#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRicvtwkfn.I */
extern IGRlong GRcvt_imp_to_wrk __((IGRlong *msg, IGRchar *table_name, OMuword osnum, IGRdouble primary, IGRdouble second, IGRdouble tertiary, IGRdouble *working_units));

#if defined(__cplusplus)
}
#endif


#undef __
