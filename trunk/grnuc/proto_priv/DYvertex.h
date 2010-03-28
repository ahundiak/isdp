#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/mod/DYvertex.C */
extern IGRint DYvertex __((struct DPele_header *header, struct EX_button *cursor_pt, struct GRid **objects, IGRdouble *matrix, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern IGRint DYrbvertex __((IGRboolean *closure, IGRdouble *end_pt1, IGRdouble *end_pt2, struct IGRdisplay *display1, struct IGRdisplay *display2));

#if defined(__cplusplus)
}
#endif


#undef __
