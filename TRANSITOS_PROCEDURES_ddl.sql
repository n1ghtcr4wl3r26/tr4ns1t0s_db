CREATE OR REPLACE 
PROCEDURE html_email (
   p_to              IN   VARCHAR2,
   p_from            IN   VARCHAR2,
   p_subject         IN   VARCHAR2,
   p_text            IN   VARCHAR2 DEFAULT NULL,
   p_html            IN   CLOB DEFAULT NULL,
   p_smtp_hostname   IN   VARCHAR2,
   p_smtp_portnum    IN   VARCHAR2
)
IS
   l_boundary     VARCHAR2 (255)      DEFAULT 'a1b2c3d4e3f2g1';
   l_connection   UTL_SMTP.connection;
   l_body_html    CLOB                := EMPTY_CLOB;
                                         --This LOB will be the email message
   l_offset       NUMBER;
   l_ammount      NUMBER;
   l_temp         VARCHAR2 (32767)    DEFAULT NULL;
BEGIN
   l_connection := UTL_SMTP.open_connection (p_smtp_hostname, p_smtp_portnum);
   UTL_SMTP.helo (l_connection, p_smtp_hostname);
   UTL_SMTP.mail (l_connection, p_from);
   UTL_SMTP.rcpt (l_connection, p_to);
   l_temp := l_temp || 'MIME-Version: 1.0' || CHR (13) || CHR (10);
   l_temp := l_temp || 'To: ' || p_to || CHR (13) || CHR (10);
   l_temp := l_temp || 'From: ' || p_from || CHR (13) || CHR (10);
   l_temp := l_temp || 'Subject: ' || p_subject || CHR (13) || CHR (10);
   l_temp := l_temp || 'Reply-To: ' || p_from || CHR (13) || CHR (10);
   l_temp :=
         l_temp
      || 'Content-Type: multipart/alternative; boundary='
      || CHR (34)
      || l_boundary
      || CHR (34)
      || CHR (13)
      || CHR (10);
----------------------------------------------------
-- Write the headers
   DBMS_LOB.createtemporary (l_body_html, FALSE, 1000);
   DBMS_LOB.WRITE (l_body_html, LENGTH (l_temp), 1, l_temp);
----------------------------------------------------
-- Write the text boundary
   l_offset := DBMS_LOB.getlength (l_body_html) + 1;
   l_temp := '--' || l_boundary || CHR (13) || CHR (10);
   l_temp :=
         l_temp
      || 'content-type: text/plain; charset=us-ascii'
      || CHR (13)
      || CHR (10)
      || CHR (13)
      || CHR (10);
   DBMS_LOB.WRITE (l_body_html, LENGTH (l_temp), l_offset, l_temp);
----------------------------------------------------
-- Write the plain text portion of the email
   l_offset := DBMS_LOB.getlength (l_body_html) + 1;
   DBMS_LOB.WRITE (l_body_html, LENGTH (p_text), l_offset, p_text);
----------------------------------------------------
-- Write the HTML boundary
   l_temp :=
         CHR (13)
      || CHR (10)
      || CHR (13)
      || CHR (10)
      || '--'
      || l_boundary
      || CHR (13)
      || CHR (10);
   l_temp :=
         l_temp
      || 'content-type: text/html;'
      || CHR (13)
      || CHR (10)
      || CHR (13)
      || CHR (10);
   l_offset := DBMS_LOB.getlength (l_body_html) + 1;
   DBMS_LOB.WRITE (l_body_html, LENGTH (l_temp), l_offset, l_temp);
----------------------------------------------------
-- Write the HTML portion of the message
   l_offset := DBMS_LOB.getlength (l_body_html) + 1;
   DBMS_LOB.WRITE (l_body_html, LENGTH (p_html), l_offset, p_html);
----------------------------------------------------
-- Write the final html boundary
   l_temp := CHR (13) || CHR (10) || '--' || l_boundary || '--' || CHR (13);
   l_offset := DBMS_LOB.getlength (l_body_html) + 1;
   DBMS_LOB.WRITE (l_body_html, LENGTH (l_temp), l_offset, l_temp);
