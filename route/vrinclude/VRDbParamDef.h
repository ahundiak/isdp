/*************************************************************************


Author	: BD

Creation: 04-Apr-1991

   Definition of the parameters' names and values coming from the database.

Change History

	 Date	    |   name  | modification's description
        ------------+---------+------------------------------------------
	09/21/94	Manyam	entry for application

*************************************************************************/


#ifndef VRDbParamDef_include
#define VRDbParamDef_include


#define	VR_N_COMP_TOPO_IN	"comp_topo"

	/* Piping available values */
	/* ----------------------- */
	enum	VRPpCompTopo	{ VRP_V_UNDEFINED_TOPO,
				  VRP_V_CLOSURE_TOPO,
				  VRP_V_INLINE_TOPO,
				  VRP_V_2_WAYS_TOPO,
				  VRP_V_3_WAYS_TOPO,
				  VRP_V_OLET_TOPO,
				  VRP_V_4_WAYS_TOPO,
				  VRP_V_ECCENTRIC_TOPO,
				  VRP_V_RETURN_TOPO,
				  VRP_V_OFFSET_TOPO,
				  VRP_V_HELIX_TOPO,

						  VRP_V_MAXIMUM_TOPO };

	/* HVAC available values */
	/* ----------------------- */
	enum	VRHvCompTopo	{ VRH_V_UNDEFINED_TOPO,
				  VRH_V_CLOSURE_TOPO,
				  VRH_V_INLINE_TOPO,
				  VRH_V_2_WAYS_TOPO,
				  VRH_V_3_WAYS_TOPO,
				  VRH_V_OLET_TOPO,
				  VRH_V_4_WAYS_TOPO,
				  VRH_V_ECCENTRIC_TOPO,
				  VRH_V_RETURN_TOPO,
				  VRH_V_OFFSET_TOPO,
				  VRH_V_SPLIT_TOPO,
				  VRH_V_BEND_SPLIT_TOPO,
				  VRH_V_Y_BRANCH_TOPO,

						  VRH_V_MAXIMUM_TOPO };

         /* Raceway available values */
         /*--------------------------*/
         enum   VRRwCompTopo    { VRR_V_UNDEFINED_TOPO,
                                  VRR_V_CLOSURE_TOPO,
                                  VRR_V_INLINE_TOPO,
                                  VRR_V_2_WAYS_TOPO,
                                  VRR_V_3_WAYS_TOPO,
                                  VRR_V_OLET_TOPO,
                                  VRR_V_4_WAYS_TOPO,
                                  VRR_V_ECCENTRIC_TOPO,
                                  VRR_V_RETURN_TOPO,
                                  VRR_V_OFFSET_TOPO,
                                  VRR_V_SPLIT_TOPO,
                                  VRR_V_Y_BRANCH_TOPO,

						  VRR_V_MAXIMUM_TOPO };


#define	VR_N_COMP_TYPE_IN	"comp_type"

/* -- START Special types values for ISOGEN -- */

#define	VR_V_DANGLING_TYPE	-1
#define	VR_V_ERROR_TYPE		-2

/* -- END Special types values for ISOGEN -- */

	/* Piping available values */
	/* ----------------------- */
	enum	VRPpCompType	{ VRP_V_PIPE_TYPE,
				  VRP_V_ELBOW_TYPE,
				  VRP_V_BRANCH_TYPE,
				  VRP_V_REDUCER_TYPE,
				  VRP_V_VALVE_TYPE,
				  VRP_V_FLANGE_TYPE,
				  VRP_V_PIPE_END_TYPE,
				  VRP_V_MISCELLANEOUS_TYPE,
				  VRP_V_BOLT_GASKET_TYPE,
				  VRP_V_SPECIALITY_TYPE,
				  VRP_V_INSTRUMENT_TYPE,
				  VRP_V_SUPPORT_TYPE,
				  VRP_V_BEND_TYPE,
				  VRP_V_NOZZLE_TYPE,
				  VRP_V_ECCRED_TYPE,
				  VRP_V_HEL_BEND_TYPE,
				  VRP_V_PENETRATION_TYPE,

						  VRP_V_MAXIMUM_TYPE };



	/* HVAC available values */
	/* ----------------------- */
	enum	VRHvCompType	{ VRH_V_DUCT_TYPE,
				  VRH_V_ELBOW_BEND_TYPE,
				  VRH_V_BRANCH_TYPE,
				  VRH_V_REDUCER_TYPE,
				  VRH_V_OFFSET_TYPE,
				  VRH_V_SIZE_TRANSITION_TYPE,
				  VRH_V_DUCT_END_TYPE,
				  VRH_V_SPLIT_TYPE,
				  VRH_V_ORIENT_TRANSITION_TYPE,
				  VRH_V_MISCELLANEOUS_TYPE,
				  VRH_V_SUPPORT_TYPE,
				  VRH_V_DEVICE_TYPE,

						  VRH_V_MAXIMUM_TYPE };


        /* Raceway available values */
        /*--------------------------*/
        enum   VRRwCompType     { VRR_V_TRAY_TYPE,
                                  VRR_V_ELBOW_TYPE,
                                  VRR_V_BRANCH_TYPE,
                                  VRR_V_REDUCER_TYPE,
                                  VRR_V_WYE_TYPE,
                                  VRR_V_CROSS_TYPE,
                                  VRR_V_MISCELLANEOUS_TYPE,
                                  VRR_V_SUPPORT_TYPE,

						  VRR_V_MAXIMUM_TYPE };

