#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/dsgo/GRdsi.I */
extern void _ds_dump __((void));
extern IGRint _ds_do __((IGRlong *msg, IGRlong op, IGRlong type, IGRchar *buffer1, IGRchar *buffer2));
static IGRlong _get_std_ndx __((IGRchar *std, struct ds_standard *stds, IGRlong std_len));
static IGRlong _get_sht_ndx __((struct ds_sheet *sht, struct ds_sheet *shts, IGRlong sht_len));

#if defined(__cplusplus)
}
#endif


#undef __
