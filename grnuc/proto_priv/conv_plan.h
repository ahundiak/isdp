#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_conv/conv_plan.I */
extern IGRint DMconv_gplan __((OM_S_OBJID planmgr_id, OMuword planmgr_os));
extern IGRint DMconv_lplan __((IGRint *msg, struct GRid win_plan, struct GRid act_plan, struct GRmd_env *md_env, struct GRid *window, IGRdouble matrix[16 ], IGRint *count, struct GRid list[2 ], double axis[6 ]));
extern IGRint DMcreate_lplan __((IGRint *msg, struct GRid win_grid, IGRdouble matrix[16 ], IGRint count, struct GRid list[], double axis[6 ], struct GRmd_env *md_env, struct GRid *dim_plan));
extern IGRint DMgive_template_info __((IGRint *msg, struct GRid macro, char temp_name[], struct GRmd_env *md_env, struct GRid *temp_id, struct ret_struct *rstr));
extern IGRint DMgive_feet_info __((IGRint *msg, struct GRid macro, char feet_name[], struct GRmd_env *md_env, struct ret_struct *rstr));
extern IGRint DMget_source_obj __((struct GRid *grid));
extern IGRint DMget_meas_axis __((IGRint *msg, struct GRid act_plan, struct GRmd_env *md_env, IGRint *count, struct GRid *list, double axis[6 ]));

#if defined(__cplusplus)
}
#endif


#undef __
