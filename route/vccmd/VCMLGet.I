
/* $Id: VCMLGet.I,v 1.6 2002/05/24 21:41:49 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCMLGet.I
 *
 * Description:
 *      Implementation file for place cable command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMLGet.I,v $
 *  Revision 1.6  2002/05/24 21:41:49  anand
 *  Second set of bug fixes for the cable lead enhancement.
 *  Fixes errors in model arising out of merge-cable workflows.
 *  Ensure placeholders are created for markers for DB driven
 *  cables. Major shuffling of code in Sketch cable state table.
 *
 *  Revision 1.5  2002/05/14 14:15:05  anand
 *  Bug fixes. TRs 6347 and 6348.
 *
 *  Revision 1.4  2002/05/10 22:13:24  anand
 *  First set of bug fixes for sub-cable functionality. Attempts
 *  to fix merge issues, and some cpt issues. Fix for TR 6344.
 *
 *  Revision 1.3  2002/05/08 15:48:23  anand
 *  Files added/modified for sub-cable functionality.
 *
 *  Revision 1.2  2001/02/20 01:09:51  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:07:44  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by r250_int for route
#
# Revision 1.22  1997/11/09  06:42:14  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by apazhani for cabling
#
# Revision 1.21  1997/07/22  16:05:16  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.20  1997/05/12  17:04:40  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.19  1997/05/10  15:17:22  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.18  1997/05/07  14:18:34  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.17  1997/04/30  13:03:58  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.16  1997/04/28  22:33:40  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.15  1997/03/12  21:55:36  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.14  1997/01/31  18:13:30  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.13  1997/01/24  14:55:08  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.12  1997/01/23  23:50:28  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.11  1997/01/09  23:02:32  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.10  1997/01/09  19:59:56  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.8  1996/12/18  17:49:16  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.7  1996/11/15  22:27:52  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.6  1996/11/12  21:47:56  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.5  1996/10/25  14:32:50  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/09  22:02:54  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:20:24  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:37:04  pinnacle
# Replaced: vccmd/VCMLGet.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:21:14  pinnacle
# Created: vccmd/VCMLGet.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

/*         METHODS

          VCGetLink                
          VCGetLinkAttr            
          VCGetConn                
          VCGetAssocPoint          */

class implementation VCCmdPC;

#include <ctype.h>
#include <string.h>

#include "bsdistptpt.h"
#include "vrdbgmacros.h"
#include "VCLead.h"

/*
#define MY_DEBUG 
*/

/***********  EXTERN ***********/

from  NDnode    import  NDgive_structure;

from  ACncpx    import  ACgive_structure;

from  VCRoot    import  VCGetCptGeom;
from  VCRoot    import  VCGetCptCoord;
from  VCRoot    import  VCGetTopology;
from  VCRoot    import  VCGetCode;
from  VCRoot    import  VCGetProduct;
from  VCRoot    import  VCSelectCpt;

from  VCTerm    import  VCTembed;

from  VCCable   import  VCCbTerm;

from  VCCable	import	VCAmISubCab;

// Needed for VC$SubCabLeadInfo
from VCCable import VCGetInfoSubCab;

extern GRclassid  OPP_VRRway_class_id;

extern GRclassid  OPP_VCCable_class_id;
extern GRclassid  OPP_VCGuide_class_id;
extern GRclassid  OPP_VCTerm_class_id;



