/*
NAME:
   EFgetmapped_inters

DESCRIPTION
    This function takes in two coincident surfaces, and maps each edge of the
    respective surfaces onto the other surface and outputs the mapped 
    information in the form of inters list. This function in turn calls another
    lower level function at edge level which does the actual mapping. This is
    basically a wrapper to the function EFmap_the_edge().

    input:
         sfid_a    :   Surface Grid for surface A.
         options_a :   options for surface A.
         sfid_b    :   Surface Grid for surface B.
         options_b :   options for surface B.

    output:
         inters_a  :   Inters list for surface A.
         inters_b  :   Inters list for surface B.

    Typically the options supported for both the surfaces are:-
         EMS_DONOT_MAP_ANY_EDGE
         EMS_DONOT_MAP_CONVEX_EDGES
         EMS_DONOT_MAP_CONCAVE_EDGES
         EMS_DONOT_MAP_NEUTRAL_EDGES
         EMS_OPT_PUSH_TO_COMMON_EDGE
    These are defined in EMSopt.h.

History :

      KNAP    :         04/??/94            Initial Writing
      Sanjay  :         04/??/94            Modified the main function call
                                            to look for the option "do not
                                            map edge" first rather than 
                                            checking for the other options 
                                            first. 
      Sanjay  :         05/24/94            Added one more option
                                            "EMS_OPT_REVERSE_MAPPED_EDGE"
                                            for orienting the intersections
                                            properly for boolean difference
      Sanjay  :         05/25/94            Fixed problems related to 
                                            intobj's orientation. 
      Sanjay  :         07/06/94            Added the call to "add$status"
                                            macro in place of "EMerr_hndlr"

      Sanjay  :         01/05/95            Modified some stuff.
*/

class implementation Root;

#include "EMS.h"
#include "ECmsg.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "emsinterdef.h"
#include "emssfint.h"
#include "emserr.h"
#include "emssfintdef.h"
#include "addrmopts.h"
#include "bserr.h"
#include "bssfarrevn.h"
#include "bsparameters.h"
#include "bsprptonsf.h"

#define  ZERO   0
#define  FIRST  0
#define  SECOND 1

#define  REVERSE_THIS        0x01
#define  REVERSE_OTHER       0x02


from  EMSloopset   import  EMlsparttrim, EMgetsurface_info;
from  EMSsubbs     import  EMgetedges;
from  EMSedge      import  EMptproject, EMextractyourself, EMget_props;


IGRlong EMgetmapped_inters ( msg, md_env, sfid_a, options_a, sfid_b, options_b,
                             inters_a, inters_b )
IGRlong               *msg;
IGRushort             options_a, options_b;
struct GRmd_env       *md_env;
struct GRid           *sfid_a, *sfid_b;
struct EMSinters      **inters_a, **inters_b;
{
  IGRushort               options, orient;
  IGRshort                *mattyp;
  IGRlong                 stat, msg_loc;
  IGRboolean              is_convex, is_neutral, is_mapped;
  IGRint                  i, numed_a, array_size_a, numed_b, array_size_b;
  IGRdouble               *mat; 
  IGRushort               ed_props;
  struct GRid             *sfedges_a, *sfedges_b;
  struct EMSinters        *loc_inters_a, *loc_inters_b;
  extern IGRlong          EFmap_the_edge();

  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  loc_inters_a = loc_inters_b = NULL;
  numed_a = numed_b = 0;
  array_size_a = array_size_b = 0;
  sfedges_a = sfedges_b = NULL;
  ed_props = NULL; options = NULL;
  stat = OM_S_SUCCESS; msg_loc = EMS_S_Success;
  *msg = EMS_S_Success;

