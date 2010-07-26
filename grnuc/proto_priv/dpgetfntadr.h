#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpgetfntadr.C */
extern int DPget_fnt_adr __((IGRlong *msg, IGRint in_flags, struct DPfnt_os_tbl *fnt_os_tbl, GRspacenum fnt_os, IGRshort virt_font_no, IGRdouble angle, IGRdouble aspect_ratio, IGRint *font_id, IGRdouble *body_size, IGRdouble *decent, IGRint *flags));

#if defined(__cplusplus)
}
#endif


#undef __
