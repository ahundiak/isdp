/* $Id: VRCompDel.I,v 1.4 2002/05/28 19:17:30 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrcomponent / VRCompDel.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRCompDel.I,v $
 *  Revision 1.4  2002/05/28 19:17:30  louis
 *  TR5888-component flipping on replace
 *
 *  Revision 1.3  2001/02/20 01:12:34  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/12 15:37:53  anand
 *  SP merge
 *
# Revision 1.1  2000/05/23  17:24:50  pinnacle
# Created: route/vrcomponent/VRCompDel.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/03/02  08:54:40  pinnacle
# Replaced: vrcomponent/VRCompDel.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/02/18  19:57:54  pinnacle
# Replaced: vrcomponent/VRCompDel.I for:  by hverstee for route
#
# Revision 1.2  1996/01/16  21:47:06  pinnacle
# Replaced: vrcomponent/VRCompDel.I for:  by r240_int for route240
#
 *
 * History:
 *  01/16/96    tlb  	Add prototypes
 *  03/02/98    Alwin   Provided a kludge for TR179602540. Deleting Angle Valve
 *			in PID should change the Component to EL90. 
 *
 *************************************************************************/
/*
     CLASS  NAME: VRComponent
     METHOD NAMES: NDdelete 


***********************************************************************/

class implementation VRComponent;

#include "nddef.h"
#include "ndmacros.h"
#include "VDmem.h"
#include "VRDbParamDef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRsketchdef.h"
#include "VRcsdef.h"
#include "vrtools_pto.h"
#include "acrepdef.h"
#include "VRPid.h"
#include "vrdbgmacros.h"

extern  GRclassid  OPP_VRPiping_class_id;
extern  GRclassid  OPP_VRHvac_class_id;

from  VRCorrection  import  VRMergeCorrection;
from  VRCorrection  import  VRSplit;

/***********************************************************************/

method GRdelete ( IGRlong *msg; struct GRmd_env *md_env )


