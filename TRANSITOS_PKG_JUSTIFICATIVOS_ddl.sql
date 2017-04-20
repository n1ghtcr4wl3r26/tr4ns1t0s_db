CREATE OR REPLACE 
PACKAGE pkg_justificativos
/* Formatted on 5-dic.-2016 17:37:25 (QP5 v5.126) */
IS
    TYPE cursortype IS REF CURSOR;

    FUNCTION verifica_man_jus (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN DECIMAL)
        RETURN VARCHAR2;

    FUNCTION graba_justificativo (prm_keycuo        IN VARCHAR2,
                                  prm_gestion       IN VARCHAR2,
                                  prm_serial        IN VARCHAR2,
                                  prm_keycuopres    IN VARCHAR2,
                                  prm_cite          IN VARCHAR2,
                                  prm_fecha_cite    IN VARCHAR2,
                                  prm_hoja_ruta     IN VARCHAR2,
                                  prm_causa         IN VARCHAR2,
                                  prm_observacion   IN VARCHAR2,
                                  prm_documento     IN VARCHAR2,
                                  prm_usuario       IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION devuelve_fecha_actual
        RETURN VARCHAR2;

    FUNCTION devuelve_aduana_desc (keycuo IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION devuelve_justificativo (keycuo    IN VARCHAR2,
                                     gestion   IN VARCHAR2,
                                     serial    IN DECIMAL,
                                     adudes    IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION devuelve_justificativos (prm_keycuo    IN VARCHAR2,
                                      prm_gestion   IN VARCHAR2,
                                      prm_serial    IN DECIMAL,
                                      prm_adupres    IN VARCHAR2
                                      )
        RETURN cursortype;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_justificativos
/* Formatted on 12-dic.-2016 18:08:07 (QP5 v5.126) */
IS
    FUNCTION graba_justificativo (prm_keycuo        IN VARCHAR2,
                                  prm_gestion       IN VARCHAR2,
                                  prm_serial        IN VARCHAR2,
                                  prm_keycuopres    IN VARCHAR2,
                                  prm_cite          IN VARCHAR2,
                                  prm_fecha_cite    IN VARCHAR2,
                                  prm_hoja_ruta     IN VARCHAR2,
                                  prm_causa         IN VARCHAR2,
                                  prm_observacion   IN VARCHAR2,
                                  prm_documento     IN VARCHAR2,
                                  prm_usuario       IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res        VARCHAR2 (300) := '';
        existe     NUMBER;
        cantidad   DECIMAL (2, 0);
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   ops$asy.car_gen a
         WHERE       a.key_cuo = prm_keycuo
                 AND a.car_reg_year = prm_gestion
                 AND a.car_reg_nber = prm_serial;

        IF existe = 0
        THEN
            RETURN 'EL MANIFIESTO NO EXISTE';
        ELSE
            /*SELECT   COUNT (1)
              INTO   existe
              FROM   tra_justificaciones a
             WHERE       a.key_cuo = prm_keycuo
                     AND a.car_reg_year = prm_gestion
                     AND a.car_reg_nber = prm_serial
                     AND a.jus_cuo_presentacion = prm_keycuopres;

            IF existe = 0
            THEN*/
            SELECT   COUNT (1)
              INTO   existe
              FROM   tra_justificaciones a
             WHERE       a.key_cuo = prm_keycuo
                     AND a.car_reg_year = prm_gestion
                     AND a.car_reg_nber = prm_serial
                     AND a.jus_cite = prm_cite
                     AND a.jus_num = 0
                     AND a.jus_lstope = 'U';

            IF existe = 0
            THEN
                SELECT   COUNT (1)
                  INTO   existe
                  FROM   tra_pla_rut a
                 WHERE       a.key_cuo = prm_keycuo
                         AND a.car_reg_year = prm_gestion
                         AND a.car_reg_nber = prm_serial
                         AND a.tra_num = 0
                         AND a.lst_ope = 'U'
                         AND a.tra_cuo_est = prm_keycuopres;

                IF existe = 0
                THEN
                    RETURN 'LA ADUANA DE PRESENTACION NO CORRESPONDE CON NINGUNA ADUANA DE DESTINO DEL TRANSITO';
                ELSE
                    INSERT INTO tra_justificaciones
                      VALUES   (prm_keycuo,
                                prm_gestion,
                                prm_serial,
                                prm_keycuopres,
                                UPPER (prm_cite),
                                TO_DATE (prm_fecha_cite, 'dd/mm/yyyy'),
                                UPPER (prm_hoja_ruta),
                                UPPER (prm_causa),
                                UPPER (prm_observacion),
                                prm_documento,
                                'U',
                                0,
                                prm_usuario,
                                SYSDATE);

                    RETURN 'OK';
                END IF;
            /*ELSE
                RETURN 'EL JUSTIFICATIVO YA FUE REGISTRADO EN ESTA ADUANA';
            END IF;*/
            ELSE
                RETURN 'EL NUMERO DE CITE DEL JUSTIFICATIVO YA FUE REGISTRADO EN ESTA ADUANA';
            END IF;
        END IF;
    END;



    FUNCTION verifica_man_jus (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN DECIMAL)
        RETURN VARCHAR2
    IS
        res              VARCHAR2 (300) := '';
        existe           NUMBER;
        cantidad         DECIMAL (2, 0);
        v_key_cuo        car_bol_ope.key_cuo%TYPE;
        v_key_voy_nber   car_bol_ope.key_voy_nber%TYPE;
        v_key_dep_date   VARCHAR2 (20);
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   ops$asy.car_gen a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial;

        IF existe = 0
        THEN
            RETURN 'EL MANIFIESTO NO EXISTE';
        ELSE
            SELECT   COUNT (1)
              INTO   existe
              FROM   tra_pla_rut a
             WHERE       a.car_reg_year = gestion
                     AND a.key_cuo = keycuo
                     AND a.car_reg_nber = serial
                     AND a.tra_num = 0
                     AND a.lst_ope = 'U';

            IF existe = 0
            THEN
                RETURN    'NO EXISTE NINGUN TRANSITO PARA EL MANIFIESTO '
                       || gestion
                       || '/'
                       || keycuo
                       || '/'
                       || serial;
            ELSE
                SELECT   COUNT (1)
                  INTO   existe
                  FROM   tra_pla_rut a
                 WHERE       a.car_reg_year = gestion
                         AND a.key_cuo = keycuo
                         AND a.car_reg_nber = serial
                         AND a.tra_num = 0
                         AND a.lst_ope = 'U'
                         AND a.tra_estado = 0;

                IF existe = 0
                THEN
                    RETURN 'NO EXISTE NINGUN TRANSITO PENDIENTE PARA EL MANIFIESTO '
                           || gestion
                           || '/'
                           || keycuo
                           || '/'
                           || serial;
                ELSE
                    RETURN 'OK';
                END IF;
            END IF;
        END IF;
    END;

    FUNCTION devuelve_fecha_actual
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (10);
    BEGIN
        SELECT   TO_CHAR (SYSDATE, 'DD/MM/YYYY') INTO res FROM DUAL;

        RETURN res;
    END;

    FUNCTION devuelve_aduana_desc (keycuo IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (200);
    BEGIN
        SELECT   a.cuo_nam
          INTO   res
          FROM   ops$asy.uncuotab a
         WHERE   a.cuo_cod = keycuo AND a.lst_ope = 'U';

        RETURN res;
    END;


    FUNCTION devuelve_justificativo (keycuo    IN VARCHAR2,
                                     gestion   IN VARCHAR2,
                                     serial    IN DECIMAL,
                                     adudes    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res      VARCHAR2 (10);
        existe   NUMBER;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_justificaciones a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial
                 AND a.jus_cuo_presentacion = adudes
                 AND a.jus_num = 0
                 AND a.jus_lstope = 'U';

        IF existe = 0
        THEN
            RETURN '-';
        ELSE
            RETURN    '<a href="justificativos/justificativos.jsp?gestion='
                   || gestion
                   || '&aduana='
                   || keycuo
                   || '&numero='
                   || serial
                   || '&adupres='
                   || adudes
                   || '" target="_blank">Justificativo</a>';
        END IF;
    END;

    FUNCTION devuelve_justificativos (prm_keycuo    IN VARCHAR2,
                                      prm_gestion   IN VARCHAR2,
                                      prm_serial    IN DECIMAL,
                                      prm_adupres   IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        IF prm_adupres = 'ALL'
        THEN
            OPEN ct FOR
                SELECT   a.key_cuo,
                         a.car_reg_year,
                         a.car_reg_nber,
                         a.jus_cuo_presentacion,
                         a.jus_cuo_presentacion || ':' || u.cuo_nam,
                         a.jus_cite,
                         TO_CHAR (a.jus_fec_cite, 'dd/mm/yyyy'),
                         a.jus_hoja_ruta,
                         a.jus_causa,
                         a.jus_observaciones,
                         SUBSTR (a.jus_documento,
                                 INSTR (a.jus_documento, '/') + 1)
                             documento,
                         REPLACE (
                             SUBSTR (a.jus_documento,
                                     INSTR (a.jus_documento, 'data') + 4),
                             '\',
                             '/')
                             ruta,
                         a.jus_lstope,
                         a.jus_num,
                         a.jus_usuario,
                         a.jus_fecha
                  FROM   tra_justificaciones a, uncuotab u
                 WHERE       u.lst_ope = 'U'
                         AND a.jus_cuo_presentacion = u.cuo_cod
                         AND a.jus_num = 0
                         AND a.jus_lstope = 'U'
                         AND a.key_cuo = prm_keycuo
                         AND a.car_reg_year = prm_gestion
                         AND a.car_reg_nber = prm_serial;
        ELSE
            OPEN ct FOR
                SELECT   a.key_cuo,
                         a.car_reg_year,
                         a.car_reg_nber,
                         a.jus_cuo_presentacion,
                         a.jus_cuo_presentacion || ':' || u.cuo_nam,
                         a.jus_cite,
                         TO_CHAR (a.jus_fec_cite, 'dd/mm/yyyy'),
                         a.jus_hoja_ruta,
                         a.jus_causa,
                         a.jus_observaciones,
                         SUBSTR (a.jus_documento,
                                 INSTR (a.jus_documento, '/') + 1)
                             documento,
                         REPLACE (
                             SUBSTR (a.jus_documento,
                                     INSTR (a.jus_documento, 'data') + 4),
                             '\',
                             '/')
                             ruta,
                         a.jus_lstope,
                         a.jus_num,
                         a.jus_usuario,
                         a.jus_fecha
                  FROM   tra_justificaciones a, uncuotab u
                 WHERE       u.lst_ope = 'U'
                         AND a.jus_cuo_presentacion = u.cuo_cod
                         AND a.jus_num = 0
                         AND a.jus_lstope = 'U'
                         AND a.key_cuo = prm_keycuo
                         AND a.car_reg_year = prm_gestion
                         AND a.car_reg_nber = prm_serial
                         AND a.jus_cuo_presentacion = prm_adupres;
        END IF;

        RETURN ct;
    END;
END;
/

