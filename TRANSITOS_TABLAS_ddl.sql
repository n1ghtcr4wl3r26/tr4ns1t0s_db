CREATE GLOBAL TEMPORARY TABLE quest_sl_temp_explain1
    (statement_id                   VARCHAR2(30 BYTE),
    timestamp                      DATE,
    remarks                        VARCHAR2(80 BYTE),
    operation                      VARCHAR2(30 BYTE),
    options                        VARCHAR2(255 BYTE),
    object_node                    VARCHAR2(128 BYTE),
    object_owner                   VARCHAR2(30 BYTE),
    object_name                    VARCHAR2(30 BYTE),
    object_instance                NUMBER,
    object_type                    VARCHAR2(30 BYTE),
    optimizer                      VARCHAR2(255 BYTE),
    search_columns                 NUMBER,
    id                             NUMBER,
    parent_id                      NUMBER,
    position                       NUMBER,
    cost                           NUMBER,
    cardinality                    NUMBER,
    bytes                          NUMBER,
    other_tag                      VARCHAR2(255 BYTE),
    partition_start                VARCHAR2(255 BYTE),
    partition_stop                 VARCHAR2(255 BYTE),
    partition_id                   NUMBER,
    other                          LONG,
    distribution                   VARCHAR2(30 BYTE),
    cpu_cost                       NUMBER(38,0),
    io_cost                        NUMBER(38,0),
    temp_space                     NUMBER(38,0),
    access_predicates              VARCHAR2(4000 BYTE),
    filter_predicates              VARCHAR2(4000 BYTE))
ON COMMIT PRESERVE ROWS
  NOPARALLEL
  NOLOGGING
/

