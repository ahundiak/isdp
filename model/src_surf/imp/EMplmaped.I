class implementation EMSplane;

/* 


DESCRIPTION

 The merged plane for the Unite surface state is created in this
method. The method inputs a list of surfaces and creates a plane large
enough to fit all these surfaces. All eligible surface edges are
mapped as boundaries on this plane. The EMmerge_info structure for
each edge is filled up and returned.


HISTORY

 07/09/1992  : AMD : Creation 
 08/20/92    : NP  : Modified for ANSI compliance. Added typecasts and changed
		     variable types.
 04/02/1993  : AMD : Check for return code from EMget_mapped_data.
 05/29/93   : Jack : Added code to deallocate the edgeom->(poles,knots,weights) that
                     were allocated in EMget_bcxyz_geom. (Purify)  Also, removed unused
                     declaration of OMuint dummy.

*/


#include "emsimpdef.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmapdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSfrtdef.h"
#include "EMSdpr.h"

# define  BUFF_INCR 20
# define  PT_INCR   40

from EMSedge import EMget_bcxyz_geom;
from EMSedge import EMget_props_type, 
                    EMgetsurface_info;
from EMSloop import EMgivenestinfo,
                    EMtreemod,
                    EMtoggle_type;
from EMSloopset import EMnesting, EMmakeFRT,
                       EMtreemod;

method EMmap_edges_on_plane ( IGRlong *msg;
                              struct GRvg_construct construct_list;
                              struct EMSpartolbasis *partolbasis;
                              IGRint num_surfs;
                              GRobjid *surfs;
                              IGRint *num_edinfo;
                              struct EMmerge_info **edinfo)


{
 IGRlong                           sts, stat_OM;
 struct IGRbsp_curve               *edgeom = NULL,
                                   **edgeomptr = NULL;
 struct GRid                       clip_ls, *sfedges = NULL;
 IGRint                            i, j, k, totaled, 
                                   *num_edout=NULL, array_size, numed;
 IGRuint			   edge_count;
 struct EMSgetlp_planar_info       planar_info;
 struct EMSgetlp_output            outlp;
 IGRuchar                          *edtypes = NULL;
 GRobjid                           planels, **cvinfo = NULL, 
                                   *fromed=NULL, *new_edge=NULL,
                                   srfid, newed;
 struct EMSnest_info               nesting;
 OM_S_CHANSELECT                   to_loopset, to_common_edge,
                                   to_loops;
 OM_S_OBJECT_LINKAGE               comm_edge;
 struct EMSgetlp_edgeinfo          **edout = NULL;
 IGRushort                         map_options;
 struct IGRbsp_surface             *surface=NULL, plane;
 IGRboolean                        surf_in_buffer;
 GRrange                           myrange, plane_range;
 IGRboolean                        world_range = TRUE, inrange;
 IGRdouble                         plane_u_knots[4], plane_v_knots[4],
                                   scale_factor, chtol;
 struct IGRplane                   locplane;
 IGRvector                         locplnormal;
 IGRpoint                          *rngpt = NULL, *plpts = NULL,
                                   plane_poles[4], locplpt;
 IGRint                            num_plpts, num_surf_pt, num_rng_pt;
 BSrc                              rc;
 OM_S_CHANSELECT                   to_ls, to_sf;
 struct GRmd_env                   *md_env=NULL;
 IGRlong                           surf_size;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 map_options = NULL;
 *num_edinfo = 0;
 num_plpts = 0;
 num_rng_pt = 0;
 md_env = construct_list.env_info;

