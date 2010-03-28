#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUonamedvws.C */
extern IGRint GUonamedvws __((IGRlong *msg, IGRlong *file_des, IGRchar *dgn_buf, IGRchar *ele_buf, struct GRmd_env *mod_info, IGRdouble *scale_factor));

#if defined(__cplusplus)
}
#endif


#undef __
