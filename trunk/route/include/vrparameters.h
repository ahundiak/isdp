/* $Id: vrparameters.h,v 1.2 2001/01/11 20:00:31 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        include/vrparameters.h
 *
 * Description:
 *
 *
 * This file contains all needed predefined values that can be given as 
 * arguments of I/ROUTE programing macros.
 *
 * The defined name of the parameters describes the fact that they define names
 * (i.e. "_N_"), a short name for the parameter (i.e. "_CLASS_") and the 
 * type of parameter 
 *               (i.e. 	"_AN" for alpha numeric, 
 * 					   	"_DB" for double or 
 *					 	"_IN" for integer ). 
 * 
 * The type is important for filling any parameter description structure 
 * (ACrg_coll) : for "_AN" parameters, AC_ATTRIB_TEXT should be put in the 
 * "type" field and AC_ATTRIB_DOUBLE for all "_DB" or "_IN" parameters.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vrparameters.h,v $
 *      Revision 1.2  2001/01/11 20:00:31  anand
 *      sp merge
 *
 * Revision 1.2  2000/07/13  23:00:32  pinnacle
 * Replaced: route/include/vrparameters.h for:  by apazhani for Service Pack
 *
 * Revision 1.1  2000/05/11  22:10:04  pinnacle
 * Created: route/include/vrparameters.h by apazhani for Service Pack
 *
 * 
 * History:
 *		Author		Date	Description  		
 *      Bruno 		18-Jul-92	Creation
 *	LAW		25-Jul-1998	Added tiers for raceway - CR179801144
 *	Alwin		10-May-2000	Added Acoustic Insul attributes
 *					CR179901312
 *	Alwin		13-Jul-2000	Added ACST attribute
 *********************************************************************/

#ifndef	vr_parameterdef_include
#define vr_parameterdef_include

	/* --------------------------------------- */
	/* Design Piping and HVAC attributes names */
	/* --------------------------------------- */

						/* R/W permission */
#define VR_N_SEQ_NUMBER_AN	"seq_number"	/*  R  */
#define	VR_N_CLASS_AN		"spec_name"	/*  R  */
#define	VR_N_LINE_ID_AN		"line_id"	/*  R  */
#define VR_N_ZONE_AN		"zone_number"	/* R/W */

#define	VR_N_COMP_CODE_AN	"comp_code"	/*  R  */
#define VR_N_TAG_NUMBER_AN	"tag_number"	/* R/W */
#define VR_N_INSUL_TYPE_AN	"insul_type"	/* R/W */
#define	VR_N_INSUL_THK_DB	"insul_thk"	/* R/W */

/* Above insul_type and insul_thk are for Thermal insulation and
the following two attributes are for Acoustical Insulation purposes. Alwin */
#define VR_N_ACST_INSUL_TYPE_AN	"acst_insul_type"	/* R/W */
#define	VR_N_ACST_INSUL_THK_DB	"acst_insul_thk"	/* R/W */
#define VR_N_ACST_DB		"acst" /* HVAC acoustic user property */

#define VR_N_COMP_NOTE_AN	"comp_note"	/* R/W */
#define VR_N_APPRV_STAT_AN	"apprv_stat"	/* R/W */
#define	VR_N_CONSTR_STAT_AN	"constr_stat"	/* R/W */
#define	VR_N_CHG_REQ_NUM_IN	"chg_no"	/* R/W */

#define VR_N_NB_CONNECT_IN	"nb_cpt"	/*  R  */

#define VR_N_NO_MTO_AN		"no_mto_flag"	/* R/W */
#define	VR_N_FLOW_DIR_IN	"flow_dir"	/*  R  */
#define	VR_N_BEND_ANG_DB	"bend_sweep"	/*  R  */
#define VR_N_ERR_FLAG_AN	"err_cmp_flg"	/*  R  */
#define VR_N_WEIGHT_GRP_IN	"weight_grp"	/*  R  */
#define VR_N_PID_SCALE_DB	"pid_scale"	/*  R  */
#define VR_N_CATAL_OCC_AN	"part_num"	/*  R  */

	/* ------------------------------------- */
	/* Design Piping shared attributes names */
	/* ------------------------------------- */

