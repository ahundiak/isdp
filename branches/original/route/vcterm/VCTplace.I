
/* $Id: VCTplace.I,v 1.2 2001/02/20 01:11:42 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcterm / VCTplace.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCTplace.I,v $
 *  Revision 1.2  2001/02/20 01:11:42  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:39  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.8  1998/04/26  20:25:18  pinnacle
# Replaced: vcterm/VCTplace.I for:  by kddinov for route
#
# Revision 1.7  1998/03/14  19:46:20  pinnacle
# Replaced: vcterm/VCTplace.I for:  by kddinov for route
#
# Revision 1.6  1998/02/27  04:31:14  pinnacle
# Replaced: vcterm/VCTplace.I for:  by apazhani for route
#
# Revision 1.5  1998/02/18  20:12:02  pinnacle
# Replaced: vcterm/VCTplace.I for:  by kddinov for route
#
# Revision 1.4  1997/12/08  09:27:14  pinnacle
# Replaced: vcterm/VCTplace.I for:  by apazhani for route
#
# Revision 1.3  1997/12/04  20:17:32  pinnacle
# Replaced: vcterm/VCTplace.I for:  by r250_int for route
#
# Revision 1.15  1997/12/08  08:38:58  pinnacle
# Replaced: vcterm/VCTplace.I for:  by apazhani for cabling
#
# Revision 1.14  1997/12/04  20:06:22  pinnacle
# Replaced: vcterm/VCTplace.I for:  by vc241 for cabling
#
# Revision 1.13  1997/12/04  17:32:42  pinnacle
# Replaced: vcterm/VCTplace.I for:  by apazhani for cabling
#
# Revision 1.12  1997/11/26  18:52:04  pinnacle
# Replaced: vcterm/VCTplace.I for:  by apazhani for cabling
#
# Revision 1.11  1997/07/22  14:49:18  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.10  1997/05/22  15:23:14  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.9  1997/05/19  13:49:24  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.8  1997/05/06  13:29:22  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/02  20:29:30  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.6  1997/04/28  22:03:48  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/25  17:21:44  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/12  16:35:14  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/30  15:22:38  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:38:20  pinnacle
# Replaced: vcterm/VCTplace.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:29:58  pinnacle
# Created: vcterm/VCTplace.I by hverstee for cabling
#
 *
 * History:
 *  06/10/96  hv      initial
 *  11/26/97  Alwin   Implemented the method NDmove_to_root
 *  12/08/97  Alwin   Modified method NDmove_to_root to call the VCInitSection
 *                    of Cables to doo the freeing job and to delete the 
 *                    Backshells before deleting the Terminal. And also 
 *                    modified the NDdelete to take care of erasing the Display
 *                    of Terminal.
 *  02/27/97  Alwin   Modified method NDmove_to_root to call the VCCbDetach 
 *		      instead of VCCInitSection. NO TR.
 *
 * 4-98         KDD     Attach the graphics to terminals via ACheader not
 *                      not ACconst. That is because terminals are macros.
 *                      This is easier for getting their transformation matrix.
 *
 *************************************************************************/

class implementation VCTerm;

#include "ndmacros.h"
#include "VDmem.h"
#include "vrdbgmacros.h"

#include "VCMacLib.h"

extern GRclassid   OPP_VDequipment_class_id;
extern GRclassid   OPP_VREquipment_class_id;
 
from VCCable import VCCbDetach;
/*
#define  MY_DEBUG
*/

