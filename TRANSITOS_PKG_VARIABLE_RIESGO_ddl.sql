CREATE OR REPLACE 
PACKAGE pkg_variable_riesgo
/* Formatted on 29-mar-2016 11:30:05 (QP5 v5.126) */
AS
    TYPE cursortype IS REF CURSOR;

    FUNCTION graba_variable (
        prm_variable       IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor          IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_fecha_inicio   IN tra_variable_riesgo.tvr_fecha_inicio%TYPE,
        prm_usuario        IN tra_variable_riesgo.tvr_usr%TYPE,
        prm_criterio       IN tra_variable_riesgo.tvr_criterio%TYPE,
        prm_criterio_otro  IN tra_variable_riesgo.tvr_criterio_otro%TYPE)
        RETURN VARCHAR2;

    FUNCTION habilita_variable (
        prm_variable       IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor          IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_fecha_inicio   IN tra_variable_riesgo.tvr_fecha_inicio%TYPE,
        prm_observacion    IN tra_variable_riesgo.tvr_observacion%TYPE,
        prm_usuario        IN tra_variable_riesgo.tvr_usr%TYPE)
        RETURN VARCHAR2;

    FUNCTION deshabilita_variable (
        prm_variable                IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor                   IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_fecha_deshabilitacion   IN tra_variable_riesgo.tvr_fecha_inicio%TYPE,
        prm_observacion             IN tra_variable_riesgo.tvr_observacion%TYPE,
        prm_usuario                 IN tra_variable_riesgo.tvr_usr%TYPE)
        RETURN VARCHAR2;

    FUNCTION graba_manifiesto_riesgo (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE)
        RETURN VARCHAR2;

    FUNCTION graba_var_manifiesto_riesgo (
        prm_variable       IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor          IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE)
        RETURN VARCHAR2;

    PROCEDURE evalua_riesgo (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE);


    FUNCTION lista_paises
        RETURN cursortype;

    FUNCTION lista_variables_riesgo (
        prm_variable IN tra_variable_riesgo.tvr_variable%TYPE)
        RETURN cursortype;

    FUNCTION lista_var_manifiesto_riesgo (
        prm_variable   IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor      IN tra_variable_riesgo.tvr_valor%TYPE)
        RETURN cursortype;


    FUNCTION cant_riesgo (
        prm_variable IN tra_variable_riesgo.tvr_variable%TYPE)
        RETURN NUMBER;


    FUNCTION cant_estado (
        prm_variable   IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_estado     IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION devuelve_pais (
        prm_cod_pais IN tra_variable_riesgo.tvr_valor%TYPE)
        RETURN VARCHAR2;


    function lista_usuarios_correo
    return cursortype;


    FUNCTION devuelve_nit (prm_nit IN tra_variable_riesgo.tvr_valor%TYPE)
        RETURN VARCHAR2;

    FUNCTION devuelve_consignatario (
        prm_consignatario IN tra_variable_riesgo.tvr_valor%TYPE)
        RETURN VARCHAR2;

    FUNCTION devuelve_variables_asociadas (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE)
        RETURN VARCHAR2;
 FUNCTION devuelve_variables_asoc_table (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE)
        RETURN VARCHAR2;

    FUNCTION cant_evalua (
        prm_variable   IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_estado     IN VARCHAR2)
        RETURN NUMBER;



    FUNCTION cant_riesgo_f (
        prm_variable    IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_fec_desde   IN VARCHAR2,
        prm_fec_hasta   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION cant_estado_f (
        prm_variable    IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_estado      IN VARCHAR2,
        prm_fec_desde   IN VARCHAR2,
        prm_fec_hasta   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION cant_evalua_f (
        prm_variable    IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_estado      IN VARCHAR2,
        prm_fec_desde   IN VARCHAR2,
        prm_fec_hasta   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION cant_evalua_fvar (
        prm_variable    IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor       IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_estado      IN VARCHAR2,
        prm_fec_desde   IN VARCHAR2,
        prm_fec_hasta   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION reporte1 (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype;

    FUNCTION devuelve_mic (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE)
        RETURN cursortype;

    FUNCTION reporte2 (prm_fec_desde   IN VARCHAR2,
                       prm_fec_hasta   IN VARCHAR2,
                       prm_tipo        IN VARCHAR2)
        RETURN cursortype;

    FUNCTION reporte3 (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype;

    FUNCTION reporte4 (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype;

    FUNCTION reporte5 (prm_fec_desde   IN VARCHAR2,
                       prm_fec_hasta   IN VARCHAR2,
                       prm_tipo        IN VARCHAR2)
        RETURN cursortype;

    FUNCTION reporte6 (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype;

    FUNCTION lista_mic (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype;

    FUNCTION lista_riesgo_mic (prm_key_cuo        IN VARCHAR2,
                               prm_car_reg_year   IN VARCHAR2,
                               prm_car_reg_nber   IN VARCHAR2)
        RETURN cursortype;

    FUNCTION mic_observado (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE,
        prm_resultado      IN tra_manifiesto_riesgo.tmr_resultado%TYPE)
        RETURN VARCHAR2;

    FUNCTION mic_sinobservacion (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE,
        prm_resultado      IN tra_manifiesto_riesgo.tmr_resultado%TYPE)
        RETURN VARCHAR2;

  FUNCTION modifica_enviocorreo (
        prm_usuario   IN VARCHAR2,
        prm_estado      IN VARCHAR2,
        prm_usr        IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE evaluar_variable_riesgo;


  PROCEDURE send_email_manifiesto_riesgo (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE,
        prm_etapa          IN VARCHAR2);



END pkg_variable_riesgo;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_variable_riesgo
/* Formatted on 26/04/2016 19:12:49 (QP5 v5.126) */
AS


    FUNCTION modifica_enviocorreo (
        prm_usuario   IN VARCHAR2,
        prm_estado      IN VARCHAR2,
        prm_usr        IN VARCHAR2)
        RETURN VARCHAR2
    IS
        version     NUMBER;
        existe      NUMBER;
    BEGIN

        SELECT COUNT(1) INTO existe
        FROM tra_variable_riesgo_correo a
        WHERE a.trc_usuario = prm_usuario;


            if existe > 0 then

                SELECT max(a.trc_num) INTO version
                FROM tra_variable_riesgo_correo a
                WHERE a.trc_usuario = prm_usuario;

                update tra_variable_riesgo_correo
                set trc_num = version + 1
                WHERE trc_usuario = prm_usuario
                and trc_num = 0;

                insert INTO tra_variable_riesgo_correo values (prm_usuario, prm_estado, 'U', 0, prm_usr, sysdate );

            else

                insert INTO tra_variable_riesgo_correo values (prm_usuario, prm_estado, 'U', 0, prm_usr, sysdate );

            end if;

        COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            RETURN    SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255)
                || ' - USUARIO CORREO '
                || prm_usuario
                || ' '
                || prm_estado
                || ' '
                || prm_usr
                || ' - '
                || TO_CHAR(sysdate,'dd/mm/yyyy hh24:mi');
    END modifica_enviocorreo;




    FUNCTION graba_variable (
        prm_variable       IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor          IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_fecha_inicio   IN tra_variable_riesgo.tvr_fecha_inicio%TYPE,
        prm_usuario        IN tra_variable_riesgo.tvr_usr%TYPE,
        prm_criterio       IN tra_variable_riesgo.tvr_criterio%TYPE,
        prm_criterio_otro  IN tra_variable_riesgo.tvr_criterio_otro%TYPE)
        RETURN VARCHAR2
    IS
        fecha_des   DATE;
        existe      NUMBER;
    BEGIN
        IF prm_fecha_inicio IS NULL
        THEN
            fecha_des := SYSDATE;
        ELSE
            fecha_des := TO_DATE (prm_fecha_inicio, 'dd/mm/yyyy');
        END IF;

        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = UPPER (prm_valor)
                 AND a.tvr_lstope = 'U'
                 AND a.tvr_num = 0;

        --VALIDACION DE EXISTENCIA DE LA VARIABLE DE RIESGO
        IF (existe > 0)
        THEN
            RETURN 'ERRORLA VARIABLE DE RIESGO YA SE ENCUENTRA REGISTRADA';
        ELSE
            --VALIDACION INDIVIDUAL POR TIPO DE VARIABLE

            --POR PLACA
            IF (prm_variable = 'PLACA')
            THEN
                SELECT   COUNT (1)
                  INTO   existe
                  FROM   ops$asy.unprptab a
                 WHERE   a.cmp_cod = UPPER (prm_valor);

                IF (existe = 0)
                THEN
                    RETURN 'ERRORLA PLACA DEL MEDIO NO SE ENCUENTRA REGISTRADA';
                END IF;
            END IF;

            --POR NIT
            IF (prm_variable = 'NIT')
            THEN
                SELECT   COUNT (1)
                  INTO   existe
                  FROM   ops$asy.uncartab a
                 WHERE   a.car_cod = prm_valor;

                IF (existe = 0)
                THEN
                    RETURN 'ERRORLA NIT DE LA EMPRESA DE TRANSPORTE NO SE ENCUENTRA REGISTRADO';
                END IF;
            END IF;

            --POR CONSIGNATARIO
            IF (prm_variable = 'CONSIGNATARIO')
            THEN
                SELECT   COUNT (1)
                  INTO   existe
                  FROM   ops$asy.uncmptab a
                 WHERE   a.cmp_cod = prm_valor;

                IF (existe = 0)
                THEN
                    RETURN 'ERRORLA NIT DE LA EMPRESA DE TRANSPORTE NO SE ENCUENTRA REGISTRADO';
                END IF;
            END IF;

            INSERT INTO tra_variable_riesgo (tvr_variable,
                                             tvr_valor,
                                             tvr_estado,
                                             tvr_fecha_inicio,
                                             tvr_fecha_vencimiento,
                                             tvr_observacion,
                                             tvr_lstope,
                                             tvr_num,
                                             tvr_usr,
                                             tvr_fec,
                                             tvr_criterio,
                                             tvr_criterio_otro)
              VALUES   (prm_variable,
                        UPPER (prm_valor),
                        'HABILITADO',
                        fecha_des,
                        fecha_des + 45,
                        NULL,
                        'U',
                        0,
                        prm_usuario,
                        SYSDATE,
                        UPPER(prm_criterio),
                        UPPER(prm_criterio_otro));

            COMMIT;
            RETURN 'CORRECTO';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN    'ERROR'
                   || SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255)
                   || ' - '
                   || prm_variable
                   || ':'
                   || prm_valor
                   || ' '
                   || prm_fecha_inicio
                   || ' - '
                   || prm_usuario

;
    END graba_variable;

    FUNCTION habilita_variable (
        prm_variable       IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor          IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_fecha_inicio   IN tra_variable_riesgo.tvr_fecha_inicio%TYPE,
        prm_observacion    IN tra_variable_riesgo.tvr_observacion%TYPE,
        prm_usuario        IN tra_variable_riesgo.tvr_usr%TYPE)
        RETURN VARCHAR2
    IS
        version     NUMBER;
        fecha_des   DATE;
        existe      NUMBER;
    BEGIN
        IF prm_fecha_inicio IS NULL
        THEN
            fecha_des := SYSDATE;
        ELSE
            fecha_des := TO_DATE (prm_fecha_inicio, 'dd/mm/yyyy');
        END IF;

        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = prm_valor
                 AND a.tvr_lstope = 'U'
                 AND a.tvr_num = 0;

        --VALIDACION DE EXISTENCIA DE LA VARIABLE DE RIESGO
        IF (existe = 0)
        THEN
            RETURN 'ERRORNO EXISTE LA VARIABLE DE RIESGO';
        END IF;

        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = prm_valor
                 AND a.tvr_lstope = 'U'
                 AND a.tvr_num = 0
                 AND tvr_estado = 'DESHABILITADO';

        --VALIDACION DE ESTADO DE LA VARIABLE DE RIESGO
        IF (existe = 0)
        THEN
            RETURN 'ERRORLA VARIABLE DE RIESGO SE ENCUENTRA HABILITADA';
        END IF;


        SELECT   MAX (a.tvr_num)
          INTO   version
          FROM   tra_variable_riesgo a
         WHERE   a.tvr_variable = prm_variable AND a.tvr_valor = prm_valor;

        UPDATE   tra_variable_riesgo a
           SET   a.tvr_num = version + 1
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = prm_valor
                 AND a.tvr_num = 0;

        INSERT INTO tra_variable_riesgo (tvr_variable,
                                         tvr_valor,
                                         tvr_estado,
                                         tvr_fecha_inicio,
                                         tvr_fecha_vencimiento,
                                         tvr_observacion,
                                         tvr_lstope,
                                         tvr_num,
                                         tvr_usr,
                                         tvr_fec,
                                         tvr_criterio,
                                         tvr_criterio_otro)
            SELECT   tvr_variable,
                     tvr_valor,
                     'HABILITADO',
                     fecha_des,
                     fecha_des + 45,
                     prm_observacion,
                     'U',
                     0,
                     prm_usuario,
                     SYSDATE,
                     tvr_criterio,
                     tvr_criterio_otro
              FROM   tra_variable_riesgo a
             WHERE       a.tvr_variable = prm_variable
                     AND a.tvr_valor = prm_valor
                     AND tvr_num = version + 1;



        COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            RETURN    SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255)
                   || ' - HABILITACION RIESGO '
                   || prm_variable
                   || ':'
                   || prm_valor
                   || ' '
                   || prm_fecha_inicio
                   || ' - '
                   || prm_usuario;
    END habilita_variable;

    FUNCTION deshabilita_variable (
        prm_variable                IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor                   IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_fecha_deshabilitacion   IN tra_variable_riesgo.tvr_fecha_inicio%TYPE,
        prm_observacion             IN tra_variable_riesgo.tvr_observacion%TYPE,
        prm_usuario                 IN tra_variable_riesgo.tvr_usr%TYPE)
        RETURN VARCHAR2
    IS
        version     NUMBER;
        fecha_des   DATE;
        existe      NUMBER;
    BEGIN
        IF prm_fecha_deshabilitacion IS NULL
        THEN
            fecha_des := SYSDATE;
        ELSE
            fecha_des := TO_DATE (prm_fecha_deshabilitacion, 'dd/mm/yyyy');
        END IF;

        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = prm_valor
                 AND a.tvr_lstope = 'U'
                 AND a.tvr_num = 0;

        --VALIDACION DE EXISTENCIA DE LA VARIABLE DE RIESGO
        IF (existe = 0)
        THEN
            RETURN 'ERRORNO EXISTE LA VARIABLE DE RIESGO';
        END IF;

        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = prm_valor
                 AND a.tvr_lstope = 'U'
                 AND a.tvr_num = 0
                 AND tvr_estado = 'HABILITADO';

        --VALIDACION DE ESTADO DE LA VARIABLE DE RIESGO
        IF (existe = 0)
        THEN
            RETURN 'ERRORLA VARIABLE DE RIESGO SE ENCUENTRA DESHABILITADA';
        END IF;

        SELECT   MAX (a.tvr_num)
          INTO   version
          FROM   tra_variable_riesgo a
         WHERE   a.tvr_variable = prm_variable AND a.tvr_valor = prm_valor;

        UPDATE   tra_variable_riesgo a
           SET   a.tvr_num = version + 1
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = prm_valor
                 AND a.tvr_num = 0;

        INSERT INTO tra_variable_riesgo (tvr_variable,
                                         tvr_valor,
                                         tvr_estado,
                                         tvr_fecha_inicio,
                                         tvr_fecha_vencimiento,
                                         tvr_observacion,
                                         tvr_lstope,
                                         tvr_num,
                                         tvr_usr,
                                         tvr_fec,
                                         tvr_criterio,
                                         tvr_criterio_otro)
            SELECT   tvr_variable,
                     tvr_valor,
                     'DESHABILITADO',
                     tvr_fecha_inicio,
                     fecha_des,
                     prm_observacion,
                     'U',
                     0,
                     prm_usuario,
                     SYSDATE,
                     tvr_criterio,
                     tvr_criterio_otro
              FROM   tra_variable_riesgo a
             WHERE       a.tvr_variable = prm_variable
                     AND a.tvr_valor = prm_valor
                     AND tvr_num = version + 1;


        COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            RETURN    SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255)
                   || ' - DESHABILITACION RIESGO '
                   || prm_variable
                   || ':'
                   || prm_valor
                   || ' '
                   || prm_fecha_deshabilitacion
                   || ' - '
                   || prm_usuario;
    END deshabilita_variable;

    FUNCTION graba_manifiesto_riesgo (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE)
        RETURN VARCHAR2
    IS
    BEGIN
        INSERT INTO tra_manifiesto_riesgo (key_cuo,
                                           car_reg_year,
                                           car_reg_nber,
                                           tmr_fecha_registro,
                                           tmr_estado,
                                           tmr_lstope,
                                           tmr_num,
                                           tmr_usr,
                                           tmr_fec)
          VALUES   (prm_key_cuo,
                    prm_car_reg_year,
                    prm_car_reg_nber,
                    SYSDATE,
                    'PENDIENTE',
                    'U',
                    0,
                    prm_usuario,
                    SYSDATE);


        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN    SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255)
                   || ' - '
                   || prm_key_cuo
                   || '/'
                   || prm_car_reg_year
                   || '/'
                   || prm_car_reg_nber
                   || ' - '
                   || prm_usuario
;
    END graba_manifiesto_riesgo;


    PROCEDURE send_email_manifiesto_riesgo (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE,
        prm_etapa          IN VARCHAR2)
    IS
        mensaje          VARCHAR2 (100) := '';
        datos_cabecera   VARCHAR2 (2000) := '';
        datos_detalle    VARCHAR2 (30000) := ' ';
        datos_footer     VARCHAR2 (200) := '';
        variables        VARCHAR2 (2000) := '';
        cont             NUMBER := 0;
        conta            NUMBER := 0;
        contb            NUMBER := 0;
    BEGIN

        variables :=
            '<table cellspacing="0" cellpadding="3" border="1" align="center"><tr><th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">VARIABLES DE RIESGO</th><th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">RIESGO</th></tr>'
            || pkg_variable_riesgo.devuelve_variables_asoc_table (
                   prm_key_cuo,
                   prm_car_reg_year,
                   prm_car_reg_nber)
            || '</table>';
        variables :=
            REPLACE (
                variables,
                '*-',
                '<tr style="color:rgb(0,78,155);background-color:rgb(224,239,254);font-size:10px"><td>');
        variables := REPLACE (variables, '--', '<td></td>');
        variables := REPLACE (variables, '-*', '</td></tr>');


        FOR j
        IN (  SELECT   cg.key_cuo,
                       cg.car_reg_year,
                       cg.car_reg_nber,
                       a.key_secuencia,
                       cbg.key_bol_ref,
                          '<tr><th style="text-align:right;">MIC:</th><td>'
                       || cg.key_cuo
                       || '/'
                       || cg.car_reg_year
                       || '/'
                       || cg.car_reg_nber
                       || '</td></tr>'
                       || '<tr><th style="text-align:right;">Empresa:</th><td>'
                       || cg.car_car_cod
                       || ': '
                       || cg.car_car_nam
                       || '</td></tr>'
                       || '<tr><th style="text-align:right;">Placa:</th><td>'
                       || cg.car_id_trp
                       || '</td></tr>'
                       || '<tr><th style="text-align:right;">Fecha de Registro del Manifiesto:</th><td>'
                       || TO_CHAR (cg.car_reg_date, 'DD/MM/YYYY')
                       || ''
                       || cg.car_reg_time
                       || '</td></tr>'
                       || '<tr><th style="text-align:right;">T&eacute;cnico Aduanero:</th><td>'
                       || devuelve_tecnicos_operaciones (a.key_cuo,
                                                         a.car_reg_year,
                                                         a.car_reg_nber,
                                                         a.key_secuencia)
                       || '</td></tr>'
                       || '<tr><th style="text-align:right;">Conductor:</th><td>'
                       || NVL (cg.car_mast_nam, '-')
                       || ' '
                       || NVL (car_mast_inf1, ' ')
                       || ' '
                       || NVL (car_mast_inf2, ' ')
                       || '</td></tr>'
                       || '<tr><th style="text-align:right;">Precintos:</th><td>'
                       || NVL (a.tra_pre, '&nbsp;')
                       || '</td></tr>'
                           cabecera,
                       '<tr  style="color:rgb(0,78,155);background-color:rgb(224,239,254);font-size:10px"><td>'
                       || cg.key_cuo
                       || '/'
                       || cg.car_reg_year
                       || '/'
                       || cg.car_reg_nber
                       || ' - '
                       || a.key_secuencia
                       || '</td><td>'
                       || cbg.key_bol_ref
                       || '</td><td>'
                       || TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:mi')
                       || '</td><td>'
                       || a.tra_cuo_ini
                       || ': '
                       || b.cuo_nam
                       || '</td><td>'
                       || NVL (TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:mi'),
                               TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:mi'))
                       || '</td><td>'
                       || DECODE (a.tra_cuo_des,
                                  NULL, a.tra_cuo_est || ': ' || c.cuo_nam,
                                  a.tra_cuo_des || ': ' || d.cuo_nam)
                       || '</td><td>'
                       || DECODE (
                              a.lst_ope,
                              'D',
                              'CANCELADO',
                              'M',
                              'SIN SALIDA DE PUERTO',
                              DECODE (
                                  DECODE (a.tra_fec_des, NULL, 2, a.tra_loc),
                                  1,
                                  'CONCLUIDO',
                                  0,
                                  'SIN LOCALIZACION',
                                  2,
                                  CASE
                                      WHEN TRUNC (SYSDATE - a.tra_fec_est) <= 0
                                      THEN
                                          'EN TRANSITO'
                                      ELSE
                                          DECODE (tiene_acta (a.key_cuo,
                                                              a.car_reg_year,
                                                              a.car_reg_nber,
                                                              a.key_secuencia),
                                                  '-', 'FUERA DE PLAZO',
                                                  tiene_acta (a.key_cuo,
                                                              a.car_reg_year,
                                                              a.car_reg_nber,
                                                              a.key_secuencia))
                                  END))
                       || '</td><td>'
                       || NVL (cbg.carbol_cons_cod, ' ')
                       || ':'
                       || cbg.carbol_cons_nam
                       || '</td><td>'
                       || cbg.carbol_exp_nam
                       || '</td><td>'
                       || NVL (cbg.carbol_good1, ' ')
                       || NVL (cbg.carbol_good2, ' ')
                       || NVL (cbg.carbol_good3, ' ')
                       || NVL (cbg.carbol_good4, ' ')
                       || NVL (cbg.carbol_good5, '&nbsp;')
                       || '</td><td>'
                       || NVL (cbg.carbol_infos1, ' ')
                       || ' '
                       || NVL (cbg.carbol_infos2, '&nbsp;')
                       || '</td><td>'
                       || carbol_gros_mas
                       || '</td><td>'
                       || carbol_pack_nber
                       || ' '
                       || upt.pkg_dsc
                           detalle
                FROM   transitos.tra_pla_rut a,
                       ops$asy.uncuotab b,
                       ops$asy.uncuotab c,
                       ops$asy.uncuotab d,
                       ops$asy.car_gen cg,
                       ops$asy.car_bol_gen cbg,
                       ops$asy.unpkgtab upt,
                       tra_manifiesto_riesgo manr
               WHERE       upt.pkg_cod = cbg.carbol_pack_cod
                       AND a.key_cuo = cg.key_cuo
                       AND a.car_reg_year = cg.car_reg_year
                       AND a.car_reg_nber = cg.car_reg_nber
                       AND cg.key_cuo = cbg.key_cuo
                       AND cg.key_voy_nber = cbg.key_voy_nber
                       AND cg.key_dep_date = cbg.key_dep_date
                       AND a.key_cuo = manr.key_cuo
                       AND a.car_reg_year = manr.car_reg_year
                       AND a.car_reg_nber = manr.car_reg_nber
                       AND manr.tmr_num = 0
                       AND manr.tmr_lstope = 'U'
                       AND cbg.carbol_nat_cod = '24'
                       AND cbg.carbol_typ_cod <> 'LTR'
                       AND a.tra_cuo_ini = b.cuo_cod
                       AND b.lst_ope = 'U'
                       AND NVL (a.tra_cuo_des, a.tra_cuo_est) = c.cuo_cod
                       AND c.lst_ope = 'U'
                       AND a.tra_cuo_des = d.cuo_cod(+)
                       AND d.lst_ope(+) = 'U'
                       AND a.tra_num = 0
                       AND a.lst_ope <> 'D'
                       AND a.key_secuencia <> 0
                       AND a.key_cuo = prm_key_cuo
                       AND a.car_reg_year = prm_car_reg_year
                       AND a.car_reg_nber = prm_car_reg_nber
            ORDER BY   4, 5)
        LOOP
            IF cont = 0
            THEN
                datos_cabecera := j.cabecera;
                cont := 1;
            END IF;

            IF LENGTH (datos_detalle) <= 25000
            THEN
                datos_detalle := datos_detalle || j.detalle;
            ELSE
                IF conta = 0
                THEN
                    datos_detalle :=
                        datos_detalle
                        || '<tr><td colspan="13" style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px" >PUEDE VISUALIZAR LOS DEMAS REGISTROS EN EL SISTEMA WEB TRANSITOS</td></tr>';
                    conta := 1;
                END IF;
            END IF;
        END LOOP;



        FOR i
        IN (select usucorreo FROM ( SELECT   a.usucodusu, u.usucorreo,
                     NVL (c.trc_estado, 'HABILITADO') estado

              FROM   usuario.usu_rol a,
                     usuario.usuario u,
                     tra_variable_riesgo_correo c
             WHERE   a.rol_cod IN
                             ('GNF_RIESGOADMINISTRADOR', 'GNF_RIESGOOPERADOR')
                     AND a.lst_ope = 'U'
                     AND a.ult_ver = 0
                     AND u.lst_ope = 'U'
                     AND u.usu_num = 0
                     AND a.usucodusu = u.usucodusu
                     AND u.usucodusu = c.trc_usuario(+)
                     AND c.trc_lstope(+) = 'U'
                     AND c.trc_num(+) = 0) tbl where tbl.estado = 'HABILITADO')
        LOOP
            IF prm_etapa = 'inicio'
            THEN
                SELECT   DECODE (
                             SUBSTR (prm_key_cuo, 0, 1),
                             '0',
                             '<br><br>Realiz&oacute; el registro de la operaci&oacute;n de MIC Anticipado en fecha: ',
                             '<br><br>Realiz&oacute; el registro de la operaci&oacute;n de Inicio de Transito en fecha: ')
                  INTO   mensaje
                  FROM   DUAL;


                html_email (
                    i.usucorreo,
                    'transitos_riesgo@aduana.gob.bo',
                    'Control de variables de riesgos en el sistema Transitos Web',
                    '.',
                       'Se&ntilde;or(a) : <br>'
                    || '<br>'
                    || 'El manifiesto&nbsp;<B>: </B>'
                    || prm_car_reg_year
                    || '/'
                    || prm_key_cuo
                    || '/'
                    || prm_car_reg_nber
                    || '<br><br>Realiz&oacute; el registro de la operaci&oacute;n de Inicio de Transito en fecha:'
                    || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi')
                    || '<br><br><br>'
                    || '<table width="90%" cellspacing="0" cellpadding="3" border="0" align="center" style="font-size:12px"><tbody>'
                    || datos_cabecera
                    || datos_footer
                    || '</tbody></table>'
                    || '<table width="90%" cellspacing="0" cellpadding="3" border="0" align="center" style="font-size:12px">
                        <tbody>
                        <tr><td>&nbsp</td></tr>
                        <tr>
                            <th style="text-align: center;"><label style="font-size: 12px;">Detalle de Documentos de Embarque</label></th>
                        </tr>
                    </tbody></table>

                    <table width="90%" cellspacing="0" cellpadding="3" border="1" align="center">
                      <tbody><tr class="t14">
                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Manifiesto</th>
                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Documento de Embarque</th>

                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Fecha Partida</th>
                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Aduana Partida</th>
                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Fecha Destino</th>

                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Aduana Destino</th>
                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Estado</th>



                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Consignatario</th>
                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Proveedor</th>

                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Descripci&oacute;n de la mercanc&iacute;a</th>

                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Informaci&oacute;n Adicional Manifiesto</th>

                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Peso</th>
                      <th style="text-align: center;color:rgb(240,248,255);background-color:rgb(0,78,155);font-size:10px">Cantidad de bultos</th>
                        </tr>'
                    || datos_detalle
                    || '</tbody></table>'
                    || '<br><br>'
                    || variables
                    || '<br><br>'
                    || '<br><br>Atentamente,'
                    || '<br><br>Aduana Nacional de Bolivia'
                    || '<br>----------------------------------',
                    'anbdm4.aduana.gob.bo',
                    '25');

            END IF;

            IF prm_etapa = 'puerto'
            THEN
                html_email (
                    i.usucorreo,
                    'transitos_riesgo@aduana.gob.bo',
                    'Control de variables de riesgos en el sistema Tr?nsitos Web',
                    '.',
                       'Se&ntilde;or(a) : <br>'
                    || '<br>'
                    || 'El manifiesto&nbsp;<B>: </B>'
                    || prm_car_reg_year
                    || '/'
                    || prm_key_cuo
                    || '/'
                    || prm_car_reg_nber
                    || '<br><br>Realiz&oacute; el registro de la operaci&oacute;n de Salida de Puerto en fecha:'
                    || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi')
                    || '<br>'
                    || '<br><br>'
                    || '<table width="90%" cellspacing="0" cellpadding="3" border="0" align="center" style="font-size:12px"><tbody>'
                    || datos_cabecera
                    || '</tbody></table>'
                    || '<table width="90%" cellspacing="0" cellpadding="3" border="0" align="center" style="font-size:12px">
                            <tbody>
                            <tr><td>&nbsp</td></tr>
                            <tr>
                                <th style="text-align: center;"><label style="font-size: 12px;">Detalle de Documentos de Embarque</label></th>
                            </tr>
                        </tbody></table>

                        <table width="90%" cellspacing="0" cellpadding="3" border="1" align="center">
                          <tbody><tr class="t14">
                          <th style="text-align: center;">Manifiesto</th>
                          <th style="text-align: center;">Documento de Embarque</th>

                          <th style="text-align: center;">Fecha Partida</th>
                          <th style="text-align: center;">Aduana Partida</th>
                          <th style="text-align: center;">Fecha Destino</th>

                          <th style="text-align: center;">Aduana Destino</th>
                          <th style="text-align: center;">Estado</th>



                          <th style="text-align: center;">Consignatario</th>
                          <th style="text-align: center;">Proveedor</th>

                          <th style="text-align: center;">Descripci?n de la mercanc?a</th>

                          <th style="text-align: center;">Informaci?n Adicional Manifiesto</th>

                          <th style="text-align: center;">Peso</th>
                          <th style="text-align: center;">Cantidad de bultos</th>
                        </tr>'
                    || datos_detalle
                    || '</tbody></table>'
                    || '<br><br>'
                    || variables
                    || '<br><br>'
                    || '<br><br>Atentamente,'
                    || '<br><br>Aduana Nacional de Bolivia'
                    || '<br>----------------------------------',
                    'anbdm4.aduana.gob.bo',
                    '25');

            END IF;
        END LOOP;

    END send_email_manifiesto_riesgo;



    FUNCTION graba_var_manifiesto_riesgo (
        prm_variable       IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor          IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE)
        RETURN VARCHAR2
    IS
        existe   DECIMAL (3, 0) := 0;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_variable_manifiesto_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = prm_valor
                 AND a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tvmr_num = 0;

        IF (existe > 0)
        THEN
            RETURN    'VARIABLE YA REGISTRADA '
                   || prm_variable
                   || ':'
                   || prm_valor
                   || ' '
                   || prm_key_cuo
                   || '/'
                   || prm_car_reg_year
                   || '/'
                   || prm_car_reg_nber;
        ELSE
            INSERT INTO tra_variable_manifiesto_riesgo (tvr_variable,
                                                        tvr_valor,
                                                        key_cuo,
                                                        car_reg_year,
                                                        car_reg_nber,
                                                        tvmr_lstope,
                                                        tvmr_num,
                                                        tvmr_fec)
              VALUES   (prm_variable,
                        prm_valor,
                        prm_key_cuo,
                        prm_car_reg_year,
                        prm_car_reg_nber,
                        'U',
                        0,
                        SYSDATE);


            RETURN 'CORRECTO';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END graba_var_manifiesto_riesgo;


    PROCEDURE evalua_riesgo (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE)
    IS
        existe      DECIMAL (3, 0) := 0;
        valor       VARCHAR2 (100) := '';
        contador    DECIMAL (3, 0) := 0;

        error_variable exception;
        error_manifiesto exception;
        error_registrado exception;
        respuesta   VARCHAR2 (300);
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tmr_num = 0;

        IF (existe > 0)
        THEN
            RAISE error_registrado;
        ELSE
            --nit
            SELECT   COUNT (1)
              INTO   existe
              FROM   ops$asy.car_gen a, transitos.tra_variable_riesgo b
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND a.car_car_cod = b.tvr_valor
                     AND b.tvr_variable = 'NIT'
                     AND b.tvr_estado = 'HABILITADO'
                     AND b.tvr_lstope = 'U'
                     AND b.tvr_num = 0;

            IF (existe > 0)
            THEN
                SELECT   DISTINCT b.tvr_valor
                  INTO   valor
                  FROM   ops$asy.car_gen a, transitos.tra_variable_riesgo b
                 WHERE       a.key_cuo = prm_key_cuo
                         AND a.car_reg_year = prm_car_reg_year
                         AND a.car_reg_nber = prm_car_reg_nber
                         AND a.car_car_cod = b.tvr_valor
                         AND b.tvr_variable = 'NIT'
                         AND b.tvr_estado = 'HABILITADO'
                         AND b.tvr_lstope = 'U'
                         AND b.tvr_num = 0;

                respuesta :=
                    graba_var_manifiesto_riesgo ('NIT',
                                                 valor,
                                                 prm_key_cuo,
                                                 prm_car_reg_year,
                                                 prm_car_reg_nber);

                IF (respuesta = 'CORRECTO')
                THEN
                    contador := contador + 1;
                ELSE
                    RAISE error_variable;
                END IF;
            END IF;



            --placa
            SELECT   COUNT (1)
              INTO   existe
              FROM   ops$asy.car_gen a, transitos.tra_variable_riesgo b
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND a.car_id_trp = UPPER (b.tvr_valor)
                     AND b.tvr_variable = 'PLACA'
                     AND b.tvr_estado = 'HABILITADO'
                     AND b.tvr_lstope = 'U'
                     AND b.tvr_num = 0;

            IF (existe > 0)
            THEN
                SELECT   DISTINCT b.tvr_valor
                  INTO   valor
                  FROM   ops$asy.car_gen a, transitos.tra_variable_riesgo b
                 WHERE       a.key_cuo = prm_key_cuo
                         AND a.car_reg_year = prm_car_reg_year
                         AND a.car_reg_nber = prm_car_reg_nber
                         AND a.car_id_trp = UPPER (b.tvr_valor)
                         AND b.tvr_variable = 'PLACA'
                         AND b.tvr_estado = 'HABILITADO'
                         AND b.tvr_lstope = 'U'
                         AND b.tvr_num = 0;

                respuesta :=
                    graba_var_manifiesto_riesgo ('PLACA',
                                                 valor,
                                                 prm_key_cuo,
                                                 prm_car_reg_year,
                                                 prm_car_reg_nber);

                IF (respuesta = 'CORRECTO')
                THEN
                    contador := contador + 1;
                ELSE
                    RAISE error_variable;
                END IF;
            END IF;



            --remitente
            SELECT   COUNT (1)
              INTO   existe
              FROM   ops$asy.car_gen a,
                     transitos.tra_variable_riesgo b,
                     ops$asy.car_bol_gen c
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND c.carbol_exp_nam LIKE
                            '%' || UPPER (b.tvr_valor) || '%'
                     AND b.tvr_variable = 'REMITENTE'
                     AND b.tvr_estado = 'HABILITADO'
                     AND b.tvr_lstope = 'U'
                     AND b.tvr_num = 0
                     AND a.key_cuo = c.key_cuo
                     AND a.key_voy_nber = c.key_voy_nber
                     AND a.key_dep_date = c.key_dep_date;

            IF (existe > 0)
            THEN
                SELECT   DISTINCT b.tvr_valor
                  INTO   valor
                  FROM   ops$asy.car_gen a,
                         transitos.tra_variable_riesgo b,
                         ops$asy.car_bol_gen c
                 WHERE       a.key_cuo = prm_key_cuo
                         AND a.car_reg_year = prm_car_reg_year
                         AND a.car_reg_nber = prm_car_reg_nber
                         AND c.carbol_exp_nam LIKE
                                '%' || UPPER (b.tvr_valor) || '%'
                         AND b.tvr_variable = 'REMITENTE'
                         AND b.tvr_estado = 'HABILITADO'
                         AND b.tvr_lstope = 'U'
                         AND b.tvr_num = 0
                         AND a.key_cuo = c.key_cuo
                         AND a.key_voy_nber = c.key_voy_nber
                         AND a.key_dep_date = c.key_dep_date
                         AND ROWNUM = 1;

                respuesta :=
                    graba_var_manifiesto_riesgo ('REMITENTE',
                                                 valor,
                                                 prm_key_cuo,
                                                 prm_car_reg_year,
                                                 prm_car_reg_nber);

                IF (respuesta = 'CORRECTO')
                THEN
                    contador := contador + 1;
                ELSE
                    RAISE error_variable;
                END IF;
            END IF;


            --origen
            SELECT   COUNT (1)
              INTO   existe
              FROM   ops$asy.car_gen a, transitos.tra_variable_riesgo b
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND SUBSTR (a.car_dep_cod, 0, 2) = b.tvr_valor
                     AND b.tvr_variable = 'ORIGEN'
                     AND b.tvr_estado = 'HABILITADO'
                     AND b.tvr_lstope = 'U'
                     AND b.tvr_num = 0;

            IF (existe > 0)
            THEN
                SELECT   DISTINCT b.tvr_valor
                  INTO   valor
                  FROM   ops$asy.car_gen a, transitos.tra_variable_riesgo b
                 WHERE       a.key_cuo = prm_key_cuo
                         AND a.car_reg_year = prm_car_reg_year
                         AND a.car_reg_nber = prm_car_reg_nber
                         AND SUBSTR (a.car_dep_cod, 0, 2) = b.tvr_valor
                         AND b.tvr_variable = 'ORIGEN'
                         AND b.tvr_estado = 'HABILITADO'
                         AND b.tvr_lstope = 'U'
                         AND b.tvr_num = 0;

                respuesta :=
                    graba_var_manifiesto_riesgo ('ORIGEN',
                                                 valor,
                                                 prm_key_cuo,
                                                 prm_car_reg_year,
                                                 prm_car_reg_nber);

                IF (respuesta = 'CORRECTO')
                THEN
                    contador := contador + 1;
                ELSE
                    RAISE error_variable;
                END IF;
            END IF;



            --carta porte
            SELECT   COUNT (1)
              INTO   existe
              FROM   ops$asy.car_gen a,
                     transitos.tra_variable_riesgo b,
                     ops$asy.car_bol_gen c
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND c.key_bol_ref = b.tvr_valor
                     AND b.tvr_variable = 'CARTA_PORTE'
                     AND b.tvr_estado = 'HABILITADO'
                     AND b.tvr_lstope = 'U'
                     AND b.tvr_num = 0
                     AND a.key_cuo = c.key_cuo
                     AND a.key_voy_nber = c.key_voy_nber
                     AND a.key_dep_date = c.key_dep_date;

            IF (existe > 0)
            THEN
                SELECT   DISTINCT b.tvr_valor
                  INTO   valor
                  FROM   ops$asy.car_gen a,
                         transitos.tra_variable_riesgo b,
                         ops$asy.car_bol_gen c
                 WHERE       a.key_cuo = prm_key_cuo
                         AND a.car_reg_year = prm_car_reg_year
                         AND a.car_reg_nber = prm_car_reg_nber
                         AND c.key_bol_ref = b.tvr_valor
                         AND b.tvr_variable = 'CARTA_PORTE'
                         AND b.tvr_estado = 'HABILITADO'
                         AND b.tvr_lstope = 'U'
                         AND b.tvr_num = 0
                         AND a.key_cuo = c.key_cuo
                         AND a.key_voy_nber = c.key_voy_nber
                         AND a.key_dep_date = c.key_dep_date;

                respuesta :=
                    graba_var_manifiesto_riesgo ('CARTA_PORTE',
                                                 valor,
                                                 prm_key_cuo,
                                                 prm_car_reg_year,
                                                 prm_car_reg_nber);

                IF (respuesta = 'CORRECTO')
                THEN
                    contador := contador + 1;
                ELSE
                    RAISE error_variable;
                END IF;
            END IF;

            --consignatario
            SELECT   COUNT (1)
              INTO   existe
              FROM   ops$asy.car_gen a,
                     transitos.tra_variable_riesgo b,
                     ops$asy.car_bol_gen c
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND c.carbol_cons_cod = b.tvr_valor
                     AND b.tvr_variable = 'CONSIGNATARIO'
                     AND b.tvr_estado = 'HABILITADO'
                     AND b.tvr_lstope = 'U'
                     AND b.tvr_num = 0
                     AND a.key_cuo = c.key_cuo
                     AND a.key_voy_nber = c.key_voy_nber
                     AND a.key_dep_date = c.key_dep_date;

            IF (existe > 0)
            THEN
                SELECT   DISTINCT b.tvr_valor
                  INTO   valor
                  FROM   ops$asy.car_gen a,
                         transitos.tra_variable_riesgo b,
                         ops$asy.car_bol_gen c
                 WHERE       a.key_cuo = prm_key_cuo
                         AND a.car_reg_year = prm_car_reg_year
                         AND a.car_reg_nber = prm_car_reg_nber
                         AND c.carbol_cons_cod = b.tvr_valor
                         AND b.tvr_variable = 'CONSIGNATARIO'
                         AND b.tvr_estado = 'HABILITADO'
                         AND b.tvr_lstope = 'U'
                         AND b.tvr_num = 0
                         AND a.key_cuo = c.key_cuo
                         AND a.key_voy_nber = c.key_voy_nber
                         AND a.key_dep_date = c.key_dep_date;

                respuesta :=
                    graba_var_manifiesto_riesgo ('CONSIGNATARIO',
                                                 valor,
                                                 prm_key_cuo,
                                                 prm_car_reg_year,
                                                 prm_car_reg_nber);

                IF (respuesta = 'CORRECTO')
                THEN
                    contador := contador + 1;
                ELSE
                    RAISE error_variable;
                END IF;
            END IF;

            IF (contador > 0)
            THEN
                respuesta :=
                    graba_manifiesto_riesgo (prm_key_cuo,
                                             prm_car_reg_year,
                                             prm_car_reg_nber,
                                             prm_usuario);



                IF (respuesta = 'CORRECTO')
                THEN
                    COMMIT;
                    send_email_manifiesto_riesgo (prm_key_cuo,
                                                  prm_car_reg_year,
                                                  prm_car_reg_nber,
                                                  prm_usuario,
                                                  'inicio');
                ELSE
                    RAISE error_manifiesto;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN error_registrado
        THEN
            valor:='error';

        WHEN error_manifiesto
        THEN
            valor:='error';
        WHEN error_variable
        THEN
            valor:='error';
        WHEN OTHERS
        THEN
            valor:='error';

    END evalua_riesgo;


    FUNCTION lista_variables_riesgo (
        prm_variable IN tra_variable_riesgo.tvr_variable%TYPE)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   a.tvr_variable,
                       DECODE (
                           a.tvr_variable,
                           'ORIGEN',
                           pkg_variable_riesgo.devuelve_pais (a.tvr_valor),
                           'NIT',
                              a.tvr_valor
                           || ':'
                           || pkg_variable_riesgo.devuelve_nit (a.tvr_valor),
                           'CONSIGNATARIO',
                           a.tvr_valor || ':'
                           || pkg_variable_riesgo.devuelve_consignatario (
                                  a.tvr_valor),
                           a.tvr_valor),
                       a.tvr_estado,
                       TO_CHAR (a.tvr_fecha_inicio, 'dd/mm/yyyy hh24:mi'),
                       TO_CHAR (a.tvr_fecha_vencimiento, 'dd/mm/yyyy'),
                       NVL (a.tvr_observacion, ' '),
                       a.tvr_lstope,
                       a.tvr_num,
                       a.tvr_usr,
                       a.tvr_fec,
                       a.tvr_valor,
                       decode(a.tvr_criterio,'OTROS',a.tvr_criterio||':'||a.tvr_criterio_otro,null,'-',a.tvr_criterio)
                FROM   tra_variable_riesgo a
               WHERE       a.tvr_lstope = 'U'
                       AND a.tvr_num = 0
                       AND a.tvr_variable LIKE prm_variable
            ORDER BY   1, 2;

        RETURN ct;
    END;


    FUNCTION lista_var_manifiesto_riesgo (
        prm_variable   IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor      IN tra_variable_riesgo.tvr_valor%TYPE)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   a.tvr_variable,
                     a.tvr_valor,
                     a.key_cuo,
                     a.car_reg_year,
                     a.car_reg_nber,
                     a.tvmr_lstope,
                     a.tvmr_num,
                     a.tvmr_fec
              FROM   tra_variable_manifiesto_riesgo a
             WHERE       a.tvmr_lstope = 'U'
                     AND a.tvmr_num = 0
                     AND a.tvr_variable LIKE prm_variable
                     AND a.tvr_valor LIKE prm_valor;

        RETURN ct;
    END;


    FUNCTION reporte1 (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   cg.key_cuo,
                       cg.car_reg_year,
                       cg.car_reg_nber,
                       a.key_secuencia,
                       cg.car_car_cod || ': ' || cg.car_car_nam,
                       cg.car_id_trp,
                       TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:mi')
                           AS tra_fec_ini,
                       a.tra_cuo_ini || ': ' || b.cuo_nam AS tra_cuo_ini,
                       NVL (TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:mi'),
                            TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:mi'))
                           AS tra_fec_des,
                       DECODE (a.tra_cuo_des,
                               NULL, a.tra_cuo_est || ': ' || c.cuo_nam,
                               a.tra_cuo_des || ': ' || d.cuo_nam)
                           AS tra_cuo_des,
                       DECODE (a.tra_tipo,
                               23, 'Forzoso',
                               24, 'Normal',
                               28, 'Transbordo',
                               31, 'Despacho Anticipado',
                               ' ')
                           AS tra_tipo,
                       DECODE (a.tra_fec_des, NULL, 2, a.tra_loc) AS loc,
                       TRUNC (SYSDATE - a.tra_fec_est) AS dias,
                       a.lst_ope,
                       tiene_acta (a.key_cuo,
                                   a.car_reg_year,
                                   a.car_reg_nber,
                                   a.key_secuencia)
                           acta,
                       devuelve_tecnicos_operaciones (a.key_cuo,
                                                      a.car_reg_year,
                                                      a.car_reg_nber,
                                                      a.key_secuencia),
                       NVL (cbg.carbol_cons_cod, ' '),
                       cbg.carbol_cons_nam,
                          NVL (cg.car_mast_nam, '-')
                       || ' '
                       || NVL (car_mast_inf1, ' ')
                       || ' '
                       || NVL (car_mast_inf2, ' ')
                           conductor,
                          NVL (cbg.carbol_good1, ' ')
                       || NVL (cbg.carbol_good2, ' ')
                       || NVL (cbg.carbol_good3, ' ')
                       || NVL (cbg.carbol_good4, ' ')
                       || NVL (cbg.carbol_good5, ' '),
                       a.tra_pre precintos,
                          NVL (cbg.carbol_infos1, ' ')
                       || ' '
                       || NVL (cbg.carbol_infos2, ' ')
                           numero_factura,
                       cbg.key_bol_ref,
                       carbol_gros_mas peso,
                       carbol_pack_nber cantidad_bultos,
                       upt.pkg_dsc,
                          TO_CHAR (cg.car_reg_date, 'dd/mm/yyyy')
                       || ' '
                       || cg.car_reg_time,
                       cbg.carbol_exp_nam,
                       manr.tmr_fecha_registro,
                       manr.tmr_estado,
                       pkg_variable_riesgo.devuelve_variables_asociadas (
                           cg.key_cuo,
                           cg.car_reg_year,
                           cg.car_reg_nber)
                           variables_asociadas,
                       NVL (UPPER (manr.tmr_resultado), ' ')
                FROM   transitos.tra_pla_rut a,
                       ops$asy.uncuotab b,
                       ops$asy.uncuotab c,
                       ops$asy.uncuotab d,
                       ops$asy.car_gen cg,
                       ops$asy.car_bol_gen cbg,
                       ops$asy.unpkgtab upt,
                       tra_manifiesto_riesgo manr
               WHERE       upt.pkg_cod = cbg.carbol_pack_cod
                       AND a.key_cuo = cg.key_cuo
                       AND a.car_reg_year = cg.car_reg_year
                       AND a.car_reg_nber = cg.car_reg_nber
                       AND cg.key_cuo = cbg.key_cuo
                       AND cg.key_voy_nber = cbg.key_voy_nber
                       AND cg.key_dep_date = cbg.key_dep_date
                       AND a.key_cuo = manr.key_cuo
                       AND a.car_reg_year = manr.car_reg_year
                       AND a.car_reg_nber = manr.car_reg_nber
                       AND manr.tmr_num = 0
                       AND manr.tmr_lstope = 'U'
                       AND TRUNC (manr.tmr_fecha_registro) BETWEEN TO_DATE (
                                                                       prm_fec_desde,
                                                                       'dd/mm/yyyy')
                                                               AND  TO_DATE (
                                                                        prm_fec_hasta,
                                                                        'dd/mm/yyyy')
                       AND cbg.carbol_nat_cod = '24'
                       AND cbg.carbol_typ_cod <> 'LTR'
                       AND a.tra_cuo_ini = b.cuo_cod
                       AND b.lst_ope = 'U'
                       AND NVL (a.tra_cuo_des, a.tra_cuo_est) = c.cuo_cod
                       AND c.lst_ope = 'U'
                       AND a.tra_cuo_des = d.cuo_cod(+)
                       AND d.lst_ope(+) = 'U'
                       AND a.tra_num = 0
                       AND a.lst_ope <> 'D'
                       AND a.key_secuencia <> 0
            ORDER BY   key_cuo,
                       car_reg_year,
                       car_reg_nber,
                       key_bol_ref;

        RETURN ct;
    END;

    FUNCTION devuelve_mic (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   cg.key_cuo,
                       cg.car_reg_year,
                       cg.car_reg_nber,
                       a.key_secuencia,
                       cg.car_car_cod || ': ' || cg.car_car_nam,
                       cg.car_id_trp,
                       TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:mi')
                           AS tra_fec_ini,
                       a.tra_cuo_ini || ': ' || b.cuo_nam AS tra_cuo_ini,
                       NVL (TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:mi'),
                            TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:mi'))
                           AS tra_fec_des,
                       DECODE (a.tra_cuo_des,
                               NULL, a.tra_cuo_est || ': ' || c.cuo_nam,
                               a.tra_cuo_des || ': ' || d.cuo_nam)
                           AS tra_cuo_des,
                       DECODE (a.tra_tipo,
                               23, 'Forzoso',
                               24, 'Normal',
                               28, 'Transbordo',
                               31, 'Despacho Anticipado',
                               ' ')
                           AS tra_tipo,
                       DECODE (a.tra_fec_des, NULL, 2, a.tra_loc) AS loc,
                       TRUNC (SYSDATE - a.tra_fec_est) AS dias,
                       a.lst_ope,
                       tiene_acta (a.key_cuo,
                                   a.car_reg_year,
                                   a.car_reg_nber,
                                   a.key_secuencia)
                           acta,
                       devuelve_tecnicos_operaciones (a.key_cuo,
                                                      a.car_reg_year,
                                                      a.car_reg_nber,
                                                      a.key_secuencia),
                       NVL (cbg.carbol_cons_cod, ' '),
                       cbg.carbol_cons_nam,
                          NVL (cg.car_mast_nam, '-')
                       || ' '
                       || NVL (car_mast_inf1, ' ')
                       || ' '
                       || NVL (car_mast_inf2, ' ')
                           conductor,
                          NVL (cbg.carbol_good1, ' ')
                       || NVL (cbg.carbol_good2, ' ')
                       || NVL (cbg.carbol_good3, ' ')
                       || NVL (cbg.carbol_good4, ' ')
                       || NVL (cbg.carbol_good5, ' '),
                       a.tra_pre precintos,
                          NVL (cbg.carbol_infos1, ' ')
                       || ' '
                       || NVL (cbg.carbol_infos2, ' ')
                           numero_factura,
                       cbg.key_bol_ref,
                       carbol_gros_mas peso,
                       carbol_pack_nber cantidad_bultos,
                       upt.pkg_dsc,
                          TO_CHAR (cg.car_reg_date, 'dd/mm/yyyy')
                       || ' '
                       || cg.car_reg_time,
                       cbg.carbol_exp_nam,
                       manr.tmr_fecha_registro,
                       manr.tmr_estado
                FROM   transitos.tra_pla_rut a,
                       ops$asy.uncuotab b,
                       ops$asy.uncuotab c,
                       ops$asy.uncuotab d,
                       ops$asy.car_gen cg,
                       ops$asy.car_bol_gen cbg,
                       ops$asy.unpkgtab upt,
                       tra_manifiesto_riesgo manr
               WHERE       upt.pkg_cod = cbg.carbol_pack_cod
                       AND a.key_cuo = cg.key_cuo
                       AND a.car_reg_year = cg.car_reg_year
                       AND a.car_reg_nber = cg.car_reg_nber
                       AND cg.key_cuo = cbg.key_cuo
                       AND cg.key_voy_nber = cbg.key_voy_nber
                       AND cg.key_dep_date = cbg.key_dep_date
                       AND a.key_cuo = manr.key_cuo
                       AND a.car_reg_year = manr.car_reg_year
                       AND a.car_reg_nber = manr.car_reg_nber
                       AND manr.tmr_num = 0
                       AND manr.tmr_lstope = 'U'
                       AND cbg.carbol_nat_cod = '24'
                       AND cbg.carbol_typ_cod <> 'LTR'
                       AND a.tra_cuo_ini = b.cuo_cod
                       AND b.lst_ope = 'U'
                       AND NVL (a.tra_cuo_des, a.tra_cuo_est) = c.cuo_cod
                       AND c.lst_ope = 'U'
                       AND a.tra_cuo_des = d.cuo_cod(+)
                       AND d.lst_ope(+) = 'U'
                       AND a.tra_num = 0
                       AND a.lst_ope <> 'D'
                       AND a.key_secuencia <> 0
                       AND a.key_cuo = prm_key_cuo
                       AND a.car_reg_year = prm_car_reg_year
                       AND a.car_reg_nber = prm_car_reg_nber
            ORDER BY   key_cuo,
                       car_reg_year,
                       car_reg_nber,
                       key_bol_ref;

        RETURN ct;
    END;


    FUNCTION reporte2 (prm_fec_desde   IN VARCHAR2,
                       prm_fec_hasta   IN VARCHAR2,
                       prm_tipo        IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   DECODE (a.tvr_variable,
                             'NIT', 'NIT EMPRESA DE TRANSPORTE',
                             'REMITENTE', 'REMITENTE (PROVEEDOR)',
                             a.tvr_variable),
                     a.tvr_valor,
                     a.tvr_usr,
                     TO_CHAR (a.tvr_fecha_inicio, 'dd/mm/yyyy'),
                     TO_CHAR (a.tvr_fecha_vencimiento, 'dd/mm/yyyy'),
                     a.tvr_estado,
                     a.tvr_observacion
              FROM   tra_variable_riesgo a
             WHERE       a.tvr_lstope = 'U'
                     AND a.tvr_num = 0
                     AND a.tvr_estado = 'HABILITADO'
                     AND a.tvr_variable <> 'ORIGEN'
                     AND a.tvr_fecha_inicio BETWEEN TO_DATE (
                                                        prm_fec_desde
                                                        || ' 00:01',
                                                        'dd/mm/yyyy HH24:mi')
                                                AND  TO_DATE (
                                                         prm_fec_hasta
                                                         || ' 23:59',
                                                         'dd/mm/yyyy HH24:mi')
                     AND a.tvr_variable LIKE prm_tipo
            UNION ALL
            SELECT   a.tvr_variable,
                     UPPER (b.cty_dsc) || ':' || a.tvr_valor,
                     a.tvr_usr,
                     TO_CHAR (a.tvr_fecha_inicio, 'dd/mm/yyyy'),
                     TO_CHAR (a.tvr_fecha_vencimiento, 'dd/mm/yyyy'),
                     a.tvr_estado,
                     a.tvr_observacion
              FROM   tra_variable_riesgo a, ops$asy.unctytab b
             WHERE       a.tvr_valor = b.cty_cod
                     AND b.lst_ope = 'U'
                     AND a.tvr_lstope = 'U'
                     AND a.tvr_num = 0
                     AND a.tvr_estado = 'HABILITADO'
                     AND a.tvr_variable = 'ORIGEN'
                     AND a.tvr_fecha_inicio BETWEEN TO_DATE (
                                                        prm_fec_desde
                                                        || ' 00:01',
                                                        'dd/mm/yyyy HH24:mi')
                                                AND  TO_DATE (
                                                         prm_fec_hasta
                                                         || ' 23:59',
                                                         'dd/mm/yyyy HH24:mi')
                     AND a.tvr_variable LIKE prm_tipo
            ORDER BY   1, 2;

        RETURN ct;
    END;



    FUNCTION reporte3 (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   'NIT EMPRESA DE TRANSPORTE',
                     pkg_variable_riesgo.cant_riesgo_f ('NIT',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('NIT',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('NIT',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados,
                     pkg_variable_riesgo.cant_evalua_f ('NIT',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('NIT',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('NIT',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'PLACA',
                     pkg_variable_riesgo.cant_riesgo_f ('PLACA',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('PLACA',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('PLACA',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados,
                     pkg_variable_riesgo.cant_evalua_f ('PLACA',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('PLACA',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('PLACA',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'ORIGEN',
                     pkg_variable_riesgo.cant_riesgo_f ('ORIGEN',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('ORIGEN',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('ORIGEN',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados,
                     pkg_variable_riesgo.cant_evalua_f ('ORIGEN',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('ORIGEN',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('ORIGEN',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'REMITENTE (PROVEEDOR)',
                     pkg_variable_riesgo.cant_riesgo_f ('REMITENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('REMITENTE',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('REMITENTE',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados,
                     pkg_variable_riesgo.cant_evalua_f ('REMITENTE',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('REMITENTE',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('REMITENTE',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'CONSIGNATARIO',
                     pkg_variable_riesgo.cant_riesgo_f ('CONSIGNATARIO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('CONSIGNATARIO',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('CONSIGNATARIO',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados,
                     pkg_variable_riesgo.cant_evalua_f ('CONSIGNATARIO',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('CONSIGNATARIO',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('CONSIGNATARIO',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'CARTA_PORTE',
                     pkg_variable_riesgo.cant_riesgo_f ('CARTA_PORTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('CARTA_PORTE',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('CARTA_PORTE',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados,
                     pkg_variable_riesgo.cant_evalua_f ('CARTA_PORTE',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('CARTA_PORTE',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('CARTA_PORTE',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL;

        RETURN ct;
    END;



    FUNCTION reporte4 (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   'NIT EMPRESA DE TRANSPORTE',
                     pkg_variable_riesgo.cant_riesgo_f ('NIT',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('NIT',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('NIT',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados
              FROM   DUAL
            UNION ALL
            SELECT   'PLACA',
                     pkg_variable_riesgo.cant_riesgo_f ('PLACA',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('PLACA',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('PLACA',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados
              FROM   DUAL
            UNION ALL
            SELECT   'ORIGEN',
                     pkg_variable_riesgo.cant_riesgo_f ('ORIGEN',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('ORIGEN',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('ORIGEN',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados
              FROM   DUAL
            UNION ALL
            SELECT   'REMITENTE (PROVEEDOR)',
                     pkg_variable_riesgo.cant_riesgo_f ('REMITENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('REMITENTE',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('REMITENTE',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados
              FROM   DUAL
            UNION ALL
            SELECT   'CONSIGNATARIO',
                     pkg_variable_riesgo.cant_riesgo_f ('CONSIGNATARIO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('CONSIGNATARIO',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('CONSIGNATARIO',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados
              FROM   DUAL
            UNION ALL
            SELECT   'CARTA_PORTE',
                     pkg_variable_riesgo.cant_riesgo_f ('CARTA_PORTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         riesgo,
                     pkg_variable_riesgo.cant_estado_f ('CARTA_PORTE',
                                                        'HABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         habilitados,
                     pkg_variable_riesgo.cant_estado_f ('CARTA_PORTE',
                                                        'DESHABILITADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         deshabilitados
              FROM   DUAL;

        RETURN ct;
    END;


    FUNCTION reporte5 (prm_fec_desde   IN VARCHAR2,
                       prm_fec_hasta   IN VARCHAR2,
                       prm_tipo        IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   a.tvr_valor,
                       pkg_variable_riesgo.cant_evalua_fvar (a.tvr_variable,
                                                             a.tvr_valor,
                                                             'OBSERVADO',
                                                             prm_fec_desde,
                                                             prm_fec_hasta)
                       + pkg_variable_riesgo.cant_evalua_fvar (
                             a.tvr_variable,
                             a.tvr_valor,
                             'SIN OBSERVACION',
                             prm_fec_desde,
                             prm_fec_hasta)
                       + pkg_variable_riesgo.cant_evalua_fvar (a.tvr_variable,
                                                               a.tvr_valor,
                                                               'PENDIENTE',
                                                               prm_fec_desde,
                                                               prm_fec_hasta),
                       pkg_variable_riesgo.cant_evalua_fvar (a.tvr_variable,
                                                             a.tvr_valor,
                                                             'OBSERVADO',
                                                             prm_fec_desde,
                                                             prm_fec_hasta)
                           observado,
                       pkg_variable_riesgo.cant_evalua_fvar (a.tvr_variable,
                                                             a.tvr_valor,
                                                             'SIN OBSERVACION',
                                                             prm_fec_desde,
                                                             prm_fec_hasta)
                           sinobservado,
                       pkg_variable_riesgo.cant_evalua_fvar (a.tvr_variable,
                                                             a.tvr_valor,
                                                             'PENDIENTE',
                                                             prm_fec_desde,
                                                             prm_fec_hasta)
                           pendiente,
                       c.tvr_estado
                FROM   tra_variable_manifiesto_riesgo a,
                       tra_manifiesto_riesgo b,
                       tra_variable_riesgo c
               WHERE   a.key_cuo = b.key_cuo
                       AND a.car_reg_year = b.car_reg_year
                       AND a.car_reg_nber = b.car_reg_nber
                       AND a.tvmr_lstope = 'U'
                       AND a.tvmr_num = 0
                       AND b.tmr_lstope = 'U'
                       AND b.tmr_num = 0
                       AND c.tvr_variable = a.tvr_variable
                       AND c.tvr_valor = a.tvr_valor
                       AND c.tvr_num = 0
                       AND c.tvr_lstope = 'U'
                       AND c.tvr_fecha_inicio BETWEEN TO_DATE (
                                                          prm_fec_desde
                                                          || ' 00:01',
                                                          'dd/mm/yyyy HH24:mi')
                                                  AND  TO_DATE (
                                                           prm_fec_hasta
                                                           || ' 23:59',
                                                           'dd/mm/yyyy HH24:mi')
                       AND a.tvr_variable LIKE prm_tipo
                       group by a.tvr_variable,a.tvr_valor, c.tvr_estado
            ORDER BY   1, 2;

        RETURN ct;
    END;



    FUNCTION reporte6 (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   'NIT EMPRESA DE TRANSPORTE',
                     pkg_variable_riesgo.cant_evalua_f ('NIT',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('NIT',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('NIT',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'PLACA',
                     pkg_variable_riesgo.cant_evalua_f ('PLACA',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('PLACA',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('PLACA',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'ORIGEN',
                     pkg_variable_riesgo.cant_evalua_f ('ORIGEN',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('ORIGEN',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('ORIGEN',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'REMITENTE (PROVEEDOR)',
                     pkg_variable_riesgo.cant_evalua_f ('REMITENTE',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('REMITENTE',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('REMITENTE',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'CONSIGNATARIO',
                     pkg_variable_riesgo.cant_evalua_f ('CONSIGNATARIO',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('CONSIGNATARIO',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('CONSIGNATARIO',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL
            UNION ALL
            SELECT   'CARTA_PORTE',
                     pkg_variable_riesgo.cant_evalua_f ('CARTA_PORTE',
                                                        'OBSERVADO',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         observado,
                     pkg_variable_riesgo.cant_evalua_f ('CARTA_PORTE',
                                                        'SIN OBSERVACION',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         sinobservado,
                     pkg_variable_riesgo.cant_evalua_f ('CARTA_PORTE',
                                                        'PENDIENTE',
                                                        prm_fec_desde,
                                                        prm_fec_hasta)
                         pendiente
              FROM   DUAL;

        RETURN ct;
    END;



    FUNCTION cant_riesgo (
        prm_variable IN tra_variable_riesgo.tvr_variable%TYPE)
        RETURN NUMBER
    IS
        res   NUMBER := 0;
    BEGIN
        SELECT   COUNT (1)
          INTO   res
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_num = 0
                 AND a.tvr_lstope = 'U';

        RETURN res;
    END;

    FUNCTION cant_estado (
        prm_variable   IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_estado     IN VARCHAR2)
        RETURN NUMBER
    IS
        res   NUMBER := 0;
    BEGIN
        SELECT   COUNT (1)
          INTO   res
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_estado = prm_estado
                 AND a.tvr_num = 0
                 AND a.tvr_lstope = 'U';

        RETURN res;
    END;

    FUNCTION devuelve_pais (
        prm_cod_pais IN tra_variable_riesgo.tvr_valor%TYPE)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (30) := '';
    BEGIN
        SELECT   UPPER (a.cty_dsc)
          INTO   res
          FROM   ops$asy.unctytab a
         WHERE   a.cty_cod = prm_cod_pais AND a.lst_ope = 'U' AND ROWNUM = 1;

        RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN ' ';
    END;



    FUNCTION lista_usuarios_correo
        RETURN cursortype
    IS
        cr   cursortype;
    BEGIN
        OPEN cr FOR
            SELECT   a.usucodusu,
                        NVL (u.usuapepat, ' ')
                     || ' '
                     || NVL (u.usuapemat, ' ')
                     || ' '
                     || NVL (u.usunombre, ' ')
                         nombre,
                     u.usucorreo,
                     NVL (c.trc_estado, 'HABILITADO') estado,
                     NVL (c.trc_usr, '-') usuario_modificacion,
                     DECODE (c.trc_fec,
                             NULL, '-',
                             TO_CHAR (c.trc_fec, 'dd/mm/yyyy hh24:mi'))
                         fecha_modificacion
              FROM   usuario.usu_rol a,
                     usuario.usuario u,
                     tra_variable_riesgo_correo c
             WHERE   a.rol_cod IN
                             ('GNF_RIESGOADMINISTRADOR', 'GNF_RIESGOOPERADOR')
                     AND a.lst_ope = 'U'
                     AND a.ult_ver = 0
                     AND u.lst_ope = 'U'
                     AND u.usu_num = 0
                     AND a.usucodusu = u.usucodusu
                     AND u.usucodusu = c.trc_usuario(+)
                     AND c.trc_lstope(+) = 'U'
                     AND c.trc_num(+) = 0;

        RETURN cr;
    END;



    FUNCTION devuelve_nit (prm_nit IN tra_variable_riesgo.tvr_valor%TYPE)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (30) := '';
    BEGIN
        SELECT   UPPER (a.car_nam)
          INTO   res
          FROM   ops$asy.uncartab a
         WHERE   a.car_cod = prm_nit AND a.lst_ope = 'U' AND ROWNUM = 1;

        RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN ' ';
    END;

    FUNCTION devuelve_consignatario (
        prm_consignatario IN tra_variable_riesgo.tvr_valor%TYPE)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (30) := '';
    BEGIN
        SELECT   UPPER (a.cmp_nam)
          INTO   res
          FROM   ops$asy.uncmptab a
         WHERE       a.cmp_cod = prm_consignatario
                 AND a.lst_ope = 'U'
                 AND ROWNUM = 1;

        RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN ' ';
    END;

    FUNCTION devuelve_variables_asociadas (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (300) := '';
    BEGIN
        SELECT   reverse(SUBSTR (
                             reverse(RTRIM (
                                         XMLAGG(XMLELEMENT (
                                                    e,
                                                       a.tvr_variable
                                                    || ':'
                                                    || a.tvr_valor
                                                    || '; ')).EXTRACT (
                                             '//text()').EXTRACT ('//text()'),
                                         ';')),
                             1))
          INTO   res
          FROM   tra_variable_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tvmr_lstope = 'U'
                 AND a.tvmr_num = 0;



        RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    FUNCTION devuelve_variables_asoc_table (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (300) := '';
    BEGIN
        SELECT   reverse(SUBSTR (
                             reverse(RTRIM (
                                         XMLAGG(XMLELEMENT (
                                                    e,
                                                       '*-'
                                                    || a.tvr_variable
                                                    || '--'
                                                    || a.tvr_valor
                                                    || '-* ')).EXTRACT (
                                             '//text()').EXTRACT ('//text()'),
                                         ';')),
                             1))
          INTO   res
          FROM   tra_variable_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tvmr_lstope = 'U'
                 AND a.tvmr_num = 0;



        RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    FUNCTION cant_evalua (
        prm_variable   IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_estado     IN VARCHAR2)
        RETURN NUMBER
    IS
        res   NUMBER := 0;
    BEGIN
        --ESTADO
        SELECT   COUNT (1)
          INTO   res
          FROM   tra_variable_manifiesto_riesgo a, tra_manifiesto_riesgo b
         WHERE       a.tvr_variable = prm_variable
                 AND a.key_cuo = b.key_cuo
                 AND a.car_reg_year = b.car_reg_year
                 AND a.car_reg_nber = b.car_reg_nber
                 AND a.tvmr_lstope = 'U'
                 AND a.tvmr_num = 0
                 AND b.tmr_lstope = 'U'
                 AND b.tmr_num = 0
                 AND tmr_estado = prm_estado;

        RETURN res;
    END;



    FUNCTION cant_riesgo_f (
        prm_variable    IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_fec_desde   IN VARCHAR2,
        prm_fec_hasta   IN VARCHAR2)
        RETURN NUMBER
    IS
        res   NUMBER := 0;
    BEGIN
        SELECT   COUNT (1)
          INTO   res
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_num = 0
                 AND a.tvr_lstope = 'U'
                 AND a.tvr_fecha_inicio BETWEEN TO_DATE (
                                                    prm_fec_desde || ' 00:01',
                                                    'dd/mm/yyyy HH24:mi')
                                            AND  TO_DATE (
                                                     prm_fec_hasta
                                                     || ' 23:59',
                                                     'dd/mm/yyyy HH24:mi');

        RETURN res;
    END;

    FUNCTION cant_estado_f (
        prm_variable    IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_estado      IN VARCHAR2,
        prm_fec_desde   IN VARCHAR2,
        prm_fec_hasta   IN VARCHAR2)
        RETURN NUMBER
    IS
        res   NUMBER := 0;
    BEGIN
        SELECT   COUNT (1)
          INTO   res
          FROM   tra_variable_riesgo a
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_estado = prm_estado
                 AND a.tvr_num = 0
                 AND a.tvr_lstope = 'U'
                 AND a.tvr_fecha_inicio BETWEEN TO_DATE (
                                                    prm_fec_desde || ' 00:01',
                                                    'dd/mm/yyyy HH24:mi')
                                            AND  TO_DATE (
                                                     prm_fec_hasta
                                                     || ' 23:59',
                                                     'dd/mm/yyyy HH24:mi');

        RETURN res;
    END;



    FUNCTION cant_evalua_f (
        prm_variable    IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_estado      IN VARCHAR2,
        prm_fec_desde   IN VARCHAR2,
        prm_fec_hasta   IN VARCHAR2)
        RETURN NUMBER
    IS
        res   NUMBER := 0;
    BEGIN
        --ESTADO
        SELECT   COUNT (1)
          INTO   res
          FROM   tra_variable_manifiesto_riesgo a,
                 tra_manifiesto_riesgo b,
                 tra_variable_riesgo c
         WHERE       a.tvr_variable = prm_variable
                 AND a.key_cuo = b.key_cuo
                 AND a.car_reg_year = b.car_reg_year
                 AND a.car_reg_nber = b.car_reg_nber
                 AND a.tvmr_lstope = 'U'
                 AND a.tvmr_num = 0
                 AND b.tmr_lstope = 'U'
                 AND b.tmr_num = 0
                 AND b.tmr_estado = prm_estado
                 AND c.tvr_variable = a.tvr_variable
                 AND c.tvr_valor = a.tvr_valor
                 AND c.tvr_num = 0
                 AND c.tvr_lstope = 'U'
                 AND c.tvr_fecha_inicio BETWEEN TO_DATE (
                                                    prm_fec_desde || ' 00:01',
                                                    'dd/mm/yyyy HH24:mi')
                                            AND  TO_DATE (
                                                     prm_fec_hasta
                                                     || ' 23:59',
                                                     'dd/mm/yyyy HH24:mi');

        RETURN res;
    END;


    FUNCTION cant_evalua_fvar (
        prm_variable    IN tra_variable_riesgo.tvr_variable%TYPE,
        prm_valor       IN tra_variable_riesgo.tvr_valor%TYPE,
        prm_estado      IN VARCHAR2,
        prm_fec_desde   IN VARCHAR2,
        prm_fec_hasta   IN VARCHAR2)
        RETURN NUMBER
    IS
        res   NUMBER := 0;
    BEGIN
        --ESTADO
        SELECT   COUNT (1)
          INTO   res
          FROM   tra_variable_manifiesto_riesgo a,
                 tra_manifiesto_riesgo b,
                 tra_variable_riesgo c
         WHERE       a.tvr_variable = prm_variable
                 AND a.tvr_valor = prm_valor
                 AND a.key_cuo = b.key_cuo
                 AND a.car_reg_year = b.car_reg_year
                 AND a.car_reg_nber = b.car_reg_nber
                 AND a.tvmr_lstope = 'U'
                 AND a.tvmr_num = 0
                 AND b.tmr_lstope = 'U'
                 AND b.tmr_num = 0
                 AND b.tmr_estado = prm_estado
                 AND c.tvr_variable = a.tvr_variable
                 AND c.tvr_valor = a.tvr_valor
                 AND c.tvr_num = 0
                 AND c.tvr_lstope = 'U'
                 AND c.tvr_fecha_inicio BETWEEN TO_DATE (
                                                    prm_fec_desde || ' 00:01',
                                                    'dd/mm/yyyy HH24:mi')
                                            AND  TO_DATE (
                                                     prm_fec_hasta
                                                     || ' 23:59',
                                                     'dd/mm/yyyy HH24:mi');

        RETURN res;
    END;

    FUNCTION lista_paises
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   a.cty_cod, a.cty_dsc
                FROM   ops$asy.unctytab a
               WHERE   lst_ope = 'U' AND cty_cod <> '99'
            ORDER BY   2;

        RETURN ct;
    END;

    FUNCTION lista_mic (prm_fec_desde IN VARCHAR2, prm_fec_hasta IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   DISTINCT b.key_cuo,
                                b.car_reg_year,
                                b.car_reg_nber,
                                b.tmr_estado,
                                NVL (UPPER (b.tmr_resultado), ' ')
                FROM   tra_variable_manifiesto_riesgo a,
                       tra_manifiesto_riesgo b,
                       tra_variable_riesgo c
               WHERE       a.key_cuo = b.key_cuo
                       AND a.car_reg_year = b.car_reg_year
                       AND a.car_reg_nber = b.car_reg_nber
                       AND a.tvmr_lstope = 'U'
                       AND a.tvmr_num = 0
                       AND b.tmr_lstope = 'U'
                       AND b.tmr_num = 0
                       AND c.tvr_variable = a.tvr_variable
                       AND c.tvr_valor = a.tvr_valor
                       AND c.tvr_num = 0
                       AND c.tvr_lstope = 'U'
                       AND c.tvr_fecha_inicio BETWEEN TO_DATE (
                                                          prm_fec_desde
                                                          || ' 00:01',
                                                          'dd/mm/yyyy HH24:mi')
                                                  AND  TO_DATE (
                                                           prm_fec_hasta
                                                           || ' 23:59',
                                                           'dd/mm/yyyy HH24:mi')
            ORDER BY   1, 2;

        RETURN ct;
    END;

    FUNCTION lista_riesgo_mic (prm_key_cuo        IN VARCHAR2,
                               prm_car_reg_year   IN VARCHAR2,
                               prm_car_reg_nber   IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   a.tvr_variable, a.tvr_valor
              FROM   tra_variable_manifiesto_riesgo a,
                     tra_manifiesto_riesgo b,
                     tra_variable_riesgo c
             WHERE       a.key_cuo = b.key_cuo
                     AND a.car_reg_year = b.car_reg_year
                     AND a.car_reg_nber = b.car_reg_nber
                     AND a.tvmr_lstope = 'U'
                     AND a.tvmr_num = 0
                     AND b.tmr_lstope = 'U'
                     AND b.tmr_num = 0
                     AND c.tvr_variable = a.tvr_variable
                     AND c.tvr_valor = a.tvr_valor
                     AND c.tvr_num = 0
                     AND c.tvr_lstope = 'U'
                     AND a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber;



        RETURN ct;
    END;



    FUNCTION mic_observado (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE,
        prm_resultado      IN tra_manifiesto_riesgo.tmr_resultado%TYPE)
        RETURN VARCHAR2
    IS
        version     NUMBER;
        fecha_des   DATE;
        existe      NUMBER;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tmr_lstope = 'U'
                 AND a.tmr_num = 0;


        --VALIDACION DE EXISTENCIA DE LA VARIABLE DE RIESGO
        IF (existe = 0)
        THEN
            RETURN 'ERRORNO EXISTE EL MANIFIESTO';
        END IF;

        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tmr_lstope = 'U'
                 AND a.tmr_num = 0
                 AND a.tmr_estado = 'PENDIENTE';

        --VALIDACION DE ESTADO DE LA VARIABLE DE RIESGO
        IF (existe = 0)
        THEN
            RETURN 'ERROREL MANIFIESTO YA FUE EVALUADO ANTERIORMENTE';
        END IF;


        SELECT   MAX (a.tmr_num)
          INTO   version
          FROM   tra_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber;

        UPDATE   tra_manifiesto_riesgo a
           SET   a.tmr_num = version + 1
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tmr_num = 0;


        INSERT INTO tra_manifiesto_riesgo (key_cuo,
                                           car_reg_year,
                                           car_reg_nber,
                                           tmr_fecha_registro,
                                           tmr_estado,
                                           tmr_lstope,
                                           tmr_num,
                                           tmr_usr,
                                           tmr_fec,
                                           tmr_resultado)
            SELECT   a.key_cuo,
                     a.car_reg_year,
                     a.car_reg_nber,
                     a.tmr_fecha_registro,
                     'OBSERVADO',
                     'U',
                     0,
                     prm_usuario,
                     SYSDATE,
                     UPPER (prm_resultado)
              FROM   tra_manifiesto_riesgo a
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND a.tmr_num = version + 1;

        COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            RETURN    SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255)
                   || ' - MIC OBSERVADO '
                   || prm_key_cuo
                   || ' '
                   || prm_car_reg_year
                   || ' '
                   || prm_car_reg_nber
                   || ' - '
                   || prm_usuario;
    END mic_observado;



    FUNCTION mic_sinobservacion (
        prm_key_cuo        IN tra_manifiesto_riesgo.key_cuo%TYPE,
        prm_car_reg_year   IN tra_manifiesto_riesgo.car_reg_year%TYPE,
        prm_car_reg_nber   IN tra_manifiesto_riesgo.car_reg_nber%TYPE,
        prm_usuario        IN tra_manifiesto_riesgo.tmr_usr%TYPE,
        prm_resultado      IN tra_manifiesto_riesgo.tmr_resultado%TYPE)
        RETURN VARCHAR2
    IS
        version     NUMBER;
        fecha_des   DATE;
        existe      NUMBER;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tmr_lstope = 'U'
                 AND a.tmr_num = 0;


        --VALIDACION DE EXISTENCIA DE LA VARIABLE DE RIESGO
        IF (existe = 0)
        THEN
            RETURN 'ERRORNO EXISTE EL MANIFIESTO';
        END IF;

        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tmr_lstope = 'U'
                 AND a.tmr_num = 0
                 AND a.tmr_estado = 'PENDIENTE';

        --VALIDACION DE ESTADO DE LA VARIABLE DE RIESGO
        IF (existe = 0)
        THEN
            RETURN 'ERROREL MANIFIESTO YA FUE EVALUADO ANTERIORMENTE';
        END IF;


        SELECT   MAX (a.tmr_num)
          INTO   version
          FROM   tra_manifiesto_riesgo a
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber;

        UPDATE   tra_manifiesto_riesgo a
           SET   a.tmr_num = version + 1
         WHERE       a.key_cuo = prm_key_cuo
                 AND a.car_reg_year = prm_car_reg_year
                 AND a.car_reg_nber = prm_car_reg_nber
                 AND a.tmr_num = 0;


        INSERT INTO tra_manifiesto_riesgo (key_cuo,
                                           car_reg_year,
                                           car_reg_nber,
                                           tmr_fecha_registro,
                                           tmr_estado,
                                           tmr_lstope,
                                           tmr_num,
                                           tmr_usr,
                                           tmr_fec,
                                           tmr_resultado)
            SELECT   a.key_cuo,
                     a.car_reg_year,
                     a.car_reg_nber,
                     a.tmr_fecha_registro,
                     'SIN OBSERVACION',
                     'U',
                     0,
                     prm_usuario,
                     SYSDATE,
                     UPPER (prm_resultado)
              FROM   tra_manifiesto_riesgo a
             WHERE       a.key_cuo = prm_key_cuo
                     AND a.car_reg_year = prm_car_reg_year
                     AND a.car_reg_nber = prm_car_reg_nber
                     AND a.tmr_num = version + 1;

        COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            RETURN    SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255)
                   || ' - MIC SIN OBSERVACION '
                   || prm_key_cuo
                   || ' '
                   || prm_car_reg_year
                   || ' '
                   || prm_car_reg_nber
                   || ' - '
                   || prm_usuario;
    END mic_sinobservacion;

    PROCEDURE evaluar_variable_riesgo
    IS
        vtot      NUMBER;
        vobs      NUMBER;
        vsob      NUMBER;
        vpen      NUMBER;
        version   NUMBER;
    BEGIN

        FOR i
        IN (SELECT   a.tvr_variable, a.tvr_valor
              FROM   tra_variable_riesgo a
             WHERE       TRUNC (tvr_fecha_vencimiento) <= TRUNC (SYSDATE)
                     AND tvr_estado = 'HABILITADO'
                     AND tvr_lstope = 'U'
                     AND tvr_num = 0)
        LOOP
            SELECT   COUNT (1)
              INTO   vtot
              FROM   tra_variable_manifiesto_riesgo a,
                     tra_manifiesto_riesgo b
             WHERE       a.tvmr_lstope = 'U'
                     AND a.tvmr_num = 0
                     AND a.tvr_variable = i.tvr_variable -- 'ORIGEN'
                     AND a.tvr_valor = i.tvr_valor -- 'CL'
                     AND a.key_cuo = b.key_cuo
                     AND a.car_reg_year = b.car_reg_year
                     AND a.car_reg_nber = b.car_reg_nber
                     AND b.tmr_lstope = 'U'
                     AND b.tmr_num = 0
                     AND TRUNC (a.tvmr_fec) BETWEEN TRUNC (SYSDATE) - 45
                                                AND  TRUNC (SYSDATE);



            SELECT   COUNT (1)
              INTO   vobs
              FROM   tra_variable_manifiesto_riesgo a,
                     tra_manifiesto_riesgo b
             WHERE       a.tvmr_lstope = 'U'
                     AND a.tvmr_num = 0
                     AND a.tvr_variable = i.tvr_variable -- 'ORIGEN'
                     AND a.tvr_valor = i.tvr_valor -- 'CL'
                     AND a.key_cuo = b.key_cuo
                     AND a.car_reg_year = b.car_reg_year
                     AND a.car_reg_nber = b.car_reg_nber
                     AND b.tmr_lstope = 'U'
                     AND b.tmr_num = 0
                     AND TRUNC (a.tvmr_fec) BETWEEN TRUNC (SYSDATE) - 45
                                                AND  TRUNC (SYSDATE)
                     AND b.tmr_estado = 'OBSERVADO';

            SELECT   COUNT (1)
              INTO   vsob
              FROM   tra_variable_manifiesto_riesgo a,
                     tra_manifiesto_riesgo b
             WHERE       a.tvmr_lstope = 'U'
                     AND a.tvmr_num = 0
                     AND a.tvr_variable = i.tvr_variable -- 'ORIGEN'
                     AND a.tvr_valor = i.tvr_valor -- 'CL'
                     AND a.key_cuo = b.key_cuo
                     AND a.car_reg_year = b.car_reg_year
                     AND a.car_reg_nber = b.car_reg_nber
                     AND b.tmr_lstope = 'U'
                     AND b.tmr_num = 0
                     AND TRUNC (a.tvmr_fec) BETWEEN TRUNC (SYSDATE) - 45
                                                AND  TRUNC (SYSDATE)
                     AND b.tmr_estado = 'SIN OBSERVACION';


            SELECT   COUNT (1)
              INTO   vpen
              FROM   tra_variable_manifiesto_riesgo a,
                     tra_manifiesto_riesgo b
             WHERE       a.tvmr_lstope = 'U'
                     AND a.tvmr_num = 0
                     AND a.tvr_variable = i.tvr_variable -- 'ORIGEN'
                     AND a.tvr_valor = i.tvr_valor -- 'CL'
                     AND a.key_cuo = b.key_cuo
                     AND a.car_reg_year = b.car_reg_year
                     AND a.car_reg_nber = b.car_reg_nber
                     AND b.tmr_lstope = 'U'
                     AND b.tmr_num = 0
                     AND TRUNC (a.tvmr_fec) BETWEEN TRUNC (SYSDATE) - 45
                                                AND  TRUNC (SYSDATE)
                     AND b.tmr_estado = 'PENDIENTE';


            IF (vobs / vtot) * 100 >= 20
            THEN
                SELECT   MAX (a.tvr_num)
                  INTO   version
                  FROM   tra_variable_riesgo a
                 WHERE   a.tvr_variable = i.tvr_variable
                         AND a.tvr_valor = i.tvr_valor;

                UPDATE   tra_variable_riesgo a
                   SET   a.tvr_num = version + 1
                 WHERE       a.tvr_variable = i.tvr_variable
                         AND a.tvr_valor = i.tvr_valor
                         AND a.tvr_num = 0;

                INSERT INTO tra_variable_riesgo (tvr_variable,
                                                 tvr_valor,
                                                 tvr_estado,
                                                 tvr_fecha_inicio,
                                                 tvr_fecha_vencimiento,
                                                 tvr_observacion,
                                                 tvr_lstope,
                                                 tvr_num,
                                                 tvr_usr,
                                                 tvr_fec,
                                                 tvr_criterio,
                                                 tvr_criterio_otro)
                    SELECT   a.tvr_variable,
                             a.tvr_valor,
                             'HABILITADO',
                             a.tvr_fecha_inicio,
                             SYSDATE + 45,
                                'AMPLIADO POR EVALUACION '
                             || TO_CHAR (SYSDATE, 'dd/mm/yyyy')
                             || ' RESULTADO DE ACERTIVIDAD: '
                             || TO_CHAR (ROUND ( (vobs / vtot) * 100))
                             || '% - OBSERVADOS: '
                             || vobs
                             || ' SIN OBSERVACION: '
                             || vsob
                             || ' PENDIENTES: '
                             || vpen
                             || ' TOTAL EVALUADOS: '
                             || vtot,
                             'U',
                             0,
                             'TRANSITOS',
                             SYSDATE,
                             tvr_criterio,
                             tvr_criterio_otro
                      FROM   tra_variable_riesgo a
                     WHERE       a.tvr_variable = i.tvr_variable
                             AND a.tvr_valor = i.tvr_valor
                             AND tvr_num = version + 1;
            ELSE
                SELECT   MAX (a.tvr_num)
                  INTO   version
                  FROM   tra_variable_riesgo a
                 WHERE   a.tvr_variable = i.tvr_variable
                         AND a.tvr_valor = i.tvr_valor;

                UPDATE   tra_variable_riesgo a
                   SET   a.tvr_num = version + 1
                 WHERE       a.tvr_variable = i.tvr_variable
                         AND a.tvr_valor = i.tvr_valor
                         AND a.tvr_num = 0;

                INSERT INTO tra_variable_riesgo (tvr_variable,
                                                 tvr_valor,
                                                 tvr_estado,
                                                 tvr_fecha_inicio,
                                                 tvr_fecha_vencimiento,
                                                 tvr_observacion,
                                                 tvr_lstope,
                                                 tvr_num,
                                                 tvr_usr,
                                                 tvr_fec,
                                                 tvr_criterio,
                                                 tvr_criterio_otro)
                    SELECT   a.tvr_variable,
                             a.tvr_valor,
                             'DESHABILITADO',
                             a.tvr_fecha_inicio,
                             a.tvr_fecha_vencimiento,
                                'DESHABILITADO POR EVALUACION '
                             || TO_CHAR (SYSDATE, 'dd/mm/yyyy')
                             || ' RESULTADO DE ACERTIVIDAD: '
                             || TO_CHAR (ROUND ( (vobs / vtot) * 100))
                             || '% - OBSERVADOS: '
                             || vobs
                             || ' SIN OBSERVACION: '
                             || vsob
                             || ' PENDIENTES: '
                             || vpen
                             || ' TOTAL EVALUADOS: '
                             || vtot,
                             'U',
                             0,
                             'TRANSITOS',
                             SYSDATE,
                             tvr_criterio,
                             tvr_criterio_otro
                      FROM   tra_variable_riesgo a
                     WHERE       a.tvr_variable = i.tvr_variable
                             AND a.tvr_valor = i.tvr_valor
                             AND tvr_num = version + 1;
            END IF;
        END LOOP;

        COMMIT;
    END evaluar_variable_riesgo;






END pkg_variable_riesgo;
/

