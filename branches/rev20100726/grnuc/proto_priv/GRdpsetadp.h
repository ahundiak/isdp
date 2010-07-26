#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRdpsetadp.C */
extern IGRint GRdisp_set_adp __((void));

#if defined(__cplusplus)
}
#endif


#undef __
