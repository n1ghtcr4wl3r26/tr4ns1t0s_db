CREATE OR REPLACE 
FUNCTION cierre (
   skeycuo     IN   VARCHAR2,
   sgestion    IN   VARCHAR2,
   iregistro   IN   NUMBER,
   sdocemb     IN   VARCHAR2
)
   RETURN BOOLEAN
IS
   valor   NUMBER;
BEGIN
   valor := pkg_localiza.localiza (skeycuo, sgestion, iregistro, sdocemb);
   RETURN TRUE;
END;
/

CREATE OR REPLACE 
FUNCTION devuelve_tecnico_inicio
  ( prm_keycuo      IN     VARCHAR2,
                              prm_gestion     IN     VARCHAR2,
                              prm_serial      IN     DECIMAL,
                              prm_secuencia   IN     DECIMAL)
  RETURN  VARCHAR2 IS

    res varchar2(1000) := '';
    usuario varchar2(100) := '-';
BEGIN

for i in (select distinct a.usr_nam ,nvl(b.usuapepat,' ')||' '|| nvl(b.usuapemat,' ')||' '||  nvl(b.usunombre ,' ') nombre, to_char(a.usr_fec,'dd/mm/yyyy hh24:mi:ss') fecha,a.usr_fec
FROM transitos.tra_pla_rut a, usuario.usuario b
where b.usu_num = 0
and b.usucodusu = a.usr_nam
and car_reg_year = prm_gestion
and key_cuo =prm_keycuo
and car_reg_nber = prm_serial
and key_secuencia = prm_secuencia
order by a.usr_fec asc) loop

res := res || i.usr_nam ||'-'||i.nombre ||'-'||i.fecha ||UTL_TCP.crlf;


end loop;




    RETURN res ;
EXCEPTION
   WHEN OTHERS
    THEN
        RETURN '-';
END;
/

CREATE OR REPLACE 
FUNCTION devuelve_tecnicos_operaciones
  ( prm_keycuo      IN     VARCHAR2,
                              prm_gestion     IN     VARCHAR2,
                              prm_serial      IN     DECIMAL,
                              prm_secuencia   IN     DECIMAL)
  RETURN  VARCHAR2 IS

    res varchar2(1000) := '';
    usuario varchar2(100) := '-';
    cont number(8) := 0;
BEGIN

/*
for i in (select distinct a.usr_nam ,nvl(b.usuapepat,' ')||' '|| nvl(b.usuapemat,' ')||' '||  nvl(b.usunombre ,' ') nombre, to_char(a.usr_fec,'dd/mm/yyyy hh24:mi:ss') fecha,a.usr_fec
FROM transitos.tra_pla_rut a, usuario.usuario b
where b.usu_num = 0
and b.usucodusu = a.usr_nam
and car_reg_year = prm_gestion
and key_cuo =prm_keycuo
and car_reg_nber = prm_serial
and key_secuencia = prm_secuencia
order by a.usr_fec asc) loop

res := res || i.usr_nam ||' - '||i.nombre ||' - '||i.fecha ||UTL_TCP.crlf;
end loop;
*/
/*
for i in (select distinct a.usr_nam, to_char(a.usr_fec,'dd/mm/yyyy hh24:mi:ss') fecha,a.usr_fec
FROM transitos.tra_pla_rut a
where car_reg_year = prm_gestion
and key_cuo =prm_keycuo
and car_reg_nber = prm_serial
and key_secuencia = prm_secuencia
order by a.usr_fec asc) loop
*/
res:= '<div style="width:200px">';
FOR I IN (
SELECT    usr_nam, estado
  FROM   (  SELECT   DISTINCT
                     DECODE (
                         key_secuencia,
                         0,
                         'ADUANA DE PASO',
                         DECODE (
                             lst_ope,
                             'M',
                             'REGISTRO MIC ANTICIPADO',
                             'D',
                             'CANCELACION DE TRANSITO',
                             DECODE (
                                 tra_fec_des,
                                 NULL,                   --ES NULO SIN LLEGADA
                                 DECODE (tra_estado,
                                         0, 'INICIO',
                                         'VERSIONAMIENTO'),
                                 --NO ES NULO, QUE LLEGO

                                 DECODE (tra_estado,
                                         1, 'CIERRE',
                                         'VERSIONAMIENTO'))))
                         estado,

                     a.usr_nam,
                     a.usr_fec
              FROM   transitos.tra_pla_rut a
             WHERE       a.key_cuo = prm_keycuo
                     AND a.car_reg_year = prm_gestion
                     AND a.car_reg_nber = prm_serial
                     AND a.key_secuencia = prm_secuencia
                     AND a.tra_fec_ini =
                            (SELECT   MAX (b.tra_fec_ini)
                               FROM   transitos.tra_pla_rut b
                              WHERE       a.key_cuo = b.key_cuo
                                      AND a.car_reg_year = b.car_reg_year
                                      AND a.car_reg_nber = b.car_reg_nber
                                      AND a.key_secuencia = b.key_secuencia)
          ORDER BY   usr_fec asc) tbl
 WHERE   estado <> 'VERSIONAMIENTO'
) LOOP



