#ifndef __DBA_FUNC__
#define __DBA_FUNC__

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

typedef  int  (*DBA_F01) (char *logical, struct dba_att *att_ptr, char *relop); // dba_add_find
typedef  int  (*DBA_F02) (struct dba_ent *ent_ptr, int *got_where, int fence, int create_flag, char **s1_ptr, unsigned long *s1_size, int from_report); // dba_build_where
typedef  int  (*DBA_F03) (short *buffer, short *link_offset, short *entity, long *mslink, short *wtf, char *type); // dba_check_link
typedef  int  (*DBA_F04) (int curs);                // dba_close_cursor
typedef  int  (*DBA_F05) (char *string);            // dba_conv_to_dos
typedef  int  (*DBA_F06) (void *ptr);               // dba_dfree
typedef  int  (*DBA_F07) (void);                    // dba_display_dbe
typedef  void *(*DBA_F08) (unsigned long size, unsigned long desc, char *file, int line); // dba_dmalloc_ex
typedef  int  (*DBA_F09) ();                        // dba_double_quote
typedef  void *(*DBA_F10) (void *ptr, unsigned long size); // dba_drealloc
typedef  char *(*DBA_F11) (char *str, unsigned long desc, char *file, int line); // dba_dstrdup_ex
typedef  int  (*DBA_F12) (Form fpt, int mnunum);    // dba_f_display
typedef  int  (*DBA_F13) (int curs, sqlda *in_desc, ...); // dba_fetch
typedef  int  (*DBA_F14) (void);                    // dba_get_autocommit
typedef  int  (*DBA_F15) (char *tabnam, long *max); // dba_get_max_mslink
typedef  int  (*DBA_F16) (char *menu, int *mnunum); // dba_get_mnunum
typedef  int  (*DBA_F17) (long msgnum, char *msgfmt, int maxlen, void *ptr1, void *ptr2); // dba_get_msg
typedef  int  (*DBA_F18) (char *schema, char *table, char **query); // dba_get_query
typedef  int  (*DBA_F19) (int field, char *text);  // dba_gra_msg
typedef  int  (*DBA_F20) (void);                   // dba_init_find
typedef  void (*DBA_F21) (char *script);           // dba_inq_process_script
typedef  int  (*DBA_F22) (void);                   // dba_insert_record
typedef  int  (*DBA_F23) (char *text_ptr);         // dba_lower
typedef  int  (*DBA_F24) (int label, char *name, int (*notify)(), Form *fpt); // dba_menu_new
typedef  int  (*DBA_F25) (int form_label, int label, double value, Form fpt); // dba_notify
typedef  char *(*DBA_F26) (long msgnum, char *msgfmt, int maxlng, void *ptr1, void *ptr2, void *ptr3); // dba_open_msg
typedef  int  (*DBA_F27) (Form *fpt);              // dba_pop_form_to_top
typedef  int  (*DBA_F28) (char *msg);              // dba_print_message
typedef  int  (*DBA_F29) (char *msg);              // dba_print_msg
typedef  int  (*DBA_F30) (char *prompt_text);      // dba_print_prompt
typedef  int  (*DBA_F31) (int key, int (*ser)());  // dba_register_service
typedef  int  (*DBA_F32) (int curs, sqlda **in_desc, char *sqltxt); // dba_select
typedef  int  (*DBA_F33) (struct dba_ent *ent_ptr, char *entnam, char *attnam, struct dba_att **att_ptr, int msg, int alias); // dba_set_att_ptr
typedef  int  (*DBA_F34) (int mnunum);             // dba_set_currow
typedef  int  (*DBA_F35) (int schema, int entnum, char *entnam, struct dba_ent **ent_ptr, int msg, int alias); // dba_set_ent_ptr
typedef  int  (*DBA_F36) (struct dba_ent *ent_ptr);// dba_set_select
typedef  void (*DBA_F37) (void);                   // dba_sigset
typedef  int  (*DBA_F38) (int val);                // dba_sleep
typedef  int  (*DBA_F39) (char *sqlptr);           // dba_sql
typedef  int  (*DBA_F40) (void);                   // dba_sqlerr
typedef  int  (*DBA_F41) (void);                   // dba_update_no_db
typedef  int  (*DBA_F42) (char *text_ptr);         // dba_upper
typedef  int  (*DBA_F43) (int val);                // dba_usleep
typedef  int  (*DBA_F44) (int flag);               // dba_wait_cursor
typedef  int  (*DBA_F45) (int discard);            // dba_xsync
typedef  int  (*DBA_F46) (int flag, char *title, char *szFormat, ...); // VI_message_box
typedef  int  (*DBA_F47) (char *filename);         // VI_open_dialog
typedef  int  (*DBA_F48) (char *name);             // VIapp_get_client
typedef  int  (*DBA_F49) (char *name);             // VIapp_get_window
typedef  int  ((*(*DBA_F50) (int key))());         // dba_inq_service
typedef  long (*DBA_F51) (char *name, void (*func_ptr)(), long mode); // dba_pseudo_reg_func
typedef  long (*DBA_F52) (char *name, void (*func_ptr)()); // dba_register_function
typedef  long (*DBA_F53) (void);                   // dba_reg_arg_end
typedef  long (*DBA_F54) (char *name);             // dba_reg_arg_start
typedef  void (*DBA_F55) (void);                   // dba_reg_default_argnum_enforce_off
typedef  void (*DBA_F56) (void);                   // dba_reg_default_argnum_enforce_on
typedef  void (*DBA_F57) (void);                   // dba_reg_default_verbose_off
typedef  void (*DBA_F58) (long type, long val);    // dba_reg_default_verbose_on
typedef  long (*DBA_F59) (void);                   // dba_reg_func_end
typedef  long (*DBA_F60) (char *name, void (*func_ptr)()); // dba_reg_func_start
typedef  long (*DBA_F61) (unsigned long size);     // dba_reg_set_arg_buffered_expand
typedef  long (*DBA_F62) (long indir, long enforce, long nulls_ok); // dba_reg_set_arg_indir
typedef  long (*DBA_F63) (long flag);              // dba_reg_set_arg_output
typedef  long (*DBA_F64) (long (*func)(), long trans_size, long trans_type); // dba_reg_set_arg_transform
typedef  long (*DBA_F65) (long type, long type_enforce, long us, long us_enforce, long str_convert); // dba_reg_set_arg_type
typedef  long (*DBA_F66) (functiontype *bfunc, functiontype *function, long opnum); // dba_s_display_graphics
typedef  long (*DBA_F67) (operandtype *ptrop, void *valptr, char ***arg_ptr, char ***alloc_ptr, int alloc_size, char *func_name, int *ret_override_flag, int *ret_overrive_value); // dba_trans_menu_arg
typedef  int  (*DBA_F68) (struct dba_ent *ent_ptr, int set, int mslink); // dba_check_mslink
typedef  int  (*DBA_F69) (void);                       // dba_clear_msg
typedef  int  (*DBA_F70) (char *script_text);          // dba_print_script
typedef  int  (*DBA_F71) (char *menu, int preserve);   // dba_display_menu
typedef  int  (*DBA_F72) (char *menu);                 // dba_pop_to_top
typedef  int  (*DBA_F73) (int window, int *x, int *y); // dba_get_point
typedef  int  (*DBA_F74) ();                           // dba_get_sqlcode
typedef  int  (*DBA_F75) (char *format, ...);      // dba_printf
typedef  void  (*DBA_F76) (void);                  // dba_reg_default_init_env_check

