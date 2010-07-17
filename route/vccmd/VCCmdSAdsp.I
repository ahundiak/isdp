
/* $Id: VCCmdSAdsp.I,v 1.3 2002/05/29 20:25:43 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdSAdsp.I
 *
 * Description:
 *      Display of connection and more info reviewforms
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdSAdsp.I,v $
 *  Revision 1.3  2002/05/29 20:25:43  anand
 *  Third set of bug fixes for the split cable functionality.
 *  Merge does not corrupt the model. The marker information is
 *  now propagated to newly sketched cables/sub-cables. Changed
 *  interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *  Revision 1.2  2002/05/08 15:48:23  anand
 *  Files added/modified for sub-cable functionality.
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/02/06  11:06:32  pinnacle
# Replaced: vccmd/VCCmdSAdsp.I for:  by apazhani for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/08/12  22:10:58  pinnacle
# Replaced: vccmd/VCCmdSAdsp.I for:  by hverstee for cabling
#
# Revision 1.3  1997/07/31  22:16:24  pinnacle
# Replaced: vccmd/VCCmdSAdsp.I for:  by hverstee for cabling
#
# Revision 1.2  1997/07/31  20:07:48  pinnacle
# Replaced: vccmd/VCCmdSAdsp.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/29  15:04:06  pinnacle
# Created: vccmd/VCCmdSAdsp.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  02/06/98      Alwin   Made a minor fix, which misleads the user while
 *                        viewing the Cable Connection details.
 *
 *************************************************************************/

class implementation VCCmdSA;

#include "VCmacros.h"
#include "VCCmdSet.h"
#include "VCCmdMre.h"
#include "VCCmdCCN.h"
#include "VCCmdTCN.h"
#include "VCLead.h"
#include "vrdbgmacros.h"

#include "VDmem.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "VRMcForm.h"

/*
#define  MY_DEBUG
*/

from  VCDB          import  VCGpAnum;
from  VCDB          import  VCGetLayout;

from  VCRoot        import  VCGetRep;
from  VCRoot        import  VCGetMtoFlag;
from  VCRoot        import  VCGetType;
from  VCRoot        import  VCGetCode;
from  VCRoot        import  VCGetTagNo;
from  VCRoot        import  VCGetProduct;
from  VCRoot        import  VCGetParams;
from  VCRoot        import  VCGetTopology;
from  VCRoot        import  VCGetInstance;
from  VCRoot        import  VCChgParam;

from  VCMac         import  VCGetEquipTag;
from  VCMac         import  VCGetEquipId;

from  VCCable       import  VCCbInsConTab;
from  VCCable       import  VCCbTerm;

from  VCTerm        import  VCTshells;

from  ACncpx        import  ACgive_structure;