res := res || i.estado ||' - '||i.usr_nam ||'<br>';
cont := cont +1;


end loop;

res:= res ||'</div>';


if(cont = 0) then
res:= '-';
end if;


    RETURN res ;
EXCEPTION
   WHEN OTHERS
    THEN
        RETURN '-';
END;
/

CREATE OR REPLACE 
FUNCTION manifiesto_activo
  ( placa IN VARCHAR2
  )
 RETURN  VARCHAR2 IS
res varchar2(200) := '-';
BEGIN

SELECT tb.key_cuo|| tb.car_reg_year|| tb.car_reg_nber into res
          FROM (SELECT x.key_cuo, x.car_reg_year, x.car_reg_nber
                  FROM ops$asy.car_gen x, transitos.tra_pla_rut y
                 WHERE     x.key_cuo = y.key_cuo
                       AND x.car_reg_year = y.car_reg_year
                       AND x.car_reg_nber = y.car_reg_nber
                       AND x.car_id_trp = placa
                       AND y.tra_num = 0
                       AND y.key_secuencia <> 0
                ORDER BY y.tra_fec_ini DESC) tb
         WHERE ROWNUM = 1;

    RETURN res ;
EXCEPTION
   WHEN OTHERS
    THEN
        RETURN '-';
END;
/

CREATE OR REPLACE 
FUNCTION tiene_acta
  ( prm_keycuo      IN     VARCHAR2,
                              prm_gestion     IN     VARCHAR2,
                              prm_serial      IN     DECIMAL,
                              prm_secuencia   IN     DECIMAL)
  RETURN  VARCHAR2 IS

res varchar2(200) := '-';
BEGIN

/*SELECT DECODE (tac_estado,
          0, 'ACTA DE INTERVENCION - Empresa y Medio con TNA',
          1, 'ACTA DE INTERVENCION - Empresa con TNA',
          2, 'ACTA DE INTERVENCION - Medio con TNA',
          '-') into res*/
SELECT DECODE (tac_estado,
          0, 'TRANSITO FUERZA DE PLAZO CON ACTA DE INTERVENCION: '||tac_acta,
          1, 'TRANSITO FUERZA DE PLAZO CON ACTA DE INTERVENCION: '||tac_acta,
          2, 'TRANSITO FUERZA DE PLAZO CON ACTA DE INTERVENCION: '||tac_acta,
          '-') into res
       FROM tra_acta a
 WHERE     lst_ope = 'U'
       AND tac_num = 0
       AND key_cuo = prm_keycuo
       AND car_reg_year = prm_gestion
       AND car_reg_nber = prm_serial
       AND key_secuencia = prm_secuencia;

    RETURN res ;
EXCEPTION
   WHEN OTHERS
    THEN
        RETURN '-';
END;
/

CREATE OR REPLACE 
FUNCTION tiene_salida_puerto
  ( prm_cuo IN varchar2,
    prm_year IN varchar2,
    prm_nber IN varchar2,
    prm_tipo IN varchar2 --tipo de consulta si es 1 es pa registro, 2 es pa control
  )
  RETURN  NUMBER IS
--
   res NUMBER(8);
   cantidad NUMBER(8);
   -- Declare program variables as shown above
BEGIN


if(prm_tipo = '1') then

-- verifica si el tramite tiene salida de puerto, consultando si registro su peso en la tabla tramicanticipado
         SELECT count(*)
           into cantidad
           FROM tra_micanticipado m
          WHERE m.key_cuo = prm_cuo
            AND m.car_reg_year = prm_year
            AND m.car_reg_nber = prm_nber
            AND m.mic_lst_ope = 'U'
            AND m.mic_num = 0;
 end if;


if(prm_tipo = '2') then


        SELECT count(*) into res
           FROM tra_pla_rut m
          WHERE m.key_cuo = prm_cuo
            AND m.car_reg_year = prm_year
            AND m.car_reg_nber = prm_nber
            and m.key_secuencia = 1
            and m.tra_num = 0
            and m.usr_fec > to_date('20/08/2014 08:14','dd/mm/yyyy hh24:mi');

        IF res > 0 THEN

