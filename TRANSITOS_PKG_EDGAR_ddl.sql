CREATE OR REPLACE 
PACKAGE pkg_edgar
  IS

TYPE cursortype IS REF CURSOR;

    FUNCTION revierte_inicio (gestion     IN     VARCHAR2,
                               aduana    IN     VARCHAR2,
                               numero     IN     VARCHAR2)
        RETURN VARCHAR2;
FUNCTION habilita_placa (placa     IN     VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION verifica_manifiesto_local   ( prm_key_cuo     IN     VARCHAR2,
                                       prm_reg_year    IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2;

FUNCTION verifica_manifiesto_prod    ( prm_key_cuo     IN     VARCHAR2,
                                       prm_reg_year    IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2;

FUNCTION elimina_manifiesto_local   (  prm_key_cuo     IN     VARCHAR2,
                                       prm_reg_year    IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2;

FUNCTION replica_manifiesto_prod    (  prm_key_cuo     IN     VARCHAR2,
                                       prm_reg_year    IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2;


END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_edgar
IS

crlf       CONSTANT VARCHAR2 (2)        := CHR (13) || CHR (10);

FUNCTION revierte_inicio (gestion     IN     VARCHAR2,
                               aduana    IN     VARCHAR2,
                               numero     IN     VARCHAR2)
        RETURN VARCHAR2
IS
        res   VARCHAR2 (800);
    BEGIN

    DELETE tra_pla_rut
    WHERE key_cuo = aduana
    AND car_reg_year = gestion
    AND car_reg_nber = numero;

    DELETE tra_micanticipado
    WHERE key_cuo = aduana
    AND car_reg_year = gestion
    AND car_reg_nber = numero;

    RES:='CORRECTO';
        RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'ERROR';
    END;

FUNCTION habilita_placa (placa     IN     VARCHAR2)
        RETURN VARCHAR2
IS
        res   VARCHAR2 (800);
    BEGIN

   update ops$asy.unprptab set lst_ope = 'U'
             WHERE   cmp_cod = placa;
    RES:='CORRECTO';
        RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'ERROR';
    END;



FUNCTION verifica_manifiesto_local   ( prm_key_cuo     IN     VARCHAR2,
                                       prm_reg_year    IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2
 IS
        res   VARCHAR2 (500) := '';
        cant  DECIMAL (2,0);
        v_voy_nber VARCHAR2 (17);
        v_dep_date date;


    BEGIN

    SELECT count(1) into cant
      FROM ops$asy.car_gen
      where key_cuo = prm_key_cuo
      and car_reg_year = prm_reg_year
      and car_reg_nber = prm_reg_nber;

    if (cant = 0) then
        res := 'NO EXISTE EL MANIFIESTO';
    else
        SELECT key_voy_nber, key_dep_date into v_voy_nber, v_dep_date
        FROM ops$asy.car_gen
        where key_cuo = prm_key_cuo
        and car_reg_year = prm_reg_year
        and car_reg_nber = prm_reg_nber;


        SELECT count(1) into cant
        FROM ops$asy.car_bol_gen
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_BOL_GEN '||CANT||' REGISTROS'||crlf;
        END IF;


        SELECT count(1) into cant
        FROM ops$asy.car_bol_ope
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_BOL_OPE '||CANT||' REGISTROS'||crlf;
        END IF;


        SELECT count(1) into cant
        FROM ops$asy.car_bol_ctn
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_BOL_CTN '||CANT||' REGISTROS'||crlf;
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.car_bol_sta
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_BOL_STA '||CANT||' REGISTROS'||crlf;
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.car_spy
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_SPY '||CANT||' REGISTROS'||crlf;
        END IF;




    end if;

      RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 500);
    END;


FUNCTION verifica_manifiesto_prod    ( prm_key_cuo     IN     VARCHAR2,
                                       prm_reg_year    IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2
 IS
        res   VARCHAR2 (500) := '';
        cant  DECIMAL (2,0);
        v_voy_nber VARCHAR2 (17);
        v_dep_date date;


    BEGIN

    SELECT count(1) into cant
      FROM ops$asy.car_gen@asy.prod2
      where key_cuo = prm_key_cuo
      and car_reg_year = prm_reg_year
      and car_reg_nber = prm_reg_nber;

    if (cant = 0) then
        res := 'NO EXISTE EL MANIFIESTO';
    else
        SELECT key_voy_nber, key_dep_date into v_voy_nber, v_dep_date
        FROM ops$asy.car_gen@asy.prod2
        where key_cuo = prm_key_cuo
        and car_reg_year = prm_reg_year
        and car_reg_nber = prm_reg_nber;


        SELECT count(1) into cant
        FROM ops$asy.car_bol_gen@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_BOL_GEN '||CANT||' REGISTROS'||crlf;
        END IF;


        SELECT count(1) into cant
        FROM ops$asy.car_bol_ope@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_BOL_OPE '||CANT||' REGISTROS'||crlf;
        END IF;


        SELECT count(1) into cant
        FROM ops$asy.car_bol_ctn@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_BOL_CTN '||CANT||' REGISTROS'||crlf;
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.car_bol_sta@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_BOL_STA '||CANT||' REGISTROS'||crlf;
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.car_spy@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        IF(CANT > 0) THEN
            RES := RES||'CAR_SPY '||CANT||' REGISTROS'||crlf;
        END IF;




    end if;


      RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 500);
    END;

FUNCTION elimina_manifiesto_local    ( prm_key_cuo     IN     VARCHAR2,
                                       prm_reg_year    IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2
IS
        res   VARCHAR2 (500) := '';
        cant  DECIMAL (2,0);
        v_voy_nber VARCHAR2 (17);
        v_dep_date date;


    BEGIN

    SELECT count(1) into cant
      FROM ops$asy.car_gen
      where key_cuo = prm_key_cuo
      and car_reg_year = prm_reg_year
      and car_reg_nber = prm_reg_nber;

    if (cant = 0) then
        res := 'NO EXISTE EL MANIFIESTO';
    else
        SELECT key_voy_nber, key_dep_date into v_voy_nber, v_dep_date
        FROM ops$asy.car_gen
        where key_cuo = prm_key_cuo
        and car_reg_year = prm_reg_year
        and car_reg_nber = prm_reg_nber;


        DELETE ops$asy.car_gen
        where key_cuo = prm_key_cuo
        and car_reg_year = prm_reg_year
        and car_reg_nber = prm_reg_nber;

        DELETE ops$asy.car_bol_gen
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        DELETE ops$asy.car_bol_ope
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        DELETE ops$asy.car_bol_ctn a
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        DELETE ops$asy.car_bol_sta a
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        DELETE ops$asy.car_spy a
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;



    end if;

      RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 500);
    END;

FUNCTION replica_manifiesto_prod     ( prm_key_cuo     IN     VARCHAR2,
                                       prm_reg_year    IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2
  IS
        res   VARCHAR2 (500) := '';
        cant  DECIMAL (2,0);
        v_voy_nber VARCHAR2 (17);
        v_dep_date date;


    BEGIN

    SELECT count(1) into cant
      FROM ops$asy.car_gen@asy.prod2
      where key_cuo = prm_key_cuo
      and car_reg_year = prm_reg_year
      and car_reg_nber = prm_reg_nber;

    if (cant = 0) then
        res := 'NO EXISTE EL MANIFIESTO';
    else
        SELECT key_voy_nber, key_dep_date into v_voy_nber, v_dep_date
        FROM ops$asy.car_gen@asy.prod2
        where key_cuo = prm_key_cuo
        and car_reg_year = prm_reg_year
        and car_reg_nber = prm_reg_nber;

        INSERT INTO ops$asy.car_gen
        SELECT *
    FROM ops$asy.car_gen@asy.prod2
        where key_cuo = prm_key_cuo
        and car_reg_year = prm_reg_year
        and car_reg_nber = prm_reg_nber;

    INSERT INTO ops$asy.car_bol_gen
        SELECT *
        FROM ops$asy.car_bol_gen@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        INSERT INTO ops$asy.car_bol_ope
        SELECT *
        FROM ops$asy.car_bol_ope@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        INSERT INTO ops$asy.car_bol_ctn
        SELECT *
        FROM ops$asy.car_bol_ctn@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        INSERT INTO ops$asy.car_bol_sta
        SELECT *
        FROM ops$asy.car_bol_sta@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;

        INSERT INTO ops$asy.car_spy
        SELECT *
        FROM ops$asy.car_spy@asy.prod2
        WHERE key_cuo = prm_key_cuo
        AND key_voy_nber = v_voy_nber
        AND key_dep_date = v_dep_date;


    end if;


      RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 500);
    END;


FUNCTION verifica_declaracion_local   (prm_key_year     IN     VARCHAR2,
                                       prm_key_cuo      IN     VARCHAR2,
                       prm_reg_serial   IN     VARCHAR2,
                                       prm_reg_nber     IN     DECIMAL)
        RETURN VARCHAR2
 IS
        res   VARCHAR2 (500) := '';
        cant  DECIMAL (2,0);
        v_key_dec VARCHAR2 (17);
        v_key_nber VARCHAR2 (13);


    BEGIN

      SELECT count(1) into cant
      FROM ops$asy.sad_gen
      where key_year = prm_key_year
      and key_cuo = prm_key_cuo
      and sad_reg_serial = prm_reg_serial
      and sad_reg_nber = prm_reg_nber;

    if (cant = 0) then
        res := 'NO EXISTE EL declaracion';
    else
        SELECT key_dec, key_nber into v_key_dec, v_key_nber
        FROM ops$asy.sad_gen
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and sad_reg_serial = prm_reg_serial
        and sad_reg_nber = prm_reg_nber;


        SELECT count(1) into cant
        FROM ops$asy.sad_itm
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'SAD_ITM '||CANT||' REGISTROS/n';
        END IF;


        SELECT count(1) into cant
        FROM ops$asy.bo_sad_payment
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'bo_sad_payment '||CANT||' REGISTROS/n';
        END IF;


        SELECT count(1) into cant
        FROM ops$asy.sad_dec_ser
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_dec_ser '||CANT||' REGISTROS/n';
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.sad_exp_rls
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_exp_rls '||CANT||' REGISTROS/n';
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.sad_gen_blk
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_gen_blk '||CANT||' REGISTROS/n';
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.sad_gen_ped
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_gen_ped '||CANT||' REGISTROS/n';
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.sad_gen_sus
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_gen_sus '||CANT||' REGISTROS/n';
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.sad_gen_vex
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_gen_vex '||CANT||' REGISTROS/n';
        END IF;

        SELECT count(1) into cant
        FROM ops$asy.sad_gen_vim
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_gen_vim '||CANT||' REGISTROS/n';
        END IF;

    SELECT count(1) into cant
        FROM ops$asy.sad_inf
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_inf '||CANT||' REGISTROS/n';
        END IF;

    SELECT count(1) into cant
        FROM ops$asy.sad_itm_blk
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_itm_blk '||CANT||' REGISTROS/n';
        END IF;

    SELECT count(1) into cant
        FROM ops$asy.sad_itm_ped
        where key_year = prm_key_year
        and key_cuo = prm_key_cuo
        and key_dec = v_key_dec
        and key_nber = v_key_nber;

        IF(CANT > 0) THEN
            RES := 'sad_itm_ped '||CANT||' REGISTROS/n';
        END IF;

 end if;

      RETURN res;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RETURN SUBSTR (TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1, 500);
    END;



END;
/

