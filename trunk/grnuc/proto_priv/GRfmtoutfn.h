#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRfmtoutfn.C */
extern int GRIOformat_readout __((int *rc, struct GRIOreadout_spec *readout_spec, short *num_alias, GRIOalias_name *alias_list[], double *value_list, short *field_size, short *fraction_mode, char *return_string));

#if defined(__cplusplus)
}
#endif


#undef __
