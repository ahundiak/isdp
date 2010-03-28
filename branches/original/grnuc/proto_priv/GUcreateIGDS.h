#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUcreateIGDS.I */
extern IGRlong GUcreate_IGDSfile __((IGRlong *msg, IGRlong *file_name, IGRchar *dbtype, struct GRmd_env *mod_info, GRobjid *command_id, IGRchar seedfile[], struct GRid view_setup[], IGRdouble trans_limits[]));

#if defined(__cplusplus)
}
#endif


#undef __