-- verifica si el tramite tiene salida de puerto, consultando si registro su peso en la tabla tramicanticipado
         SELECT count(*)
           into cantidad
           FROM tra_micanticipado m
          WHERE m.key_cuo = prm_cuo
            AND m.car_reg_year = prm_year
            AND m.car_reg_nber = prm_nber
            AND m.mic_lst_ope = 'U'
            AND m.mic_num = 0;
         else
         cantidad :=1;

         end if;

 end if;



return cantidad;
EXCEPTION
   WHEN no_data_found
   THEN
     RETURN 0;
END;
/

CREATE OR REPLACE 
FUNCTION tiene_salida_puerto_dui (prm_cuo    IN VARCHAR2,
/* Formatted on 19/08/2014 15:15:19 (QP5 v5.126) */
                                  prm_year   IN VARCHAR2,
                                  prm_nber   IN VARCHAR2)
    RETURN NUMBER
IS
    res        NUMBER (8);
    cantidad   NUMBER (8);
    n_cuo      VARCHAR2 (3);
    n_year     VARCHAR2 (4);
    n_nber     VARCHAR2 (20);
-- Declare program variables as shown above
BEGIN
    SELECT   g.key_cuo, g.car_reg_year, g.car_reg_nber
      INTO   n_cuo, n_year, n_nber
      FROM   ops$asy.dec_man d, ops$asy.car_bol_gen c, ops$asy.car_gen g
     WHERE   declaracion LIKE prm_year || '&' || prm_cuo || '&C&' || prm_nber
             AND d.sad_num = 0
             AND d.key_cuo = c.key_cuo
             AND d.key_voy_nber = c.key_voy_nber
             AND d.key_dep_date = c.key_dep_date
             AND d.key_bol_ref = c.key_bol_ref
             AND g.key_cuo = c.key_cuo
             AND g.key_voy_nber = c.key_voy_nber
             AND g.key_dep_date = c.key_dep_date;

    IF (SUBSTR (n_cuo, 1, 1) = '0')
    THEN
        -- verifica si el tramite tiene salida de puerto, consultando si registro su peso en la tabla tramicanticipado
        SELECT   COUNT ( * )
          INTO   cantidad
          FROM   tra_micanticipado m
         WHERE       m.key_cuo = n_cuo
                 AND m.car_reg_year = n_year
                 AND m.car_reg_nber = n_nber
                 AND m.mic_lst_ope = 'U'
                 AND m.mic_num = 0;

        IF (cantidad = 0)
        THEN
            RETURN 0;
        ELSE
            RETURN 1;
        END IF;
    ELSE
        RETURN 1;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        RETURN 0;
END;
/

CREATE OR REPLACE 
FUNCTION transito_estado
  ( aduana IN VARCHAR2,
  gestion IN VARCHAR2,
  numero IN VARCHAR2
  )
 RETURN  VARCHAR2 IS
res number := 0;
aux varchar2(2) := '';
BEGIN



SELECT distinct lst_ope  into aux
--select *
  FROM transitos.tra_pla_rut b
  where b.key_cuo = aduana and b.car_reg_year = gestion and  b.car_reg_nber = numero
  and tra_num = 0
  and key_secuencia <> 0;

if(aux = 'D') then
res := 1;

else

  SELECT decode(count(1),0,1,0) into res
  FROM transitos.tra_pla_rut b
  where b.key_cuo = aduana and b.car_reg_year = gestion and  b.car_reg_nber = numero
  and tra_num = 0
  and key_secuencia <> 0
  and tra_fec_des is null;

end if;


    RETURN res ;
EXCEPTION
   WHEN OTHERS
    THEN
        RETURN -1;
END;
/

CREATE OR REPLACE 
FUNCTION verifica_medio (medio IN VARCHAR2, dep_cod IN VARCHAR2, des_cod IN VARCHAR2)
    RETURN NUMBER
IS
    cantidad   NUMBER (1):=0;
    v_aduana   VARCHAR2 (5);
