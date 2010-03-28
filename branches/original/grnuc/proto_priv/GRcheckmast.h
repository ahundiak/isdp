#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRcheckmast.I */
extern IGRlong GRcheck_master_file __((IGRchar *filename));

#if defined(__cplusplus)
}
#endif


#undef __
