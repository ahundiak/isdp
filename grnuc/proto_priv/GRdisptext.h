#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRdisptext.I */
extern IGRint GRdisptext __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRpoint origin, IGRdouble *rot_matrix, IGRdouble *lbs_matrix, struct IGRdisplay *ActiveDisplay, IGRshort *ActiveLevel, struct GRmd_env *ModuleInfo, struct GRdpb_text_symb *text_symb, IGRushort *properties, IGRdouble *ActiveAngle, enum GRdpmode *mode, GRobjid *win_objid, IGRint flags));

#if defined(__cplusplus)
}
#endif


#undef __
