CREATE TABLE tra_pastogrande
    (key_year                       VARCHAR2(4 BYTE),
    key_cuo                        VARCHAR2(3 BYTE),
    key_dec                        VARCHAR2(30 BYTE),
    key_nber                       VARCHAR2(20 BYTE),
    operacion                      VARCHAR2(300 BYTE),
    resultado                      VARCHAR2(300 BYTE),
    usuario                        VARCHAR2(30 BYTE),
    fecha                          DATE)
  NOPARALLEL
  LOGGING
/

