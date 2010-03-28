#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/asap_comm/dekkers.c */
extern void enter_critical __((int my_process, volatile int *my_wants, volatile int *it_wants, volatile int *favored));
extern void exit_critical __((int my_process, volatile int *my_wants, volatile int *favored));

#if defined(__cplusplus)
}
#endif


#undef __
