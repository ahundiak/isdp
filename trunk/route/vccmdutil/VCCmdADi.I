/* $Id: VCCmdADi.I,v 1.5 2002/01/30 18:01:31 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdADi.I
 *
 * Description:
 *      Command object for attach/detach cable
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdADi.I,v $
 *        Revision 1.5  2002/01/30 18:01:31  anand
 *        No TR.
 *
 *        Revision 1.4  2002/01/03 15:56:29  anand
 *        *** empty log message ***
 *
 *        Revision 1.3  2001/12/20 00:13:00  anand
 *        No TR. No priority. Problem never observed by support or
 *        customer. A "would-be-nice" fix.
 *
 *        Revision 1.2  2001/02/20 01:10:22  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.3  1998/11/13  16:02:12  pinnacle
# File checked in for sbilla
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/02  22:09:32  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.10  1997/10/06  16:44:12  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by apazhani for cabling
#
# Revision 1.9  1997/08/28  15:54:14  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by apazhani for cabling
#
# Revision 1.8  1997/07/22  15:23:46  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/07  16:18:02  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by hverstee for cabling
#
# Revision 1.6  1997/03/12  22:25:56  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/01/31  18:09:36  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/16  14:54:14  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/21  21:33:52  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/25  19:13:18  pinnacle
# Replaced: vccmdutil/VCCmdADi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/10/15  19:35:20  pinnacle
# Created: vccmdutil/VCCmdADi.I by hverstee for cabling
#
 *
 * History:
 *
 *	07/10/96	hv	Initial
 *
 *	08/28/97	Alwin	While detaching the terminal connected to
 *				the Equipment, should return the Virtual
 *				Terminals ID. Previously it was sending 
 *				ACpretend Id, because of which Virtual
 *				terminal retains its connection with the 
 *				Cable  connected to it. TR179701607
 *
 *	09/25/97	Alwin	Implemented the method VCADMoAttVertex.
 *
 *	4/98		kdd	locate_eligible attach to the guide itself
 *
 *	10/14/98	Alwin	Checked the selection of Correction
 *				components in the case of Raceway Guides.
 *				for TR179801971.
 *
 *	11/10/98	Reddy	TR179802305 - Cable is made to detach from 
 *				terminal and point. A piece of code in
 *				VCADProcess is moved into the Raceway case of
 *				th same method.
 *
 *	12/19/01	Anand	No TR. Choosing specific vertex of a cable from
 *				the 'attach cable to terminal' command was
 *				causing problems.
 *
 *	 1/30/02	Anand	No TR. Ensure proper argument to VCCbAttPoint
 *				so that correct value is set for section type
 *				for an intermediate (dummy) terminal.
 *
 *************************************************************************/

class implementation VCCmdAD;

#include <stdio.h>
#include <float.h>

#include "FI.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMtypes.h"
#include "ODE.h"

#include "igetypedef.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "grio.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "bsvalues.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"

#include "asmacros.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "parametric.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCparameters.h"
#include "VCproto.h"

#include "VDmem.h"

#include "bsdistptpt.h"
#include "vrdbgmacros.h"
#include "VRcompdef.h"


from  VRGeneric         import  VRGetOrigCoor;
from  NDnode            import  NDgive_structure;
from  GRgraphics        import  GRdisplay;

extern GRclassid   OPP_VCGuide_class_id;
extern GRclassid   OPP_VCCable_class_id;
extern GRclassid   OPP_VCTerm_class_id;
extern GRclassid   OPP_VRRway_class_id;
extern GRclassid   OPP_GRpoint_class_id;

from  VCRoot     import   VCSelectCpt, VCGetMatrix;

from  VCCable    import   VCCbAttGuide, VCCbModify;
from  VCCable    import   VCCbAttRway;
from  VCCable    import   VCCbAttPoint;
from  VCCable    import   VCCbDetach;

from  VCCable    import   VCCbFind;

from  IGEgragad import   DPinrot;
from  VRGeneric import   VRGetStatus;

method init ( int type ; char * str_ptr )
{
  int      status;

SetProc(VCCmdAD_init); Begin

  /*A Initialize my instance data -- */

  /*A send the parent's init message wrt message */
  status =
  om$send( msg = message VDS_LOCATE.init ( type, str_ptr ),
          mode = OM_e_wrt_message,
      targetid = my_id);
  as$status( action = RET_STATUS );

  me->RefId.objid = me->CabId.objid = NULL_OBJID;
  me->Vtx1        = me->Vtx2        = -1;
  me->MyType      = type;
  me->LocType     = -1;
  me->nRWtr       = 0;

  me->RWTrac      = NULL;

  me->LineIn.points = NULL;

#ifdef MY_DEBUG
  printf (" init\n");
#endif

End
  return OM_S_SUCCESS;
}