 EMmake_chanselect ( EMSedge_to_common_edge, &to_common_edge );
 EMmake_chanselect ( EMSsubbs_to_loopset, &to_loopset);

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, chtol);

 /* Get the range of all surfaces */

 rngpt = (IGRpoint *) om$malloc (size = (2 * num_surfs)
                                 * sizeof (IGRpoint));

 for (i=0; i<num_surfs; i++)
 {
  sts = om$send ( msg = message GRvg.GRgetrang ( msg, 
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &world_range, myrange),
           targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, ""); 
  for (j=0; j<3; j++)
  {
   rngpt[num_rng_pt][j] = myrange[j];
   rngpt[num_rng_pt + 1][j] = myrange[3 + j];
  }

  num_rng_pt += 2;
 
  num_surf_pt = 0;

  sts = om$send ( msg = message GRvg.GRgetsize ( msg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &surf_size),
           targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, "GRvg.GRgetsize"); 

  surface = (struct IGRbsp_surface *) alloca(surf_size);

  sts = om$send ( msg = message EMSsubbs.GRgetgeom( msg,
                  &md_env->md_env.matrix_type,
                  md_env->md_env.matrix, (IGRchar *) surface),
          targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, "EMSsubbs.GRgetgeom"); 

  num_surf_pt = surface->u_num_poles * surface->v_num_poles;
/* fix for abr & abw */
  if(!num_plpts)
  {
    plpts = (IGRpoint *) om$malloc (size = (num_surf_pt)
             * sizeof (IGRpoint));
    EMerr_hndlr (! plpts , *msg, EMS_E_NoDynamicMemory, ret_end );
  }
  else
  {
    plpts = (IGRpoint *) om$realloc (ptr = (IGRchar *)plpts, size = 
            (num_plpts + num_surf_pt) * sizeof (IGRpoint));
   EMerr_hndlr (! plpts , *msg, EMS_E_NoDynamicMemory, ret_end );
  }
     
  if (surface->rational && surface->weights)
  {
   (void) BSunwght_p ( &rc, surface->poles, surface->weights, 
                       &num_surf_pt, plpts[num_plpts]);
  }
  else OM_BLOCK_MOVE ( surface->poles, &plpts[num_plpts],
                       num_surf_pt * sizeof(IGRpoint));
  
  num_plpts += num_surf_pt;
  
 }

 /* Get the range encompassing all surfaces */

 BSbx2 (msg, &num_rng_pt, rngpt, NULL, &plane_range[0], 
        &plane_range[3]);

 /* Construct a plane having this range */

 plane.poles = (IGRdouble *) plane_poles;
 plane.u_knots = (IGRdouble *) plane_u_knots;
 plane.v_knots = (IGRdouble *) plane_v_knots;
 plane.weights = NULL;

 scale_factor = 1.1;

 locplane.point = locplpt;
 locplane.normal = locplnormal;
 
 sts = MAdetplane ( msg, plpts, &num_plpts, &chtol, &locplane );
 EMomerr_hndlr (sts, ret_end, "MAdetplane"); 

 BSplptnorrg ( &plane_range[0], &plane_range[3], locplane.point,
               locplane.normal, scale_factor, &inrange, &plane, 
               &rc );

 sts = EMorient_plane ( msg, surface->poles, &plane, NULL );
 EMomerr_hndlr (sts, ret_end, "EMorient_plane"); 

 construct_list.geometry = (IGRchar *) &plane;

 /*
  *  Now find all the edges of the input surfaces which are eligible
  * for being imposed as boundaries on this plane. All edges which do
  * not have common edges with the list of input surface are eligible 
  */


 for (i=0; i<num_surfs; i++)
 {
  numed = 0;
  sfedges = NULL;
  array_size = 0;
  sts = om$send ( msg = message EMSsurface.EMgetedges ( msg,
                  EMS_OPT_NONDEG_NONSEAM, &sfedges, &array_size,
                  &numed, NULL, NULL, NULL, NULL),
           targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, "EMSsurface.EMgetedges"); 
   
   for (j=0 ; j<numed; j++)
   {
    surf_in_buffer = FALSE;

    /* check if this edge has a common edge with the list of surfs */

    sts = om$get_channel_objects(
          objid = sfedges[j].objid,
          p_chanselect = &to_common_edge,
          list = &comm_edge,
          size = 1 ,
          count = &edge_count);
    EMomerr_hndlr (sts, ret_end, "om$get_channel_objects"); 

    if(edge_count)
     {
       sts = om$send ( msg = message EMSedge.EMgetsurface_info
                     ( msg, &srfid, NULL),
                targetid = comm_edge.S_objid);
       EMomerr_hndlr (sts, ret_end, "EMSedge.EMgetsurface_info"); 

       for(k=0; k<num_surfs; k++)
        if(IF_EQ_OBJID ( srfid, surfs[k]))
        { surf_in_buffer = TRUE; break;}
     }

    if(surf_in_buffer) continue;

      /* Else the edge has passed the test. Now fill up 
         the EMmerge_info structure */

    if (! ((*num_edinfo) % BUFF_INCR))
    {
     if (!(*num_edinfo))
     *edinfo = (struct EMmerge_info *) om$malloc (size =
               (BUFF_INCR) * sizeof (struct EMmerge_info));

     else
      *edinfo = (struct EMmerge_info *) om$realloc (ptr = (IGRchar *)(*edinfo), 
      size = (unsigned) (*num_edinfo + BUFF_INCR) * sizeof 
      (struct EMmerge_info));
      EMerr_hndlr (! *edinfo , *msg, EMS_E_NoDynamicMemory, ret_end );
    } 

    if(edge_count)
    {
     (*edinfo)[*num_edinfo].edge0 = sfedges[j].objid;
     (*edinfo)[*num_edinfo].surf0 = surfs[i];      
     (*edinfo)[*num_edinfo].edge1 = comm_edge.S_objid;
     (*edinfo)[*num_edinfo].surf1 = srfid;
    }
    else
    {      
     (*edinfo)[*num_edinfo].edge0 = sfedges[j].objid;
     (*edinfo)[*num_edinfo].surf0 = surfs[i];      
     (*edinfo)[*num_edinfo].edge1 = NULL_OBJID;
     (*edinfo)[*num_edinfo].surf1 = NULL_OBJID;
    }                               
    
    (*num_edinfo)++;
   }
 /* fix for mlk */
    if (sfedges) 
      {
      om$dealloc ( ptr = sfedges ); 
      sfedges = NULL;
      }
 }
  
 if(!(*num_edinfo)) goto ret_end;


 /* Now map the eligible edges on the new plane */

 edgeom = (struct IGRbsp_curve *) alloca ( (*num_edinfo) *
                  sizeof ( struct IGRbsp_curve ));

 edgeomptr = (struct IGRbsp_curve **) alloca ( (*num_edinfo) *
                  sizeof ( struct IGRbsp_curve *));

 edtypes = (IGRuchar *) alloca ((*num_edinfo) * sizeof(IGRuchar));

 new_edge = (GRobjid *) alloca ((*num_edinfo) * sizeof(GRobjid *));

 for ( i=0; i<(*num_edinfo); i++)
 {
  edgeom[i].poles = NULL;
  edgeom[i].knots = NULL;
  edgeom[i].weights = NULL;
  edgeom[i].bdrys = NULL;
  edgeomptr[i] = &edgeom[i];

  sts = om$send ( msg = message EMSedge.EMget_bcxyz_geom (
                  msg, &md_env->md_env, NULL, NULL, 0, MAXINT,
                  FALSE, NULL, &edgeom[i]),
           targetid = (*edinfo)[i].edge0 );
  EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_bcxyz_geom"); 

  sts = om$send ( msg = message EMSedge.EMget_props_type ( msg,
                  NULL, &edtypes[i]),
           targetid = (*edinfo)[i].edge0 );
  EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props_type"); 

 }

 planar_info.edge_types = edtypes;
 
 cvinfo = (GRobjid **) alloca ((*num_edinfo) * sizeof (GRobjid *));

 for (i=0; i<(*num_edinfo); i++)
  cvinfo[i] = &(*edinfo)[i].edge0;

 planar_info.curve_info = (IGRchar **) cvinfo;
 planar_info.out_edges = &edout;
 planar_info.num_out_edges = &num_edout;

 clip_ls.objid = NULL_OBJID;
 clip_ls.osnum = OM_Gw_current_OS;

 outlp.num_objs = 0;
 outlp.objs = NULL;

 map_options = EMMapBnd_SurfIsPlane | EMMapBnd_WantBadCurves;

 sts = EMget_mapped_data ( (*num_edinfo),
                           edgeomptr,
                           NULL,
                           NULL,
                           &plane,
                           partolbasis,
                           md_env,
                           NULL,
                           NULL,
                           &outlp,
                           NULL,
                           clip_ls,
                           map_options,
                           &planar_info,
                           msg );
 EMomerr_hndlr (sts, ret_end, "EMget_mapped_data"); 

  if (!outlp.num_objs)
   {
    *msg = EMS_E_Fail;
    sts = OM_E_ABORT;
    goto ret_end;
   }

  /* Verification of the number of edges */

  totaled = 0;
  for ( i=0; i<outlp.num_objs; i++)
  {
   if ( !edout[i] || !num_edout[i] )
    {
     *msg = EMS_E_Fail;
     goto ret_end;
    }
   totaled += num_edout[i];
  }
  EMerr_hndlr((*num_edinfo) != totaled, *msg, EMS_E_Fail, ret_end);


  /* Construct a nested loopset for the plane */

  EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
  EMmake_chanselect(EMSloopset_to_surface, &to_sf);

  sts = om$construct ( classid = OPP_EMSloopset_class_id,
                       p_objid = &planels);

  /* Connect the loopset to the plane */

  sts = om$send(msg = message Root.connect(to_sf, NULL, my_id, 
                OM_Gw_current_OS, to_ls, NULL), 
           targetid = planels);
  EMomerr_hndlr (sts, ret_end, "Root.connect"); 

  for (i=0; i<outlp.num_objs; i++)
  {
   sts = om$send ( msg = message EMSloop.EMgivenestinfo( msg,
                   &nesting ),
            targetid = outlp.objs[i]);
   EMomerr_hndlr (sts, ret_end, "EMSloop.EMgivenestinfo"); 

   if(nesting.lp_props & EMLP_OPEN)
    {
     *msg = EMS_E_Fail;
     goto ret_end;
    }

   sts = om$send ( msg = message EMSloopset.EMnesting( msg,
                   &nesting, partolbasis),
            p_chanselect = &to_loopset,
            senderid = my_id);  

   if(IF_EQ_OBJID(nesting.parent, planels))
    sts = om$send(msg = message EMSloopset.EMtreemod(msg, 
                  &nesting, ADD_CHILD, partolbasis), 
             targetid = planels);
   else
    sts = om$send ( msg = message EMSloop.EMtreemod ( msg,
                   &nesting, ADD_CHILD, partolbasis),
            targetid = nesting.parent);

  }
  
  /* Make the outermost loop on the new plane a P loop and then
   toggle through */

  EMmake_chanselect ( EMSloopset_to_loops, &to_loops );

  sts = om$send ( msg = message EMSloop.EMtoggle_type ( msg,
                  TRUE, FALSE, planels, EMTogType_SendInner |
                  EMTogType_SendOuter, NULL, NULL, NULL,
                  NULL, NULL, NULL),
           senderid = planels,
           p_chanselect = &to_loops);
  EMomerr_hndlr (sts, ret_end, "EMSloop.EMtoggle_type"); 

  for ( i=0; i<outlp.num_objs; i++ )
   {
    for ( j=0; j<num_edout[i]; j++ )
     {
      newed = edout[i][j].edgeid;
       fromed = (GRobjid *) edout[i][j].info;
        {
         for (k=0; k<(*num_edinfo); k++ )
          if ( IF_EQ_OBJID ( *fromed , (*edinfo)[k].edge0))
           { new_edge[k] = newed; break; }
        }
     }
   }        

  for ( i=0; i<(*num_edinfo); i++ )
    (*edinfo)[i].new_edge = new_edge[i];


  /* Initialize the instance data */

  sts = om$send ( mode = OM_e_wrt_object,
                  msg = message GRgraphics.GRconstruct
                  ( &construct_list),
           targetid = my_id,
           senderid = my_id);
  EMomerr_hndlr (sts, ret_end, "GRgraphics.GRconstruct"); 

  /* Initialize the new gradata */

  sts = om$send ( msg = message EMSloopset.EMmakeFRT 
                ( msg, my_id ),
           targetid = planels);
  EMomerr_hndlr (sts, ret_end, "EMSloopset.EMmakeFRT"); 


