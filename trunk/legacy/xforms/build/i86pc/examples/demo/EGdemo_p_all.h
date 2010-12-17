
/* command.c */
extern void DEMO_do_msg_box(void);
extern int DEMO_process_command(int cmd_type, char *cmd_or_help_topic);

/* exec.c */
extern int Syntax(char *pn, char *arg);
extern int Sync_on(void);
extern int Sync_off(void);
extern int main(int argc, char *argv[]);

/* notify.c */
extern void DEMO_notification_routine(int form_label, int gadget_label, double value, Form form);
