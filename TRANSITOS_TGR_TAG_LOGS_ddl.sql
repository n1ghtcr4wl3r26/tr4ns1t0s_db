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

