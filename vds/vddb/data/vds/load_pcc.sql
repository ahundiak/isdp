begin work;
load from "/usr/tmp/p_comm_cod" delimiter "|" insert into PIPING_COMMOD_CODE;
commit work;
