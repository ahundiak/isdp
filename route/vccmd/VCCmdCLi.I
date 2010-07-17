/* $Id: VCCmdCLi.I,v 1.2 2002/05/29 20:25:43 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdCLi.I
 *
 * Description:
 *      Implementation file for "C Configure Cable Leads" command
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdCLi.I,v $
 *  Revision 1.2  2002/05/29 20:25:43  anand
 *  Third set of bug fixes for the split cable functionality.
 *  Merge does not corrupt the model. The marker information is
 *  now propagated to newly sketched cables/sub-cables. Changed
 *  interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *  Revision 1.1  2002/05/08 15:48:23  anand
 *  Files added/modified for sub-cable functionality.
 *
 *
 * History:
 *        DATE		AUTHOR		DESCRIPTION
 *
 *     12 April '02	Jayadev		Creation
 *
 *************************************************************************/

class implementation VCCmdCL;

#include <stdlib.h>
#include "vc_define.h"
#include "VCdbstructs.h"
#include "VCCmdPC.h"
#include "VCCmdDef.h"
#include "VDmem.h"
#include "VDchn.h"
#include "VCDBpar.h"
#include "VCmacros.h"
#include "VCLead.h"
#include "VCdefine.h"
#include "vrdbgmacros.h"

from VCCable import VCAmISubCab, VCCbInsConTab ;
from VCCable import VCCSetCon_Data, VCGetInfoSubCab;

/***********  EXTERN ***********/

method init ( int type ; char * str_ptr )
{
  int         status;
  IGRlong     retmsg;
  int         i;
  extern int  GRstatus_display_button();

  SetProc( Md init ); Begin 

  //Initialize superclass
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VCCmdCAT.init( type, str_ptr ),
                    targetid = my_id);

  me->parCable.objid = NULL_OBJID;
  me->parCable.osnum = 2;
  me->subCable.objid = NULL_OBJID;
  me->subCable.osnum = 2;
  me->checkTransfer  = 1;

  me->pUsrAtt        = NULL;
  me->pCtlAtt        = NULL;
  me->bSysUp         = FALSE;
  me->form_ptr       = NULL;
  me->FCmain         = VC_FPOS_CL_MAIN;
  // initialize the VLAs
  om$vla_set_dimension(varray = me->parLeads, size = 0);
  om$vla_set_dimension(varray = me->subLeads, size = 0);

  quit:
  End
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int     status;

  SetProc( Md wakeup ); Begin 

  if( (pos & EX_suspend) && me->bSysUp )
  {
      __DBGpr_com( " Display the form " );
      FIf_display( me->form_ptr );
  }

  End
  return (OM_S_SUCCESS);
}

method sleep ( int pos )
{
    int             status;

    if( (pos & EX_suspend) && me->bSysUp )
	FIf_erase ( me->form_ptr );

    status = om$send (	mode     = OM_e_wrt_message,
			msg      = message VCCmdCAT.sleep( pos ),
			targetid = my_id);

    return (OM_S_SUCCESS);
}

method VCCleanup ( long * sts )
{
    IGRint       status;

    SetProc( Md VCCleanup ); Begin  

    om$vla_set_dimension(varray = me->parLeads, size = 0);
    om$vla_set_dimension(varray = me->subLeads, size = 0);

    if( me->form_ptr )
    {
//	FIf_delete( me->form_ptr );
//	VC_INITSTR( me->form_ptr );
	me->bSysUp = FALSE;
    }

    __DBGpr_com( " Calling VCATExit to Cleanup..." );
    status = om$send ( msg = message VCCmdCAT.VCATExit (sts),
	    targetid = my_id);

    End
    return OM_S_SUCCESS;
}

