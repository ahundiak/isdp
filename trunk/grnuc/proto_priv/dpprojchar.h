#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpprojchar.C */
extern int DPprojchar __((IGRlong *msg, struct IGRlbsys *lbsys, struct IGResintx *txt_ele, struct DPfnt_os_tbl *os_tbl_ptr, IGRdouble *point, IGRint *which_char));

#if defined(__cplusplus)
}
#endif


#undef __
