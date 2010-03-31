#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern void  EMblend_curves __((IGRlong *msg,
                     struct GRmd_env *env1,
                     struct GRid cv1_GRid,
                     IGRint cont1,
                     IGRint tangent_flag1,
                     IGRdouble *ratio1,
                     IGRdouble par_cv1,
                     IGRint dir_cv1,
                     struct GRmd_env *env2,
		     struct GRid cv2_GRid,
                     IGRint cont2,
                     IGRint tangent_flag2,
                     IGRdouble *ratio2,
                     IGRdouble par_cv2,
                     IGRint dir_cv2,
                     IGRint blend_order,
		     struct GRvg_construct *construct_list,
                     struct GRid *blend_cv));


#if defined(__cplusplus)
}
#endif


#undef __