  /*
   *  Get all the edges of surface A.
   */
  if( !(options_a & EMS_DONOT_MAP_ANY_EDGE) )
  {
      stat = om$send ( msg = message EMSsubbs.EMgetedges( &msg_loc,
                                     NULL, &sfedges_a, &array_size_a,
                                     &numed_a, NULL, NULL, NULL, NULL ),
                             senderid = NULL_OBJID,
                             targetid = sfid_a->objid,
                             targetos = sfid_a->osnum );
      add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMgetmapped_inters : EMgetedges error",
          action = GOTO_VALUE, value = wrapup );
  }

  /*
   *  Get all the edges of surface B.
   */
  if( !(options_b & EMS_DONOT_MAP_ANY_EDGE) )
  {
      stat = om$send ( msg = message EMSsubbs.EMgetedges( &msg_loc,
                                     NULL, &sfedges_b, &array_size_b,
                                     &numed_b, NULL, NULL, NULL, NULL ),
                             senderid = NULL_OBJID,
                             targetid = sfid_b->objid,
                             targetos = sfid_b->osnum );
      add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMgetmapped_inters : EMgetedges error",
          action = GOTO_VALUE, value = wrapup );
  }

  orient = NULL;
  if( options_a & EMS_OPT_REVERSE_MAPPED_EDGE )
      orient = REVERSE_THIS;
  if( options_b & EMS_OPT_REVERSE_MAPPED_EDGE )
      orient |= REVERSE_OTHER;

  /*
   * Map each edge of surface A on to surface B depending on the
   * options input.
   */
  for ( i = 0; i < numed_a; i++ )
  {
    is_mapped = FALSE;
    ed_props  = NULL;
    stat = EFget_edge_info( &msg_loc, mattyp, mat, sfedges_a[i], NULL,
                            NULL, &ed_props, NULL, &is_convex, 
                            &is_neutral, NULL, NULL, NULL, NULL );
    add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_EdgeError,
        str = "EMgetmapped_inters : EFget_edge_info error",
        action = GOTO_VALUE, value = wrapup );

    if ( is_convex && (options_a & EMS_DONOT_MAP_CONVEX_EDGES ))
      continue;
    else if (!is_convex && (options_a & EMS_DONOT_MAP_CONCAVE_EDGES))
      continue;
    else if( is_neutral && (options_a & EMS_DONOT_MAP_NEUTRAL_EDGES))
      continue;
    else if( (ed_props & EMED_SEAM) && (options_a & EMS_DONOT_MAP_SEAM_EDGES))
      continue;

    else
    {
      if ( options_a & EMS_OPT_PUSH_TO_COMMON_EDGE )
        options = EMS_OPT_PUSH_TO_COMMON_EDGE;

      stat = EFmap_the_edge( &msg_loc, options, orient, md_env, sfedges_a[i], 
                    sfid_a, sfid_b, &is_mapped, &loc_inters_a, &loc_inters_b);
      if ( is_mapped )
        add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
            str = "EMgetmapped_inters : EFmap_the_edge error",
            action = GOTO_VALUE, value = wrapup );
    }
  }

  orient = NULL;
  if( options_b & EMS_OPT_REVERSE_MAPPED_EDGE )
      orient = REVERSE_THIS;
  if( options_a & EMS_OPT_REVERSE_MAPPED_EDGE )
      orient |= REVERSE_OTHER;

  /*
   * Map each edge of surface B on to surface A depending on the
   * options input.
   */
  for ( i = 0; i < numed_b; i++ )
  {
    is_mapped = FALSE;
    ed_props  = NULL;
    stat = EFget_edge_info( &msg_loc, mattyp, mat, sfedges_b[i], NULL,
                            NULL, &ed_props, NULL, &is_convex, &is_neutral,
                            NULL, NULL, NULL, NULL );
    add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_EdgeError,
        str = "EMgetmapped_inters : EFget_edge_info error",
        action = GOTO_VALUE, value = wrapup );

    if ( is_convex && (options_b & EMS_DONOT_MAP_CONVEX_EDGES ))
      continue;
    else if (!is_convex && (options_b & EMS_DONOT_MAP_CONCAVE_EDGES))
      continue;
    else if( is_neutral && (options_b & EMS_DONOT_MAP_NEUTRAL_EDGES))
      continue;
    else if( (ed_props & EMED_SEAM) && (options_a & EMS_DONOT_MAP_SEAM_EDGES))
      continue;
    else
    {
      if ( options_b & EMS_OPT_PUSH_TO_COMMON_EDGE )
        options = EMS_OPT_PUSH_TO_COMMON_EDGE;
      stat = EFmap_the_edge( &msg_loc, options, orient, md_env, sfedges_b[i], 
                     sfid_b, sfid_a, &is_mapped, &loc_inters_b, &loc_inters_a);
      if ( is_mapped ) 
        add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
            str = "EMgetmapped_inters : EFmap_the_edge error",
            action = GOTO_VALUE, value = wrapup );
    }
  }

  EMmergeinters (&msg_loc, inters_a, loc_inters_a );
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMmergeinters error",
      action = GOTO_VALUE, value = wrapup );
  loc_inters_a = NULL;
   
  EMmergeinters (&msg_loc, inters_b, loc_inters_b );
  add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMmergeinters error",
      action = GOTO_VALUE, value = wrapup );
  loc_inters_b = NULL;

