CREATE OR REPLACE 
PACKAGE pkg_modalbo
  IS

TYPE cursortype IS REF CURSOR;
FUNCTION manifiesto (s_aduana IN     VARCHAR2,
                     s_anio   IN     VARCHAR2,
                     s_numero IN     VARCHAR2)
RETURN cursortype;

FUNCTION manifiesto_rep (s_aduana IN     VARCHAR2,
                     s_anio   IN     VARCHAR2,
                     s_numero IN     VARCHAR2,
                     destino OUT cursortype)
RETURN cursortype;

FUNCTION c_manifiesto2 (s_aduana IN     VARCHAR2,
                           s_anio   IN     VARCHAR2,
                           s_numero IN     VARCHAR2,
                           s_placa  IN     VARCHAR2,
                           s_fecha  IN     VARCHAR2
                           )
RETURN VARCHAR2;

FUNCTION c_imprime (s_aduana IN     VARCHAR2,
                           s_anio   IN     VARCHAR2,
                           s_numero IN     VARCHAR2)
RETURN VARCHAR2;

PROCEDURE graba_peso (p_aduana       IN     VARCHAR2,
                            p_anio      IN     VARCHAR2,
                            p_registro  IN     VARCHAR2,
                            p_pesoant   IN     NUMBER,
                            p_pesonue   IN     NUMBER,
                            p_usuario   IN     VARCHAR2,
                            p_fechadif  IN     VARCHAR2,
                            p_horadif   IN     VARCHAR2,
                            estado       OUT NUMBER,
                            est_err      OUT VARCHAR2);

FUNCTION lista_man (s_aduana IN     VARCHAR2,
                     s_anio   IN     VARCHAR2,
                     s_numero IN     VARCHAR2)
RETURN cursortype;

FUNCTION verifica_usuario (p_usuario   IN     VARCHAR2,
                               p_clave     IN OUT VARCHAR2,
                               p_aduana    IN     VARCHAR2,
                               p_nit          OUT VARCHAR2,
                               p_perfil       OUT VARCHAR2)
RETURN VARCHAR2;

FUNCTION verifica_inicio (p_perfil    IN OUT     VARCHAR2)
RETURN VARCHAR2;

END; -- Package spec
/

