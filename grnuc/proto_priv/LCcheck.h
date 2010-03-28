#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCcheck.C */
extern IGRint LCcheck_class __((OMuword classid_to_check));

#if defined(__cplusplus)
}
#endif


#undef __
