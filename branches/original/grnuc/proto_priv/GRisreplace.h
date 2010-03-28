#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/symbgo/GRisreplace.C */
extern IGRint GRis_symbol_replacable __((GRspacenum osnum, GRobjid objid, OM_p_CHANSELECT chansel));

#if defined(__cplusplus)
}
#endif


#undef __
