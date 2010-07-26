#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/palgo/GRpallib.I */
extern int GRpal_window_icon_routine __((int form_label, int icon_id, Form form));
extern int GRpal_button_intercept_routine __((Form form, int xpos, int ypos, int button, int trans, int t_tag));
static int GRpal_set_collapse_location __((Form form_id, int *form_slot));
static struct palette *GRpal_create_node __((void));
static int GRpal_delete_node __((struct palette *p));
static int GRpal_set_paths __((void));
extern int GRpal_get_paths __((char ***paths, int *num));
extern int GRpal_check_file __((char *filename, char *fullname, int check));
extern int GRpal_check_icon __((char *filename, char *fullname, int check));
extern void GRpal_add_popup_icons __((struct palette *p));
extern struct palette *GRpal_create __((int *msg, int properties, int rows, int cols, int color, int xpos, int ypos, int xsize, int ysize, int btn_x, int btn_y, int btn_on_color, int btn_off_color));
extern int GRpal_del_cmd __((struct palette *p, int row, int col));
extern int GRpal_set_outline_fp __((void));
extern int GRpal_get_cmd_icon __((char *cmd_key, char *symbol_file, int *symbol));
extern int GRpal_add_cmd __((struct palette *p, int row, int col, int type, char *command, char *symbol_file, int symbol));
extern struct palette *GRpal_recreate __((int *msg, char *filename));
extern struct palette *GRpal_recreate_autodismiss __((int *msg, char *filename));
extern int GRpal_get_header_info __((struct palette *p, int *xpos, int *ypos, int *xsize, int *ysize, int *rows, int *cols, int *btn_x, int *btn_y, int *color, int *btn_on_color, int *btn_off_color, int *properties));
extern int GRpal_get_cmd_info __((struct palette *p, int label, char *command, int *command_type, char *symbol_file, int *symbol));
extern int GRpal_save_file __((struct palette *p, char *filename));
extern int GRpal_check_palmgr __((void));
extern int GRpal_delete __((struct palette *p));
extern int GRpal_get_last_cmd __((struct palette **p, IGRint *label, IGRint *row, IGRint *col));

#if defined(__cplusplus)
}
#endif


#undef __
