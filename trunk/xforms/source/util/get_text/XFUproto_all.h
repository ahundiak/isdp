
/* BAGgetopt.c */
extern int BAGgetopt(int argc, char **argv, char *optstring);

/* get_text.c */
extern int _FI_g_output_text(struct FIgadget_obj *gadget, FILE *outfp);
extern int FIf_get_text(Form form_ptr, FILE *outfp, char *form_name);

/* main.c */
extern void notification_routine(void);
extern void print_usage(void);
extern int API_HANDLE_SHUTDOWN(void);
