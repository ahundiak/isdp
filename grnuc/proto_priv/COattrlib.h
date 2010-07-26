#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/attrco/COattrlib.I */
extern IGRint COattr_get_style __((IGRchar *string, IGRuchar *style));
extern IGRint COattr_get_just __((IGRchar *string, IGRshort *just, IGRshort op));
extern IGRint COattr_get_font __((IGRlong *ok, IGRuchar *name, IGRshort *num, IGRint op));

#if defined(__cplusplus)
}
#endif


#undef __
