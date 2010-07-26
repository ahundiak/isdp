#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRicvtalfn.I */
extern IGRlong GRcvt_imp_to_alias __((IGRlong *msg, IGRchar *table_name, OMuword osnum, IGRdouble *working_units, IGRshort *num_alias, IGRshort num_conversions, struct GRIOreadout_spec *readout_spec, IGRshort *field_size, IGRshort inverse_scale_flag, IGRshort *fraction_mode, IGRchar *cvt_list[]));

#if defined(__cplusplus)
}
#endif


#undef __
