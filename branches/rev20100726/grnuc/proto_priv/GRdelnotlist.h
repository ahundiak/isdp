#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/GRdelnotlist.I */
extern IGRint GRdel_obj_not_listed __((IGRlong *msg, struct GRid *current_obj, struct GRfunction_info *usr_info));

#if defined(__cplusplus)
}
#endif


#undef __
