CREATE OR REPLACE 
PACKAGE pkg_movil
IS
    TYPE cursortype IS REF CURSOR;



    PROCEDURE lista_aduana_paso (p_date_a         IN     VARCHAR2,
                                 p_date_b         IN     VARCHAR2,
                                 p_key_cuo        IN     VARCHAR2,
                                 p_car_reg_year   IN     VARCHAR2,
                                 p_ok                OUT VARCHAR2,
                                 p_respuesta         OUT VARCHAR2,
                                 paso                OUT cursortype);

 FUNCTION busca_matricula (keycuo    IN VARCHAR2,
                              gestion   IN VARCHAR2,
                              serial    IN NUMBER)
        RETURN VARCHAR2;


        FUNCTION ControlVersion( APLICACION IN VARCHAR2, VERSION IN VARCHAR2, MENSAJE OUT VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION control_imagen_cod (keycuo                IN VARCHAR2,
                               gestion               IN VARCHAR2,
                               serial                IN DECIMAL,
                             cantidad               in NUMBER,
                               tipo                  IN VARCHAR2)
        RETURN VARCHAR2;
END;                                                           -- Package spec
/

CREATE OR REPLACE 
PACKAGE BODY pkg_movil
IS
     -- Etapas del transito
    mt_nuevo             CONSTANT DECIMAL (2, 0) := 1;
    mt_pendiente         CONSTANT DECIMAL (2, 0) := 2;
    mt_concluido         CONSTANT DECIMAL (2, 0) := 3;
    mt_no_existe         CONSTANT DECIMAL (2, 0) := 4;
    mt_placa_pendiente   CONSTANT DECIMAL (2, 0) := 5;
    mt_registrado        CONSTANT DECIMAL (2, 0) := 6;
    mt_eliminado         CONSTANT DECIMAL (2, 0) := 7;
    mt_acta              CONSTANT DECIMAL (2, 0) := 8;
    mt_tna               CONSTANT DECIMAL (2, 0) := 9;
    mt_no_usuario        CONSTANT DECIMAL (2, 0) := 10;
    mt_no_eliminado      CONSTANT DECIMAL (2, 0) := 11;
    mt_no_localizado     CONSTANT DECIMAL (2, 0) := 12;
    mt_no_aduana_paso1   CONSTANT DECIMAL (2, 0) := 13;
    mt_no_aduana_paso2   CONSTANT DECIMAL (2, 0) := 14;
    mt_no_aduana_paso3   CONSTANT DECIMAL (2, 0) := 15;
    mt_no_aduana_paso4   CONSTANT DECIMAL (2, 0) := 16;
    mt_no_aduana_paso5   CONSTANT DECIMAL (2, 0) := 17;
    mt_boleta_garantia   CONSTANT DECIMAL (2, 0) := 18;
    mt_correcto          CONSTANT DECIMAL (2, 0) := 29;
    mt_error             CONSTANT DECIMAL (2, 0) := 99;
    -- Seleccion del tramite
    binicio              CONSTANT DECIMAL (2, 0) := 1;
    bfinalizacion        CONSTANT DECIMAL (2, 0) := 2;
    bmodificacion        CONSTANT DECIMAL (2, 0) := 3;
    bcancelacion         CONSTANT DECIMAL (2, 0) := 4;
    bmod_manifiesto      CONSTANT DECIMAL (2, 0) := 5;
    bhabilitamedio       CONSTANT DECIMAL (2, 0) := 7;
    bpaso                CONSTANT DECIMAL (2, 0) := 8;
    bptoctl              CONSTANT DECIMAL (2, 0) := 9;
    betiqueta            CONSTANT DECIMAL (2, 0) := 12;
    breporte             CONSTANT DECIMAL (2, 0) := 21;
    --PlazoEtiqueta
    bsalidapuerto        CONSTANT DECIMAL (2, 0) := 16;
    blistasalidapuerto   CONSTANT DECIMAL (2, 0) := 17;
    -- Seleccion del cierre
    bnormal              CONSTANT DECIMAL (2, 0) := 24;
    btransbordo          CONSTANT DECIMAL (2, 0) := 28;
    bforzoso             CONSTANT DECIMAL (2, 0) := 23;
    -- Estado de boletas
    bexiste              CONSTANT VARCHAR2 (1) := 1;
    bnoexiste            CONSTANT VARCHAR2 (1) := 0;

    --Modificado Edgar 27112014 Nuevo OCE
    v_fecha_corte        CONSTANT DATE := to_date('15/12/2015','dd/mm/yyyy');

   /**************************************
    *   Verificamos la etapa del transito *
    **************************************/


 /*****************************************************************
       recuperamos el manifiesto o el transito
    ******************************************************************/
    PROCEDURE lista_aduana_paso (   p_date_a    IN  VARCHAR2,
                                    p_date_b    IN  VARCHAR2,
                                    p_key_cuo   IN VARCHAR2,
                                    p_car_reg_year  in VARCHAR2,
                                    p_ok              OUT  VARCHAR2,
                                    p_respuesta       OUT  VARCHAR2,
                                    paso               OUT cursortype)
    IS
        cantidad    DECIMAL (3, 0);
        c           number;
        viaje       VARCHAR2 (15);
        fecreg      DATE;
        ecantidad   PLS_INTEGER;
        emax        PLS_INTEGER;
        fmax        VARCHAR2 (50);
        precinto    VARCHAR2 (200);
        pre_emic    VARCHAR2 (500);
        p_res_aux   VARCHAR2 (3999);
         CURSOR CAB
        IS
        SELECT   a.key_cuo ,
                 a.car_reg_year,
                 a.car_reg_nber,
                 a.key_secuencia,
                 a.tra_cuo_ini,
                 a.tra_fec_ini,
                 a.tra_cuo_est,
                 a.tra_fec_est,
                 a.tra_pre,
                 a.tra_plazo,
                 a.tra_ruta,
                 a.tra_cuo_des,
                 a.tra_fec_des,
                 a.tra_tipo,
                 a.tra_obs,
                 a.act_boleta,
                 a.act_entidad,
                 a.act_fec_ini,
                 a.act_fec_fin,
                 a.act_monto,
                 a.act_moneda,
                 a.tra_loc,
                 a.tra_estado,
                 a.lst_ope,
                 a.tra_num,
                 a.usr_nam,
                 a.usr_fec,busca_matricula(p_key_cuo,p_car_reg_year,a.car_reg_nber) as matri
          FROM   tra_pla_rut a
         WHERE       a.tra_loc = 0
                 AND a.tra_num = 0
                 AND a.tra_fec_est BETWEEN TO_DATE (p_date_a, 'dd/mm/yyyy') AND TO_DATE (p_date_b, 'dd/mm/yyyy')
                 AND a.tra_num = 0
                 AND a.lst_ope = 'U'
                 AND a.key_secuencia = 1
                 AND a.key_cuo = p_key_cuo --'072'
                 AND a.car_reg_year = p_car_reg_year --2015
                 AND (a.key_cuo, a.car_reg_year, a.car_reg_nber) NOT IN
                            (SELECT   b.key_cuo, b.car_reg_year, b.car_reg_nber
                               FROM   tra_pla_rut b
                              WHERE       b.key_secuencia = 0
                                      AND b.tra_num = 0
                                      AND b.lst_ope = 'U');

    BEGIN
        p_ok:='0';
        c:=0;
        p_respuesta :='';
                open paso FOR

               SELECT   a.key_cuo ,
                 a.car_reg_year,
                 a.car_reg_nber,
                 a.key_secuencia,
                 a.tra_cuo_ini,
                 a.tra_fec_ini,
                 a.tra_cuo_est,
                 a.tra_fec_est,
                 a.tra_pre,
                 a.tra_plazo,
                 a.tra_ruta,
                 a.tra_cuo_des,
                 a.tra_fec_des,
                 a.tra_tipo,
                 a.tra_obs,
                 a.act_boleta,
                 a.act_entidad,
                 a.act_fec_ini,
                 a.act_fec_fin,
                 a.act_monto,
                 a.act_moneda,
                 a.tra_loc,
                 a.tra_estado,
                 a.lst_ope,
                 a.tra_num,
                 a.usr_nam,
                 a.usr_fec,busca_matricula(p_key_cuo,p_car_reg_year,a.car_reg_nber) as matri
          FROM   tra_pla_rut a
         WHERE       a.tra_loc = 0
                 AND a.tra_num = 0
                 AND a.TRA_FEC_EST BETWEEN TO_DATE (p_date_a, 'dd/mm/yyyy') AND TO_DATE (p_date_b, 'dd/mm/yyyy')
                 AND a.tra_num = 0
                 AND a.lst_ope = 'U'
                 AND a.key_secuencia = 1
                 AND a.key_cuo =p_key_cuo --'072'
                 AND a.car_reg_year = p_car_reg_year --2015
                 AND (a.key_cuo, a.car_reg_year, a.car_reg_nber) NOT IN
                            (SELECT   b.key_cuo, b.car_reg_year, b.car_reg_nber
                               FROM   tra_pla_rut b
                              WHERE       b.key_secuencia = 0
                                      AND b.tra_num = 0
                                      AND b.lst_ope = 'U');

      FOR i IN CAB
        LOOP
          c := c + 1;p_ok:='1';
        -- p_respuesta:= i.car_reg_nber;
            p_respuesta :=p_respuesta||
                   '<fila'||c||'><key_cuo>'
                || i.key_cuo
                || '</key_cuo><gestion>'
                || i.car_reg_year
                || '</gestion><registro>'
                || i.car_reg_nber
                || '</registro><aduana>'
                || i.key_cuo
                || '</aduana><usuario>'
                || i.usr_nam
                || '</usuario><fechaini>'
                || i.tra_fec_ini
                || '</fechaini></fila'||c||'>';

        END LOOP;
        p_respuesta:=p_respuesta||'<numero>'||c||'</numero>';
    END;

   FUNCTION busca_matricula (keycuo IN VARCHAR2,gestion in VARCHAR2,serial in NUMBER)
    RETURN VARCHAR2
    IS
            matricula VARCHAR2(20);
    BEGIN
        matricula:='NO-HAY';
            SELECT
                         cg.car_id_trp

                         into matricula
                  FROM   tra_pla_rut a, ops$asy.car_gen cg
                 WHERE       a.key_cuo = cg.key_cuo
                         AND a.car_reg_year = cg.car_reg_year
                         AND a.car_reg_nber = cg.car_reg_nber
                         AND a.tra_num = 0
                         --AND a.lst_ope = 'U'
                         --edgar 04092014
                         AND a.lst_ope in ('U','M')
                         AND cg.key_cuo = keycuo
                         AND cg.car_reg_year = gestion
                         AND cg.car_reg_nber = serial
                         AND a.tra_estado = 0;

            IF matricula is not null
            THEN
                return matricula;
            ELSE

                RETURN 'NO-HAY';
            END IF;
    END;

    FUNCTION ControlVersion( APLICACION IN VARCHAR2, VERSION IN VARCHAR2, MENSAJE OUT VARCHAR2)
   RETURN VARCHAR2 IS
   hay  NUMBER:= 0;
   BEGIN

    SELECT COUNT(1)
      INTO hay
      FROM ops$asy.mov_version a
     WHERE a.ver_codigo = APLICACION
       AND a.ver_version = VERSION
       AND a.ver_num = 0;

    --- CONTROL FRECUENCIA ---
   /* BEGIN
        frecuencia('CONTACTO ANB','CONTROL VERSION');
    EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error: Frecuencia(CONTROL VERSION)');
    END;*/
    --------------------------

       IF (hay = 0) THEN
            MENSAJE := 'NO HAY DATOS';
            RETURN '1';
       ELSE
            MENSAJE := 'CORRECTO';
            RETURN '0';
       END IF;

    EXCEPTION
       WHEN OTHERS
       THEN
       MENSAJE := 'Error ' || SQLCODE || '. ' || SQLERRM;
       RETURN '2';

   END ControlVersion;

   FUNCTION control_imagen_cod (keycuo                IN VARCHAR2,
                               gestion               IN VARCHAR2,
                               serial                IN DECIMAL,
                                cantidad               in NUMBER,
                               tipo                  IN VARCHAR2)
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

            IF ((existe+cantidad) <= 3)
            THEN

                RETURN 'CORRECTO';
            ELSE
                RETURN 'SOLO SE PUEDEN ADJUNTAR 3 FOTOS DE PRECINTOS COMO MAXIMO, ACTUALMENTE HAY '||existe;
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;


END;
/

