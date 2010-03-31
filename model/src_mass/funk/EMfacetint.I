/* ###################   APOGEE COMPILED   ################## */
/*
	This function computes integrals needed for mass/area properties
	evaluation based on incoming surf_data structure

	option = 0	mass properties
	       = 1	all area properties
	       = 2	surface area only

govinda :            creation
gupta   : 12/09/88   rewritten to consider topology and solve the problem
                     of gaps, non-planarity of facets and good
                     triangulation
 
*/

class implementation GRvg;

#include    "EMS.h"
#include    "emsmacros.h"
#include    "bserr.h"
#include    "bsparameters.h"
#include    "emsdef.h"
#include    "emserr.h"
#include    "EMSmsgdef.h"
#include    "emsdattyp.h"
#include    "emsinter.h"
#include    "EMSbnddef.h"
#include    "EMSbnd.h"
#include 	"emsmass.h"
#include	"wanginc.h"
#include    "EMSopt.h"
#include    "EMSprop.h"

#define SOLID   1
#define	HOLE    0
#define BOUND  -1

from EMSsubbs import    EMget_edges,
                        EMpartolbasis;
from EMSedge  import    EMpyxyz_geometry,
                        EMget_props,
                        EMget_sf_geom;
from EMSboundary import EMget_objid,
                        EMgetsurface_info;

EMfacetint(EMmsg, my_env, trans_vector, surface, surf_id, surf_data,
           option, density, prop)

IGRlong			      *EMmsg;
struct GRmd_env       *my_env;
IGRvector             trans_vector;
struct IGRbsp_surface *surface;
struct GRid           *surf_id;
struct BNsf_data      *surf_data;
IGRlong               option;
IGRdouble             *density;
IGRdouble             *prop;

{
  IGRlong                stat_OM, msg;
  IGRushort      edge_prop;
  IGRlong                num_poles,  boundary_type;
  IGRint                 i, j, k, a_id, c_id,
                         facet_id, patch_cnt, save_index;
  IGRint                 num_points=5, num_iso, num_tply;
  IGRint                 num_edges = 0, buf_size = 0;
  IGRint                 f_type, swap_index;
  OMuint		 comm_edge_cnt;
  IGRdouble              knot_tol, bastol, quad_points[15];
  IGRdouble              scratch, loc_prop[NUMB_PROPS];
  extern IGRdouble       fabs();
  IGRshort               *facet_map;
  IGRushort      py_option;
  IGRboolean             swap_geometry, in_there, world;
  IGRboolean             swap_valid;
  struct GRid            *edges = NULL, comm_surf_GRid;
  struct IGRbsp_surface  *surf_geom, *comm_surface;
  struct EMtopology_info *topology;
  struct BNpatch         *patch_data;
  struct Facetloop       *loop_data;
  struct EMfacet_data    fct_data;
  struct EMpatch_bounds  pch_bnds;
  struct EMSpartolbasis  my_partol, other_partol;
  OM_S_CHANSELECT        to_common_edge;
 
/*-------------------------------------------------------------------*/

stat_OM = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);
BSEXTRACTPAR (&msg, BSTOLLENVEC, bastol);

stat_OM = om$make_chanselect(channame ="EMSedge.to_common_edge",
                             p_chanselect = &to_common_edge);
if (! (1 & stat_OM)) goto wrapup;

topology = NULL;
world = TRUE;

for(i=0; i<NUMB_PROPS; i++)
    loc_prop[i] = 0.0;

pch_bnds.numu = 0;
pch_bnds.numv = 0;
pch_bnds.u_pars = NULL; pch_bnds.v_pars = NULL;

pch_bnds.u_pars = (IGRdouble *) om$malloc (size = surf_data->n_pat *
                                                 sizeof(IGRdouble)); 
pch_bnds.v_pars = (IGRdouble *) om$malloc (size = surf_data->n_pat *
                                                 sizeof(IGRdouble)); 

