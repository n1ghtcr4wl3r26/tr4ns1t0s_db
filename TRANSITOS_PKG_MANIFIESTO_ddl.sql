CREATE OR REPLACE 
PACKAGE pkg_manifiesto
AS
   /*
       p_reggestion           A?o de registro del manifiesto
       p_regaduana            Aduana de registro del manifiesto
       p_regnumero            Numero de registro del manifiesto
       p_destinoaduana        Aduana de destino

       p_destinoregimen       24 Transito; 28 Transbordo
       p_usuario              Codigo de usuario SIDUNEA++
       p_manifiestoregistro   Numero de registro del manifiesto generado
       p_manifiestoreferencia Numero de referencia del manifiesto generado
       p_transbordoempresa    Numero de NIT de la empresa transportista(solo para transbordos)
       p_transbordomedio      Identificacion del medio de transporte(solo para transbordos)
   */
   PROCEDURE generarmanifiesto (p_reggestion                    VARCHAR2,
                                p_regaduana                     VARCHAR2,
                                p_regnumero                     NUMBER,
                                p_destinoaduana                 VARCHAR2,
                                p_destinoregimen                VARCHAR2,
                                p_fechadestino                  VARCHAR2,
                                p_horadestino                   VARCHAR2,
                                p_usuario                       VARCHAR2,
                                p_manifiestoregistro     IN OUT VARCHAR2,
                                p_manifiestoreferencia   IN OUT VARCHAR2,
                                p_transbordoempresa             VARCHAR2 := NULL,
                                p_transbordomedio               VARCHAR2 := NULL);

    PROCEDURE generarmanifiestotransbordo (p_reggestion                    VARCHAR2,
                                p_regaduana                     VARCHAR2,
                                p_regnumero                     NUMBER,
                                p_destinoaduana                 VARCHAR2,
                                p_destinoregimen                VARCHAR2,
                                p_fechadestino                  VARCHAR2,
                                p_horadestino                   VARCHAR2,
                                p_usuario                       VARCHAR2,
                                p_manifiestoregistro     IN OUT VARCHAR2,
                                p_manifiestoreferencia   IN OUT VARCHAR2,
                                p_transbordoempresa             VARCHAR2 := NULL,
                                p_transbordomedio               VARCHAR2 := NULL);

