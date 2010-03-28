#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/GUattrlink.C */
extern IGRint GUattr_link __((IGRlong *msg, struct GUcommon_header_info *element, IGRchar *name, IGRshort *symbology, IGRchar *typeface, IGRchar *charmap));
extern IGRint FTConnectToNodes __((struct GRid *objinfo, unsigned short *ivec_info));
extern IGRint GRConnectToNodes __((struct GRid *objinfo));

#if defined(__cplusplus)
}
#endif


#undef __
