/* ###################   ANSI COMPILED   ################## */
/*
NAME:
  
  Methods: 
   EMdim 
   EMdimparam

  Functions:
   static void EFget_edge_midpt_and_sf_nor()
   IGRlong EFget_dimension_plane_and_geom()
   IGRlong EFget_edge_near_point_on_sf()
   IGRlong EFfind_outer_surface_and_edge_by_ptproject()

 
ABSTRACT:
 
   These are the autodimension methods for Phoenix Thinwall Solids and
   supporting functions.

ARGUMENTS:

RETURN VALUES:

ALGORITHM:

NOTES:

KEYWORDS:
 
HISTORY:

   Sudhakar :  23Apr'93 :  Creation
   Sudha    :  06/23/93 :  Modified for BSprototype ansification
   Sudhakar :  25Jun'93 :  Set appropriate sign for the 'surf_nor' in
                           determining the 'boreline' for projecting
                           onto the outer solid.
   Sudhakar :  24Sep'93 :  Modified to handle 'auto-dimensioning' using
                           only surface parents and 'uv' data in the 'recompute'
                           info. Removed dependance on 'edge' parents.
                           Modified to use a different approach for finding
                           the outer surface to be dimensioned in case of
                           'outer' and 'symmetric' thinwall solids.
   Sudhakar :  30Sep'93 :  Modified to handle 'Pre- EMS 2.4' models.
   Sudhakar :  27Nov'93 :  Added three args to the function 
                           'EFget_edge_near_point_on_sf' function. This 
                           generalizes this function and allows the caller
                           to know whether the input point lies on the boundary
                           or inside, and also to get back the 'uv' and
                           'xyz' point on the edge, if needed. Modified all
                           calls to this function.
   Sudhakar :  23Dec'93 :  Modified to use the time-consuming projection 
                           on the outer solid only for "symmetric" thinwall
                           solids.
   Sudhakar :  12Jan'94 :  Modified the choice of the view-to-dimension-in 
                           to be perpendicular to both the surface normal
                           and the edge tangent. 
*/
class implementation EMSshslbool;

#include "OMmacros.h"
#include "dimdef.h"
#include "dimplcmacros.h"
#include "EMSdimdef.h"
#include "EMSas.h"
#include "EMSconstruct.h"
#include "EMSkey.h"
#include "REsfsolid.h"
#include "REshsolid.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bscrossp.h"

%safe

static void EFget_edge_midpt_and_sf_nor();

%endsafe 

#define COMMON_THICKNESS   0

#define CURVE       0
#define VECTOR      2

#define REV_BASE    1
#define REV_DIR     2
#define REV_START   3
#define REV_SWEEP   4

#define FIRST       0
#define SECOND      1

#define X  0
#define Y  1
#define Z  2


#define BASE        0
#define HEIGHT      1
#define DIRECTION   2
#define DIAMETER    3

#define XYZ_POINT   1
#define UV_POINT    2

#define USE_PROJECT 1
#define USE_KEY     2

#define DONOT_REVERSE_NORMAL  0
#define REVERSE_NORMAL        1

from EMSparamgm  import EMgetgeom;
from expression  import NDgive_value;
from EMSedge import EMgetsurface_info, EMinternalpt, EMtangent;
from EMSsubbs import EMpartolbasis, EMget_unit_norm;
from EMSpointer import EMpass;
from EMSloopset import EMpt_location;
from GRcurve import GRmidpoint, GRtotlength, EMcvtanorm;
from EMSloop import EMptinside, EMget_props;

extern OMuword OPP_DMroot_class_id;
extern OMuword OPP_EMScomposite_class_id;


method EMdim ( IGRlong             * msg;
               struct GRmd_env     * mod_env;
               IGRushort     options;
               IGRint                type;
               IGRchar             * info;
               IGRint                num_parents;
               struct GRid         * parents )
{
    IGRlong             om_msg = OM_S_SUCCESS, msg_loc;
    struct GRid         assoc_id, source_id, dim_id;
    IGRpoint            dumpt;
    IGRint              trak_dir;
    IGRdouble           trak_dist;
    struct EMSshell_solid  *recomp;
    IGRint                 num_mult_tks, ii;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    /* Get the 'number of multiple thicknesses' from the recompute-info */

    if(info)
    {
      recomp = (struct EMSshell_solid *) info;
      num_mult_tks = recomp->num_mult_tks;
    }
    else
      num_mult_tks = 0;


