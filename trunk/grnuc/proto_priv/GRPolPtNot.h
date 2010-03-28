#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/event/GRPolPtNot.I */
extern void GRPolarDpt_notification __((int f_label, int g_label, double value, Form fp));
extern void GRPolarDpt_init __((Form fp));

#if defined(__cplusplus)
}
#endif


#undef __
