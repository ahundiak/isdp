#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGRdir/src/COdirxlate.C */
extern int CO_xlate_from_user_mode __((IGRint mode, IGRchar *path1, IGRchar *path2));
extern int CO_xlate_to_user_mode __((IGRint mode, IGRchar *path1, IGRchar *path2));

#if defined(__cplusplus)
}
#endif


#undef __
