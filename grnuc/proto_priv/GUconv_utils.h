#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUconv_utils.C */
extern void GRconv_short __((char *in, char *out));
extern void GRconv_int __((IGRchar *in, IGRchar *out));
extern void GRconv_dbl __((IGRchar *in, IGRchar *out));
extern void GRswap_double __((char *in, char *out));
extern void GRswap_common_hdr __((char *ele_buf));
extern void GRswap_type1214_ele __((char *ele_ptr));
extern void GRswap_type4_ele __((char *ele_ptr, int ndices, int direc));
extern void GRswap_type1113_ele __((char *ele_ptr, int ndices, int direc));
extern void GRswap_type6_ele __((char *ele_ptr, int ndices, int direc));
extern void GRswap_type717_ele __((char *ele_ptr, long dim));
extern void GRswap_type21_ele __((IGRchar *ele_ptr, IGRshort direc));
extern void GRswap_name_linkage __((IGRchar *ele_buf));
extern void GRswap_poly_linkage __((IGRchar *ele_buf));
extern void GRswap_font_linkage __((IGRchar *ele_buf, IGRshort ndices));
extern void GRswap_type15_ele __((IGRchar *ele_buf, IGRshort dim));
extern void GRswap_type16_ele __((IGRchar *ele_buf, IGRshort dim));
extern void GRswap_type3_ele __((IGRchar *ele_buf, IGRshort ndices));
extern void GRswap_type2_ele __((IGRchar *ele_buf, IGRshort ndices));
extern void GRswap_type24_ele __((IGRchar *ele_buf));
extern void GRswap_type25_ele __((IGRchar *ele_buf, IGRshort direc));
extern void GRswap_type26_ele __((IGRchar *ele_buf, IGRshort direc));
extern void GRswap_type28_ele __((IGRchar *ele_buf, IGRshort direc));
extern void GRswap_type27_ele __((IGRchar *ele_buf));
extern void GRswap_type1819_ele __((char *ele_ptr));
extern void GRswap_type23_ele __((IGRchar *ele_ptr));
extern void GRswap_type1_ele __((IGRchar *ele_ptr));
extern void GRswap_type5lv3_ele __((IGRchar *ele_ptr));
extern void GRswap_type5vl9_ele __((IGRchar *ele_ptr));
extern void GRswap_type5lv4_ele __((char *ele_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
