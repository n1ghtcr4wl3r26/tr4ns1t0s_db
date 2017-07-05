CREATE UNIQUE INDEX idx_wstraplarut ON tra_pla_rut
  (
    key_cuo                         ASC,
    car_reg_year                    ASC,
    car_reg_nber                    ASC,
    key_secuencia                   ASC,
    lst_ope                         ASC,
    tra_num                         ASC,
    tra_fec_ini                     ASC,
    tra_cuo_est                     ASC,
    tra_cuo_des                     ASC,
    tra_fec_des                     ASC
  )
NOPARALLEL
LOGGING
/

