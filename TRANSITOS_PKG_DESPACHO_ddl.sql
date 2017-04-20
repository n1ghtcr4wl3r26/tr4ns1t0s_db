CREATE OR REPLACE 
PACKAGE           pkg_despacho AS
   TYPE CURSORTYPE IS REF CURSOR;

   FUNCTION LISTA_ADUANAS (USUARIO IN VARCHAR2)
      RETURN CURSORTYPE;

   FUNCTION CONSULTA_DESPACHO (OPCION     IN     NUMBER,
                               GESTION    IN     VARCHAR2,
                               ADUANA     IN     VARCHAR2,
                               REGISTRO   IN     NUMBER,
                               USUARIO    IN     VARCHAR2,
                               ANS           OUT VARCHAR2)
      RETURN CURSORTYPE;

   FUNCTION REGISTRA_DESPACHO (                                                                                                                           -- datos de la declaracion
                               SD_GESTION    IN     SAD_GEN.SAD_REG_YEAR%TYPE,
                               SD_ADUANA     IN     SAD_GEN.KEY_CUO%TYPE,
                               ND_REGISTRO   IN     SAD_GEN.SAD_REG_NBER%TYPE,
                               -- datos del manifiesto
                               SM_GESTION    IN     CAR_GEN.CAR_REG_YEAR%TYPE,
                               SM_ADUANA     IN     CAR_GEN.KEY_CUO%TYPE,
                               NM_REGISTRO   IN     CAR_GEN.CAR_REG_NBER%TYPE,
                               -- dato de la aduana de conexion
                               SO_ADUANA     IN     CAR_GEN.KEY_CUO%TYPE,
                               SO_USUARIO    IN     TRA_PLA_RUT.USR_NAM%TYPE,
                               MANIFIESTO       OUT VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION IMPRIME_PARTE (SM_ADUANA IN CAR_GEN.KEY_CUO%TYPE, SM_GESTION IN CAR_GEN.CAR_REG_YEAR%TYPE, NM_REGISTRO IN CAR_GEN.CAR_REG_NBER%TYPE)
      RETURN CURSORTYPE;

      FUNCTION imprime_parte_sec (sm_aduana     IN car_gen.key_cuo%TYPE,
                            sm_gestion    IN car_gen.car_reg_year%TYPE,
                            nm_registro   IN car_gen.car_reg_nber%TYPE,
                            sm_secuencia  IN varchar2
                            )
        RETURN cursortype;

   FUNCTION DUI_PARTE_RECEP (S_CUO    IN VARCHAR2,
                             S_YEAR   IN VARCHAR2,
                             S_NBER   IN NUMBER,
                             S_REF    IN VARCHAR2)
      RETURN CURSORTYPE;

   FUNCTION detalle_cierre_docemb (s_cuo    IN VARCHAR2,
                              s_year   IN VARCHAR2,
                              s_nber   IN NUMBER,
                              s_ref    IN VARCHAR2)
        RETURN cursortype;

    FUNCTION transitos_con_parte (  prm_cuoini     IN VARCHAR2,
                                 prm_cuofin     IN VARCHAR2,
                                 prm_fecini     IN VARCHAR2,
                                 prm_fecfin     IN VARCHAR2
                              )
        RETURN cursortype;

   FUNCTION VALIDA_TRANSITOS (SM_GESTION IN CAR_GEN.CAR_REG_YEAR%TYPE, SM_ADUANA IN CAR_GEN.KEY_CUO%TYPE, NM_REGISTRO IN CAR_GEN.CAR_REG_NBER%TYPE)
      RETURN VARCHAR2;
END PKG_DESPACHO;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_despacho
AS
    op_consulta_por_dui          CONSTANT PLS_INTEGER := 1001;
    op_consulta_por_manifiesto   CONSTANT PLS_INTEGER := 1002;
    op_registro_manifiesto       CONSTANT PLS_INTEGER := 1011;

    FUNCTION lista_aduanas (usuario IN VARCHAR2)
        RETURN cursortype
    IS
        ct       cursortype;
        hay      DECIMAL (3, 0);
        aduana   VARCHAR2 (30) := usuario;
        adu1     VARCHAR2 (5);
        adu2     VARCHAR2 (5);
        adu3     VARCHAR2 (5);
        adu4     VARCHAR2 (5);
        adu5     VARCHAR2 (30);
    BEGIN
        IF (usuario = 'ALL')
        THEN
            OPEN ct FOR
                  SELECT   cuo_cod, cuo_nam, 1
                    FROM   ops$asy.uncuotab a
                   WHERE   NOT cuo_cod IN ('ALL', 'CUO01') AND lst_ope = 'U'
                ORDER BY   1;
        ELSE
            hay := INSTR (aduana, '-');

            IF (hay > 0)
            THEN
                adu1 := SUBSTR (aduana, 0, hay - 1);
                aduana := SUBSTR (aduana, hay + 1);
                hay := INSTR (aduana, '-');

                IF (hay > 0)
                THEN
                    adu2 := SUBSTR (aduana, 0, hay - 1);
                    aduana := SUBSTR (aduana, hay + 1);
                    hay := INSTR (aduana, '-');

                    IF (hay > 0)
                    THEN
                        adu3 := SUBSTR (aduana, 0, hay - 1);
                        aduana := SUBSTR (aduana, hay + 1);
                        hay := INSTR (aduana, '-');

                        IF (hay > 0)
                        THEN
                            adu4 := SUBSTR (aduana, 0, hay - 1);
                            aduana := SUBSTR (aduana, hay + 1);
                            hay := INSTR (aduana, '-');
                        END IF;
                    END IF;
                END IF;
            END IF;

            adu5 := aduana;

            OPEN ct FOR
                  SELECT   a.cuo_cod,
                           a.cuo_nam,
                           CASE
                               WHEN INSTR (cuo_cod, adu1) > 0 THEN 1
                               WHEN INSTR (cuo_cod, adu2) > 0 THEN 1
                               WHEN INSTR (cuo_cod, adu3) > 0 THEN 1
                               WHEN INSTR (cuo_cod, adu4) > 0 THEN 1
                               WHEN INSTR (cuo_cod, adu5) > 0 THEN 1
                               ELSE 0
                           END
                               si
                    FROM   ops$asy.uncuotab a
                   WHERE   NOT cuo_cod IN ('ALL', 'CUO01') AND a.lst_ope = 'U'
                ORDER BY   1;
        END IF;

        RETURN ct;
    END lista_aduanas;

    PROCEDURE inserta_por_manifiesto (gestion    IN VARCHAR2,
                                      aduana     IN VARCHAR2,
                                      registro   IN NUMBER,
                                      usuario    IN VARCHAR2)
    IS
        CURSOR man
        IS
            SELECT   b.key_cuo,
                     b.key_voy_nber,
                     b.key_dep_date,                        --, B.KEY_BOL_REF,
                     NVL (b.carbol_shp_mark5, '-') AS carbol_shp_mark5
              FROM   car_gen a, car_bol_gen b
             WHERE       a.key_cuo = b.key_cuo
                     AND a.key_voy_nber = b.key_voy_nber
                     AND a.key_dep_date = b.key_dep_date
                     AND a.key_cuo = aduana
                     AND car_reg_year = gestion
                     AND car_reg_nber = registro;

        cantidad   PLS_INTEGER;
    BEGIN
        FOR m1 IN man
        LOOP
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   ops$asy.dec_man
             WHERE       declaracion = m1.carbol_shp_mark5
                     AND key_cuo = m1.key_cuo
                     AND key_voy_nber = m1.key_voy_nber
                     AND key_dep_date = m1.key_dep_date
                     --AND KEY_BOL_REF = M1.KEY_BOL_REF
                     AND sad_num = 0;

            IF (cantidad = 0)
            THEN
                IF (ops$asy.sidunea.grabar_transito (
                        m1.key_cuo,
                        m1.key_voy_nber,
                        TO_CHAR (m1.key_dep_date, 'yyyymmdd'),
                        '-',                                 --M1.KEY_BOL_REF,
                        usuario) != 0)
                THEN
                    RAISE NO_DATA_FOUND;
                END IF;
            END IF;
        END LOOP;
    END;


    PROCEDURE inserta_por_dui (dui IN VARCHAR2, usuario IN VARCHAR2)
    IS
        CURSOR dec
        IS
            SELECT   key_cuo, car_reg_year, car_reg_nber
              FROM   car_gen
             WHERE   (key_cuo, key_voy_nber, key_dep_date) IN
                             (SELECT   b.key_cuo,
                                       b.key_voy_nber,
                                       b.key_dep_date
                                FROM   ops$asy.dec_man a, car_bol_gen b
                               WHERE       declaracion LIKE dui
                                       AND a.key_cuo = b.key_cuo
                                       AND a.key_voy_nber = b.key_voy_nber
                                       AND a.key_dep_date = b.key_dep_date
                                       AND a.sad_num = 0);
    BEGIN
        FOR d1 IN dec
        LOOP
            inserta_por_manifiesto (d1.car_reg_year,
                                    d1.key_cuo,
                                    d1.car_reg_nber,
                                    usuario);
        END LOOP;
    --CLOSE DEC;
    END;

    FUNCTION consulta_despacho (opcion     IN     NUMBER,
                                gestion    IN     VARCHAR2,
                                aduana     IN     VARCHAR2,
                                registro   IN     NUMBER,
                                usuario    IN     VARCHAR2,
                                ans           OUT VARCHAR2)
        RETURN cursortype
    IS
        ct            cursortype;

        -- datos de la dui
        sd_gestion    sad_gen.sad_reg_year%TYPE;
        sd_aduana     sad_gen.key_cuo%TYPE;
        nd_registro   sad_gen.sad_reg_nber%TYPE;

        canal         sad_spy.sad_clr%TYPE;
        importador    VARCHAR2 (100);
        peso          NUMBER (12, 2);
        -- datos del manifiesto
        sm_aduana     car_gen.key_cuo%TYPE;
        sm_gestion    car_gen.car_reg_year%TYPE;
        nm_registro   car_gen.car_reg_nber%TYPE;

        skey_voy      car_bol_gen.key_voy_nber%TYPE;
        skey_dep      VARCHAR2 (10);
        scar_bol      car_bol_gen.key_bol_ref%TYPE;

        -- variable auxiliar
        existe                     PLS_INTEGER;
        dui                        VARCHAR2 (30);
        paso                       PLS_INTEGER := 0;

        -- variable para verificar si necesita salida de puerta
        var_spuerto                NUMBER (8, 0) := 2;
        var_valida_salida_puerto   NUMBER (8, 0) := 0;
    BEGIN
        IF (opcion = op_consulta_por_dui)
        THEN
            paso := 9;
            sd_gestion := gestion;
            sd_aduana := aduana;
            nd_registro := registro;

            -- VERIFICACION DE QUE LA ADUANA DEL MANIFIESTO SEA 071, 072 EDGAR 12062014
            SELECT   COUNT (1)
              INTO   var_spuerto
              FROM   ops$asy.dec_man d
             WHERE   d.declaracion LIKE
                            sd_gestion
                         || '&'
                         || sd_aduana
                         || '&C&'
                         || nd_registro
                         || '&'
                         || '%'
                     AND ROWNUM = 1
                     AND SUBSTR (key_cuo, 0, 1) = 0
                     AND d.sad_num = 0;

            BEGIN
                inserta_por_dui (
                    gestion || '&' || aduana || '&C&' || registro || '&%',
                    usuario);
                COMMIT;
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK;
            END;
        ELSIF (opcion = op_consulta_por_manifiesto)
        THEN
            paso := 10;

            BEGIN

                -- VERIFICACION DE QUE LA ADUANA DEL MANIFIESTO SEA 071, 072 EDGAR 12062014
                SELECT   DECODE(SUBSTR (aduana, 0, 1),0,1,0)
                INTO   var_spuerto
                FROM   dual;

                inserta_por_manifiesto (gestion,
                                        aduana,
                                        registro,
                                        usuario);
                COMMIT;
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK;
            END;

            paso := 11;

            SELECT   SUBSTR (declaracion, 0, 4),
                     SUBSTR (declaracion, 6, 3),
                     SUBSTR (declaracion, 12, LENGTH (declaracion) - 12 - 8)
              INTO   sd_gestion, sd_aduana, nd_registro
              FROM   car_gen a, ops$asy.dec_man b, car_bol_gen c
             WHERE       a.key_cuo = aduana
                     AND a.car_reg_year = gestion
                     AND a.car_reg_nber = registro
                     AND a.key_cuo = b.key_cuo
                     AND a.key_voy_nber = b.key_voy_nber
                     AND a.key_dep_date = b.key_dep_date
                     AND a.key_cuo = c.key_cuo
                     AND a.key_voy_nber = c.key_voy_nber
                     AND a.key_dep_date = c.key_dep_date
                     AND c.carbol_shp_mark5 = b.declaracion
                     AND b.sad_num = 0;
        ELSE
            ans := 'Operacion Invalida';
            RETURN ct;
        END IF;

        paso := 1;

          SELECT   sad_clr,
                   REPLACE (sad_consignee || ': ' || cmp_nam, '&', ' ')
                       AS importador,
                   SUM (saditm_gross_mass)
            INTO   canal, importador, peso
            FROM   sad_gen a,
                   sad_spy b,
                   sad_itm c,
                   uncmptab d
           WHERE       a.key_cuo = sd_aduana
                   AND a.sad_reg_year = sd_gestion
                   AND a.sad_reg_serial = 'C'
                   AND a.sad_reg_nber = nd_registro
                   AND a.sad_num = 0
                   AND a.lst_ope = 'U'
                   AND a.sad_typ_dec = 'IMA'
                   AND a.key_year = b.key_year
                   AND a.key_cuo = b.key_cuo
                   AND NVL (a.key_dec, '-') = NVL (b.key_dec, '-')
                   AND a.key_nber = c.key_nber
                   AND a.key_year = c.key_year
                   AND a.key_cuo = c.key_cuo
                   AND NVL (a.key_dec, '-') = NVL (c.key_dec, '-')
                   AND a.key_nber = b.key_nber
                   AND spy_act = '24'
                   AND c.sad_num = 0
                   AND a.sad_consignee = d.cmp_cod(+)
                   AND d.lst_ope = 'U'
        GROUP BY   sad_clr, sad_consignee || ': ' || cmp_nam;

        IF (canal = '2')
        THEN
            ans :=
                'La DUI tiene canal Amarillo y no puede continuar con el Despacho anticipado.';
            RETURN ct;
        ELSIF (canal = '3')
        THEN
            ans :=
                'La DUI tiene canal Rojo y no puede continuar con el Despacho anticipado.';
            RETURN ct;
        ELSIF (canal <> '0')
        THEN
            ans :=
                'La DUI no tiene canal  y no puede continuar con el Despacho anticipado.';
            RETURN ct;
        END IF;
/*
        var_valida_salida_puerto :=
            tiene_salida_puerto_dui (sd_aduana, sd_gestion, nd_registro);

        IF (var_valida_salida_puerto = 0)
        THEN
            ans :=
                'El manifiesto asociado a la DUI no tiene registro de Salida de Puerto y no puede continuar con el Despacho anticipado.';
            RETURN ct;
        END IF;*/

        dui := sd_gestion || '&' || sd_aduana || '&C&' || nd_registro || '&';

        OPEN ct FOR
              SELECT   sd_gestion || '/' || sd_aduana || '/C-' || nd_registro
                           AS dui,
                       carbol_frt_prep || ': ' || c.cuo_nam AS destino,
                       car_mot_cod || ': ' || e.mot_dsc AS forma,
                       carbol_nat_cod || ': '
                       || CASE
                              WHEN carbol_nat_cod = '24' THEN 'Transito'
                              ELSE 'Importacion'
                          END
                           tipo,
                       a.key_cuo,
                       a.car_reg_year,
                       a.car_reg_nber,
                       REPLACE (a.car_car_cod || ': ' || a.car_car_nam,
                                '&',
                                '/')
                           AS empresa,
                       a.car_id_trp AS placa,
                       estado,
                       peso AS duipeso,
                       importador AS duiimportador,
                       b.carbol_gros_mas AS peso,
                       REPLACE (b.carbol_cons_cod || ': ' || b.carbol_cons_nam,
                                '&',
                                '/')
                           AS importador
                FROM   car_gen a,
                       car_bol_gen b,
                       uncuotab c,
                       ops$asy.dec_man d,
                       unmottab e
               WHERE       d.declaracion LIKE dui || '%'
                       AND SUBSTR (b.carbol_shp_mark5, 0, LENGTH (dui)) = dui
                       AND a.key_cuo = d.key_cuo
                       AND a.key_voy_nber = d.key_voy_nber
                       AND a.key_dep_date = d.key_dep_date
                       AND b.key_bol_ref = d.key_bol_ref
                       AND a.key_cuo = b.key_cuo
                       AND a.key_voy_nber = b.key_voy_nber
                       AND a.key_dep_date = b.key_dep_date
                       AND b.carbol_nat_cod IN ('23', '24')
                       AND NVL (b.carbol_frt_prep, a.key_cuo) = sd_aduana
                       AND e.mot_cod = a.car_mot_cod
                       AND e.lst_ope = 'U'
                       AND c.cuo_cod = NVL (b.carbol_frt_prep, a.key_cuo)
                       AND c.lst_ope = 'U'
                       AND d.sad_num = 0
                       --AND A.CAR_MOT_COD IN ('3', '2')
                       AND NOT b.key_bol_ref IN
                                       (SELECT   key_bol_ref
                                          FROM   ops$asy.car_spy
                                         WHERE   key_cuo = b.key_cuo
                                                 AND key_voy_nber =
                                                        b.key_voy_nber
                                                 AND key_dep_date =
                                                        b.key_dep_date
                                                 AND spy_act = 15)
            ORDER BY   estado;

        ans := 'correcto';

        RETURN ct;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            IF (paso = 0 OR paso = -1 OR paso = -2)
            THEN
                ans :=
                       'Verifique que:'
                    || CHR (13)
                    || '- El Manifiesto sea el correcto.'
                    || CHR (13)
                    || '- El D/E este relacionada a la DUI.';
            ELSIF (paso = 1)
            THEN
                ans :=
                       'Verifique que:'
                    || CHR (13)
                    || '- La DUI sea la correcta.'
                    || CHR (13)
                    || '- La DUI tenga canal VERDE.'
                    || CHR (13)
                    || '- El D/E este relacionada a la DUI en origen.'
                    || CHR (13)
                    || '- El consignatario es diferente al de la DUI.';

                IF (opcion = 1001)
                THEN
                    IF (var_spuerto = 1)
                    THEN
                        ans :=
                            ans || CHR (13)
                            || '- El transito tenga el Registro de Salida de Puerto.';
                    END IF;
                END IF;

                IF (opcion = 1002)
                THEN
                    IF (SUBSTR (aduana, 0, 1) = 0)
                    THEN
                        ans :=
                            ans || CHR (13)
                            || '- El transito tenga el Registro de Salida de Puerto.';
                    END IF;
                END IF;
            ELSE
                ans := 'No se puede registrar el D/E.';
            END IF;

            OPEN ct FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN ct;
        WHEN TOO_MANY_ROWS
        THEN
            OPEN ct FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            ans :=
                'El Manifiesto tiene mas de un D/E y esta asociada a mas de una DUI, tiene que ingresar por Declaracion Unica de Importacion.';
            RETURN ct;
        WHEN OTHERS
        THEN
            ans := SQLERRM;

            OPEN ct FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN ct;
    END;

    FUNCTION verifica_transito (sm_gestion    IN car_gen.car_reg_year%TYPE,
                                sm_aduana     IN car_gen.key_cuo%TYPE,
                                nm_registro   IN car_gen.car_reg_nber%TYPE)
        RETURN NUMBER
    IS
        sdestino   car_bol_gen.carbol_frt_prep%TYPE;
        tipo       tra_pla_rut.tra_tipo%TYPE;
        existe     PLS_INTEGER;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_pla_rut
         WHERE       key_cuo = sm_aduana
                 AND car_reg_year = sm_gestion
                 AND car_reg_nber = nm_registro;

        IF (existe = 0)
        THEN
            -- no esta registrado el transito
            RETURN 1;
        END IF;

        SELECT   tra_cuo_des, tra_tipo
          INTO   sdestino, tipo
          FROM   tra_pla_rut
         WHERE       key_cuo = sm_aduana
                 AND car_reg_year = sm_gestion
                 AND car_reg_nber = nm_registro
                 AND key_secuencia > 0
                 AND tra_num = 0
                 AND lst_ope = 'U';

        IF (NOT sdestino IS NULL)
        THEN
            IF (tipo != 31)
            THEN
                -- transito cerrado normal mente
                RETURN -1;
            ELSIF (tipo = 31)
            THEN
                --transito cerrado como despacho anticipado
                RETURN -2;
            ELSE
                RETURN -3;
            END IF;
        END IF;

        RETURN 2;
    END;

    FUNCTION registra_despacho (                    -- datos de la declaracion
        sd_gestion    IN     sad_gen.sad_reg_year%TYPE,
        sd_aduana     IN     sad_gen.key_cuo%TYPE,
        nd_registro   IN     sad_gen.sad_reg_nber%TYPE,
        -- datos del manifiesto
        sm_gestion    IN     car_gen.car_reg_year%TYPE,
        sm_aduana     IN     car_gen.key_cuo%TYPE,
        nm_registro   IN     car_gen.car_reg_nber%TYPE,
        -- dato de la aduana de conexion
        so_aduana     IN     car_gen.key_cuo%TYPE,
        so_usuario    IN     tra_pla_rut.usr_nam%TYPE,
        manifiesto       OUT VARCHAR2)
        RETURN VARCHAR2
    IS
        ans                      VARCHAR2 (500);
        sm_destino               car_bol_gen.carbol_nat_cod%TYPE;
        dui VARCHAR2 (20)
                := sd_gestion || '&' || sd_aduana || '&C&' || nd_registro;
        canal                    sad_spy.sad_clr%TYPE;

        skey_cuo                 car_gen.key_cuo%TYPE;
        skey_voy                 car_gen.key_voy_nber%TYPE;
        skey_date                car_gen.key_dep_date%TYPE;

        -- para determinar el destino del manifiesto
        existe                   PLS_INTEGER;
        smodo                    car_gen.car_mot_cod%TYPE;

        plazo                    PLS_INTEGER;
        iplazo                   VARCHAR2 (5);
        p_manifiestoreferencia   VARCHAR2 (100);

        v_operacion              NUMBER := 0;
        v_bol_ser                NUMBER := 0;
        cantidad   DECIMAL (2, 0);


        ypfb                     car_bol_gen.carbol_cons_cod%TYPE;
    BEGIN
/*
        cantidad := tiene_salida_puerto (sm_aduana, sm_gestion, nm_registro);
        IF (cantidad = 0 AND SUBSTR (sm_aduana, 1, 1) = 0)
        THEN
            RETURN 'El manifiesto asociado a la DUI no tiene registro de Salida de Puerto.';
        END IF;
*/

        SELECT   sad_clr
          INTO   canal
          FROM   sad_gen a, sad_spy b
         WHERE       a.sad_num = 0
                 AND a.lst_ope = 'U'
                 AND a.sad_typ_dec = 'IMA'
                 AND a.key_year = b.key_year
                 AND a.key_cuo = b.key_cuo
                 AND NVL (a.key_dec, '-') = NVL (b.key_dec, '-')
                 AND a.key_nber = b.key_nber
                 AND b.spy_act = '24'
                 AND (a.key_cuo,
                      a.sad_reg_year,
                      a.sad_reg_serial,
                      a.sad_reg_nber) IN
                            (SELECT   SUBSTR (carbol_shp_mark5, 6, 3),
                                      SUBSTR (carbol_shp_mark5, 0, 4),
                                      'C',
                                      SUBSTR (
                                          carbol_shp_mark5,
                                          12,
                                          LENGTH (carbol_shp_mark5) - 12 - 8)
                               FROM   car_bol_gen b, car_gen a
                              WHERE       a.key_cuo = sm_aduana
                                      AND a.car_reg_year = sm_gestion
                                      AND a.car_reg_nber = nm_registro
                                      AND a.key_cuo = b.key_cuo
                                      AND a.key_voy_nber = b.key_voy_nber
                                      AND a.key_dep_date = b.key_dep_date
                                      AND b.carbol_shp_mark5 LIKE dui || '%');




        IF (canal != '0')
        THEN
            RETURN 'La DUI no tiene canal VERDE asignado.';
        END IF;


        SELECT count(1) into canal
            FROM tra_pla_rut a
            where a.key_cuo = sm_aduana and a.car_reg_year = sm_gestion and  a.car_reg_nber = nm_registro
                and a.lst_ope in ('M','U');

        IF (canal = '0' AND SUBSTR(sm_aduana,1,1) = '0')
        THEN
            RETURN 'El manifiesto no tiene Inicio de Transito.';
        END IF;

        SELECT   carbol_nat_cod,
                 car_mot_cod,
                 a.key_cuo,
                 a.key_voy_nber,
                 a.key_dep_date,
                 carbol_cons_cod
          INTO   sm_destino,
                 smodo,
                 skey_cuo,
                 skey_voy,
                 skey_date,
                 ypfb
          FROM   car_gen a, car_bol_gen b
         WHERE       a.key_cuo = sm_aduana
                 AND a.car_reg_year = sm_gestion
                 AND a.car_reg_nber = nm_registro
                 AND a.key_cuo = b.key_cuo
                 AND a.key_voy_nber = b.key_voy_nber
                 AND a.key_dep_date = b.key_dep_date
                 AND NVL (b.carbol_frt_prep, a.key_cuo) = sd_aduana
                 AND SUBSTR (b.carbol_shp_mark5, 0, LENGTH (dui)) = dui
                 AND b.carbol_nat_cod IN ('23', '24')
                 AND NOT b.key_bol_ref IN
                                 (SELECT   key_bol_ref
                                    FROM   ops$asy.car_spy
                                   WHERE       key_cuo = b.key_cuo
                                           AND key_voy_nber = b.key_voy_nber
                                           AND key_dep_date = b.key_dep_date
                                           AND spy_sta = 11);

        IF (sm_aduana != so_aduana)
        THEN
            IF (NOT ( (sm_aduana = '072' AND so_aduana = '422')
                    OR(sm_aduana = '072' AND so_aduana = '421' AND TRUNC(SYSDATE) >= TO_DATE('01/04/2017') AND TRUNC(SYSDATE) <= TO_DATE('09/10/2017') )
                    OR (sm_aduana = '072' AND so_aduana = '301')
                    OR (sm_aduana = '071' AND so_aduana = '241')))
            THEN
                RETURN 'Incompatibilidad de Aduana: Aduana de Registro Manifiesto -> '
                       || sm_aduana
                       || ' y aduana de Conexion -> '
                       || so_aduana;
            END IF;
        END IF;

        IF (NOT ( (sm_aduana = sd_aduana AND sm_destino = '23')
                 OR (sm_aduana != sd_aduana AND sm_destino = '24')))
        THEN
            RETURN    'Incompatibilidad de Tipo operacion: Aduana de DUI -> '
                   || sd_aduana
                   || ' y aduana Registro Manifiesto -> '
                   || sm_destino;
        END IF;

        UPDATE   ops$asy.dec_man
           SET   estado = 1
         WHERE   declaracion LIKE
                        sd_gestion
                     || '&'
                     || sd_aduana
                     || '&C&'
                     || nd_registro
                     || '%'
                 AND key_cuo = skey_cuo
                 AND key_voy_nber = skey_voy
                 AND key_dep_date = skey_date
                 AND sad_num = 0;

        IF (ypfb IN
                    ('1020269020',
                     '1028349027',
                     '1028359026',
                     '1028255024',
                     '1015481021',
                     '150250021'))
        THEN
            UPDATE   ops$asy.dec_man
               SET   estado = 1
             WHERE       key_cuo = skey_cuo
                     AND key_voy_nber = skey_voy
                     AND key_dep_date = skey_date
                     AND sad_num = 0;
        END IF;

        -- begin varificar con patricia ---
        SELECT   COUNT (1)
          INTO   existe
          FROM   (SELECT   DISTINCT carbol_frt_prep
                    FROM   car_bol_gen a, car_gen b
                   WHERE       b.car_reg_year = sm_gestion
                           AND b.car_reg_nber = nm_registro
                           AND a.key_cuo = b.key_cuo
                           AND a.key_voy_nber = b.key_voy_nber
                           AND a.key_dep_date = b.key_dep_date);


        IF (existe > 1)
        THEN
            RAISE ZERO_DIVIDE;
        END IF;

        -- end varificar con patricia ---
        IF (sm_destino = '24')
        THEN
            existe := verifica_transito (sm_gestion, sm_aduana, nm_registro);

            IF (existe = -1)
            THEN
                RETURN 'Se concluyo anteriormente el Transito <Normal>.';
            ELSIF (existe = -2)
            THEN
                RETURN 'Se concluyo anteriormente el Transito <Despacho Anticipado>.';
            ELSIF (existe = -3)
            THEN
                RETURN 'Error antes de efectuar registro del Despacho anticipado.';
            ELSIF (existe = 1)
            THEN
                -- inciamos y cerramos el transito
                IF (smodo = 9)
                THEN
                    SELECT   rou_ter, rou_cod
                      INTO   plazo, iplazo
                      FROM   unroutab
                     WHERE       cuo_sal IN (sm_aduana, sd_aduana)
                             AND cuo_arr IN (sm_aduana, sd_aduana)
                             AND rou_mod = 3
                             AND lst_ope = 'U'
                             AND numver = 0;
                ELSE
                    SELECT   rou_ter, rou_cod
                      INTO   plazo, iplazo
                      FROM   unroutab
                     WHERE       cuo_sal IN (sm_aduana, sd_aduana)
                             AND cuo_arr IN (sm_aduana, sd_aduana)
                             AND rou_mod = smodo
                             AND lst_ope = 'U'
                             AND numver = 0;
                END IF;

                INSERT INTO tra_pla_rut (key_cuo,
                                         car_reg_year,
                                         car_reg_nber,
                                         key_secuencia,
                                         tra_cuo_ini,
                                         tra_fec_ini,
                                         tra_cuo_est,
                                         tra_fec_est,
                                         tra_plazo,
                                         tra_ruta,
                                         tra_cuo_des,
                                         tra_fec_des,
                                         tra_tipo,
                                         tra_obs,
                                         tra_loc,
                                         tra_estado,
                                         lst_ope,
                                         tra_num,
                                         usr_nam,
                                         usr_fec)
                  VALUES   (sm_aduana,
                            sm_gestion,
                            nm_registro,
                            1,
                            sm_aduana,
                            SYSDATE,
                            sd_aduana,
                            SYSDATE,
                            plazo,
                            iplazo,
                            so_aduana,
                            SYSDATE,
                            31,
                            'REGISTRO DESPACHO ANTICIPADO - DUI ' || dui,
                            1,
                            0,
                            'U',
                            0,
                            so_usuario,
                            SYSDATE);

               --Para registrar la placa del medio de transporte EJAG 16/11/2015
               placa_cierre(sm_aduana,sm_gestion,nm_registro,0,'0','CIERRE');

            ELSIF (existe = 2)
            THEN
                --cerramos el transito (transito registrado anteriormente)

                SELECT   MAX (tra_num)
                  INTO   existe
                  FROM   tra_pla_rut
                 WHERE       key_cuo = sm_aduana
                         AND car_reg_year = sm_gestion
                         AND car_reg_nber = nm_registro;

                INSERT INTO tra_pla_rut
                    SELECT   key_cuo,
                             car_reg_year,
                             car_reg_nber,
                             key_secuencia,
                             tra_cuo_ini,
                             tra_fec_ini,
                             tra_cuo_est,
                             tra_fec_est,
                             tra_pre,
                             tra_plazo,
                             tra_ruta,
                             tra_cuo_des,
                             tra_fec_des,
                             tra_tipo,
                             tra_obs,
                             act_boleta,
                             act_entidad,
                             act_fec_ini,
                             act_fec_fin,
                             act_monto,
                             act_moneda,
                             tra_loc,
                             tra_estado,
                             lst_ope,
                             existe + 1,
                             usr_nam,
                             usr_fec
                      FROM   tra_pla_rut
                     WHERE       key_cuo = sm_aduana
                             AND car_reg_year = sm_gestion
                             AND car_reg_nber = nm_registro
                             AND key_secuencia = 1
                             AND tra_num = 0;

                UPDATE   tra_pla_rut
                   SET   tra_cuo_des = so_aduana,
                         tra_fec_des = SYSDATE,
                         tra_obs =
                             'REGISTRO DESPACHO ANTICIPADO - DUI ' || dui,
                         tra_estado = 0,
                         tra_loc = 1,
                         tra_tipo = 31,
                         usr_nam = so_usuario,
                         usr_fec = SYSDATE
                 WHERE       key_cuo = sm_aduana
                         AND car_reg_year = sm_gestion
                         AND car_reg_nber = nm_registro
                         AND key_secuencia = 1
                         AND tra_num = 0;

                --Para registrar la placa del medio de transporte EJAG 16/11/2015
                placa_cierre(sm_aduana,sm_gestion,nm_registro,0,'0','CIERRE');


            END IF;

            ops$asy.pckmanifiesto.generarmanifiesto (
                sm_gestion,
                sm_aduana,
                nm_registro,
                sd_aduana,
                '23',
                TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
                TO_CHAR (SYSDATE, 'hh24:mi:ss'),
                so_usuario,
                ans,
                p_manifiestoreferencia);

            -- nro del manifiesto registrado
            ans := RTRIM (ans);
            manifiesto := ans;
            existe := INSTR (manifiesto, ' ') - 10;

            INSERT INTO tra_loc
                SELECT   sm_aduana,
                         sm_gestion,
                         nm_registro,
                         1,
                         SUBSTR (ans, 6, 3),
                         SUBSTR (ans, 0, 4),
                         SUBSTR (ans, 10, existe),
                         key_bol_ref,
                         SYSDATE
                  FROM   ops$asy.car_bol_gen cb, ops$asy.car_gen cg
                 WHERE       cb.key_cuo = cg.key_cuo
                         AND cb.key_voy_nber = cg.key_voy_nber
                         AND cb.key_dep_date = cg.key_dep_date
                         AND cg.key_cuo = SUBSTR (ans, 6, 3)
                         AND cg.car_reg_year = SUBSTR (ans, 0, 4)
                         AND cg.car_reg_nber = SUBSTR (ans, 10, existe);

            SELECT   key_cuo, key_voy_nber, key_dep_date
              INTO   skey_cuo, skey_voy, skey_date
              FROM   car_gen
             WHERE       key_cuo = SUBSTR (ans, 6, 3)
                     AND car_reg_year = SUBSTR (ans, 0, 4)
                     AND car_reg_nber = SUBSTR (ans, 10, existe);
        ELSIF (sm_destino = '23')
        THEN
            SELECT   key_cuo, key_voy_nber, key_dep_date
              INTO   skey_cuo, skey_voy, skey_date
              FROM   car_gen
             WHERE       key_cuo = sm_aduana
                     AND car_reg_year = sm_gestion
                     AND car_reg_nber = nm_registro;

            UPDATE   car_gen
               SET   car_arr_date = TRUNC (SYSDATE),
                     car_arr_time = TO_CHAR (SYSDATE, 'hh24:mi:ss')
             WHERE       key_cuo = sm_aduana
                     AND car_reg_year = sm_gestion
                     AND car_reg_nber = nm_registro;

            manifiesto :=
                sm_gestion || '\' || sm_gestion || '-' || nm_registro;
        END IF;

        /* para la localizacion */
        SELECT   COUNT (1)
          INTO   existe
          FROM   ops$asy.unshdtab
         WHERE   shd_cod = skey_cuo || 'D144301ANTIC';

        IF (existe = 0)
        THEN
            ROLLBACK;
            RETURN 'No se encuentra el deposito para hacer la localizacion.';
        END IF;

/*
        SELECT   MAX (car_ope_nbr)
          INTO   v_operacion
          FROM   car_bol_ope
         WHERE       key_cuo = skey_cuo
                 AND key_voy_nber = skey_voy
                 AND key_dep_date = skey_date;

        v_operacion := v_operacion + 1;

            SELECT   ops$asy.car_bol_ser.NEXTVAL
              INTO   v_bol_ser
              FROM   DUAL
        FOR UPDATE   ;

        INSERT INTO car_bol_ope
            SELECT   key_cuo,
                     key_voy_nber,
                     key_dep_date,
                     key_bol_ref,
                     key_lin_nbr,
                     car_pkg_avl,
                     car_wgt_avl,
                     skey_cuo || 'D144301ANTIC',
                     'DECRETO SUPREMO 1443',
                     car_trs_cuo,
                     car_doc_ref,
                     car_trm_loc,
                     car_onw_cod,
                     car_onw_nam,
                     'LOC',
                     TRUNC (SYSDATE),
                     TO_CHAR (SYSDATE, 'hh24:mi:ss'),
                     v_operacion,
                     car_pkg_deb,
                     car_pkg_cre,
                     car_wgt_deb,
                     car_wgt_cre,
                     car_ass_ser,
                     car_ass_nbr,
                     car_ass_dat,
                     car_ass_itm,
                     car_pst_num,
                     car_man_dsc,
                     so_usuario,
                     v_bol_ser
              FROM   (SELECT   ope1.*
                        FROM   car_bol_ope ope1
                       WHERE       ope1.key_cuo = skey_cuo
                               AND ope1.key_voy_nber = skey_voy
                               AND ope1.key_dep_date = skey_date
                               AND ope1.car_ope_nbr =
                                      (SELECT   MAX (b.car_ope_nbr)
                                         FROM   car_bol_ope b
                                        WHERE   ope1.key_cuo = b.key_cuo
                                                AND ope1.key_voy_nber =
                                                       b.key_voy_nber
                                                AND ope1.key_dep_date =
                                                       b.key_dep_date
                                                AND ope1.key_bol_ref =
                                                       b.key_bol_ref));
*/





           FOR rs IN (SELECT   key_cuo,
                     key_voy_nber,
                     key_dep_date,
                     key_bol_ref,
                     key_lin_nbr,
                     car_pkg_avl,
                     car_wgt_avl,
                     skey_cuo || 'D144301ANTIC' deposito,
                     'DECRETO SUPREMO 1443' decreto,
                     car_trs_cuo,
                     car_doc_ref,
                     car_trm_loc,
                     car_onw_cod,
                     car_onw_nam,
                     'LOC' localizacion,
                     TRUNC (SYSDATE),
                     TO_CHAR (SYSDATE, 'hh24:mi:ss'),
                     v_operacion operacion,
                     car_pkg_deb,
                     car_pkg_cre,
                     car_wgt_deb,
                     car_wgt_cre,
                     car_ass_ser,
                     car_ass_nbr,
                     car_ass_dat,
                     car_ass_itm,
                     car_pst_num,
                     car_man_dsc,
                     so_usuario usuario
              FROM   (SELECT   ope1.*
                        FROM   car_bol_ope ope1
                       WHERE       ope1.key_cuo = skey_cuo
                               AND ope1.key_voy_nber = skey_voy
                               AND ope1.key_dep_date = skey_date
                               AND ope1.car_ope_nbr =
                                      (SELECT   MAX (b.car_ope_nbr)
                                         FROM   car_bol_ope b
                                        WHERE   ope1.key_cuo = b.key_cuo
                                                AND ope1.key_voy_nber =
                                                       b.key_voy_nber
                                                AND ope1.key_dep_date =
                                                       b.key_dep_date
                                                AND ope1.key_bol_ref =
                                                       b.key_bol_ref)))
          LOOP


                 SELECT   MAX (car_ope_nbr)
                  INTO   v_operacion
                  FROM   car_bol_ope
                 WHERE       key_cuo = rs.key_cuo
                 AND key_voy_nber = rs.key_voy_nber
                 AND key_dep_date = rs.key_dep_date
                 and key_bol_ref = rs.key_bol_ref;

                v_operacion := v_operacion + 1;


                SELECT   ops$asy.car_bol_ser.NEXTVAL
                  INTO   v_bol_ser
                  FROM   DUAL;
                --FOR UPDATE;

                INSERT INTO car_bol_ope values
                (    rs.key_cuo,
                     rs.key_voy_nber,
                     rs.key_dep_date,
                     rs.key_bol_ref,
                     rs.key_lin_nbr,
                     rs.car_pkg_avl,
                     rs.car_wgt_avl,
                     rs.deposito,
                     rs.decreto,
                     rs.car_trs_cuo,
                     rs.car_doc_ref,
                     rs.car_trm_loc,
                     rs.car_onw_cod,
                     rs.car_onw_nam,
                     rs.localizacion,
                     to_date(to_char(SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy'),
                     TO_CHAR (SYSDATE, 'hh24:mi:ss'),
                     v_operacion,
                     rs.car_pkg_deb,
                     rs.car_pkg_cre,
                     rs.car_wgt_deb,
                     rs.car_wgt_cre,
                     rs.car_ass_ser,
                     rs.car_ass_nbr,
                     rs.car_ass_dat,
                     rs.car_ass_itm,
                     rs.car_pst_num,
                     rs.car_man_dsc,
                     rs.usuario,
                     v_bol_ser);

        END LOOP;




        INSERT INTO car_spy
            SELECT   key_cuo,
                     key_voy_nber,
                     key_dep_date,
                     key_bol_ref,
                     '13',
                     '13',
                     so_usuario,
                     TRUNC (SYSDATE),
                     TO_CHAR (SYSDATE, 'hh24:mi:ss'),
                     1930
              FROM   (SELECT   ope1.*
                        FROM   car_spy ope1
                       WHERE       ope1.key_cuo = skey_cuo
                               AND ope1.key_voy_nber = skey_voy
                               AND ope1.key_dep_date = skey_date
                               AND NOT ope1.key_bol_ref IS NULL
                               AND ope1.rtp_nbr =
                                      (SELECT   MAX (rtp_nbr)
                                         FROM   car_spy b
                                        WHERE   b.key_cuo = ope1.key_cuo
                                                AND b.key_voy_nber =
                                                       ope1.key_voy_nber
                                                AND b.key_dep_date =
                                                       ope1.key_dep_date
                                                AND NOT b.key_bol_ref IS NULL));

        COMMIT;

        RETURN 'correcto';
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            RETURN 'Verifique que:' || CHR (13)
                   || '- Que el Manifiesto este registrado y el consignatario sea el mismo que el de la DUI.'
                   || CHR (13)
                   || '- Que no este descargado el Manifiesto.'
                   || CHR (13)
                   || '- Tipo destino sea 23:Importacion o 24:Transito.'
                   || CHR (13)
                   || '- Que el D/E este relacionado con la DUI.';
        WHEN TOO_MANY_ROWS
        THEN
            ROLLBACK;
            RETURN 'EL Manifiesto tiene mas de un D/E.';
        WHEN ZERO_DIVIDE
        THEN
            ROLLBACK;
            RETURN 'Solo se puede tener un destino.';
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN 'error' || (SQLERRM);
    END;

    FUNCTION imprime_parte (sm_aduana     IN car_gen.key_cuo%TYPE,
                            sm_gestion    IN car_gen.car_reg_year%TYPE,
                            nm_registro   IN car_gen.car_reg_nber%TYPE)
        RETURN cursortype
    IS
        cr       cursortype;
        existe   PLS_INTEGER;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_loc
         WHERE       key_cuo = sm_aduana
                 AND car_reg_year = sm_gestion
                 AND car_reg_nber = nm_registro;

        IF (existe > 0)
        THEN
            OPEN cr FOR
                SELECT   man_cuo,
                         man_reg_year,
                         man_reg_nber,
                         man_bol_ref
                  FROM   tra_loc
                 WHERE       key_cuo = sm_aduana
                         AND car_reg_year = sm_gestion
                         AND car_reg_nber = nm_registro;
        ELSE
            OPEN cr FOR
                SELECT   a.key_cuo AS man_cuo,
                         a.car_reg_year AS man_reg_year,
                         a.car_reg_nber AS man_reg_nber,
                         b.key_bol_ref AS man_bol_ref
                  FROM   car_gen a, car_bol_gen b
                 WHERE       a.key_cuo = b.key_cuo
                         AND a.key_voy_nber = b.key_voy_nber
                         AND a.key_dep_date = b.key_dep_date
                         AND b.carbol_nat_cod = '23'
                         AND a.key_cuo = sm_aduana
                         AND a.car_reg_year = sm_gestion
                         AND a.car_reg_nber = nm_registro;
        END IF;

        RETURN cr;
    END;


FUNCTION imprime_parte_sec (sm_aduana     IN car_gen.key_cuo%TYPE,
                            sm_gestion    IN car_gen.car_reg_year%TYPE,
                            nm_registro   IN car_gen.car_reg_nber%TYPE,
                            sm_secuencia  IN varchar2
                            )
        RETURN cursortype
    IS
        cr       cursortype;
        existe   PLS_INTEGER;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_loc
         WHERE       key_cuo = sm_aduana
                 AND car_reg_year = sm_gestion
                 AND car_reg_nber = nm_registro
                 and key_secuencia = sm_secuencia;

        IF (existe > 0)
        THEN
            OPEN cr FOR
                SELECT   man_cuo,
                         man_reg_year,
                         man_reg_nber,
                         man_bol_ref
                  FROM   tra_loc
                 WHERE       key_cuo = sm_aduana
                         AND car_reg_year = sm_gestion
                         AND car_reg_nber = nm_registro
                         and key_secuencia = sm_secuencia;
        ELSE
            OPEN cr FOR
                SELECT   a.key_cuo AS man_cuo,
                         a.car_reg_year AS man_reg_year,
                         a.car_reg_nber AS man_reg_nber,
                         b.key_bol_ref AS man_bol_ref
                  FROM   car_gen a, car_bol_gen b
                 WHERE       a.key_cuo = b.key_cuo
                         AND a.key_voy_nber = b.key_voy_nber
                         AND a.key_dep_date = b.key_dep_date
                         AND b.carbol_nat_cod = '23'
                         AND a.key_cuo = sm_aduana
                         AND a.car_reg_year = sm_gestion
                         AND a.car_reg_nber = nm_registro;
        END IF;

        RETURN cr;
    END;


    FUNCTION dui_parte_recep (s_cuo    IN VARCHAR2,
                              s_year   IN VARCHAR2,
                              s_nber   IN NUMBER,
                              s_ref    IN VARCHAR2)
        RETURN cursortype
    IS
        cd   cursortype;
    BEGIN
        OPEN cd FOR
            SELECT      car.key_cuo
                     || ' '
                     || car.car_reg_year
                     || ' '
                     || car.car_reg_nber
                     || ' - '
                     || bol.key_bol_ref
                         p_r,
                        TO_CHAR (car.car_arr_date, 'dd/mm/yyyy')
                     || ' '
                     || car.car_arr_time
                         llegada,
                     ope.car_loc_cod || ' ' || ope.car_loc_inf loc,      --(3)
                     (SELECT   NVL (
                                   TO_CHAR (MIN (b.car_ope_dat),
                                            'dd/mm/yyyy'),
                                   ' ')
                        FROM   car_bol_ope b
                       WHERE       ope.key_cuo = b.key_cuo
                               AND ope.key_voy_nber = b.key_voy_nber
                               AND ope.key_dep_date = b.key_dep_date
                               AND ope.key_bol_ref = b.key_bol_ref
                               AND b.car_ope_typ = 'LOC')
                         f_recep,                                        --(4)
                     NVL (car.car_id_trp, ' ') placa,
                     DECODE (bol.carbol_cons_cod,
                             NULL, bol.carbol_cons_nam,
                             unc.cmp_nam)
                         consig,
                     CASE
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'TEMPO'
                         THEN
                             'Deposito Temporal'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'ADUAN'
                         THEN
                             'Deposito de Aduana'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'TRANS'
                         THEN
                             'Deposito Transitorio'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'ESPEC'
                         THEN
                             'Deposito Especial'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'PUERT'
                         THEN
                             'Deposito de Puerto'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'INCAU'
                         THEN
                             'Mercancia Incautada'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'ABAND'
                         THEN
                             'Mercancia en Abandono'
                         ELSE
                             'NINGUNO'
                     END
                         tipo_recep,                                     --(7)
                     NVL (bol.carbol_shp_mark1, ' ') marca1,
                     NVL (bol.carbol_shp_mark2, ' ') marca2,
                     NVL (bol.carbol_shp_mark3, ' ') marca3,
                     NVL (bol.carbol_shp_mark4, ' ') marca4,
                     NVL (bol.carbol_shp_mark5, ' ') marca5,
                     car.car_car_cod || ' ' || car.car_car_nam transp,  --(13)
                        bol.carbol_good1
                     || ' '
                     || bol.carbol_good2
                     || ' '
                     || bol.carbol_good3
                     || ' '
                     || bol.carbol_good4
                     || ' '
                     || bol.carbol_good5
                         descrip,
                     NVL (bol.carbol_pack_cod, ' ') tipo_bultos,
                     NVL (pkg.pkg_dsc, ' ') tipo_desc,
                     bol.carbol_pack_nber cant_manif,
                     bol.carbol_gros_mas peso_manif,                    --(18)
                     ope1.car_pkg_avl cant_recib,
                     ope1.car_wgt_avl peso_recib,                       --(20)
                     CASE
                         WHEN (bol.carbol_pack_nber - ope1.car_pkg_avl) <= 0
                         THEN
                             ABS (bol.carbol_pack_nber - ope1.car_pkg_avl)
                         ELSE
                             0
                     END
                         c_sobrante,
                     CASE
                         WHEN (bol.carbol_gros_mas - ope1.car_wgt_avl) <= 0
                         THEN
                             ABS (bol.carbol_gros_mas - ope1.car_wgt_avl)
                         ELSE
                             0
                     END
                         p_sobrante,
                     CASE
                         WHEN (bol.carbol_pack_nber - ope1.car_pkg_avl) >= 0
                         THEN
                             ABS (bol.carbol_pack_nber - ope1.car_pkg_avl)
                         ELSE
                             0
                     END
                         c_fantante,
                     CASE
                         WHEN (bol.carbol_gros_mas - ope1.car_wgt_avl) >= 0
                         THEN
                             ABS (bol.carbol_gros_mas - ope1.car_wgt_avl)
                         ELSE
                             0
                     END
                         p_faltante,                                    --(24)
                     NVL (bol.carbol_shp_mark6, ' ') obs1,
                     NVL (bol.carbol_shp_mark7, ' ') obs2,
                     NVL (bol.carbol_shp_mark8, ' ') obs3,
                     NVL (bol.carbol_shp_mark9, ' ') obs4,
                     NVL (bol.carbol_shp_mark0, ' ') obs5,              --(29)
                     bol.carbol_infos1 || ' ' || bol.carbol_infos2
                         informacion1,
                     ' ' observacion
              FROM   car_gen car,
                     car_bol_gen bol,
                     car_bol_ope ope,
                     car_bol_ope ope1,
                     uncmptab unc,
                     unpkgtab pkg
             WHERE       car.key_cuo = bol.key_cuo
                     AND car.key_voy_nber = bol.key_voy_nber
                     AND car.key_dep_date = bol.key_dep_date
                     AND bol.key_cuo = ope.key_cuo
                     AND bol.key_voy_nber = ope.key_voy_nber
                     AND bol.key_dep_date = ope.key_dep_date
                     AND bol.key_bol_ref = ope.key_bol_ref
                     AND ope.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope.key_cuo = b.key_cuo
                                      AND ope.key_voy_nber = b.key_voy_nber
                                      AND ope.key_dep_date = b.key_dep_date
                                      AND ope.key_bol_ref = b.key_bol_ref)
                     AND ope.car_ope_typ <> 'MAN' --manifiestos anulados o con descarga manual
                     AND bol.key_cuo = ope1.key_cuo
                     AND bol.key_voy_nber = ope1.key_voy_nber
                     AND bol.key_dep_date = ope1.key_dep_date
                     AND bol.key_bol_ref = ope1.key_bol_ref
                     AND ope1.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope1.key_cuo = b.key_cuo
                                      AND ope1.key_voy_nber = b.key_voy_nber
                                      AND ope1.key_dep_date = b.key_dep_date
                                      AND ope1.key_bol_ref = b.key_bol_ref
                                      AND b.car_ope_typ IN ('EXC', 'LOC')) -- busca la primera operacion de sobrantes y faltantes
                     AND bol.carbol_cons_cod = unc.cmp_cod(+)
                     AND unc.lst_ope(+) = 'U'
                     AND bol.carbol_pack_cod = pkg.pkg_cod
                     AND pkg.lst_ope = 'U'
                     AND bol.key_cuo = s_cuo                         --KEY_CUO
                     AND car.car_reg_year = s_year --SUSTR(SAD_MANIF_NBER,1,4)
                     AND car.car_reg_nber = s_nber --SUSTR(SAD_MANIF_NBER,6,10)
                     AND bol.key_bol_ref = s_ref             --SADITM_TRSP_DOC
            UNION
            SELECT      car.key_cuo
                     || ' '
                     || car.car_reg_year
                     || ' '
                     || car.car_reg_nber
                     || ' - '
                     || bol.key_bol_ref
                         p_r,
                        TO_CHAR (car.car_arr_date, 'dd/mm/yyyy')
                     || ' '
                     || car.car_arr_time
                         llegada,
                     ope.car_loc_cod || ' ' || ope.car_loc_inf loc,      --(3)
                     (SELECT   NVL (
                                   TO_CHAR (MIN (b.car_ope_dat),
                                            'dd/mm/yyyy'),
                                   ' ')
                        FROM   car_bol_ope b
                       WHERE       ope.key_cuo = b.key_cuo
                               AND ope.key_voy_nber = b.key_voy_nber
                               AND ope.key_dep_date = b.key_dep_date
                               AND ope.key_bol_ref = b.key_bol_ref
                               AND b.car_ope_typ = 'LOC')
                         f_recep,                                        --(4)
                     NVL (car.car_id_trp, ' ') placa,
                     DECODE (bol.carbol_cons_cod,
                             NULL, bol.carbol_cons_nam,
                             unc.cmp_nam)
                         consig,
                     CASE
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'TEMPO'
                         THEN
                             'Deposito Temporal'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'ADUAN'
                         THEN
                             'Deposito de Aduana'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'TRANS'
                         THEN
                             'Deposito Transitorio'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'ESPEC'
                         THEN
                             'Deposito Especial'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'PUERT'
                         THEN
                             'Deposito de Puerto'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'INCAU'
                         THEN
                             'Mercancia Incautada'
                         WHEN SUBSTR (ope.car_loc_cod, -5) = 'ABAND'
                         THEN
                             'Mercancia en Abandono'
                         ELSE
                             'NINGUNO'
                     END
                         tipo_recep,                                     --(7)
                     NVL (bol.carbol_shp_mark1, ' ') marca1,
                     NVL (bol.carbol_shp_mark2, ' ') marca2,
                     NVL (bol.carbol_shp_mark3, ' ') marca3,
                     NVL (bol.carbol_shp_mark4, ' ') marca4,
                     NVL (bol.carbol_shp_mark5, ' ') marca5,
                     car.car_car_cod || ' ' || car.car_car_nam transp,  --(13)
                        bol.carbol_good1
                     || ' '
                     || bol.carbol_good2
                     || ' '
                     || bol.carbol_good3
                     || ' '
                     || bol.carbol_good4
                     || ' '
                     || bol.carbol_good5
                         descrip,
                     NVL (bol.carbol_pack_cod, ' ') tipo_bultos,
                     NVL (pkg.pkg_dsc, ' ') tipo_desc,
                     bol.carbol_pack_nber cant_manif,
                     bol.carbol_gros_mas peso_manif,                    --(18)
                     ope1.car_pkg_avl cant_recib,
                     ope1.car_wgt_avl peso_recib,                       --(20)
                     CASE
                         WHEN (bol.carbol_pack_nber - ope1.car_pkg_avl) <= 0
                         THEN
                             ABS (bol.carbol_pack_nber - ope1.car_pkg_avl)
                         ELSE
                             0
                     END
                         c_sobrante,
                     CASE
                         WHEN (bol.carbol_gros_mas - ope1.car_wgt_avl) <= 0
                         THEN
                             ABS (bol.carbol_gros_mas - ope1.car_wgt_avl)
                         ELSE
                             0
                     END
                         p_sobrante,
                     CASE
                         WHEN (bol.carbol_pack_nber - ope1.car_pkg_avl) >= 0
                         THEN
                             ABS (bol.carbol_pack_nber - ope1.car_pkg_avl)
                         ELSE
                             0
                     END
                         c_fantante,
                     CASE
                         WHEN (bol.carbol_gros_mas - ope1.car_wgt_avl) >= 0
                         THEN
                             ABS (bol.carbol_gros_mas - ope1.car_wgt_avl)
                         ELSE
                             0
                     END
                         p_faltante,                                    --(24)
                     NVL (bol.carbol_shp_mark6, ' ') obs1,
                     NVL (bol.carbol_shp_mark7, ' ') obs2,
                     NVL (bol.carbol_shp_mark8, ' ') obs3,
                     NVL (bol.carbol_shp_mark9, ' ') obs4,
                     NVL (bol.carbol_shp_mark0, ' ') obs5,              --(29)
                     bol.carbol_infos1 || ' ' || bol.carbol_infos2
                         informacion1,
                     ' ' observacion
              FROM   car_gen car,
                     car_bol_gen bol,
                     car_bol_ope ope,
                     car_bol_ope ope1,
                     uncmptab unc,
                     unpkgtab pkg
             WHERE       car.key_cuo = bol.key_cuo
                     AND car.key_voy_nber = bol.key_voy_nber
                     AND car.key_dep_date = bol.key_dep_date
                     AND bol.key_cuo = ope.key_cuo
                     AND bol.key_voy_nber = ope.key_voy_nber
                     AND bol.key_dep_date = ope.key_dep_date
                     AND bol.key_bol_ref = ope.key_bol_ref
                     AND ope.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope.key_cuo = b.key_cuo
                                      AND ope.key_voy_nber = b.key_voy_nber
                                      AND ope.key_dep_date = b.key_dep_date
                                      AND ope.key_bol_ref = b.key_bol_ref)
                     AND ope.car_ope_typ <> 'MAN' --manifiestos anulados o con descarga manual
                     AND bol.key_cuo = ope1.key_cuo
                     AND bol.key_voy_nber = ope1.key_voy_nber
                     AND bol.key_dep_date = ope1.key_dep_date
                     AND bol.key_bol_ref = ope1.key_bol_ref
                     AND bol.key_voy_nber LIKE 'CONS%'
                     AND ope1.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope1.key_cuo = b.key_cuo
                                      AND ope1.key_voy_nber = b.key_voy_nber
                                      AND ope1.key_dep_date = b.key_dep_date
                                      AND ope1.key_bol_ref = b.key_bol_ref
                                      AND b.car_ope_typ = 'STO')
                     AND bol.carbol_cons_cod = unc.cmp_cod(+)
                     AND unc.lst_ope(+) = 'U'
                     AND bol.carbol_pack_cod = pkg.pkg_cod
                     AND pkg.lst_ope = 'U'
                     AND bol.key_cuo = s_cuo                         --KEY_CUO
                     AND car.car_reg_year = s_year --SUSTR(SAD_MANIF_NBER,1,4)
                     AND car.car_reg_nber = s_nber --SUSTR(SAD_MANIF_NBER,6,10)
                     AND bol.key_bol_ref = s_ref;            --SADITM_TRSP_DOC

        DBMS_OUTPUT.put_line ('Carga bien parte de recepcion');
        RETURN cd;
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (SQLERRM);
    END;


     FUNCTION detalle_cierre_docemb (s_cuo    IN VARCHAR2,
                              s_year   IN VARCHAR2,
                              s_nber   IN NUMBER,
                              s_ref    IN VARCHAR2)
        RETURN cursortype
    IS
        cd   cursortype;
    BEGIN
        OPEN cd FOR
            SELECT      car.key_cuo,
                     car.car_reg_year,
                     car.car_reg_nber,
                     bol.key_bol_ref,
                     car.key_cuo||' '||
                     car.car_reg_year||' - '||
                     car.car_reg_nber nroregistro,

                        TO_CHAR (car.car_arr_date, 'dd/mm/yyyy')
                     || ' '
                     || car.car_arr_time
                         llegada,
                     (SELECT   NVL (
                                   TO_CHAR (MIN (b.car_ope_dat),
                                            'dd/mm/yyyy'),
                                   ' ')
                        FROM   car_bol_ope b
                       WHERE       ope.key_cuo = b.key_cuo
                               AND ope.key_voy_nber = b.key_voy_nber
                               AND ope.key_dep_date = b.key_dep_date
                               AND ope.key_bol_ref = b.key_bol_ref
                               AND b.car_ope_typ = 'LOC')
                         f_recep,                                        --(4)
                     DECODE (bol.carbol_cons_cod,
                             NULL, bol.carbol_cons_nam,
                             unc.cmp_nam)
                         consig,
                     NVL (bol.carbol_shp_mark6, ' ') obs1,
                     NVL (bol.carbol_shp_mark7, ' ') obs2,
                     NVL (bol.carbol_shp_mark8, ' ') obs3,
                     NVL (bol.carbol_shp_mark9, ' ') obs4,
                     NVL (bol.carbol_shp_mark0, ' ') obs5,
                     NVL (bol.carbol_shp_mark5, ' ')
              FROM   car_gen car,
                     car_bol_gen bol,
                     car_bol_ope ope,
                     car_bol_ope ope1,
                     uncmptab unc,
                     unpkgtab pkg
             WHERE       car.key_cuo = bol.key_cuo
                     AND car.key_voy_nber = bol.key_voy_nber
                     AND car.key_dep_date = bol.key_dep_date
                     AND bol.key_cuo = ope.key_cuo
                     AND bol.key_voy_nber = ope.key_voy_nber
                     AND bol.key_dep_date = ope.key_dep_date
                     AND bol.key_bol_ref = ope.key_bol_ref
                     AND ope.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope.key_cuo = b.key_cuo
                                      AND ope.key_voy_nber = b.key_voy_nber
                                      AND ope.key_dep_date = b.key_dep_date
                                      AND ope.key_bol_ref = b.key_bol_ref)
                     AND ope.car_ope_typ <> 'MAN' --manifiestos anulados o con descarga manual
                     AND bol.key_cuo = ope1.key_cuo
                     AND bol.key_voy_nber = ope1.key_voy_nber
                     AND bol.key_dep_date = ope1.key_dep_date
                     AND bol.key_bol_ref = ope1.key_bol_ref
                     AND ope1.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope1.key_cuo = b.key_cuo
                                      AND ope1.key_voy_nber = b.key_voy_nber
                                      AND ope1.key_dep_date = b.key_dep_date
                                      AND ope1.key_bol_ref = b.key_bol_ref
                                      AND b.car_ope_typ IN ('EXC', 'LOC')) -- busca la primera operacion de sobrantes y faltantes
                     AND bol.carbol_cons_cod = unc.cmp_cod(+)
                     AND unc.lst_ope(+) = 'U'
                     AND bol.carbol_pack_cod = pkg.pkg_cod
                     AND pkg.lst_ope = 'U'
                     AND bol.key_cuo = s_cuo                         --KEY_CUO
                     AND car.car_reg_year = s_year --SUSTR(SAD_MANIF_NBER,1,4)
                     AND car.car_reg_nber = s_nber --SUSTR(SAD_MANIF_NBER,6,10)
                     AND bol.key_bol_ref = s_ref             --SADITM_TRSP_DOC
            UNION
            SELECT      car.key_cuo,
            car.car_reg_year,
            car.car_reg_nber,
            bol.key_bol_ref,

            car.key_cuo ||' - '||
            car.car_reg_year ||' - '||
            car.car_reg_nber nroregistro,
            TO_CHAR (car.car_arr_date, 'dd/mm/yyyy')
                     || ' '
                     || car.car_arr_time
                         llegada,
                     (SELECT   NVL (
                                   TO_CHAR (MIN (b.car_ope_dat),
                                            'dd/mm/yyyy'),
                                   ' ')
                        FROM   car_bol_ope b
                       WHERE       ope.key_cuo = b.key_cuo
                               AND ope.key_voy_nber = b.key_voy_nber
                               AND ope.key_dep_date = b.key_dep_date
                               AND ope.key_bol_ref = b.key_bol_ref
                               AND b.car_ope_typ = 'LOC')
                         f_recep,                                        --(4)
                     DECODE (bol.carbol_cons_cod,
                             NULL, bol.carbol_cons_nam,
                             unc.cmp_nam)
                         consig,
                                                         --(24)
                     NVL (bol.carbol_shp_mark6, ' ') obs1,
                     NVL (bol.carbol_shp_mark7, ' ') obs2,
                     NVL (bol.carbol_shp_mark8, ' ') obs3,
                     NVL (bol.carbol_shp_mark9, ' ') obs4,
                     NVL (bol.carbol_shp_mark0, ' ') obs5,            --(29)
                     NVL (bol.carbol_shp_mark5, ' ')
              FROM   car_gen car,
                     car_bol_gen bol,
                     car_bol_ope ope,
                     car_bol_ope ope1,
                     uncmptab unc,
                     unpkgtab pkg
             WHERE       car.key_cuo = bol.key_cuo
                     AND car.key_voy_nber = bol.key_voy_nber
                     AND car.key_dep_date = bol.key_dep_date
                     AND bol.key_cuo = ope.key_cuo
                     AND bol.key_voy_nber = ope.key_voy_nber
                     AND bol.key_dep_date = ope.key_dep_date
                     AND bol.key_bol_ref = ope.key_bol_ref
                     AND ope.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope.key_cuo = b.key_cuo
                                      AND ope.key_voy_nber = b.key_voy_nber
                                      AND ope.key_dep_date = b.key_dep_date
                                      AND ope.key_bol_ref = b.key_bol_ref)
                     AND ope.car_ope_typ <> 'MAN' --manifiestos anulados o con descarga manual
                     AND bol.key_cuo = ope1.key_cuo
                     AND bol.key_voy_nber = ope1.key_voy_nber
                     AND bol.key_dep_date = ope1.key_dep_date
                     AND bol.key_bol_ref = ope1.key_bol_ref
                     AND bol.key_voy_nber LIKE 'CONS%'
                     AND ope1.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope1.key_cuo = b.key_cuo
                                      AND ope1.key_voy_nber = b.key_voy_nber
                                      AND ope1.key_dep_date = b.key_dep_date
                                      AND ope1.key_bol_ref = b.key_bol_ref
                                      AND b.car_ope_typ = 'STO')
                     AND bol.carbol_cons_cod = unc.cmp_cod(+)
                     AND unc.lst_ope(+) = 'U'
                     AND bol.carbol_pack_cod = pkg.pkg_cod
                     AND pkg.lst_ope = 'U'
                     AND bol.key_cuo = s_cuo                         --KEY_CUO
                     AND car.car_reg_year = s_year --SUSTR(SAD_MANIF_NBER,1,4)
                     AND car.car_reg_nber = s_nber --SUSTR(SAD_MANIF_NBER,6,10)
                     AND bol.key_bol_ref = s_ref;            --SADITM_TRSP_DOC

        DBMS_OUTPUT.put_line ('Carga bien parte de recepcion');
        RETURN cd;
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (SQLERRM);
    END;





 FUNCTION transitos_con_parte (  prm_cuoini     IN VARCHAR2,
                                 prm_cuofin     IN VARCHAR2,
                                 prm_fecini     IN VARCHAR2,
                                 prm_fecfin     IN VARCHAR2
                              )
        RETURN cursortype
    IS
        cr       cursortype;
    BEGIN

