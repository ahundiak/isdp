/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/*
  EMglpinit.I

  Graphics loop init.
  
  History:
   JJC & SCW  3-18-91  Created from feature loop.
   NP          3-3-92  Modified to do the surface connect ONLY if the surface
                       exists. This is because some loops formed during 
                       coincident plane processing are not connected to any
                       surface.
   msm        10-3-92  ANSI-C conversion.
*/
class implementation EMSgraloop;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "bs.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"

from EMSedge    import EMgetrange;

method EMglpinit( IGRlong               *EMmsg;
                  IGRushort      props;
                  struct EMSpartolbasis *partolbasis; 
                  GRobjid                surf_id )
{
  IGRlong          sts,
                   rc,
                   i;
  OMuint           count;
  IGRboolean       EFextract_par();
  OM_S_CHANSELECT  to_edges;
  IGRdouble        range[4],
                   parsqtollen,
                   begin_pt[2],
                   end_pt[2];


  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  ME.EMSloop->lp_props = props;

  /* Get the proper tolerance
   */
  if( !partolbasis->is_valid )
  {
     sts = om$send( msg = message EMSboundary.EMgetsurface_info( EMmsg,
                                                                 NULL,
                                                                 partolbasis ),
                    targetid = my_id );
     EMerr_hndlr( !( 1 & *EMmsg & sts ), *EMmsg, EMS_E_LoopError, wrapup );
  }
  sts = EFextract_par( BSTOLSQLENVEC,
                       partolbasis->tol,
                      &parsqtollen,
                      &rc );


  /* Update my range box
   */
  sts = om$get_channel_count( object       =  me,
                              p_chanselect = &to_edges,
                              count        = &count );
  if( !( 1 & sts ))goto wrapup;

  /* decide my min max values */

  ME.EMSloop->range[0] = MAXFLOAT;    /* Any big number */
  ME.EMSloop->range[1] = MAXFLOAT;
  ME.EMSloop->range[2] = MINFLOAT;    /* Any small number*/
  ME.EMSloop->range[3] = MINFLOAT;

  for( i = 0; i < count; i++ )
  {
     sts = om$send( msg = message EMSedge.EMgetrange( EMmsg,
                                                      range,
                                                      NULL ),
                    p_chanselect = &to_edges,
                    from = i,
                    to = i );
     if( !( 1 & *EMmsg & sts )) goto wrapup;

     if(range[0] < ME.EMSloop->range[0]) ME.EMSloop->range[0] = range[0];
     if(range[1] < ME.EMSloop->range[1]) ME.EMSloop->range[1] = range[1];
     if(range[2] > ME.EMSloop->range[2]) ME.EMSloop->range[2] = range[2];
     if(range[3] > ME.EMSloop->range[3]) ME.EMSloop->range[3] = range[3];
  }

  /* Check whether I am open or closed
   */
  sts = om$send( msg = message EMSloop.EMendpts( EMmsg,
                                                 begin_pt,
                                                 end_pt,
                                                 NULL,
                                                 NULL ),
                 targetid = my_id );
  if( !( 1 & *EMmsg & sts ))  goto wrapup;

  if( EM2ddistptpts( begin_pt, end_pt ) < parsqtollen )
      ME.EMSloop->lp_props &= ~EMLP_OPEN;
  else ME.EMSloop->lp_props |= EMLP_OPEN;

  ME.EMSloop->lp_props |= EMLP_NOAREA_NOHOLE;

  if( surf_id == NULL_OBJID )
  {
    sts = om$send( msg = message EMSboundary.EMgetsurface_info( EMmsg,
                                                               &surf_id,
                                                                NULL ),
                   targetid = my_id );
    if( !( 1 & *EMmsg & sts ))  goto wrapup;

  }

  /*
   * Connect the surface (ONLY if one exists for this loop)
   */
  if (surf_id != NULL_OBJID )
  {
    sts = om$send( msg = message EMShelper.EMhelperConnect( EMmsg, 
                                                          surf_id,
                                       /* add at end */   MAXINT ),  
                targetid = my_id );
    if(! (1 & *EMmsg & sts)) goto wrapup;
  }

  /* what about EMgradata.EMnotify_surface_range_modify method */

  if ( surf_id != NULL_OBJID )
  {
    /* notify display list of graphics loop initialization */
    DPdlist_graloop_notify( surf_id, OM_Gw_current_OS );
  }

wrapup:
  EMWRAPUP( *EMmsg, sts, "In EMSgraloop.EMglpinit" )
  return( sts );
}

end implementation EMSgraloop;


