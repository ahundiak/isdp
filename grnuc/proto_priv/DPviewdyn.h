#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPviewdyn.I */
extern void DPclear_buf_full __((void));
extern IGRint DPdisplay_frames __((IGRlong *msg, IGRint start_frame, IGRint relative_frame, IGRint number_of_frames, IGRint number_of_cycles, IGRint direction, IGRint erase, IGRdouble zoom_factor, IGRdouble pan_factor, IGRdouble max_rotate_factor, GRobjid gragad_id, GRspacenum gragad_osnum, IGRint (*func_ptr )(), IGRchar *func_parms));
extern IGRint DPdyn_set_up_buf __((IGRlong *msg, IGRint static_frame, IGRint *frame_no, IGRdouble *buffer, IGRint buf_size));
extern IGRint DPend_frame __((IGRlong *msg, IGRint *buffer_size, IGRint *fb_buf_status, IGRint *disp_buf_status, GRobjid frame_id, GRspacenum frame_osnum));
extern IGRint DPget_frame_block __((IGRint size));
extern IGRint DPinq_app_buf_full __((void));
extern IGRint DPinq_buf_ptrs __((IGRdouble ***cur_disp_ptr, IGRdouble **end_disp_ptr, IGRdouble ***cur_app_fb_ptr, IGRdouble **end_app_fb_ptr));
extern IGRint DPinq_dyn_buffers __((IGRdouble ***dyn_buf_ptr, IGRdouble ***end_buf, IGRdouble ***fb_buf));
extern IGRint DPinq_dyn_buf_full __((void));
extern IGRdouble *DPinq_gpipe_fb_buf __((void));
extern IGRint DPload_frame __((IGRlong *msg, IGRint static_frame, IGRint frame_no, IGRdouble *buffer, IGRint buf_size));
extern IGRint DPpack_buffer __((IGRint type, struct IGRdisplay *dis_attr));
extern IGRint DPreset_frames __((IGRlong *msg));
extern IGRint DPstart_frame __((IGRlong *msg, IGRint static_frame, IGRint frame_no, IGRint load_frame, IGRint feedback, IGRdouble *feedback_buf, IGRint feedback_size, IGRdouble apparent_stroke_scale, GRobjid gragad_id, GRspacenum gragad_osnum, GRobjid *frame_id, GRspacenum *frame_osnum));

#if defined(__cplusplus)
}
#endif


#undef __
