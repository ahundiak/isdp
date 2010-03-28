#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/poly/DYtriangle.C */
extern IGRlong DYtriangle __((struct DPele_header *header, struct EX_button *cursor, struct GRid **objects, IGRdouble *matrix, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern IGRlong DYrbtriangle __((struct GRevent *events[], struct IGRdisplay *display));

#if defined(__cplusplus)
}
#endif


#undef __
