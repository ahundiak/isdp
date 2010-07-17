
/* $Id: vc_dbpar.h,v 1.1.1.1 2001/01/04 21:12:09 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        include/vc_dbpar.h
 *
 * Description:
 *
 *      Public Constants defined for VC cabling system database
 *       (all alpha and numeric attribute definitions)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vc_dbpar.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:09  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/01/19  04:01:52  pinnacle
 * Replaced: include/vc_dbpar.h for: CR179701619 by aharihar for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  04:55:32  pinnacle
 * Created: include/vc_dbpar.h by impd for route
 *
 * Revision 1.3  1997/07/28  14:56:58  pinnacle
 * Replaced: include/vc_dbpar.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/07/14  21:04:58  pinnacle
 * Replaced: include/vc_dbpar.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/03/14  16:49:48  pinnacle
 * Created: include/vc_dbpar.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/31/96    hv          Initial
 *      18 Jan 1998 Anand       Added constant for jumper
 *
 *************************************************************************/

#ifndef vc_dbpar_include
#define vc_dbpar_include

/*************************************************************************/
/*    SECTION 1:   DATABASE PARAMETERS                                   */
/*************************************************************************/
/*            general key                                                */
/*************************************************************************/

#define  VC_N_COMP_CODE_AN       "comp_code"

/*************************************************************************/
/*            general cabling parameters (master DB records)             */
/*************************************************************************/

#define  VC_N_SHORT_DESC_AN      "short_desc"
#define  VC_N_OWNER_ID_AN        "owner_id"
#define  VC_N_MACRO_NAME_AN      "macro_name"
#define  VC_N_STANDARD_AN        "standard"
#define  VC_N_DIAMETER_DB        "diameter"
#define  VC_N_BEND_RAD_DB        "bend_rad"
#define  VC_N_ENVIRON_AN         "environment"
#define  VC_N_FIRE_RESIST_AN     "fire_resist"
#define  VC_N_SECURITY_AN        "security"
#define  VC_N_INSUL_TYPE_AN      "insul_type"
#define  VC_N_INSUL_THK_DB       "insul_thk"
#define  VC_N_WEIGHT_DB          "weight"
#define  VC_N_COST_DB            "cost"
#define  VC_N_GN_DATA1_DB        "gn_data1"
#define  VC_N_GN_DATA2_DB        "gn_data2"
#define  VC_N_DESC_AN            "description"
#define  VC_N_VENDOR_AN          "vendor"
#define  VC_N_CATALOG_NUM_AN     "catalog_num"
#define  VC_N_STOCK_NUM_AN       "stock_number"
#define  VC_N_INSERT_BLOCK_AN    "insertion_block"
#define  VC_N_TUBE_SIZE_AN       "tube_size"
#define  VC_N_LUG_SIZE_DB        "lug_size"

/*************************************************************************/
/*                     general lead parameters                           */
/*************************************************************************/

#define  VC_N_LEAD_NBR_DB         "lead_number"
#define  VC_N_CLAD_DIAM_DB        "clad_diam"
#define  VC_N_SECT_CONDUCT_DB     "sect_conduct"
#define  VC_N_MODAL_BW_DB         "modal_bw"
#define  VC_N_LN_SC_FAC_DB        "len_scale_factor"
#define  VC_N_SENSITIVE_DB        "sensitivity"
#define  VC_N_DT_DATA1_DB         "dt_data1"
#define  VC_N_DT_DATA2_DB         "dt_data2"
#define  VC_N_DEF_SIGNAL_AN       "def_signal"

/*************************************************************************/
/*                     electrical lead parameters                        */
/*************************************************************************/

