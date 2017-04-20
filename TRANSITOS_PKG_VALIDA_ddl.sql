CREATE OR REPLACE 
PACKAGE pkg_valida
AS
   bcorrecto CONSTANT VARCHAR2(1) := 1;
   berror CONSTANT VARCHAR2(1) := 0;
END pkg_valida;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_valida
/* Formatted on 27/11/2014 21:31:01 (QP5 v5.126) */
AS
    --Modificado Edgar 27112014 Nuevo OCE
    v_fecha_corte   CONSTANT DATE := TO_DATE ('15/12/2015', 'dd/mm/yyyy');

    -- keycuo aduana del manifiesto o aduana del usuario
    -- lista_aduanas_usuario listado de aduanas
    FUNCTION varifica_aduana (keycuo                  IN tra_pla_rut.key_cuo%TYPE,
                              lista_aduanas_usuario   IN VARCHAR2)
        RETURN PLS_INTEGER
    IS
        hay           PLS_INTEGER;
        item_aduana   tra_pla_rut.key_cuo%TYPE;
        laduana       VARCHAR2 (20) := lista_aduanas_usuario;
    BEGIN
        IF (laduana = 'ALL')
        THEN
            RETURN bcorrecto;
        END IF;

        hay := INSTR (laduana, '-');

        WHILE hay > 0
        LOOP
            item_aduana := SUBSTR (laduana, 0, hay - 1);

            IF (keycuo = item_aduana)
            THEN
                RETURN bcorrecto;
            END IF;

            item_aduana := SUBSTR (item_aduana, hay + 1);
            hay := INSTR (item_aduana, '-');
        END LOOP;

        IF (keycuo = item_aduana)
        THEN
            RETURN bcorrecto;
        END IF;

        RETURN berror;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    -- keycuo aduana del manifiesto
    -- lista_aduanas_usuario listado de aduanas
    FUNCTION varifica_aduana_paso (keycuo                  IN tra_pla_rut.key_cuo%TYPE,
                                   lista_aduanas_usuario   IN VARCHAR2)
        RETURN PLS_INTEGER
    IS
        hay           PLS_INTEGER;
        aduana        tra_pla_rut.key_cuo%TYPE;
        item_aduana   tra_pla_rut.key_cuo%TYPE;
        laduana       VARCHAR2 (20) := lista_aduanas_usuario;
    BEGIN
        IF (laduana = 'ALL')
        THEN
            RETURN bcorrecto;
        END IF;

        SELECT   key_cuo_control
          INTO   aduana
          FROM   tra_adu_con
         WHERE   key_cuo_partida = keycuo;

        hay := INSTR (laduana, '-');

        WHILE hay > 0
        LOOP
            item_aduana := SUBSTR (laduana, 0, hay - 1);

            IF (aduana = item_aduana)
            THEN
                RETURN bcorrecto;
            END IF;

            item_aduana := SUBSTR (item_aduana, hay + 1);
            hay := INSTR (item_aduana, '-');
        END LOOP;

        IF (aduana = item_aduana)
        THEN
            RETURN bcorrecto;
        END IF;

        RETURN berror;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    FUNCTION empresa_vigente (empresa IN car_gen.car_car_cod%TYPE)
        RETURN PLS_INTEGER
    IS
        cantidad   PLS_INTEGER;
        hay        DECIMAL (3, 0);
    BEGIN
        /*
           SELECT
              count(1)
           INTO
              cantidad
           FROM
              operador.olopetab a, operador.olopetip b
           WHERE
              a.ope_nit = empresa AND a.emp_cod = b.emp_cod AND ope_tip IN ('TRN', 'TRE', 'NAL') AND b.ult_ver = 0 AND b.tbl_sta = 'H';
     */

        --Modificado Edgar 27112014 Nuevo OCE   QUERY 5

 SELECT count(1) INTO hay FROM ops$asy.bo_oce_opetipo x
     where x.ope_numerodoc = empresa and x.tip_tipooperador in ('TRN','TRE','NAL')
     and x.tip_num = 0 and x.tip_lst_ope = 'U' ;