#define	VR_N_GDIAMETER_DB	"npd_g"		/*  R  */
#define	VR_N_RDIAMETER_DB	"npd_r"		/*  R  */
#define	VR_N_OPTION_IN		"opt_code"	/*  R  */
#define VR_N_FLUID_CODE_AN	"fluid_code"	/**/
#define VR_N_UNIT_AN		"unit_number"	/**/
#define VR_N_THICK_OVER_AN	"sch_thk_ovr"	/**/
#define VR_N_TRACING_CODE_AN	"tracing_code"	/* R/W */
#define VR_N_PAINT_CODE_AN	"paint_code"	/* R/W */
#define	VR_N_OPER_TEMP_DB	"op_temp"	/**/
#define	VR_N_OPER_PRESS_DB	"op_press"	/**/
#define	VR_N_DGN_TEMP_DB	"dgn_temp"	/* R/W */
#define	VR_N_DGN_PRESS_DB	"dgn_press"	/* R/W */
#define	VR_N_SPEC_GRAV_DB	"spec_grav"	/**/
#define	VR_N_PIPE_LNG_DB	"pipe_length"	/**/
#define	VR_N_FLD_WELD_IN	"fld_weld"	/* R/W */


		/* ---------------------------- */
		/* Design Hvac attributes names */
		/* ---------------------------- */


#define	VR_N_SHAPE_IN		"shape_code"
#define	VR_N_WIDTH1_DB		"width_1"
#define	VR_N_DEPTH1_DB		"depth_1"
#define	VR_N_WIDTH2_DB		"width_2"
#define	VR_N_DEPTH2_DB		"depth_2"
#define	VR_N_WIDTH3_DB		"width_3"
#define	VR_N_DEPTH3_DB		"depth_3"
#define	VR_N_WIDTH4_DB		"width_4"
#define	VR_N_DEPTH4_DB		"depth_4"
#define	VR_N_THROAT_DB		"throat_rad"
#define	VR_N_TRANS_L_DB		"trans_len"
#define	VR_N_TRANS_A_DB		"trans_ang"
#define	VR_N_PRESS_CLASS_AN	"press_class"
#define	VR_N_SYST_NAME_AN	"system_name"
#define	VR_N_DUCT_MATERIAL_AN	"duct_matl"
#define	VR_N_DUCT_THICK_DB	"duct_thk"
#define	VR_N_SURF_AREA_DB	"surf_area"
#define	VR_N_LINING_TYPE_AN	"lining_type"
#define	VR_N_LINING_THICK_DB	"lining_thk"
#define	VR_N_ADDIT_WEIGHT_DB	"addnl_wt"
#define	VR_N_SHOCK_GRADE_AN	"shock_grade"
#define	VR_N_MAX_FRICT_DB	"max_frict"
#define	VR_N_MAX_VELOC_DB	"max_veloc"
#define	VR_N_MAX_DEPTH_DB	"max_depth"
#define	VR_N_MIN_VELOC_DB	"min_veloc"
#define	VR_N_CONST_DIM_IN	"const_dim"
#define	VR_N_SIZE_METHOD_AN	"size_method"
#define	VR_N_FLOW_RATE_DB	"flow_rate"
#define	VR_N_VELOC_CALC_DB	"veloc_calc"
#define	VR_N_PRESS_DROP_DB	"press_drop"
#define	VR_N_DUCT_LNG_DB	"duct_length"
#define	VR_N_EQUIV_DIA_DB	"equiv_dia"

#define	VR_N_CP_OFFSET_DB	"cp_offset"

/* Specific supports parameters names */

#define VR_N_SUPP_TYPE_IN	"supp_type"
#define VR_N_DETAIL_NUM_AN	"detail_num"
#define VR_N_SUPP_SIZE_DB	"sup_size"
#define VR_N_WEIGHT_DB		"weight"


/* Specific nozzle parameters names */
#define VR_N_SERVICE_AN         "service"


#define VR_N_CORN_RAD_DB        "corner_radius"


/*  ----------------------------------------- */
/*C      ADDITIONAL ATTRIBUTES ELECTRICAL     */

/*C electrical , cable/terminal level   */

