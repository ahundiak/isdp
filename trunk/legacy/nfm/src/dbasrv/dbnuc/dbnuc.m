INCLUDE
../inc
../${NFMINC}
${INGRINC}
${RISINC}
${FORMSINC}
${XFORMSINC}
${FTRINC}
${HELPINC}
${RESINC}
${UMSINC}
${X11INC}
${RISCC}

ARCHIVE
libdbnuc.a

SOURCE
add_att.c        
dba_check.c      
get_attnam.c     
rd_mscols.c
add_column.c     
dbd_add_qry.c    
get_atyp.c       
read_schema.c
add_ent.c        
dbd_init_qry.c   
get_code_txt.c   
reg_dbnu.c
add_find.c       
dbd_ris_err.rc   
get_commit.c     
replace_sch.c
add_fnd_ptr.c    
dbd_schema.c     
get_entnam.c     
s_addqry.c
add_qry_str.c    
dbd_select.rc    
get_query.c      
s_dbnuc.c
add_schema.c     
dbd_table.c      
get_rel.c        
s_getcod.c
add_table.c      
decl_sch.c       
get_sqlc.c       
s_getqry.c
att_db.c         
del_att_ptr.c    
i_dbnuc.c        
s_select.c
attach_sch.c     
del_ent_ptr.c    
init_find.c      
s_tabnum.c
attached.c       
delete_table.c   
init_tab_qry.c   
save_qry.c
bld_att.c        
desc_index.c     
join_info.c      
set_att_ptr.c
bld_ent.c        
double_quote.c   
key_column.c     
set_catt.c
bld_wher_txt.c   
ex_dbnuc.c       
load_find.c      
set_ent_ptr.c
branch.c         
f_dbnuc.c        
load_rel.c       
set_sch_ptr.c
build_where.c    
flush_code.c     
mal_dbnu.c       
set_schent.c
chk_rel.c        
flush_schema.c   
nam_to_num.c     
set_schlst.c
chk_tab.c        
flush_table.c    
open_sch.c       
set_table.c
clr_schlst.c     
format_chk.c     
parse_att.c      
single_quote.c
code_num.c       
g_colnam.c       
parse_ent.c      
sprintf_spec.c
codelist.c       
g_colnum.c       
parse_relop.c    
sql_debug.c
current_col.c    
g_schnam.c       
parse_sch.c      
sqlerr.c
cvt_date.c       
g_schnum.c       
r_exec.rc        
tb_alias.c
cvt_in.c         
g_tabnam.c       
r_prep_sql.rc    
up_sqltype.c
cvt_out.c        
g_tabnum.c       
r_sql.rc         
write_schema.c

COMBINE_FLAG