for (i=0; i<surf_data->n_pat; i++)
 {
  patch_data = (struct BNpatch *) (surf_data->pat_ary[i]);

  if ((patch_data->ud > knot_tol) && (patch_data->ud < 1-knot_tol))
   {
    in_there = FALSE;
    for (j=0; j<pch_bnds.numu; j++)
     {
      if(fabs(patch_data->ud - pch_bnds.u_pars[j]) <= knot_tol)
       {
        in_there = TRUE;
        break;
       }
     }
    if (! in_there)
     {
      pch_bnds.u_pars[pch_bnds.numu] = patch_data->ud;
      (pch_bnds.numu)++; 
     }
   }

  if ((patch_data->vd > knot_tol) && (patch_data->vd < 1-knot_tol))
   {
    in_there = FALSE;
    for (j=0; j<pch_bnds.numv; j++)
     {
      if(fabs(patch_data->vd - pch_bnds.v_pars[j]) <= knot_tol)
       {
        in_there = TRUE;
        break;
       }
     }
    if (! in_there)
     {
      pch_bnds.v_pars[pch_bnds.numv] = patch_data->vd;
      (pch_bnds.numv)++; 
     }
   }
 }

edges = NULL;

stat_OM = om$send(msg = message EMSsubbs.EMget_edges(&msg, MAXINT,
                        EMS_OPT_NONDEG, my_env, &edges, &buf_size,
                        &num_edges),
                  senderid = NULL_OBJID,
                  targetid = surf_id->objid);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);

num_iso = pch_bnds.numu + pch_bnds.numv;
num_tply = 2 * num_edges + num_iso;

topology = (struct EMtopology_info *) om$malloc (size = num_tply *
                                     sizeof (struct EMtopology_info)); 

for (i=0; i<num_tply; i++)
 {
  topology[i].poly = (struct IGRpolyline *) om$malloc (size =
                                         sizeof (struct IGRpolyline));
  topology[i].poly->points = NULL;
  topology[i].poly->num_points = 0;
 }

stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                         &my_env->md_env.matrix_type,
                         my_env->md_env.matrix, &world, FALSE,
                         &my_partol.tol),
                   senderid = NULL_OBJID,
                   targetid = surf_id->objid);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

my_partol.in_world = TRUE;
my_partol.is_valid = TRUE;
my_partol.mattyp = &my_env->md_env.matrix_type;
my_partol.mat = my_env->md_env.matrix;

other_partol.in_world = FALSE;
other_partol.is_valid = FALSE;
other_partol.mattyp = &my_env->md_env.matrix_type;
other_partol.mat = my_env->md_env.matrix;

j=0;

for (i=0; i<(pch_bnds.numu); i++)
 {
  topology[i].boundary_poly = FALSE;
  topology[i].pygeom_sacked = FALSE;
  topology[i].u_dir = TRUE;
  topology[i].param = pch_bnds.u_pars[j++];

  MSpyxyz_geometry (&msg, TRUE, &topology[i].param, surface,
                    topology[i].poly);
  EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
 }

j=0;

for (i=(pch_bnds.numu); i<num_iso; i++)
 {
  topology[i].boundary_poly = FALSE;
  topology[i].pygeom_sacked = FALSE;
  topology[i].u_dir = FALSE;
  topology[i].param = pch_bnds.v_pars[j++];

  MSpyxyz_geometry (&msg, FALSE, &topology[i].param, surface,
                    topology[i].poly);
  EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
 }

py_option = EMonly_If_Dominant;