BEGIN
    SELECT   COUNT (1)
      INTO   cantidad
      FROM   tra_pla_rut a, ops$asy.car_gen b
     WHERE       a.key_cuo = b.key_cuo
             AND a.car_reg_year = b.car_reg_year
             AND a.car_reg_nber = b.car_reg_nber
             AND a.tra_num = 0
             AND a.lst_ope = 'U'
             AND b.car_id_trp = medio
             AND NOT b.car_id_trp IN ('11111', '00000')      -- Propios medios
             AND NVL (a.tra_tipo, 22) <> 28
             AND a.tra_loc = 0;

    IF (cantidad > 0)
    THEN
        SELECT   distinct b.key_cuo
          INTO   v_aduana
          FROM   tra_pla_rut a, ops$asy.car_gen b
         WHERE       a.key_cuo = b.key_cuo
                 AND a.car_reg_year = b.car_reg_year
                 AND a.car_reg_nber = b.car_reg_nber
                 AND a.tra_num = 0
                 AND a.lst_ope = 'U'
                 AND b.car_id_trp = medio
                 AND NOT b.car_id_trp IN ('11111', '00000')      -- Propios medios
                 AND NVL (a.tra_tipo, 22) <> 28
                 AND a.tra_loc = 0;
        IF NOT (SUBSTR(DEP_COD,1,2)='BO' AND SUBSTR(DES_COD,1,2)<>'BO' AND v_aduana IN ('071','072'))
        THEN
            RETURN 1381;
        END IF;
    END IF;

    SELECT   COUNT (1)
      INTO   cantidad
      FROM   tra_acta
     WHERE       car_id_trp = medio
             AND tac_num = 0
             AND tac_estado IN (0, 2)
             AND lst_ope = 'U';

    IF (cantidad > 0)
    THEN
        RETURN 1381;
    END IF;

    RETURN 0;
EXCEPTION
    WHEN OTHERS
    THEN
        RETURN -1;
END;
/

CREATE OR REPLACE 
FUNCTION verifica_operador (ope_nit IN VARCHAR2, placa IN VARCHAR2)

    RETURN NUMBER
IS
    hay             NUMBER (10) := 0;
    existe          NUMBER (10) := 0;
    v_fecha_corte   DATE := TO_DATE ('15/12/2015', 'dd/mm/yyyy');
BEGIN

    SELECT count(1) INTO existe FROM ops$asy.bo_oce_opetipo x
     where x.ope_numerodoc = ope_nit
     and x.tip_tipooperador in ('TRN','TRE','NAL')
     and x.tip_num = 0 and x.tip_lst_ope = 'U' ;

    /*SELECT   COUNT (1)
      INTO   existe
      FROM   ops$asy.bo_oce_opetipo ot, ops$asy.bo_oce_tarope pl
     WHERE       ot.tip_tipooperador = pl.tip_tipooperador
             AND ot.ope_numerodoc = pl.ope_numerodoc
             AND ot.tip_num = 0
             AND ot.ope_numerodoc = ope_nit
             AND pl.pla_nro_placa = placa
             AND pl.tar_num = 0
             AND ot.tip_estado = 'H';*/

    IF existe = 0 AND SYSDATE < v_fecha_corte
    THEN
        SELECT   COUNT (1)
          INTO   hay
          FROM   operador.olopetab a2,
                 operador.olopetip e2,
                 operador.oope_trp b2,
                 operador.oltratab c2,
                 operador.unmrctab x2,
                 operador.unesttab z2
         WHERE       a2.ult_ver = 0
                 --AND a2.ope_nit = ope_nit
                 AND c2.nro_placa = placa
                 AND a2.emp_cod = e2.emp_cod
                 AND b2.tbl_sta = 'H'
                 AND a2.ult_ver = e2.ult_ver
                 AND e2.emp_cod = b2.emp_cod
                 AND e2.ope_tip = b2.ope_tip
                 AND e2.ult_ver = b2.ult_ver
                 AND b2.trp_cod = c2.trp_cod
                 AND b2.ult_ver = c2.ult_ver
                 AND x2.mrc_cod = c2.mrc_cod
                 AND x2.ult_ver = 0
                 AND z2.est_cod = b2.tbl_sta
                 AND z2.ult_ver = 0;
    ELSE
        SELECT   COUNT (1) into hay
          FROM   ops$asy.bo_oce_opetipo ot, ops$asy.bo_oce_tarope pl
         WHERE       ot.tip_tipooperador = pl.tip_tipooperador
                 AND ot.ope_numerodoc = pl.ope_numerodoc
                 AND ot.tip_num = 0
                 --AND ot.ope_numerodoc = ope_nit
                 AND pl.pla_nro_placa = placa
                 AND pl.tar_num = 0
                 AND ot.tip_estado = 'H';
    END IF;



    RETURN hay;
END;
/

CREATE OR REPLACE 
FUNCTION zcoma
  ( param1 IN varchar2)
  RETURN  varchar2 IS
   res                 VARCHAR2(30);
BEGIN
    res := REPLACE(param1, ',','.');
    RETURN res ;

END;
/

