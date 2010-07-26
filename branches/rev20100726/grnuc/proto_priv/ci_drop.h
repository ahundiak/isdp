#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro/ci_drop.I */
extern int ACpull_feet __((struct GRid *my_grid, int *nb_obj, struct GRid **feet));
extern int ACfree_feet __((struct GRid *my_grid));
extern int ACpush_feet __((struct GRid *my_grid, int nb_obj, struct GRid *feet));

#if defined(__cplusplus)
}
#endif


#undef __