method  VCSAdsp_eq   (IGRlong      *msg;
               struct GRid         *TermId;       /*   terminal id   */
                      IGRchar      *pForm;
                      IGRint        iGDGtyp;      /*  gadget TYPE    */
                      IGRint        iGDGtag;      /*  gadget TAG     */
                      IGRint        iGDGcmp)
{
  IGRint       status;
  IGRlong      retmsg;

  struct GRid  EqId;

  EqId.objid = NULL_OBJID;

  if ((TermId != NULL) && (TermId->objid != NULL_OBJID))
  {
    status =
    om$send(msg = message VCMac.VCGetEquipId (&retmsg, &EqId),
       targetid = TermId->objid,
       targetos = TermId->osnum);
  }

  if (EqId.objid == NULL_OBJID)
  {
    IGRchar      szFld[2];

    VC_INITSTR (szFld);

    if (iGDGtyp > 0)
      FIg_set_text (pForm, iGDGtyp, szFld);
    if (iGDGtag > 0)
      FIg_set_text (pForm, iGDGtag, szFld);
    if (iGDGcmp > 0)
      FIg_set_text (pForm, iGDGcmp, szFld);
  }
  else
  {
    IGRint       intmsg;
    IGRint       Findex;

    struct ret_struct   rts;

    Findex = -1;

    if (iGDGtyp > 0)
    {
      VC_INITSTR (rts.var.text_st.text_string);

      status =
      om$send (msg = message ACncpx.ACgive_structure
                              (&intmsg, &Findex, VC_VDS_EQ_EQTYP, &rts,
                               &me->ModuleInfo),
          targetid = EqId.objid,
          targetos = EqId.osnum);

      FIg_set_text (pForm, iGDGtyp, rts.var.text_st.text_string);
    }

    if (iGDGtag > 0)
    {
      VC_INITSTR (rts.var.text_st.text_string);

      status =
      om$send (msg = message ACncpx.ACgive_structure
                              (&intmsg, &Findex, VC_VDS_EQ_EQTAG, &rts,
                               &me->ModuleInfo),
          targetid = EqId.objid,
          targetos = EqId.osnum);

      FIg_set_text (pForm, iGDGtag, rts.var.text_st.text_string);
    }

    if (iGDGcmp > 0)
    {
      VC_INITSTR (rts.var.text_st.text_string);

      status =
      om$send (msg = message ACncpx.ACgive_structure
                              (&intmsg, &Findex, VC_VDS_EQ_COMPT, &rts,
                               &me->ModuleInfo),
          targetid = EqId.objid,
          targetos = EqId.osnum);

      FIg_set_text (pForm, iGDGcmp, rts.var.text_st.text_string);
    }
  }

  return (OM_S_SUCCESS);
}

method  VCSAdsp_more (IGRlong    *msg)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nIndex, nMap;

  struct ret_struct   rts;

  *msg  = MSSUCC;

  nIndex = nMap = -1;

  status =
  VC_Cmd_form_open (me->pMORE, VC_FPOS_SA_MORE);
  me->bSAmoreup = TRUE;

  /*    retrieve and display all params    */

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_STANDARD_AN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_text (me->pMORE, VC_GDG_DFL_SPEC,  rts.var.text_st.text_string);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_CATALOG_NUM_AN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_text (me->pMORE, VC_GDG_DFL_CAT,  rts.var.text_st.text_string);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_STOCK_NUM_AN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_text (me->pMORE, VC_GDG_DFL_STOCK,  rts.var.text_st.text_string);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_CON_MAT_AN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_text (me->pMORE, VC_GDG_DFL_MATL,  rts.var.text_st.text_string);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_NUM_CONDUCT_IN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pMORE, VC_GDG_DFL_NOCON,  rts.var.root_pm_st.value);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_SECT_CONDUCT_DB, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pMORE, VC_GDG_DFL_LDIA,  rts.var.root_pm_st.value);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_DIAMETER_DB, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pMORE, VC_GDG_DFL_CDIA,  rts.var.root_pm_st.value);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_BEND_RAD_DB, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pMORE, VC_GDG_DFL_BRAD,  rts.var.root_pm_st.value);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_VOLTAGE_DB, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pMORE, VC_GDG_DFL_VOLT,  rts.var.root_pm_st.value);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_CURRENT_DB, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pMORE, VC_GDG_DFL_CURR,  rts.var.root_pm_st.value);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_RESIST_DB, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pMORE, VC_GDG_DFL_RES,  rts.var.root_pm_st.value);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_INSERT_BLOCK_AN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_text (me->pMORE, VC_GDG_DFL_INSB,  rts.var.text_st.text_string);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_WEIGHT_DB, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pMORE, VC_GDG_DFL_WGT,  rts.var.root_pm_st.value);

  return OM_S_SUCCESS;
}

