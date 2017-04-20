CREATE OR REPLACE 
PACKAGE pkg_consulta
AS
   TYPE cursortype IS REF CURSOR;

   FUNCTION flista_aduana
      RETURN cursortype;
   FUNCTION r_manifiesto (p_aduana IN VARCHAR2, p_gestion IN VARCHAR2, p_registro IN DECIMAL, p_usucuo IN VARCHAR2, OPCION IN NUMBER)
      RETURN cursortype;
   FUNCTION l_manifiesto (p_usucuo IN VARCHAR2, OPCION IN DECIMAL)
      RETURN cursortype;
   FUNCTION l_manifiesto_placa (p_usucuo IN VARCHAR2, p_placa IN VARCHAR2, OPCION IN DECIMAL)
      RETURN cursortype;
END pkg_consulta;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_consulta
AS
    --PlazoEtiqueta
    bsalidapuerto        CONSTANT DECIMAL (2, 0) := 16;
    blistasalidapuerto   CONSTANT DECIMAL (2, 0) := 17;
   --Modificado Edgar 27112014 Nuevo OCE
    v_fecha_corte        CONSTANT DATE := to_date('15/12/2015','dd/mm/yyyy');

    FUNCTION flista_aduana
        RETURN cursortype
    IS
        cr   cursortype;
    BEGIN
        OPEN cr FOR
              SELECT   cuo_cod,
                       '<a1>' || cuo_cod || '</a1><a2>' || cuo_nam || '</a2>'
                FROM   ops$asy.uncuotab
               WHERE   lst_ope = 'U' AND NOT cuo_cod IN ('CUO01', 'ALL')
            ORDER BY   cuo_cod;

        RETURN cr;
    END flista_aduana;

    FUNCTION r_manifiesto (p_aduana     IN VARCHAR2,
                           p_gestion    IN VARCHAR2,
                           p_registro   IN DECIMAL,
                           p_usucuo     IN VARCHAR2,
                           opcion       IN NUMBER)
        RETURN cursortype
    IS
        cr          cursortype;
        v_gestion   VARCHAR2 (4) := TO_CHAR (SYSDATE, 'yyyy');
    BEGIN
        OPEN cr FOR
            SELECT   a.key_voy_nber,
                     TO_CHAR (a.key_dep_date, 'ddmmyyyy') dep_date,
                     a.car_cntr_nbr,
                     a.car_id_trp,
                     a.key_cuo,
                     a.car_reg_year,
                     a.car_reg_nber,
                     TO_CHAR (a.car_reg_date, 'dd/mm/yyyy') reg_date,
                     a.car_reg_time,
                     a.car_car_cod,
                     a.car_car_nam,
                     a.car_tr_regref,
                     TO_CHAR (a.car_tr_regdat, 'dd/mm/yyyy') tr_regdat,
                     NVL (a.car_mast_nam, ' ') car_mast_nam,
                     NVL (a.car_mast_inf1, ' ') car_mast_inf1,
                     a.car_mast_inf2,
                     a.car_bl_nber,
                     a.car_pac_nber,
                     a.car_gros_mass,
                     b.key_lin_nbr,
                     b.key_bol_ref,
                     b.carbol_gros_mas,
                     b.carbol_pack_nber,
                     b.carbol_pack_cod || '-' || c.pkg_dsc,
                        b.carbol_good1
                     || b.carbol_good2
                     || b.carbol_good3
                     || b.carbol_good4
                     || b.carbol_good5
                         goods
              FROM   ops$asy.car_gen a, ops$asy.car_bol_gen b, ops$asy.unpkgtab c
             WHERE       a.key_cuo = p_aduana
                     AND a.car_reg_year = p_gestion
                     AND car_reg_nber = p_registro
                     AND a.key_cuo = b.key_cuo
                     AND a.key_voy_nber = b.key_voy_nber
                     AND a.key_dep_date = b.key_dep_date
                     AND b.key_lin_nbr =
                            (SELECT   MAX (b.key_lin_nbr)
                               FROM   ops$asy.car_bol_gen bg
                              WHERE       a.key_cuo = bg.key_cuo
                                      AND a.key_voy_nber = bg.key_voy_nber
                                      AND a.key_dep_date = bg.key_dep_date
                                      AND bg.carbol_sline_nber = 0)
                     AND b.carbol_sline_nber = 0
                     AND b.carbol_pack_cod = c.pkg_cod
                     AND c.lst_ope = 'U';


        RETURN cr;
    END r_manifiesto;

    FUNCTION l_manifiesto (p_usucuo IN VARCHAR2, opcion IN DECIMAL)
        RETURN cursortype
    IS
        cr             cursortype;
        v_gestionact   VARCHAR2 (4) := TO_CHAR (SYSDATE, 'yyyy');
        v_gestionant   VARCHAR2 (4) := TO_CHAR (TO_NUMBER (v_gestionact) - 1);
    BEGIN
        OPEN cr FOR
              SELECT   a.car_id_trp placa,
                       a.key_cuo,
                       a.car_reg_year,
                       a.car_reg_nber,
                          a.key_cuo
                       || '/'
                       || a.car_reg_year
                       || '-'
                       || a.car_reg_nber
                           transito,
                       TO_CHAR (a.car_reg_date, 'dd/mm/yyyy') reg_date,
                       a.car_reg_time,
                       a.car_car_cod,
                       a.car_car_nam,
                       a.car_tr_regref,
                       TO_CHAR (a.car_tr_regdat, 'dd/mm/yyyy') tr_regdat,
                       NVL (a.car_mast_nam, ' ') car_mast_nam,
                       NVL (a.car_mast_inf1, ' ') car_mast_inf1,
                       a.car_mast_inf2,
                       a.car_bl_nber,
                       a.car_pac_nber,
                       a.car_gros_mass
                FROM   car_gen a,
                       (SELECT   DISTINCT
                                 b.key_cuo, b.key_voy_nber, b.key_dep_date
                          FROM   car_bol_gen b
                         WHERE   b.key_cuo = p_usucuo
                                 AND TO_CHAR (b.key_dep_date, 'yyyy') IN
                                            (v_gestionant, v_gestionact)
                                 AND b.carbol_nat_cod = '24') m
               WHERE       a.key_cuo = p_usucuo
                       AND car_reg_year IS NOT NULL
                       AND car_reg_nber > 0
                       AND a.key_cuo = m.key_cuo
                       AND a.key_voy_nber = m.key_voy_nber
                       AND a.key_dep_date = m.key_dep_date
                       AND a.key_cuo IN
                                  ('422',
                                   '072',
                                   '421',
                                   '722',
                                   '071',
                                   '241',
                                   '521',
                                   '621',
                                   '641',
                                   '643',
                                   '741',
                                   '721')
                       AND a.car_reg_year IN (v_gestionant, v_gestionact)
                       AND a.car_reg_date BETWEEN SYSDATE - 60 AND SYSDATE
                       AND a.car_reg_date >=
                              TO_DATE ('13/05/2014', 'dd/mm/yyyy')
                       AND 29 =
                              pkg_verifica_transito.fplazoetiqueta (
                                  a.key_cuo,
                                  a.car_reg_year,
                                  a.car_reg_nber,
                                  p_usucuo,
                                  opcion)
                       AND 0 < verifica_operador(a.car_car_cod,a.car_id_trp) --Modificado Edgar 27112014 Nuevo OCE

            ORDER BY   a.car_reg_date, a.car_reg_time;

        RETURN cr;
    END l_manifiesto;

    FUNCTION l_manifiesto_placa (p_usucuo   IN VARCHAR2,
                                 p_placa    IN VARCHAR2,
                                 opcion     IN DECIMAL)
        RETURN cursortype
    IS
        cr             cursortype;
        v_gestionact   VARCHAR2 (4) := TO_CHAR (SYSDATE, 'yyyy');
        v_gestionant   VARCHAR2 (4) := TO_CHAR (TO_NUMBER (v_gestionact) - 1);
    BEGIN

        IF (opcion = 17) THEN
        OPEN cr FOR
              SELECT   a.car_id_trp placa,
                       a.key_cuo,
                       a.car_reg_year,
                       a.car_reg_nber,
                       --a.key_cuo||'/'|| a.car_reg_year||'-'|| a.car_reg_nber transito,
                       a.car_reg_year || '-' || a.car_reg_nber transito,
                       TO_CHAR (a.car_reg_date, 'dd/mm/yyyy') reg_date,
                       a.car_reg_time,
                       a.car_car_cod,
                       a.car_car_nam,
                       a.car_tr_regref,
                       TO_CHAR (a.car_tr_regdat, 'dd/mm/yyyy') tr_regdat,
                       NVL (a.car_mast_nam, ' ') car_mast_nam,
                       NVL (a.car_mast_inf1, ' ') car_mast_inf1,
                       a.car_mast_inf2,
                       a.car_bl_nber,
                       a.car_pac_nber,
                       a.car_gros_mass,
                       '' precinto,
                       '' obs
                FROM   car_gen a,
                       (SELECT   DISTINCT
                                 b.key_cuo, b.key_voy_nber, b.key_dep_date
                          FROM   car_bol_gen b
                         WHERE   b.key_cuo = p_usucuo
                                 AND TO_CHAR (b.key_dep_date, 'yyyy') IN
                                            (v_gestionant, v_gestionact)
                                 AND b.carbol_nat_cod = '24') m
               WHERE       a.key_cuo = p_usucuo
                       AND car_reg_year IS NOT NULL
                       AND car_reg_nber > 0
                       AND a.key_cuo = m.key_cuo
                       AND a.key_voy_nber = m.key_voy_nber
                       AND a.key_dep_date = m.key_dep_date
                       AND a.key_cuo IN
                                  ('422',
                                   '072',
                                   '421',
                                   '722',
                                   '071',
                                   '241',
                                   '521',
                                   '621',
                                   '641',
                                   '643',
                                   '741',
                                   '721')
                       AND a.car_reg_year IN (v_gestionant, v_gestionact)
                       AND a.car_id_trp = p_placa
                       AND 29 =
                              pkg_verifica_transito.fplazoetiqueta (
                                  a.key_cuo,
                                  a.car_reg_year,
                                  a.car_reg_nber,
                                  p_usucuo,
                                  opcion)
                       AND 0 < verifica_operador(a.car_car_cod,a.car_id_trp) --Modificado Edgar 27112014 Nuevo OCE

            ORDER BY   a.car_reg_date, a.car_reg_time;
        END IF;
        IF (opcion = 8) THEN
        OPEN cr FOR
            SELECT  DISTINCT a.key_cuo,
             a.car_reg_year,
             a.car_reg_nber,
             a.car_reg_year || '-' || a.car_reg_nber transito,
             b.car_id_trp placa,
             TO_CHAR (b.car_reg_date, 'dd/mm/yyyy') reg_date,
                           b.car_reg_time,
                           b.car_car_cod,
                           b.car_car_nam,
                           b.car_tr_regref,
                           TO_CHAR (b.car_tr_regdat, 'dd/mm/yyyy') tr_regdat,
                           NVL (b.car_mast_nam, ' ') car_mast_nam,
                           NVL (b.car_mast_inf1, ' ') car_mast_inf1,
                           b.car_mast_inf2,
                           b.car_bl_nber,
                           b.car_pac_nber,
                           b.car_gros_mass,
                           nvl(a.tra_pre,' ') precinto,
                           nvl(a.tra_obs,' ') obs
        FROM   tra_pla_rut a, car_gen b
        WHERE       a.key_cuo = b.key_cuo
             AND a.car_reg_year = b.car_reg_year
             AND a.car_reg_nber = b.car_reg_nber
             AND a.tra_num = 0
             AND a.lst_ope = 'U'
             AND b.car_id_trp = p_placa
             AND NOT b.car_id_trp IN ('11111', '00000')
             AND NVL (a.tra_tipo, 22) <> 28
             AND a.tra_loc = 0;
        END IF;


        RETURN cr;
    EXCEPTION
    WHEN OTHERS
    THEN
        OPEN cr FOR
        SELECT * FROM dual WHERE 1=2;
        RETURN cr;
    END;
END pkg_consulta;
/* Formatted on 5-sep-2014 15:43:05 (QP5 v5.126) */
/