method VCFstart ()
{
  int   status;

  SetProc( Md VCFstart ); Begin 

  if( !me->bSysUp )
  {
      __DBGpr_com(" The form is not displayed already. So display it.");
      me->pSysAtt  = me->forms[0].form_ptr;
      me->form_ptr = me->pSysAtt;

     status = VC_Cmd_form_open ( me->form_ptr, me->FCmain );
     me->bSysUp = TRUE;
  }

  End
  return OM_S_SUCCESS;
}
IGRlong VCfindIfLeadInUse(
			   struct VCLdInfo *ldInfo,
			   struct GRid     *cable,
			   IGRint          *inUse,
		           IGRint          *extEnd
			 )
{
    IGRlong retFlag = 0;
    IGRint  i, whichEnd;
    IGRboolean begExtreme, endExtreme;

    if((!ldInfo) || (!cable) ) goto wrapup;

    if(extEnd) *extEnd = -1;
    begExtreme = endExtreme = FALSE;

    // check if this cable is any of the extreme ones for the lead
    if((cable->objid == ldInfo->CabId[0].objid) &&
       (cable->osnum == ldInfo->CabId[0].osnum)) 
    {
	begExtreme = TRUE;   
        whichEnd   = 0;
        if(extEnd) *extEnd = begExtreme; 
    }
	 
    if((cable->objid == ldInfo->CabId[(ldInfo->NbCab)-1].objid) &&
       (cable->osnum == ldInfo->CabId[(ldInfo->NbCab)-1].osnum))  
    {
	endExtreme = TRUE;
        whichEnd   = 1;
        if(extEnd) *extEnd = endExtreme; 
    }
    /*
     * Just to know the extreme position of the subcable for the lead
     */
    if(!inUse)
    {
	retFlag = 1;
	goto wrapup;
    }

    if(begExtreme || endExtreme)
    {
        // see if there is a terminal at that end
	  if(ldInfo->TermId[whichEnd].objid != NULL_OBJID)
	  {
	      if(((ldInfo->FibEnds[whichEnd].szModId != '\0') &&
	         (ldInfo->FibEnds[whichEnd].szPosId != '\0')) 
		                    &&
	         ((strlen(ldInfo->FibEnds[whichEnd].szModId) != 0) &&
	          (strlen(ldInfo->FibEnds[whichEnd].szPosId) != 0)))
	      {
		  *inUse = 1;
	      }
	      else
	      {
		  *inUse = 0;
	      }
	  }
	  else
	  {
	      *inUse = 0;
	  } 
    }
    else
    {
	*inUse = 1;
    }

    //Done
    retFlag = 1;
wrapup:
    return retFlag;
}
method VCGetObject( IGRlong *sts )
{
  int                  status, nParCab, i, j;
  IGRshort             iNo;
  int                  NumAvlLeads, whichEnd;
  IGRlong              retmsg, sts1, msg;
  struct VCcab_connect *Conn = NULL, *avlLeads = NULL;
  IGRboolean           legacy;

  SetProc( Md VCGetObject ); Begin 

  me->subCable = me->event1.located_object[0].located_obj;
  if( me->subCable.objid == NULL_OBJID )
  {
     UI_status( "Please locate Proper Input" );
     End
     return ( VC_ERROR );
  }
  __DBGpr_obj("me->subCable ", me->subCable); 
  // get the parent cable
  sts1 = om$send(msg = message VCCable.VCAmISubCab( &retmsg, &whichEnd,
                                                    &me->parCable, NULL, NULL),
		 targetid = me->subCable.objid,
		 targetos = me->subCable.osnum);

  if(!(sts1&retmsg&1) || 
     ((whichEnd!=VCC_SPLIT_BEGIN) && (whichEnd!=VCC_SPLIT_END)))
  {
     UI_status(" Please select a subcable");
     *sts = VC_ERROR; 
     End
     return ( VC_ERROR );
  }
  __DBGpr_obj("me->parCable ", me->parCable); 

  // get the lead info for all the leads in the parent Cable
  // CAUTION: Conn points to the instance. DO NOT FREE IT!
  iNo = 0;
  Conn = NULL; 
  status =
  om$send ( msg = message VCCable.VCCbInsConTab (&retmsg, &iNo, &Conn),
       targetid = me->parCable.objid,
       targetos = me->parCable.osnum);  
  if(!(status&retmsg&1) || (iNo == 0))
  {
    __DBGpr_obj(" VCCbInsConTab FAILED ", me->parCable );
    *sts = VC_ERROR; 
    End
    return ( VC_ERROR );
  }
  __DBGpr_int(" No. of leads in parent cable ", iNo);
  om$vla_set_dimension(varray = me->parLeads, size = iNo); 
  
  NumAvlLeads = 0;

  if(whichEnd == VCC_SPLIT_BEGIN)
  {
      status = VC$SubCabLeadInfo( p_msg		    = &retmsg,
				  gridInputCab	    = me->parCable,
				  p_nBegAvlblLeads  = &NumAvlLeads
				);
      __DBGpr_int(" Number of Beg available leads ", NumAvlLeads);
      if(NumAvlLeads > 0)
      {
	  avlLeads = _MALLOC(NumAvlLeads, struct VCcab_connect);
	  status = VC$SubCabLeadInfo( p_msg		    = &retmsg,
				      gridInputCab	    = me->parCable,
				      p_nBegAvlblLeads  = &NumAvlLeads,
				      p_BegAvlblLds	    = avlLeads 
				    );
      }
  }
  else
  {
      status = VC$SubCabLeadInfo( p_msg		    = &retmsg,
				  gridInputCab	    = me->parCable,
				  p_nEndAvlblLeads  = &NumAvlLeads
				);
      __DBGpr_int(" Number of End available leads ", NumAvlLeads);
      if(NumAvlLeads > 0)
      {
	  avlLeads = _MALLOC(NumAvlLeads, struct VCcab_connect);
	  status = VC$SubCabLeadInfo( p_msg		    = &retmsg,
				      gridInputCab	    = me->parCable,
				      p_nEndAvlblLeads  = &NumAvlLeads,
				      p_EndAvlblLds	    = avlLeads 
				    );
      }
  }

  for(i=0; i<iNo; i++)
  {
    me->parLeads[i].used  = 1;

    for(j=0; j<NumAvlLeads; j++)
    {
      if(!strcmp(Conn[i].LeadNam, avlLeads[j].LeadNam))
      {
	me->parLeads[i].used = 0;
	break;
      }	
    }
	 
    me->parLeads[i].ldInfo.CabId = NULL;

    strcpy(me->parLeads[i].ldInfo.LeadNam, Conn[i].LeadNam);
    strcpy(me->parLeads[i].ldInfo.SigNam, Conn[i].SigNam);

    me->parLeads[i].ldInfo.nEndStat[0] = Conn[i].nEndStat[0];
    me->parLeads[i].ldInfo.nEndStat[1] = Conn[i].nEndStat[1];
    me->parLeads[i].ldInfo.nFibStat           = Conn[i].nFibStat;

    sts1 = VC$GetNetworkForLead( 
			        msg            = &msg,
			        szLeadName     = Conn[i].LeadNam,
			        p_gridCabId    = &me->parCable,
			        p_LeadInfo     = &me->parLeads[i].ldInfo	
                              );
    if(!(sts1&msg&1))
    {
      __DBGpr_obj(" VC$GetNetworkForLead failed for", me->parCable);
      __DBGpr_str(" Lead Name ", Conn[i].LeadNam);
      *sts = VC_ERROR; 
      End
      return ( VC_ERROR );
    }

    VC_INITSTR(me->parLeads[i].ldInfo.Marker);
    sts1 =  VCGetAttrInfoForLead( &me->parCable, &me->parLeads[i].ldInfo, 1,
		   VC_MARKER_TYPE, &legacy);
    if(!(sts1&1))
    {
      __DBGpr_obj("Marker : VCGetAttrInfoForLead failed for", me->parCable);
      __DBGpr_str(" Lead Name ", Conn[i].LeadNam);
      *sts = VC_ERROR; 
      End
      return ( VC_ERROR );
    }
    __DBGpr_int(" Parent Cable LeadIndex ", i);
    __DBGpr_str(" Parent Cable LeadName ", me->parLeads[i].ldInfo.LeadNam); 
    __DBGpr_str(" Parent Cable SignalName ", me->parLeads[i].ldInfo.SigNam); 
    __DBGpr_str(" Parent Cable Marker ", me->parLeads[i].ldInfo.Marker); 
    __DBGpr_int(" Lead in Use ", me->parLeads[i].used);
    __DBGpr_int(" Lead passes thru cables ", me->parLeads[i].ldInfo.NbCab);
    __DBGpr_objlist("Cables ", me->parLeads[i].ldInfo.NbCab,
		    me->parLeads[i].ldInfo.CabId);
    __DBGpr_obj("Begin Terminal ", me->parLeads[i].ldInfo.TermId[0]);
    __DBGpr_obj("End Terminal ", me->parLeads[i].ldInfo.TermId[1]);
    __DBGpr_str(" Begin Terminal Pin Module ", 
		me->parLeads[i].ldInfo.FibEnds[0].szModId); 
    __DBGpr_str(" Begin Terminal Pin Position ", 
		me->parLeads[i].ldInfo.FibEnds[0].szPosId); 
    __DBGpr_str(" End Terminal Pin Module ", 
		me->parLeads[i].ldInfo.FibEnds[1].szModId); 
    __DBGpr_str(" End Terminal Pin Position ", 
		me->parLeads[i].ldInfo.FibEnds[1].szPosId); 
  }
  _FREE(avlLeads);
  // captured all the info required for the leads of parent cable
  
  // need to find the info for the selected subcable
  iNo  = 0;
  Conn = NULL;
  status =
  om$send ( msg = message VCCable.VCCbInsConTab (&retmsg, &iNo, &Conn),
       targetid = me->subCable.objid,
       targetos = me->subCable.osnum);  
  if(!(status&retmsg&1) || (iNo == 0))
  {
    __DBGpr_obj(" VCCbInsConTab FAILED ", me->subCable );
    *sts = VC_ERROR; 
    End
    return ( VC_ERROR );
  }
  __DBGpr_int(" No. of leads in sub cable ", iNo);
  om$vla_set_dimension(varray = me->subLeads, size = iNo); 
  for(i=0; i<iNo; i++)
  {
    me->subLeads[i].used  = -1; 
    // simply copy the relevant lead info from the matching
    // lead in the parent cable
    for(j=0; j<om$dimension_of(varray = me->parLeads); j++)
    {
      if(!strcmp(Conn[i].LeadNam, me->parLeads[j].ldInfo.LeadNam))
      {
	  me->subLeads[i].ldInfo = me->parLeads[j].ldInfo;
          me->subLeads[i].ldInfo.nEndStat[0] = Conn[i].nEndStat[0];
          me->subLeads[i].ldInfo.nEndStat[1] = Conn[i].nEndStat[1];
          me->subLeads[i].ldInfo.nFibStat           = Conn[i].nFibStat;
	  break;
      }
    }
    // find if this lead[i] is used or unsed lead for the parent cable
    sts1 = VCfindIfLeadInUse( &me->subLeads[i].ldInfo, &me->subCable, 
			      &me->subLeads[i].used , NULL);
    if(!(sts1&1) || (me->parLeads[i].used  == -1))
    {
      __DBGpr_obj(" VCfindLeadInUse failed for", me->subCable);
      *sts = VC_ERROR; 
      End
      return ( VC_ERROR );
    }
    __DBGpr_int("Sub Cable LeadIndex ", i);
    __DBGpr_str(" Sub Cable LeadName ", me->subLeads[i].ldInfo.LeadNam); 
    __DBGpr_int(" Lead in Use ", me->subLeads[i].used); 
  }
  /*
   * Need to set the me->checkTransfer flag to TRUE if we donot have
   * any used leads in the subcable; if set to FALSE, we need execute
   * the contents of the VCcheckTransfer method
   */
  i = 0;
  for(j=0; j<om$dimension_of(varray = me->subLeads); j++)
    if( me->subLeads[j].used == 1) i++;

  if(i>0) me->checkTransfer = 0;

  __DBGpr_int("me->checkTransfer ", me->checkTransfer);
quit:
  *sts = MSSUCC;
  End
  return OM_S_SUCCESS;
}
/*
 * When a row is selected on the form, it may be an empty 
 * one; this function takes the row-text , and returns 1
 * if that matches any of the parent/subcable leadnames, 
 * denoting an appropriate selection; the flag is set to
 * TRUE if the leadname str belong to the subcable
 */