method NDplace( struct GRas      *asso_lis;
                struct GRmd_env  *md_env;
                       IGRchar   *go_cnst_lis)
{
  IGRlong     retmsg;
  IGRint      status;
  IGRint      FeetCount;
  IGRint      TypSav;
  IGRshort    nCP;
  IGRshort    nVal;
  IGRshort    nEnt, nTab;
  IGRint      i;
  IGRdouble   dMat[16];

  struct VClayout   *Layout;
  struct GRid        FeetList [2];
  struct GRid        ModelId;

  if ( asso_lis->as_attr == NULL || md_env == NULL)
  {
    /*| ERROR -> MISSING ATTRIBUTES */
    return OM_E_INVARG;
  }

  /* -------------------------- */
  /* -- INITIALIZE INSTANCE -- */
  /* ------------------------- */

  status = om$send( msg      = message VCRoot.VCInitInstance (&retmsg),
                    targetid = my_id) ;

  status =
  om$send( msg = message VCRoot.VCSetInstance
                            (&retmsg, (struct VCGenInfo *) asso_lis->as_attr),
      targetid = my_id);

   /* I cannot be moved to root */

  /*     really ??????
   status =
   om$send( msg = message NDnode.NDchg_state
                        ( ND_DONT_MVRT, ND_DONT_MVRT),
       targetid = my_id);
   */

   status =
   om$send( msg = message VCX.VCx_init (&retmsg),
       targetid = my_id);

  /*A attach to the macro definition */
  status =
  om$send(msg = message ACcpx.ACattach ((IGRint *)&retmsg, VC_MACDEF_TERM),
     targetid = my_id );
  as$status(action = RET_STATUS);

  /* ------------------------ */
  /* -- INSERT CC IN GRAPH -- */
  /* ------------------------ */

  if (asso_lis->num_parents)
  {
    status =
    om$send( msg = message NDnode.NDconnect (asso_lis->num_parents,
                                   asso_lis->parents, NULL_GRID, ND_NEW),
        targetid = my_id);
    as$status(action = RET_STATUS);

    /*    VCX for CB term   */
  }

  /*A   set local offsets from input   */

  /*   get base matrix (without translation) first   */

  TypSav = me->nVCType;
  nCP    = 0;
  nVal   = om$dimension_of (varray = me->dVCOffVal);

  status =
  om$send (msg = message VCRoot.VCBaseMat (&retmsg, nCP, dMat, md_env),
      targetid = my_id);

  me->nVCType = TypSav;

  /*   and translate to this input matrix   */
  /*   NOTE: when a vitual is created the offsets are already local  */

  if (!(me->nVCType & VC_GEN_VIRTUAL))
  {
    status =
    VC_to_offset (dMat, me->nVCType, nVal, me->dVCOffVal, me->dVCOffVal);
  }

  /* --------------------*/
  /* -- BUILD GRAPHICS --*/
  /* --------------------*/

/* KDD 4-98 make terminals assign the graphics components via ACheader */

  me->nVCType = me->nVCType & (~VC_GEN_BITERM) ; 


  status =
  om$send( msg = message ACncpx.ACconstruct_feet
                         (&retmsg, 0, 0, NULL, md_env, &FeetCount, FeetList),
      targetid = my_id );
  as$status ( action = RET_STATUS );

  status =
  om$send( msg = message ACncpx.ACchange_feet(FeetCount, FeetList, md_env ),
      targetid = my_id );
  as$status ( action = RET_STATUS );

  status =
  om$send( msg = message VCP.VCP_init (&retmsg, FeetList, md_env),
      targetid = my_id);

  /*    get signalnames from DB           */

  status =
  om$send( msg  = message VCRoot.VCGetModel( &retmsg, &ModelId),
       targetid = my_id);
  as$status();

  if (ModelId.objid != NULL_OBJID)
  {
    status =
    om$send ( msg = message VCDB.VCGetLayout
                     (&retmsg, NULL, &nEnt, &nTab, NULL),
         targetid = ModelId.objid,
         targetos = ModelId.osnum);

    if (nEnt <= 0) nEnt = 1;

    Layout = _MALLOC (nEnt, struct  VClayout);

    status =
    om$send ( msg = message VCDB.VCGetLayout
                     (&retmsg, NULL, &nEnt, &nTab, Layout),
         targetid = ModelId.objid,
         targetos = ModelId.osnum);

    for (i=0; i< nEnt; i++)
    {
      if (!(VC_EMPTYSTR (Layout[i].szDefSig)))
      {
        status =
        om$send (msg = message VCCon.VCPutSignal
                           (&retmsg, &Layout[i].pDef, Layout[i].szDefSig),
            targetid = my_id);
      }
    }

    _FREE (Layout);
  }

  /* -------------------*/
  /* -- SET SYMBOLOGY --*/
  /* -------------------*/

  if ( !(me->nVCStat & VC_ERROR) )
  {
    struct GRsymbology        Symb;

    if (go_cnst_lis)
    { /*C Take given symbology */
      Symb.display_attr =  *(((struct GRvg_construct *)go_cnst_lis)->display);
      Symb.level        =   (((struct GRvg_construct *)go_cnst_lis)->level);
    }
    else
    {  /*C Get symbology from parent */
      struct GRid        GoId;

      if (me->nVCType & VC_GEN_VIRTUAL)
      {
        status =
        om$send (msg = message VCTerm.VCGetEquipId
                                         (&retmsg, &GoId),
            targetid = my_id);
        as$status( action = RET_STATUS );
      }
      else
      {
        status =
        om$send (msg = message NDnode.ASreturn_go
                                       (&GoId, NULL, NULL),
            targetid = asso_lis->parents[me->nVCAttr].objid,
            targetos = asso_lis->parents[me->nVCAttr].osnum );
        as$status( action = RET_STATUS );
      }

      status =
      om$send( msg = message GRvg.GRgetsymb (&retmsg,&Symb),
          targetid = GoId.objid,
          targetos = GoId.osnum );
      as$status ( action = RET_STATUS );
    }

    status =
    om$send(msg = message GRvg.GRputsymb(&retmsg,&Symb),
       targetid = my_id);
    as$status();


    /* KDD 2-98 for CR179702225 VCRoot overrides this method */
 
    status = om$send( msg      = message VDSroot.VDputAttrDrivenSymb
                                        ( &retmsg, md_env, "cableattr.symb"),
                      targetid = my_id);
  }

  return (status);
}

