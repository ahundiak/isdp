#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/asap_comm/CLAA_comm.c */
#if defined(CLIX)
extern int AA_allocate __((char *asap_path, char *asap_name));
extern int AA_load_application __((char *asap_path, char *asap_name));
extern int AA_process_misc __((void));
extern int AA_inquire __((void));
extern int AA_really_busy __((void));
extern int AA_need_to_flush_answers __((void));
extern int AA_toggle_usage __((void));
extern int CLAA_get_request_ptrs __((int request_size, int request_type, char **clip_addr, char **asap_addr));
extern void CLAA_request_complete __((void));
extern int CLAA_get_answer_ptrs __((int *answer_type, char **clip_addr, char **asap_addr));
extern void CLAA_answer_complete __((void));
extern int AA_timer __((unsigned int *clock));
extern int AA_timer_pop __((void));
extern int AA_set_timer_usage __((int state));
extern int asap_debug __((void));
extern int dump_memory __((char *start, int bytes));
extern void AA_print_stats __((void));
#else
extern int AA_allocate __((void));
extern int AA_load_application __((void));
extern int AA_process_misc __((void));
extern int AA_inquire __((void));
extern int AA_really_busy __((void));
extern int AA_need_to_flush_answers __((void));
extern int AA_toggle_usage __((void));
extern int CLAA_get_request_ptrs __((void));
extern void CLAA_request_complete __((void));
extern int CLAA_get_answer_ptrs __((void));
extern void CLAA_answer_complete __((void));
extern int AA_timer __((void));
extern int AA_timer_pop __((void));
extern int AA_set_timer_usage __((void));
extern int asap_debug __((void));
#endif

#if defined(__cplusplus)
}
#endif


#undef __
