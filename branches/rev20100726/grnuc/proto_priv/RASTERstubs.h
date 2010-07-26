#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/EMSstubs/RASTERstubs.c */
extern void GRrsloadctb __((void));
extern void RSstroke __((void));
extern void RScalccalib __((void));
extern void RSloadvlt __((void));

#if defined(__cplusplus)
}
#endif


#undef __
