#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGRdir/src/FIlstformi.I */
extern int DirList_form_input __((int form_label, int gadget_label, double value));
extern int DIfwrite __((char *file_name, char **lines, DIgrid *grids, int count));

#if defined(__cplusplus)
}
#endif


#undef __
