#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/symb_mac/ACmodel_mgri.I */
extern IGRlong ACget_model_base_ref __((struct GRid *ref, struct GRmd_env *md_env));
extern int ACSret_values_list __((struct GRid *list_obj, IGRint list_len, struct ACrg_coll *att_list, IGRint *nb_att, struct GRmd_env *mod_env));

#if defined(__cplusplus)
}
#endif


#undef __