{
  IGRlong      retmsg;
  IGRint       status;
  IGRint       NbRoots;
  IGRboolean   bDelComp;
  IGRint       cn_type;

  struct GRid *buffer;
  struct GRid  MyId;

  SetProc( VRComponent_GRdelete ); Begin 

  *msg     = MSSUCC;
  MyId.objid   = my_id;
  MyId.osnum   = OM_Gw_current_OS;
  cn_type      = ND_COMP;

  __DBGpr_me();
  __DBGpr_str( "Compcode ", me->szAABBCC );

  if (   (me->Status & VR_DUMB_DEL) ||
      (me->Status&VR_CORRECTION) || 
    /* test on topology (can delete if not linking two segments)*/
      (!me->nNbTopo) ||
      (me->Orientation.nPriIndex == -1) ||
      (me->Orientation.nSecIndex == -1)  )
  {
    /* -- Dumb delete if specified or if User's component -- */
    /*| Dumb delete */
    __DBGpr_com("nPriIndex or nSecIndex = -1 or nNbTopo = 0");
    bDelComp = TRUE;

  }/* End Delete required by somebody else or manual component */

  else if ( (me->Status & VR_CORRECTION)  )
  {
    /* -- Correction component without Dumb Delete flag -- */
    /*| Cannot delete correction component */

    bDelComp = FALSE;

  }/* End Correction never gets deleted */

  else /* System component not deleted by system */
  {

    /*| System component */

    bDelComp = FALSE;

    /* -- Verify consistency of templates */

    status = 
    om$send( msg   = message NDnode.NDget_objects(
                        ND_ROOT | ND_IN_BUF,
                        NULL,
                        0,
                        &buffer,
                        0,
                        OM_K_MAXINT,
                        &NbRoots ),
           targetid = my_id);
    as$status( );

    /* Verify number of templates */
    if (   NbRoots != ( me->nNbTopo + me->nNbAttr) )
    {
      /*| Missing or too many roots  => delete component */
      bDelComp = TRUE;
    }

    /* -- If all templates OK reset forced component -- */

    if ( (me->Status & VR_FORCED) && !bDelComp )
    {

      /* ------------------------------- */
      /* -- manage Tee<-->Olet switch -- */
      /* ------------------------------- */
      /* KLUDGE (part1) : Tee<-->Olet switch  */
      /* (should be generic each time cpts change) */

      struct ACrg_coll  TopoAttr;
      IGRint      PrevTopo,NewTopo;

      /* -- Get actual topology -- */
      strcpy ( TopoAttr.name, VR_N_COMP_TOPO_IN );

      status =
      om$send (msg = message VRGeneric.VRGetCompDesc ( &retmsg,
                                              &TopoAttr, md_env),
          targetid = my_id );
      as$status ();

      PrevTopo = (IGRint) TopoAttr.desc.value.att_exp;

      /* -------------- End KLUDGE (part1) -------------- */

      /*| Reset Forced status */
      status =
      om$send (msg = message VRGeneric.VRSetStatus ( &retmsg,
                            (IGRshort)VR_FORCED, (IGRshort)!VR_FORCED),
          targetid = my_id );
      as$status ();

      if ( me->Desc.nItemNum != 0 )
      {
        /*|   Reset forced AABBCC Code */
        me->szAABBCC[0] = 0;


        /* ------------------------------- */
        /* -- manage Tee<-->Olet switch -- */
        /* ------------------------------- */
        /* KLUDGE (part2) : Tee<-->Olet switch */
        /* (should be generic each time cpts change) */
        status =
        om$send (msg = message VRGeneric.VRGetCompDesc
                                         ( &retmsg, &TopoAttr, md_env),
            targetid = my_id );
        as$status ();

        NewTopo = (IGRint) TopoAttr.desc.value.att_exp;

        if (   NewTopo != PrevTopo )
        {
          IGRshort  nNextCp;
          IGRint    TeeTopo,OletTopo;
          GRclassid  MyClassId;
          struct GRid  NextId,CorId;

          /*| --> Topo Modification (Only for Tee,Olet) */

          /* Init product dependent values */
          om$get_classid (objid = my_id,
                          osnum = OM_Gw_current_OS,
                      p_classid = &MyClassId );

        if ( om$is_ancestry_valid
          ( subclassid   = MyClassId,
            superclassid = OPP_VRPiping_class_id )
             == OM_S_SUCCESS )
        {/*| -- PIPING object -- */
          TeeTopo   = VRP_V_3_WAYS_TOPO;
          OletTopo   = VRP_V_OLET_TOPO;
        }
        else
        if ( om$is_ancestry_valid
          ( subclassid   = MyClassId,
            superclassid = OPP_VRHvac_class_id )
             == OM_S_SUCCESS )
        {/*| -- HVAC object -- */
          TeeTopo   = VRH_V_3_WAYS_TOPO;
          OletTopo   = VRH_V_OLET_TOPO;
        }
        else
        {/*| -- RWAY object -- */
          TeeTopo   = VRR_V_3_WAYS_TOPO;
          OletTopo   = VRR_V_OLET_TOPO;
        }


      if ((PrevTopo==TeeTopo) && (NewTopo==OletTopo))
      { /*| TEE --> OLET */

        /* -- Get my correction on cp0 -- */

        status =
        om$send( msg = message VRGeneric.VRGetCorOnCpt
                                       (&retmsg, (IGRshort) 0, &CorId,md_env),
                        targetid = my_id);
        as$status( action = RET_STATUS );

        /* -- Perform geometric transformation -- */
        status =
        om$send(msg = message NDnode.NDs_compute_node( 
              &retmsg, 
              ND_COMP,
              md_env ),
          targetid = my_id );
        as$status ();

        /* -- merge my correction -- */
        status =
        om$send(msg = message VRCorrection.VRMergeCorrection
             ( &retmsg, &MyId, md_env ),
          targetid = CorId.objid,
          targetos = CorId.osnum );
        as$status();

        /* -- Recompute this correction -- */
        nd$wait_batch( type       = GR_GEOM_POSTED, 
            l_object   = &CorId,
            l_obj_info = &cn_type,
            nb_obj     = 1 );


      }/* end tee->olet */
      else if ((PrevTopo==OletTopo) && (NewTopo==TeeTopo))
      { /*| OLET --> TEE */
        /* -- Perform geometric transformation -- */
        status =
        om$send(msg = message NDnode.NDs_compute_node( 
              &retmsg, 
              ND_COMP,
              md_env ),
            targetid = my_id );
        as$status ();

        /* -- Get my next component on cpt 0 -- */
        status =
        om$send( msg = message VRGeneric.VRGetNextOnCpt
          ( &retmsg, (IGRshort)0, &NextId,
          &nNextCp,0, NULL, NULL, NULL, md_env ),
          targetid = my_id);
        as$status( action = RET_STATUS );

        /* -- Get its correction -- */

        status =
        om$send( msg = message VRGeneric.VRGetCorOnCpt
                                       ( &retmsg, nNextCp, &CorId, md_env  ),
                        targetid = NextId.objid,
                        targetos = NextId.osnum );
        as$status( action = RET_STATUS );

        /* -- split its correction -- */
      
        status =
        om$send(msg = message VRCorrection.VRSplit
                               (&retmsg, &NextId, VR_UNKNOWN, VR_UNKNOWN, md_env),
                        targetid = CorId.objid,
                        targetos = CorId.osnum );
        as$status( action = RET_STATUS );

      }/* end olet->tee */

      }/* end Topo Modification */

      /* ----------- End KLUDGE (part2) ----------- */

    status =
    om$send (msg = message VRGeneric.VRNotifyCorrections 
      ( &retmsg, 0 ),
      targetid = my_id );

    /*|   Recompute  */

    nd$wait_batch( type       = GR_GEOM_POSTED, 
        l_object   = &MyId,
        l_obj_info = &cn_type,
        nb_obj     = 1 );

    }
    
  }/* end system forced component */


  }/* end system component not deleted by system */

  /* added by alwin for TR179602540 */
  /* When the Angle Valve is deleted, the system is expected to replace that
  component with the 90 Deg Elbow. Whereas this wasn't considered during the
  design time. As this is only simple way out for fixing this problem, so I'm
  proposing this Kludge. Just check Component's code for the Angle Valve, if
  you find so; then set the Compcode instance variable to "EL90" and allow the
  system to recompute. During the recompute the system picks up the correct
  macro "pidcod" ( this may be different for different user ) to display the 
  EL90. */

  if( bVR_IS_PID(me->xform_chan) )
  {
     if( !strcmp( me->szAABBCC, "ANGV" ) )
     {
	strcpy( me->szAABBCC, "EL90" );

        nd$wait_batch( 
	  type       = GR_GEOM_POSTED, 
	  l_object   = &MyId,
	  l_obj_info = &cn_type,
	  nb_obj     = 1 );
     }
  }
  /* added by alwin for TR179602540 */

  __DBGpr_int( " bDelComp ", bDelComp );

  if ( bDelComp )
  {
    /*|   Delete */
  
    nd$wait_batch( type       = GR_DELETED, 
        l_object   = &MyId,
        l_obj_info = &cn_type,
        nb_obj     = 1 );
  
  }

End
return ( OM_S_SUCCESS );

}
/***********************************************************************/