method VCGetCitem ( long * sts )
{
  IGRint            status;
  IGRint            nProd;
  GRclassid         parentClassId;

  *sts = me->ret = VC_RTC_ALLOK;

  /*A ----- Get located object ----- */
  me->ConnId    = me->event1.located_object[0].located_obj;

  me->dIncrd[0] = me->event1.event.button.x;
  me->dIncrd[1] = me->event1.event.button.y;
  me->dIncrd[2] = me->event1.event.button.z;

  /*   for connect check product first  */

  status =
  om$send (msg = message VCRoot.VCGetProduct (&nProd, NULL),
      targetid = me->ConnId.objid,
      targetos = me->ConnId.osnum);
  as$status();

  if ((nProd != me->Product) &&
      ( (me->Product == VC_PROD_ELEC) || (me->Product == VC_PROD_FO)) )
  {
    _put_response( resp = EX_BACK_UP );
    *sts = EX_BACK_UP;
    goto quit;
  }
  else
    me->Product = nProd;

  om$get_classid (objid = me->ConnId.objid,
                  osnum = me->ConnId.osnum,
              p_classid = &parentClassId );

  if ( om$is_ancestry_valid (subclassid = parentClassId,
                           superclassid = OPP_VCCable_class_id )
                                      == OM_S_SUCCESS)
  {
    // Insert place holders for marker attribute on located cable.
    VCsyncLdAttrInfo( &me->ConnId );
  
    status =
    om$send (msg = message VCCmdPC.VCGetLink (sts),
        targetid = my_id);
  }
  else
  if ( om$is_ancestry_valid (subclassid = parentClassId,
                           superclassid = OPP_VCTerm_class_id )
                                      == OM_S_SUCCESS)
  {
    status =
    om$send (msg = message VCCmdPC.VCGetConn (sts),
        targetid = my_id);
  }
  else
  {
    _put_response( resp = EX_BACK_UP );
    *sts = EX_BACK_UP;
  }

  quit:
  return (OM_S_SUCCESS);
}

method VCGetAitem ( long * sts )
{
  IGRint            status;
  GRclassid         parentClassId;

  me->ret = VC_RTC_ALLOK;

  /*A ----- Get located object ----- */
  me->ConnId   = me->event1.located_object[0].located_obj;

  me->dIncrd[0] = me->event1.event.button.x;
  me->dIncrd[1] = me->event1.event.button.y;
  me->dIncrd[2] = me->event1.event.button.z;

  om$get_classid (objid = me->ConnId.objid,
                  osnum = me->ConnId.osnum,
              p_classid = &parentClassId );

  if ((om$is_ancestry_valid (subclassid = parentClassId,
                           superclassid = OPP_VCGuide_class_id )
                                      == OM_S_SUCCESS))
  {
    status =
    om$send (msg = message VCCmdPC.VCGetConduit (sts),
        targetid = my_id);
  }
  else
  if ((om$is_ancestry_valid (subclassid = parentClassId,
                           superclassid = OPP_VRRway_class_id )
                                      == OM_S_SUCCESS)                )
  {
    status =
    om$send (msg = message VCCmdPC.VCGetRway (sts),
        targetid = my_id);
  }
  else
  {
    status =
    om$send (msg = message VCCmdPC.VCGetAssocPoint (sts),
        targetid = my_id);
  }

  return (OM_S_SUCCESS);
}



