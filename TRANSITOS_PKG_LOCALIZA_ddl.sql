CREATE OR REPLACE 
PACKAGE pkg_localiza 
IS
   FUNCTION localiza (
      keycuo    IN   VARCHAR2,
      gestion   IN   VARCHAR2,
      serial    IN   NUMBER,
      docemb    IN   VARCHAR2
   )
      RETURN NUMBER;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_localiza 
IS
   FUNCTION localiza (
      keycuo    IN   VARCHAR2,
      gestion   IN   VARCHAR2,
      serial    IN   NUMBER,
      docemb    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      maximo   NUMBER;
      scuo     VARCHAR2 (5);
      syear    VARCHAR2 (5);
      ireg     NUMBER;
      isec     NUMBER;
   BEGIN
      UPDATE tra_loc
         SET man_fec = SYSDATE
       WHERE man_cuo = keycuo
         AND man_reg_year = gestion
         AND man_reg_nber = serial
         AND man_bol_ref = docemb
         AND man_fec IS NULL;

      IF SQL%ROWCOUNT > 0
      THEN
         COMMIT;

         SELECT COUNT (1)
           INTO maximo
           FROM tra_loc
          WHERE man_cuo = keycuo
            AND man_reg_year = gestion
            AND man_reg_nber = serial
            AND man_fec IS NULL;

         IF (maximo = 0)
         THEN
            SELECT key_cuo, car_reg_year, car_reg_nber, key_secuencia
              INTO scuo, syear, ireg, isec
              FROM tra_loc
             WHERE man_cuo = keycuo
               AND man_reg_year = gestion
               AND man_reg_nber = serial
               AND man_bol_ref = docemb
               AND ROWNUM = 1;

            UPDATE tra_pla_rut
               SET tra_loc = 1
             WHERE key_cuo = scuo
               AND car_reg_year = syear
               AND car_reg_nber = ireg
               AND key_secuencia = isec
               AND tra_num = 0
               AND lst_ope = 'U';

            COMMIT;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN -101;                               -- registro no encontrado
      WHEN TOO_MANY_ROWS
      THEN
         RETURN -102;                          -- muchos registro encontrados
      WHEN OTHERS
      THEN
         RETURN 0;
   END;
END;
/