    for(ii=0; ii<num_mult_tks+1; ii++)
    {    
      /*
       * Dimension each thickness if it hasn't already been done.
       *  The first one is the 'common thickness'. The rest are 
       *  multiple thicknesses.
       */
      if (!(EFselect_first_component (&parents[ii], 
                                      OPP_DMroot_class_id, 
                                      &dim_id) & 1))
      {
          dim_id.objid = NULL_OBJID;
          trak_dir = 1;
          trak_dist = 0.0;
  
          dm$place_sglpara ( orig_grid    = &source_id,
                             orig_pt      = dumpt,
                             plane_grid   = &source_id,
                             brk_pos      = BRK_LEFT,
                             trak_dir     = trak_dir,
                             trak_dist    = trak_dist,
                             owner        = &parents[ii],
                             dim_grid     = &dim_id );
          EMerr_hndlr (dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
      }
    }
  
  
ret_end:

    EMWRAPUP (*msg, om_msg, "EMSshsldim.EMdim");

    return (om_msg);
}

method EMdimparam ( IGRlong            * msg; 
                    struct GRmd_env    * mod_env;
                    IGRushort            options;
                    IGRint               type;
                    IGRchar            * info;
                    IGRint               num_parents;
                    struct GRid        * parents;
                    IGRint               index; 
                    struct IGRplane    * dim_plane;
                    IGRdouble          * dim_plane_xaxis;
                    struct EMSgeomdata * dim_geom;
                    IGRint             * dim_type )
{
    IGRint              i, ii;
    IGRlong             msg_loc, om_msg = OM_S_SUCCESS;
    GRobjid             solidobj;
    OMuword             dumos; 
    IGRpoint            dimplpt;
    IGRvector           dimplnor, dimplxaxis;
    IGRdouble           dimgeom[6];
    IGRdouble           distance;
    OM_S_CHANSELECT     to_comps;
    struct EMSshell_solid  *recomp = NULL;
    struct mult_tk_surfs_views *mult_tk_sfs = NULL;
    IGRboolean          is_inward, is_symmetric, post_220;
    OMuword             best_view_index = 0;
    IGRint              parent_surf_index, num_mult_tks, numsf;
    struct  GRid        surf_pointer_GRid, dimension_surf_GRid, 
                        dimension_edge_GRid, surfs;
    IGRpoint            uv_point;
    GRobjid             nearest_edge, new_surf, new_ed;
    
    IGRlong EFget_dimension_plane_and_geom();
    IGRlong EFget_edge_near_point_on_sf();
    IGRlong EFfind_outer_surface_and_edge_by_ptproject();

    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    /* Determine whether the thinwall solid is 'inward', 'outward' or
       'symmetric' */

    if(info)
    {
       recomp = (struct EMSshell_solid *) info;
       is_inward = recomp->inward;
       is_symmetric = recomp->is_symmetric;
       num_mult_tks = recomp->num_mult_tks;
       post_220 = TRUE;
    }
    else
    {
      /* Pre-EMS 2.4 Models */
       is_inward = TRUE;
       is_symmetric = FALSE;
       num_mult_tks = 0;
       post_220 = FALSE;

#ifdef DEBUG
printf("Its a Pre-EMS 2.4 Model\n");
#endif
    }

    /* determine the shell solid thickness   */
    om_msg = om$send (msg = message expression.NDgive_value (&distance),
             targetid = parents[index].objid);
    EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_InvalidCase, ret_end);

    /* Get the objid of the component at index 0 of my_id.
        This is the outer component of the thinwall boolean difference.
        The auto-dimension is to be placed on an edge of the outer
        component.  */

    EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    om_msg = om$get_objid_at_index(objid = my_id,
                     osnum = OM_Gw_current_OS,
                     p_chanselect = &to_comps, index = 0,
                     objidaddr = &solidobj,
                     osnumaddr = &dumos);
    EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);
  
    /* Determine the Dimension plane point, Dimension plane normal
       and the Dimension Geometry for the associative solid. */

    /* Get the current surface to be dimensioned,and the 'uv' point on the
       surface to be used for dimensioning. */

    if(post_220)
    {    
       parent_surf_index =  1 + num_mult_tks;

       mult_tk_sfs = recomp->sfs_views;

       if(index > 0)     /* refers to a multiple thickness */
       {
          parent_surf_index++;  /* Index to first multiple thick surface */
   
          for(ii=1; (ii<index) && (index <= num_mult_tks); ii++)
                 parent_surf_index += mult_tk_sfs[ii].num_sfs_per_mult_tks;
       }
   
       OM_BLOCK_MOVE(&parents[parent_surf_index], &surf_pointer_GRid,
                                           sizeof(struct GRid));

       om_msg = om$send (msg = message EMSpointer.ASreturn_go
                                  (&dimension_surf_GRid, 
                                   &mod_env->md_env.matrix_type,
                                   mod_env->md_env.matrix),
                      targetid = surf_pointer_GRid.objid,
                      targetos = surf_pointer_GRid.osnum,
                      senderid = NULL_OBJID);
       EMerr_hndlr(!(1 & om_msg) || dimension_surf_GRid.objid == NULL_OBJID, 
                                              *msg, EMS_E_Fail, ret_end);

       /* 'uv' point */
       uv_point[0] = mult_tk_sfs[index].uv_point[0];
       uv_point[1] = mult_tk_sfs[index].uv_point[1];
    }
    else
    {

     /* Since no surface is specified for dimensioning in the 
        'Pre-EMS 2.4' models, get the first component surface of 
        'solidobj' and use it for auto-dimensioning. */

     /* There should be atleast one component surface for auto-dimensioning */
       numsf=0;
       om_msg = om$send(msg = message GRowner.GRget_number_components(
                                &msg_loc, &numsf ),
                     senderid = NULL_OBJID,
                     targetid = solidobj,
                     targetos = dumos );
       EMerr_hndlr(EMSerror(om_msg & msg_loc) || (numsf <= 0), 
                                               *msg, EMS_E_Fail, ret_end);
       numsf = 1;
       om_msg = om$send( msg = message GRowner.GRget_components(
                            &msg_loc, mod_env, &surfs, numsf,
                            &numsf, 0, 0),
                    senderid = NULL_OBJID,
                    targetid = solidobj,
                    targetos = dumos );
       EMerr_hndlr(! (1 & om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
       dimension_surf_GRid.objid = surfs.objid;
       dimension_surf_GRid.osnum = surfs.osnum;
       
       /* Assumed 'uv' point */
       uv_point[0] = 0.0;
       uv_point[1] = 0.0;
    }

    /* Determine the edge nearest to the 'uv' point on the surface */

    om_msg = EFget_edge_near_point_on_sf(&msg_loc, mod_env, 
                                          dimension_surf_GRid,
                                          UV_POINT,
                                          uv_point,
                                          NULL,
                                          &nearest_edge, NULL, NULL);
    EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_EdgeError, ret_end);

    dimension_edge_GRid.objid = nearest_edge; 
    dimension_edge_GRid.osnum = dimension_surf_GRid.osnum; 

    if(post_220)
    {
       if(!(index > recomp->num_mult_tks))
         best_view_index =  mult_tk_sfs[index].best_view_index;
       else
         printf("Error - 'index' exceeds 'num_mult_tks' \n");
    }
    else
       best_view_index = 1;

    if(is_symmetric)
    {
       om_msg = EFfind_outer_surface_and_edge_by_ptproject(&msg_loc, mod_env,
                               USE_PROJECT,
                               is_inward, is_symmetric, distance,
                               solidobj,
                               dimension_surf_GRid, dimension_edge_GRid,
                               &new_surf, &new_ed);

       EMerr_hndlr ((EMSerror (om_msg & msg_loc) || new_surf == NULL_OBJID ||
                                                   new_ed == NULL_OBJID),
                                *msg, EMS_E_Fail, ret_end);

       dimension_surf_GRid.objid = new_surf;
       dimension_edge_GRid.objid = new_ed;
    };

    EFget_dimension_plane_and_geom(&msg_loc,
                                   mod_env, 
                                   DONOT_REVERSE_NORMAL, 
                                   &distance,
                                   dimension_surf_GRid,
                                   dimension_edge_GRid,
                                   best_view_index,
                                   &dimplpt[0],
                                   &dimplnor[0],
                                   &dimplxaxis[0],
                                   &dimgeom[0]);

    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (dim_type)
    {
        *dim_type = SINGLE_PARALLEL;
    }

    if (dim_plane)
    {

        memcpy (dim_plane->point, dimplpt, sizeof(IGRpoint));
        memcpy (dim_plane->normal, dimplnor, sizeof (IGRvector));
    }

    if (dim_plane_xaxis)
    {
        memcpy (dim_plane_xaxis, dimplxaxis, sizeof (IGRvector));
    }

    if (dim_geom)
    {
        dim_geom->geomtype = GEOMDATA_LINE;
        dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
        dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
        for (i=0; i<3; ++i)
         {
           /* Reverse the dim. points only for outward offset */
            dim_geom->line.line_pt1[i] = ((is_inward || is_symmetric) ?
                                            dimgeom[i] : dimgeom[i+3]);
            dim_geom->line.line_pt2[i] = ((is_inward || is_symmetric) ?
                                            dimgeom[i+3] : dimgeom[i]);
         }

    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMSshslbool.EMdimparam");
/*
    if(surfs) om$dealloc(ptr = surfs); 
 */
    return (om_msg);
}

/****************************************************************************/

  IGRlong EFfind_outer_surface_and_edge_by_ptproject(msg, md_env, option,
                                        is_inward, is_symmetric,
                                        current_thickness,
                                        outer_solid,
                                        dimension_surf_GRid,
                                        dimension_edge_GRid,
                                        new_surf, new_edge)
   IGRlong         *msg;
   struct GRmd_env *md_env;
   IGRushort       option;
   IGRboolean      is_inward, is_symmetric;
   IGRdouble       current_thickness;
   GRobjid         outer_solid;
   struct GRid     dimension_surf_GRid, dimension_edge_GRid;
   GRobjid         *new_surf, *new_edge;
 {

  /* Project this point onto the outer solid, and
   * redetermine the corresponding surface and edge ids. 
   *  Find the surf on the outer solid corresponding to the
   *  'dimension_surf_GRid'.
   */ 
    
    GRobjid                 proj_surf[3];
    IGRint                  ii, numpts;
    IGRuint                 attempt_no;
    IGRpoint                pts[3];
    struct GRparms          proj_parms;
    IGRpoint                edge_point, surfpt;
    IGRdouble               surf_nor[3];
    IGRboolean              surface_found = FALSE;

    IGRlong msg_loc, stat_OM = OM_S_SUCCESS;

    IGRlong EFget_edge_near_point_on_sf();

    *msg = EMS_S_Success;
    *new_surf = *new_edge = NULL_OBJID;

   /* To avoid Compiler Warnings */
    is_inward = is_inward;
    current_thickness = current_thickness;

   /* STEPS:

       1. Find three internal points on the surface.
       2. 'GRptproject' each of these points onto the 'outer_solid'.
       3. If the component surface obtained out of the three projections
          is the same, then continue else fail.
       4. IF option is 'USE_KEY'
            Generate the key for the 'dimension-edge' on the original surface.
            Use the key to generate the corresponding edge on the new surface.
          ELSE if option is 'USE_PROJECT'
            'GRptproject' the edge midpoint onto the new-surface and get the
             nearest edge.
    */

   numpts = 3;
   attempt_no = 0;
   stat_OM = om$send( msg = message EMSsubbs.EMget_point_on_surface(&msg_loc,
                                                 md_env, attempt_no,
                                                 numpts, (IGRdouble *)pts,
                                                 NULL),
                      senderid = NULL_OBJID,
                      targetid = dimension_surf_GRid.objid,
                      targetos = dimension_surf_GRid.osnum);
   EMerr_hndlr (!(1&stat_OM&msg_loc),*msg,EMS_E_Fail,ret_end);

  /* For each of the three points do a 'pt-project' onto the 'outer-solid' */
  for(ii=0; ii<3; ii++)
  {
     stat_OM = = om$send ( msg = message GRgraphics.GRptproject(&msg_loc,
			           &md_env->md_env.matrix_type, 
			           md_env->md_env.matrix, 
                                   pts[ii], 
                                   surfpt,
                                   &proj_parms),
                          senderid = NULL_OBJID,
                          targetid = outer_solid,
                          targetos = dimension_edge_GRid.osnum);
     EMerr_hndlr (!(1&stat_OM&msg_loc),*msg,EMS_E_Fail,ret_end);
     proj_surf[ii] = proj_parms.leaf_id.objid;

#ifdef DEBUG
printf("The %d th surface by pt-project is %d\n", ii, proj_surf[ii]);
#endif
  }
  
  /* 
   * Compare the three objids obtained.  
   * If the surface ids of all surfaces located through 'ptproject' are
   * the same, except for the 'symmetric' case, the corresponding surface
   * has been successfully found. For the 'symmetric' case, if any two
   * objids match, that is taken as the corresponding surface. This is
   * required because there are two equi-distant surfaces in case of the
   * 'symmetric' offset. 
   */   

  surface_found = FALSE;
  if(proj_surf[0] == proj_surf[1])
     if(is_symmetric || (proj_surf[1] == proj_surf[2]))
     {
         surface_found = TRUE;
         *new_surf = proj_surf[1];
     }
  else if(proj_surf[0] == proj_surf[2])
           if(is_symmetric)
           {
              surface_found = TRUE;
              *new_surf = proj_surf[0];
           }
  else if(proj_surf[1] == proj_surf[2])
           if(is_symmetric)
           {
              surface_found = TRUE;
              *new_surf = proj_surf[1];
           }
  else
     surface_found = FALSE;

  if(surface_found)
  {
     IGRdouble uv[2];
     GRobjid   nearest_edge; 
     struct GRid  newsurf_GRid;

     if(option & USE_PROJECT)
     {
        /* Get the mid-point of the current_edge */
        EFget_edge_midpt_and_sf_nor(&msg_loc,
			            &md_env->md_env.matrix_type, 
			            md_env->md_env.matrix, 
                                    md_env,
                                    dimension_surf_GRid,
                                    FALSE,
                                    dimension_edge_GRid.objid,
                                    edge_point, surf_nor);
        EMerr_hndlr (!(1&msg_loc),*msg,EMS_E_Fail,ret_end);

        /* Project this point onto the 'new' surface. */
        stat_OM = = om$send ( msg = message GRgraphics.GRptproject(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    edge_point,
                                    surfpt,
                                    &proj_parms),
                           senderid = NULL_OBJID,
                           targetid = *new_surf,
                           targetos = dimension_edge_GRid.osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc),*msg,EMS_E_Fail,ret_end);
       uv[0] = proj_parms.u;
       uv[1] = proj_parms.v;

      /* Determine the edge nearest to the 'uv' point on the surface */
       newsurf_GRid.objid = *new_surf;
       newsurf_GRid.osnum = dimension_surf_GRid.osnum;
       stat_OM = EFget_edge_near_point_on_sf(&msg_loc, md_env,
                                          newsurf_GRid,
                                          UV_POINT,
                                          uv,
                                          NULL,
                                          &nearest_edge, NULL, NULL);
       EMerr_hndlr (EMSerror (stat_OM & msg_loc), 
                                    *msg, EMS_E_EdgeError, ret_end);

       *new_edge = nearest_edge;
     }
     else
     {
#ifdef DEBUG
printf("ERROR - 'option' other than 'USE_PROJECT' not handled\n");
#endif
       stat_OM = OM_E_ABORT;
       goto ret_end;
     }
  }
  else
  {
#ifdef DEBUG
printf("ERROR - Surface for Dimensioning on Outer solid NOT FOUND\n");
#endif
     stat_OM = OM_E_ABORT;
     goto ret_end;
  }

 ret_end:
  return(stat_OM);

 }