wrapup:
    EMinters_free( loc_inters_a, ( IGRint ) 0 );
    EMinters_free( loc_inters_b, ( IGRint ) 0 );
    return(stat);
}

/*
NAME:
   EFmap_the_edge

DESCRIPTION
    This function takes in an edge, its surface, and the surface on which it
    is to be mapped and outputs the mapped information in the form of inters
    list. Optionally, it generates inters on the common surface along the
    common egde channel Optionally, it generates inters on the common surface
    along the common egde channel.

    input:
         options   :   options
         edge_grid :   Edge which is being mapped.
         sfid      :   Surface Grid for edge_grid.
         othersfid :   Surface Grid for surface B.

    output:
         is_mapped     :   Flag indicating whether map is successfull or not.
         this_inters   :   Inters list for surface A.
         otehr_inters  :   Inters list for surface B.

    Typically the option supported for edge is:
         EMS_OPT_PUSH_TO_COMMON_EDGE
    These are defined in EMSopt.h.

Author   Apr'94   KNAP:  Initial writing.
*/

IGRlong  EFmap_the_edge ( msg, opt, orient, md_env, edge_grid, sfid, othersfid, 
                          is_mapped, this_inters, other_inters )
IGRlong                   *msg;
IGRushort                 opt, orient;
IGRboolean                *is_mapped;
struct GRmd_env           *md_env;
struct GRid               edge_grid;
struct GRid               *sfid, *othersfid;
struct EMSinters          **this_inters, **other_inters;
{
  IGRshort                disp_level;
  IGRushort               options, ed_props, com_ed_props;
  IGRboolean              onsrf, this_reversed, other_reversed;
  IGRint                  j, num_out_cvs, num_bytes;
  IGRlong                 msg_loc, stat, nbytes_ret;
  IGRshort                *mattyp=NULL, tst_plan;
  IGRdouble               *mat=NULL, chttol, u_par[2];
  IGRpoint                end_pt[3];
  GRobjid                 *output_obj=NULL;
  IGRulong                this_props, other_props;
  struct IGRdisplay       disp_buffer;
  struct IGRbsp_curve     *loc_ed_geom=NULL, *p_curve=NULL;
  struct IGRbsp_surface   *this_surf=NULL, *other_surf=NULL, *comsurf=NULL, *org_surf=NULL;
  struct GRid             ls_grid, thisid, otherid, tmp_grid, comm_edge, 
                          ed_grid, comsfid;
  struct EMSdataselect    this_uvdata, *other_uvdata=NULL, *xyzdata=NULL, tmpdata;
  struct EMSpartolbasis   partolbasis;
  struct EMSsfintedpar    *this_intedpar=NULL, **other_intedpar=NULL, *loc_intedpar=NULL;
  struct EMSinters        *loc_this_inters=NULL, *loc_other_inters=NULL;
  struct EMSproj_info     proj_info;
  struct GRvg_construct   const_list;

  struct EMSintobj *EMmakeintlist();
  struct EMSsfintedpar* EMsfintedpar_malloc(), EMsfintedpar_free();
  struct EMSdataselect    *new_other_uvdata=NULL, *new_xyzdata=NULL; 

  OM_S_CHANSELECT chan_to_loopset;
  OMuint num_lps;
  OM_S_OBJECT_LINKAGE comm_list[1];

