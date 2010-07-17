
/* $Id: VCDBi.I,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr / VCDBi.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCDB class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1999/01/19  04:29:20  pinnacle
# Replaced: vcdbattr/VCDBi.I for: CR179701619 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.11  1997/08/15  12:54:12  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.10  1997/08/11  21:25:34  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.9  1997/08/05  22:33:34  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.8  1997/07/29  14:48:44  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.7  1997/07/28  22:18:08  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.6  1997/07/14  21:44:38  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/19  15:19:30  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/03  14:24:02  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/29  22:13:24  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:27:32  pinnacle
# Replaced: vcdbattr/VCDBi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:54:08  pinnacle
# Created: vcdbattr/VCDBi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCDB;

#include "VCproto.h"
#include "VCDBpar.h"
#include "VCparameters.h"
#include "VCCmdPJ.h"

#define  VC_ENDMARKER        -9999

struct    VCDBtab
{
   IGRchar       *Nam;
   IGRshort       nNum;
};

  /************************************************************/
  /*    translation table from attribute names to numbers     */

%safe
static
  struct VCDBtab   Localtab[] = {

          /*    general DB                                */
          VC_N_COMP_CODE_AN,    VC_X_COMP_CODE_AN,
          VC_N_SHORT_DESC_AN,   VC_X_SHORT_DESC_AN,
          VC_N_OWNER_ID_AN,     VC_X_OWNER_ID_AN,
          VC_N_MACRO_NAME_AN,   VC_X_MACRO_NAME_AN,
          VC_N_STANDARD_AN  ,   VC_X_STANDARD_AN,
          VC_N_DIAMETER_DB,     VC_X_DIAMETER_DB,
          VC_N_BEND_RAD_DB,     VC_X_BEND_RAD_DB,
          VC_N_ENVIRON_AN,      VC_X_ENVIRON_AN,
          VC_N_FIRE_RESIST_AN,  VC_X_FIRE_RESIST_AN,
          VC_N_SECURITY_AN,     VC_X_SECURITY_AN,
          VC_N_INSUL_TYPE_AN,   VC_X_INSUL_TYPE_AN,
          VC_N_INSUL_THK_DB,    VC_X_INSUL_THK_DB,
          VC_N_WEIGHT_DB,       VC_X_WEIGHT_DB,
          VC_N_COST_DB,         VC_X_COST_DB,
          VC_N_GN_DATA1_DB,     VC_X_GN_DATA1_DB,
          VC_N_GN_DATA2_DB,     VC_X_GN_DATA2_DB,
          VC_N_DESC_AN,         VC_X_DESC_AN,
          VC_N_VENDOR_AN,       VC_X_VENDOR_AN,
          VC_N_CATALOG_NUM_AN,  VC_X_CATALOG_NUM_AN,
          VC_N_STOCK_NUM_AN,    VC_X_STOCK_NUM_AN,
          VC_N_INSERT_BLOCK_AN, VC_X_INSERT_BLOCK_AN,
          VC_N_TUBE_SIZE_AN,    VC_X_TUBE_SIZE_AN,
          VC_N_LUG_SIZE_DB,     VC_X_LUG_SIZE_DB,

          /*   cable lead DB                               */
          VC_N_LEAD_NBR_DB,     VC_X_LEAD_NBR_DB,
          VC_N_CLAD_DIAM_DB,    VC_X_CLAD_DIAM_DB,
          VC_N_SECT_CONDUCT_DB, VC_X_SECT_CONDUCT_DB,
          VC_N_MODAL_BW_DB,     VC_X_MODAL_BW_DB,
          VC_N_LN_SC_FAC_DB,    VC_X_LN_SC_FAC_DB,
          VC_N_SENSITIVE_DB,    VC_X_SENSITIVE_DB,
          VC_N_DT_DATA1_DB,     VC_X_DT_DATA1_DB,
          VC_N_DT_DATA2_DB,     VC_X_DT_DATA2_DB,
          VC_N_DEF_SIGNAL_AN,   VC_X_DEF_SIGNAL_AN,

          /*   electrical lead                              */
          VC_N_CON_MAT_AN,      VC_X_CON_MAT_AN,
          VC_N_VOLTAGE_DB,      VC_X_VOLTAGE_DB,
          VC_N_CURRENT_DB,      VC_X_CURRENT_DB,
          VC_N_RESIST_DB,       VC_X_RESIST_DB,
          VC_N_RESIS_MSR_DB,    VC_X_RESIS_MSR_DB,

          VC_N_AMP_60_40_DB,    VC_X_AMP_60_40_DB,
          VC_N_AMP_60_50_DB,    VC_X_AMP_60_50_DB,
          VC_N_AMP_400_40_DB,   VC_X_AMP_400_40_DB,
          VC_N_AMP_400_50_DB,   VC_X_AMP_400_50_DB,

          /*   fiberoptic lead                              */
          VC_N_NUM_APER_DB,     VC_X_NUM_APER_DB,
          VC_N_CHROM_DISP_DB,   VC_X_CHROM_DISP_DB,
          VC_N_ZERO_DISP_DB,    VC_X_ZERO_DISP_DB,
          VC_N_ATTENUATION_DB,  VC_X_ATTENUATION_DB,
          VC_N_ATT_MEAS_WL_DB,  VC_X_ATT_MEAS_WL_DB,
          VC_N_LMT_PH_SP_ATT_DB,VC_X_LMT_PH_SP_ATT_DB,
          VC_N_HO_MOD_LOSS_DB,  VC_X_HO_MOD_LOSS_DB,

          /*   electrical terminals                         */
          VC_N_MAX_CONNECT_DB,  VC_X_MAX_CONNECT_DB,
          VC_N_WORK_VOLT_DB,    VC_X_WORK_VOLT_DB,
          VC_N_PEAK_VOLT_DB,    VC_X_PEAK_VOLT_DB,
          VC_N_VOLT_DB,         VC_X_VOLT_DB,
          VC_N_VOLT_DROP_DB,    VC_X_VOLT_DROP_DB,
          VC_N_FREQUENCY_DB,    VC_X_FREQUENCY_DB,
          VC_N_RISE_TIME_DB,    VC_X_RISE_TIME_DB,
          VC_N_PRECISION_DB,    VC_X_PRECISION_DB,

          /*  fiberoptic terminals                          */
          VC_N_BANDWIDTH_DB,    VC_X_BANDWIDTH_DB,
          VC_N_SPECTRAL_W_DB,   VC_X_SPECTRAL_W_DB,
          VC_N_LAMBDA_C_DB,     VC_X_LAMBDA_C_DB,
          VC_N_ANG_DIST_DB,     VC_X_ANG_DIST_DB,
          VC_N_PWR_MEAN_DB,     VC_X_PWR_MEAN_DB,
          VC_N_PWR_MAX_DB,      VC_X_PWR_MAX_DB,
          VC_N_PWR_STD_DEV_DB,  VC_X_PWR_STD_DEV_DB,
          VC_N_SEN_STD_DEV_DB,  VC_X_SEN_STD_DEV_DB,

          /*   layout control                                  */
          VC_N_V_MOD_CODE_AN,   VC_X_V_MOD_CODE_AN,
          VC_N_V_MOD_NAME_AN,   VC_X_V_MOD_NAME_AN,
          VC_N_V_POS_NM1_AN,    VC_X_V_POS_NM1_AN,
          VC_N_V_IOTYPE1_DB,    VC_X_V_IOTYPE1_DB,
          VC_N_V_POS_NM2_AN,    VC_X_V_POS_NM2_AN,
          VC_N_V_IOTYPE2_DB,    VC_X_V_IOTYPE2_DB,
          VC_N_V_CONNECTYPE_DB, VC_X_V_CONNECTYPE_DB,

          VC_N_CON_MATCH_AN,    VC_X_CON_MATCH_AN,
          VC_N_CON_SPL_DEF_AN,  VC_X_CON_SPL_DEF_AN,
          VC_N_CNTYPE_AN,       VC_X_CNTYPE_AN,

          /*     inline calculated                            */
          VC_N_NUM_PINS_IN,     VC_X_NUM_PINS_IN,
          VC_N_NUM_CONDUCT_IN,  VC_X_NUM_CONDUCT_IN,
          VC_N_NO_POS_MOD_IN,   VC_X_NO_POS_MOD_IN,
          VC_N_NO_ENT_MOD_IN,   VC_X_NO_ENT_MOD_IN,

          VC_N_NB_CONNPT_IN,    VC_X_NB_CONNPT_IN,
          VC_N_CAB_LENGTH_DB,   VC_X_CAB_LENGTH_DB,
          VC_N_SIGNAL_NAME_AN,  VC_X_SIGNAL_NAME_AN,
          VC_N_EQP_ID_IN,       VC_X_EQP_ID_IN,
          VC_N_EQP_NUMBER_AN,   VC_X_EQP_NUMBER_AN,
          VC_N_REF_CS,          VC_X_REF_CS,
          VC_N_LOC_PT,          VC_X_LOC_PT,
          VC_N_TAIL_LENGTH_DB,  VC_X_TAIL_LENGTH_DB,
          VC_N_ESTIM_LENGTH_DB, VC_X_ESTIM_LENGTH_DB,

          /*      system  attributes                          */
          VC_N_TAG_NUMBER_AN,   VC_X_TAG_NUMBER_AN,
          VC_N_PART_NUM_AN,     VC_X_PART_NUM_AN,
          VC_N_UNIT_AN,         VC_X_UNIT_AN,
          VC_N_SYST_NAME_AN,    VC_X_SYST_NAME_AN,
          VC_N_APPRV_STAT_AN,   VC_X_APPRV_STAT_AN,
          VC_N_CONSTR_STAT_AN,  VC_X_CONSTR_STAT_AN,
          VC_N_CHG_REQ_NUM_AN,  VC_X_CHG_REQ_NUM_AN,
          VC_N_COMP_NOTE_AN,    VC_X_COMP_NOTE_AN,
          VC_N_NO_MTO_AN,       VC_X_NO_MTO_AN,
          VC_N_ADD_LABEL_AN,    VC_X_ADD_LABEL_AN,
          VC_N_PID_SCALE_DB,    VC_X_PID_SCALE_DB,

          /*      misc                                        */
          VC_N_SEQ_NUMBER_AN,   VC_X_SEQ_NUMBER_AN,
          VC_N_LINE_ID_AN,      VC_X_LINE_ID_AN,
          VC_N_ZONE_AN,         VC_X_ZONE_AN,
          VC_N_ERR_FLAG_AN,     VC_X_ERR_FLAG_AN,
          VC_N_DETAIL_NUM_AN,   VC_X_DETAIL_NUM_AN,
          VC_N_PID_SCALE_DB,    VC_X_PID_SCALE_DB,

          VC_N_CATEGORY_AN,     VC_X_CATEGORY_AN,
          VC_N_GROUP_AN,        VC_X_GROUP_AN,
          VC_N_COMPART_X_AN,    VC_X_COMPART_X_AN,
          VC_N_DECK_X_AN,       VC_X_DECK_X_AN,
          VC_N_ATT_REF_IN,      VC_X_ATT_REF_IN,

          VC_N_THRUCONN_AN,     VC_X_THRUCONN_AN,

          /*      dynamic                                     */

          VC_N_F_EQP_NUMBER_AN, VC_X_F_EQP_NUMBER_AN,
          VC_N_F_TAG_NUMBER_AN, VC_X_F_TAG_NUMBER_AN,
          VC_N_F_MOD_SEQ_AN,    VC_X_F_MOD_SEQ_AN,
          VC_N_F_POS_NAM_AN,    VC_X_F_POS_NAM_AN,

          VC_N_T_EQP_NUMBER_AN, VC_X_T_EQP_NUMBER_AN,
          VC_N_T_TAG_NUMBER_AN, VC_X_T_TAG_NUMBER_AN,
          VC_N_T_MOD_SEQ_AN,    VC_X_T_MOD_SEQ_AN,
          VC_N_T_POS_NAM_AN,    VC_X_T_POS_NAM_AN,

	  //added by alwin 
	  VC_N_JUMP_MAX_POSITION_AN, VC_X_JUMP_MAX_POSITION,
          /*      end of table marker                        */

          "****************",   VC_ENDMARKER
          
                                };
