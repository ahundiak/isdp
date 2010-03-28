#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GRconvtype.c */
extern int GRconversion_type __((void));
extern int GRset_conversion_type __((int newtype));

#if defined(__cplusplus)
}
#endif


#undef __