method VCADReset ( long * sts )
{
  IGRlong    retmsg;

SetProc(VCCmdAD_VCADReset); Begin

  me->RefId.objid = me->CabId.objid = NULL_OBJID;
  me->Vtx1        = me->Vtx2        = -1;
  me->LocType     = -1;

  _FREE (me->LineIn.points);
  _FREE (me->RWTrac);

  me->nRWtr       = 0;
  me->RWTrac      = NULL;
  me->LineIn.points = NULL;

  dp$erase_hilite (msg = &retmsg);

#ifdef MY_DEBUG
  printf (" reset\n");
#endif

End
  return OM_S_SUCCESS;
}

method VCADDel ( long * sts )
{
  IGRlong    retmsg;

SetProc(VCCmdAD_VCADDel); Begin

  me->RefId.objid = me->CabId.objid = NULL_OBJID;
  me->Vtx1        = me->Vtx2        = -1;
  me->LocType     = -1;

  dp$erase_hilite (msg = &retmsg);

#ifdef MY_DEBUG
  printf (" reset\n");
#endif

End
  return OM_S_SUCCESS;
}

method VCADGetFather ( long * sts )
{
  int              status;
  GRclassid        MyClassId;

SetProc(VCCmdAD_VCADGetFather); Begin

  *sts = VC_RTC_ERROR;

  /*A get the located object */
  me->RefId = me->event1.located_object[0].located_obj;

  /*A get located element class id   */
  status =
  om$get_classid (objid      = me->RefId.objid,
                  osnum      = me->RefId.osnum,
                  p_classid  = &MyClassId   );

  if (om$is_ancestry_valid
         (subclassid = MyClassId,
        superclassid = OPP_GRpoint_class_id) == OM_S_SUCCESS)
  {
      me->LocType = 2;
  }
  else
  if (om$is_ancestry_valid
         (subclassid = MyClassId,
        superclassid = OPP_VCTerm_class_id) == OM_S_SUCCESS)
  {
      me->LocType = 4;
  }
  else
  if (om$is_ancestry_valid
         (subclassid = MyClassId,
        superclassid = OPP_VCGuide_class_id) == OM_S_SUCCESS)
  {
      me->LocType = 1;
  }
  else
  if (om$is_ancestry_valid
         (subclassid = MyClassId,
        superclassid = OPP_VRRway_class_id) == OM_S_SUCCESS)
  {   /* other than guide == raceway???   */
      IGRshort StatusValue;
      IGRlong retmsg;

      me->LocType = 3;

      /* Get the status of the Component to check whether its a correction
      or not. If its a correction component then revert back saying its a bad
      located component. Alwin for TR179801971 */
      status =
      om$send ( msg = message VRGeneric.VRGetStatus ( &retmsg, &StatusValue ),
                targetid = me->RefId.objid,
                targetos = me->RefId.osnum );

      if( StatusValue & VR_CORRECTION )
      {
         UI_status( "Bad Located component :-( " );
         *sts = VC_RTC_ERROR;
         _put_response( resp = VC_RTC_ERROR );
         End
         return( OM_S_SUCCESS  );
      }
  }

  if( me->LocType == 4 )
  {
   /* Call the VCT_virtualize, in the case of Terminal */
      IGRboolean bCreate;
      IGRlong retmsg;

      bCreate = TRUE;

      status =
      VCT_virtualize (&retmsg, bCreate, 
                      &me->RefId, &me->event1.located_object[0].module_info,
                      &me->AssId, &me->ModuleInfo);

      /*In the case of Terminal connected to Equipment (especially embedded)
        then VCT_virtualize will return, object Id of the Virtual Terminal to
        disconnect or else we can carry on with the Located Terminal Id itself
        --Alwin for TR179701607 */
      
      if( me->AssId.objid == NULL_OBJID ) me->AssId = me->RefId;
  }
  else {

      status =
      as$make_source( go_grid  = me->RefId,
                      mod_env  = &me->event1.located_object[0].module_info,
                      as_os    = me->ModuleInfo.md_id.osnum,
                      as_grid  = &me->AssId);
      as$status();
  }

  if ((me->LocType == 2) || (me->LocType == 4))
  {
    _put_response (resp = VC_RTC_SINGLE);
    *sts = VC_RTC_SINGLE;
    goto quit;
  }

  if (me->LocType == 3)
  {
    IGRlong             retmsg;
    struct GRid         OtherEnd;
    IGRboolean          bBRANCH;

    OtherEnd.objid = NULL_OBJID;

    status =
    VR$Tracer (p_msg      = &retmsg,
               p_comp     = &me->RefId,
               numout     = &me->nRWtr,
               Tracetab   = &me->RWTrac,
               p_Branched = &bBRANCH,
               p_mdenv    = &me->ModuleInfo);

    if (bBRANCH)
    {    /*   it branches, get next pick before fill   */
      _put_response( resp = VC_RTC_RWEND);
      *sts = VC_RTC_RWEND;
#ifdef MY_DEBUG
      printf (" branch found, get endpoint\n");
#endif
      goto quit;
    }
    else
    {
      status =
      om$send (msg = message VCCmdAD.VCADRWfill (sts),
          targetid = my_id);
    }
  }

  *sts = OM_S_SUCCESS;

  quit:
#ifdef MY_DEBUG
  printf (" classid = %d\n",MyClassId);
  printf (" get conduit %d %d\n",me->RefId.objid,me->RefId.osnum);
  printf (" Loctype %d sts=%d\n",me->LocType,*sts);
#endif
End
  return OM_S_SUCCESS;
}

