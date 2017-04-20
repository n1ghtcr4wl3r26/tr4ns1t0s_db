CREATE OR REPLACE 
PACKAGE pkg_imagenes
/* Formatted on 4-nov.-2016 17:36:44 (QP5 v5.126) */
IS
    TYPE cursortype IS REF CURSOR;

    FUNCTION devuelve_codimg_next (keycuo    IN VARCHAR2,
                                   gestion   IN VARCHAR2,
                                   serial    IN DECIMAL)
        RETURN VARCHAR2;

    FUNCTION verifica_ds2295 (p_cuo        IN car_bol_ope.key_cuo%TYPE,
                              p_voy_nber   IN car_bol_ope.key_voy_nber%TYPE,
                              p_dep_date   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION graba_imagen_cod (keycuo                IN VARCHAR2,
                               gestion               IN VARCHAR2,
                               serial                IN DECIMAL,
                               cod_img               IN VARCHAR2,
                               tipo                  IN VARCHAR2,
                               direccion             IN VARCHAR2,
                               direccion_mini        IN VARCHAR2,
                               nombre_archivo        IN VARCHAR2,
                               nombre_archivo_mini   IN VARCHAR2,
                               usuario               IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION graba_imagen (keycuo                IN VARCHAR2,
                           gestion               IN VARCHAR2,
                           serial                IN DECIMAL,
                           tipo                  IN VARCHAR2,
                           direccion             IN VARCHAR2,
                           direccion_mini        IN VARCHAR2,
                           nombre_archivo        IN VARCHAR2,
                           nombre_archivo_mini   IN VARCHAR2,
                           usuario               IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION graba_imagen2 (keycuo                IN     VARCHAR2,
                            gestion               IN     VARCHAR2,
                            serial                IN     DECIMAL,
                            tipo                  IN     VARCHAR2,
                            direccion             IN     VARCHAR2,
                            direccion_mini        IN     VARCHAR2,
                            nombre_archivo        IN     VARCHAR2,
                            nombre_archivo_mini   IN     VARCHAR2,
                            usuario               IN     VARCHAR2,
                            cod_img                  OUT VARCHAR2)
        RETURN VARCHAR2;


    FUNCTION elimina_imagen (keycuo    IN VARCHAR2,
                             gestion   IN VARCHAR2,
                             serial    IN DECIMAL,
                             codigo    IN VARCHAR2,
                             usuario   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION existe_imagen (keycuo    IN VARCHAR2,
                            gestion   IN VARCHAR2,
                            serial    IN DECIMAL)
        RETURN DECIMAL;

    FUNCTION devuelve_imagen (keycuo    IN VARCHAR2,
                              gestion   IN VARCHAR2,
                              serial    IN DECIMAL)
        RETURN cursortype;


    FUNCTION devuelve_datos_imagen (keycuo       IN VARCHAR2,
                                    gestion      IN VARCHAR2,
                                    serial       IN DECIMAL,
                                    cod_imagen   IN DECIMAL)
        RETURN cursortype;

    FUNCTION devuelve_ruta_imagen (keycuo       IN VARCHAR2,
                                   gestion      IN VARCHAR2,
                                   serial       IN VARCHAR2,
                                   cod_imagen   IN VARCHAR2)
        RETURN VARCHAR2;


    FUNCTION devuelve_documentos (keycuo    IN VARCHAR2,
                                  gestion   IN VARCHAR2,
                                  serial    IN DECIMAL)
        RETURN cursortype;

    FUNCTION verifica_man_dig (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN DECIMAL)
        RETURN VARCHAR2;

    FUNCTION verifica_man_dig_ver (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN DECIMAL)
        RETURN VARCHAR2;
END;                                                           -- Package spec
/

CREATE OR REPLACE 
PACKAGE BODY pkg_imagenes
/* Formatted on 4-nov.-2016 17:36:47 (QP5 v5.126) */
IS
    FUNCTION devuelve_codimg_next (keycuo    IN VARCHAR2,
                                   gestion   IN VARCHAR2,
                                   serial    IN DECIMAL)
        RETURN VARCHAR2
    IS
        nextcod   DECIMAL (6, 0) := 0;
        cod_img   VARCHAR2 (50);
    BEGIN
        SELECT   DECODE (MAX (tim_cod), NULL, 1, MAX (tim_cod) + 1)
          INTO   nextcod
          FROM   tra_imagenes
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial;
        cod_img := nextcod;
        RETURN cod_img;
    END;

    FUNCTION verifica_ds2295 (p_cuo        IN car_bol_ope.key_cuo%TYPE,
                              p_voy_nber   IN car_bol_ope.key_voy_nber%TYPE,
                              p_dep_date   IN VARCHAR2)
        RETURN NUMBER
    IS
        ans   NUMBER;
    BEGIN
        SELECT   COUNT (1)
          INTO   ans
          FROM   transitos.tra_inf_manifiesto a
         WHERE       a.key_cuo = p_cuo
                 AND a.key_voy_nber = p_voy_nber
                 AND a.key_dep_date = TO_DATE (p_dep_date, 'dd/mm/yyyy')
                 AND a.man_num = 0
                 AND a.lst_ope = 'U';
        IF ans > 0
        THEN
            SELECT   COUNT (1)
              INTO   ans
              FROM   transitos.tra_inf_manifiesto a
             WHERE       a.key_cuo = p_cuo
                     AND a.man_est_autorizado = 'DS2295'
                     AND a.key_voy_nber = p_voy_nber
                     AND a.key_dep_date = TO_DATE (p_dep_date, 'dd/mm/yyyy')
                     AND a.man_num = 0
                     AND a.lst_ope = 'U';
            IF ans > 0
            THEN
                RETURN 2;                   --lleno el control DE y tiene 2295
            ELSE
                RETURN 1;                                --lleno el control DE
            END IF;
        ELSE
            RETURN 0;                                 --no lleno el control DE
        END IF;
    END;


    FUNCTION graba_imagen_cod (keycuo                IN VARCHAR2,
                               gestion               IN VARCHAR2,
                               serial                IN DECIMAL,
                               cod_img               IN VARCHAR2,
                               tipo                  IN VARCHAR2,
                               direccion             IN VARCHAR2,
                               direccion_mini        IN VARCHAR2,
                               nombre_archivo        IN VARCHAR2,
                               nombre_archivo_mini   IN VARCHAR2,
                               usuario               IN VARCHAR2)
        RETURN VARCHAR2
    IS
        existe   NUMBER := 0;
    BEGIN
        IF tipo = 'PRECINTO' OR tipo = 'TRANSPORTE'
        THEN
            SELECT   COUNT (1)
              INTO   existe
              FROM   tra_imagenes a
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND a.lst_ope = 'U'
                     AND a.tim_num = 0;

            IF existe < 3
            THEN
                INSERT INTO tra_imagenes (key_cuo,
                                          car_reg_year,
                                          car_reg_nber,
                                          tim_cod,
                                          tim_tipo,
                                          tim_direccion,
                                          tim_direccion_mini,
                                          tim_nombre_archivo,
                                          tim_nombre_archivo_mini,
                                          lst_ope,
                                          tim_num,
                                          usr_nam,
                                          usr_fec)
                  VALUES   (keycuo,
                            gestion,
                            serial,
                            cod_img,
                            tipo,
                            direccion,
                            direccion_mini,
                            nombre_archivo,
                            nombre_archivo_mini,
                            'U',
                            0,
                            usuario,
                            SYSDATE);

                COMMIT;
                RETURN 'CORRECTO';
            ELSE
                RETURN 'SOLO SE PUEDEN ADJUNTAR 3 FOTOS DE PRECINTOS COMO MAXIMO';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    FUNCTION graba_imagen (keycuo                IN VARCHAR2,
                           gestion               IN VARCHAR2,
                           serial                IN DECIMAL,
                           tipo                  IN VARCHAR2,
                           direccion             IN VARCHAR2,
                           direccion_mini        IN VARCHAR2,
                           nombre_archivo        IN VARCHAR2,
                           nombre_archivo_mini   IN VARCHAR2,
                           usuario               IN VARCHAR2)
        RETURN VARCHAR2
    IS
        nextcod   DECIMAL (6, 0) := 0;
        cod_img   VARCHAR2 (50);
        existe    NUMBER := 0;
    BEGIN
        IF tipo = 'PRECINTO' OR tipo = 'TRANSPORTE'
        THEN
            SELECT   COUNT (1)
              INTO   existe
              FROM   tra_imagenes a
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND a.lst_ope = 'U'
                     AND a.tim_num = 0;

            IF existe < 3
            THEN
                SELECT   DECODE (MAX (tim_cod), NULL, 1, MAX (tim_cod) + 1)
                  INTO   nextcod
                  FROM   tra_imagenes
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial;

                cod_img := nextcod;

                INSERT INTO tra_imagenes (key_cuo,
                                          car_reg_year,
                                          car_reg_nber,
                                          tim_cod,
                                          tim_tipo,
                                          tim_direccion,
                                          tim_direccion_mini,
                                          tim_nombre_archivo,
                                          tim_nombre_archivo_mini,
                                          lst_ope,
                                          tim_num,
                                          usr_nam,
                                          usr_fec)
                  VALUES   (keycuo,
                            gestion,
                            serial,
                            nextcod,
                            tipo,
                            direccion,
                            direccion_mini,
                            nombre_archivo,
                            nombre_archivo_mini,
                            'U',
                            0,
                            usuario,
                            SYSDATE);

                COMMIT;
                RETURN 'CORRECTO';
            ELSE
                RETURN 'SOLO SE PUEDEN ADJUNTAR 3 FOTOS DE PRECINTOS COMO MAXIMO';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    FUNCTION graba_imagen2 (keycuo                IN     VARCHAR2,
                            gestion               IN     VARCHAR2,
                            serial                IN     DECIMAL,
                            tipo                  IN     VARCHAR2,
                            direccion             IN     VARCHAR2,
                            direccion_mini        IN     VARCHAR2,
                            nombre_archivo        IN     VARCHAR2,
                            nombre_archivo_mini   IN     VARCHAR2,
                            usuario               IN     VARCHAR2,
                            cod_img                  OUT VARCHAR2)
        RETURN VARCHAR2
    IS
        nextcod   DECIMAL (6, 0) := 0;
    BEGIN
        SELECT   DECODE (MAX (tim_cod), NULL, 1, MAX (tim_cod) + 1)
          INTO   nextcod
          FROM   tra_imagenes
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial;

        cod_img := nextcod;

        INSERT INTO tra_imagenes (key_cuo,
                                  car_reg_year,
                                  car_reg_nber,
                                  tim_cod,
                                  tim_tipo,
                                  tim_direccion,
                                  tim_direccion_mini,
                                  tim_nombre_archivo,
                                  tim_nombre_archivo_mini,
                                  lst_ope,
                                  tim_num,
                                  usr_nam,
                                  usr_fec)
          VALUES   (keycuo,
                    gestion,
                    serial,
                    nextcod,
                    tipo,
                    direccion,
                    direccion_mini,
                    nombre_archivo,
                    nombre_archivo_mini,
                    'U',
                    0,
                    usuario,
                    SYSDATE);

        COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    FUNCTION elimina_imagen (keycuo    IN VARCHAR2,
                             gestion   IN VARCHAR2,
                             serial    IN DECIMAL,
                             codigo    IN VARCHAR2,
                             usuario   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        imax   DECIMAL (3, 0) := 0;
    BEGIN
        -- buscamos el codigo siguiente correlativo de imagen por manifiesto
        SELECT   COUNT (1)
          INTO   imax
          FROM   tra_imagenes
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND tim_cod = codigo;

        UPDATE   tra_imagenes
           SET   tim_num = imax
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND tim_cod = codigo
                 AND tim_num = 0;

        INSERT INTO tra_imagenes
            SELECT   key_cuo,
                     car_reg_year,
                     car_reg_nber,
                     tim_cod,
                     tim_tipo,
                     tim_direccion,
                     tim_direccion_mini,
                     tim_nombre_archivo,
                     tim_nombre_archivo_mini,
                     'D',
                     0,
                     usuario,
                     SYSDATE
              FROM   tra_imagenes
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tim_cod = codigo
                     AND tim_num = imax;

        COMMIT;
        RETURN 'CORRECTO';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;


    FUNCTION existe_imagen (keycuo    IN VARCHAR2,
                            gestion   IN VARCHAR2,
                            serial    IN DECIMAL)
        RETURN DECIMAL
    IS
        imax   DECIMAL (3, 0) := 0;
    BEGIN
        -- buscamos el codigo siguiente correlativo de imagen por manifiesto
        SELECT   COUNT (1)
          INTO   imax
          FROM   tra_imagenes
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND lst_ope = 'U'
                 AND tim_num = 0;

        RETURN imax;
    END;


    FUNCTION devuelve_imagen (keycuo    IN VARCHAR2,
                              gestion   IN VARCHAR2,
                              serial    IN DECIMAL)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   key_cuo,
                       car_reg_year,
                       car_reg_nber,
                       tim_cod,
                       tim_tipo,
                       tim_direccion,
                       tim_direccion_mini,
                       tim_nombre_archivo,
                       tim_nombre_archivo_mini,
                       usr_nam,
                       usr_fec
                FROM   tra_imagenes
               WHERE       key_cuo = keycuo
                       AND car_reg_year = gestion
                       AND car_reg_nber = serial
                       AND lst_ope = 'U'
                       AND tim_num = 0
            ORDER BY   tra_imagenes.tim_tipo DESC;

        RETURN ct;
    END;


    FUNCTION devuelve_datos_imagen (keycuo       IN VARCHAR2,
                                    gestion      IN VARCHAR2,
                                    serial       IN DECIMAL,
                                    cod_imagen   IN DECIMAL)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   *
                FROM   tra_imagenes
               WHERE       key_cuo = keycuo
                       AND car_reg_year = gestion
                       AND car_reg_nber = serial
                       AND tim_cod = cod_imagen
                       AND lst_ope = 'U'
                       AND tim_num = 0
            ORDER BY   tra_imagenes.tim_tipo DESC;

        RETURN ct;
    END;


    FUNCTION devuelve_ruta_imagen (keycuo       IN VARCHAR2,
                                   gestion      IN VARCHAR2,
                                   serial       IN VARCHAR2,
                                   cod_imagen   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (150);
    BEGIN
          SELECT   tim_direccion
            INTO   res
            FROM   tra_imagenes
           WHERE       key_cuo = keycuo
                   AND car_reg_year = gestion
                   AND car_reg_nber = serial
                   AND tim_cod = cod_imagen
                   AND lst_ope = 'U'
                   AND tim_num = 0
        ORDER BY   tra_imagenes.tim_tipo DESC;

        RETURN res;
    END;



    FUNCTION devuelve_documentos (keycuo    IN VARCHAR2,
                                  gestion   IN VARCHAR2,
                                  serial    IN DECIMAL)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   DISTINCT
                     a.doc_reg_year,
                     a.doc_key_cuo,
                     a.doc_reg_nber,
                     a.doc_codigo_doc,
                     DECODE (a.doc_codigo_doc, 'XXX', 'Otros', b.atd_dsc)
                         doc_codigo_descrip,
                     NVL (a.doc_emisor, ' ') doc_emisor,
                     NVL (a.doc_referencia, ' ') doc_referencia,
                     NVL (TO_CHAR (a.doc_fecha, 'dd/mm/yyyy'), ' ') doc_fecha,
                     NVL (a.doc_importe, 0) doc_importe,
                     NVL (a.doc_divisa, ' ') doc_divisa,
                     a.doc_otr_divisa,
                     NVL (a.doc_doc_adicional, ' ') doc_doc_adicional,
                     a.doc_codigo_descrip cod2,
                     a.doc_key_bol_ref doc_emb,
                     a.doc_doc_adicional AS ruta
              FROM   mira.ai_doc_man a, ops$asy.unatdtab b
             WHERE       a.doc_num = 0
                     AND a.doc_lst_ope = 'U'
                     AND b.lst_ope(+) = 'U'
                     AND b.atd_cod(+) = a.doc_codigo_doc
                     AND TRUNC (a.doc_fecreg) BETWEEN b.eea_dov(+)
                                                  AND  NVL (b.eea_eov(+),
                                                            SYSDATE)
                     AND a.doc_reg_year = gestion
                     AND a.doc_key_cuo = keycuo
                     AND a.doc_reg_nber = serial;

            /*SELECT   DISTINCT
                     a.doc_reg_year,
                     a.doc_key_cuo,
                     a.doc_reg_nber,
                     a.doc_codigo_doc,
                     b.atd_dsc doc_codigo_descrip,
                     NVL (a.doc_emisor, ' ') doc_emisor,
                     NVL (a.doc_referencia, ' ') doc_referencia,
                     NVL (TO_CHAR (a.doc_fecha, 'dd/mm/yyyy'), ' ') doc_fecha,
                     NVL (a.doc_importe, 0) doc_importe,
                     NVL (a.doc_divisa, ' ') doc_divisa,
                     a.doc_otr_divisa,
                     NVL (a.doc_doc_adicional, ' ') doc_doc_adicional,
                     a.doc_codigo_descrip cod2,
                     a.doc_key_bol_ref doc_emb
              FROM   mira.ai_doc_man a, ops$asy.unatdtab b
             WHERE       a.doc_num = 0
                     AND a.doc_lst_ope = 'U'
                     AND b.atd_cod = a.doc_codigo_doc
                     AND a.doc_reg_year = gestion
                     AND a.doc_key_cuo = keycuo
                     AND a.doc_reg_nber = serial;
*/
        RETURN ct;
    END;

    FUNCTION verifica_man_dig (keycuo    IN VARCHAR2,
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
            SELECT   b.key_cuo,
                     b.key_voy_nber,
                     TO_CHAR (b.key_dep_date, 'dd/mm/yyyy')
              INTO   v_key_cuo, v_key_voy_nber, v_key_dep_date
              FROM   ops$asy.car_gen b
             WHERE       b.key_cuo = keycuo
                     AND b.car_reg_year = gestion
                     AND b.car_reg_nber = serial;

            cantidad :=
                verifica_ds2295 (v_key_cuo,
                                        v_key_voy_nber,
                                        v_key_dep_date);

            IF (cantidad = 0)
            THEN
                RETURN 'EL MANIFIESTO NO TIENE REGISTRO DE CONTROL DE DOCUMENTO DE EMBARQUE';
            ELSE
                IF (cantidad = 2)
                THEN
                    RETURN 'EL MANIFIESTO TIENE MERCANCIA CON D.S. 2295, NO NECESITA DIGITALIZAR PRECINTO';
                ELSE
                    RETURN 'OK';
                END IF;
            END IF;


            RETURN 'OK';
        END IF;
    END;

    FUNCTION verifica_man_dig_ver (keycuo    IN VARCHAR2,
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
            RETURN 'OK';
        END IF;
    END;
END;
/

