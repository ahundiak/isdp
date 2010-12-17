/* $Revision: 1.1 $ */
#ifndef __DBA_DLL__
#define __DBA_DLL__

#include "dba_func.h"
/*
** Set up dba core functions
*/
extern DBA_FUNCTION_TABLE *dba_func_tbl;

#define dba_add_find                        dba_func_tbl->f01
#define dba_build_where                     dba_func_tbl->f02
#define dba_check_link                      dba_func_tbl->f03
#define dba_close_cursor                    dba_func_tbl->f04
#define dba_conv_to_dos                     dba_func_tbl->f05
#define dba_dfree                           dba_func_tbl->f06
#define dba_display_dbe                     dba_func_tbl->f07
#define dba_dmalloc_ex                      dba_func_tbl->f08
#define dba_double_quote                    dba_func_tbl->f09
#define dba_drealloc                        dba_func_tbl->f10
#define dba_dstrdup_ex                      dba_func_tbl->f11
#define dba_f_display                       dba_func_tbl->f12
#define dba_fetch                           dba_func_tbl->f13
#define dba_get_autocommit                  dba_func_tbl->f14
#define dba_get_max_mslink                  dba_func_tbl->f15
#define dba_get_mnunum                      dba_func_tbl->f16
#define dba_get_msg                         dba_func_tbl->f17
#define dba_get_query                       dba_func_tbl->f18
#define dba_gra_msg                         dba_func_tbl->f19
#define dba_init_find                       dba_func_tbl->f20
#define dba_inq_process_script              dba_func_tbl->f21
#define dba_insert_record                   dba_func_tbl->f22
#define dba_lower                           dba_func_tbl->f23
#define dba_menu_new                        dba_func_tbl->f24
#define dba_notify                          dba_func_tbl->f25
#define dba_open_msg                        dba_func_tbl->f26
#define dba_pop_form_to_top                 dba_func_tbl->f27
#define dba_print_message                   dba_func_tbl->f28
#define dba_print_msg                       dba_func_tbl->f29
#define dba_print_prompt                    dba_func_tbl->f30
#define dba_register_service                dba_func_tbl->f31
#define dba_select                          dba_func_tbl->f32
#define dba_set_att_ptr                     dba_func_tbl->f33
#define dba_set_currow                      dba_func_tbl->f34
#define dba_set_ent_ptr                     dba_func_tbl->f35
#define dba_set_select                      dba_func_tbl->f36
#define dba_sigset                          dba_func_tbl->f37
#define dba_sleep                           dba_func_tbl->f38
#define dba_sql                             dba_func_tbl->f39
#define dba_sqlerr                          dba_func_tbl->f40
#define dba_update_no_db                    dba_func_tbl->f41
#define dba_upper                           dba_func_tbl->f42
#define dba_usleep                          dba_func_tbl->f43
#define dba_wait_cursor                     dba_func_tbl->f44
#define dba_xsync                           dba_func_tbl->f45
#define VI_message_box                      dba_func_tbl->f46
#define VI_open_dialog                      dba_func_tbl->f47
#define VIapp_get_client                    dba_func_tbl->f48
#define VIapp_get_window                    dba_func_tbl->f49
#define dba_inq_service                     dba_func_tbl->f50
#define dba_pseudo_reg_func                 dba_func_tbl->f51
#define dba_register_function               dba_func_tbl->f52
#define dba_reg_arg_end                     dba_func_tbl->f53
#define dba_reg_arg_start                   dba_func_tbl->f54
#define dba_reg_default_argnum_enforce_off  dba_func_tbl->f55
#define dba_reg_default_argnum_enforce_on   dba_func_tbl->f56
#define dba_reg_default_verbose_off         dba_func_tbl->f57
#define dba_reg_default_verbose_on          dba_func_tbl->f58
#define dba_reg_func_end                    dba_func_tbl->f59
#define dba_reg_func_start                  dba_func_tbl->f60
#define dba_reg_set_arg_buffered_expand     dba_func_tbl->f61
#define dba_reg_set_arg_indir               dba_func_tbl->f62
#define dba_reg_set_arg_output              dba_func_tbl->f63
#define dba_reg_set_arg_transform           dba_func_tbl->f64
#define dba_reg_set_arg_type                dba_func_tbl->f65
#define dba_s_display_graphics              dba_func_tbl->f66
#define dba_trans_menu_arg                  dba_func_tbl->f67
#define dba_check_mslink                    dba_func_tbl->f68
#define dba_clear_msg                       dba_func_tbl->f69
#define dba_print_status                    dba_func_tbl->f70
#define dba_display_menu                    dba_func_tbl->f71
#define dba_pop_to_top                      dba_func_tbl->f72
#define dba_get_point                       dba_func_tbl->f73
#define dba_get_sqlcode                     dba_func_tbl->f74
#define dba_printf                          dba_func_tbl->f75
#define dba_reg_default_init_env_check      dba_func_tbl->f76

/*
** Set up global variables
*/

extern DBA_VARIABLE_TABLE *dba_vari_tbl;

#define dba_app_template             (dba_vari_tbl->v01) // char
#define dba_attach_mode             (*dba_vari_tbl->v02) // int
#define dba_cent  ((struct dba_ent *)*dba_vari_tbl->v03) // struct dba_ent *
#define dba_csch  ((struct dba_sch *)*dba_vari_tbl->v04) // struct dba_sch *
#define dba_debug                   (*dba_vari_tbl->v05) // int
#define dba_delete_row_toggle       (*dba_vari_tbl->v06) // int
#define dba_error                   (*dba_vari_tbl->v07) // int
#define dba_errtxt                   (dba_vari_tbl->v08) // char *
#define dba_fldtrm                  (*dba_vari_tbl->v09) // int
#define dba_fldval                   (dba_vari_tbl->v10) // char *
#define dba_form                     (dba_vari_tbl->v11) // Form
#define dba_graphic_mode            (*dba_vari_tbl->v12) // int
#define dba_instance                 (dba_vari_tbl->v13) // HINSTANCE
#define dba_level_mask               (dba_vari_tbl->v14) // short [4]
#define dba_level_mode              (*dba_vari_tbl->v15) // int
#define dba_mnunum                  (*dba_vari_tbl->v16) // int
#define dba_mslink                   (dba_vari_tbl->v17) // char *
#define dba_nest_mode               (*dba_vari_tbl->v18) // int
#define dba_raster                   (dba_vari_tbl->v19) // char *
#define dba_table_count             (*dba_vari_tbl->v20) // int
#define dba_text                     (dba_vari_tbl->v21) // char
#define dba_topmost                 (*dba_vari_tbl->v22) // int
#define dba_type_mask                (dba_vari_tbl->v23) // short [8]
#define dba_root_dir                 (dba_vari_tbl->v24) // char *
#define dba_status_field            (*dba_vari_tbl->v25) // int

#endif