  stat     = OM_S_SUCCESS; 
  msg_loc  = EMS_S_Success;
  *msg     = EMS_S_Success;
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);


  loc_this_inters = loc_other_inters = NULL;
  this_surf = other_surf = comsurf = NULL;
  other_uvdata = xyzdata = NULL;
  this_intedpar = NULL;
  other_intedpar = NULL;
  output_obj = NULL;
  loc_ed_geom = NULL;
  onsrf = this_reversed = other_reversed = FALSE;

  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  partolbasis.in_world = TRUE;
  partolbasis.mattyp = mattyp;
  partolbasis.mat = mat;
  partolbasis.in_world = TRUE;
  partolbasis.mattyp = mattyp;
  partolbasis.mat = mat;

  this_intedpar = EMsfintedpar_malloc( &msg_loc, 2 );

  if ( opt & EMS_OPT_PUSH_TO_COMMON_EDGE )
  {
    stat = EFget_edge_info( &msg_loc, mattyp, mat, edge_grid, &comm_edge,
                            &comsfid, NULL, NULL, NULL, NULL, NULL, NULL,
                            NULL, &com_ed_props );
    add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_EdgeError,
        str = "EMgetmapped_inters : EFget_edge_info error",
        action = GOTO_VALUE, value = wrapup );

    EMgetvggeom ( &msg_loc, mattyp, mat, &comsfid, (IGRchar **)&comsurf, NULL);
    add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_SurfaceError,
        str = "EMgetmapped_inters : EMgetvggeom error",
        action = GOTO_VALUE, value = wrapup );

    thisid.objid = comsfid.objid;
    thisid.osnum = comsfid.osnum;
    ed_grid.objid = comm_edge.objid;
    ed_grid.osnum = edge_grid.osnum;
    this_surf = comsurf;

    EMgetvggeom ( &msg_loc, mattyp, mat, sfid, (IGRchar **)&org_surf, NULL );
    add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_SurfaceError,
        str = "EMgetmapped_inters : EMgetvggeom error",
        action = GOTO_VALUE, value = wrapup );
  }
  else
  {
    ed_grid   = edge_grid;
    thisid    = *sfid;

    /*
     *  Get the geometry of the "this surface".
     */
    EMgetvggeom ( &msg_loc, mattyp, mat, sfid, (IGRchar **)&this_surf, NULL );
    add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_SurfaceError,
        str = "EMgetmapped_inters : EMgetvggeom error",
        action = GOTO_VALUE, value = wrapup );
    this_surf = this_surf;
  }     

  /*
   *  Get the loopset of the other surface viz. the surface on which map
   *  is being performed.
   */
  num_lps = 0;
  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  om$get_channel_objects(objid = othersfid->objid,
                         osnum = othersfid->osnum,
                         p_chanselect = &chan_to_loopset, count = &num_lps,
                         size = 1, list = comm_list);
  add$status( test = (num_lps != 1), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : Number of loops is not equal to one",
      action = GOTO_VALUE, value = wrapup );

  ls_grid.objid = comm_list[FIRST].S_objid;
  ls_grid.osnum = othersfid->osnum;

  /*
   *  Get the geometry of the "other surface".
   */
  EMgetvggeom ( &msg_loc, mattyp, mat, othersfid, (IGRchar **)&other_surf,
                NULL );
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_SurfaceError,
      str = "EMgetmapped_inters : EMgetvggeom error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Extract the partol for the "other surface".
   */
  partolbasis.is_valid = TRUE;
  stat = EFsspbtol_by_geom (&msg_loc, other_surf, &partolbasis.tol);