#define  VC_N_CON_MAT_AN          "conductor_material"
#define  VC_N_VOLTAGE_DB          "voltage"
#define  VC_N_CURRENT_DB          "current"
#define  VC_N_RESIST_DB           "resistance"
#define  VC_N_RESIS_MSR_DB        "resis_measure_wl"
#define  VC_N_AMP_60_40_DB        "amp_60_40"
#define  VC_N_AMP_60_50_DB        "amp_60_50"
#define  VC_N_AMP_400_40_DB       "amp_400_40"
#define  VC_N_AMP_400_50_DB       "amp_400_50"

/*************************************************************************/
/*                     fiberoptic lead parameters                        */
/*************************************************************************/

#define  VC_N_NUM_APER_DB          "numeric_aperture"
#define  VC_N_CHROM_DISP_DB        "chrom_disp_slope"
#define  VC_N_ZERO_DISP_DB         "zero_disp_slope"
#define  VC_N_ATTENUATION_DB       "attenuation"
#define  VC_N_ATT_MEAS_WL_DB       "atten_measure_wl"
#define  VC_N_LMT_PH_SP_ATT_DB     "lmt_ph_space_att"
#define  VC_N_HO_MOD_LOSS_DB       "h_order_mod_loss"

/*************************************************************************/
/*                     Electrical terminal parameters                    */
/*************************************************************************/

#define  VC_N_MAX_CONNECT_DB       "max_connect"
#define  VC_N_WORK_VOLT_DB         "work_volt"
#define  VC_N_PEAK_VOLT_DB         "peak_volt"
#define  VC_N_VOLT_DB              "volt"
#define  VC_N_VOLT_DROP_DB         "volt_drop"
#define  VC_N_FREQUENCY_DB         "frequency"
#define  VC_N_RISE_TIME_DB         "rise_time"
#define  VC_N_PRECISION_DB         "precision"

/*************************************************************************/
/*                     Fiberoptic terminal parameters                    */
/*************************************************************************/

#define  VC_N_BANDWIDTH_DB         "bandwidth"
#define  VC_N_SPECTRAL_W_DB        "spectral_w"
#define  VC_N_LAMBDA_C_DB          "lambda_c"
#define  VC_N_ANG_DIST_DB          "ang_distrib"
#define  VC_N_PWR_MEAN_DB          "power_mean"
#define  VC_N_PWR_MAX_DB           "power_max"
#define  VC_N_PWR_STD_DEV_DB       "power_std_dev"
#define  VC_N_SEN_STD_DEV_DB       "sensi_std_dev"

/*************************************************************************/
/*                     general control parameters                        */
/*************************************************************************/

#define  VC_N_V_MOD_CODE_AN        "mod_code"    /* links group to module   */
#define  VC_N_V_MOD_NAME_AN        "mod_name"    /* indexes modules         */
#define  VC_N_V_POS_NM1_AN         "pos_name1"   /* indexes positions       */
#define  VC_N_V_IOTYPE1_DB         "iotype1"
#define  VC_N_V_POS_NM2_AN         "pos_name2"   /* indexes positions       */
#define  VC_N_V_IOTYPE2_DB         "iotype2"
#define  VC_N_V_CONNECTYPE_DB      "connectype"  /* connector/splice switch */

#define  VC_N_CON_MATCH_AN         "con_matchcode"
#define  VC_N_CON_SPL_DEF_AN       "con_spl_def"    /* FIBEROPTIC */
#define  VC_N_CNTYPE_AN            "cntype"         /* FIBEROPTIC */
 
/*************************************************************************/
/*                     parameters calculated from DB contents            */
/*************************************************************************/

#define  VC_N_NUM_PINS_IN          "number_pins"   /* CABLING */
#define  VC_N_NUM_CONDUCT_IN       "number_conduct"/* CABLING */
#define  VC_N_NO_POS_MOD_IN        "pos_per_module"
#define  VC_N_NO_ENT_MOD_IN        "ent_per_module"

/*************************************************************************/
/*                     Jumper parameter                                  */
/*************************************************************************/

//added by alwin for jumpers
#define  VC_N_JUMP_MAX_POSITION_AN         "max_position"

#endif
