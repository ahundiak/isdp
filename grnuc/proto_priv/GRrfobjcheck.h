#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRrfobjcheck.C */
extern IGRint GRref_obj_check __((IGRlong *msg, struct GRid *ref_obj, IGRdouble *context_matrix, struct ref_objects *obj_list));

#if defined(__cplusplus)
}
#endif


#undef __
