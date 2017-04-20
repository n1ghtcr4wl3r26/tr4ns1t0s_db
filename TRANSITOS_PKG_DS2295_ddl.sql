CREATE OR REPLACE 
PACKAGE pkg_ds2295

/* Formatted on 13-jun-2016 17:09:46 (QP5 v5.126) */
IS
    TYPE cursortype IS REF CURSOR;

 FUNCTION verifica_enmienda_autprevia (prm_key_cuo        IN VARCHAR2,
/*ADVICE(15): Function with more than one RETURN statement in the
                  executable section [512] */
                                          prm_key_voy_nber   IN VARCHAR2,
                                          prm_key_dep_date   IN VARCHAR2)
/*ADVICE(20): Unreferenced parameter [552] */
        RETURN NUMBER;


    FUNCTION verifica_aduana_autprevia (prm_keycuo IN VARCHAR2,
                                        prm_dato    IN VARCHAR2,
                                        prm_numero IN VARCHAR2,
                                        prm_tipo    IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION c_list_aduanas
        RETURN cursortype;


    FUNCTION c_list_partidas (p_tipo IN VARCHAR2)
        RETURN cursortype;



    FUNCTION verifica_aut (
        p_key_cuo        IN ops$asy.car_bol_gen.key_cuo%TYPE,
        p_key_voy_nber   IN ops$asy.car_bol_gen.key_voy_nber%TYPE,
        p_key_dep_date   IN VARCHAR2,
        p_key_bol_ref    IN ops$asy.car_bol_gen.key_bol_ref%TYPE)
        RETURN VARCHAR2;
 FUNCTION devuelve_autprevia (
        p_key_cuo        IN ops$asy.car_bol_gen.key_cuo%TYPE,
        p_key_voy_nber   IN ops$asy.car_bol_gen.key_voy_nber%TYPE,
        p_key_dep_date   IN VARCHAR2,
        p_key_bol_ref    IN ops$asy.car_bol_gen.key_bol_ref%TYPE)
        RETURN VARCHAR2;

    FUNCTION c_list_docembq (
        p_key_voy_nber_ref   IN ops$asy.car_gen.key_voy_nber%TYPE,
        p_man_aduana_ref     IN ops$asy.car_gen.key_cuo%TYPE,
        p_key_dep_date_ref   IN VARCHAR2,
        p_man_gestion_reg    IN ops$asy.car_gen.car_reg_year%TYPE,
        p_man_aduana_reg     IN ops$asy.car_gen.key_cuo%TYPE,
        p_man_numero_reg     IN ops$asy.car_gen.car_reg_nber%TYPE,
        p_tipo               IN VARCHAR2)
        RETURN cursortype;

    --Verifica si el destino es zona franca
    FUNCTION verifica_destino_zf (
        p_key_voy_nber_ref   IN ops$asy.car_gen.key_voy_nber%TYPE,
        p_man_aduana_ref     IN ops$asy.car_gen.key_cuo%TYPE,
        p_key_dep_date_ref   IN VARCHAR2,
        p_man_gestion_reg    IN ops$asy.car_gen.car_reg_year%TYPE,
        p_man_aduana_reg     IN ops$asy.car_gen.key_cuo%TYPE,
        p_man_numero_reg     IN ops$asy.car_gen.car_reg_nber%TYPE,
        p_tipo               IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION f_existe_manifiesto (
        p_key_voy_nber_ref    IN     ops$asy.car_gen.key_voy_nber%TYPE,
        p_man_aduana_ref      IN     ops$asy.car_gen.key_cuo%TYPE,
        p_key_dep_date_ref    IN     VARCHAR2,
        p_man_gestion_reg     IN     ops$asy.car_gen.car_reg_year%TYPE,
        p_man_aduana_reg      IN     ops$asy.car_gen.key_cuo%TYPE,
        p_man_numero_reg      IN     ops$asy.car_gen.car_reg_nber%TYPE,
        p_tipo                IN     VARCHAR2,
        ps_key_voy_nber_ref      OUT ops$asy.car_gen.key_voy_nber%TYPE,
        ps_man_aduana_ref        OUT ops$asy.car_gen.key_cuo%TYPE,
        ps_key_dep_date_ref      OUT VARCHAR2)
        RETURN VARCHAR2;

     -----------------------------------------------------------------------------
    -- Verifica si existe manifiesto
    -----------------------------------------------------------------------------
    FUNCTION fe_existe_manifiesto (
        p_key_voy_nber_ref    IN     ops$asy.car_gen.key_voy_nber%TYPE,
        p_man_aduana_ref      IN     ops$asy.car_gen.key_cuo%TYPE,
        p_key_dep_date_ref    IN     VARCHAR2,
        p_man_gestion_reg     IN     ops$asy.car_gen.car_reg_year%TYPE,
        p_man_aduana_reg      IN     ops$asy.car_gen.key_cuo%TYPE,
        p_man_numero_reg      IN     ops$asy.car_gen.car_reg_nber%TYPE,
        p_tipo                IN     VARCHAR2,
        ps_key_voy_nber_ref      OUT ops$asy.car_gen.key_voy_nber%TYPE,
        ps_man_aduana_ref        OUT ops$asy.car_gen.key_cuo%TYPE,
        ps_key_dep_date_ref      OUT VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION graba_autorizacion_previa (prm_key_cuo        IN VARCHAR2,
                                        prm_key_voy_nber   IN VARCHAR2,
                                        prm_key_dep_date   IN VARCHAR2,
                                        prm_key_bol_ref    IN VARCHAR2,
                                        prm_chds2600       IN VARCHAR2,
                                        prm_valds2600      IN VARCHAR2,
                                        prm_chds2657       IN VARCHAR2,
                                        prm_valds2657      IN VARCHAR2,
                                        prm_chds2751       IN VARCHAR2,
                                        prm_valds2751      IN VARCHAR2,
                                        prm_chds2752       IN VARCHAR2,
                                        prm_valds2752      IN VARCHAR2,
                                        prm_chds2752can    IN VARCHAR2,
                                        prm_valds2752can   IN VARCHAR2,
                                        prm_chninguno      IN VARCHAR2,
                                        prm_usuario        IN VARCHAR2,
                                        prm_observacion    IN VARCHAR2,
                                        prm_chds2865       IN VARCHAR2,
                                        prm_valds2865      IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION graba_docemb (prm_key_cuo                    IN VARCHAR2,
                           prm_key_voy_nber               IN VARCHAR2,
                           prm_key_dep_date               IN VARCHAR2,
                           prm_key_bol_ref                IN VARCHAR2,
                           prm_docemb_fecha_embarque      IN VARCHAR2,
                           prm_docemb_silista_rs1392015   IN VARCHAR2,
                           prm_docemb_si_pri_rs1692016    IN VARCHAR2,
                           prm_docemb_si_seg_rs1692016    IN VARCHAR2,
                           prm_docemb_otras_mercancias    IN VARCHAR2,
                           prm_docemb_cantidad_partidas   IN VARCHAR2,
                           prm_usuario                    IN VARCHAR2)
        RETURN VARCHAR2;

FUNCTION graba_docemb_enmienda (prm_key_cuo                    IN VARCHAR2,
                           prm_key_voy_nber               IN VARCHAR2,
                           prm_key_dep_date               IN VARCHAR2,
                           prm_key_bol_ref                IN VARCHAR2,
                           prm_docemb_fecha_embarque      IN VARCHAR2,
                           prm_docemb_silista_rs1392015   IN VARCHAR2,
                           prm_docemb_si_pri_rs1692016    IN VARCHAR2,
                           prm_docemb_si_seg_rs1692016    IN VARCHAR2,
                           prm_docemb_otras_mercancias    IN VARCHAR2,
                           prm_docemb_cantidad_partidas   IN VARCHAR2,
                           prm_usuario                    IN VARCHAR2,
                           prm_observacion2295            IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION graba_docemb2 (prm_key_cuo                 IN VARCHAR2,
                            prm_key_voy_nber            IN VARCHAR2,
                            prm_key_dep_date            IN VARCHAR2,
                            prm_key_bol_ref             IN VARCHAR2,
                            prm_docemb_fecha_embarque   IN VARCHAR2,
                            prm_usuario                 IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION graba_man_autorizado (prm_key_cuo        IN VARCHAR2,
                                   prm_key_voy_nber   IN VARCHAR2,
                                   prm_key_dep_date   IN VARCHAR2,
                                   prm_cantidad       IN VARCHAR2,
                                   prm_usuario        IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION graba_man_sidunea (pr_key_cuo        IN VARCHAR2,
                                pr_key_voy_nber   IN VARCHAR2,
                                pr_key_dep_date   IN VARCHAR2,
                                pr_estado         IN VARCHAR2)
        RETURN VARCHAR2;
END;                                                           -- Package spec
/

CREATE OR REPLACE 
PACKAGE BODY pkg_ds2295

/* Formatted on 14/06/2016 16:18:03 (QP5 v5.126) */
IS
    --
    -- To modify this template, edit file PKGBODY.TXT in TEMPLATE
    -- directory of SQL Navigator
    --
    -- Purpose: Briefly explain the functionality of the package body
    --
    -- MODIFICATION HISTORY
    -- Person      Date    Comments
    -----------------------------------------------------------------------------
    -- LISTADO DE ADUANA
    -----------------------------------------------------------------------------
    FUNCTION verifica_enmienda_autprevia (prm_key_cuo        IN VARCHAR2,
                                          prm_key_voy_nber   IN VARCHAR2,
                                          prm_key_dep_date   IN VARCHAR2)
        RETURN NUMBER
    IS
        hay              NUMBER (10) := 0;
        tipoman          VARCHAR2 (5) := '0';
        v_reg_year       VARCHAR2 (5);
        v_reg_nber       NUMBER (18);
        v_key_cuo        VARCHAR2 (5);
        v_key_voy_nber   VARCHAR2 (30);
        v_key_dep_date   DATE;
    BEGIN
        --  0 QUE PUEDE REALIZAR LA ENMIENDA PQ NO ESTA ASOCIADO A NINGUNA DUI
        --  1 QUE NO PUEDE REALIZAR LA ENMIENDA PQ ESTA ASOCIADO A UNA DUI

        SELECT   COUNT (1)
          INTO   hay
          FROM   ops$asy.car_bol_gen a
         WHERE   a.key_cuo = prm_key_cuo
                 AND a.key_voy_nber = prm_key_voy_nber
                 AND a.key_dep_date =
                        TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND ROWNUM = 1;

        IF hay = 0
        THEN
            RETURN 1;
        ELSE
            SELECT   a.carbol_nat_cod
              INTO   tipoman
              FROM   ops$asy.car_bol_gen a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND ROWNUM = 1;

            IF (tipoman = '24')
            THEN
                --si es tipo 24 encontramos al manifiesto 23
                SELECT   a.car_reg_year, a.car_reg_nber
                  INTO   v_reg_year, v_reg_nber
                  FROM   car_gen a
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy');

                --verificamos que tenga un manifiesto 23
                SELECT   COUNT (1)
                  INTO   hay
                  FROM   car_gen a
                 WHERE   a.key_voy_nber =
                             'GRM' || v_reg_year || '-' || v_reg_nber;

                IF hay = 0
                THEN
                    --No tiene manifiesto 23, se asume que no tiene DUI asociada
                    RETURN 0;
                ELSE
                    --devolver el manifiesto 23
                    SELECT   a.key_cuo, a.key_voy_nber, a.key_dep_date
                      INTO   v_key_cuo, v_key_voy_nber, v_key_dep_date
                      FROM   car_gen a
                     WHERE   a.key_voy_nber =
                                 'GRM' || v_reg_year || '-' || v_reg_nber;

                    --verificamos que el manifiesto 23, no tenga ninguna asociacion de DUI
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   car_bol_ope a
                     WHERE       a.key_cuo = v_key_cuo
                             AND a.key_voy_nber = v_key_voy_nber
                             AND a.key_dep_date = v_key_dep_date
                             AND a.car_ass_ser = 'L';

                    IF hay = 0
                    THEN
                        RETURN 0;
                    ELSE
                        RETURN 1;
                    END IF;
                END IF;
            ELSE
                IF (tipoman = '23')
                THEN
                    v_key_cuo := prm_key_cuo;
                    v_key_voy_nber := prm_key_voy_nber;
                    v_key_dep_date := TO_DATE (prm_key_dep_date, 'dd/mm/yyyy');

                    -- como el manifiesto es tipo 23, verificamos directamente que no tenga nonguna asociacion de DUI
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   car_bol_ope a
                     WHERE       a.key_cuo = v_key_cuo
                             AND a.key_voy_nber = v_key_voy_nber
                             AND a.key_dep_date = v_key_dep_date
                             AND a.car_ass_ser = 'L';

                    IF hay = 0
                    THEN
                        RETURN 0;
                    ELSE
                        RETURN 1;
                    END IF;
                ELSE
                    RETURN 1;
                END IF;
            END IF;
        END IF;
    END;



    FUNCTION verifica_aduana_autprevia (prm_keycuo   IN VARCHAR2,
                                        prm_dato     IN VARCHAR2,
                                        prm_numero   IN VARCHAR2,
                                        prm_tipo     IN VARCHAR2)
        RETURN NUMBER
    IS
        hay       NUMBER (10) := 0;
        existe    NUMBER (10) := 0;
        tipoman   VARCHAR2 (5) := '20';
    BEGIN
        IF prm_keycuo = '722'
        THEN
            IF UPPER (prm_tipo) = 'REF'
            THEN
                SELECT   a.carbol_nat_cod
                  INTO   tipoman
                  FROM   ops$asy.car_bol_gen a
                 WHERE   a.key_cuo = prm_keycuo
                         AND a.key_voy_nber = prm_numero
                         AND a.key_dep_date =
                                TO_DATE (prm_dato, 'dd/mm/yyyy')
                         AND ROWNUM = 1;
            ELSE
                SELECT   a.carbol_nat_cod
                  INTO   tipoman
                  FROM   ops$asy.car_bol_gen a, ops$asy.car_gen b
                 WHERE       a.key_cuo = b.key_cuo
                         AND a.key_voy_nber = b.key_voy_nber
                         AND a.key_dep_date = b.key_dep_date
                         AND b.car_reg_year = prm_dato
                         AND b.car_reg_nber = prm_numero
                         AND b.key_cuo = prm_keycuo
                         AND ROWNUM = 1;
            END IF;

            IF (tipoman = '23')
            THEN
                hay := 1;
            ELSE
                hay := 0;
            END IF;
        ELSE
            -- SELECT   COUNT (1)
            --   INTO   existe
            --   FROM   uncuoaut_previa a
            --  WHERE   a.key_cuo = prm_keycuo AND a.lst_ope = 'U';


            SELECT   COUNT (1)
              INTO   existe
              FROM   uncuotab a
             WHERE   a.cuo_cod = prm_keycuo AND a.lst_ope = 'U'
                     AND (SUBSTR (a.cuo_cod, 2, 1) = 4
                          OR SUBSTR (a.cuo_cod, 2, 1) = 2)
                     AND NOT a.cuo_cod IN
                                     ('221',
                                      '241',
                                      '243',
                                      '421',
                                      '422',
                                      '521',
                                      '522',
                                      '641',
                                      '642',
                                      '621',
                                      '623',
                                      '721');

            IF existe = 0
            THEN
                hay := 0;
            ELSE
                hay := 1;
            END IF;
        END IF;

        RETURN hay;
    END;

    FUNCTION c_list_partidas (p_tipo IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        IF (p_tipo = '1')
        THEN
            OPEN ct FOR
                  SELECT   DISTINCT a.hs8_cod || a.hsprec_cod, b.tar_dsc
                    FROM   ops$asy.untards2295 a, ops$asy.untartab b
                   WHERE   a.hs8_cod || a.hsprec_cod =
                               b.hs6_cod || b.tar_pr1 || b.tar_pr2
                           AND a.lst_ope = 'U'
                           AND a.lst_ope = b.lst_ope
                           --   AND TRUNC (SYSDATE) BETWEEN a.fec_ini
                           --                         AND  NVL (a.fec_ven, TRUNC(sysdate))
                           AND TRUNC (SYSDATE) BETWEEN b.eea_dov
                                                   AND  NVL (b.eea_eov,
                                                             TRUNC (SYSDATE))
                           --2
                           --and a.fec_ini=to_date('01/02/2016','dd/mm/yyyy')
                           -- 3tra
                           --and a.fec_ini=to_date('06/06/2016','dd/mm/yyyy')
                           AND a.fec_ini NOT IN
                                      (TO_DATE ('06/06/2016', 'dd/mm/yyyy'),
                                       TO_DATE ('01/02/2016', 'dd/mm/yyyy'))
                ORDER BY   1;
        END IF;

        IF (p_tipo = '2')
        THEN
            OPEN ct FOR
                  SELECT   DISTINCT a.hs8_cod || a.hsprec_cod, b.tar_dsc
                    FROM   ops$asy.untards2295 a, ops$asy.untartab b
                   WHERE   a.hs8_cod || a.hsprec_cod =
                               b.hs6_cod || b.tar_pr1 || b.tar_pr2
                           AND a.lst_ope = 'U'
                           AND a.lst_ope = b.lst_ope
                           --  AND TRUNC (SYSDATE) BETWEEN a.fec_ini
                           --                         AND  NVL (a.fec_ven, TRUNC(sysdate))
                           AND TRUNC (SYSDATE) BETWEEN b.eea_dov
                                                   AND  NVL (b.eea_eov,
                                                             TRUNC (SYSDATE))
                           AND a.fec_ini = TO_DATE ('01/02/2016', 'dd/mm/yyyy')
                ORDER BY   1;
        END IF;

        IF (p_tipo = '3')
        THEN
            OPEN ct FOR
                  SELECT   DISTINCT a.hs8_cod || a.hsprec_cod, b.tar_dsc
                    FROM   ops$asy.untards2295 a, ops$asy.untartab b
                   WHERE   a.hs8_cod || a.hsprec_cod =
                               b.hs6_cod || b.tar_pr1 || b.tar_pr2
                           AND a.lst_ope = 'U'
                           AND a.lst_ope = b.lst_ope
                           --   AND TRUNC (SYSDATE) BETWEEN a.fec_ini
                           --                       AND  NVL (a.fec_ven, TRUNC(sysdate))
                           AND TRUNC (SYSDATE) BETWEEN b.eea_dov
                                                   AND  NVL (b.eea_eov,
                                                             TRUNC (SYSDATE))
                           AND a.fec_ini = TO_DATE ('06/06/2016', 'dd/mm/yyyy')
                ORDER BY   1;
        END IF;

        RETURN ct;
    END c_list_partidas;


    FUNCTION c_list_aduanas
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   DISTINCT cuo_cod, cuo_nam
              FROM   ops$asy.untards2295 a, ops$asy.uncuotab b
             WHERE       a.lst_ope = 'U'
                     AND a.key_cuo = b.cuo_cod
                     AND b.lst_ope = 'U'
            UNION
            SELECT   cuo_cod, cuo_nam
              FROM   ops$asy.uncuotab a
             WHERE   a.cuo_cod IN ('071', '072', '243', '623', '522', '722')
                     AND a.lst_ope = 'U'
            UNION
            SELECT   cuo_cod, cuo_nam
              FROM   uncuotab a
             WHERE   a.lst_ope = 'U'
                     AND (SUBSTR (a.cuo_cod, 2, 1) = '4'
                          OR SUBSTR (a.cuo_cod, 2, 1) = '2')
            --  SELECT   a.key_cuo, b.cuo_nam
            --    FROM   transitos.uncuoaut_previa a, ops$asy.uncuotab b
            --   WHERE       a.key_cuo = b.cuo_cod
            --           AND a.lst_ope = 'U'
            --           AND b.lst_ope = 'U'
            ORDER BY   1;

        RETURN ct;
    END c_list_aduanas;

    -----------------------------------------------------------------------------
    -- GUARDA DOCUMENTO DE EMBARQUE
    -----------------------------------------------------------------------------

    FUNCTION graba_autorizacion_previa (prm_key_cuo        IN VARCHAR2,
                                        prm_key_voy_nber   IN VARCHAR2,
                                        prm_key_dep_date   IN VARCHAR2,
                                        prm_key_bol_ref    IN VARCHAR2,
                                        prm_chds2600       IN VARCHAR2,
                                        prm_valds2600      IN VARCHAR2,
                                        prm_chds2657       IN VARCHAR2,
                                        prm_valds2657      IN VARCHAR2,
                                        prm_chds2751       IN VARCHAR2,
                                        prm_valds2751      IN VARCHAR2,
                                        prm_chds2752       IN VARCHAR2,
                                        prm_valds2752      IN VARCHAR2,
                                        prm_chds2752can    IN VARCHAR2,
                                        prm_valds2752can   IN VARCHAR2,
                                        prm_chninguno      IN VARCHAR2,
                                        prm_usuario        IN VARCHAR2,
                                        prm_observacion    IN VARCHAR2,
                                        prm_chds2865       IN VARCHAR2,
                                        prm_valds2865      IN VARCHAR2)
        RETURN VARCHAR2
    IS
        cont      NUMBER;
        hay       NUMBER;
        version   NUMBER;
    BEGIN
        --verificar si esta marcado la opcion de ninguno
        IF (UPPER (prm_chninguno) = 'ON')
        THEN
            --verificamos si existe el registro
            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = prm_key_bol_ref
                     AND a.apr_ds_autorizacion = 'NINGUNO';

            IF hay = 0
            THEN
                --sino existe insertamos la primera version
                INSERT INTO tra_aut_previa
                  VALUES   (prm_key_cuo,
                            prm_key_voy_nber,
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                            prm_key_bol_ref,
                            'NINGUNO',
                            '',
                            prm_usuario,
                            0,
                            'U',
                            SYSDATE);
            ELSE
                --si existe versionamos, como esta marcado actualizamos la version del registro a U
                INSERT INTO tra_aut_previa
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.apr_ds_autorizacion,
                             a.apr_nro_autorizacion,
                             a.apr_usuario,
                             hay,
                             a.apr_lstope,
                             a.apr_fecreg
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'NINGUNO'
                             AND a.apr_num = 0;

                UPDATE   tra_aut_previa a
                   SET   a.apr_usuario = prm_usuario,
                         a.apr_lstope = 'U',
                         a.apr_fecreg = SYSDATE
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.key_bol_ref = prm_key_bol_ref
                         AND a.apr_ds_autorizacion = 'NINGUNO'
                         AND a.apr_num = 0;
            END IF;

            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = prm_key_bol_ref
                     AND a.apr_ds_autorizacion = 'DS2600';

            --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
            IF hay > 0
            THEN
                INSERT INTO tra_aut_previa
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.apr_ds_autorizacion,
                             a.apr_nro_autorizacion,
                             a.apr_usuario,
                             hay,
                             a.apr_lstope,
                             a.apr_fecreg
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2600'
                             AND a.apr_num = 0;

                UPDATE   tra_aut_previa a
                   SET   a.apr_nro_autorizacion = '',
                         a.apr_usuario = prm_usuario,
                         a.apr_lstope = 'D',
                         a.apr_fecreg = SYSDATE
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.key_bol_ref = prm_key_bol_ref
                         AND a.apr_ds_autorizacion = 'DS2600'
                         AND a.apr_num = 0;
            END IF;

            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = prm_key_bol_ref
                     AND a.apr_ds_autorizacion = 'DS2657';

            --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
            IF hay > 0
            THEN
                INSERT INTO tra_aut_previa
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.apr_ds_autorizacion,
                             a.apr_nro_autorizacion,
                             a.apr_usuario,
                             hay,
                             a.apr_lstope,
                             a.apr_fecreg
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2657'
                             AND a.apr_num = 0;

                UPDATE   tra_aut_previa a
                   SET   a.apr_nro_autorizacion = '',
                         a.apr_usuario = prm_usuario,
                         a.apr_lstope = 'D',
                         a.apr_fecreg = SYSDATE
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.key_bol_ref = prm_key_bol_ref
                         AND a.apr_ds_autorizacion = 'DS2657'
                         AND a.apr_num = 0;
            END IF;

            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = prm_key_bol_ref
                     AND a.apr_ds_autorizacion = 'DS2751';

            --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
            IF hay > 0
            THEN
                INSERT INTO tra_aut_previa
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.apr_ds_autorizacion,
                             a.apr_nro_autorizacion,
                             a.apr_usuario,
                             hay,
                             a.apr_lstope,
                             a.apr_fecreg
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2751'
                             AND a.apr_num = 0;

                UPDATE   tra_aut_previa a
                   SET   a.apr_nro_autorizacion = '',
                         a.apr_usuario = prm_usuario,
                         a.apr_lstope = 'D',
                         a.apr_fecreg = SYSDATE
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.key_bol_ref = prm_key_bol_ref
                         AND a.apr_ds_autorizacion = 'DS2751'
                         AND a.apr_num = 0;
            END IF;

            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = prm_key_bol_ref
                     AND a.apr_ds_autorizacion = 'DS2752';

            --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
            IF hay > 0
            THEN
                INSERT INTO tra_aut_previa
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.apr_ds_autorizacion,
                             a.apr_nro_autorizacion,
                             a.apr_usuario,
                             hay,
                             a.apr_lstope,
                             a.apr_fecreg
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2752'
                             AND a.apr_num = 0;

                UPDATE   tra_aut_previa a
                   SET   a.apr_nro_autorizacion = '',
                         a.apr_usuario = prm_usuario,
                         a.apr_lstope = 'D',
                         a.apr_fecreg = SYSDATE
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.key_bol_ref = prm_key_bol_ref
                         AND a.apr_ds_autorizacion = 'DS2752'
                         AND a.apr_num = 0;
            END IF;

            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = prm_key_bol_ref
                     AND a.apr_ds_autorizacion = 'DS2752CAN';

            --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
            IF hay > 0
            THEN
                INSERT INTO tra_aut_previa
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.apr_ds_autorizacion,
                             a.apr_nro_autorizacion,
                             a.apr_usuario,
                             hay,
                             a.apr_lstope,
                             a.apr_fecreg
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2752CAN'
                             AND a.apr_num = 0;

                UPDATE   tra_aut_previa a
                   SET   a.apr_nro_autorizacion = '',
                         a.apr_usuario = prm_usuario,
                         a.apr_lstope = 'D',
                         a.apr_fecreg = SYSDATE
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.key_bol_ref = prm_key_bol_ref
                         AND a.apr_ds_autorizacion = 'DS2752CAN'
                         AND a.apr_num = 0;
            END IF;

            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = prm_key_bol_ref
                     AND a.apr_ds_autorizacion = 'DS2865';

            --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
            IF hay > 0
            THEN
                INSERT INTO tra_aut_previa
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.apr_ds_autorizacion,
                             a.apr_nro_autorizacion,
                             a.apr_usuario,
                             hay,
                             a.apr_lstope,
                             a.apr_fecreg
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2865'
                             AND a.apr_num = 0;

                UPDATE   tra_aut_previa a
                   SET   a.apr_nro_autorizacion = '',
                         a.apr_usuario = prm_usuario,
                         a.apr_lstope = 'D',
                         a.apr_fecreg = SYSDATE
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.key_bol_ref = prm_key_bol_ref
                         AND a.apr_ds_autorizacion = 'DS2865'
                         AND a.apr_num = 0;
            END IF;

        ELSE
            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = prm_key_bol_ref
                     AND a.apr_ds_autorizacion = 'NINGUNO';

            --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
            IF hay > 0
            THEN
                INSERT INTO tra_aut_previa
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.apr_ds_autorizacion,
                             a.apr_nro_autorizacion,
                             a.apr_usuario,
                             hay,
                             a.apr_lstope,
                             a.apr_fecreg
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'NINGUNO'
                             AND a.apr_num = 0;

                UPDATE   tra_aut_previa a
                   SET   a.apr_usuario = prm_usuario,
                         a.apr_lstope = 'D',
                         a.apr_fecreg = SYSDATE
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.key_bol_ref = prm_key_bol_ref
                         AND a.apr_ds_autorizacion = 'NINGUNO'
                         AND a.apr_num = 0;
            END IF;

            --verificamos si el destino del documento de embarque tiene como destino una zona franca
            SELECT   COUNT (1)
              INTO   cont
              FROM   ops$asy.car_bol_gen b
             WHERE   b.key_cuo = prm_key_cuo
                     AND b.key_voy_nber = prm_key_voy_nber
                     AND b.key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND b.key_bol_ref = prm_key_bol_ref
                     AND b.carbol_frt_prep IN
                                (SELECT   cuo_cod
                                   FROM   ops$asy.uncuotab u
                                  WHERE   SUBSTR (u.cuo_cod, 2, 1) = '3'
                                          AND u.cuo_cod not in ('737','738','736','234','432','232','332','931')
                                          AND u.lst_ope = 'U');

            --si tiene destino una zona franca, no puede realizar el registro de ninguna autorizacion previa
            IF (cont > 0)
            THEN
                RETURN    'EL DOCUMENTO DE EMBARQUE '
                       || prm_key_cuo
                       || ' '
                       || prm_key_voy_nber
                       || ' '
                       || prm_key_dep_date
                       || ' '
                       || prm_key_bol_ref
                       || ' NO PUEDE TENER DESTINO UNA ZONA FRANCA';
            ELSE
                --si no tiene destino una zona franca, puede registrar una autorizacion previa
                IF (UPPER (prm_chds2600) = 'ON')
                THEN
                    --verificamos si existe el registro con DS2600
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2600';

                    IF hay = 0
                    THEN
                        --sino existe insertamos la primera version
                        INSERT INTO tra_aut_previa
                          VALUES   (prm_key_cuo,
                                    prm_key_voy_nber,
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                                    prm_key_bol_ref,
                                    'DS2600',
                                    prm_valds2600,
                                    prm_usuario,
                                    0,
                                    'U',
                                    SYSDATE);
                    ELSE
                        --si existe versionamos, como esta marcado actualizamos la version del registro a U
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2600'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = prm_valds2600,
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'U',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2600'
                                 AND a.apr_num = 0;
                    END IF;
                ELSE
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2600';

                    --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
                    IF hay > 0
                    THEN
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2600'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = '',
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'D',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2600'
                                 AND a.apr_num = 0;
                    END IF;
                END IF;

                IF (UPPER (prm_chds2657) = 'ON')
                THEN
                    --verificamos si existe el registro con DS2657
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2657';

                    IF hay = 0
                    THEN
                        --sino existe insertamos la primera version
                        INSERT INTO tra_aut_previa
                          VALUES   (prm_key_cuo,
                                    prm_key_voy_nber,
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                                    prm_key_bol_ref,
                                    'DS2657',
                                    prm_valds2657,
                                    prm_usuario,
                                    0,
                                    'U',
                                    SYSDATE);
                    ELSE
                        --si existe versionamos, como esta marcado actualizamos la version del registro a U
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2657'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = prm_valds2657,
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'U',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2657'
                                 AND a.apr_num = 0;
                    END IF;
                ELSE
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2657';

                    --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
                    IF hay > 0
                    THEN
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2657'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = '',
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'D',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2657'
                                 AND a.apr_num = 0;
                    END IF;
                END IF;

                IF (UPPER (prm_chds2751) = 'ON')
                THEN
                    --verificamos si existe el registro con DS2751
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2751';

                    IF hay = 0
                    THEN
                        --sino existe insertamos la primera version
                        INSERT INTO tra_aut_previa
                          VALUES   (prm_key_cuo,
                                    prm_key_voy_nber,
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                                    prm_key_bol_ref,
                                    'DS2751',
                                    prm_valds2751,
                                    prm_usuario,
                                    0,
                                    'U',
                                    SYSDATE);
                    ELSE
                        --si existe versionamos, como esta marcado actualizamos la version del registro a U
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2751'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = prm_valds2751,
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'U',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2751'
                                 AND a.apr_num = 0;
                    END IF;
                ELSE
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2751';

                    --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
                    IF hay > 0
                    THEN
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2751'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = '',
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'D',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2751'
                                 AND a.apr_num = 0;
                    END IF;
                END IF;

                IF (UPPER (prm_chds2752) = 'ON')
                THEN
                    --verificamos si existe el registro con DS2752
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2752';

                    IF hay = 0
                    THEN
                        --sino existe insertamos la primera version
                        INSERT INTO tra_aut_previa
                          VALUES   (prm_key_cuo,
                                    prm_key_voy_nber,
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                                    prm_key_bol_ref,
                                    'DS2752',
                                    prm_valds2752,
                                    prm_usuario,
                                    0,
                                    'U',
                                    SYSDATE);
                    ELSE
                        --si existe versionamos, como esta marcado actualizamos la version del registro a U
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2752'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = prm_valds2752,
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'U',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2752'
                                 AND a.apr_num = 0;
                    END IF;
                ELSE
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2752';

                    --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
                    IF hay > 0
                    THEN
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2752'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = '',
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'D',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2752'
                                 AND a.apr_num = 0;
                    END IF;
                END IF;

                IF (UPPER (prm_chds2865) = 'ON')
                THEN
                    --verificamos si existe el registro con DS2865
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2865';

                    IF hay = 0
                    THEN
                        --sino existe insertamos la primera version
                        INSERT INTO tra_aut_previa
                          VALUES   (prm_key_cuo,
                                    prm_key_voy_nber,
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                                    prm_key_bol_ref,
                                    'DS2865',
                                    prm_valds2865,
                                    prm_usuario,
                                    0,
                                    'U',
                                    SYSDATE);
                    ELSE
                        --si existe versionamos, como esta marcado actualizamos la version del registro a U
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2865'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = prm_valds2865,
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'U',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2865'
                                 AND a.apr_num = 0;
                    END IF;
                ELSE
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2865';

                    --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
                    IF hay > 0
                    THEN
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2865'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = '',
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'D',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2865'
                                 AND a.apr_num = 0;
                    END IF;
                END IF;


                IF (UPPER (prm_chds2752can) = 'ON')
                THEN
                    --verificamos si existe el registro con DS2752CAN
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2752CAN';

                    IF hay = 0
                    THEN
                        --sino existe insertamos la primera version
                        INSERT INTO tra_aut_previa
                          VALUES   (prm_key_cuo,
                                    prm_key_voy_nber,
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                                    prm_key_bol_ref,
                                    'DS2752CAN',
                                    '',
                                    prm_usuario,
                                    0,
                                    'U',
                                    SYSDATE);
                    ELSE
                        --si existe versionamos, como esta marcado actualizamos la version del registro a U
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2752CAN'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = '',
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'U',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2752CAN'
                                 AND a.apr_num = 0;
                    END IF;
                ELSE
                    SELECT   COUNT (1)
                      INTO   hay
                      FROM   tra_aut_previa a
                     WHERE   a.key_cuo = prm_key_cuo
                             AND a.key_voy_nber = prm_key_voy_nber
                             AND a.key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND a.key_bol_ref = prm_key_bol_ref
                             AND a.apr_ds_autorizacion = 'DS2752CAN';

                    --si el registro existe, como la opcion ninguno estaba desahabilitada debemos colocar D en el stado del registro
                    IF hay > 0
                    THEN
                        INSERT INTO tra_aut_previa
                            SELECT   a.key_cuo,
                                     a.key_voy_nber,
                                     a.key_dep_date,
                                     a.key_bol_ref,
                                     a.apr_ds_autorizacion,
                                     a.apr_nro_autorizacion,
                                     a.apr_usuario,
                                     hay,
                                     a.apr_lstope,
                                     a.apr_fecreg
                              FROM   tra_aut_previa a
                             WHERE   a.key_cuo = prm_key_cuo
                                     AND a.key_voy_nber = prm_key_voy_nber
                                     AND a.key_dep_date =
                                            TO_DATE (prm_key_dep_date,
                                                     'dd/mm/yyyy')
                                     AND a.key_bol_ref = prm_key_bol_ref
                                     AND a.apr_ds_autorizacion = 'DS2752CAN'
                                     AND a.apr_num = 0;

                        UPDATE   tra_aut_previa a
                           SET   a.apr_nro_autorizacion = '',
                                 a.apr_usuario = prm_usuario,
                                 a.apr_lstope = 'D',
                                 a.apr_fecreg = SYSDATE
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.key_bol_ref = prm_key_bol_ref
                                 AND a.apr_ds_autorizacion = 'DS2752CAN'
                                 AND a.apr_num = 0;
                    END IF;
                END IF;
            END IF;
        END IF;

        IF LENGTH (prm_observacion) > 0
        THEN
            SELECT   COUNT ( * )
              INTO   hay
              FROM   tra_inf_docembarque
             WHERE   key_cuo = prm_key_cuo
                     AND key_voy_nber = prm_key_voy_nber
                     AND key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND key_bol_ref = prm_key_bol_ref;

            INSERT INTO tra_inf_docembarque
                SELECT   a.key_cuo,
                         a.key_voy_nber,
                         a.key_dep_date,
                         a.key_bol_ref,
                         a.docemb_adm_destino,
                         a.docemb_fecha_embarque,
                         a.docemb_silista_rs1392015,
                         a.docemb_si_pri_rs1692016,
                         a.docemb_si_seg_rs1692016,
                         a.docemb_otras_mercancias,
                         a.docemb_est_autorizado,
                         a.docemb_usuario,
                         hay,
                         a.lst_ope,
                         a.docemb_fecreg,
                         a.docemb_cantidad_partidas,
                         a.docemb_observacionaut,
                         a.docemb_observacion2295
                  FROM   tra_inf_docembarque a
                 WHERE   key_cuo = prm_key_cuo
                         AND key_voy_nber = prm_key_voy_nber
                         AND key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND key_bol_ref = prm_key_bol_ref
                         AND docemb_num = 0;

            UPDATE   tra_inf_docembarque
               SET   docemb_usuario = prm_usuario,
                     lst_ope = 'U',
                     docemb_fecreg = SYSDATE,
                     docemb_observacionaut = prm_observacion
             WHERE   key_cuo = prm_key_cuo
                     AND key_voy_nber = prm_key_voy_nber
                     AND key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND key_bol_ref = prm_key_bol_ref
                     AND docemb_num = 0;
        END IF;

        COMMIT;
        RETURN 'SI';
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SQLCODE || '-' || SQLERRM;
            ROLLBACK;
    END;


    -----------------------------------------------------------------------------
    -- GUARDA DOCUMENTO DE EMBARQUE
    -----------------------------------------------------------------------------

    FUNCTION graba_docemb (prm_key_cuo                    IN VARCHAR2,
                           prm_key_voy_nber               IN VARCHAR2,
                           prm_key_dep_date               IN VARCHAR2,
                           prm_key_bol_ref                IN VARCHAR2,
                           prm_docemb_fecha_embarque      IN VARCHAR2,
                           prm_docemb_silista_rs1392015   IN VARCHAR2,
                           prm_docemb_si_pri_rs1692016    IN VARCHAR2,
                           prm_docemb_si_seg_rs1692016    IN VARCHAR2,
                           prm_docemb_otras_mercancias    IN VARCHAR2,
                           prm_docemb_cantidad_partidas   IN VARCHAR2,
                           prm_usuario                    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        hay_docemb              NUMBER;
        sw_nro                  NUMBER;
        vaduana_dest            VARCHAR2 (9);
        hay_docemb_autorizado   NUMBER;
        estado                  VARCHAR2 (3) := 'NA';
        estado1                 VARCHAR2 (3) := 'NA';
        estado2                 VARCHAR2 (3) := 'NA';
        estado3                 VARCHAR2 (3) := 'NA';
    BEGIN
        IF (prm_docemb_fecha_embarque IS NULL)
        THEN
            RETURN 'Debe ingresar la fecha de embarque';
        END IF;

        --evaluar estado 18022016 agregado por edgar a solicitud de Normas
        IF (prm_docemb_cantidad_partidas = 'SI')
        THEN
            estado := 'NA';
        ELSE
            --- EVALUAR ESTADO ---
            IF (prm_docemb_otras_mercancias = 'NO')
            THEN
                estado1 := 'SA';

                IF (prm_docemb_si_pri_rs1692016 = 'SI')
                THEN
                    IF (TO_DATE (prm_docemb_fecha_embarque, 'dd/mm/yyyy') >=
                            TO_DATE ('01/02/2016', 'dd/mm/yyyy'))
                    THEN
                        estado2 := 'SA';
                    END IF;
                ELSE
                    estado2 := 'SA';
                END IF;

                IF (prm_docemb_si_seg_rs1692016 = 'SI')
                THEN
                    IF (TO_DATE (prm_docemb_fecha_embarque, 'dd/mm/yyyy') >=
                            TO_DATE ('06/06/2016', 'dd/mm/yyyy'))
                    THEN
                        estado3 := 'SA';
                    END IF;
                ELSE
                    estado3 := 'SA';
                END IF;

                IF (estado1 = 'SA' AND estado2 = 'SA' AND estado3 = 'SA')
                THEN
                    estado := 'SA';
                END IF;
            END IF;
        --- FIN EVALUAR ESTADO ---
        END IF;

        --- fin evaluar estado

        SELECT   COUNT ( * )
          INTO   hay_docemb
          FROM   tra_inf_docembarque
         WHERE       key_cuo = prm_key_cuo
                 AND key_voy_nber = prm_key_voy_nber
                 AND key_dep_date = TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND key_bol_ref = prm_key_bol_ref;

        --                 AND docemb_est_autorizado = 'NA';

        /*        SELECT   COUNT ( * )
                  INTO   hay_docemb_autorizado
                  FROM   tra_inf_docembarque
                 WHERE       key_cuo = prm_key_cuo
                         AND key_voy_nber = prm_key_voy_nber
                         AND key_dep_date = prm_key_dep_date
                         AND key_bol_ref = prm_key_bol_ref
                         AND docemb_num = 0
                         AND lst_ope = 'U'
                         AND docemb_est_autorizado IS NOT NULL;*/
        --               AND docemb_est_autorizado = 'SA';


        /*        IF (hay_docemb_autorizado > 0)
                THEN
                    RETURN    'El Documento de embarque   '
                           || prm_key_dep_date
                           || ' '
                           || prm_key_cuo
                           || ' '
                           || prm_key_voy_nber
                           || ' '
                           || prm_key_bol_ref
                           || ' '
                           || ' ya fue registrado anteriormente';
                END IF;*/

        SELECT   carbol_frt_prep
          INTO   vaduana_dest
          FROM   car_bol_gen
         WHERE       key_cuo = prm_key_cuo
                 AND key_voy_nber = prm_key_voy_nber
                 AND key_dep_date = TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND key_bol_ref = prm_key_bol_ref;


        IF (hay_docemb > 0)
        THEN
            INSERT INTO tra_inf_docembarque
                SELECT   a.key_cuo,
                         a.key_voy_nber,
                         a.key_dep_date,
                         a.key_bol_ref,
                         a.docemb_adm_destino,
                         a.docemb_fecha_embarque,
                         a.docemb_silista_rs1392015,
                         a.docemb_si_pri_rs1692016,
                         a.docemb_si_seg_rs1692016,
                         a.docemb_otras_mercancias,
                         a.docemb_est_autorizado,
                         a.docemb_usuario,
                         hay_docemb,
                         a.lst_ope,
                         a.docemb_fecreg,
                         a.docemb_cantidad_partidas,
                         a.docemb_observacionaut,
                         a.docemb_observacion2295
                  FROM   tra_inf_docembarque a
                 WHERE   key_cuo = prm_key_cuo
                         AND key_voy_nber = prm_key_voy_nber
                         AND key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND key_bol_ref = prm_key_bol_ref
                         AND docemb_num = 0;


            UPDATE   tra_inf_docembarque
               SET   docemb_fecha_embarque =
                         TO_DATE (prm_docemb_fecha_embarque, 'dd/mm/yyyy'),
                     docemb_silista_rs1392015 = prm_docemb_silista_rs1392015,
                     docemb_si_pri_rs1692016 = prm_docemb_si_pri_rs1692016,
                     docemb_si_seg_rs1692016 = prm_docemb_si_seg_rs1692016,
                     docemb_otras_mercancias = prm_docemb_otras_mercancias,
                     docemb_est_autorizado = estado,
                     docemb_usuario = prm_usuario,
                     lst_ope = 'U',
                     docemb_fecreg = SYSDATE,
                     docemb_cantidad_partidas = prm_docemb_cantidad_partidas
             WHERE   key_cuo = prm_key_cuo
                     AND key_voy_nber = prm_key_voy_nber
                     AND key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND key_bol_ref = prm_key_bol_ref
                     AND docemb_num = 0;
        ELSE
            INSERT INTO tra_inf_docembarque a (a.key_cuo,
                                               a.key_voy_nber,
                                               a.key_dep_date,
                                               a.key_bol_ref,
                                               a.docemb_adm_destino,
                                               a.docemb_fecha_embarque,
                                               a.docemb_silista_rs1392015,
                                               a.docemb_si_pri_rs1692016,
                                               a.docemb_si_seg_rs1692016,
                                               a.docemb_otras_mercancias,
                                               a.docemb_est_autorizado,
                                               a.docemb_usuario,
                                               a.docemb_num,
                                               a.lst_ope,
                                               --                                               a.docemb_cantidad,
                                               a.docemb_fecreg,
                                               a.docemb_cantidad_partidas,
                                               a.docemb_observacionaut)
              VALUES   (prm_key_cuo,
                        prm_key_voy_nber,
                        TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                        prm_key_bol_ref,
                        vaduana_dest,
                        TO_DATE (prm_docemb_fecha_embarque, 'dd/mm/yyyy'),
                        prm_docemb_silista_rs1392015,
                        prm_docemb_si_pri_rs1692016,
                        prm_docemb_si_seg_rs1692016,
                        prm_docemb_otras_mercancias,
                        estado,
                        --                        'NA',
                        prm_usuario,
                        0,
                        'U',
                        --                        NULL,
                        SYSDATE,
                        prm_docemb_cantidad_partidas,
                        '');
        END IF;

        COMMIT;
        RETURN 'SI';
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SQLCODE || '-' || SQLERRM;
            ROLLBACK;
    END;


    FUNCTION graba_docemb_enmienda (
        prm_key_cuo                    IN VARCHAR2,
        prm_key_voy_nber               IN VARCHAR2,
        prm_key_dep_date               IN VARCHAR2,
        prm_key_bol_ref                IN VARCHAR2,
        prm_docemb_fecha_embarque      IN VARCHAR2,
        prm_docemb_silista_rs1392015   IN VARCHAR2,
        prm_docemb_si_pri_rs1692016    IN VARCHAR2,
        prm_docemb_si_seg_rs1692016    IN VARCHAR2,
        prm_docemb_otras_mercancias    IN VARCHAR2,
        prm_docemb_cantidad_partidas   IN VARCHAR2,
        prm_usuario                    IN VARCHAR2,
        prm_observacion2295            IN VARCHAR2)
        RETURN VARCHAR2
    IS
        hay_docemb              NUMBER;
        sw_nro                  NUMBER;
        vaduana_dest            VARCHAR2 (9);
        hay_docemb_autorizado   NUMBER;
        estado                  VARCHAR2 (3) := 'NA';
        estado1                 VARCHAR2 (3) := 'NA';
        estado2                 VARCHAR2 (3) := 'NA';
        estado3                 VARCHAR2 (3) := 'NA';
        v_fecha_embarque        DATE;
        verif                   VARCHAR2 (200);
    BEGIN
        SELECT   a.docemb_fecha_embarque
          INTO   v_fecha_embarque
          FROM   tra_inf_docembarque a
         WHERE   a.key_cuo = prm_key_cuo
                 AND a.key_voy_nber = prm_key_voy_nber
                 AND a.key_dep_date =
                        TO_DATE (prm_key_dep_date, 'DD/MM/YYYY')
                 AND a.key_bol_ref = prm_key_bol_ref
                 AND a.docemb_num = 0;


        --evaluar estado 18022016 agregado por edgar a solicitud de Normas
        IF (prm_docemb_cantidad_partidas = 'SI')
        THEN
            estado := 'NA';
        ELSE
            --- EVALUAR ESTADO ---
            IF (prm_docemb_otras_mercancias = 'NO')
            THEN
                estado1 := 'SA';

                IF (prm_docemb_si_pri_rs1692016 = 'SI')
                THEN
                    IF (v_fecha_embarque >=
                            TO_DATE ('01/02/2016', 'dd/mm/yyyy'))
                    THEN
                        estado2 := 'SA';
                    END IF;
                ELSE
                    estado2 := 'SA';
                END IF;

                IF (prm_docemb_si_seg_rs1692016 = 'SI')
                THEN
                    IF (v_fecha_embarque >=
                            TO_DATE ('06/06/2016', 'dd/mm/yyyy'))
                    THEN
                        estado3 := 'SA';
                    END IF;
                ELSE
                    estado3 := 'SA';
                END IF;

                IF (estado1 = 'SA' AND estado2 = 'SA' AND estado3 = 'SA')
                THEN
                    estado := 'SA';
                END IF;
            END IF;
        --- FIN EVALUAR ESTADO ---
        END IF;

        --- fin evaluar estado

        SELECT   COUNT ( * )
          INTO   hay_docemb
          FROM   tra_inf_docembarque
         WHERE       key_cuo = prm_key_cuo
                 AND key_voy_nber = prm_key_voy_nber
                 AND key_dep_date = TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND key_bol_ref = prm_key_bol_ref;

        --                 AND docemb_est_autorizado = 'NA';

        /*        SELECT   COUNT ( * )
                  INTO   hay_docemb_autorizado
                  FROM   tra_inf_docembarque
                 WHERE       key_cuo = prm_key_cuo
                         AND key_voy_nber = prm_key_voy_nber
                         AND key_dep_date = prm_key_dep_date
                         AND key_bol_ref = prm_key_bol_ref
                         AND docemb_num = 0
                         AND lst_ope = 'U'
                         AND docemb_est_autorizado IS NOT NULL;*/
        --               AND docemb_est_autorizado = 'SA';


        /*        IF (hay_docemb_autorizado > 0)
                THEN
                    RETURN    'El Documento de embarque   '
                           || prm_key_dep_date
                           || ' '
                           || prm_key_cuo
                           || ' '
                           || prm_key_voy_nber
                           || ' '
                           || prm_key_bol_ref
                           || ' '
                           || ' ya fue registrado anteriormente';
                END IF;*/

        SELECT   carbol_frt_prep
          INTO   vaduana_dest
          FROM   car_bol_gen
         WHERE       key_cuo = prm_key_cuo
                 AND key_voy_nber = prm_key_voy_nber
                 AND key_dep_date = TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND key_bol_ref = prm_key_bol_ref;


        IF (hay_docemb > 0)
        THEN
            INSERT INTO tra_inf_docembarque
                SELECT   a.key_cuo,
                         a.key_voy_nber,
                         a.key_dep_date,
                         a.key_bol_ref,
                         a.docemb_adm_destino,
                         a.docemb_fecha_embarque,
                         a.docemb_silista_rs1392015,
                         a.docemb_si_pri_rs1692016,
                         a.docemb_si_seg_rs1692016,
                         a.docemb_otras_mercancias,
                         a.docemb_est_autorizado,
                         a.docemb_usuario,
                         hay_docemb,
                         a.lst_ope,
                         a.docemb_fecreg,
                         a.docemb_cantidad_partidas,
                         a.docemb_observacionaut,
                         a.docemb_observacion2295
                  FROM   tra_inf_docembarque a
                 WHERE   key_cuo = prm_key_cuo
                         AND key_voy_nber = prm_key_voy_nber
                         AND key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND key_bol_ref = prm_key_bol_ref
                         AND docemb_num = 0;


            UPDATE   tra_inf_docembarque
               SET   docemb_silista_rs1392015 = prm_docemb_silista_rs1392015,
                     docemb_si_pri_rs1692016 = prm_docemb_si_pri_rs1692016,
                     docemb_si_seg_rs1692016 = prm_docemb_si_seg_rs1692016,
                     docemb_otras_mercancias = prm_docemb_otras_mercancias,
                     docemb_est_autorizado = estado,
                     docemb_usuario = prm_usuario,
                     lst_ope = 'U',
                     docemb_fecreg = SYSDATE,
                     docemb_cantidad_partidas = prm_docemb_cantidad_partidas,
                     docemb_observacion2295 = prm_observacion2295
             WHERE   key_cuo = prm_key_cuo
                     AND key_voy_nber = prm_key_voy_nber
                     AND key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND key_bol_ref = prm_key_bol_ref
                     AND docemb_num = 0;
        ELSE
            RETURN 'SE DEBE REGISTRAR EL CONTROL DE DOCUMENTO DE EMBARQUE, ANTES DE ENMENDAR';
        END IF;

        verif :=
            pkg_ds2295.graba_man_autorizado (prm_key_cuo,
                                             prm_key_voy_nber,
                                             prm_key_dep_date,
                                             '',
                                             prm_usuario);

        IF verif = 'SI'
        THEN
            COMMIT;
            RETURN 'SI';
        ELSE
            ROLLBACK;
            RETURN verif;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SQLCODE || '-' || SQLERRM;
            ROLLBACK;
    END;



    FUNCTION graba_docemb2 (prm_key_cuo                 IN VARCHAR2,
                            prm_key_voy_nber            IN VARCHAR2,
                            prm_key_dep_date            IN VARCHAR2,
                            prm_key_bol_ref             IN VARCHAR2,
                            prm_docemb_fecha_embarque   IN VARCHAR2,
                            prm_usuario                 IN VARCHAR2)
        RETURN VARCHAR2
    IS
        hay_docemb              NUMBER;
        sw_nro                  NUMBER;
        vaduana_dest            VARCHAR2 (9);
        hay_docemb_autorizado   NUMBER;
        estado                  VARCHAR2 (3) := 'NA';
        estado1                 VARCHAR2 (3) := 'NA';
        estado2                 VARCHAR2 (3) := 'NA';
        estado3                 VARCHAR2 (3) := 'NA';
    BEGIN
        IF (prm_docemb_fecha_embarque IS NULL)
        THEN
            RETURN 'Debe ingresar la fecha de embarque';
        END IF;

        estado := 'NA';


        --- fin evaluar estado

        SELECT   COUNT ( * )
          INTO   hay_docemb
          FROM   tra_inf_docembarque
         WHERE       key_cuo = prm_key_cuo
                 AND key_voy_nber = prm_key_voy_nber
                 AND key_dep_date = TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND key_bol_ref = prm_key_bol_ref;

        SELECT   carbol_frt_prep
          INTO   vaduana_dest
          FROM   car_bol_gen
         WHERE       key_cuo = prm_key_cuo
                 AND key_voy_nber = prm_key_voy_nber
                 AND key_dep_date = TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND key_bol_ref = prm_key_bol_ref;


        IF (hay_docemb > 0)
        THEN
            INSERT INTO tra_inf_docembarque
                SELECT   a.key_cuo,
                         a.key_voy_nber,
                         a.key_dep_date,
                         a.key_bol_ref,
                         a.docemb_adm_destino,
                         a.docemb_fecha_embarque,
                         a.docemb_silista_rs1392015,
                         a.docemb_si_pri_rs1692016,
                         a.docemb_si_seg_rs1692016,
                         a.docemb_otras_mercancias,
                         a.docemb_est_autorizado,
                         a.docemb_usuario,
                         hay_docemb,
                         a.lst_ope,
                         a.docemb_fecreg,
                         a.docemb_cantidad_partidas,
                         a.docemb_observacionaut,
                         a.docemb_observacion2295
                  FROM   tra_inf_docembarque a
                 WHERE   key_cuo = prm_key_cuo
                         AND key_voy_nber = prm_key_voy_nber
                         AND key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND key_bol_ref = prm_key_bol_ref
                         AND docemb_num = 0;


            UPDATE   tra_inf_docembarque
               SET   docemb_fecha_embarque = to_date(prm_docemb_fecha_embarque,'dd/mm/yyyy'),
                     docemb_silista_rs1392015 = NULL,
                     docemb_si_pri_rs1692016 = NULL,
                     docemb_si_seg_rs1692016 = NULL,
                     docemb_otras_mercancias = NULL,
                     docemb_est_autorizado = estado,
                     docemb_usuario = prm_usuario,
                     lst_ope = 'U',
                     docemb_fecreg = SYSDATE,
                     docemb_cantidad_partidas = NULL
             WHERE   key_cuo = prm_key_cuo
                     AND key_voy_nber = prm_key_voy_nber
                     AND key_dep_date =
                            TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                     AND key_bol_ref = prm_key_bol_ref
                     AND docemb_num = 0;
        ELSE
            INSERT INTO tra_inf_docembarque a (a.key_cuo,
                                               a.key_voy_nber,
                                               a.key_dep_date,
                                               a.key_bol_ref,
                                               a.docemb_adm_destino,
                                               a.docemb_fecha_embarque,
                                               a.docemb_silista_rs1392015,
                                               a.docemb_si_pri_rs1692016,
                                               a.docemb_si_seg_rs1692016,
                                               a.docemb_otras_mercancias,
                                               a.docemb_est_autorizado,
                                               a.docemb_usuario,
                                               a.docemb_num,
                                               a.lst_ope,
                                               --                                               a.docemb_cantidad,
                                               a.docemb_fecreg,
                                               a.docemb_cantidad_partidas,
                                               a.docemb_observacionaut)
              VALUES   (prm_key_cuo,
                        prm_key_voy_nber,
                        TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                        prm_key_bol_ref,
                        vaduana_dest,
                        TO_DATE (prm_docemb_fecha_embarque, 'dd/mm/yyyy'),
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        estado,
                        --                        'NA',
                        prm_usuario,
                        0,
                        'U',
                        --                        NULL,
                        SYSDATE,
                        NULL,
                        '');
        END IF;

        COMMIT;
        RETURN 'SI';
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SQLCODE || '-' || SQLERRM;
            ROLLBACK;
    END;


    FUNCTION verifica_aut (
        p_key_cuo        IN ops$asy.car_bol_gen.key_cuo%TYPE,
        p_key_voy_nber   IN ops$asy.car_bol_gen.key_voy_nber%TYPE,
        p_key_dep_date   IN VARCHAR2,
        p_key_bol_ref    IN ops$asy.car_bol_gen.key_bol_ref%TYPE)
        RETURN VARCHAR2
    IS
        res    VARCHAR2 (10);
        cont   NUMBER;
    BEGIN
        SELECT   COUNT (1)
          INTO   cont
          FROM   tra_inf_docembarque a
         WHERE       a.key_cuo = p_key_cuo
                 AND a.key_voy_nber = p_key_voy_nber
                 AND a.key_dep_date = TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                 AND a.key_bol_ref = p_key_bol_ref
                 --AND a.docemb_fecha_embarque is not null
                 AND a.docemb_num = 0
                 AND a.lst_ope = 'U';

        IF cont = 0
        THEN
            res := 'SIN 2295';
        ELSE
            SELECT   DECODE (COUNT (1), 0, 'SIN DATOS', 'LLENADO')
              INTO   res
              FROM   tra_aut_previa a
             WHERE   a.key_cuo = p_key_cuo
                     AND a.key_voy_nber = p_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                     AND a.key_bol_ref = p_key_bol_ref
                     AND a.apr_num = 0
                     AND a.apr_lstope = 'U';
        END IF;


        RETURN res;
    END;


    FUNCTION devuelve_autprevia (
        p_key_cuo        IN ops$asy.car_bol_gen.key_cuo%TYPE,
        p_key_voy_nber   IN ops$asy.car_bol_gen.key_voy_nber%TYPE,
        p_key_dep_date   IN VARCHAR2,
        p_key_bol_ref    IN ops$asy.car_bol_gen.key_bol_ref%TYPE)
        RETURN VARCHAR2
    IS
        res    VARCHAR2 (100) := '';
        cont   NUMBER;
        sep    VARCHAR2 (2) := '';
    BEGIN
        SELECT   COUNT (1)
          INTO   cont
          FROM   tra_aut_previa a
         WHERE       a.key_cuo = p_key_cuo
                 AND a.key_voy_nber = p_key_voy_nber
                 AND a.key_dep_date = TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                 AND a.key_bol_ref = p_key_bol_ref
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND a.apr_ds_autorizacion = 'DS2600';

        IF cont = 1
        THEN
            res := res || sep || 'DS2600';
            sep := ', ';
        END IF;

        SELECT   COUNT (1)
          INTO   cont
          FROM   tra_aut_previa a
         WHERE       a.key_cuo = p_key_cuo
                 AND a.key_voy_nber = p_key_voy_nber
                 AND a.key_dep_date = TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                 AND a.key_bol_ref = p_key_bol_ref
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND a.apr_ds_autorizacion = 'DS2657';

        IF cont = 1
        THEN
            res := res || sep || 'DS2657';
            sep := ', ';
        END IF;

        SELECT   COUNT (1)
          INTO   cont
          FROM   tra_aut_previa a
         WHERE       a.key_cuo = p_key_cuo
                 AND a.key_voy_nber = p_key_voy_nber
                 AND a.key_dep_date = TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                 AND a.key_bol_ref = p_key_bol_ref
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND a.apr_ds_autorizacion = 'DS2751';

        IF cont = 1
        THEN
            res := res || sep || 'DS2751';
            sep := ', ';
        END IF;

        SELECT   COUNT (1)
          INTO   cont
          FROM   tra_aut_previa a
         WHERE       a.key_cuo = p_key_cuo
                 AND a.key_voy_nber = p_key_voy_nber
                 AND a.key_dep_date = TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                 AND a.key_bol_ref = p_key_bol_ref
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND a.apr_ds_autorizacion = 'DS2752';

        IF cont = 1
        THEN
            res := res || sep || 'DS2752';
            sep := ', ';
        END IF;

        SELECT   COUNT (1)
          INTO   cont
          FROM   tra_aut_previa a
         WHERE       a.key_cuo = p_key_cuo
                 AND a.key_voy_nber = p_key_voy_nber
                 AND a.key_dep_date = TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                 AND a.key_bol_ref = p_key_bol_ref
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND a.apr_ds_autorizacion = 'DS2752CAN';

        IF cont = 1
        THEN
            res := res || sep || 'DS2752CAN';
            sep := ', ';
        END IF;

        SELECT   COUNT (1)
          INTO   cont
          FROM   tra_aut_previa a
         WHERE       a.key_cuo = p_key_cuo
                 AND a.key_voy_nber = p_key_voy_nber
                 AND a.key_dep_date = TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                 AND a.key_bol_ref = p_key_bol_ref
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND a.apr_ds_autorizacion = 'DS2865';

        IF cont = 1
        THEN
            res := res || sep || 'DS2865';
            sep := ', ';
        END IF;

        SELECT   COUNT (1)
          INTO   cont
          FROM   tra_aut_previa a
         WHERE       a.key_cuo = p_key_cuo
                 AND a.key_voy_nber = p_key_voy_nber
                 AND a.key_dep_date = TO_DATE (p_key_dep_date, 'dd/mm/yyyy')
                 AND a.key_bol_ref = p_key_bol_ref
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND a.apr_ds_autorizacion = 'NINGUNO';

        IF cont = 1
        THEN
            res := res || sep || 'NINGUNO';
            sep := ', ';
        END IF;

        IF LENGTH(res) = 0 or res is null
        THEN
            res := '-';
        END IF;

        RETURN res;
    END;

    FUNCTION c_list_docembq (
        p_key_voy_nber_ref   IN ops$asy.car_gen.key_voy_nber%TYPE,
        p_man_aduana_ref     IN ops$asy.car_gen.key_cuo%TYPE,
        p_key_dep_date_ref   IN VARCHAR2,
        p_man_gestion_reg    IN ops$asy.car_gen.car_reg_year%TYPE,
        p_man_aduana_reg     IN ops$asy.car_gen.key_cuo%TYPE,
        p_man_numero_reg     IN ops$asy.car_gen.car_reg_nber%TYPE,
        p_tipo               IN VARCHAR2)
        RETURN cursortype
    IS
        ct       cursortype;
        d1       VARCHAR2 (20);
        fd1      VARCHAR2 (20);
        d2       VARCHAR2 (20);
        fd2      VARCHAR2 (20);

        d2657    VARCHAR2 (20);
        fd2657   VARCHAR2 (20);
        d2600    VARCHAR2 (20);
        fd2600   VARCHAR2 (20);
        d2751    VARCHAR2 (20);
        fd2751   VARCHAR2 (20);
        d2752    VARCHAR2 (20);
        fd2752   VARCHAR2 (20);
        d2865    VARCHAR2 (20);
        fd2865   VARCHAR2 (20);
    BEGIN
        d1 := '';
        fd1 := '';
        d2 := '';
        fd2 := '';

        d2751 := '';
        fd2751 := '';
        d2752 := '';
        fd2752 := '';
        d2657 := '';
        fd2657 := '';
        d2600 := '';
        fd2600 := '';
        d2865 := '';
        fd2865 := '';

        SELECT   d1.ade_ds_autorizacion,
                 TO_CHAR (d1.ade_fecha_control, 'dd/mm/yyyy'),
                 d2.ade_ds_autorizacion,
                 TO_CHAR (d2.ade_fecha_control, 'dd/mm/yyyy'),
                 d3.ade_ds_autorizacion,
                 TO_CHAR (d3.ade_fecha_control, 'dd/mm/yyyy'),
                 d4.ade_ds_autorizacion,
                 TO_CHAR (d4.ade_fecha_control, 'dd/mm/yyyy'),
                 d5.ade_ds_autorizacion,
                 TO_CHAR (d5.ade_fecha_control, 'dd/mm/yyyy')
          INTO   d2751,
                 fd2751,
                 d2752,
                 fd2752,
                 d2657,
                 fd2657,
                 d2600,
                 fd2600,
                 d2865,
                 fd2865
          FROM   tra_aut_decreto d1,
                 tra_aut_decreto d2,
                 tra_aut_decreto d3,
                 tra_aut_decreto d4,
                 tra_aut_decreto d5
         WHERE       d1.ade_num = 0
                 AND d1.ade_lstope = 'U'
                 AND d1.ade_ds_autorizacion = 'DS2751'
                 AND d2.ade_num = 0
                 AND d2.ade_lstope = 'U'
                 AND d2.ade_ds_autorizacion = 'DS2752'
                 AND d3.ade_num = 0
                 AND d3.ade_lstope = 'U'
                 AND d3.ade_ds_autorizacion = 'DS2657'
                 AND d4.ade_num = 0
                 AND d4.ade_lstope = 'U'
                 AND d4.ade_ds_autorizacion = 'DS2600'
                 AND d5.ade_num = 0
                 AND d5.ade_lstope = 'U'
                 AND d5.ade_ds_autorizacion = 'DS2865';

        IF (UPPER (p_tipo) = 'REF')
        THEN
            OPEN ct FOR
                  SELECT   a.key_cuo,
                           a.key_voy_nber,
                           TO_CHAR (a.key_dep_date, 'dd/mm/yyyy'),
                           a.key_bol_ref,
                           a.carbol_frt_prep,
                           TO_CHAR (tb.docemb_fecha_embarque, 'dd/mm/yyyy'),
                           tb.docemb_silista_rs1392015,
                           tb.docemb_si_pri_rs1692016,
                           tb.docemb_si_seg_rs1692016,
                           tb.docemb_otras_mercancias,
                           tb.docemb_est_autorizado,
                           tb.docemb_cantidad_partidas,
                           verifica_aut (
                               a.key_cuo,
                               a.key_voy_nber,
                               TO_CHAR (a.key_dep_date, 'dd/mm/yyyy'),
                               a.key_bol_ref),
                           --tb.docemb_cantidad
                           d2751,
                           fd2751,
                           d2752,
                           fd2752,
                           d2657,
                           fd2657,
                           d2600,
                           fd2600,
                           devuelve_autprevia (
                               a.key_cuo,
                               a.key_voy_nber,
                               TO_CHAR (a.key_dep_date, 'dd/mm/yyyy'),
                               a.key_bol_ref)
                               decretos,
                           NVL (a2600.apr_ds_autorizacion, '-') ds2600,
                           NVL (a2600.apr_nro_autorizacion, '-') dn2600,
                           NVL (a2657.apr_ds_autorizacion, '-') ds2657,
                           NVL (a2657.apr_nro_autorizacion, '-') dn2657,
                           NVL (a2751.apr_ds_autorizacion, '-') ds2751,
                           NVL (a2751.apr_nro_autorizacion, '-') dn2751,
                           NVL (a2752.apr_ds_autorizacion, '-') ds2752,
                           NVL (a2752.apr_nro_autorizacion, '-') dn2752,
                           NVL (a2752can.apr_ds_autorizacion, '-') ds2752can,
                           NVL (aninguno.apr_ds_autorizacion, '-') dsninguno,
                           NVL(tb.docemb_observacionaut,'-')
                               docemb_obs_enm_autprevia,
                           d2865,
                           fd2865,
                           NVL (a2865.apr_ds_autorizacion, '-') ds2865,
                           NVL (a2865.apr_nro_autorizacion, '-') dn2865,
                           NVL(docemb_observacion2295,'-')
                    FROM   ops$asy.car_bol_gen a,
                           ops$asy.car_gen b,
                           (SELECT   *
                              FROM   tra_inf_docembarque x
                             WHERE   x.lst_ope = 'U' AND x.docemb_num = 0) tb,
                           tra_aut_previa a2600,
                           tra_aut_previa a2657,
                           tra_aut_previa a2751,
                           tra_aut_previa a2752,
                           tra_aut_previa a2752can,
                           tra_aut_previa aninguno,
                           tra_aut_previa a2865
                   WHERE       a.key_cuo = b.key_cuo
                           AND a.key_voy_nber = b.key_voy_nber
                           AND a.key_dep_date = b.key_dep_date
                           AND tb.key_cuo(+) = a.key_cuo
                           AND tb.key_voy_nber(+) = a.key_voy_nber
                           AND tb.key_dep_date(+) = a.key_dep_date
                           AND tb.key_bol_ref(+) = a.key_bol_ref
                           AND a.key_cuo = p_man_aduana_ref
                           AND a.key_voy_nber = p_key_voy_nber_ref
                           AND a.key_dep_date =
                                  TO_DATE (p_key_dep_date_ref, 'dd/mm/yyyy')
                           AND a2600.key_cuo(+) = tb.key_cuo
                           AND a2600.key_voy_nber(+) = tb.key_voy_nber
                           AND a2600.key_dep_date(+) = tb.key_dep_date
                           AND a2600.key_bol_ref(+) = tb.key_bol_ref
                           AND a2600.apr_num(+) = 0
                           AND a2600.apr_lstope(+) = 'U'
                           AND a2600.apr_ds_autorizacion(+) = 'DS2600'
                           AND a2657.key_cuo(+) = tb.key_cuo
                           AND a2657.key_voy_nber(+) = tb.key_voy_nber
                           AND a2657.key_dep_date(+) = tb.key_dep_date
                           AND a2657.key_bol_ref(+) = tb.key_bol_ref
                           AND a2657.apr_num(+) = 0
                           AND a2657.apr_lstope(+) = 'U'
                           AND a2657.apr_ds_autorizacion(+) = 'DS2657'
                           AND a2751.key_cuo(+) = tb.key_cuo
                           AND a2751.key_voy_nber(+) = tb.key_voy_nber
                           AND a2751.key_dep_date(+) = tb.key_dep_date
                           AND a2751.key_bol_ref(+) = tb.key_bol_ref
                           AND a2751.apr_num(+) = 0
                           AND a2751.apr_lstope(+) = 'U'
                           AND a2751.apr_ds_autorizacion(+) = 'DS2751'
                           AND a2752.key_cuo(+) = tb.key_cuo
                           AND a2752.key_voy_nber(+) = tb.key_voy_nber
                           AND a2752.key_dep_date(+) = tb.key_dep_date
                           AND a2752.key_bol_ref(+) = tb.key_bol_ref
                           AND a2752.apr_num(+) = 0
                           AND a2752.apr_lstope(+) = 'U'
                           AND a2752.apr_ds_autorizacion(+) = 'DS2752'
                           AND a2752can.key_cuo(+) = tb.key_cuo
                           AND a2752can.key_voy_nber(+) = tb.key_voy_nber
                           AND a2752can.key_dep_date(+) = tb.key_dep_date
                           AND a2752can.key_bol_ref(+) = tb.key_bol_ref
                           AND a2752can.apr_num(+) = 0
                           AND a2752can.apr_lstope(+) = 'U'
                           AND a2752can.apr_ds_autorizacion(+) = 'DS2752CAN'
                           AND aninguno.key_cuo(+) = tb.key_cuo
                           AND aninguno.key_voy_nber(+) = tb.key_voy_nber
                           AND aninguno.key_dep_date(+) = tb.key_dep_date
                           AND aninguno.key_bol_ref(+) = tb.key_bol_ref
                           AND aninguno.apr_num(+) = 0
                           AND aninguno.apr_lstope(+) = 'U'
                           AND aninguno.apr_ds_autorizacion(+) = 'NINGUNO'
                           AND a2865.key_cuo(+) = tb.key_cuo
                           AND a2865.key_voy_nber(+) = tb.key_voy_nber
                           AND a2865.key_dep_date(+) = tb.key_dep_date
                           AND a2865.key_bol_ref(+) = tb.key_bol_ref
                           AND a2865.apr_num(+) = 0
                           AND a2865.apr_lstope(+) = 'U'
                           AND a2865.apr_ds_autorizacion(+) = 'DS2865'
                ORDER BY   a.key_lin_nbr;
        /*SELECT   cbg.key_cuo,
                 cbg.key_voy_nber,
                 cbg.key_dep_date,
                 cbg.key_bol_ref,
                 NVL (cbg.carbol_frt_prep, '-')
          FROM   ops$asy.uncuotab b,
                 ops$asy.car_gen cg,
                 ops$asy.car_bol_gen cbg
         WHERE       cbg.key_cuo = p_man_aduana_ref
                 AND cbg.key_voy_nber = p_key_voy_nber_ref
                 AND cbg.key_dep_date = p_key_dep_date_ref
                 AND cg.key_cuo = cbg.key_cuo
                 AND cg.key_voy_nber = cbg.key_voy_nber
                 AND cg.key_dep_date = cbg.key_dep_date
                 AND cg.key_cuo = b.cuo_cod
                 AND b.lst_ope = 'U';*/
        ELSE
            OPEN ct FOR
                  SELECT   a.key_cuo,
                           a.key_voy_nber,
                           TO_CHAR (a.key_dep_date, 'dd/mm/yyyy'),
                           a.key_bol_ref,
                           a.carbol_frt_prep,
                           TO_CHAR (tb.docemb_fecha_embarque, 'dd/mm/yyyy'),
                           tb.docemb_silista_rs1392015,
                           tb.docemb_si_pri_rs1692016,
                           tb.docemb_si_seg_rs1692016,
                           tb.docemb_otras_mercancias,
                           tb.docemb_est_autorizado,
                           tb.docemb_cantidad_partidas,
                           verifica_aut (
                               a.key_cuo,
                               a.key_voy_nber,
                               TO_CHAR (a.key_dep_date, 'dd/mm/yyyy'),
                               a.key_bol_ref),
                           --                         tb.docemb_cantidad
                           d2751,
                           fd2751,
                           d2752,
                           fd2752,
                           d2657,
                           fd2657,
                           d2600,
                           fd2600,
                           devuelve_autprevia (
                               a.key_cuo,
                               a.key_voy_nber,
                               TO_CHAR (a.key_dep_date, 'dd/mm/yyyy'),
                               a.key_bol_ref)
                               decretos,
                           NVL (a2600.apr_ds_autorizacion, '-') ds2600,
                           NVL (a2600.apr_nro_autorizacion, '-') dn2600,
                           NVL (a2657.apr_ds_autorizacion, '-') ds2657,
                           NVL (a2657.apr_nro_autorizacion, '-') dn2657,
                           NVL (a2751.apr_ds_autorizacion, '-') ds2751,
                           NVL (a2751.apr_nro_autorizacion, '-') dn2751,
                           NVL (a2752.apr_ds_autorizacion, '-') ds2752,
                           NVL (a2752.apr_nro_autorizacion, '-') dn2752,
                           NVL (a2752can.apr_ds_autorizacion, '-') ds2752can,
                           NVL (aninguno.apr_ds_autorizacion, '-') dsninguno,
                           NVL(tb.docemb_observacionaut,'-')
                               docemb_obs_enm_autprevia,
                           d2865,
                           fd2865,
                           NVL (a2865.apr_ds_autorizacion, '-') ds2865,
                           NVL (a2865.apr_nro_autorizacion, '-') dn2865,
                           NVL(docemb_observacion2295,'-')
                    FROM   ops$asy.car_bol_gen a,
                           ops$asy.car_gen b,
                           (SELECT   *
                              FROM   tra_inf_docembarque x
                             WHERE   x.lst_ope = 'U' AND x.docemb_num = 0) tb,
                           tra_aut_previa a2600,
                           tra_aut_previa a2657,
                           tra_aut_previa a2751,
                           tra_aut_previa a2752,
                           tra_aut_previa a2752can,
                           tra_aut_previa aninguno,
                           tra_aut_previa a2865
                   WHERE       a.key_cuo = b.key_cuo
                           AND a.key_voy_nber = b.key_voy_nber
                           AND a.key_dep_date = b.key_dep_date
                           AND tb.key_cuo(+) = a.key_cuo
                           AND tb.key_voy_nber(+) = a.key_voy_nber
                           AND tb.key_dep_date(+) = a.key_dep_date
                           AND tb.key_bol_ref(+) = a.key_bol_ref
                           AND b.key_cuo = p_man_aduana_reg
                           AND b.car_reg_year = p_man_gestion_reg
                           AND b.car_reg_nber = p_man_numero_reg
                           AND a2600.key_cuo(+) = tb.key_cuo
                           AND a2600.key_voy_nber(+) = tb.key_voy_nber
                           AND a2600.key_dep_date(+) = tb.key_dep_date
                           AND a2600.key_bol_ref(+) = tb.key_bol_ref
                           AND a2600.apr_num(+) = 0
                           AND a2600.apr_lstope(+) = 'U'
                           AND a2600.apr_ds_autorizacion(+) = 'DS2600'
                           AND a2657.key_cuo(+) = tb.key_cuo
                           AND a2657.key_voy_nber(+) = tb.key_voy_nber
                           AND a2657.key_dep_date(+) = tb.key_dep_date
                           AND a2657.key_bol_ref(+) = tb.key_bol_ref
                           AND a2657.apr_num(+) = 0
                           AND a2657.apr_lstope(+) = 'U'
                           AND a2657.apr_ds_autorizacion(+) = 'DS2657'
                           AND a2751.key_cuo(+) = tb.key_cuo
                           AND a2751.key_voy_nber(+) = tb.key_voy_nber
                           AND a2751.key_dep_date(+) = tb.key_dep_date
                           AND a2751.key_bol_ref(+) = tb.key_bol_ref
                           AND a2751.apr_num(+) = 0
                           AND a2751.apr_lstope(+) = 'U'
                           AND a2751.apr_ds_autorizacion(+) = 'DS2751'
                           AND a2752.key_cuo(+) = tb.key_cuo
                           AND a2752.key_voy_nber(+) = tb.key_voy_nber
                           AND a2752.key_dep_date(+) = tb.key_dep_date
                           AND a2752.key_bol_ref(+) = tb.key_bol_ref
                           AND a2752.apr_num(+) = 0
                           AND a2752.apr_lstope(+) = 'U'
                           AND a2752.apr_ds_autorizacion(+) = 'DS2752'
                           AND a2752can.key_cuo(+) = tb.key_cuo
                           AND a2752can.key_voy_nber(+) = tb.key_voy_nber
                           AND a2752can.key_dep_date(+) = tb.key_dep_date
                           AND a2752can.key_bol_ref(+) = tb.key_bol_ref
                           AND a2752can.apr_num(+) = 0
                           AND a2752can.apr_lstope(+) = 'U'
                           AND a2752can.apr_ds_autorizacion(+) = 'DS2752CAN'
                           AND aninguno.key_cuo(+) = tb.key_cuo
                           AND aninguno.key_voy_nber(+) = tb.key_voy_nber
                           AND aninguno.key_dep_date(+) = tb.key_dep_date
                           AND aninguno.key_bol_ref(+) = tb.key_bol_ref
                           AND aninguno.apr_num(+) = 0
                           AND aninguno.apr_lstope(+) = 'U'
                           AND aninguno.apr_ds_autorizacion(+) = 'NINGUNO'
                           AND a2865.key_cuo(+) = tb.key_cuo
                           AND a2865.key_voy_nber(+) = tb.key_voy_nber
                           AND a2865.key_dep_date(+) = tb.key_dep_date
                           AND a2865.key_bol_ref(+) = tb.key_bol_ref
                           AND a2865.apr_num(+) = 0
                           AND a2865.apr_lstope(+) = 'U'
                           AND a2865.apr_ds_autorizacion(+) = 'DS2865'
                ORDER BY   a.key_lin_nbr;
        /*SELECT   cbg.key_cuo,
                 cbg.key_voy_nber,
                 cbg.key_dep_date,
                 cbg.key_bol_ref,
                 NVL (cbg.carbol_frt_prep, '-')
          FROM   ops$asy.uncuotab b,
                 ops$asy.car_gen cg,
                 ops$asy.car_bol_gen cbg
         WHERE       cg.car_reg_year = p_man_gestion_reg
                 AND cg.key_cuo = p_man_aduana_reg
                 AND cg.car_reg_nber = p_man_numero_reg
                 AND cg.key_cuo = cbg.key_cuo
                 AND cg.key_voy_nber = cbg.key_voy_nber
                 AND cg.key_dep_date = cbg.key_dep_date
                 AND cg.key_cuo = b.cuo_cod
                 AND b.lst_ope = 'U'; */
        END IF;


        RETURN ct;
    EXCEPTION
        WHEN OTHERS
        THEN
            OPEN ct FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN (ct);
    END c_list_docembq;

    --Verifica si el destino es zona franca
    FUNCTION verifica_destino_zf (
        p_key_voy_nber_ref   IN ops$asy.car_gen.key_voy_nber%TYPE,
        p_man_aduana_ref     IN ops$asy.car_gen.key_cuo%TYPE,
        p_key_dep_date_ref   IN VARCHAR2,
        p_man_gestion_reg    IN ops$asy.car_gen.car_reg_year%TYPE,
        p_man_aduana_reg     IN ops$asy.car_gen.key_cuo%TYPE,
        p_man_numero_reg     IN ops$asy.car_gen.car_reg_nber%TYPE,
        p_tipo               IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (5);
    BEGIN
        IF (UPPER (p_tipo) = 'REF')
        THEN
            SELECT   COUNT (1)
              INTO   res
              FROM   ops$asy.car_bol_gen a
             WHERE   a.key_cuo = p_man_aduana_ref
                     AND a.key_voy_nber = p_key_voy_nber_ref
                     AND a.key_dep_date =
                            TO_DATE (p_key_dep_date_ref, 'dd/mm/yyyy')
                     AND NOT a.carbol_frt_prep IN
                                     ('232',
                                      '234',
                                      '432',
                                      '736',
                                      '737',
                                      '738');
        ELSE
            SELECT   COUNT (1)
              INTO   res
              FROM   ops$asy.car_bol_gen a, ops$asy.car_gen b
             WHERE       a.key_cuo = b.key_cuo
                     AND a.key_voy_nber = b.key_voy_nber
                     AND a.key_dep_date = b.key_dep_date
                     AND b.key_cuo = p_man_aduana_reg
                     AND b.car_reg_year = p_man_gestion_reg
                     AND b.car_reg_nber = p_man_numero_reg
                     AND NOT a.carbol_frt_prep IN
                                     ('232',
                                      '234',
                                      '432',
                                      '736',
                                      '737',
                                      '738');
        END IF;


        RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            res := '0';

            RETURN res;
    END verifica_destino_zf;



    -----------------------------------------------------------------------------
    -- Verifica si existe manifiesto
    -----------------------------------------------------------------------------
    FUNCTION f_existe_manifiesto (
        p_key_voy_nber_ref    IN     ops$asy.car_gen.key_voy_nber%TYPE,
        p_man_aduana_ref      IN     ops$asy.car_gen.key_cuo%TYPE,
        p_key_dep_date_ref    IN     VARCHAR2,
        p_man_gestion_reg     IN     ops$asy.car_gen.car_reg_year%TYPE,
        p_man_aduana_reg      IN     ops$asy.car_gen.key_cuo%TYPE,
        p_man_numero_reg      IN     ops$asy.car_gen.car_reg_nber%TYPE,
        p_tipo                IN     VARCHAR2,
        ps_key_voy_nber_ref      OUT ops$asy.car_gen.key_voy_nber%TYPE,
        ps_man_aduana_ref        OUT ops$asy.car_gen.key_cuo%TYPE,
        ps_key_dep_date_ref      OUT VARCHAR2)
        RETURN VARCHAR2
    IS
        vhay_manif       NUMBER;
        p_car_reg_year   VARCHAR2 (5);
        p_car_reg_nber   NUMBER;
        res              NUMBER := 0;
    BEGIN
        IF (p_tipo = 'REF')
        THEN
            SELECT   COUNT (1)
              INTO   vhay_manif
              FROM   ops$asy.uncuotab b,
                     ops$asy.car_gen cg,
                     ops$asy.car_bol_gen cbg
             WHERE   cbg.key_cuo = p_man_aduana_ref
                     AND cbg.key_voy_nber = p_key_voy_nber_ref
                     AND cbg.key_dep_date =
                            TO_DATE (p_key_dep_date_ref, 'dd/mm/yyyy')
                     AND cg.key_cuo = cbg.key_cuo
                     AND cg.key_voy_nber = cbg.key_voy_nber
                     AND cg.key_dep_date = cbg.key_dep_date
                     AND cg.key_cuo = b.cuo_cod
                     AND b.lst_ope = 'U';
        ELSE
            SELECT   COUNT (1)
              INTO   vhay_manif
              FROM   ops$asy.uncuotab b,
                     ops$asy.car_gen cg,
                     ops$asy.car_bol_gen cbg
             WHERE       cg.car_reg_year = p_man_gestion_reg
                     AND cg.key_cuo = p_man_aduana_reg
                     AND cg.car_reg_nber = p_man_numero_reg
                     AND cg.key_cuo = cbg.key_cuo
                     AND cg.key_voy_nber = cbg.key_voy_nber
                     AND cg.key_dep_date = cbg.key_dep_date
                     AND cg.key_cuo = b.cuo_cod
                     AND b.lst_ope = 'U';
        END IF;



        IF (vhay_manif = 0)
        THEN
            RETURN 'El manifiesto no se encuentra registrado o memorizado';
        ELSE
            IF (p_tipo = 'REF')
            THEN
                SELECT   cg.key_cuo,
                         cg.key_voy_nber,
                         TO_CHAR (cg.key_dep_date, 'dd/mm/yyyy')
                  INTO   ps_man_aduana_ref,
                         ps_key_voy_nber_ref,
                         ps_key_dep_date_ref
                  FROM   ops$asy.car_gen cg
                 WHERE   cg.key_cuo = p_man_aduana_ref
                         AND cg.key_voy_nber = p_key_voy_nber_ref
                         AND cg.key_dep_date =
                                TO_DATE (p_key_dep_date_ref, 'dd/mm/yyyy');

                SELECT   COUNT (1)
                  INTO   vhay_manif
                  FROM   tra_inf_manifiesto cg
                 WHERE   cg.key_cuo = p_man_aduana_ref
                         AND cg.key_voy_nber = p_key_voy_nber_ref
                         AND cg.key_dep_date =
                                TO_DATE (p_key_dep_date_ref, 'dd/mm/yyyy')
                         AND cg.lst_ope = 'U'
                         AND cg.man_num = 0;

                IF (vhay_manif > 0)
                THEN
                    RETURN 'La aplicaci&oacute;n Control Documento de Embarque ya se encuentra registrada';
                END IF;
            ELSE
                SELECT   cg.key_cuo,
                         cg.key_voy_nber,
                         TO_CHAR (cg.key_dep_date, 'dd/mm/yyyy')
                  INTO   ps_man_aduana_ref,
                         ps_key_voy_nber_ref,
                         ps_key_dep_date_ref
                  FROM   ops$asy.car_gen cg
                 WHERE       cg.car_reg_year = p_man_gestion_reg
                         AND cg.key_cuo = p_man_aduana_reg
                         AND cg.car_reg_nber = p_man_numero_reg;

                SELECT   COUNT (1)
                  INTO   vhay_manif
                  FROM   tra_inf_manifiesto cg
                 WHERE   cg.key_cuo = ps_man_aduana_ref
                         AND cg.key_voy_nber = ps_key_voy_nber_ref
                         AND cg.key_dep_date =
                                TO_DATE (ps_key_dep_date_ref, 'dd/mm/yyyy')
                         AND cg.lst_ope = 'U'
                         AND cg.man_num = 0;

                IF (vhay_manif > 0)
                THEN
                    RETURN 'La aplicaci&oacute;n Control Documento de Embarque ya se encuentra registrada';
                END IF;
            END IF;


            RETURN 'SI';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            RETURN (SQLERRM);
    END f_existe_manifiesto;


    -----------------------------------------------------------------------------
    -- Verifica si existe manifiesto
    -----------------------------------------------------------------------------
    FUNCTION fe_existe_manifiesto (
        p_key_voy_nber_ref    IN     ops$asy.car_gen.key_voy_nber%TYPE,
        p_man_aduana_ref      IN     ops$asy.car_gen.key_cuo%TYPE,
        p_key_dep_date_ref    IN     VARCHAR2,
        p_man_gestion_reg     IN     ops$asy.car_gen.car_reg_year%TYPE,
        p_man_aduana_reg      IN     ops$asy.car_gen.key_cuo%TYPE,
        p_man_numero_reg      IN     ops$asy.car_gen.car_reg_nber%TYPE,
        p_tipo                IN     VARCHAR2,
        ps_key_voy_nber_ref      OUT ops$asy.car_gen.key_voy_nber%TYPE,
        ps_man_aduana_ref        OUT ops$asy.car_gen.key_cuo%TYPE,
        ps_key_dep_date_ref      OUT VARCHAR2)
        RETURN VARCHAR2
    IS
        vhay_manif       NUMBER;
        p_car_reg_year   VARCHAR2 (5);
        p_car_reg_nber   NUMBER;
        res              NUMBER := 0;
        v_key_cuo        ops$asy.car_gen.key_cuo%TYPE;
        v_key_voy_nber   ops$asy.car_gen.key_voy_nber%TYPE;
        v_key_dep_date   VARCHAR (20);
    BEGIN
        IF (p_tipo = 'REF')
        THEN
            SELECT   COUNT (1)
              INTO   vhay_manif
              FROM   ops$asy.uncuotab b,
                     ops$asy.car_gen cg,
                     ops$asy.car_bol_gen cbg
             WHERE   cbg.key_cuo = p_man_aduana_ref
                     AND cbg.key_voy_nber = p_key_voy_nber_ref
                     AND cbg.key_dep_date =
                            TO_DATE (p_key_dep_date_ref, 'dd/mm/yyyy')
                     AND cg.key_cuo = cbg.key_cuo
                     AND cg.key_voy_nber = cbg.key_voy_nber
                     AND cg.key_dep_date = cbg.key_dep_date
                     AND cg.key_cuo = b.cuo_cod
                     AND b.lst_ope = 'U';
        ELSE
            SELECT   COUNT (1)
              INTO   vhay_manif
              FROM   ops$asy.uncuotab b,
                     ops$asy.car_gen cg,
                     ops$asy.car_bol_gen cbg
             WHERE       cg.car_reg_year = p_man_gestion_reg
                     AND cg.key_cuo = p_man_aduana_reg
                     AND cg.car_reg_nber = p_man_numero_reg
                     AND cg.key_cuo = cbg.key_cuo
                     AND cg.key_voy_nber = cbg.key_voy_nber
                     AND cg.key_dep_date = cbg.key_dep_date
                     AND cg.key_cuo = b.cuo_cod
                     AND b.lst_ope = 'U';
        END IF;



        IF (vhay_manif = 0)
        THEN
            RETURN 'El manifiesto no se encuentra registrado o memorizado';
        ELSE
            IF (p_tipo = 'REF')
            THEN
                SELECT   cg.key_cuo,
                         cg.key_voy_nber,
                         TO_CHAR (cg.key_dep_date, 'dd/mm/yyyy')
                  INTO   ps_man_aduana_ref,
                         ps_key_voy_nber_ref,
                         ps_key_dep_date_ref
                  FROM   ops$asy.car_gen cg
                 WHERE   cg.key_cuo = p_man_aduana_ref
                         AND cg.key_voy_nber = p_key_voy_nber_ref
                         AND cg.key_dep_date =
                                TO_DATE (p_key_dep_date_ref, 'dd/mm/yyyy');

                SELECT   COUNT (1)
                  INTO   vhay_manif
                  FROM   tra_inf_manifiesto cg
                 WHERE   cg.key_cuo = p_man_aduana_ref
                         AND cg.key_voy_nber = p_key_voy_nber_ref
                         AND cg.key_dep_date =
                                TO_DATE (p_key_dep_date_ref, 'dd/mm/yyyy')
                         AND cg.lst_ope = 'U'
                         AND cg.man_num = 0;

                IF (vhay_manif = 0)
                THEN
                    RETURN 'No se registro el Control de Documento de Embarque';
                ELSE
                    vhay_manif :=
                        pkg_ds2295.verifica_enmienda_autprevia (
                            p_man_aduana_ref,
                            p_key_voy_nber_ref,
                            p_key_dep_date_ref);

                    IF (vhay_manif = 1)
                    THEN
                        RETURN 'No se puede enmendar, porque el manifiesto ya se encuentra asociado a una DUI';
                    END IF;
                END IF;
            ELSE
                SELECT   cg.key_cuo,
                         cg.key_voy_nber,
                         TO_CHAR (cg.key_dep_date, 'dd/mm/yyyy')
                  INTO   ps_man_aduana_ref,
                         ps_key_voy_nber_ref,
                         ps_key_dep_date_ref
                  FROM   ops$asy.car_gen cg
                 WHERE       cg.car_reg_year = p_man_gestion_reg
                         AND cg.key_cuo = p_man_aduana_reg
                         AND cg.car_reg_nber = p_man_numero_reg;

                SELECT   COUNT (1)
                  INTO   vhay_manif
                  FROM   tra_inf_manifiesto cg
                 WHERE   cg.key_cuo = ps_man_aduana_ref
                         AND cg.key_voy_nber = ps_key_voy_nber_ref
                         AND cg.key_dep_date =
                                TO_DATE (ps_key_dep_date_ref, 'dd/mm/yyyy')
                         AND cg.lst_ope = 'U'
                         AND cg.man_num = 0;

                IF (vhay_manif = 0)
                THEN
                    RETURN 'No se registro el Control de Documento de Embarque';
                else
                    SELECT   cg.key_cuo, cg.key_voy_nber, to_char(cg.key_dep_date,'dd/mm/yyyy')
                      INTO   v_key_cuo, v_key_voy_nber, v_key_dep_date
                      FROM   ops$asy.car_gen cg
                     WHERE       cg.car_reg_year = p_man_gestion_reg
                             AND cg.key_cuo = p_man_aduana_reg
                             AND cg.car_reg_nber = p_man_numero_reg;
                     vhay_manif :=
                        pkg_ds2295.verifica_enmienda_autprevia (
                            v_key_cuo,
                            v_key_voy_nber,
                            v_key_dep_date);

                    IF (vhay_manif = 1)
                    THEN
                        RETURN 'No se puede enmendar, porque el manifiesto ya se encuentra asociado a una DUI';
                    END IF;
                END IF;
            /*IF (vhay_manif > 0)
            THEN
                RETURN 'La aplicaci&oacute;n del DS2295 ya se encuentra registrada';
            END IF;*/
            END IF;


            RETURN 'SI';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            RETURN (SQLERRM);
    END fe_existe_manifiesto;


    -----------------------------------------------------------------------------
    -- GUARDA MANIFIESTO AUTORIZADO VERIFICADO LOS DOCMENTOS DE EMBARQUE
    -----------------------------------------------------------------------------

    FUNCTION graba_man_autorizado (prm_key_cuo        IN VARCHAR2,
                                   prm_key_voy_nber   IN VARCHAR2,
                                   prm_key_dep_date   IN VARCHAR2,
                                   prm_cantidad       IN VARCHAR2,
                                   prm_usuario        IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res                    VARCHAR2 (20);
        cant_docemb            NUMBER := 0;
        cant_docemb_tra        NUMBER := 0;
        cant_docemb_tra_aut    NUMBER := 0;
        cant_docemb_tra_prev   NUMBER := 0;
        vhay_manif             NUMBER := 0;
        estado                 VARCHAR2 (20);
    BEGIN
        SELECT   COUNT (1)
          INTO   cant_docemb
          FROM   car_bol_gen a
         WHERE   a.key_cuo = prm_key_cuo
                 AND a.key_voy_nber = prm_key_voy_nber
                 AND a.key_dep_date =
                        TO_DATE (prm_key_dep_date, 'dd/mm/yyyy');

        SELECT   COUNT (1)
          INTO   cant_docemb_tra
          FROM   tra_inf_docembarque a
         WHERE   a.key_cuo = prm_key_cuo
                 AND a.key_voy_nber = prm_key_voy_nber
                 AND a.key_dep_date =
                        TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                 AND a.docemb_num = 0
                 AND a.lst_ope = 'U';


        SELECT   COUNT (1)
          INTO   cant_docemb_tra_prev
          FROM   (SELECT   DISTINCT a.key_cuo,
                                    a.key_voy_nber,
                                    a.key_dep_date,
                                    a.key_bol_ref
                    FROM   tra_aut_previa a
                   WHERE   a.key_cuo = prm_key_cuo
                           AND a.key_voy_nber = prm_key_voy_nber
                           AND a.key_dep_date =
                                  TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                           AND a.apr_num = 0
                           AND a.apr_lstope = 'U') tbl;

        IF (cant_docemb = cant_docemb_tra)
        THEN
            IF (cant_docemb = cant_docemb_tra_prev)
            THEN
                /*IF (prm_cantidad = 'SI')
                THEN
                   estado   := NULL;
                ELSE*/
                SELECT   COUNT (1)
                  INTO   cant_docemb_tra_aut
                  FROM   tra_inf_docembarque a
                 WHERE   a.key_cuo = prm_key_cuo
                         AND a.key_voy_nber = prm_key_voy_nber
                         AND a.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                         AND a.docemb_est_autorizado = 'SA'
                         AND a.docemb_num = 0
                         AND a.lst_ope = 'U';

                IF (cant_docemb = cant_docemb_tra_aut)
                THEN
                    estado := 'DS2295';
                ELSE
                    estado := NULL;
                END IF;

                /*END IF;*/

                SELECT   COUNT (1)
                  INTO   vhay_manif
                  FROM   tra_inf_manifiesto cg
                 WHERE   cg.key_cuo = prm_key_cuo
                         AND cg.key_voy_nber = prm_key_voy_nber
                         AND cg.key_dep_date =
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy');



                IF (vhay_manif > 0)
                THEN
                    INSERT INTO tra_inf_manifiesto
                        SELECT   a.key_cuo,
                                 a.key_voy_nber,
                                 a.key_dep_date,
                                 a.man_cantidad,
                                 a.man_est_autorizado,
                                 a.man_usuario,
                                 vhay_manif,
                                 a.lst_ope,
                                 a.man_fecreg
                          FROM   tra_inf_manifiesto a
                         WHERE   a.key_cuo = prm_key_cuo
                                 AND a.key_voy_nber = prm_key_voy_nber
                                 AND a.key_dep_date =
                                        TO_DATE (prm_key_dep_date,
                                                 'dd/mm/yyyy')
                                 AND a.man_num = 0;

                    UPDATE   tra_inf_manifiesto
                       SET   man_cantidad = prm_cantidad,
                             man_est_autorizado = estado,
                             man_usuario = prm_usuario,
                             lst_ope = 'U',
                             man_fecreg = SYSDATE
                     WHERE   key_cuo = prm_key_cuo
                             AND key_voy_nber = prm_key_voy_nber
                             AND key_dep_date =
                                    TO_DATE (prm_key_dep_date, 'dd/mm/yyyy')
                             AND man_num = 0;
                ELSE
                    INSERT INTO tra_inf_manifiesto (key_cuo,
                                                    key_voy_nber,
                                                    key_dep_date,
                                                    man_cantidad,
                                                    man_est_autorizado,
                                                    man_usuario,
                                                    man_num,
                                                    lst_ope,
                                                    man_fecreg)
                      VALUES   (prm_key_cuo,
                                prm_key_voy_nber,
                                TO_DATE (prm_key_dep_date, 'dd/mm/yyyy'),
                                prm_cantidad,
                                estado,
                                prm_usuario,
                                0,
                                'U',
                                SYSDATE);
                END IF;

                res :=
                    graba_man_sidunea (prm_key_cuo,
                                       prm_key_voy_nber,
                                       prm_key_dep_date,
                                       estado);

                IF res <> 'SI'
                THEN
                    ROLLBACK;
                    RETURN 'No se pudo registrar la informaci&oacute;n en el manifiesto SIDUNEA++ : '
                           || res;
                END IF;
            ELSE
                RETURN 'Para registrar el Control de Documento de Embarque,  debe completar las autorizaciones previas de todos los documentos de embarque';
            END IF;
        ELSE
            RETURN 'Para registrar el Control de Documento de Embarque, debe completar la informacion de todos los documentos de embarque';
        END IF;

        COMMIT;
        RETURN 'SI';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SQLCODE || '-' || SQLERRM;
    END graba_man_autorizado;


    -----------------------------------------------------------------------------
    -- GUARDA MANIFIESTO AUTORIZADO VERIFICADO LOS DOCMENTOS DE EMBARQUE
    -----------------------------------------------------------------------------

    /*FUNCTION graba_docemb_no_autorizado (
        prm_key_cuo        IN VARCHAR2,
        prm_key_voy_nber   IN VARCHAR2,
        prm_key_dep_date   IN VARCHAR2,
        prm_usuario        IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR c_doc_embq
        IS
            SELECT   a.key_cuo,
                     a.key_voy_nber,
                     a.key_dep_date,
                     a.key_bol_ref,
                     a.docemb_adm_destino,
                     a.docemb_fecha_embarque,
                     a.docemb_silista_rs1392015,
                     a.docemb_si_pri_rs1692016,
                     a.docemb_si_seg_rs1692016,
                     a.docemb_otras_mercancias,
                     a.docemb_est_autorizado,
                     a.docemb_usuario,
                     a.docemb_num,
                     a.lst_ope,
                    -- a.docemb_cantidad,
                     a.docemb_fecreg
              FROM   tra_inf_docembarque a
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.key_voy_nber = prm_key_voy_nber
                     AND a.key_dep_date = TO_DATE(prm_key_dep_date,'dd/mm/yyyy')
                     AND a.docemb_num = 0
                     AND a.lst_ope = 'U'
                     AND a.docemb_est_autorizado = 'NA';



        res                          VARCHAR2 (20);
        cant_docemb                  NUMBER := 0;
        cant_docemb_tra              NUMBER := 0;
        cant_docemb_tra_aut          NUMBER := 0;
        cont                         NUMBER := 0;
        sw_nro                       NUMBER := 0;

        res                          VARCHAR2 (20);

        v_docemb_fecha_embarque      DATE;
        v_docemb_silista_rs1392015   VARCHAR2 (10);
        v_docemb_si_pri_rs1692016    VARCHAR2 (10);
        v_docemb_si_seg_rs1692016    VARCHAR2 (10);
        v_docemb_otras_mercancias    VARCHAR2 (10);
        v_docemb_cantidad            VARCHAR2 (10);

        estado                       VARCHAR2 (20);
        hay_dat_ds2295               NUMBER := 0;
    BEGIN
        SELECT   COUNT (1)
          INTO   cant_docemb
          FROM   car_bol_gen a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.key_voy_nber = prm_key_voy_nber
                 AND a.key_dep_date = TO_DATE(prm_key_dep_date,'dd/mm/yyyy');

        SELECT   COUNT (1)
          INTO   cant_docemb_tra
          FROM   tra_inf_docembarque a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.key_voy_nber = prm_key_voy_nber
                 AND a.key_dep_date = TO_DATE(prm_key_dep_date,'dd/mm/yyyy')
                 AND a.docemb_num = 0
                 AND a.lst_ope = 'U'
                 AND a.docemb_est_autorizado = 'NA';

        SELECT   COUNT (1)
          INTO   cant_docemb_tra_aut
          FROM   tra_inf_docembarque a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.key_voy_nber = prm_key_voy_nber
                 AND a.key_dep_date = TO_DATE(prm_key_dep_date,'dd/mm/yyyy')
                 AND a.docemb_num = 0
                 AND a.lst_ope = 'U'
                 AND a.docemb_est_autorizado = 'SA';


        IF (cant_docemb = cant_docemb_tra_aut)
        THEN
            RETURN    'El Manifiesto  '
                   || prm_key_dep_date
                   || ' '
                   || prm_key_cuo
                   || ' '
                   || prm_key_voy_nber
                   || ' ya fue autorizado con el DS2295';
        END IF;


        IF (cant_docemb = cant_docemb_tra)
        THEN
            --guardar reg
            FOR x IN c_doc_embq
            LOOP
                cont := cont + 1;


                --ACTUALIZA EN LA TABLA CAR_BOL_GEN LA LEYENDA DS2295 EN EL SHIPMARK5
                SELECT   COUNT (1)
                  INTO   hay_dat_ds2295
                  FROM   ops$asy.car_bol_gen
                 WHERE       key_cuo = x.key_cuo
                         AND key_voy_nber = x.key_voy_nber
                         AND key_dep_date = x.key_dep_date
                         AND key_bol_ref = x.key_bol_ref
                         AND carbol_shp_mark5 = 'DS2295';

                IF (hay_dat_ds2295 > 0)
                THEN
                    UPDATE   ops$asy.car_bol_gen
                       SET   carbol_shp_mark5 = ''
                     WHERE       key_cuo = x.key_cuo
                             AND key_voy_nber = x.key_voy_nber
                             AND key_dep_date = x.key_dep_date
                             AND key_bol_ref = x.key_bol_ref;
                END IF;



                SELECT   NVL (MAX (docemb_num), 0) + 1
                  INTO   sw_nro
                  FROM   tra_inf_docembarque
                 WHERE       key_cuo = x.key_cuo
                         AND key_voy_nber = x.key_voy_nber
                         AND key_dep_date = x.key_dep_date
                         AND key_bol_ref = x.key_bol_ref;



                UPDATE   tra_inf_docembarque
                   SET   docemb_num = sw_nro
                 WHERE       key_cuo = x.key_cuo
                         AND key_voy_nber = x.key_voy_nber
                         AND key_dep_date = x.key_dep_date
                         AND key_bol_ref = x.key_bol_ref
                         AND docemb_num = 0;

                INSERT INTO tra_inf_docembarque
                    SELECT   a.key_cuo,
                             a.key_voy_nber,
                             a.key_dep_date,
                             a.key_bol_ref,
                             a.docemb_adm_destino,
                             a.docemb_fecha_embarque,
                             a.docemb_silista_rs1392015,
                             a.docemb_si_pri_rs1692016,
                             a.docemb_si_seg_rs1692016,
                             a.docemb_otras_mercancias,
                             'NA',               --SI AUTORIZADO CON EL DS2295
                             prm_usuario,
                             0,
                             'U',
                            -- a.docemb_cantidad,
                             SYSDATE
                      FROM   tra_inf_docembarque a
                     WHERE       a.key_cuo = x.key_cuo
                             AND a.key_voy_nber = x.key_voy_nber
                             AND a.key_dep_date = x.key_dep_date
                             AND key_bol_ref = x.key_bol_ref
                             AND a.docemb_num = sw_nro
                             AND a.lst_ope = 'U'
                             AND a.docemb_est_autorizado = 'NA';

                sw_nro := 0;
            END LOOP;

            COMMIT;
        ELSE
            RETURN 'Para no autorizar seg&uacute;n DS2295 debe completar la informacion de todos los documentos de embarque';
        END IF;

        RETURN 'SI';

    END graba_docemb_no_autorizado;*/


    FUNCTION graba_man_sidunea (pr_key_cuo        IN VARCHAR2,
                                pr_key_voy_nber   IN VARCHAR2,
                                pr_key_dep_date   IN VARCHAR2,
                                pr_estado         IN VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR c_doc_embq_sid
        IS
            SELECT   a.key_cuo,
                     a.key_voy_nber,
                     a.key_dep_date,
                     a.key_bol_ref,
                     a.carbol_nat_cod
              FROM   ops$asy.car_bol_gen a
             WHERE   a.key_cuo = pr_key_cuo
                     AND a.key_voy_nber = pr_key_voy_nber
                     AND a.key_dep_date =
                            TO_DATE (pr_key_dep_date, 'dd/mm/yyyy');
    BEGIN
        --guardar reg
        FOR x IN c_doc_embq_sid
        LOOP
            UPDATE   ops$asy.car_bol_gen
               SET   carbol_shp_mark1 = '..'
             WHERE       key_cuo = x.key_cuo
                     AND key_voy_nber = x.key_voy_nber
                     AND key_dep_date = x.key_dep_date
                     AND key_bol_ref = x.key_bol_ref
                     AND carbol_shp_mark1 IS NULL;

            UPDATE   ops$asy.car_bol_gen
               SET   carbol_shp_mark2 = '..'
             WHERE       key_cuo = x.key_cuo
                     AND key_voy_nber = x.key_voy_nber
                     AND key_dep_date = x.key_dep_date
                     AND key_bol_ref = x.key_bol_ref
                     AND carbol_shp_mark2 IS NULL;

            UPDATE   ops$asy.car_bol_gen
               SET   carbol_shp_mark3 = '..'
             WHERE       key_cuo = x.key_cuo
                     AND key_voy_nber = x.key_voy_nber
                     AND key_dep_date = x.key_dep_date
                     AND key_bol_ref = x.key_bol_ref
                     AND carbol_shp_mark3 IS NULL;

            UPDATE   ops$asy.car_bol_gen
               SET   carbol_shp_mark4 = '..'
             WHERE       key_cuo = x.key_cuo
                     AND key_voy_nber = x.key_voy_nber
                     AND key_dep_date = x.key_dep_date
                     AND key_bol_ref = x.key_bol_ref
                     AND carbol_shp_mark4 IS NULL;

            IF (x.key_cuo = '722' AND x.carbol_nat_cod = 24)
               OR x.key_cuo IN
                         ('241',
                          '243',
                          '421',
                          '422',
                          '521',
                          '522',
                          '641',
                          '642',
                          '621',
                          '623',
                          '721')
            THEN
                --ACTUALIZA EN LA TABLA CAR_BOL_GEN LA LEYENDA DS2295 EN EL SHIPMARK5

                IF pr_estado = 'DS2295' THEN
                    UPDATE   ops$asy.car_bol_gen
                       SET   carbol_shp_mark5 = pr_estado
                     WHERE       key_cuo = x.key_cuo
                             AND key_voy_nber = x.key_voy_nber
                             AND key_dep_date = x.key_dep_date
                             AND key_bol_ref = x.key_bol_ref
                             AND ( not carbol_shp_mark5 like '%&C&%'
                                  OR carbol_shp_mark5 = 'DS2295');
                END IF;
            END IF;
        END LOOP;

        RETURN 'SI';
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SQLCODE || '-' || SQLERRM;
    END graba_man_sidunea;
END;
/