method NDupdate (int      *msg;
                 int       cn_type, count;
          struct GRid     *parents;
                 int      *parent_state;
          struct GRid     *context,*new_objid;
          struct GRmd_env *md_env)

{
  /* Once moved to root during place macro, this objects receives
     another compute ??????? */
  /* So, if no templates are given => return success */
  if ( count <= 0 )
  {
    *msg = MSSUCC;
    return ND_COMP_SAME;
  }

  /*A    then send to general NDupdate method   */
  return
  (om$send (msg = message VCRoot.NDupdate
                (msg, cn_type, count, parents, parent_state,
                 context, new_objid, md_env),
        mode     = OM_e_wrt_message,
        targetid = my_id)                                       );
}

method NDdelete(struct GRmd_env *md_env)
{
  IGRint         status;
  IGRlong        retmsg;

  /* Undisplay the Terminal first and then delete it */
  {
         enum   GRdpmode         Mode;
  
         GRabsg_del_all();
  
         Mode = GRbe;
         status = om$send( msg = message GRgraphics.GRdisplay( &retmsg,
                                         &md_env->md_env.matrix_type,
                                          md_env->md_env.matrix,
                                         &Mode, &md_env->md_id ),
               targetid = my_id );
         as$status();
  }

  status =
  om$send (msg = message VCCon.VCConDscall (&retmsg, VC_REQ_ALL_CPT),
      targetid = my_id);

  status =
  om$send (msg = message VCRoot.NDdelete (md_env),
          mode = OM_e_wrt_message,
      targetid = my_id);

  return (status);
}

/*****************************************************************************
* Whenever the Parent of the Terminal object is deleted, the control will come
* here. Here what has been done is, first the object is checked for Embedded 
* Terminal.  
*
* If it is Embedded term. then we need to Delete it. Before deleting we're 
* supposed to disconnect it from all the childrens it may either be cable or 
* Connection Component (Backshell). 
*
* In case of Cable child we have to disconnect it from Terminal and then we 
* need to reset the Section properties of the Cable so that we can connect to
* the free end of the cable.
*
* In case of Backshell child, we can directly delete it. As such we don't need
* any processing work for Backshell.
*
* One more case is, the External Terminals i.e Terminal which
* are placed using "C PLACE CABLING TERMINAL" as selecting the Equipment/CS
* as Parent. In this case we need set the offset value of the Terminal to itself
* and change the instances accordingly. Alwin for TR179701984
*
******************************************************************************/
 
 
method NDmove_to_root(IGRlong     *msg;
                struct GRid        *src_grid;
                struct GRmd_env    *md_env )
{
  IGRboolean bEmbedded=FALSE;
  IGRint status=OM_S_SUCCESS;
  struct GRid MyId;
 
  SetProc( NDmove_to_root ); Begin
 
  MyId.objid = my_id;
  MyId.osnum = md_env->md_id.osnum;
 
  __DBGpr_obj( " Terminal Object ", MyId );
 
  status = om$send ( msg = message VCTerm.VCTembed( &bEmbedded ),
                            targetid = my_id );

  __DBGpr_int( " Is it Embedded? ", bEmbedded );

