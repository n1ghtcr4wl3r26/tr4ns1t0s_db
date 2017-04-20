CREATE OR REPLACE 
PACKAGE pkg_acta
IS
    TYPE cursortype IS REF CURSOR;

    FUNCTION reporte_acta (nit        IN VARCHAR2,
                           medio      IN VARCHAR2,
                           i_aduana   IN VARCHAR2,
                           d_aduana   IN VARCHAR2)
        RETURN cursortype;

    FUNCTION consulta_acta (keycuo IN VARCHAR2)
        RETURN cursortype;

    FUNCTION consulta_empresas (keycuo IN VARCHAR2)
        RETURN cursortype;

    FUNCTION consulta_medios (keycuo IN VARCHAR2)
        RETURN cursortype;

    FUNCTION graba_acta (keycuo      IN VARCHAR2,
                         gestion     IN VARCHAR2,
                         serial      IN NUMBER,
                         secuencia   IN NUMBER,
                         nit         IN VARCHAR2,
                         medio       IN VARCHAR2,
                         acta        IN VARCHAR2,
                         usuario     IN VARCHAR2,
                         etapa       IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION graba_acta_spcai (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN NUMBER,
                               medio     IN VARCHAR2,
                               acta      IN VARCHAR2,
                               usuario   IN VARCHAR2)
        RETURN VARCHAR2;


    FUNCTION graba_acta_nuevooce (keycuo      IN VARCHAR2,
                                  gestion     IN VARCHAR2,
                                  serial      IN NUMBER,
                                  secuencia   IN NUMBER,
                                  nit         IN VARCHAR2,
                                  medio       IN VARCHAR2,
                                  acta        IN VARCHAR2,
                                  usuario     IN VARCHAR2)
        RETURN VARCHAR2;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_acta
/* Formatted on 1-dic.-2016 10:13:22 (QP5 v5.126) */
IS
    bregistra_acta      CONSTANT NUMBER := 5;
    bhabilita_empresa   CONSTANT NUMBER := 6;
    bhabilita_medio     CONSTANT NUMBER := 7;

    FUNCTION reporte_acta (nit        IN VARCHAR2,
                           medio      IN VARCHAR2,
                           i_aduana   IN VARCHAR2,
                           d_aduana   IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT      b.key_cuo
                       || '/'
                       || b.car_reg_year
                       || '-'
                       || TO_CHAR (b.car_reg_nber)
                           AS apertura,
                       b.car_car_cod,
                       b.car_car_nam,
                       b.car_id_trp,
                       a.tra_cuo_ini || ': ' || c1.cuo_nam AS tra_cuo_ini,
                       TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy hh24:mi'),
                       a.tra_cuo_est || ': ' || c2.cuo_nam AS tra_cuo_est,
                       TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy hh24:mi'),
                       a.tra_cuo_des || ': ' || c3.cuo_nam AS tra_cuo_des,
                       NVL (TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy hh24:mi'), ' '),
                       TRUNC (SYSDATE - NVL (a.tra_fec_des, a.tra_fec_est))
                           AS dias,
                       TRUNC( ( (SYSDATE - NVL (a.tra_fec_des, a.tra_fec_est))
                               - TRUNC(SYSDATE
                                       - NVL (a.tra_fec_des, a.tra_fec_est)))
                             * 24)
                           AS hora,
                       ta.tac_acta,
                       DECODE (a.tra_loc, 0, 'No', 'Si') AS loc,
                       ta.tac_estado,
                       NVL (spcai.f_resolucion_tna@dbapp.spcai (ta.tac_acta),
                            ' ')
                FROM   ops$asy.car_gen b,
                       tra_pla_rut a,
                       tra_acta ta,
                       ops$asy.uncuotab c1,
                       ops$asy.uncuotab c2,
                       ops$asy.uncuotab c3
               WHERE       b.key_cuo = a.key_cuo
                       AND b.car_reg_year = a.car_reg_year
                       AND b.car_reg_nber = a.car_reg_nber
                       AND a.key_cuo = ta.key_cuo
                       AND a.car_reg_year = ta.car_reg_year
                       AND a.car_reg_nber = ta.car_reg_nber
                       AND a.key_secuencia = ta.key_secuencia
                       AND a.tra_cuo_ini = c1.cuo_cod
                       AND a.tra_cuo_est = c2.cuo_cod
                       AND a.tra_cuo_des = c3.cuo_cod(+)
                       AND a.lst_ope = 'U'
                       AND a.tra_num = 0
                       AND ta.tac_num = 0
                       AND ta.lst_ope = 'U'
                       AND c1.lst_ope = 'U'
                       AND c2.lst_ope = 'U'
                       AND c3.lst_ope(+) = 'U'
                       AND b.car_car_cod LIKE nit
                       AND b.car_id_trp LIKE medio
                       AND a.tra_cuo_ini LIKE i_aduana
                       AND a.tra_cuo_est LIKE d_aduana
                       AND tac_estado <> 3
            ORDER BY   ta.tac_estado,
                       1,
                       2,
                       3;

        RETURN ct;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN ct;
    END;

    FUNCTION consulta_acta (keycuo IN VARCHAR2)
        RETURN cursortype
    IS
        cantidad   NUMBER;
        ct         cursortype;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       tra_num = 0
                 AND lst_ope = 'U'
                 AND tra_loc = 0
                 AND tra_estado = 0
                 AND tra_fec_est + 3 < SYSDATE
                 AND NVL (tra_cuo_des, tra_cuo_est) = keycuo
                 AND (key_cuo, car_reg_year, car_reg_nber, key_secuencia) NOT IN
                            (SELECT   key_cuo,
                                      car_reg_year,
                                      car_reg_nber,
                                      key_secuencia
                               FROM   tra_acta
                              WHERE   tra_num = 0);

        OPEN ct FOR
              SELECT   b.key_cuo,
                       b.car_reg_year,
                       b.car_reg_nber,
                       a.key_secuencia,
                       b.car_car_cod,
                       b.car_car_nam,
                       b.car_id_trp,
                       a.tra_cuo_ini || ': ' || c1.cuo_nam AS tra_cuo_ini,
                       TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy hh24:mi')
                           AS tra_fec_ini,
                       NVL (a.tra_cuo_des, a.tra_cuo_est) || ': ' || c2.cuo_nam
                           AS tra_cuo_est,
                       TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy hh24:mi')
                           AS tra_fec_est,
                       cantidad,
                       TRUNC (SYSDATE - NVL (a.tra_fec_des, a.tra_fec_est))
                           AS dias,
                       TRUNC( ( (SYSDATE - NVL (a.tra_fec_des, a.tra_fec_est))
                               - TRUNC(SYSDATE
                                       - NVL (a.tra_fec_des, a.tra_fec_est)))
                             * 24)
                           AS hora
                FROM   tra_pla_rut a,
                       ops$asy.car_gen b,
                       ops$asy.uncuotab c1,
                       ops$asy.uncuotab c2
               WHERE       b.key_cuo = a.key_cuo
                       AND b.car_reg_year = a.car_reg_year
                       AND b.car_reg_nber = a.car_reg_nber
                       AND a.tra_cuo_ini = c1.cuo_cod
                       AND NVL (a.tra_cuo_des, a.tra_cuo_est) = c2.cuo_cod
                       AND a.lst_ope = 'U'
                       AND a.tra_num = 0
                       AND a.tra_loc = 0
                       AND a.tra_fec_est + 3 < SYSDATE
                       AND c1.lst_ope = 'U'
                       AND c2.lst_ope = 'U'
                       AND a.tra_estado = 0
                       AND NVL (a.tra_cuo_des, a.tra_cuo_est) = keycuo
                       AND (a.key_cuo,
                            a.car_reg_year,
                            a.car_reg_nber,
                            a.key_secuencia) NOT IN
                                  (SELECT   key_cuo,
                                            car_reg_year,
                                            car_reg_nber,
                                            key_secuencia
                                     FROM   tra_acta
                                    WHERE   tra_num = 0 AND tra_estado <> 3)
            ORDER BY   1,
                       2,
                       3,
                       4;

        RETURN ct;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN ct;
    END;

    FUNCTION consulta_empresas (keycuo IN VARCHAR2)
        RETURN cursortype
    IS
        ct         cursortype;
        cantidad   NUMBER;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_acta
         WHERE   lst_ope = 'U' AND tac_num = 0 AND tac_estado IN (0, 1);

        OPEN ct FOR
              SELECT   b.key_cuo,
                       b.car_reg_year,
                       b.car_reg_nber,
                       a.key_secuencia,
                       b.car_car_cod,
                       b.car_car_nam,
                       b.car_id_trp,
                       a.tac_acta,
                       TO_CHAR (a.usr_fec, 'dd/mm/yyyy hh24:mi') AS fec_acta,
                       cantidad
                FROM   tra_pla_rut c, tra_acta a, ops$asy.car_gen b
               WHERE       c.key_cuo = a.key_cuo
                       AND c.car_reg_year = a.car_reg_year
                       AND c.car_reg_nber = a.car_reg_nber
                       AND c.key_secuencia = a.key_secuencia
                       AND b.key_cuo = a.key_cuo
                       AND b.car_reg_year = a.car_reg_year
                       AND b.car_reg_nber = a.car_reg_nber
                       AND a.lst_ope = 'U'
                       AND a.tac_num = 0
                       AND c.tra_num = 0
                       AND NVL (c.tra_cuo_des, c.tra_cuo_est) = keycuo
                       AND a.tac_estado IN (0, 1)
            ORDER BY   1,
                       2,
                       3,
                       4;

        RETURN ct;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN ct;
    END;

    FUNCTION consulta_medios (keycuo IN VARCHAR2)
        RETURN cursortype
    IS
        ct         cursortype;
        cantidad   NUMBER;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_acta
         WHERE   lst_ope = 'U' AND tac_num = 0 AND tac_estado IN (0, 2);

        OPEN ct FOR
              SELECT   b.key_cuo,
                       b.car_reg_year,
                       b.car_reg_nber,
                       a.key_secuencia,
                       b.car_car_cod,
                       b.car_car_nam,
                       b.car_id_trp,
                       a.tac_acta,
                       TO_CHAR (a.usr_fec, 'dd/mm/yyyy hh24:mi') AS fec_acta,
                       cantidad
                FROM   tra_pla_rut c, tra_acta a, ops$asy.car_gen b
               WHERE       c.key_cuo = a.key_cuo
                       AND c.car_reg_year = a.car_reg_year
                       AND c.car_reg_nber = a.car_reg_nber
                       AND c.key_secuencia = a.key_secuencia
                       AND b.key_cuo = a.key_cuo
                       AND b.car_reg_year = a.car_reg_year
                       AND b.car_reg_nber = a.car_reg_nber
                       AND a.lst_ope = 'U'
                       AND a.tac_num = 0
                       AND c.tra_num = 0
                       AND NVL (c.tra_cuo_des, c.tra_cuo_est) = keycuo
                       AND a.tac_estado IN (0, 2)
            ORDER BY   1,
                       2,
                       3,
                       4;

        RETURN ct;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN ct;
    END;

    FUNCTION graba_acta (keycuo      IN VARCHAR2,
                         gestion     IN VARCHAR2,
                         serial      IN NUMBER,
                         secuencia   IN NUMBER,
                         nit         IN VARCHAR2,
                         medio       IN VARCHAR2,
                         acta        IN VARCHAR2,
                         usuario     IN VARCHAR2,
                         etapa       IN NUMBER)
        RETURN VARCHAR2
    IS
        dacta           VARCHAR2 (30);
        hay             NUMBER (3, 0);
        estado          NUMBER (3, 0);
        msg             VARCHAR2 (255);
        res             NUMBER (3, 0);
        /* EDGAR ARTEAGA NUEVO OCE 18122014*/
        v_fecha_corte   DATE := TO_DATE ('15/12/2015', 'dd/mm/yyyy');
        existe          NUMBER (10) := 0;
    /********/
    BEGIN
        res := 0;
        msg := '';

        SELECT   COUNT (1)
          INTO   hay
          FROM   tra_acta
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND key_secuencia = secuencia
                 AND car_car_cod = nit
                 AND car_id_trp = medio;

        IF (hay > 0)
        THEN
              SELECT   tac_acta, MAX (tac_estado)
                INTO   dacta, estado
                FROM   tra_acta
               WHERE       key_cuo = keycuo
                       AND car_reg_year = gestion
                       AND car_reg_nber = serial
                       AND key_secuencia = secuencia
                       AND car_car_cod = nit
                       AND car_id_trp = medio
            GROUP BY   tac_acta;

            UPDATE   tra_acta
               SET   tac_num = hay
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = secuencia
                     AND car_car_cod = nit
                     AND car_id_trp = medio
                     AND tac_num = 0;
        END IF;

        IF (etapa = bregistra_acta)
        THEN
            INSERT INTO tra_acta
              VALUES   (keycuo,
                        gestion,
                        serial,
                        secuencia,
                        nit,
                        medio,
                        acta,
                        0,
                        NULL,
                        'U',
                        0,
                        usuario,
                        SYSDATE);

            /* EDGAR ARTEAGA NUEVO OCE 18122014
           -- OPERADOR
             operador.p_suspende_unidades_transitos (nit,
                                                     medio,
                                                     acta,
                                                     usuario,
                                                     msg,
                                                     res
                                                    );
                          */
            /* EDGAR ARTEAGA NUEVO OCE 18122014*/
            SELECT   COUNT (1)
              INTO   existe
              FROM   ops$asy.bo_oce_opetipo x
             WHERE       x.ope_numerodoc = nit
                     AND x.tip_tipooperador IN ('TRN', 'TRE', 'NAL')
                     AND x.tip_num = 0
                     AND x.tip_lst_ope = 'U';

            IF existe = 0 AND SYSDATE < v_fecha_corte
            THEN
                -- OPERADOR
                operador.p_suspende_unidades_transitos (nit,
                                                        medio,
                                                        acta,
                                                        usuario,
                                                        msg,
                                                        res);
            ELSE
                res := 5;
                msg := 'ENVIAR BAJA AL NUEVO OCE';
            END IF;

            IF (res <> 0)
            THEN
                RAISE NO_DATA_FOUND;
            END IF;
        -- PADRON
        /*         UPDATE padron.pad_unidad
                    SET uni_obs =
                              'OTR1 Por Acta de Intrencion Nro: '
                           || acta
                           || ' usuario :'
                           || usuario,
                        estado = 'S',
                        usr_elab = usuario,
                        fecha_elab = SYSDATE
                  WHERE tipo_uni = 'VEH' AND placa = medio;*/
        ELSIF (etapa = bhabilita_empresa)
        THEN
            estado := estado + 2;

            INSERT INTO tra_acta
              VALUES   (keycuo,
                        gestion,
                        serial,
                        secuencia,
                        nit,
                        medio,
                        dacta,
                        estado,
                        acta,
                        'U',
                        0,
                        usuario,
                        SYSDATE);
        ELSIF (etapa = bhabilita_medio)
        THEN
            estado := estado + 1;

            INSERT INTO tra_acta
              VALUES   (keycuo,
                        gestion,
                        serial,
                        secuencia,
                        nit,
                        medio,
                        dacta,
                        estado,
                        acta,
                        'U',
                        0,
                        usuario,
                        SYSDATE);
        -- OPERADOR
        /*operador.p_habilita_unidades_transitos (nit,
                                                medio,
                                                acta,
                                                usuario,
                                                msg,
                                                res);

        IF (res <> 0)
        THEN
            RAISE NO_DATA_FOUND;
        END IF; */
        -- PADRON
        /*         UPDATE padron.pad_unidad
                    SET uni_obs = 'PDES obs.: ' || acta || ' usuario :' || usuario,
                        estado = 'G',
                        usr_elab = usuario,
                        fecha_elab = SYSDATE
                  WHERE tipo_uni = 'VEH' AND placa = medio;*/
        END IF;

        COMMIT;
        RETURN 'Correcto';
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            RETURN 'encontrado: ' || msg;
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN (SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255));
    END;

    FUNCTION graba_acta_nuevooce (keycuo      IN VARCHAR2,
                                  gestion     IN VARCHAR2,
                                  serial      IN NUMBER,
                                  secuencia   IN NUMBER,
                                  nit         IN VARCHAR2,
                                  medio       IN VARCHAR2,
                                  acta        IN VARCHAR2,
                                  usuario     IN VARCHAR2)
        RETURN VARCHAR2
    IS
        msg   VARCHAR2 (255);
        res   NUMBER (3, 0);
    BEGIN
        res := 0;
        msg := '';

        INSERT INTO tra_acta
          VALUES   (keycuo,
                    gestion,
                    serial,
                    secuencia,
                    nit,
                    medio,
                    acta,
                    0,
                    NULL,
                    'U',
                    0,
                    usuario,
                    SYSDATE);

        COMMIT;
        RETURN 'Correcto';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN (SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255));
    END;

    FUNCTION graba_acta_spcai (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN NUMBER,
                               medio     IN VARCHAR2,
                               acta      IN VARCHAR2,
                               usuario   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        msg         VARCHAR2 (255);
        res         NUMBER (3, 0);
        secuencia   NUMBER (2, 0);
        nit         VARCHAR2 (50);
        placa       VARCHAR2 (20);
        hay         NUMBER (10);
    BEGIN
        res := '';
        msg := '';

        SELECT   COUNT (1)
          INTO   hay
          FROM   ops$asy.car_gen a
         WHERE       a.car_reg_year = gestion
                 AND a.key_cuo = keycuo
                 AND a.car_reg_nber = serial;

        IF hay = 0
        THEN
            RETURN    'EL MANIFIESTO '
                   || gestion
                   || '/'
                   || keycuo
                   || '/'
                   || serial
                   || ' NO EXISTE.';
        END IF;

        SELECT   a.car_car_cod, a.car_id_trp
          INTO   nit, placa
          FROM   ops$asy.car_gen a
         WHERE       a.car_reg_year = gestion
                 AND a.key_cuo = keycuo
                 AND a.car_reg_nber = serial;

        IF placa <> medio
        THEN
            RETURN    'LA PLACA DEL MEDIO ('
                   || medio
                   || ') NO CORRESPONDE CON LA REGISTRADA EN EL MANIFIESTO ('
                   || placa
                   || ')';
        END IF;

        SELECT   COUNT (1)
          INTO   hay
          FROM   tra_pla_rut a
         WHERE       a.car_reg_year = gestion
                 AND a.key_cuo = keycuo
                 AND a.car_reg_nber = serial
                 AND a.tra_num = 0
                 AND a.lst_ope = 'U'
                 AND a.tra_estado = 0;

        IF hay = 0
        THEN
            RETURN 'NO EXISTE NINGUN TRANSITO PENDIENTE PARA EL MANIFIESTO '
                   || gestion
                   || '/'
                   || keycuo
                   || '/'
                   || serial;
        END IF;

        SELECT   a.key_secuencia
          INTO   secuencia
          FROM   tra_pla_rut a
         WHERE       a.car_reg_year = gestion
                 AND a.key_cuo = keycuo
                 AND a.car_reg_nber = serial
                 AND a.tra_num = 0
                 AND a.lst_ope = 'U'
                 AND a.tra_estado = 0;

        -- GABY
        -- verifica si ya tiene acta
        SELECT   COUNT (1)
          INTO   hay
          FROM   tra_acta a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial
                 AND a.key_secuencia = secuencia
                 AND a.car_car_cod = nit
                 AND a.car_id_trp = medio
                 AND a.tac_num = 0
                 AND a.lst_ope = 'U';

        IF hay = 0
        THEN
            INSERT INTO tra_acta
              VALUES   (keycuo,
                        gestion,
                        serial,
                        secuencia,
                        nit,
                        medio,
                        acta,
                        0,
                        NULL,
                        'U',
                        0,
                        usuario,
                        SYSDATE);
        ELSE
            SELECT   COUNT (1)
              INTO   hay
              FROM   tra_acta a
             WHERE       a.key_cuo = keycuo
                     AND a.car_reg_year = gestion
                     AND a.car_reg_nber = serial
                     AND a.key_secuencia = secuencia
                     AND a.car_car_cod = nit
                     AND a.car_id_trp = medio
                     AND a.tac_num = 0
                     AND a.lst_ope = 'U'
                     AND a.tac_estado <> 3;

            IF hay = 0
            THEN
                SELECT   COUNT (1)
                  INTO   hay
                  FROM   tra_acta a
                 WHERE       a.key_cuo = keycuo
                         AND a.car_reg_year = gestion
                         AND a.car_reg_nber = serial
                         AND a.key_secuencia = secuencia;

                UPDATE   tra_acta
                   SET   tac_num = hay
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND key_secuencia = secuencia
                         AND tac_num = 0;

                INSERT INTO tra_acta
                  VALUES   (keycuo,
                            gestion,
                            serial,
                            secuencia,
                            nit,
                            medio,
                            acta,
                            0,
                            NULL,
                            'U',
                            0,
                            usuario,
                            SYSDATE);
            ELSE
                RETURN 'YA EXISTE REGISTRO DE ACTA DE INTERVENCION Y SE ENCUENTRA PENDIENTE.';
            END IF;
        END IF;

        -- GABY

        --COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            RETURN (SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255));
    END;
END;
/

