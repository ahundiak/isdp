#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRnamereffi.I */
extern int GRsort_dir_names __((IGRchar **ptr1, IGRchar **ptr2));
extern IGRint GRname_reffile __((IGRlong *msg, IGRchar *name, IGRchar *filename, struct GRid *ref_id, IGRboolean *constr_flag, IGRchar *logical));

#if defined(__cplusplus)
}
#endif


#undef __
