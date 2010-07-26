#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_crdef1.I */
extern int COm_crdef_router __((int form_label, int label, double value, char *form_ptr));
extern int COm_crdef_option __((int form_label, int label, double value, char *form_ptr));
extern int COm_hilite_elem __((struct GRid *obj, int type, enum GRdpmode dp_mode, struct GRmd_env *md_env));
extern int COm_crdef_delete_form __((void));

#if defined(__cplusplus)
}
#endif


#undef __
