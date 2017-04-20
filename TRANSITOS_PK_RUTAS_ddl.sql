CREATE OR REPLACE 
PACKAGE pk_rutas 
IS
   FUNCTION borra (
      p_rou_cod   unroutab.rou_cod%TYPE,
      p_usucre    unroutab.usucre%TYPE
   )
      RETURN VARCHAR2;

/* --------------------------------------*/
   FUNCTION graba (
      p_rou_cod   unroutab.rou_cod%TYPE,
      p_cuo_sal   unroutab.cuo_sal%TYPE,
      p_cuo_arr   unroutab.cuo_arr%TYPE,
      p_rou_ter   unroutab.rou_ter%TYPE,
      p_rou_mod   unroutab.rou_mod%TYPE,
      p_usucre    unroutab.usucre%TYPE,
      p_des       VARCHAR2,
      opcion      NUMBER
   )
      RETURN VARCHAR2;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pk_rutas 
IS
   FUNCTION borra (
      p_rou_cod   unroutab.rou_cod%TYPE,
      p_usucre    unroutab.usucre%TYPE
   )
      RETURN VARCHAR2
   IS
      cant   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO cant
        FROM unroutab
       WHERE rou_cod = p_rou_cod AND lst_ope = 'U';

      IF cant > 0
      THEN
         UPDATE unroutab
            SET numver = cant
          WHERE rou_cod = p_rou_cod AND numver = 0;

         INSERT INTO unroutab
            (SELECT rou_cod, rou_des, cuo_sal, cuo_arr, rou_ter, rou_mod, 'D',
                    0, p_usucre, SYSDATE
               FROM unroutab
              WHERE rou_cod = p_rou_cod AND numver = cant);

         COMMIT;
         RETURN 'Se ha borrado correctamente la ruta';
      ELSE
         RETURN '- No se ha encontrado la ruta';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SUBSTR (SQLCODE || SQLERRM || '. ', 1, 255);
   END;

/* --------------------------------------*/
   FUNCTION graba (
      p_rou_cod   unroutab.rou_cod%TYPE,
      p_cuo_sal   unroutab.cuo_sal%TYPE,
      p_cuo_arr   unroutab.cuo_arr%TYPE,
      p_rou_ter   unroutab.rou_ter%TYPE,
      p_rou_mod   unroutab.rou_mod%TYPE,
      p_usucre    unroutab.usucre%TYPE,
      p_des       VARCHAR2,
      opcion      NUMBER
   )
      RETURN VARCHAR2
   IS
      cant     NUMBER;
      codigo   NUMBER;
   BEGIN
      IF (opcion = 1)
      THEN
         SELECT COUNT (*)
           INTO cant
           FROM unroutab
          WHERE cuo_sal IN (p_cuo_sal, p_cuo_arr)
            AND cuo_arr IN (p_cuo_sal, p_cuo_arr)
            AND rou_mod = p_rou_mod
            AND lst_ope = 'U'
            AND numver = 0;

         IF (cant > 0)
         THEN
            RAISE TOO_MANY_ROWS;
         END IF;

         SELECT NVL (MAX (TO_NUMBER (rou_cod)), 0)
           INTO codigo
           FROM unroutab;

         codigo := codigo + 1;
      ELSE
         SELECT MAX (numver)
           INTO cant
           FROM unroutab
          WHERE rou_cod = p_rou_cod;

         UPDATE unroutab
            SET numver = cant + 1
          WHERE rou_cod = p_rou_cod AND numver = 0;

         codigo := p_rou_cod;
      END IF;

      INSERT INTO unroutab
           VALUES (codigo, UPPER (p_des), p_cuo_sal, p_cuo_arr, p_rou_ter,
                   p_rou_mod, 'U', 0, p_usucre, SYSDATE);

      COMMIT;
      RETURN 'Correcto';
   EXCEPTION
      WHEN TOO_MANY_ROWS
      THEN
         RETURN 'El Codigo que desea a?adir ya esta registrado';
      WHEN OTHERS
      THEN
         RETURN SUBSTR (SQLERRM || '. ', 1, 255);
   END;
END;
/

