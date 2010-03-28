#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRecvtwkfn.I */
extern IGRlong GRcvt_exp_to_wrk __((IGRlong *msg, IGRchar *table_name, OMuword osnum, IGRdouble units, IGRchar *alias, IGRdouble *working_units));

#if defined(__cplusplus)
}
#endif


#undef __