/*     raceway other end     */

method VCADGetARW ( long * sts)
{
  int                 status;
  IGRshort            StatusValue;
  IGRlong             retmsg;
  IGRint              i;
  IGRshort            nConEnd;
  IGRboolean          bBRANCH;
  IGRboolean          bPATH;

  struct GRid         OtherEnd;
  struct VR_tracerec *LTrac=NULL;

SetProc(VCCmdAD_VCADGetARW); Begin

#ifdef MY_DEBUG
  printf ("get raceway second pick\n");
#endif

  me->ret = VC_RTC_ALLOK;
  LTrac   = me->RWTrac;
  bPATH   = TRUE;
  nConEnd = 1;

  /*A ----- Get located object ----- */
  OtherEnd = me->event1.located_object[0].located_obj;

  /* Get the status of the Component to check whether its a correction
  or not. If its a correction component then revert back saying its a bad
  located component. Alwin */
  status =
  om$send ( msg = message VRGeneric.VRGetStatus ( &retmsg, &StatusValue ),
            targetid = OtherEnd.objid,
            targetos = OtherEnd.osnum );

  if( StatusValue & VR_CORRECTION )
  {
     UI_status( "Bad Located component :-( " );
     *sts = VC_RTC_ERROR;
     _put_response( resp = VC_RTC_ERROR );
     End
     return( OM_S_SUCCESS );
  }

  for (i=0; i<me->nRWtr; i++)
  {
    if (OtherEnd.objid == LTrac[i].Comp.objid) goto ALLOK;
  }

  _put_response( resp = VC_RTC_ERROR);
  *sts = VC_RTC_ERROR;
  goto quit;

  ALLOK:

  me->nRWtr = 0;
  _FREE (me->RWTrac);

#ifdef MY_DEBUG
  printf ("regenerate trace\n");
#endif

  status =
  VR$Tracer (p_msg      = &retmsg,
             b_path     = bPATH,
             p_comp     = &me->RefId,
             numends    = nConEnd,
             p_ends     = &OtherEnd,
             numout     = &me->nRWtr,
             Tracetab   = &me->RWTrac,
             p_Branched = &bBRANCH,
             p_mdenv    = &me->ModuleInfo);

  __DBGpr_com( " Calling the Md VCADRWfill ... " );
  status =
  om$send (msg = message VCCmdAD.VCADRWfill (sts),
      targetid = my_id);

  __DBGpr_int( " Nb of Components selected ", me->nRWtr );

  /* Previously the After executing the above method, it used to free the 
  memory. It shouldn't be freed. Better play carefully with pointers.
  Alwin for TR179801971 */

  __DBGpr_com( " Safe exit " );
  End
  return OM_S_SUCCESS;

  quit:
  __DBGpr_com( " something went wrong " );
  me->nRWtr = 0;
  _FREE (me->RWTrac);
End
  return OM_S_SUCCESS;
}


