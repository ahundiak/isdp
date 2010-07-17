
/* $Id: VCMLMisc.I,v 1.4 2002/05/29 20:25:43 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCMLMisc.I
 *
 * Description:
 *      Implementation file for place cable command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMLMisc.I,v $
 *  Revision 1.4  2002/05/29 20:25:43  anand
 *  Third set of bug fixes for the split cable functionality.
 *  Merge does not corrupt the model. The marker information is
 *  now propagated to newly sketched cables/sub-cables. Changed
 *  interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *  Revision 1.3  2002/05/24 21:41:49  anand
 *  Second set of bug fixes for the cable lead enhancement.
 *  Fixes errors in model arising out of merge-cable workflows.
 *  Ensure placeholders are created for markers for DB driven
 *  cables. Major shuffling of code in Sketch cable state table.
 *
 *  Revision 1.2  2001/02/20 01:09:56  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/26  20:21:52  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by kddinov for route
#
# Revision 1.4  1998/03/06  08:31:52  pinnacle
# Replaced: vccmd/VCMLMisc.I for: TR 179800044 by aharihar for route
#
# Revision 1.3  1997/12/03  16:59:52  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by r250_int for route
#
# Revision 1.11  1997/12/02  08:33:46  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by apazhani for cabling
#
# Revision 1.10  1997/05/23  13:13:30  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by hverstee for cabling
#
# Revision 1.9  1997/05/07  14:19:26  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by hverstee for cabling
#
# Revision 1.8  1997/04/28  22:31:04  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by hverstee for cabling
#
# Revision 1.7  1997/01/09  23:05:58  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/09  19:58:34  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by hverstee for cabling
#
# Revision 1.4  1996/11/15  22:27:38  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:21:24  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:36:14  pinnacle
# Replaced: vccmd/VCMLMisc.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:22:10  pinnacle
# Created: vccmd/VCMLMisc.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  12/02/97      Alwin   Modified method VCADDCPT, for TR179701610
 *  Mar 6 98      Anand   Target object for VCSelectCpt in method VCGetCPT 
 *  			  was changed to ConnId from ASConnId. (TR 179800044)
 *  4-98 	KDD	use located object environment for VCRoot.VCSelectCpt
 *			and VCP.VCP_addpt
 *
 *************************************************************************/

/*          METHODS

           VCMergeLink              
                                        */

class implementation VCCmdPC;

/*
#define MY_DEBUG 	1
#define vdsDEBUG	1 
*/

#include "VDmem.h"
#include "vrdbgmacros.h"

/***********  EXTERN ***********/

from  VCCable   import   VCCbMerge;
from  VCRoot    import   VCSelectCpt;
from  VCP       import   VCP_addpt;



