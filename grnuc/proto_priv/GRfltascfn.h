#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRfltascfn.C */
extern int GRIO_float_to_ascii __((double float_in, struct GRIOreadout_spec *readout_spec, char *ascii_result));

#if defined(__cplusplus)
}
#endif


#undef __
