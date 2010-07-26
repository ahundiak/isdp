#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/palgo/GRpopup.I */
extern int GRpopup_set_fp __((void));
extern int GRpopup_find __((char *command, char *filename));
extern struct popup *GRpopup_create __((int *msg, char *command, Form menu_form, int menu_label));
extern int GRdisplay_command_name __((Form form, int label, char *command));
extern int GRpopup_locate __((int *msg, char *command, Form menu_form, int menu_label, struct popup **pu));
extern int GRpopup_process __((int *msg, char *command, Form menu_form, int menu_label, int type));
extern int GRmenu_button_intercept_routine __((Form form, int xpos, int ypos, int button, int trans, int t_tag));

#if defined(__cplusplus)
}
#endif


#undef __
