#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* DPinvmxRT.c */
int DPinvmxRT __((double *mx, double *invmx));

#if defined(__cplusplus)
}
#endif


#undef __
