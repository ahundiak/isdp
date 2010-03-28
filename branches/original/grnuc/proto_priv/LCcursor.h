#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCcursor.I */
extern IGRint LCdef_cursor __((void));
extern IGRint LCrestore_cursor __((void));
extern void LCbit_set __((IGRint row, IGRint column, IGRint dim, IGRint *mat));
extern IGRint LCset_c_def __((IGRint c_d[32 ], IGRint c_e[32 ], IGRdouble tolerance, IGRint hs_x, IGRint hs_y));
extern IGRint LCset_window __((IGRint mode, IGRlong *c_e, IGRlong *c_d, IGRlong *hs));

#if defined(__cplusplus)
}
#endif


#undef __