method VCGetLink ( long * sts)
{
  int               status = OM_S_SUCCESS;
  int               nCurMerge;
  IGRlong           retmsg;
  IGRshort          i;
  IGRshort          nCpt;
  IGRboolean        bFree;
  struct GRid       Win;
  struct GRid       connIds[2];
  IGRshort          connCpts[2];
  double            dSelOff = 0;
  double            dSelOn  = 1;
  IGRdouble         dCrd[3];
  IGRshort          nCP;
  IGRshort          nOCP;
  IGRchar           szCC[13];

  struct GRid       Oterm;

  IGRint	    nSubCab=0, NbLeads=0;

  SetProc( VCGetLink ); Begin;

  nCP = 0;

  if (me->bGoing) nCurMerge = 1;
  else            nCurMerge = 0;

  __DBGpr_int("Sketch in progress?",me->bGoing);

#ifdef vdsDEBUG
  printf (" Get cable <%d %d>\n",me->ConnId.objid, me->ConnId.osnum);
#endif

  connIds[0].objid   = NULL_OBJID;
  connIds[0].osnum   = me->ModuleInfo.md_id.osnum;
  connIds[1].objid   = NULL_OBJID;
  connIds[1].osnum   = me->ModuleInfo.md_id.osnum;

  Win.objid          = me->event1.event.button.objid;
  Win.osnum          = me->event1.event.button.osnum;
 
  /*   check if merge attempted TO a sub-cable   */
  status = om$send( msg = message VCCable.VCAmISubCab( &retmsg, &nSubCab,
						       NULL, NULL, NULL ),
		    targetid = me->ConnId.objid,
		    targetos = me->ConnId.osnum );

  me->bSkSplCab = (status&retmsg&1) ? TRUE : FALSE;
  __DBGpr_int("Sketching sub cable?",me->bSkSplCab);

  if( me->bSkSplCab && me->bGoing )
  {
    me->bSkSplCab = FALSE;
    UI_status("Cannot merge with a sub-cable");
    _put_response( resp = VC_RTC_ERROR );
    *sts = VC_RTC_ERROR;
    goto quit;
  } 

  /*   select the end to connect   */

#ifdef vdsDEBUG
  printf (" select end\n");
#endif

  status =
  om$send(msg = message VCRoot.VCSelectCpt
                       (&retmsg, me->dIncrd, &nCpt, dCrd, NULL, &bFree,
                        &me->event1.located_object[0].module_info),
     targetid = me->ConnId.objid,
     targetos = me->ConnId.osnum);
  __DBGpr_int("Cpt of cable located for merging",nCpt);

  /* Below if condition checks to see if a connect was attempted on a
   * sub-cable at the point where it branches off from parent cable. */
  if( me->bSkSplCab && nCpt==0 )
  {
    UI_status("Cannot extend sub-cable at branch-off point.");
    _put_response( resp = VC_RTC_ERROR );
    *sts = VC_RTC_ERROR;
    goto quit;
  }

  /* Check if me->ConnId is a parent cable split at the nCpt end */

  if( nCpt == 0 )
      status = VC$SubCabLeadInfo( p_msg		   = &retmsg,
				  gridInputCab	   = me->ConnId,
				  p_nBegCab	   = &nSubCab,
				  p_nBegAvlblLeads = &NbLeads );
  else
      status = VC$SubCabLeadInfo( p_msg		   = &retmsg,
				  gridInputCab	   = me->ConnId,
				  p_nEndCab	   = &nSubCab,
				  p_nEndAvlblLeads = &NbLeads );
  __DBGpr_int("Num Subcables off located cable at located end",nSubCab);
  __DBGpr_int("Num leads available off located cable",NbLeads);

  me->ParSpltEnd = nCpt;

  if( nSubCab ) // ie., located cable has sub-cables (ie., is a parent cable).
  {
      if( me->bGoing )
      {
	  UI_status("Cannot merge with a cable that has been split.");
	  _put_response( resp = VC_RTC_ERROR );
	  *sts = VC_RTC_ERROR;
	  goto quit;
      }
  /* If so, AND IF IT IS NOT AN ATTEMPT TO MERGE, set some command instance
   * and direct state table to goto Split */
      else
      {
	  /* Code come here, it means => User has located the end of a cable
	   * that has been split. Obviously, user has an intention to sketch a
	   * subcable using the remaining leads not taken up by other
	   * subcables. Hence set flag. */
	  me->bSkSplCab = TRUE;

	  /* Get details of located object and display on form */
	  status =
	  om$send(msg = message VCCmdCAT.VCATGetData
	      			    (&retmsg, &me->ConnId),
	     targetid = my_id );
	  as$status();
	 
	  /*C Update form contents */
	  status =
	  om$send(msg = message VCCmdCAT.VCATLoadLnAttr
	      		       (me->pSysAtt, &me->ConnId),
	     targetid = my_id );
	  as$status();

	  FIg_set_text (me->pSysAtt,VCCAT_LINK_NAME, me->CompTag);
	  FIg_set_text (me->pSysAtt,VCCAT_COMP_CODE, me->CompCode);
	  FIg_set_text (me->pSysAtt,VCCAT_DESC_FIELD, me->CompDesc);

	  FIg_set_text (me->pCtlAtt, VCPCAB_COMPCODE, me->CompCode);
	  FIg_set_text (me->pCtlAtt, VCPCAB_TAGNO, me->CompTag);

	  _put_response( resp = VCL_LINK_SPLIT );
	  *sts = VCL_LINK_SPLIT;
	  goto quit;
      }
  }

  if( me->bSkSplCab && NbLeads )
  {
      om$vla_set_dimension( varray = me->Leads, size = NbLeads );

      if( me->ParSpltEnd == 0 )
	  status = VC$SubCabLeadInfo( p_msg		= &retmsg,
				      gridInputCab	= me->ConnId,
				      p_nBegAvlblLeads	= &NbLeads,
				      p_BegAvlblLds	= me->Leads );
      else
	  status = VC$SubCabLeadInfo( p_msg		= &retmsg,
				      gridInputCab	= me->ConnId,
				      p_nEndAvlblLeads	= &NbLeads,
				      p_EndAvlblLds	= me->Leads );

      for( i=0 ; i<NbLeads ; i++ )
	  __DBGpr_str("Leadname",me->Leads[i].LeadNam);
  }

  nOCP = 1 - nCpt;

  if (me->bGoing)
  {
    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, nOCP, &Oterm),
       targetid = me->ConnId.objid,
       targetos = me->ConnId.osnum);

    if ((Oterm.objid == me->FirstTerm.objid) &&
        (Oterm.osnum == me->FirstTerm.osnum) &&
	(Oterm.objid != NULL_OBJID)) // Added by Anand.
    {
       UI_status("Origin and destination terminal identical");
      _put_response( resp = VC_RTC_ERROR );
      *sts = VC_RTC_ERROR;
      goto quit;
    }
  }
  else
  {
    status =
    om$send(msg = message VCCable.VCCbTerm (&retmsg, nOCP, &me->FirstTerm),
       targetid = me->ConnId.objid,
       targetos = me->ConnId.osnum);
  }

  __DBGpr_int("check free, end",nCpt);

  /*   see if it's free     */

  status =
  om$send(msg = message VCRoot.VCGetTopology
                         (&retmsg, nCpt, &i, &connIds[0], &connCpts[0],
                            NULL, NULL),
     targetid = me->ConnId.objid,
     targetos = me->ConnId.osnum);

  if (i != 0)
  {
    UI_status("Cannot merge with this cable, end not free");
    _put_response( resp = VC_RTC_ERROR );
    *sts = VC_RTC_ERROR;
    goto quit;
  }

  me->otherLnId[nCurMerge].objid = me->ConnId.objid;
  me->otherLnId[nCurMerge].osnum = me->ConnId.osnum;
  me->otherLnMdEnv[nCurMerge]    = me->event1.located_object[0].module_info;

  /*   block merge across ref file boundary    */

  if( (me->otherLnMdEnv[nCurMerge].md_id.objid !=
                                     me->ModuleInfo.md_id.objid) ||
      (me->otherLnMdEnv[nCurMerge].md_id.osnum !=
                                     me->ModuleInfo.md_id.osnum) )
  {
    UI_status("Cannot merge with cable in reference file");
    _put_response( resp = VC_RTC_ERROR );
    *sts = VC_RTC_ERROR;
    goto quit;
  }

