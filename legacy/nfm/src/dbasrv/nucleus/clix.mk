SRC=/usr2/dba/source/nucleus/
INC=/usr2/dba/source/inc/
ACFLAGS=-ansi -DSYSV -O3 -D__cpu_c400__ -Atarg=c400 -DRIS5
ASFLAGS=
PROC=
TARG=

CFLAGS= -DHANGUL -D_INGR_EXTENSIONS  -I/usr2/dba/source/inc -I/usr2/dba/source/dm_evinc  -I/usr/ip32/forms/include     -I/usr2/ip32/ris/risdp/include  -I/usr/ip32/ums/include  


dba : \
 add_err.o \
 append_error.o \
 avl.o \
 blk_und.o \
 check_max14.o \
 chunk.o \
 code_to_tic.o \
 compress.o \
 crash.o \
 creat_rtblib.o \
 d_strcmp.o \
 dba_get_opt.o \
 dba_init.o \
 dba_sort.o \
 dba_strdup.o \
 dba_swap.o \
 dbd_abort.o \
 del_temp.o \
 dmalloc.o \
 exit.o \
 exit_err.o \
 expbs.o \
 ext_temp.o \
 f_nuc.o \
 g_deltmp.o \
 g_libndx.o \
 get_msg.o \
 get_temp_typ.o \
 i_bldfnc.o \
 i_cvtfnc.o \
 i_fncexi.o \
 i_prcscr.o \
 init_err.o \
 ins_temp.o \
 int_stak.o \
 list_lib.o \
 load_opt.o \
 load_tmp.o \
 look_lib.o \
 lower.o \
 mal_nuc.o \
 movefile.o \
 nuc_mgr.o \
 nuc_util.o \
 open_msg.o \
 out_er.o \
 pad_string.o \
 parse_string.o \
 parse_tics.o \
 parse_var.o \
 r_c_w.o \
 regfunc.o \
 save_blk.o \
 search_str.o \
 setup.o \
 std_err.o \
 stralloc.o \
 strchr.o \
 strip.o \
 temptype.o \
 text_lib.o \
 tic_to_code.o \
 typed_temps.o \
 undel.o \
 upper.o \
 ustrcmp.o \
 wild.o \
 win32s.o \
 write_temp.o


 add_err.o : $(SRC)add_err.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)add_err.c

 append_error.o : $(SRC)append_error.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)append_error.c

 avl.o : $(SRC)avl.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)avl.c

 blk_und.o : $(SRC)blk_und.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)blk_und.c

 check_max14.o : $(SRC)check_max14.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)check_max14.c

 chunk.o : $(SRC)chunk.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)chunk.c

 code_to_tic.o : $(SRC)code_to_tic.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)code_to_tic.c

 compress.o : $(SRC)compress.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)compress.c

 crash.o : $(SRC)crash.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)crash.c

 creat_rtblib.o : $(SRC)creat_rtblib.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)creat_rtblib.c

 d_strcmp.o : $(SRC)d_strcmp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)d_strcmp.c

 dba_get_opt.o : $(SRC)dba_get_opt.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)dba_get_opt.c

 dba_init.o : $(SRC)dba_init.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)dba_init.c

 dba_sort.o : $(SRC)dba_sort.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)dba_sort.c

 dba_strdup.o : $(SRC)dba_strdup.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)dba_strdup.c

 dba_swap.o : $(SRC)dba_swap.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)dba_swap.c

 dbd_abort.o : $(SRC)dbd_abort.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)dbd_abort.c

 del_temp.o : $(SRC)del_temp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)del_temp.c

 dmalloc.o : $(SRC)dmalloc.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)dmalloc.c

 exit.o : $(SRC)exit.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)exit.c

 exit_err.o : $(SRC)exit_err.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)exit_err.c

 expbs.o : $(SRC)expbs.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)expbs.c

 ext_temp.o : $(SRC)ext_temp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)ext_temp.c

 f_nuc.o : $(SRC)f_nuc.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)f_nuc.c

 g_deltmp.o : $(SRC)g_deltmp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)g_deltmp.c

 g_libndx.o : $(SRC)g_libndx.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)g_libndx.c

 get_msg.o : $(SRC)get_msg.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)get_msg.c

 get_temp_typ.o : $(SRC)get_temp_typ.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)get_temp_typ.c

 i_bldfnc.o : $(SRC)i_bldfnc.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)i_bldfnc.c

 i_cvtfnc.o : $(SRC)i_cvtfnc.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)i_cvtfnc.c

 i_fncexi.o : $(SRC)i_fncexi.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)i_fncexi.c

 i_prcscr.o : $(SRC)i_prcscr.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)i_prcscr.c

 init_err.o : $(SRC)init_err.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)init_err.c

 ins_temp.o : $(SRC)ins_temp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)ins_temp.c

 int_stak.o : $(SRC)int_stak.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)int_stak.c

 list_lib.o : $(SRC)list_lib.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)list_lib.c

 load_opt.o : $(SRC)load_opt.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)load_opt.c

 load_tmp.o : $(SRC)load_tmp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)load_tmp.c

 look_lib.o : $(SRC)look_lib.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)look_lib.c

 lower.o : $(SRC)lower.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)lower.c

 mal_nuc.o : $(SRC)mal_nuc.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)mal_nuc.c

 movefile.o : $(SRC)movefile.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)movefile.c

 nuc_mgr.o : $(SRC)nuc_mgr.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)nuc_mgr.c

 nuc_util.o : $(SRC)nuc_util.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)nuc_util.c

 open_msg.o : $(SRC)open_msg.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)open_msg.c

 out_er.o : $(SRC)out_er.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)out_er.c

 pad_string.o : $(SRC)pad_string.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)pad_string.c

 parse_string.o : $(SRC)parse_string.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)parse_string.c

 parse_tics.o : $(SRC)parse_tics.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)parse_tics.c

 parse_var.o : $(SRC)parse_var.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)parse_var.c

 r_c_w.o : $(SRC)r_c_w.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)r_c_w.c

 regfunc.o : $(SRC)regfunc.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)regfunc.c

 save_blk.o : $(SRC)save_blk.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)save_blk.c

 search_str.o : $(SRC)search_str.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)search_str.c

 setup.o : $(SRC)setup.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)setup.c

 std_err.o : $(SRC)std_err.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)std_err.c

 stralloc.o : $(SRC)stralloc.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)stralloc.c

 strchr.o : $(SRC)strchr.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)strchr.c

 strip.o : $(SRC)strip.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)strip.c

 temptype.o : $(SRC)temptype.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)temptype.c

 text_lib.o : $(SRC)text_lib.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)text_lib.c

 tic_to_code.o : $(SRC)tic_to_code.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)tic_to_code.c

 typed_temps.o : $(SRC)typed_temps.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)typed_temps.c

 undel.o : $(SRC)undel.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)undel.c

 upper.o : $(SRC)upper.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)upper.c

 ustrcmp.o : $(SRC)ustrcmp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)ustrcmp.c

 wild.o : $(SRC)wild.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)wild.c

 win32s.o : $(SRC)win32s.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)win32s.c

 write_temp.o : $(SRC)write_temp.c 
	acc ${ACFLAGS} ${CFLAGS} -Dsrc_nucleus ${PROC} ${TARG} -c $(SRC)write_temp.c
