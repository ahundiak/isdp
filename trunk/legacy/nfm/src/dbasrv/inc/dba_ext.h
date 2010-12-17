/* $Revision: 1.1 $ */

/*
** Set up global variables
*/

extern struct dba_ent *dba_cent;
extern struct dba_sch *dba_csch;
extern char  dba_app_template[];
extern int   dba_attach_mode;
extern int   dba_debug;
extern int   dba_delete_row_toggle;
extern int   dba_error;
extern char *dba_errtxt;
extern int   dba_fldtrm;
extern char *dba_fldval;
extern Form  dba_form[];
extern int   dba_graphic_mode;
extern char  dba_key_buf[];
extern short dba_level_mask[];
extern int   dba_level_mode;
extern int   dba_mnunum;
extern char *dba_mslink;
extern int   dba_nest_mode;
extern char *dba_raster;
extern char *dba_root_dir;
extern int   dba_select_button;
extern int   dba_status_field;
extern int   dba_table_count;
extern char  dba_text[];
extern int   dba_topmost;
extern short dba_type_mask[];

#if defined __WIN16__ || defined __WIN32__
extern HINSTANCE dba_instance;
#endif