method  VCSAdsp_tcon (IGRlong    *msg)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRint          i;
  IGRint          irow;
  IGRint          SelFlag;
  IGRchar         szCab[VC_MAX_CCODE];

  *msg  = MSSUCC;
  SelFlag = 0;

  status =
  VC_Cmd_form_open (me->pTCON, VC_FPOS_SA_TCON);
  me->bSAtconup = TRUE;

  /*    retrieve and display all params    */

  /*   get the connections buffers           */

  status =
  om$send (msg = message VCCtab.VCCtLoad (&retmsg, &me->CompId, &me->CATenv),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" Loaded, display   \n");
#endif

  status =
  om$send (msg = message VCCmdSA.VCSAdsp_eq
                                 (&retmsg, &me->CompId, me->pTCON,
                                  VC_TCON_GDG_EQTYP,
                                  VC_TCON_GDG_EQTAG, 0),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" To formdisp %s %s  \n",me->CompCode,  me->CompTag);
#endif

  FIg_set_text (me->pTCON, VC_TCON_GDG_TERMTYP , me->CompCode);
  FIg_set_text (me->pTCON, VC_TCON_GDG_TERMTAG , me->CompTag);

#ifdef MY_DEBUG
  printf (" To table %d rows max \n",me->nMaxCon);
#endif

  FIfld_set_max_num_rows (me->pTCON,VC_TCON_GDG_MCF, me->nMaxCon);

  irow = 0;

#ifdef MY_DEBUG
  for (i=0; i<me->nNumConTab; i++)
  {
    printf (" -- %s %s %s == %s %s \n",
                  me->PosTab[i].pDef.Conn.Term.szModId ,
                  me->PosTab[i].pDef.Conn.Term.szPosId ,
                  me->ConTab1[i].Ctag ,
                  me->ConTab1[i].ps.Conn.Cable.szLeadId,
                  me->ConTab1[i].sig);
  }
#endif

  for (i=0; i<me->nNumConTab; i++)
  {
#ifdef MY_DEBUG
  printf (" Item , loop, row %d %d",i, irow);
#endif

    if (me->PosTab[i].pDef.nType == VC_TERM_TYPE)
    {
#ifdef MY_DEBUG
      printf (" pdef ");
#endif

      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_MOD,
                        me->PosTab[i].pDef.Conn.Term.szModId , SelFlag);
      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_POS,
                        me->PosTab[i].pDef.Conn.Term.szPosId , SelFlag);
      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_CTAG,
                        me->ConTab1[i].Ctag , SelFlag);

      VC_INITSTR (szCab);

      if (me->ConTab1[i].GR.objid != NULL_OBJID)
      {
        status =
        om$send (msg = message VCRoot.VCGetCode (szCab),
            targetid = me->ConTab1[i].GR.objid,
            targetos = me->ConTab1[i].GR.osnum);
      }

      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_CTYP,
                        szCab , SelFlag);

      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_CLEAD,
                        me->ConTab1[i].ps.Conn.Cable.szLeadId, SelFlag);
      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_SIG,
                        me->ConSig1[i].sig , SelFlag);

      irow++;
    }

    if (me->PosTab[i].pAlt.nType == VC_TERM_TYPE)
    {
#ifdef MY_DEBUG
      printf (" palt ");
#endif

      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_MOD,
                        me->PosTab[i].pAlt.Conn.Term.szModId , SelFlag);
      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_POS,
                        me->PosTab[i].pAlt.Conn.Term.szPosId , SelFlag);
      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_CTAG,
                        me->ConTab2[i].Ctag , SelFlag);

      VC_INITSTR (szCab);

      if (me->ConTab2[i].GR.objid != NULL_OBJID)
      {
        status =
        om$send (msg = message VCRoot.VCGetCode (szCab),
            targetid = me->ConTab2[i].GR.objid,
            targetos = me->ConTab2[i].GR.osnum);
      }

      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_CTYP,
                        szCab , SelFlag);

      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_CLEAD,
                        me->ConTab2[i].ps.Conn.Cable.szLeadId, SelFlag);
      FIfld_set_text (me->pTCON, VC_TCON_GDG_MCF, irow, VC_TCON_COL_SIG,
                        me->ConSig2[i].sig , SelFlag);

      irow++;
    }