%endsafe

/***********************************************************************/

IGRshort   VCDB_AttrNamToNum (IGRchar     *szAttNam)
{

  IGRshort      nRet;
  IGRshort      i;

  nRet = -1;

  for (i=0; Localtab[i].nNum != VC_ENDMARKER; i++)
  {
    if (strcmp (Localtab[i].Nam, szAttNam) == 0)
    {
      nRet = Localtab[i].nNum;
      break;
    }
  }

  return (nRet);
}

IGRchar *   VCDB_AttrNumToNam (IGRshort       nNum)
{
  IGRshort    i;
  IGRchar   * pRet;

  pRet = NULL;

  for (i=0; Localtab[i].nNum != VC_ENDMARKER; i++)
  {
    if (Localtab[i].nNum == nNum)
    {
      pRet = Localtab[i].Nam;
      break;
    }
  }

  return (pRet);
}

IGRshort   VCDB_AttrNamToType (IGRchar     *szAttNam)
{
  IGRshort   nAttNum;

  nAttNum = VCDB_AttrNamToNum (szAttNam);

  return (VCDB_AttrNumToType (nAttNum));
}

IGRshort   VCDB_AttrNumToType (IGRshort     nNum)
{
  IGRshort      nRET;

  if (nNum < 0)                       nRET = VCPT_UNDEFINED;
  else
  if (nNum >= VC_X_SYSTEM_CUTOFF)     nRET = VCPT_USER;
  else
  if (nNum >= VC_X_INTERNAL_CUTOFF)   nRET = VCPT_SYSTEM;
  else
  if (nNum >= VC_DB_PARA_LIMIT)       nRET = VCPT_INTERNAL;
  else
  if (nNum == VC_X_COMP_CODE_AN)      nRET = VCPT_INTERNAL;
  else
                                      nRET = VCPT_DB;

  return (nRET);
}