/******
  stat = om$send (msg = message EMSloopset.EMgetsurface_info (&msg_loc,
                                NULL, &partolbasis),
                        senderid = NULL_OBJID,
                        targetid = ls_grid.objid,
                        targetos = ls_grid.osnum );
*******/
  add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMSloopset.EMgetsurface_info error",
      action = GOTO_VALUE, value = wrapup );

  /*
   *  Get the edge properties.
   */
  stat = om$send(msg = message EMSedge.EMget_props(&msg_loc, &ed_props),
                               senderid = NULL_OBJID,
                               targetid = ed_grid.objid,
                               targetos = ed_grid.osnum);
  add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMSedge.EMget_props error",
      action = GOTO_VALUE, value = wrapup );

  /*
   *  Get the geometry of the edge to be mapped.
   */
  EFcvt_edge_to_cv(&msg_loc, (IGRushort)0, ed_grid, &thisid,
                   &loc_ed_geom, &md_env->md_env);
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EFcvt_edge_to_cv error",
      action = GOTO_VALUE, value = wrapup );

  options = EMMapBnd_StrokeIfNeeded  | EMMapBnd_NoCurveType |
            EMMapBnd_WantBadCurves | EMMapBnd_NoValidate;
  tst_plan  = EMS_O_Unknown;
  
  /*
   *  Map the edge geometry on to the other surface.
   */
  EFmap_the_curve(ed_grid, loc_ed_geom, other_surf, ls_grid, &chttol,
                  &partolbasis, options, &tst_plan, &num_out_cvs,
                  &other_uvdata, &xyzdata, NULL, &other_intedpar, FALSE,
                  &msg_loc);
  if ( !num_out_cvs ) goto wrapup;
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EFmap_the_curve error",
      action = GOTO_VALUE, value = wrapup );
  *is_mapped = TRUE;

  /*
   * Get the xyz end points of the mapped curve.
   */
  if (num_out_cvs == 1)
  {
    
    EMgetendpts_xyz (&msg_loc, mattyp, mat, xyzdata, FALSE, (IGRint)1,
                     end_pt[FIRST], end_pt[SECOND] );
    add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
        str = "EMgetmapped_inters : EMgetendpts_xyz error",
        action = GOTO_VALUE, value = wrapup );
  }
  else
  {
    IGRint   i,npts=0, np_pts=0;
    IGRpoint dummypt;
    IGRdouble par[3], par1, par2, par3;
    IGRboolean on_curve;
  
  
    EMgetendpts_xyz (&msg_loc, mattyp, mat, xyzdata, FALSE, (IGRint)1,
                     end_pt[FIRST], dummypt );
    add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
        str = "EMgetmapped_inters : EMgetendpts_xyz error",
        action = GOTO_VALUE, value = wrapup );

    EMgetendpts_xyz (&msg_loc, mattyp, mat, &xyzdata[num_out_cvs-1], FALSE, 
                     (IGRint)1, end_pt[2], end_pt[SECOND] );
    add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
        str = "EMgetmapped_inters : EMgetendpts_xyz error",
        action = GOTO_VALUE, value = wrapup );
  
  
    for (i=0; i<3; i++)
    {
      BSprptoncv (&msg_loc, loc_ed_geom, end_pt[i], &par[i], &on_curve);
      add$status( test = BSERROR(msg_loc), msg = *msg, code = EMS_E_BSerror,
          str = "EMgetmapped_inters : BSprptoncv error",
          action = GOTO_VALUE, value = wrapup );
    }

    BSalloccv (loc_ed_geom->order, 
               (loc_ed_geom->num_poles + 2 * loc_ed_geom->order -1),
               loc_ed_geom->rational, 0, &p_curve, &msg_loc);  
    BSpartofcv (&msg_loc, loc_ed_geom, par[0], par[2], par[1], p_curve);
    add$status( test = BSERROR(msg_loc), msg = *msg, code = EMS_E_BSerror,
        str = "EMgetmapped_inters : BSpartofcv error",
        action = GOTO_VALUE, value = wrapup );
  
    EMdataselect_data_free (&msg_loc, xyzdata, num_out_cvs);
  
    xyzdata = (struct EMSdataselect *) malloc(sizeof(struct EMSdataselect));
    xyzdata->datatype = EMSdata_curve3d;
    xyzdata->data.curve = p_curve;
  
    npts = 0;

    for (i=0; i<num_out_cvs; i++)
    {
      npts += other_uvdata[i].data.poly->num_points;
    }
    npts = npts - num_out_cvs + 1;
  
    new_other_uvdata = (struct EMSdataselect *) malloc(sizeof(struct EMSdataselect));
    new_other_uvdata->datatype = EMSdata_poly2d;
    new_other_uvdata->data.poly = (struct IGRpolyline *) malloc(sizeof(struct IGRpolyline));
    new_other_uvdata->data.poly->num_points = npts;
    new_other_uvdata->data.poly->points = (double *) malloc (npts * 2 * sizeof(double));
  
    npts = 0;
    for (i=0; i<num_out_cvs; i++)
    {
      np_pts = other_uvdata[i].data.poly->num_points-1;
  
      OM_BLOCK_MOVE (other_uvdata[i].data.poly->points, 
                     &new_other_uvdata->data.poly->points[npts*2],
                     2 * (np_pts) * sizeof(double));
      npts += np_pts;
    }
  
    OM_BLOCK_MOVE (&other_uvdata[num_out_cvs-1].data.poly->points[np_pts*2],
                   &new_other_uvdata->data.poly->points[npts*2],
                   2 * sizeof(double));
           
    EMdataselect_data_free (&msg_loc, other_uvdata, num_out_cvs);

    other_uvdata = new_other_uvdata;
  }


  otherid.objid = othersfid->objid;
  otherid.osnum = othersfid->osnum;

