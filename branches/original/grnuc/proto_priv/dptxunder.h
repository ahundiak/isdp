#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dptxunder.C */
extern int DPtxunder __((IGRlong *msg, struct IGRlbsys *lbsys, struct IGResintx *txt_ele, struct DPfnt_os_tbl *os_tbl_ptr, IGRint which_char, IGRint which_point, IGRint horizontal, IGRdouble *point1, IGRdouble *point2));

#if defined(__cplusplus)
}
#endif


#undef __
