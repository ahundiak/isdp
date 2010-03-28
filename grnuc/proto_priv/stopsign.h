#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/stopsign/stopsign.c */
extern void usage __((char *progname));
extern void refresh_sign __((void));
extern void trap_signals __((void));
extern void activate_sign __((int sig));
extern void deactivate_sign __((int sig));
extern int form_notification __((int f_label, int g_label, double value, Form fp));
extern int translate_color __((int vs, int color));
extern int main __((int argc, char *argv[]));

#if defined(__cplusplus)
}
#endif


#undef __
