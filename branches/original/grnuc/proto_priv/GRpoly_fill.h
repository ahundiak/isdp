#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GRpoly_fill.C */
extern IGRboolean GRpoly_fill __((IGRlong *msg, IGRboolean *fill_bit, IGRchar *ele_buf));

#if defined(__cplusplus)
}
#endif


#undef __