END pkg_manifiesto;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_manifiesto
AS
   man_noexiste_notransito      CONSTANT INTEGER       := -20001;
   man_noexiste_bol_acancelar   CONSTANT INTEGER       := -20002;
   man_noexiste_notransito_msg           VARCHAR2 (50)
                                := 'Manifiesto no existe o no es de transito';
   man_noexiste_bol_acancelar_msg        VARCHAR2 (50)
                          := 'No existen documentos de embarque por cancelar';
   regimen_exportacion          CONSTANT VARCHAR2 (3)  := '22';
   regimen_importacion          CONSTANT VARCHAR2 (3)  := '23';
   regimen_transito             CONSTANT VARCHAR2 (3)  := '24';
   regimen_transbordo           CONSTANT VARCHAR2 (3)  := '28';
   -- car_bol_ope/car_ope_typ
   ope_operacion_memorizar      CONSTANT VARCHAR2 (3)  := 'STO';
   ope_operacion_transito       CONSTANT VARCHAR2 (3)  := 'TRS';
   ope_operacion_transbordo     CONSTANT VARCHAR2 (3)  := 'TRM';
   -- car_spy
   spy_estado_memorizada        CONSTANT VARCHAR2 (3)  := '1';
   spy_estado_registrada        CONSTANT VARCHAR2 (3)  := '2';
   spy_estado_descargada        CONSTANT VARCHAR2 (3)  := '11';
   spy_operacion_memorizar      CONSTANT VARCHAR2 (3)  := '1';
   spy_operacion_registrar      CONSTANT VARCHAR2 (3)  := '2';
   spy_operacion_transito       CONSTANT VARCHAR2 (3)  := '11';
   spy_operacion_transbordo     CONSTANT VARCHAR2 (3)  := '12';

   CURSOR bol_cur (
      p_aduana    VARCHAR2,
      p_viaje     VARCHAR2,
      p_fecha     DATE,
      p_destino   VARCHAR2
   )
   IS
      SELECT a.*, x.car_pkg_avl, x.car_wgt_avl
        FROM car_bol_gen a, car_bol_ope x
       WHERE a.key_cuo = p_aduana
         AND a.key_voy_nber = p_viaje
         AND a.key_dep_date = p_fecha
         AND a.carbol_frt_prep LIKE p_destino
         AND a.carbol_nat_cod = '24'
         AND x.car_pkg_avl > 0
         AND x.car_wgt_avl > 0
         AND a.key_cuo = x.key_cuo
         AND a.key_voy_nber = x.key_voy_nber
         AND a.key_dep_date = x.key_dep_date
         AND a.key_bol_ref = x.key_bol_ref
         AND a.key_lin_nbr = x.key_lin_nbr
         AND x.car_ope_nbr =
                (SELECT MAX (y.car_ope_nbr)
                   FROM car_bol_ope y
                  WHERE x.key_cuo = y.key_cuo
                    AND x.key_voy_nber = y.key_voy_nber
                    AND x.key_dep_date = y.key_dep_date
                    AND x.key_bol_ref = y.key_bol_ref
                    AND x.key_lin_nbr = y.key_lin_nbr);

   CURSOR bollist_cur (p_aduana VARCHAR2, p_viaje VARCHAR2, p_fecha DATE)
   IS
      SELECT     *
            FROM car_bol_gen
           WHERE key_cuo = p_aduana
             AND key_voy_nber = p_viaje
             AND key_dep_date = p_fecha
      FOR UPDATE;

   CURSOR ctn_cur (
      p_aduana   VARCHAR2,
      p_viaje    VARCHAR2,
      p_fecha    DATE,
      p_bol      VARCHAR2,
      p_linea    NUMBER
   )
   IS
      SELECT *
        FROM car_bol_ctn
       WHERE key_cuo = p_aduana
         AND key_voy_nber = p_viaje
         AND key_dep_date = p_fecha
         AND key_bol_ref = p_bol
         AND key_lin_nbr = p_linea;

   FUNCTION obtienesecuencia (p_aduana VARCHAR2, p_viaje VARCHAR2, p_date DATE)
      RETURN VARCHAR2
   IS
      v_casos       NUMBER;
      v_secuencia   VARCHAR2 (10) := '';
   BEGIN
      SELECT COUNT (1)
        INTO v_casos
        FROM car_gen
       WHERE key_cuo = p_aduana
         AND key_voy_nber LIKE p_viaje || '%'
         AND key_dep_date = p_date;

      IF NOT (v_casos IS NULL OR v_casos = 0)
      THEN
         v_secuencia := '/' || v_casos;
      END IF;

      RETURN v_secuencia;
   END;

   FUNCTION numeromanifiesto (p_anio VARCHAR2)
      RETURN NUMBER
   IS
      v_numero   NUMBER       := 1;
      v_serie    VARCHAR2 (1) := 'M';
   BEGIN
      UPDATE    app_ser
            SET app_nber = app_nber + 1
          WHERE app_year = p_anio AND app_cuo IS NULL AND app_serial = v_serie
      RETURNING app_nber
           INTO v_numero;

      IF SQL%ROWCOUNT = 0
      THEN
         INSERT INTO app_ser
                     (app_year, app_serial, app_nber
                     )
              VALUES (p_anio, v_serie, v_numero
                     );
      END IF;

      RETURN v_numero;
   END numeromanifiesto;

   PROCEDURE addope (ope car_bol_ope%ROWTYPE)
   IS
      v_bol_ser     NUMBER        := 0;
      v_fecha       DATE;
      v_hora        VARCHAR2 (11);
      v_operacion   NUMBER        := 0;
   BEGIN
      v_operacion := ope.car_ope_nbr;

      IF v_operacion = 0
      THEN
         SELECT MAX (car_ope_nbr)
           INTO v_operacion
           FROM car_bol_ope
          WHERE key_cuo = ope.key_cuo
            AND key_voy_nber = ope.key_voy_nber
            AND key_dep_date = ope.key_dep_date
            AND key_bol_ref = ope.key_bol_ref
            AND key_lin_nbr = ope.key_lin_nbr;

         v_operacion := v_operacion + 1;
      END IF;

      SELECT     ops$asy.car_bol_ser.NEXTVAL
            INTO v_bol_ser
            FROM DUAL
      FOR UPDATE;

      v_fecha := TRUNC (SYSDATE);
      v_hora := TO_CHAR (SYSDATE, 'hh24:mi:ss');

      INSERT INTO car_bol_ope
                  (key_cuo, key_voy_nber, key_dep_date,
                   key_bol_ref, key_lin_nbr, car_pkg_avl,
                   car_wgt_avl, car_loc_cod, car_loc_inf,
                   car_trs_cuo, car_doc_ref, car_trm_loc,
                   car_onw_cod, car_onw_nam, car_ope_typ,
                   car_ope_dat, car_ope_hor, car_ope_nbr, car_pkg_deb,
                   car_pkg_cre, car_wgt_deb, car_wgt_cre,
                   car_ass_ser, car_ass_nbr, car_ass_dat,
                   car_ass_itm, car_pst_num, car_man_dsc,
                   car_ope_usr, car_bol_ser
                  )
           VALUES (ope.key_cuo, ope.key_voy_nber, ope.key_dep_date,
                   ope.key_bol_ref, ope.key_lin_nbr, ope.car_pkg_avl,
                   ope.car_wgt_avl, ope.car_loc_cod, ope.car_loc_inf,
                   ope.car_trs_cuo, ope.car_doc_ref, ope.car_trm_loc,
                   ope.car_onw_cod, ope.car_onw_nam, ope.car_ope_typ,
                   v_fecha, v_hora, v_operacion, ope.car_pkg_deb,
                   ope.car_pkg_cre, ope.car_wgt_deb, ope.car_wgt_cre,
                   ope.car_ass_ser, ope.car_ass_nbr, ope.car_ass_dat,
                   ope.car_ass_itm, ope.car_pst_num, ope.car_man_dsc,
                   ope.car_ope_usr, v_bol_ser
                  );
   END;

   PROCEDURE addcarspy (
      p_operacion   VARCHAR2,
      p_aduana      VARCHAR2,
      p_viaje       VARCHAR2,
      p_bol         VARCHAR2,
      p_salida      DATE,
      p_usuario     VARCHAR2
   )
   IS
      v_mensaje     NUMBER;
      v_estado      VARCHAR2 (3);
      v_operacion   VARCHAR (3);
      v_fecha       DATE;
      v_hora        VARCHAR2 (11);
   BEGIN
      v_fecha := TRUNC (SYSDATE);
      v_hora := TO_CHAR (SYSDATE, 'HH24:MI:SS');

      IF p_operacion = spy_operacion_memorizar
      THEN
         v_estado := spy_estado_memorizada;
         v_operacion := spy_operacion_memorizar;
         v_mensaje := 1900;
      ELSIF p_operacion = spy_operacion_registrar
      THEN
         v_estado := spy_estado_registrada;
         v_operacion := spy_operacion_registrar;
         v_mensaje := 1936;
      ELSIF p_operacion = spy_operacion_transito
      THEN
         v_estado := spy_estado_descargada;
         v_operacion := spy_operacion_transito;
         v_mensaje := 1970;
      ELSIF p_operacion = spy_operacion_transbordo
      THEN
         v_estado := spy_estado_descargada;
         v_operacion := spy_operacion_transbordo;
         v_mensaje := 1974;
      END IF;

      INSERT INTO car_spy
                  (key_cuo, key_voy_nber, key_dep_date, key_bol_ref, spy_sta,
                   spy_act, usr_nam, act_date, act_time, rtp_nbr
                  )
           VALUES (p_aduana, p_viaje, p_salida, p_bol, v_estado,
                   v_operacion, p_usuario, v_fecha, v_hora, v_mensaje
                  );
   END addcarspy;

   PROCEDURE descargarbol (
      p_regimen      VARCHAR2,
      p_aduana       VARCHAR2,
      p_viaje        VARCHAR2,
      p_salida       DATE,
      p_destino      VARCHAR2,
      p_criterio     VARCHAR2,
      p_referencia   VARCHAR2,
      p_usuario      VARCHAR2
   )
   IS
      v_referencia   VARCHAR2 (100);
      v_operacion    VARCHAR2 (3);
      ope_rec        car_bol_ope%ROWTYPE;
   BEGIN
      v_referencia := SUBSTR (p_referencia, 1, LENGTH (p_referencia) - 9);

      FOR bol_rec IN bol_cur (p_aduana, p_viaje, p_salida, p_criterio)
      LOOP
         ope_rec.key_cuo := bol_rec.key_cuo;
         ope_rec.key_voy_nber := bol_rec.key_voy_nber;
         ope_rec.key_dep_date := bol_rec.key_dep_date;
         ope_rec.key_bol_ref := bol_rec.key_bol_ref;
         ope_rec.key_lin_nbr := bol_rec.key_lin_nbr;
         ope_rec.car_pkg_avl := 0;
         ope_rec.car_wgt_avl := 0;
         ope_rec.car_loc_cod := NULL;
         ope_rec.car_loc_inf := NULL;

         IF p_regimen = regimen_transbordo
         THEN
            ope_rec.car_trs_cuo := NULL;
            ope_rec.car_trm_loc := p_destino;
            ope_rec.car_ope_typ := ope_operacion_transbordo;
            v_operacion := spy_operacion_transbordo;
         ELSE
            ope_rec.car_trs_cuo := p_destino;
            ope_rec.car_trm_loc := NULL;
            ope_rec.car_ope_typ := ope_operacion_transito;
            v_operacion := spy_operacion_transito;
         END IF;

         ope_rec.car_doc_ref := v_referencia;
         ope_rec.car_onw_cod := NULL;                -- transito transportista
         ope_rec.car_onw_nam := NULL;
         ope_rec.car_ope_nbr := 0;
         ope_rec.car_pkg_deb := bol_rec.car_pkg_avl;
         ope_rec.car_pkg_cre := 0;
         ope_rec.car_wgt_deb := bol_rec.car_wgt_avl;
         ope_rec.car_wgt_cre := 0;
         ope_rec.car_ass_ser := NULL;
         ope_rec.car_ass_nbr := NULL;
         ope_rec.car_ass_dat := NULL;
         ope_rec.car_ass_itm := 0;
         ope_rec.car_pst_num := 0;
         ope_rec.car_man_dsc := NULL;
         ope_rec.car_ope_usr := p_usuario;
         addope (ope_rec);
         addcarspy (v_operacion,
                    bol_rec.key_cuo,
                    bol_rec.key_voy_nber,
                    bol_rec.key_bol_ref,
                    bol_rec.key_dep_date,
                    p_usuario
                   );
      END LOOP;
   END;

   PROCEDURE registrarmanifiesto (
      p_aduana                VARCHAR2,
      p_viaje                 VARCHAR2,
      p_salida                DATE,
      p_usuario               VARCHAR2,
      p_manifiesto   IN OUT   VARCHAR2
   )
   IS
      v_registro        NUMBER;
      v_fechatrabajo    DATE          := SYSDATE;
      v_anioregistro    VARCHAR2 (4)  := TO_CHAR (v_fechatrabajo, 'yyyy');
      v_fecharegistro   DATE          := TRUNC (v_fechatrabajo);
      v_fecha           VARCHAR2 (50);
      v_numero          VARCHAR2 (50);
      v_horaregistro    VARCHAR2 (11)
                                    := TO_CHAR (v_fechatrabajo, 'hh24:mi:ss');
   BEGIN
      p_manifiesto := NULL;
      v_registro := numeromanifiesto (v_anioregistro);

      UPDATE car_gen
         SET car_reg_nber = v_registro,
             car_reg_year = v_anioregistro,
             car_reg_date = v_fecharegistro,
             car_reg_time = v_horaregistro
       WHERE key_cuo = p_aduana
         AND key_voy_nber = p_viaje
         AND key_dep_date = p_salida;

      IF SQL%ROWCOUNT = 1
      THEN
         addcarspy (spy_operacion_registrar,
                    p_aduana,
                    p_viaje,
                    NULL,
                    p_salida,
                    p_usuario
                   );

         FOR bol_rec IN bollist_cur (p_aduana, p_viaje, p_salida)
         LOOP
            addcarspy (spy_operacion_registrar,
                       bol_rec.key_cuo,
                       bol_rec.key_voy_nber,
                       bol_rec.key_bol_ref,
                       bol_rec.key_dep_date,
                       p_usuario
                      );
         END LOOP;
      END IF;

      v_fecha := TO_CHAR (v_fechatrabajo, 'dd/mm/yyyy hh24:mi:ss');
      p_manifiesto :=
         v_anioregistro || '/' || p_aduana || '-' || v_registro || ' '
         || v_fecha;
   END registrarmanifiesto;

   PROCEDURE addcontenedor (
      p_aduanap   VARCHAR2,
      p_viajep    VARCHAR2,
      p_lineap    NUMBER,
      p_aduana    VARCHAR2,
      p_viaje     VARCHAR2,
      p_fecha     DATE,
      p_bol       VARCHAR2,
      p_linea     NUMBER
   )
   IS
   BEGIN
      FOR ctn_rec IN ctn_cur (p_aduanap, p_viajep, p_fecha, p_bol, p_lineap)
      LOOP
         INSERT INTO car_bol_ctn
                     (key_cuo, key_voy_nber, key_dep_date, key_bol_ref,
                      key_lin_nbr, car_ctn_nbr, car_ctn_ident,
                      car_ctn_typ, car_ctn_full,
                      car_ctn_seal1, car_ctn_seal2,
                      car_ctn_seal3, car_ctn_seal
                     )
              VALUES (p_aduana, p_viaje, p_fecha, p_bol,
                      p_linea, ctn_rec.car_ctn_nbr, ctn_rec.car_ctn_ident,
                      ctn_rec.car_ctn_typ, ctn_rec.car_ctn_full,
                      ctn_rec.car_ctn_seal1, ctn_rec.car_ctn_seal2,
                      ctn_rec.car_ctn_seal3, ctn_rec.car_ctn_seal
                     );
      END LOOP;
   END;

   PROCEDURE addbol (bol bol_cur%ROWTYPE)
   IS
   BEGIN
      INSERT INTO car_bol_gen
                  (key_cuo, key_voy_nber, key_dep_date,
                   key_bol_ref, key_lin_nbr, carbol_sline_nber,
                   carbol_status, carbol_typ_cod,
                   carbol_nat_cod, carbol_ucr_ref,
                   carbol_exp_nam, carbol_exp_adr1,
                   carbol_exp_adr2, carbol_exp_adr3,
                   carbol_exp_adr4, carbol_cons_cod,
                   carbol_cons_nam, carbol_cons_adr1,
                   carbol_cons_adr2, carbol_cons_adr3,
                   carbol_cons_adr4, carbol_ntfy_cod,
                   carbol_ntfy_nam, carbol_ntfy_adr1,
                   carbol_ntfy_adr2, carbol_ntfy_adr3,
                   carbol_ntfy_adr4, carbol_dep_cod,
                   carbol_dest_cod, carbol_cont_nber,
                   carbol_pack_cod, carbol_pack_nber, carbol_gros_mas,
                   carbol_cbm, carbol_shp_mark1,
                   carbol_shp_mark2, carbol_shp_mark3,
                   carbol_shp_mark4, carbol_shp_mark5,
                   carbol_good1, carbol_good2, carbol_good3,
                   carbol_good4, carbol_good5,
                   carbol_cust_value, carbol_cust_cur,
                   carbol_trsp_value, carbol_trsp_cur,
                   carbol_insu_value, carbol_insu_cur,
                   carbol_subbol_nbr, carbol_seal_nber,
                   carbol_seal_mrks1, carbol_seal_mrks2,
                   carbol_seal_cod, carbol_infos1,
                   carbol_infos2, carbol_frt_prep
                  )
           VALUES (bol.key_cuo, bol.key_voy_nber, bol.key_dep_date,
                   bol.key_bol_ref, bol.key_lin_nbr, bol.carbol_sline_nber,
                   bol.carbol_status, bol.carbol_typ_cod,
                   bol.carbol_nat_cod, bol.carbol_ucr_ref,
                   bol.carbol_exp_nam, bol.carbol_exp_adr1,
                   bol.carbol_exp_adr2, bol.carbol_exp_adr3,
                   bol.carbol_exp_adr4, bol.carbol_cons_cod,
                   bol.carbol_cons_nam, bol.carbol_cons_adr1,
                   bol.carbol_cons_adr2, bol.carbol_cons_adr3,
                   bol.carbol_cons_adr4, bol.carbol_ntfy_cod,
                   bol.carbol_ntfy_nam, bol.carbol_ntfy_adr1,
                   bol.carbol_ntfy_adr2, bol.carbol_ntfy_adr3,
                   bol.carbol_ntfy_adr4, bol.carbol_dep_cod,
                   bol.carbol_dest_cod, bol.carbol_cont_nber,
                   bol.carbol_pack_cod, bol.car_pkg_avl, bol.car_wgt_avl,
                   bol.carbol_cbm, bol.carbol_shp_mark1,
                   bol.carbol_shp_mark2, bol.carbol_shp_mark3,
                   bol.carbol_shp_mark4, bol.carbol_shp_mark5,
                   bol.carbol_good1, bol.carbol_good2, bol.carbol_good3,
                   bol.carbol_good4, bol.carbol_good5,
                   bol.carbol_cust_value, bol.carbol_cust_cur,
                   bol.carbol_trsp_value, bol.carbol_trsp_cur,
                   bol.carbol_insu_value, bol.carbol_insu_cur,
                   bol.carbol_subbol_nbr, bol.carbol_seal_nber,
                   bol.carbol_seal_mrks1, bol.carbol_seal_mrks2,
                   bol.carbol_seal_cod, bol.carbol_infos1,
                   bol.carbol_infos2, bol.carbol_frt_prep
                  );
   END;

   PROCEDURE memorizarmanifiesto (
      man                      car_gen%ROWTYPE,
      p_destinoaduana          VARCHAR2,
      p_manifiestoreferencia   VARCHAR2,
      p_destinocriterio        VARCHAR2,
      p_destinoregimen         VARCHAR2,
      p_totalbol               NUMBER,
      p_totalcantidad          NUMBER,
      p_totalpeso              NUMBER,
      p_totalcontenedor        NUMBER,
      p_usuario                VARCHAR2
   )
   IS
