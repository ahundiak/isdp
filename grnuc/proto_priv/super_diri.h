#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGRdir/src/super_diri.I */
static DIis_ref __((void));
extern int DIlock_form __((void));
extern int DIunlock_form __((void));
extern int DIupdate_form __((void));

#if defined(__cplusplus)
}
#endif


#undef __
