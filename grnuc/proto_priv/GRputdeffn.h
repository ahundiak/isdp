#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRputdeffn.I */
extern IGRlong GRput_default_units __((IGRlong *msg, IGRchar *table_name, OMuword osnum, IGRshort *flag, IGRshort *num_defaults, GRIOalias_name *default_units));

#if defined(__cplusplus)
}
#endif


#undef __