----------------------------------------------------
-- Send the email in 1900 byte chunks to UTL_SMTP
   l_offset := 1;
   l_ammount := 1900;
   UTL_SMTP.open_data (l_connection);

   WHILE l_offset < DBMS_LOB.getlength (l_body_html)
   LOOP
      UTL_SMTP.write_data (l_connection,
                           DBMS_LOB.SUBSTR (l_body_html, l_ammount, l_offset)
                          );
      l_offset := l_offset + l_ammount;
      l_ammount := LEAST (1900, DBMS_LOB.getlength (l_body_html) - l_ammount);
   END LOOP;

   UTL_SMTP.close_data (l_connection);
   UTL_SMTP.quit (l_connection);
   DBMS_LOB.freetemporary (l_body_html);
END;
/

CREATE OR REPLACE 
PROCEDURE placa_cierre (prm_keycuo IN VARCHAR2,
                        prm_gestion IN VARCHAR2,
                        prm_serial IN DECIMAL,
                        prm_secuencia IN VARCHAR2,
                        prm_placa IN VARCHAR2,
                        prm_operacion IN VARCHAR2
)
IS
   res   NUMBER;
BEGIN


if(prm_operacion = 'CIERRE') then

 SELECT count(1) into res
  FROM transitos.tra_pla_rut b
  where b.key_cuo = prm_keycuo and b.car_reg_year = prm_gestion and  b.car_reg_nber = prm_serial
  and tra_num = 0
  and key_secuencia <> 0
  and tra_fec_des is null;

    IF(res = 0) then
        UPDATE tra_estado_placa a
         SET tra_estado    = 1
       WHERE     a.key_cuo = prm_keycuo
             AND a.car_reg_year = prm_gestion
             AND a.car_reg_nber = prm_serial;
--             AND a.tra_placa = prm_placa;

    end if;

end if;

if(prm_operacion = 'CANCELACION') then

        UPDATE tra_estado_placa a
         SET tra_estado    = 1
       WHERE     a.key_cuo = prm_keycuo
             AND a.car_reg_year = prm_gestion
             AND a.car_reg_nber = prm_serial;
            -- AND a.tra_placa = prm_placa;

end if;


if(prm_operacion = 'FORZOSO') then

        UPDATE tra_estado_placa a
         SET tra_estado    = 1
       WHERE     a.key_cuo = prm_keycuo
             AND a.car_reg_year = prm_gestion
             AND a.car_reg_nber = prm_serial;
--             AND a.tra_placa = prm_placa;

end if;

if(prm_operacion = 'TRANSBORDO') then

        SELECT count(1) into res
  FROM transitos.tra_pla_rut b
  where b.key_cuo = prm_keycuo and b.car_reg_year = prm_gestion and  b.car_reg_nber = prm_serial
  and tra_num = 0
  and key_secuencia <> 0
  and tra_fec_des is null;

    IF(res = 0) then
        UPDATE tra_estado_placa a
         SET tra_estado    = 1
       WHERE     a.key_cuo = prm_keycuo
             AND a.car_reg_year = prm_gestion
             AND a.car_reg_nber = prm_serial;
--             AND a.tra_placa = prm_placa;

    end if;


end if;


END;
/

CREATE OR REPLACE 
PROCEDURE placa_inicio (prm_keycuo IN VARCHAR2,
/* Formatted on 23-dic.-2015 10:22:14 (QP5 v5.126) */
                        prm_gestion IN VARCHAR2,
                        prm_serial IN DECIMAL,
                        prm_placa IN VARCHAR2
)
IS
   res     NUMBER;
   placa   VARCHAR2 (27);