/*--------------
*  KDD July 1997. PID equipment need those attributes.
*
*  DBtable_name points to the home table of the PID equipment.
*  diag_eqp_number is the "eqp_number" attribute of DBtable_name.
*		This System Attribute Conflicts with VDS eqp_number User attrib.
--------------*/ 
#define VR_N_TABLE_NAME_DB      "DBtable_name"
#define VR_N_PID_EQP_NUMBER     "diag_eqp_number"

#define VR_N_GASK_SEP_DB        "gask_sep"
#define VR_N_MACRO_NAME_AN      "macro_name"
#define VR_N_CATAL_NAME_AN      "catalog_name"
#define VR_N_SHORT_CODE_AN      "short_code"
#define VR_N_MAX_TEMP_DB        "max_temp"
#define VR_N_PREP_G_IN          "prep_g"
#define VR_N_PREP_R_IN          "prep_r"
#define VR_N_PREPS_G_IN         "preps_g"
#define VR_N_RATING_G_DB        "rating_g"
#define VR_N_RATINGS_G_DB       "ratings_g"
#define VR_N_RATING_R_DB        "rating_r"
#define VR_N_SCH_THK_G_AN       "sch_thk_g"
#define VR_N_SCH_THK_R_AN       "sch_thk_r"
#define VR_N_GEOM_STD_IN        "geom_std"
#define VR_N_END_STD_G_IN       "end_std_g"
#define VR_N_END_STD_R_IN       "end_std_r"


#define VR_N_MODIFIER_DB        "modifier"   /* Note: These parameter names */
#define VR_N_MATERIAL_IN        "material"   /*       match exactly with the*/
#define VR_N_COMMODITY_AN       "commodity"  /*       column names in the   */
#define VR_N_FABCAT_IN          "fabcat"     /*       database.Hence any    */
#define VR_N_WT_FCTR_IN         "wt_fctr"    /*       changes to database   */
#define VR_N_NOTE_A_IN          "note_a"     /*       should be repeated in */
#define VR_N_NOTE_B_IN          "note_b"     /*       these defines.        */


#define VR_N_COMP_RPTCAT_IN     "comp_rptcat"
#define VR_N_COMP_NUMCP_IN      "comp_numcp"
#define VR_N_COMP_2ND_CP_IN     "comp_2nd_cp"
#define VR_N_PDM_PART_NUM_AN    "pdm_part_num"
#define VR_N_THK_G_DB           "thk_g"
#define VR_N_THK_R_DB           "thk_r"
#define VR_N_BR_DB              "br"
#define VR_N_NM_IN              "nm"
#define VR_N_OPER_WT_DB         "oper_wt"
#define VR_N_WET_WT_DB          "wet_wt"
#define VR_N_DRY_WT_DB          "dry_wt"
#define VR_N_F1_DB              "f1"
#define VR_N_F2_DB              "f2"
#define VR_N_F3_DB              "f3"
#define VR_N_F4_DB              "f4"
#define VR_N_F5_DB              "f5"


#define VR_N_PAR_1_DB           "par_1" /* These are for race way application*/
#define VR_N_PAR_2_DB           "par_2" /* only.                             */
#define VR_N_PAR_3_DB           "par_3"

/*****  Equipment 3D ***************/
#define	VR_N_PARTNO_AN		"partno"
#define	VR_N_PART_REV_AN	"part_rev"

/*	Nozzle			*/

#define	VR_N_APPLICATION_AN	"application"

#endif
