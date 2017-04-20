CREATE OR REPLACE 
PACKAGE pkg_wstransitosalbo
  IS
  TYPE cursortype IS REF CURSOR;
FUNCTION consulta_transitos(p_aduanaOrigen IN VARCHAR2,
                               p_aduanaDestino IN VARCHAR2,
                               p_fecha_ini IN VARCHAR2,
                               p_fecha_fin IN VARCHAR2,
                               p_usuario IN VARCHAR2,
                               p_mensaje OUT VARCHAR2)
      RETURN cursortype;

FUNCTION cobro_diferido  (P_ADUANAORIGEN     IN     VARCHAR2,
                          P_ADUANADESTINO   IN     VARCHAR2,
                          P_FECHA_INI       IN     VARCHAR2,
                          P_FECHA_FIN       IN     VARCHAR2,
                          P_USUARIO         IN     VARCHAR2,
                          P_MENSAJE        OUT     VARCHAR2)
      RETURN cursortype;

FUNCTION duiLevante (P_SAD_REG_YEAR     IN     SAD_GEN.SAD_REG_YEAR%TYPE,
                     P_KEY_CUO          IN     SAD_GEN.KEY_CUO%TYPE,
                     P_SAD_REG_SERIAL   IN     SAD_GEN.SAD_REG_SERIAL%TYPE,
                     P_SAD_REG_NBER     IN     SAD_GEN.SAD_REG_NBER%TYPE,
                     P_USUARIO          IN     VARCHAR2,
                     P_MENSAJE          OUT    varchar2)

      RETURN cursortype;

FUNCTION duiCourier (p_declarante     IN     SAD_GEN.key_dec%TYPE,
                     P_KEY_CUO        IN     SAD_GEN.KEY_CUO%TYPE,
                     P_f_inicial      IN     VARCHAR2,
                     P_f_final        IN     VARCHAR2,
                     P_USUARIO        IN     VARCHAR2,
                     p_mananio        IN     VARCHAR2,
                     p_manreg         IN     VARCHAR2,
                     p_docemb         IN     VARCHAR2,
                     P_MENSAJE        OUT    VARCHAR2)
    RETURN CURSORTYPE;

FUNCTION MANIFIESTO_23 (P_ADUANADESTINO   IN     VARCHAR2,
                                P_FECHA_INI       IN     VARCHAR2,
                                P_FECHA_FIN       IN     VARCHAR2,
                                P_USUARIO         IN     VARCHAR2,
                                P_MENSAJE            OUT VARCHAR2)
    RETURN CURSORTYPE;

FUNCTION CONSULTA_ORIGEN_DAB (P_ADUANAORIGEN        IN     VARCHAR2,
                                P_GESTION           IN     VARCHAR2,
                                P_REGISTRO          IN     VARCHAR2,
                                P_IDENTIFICADOR     IN     VARCHAR2,
                                P_MENSAJE           OUT    VARCHAR2)
    RETURN CURSORTYPE;

FUNCTION CONSULTA_DESTINO_DAB (P_ADUANAORIGEN        IN     VARCHAR2,
                                P_GESTION           IN     VARCHAR2,
                                P_REGISTRO          IN     VARCHAR2,
                                P_IDENTIFICADOR     IN     VARCHAR2,
                                P_MENSAJE           OUT    VARCHAR2)
      RETURN CURSORTYPE;

FUNCTION CONSULTA_ARRIBADOS (P_ADUANAORIGEN    IN     VARCHAR2,
                                P_ADUANADESTINO   IN     VARCHAR2,
                                P_FECHA_INI       IN     VARCHAR2,
                                P_FECHA_FIN       IN     VARCHAR2,
                                P_USUARIO         IN     VARCHAR2,
                                P_MENSAJE            OUT VARCHAR2)
      RETURN CURSORTYPE;

FUNCTION duilevantedab (
        p_sad_reg_year     IN     sad_gen.sad_reg_year%TYPE,
        p_key_cuo          IN     sad_gen.key_cuo%TYPE,
        p_sad_reg_serial   IN     sad_gen.sad_reg_serial%TYPE,
        p_sad_reg_nber     IN     sad_gen.sad_reg_nber%TYPE,
        p_identificador    IN     VARCHAR2,
        p_mensaje             OUT VARCHAR2)
        RETURN cursortype;

FUNCTION manifiesto_imp (p_aduanadestino   IN     VARCHAR2,
                          p_fecha_ini       IN     VARCHAR2,
                          p_fecha_fin       IN     VARCHAR2,
                          p_identificador   IN     VARCHAR2,
                          p_opcion          IN     VARCHAR2,
                          p_mensaje         OUT    VARCHAR2)
        RETURN cursortype;

FUNCTION destino_dab_rango (p_aduanadestino   IN     VARCHAR2,
                                p_f_inicio        IN     VARCHAR2,
                                p_f_fin           IN     VARCHAR2,
                                p_identificador   IN     VARCHAR2,
                                p_mensaje         OUT    VARCHAR2)
        RETURN cursortype;