/*
    if ( ed_props & EMED_REVERSE_CONNECT )
      this_reversed = TRUE; 
    if ( com_ed_props & EMED_REVERSE_CONNECT )
      other_reversed = TRUE;
*/

  /* 
   *  Generate the sfintedpar information for this/or common surface
   *  and extract the partial/full edge corresponding to the mapped geometry.
   */
  loc_intedpar = this_intedpar; 
  for ( j = FIRST; j <= SECOND; j++ )
  {
    BSprptonsf ( &msg_loc, this_surf, end_pt[j], &u_par[FIRST], 
                 &u_par[SECOND], &onsrf );
    add$status( test = BSERROR(msg_loc), msg = *msg, code = EMS_E_BSerror,
      str = "EMgetmapped_inters : BSprptonsf error",
      action = GOTO_VALUE, value = wrapup );

    partolbasis.is_valid = FALSE;
    stat = om$send(msg = message EMSedge.EMptproject(
                         &msg_loc, u_par, (IGRint) 1,
                         &proj_info, NULL, &partolbasis),
                      senderid = NULL_OBJID,
                      targetid = ed_grid.objid,
                      targetos = ed_grid.osnum);
    add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
        str = "EMgetmapped_inters : EMSedge.EMptproject error",
        action = GOTO_VALUE, value = wrapup );

    loc_intedpar->edgepar = proj_info.param;
    OM_BLOCK_MOVE( &proj_info.param, &loc_intedpar->edgepar,
                   sizeof (struct EMSedgebound ));
    OM_BLOCK_MOVE(proj_info.proj_pt, loc_intedpar->point,
                  2 * sizeof(IGRdouble));
    loc_intedpar->intloc = proj_info.location;
    loc_intedpar->edgeid = ed_grid.objid;
    loc_intedpar = loc_intedpar->next;
  }
  
  output_obj = &tmp_grid.objid;
  partolbasis.is_valid = FALSE;
  stat = om$send(msg = message EMSedge.EMextractyourself(
                       &msg_loc, 
                       (ed_props & EMED_OPEN ? this_intedpar : NULL),
                       NULL, ( IGRint )1,
                       &output_obj, NULL, NULL, FALSE, 
                       (IGRushort)EMImpBnd_NoInputDelete,
                       NULL, &partolbasis),
                    senderid = NULL_OBJID,
                    targetid = ed_grid.objid,
                    targetos = ed_grid.osnum);
  add$status( test = !(1&stat&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMSedge.EMextractyourself error",
      action = GOTO_VALUE, value = wrapup );
  /*
   *  Create an edge object out of the extracted portion.
   */
  tmp_grid.osnum = ed_grid.osnum;
  tmpdata.datatype = EMSdata_object;
  tmpdata.data.object = &tmp_grid;
  EMmkintdata(&msg_loc, &tmpdata, NULL, NULL, FALSE, NULL, NULL,
              TRUE, NULL, NULL, &this_uvdata);
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMmkintdata error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Convert the mapped uvdata (other_uvdata) into edge 
   * objects(uv-space).
   */
  num_bytes = sizeof(struct IGRdisplay);
  gr$get_active_display ( msg = &msg_loc, sizbuf = &num_bytes,
                          nret= &nbytes_ret, buffer = &disp_buffer );
  gr$get_active_level   ( buffer = &disp_level );

  const_list.msg        = &msg_loc;
  const_list.env_info   = md_env;
  const_list.display    = &disp_buffer;
  const_list.properties = NULL;
  const_list.newflag    = FALSE;
  const_list.level      = disp_level;
  const_list.class_attr = NULL;
  const_list.name       = NULL;
  const_list.geometry   = NULL;

  EMmkintdata(&msg_loc, other_uvdata, NULL, NULL, FALSE, NULL, &const_list,
              TRUE, NULL, NULL, other_uvdata);
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMmkintdata error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Generate the inters list for both the surfaces.
   */
/*
  this_props = other_props = EMSintobj_nonoriented;
*/
  if( opt & EMS_OPT_PUSH_TO_COMMON_EDGE )
  {
#ifdef DEBUG
       printf(" org, comm, other : %d, %d, %d\n",
                org_surf->pos_orient, this_surf->pos_orient, 
                other_surf->pos_orient );
       printf(" edge reversed : %d\n", (ed_props & EMED_REVERSE_CONNECT ) ); 
#endif
       if( org_surf->pos_orient != this_surf->pos_orient )
           other_reversed = !other_reversed;
  }
  else
  {
#ifdef DEBUG
       printf(" this, other : %d, %d\n",
                this_surf->pos_orient, other_surf->pos_orient );
       printf(" edge reversed : %d\n", (ed_props & EMED_REVERSE_CONNECT ) );
#endif
       if( this_surf->pos_orient == other_surf->pos_orient )
           other_reversed = !other_reversed;
  }

  if( orient & REVERSE_THIS )
      this_reversed = !this_reversed;
  if( orient & REVERSE_OTHER )
      other_reversed = !other_reversed;
  this_props = other_props = EMSintobj_mapped_data;

  EMmakeintlist( &msg_loc, &loc_this_inters, &loc_other_inters,
                 &thisid, &otherid, NULL, NULL, NULL,
                 NULL, xyzdata, &this_uvdata,
                 other_uvdata, this_reversed, other_reversed,
                 (IGRchar *)this_intedpar, 
                 (IGRchar *)other_intedpar[0], 
                 this_props, other_props, NULL, NULL, TRUE, FALSE );
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMmakeintlist error",
      action = GOTO_VALUE, value = wrapup );

