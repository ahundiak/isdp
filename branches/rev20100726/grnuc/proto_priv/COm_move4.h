#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_move4.I */
extern int COm_display_move_line __((char *fp, int num_col, int i, char *root, char *clone, struct ret_struct *Temp_Value, struct GRid *Temp_List));

#if defined(__cplusplus)
}
#endif


#undef __