for (i=num_iso; i<num_tply; i+=2)
 {
  topology[i].edge_id = edges[(i-num_iso)/2].objid;
  topology[i].boundary_poly = TRUE;
  topology[i+1].boundary_poly = TRUE;
  swap_geometry = FALSE;

  stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                          &edge_prop),
                    senderid = NULL_OBJID,
                    targetid = topology[i].edge_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  
  if ((! (edge_prop & EMED_SUBORDINATE)) ||
      ((edge_prop & EMED_SUBORDINATE) && (edge_prop & EMED_ISO)))
   {
    swap_valid = FALSE;
    stat_OM = om$send (msg = message EMSedge.EMpyxyz_geometry(&msg,
                             my_env, surf_id, surface, 0, MAXINT,
                             FALSE, NULL, topology[i].poly, &my_partol,
                             &num_iso, topology, &swap_valid, &swap_index,
                             py_option),
                       senderid = NULL_OBJID,
                       targetid = topology[i].edge_id);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    if (edge_prop & EMED_SUBORDINATE)
     {
      if (swap_valid) {swap_geometry = TRUE; save_index = swap_index;}
      if (topology[i].poly->points)
          om$dealloc (ptr = topology[i].poly->points);
      topology[i].poly->points = NULL;
     }
   }

  stat_OM = om$get_channel_count (osnum = my_env->md_id.osnum,
                                  objid = topology[i].edge_id,
                                  p_chanselect = &to_common_edge,
                                  count = &comm_edge_cnt);
  if (! (1 & stat_OM)) goto wrapup;

  if (! comm_edge_cnt)
   {
    topology[i+1].edge_id = NULL_OBJID;
   }
  else
   {
    comm_surface = NULL;

    stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                            &topology[i+1].edge_id),
                      senderid = topology[i].edge_id,
                      p_chanselect = &to_common_edge);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                            (&msg, &comm_surf_GRid.objid, &other_partol),
                      senderid = NULL_OBJID,
                      targetid = topology[i+1].edge_id);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    comm_surf_GRid.osnum = OM_Gw_current_OS;

    stat_OM = om$send(msg = message EMSedge.EMget_sf_geom(&msg,
                            &comm_surf_GRid, &surf_geom,
                            &my_env->md_env),
                      senderid = NULL_OBJID,
                      targetid = topology[i+1].edge_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    if (surf_id->objid == comm_surf_GRid.objid)
     {
      comm_surface = surface;
     }
    else
     {
      comm_surface = surf_geom;

      if (trans_vector)
       {
        num_poles = comm_surface->u_num_poles * comm_surface->v_num_poles;

        j = 0;

        for(k=0; k<num_poles; k++)
         {
          scratch = (comm_surface->rational) ? (comm_surface->weights[k])
                                             : (1.0);

          comm_surface->poles[j] -= (trans_vector[0] * scratch);
          j++;
          comm_surface->poles[j] -= (trans_vector[1] * scratch);
          j++;
          comm_surface->poles[j] -= (trans_vector[2] * scratch);
          j++;
         }
       }
     }

    stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                            &edge_prop),
                      senderid = NULL_OBJID,
                      targetid = topology[i+1].edge_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  
    if (! (edge_prop & EMED_SUBORDINATE))
     {
      swap_valid = FALSE;
      stat_OM = om$send (msg = message EMSedge.EMpyxyz_geometry(&msg,
                               my_env, &comm_surf_GRid, comm_surface, 0,
                               MAXINT, FALSE, NULL, topology[i+1].poly,
                               &other_partol, &num_iso, topology,
                               &swap_valid, &swap_index, py_option),
                         senderid = NULL_OBJID,
                         targetid = topology[i+1].edge_id);
      EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

      if (swap_geometry)
       {
        topology[save_index].poly->num_points =
                                           topology[i+1].poly->num_points;
        topology[save_index].poly->points = topology[i+1].poly->points;
       }
     }

    if ((surf_id->objid != comm_surf_GRid.objid) && (comm_surface))
         om$dealloc (ptr = comm_surface);
   }
 }

