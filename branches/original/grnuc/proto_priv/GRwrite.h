#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ref/GRwrite.I */
extern int GRget_file_list __((struct GRid *p_grid, int create, OMuword osnum));
extern int GRis_writable __((long *msg, char *file_name, int check, OMuword osnum));
extern int GRmake_writable __((long *msg, char *file_name));
extern int GRmake_read_only __((long *msg, char *file_name));

#if defined(__cplusplus)
}
#endif


#undef __
