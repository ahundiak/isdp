#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/COisunitsl.I */
extern IGRlong GRis_unit_scalable __((IGRlong *msg, IGRchar *unit_type, OMuword osnum, IGRboolean *scale_flag));

#if defined(__cplusplus)
}
#endif


#undef __
