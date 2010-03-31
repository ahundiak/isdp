class implementation EMShorizon;


/*
   HISTORY
   
   27-Sep-91   Jack  Creation, a good portion of this code was 
                     moved from EMSsubbs.EMget_graphics_edges.
   02-Oct-91   Jack  If no horizon edges are returned, delete
                     myself. 
   08-Nov-91   Jack  Moved the call to EMset_props back to 
                     EMget_graphics_edges.  It didn't need to
                     be here.
   11-Jan-92   Jack  Moved the dealloc of the local_partgrp outside
                     of the loop since it was allocated as one chunk.
   14-Jan-92   Jack  Removed unnecessary code for initially deallocating
                     memory for local_partgrps.  Setting it to NULL is
                     sufficient.
 
   NOTES
   This method will calculate the edges for the horizon loop and 
   connect them. 



*/

#include "OMmacros.h"
#include "emsmacros.h"
#include "EMSfrtdef.h"     /* EMGL_NO_DISPLAY              */
#include "msdef.h"
#include "gocmacros.h"
#include "emsedgedef.h"    /* EMlinestring                 */
#include "EMSprop.h"       /* EMLP_ACTIVE                  */
#include "EMSopt.h"        /* nesting and profile options  */
#include "EMSbnddef.h"     /* EMSbnd.h                     */
#include "EMSbnd.h"        /* EMSpartolbasis               */
#include "bstypes.h"
#include "emsdef.h"
#include "EMdtmacros.h"
#include "EMSasnuc.h"


extern OMuword  OPP_EMSlinedge_class_id;

from EMSlinedge     import  EMleinit;
from EMSdatpln      import  EMget_pln_info;
from EMSsubbs       import  EMpartolbasis,
                            EMpartingLines, 
                            EMmk_nat_bdry;

method EMconstruct_associative ( 
                    IGRlong               *EMmsg; 
                    IGRushort      opts;
                    GRobjid                old_objid;
                    IGRint                 num_parents;
 /* struct GRid */  IGRchar               *p_info;
                    IGRint                 type;
                    IGRchar               *recomp_info;
                    struct GRvg_construct *constr_list)
{
    IGRlong           OM_stat;
    OM_S_CHANSELECT   to_helpers;
    struct GRid       ref_obj,
                      surf_obj,
                     *parent_info;
    struct GRmd_env   ref_module,
                      surf_module;
    IGRdouble         z_vector[3];
    IGRint            local_numgrps=0;
    struct BSpartgrp *local_partgrps = NULL;


    *EMmsg = EMS_S_Success;
     parent_info = (struct GRid *)p_info;


    OM_stat = EMmake_chanselect( EMSrequester_to_helpers, &to_helpers );
    if(! (1 & OM_stat)) goto wrapup;

    /* get the objects from the parent_info list, this method will
       return the GRid of the object and the objects matrix and
       matrix type
     */
    OM_stat = om$send( msg = message NDnode.ASreturn_go(
                                     &ref_obj,
                                     &ref_module.md_env.matrix_type, 
                                      ref_module.md_env.matrix),
                       targetid = parent_info[0].objid,
                       targetos = parent_info[0].osnum );
    if(! (1 & OM_stat)) goto wrapup;

    ref_module.md_id.objid = 0;
    ref_module.md_id.osnum = 0;

    OM_stat = om$send( msg = message NDnode.ASreturn_go(
                                     &surf_obj,
                                     &surf_module.md_env.matrix_type, 
                                      surf_module.md_env.matrix),
                       targetid = parent_info[1].objid,
                       targetos = parent_info[1].osnum );
    if(! (1 & OM_stat)) goto wrapup;

    surf_module.md_id.objid = 0;
    surf_module.md_id.osnum = 0;


