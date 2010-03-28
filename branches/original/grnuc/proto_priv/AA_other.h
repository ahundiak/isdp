#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/asap_comm/AA_other.C */
extern IGRchar *AA_config_path __((void));

#if defined(__cplusplus)
}
#endif


#undef __