CREATE TABLE sqln_explain_plan
    (statement_id                   VARCHAR2(30 BYTE),
    timestamp                      DATE,
    remarks                        VARCHAR2(80 BYTE),
    operation                      VARCHAR2(30 BYTE),
    options                        VARCHAR2(30 BYTE),
    object_node                    VARCHAR2(128 BYTE),
    object_owner                   VARCHAR2(30 BYTE),
    object_name                    VARCHAR2(30 BYTE),
    object_instance                NUMBER(*,0),
    object_type                    VARCHAR2(30 BYTE),
    optimizer                      VARCHAR2(255 BYTE),
    search_columns                 NUMBER(*,0),
    id                             NUMBER(*,0),
    parent_id                      NUMBER(*,0),
    position                       NUMBER(*,0),
    cost                           NUMBER(*,0),
    cardinality                    NUMBER(*,0),
    bytes                          NUMBER(*,0),
    other_tag                      VARCHAR2(255 BYTE),
    partition_start                VARCHAR2(255 BYTE),
    partition_stop                 VARCHAR2(255 BYTE),
    partition_id                   NUMBER(*,0),
    other                          LONG,
    distribution                   VARCHAR2(30 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE t_config
    (llave                          VARCHAR2(6 BYTE) ,
    valor                          VARCHAR2(1 BYTE))
  NOPARALLEL
  LOGGING
/

ALTER TABLE t_config
ADD CONSTRAINT pk_t_config PRIMARY KEY (llave)
USING INDEX
/

CREATE TABLE t_modpeso
    (key_cuo                        VARCHAR2(5 BYTE) ,
    car_reg_year                   VARCHAR2(4 BYTE) ,
    car_reg_nber                   NUMBER ,
    mod_peso                       NUMBER(18,2),
    mod_usuario                    VARCHAR2(30 BYTE),
    mod_fecreg                     DATE,
    mod_lst_ope                    VARCHAR2(2 BYTE),
    mod_num                        NUMBER(3,0) ,
    mod_fechadif                   DATE,
    mod_horadif                    VARCHAR2(8 BYTE))
  NOPARALLEL
  LOGGING
/

ALTER TABLE t_modpeso
ADD CONSTRAINT pk_t_modpeso PRIMARY KEY (key_cuo, car_reg_year, car_reg_nber, 
  mod_num)
USING INDEX
/

CREATE TABLE tag_logs
    (tag_id                         NUMBER ,
    tag_archivo                    VARCHAR2(125 BYTE) NOT NULL,
    tag_total_item                 NUMBER DEFAULT 0 NOT NULL,
    tag_estado                     NUMBER(1,0) DEFAULT 1 NOT NULL,
    reg_fecha                      DATE DEFAULT sysdate NOT NULL)
  NOPARALLEL
  LOGGING
/

ALTER TABLE tag_logs
ADD CONSTRAINT tag_logs_pk PRIMARY KEY (tag_id)
USING INDEX
/

CREATE OR REPLACE TRIGGER tgr_tag_logs
 BEFORE
  INSERT
 ON tag_logs
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
    tmpvar          NUMBER;
BEGIN
    tmpvar := 0;

    SELECT seq_logs_id.NEXTVAL INTO tmpvar FROM DUAL;

    :new.tag_id := tmpvar;
END tgr_tag_logs;
/

CREATE TABLE tag_logs_detalle
    (tag_id                         NUMBER NOT NULL,
    tag_item                       NUMBER NOT NULL,
    reg_fecha                      DATE DEFAULT sysdate,
    key_cuo                        VARCHAR2(4 BYTE),
    car_reg_year                   VARCHAR2(4 BYTE),
    car_reg_nber                   NUMBER,
    tag_fecha                      DATE,
    tag_imei                       VARCHAR2(30 BYTE),
    tag_tipo                       NUMBER(1,0),
    tag_gen                        NUMBER(1,0),
    tag_usuario                    VARCHAR2(20 BYTE),
    tag_estado                     NUMBER(1,0) DEFAULT -1,
    tag                            VARCHAR2(1000 BYTE))
  NOPARALLEL
  LOGGING
/

ALTER TABLE tag_logs_detalle
ADD CONSTRAINT tag_logs_detalle_pk PRIMARY KEY (tag_id, tag_item)
USING INDEX
/


CREATE TABLE tra_acta
    (key_cuo                        VARCHAR2(5 BYTE),
    car_reg_year                   VARCHAR2(4 BYTE),
    car_reg_nber                   NUMBER,
    key_secuencia                  NUMBER,
    car_car_cod                    VARCHAR2(17 BYTE),
    car_id_trp                     VARCHAR2(27 BYTE),
    tac_acta                       VARCHAR2(25 BYTE),
    tac_estado                     NUMBER(1,0),
    tac_obs                        VARCHAR2(100 BYTE),
    lst_ope                        VARCHAR2(1 BYTE),
    tac_num                        NUMBER(2,0),
    usr_nam                        VARCHAR2(15 BYTE),
    usr_fec                        DATE)
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX pk_acta ON tra_acta
  (
    key_cuo                         ASC,
    car_reg_year                    ASC,
    car_reg_nber                    ASC,
    key_secuencia                   ASC,
    car_car_cod                     ASC,
    car_id_trp                      ASC,
    tac_num                         ASC
  )
NOPARALLEL
LOGGING
/


COMMENT ON COLUMN tra_acta.car_car_cod IS 'Empresa'
/
COMMENT ON COLUMN tra_acta.car_id_trp IS 'Medio'
/
COMMENT ON COLUMN tra_acta.car_reg_nber IS 'Registro'
/
COMMENT ON COLUMN tra_acta.car_reg_year IS 'Gestion'
/
COMMENT ON COLUMN tra_acta.key_cuo IS 'Aduana'
/
COMMENT ON COLUMN tra_acta.key_secuencia IS 'Item'
/
COMMENT ON COLUMN tra_acta.lst_ope IS 'U o D'
/
COMMENT ON COLUMN tra_acta.tac_acta IS 'Acta'
/
COMMENT ON COLUMN tra_acta.tac_estado IS '0:Em Me con TNA, 1:Em TNA, 2:Me TNA, 3:Ninguno TNA'
/
COMMENT ON COLUMN tra_acta.tac_num IS 'Version'
/
COMMENT ON COLUMN tra_acta.tac_obs IS 'Observacion'
/
COMMENT ON COLUMN tra_acta.usr_fec IS 'Fecha'
/
COMMENT ON COLUMN tra_acta.usr_nam IS 'usuario'
/
CREATE TABLE tra_adu_con
    (key_cuo_partida                VARCHAR2(5 BYTE),
    key_cuo_control                VARCHAR2(5 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE tra_arr_deposito
    (key_cuo                        VARCHAR2(5 BYTE) ,
    car_reg_year                   VARCHAR2(4 BYTE) ,
    car_reg_nber                   NUMBER ,
    shd_cod                        VARCHAR2(17 BYTE) ,
    arr_nom_archivo                VARCHAR2(100 BYTE),
    arr_dir_archivo                VARCHAR2(300 BYTE),
    arr_fec_llegada                DATE,
    arr_num                        NUMBER ,
    arr_lstope                     VARCHAR2(1 BYTE),
    arr_usuario                    VARCHAR2(20 BYTE),
    arr_fec                        DATE)
  NOPARALLEL
  LOGGING
/

ALTER TABLE tra_arr_deposito
ADD CONSTRAINT pk_tra_arr_deposito PRIMARY KEY (key_cuo, car_reg_year, 
  car_reg_nber, shd_cod, arr_num)
USING INDEX
/

CREATE TABLE tra_aut_decreto
    (ade_ds_autorizacion            VARCHAR2(20 BYTE),
    ade_fecha_control              DATE,
    ade_usuario                    VARCHAR2(50 BYTE) NOT NULL,
    ade_num                        NUMBER(5,0),
    ade_lstope                     VARCHAR2(1 BYTE) NOT NULL,
    ade_fecreg                     DATE NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE TABLE tra_aut_previa
    (key_cuo                        VARCHAR2(5 BYTE),
    key_voy_nber                   VARCHAR2(17 BYTE),
    key_dep_date                   DATE,
    key_bol_ref                    VARCHAR2(17 BYTE),
    apr_ds_autorizacion            VARCHAR2(20 BYTE),
    apr_nro_autorizacion           VARCHAR2(200 BYTE),
    apr_usuario                    VARCHAR2(50 BYTE) NOT NULL,
    apr_num                        NUMBER(5,0),
    apr_lstope                     VARCHAR2(1 BYTE) NOT NULL,
    apr_fecreg                     DATE NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX idx_tra_aut_previa ON tra_aut_previa
  (
    key_cuo                         ASC,
    key_voy_nber                    ASC,
    key_dep_date                    ASC,
    key_bol_ref                     ASC,
    apr_ds_autorizacion             ASC,
    apr_num                         ASC,
    apr_lstope                      ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE tra_configuracion
    (trc_cod                        NUMBER,
    trc_parametro                  VARCHAR2(20 BYTE),
    trc_valor                      VARCHAR2(100 BYTE),
    trc_descripcion                VARCHAR2(300 BYTE),
    trc_lstope                     VARCHAR2(2 BYTE),
    trc_num                        NUMBER,
    trc_usr                        VARCHAR2(15 BYTE),
    trc_fec                        DATE)
  NOPARALLEL
  LOGGING
/

CREATE TABLE tra_dep_transitorio
    (shd_cod                        VARCHAR2(17 BYTE) ,
    dep_consignee                  VARCHAR2(17 BYTE),
    dep_key_cuo                    VARCHAR2(5 BYTE),
    dep_resolucion                 VARCHAR2(100 BYTE),
    dep_distancia                  NUMBER,
    dep_tiempo                     NUMBER,
    dep_num                        NUMBER ,
    dep_lstope                     VARCHAR2(1 BYTE),
    dep_nam                        VARCHAR2(20 BYTE),
    dep_fec                        DATE)
  NOPARALLEL
  LOGGING
/

ALTER TABLE tra_dep_transitorio
ADD CONSTRAINT pk_dep_transitorio PRIMARY KEY (shd_cod, dep_num)
USING INDEX
/

CREATE TABLE tra_estado
    (key_cuo                        VARCHAR2(5 BYTE),
    car_reg_year                   VARCHAR2(4 BYTE),
    car_reg_nber                   NUMBER,
    key_secuencia                  NUMBER(2,0),
    tra_placa                      VARCHAR2(8 BYTE),
    tra_estado                     NUMBER(2,0),
    tra_num                        NUMBER(2,0))
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX pk_tra_estado ON tra_estado
  (
    key_cuo                         ASC,
    car_reg_year                    ASC,
    car_reg_nber                    ASC,
    key_secuencia                   ASC,
    tra_num                         ASC
  )
NOPARALLEL
LOGGING
/

CREATE INDEX tra_estado_idx ON tra_estado
  (
    tra_placa                       ASC,
    tra_estado                      ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE tra_estado_placa
    (key_cuo                        VARCHAR2(5 BYTE),
    car_reg_year                   VARCHAR2(4 BYTE),
    car_reg_nber                   NUMBER,
    tra_placa                      VARCHAR2(27 BYTE),
    tra_estado                     NUMBER(2,0))
  NOPARALLEL
  LOGGING
/

CREATE TABLE tra_etiqueta
    (key_cuo                        VARCHAR2(5 BYTE) ,
    car_reg_year                   VARCHAR2(4 BYTE) ,
    car_reg_nber                   NUMBER ,
    tra_version                    NUMBER DEFAULT 0 ,
    tra_secuencia                  NUMBER,
    tra_estado                     NUMBER DEFAULT 0,
    tra_usuario                    VARCHAR2(15 BYTE),
    tra_fecha                      DATE DEFAULT SYSDATE,
    tra_tag                        VARCHAR2(1000 BYTE))
  NOPARALLEL
  LOGGING
/

ALTER TABLE tra_etiqueta
ADD CONSTRAINT tra_etiqueta_pk PRIMARY KEY (car_reg_year, car_reg_nber, key_cuo, 
  tra_version)
USING INDEX
/

CREATE TABLE tra_generica
    (tra_aduana                     VARCHAR2(3 BYTE) NOT NULL,
    tra_lugar                      VARCHAR2(30 BYTE) NOT NULL,
    tra_gestion                    VARCHAR2(4 BYTE) NOT NULL,
    tra_inicio                     NUMBER NOT NULL,
    tra_fin                        FLOAT(15) NOT NULL,
    tra_cantidad                   FLOAT(15) NOT NULL,
    tra_solicitud                  VARCHAR2(100 BYTE),
    tra_fdesde                     DATE NOT NULL,
    tra_fvence                     DATE NOT NULL,
    tra_impresora                  NUMBER(*,0) NOT NULL,
    tra_fecha_generacion           DATE NOT NULL,
    tra_usuario                    VARCHAR2(15 BYTE) NOT NULL,
    tra_estado                     VARCHAR2(2 BYTE) NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE TABLE tra_imagenes
    (key_cuo                        VARCHAR2(5 BYTE) ,
    car_reg_year                   VARCHAR2(4 BYTE) ,
    car_reg_nber                   NUMBER ,
    tim_cod                        NUMBER ,
    tim_tipo                       VARCHAR2(50 BYTE),
    tim_direccion                  VARCHAR2(500 BYTE),
    tim_direccion_mini             VARCHAR2(500 BYTE),
    tim_nombre_archivo             VARCHAR2(200 BYTE),
    tim_nombre_archivo_mini        VARCHAR2(200 BYTE),
    lst_ope                        VARCHAR2(1 BYTE),
    tim_num                        NUMBER ,
    usr_nam                        VARCHAR2(20 BYTE),
    usr_fec                        DATE)
  NOPARALLEL
  LOGGING
/

ALTER TABLE tra_imagenes
ADD CONSTRAINT pk_tra_imagenes PRIMARY KEY (key_cuo, car_reg_year, car_reg_nber, 
  tim_cod, tim_num)
USING INDEX
/

CREATE TABLE tra_inf_docembarque
    (key_cuo                        VARCHAR2(5 BYTE) ,
    key_voy_nber                   VARCHAR2(17 BYTE) ,
    key_dep_date                   DATE ,
    key_bol_ref                    VARCHAR2(17 BYTE) ,
    docemb_adm_destino             VARCHAR2(5 BYTE),
    docemb_fecha_embarque          DATE NOT NULL,
    docemb_silista_rs1392015       VARCHAR2(2 BYTE),
    docemb_si_pri_rs1692016        VARCHAR2(2 BYTE),
    docemb_si_seg_rs1692016        VARCHAR2(2 BYTE),
    docemb_otras_mercancias        VARCHAR2(2 BYTE),
    docemb_est_autorizado          VARCHAR2(2 BYTE),
    docemb_usuario                 VARCHAR2(50 BYTE) NOT NULL,
    docemb_num                     NUMBER(5,0) ,
    lst_ope                        VARCHAR2(1 BYTE) NOT NULL,
    docemb_fecreg                  DATE NOT NULL,
    docemb_cantidad_partidas       VARCHAR2(2 BYTE),
    docemb_observacionaut          VARCHAR2(100 BYTE),
    docemb_observacion2295         VARCHAR2(100 BYTE))
  NOPARALLEL
  LOGGING
/

ALTER TABLE tra_inf_docembarque
ADD CONSTRAINT pk_docemb PRIMARY KEY (key_cuo, key_voy_nber, key_dep_date, 
  key_bol_ref, docemb_num)
USING INDEX
/

CREATE TABLE tra_inf_manifiesto
    (key_cuo                        VARCHAR2(5 BYTE) ,
    key_voy_nber                   VARCHAR2(17 BYTE) ,
    key_dep_date                   DATE ,
    man_cantidad                   VARCHAR2(2 BYTE),
    man_est_autorizado             VARCHAR2(10 BYTE),
    man_usuario                    VARCHAR2(50 BYTE) NOT NULL,
    man_num                        NUMBER(5,0) ,
    lst_ope                        VARCHAR2(1 BYTE) NOT NULL,
    man_fecreg                     DATE NOT NULL)
  NOPARALLEL
  LOGGING
/

ALTER TABLE tra_inf_manifiesto
ADD CONSTRAINT pk_man PRIMARY KEY (key_cuo, key_voy_nber, key_dep_date, man_num)
USING INDEX
/

CREATE TABLE tra_justificaciones
    (key_cuo                        VARCHAR2(5 BYTE) NOT NULL,
    car_reg_year                   VARCHAR2(4 BYTE) NOT NULL,
    car_reg_nber                   NUMBER NOT NULL,
    jus_cuo_presentacion           VARCHAR2(5 BYTE) NOT NULL,
    jus_cite                       VARCHAR2(30 BYTE) NOT NULL,
    jus_fec_cite                   DATE NOT NULL,
    jus_hoja_ruta                  VARCHAR2(30 BYTE) NOT NULL,
    jus_causa                      VARCHAR2(100 BYTE) NOT NULL,
    jus_observaciones              VARCHAR2(300 BYTE) NOT NULL,
    jus_documento                  VARCHAR2(500 BYTE),
    jus_lstope                     VARCHAR2(1 BYTE) NOT NULL,
    jus_num                        NUMBER NOT NULL,
    jus_usuario                    VARCHAR2(20 BYTE) NOT NULL,
    jus_fecha                      DATE NOT NULL)
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX tra_justificaciones_idx ON tra_justificaciones
  (
    key_cuo                         ASC,
    car_reg_year                    ASC,
    car_reg_nber                    ASC,
    jus_cuo_presentacion            ASC,
    jus_cite                        ASC,
    jus_num                         ASC
  )
NOPARALLEL
LOGGING
/


CREATE TABLE tra_loc
    (key_cuo                        VARCHAR2(5 BYTE),
    car_reg_year                   VARCHAR2(4 BYTE),
    car_reg_nber                   NUMBER,
    key_secuencia                  NUMBER,
    man_cuo                        VARCHAR2(5 BYTE),
    man_reg_year                   VARCHAR2(4 BYTE),
    man_reg_nber                   NUMBER,
    man_bol_ref                    VARCHAR2(17 BYTE),
    man_fec                        DATE)
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX pk_loc ON tra_loc
  (
    key_cuo                         ASC,
    car_reg_year                    ASC,
    car_reg_nber                    ASC,
    key_secuencia                   ASC,
    man_cuo                         ASC,
    man_reg_year                    ASC,
    man_reg_nber                    ASC,
    man_bol_ref                     ASC
  )
NOPARALLEL
LOGGING
/


COMMENT ON COLUMN tra_loc.car_reg_nber IS 'Nro. registro'
/
COMMENT ON COLUMN tra_loc.car_reg_year IS 'Gestion'
/
COMMENT ON COLUMN tra_loc.key_cuo IS 'Aduana'
/
COMMENT ON COLUMN tra_loc.key_secuencia IS 'Secuencia'
/
COMMENT ON COLUMN tra_loc.man_bol_ref IS 'Doc. embarque'
/
COMMENT ON COLUMN tra_loc.man_cuo IS 'Aduana destino'
/
COMMENT ON COLUMN tra_loc.man_fec IS 'Fecha  lozalizacion'
/
COMMENT ON COLUMN tra_loc.man_reg_nber IS 'Nro. registro destino'
/
COMMENT ON COLUMN tra_loc.man_reg_year IS 'Gestion destino'
/
CREATE TABLE tra_manifiesto_riesgo
    (key_cuo                        VARCHAR2(5 BYTE),
    car_reg_year                   VARCHAR2(4 BYTE),
    car_reg_nber                   NUMBER,
    tmr_fecha_registro             DATE,
    tmr_estado                     VARCHAR2(30 BYTE),
    tmr_lstope                     VARCHAR2(1 BYTE),
    tmr_num                        NUMBER(2,0),
    tmr_usr                        VARCHAR2(15 BYTE),
    tmr_fec                        DATE,
    tmr_resultado                  VARCHAR2(300 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE TABLE tra_micanticipado
    (key_cuo                        VARCHAR2(5 BYTE) NOT NULL,
    car_reg_year                   VARCHAR2(4 BYTE) NOT NULL,
    car_reg_nber                   NUMBER NOT NULL,
    mic_peso                       NUMBER(18,2),
    mic_usuario                    VARCHAR2(30 BYTE) NOT NULL,
    mic_lst_ope                    VARCHAR2(2 BYTE) NOT NULL,
    mic_num                        NUMBER(3,0) NOT NULL,
    mic_fecreg                     DATE NOT NULL)
  NOPARALLEL
  LOGGING
/

ALTER TABLE tra_micanticipado
ADD CONSTRAINT pk_tra_micanticipado PRIMARY KEY (key_cuo, car_reg_year, 
  car_reg_nber, mic_num)
USING INDEX
/

CREATE TABLE tra_notificacion
    (car_car_cod                    VARCHAR2(17 BYTE),
    usr_fec                        DATE)
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX pk_tra_not ON tra_notificacion
  (
    car_car_cod                     ASC,
    usr_fec                         ASC
  )
NOPARALLEL
LOGGING
/


COMMENT ON COLUMN tra_notificacion.car_car_cod IS 'Empresa de transporte'
/
COMMENT ON COLUMN tra_notificacion.usr_fec IS 'fecha'
/
CREATE TABLE tra_pla_rut
    (key_cuo                        VARCHAR2(5 BYTE),
    car_reg_year                   VARCHAR2(4 BYTE),
    car_reg_nber                   NUMBER,
    key_secuencia                  NUMBER(2,0),
    tra_cuo_ini                    VARCHAR2(5 BYTE),
    tra_fec_ini                    DATE,
    tra_cuo_est                    VARCHAR2(5 BYTE),
    tra_fec_est                    DATE,
    tra_pre                        VARCHAR2(100 BYTE),
    tra_plazo                      NUMBER(3,0),
    tra_ruta                       VARCHAR2(4 BYTE),
    tra_cuo_des                    VARCHAR2(5 BYTE),
    tra_fec_des                    DATE,
    tra_tipo                       NUMBER(2,0),
    tra_obs                        VARCHAR2(100 BYTE),
    act_boleta                     VARCHAR2(15 BYTE),
    act_entidad                    VARCHAR2(5 BYTE),
    act_fec_ini                    DATE,
    act_fec_fin                    DATE,
    act_monto                      NUMBER(10,2),
    act_moneda                     VARCHAR2(3 BYTE),
    tra_loc                        NUMBER(1,0) DEFAULT 0,
    tra_estado                     VARCHAR2(1 BYTE),
    lst_ope                        VARCHAR2(1 BYTE),
    tra_num                        NUMBER(2,0),
    usr_nam                        VARCHAR2(15 BYTE),
    usr_fec                        DATE)
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX pk_tra_pla_rut ON tra_pla_rut
  (
    key_cuo                         ASC,
    car_reg_year                    ASC,
    car_reg_nber                    ASC,
    key_secuencia                   ASC,
    tra_num                         ASC
  )
NOPARALLEL
LOGGING
/


COMMENT ON COLUMN tra_pla_rut.act_boleta IS 'Boleta; si la empresa tiene acta de intervesion'
/
COMMENT ON COLUMN tra_pla_rut.act_entidad IS 'Entidad; si la empresa tiene acta de intervesion'
/
COMMENT ON COLUMN tra_pla_rut.act_fec_fin IS 'Fecha superior boleta; si la empresa tiene acta de intervesion'
/
COMMENT ON COLUMN tra_pla_rut.act_fec_ini IS 'Fecha inferior boleta; si la empresa tiene acta de intervesion'
/
COMMENT ON COLUMN tra_pla_rut.act_moneda IS 'Tipo de moneda; si la empresa tiene acta de intervesion'
/
COMMENT ON COLUMN tra_pla_rut.act_monto IS 'Monto; si la empresa tiene acta de intervesion'
/
COMMENT ON COLUMN tra_pla_rut.car_reg_nber IS 'Nro. registro'
/
COMMENT ON COLUMN tra_pla_rut.car_reg_year IS 'Gestion'
/
COMMENT ON COLUMN tra_pla_rut.key_cuo IS 'Aduana'
/
COMMENT ON COLUMN tra_pla_rut.key_secuencia IS 'Secuencia - Si es 0: es el registro de aduana de paso; >0 es la secuania de destinos 1 es el primer destino, 2... asi hasta terminar'
/
COMMENT ON COLUMN tra_pla_rut.lst_ope IS 'U:Vigente; D:Borrado'
/
COMMENT ON COLUMN tra_pla_rut.tra_cuo_des IS 'Aduana de destino efectiva (cuando se hace el cierre)'
/
COMMENT ON COLUMN tra_pla_rut.tra_cuo_est IS 'Aduana de destino estimada'
/
COMMENT ON COLUMN tra_pla_rut.tra_cuo_ini IS 'Aduana de partida'
/
COMMENT ON COLUMN tra_pla_rut.tra_estado IS 'Tramo de recorrido 1: actual 0:no es el actual'
/
COMMENT ON COLUMN tra_pla_rut.tra_fec_des IS 'Fecha de destino efectiva  (cuando se hace el cierre)'
/
COMMENT ON COLUMN tra_pla_rut.tra_fec_est IS 'Fecha de destino estimada'
/
COMMENT ON COLUMN tra_pla_rut.tra_fec_ini IS 'Fecha de partida'
/
COMMENT ON COLUMN tra_pla_rut.tra_loc IS 'Localizacion;0: no esta localizado 1: esta localizado cuando se hace el destino'
/
COMMENT ON COLUMN tra_pla_rut.tra_num IS 'version, 0 la ultima, 1 la primera, 2 la segunda'
/
COMMENT ON COLUMN tra_pla_rut.tra_obs IS 'Observacion'
/
COMMENT ON COLUMN tra_pla_rut.tra_plazo IS 'Plazo codigo'
/
COMMENT ON COLUMN tra_pla_rut.tra_pre IS 'Precintos'
/
COMMENT ON COLUMN tra_pla_rut.tra_ruta IS 'Plazo horas'
/
COMMENT ON COLUMN tra_pla_rut.tra_tipo IS 'Tipo de cierre  (cuando se hace el cierre)'
/
COMMENT ON COLUMN tra_pla_rut.usr_fec IS 'fecha'
/
COMMENT ON COLUMN tra_pla_rut.usr_nam IS 'usuario'
/
CREATE TABLE tra_val_tra
    (tratipo                        NUMBER(2,0),
    tradsc                         VARCHAR2(40 BYTE),
    tvtempcod                      NUMBER(1,0),
    tvtmedtra                      NUMBER(1,0),
    tvtactemp                      NUMBER(1,0),
    tvtactmed                      NUMBER(1,0),
    tvtusuaduini                   NUMBER(1,0),
    tctusuadupas                   NUMBER(1,0),
    tvtusuadudes                   NUMBER(1,0))
  NOPARALLEL
  LOGGING
/

CREATE TABLE tra_variable_manifiesto_riesgo
    (tvr_variable                   VARCHAR2(30 BYTE),
    tvr_valor                      VARCHAR2(50 BYTE),
    key_cuo                        VARCHAR2(5 BYTE),
    car_reg_year                   VARCHAR2(4 BYTE),
    car_reg_nber                   NUMBER,
    tvmr_lstope                    VARCHAR2(1 BYTE),
    tvmr_num                       NUMBER(2,0),
    tvmr_fec                       DATE)
  NOPARALLEL
  LOGGING
/

CREATE TABLE tra_variable_riesgo
    (tvr_variable                   VARCHAR2(30 BYTE) ,
    tvr_valor                      VARCHAR2(50 BYTE) ,
    tvr_estado                     VARCHAR2(30 BYTE),
    tvr_fecha_inicio               DATE,
    tvr_fecha_vencimiento          DATE,
    tvr_observacion                VARCHAR2(300 BYTE),
    tvr_lstope                     VARCHAR2(1 BYTE),
    tvr_num                        NUMBER(2,0) ,
    tvr_usr                        VARCHAR2(15 BYTE),
    tvr_fec                        DATE,
    tvr_criterio                   VARCHAR2(30 BYTE),
    tvr_criterio_otro              VARCHAR2(300 BYTE))
  NOPARALLEL
  LOGGING
/

ALTER TABLE tra_variable_riesgo
ADD CONSTRAINT pk_variable_riesgo PRIMARY KEY (tvr_variable, tvr_valor, tvr_num)
USING INDEX
/

CREATE TABLE tra_variable_riesgo_correo
    (trc_usuario                    VARCHAR2(30 BYTE),
    trc_estado                     VARCHAR2(30 BYTE),
    trc_lstope                     VARCHAR2(1 BYTE),
    trc_num                        NUMBER(2,0),
    trc_usr                        VARCHAR2(30 BYTE),
    trc_fec                        DATE)
  NOPARALLEL
  LOGGING
/

CREATE TABLE uncuoaut_previa
    (key_cuo                        VARCHAR2(5 BYTE),
    lst_ope                        VARCHAR2(1 BYTE),
    usr_cod                        VARCHAR2(20 BYTE),
    fec_reg                        DATE)
  NOPARALLEL
  LOGGING
/

CREATE TABLE unetitab
    (key_cuo                        VARCHAR2(5 BYTE) ,
    tip_impresora                  NUMBER(1,0),
    lst_ope                        VARCHAR2(1 BYTE))
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX sys_c004949 ON unetitab
  (
    key_cuo                         ASC
  )
NOPARALLEL
LOGGING
/


ALTER TABLE unetitab
ADD PRIMARY KEY (key_cuo)
/

CREATE TABLE unroutab
    (rou_cod                        VARCHAR2(5 BYTE),
    rou_des                        VARCHAR2(100 BYTE),
    cuo_sal                        VARCHAR2(5 BYTE),
    cuo_arr                        VARCHAR2(5 BYTE),
    rou_ter                        NUMBER(3,0),
    rou_mod                        VARCHAR2(3 BYTE),
    lst_ope                        VARCHAR2(1 BYTE),
    numver                         NUMBER(1,0),
    usucre                         VARCHAR2(15 BYTE),
    feccre                         DATE)
  NOPARALLEL
  LOGGING
/

CREATE UNIQUE INDEX pk_unroutab ON unroutab
  (
    rou_cod                         ASC,
    numver                          ASC
  )
NOPARALLEL
LOGGING
/


COMMENT ON COLUMN unroutab.cuo_arr IS 'Codigo de aduana (llegada/partida)(uncuotab)'
/
COMMENT ON COLUMN unroutab.cuo_sal IS 'Codigo de aduana (partida/llegada)(uncuotab)'
/
COMMENT ON COLUMN unroutab.feccre IS 'Fecha registro'
/
COMMENT ON COLUMN unroutab.lst_ope IS 'Estado (U:Habilitado; D:Borrado)'
/
COMMENT ON COLUMN unroutab.numver IS 'Version (0:actual)'
/
COMMENT ON COLUMN unroutab.rou_cod IS 'Codigo'
/
COMMENT ON COLUMN unroutab.rou_des IS 'Descripcion'
/
COMMENT ON COLUMN unroutab.rou_mod IS 'Medio de transporte (unmottab)'
/
COMMENT ON COLUMN unroutab.rou_ter IS 'Tiempo horas'
/
COMMENT ON COLUMN unroutab.usucre IS 'Usuario registro'
/
ALTER TABLE tag_logs_detalle
ADD CONSTRAINT tag_logs_detalle_r01 FOREIGN KEY (tag_id)
REFERENCES tag_logs (tag_id)
/
-- End of DDL script for Foreign Key(s)
