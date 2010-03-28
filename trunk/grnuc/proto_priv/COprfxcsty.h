#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/forms/COprfxcsty.C */
extern IGRlong COprefix_to_cs_type __((IGRlong *ReturnMsg, IGRchar *Prefix, IGRlong CStypeSize, IGRchar *CStype));

#if defined(__cplusplus)
}
#endif


#undef __