#ifdef MY_DEBUG
  printf("otherLnCpt chosen %d \n", nCpt);
#endif
  
  me->otherLnCpt[nCurMerge] = nCpt;

  if (!(me->bGoing))
  { /*A Only for beginning set attributes   */
    /*C Copy attributes including tag number */
#ifdef MY_DEBUG
      printf("Will extend found cable ...to getdata\n");
#endif

    status =
    om$send(msg = message VCCmdCAT.VCATGetData
                                    (&retmsg, &me->otherLnId[nCurMerge]),
       targetid = my_id );
    as$status();

    /*C Update form contents */
    status =
    om$send(msg = message VCCmdCAT.VCATLoadLnAttr
                               (me->pSysAtt, &me->otherLnId[nCurMerge]),
       targetid = my_id );
    as$status();

    me->myMergeCpt[nCurMerge]  = 0;

    FIg_set_text (me->pSysAtt,VCCAT_LINK_NAME, me->CompTag);
    FIg_set_text (me->pSysAtt,VCCAT_COMP_CODE, me->CompCode);
    FIg_set_text (me->pSysAtt,VCCAT_DESC_FIELD, me->CompDesc);

    FIg_set_text (me->pCtlAtt, VCPCAB_COMPCODE, me->CompCode);
    FIg_set_text (me->pCtlAtt, VCPCAB_TAGNO, me->CompTag);

    _put_response( resp = VCL_LINK_ROUTING ); 
    *sts = VCL_LINK_ROUTING;
  }
  else
  {  /*A   for end check if code is compatible   */
    status =
    om$send(msg = message VCRoot.VCGetCode (szCC),
       targetid = me->otherLnId[nCurMerge].objid,
       targetos = me->otherLnId[nCurMerge].osnum);
    as$status();

    if ((szCC[0] != '\0') &&
        (strcmp (szCC, me->CompCode) != 0))
    {
      UI_status("Cannot merge with cable having different comp_code");
      _put_response( resp = VC_RTC_ERROR );
      *sts = VC_RTC_ERROR;
      goto quit;
    }

#ifdef MY_DEBUG
      printf("Will join ...\n");
#endif

    me->myMergeCpt[nCurMerge]  = 1;

    if (me->myMergeCpt[0] == -1)
    { /* Get attributes if it is NOT a double merge   */
      status =
      om$send(msg = message VCCmdCAT.VCATGetData
                                    (&retmsg, &me->otherLnId[nCurMerge]),
         targetid = my_id );
      as$status();

      /*C Update form contents */
      status =
      om$send(msg = message VCCmdCAT.VCATLoadLnAttr
                               (me->pSysAtt, &me->otherLnId[nCurMerge]),
         targetid = my_id );
      as$status();

      FIg_set_text (me->pSysAtt,VCCAT_LINK_NAME, me->CompTag);
      FIg_set_text (me->pSysAtt,VCCAT_COMP_CODE, me->CompCode);

      FIg_set_text (me->pCtlAtt, VCPCAB_COMPCODE, me->CompCode);
      FIg_set_text (me->pCtlAtt, VCPCAB_TAGNO, me->CompTag);
    }

    _put_response( resp = VCL_LINK_JOIN ); 
    *sts = VCL_LINK_JOIN;
  }
    
  status =
  om$send (msg = message VCCmdPC.VCMLAddStrP (dCrd),
      targetid = my_id);

  me->bTagByp        = TRUE;

  /*   reset buttons    */

  FIg_set_value ( me->pCtlAtt, VCPCAB_CONNECT, dSelOff );
  FIg_set_value ( me->pCtlAtt, VCPCAB_DIG, dSelOn );

  quit:
  End;
  return OM_S_SUCCESS;
}