#ifdef MY_DEBUG
    printf (" done\n ");
#endif

  }

  return (OM_S_SUCCESS);
}

method  VCSAdsp_ccon (IGRlong    *msg)
{
  IGRint                  status;
  IGRlong                 retmsg, sts;
  IGRshort                iNo;
  IGRshort                iend;
  IGRchar                 szFld[80];
  IGRint                  iGDG;
  IGRint                  i, j, nIndex;
  IGRint                  SelFlag;

  struct GRid              Term[2], trunkCable;

  IGRshort                nEnt, nTab, nLeads;
  GRname                  *ldNames, *sigNames, buff;
  struct VClayout         *Layout;
  struct VCLdInfo         ldInfo;
  struct VCTpos           begTermPin, endTermPin;
  IGRboolean              legacy;

  Layout        = NULL;
  ldNames       = NULL;
  sigNames      = NULL;
  nLeads        = 0; 

  *msg          = MSSUCC;

  SelFlag       = 0;

  status =
  VC_Cmd_form_open (me->pCCON, VC_FPOS_SA_CCON);
  me->bSAcconup = TRUE;
  FIfld_set_num_rows( me->pCCON, VC_CCON_GDG_MCF, 0 );

  __DBGpr_objlist("me->Connx",2,me->Connx);

  /*    retrieve and display all params    */

  /**** commenting this, b'cas this shows wrong information when we change 
  the cable code and without executing(run), if we try viewing the Cable 
  Connections with the Terminal Pins, this will show some conflicting 
  connections which should not allowed. B'cas it will some Cable code and show 
  connection details of the old Cable Code. Alwin
 
  FIg_set_text (me->pCCON, VC_CCON_GDG_CABTAG, me->CompTag);
  FIg_set_text (me->pCCON, VC_CCON_GDG_CABTYP, me->CompCode);
 
  Instead get information from Located Component ***/
 
  /* added by alwin */
  status =
  om$send (msg = message VCRoot.VCGetCode (szFld),
         targetid = me->CompId.objid,
         targetos = me->CompId.osnum);
 
  FIg_set_text (me->pCCON, VC_CCON_GDG_CABTYP, szFld);
 
  status =
  om$send (msg = message VCRoot.VCGetTagNo (szFld),
         targetid = me->CompId.objid,
         targetos = me->CompId.osnum);
 
  FIg_set_text (me->pCCON, VC_CCON_GDG_CABTAG, szFld);
  /* added by alwin */

  for (iend = 0; iend < 2; iend++)
  {
      /*
      status =
      om$send ( msg = message VCCable.VCCbTerm (&retmsg, iend, &Term[iend]),
         targetid = me->CompId.objid,
         targetos = me->CompId.osnum);
      */

      /* Replace all occurrences of Term[] with me->Connx[] here */
      Term[iend] = me->Connx[iend];

    if (Term[iend].objid != NULL_OBJID)
    {
      VC_INITSTR (szFld);

      status =
      om$send (msg = message VCRoot.VCGetCode (szFld),
         targetid = Term[iend].objid,
         targetos = Term[iend].osnum);

      iGDG = (iend == 0) ? VC_CCON_GDG_TMATYP : VC_CCON_GDG_TMBTYP;

      FIg_set_text  (me->pCCON, iGDG, szFld);

      VC_INITSTR (szFld);

      status =
      om$send (msg = message VCRoot.VCGetTagNo (szFld),
         targetid = Term[iend].objid,
         targetos = Term[iend].osnum);

      iGDG = (iend == 0) ? VC_CCON_GDG_TMATAG : VC_CCON_GDG_TMBTAG;

      FIg_set_text  (me->pCCON, iGDG, szFld);

      status =
      om$send (msg = message VCCmdSA.VCSAdsp_eq
                                 (&retmsg, &Term[iend], me->pCCON,
                                  (iend == 0) ?
                                  VC_CCON_GDG_EQATYP : VC_CCON_GDG_EQBTYP,
                                  (iend == 0) ?
                                  VC_CCON_GDG_EQATAG : VC_CCON_GDG_EQBTAG,
                                  0),
          targetid = my_id);
    }
    else
    {
      VC_INITSTR (szFld);

      iGDG = (iend == 0) ? VC_CCON_GDG_TMATYP : VC_CCON_GDG_TMBTYP;
      FIg_set_text  (me->pCCON, iGDG, szFld);

      iGDG = (iend == 0) ? VC_CCON_GDG_TMATAG : VC_CCON_GDG_TMBTAG;
      FIg_set_text  (me->pCCON, iGDG, szFld);
    }
  }

  /* Hack around for parent cable */
  if( me->bParCab )
  {
    trunkCable.objid = NULL_OBJID;
    // get the main cable in the network
    sts = VC$GetTrunkCab( msg              = &retmsg,
		          p_gridCabId      = &me->CompId,
			  p_gridTrunkCabId = &trunkCable
			);
    if(!(sts&retmsg&1) || (trunkCable.objid == NULL_OBJID))
    {
      __DBGpr_obj("VC$GetTrunkCab FAILED ", me->CompId);
      goto wrapup;
    }
    __DBGpr_obj("TRUNK CABLE ", trunkCable);

    // get all the names&signals of the leads for the trunkcable
    { 
	struct VCcab_connect    *Conn;
	// CAUTION: Conn points to the instance. DO NOT FREE IT!
	status =
	om$send ( msg = message VCCable.VCCbInsConTab (&retmsg, &iNo, &Conn),
		  targetid = me->CompId.objid,
		  targetos = me->CompId.osnum);

	nLeads = iNo;

	ldNames  = _MALLOC(nLeads, GRname);
	sigNames = _MALLOC(nLeads, GRname);
	for(j=0; j<nLeads; j++) {
	    ldNames [j][0] = '\0';
	    sigNames[j][0] = '\0';
	}
	for(j=0; j<nLeads; j++)
	{
	    strcpy(ldNames[j], Conn[j].LeadNam);  
	    strcpy(sigNames[j], Conn[j].SigNam);  
	}
    }

    // if any of the leads has either of the begin/end terminals
    // selected on the form me->Connx[], display the info for 
    // that particular lead

    FIfld_set_num_rows( me->pCCON, VC_CCON_GDG_MCF, nLeads );
    nIndex = 0;

    for(j=0; j<nLeads; j++)
    {
      legacy = FALSE;
      strcpy(ldInfo.LeadNam, ldNames[j]);
      VC_INITSTR(ldInfo.Marker);
      sts =  VCGetAttrInfoForLead( &trunkCable, &ldInfo, 1,
				   VC_MARKER_TYPE, &legacy);
      if(!(sts&1))
      {
        __DBGpr_obj("Marker : VCGetAttrInfoForLead failed for", trunkCable);
        __DBGpr_str(" Lead Name ", ldNames[j]);
        goto wrapup;
      }

	/* Display all leads if no terminal selected. */
      if((me->Connx[0].objid==NULL_OBJID)&&(me->Connx[1].objid==NULL_OBJID))
      {
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, j, VC_CCON_COL_AMOD,
			    "" , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, j, VC_CCON_COL_APOS,
			    "" , SelFlag);
	__DBGpr_str(" Lead Name ", ldNames[j]);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, j, VC_CCON_COL_LEAD,
			    ldNames[j] , SelFlag);
	__DBGpr_str(" Signal Name ", sigNames[j]);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, j, VC_CCON_COL_SIG,
			    sigNames[j] , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, j, VC_CCON_COL_BMOD,
			    "" , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, j, VC_CCON_COL_BPOS,
			    "" , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, j, VC_CCON_COL_MARK,
			    ldInfo.Marker, SelFlag);
	continue;
      }

      Term[0].objid = NULL_OBJID;
      Term[1].objid = NULL_OBJID;
      sts = VC$GetNetworkForLead( 
			        msg                = &retmsg,
			        szLeadName         = ldNames[j],
			        p_gridCabId        = &trunkCable,
				p_gridBegTerm      = &Term[0],
				p_gridEndTerm      = &Term[1],
				p_vctposBegTermPin = &begTermPin,
				p_vctposEndTermPin = &endTermPin
                              );
      if(!(sts&retmsg&1))
      {
        __DBGpr_obj(" VC$GetNetworkForLead failed for", trunkCable);
        __DBGpr_str(" Lead Name ", ldNames[j]);
        goto wrapup;
      }

      // fill the form info only for matching terminals
      if(((Term[0].objid == me->Connx[0].objid ) &&
          (Term[0].osnum == me->Connx[0].osnum )) &&
         ((Term[1].objid == me->Connx[1].objid ) &&
          (Term[1].osnum == me->Connx[1].osnum ))) 
      {
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, nIndex, VC_CCON_COL_AMOD,
			    begTermPin.szModId , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, nIndex, VC_CCON_COL_APOS,
			    begTermPin.szPosId , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, nIndex, VC_CCON_COL_LEAD,
			    ldNames[j] , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, nIndex, VC_CCON_COL_SIG,
			    sigNames[j] , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, nIndex, VC_CCON_COL_BMOD,
			    endTermPin.szModId , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, nIndex, VC_CCON_COL_BPOS,
			    endTermPin.szPosId , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, nIndex, VC_CCON_COL_MARK,
			    ldInfo.Marker, SelFlag);
	nIndex ++;
      }
    }
  }
  else
  {
      struct VCcab_connect    *Conn;
      // CAUTION: Conn points to the instance. DO NOT FREE IT!
      status =
      om$send ( msg = message VCCable.VCCbInsConTab (&retmsg, &iNo, &Conn),
	   targetid = me->CompId.objid,
	   targetos = me->CompId.osnum);

      FIfld_set_num_rows( me->pCCON, VC_CCON_GDG_MCF, iNo );

      for (i=0; i<iNo; i++)
      {
	legacy = FALSE;
	strcpy(ldInfo.LeadNam, Conn[i].LeadNam);
        VC_INITSTR(ldInfo.Marker);
	sts =  VCGetAttrInfoForLead( &(me->CompId), &ldInfo, 1,
	      		       VC_MARKER_TYPE, &legacy);
	if(!(sts&1))
	{
	  __DBGpr_obj("Marker : VCGetAttrInfoForLead failed for", me->CompId);
	  __DBGpr_str(" Lead Name ", Conn[i].LeadNam[i]);
	  goto wrapup;
	}
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, i, VC_CCON_COL_AMOD,
			    Conn[i].FibEnds[0].szModId , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, i, VC_CCON_COL_APOS,
			    Conn[i].FibEnds[0].szPosId , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, i, VC_CCON_COL_LEAD,
			    Conn[i].LeadNam , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, i, VC_CCON_COL_SIG,
			    Conn[i].SigNam , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, i, VC_CCON_COL_BMOD,
			    Conn[i].FibEnds[1].szModId , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, i, VC_CCON_COL_BPOS,
			    Conn[i].FibEnds[1].szPosId , SelFlag);
	FIfld_set_text (me->pCCON, VC_CCON_GDG_MCF, i, VC_CCON_COL_MARK,
			    ldInfo.Marker, SelFlag);
      }
  }
wrapup :
  _FREE(sigNames);
  _FREE(ldNames);
  _FREE(Layout);

  if(!(sts&retmsg&1)) return MSFAIL; 
  else return OM_S_SUCCESS;
}

end implementation VCCmdSA;

