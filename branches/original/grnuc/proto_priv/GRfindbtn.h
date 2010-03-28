#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRfindbtn.c */
extern int GRfind_button_on_menu_bar __((char *cmd_to_find, Form *menu_bar_arg, int *button_label));

#if defined(__cplusplus)
}
#endif


#undef __
