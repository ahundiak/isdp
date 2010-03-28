#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/ln/DYangbs3pt.C */
extern IGRint DYangbis3pt __((struct DPele_header *header, struct EX_button *cursor_pt, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern IGRint DYrbangbis3pt __((struct GRevent *Events[], struct IGRdisplay *BisectorDisplay));

#if defined(__cplusplus)
}
#endif


#undef __
