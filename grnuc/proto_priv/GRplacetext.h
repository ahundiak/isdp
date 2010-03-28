#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRplacetext.I */
extern IGRint GRplace_text __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRpoint origin, IGRdouble *rot_matrix, IGRdouble *lbs_matrix, IGRchar *DatabaseType, IGRchar *classname, struct IGRdisplay *ActiveDisplay, IGRshort ActiveLevel, IGRushort *Properties, struct GRmd_env *ModuleInfo, struct GRdpb_text_symb *TextSymb, IGRdouble ActiveAngle, enum GRdpmode mode, GRobjid win_objid, IGRint flags, struct GRid *buffer));

#if defined(__cplusplus)
}
#endif


#undef __