/*
** Set up functions for use by dlls
*/

typedef struct dba_FunctionTable
{
  DBA_F01  f01;                            // dba_add_find
  DBA_F02  f02;                            // dba_build_where
  DBA_F03  f03;                            // dba_check_link
  DBA_F04  f04;                            // dba_close_cursor
  DBA_F05  f05;                            // dba_conv_to_dos
  DBA_F06  f06;                            // dba_dfree
  DBA_F07  f07;                            // dba_display_dbe
  DBA_F08  f08;                            // dba_dmalloc_ex
  DBA_F09  f09;                            // dba_double_quote
  DBA_F10  f10;                            // dba_drealloc
  DBA_F11  f11;                            // dba_dstrdup_ex
  DBA_F12  f12;                            // dba_f_display
  DBA_F13  f13;                            // dba_fetch
  DBA_F14  f14;                            // dba_get_autocommit
  DBA_F15  f15;                            // dba_get_max_mslink
  DBA_F16  f16;                            // dba_get_mnunum
  DBA_F17  f17;                            // dba_get_msg
  DBA_F18  f18;                            // dba_get_query
  DBA_F19  f19;                            // dba_gra_msg
  DBA_F20  f20;                            // dba_init_find
  DBA_F21  f21;                            // dba_inq_process_script
  DBA_F22  f22;                            // dba_insert_record
  DBA_F23  f23;                            // dba_lower
  DBA_F24  f24;                            // dba_menu_new
  DBA_F25  f25;                            // dba_notify
  DBA_F26  f26;                            // dba_open_msg
  DBA_F27  f27;                            // dba_pop_form_to_top
  DBA_F28  f28;                            // dba_print_message
  DBA_F29  f29;                            // dba_print_msg
  DBA_F30  f30;                            // dba_print_prompt
  DBA_F31  f31;                            // dba_register_service
  DBA_F32  f32;                            // dba_select
  DBA_F33  f33;                            // dba_set_att_ptr
  DBA_F34  f34;                            // dba_set_currow
  DBA_F35  f35;                            // dba_set_ent_ptr
  DBA_F36  f36;                            // dba_set_select
  DBA_F37  f37;                            // dba_sigset
  DBA_F38  f38;                            // dba_sleep
  DBA_F39  f39;                            // dba_sql
  DBA_F40  f40;                            // dba_sqlerr
  DBA_F41  f41;                            // dba_update_no_db
  DBA_F42  f42;                            // dba_upper
  DBA_F43  f43;                            // dba_usleep
  DBA_F44  f44;                            // dba_wait_cursor
  DBA_F45  f45;                            // dba_xsync
  DBA_F46  f46;                            // VI_message_box
  DBA_F47  f47;                            // VI_open_dialog
  DBA_F48  f48;                            // VIapp_get_client
  DBA_F49  f49;                            // VIapp_get_window
  DBA_F50  f50;                            // dba_inq_service
  DBA_F51  f51;                            // dba_pseudo_reg_func
  DBA_F52  f52;                            // dba_register_function
  DBA_F53  f53;                            // dba_reg_arg_end
  DBA_F54  f54;                            // dba_reg_arg_start
  DBA_F55  f55;                            // dba_reg_default_argnum_enforce_off
  DBA_F56  f56;                            // dba_reg_default_argnum_enforce_on
  DBA_F57  f57;                            // dba_reg_default_verbose_off
  DBA_F58  f58;                            // dba_reg_default_verbose_on
  DBA_F59  f59;                            // dba_reg_func_end
  DBA_F60  f60;                            // dba_reg_func_start
  DBA_F61  f61;                            // dba_reg_set_arg_buffered_expand
  DBA_F62  f62;                            // dba_reg_set_arg_indir
  DBA_F63  f63;                            // dba_reg_set_arg_output
  DBA_F64  f64;                            // dba_reg_set_arg_transform
  DBA_F65  f65;                            // dba_reg_set_arg_type
  DBA_F66  f66;                            // dba_s_display_graphics
  DBA_F67  f67;                            // dba_trans_menu_arg
  DBA_F68  f68;                            // dba_check_mslink
  DBA_F69  f69;                            // dba_clear_msg
  DBA_F70  f70;                            // dba_print_status
  DBA_F71  f71;                            // dba_display_menu
  DBA_F72  f72;                            // dba_pop_to_top
  DBA_F73  f73;                            // dba_get_point
  DBA_F74  f74;                            // dba_get_sqlcode
  DBA_F75  f75;                            // dba_printf
  DBA_F76  f76;                            // dba_reg_default_init_env_check
} DBA_FUNCTION_TABLE;

/*
** Set up global variables needed by dll
*/

typedef struct dba_VariableTable
{
  char           *v01;                     // dba_app_template
  int            *v02;                     // dba_attach_mode
  struct dba_ent **v03;                    // dba_cent
  struct dba_sch **v04;                    // dba_csch 
  int            *v05;                     // dba_debug
  int            *v06;                     // dba_delete_row_toggle
  int            *v07;                     // dba_error
  char           *v08;                     // dba_errtxt
  int            *v09;                     // dba_fldtrm
  char           *v10;                     // dba_fldval
  Form           *v11;                     // dba_form
  int            *v12;                     // dba_graphic_mode
  HINSTANCE      *v13;                     // dba_instance
  short          *v14;                     // dba_level_mask
  int            *v15;                     // dba_level_mode
  int            *v16;                     // dba_mnunum
  char           *v17;                     // dba_mslink
  int            *v18;                     // dba_nest_mode
  char           *v19;                     // dba_raster
  int            *v20;                     // dba_table_count
  char           *v21;                     // dba_text
  int            *v22;                     // dba_topmost
  short          *v23;                     // dba_type_mask
  char           *v24;                     // dba_root_dir
  int            *v25;                     // dba_status_field
} DBA_VARIABLE_TABLE;

#endif