for(patch_cnt=0; patch_cnt<surf_data->n_pat; patch_cnt++)
 {
  patch_data = (struct BNpatch *) (surf_data->pat_ary[patch_cnt]);

  if(patch_data->solid == HOLE)
     continue;                                    /* next patch */

  /*   What's left are:   wholly solids
   *                      partial facets with loops in them
   */

  MSpatch_boundary_type (patch_data, knot_tol, &boundary_type);

  facet_map = patch_data->bit_map;

  facet_id = 0;
  a_id     = 0;
  c_id     = patch_data->nu;

  for(i=0; i<(patch_data->nv - 1); i++)
   {
    for(j=0; j<(patch_data->nu - 1); j++)
     {
      if((patch_data->solid == SOLID) || (facet_map[facet_id] == SOLID))
       {
        if ((surface->planar) && (! surface->poles))
         {
          MSquadint(option, &patch_data->xyz_tp[a_id][0],   /* A */
                    &patch_data->xyz_tp[a_id+1][0],         /* B */
                    &patch_data->xyz_tp[c_id][0],           /* C */
                    &patch_data->xyz_tp[c_id+1][0],         /* D */
                    loc_prop);
         }
        else
         {
          for (k=0; k<3; k++)
           {
            quad_points[k] = patch_data->xyz_tp[a_id][k];
            quad_points[k+3] = patch_data->xyz_tp[a_id+1][k];
            quad_points[k+6] = patch_data->xyz_tp[c_id+1][k];
            quad_points[k+9] = patch_data->xyz_tp[c_id][k];
            quad_points[k+12] = patch_data->xyz_tp[a_id][k];
           }

          MSfacet_boundary_type (boundary_type, &i, &j, patch_data->nv,
                                 patch_data->nu, patch_data, &fct_data,
                                 quad_points, bastol, &f_type);

          if (f_type == NOT_ON_FACET_BND)
           {
            MSnon_planar_quadint (option, num_points, quad_points,
                                  surface, patch_data, loc_prop);
           }
          else
           {
            EMboundary_quadint (&msg,
                                &patch_cnt,
                                quad_points,
                                &fct_data,
                                patch_data,
                                num_tply,
                                topology,
                                &my_partol.tol,
                                option,
                                surface,
                                loc_prop);
            EMerr_hndlr(!(1 & msg), *EMmsg, EMS_E_Fail, wrapup);
           }
         }
	   }
      facet_id ++;
      a_id ++;
      c_id ++;
     }		/* for along_u */

    /* a_id and c_id point to the last point of the row i
     * so make them point to the first point of the row i +1
     */
    a_id ++;    /* points to u=0 point */
    c_id ++;    /* points to u=0 point */
   }            /* for along_v */

  /*
   *   All quad elements have been considered. Now consider
   *   the cases  with loops in them
   */

  if(! patch_data->n_loop)
     continue;                /* retrieve next patch */

  for(i=0; i<patch_data->n_loop; i++)
   {
    loop_data = (struct Facetloop *)&patch_data->fct_lp[i];
	
    EMboundary_loopint (&msg,
                        &patch_cnt, &i,
                        patch_data->plannar,
                        loop_data,
                        num_tply,
                        topology,
                        &my_partol.tol,
                        option,
                        surface,
                        loc_prop);
    EMerr_hndlr(!(1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   }        /* for loop count */
 }          /* patch_cnt      */

if(option == 0)	/* mass prop */
 {
  for(i=1; i<11; i++)
      loc_prop[i] *= (*density);
 }

for(i=0; i<NUMB_PROPS; i++)
    prop[i] += loc_prop[i];

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMfacetint");

 for (i=0; i<num_tply; i++)
  {
   if (topology[i].poly->points)
       om$dealloc (ptr = topology[i].poly->points);
       topology[i].poly->points = NULL;
   if (topology[i].poly) om$dealloc (ptr = topology[i].poly);
  }

 if (topology) om$dealloc (ptr = topology);
 if (pch_bnds.u_pars) om$dealloc (ptr = pch_bnds.u_pars);
 if (pch_bnds.v_pars) om$dealloc (ptr = pch_bnds.v_pars);

 return (stat_OM);

}

end implementation GRvg;