method VCisAppropSelect( IGRlong         *sts; 
			 GRname          str;
			 IGRboolean      *flag;
			 struct VCLdInfo *matchInfo)
{
  IGRint  i; 

  SetProc( Md VCisAppropSelect ); Begin 
  *flag = FALSE;

  if(str[0] == '\0')
  {
     End
     return ( OM_E_ABORT );
  }
  /*
   * compare the string against the unused leadnames in the 
   * parent and subcables
   */
  for(i=0; i<om$dimension_of(varray = me->subLeads); i++)
  {
    if(me->subLeads[i].used == 0)
    {
      if(!strcmp(me->subLeads[i].ldInfo.LeadNam, str))
      {
	  if(matchInfo) *matchInfo = me->subLeads[i].ldInfo; 
	  *flag = TRUE;
	  *sts = MSSUCC;
          End
          return OM_S_SUCCESS;
      }	  
    }
  } 
  for(i=0; i<om$dimension_of(varray = me->parLeads); i++)
  {
    if(me->parLeads[i].used == 0)
    {
      if(!strcmp(me->parLeads[i].ldInfo.LeadNam, str))
      {
	  if(matchInfo) *matchInfo = me->parLeads[i].ldInfo; 
	  *sts = MSSUCC;
          End
          return OM_S_SUCCESS;
      }	  
    }
  }
  // if the leadname matches should be returning above
  End
  return OM_E_ABORT;
}
/*
 * This routine essentially ensures that we have atleast
 * one valid row of lead information for unused leads of
 * subcable on the form
 */