/*********************************************************************/

IGRlong EFget_edge_near_point_on_sf(msg, modenv, sf_grid,
                                          point_type,
                                          point,
                                          near_edge,
                                          nearest_edge,
                                          uv_on_edge,
                                          xyz_on_edge)
 IGRlong          *msg;
 struct GRmd_env  *modenv;
 struct GRid      sf_grid;
 IGRushort        point_type; 
 IGRpoint         point;
 IGRboolean       *near_edge;
 GRobjid          *nearest_edge;
 IGRdouble        *uv_on_edge, *xyz_on_edge;
{

 IGRlong  msg_loc, sts;
 struct EMSpartolbasis   sfpartol;
 struct EMSptloc_info    ptloc_info;
 OM_S_CHANSELECT         sf_ls_chan;
 IGRdouble               u,v, min_dist, dist_from_edge;
 IGRdouble               proj_locpt[3], uvpt[2];
 IGRboolean              in_world=TRUE, ls_created = FALSE;
 struct IGRbsp_surface   *sf_geom=NULL;
 IGRlong                 sf_size=0;
 IGRshort                location;
 GRobjid                 current_sf;
 GRspacenum              thisos;
 IGRint                  ii;

 sts     = OM_S_SUCCESS;
 *msg  = EMS_S_Success;

 current_sf = sf_grid.objid;
 thisos     = sf_grid.osnum;
 if(near_edge) *near_edge = FALSE;

 sts = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
 EMerr_hndlr (!(1&sts),*msg,EMS_E_OMerror, ret_end);
 
 min_dist         = MAXDOUBLE;
 *nearest_edge     = NULL_OBJID;
 location         = EMS_L_UNKNWN;


  /* Make sure the surface has a 'loopset' before proceeding. */
    sts = om$send (msg = message EMSsubbs.EMputLsIfNotThere(&msg_loc,
                          &(modenv->md_env), NULL, NULL, 0, &ls_created),
                   targetid = current_sf,
                   targetos = thisos,
                   senderid = NULL_OBJID);
    EMerr_hndlr(!(msg_loc&sts&1), *msg, EMS_E_LoopsetError, ret_end);
#ifdef DEBUG
 if(ls_created)
   printf("Loopset created for surface id = %d\n", current_sf);
#endif

  /* get the parametric tolerance on this surface */

    sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                       &(modenv->md_env.matrix_type),
                                        modenv->md_env.matrix,
                                       &in_world, FALSE, &(sfpartol.tol)),
                   targetid = current_sf,
                   targetos = thisos,
                   senderid = NULL_OBJID);
    EMerr_hndlr(!(msg_loc&sts&1), *msg, msg_loc, ret_end);
    sfpartol.is_valid = TRUE;

    if(point_type == XYZ_POINT)
    {
     /* get size of surface geometry */
        sts = om$send(msg = message GRvg.GRgetsize(
                   &msg_loc,
                   &(modenv->md_env.matrix_type),
                   modenv->md_env.matrix,
                   &sf_size),
                  senderid = NULL_OBJID,
                  targetid = current_sf,
                  targetos = thisos);
        EMerr_hndlr(!(1&sts&msg_loc),*msg,msg_loc,ret_end);

     /* allocate memory for surface geometry */
       sf_geom = (struct IGRbsp_surface *) om$malloc (size = sf_size);
       EMerr_hndlr(!sf_geom,*msg,EMS_E_NoDynamicMemory,ret_end);

     /* Get the surface geometry.*/
       sts = om$send(msg = message GRvg.GRgetgeom(
                   &msg_loc,
                   &(modenv->md_env.matrix_type),
                   modenv->md_env.matrix,
                   (IGRchar *) sf_geom),
                  senderid = NULL_OBJID,
                  targetid = current_sf,
                  targetos = thisos);
       EMerr_hndlr(!(msg_loc&sts&1), *msg, msg_loc, ret_end);


     /* project pt. onto surface just to make sure it lies on surface*/
       sts = BSmdistptsf( (BSrc *)&msg_loc, sf_geom, point, &u,&v,
                       proj_locpt, &min_dist);
       EMerr_hndlr (!(sts&1) || BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);

     /* pt location needs a UV point */
       uvpt[0] = u;
       uvpt[1] = v;
    }
    else if(point_type == UV_POINT)
    {
       uvpt[0] = point[0];
       uvpt[1] = point[1];
    }
    else
        goto ret_end;

  /* Find nearest edge */

    ptloc_info.options =  EMS_PTLOC_CLOSEST_EDGE;
    ptloc_info.location = EMS_L_UNKNWN;

    sts=om$send (msg = message EMSloopset.EMpt_location (&msg_loc, uvpt,
                           &ptloc_info, &sfpartol),
                senderid     = current_sf,
                p_chanselect = &sf_ls_chan,
                targetos     = thisos);
    EMerr_hndlr (!(1&sts&msg_loc), *msg, EMS_E_EdgeError, ret_end);

    dist_from_edge   = ptloc_info.edge[0].nst_pt.dist;
    location         = ptloc_info.location;
    *nearest_edge     = ptloc_info.edge[0].edge_id;

    if(near_edge)
    {
        if((location == EMS_L_ONEDGE) || (location == EMS_L_ONVRTX) ||
           (location == EMS_L_INHOLE))
            { *near_edge = TRUE; }
        else 
            { *near_edge = FALSE; }
    }

    if(uv_on_edge)
      for(ii=0; ii<2; ii++)
          uv_on_edge[ii] = ptloc_info.edge[0].nst_pt.proj_pt[ii];

    if(xyz_on_edge)
    {
      IGRpoint   edge_point;
       
      for(ii=0; ii<2; ii++)
          uvpt[ii] = ptloc_info.edge[0].nst_pt.proj_pt[ii];

      /* get the XYZ coordinates corresponding to uvpt[2] in edge_point[3] */
      sts = om$send(msg = message GRvg.EMptatpr (&msg_loc,
                                               &(modenv->md_env.matrix_type),
                                               modenv->md_env.matrix,
                                               uvpt, 2, edge_point),
                    senderid = NULL_OBJID,
                    targetos = thisos,
                    targetid = current_sf);
      EMerr_hndlr (EMSerror (sts & msg_loc), *msg, EMS_E_SurfaceError,
                     ret_end);
      for(ii=0; ii<3; ii++)
          xyz_on_edge[ii] = edge_point[ii];
    }

