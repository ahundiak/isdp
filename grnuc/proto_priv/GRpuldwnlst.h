#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cosup/GRpuldwnlst.c */
extern int GRcreate_pull_down_list __((int form_label, Form form, int field, int max_rows, int num_vis_rows, char *text_strings[], int num_text_strings, int position, int *form_id));
extern int GRgetassocpos __((Form form, int field, int num_vis_rows, int max_rows, int position, int *new_form_x_pos, int *new_form_y_pos, int *new_form_x_size, int *new_form_y_size));
extern void GRasfmbntevent __((Form form, int xpos, int ypos, int button_number, int transition, int time_tag));
extern void GRasfmwinevent __((int form_label, int event, Form form));
extern void GRlist_notify_routine __((int form_label, int gadget_label, double value, Form form));
extern int GRproc_pull_down_list __((int form_no));
extern int GRchange_pull_down_text __((int form_no, char **text, int num_text));
extern int GRdelete_pull_down_list __((int form_no));

#if defined(__cplusplus)
}
#endif


#undef __
