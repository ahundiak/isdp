#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpdynevent.C */
extern IGRint DPdynevent __((WLuint32 lwin_no, IGRint *state, IGRint *pan_state, IGRint *pan_point));

#if defined(__cplusplus)
}
#endif


#undef __