--      v_destinoviaje   VARCHAR2 (35);
      v_destinofecha   DATE;
      v_anterior       VARCHAR2 (35);
      v_item           NUMBER                := 0;
      v_item_ant       NUMBER;
      ope_rec          car_bol_ope%ROWTYPE;
      v_dep_cod        VARCHAR (2);
      v_dest_cod       VARCHAR (2);
   BEGIN
--      v_destinoviaje := 'GRM' || man.car_reg_year || '-' || man.car_reg_nber;
      v_destinofecha := man.key_dep_date;
      v_anterior :=
            'BO'
         || '&'
         || man.car_reg_year
         || '&'
         || man.key_cuo
         || '&'
         || man.car_reg_nber;

      INSERT INTO car_gen
                  (key_cuo, key_voy_nber, key_dep_date,
                   car_arr_date, car_arr_time, car_dep_cod,
                   car_dest_cod, car_car_cod, car_car_nam,
                   car_car_adr1, car_car_adr2, car_car_adr3,
                   car_car_adr4, car_mot_cod, car_id_trp,
                   car_nat_cod, car_trsp_pla, car_tr_regref,
                   car_tr_regdat, car_mast_nam, car_mast_inf1,
                   car_mast_inf2, car_bl_nber, car_pac_nber,
                   car_gros_mass, car_cntr_nbr
                  )
           VALUES (p_destinoaduana, p_manifiestoreferencia, v_destinofecha,
                   man.car_arr_date, man.car_arr_time, man.car_dep_cod,
                   man.car_dest_cod, man.car_car_cod, man.car_car_nam,
                   man.car_car_adr1, man.car_car_adr2, man.car_car_adr3,
                   man.car_car_adr4, man.car_mot_cod, man.car_id_trp,
                   man.car_nat_cod, man.car_trsp_pla, v_anterior,
                   man.car_reg_date, man.car_mast_nam, man.car_mast_inf1,
                   man.car_mast_inf2, p_totalbol, p_totalcantidad,
                   p_totalpeso, p_totalcontenedor
                  );

      addcarspy (spy_operacion_memorizar,
                 p_destinoaduana,
                 p_manifiestoreferencia,
                 NULL,
                 v_destinofecha,
                 p_usuario
                );

      FOR bol_rec IN bol_cur (man.key_cuo,
                              man.key_voy_nber,
                              man.key_dep_date,
                              p_destinocriterio
                             )
      LOOP
         -- Registro en car_bol_gen del BOL
         v_item := v_item + 1;
         v_item_ant := bol_rec.key_lin_nbr;
         bol_rec.key_cuo := p_destinoaduana;
         bol_rec.key_voy_nber := p_manifiestoreferencia;
         bol_rec.key_dep_date := v_destinofecha;
         bol_rec.key_lin_nbr := v_item;
         bol_rec.carbol_sline_nber := 0;
         bol_rec.carbol_nat_cod := p_destinoregimen;
         v_dep_cod := SUBSTR (bol_rec.carbol_dep_cod, 1, 2);
         v_dest_cod := SUBSTR (bol_rec.carbol_dest_cod, 1, 2);

         IF     p_destinoregimen = regimen_importacion
            AND (    (v_dep_cod <> 'BO' AND v_dest_cod <> 'BO')
                 AND (v_dep_cod <> 'ZF' AND v_dest_cod <> 'ZF')
                )
         THEN
            bol_rec.carbol_frt_prep := NULL;
            bol_rec.carbol_nat_cod := regimen_transito;
         ELSIF    p_destinoregimen = regimen_importacion
               OR p_destinoregimen = regimen_exportacion
         THEN
            bol_rec.carbol_frt_prep := NULL;
         END IF;

         addbol (bol_rec);

         IF bol_rec.carbol_cont_nber > 0
         THEN
            addcontenedor (man.key_cuo,
                           man.key_voy_nber,
                           v_item_ant,
                           bol_rec.key_cuo,
                           bol_rec.key_voy_nber,
                           bol_rec.key_dep_date,
                           bol_rec.key_bol_ref,
                           bol_rec.key_lin_nbr
                          );
         END IF;

         -- Registro en car_bol_ope del BOL
         ope_rec.key_cuo := p_destinoaduana;
         ope_rec.key_voy_nber := p_manifiestoreferencia;
         ope_rec.key_dep_date := v_destinofecha;
         ope_rec.key_bol_ref := bol_rec.key_bol_ref;
         ope_rec.key_lin_nbr := bol_rec.key_lin_nbr;
         ope_rec.car_pkg_avl := bol_rec.car_pkg_avl;
         ope_rec.car_wgt_avl := bol_rec.car_wgt_avl;
         ope_rec.car_loc_cod := NULL;
         ope_rec.car_loc_inf := NULL;
         ope_rec.car_trs_cuo := NULL;
         ope_rec.car_doc_ref := NULL;
         ope_rec.car_trm_loc := NULL;
         ope_rec.car_onw_cod := NULL;
         ope_rec.car_onw_nam := NULL;
         ope_rec.car_ope_typ := ope_operacion_memorizar;
         ope_rec.car_ope_nbr := 1;
         ope_rec.car_pkg_deb := 0;
         ope_rec.car_pkg_cre := bol_rec.car_pkg_avl;
         ope_rec.car_wgt_deb := 0;
         ope_rec.car_wgt_cre := bol_rec.car_wgt_avl;
         ope_rec.car_ass_ser := NULL;
         ope_rec.car_ass_nbr := NULL;
         ope_rec.car_ass_dat := NULL;
         ope_rec.car_ass_itm := 0;
         ope_rec.car_pst_num := 0;
         ope_rec.car_man_dsc := NULL;
         ope_rec.car_ope_usr := p_usuario;
         addope (ope_rec);
         addcarspy (spy_operacion_memorizar,
                    p_destinoaduana,
                    p_manifiestoreferencia,
                    bol_rec.key_bol_ref,
                    v_destinofecha,
                    p_usuario
                   );
      END LOOP;
   END memorizarmanifiesto;

   PROCEDURE generarmanifiesto (
      p_reggestion                      VARCHAR2,
      p_regaduana                       VARCHAR2,
      p_regnumero                       NUMBER,
      p_destinoaduana                   VARCHAR2,
      p_destinoregimen                  VARCHAR2,
      p_fechadestino                    VARCHAR2,
      p_horadestino                     VARCHAR2,
      p_usuario                         VARCHAR2,
      p_manifiestoregistro     IN OUT   VARCHAR2,
      p_manifiestoreferencia   IN OUT   VARCHAR2,
      p_transbordoempresa               VARCHAR2 := NULL,
      p_transbordomedio                 VARCHAR2 := NULL
   )
   IS
      v_destinoregimen    VARCHAR2 (2);
      v_destinoaduana     VARCHAR2 (5);
      v_destinocriterio   VARCHAR2 (5);
      v_viajenumero       VARCHAR2 (17);
      v_viajefecha        DATE;
      v_totalbol          NUMBER            := 0;
      v_totalcantidad     NUMBER            := 0;
      v_totalpeso         NUMBER (18, 2)    := 0;
      v_totalcontenedor   NUMBER            := 0;
      man_rec             car_gen%ROWTYPE;
      v_interior_o_zf     VARCHAR2 (1);
      v_frontera          VARCHAR2 (1);
      v_exportacion       BOOLEAN;
   BEGIN
      v_destinocriterio := '%';
      v_destinoregimen := regimen_transito;

      IF p_destinoregimen = regimen_transito
      THEN
         v_destinocriterio := p_destinoaduana;
         v_destinoregimen := regimen_importacion;
         v_interior_o_zf := SUBSTR (p_regaduana, 2, 1);
         v_frontera := SUBSTR (p_destinoaduana, 2, 1);
         v_exportacion :=
                (v_interior_o_zf = '0' OR v_interior_o_zf = '3')
            AND (v_frontera = '2' OR v_frontera = '4');

         IF v_exportacion
         THEN
            v_destinoregimen := regimen_exportacion;
         END IF;
      ELSIF p_destinoregimen = regimen_importacion
      THEN
         v_destinoregimen := regimen_importacion;
      END IF;

      SELECT *
        INTO man_rec
        FROM car_gen a
       WHERE car_reg_year = p_reggestion
         AND key_cuo = p_regaduana
         AND car_reg_nber = p_regnumero
         AND EXISTS (
                SELECT 1
                  FROM car_bol_gen b
                 WHERE a.key_cuo = b.key_cuo
                   AND a.key_voy_nber = b.key_voy_nber
                   AND a.key_dep_date = b.key_dep_date
                   AND b.carbol_frt_prep LIKE v_destinocriterio
                   AND b.carbol_nat_cod = '24');

      IF SQL%ROWCOUNT = 0
      THEN
         raise_application_error (man_noexiste_notransito,
                                  man_noexiste_notransito_msg
                                 );
      END IF;

      IF p_destinoregimen = regimen_transbordo
      THEN
         SELECT car_nam, car_adr,
                car_ad2, car_ad3,
                car_ad4
           INTO man_rec.car_car_nam, man_rec.car_car_adr1,
                man_rec.car_car_adr2, man_rec.car_car_adr3,
                man_rec.car_car_adr4
           FROM uncartab
          WHERE car_cod = p_transbordoempresa AND lst_ope = 'U';

         SELECT cmp_nam
           INTO man_rec.car_trsp_pla
           FROM unprptab
          WHERE cmp_cod = p_transbordomedio
            AND prp_nam = p_transbordoempresa
            AND lst_ope = 'U';

         man_rec.car_car_cod := p_transbordoempresa;
         man_rec.car_id_trp := UPPER (p_transbordomedio);
      END IF;

      SELECT COUNT (1), SUM (x.car_pkg_avl), SUM (x.car_wgt_avl),
             SUM (a.carbol_cont_nber)
        INTO v_totalbol, v_totalcantidad, v_totalpeso,
             v_totalcontenedor
        FROM car_bol_gen a, car_bol_ope x
       WHERE a.key_cuo = man_rec.key_cuo
         AND a.key_voy_nber = man_rec.key_voy_nber
         AND a.key_dep_date = man_rec.key_dep_date
         AND a.carbol_frt_prep LIKE v_destinocriterio
         AND a.carbol_nat_cod = '24'
         AND x.car_pkg_avl > 0
         AND x.car_wgt_avl > 0
         AND a.key_cuo = x.key_cuo
         AND a.key_voy_nber = x.key_voy_nber
         AND a.key_dep_date = x.key_dep_date
         AND a.key_bol_ref = x.key_bol_ref
         AND a.key_lin_nbr = x.key_lin_nbr
         AND x.car_ope_nbr =
                (SELECT MAX (y.car_ope_nbr)
                   FROM car_bol_ope y
                  WHERE x.key_cuo = y.key_cuo
                    AND x.key_voy_nber = y.key_voy_nber
                    AND x.key_dep_date = y.key_dep_date
                    AND x.key_bol_ref = y.key_bol_ref
                    AND x.key_lin_nbr = y.key_lin_nbr);

      IF v_totalbol = 0
      THEN
         raise_application_error (man_noexiste_bol_acancelar,
                                  man_noexiste_bol_acancelar_msg
                                 );
      END IF;

      man_rec.car_arr_date := TO_DATE (p_fechadestino, 'dd/mm/yyyy');
      man_rec.car_arr_time := p_horadestino;
      p_manifiestoreferencia :=
                  'GRM' || man_rec.car_reg_year || '-' || man_rec.car_reg_nber;

      IF    p_destinoregimen = regimen_importacion
         OR p_destinoregimen = regimen_transbordo
      THEN
         p_manifiestoreferencia :=
               p_manifiestoreferencia
            || obtienesecuencia (p_destinoaduana,
                                 p_manifiestoreferencia,
                                 man_rec.key_dep_date
                                );
      END IF;

      memorizarmanifiesto (man_rec,
                           p_destinoaduana,
                           p_manifiestoreferencia,
                           v_destinocriterio,
                           v_destinoregimen,
                           v_totalbol,
                           v_totalcantidad,
                           v_totalpeso,
                           v_totalcontenedor,
                           p_usuario
                          );
      registrarmanifiesto (p_destinoaduana,
                           p_manifiestoreferencia,
                           man_rec.key_dep_date,
                           p_usuario,
                           p_manifiestoregistro
                          );
      descargarbol (p_destinoregimen,
                    man_rec.key_cuo,
                    man_rec.key_voy_nber,
                    man_rec.key_dep_date,
                    p_destinoaduana,
                    v_destinocriterio,
                    p_manifiestoregistro,
                    p_usuario
                   );
   END;



