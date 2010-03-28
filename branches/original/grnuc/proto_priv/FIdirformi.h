#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGRdir/src/FIdirformi.I */
extern void DIget_dir_form __((Form *Form1));
extern void DIget_form_find_info __((int *max_level, char *start_dir));
extern int DIform_find __((char *start, char ***lines, int *ptr, int max_level, int *deep));
extern int DIfetch_form_find __((char line[DI_PATH_MAX ], int index));
extern int FIdirform_process_form __((int form_label, int gadget_label, double value));

#if defined(__cplusplus)
}
#endif


#undef __
