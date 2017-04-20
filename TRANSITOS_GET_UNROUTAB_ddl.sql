CREATE OR REPLACE VIEW get_unroutab (
   rou_cod,
   rou_des,
   adu_uno,
   adu_dos,
   rou_ter,
   tip_tra,
   lst_ope,
   numver,
   usucre,
   feccre )
AS
(SELECT a.rou_cod, a.rou_des, a.cuo_sal || ' ' || u1.cuo_nam AS adu_uno,
           a.cuo_arr || ' ' || u2.cuo_nam AS adu_dos, a.rou_ter,
           a.rou_mod || ' ' || u3.mot_dsc AS tip_tra, a.lst_ope, a.numver,
           a.usucre, a.feccre
      FROM unroutab a,
           ops$asy.uncuotab u1,
           ops$asy.uncuotab u2,
           ops$asy.unmottab u3
     WHERE a.cuo_sal = u1.cuo_cod
       AND u1.lst_ope = 'U'
       AND a.cuo_arr = u2.cuo_cod
       AND u2.lst_ope = 'U'
       AND a.rou_mod = u3.mot_cod
       AND u3.lst_ope = 'U'
       AND a.lst_ope = 'U'
       AND a.numver = 0)
/
