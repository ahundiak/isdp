#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/condit/COm_condit3.I */
extern int COm_decode __((char *syntax, struct ACcond_val *value));

#if defined(__cplusplus)
}
#endif


#undef __