method VCADRWfill ( long * sts)
{
  IGRint              status;
  IGRlong             retmsg;
  int                 i;

  struct GRid         disp_info;
  enum GRdpmode       dpmode;
  struct VR_tracerec *LTrac=NULL;

SetProc(VCCmdAD_VCADRWfill); Begin

  me->ret = VC_RTC_ALLOK;
  LTrac   = me->RWTrac;

  GRfindmod (&disp_info);
  dpmode = GRhd;
  me->AltEnv = me->event1.located_object[0].module_info;

  for (i=0; i<me->nRWtr; i++)
  {
    /*A ---- If required, change it into an associative root ------ */
/* @@@@@@@@@
    status =
    as$make_source( go_grid      = LTrac[i].Comp,
                    mod_env      = &me->event1.located_object[0].module_info,
                    as_os        = me->ModuleInfo.md_id.osnum,
                    as_grid      = &LTrac[i].Comp);
    as$status();
@@@@@@@@@@@ */

#ifdef MY_DEBUG
    printf (" TRACE.. <%d %d> and <%d %d> ends %d %d\n",
                      LTrac[i].Corr.objid, LTrac[i].Corr.osnum,
                      LTrac[i].Comp.objid, LTrac[i].Comp.osnum,
                       LTrac[i].nCPfrom, LTrac[i].nCPto);
#endif

    /*    highlight trace    */

    if (LTrac[i].Corr.objid != NULL_OBJID)
    {  /*   correction fields may be empty   */
      status =
      om$send (msg = message GRgraphics.GRdisplay
                                 (&retmsg, &me->AltEnv.md_env.matrix_type,
                                  me->AltEnv.md_env.matrix,
                                  &dpmode, &disp_info),
          targetid = LTrac[i].Corr.objid,
          targetos = LTrac[i].Corr.osnum,
          senderid = NULL_OBJID);
      as$status ();
    }

    status =
    om$send (msg = message GRgraphics.GRdisplay
                                 (&retmsg, &me->AltEnv.md_env.matrix_type,
                                  me->AltEnv.md_env.matrix,
                                  &dpmode, &disp_info),
        targetid = LTrac[i].Comp.objid,
        targetos = LTrac[i].Comp.osnum,
        senderid = NULL_OBJID);
    as$status ();
  }

End
  return OM_S_SUCCESS;
}

method VCADGetCable ( long * sts )
{
  IGRlong               status;
  GRclassid             MyClassId;
  IGRint                IXloc;
  IGRint                i;
  IGRint                EP;
  IGRint                Adj;
  IGRlong               retmsg;
  IGRmatrix             win_matrix;

SetProc(VCCmdAD_VCADGetCable); Begin

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  /*A get the located object */
  me->CabId = me->event1.located_object[0].located_obj;

__DBGpr_obj("Located cable ", me->CabId); 

#ifdef MY_DEBUG
  printf (" get cable %d %d\n",me->CabId.objid,me->CabId.osnum);
#endif

  /*A get located element class id   */
/*----------------------
* 3-98 KDD locate_eligible does that for us
*  status =
*  om$get_classid (
*      objid      = me->CabId.objid,
*      osnum      = me->CabId.osnum,
*      p_classid  = &MyClassId   );
*
*  if (om$is_ancestry_valid (subclassid  =MyClassId,
*                            superclassid=OPP_VCCable_class_id) == OM_S_SUCCESS)
*         *sts = OM_S_SUCCESS;
  else
*         *sts = VC_RTC_ERROR;
*-------------------------*/

  /*A get the location    */

  me->dCVtx1[0] = me->dCVtx2[0] = me->event1.event.button.x;
  me->dCVtx1[1] = me->dCVtx2[1] = me->event1.event.button.y;
  me->dCVtx1[2] = me->dCVtx2[2] = me->event1.event.button.z;
  me->bSecGiven = FALSE;
  me->bReverse  = FALSE;

  /*    get window....   */
  IXloc = -1;

  status =
  om$send (msg = message IGEgragad.DPinrot( &retmsg, win_matrix ),
      senderid = NULL_OBJID,
      targetid = me->event1.event.button.objid,
      targetos = me->event1.event.button.osnum);
  as$status();

__DBGpr_mat("Window matrix ", win_matrix); 

  for (i=0; i<3; i++)
    if ((win_matrix[i+8] > 0.99) ||
        (win_matrix[i+8] < -0.99))    IXloc = i;

__DBGpr_int("IXloc               ", IXloc); 

  /*    get vertex and section   */
  {
    IGRdouble  dDyn[12];

__DBGpr_vec("dCVtx1 coordinates  ", me->dCVtx1); 

    status =
    om$send (msg = message VCCable.VCCbFind
                       (&retmsg, VCCB_MOV_VERTEX, &Adj, &me->SectNo, &me->Vtx1,
                        me->dCVtx1, IXloc, dDyn, &EP, &me->ModuleInfo),
        targetid = me->CabId.objid,
        targetos = me->CabId.osnum);
    as$status();
  }

__DBGpr_int("Vertex Vtx1  ", me->Vtx1);
__DBGpr_int("Vertex Vtx2  ", me->Vtx2);

  me->Vtx2 = me->Vtx1;

End
  return OM_S_SUCCESS;
}

