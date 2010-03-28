#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/COcppar.I */
extern IGRint COch_cp_parallel __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *const_mod, struct GRevent *events[], IGRboolean apparent, GRobjid *new_object));
extern IGRint COcppdyn __((struct COcppdy *cppinfo, struct EX_button *to_point, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar **out_dummy1, struct GRmdenv_info **dyn_mod_info, IGRchar **out_dummy3));
extern IGRint COcpplcdyn __((struct GRid *dynobj, struct GRevent *locevent, struct COcppdy *cppinfo));

#if defined(__cplusplus)
}
#endif


#undef __
