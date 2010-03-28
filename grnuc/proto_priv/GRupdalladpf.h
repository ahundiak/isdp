#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRupdalladpf.C */
extern IGRint GRupdate_adp_forms __((IGRlong *msg, IGRint param_type, IGRchar *param_value));

#if defined(__cplusplus)
}
#endif


#undef __
