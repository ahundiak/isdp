#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUcpxhand.I */
extern int GUcpxinit __((void));
extern IGRboolean GUcpxopen __((IGRlong *msg, IGRchar *dgn_buf, IGRchar *ele_buf, IGRint *ele_size, IGRint *file_des, IGRint *previous_state, IGRint *previous_offset));
extern IGRboolean GUcpxclose __((IGRlong *msg, IGRchar *dgn_buf, IGRchar *ele_buf, IGRint *ele_size, IGRint *file_des));
extern IGRboolean GUcpxwritehdr __((IGRlong *msg, IGRboolean *twrite));
extern IGRboolean GUcpxhandler __((IGRlong *msg, IGRboolean *cpx_calling, struct GRmd_env *md_env, IGRchar *dgn_buf, IGRchar *bs_buf, IGRchar *ele_buf, IGRint *ele_size, IGRint *file_des, IGRdouble *max_overflow, IGRdouble *scale_factor, IGRchar *IGDSclass, IGRushort *properties, IGRushort *level, struct GRid *id, IGRboolean *format, IGRboolean *cpx));
extern IGRboolean GUcpxclose_string __((IGRlong *msg, IGRchar *dgn_buf, IGRchar *ele_buf, IGRint *ele_size, IGRint *file_des, IGRshort *type, IGRint *previous_state, IGRint *previous_offset));

#if defined(__cplusplus)
}
#endif


#undef __
