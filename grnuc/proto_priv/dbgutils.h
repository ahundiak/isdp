#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/dbgutils.I */
extern int print_grid_info __((char *name, struct GRid grid));

#if defined(__cplusplus)
}
#endif


#undef __
