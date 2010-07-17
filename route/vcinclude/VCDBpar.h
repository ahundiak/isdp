
/* $Id: VCDBpar.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCDBpar.h
 *
 * Description:
 *
 *      Constants defined for VC cabling system database
 *       (all alpha and numeric attribute definitions)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBpar.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.7  1997/07/28  14:58:02  pinnacle
 * Replaced: vcinclude/VCDBpar.h for:  by hverstee for cabling
 *
 * Revision 1.6  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.5  1997/03/14  18:16:32  pinnacle
 * Replaced: vcinclude/VCDBpar.h for:  by hverstee for cabling
 *
 * Revision 1.4  1997/01/20  20:09:22  pinnacle
 * Replaced: vcinclude/VCDBpar.h for:  by hverstee for cabling
 *
 * Revision 1.3  1996/10/29  22:04:56  pinnacle
 * Replaced: vcinclude/VCDBpar.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/08/29  22:15:50  pinnacle
 * Replaced: vcinclude/VCDBpar.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:44:28  pinnacle
 * Created: vcinclude/VCDBpar.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/31/96    hv          Initial
 *
 *************************************************************************/

#ifndef VCdbpar_include
#define VCdbpar_include

#define  VC_DB_PARA_LIMIT       100

/*   parameter numbers below limit are considered DB parameters!!!!   */

/*************************************************************************/
/*    SECTION 1:   DATABASE PARAMETERS                                   */
/*************************************************************************/
/*            general key                                                */
/*************************************************************************/

#define  VC_X_COMP_CODE_AN       1

/*************************************************************************/
/*            general cabling parameters (master DB records)             */
/*************************************************************************/

#define  VC_X_SHORT_DESC_AN      2
#define  VC_X_OWNER_ID_AN        3
#define  VC_X_MACRO_NAME_AN      4
#define  VC_X_STANDARD_AN        5
#define  VC_X_DIAMETER_DB        6
#define  VC_X_BEND_RAD_DB        7
#define  VC_X_ENVIRON_AN         8
#define  VC_X_FIRE_RESIST_AN     9
#define  VC_X_SECURITY_AN        10
#define  VC_X_INSUL_TYPE_AN      11
#define  VC_X_INSUL_THK_DB       12
#define  VC_X_WEIGHT_DB          13
#define  VC_X_COST_DB            14
#define  VC_X_GN_DATA1_DB        15
#define  VC_X_GN_DATA2_DB        16
#define  VC_X_DESC_AN            17
#define  VC_X_VENDOR_AN          18
#define  VC_X_CATALOG_NUM_AN     19
#define  VC_X_STOCK_NUM_AN       20
#define  VC_X_INSERT_BLOCK_AN    21

#define  VC_X_TUBE_SIZE_AN                              72
#define  VC_X_LUG_SIZE_DB                               73
 
/*************************************************************************/
/*                     general lead parameters                           */
/*************************************************************************/

#define  VC_X_LEAD_NBR_DB                               70
#define  VC_X_CON_MAT_AN                                78
#define  VC_X_CLAD_DIAM_DB        22
#define  VC_X_SECT_CONDUCT_DB     23
#define  VC_X_MODAL_BW_DB         24
#define  VC_X_LN_SC_FAC_DB        25
#define  VC_X_SENSITIVE_DB        26
#define  VC_X_DT_DATA1_DB         27
#define  VC_X_DT_DATA2_DB         28
#define  VC_X_DEF_SIGNAL_AN                             71

#define  VC_X_AMP_60_40_DB                              74
#define  VC_X_AMP_60_50_DB                              75
#define  VC_X_AMP_400_40_DB                             76
#define  VC_X_AMP_400_50_DB                             77

/*************************************************************************/
/*                     electrical lead parameters                        */
/*************************************************************************/

#define  VC_X_VOLTAGE_DB          29
#define  VC_X_CURRENT_DB          30
#define  VC_X_RESIST_DB           31
#define VC_X_RESIS_MSR_DB         32

/*************************************************************************/
/*                     fiberoptic lead parameters                        */
/*************************************************************************/

#define  VC_X_NUM_APER_DB          33
#define  VC_X_CHROM_DISP_DB        34
#define  VC_X_ZERO_DISP_DB         35
#define  VC_X_ATTENUATION_DB       36
#define  VC_X_ATT_MEAS_WL_DB       37
#define  VC_X_LMT_PH_SP_ATT_DB     38
#define  VC_X_HO_MOD_LOSS_DB       39

/*************************************************************************/
/*                     Electrical terminal parameters                    */
/*************************************************************************/

#define  VC_X_MAX_CONNECT_DB       40
#define  VC_X_WORK_VOLT_DB         41
#define  VC_X_PEAK_VOLT_DB         42
#define  VC_X_VOLT_DB              43
#define  VC_X_VOLT_DROP_DB         44
#define  VC_X_FREQUENCY_DB         45
#define  VC_X_RISE_TIME_DB         46
#define  VC_X_PRECISION_DB         47

/*************************************************************************/
/*                     Fiberoptic terminal parameters                    */
/*************************************************************************/

#define  VC_X_BANDWIDTH_DB         48
#define  VC_X_SPECTRAL_W_DB        49
#define  VC_X_LAMBDA_C_DB          50
#define  VC_X_ANG_DIST_DB          51
#define  VC_X_PWR_MEAN_DB          52
#define  VC_X_PWR_MAX_DB           53
#define  VC_X_PWR_STD_DEV_DB       54
#define  VC_X_SEN_STD_DEV_DB       55

/*************************************************************************/
/*                     general control parameters                        */
/*************************************************************************/

#define  VC_X_V_MOD_CODE_AN        56
#define  VC_X_V_MOD_NAME_AN        57
#define  VC_X_V_POS_NM1_AN         58
#define  VC_X_V_POS_NM2_AN         59
#define  VC_X_V_IOTYPE1_DB         60
#define  VC_X_V_IOTYPE2_DB         61
#define  VC_X_V_CONNECTYPE_DB      62

#define  VC_X_CON_MATCH_AN         63
#define  VC_X_CON_SPL_DEF_AN       64
#define  VC_X_CNTYPE_AN            65

/*************************************************************************/
/*                     parameters calculated from DB contents            */
/*************************************************************************/

#define  VC_X_NUM_PINS_IN          66
#define  VC_X_NUM_CONDUCT_IN       67
#define  VC_X_NO_POS_MOD_IN        68
#define  VC_X_NO_ENT_MOD_IN        69

/*************************************************************************/

#endif