method VCADGetVtx2 ( long * sts )
{
  int              status;
  IGRint           IXloc;
  IGRint           Lsec;
  IGRlong          retmsg;
  IGRint           EP;
  IGRint           Adj;
  IGRint           i;
  IGRmatrix        win_matrix;

SetProc(VCCmdAD_VCADGetVtx2); Begin

  *sts = OM_S_SUCCESS;

  /*A get the location    */

  me->dCVtx2[0] = me->event1.event.button.x;
  me->dCVtx2[1] = me->event1.event.button.y;
  me->dCVtx2[2] = me->event1.event.button.z;
  me->bSecGiven = TRUE;

#ifdef MY_DEBUG
  printf (" get vtx2\n");
#endif

  /*    get window....   */
  IXloc = -1;

  status =
  om$send (msg = message IGEgragad.DPinrot( &retmsg, win_matrix ),
      senderid = NULL_OBJID,
      targetid = me->event1.event.button.objid,
      targetos = me->event1.event.button.osnum);
  as$status();

  for (i=0; i<3; i++)
    if ((win_matrix[i+8] > 0.99) ||
        (win_matrix[i+8] < -0.99))    IXloc = i;

  /*    get vertex and section   */
  status =
  om$send (msg = message VCCable.VCCbFind
                       (&retmsg, VCCB_MOV_VERTEX, &Adj, &Lsec, &me->Vtx2,
                        me->dCVtx2, IXloc, NULL, &EP, &me->ModuleInfo),
      targetid = me->CabId.objid,
      targetos = me->CabId.osnum);
  as$status();

  /*    reverse vertices if needed. (align with string sequence)   */

  if (me->Vtx1 > me->Vtx2)
  {
    IGRint      iVV;
    IGRdouble   dVV;

    iVV        = me->Vtx1;
    me->Vtx1   = me->Vtx2;
    me->Vtx2   = iVV;

    me->bReverse  = TRUE;

    for (i=0; i<3; i++)
    {
      dVV           = me->dCVtx1[i];
      me->dCVtx1[i] = me->dCVtx2[i];
      me->dCVtx2[i] = dVV;
    }
  }

End
  return OM_S_SUCCESS;
}

