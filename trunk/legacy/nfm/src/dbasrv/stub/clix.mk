SRC=/usr2/dba/source/stub/
INC=/usr2/dba/include/
ACFLAGS=-ansi -DSYSV -O3 -Atarg=c300 -DRIS4
ASFLAGS=
PROC=
TARG=

CFLAGS= -DHANGUL -D_INGR_EXTENSIONS -I/usr2/dba/include  -I/usr/ip32/forms/include     -I/usr/ip32/ris/rispcuc/include  -I/usr/ip32/ums/include  -I/usr/ip32/nfmdp/include 


dba : \
 mc_stub.o \
 d_erase_rb.o \
 d_init_bld.o \
 d_logkbd.o \
 d_mb.o \
 d_paint_temp.o \
 d_pnt_struct.o \
 d_proc_event.o \
 d_rb.o \
 d_run_select.o \
 d_send_expos.o \
 d_write_menu.o \
 dbn_stub.o \
 dmgv_dummy.o \
 dld_dummy.o \
 dummy_link.o \
 rdvwrt_dummy.o \
 risdvw_dummy.o \
 risrpt_dummy.o \
 rpt_dummy.o \
 rptrt_dummy.o \
 run_dummy.o \
 scr_dummy.o \
 scr_dv_dummy.o \
 script_dummy.o \
 c_rdba_stub.o \
 x_dummy.o \
 no_mcsl.o \
 d_dmg_init.o \
 g_stub.o \
 d_er_mb.o \
 d_p_mb_opts.o \
 d_p_rb_opts.o \
 w_dummy.o \
 no_ris.o \
 reg_dummy.o \
 drg_graf.o \
 drg_nfm.o \
 drg_form.o \
 drg_menu.o


 mc_stub.o : $(SRC)mc_stub.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)mc_stub.c

 d_erase_rb.o : $(SRC)d_erase_rb.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_erase_rb.c

 d_init_bld.o : $(SRC)d_init_bld.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_init_bld.c

 d_logkbd.o : $(SRC)d_logkbd.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_logkbd.c

 d_mb.o : $(SRC)d_mb.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_mb.c

 d_paint_temp.o : $(SRC)d_paint_temp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_paint_temp.c

 d_pnt_struct.o : $(SRC)d_pnt_struct.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_pnt_struct.c

 d_proc_event.o : $(SRC)d_proc_event.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_proc_event.c

 d_rb.o : $(SRC)d_rb.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_rb.c

 d_run_select.o : $(SRC)d_run_select.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_run_select.c

 d_send_expos.o : $(SRC)d_send_expos.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_send_expos.c

 d_write_menu.o : $(SRC)d_write_menu.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_write_menu.c

 dbn_stub.o : $(SRC)dbn_stub.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)dbn_stub.c

 dmgv_dummy.o : $(SRC)dmgv_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)dmgv_dummy.c

 dld_dummy.o : $(SRC)dld_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)dld_dummy.c

 dummy_link.o : $(SRC)dummy_link.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)dummy_link.c

 rdvwrt_dummy.o : $(SRC)rdvwrt_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)rdvwrt_dummy.c

 risdvw_dummy.o : $(SRC)risdvw_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)risdvw_dummy.c

 risrpt_dummy.o : $(SRC)risrpt_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)risrpt_dummy.c

 rpt_dummy.o : $(SRC)rpt_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)rpt_dummy.c

 rptrt_dummy.o : $(SRC)rptrt_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)rptrt_dummy.c

 run_dummy.o : $(SRC)run_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)run_dummy.c

 scr_dummy.o : $(SRC)scr_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)scr_dummy.c

 scr_dv_dummy.o : $(SRC)scr_dv_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)scr_dv_dummy.c

 script_dummy.o : $(SRC)script_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)script_dummy.c

 c_rdba_stub.o : $(SRC)c_rdba_stub.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)c_rdba_stub.c

 x_dummy.o : $(SRC)x_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)x_dummy.c

 no_mcsl.o : $(SRC)no_mcsl.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)no_mcsl.c

 d_dmg_init.o : $(SRC)d_dmg_init.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_dmg_init.c

 g_stub.o : $(SRC)g_stub.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)g_stub.c

 d_er_mb.o : $(SRC)d_er_mb.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_er_mb.c

 d_p_mb_opts.o : $(SRC)d_p_mb_opts.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_p_mb_opts.c

 d_p_rb_opts.o : $(SRC)d_p_rb_opts.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)d_p_rb_opts.c

 w_dummy.o : $(SRC)w_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)w_dummy.c

 no_ris.o : $(SRC)no_ris.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)no_ris.c

 reg_dummy.o : $(SRC)reg_dummy.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)reg_dummy.c

 drg_graf.o : $(SRC)drg_graf.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)drg_graf.c

 drg_nfm.o : $(SRC)drg_nfm.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)drg_nfm.c

 drg_form.o : $(SRC)drg_form.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)drg_form.c

 drg_menu.o : $(SRC)drg_menu.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_stub ${PROC} ${TARG} -c $(SRC)drg_menu.c