   /* get the z_vector from the reference plane */   
   OM_stat = om$send(msg = message EMSdatpln.EMget_pln_info
                           ( EMmsg,
                             NULL,
                            &surf_module, 
                             NULL,
                             NULL,
                             z_vector,
                             NULL,
                             NULL), 
                   senderid = my_id,
                   targetos = ref_obj.osnum,
                   targetid = ref_obj.objid );
     if(! (1 & OM_stat & *EMmsg)) goto wrapup;



   { 
     /*
      * Place horizon edges
      *  This horizon code was copied almost verbatum from 
      *  EMSsubbs.EMprofile.  If there are any changes please make
      *  sure the changes are carried over to EMprofile.  Thank you
      *  for your support.
      */
       IGRboolean            loopset_constructed = FALSE,
                             world = TRUE;
       unsigned short        trim = NULL;
       IGRint                j,
                             count,
                             num_vectors;
       struct BSpartgrp     *grp;
       GRobjid               ls_id = NULL_OBJID;
       struct EMSpartolbasis partolbasis;
       OM_S_CHANSELECT       to_loopset,
                             to_owner,
                             to_edges;


       /*
        * Initialize
        */
       local_numgrps = 0;
       num_vectors = 1;

       OM_stat = EMmake_chanselect( EMSsubbs_to_loopset, &to_loopset );
       if(! (1 & OM_stat)) goto wrapup;

       trim = EMSuntrimmedParametricData;

         /*
          * Get the surface parametric tolerance.
          */
           OM_stat = om$send( msg = message EMSsubbs.EMpartolbasis(
                                        EMmsg,
                                       &surf_module.md_env.matrix_type, 
                                        surf_module.md_env.matrix,
                                       &world, 
                                       FALSE, 
                                      &partolbasis.tol ),
                              targetid = surf_obj.objid,
                              targetos = surf_obj.osnum );
           if(! (1 & OM_stat & *EMmsg)) goto wrapup;

           partolbasis.is_valid = TRUE;
           partolbasis.mattyp = &surf_module.md_env.matrix_type;
           partolbasis.mat = surf_module.md_env.matrix;



         /*
          * Calculate the parting lines
          */
         local_numgrps = 0;
         local_partgrps = NULL;
         OM_stat = om$send(msg = message EMSsubbs.EMpartingLines(
                                     EMmsg, 
                                    &surf_module, 
                                     z_vector,
                                     trim,
                                    &partolbasis, 
                                    &local_numgrps, 
                                    &local_partgrps),
                           targetid = surf_obj.objid,
                           targetos = surf_obj.osnum);
         if(! (1 & OM_stat & *EMmsg)) goto wrapup;
     


      if(local_numgrps >= 0) /* there are results */
       {

       /* Moved the construction of the horizon loop object
          from here to get_graphics_edges.  if local_numgrps == 0
          that means the current surface orientation does not require 
          any horizon edges.  We will place a horizon loop with no
          edges in this case.  If the surface does eventually get
          repositioned so that it needs horizon edges, the horizon
          loop will get an update.
        */
           /*
            * Make linear edges for each parting line group.
            */
           for(j=0, grp=local_partgrps; j<local_numgrps; grp=grp->next, j++)
           {
             GRobjid               edge_id;
             struct IGRpolyline    inpoly;
     
            if(grp->num > 0) /* this will weed out point curves */
             {

             /*
              * Construct the edge.
              */
             inpoly.num_points = grp->num;
             inpoly.points = (IGRdouble *)grp->par;
             OM_stat = om$construct(classid = OPP_EMSlinedge_class_id,
                                    p_objid = &edge_id);
             if(! (1 & OM_stat)) goto wrapup;
     
             OM_stat = om$send( msg = message EMSlinedge.EMleinit(
                                         EMmsg, 
                                         NULL, 
                                         EMlinestring,
                                        &inpoly, 
                                        &partolbasis, 
                                         NULL, 
                                         surf_obj.objid ),
                                targetid = edge_id );


             OM_stat = EMmake_chanselect( EMSedge_to_owner, &to_owner );
             EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror, wrapup );
     
             OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
             if(! (1 & OM_stat)) goto wrapup;
                

             /*
              * Add the edge to the horizon loop.
              */
             OM_stat = om$send(msg = message Root.connect(
                                    to_owner,         /* targ. chan */
                                    0,                /* targ index */
                                    my_id,            /* send objid */
                                    OM_Gw_current_OS, /* send os    */
                                    to_edges,         /* send chan  */ 
                                    0),               /* from index */
                               targetid = edge_id);
             if(! (1 & OM_stat)) goto wrapup;
             } /* end if grp->num > 0 */
           } /* for */

         /*
          * Initialize the horizon loop data.  This method will connect the
          * horizon loop to the surface.
          */
         OM_stat = om$send( msg = message EMSgraloop.EMglpinit( EMmsg, 
                                                                EMLP_ACTIVE,
                                                               &partolbasis, 
                                                                surf_obj.objid ),
                            targetid = my_id );
         if(! (1 & OM_stat & *EMmsg)) goto wrapup;


         /*
          * If there is no loopset create one.
          */
         for(count = 0; (ls_id IS NULL_OBJID) || (count <= 1); count ++)
         {
           /*
            * Get the id of the loopset.
            */
           OM_stat = om$send( msg = message EMSboundary.EMget_objid( EMmsg, 
                                                                    &ls_id ),
                              senderid = surf_obj.objid,
                              p_chanselect = &to_loopset );
           if( !( 1 & OM_stat & *EMmsg))  goto wrapup;

           if( ls_id IS NULL_OBJID )
           {
             /*
              * There is not a loopset, create one.
              */
             loopset_constructed = TRUE;
             OM_stat = om$send( msg = message EMSsubbs.EMmk_nat_bdry( 
                                                   EMmsg, 
                                                  &surf_module.md_env,
                                                   NULL ),
                                targetid = surf_obj.objid,
                                targetos = surf_obj.osnum );
             if(! (1 & OM_stat & *EMmsg)) goto wrapup;

           } /* if ls_id IS NULL_OBJID */
           count ++;

         } /* for */

         if(ls_id IS NULL_OBJID) { *EMmsg = EMS_E_Fail; goto wrapup; }

         /*
          * Update the horizon loop against the boundaries
          */
         OM_stat = om$send(msg = message EMSgraloop.EMupdate_feature(
                                          EMmsg, 
                                         &surf_module.md_env.matrix_type,
                                          surf_module.md_env.matrix ),
                           targetid = my_id);
         if(! (1 & OM_stat & *EMmsg)) goto wrapup;

       } /* if there are results */
      else 
       { /* if the surface is an ancestor of EMSplane, then it will
            never get horizon edges so delete myself.  I set local_numgrps
            to -1 in EMpartingLines if this was the case. */
        OM_stat =  om$send(msg      = message Root.delete(1),
                           targetid = my_id,
                           targetos = OM_Gw_current_OS);
        if(! (1 & OM_stat)) goto wrapup;
       }
   }  /* end block -- place horizon edges  */


wrapup:

  /*
   * Free the memory for the parting line data.
   */
  if(local_partgrps)
  {
    int                i;
    struct BSpartgrp  *grp;
  
    for( i = 0, grp = local_partgrps; i < local_numgrps; i++ )
    {
      if(grp->pts)  om$dealloc(ptr = grp->pts);
      grp->pts = NULL; 
      if(grp->par)  om$dealloc(ptr = grp->par);
      grp->par = NULL;
      grp = grp->next;
    }
    /* deallocate this memory outside of the loop since it was
       allocated as one chunk.
     */  
    om$dealloc(ptr = local_partgrps);
  }

    EMWRAPUP (*EMmsg, OM_stat, "EMShorizon.EMconstruct_associative");
    return (OM_stat);
}

end implementation EMShorizon;