method VCADProcess ( long * sts )
{
  int              status;
  IGRlong          retmsg;
  IGRshort         nE, i;
  IGRdouble        dConCrd1[3];
  IGRdouble        dConCrd2[3];

  struct VR_tracerec  *LTrac=NULL;

SetProc(VCCmdAD_VCADProcess); Begin

  LTrac   = me->RWTrac;

/**** Following code is commented for TR179802305
      and moved to the 'case 3' for Raceways *********/

/*************
  if( !LTrac )
  {
    __DBGpr_com( " NULL POINTER input ... " );
    End
    return( OM_E_INVARG ); //added by alwin  for TR179801971
  }
*************/

  *sts = OM_S_SUCCESS;

  if (me->LocType < 0) goto quit;

  if (me->MyType == 1)
  {    /*A    Detach child from parent    */
    status =
    om$send (msg = message VCCable.VCCbDetach (&retmsg, &me->AssId),
        targetid = me->CabId.objid,
        targetos = me->CabId.osnum);
    as$status ();
  }
  else
  {    /*A    Attach child to parent    */
    IGRdouble      dP1;
    IGRdouble      dP2;
    IGRdouble      dQ1;
    IGRdouble      dQ2;
    IGRdouble      dPcon[3];
    IGRshort       ie;
    IGRboolean     bFree;
    BSrc           rc;

    switch (me->LocType)
    {
      case 1:   /*   attach to conduit guide    */
        status =
        om$send (msg = message VCRoot.VCSelectCpt
                         (&retmsg, me->dCVtx1, &ie, dPcon, NULL, &bFree,
                          &me->ModuleInfo),
            targetid = me->RefId.objid,
            targetos = me->RefId.osnum);
        as$status ();

        if (ie == 0)
        {
          me->iCFrom = 0;
          me->iCTo   = VC_MAX_SHORT;
        }
        else
        {
          me->iCFrom = VC_MAX_SHORT;
          me->iCTo   = 0;
        }

/* 3-98 KDD attach to the guide itself 
                                   (&retmsg, &me->AssId, me->iCFrom, me->iCTo,
*/
        status =
        om$send (msg = message VCCable.VCCbAttGuide
                                   (&retmsg, &me->RefId, me->iCFrom, me->iCTo,
                                    me->Vtx1, me->Vtx2, me->SectNo),
            targetid = me->CabId.objid,
            targetos = me->CabId.osnum);
        as$status ();
        break;

      case 2:     /*   attach to pointsource    */
        status =
        om$send (msg = message VCCable.VCCbAttPoint
                                        (&retmsg, &me->AssId, VCC_POINT_PARENT,
                                         me->Vtx1, me->SectNo),
            targetid = me->CabId.objid,
            targetos = me->CabId.osnum);
        as$status ();
        break;

      case 3:     /*   attach to raceway section   */

/**** Following code is inserted for TR179802305 *********/

	if( !LTrac )
	{
	  __DBGpr_com( " NULL POINTER input ... " );
	  End
	  return( OM_E_INVARG ); //added by alwin  for TR179801971
	}

/**** Above  code is inserted for TR179802305 *********/

	__DBGpr_obj( " Initial Component Id ", LTrac[0].Comp );
        status =
        om$send (msg = message VRGeneric.VRGetOrigCoor
                         (&retmsg, dConCrd1, &me->ModuleInfo),
            targetid = LTrac[0].Comp.objid,
            targetos = LTrac[0].Comp.osnum);
        as$status ();
	__DBGpr_vec( " Origin Coordinates ", dConCrd1 );

	__DBGpr_obj( " End Component Id ", LTrac[me->nRWtr - 1].Comp );
        status =
        om$send (msg = message VRGeneric.VRGetOrigCoor
                         (&retmsg, dConCrd2, &me->ModuleInfo),
            targetid = LTrac[me->nRWtr - 1].Comp.objid,
            targetos = LTrac[me->nRWtr - 1].Comp.osnum);
        as$status ();
	__DBGpr_vec( " End Coordinates ", dConCrd2 );

        dP1 = BSdistptpt (&rc, me->dCVtx1, dConCrd1);
        dP2 = BSdistptpt (&rc, me->dCVtx1, dConCrd2);
        dQ1 = BSdistptpt (&rc, me->dCVtx2, dConCrd1);
        dQ2 = BSdistptpt (&rc, me->dCVtx2, dConCrd2);

        if ((dP1 + dQ2) > (dP2 + dQ1))
        {
          /*   reverse rwaytrace     */
          struct VR_tracerec   Sdumm;

          nE = me->nRWtr / 2;

          for (i=0; i<nE; i++)
          {
            Sdumm         = LTrac[i];
            Sdumm.nCPfrom = LTrac[i].nCPto;
            Sdumm.nCPto   = LTrac[i].nCPfrom;

            LTrac[i]           =  LTrac[me->nRWtr - i - 1];
            LTrac[i].nCPto     =  LTrac[me->nRWtr - i - 1].nCPfrom;
            LTrac[i].nCPfrom   =  LTrac[me->nRWtr - i - 1].nCPto;

            LTrac[me->nRWtr - i - 1] = Sdumm;
          }

        }

        for (i=0; i<me->nRWtr; i++)
        {
          /*A ---- If required, change it into an associative root ------ */
          status =
          as$make_source( go_grid      = LTrac[i].Comp,
                          mod_env      = &me->AltEnv,
                          as_os        = me->ModuleInfo.md_id.osnum,
                          as_grid      = &LTrac[i].Comp);
          as$status();
        }

        status =
        om$send (msg = message VCCable.VCCbAttRway
                                   (&retmsg, me->nRWtr, me->RWTrac,
                                    me->Vtx1, me->Vtx2, me->SectNo),
            targetid = me->CabId.objid,
            targetos = me->CabId.osnum);
        as$status ();
        break;

      case 4:     /*   attach to term pullbox     */
        status =
        om$send (msg = message VCCable.VCCbAttPoint
                                         (&retmsg, &me->AssId, VCC_TERM_PULL,
                                          me->Vtx1, me->SectNo),
            targetid = me->CabId.objid,
            targetos = me->CabId.osnum);
        as$status ();
        break;

      default:
        break;
    }
  }

  quit:
End
  return OM_S_SUCCESS;
}