method VCGetLinkAttr ( long * sts )
{
  int               status;
  GRclassid         parentClassId;

  me->ret = VC_RTC_ALLOK;
  status  = OM_S_SUCCESS;

  om$get_classid(objid    = me->ConnId.objid,
                osnum     = me->ConnId.osnum, 
                p_classid = &parentClassId );

  if ( om$is_ancestry_valid (subclassid = parentClassId,
                           superclassid = OPP_VCCable_class_id )
                                                 == OM_S_SUCCESS )
  { /* Update form contents */
    status =
    om$send(msg = message VCCmdPC.VCATLoadLnAttr (me->pSysAtt, &me->ConnId),
       targetid = my_id );
    as$status();
  }

  return OM_S_SUCCESS;
}

method VCGetConn ( long * sts)
{
  int                  status = OM_S_SUCCESS;
  IGRlong              retmsg;
  int                  odestcode;
  double               dSelOff = 0;
  double               dSelOn  = 1;
  IGRboolean           bCreate;

  void  VCCLn_odest ();

  SetProc( VCGetConn ); Begin

  *sts = me->ret = VC_RTC_ALLOK;

  /* if it is a destination connect, check required data FIRST   */

  if( me->bGoing && !me->bSkSplCab )
  {
    status =
    om$send (msg = message VCCmdCAT.VCATcheck (sts),
            mode = OM_e_wrt_message,
        targetid = my_id);

    if (*sts != VC_RTC_ALLOK) goto quit;
  }

  bCreate = TRUE;

  __DBGpr_com( " Calling Fn VCT_virtualize " );
 
  __DBGpr_int( " Ref Module Info md_id.objid ", me->event1.located_object[0].module_info.md_id.objid );
  __DBGpr_int( " Ref Module Info md_id.osnum ", me->event1.located_object[0].module_info.md_id.osnum );
  __DBGpr_mat( " Ref Module Info Matrix ", me->event1.located_object[0].module_info.md_env.matrix );
  __DBGpr_int( " Ref Module Info Matrix_type ", me->event1.located_object[0].module_info.md_env.matrix_type );
 
  __DBGpr_com( " =========================== " );
 
  __DBGpr_int( " Act Module Info md_id.objid ", me->ModuleInfo.md_id.objid );
  __DBGpr_int( " Act Module Info md_id.osnum ", me->ModuleInfo.md_id.osnum );
  __DBGpr_mat( " Act Module Info Matrix ", me->ModuleInfo.md_env.matrix );
  __DBGpr_int( " Act Module Info Matrix_type ", me->ModuleInfo.md_env.matrix_type );

  status =
  VCT_virtualize (&retmsg, bCreate, &me->ConnId, 
                           &me->event1.located_object[0].module_info,
                           &me->ASConnId, &me->ModuleInfo);

  as$status();
  __DBGpr_obj( " Associative Object ", me->ASConnId );

  if (me->bGoing)
  {
    if ((me->ASConnId.objid == me->FirstTerm.objid) &&
        (me->ASConnId.osnum == me->FirstTerm.osnum))
    {
       UI_status("Origin and destination terminal identical");
      _put_response( resp = VC_RTC_ERROR );
      *sts = VC_RTC_ERROR;
      goto quit;
    }
  }
  else
  {
    me->FirstTerm.objid = me->ASConnId.objid;
    me->FirstTerm.osnum = me->ASConnId.osnum;
    __DBGpr_obj( " 1 Associative Object ", me->ASConnId );
  }

#ifdef MY_DEBUG
  printf (" GetConnect <%d %d>\n",me->ConnId.objid,me->ConnId.osnum);
  printf (" AS_Connect <%d %d>\n",me->ASConnId.objid,me->ASConnId.osnum);
#endif

  /* reset control form     */

  FIg_set_value ( me->pCtlAtt, VCPCAB_CONNECT, dSelOff );
  FIg_set_value ( me->pCtlAtt, VCPCAB_DIG, dSelOn );

  if( me->bGoing)   odestcode = 0;
  else              odestcode = 1;

  VCCLn_odest (me->pSysAtt, odestcode, &me->ConnId, &me->ModuleInfo);

  /* Set response */

  FIfld_set_text( me->pSysAtt, VCCAT_MSG, 0, 0, "", FALSE);

  quit:
  End
  return OM_S_SUCCESS;
}