/*************************************************************************/
/*                      TO BE OVERRIDDEN                                 */
/*************************************************************************/

method  VCGetPos  (IGRlong         *msg;
            struct VCpos           *Posdef;
                   IGRshort        *nIndex;
                    IGRshort       *nMAP;
                    IGRshort       *nSIG)
{  /*    TO BE OVERRIDDEN     */
   *msg       = MSSUCC;
   *nIndex    = -1;
   *nMAP      = -1;
   *nSIG      = -1;

   return (OM_S_SUCCESS);
}

method  VCGpAnum  (IGRlong         *msg;
                   IGRshort         nIndex;
                   IGRshort         nMAP;
                   IGRint           nAttnum;
            struct ret_struct      *res)
{  /*    TO BE OVERRIDDEN     */
   *msg = MSFAIL;

   return (OM_S_SUCCESS);
}

method  VCDB_init   (IGRlong         *msg;
               struct VCdbmain        *Tabrec)
{  /*    TO BE OVERRIDDEN     */
   *msg = MSFAIL;

   return (OM_S_SUCCESS);
}

method  VCDB_ghdr   (IGRlong         *msg;
               struct VCdbmain        *Tabrec)
{  /*    TO BE OVERRIDDEN     */
   *msg = MSFAIL;

   return (OM_S_SUCCESS);
}

