/*
  OVERVIEW

  API for Round Edge.

  NOTES
*/

class implementation Root;

#include <math.h>
#include <alloca.h>
#include "OMmacros.h"
#include "bsvalues.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "PWminimum.h"
#include "PWerror.h"

#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "EMSrnd.h"
#include "PWmodel.h"
#include "valinfo.h"
#include "PWapi/round.h"

#include "bsparameters.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bscvtstclsd.h"
#include "bsnorvec.h"

from EMSboundary import EMgetsurface_info;
from EMSsurface import EMgetactiveid;
from EMSedge import EMget_props;
from EMSdpr import EMsetprops;
from GRvg import GRgetsymb;

%safe
static PWboolean IsEdgeInList (
  PWobjid edge_id,
  int num_elem,
  struct EMSrnd_boundary_input *bdry_array);
%endsafe

extern OMuword OPP_EMScompsurf_class_id, OPP_EMSedge_class_id;
extern OMuword OPP_EMSsubbs_class_id, OPP_EMSloop_class_id;

extern short _Pathway, _pathway_trim, _pathway_orient;

/*
  DESCRIPTION

  This API rounds edges of surface entities with given radii.

  ARGUMENTS

  PWobjid sf_entity               -I : Surface entity (solid/comp surface)
                                       whose edges are to be rounded.
  PWosnum os                      -I : OS number of the surface entity.
  int num_edge_sets               -I : Number of sets of edges with the
                                       same radius.
  struct PWrndedgeset *edge_sets  -I : Array of edge sets.
  PWboolean is_chamfer            -I : TRUE, if the operation required is a
                                       chamfer.
  PWobjid *rnd_entity             -O : Rounded surface entity.

  NOTES
  Memory for rnd_entity should be provided by the caller.

  HISTORY
  Aditya  03/19/96  Creation
*/

