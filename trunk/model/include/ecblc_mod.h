#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern long ECblendcv_m __(
                           (IGRlong                          *msg,
                            struct GRid                      *blend_id, 
                            struct HDbd_form_params          *HDbd_f_p,
                            IGRint                           *response,
                            IGRchar                          *response_data,
                            struct EMSblend_cv_end_condition *b_start_cond,
                            struct EMSblend_cv_end_condition *b_ende_cond,
                            struct ext_pnt_info              *ext_pnt1,
                            struct ext_pnt_info              *ext_pnt2,
                            IGRdouble                        *rot_mat,
                            IGRdouble                        *disp_fakt,
                            OMuint                           *new_tag    
                                                                 ));


#if defined(__cplusplus)
}
#endif


#undef __