method VCGetAssocPoint ( long * sts)
{
  int                 status = OM_S_SUCCESS;
  IGRlong             retmsg;
  IGRint              Partyp;
  GRclassid           Cltyp;
  IGRshort            nCP;
  IGRshort            nDdig;
  IGRdouble           d3pt[3];

  struct ret_struct   VertexSt;

  me->ret = VC_RTC_ALLOK;

  nCP     = 0;
  nDdig   = -1;

  om$get_classid (objid = me->ConnId.objid,
                  osnum = me->ConnId.osnum,
              p_classid = &Cltyp);

  if ( om$is_ancestry_valid (subclassid = Cltyp,
                           superclassid = OPP_VCTerm_class_id )
                                      == OM_S_SUCCESS)
  {
    Partyp = VCC_TERM_PULL;

    /*A ---- If required, change it into an associative root ------ */
    /*A ---- In equipment or ref file ?????                         */
    /*A @@@@@@@@@@@@@@@  CHECK THIS OUT @@@@@@@@@@@@@@@@@@@@@@@@@@@ */

    status =
    as$make_source( go_grid      = me->ConnId,
                    mod_env      = &me->event1.located_object[0].module_info,
                    as_os        = me->ModuleInfo.md_id.osnum,
                    as_grid      = &me->ASConnId );
    as$status();

    status =
    om$send (msg = message VCRoot.VCGetCptCoord
                                   (&retmsg, nCP, d3pt, &me->ModuleInfo),
        targetid = me->ConnId.objid,
        targetos = me->ConnId.osnum);
    as$status();
  }
  else
  {
    Partyp = VCC_POINT_PARENT;  /*   switch to POINT_EXTERN when ready   */
  
    /*A ---- If required, change it into an associative root ------ */

    status =
    as$make_source( go_grid      = me->ConnId,
                    mod_env      = &me->event1.located_object[0].module_info,
                    as_os        = me->ModuleInfo.md_id.osnum,
                    as_grid      = &me->ASConnId );
    as$status();

    /*C Get parent's description */
    status =
    om$send (msg = message NDnode.NDgive_structure
                                          (&retmsg, &VertexSt, &me->ModuleInfo),
        targetid = me->ASConnId.objid,
        targetos = me->ASConnId.osnum);
    as$status();

    if (VertexSt.type & point_generic)
    {   /*C point's coordinates */
      d3pt[0] = VertexSt.var.point_st.pt[0];
      d3pt[1] = VertexSt.var.point_st.pt[1];
      d3pt[2] = VertexSt.var.point_st.pt[2];
    }
    else
    if (VertexSt.type & macro_generic)
    {   /*C Get from a complex object its foot "ref" */
      IGRint     Index = -1;

      status =
      om$send (msg = message ACncpx.ACgive_structure
                  ((IGRint *) &retmsg, &Index, VC_N_REF_CS, &VertexSt,
                              &me->ModuleInfo),
          targetid = me->ASConnId.objid,
          targetos = me->ASConnId.osnum);
      as$status();

      d3pt[0] = VertexSt.var.ref_st.t[3];
      d3pt[1] = VertexSt.var.ref_st.t[7];
      d3pt[2] = VertexSt.var.ref_st.t[11];
    }
    else
    if (VertexSt.type & ref_generic)
    {   /*C origin of the cs */
      d3pt[0] = VertexSt.var.ref_st.t[3];
      d3pt[1] = VertexSt.var.ref_st.t[7];
      d3pt[2] = VertexSt.var.ref_st.t[11];
    }
    else
    {   /*C What kind of point source ???? */
      printf ("Unknown type of parent\n");
      return (OM_S_SUCCESS);
    }
  }

  status =
  om$send (msg = message VCCmdPC.VCMLAddPath
                         (Partyp, me->nLdig, d3pt, d3pt, nCP, nCP,
                          nDdig, &me->ASConnId),
      targetid = my_id);

  /*   exit point if NOT continuous string (POINT_EMBED)   */
  /* Dunno what the above comment means, but am commenting the below if
   * condition. Appears to cause some confusing dynamics - Anand */
//  if (Partyp == VCC_POINT_PARENT)
  {
    status =
    om$send (msg = message VCCmdPC.VCMLAddStrP (d3pt),
        targetid = my_id);
  }

  /* FROM FORM */
  status =
  om$send( msg = message VCCmdPC.VCGetNextPointType( sts ),
      targetid = my_id );
  as$status( action = RET_STATUS );

  return OM_S_SUCCESS;
}


