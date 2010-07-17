
/* $Id: VCCplace.I,v 1.3 2002/05/08 15:48:22 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCplace.I
 *
 * Description:
 *      NDplace method for cables
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCplace.I,v $
 *        Revision 1.3  2002/05/08 15:48:22  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:09:04  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/07/22  07:54:36  pinnacle
# Replaced: vccable/VCCplace.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/01  20:24:20  pinnacle
# Replaced: vccable/VCCplace.I for:  by kddinov for route
#
# Revision 1.4  1998/03/14  19:52:16  pinnacle
# Replaced: vccable/VCCplace.I for:  by kddinov for route
#
# Revision 1.3  1998/03/12  10:14:48  pinnacle
# Replaced: vccable/VCCplace.I for: TR179800045 by aharihar for route
#
# Revision 1.2  1998/02/18  20:00:08  pinnacle
# Replaced: vccable/VCCplace.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.7  1997/07/22  15:02:02  pinnacle
# Replaced: vccable/VCCplace.I for:  by hverstee for cabling
#
# Revision 1.6  1997/05/06  23:11:14  pinnacle
# Replaced: vccable/VCCplace.I for:  by hverstee for cabling
#
# Revision 1.5  1997/04/28  22:12:32  pinnacle
# Replaced: vccable/VCCplace.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/25  20:29:22  pinnacle
# Replaced: vccable/VCCplace.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/06  22:52:14  pinnacle
# Replaced: vccable/VCCplace.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/09  18:16:22  pinnacle
# Replaced: vccable/VCCplace.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:49:12  pinnacle
# Created: vccable/VCCplace.I by hverstee for cabling
#
 *
 * History:
 *        06/29/96        hv        Initial
 *        12 Mar 98       Anand     Commented out the code for initialising
 *				    instance (done elsewhere).
 *	  3-98		  KDD	    VDputAttrDrivenSymb
 *	  3-98		  KDD	    allocate memory for GRlinear.GRgetpolyline
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
#define MY_DEBUG      1
*/

#include "VDmem.h"
#include "VCMacLib.h"
#include "vrdbgmacros.h"
#include "vdreporterr.h"


/********************************************/
/*    static buffer for initial compute     */

%safe
static
IGRdouble  *dLocVert = NULL;
static
IGRint      TotVert = 0;
%endsafe

/********************************************/

from   GRlinear   import   GRgetpolyline;

extern     GRclassid     OPP_GR3dlinestr_class_id;



method NDplace( struct GRas        *asso_lis;
                struct GRmd_env    *md_env;
                       IGRchar     *go_cnst_lis)
{
  IGRlong     retmsg;
  IGRint      status;
  IGRint      NumFeet;
  IGRint      NumSect;
  IGRint      i, j;

  struct GRid           *FeetList;
  struct GRvg_construct *pLocGo;
  struct VCGenInfo      *pGenin;

  SetProc(VCCable_NDplace ); Begin;

  if (asso_lis->as_attr == NULL ||
                 md_env == NULL ||
            go_cnst_lis == NULL)            return OM_E_INVARG;

  pGenin = (struct VCGenInfo *) asso_lis->as_attr;

#ifdef NOT_DONE_ELSEWHERE

/*-------------------------------------------------------------------------*
/* Note: The instance is initialised in					   *
/*									   *
/*	 function VC_CreateCab of vccmd/VC_CreFun.I			   *
/*									   *
/*	 soon after the object is constructed and before NDplace is called.*
/*	 The me->Offset is also set subsequently.			   *
/*	 Hence, the instance variable should NOT be re-initialised.	   *
/*						Anand (for TR179800045)    *
/*-------------------------------------------------------------------------*

  /* -------------------------- *
  /* -- INITIALIZE INSTANCE -- *
  /* ------------------------- *
 
*  status = om$send( msg      = message VCRoot.VCInitInstance (&retmsg),
*                    targetid = my_id) ;
--------------------------------------------------------------------------*/

#endif

  /*A store data in my instance */
  status = 
  om$send(msg = message VCRoot.VCSetInstance (&retmsg, pGenin),
     targetid = my_id );

  /*A initialization */

  TotVert = pGenin->Attr.Cable.NbVertices;

  pLocGo  = (struct GRvg_construct *)go_cnst_lis;
  NumFeet = 0;
  NumSect = om$dimension_of( varray = me->Sect );

  /* -----------------------------------------------------
   * TR179801127
   * Add a check to make sure have a valid object
   */
  if ((NumSect < 1) || (TotVert < 1)) {
    return OM_E_INVARG;
  }
  
  FeetList = _MALLOC ((2 * NumSect), struct GRid);
  dLocVert = _MALLOC ((3 * TotVert), IGRdouble);

  for (i=0; i<(NumSect*2); i++)
  {
    FeetList[i].objid = NULL_OBJID; 
    FeetList[i].osnum = md_env->md_id.osnum;
  }

  /*A attach to the macro definition */
  status = 
  om$send(msg = message ACcpx.ACattach ((IGRint *)&retmsg, VC_MACDEF_CABLE),
     targetid = my_id );
  as$status(action = RET_STATUS);

  /*C   move vertex data to local    */

  for (j =  0; j < TotVert; j++)
  {
    dLocVert[3*j]   = pGenin->Attr.Cable.pVertex[3*j];
    dLocVert[3*j+1] = pGenin->Attr.Cable.pVertex[3*j+1];
    dLocVert[3*j+2] = pGenin->Attr.Cable.pVertex[3*j+2];

#ifdef MY_DEBUG
    printf ("PLACE vtx %d - %f %f %f\n",j,dLocVert[3*j],dLocVert[3*j+1],
                     dLocVert[3*j+2]);
#endif
  }

  /*A make connections to the parents */
  status = 
  om$send(msg = message NDnode.NDconnect(asso_lis->num_parents,
                                     asso_lis->parents, NULL_GRID, ND_NEW),
     targetid = my_id);
  as$status(action = GOTO_VALUE, value = NO_GRAPHIC );

  status =
  om$send (msg = message ACncpx.ACconstruct_feet
                           (&retmsg, 0, asso_lis->num_parents, 
                             asso_lis->parents, md_env, &NumFeet,FeetList),
      targetid = my_id);

  pLocGo->geometry = (IGRchar *) NULL;

#ifdef MY_DEBUG
  {
    IGRint    ii;

    for (ii=0; ii<NumFeet; ii++)
      printf (" change foot %d <%d %d>\n",ii,FeetList[ii].objid,
                                             FeetList[ii].osnum);
  }
#endif

  /*A make connections to my feet */
  status = 
  om$send( msg = message ACncpx.ACchange_feet( NumFeet, FeetList, md_env ),
      targetid = my_id );
  as$status(action = GOTO_VALUE, value = NO_GRAPHIC );

  _FREE (FeetList);
  _FREE (dLocVert);

  /* -------------- */
  /*A Set symbology */
  /* -------------- */

  if ( !(me->nVCStat & VC_ERROR) )
  {
    struct GRsymbology  symb;

    symb.display_attr = *(pLocGo->display);
    symb.level        =  pLocGo->level;

    status = om$send(msg = message GRvg.GRputsymb (&retmsg, &symb),
                targetid = my_id);
    as$status();

    /* KDD 2-98 for CR179702225 VCRoot overrides this method */
  
    status = om$send( msg      = message VDSroot.VDputAttrDrivenSymb
                                         ( &retmsg, md_env, "cableattr.symb"),
                      targetid = my_id);

  }/* end set symbology */

  _FREE (FeetList);
  _FREE (dLocVert);

  return(OM_S_SUCCESS);

  NO_GRAPHIC:
  /*A delete the graphics objects */
  for (i=0; i<= NumFeet; i++)
    if( FeetList[i].objid != NULL_OBJID )
    {
      om$send(msg   = message Root.delete(1),
           targetid = FeetList[i].objid,
           senderid = NULL_OBJID );
    }

  _FREE (FeetList);
  _FREE (dLocVert);
End;
  return OM_E_ABORT;
} /* end of NDplace */



