#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/dir_macro.I */
extern int ACpath_to_file __((char *path_name, char *file_name));
extern int ACos_to_path __((GRspacenum osnum, char *path_name));
extern int AClib_name __((int osnum, int name_size, char *name, int *name_len));
extern int AClib_dir __((char *name, struct GRid *dir));
extern int ACopen_init __((void));
extern int ACopen_store __((GRspacenum osnum, IGRchar *name, int *open_index));
extern int ACconstruct_path __((int mode, char *name, char *path, int path_size, int *path_len));
extern int ACconstruct_wd __((int mode, char *name, struct GRid *const_grid, int name_size, int *name_len));
extern int ACtran_or_make __((GRspacenum cur_os, char *dir_name, struct GRid *dir_grid));
extern int ACactivate __((char *file_name, struct GRid *construct, IGRint req_mode, IGRint *open_index, IGRint *open_mode));
extern int ACconstruct_save __((char *name));

#if defined(__cplusplus)
}
#endif


#undef __