#define	VR_N_CATEGORY_AN	"category"	/* CABLING */
#define	VR_N_GROUP_AN		"grp"		/* CABLING */
#define	VR_N_SURF_TREAT_AN	"surf_treat"	/* CABLING */
#define	VR_N_COMPART_X_AN	"compart_x"	/* CABLING */
#define	VR_N_DECK_X_AN		"deck_x"	/* CABLING */
#define	VR_N_ATT_REF_IN		"att_ref"	/* CABLING */
#define	VR_N_LENGTH_DB		"length"	/* CABLING */
#define	VR_N_CAB_LENGTH_DB	"cable_length"	/* CABLING */
#define	VR_N_BEND_RAD_DB	"bend_rad"	/* CABLING */
#define	VR_N_ENVIRON_AN		"environment"	/* CABLING */
#define	VR_N_FIRE_RESIST_AN	"fire_resist"	/* CABLING */
#define	VR_N_DIAMETER_DB	"diameter"	/* CABLING */
#define	VR_N_NUM_CONDUCT_IN	"number_conduct"/* CABLING */
#define	VR_N_NUM_PINS_IN	"number_pins"   /* CABLING */
#define	VR_N_SHORT_DESC_AN	"short_desc"    /* CABLING */
#define	VR_N_DESC_AN		"descript"      /* CABLING */
#define	VR_N_ALT_DESC_AN	"alt_desc"      /* CABLING */
#define	VR_N_VENDOR_AN		"vendor"        /* CABLING */
#define	VR_N_STANDARD_AN	"standard"      /* CABLING */
#define	VR_N_SECURITY_AN	"security"      /* CABLING */
/* Tiers added for CR179801144 */
#define	VR_N_NUMTIER1_IN	"no_tiers_1"    /* CABLING */
#define	VR_N_NUMTIER2_IN	"no_tiers_2"    /* CABLING */
#define	VR_N_TIERSP1_DB		"tier_sp_1"     /* CABLING */
#define	VR_N_TIERSP2_DB		"tier_sp_2"     /* CABLING */

/*C additional indexed, per conductor/pin                   */

#define	VR_N_ALT_DIRECT_AN	"alt_direct"	/* CABLING */
#define VR_N_SIGNAL_NAME_AN	"signal_name"	/* CABLING */
#define	VR_N_SECT_CONDUCT_DB	"sect_conduct"	/* CABLING */
#define	VR_N_CLAD_DIAM_DB	"clad_diam"	/* CABLING */
#define	VR_N_IOTYPE_DB		"iotype"	/* CABLING */
#define	VR_N_VOLTAGE_DB		"voltage"	/* CABLING */
#define	VR_N_WORK_VOLT_DB	"work_volt"	/* CABLING */
#define	VR_N_PEAK_VOLT_DB	"peak_volt"	/* CABLING */
#define	VR_N_VOLT_DB		"volt"		/* CABLING */
#define	VR_N_VOLT_DROP_DB	"volt_drop"	/* CABLING */  /* ?????  */
#define	VR_N_FREQUENCY_DB	"frequency"	/* CABLING */  /* ?????  */
#define	VR_N_RESIST_DB		"resistance"	/* CABLING */
#define	VR_N_MODAL_BW_DB	"modal_bw"	/* CABLING */
#define	VR_N_SENSITIVE_DB	"sensitiv"	/* CABLING */
#define	VR_N_RISE_TIME_DB	"rise_time"	/* CABLING */
#define	VR_N_MAX_CONNECT_IN	"max_connect"	/* CABLING */
#define	VR_N_INTENSITY_DB	"intensity"	/* CABLING */
#define	VR_N_LN_SC_FAC_DB	"len_sca_fac"	/* CABLING */
#define VR_N_RESIS_MSR_DB       "resis_measure_wl"  /* CABLING */

/*C virtual (linkage and indexing) attributes    */

#define VR_N_V_COND_CODE_AN     "conductor_code"  /* links cable to lead   */
#define VR_N_V_COND_SEQ_AN      "conductor_seq"   /* indexes leads         */
#define VR_N_V_PIN_CODE_AN      "pin_code"        /* links term to pin     */
#define VR_N_V_PIN_SEQ_AN       "pin_seq"         /* indexes pins          */
#define VR_N_V_ELEQ_CODE_AN     "eleq_code"       /* links mxconn to spec    */

/*  ----------------------------------------- */
/*C      ADDITIONAL ATTRIBUTES FIBEROPTIC     */

/*C fiberoptical , cable/terminal level   */

#define	VR_N_NUM_FIBERS_IN	"number_fibers" /* FIBEROPTIC */
#define VR_N_MAX_NO_MODS_IN     "max_no_mods"
#define VR_N_ACT_NO_MODS_IN     "act_no_mods"

/*C additional indexed, per fiber/connector etc                   */

#define	VR_N_CON_MATCH_AN	"con_match" 		/* FIBEROPTIC */
#define	VR_N_SPL_MATCH_AN	"spl_match" 		/* FIBEROPTIC */
#define VR_N_CON_SPL_DEF_AN	"con_spl_def"		/* FIBEROPTIC */
#define VR_N_IO_TYPE_AN         "iotype"                /* FIBEROPTIC */
#define	VR_N_NUM_APER_DB	"numeric_aperture" 	/* FIBEROPTIC */
#define	VR_N_CHROM_DISP_DB	"chrom_disp_slope" 	/* FIBEROPTIC */
#define	VR_N_ZERO_DISP_DB	"zero_disp_slope" 	/* FIBEROPTIC */
#define	VR_N_ATTENUATION_DB	"attenuation" 		/* FIBEROPTIC */
#define	VR_N_ATT_MEAS_WL_DB	"atten_measure_wl" 	/* FIBEROPTIC */
#define	VR_N_LMT_PH_SP_ATT_DB	"lmt_ph_space_att" 	/* FIBEROPTIC */
#define	VR_N_HO_MOD_LOSS_DB	"h_order_mod_loss" 	/* FIBEROPTIC */
#define	VR_N_LEN_SC_FAC_DB	"len_scale_factor" 	/* FIBEROPTIC */

