CREATE OR REPLACE 
PACKAGE pkg_util
/* Formatted on 25-sep.-2017 18:16:15 (QP5 v5.126) */
IS
    TYPE cursortype IS REF CURSOR;

    FUNCTION asigna_tecnico (prm_sad_reg_year   IN VARCHAR2,
                             prm_key_cuo        IN VARCHAR2,
                             prm_sad_reg_nber   IN VARCHAR2,
                             prm_usuario        IN VARCHAR2)
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
/* Formatted on 26-sep.-2017 12:16:47 (QP5 v5.126) */
IS
    FUNCTION asigna_tecnico (prm_sad_reg_year   IN VARCHAR2,
                             prm_key_cuo        IN VARCHAR2,
                             prm_sad_reg_nber   IN VARCHAR2,
                             prm_usuario        IN VARCHAR2)
        RETURN INTEGER
    IS
        v_res   INTEGER;
    BEGIN
        --ASIGNA TECNICO DE ADUANA
        INSERT INTO tra_pastogrande
          VALUES   (prm_sad_reg_year,
                    prm_key_cuo,
                    prm_sad_reg_nber,
                    prm_usuario,
                    SYSDATE);

        v_res := 0;
        RETURN v_res;
    END;

    FUNCTION verifica_pastogrande (prm_car_reg_year   IN VARCHAR2,
                                   prm_key_cuo        IN VARCHAR2,
                                   prm_car_reg_nber   IN VARCHAR2)
        RETURN INTEGER
    IS
        v_res    INTEGER;
        existe   NUMBER;
        sw       NUMBER;
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
             WHERE       a.car_reg_year = '2017'
                     AND a.key_cuo = '422'
                     AND a.car_reg_nber = '218'
                     AND a.key_cuo = b.key_cuo
                     AND a.key_voy_nber = b.key_voy_nber
                     AND a.key_dep_date = b.key_dep_date)
        LOOP
            IF LENGTH (i.carbol_shp_mark5) < 21
            THEN
                sw := 1;
            ELSE
                SELECT   COUNT (1)
                  INTO   existe
                  FROM   ops$asy.sad_gen g
                 WHERE   g.sad_reg_year = SUBSTR (i.carbol_shp_mark5, 0, 4)
                         AND g.key_cuo = SUBSTR (i.carbol_shp_mark5, 6, 3)
                         AND g.sad_reg_nber =
                                SUBSTR (i.carbol_shp_mark5,
                                        12,
                                        LENGTH (i.carbol_shp_mark5) - 12 - 8)
                         AND g.sad_num = 0;

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
                     SUBSTR (b.carbol_shp_mark5, 0, 4),
                     SUBSTR (b.carbol_shp_mark5, 6, 3),
                     SUBSTR (b.carbol_shp_mark5,
                             12,
                             LENGTH (b.carbol_shp_mark5) - 12 - 8)
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

