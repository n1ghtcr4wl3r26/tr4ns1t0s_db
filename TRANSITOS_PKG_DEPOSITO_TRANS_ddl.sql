CREATE OR REPLACE 
PACKAGE pkg_deposito_trans
/* Formatted on 17/10/2016 20:02:13 (QP5 v5.126) */
IS
    TYPE cursortype IS REF CURSOR;

FUNCTION deposito_cierre ( pkeycuo                IN VARCHAR2,
        pcar_reg_year          IN VARCHAR2,
        pcar_reg_nber          IN NUMBER)
        RETURN cursortype;



    FUNCTION f_graba_lleg_dep_transitorio (
        pkeycuo                IN VARCHAR2,
        pcar_reg_year          IN VARCHAR2,
        pcar_reg_nber          IN NUMBER,
        pcod_dep_transitorio   IN VARCHAR2,
        pnombre_archivo        IN VARCHAR2,
        pdireccion_archivo     IN VARCHAR2,
        pusuario               IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION c_list_aduanas
        RETURN cursortype;

            FUNCTION c_lista_depositos_manif_xnit ( pkeycuo                IN VARCHAR2,
        pcar_reg_year          IN VARCHAR2,
        pcar_reg_nber          IN NUMBER)
        RETURN cursortype;


   FUNCTION c_lista_depositos (prm_nit IN VARCHAR2, prm_razon OUT VARCHAR2, prm_resultado OUT VARCHAR2)
        RETURN cursortype;

    FUNCTION c_lista_depositos_sin_asig
        RETURN cursortype;

    FUNCTION devuelve_deposito(prm_deposito IN VARCHAR2, prm_aduana OUT VARCHAR2, prm_fecini OUT VARCHAR2, prm_fecfin OUT VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION f_graba_deposito_transitorio (prm_consignee      IN VARCHAR2,
                                           prm_cod_deposito   IN VARCHAR2,
                                           prm_resolucion     IN VARCHAR2,
                                           prm_distancia      IN VARCHAR2,
                                           prm_tiempo         IN VARCHAR2,
                                           prm_usuario        IN VARCHAR2)
        RETURN VARCHAR2;


END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_deposito_trans
/* Formatted on 25-oct.-2016 15:55:32 (QP5 v5.126) */
IS
    FUNCTION deposito_cierre (pkeycuo         IN VARCHAR2,
                              pcar_reg_year   IN VARCHAR2,
                              pcar_reg_nber   IN NUMBER)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   n.cmp_cod,
                     n.cmp_nam,
                     d.shd_cod,
                     t.dep_resolucion,
                     TO_CHAR (b.eea_dov, 'dd/mm/yyyy'),
                     NVL (TO_CHAR (b.eea_eov, 'dd/mm/yyyy'), '-'),
                     u.cuo_cod || ':' || u.cuo_nam,
                     t.dep_distancia,
                     t.dep_tiempo,
                     d.arr_nom_archivo,
                     'transitos' || SUBSTR (d.arr_dir_archivo, '41'),
                     TO_CHAR (d.arr_fec_llegada, 'dd/mm/yyyy hh24:mi:ss')
              FROM   transitos.tra_pla_rut a,
                     tra_arr_deposito d,
                     tra_dep_transitorio t,
                     uncuotab u,
                     ops$asy.uncmptab n,
                     ops$asy.unshdtab b
             WHERE       a.key_cuo = pkeycuo
                     AND a.car_reg_year = pcar_reg_year
                     AND a.car_reg_nber = pcar_reg_nber
                     AND a.key_cuo = d.key_cuo
                     AND a.car_reg_year = d.car_reg_year
                     AND a.car_reg_nber = d.car_reg_nber
                     AND a.tra_cuo_est = SUBSTR (d.shd_cod, 1, 3)
                     AND a.key_secuencia > 0
                     AND a.tra_fec_des IS NULL
                     AND a.tra_num = 0
                     AND a.tra_estado = 0
                     AND a.lst_ope = 'U'
                     AND d.arr_num = 0
                     AND d.arr_lstope = 'U'
                     AND t.dep_num = 0
                     AND t.dep_lstope = 'U'
                     AND t.shd_cod = d.shd_cod
                     AND u.lst_ope = 'U'
                     AND t.dep_key_cuo = u.cuo_cod
                     AND n.lst_ope = 'U'
                     AND n.cmp_cod = t.dep_consignee
                     AND b.lst_ope = 'U'
                     AND d.shd_cod = b.shd_cod
                     AND b.eea_dov <= TRUNC (SYSDATE)
                     AND NVL (b.eea_eov, TRUNC (SYSDATE + 1)) >=
                            TRUNC (SYSDATE);

        RETURN ct;
    END;



    --------------------------------------------------------
    --REGISTRA INFORMACION DE LLEGADA A DEPOSITO TRANSITORIO

    FUNCTION f_graba_lleg_dep_transitorio (
        pkeycuo                IN VARCHAR2,
        pcar_reg_year          IN VARCHAR2,
        pcar_reg_nber          IN NUMBER,
        pcod_dep_transitorio   IN VARCHAR2,
        pnombre_archivo        IN VARCHAR2,
        pdireccion_archivo     IN VARCHAR2,
        pusuario               IN VARCHAR2)
        RETURN VARCHAR2
    IS
        v_existe_reg                  NUMBER := 0;
        v_cod_aduana_deptransitorio   NUMBER := 0;
        v_tcierre_trans               NUMBER := 0;
        v_si_aduana_est_entramo       NUMBER := 0;
        v_sicoin                      VARCHAR2 (30);
    BEGIN
        SELECT   COUNT (1)
          INTO   v_existe_reg
          FROM   tra_arr_deposito a
         WHERE       a.key_cuo = pkeycuo
                 AND a.car_reg_year = pcar_reg_year
                 AND a.car_reg_nber = pcar_reg_nber
                 AND a.shd_cod = pcod_dep_transitorio;

        IF (v_existe_reg > 0)
        THEN
            RETURN 'El registro de llegada a dep&oacute;sito transitorio del manifiesto: '
                   || pcar_reg_year
                   || ' '
                   || pkeycuo
                   || ' '
                   || pcar_reg_nber
                   || ' con c&oacute;digo: '
                   || pcod_dep_transitorio
                   || ' ya se encuentra registrado';
        END IF;

        v_cod_aduana_deptransitorio := SUBSTR (pcod_dep_transitorio, 0, 3);

        SELECT   COUNT (1)
          INTO   v_tcierre_trans
          FROM   transitos.tra_pla_rut a
         WHERE       a.key_cuo = pkeycuo
                 AND a.car_reg_year = pcar_reg_year
                 AND a.car_reg_nber = pcar_reg_nber
                 AND a.key_secuencia > 0
                 AND a.tra_fec_des IS NOT NULL
                 AND a.tra_num = 0
                 AND a.tra_estado = 0
                 AND a.lst_ope = 'U';

        IF (v_tcierre_trans > 0)
        THEN
            RETURN    'El manifiesto: '
                   || pcar_reg_year
                   || ' '
                   || pkeycuo
                   || ' '
                   || pcar_reg_nber
                   || ' tiene cierre de tr&aacute;nsito';
        END IF;

        SELECT   COUNT (1)
          INTO   v_si_aduana_est_entramo
          FROM   transitos.tra_pla_rut a
         WHERE       a.key_cuo = pkeycuo
                 AND a.car_reg_year = pcar_reg_year
                 AND a.car_reg_nber = pcar_reg_nber
                 AND a.key_secuencia > 0
                 AND a.tra_cuo_est = v_cod_aduana_deptransitorio --aduana de lelgada estimanda
                 AND a.tra_num = 0
                 AND a.tra_estado = 0
                 AND a.lst_ope = 'U';

        IF (v_si_aduana_est_entramo = 0)
        THEN
            RETURN 'Incompatibilidad entre aduana de destino y aduana del Dep&oacute;sito Transitorio '
                   || pcar_reg_year
                   || ' '
                   || pkeycuo
                   || ' '
                   || pcar_reg_nber;
        END IF;


        SELECT   COUNT (1)
          INTO   v_existe_reg
          FROM   tra_dep_transitorio a, usuario.usuario u
         WHERE       u.usucodusu = pusuario
                 AND a.dep_consignee = u.usuregnit
                 AND u.usu_num = 0
                 AND u.lst_ope = 'U'
                 AND a.shd_cod = pcod_dep_transitorio
                 AND a.dep_num = 0
                 AND a.dep_lstope = 'U';

        IF (v_existe_reg = 0)
        THEN
            RETURN 'Incompatibilidad entre el NIT del Documento de Embarque y el NIT del Dep&oacute;sito Transitorio '
                   || pcar_reg_year
                   || ' '
                   || pkeycuo
                   || ' '
                   || pcar_reg_nber;
        END IF;

        SELECT   COUNT (1)
          INTO   v_existe_reg
          FROM   car_gen a, car_bol_gen b, transitos.tra_pla_rut t
         WHERE       t.key_cuo = pkeycuo
                 AND t.car_reg_year = pcar_reg_year
                 AND t.car_reg_nber = pcar_reg_nber
                 AND a.car_reg_year = t.car_reg_year
                 AND a.car_reg_nber = t.car_reg_nber
                 AND a.key_cuo = b.key_cuo
                 AND a.key_voy_nber = b.key_voy_nber
                 AND a.key_dep_date = b.key_dep_date
                 AND t.key_secuencia > 0
                 AND t.tra_num = 0
                 AND t.tra_estado = 0
                 AND t.lst_ope = 'U';

        IF (v_existe_reg = 0)
        THEN
            RETURN 'El Tr&aacute;nsito no tiene un Documento de Embarque asociado '
                   || pcar_reg_year
                   || ' '
                   || pkeycuo
                   || ' '
                   || pcar_reg_nber;
        END IF;

        IF (v_existe_reg > 1)
        THEN
            RETURN 'Operaci&oacute;n no permitida, el Manifiesto tiene m&aacute;s de un documento de embarque con el mismo destino '
                   || pcar_reg_year
                   || ' '
                   || pkeycuo
                   || ' '
                   || pcar_reg_nber;
        END IF;


        SELECT   COUNT (1)
          INTO   v_existe_reg
          FROM   car_gen a, car_bol_gen b, transitos.tra_pla_rut t
         WHERE       t.key_cuo = pkeycuo
                 AND t.car_reg_year = pcar_reg_year
                 AND t.car_reg_nber = pcar_reg_nber
                 AND a.car_reg_year = t.car_reg_year
                 AND a.car_reg_nber = t.car_reg_nber
                 AND a.key_cuo = b.key_cuo
                 AND a.key_voy_nber = b.key_voy_nber
                 AND a.key_dep_date = b.key_dep_date
                 AND t.key_secuencia > 0
                 AND t.tra_num = 0
                 AND t.tra_estado = 0
                 AND t.lst_ope = 'U'
                 AND NOT b.carbol_shp_mark5 IS NULL
                 AND LENGTH (b.carbol_shp_mark5) > 6;

        IF (v_existe_reg = 0)
        THEN
            RETURN 'El documento de embarque no tiene un n&uacute;mero de SICOIN asociado en la casilla 5ta de marcas y bultos '
                   || pcar_reg_year
                   || ' '
                   || pkeycuo
                   || ' '
                   || pcar_reg_nber;
        END IF;

        SELECT   b.carbol_shp_mark5
          INTO   v_sicoin
          FROM   car_gen a, car_bol_gen b, transitos.tra_pla_rut t
         WHERE       t.key_cuo = pkeycuo
                 AND t.car_reg_year = pcar_reg_year
                 AND t.car_reg_nber = pcar_reg_nber
                 AND a.car_reg_year = t.car_reg_year
                 AND a.car_reg_nber = t.car_reg_nber
                 AND a.key_cuo = b.key_cuo
                 AND a.key_voy_nber = b.key_voy_nber
                 AND a.key_dep_date = b.key_dep_date
                 AND t.key_secuencia > 0
                 AND t.tra_num = 0
                 AND t.tra_estado = 0
                 AND t.lst_ope = 'U'
                 AND NOT b.carbol_shp_mark5 IS NULL
                 AND LENGTH (b.carbol_shp_mark5) > 6;

        IF (SUBSTR (v_sicoin, 5, 3) <> SUBSTR (pcod_dep_transitorio, 1, 3))
        THEN
            RETURN 'La aduana del n&uacute;mero SICOIN, no corresponde con la aduana del Dep&oacute;sito Transitorio '
                   || pcar_reg_year
                   || ' '
                   || pkeycuo
                   || ' '
                   || pcar_reg_nber;
        END IF;


        INSERT INTO tra_arr_deposito (key_cuo,
                                      car_reg_year,
                                      car_reg_nber,
                                      shd_cod,
                                      arr_nom_archivo,
                                      arr_dir_archivo,
                                      arr_fec_llegada,
                                      arr_num,
                                      arr_lstope,
                                      arr_usuario,
                                      arr_fec)
          VALUES   (pkeycuo,
                    pcar_reg_year,
                    pcar_reg_nber,
                    pcod_dep_transitorio,
                    pnombre_archivo,
                    pdireccion_archivo,
                    SYSDATE,
                    0,
                    'U',
                    pusuario,
                    SYSDATE);

        COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    --------------------------------------------------------
    --LISTA ADUANAS
    FUNCTION c_list_aduanas
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   cuo_cod, cuo_nam
                FROM   ops$asy.uncuotab
               WHERE   lst_ope = 'U' AND NOT cuo_cod IN ('ALL', 'CUO01')
            ORDER BY   1;

        RETURN ct;
    END c_list_aduanas;


    FUNCTION c_lista_depositos_manif_xnit (pkeycuo         IN VARCHAR2,
                                           pcar_reg_year   IN VARCHAR2,
                                           pcar_reg_nber   IN NUMBER)
        RETURN cursortype
    IS
        ct           cursortype;
        vnit_manif   VARCHAR2 (100);
    BEGIN
        SELECT   g.carbol_cons_cod
          INTO   vnit_manif
          FROM   ops$asy.car_gen a, car_bol_gen g
         WHERE       a.key_cuo = pkeycuo
                 AND a.car_reg_year = pcar_reg_year
                 AND a.car_reg_nber = pcar_reg_nber
                 AND a.key_cuo = g.key_cuo
                 AND a.key_voy_nber = g.key_voy_nber
                 AND a.key_dep_date = g.key_dep_date;

        OPEN ct FOR
            SELECT   a.shd_cod,
                     a.dep_consignee,
                     a.dep_key_cuo,
                     a.dep_resolucion,
                     a.dep_distancia,
                     a.dep_tiempo,
                     a.dep_num,
                     a.dep_lstope,
                     a.dep_nam,
                     a.dep_fec
              FROM   tra_dep_transitorio a
             WHERE       a.dep_consignee = vnit_manif
                     AND a.dep_num = 0
                     AND a.dep_lstope = 'U';

        RETURN ct;
    END c_lista_depositos_manif_xnit;


    FUNCTION c_lista_depositos (prm_nit         IN     VARCHAR2,
                                prm_razon          OUT VARCHAR2,
                                prm_resultado      OUT VARCHAR2)
        RETURN cursortype
    IS
        ct       cursortype;
        existe   NUMBER (10);
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   uncmptab a
         WHERE   cmp_cod = prm_nit AND lst_ope = 'U';

        IF existe = 0
        THEN
            prm_resultado := 'ERROR';

            OPEN ct FOR SELECT   SYSDATE FROM DUAL;

            RETURN ct;
        ELSE
            SELECT   a.cmp_nam
              INTO   prm_razon
              FROM   uncmptab a
             WHERE   cmp_cod = prm_nit AND lst_ope = 'U' AND ROWNUM = 1;


            SELECT   COUNT (1)
              INTO   existe
              FROM   tra_dep_transitorio a, ops$asy.unshdtab b, uncuotab u
             WHERE       a.dep_num = 0
                     AND a.dep_lstope = 'U'
                     AND b.lst_ope = 'U'
                     AND a.dep_key_cuo = u.cuo_cod
                     AND u.lst_ope = 'U'
                     AND a.shd_cod = b.shd_cod
                     AND b.eea_dov <= TRUNC (SYSDATE)
                     AND NVL (b.eea_eov, TRUNC (SYSDATE + 1)) >=
                            TRUNC (SYSDATE)
                     AND a.dep_consignee = prm_nit;

            IF existe = 0
            THEN
                prm_resultado := 'SINDEP';

                OPEN ct FOR SELECT   SYSDATE FROM DUAL;

                RETURN ct;
            ELSE
                OPEN ct FOR
                    SELECT   b.shd_cod,
                             a.dep_key_cuo,
                             u.cuo_nam,
                             TO_CHAR (b.eea_dov, 'dd/mm/yyyy') fec_ini,
                             NVL (TO_CHAR (b.eea_eov, 'dd/mm/yyyy'), '-')
                                 fec_fin,
                             a.dep_resolucion,
                             a.dep_distancia,
                             a.dep_tiempo
                      FROM   tra_dep_transitorio a,
                             ops$asy.unshdtab b,
                             uncuotab u
                     WHERE       a.dep_num = 0
                             AND a.dep_lstope = 'U'
                             AND b.lst_ope = 'U'
                             AND a.dep_key_cuo = u.cuo_cod
                             AND u.lst_ope = 'U'
                             AND a.shd_cod = b.shd_cod
                             AND b.eea_dov <= TRUNC (SYSDATE)
                             AND NVL (b.eea_eov, TRUNC (SYSDATE + 1)) >=
                                    TRUNC (SYSDATE)
                             AND a.dep_consignee = prm_nit;

                prm_resultado := 'CORRECTO';
            END IF;

            RETURN ct;
        END IF;
    END c_lista_depositos;

    FUNCTION c_lista_depositos_sin_asig
        RETURN cursortype
    IS
        ct       cursortype;
        existe   NUMBER (10);
    BEGIN
        OPEN ct FOR
              SELECT   b.shd_cod,
                          b.shd_cod
                       || ' - '
                       || TO_CHAR (b.eea_dov, 'dd/mm/yyyy')
                       || ' - '
                       || NVL (TO_CHAR (b.eea_eov, 'dd/mm/yyyy'),
                               'Sin Vencimiento')
                FROM   ops$asy.unshdtab b
               WHERE   b.eea_dov <= TRUNC (SYSDATE)
                       AND NVL (b.eea_eov, TRUNC(SYSDATE + 1)) >=
                              TRUNC (SYSDATE)
                       AND b.lst_ope = 'U'
                       AND b.shd_cod LIKE '%TRANS%'
                       AND b.shd_cod NOT IN
                                  (SELECT   b.shd_cod
                                     FROM   tra_dep_transitorio a,
                                            ops$asy.unshdtab b
                                    WHERE       a.dep_num = 0
                                            AND a.dep_lstope = 'U'
                                            AND a.shd_cod = b.shd_cod
                                            AND b.eea_dov <= TRUNC (SYSDATE)
                                            AND NVL (b.eea_eov,
                                                     TRUNC (SYSDATE + 1)) >=
                                                   TRUNC (SYSDATE))
            ORDER BY   1;

        RETURN ct;
    END c_lista_depositos_sin_asig;


    FUNCTION f_graba_deposito_transitorio (prm_consignee      IN VARCHAR2,
                                           prm_cod_deposito   IN VARCHAR2,
                                           prm_resolucion     IN VARCHAR2,
                                           prm_distancia      IN VARCHAR2,
                                           prm_tiempo         IN VARCHAR2,
                                           prm_usuario        IN VARCHAR2)
        RETURN VARCHAR2
    IS
        existe   NUMBER := 0;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_dep_transitorio a
         WHERE   a.shd_cod = prm_cod_deposito AND dep_num = 0;

        IF existe > 0
        THEN
            RETURN 'ERROR EL DEPOSITO TRANSITORIO YA SE ENCUENTRA REGISTRADO';
        ELSE
            SELECT   COUNT (1)
              INTO   existe
              FROM   uncuotab u
             WHERE   u.lst_ope = 'U'
                     AND u.cuo_cod = SUBSTR (prm_cod_deposito, 1, 3);

            IF existe = 0
            THEN
                RETURN 'ERROR LA ADUANA DEL DEPOSITO TRANSITORIO NO ES VALIDA';
            ELSE
                INSERT INTO tra_dep_transitorio (shd_cod,
                                                 dep_consignee,
                                                 dep_key_cuo,
                                                 dep_resolucion,
                                                 dep_distancia,
                                                 dep_tiempo,
                                                 dep_num,
                                                 dep_lstope,
                                                 dep_nam,
                                                 dep_fec)
                  VALUES   (prm_cod_deposito,
                            prm_consignee,
                            SUBSTR (prm_cod_deposito, 1, 3),
                            prm_resolucion,
                            prm_distancia,
                            prm_tiempo,
                            0,
                            'U',
                            prm_usuario,
                            SYSDATE);

                COMMIT;
                RETURN 'CORRECTO';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN 'ERROR'
                   || SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;


    FUNCTION devuelve_deposito (prm_deposito   IN     VARCHAR2,
                                prm_aduana        OUT VARCHAR2,
                                prm_fecini        OUT VARCHAR2,
                                prm_fecfin        OUT VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        SELECT   u.cuo_cod || ':' || u.cuo_nam,
                 TO_CHAR (b.eea_dov, 'dd/mm/yyyy'),
                 NVL (TO_CHAR (b.eea_eov, 'dd/mm/yyyy'), '-')
          INTO   prm_aduana, prm_fecini, prm_fecfin
          FROM   ops$asy.unshdtab b, uncuotab u
         WHERE       b.eea_dov <= TRUNC (SYSDATE)
                 AND NVL (b.eea_eov, TRUNC(SYSDATE + 1)) >= TRUNC (SYSDATE)
                 AND b.shd_cod = prm_deposito
                 AND SUBSTR (b.shd_cod, 1, 3) = u.cuo_cod
                 AND b.lst_ope = 'U'
                 AND u.lst_ope = 'U';

        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'ERROR';
    END;
END;
/

