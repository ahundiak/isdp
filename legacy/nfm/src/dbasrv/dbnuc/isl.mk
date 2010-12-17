SRC=/usr2/nfm352/src/dbasrv/dbnuc/
INC=/usr2/nfm352/src/dbasrv/inc
#ACFLAGS=-ansi -DSYSV -O3 -D__cpu_c400__ -Atarg=c400 -DRIS5
ASFLAGS=
PROC=
TARG=
CC=/opt/SUNWspro/bin/cc
RISCPP=/opt/ingr/ris/risdp/bin/riscpp

CFLAGS= -Disl -DRIS5  -I/usr2/nfm352/src/dbasrv/inc -I/usr2/nfm352/src/include -I/opt/ingr/xformsdp/xfi/include   -I/opt/ingr/ris/risdp/include  -I/opt/ingr/include  -I/usr/openwin/include

dba : \
 add_att.o \
 add_column.o \
 add_ent.o \
 add_find.o \
 add_fnd_ptr.o \
 add_qry_str.o \
 add_schema.o \
 add_table.o \
 att_db.o \
 attach_sch.o \
 attached.o \
 bld_att.o \
 bld_ent.o \
 bld_wher_txt.o \
 branch.o \
 build_where.o \
 chk_rel.o \
 chk_tab.o \
 clr_schlst.o \
 code_num.o \
 codelist.o \
 current_col.o \
 cvt_date.o \
 cvt_in.o \
 cvt_out.o \
 dba_check.o \
 dbd_add_qry.o \
 dbd_init_qry.o \
 dbd_ris_err.o \
 dbd_schema.o \
 dbd_select.o \
 dbd_table.o \
 decl_sch.o \
 del_att_ptr.o \
 del_ent_ptr.o \
 delete_table.o \
 desc_index.o \
 double_quote.o \
 ex_dbnuc.o \
 f_dbnuc.o \
 flush_code.o \
 flush_schema.o \
 flush_table.o \
 format_chk.o \
 g_colnam.o \
 g_colnum.o \
 g_schnam.o \
 g_schnum.o \
 g_tabnam.o \
 g_tabnum.o \
 get_attnam.o \
 get_atyp.o \
 get_code_txt.o \
 get_commit.o \
 get_entnam.o \
 get_query.o \
 get_rel.o \
 get_sqlc.o \
 i_dbnuc.o \
 init_find.o \
 init_tab_qry.o \
 join_info.o \
 key_column.o \
 load_find.o \
 load_rel.o \
 mal_dbnu.o \
 nam_to_num.o \
 open_sch.o \
 parse_att.o \
 parse_ent.o \
 parse_relop.o \
 parse_sch.o \
 r_exec.o \
 r_prep_sql.o \
 r_sql.o \
 rd_mscols.o \
 read_schema.o \
 reg_dbnu.o \
 replace_sch.o \
 s_addqry.o \
 s_dbnuc.o \
 s_getcod.o \
 s_getqry.o \
 s_select.o \
 s_tabnum.o \
 save_qry.o \
 set_att_ptr.o \
 set_catt.o \
 set_ent_ptr.o \
 set_sch_ptr.o \
 set_schent.o \
 set_schlst.o \
 set_table.o \
 single_quote.o \
 sprintf_spec.o \
 sql_debug.o \
 sqlerr.o \
 tb_alias.o \
 up_sqltype.o \
 write_schema.o


 libdbnuc.a : $(dba)
	ar -ruv libdbnuc.a $(dba)

 add_att.o : $(SRC)add_att.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)add_att.c

 add_column.o : $(SRC)add_column.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)add_column.c

 add_ent.o : $(SRC)add_ent.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)add_ent.c

 add_find.o : $(SRC)add_find.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)add_find.c

 add_fnd_ptr.o : $(SRC)add_fnd_ptr.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)add_fnd_ptr.c

 add_qry_str.o : $(SRC)add_qry_str.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)add_qry_str.c

 add_schema.o : $(SRC)add_schema.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)add_schema.c

 add_table.o : $(SRC)add_table.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)add_table.c

 att_db.o : $(SRC)att_db.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)att_db.c

 attach_sch.o : $(SRC)attach_sch.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)attach_sch.c

 attached.o : $(SRC)attached.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)attached.c

 bld_att.o : $(SRC)bld_att.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)bld_att.c

 bld_ent.o : $(SRC)bld_ent.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)bld_ent.c

 bld_wher_txt.o : $(SRC)bld_wher_txt.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)bld_wher_txt.c

 branch.o : $(SRC)branch.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)branch.c

 build_where.o : $(SRC)build_where.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)build_where.c

 chk_rel.o : $(SRC)chk_rel.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)chk_rel.c

 chk_tab.o : $(SRC)chk_tab.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)chk_tab.c

 clr_schlst.o : $(SRC)clr_schlst.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)clr_schlst.c

 code_num.o : $(SRC)code_num.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)code_num.c

 codelist.o : $(SRC)codelist.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)codelist.c

 current_col.o : $(SRC)current_col.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)current_col.c

 cvt_date.o : $(SRC)cvt_date.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)cvt_date.c

 cvt_in.o : $(SRC)cvt_in.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)cvt_in.c

 cvt_out.o : $(SRC)cvt_out.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)cvt_out.c

 dba_check.o : $(SRC)dba_check.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)dba_check.c

 dbd_add_qry.o : $(SRC)dbd_add_qry.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)dbd_add_qry.c

 dbd_init_qry.o : $(SRC)dbd_init_qry.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)dbd_init_qry.c

 dbd_ris_err.o : $(SRC)dbd_ris_err.rc 
	$(RISCPP) ${CFLAGS} ${ACFLAGS} -r -l -c $(SRC)dbd_ris_err.rc; $(CC) ${ACFLAGS} ${CFLAGS} -DRIS5  ${PROC} ${TARG} -c dbd_ris_err.c; rm dbd_ris_err.c

 dbd_schema.o : $(SRC)dbd_schema.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)dbd_schema.c

 dbd_select.o : $(SRC)dbd_select.rc 
	$(RISCPP) ${CFLAGS} ${ACFLAGS} -r -l -c $(SRC)dbd_select.rc; $(CC) ${ACFLAGS} ${CFLAGS} -DRIS5  ${PROC} ${TARG} -c dbd_select.c; rm dbd_select.c

 dbd_table.o : $(SRC)dbd_table.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)dbd_table.c

 decl_sch.o : $(SRC)decl_sch.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)decl_sch.c

 del_att_ptr.o : $(SRC)del_att_ptr.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)del_att_ptr.c

 del_ent_ptr.o : $(SRC)del_ent_ptr.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)del_ent_ptr.c

 delete_table.o : $(SRC)delete_table.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)delete_table.c

 desc_index.o : $(SRC)desc_index.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)desc_index.c

 double_quote.o : $(SRC)double_quote.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)double_quote.c

 ex_dbnuc.o : $(SRC)ex_dbnuc.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)ex_dbnuc.c

 f_dbnuc.o : $(SRC)f_dbnuc.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)f_dbnuc.c

 flush_code.o : $(SRC)flush_code.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)flush_code.c

 flush_schema.o : $(SRC)flush_schema.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)flush_schema.c

 flush_table.o : $(SRC)flush_table.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)flush_table.c

 format_chk.o : $(SRC)format_chk.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)format_chk.c

 g_colnam.o : $(SRC)g_colnam.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)g_colnam.c

 g_colnum.o : $(SRC)g_colnum.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)g_colnum.c

 g_schnam.o : $(SRC)g_schnam.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)g_schnam.c

 g_schnum.o : $(SRC)g_schnum.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)g_schnum.c

 g_tabnam.o : $(SRC)g_tabnam.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)g_tabnam.c

 g_tabnum.o : $(SRC)g_tabnum.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)g_tabnum.c

 get_attnam.o : $(SRC)get_attnam.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)get_attnam.c

 get_atyp.o : $(SRC)get_atyp.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)get_atyp.c

 get_code_txt.o : $(SRC)get_code_txt.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)get_code_txt.c

 get_commit.o : $(SRC)get_commit.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)get_commit.c

 get_entnam.o : $(SRC)get_entnam.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)get_entnam.c

 get_query.o : $(SRC)get_query.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)get_query.c

 get_rel.o : $(SRC)get_rel.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)get_rel.c

 get_sqlc.o : $(SRC)get_sqlc.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)get_sqlc.c

 i_dbnuc.o : $(SRC)i_dbnuc.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)i_dbnuc.c

 init_find.o : $(SRC)init_find.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)init_find.c

 init_tab_qry.o : $(SRC)init_tab_qry.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)init_tab_qry.c

 join_info.o : $(SRC)join_info.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)join_info.c

 key_column.o : $(SRC)key_column.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)key_column.c

 load_find.o : $(SRC)load_find.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)load_find.c

 load_rel.o : $(SRC)load_rel.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)load_rel.c

 mal_dbnu.o : $(SRC)mal_dbnu.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)mal_dbnu.c

 nam_to_num.o : $(SRC)nam_to_num.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)nam_to_num.c

 open_sch.o : $(SRC)open_sch.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)open_sch.c

 parse_att.o : $(SRC)parse_att.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)parse_att.c

 parse_ent.o : $(SRC)parse_ent.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)parse_ent.c

 parse_relop.o : $(SRC)parse_relop.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)parse_relop.c

 parse_sch.o : $(SRC)parse_sch.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)parse_sch.c

 r_exec.o : $(SRC)r_exec.rc 
	$(RISCPP) ${CFLAGS} ${ACFLAGS} -r -l -c $(SRC)r_exec.rc; $(CC) ${ACFLAGS} ${CFLAGS} -DRIS5  ${PROC} ${TARG} -c r_exec.c; rm r_exec.c

 r_prep_sql.o : $(SRC)r_prep_sql.rc 
	$(RISCPP) ${CFLAGS} ${ACFLAGS} -r -l -c $(SRC)r_prep_sql.rc; $(CC) ${ACFLAGS} ${CFLAGS} -DRIS5  ${PROC} ${TARG} -c r_prep_sql.c; rm r_prep_sql.c

 r_sql.o : $(SRC)r_sql.rc 
	$(RISCPP) ${CFLAGS} ${ACFLAGS} -r -l -c $(SRC)r_sql.rc; $(CC) ${ACFLAGS} ${CFLAGS} -DRIS5  ${PROC} ${TARG} -c r_sql.c; rm r_sql.c

 rd_mscols.o : $(SRC)rd_mscols.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)rd_mscols.c

 read_schema.o : $(SRC)read_schema.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)read_schema.c

 reg_dbnu.o : $(SRC)reg_dbnu.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)reg_dbnu.c

 replace_sch.o : $(SRC)replace_sch.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)replace_sch.c

 s_addqry.o : $(SRC)s_addqry.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)s_addqry.c

 s_dbnuc.o : $(SRC)s_dbnuc.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)s_dbnuc.c

 s_getcod.o : $(SRC)s_getcod.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)s_getcod.c

 s_getqry.o : $(SRC)s_getqry.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)s_getqry.c

 s_select.o : $(SRC)s_select.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)s_select.c

 s_tabnum.o : $(SRC)s_tabnum.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)s_tabnum.c

 save_qry.o : $(SRC)save_qry.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)save_qry.c

 set_att_ptr.o : $(SRC)set_att_ptr.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)set_att_ptr.c

 set_catt.o : $(SRC)set_catt.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)set_catt.c

 set_ent_ptr.o : $(SRC)set_ent_ptr.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)set_ent_ptr.c

 set_sch_ptr.o : $(SRC)set_sch_ptr.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)set_sch_ptr.c

 set_schent.o : $(SRC)set_schent.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)set_schent.c

 set_schlst.o : $(SRC)set_schlst.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)set_schlst.c

 set_table.o : $(SRC)set_table.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)set_table.c

 single_quote.o : $(SRC)single_quote.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)single_quote.c

 sprintf_spec.o : $(SRC)sprintf_spec.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)sprintf_spec.c

 sql_debug.o : $(SRC)sql_debug.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)sql_debug.c

 sqlerr.o : $(SRC)sqlerr.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)sqlerr.c

 tb_alias.o : $(SRC)tb_alias.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)tb_alias.c

 up_sqltype.o : $(SRC)up_sqltype.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)up_sqltype.c

 write_schema.o : $(SRC)write_schema.c 
	$(CC) ${ACFLAGS} ${CFLAGS}  ${PROC} ${TARG} -c $(SRC)write_schema.c
