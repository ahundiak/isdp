#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* src_datum/imp/EFretpln.I */
extern IGRlong EFreturn_reference_plane __((IGRlong *EMmsg, IGRuint options,
        struct GRmd_env *md_env, IGRshort *refpln_mxtyp, IGRmatrix refpln_mx,
        struct GRid *pln_GRid));  

#if defined(__cplusplus)
}
#endif


#undef __
