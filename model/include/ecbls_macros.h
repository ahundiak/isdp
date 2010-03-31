# ifndef ecbls_macros_include
# define ecbls_macros_include




IGRint ECblend_surfaces_api __((IGRlong                *EMmsg,
                                struct GRlc_info       *surface1,
                                struct GRlc_info       *curve1,
                                struct GRlc_info       *p_point1s,
                                struct GRlc_info       *p_point1e,
                                IGRint                 cv_flag1,
                                IGRint                 cont1,
                                IGRint                 approx_flag1,
                                IGRdouble              approx_fact1,
                                IGRint                 tangent_flag1,
                                IGRdouble              *ratio1,
                                IGRdouble              par_iso1,
                                IGRdouble              par_cv1[2],
                                IGRint                 dir_flag1,
                                IGRvector              dir_vec1[2],
                                struct GRlc_info       *surface2,
                                struct GRlc_info       *curve2,
                                struct GRlc_info       *p_point2s,
                                struct GRlc_info       *p_point2e,
                                IGRint                 cv_flag2,
                                IGRint                 cont2,
                                IGRint                 approx_flag2,
                                IGRdouble              approx_fact2,
                                IGRint                 tangent_flag2,
                                IGRdouble              *ratio2,
                                IGRdouble              par_iso2,
                                IGRdouble              par_cv2[2],
                                IGRint                 dir_flag2,
                                IGRvector              dir_vec2[2],
                                IGRshort               blend_order,
                                struct GRvg_construct  *construct_list,
                                GRspacenum             *result_os,
                                GRobjid                *result_id));




# omdef ec$blend_surfaces (msg = NULL,
                           surface1,
                           curve1,
                           p_point1s,
                           p_point1e,
                           cv_flag1,
                           cont1,
                           approx_flag1,
                           approx_fact1,
                           tangent_flag1,
                           ratio1,
                           par_iso1,
                           par_cv1,
                           dir_flag1,
                           dir_vec1,
                           surface2,
                           curve2,
                           p_point2s,
                           p_point2e,
                           cv_flag2,
                           cont2,
                           approx_flag2,
                           approx_fact2,
                           tangent_flag2,
                           ratio2,
                           par_iso2,
                           par_cv2,
                           dir_flag2,
                           dir_vec2,
                           blend_order = NULL,
                           construct_list = NULL,
                           blend_os = NULL,
                           blend_id = NULL)

ECblend_surfaces_api ((msg),
                      (surface1), (curve1), (p_point1s), (p_point1e),
                      (cv_flag1), (cont1), (approx_flag1), (approx_fact1),
                      (tangent_flag1), (ratio1), (par_iso1),
                      (par_cv1), (dir_flag1), (dir_vec1),
                      (surface2), (curve2), (p_point2s), (p_point2e),
                      (cv_flag2), (cont2), (approx_flag2), (approx_fact2),
                      (tangent_flag2), (ratio2), (par_iso2),
                      (par_cv2), (dir_flag2), (dir_vec2),
                      (blend_order),
                      (construct_list), (blend_os), (blend_id) ) 

# endomdef


# endif

