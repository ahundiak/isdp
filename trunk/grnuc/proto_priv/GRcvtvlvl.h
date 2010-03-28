#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRcvtvlvl.I */
extern IGRlong GRcvt_value_to_value __((IGRlong *msg, IGRchar *table_name, OMuword osnum, IGRchar *alias_to_cvt_from, IGRchar *alias_to_cvt_to, IGRint num_vals, IGRdouble *values_in, IGRdouble *values_out));

#if defined(__cplusplus)
}
#endif


#undef __
