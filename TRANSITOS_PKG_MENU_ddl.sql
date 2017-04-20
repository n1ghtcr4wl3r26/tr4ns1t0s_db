CREATE OR REPLACE 
PACKAGE pkg_menu

IS
   FUNCTION devuelve_url (prm_sistema IN VARCHAR2)
      RETURN VARCHAR2;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_menu

IS
   FUNCTION devuelve_url (prm_sistema IN VARCHAR2)
      RETURN VARCHAR2
   IS
      res   VARCHAR2 (100);
   BEGIN
      SELECT SUBSTR (a.sis_url, 0, LENGTH (a.sis_url) - 9)
        INTO res
        FROM usuario.sistema a
       WHERE a.siscodsis = prm_sistema AND a.lst_ope = 'U' AND a.sis_ope = 0;

      RETURN res;
   END;
END;
/