method VCcheckTransfer( IGRlong *retsts)
{
    IGRlong     sts, msg;
    IGRint      nRows, nAppr, nHilit, nApprHilit;
    IGRint      SelFlag, rp, i;
    IGRchar     LeadName[VC_MAX_LEAD_ID];
    IGRboolean  flag;

    SetProc( Md VCcheckTransfer ); Begin 
    if(me->checkTransfer == 0)
    {
	/* This means that the subcable has atleast one
	 * used lead and hence is always assured of not
	 * being ripped off without any leads in it
	 */
	*retsts = MSSUCC;
        End
	return OM_S_SUCCESS;
    }
    /* 
     * Get all the rows on the form (unused section 
     * for subcable) - nRows
     * Get the no. of appropriate rows that has the lead
     * information -   nAppr
     * Get all the hilited rows on the form - nHilit
     * Get all the hilited rows that has lead info - nApprHilit 
     * The condition (nAppr > nApprHilit) ensures that the
     * subcable has atleast one lead in it
     */

    nRows = nAppr = nHilit = nApprHilit = 0;
    FIfld_get_num_rows( me->form_ptr, VCSUBCAB_UNUSD_LEAD, &nRows );

    for( i=0 ; i<nRows ; i++ )
    {
	  FIfld_get_select( me->form_ptr, VCSUBCAB_UNUSD_LEAD,
			    i, 0, &SelFlag );
	  if(SelFlag) nHilit ++;

	  FIfld_get_text( me->form_ptr, VCSUBCAB_UNUSD_LEAD, i, 0,
			  VC_MAX_LEAD_ID, LeadName, &SelFlag, &rp );
          __DBGpr_str("LeadName selected in row ", LeadName);
	  sts = om$send ( msg = message VCCmdCL.VCisAppropSelect( &msg,
					        LeadName, &flag, NULL),
			targetid = my_id );
          if(sts&msg&1)
	  {
	      nAppr ++;
	      if(SelFlag) nApprHilit ++;
	  }
    }
    __DBGpr_int("nRows ", nRows);
    __DBGpr_int("nAppr ", nAppr);
    __DBGpr_int("nHilit ", nHilit);
    __DBGpr_int("nApprHilit ", nApprHilit);

    if(nAppr > nApprHilit) *retsts = MSSUCC;
    else                   *retsts = MSFAIL;

    End
    return OM_S_SUCCESS;
}
method VCGetSubCableLdInfo( IGRlong              *retsts;
			    struct VCcab_connect *ldInfo;
			    IGRint               *nLeads;
			  )
{
    IGRint           nSubCabLds, i, j, nRows, rp;
    IGRint           SelFlag;
    struct VCLdInfo  subCabLdInfo[128], matchLdInfo; 
    IGRboolean       flag;
    IGRchar          LeadName[VC_MAX_LEAD_ID];
    IGRlong          sts, msg;

    SetProc( Md VCSetCableLdInfo ); Begin 
    if( !nLeads)
    {
      End
      return ( OM_E_ABORT );
    }
    nSubCabLds = 0;
    // first take into account the used leads for subcable
    for(i=0; i<om$dimension_of(varray = me->subLeads); i++)
    {
      if(me->subLeads[i].used == 1)
      {
	  subCabLdInfo[nSubCabLds] = me->subLeads[i].ldInfo;
	  nSubCabLds ++;
      }
    }    
    /* 
     * Get all the rows from the unused section of subcable
     * on the form and see they represent valid leadnames
     *
     * If so, subCabLdInfo[nSubCabLds] = me->subLeads[i].ldInfo;
     * and increment nSubCabLds ++;
     *
     * need to take care of nFibStat and nEndStat in the VCLdInfo
     * structure for leads that are taken from parent cable into
     * subcable and also the other way round;
     */
    nRows = 0;
    FIfld_get_num_rows( me->form_ptr, VCSUBCAB_UNUSD_LEAD, &nRows );

    for( i=0 ; i<nRows ; i++ )
    {
	  FIfld_get_text( me->form_ptr, VCSUBCAB_UNUSD_LEAD, i, 0,
			  VC_MAX_LEAD_ID, LeadName, &SelFlag, &rp );
          __DBGpr_str("LeadName selected in row ", LeadName);
	  sts = om$send ( msg = message VCCmdCL.VCisAppropSelect( &msg,
					        LeadName, &flag, &matchLdInfo),
			targetid = my_id );
          if(sts&msg&1)
	  {
	      __DBGpr_com(" Appropriate selection ");
	      if(flag)
	      {
		  __DBGpr_com("Subcable Lead");
	      }
	      else
	      {
		  __DBGpr_com("Parent Cable Lead");
	      }

	      subCabLdInfo[nSubCabLds] = matchLdInfo;
	      nSubCabLds ++;
	  }
	  else
	  {
	      __DBGpr_com(" InAppropriate selection ");
	  }
    }
    *nLeads = nSubCabLds;
    if(!ldInfo)
    {
	*retsts    = MSSUCC;
        End
        return OM_S_SUCCESS;
    }
    for(i=0; i<nSubCabLds; i++)
    {
	ldInfo[i].FibEnds[0] = subCabLdInfo[i].FibEnds[0];
	ldInfo[i].FibEnds[1] = subCabLdInfo[i].FibEnds[1];
	ldInfo[i].nEndStat[0] = subCabLdInfo[i].nEndStat[0];
	ldInfo[i].nEndStat[1] = subCabLdInfo[i].nEndStat[1];
	ldInfo[i].nFibStat = subCabLdInfo[i].nFibStat;
	strcpy(ldInfo[i].LeadNam, subCabLdInfo[i].LeadNam);
	strcpy(ldInfo[i].SigNam, subCabLdInfo[i].SigNam);
    }
    *retsts    = MSSUCC;
    End
    return OM_S_SUCCESS;
}
method VCSetSubCableLdInfo( IGRlong *sts)
{
    IGRlong              msg, retmsg;
    IGRint               i, j, nSubCabLds = 0;
    IGRint               status, iNo;
    struct VCcab_connect *conData = NULL;

    SetProc( Md VCSetCableLdInfo ); Begin 

    /* From the form rows, make out the no. of leads that 
     * go into the subcable
     */
    iNo = 0;
    status =
    om$send ( msg = message VCCmdCL.VCGetSubCableLdInfo (&retmsg, NULL, &iNo),
         targetid = my_id); 
    if(!(status&retmsg&1) || (iNo == 0))
    {
      __DBGpr_com(" VCGetSubCableLdInfo FAILED ");
      End
      return ( OM_E_ABORT );
    }  
    nSubCabLds = iNo;
    __DBGpr_int(" nSubCabLds ", nSubCabLds);

    conData = _MALLOC(nSubCabLds, struct VCcab_connect);

    nSubCabLds = 0;
    status =
    om$send ( msg = message VCCmdCL.VCGetSubCableLdInfo(&retmsg,
							conData, &nSubCabLds),
         targetid = my_id); 
    if(!(status&retmsg&1) || (iNo == 0))
    {
      __DBGpr_com(" VCGetSubCableLdInfo FAILED ");
      End
      return ( OM_E_ABORT );
    }  
    // set the conData for the subcable 
    status = om$send( msg = message VCCable.VCCSetCon_Data( &msg,
                                                            nSubCabLds,
                                                            conData,
                                                            NULL
                                                          ),
		      senderid = NULL_OBJID,
                      targetid = me->subCable.objid,
		      targetos = me->subCable.osnum);
    if(!(status&1))
    {
      __DBGpr_obj("VCCable.VCCSetCon_Data failed for ", me->subCable);
      _FREE(conData);
      End
      return ( OM_E_ABORT );
    }
    End
    return OM_S_SUCCESS;
}
method VCDispForm( IGRlong *sts )
{
    IGRint   i, SelFlag=FALSE, whichEnd;
    IGRint   avlbl, unused, used;
    IGRchar  buffer[128];
    IGRlong  sts1;

    SetProc( Md VCDispForm ); Begin
    avlbl = unused = used = 0;
    for(i=0; i<om$dimension_of(varray = me->parLeads ); i++)
    {
	if(me->parLeads[i].used == 0)
	{
	    avlbl ++;
	    __DBGpr_str("Parent Available Leadname ", 
			me->parLeads[i].ldInfo.LeadNam);
	}
    }
    for(i=0; i<om$dimension_of(varray = me->subLeads ); i++)
    {
	if(me->subLeads[i].used == 0)
	{
	    unused ++;
	    __DBGpr_str("Unused Subcable Leadname ", 
			me->subLeads[i].ldInfo.LeadNam);
	}
        else 
	{
	    used ++;
	    __DBGpr_str("Used Subcable Leadname ", 
			me->subLeads[i].ldInfo.LeadNam);
	}
    }
    __DBGpr_int(" No. of Available leads on parent ", avlbl);
    __DBGpr_int(" No. of Unused leads on subcable ", unused);
    __DBGpr_int(" No. of Used leads on subcable ", used);

    // fill the form
    FIfld_set_num_rows( me->form_ptr,VCSUBCAB_AVLBL_LEAD , avlbl); 
    FIfld_set_num_rows( me->form_ptr,VCSUBCAB_UNUSD_LEAD , unused); 
    FIfld_set_num_rows( me->form_ptr,VCSUBCAB_USED_FIELD , used);

    SelFlag = 0;
    avlbl = unused = used = 0;

    for(i=0; i<om$dimension_of(varray = me->parLeads ); i++)
    {
	if(me->parLeads[i].used == 0)
	{
	    FIfld_set_text (me->form_ptr, VCSUBCAB_AVLBL_LEAD, avlbl, 
			    0, me->parLeads[i].ldInfo.LeadNam, SelFlag);
	    avlbl ++;
	}
    }
    for(i=0; i<om$dimension_of(varray = me->subLeads ); i++)
    {
	if(me->subLeads[i].used == 0)
	{
	    FIfld_set_text (me->form_ptr, VCSUBCAB_UNUSD_LEAD, unused, 
			    0, me->subLeads[i].ldInfo.LeadNam, SelFlag);
	    unused ++;
	}
	else
	{
	    FIfld_set_text (me->form_ptr, VCSUBCAB_USED_FIELD, used, 
			    VCSUBCAB_USED_LEADS, 
			    me->subLeads[i].ldInfo.LeadNam, SelFlag);
	    {
		/*
		 * find if the subcable is the end one for the lead 
		 * if so, you will have a terminal with this lead connected
		 * to one of its pin; we present the (module,position) 
		 * information to the user on the form
		 */
		sts1 = VCfindIfLeadInUse( &me->subLeads[i].ldInfo, 
					  &me->subCable, 
					  NULL , &whichEnd);
		if(!(sts1&1))
		{
		    __DBGpr_obj(" VCfindLeadInUse failed for", me->subCable);
		    *sts = MSFAIL; 
		    End
		    return ( VC_ERROR );
		}
		if(whichEnd != -1)
		{
		    sprintf(buffer,"TermPin: Mod[%s] Pos[%s]",
			    me->subLeads[i].ldInfo.FibEnds[whichEnd].szModId,
			    me->subLeads[i].ldInfo.FibEnds[whichEnd].szPosId);
		    FIfld_set_text (me->form_ptr, VCSUBCAB_USED_FIELD, used, 
				    VCSUBCAB_USED_WHERE, 
				    buffer, SelFlag);
		}
		else
		{
		    sprintf(buffer,"SubCable");
		    FIfld_set_text (me->form_ptr, VCSUBCAB_USED_FIELD, used, 
				    VCSUBCAB_USED_WHERE, 
				    buffer, SelFlag);
		}
	    } 
	    used ++;
	}
    }

    *sts = MSSUCC;
    End
    return OM_S_SUCCESS;
}
method VCSubCabGrabLead( IGRlong *retsts)
{
    IGRlong             sts, msg;
    IGRint		i, NumRows, SelFlag, rp;
    IGRchar		LeadName[VC_MAX_LEAD_ID];
    IGRboolean          flag;

    SetProc( Md VCSubCabGrabLead ); Begin 
    /* 
     * call VCisAppropSelect() on the hilited text
     * rows on the form
     * move the appropriate hilited text content  
     * VCSUBCAB_AVLBL_LEAD -> VCSUBCAB_UNUSD_LEAD
     */

      FIfld_get_num_rows( me->form_ptr, VCSUBCAB_AVLBL_LEAD, &NumRows );

      for( i=0 ; i<NumRows ; i++ )
      {
	  FIfld_get_select( me->form_ptr, VCSUBCAB_AVLBL_LEAD,
			    i, 0, &SelFlag );
	  FIfld_get_text( me->form_ptr, VCSUBCAB_AVLBL_LEAD, i, 0,
			  VC_MAX_LEAD_ID, LeadName, &SelFlag, &rp );
          __DBGpr_str("LeadName selected in row ", LeadName);

	  sts = om$send ( msg = message VCCmdCL.VCisAppropSelect( &msg,
					        LeadName, &flag, NULL),
			targetid = my_id );
	  /*
	   * Make sure that the text in the row matches one of the
	   * leadnames
	   */
	  if( SelFlag && (sts&msg&1))
	  {
              __DBGpr_com(" VCSUBCAB_AVLBL_LEAD -> VCSUBCAB_UNUSD_LEAD");

	      FIfld_get_num_rows( me->form_ptr, VCSUBCAB_UNUSD_LEAD, &rp );
	      FIfld_set_num_rows( me->form_ptr, VCSUBCAB_UNUSD_LEAD, rp+1 );

	      SelFlag = 0;
	      FIfld_set_text( me->form_ptr, VCSUBCAB_UNUSD_LEAD, rp, 0,
			      (char *) LeadName, SelFlag );

	      FIfld_delete_rows( me->form_ptr, VCSUBCAB_AVLBL_LEAD, i, 1 );
	      i--;
	      NumRows--;
	  }
      }
    UI_status("Lead Transfer successful");
    *retsts = MSSUCC;
    End
    return OM_S_SUCCESS;
}