method VCMergeLink ( long * sts ;
                     int    iMerge)
{
  int          status;
  IGRshort     nLocCpt;
  IGRlong      retmsg;

  me->ret = VC_RTC_ALLOK;
  
#ifdef MY_DEBUG 
  printf("entering merge link %d\n", iMerge);
#endif

  /*A JOIN Links */

  /*NOTE: if two subsequent merges occur then the first REVERSES my
          primary, so reverse the connectpoint number..........     */

  nLocCpt = me->myMergeCpt[iMerge];

  if ((iMerge == 1) && (me->myMergeCpt[0] >= 0)  && (me->myMergeCpt[1] >= 0))
    nLocCpt = 1 - nLocCpt;

  status = 
  om$send(msg   = message VCCable.VCCbMerge(&retmsg, nLocCpt,
                               &me->otherLnId[iMerge], me->otherLnCpt[iMerge],
                               &me->ModuleInfo),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

#ifdef MY_DEBUG
  printf("MERGE %d done ", iMerge);
  if (retmsg == MSSUCC)
    printf (" OK\n");
  else
    printf (" retmsg = %d\n",retmsg);
#endif

  as$status( action = RET_STATUS );

  return OM_S_SUCCESS;
}


method VCCleanup ( long * sts )
{
  IGRint       status;

  extern
  int          GRstatus_display_button();

  me->nRWtr = 0;
  _FREE (me->RWTrac);

  status = GRstatus_display_button (0);

  status =
  om$send (msg = message VCCmdCAT.VCATExit (sts),
      targetid = my_id);

  return OM_S_SUCCESS;
}

method VCGetCPT ( long * sts )
{
  IGRint       status;
  IGRlong      retmsg;
  IGRdouble    d3pt[3];
  IGRdouble    dinpt[3];
  IGRboolean   bFree;
  IGRshort     nCP;

SetProc( VCCmdPC_VCGetCPT); Begin

  dinpt[0] = me->dIncrd[0];
  dinpt[1] = me->dIncrd[1];
  dinpt[2] = me->dIncrd[2];

__DBGpr_vec("Input point        ", dinpt);

/*----------------------
* 4-98 KDD 179800044, Module environment is the one from the located object 
* This is OK with reference files 
*----------------------*/
  me->CATenv = me->event1.located_object[0].module_info;

  status = om$send( msg      = message VCRoot.VCSelectCpt
                                  (&retmsg, dinpt, &nCP, d3pt, NULL, &bFree,
                     		  &me->event1.located_object[0].module_info),
                    targetid = me->ConnId.objid,
                    targetos = me->ConnId.osnum);

/* The target object for this method was originally ASConnId. Changed to ConnId
   by Anand for TR 179800044 */

__DBGpr_int("Output status&msg  ", (status & retmsg) );
__DBGpr_vec("Output point       ", d3pt);
__DBGpr_int("Output point num   ", nCP);
__DBGpr_int("Output point Free  ", bFree);
__DBGpr_obj("Associative parent ", me->ASConnId);
__DBGpr_obj("Located Element    ", me->ConnId);


#ifdef MY_DEBUG
  printf ("select CPT %d - %f %f %f\n",nCP, d3pt[0], d3pt[1], d3pt[2]);
#endif

  if (me->bBegCP)
  {
    *sts = VCL_LINK_FREE_POINT;

    status =
    om$send (msg = message VCCmdPC.VCMLAddNode
                            (VCC_TERM_PARENT, d3pt, d3pt,
                             nCP, nCP,  &me->ASConnId),
        targetid = my_id);

    status =
    om$send (msg = message VCCmdPC.VCMLAddStrP (d3pt),
        targetid = my_id);

  }
  else
  {
    *sts = VCL_LINK_ENDED;

    status =
    om$send (msg = message VCCmdPC.VCMLAddPath
                             (VCC_TERM_PARENT, me->nLdig, d3pt, d3pt, nCP, nCP,
                              me->nDdig, &me->ASConnId),
        targetid = my_id);
  }

  _put_response( resp = *sts);

  quit:
End;
  return OM_S_SUCCESS;
}


method VCAddCPT ( long * sts )
{
  IGRint       status;
  IGRlong      retmsg;
  IGRdouble    d3pt[3];
  IGRshort     nCP;

  SetProc( VCAddCPT ); Begin

  d3pt[0] = me->event1.event.button.x;
  d3pt[1] = me->event1.event.button.y;
  d3pt[2] = me->event1.event.button.z;

  __DBGpr_vec( " Dynamic Point specified ", d3pt );

  /*****************************************************************************
  commenting this portion of the code, for TR179701610. Alwin

  __DBGpr_obj( " Object for which Cpt Info being set is ", me->ASConnId );
 
  status =
  om$send (msg = message VCP.VCP_addpt
                    (&retmsg, d3pt, NULL, &me->ModuleInfo, &nCP),
      targetid = me->ASConnId.objid,
      targetos = me->ASConnId.osnum);
  *****************************************************************************/
 
  /* *************************************************************************
   * Previously, for adding the Connect Point details into the Connect Point
   * Manager, we were using the "Assoc. Graphic Object Id". This has a drawback
   * loop hole in it, when it comes to Reference files. When we try to retreive
   * this information from the Object( Terminal ) in most of the places we're
   * not sending the correct object id( i.e we're sending the actual object id
   * instead of the Assoc. Graphic Object Id ). As a reslut it has been decided
   * from now on we'll set the connect point detailes directly to the Located
   * object itself. This proble won't occur for the Terminals in the Active file
   * b'cas in that case me->ASConnId = me->ConnId.
   * Alwin for TR179701610.
   ****************************************************************************/
 
  __DBGpr_obj( " Object for which Cpt Info being set is ", me->ConnId );

  me->CATenv = me->event1.located_object[0].module_info;

/* 4-98 KDD modified to handle reference file environments */

  status = om$send (msg = message VCP.VCP_addpt (&retmsg, d3pt, NULL, 
	         	      &me->event1.located_object[0].module_info, &nCP),
               targetid = me->ConnId.objid,
               targetos = me->ConnId.osnum);

__DBGpr_obj("located object ", me->event1.located_object[0].located_obj);
__DBGpr_obj("me->ConnId     ", me->ConnId);
__DBGpr_obj("me->ASConnId   ", me->ASConnId);
__DBGpr_mat("located_object matrix ", 
		me->event1.located_object[0].module_info.md_env.matrix);

__DBGpr_vec("click point ", d3pt);


#ifdef MY_DEBUG
  printf ("add new CPT %d\n",nCP);
#endif


  if (me->bBegCP)
  {
    *sts = VCL_LINK_FREE_POINT;

    status =
    om$send (msg = message VCCmdPC.VCMLAddNode
                            (VCC_TERM_PARENT, d3pt, d3pt,
                             nCP, nCP,  &me->ASConnId),
        targetid = my_id);

    status =
    om$send (msg = message VCCmdPC.VCMLAddStrP (d3pt),
        targetid = my_id);
  }
  else
  {
    *sts = VCL_LINK_ENDED;

    status =
    om$send (msg = message VCCmdPC.VCMLAddPath
                             (VCC_TERM_PARENT, me->nLdig, d3pt, d3pt, nCP, nCP,
                              me->nDdig, &me->ASConnId),
        targetid = my_id);
  }

  _put_response( resp = *sts);

  quit:
  End
  return OM_S_SUCCESS;
}

end implementation VCCmdPC;
