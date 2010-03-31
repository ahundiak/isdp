/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method determines the location of a point(2D) with respect to an
  edge. The location returned is one of the following - 

	EMS_L_ONVRTX   - point was on vertex
	EMS_L_UNKNWN   - location unknown.

History
	SM    22-Oct-87   creation date

Algorithm
	If distance between the input point and the stored point is within
	tolerance then return the location as EMS_L_ONVRTX else return the
	location as EMS_L_UNKNWN.
	Also return back EMS_I_DegenerateEdge as the return code.
*/

class implementation EMSptedge;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "bsparameters.h"
%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsgeteddef.h"

from EMSloop import EMnext_edge;

method EMpt_location(IGRlong *EMmsg;IGRdouble *point; 
                 struct EMSptloc_info *location;struct EMSpartedinfo *part;
		 struct EMSpartolbasis *partolbasis)
{
    IGRint 		sts, k, rc;
    IGRdouble		partollen,distsq;
    IGRboolean		EFextract_par();
    struct EMSproj_info *proj;

    *EMmsg = EMS_S_Success;
    sts = OM_S_SUCCESS;


/* Get the proper tolerance
*/
    if(!partolbasis->is_valid)
     {
	sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL,partolbasis),targetid=my_id);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
     }

/* extract the tolerance for the parametric space
*/
    sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);

    for(k=0; k< MAX_LOCATED_EDGES; k++)
       location->edge[k].edge_id = NULL_OBJID;

    k = location->num_located_edges = 1;
    location->edge[k-1].edge_id = my_id;

/*   project the incoming point on myself.
*/    
    proj = (struct EMSproj_info *) &location->edge[k-1].nst_pt;
    OM_BLOCK_MOVE(ME.EMSptedge->point, proj->proj_pt, 2 * sizeof(IGRdouble));
    distsq = EM2ddistptpts(ME.EMSptedge->point, point);
    proj->dist = sqrt(distsq);
    proj->param.span_inx = 0;
    proj->param.param = 0.0;
    proj->location = EMScvint_collapsed;

    if(proj->dist <= partollen)
      {
        GRobjid	other_edge;

        location->location = EMS_L_ONVRTX;

        sts = EMsend_loops(&rc,message EMSloop.EMnext_edge
                           (EMmsg,EMGetEd_Previous,my_id,&other_edge),
				my_id,0,0,EMLP_ACTIVE,NULL,NULL);
         if(!(1&*EMmsg&sts)) goto wrapup;
         if(!IF_EQ_OBJID(other_edge,my_id))
          {
	    struct EMSlocated_edge temp;
	
            location->num_located_edges++;
            location->edge[1].edge_id = other_edge;
            sts = om$send(msg=message EMSedge.EMptproject
                              (EMmsg,point,1,&location->edge[1].nst_pt, 
				NULL,partolbasis),targetid = other_edge);
            if(!(1&*EMmsg&sts)) goto wrapup;
	    temp = location->edge[0];
	    location->edge[0] = location->edge[1];
	    location->edge[1] = temp;
           }

          sts = EMsend_loops(&rc,message EMSloop.EMnext_edge
                               (EMmsg,EMGetEd_Next,my_id,&other_edge),
				my_id,0,0,EMLP_ACTIVE,NULL,NULL);
          if(!(1&*EMmsg&sts)) goto wrapup;
          if(!IF_EQ_OBJID(other_edge,my_id))
           {
	     IGRint	idx;
	
	     idx = IF_NULL_OBJID(location->edge[1].edge_id) ? 1 : 2;
	     location->num_located_edges++;
	     location->edge[idx].edge_id = other_edge;
             sts = om$send(msg=message EMSedge.EMptproject
                              (EMmsg,point,1,&location->edge[idx].nst_pt, 
				NULL,partolbasis),targetid = other_edge);
             if(!(1&*EMmsg&sts)) goto wrapup;
           }
       }
      else
	 location->location = EMS_L_UNKNWN;

wrapup:
       if(1&*EMmsg&sts) *EMmsg = EMS_I_DegenerateEdge;

       EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMpt_location")
       return(sts);
}

end implementation EMSptedge;
