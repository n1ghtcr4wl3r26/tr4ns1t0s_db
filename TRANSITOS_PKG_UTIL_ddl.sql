CREATE OR REPLACE 
PACKAGE pkg_util
/* Formatted on 28-sep.-2017 18:11:20 (QP5 v5.126) */
IS
    TYPE cursortype IS REF CURSOR;

    FUNCTION comparacion_precios (prm_key_year   IN VARCHAR2,
                                  prm_key_cuo    IN VARCHAR2,
                                  prm_key_dec    IN VARCHAR2,
                                  prm_key_nber   IN VARCHAR2,
                                  prm_usuario    IN VARCHAR2)
        RETURN INTEGER;

    FUNCTION verifica_pastogrande (prm_car_reg_year   IN VARCHAR2,
                                   prm_key_cuo        IN VARCHAR2,
                                   prm_car_reg_nber   IN VARCHAR2)
        RETURN INTEGER;

    FUNCTION devuelve_dui (prm_car_reg_year   IN VARCHAR2,
                           prm_key_cuo        IN VARCHAR2,
                           prm_car_reg_nber   IN VARCHAR2)
        RETURN cursortype;

    FUNCTION test_sleep (in_time IN NUMBER)
        RETURN INTEGER;

    PROCEDURE proc_sleep (in_time IN NUMBER);

    FUNCTION cantidad_docemb_por_tramo (prm_key_cuo        IN VARCHAR2,
                                        prm_key_voy_nber   IN VARCHAR2,
                                        prm_key_dep_date   IN VARCHAR2,
                                        prm_frt_prep       IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION lista_docemb_por_tramo (prm_key_year        IN VARCHAR2,
                                     prm_key_cuo         IN VARCHAR2,
                                     prm_key_nber        IN VARCHAR2,
                                     prm_key_secuencia   IN VARCHAR2)
        RETURN cursortype;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_util
/* Formatted on 28-sep.-2017 18:12:03 (QP5 v5.126) */
IS
    FUNCTION comparacion_precios (prm_key_year   IN VARCHAR2,
                                  prm_key_cuo    IN VARCHAR2,
                                  prm_key_dec    IN VARCHAR2,
                                  prm_key_nber   IN VARCHAR2,
                                  prm_usuario    IN VARCHAR2)
        RETURN INTEGER
    IS
        v_res   INTEGER;
        res     VARCHAR2 (300);
    BEGIN
        --Proceso MIRA para comparacion de precios.
        res :=
            mira.pkg_analista.ver_dui_dav (prm_key_year,
                                           prm_key_cuo,
                                           prm_key_dec,
                                           prm_key_nber,
                                           prm_usuario);

        INSERT INTO tra_pastogrande
          VALUES   ('COMPARACION PRECIOS' || res,
                    SYSDATE,
                    prm_key_year,
                    prm_key_cuo,
                    prm_key_dec,
                    prm_key_nber);

        v_res := 0;
        RETURN v_res;
    END;

    FUNCTION asigna_tecnico_analista (prm_key_year   IN VARCHAR2,
                                      prm_key_cuo    IN VARCHAR2,
                                      prm_key_dec    IN VARCHAR2,
                                      prm_key_nber   IN VARCHAR2,
                                      prm_usuario    IN VARCHAR2)
        RETURN INTEGER
    IS
        v_res      INTEGER;
        acant      NUMBER;
        kusr_ex1   VARCHAR2 (30);
        kusr_ex2   VARCHAR2 (30);
        desc1      VARCHAR2 (30);
        desc2      VARCHAR2 (30);

        ksec_cod   VARCHAR2 (30);
        kclr       VARCHAR2 (30);
        citems     NUMBER;
    BEGIN
        --ASIGNA TECNICO DE ADUANA
        ------- VERIFICAR SI YA TIENE ASIGNACION DE VISTA -------
        SELECT   COUNT (1)
          INTO   acant
          FROM   ops$asy.sad_spy
         WHERE       key_year = prm_key_year
                 AND key_cuo = prm_key_cuo
                 AND key_dec = prm_key_dec
                 AND key_nber = prm_key_nber
                 AND spy_sta = '10'
                 AND spy_act = '76';

        IF acant > 0
        THEN
            RETURN 0;
        END IF;

        ------- OBTENER LOS DATOS DEL USR_EX1 Y USR_EX2 -------

        SELECT   usr_nam
          INTO   kusr_ex1
          FROM   ops$asy.sec_usr b
         WHERE       b.cuo_cod = prm_key_cuo
                 AND b.sec_cod = ksec_cod
                 AND b.usr_sta = 1
                 AND b.usr_typ = 1
                 AND ROWNUM = 1
                 AND (b.usr_nbd + b.usr_wrk) =
                        (SELECT   MIN (usr_nbd + usr_wrk)
                           FROM   ops$asy.sec_usr a
                          WHERE       a.cuo_cod = prm_key_cuo
                                  AND a.sec_cod = ksec_cod
                                  AND a.usr_sta = 1
                                  AND a.usr_typ = 1);

        SELECT   usr_nam
          INTO   kusr_ex2
          FROM   ops$asy.sec_usr b
         WHERE       b.cuo_cod = prm_key_cuo
                 AND b.sec_cod = ksec_cod
                 AND b.usr_sta = 1
                 AND b.usr_typ = 2
                 AND ROWNUM = 1
                 AND (b.usr_nbd + b.usr_wrk) =
                        (SELECT   MIN (usr_nbd + usr_wrk)
                           FROM   ops$asy.sec_usr a
                          WHERE       a.cuo_cod = prm_key_cuo
                                  AND a.sec_cod = ksec_cod
                                  AND a.usr_sta = 1
                                  AND a.usr_typ = 2);

        --- INSERT EN LA SAD_SPY
        INSERT INTO ops$asy.sad_spy
          VALUES   (prm_key_year,
                    prm_key_cuo,
                    prm_key_dec,
                    prm_key_nber,
                    '10',
                    '76',
                    prm_usuario,
                    TRUNC (SYSDATE),
                    TO_CHAR (SYSDATE, 'hh24:mi:ss'),
                    kclr,
                    ksec_cod,
                    kusr_ex1,
                    kusr_ex2,
                    '0',
                    '0',
                    NULL,
                    -1);

        ---- DESCUENTO DE LA CARGA DE TRABAJO ----------

        SELECT   dec_wgt, itm_wgt
          INTO   desc1, desc2
          FROM   ops$asy.sel_prm
         WHERE   cuo_cod = prm_key_cuo AND sel_flw = 1;

        UPDATE   ops$asy.sec_usr a
           SET   a.usr_wrk = usr_wrk + (desc1 + desc2 * citems),
                 a.usr_nbd = usr_nbd + 1,
                 a.usr_wrn = 1
         WHERE       a.cuo_cod = prm_key_cuo
                 AND a.sec_cod = ksec_cod
                 AND a.usr_nam = kusr_ex1;


        UPDATE   ops$asy.sec_usr a
           SET   a.usr_wrk = usr_wrk + (desc1 + desc2 * citems),
                 a.usr_nbd = usr_nbd + 1,
                 a.usr_wrn = 1
         WHERE       a.cuo_cod = prm_key_cuo
                 AND a.sec_cod = ksec_cod
                 AND a.usr_nam = kusr_ex2;



        INSERT INTO tra_pastogrande
          VALUES   (prm_usuario,
                    SYSDATE,
                    prm_key_year,
                    prm_key_cuo,
                    prm_key_dec,
                    prm_key_nber);

        v_res := 0;
        RETURN v_res;
    END;

    FUNCTION asigna_tecnico_aforador (prm_key_year   IN VARCHAR2,
                                      prm_key_cuo    IN VARCHAR2,
                                      prm_key_dec    IN VARCHAR2,
                                      prm_key_nber   IN VARCHAR2,
                                      prm_usuario    IN VARCHAR2)
        RETURN INTEGER
    IS
        v_res   INTEGER;
    BEGIN
        --ASIGNA TECNICO DE ADUANA
        INSERT INTO tra_pastogrande
          VALUES   (prm_usuario,
                    SYSDATE,
                    prm_key_year,
                    prm_key_cuo,
                    prm_key_dec,
                    prm_key_nber);

        v_res := 0;
        RETURN v_res;
    END;

    FUNCTION verifica_pastogrande (prm_car_reg_year   IN VARCHAR2,
                                   prm_key_cuo        IN VARCHAR2,
                                   prm_car_reg_nber   IN VARCHAR2)
        RETURN INTEGER
    IS
        v_res       INTEGER;
        existe      NUMBER;
        sw          NUMBER;
        v_keyyear   VARCHAR2 (4);
        v_keycuo    VARCHAR2 (5);
        v_keydec    VARCHAR2 (17);
        v_keynber   VARCHAR2 (13);
    BEGIN
        sw := 0;

        SELECT   COUNT (1)
          INTO   existe
          FROM   ops$asy.car_gen a, ops$asy.car_bol_gen b
         WHERE       a.car_reg_year = prm_car_reg_year
                 AND a.key_cuo = prm_key_cuo
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.key_cuo = b.key_cuo
                 AND a.key_voy_nber = b.key_voy_nber
                 AND a.key_dep_date = b.key_dep_date
                 AND b.carbol_nat_cod = '24'
                 AND (b.carbol_frt_prep IS NULL OR b.carbol_frt_prep <> '402');

        IF existe > 0
        THEN
            RETURN 1;
        END IF;

        FOR i
        IN (SELECT   b.carbol_shp_mark5
              FROM   ops$asy.car_gen a, ops$asy.car_bol_gen b
             WHERE       a.car_reg_year = prm_car_reg_year
                     AND a.key_cuo = prm_key_cuo
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND a.key_cuo = b.key_cuo
                     AND a.key_voy_nber = b.key_voy_nber
                     AND a.key_dep_date = b.key_dep_date)
        LOOP
            SELECT   INSTR (i.carbol_shp_mark5,
                            '&',
                            1,
                            3)
              INTO   existe
              FROM   DUAL;

            IF existe = 0
            THEN
                sw := 1;
            ELSE
                SELECT   SUBSTR (i.carbol_shp_mark5,
                                 1,
                                 INSTR (i.carbol_shp_mark5, '&') - 1),
                         SUBSTR (i.carbol_shp_mark5,
                                 INSTR (i.carbol_shp_mark5,
                                        '&',
                                        1,
                                        1)
                                 + 1,
                                   INSTR (i.carbol_shp_mark5,
                                          '&',
                                          1,
                                          2)
                                 - INSTR (i.carbol_shp_mark5,
                                          '&',
                                          1,
                                          1)
                                 - 1),
                         SUBSTR (i.carbol_shp_mark5,
                                 INSTR (i.carbol_shp_mark5,
                                        '&',
                                        1,
                                        2)
                                 + 1,
                                   INSTR (i.carbol_shp_mark5,
                                          '&',
                                          1,
                                          3)
                                 - INSTR (i.carbol_shp_mark5,
                                          '&',
                                          1,
                                          2)
                                 - 1),
                         SUBSTR (i.carbol_shp_mark5,
                                 INSTR (i.carbol_shp_mark5,
                                        '&',
                                        1,
                                        3)
                                 + 1,
                                 LENGTH (i.carbol_shp_mark5)
                                 - INSTR (i.carbol_shp_mark5,
                                          '&',
                                          1,
                                          3))
                  INTO   v_keyyear,
                         v_keycuo,
                         v_keydec,
                         v_keynber
                  FROM   DUAL;

                IF v_keydec IS NULL
                THEN
                    SELECT   COUNT (1)
                      INTO   existe
                      FROM   ops$asy.sad_gen g
                     WHERE       g.key_year = v_keyyear
                             AND g.key_cuo = v_keycuo
                             AND g.key_dec = NULL
                             AND g.key_nber = v_keynber
                             AND g.sad_num = 0;
                ELSE
                    SELECT   COUNT (1)
                      INTO   existe
                      FROM   ops$asy.sad_gen g
                     WHERE       g.key_year = v_keyyear
                             AND g.key_cuo = v_keycuo
                             AND g.key_dec = v_keydec
                             AND g.key_nber = v_keynber
                             AND g.sad_num = 0;
                END IF;

                IF existe = 0
                THEN
                    sw := 1;
                END IF;
            END IF;
        END LOOP;

        IF sw = 1
        THEN
            RETURN 2;
        END IF;

        RETURN 0;
    END;

    FUNCTION devuelve_dui (prm_car_reg_year   IN VARCHAR2,
                           prm_key_cuo        IN VARCHAR2,
                           prm_car_reg_nber   IN VARCHAR2)
        RETURN cursortype
    IS
        cr   cursortype;
    BEGIN
        OPEN cr FOR
            SELECT   DISTINCT
                     SUBSTR (b.carbol_shp_mark5,
                             1,
                             INSTR (b.carbol_shp_mark5, '&') - 1),
                     SUBSTR (b.carbol_shp_mark5,
                             INSTR (b.carbol_shp_mark5,
                                    '&',
                                    1,
                                    1)
                             + 1,
                               INSTR (b.carbol_shp_mark5,
                                      '&',
                                      1,
                                      2)
                             - INSTR (b.carbol_shp_mark5,
                                      '&',
                                      1,
                                      1)
                             - 1),
                     SUBSTR (b.carbol_shp_mark5,
                             INSTR (b.carbol_shp_mark5,
                                    '&',
                                    1,
                                    2)
                             + 1,
                               INSTR (b.carbol_shp_mark5,
                                      '&',
                                      1,
                                      3)
                             - INSTR (b.carbol_shp_mark5,
                                      '&',
                                      1,
                                      2)
                             - 1),
                     SUBSTR (b.carbol_shp_mark5,
                             INSTR (b.carbol_shp_mark5,
                                    '&',
                                    1,
                                    3)
                             + 1,
                             LENGTH (b.carbol_shp_mark5)
                             - INSTR (b.carbol_shp_mark5,
                                      '&',
                                      1,
                                      3))
              FROM   ops$asy.car_gen a, ops$asy.car_bol_gen b
             WHERE       a.car_reg_year = prm_car_reg_year
                     AND a.key_cuo = prm_key_cuo
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND a.key_cuo = b.key_cuo
                     AND a.key_voy_nber = b.key_voy_nber
                     AND a.key_dep_date = b.key_dep_date;

        RETURN cr;
    END;

    FUNCTION test_sleep (in_time IN NUMBER)
        RETURN INTEGER
    IS
        v_now   DATE;
    BEGIN
        SELECT   SYSDATE INTO v_now FROM DUAL;

        LOOP
            EXIT WHEN v_now + (in_time * (1 / 86400)) <= SYSDATE;
        END LOOP;

        RETURN 1;
    END;

    PROCEDURE proc_sleep (in_time IN NUMBER)
    IS
        v_now   DATE;
    BEGIN
        SELECT   SYSDATE INTO v_now FROM DUAL;

        LOOP
            EXIT WHEN v_now + (in_time * (1 / 86400)) <= SYSDATE;
        END LOOP;
    END;

    FUNCTION cantidad_docemb_por_tramo (prm_key_cuo        IN VARCHAR2,
                                        prm_key_voy_nber   IN VARCHAR2,
                                        prm_key_dep_date   IN VARCHAR2,
                                        prm_frt_prep       IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (20);
    BEGIN
        SELECT   COUNT (1)
          INTO   res
          FROM   ops$asy.car_bol_gen cb
         WHERE   cb.key_cuo = prm_key_cuo
                 AND cb.key_voy_nber = prm_key_voy_nber
                 AND cb.key_dep_date =
                        TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND cb.carbol_frt_prep = prm_frt_prep;

        RETURN res;
    END;

    FUNCTION lista_docemb_por_tramo (prm_key_year        IN VARCHAR2,
                                     prm_key_cuo         IN VARCHAR2,
                                     prm_key_nber        IN VARCHAR2,
                                     prm_key_secuencia   IN VARCHAR2)
        RETURN cursortype
    IS
        cr   cursortype;
    BEGIN
        OPEN cr FOR
            SELECT   a.tra_cuo_est,
                        a.key_cuo
                     || ' '
                     || a.car_reg_year
                     || ' - '
                     || a.car_reg_nber,
                     cb.key_bol_ref,
                     TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:mi'),
                     cb.carbol_cons_nam,
                     NVL (cb.carbol_shp_mark5, ' ')
              FROM   tra_pla_rut a,
                     ops$asy.car_gen cg,
                     ops$asy.car_bol_gen cb
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_key_year
                     AND a.car_reg_nber = prm_key_nber
                     AND a.key_secuencia = prm_key_secuencia
                     AND a.lst_ope = 'U'
                     AND a.tra_num = 0
                     AND cg.key_cuo = a.key_cuo
                     AND cg.car_reg_year = a.car_reg_year
                     AND cg.car_reg_nber = a.car_reg_nber
                     AND cg.key_cuo = cb.key_cuo
                     AND cg.key_voy_nber = cb.key_voy_nber
                     AND cg.key_dep_date = cb.key_dep_date
                     AND cb.carbol_frt_prep = a.tra_cuo_est;

        RETURN cr;
    END;
END;
/

