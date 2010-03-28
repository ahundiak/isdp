#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/expression/exp_ovrdi.I */
extern IGRshort EXP_len_locate __((char *Pattern, char *Source, int Start, int Stop, int length));
extern IGRshort EXP_len_substitute __((char *old_name, char *new_name, char *expr, int subs_type, int how_many_type, int length));

#if defined(__cplusplus)
}
#endif


#undef __
