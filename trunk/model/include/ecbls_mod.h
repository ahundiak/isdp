#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern long Blend_modify __(
                           (IGRlong                          *msg,
                            struct GRid                      *blend_id, 
                            struct GRmd_env                  *module_inf,
                            struct HDbd_form_sf_p            *HDbd_f_p,
                            IGRlong                          *response,
                            IGRchar                          *response_data,
                            struct EMSblend_sf_end_condition *b_start_cond,
                            struct EMSblend_sf_end_condition *b_ende_cond,
                            struct HDbd_ext_inf              *b_start_inf,
                            struct HDbd_ext_inf              *b_ende_inf,
                            struct saved_blend               *saved_blend,    
                            struct saved_blend               *pre_saved_blend,
                            IGRdouble                        *rot_mat[9],
                            IGRdouble                        *disp_fakt,
                            IGRlong                          *dyn_status
                                                             )               );


#if defined(__cplusplus)
}
#endif


#undef __

