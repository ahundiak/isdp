/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method determines the location of a point(2D) with respect to a
  loop. The location returned is one of the following - 
	EMS_L_ONEDGE   - point was on this edge
	EMS_L_ONVRTX   - point was on vertex
	EMS_L_OUTSIDE  - point was outside the loop.
History
	SM	27-Oct-87	Design and creation based on EMSloop
				method.
*/

class implementation EMSopenloop;

#include "EMS.h"
#include "emsdef.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmacros.h"

%safe
#include "math.h"
%endsafe

from EMSedge import EMpt_location;

method EMpt_location( IGRlong *EMmsg;IGRdouble *point;  
                      struct EMSptloc_info *location;
		      struct EMSpartolbasis *partolbasis)
{
    IGRlong                  sts,rc;
    IGRint                   i, doublesize, structsize;
    OMuint                   num_edges;
    struct EMSptloc_info     nst_edges[2],temp;
    IGRboolean               EFextract_par();
    OM_S_CHANSELECT          to_edges;
    IGRdouble		     partollen, dist0, dist1, new_dist;
    IGRboolean		     all_degenerate_edges = FALSE;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   doublesize = sizeof(IGRdouble);
   structsize = sizeof(struct EMSptloc_info);

/* Get the proper tolerances
*/
   if(!partolbasis->is_valid)
    {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL,partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
    }

   sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);


   location->num_located_edges=0;
   location->location = EMS_L_UNKNWN;
   location->loop_id = my_id;


/* If the option specifies that the input point is to be processed only by
   active loops and if I am inactive then just return.
*/
   if( (location->options & EMS_PTLOC_ACTLOOP) &&
       (!(ME.EMSloop->lp_props&EMLP_ACTIVE)))
	goto wrapup;


/* If the caller wants the box check to be done, see if the point is inside
   my range box or not. If the input point is outside my range box then the
   the point is definately outside me.
   The box check is done only for closed loops. Inside/Outside does not
   make sense for open loops.
*/
   if( (location->options&EMS_PTLOC_BOXCHECK) && 
       (!(ME.EMSloop->lp_props&EMLP_OPEN)))
    {
       IGRdouble range_box[4];
       IGRint size = sizeof(IGRdouble) * 4;
       OM_BLOCK_MOVE(ME.EMSloop->range,range_box,size);
       EM2dbxinc(range_box,partollen/2.0);
       if(!(EM2dptinbx(range_box,point)))
        {
          *EMmsg = EMS_S_Success;
          sts = OM_S_SUCCESS;
          location->location = EMS_L_OUTSIDE;
          goto wrapup;
        }
     }

     to_edges.type = OM_e_addr;
     to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;


/* get a count of the number of edges involved */

    sts = om$get_channel_count(object = me,
                      p_chanselect = &to_edges,count = &num_edges);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

    nst_edges[0].edge[0].nst_pt.dist = MAXDOUBLE;  /* Any big number */
    nst_edges[1].edge[0].nst_pt.dist = MAXDOUBLE;
    nst_edges[0].loop_id = nst_edges[1].loop_id = my_id;

/* Give the input point to each edge for a location test. Keep track of
   the two nearest edges.
*/
    all_degenerate_edges = TRUE;

    for(i=0;i<num_edges;i++)
     {
       location->num_located_edges = 0;
       location->location = EMS_L_UNKNWN;

       sts = om$send(msg = message EMSedge.EMpt_location
                            (EMmsg,point,location,NULL,partolbasis),
                        p_chanselect = &to_edges,from = i,to = i);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

/* If the edge returns the location as on edge or on vertex, then no
   further processing is needed.
*/
       if ((location->location == EMS_L_ONEDGE) ||
           (location->location == EMS_L_ONVRTX) )
         {all_degenerate_edges = FALSE; break;}

/* If the edge was degenerate then ignore it.
*/
       if(*EMmsg == EMS_I_DegenerateEdge) continue;

	all_degenerate_edges = FALSE;
	

       OM_BLOCK_MOVE(&location->edge[0].nst_pt.dist, &new_dist, doublesize);
       OM_BLOCK_MOVE(&nst_edges[1].edge[0].nst_pt.dist, &dist1, doublesize);

       if( ( (new_dist + partollen) < dist1) ||
	   ( ( fabs(new_dist-dist1) < partollen) &&
	     (nst_edges[1].location == EMS_L_COLLINEAR) &&
	     (location->location != EMS_L_COLLINEAR)))
            OM_BLOCK_MOVE(location, &nst_edges[1], structsize);
       
       OM_BLOCK_MOVE(&nst_edges[1].edge[0].nst_pt.dist, &dist1, doublesize);
       OM_BLOCK_MOVE(&nst_edges[0].edge[0].nst_pt.dist, &dist0, doublesize);

       if( ( (dist1 + partollen) < dist0) ||
	   ( ( fabs(dist1 - dist0) < partollen) &&
	     (nst_edges[0].location == EMS_L_COLLINEAR) &&
	     (nst_edges[1].location != EMS_L_COLLINEAR)))
          {
              OM_BLOCK_MOVE(&nst_edges[0], &temp, structsize);
              OM_BLOCK_MOVE(&nst_edges[1], &nst_edges[0], structsize);
              OM_BLOCK_MOVE(&temp, &nst_edges[1], structsize);
          }             
     }

/* If the location was neither ONVRTX or ONEDGE then set it unconditionally
   to OUTSIDE and return the info about the nearest edge.
*/
   if( (location->location != EMS_L_ONVRTX) &&
       (location->location != EMS_L_ONEDGE)
     )
    {
      OM_BLOCK_MOVE(&nst_edges[0], location, structsize);
      location->location = EMS_L_OUTSIDE;
    }

wrapup:
        EMWRAPUP(*EMmsg,sts,"In EMSopenloop.EMpt_location")
        return(sts);   
}



end implementation EMSopenloop;
