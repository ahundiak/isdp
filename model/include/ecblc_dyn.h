#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern IGRint Create_bar_dynamics_buffer __(
                    (IGRboolean init_mode,
                     IGRint task,
                     struct  GRid *blend_curve,
                     struct GRmd_env *env1,
                     struct GRid cv1_GRid,
                     IGRint cont1,
                     IGRint tangent_flag1,
                     IGRdouble *ratio1,
                     IGRdouble *par_cv1,
                     IGRint  *dir_cv1,
                     IGRboolean int_cv1,
                     IGRdouble sensi_fakt1,
                     struct GRmd_env *env2,
		     struct GRid cv2_GRid,
                     IGRint cont2,
                     IGRint tangent_flag2,
                     IGRdouble *ratio2,
                     IGRdouble *par_cv2,
                     IGRint *dir_cv2,
                     IGRboolean int_cv2,
                     IGRdouble sensi_fakt2,
                     IGRboolean diagnos,
                     IGRshort  blnd_order,
                     IGRdouble *rot_mat[9],
                     IGRdouble *disp_fakt     ));

#if defined(__cplusplus)
}
#endif


#undef __