CREATE OR REPLACE 
PACKAGE BODY pkg_modalbo
IS
   FUNCTION manifiesto (s_aduana   IN VARCHAR2,
                        s_anio     IN VARCHAR2,
                        s_numero   IN VARCHAR2)
      RETURN cursortype
   IS
      cd         cursortype;
      cantidad   NUMBER;
      fecha      DATE;
   BEGIN
      OPEN cd FOR
         SELECT DISTINCT
                g.key_cuo "ADUANA",
                g.key_cuo || '/' || g.car_reg_year || '/' || g.car_reg_nber
                   "MANIFIESTO",
                TO_CHAR (g.car_reg_date, 'dd/mm/yyyy') "FECHA REGISTRO",
                g.car_car_cod "DOC TRANSPORTISTA",
                g.car_car_nam "NOM EMPRESA",                               --5
                g.car_id_trp "PLACA",
                g.car_gros_mass "PESO BRUTO",
                g.car_reg_year,
                g.car_reg_nber
           FROM car_gen g
          WHERE     g.key_cuo = s_aduana                               --'072'
                AND g.car_reg_year = s_anio                           --'2011'
                AND g.car_reg_nber = s_numero                        --'19312'
                                             ;

      RETURN cd;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN cd;
   END;

   FUNCTION manifiesto_rep (s_aduana   IN     VARCHAR2,
                            s_anio     IN     VARCHAR2,
                            s_numero   IN     VARCHAR2,
                            destino       OUT cursortype)
      RETURN cursortype
   IS
      cd         cursortype;
      cantidad   NUMBER;
      fecha      DATE;
   BEGIN
      OPEN cd FOR
         SELECT DISTINCT
                g.key_cuo "ADUANA",
                g.key_cuo || '/' || g.car_reg_year || '/' || g.car_reg_nber
                   "MANIFIESTO",
                TO_CHAR (g.car_reg_date, 'dd/mm/yyyy') "FECHA REGISTRO",
                g.car_car_cod "DOC TRANSPORTISTA",
                g.car_car_nam "NOM EMPRESA",                               --5
                g.car_id_trp "PLACA",
                g.car_gros_mass "PESO BRUTO",
                g.car_reg_year,
                g.car_reg_nber,
                TO_CHAR (m.mod_fecreg, 'dd/mm/yyyy') mod_fecreg,          --10
                m.mod_peso,
                g.car_car_cod NIT,
                g.car_reg_time HORA,
                g.car_pac_nber BULTOS_TOTAL
           FROM car_gen g, t_modpeso m
          WHERE     g.key_cuo = m.key_cuo
                AND g.car_reg_year = m.car_reg_year
                AND g.car_reg_nber = m.car_reg_nber
                AND g.key_cuo = s_aduana                               --'072'
                AND g.car_reg_year = s_anio                           --'2011'
                AND g.car_reg_nber = s_numero                        --'19312'
                AND m.mod_lst_ope = 'U'
                AND m.mod_num = 0;

      OPEN destino FOR
         SELECT '| ' || c.cuo_cod || ' - ' || c.cuo_nam nomdes,
                '| ' || b.carbol_gros_mas,
                '| ' || NVL (b.carbol_cons_cod, '-') NIT_CONSIG,
                '| ' || NVL (b.carbol_cons_nam, '-') NAM_CONSIG,
                   '| '
                || NVL (d.car_ctn_ident, '-')
                || ' '
                || NVL (d.car_ctn_typ, '-')
                || ' '
                || NVL (d.car_ctn_full, '-')
                   MARCA_NUMERO,
                   '| '
                || NVL (b.carbol_good1, ' ')
                || '.'
                || NVL (b.carbol_good2, ' ')
                || '.'
                || NVL (b.carbol_good3, ' ')
                || '.'
                || NVL (b.carbol_good4, ' ')
                || '.'
                || NVL (b.carbol_good5, ' ')
                   DESC_MERC,
                '| ' || b.carbol_pack_nber CANT,
                '| ' || b.key_bol_ref DOC_EMB         -- Adicionado 31/08/2012
           FROM car_gen a,
                car_bol_gen b,
                uncuotab c,
                car_bol_ctn d
          WHERE     a.key_cuo = s_aduana
                AND a.car_reg_year = s_anio
                AND a.car_reg_nber = s_numero
                AND a.key_cuo = b.key_cuo
                AND a.key_voy_nber = b.key_voy_nber
                AND a.key_dep_date = b.key_dep_date
                AND b.carbol_frt_prep = c.cuo_cod
                AND c.lst_ope = 'U'
                AND b.key_cuo = d.key_cuo(+)
                AND b.key_voy_nber = d.key_voy_nber(+)
                AND b.key_dep_date = d.key_dep_date(+)
                AND b.key_bol_ref = d.key_bol_ref(+)
                AND b.key_lin_nbr = d.key_lin_nbr(+);

      RETURN cd;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN cd;
   END;

   FUNCTION c_manifiesto2 (s_aduana   IN VARCHAR2,
                           s_anio     IN VARCHAR2,
                           s_numero   IN VARCHAR2,
                           s_placa    IN VARCHAR2,
                           s_fecha    IN VARCHAR2)
      RETURN VARCHAR2
   IS
      reg       VARCHAR2 (15) := '-9999999';
      hay       NUMBER := 0;
      fec_ini   DATE;
   BEGIN
      IF s_fecha = '0'
      THEN
         fec_ini := TRUNC (SYSDATE);
      ELSE
         fec_ini := TO_DATE (s_fecha, 'dd/mm/yyyy');
      END IF;


      IF s_aduana <> '072'
      THEN
         RETURN 'Error, el codigo de aduana no corresponde a Arica.';
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM car_gen
       WHERE     key_cuo = s_aduana
             AND car_reg_year = s_anio
             AND car_reg_nber LIKE s_numero
             AND car_id_trp LIKE s_placa;

      IF hay = 0
      THEN
         RETURN 'Error, el manifiesto no existe.';
      END IF;

      SELECT DISTINCT g.car_reg_nber
        INTO reg
        FROM car_gen g,
             (SELECT bol_gen.key_cuo,
                     bol_gen.key_voy_nber,
                     bol_gen.key_dep_date,
                     bol_gen.key_bol_ref
                FROM car_gen a,
                     car_bol_gen bol_gen,
                     (SELECT key_cuo, key_voy_nber, key_dep_date
                        FROM car_gen
                       WHERE     key_cuo = s_aduana                    --'072'
                             AND car_reg_year = s_anio
                             AND car_reg_nber LIKE s_numero
                             AND car_id_trp LIKE s_placa
                      MINUS
                      SELECT a.key_cuo, a.key_voy_nber, a.key_dep_date
                        FROM car_gen a, car_bol_ope b
                       WHERE     a.key_cuo = s_aduana                  --'072'
                             AND a.car_reg_year = s_anio              --'2011'
                             AND a.car_reg_nber LIKE s_numero       -- '22125'
                             AND a.car_id_trp LIKE s_placa    --536RRD,2470KED
                             AND a.key_cuo = b.key_cuo
                             AND a.key_voy_nber = b.key_voy_nber
                             AND a.key_dep_date = b.key_dep_date
                             AND b.car_ope_typ = 'TRS') b
               WHERE     a.car_reg_nber IS NOT NULL
                     AND a.key_cuo = b.key_cuo
                     AND a.key_voy_nber = b.key_voy_nber
                     AND a.key_dep_date = b.key_dep_date
                     AND a.key_cuo = bol_gen.key_cuo
                     AND a.key_voy_nber = bol_gen.key_voy_nber
                     AND a.key_dep_date = bol_gen.key_dep_date
              MINUS
              SELECT DISTINCT b.key_cuo,
                              b.key_voy_nber,
                              b.key_dep_date,
                              b.key_bol_ref
                FROM car_bol_ope b
               WHERE b.key_cuo = s_aduana                              --'072'
                                         AND b.car_ope_typ = 'MAN') n
       WHERE     g.key_cuo = n.key_cuo
             AND g.key_voy_nber = n.key_voy_nber
             AND g.key_dep_date = n.key_dep_date;



      SELECT COUNT (1)
        INTO hay
        FROM t_modpeso a
       WHERE     a.key_cuo = s_aduana
             AND a.car_reg_year = s_anio
             AND a.car_reg_nber = reg
             AND a.mod_num = 0
             AND a.mod_lst_ope = 'U';

      IF hay > 0
      THEN
         RETURN 'Error, el peso bruto del manifiesto ya fue registrado.';
      END IF;

      --reg := s_numero;

      SELECT COUNT (1)
        INTO hay
        FROM tra_pla_rut
       WHERE     key_cuo = s_aduana
             AND car_reg_year = s_anio
             AND car_reg_nber = reg
             AND key_secuencia > 0
             AND tra_num = 0
             AND lst_ope = 'U'
             AND tra_loc = 0;

      IF hay = 0
      THEN
         RETURN 'Error, el manifiesto no esta registrado en Transitos.';
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM tra_pla_rut
       WHERE     key_cuo = s_aduana
             AND car_reg_year = s_anio
             AND car_reg_nber = reg
             AND key_secuencia = 1
             AND tra_num = 0
             AND lst_ope = 'U'
             AND fec_ini BETWEEN TRUNC (tra_fec_ini) AND TRUNC (SYSDATE);

      IF hay = 0
      THEN
         RETURN 'Error, la fecha debe estar entre la fecha de inicio de transito y hoy.';
      END IF;


      RETURN 'Correcto' || reg;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 'Error, el manifiesto esta borrado o con arribo.';
      WHEN OTHERS
      THEN
         RETURN 'Error: ' || SQLERRM;
   END;


   FUNCTION c_imprime (s_aduana   IN VARCHAR2,
                       s_anio     IN VARCHAR2,
                       s_numero   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      hay   NUMBER := 0;
   BEGIN
      IF s_aduana <> '072'
      THEN
         RETURN 'Error, el codigo de aduana no corresponde a Arica.';
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM car_gen
       WHERE     key_cuo = s_aduana
             AND car_reg_year = s_anio
             AND car_reg_nber = s_numero;

      IF hay = 0
      THEN
         RETURN 'Error, el manifiesto no existe.';
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM t_modpeso a
       WHERE     a.key_cuo = s_aduana
             AND a.car_reg_year = s_anio
             AND a.car_reg_nber = s_numero
             AND a.mod_num = 0
             AND a.mod_lst_ope = 'U';

      IF hay = 0
      THEN
         RETURN 'Error, el peso bruto del manifiesto NO fue registrado.';
      END IF;



      RETURN 'Correcto';
   END;

   PROCEDURE graba_peso (p_aduana     IN     VARCHAR2,
                         p_anio       IN     VARCHAR2,
                         p_registro   IN     VARCHAR2,
                         p_pesoant    IN     NUMBER,
                         p_pesonue    IN     NUMBER,
                         p_usuario    IN     VARCHAR2,
                         p_fechadif   IN     VARCHAR2,
                         p_horadif    IN     VARCHAR2,
                         estado          OUT NUMBER,
                         est_err         OUT VARCHAR2)
   IS
      correl        NUMBER;
      hay           NUMBER;
      s_fechadif    DATE;
      s_horadif     VARCHAR2 (8);
      f_paso_peso   VARCHAR2 (200);
      fecha_peso    VARCHAR2 (100);
   BEGIN
      IF p_fechadif = '0'
      THEN
         s_fechadif := TRUNC (SYSDATE);
         s_horadif := TO_CHAR (SYSDATE, 'HH24:mi:ss');
      ELSE
         s_fechadif := TO_DATE (p_fechadif, 'dd/mm/yyyy');
         s_horadif := p_horadif;
      END IF;

      SELECT COUNT (1)
        INTO hay
        FROM t_modpeso a
       WHERE     a.key_cuo = p_aduana
             AND a.car_reg_year = p_anio
             AND a.car_reg_nber = p_registro
             AND a.mod_num = 0
             AND a.mod_lst_ope = 'U';


      IF hay > 0
      THEN
         estado := 0;
         est_err := 'Error, el peso bruto del manifiesto ya fue registrado.';
      ELSE
         fecha_peso := TO_CHAR (s_fechadif, 'dd/mm/yyyy') || ' ' || s_horadif;
         f_paso_peso :=
            pkg_transito.registro_paso_peso (p_aduana,
                                             p_anio,
                                             p_registro,
                                             fecha_peso,
                                             '422',
                                             p_usuario);

         IF f_paso_peso != 'correcto'
         THEN
            estado := 0;
            est_err := 'Error, No es posible registrar peso.';
         ELSE
/*
            f_paso_peso :=
               PKG_DESPACHO.VALIDA_TRANSITOS (p_anio, p_aduana, p_registro);

            IF (f_paso_peso != 'correcto')
            THEN
               estado := 0;
               est_err := f_paso_peso;
            ELSE*/
               SELECT MAX (mod_num) + 1
                 INTO correl
                 FROM t_modpeso
                WHERE     key_cuo = p_aduana
                      AND car_reg_year = p_anio
                      AND car_reg_nber = p_registro;

               UPDATE t_modpeso
                  SET mod_num = correl
                WHERE     key_cuo = p_aduana
                      AND car_reg_year = p_anio
                      AND car_reg_nber = p_registro
                      AND mod_num = 0;


               INSERT INTO t_modpeso
                    VALUES (p_aduana,
                            p_anio,
                            p_registro,
                            p_pesonue,
                            p_usuario,
                            SYSDATE,
                            'U',
                            0,
                            s_fechadif,
                            s_horadif);

               COMMIT;
               estado := 1;
--            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         est_err := SQLCODE || '-' || SQLERRM;
         ROLLBACK;
         estado := 0;
   END;

   FUNCTION lista_man (s_aduana   IN VARCHAR2,
                       s_anio     IN VARCHAR2,
                       s_numero   IN VARCHAR2)
      RETURN cursortype
   IS
      cd         cursortype;
      cantidad   NUMBER;
      fecha      DATE;
      gestion    VARCHAR2 (4) := TO_CHAR (SYSDATE, 'yyyy');
   BEGIN
      OPEN cd FOR
           SELECT DISTINCT
                  g.key_cuo,
                  g.car_reg_year,
                  g.car_reg_nber,
                  g.key_cuo || '/' || g.car_reg_year || '/' || g.car_reg_nber
                     manifiesto,
                  TO_CHAR (g.car_reg_date, 'dd/mm/yyyy') car_reg_date,
                  g.car_car_cod doc_trans,
                  g.car_car_nam nom_emp,                                   --5
                  g.car_id_trp placa,
                  g.car_gros_mass peso
             FROM car_gen g,
                  tra_pla_rut t,
                  (SELECT bol_gen.key_cuo,
                          bol_gen.key_voy_nber,
                          bol_gen.key_dep_date,
                          bol_gen.key_bol_ref
                     FROM car_gen a,
                          car_bol_gen bol_gen,
                          (SELECT key_cuo, key_voy_nber, key_dep_date
                             FROM car_gen
                            WHERE key_cuo = s_aduana                   --'072'
                                  AND TRUNC (car_reg_date) BETWEEN TRUNC (
                                                                      SYSDATE
                                                                      - 8)
                                                               AND TRUNC (
                                                                      SYSDATE)
                           MINUS
                           (SELECT a.key_cuo, a.key_voy_nber, a.key_dep_date
                              FROM car_gen a, car_bol_ope b
                             WHERE a.key_cuo = s_aduana                --'072'
                                   AND a.car_reg_year >=
                                          TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
                                   AND a.car_reg_nber > 0
                                   AND a.key_cuo = b.key_cuo
                                   AND a.key_voy_nber = b.key_voy_nber
                                   AND a.key_dep_date = b.key_dep_date
                                   AND b.car_ope_typ = 'TRS'
                            UNION
                            SELECT h.key_cuo, h.key_voy_nber, h.key_dep_date
                              FROM car_gen h, t_modpeso m
                             WHERE     h.key_cuo = m.key_cuo
                                   AND h.car_reg_year = m.car_reg_year
                                   AND h.car_reg_nber = m.car_reg_nber
                                   AND m.mod_num = 0
                                   AND m.mod_lst_ope = 'U')) b
                    WHERE     a.car_reg_nber IS NOT NULL
                          AND a.key_cuo = b.key_cuo
                          AND a.key_voy_nber = b.key_voy_nber
                          AND a.key_dep_date = b.key_dep_date
                          AND a.key_cuo = bol_gen.key_cuo
                          AND a.key_voy_nber = bol_gen.key_voy_nber
                          AND a.key_dep_date = bol_gen.key_dep_date
                   MINUS
                   SELECT DISTINCT b.key_cuo,
                                   b.key_voy_nber,
                                   b.key_dep_date,
                                   b.key_bol_ref
                     FROM car_bol_ope b
                    WHERE b.key_cuo = s_aduana                         --'072'
                                              AND b.car_ope_typ = 'MAN') n
            WHERE     g.key_cuo = n.key_cuo
                  AND g.key_voy_nber = n.key_voy_nber
                  AND g.key_dep_date = n.key_dep_date
                  AND g.key_cuo = t.key_cuo
                  AND g.car_reg_year = t.car_reg_year
                  AND g.car_reg_nber = t.car_reg_nber
                  AND t.tra_num = 0
                  AND t.lst_ope = 'U'
                  AND t.key_secuencia > 0
                  AND t.tra_cuo_des IS NULL
                  AND t.tra_fec_des IS NULL
         ORDER BY 2;


      RETURN cd;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN cd;
   END;

   FUNCTION verifica_usuario (p_usuario   IN     VARCHAR2,
                              p_clave     IN OUT VARCHAR2,
                              p_aduana    IN     VARCHAR2,
                              p_nit          OUT VARCHAR2,
                              p_perfil       OUT VARCHAR2)
      RETURN VARCHAR2
   IS
      hay        NUMBER (10) := 0;
      j          NUMBER (2, 0) := 0;
      cant       NUMBER := 0;
      ans        VARCHAR2 (400);
      peso       VARCHAR2 (1);
      si_clave   VARCHAR2 (30);
   BEGIN
      WHILE LENGTH (p_clave) > 0
      LOOP
         j := INSTR (p_clave, ';');

         IF j <= 0
         THEN
            EXIT;
         END IF;

         IF (SUBSTR (p_clave, 1, j - 1) <> '-1')
         THEN
            si_clave := si_clave || CHR (SUBSTR (p_clave, 1, j - 1));
         END IF;

         p_clave := SUBSTR (p_clave, j + 1);
      END LOOP;

      si_clave := SUBSTR (si_clave, 1, LENGTH (si_clave) - 2);

      SELECT COUNT (1)
        INTO cant
        FROM usuario.usuarios_sidunea
       WHERE     usr_nam = p_usuario
             AND (usr_cuo = p_aduana OR usr_cuo = 'ALL')
             AND usr_pwd = si_clave
             AND usr_num = 0
             AND lst_ope = 'U';

      IF cant = 0
      THEN
         RETURN 'Error, Clave incorrecta, o Usuario no pertenece a Administraci'
                || CHR (243)
                || 'n de Aduana';
      END IF;

      /******************* Verifica Registro de peso Habilitado *************/
      SELECT valor
        INTO peso
        FROM t_config
       WHERE llave = 'PESO';

      IF peso = '0'
      THEN
         RETURN 'Error, Registro de PESO esta inhabilitado.';
      END IF;

      /*********************************************************************/

      SELECT COUNT (1)
        INTO hay
        FROM usuario.usuarios_sidunea a
       WHERE     a.usr_nam = p_usuario
             AND (a.usr_cuo = p_aduana OR a.usr_cuo = 'ALL')
             AND a.usr_prf LIKE '%RECIN%'
             AND usr_pwd = si_clave
             AND a.usr_num = 0
             AND a.lst_ope = 'U';

      IF hay > 0
      THEN
         p_perfil := 'RECIN';
      ELSE
         SELECT COUNT (1)
           INTO hay
           FROM usuario.usuarios_sidunea a
          WHERE     a.usr_nam = p_usuario
                AND (a.usr_cuo = p_aduana OR a.usr_cuo = 'ALL')
                AND a.usr_prf LIKE '%RECINDM%'
                AND usr_pwd = si_clave
                AND a.usr_num = 0
                AND a.lst_ope = 'U';

         IF hay > 0
         THEN
            p_perfil := 'RECINDM';
         ELSE
            SELECT COUNT (1)
              INTO hay
              FROM usuario.usuarios_sidunea a
             WHERE     a.usr_nam = p_usuario
                   AND (a.usr_cuo = p_aduana OR a.usr_cuo = 'ALL')
                   AND a.usr_prf LIKE '%ZF%'
                   AND usr_pwd = si_clave
                   AND a.usr_num = 0
                   AND a.lst_ope = 'U';

            IF hay > 0
            THEN
               p_perfil := 'ZF';
            ELSE
               SELECT a.usr_prf
                 INTO p_perfil
                 FROM usuario.usuarios_sidunea a
                WHERE     a.usr_nam = p_usuario
                      AND a.usr_cuo = p_aduana
                      AND usr_pwd = si_clave
                      AND a.usr_num = 0
                      AND a.lst_ope = 'U'
                      AND ROWNUM = 1;
            END IF;
         END IF;
      END IF;

      RETURN 'Ok';
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN 'ERROR';
   END;

   -- No esta en produccion, es para PESO con gusuario

   FUNCTION verifica_inicio (p_perfil IN OUT VARCHAR2)
      RETURN VARCHAR2
   IS
      hay    NUMBER (10) := 0;
      peso   VARCHAR2 (1);
   BEGIN
      /******************* Verifica Registro de peso Habilitado *************/
      SELECT valor
        INTO peso
        FROM t_config
       WHERE llave = 'PESO';

      IF peso = '0'
      THEN
         RETURN 'Error, Registro de PESO esta inhabilitado.';
      END IF;

      /*********************************************************************/

      IF INSTR (p_perfil, 'RECINDM') > 0
      THEN
         p_perfil := 'CONSECIONARIO';
      ELSIF INSTR (p_perfil, 'RECIN') > 0
      THEN
         p_perfil := 'CONSECIONARIO';
      ELSIF INSTR (p_perfil, 'ZF') > 0
      THEN
         p_perfil := 'CONSECIONARIO';
      ELSE
         p_perfil := 'NINGUNO';
      END IF;

      RETURN 'Ok';
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RETURN 'Perfil no habilitado para la aplicacion';
   END;
END;
/

