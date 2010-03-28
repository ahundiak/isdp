#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/dpbco/COdpblib.I */
extern IGRint COdpb_get_style __((IGRchar *string, IGRuchar *style, IGRint op));
extern IGRint COdpb_get_just __((IGRchar *string, IGRshort *just, IGRshort op));
extern IGRint COdpb_get_font __((IGRchar *name, IGRshort *num, IGRlong type, IGRint op));

#if defined(__cplusplus)
}
#endif


#undef __
