#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/CObuildev.C */
extern IGRlong CObuild_event __((IGRlong *msg, IGRlong event_response, IGRint event_nbytes, struct EX_button *button, IGRchar *keyin, IGRdouble *value, IGRint subtype, IGRshort num_id, IGRshort num_val, IGRdouble values_1, IGRdouble values_2, struct GRlc_info *located_object_1, struct GRlc_info *located_object_2, struct GRevent *event));

#if defined(__cplusplus)
}
#endif


#undef __
