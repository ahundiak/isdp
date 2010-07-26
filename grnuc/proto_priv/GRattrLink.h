#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GRattrLink.c */
extern IGRlong GRaddAttrLinkage __((IGRlong *msg, IGRuchar *element, IGRuchar *buffer, IGRint buffersize));
extern IGRlong GRaddStyleLinkage __((IGRlong *msg, IGRuchar style, IGRuchar *ele));

#if defined(__cplusplus)
}
#endif


#undef __
