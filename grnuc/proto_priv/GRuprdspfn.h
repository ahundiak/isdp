#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRuprdspfn.I */
extern int GRupdate_readout_spec __((IGRlong *msg, IGRchar *table_name, OMuword osnum, IGRboolean update_flag, struct GRIOreadout_spec *readout_spec));

#if defined(__cplusplus)
}
#endif


#undef __
