#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/detailgo/GRdvuphesym.I */
extern int GRdvuphesym __((struct GRhesym *hesym));

#if defined(__cplusplus)
}
#endif


#undef __
