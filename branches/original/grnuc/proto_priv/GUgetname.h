#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/GUgetname.C */
extern IGRboolean GUgetname __((IGRlong *msg, IGRchar *element, IGRchar *name));

#if defined(__cplusplus)
}
#endif


#undef __
