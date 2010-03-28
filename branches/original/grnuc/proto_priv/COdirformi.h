#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cob/COdirformi.I */
extern int DIfwrite __((DIchar *file_name, DIchar **lines, DIgrid *grids, DIint count));

#if defined(__cplusplus)
}
#endif


#undef __
