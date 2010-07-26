#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/numstr.C */
extern IGRboolean numstr __((IGRlong *msg, IGRchar **old_str, IGRchar **new_str, IGRint max_len, IGRint num_str, IGRint *new_strlen));

#if defined(__cplusplus)
}
#endif


#undef __
