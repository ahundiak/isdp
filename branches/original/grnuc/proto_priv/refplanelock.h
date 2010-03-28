#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/stubs/refplanelock.c */
extern int EFref_plane_lock __((void));

#if defined(__cplusplus)
}
#endif


#undef __
