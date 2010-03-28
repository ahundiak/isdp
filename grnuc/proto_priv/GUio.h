#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUio.C */
extern IGRboolean GUget_next_ele __((IGRlong *msg, struct GUcvt_bufs *cvt_bufs));
extern IGRlong GUwrite_element __((IGRlong *msg, IGRchar *dgn_buf, IGRchar *ele_buf, IGRint *ele_type, IGRint *ele_size, IGRint *file_des, IGRshort *write_mode, IGRint *block_ptr, IGRint *byte_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
