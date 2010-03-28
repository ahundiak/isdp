#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/textco/DYtextdyn.I */
extern IGRint DYtext __((struct DPele_header *elem, struct IGResintx *text_attr, struct IGRlbsys *lbs_geom, IGRshort *font_id, struct GRdpb_text_symb *me_text_symb, struct extents *me_text_extents, IGRshort *me_text_length, IGRuchar **me_text_string, struct IGRdisplay *me_ActiveDisplay, IGRdouble *me_ActiveAngle, IGRint me_viewind));
extern IGRint DYtextdyn __((struct GRdyn_info *info, struct EX_button *pnt, IGRboolean *pnt_flag, IGRuchar *character, IGRint num_bytes, IGRboolean *char_flag, IGRdouble *rot_matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRint *out_flags, struct DPviewind **viewind));
extern IGRint get_num_bytes_delete __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort *font, struct vfont_entry *font_info, IGRshort *prev_font, IGRshort *num_bytes_del));

#if defined(__cplusplus)
}
#endif


#undef __
