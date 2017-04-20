CREATE OR REPLACE 
PACKAGE pkg_wservices_albo
  IS
  TYPE cursortype IS REF CURSOR;
FUNCTION consulta_micdta (p_fecha IN varchar2, p_usuario IN VARCHAR2)
      RETURN cursortype;

FUNCTION graba_peso (p_aduana       IN     VARCHAR2,
                       p_anio      IN     VARCHAR2,
                       p_registro  IN     VARCHAR2,
                       p_peso      IN     NUMBER,
                       p_usuario   IN     VARCHAR2,
                       p_fechadif  IN     VARCHAR2,
                       p_horadif   IN     VARCHAR2
                       )
     RETURN varchar2;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_wservices_albo
IS
   FUNCTION consulta_micdta (p_fecha IN VARCHAR2, p_usuario IN VARCHAR2)
      RETURN cursortype
   IS
      cd   cursortype;
   --fecha    DATE;
   BEGIN
      OPEN cd FOR
         SELECT g.key_cuo aduanaOrigen,
                g.key_cuo || ' ' || g.car_reg_year || ' ' || g.car_reg_nber
                   registroManifiesto,
                nvl((select distinct to_char(a.tra_fec_ini,'dd/mm/yyyy HH24:mi:ss')
                   from transitos.tra_pla_rut a
                  where a.key_cuo = g.key_cuo
                    AND a.car_reg_year = g.car_reg_year
                    AND a.car_reg_nber = g.car_reg_nber
                    AND a.tra_num = 0
                    AND a.lst_ope = 'U'
                    AND a.key_secuencia > 0
                    and nvl(a.tra_cuo_des,a.tra_cuo_est)= b.carbol_frt_prep
                    ),' ') fechainicio,
                g.car_id_trp numeroPlaca,
                g.car_car_cod identificacionEmpresa,
                g.car_car_nam nombreEmpresa,
                g.car_pac_nber totalBultos,
                g.car_reg_date fechaRegistro,
                g.car_reg_time horaRegistro,
                g.car_gros_mass pesoBrutoTotal,
                b.key_bol_ref docEmbarque,
                b.key_lin_nbr||'/'||b.carbol_sline_nber nroitem,
                c.cuo_cod aduanaDestino,
                c.cuo_nam descripcionAduana,
                b.carbol_gros_mas pesoBruto,
                b.carbol_pack_nber cantidadBultos,
                b.carbol_pack_cod tipoBultos,
                   NVL (b.carbol_seal_mrks1, '-')
                || ' '
                || NVL (b.carbol_seal_mrks2, '-')
                || '/'
                || decode(INSTR(b.carbol_shp_mark5,'&',1),0, b.carbol_shp_mark5, null) marcabultos,
                NVL (b.carbol_cons_cod, '-') identificacionConsignatario,
                NVL (b.carbol_cons_nam, '-') nombreConsignatario,
                   /*NVL (d.car_ctn_ident, '-')
                || ' '
                || NVL (d.car_ctn_typ, '-')
                || ' '
                || NVL (d.car_ctn_full, '-')
                   marcaBultos,*/
                   NVL (b.carbol_good1, ' ')
                || '.'
                || NVL (b.carbol_good2, ' ')
                || '.'
                || NVL (b.carbol_good3, ' ')
                || '.'
                || NVL (b.carbol_good4, ' ')
                || '.'
                || NVL (b.carbol_good5, ' ')
                   descripcionMercancia,
                b.carbol_infos1||'-'||b.carbol_infos2 doc_anexos,
                ctn.car_ctn_nbr nrocontenedor,
                nvl(ctn.car_ctn_ident,'-') precintocont,
                nvl(ctn.car_ctn_typ,'-') clasificacion
           FROM car_gen g, car_bol_gen b, uncuotab c, car_bol_ctn ctn
          WHERE     g.key_cuo = b.key_cuo
                AND g.key_voy_nber = b.key_voy_nber
                AND g.key_dep_date = b.key_dep_date
                AND b.carbol_frt_prep = c.cuo_cod

                and b.key_cuo = ctn.key_cuo(+)
                and b.key_voy_nber = ctn.key_voy_nber(+)
                and b.key_dep_date = ctn.key_dep_date(+)
                and b.key_bol_ref = ctn.key_bol_ref(+)
                and b.key_lin_nbr = ctn.key_lin_nbr(+)
                AND c.lst_ope = 'U'
                AND (SELECT COUNT (*)
                       FROM t_modpeso m
                      WHERE     g.key_cuo = m.key_cuo
                            AND g.car_reg_year = m.car_reg_year
                            AND g.car_reg_nber = m.car_reg_nber
                            AND m.mod_lst_ope = 'U'
                            AND m.mod_num = 0) = 0
                AND g.car_reg_date = TO_DATE (p_fecha, 'dd/mm/yyyy')
                AND g.key_cuo = '072';

      RETURN cd;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         OPEN cd FOR
            SELECT 'NO EXISTEN MANIFIESTOS EN LA FECHA INDICADA'
              FROM DUAL
             WHERE 1 = 1;

         RETURN cd;
      WHEN OTHERS
      THEN
         OPEN cd FOR
            SELECT 'ERROR DESCONOCIDO'
              FROM DUAL
             WHERE 1 = 0;

         RETURN cd;
   END consulta_micdta;

   FUNCTION graba_peso (p_aduana     IN VARCHAR2,
                        p_anio       IN VARCHAR2,
                        p_registro   IN VARCHAR2,
                        p_peso       IN NUMBER,
                        p_usuario    IN VARCHAR2,
                        p_fechadif   IN VARCHAR2,
                        p_horadif    IN VARCHAR2)
      RETURN VARCHAR2
   IS
      correl        NUMBER;
      hay           NUMBER;
      s_fechadif    DATE;
      s_horadif     VARCHAR2 (8);
      f_paso_peso   VARCHAR2 (200);
      fecha_peso    VARCHAR2 (100);
   BEGIN
      IF p_fechadif = '-1'
      THEN
         s_fechadif := TRUNC (SYSDATE);
         s_horadif := TO_CHAR (SYSDATE, 'HH24:mi:ss');
      ELSE
         s_fechadif := TO_DATE (p_fechadif, 'dd/mm/yyyy');
         s_horadif := p_horadif;
      END IF;

      IF p_aduana <> '072'
      THEN
         RETURN 'Error, el codigo de aduana no corresponde a Arica.';
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM car_gen
       WHERE     key_cuo = p_aduana
             AND car_reg_year = p_anio
             AND car_reg_nber = p_registro;

      IF hay = 0
      THEN
         RETURN 'Error, el manifiesto no existe.';
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM tra_pla_rut
       WHERE     key_cuo = p_aduana
             AND car_reg_year = p_anio
             AND car_reg_nber = p_registro
             AND key_secuencia > 0
             AND tra_num = 0
             AND lst_ope = 'U'
             AND tra_loc = 0;

      IF hay = 0
      THEN
         RETURN 'Error, el manifiesto no esta registrado en Transitos.';
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM tra_pla_rut
       WHERE     key_cuo = p_aduana
             AND car_reg_year = p_anio
             AND car_reg_nber = p_registro
             AND key_secuencia = 1
             AND tra_num = 0
             AND lst_ope = 'U'
             AND s_fechadif BETWEEN TRUNC (tra_fec_ini) AND TRUNC (SYSDATE);

      IF hay = 0
      THEN
         RETURN 'Error, la fecha debe estar entre la fecha de inicio de transito y hoy.';
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM t_modpeso a
       WHERE     a.key_cuo = p_aduana
             AND a.car_reg_year = p_anio
             AND a.car_reg_nber = p_registro
             AND a.mod_num = 0
             AND a.mod_lst_ope = 'U';


      IF hay > 0
      THEN
         RETURN 'Error, el peso bruto del manifiesto ya fue registrado.';
      ELSE
         fecha_peso := TO_CHAR (s_fechadif, 'dd/mm/yyyy') || ' ' || s_horadif;
         f_paso_peso :=
            pkg_transito.registro_paso_peso (p_aduana,
                                             p_anio,
                                             p_registro,
                                             fecha_peso,
                                             '422',
                                             p_usuario);

         IF f_paso_peso != 'correcto'
         THEN
            RETURN 'Error, No es posible registrar peso.';
         ELSE

/*            f_paso_peso :=
               PKG_DESPACHO.VALIDA_TRANSITOS (p_anio, p_aduana, p_registro);
            IF (f_paso_peso != 'correcto')
            THEN
               RETURN f_paso_peso;
            ELSE*/
               INSERT INTO t_modpeso
                    VALUES (p_aduana,
                            p_anio,
                            p_registro,
                            p_peso,
                            p_usuario,
                            SYSDATE,
                            'U',
                            0,
                            s_fechadif,
                            s_horadif);

               COMMIT;
               RETURN 'ok';
--            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE || '-' || SQLERRM;
         ROLLBACK;
   END;
END;
/

