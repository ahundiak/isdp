#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/attrib/ACdiowneri.I */
static get_componant_ch __((OM_S_CHANSELECT **componant));
static ACdefault_name __((char *di_name));
extern int ACreturn_diowner __((struct GRid *in, struct GRid *out));

#if defined(__cplusplus)
}
#endif


#undef __
