#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/gde/gdedriver/main_noti.c */
extern int notification_routine __((int f_label, int g_label, double value, Form fp));

#if defined(__cplusplus)
}
#endif


#undef __
