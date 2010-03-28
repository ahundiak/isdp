#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pop/pop_to_otl.c */
extern int main __((int argc, char **argv));
extern int cleanup __((void));
extern int get_cmd_strg __((struct xref_tbl *cmd_x_key_x_strg, int max_cmd_strgs, char cmd_key[]));
extern int init_xref __((struct xref_tbl *cmd_x_key_x_strg, char *mod_ptr[], int *mod_max, int *msg_cnt));

#if defined(__cplusplus)
}
#endif


#undef __
