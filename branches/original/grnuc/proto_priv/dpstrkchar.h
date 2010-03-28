#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpstrkchar.C */
extern int DPstrkchar __((IGRlong *msg, IGRshort *vec_resolution, IGRchar *strk_ptr, IGRdouble *buffer, struct f_facts *fun_facts, IGRdouble *fnt_to_screen, IGRlong *abc_width, IGRlong *num_pnts));

#if defined(__cplusplus)
}
#endif


#undef __
