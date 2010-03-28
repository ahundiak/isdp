#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/symbco/DYsddyn.I */
extern IGRint DYsdinit __((IGRlong *msg, IGRdouble scale[3 ], IGRdouble *angle, struct GRactive_symbol_def *act_symbol_def));
extern IGRint DYsddyn_fun __((struct DYsddyn_info *info, struct EX_button *pnt2, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));

#if defined(__cplusplus)
}
#endif


#undef __