OPEN cr FOR

  SELECT
         a.key_cuo cuomi,
         a.car_reg_year yearmi,
         a.car_reg_nber nbermi,
         a.key_secuencia secmi,
         cg.car_car_cod || ': ' || cg.car_car_nam,
         cg.car_id_trp,
         TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:mi') AS tra_fec_ini,
         a.tra_cuo_ini || ': ' || b.cuo_nam AS tra_cuo_ini,
         NVL (TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:mi'),
              TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:mi'))
             AS tra_fec_des,
         DECODE (a.tra_cuo_des,
                 NULL, a.tra_cuo_est || ': ' || c.cuo_nam,
                 a.tra_cuo_des || ': ' || d.cuo_nam)
             AS tra_cuo_des,

                          car.key_cuo|| ': ' || e.cuo_nam,
                     car.car_reg_year,
                     car.car_reg_nber,
                     bol.key_bol_ref,
                     car.key_cuo||' '||
                     car.car_reg_year||' - '||
                     car.car_reg_nber nroregistro,

                        TO_CHAR (car.car_arr_date, 'dd/mm/yyyy')
                     || ' '
                     || car.car_arr_time
                         llegada,
                     (SELECT   NVL (
                                   TO_CHAR (MIN (b.car_ope_dat),
                                            'dd/mm/yyyy'),
                                   ' ')
                        FROM   car_bol_ope b
                       WHERE       ope.key_cuo = b.key_cuo
                               AND ope.key_voy_nber = b.key_voy_nber
                               AND ope.key_dep_date = b.key_dep_date
                               AND ope.key_bol_ref = b.key_bol_ref
                               AND b.car_ope_typ = 'LOC')
                         f_recep,                                        --(4)
                     DECODE (bol.carbol_cons_cod,
                             NULL, bol.carbol_cons_nam,
                             unc.cmp_nam)
                         consig
              FROM
                     transitos.tra_pla_rut a,
                     ops$asy.uncuotab b,
                     ops$asy.uncuotab c,
                     ops$asy.uncuotab d,
                     ops$asy.uncuotab e,
                     ops$asy.car_gen cg,

                     car_gen car,
                     car_bol_gen bol,
                     car_bol_ope ope,
                     uncmptab unc,
                     tra_loc tl
             WHERE       car.key_cuo = bol.key_cuo
                     AND car.key_voy_nber = bol.key_voy_nber
                     AND car.key_dep_date = bol.key_dep_date
                     AND bol.key_cuo = ope.key_cuo
                     AND bol.key_voy_nber = ope.key_voy_nber
                     AND bol.key_dep_date = ope.key_dep_date
                     AND bol.key_bol_ref = ope.key_bol_ref
                     AND ope.car_ope_nbr =
                            (SELECT   MAX (b.car_ope_nbr)
                               FROM   car_bol_ope b
                              WHERE       ope.key_cuo = b.key_cuo
                                      AND ope.key_voy_nber = b.key_voy_nber
                                      AND ope.key_dep_date = b.key_dep_date
                                      AND ope.key_bol_ref = b.key_bol_ref)
                     AND ope.car_ope_typ <> 'MAN' --manifiestos anulados o con descarga manual
                     AND bol.carbol_cons_cod = unc.cmp_cod(+)
                     AND unc.lst_ope(+) = 'U'

                     AND bol.key_cuo = tl.man_cuo                         --KEY_CUO
                     AND car.car_reg_year = tl.man_reg_year --SUSTR(SAD_MANIF_NBER,1,4)
                     AND car.car_reg_nber = tl.man_reg_nber --SUSTR(SAD_MANIF_NBER,6,10)
                     AND bol.key_bol_ref = tl.man_bol_ref             --SADITM_TRSP_DOC

                     AND tl.key_cuo =  a.key_cuo
                     AND tl.car_reg_year = a.car_reg_year
                     AND tl.car_reg_nber = a.car_reg_nber
AND tl.key_secuencia = a.key_secuencia


         AND a.key_cuo = cg.key_cuo
         AND a.car_reg_year = cg.car_reg_year
         AND a.car_reg_nber = cg.car_reg_nber
         AND a.tra_cuo_ini LIKE prm_cuoini
         AND NVL (a.tra_cuo_des, a.tra_cuo_est) LIKE prm_cuofin
         AND TRUNC (a.tra_fec_ini) BETWEEN TO_DATE (prm_fecini,'dd/mm/yyyy')
                                       AND  TO_DATE (prm_fecfin,'dd/mm/yyyy')
         AND car.key_cuo = e.cuo_cod
         AND e.lst_ope = 'U'

         AND a.tra_cuo_ini = b.cuo_cod
         AND b.lst_ope = 'U'
         AND NVL (a.tra_cuo_des, a.tra_cuo_est) = c.cuo_cod
         AND c.lst_ope = 'U'
         AND a.tra_cuo_des = d.cuo_cod(+)
         AND d.lst_ope(+) = 'U'
         AND a.tra_num = 0
         AND a.lst_ope = 'U'
         AND tra_loc = '1'
         order by 1,2,3,4;

RETURN cr;
    END;





    FUNCTION valida_transitos (sm_gestion    IN car_gen.car_reg_year%TYPE,
                               sm_aduana     IN car_gen.key_cuo%TYPE,
                               nm_registro   IN car_gen.car_reg_nber%TYPE)
        RETURN VARCHAR2
    IS
        canal    sad_spy.sad_clr%TYPE;
        existe   PLS_INTEGER;
    BEGIN
        IF (NOT sm_aduana IN ('072', '071'))
        THEN
            RETURN 'correcto';
        END IF;

        SELECT   sad_clr
          INTO   canal
          FROM   sad_gen a, sad_spy b
         WHERE       a.sad_num = 0
                 AND a.lst_ope = 'U'
                 AND a.sad_typ_dec = 'IMA'
                 AND a.key_year = b.key_year
                 AND a.key_cuo = b.key_cuo
                 AND NVL (a.key_dec, '-') = NVL (b.key_dec, '-')
                 AND a.key_nber = b.key_nber
                 AND b.spy_act = '24'
                 AND (a.key_cuo,
                      a.sad_reg_year,
                      a.sad_reg_serial,
                      a.sad_reg_nber) IN
                            (SELECT   SUBSTR (carbol_shp_mark5, 6, 3),
                                      SUBSTR (carbol_shp_mark5, 0, 4),
                                      'C',
                                      SUBSTR (
                                          carbol_shp_mark5,
                                          12,
                                          LENGTH (carbol_shp_mark5) - 12 - 8)
                               FROM   car_bol_gen b, car_gen a
                              WHERE       a.key_cuo = sm_aduana
                                      AND a.car_reg_year = sm_gestion
                                      AND a.car_reg_nber = nm_registro
                                      AND a.key_cuo = b.key_cuo
                                      AND a.key_voy_nber = b.key_voy_nber
                                      AND a.key_dep_date = b.key_dep_date);

        IF (canal = 0)
        THEN
            RETURN 'Despacho Anticipado.';
        ELSE
            RETURN 'correcto';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN 'correcto';
        WHEN INVALID_NUMBER
        THEN
            RETURN 'correcto';
        WHEN OTHERS
        THEN
            RETURN 'Se produjo un error con la Consulta, vuelve a intentar.';
    END;
END pkg_despacho;
/

