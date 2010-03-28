#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/poly/DYnspoly.C */
extern IGRint DYrbnpolygon __((struct GRevent *Events[], struct IGRdisplay *Display));
extern IGRint DYnpolygon __((struct DYnpolygon_params *DYinfo, struct EX_button *point, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *dummy_in1, IGRchar *dummy_in2, IGRchar *dummy_in3, IGRchar **dummy_out1, IGRchar **dummy_out2, IGRchar **dummy_out3));

#if defined(__cplusplus)
}
#endif


#undef __