/* Move the located vertex and attach it to the Parent Point */
method VCADMoAttVertex ( long *sts )
{
    IGRint         i;
    IGRshort       nTmpType;
    IGRlong        status=OM_S_SUCCESS, retmsg;
    IGRdouble      dPt[3];
    struct ret_struct	VertexSt;

    SetProc(VCCmdAD_VCADMoAttVertex); Begin;

    __DBGpr_obj(" ref id", me->RefId);
    __DBGpr_obj(" ass id", me->AssId);

    /* This method was possibly written keeping only a point parent in mind.
     * However, the VCADGetFather method was triggering an alternate command
     * flow (in the state table) using VC_RTC_SINGLE. This trigger was set
     * based on either a point OR a terminal parent. Hence, this method should
     * have envisaged the possibility of a terminal parent as well.
     *
     * The actual problem (No TR):
     * Choosing a specific vertex of a cable from the 'attach cable to
     * terminal' command was causing problems.
     *
     * The if-else conditions below added by Anand in Dec 19, 2001.
     */

    if( me->LocType == 2 )
    {
	/*C Get parent's description */
	status = om$send( msg = message NDnode.NDgive_structure( &retmsg, 
								 &VertexSt,
							     &me->ModuleInfo ),
			  senderid = NULL_OBJID,
			  targetid = me->AssId.objid,
			  targetos = me->AssId.osnum );

	if ( VertexSt.type & point_generic )
	{   
	    /*C point's coordinates */
	    for (i=0; i<3; i++)
		dPt[i] = VertexSt.var.point_st.pt[i];
	}
    }
    else if( me->LocType == 4 )
    {
		       /* Get Terminal's ref location */
	IGRdouble	dRefMatrix[16];

	status = om$send( msg = message VCRoot.VCGetMatrix( &retmsg, -1,
							    dRefMatrix,
							    &me->ModuleInfo ),
			  senderid = NULL_OBJID,
			  targetid = me->AssId.objid,
			  targetos = me->AssId.osnum );

	dPt[0] = dRefMatrix[ 3];
	dPt[1] = dRefMatrix[ 7];
	dPt[2] = dRefMatrix[11];
    }
    else
    {
	printf("Invalid workflow in Attach cable command?\n");
	End;
	return OM_E_INVARG; /* Though not exactly an (invalid) argument, this
			     * method should not have been called for other
			     * values of LocTypes.
			     */
    }

    __DBGpr_vec(" pt arg", dPt);
    __DBGpr_int(" section num", me->SectNo);
    __DBGpr_int(" vertex num", me->Vtx1 );

    /* This method will change the "line_string", changing the vertex of the
       specified "Vertex no" with the given "Coordinates" */

    status = om$send ( msg = message VCCable.VCCbModify( &retmsg, 
							 VCCB_MOV_VERTEX,
							 VCCB_ADJUST_OFFSET, 
							 me->SectNo, me->Vtx1,
							 dPt, &me->ModuleInfo ),
		       targetid = me->CabId.objid,
		       targetos = me->CabId.osnum );

    /* This will  attach the selected vertex to the "Parent Point" */
    /* .. or to the dummy terminal parent (VCC_TERM_PULL) depending upon
     * me->LocType (added by Anand on Jan 30, 2002) */
    status = om$send ( msg = message VCCable.VCCbAttPoint ( &retmsg, 
							    &me->AssId,
							    ( me->LocType == 2 ?
							      VCC_POINT_PARENT :
							      VCC_TERM_PULL
							    ), 
							    me->Vtx1,
							    me->SectNo ),
		       targetid = me->CabId.objid,
		       targetos = me->CabId.osnum );

quit:
    End;
    return OM_S_SUCCESS;
}

end implementation VCCmdAD;
