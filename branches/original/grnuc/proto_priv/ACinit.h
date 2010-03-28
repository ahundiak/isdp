#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACinit.I */
extern int ACinit __((OM_S_OBJID super_id));
extern int ACfind_macro_defn __((int action, OM_S_OBJID caller_id, char *macro_name, OMuword osnum, struct GRid *macro_defn));
extern int ACadd_macro_name __((char *macro_name, OMuword osnum, OM_S_OBJID macro_defn_id));

#if defined(__cplusplus)
}
#endif


#undef __
