#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRdisassoc.C */
extern IGRint GRdisplay_associative_button __((IGRint on));
extern IGRint EFdisplay_associative_button __((IGRint on));
extern void GRupdate_assoc_button __((void));
extern void GRupdate_assoc_buttons __((void));

#if defined(__cplusplus)
}
#endif


#undef __