ret_end:

  if(sf_geom) om$dealloc(ptr = sf_geom);
  return(sts);
}
/*****************************************************************/

IGRlong EFget_dimension_plane_and_geom(msg, md_env, option, 
                                       thickness,
                                       edge_surf,
                                       parent_edge_GRid, dim_view_index,
                                       planept, planenor, planexaxis, dimgeom)

   IGRlong    *msg;
   struct GRmd_env *md_env;
   IGRushort     option;
   IGRdouble  *thickness;
   struct GRid  edge_surf;
   struct GRid parent_edge_GRid;
   OMuword     dim_view_index;
   IGRdouble  *planept;
   IGRdouble  *planenor, *planexaxis;
   IGRdouble  *dimgeom;
{

  IGRshort     mattyp;
  IGRmatrix    mat;
  IGRlong      msg_loc, stat_OM = OM_S_SUCCESS;
  IGRint       i;
  IGRpoint     edge_point;
  IGRdouble    surf_nor[3];
  IGRvector    tan_vec;
  IGRint       ii;
  IGRvector    viewnor_top, viewnor_front, viewnor_right;
  IGRdouble    top_dot, front_dot, right_dot, coltol;
  IGRboolean   found, is_pointer = TRUE;

  extern IGRdouble fabs();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  dim_view_index = dim_view_index; /* Dummy Assignment to fool Compiler */
  OM_BLOCK_MOVE (md_env->md_env.matrix, mat, sizeof (IGRmatrix));
  mattyp = md_env->md_env.matrix_type;

  is_pointer = FALSE;
  EFget_edge_midpt_and_sf_nor(&msg_loc, &mattyp, mat, md_env,
                              edge_surf, is_pointer, 
                              parent_edge_GRid.objid,  
                              edge_point, surf_nor);
  EMerr_hndlr(EMSerror (msg_loc), *msg, EMS_E_EdgeError,
                             ret_end);

  if(option & REVERSE_NORMAL)     /* Reverse the normal, if necessary */
    for(i=0; i<3; i++)
       surf_nor[i] *= -1.0;

  /* Determine the tangent vector for the edge at the mid-point */
  stat_OM = om$send(msg = message EMSedge.EMtangent(&msg_loc, md_env, 
                                          &edge_surf.objid, edge_point, 1.0,
                                          NULL, tan_vec),
                    senderid = NULL_OBJID,
                    targetos = edge_surf.osnum,
                    targetid = parent_edge_GRid.objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
                     ret_end);
  BSnorvec (&msg_loc, tan_vec);
  EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);

  /* Determine 'planepoint' */
  for (i=0; i<3; i++)
      planept[i] = edge_point[i];

  /* Determine the Dimension plane normal appropriately 
     and the 'plane-x-axis' */

  /* Find if any of the three principal views are perpendicular to the 
     dimension line */

  /** Find the view to which the dimension line is closest to perpendicular **/
  for (ii=0; ii<3; ii++)
  {
      viewnor_top[ii] = 0.0;
      viewnor_front[ii] = 0.0;
      viewnor_right[ii] = 0.0;
  }

  viewnor_top[2] = 1.0;   /* Top View - Z-axis Normal */
  viewnor_front[1] = 1.0;   /* Front View - Y-axis Normal */
  viewnor_right[0] = 1.0;   /* Right Side View - X-axis Normal */

  top_dot = BSdotp (&msg_loc, viewnor_top, surf_nor) + 
                BSdotp (&msg_loc, viewnor_top, tan_vec);
  front_dot = BSdotp (&msg_loc, viewnor_front, surf_nor) +
                BSdotp (&msg_loc, viewnor_front, tan_vec);
  right_dot = BSdotp (&msg_loc, viewnor_right, surf_nor) +
                BSdotp (&msg_loc, viewnor_right, tan_vec);
  EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);

  BSEXTRACTPAR (&msg_loc, BSTOLCOLLINVEC, coltol);

  for (ii=0; ii<3; ii++)
  {
     planenor[ii] = 0.0;
     planexaxis[ii] = 0.0;
  }

  found = FALSE;
  if (fabs(top_dot) < fabs(front_dot))
     if (fabs(top_dot) < fabs(right_dot))
        if(fabs(top_dot) <= 2*coltol)
        {
          planenor[2] = 1.0;
          planexaxis[0] = 1.0;
          found = TRUE;
        } 
        else
          found = FALSE;
     else
        if(fabs(right_dot) <= 2*coltol)
        {
          planenor[0] = 1.0;
          planexaxis[1] = 1.0;
          found = TRUE;
        }
        else
          found = FALSE;
  else
     if (fabs(front_dot) < fabs(right_dot))
        if(fabs(front_dot) <= 2*coltol)
        {
          planenor[1] = -1.0;
          planexaxis[0] = 1.0;
          found = TRUE;
        }
        else
          found = FALSE;
     else
        if(fabs(right_dot) <= 2*coltol)
        {
          planenor[0] = 1.0;
          planexaxis[1] = 1.0;
          found = TRUE;
        }
        else
          found = FALSE;


  if(!found)
  {
   /* Use the actual dimension plane normal itself */
    BScrossp (&msg_loc, surf_nor, tan_vec, planenor);
    BSnorvec (&msg_loc, planenor);

    /* The actual dimension plane x-axis */
  
    OM_BLOCK_MOVE(tan_vec, planexaxis, sizeof(IGRvector));
    BSnorvec (&msg_loc, planexaxis);
    EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);
  } /* end of if(!found) */

  /* Determine the geometry of the dimension line  */

  for(i=0; i<3; i++)
      dimgeom[i] = edge_point[i];
  for(i=0; i<3; i++)
      dimgeom[i+3] = edge_point[i]+ (*thickness) * surf_nor[i];


