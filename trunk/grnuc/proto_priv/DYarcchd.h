#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/arc/DYarcchd.I */
extern IGRlong DYrbarcchd __((struct GRevent *Events[], struct IGRdisplay *Display1));
extern IGRlong DYarcchd __((struct DYarctnchd_params *DYinfo, struct EX_button *cursor, IGRdouble *ViewMatrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dum1, IGRchar *in_dum2, IGRchar *in_dum3, IGRchar **out_dum1, IGRchar **out_dum2, IGRchar **out_dum3));

#if defined(__cplusplus)
}
#endif


#undef __