/*    default connectivity init     */

method     VCCbInitCon (IGRlong      *msg;
                        IGRboolean    bInit)
{
  IGRint     status;

SetProc(VCCable_VCCbInitCon ); Begin

  *msg = MSSUCC;

  status =
  om$vla_set_dimension (varray  = me->Connect_Data,
                        size    = 1);

  if (bInit)
  {
    VC_INITSTR (me->Connect_Data[0].FibEnds[0].szModId);
    VC_INITSTR (me->Connect_Data[0].FibEnds[0].szPosId);
    VC_INITSTR (me->Connect_Data[0].FibEnds[1].szModId);
    VC_INITSTR (me->Connect_Data[0].FibEnds[1].szPosId);
    VC_INITSTR (me->Connect_Data[0].SigNam);

    me->Connect_Data[0].nEndStat[0] = VC_CBE_OPEN;
    me->Connect_Data[0].nEndStat[1] = VC_CBE_OPEN;
    me->Connect_Data[0].nFibStat    = VC_CAB_REGULAR;
  }

  strcpy (me->Connect_Data[0].LeadNam, "DEF");

End;
  return (status);
}


/*   retrieve coordinatestrings for compute    */

method VCCbLdLine (IGRlong     *msg;
                   IGRshort     strno;
            struct IGRpolyline *LineIn;
            struct GRmd_env    *md_env)
{

SetProc(VCCable_VCCbLdLine ); Begin

  *msg = MSSUCC;

  if (dLocVert != NULL)
  { /*    for initial compute get from temp buffer    */
__DBGpr_com("Initial Recompute get from temp buffer");

    LineIn->num_points = TotVert;
    LineIn->points     = dLocVert;
  }
  else
  { /*    for regular recompute get component strings   */
    IGRint      status;
    IGRint      action;

 __DBGpr_com("regular recompute get component strings");

 /* KDD 3-98 allocated memory needed */
    action = 0;

    status = om$send(msg    = message GRlinear.GRgetpolyline
                                 (msg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix, &action, LineIn),
               p_chanselect = &AS_to_comp,
               from         = strno,
               to           = strno);
    as$status();

    _FREE(LineIn->points);
    /* ------------------------------------------
     * TR179801127
     * Guard against invalid input
     */
    LineIn->points = NULL;
    if (LineIn->num_points < 1) {
      goto wrapup;
    }
    
    LineIn->points     = _MALLOC ((3 * LineIn->num_points), IGRdouble);
    
    as$status( test   = (LineIn->points == NULL),
               msg    = "Memory allocation failure",
               action = GOTO_VALUE, value = wrapup);



    action = 1;
    LineIn->num_points = 0;

    status =
    om$send(msg    = message GRlinear.GRgetpolyline
                                (msg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix, &action, LineIn),
      p_chanselect = &AS_to_comp,
      from         = strno,
      to           = strno);

    if (!(status & OM_S_SUCCESS)) *msg = MSFAIL;
  }

wrapup:
__DBGpr_int("LineIn->num_points ", LineIn->num_points);
End;
  return (OM_S_SUCCESS);
}


end implementation VCCable;

