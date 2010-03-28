#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUprocsymbol.I */
extern IGRlong GUprocess_symbol __((IGRlong *msg, struct GRmd_env *env, IGRchar *dgn_buf, IGRchar *bs_buf, IGRchar *ele_buf, IGRint *ele_size, IGRint *file_des, IGRdouble *max_overflow, struct GRid *symbol, IGRboolean *flag));

#if defined(__cplusplus)
}
#endif


#undef __