/*
        SELECT   COUNT (1)
          INTO   hay
          FROM   ops$asy.bo_oce_opetipo ot
         WHERE       ot.tip_tipooperador IN ('TRN', 'TRE', 'NAL')
                 AND ot.ope_numerodoc = empresa
                 AND ot.tip_estado = 'H'
                 AND ot.tip_num = 0;*/


        IF hay = 0 AND SYSDATE < v_fecha_corte
        THEN
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   operador.olopetab a, operador.olopetip b
             WHERE       a.ope_nit = empresa
                     AND a.emp_cod = b.emp_cod
                     AND ope_tip IN ('TRN', 'TRE', 'NAL')
                     AND b.ult_ver = 0
                     AND b.tbl_sta = 'H';
        ELSE
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   ops$asy.bo_oce_opetipo ot
             WHERE       ot.tip_tipooperador IN ('TRN', 'TRE', 'NAL')
                     AND ot.ope_numerodoc = empresa
                     AND ot.tip_estado = 'H'
                     AND ot.tip_num = 0;
        END IF;



        IF (cantidad > 0)
        THEN
            RETURN bcorrecto;
        ELSE
            RETURN berror;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    FUNCTION placa_vigente (placa IN car_gen.car_id_trp%TYPE)
        RETURN PLS_INTEGER
    IS
        cantidad   PLS_INTEGER;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   ops$asy.unprptab
         WHERE   cmp_cod = placa AND lst_ope = 'U';

        IF (cantidad > 0)
        THEN
            RETURN bcorrecto;
        ELSE
            RETURN berror;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    FUNCTION placa_tna (placa IN car_gen.car_id_trp%TYPE)
        RETURN PLS_INTEGER
    IS
        cantidad   PLS_INTEGER;
    BEGIN
        IF (placa IN ('11111', '00000'))
        THEN
            RETURN bcorrecto;
        END IF;

        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut a, ops$asy.car_gen b
         WHERE       a.key_cuo = b.key_cuo
                 AND a.car_reg_year = b.car_reg_year
                 AND a.car_reg_nber = b.car_reg_nber
                 AND a.tra_num = 0
                 AND a.lst_ope = 'U'
                 AND b.car_id_trp = placa
                 AND NVL (a.tra_tipo, 22) <> 28
                 AND a.tra_loc = 0;

        IF (cantidad = 0)
        THEN
            RETURN bcorrecto;
        ELSE
            RETURN berror;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    FUNCTION empresa_acta_intervencion (empresa IN car_gen.car_car_cod%TYPE)
        RETURN PLS_INTEGER
    IS
        cantidad   PLS_INTEGER;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_acta
         WHERE       car_car_cod = empresa
                 AND tac_num = 0
                 AND tac_estado IN (0, 1)
                 AND lst_ope = 'U';

        IF (cantidad = 0)
        THEN
            RETURN bcorrecto;
        ELSE
            RETURN berror;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    FUNCTION placa_acta_intervencion (placa IN car_gen.car_id_trp%TYPE)
        RETURN PLS_INTEGER
    IS
        cantidad   PLS_INTEGER;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_acta
         WHERE       car_id_trp = placa
                 AND tac_num = 0
                 AND tac_estado IN (0, 2)
                 AND lst_ope = 'U';

        IF (cantidad = 0)
        THEN
            RETURN bcorrecto;
        ELSE
            RETURN berror;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    FUNCTION transito_registrado (keycuo    IN tra_pla_rut.key_cuo%TYPE,
                                  gestion   IN tra_pla_rut.car_reg_year%TYPE,
                                  serial    IN tra_pla_rut.car_reg_nber%TYPE)
        RETURN PLS_INTEGER
    IS
        cantidad   PLS_INTEGER;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND tra_num = 0
                 AND lst_ope = 'U';

        IF (cantidad > 0)
        THEN
            RETURN bcorrecto;
        ELSE
            RETURN berror;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    FUNCTION manifiesto_registrado (
        keycuo    IN tra_pla_rut.key_cuo%TYPE,
        gestion   IN tra_pla_rut.car_reg_year%TYPE,
        serial    IN tra_pla_rut.car_reg_nber%TYPE)
        RETURN PLS_INTEGER
    IS
        cantidad   PLS_INTEGER;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   ops$asy.car_bol_gen cb, ops$asy.car_gen cg
         WHERE       cb.key_cuo = cg.key_cuo
                 AND cb.key_voy_nber = cg.key_voy_nber
                 AND cb.key_dep_date = cg.key_dep_date
                 AND cg.key_cuo = keycuo
                 AND cg.car_reg_year = gestion
                 AND cg.car_reg_nber = serial
                 AND cb.carbol_nat_cod = '24'
                 AND NOT cb.carbol_frt_prep IS NULL
                 AND NOT cb.key_bol_ref IN
                                 (SELECT   key_bol_ref
                                    FROM   ops$asy.car_spy
                                   WHERE       key_cuo = cb.key_cuo
                                           AND key_voy_nber = cb.key_voy_nber
                                           AND key_dep_date = cb.key_dep_date
                                           AND spy_sta = 11);

        IF (cantidad > 0)
        THEN
            RETURN bcorrecto;
        ELSE
            RETURN berror;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN berror;
    END;

    FUNCTION valida_proceso (keycuo          IN tra_pla_rut.key_cuo%TYPE,
                             gestion         IN tra_pla_rut.car_reg_year%TYPE,
                             serial          IN tra_pla_rut.car_reg_nber%TYPE,
                             aduanausuario   IN tra_pla_rut.key_cuo%TYPE,
                             lista_aduanas   IN VARCHAR2,
                             operacion       IN NUMBER)
        RETURN VARCHAR2
    IS
        validar   tra_val_tra%ROWTYPE;
        msg       VARCHAR2 (500) := '';
    BEGIN
        SELECT   *
          INTO   validar
          FROM   tra_val_tra
         WHERE   tratipo = operacion;

        IF (validar.tvtusuaduini = 1)
        THEN
            IF (varifica_aduana (keycuo, lista_aduanas) = berror)
            THEN
                msg := msg || 'No esta habilitado para Iniciar Transito.';
                RETURN msg;
            END IF;
        END IF;

        IF (validar.tctusuadupas = 1)
        THEN
            IF (varifica_aduana_paso (keycuo, lista_aduanas) = berror)
            THEN
                msg :=
                    msg
                    || 'No esta habilitado para registrar la Aduana de Paso/.';
                RETURN msg;
            END IF;
        END IF;

        IF (validar.tvtusuadudes = 1)
        THEN
            IF (varifica_aduana (aduanausuario, lista_aduanas) = berror)
            THEN
                msg :=
                    msg
                    || 'No esta habilitado para registrar la Aduana de Destino.';
                RETURN msg;
            END IF;
        END IF;

        IF (validar.tvtempcod = 1)
        THEN
            IF (empresa_vigente ('1111112333') = berror)
            THEN
                msg :=
                    msg
                    || 'No esta habilitado para registrar la Aduana de Destino.';
                RETURN msg;
            END IF;
        END IF;
    END;
END pkg_valida;
/