ret_end:

 /*
  * Purify fix -- added this block
  */
 for ( i=0; i<(*num_edinfo); i++)
 {
  if(edgeom[i].poles)
   {
    om$dealloc ( ptr = edgeom[i].poles );
    edgeom[i].poles = NULL;     
   }

  if(edgeom[i].knots)
   {
    om$dealloc ( ptr = edgeom[i].knots );
    edgeom[i].knots = NULL;     
   }

  if(edgeom[i].weights)
   {
    om$dealloc ( ptr = edgeom[i].weights );
    edgeom[i].weights = NULL;     
   }

 }

 if (sfedges) 
   {
   om$dealloc ( ptr = sfedges ); 
   sfedges = NULL;
   }
 
 
 if (edout)
  {
   for(i=0; i<outlp.num_objs; i++)
     if(edout[i]) om$dealloc (ptr = edout[i]);
   om$dealloc(ptr = edout);
  }

 if ( *msg == EMS_E_Fail ) /* delete the plane */
 {
  stat_OM = om$send ( msg = message Root.delete(1),
               targetid = my_id);
 }
 
 if(rngpt) om$dealloc ( ptr = rngpt );
 if(plpts) om$dealloc ( ptr = plpts );
 if(num_edout) om$dealloc ( ptr = num_edout);
 if(outlp.objs) om$dealloc (ptr = outlp.objs);

return (sts);

}

end implementation EMSplane;
   