  if( bEmbedded ) 
  {
     IGRint i;
     IGRshort NbCables=0, nRefcab=0, NbShells=0;
     struct GRid *CableId=NULL;
     struct GRid *ShellId=NULL;

     /* First get the number of cables connected to this Terminal */
     status = om$send ( msg = message VCTerm.VCTcables( msg, &NbCables,
                                      &nRefcab, NULL ),
                              targetid = my_id );
 
     __DBGpr_int( " Number of Cables ", NbCables );
 
     if( NbCables )
     {
         CableId = _MALLOC( NbCables, struct GRid );
 
         __CheckPtr( CableId, "Allocation for Cables failed", quit );
 
         /* After the memory Allocation, now get all the Cable Object Ids */
         status = om$send ( msg = message VCTerm.VCTcables( msg, &NbCables,
                                   &nRefcab, CableId ),
                           targetid = my_id );
 
         for( i=0; i<NbCables; i++ )
         {
            __DBGpr_obj( " Cable Id to be freed ", CableId[i] );
 
	    /* Previously, VCCInitSection was called the set the instance of
	    the Cable objects. It is advisable to call the VCCbDetach method
	    to disconnect the Cable from Terminal. Alwin */
	    /****
            status =
            om$send ( msg = message VCCable.VCCInitSection( msg, MyId ),
                             senderid = NULL_OBJID,
                             targetid = CableId[i].objid,
                             targetos = CableId[i].osnum );
	    ****/
            status =
            om$send ( msg = message VCCable.VCCbDetach( msg, &MyId ),
                             senderid = NULL_OBJID,
                             targetid = CableId[i].objid,
                             targetos = CableId[i].osnum );
         }
 
         _FREE( CableId );
     }
 
     /* First get the number of BackShells connected to this Terminal */
     status = om$send ( msg = message VCTerm.VCTshells( msg, &NbShells,
                                      NULL ),
                              targetid = my_id );
 
     __DBGpr_int( " Number of Shells ", NbShells );

     if( NbShells )
     {
         ShellId = _MALLOC( NbShells, struct GRid );
 
         __CheckPtr( ShellId, "Allocation for Shells failed", quit );
 
         /* After the memory Allocation, now get all the Shell Object Ids */
         status = om$send ( msg = message VCTerm.VCTshells( msg, &NbShells,
                                   ShellId ),
                           targetid = my_id );
 
         for( i=0; i<NbShells; i++ )
         {
            __DBGpr_obj( " Shell Id to be Deleted ", ShellId[i] );
 
            status =
            om$send ( msg = message VCRoot.NDdelete( md_env ),
                             targetid = ShellId[i].objid,
                             targetos = ShellId[i].osnum );
         }
 
         _FREE( ShellId );
     }
 
quit:
 
     __DBGpr_obj( " Deleting Terminal ", MyId );
     status =
     om$send ( msg = message VCRoot.GRdelete( msg, md_env ),
                   targetid = my_id );
     as$status();
  }
  else
  {
    /* A Terminal can have one only Topological Parent. After the only parent
    has been deleted reset the Type of Terminal and Topological Parents */
 
    IGRdouble dRefMatrix[16];
    IGRdouble dPoints[16]; /* To be on the safer side, I'm using 16 */
    struct VCGenInfo TermInst;

    TermInst.Attr.Term.dOffVal = dPoints; /* Allocating memory for Points */
 
    status = om$send ( msg = message VCRoot.VCGetInstance( msg, &TermInst ),
                            targetid = my_id );
 
    __DBGpr_int( " TermInst.nType ", TermInst.nType );

    TermInst.nType  =  VC_GEN_BITERM | VC_TERM_NO |
                       VC_TOFF_COORDS;
    TermInst.nNbTopo = 0;
 
    MAidmx( msg, dRefMatrix );
    status = om$send ( msg = message VCRoot.VCGetMatrix( msg, -1,
                                                         dRefMatrix, md_env ),
                              targetid = my_id );
 
    /* Set the Offset of the Terminal to itself( mean Set its Offset value with
    Base Coordinate System ). Alwin */
 
    TermInst.Attr.Term.dOffVal[0] = dRefMatrix[3];
    TermInst.Attr.Term.dOffVal[1] = dRefMatrix[7];
    TermInst.Attr.Term.dOffVal[2] = dRefMatrix[11];
 
    status = om$send ( msg = message VCRoot.VCSetInstance( msg, &TermInst ),
                              targetid = my_id );
  }

  status = om$send( msg = message ACncpx.NDmove_to_root( msg, src_grid, md_env),
                           mode = OM_e_wrt_message,
                           targetid = my_id );

  End
  return status;
}

end implementation VCTerm;