END pkg_wstransitosalbo;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_wstransitosalbo
/* Formatted on 27/11/2014 21:32:25 (QP5 v5.126) */
IS
    --Modificado Edgar 27112014 Nuevo OCE
    v_fecha_corte   CONSTANT DATE := TO_DATE ('15/12/2015', 'dd/mm/yyyy');


    FUNCTION CONSULTA_TRANSITOS (P_ADUANAORIGEN    IN     VARCHAR2,
                                P_ADUANADESTINO   IN     VARCHAR2,
                                P_FECHA_INI       IN     VARCHAR2,
                                P_FECHA_FIN       IN     VARCHAR2,
                                P_USUARIO         IN     VARCHAR2,
                                P_MENSAJE            OUT VARCHAR2)
      RETURN CURSORTYPE
   IS
      CD          CURSORTYPE;
      V_USU       VARCHAR2 (20);
      V_ADUDEST   VARCHAR2 (5);
      V           NUMBER;
      CONT        NUMBER;
      v_fecha_ini DATE := TO_DATE(p_fecha_ini,'DD/MM/YYYY');
      v_fecha_fin DATE := TO_DATE(p_fecha_fin,'DD/MM/YYYY');
   BEGIN
      V_USU := SUBSTR (UPPER (P_USUARIO), 1, 3);
      V_ADUDEST := P_ADUANADESTINO;

      P_MENSAJE := 'NO';

      -- VERIFICA EXISTENCIA DE USUARIO
      SELECT COUNT (1)
        INTO CONT
        FROM usuario.usuario
       WHERE usucodusu = UPPER (P_USUARIO) AND usu_num = 0 AND lst_ope = 'U';

      IF CONT = 0
      THEN
         P_MENSAJE := 'Error, Usuario incorrecto';

         OPEN CD FOR
            SELECT *
              FROM DUAL
             WHERE 1 = 0;

         RETURN CD;
      END IF;

      IF LENGTH (V_ADUDEST) <= 1
      THEN
         V_ADUDEST := '';
      END IF;

      IF v_fecha_fin >= v_fecha_ini + 2
        THEN
            p_mensaje := 'Error, rango de fecha no permitido';
            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;
            RETURN cd;
        END IF;

      -- VERIFICA que el usuario sea de la concesion, y que la aduana consultada es permitida para esa concesion
      IF V_USU = 'ALB'
      THEN
         IF (   P_ADUANADESTINO = '101'
             OR P_ADUANADESTINO = '211'
             OR P_ADUANADESTINO = '301'
             OR P_ADUANADESTINO = '421'
             OR P_ADUANADESTINO = '422'
             OR P_ADUANADESTINO = '521'
             OR P_ADUANADESTINO = '543'
             OR P_ADUANADESTINO = '621'
             OR P_ADUANADESTINO = '641'
             OR P_ADUANADESTINO = '701'
             OR P_ADUANADESTINO = '711')
         THEN
            OPEN CD FOR
                 /*SELECT DISTINCT
                        CG.KEY_CUO || ': ' || B.CUO_NAM ADUANAORIGEN,
                           CG.KEY_CUO
                        || ' '
                        || CG.CAR_REG_YEAR
                        || ' '
                        || CG.CAR_REG_NBER
                           REGISTROMANIFIESTO,
                        to_char(a.tra_fec_ini,'dd/mm/yyyy HH24:mi:ss') fechainicio,
                        CG.CAR_ID_TRP NUMEROPLACA,
                        CG.CAR_CAR_COD IDENTIFICACIONEMPRESA,
                        CG.CAR_CAR_NAM NOMBREEMPRESA,
                        CG.CAR_PAC_NBER TOTALBULTOS,
                        CG.CAR_REG_DATE FECHAREGISTRO,
                        CG.CAR_REG_TIME HORAREGISTRO,
                        CG.CAR_GROS_MASS PESOBRUTOTOTAL,
                        CBG.KEY_BOL_REF DOCEMBARQUE, --c.cuo_cod aduanaDestino,
                    cbg.key_lin_nbr||'/'||cbg.carbol_sline_nber nroitem,
                        CBG.CARBOL_FRT_PREP ADUANADESTINO,
                        C.CUO_NAM DESCRIPCIONADUANA,
                        CBG.CARBOL_GROS_MAS PESOBRUTO,
                        CBG.CARBOL_PACK_NBER CANTIDADBULTOS,
                        CBG.CARBOL_PACK_COD TIPOBULTOS,
                           NVL (CBG.CARBOL_SEAL_MRKS1, '-')
                        || ' '
                        || NVL (CBG.CARBOL_SEAL_MRKS2, '-')
                        || '/'
                        || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) MARCABULTOS,
                        NVL (CBG.CARBOL_CONS_COD, '-')
                           IDENTIFICACIONCONSIGNATARIO,
                        NVL (CBG.CARBOL_CONS_NAM, '-') NOMBRECONSIGNATARIO,
                           NVL (CBG.CARBOL_GOOD1, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD2, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD3, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD4, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD5, ' ')
                           DESCRIPCIONMERCANCIA,
                        cbg.carbol_infos1||'-'||cbg.carbol_infos2 doc_anexos,
                        ctn.car_ctn_nbr nrocontenedor,
                        nvl(ctn.car_ctn_ident,'-') precintocont,
                        nvl(ctn.car_ctn_typ,'-') clasificacion
                   --case when ROUND (a.tra_fec_est - SYSDATE) < 0 then -1 else ROUND (a.tra_fec_est - SYSDATE) end as plazo
                   FROM TRANSITOS.TRA_PLA_RUT A,
                        OPS$ASY.UNCUOTAB B,
                        OPS$ASY.UNCUOTAB C,
                        OPS$ASY.UNCUOTAB D,
                        OPS$ASY.CAR_GEN CG,
                        OPS$ASY.CAR_BOL_GEN CBG,
                    OPS$ASY.car_bol_ctn ctn
                  WHERE     A.KEY_CUO = CG.KEY_CUO
                        AND A.CAR_REG_YEAR = CG.CAR_REG_YEAR
                        AND A.CAR_REG_NBER = CG.CAR_REG_NBER
                        AND CG.KEY_CUO = CBG.KEY_CUO
                        AND CG.KEY_VOY_NBER = CBG.KEY_VOY_NBER
                        AND CG.KEY_DEP_DATE = CBG.KEY_DEP_DATE
                    and cbg.carbol_nat_cod='24'

                        and cbg.key_cuo = ctn.key_cuo(+)
                        and cbg.key_voy_nber = ctn.key_voy_nber(+)
                        and cbg.key_dep_date = ctn.key_dep_date(+)
                        and cbg.key_bol_ref = ctn.key_bol_ref(+)
                        and cbg.key_lin_nbr = ctn.key_lin_nbr(+)
                        AND CG.KEY_CUO LIKE '%' || P_ADUANAORIGEN
                        AND CBG.CARBOL_FRT_PREP = P_ADUANADESTINO
                        AND A.TRA_FEC_INI BETWEEN TO_DATE (P_FECHA_INI, 'dd/mm/yyyy HH24:mi:ss') AND TO_DATE (P_FECHA_FIN, 'dd/mm/yyyy HH24:mi:ss')
                        --AND trunc(a.tra_fec_ini) BETWEEN TO_DATE (p_fecha_ini,'dd/mm/yyyy') AND TO_DATE (p_fecha_fin,'dd/mm/yyyy')
                        AND CG.KEY_CUO = B.CUO_COD
                        AND B.LST_OPE = 'U'
                        AND CBG.CARBOL_FRT_PREP = C.CUO_COD
                        AND C.LST_OPE = 'U'
                        AND A.TRA_CUO_DES = D.CUO_COD(+)
                        AND D.LST_OPE(+) = 'U'
                        AND A.TRA_NUM = 0
                        AND A.LST_OPE = 'U'
                        AND A.KEY_SECUENCIA > 0
                        AND A.TRA_FEC_DES IS NULL
                        and a.tra_cuo_est = CBG.CARBOL_FRT_PREP
               ORDER BY    CG.KEY_CUO
                        || ' '
                        || CG.CAR_REG_YEAR
                        || ' '
                        || CG.CAR_REG_NBER,
                        CBG.KEY_BOL_REF; */
               SELECT DISTINCT
                    CG.KEY_CUO || ': ' || B.CUO_NAM ADUANAORIGEN,
                       CG.KEY_CUO
                    || ' '
                    || CG.CAR_REG_YEAR
                    || ' '
                    || CG.CAR_REG_NBER
                       REGISTROMANIFIESTO,
                     --to_char(a.tra_fec_ini,'dd/mm/yyyy HH24:mi:ss') fechainicio,
                    CG.CAR_ID_TRP NUMEROPLACA,
                    CG.CAR_CAR_COD IDENTIFICACIONEMPRESA,
                    CG.CAR_CAR_NAM NOMBREEMPRESA,
                    CG.CAR_PAC_NBER TOTALBULTOS,
                    CG.CAR_REG_DATE FECHAREGISTRO,
                    CG.CAR_REG_TIME HORAREGISTRO,
                    CG.CAR_GROS_MASS PESOBRUTOTOTAL,
                    CBG.KEY_BOL_REF DOCEMBARQUE, --c.cuo_cod aduanaDestino,
                    cbg.key_lin_nbr||'/'||cbg.carbol_sline_nber nroitem,
                    CBG.CARBOL_FRT_PREP ADUANADESTINO,
                    C.CUO_NAM DESCRIPCIONADUANA,
                    CBG.CARBOL_GROS_MAS PESOBRUTO,
                    CBG.CARBOL_PACK_NBER CANTIDADBULTOS,
                    CBG.CARBOL_PACK_COD TIPOBULTOS,
                       NVL (CBG.CARBOL_SEAL_MRKS1, '-')
                    || ' '
                    || NVL (CBG.CARBOL_SEAL_MRKS2, '-')
                    || '/'
                    || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) MARCABULTOS,
                    NVL (CBG.CARBOL_CONS_COD, '-')
                       IDENTIFICACIONCONSIGNATARIO,
                    NVL (CBG.CARBOL_CONS_NAM, '-') NOMBRECONSIGNATARIO,
                       NVL (CBG.CARBOL_GOOD1, ' ')
                    || '.'
                    || NVL (CBG.CARBOL_GOOD2, ' ')
                    || '.'
                    || NVL (CBG.CARBOL_GOOD3, ' ')
                    || '.'
                    || NVL (CBG.CARBOL_GOOD4, ' ')
                    || '.'
                    || NVL (CBG.CARBOL_GOOD5, ' ')
                       DESCRIPCIONMERCANCIA,
                    cbg.carbol_infos1||'-'||cbg.carbol_infos2 doc_anexos,
                    ctn.car_ctn_nbr nrocontenedor,
                    nvl(ctn.car_ctn_ident,'-') precintocont,
                    nvl(ctn.car_ctn_typ,'-') clasificacion
               --case when ROUND (a.tra_fec_est - SYSDATE) < 0 then -1 else ROUND (a.tra_fec_est - SYSDATE) end as plazo
               FROM --TRANSITOS.TRA_PLA_RUT A,
                    OPS$ASY.UNCUOTAB B,
                    OPS$ASY.UNCUOTAB C,
                    OPS$ASY.CAR_GEN CG,
                    OPS$ASY.CAR_BOL_GEN CBG, ops$asy.car_bol_ope cbo, transitos.tra_estado_placa e,
                    OPS$ASY.car_bol_ctn ctn
              WHERE     CG.KEY_CUO = CBG.KEY_CUO
                    AND CG.KEY_VOY_NBER = CBG.KEY_VOY_NBER
                    AND CG.KEY_DEP_DATE = CBG.KEY_DEP_DATE
                    and cbg.carbol_nat_cod='24'

                    AND cbg.key_cuo = cbo.key_cuo
                    AND cbg.key_voy_nber = cbo.key_voy_nber
                    AND cbg.key_dep_date = cbo.key_dep_date
                    AND cbg.key_bol_ref = cbo.key_bol_ref
                    AND to_char(cbo.car_ope_dat, 'yyyymmdd') || replace(cbo.car_ope_hor, ':', '') =
                    (SELECT MAX(to_char(b.car_ope_dat, 'yyyymmdd') || replace(b.car_ope_hor, ':', ''))
                       FROM CAR_BOL_OPE B
                      WHERE B.key_cuo = cbo.key_cuo
                        AND B.key_voy_nber = cbo.KEY_VOY_NBER
                        AND B.key_dep_date = cbo.KEY_DEP_DATE
                        AND B.key_bol_ref = cbo.KEY_BOL_REF)
                    AND cbo.car_pkg_avl > 0
                    AND cbo.car_wgt_avl > 0

                    and cbg.key_cuo = ctn.key_cuo(+)
                    and cbg.key_voy_nber = ctn.key_voy_nber(+)
                    and cbg.key_dep_date = ctn.key_dep_date(+)
                    and cbg.key_bol_ref = ctn.key_bol_ref(+)
                    and cbg.key_lin_nbr = ctn.key_lin_nbr(+)
                    AND CG.KEY_CUO LIKE '%' || P_ADUANAORIGEN
                    AND CBG.CARBOL_FRT_PREP = P_ADUANADESTINO
                    AND cg.car_reg_date BETWEEN TO_DATE (p_fecha_ini, 'dd/mm/yyyy') AND TO_DATE (p_fecha_fin, 'dd/mm/yyyy')
                    AND CG.KEY_CUO = B.CUO_COD
                    AND B.LST_OPE = 'U'
                    AND CBG.CARBOL_FRT_PREP = C.CUO_COD
                    AND C.LST_OPE = 'U'

                    and cg.key_cuo = e.key_cuo
                    and cg.car_reg_year = e.car_reg_year
                    and cg.car_reg_nber = e.car_reg_nber
              ORDER BY    CG.KEY_CUO
                    || ' '
                    || CG.CAR_REG_YEAR
                    || ' '
                    || CG.CAR_REG_NBER,
                    CBG.KEY_BOL_REF;

                    P_MENSAJE := 'OK';
         ELSIF V_ADUDEST IS NULL
         THEN
            OPEN CD FOR
                 /*SELECT DISTINCT
                        CG.KEY_CUO || ': ' || B.CUO_NAM ADUANAORIGEN,
                           CG.KEY_CUO
                        || ' '
                        || CG.CAR_REG_YEAR
                        || ' '
                        || CG.CAR_REG_NBER
                           REGISTROMANIFIESTO,
                        to_char(a.tra_fec_ini,'dd/mm/yyyy HH24:mi:ss') fechainicio,
                        CG.CAR_ID_TRP NUMEROPLACA,
                        CG.CAR_CAR_COD IDENTIFICACIONEMPRESA,
                        CG.CAR_CAR_NAM NOMBREEMPRESA,
                        CG.CAR_PAC_NBER TOTALBULTOS,
                        CG.CAR_REG_DATE FECHAREGISTRO,
                        CG.CAR_REG_TIME HORAREGISTRO,
                        CG.CAR_GROS_MASS PESOBRUTOTOTAL,
                        CBG.KEY_BOL_REF DOCEMBARQUE, --c.cuo_cod aduanaDestino,
                        cbg.key_lin_nbr||'/'||cbg.carbol_sline_nber nroitem,
                        CBG.CARBOL_FRT_PREP ADUANADESTINO,
                        C.CUO_NAM DESCRIPCIONADUANA,
                        CBG.CARBOL_GROS_MAS PESOBRUTO,
                        CBG.CARBOL_PACK_NBER CANTIDADBULTOS,
                        CBG.CARBOL_PACK_COD TIPOBULTOS,
                           NVL (CBG.CARBOL_SEAL_MRKS1, '-')
                        || ' '
                        || NVL (CBG.CARBOL_SEAL_MRKS2, '-')
                        || '/'
                        || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) MARCABULTOS,
                        NVL (CBG.CARBOL_CONS_COD, '-')
                           IDENTIFICACIONCONSIGNATARIO,
                        NVL (CBG.CARBOL_CONS_NAM, '-') NOMBRECONSIGNATARIO,
                           NVL (CBG.CARBOL_GOOD1, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD2, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD3, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD4, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD5, ' ')
                           DESCRIPCIONMERCANCIA,
                        cbg.carbol_infos1||'-'||cbg.carbol_infos2 doc_anexos,
                        ctn.car_ctn_nbr nrocontenedor,
                        nvl(ctn.car_ctn_ident,'-') precintocont,
                        nvl(ctn.car_ctn_typ,'-') clasificacion
                   --case when ROUND (a.tra_fec_est - SYSDATE) < 0 then -1 else ROUND (a.tra_fec_est - SYSDATE) end as plazo
                   FROM TRANSITOS.TRA_PLA_RUT A,
                        OPS$ASY.UNCUOTAB B,
                        OPS$ASY.UNCUOTAB C,
                        OPS$ASY.UNCUOTAB D,
                        OPS$ASY.CAR_GEN CG,
                        OPS$ASY.CAR_BOL_GEN CBG,
                    OPS$ASY.car_bol_ctn ctn
                  WHERE     A.KEY_CUO = CG.KEY_CUO
                        AND A.CAR_REG_YEAR = CG.CAR_REG_YEAR
                        AND A.CAR_REG_NBER = CG.CAR_REG_NBER
                        AND CG.KEY_CUO = CBG.KEY_CUO
                        AND CG.KEY_VOY_NBER = CBG.KEY_VOY_NBER
                        AND CG.KEY_DEP_DATE = CBG.KEY_DEP_DATE
                    and cbg.carbol_nat_cod='24'

                        and cbg.key_cuo = ctn.key_cuo(+)
                        and cbg.key_voy_nber = ctn.key_voy_nber(+)
                        and cbg.key_dep_date = ctn.key_dep_date(+)
                        and cbg.key_bol_ref = ctn.key_bol_ref(+)
                        and cbg.key_lin_nbr = ctn.key_lin_nbr(+)
                        AND CG.KEY_CUO LIKE '%' || P_ADUANAORIGEN
                        AND CBG.CARBOL_FRT_PREP IN
                               ('101',
                                '211',
                                '301',
                                '421',
                                '422',
                                '521',
                                '543',
                                '621',
                                '641',
                                '701',
                                '711')
                        --AND trunc(a.tra_fec_ini) BETWEEN to_date(p_fecha_ini, 'dd/mm/yyyy') AND to_date(p_fecha_fin, 'dd/mm/yyyy')
                        AND A.TRA_FEC_INI BETWEEN TO_DATE (P_FECHA_INI, 'dd/mm/yyyy HH24:mi:ss') AND TO_DATE (P_FECHA_FIN, 'dd/mm/yyyy HH24:mi:ss')
                        AND CG.KEY_CUO = B.CUO_COD
                        AND B.LST_OPE = 'U'
                        AND CBG.CARBOL_FRT_PREP = C.CUO_COD
                        AND C.LST_OPE = 'U'
                        AND A.TRA_CUO_DES = D.CUO_COD(+)
                        AND D.LST_OPE(+) = 'U'
                        AND A.TRA_NUM = 0
                        AND A.LST_OPE = 'U'
                        AND A.KEY_SECUENCIA > 0
                        AND A.TRA_FEC_DES IS NULL
                        and a.tra_cuo_est = CBG.CARBOL_FRT_PREP
                 ORDER BY    CG.KEY_CUO
                        || ' '
                        || CG.CAR_REG_YEAR
                        || ' '
                        || CG.CAR_REG_NBER,
                        CBG.KEY_BOL_REF;*/

                 SELECT DISTINCT
                        CG.KEY_CUO || ': ' || B.CUO_NAM ADUANAORIGEN,
                           CG.KEY_CUO
                        || ' '
                        || CG.CAR_REG_YEAR
                        || ' '
                        || CG.CAR_REG_NBER
                           REGISTROMANIFIESTO,
                        --to_char(a.tra_fec_ini,'dd/mm/yyyy HH24:mi:ss') fechainicio,
                        CG.CAR_ID_TRP NUMEROPLACA,
                        CG.CAR_CAR_COD IDENTIFICACIONEMPRESA,
                        CG.CAR_CAR_NAM NOMBREEMPRESA,
                        CG.CAR_PAC_NBER TOTALBULTOS,
                        CG.CAR_REG_DATE FECHAREGISTRO,
                        CG.CAR_REG_TIME HORAREGISTRO,
                        CG.CAR_GROS_MASS PESOBRUTOTOTAL,
                        CBG.KEY_BOL_REF DOCEMBARQUE, --c.cuo_cod aduanaDestino,
                        cbg.key_lin_nbr||'/'||cbg.carbol_sline_nber nroitem,
                        CBG.CARBOL_FRT_PREP ADUANADESTINO,
                        C.CUO_NAM DESCRIPCIONADUANA,
                        CBG.CARBOL_GROS_MAS PESOBRUTO,
                        CBG.CARBOL_PACK_NBER CANTIDADBULTOS,
                        CBG.CARBOL_PACK_COD TIPOBULTOS,
                           NVL (CBG.CARBOL_SEAL_MRKS1, '-')
                        || ' '
                        || NVL (CBG.CARBOL_SEAL_MRKS2, '-')
                        || '/'
                        || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) MARCABULTOS,
                        NVL (CBG.CARBOL_CONS_COD, '-')
                           IDENTIFICACIONCONSIGNATARIO,
                        NVL (CBG.CARBOL_CONS_NAM, '-') NOMBRECONSIGNATARIO,
                           NVL (CBG.CARBOL_GOOD1, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD2, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD3, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD4, ' ')
                        || '.'
                        || NVL (CBG.CARBOL_GOOD5, ' ')
                           DESCRIPCIONMERCANCIA,
                        cbg.carbol_infos1||'-'||cbg.carbol_infos2 doc_anexos,
                        ctn.car_ctn_nbr nrocontenedor,
                        nvl(ctn.car_ctn_ident,'-') precintocont,
                        nvl(ctn.car_ctn_typ,'-') clasificacion
                   --case when ROUND (a.tra_fec_est - SYSDATE) < 0 then -1 else ROUND (a.tra_fec_est - SYSDATE) end as plazo
                   FROM OPS$ASY.UNCUOTAB B,
                        OPS$ASY.UNCUOTAB C,
                        OPS$ASY.CAR_GEN CG,
                        OPS$ASY.CAR_BOL_GEN CBG, ops$asy.car_bol_ope cbo, transitos.tra_estado_placa e,
                        OPS$ASY.car_bol_ctn ctn
                  WHERE     CG.KEY_CUO = CBG.KEY_CUO
                        AND CG.KEY_VOY_NBER = CBG.KEY_VOY_NBER
                        AND CG.KEY_DEP_DATE = CBG.KEY_DEP_DATE
                        and cbg.carbol_nat_cod='24'
                        AND cbg.key_cuo = cbo.key_cuo
                        AND cbg.key_voy_nber = cbo.key_voy_nber
                        AND cbg.key_dep_date = cbo.key_dep_date
                        AND cbg.key_bol_ref = cbo.key_bol_ref
                        AND to_char(cbo.car_ope_dat, 'yyyymmdd') || replace(cbo.car_ope_hor, ':', '') =
                        (SELECT MAX(to_char(b.car_ope_dat, 'yyyymmdd') || replace(b.car_ope_hor, ':', ''))
                           FROM CAR_BOL_OPE B
                          WHERE B.key_cuo = cbo.key_cuo
                            AND B.key_voy_nber = cbo.KEY_VOY_NBER
                            AND B.key_dep_date = cbo.KEY_DEP_DATE
                            AND B.key_bol_ref = cbo.KEY_BOL_REF)
                        AND cbo.car_pkg_avl > 0
                        AND cbo.car_wgt_avl > 0

                        and cbg.key_cuo = ctn.key_cuo(+)
                        and cbg.key_voy_nber = ctn.key_voy_nber(+)
                        and cbg.key_dep_date = ctn.key_dep_date(+)
                        and cbg.key_bol_ref = ctn.key_bol_ref(+)
                        and cbg.key_lin_nbr = ctn.key_lin_nbr(+)
                        AND CG.KEY_CUO LIKE '%' || P_ADUANAORIGEN
                        AND CBG.CARBOL_FRT_PREP IN
                               ('101',
                                '211',
                                '301',
                                '421',
                                '422',
                                '521',
                                '543',
                                '621',
                                '641',
                                '701',
                                '711')
                        AND cg.car_reg_date BETWEEN TO_DATE (P_FECHA_INI, 'dd/mm/yyyy') AND TO_DATE (P_FECHA_FIN, 'dd/mm/yyyy')
                        AND CG.KEY_CUO = B.CUO_COD
                        AND B.LST_OPE = 'U'
                        AND CBG.CARBOL_FRT_PREP = C.CUO_COD
                        AND C.LST_OPE = 'U'

                        and cg.key_cuo = e.key_cuo
                        and cg.car_reg_year = e.car_reg_year
                        and cg.car_reg_nber = e.car_reg_nber
               ORDER BY    CG.KEY_CUO
                        || ' '
                        || CG.CAR_REG_YEAR
                        || ' '
                        || CG.CAR_REG_NBER,
                        CBG.KEY_BOL_REF;

            P_MENSAJE := 'OK';
         ELSE
            OPEN CD FOR
               SELECT ''
                 FROM DUAL
                WHERE 1 = 0;

            p_mensaje := 'Aduana destino no corresponde a su concesion.';
         END IF;
      ELSE
         OPEN CD FOR
            SELECT ''
              FROM DUAL
             WHERE 1 = 0;

         p_mensaje := 'Error: Usuario no corresponde a su concesion';
      END IF;

      RETURN CD;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         OPEN CD FOR
            SELECT ''
              FROM DUAL
             WHERE 1 = 1;

         p_mensaje := 'No existen transitos pendientes';
         RETURN CD;
      WHEN OTHERS
      THEN
         OPEN CD FOR
            SELECT ''
              FROM DUAL
             WHERE 1 = 0;

         p_mensaje := 'Error desconocido';
         RETURN CD;
   END CONSULTA_TRANSITOS;

    FUNCTION cobro_diferido (p_aduanaorigen    IN     VARCHAR2,
                             p_aduanadestino   IN     VARCHAR2,
                             p_fecha_ini       IN     VARCHAR2,
                             p_fecha_fin       IN     VARCHAR2,
                             p_usuario         IN     VARCHAR2,
                             p_mensaje            OUT VARCHAR2)
        RETURN cursortype
    IS
        cd          cursortype;
        v_usu       VARCHAR2 (20);
        v_adudest   VARCHAR2 (5);
        cont        NUMBER;
        v           NUMBER;
        v_fecha_ini DATE := TO_DATE(p_fecha_ini,'DD/MM/YYYY');
        v_fecha_fin DATE := TO_DATE(p_fecha_fin,'DD/MM/YYYY');
    BEGIN
        v_usu := SUBSTR (UPPER (p_usuario), 1, 3);
        v_adudest := p_aduanadestino;

        p_mensaje := 'NO';

        -- VERIFICA EXISTENCIA DE USUARIO
        SELECT   COUNT (1)
          INTO   cont
          FROM   usuario.usuario
         WHERE       usucodusu = UPPER (p_usuario)
                 AND usu_num = 0
                 AND lst_ope = 'U';

        IF cont = 0
        THEN
            p_mensaje := 'Error, Usuario incorrecto';

            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF LENGTH (v_adudest) <= 1
        THEN
            v_adudest := '';
        END IF;

        IF v_fecha_fin >= v_fecha_ini + 2
        THEN
            p_mensaje := 'Error, rango de fecha no permitido';
            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;
            RETURN cd;
        END IF;

        -- VERIFICA que el usuario sea de la concesion, y que la aduana consultada es permitida para esa concesion
        IF v_usu = 'ALB'
        THEN
            IF (   p_aduanaorigen = '101'
                OR p_aduanaorigen = '211'
                OR p_aduanaorigen = '301'
                OR p_aduanaorigen = '421'
                OR p_aduanaorigen = '422'
                OR p_aduanaorigen = '521'
                OR p_aduanaorigen = '543'
                OR p_aduanaorigen = '621'
                OR p_aduanaorigen = '641'
                OR p_aduanaorigen = '701'
                OR p_aduanaorigen = '711')
            THEN
                OPEN cd FOR
                      /*SELECT   DISTINCT
                               cg.key_cuo || ': ' || b.cuo_nam aduanaorigen,
                                  cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber
                                   registromanifiesto,
                               to_char(a.tra_fec_ini,'dd/mm/yyyy HH24:mi:ss') fechainicio,
                               cg.car_id_trp numeroplaca,
                               cg.car_car_cod identificacionempresa,
                               cg.car_car_nam nombreempresa,
                               cg.car_pac_nber totalbultos,
                               cg.car_reg_date fecharegistro,
                               cg.car_reg_time horaregistro,
                               cg.car_gros_mass pesobrutototal,
                               cbg.key_bol_ref docembarque,
                               cbg.key_lin_nbr || '/' || cbg.carbol_sline_nber
                                   nroitem,
                               cbg.carbol_frt_prep aduanadestino,
                               c.cuo_nam descripcionaduana,
                               cbg.carbol_gros_mas pesobruto,
                               cbg.carbol_pack_nber cantidadbultos,
                               cbg.carbol_pack_cod tipobultos,
                                  NVL (cbg.carbol_seal_mrks1, '-')
                               || ' '
                               || NVL (cbg.carbol_seal_mrks2, '-')
                               || '/'
                               || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                               NVL (cbg.carbol_cons_cod, '-')
                                   identificacionconsignatario,
                               NVL (cbg.carbol_cons_nam, '-')
                                   nombreconsignatario,
                                  NVL (cbg.carbol_good1, ' ')
                               || '.'
                               || NVL (cbg.carbol_good2, ' ')
                               || '.'
                               || NVL (cbg.carbol_good3, ' ')
                               || '.'
                               || NVL (cbg.carbol_good4, ' ')
                               || '.'
                               || NVL (cbg.carbol_good5, ' ')
                                   descripcionmercancia,
                               cbg.carbol_infos1||'-'||cbg.carbol_infos2 doc_anexos,
                               ctn.car_ctn_nbr nrocontenedor,
                               NVL (ctn.car_ctn_ident, '-') precintocont,
                               NVL (ctn.car_ctn_typ, '-') clasificacion
                        FROM   transitos.tra_pla_rut a,
                               ops$asy.uncuotab b,
                               ops$asy.uncuotab c,
                               ops$asy.uncuotab d,
                               ops$asy.car_gen cg,
                               ops$asy.car_bol_gen cbg,
                               ops$asy.car_bol_ctn ctn
                       WHERE       a.key_cuo = cg.key_cuo
                               AND a.car_reg_year = cg.car_reg_year
                               AND a.car_reg_nber = cg.car_reg_nber
                               AND cg.key_cuo = cbg.key_cuo
                               AND cg.key_voy_nber = cbg.key_voy_nber
                               AND cg.key_dep_date = cbg.key_dep_date
                               AND cbg.carbol_nat_cod = '24'
                               AND cbg.key_cuo = ctn.key_cuo(+)
                               AND cbg.key_voy_nber = ctn.key_voy_nber(+)
                               AND cbg.key_dep_date = ctn.key_dep_date(+)
                               AND cbg.key_bol_ref = ctn.key_bol_ref(+)
                               AND cbg.key_lin_nbr = ctn.key_lin_nbr(+)
                               AND cg.key_cuo = p_aduanaorigen
                               --and p_aduanaOrigen in ('072','101', '211', '301', '421', '422', '521', '543', '621', '641', '701', '711')
                               AND cbg.carbol_frt_prep LIKE '%' || p_aduanadestino || '%'
                               AND a.tra_fec_ini >= TO_DATE (p_fecha_ini,'dd/mm/yyyy HH24:mi:ss')
                               AND a.tra_fec_ini <= TO_DATE (p_fecha_fin,'dd/mm/yyyy HH24:mi:ss')
                               AND cg.key_cuo = b.cuo_cod
                               AND b.lst_ope = 'U'
                               AND cbg.carbol_frt_prep = c.cuo_cod
                               AND c.lst_ope = 'U'
                               AND a.tra_cuo_des = d.cuo_cod(+)
                               AND d.lst_ope(+) = 'U'
                               AND a.tra_num = 0
                               AND a.lst_ope = 'U'
                               AND a.key_secuencia > 0
                               AND a.tra_fec_des IS NULL
                               and a.tra_cuo_est = CBG.CARBOL_FRT_PREP
                    ORDER BY      cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber,
                               cbg.key_bol_ref;*/
                    SELECT DISTINCT
                           cg.key_cuo || ': ' || b.cuo_nam aduanaorigen,
                              cg.key_cuo
                           || ' '
                           || cg.car_reg_year
                           || ' '
                           || cg.car_reg_nber
                               registromanifiesto,
                           --to_char(a.tra_fec_ini,'dd/mm/yyyy HH24:mi:ss') fechainicio,
                           cg.car_id_trp numeroplaca,
                           cg.car_car_cod identificacionempresa,
                           cg.car_car_nam nombreempresa,
                           cg.car_pac_nber totalbultos,
                           cg.car_reg_date fecharegistro,
                           cg.car_reg_time horaregistro,
                           cg.car_gros_mass pesobrutototal,
                           cbg.key_bol_ref docembarque,
                           cbg.key_lin_nbr || '/' || cbg.carbol_sline_nber
                               nroitem,
                           cbg.carbol_frt_prep aduanadestino,
                           c.cuo_nam descripcionaduana,
                           cbg.carbol_gros_mas pesobruto,
                           cbg.carbol_pack_nber cantidadbultos,
                           cbg.carbol_pack_cod tipobultos,
                              NVL (cbg.carbol_seal_mrks1, '-')
                           || ' '
                           || NVL (cbg.carbol_seal_mrks2, '-')
                           || '/'
                           || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                           NVL (cbg.carbol_cons_cod, '-')
                               identificacionconsignatario,
                           NVL (cbg.carbol_cons_nam, '-')
                               nombreconsignatario,
                              NVL (cbg.carbol_good1, ' ')
                           || '.'
                           || NVL (cbg.carbol_good2, ' ')
                           || '.'
                           || NVL (cbg.carbol_good3, ' ')
                           || '.'
                           || NVL (cbg.carbol_good4, ' ')
                           || '.'
                           || NVL (cbg.carbol_good5, ' ')
                               descripcionmercancia,
                           cbg.carbol_infos1||'-'||cbg.carbol_infos2 doc_anexos,
                           ctn.car_ctn_nbr nrocontenedor,
                           NVL (ctn.car_ctn_ident, '-') precintocont,
                           NVL (ctn.car_ctn_typ, '-') clasificacion
                    FROM   uncuotab b,
                           uncuotab c,
                           car_gen cg,
                           car_bol_gen cbg, car_bol_ope cbo, transitos.tra_estado_placa e,
                           car_bol_ctn ctn
                   WHERE   cg.key_cuo = cbg.key_cuo
                           AND cg.key_voy_nber = cbg.key_voy_nber
                           AND cg.key_dep_date = cbg.key_dep_date
                           AND cbg.carbol_nat_cod = '24'

                           AND cbg.key_cuo = cbo.key_cuo
                           AND cbg.key_voy_nber = cbo.key_voy_nber
                           AND cbg.key_dep_date = cbo.key_dep_date
                           AND cbg.key_bol_ref = cbo.key_bol_ref
                           AND to_char(cbo.car_ope_dat, 'yyyymmdd') || replace(cbo.car_ope_hor, ':', '') =
                           (SELECT MAX(to_char(b.car_ope_dat, 'yyyymmdd') || replace(b.car_ope_hor, ':', ''))
                               FROM CAR_BOL_OPE B
                              WHERE B.key_cuo = cbo.key_cuo
                                AND B.key_voy_nber = cbo.KEY_VOY_NBER
                                AND B.key_dep_date = cbo.KEY_DEP_DATE
                                AND B.key_bol_ref = cbo.KEY_BOL_REF)
                           AND cbo.car_pkg_avl > 0
                           AND cbo.car_wgt_avl > 0

                           AND cbg.key_cuo = ctn.key_cuo(+)
                           AND cbg.key_voy_nber = ctn.key_voy_nber(+)
                           AND cbg.key_dep_date = ctn.key_dep_date(+)
                           AND cbg.key_bol_ref = ctn.key_bol_ref(+)
                           AND cbg.key_lin_nbr = ctn.key_lin_nbr(+)
                           AND cg.key_cuo = p_aduanaorigen
                           --and p_aduanaOrigen in ('072','101', '211', '301', '421', '422', '521', '543', '621', '641', '701', '711')
                           AND cbg.carbol_frt_prep LIKE '%' || p_aduanadestino || '%'
                           AND cg.car_reg_date BETWEEN TO_DATE (p_fecha_ini, 'dd/mm/yyyy') AND TO_DATE (p_fecha_fin, 'dd/mm/yyyy')
                           AND cg.key_cuo = b.cuo_cod
                           AND b.lst_ope = 'U'
                           AND cbg.carbol_frt_prep = c.cuo_cod
                           AND c.lst_ope = 'U'

                           and cg.key_cuo = e.key_cuo
                           and cg.car_reg_year = e.car_reg_year
                           and cg.car_reg_nber = e.car_reg_nber
                ORDER BY      cg.key_cuo
                           || ' '
                           || cg.car_reg_year
                           || ' '
                           || cg.car_reg_nber,
                           cbg.key_bol_ref;

                p_mensaje := 'OK';
            ELSE
                OPEN cd FOR
                    SELECT   ''
                      FROM   DUAL
                     WHERE   1 = 0;

                p_mensaje := 'Aduana origen no pertenece a su concesion.';
            END IF;
        ELSE
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Usuario no corresponde a su concesion';
        END IF;

        RETURN cd;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 1;

            p_mensaje := 'No existen transitos pendientes';
            RETURN cd;
        WHEN OTHERS
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Error desconocido.';
            RETURN cd;
    END cobro_diferido;

    FUNCTION duilevante (
        p_sad_reg_year     IN     sad_gen.sad_reg_year%TYPE,
        p_key_cuo          IN     sad_gen.key_cuo%TYPE,
        p_sad_reg_serial   IN     sad_gen.sad_reg_serial%TYPE,
        p_sad_reg_nber     IN     sad_gen.sad_reg_nber%TYPE,
        p_usuario          IN     VARCHAR2,
        p_mensaje             OUT VARCHAR2)
        RETURN cursortype
    IS
        cr       cursortype;
        cont     NUMBER;
        k_year   VARCHAR2 (4);
        k_cuo    VARCHAR2 (3);
        k_dec    VARCHAR2 (20);
        k_bner   VARCHAR2 (20);
        v_usu    VARCHAR2 (20) := SUBSTR (p_usuario, 1, 3);
    BEGIN
        v_usu := UPPER (SUBSTR (p_usuario, 1, 3));
        p_mensaje := 'NO';

        -- VERIFICA EXISTENCIA DE USUARIO
        SELECT   COUNT (1)
          INTO   cont
          FROM   usuario.usuario
         WHERE       usucodusu = UPPER (p_usuario)
                 AND usu_num = 0
                 AND lst_ope = 'U';

        IF cont = 0
        THEN
            p_mensaje := 'Error, Usuario incorrecto';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        -- VERIFICA SI EXISTE LA DECLARACI?N
        SELECT   COUNT (1)                           -- verifica si existe dui
          INTO   cont
          FROM   ops$asy.sad_gen gen
         WHERE       gen.sad_reg_year = p_sad_reg_year
                 AND gen.key_cuo = p_key_cuo
                 AND gen.sad_reg_serial = p_sad_reg_serial
                 AND gen.sad_reg_nber = p_sad_reg_nber
                 AND gen.sad_num = 0
                 AND gen.sad_flw = '1'
                 AND gen.lst_ope = 'U';

        IF NOT (cont > 0)
        THEN
            p_mensaje := 'Declaracion no existe';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        -- VERIFICA SI ESTA VIGENTE LA DECLARACION
        SELECT   COUNT (1)                     -- verifica si dui esta anulada
          INTO   cont
          FROM   ops$asy.sad_gen gen
         WHERE       gen.sad_reg_year = p_sad_reg_year
                 AND gen.key_cuo = p_key_cuo
                 AND gen.sad_reg_serial = p_sad_reg_serial
                 AND gen.sad_reg_nber = p_sad_reg_nber
                 AND gen.sad_num = 0
                 AND gen.sad_flw = '1'
                 AND gen.lst_ope = 'D';

        IF cont > 0
        THEN
            p_mensaje := 'Declaracion Anulada';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        -- SACA LA LLAVE
        SELECT   gen.key_year,
                 gen.key_cuo,
                 NVL (gen.key_dec, '0'),
                 gen.key_nber                        -- verifica si existe dui
          INTO   k_year,
                 k_cuo,
                 k_dec,
                 k_bner
          FROM   ops$asy.sad_gen gen
         WHERE       gen.sad_reg_year = p_sad_reg_year
                 AND gen.key_cuo = p_key_cuo
                 AND gen.sad_reg_serial = p_sad_reg_serial
                 AND gen.sad_reg_nber = p_sad_reg_nber
                 AND gen.sad_num = 0
                 AND gen.sad_flw = '1'
                 AND gen.lst_ope = 'U';

        -- VERIFICA SI LA DECLARACI?N TIENE LEVANTE
        SELECT   COUNT (1)                           -- verifica si existe dui
          INTO   cont
          FROM   ops$asy.sad_spy s
         WHERE       s.key_year = k_year
                 AND s.key_cuo = k_cuo
                 AND NVL (s.key_dec, '0') = k_dec
                 AND s.key_nber = k_bner
                 AND ( (s.spy_sta = 10 AND s.spy_act = 24 AND s.sad_clr = 0)
                      OR              -- solo considera los que tienen levante
                         (s.spy_sta = 6 AND s.spy_act = 9 AND s.sad_clr = 0));

        IF NOT (cont > 0)
        THEN
            p_mensaje := 'Declaracion sin Levante';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        IF v_usu = 'ALB'
        THEN
            IF (   p_key_cuo = '101'
                OR p_key_cuo = '211'
                OR p_key_cuo = '301'
                OR p_key_cuo = '421'
                OR p_key_cuo = '422'
                OR p_key_cuo = '521'
                OR p_key_cuo = '543'
                OR p_key_cuo = '621'
                OR p_key_cuo = '641'
                OR p_key_cuo = '701'
                OR p_key_cuo = '711')
            THEN
                p_mensaje := 'OK';
            ELSE
                p_mensaje := 'Declaracion no corresponde a su Concesion';

                OPEN cr FOR
                    SELECT   *
                      FROM   DUAL
                     WHERE   1 = 0;

                RETURN cr;
            END IF;
        ELSIF v_usu = 'DAB'
        THEN
            IF (   p_key_cuo = '201'
                OR p_key_cuo = '221'
                OR p_key_cuo = '241'
                OR p_key_cuo = '311'
                OR p_key_cuo = '401'
                OR p_key_cuo = '601'
                OR p_key_cuo = '711'
                OR p_key_cuo = '721'
                OR p_key_cuo = '722'
                OR p_key_cuo = '741'
                OR p_key_cuo = '743'
                OR p_key_cuo = '841')
            THEN
                p_mensaje := 'OK';
            ELSE
                p_mensaje := 'Declaracion no corresponde a su Concesion';

                OPEN cr FOR
                    SELECT   *
                      FROM   DUAL
                     WHERE   1 = 0;

                RETURN cr;
            END IF;
        ELSE
            p_mensaje := 'Usuario no corresponde al concesionario';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        IF p_mensaje = 'OK'
        THEN
            IF k_dec = 0                                    -- declarante nulo
            THEN
                OPEN cr FOR
                    SELECT   gen.sad_reg_nber numerodui,
                             gen.sad_reg_date fecharegistro,
                             gen.sad_typ_dec || '-' || gen.sad_typ_proc
                                 patrondui,
                             DECODE (
                                 gen.sad_manif_nber,
                                 NULL,
                                 '-1',
                                 gen.key_cuo || ' ' || gen.sad_manif_nber)
                                 numeromanifiesto,
                             NVL (gen.sad_consignee, cns.sad_con_zip)
                                 idconsignatario,
                             DECODE (gen.sad_consignee,
                                     NULL, cns.sad_con_nam,
                                     cmp.cmp_nam)
                                 nombreconsignatario,
                             '' iddeclarante,
                             (SELECT   d.sad_dec_nam
                                FROM   sad_occ_dec d
                               WHERE       gen.key_year = d.key_year
                                       AND gen.key_cuo = d.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND d.key_dec IS NULL
                                       AND gen.key_nber = d.key_nber
                                       AND d.sad_num = 0)
                                 nombredeclarante,
                             gen.sad_loc_goods localizacion,
                             gen.sad_val_details costostotal,
                             gen.sad_tot_invoiced valorfobtotal,
                             (SELECT   rat.rat_exc
                                FROM   ops$asy.unrattab rat
                               WHERE       rat.cur_cod = gen.sad_cur_cod
                                       AND rat.lst_ope = 'U'
                                       AND gen.sad_reg_date >= rat.eea_dov
                                       AND gen.sad_reg_date <=
                                              NVL (rat.eea_eov, SYSDATE))
                                 tipocambio,
                             /*round ((gen.sad_tot_invoiced *
                             (SELECT rat.rat_exc
                             FROM ops$asy.unrattab rat
                            WHERE rat.cur_cod = gen.sad_cur_cod
                              AND rat.lst_ope = 'U'
                              AND gen.sad_reg_date >= rat.eea_dov
                              AND gen.sad_reg_date <= nvl(rat.eea_eov,sysdate))) + gen.sad_val_details,0) valorCifTotal,*/
                             --     gen.sad_stat_val valorCifTotal,    26/12/2013
                             (SELECT   vim.sad_icif_valn
                                FROM   sad_gen_vim vim
                               WHERE       vim.key_year = gen.key_year
                                       AND vim.key_cuo = gen.key_cuo
                                       AND vim.key_dec IS NULL
                                       AND gen.key_dec IS NULL
                                       AND vim.key_nber = gen.key_nber
                                       AND vim.sad_num = gen.sad_num)
                                 valorciftotal,
                             (SELECT   SUM (it.saditm_pack_nber)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND it.key_dec IS NULL
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 cantidadbultostotal,
                             (SELECT   SUM (it.saditm_gross_mass)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND it.key_dec IS NULL
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 pesobrutototal,
                             lev.upd_dat fechalevante,
                             NVL (sal.upd_dat,
                                  TO_DATE ('01/01/1900', 'dd/mm/yyyy'))
                                 fechapasesalida,
                             itm.itm_nber numeroitem,
                             itm.saditm_hs_cod || itm.saditm_hsprec_cod
                                 codigonandina,
                             itm.saditm_goods_desc3 desccomercial,
                             itm.saditm_gross_mass pesobruto,
                             itm.saditm_net_mass pesoneto,
                             itm.saditm_supp_units cantidadunidades,
                             itm.saditm_pack_kndcod codigoembalaje,
                             itm.saditm_itm_price valorfobitem,
                             itm.saditm_stat_val valorcifitem,
                             DECODE (gen.sad_manif_nber,
                                     NULL, '-1',
                                     itm.saditm_trsp_doc)
                                 documentoembarque
                      FROM   ops$asy.sad_gen gen,
                             ops$asy.sad_itm itm,
                             ops$asy.sad_spy lev,
                             ops$asy.sad_spy sal,
                             ops$asy.sad_occ_cns cns,
                             ops$asy.uncmptab cmp
                     WHERE       gen.key_year = itm.key_year
                             AND gen.key_cuo = itm.key_cuo
                             AND gen.key_dec IS NULL
                             AND itm.key_dec IS NULL
                             AND gen.key_nber = itm.key_nber
                             AND gen.sad_num = itm.sad_num
                             AND gen.sad_num = 0
                             AND gen.lst_ope = 'U'
                             AND gen.sad_flw = '1'
                             AND gen.key_year = lev.key_year
                             AND gen.key_cuo = lev.key_cuo
                             AND lev.key_dec IS NULL
                             AND gen.key_nber = lev.key_nber
                             AND ( (    lev.spy_sta = 10
                                    AND lev.spy_act = 24
                                    AND lev.sad_clr = 0)
                                  OR  -- solo considera los que tienen levante
                                     (    lev.spy_sta = 6
                                      AND lev.spy_act = 9
                                      AND lev.sad_clr = 0))
                             AND gen.key_year = sal.key_year(+)
                             AND gen.key_cuo = sal.key_cuo(+)
                             AND sal.key_dec(+) IS NULL
                             AND gen.key_nber = sal.key_nber(+)
                             AND sal.spy_act(+) = 25 -- solo considera los que tienen levante
                             AND gen.key_year = cns.key_year(+)
                             AND gen.key_cuo = cns.key_cuo(+)
                             AND cns.key_dec(+) IS NULL
                             AND gen.key_nber = cns.key_nber(+)
                             AND gen.sad_num = cns.sad_num(+)
                             AND gen.sad_consignee = cmp.cmp_cod(+)
                             AND cmp.lst_ope(+) = 'U'
                             AND gen.sad_reg_year = p_sad_reg_year
                             AND gen.key_cuo = p_key_cuo
                             AND gen.sad_reg_serial = p_sad_reg_serial
                             AND gen.sad_reg_nber = p_sad_reg_nber;
            ELSE                                         -- declarante no nulo
                OPEN cr FOR
                    SELECT   gen.sad_reg_nber numerodui,
                             gen.sad_reg_date fecharegistro,
                             gen.sad_typ_dec || '-' || gen.sad_typ_proc
                                 patrondui,
                             DECODE (
                                 gen.sad_manif_nber,
                                 NULL,
                                 '-1',
                                 gen.key_cuo || ' ' || gen.sad_manif_nber)
                                 numeromanifiesto,
                             NVL (gen.sad_consignee, cns.sad_con_zip)
                                 idconsignatario,
                             DECODE (gen.sad_consignee,
                                     NULL, cns.sad_con_nam,
                                     cmp.cmp_nam)
                                 nombreconsignatario,
                             gen.key_dec iddeclarante,
                             (SELECT   dec_nam
                                FROM   undectab d
                               WHERE   gen.key_dec = d.dec_cod
                                       AND d.lst_ope = 'U')
                                 nombredeclarante,
                             gen.sad_loc_goods localizacion,
                             gen.sad_val_details costostotal,
                             gen.sad_tot_invoiced valorfobtotal,
                             (SELECT   rat.rat_exc
                                FROM   ops$asy.unrattab rat
                               WHERE       rat.cur_cod = gen.sad_cur_cod
                                       AND rat.lst_ope = 'U'
                                       AND gen.sad_reg_date >= rat.eea_dov
                                       AND gen.sad_reg_date <=
                                              NVL (rat.eea_eov, SYSDATE))
                                 tipocambio,
                             /*round ((gen.sad_tot_invoiced *
                            (SELECT rat.rat_exc
                            FROM ops$asy.unrattab rat
                           WHERE rat.cur_cod = gen.sad_cur_cod
                             AND rat.lst_ope = 'U'
                             AND gen.sad_reg_date >= rat.eea_dov
                             AND gen.sad_reg_date <= nvl(rat.eea_eov,sysdate))) + gen.sad_val_details,0) valorCifTotal,*/
                             --gen.sad_stat_val valorCifTotal,    26/12/2013
                             (SELECT   vim.sad_icif_valn
                                FROM   sad_gen_vim vim
                               WHERE       vim.key_year = gen.key_year
                                       AND vim.key_cuo = gen.key_cuo
                                       AND vim.key_dec = gen.key_dec
                                       AND vim.key_nber = gen.key_nber
                                       AND vim.sad_num = gen.sad_num)
                                 valorciftotal,
                             (SELECT   SUM (it.saditm_pack_nber)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec = it.key_dec
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 cantidadbultostotal,
                             (SELECT   SUM (it.saditm_gross_mass)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec = it.key_dec
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 pesobrutototal,
                             lev.upd_dat fechalevante,
                             NVL (sal.upd_dat,
                                  TO_DATE ('01/01/1900', 'dd/mm/yyyy'))
                                 fechapasesalida,
                             itm.itm_nber numeroitem,
                             itm.saditm_hs_cod || itm.saditm_hsprec_cod
                                 codigonandina,
                             itm.saditm_goods_desc3 desccomercial,
                             itm.saditm_gross_mass pesobruto,
                             itm.saditm_net_mass pesoneto,
                             itm.saditm_supp_units cantidadunidades,
                             itm.saditm_pack_kndcod codigoembalaje,
                             itm.saditm_itm_price valorfobitem,
                             itm.saditm_stat_val valorcifitem,
                             DECODE (gen.sad_manif_nber,
                                     NULL, '-1',
                                     itm.saditm_trsp_doc)
                                 documentoembarque
                      FROM   ops$asy.sad_gen gen,
                             ops$asy.sad_itm itm,
                             ops$asy.sad_spy lev,
                             ops$asy.sad_spy sal,
                             ops$asy.sad_occ_cns cns,
                             ops$asy.uncmptab cmp
                     WHERE       gen.key_year = itm.key_year
                             AND gen.key_cuo = itm.key_cuo
                             AND gen.key_dec = itm.key_dec
                             AND gen.key_nber = itm.key_nber
                             AND gen.sad_num = itm.sad_num
                             AND gen.sad_num = 0
                             AND gen.lst_ope = 'U'
                             AND gen.sad_flw = '1'
                             AND gen.key_year = lev.key_year
                             AND gen.key_cuo = lev.key_cuo
                             AND gen.key_dec = lev.key_dec
                             AND gen.key_nber = lev.key_nber
                             AND ( (    lev.spy_sta = 10
                                    AND lev.spy_act = 24
                                    AND lev.sad_clr = 0)
                                  OR  -- solo considera los que tienen levante
                                     (    lev.spy_sta = 6
                                      AND lev.spy_act = 9
                                      AND lev.sad_clr = 0))
                             AND gen.key_year = sal.key_year(+)
                             AND gen.key_cuo = sal.key_cuo(+)
                             AND gen.key_dec = sal.key_dec(+)
                             AND gen.key_nber = sal.key_nber(+)
                             AND sal.spy_act(+) = 25 -- solo considera los que tienen levante
                             AND gen.key_year = cns.key_year(+)
                             AND gen.key_cuo = cns.key_cuo(+)
                             AND gen.key_dec = cns.key_dec(+)
                             AND gen.key_nber = cns.key_nber(+)
                             AND gen.sad_num = cns.sad_num(+)
                             AND gen.sad_consignee = cmp.cmp_cod(+)
                             AND cmp.lst_ope(+) = 'U'
                             AND gen.sad_reg_year = p_sad_reg_year
                             AND gen.key_cuo = p_key_cuo
                             AND gen.sad_reg_serial = p_sad_reg_serial
                             AND gen.sad_reg_nber = p_sad_reg_nber;
            END IF;

        END IF;

        RETURN cr;
    END duilevante;

    FUNCTION duicourier (p_declarante   IN     sad_gen.key_dec%TYPE,
                         p_key_cuo      IN     sad_gen.key_cuo%TYPE,
                         p_f_inicial    IN     VARCHAR2,
                         p_f_final      IN     VARCHAR2,
                         p_usuario      IN     VARCHAR2,
                         p_mananio      IN     VARCHAR2,
                         p_manreg       IN     VARCHAR2,
                         p_docemb       IN     VARCHAR2,
                         p_mensaje         OUT VARCHAR2)
        RETURN cursortype
    IS
        cr       cursortype;
        cont     NUMBER;
        k_year   VARCHAR2 (4);
        k_cuo    VARCHAR2 (3);
        k_dec    VARCHAR2 (20);
        k_bner   VARCHAR2 (20);
        v_usu    VARCHAR2 (20) := SUBSTR (p_usuario, 1, 3);
        hay      DECIMAL (3, 0);
        v_fecha_ini DATE;
        v_fecha_fin DATE;
    BEGIN
        v_usu := UPPER (SUBSTR (p_usuario, 1, 3));
        p_mensaje := 'NO';

        -- VERIFICA EXISTENCIA DE USUARIO
        SELECT   COUNT (1)
          INTO   cont
          FROM   usuario.usuario
         WHERE       usucodusu = UPPER (p_usuario)
                 AND usu_num = 0
                 AND lst_ope = 'U';

        IF cont = 0
        THEN
            p_mensaje := 'Error, Usuario incorrecto';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        -- verifica si se trata de una consulta por documento o por manifiesto
        IF NOT (p_declarante = '-1')
        THEN
            -- VERIFICA SI EXISTE DEL NIT DEL DECLARANTE
            SELECT   COUNT (1)
              INTO   cont
              FROM   undectab
             WHERE   dec_cod = p_declarante AND lst_ope = 'U';

            IF NOT (cont > 0)
            THEN
                p_mensaje := 'Declarante no existe';

                OPEN cr FOR
                    SELECT   *
                      FROM   DUAL
                     WHERE   1 = 0;

                RETURN cr;
            END IF;


            SELECT   COUNT (1)
              INTO   cont
              FROM   undectab d, operador.olopetab olo, operador.olopetip tip
             WHERE       dec_cod = p_declarante
                     AND lst_ope = 'U'
                     AND d.dec_cod = olo.ope_nit
                     AND olo.ult_ver = 0
                     AND olo.emp_cod = tip.emp_cod
                     AND olo.ult_ver = tip.ult_ver
                     AND tip.ope_tip = 'COU';

             IF cont = 0
             THEN
                 SELECT   COUNT (1)
                  INTO   cont
                  FROM   ops$asy.bo_oce_opetipo ot, undectab d
                 WHERE       dec_cod = p_declarante
                         AND d.lst_ope = 'U'
                         AND d.dec_cod = ot.ope_numerodoc
                         AND ot.tip_estado = 'H'
                         AND ot.tip_num = 0
                         AND ot.tip_tipooperador = 'COU';
             END IF;
            --Modificado Edgar 27112014 Nuevo OCE       QUERY 6


  /*          SELECT   COUNT (1)
              INTO   hay
              FROM   ops$asy.bo_oce_opetipo ot, undectab d
             WHERE       dec_cod = p_declarante
                     AND d.lst_ope = 'U'
                     AND d.dec_cod = ot.ope_numerodoc
                     AND ot.tip_estado = 'H'
                     AND ot.tip_num = 0
                     AND ot.tip_tipooperador = 'COU';

            IF hay = 0 AND SYSDATE < v_fecha_corte
            THEN
                SELECT   COUNT (1)
                  INTO   cont
                  FROM   undectab d,
                         operador.olopetab olo,
                         operador.olopetip tip
                 WHERE       dec_cod = p_declarante
                         AND d.lst_ope = 'U'
                         AND d.dec_cod = olo.ope_nit
                         AND olo.ult_ver = 0
                         AND olo.emp_cod = tip.emp_cod
                         AND olo.ult_ver = tip.ult_ver
                         AND tip.ope_tip = 'COU';
            ELSE
                SELECT   COUNT (1)
                  INTO   cont
                  FROM   ops$asy.bo_oce_opetipo ot, undectab d
                 WHERE       dec_cod = p_declarante
                         AND d.lst_ope = 'U'
                         AND d.dec_cod = ot.ope_numerodoc
                         AND ot.tip_estado = 'H'
                         AND ot.tip_num = 0
                         AND ot.tip_tipooperador = 'COU';
            END IF;*/

            IF NOT (cont > 0)
            THEN
                p_mensaje := 'Declarante no es Courier';

                OPEN cr FOR
                    SELECT   *
                      FROM   DUAL
                     WHERE   1 = 0;

                RETURN cr;
            END IF;

            v_fecha_ini := TO_DATE(p_f_inicial,'DD/MM/YYYY');
            v_fecha_fin := TO_DATE(p_f_final,'DD/MM/YYYY');

            IF v_fecha_fin >= v_fecha_ini + 2
            THEN
                p_mensaje := 'Error, rango de fecha no permitido';
                OPEN cr FOR
                    SELECT   *
                      FROM   DUAL
                     WHERE   1 = 0;
                RETURN cr;
            END IF;

        END IF;

        IF v_usu = 'ALB'
        THEN
            IF (   p_key_cuo = '101'
                OR p_key_cuo = '211'
                OR p_key_cuo = '301'
                OR p_key_cuo = '421'
                OR p_key_cuo = '422'
                OR p_key_cuo = '521'
                OR p_key_cuo = '543'
                OR p_key_cuo = '621'
                OR p_key_cuo = '641'
                OR p_key_cuo = '701'
                OR p_key_cuo = '711')
            THEN
                p_mensaje := 'OK';
            ELSE
                p_mensaje := 'Consulta no corresponde a su Concesion';

                OPEN cr FOR
                    SELECT   *
                      FROM   DUAL
                     WHERE   1 = 0;

                RETURN cr;
            END IF;
        ELSIF v_usu = 'DAB'
        THEN
            IF (   p_key_cuo = '201'
                OR p_key_cuo = '221'
                OR p_key_cuo = '241'
                OR p_key_cuo = '311'
                OR p_key_cuo = '401'
                OR p_key_cuo = '601'
                OR p_key_cuo = '711'
                OR p_key_cuo = '721'
                OR p_key_cuo = '722'
                OR p_key_cuo = '741'
                OR p_key_cuo = '743'
                OR p_key_cuo = '841')
            THEN
                p_mensaje := 'OK';
            ELSE
                p_mensaje := 'Consulta no corresponde a su Concesion';

                OPEN cr FOR
                    SELECT   *
                      FROM   DUAL
                     WHERE   1 = 0;

                RETURN cr;
            END IF;
        ELSE
            p_mensaje := 'Usuario no corresponde al concesionario';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        IF p_mensaje = 'OK'
        THEN
            IF NOT (p_declarante = '-1') AND (p_docemb = '-1')
            THEN
                IF k_dec = 0                                -- declarante nulo
                THEN
                    OPEN cr FOR
                        SELECT      gen.key_year
                                 || ' '
                                 || gen.key_cuo
                                 || ' '
                                 || gen.key_dec
                                 || ' '
                                 || gen.key_nber
                                     llave,
                                 gen.sad_reg_nber numerodui,
                                 gen.sad_reg_date fecharegistro,
                                 gen.sad_typ_dec || '-' || gen.sad_typ_proc
                                     patrondui,
                                 DECODE (
                                     gen.sad_manif_nber,
                                     NULL,
                                     '-1',
                                     gen.key_cuo || ' ' || gen.sad_manif_nber)
                                     numeromanifiesto,
                                 NVL (gen.sad_consignee, cns.sad_con_zip)
                                     idconsignatario,
                                 DECODE (gen.sad_consignee,
                                         NULL, cns.sad_con_nam,
                                         cmp.cmp_nam)
                                     nombreconsignatario,
                                 '' iddeclarante,
                                 (SELECT   d.sad_dec_nam
                                    FROM   sad_occ_dec d
                                   WHERE       gen.key_year = d.key_year
                                           AND gen.key_cuo = d.key_cuo
                                           AND gen.key_dec IS NULL
                                           AND d.key_dec IS NULL
                                           AND gen.key_nber = d.key_nber
                                           AND d.sad_num = 0)
                                     nombredeclarante,
                                 gen.sad_loc_goods localizacion,
                                 gen.sad_val_details costostotal,
                                 gen.sad_tot_invoiced valorfobtotal,
                                 (SELECT   rat.rat_exc
                                    FROM   ops$asy.unrattab rat
                                   WHERE   rat.cur_cod = gen.sad_cur_cod
                                           AND rat.lst_ope = 'U'
                                           AND gen.sad_reg_date >=
                                                  rat.eea_dov
                                           AND gen.sad_reg_date <=
                                                  NVL (rat.eea_eov, SYSDATE))
                                     tipocambio,
                                 (SELECT   vim.sad_icif_valn
                                    FROM   sad_gen_vim vim
                                   WHERE       vim.key_year = gen.key_year
                                           AND vim.key_cuo = gen.key_cuo
                                           AND vim.key_dec IS NULL
                                           AND gen.key_dec IS NULL
                                           AND vim.key_nber = gen.key_nber
                                           AND vim.sad_num = gen.sad_num)
                                     valorciftotal,
                                 (SELECT   SUM (it.saditm_pack_nber)
                                    FROM   ops$asy.sad_itm it
                                   WHERE       gen.key_year = it.key_year
                                           AND gen.key_cuo = it.key_cuo
                                           AND gen.key_dec IS NULL
                                           AND it.key_dec IS NULL
                                           AND gen.key_nber = it.key_nber
                                           AND it.sad_num = 0)
                                     cantidadbultostotal,
                                 (SELECT   SUM (it.saditm_gross_mass)
                                    FROM   ops$asy.sad_itm it
                                   WHERE       gen.key_year = it.key_year
                                           AND gen.key_cuo = it.key_cuo
                                           AND gen.key_dec IS NULL
                                           AND it.key_dec IS NULL
                                           AND gen.key_nber = it.key_nber
                                           AND it.sad_num = 0)
                                     pesobrutototal,
                                 lev.upd_dat fechalevante,
                                 NVL (sal.upd_dat,
                                      TO_DATE ('01/01/1900', 'dd/mm/yyyy'))
                                     fechapasesalida,
                                 itm.itm_nber numeroitem,
                                 itm.saditm_hs_cod || itm.saditm_hsprec_cod
                                     codigonandina,
                                 itm.saditm_goods_desc3 desccomercial,
                                 itm.saditm_gross_mass pesobruto,
                                 itm.saditm_net_mass pesoneto,
                                 itm.saditm_supp_units cantidadunidades,
                                 itm.saditm_pack_kndcod codigoembalaje,
                                 itm.saditm_itm_price valorfobitem,
                                 itm.saditm_stat_val valorcifitem,
                                 DECODE (gen.sad_manif_nber,
                                         NULL, '-1',
                                         itm.saditm_trsp_doc)
                                     documentoembarque
                          FROM   ops$asy.sad_gen gen,
                                 ops$asy.sad_itm itm,
                                 ops$asy.sad_spy lev,
                                 ops$asy.sad_spy sal,
                                 ops$asy.sad_occ_cns cns,
                                 ops$asy.uncmptab cmp
                         WHERE       gen.key_year = itm.key_year
                                 AND gen.key_cuo = itm.key_cuo
                                 AND gen.key_dec IS NULL
                                 AND itm.key_dec IS NULL
                                 AND gen.key_nber = itm.key_nber
                                 AND gen.sad_num = itm.sad_num
                                 AND gen.sad_num = 0
                                 AND gen.lst_ope = 'U'
                                 AND gen.sad_flw = '1'
                                 AND gen.key_year = lev.key_year
                                 AND gen.key_cuo = lev.key_cuo
                                 AND lev.key_dec IS NULL
                                 AND gen.key_nber = lev.key_nber
                                 AND ( (    lev.spy_sta = 10
                                        AND lev.spy_act = 24
                                        AND lev.sad_clr = 0)
                                      OR -- solo considera los que tienen levante
                                         (    lev.spy_sta = 6
                                          AND lev.spy_act = 9
                                          AND lev.sad_clr = 0))
                                 AND gen.key_year = sal.key_year(+)
                                 AND gen.key_cuo = sal.key_cuo(+)
                                 AND sal.key_dec(+) IS NULL
                                 AND gen.key_nber = sal.key_nber(+)
                                 AND sal.spy_act(+) = 25 -- solo considera los que tienen levante
                                 AND gen.key_year = cns.key_year(+)
                                 AND gen.key_cuo = cns.key_cuo(+)
                                 AND cns.key_dec(+) IS NULL
                                 AND gen.key_nber = cns.key_nber(+)
                                 AND gen.sad_num = cns.sad_num(+)
                                 AND gen.sad_consignee = cmp.cmp_cod(+)
                                 AND cmp.lst_ope(+) = 'U'
                                 AND gen.sad_consignee = p_declarante
                                 AND gen.key_cuo = p_key_cuo
                                 AND gen.sad_reg_date >= TO_DATE (p_f_inicial, 'dd/mm/yyyy') AND gen.sad_reg_date <= TO_DATE (p_f_final, 'dd/mm/yyyy');

                ELSE                                     -- declarante no nulo
                    OPEN cr FOR
                        SELECT      gen.key_year
                                 || ' '
                                 || gen.key_cuo
                                 || ' '
                                 || gen.key_dec
                                 || ' '
                                 || gen.key_nber
                                     llave,
                                 gen.sad_reg_nber numerodui,
                                 gen.sad_reg_date fecharegistro,
                                 gen.sad_typ_dec || '-' || gen.sad_typ_proc
                                     patrondui,
                                 DECODE (
                                     gen.sad_manif_nber,
                                     NULL,
                                     '-1',
                                     gen.key_cuo || ' ' || gen.sad_manif_nber)
                                     numeromanifiesto,
                                 NVL (gen.sad_consignee, cns.sad_con_zip)
                                     idconsignatario,
                                 DECODE (gen.sad_consignee,
                                         NULL, cns.sad_con_nam,
                                         cmp.cmp_nam)
                                     nombreconsignatario,
                                 gen.key_dec iddeclarante,
                                 (SELECT   dec_nam
                                    FROM   undectab d
                                   WHERE   gen.key_dec = d.dec_cod
                                           AND d.lst_ope = 'U')
                                     nombredeclarante,
                                 gen.sad_loc_goods localizacion,
                                 gen.sad_val_details costostotal,
                                 gen.sad_tot_invoiced valorfobtotal,
                                 (SELECT   rat.rat_exc
                                    FROM   ops$asy.unrattab rat
                                   WHERE   rat.cur_cod = gen.sad_cur_cod
                                           AND rat.lst_ope = 'U'
                                           AND gen.sad_reg_date >=
                                                  rat.eea_dov
                                           AND gen.sad_reg_date <=
                                                  NVL (rat.eea_eov, SYSDATE))
                                     tipocambio,
                                 (SELECT   vim.sad_icif_valn
                                    FROM   sad_gen_vim vim
                                   WHERE       vim.key_year = gen.key_year
                                           AND vim.key_cuo = gen.key_cuo
                                           AND vim.key_dec = gen.key_dec
                                           AND vim.key_nber = gen.key_nber
                                           AND vim.sad_num = gen.sad_num)
                                     valorciftotal,
                                 (SELECT   SUM (it.saditm_pack_nber)
                                    FROM   ops$asy.sad_itm it
                                   WHERE       gen.key_year = it.key_year
                                           AND gen.key_cuo = it.key_cuo
                                           AND gen.key_dec = it.key_dec
                                           AND gen.key_nber = it.key_nber
                                           AND it.sad_num = 0)
                                     cantidadbultostotal,
                                 (SELECT   SUM (it.saditm_gross_mass)
                                    FROM   ops$asy.sad_itm it
                                   WHERE       gen.key_year = it.key_year
                                           AND gen.key_cuo = it.key_cuo
                                           AND gen.key_dec = it.key_dec
                                           AND gen.key_nber = it.key_nber
                                           AND it.sad_num = 0)
                                     pesobrutototal,
                                 lev.upd_dat fechalevante,
                                 NVL (sal.upd_dat,
                                      TO_DATE ('01/01/1900', 'dd/mm/yyyy'))
                                     fechapasesalida,
                                 itm.itm_nber numeroitem,
                                 itm.saditm_hs_cod || itm.saditm_hsprec_cod
                                     codigonandina,
                                 itm.saditm_goods_desc3 desccomercial,
                                 itm.saditm_gross_mass pesobruto,
                                 itm.saditm_net_mass pesoneto,
                                 itm.saditm_supp_units cantidadunidades,
                                 itm.saditm_pack_kndcod codigoembalaje,
                                 itm.saditm_itm_price valorfobitem,
                                 itm.saditm_stat_val valorcifitem,
                                 DECODE (gen.sad_manif_nber,
                                         NULL, '-1',
                                         itm.saditm_trsp_doc)
                                     documentoembarque
                          FROM   ops$asy.sad_gen gen,
                                 ops$asy.sad_itm itm,
                                 ops$asy.sad_spy lev,
                                 ops$asy.sad_spy sal,
                                 ops$asy.sad_occ_cns cns,
                                 ops$asy.uncmptab cmp
                         WHERE       gen.key_year = itm.key_year
                                 AND gen.key_cuo = itm.key_cuo
                                 AND gen.key_dec = itm.key_dec
                                 AND gen.key_nber = itm.key_nber
                                 AND gen.sad_num = itm.sad_num
                                 AND gen.sad_num = 0
                                 AND gen.lst_ope = 'U'
                                 AND gen.sad_flw = '1'
                                 AND gen.key_year = lev.key_year
                                 AND gen.key_cuo = lev.key_cuo
                                 AND gen.key_dec = lev.key_dec
                                 AND gen.key_nber = lev.key_nber
                                 AND ( (    lev.spy_sta = 10
                                        AND lev.spy_act = 24
                                        AND lev.sad_clr = 0)
                                      OR -- solo considera los que tienen levante
                                         (    lev.spy_sta = 6
                                          AND lev.spy_act = 9
                                          AND lev.sad_clr = 0))
                                 AND gen.key_year = sal.key_year(+)
                                 AND gen.key_cuo = sal.key_cuo(+)
                                 AND gen.key_dec = sal.key_dec(+)
                                 AND gen.key_nber = sal.key_nber(+)
                                 AND sal.spy_act(+) = 25 -- solo considera los que tienen levante
                                 AND gen.key_year = cns.key_year(+)
                                 AND gen.key_cuo = cns.key_cuo(+)
                                 AND gen.key_dec = cns.key_dec(+)
                                 AND gen.key_nber = cns.key_nber(+)
                                 AND gen.sad_num = cns.sad_num(+)
                                 AND gen.sad_consignee = cmp.cmp_cod(+)
                                 AND cmp.lst_ope(+) = 'U'
                                 AND gen.key_dec = p_declarante
                                 AND gen.key_cuo = p_key_cuo
                                 AND gen.sad_reg_date >=
                                        TO_DATE (p_f_inicial, 'dd/mm/yyyy')
                                 AND gen.sad_reg_date <=
                                        TO_DATE (p_f_final, 'dd/mm/yyyy');
                END IF;
            ELSIF     NOT (p_mananio = '-1')
                  AND NOT (p_manreg = '-1')
                  AND NOT (p_docemb = '-1')
            THEN
                SELECT   COUNT (1)
                  INTO   cont
                  FROM   car_bol_sta st
                 WHERE       st.key_cuo = p_key_cuo
                         AND st.car_reg_year = p_mananio
                         AND st.car_reg_nber = p_manreg
                         AND st.key_bol_ref = p_docemb;

                IF NOT (cont > 0)
                THEN
                    p_mensaje := 'No existe informacion. Revise los datos.';

                    OPEN cr FOR
                        SELECT   *
                          FROM   DUAL
                         WHERE   1 = 0;

                    RETURN cr;
                END IF;

                OPEN cr FOR
                    SELECT      gen.key_year
                             || ' '
                             || gen.key_cuo
                             || ' '
                             || gen.key_dec
                             || ' '
                             || gen.key_nber
                                 llave,
                             gen.sad_reg_nber numerodui,
                             gen.sad_reg_date fecharegistro,
                             gen.sad_typ_dec || '-' || gen.sad_typ_proc
                                 patrondui,
                             DECODE (
                                 gen.sad_manif_nber,
                                 NULL,
                                 '-1',
                                 gen.key_cuo || ' ' || gen.sad_manif_nber)
                                 numeromanifiesto,
                             NVL (gen.sad_consignee, cns.sad_con_zip)
                                 idconsignatario,
                             DECODE (gen.sad_consignee,
                                     NULL, cns.sad_con_nam,
                                     cmp.cmp_nam)
                                 nombreconsignatario,
                             gen.key_dec iddeclarante,
                             (SELECT   dec_nam
                                FROM   ops$asy.undectab d
                               WHERE   gen.key_dec = d.dec_cod
                                       AND d.lst_ope = 'U')
                                 nombredeclarante,
                             gen.sad_loc_goods localizacion,
                             gen.sad_val_details costostotal,
                             gen.sad_tot_invoiced valorfobtotal,
                             (SELECT   rat.rat_exc
                                FROM   ops$asy.unrattab rat
                               WHERE       rat.cur_cod = gen.sad_cur_cod
                                       AND rat.lst_ope = 'U'
                                       AND gen.sad_reg_date >= rat.eea_dov
                                       AND gen.sad_reg_date <=
                                              NVL (rat.eea_eov, SYSDATE))
                                 tipocambio,
                             (SELECT   vim.sad_icif_valn
                                FROM   ops$asy.sad_gen_vim vim
                               WHERE       vim.key_year = gen.key_year
                                       AND vim.key_cuo = gen.key_cuo
                                       AND vim.key_dec = gen.key_dec
                                       AND vim.key_nber = gen.key_nber
                                       AND vim.sad_num = gen.sad_num)
                                 valorciftotal,
                             (SELECT   SUM (it.saditm_pack_nber)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec = it.key_dec
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 cantidadbultostotal,
                             (SELECT   SUM (it.saditm_gross_mass)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec = it.key_dec
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 pesobrutototal,
                             lev.upd_dat fechalevante,
                             NVL (sal.upd_dat,
                                  TO_DATE ('01/01/1900', 'dd/mm/yyyy'))
                                 fechapasesalida,
                             itm.itm_nber numeroitem,
                             itm.saditm_hs_cod || itm.saditm_hsprec_cod
                                 codigonandina,
                             itm.saditm_goods_desc3 desccomercial,
                             itm.saditm_gross_mass pesobruto,
                             itm.saditm_net_mass pesoneto,
                             itm.saditm_supp_units cantidadunidades,
                             itm.saditm_pack_kndcod codigoembalaje,
                             itm.saditm_itm_price valorfobitem,
                             itm.saditm_stat_val valorcifitem,
                             DECODE (gen.sad_manif_nber,
                                     NULL, '-1',
                                     itm.saditm_trsp_doc)
                                 documentoembarque
                      FROM   ops$asy.sad_gen gen,
                             ops$asy.sad_itm itm,
                             ops$asy.sad_spy lev,
                             ops$asy.sad_spy sal,
                             ops$asy.sad_occ_cns cns,
                             ops$asy.uncmptab cmp,
                             ops$asy.car_bol_sta st
                     WHERE       gen.key_year = itm.key_year
                             AND gen.key_cuo = itm.key_cuo
                             AND gen.key_dec = itm.key_dec
                             AND gen.key_nber = itm.key_nber
                             AND gen.sad_num = itm.sad_num
                             AND gen.sad_num = 0
                             AND gen.lst_ope = 'U'
                             AND gen.sad_flw = '1'
                             AND gen.key_year = lev.key_year
                             AND gen.key_cuo = lev.key_cuo
                             AND gen.key_dec = lev.key_dec
                             AND gen.key_nber = lev.key_nber
                             AND ( (    lev.spy_sta = 10
                                    AND lev.spy_act = 24
                                    AND lev.sad_clr = 0)
                                  OR  -- solo considera los que tienen levante
                                     (    lev.spy_sta = 6
                                      AND lev.spy_act = 9
                                      AND lev.sad_clr = 0))
                             AND gen.key_year = sal.key_year(+)
                             AND gen.key_cuo = sal.key_cuo(+)
                             AND gen.key_dec = sal.key_dec(+)
                             AND gen.key_nber = sal.key_nber(+)
                             AND sal.spy_act(+) = 25 -- solo considera los que tienen levante
                             AND gen.key_year = cns.key_year(+)
                             AND gen.key_cuo = cns.key_cuo(+)
                             AND gen.key_dec = cns.key_dec(+)
                             AND gen.key_nber = cns.key_nber(+)
                             AND gen.sad_num = cns.sad_num(+)
                             AND gen.sad_consignee = cmp.cmp_cod(+)
                             AND cmp.lst_ope(+) = 'U'
                             AND gen.key_year = st.sad_year
                             AND gen.key_cuo = st.sad_cuo
                             AND gen.key_dec = st.sad_dec
                             AND gen.key_nber = st.sad_nber
                             AND st.key_bol_ref = p_docemb
                             AND st.key_cuo = p_key_cuo
                             AND st.car_reg_year = p_mananio
                             AND st.car_reg_nber = p_manreg
                    UNION
                    SELECT      gen.key_year
                             || ' '
                             || gen.key_cuo
                             || ' '
                             || gen.key_dec
                             || ' '
                             || gen.key_nber
                                 llave,
                             gen.sad_reg_nber numerodui,
                             gen.sad_reg_date fecharegistro,
                             gen.sad_typ_dec || '-' || gen.sad_typ_proc
                                 patrondui,
                             DECODE (
                                 gen.sad_manif_nber,
                                 NULL,
                                 '-1',
                                 gen.key_cuo || ' ' || gen.sad_manif_nber)
                                 numeromanifiesto,
                             NVL (gen.sad_consignee, cns.sad_con_zip)
                                 idconsignatario,
                             DECODE (gen.sad_consignee,
                                     NULL, cns.sad_con_nam,
                                     cmp.cmp_nam)
                                 nombreconsignatario,
                             '' iddeclarante,
                             (SELECT   d.sad_dec_nam
                                FROM   ops$asy.sad_occ_dec d
                               WHERE       gen.key_year = d.key_year
                                       AND gen.key_cuo = d.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND d.key_dec IS NULL
                                       AND gen.key_nber = d.key_nber
                                       AND d.sad_num = 0)
                                 nombredeclarante,
                             gen.sad_loc_goods localizacion,
                             gen.sad_val_details costostotal,
                             gen.sad_tot_invoiced valorfobtotal,
                             (SELECT   rat.rat_exc
                                FROM   ops$asy.unrattab rat
                               WHERE       rat.cur_cod = gen.sad_cur_cod
                                       AND rat.lst_ope = 'U'
                                       AND gen.sad_reg_date >= rat.eea_dov
                                       AND gen.sad_reg_date <=
                                              NVL (rat.eea_eov, SYSDATE))
                                 tipocambio,
                             (SELECT   vim.sad_icif_valn
                                FROM   ops$asy.sad_gen_vim vim
                               WHERE       vim.key_year = gen.key_year
                                       AND vim.key_cuo = gen.key_cuo
                                       AND vim.key_dec IS NULL
                                       AND gen.key_dec IS NULL
                                       AND vim.key_nber = gen.key_nber
                                       AND vim.sad_num = gen.sad_num)
                                 valorciftotal,
                             (SELECT   SUM (it.saditm_pack_nber)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND it.key_dec IS NULL
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 cantidadbultostotal,
                             (SELECT   SUM (it.saditm_gross_mass)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND it.key_dec IS NULL
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 pesobrutototal,
                             lev.upd_dat fechalevante,
                             NVL (sal.upd_dat, TO_DATE ('01/01/1900', 'dd/mm/yyyy'))
                                 fechapasesalida,
                             itm.itm_nber numeroitem,
                             itm.saditm_hs_cod || itm.saditm_hsprec_cod
                                 codigonandina,
                             itm.saditm_goods_desc3 desccomercial,
                             itm.saditm_gross_mass pesobruto,
                             itm.saditm_net_mass pesoneto,
                             itm.saditm_supp_units cantidadunidades,
                             itm.saditm_pack_kndcod codigoembalaje,
                             itm.saditm_itm_price valorfobitem,
                             itm.saditm_stat_val valorcifitem,
                             DECODE (gen.sad_manif_nber,
                                     NULL, '-1',
                                     itm.saditm_trsp_doc)
                                 documentoembarque
                      FROM   ops$asy.sad_gen gen,
                             ops$asy.sad_itm itm,
                             ops$asy.sad_spy lev,
                             ops$asy.sad_spy sal,
                             ops$asy.sad_occ_cns cns,
                             ops$asy.uncmptab cmp,
                             ops$asy.car_bol_sta st
                     WHERE       gen.key_year = itm.key_year
                             AND gen.key_cuo = itm.key_cuo
                             AND gen.key_dec IS NULL
                             AND itm.key_dec IS NULL
                             AND gen.key_nber = itm.key_nber
                             AND gen.sad_num = itm.sad_num
                             AND gen.sad_num = 0
                             AND gen.lst_ope = 'U'
                             AND gen.sad_flw = '1'
                             AND gen.key_year = lev.key_year
                             AND gen.key_cuo = lev.key_cuo
                             AND lev.key_dec IS NULL
                             AND gen.key_nber = lev.key_nber
                             AND ( (    lev.spy_sta = 10
                                    AND lev.spy_act = 24
                                    AND lev.sad_clr = 0)
                                  OR  -- solo considera los que tienen levante
                                     (    lev.spy_sta = 6
                                      AND lev.spy_act = 9
                                      AND lev.sad_clr = 0))
                             AND gen.key_year = sal.key_year(+)
                             AND gen.key_cuo = sal.key_cuo(+)
                             AND sal.key_dec(+) IS NULL
                             AND gen.key_nber = sal.key_nber(+)
                             AND sal.spy_act(+) = 25 -- solo considera los que tienen levante
                             AND gen.key_year = cns.key_year(+)
                             AND gen.key_cuo = cns.key_cuo(+)
                             AND cns.key_dec(+) IS NULL
                             AND gen.key_nber = cns.key_nber(+)
                             AND gen.sad_num = cns.sad_num(+)
                             AND gen.sad_consignee = cmp.cmp_cod(+)
                             AND cmp.lst_ope(+) = 'U'
                             AND gen.key_year = st.sad_year
                             AND gen.key_cuo = st.sad_cuo
                             AND gen.key_dec = st.sad_dec
                             AND gen.key_nber = st.sad_nber
                             AND st.key_bol_ref = p_docemb
                             AND st.key_cuo = p_key_cuo
                             AND st.car_reg_year = p_mananio
                             AND st.car_reg_nber = p_manreg;
            END IF;
        END IF;

        RETURN cr;
    END duicourier;

    FUNCTION manifiesto_23 (p_aduanadestino   IN     VARCHAR2,
                            p_fecha_ini       IN     VARCHAR2,
                            p_fecha_fin       IN     VARCHAR2,
                            p_usuario         IN     VARCHAR2,
                            p_mensaje            OUT VARCHAR2)
        RETURN cursortype
    IS
        cd          cursortype;
        v_usu       VARCHAR2 (20);
        v_adudest   VARCHAR2 (5);
        v           NUMBER;
        cont        NUMBER;
        v_fecha_ini DATE := TO_DATE(p_fecha_ini,'DD/MM/YYYY');
        v_fecha_fin DATE := TO_DATE(p_fecha_fin,'DD/MM/YYYY');
    BEGIN
        v_usu := SUBSTR (UPPER (p_usuario), 1, 3);
        v_adudest := p_aduanadestino;

        p_mensaje := 'NO';

        -- VERIFICA EXISTENCIA DE USUARIO
        SELECT   COUNT (1)
          INTO   cont
          FROM   usuario.usuario
         WHERE       usucodusu = UPPER (p_usuario)
                 AND usu_num = 0
                 AND lst_ope = 'U';

        IF cont = 0
        THEN
            p_mensaje := 'Error, Usuario incorrecto';

            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF LENGTH (v_adudest) <= 1
        THEN
            --V_ADUDEST := '';
            p_mensaje := 'Error, Aduana no existe';

            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF (    SUBSTR (p_aduanadestino, 2, 1) <> '2'
            AND SUBSTR (p_aduanadestino, 2, 1) <> '4'
            AND SUBSTR (p_aduanadestino, 2, 1) <> '1')
        THEN
            p_mensaje := 'Error, Aduana no es de frontera o aeropuerto';

            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF v_fecha_fin >= v_fecha_ini + 2
        THEN
            p_mensaje := 'Error, rango de fecha no permitido';
            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;
            RETURN cd;
        END IF;

        IF v_usu = 'ALB'
        THEN
            IF (   p_aduanadestino = '101'
                OR p_aduanadestino = '211'
                OR p_aduanadestino = '301'
                OR p_aduanadestino = '421'
                OR p_aduanadestino = '422'
                OR p_aduanadestino = '521'
                OR p_aduanadestino = '543'
                OR p_aduanadestino = '621'
                OR p_aduanadestino = '641'
                OR p_aduanadestino = '701'
                OR p_aduanadestino = '711')
            THEN
                OPEN cd FOR
                      SELECT   *
                        FROM   (SELECT   DISTINCT
                                         cg.key_cuo || ': ' || b.cuo_nam
                                             aduanaorigen,
                                            cg.key_cuo
                                         || ' '
                                         || cg.car_reg_year
                                         || ' '
                                         || cg.car_reg_nber
                                             registromanifiesto,
                                         cg.car_id_trp numeroplaca,
                                         cg.car_car_cod identificacionempresa,
                                         cg.car_car_nam nombreempresa,
                                         cg.car_pac_nber totalbultos,
                                         cg.car_reg_date fecharegistro,
                                         cg.car_reg_time horaregistro,
                                         cg.car_gros_mass pesobrutototal,
                                         cbg.key_bol_ref docembarque,
                                            cbg.key_lin_nbr
                                         || '/'
                                         || cbg.carbol_sline_nber
                                             nroitem,
                                         NVL (cbg.carbol_frt_prep, cg.key_cuo)
                                             aduanadestino,
                                         b.cuo_nam descripcionaduana,
                                         cbg.carbol_nat_cod tipomanifiesto,
                                         cbg.carbol_gros_mas pesobruto,
                                         cbg.carbol_pack_nber cantidadbultos,
                                         cbg.carbol_pack_cod tipobultos,
                                            NVL (cbg.carbol_seal_mrks1, '-')
                                         || ' '
                                         || NVL (cbg.carbol_seal_mrks2, '-')
                                         || '/'
                                         || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                                         NVL (cbg.carbol_cons_cod, '-')
                                             identificacionconsignatario,
                                         NVL (cbg.carbol_cons_nam, '-')
                                             nombreconsignatario,
                                            NVL (cbg.carbol_good1, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good2, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good3, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good4, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good5, ' ')
                                             descripcionmercancia,
                                         ctn.car_ctn_nbr nrocontenedor,
                                         NVL (ctn.car_ctn_ident, '-')
                                             precintocont,
                                         NVL (ctn.car_ctn_typ, '-')
                                             clasificacion
                                  FROM   ops$asy.uncuotab b,
                                         ops$asy.car_gen cg,
                                         ops$asy.car_bol_gen cbg,
                                         ops$asy.car_bol_ctn ctn
                                 WHERE       cg.key_cuo = cbg.key_cuo
                                         AND cg.key_voy_nber = cbg.key_voy_nber
                                         AND cg.key_dep_date = cbg.key_dep_date
                                         AND cbg.key_cuo = ctn.key_cuo(+)
                                         AND cbg.key_voy_nber =
                                                ctn.key_voy_nber(+)
                                         AND cbg.key_dep_date =
                                                ctn.key_dep_date(+)
                                         AND cbg.key_bol_ref =
                                                ctn.key_bol_ref(+)
                                         AND cbg.key_lin_nbr =
                                                ctn.key_lin_nbr(+)
                                         AND cg.key_cuo = p_aduanadestino
                                         --AND CG.KEY_CUO '','','')
                                         AND cg.car_reg_date BETWEEN TO_DATE (p_fecha_ini,'dd/mm/yyyy HH24:mi:ss') AND  TO_DATE ( p_fecha_fin, 'dd/mm/yyyy HH24:mi:ss')
                                         AND cg.key_cuo = b.cuo_cod
                                         AND b.lst_ope = 'U'
                                         AND cbg.carbol_nat_cod = '23'
                                         --AND cg.car_tr_regref NOT LIKE 'BO%'
                                         AND cg.key_voy_nber NOT LIKE 'CONS%'
                                         AND (SELECT   COUNT (1)
                                                FROM   car_bol_ope ope
                                               WHERE   ope.key_cuo =
                                                           cbg.key_cuo
                                                       AND ope.key_voy_nber =
                                                              cbg.key_voy_nber
                                                       AND ope.key_dep_date =
                                                              cbg.key_dep_date
                                                       AND ope.key_bol_ref =
                                                              cbg.key_bol_ref
                                                       AND ope.key_lin_nbr =
                                                              cbg.key_lin_nbr
                                                       AND ope.car_ope_typ =
                                                              'LOC') = 0 -- que no tenga localizacion
                                UNION
                                SELECT   DISTINCT
                                         cg.key_cuo || ': ' || b.cuo_nam
                                             aduanaorigen,
                                            cg.key_cuo
                                         || ' '
                                         || cg.car_reg_year
                                         || ' '
                                         || cg.car_reg_nber
                                             registromanifiesto,
                                         cg.car_id_trp numeroplaca,
                                         cg.car_car_cod identificacionempresa,
                                         cg.car_car_nam nombreempresa,
                                         cg.car_pac_nber totalbultos,
                                         cg.car_reg_date fecharegistro,
                                         cg.car_reg_time horaregistro,
                                         cg.car_gros_mass pesobrutototal,
                                         cbg.key_bol_ref docembarque,
                                            cbg.key_lin_nbr
                                         || '/'
                                         || cbg.carbol_sline_nber
                                             nroitem,
                                         NVL (cbg.carbol_frt_prep, cg.key_cuo)
                                             aduanadestino,
                                         b.cuo_nam descripcionaduana,
                                         cbg.carbol_nat_cod tipomanifiesto,
                                         cbg.carbol_gros_mas pesobruto,
                                         cbg.carbol_pack_nber cantidadbultos,
                                         cbg.carbol_pack_cod tipobultos,
                                            NVL (cbg.carbol_seal_mrks1, '-')
                                         || ' '
                                         || NVL (cbg.carbol_seal_mrks2, '-')
                                         || '/'
                                         || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                                         NVL (cbg.carbol_cons_cod, '-')
                                             identificacionconsignatario,
                                         NVL (cbg.carbol_cons_nam, '-')
                                             nombreconsignatario,
                                            NVL (cbg.carbol_good1, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good2, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good3, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good4, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good5, ' ')
                                             descripcionmercancia,
                                         ctn.car_ctn_nbr nrocontenedor,
                                         NVL (ctn.car_ctn_ident, '-')
                                             precintocont,
                                         NVL (ctn.car_ctn_typ, '-')
                                             clasificacion
                                  FROM   ops$asy.uncuotab b,
                                         ops$asy.car_gen cg,
                                         ops$asy.car_bol_gen cbg,
                                         ops$asy.car_bol_ctn ctn
                                 WHERE       cg.key_cuo = cbg.key_cuo
                                         AND cg.key_voy_nber = cbg.key_voy_nber
                                         AND cg.key_dep_date = cbg.key_dep_date
                                         AND cbg.key_cuo = ctn.key_cuo(+)
                                         AND cbg.key_voy_nber =
                                                ctn.key_voy_nber(+)
                                         AND cbg.key_dep_date =
                                                ctn.key_dep_date(+)
                                         AND cbg.key_bol_ref =
                                                ctn.key_bol_ref(+)
                                         AND cbg.key_lin_nbr =
                                                ctn.key_lin_nbr(+)
                                         AND cg.key_cuo = p_aduanadestino
                                         AND cg.car_reg_date BETWEEN TO_DATE ( p_fecha_ini, 'dd/mm/yyyy HH24:mi:ss') AND  TO_DATE ( p_fecha_fin, 'dd/mm/yyyy HH24:mi:ss')
                                         AND cg.key_cuo = b.cuo_cod
                                         AND b.lst_ope = 'U'
                                         AND cbg.carbol_nat_cod IN ('23', '28')
                                         AND cg.car_tr_regref IS NULL
                                         AND cg.key_voy_nber NOT LIKE 'CONS%'
                                         AND (SELECT   COUNT (1)
                                                FROM   car_bol_ope ope
                                               WHERE   ope.key_cuo =
                                                           cbg.key_cuo
                                                       AND ope.key_voy_nber =
                                                              cbg.key_voy_nber
                                                       AND ope.key_dep_date =
                                                              cbg.key_dep_date
                                                       AND ope.key_bol_ref =
                                                              cbg.key_bol_ref
                                                       AND ope.key_lin_nbr =
                                                              cbg.key_lin_nbr
                                                       AND ope.car_ope_typ IN
                                                                  ('LOC', 'ASS')) =
                                                0 -- que no tenga localizacion O dui en caso de aeropuertos
                                UNION
                                SELECT   DISTINCT
                                         cg.key_cuo || ': ' || b.cuo_nam
                                             aduanaorigen,
                                            cg.key_cuo
                                         || ' '
                                         || cg.car_reg_year
                                         || ' '
                                         || cg.car_reg_nber
                                             registromanifiesto,
                                         cg.car_id_trp numeroplaca,
                                         cg.car_car_cod identificacionempresa,
                                         cg.car_car_nam nombreempresa,
                                         cg.car_pac_nber totalbultos,
                                         cg.car_reg_date fecharegistro,
                                         cg.car_reg_time horaregistro,
                                         cg.car_gros_mass pesobrutototal,
                                         cbg.key_bol_ref docembarque,
                                            cbg.key_lin_nbr
                                         || '/'
                                         || cbg.carbol_sline_nber
                                             nroitem,
                                         NVL (cbg.carbol_frt_prep, cg.key_cuo)
                                             aduanadestino,
                                         b.cuo_nam descripcionaduana,
                                         cbg.carbol_nat_cod tipomanifiesto,
                                         cbg.carbol_gros_mas pesobruto,
                                         cbg.carbol_pack_nber cantidadbultos,
                                         cbg.carbol_pack_cod tipobultos,
                                            NVL (cbg.carbol_seal_mrks1, '-')
                                         || ' '
                                         || NVL (cbg.carbol_seal_mrks2, '-')
                                         || '/'
                                         || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                                         NVL (cbg.carbol_cons_cod, '-')
                                             identificacionconsignatario,
                                         NVL (cbg.carbol_cons_nam, '-')
                                             nombreconsignatario,
                                            NVL (cbg.carbol_good1, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good2, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good3, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good4, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good5, ' ')
                                             descripcionmercancia,
                                         ctn.car_ctn_nbr nrocontenedor,
                                         NVL (ctn.car_ctn_ident, '-')
                                             precintocont,
                                         NVL (ctn.car_ctn_typ, '-')
                                             clasificacion
                                  FROM   ops$asy.uncuotab b,
                                         ops$asy.car_gen cg,
                                         ops$asy.car_bol_gen cbg,
                                         ops$asy.car_bol_ctn ctn,
                                         ops$asy.sad_gen gen
                                 WHERE       cg.key_cuo = cbg.key_cuo
                                         AND cg.key_voy_nber = cbg.key_voy_nber
                                         AND cg.key_dep_date = cbg.key_dep_date
                                         AND cbg.key_cuo = ctn.key_cuo(+)
                                         AND cbg.key_voy_nber =
                                                ctn.key_voy_nber(+)
                                         AND cbg.key_dep_date =
                                                ctn.key_dep_date(+)
                                         AND cbg.key_bol_ref =
                                                ctn.key_bol_ref(+)
                                         AND cbg.key_lin_nbr =
                                                ctn.key_lin_nbr(+)
                                         AND cg.key_cuo = p_aduanadestino
                                         AND cg.car_reg_date BETWEEN TO_DATE ( p_fecha_ini, 'dd/mm/yyyy HH24:mi:ss') AND  TO_DATE ( p_fecha_fin, 'dd/mm/yyyy HH24:mi:ss')
                                         AND cg.key_cuo = b.cuo_cod
                                         AND b.lst_ope = 'U'
                                         AND cbg.carbol_nat_cod = '22'
                                         AND SUBSTR (cbg.carbol_ucr_ref, 1, 4) =
                                                gen.sad_reg_year
                                         AND SUBSTR (cbg.carbol_ucr_ref, 6, 3) =
                                                gen.key_cuo
                                         AND SUBSTR (cbg.carbol_ucr_ref, 10, 1) =
                                                gen.sad_reg_serial
                                         AND SUBSTR (
                                                cbg.carbol_ucr_ref,
                                                12,
                                                  INSTR (cbg.carbol_ucr_ref,
                                                         '&',
                                                         1,
                                                         4)
                                                - INSTR (cbg.carbol_ucr_ref,
                                                         '&',
                                                         1,
                                                         3)
                                                - 1) = gen.sad_reg_nber
                                         AND (SELECT   COUNT (1)
                                                FROM   ops$asy.sad_exp_rls rls
                                               WHERE   gen.key_year =
                                                           rls.key_year
                                                       AND gen.key_cuo =
                                                              rls.key_cuo
                                                       AND ( (gen.key_dec =
                                                                  rls.key_dec)
                                                            OR (gen.key_dec IS NULL))
                                                       AND gen.key_nber =
                                                              rls.key_nber) = 0 -- que no tenga certificado de salida emitido
                                                                               )
                    ORDER BY   registromanifiesto, docembarque;

                p_mensaje := 'OK';
            ELSE
                OPEN cd FOR
                    SELECT   ''
                      FROM   DUAL
                     WHERE   1 = 0;

                p_mensaje :=
                    'Error: Aduana destino no corresponde a su concesion';
            END IF;
        ELSIF v_usu = 'DAB'
        THEN
            IF (   p_aduanadestino = '201'
                OR p_aduanadestino = '221'
                OR p_aduanadestino = '241'
                OR p_aduanadestino = '311'
                OR p_aduanadestino = '401'
                OR p_aduanadestino = '601'
                OR p_aduanadestino = '711'
                OR p_aduanadestino = '721'
                OR p_aduanadestino = '722'
                OR p_aduanadestino = '741'
                OR p_aduanadestino = '743'
                OR p_aduanadestino = '841')
            THEN
                OPEN cd FOR
                      SELECT   *
                        FROM   (SELECT   DISTINCT
                                         cg.key_cuo || ': ' || b.cuo_nam
                                             aduanaorigen,
                                            cg.key_cuo
                                         || ' '
                                         || cg.car_reg_year
                                         || ' '
                                         || cg.car_reg_nber
                                             registromanifiesto,
                                         cg.car_id_trp numeroplaca,
                                         cg.car_car_cod identificacionempresa,
                                         cg.car_car_nam nombreempresa,
                                         cg.car_pac_nber totalbultos,
                                         cg.car_reg_date fecharegistro,
                                         cg.car_reg_time horaregistro,
                                         cg.car_gros_mass pesobrutototal,
                                         cbg.key_bol_ref docembarque,
                                            cbg.key_lin_nbr
                                         || '/'
                                         || cbg.carbol_sline_nber
                                             nroitem,
                                         NVL (cbg.carbol_frt_prep, cg.key_cuo)
                                             aduanadestino,
                                         b.cuo_nam descripcionaduana,
                                         cbg.carbol_nat_cod tipomanifiesto,
                                         cbg.carbol_gros_mas pesobruto,
                                         cbg.carbol_pack_nber cantidadbultos,
                                         cbg.carbol_pack_cod tipobultos,
                                            NVL (cbg.carbol_seal_mrks1, '-')
                                         || ' '
                                         || NVL (cbg.carbol_seal_mrks2, '-')
                                         || '/'
                                         || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                                         NVL (cbg.carbol_cons_cod, '-')
                                             identificacionconsignatario,
                                         NVL (cbg.carbol_cons_nam, '-')
                                             nombreconsignatario,
                                            NVL (cbg.carbol_good1, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good2, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good3, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good4, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good5, ' ')
                                             descripcionmercancia,
                                         ctn.car_ctn_nbr nrocontenedor,
                                         NVL (ctn.car_ctn_ident, '-')
                                             precintocont,
                                         NVL (ctn.car_ctn_typ, '-')
                                             clasificacion
                                  FROM   ops$asy.uncuotab b,
                                         ops$asy.car_gen cg,
                                         ops$asy.car_bol_gen cbg,
                                         ops$asy.car_bol_ctn ctn
                                 WHERE       cg.key_cuo = cbg.key_cuo
                                         AND cg.key_voy_nber = cbg.key_voy_nber
                                         AND cg.key_dep_date = cbg.key_dep_date
                                         AND cbg.key_cuo = ctn.key_cuo(+)
                                         AND cbg.key_voy_nber =
                                                ctn.key_voy_nber(+)
                                         AND cbg.key_dep_date =
                                                ctn.key_dep_date(+)
                                         AND cbg.key_bol_ref =
                                                ctn.key_bol_ref(+)
                                         AND cbg.key_lin_nbr =
                                                ctn.key_lin_nbr(+)
                                         AND cg.key_cuo = p_aduanadestino
                                         --AND CG.KEY_CUO '','','')
                                         AND cg.car_reg_date BETWEEN TO_DATE (
                                                                         p_fecha_ini,
                                                                         'dd/mm/yyyy HH24:mi:ss')
                                                                 AND  TO_DATE (
                                                                          p_fecha_fin,
                                                                          'dd/mm/yyyy HH24:mi:ss')
                                         AND cg.key_cuo = b.cuo_cod
                                         AND b.lst_ope = 'U'
                                         AND cbg.carbol_nat_cod = '23'
                                         --AND cg.car_tr_regref NOT LIKE 'BO%'
                                         AND cg.key_voy_nber NOT LIKE 'CONS%'
                                         AND (SELECT   COUNT (1)
                                                FROM   car_bol_ope ope
                                               WHERE   ope.key_cuo =
                                                           cbg.key_cuo
                                                       AND ope.key_voy_nber =
                                                              cbg.key_voy_nber
                                                       AND ope.key_dep_date =
                                                              cbg.key_dep_date
                                                       AND ope.key_bol_ref =
                                                              cbg.key_bol_ref
                                                       AND ope.key_lin_nbr =
                                                              cbg.key_lin_nbr
                                                       AND ope.car_ope_typ =
                                                              'LOC') = 0 -- que no tenga localizacion
                                UNION
                                SELECT   DISTINCT
                                         cg.key_cuo || ': ' || b.cuo_nam
                                             aduanaorigen,
                                            cg.key_cuo
                                         || ' '
                                         || cg.car_reg_year
                                         || ' '
                                         || cg.car_reg_nber
                                             registromanifiesto,
                                         cg.car_id_trp numeroplaca,
                                         cg.car_car_cod identificacionempresa,
                                         cg.car_car_nam nombreempresa,
                                         cg.car_pac_nber totalbultos,
                                         cg.car_reg_date fecharegistro,
                                         cg.car_reg_time horaregistro,
                                         cg.car_gros_mass pesobrutototal,
                                         cbg.key_bol_ref docembarque,
                                            cbg.key_lin_nbr
                                         || '/'
                                         || cbg.carbol_sline_nber
                                             nroitem,
                                         NVL (cbg.carbol_frt_prep, cg.key_cuo)
                                             aduanadestino,
                                         b.cuo_nam descripcionaduana,
                                         cbg.carbol_nat_cod tipomanifiesto,
                                         cbg.carbol_gros_mas pesobruto,
                                         cbg.carbol_pack_nber cantidadbultos,
                                         cbg.carbol_pack_cod tipobultos,
                                            NVL (cbg.carbol_seal_mrks1, '-')
                                         || ' '
                                         || NVL (cbg.carbol_seal_mrks2, '-')
                                         || '/'
                                         || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                                         NVL (cbg.carbol_cons_cod, '-')
                                             identificacionconsignatario,
                                         NVL (cbg.carbol_cons_nam, '-')
                                             nombreconsignatario,
                                            NVL (cbg.carbol_good1, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good2, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good3, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good4, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good5, ' ')
                                             descripcionmercancia,
                                         ctn.car_ctn_nbr nrocontenedor,
                                         NVL (ctn.car_ctn_ident, '-')
                                             precintocont,
                                         NVL (ctn.car_ctn_typ, '-')
                                             clasificacion
                                  FROM   ops$asy.uncuotab b,
                                         ops$asy.car_gen cg,
                                         ops$asy.car_bol_gen cbg,
                                         ops$asy.car_bol_ctn ctn
                                 WHERE       cg.key_cuo = cbg.key_cuo
                                         AND cg.key_voy_nber = cbg.key_voy_nber
                                         AND cg.key_dep_date = cbg.key_dep_date
                                         AND cbg.key_cuo = ctn.key_cuo(+)
                                         AND cbg.key_voy_nber =
                                                ctn.key_voy_nber(+)
                                         AND cbg.key_dep_date =
                                                ctn.key_dep_date(+)
                                         AND cbg.key_bol_ref =
                                                ctn.key_bol_ref(+)
                                         AND cbg.key_lin_nbr =
                                                ctn.key_lin_nbr(+)
                                         AND cg.key_cuo = p_aduanadestino
                                         AND cg.car_reg_date BETWEEN TO_DATE (
                                                                         p_fecha_ini,
                                                                         'dd/mm/yyyy HH24:mi:ss')
                                                                 AND  TO_DATE (
                                                                          p_fecha_fin,
                                                                          'dd/mm/yyyy HH24:mi:ss')
                                         AND cg.key_cuo = b.cuo_cod
                                         AND b.lst_ope = 'U'
                                         AND cbg.carbol_nat_cod IN ('23', '28')
                                         AND cg.car_tr_regref IS NULL
                                         AND cg.key_voy_nber NOT LIKE 'CONS%'
                                         AND (SELECT   COUNT (1)
                                                FROM   car_bol_ope ope
                                               WHERE   ope.key_cuo =
                                                           cbg.key_cuo
                                                       AND ope.key_voy_nber =
                                                              cbg.key_voy_nber
                                                       AND ope.key_dep_date =
                                                              cbg.key_dep_date
                                                       AND ope.key_bol_ref =
                                                              cbg.key_bol_ref
                                                       AND ope.key_lin_nbr =
                                                              cbg.key_lin_nbr
                                                       AND ope.car_ope_typ IN
                                                                  ('LOC', 'ASS')) =
                                                0 -- que no tenga localizacion O dui en caso de aeropuertos
                                UNION
                                SELECT   DISTINCT
                                         cg.key_cuo || ': ' || b.cuo_nam
                                             aduanaorigen,
                                            cg.key_cuo
                                         || ' '
                                         || cg.car_reg_year
                                         || ' '
                                         || cg.car_reg_nber
                                             registromanifiesto,
                                         cg.car_id_trp numeroplaca,
                                         cg.car_car_cod identificacionempresa,
                                         cg.car_car_nam nombreempresa,
                                         cg.car_pac_nber totalbultos,
                                         cg.car_reg_date fecharegistro,
                                         cg.car_reg_time horaregistro,
                                         cg.car_gros_mass pesobrutototal,
                                         cbg.key_bol_ref docembarque,
                                            cbg.key_lin_nbr
                                         || '/'
                                         || cbg.carbol_sline_nber
                                             nroitem,
                                         NVL (cbg.carbol_frt_prep, cg.key_cuo)
                                             aduanadestino,
                                         b.cuo_nam descripcionaduana,
                                         cbg.carbol_nat_cod tipomanifiesto,
                                         cbg.carbol_gros_mas pesobruto,
                                         cbg.carbol_pack_nber cantidadbultos,
                                         cbg.carbol_pack_cod tipobultos,
                                            NVL (cbg.carbol_seal_mrks1, '-')
                                         || ' '
                                         || NVL (cbg.carbol_seal_mrks2, '-')
                                         || '/'
                                         || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                                         NVL (cbg.carbol_cons_cod, '-')
                                             identificacionconsignatario,
                                         NVL (cbg.carbol_cons_nam, '-')
                                             nombreconsignatario,
                                            NVL (cbg.carbol_good1, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good2, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good3, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good4, ' ')
                                         || '.'
                                         || NVL (cbg.carbol_good5, ' ')
                                             descripcionmercancia,
                                         ctn.car_ctn_nbr nrocontenedor,
                                         NVL (ctn.car_ctn_ident, '-')
                                             precintocont,
                                         NVL (ctn.car_ctn_typ, '-')
                                             clasificacion
                                  FROM   ops$asy.uncuotab b,
                                         ops$asy.car_gen cg,
                                         ops$asy.car_bol_gen cbg,
                                         ops$asy.car_bol_ctn ctn,
                                         ops$asy.sad_gen gen
                                 WHERE       cg.key_cuo = cbg.key_cuo
                                         AND cg.key_voy_nber = cbg.key_voy_nber
                                         AND cg.key_dep_date = cbg.key_dep_date
                                         AND cbg.key_cuo = ctn.key_cuo(+)
                                         AND cbg.key_voy_nber =
                                                ctn.key_voy_nber(+)
                                         AND cbg.key_dep_date =
                                                ctn.key_dep_date(+)
                                         AND cbg.key_bol_ref =
                                                ctn.key_bol_ref(+)
                                         AND cbg.key_lin_nbr =
                                                ctn.key_lin_nbr(+)
                                         AND cg.key_cuo = p_aduanadestino
                                         AND cg.car_reg_date BETWEEN TO_DATE (
                                                                         p_fecha_ini,
                                                                         'dd/mm/yyyy HH24:mi:ss')
                                                                 AND  TO_DATE (
                                                                          p_fecha_fin,
                                                                          'dd/mm/yyyy HH24:mi:ss')
                                         AND cg.key_cuo = b.cuo_cod
                                         AND b.lst_ope = 'U'
                                         AND cbg.carbol_nat_cod = '22'
                                         AND SUBSTR (cbg.carbol_ucr_ref, 1, 4) =
                                                gen.sad_reg_year
                                         AND SUBSTR (cbg.carbol_ucr_ref, 6, 3) =
                                                gen.key_cuo
                                         AND SUBSTR (cbg.carbol_ucr_ref, 10, 1) =
                                                gen.sad_reg_serial
                                         AND SUBSTR (
                                                cbg.carbol_ucr_ref,
                                                12,
                                                  INSTR (cbg.carbol_ucr_ref,
                                                         '&',
                                                         1,
                                                         4)
                                                - INSTR (cbg.carbol_ucr_ref,
                                                         '&',
                                                         1,
                                                         3)
                                                - 1) = gen.sad_reg_nber
                                         AND (SELECT   COUNT (1)
                                                FROM   ops$asy.sad_exp_rls rls
                                               WHERE   gen.key_year =
                                                           rls.key_year
                                                       AND gen.key_cuo =
                                                              rls.key_cuo
                                                       AND ( (gen.key_dec =
                                                                  rls.key_dec)
                                                            OR (gen.key_dec IS NULL))
                                                       AND gen.key_nber =
                                                              rls.key_nber) = 0 -- que no tenga certificado de salida emitido
                                                                               )
                    ORDER BY   registromanifiesto, docembarque;

                p_mensaje := 'OK';
            ELSE
                OPEN cd FOR
                    SELECT   ''
                      FROM   DUAL
                     WHERE   1 = 0;

                p_mensaje :=
                    'Error: Aduana destino no corresponde a su concesion';
            END IF;
        ELSE
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Error: Usuario no corresponde a su concesion';
        END IF;

        RETURN cd;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 1;

            p_mensaje := 'No existen transitos pendientes';
            RETURN cd;
        WHEN OTHERS
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Error desconocido';
            RETURN cd;
    END manifiesto_23;

    FUNCTION consulta_origen_dab (p_aduanaorigen    IN     VARCHAR2,
                                  p_gestion         IN     VARCHAR2,
                                  p_registro        IN     VARCHAR2,
                                  p_identificador   IN     VARCHAR2,
                                  p_mensaje            OUT VARCHAR2)
        RETURN cursortype
    IS
        cd      cursortype;
        v_ide   VARCHAR2 (20);
    BEGIN
        p_mensaje := 'NOOK';

        IF p_identificador = 'DAB'
        THEN
            OPEN cd FOR
                  SELECT   DISTINCT
                           cg.key_cuo aduanaorigen,
                           cbg.carbol_frt_prep aduanadestino,
                           cg.car_reg_nber manifiesto,
                           cg.car_reg_year gestion,
                           cg.car_id_trp numeroplaca,
                           --solo cuenta los d/e que pertenecen a DAB,
                           (SELECT   COUNT (1)
                              FROM   car_bol_gen bol
                             WHERE       bol.key_cuo = cg.key_cuo
                                     AND bol.key_voy_nber = cg.key_voy_nber
                                     AND bol.key_dep_date = cg.key_dep_date
                                     AND bol.carbol_frt_prep IN
                                                ('201',
                                                 '221',
                                                 '241',
                                                 '311',
                                                 '401',
                                                 '601',
                                                 '711',
                                                 '721',
                                                 '722',
                                                 '741',
                                                 '743',
                                                 '841'))
                               cantidaddocemb,
                           /*(SELECT COUNT (1)
                              FROM car_bol_gen bol
                             WHERE bol.key_cuo = cbg.key_cuo
                               AND bol.key_voy_nber = cbg.key_voy_nber
                               AND bol.key_dep_date = cbg.key_dep_date
                               and bol.key_bol_ref = cbg.key_bol_ref ) cantidadContenedores*/
                           cg.car_cntr_nbr cantidadcontenedores
                    FROM   transitos.tra_pla_rut a,
                           ops$asy.car_gen cg,
                           ops$asy.car_bol_gen cbg
                   WHERE       a.key_cuo = cg.key_cuo
                           AND a.car_reg_year = cg.car_reg_year
                           AND a.car_reg_nber = cg.car_reg_nber
                           AND cg.key_cuo = cbg.key_cuo
                           AND cg.key_voy_nber = cbg.key_voy_nber
                           AND cg.key_dep_date = cbg.key_dep_date
                           AND cg.key_cuo IN
                                      ('071',
                                       '072',
                                       '201',
                                       '221',
                                       '241',
                                       '311',
                                       '401',
                                       '601',
                                       '711',
                                       '721',
                                       '722',
                                       '741',
                                       '743',
                                       '841') -- solo el origen que pertenezca a esa concesion
                           --AND cbg.carbol_frt_prep IN ('201','221','241','311','401','601','711','721','722','741','743','841') -- solo el destino que pertenezca a esa concesion
                           AND a.key_cuo = p_aduanaorigen                --422
                           AND a.car_reg_year = p_gestion               --2012
                           AND a.car_reg_nber = p_registro           -- 411784
                           AND a.tra_num = 0
                           AND a.lst_ope = 'U'
                           AND a.key_secuencia > 0
                           AND a.tra_fec_des IS NULL
                ORDER BY      cg.key_cuo
                           || ' '
                           || cg.car_reg_year
                           || ' '
                           || cg.car_reg_nber;
        ELSE
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Manifiesto no pertenece al concesionario DAB';
            RETURN cd;
        END IF;

        p_mensaje := 'OK';
        RETURN cd;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 1;

            p_mensaje := 'No existen transitos en curso';
            RETURN cd;
        WHEN OTHERS
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Error desconocido.';
            RETURN cd;
    END consulta_origen_dab;

    FUNCTION consulta_destino_dab (p_aduanaorigen    IN     VARCHAR2,
                                   p_gestion         IN     VARCHAR2,
                                   p_registro        IN     VARCHAR2,
                                   p_identificador   IN     VARCHAR2,
                                   p_mensaje            OUT VARCHAR2)
        RETURN cursortype
    IS
        cd      cursortype;
        v_ide   VARCHAR2 (20);
    BEGIN
        p_mensaje := 'NOOK';

        IF p_identificador = 'DAB'
        THEN
            OPEN cd FOR
                  SELECT   DISTINCT
                           cg.key_cuo aduanaorigen,
                           cbg.carbol_frt_prep aduanadestino,
                           cg.car_reg_nber manifiesto,
                           cg.car_reg_year gestion,
                           cg.car_id_trp numeroplaca,
                           --solo cuenta los d/e que pertenecen a DAB,
                           (SELECT   COUNT (1)
                              FROM   car_bol_gen bol
                             WHERE       bol.key_cuo = cg.key_cuo
                                     AND bol.key_voy_nber = cg.key_voy_nber
                                     AND bol.key_dep_date = cg.key_dep_date
                                     AND bol.carbol_frt_prep IN
                                                ('201',
                                                 '221',
                                                 '241',
                                                 '311',
                                                 '401',
                                                 '601',
                                                 '711',
                                                 '721',
                                                 '722',
                                                 '741',
                                                 '743',
                                                 '841'))
                               cantidaddocemb,
                           ctn.car_ctn_nbr secuencialcont,
                           NVL (ctn.car_ctn_ident, '-') identifcont,
                           NVL (ctn.car_ctn_typ, '-') tipocont,
                           NVL (TO_CHAR (cbg.carbol_seal_nber), '-')
                               cantprecinto,
                           DECODE (
                                  ctn.car_ctn_seal1
                               || ctn.car_ctn_seal2
                               || ctn.car_ctn_seal3,
                               NULL,
                               '-',
                               DECODE (
                                   car_ctn_seal,
                                   'RE',
                                      ctn.car_ctn_seal1
                                   || '-'
                                   || ctn.car_ctn_seal2
                                   || '-'
                                   || ctn.car_ctn_seal3,
                                   '-'))
                               precinto,
                           cbg.key_lin_nbr numeroitem,
                           cbg.key_bol_ref docembarque,
                           cbg.carbol_pack_nber cantidadbultos,
                           cbg.carbol_gros_mas pesobruto,
                           NVL (cbg.carbol_cons_nam, '-') nombreconsignatario,
                           NVL (cbg.carbol_cust_value, 0) valorfob,
                              NVL (cbg.carbol_good1, ' ')
                           || '.'
                           || NVL (cbg.carbol_good2, ' ')
                           || '.'
                           || NVL (cbg.carbol_good3, ' ')
                           || '.'
                           || NVL (cbg.carbol_good4, ' ')
                           || '.'
                           || NVL (cbg.carbol_good5, ' ')
                               descripcionmercancia
                    FROM   transitos.tra_pla_rut a,
                           ops$asy.car_gen cg,
                           ops$asy.car_bol_gen cbg,
                           ops$asy.car_bol_ctn ctn
                   WHERE       a.key_cuo = cg.key_cuo
                           AND a.car_reg_year = cg.car_reg_year
                           AND a.car_reg_nber = cg.car_reg_nber
                           AND cg.key_cuo = cbg.key_cuo
                           AND cg.key_voy_nber = cbg.key_voy_nber
                           AND cg.key_dep_date = cbg.key_dep_date
                           AND cbg.key_cuo = ctn.key_cuo(+)
                           AND cbg.key_voy_nber = ctn.key_voy_nber(+)
                           AND cbg.key_dep_date = ctn.key_dep_date(+)
                           AND cbg.key_bol_ref = ctn.key_bol_ref(+)
                           AND cbg.key_lin_nbr = ctn.key_lin_nbr(+)
                           AND cbg.carbol_frt_prep IN
                                      ('201',
                                       '221',
                                       '241',
                                       '311',
                                       '401',
                                       '601',
                                       '711',
                                       '721',
                                       '722',
                                       '741',
                                       '743',
                                       '841') -- solo el destino que pertenezca a esa concesion
                           AND a.key_cuo = p_aduanaorigen
                           AND a.car_reg_year = p_gestion
                           AND a.car_reg_nber = p_registro
                           AND a.tra_num = 0
                           AND a.lst_ope = 'U'
                           AND a.key_secuencia > 0
                           AND a.tra_fec_des IS NULL
                ORDER BY      cg.key_cuo
                           || ' '
                           || cg.car_reg_year
                           || ' '
                           || cg.car_reg_nber,
                           cbg.key_bol_ref;
        ELSE
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Manifiesto no pertenece al concesionario DAB';
            RETURN cd;
        END IF;

        p_mensaje := 'OK';
        RETURN cd;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 1;

            p_mensaje := 'No existen transitos en curso';
            RETURN cd;
        WHEN OTHERS
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Error desconocido.';
            RETURN cd;
    END consulta_destino_dab;

    FUNCTION duilevantedab (
        p_sad_reg_year     IN     sad_gen.sad_reg_year%TYPE,
        p_key_cuo          IN     sad_gen.key_cuo%TYPE,
        p_sad_reg_serial   IN     sad_gen.sad_reg_serial%TYPE,
        p_sad_reg_nber     IN     sad_gen.sad_reg_nber%TYPE,
        p_identificador    IN     VARCHAR2,
        p_mensaje             OUT VARCHAR2)
        RETURN cursortype
    IS
        cr       cursortype;
        cont     NUMBER;
        k_year   VARCHAR2 (4);
        k_cuo    VARCHAR2 (3);
        k_dec    VARCHAR2 (20);
        k_bner   VARCHAR2 (20);
    --V_USU VARCHAR2(20) := SUBSTR (P_USUARIO, 1, 3);
    BEGIN
        --V_USU := UPPER(SUBSTR(P_USUARIO,1,3));
        p_mensaje := 'NO';

        -- VERIFICA SI EXISTE LA DECLARACI?N
        SELECT   COUNT (1)                           -- verifica si existe dui
          INTO   cont
          FROM   ops$asy.sad_gen gen
         WHERE       gen.sad_reg_year = p_sad_reg_year
                 AND gen.key_cuo = p_key_cuo
                 AND gen.sad_reg_serial = p_sad_reg_serial
                 AND gen.sad_reg_nber = p_sad_reg_nber
                 AND gen.sad_num = 0
                 AND gen.sad_flw = '1'
                 AND gen.lst_ope = 'U';

        IF NOT (cont > 0)
        THEN
            p_mensaje := 'Declaracion no existe';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        -- VERIFICA SI ESTA VIGENTE LA DECLARACION
        SELECT   COUNT (1)                     -- verifica si dui esta anulada
          INTO   cont
          FROM   ops$asy.sad_gen gen
         WHERE       gen.sad_reg_year = p_sad_reg_year
                 AND gen.key_cuo = p_key_cuo
                 AND gen.sad_reg_serial = p_sad_reg_serial
                 AND gen.sad_reg_nber = p_sad_reg_nber
                 AND gen.sad_num = 0
                 AND gen.sad_flw = '1'
                 AND gen.lst_ope = 'D';

        IF cont > 0
        THEN
            p_mensaje := 'Declaracion Anulada';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        -- SACA LA LLAVE
        SELECT   gen.key_year,
                 gen.key_cuo,
                 NVL (gen.key_dec, '0'),
                 gen.key_nber                        -- verifica si existe dui
          INTO   k_year,
                 k_cuo,
                 k_dec,
                 k_bner
          FROM   ops$asy.sad_gen gen
         WHERE       gen.sad_reg_year = p_sad_reg_year
                 AND gen.key_cuo = p_key_cuo
                 AND gen.sad_reg_serial = p_sad_reg_serial
                 AND gen.sad_reg_nber = p_sad_reg_nber
                 AND gen.sad_num = 0
                 AND gen.sad_flw = '1'
                 AND gen.lst_ope = 'U';

        -- VERIFICA SI LA DECLARACI?N TIENE LEVANTE
        SELECT   COUNT (1)                           -- verifica si existe dui
          INTO   cont
          FROM   ops$asy.sad_spy s
         WHERE       s.key_year = k_year
                 AND s.key_cuo = k_cuo
                 AND NVL (s.key_dec, '0') = k_dec
                 AND s.key_nber = k_bner
                 AND ( (s.spy_sta = 10 AND s.spy_act = 24 AND s.sad_clr = 0)
                      OR              -- solo considera los que tienen levante
                         (s.spy_sta = 6 AND s.spy_act = 9 AND s.sad_clr = 0));

        IF NOT (cont > 0)
        THEN
            p_mensaje := 'Declaracion sin Levante';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        IF p_identificador = 'DAB'
        THEN
            IF (   p_key_cuo = '201'
                OR p_key_cuo = '221'
                OR p_key_cuo = '241'
                OR p_key_cuo = '311'
                OR p_key_cuo = '401'
                OR p_key_cuo = '601'
                OR p_key_cuo = '711'
                OR p_key_cuo = '721'
                OR p_key_cuo = '722'
                OR p_key_cuo = '741'
                OR p_key_cuo = '743'
                OR p_key_cuo = '841')
            THEN
                p_mensaje := 'OK';
            ELSE
                p_mensaje := 'Declaracion no corresponde a su Concesion';

                OPEN cr FOR
                    SELECT   *
                      FROM   DUAL
                     WHERE   1 = 0;

                RETURN cr;
            END IF;
        ELSE
            p_mensaje := 'Identificador no corresponde al concesionario';

            OPEN cr FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cr;
        END IF;

        IF p_mensaje = 'OK'
        THEN
            IF k_dec = 0                                    -- declarante nulo
            THEN
                OPEN cr FOR
                    SELECT   gen.sad_reg_nber numerodui,
                             gen.sad_reg_date fecharegistro,
                             gen.sad_typ_dec || '-' || gen.sad_typ_proc
                                 patrondui,
                             DECODE (
                                 gen.sad_manif_nber,
                                 NULL,
                                 '-1',
                                 gen.key_cuo || ' ' || gen.sad_manif_nber)
                                 numeromanifiesto,
                             NVL (gen.sad_consignee, cns.sad_con_zip)
                                 idconsignatario,
                             DECODE (gen.sad_consignee,
                                     NULL, cns.sad_con_nam,
                                     cmp.cmp_nam)
                                 nombreconsignatario,
                             '' iddeclarante,
                             (SELECT   d.sad_dec_nam
                                FROM   ops$asy.sad_occ_dec d
                               WHERE       gen.key_year = d.key_year
                                       AND gen.key_cuo = d.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND d.key_dec IS NULL
                                       AND gen.key_nber = d.key_nber
                                       AND d.sad_num = 0)
                                 nombredeclarante,
                             gen.sad_loc_goods localizacion,
                             to_char(gen.sad_val_details) costostotal,
                             to_char(gen.sad_tot_invoiced) valorfobtotal,
                             (SELECT   rat.rat_exc
                                FROM   ops$asy.unrattab rat
                               WHERE       rat.cur_cod = gen.sad_cur_cod
                                       AND rat.lst_ope = 'U'
                                       AND gen.sad_reg_date >= rat.eea_dov
                                       AND gen.sad_reg_date <=
                                              NVL (rat.eea_eov, SYSDATE))
                                 tipocambio,
                             (SELECT   to_char(vim.sad_icif_valn)
                                FROM   ops$asy.sad_gen_vim vim
                               WHERE       vim.key_year = gen.key_year
                                       AND vim.key_cuo = gen.key_cuo
                                       AND vim.key_dec IS NULL
                                       AND gen.key_dec IS NULL
                                       AND vim.key_nber = gen.key_nber
                                       AND vim.sad_num = gen.sad_num)
                                 valorciftotal,
                             (SELECT   SUM (it.saditm_pack_nber)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND it.key_dec IS NULL
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 cantidadbultostotal,
                             (SELECT   SUM (it.saditm_gross_mass)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec IS NULL
                                       AND it.key_dec IS NULL
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 pesobrutototal,
                             lev.upd_dat fechalevante,
                             NVL (sal.upd_dat,
                                  TO_DATE ('01/01/1900', 'dd/mm/yyyy'))
                                 fechapasesalida,
                             itm.itm_nber numeroitem,
                             itm.saditm_hs_cod || itm.saditm_hsprec_cod
                                 codigonandina,
                             itm.saditm_goods_desc3 desccomercial,
                             itm.saditm_gross_mass pesobruto,
                             itm.saditm_net_mass pesoneto,
                             itm.saditm_supp_units cantidadunidades,
                             itm.saditm_pack_kndcod codigoembalaje,
                             to_char(itm.saditm_itm_price) valorfobitem,
                             to_char(itm.saditm_stat_val) valorcifitem,
                             DECODE (gen.sad_manif_nber,
                                     NULL, '-1',
                                     itm.saditm_trsp_doc)
                                 documentoembarque
                      FROM   ops$asy.sad_gen gen,
                             ops$asy.sad_itm itm,
                             ops$asy.sad_spy lev,
                             ops$asy.sad_spy sal,
                             ops$asy.sad_occ_cns cns,
                             ops$asy.uncmptab cmp
                     WHERE       gen.key_year = itm.key_year
                             AND gen.key_cuo = itm.key_cuo
                             AND gen.key_dec IS NULL
                             AND itm.key_dec IS NULL
                             AND gen.key_nber = itm.key_nber
                             AND gen.sad_num = itm.sad_num
                             AND gen.sad_num = 0
                             AND gen.lst_ope = 'U'
                             AND gen.sad_flw = '1'
                             AND gen.key_year = lev.key_year
                             AND gen.key_cuo = lev.key_cuo
                             AND lev.key_dec IS NULL
                             AND gen.key_nber = lev.key_nber
                             AND ( (    lev.spy_sta = 10
                                    AND lev.spy_act = 24
                                    AND lev.sad_clr = 0)
                                  OR  -- solo considera los que tienen levante
                                     (    lev.spy_sta = 6
                                      AND lev.spy_act = 9
                                      AND lev.sad_clr = 0))
                             AND gen.key_year = sal.key_year(+)
                             AND gen.key_cuo = sal.key_cuo(+)
                             AND sal.key_dec(+) IS NULL
                             AND gen.key_nber = sal.key_nber(+)
                             AND sal.spy_act(+) = 25 -- solo considera los que tienen levante
                             AND gen.key_year = cns.key_year(+)
                             AND gen.key_cuo = cns.key_cuo(+)
                             AND cns.key_dec(+) IS NULL
                             AND gen.key_nber = cns.key_nber(+)
                             AND gen.sad_num = cns.sad_num(+)
                             AND gen.sad_consignee = cmp.cmp_cod(+)
                             AND cmp.lst_ope(+) = 'U'
                             AND gen.sad_reg_year = p_sad_reg_year
                             AND gen.key_cuo = p_key_cuo
                             AND gen.sad_reg_serial = p_sad_reg_serial
                             AND gen.sad_reg_nber = p_sad_reg_nber;
            ELSE                                         -- declarante no nulo
                OPEN cr FOR
                    SELECT   gen.sad_reg_nber numerodui,
                             gen.sad_reg_date fecharegistro,
                             gen.sad_typ_dec || '-' || gen.sad_typ_proc
                                 patrondui,
                             DECODE (
                                 gen.sad_manif_nber,
                                 NULL,
                                 '-1',
                                 gen.key_cuo || ' ' || gen.sad_manif_nber)
                                 numeromanifiesto,
                             NVL (gen.sad_consignee, cns.sad_con_zip)
                                 idconsignatario,
                             DECODE (gen.sad_consignee,
                                     NULL, cns.sad_con_nam,
                                     cmp.cmp_nam)
                                 nombreconsignatario,
                             gen.key_dec iddeclarante,
                             (SELECT   dec_nam
                                FROM   ops$asy.undectab d
                               WHERE   gen.key_dec = d.dec_cod
                                       AND d.lst_ope = 'U')
                                 nombredeclarante,
                             gen.sad_loc_goods localizacion,
                             to_char(gen.sad_val_details) costostotal,
                             to_char(gen.sad_tot_invoiced) valorfobtotal,
                             (SELECT   rat.rat_exc
                                FROM   ops$asy.unrattab rat
                               WHERE       rat.cur_cod = gen.sad_cur_cod
                                       AND rat.lst_ope = 'U'
                                       AND gen.sad_reg_date >= rat.eea_dov
                                       AND gen.sad_reg_date <=
                                              NVL (rat.eea_eov, SYSDATE))
                                 tipocambio,
                             (SELECT   to_char(vim.sad_icif_valn)
                                FROM   ops$asy.sad_gen_vim vim
                               WHERE       vim.key_year = gen.key_year
                                       AND vim.key_cuo = gen.key_cuo
                                       AND vim.key_dec = gen.key_dec
                                       AND vim.key_nber = gen.key_nber
                                       AND vim.sad_num = gen.sad_num)
                                 valorciftotal,
                             (SELECT   SUM (it.saditm_pack_nber)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec = it.key_dec
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 cantidadbultostotal,
                             (SELECT   SUM (it.saditm_gross_mass)
                                FROM   ops$asy.sad_itm it
                               WHERE       gen.key_year = it.key_year
                                       AND gen.key_cuo = it.key_cuo
                                       AND gen.key_dec = it.key_dec
                                       AND gen.key_nber = it.key_nber
                                       AND it.sad_num = 0)
                                 pesobrutototal,
                             lev.upd_dat fechalevante,
                             NVL (sal.upd_dat,
                                  TO_DATE ('01/01/1900', 'dd/mm/yyyy'))
                                 fechapasesalida,
                             itm.itm_nber numeroitem,
                             itm.saditm_hs_cod || itm.saditm_hsprec_cod
                                 codigonandina,
                             itm.saditm_goods_desc3 desccomercial,
                             itm.saditm_gross_mass pesobruto,
                             itm.saditm_net_mass pesoneto,
                             itm.saditm_supp_units cantidadunidades,
                             itm.saditm_pack_kndcod codigoembalaje,
                             to_char(itm.saditm_itm_price) valorfobitem,
                             to_char(itm.saditm_stat_val) valorcifitem,
                             DECODE (gen.sad_manif_nber,
                                     NULL, '-1',
                                     itm.saditm_trsp_doc)
                                 documentoembarque
                      FROM   ops$asy.sad_gen gen,
                             ops$asy.sad_itm itm,
                             ops$asy.sad_spy lev,
                             ops$asy.sad_spy sal,
                             ops$asy.sad_occ_cns cns,
                             ops$asy.uncmptab cmp
                     WHERE       gen.key_year = itm.key_year
                             AND gen.key_cuo = itm.key_cuo
                             AND gen.key_dec = itm.key_dec
                             AND gen.key_nber = itm.key_nber
                             AND gen.sad_num = itm.sad_num
                             AND gen.sad_num = 0
                             AND gen.lst_ope = 'U'
                             AND gen.sad_flw = '1'
                             AND gen.key_year = lev.key_year
                             AND gen.key_cuo = lev.key_cuo
                             AND gen.key_dec = lev.key_dec
                             AND gen.key_nber = lev.key_nber
                             AND ( (    lev.spy_sta = 10
                                    AND lev.spy_act = 24
                                    AND lev.sad_clr = 0)
                                  OR  -- solo considera los que tienen levante
                                     (    lev.spy_sta = 6
                                      AND lev.spy_act = 9
                                      AND lev.sad_clr = 0))
                             AND gen.key_year = sal.key_year(+)
                             AND gen.key_cuo = sal.key_cuo(+)
                             AND gen.key_dec = sal.key_dec(+)
                             AND gen.key_nber = sal.key_nber(+)
                             AND sal.spy_act(+) = 25 -- solo considera los que tienen levante
                             AND gen.key_year = cns.key_year(+)
                             AND gen.key_cuo = cns.key_cuo(+)
                             AND gen.key_dec = cns.key_dec(+)
                             AND gen.key_nber = cns.key_nber(+)
                             AND gen.sad_num = cns.sad_num(+)
                             AND gen.sad_consignee = cmp.cmp_cod(+)
                             AND cmp.lst_ope(+) = 'U'
                             AND gen.sad_reg_year = p_sad_reg_year
                             AND gen.key_cuo = p_key_cuo
                             AND gen.sad_reg_serial = p_sad_reg_serial
                             AND gen.sad_reg_nber = p_sad_reg_nber;
            END IF;
        END IF;

        RETURN cr;
    END duilevantedab;

    FUNCTION manifiesto_imp (p_aduanadestino   IN     VARCHAR2,
                                   p_fecha_ini       IN     VARCHAR2,
                                   p_fecha_fin       IN     VARCHAR2,
                                   p_identificador   IN     VARCHAR2,
                                   p_opcion          IN     VARCHAR2,
                                   p_mensaje         OUT    VARCHAR2)
        RETURN cursortype
    IS
        cd      cursortype;
        v_ide   VARCHAR2 (20);
        v_fecha_ini DATE := TO_DATE(p_fecha_ini,'DD/MM/YYYY');
        v_fecha_fin DATE := TO_DATE(p_fecha_fin,'DD/MM/YYYY');
        cont        NUMBER;
    BEGIN
        p_mensaje := 'NOOK';
        v_ide := SUBSTR (UPPER (p_identificador), 1, 3);

        -- VERIFICA EXISTENCIA DE USUARIO
        SELECT   COUNT (1)
          INTO   cont
          FROM   usuario.usuario
         WHERE       usucodusu = UPPER (p_identificador)
                 AND usu_num = 0
                 AND lst_ope = 'U';

        IF cont = 0
        THEN
            p_mensaje := 'Error, Usuario incorrecto';

            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF LENGTH (p_aduanadestino) <= 1
        THEN
            p_mensaje := 'Error, Aduana no existe';
            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF v_fecha_fin >= v_fecha_ini + 2
        THEN
            p_mensaje := 'Error, rango de fecha no permitido';
            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF p_opcion = '1'   -- opcion 1= manifiestos localizados
        THEN
            IF v_ide = 'DAB'
            THEN
                IF (   p_aduanadestino = '201'
                    OR p_aduanadestino = '221'
                    OR p_aduanadestino = '241'
                    OR p_aduanadestino = '311'
                    OR p_aduanadestino = '401'
                    OR p_aduanadestino = '601'
                    OR p_aduanadestino = '711'
                    OR p_aduanadestino = '721'
                    OR p_aduanadestino = '722'
                    OR p_aduanadestino = '741'
                    OR p_aduanadestino = '743'
                    OR p_aduanadestino = '841')
                THEN
                    OPEN cd FOR
                      SELECT DISTINCT cg.key_cuo aduanadestino,
                             b.cuo_nam descripcionaduana,
                                cg.key_cuo
                             || ' '
                             || cg.car_reg_year
                             || ' '
                             || cg.car_reg_nber
                                 registromanifiesto,
                             cg.car_id_trp numeroplaca,
                             cg.car_car_cod identificacionempresa,
                             cg.car_car_nam nombreempresa,
                             cg.car_pac_nber totalbultos,
                             cg.car_reg_date fecharegistro,
                             cg.car_reg_time horaregistro,
                             cg.car_gros_mass pesobrutototal,
                             cbg.key_bol_ref docembarque,
                                cbg.key_lin_nbr
                             || '/'
                             || cbg.carbol_sline_nber
                                 nroitem,
                             cbg.carbol_nat_cod tipomanifiesto,
                             cbg.carbol_gros_mas peso_manif,
                             cbg.carbol_pack_nber cantidad_manif,
                             loc.car_wgt_avl pesobruto,
                             loc.car_pkg_avl cantidadbultos,
                             cbo.car_wgt_avl saldo_peso,
                             CBO.car_pkg_avl saldo_cantidad,
                             cbg.carbol_pack_cod tipobultos,
                                NVL (cbg.carbol_seal_mrks1, '-')
                             || ' '
                             || NVL (cbg.carbol_seal_mrks2, '-')
                             || '/'
                             || decode(INSTR(cbg.carbol_shp_mark5,'&',1),0, cbg.carbol_shp_mark5, null) marcabultos,
                             cbg.carbol_shp_mark6||cbg.carbol_shp_mark7||cbg.carbol_shp_mark8||cbg.carbol_shp_mark9||cbg.carbol_shp_mark0 obser,
                             NVL (cbg.carbol_cons_cod, '-')
                                 identificacionconsignatario,
                             NVL (cbg.carbol_cons_nam, '-')
                                 nombreconsignatario,
                                NVL (cbg.carbol_good1, ' ')
                             || '.'
                             || NVL (cbg.carbol_good2, ' ')
                             || '.'
                             || NVL (cbg.carbol_good3, ' ')
                             || '.'
                             || NVL (cbg.carbol_good4, ' ')
                             || '.'
                             || NVL (cbg.carbol_good5, ' ')
                                 descripcionmercancia,
                             ctn.car_ctn_nbr nrocontenedor,
                             NVL (ctn.car_ctn_ident, '-')
                                 precintocont,
                             NVL (ctn.car_ctn_typ, '-')
                                 clasificacion
                      FROM   ops$asy.uncuotab b,
                             ops$asy.car_gen cg,
                             ops$asy.car_bol_gen cbg,
                             ops$asy.car_bol_ope cbo, ops$asy.car_bol_ope loc,
                             ops$asy.car_bol_ctn ctn
                     WHERE       cg.key_cuo = cbg.key_cuo
                             AND cg.key_voy_nber = cbg.key_voy_nber
                             AND cg.key_dep_date = cbg.key_dep_date
                             AND cbg.key_cuo = ctn.key_cuo(+)
                             AND cbg.key_voy_nber = ctn.key_voy_nber(+)
                             AND cbg.key_dep_date = ctn.key_dep_date(+)
                             AND cbg.key_bol_ref = ctn.key_bol_ref(+)
                             AND cbg.key_lin_nbr = ctn.key_lin_nbr(+)

                             AND cbg.key_cuo = cbo.key_cuo
                             AND cbg.key_voy_nber = cbo.key_voy_nber
                             AND cbg.key_dep_date = cbo.key_dep_date
                             AND cbg.key_bol_ref = cbo.key_bol_ref
                             AND cbg.key_lin_nbr = cbo.key_lin_nbr

                             AND cbg.key_cuo = loc.key_cuo
                             AND cbg.key_voy_nber = loc.key_voy_nber
                             AND cbg.key_dep_date = loc.key_dep_date
                             AND cbg.key_bol_ref = loc.key_bol_ref
                             AND cbg.key_lin_nbr = loc.key_lin_nbr

                             and cbo.car_ope_nbr=(SELECT MAX(b.car_ope_nbr)
                                                        FROM CAR_BOL_OPE B
                                                       WHERE cbo.KEY_CUO=B.key_cuo
                                                         AND cbo.KEY_VOY_NBER=B.key_voy_nber
                                                         AND cbo.KEY_DEP_DATE=B.key_dep_date
                                                         AND cbo.KEY_BOL_REF=B.key_bol_ref
                                                      )
                             and cbo.car_pkg_avl > 0
                             and cbo.car_wgt_avl > 0
                             --and bol_ope.car_ope_typ <> 'MAN'   --manifiestos anulados o con descarga manual
                             and cbg.CARBOL_TYP_COD <> 'LTR'  -- transitos en lastre

                             AND cg.key_cuo = p_aduanadestino
                             AND cg.car_reg_date BETWEEN TO_DATE (
                                                             p_fecha_ini,
                                                             'dd/mm/yyyy')
                                                     AND  TO_DATE (
                                                              p_fecha_fin,
                                                              'dd/mm/yyyy')
                             AND cg.key_cuo = b.cuo_cod
                             AND b.lst_ope = 'U'
                             AND cbg.carbol_nat_cod = '23'
                             --AND cg.car_tr_regref NOT LIKE 'BO%'
                             AND cg.key_voy_nber NOT LIKE 'CONS%'

                             and loc.car_ope_nbr=(SELECT MIN(b.car_ope_nbr)
                                                        FROM CAR_BOL_OPE B
                                                       WHERE loc.KEY_CUO=B.key_cuo
                                                         AND loc.KEY_VOY_NBER=B.key_voy_nber
                                                         AND loc.KEY_DEP_DATE=B.key_dep_date
                                                         AND loc.KEY_BOL_REF=B.key_bol_ref
                                                         AND b.car_ope_typ = 'LOC'
                                                      )
                             AND (SELECT   COUNT (1)
                                    FROM   car_bol_ope ope
                                   WHERE   ope.key_cuo =
                                               cbg.key_cuo
                                           AND ope.key_voy_nber =
                                                  cbg.key_voy_nber
                                           AND ope.key_dep_date =
                                                  cbg.key_dep_date
                                           AND ope.key_bol_ref =
                                                  cbg.key_bol_ref
                                           AND ope.key_lin_nbr =
                                                  cbg.key_lin_nbr
                                           AND ope.car_ope_typ IN ('LOC','ASS')) > 0; -- que esten localizados o alguna descarga con DUI por ser aeropuertos
                ELSE
                    OPEN cd FOR
                        SELECT   ''
                          FROM   DUAL
                         WHERE   1 = 0;

                    p_mensaje := 'Aduana no pertenece al concesionario DAB';
                    RETURN cd;
                END IF;
            ELSE
                OPEN cd FOR
                    SELECT   ''
                      FROM   DUAL
                     WHERE   1 = 0;

                p_mensaje := 'Usuario no pertenece al concesionario DAB';
                RETURN cd;
            END IF;
        ELSE
            OPEN cd FOR
                    SELECT   ''
                      FROM   DUAL
                     WHERE   1 = 0;

                p_mensaje := 'Opcion no implementada';
                RETURN cd;
        END IF;
        p_mensaje := 'OK';
        RETURN cd;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 1;

            p_mensaje := 'No existen manifiestos pendientes de descargue';
            RETURN cd;
        WHEN OTHERS
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Error desconocido.';
            RETURN cd;
    END manifiesto_imp;

    FUNCTION consulta_arribados (p_aduanaorigen    IN     VARCHAR2,
                                 p_aduanadestino   IN     VARCHAR2,
                                 p_fecha_ini       IN     VARCHAR2,
                                 p_fecha_fin       IN     VARCHAR2,
                                 p_usuario         IN     VARCHAR2,
                                 p_mensaje            OUT VARCHAR2)
        RETURN cursortype
    IS
        cd          cursortype;
        v_usu       VARCHAR2 (20);
        v_adudest   VARCHAR2 (5);
        v           NUMBER;
        cont        NUMBER;
    BEGIN
        v_usu := SUBSTR (p_usuario, 1, 3);
        v_adudest := p_aduanadestino;

        p_mensaje := 'NO';

        -- VERIFICA EXISTENCIA DE USUARIO
        SELECT   COUNT (1)
          INTO   cont
          FROM   usuario.usuario
         WHERE       usucodusu = UPPER (p_usuario)
                 AND usu_num = 0
                 AND lst_ope = 'U';

        IF cont = 0
        THEN
            p_mensaje := 'Error, Usuario incorrecto';

            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF LENGTH (v_adudest) <= 1
        THEN
            v_adudest := '';
        END IF;

        -- VERIFICA que el usuario sea de la concesion, y que la aduana consultada es permitida para esa concesion
        IF v_usu = 'DAB'
        THEN
            IF (   p_aduanadestino = '201'
                OR p_aduanadestino = '221'
                OR p_aduanadestino = '241'
                OR p_aduanadestino = '311'
                OR p_aduanadestino = '401'
                OR p_aduanadestino = '601'
                OR p_aduanadestino = '711'
                OR p_aduanadestino = '721'
                OR p_aduanadestino = '722'
                OR p_aduanadestino = '741'
                OR p_aduanadestino = '743'
                OR p_aduanadestino = '841')
            THEN
                OPEN cd FOR
                      SELECT   DISTINCT
                               cg.key_cuo || ': ' || b.cuo_nam aduanaorigen,
                                  cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber
                                   registromanifiesto,
                               cg.car_id_trp numeroplaca,
                               cg.car_car_cod identificacionempresa,
                               cg.car_car_nam nombreempresa,
                               cg.car_pac_nber totalbultos,
                               cg.car_reg_date fecharegistro,
                               cg.car_reg_time horaregistro,
                               cg.car_gros_mass pesobrutototal,
                               cbg.key_bol_ref docembarque, --c.cuo_cod aduanaDestino,
                               cbg.carbol_frt_prep aduanadestino,
                               c.cuo_nam descripcionaduana,
                               cbg.carbol_gros_mas pesobruto,
                               cbg.carbol_pack_nber cantidadbultos,
                               cbg.carbol_pack_cod tipobultos,
                                  NVL (cbg.carbol_seal_mrks1, '-')
                               || ' '
                               || NVL (cbg.carbol_seal_mrks2, '-')
                                   marcabultos,
                               NVL (cbg.carbol_cons_cod, '-')
                                   identificacionconsignatario,
                               NVL (cbg.carbol_cons_nam, '-')
                                   nombreconsignatario,
                                  NVL (cbg.carbol_good1, ' ')
                               || '.'
                               || NVL (cbg.carbol_good2, ' ')
                               || '.'
                               || NVL (cbg.carbol_good3, ' ')
                               || '.'
                               || NVL (cbg.carbol_good4, ' ')
                               || '.'
                               || NVL (cbg.carbol_good5, ' ')
                                   descripcionmercancia
                        --case when ROUND (a.tra_fec_est - SYSDATE) < 0 then -1 else ROUND (a.tra_fec_est - SYSDATE) end as plazo
                        FROM   transitos.tra_pla_rut a,
                               ops$asy.uncuotab b,
                               ops$asy.uncuotab c,
                               ops$asy.uncuotab d,
                               ops$asy.car_gen cg,
                               ops$asy.car_bol_gen cbg
                       WHERE       a.key_cuo = cg.key_cuo
                               AND a.car_reg_year = cg.car_reg_year
                               AND a.car_reg_nber = cg.car_reg_nber
                               AND cg.key_cuo = cbg.key_cuo
                               AND cg.key_voy_nber = cbg.key_voy_nber
                               AND cg.key_dep_date = cbg.key_dep_date
                               AND cg.key_cuo LIKE '%' || p_aduanaorigen
                               AND cbg.carbol_frt_prep = p_aduanadestino
                               --AND trunc(a.tra_fec_ini) BETWEEN to_date(p_fecha_ini, 'dd/mm/yyyy') AND to_date(p_fecha_fin, 'dd/mm/yyyy')
                               AND a.tra_fec_ini BETWEEN TO_DATE (
                                                             p_fecha_ini,
                                                             'dd/mm/yyyy HH24:mi:ss')
                                                     AND  TO_DATE (
                                                              p_fecha_fin,
                                                              'dd/mm/yyyy HH24:mi:ss')
                               /*AND a.key_cuo = '072'
                               AND a.car_reg_year = '2012'
                               AND a.car_reg_nber in( 190095,279730)*/
                               AND cg.key_cuo = b.cuo_cod
                               AND b.lst_ope = 'U'
                               AND cbg.carbol_frt_prep = c.cuo_cod
                               AND c.lst_ope = 'U'
                               AND a.tra_cuo_des = d.cuo_cod(+)
                               AND d.lst_ope(+) = 'U'
                               AND a.tra_num = 0
                               AND a.lst_ope = 'U'
                               AND a.key_secuencia > 0
                               AND a.tra_fec_des IS NOT NULL
                    ORDER BY      cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber,
                               cbg.key_bol_ref;

                p_mensaje := 'OK';
            ELSIF v_adudest IS NULL
            THEN
                OPEN cd FOR
                      SELECT   DISTINCT
                               cg.key_cuo || ': ' || b.cuo_nam aduanaorigen,
                                  cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber
                                   registromanifiesto,
                               cg.car_id_trp numeroplaca,
                               cg.car_car_cod identificacionempresa,
                               cg.car_car_nam nombreempresa,
                               cg.car_pac_nber totalbultos,
                               cg.car_reg_date fecharegistro,
                               cg.car_reg_time horaregistro,
                               cg.car_gros_mass pesobrutototal,
                               cbg.key_bol_ref docembarque, --c.cuo_cod aduanaDestino,
                               cbg.carbol_frt_prep aduanadestino,
                               c.cuo_nam descripcionaduana,
                               cbg.carbol_gros_mas pesobruto,
                               cbg.carbol_pack_nber cantidadbultos,
                               cbg.carbol_pack_cod tipobultos,
                                  NVL (cbg.carbol_seal_mrks1, '-')
                               || ' '
                               || NVL (cbg.carbol_seal_mrks2, '-')
                                   marcabultos,
                               NVL (cbg.carbol_cons_cod, '-')
                                   identificacionconsignatario,
                               NVL (cbg.carbol_cons_nam, '-')
                                   nombreconsignatario,
                                  NVL (cbg.carbol_good1, ' ')
                               || '.'
                               || NVL (cbg.carbol_good2, ' ')
                               || '.'
                               || NVL (cbg.carbol_good3, ' ')
                               || '.'
                               || NVL (cbg.carbol_good4, ' ')
                               || '.'
                               || NVL (cbg.carbol_good5, ' ')
                                   descripcionmercancia
                        --case when ROUND (a.tra_fec_est - SYSDATE) < 0 then -1 else ROUND (a.tra_fec_est - SYSDATE) end as plazo
                        FROM   transitos.tra_pla_rut a,
                               ops$asy.uncuotab b,
                               ops$asy.uncuotab c,
                               ops$asy.uncuotab d,
                               ops$asy.car_gen cg,
                               ops$asy.car_bol_gen cbg
                       WHERE       a.key_cuo = cg.key_cuo
                               AND a.car_reg_year = cg.car_reg_year
                               AND a.car_reg_nber = cg.car_reg_nber
                               AND cg.key_cuo = cbg.key_cuo
                               AND cg.key_voy_nber = cbg.key_voy_nber
                               AND cg.key_dep_date = cbg.key_dep_date
                               AND cg.key_cuo LIKE '%' || p_aduanaorigen
                               AND cbg.carbol_frt_prep IN
                                          ('201',
                                           '221',
                                           '241',
                                           '311',
                                           '401',
                                           '601',
                                           '711',
                                           '721',
                                           '722',
                                           '741',
                                           '743',
                                           '841')
                               --AND trunc(a.tra_fec_ini) BETWEEN to_date(p_fecha_ini, 'dd/mm/yyyy') AND to_date(p_fecha_fin, 'dd/mm/yyyy')
                               AND a.tra_fec_ini BETWEEN TO_DATE (
                                                             p_fecha_ini,
                                                             'dd/mm/yyyy HH24:mi:ss')
                                                     AND  TO_DATE (
                                                              p_fecha_fin,
                                                              'dd/mm/yyyy HH24:mi:ss')
                               /*AND a.key_cuo = '072'
                               AND a.car_reg_year = '2012'
                               AND a.car_reg_nber in( 190095,279730)*/
                               AND cg.key_cuo = b.cuo_cod
                               AND b.lst_ope = 'U'
                               AND cbg.carbol_frt_prep = c.cuo_cod
                               AND c.lst_ope = 'U'
                               AND a.tra_cuo_des = d.cuo_cod(+)
                               AND d.lst_ope(+) = 'U'
                               AND a.tra_num = 0
                               AND a.lst_ope = 'U'
                               AND a.key_secuencia > 0
                               AND a.tra_fec_des IS NOT NULL
                    ORDER BY      cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber,
                               cbg.key_bol_ref;

                p_mensaje := 'OK';
            ELSE
                OPEN cd FOR
                    SELECT   ''
                      FROM   DUAL
                     WHERE   1 = 0;

                p_mensaje := 'Aduana destino incorrecto.';
            END IF;
        ELSIF v_usu = 'ALB'
        THEN
            IF (   p_aduanadestino = '101'
                OR p_aduanadestino = '211'
                OR p_aduanadestino = '301'
                OR p_aduanadestino = '421'
                OR p_aduanadestino = '422'
                OR p_aduanadestino = '521'
                OR p_aduanadestino = '543'
                OR p_aduanadestino = '621'
                OR p_aduanadestino = '641'
                OR p_aduanadestino = '701'
                OR p_aduanadestino = '711')
            THEN
                OPEN cd FOR
                      SELECT   DISTINCT
                               cg.key_cuo || ': ' || b.cuo_nam aduanaorigen,
                                  cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber
                                   registromanifiesto,
                               cg.car_id_trp numeroplaca,
                               cg.car_car_cod identificacionempresa,
                               cg.car_car_nam nombreempresa,
                               cg.car_pac_nber totalbultos,
                               cg.car_reg_date fecharegistro,
                               cg.car_reg_time horaregistro,
                               cg.car_gros_mass pesobrutototal,
                               cbg.key_bol_ref docembarque, --c.cuo_cod aduanaDestino,
                               cbg.carbol_frt_prep aduanadestino,
                               c.cuo_nam descripcionaduana,
                               cbg.carbol_gros_mas pesobruto,
                               cbg.carbol_pack_nber cantidadbultos,
                               cbg.carbol_pack_cod tipobultos,
                                  NVL (cbg.carbol_seal_mrks1, '-')
                               || ' '
                               || NVL (cbg.carbol_seal_mrks2, '-')
                                   marcabultos,
                               NVL (cbg.carbol_cons_cod, '-')
                                   identificacionconsignatario,
                               NVL (cbg.carbol_cons_nam, '-')
                                   nombreconsignatario,
                                  NVL (cbg.carbol_good1, ' ')
                               || '.'
                               || NVL (cbg.carbol_good2, ' ')
                               || '.'
                               || NVL (cbg.carbol_good3, ' ')
                               || '.'
                               || NVL (cbg.carbol_good4, ' ')
                               || '.'
                               || NVL (cbg.carbol_good5, ' ')
                                   descripcionmercancia
                        --case when ROUND (a.tra_fec_est - SYSDATE) < 0 then -1 else ROUND (a.tra_fec_est - SYSDATE) end as plazo
                        FROM   transitos.tra_pla_rut a,
                               ops$asy.uncuotab b,
                               ops$asy.uncuotab c,
                               ops$asy.uncuotab d,
                               ops$asy.car_gen cg,
                               ops$asy.car_bol_gen cbg
                       WHERE       a.key_cuo = cg.key_cuo
                               AND a.car_reg_year = cg.car_reg_year
                               AND a.car_reg_nber = cg.car_reg_nber
                               AND cg.key_cuo = cbg.key_cuo
                               AND cg.key_voy_nber = cbg.key_voy_nber
                               AND cg.key_dep_date = cbg.key_dep_date
                               AND cg.key_cuo LIKE '%' || p_aduanaorigen
                               AND cbg.carbol_frt_prep = p_aduanadestino
                               --AND trunc(a.tra_fec_ini) BETWEEN to_date(p_fecha_ini, 'dd/mm/yyyy') AND to_date(p_fecha_fin, 'dd/mm/yyyy')
                               AND a.tra_fec_ini BETWEEN TO_DATE (
                                                             p_fecha_ini,
                                                             'dd/mm/yyyy HH24:mi:ss')
                                                     AND  TO_DATE (
                                                              p_fecha_fin,
                                                              'dd/mm/yyyy HH24:mi:ss')
                               /*AND a.key_cuo = '072'
                               AND a.car_reg_year = '2012'
                               AND a.car_reg_nber in( 190095,279730)*/
                               AND cg.key_cuo = b.cuo_cod
                               AND b.lst_ope = 'U'
                               AND cbg.carbol_frt_prep = c.cuo_cod
                               AND c.lst_ope = 'U'
                               AND a.tra_cuo_des = d.cuo_cod(+)
                               AND d.lst_ope(+) = 'U'
                               AND a.tra_num = 0
                               AND a.lst_ope = 'U'
                               AND a.key_secuencia > 0
                               AND a.tra_fec_des IS NOT NULL
                    ORDER BY      cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber,
                               cbg.key_bol_ref;

                p_mensaje := 'OK';
            ELSIF v_adudest IS NULL
            THEN
                OPEN cd FOR
                      SELECT   DISTINCT
                               cg.key_cuo || ': ' || b.cuo_nam aduanaorigen,
                                  cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber
                                   registromanifiesto,
                               cg.car_id_trp numeroplaca,
                               cg.car_car_cod identificacionempresa,
                               cg.car_car_nam nombreempresa,
                               cg.car_pac_nber totalbultos,
                               cg.car_reg_date fecharegistro,
                               cg.car_reg_time horaregistro,
                               cg.car_gros_mass pesobrutototal,
                               cbg.key_bol_ref docembarque, --c.cuo_cod aduanaDestino,
                               cbg.carbol_frt_prep aduanadestino,
                               c.cuo_nam descripcionaduana,
                               cbg.carbol_gros_mas pesobruto,
                               cbg.carbol_pack_nber cantidadbultos,
                               cbg.carbol_pack_cod tipobultos,
                                  NVL (cbg.carbol_seal_mrks1, '-')
                               || ' '
                               || NVL (cbg.carbol_seal_mrks2, '-')
                                   marcabultos,
                               NVL (cbg.carbol_cons_cod, '-')
                                   identificacionconsignatario,
                               NVL (cbg.carbol_cons_nam, '-')
                                   nombreconsignatario,
                                  NVL (cbg.carbol_good1, ' ')
                               || '.'
                               || NVL (cbg.carbol_good2, ' ')
                               || '.'
                               || NVL (cbg.carbol_good3, ' ')
                               || '.'
                               || NVL (cbg.carbol_good4, ' ')
                               || '.'
                               || NVL (cbg.carbol_good5, ' ')
                                   descripcionmercancia
                        --case when ROUND (a.tra_fec_est - SYSDATE) < 0 then -1 else ROUND (a.tra_fec_est - SYSDATE) end as plazo
                        FROM   transitos.tra_pla_rut a,
                               ops$asy.uncuotab b,
                               ops$asy.uncuotab c,
                               ops$asy.uncuotab d,
                               ops$asy.car_gen cg,
                               ops$asy.car_bol_gen cbg
                       WHERE       a.key_cuo = cg.key_cuo
                               AND a.car_reg_year = cg.car_reg_year
                               AND a.car_reg_nber = cg.car_reg_nber
                               AND cg.key_cuo = cbg.key_cuo
                               AND cg.key_voy_nber = cbg.key_voy_nber
                               AND cg.key_dep_date = cbg.key_dep_date
                               AND cg.key_cuo LIKE '%' || p_aduanaorigen
                               AND cbg.carbol_frt_prep IN
                                          ('101',
                                           '211',
                                           '301',
                                           '421',
                                           '422',
                                           '521',
                                           '543',
                                           '621',
                                           '641',
                                           '701',
                                           '711')
                               --AND trunc(a.tra_fec_ini) BETWEEN to_date(p_fecha_ini, 'dd/mm/yyyy') AND to_date(p_fecha_fin, 'dd/mm/yyyy')
                               AND a.tra_fec_ini BETWEEN TO_DATE (
                                                             p_fecha_ini,
                                                             'dd/mm/yyyy HH24:mi:ss')
                                                     AND  TO_DATE (
                                                              p_fecha_fin,
                                                              'dd/mm/yyyy HH24:mi:ss')
                               /*AND a.key_cuo = '072'
                               AND a.car_reg_year = '2012'
                               AND a.car_reg_nber in( 190095,279730)*/
                               AND cg.key_cuo = b.cuo_cod
                               AND b.lst_ope = 'U'
                               AND cbg.carbol_frt_prep = c.cuo_cod
                               AND c.lst_ope = 'U'
                               AND a.tra_cuo_des = d.cuo_cod(+)
                               AND d.lst_ope(+) = 'U'
                               AND a.tra_num = 0
                               AND a.lst_ope = 'U'
                               AND a.key_secuencia > 0
                               AND a.tra_fec_des IS NOT NULL
                    ORDER BY      cg.key_cuo
                               || ' '
                               || cg.car_reg_year
                               || ' '
                               || cg.car_reg_nber,
                               cbg.key_bol_ref;

                p_mensaje := 'OK';
            ELSE
                OPEN cd FOR
                    SELECT   ''
                      FROM   DUAL
                     WHERE   1 = 0;

                p_mensaje := 'Aduana destino incorrecta.';
            END IF;
        ELSE
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Error: Usuario no corresponde al concesionario';
        END IF;

        RETURN cd;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 1;

            p_mensaje := 'No existen transitos pendientes';
            RETURN cd;
        WHEN OTHERS
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Error desconocido.';
            RETURN cd;
    END consulta_arribados;

    FUNCTION destino_dab_rango (p_aduanadestino   IN     VARCHAR2,
                                p_f_inicio        IN     VARCHAR2,
                                p_f_fin           IN     VARCHAR2,
                                p_identificador   IN     VARCHAR2,
                                p_mensaje         OUT    VARCHAR2)
        RETURN cursortype
    IS
        cd      cursortype;
        v_ide   VARCHAR2 (20);
        v_fecha_ini DATE := TO_DATE(p_f_inicio,'DD/MM/YYYY');
        v_fecha_fin DATE := TO_DATE(p_f_fin,'DD/MM/YYYY');
        cont        NUMBER;
    BEGIN
        p_mensaje := 'NOOK';

        v_ide := SUBSTR (UPPER (p_identificador), 1, 3);

        -- VERIFICA EXISTENCIA DE USUARIO
        SELECT   COUNT (1)
          INTO   cont
          FROM   usuario.usuario
         WHERE       usucodusu = UPPER (p_identificador)
                 AND usu_num = 0
                 AND lst_ope = 'U';

        IF cont = 0
        THEN
            p_mensaje := 'Error, Usuario incorrecto';

            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;

            RETURN cd;
        END IF;

        IF LENGTH (p_aduanadestino) <= 2
        THEN
            p_mensaje := 'Error, Aduana no existe';
            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;
            RETURN cd;
        END IF;

        IF v_fecha_fin >= v_fecha_ini + 2
        THEN
            p_mensaje := 'Error, rango de fecha no permitido';
            OPEN cd FOR
                SELECT   *
                  FROM   DUAL
                 WHERE   1 = 0;
            RETURN cd;
        END IF;

        IF v_ide = 'DAB'
        THEN
            IF (   p_aduanadestino = '201'
                    OR p_aduanadestino = '221'
                    OR p_aduanadestino = '241'
                    OR p_aduanadestino = '311'
                    OR p_aduanadestino = '401'
                    OR p_aduanadestino = '601'
                    OR p_aduanadestino = '711'
                    OR p_aduanadestino = '721'
                    OR p_aduanadestino = '722'
                    OR p_aduanadestino = '741'
                    OR p_aduanadestino = '743'
                    OR p_aduanadestino = '841')
            THEN
                OPEN cd FOR
                      SELECT DISTINCT
                            cg.key_cuo aduanaorigen,
                            cbg.carbol_frt_prep aduanadestino,
                            cg.car_reg_nber manifiesto,
                            cg.car_reg_year gestion,
                            cg.car_id_trp numeroplaca,
                            --solo cuenta los d/e que pertenecen a DAB,
                            (SELECT   COUNT (1)
                               FROM   car_bol_gen bol
                              WHERE       bol.key_cuo = cg.key_cuo
                                      AND bol.key_voy_nber = cg.key_voy_nber
                                      AND bol.key_dep_date = cg.key_dep_date
                                      AND bol.carbol_frt_prep IN
                                                 ('201',
                                                  '221',
                                                  '241',
                                                  '311',
                                                  '401',
                                                  '601',
                                                  '711',
                                                  '721',
                                                  '722',
                                                  '741',
                                                  '743',
                                                  '841'))
                                cantidaddocemb,
                            ctn.car_ctn_nbr secuencialcont,
                            NVL (ctn.car_ctn_ident, '-') identifcont,
                            NVL (ctn.car_ctn_typ, '-') tipocont,
                            NVL (TO_CHAR (cbg.carbol_seal_nber), '-')
                                cantprecinto,
                            DECODE (
                                   ctn.car_ctn_seal1
                                || ctn.car_ctn_seal2
                                || ctn.car_ctn_seal3,
                                NULL,
                                '-',
                                DECODE (
                                    car_ctn_seal,
                                    'RE',
                                       ctn.car_ctn_seal1
                                    || '-'
                                    || ctn.car_ctn_seal2
                                    || '-'
                                    || ctn.car_ctn_seal3,
                                    '-'))
                                precinto,
                            cbg.key_lin_nbr numeroitem,
                            cbg.key_bol_ref docembarque,
                            cbg.carbol_pack_nber cantidadbultos,
                            cbg.carbol_gros_mas pesobruto,
                            NVL (cbg.carbol_cons_nam, '-') nombreconsignatario,
                            NVL (cbg.carbol_cust_value, 0) valorfob,
                               NVL (cbg.carbol_good1, ' ')
                            || '.'
                            || NVL (cbg.carbol_good2, ' ')
                            || '.'
                            || NVL (cbg.carbol_good3, ' ')
                            || '.'
                            || NVL (cbg.carbol_good4, ' ')
                            || '.'
                            || NVL (cbg.carbol_good5, ' ')
                                descripcionmercancia
                     FROM   transitos.tra_pla_rut a,
                            ops$asy.car_gen cg,
                            ops$asy.car_bol_gen cbg,
                            ops$asy.car_bol_ctn ctn
                    WHERE       a.key_cuo = cg.key_cuo
                            AND a.car_reg_year = cg.car_reg_year
                            AND a.car_reg_nber = cg.car_reg_nber
                            AND cg.key_cuo = cbg.key_cuo
                            AND cg.key_voy_nber = cbg.key_voy_nber
                            AND cg.key_dep_date = cbg.key_dep_date
                            AND cbg.key_cuo = ctn.key_cuo(+)
                            AND cbg.key_voy_nber = ctn.key_voy_nber(+)
                            AND cbg.key_dep_date = ctn.key_dep_date(+)
                            AND cbg.key_bol_ref = ctn.key_bol_ref(+)
                            AND cbg.key_lin_nbr = ctn.key_lin_nbr(+)
                            AND cbg.carbol_frt_prep = p_aduanadestino
                            AND trunc(a.tra_fec_ini) BETWEEN TO_DATE (p_f_inicio,'dd/mm/yyyy')
                                                  AND TO_DATE (p_f_fin,'dd/mm/yyyy')
                            AND a.tra_num = 0
                            AND a.lst_ope = 'U'
                            AND a.key_secuencia > 0
                            AND a.tra_fec_des IS NULL
                 ORDER BY      cg.key_cuo
                            || ' '
                            || cg.car_reg_year
                            || ' '
                            || cg.car_reg_nber,
                            cbg.key_bol_ref;
            ELSE
                    OPEN cd FOR
                        SELECT   ''
                          FROM   DUAL
                         WHERE   1 = 0;

                    p_mensaje := 'Aduana no pertenece al concesionario DAB';
                    RETURN cd;
                END IF;
        ELSE
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := 'Usuario no pertenece al concesionario DAB';
            RETURN cd;
        END IF;
        p_mensaje := 'OK';
        RETURN cd;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 1;

            p_mensaje := 'No existen transitos en curso';
            RETURN cd;
        WHEN OTHERS
        THEN
            OPEN cd FOR
                SELECT   ''
                  FROM   DUAL
                 WHERE   1 = 0;

            p_mensaje := SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 500);
            RETURN cd;
    END destino_dab_rango;
END;
/

