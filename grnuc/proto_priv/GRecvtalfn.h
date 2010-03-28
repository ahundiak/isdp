#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRecvtalfn.I */
extern IGRlong GRcvt_exp_to_alias __((IGRlong *msg, IGRchar *table_name, OMuword osnum, IGRshort *num_def, GRIOalias_name *output_alias[], IGRdouble *working_units, struct GRIOreadout_spec *readout_spec, IGRshort *field_size, IGRshort inverse_scale_flag, IGRshort *fraction_mode, IGRchar *cvt_string));

#if defined(__cplusplus)
}
#endif


#undef __
