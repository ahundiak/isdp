#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGEcolor/IGEmatch_col.c */
#ifdef RUN_X
extern int IGEclosest_match_colors __((XColor *vlt, int myflag));
extern int IGEget_intergraph_color_slots __((int slots[15 ]));
#endif

#if defined(__cplusplus)
}
#endif


#undef __
