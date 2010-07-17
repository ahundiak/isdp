
/* $Id: VCparameters.h,v 1.1.1.1 2001/01/04 21:12:35 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCparameters.h
 *
 * Description:
 *
 *      Constants defined for VC cabling system runtime attributes
 *       (all numeric equivalents attribute definitions)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCparameters.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:35  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.10  1997/08/05  22:19:46  pinnacle
 * Replaced: vcinclude/VCparameters.h for:  by hverstee for cabling
 *
 * Revision 1.9  1997/07/21  21:12:10  pinnacle
 * Replaced: vcinclude/VCparameters.h for:  by hverstee for cabling
 *
 * Revision 1.8  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.7  1997/03/19  14:44:40  pinnacle
 * Replaced: vcinclude/VCparameters.h for:  by hverstee for cabling
 *
 * Revision 1.6  1997/03/14  18:16:48  pinnacle
 * Replaced: vcinclude/VCparameters.h for:  by hverstee for cabling
 *
 * Revision 1.5  1997/01/20  20:07:08  pinnacle
 * Replaced: vcinclude/VCparameters.h for:  by hverstee for cabling
 *
 * Revision 1.4  1997/01/17  21:53:44  pinnacle
 * Replaced: vcinclude/VCparameters.h for:  by hverstee for cabling
 *
 * Revision 1.3  1997/01/03  14:08:18  pinnacle
 * Replaced: vcinclude/VCparameters.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/08/29  22:16:12  pinnacle
 * Replaced: vcinclude/VCparameters.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:47:24  pinnacle
 * Created: vcinclude/VCparameters.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/31/96    hv          Initial
 *
 *************************************************************************/

#ifndef	VCparameters_include
#define VCparameters_include

#define  VC_X_INTERNAL_CUTOFF   200
#define  VC_X_SYSTEM_CUTOFF     300

/*   note that all DB parameters are under the "100" cutoff    */
/*   also note that the comp_code as a DB key also is an internal attr.  */

/*************************************************************************/
/*               Internal attributes including                           */
/*               Calculated/indirect attributes                          */
/*************************************************************************/

#define VC_X_TAG_NUMBER_AN	101

#define VC_X_NB_CONNPT_IN       102
#define VC_X_CAB_LENGTH_DB      103
#define VC_X_SIGNAL_NAME_AN     104

#define VC_X_EQP_ID_IN          105
#define VC_X_EQP_NUMBER_AN      106
#define VC_X_REF_CS             107
#define VC_X_LOC_PT             108

#define VC_X_ERR_FLAG_AN	120

#define	VC_X_THRUCONN_AN	130

#define VC_X_TAIL_LENGTH_DB     140
#define VC_X_ESTIM_LENGTH_DB    141

/*************************************************************************/
/*               System collection                                       */
/*************************************************************************/

#define VC_X_PART_NUM_AN	201
#define VC_X_UNIT_AN		202
#define	VC_X_SYST_NAME_AN	203
#define VC_X_APPRV_STAT_AN	204
#define	VC_X_CONSTR_STAT_AN	205
#define	VC_X_CHG_REQ_NUM_AN	206
#define VC_X_COMP_NOTE_AN	207
#define VC_X_NO_MTO_AN		208
#define VC_X_ADD_LABEL_AN	209
#define VC_X_PID_SCALE_DB       210


/*************************************************************************/
/*          predefined names for user collection                         */
/*************************************************************************/

#define VC_X_SEQ_NUMBER_AN	301
#define	VC_X_LINE_ID_AN		302
#define VC_X_ZONE_AN		303
#define VC_X_DETAIL_NUM_AN	304

#define	VC_X_CATEGORY_AN	306
#define	VC_X_GROUP_AN		307
#define	VC_X_COMPART_X_AN	308
#define	VC_X_DECK_X_AN		309
#define	VC_X_ATT_REF_IN		310

/*************************************************************************/
/*                    MISCELLANEOUS  GENERAL                             */
/*         Dynamic attributes for connectivity tables                    */
/*  also uses tag_number, signal_name and conductor_seq (foptic_sec)     */
/*       name indicate from/to of equivalent attributes                  */
/*                 TREAT AS INTERNAL ATTRIBUTES                          */
/*************************************************************************/

#define VC_X_F_EQP_NUMBER_AN	150
#define VC_X_F_TAG_NUMBER_AN	151
#define VC_X_F_MOD_SEQ_AN	152
#define VC_X_F_POS_NAM_AN	153

#define VC_X_T_EQP_NUMBER_AN	154
#define VC_X_T_TAG_NUMBER_AN	155
#define VC_X_T_MOD_SEQ_AN	156
#define VC_X_T_POS_NAM_AN	157

#endif
