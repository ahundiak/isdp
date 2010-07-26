#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/com/cistore.C */
extern int store_parsed __((char *file_name, char *tag, struct instance_ci *code, char *data_seg_addr, short *text_seg_addr, int extnum, char *errmess));
extern int CIreadhdr __((FILE *input, char *vnum, char *tag, int *nbext, long *msg));
extern int recall_parsed __((char *file_name, char *tag, struct instance_ci **p_code, int *extnum, long *msg));

#if defined(__cplusplus)
}
#endif


#undef __
