CREATE OR REPLACE 
PACKAGE pkg_etiqueta
IS
    TYPE cursortype IS REF CURSOR;
   PROCEDURE adicionar_etiqueta (aduana_i           VARCHAR2,
                                 anio_i             VARCHAR2,
                                 numero_i           NUMBER,
                                 usuario_i          VARCHAR2,
                                 tag_i              VARCHAR2,
                                 fecha_io    IN OUT VARCHAR2,
                                 tipo           OUT unetitab.tip_impresora%TYPE);
     FUNCTION INS_GENERICAS ( ADUANA IN VARCHAR2,
                              GESTION IN VARCHAR2,
                              DESDE IN VARCHAR2,
                              HASTA IN VARCHAR2,
                              CANTIDAD IN VARCHAR2,
                              FDESDE  IN VARCHAR2,
                              FHASTA IN VARCHAR2,
                              IMPRESORA IN VARCHAR2,
                              SOLICITUD IN VARCHAR2,
                              USUARIO IN VARCHAR2)
      RETURN VARCHAR2;

     FUNCTION MAXIMO_NUM (GESTION IN VARCHAR2)
        RETURN VARCHAR2;

     FUNCTION LISTA_ADUANAS2 (USUARIO IN VARCHAR2)
        RETURN CURSORTYPE;

     FUNCTION LISTA_ADUANAS3 (USUARIO IN VARCHAR2)
        RETURN CURSORTYPE;

END pkg_etiqueta;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_etiqueta
AS
   PROCEDURE adicionar_etiqueta (aduana_i           VARCHAR2,
                                 anio_i             VARCHAR2,
                                 numero_i           NUMBER,
                                 usuario_i          VARCHAR2,
                                 tag_i              VARCHAR2,
                                 fecha_io    IN OUT VARCHAR2,
                                 tipo           OUT unetitab.tip_impresora%TYPE)
   IS
      secuencia   NUMBER;
      estado      VARCHAR2 (1);
      fecha       DATE;
   BEGIN
      SELECT MAX (tra_version)
        INTO secuencia
        FROM tra_etiqueta b
       WHERE b.key_cuo = aduana_i AND b.car_reg_year = anio_i AND b.car_reg_nber = numero_i;

      IF secuencia IS NULL
      THEN
         secuencia := 0;
      ELSE
         secuencia := secuencia + 1;

         SELECT b.tra_estado
           INTO estado
           FROM tra_etiqueta b
          WHERE b.key_cuo = aduana_i AND b.car_reg_year = anio_i AND b.car_reg_nber = numero_i AND b.tra_version = 0;

         IF estado = '1'
         THEN
            RETURN;
         END IF;

         UPDATE tra_etiqueta a
            SET a.tra_version = secuencia
          WHERE a.key_cuo = aduana_i AND a.car_reg_year = anio_i AND a.car_reg_nber = numero_i AND tra_version = 0;
      END IF;

      INSERT INTO tra_etiqueta (key_cuo,
                                car_reg_year,
                                car_reg_nber,
                                tra_secuencia,
                                tra_usuario,
                                tra_tag)
           VALUES (aduana_i,
                   anio_i,
                   numero_i,
                   secuencia + 1,
                   usuario_i,
                   tag_i)
        RETURNING tra_fecha
             INTO fecha;

      fecha_io := TO_CHAR (fecha, 'dd/MM/yyyy hh24:MI:ss') || '(' || secuencia || ')';

      BEGIN
         SELECT tip_impresora
           INTO tipo
           FROM unetitab
          WHERE key_cuo = aduana_i;
      EXCEPTION
         WHEN OTHERS
         THEN
            tipo := 0;
      END;
   END adicionar_etiqueta;

   /*************************************************************
   * Devuelve el ultimo numero creado de la gestion en curso*
   *************************************************************/
   FUNCTION MAXIMO_NUM (GESTION IN VARCHAR2)
      RETURN VARCHAR2 IS
      MAXI      VARCHAR2(6) :='0';
      HAY       DECIMAL (3, 0);
      CONT      NUMBER :=0;

      BEGIN
            SELECT COUNT(*) INTO CONT
              FROM tra_generica
             WHERE tra_estado ='G'
               AND TRA_GESTION = GESTION;
            IF CONT = 0 THEN
                MAXI:='0';
            ELSE
              SELECT TO_CHAR(MAX(TRA_FIN)) INTO MAXI
                FROM tra_generica
               WHERE TRA_ESTADO = 'G'
                 AND TRA_GESTION = GESTION;
            END IF;
      RETURN MAXI;
   END;

   FUNCTION INS_GENERICAS ( ADUANA IN VARCHAR2,
                            GESTION IN VARCHAR2,
                            DESDE IN VARCHAR2,
                            HASTA IN VARCHAR2,
                            CANTIDAD IN VARCHAR2,
                            FDESDE  IN VARCHAR2,
                            FHASTA IN VARCHAR2,
                            IMPRESORA IN VARCHAR2,
                            SOLICITUD IN VARCHAR2,
                            USUARIO IN VARCHAR2)
    RETURN VARCHAR2 IS
        LUGAR VARCHAR2(100):='';
    BEGIN
        SELECT A.CUO_NAM INTO LUGAR
                FROM OPS$ASY.UNCUOTAB A
               WHERE A.LST_OPE = 'U'
                 AND A.CUO_COD = ADUANA;

        INSERT INTO tra_generica
                    (tra_aduana, tra_lugar, tra_gestion, tra_inicio, tra_fin,
                     tra_cantidad, tra_solicitud, tra_fdesde, tra_fvence,
                     tra_impresora, tra_fecha_generacion, tra_usuario, tra_estado
                  )
           VALUES   (aduana, lugar, gestion,TO_NUMBER(desde), TO_NUMBER(hasta),
                     TO_NUMBER(cantidad), solicitud, TO_DATE(fdesde,'dd/mm/yyyy'), TO_DATE(fhasta,'dd/mm/yyyy'),
                     impresora, SYSDATE, usuario, 'G'
                  );
        RETURN 'Correcto';
   END;

    /*************************************************************
   * Devuelve la lista de las Aduana *
   *************************************************************/
   FUNCTION LISTA_ADUANAS2 (USUARIO IN VARCHAR2)
      RETURN CURSORTYPE IS
      CT       CURSORTYPE;
      HAY      DECIMAL (3, 0);
      ADUANA   VARCHAR2 (30) := USUARIO;

   BEGIN
         OPEN CT FOR
              SELECT CUO_COD, CUO_NAM, NVL( (SELECT TIP_IMPRESORA FROM UNETITAB U  WHERE CUO_COD = U.KEY_CUO),'0')
                FROM OPS$ASY.UNCUOTAB A
               WHERE LST_OPE = 'U'
            ORDER BY 1;
      RETURN CT;
   END;

    /*************************************************************
   * Devuelve la lista de las Aduana Habilitadas*
   *************************************************************/
   FUNCTION LISTA_ADUANAS3 (USUARIO IN VARCHAR2)
      RETURN CURSORTYPE IS
      CT       CURSORTYPE;
      HAY      DECIMAL (3, 0);
      ADUANA   VARCHAR2 (30) := USUARIO;

   BEGIN
         OPEN CT FOR
              SELECT A.CUO_COD, A.CUO_NAM, U.TIP_IMPRESORA
                FROM OPS$ASY.UNCUOTAB A, UNETITAB U
               WHERE A.LST_OPE = 'U'
                 AND A.CUO_COD = U.KEY_CUO
            ORDER BY 1;
      RETURN CT;
   END;
END pkg_etiqueta;
/

