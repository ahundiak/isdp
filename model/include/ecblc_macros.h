# ifndef ecb1macros_include
# define ecb1macros_include




IGRint ECblend_curves_api __((IGRlong                 *EMmsg,
                              struct GRlc_info        *curve1,
                              struct GRlc_info        *curve2,
                              IGRdouble               tangent_par1,
                              IGRdouble               tangent_par2,
                              IGRint                  direction1,
                              IGRint                  direction2,
                              IGRint                  curvature1,
                              IGRint                  curvature2,
                              IGRdouble               blend_start_par1,
                              IGRdouble               blend_start_par2,
                              struct GRlc_info        *int_blend_point1,
                              struct GRlc_info        *int_blend_point2,
                              IGRshort                blend_order,
                              struct GRvg_construct   *construct_list,
                              GRspacenum              *result_os,
                              GRobjid                 *result_id));




# omdef ec$blend_curves (msg = NULL,
                         curve1,
                         curve2,
		         tangent_par1 = NULL,
                         tangent_par2 = NULL,
                         direction1 = 1,
			 direction2 = 1,
                         curvature1 = 1,
                         curvature2 = 1,
                         blend_start_par1,
                         blend_start_par2,
                         int_blend_point1,
                         int_blend_point2,
                         blend_order = NULL,
                         construct_list = NULL,
                         blend_os = NULL,
                         blend_id = NULL)

ECblend_curves_api ((msg),
                    (curve1), (curve2),
                    (tangent_par1), (tangent_par2),
                    (direction1), (direction2),
                    (curvature1), (curvature2),
                    (blend_start_par1), (blend_start_par2),
                    (int_blend_point1), (int_blend_point2),
                    (blend_order), (construct_list), (blend_os), (blend_id) )

# endomdef

# endif