method VCGetConduit ( long * sts)
{
  int                 status = OM_S_SUCCESS;
  IGRlong             retmsg;
  IGRshort            iend[2];
  IGRdouble           d3pt[3];
  IGRdouble           dBcoord[3];
  IGRdouble           dEcoord[3];
  IGRdouble           dBvtx[3];
  IGRdouble           dEvtx[3];
  IGRdouble           dDumm[3];
  IGRint              i;
  IGRint              ICbeg, ICend;
  IGRboolean          bFree;
  IGRshort            nDIG;

  double              dSelOff = 0;
  double              dSelOn  = 1;

  IGRdouble BSdistptpt();

  me->ret = VC_RTC_ALLOK;

  dDumm[0] = dDumm[1] = dDumm[2] = 0.0;

#ifdef MY_DEBUG
  printf (" Conduit - current index %d\n",me->nMyPnts);
#endif

  if (me->bGoing)
  {
    for( i = 0; i < 3; i++ )
      d3pt[i]   = me->dLAST[i];
  }
  else
  {
    for( i = 0; i < 3; i++ )
      d3pt[i]   = me->dIncrd[i];
  }

#ifdef MY_DEBUG
  printf (" last vertex %f %f %f \n",d3pt[0], d3pt[1], d3pt[2]);
#endif

/*---------------------------------------------------------------*/

  /*A ---- If required, change it into an associative root ------ */

  status =
  as$make_source( go_grid      = me->ConnId,
                  mod_env      = &me->event1.located_object[0].module_info,
                  as_os        = me->ModuleInfo.md_id.osnum,
                  as_grid      = &me->ASConnId);
  as$status();

  status =
  om$send(msg = message VCRoot.VCSelectCpt
                        (&retmsg, d3pt, &iend[0], dBcoord, dBvtx, &bFree,
                         &me->ModuleInfo),
     targetid = me->ConnId.objid,
     targetos = me->ConnId.osnum);
  as$status();

  iend[1] = 1 - iend[0];

#ifdef MY_DEBUG
  printf ("selected ends %d %d\n", iend[0], iend[1]);
  printf (" entry vertex %f %f %f \n",dBcoord[0], dBcoord[1], dBcoord[2]);
#endif

  status =
  om$send(msg = message VCRoot.VCGetCptGeom
                        (&retmsg, iend[1], dEcoord, dEvtx, NULL, &bFree,
                         &me->ModuleInfo),
     targetid = me->ConnId.objid,
     targetos = me->ConnId.osnum);
  as$status();

#ifdef MY_DEBUG
  printf (" exit vertex %f %f %f \n",dEcoord[0], dEcoord[1], dEcoord[2]);
#endif

  if (iend[0] > iend[1])
  {
    ICbeg = 1;
    ICend = 0;
  }
  else
  {
    ICbeg = 0;
    ICend = 1;
  }

  nDIG = VC_digit (dEvtx, dDumm);

  status =
  om$send (msg = message VCCmdPC.VCMLAddPath
                         (VCC_GUIDE_PARENT, me->nLdig, dBcoord, dEcoord,
                          ICbeg, ICend, nDIG, &me->ASConnId),
      targetid = my_id);

  status =
  om$send (msg = message VCCmdPC.VCMLAddStrP (dEcoord),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" thru conduit from %d to %d\n",ICbeg,ICend);
#endif

  /* one-shot attach   */

  FIg_set_value ( me->pCtlAtt, VCPCAB_ATTACH, dSelOff );
  FIg_set_value ( me->pCtlAtt, VCPCAB_DIG, dSelOn );

  _put_response( resp = VCL_LINK_FREE_POINT );
  *sts = VCL_LINK_FREE_POINT;

  quit:
  return OM_S_SUCCESS;
}

end implementation VCCmdPC;
