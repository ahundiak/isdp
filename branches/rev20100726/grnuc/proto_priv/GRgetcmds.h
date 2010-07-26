#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRgetcmds.C */
extern int GRget_cmds __((char search_string[], long *num_cmds, char *list[]));
extern int GRis_substr __((char search_string[], char full_string[]));

#if defined(__cplusplus)
}
#endif


#undef __
