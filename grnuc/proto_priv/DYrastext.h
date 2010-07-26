#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/DYrastext.I */
extern IGRint DYrastext __((struct form_st *form_data, struct EX_button *pnt2, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *inflag1, IGRchar *inflag2, IGRchar *inflag3, IGRint *outflag4, IGRchar **outflag5, IGRchar **outflag6));
extern IGRlong DYrbrastext __((IGRshort *num_entries, IGRshort *offset_array, IGRchar **string_array));

#if defined(__cplusplus)
}
#endif


#undef __
