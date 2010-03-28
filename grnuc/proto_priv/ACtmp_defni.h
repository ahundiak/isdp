#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACtmp_defni.I */
extern int ACinit_symbol __((void));
extern int ACload_symbol __((OM_S_OBJID osid, GRspacenum osnum));
extern int ACalloc_symbol __((void));
extern int ACfree_symbol __((void));
extern int ACret_in_symbol __((struct GRid symb_def, struct GRid *real_def, int used));
extern int ACret_in_real __((struct GRid real_def, struct GRid *symb_def, int used));
extern int ACclear_symbol __((int *nb_symb));
extern int ACadd_in_symbol __((struct GRid symb_def, struct GRid real_def, int used));

#if defined(__cplusplus)
}
#endif


#undef __
