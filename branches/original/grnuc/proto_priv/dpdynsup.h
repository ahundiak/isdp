#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpdynsup.I */
extern IGRint DPdyn_ret_index __((IGRint x, IGRint y, WLuint32 lwin_no, IGRint num_windows,
                                  struct DP_information *dp_info, struct DPgad_in_win *win_info,
                                  IGRint *index, GRobjid *win_id));
extern void DPclean_up_dyn __((struct DP_information *dp_info, IGRint index, IGRint win_no, IGRint num_gra_gad,
                               IGRboolean all_windows));
extern void DPdisp_dyn __((IGRint num_of_screens, IGRint num_phy_screens,
                           IGRboolean dynamics_all_windows,
                           IGRint actual_cursor, IGRint win_no, struct GRid *objects, struct DPele_header *buffers,
                           struct GRmdenv_info *mod_info, IGRint out_flags, struct DP_information *dp_info,
                           IGRint num_gra_gad, IGRint num_objects, IGRint num_buffers,
                           struct DPviewind *viewind, IGRint no_cursor, IGRint num_windows, IGRint *win, IGRint index,
                           struct EX_button *uor_point, IGRdouble *mat, IGRint *dit_point, IGRboolean erase_flag));

extern void DPset_text_dyn __((IGRint mode));

#if defined(__cplusplus)
}
#endif


#undef __
