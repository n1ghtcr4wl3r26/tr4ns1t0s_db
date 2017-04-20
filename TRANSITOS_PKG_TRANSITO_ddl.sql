CREATE OR REPLACE 
PACKAGE pkg_transito
/* Formatted on 29/11/2016 10:46:31 (QP5 v5.126) */
IS
    TYPE cursortype IS REF CURSOR;

    FUNCTION verfica_transito (keycuo     IN     VARCHAR2,
                               gestion    IN     VARCHAR2,
                               serial     IN     DECIMAL,
                               aduana     IN     VARCHAR2,
                               usuario    IN     VARCHAR2,
                               etapa      IN     DECIMAL,
                               sboleta       OUT DECIMAL,
                               stna          OUT DECIMAL,
                               cabecera      OUT cursortype,
                               item          OUT cursortype)
        RETURN DECIMAL;

    FUNCTION verfica_transito_dep (keycuo     IN     VARCHAR2,
                                   gestion    IN     VARCHAR2,
                                   serial     IN     DECIMAL,
                                   aduana     IN     VARCHAR2,
                                   usuario    IN     VARCHAR2,
                                   etapa      IN     DECIMAL,
                                   sboleta       OUT DECIMAL,
                                   stna          OUT DECIMAL,
                                   cabecera      OUT cursortype,
                                   item          OUT cursortype)
        RETURN DECIMAL;

    PROCEDURE consulta_transito (keycuo     IN     VARCHAR2,
                                 gestion    IN     VARCHAR2,
                                 serial     IN     DECIMAL,
                                 etapa      IN     DECIMAL,
                                 cabecera      OUT cursortype,
                                 item          OUT cursortype);

    FUNCTION verifica_empresa_habilitada (codtran IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION borra_transito (keycuo    IN VARCHAR2,
                             gestion   IN VARCHAR2,
                             serial    IN DECIMAL,
                             usuario   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION graba_ruta_plazo (keycuo     IN     VARCHAR2,
                               gestion    IN     VARCHAR2,
                               serial     IN     DECIMAL,
                               modtra     IN     DECIMAL, -- Modo de transporte
                               sfecpar    IN     VARCHAR2,
                               adupas     IN OUT VARCHAR2,
                               laduanas   IN     VARCHAR2,
                               pre_uno    IN     VARCHAR2,
                               obs        IN     VARCHAR2,
                               --para la boleta
                               boleta     IN     VARCHAR2,
                               entidad    IN     VARCHAR2,
                               fecini     IN     VARCHAR2,
                               fecfin     IN     VARCHAR2,
                               monto      IN     DECIMAL,
                               moneda     IN     VARCHAR2,
                               --el usuario
                               usuario    IN     VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION cierra_transito (keycuo      IN     VARCHAR2,
                              gestion     IN     VARCHAR2,
                              serial      IN     DECIMAL,
                              secuencia   IN     DECIMAL,
                              adudes      IN     VARCHAR2, -- aduana de estino
                              fecdes      IN     VARCHAR2,
                              codtrans    IN     VARCHAR2, -- empresa de transporte
                              placa       IN     VARCHAR2,      -- medio placa
                              icierre     IN     DECIMAL,    -- Tipo de cierre
                              obs         IN     VARCHAR2,
                              usuario     IN     VARCHAR2,
                              ans            OUT VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION lista_aduanas (usuario IN VARCHAR2)
        RETURN cursortype;

    FUNCTION consulta_peso (keycuo    IN VARCHAR2,
                            gestion   IN VARCHAR2,
                            serial    IN DECIMAL,
                            adudes    IN VARCHAR)
        RETURN cursortype;

    FUNCTION consulta_bitacora (keycuo    IN VARCHAR2,
                                gestion   IN VARCHAR2,
                                serial    IN DECIMAL)
        RETURN cursortype;

    FUNCTION consulta_transportista (nit IN VARCHAR2)
        RETURN cursortype;

    FUNCTION consulta_placa (placa   IN VARCHAR2,
                             sini    IN VARCHAR2,
                             sfin    IN VARCHAR2)
        RETURN cursortype;


    FUNCTION letras_numeros (texto IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION lista_ptoctl (usuario IN VARCHAR2)
        RETURN cursortype;

    FUNCTION registro_paso_peso (keycuo       IN VARCHAR2,
                                 gestion      IN VARCHAR2,
                                 serial       IN DECIMAL,
                                 fecha_paso   IN VARCHAR2,
                                 aduana       IN VARCHAR2,
                                 usuario      IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION reporte_aduana_peso_paso (fec_ini   IN VARCHAR2,
                                       fec_fin   IN VARCHAR2,
                                       npeso     IN PLS_INTEGER,
                                       nobs      IN PLS_INTEGER)
        RETURN cursortype;

    FUNCTION versiona_transito (keycuo    IN VARCHAR2,
                                gestion   IN VARCHAR2,
                                serial    IN DECIMAL)
        RETURN NUMBER;

    FUNCTION graba_plazo_etiqueta (keycuo    IN VARCHAR2,
                                   gestion   IN VARCHAR2,
                                   serial    IN DECIMAL,
                                   --el usuario
                                   usucuo    IN VARCHAR2,
                                   usuario   IN VARCHAR2,
                                   peso      IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION devuelve_estado (prm_keycuo    IN VARCHAR2,
                              prm_gestion   IN VARCHAR2,
                              prm_serial    IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION transbordo_transito (keycuo      IN     VARCHAR2,
                                  gestion     IN     VARCHAR2,
                                  serial      IN     DECIMAL,
                                  secuencia   IN     DECIMAL,
                                  adudes      IN     VARCHAR2, -- aduana de estino
                                  fecdes      IN     VARCHAR2,
                                  codtrans    IN     VARCHAR2, -- empresa de transporte
                                  placa       IN     VARCHAR2,  -- medio placa
                                  icierre     IN     DECIMAL, -- Tipo de cierre
                                  obs         IN     VARCHAR2,
                                  usuario     IN     VARCHAR2,
                                  ans            OUT VARCHAR2,
                                  tipodoc     IN     VARCHAR2, --documento de destino MIC o TIF
                                  modo        IN     VARCHAR2, --CARRETERO FERREO
                                  precintos   IN     VARCHAR2, --NUEVOS PRECINTOS DEL TRANSBORDO
                                  aduandes    IN     VARCHAR2, --ADUANA DE DESTINO DEL MANIFIESTO
                                  obsdes      IN     VARCHAR2,
                                  manyear        OUT VARCHAR2,
                                  mancuo         OUT VARCHAR2,
                                  mannber        OUT VARCHAR2) --OBSERVACION DEL NUEVO INICIO DE TRANSITO
        RETURN VARCHAR2;

    FUNCTION valida_verifdocs (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION valida_verifdocs_spuerto (keycuo    IN VARCHAR2,
                                       gestion   IN VARCHAR2,
                                       serial    IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE replica_control_embarque (prm_keycuo24    IN VARCHAR2,
                                        prm_gestion24   IN VARCHAR2,
                                        prm_serial24    IN DECIMAL,
                                        prm_keycuo23    IN VARCHAR2,
                                        prm_gestion23   IN VARCHAR2,
                                        prm_serial23    IN DECIMAL,
                                        prm_usuario     IN VARCHAR2);
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_transito
/* Formatted on 29/11/2016 10:46:33 (QP5 v5.126) */
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
    --Transbordo
    btransbordoferreo    CONSTANT DECIMAL (2, 0) := 18;
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
    v_fecha_corte CONSTANT DATE
            := TO_DATE ('15/12/2015', 'dd/mm/yyyy') ;

    -- verificamos si el medio tiene transito pendiente
    FUNCTION verifica_medio_pendiente (placa VARCHAR2)
        RETURN DECIMAL
    IS
        cantidad   DECIMAL (3, 0);
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut a, ops$asy.car_gen b
         WHERE       a.key_cuo = b.key_cuo
                 AND a.car_reg_year = b.car_reg_year
                 AND a.car_reg_nber = b.car_reg_nber
                 AND a.tra_num = 0
                 AND a.lst_ope = 'U'
                 AND b.car_id_trp = placa
                 AND NOT b.car_id_trp IN ('11111', '00000')  -- Propios medios
                 AND NVL (a.tra_tipo, 22) <> 28
                 AND a.tra_loc = 0;

        RETURN cantidad;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0;
    END;

    -- Verificamos si la empresa esta habilitado como empresa de transportes
    FUNCTION verifica_empresa_habilitada (codtran IN VARCHAR2)
        RETURN VARCHAR2
    IS
        id    VARCHAR2 (30);
        hay   DECIMAL (3, 0);
    BEGIN
        -- Operador
        /*
        SELECT   NVL (a.emp_cod, 0)
          INTO   id
          FROM   operador.olopetip a, operador.olopetab b
         WHERE       a.emp_cod = b.emp_cod
                 AND a.ope_tip IN ('TRN', 'TRE', 'NAL')
                 AND a.tbl_sta = 'H'
                 AND a.cuo_cod = 'S/R'
                 AND a.ult_ver = 0
                 AND b.ult_ver = 0
                 AND b.ope_nit = codtran;*/

        --Modificado Edgar 27112014 Nuevo OCE  QUERY 3  Cambiar logica para que devuelva el NIT y no el em_cod

        SELECT   COUNT (1)
          INTO   hay
          FROM   ops$asy.bo_oce_opetipo x
         WHERE       x.ope_numerodoc = codtran
                 AND x.tip_tipooperador IN ('TRN', 'TRE', 'NAL')
                 AND x.tip_num = 0
                 AND x.tip_lst_ope = 'U';

        /*SELECT   COUNT (1) into hay
    FROM   ops$asy.bo_oce_opetipo ot
   WHERE       ot.tip_tipooperador  in ('TRN', 'TRE', 'NAL')
           AND ot.ope_numerodoc = codtran
           AND ot.tip_estado = 'H'
           AND (ot.ope_numerodoc, ot.tip_tipooperador) NOT IN
                      (SELECT   oa.ope_numerodoc, oa.tip_tipooperador
                         FROM   ops$asy.bo_oce_aduana oa
                        WHERE   oa.adu_estado = 'H' AND oa.adu_num = 0);*/

        IF hay = 0 AND SYSDATE < v_fecha_corte
        THEN
            SELECT   NVL (b.ope_nit, 0)
              INTO   id
              FROM   operador.olopetip a, operador.olopetab b
             WHERE       a.emp_cod = b.emp_cod
                     AND a.ope_tip IN ('TRN', 'TRE', 'NAL')
                     AND a.tbl_sta = 'H'
                     AND a.cuo_cod = 'S/R'
                     AND a.ult_ver = 0
                     AND b.ult_ver = 0
                     AND b.ope_nit = codtran;
        ELSE
            SELECT   NVL (ot.ope_numerodoc, 0)
              INTO   id
              FROM   ops$asy.bo_oce_opetipo ot
             WHERE       ot.tip_tipooperador IN ('TRN', 'TRE', 'NAL')
                     AND ot.ope_numerodoc = codtran
                     AND ot.tip_estado = 'H'
                     AND ot.tip_num = 0;
        END IF;


        -- Padron
        /*SELECT resolucion_codigo
          INTO ID
          FROM padron.pad_operador a
         WHERE resolucion_codigo = codtran
           AND top_cod_ope IN ('TRA', 'NAL')
           AND ope_estado = 'H';*/
        RETURN id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0;
    END;

    -- Verificamos si el medio esta habilitado como medio de transporte
    FUNCTION verifica_medio_habilitada (id IN VARCHAR2, placa12 IN VARCHAR2)
        RETURN DECIMAL
    IS
        cantidad   DECIMAL (3, 0);
        hay        DECIMAL (3, 0);
    BEGIN
        /*
            -- operador
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   operador.oope_trp a, operador.oltratab b
             WHERE       a.trp_cod = b.trp_cod
                     AND a.ope_tip IN ('TRN', 'TRE', 'NAL')
                     AND a.ult_ver = 0
                     AND b.trp_cls = 'VEH'
                     AND b.ult_ver = 0
                     --AND TRUNC (SYSDATE) BETWEEN a.fch_ini AND  NVL (a.fch_fin, TRUNC (SYSDATE))
                     AND a.emp_cod = id
                     AND b.nro_placa = placa12
                     AND a.tbl_sta = 'H';*/


        --Modificado Edgar 27112014 Nuevo OCE   QUERY 4
        --cambiar la logica del id por el de ope_numerodoc = id2

        SELECT   COUNT (1)
          INTO   hay
          FROM   ops$asy.bo_oce_opetipo x
         WHERE       x.ope_numerodoc = id
                 AND x.tip_tipooperador IN ('TRN', 'TRE', 'NAL')
                 AND x.tip_num = 0
                 AND x.tip_lst_ope = 'U';

        /*
         SELECT   COUNT (1) into hay
           FROM   ops$asy.bo_oce_opetipo ot, ops$asy.bo_oce_placa op, ops$asy.bo_oce_tarope ta
          WHERE       ot.tip_tipooperador = ta.tip_tipooperador
                  AND ot.ope_numerodoc = ta.ope_numerodoc
                  AND ta.tar_num = 0
                  and ta.pla_nro_placa = op.pla_nro_placa
                  and ot.tip_tipooperador in ('TRN', 'TRE', 'NAL')
                  AND ot.ope_numerodoc = id
                  AND ot.tip_estado = 'H'
                  AND ot.tip_num = 0
                  AND ta.tar_estado = 'H'
                  and op.pla_tipo = 'VEH'
                  AND op.pla_num = 0
                  AND op.pla_nro_placa = placa12;*/

        IF hay = 0 AND SYSDATE < v_fecha_corte
        THEN
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   operador.olopetab a2,
                     operador.olopetip e2,
                     operador.oope_trp a,
                     operador.oltratab b
             WHERE       a2.ult_ver = 0
                     AND a2.ope_nit = id
                     AND a2.emp_cod = e2.emp_cod
                     AND a2.ult_ver = e2.ult_ver
                     AND a2.ult_ver = 0
                     AND e2.emp_cod = a.emp_cod
                     AND e2.ope_tip = a.ope_tip
                     AND e2.ult_ver = a.ult_ver
                     AND a.trp_cod = b.trp_cod
                     AND a.ope_tip IN ('TRN', 'TRE', 'NAL')
                     AND a.ult_ver = 0
                     AND b.trp_cls IN ('VEH','TRAC')
                     AND b.ult_ver = 0
                     --AND a.emp_cod = ''
                     AND b.nro_placa = placa12
                     AND a.tbl_sta = 'H';
        ELSE
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   ops$asy.bo_oce_opetipo ot,
                     ops$asy.bo_oce_placa op,
                     ops$asy.bo_oce_tarope ta
             WHERE       ot.tip_tipooperador = ta.tip_tipooperador
                     AND ot.ope_numerodoc = ta.ope_numerodoc
                     AND ta.tar_num = 0
                     AND ta.pla_nro_placa = op.pla_nro_placa
                     AND ot.tip_tipooperador IN ('TRN', 'TRE', 'NAL')
                     AND ot.ope_numerodoc = id
                     AND ot.tip_estado = 'H'
                     AND ot.tip_num = 0
                     AND ta.tar_estado = 'H'
                     AND op.pla_tipo IN ('VEH','TRAC')
                     AND op.pla_num = 0
                     AND op.pla_nro_placa = placa12;
        END IF;


        -- padron
        /*SELECT COUNT (1)
          INTO cantidad
          FROM padron.pad_parque_auto a, padron.pad_unidad b
         WHERE a.tipo_uni = b.tipo_uni
           AND a.placa = b.placa
           AND a.tipo_uni = 'VEH'
           AND a.placa = placa12
           AND a.resolucion_codigo = ID
           AND a.estado = 'A'
           AND b.estado = 'G';*/
        RETURN cantidad;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0;
    END;

    -- verifica que no sea ciclico el cierre
    FUNCTION no_ciclico_transbordo (keycuo    IN VARCHAR2,
                                    gestion   IN VARCHAR2,
                                    serial    IN DECIMAL,
                                    aduana    IN VARCHAR2)
        RETURN BOOLEAN
    IS
        cantidad   DECIMAL (3, 0) := 0;
    BEGIN
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND tra_num = 0
                 AND lst_ope = 'U'
                 AND tra_cuo_est = aduana
                 AND tra_cuo_des IS NULL;

        IF (cantidad > 0)
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    FUNCTION busca_precintos (keycuo     IN     VARCHAR2,
                              gestion    IN     VARCHAR2,
                              serial     IN     DECIMAL,
                              pre_emic      OUT VARCHAR2)
        RETURN VARCHAR2
    IS
        precinto    VARCHAR2 (200);
        v_cuo       VARCHAR2 (4);
        v_voynber   VARCHAR2 (50);
        v_depdate   VARCHAR2 (50);
    BEGIN
        DECLARE
            CURSOR fp
            IS
                SELECT   DISTINCT
                         b.carbol_seal_mrks1
                         || CASE
                                WHEN b.carbol_seal_mrks2 IS NULL THEN NULL
                                ELSE ' ' || b.carbol_seal_mrks2
                            END
                             AS dsc
                  FROM   car_gen a, car_bol_gen b
                 WHERE       a.key_cuo = b.key_cuo
                         AND a.key_dep_date = b.key_dep_date
                         AND a.key_voy_nber = b.key_voy_nber
                         AND a.key_cuo = keycuo
                         AND a.car_reg_year = gestion
                         AND a.car_reg_nber = serial;
        BEGIN
            FOR rs IN fp
            LOOP
                precinto := precinto || rs.dsc || ';';
            END LOOP;
        END;

        -- Precintos EMIC
        BEGIN
            SELECT   DISTINCT
                     cg.key_cuo,
                     cg.key_voy_nber,
                     TO_CHAR (cg.key_dep_date, 'dd/mm/yyyy')
              INTO   v_cuo, v_voynber, v_depdate
              FROM   ops$asy.car_gen cg, ops$asy.car_bol_gen cb
             WHERE       cb.key_cuo = cg.key_cuo
                     AND cb.key_voy_nber = cg.key_voy_nber
                     AND cb.key_dep_date = cg.key_dep_date
                     AND cg.key_cuo = keycuo
                     AND cg.car_reg_year = gestion
                     AND cg.car_reg_nber = serial
                     AND cb.carbol_nat_cod = '24'
                     AND NOT cb.carbol_frt_prep IS NULL
                     AND NOT cb.key_bol_ref IN
                                     (SELECT   key_bol_ref
                                        FROM   ops$asy.car_spy
                                       WHERE   key_cuo = cb.key_cuo
                                               AND key_voy_nber =
                                                      cb.key_voy_nber
                                               AND key_dep_date =
                                                      cb.key_dep_date
                                               AND spy_sta = 11);

            DECLARE
                CURSOR premicur
                IS
                    SELECT   DISTINCT a.mic_precinto
                      FROM   car_mic a
                     WHERE       a.mic_nregistro = v_voynber
                             AND a.mic_aduana = v_cuo
                             AND a.mic_gestion = v_depdate
                             AND a.mic_num = 0
                             AND a.lst_ope = 'U';
            BEGIN
                FOR rse IN premicur
                LOOP
                    pre_emic := pre_emic || rse.mic_precinto || ' ';
                END LOOP;

                IF LENGTH (pre_emic) > 100
                THEN
                    pre_emic := SUBSTR (pre_emic, 1, 100);
                END IF;
            END;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                pre_emic := NULL;
        END;

        RETURN precinto;
    END;

    -- versiona el transito
    FUNCTION versiona_transito (keycuo    IN VARCHAR2,
                                gestion   IN VARCHAR2,
                                serial    IN DECIMAL)
        RETURN NUMBER
    IS
        version   NUMBER (3) := 0;
    BEGIN
        SELECT   MAX (tra_num)
          INTO   version
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial;

        UPDATE   tra_pla_rut
           SET   tra_num = version + 1
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND key_secuencia > 0
                 AND tra_num = 0;

        RETURN (version + 1);
    END;

    -- borra cualquier caracter excepto letra o numero
    FUNCTION letras_numeros (texto IN VARCHAR2)
        RETURN VARCHAR2
    IS
        ans     VARCHAR2 (255);
        lon     NUMBER (3, 0) := 0;
        letra   VARCHAR2 (1) := 0;
    BEGIN
        lon := LENGTH (texto);

        FOR j IN 1 .. lon
        LOOP
            letra := SUBSTR (texto, j, 1);     --ASCII (SUBSTR (texto, j, 1));

            IF (   (letra BETWEEN 'A' AND 'Z')
                OR (letra = CHR (165))
                OR (letra BETWEEN '0' AND '9')
                OR (letra = CHR (32)))
            THEN
                ans := ans || letra;
            ELSE
                ans := ans || ' ';
            END IF;
        END LOOP;

        RETURN ans;
    END;

    /**************************************
    *   Verificamos la etapa del transito *
    **************************************/
    FUNCTION verfica_transito (keycuo     IN     VARCHAR2,
                               gestion    IN     VARCHAR2,
                               serial     IN     DECIMAL,
                               aduana     IN     VARCHAR2,
                               usuario    IN     VARCHAR2,
                               etapa      IN     DECIMAL,
                               sboleta       OUT DECIMAL,
                               stna          OUT DECIMAL,
                               cabecera      OUT cursortype,
                               item          OUT cursortype)
        RETURN DECIMAL
    IS
        empresa     VARCHAR2 (15);
        placa       VARCHAR2 (10);
        inicio      DECIMAL (3, 0) := 0;
        pendiente   DECIMAL (3, 0) := 0;
    BEGIN
        sboleta := bnoexiste;
        stna := bnoexiste;

        IF (etapa = binicio)
        THEN
            inicio :=
                pkg_verifica_transito.finicio (keycuo,
                                               gestion,
                                               serial,
                                               aduana,
                                               sboleta);

            IF (inicio = mt_boleta_garantia)
            THEN
                inicio := mt_correcto;
            END IF;

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bmodificacion)            -- IN (bmodificacion, bpaso))
        THEN
            inicio :=
                pkg_verifica_transito.freasignacion (keycuo,
                                                     gestion,
                                                     serial,
                                                     aduana,
                                                     sboleta);

            IF (inicio = mt_boleta_garantia)
            THEN
                inicio := mt_correcto;
            END IF;

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bpaso)
        THEN
            inicio :=
                pkg_verifica_transito.faduana_paso (keycuo,
                                                    gestion,
                                                    serial,
                                                    aduana);

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bptoctl)
        THEN
            inicio :=
                pkg_verifica_transito.faduana_ptoctl (keycuo,
                                                      gestion,
                                                      serial,
                                                      aduana);

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bfinalizacion)
        THEN
            inicio :=
                pkg_verifica_transito.ffinalizacion (keycuo, gestion, serial);

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = btransbordoferreo)
        THEN
            inicio :=
                pkg_verifica_transito.ffinalizacion (keycuo, gestion, serial);

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bcancelacion)
        THEN
            inicio :=
                pkg_verifica_transito.fcancelacion (keycuo,
                                                    gestion,
                                                    serial,
                                                    aduana);

            IF (inicio = mt_correcto)
            THEN
                IF (borra_transito (keycuo,
                                    gestion,
                                    serial,
                                    usuario) = 'Correcto')
                THEN
                    RETURN mt_correcto;
                ELSE
                    RETURN mt_error;
                END IF;
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = betiqueta)
        THEN
            inicio :=
                pkg_verifica_transito.fetiqueta (keycuo,
                                                 gestion,
                                                 serial,
                                                 aduana);

            RETURN inicio;
        ELSIF (etapa = bsalidapuerto OR etapa = blistasalidapuerto)
        THEN
            inicio :=
                pkg_verifica_transito.fplazoetiqueta (keycuo,
                                                      gestion,
                                                      serial,
                                                      aduana,
                                                      etapa);

            RETURN inicio;
        ELSE
            RETURN mt_error;
        END IF;

        RETURN mt_correcto;
    END;

    FUNCTION verfica_transito_dep (keycuo     IN     VARCHAR2,
                                   gestion    IN     VARCHAR2,
                                   serial     IN     DECIMAL,
                                   aduana     IN     VARCHAR2,
                                   usuario    IN     VARCHAR2,
                                   etapa      IN     DECIMAL,
                                   sboleta       OUT DECIMAL,
                                   stna          OUT DECIMAL,
                                   cabecera      OUT cursortype,
                                   item          OUT cursortype)
        RETURN DECIMAL
    IS
        empresa     VARCHAR2 (15);
        placa       VARCHAR2 (10);
        inicio      DECIMAL (3, 0) := 0;
        pendiente   DECIMAL (3, 0) := 0;
    BEGIN
        sboleta := bnoexiste;
        stna := bnoexiste;

        IF (etapa = binicio)
        THEN
            inicio :=
                pkg_verifica_transito.finicio (keycuo,
                                               gestion,
                                               serial,
                                               aduana,
                                               sboleta);

            IF (inicio = mt_boleta_garantia)
            THEN
                inicio := mt_correcto;
            END IF;

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bmodificacion)            -- IN (bmodificacion, bpaso))
        THEN
            inicio :=
                pkg_verifica_transito.freasignacion (keycuo,
                                                     gestion,
                                                     serial,
                                                     aduana,
                                                     sboleta);

            IF (inicio = mt_boleta_garantia)
            THEN
                inicio := mt_correcto;
            END IF;

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bpaso)
        THEN
            inicio :=
                pkg_verifica_transito.faduana_paso (keycuo,
                                                    gestion,
                                                    serial,
                                                    aduana);

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bptoctl)
        THEN
            inicio :=
                pkg_verifica_transito.faduana_ptoctl (keycuo,
                                                      gestion,
                                                      serial,
                                                      aduana);

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bfinalizacion)
        THEN
            inicio :=
                pkg_verifica_transito.ffinalizacion_dep (keycuo,
                                                         gestion,
                                                         serial);

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = btransbordoferreo)
        THEN
            inicio :=
                pkg_verifica_transito.ffinalizacion (keycuo, gestion, serial);

            IF (inicio = mt_correcto)
            THEN
                consulta_transito (keycuo,
                                   gestion,
                                   serial,
                                   etapa,
                                   cabecera,
                                   item);
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = bcancelacion)
        THEN
            inicio :=
                pkg_verifica_transito.fcancelacion (keycuo,
                                                    gestion,
                                                    serial,
                                                    aduana);

            IF (inicio = mt_correcto)
            THEN
                IF (borra_transito (keycuo,
                                    gestion,
                                    serial,
                                    usuario) = 'Correcto')
                THEN
                    RETURN mt_correcto;
                ELSE
                    RETURN mt_error;
                END IF;
            ELSE
                RETURN inicio;
            END IF;
        ELSIF (etapa = betiqueta)
        THEN
            inicio :=
                pkg_verifica_transito.fetiqueta (keycuo,
                                                 gestion,
                                                 serial,
                                                 aduana);

            RETURN inicio;
        ELSIF (etapa = bsalidapuerto OR etapa = blistasalidapuerto)
        THEN
            inicio :=
                pkg_verifica_transito.fplazoetiqueta (keycuo,
                                                      gestion,
                                                      serial,
                                                      aduana,
                                                      etapa);

            RETURN inicio;
        ELSE
            RETURN mt_error;
        END IF;

        RETURN mt_correcto;
    END;


    /*****************************************************************
       recuperamos el manifiesto o el transito
    ******************************************************************/
    PROCEDURE consulta_transito (keycuo     IN     VARCHAR2,
                                 gestion    IN     VARCHAR2,
                                 serial     IN     DECIMAL,
                                 etapa      IN     DECIMAL,
                                 cabecera      OUT cursortype,
                                 item          OUT cursortype)
    IS
        cantidad    DECIMAL (3, 0);
        viaje       VARCHAR2 (15);
        fecreg      DATE;
        ecantidad   PLS_INTEGER;
        emax        PLS_INTEGER;
        fmax        VARCHAR2 (50);
        precinto    VARCHAR2 (200);
        pre_emic    VARCHAR2 (500);
    BEGIN
        precinto :=
            busca_precintos (keycuo,
                             gestion,
                             serial,
                             pre_emic);

        IF (etapa = binicio)
        THEN
            OPEN cabecera FOR
                  SELECT   DISTINCT
                           cg.car_car_cod,
                           cg.car_car_nam,
                           cg.car_id_trp,
                           cb.carbol_frt_prep AS tra_cuo_ini,
                           uct.cuo_nam AS tra_dsc_ini,
                           cg.car_mot_cod,
                           TO_CHAR (SYSDATE, 'dd/mm/yyyy') fechaact,
                           TO_CHAR (SYSDATE, 'hh24:MI') horact,
                           TO_CHAR (SYSDATE + 1, 'yyyymmddhh24mi') AS actual,
                              TO_CHAR (cg.car_reg_date, 'yyyymmdd')
                           || SUBSTR (cg.car_reg_time, 1, 2)
                           || SUBSTR (cg.car_reg_time, 4, 2)
                               registro,
                           precinto AS precinto,
                           pre_emic AS pre_emic
                    FROM   ops$asy.car_bol_gen cb,
                           ops$asy.car_gen cg,
                           ops$asy.uncuotab uct
                   WHERE       cb.key_cuo = cg.key_cuo
                           AND cb.key_voy_nber = cg.key_voy_nber
                           AND cb.key_dep_date = cg.key_dep_date
                           AND uct.cuo_cod = cb.carbol_frt_prep
                           AND uct.lst_ope = 'U'
                           AND cg.key_cuo = keycuo
                           AND cg.car_reg_year = gestion
                           AND cg.car_reg_nber = serial
                           AND cb.carbol_nat_cod = '24'
                           AND NOT cb.carbol_frt_prep IS NULL
                           AND NOT cb.key_bol_ref IN
                                           (SELECT   key_bol_ref
                                              FROM   ops$asy.car_spy
                                             WHERE   key_cuo = cb.key_cuo
                                                     AND key_voy_nber =
                                                            cb.key_voy_nber
                                                     AND key_dep_date =
                                                            cb.key_dep_date
                                                     AND spy_sta = 11)
                ORDER BY   carbol_frt_prep DESC;

            OPEN item FOR SELECT   SYSDATE FROM DUAL;
        ELSIF (etapa IN (bmodificacion, bmod_manifiesto, bpaso, bptoctl))
        THEN
            SELECT   MAX (tra_fec_des)
              INTO   fecreg
              FROM   tra_pla_rut a
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia > 0
                     AND tra_num = 0
                     --AND lst_ope = 'U';
                     --edgar 04092014
                     AND lst_ope IN ('U', 'M');

            IF (fecreg IS NULL)
            THEN
                SELECT   tra_fec_ini
                  INTO   fecreg
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND key_secuencia > 0
                         AND tra_estado = 0
                         AND tra_num = 0
                         --AND lst_ope = 'U';
                         --edgar 04092014
                         AND lst_ope IN ('U', 'M');
            END IF;

            OPEN cabecera FOR
                SELECT   cg.car_car_cod,
                         cg.car_car_nam,
                         cg.car_id_trp,
                         cg.car_mot_cod,
                         TO_CHAR (SYSDATE, 'dd/mm/yyyy') AS fechaact,
                         TO_CHAR (SYSDATE, 'hh24:mi') AS horact,
                         a.tra_pre,
                         a.act_boleta,
                         a.act_entidad,
                         TO_CHAR (a.act_fec_ini, 'dd/mm/yyyy') AS act_fec_ini,
                         TO_CHAR (a.act_fec_fin, 'dd/mm/yyyy') AS act_fec_fin,
                         a.act_monto,
                         a.act_moneda,
                         tra_obs AS obs,
                         TO_CHAR (SYSDATE + 1, 'yyyymmddhh24mi') AS actual,
                         TO_CHAR (fecreg, 'yyyymmddhh24mi') registro,
                         precinto AS precinto
                  FROM   tra_pla_rut a, ops$asy.car_gen cg
                 WHERE       a.key_cuo = cg.key_cuo
                         AND a.car_reg_year = cg.car_reg_year
                         AND a.car_reg_nber = cg.car_reg_nber
                         AND a.tra_num = 0
                         --AND a.lst_ope = 'U'
                         --edgar 04092014
                         AND a.lst_ope IN ('U', 'M')
                         AND cg.key_cuo = keycuo
                         AND cg.car_reg_year = gestion
                         AND cg.car_reg_nber = serial
                         AND a.tra_estado = 0;

            OPEN item FOR
                SELECT   b.key_secuencia,
                         DECODE (tra_cuo_est, NULL, cuo_est, tra_cuo_est)
                             AS tra_cuo_est,
                         z.cuo_nam AS tra_dsc_est,
                         TO_CHAR (tra_fec_des, 'dd/mm/yyyy') AS fecdes,
                         TO_CHAR (tra_fec_des, 'HH24:MI') AS hordes,
                         z.cuo_acc
                  FROM   (SELECT   DISTINCT cb.carbol_frt_prep AS cuo_est
                            FROM   ops$asy.car_bol_gen cb,
                                   ops$asy.car_gen cg,
                                   ops$asy.uncuotab uct
                           WHERE       cb.key_cuo = cg.key_cuo
                                   AND cb.key_voy_nber = cg.key_voy_nber
                                   AND cb.key_dep_date = cg.key_dep_date
                                   AND uct.cuo_cod = cb.carbol_frt_prep
                                   AND uct.lst_ope = 'U'
                                   AND cg.key_cuo = keycuo
                                   AND cg.car_reg_year = gestion
                                   AND cg.car_reg_nber = serial
                                   AND cb.carbol_nat_cod = '24'
                                   AND NOT cb.carbol_frt_prep IS NULL
                                   AND NOT cb.key_bol_ref IN
                                                   (SELECT   key_bol_ref
                                                      FROM   ops$asy.car_spy
                                                     WHERE   key_cuo =
                                                                 cb.key_cuo
                                                             AND key_voy_nber =
                                                                    cb.key_voy_nber
                                                             AND key_dep_date =
                                                                    cb.key_dep_date
                                                             AND spy_sta = 11))
                         a,
                         tra_pla_rut b,
                         ops$asy.uncuotab z
                 WHERE       a.cuo_est = b.tra_cuo_est(+)
                         AND b.key_cuo(+) = keycuo
                         AND b.car_reg_year(+) = gestion
                         AND b.car_reg_nber(+) = serial
                         AND tra_num(+) = 0
                         AND DECODE (tra_cuo_est, NULL, cuo_est, tra_cuo_est) =
                                z.cuo_cod
                         AND z.lst_ope = 'U'
                UNION
                SELECT   b.key_secuencia,
                         tra_cuo_est,
                         z.cuo_nam AS tra_dsc_est,
                         TO_CHAR (tra_fec_des, 'dd/mm/yyyy') AS fecdes,
                         TO_CHAR (tra_fec_des, 'HH24:MI') AS hordes,
                         z.cuo_acc
                  FROM   tra_pla_rut b, ops$asy.uncuotab z
                 WHERE       b.key_cuo = keycuo
                         AND b.car_reg_year = gestion
                         AND b.car_reg_nber = serial
                         AND b.key_secuencia > 0
                         AND b.tra_num = 0
                         AND tra_cuo_est = z.cuo_cod
                         AND z.lst_ope = 'U'
                         --AND b.lst_ope = 'U'
                         --edgar 04092014
                         AND b.lst_ope IN ('U', 'M')
                         AND NOT tra_cuo_des IS NULL;
        ELSIF (etapa = bfinalizacion)
        THEN
            OPEN cabecera FOR
                SELECT   cg.car_car_cod,
                         letras_numeros (cg.car_car_nam) AS car_car_nam,
                         cg.car_id_trp,
                         NVL (a.tra_pre, ' ') AS tra_pre,
                         DECODE (
                             a.act_boleta,
                             NULL,
                             NULL,
                                'Boleta de Garantia, Nro.: '
                             || a.act_boleta
                             || ' por '
                             || TO_CHAR (a.act_monto, '999,990.00')
                             || ' '
                             || a.act_moneda
                             || ' Vigencia: '
                             || TO_CHAR (a.act_fec_ini, 'dd/mm/yyyy')
                             || ' a '
                             || TO_CHAR (a.act_fec_fin, 'dd/mm/yyyy'))
                             AS boleta,
                         tra_obs AS obs,
                         TO_CHAR (SYSDATE + (1 / 48), 'yyyymmddhh24mi')
                             AS actual,
                         TO_CHAR (a.tra_fec_est, 'yyyymmddhh24mi')
                             AS estimada,
                         TO_CHAR (a.tra_fec_ini, 'yyyymmddhh24mi') AS partida,
                         TO_CHAR (NVL (mod_peso, 0), '999,990.00') AS peso,
                         key_secuencia,
                         CASE NVL (t.key_cuo, '-') WHEN '-' THEN 0 ELSE 1 END
                             AS key_paso,
                         precinto AS precinto,
                         TO_CHAR (NVL (mic.mic_peso, 0), '999,990.00')
                             AS peso_salida
                  FROM   tra_pla_rut a,
                         ops$asy.car_gen cg,
                         t_modpeso t,
                         tra_micanticipado mic
                 WHERE       cg.key_cuo = a.key_cuo
                         AND cg.car_reg_year = a.car_reg_year
                         AND cg.car_reg_nber = a.car_reg_nber
                         AND a.key_cuo = keycuo
                         AND a.car_reg_year = gestion
                         AND a.car_reg_nber = serial
                         AND a.tra_estado = 0
                         AND a.tra_num = 0
                         --AND a.lst_ope = 'U'
                         --edgar 04092014
                         AND a.lst_ope IN ('U', 'M')
                         AND t.key_cuo(+) = a.key_cuo
                         AND t.car_reg_year(+) = a.car_reg_year
                         AND t.car_reg_nber(+) = a.car_reg_nber
                         AND t.mod_num(+) = 0
                         AND t.mod_lst_ope(+) = 'U'
                         AND mic.key_cuo(+) = a.key_cuo
                         AND mic.car_reg_year(+) = a.car_reg_year
                         AND mic.car_reg_nber(+) = a.car_reg_nber
                         AND mic.mic_num(+) = 0
                         AND mic.mic_lst_ope(+) = 'U';

            OPEN item FOR
                  SELECT   a.key_secuencia,
                           a.tra_cuo_ini,
                           ct1.cuo_nam AS tra_dsc_ini,
                           TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_ini,
                           a.tra_cuo_est,
                           ct2.cuo_nam AS tra_dsc_est,
                           TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_est,
                           a.tra_estado,
                           a.tra_cuo_des,
                           ct3.cuo_nam AS tra_dsc_des,
                           TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_des,
                           TO_CHAR (SYSDATE, 'dd/mm/yyyy') AS fechaact,
                           TO_CHAR (SYSDATE, 'hh24:mi') AS horact,
                           ct1.cuo_acc
                    FROM   tra_pla_rut a,
                           ops$asy.uncuotab ct1,
                           ops$asy.uncuotab ct2,
                           ops$asy.uncuotab ct3
                   WHERE       ct1.cuo_cod = a.tra_cuo_ini
                           AND ct2.cuo_cod = a.tra_cuo_est
                           AND ct3.cuo_cod(+) = a.tra_cuo_des
                           AND a.tra_num = 0
                           --AND a.lst_ope = 'U'
                           --edgar 04092014
                           AND a.lst_ope IN ('U', 'M')
                           AND ct1.lst_ope = 'U'
                           AND ct2.lst_ope = 'U'
                           AND ct3.lst_ope(+) = 'U'
                           AND a.key_cuo = keycuo
                           AND a.car_reg_year = gestion
                           AND a.car_reg_nber = serial
                           AND a.key_secuencia > 0
                ORDER BY   key_secuencia;
        ELSIF (etapa = btransbordoferreo)
        THEN
            OPEN cabecera FOR
                SELECT   cg.car_car_cod,
                         letras_numeros (cg.car_car_nam) AS car_car_nam,
                         cg.car_id_trp,
                         NVL (a.tra_pre, ' ') AS tra_pre,
                         DECODE (
                             a.act_boleta,
                             NULL,
                             NULL,
                                'Boleta de Garantia, Nro.: '
                             || a.act_boleta
                             || ' por '
                             || TO_CHAR (a.act_monto, '999,990.00')
                             || ' '
                             || a.act_moneda
                             || ' Vigencia: '
                             || TO_CHAR (a.act_fec_ini, 'dd/mm/yyyy')
                             || ' a '
                             || TO_CHAR (a.act_fec_fin, 'dd/mm/yyyy'))
                             AS boleta,
                         tra_obs AS obs,
                         TO_CHAR (SYSDATE + (1 / 48), 'yyyymmddhh24mi')
                             AS actual,
                         TO_CHAR (a.tra_fec_est, 'yyyymmddhh24mi')
                             AS estimada,
                         TO_CHAR (a.tra_fec_ini, 'yyyymmddhh24mi') AS partida,
                         TO_CHAR (NVL (mod_peso, 0), '999,990.00') AS peso,
                         key_secuencia,
                         CASE NVL (t.key_cuo, '-') WHEN '-' THEN 0 ELSE 1 END
                             AS key_paso,
                         precinto AS precinto,
                         TO_CHAR (NVL (mic.mic_peso, 0), '999,990.00')
                             AS peso_salida
                  FROM   tra_pla_rut a,
                         ops$asy.car_gen cg,
                         t_modpeso t,
                         tra_micanticipado mic
                 WHERE       cg.key_cuo = a.key_cuo
                         AND cg.car_reg_year = a.car_reg_year
                         AND cg.car_reg_nber = a.car_reg_nber
                         AND a.key_cuo = keycuo
                         AND a.car_reg_year = gestion
                         AND a.car_reg_nber = serial
                         AND a.tra_estado = 0
                         AND a.tra_num = 0
                         --AND a.lst_ope = 'U'
                         --edgar 04092014
                         AND a.lst_ope IN ('U', 'M')
                         AND t.key_cuo(+) = a.key_cuo
                         AND t.car_reg_year(+) = a.car_reg_year
                         AND t.car_reg_nber(+) = a.car_reg_nber
                         AND t.mod_num(+) = 0
                         AND t.mod_lst_ope(+) = 'U'
                         AND mic.key_cuo(+) = a.key_cuo
                         AND mic.car_reg_year(+) = a.car_reg_year
                         AND mic.car_reg_nber(+) = a.car_reg_nber
                         AND mic.mic_num(+) = 0
                         AND mic.mic_lst_ope(+) = 'U';

            OPEN item FOR
                  SELECT   a.key_secuencia,
                           a.tra_cuo_ini,
                           ct1.cuo_nam AS tra_dsc_ini,
                           TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_ini,
                           a.tra_cuo_est,
                           ct2.cuo_nam AS tra_dsc_est,
                           TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_est,
                           a.tra_estado,
                           a.tra_cuo_des,
                           ct3.cuo_nam AS tra_dsc_des,
                           TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_des,
                           TO_CHAR (SYSDATE, 'dd/mm/yyyy') AS fechaact,
                           TO_CHAR (SYSDATE, 'hh24:mi') AS horact,
                           ct1.cuo_acc
                    FROM   tra_pla_rut a,
                           ops$asy.uncuotab ct1,
                           ops$asy.uncuotab ct2,
                           ops$asy.uncuotab ct3
                   WHERE       ct1.cuo_cod = a.tra_cuo_ini
                           AND ct2.cuo_cod = a.tra_cuo_est
                           AND ct3.cuo_cod(+) = a.tra_cuo_des
                           AND a.tra_num = 0
                           --AND a.lst_ope = 'U'
                           --edgar 04092014
                           AND a.lst_ope IN ('U', 'M')
                           AND ct1.lst_ope = 'U'
                           AND ct2.lst_ope = 'U'
                           AND ct3.lst_ope(+) = 'U'
                           AND a.key_cuo = keycuo
                           AND a.car_reg_year = gestion
                           AND a.car_reg_nber = serial
                           AND a.key_secuencia > 0
                ORDER BY   key_secuencia;
        ELSE
            BEGIN
                SELECT   key_secuencia
                  INTO   cantidad
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND tra_num = 0
                         AND tra_estado = 0;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    SELECT   MAX (key_secuencia)
                      INTO   cantidad
                      FROM   tra_pla_rut
                     WHERE       key_cuo = keycuo
                             AND car_reg_year = gestion
                             AND car_reg_nber = serial
                             AND tra_num = 0;
            END;

            SELECT   COUNT (1),
                     MAX (tra_secuencia),
                     TO_CHAR (MAX (tra_fecha), 'dd/mm/yyyy hh24:mi')
              INTO   ecantidad, emax, fmax
              FROM   tra_etiqueta
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_version = 0;

            OPEN cabecera FOR
                SELECT   cg.car_car_cod,
                         cg.car_car_nam,
                         cg.car_id_trp,
                         NVL (a.tra_pre, ' ') AS tra_pre,
                         cg.car_mot_cod,
                         DECODE (
                             a.act_boleta,
                             NULL,
                             NULL,
                                'Boleta de Garantia, Nro.: '
                             || a.act_boleta
                             || ' por '
                             || TO_CHAR (a.act_monto, '999,990.00')
                             || ' '
                             || a.act_moneda)
                             AS boleta,
                         a.usr_nam,
                         TO_CHAR (a.usr_fec, 'dd/mm/yyyy HH24:MI') AS usr_fec,
                         ecantidad AS eticant,
                         emax AS etimax,
                         fmax AS fmax,
                         precinto AS precinto,
                         a.lst_ope AS estado_tran
                  FROM   tra_pla_rut a, ops$asy.car_gen cg
                 WHERE       cg.key_cuo = a.key_cuo
                         AND cg.car_reg_year = a.car_reg_year
                         AND cg.car_reg_nber = a.car_reg_nber
                         AND a.tra_num = 0
                         --AND A.LST_OPE = DECODE(SUBSTR(KEYCUO,0,1),'0',decode(tiene_salida_puerto(KEYCUO,GESTION,SERIAL,1),0,'M','U'),'U')  -- MODIFICACION PARA SALIDA DE PUERTO 04062014
                         AND a.lst_ope IN ('M', 'U')
                         AND a.key_secuencia = cantidad
                         AND a.key_cuo = keycuo
                         AND a.car_reg_year = gestion
                         AND a.car_reg_nber = serial;

            OPEN item FOR
                  SELECT   a.key_secuencia,
                           a.tra_cuo_ini,
                           ct1.cuo_nam AS tra_dsc_ini,
                           TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_ini,
                           a.tra_cuo_est,
                           ct2.cuo_nam AS tra_dsc_est,
                           TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_est,
                           a.tra_estado,
                           a.tra_cuo_des,
                           ct3.cuo_nam AS tra_dsc_des,
                           TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:MI')
                               AS tra_fec_des,
                           a.tra_plazo,
                           DECODE (a.tra_tipo,
                                   23, 'Forzoso',
                                   24, 'Normal',
                                   28, 'Transbordo',
                                   31, 'Despacho Anticipado',
                                   '&nbsp;')
                               AS tra_tipo,
                           TRUNC (SYSDATE - NVL (a.tra_fec_des, a.tra_fec_est))
                               AS dias,
                           TRUNC( ( (SYSDATE
                                     - NVL (a.tra_fec_des, a.tra_fec_est))
                                   - TRUNC(SYSDATE
                                           - NVL (a.tra_fec_des, a.tra_fec_est)))
                                 * 24)
                               AS hora,
                           DECODE (a.tra_fec_des, NULL, 2, a.tra_loc) AS loc,
                           a.tra_obs,
                           ct1.cuo_acc,
                           tiene_acta (a.key_cuo,
                                       a.car_reg_year,
                                       a.car_reg_nber,
                                       a.key_secuencia)
                               acta
                    FROM   tra_pla_rut a,
                           ops$asy.uncuotab ct1,
                           ops$asy.uncuotab ct2,
                           ops$asy.uncuotab ct3
                   WHERE       ct1.cuo_cod = a.tra_cuo_ini
                           AND ct2.cuo_cod = a.tra_cuo_est
                           AND ct3.cuo_cod(+) = a.tra_cuo_des
                           AND a.tra_num = 0
                           --AND A.LST_OPE = DECODE(SUBSTR(KEYCUO,0,1),'0',decode(tiene_salida_puerto(KEYCUO,GESTION,SERIAL,1),0,'M','U'),'U')  -- MODIFICACION PARA SALIDA DE PUERTO 04062014
                           AND a.lst_ope IN ('M', 'U')
                           AND ct1.lst_ope = 'U'
                           AND ct2.lst_ope = 'U'
                           AND ct3.lst_ope(+) = 'U'
                           AND a.key_cuo = keycuo
                           AND a.car_reg_year = gestion
                           AND a.car_reg_nber = serial
                ORDER BY   key_secuencia;
        END IF;
    END;

    /**************************************************************
    * Damos de baja un transito que no tiene ningun cierre        *
    * creamos un nuevo registro con lst_ope ='U', usuario y fecha *
    **************************************************************/
    FUNCTION borra_transito (keycuo    IN VARCHAR2,
                             gestion   IN VARCHAR2,
                             serial    IN DECIMAL,
                             usuario   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        imax      DECIMAL (3, 0) := 0;
        version   DECIMAL (3, 0) := 0;
    BEGIN
        -- versiona el transito
        version := versiona_transito (keycuo, gestion, serial);

        -- insertamos un nuevo registro
        INSERT INTO tra_pla_rut
            SELECT   key_cuo,
                     car_reg_year,
                     car_reg_nber,
                     key_secuencia,
                     tra_cuo_ini,
                     tra_fec_ini,
                     tra_cuo_est,
                     tra_fec_est,
                     tra_pre,
                     tra_plazo,
                     tra_ruta,
                     tra_cuo_des,
                     tra_fec_des,
                     tra_tipo,
                     tra_obs,
                     act_boleta,
                     act_entidad,
                     act_fec_ini,
                     act_fec_fin,
                     act_monto,
                     act_moneda,
                     tra_loc,
                     tra_estado,
                     'D',
                     0,
                     usuario,
                     SYSDATE
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = version;

        --Para registrar la placa del medio de transporte EJAG 16/11/2015
        placa_cierre (keycuo,
                      gestion,
                      serial,
                      0,
                      '0',
                      'CANCELACION');
        COMMIT;
        RETURN 'Correcto';
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    FUNCTION valida_verifdocs (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res       VARCHAR2 (100);
        existe    NUMBER;
        fec_reg   DATE;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   ops$asy.car_gen a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial
                 AND a.car_mot_cod IN (1, 2, 3, 8, 9);

        IF existe = 0
        THEN
            RETURN 'OK';
        END IF;


        SELECT   a.car_reg_date
          INTO   fec_reg
          FROM   ops$asy.car_gen a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial;

        IF (TRUNC (fec_reg) >= TRUNC (TO_DATE ('26/10/2016', 'dd/mm/yyyy')))
        THEN
            IF NOT keycuo IN ('071', '072')
            THEN
                --verificamos que tenga documentos digitalizados en el mira
                SELECT   COUNT (1)
                  INTO   existe
                  FROM   mira.ai_doc_man_cab a
                 WHERE       a.doc_reg_year = gestion
                         AND a.doc_key_cuo = keycuo
                         AND a.doc_reg_nber = serial
                         AND a.man_estado_man IN ('C')
                         AND a.doc_lst_ope = 'U'
                         AND a.doc_num = 0;
            ELSE
                --verificamos que tenga documentos digitalizados en el mira
                SELECT   COUNT (1)
                  INTO   existe
                  FROM   mira.ai_doc_man_cab a
                 WHERE       a.doc_reg_year = gestion
                         AND a.doc_key_cuo = keycuo
                         AND a.doc_reg_nber = serial
                         AND a.man_estado_man IN ('F', 'C')
                         AND a.doc_lst_ope = 'U'
                         AND a.doc_num = 0;
            END IF;

            IF existe = 0
            THEN
                RETURN 'FALTA CONFIRMACION REGISTRO DE MANIFIESTO';
            ELSE
                /*IF NOT keycuo IN ('071', '072')
                THEN
                    SELECT   COUNT (1)
                      INTO   existe
                      FROM   tra_imagenes a
                     WHERE       a.key_cuo = keycuo
                             AND a.car_reg_year = gestion
                             AND a.car_reg_nber = serial
                             AND a.lst_ope = 'U'
                             AND a.tim_num = 0;

                    IF existe = 0
                    THEN
                        RETURN 'DEBE DIGITALIZAR IMAGENES DEL MANIFIESTO';
                    ELSE
                        RETURN 'OK';
                    END IF;
                ELSE
                    RETURN 'OK';
                END IF;*/
                RETURN 'OK';
            END IF;
        ELSE
            RETURN 'OK';
        END IF;
    END valida_verifdocs;

    FUNCTION valida_verifdocs_spuerto (keycuo    IN VARCHAR2,
                                       gestion   IN VARCHAR2,
                                       serial    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res       VARCHAR2 (100);
        existe    NUMBER;
        fec_reg   DATE;
    BEGIN
        SELECT   COUNT (1)
          INTO   existe
          FROM   ops$asy.car_gen a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial
                 AND a.car_mot_cod IN (1, 2, 3, 8, 9);

        IF existe = 0
        THEN
            RETURN 'OK';
        END IF;

        SELECT   a.car_reg_date
          INTO   fec_reg
          FROM   ops$asy.car_gen a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial;

        IF (TRUNC (fec_reg) >= TRUNC (TO_DATE ('26/10/2016', 'dd/mm/yyyy')))
        THEN
            SELECT   COUNT (1)
              INTO   existe
              FROM   mira.ai_doc_man_cab a
             WHERE       a.doc_reg_year = gestion
                     AND a.doc_key_cuo = keycuo
                     AND a.doc_reg_nber = serial
                     AND a.man_estado_man IN ('C')
                     AND a.doc_lst_ope = 'U'
                     AND a.doc_num = 0;

            IF existe = 0
            THEN
                RETURN 'FALTA CONFIRMACION REGISTRO DE MANIFIESTO';
            ELSE
                /*SELECT   COUNT (1)
                  INTO   existe
                  FROM   tra_imagenes a
                 WHERE       a.key_cuo = keycuo
                         AND a.car_reg_year = gestion
                         AND a.car_reg_nber = serial
                         AND a.lst_ope = 'U'
                         AND a.tim_num = 0;

                IF existe = 0
                THEN
                    RETURN 'DEBE DIGITALIZAR IMAGENES DEL MANIFIESTO';
                ELSE*/
                    RETURN 'OK';
                /*END IF;*/
            END IF;
        ELSE
            RETURN 'OK';
        END IF;
    END valida_verifdocs_spuerto;


    FUNCTION valida_autorizacion2752 (keycuo    IN VARCHAR2,
                                      gestion   IN VARCHAR2,
                                      serial    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res      VARCHAR2 (100);
        existe   NUMBER;
    BEGIN
        --verificamos que tenga documentos digitalizados en el mira
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_aut_previa a, ops$asy.car_gen c
         WHERE       a.key_cuo = c.key_cuo
                 AND a.key_voy_nber = c.key_voy_nber
                 AND a.key_dep_date = c.key_dep_date
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND (a.apr_ds_autorizacion = 'DS2752'
                      OR a.apr_ds_autorizacion = 'DS2752CAN')
                 AND c.key_cuo = keycuo
                 AND c.car_reg_year = gestion
                 AND c.car_reg_nber = serial;

        IF existe = 0
        THEN
            RETURN 'OK';
        ELSE
            RETURN 'MERCANCIA DEL DS2752, SIN AUTORIZACION PREVIA';
        END IF;
    END valida_autorizacion2752;



    /***********************************************************
    * Grabamos la(s) ruta(s) y plazo(s)                        *
    * si ietapa = 9 => ya a conluido el transito y no grabamos *
    ***********************************************************/
    FUNCTION graba_ruta_plazo (keycuo     IN     VARCHAR2,
                               gestion    IN     VARCHAR2,
                               serial     IN     DECIMAL,
                               modtra     IN     DECIMAL, -- Modo de transporte
                               sfecpar    IN     VARCHAR2,
                               adupas     IN OUT VARCHAR2,
                               laduanas   IN     VARCHAR2,
                               pre_uno    IN     VARCHAR2,
                               obs        IN     VARCHAR2,
                               --para la boleta
                               boleta     IN     VARCHAR2,
                               entidad    IN     VARCHAR2,
                               fecini     IN     VARCHAR2,
                               fecfin     IN     VARCHAR2,
                               monto      IN     DECIMAL,
                               moneda     IN     VARCHAR2,
                               --el usuario
                               usuario    IN     VARCHAR2)
        RETURN VARCHAR2
    IS
        i         DECIMAL (3, 0);
        adupar    VARCHAR2 (5) := keycuo;
        fecpar    DATE := TO_DATE (sfecpar, 'DD/MM/YYYY HH24:MI');
        adudes    VARCHAR2 (5);
        fecdes    DATE;
        lista     VARCHAR2 (100) := laduanas;
        plazo     DECIMAL (3, 0);
        iplazo    VARCHAR2 (5);
        icamino   DECIMAL (3, 0) := 0;
        isec      DECIMAL (3, 0) := 1;
        ietapa    DECIMAL (3, 0) := 0;
        imax      DECIMAL (3, 0);

        --Para registrar la placa del medio de transporte EJAG 16/11/2015
        vplaca    VARCHAR2 (27);

        inicio    DECIMAL (3, 0);
        res       VARCHAR2 (100);
    BEGIN
        res := valida_verifdocs (keycuo, gestion, serial);

        IF (res <> 'OK')
        THEN
            RETURN res;
        END IF;

        --Para registrar la placa del medio de transporte EJAG 16/11/2015
        SELECT   a.car_id_trp
          INTO   vplaca
          FROM   car_gen a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial;

        IF (NOT adupas IS NULL)
        THEN
            -- versiona el transito
            SELECT   COUNT (1)
              INTO   imax
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = 1;

            -- copiamos tal como es registro anterior-vigente
            INSERT INTO tra_pla_rut
                SELECT   key_cuo,
                         car_reg_year,
                         car_reg_nber,
                         key_secuencia,
                         tra_cuo_ini,
                         tra_fec_ini,
                         tra_cuo_est,
                         tra_fec_est,
                         tra_pre,
                         tra_plazo,
                         tra_ruta,
                         tra_cuo_des,
                         tra_fec_des,
                         tra_tipo,
                         tra_obs,
                         act_boleta,
                         act_entidad,
                         act_fec_ini,
                         act_fec_fin,
                         act_monto,
                         act_moneda,
                         tra_loc,
                         tra_estado,
                         lst_ope,
                         imax,
                         usr_nam,
                         usr_fec
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND tra_num = 0;

            UPDATE   tra_pla_rut
               SET   tra_fec_ini = fecpar,
                     tra_fec_est = fecpar,
                     tra_fec_des = fecpar,
                     usr_nam = usuario,
                     usr_fec = SYSDATE
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = 0
                     AND tra_num = 0;

            IF (sql%NOTFOUND)
            THEN
                -- anadimos el registro con key_secuencia = 0, aduana de paso
                INSERT INTO tra_pla_rut (key_cuo,
                                         car_reg_year,
                                         car_reg_nber,
                                         key_secuencia,
                                         tra_cuo_ini,
                                         tra_fec_ini,
                                         tra_cuo_est,
                                         tra_fec_est,
                                         tra_cuo_des,
                                         tra_fec_des,
                                         tra_pre,
                                         tra_plazo,
                                         tra_ruta,
                                         act_boleta,
                                         act_entidad,
                                         act_fec_ini,
                                         act_fec_fin,
                                         act_monto,
                                         act_moneda,
                                         tra_estado,
                                         lst_ope,
                                         tra_num,
                                         usr_nam,
                                         usr_fec,
                                         tra_obs,
                                         tra_loc)
                  VALUES   (keycuo,
                            gestion,
                            serial,
                            0,
                            adupas,
                            fecpar,
                            adupas,
                            fecpar,
                            adupas,
                            fecpar,
                            pre_uno,
                            plazo,
                            iplazo,
                            boleta,
                            entidad,
                            TO_DATE (fecini, 'dd/mm/yyyy'),
                            TO_DATE (fecfin, 'dd/mm/yyyy'),
                            monto,
                            moneda,
                            1,
                            'U',
                            0,
                            usuario,
                            SYSDATE,
                            obs,
                            1);
            END IF;

            UPDATE   tra_pla_rut
               SET   tra_obs = obs, tra_pre = pre_uno
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0;
        ELSE
            -- para verificar que es un inicio de transito, caso contrario reaizar una reasignacion, para salida de puerto con U
            SELECT   COUNT (1)
              INTO   inicio
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U';

            -- versiona el transito
            imax := versiona_transito (keycuo, gestion, serial);

            -- copiamos aquellos que fueron cerrados
            INSERT INTO tra_pla_rut
                SELECT   key_cuo,
                         car_reg_year,
                         car_reg_nber,
                         key_secuencia,
                         tra_cuo_ini,
                         tra_fec_ini,
                         tra_cuo_est,
                         tra_fec_est,
                         tra_pre,
                         tra_plazo,
                         tra_ruta,
                         tra_cuo_des,
                         tra_fec_des,
                         tra_tipo,
                         tra_obs,
                         act_boleta,
                         act_entidad,
                         act_fec_ini,
                         act_fec_fin,
                         act_monto,
                         act_moneda,
                         tra_loc,
                         tra_estado,
                         lst_ope,
                         0,
                         usr_nam,
                         usr_fec
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND tra_num = imax
                         AND NOT tra_fec_des IS NULL;

            i := INSTR (lista, ';');
            ietapa := SUBSTR (lista, 0, i - 1);
            lista := SUBSTR (lista, 1 + i);
            i := INSTR (lista, ';');
            adudes := SUBSTR (lista, 0, i - 1);
            lista := SUBSTR (lista, 1 + i);

            --hasta aca v1
            WHILE i > 0
            LOOP
                IF (ietapa < 9)
                THEN
                    IF (modtra = 9)
                    THEN
                        SELECT   rou_ter, rou_cod
                          INTO   plazo, iplazo
                          FROM   unroutab
                         WHERE       cuo_sal IN (adupar, adudes)
                                 AND cuo_arr IN (adupar, adudes)
                                 AND rou_mod = 3
                                 AND lst_ope = 'U'
                                 AND numver = 0;
                    ELSE
                        SELECT   rou_ter, rou_cod
                          INTO   plazo, iplazo
                          FROM   unroutab
                         WHERE       cuo_sal IN (adupar, adudes)
                                 AND cuo_arr IN (adupar, adudes)
                                 AND rou_mod = modtra
                                 AND lst_ope = 'U'
                                 AND numver = 0;
                    END IF;

                    fecdes := fecpar + (plazo / 24);

                    INSERT INTO tra_pla_rut (key_cuo,
                                             car_reg_year,
                                             car_reg_nber,
                                             key_secuencia,
                                             tra_cuo_ini,
                                             tra_fec_ini,
                                             tra_cuo_est,
                                             tra_fec_est,
                                             tra_pre,
                                             tra_plazo,
                                             tra_ruta,
                                             act_boleta,
                                             act_entidad,
                                             act_fec_ini,
                                             act_fec_fin,
                                             act_monto,
                                             act_moneda,
                                             tra_estado,
                                             lst_ope,
                                             tra_num,
                                             usr_nam,
                                             usr_fec,
                                             tra_obs)
                      VALUES   (keycuo,
                                gestion,
                                serial,
                                isec,
                                adupar,
                                fecpar,
                                adudes,
                                fecdes,
                                pre_uno,
                                plazo,
                                iplazo,
                                boleta,
                                entidad,
                                TO_DATE (fecini, 'dd/mm/yyyy'),
                                TO_DATE (fecfin, 'dd/mm/yyyy'),
                                monto,
                                moneda,
                                icamino,
                                DECODE (
                                    inicio,
                                    0,
                                    DECODE (SUBSTR (keycuo, 0, 1),
                                            '0', 'M',
                                            'U'),
                                    'U'), -- MODIFICACION PARA SALIDA DE PUERTO 04062014
                                0,
                                usuario,
                                SYSDATE,
                                obs);

                    icamino := 1;
                    fecpar := fecdes;
                END IF;

                adupar := adudes;
                i := INSTR (lista, ';');
                ietapa := SUBSTR (lista, 0, i - 1);
                lista := SUBSTR (lista, 1 + i);
                i := INSTR (lista, ';');
                adudes := SUBSTR (lista, 0, i - 1);
                lista := SUBSTR (lista, 1 + i);
                isec := isec + 1;
            END LOOP;

            --Para registrar la placa del medio de transporte EJAG 16/11/2015
            placa_inicio (keycuo,
                          gestion,
                          serial,
                          vplaca);
            --Para enviar mensaje al UTIL por inicio de transito
            if(keycuo <> '071' and keycuo <> '072' ) then
                util_inicio (keycuo,
                              gestion,
                              serial,
                              usuario,
                              '1');
            end if;
            pkg_variable_riesgo.evalua_riesgo (keycuo,
                                               gestion,
                                               serial,
                                               usuario);
        END IF;


        COMMIT;
        RETURN 'Correcto';
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            RETURN    'El tramo '
                   || adupar
                   || ' - '
                   || adudes
                   || ' no esta registrado';
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    /*****************************************************
    * Cerramos la ruta y plazo el registro tra_estado=0  *
    *****************************************************/
    FUNCTION cierra_secuencia (keycuo      IN VARCHAR2,
                               gestion     IN VARCHAR2,
                               serial      IN DECIMAL,
                               secuencia   IN DECIMAL,
                               adudes      IN VARCHAR2,
                               sfecdes     IN VARCHAR2,
                               itipo       IN DECIMAL,
                               obs         IN VARCHAR2,
                               usuario     IN VARCHAR2)
        RETURN VARCHAR2
    IS
        imax     DECIMAL (3, 0) := 0;
        fecdes   DATE := TO_DATE (sfecdes, 'dd/mm/yyyy hh24:mi');
    BEGIN
        -- versiona el transito
        imax := versiona_transito (keycuo, gestion, serial);

        -- insertamos los registro que son diferente a la secuencia tal como son
        INSERT INTO tra_pla_rut
            SELECT   key_cuo,
                     car_reg_year,
                     car_reg_nber,
                     key_secuencia,
                     tra_cuo_ini,
                     tra_fec_ini,
                     tra_cuo_est,
                     tra_fec_est,
                     tra_pre,
                     tra_plazo,
                     tra_ruta,
                     tra_cuo_des,
                     tra_fec_des,
                     tra_tipo,
                     tra_obs,
                     act_boleta,
                     act_entidad,
                     act_fec_ini,
                     act_fec_fin,
                     act_monto,
                     act_moneda,
                     tra_loc,
                     tra_estado,
                     lst_ope,
                     0,
                     usr_nam,
                     usr_fec
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia <> secuencia
                     AND tra_num = imax;

        -- insertamos el registro la aduana y fecha de destino
        INSERT INTO tra_pla_rut
            SELECT   key_cuo,
                     car_reg_year,
                     car_reg_nber,
                     key_secuencia,
                     tra_cuo_ini,
                     tra_fec_ini,
                     tra_cuo_est,
                     tra_fec_est,
                     tra_pre,
                     tra_plazo,
                     tra_ruta,
                     adudes,
                     fecdes,
                     itipo,
                     obs,
                     act_boleta,
                     act_entidad,
                     act_fec_ini,
                     act_fec_fin,
                     act_monto,
                     act_moneda,
                     tra_loc,
                     1,
                     lst_ope,
                     0,
                     usuario,
                     SYSDATE
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = secuencia
                     AND tra_num = imax;

        -- recorremos el control de ruta al siguiente tramo
        UPDATE   tra_pla_rut
           SET   tra_estado = 0, tra_num = 0
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND key_secuencia = secuencia + 1
                 AND tra_num = 0;

        --Para registrar la placa del medio de transporte EJAG 16/11/2015
        placa_cierre (keycuo,
                      gestion,
                      serial,
                      0,
                      '0',
                      'CIERRE');
        --Para enviar mensaje al UTIL por cierre de transito
        util_cierre (keycuo,
                      gestion,
                      serial,
                      secuencia,
                      usuario,
                      'CIERRE');
        RETURN 'Correcto';
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    /********************************************************
    * Cerramos las rutas y plazos para forzoso y transbordo *
    ********************************************************/
    FUNCTION cierra_todo (keycuo      IN VARCHAR2,
                          gestion     IN VARCHAR2,
                          serial      IN DECIMAL,
                          secuencia   IN DECIMAL,
                          adudes      IN VARCHAR2,
                          sfecdes     IN VARCHAR2,
                          icierre     IN DECIMAL,
                          obs         IN VARCHAR2,
                          usuario     IN VARCHAR2)
        RETURN VARCHAR2
    IS
        maximo   DECIMAL (3, 0) := 0;
        fecdes   DATE := TO_DATE (sfecdes, 'dd/mm/yyyy hh24:mi');
    BEGIN
        -- versiona el transito
        maximo := versiona_transito (keycuo, gestion, serial);

        -- verificamos el tipo de cierre
        IF (icierre = btransbordo)
        THEN
            -- insertamos los registro que se cerraron anteriormente
            INSERT INTO tra_pla_rut
                SELECT   key_cuo,
                         car_reg_year,
                         car_reg_nber,
                         key_secuencia,
                         tra_cuo_ini,
                         tra_fec_ini,
                         tra_cuo_est,
                         tra_fec_est,
                         tra_pre,
                         tra_plazo,
                         tra_ruta,
                         tra_cuo_des,
                         tra_fec_des,
                         tra_tipo,
                         tra_obs,
                         act_boleta,
                         act_entidad,
                         act_fec_ini,
                         act_fec_fin,
                         act_monto,
                         act_moneda,
                         tra_loc,
                         tra_estado,
                         lst_ope,
                         0,
                         usr_nam,
                         usr_fec
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND NOT tra_cuo_des IS NULL
                         AND tra_num = maximo;

            -- insertamos los registro pendientes de cierre con usuario, fecha y no se localiza
            INSERT INTO tra_pla_rut
                SELECT   key_cuo,
                         car_reg_year,
                         car_reg_nber,
                         key_secuencia,
                         tra_cuo_ini,
                         tra_fec_ini,
                         tra_cuo_est,
                         tra_fec_est,
                         tra_pre,
                         tra_plazo,
                         tra_ruta,
                         adudes,
                         fecdes,
                         icierre,
                         obs,
                         act_boleta,
                         act_entidad,
                         act_fec_ini,
                         act_fec_fin,
                         act_monto,
                         act_moneda,
                         1,
                         1,
                         lst_ope,
                         0,
                         usuario,
                         SYSDATE
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND tra_cuo_des IS NULL
                         AND tra_num = maximo;

            --Para registrar la placa del medio de transporte EJAG 16/11/2015
            placa_cierre (keycuo,
                          gestion,
                          serial,
                          0,
                          '0',
                          'TRANSBORDO');
            --Para enviar mensaje al UTIL por cierre de transito
        util_cierre (keycuo,
                      gestion,
                      serial,
                      secuencia,
                      usuario,
                      'TRANSBORDO');
        ELSE
            -- insertamos los registro que se cerraron anteriormente
            INSERT INTO tra_pla_rut
                SELECT   key_cuo,
                         car_reg_year,
                         car_reg_nber,
                         key_secuencia,
                         tra_cuo_ini,
                         tra_fec_ini,
                         tra_cuo_est,
                         tra_fec_est,
                         tra_pre,
                         tra_plazo,
                         tra_ruta,
                         tra_cuo_des,
                         tra_fec_des,
                         tra_tipo,
                         tra_obs,
                         act_boleta,
                         act_entidad,
                         act_fec_ini,
                         act_fec_fin,
                         act_monto,
                         act_moneda,
                         tra_loc,
                         tra_estado,
                         lst_ope,
                         0,
                         usr_nam,
                         usr_fec
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND NOT tra_cuo_des IS NULL
                         AND tra_num = maximo;

            -- insertamos el registro vigente de cierre con usuario, fecha y se localiza
            INSERT INTO tra_pla_rut
                SELECT   key_cuo,
                         car_reg_year,
                         car_reg_nber,
                         key_secuencia,
                         tra_cuo_ini,
                         tra_fec_ini,
                         tra_cuo_est,
                         tra_fec_est,
                         tra_pre,
                         tra_plazo,
                         tra_ruta,
                         adudes,
                         fecdes,
                         icierre,
                         obs,
                         act_boleta,
                         act_entidad,
                         act_fec_ini,
                         act_fec_fin,
                         act_monto,
                         act_moneda,
                         0,
                         1,
                         lst_ope,
                         0,
                         usuario,
                         SYSDATE
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND key_secuencia = secuencia
                         AND tra_cuo_des IS NULL
                         AND tra_num = maximo;

            -- insertamos los registro pendientes (no vigente) con usuario, fecha y se localiza
            INSERT INTO tra_pla_rut
                SELECT   key_cuo,
                         car_reg_year,
                         car_reg_nber,
                         key_secuencia,
                         tra_cuo_ini,
                         tra_fec_ini,
                         tra_cuo_est,
                         tra_fec_est,
                         tra_pre,
                         tra_plazo,
                         tra_ruta,
                         adudes,
                         fecdes,
                         icierre,
                         obs,
                         act_boleta,
                         act_entidad,
                         act_fec_ini,
                         act_fec_fin,
                         act_monto,
                         act_moneda,
                         1,
                         1,
                         lst_ope,
                         0,
                         usuario,
                         SYSDATE
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND key_secuencia <> secuencia
                         AND tra_cuo_des IS NULL
                         AND tra_num = maximo;

            --Para registrar la placa del medio de transporte EJAG 16/11/2015
            placa_cierre (keycuo,
                          gestion,
                          serial,
                          0,
                          '0',
                          'FORZOSO');
            --Para enviar mensaje al UTIL por cierre de transito
            util_cierre (keycuo,
                          gestion,
                          serial,
                          secuencia,
                          usuario,
                          'FORZOSO');
        END IF;

        RETURN 'Correcto';
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;

    /***************************************************************
    * Cerramos la(s) ruta(s) y plazo(s)                            *
    * si icierre = 24 (normal) => cerramos solo un tramo           *
    * si icierre = 23 (forzoso) => cerramos todos para importar    *
    * si icierre = 28 (transbordo) => cerramos todos para transito *
    ***************************************************************/
    FUNCTION cierra_transito (keycuo      IN     VARCHAR2,
                              gestion     IN     VARCHAR2,
                              serial      IN     DECIMAL,
                              secuencia   IN     DECIMAL,
                              adudes      IN     VARCHAR2, -- aduana de estino
                              fecdes      IN     VARCHAR2,
                              codtrans    IN     VARCHAR2, -- empresa de transporte
                              placa       IN     VARCHAR2,      -- medio placa
                              icierre     IN     DECIMAL,    -- Tipo de cierre
                              obs         IN     VARCHAR2,
                              usuario     IN     VARCHAR2,
                              ans            OUT VARCHAR2)
        RETURN VARCHAR2
    IS
        answer                   VARCHAR2 (255);
        maximo                   DECIMAL (3, 0);
        id                       VARCHAR2 (15);
        p_manifiestoregistro     VARCHAR2 (100);
        p_manifiestoreferencia   VARCHAR2 (100);
        medio                    VARCHAR2 (15);
        etapa                    DECIMAL (3, 0) := 0;
    BEGIN
        IF (icierre = bnormal)
        THEN
            answer :=
                cierra_secuencia (keycuo,
                                  gestion,
                                  serial,
                                  secuencia,
                                  adudes,
                                  fecdes,
                                  icierre,
                                  obs,
                                  usuario);
        ELSE
            IF (icierre = btransbordo)
            THEN
                etapa := 0;

                IF (no_ciclico_transbordo (keycuo,
                                           gestion,
                                           serial,
                                           adudes))
                THEN
                    RAISE NO_DATA_FOUND;
                END IF;

                etapa := 1;
                id := verifica_empresa_habilitada (codtrans);

                IF (maximo = 0)
                THEN
                    RAISE NO_DATA_FOUND;
                END IF;

                etapa := 2;

                IF (verifica_medio_habilitada (id, placa) = 0)
                THEN
                    RAISE NO_DATA_FOUND;
                END IF;

                etapa := 3;

                IF (verifica_medio_pendiente (placa) > 0)
                THEN
                    RAISE NO_DATA_FOUND;
                END IF;
            END IF;

            answer :=
                cierra_todo (keycuo,
                             gestion,
                             serial,
                             secuencia,
                             adudes,
                             fecdes,
                             icierre,
                             obs,
                             usuario);
        END IF;

        IF (answer = 'Correcto')
        THEN
            IF (icierre = btransbordo)
            THEN
                ops$asy.pckmanifiesto.generarmanifiesto (
                    gestion,
                    keycuo,
                    serial,
                    adudes,
                    icierre,
                    SUBSTR (fecdes, 1, 10),
                    SUBSTR (fecdes, 12, 5),
                    usuario,
                    p_manifiestoregistro,
                    p_manifiestoreferencia,
                    codtrans,
                    placa);
            ELSE
                ops$asy.pckmanifiesto.generarmanifiesto (
                    gestion,
                    keycuo,
                    serial,
                    adudes,
                    icierre,
                    SUBSTR (fecdes, 1, 10),
                    SUBSTR (fecdes, 12, 5),
                    usuario,
                    p_manifiestoregistro,
                    p_manifiestoreferencia);
            END IF;

            answer := 'Correcto';
            ans := RTRIM (p_manifiestoregistro);

            IF (icierre = btransbordo)
            THEN
                maximo := INSTR (ans, ' ') - 10;
                pkg_transito.replica_control_embarque (
                    keycuo,
                    gestion,
                    serial,
                    SUBSTR (ans, 6, 3),
                    SUBSTR (ans, 0, 4),
                    SUBSTR (ans, 10, maximo),
                    usuario);
            END IF;

            IF (icierre <> btransbordo)
            THEN
                maximo := INSTR (ans, ' ') - 10;

                INSERT INTO tra_loc
                    SELECT   keycuo,
                             gestion,
                             serial,
                             secuencia,
                             SUBSTR (ans, 6, 3),
                             SUBSTR (ans, 0, 4),
                             SUBSTR (ans, 10, maximo),
                             key_bol_ref,
                             NULL
                      FROM   ops$asy.car_bol_gen cb, ops$asy.car_gen cg
                     WHERE       cb.key_cuo = cg.key_cuo
                             AND cb.key_voy_nber = cg.key_voy_nber
                             AND cb.key_dep_date = cg.key_dep_date
                             AND cg.key_cuo = SUBSTR (ans, 6, 3)
                             AND cg.car_reg_year = SUBSTR (ans, 0, 4)
                             AND cg.car_reg_nber = SUBSTR (ans, 10, maximo);
            END IF;

            COMMIT;
        ELSE
            --answer := 'Mal';
            ans := '';
            ROLLBACK;
        END IF;

        RETURN answer;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            IF (etapa = 0)
            THEN
                RETURN ('No se puede hacer transbordo en una Aduana Destino');
            ELSIF (etapa = 1)
            THEN
                RETURN ('No esta habilitado la Empresa');
            ELSIF (etapa = 2)
            THEN
                RETURN ('No esta habilitado el Medio de Transporte');
            ELSE
                RETURN ('El medio tiene un transito Pendiente');
            END IF;
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR ('Error ' || TO_CHAR (SQLCODE) || ': ' || SQLERRM,
                           1,
                           255);
    END;

    /*************************************************************
    * Devuelve la lista de las Aduana habilitads para el usuario *
    *************************************************************/
    FUNCTION lista_aduanas (usuario IN VARCHAR2)
        RETURN cursortype
    IS
        ct       cursortype;
        hay      DECIMAL (3, 0);
        aduana   VARCHAR2 (30) := usuario;
        adu1     VARCHAR2 (5);
        adu2     VARCHAR2 (5);
        adu3     VARCHAR2 (5);
        adu4     VARCHAR2 (5);
        adu5     VARCHAR2 (30);
    BEGIN
        IF (usuario = 'ALL')
        THEN
            OPEN ct FOR
                  SELECT   cuo_cod, cuo_nam
                    FROM   ops$asy.uncuotab a
                   WHERE   NOT cuo_cod IN ('ALL', 'CUO01') AND lst_ope = 'U'
                ORDER BY   1;
        ELSE
            hay := INSTR (aduana, '-');

            IF (hay > 0)
            THEN
                adu1 := SUBSTR (aduana, 0, hay - 1);
                aduana := SUBSTR (aduana, hay + 1);
                hay := INSTR (aduana, '-');

                IF (hay > 0)
                THEN
                    adu2 := SUBSTR (aduana, 0, hay - 1);
                    aduana := SUBSTR (aduana, hay + 1);
                    hay := INSTR (aduana, '-');

                    IF (hay > 0)
                    THEN
                        adu3 := SUBSTR (aduana, 0, hay - 1);
                        aduana := SUBSTR (aduana, hay + 1);
                        hay := INSTR (aduana, '-');

                        IF (hay > 0)
                        THEN
                            adu4 := SUBSTR (aduana, 0, hay - 1);
                            aduana := SUBSTR (aduana, hay + 1);
                            hay := INSTR (aduana, '-');
                        END IF;
                    END IF;
                END IF;
            END IF;

            adu5 := aduana;

            OPEN ct FOR
                  SELECT   a.cuo_cod, a.cuo_nam
                    FROM   ops$asy.uncuotab a
                   WHERE       a.cuo_cod IN (adu1, adu2, adu3, adu4, adu5)
                           AND NOT cuo_cod IN ('ALL', 'CUO01')
                           AND a.lst_ope = 'U'
                ORDER BY   1;
        END IF;

        RETURN ct;
    END;

    FUNCTION consulta_peso (keycuo    IN VARCHAR2,
                            gestion   IN VARCHAR2,
                            serial    IN DECIMAL,
                            adudes    IN VARCHAR)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
            SELECT   key_bol_ref,
                     TO_CHAR (car_pkg_avl, '99,999,990.000000'),
                     TO_CHAR (car_wgt_avl, '99,999,990.000000')
              FROM   ops$asy.car_bol_ope
             WHERE   car_bol_ser IN
                             (  SELECT   MAX (co.car_bol_ser)
                                  FROM   ops$asy.car_bol_ope co,
                                         ops$asy.car_bol_gen cb,
                                         ops$asy.car_gen cg
                                 WHERE       cb.key_cuo = cg.key_cuo
                                         AND cb.key_voy_nber = cg.key_voy_nber
                                         AND cb.key_dep_date = cg.key_dep_date
                                         AND cb.key_cuo = co.key_cuo
                                         AND cb.key_voy_nber = co.key_voy_nber
                                         AND cb.key_dep_date = co.key_dep_date
                                         AND cb.key_bol_ref = co.key_bol_ref
                                         AND cg.key_cuo = keycuo
                                         AND cg.car_reg_year = gestion
                                         AND cg.car_reg_nber = serial
                                         AND cb.carbol_frt_prep = adudes
                                         AND NOT cb.key_bol_ref IN
                                                         (SELECT   key_bol_ref
                                                            FROM   ops$asy.car_spy
                                                           WHERE   key_cuo =
                                                                       cb.key_cuo
                                                                   AND key_voy_nber =
                                                                          cb.key_voy_nber
                                                                   AND key_dep_date =
                                                                          cb.key_dep_date
                                                                   AND spy_sta =
                                                                          11)
                              GROUP BY   cb.key_bol_ref);

        RETURN ct;
    END;

    FUNCTION consulta_bitacora (keycuo    IN VARCHAR2,
                                gestion   IN VARCHAR2,
                                serial    IN DECIMAL)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        OPEN ct FOR
              SELECT   a.key_secuencia,
                       a.tra_cuo_ini || ': ' || b.cuo_nam AS aduiini,
                       TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:mi')
                           AS tra_fec_ini,
                       DECODE (a.key_secuencia,
                               0, ' ',
                               a.tra_cuo_est || ': ' || c.cuo_nam)
                           AS aduest,
                       DECODE (a.key_secuencia,
                               0, ' ',
                               TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:mi'))
                           AS tra_fec_est,
                       NVL (a.tra_pre, ' '),
                       DECODE (
                           a.key_secuencia,
                           0,
                           ' ',
                           DECODE (a.tra_cuo_des,
                                   NULL, ' ',
                                   a.tra_cuo_des || ': ' || d.cuo_nam))
                           AS adudes,
                       DECODE (
                           a.key_secuencia,
                           0,
                           ' ',
                           NVL (TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:mi'),
                                ' '))
                           AS tra_fec_des,
                       DECODE (
                           a.lst_ope,
                           'D',
                           'Cancelado/Anulado',
                           DECODE (
                               a.tra_tipo,
                               23,
                               'Forzoso',
                               24,
                               'Normal',
                               28,
                               'Transbordo',
                               DECODE (
                                   a.key_secuencia,
                                   0,
                                   DECODE (b.cuo_acc,
                                           'PTOCTL', 'Punto de Control',
                                           'Aduana de Paso'),
                                   ' ') /*DECODE (a.key_secuencia, 0
                                                , DECODE (a.tra_cuo_est,'111'
                                                      ,'Punto de Control'
                                                      , DECODE (a.tra_cuo_est,'611'
                                                          ,'Punto de Control'
                                                          , DECODE (a.tra_cuo_est,'712'
                                                              ,'Punto de Control'
                                                              , DECODE (a.tra_cuo_est,'911'
                                                                  ,'Punto de Control'
                                                                  ,'Aduana de Paso'
                                                                  )
                                                              )
                                                          )
                                                      )
                                                , ' '
                                               )*/
                                       ))
                           AS tra_tipo,
                       NVL (a.tra_obs, ' '),
                       DECODE (a.key_secuencia,
                               0, ' ',
                               DECODE (a.tra_loc, 0, 'No', 'Si')),
                       a.tra_num,
                       a.usr_nam,
                       TO_CHAR (a.usr_fec, 'dd/mm/yyyy HH24:mi:ss') AS usr_fec
                FROM   tra_pla_rut a,
                       ops$asy.uncuotab b,
                       ops$asy.uncuotab c,
                       ops$asy.uncuotab d
               WHERE       a.key_cuo = keycuo
                       AND a.car_reg_year = gestion
                       AND a.car_reg_nber = serial
                       AND a.tra_cuo_ini = b.cuo_cod
                       AND b.lst_ope = 'U'
                       AND a.tra_cuo_est = c.cuo_cod
                       AND c.lst_ope = 'U'
                       AND a.tra_cuo_des = d.cuo_cod(+)
                       AND d.lst_ope(+) = 'U'
            ORDER BY   a.usr_fec DESC,
                       a.tra_num DESC,
                       a.car_reg_nber,
                       a.key_secuencia;

        RETURN ct;
    END;

    FUNCTION consulta_transportista (nit IN VARCHAR2)
        RETURN cursortype
    IS
        ct   cursortype;
    BEGIN
        INSERT INTO tra_notificacion
          VALUES   (nit, SYSDATE);

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
                       DECODE (a.tra_fec_des, NULL, 2, a.tra_loc) AS loc
                FROM   tra_pla_rut a,
                       ops$asy.car_gen b,
                       ops$asy.uncuotab c1,
                       ops$asy.uncuotab c2,
                       ops$asy.uncuotab c3
               WHERE       b.key_cuo = a.key_cuo
                       AND b.car_reg_year = a.car_reg_year
                       AND b.car_reg_nber = a.car_reg_nber
                       AND a.tra_cuo_ini = c1.cuo_cod
                       AND a.tra_cuo_est = c2.cuo_cod
                       AND a.tra_cuo_des = c3.cuo_cod(+)
                       AND a.lst_ope = 'U'
                       AND a.tra_num = 0
                       AND c1.lst_ope = 'U'
                       AND c2.lst_ope = 'U'
                       AND c3.lst_ope(+) = 'U'
                       AND ( (tra_loc = '0' AND NOT tra_fec_des IS NULL)
                            OR (ROUND (SYSDATE - a.tra_fec_est) >= 0
                                AND tra_fec_des IS NULL))
                       AND b.car_car_cod = nit
                       AND NOT (b.key_cuo, b.car_reg_year, b.car_reg_nber) IN
                                       (SELECT   key_cuo,
                                                 car_reg_year,
                                                 car_reg_nber
                                          FROM   tra_acta
                                         WHERE   tac_estado IN (0, 1)
                                                 AND car_car_cod = nit)
            ORDER BY   1, 2, 3;

        RETURN ct;
    END;

    FUNCTION consulta_placa (placa   IN VARCHAR2,
                             sini    IN VARCHAR2,
                             sfin    IN VARCHAR2)
        RETURN cursortype
    IS
        ct     cursortype;
        fini   DATE := TO_DATE (sini, 'dd/mm/yyyy');
        ffin   DATE := TO_DATE (sfin, 'dd/mm/yyyy');
    BEGIN
        OPEN ct FOR
              SELECT      a.car_reg_year
                       || '/'
                       || a.key_cuo
                       || '-'
                       || a.car_reg_nber
                           AS tramite,
                       a.key_secuencia,
                       b.car_car_cod,
                       b.car_car_nam,
                       b.car_id_trp,
                       a.tra_cuo_ini || ': ' || b.cuo_nam AS aduiini,
                       TO_CHAR (a.tra_fec_ini, 'dd/mm/yyyy HH24:mi')
                           AS tra_fec_ini,
                       a.tra_cuo_est || ': ' || c.cuo_nam AS aduest,
                       TO_CHAR (a.tra_fec_est, 'dd/mm/yyyy HH24:mi')
                           AS tra_fec_est,
                       DECODE (a.tra_cuo_des,
                               NULL, ' ',
                               a.tra_cuo_des || ': ' || d.cuo_nam)
                           AS adudes,
                       NVL (TO_CHAR (a.tra_fec_des, 'dd/mm/yyyy HH24:mi'), ' ')
                           AS tra_fec_des,
                       DECODE (a.tra_tipo,
                               23, 'Forzoso',
                               24, 'Normal',
                               28, 'Transbordo',
                               ' ')
                           AS tra_tipo,
                       TRUNC (SYSDATE - NVL (a.tra_fec_des, a.tra_fec_est))
                           AS dias,
                       TRUNC( ( (SYSDATE - NVL (a.tra_fec_des, a.tra_fec_est))
                               - TRUNC(SYSDATE
                                       - NVL (a.tra_fec_des, a.tra_fec_est)))
                             * 24)
                           AS hora,
                       DECODE (a.tra_fec_des, NULL, 2, a.tra_loc) AS loc,
                       tra_estado,
                       tiene_acta (a.key_cuo,
                                   a.car_reg_year,
                                   a.car_reg_nber,
                                   a.key_secuencia)
                           acta
                FROM   tra_pla_rut a,
                       ops$asy.car_gen b,
                       ops$asy.uncuotab b,
                       ops$asy.uncuotab c,
                       ops$asy.uncuotab d
               WHERE       a.key_cuo = b.key_cuo
                       AND a.car_reg_year = b.car_reg_year
                       AND a.car_reg_nber = b.car_reg_nber
                       AND a.tra_num = 0
                       AND a.lst_ope = 'U'
                       AND b.car_id_trp = UPPER (placa)
                       AND NOT b.car_id_trp IN ('11111', '00000')
                       -- Propios medios
                       AND a.tra_cuo_ini = b.cuo_cod
                       AND b.lst_ope = 'U'
                       AND a.tra_cuo_est = c.cuo_cod
                       AND c.lst_ope = 'U'
                       AND a.tra_cuo_des = d.cuo_cod(+)
                       AND d.lst_ope(+) = 'U'
                       AND a.key_secuencia > 0
                       AND TRUNC (a.tra_fec_ini) BETWEEN fini AND ffin
            ORDER BY   a.tra_fec_des DESC,
                       a.tra_fec_est DESC,
                       a.key_cuo,
                       a.car_reg_year,
                       a.car_reg_nber,
                       a.key_secuencia;

        RETURN ct;
    END;

    FUNCTION lista_ptoctl (usuario IN VARCHAR2)
        RETURN cursortype
    IS
        ct       cursortype;
        hay      DECIMAL (3, 0);
        aduana   VARCHAR2 (30) := usuario;
        adu1     VARCHAR2 (5);
        adu2     VARCHAR2 (5);
        adu3     VARCHAR2 (5);
        adu4     VARCHAR2 (5);
        adu5     VARCHAR2 (30);
    BEGIN
        IF (usuario = 'ALL')
        THEN
            OPEN ct FOR
                  SELECT   cuo_cod, cuo_nam
                    FROM   uncuotab a
                   WHERE       NOT cuo_cod IN ('ALL', 'CUO01')
                           AND lst_ope = 'U'
                           AND a.cuo_acc = 'PTOCTL'
                ORDER BY   1;
        ELSE
            hay := INSTR (aduana, '-');

            IF (hay > 0)
            THEN
                adu1 := SUBSTR (aduana, 0, hay - 1);
                aduana := SUBSTR (aduana, hay + 1);
                hay := INSTR (aduana, '-');

                IF (hay > 0)
                THEN
                    adu2 := SUBSTR (aduana, 0, hay - 1);
                    aduana := SUBSTR (aduana, hay + 1);
                    hay := INSTR (aduana, '-');

                    IF (hay > 0)
                    THEN
                        adu3 := SUBSTR (aduana, 0, hay - 1);
                        aduana := SUBSTR (aduana, hay + 1);
                        hay := INSTR (aduana, '-');

                        IF (hay > 0)
                        THEN
                            adu4 := SUBSTR (aduana, 0, hay - 1);
                            aduana := SUBSTR (aduana, hay + 1);
                            hay := INSTR (aduana, '-');
                        END IF;
                    END IF;
                END IF;
            END IF;

            adu5 := aduana;

            OPEN ct FOR
                  SELECT   a.cuo_cod, a.cuo_nam
                    FROM   uncuotab a
                   WHERE       a.cuo_cod IN (adu1, adu2, adu3, adu4, adu5)
                           AND a.cuo_acc = 'PTOCTL'
                           AND NOT cuo_cod IN ('ALL', 'CUO01')
                           AND a.lst_ope = 'U'
                ORDER BY   1;
        END IF;

        RETURN ct;
    END;

    FUNCTION registro_paso_peso (keycuo       IN VARCHAR2,
                                 gestion      IN VARCHAR2,
                                 serial       IN DECIMAL,
                                 fecha_paso   IN VARCHAR2,
                                 aduana       IN VARCHAR2,
                                 usuario      IN VARCHAR2)
        RETURN VARCHAR2
    IS
        inicio    PLS_INTEGER := 0;
        fecpaso   DATE := TO_DATE (fecha_paso, 'dd/mm/yyyy hh24:mi:ss');
    BEGIN
        inicio :=
            pkg_verifica_transito.faduana_paso (keycuo,
                                                gestion,
                                                serial,
                                                aduana);

        IF (inicio = mt_correcto AND keycuo = '072')
        THEN
            SELECT   COUNT (1)
              INTO   inicio
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = 1;

            -- copiamos tal como es registro anterior-vigente
            INSERT INTO tra_pla_rut
                SELECT   key_cuo,
                         car_reg_year,
                         car_reg_nber,
                         key_secuencia,
                         tra_cuo_ini,
                         tra_fec_ini,
                         tra_cuo_est,
                         tra_fec_est,
                         tra_pre,
                         tra_plazo,
                         tra_ruta,
                         tra_cuo_des,
                         tra_fec_des,
                         tra_tipo,
                         tra_obs,
                         act_boleta,
                         act_entidad,
                         act_fec_ini,
                         act_fec_fin,
                         act_monto,
                         act_moneda,
                         tra_loc,
                         tra_estado,
                         lst_ope,
                         inicio,
                         usr_nam,
                         usr_fec
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND tra_num = 0;

            UPDATE   tra_pla_rut
               SET   tra_fec_ini = fecpaso,
                     tra_fec_est = fecpaso,
                     tra_fec_des = fecpaso,
                     usr_nam = usuario,
                     usr_fec = SYSDATE
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = 0
                     AND tra_num = 0;

            IF (sql%NOTFOUND)
            THEN
                -- anadimos el registro con key_secuencia = 0, aduana de paso
                INSERT INTO tra_pla_rut (key_cuo,
                                         car_reg_year,
                                         car_reg_nber,
                                         key_secuencia,
                                         tra_cuo_ini,
                                         tra_fec_ini,
                                         tra_cuo_est,
                                         tra_fec_est,
                                         tra_cuo_des,
                                         tra_fec_des,
                                         tra_loc,
                                         tra_estado,
                                         lst_ope,
                                         tra_num,
                                         usr_nam,
                                         usr_fec)
                  VALUES   (keycuo,
                            gestion,
                            serial,
                            0,
                            '422',
                            fecpaso,
                            '422',
                            fecpaso,
                            '422',
                            fecpaso,
                            1,
                            1,
                            'U',
                            0,
                            usuario,
                            SYSDATE);
            END IF;

            RETURN 'correcto';
        ELSE
            RETURN 'error';
        END IF;
    END;

    FUNCTION reporte_aduana_peso_paso (fec_ini   IN VARCHAR2,
                                       fec_fin   IN VARCHAR2,
                                       npeso     IN PLS_INTEGER,
                                       nobs      IN PLS_INTEGER)
        RETURN cursortype
    IS
        ct        cursortype;
        dinicio   DATE := TO_DATE (fec_ini, 'dd/mm/yyyy') - 1;
        dfin      DATE := TO_DATE (fec_fin, 'dd/mm/yyyy') + 1;
        a1        PLS_INTEGER := npeso;
        b1        PLS_INTEGER := nobs;
    BEGIN
        OPEN ct FOR
              SELECT   az.key_cuo,
                       az.car_reg_year,
                       az.car_reg_nber,
                       CASE registro_peso WHEN 1 THEN 'Si' ELSE 'No' END
                           AS registro_peso,
                       CASE registro_obs WHEN 1 THEN 'Si' ELSE 'No' END
                           AS registro_obs,
                       NVL (TO_CHAR (mod_reg, 'dd/mm/yyyy hh24:mi'), '-')
                           AS mod_reg,
                       TO_CHAR (bz1.tra_fec_ini, 'dd/mm/yyyy hh24:mi')
                           AS tra_fec_ini,
                       NVL (TO_CHAR (bz2.tra_fec_est, 'dd/mm/yyyy hh24:mi'),
                            '-')
                           AS tra_fec_obs,
                       TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi') AS fhoy
                FROM   (  SELECT   key_cuo,
                                   car_reg_year,
                                   car_reg_nber,
                                   SUM (registro_peso) AS registro_peso,
                                   SUM (registro_observacion) AS registro_obs,
                                   SUM (solo_aduana_paso) AS solo_paso,
                                   MAX (mod_fecreg) AS mod_reg
                            FROM   (SELECT   key_cuo,
                                             car_reg_year,
                                             car_reg_nber,
                                             1 AS registro_peso,
                                             0 AS registro_observacion,
                                             0 AS solo_aduana_paso,
                                             mod_fecreg
                                      FROM   transitos.t_modpeso
                                     WHERE   key_cuo = '072' AND mod_num = 0
                                             AND TRUNC (mod_fecreg) BETWEEN dinicio
                                                                        AND  dfin
                                    UNION
                                    SELECT   key_cuo,
                                             car_reg_year,
                                             car_reg_nber,
                                             0 AS registro_peso,
                                             1 AS registro_observacion,
                                             0 AS solo_aduana_paso,
                                             NULL
                                      FROM   transitos.tra_pla_rut
                                     WHERE   tra_num = 0 AND key_secuencia = 0
                                             AND (key_cuo,
                                                  car_reg_year,
                                                  car_reg_nber) IN
                                                        (  SELECT   key_cuo,
                                                                    car_reg_year,
                                                                    car_reg_nber
                                                             FROM   transitos.tra_pla_rut
                                                            WHERE   key_cuo = '072'
                                                                    AND key_secuencia =
                                                                           0
                                                                    AND TRUNC(tra_fec_ini) BETWEEN dinicio
                                                                                               AND  dfin
                                                         GROUP BY   key_cuo,
                                                                    car_reg_year,
                                                                    car_reg_nber
                                                           HAVING   COUNT (1) > 1)
                                    UNION
                                    SELECT   key_cuo,
                                             car_reg_year,
                                             car_reg_nber,
                                             0,
                                             0,
                                             1,
                                             NULL
                                      FROM   (SELECT   key_cuo,
                                                       car_reg_year,
                                                       car_reg_nber
                                                FROM   transitos.tra_pla_rut
                                               WHERE       key_cuo = '072'
                                                       AND key_secuencia = 0
                                                       AND tra_num = 0
                                                       AND TRUNC (tra_fec_ini) BETWEEN dinicio
                                                                                   AND  dfin
                                              MINUS
                                              SELECT   key_cuo,
                                                       car_reg_year,
                                                       car_reg_nber
                                                FROM   transitos.t_modpeso
                                               WHERE   key_cuo = '072'
                                                       AND mod_num = 0
                                                       AND TRUNC (mod_fecreg) BETWEEN dinicio
                                                                                  AND  dfin))
                        GROUP BY   key_cuo, car_reg_year, car_reg_nber) az,
                       transitos.tra_pla_rut bz1,
                       transitos.tra_pla_rut bz2
               WHERE       az.key_cuo = bz2.key_cuo
                       AND az.car_reg_year = bz2.car_reg_year
                       AND az.car_reg_nber = bz2.car_reg_nber
                       AND TRUNC (bz1.tra_fec_ini) BETWEEN (dinicio + 1)
                                                       AND  (dfin - 1)
                       AND bz1.tra_num = 0
                       AND bz1.key_secuencia = 1
                       AND bz1.key_cuo = bz2.key_cuo
                       AND bz1.car_reg_year = bz2.car_reg_year
                       AND bz1.car_reg_nber = bz2.car_reg_nber
                       AND bz2.tra_num = 0
                       AND bz2.key_secuencia = 0
                       AND NOT az.registro_peso IN (a1)
                       AND NOT az.registro_obs IN (b1)
            ORDER BY   key_cuo, car_reg_year, car_reg_nber;

        RETURN ct;
    END;

    /***********************************************************
    * Actualiza plazo(s) Opcion SalidaPuerto y Lista Salida Puerto*
    * Ruben Machaca                               *
    ***********************************************************/
    FUNCTION graba_plazo_etiqueta (keycuo    IN VARCHAR2,
                                   gestion   IN VARCHAR2,
                                   serial    IN DECIMAL,
                                   --el usuario
                                   usucuo    IN VARCHAR2,
                                   usuario   IN VARCHAR2,
                                   peso      IN NUMBER)
        RETURN VARCHAR2
    IS
        i         DECIMAL (3, 0);
        adupar    VARCHAR2 (5) := keycuo;
        fecpar    DATE := SYSDATE;
        adudes    VARCHAR2 (5);
        fecdes    DATE;
        fecest    DATE;
        plazo     DECIMAL (3, 0);
        iplazo    VARCHAR2 (5);
        icamino   DECIMAL (3, 0) := 0;
        isec      NUMBER := 1;
        ietapa    DECIMAL (3, 0) := 0;
        imax      DECIMAL (3, 0);
        version   NUMBER;
        res       VARCHAR2 (100);


        --Para registrar la placa del medio de transporte EJAG 16/11/2015
        vplaca    VARCHAR2 (27);

        CURSOR l_destinos (
            p_keycuo    IN            VARCHAR2,
            p_gestion   IN            VARCHAR2,
            p_serial    IN            DECIMAL)
        IS
              ----- Pendientes -----
              SELECT   a.key_secuencia, a.tra_plazo
                FROM   tra_pla_rut a
               WHERE       a.key_cuo = keycuo
                       AND a.car_reg_year = gestion
                       AND a.car_reg_nber = serial
                       AND a.lst_ope IN ('M', 'U')                      --,'U'
                       AND a.tra_num = 0
                       AND a.key_secuencia > 0
            ORDER BY   a.key_secuencia;
    BEGIN
        --Para registrar la placa del medio de transporte EJAG 16/11/2015
        SELECT   a.car_id_trp
          INTO   vplaca
          FROM   car_gen a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial;

        SELECT   COUNT (1)
          INTO   version
          FROM   tra_pla_rut a
         WHERE       a.key_cuo = keycuo
                 AND a.car_reg_year = gestion
                 AND a.car_reg_nber = serial
                 AND a.lst_ope = 'D'
                 AND a.tra_num = 0;

        IF version > 0
        THEN
            RETURN 'No puede realizar Salida de Puerto, el tr&aacute;nsito est&aacute; cancelado';
        END IF;

        res := valida_verifdocs_spuerto (keycuo, gestion, serial);

        IF (res <> 'OK')
        THEN
            RETURN res;
        END IF;

        FOR des IN l_destinos (keycuo, gestion, serial)
        LOOP
            -- versiona el transito
            SELECT   MAX (tra_num) + 1
              INTO   version
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = des.key_secuencia;

            INSERT INTO tra_pla_rut
                SELECT   a.key_cuo,
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
                         version,
                         a.usr_nam,
                         a.usr_fec
                  FROM   tra_pla_rut a
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND key_secuencia = des.key_secuencia
                         AND tra_num = 0;

            -- Calcula nueva fecha estimada
            fecest := fecpar + (des.tra_plazo / 24);

            UPDATE   tra_pla_rut
               SET   tra_fec_ini = fecpar,
                     tra_fec_est = fecest,
                     tra_obs = 'REGISTRO EN SALIDA DE PUERTO (PESO)',
                     usr_nam = usuario,
                     usr_fec = SYSDATE,
                     lst_ope = 'U'
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = des.key_secuencia
                     AND tra_num = 0;

            fecpar := fecest;
        END LOOP;

        -- Registro de peso de SALIDA de PUERTO
        INSERT INTO tra_micanticipado
          VALUES   (keycuo,
                    gestion,
                    serial,
                    peso,
                    usuario,
                    'U',
                    0,
                    SYSDATE);

        --Para registrar la placa del medio de transporte EJAG 16/11/2015
        placa_inicio (keycuo,
                      gestion,
                      serial,
                      vplaca);
        --Para enviar mensaje al UTIL por inicio de transito
        util_inicio (keycuo,
                     gestion,
                     serial,
                     usuario,
                     '1');

        COMMIT;
        RETURN 'Correcto';
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            RETURN 'El tramo no esta registrado';
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 255);
    END;


    FUNCTION devuelve_estado (prm_keycuo    IN VARCHAR2,
                              prm_gestion   IN VARCHAR2,
                              prm_serial    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (5) := '0';
    BEGIN
        SELECT   a.lst_ope
          INTO   res
          FROM   tra_pla_rut a
         WHERE       a.key_cuo = prm_keycuo
                 AND a.car_reg_year = prm_gestion
                 AND a.car_reg_nber = prm_serial
                 AND a.tra_num = 0
                 AND a.key_secuencia = 1;

        RETURN res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN '0';
    END;


    FUNCTION devuelve_estado_por_dui (prm_keycuo    IN VARCHAR2,
                                      prm_gestion   IN VARCHAR2,
                                      prm_serial    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        res   VARCHAR2 (5) := '0';
    BEGIN
        SELECT   a.lst_ope
          INTO   res
          FROM   tra_pla_rut a
         WHERE       a.key_cuo = prm_keycuo
                 AND a.car_reg_year = prm_gestion
                 AND a.car_reg_nber = prm_serial
                 AND a.tra_num = 0
                 AND a.key_secuencia = 1;

        RETURN res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN '0';
    END;



    FUNCTION transbordo_transito (keycuo      IN     VARCHAR2,
                                  gestion     IN     VARCHAR2,
                                  serial      IN     DECIMAL,
                                  secuencia   IN     DECIMAL,
                                  adudes      IN     VARCHAR2, -- aduana de destino
                                  fecdes      IN     VARCHAR2,
                                  codtrans    IN     VARCHAR2, -- empresa de transporte
                                  placa       IN     VARCHAR2,  -- medio placa
                                  icierre     IN     DECIMAL, -- Tipo de cierre
                                  obs         IN     VARCHAR2,
                                  usuario     IN     VARCHAR2,
                                  ans            OUT VARCHAR2,
                                  tipodoc     IN     VARCHAR2, --documento de destino MIC o TIF
                                  modo        IN     VARCHAR2, --3 CARRETERO 2 FERREO
                                  precintos   IN     VARCHAR2, --NUEVOS PRECINTOS DEL TRANSBORDO
                                  aduandes    IN     VARCHAR2, --ADUANA DE DESTINO DEL MANIFIESTO
                                  obsdes      IN     VARCHAR2,
                                  manyear        OUT VARCHAR2,
                                  mancuo         OUT VARCHAR2,
                                  mannber        OUT VARCHAR2) --OBSERVACION DEL NUEVO INICIO DE TRANSITO
        RETURN VARCHAR2
    IS
        answer                   VARCHAR2 (255);
        maximo                   DECIMAL (3, 0);
        id                       VARCHAR2 (15);
        p_manifiestoregistro     VARCHAR2 (100);
        p_manifiestoreferencia   VARCHAR2 (100);
        medio                    VARCHAR2 (15);
        etapa                    DECIMAL (3, 0) := 0;
        cantidad                 NUMBER;
        aduana_destino           VARCHAR2 (5);
    BEGIN
        etapa := 6;

        -- verifica que no tenga mas de un destino ---
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   (SELECT   DISTINCT carbol_frt_prep
                    FROM   car_bol_gen a, car_gen b
                   WHERE       b.car_reg_year = gestion
                           AND b.car_reg_nber = serial
                           AND a.key_cuo = b.key_cuo
                           AND a.key_voy_nber = b.key_voy_nber
                           AND a.key_dep_date = b.key_dep_date);


        IF (cantidad > 1)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;


        etapa := 7;

        SELECT   DISTINCT carbol_frt_prep
          INTO   aduana_destino
          FROM   car_bol_gen a, car_gen b
         WHERE       b.car_reg_year = gestion
                 AND b.car_reg_nber = serial
                 AND a.key_cuo = b.key_cuo
                 AND a.key_voy_nber = b.key_voy_nber
                 AND a.key_dep_date = b.key_dep_date;



        etapa := 5;

        SELECT   COUNT (1)
          INTO   cantidad
          FROM   unroutab
         WHERE       cuo_sal IN (adudes, aduana_destino)
                 AND cuo_arr IN (adudes, aduana_destino)
                 AND rou_mod = 2
                 AND lst_ope = 'U'
                 AND numver = 0;

        IF (cantidad = 0)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;


        etapa := 0;

        IF (no_ciclico_transbordo (keycuo,
                                   gestion,
                                   serial,
                                   adudes))
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        etapa := 1;
        id := verifica_empresa_habilitada (codtrans);

        IF (maximo = 0)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        etapa := 2;

        IF (NOT (placa = '00000'))
        THEN
            IF (verifica_medio_habilitada (id, placa) = 0)
            THEN
                RAISE NO_DATA_FOUND;
            END IF;
        END IF;

        etapa := 3;

        IF (verifica_medio_pendiente (placa) > 0)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        answer :=
            cierra_todo (keycuo,
                         gestion,
                         serial,
                         secuencia,
                         adudes,
                         fecdes,
                         icierre,
                         obs,
                         usuario);



        IF (answer = 'Correcto')
        THEN
            IF (icierre = btransbordo)
            THEN
                etapa := 4;
                ops$asy.pckmanifiesto.generarmanifiestotransbordo (
                    gestion,
                    keycuo,
                    serial,
                    adudes,
                    icierre,
                    SUBSTR (fecdes, 1, 10),
                    SUBSTR (fecdes, 12, 5),
                    usuario,
                    p_manifiestoregistro,
                    p_manifiestoreferencia,
                    codtrans,
                    placa,
                    tipodoc,
                    modo,
                    precintos,
                    aduandes,
                    obsdes,
                    manyear,
                    mancuo,
                    mannber);
            END IF;

            -- Localizar el manifiesto anterior

            -- Generar el Inicio de Transito del nuevo manifiesto

            answer := 'Correcto';
            ans := RTRIM (p_manifiestoregistro);
            COMMIT;
        END IF;


        RETURN answer;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;

            IF (etapa = 5)
            THEN
                RETURN (   'El tramo '
                        || adudes
                        || ' - '
                        || aduana_destino
                        || ' no esta registrado');
            ELSIF (etapa = 6)
            THEN
                RETURN ('No se puede hacer transbordo si el manifiesto tiene multiples Destinos');
            ELSIF (etapa = 0)
            THEN
                RETURN ('No se puede hacer transbordo en una Aduana Destino');
            ELSIF (etapa = 1)
            THEN
                RETURN ('No esta habilitado la Empresa');
            ELSIF (etapa = 2)
            THEN
                RETURN ('No esta habilitado el Medio de Transporte');
            ELSIF (etapa = 3)
            THEN
                RETURN ('El medio tiene un transito Pendiente');
            ELSE
                RETURN ('No se pudo generar el Manifiesto de Destino');
            END IF;
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR ('Error ' || TO_CHAR (SQLCODE) || ': ' || SQLERRM,
                           1,
                           255);
    END;


    PROCEDURE replica_control_embarque (prm_keycuo24    IN VARCHAR2,
                                        prm_gestion24   IN VARCHAR2,
                                        prm_serial24    IN DECIMAL,
                                        prm_keycuo23    IN VARCHAR2,
                                        prm_gestion23   IN VARCHAR2,
                                        prm_serial23    IN DECIMAL,
                                        prm_usuario     IN VARCHAR2)
    IS
        sw   NUMBER := 0;
    BEGIN
        FOR rs
        IN (SELECT   g.key_cuo,
                     g.key_voy_nber,
                     g.key_dep_date,
                     g.key_bol_ref
              FROM   ops$asy.car_gen a, ops$asy.car_bol_gen g
             WHERE       a.car_reg_year = prm_gestion23
                     AND a.key_cuo = prm_keycuo23
                     AND a.car_reg_nber = prm_serial23
                     AND a.key_cuo = g.key_cuo
                     AND a.key_voy_nber = g.key_voy_nber
                     AND a.key_dep_date = g.key_dep_date)
        LOOP
            IF sw = 0
            THEN
                INSERT INTO tra_inf_manifiesto
                    SELECT   rs.key_cuo,
                             rs.key_voy_nber,
                             rs.key_dep_date,
                             m.man_cantidad,
                             m.man_est_autorizado,
                             prm_usuario,
                             m.man_num,
                             m.lst_ope,
                             SYSDATE
                      FROM   car_gen g, tra_inf_manifiesto m
                     WHERE       g.key_cuo = m.key_cuo
                             AND g.key_voy_nber = m.key_voy_nber
                             AND g.key_dep_date = m.key_dep_date
                             AND m.man_num = 0
                             AND m.lst_ope = 'U'
                             AND g.car_reg_year = prm_gestion24
                             AND g.key_cuo = prm_keycuo24
                             AND g.car_reg_nber = prm_serial24;

                sw := 1;
            END IF;

            INSERT INTO tra_inf_docembarque
                SELECT   rs.key_cuo,
                         rs.key_voy_nber,
                         rs.key_dep_date,
                         rs.key_bol_ref,
                         i.docemb_adm_destino,
                         i.docemb_fecha_embarque,
                         i.docemb_silista_rs1392015,
                         i.docemb_si_pri_rs1692016,
                         i.docemb_si_seg_rs1692016,
                         i.docemb_otras_mercancias,
                         i.docemb_est_autorizado,
                         prm_usuario,
                         i.docemb_num,
                         i.lst_ope,
                         SYSDATE,
                         i.docemb_cantidad_partidas,
                         i.docemb_observacionaut,
                         i.docemb_observacion2295
                  FROM   car_gen g, tra_inf_docembarque i
                 WHERE       g.key_cuo = i.key_cuo
                         AND g.key_voy_nber = i.key_voy_nber
                         AND g.key_dep_date = i.key_dep_date
                         AND i.docemb_num = 0
                         AND i.lst_ope = 'U'
                         AND i.key_bol_ref = rs.key_bol_ref
                         AND g.car_reg_year = prm_gestion24
                         AND g.key_cuo = prm_keycuo24
                         AND g.car_reg_nber = prm_serial24;

            INSERT INTO tra_aut_previa
                SELECT   rs.key_cuo,
                         rs.key_voy_nber,
                         rs.key_dep_date,
                         rs.key_bol_ref,
                         a.apr_ds_autorizacion,
                         a.apr_nro_autorizacion,
                         prm_usuario,
                         a.apr_num,
                         a.apr_lstope,
                         SYSDATE
                  FROM   car_gen g, tra_aut_previa a
                 WHERE       g.key_cuo = a.key_cuo
                         AND g.key_voy_nber = a.key_voy_nber
                         AND g.key_dep_date = a.key_dep_date
                         AND a.apr_num = 0
                         AND a.apr_lstope = 'U'
                         AND a.key_bol_ref = rs.key_bol_ref
                         AND g.car_reg_year = prm_gestion24
                         AND g.key_cuo = prm_keycuo24
                         AND g.car_reg_nber = prm_serial24;
        END LOOP;
    END;
END;
/