method VCSubCabDropLead( IGRlong *retsts)
{
    IGRlong             sts, msg;
    IGRint		i, NumRows, SelFlag, rp;
    IGRchar		LeadName[VC_MAX_LEAD_ID];
    IGRboolean          flag;

    SetProc( Md VCSubCabDropLead ); Begin 
    /* See if the lead transfer is appropriate
     * by calling VCcheckTransfer() method; 
     * call VCisAppropSelect() on the hilited text
     * rows on the form
     * move the appropriate hilited text content  
     * VCSUBCAB_UNUSD_LEAD -> VCSUBCAB_AVLBL_LEAD
     */
    sts = om$send ( msg = message VCCmdCL.VCcheckTransfer( &msg),
		    targetid = my_id );
    if(!(sts&msg&1))
    {
	__DBGpr_com(" LEADS CANNOT BE TRANSFERRED ");
	UI_status(" LEADS CANNOT BE TRANSFERRED ");
        *retsts = MSSUCC; 	
	End
	return OM_S_SUCCESS;
    }
    FIfld_get_num_rows( me->form_ptr, VCSUBCAB_UNUSD_LEAD, &NumRows );

    for( i=0 ; i<NumRows ; i++ )
    {
	  FIfld_get_select( me->form_ptr, VCSUBCAB_UNUSD_LEAD,
			    i, 0, &SelFlag );
	  FIfld_get_text( me->form_ptr, VCSUBCAB_UNUSD_LEAD, i, 0,
			  VC_MAX_LEAD_ID, LeadName, &SelFlag, &rp );
          __DBGpr_str("LeadName selected in row ", LeadName);

	  sts = om$send ( msg = message VCCmdCL.VCisAppropSelect( &msg,
					        LeadName, &flag, NULL),
			targetid = my_id );
	  /*
	   * Make sure that the text in the row matches one of the
	   * leadnames
	   */
	  if( SelFlag && (sts&msg&1))
	  {
              __DBGpr_com(" VCSUBCAB_UNUSD_LEAD -> VCSUBCAB_AVLBL_LEAD");
	      FIfld_get_num_rows( me->form_ptr, VCSUBCAB_AVLBL_LEAD, &rp );
	      FIfld_set_num_rows( me->form_ptr, VCSUBCAB_AVLBL_LEAD, rp+1 );

	      SelFlag = 0;
	      FIfld_set_text( me->form_ptr, VCSUBCAB_AVLBL_LEAD, rp, 0,
			      (char *) LeadName, SelFlag );

	      FIfld_delete_rows( me->form_ptr, VCSUBCAB_UNUSD_LEAD, i, 1 );
	      i--;
	      NumRows--;
	  }
     }
    UI_status("Lead Transfer successful");
    *retsts = MSSUCC;
    End
    return OM_S_SUCCESS;
}

