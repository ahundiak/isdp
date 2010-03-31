#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern IGRint ECblend_sf_d __(
                             (IGRint              bar_control,
                              IGRint              *status,
                              IGRdouble           sensi_fakt1,
                              IGRdouble           sensi_fakt2,
                              IGRint              dyn_bar,
                              IGRint              dyn_iso,
                              IGRint              dyn_vector,
                              IGRint              *response,
                              IGRchar             *response_data,
                              struct EMSblend_sf_end_condition  *start_cond,
                              struct EMSblend_sf_end_condition  *ende_cond,
                              struct HDbd_ext_inf *start_inf,
                              struct HDbd_ext_inf *ende_inf,
                              IGRshort            blend_order,
                              IGRboolean          diagnos,
                              IGRint              *hd_index,
                              IGRdouble           *hd_cur_param,    
                              IGRdouble           *rot_mat[9],
                              IGRdouble           *disp_fakt
                                                                ));

#if defined(__cplusplus)
}
#endif


#undef __