/*
  if( (opt & EMS_OPT_PUSH_TO_COMMON_EDGE) && 
      (!(ed_props & EMED_REVERSE_CONNECT)) )
      loc_this_inters->cvs->reversed = (loc_this_inters->cvs->reversed ?
                                                          FALSE : TRUE ); 
  if( (opt & EMS_OPT_PUSH_TO_COMMON_EDGE) &&
      (ed_props & EMED_REVERSE_CONNECT) )
  {
#ifdef DEBUG
       printf("Doing it ........\n");
#endif
      loc_this_inters->cvs->reversed = !loc_this_inters->cvs->reversed;
  }
*/

  EMmergeinters (&msg_loc, this_inters, loc_this_inters );
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMmergeinters error",
      action = GOTO_VALUE, value = wrapup );
  loc_this_inters = NULL;
   
  EMmergeinters (&msg_loc, other_inters, loc_other_inters );
  add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMgetmapped_inters : EMmergeinters error",
      action = GOTO_VALUE, value = wrapup );
  loc_other_inters = NULL;

wrapup:

    EMinters_data_free( &msg, loc_this_inters, ( IGRint ) 0, NULL,
                        EMsfintedpar_free );
    EMinters_free( loc_this_inters, ( IGRint ) 0 );
    EMinters_data_free( &msg, loc_other_inters, ( IGRint ) 0, NULL,
                        EMsfintedpar_free );
    EMinters_free( loc_other_inters, ( IGRint ) 0 );

    if( loc_ed_geom->poles )    om$dealloc( ptr = loc_ed_geom->poles );
    if( loc_ed_geom->knots )    om$dealloc( ptr = loc_ed_geom->knots );
    if( loc_ed_geom->weights )  om$dealloc( ptr = loc_ed_geom->weights );
    if( loc_ed_geom )           om$dealloc( ptr = loc_ed_geom);
    if ( this_surf )
      free ( this_surf );
    if ( other_surf )
      free ( other_surf );

    return(stat);
}

end implementation Root;
