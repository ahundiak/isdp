#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/getevent/GRgetevent.C */
extern IGRlong GRgetevent __((IGRlong *msg, IGRlong *mask, IGRlong *size, struct GRevent *event, IGRlong *response, IGRchar *response_data));

#if defined(__cplusplus)
}
#endif


#undef __