PWresult pwRoundEdges
(
  PWobjid sf_entity,
  PWosnum os,
  int num_edge_sets,
  struct PWrndedgeset *edge_sets,
  PWboolean is_chamfer,
  PWobjid *rnd_entity
)
{
  int inx=0, count=0, tot_num_edges=0;
  int bdry_ed_count=0;
  unsigned int chan_count=0;
  long status=0;
  unsigned short options=FALSE, ed_props=FALSE;
  short save_pw_trim, save_pw_orient;

  OM_S_CHANSELECT to_common_edge;
  OM_S_OBJECT_LINKAGE common_edge[1];

  PWboolean assoc_status=0 , stat=0, var_rnd=FALSE, in_list=FALSE;
  PWresult PWsts ;
  PWclassid classid ;
  PWobjid surf_id=NULL_OBJID;

  BSrc rc;
  IGRlong msg_loc;

  struct GRid                  rnd_feature, active_dpr;
  struct GRmd_env              md_env;

  struct EMSrnd_boundary_input *p_bdryelem=NULL;
  struct EMSrnd_error *p_rnderr=NULL;

  extern long EMround_chamfer_edges(); 
  extern void EMinitvgcnstr ( );
  extern IGRboolean EMgetvgcnstr ( );

  PWsts = PW_K_Success;
  msg_loc = EMS_S_Success;
  rc = BSSUCC;
  stat = 1;

  if(_Pathway)
  {
    save_pw_trim = _pathway_trim;
    save_pw_orient = _pathway_orient;

    _pathway_trim = 0;
    _pathway_orient = 0;
  }

  if( rnd_entity)
    *rnd_entity = NULL_OBJID;
  else
    OnErrorState ( TRUE, PWsts, PW_K_InvalidArg, wrapup);
    
  gr$get_associative_flag(buffer = &assoc_status);

  /*
   * Now using gr$get_module_env() which returns the master os' GRmodule
   * but if we want to use this api for trans os placement of features we
   * will need an api that gets the GRmd_env data for the given os.
   */
  gr$get_module_env ( buffer = &md_env);

  /*
   * Validate the sf_entity.
   */
  stat = om$is_objid_valid ( objid = sf_entity , osnum = os ) ;
  OnErrorState( !stat, PWsts, PW_K_InvalidArg, wrapup);

  classid = omClassidFromObjid ( sf_entity , os ) ;
  if ( ! omIsAncestryValid ( classid , OPP_EMScompsurf_class_id ))
  {
    OnErrorState( TRUE, PWsts, PW_K_InvalidArg, wrapup);
  }

  stat = om$make_chanselect ( channame = "EMSedge.to_common_edge",
                       p_chanselect = &to_common_edge );
  OnErrorState( !(1 & stat), PWsts, PW_K_Error, wrapup);

  /*
   * Allocate memory for p_bdryelem of size of summation of all the edges
   * in the edge_sets.
   */
  tot_num_edges = 0;

  for(inx = 0; inx < num_edge_sets; inx++)
     tot_num_edges += edge_sets[inx].num_edges;

  p_bdryelem = (struct EMSrnd_boundary_input *)
                malloc (tot_num_edges * sizeof(struct EMSrnd_boundary_input));
  OnErrorState( !p_bdryelem, PWsts, PW_K_DynamicMemory, wrapup);

  memset(p_bdryelem, NULL, tot_num_edges*sizeof(struct EMSrnd_boundary_input));

  bdry_ed_count = 0;

  for(inx = 0; inx < num_edge_sets; inx++)
  {
    /*
     * The first edge of every group in the EMSrnd_boundary_input array is
     * marked with the EMSrnd_input_ed_grp_start bit.
     */
    p_bdryelem[bdry_ed_count].props = NULL;
    p_bdryelem[bdry_ed_count].props |= EMSrnd_input_ed_grp_start;

    if(edge_sets[inx].is_variable) var_rnd = TRUE;

    for(count=0; count < edge_sets[inx].num_edges; count++)
    {
      /*
       * Check if this edge is already in the p_bdryelem array. If it is
       * already in the list don't add it again. Continue with the next edge.
       */
      in_list = FALSE;
      in_list = IsEdgeInList ( edge_sets[inx].edges[count],
                               bdry_ed_count,
                               p_bdryelem );
      if(in_list) continue;

      /*
       * Validate the edge.
       */
      stat = om$is_objid_valid ( objid = edge_sets[inx].edges[count],
                                 osnum = os ) ;
      OnErrorState( !stat, PWsts, PW_K_InvalidArg, wrapup);

      classid = omClassidFromObjid ( edge_sets[inx].edges[count], os ) ;
      if ( ! omIsAncestryValid ( classid , OPP_EMSedge_class_id ))
      {
       /****
        This is for the future. Giving the id of a loop, surface or the
        solid will result in this API unwinding the id into a list of its
        edges and rounding them.

        if( omIsAncestryValid ( classid , OPP_EMSloop_class_id ))
        {
          ;
        }
        else if( omIsAncestryValid ( classid , OPP_EMSsubbs_class_id ))
        {
          ;
        }
        else
       ****/

        OnErrorState( TRUE, PWsts, PW_K_InvalidArg, wrapup);
      }

      /*
       * Ensure that the edge being passed in lies on the sf_entity.
       */
      stat = om$send( msg = message EMSboundary.EMgetsurface_info( &msg_loc,
                               &surf_id, NULL),
                         senderid = NULL_OBJID,
                         targetid = edge_sets[inx].edges[count],
                         targetos = os );
      OnErrorState(!(1 & stat &msg_loc), PWsts, PW_K_Error, wrapup);

      stat = om$send( msg = message EMSsurface.EMgetactiveid( &msg_loc,
                                             &active_dpr, NULL ),
                         senderid = NULL_OBJID,
                         targetid = surf_id,
                         targetos = os );
      OnErrorState(!(1 & stat &msg_loc), PWsts, PW_K_Error, wrapup);

      if( active_dpr.objid != sf_entity || active_dpr.osnum != os )
         OnErrorState( TRUE,  PWsts, PW_K_InvalidArg, wrapup);

      /*
       * Check if the incoming edges are dominant & non-free edges. If the
       * edge is subordinate, get its dominant edge.
       */
      stat = om$send( msg = message EMSedge.EMget_props( &msg_loc, &ed_props),
                         senderid = NULL_OBJID,
                         targetid = edge_sets[inx].edges[count],
                         targetos = os );
      OnErrorState(!(1 & stat &msg_loc), PWsts, PW_K_Error, wrapup);

      if( ed_props & EMED_SUBORDINATE)
      {
        /*
         * If a subordinate edge has been specified get its common edge.
         */
        stat = om$get_channel_objects ( osnum = os,
                                objid = (OM_S_OBJID)edge_sets[inx].edges[count],
                                        p_chanselect = &to_common_edge,
                                        count = &chan_count,
                                        size = 1,
                                        list = common_edge );
        OnErrorState(!(1 & stat), PWsts, PW_K_Error, wrapup);

        /*
         * In case of a free edge, continue processing the other edges.
         */
        if(!chan_count) continue;

        p_bdryelem[bdry_ed_count].boundary_id.objid = common_edge[0].S_objid;
        p_bdryelem[bdry_ed_count].boundary_id.osnum = os;
      }
      else
      {
        p_bdryelem[bdry_ed_count].boundary_id.objid=edge_sets[inx].edges[count];
        p_bdryelem[bdry_ed_count].boundary_id.osnum = os;
      }

      /*
       * If this edge_set has a variable radius then all the edges of this
       * set in the boundary input are marked with EMSfillet_is_variable_radius.
       */
      if(var_rnd)
      {
        p_bdryelem[bdry_ed_count].props |= EMSfillet_is_variable_radius;

        if(count == 0)
          PWsts = PutValueInfo ( &(edge_sets[inx].start_radius),
                           &p_bdryelem[bdry_ed_count].radius); 

        if(count == edge_sets[inx].num_edges-1)
          PWsts = PutValueInfo ( &(edge_sets[inx].end_radius),
                           &p_bdryelem[bdry_ed_count].other_radius); 
      }
      else
      {
        PWsts = PutValueInfo ( &(edge_sets[inx].start_radius),
                                 &p_bdryelem[bdry_ed_count].radius); 

        PWsts= PutValueInfo( NULL, &(p_bdryelem[bdry_ed_count].other_radius));
      }

      /*
       * Only the circular cross section case is supported. Set the rho_value
       * to NULL.
       */
      PWsts = PutValueInfo ( NULL, &(p_bdryelem[bdry_ed_count].rho_value));

      bdry_ed_count++;
    }
  }

  if(is_chamfer)
    options |= EMS_RND_CHAMFER;

  if(!assoc_status)
    options |= EMS_RND_NON_ASSOCIATIVE;

  rnd_feature.objid = NULL_OBJID;
  rnd_feature.osnum = os;

  status = EMround_chamfer_edges ( &msg_loc, options, &md_env, bdry_ed_count,
                                   p_bdryelem, &p_rnderr, &rnd_feature);

  *rnd_entity = rnd_feature.objid;

  if (1 & status & msg_loc)
  {
    IGRboolean action = TRUE;
    IGRushort  bit=EMS_POST310_OBJECT | EMSIS_ACTIVE_STATE;

    status = om$send (msg = message EMSdpr.EMsetprops (&msg_loc,
                                      &action, &bit),
                    senderid = NULL_OBJID,
                    targetid = *rnd_entity,
                    targetos = os);
  }
  else
  {
    OnErrorState(!(1 & status & msg_loc), PWsts, PW_K_Error, wrapup);
  }

wrapup :

  if(p_bdryelem)
  {
     free(p_bdryelem);
  }

  if(_Pathway)
  {
    _pathway_trim = save_pw_trim;
    _pathway_orient = save_pw_orient;
  }

  PW_Wrapup (PWsts, "pwRoundEdges");
  return( PWsts);

}


static PWboolean IsEdgeInList
(
  PWobjid edge_id,
  int num_elem,
  struct EMSrnd_boundary_input *bdry_array
)
{
  int inx=0;

  for(inx=0; inx<num_elem; inx++)
    if(bdry_array[inx].boundary_id.objid == edge_id)
      return(TRUE);
  
  return(FALSE);
}

end implementation Root;