#define	VR_N_BANDWIDTH_DB	"bandwidth" 		/* FIBEROPTIC */
#define	VR_N_SPECTRAL_W_DB	"spectral_w" 		/* FIBEROPTIC */
#define	VR_N_LAMBDA_C_DB	"lambda_c" 		/* FIBEROPTIC */
#define	VR_N_ANG_DIST_DB	"ang_distrib" 		/* FIBEROPTIC */
#define	VR_N_PWR_MEAN_DB	"power_mean" 		/* FIBEROPTIC */
#define	VR_N_PWR_MAX_DB		"power_max" 		/* FIBEROPTIC */
#define	VR_N_PWR_STD_DEV_DB	"power_std_dev" 	/* FIBEROPTIC */
#define	VR_N_SEN_STD_DEV_DB	"sensi_std_dev" 	/* FIBEROPTIC */
#define	VR_N_THRUCONN_AN	"thruconnect" 		/* FIBEROPTIC */

#define VR_N_NO_MTO_MOD_AN	"no_mto"	        /* FIBEROPTIC */
#define VR_N_NO_POS_MOD_DB	"number_pos"	        /* FIBEROPTIC */
#define VR_N_NO_ENT_MOD_DB	"number_ent"	        /* FIBEROPTIC */

/*C virtual (linkage and indexing) attributes    */

#define VR_N_V_FOPTIC_CODE_AN   "foptic_code"     /* links cable to fiber    */
#define VR_N_V_FOPTIC_SEQ_AN    "foptic_seq"      /* indexes fibers          */
#define VR_N_V_FOEQ_CODE_AN     "foeq_code"       /* links mxconn to spec    */
#define VR_N_V_MOD_GROUPCODE_AN "mod_groupcode"   /* links mxconn to group   */
#define VR_N_V_MOD_CODE_AN      "mod_code"        /* links group to module   */
                                                  /*    and module spec      */
#define VR_N_V_MOD_SEQ_AN       "mod_seqno"       /* indexes modules         */
#define VR_N_V_POS_NM1_AN       "pos_name1"       /* indexes positions       */
#define VR_N_V_POS_NM2_AN       "pos_name2"       /* indexes positions       */

/*C Dynamic attributes for connectivity tables     */
/*  also uses tag_number, signal_name and conductor_seq (foptic_sec)   */
/*  name indicate from/to of equivalent attributes                     */

#define VR_N_F_EQP_NUMBER_AN	"f_eqp_number"
#define VR_N_F_TAG_NUMBER_AN	"f_tag_number"
#define VR_N_F_MOD_SEQ_AN	"f_mod_seq"
#define VR_N_F_POS_NAM_AN	"f_pos_nam"

#define VR_N_T_EQP_NUMBER_AN	"t_eqp_number"
#define VR_N_T_TAG_NUMBER_AN	"t_tag_number"
#define VR_N_T_MOD_SEQ_AN	"t_mod_seq"
#define VR_N_T_POS_NAM_AN	"t_pos_nam"

/*---------------------------------------------------------------------------*/
/*                                                                           */
/*    NOTE:   format strings for uniform handling of indexed parameternames  */
/*                                                                           */
/*---------------------------------------------------------------------------*/

#define VR_N_SNG_INDEX_FMT     "%s_%-d"
#define VR_N_DBL_INDEX_FMT     "%s_%-d_%-d"
#define VR_N_TPL_INDEX_FMT     "%s_%-d_%-d_%-d"
#define VR_N_RIS_KEY_FMT       "%s=\'%s\'"
#define VR_N_FIB_INDEX_FMT     "_%-d_"

/*C predrop attributes	*/
#define	VR_N_FRICTION_FACT_DB	"friction_factor" /* friction factor of duct*/
#define	VR_N_LOSS_COEFT_DB	"loss_coefficient" /* fitting loss coeft*/
#define	VR_N_BRANCH_COEFT_DB	"br_coefficient"  /* branch loss coeft*/

#endif
