#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRgettoken.C */
extern IGRlong GRget_token __((IGRlong *msg, IGRint TokenArray[], IGRint *mask, struct GRevent *event, IGRint *size, IGRint *response, IGRchar *response_data));

#if defined(__cplusplus)
}
#endif


#undef __
