CREATE OR REPLACE 
PACKAGE pkg_verifica_transito
IS
    FUNCTION finicio (keycuo           IN     VARCHAR2,
                      gestion          IN     VARCHAR2,
                      serial           IN     VARCHAR2,
                      aduana_usuario   IN     VARCHAR2,
                      boleta              OUT NUMBER)
        RETURN NUMBER;

    FUNCTION faduana_paso (keycuo           IN VARCHAR2,
                           gestion          IN VARCHAR2,
                           serial           IN VARCHAR2,
                           aduana_usuario   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION freasignacion (keycuo           IN     VARCHAR2,
                            gestion          IN     VARCHAR2,
                            serial           IN     VARCHAR2,
                            aduana_usuario   IN     VARCHAR2,
                            boleta              OUT NUMBER)
        RETURN NUMBER;

    FUNCTION ffinalizacion (keycuo    IN VARCHAR2,
                            gestion   IN VARCHAR2,
                            serial    IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION ffinalizacion_dep (keycuo    IN VARCHAR2,
                            gestion   IN VARCHAR2,
                            serial    IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION fcancelacion (keycuo           IN VARCHAR2,
                           gestion          IN VARCHAR2,
                           serial           IN VARCHAR2,
                           aduana_usuario   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION faduana_ptoctl (keycuo           IN VARCHAR2,
                             gestion          IN VARCHAR2,
                             serial           IN VARCHAR2,
                             aduana_usuario   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION fetiqueta (keycuo           IN VARCHAR2,
                        gestion          IN VARCHAR2,
                        serial           IN VARCHAR2,
                        aduana_usuario   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION fplazoetiqueta (keycuo           IN VARCHAR2,
                             gestion          IN VARCHAR2,
                             serial           IN VARCHAR2,
                             aduana_usuario   IN VARCHAR2,
                             etapa            IN DECIMAL)
        RETURN NUMBER;

    FUNCTION verifica_etiqueta (skey_cuo     IN     VARCHAR2,
                                scar_year    IN     VARCHAR2,
                                nreg_nber    IN     NUMBER,
                                sreg_date    IN     VARCHAR2,
                                sreg_time    IN     VARCHAR2,
                                scar_cod     IN     VARCHAR2,
                                scra_nam     IN     VARCHAR2,
                                str_regref   IN     VARCHAR2,
                                str_regdat   IN     VARCHAR2,
                                smast_name   IN     VARCHAR2,
                                smast_inf1   IN     VARCHAR2,
                                smast_inf2   IN     VARCHAR2,
                                nbl_nber     IN     NUMBER,
                                npac_nber    IN     NUMBER,
                                ngros_mass   IN     NUMBER,
                                nlin_nbr     IN     NUMBER,
                                sbol_reg     IN     VARCHAR2,
                                ngros_mas    IN     NUMBER,
                                npack_nber   IN     NUMBER,
                                sdes1        IN     VARCHAR2,
                                splaca       IN     VARCHAR2,
                                schasis      IN     VARCHAR2,
                                sctn_ident   IN     VARCHAR2,
                                stra_pre     IN     VARCHAR2,
                                nsec         IN     NUMBER,
                                saduini      IN     VARCHAR2,
                                sfecini      IN     VARCHAR2,
                                sadufin      IN     VARCHAR2,
                                sfecfin      IN     VARCHAR2,
                                opcion       IN     NUMBER,
                                dsc_aduana      OUT VARCHAR2)
        RETURN VARCHAR2;



FUNCTION verifica_unetitab (keycuo IN VARCHAR2)
/* Formatted on 27/11/2014 21:12:27 (QP5 v5.126) */
    RETURN NUMBER;

    FUNCTION valida_autorizacion2752 (keycuo    IN VARCHAR2,
                                      gestion   IN VARCHAR2,
                                      serial    IN VARCHAR2)
        RETURN NUMBER;
    FUNCTION valida_autorizacion2865 (keycuo    IN VARCHAR2,
                                      gestion   IN VARCHAR2,
                                      serial    IN VARCHAR2)
        RETURN NUMBER;
END;
/

CREATE OR REPLACE 
PACKAGE BODY pkg_verifica_transito
/* Formatted on 27/11/2014 21:19:25 (QP5 v5.126) */
IS
    -- Etapas del transito
    mt_nuevo                   CONSTANT DECIMAL (2, 0) := 1;
    mt_pendiente               CONSTANT DECIMAL (2, 0) := 2;
    mt_concluido               CONSTANT DECIMAL (2, 0) := 3;
    mt_no_existe               CONSTANT DECIMAL (2, 0) := 4;
    mt_placa_pendiente         CONSTANT DECIMAL (2, 0) := 5;
    mt_registrado              CONSTANT DECIMAL (2, 0) := 6;
    mt_eliminado               CONSTANT DECIMAL (2, 0) := 7;
    mt_acta                    CONSTANT DECIMAL (2, 0) := 8;
    mt_tna                     CONSTANT DECIMAL (2, 0) := 9;
    mt_no_usuario              CONSTANT DECIMAL (2, 0) := 10;
    mt_no_eliminado            CONSTANT DECIMAL (2, 0) := 11;
    mt_no_localizado           CONSTANT DECIMAL (2, 0) := 12;
    mt_no_aduana_paso1         CONSTANT DECIMAL (2, 0) := 13;
    mt_no_aduana_paso2         CONSTANT DECIMAL (2, 0) := 14;
    mt_no_aduana_paso3         CONSTANT DECIMAL (2, 0) := 15;
    mt_no_aduana_paso4         CONSTANT DECIMAL (2, 0) := 16;
    mt_no_aduana_paso5         CONSTANT DECIMAL (2, 0) := 17;
    mt_no_unico_salidapuerto   CONSTANT DECIMAL (2, 0) := 18;
    mt_no_man_operador         CONSTANT DECIMAL (2, 0) := 19;

   mt_no_ds2295                 CONSTANT DECIMAL (2, 0) := 70;
   mt_no_aut_ds2295             CONSTANT DECIMAL (2, 0) := 71;
   mt_no_inicio_ds2295          CONSTANT DECIMAL (2, 0) := 72;
    mt_no_ds2752                 CONSTANT DECIMAL (2, 0) := 80;
    mt_no_ds2752zf               CONSTANT DECIMAL (2, 0) := 81;
    mt_no_ds2865                 CONSTANT DECIMAL (2, 0) := 82;
    mt_no_ds2865zf               CONSTANT DECIMAL (2, 0) := 83;
    -- edgar arteaga 12012015, para impresion de etiquetas
    mt_no_habilitadounetitab   CONSTANT DECIMAL (2, 0) := 51;
    mt_no_habilitadoimportador CONSTANT DECIMAL (2, 0) := 52;

    mt_no_salidapuerto         CONSTANT DECIMAL (2, 0) := 20;

    mt_no_aduana_pctl1         CONSTANT DECIMAL (2, 0) := 43;
    mt_no_aduana_pctl2         CONSTANT DECIMAL (2, 0) := 44;
    mt_no_aduana_pctl3         CONSTANT DECIMAL (2, 0) := 45;
    mt_no_aduana_pctl4         CONSTANT DECIMAL (2, 0) := 46;
    mt_no_aduana_pctl5         CONSTANT DECIMAL (2, 0) := 47;
    mt_no_aduana_pctl6         CONSTANT DECIMAL (2, 0) := 48;
    mt_boleta_garantia         CONSTANT DECIMAL (2, 0) := 18;
    mt_correcto                CONSTANT DECIMAL (2, 0) := 29;
    mt_despacho_anticipado     CONSTANT NUMBER := 30;
    mt_error                   CONSTANT DECIMAL (2, 0) := 99;
    mt_no_imagenes               CONSTANT DECIMAL (2, 0) := 88;
    -- Seleccion del tramite
    binicio                    CONSTANT DECIMAL (2, 0) := 1;
    bfinalizacion              CONSTANT DECIMAL (2, 0) := 2;
    bmodificacion              CONSTANT DECIMAL (2, 0) := 3;
    bcancelacion               CONSTANT DECIMAL (2, 0) := 4;
    bmod_manifiesto            CONSTANT DECIMAL (2, 0) := 5;
    bhabilitamedio             CONSTANT DECIMAL (2, 0) := 7;
    bpaso                      CONSTANT DECIMAL (2, 0) := 8;
    bptoctl                    CONSTANT DECIMAL (2, 0) := 9;
    breporte                   CONSTANT DECIMAL (2, 0) := 21;
    betiqueta                  CONSTANT DECIMAL (2, 0) := 12;
    --PlazoEtiqueta
    bsalidapuerto              CONSTANT DECIMAL (2, 0) := 16;
    blistasalidapuerto         CONSTANT DECIMAL (2, 0) := 17;
    -- Seleccion del cierre
    bnormal                    CONSTANT DECIMAL (2, 0) := 24;
    btransbordo                CONSTANT DECIMAL (2, 0) := 28;
    bforzoso                   CONSTANT DECIMAL (2, 0) := 23;
    -- Estado de boletas
    bexiste                    CONSTANT VARCHAR2 (1) := 1;
    bnoexiste                  CONSTANT VARCHAR2 (1) := 0;

    --Modificado Edgar 27112014 Nuevo OCE
    v_fecha_corte CONSTANT DATE
            := TO_DATE ('15/12/2015', 'dd/mm/yyyy') ;

    -- verificamos si el usuario esta regsitrado en la aduana de partida
    FUNCTION verifica_usuario (keycuo    IN VARCHAR2,
                               gestion   IN VARCHAR2,
                               serial    IN DECIMAL,
                               aduana    IN VARCHAR2,
                               etapa     IN DECIMAL)
        RETURN DECIMAL
    IS
        hay               DECIMAL (3, 0);
        partidad_aduana   VARCHAR2 (20);
        kaduana           VARCHAR2 (5);
        laduana           VARCHAR2 (20) := aduana;
    BEGIN
        IF (laduana = 'ALL')
        THEN
            RETURN bexiste;
        END IF;

        IF (etapa = binicio)
        THEN
            partidad_aduana := keycuo;
        ELSIF (etapa = bpaso)
        THEN
            /*IF (keycuo = '071')
            THEN
                partidad_aduana := '241';
            ELSE
                partidad_aduana := '422';
            END IF; */

            IF (keycuo = '071')
            THEN
                partidad_aduana := '241';
            ELSE
                IF (keycuo = '072')
                THEN
                    partidad_aduana := '422,221';
                END IF;
            END IF;
        ELSIF (   etapa = betiqueta
               OR etapa = bsalidapuerto
               OR etapa = blistasalidapuerto)
        THEN
            partidad_aduana := keycuo;
        /*IF (keycuo = '072')
        THEN
            partidad_aduana := '422';
        END IF;*/
        ELSE
            SELECT   tra_cuo_ini
              INTO   partidad_aduana
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope IN ('U', 'M')
                     AND tra_estado = 0;
        END IF;

        hay := INSTR (laduana, '-');

        WHILE hay > 0
        LOOP
            kaduana := SUBSTR (laduana, 0, hay - 1);

            --IF (partidad_aduana = kaduana)
            IF (instr(partidad_aduana, kaduana)>0)
            THEN
                RETURN bexiste;
            END IF;

            laduana := SUBSTR (laduana, hay + 1);
            hay := INSTR (laduana, '-');
        END LOOP;

--        IF (partidad_aduana = laduana)
        IF (instr(partidad_aduana, laduana)>0)
        THEN
            RETURN bexiste;
        END IF;

        RETURN bnoexiste;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN bnoexiste;
    END;

    -- Verifica el estado de la Empresa y Medio
    FUNCTION estado_empresa_placa (keycuo    IN VARCHAR2,
                                   gestion   IN VARCHAR2,
                                   serial    IN DECIMAL,
                                   etapa     IN NUMBER)
        RETURN DECIMAL
    IS
        empresa    VARCHAR2 (20);
        placa      VARCHAR2 (15);
        cantidad   NUMBER (3, 0);
    BEGIN
        SELECT   DISTINCT car_car_cod, car_id_trp
          INTO   empresa, placa
          FROM   ops$asy.car_bol_gen cb, ops$asy.car_gen cg
         WHERE       cb.key_cuo = cg.key_cuo
                 AND cb.key_voy_nber = cg.key_voy_nber
                 AND cb.key_dep_date = cg.key_dep_date
                 AND cg.key_cuo = keycuo
                 AND cg.car_reg_year = gestion
                 AND cg.car_reg_nber = serial
                 AND cb.carbol_nat_cod = '24'
                 AND NOT cb.carbol_frt_prep IS NULL;

        IF (etapa = binicio)
        THEN
            -- verificamos si esta vigente o no la placa en unprptab
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   ops$asy.unprptab
             WHERE   cmp_cod = placa AND lst_ope = 'U';

            IF (cantidad = 0)
            THEN
                RETURN mt_placa_pendiente;
            END IF;

            -- verificamos si el medio tiene transito pendiente
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut a, ops$asy.car_gen b
             WHERE       a.key_cuo = b.key_cuo
                     AND a.car_reg_year = b.car_reg_year
                     AND a.car_reg_nber = b.car_reg_nber
                     AND a.tra_num = 0
                     AND a.lst_ope = 'U'
                     AND b.car_id_trp = placa
                     AND NOT b.car_id_trp IN ('11111', '00000')
                     AND NVL (a.tra_tipo, 22) <> 28
                     AND a.tra_loc = 0;

            IF (cantidad > 0)
            THEN
                RETURN mt_placa_pendiente;
            END IF;

            -- verificamos si la empresa tiene acta de intervencion, si tiene, pedimos la boleta
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_acta
             WHERE       car_car_cod = empresa
                     AND tac_num = 0
                     AND tac_estado IN (0, 1)
                     AND lst_ope = 'U';

            IF (cantidad > 0)
            THEN
                RETURN mt_boleta_garantia;
            END IF;
        END IF;

        -- verificamos si el medio tiene acta de intervencion
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_acta
         WHERE       car_id_trp = placa
                 AND tac_num = 0
                 AND tac_estado IN (0, 2)
                 AND lst_ope = 'U';

        IF (cantidad > 0)
        THEN
            RETURN mt_tna;
        END IF;

        RETURN mt_correcto;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;

    /****************************************************
    * Verificamos los datos para el Inicio del transito *
    ****************************************************/
    FUNCTION finicio (keycuo           IN     VARCHAR2,
                      gestion          IN     VARCHAR2,
                      serial           IN     VARCHAR2,
                      aduana_usuario   IN     VARCHAR2,
                      boleta              OUT NUMBER)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0);
        ans        VARCHAR2 (300);
      v_key_cuo        car_bol_ope.key_cuo%TYPE;
      v_key_voy_nber   car_bol_ope.key_voy_nber%TYPE;
      v_key_dep_date   VARCHAR2 (20);
    BEGIN
        boleta := bnoexiste;

      --ADUANAS HABILITADAS PARA EL CONTROL DEL DS2295
/*      IF (keycuo IN
                ('721',
                 '241',
                 '422',
                 '641',
                 '621',
                 '521',
                 '421',
                 '071',
                 '072'))
*/
    if (substr(keycuo,2,1) = '4' or substr(keycuo,2,1) = '2' or keycuo in ('071','072'))


      THEN
         --Verificacion del D.S. 2295
         SELECT b.key_cuo,
                b.key_voy_nber,
                TO_CHAR (b.key_dep_date, 'dd/mm/yyyy')
           INTO v_key_cuo, v_key_voy_nber, v_key_dep_date
           FROM ops$asy.car_gen b
          WHERE     b.key_cuo = keycuo
                AND b.car_reg_year = gestion
                AND b.car_reg_nber = serial;

         cantidad   :=
            ops$asy.f_verif_ds2295 (v_key_cuo, v_key_voy_nber, v_key_dep_date,'TRANSITO'
            );

      --*********
      ELSE
         cantidad   := 1;
      END IF;


      IF (cantidad = 0)
      THEN
         RETURN mt_no_ds2295;
      END IF;

      IF (cantidad = 2)
      THEN
         RETURN mt_no_inicio_ds2295;
      END IF;
        -- verificamos si esta asociado al DS2752
        cantidad :=
            pkg_verifica_transito.valida_autorizacion2752 (keycuo,
                                                           gestion,
                                                           serial);

        IF (cantidad = 1)
        THEN
            RETURN mt_no_ds2752;
        END IF;

        IF (cantidad = 2)
        THEN
            RETURN mt_no_ds2752zf;
        END IF;

        -- verificamos si esta asociado al DS2865
        cantidad :=
            pkg_verifica_transito.valida_autorizacion2865 (keycuo,
                                                           gestion,
                                                           serial);

        IF (cantidad = 1)
        THEN
            RETURN mt_no_ds2865;
        END IF;

        IF (cantidad = 2)
        THEN
            RETURN mt_no_ds2865zf;
        END IF;

        -- *********

        -- verificamos si esta registrado el transito
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND tra_num = 0;

        IF (cantidad > 0)
        THEN
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U';

            IF (cantidad > 0)
            THEN
                RETURN mt_pendiente;
            ELSE
                RETURN mt_eliminado;
            END IF;
        END IF;

        -- verificamos que el usuario este habilitado en la aduana de partida del manifiesto
        cantidad :=
            verifica_usuario (keycuo,
                              gestion,
                              serial,
                              aduana_usuario,
                              binicio);

        IF (cantidad = bnoexiste)
        THEN
            RETURN mt_no_usuario;
        END IF;

        -- verificamos el estado de la empresa y el medio del manifiesto
        cantidad :=
            estado_empresa_placa (keycuo,
                                  gestion,
                                  serial,
                                  binicio);


        -- verificamos despacho anticipado
        /*ans := PKG_DESPACHO.VALIDA_TRANSITOS (gestion, keycuo, serial);

        IF (ans = 'Despacho Anticipado.')
        THEN
           RETURN mt_despacho_anticipado;
        ELSIF (ans != 'correcto')
        THEN
           RETURN mt_error;
        END IF;*/

        IF (cantidad = mt_boleta_garantia)
        THEN
            boleta := bexiste;
            cantidad := mt_correcto;
        END IF;

        RETURN cantidad;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END finicio;

    FUNCTION valida_autorizacion2752 (keycuo    IN VARCHAR2,
                                      gestion   IN VARCHAR2,
                                      serial    IN VARCHAR2)
        RETURN NUMBER
    IS
        res     VARCHAR2 (100);
        existe  NUMBER;
        fec_emb date;
    BEGIN

        --verificamos si algun documento de embarque corresponde al DS2752;
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
            RETURN 0;
        ELSE
            --verificamos si algun destino de los DE con DS2752, tiene destino a zona franca.
            SELECT  count(1)
               into existe
              FROM   tra_aut_previa a, ops$asy.car_gen c, OPS$ASY.CAR_BOL_GEN g
             WHERE       a.key_cuo = c.key_cuo
                     AND a.key_voy_nber = c.key_voy_nber
                     AND a.key_dep_date = c.key_dep_date
                     and a.key_cuo = g.key_cuo
                     AND a.key_voy_nber = g.key_voy_nber
                     AND a.key_dep_date = g.key_dep_date
                     and a.KEY_BOL_REF = g.KEY_BOL_REF
                     AND a.apr_num = 0
                     AND a.apr_lstope = 'U'
                     AND (a.apr_ds_autorizacion = 'DS2752'
                          OR a.apr_ds_autorizacion = 'DS2752CAN')
                     AND c.key_cuo = keycuo
                     AND c.car_reg_year = gestion
                     AND c.car_reg_nber = serial
                     and substr(g.CARBOL_FRT_PREP,2,1) = 3
                     AND g.CARBOL_FRT_PREP not in ('737','738','736','234','432','232','332','931'); --2.  El Sistema no debera permitir el inicio de tr?nsito hacia una administraci?n de zona franca comercial, a excepci?n de zona franca Cobija.

            IF existe = 0
            THEN
                --NO tiene destino zona franca

                --verificamos si todos los DE con autorizacion previa 2752 tiene su numero de autorizacion
                SELECT  count(1)
                    into existe
                  FROM   tra_aut_previa a, ops$asy.car_gen c, OPS$ASY.CAR_BOL_GEN g, tra_inf_docembarque d
                 WHERE       a.key_cuo = c.key_cuo
                         AND a.key_voy_nber = c.key_voy_nber
                         AND a.key_dep_date = c.key_dep_date
                         and a.key_cuo = g.key_cuo
                         AND a.key_voy_nber = g.key_voy_nber
                         AND a.key_dep_date = g.key_dep_date
                         and a.KEY_BOL_REF = g.KEY_BOL_REF
                         and a.key_cuo = d.key_cuo
                         AND a.key_voy_nber = d.key_voy_nber
                         AND a.key_dep_date = d.key_dep_date
                         and a.KEY_BOL_REF = d.KEY_BOL_REF
                         and d.DOCEMB_NUM = 0
                         and d.LST_OPE = 'U'
                         AND a.apr_num = 0
                         AND a.apr_lstope = 'U'
                         AND a.apr_ds_autorizacion = 'DS2752'
                         and d.docemb_fecha_embarque >  TO_DATE('25/07/2016','DD/MM/YYYY')
                         and a.apr_nro_autorizacion is null
                         AND c.key_cuo = keycuo
                         AND c.car_reg_year = gestion
                         AND c.car_reg_nber = serial;

                IF existe = 0
                THEN
                    RETURN 0;
                ELSE
                    RETURN 1;
                END IF;
            ELSE
                --TIENE DESTINO ZONA FRANCA
                IF trunc(SYSDATE) > TO_DATE('25/07/2016','DD/MM/YYYY')
                THEN
                    RETURN 2;
                ELSE
                    RETURN 0;
                END IF;
            END IF;
        END IF;
    END valida_autorizacion2752;

    FUNCTION valida_autorizacion2865 (keycuo    IN VARCHAR2,
                                      gestion   IN VARCHAR2,
                                      serial    IN VARCHAR2)
        RETURN NUMBER
    IS
        res     VARCHAR2 (100);
        existe  NUMBER;
        fec_emb date;
    BEGIN

        --verificamos si algun documento de embarque corresponde al DS2865;
        SELECT   COUNT (1)
          INTO   existe
          FROM   tra_aut_previa a, ops$asy.car_gen c
         WHERE       a.key_cuo = c.key_cuo
                 AND a.key_voy_nber = c.key_voy_nber
                 AND a.key_dep_date = c.key_dep_date
                 AND a.apr_num = 0
                 AND a.apr_lstope = 'U'
                 AND a.apr_ds_autorizacion = 'DS2865'
                 AND c.key_cuo = keycuo
                 AND c.car_reg_year = gestion
                 AND c.car_reg_nber = serial;

        IF existe = 0
        THEN
            RETURN 0;
        ELSE
            --verificamos si algun destino de los DE con DS2865, tiene destino a zona franca.
            SELECT  count(1)
               into existe
              FROM   tra_aut_previa a, ops$asy.car_gen c, OPS$ASY.CAR_BOL_GEN g
             WHERE       a.key_cuo = c.key_cuo
                     AND a.key_voy_nber = c.key_voy_nber
                     AND a.key_dep_date = c.key_dep_date
                     and a.key_cuo = g.key_cuo
                     AND a.key_voy_nber = g.key_voy_nber
                     AND a.key_dep_date = g.key_dep_date
                     and a.KEY_BOL_REF = g.KEY_BOL_REF
                     AND a.apr_num = 0
                     AND a.apr_lstope = 'U'
                     AND a.apr_ds_autorizacion = 'DS2865'
                     AND c.key_cuo = keycuo
                     AND c.car_reg_year = gestion
                     AND c.car_reg_nber = serial
                     and substr(g.CARBOL_FRT_PREP,2,1) = 3
                     AND g.CARBOL_FRT_PREP not in ('737','738','736','234','432','232','332','931'); --2.  El Sistema no debera permitir el inicio de tr?nsito hacia una administraci?n de zona franca comercial, a excepci?n de zona franca Cobija.

            IF existe = 0
            THEN
                --NO tiene destino zona franca

                --verificamos si todos los DE con autorizacion previa 2752 tiene su numero de autorizacion
                SELECT  count(1)
                    into existe
                  FROM   tra_aut_previa a, ops$asy.car_gen c, OPS$ASY.CAR_BOL_GEN g, tra_inf_docembarque d
                 WHERE       a.key_cuo = c.key_cuo
                         AND a.key_voy_nber = c.key_voy_nber
                         AND a.key_dep_date = c.key_dep_date
                         and a.key_cuo = g.key_cuo
                         AND a.key_voy_nber = g.key_voy_nber
                         AND a.key_dep_date = g.key_dep_date
                         and a.KEY_BOL_REF = g.KEY_BOL_REF
                         and a.key_cuo = d.key_cuo
                         AND a.key_voy_nber = d.key_voy_nber
                         AND a.key_dep_date = d.key_dep_date
                         and a.KEY_BOL_REF = d.KEY_BOL_REF
                         and d.DOCEMB_NUM = 0
                         and d.LST_OPE = 'U'
                         AND a.apr_num = 0
                         AND a.apr_lstope = 'U'
                         AND a.apr_ds_autorizacion = 'DS2865'
                         and d.docemb_fecha_embarque >=  TO_DATE('04/10/2016','DD/MM/YYYY')
                         and a.apr_nro_autorizacion is null
                         AND c.key_cuo = keycuo
                         AND c.car_reg_year = gestion
                         AND c.car_reg_nber = serial;

                IF existe = 0
                THEN
                    RETURN 0;
                ELSE
                    RETURN 1;
                END IF;
            ELSE
                --TIENE DESTINO ZONA FRANCA
                IF trunc(SYSDATE) >= TO_DATE('04/10/2016','DD/MM/YYYY')
                THEN
                    RETURN 2;
                ELSE
                    RETURN 0;
                END IF;
            END IF;
        END IF;
    END valida_autorizacion2865;

    /************************************************************
    * Verificamos los datos del transito para la Aduana de Paso *
    ************************************************************/
    FUNCTION faduana_paso (keycuo           IN VARCHAR2,
                           gestion          IN VARCHAR2,
                           serial           IN VARCHAR2,
                           aduana_usuario   IN VARCHAR2)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0);
      v_key_cuo        car_bol_ope.key_cuo%TYPE;
      v_key_voy_nber   car_bol_ope.key_voy_nber%TYPE;
      v_key_dep_date   VARCHAR2 (20);
    BEGIN
        -- Verificamos si el Transito es de la Aduana 071 o 072.
        IF (NOT keycuo IN ('071', '072'))
        THEN
            RETURN mt_no_aduana_paso1;
        END IF;

      --Verificacion de Autorizacion D.S. 2295
      SELECT b.key_cuo,
             b.key_voy_nber,
             TO_CHAR (b.key_dep_date, 'dd/mm/yyyy')
        INTO v_key_cuo, v_key_voy_nber, v_key_dep_date
        FROM ops$asy.car_gen b
       WHERE     b.key_cuo = keycuo
             AND b.car_reg_year = gestion
             AND b.car_reg_nber = serial;

      SELECT COUNT (1)
        INTO cantidad
        FROM tra_inf_manifiesto a
       WHERE     a.key_cuo = v_key_cuo
             AND a.key_voy_nber = v_key_voy_nber
             AND a.key_dep_date = TO_DATE (v_key_dep_date, 'dd/mm/yyyy')
             AND a.man_est_autorizado = 'DS2295'
             AND a.man_num = 0
             AND a.lst_ope = 'U';

      IF (cantidad = 1)
      THEN
         RETURN mt_no_aut_ds2295;
      END IF;
        -- verifica que el tramite tenga salida de puerto
        -- Edgar Arteaga 18082014
        -- -LA FUNCION  tiene_salida_puerto devuelve 1 si tiene 0 si no tiene salida de puerto
        cantidad :=
            tiene_salida_puerto (keycuo,
                                 gestion,
                                 serial,
                                 '2');

        -- -validamos si no tiene salida de puerto y su aduana es (071,072) si es asi, no puede hacer cierre
        -- -hasta que haga su salida de puerto, para otra aduana que no se a071 072, pasara directamente
        IF (cantidad = 0 AND SUBSTR (keycuo, 1, 1) = 0)
        THEN
            RETURN mt_no_salidapuerto;
        END IF;

        ----------------------

        -- Verificamos que no esta registrado la aduana de paso anteriormente
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND key_secuencia = 0
                 AND lst_ope = 'U';

        IF ( (keycuo = '072' AND cantidad >= 2)
            OR (keycuo = '071' AND cantidad >= 1))
        THEN
            RETURN mt_no_aduana_paso3;
        END IF;

        -- Verificamos si el primer tramo es el vigente
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND key_secuencia = 1
                 AND tra_num = 0
                 AND lst_ope = 'U'
                 AND tra_estado = 0;

        IF (cantidad = bnoexiste)
        THEN
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'D';

            IF (cantidad = 0)
            THEN
                RETURN mt_no_aduana_paso2;
            ELSE
                RETURN mt_eliminado;
            END IF;
        END IF;

        -- verificamos que el usuario este habilitado en la aduana de partida del manifiesto
        cantidad :=
            verifica_usuario (keycuo,
                              gestion,
                              serial,
                              aduana_usuario,
                              bpaso);

        IF (cantidad = bnoexiste)
        THEN
            RETURN mt_no_usuario;
        END IF;

        -- verificamos el estado de la empresa y el medio del manifiesto
        cantidad :=
            estado_empresa_placa (keycuo,
                                  gestion,
                                  serial,
                                  bpaso);
        RETURN cantidad;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;

    /**********************************************************
    * Verificamos los datos para la Reasignacion del transito *
    **********************************************************/
    FUNCTION freasignacion (keycuo           IN     VARCHAR2,
                            gestion          IN     VARCHAR2,
                            serial           IN     VARCHAR2,
                            aduana_usuario   IN     VARCHAR2,
                            boleta              OUT NUMBER)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0);
    BEGIN
        boleta := bnoexiste;

        -- verifica que el tramite tenga salida de puerto
        -- Edgar Arteaga 18082014
        -- -LA FUNCION  tiene_salida_puerto devuelve 1 si tiene 0 si no tiene salida de puerto
        cantidad :=
            tiene_salida_puerto (keycuo,
                                 gestion,
                                 serial,
                                 '2');

        -- -validamos si no tiene salida de puerto y su aduana es (071,072) si es asi, no puede hacer cierre
        -- -hasta que haga su salida de puerto, para otra aduana que no se a071 072, pasara directamente
        IF (cantidad = 0 AND SUBSTR (keycuo, 1, 1) = 0)
        THEN
            RETURN mt_no_salidapuerto;
        END IF;

        ----------------------


        -- Verificamos si algun tramo esta vigente
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND tra_num = 0
                 AND lst_ope = 'U'
                 AND tra_estado = 0;

        IF (cantidad = bnoexiste)
        THEN
            -- verificamos si esta registrado el transito
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U';

            IF (cantidad = 0)
            THEN
                RETURN mt_no_existe;
            END IF;

            -- Verificamos si falta localizar
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U'
                     AND tra_loc = 0;

            IF (cantidad > 0)
            THEN
                RETURN mt_concluido;
            ELSE
                SELECT   COUNT (1)
                  INTO   cantidad
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND tra_num = 0
                         AND lst_ope = 'D';

                IF (cantidad = 0)
                THEN
                    RETURN mt_no_localizado;
                ELSE
                    RETURN mt_eliminado;
                END IF;
            END IF;
        END IF;

        -- verificamos si ya esta registrado la aduana de paso para no modificar el primer tramo
        IF (keycuo IN ('071', '072'))
        THEN
            -- verificamos si estamos en el primer tramo
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = 1
                     AND tra_num = 0
                     AND lst_ope = 'U'
                     AND tra_estado = 0;

            IF (cantidad > 0)
            THEN
                -- verificamos si se registro la aduana de paso
                SELECT   COUNT (1)
                  INTO   cantidad
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND key_secuencia = 0
                         AND tra_num = 0
                         AND lst_ope = 'U';

                IF (cantidad > 0)
                THEN
                    RETURN mt_no_aduana_paso4;
                END IF;
            END IF;
        END IF;

        -- verificamos que el usuario este habilitado en la aduana de partida del transito
        cantidad :=
            verifica_usuario (keycuo,
                              gestion,
                              serial,
                              aduana_usuario,
                              bmodificacion);

        IF (cantidad = bnoexiste)
        THEN
            RETURN mt_no_usuario;
        END IF;

        -- verificamos el estado de la empresa y el medio del manifiesto
        cantidad :=
            estado_empresa_placa (keycuo,
                                  gestion,
                                  serial,
                                  bmodificacion);

        IF (cantidad = mt_boleta_garantia)
        THEN
            boleta := bexiste;
            cantidad := mt_correcto;
        END IF;

        RETURN cantidad;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;

    /**********************************************************
    * Verificamos los datos para la Finalziacion del transito *
    **********************************************************/
    FUNCTION ffinalizacion (keycuo    IN VARCHAR2,
                            gestion   IN VARCHAR2,
                            serial    IN VARCHAR2)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0);
    BEGIN
        -- verifica que el tramite tenga salida de puerto
        -- Edgar Arteaga 18082014
        /*
                 SELECT count(*)
                   INTO CANTIDAD
                   FROM TRA_PLA_RUT P
                  WHERE  KEY_CUO = KEYCUO
                    AND CAR_REG_YEAR = GESTION
                    AND CAR_REG_NBER = SERIAL
                    --AND KEY_SECUENCIA = 1
                    AND TRA_ESTADO = 0   -- en ruta
                    and tra_obs like '%REGISTRO EN SALIDA DE PUERTO%'
                    AND TRA_CUO_DES IS NULL;*/

        -- LA FUNCION  tiene_salida_puerto devuelve 1 si tiene 0 si no tiene salida de puerto
        cantidad :=
            tiene_salida_puerto (keycuo,
                                 gestion,
                                 serial,
                                 '2');

        -- validamos si no tiene salida de puerto y su aduana es (071,072) si es asi, no puede hacer cierre
        -- hasta que haga su salida de puerto, para otra aduana que no se a071 072, pasara directamente
        IF (cantidad = 0 AND SUBSTR (keycuo, 1, 1) = 0)
        THEN
            RETURN mt_no_salidapuerto;
        END IF;

        ----------------------
        -- Verificamos si algun tramo esta vigente
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND tra_num = 0
                 AND lst_ope = 'U'
                 AND tra_estado = 0;

        IF (cantidad = bnoexiste)
        THEN
            -- verificamos si esta registrado el transito
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U';

            IF (cantidad = 0)
            THEN
                RETURN mt_no_existe;
            END IF;

            -- Verificamos si falta localizar
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U'
                     AND tra_loc = 0;

            IF (cantidad > 0)
            THEN
                RETURN mt_concluido;
            ELSE
                SELECT   COUNT (1)
                  INTO   cantidad
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND tra_num = 0
                         AND lst_ope = 'D';

                IF (cantidad = 0)
                THEN
                    RETURN mt_no_localizado;
                ELSE
                    RETURN mt_eliminado;
                END IF;
            END IF;
        END IF;

        -- verificamos el estado de la empresa y el medio del manifiesto
        cantidad :=
            estado_empresa_placa (keycuo,
                                  gestion,
                                  serial,
                                  bfinalizacion);
        RETURN cantidad;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;

    FUNCTION ffinalizacion_dep (keycuo    IN VARCHAR2,
                                gestion   IN VARCHAR2,
                                serial    IN VARCHAR2)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0);
        existe     DECIMAL (2, 0);
        fec_reg   DATE;
    BEGIN
        -- verifica que el tramite tenga salida de puerto
        -- Edgar Arteaga 18082014
        /*
                 SELECT count(*)
                   INTO CANTIDAD
                   FROM TRA_PLA_RUT P
                  WHERE  KEY_CUO = KEYCUO
                    AND CAR_REG_YEAR = GESTION
                    AND CAR_REG_NBER = SERIAL
                    --AND KEY_SECUENCIA = 1
                    AND TRA_ESTADO = 0   -- en ruta
                    and tra_obs like '%REGISTRO EN SALIDA DE PUERTO%'
                    AND TRA_CUO_DES IS NULL;*/

        -- LA FUNCION  tiene_salida_puerto devuelve 1 si tiene 0 si no tiene salida de puerto
        cantidad :=
            tiene_salida_puerto (keycuo,
                                 gestion,
                                 serial,
                                 '2');

        -- validamos si no tiene salida de puerto y su aduana es (071,072) si es asi, no puede hacer cierre
        -- hasta que haga su salida de puerto, para otra aduana que no se a071 072, pasara directamente
        IF (cantidad = 0 AND SUBSTR (keycuo, 1, 1) = 0)
        THEN
            RETURN mt_no_salidapuerto;
        END IF;

        ----------------------
        -- Verificamos si algun tramo esta vigente
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND tra_num = 0
                 AND lst_ope = 'U'
                 AND tra_estado = 0;

        IF (cantidad = bnoexiste)
        THEN
            -- verificamos si esta registrado el transito
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U';

            IF (cantidad = 0)
            THEN
                RETURN mt_no_existe;
            END IF;

            -- Verificamos si falta localizar
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U'
                     AND tra_loc = 0;

            IF (cantidad > 0)
            THEN
                RETURN mt_concluido;
            ELSE
                SELECT   COUNT (1)
                  INTO   cantidad
                  FROM   tra_pla_rut
                 WHERE       key_cuo = keycuo
                         AND car_reg_year = gestion
                         AND car_reg_nber = serial
                         AND tra_num = 0
                         AND lst_ope = 'D';

                IF (cantidad = 0)
                THEN
                    RETURN mt_no_localizado;
                ELSE
                    RETURN mt_eliminado;
                END IF;
            END IF;
        END IF;

        -- verificamos el estado de la empresa y el medio del manifiesto
        cantidad :=
            estado_empresa_placa (keycuo,
                                  gestion,
                                  serial,
                                  bfinalizacion);


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
              FROM   tra_pla_rut a, tra_arr_deposito d
             WHERE       a.key_cuo = keycuo
                     AND a.car_reg_year = gestion
                     AND a.car_reg_nber = serial
                     AND a.tra_num = 0
                     AND a.lst_ope = 'U'
                     AND a.tra_estado = '0'
                     AND a.tra_cuo_est = SUBSTR (d.shd_cod, 1, 3)
                     AND a.key_cuo = d.key_cuo
                     AND a.car_reg_year = d.car_reg_year
                     AND a.car_reg_nber = d.car_reg_nber
                     AND d.arr_num = 0
                     AND d.arr_lstope = 'U';

        IF (existe = 0)
        THEN
            RETURN 150;
        END IF;

        end if;



        RETURN cantidad;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;
    /*********************************************************
    * Verificamos los datos para la Cancelacion del transito *
    *********************************************************/
    FUNCTION fcancelacion (keycuo           IN VARCHAR2,
                           gestion          IN VARCHAR2,
                           serial           IN VARCHAR2,
                           aduana_usuario   IN VARCHAR2)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0);
    BEGIN
        -- Verificamos si el primer tramo esta vigente
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND key_secuencia = 1
                 AND tra_num = 0
                 AND lst_ope IN ('M', 'U')
                 AND tra_estado = 0;

        IF (cantidad = 0)
        THEN
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'U';

            IF (cantidad > 1)
            THEN
                RETURN mt_pendiente;
            ELSE
                RETURN mt_no_existe;
            END IF;
        END IF;

        IF (keycuo IN ('071', '072'))
        THEN
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = 0
                     AND tra_num = 0
                     AND lst_ope = 'U';

            IF (cantidad > 0)
            THEN
                RETURN mt_no_aduana_paso5;
            END IF;
        END IF;

        -- verificamos que el usuario este habilitado en la aduana de partida del transito
        cantidad :=
            verifica_usuario (keycuo,
                              gestion,
                              serial,
                              aduana_usuario,
                              bcancelacion);

        IF (cantidad = bnoexiste)
        THEN
            RETURN mt_no_usuario;
        END IF;

        -- verificamos el estado de la empresa y el medio del manifiesto
        cantidad :=
            estado_empresa_placa (keycuo,
                                  gestion,
                                  serial,
                                  bcancelacion);
        RETURN cantidad;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;

    /********************************************************************
    * Verificamos los datos del transito para Punto de control de Paso *
    *********************************************************************/
    FUNCTION faduana_ptoctl (keycuo           IN VARCHAR2,
                             gestion          IN VARCHAR2,
                             serial           IN VARCHAR2,
                             aduana_usuario   IN VARCHAR2)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0);
    BEGIN
        -- Verificamos si el Transito es de la Aduana 711, 211 o 311.
        IF (NOT keycuo IN ('711', '211', '311'))
        THEN
            RETURN mt_no_aduana_pctl1;
        END IF;

        -- Verificamos que el transito a la aduana de paso se por via aerea y no carretero
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   ops$asy.car_gen
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND car_mot_cod = '4';

        IF (cantidad = 0)
        THEN
            RETURN mt_no_aduana_pctl6;
        END IF;

        -- Verificamos que no esta registrado la aduana de paso anteriormente
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND key_secuencia = 0
                 AND tra_num = 0
                 AND lst_ope = 'U';

        IF (cantidad >= bexiste)
        THEN
            RETURN mt_no_aduana_pctl3;
        END IF;

        -- Verificamos si el primer tramo es el vigente
        SELECT   COUNT (1)
          INTO   cantidad
          FROM   tra_pla_rut
         WHERE       key_cuo = keycuo
                 AND car_reg_year = gestion
                 AND car_reg_nber = serial
                 AND key_secuencia = 1
                 AND tra_num = 0
                 AND lst_ope = 'U'
                 AND tra_estado = 0;

        IF (cantidad = bnoexiste)
        THEN
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND tra_num = 0
                     AND lst_ope = 'D';

            IF (cantidad = 0)
            THEN
                RETURN mt_no_aduana_pctl2;
            ELSE
                RETURN mt_eliminado;
            END IF;
        END IF;

        -- verificamos que el usuario este habilitado en la aduana de partida del manifiesto
        --      cantidad :=
        --             verifica_usuario (keycuo, gestion, serial, aduana_usuario, bpaso);
        --      IF (cantidad = bnoexiste)
        --      THEN
        --         RETURN mt_no_usuario;
        --      END IF;

        -- verificamos el estado de la empresa y el medio del manifiesto
        cantidad :=
            estado_empresa_placa (keycuo,
                                  gestion,
                                  serial,
                                  bpaso);
        RETURN cantidad;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;


    /********************************************************************
    * Verificamos para control etiqueta *
    *********************************************************************/
    FUNCTION fetiqueta (keycuo           IN VARCHAR2,
                        gestion          IN VARCHAR2,
                        serial           IN VARCHAR2,
                        aduana_usuario   IN VARCHAR2)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0) := 1;
        adu_etiqueta   DECIMAL (2, 0) := 0;

    BEGIN
        cantidad :=
            verifica_usuario (keycuo,
                              gestion,
                              serial,
                              aduana_usuario,
                              betiqueta);

        IF (cantidad = bexiste)
        THEN

            SELECT count(1) into cantidad
            FROM unetitab a
            WHERE a.key_cuo = keycuo
            AND a.lst_ope = 'U';

            IF (cantidad = bexiste)
            THEN
                SELECT   COUNT (1)
                INTO   cantidad
                FROM   tra_pla_rut
                WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = 1
                     AND tra_num = 0
                     AND tra_estado = 0
                     AND tra_cuo_des IS NULL;
                      IF (cantidad = 0)
                    THEN
                        RETURN mt_no_existe;
                    ELSE
                        RETURN mt_correcto;
                    END IF;
            else
                RETURN mt_no_habilitadounetitab;
            end if;


        else
            RETURN mt_no_usuario;
        end if;

