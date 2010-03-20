
/* accessform.c */
extern void acc_form(void);

/* chkerror.c */
extern int chkerror(int sts, char *string);

/* continuous.c */
extern void continuous_routine(int form_label, int gadget_label, double value, Form *form_ptr);

/* createlist.c */
extern void create_list(void);

/* createmulti.c */
extern void create_multi(void);

/* doresults.c */
extern void do_results(void);

/* main.c */
extern int Syntax(char *pn, char *arg);
extern int Sync_on(void);
extern int Sync_off(void);
extern int main(int argc, char *argv[]);

/* notify.c */
extern void notification_routine(int form_label, int gadget_label, double value, Form form);

/* switchsymbol.c */
extern void switch_symbol(Form form, int gadget_label, int sym_index);

/* wallform.c */
extern int wall_form(void);
