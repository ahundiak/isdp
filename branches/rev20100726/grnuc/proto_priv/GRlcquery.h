#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/GRlcquery.C */
extern int GRlcquery __((IGRlong *rc, struct GRmd_env *mod, enum GRlocate_types *locate_type, IGRchar *loc_parms, IGRint (*action_handler )(), IGRchar *act_parms, GRlc_classptrs classptr));

#if defined(__cplusplus)
}
#endif


#undef __
