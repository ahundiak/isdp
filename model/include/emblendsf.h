


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern void  EMblendsf __((IGRlong           *msg,
                           struct GRmd_env   *env_sf1,
                           struct GRid       sf1_GRid,
                           struct GRmd_env   *env_cv1,
                           struct GRid       cv1_GRid,
                           IGRint            cv1_flag,
                           IGRint            cont1,
                           IGRint            *approx_mode1,
                           IGRdouble         *approx_fact1,
                           IGRint            new_tangent_flag1[3],
                           IGRdouble         new_ratio1[3],
                           IGRdouble         pariso1,
                           IGRdouble         par_cv1[2],    
                           IGRint            dir1_flag,
                           IGRvector         dir1_vec[2],
                           struct GRmd_env   *env_sf2,
                           struct GRid       sf2_GRid,
                           struct GRmd_env   *env_cv2,
                           struct GRid       cv2_GRid,
                           IGRint            cv2_flag,
                           IGRint            cont2,
                           IGRint            *approx_mode2,
                           IGRdouble         *approx_fact2,
                           IGRint            new_tangent_flag2[3],
                           IGRdouble         new_ratio2[3],
                           IGRdouble         pariso2,
                           IGRdouble         par_cv2[2],
                           IGRint            dir2_flag,
                           IGRvector         dir2_vec[2],
                           IGRshort           blend_order,
                           IGRdouble         tolarr[3],
                           struct GRvg_construct   *construct_list,
                           struct GRid       *blend_srf ));

#if defined(__cplusplus)
}
#endif


#undef __
