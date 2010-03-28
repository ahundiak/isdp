#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/cipath.C */
extern int CIgetname __((char *filename, char *expanded_name));
extern int CIfind_path __((char *src_file));
extern int ends_with_dot_u __((char *filename));
extern int ends_with_dot_e __((char *filename));
extern int CIaccess __((char *filename));
extern int is_more_recent __((char *f1, char *f2));
extern int give_path __((char *src_file));

#if defined(__cplusplus)
}
#endif


#undef __