method  VCDB_fill    (IGRlong         *msg)
{  /*    TO BE OVERRIDDEN     */
   *msg = MSFAIL;

   return (OM_S_SUCCESS);
}

method  VCGetModules (IGRlong         *msg;
                       IGRshort        *nEnt;
                       IGRshort        *nTopoTyp;
                       IGRchar         *Modlist)
{  /*    TO BE OVERRIDDEN     */
   *msg = MSFAIL;

   return (OM_S_SUCCESS);
}

method  VCGetLayout (IGRlong         *msg;
                      IGRchar         *Modnam;
                      IGRshort        *nEnt;
                      IGRshort        *nTab;
               struct VClayout        *Layout)
{  /*    TO BE OVERRIDDEN     */
   *msg = MSFAIL;

   return (OM_S_SUCCESS);
}

/*************************************************************************/
/*                      IMPLEMENTATION                                   */
/*************************************************************************/

method  VCGpAttr  (IGRlong         *msg;
                   IGRshort         nIndex;
                   IGRshort         nMAP;
                   IGRchar         *szAttNam;
            struct ret_struct      *res)
{
  IGRint   status;
  IGRshort nAtt;

  nAtt = VCDB_AttrNamToNum (szAttNam);

  if (nAtt >= 0)
  {
    status =
    om$send (msg = message VCDB.VCGpAnum
                      (msg, nIndex, nMAP, nAtt, res),
        targetid = my_id);
  }
  else
  {
    status = OM_S_SUCCESS;
    *msg   = MSFAIL;
  }

  return (status);
}

method VCGetAttr (IGRlong         *msg;
           struct VCpos           *Posdef;
                  IGRchar         *szAttNam;
           struct ret_struct      *res)

{
  IGRint      status;
  IGRshort    nIndex;
  IGRshort    nMAP;
  IGRshort    nSig;

  status =
  om$send (msg = message VCDB.VCGetPos (msg, Posdef, &nIndex, &nMAP, &nSig),
      targetid = my_id);

  status =
  om$send (msg = message VCDB.VCGpAttr (msg, nIndex, nMAP, szAttNam, res),
      targetid = my_id);

  return (status);
}

method VCGetAnum (IGRlong         *msg;
           struct VCpos           *Posdef;
                  IGRint           nAttnum;
           struct ret_struct      *res)

{
  IGRint      status;
  IGRshort    nIndex;
  IGRshort    nMAP;
  IGRshort    nSig;

  status =
  om$send (msg = message VCDB.VCGetPos (msg, Posdef, &nIndex, &nMAP, &nSig),
      targetid = my_id);

  status =
  om$send (msg = message VCDB.VCGpAnum (msg, nIndex, nMAP, nAttnum, res),
      targetid = my_id);

  return (status);
}

/*************************************************************************/
/*              @@@@           TBD           @@@@                        */
/*************************************************************************/

/*     these methods to be used if a forms driven database interface
       is implemented                                                    */

method  VCDB_delete (IGRlong         *msg;
                     FILE            *OutFil)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method   VCDB_sdata   (IGRlong         *msg;
                       IGRshort         nomod;
                struct VCdbmodsel      *Mods;
                       IGRshort         nodata;
                union  VCdbdatarec     *Data)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}


end implementation VCDB;