method NDmove_to_root ( IGRlong  *msg;
                 struct GRid     *src_grid;
                 struct GRmd_env *md_env )

{
  IGRint        status;
  IGRlong       retmsg;
  IGRint        NbRoots;
  IGRint        NbMax;
  struct GRid  *buffer;
  struct GRid  *DelTempIds;
  struct GRid   MyId;
SetProc( VRComponent_NDmove_to_root ); Begin

  *msg = MSSUCC;

  src_grid->objid = NULL_OBJID;

  /* -- GET DELETED IN EVERY CASE -- */

  /* -- Get my templates -- */

  status = 
  om$send (msg = message NDnode.NDget_objects
                                 (ND_ROOT | ND_IN_BUF, NULL, 0, &buffer,
                                  0, OM_K_MAXINT, &NbRoots ),
      targetid = my_id);
  as$status( );

  NbMax = NbRoots + 1;
  DelTempIds = _MALLOC (NbMax, struct GRid);

  /* -- Update my instances -- */
  if ( NbRoots != (me->nNbTopo + me->nNbAttr) )
  {
    /* -- If bad number of templates :Reset my instances -- */
    /*| ERROR -> Reset my number of templates */
    me->nNbTopo = me->nNbAttr = 0;
  }
  else
  {
    /* -- Else count number of templates in delete list -- */

    IGRint   *wait_index;
    IGRshort  i,j;
    IGRshort  nPrevTopo;

    wait_index = _MALLOC ((NbRoots + 1), IGRint);

    status =
    NDis_waiting (GR_DELETED, 0, buffer, wait_index, NULL, NULL, NbRoots);

    nPrevTopo = me->nNbTopo;

    for ( i = 0;i<NbRoots; i++)
    {
      if ( wait_index[i] != -1 )
      {
        if ( i >= me->nNbAttr )
        {
          /*"loosing topo[%d]:<%d,%d>\n",i,buffer[i].objid,buffer[i].osnum*/
          /* store lost template */
          DelTempIds[nPrevTopo-me->nNbTopo] = buffer[i];
          me->nNbTopo -= 1;

          status =
          om$send (msg = message VRComponent.VRSetMEIX
                                     (&retmsg, ((IGRshort) (i-me->nNbAttr)),
                                      (IGRshort) -1),
              targetid = my_id);
        }
        else
        {
          /*" loosing attr[%d]\n",i*/
          me->nNbAttr -= 1;
        }
      }
    }/* end for() */

    _FREE (wait_index);

    if ( nPrevTopo != me->nNbTopo )
    {
      /*| Compress table of indexes */
      j=0;
      for (i=0; i<nPrevTopo; i++)
      {
        IGRshort   iLoc;

        status =
        om$send (msg = message VRComponent.VRGetMEIX (&retmsg, i, &iLoc),
            targetid = my_id);

        if (iLoc != -1 )
        {
          status =
          om$send (msg = message VRComponent.VRSetMEIX (&retmsg, j, iLoc),
              targetid = my_id);

          j++;
        }
      }/* end loop on index table */

      /*" Disconnect %d templates\n", (nPrevTopo-me->nNbTopo) */

      status=
      om$send ( msg = message NDnode.NDdisconnect
            ( (nPrevTopo-me->nNbTopo), DelTempIds ),
        targetid = my_id );

    }/* end update templates */
  }

  /*" %d Topo left\n",me->nNbTopo */
  /*" %d Attr left\n",me->nNbAttr */

  _FREE (DelTempIds);

  /* -- Set my status to VR_DUMB_DEL -- */
  status = 
  om$send (msg = message VRGeneric.VRSetStatus
                             (msg, (IGRshort)VR_DUMB_DEL,
                                   (IGRshort)VR_DUMB_DEL),
      targetid = my_id );

  /* -- Delete via batch : Call VRDeleteObjects function ( 04-02-92 ) -- */
  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;
  status = VRDeleteObjects( 1, &MyId, md_env );
  as$status();

  End
  return ( OM_S_SUCCESS );
}

end implementation VRComponent;

