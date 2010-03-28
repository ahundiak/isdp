#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRdumpinvtab.I */
extern void GRdumpinvtab __((void));

#if defined(__cplusplus)
}
#endif


#undef __
