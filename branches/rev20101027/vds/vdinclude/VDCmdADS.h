
/* $Id: VDCmdADS.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdinclude/VDCmdADS.h
 *
 * Description:
 *
 *      include file to define ADS Command gadgets
 *       (attribute driven symbols edit command)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdADS.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/11/27  06:18:36  pinnacle
 * Replaced: vdinclude/VDCmdADS.h for:  by vgnair for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.8  1996/05/20  15:36:40  pinnacle
 * Replaced: vdinclude/VDCmdADS.h for:  by hverstee for vds.240
 *
 * Revision 1.7  1995/09/22  13:51:18  pinnacle
 * Replaced: vdinclude/VDCmdADS.h for:  by hverstee for vds.240
 *
 * Revision 1.6  1995/08/29  20:21:30  pinnacle
 * Replaced: vdinclude/VDCmdADS.h for:  by hverstee for vds.240
 *
 * Revision 1.5  1995/08/15  23:36:56  pinnacle
 * Replaced: vdinclude/VDCmdADS.h for:  by hverstee for vds.240
 *
 * Revision 1.4  1995/08/14  22:27:58  pinnacle
 * Replaced: vdinclude/VDCmdADS.h for:  by hverstee for vds.240
 *
 * Revision 1.3  1995/08/11  19:13:28  pinnacle
 * Replaced: vdinclude/VDCmdADS.h for:  by hverstee for vds.240
 *
 * Revision 1.1  1995/06/19  19:40:22  pinnacle
 * Created: vdinclude/VDCmdADS.h by hverstee for vds.240
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 * 	11/27/97	  vini 	 	added cells and library	
 *
 * -------------------------------------------------------------------*/

#ifndef  VDCmdADS_h

#define  VDCmdADS_h

/*       error messages             */

#define VD_ADS_EMSG_MEM    "Memory allocation error, terminated"
#define VD_ADS_EMSG_INV    "Invalid input"
#define VD_ADS_EMSG_QTE    "Invalid character in id-field"
#define VD_ADS_EMSG_PAR    "Parameter out of range"
#define VD_ADS_EMSG_NSV    "Invalid entry found, not saved"
#define VD_ADS_EMSG_CRE    " - Created"
#define VD_ADS_EMSG_NTAB   "Define table name first"

#define VD_ADS_EMSG_NSYM   "Symbolset <%s> does not exist"
#define VD_ADS_EMSG_COPY   "Symbolset <%s> copied to <%s>"
#define VD_ADS_EMSG_NACT   "Symbolset active, save or reset first"

/*       form numbers                                     */

#define VD_ADS_EDITFORM            0

/*       command types                                     */

#define VD_CMD_ADS_EDIT          0
#define VD_CMD_ADS_REV           1

/*       stringlengths etc                 */

#define VD_ADSYM_STL_COMPAR        6
#define VD_ADSYM_NUM_COMPAR        7

/* --------------------------------------------------------- */
/*       Gadgets for VDADS_setup form                        */
/* --------------------------------------------------------- */

#define VD_ADSYM_FORM_NAME         "VDADS_setup"

#define VD_ADSYM_TXT_EDIT           33
#define VD_ADSYM_TXT_REVIEW         55
#define VD_ADSYM_TXT_COPY           38

#define VD_ADSYM_FLD_MSG             9
#define VD_ADSYM_FLD_TABNAM        131
#define VD_ADSYM_FLD_COPY           41
#define VD_ADSYM_FLD_TIMEST         24
#define VD_ADSYM_FLD_USERID         16
#define VD_ADSYM_FLD_LOCAL          26
#define VD_ADSYM_FLD_DESCR          21

#define VD_ADSYM_FLD_TOTENT         46
#define VD_ADSYM_FLD_CURENT         50
#define VD_ADSYM_BTN_DELETE         11
#define VD_ADSYM_BTN_INSERT         52
#define VD_ADSYM_BTN_UP             51
#define VD_ADSYM_BTN_DOWN           49

#define VD_ADSYM_FLD_SYMSTR         37
#define VD_ADSYM_FLD_ATTNAM         86
#define VD_ADSYM_FLD_ATVASC         28
#define VD_ADSYM_FLD_ATVNUM         35

#define VD_ADSYM_FLD_RELTYP         25
#define VD_ADSYM_TGG_ATTTYP         19
#define VD_ADSYM_TGG_PLACE          13

#define VD_ADSYM_FLD_ATTTYP         56
#define VD_ADSYM_FLD_PLACE          57

#define VD_ADSYM_FLD_OFFSET         40
#define VD_ADSYM_FLD_CHHGT          12
#define VD_ADSYM_FLD_CHWDT          54
#define VD_ADSYM_FLD_CHSPC          14
#define VD_ADSYM_FLD_CHFONT         30
#define VD_ADSYM_FLD_CHWGT          60

#define VD_ADSYM_BTN_DEFAULT        34

#define VD_ADSYM_RF_RELTYP          62
#define VD_ADSYM_RF_CHFONT          63
#define VD_ADSYM_RF_CHWGT           64

#define VD_ADSYM_FLD_LIBRY          67
#define VD_ADSYM_FLD_TEXT           70
#define VD_ADSYM_FLD_FLAG           44
#define VD_ADSYM_RF_FLAG            71
#define VD_ADSYM_RF_CELLS           72

#endif

