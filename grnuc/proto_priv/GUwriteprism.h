#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GUwriteprism.C */
extern int GUwrite_prism __((struct IGRcv_prism *prism, IGRshort *level, IGRint *file_des));

#if defined(__cplusplus)
}
#endif


#undef __
