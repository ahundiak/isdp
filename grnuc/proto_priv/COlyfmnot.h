#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/COlyfmnot.I */
extern int comp_names __((struct GRlayer *ptr1, struct GRlayer *ptr2));
extern int comp_mask __((struct GRlayer *ptr1, struct GRlayer *ptr2));

#if defined(__cplusplus)
}
#endif


#undef __