PROCEDURE memorizarmanifiestotransbordo (
      man                      car_gen%ROWTYPE,
      p_destinoaduana          VARCHAR2,
      p_manifiestoreferencia   VARCHAR2,
      p_destinocriterio        VARCHAR2,
      p_destinoregimen         VARCHAR2,
      p_totalbol               NUMBER,
      p_totalcantidad          NUMBER,
      p_totalpeso              NUMBER,
      p_totalcontenedor        NUMBER,
      p_usuario                VARCHAR2
   )
   IS
--      v_destinoviaje   VARCHAR2 (35);
      v_destinofecha   DATE;
      v_anterior       VARCHAR2 (35);
      v_item           NUMBER                := 0;
      v_item_ant       NUMBER;
      ope_rec          car_bol_ope%ROWTYPE;
      v_dep_cod        VARCHAR (2);
      v_dest_cod       VARCHAR (2);
   BEGIN
--      v_destinoviaje := 'GRM' || man.car_reg_year || '-' || man.car_reg_nber;
      v_destinofecha := man.key_dep_date;
      v_anterior :=
            'BO'
         || '&'
         || man.car_reg_year
         || '&'
         || man.key_cuo
         || '&'
         || man.car_reg_nber;

      INSERT INTO car_gen
                  (key_cuo, key_voy_nber, key_dep_date,
                   car_arr_date, car_arr_time, car_dep_cod,
                   car_dest_cod, car_car_cod, car_car_nam,
                   car_car_adr1, car_car_adr2, car_car_adr3,
                   car_car_adr4, car_mot_cod, car_id_trp,
                   car_nat_cod, car_trsp_pla, car_tr_regref,
                   car_tr_regdat, car_mast_nam, car_mast_inf1,
                   car_mast_inf2, car_bl_nber, car_pac_nber,
                   car_gros_mass, car_cntr_nbr
                  )
           VALUES (p_destinoaduana, p_manifiestoreferencia, v_destinofecha,
                   man.car_arr_date, man.car_arr_time, man.car_dep_cod,
                   man.car_dest_cod, man.car_car_cod, man.car_car_nam,
                   man.car_car_adr1, man.car_car_adr2, man.car_car_adr3,
                   man.car_car_adr4, man.car_mot_cod, man.car_id_trp,
                   man.car_nat_cod, man.car_trsp_pla, v_anterior,
                   man.car_reg_date, man.car_mast_nam, man.car_mast_inf1,
                   man.car_mast_inf2, p_totalbol, p_totalcantidad,
                   p_totalpeso, p_totalcontenedor
                  );

      addcarspy (spy_operacion_memorizar,
                 p_destinoaduana,
                 p_manifiestoreferencia,
                 NULL,
                 v_destinofecha,
                 p_usuario
                );

      FOR bol_rec IN bol_cur (man.key_cuo,
                              man.key_voy_nber,
                              man.key_dep_date,
                              p_destinocriterio
                             )
      LOOP
         -- Registro en car_bol_gen del BOL
         v_item := v_item + 1;
         v_item_ant := bol_rec.key_lin_nbr;
         bol_rec.key_cuo := p_destinoaduana;
         bol_rec.key_voy_nber := p_manifiestoreferencia;
         bol_rec.key_dep_date := v_destinofecha;
         bol_rec.key_lin_nbr := v_item;
         bol_rec.carbol_sline_nber := 0;
         bol_rec.carbol_nat_cod := p_destinoregimen;
         v_dep_cod := SUBSTR (bol_rec.carbol_dep_cod, 1, 2);
         v_dest_cod := SUBSTR (bol_rec.carbol_dest_cod, 1, 2);

         IF     p_destinoregimen = regimen_importacion
            AND (    (v_dep_cod <> 'BO' AND v_dest_cod <> 'BO')
                 AND (v_dep_cod <> 'ZF' AND v_dest_cod <> 'ZF')
                )
         THEN
            bol_rec.carbol_frt_prep := NULL;
            bol_rec.carbol_nat_cod := regimen_transito;
         ELSIF    p_destinoregimen = regimen_importacion
               OR p_destinoregimen = regimen_exportacion
         THEN
            bol_rec.carbol_frt_prep := NULL;
         END IF;
         /*PARA TRANSBORDO A FERREO */
         bol_rec.carbol_typ_cod := 'TIF';
         addbol (bol_rec);

         IF bol_rec.carbol_cont_nber > 0
         THEN
            addcontenedor (man.key_cuo,
                           man.key_voy_nber,
                           v_item_ant,
                           bol_rec.key_cuo,
                           bol_rec.key_voy_nber,
                           bol_rec.key_dep_date,
                           bol_rec.key_bol_ref,
                           bol_rec.key_lin_nbr
                          );
         END IF;

         -- Registro en car_bol_ope del BOL
         ope_rec.key_cuo := p_destinoaduana;
         ope_rec.key_voy_nber := p_manifiestoreferencia;
         ope_rec.key_dep_date := v_destinofecha;
         ope_rec.key_bol_ref := bol_rec.key_bol_ref;
         ope_rec.key_lin_nbr := bol_rec.key_lin_nbr;
         ope_rec.car_pkg_avl := bol_rec.car_pkg_avl;
         ope_rec.car_wgt_avl := bol_rec.car_wgt_avl;
         ope_rec.car_loc_cod := NULL;
         ope_rec.car_loc_inf := NULL;
         ope_rec.car_trs_cuo := NULL;
         ope_rec.car_doc_ref := NULL;
         ope_rec.car_trm_loc := NULL;
         ope_rec.car_onw_cod := NULL;
         ope_rec.car_onw_nam := NULL;
         ope_rec.car_ope_typ := ope_operacion_memorizar;
         ope_rec.car_ope_nbr := 1;
         ope_rec.car_pkg_deb := 0;
         ope_rec.car_pkg_cre := bol_rec.car_pkg_avl;
         ope_rec.car_wgt_deb := 0;
         ope_rec.car_wgt_cre := bol_rec.car_wgt_avl;
         ope_rec.car_ass_ser := NULL;
         ope_rec.car_ass_nbr := NULL;
         ope_rec.car_ass_dat := NULL;
         ope_rec.car_ass_itm := 0;
         ope_rec.car_pst_num := 0;
         ope_rec.car_man_dsc := NULL;
         ope_rec.car_ope_usr := p_usuario;
         addope (ope_rec);
         addcarspy (spy_operacion_memorizar,
                    p_destinoaduana,
                    p_manifiestoreferencia,
                    bol_rec.key_bol_ref,
                    v_destinofecha,
                    p_usuario
                   );
      END LOOP;
   END memorizarmanifiestotransbordo;

   PROCEDURE generarmanifiestotransbordo (
      p_reggestion                      VARCHAR2,
      p_regaduana                       VARCHAR2,
      p_regnumero                       NUMBER,
      p_destinoaduana                   VARCHAR2,
      p_destinoregimen                  VARCHAR2,
      p_fechadestino                    VARCHAR2,
      p_horadestino                     VARCHAR2,
      p_usuario                         VARCHAR2,
      p_manifiestoregistro     IN OUT   VARCHAR2,
      p_manifiestoreferencia   IN OUT   VARCHAR2,
      p_transbordoempresa               VARCHAR2 := NULL,
      p_transbordomedio                 VARCHAR2 := NULL
   )
   IS
      v_destinoregimen    VARCHAR2 (2);
      v_destinoaduana     VARCHAR2 (5);
      v_destinocriterio   VARCHAR2 (5);
      v_viajenumero       VARCHAR2 (17);
      v_viajefecha        DATE;
      v_totalbol          NUMBER            := 0;
      v_totalcantidad     NUMBER            := 0;
      v_totalpeso         NUMBER (18, 2)    := 0;
      v_totalcontenedor   NUMBER            := 0;
      man_rec             car_gen%ROWTYPE;
      v_interior_o_zf     VARCHAR2 (1);
      v_frontera          VARCHAR2 (1);
      v_exportacion       BOOLEAN;
   BEGIN
      v_destinocriterio := '%';
      v_destinoregimen := regimen_transito;

      IF p_destinoregimen = regimen_transito
      THEN
         v_destinocriterio := p_destinoaduana;
         v_destinoregimen := regimen_importacion;
         v_interior_o_zf := SUBSTR (p_regaduana, 2, 1);
         v_frontera := SUBSTR (p_destinoaduana, 2, 1);
         v_exportacion :=
                (v_interior_o_zf = '0' OR v_interior_o_zf = '3')
            AND (v_frontera = '2' OR v_frontera = '4');

         IF v_exportacion
         THEN
            v_destinoregimen := regimen_exportacion;
         END IF;
      ELSIF p_destinoregimen = regimen_importacion
      THEN
         v_destinoregimen := regimen_importacion;
      END IF;

      SELECT *
        INTO man_rec
        FROM car_gen a
       WHERE car_reg_year = p_reggestion
         AND key_cuo = p_regaduana
         AND car_reg_nber = p_regnumero
         AND EXISTS (
                SELECT 1
                  FROM car_bol_gen b
                 WHERE a.key_cuo = b.key_cuo
                   AND a.key_voy_nber = b.key_voy_nber
                   AND a.key_dep_date = b.key_dep_date
                   AND b.carbol_frt_prep LIKE v_destinocriterio
                   AND b.carbol_nat_cod = '24');

      IF SQL%ROWCOUNT = 0
      THEN
         raise_application_error (man_noexiste_notransito,
                                  man_noexiste_notransito_msg
                                 );
      END IF;

      IF p_destinoregimen = regimen_transbordo
      THEN
         SELECT car_nam, car_adr,
                car_ad2, car_ad3,
                car_ad4
           INTO man_rec.car_car_nam, man_rec.car_car_adr1,
                man_rec.car_car_adr2, man_rec.car_car_adr3,
                man_rec.car_car_adr4
           FROM uncartab
          WHERE car_cod = p_transbordoempresa AND lst_ope = 'U';

         SELECT cmp_nam
           INTO man_rec.car_trsp_pla
           FROM unprptab
          WHERE cmp_cod = p_transbordomedio
            AND prp_nam = p_transbordoempresa
            AND lst_ope = 'U';

         man_rec.car_car_cod := p_transbordoempresa;
         man_rec.car_id_trp := UPPER (p_transbordomedio);
      END IF;

      SELECT COUNT (1), SUM (x.car_pkg_avl), SUM (x.car_wgt_avl),
             SUM (a.carbol_cont_nber)
        INTO v_totalbol, v_totalcantidad, v_totalpeso,
             v_totalcontenedor
        FROM car_bol_gen a, car_bol_ope x
       WHERE a.key_cuo = man_rec.key_cuo
         AND a.key_voy_nber = man_rec.key_voy_nber
         AND a.key_dep_date = man_rec.key_dep_date
         AND a.carbol_frt_prep LIKE v_destinocriterio
         AND a.carbol_nat_cod = '24'
         AND x.car_pkg_avl > 0
         AND x.car_wgt_avl > 0
         AND a.key_cuo = x.key_cuo
         AND a.key_voy_nber = x.key_voy_nber
         AND a.key_dep_date = x.key_dep_date
         AND a.key_bol_ref = x.key_bol_ref
         AND a.key_lin_nbr = x.key_lin_nbr
         AND x.car_ope_nbr =
                (SELECT MAX (y.car_ope_nbr)
                   FROM car_bol_ope y
                  WHERE x.key_cuo = y.key_cuo
                    AND x.key_voy_nber = y.key_voy_nber
                    AND x.key_dep_date = y.key_dep_date
                    AND x.key_bol_ref = y.key_bol_ref
                    AND x.key_lin_nbr = y.key_lin_nbr);

      IF v_totalbol = 0
      THEN
         raise_application_error (man_noexiste_bol_acancelar,
                                  man_noexiste_bol_acancelar_msg
                                 );
      END IF;

      man_rec.car_arr_date := TO_DATE (p_fechadestino, 'dd/mm/yyyy');
      man_rec.car_arr_time := p_horadestino;
      p_manifiestoreferencia :=
                  'GRM' || man_rec.car_reg_year || '-' || man_rec.car_reg_nber;

      IF    p_destinoregimen = regimen_importacion
         OR p_destinoregimen = regimen_transbordo
      THEN
         p_manifiestoreferencia :=
               p_manifiestoreferencia
            || obtienesecuencia (p_destinoaduana,
                                 p_manifiestoreferencia,
                                 man_rec.key_dep_date
                                );
      END IF;
      /*PARA TRANSBORDO A FERREO */
      man_rec.car_mot_cod := 2;
      /*PARA TRANSBORDO A FERREO */
      memorizarmanifiestotransbordo (man_rec,
                           p_destinoaduana,
                           p_manifiestoreferencia,
                           v_destinocriterio,
                           v_destinoregimen,
                           v_totalbol,
                           v_totalcantidad,
                           v_totalpeso,
                           v_totalcontenedor,
                           p_usuario
                          );
      registrarmanifiesto (p_destinoaduana,
                           p_manifiestoreferencia,
                           man_rec.key_dep_date,
                           p_usuario,
                           p_manifiestoregistro
                          );
      descargarbol (p_destinoregimen,
                    man_rec.key_cuo,
                    man_rec.key_voy_nber,
                    man_rec.key_dep_date,
                    p_destinoaduana,
                    v_destinocriterio,
                    p_manifiestoregistro,
                    p_usuario
                   );
   END;




END pkg_manifiesto;
/