ret_end:

        if (1 & *msg)
                return(TRUE);
        else
                return(FALSE);
}

 static void EFget_edge_midpt_and_sf_nor(msg, mattyp, mat, md_env,
                                         edge_surf, is_pointer,
                                         parent_id,
                                         edge_point, surf_nor)
 IGRlong     *msg;
 IGRshort     *mattyp;
 IGRmatrix   mat;
 struct GRmd_env  *md_env;
 struct GRid        edge_surf;
 IGRboolean  is_pointer;  /* indicates whether the next arg. is an objid
                             or an EMSpointer id. */
 GRobjid     parent_id;
 IGRpoint    edge_point;
 IGRvector   surf_nor;
{
  IGRboolean   out_solid, world;
  IGRdouble    uv[2];
  struct EMSpartolbasis   partolb;
  IGRlong      msg_loc, stat_OM = OM_S_SUCCESS;

  *msg = EMS_S_Success;

  /* Get the parametric-tolerance of the Surface */
  world = TRUE;
  stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                 mattyp, mat, &world, FALSE, &partolb.tol),
                     senderid = NULL_OBJID,
                     targetos = edge_surf.osnum,
                     targetid = edge_surf.objid);
  EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_SurfaceError,ret_end);
  partolb.in_world = TRUE;
  partolb.is_valid = TRUE;
  partolb.mattyp = mattyp;
  partolb.mat = mat;

  /* Find the 'xyz' coordinates of the 'mid-point' of the edge-object -
   * get an internal point on "edge" in uv[] */
  if(is_pointer)
  {
    stat_OM = om$send(msg = message EMSpointer.EMpass(&msg_loc, NULL,
                          message EMSedge.EMinternalpt(&msg_loc, 1,
                                          NULL, uv, NULL, &partolb)),
                    senderid = NULL_OBJID,
                    targetos = edge_surf.osnum,
                    targetid = parent_id);
  }
  else
  {
    stat_OM = om$send(msg = message EMSedge.EMinternalpt(&msg_loc, 1,
                                          NULL, uv, NULL, &partolb),
                    senderid = NULL_OBJID,
                    targetos = edge_surf.osnum,
                    targetid = parent_id);
  }

  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
                     ret_end);

  /* get the XYZ coordinates corresponding to uv[2] in edge_point[3] */
  stat_OM = om$send(msg = message GRvg.EMptatpr (&msg_loc, mattyp,
                                                   mat, uv, 2, edge_point),
                    senderid = NULL_OBJID,
                    targetos = edge_surf.osnum,
                    targetid = edge_surf.objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
                     ret_end);

  /* Determine the unit normal at the 'edge-mid-point' on the surface */
  out_solid = FALSE; 
  stat_OM = om$send (msg = message EMSsubbs.EMget_unit_norm
                             (&msg_loc, out_solid, NULL,
                              &md_env->md_env,
                              (IGRdouble *)edge_point,
                              &surf_nor[0]),
                     senderid = NULL_OBJID,
                     targetid = edge_surf.objid,
                     targetos = edge_surf.osnum);

  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

ret_end:

  return;
}
  
end implementation EMSshslbool;
