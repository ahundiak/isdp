#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/textco/DYfittextdyn.I */
extern IGRint DYfittext __((struct DPele_header *elem, IGRuchar **me_text_string, struct GRdpb_text_symb *me_text_symb, struct IGRdisplay *me_ActiveDisplay, IGRpoint me_origin, IGRmatrix me_wld_view_mtrx, IGRmatrix me_rot_matrix, IGRint me_viewind));
extern IGRint DYfittextdyn __((struct GRdyn_info *info, struct EX_button *pnt, IGRboolean *pnt_flag, IGRuchar *character, IGRint num_bytes, IGRboolean *char_flag, IGRdouble *rot_matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRint *out_flags, struct DPviewind **viewind));

#if defined(__cplusplus)
}
#endif


#undef __