method form_notification ( int       form_label ;
                           int       gadget_label ;
                           double    value ;
                           char     *form_ptr )
{
    IGRint	status = OM_S_SUCCESS;
    IGRint	i;
    IGRlong   	retmsg;
    IGRchar  	*fptr;
    IGRchar   	c30buff[VC_MAX_TAGNO];

    SetProc( Md form_notification ); Begin 

    __DBGpr_int(" form label",form_label);
    __DBGpr_int(" gadget label",gadget_label);
    __DBGpr_dbl(" value label",value);
    __DBGpr_str(" form ptr",form_ptr);

    fptr = me->form_ptr;
    c30buff[0] = '\0';

    switch( gadget_label )
    {
      case FI_RESET:
      {
	  __DBGpr_com( " Reached reset case " );

	  UI_status("Form contents reset");
	  status = om$send ( msg = message VCCmdCL.VCDispForm( &retmsg ),
			targetid = my_id );
	  break;
      };

      case VCSUBCAB_GRAB_LEAD:
	  status = om$send ( msg = message VCCmdCL.VCSubCabGrabLead( &retmsg ),
			targetid = my_id );
          break;

      case VCSUBCAB_DROP_LEAD:
	  status = om$send ( msg = message VCCmdCL.VCcheckTransfer( &retmsg ),
			targetid = my_id );

	  if(status&retmsg&1)
	  {
	    status = om$send ( msg = message VCCmdCL.VCSubCabDropLead(&retmsg),
			    targetid = my_id );
	  }
	  else
	  {
	      UI_status("Error: No Leads remain in Subcable");
	  }
          break;

      case FI_ACCEPT:
      {
	  __DBGpr_com( " Reached execute case " );
	  status = om$send ( msg = message VCCmdCL.VCSetSubCableLdInfo( 
					   &retmsg ),
			targetid = my_id );

      };

      case FI_CANCEL:
      {
	  __DBGpr_com( " Reached cancel case " );
	  status = om$send ( msg = message VCCmdCL.VCCleanup( 
					   &retmsg ),
			targetid = my_id );
	  _put_response (resp = EX_FORM_FINISHED);
	  break;
      };

      default:
	  __DBGpr_com( " Reached default case " );
    }

quit:
    End
    return OM_S_SUCCESS;
}
end implementation VCCmdCL;