BEGIN
   placa   := prm_placa;

   IF (prm_placa = '0')
   THEN
      SELECT a.car_id_trp
        INTO placa
        FROM car_gen a
       WHERE     a.key_cuo = prm_keycuo
             AND a.car_reg_year = prm_gestion
             AND a.car_reg_nber = prm_serial;
   END IF;

   SELECT COUNT (1)
     INTO res
     FROM tra_pla_rut a
    WHERE     a.lst_ope = 'M'
          AND a.key_secuencia <> 0
          and a.tra_num = 0
          AND a.key_cuo = prm_keycuo
          AND a.car_reg_year = prm_gestion
          AND a.car_reg_nber = prm_serial;

   IF (res = 0)
   THEN
      SELECT COUNT (1)
        INTO res
        FROM tra_estado_placa a
       WHERE /*a.key_cuo = prm_keycuo
         AND a.car_reg_year = prm_gestion
         AND a.car_reg_nber = prm_serial
         AND*/
            a.tra_placa =
                placa;

      IF (res = 0)
      THEN
         INSERT INTO tra_estado_placa
         VALUES (prm_keycuo, prm_gestion, prm_serial, placa, 0);
      ELSE
         UPDATE tra_estado_placa a
            SET tra_estado       = 0,
                a.key_cuo        = prm_keycuo,
                a.car_reg_year   = prm_gestion,
                a.car_reg_nber   = prm_serial
          WHERE /* a.key_cuo = prm_keycuo
             AND a.car_reg_year = prm_gestion
             AND a.car_reg_nber = prm_serial
             AND*/
               a.tra_placa =
                   placa;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE 
PROCEDURE util_cierre (prm_keycuo      IN VARCHAR2,
                                         prm_gestion     IN VARCHAR2,
                                         prm_serial      IN DECIMAL,
                                         prm_secuencia   IN VARCHAR2,
                                         prm_usuario     IN VARCHAR2,
                                         prm_operacion   IN VARCHAR2)
IS
    res         NUMBER;
    secuencia   NUMBER;
BEGIN

    IF (    prm_operacion = 'CIERRE'
        OR prm_operacion = 'FORZOSO'
        OR prm_operacion = 'TRANSBORDO')
    THEN
        INSERT INTO util.em_mensaje_tmp (msj_codigo,
                                         key_year,
                                         key_cuo,
                                         key_dec,
                                         key_nber,
                                         usr_nam,
                                         sad_clr,
                                         upd_dat,
                                         upd_hor,
                                         asy_ref)
          VALUES   ('TRSDES',
                    prm_gestion,
                    prm_keycuo,
                    '0',
                    prm_serial,
                    prm_usuario,
                    '',
                    trunc(SYSDATE),
                    TO_CHAR (SYSDATE, 'HH24:mi'),
                    prm_secuencia);


        secuencia := TO_NUMBER (prm_secuencia);

        SELECT   COUNT (1)
          INTO   res
          FROM   transitos.tra_pla_rut b
         WHERE       b.key_cuo = prm_keycuo
                 AND b.car_reg_year = prm_gestion
                 AND b.car_reg_nber = prm_serial
                 AND tra_estado = 0
                 AND key_secuencia <> 0
                 AND tra_num = 0
                 AND tra_fec_des IS NULL;

        IF (res > 0)
        THEN
            INSERT INTO util.em_mensaje_tmp (msj_codigo,
                                             key_year,
                                             key_cuo,
                                             key_dec,
                                             key_nber,
                                             usr_nam,
                                             sad_clr,
                                             upd_dat,
                                             upd_hor,
                                             asy_ref)
              VALUES   ('TRSPAR',
                        prm_gestion,
                        prm_keycuo,
                        '0',
                        prm_serial,
                        prm_usuario,
                        '',
                        trunc(SYSDATE),
                        TO_CHAR (SYSDATE, 'HH24:mi'),
                        secuencia + 1);
        END IF;
    END IF;
END;
/

CREATE OR REPLACE 
PROCEDURE util_inicio (prm_keycuo      IN VARCHAR2,
                                         prm_gestion     IN VARCHAR2,
                                         prm_serial      IN DECIMAL,
                                         prm_usuario     IN VARCHAR2,
                                         prm_secuencia   IN VARCHAR2)
IS
BEGIN


    INSERT INTO util.em_mensaje_tmp (msj_codigo,
                                     key_year,
                                     key_cuo,
                                     key_dec,
                                     key_nber,
                                     usr_nam,
                                     sad_clr,
                                     upd_dat,
                                     upd_hor,
                                     asy_ref)
      VALUES   ('TRSPAR',
                prm_gestion,
                prm_keycuo,
                '0',
                prm_serial,
                prm_usuario,
                '',
                trunc(SYSDATE),
                TO_CHAR (SYSDATE, 'HH24:mi'),
                prm_secuencia);
END;
/