/*Modificado Edgar Arteaga, 08012015 para habilitar aduanas para impresion de etiquetas por la tabla UNETITAB
        /*IF (keycuo IN
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
            AND cantidad = bexiste)*/


        IF (cantidad = 0)
        THEN
            RETURN mt_no_existe;
        ELSE
            RETURN mt_correcto;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;

    /********************************************************************
    * Verificamos para control etiqueta *
    * Ruben Machaca *
    *********************************************************************/
    FUNCTION fplazoetiqueta (keycuo           IN VARCHAR2,
                             gestion          IN VARCHAR2,
                             serial           IN VARCHAR2,
                             aduana_usuario   IN VARCHAR2,
                             etapa            IN DECIMAL)
        RETURN NUMBER
    IS
        cantidad   DECIMAL (2, 0) := 1;
        hay        DECIMAL (3, 0) := 0;
        res        VARCHAR2(100);
    BEGIN
        cantidad :=
            verifica_usuario (keycuo,
                              gestion,
                              serial,
                              aduana_usuario,
                              bsalidapuerto);

        IF (keycuo IN
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
            AND cantidad = bexiste)
        THEN
            SELECT   COUNT (1)
              INTO   cantidad
              FROM   tra_pla_rut
             WHERE       key_cuo = keycuo
                     AND car_reg_year = gestion
                     AND car_reg_nber = serial
                     AND key_secuencia = 1
                     AND tra_num = 0
                     AND tra_estado = 0
                     AND tra_cuo_des IS NULL;


            -- validacion de manifiesto contra el operador


            IF (etapa = bsalidapuerto)
            THEN
                --Modificado Edgar 27112014 Nuevo OCE query 1
                SELECT   COUNT (1)
                  INTO   hay
                  FROM   car_gen a
                 WHERE       a.key_cuo = keycuo
                         AND a.car_reg_year = gestion
                         AND a.car_reg_nber = serial
                         AND 0 <
                                verifica_operador (a.car_car_cod,
                                                   a.car_id_trp);



                IF (hay = 0)
                THEN
                    RETURN mt_no_man_operador;
                END IF;
            END IF;

            -- Registro de salida de puerto Unico

            /*SELECT count(*)
              INTO HAY
              FROM TRA_PLA_RUT P
             WHERE  KEY_CUO = KEYCUO
               AND CAR_REG_YEAR = GESTION
               AND CAR_REG_NBER = SERIAL
               --AND KEY_SECUENCIA = 1
               AND TRA_ESTADO = 0   -- en ruta
               and tra_obs like '%REGISTRO EN SALIDA DE PUERTO%'
               AND TRA_CUO_DES IS NULL;*/

            hay :=
                tiene_salida_puerto (keycuo,
                                     gestion,
                                     serial,
                                     '1');

            IF (hay > 0)
            THEN
                RETURN mt_no_unico_salidapuerto;
            END IF;
        ----------------------



        ELSE
            RETURN mt_no_existe;
        END IF;

        IF (cantidad = 0)
        THEN
            RETURN mt_no_existe;
        ELSE
            RETURN mt_correcto;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;

    FUNCTION verifica_etiqueta (skey_cuo     IN     VARCHAR2,
                                scar_year    IN     VARCHAR2,
                                nreg_nber    IN     NUMBER,
                                sreg_date    IN     VARCHAR2,
                                sreg_time    IN     VARCHAR2,
                                scar_cod     IN     VARCHAR2,
                                scra_nam     IN     VARCHAR2,
                                str_regref   IN     VARCHAR2,
                                str_regdat   IN     VARCHAR2,
                                smast_name   IN     VARCHAR2,
                                smast_inf1   IN     VARCHAR2,
                                smast_inf2   IN     VARCHAR2,
                                nbl_nber     IN     NUMBER,
                                npac_nber    IN     NUMBER,
                                ngros_mass   IN     NUMBER,
                                nlin_nbr     IN     NUMBER,
                                sbol_reg     IN     VARCHAR2,
                                ngros_mas    IN     NUMBER,
                                npack_nber   IN     NUMBER,
                                sdes1        IN     VARCHAR2,
                                splaca       IN     VARCHAR2,
                                schasis      IN     VARCHAR2,
                                sctn_ident   IN     VARCHAR2,
                                stra_pre     IN     VARCHAR2,
                                nsec         IN     NUMBER,
                                saduini      IN     VARCHAR2,
                                sfecini      IN     VARCHAR2,
                                sadufin      IN     VARCHAR2,
                                sfecfin      IN     VARCHAR2,
                                opcion       IN     NUMBER,
                                dsc_aduana      OUT VARCHAR2)
        RETURN VARCHAR2
    IS
        fecha_reg_date ops$asy.car_gen.car_reg_date%TYPE
                := TO_DATE (sreg_date, 'dd/mm/yyyy');
        fecha_tr_regdat ops$asy.car_gen.car_tr_regdat%TYPE
                := TO_DATE (str_regdat, 'dd/mm/yyyy');
        fecha_inicial   DATE := TO_DATE (sfecini, 'dd/mm/yyyy hh24:mi:ss');
        fecha_final     DATE := TO_DATE (sfecfin, 'dd/mm/yyyy');
        hay1            PLS_INTEGER;
        hay2            PLS_INTEGER;
        hay3            PLS_INTEGER := 1;
        hay4            PLS_INTEGER;
        res             VARCHAR2 (100);
    BEGIN
        SELECT   COUNT (1)
          INTO   hay1
          FROM   ops$asy.car_gen a, ops$asy.car_bol_gen b, ops$asy.unpkgtab c
         WHERE       a.car_reg_year = scar_year
                 AND car_reg_nber = nreg_nber
                 AND a.key_cuo = b.key_cuo
                 AND a.key_dep_date = b.key_dep_date
                 AND a.key_voy_nber = b.key_voy_nber
                 AND b.key_lin_nbr = nbl_nber
                 AND b.carbol_sline_nber = 0
                 AND b.carbol_pack_cod = c.pkg_cod
                 AND c.lst_ope = 'U'
                 -- desde aca
                 AND a.key_cuo = skey_cuo
                 AND a.car_reg_date = fecha_reg_date
                 AND a.car_reg_time = sreg_time
                 --Instructivo AN-GEPGC-N 0192016
                 --AND a.car_car_cod = scar_cod
                 --AND a.car_car_nam = scra_nam
                 AND NVL (a.car_tr_regref, '-') = NVL (str_regref, '-')
                 AND NVL (a.car_tr_regdat, SYSDATE) =
                        NVL (fecha_tr_regdat, SYSDATE)
                 AND NVL (a.car_mast_nam, '-') = NVL (smast_name, '-')
                 AND NVL (a.car_mast_inf1, '-') = NVL (smast_inf1, '-')
                 AND NVL (a.car_mast_inf2, '-') = NVL (smast_inf2, '-')
                 AND a.car_bl_nber = nbl_nber
                 AND a.car_pac_nber = npac_nber
                 AND a.car_gros_mass = ngros_mass
                 AND b.key_lin_nbr = nlin_nbr
                 AND b.key_bol_ref = sbol_reg
                 AND b.carbol_gros_mas = ngros_mas
                 AND b.carbol_pack_nber = npack_nber;


        --Modificado Edgar 27112014 Nuevo OCE  query 2

        SELECT   COUNT (1)
          INTO   hay2
          FROM   ops$asy.bo_oce_opetipo ot, ops$asy.bo_oce_placa pl, ops$asy.bo_oce_tarope ta
         WHERE      ot.tip_tipooperador = ta.tip_tipooperador
                 AND ot.ope_numerodoc = ta.ope_numerodoc
                 AND ta.tar_num = 0
                 and ta.pla_nro_placa = pl.pla_nro_placa
                 AND ot.tip_num = 0
                 --Instructivo AN-GEPGC-N 0192016
                 --AND ot.ope_numerodoc = scar_cod
                 AND pl.pla_nro_placa = splaca
                 AND pl.pla_num = 0
                 AND pl.pla_nro_chasis = schasis
                 AND ta.tar_estado = 'H';

        IF hay2 = 0 AND SYSDATE < v_fecha_corte
        THEN
            SELECT   COUNT (1)
              INTO   hay2
              FROM   operador.olopetab a,
                     operador.olopetip e,
                     operador.oope_trp b,
                     operador.oltratab c,
                     operador.unmrctab x,
                     operador.unesttab z
             WHERE       a.ult_ver = 0
                     --Instructivo AN-GEPGC-N 0192016
                     --AND a.ope_nit = scar_cod
                     AND c.nro_placa = splaca
                     --AND FECHA_REG_DATE BETWEEN B.FCH_INI AND B.FCH_FIN
                     AND b.tbl_sta = 'H'
                     AND a.emp_cod = e.emp_cod
                     AND a.ult_ver = e.ult_ver
                     AND e.emp_cod = b.emp_cod
                     AND e.ope_tip = b.ope_tip
                     AND e.ult_ver = b.ult_ver
                     AND b.trp_cod = c.trp_cod
                     AND b.ult_ver = c.ult_ver
                     AND x.mrc_cod = c.mrc_cod
                     AND x.ult_ver = 0
                     AND z.est_cod = b.tbl_sta
                     AND z.ult_ver = 0
                     AND c.nro_cha = schasis;
        ELSE
            SELECT   COUNT (1)
              INTO   hay2
              FROM   ops$asy.bo_oce_opetipo ot, ops$asy.bo_oce_placa pl, ops$asy.bo_oce_tarope ta
         WHERE      ot.tip_tipooperador = ta.tip_tipooperador
                 AND ot.ope_numerodoc = ta.ope_numerodoc
                 AND ta.tar_num = 0
                 and ta.pla_nro_placa = pl.pla_nro_placa
                     AND ot.tip_num = 0
                     --Instructivo AN-GEPGC-N 0192016
                     --AND ot.ope_numerodoc = scar_cod
                     AND pl.pla_nro_placa = splaca
                     AND pl.pla_num = 0
                     AND pl.pla_nro_chasis = schasis
                     AND ta.tar_estado = 'H';
        END IF;

        /*SELECT COUNT (1)
          INTO hay3
          FROM ops$asy.car_bol_ctn
         WHERE     key_cuo = skey_cuo
               AND key_voy_nber = splaca
               AND key_dep_date = fecha_reg_date
               AND key_lin_nbr = 1
               AND car_ctn_typ IN ('RMLQ', 'SMRQ')
               -- desde aca
               AND car_ctn_ident = sctn_ident;*/
        IF (skey_cuo NOT IN ('071', '072'))
        THEN
            SELECT   COUNT (1)
              INTO   hay4
              FROM   tra_pla_rut
             WHERE       key_cuo = skey_cuo
                     AND car_reg_year = scar_year
                     AND car_reg_nber = nreg_nber
                     AND key_secuencia = nsec
                     AND tra_cuo_ini = saduini
                     AND tra_fec_ini = fecha_inicial
                     AND tra_cuo_est = sadufin
                     AND TRUNC (tra_fec_est) = fecha_final
                     AND tra_num = 0
                     AND lst_ope = 'U'
                     AND tra_pre = stra_pre;
        ELSE
            hay4 := 1;
        END IF;

        IF (hay1 * 1000 + hay2 * 100 + hay3 * 10 + hay4 = 1111)
        THEN
            IF (opcion = 0)
            THEN                               -- se editara la aduana de paso
                SELECT   cuo_nam
                  INTO   dsc_aduana
                  FROM   uncuotab
                 WHERE   cuo_cod = skey_cuo AND lst_ope = 'U';
            END IF;

            RETURN 'correcto';
        ELSE
            RETURN hay1 * 1000 + hay2 * 100 + hay3 * 10 + hay4;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN mt_no_existe;
        WHEN OTHERS
        THEN
            RETURN mt_error;
    END;



FUNCTION verifica_unetitab (keycuo IN VARCHAR2)
/* Formatted on 27/11/2014 21:12:27 (QP5 v5.126) */
    RETURN NUMBER
IS
    hay             NUMBER (10) := 0;
    existe          NUMBER (10) := 0;
BEGIN

     SELECT count(1) into existe
           FROM unetitab a
          WHERE a.key_cuo = keycuo
          AND a.lst_ope = 'U';

    IF existe = 0
    THEN
        hay := 0;
    ELSE
        hay := 1;
    END IF;

    RETURN hay;
END;

END;
/

