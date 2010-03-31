/* -----------------
 * FOR EMS 4.0
 * Creation : Sanjay
 * -----------------
 */
class implementation Root;

from EMSsfstitch import EMmake_comp;
from EMSsfstitch import EMmake_primitive1;
from EMSsfsolid  import EMcap_thyself;

#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "ems_m_inc.h"
#include "EMSmsgdef.h"            /* EMS_I_NotFound */
#include "EC_M.h"            /* Command strings */
#include "EC_P.h"      /* Prompt strings */
#include "EC_I.h"      /* Informational strings */
#include "EC_F.h"      /* Fatal strings */
#include "FI.h"
#include "EMSdpb.h"
#include "emsdef.h"
#include "emserr.h"
#include "REsfsolid.h"
#include "REassoc.h"
#include "REgenbs.h"
#include "emsmass.h"

#include "addrmopts.h"

#include "bsgeom_cvsf.h"
#include "EMSsfparms.h"
#include "bsconic.h"
#include "bssrmktsncg.h"
#include "bssftgeomsf.h"
#include "bssf_rev.h"
#include "bssf_copy.h"
#include "bsmergsfnna.h"
#include "bsfreesf.h"
#include "bsarclnpars.h"
#include "bsallocsf.h"
#include "bspartofsf.h"
#include "godef.h"

/*
 * Externs
 */
extern void EFMatch();
extern IGRboolean DeleteObject();
extern IGRlong EFspecial_case_from_geom();
extern IGRlong EFMakeSkinSurface();
extern int     compare_doubles();

extern OMuword OPP_EMSsfsolid_class_id, OPP_EMSsfstitch_class_id;

/*
 *
 * NAME
 *    EFPlaceSkinSurface
 *
 * ABSTRACT
 *    This function places a skinning surface given the cross section 
 *    curve(s) and trace curve(s) and returns the skin surface info.
 *
 * SYNOPSIS
 *
 * IGRlong               *EFmsg,     O  Return Status
 * IGRlong               options,    I  Options defined in addrmopts.h
 * struct GRvg_construct *cons_list, I  Construction List
 * IGRint                nsec_cvs,   I  Number of Cross-section curves
 * struct GRlc_info      *sec_cvs,   I  Cross-Section Curves Info
 * IGRint                ntrc_cvs,   I  Number of Trace Curves
 * struct GRlc_info      *trc_cvs,   I  Trace Curves Info
 * struct GRid           *skin_grid, O  Created Skinned Surface GRid
 * struct SkinSurfInfo   *skin_info  O  Skin Surface Info if required 
 *                                      otherwise NULL.
 *
 * DESCRIPTION
 *
 * RETURN VALUE 
 *
 *    EMS_S_Success        Successful
 *    EMS_E_Fail           Failure 
 *    EMS_E_BSerror        BSfailure
 *
 * NOTES
 * 
 * INDEX
 *
 * KEYWORDS
 *    skinning,surface,composite
 *
 * HISTORY
 *    Sanjay    12/13/94    Creation 
 *
 */
IGRlong EFPlaceSkinSurface (
IGRlong               *EFmsg,
IGRlong               options,  /* SKIN_OPT_SMOOTH, SKIN_OPT_ABSOLUTE, 
                                   SKIN_OPT_MADECOMP, SKIN_OPT_CLOSED */
struct GRvg_construct *cons_list,
IGRint                nsec_cvs,
struct GRlc_info      *sec_cvs,
IGRint                ntrc_cvs,
struct GRlc_info      *trc_cvs,
struct GRid           *skin_grid,
struct SkinSurfInfo   *skin_info )
{
  /* general */
  BSrc     BSmsg;
  IGRint   inx, n_sf=0;
  IGRlong  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
  OMuword  osnum = cons_list->env_info->md_id.osnum;

  /* options */
  IGRboolean  absolute=FALSE, smooth=FALSE, madecomp=FALSE, closed=FALSE;

  /* surface geometry */
  struct IGRbsp_surface  *p_surface = NULL, *split_surface=NULL;

  /* split surface object ids */
  GRobjid  *split_surf_objids=NULL;

  /* INITIALIZATION */
  *EFmsg = EMS_S_Success;
  skin_grid->objid = NULL_OBJID;
  skin_grid->osnum = osnum;

  if(skin_info) 
    memset(skin_info, 0, sizeof(struct SkinSurfInfo));

  /* initialize the options */
  absolute = (options & SKIN_OPT_ABSOLUTE) ? TRUE : FALSE;
  smooth   = (options & SKIN_OPT_SMOOTH)   ? TRUE : FALSE;
  madecomp = (options & SKIN_OPT_MADECOMP) ? TRUE : FALSE;
  closed   = (options & SKIN_OPT_CLOSED)   ? TRUE : FALSE;
      
  /*
   * Construct a skinning surface
   */
  OMsts = EFMakeSkinSurface( &OMmsg, ntrc_cvs, trc_cvs, nsec_cvs, sec_cvs,
                             !closed, NULL, absolute, FALSE, NULL, NULL,
                             smooth, &p_surface );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFPlaceSkinSurface : EFMakeSkinSurface error", 
      action = GOTO_VALUE, value = wrapup );

  /*
   * if user wants a composite
   * then
   *    determine if I can create a composite
   *    if I can create a composite
   *    then
   *       create a multi-component composite
   *    else
   *       create a single surface
   * else
   *    create a single surface
   */
  if( madecomp )
  {
    /* general */
    IGRint d_size = sizeof(IGRdouble);
    IGRboolean can_create_composite = FALSE;

    /* skin surface info */
    IGRint     npoles_u, npoles_v; 
    IGRshort   order_u, order_v;

    /* cross and trace curves information */
    IGRint     ncusp_u=0, ncusp_v=0, nsplit_sec=0, nsplit_trc=0; 
    IGRint     nsplit_u=0, nsplit_v=0;
    IGRdouble  *cusp_u=NULL, *cusp_v=NULL, *split_sec=NULL, *split_trc=NULL;
    IGRdouble  *split_u=NULL, *split_v=NULL;

    npoles_u = p_surface->u_num_poles;
    npoles_v = p_surface->v_num_poles;
    order_u  = p_surface->u_order;
    order_v  = p_surface->v_order;

    /*
     * STEP #1 (SKIN SURFACE CUSP POINTS) 
     *      get the cusp points parameters of the skinned surface 
     */
    cusp_u = (IGRdouble *) alloca((npoles_u - order_u + 3) * d_size);
    cusp_v = (IGRdouble *) alloca((npoles_v - order_v + 3) * d_size);
    add$status( test = !cusp_u || !cusp_v, msg = *EFmsg, 
        code = EMS_E_NoDynamicMemory, str = "EFPlaceSkinSurface : Insufficient Memory", 
        action = GOTO_VALUE, value = wrapup );
    
    BSfndsfcsp(p_surface, &ncusp_u, cusp_u, &ncusp_v, cusp_v, &BSmsg);
    add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror, 
        str = "EFPlaceSkinSurface : BSfndsfcsp error", 
        action = GOTO_VALUE, value = wrapup );

    /* 
     * STEP #2 (SPLIT PARAMETERS CORRESPOND TO COMPONENTS OF THE PROFILES) 
     *      If smooth option is not specified, the surface is need to be 
     *      split at the end of the each component of the trace and cross
     *      section curves. So find the split parameters correspond to the
     *      components of the trace and cross section curves. 
     */
    if( !smooth )
    {
      /* general */
      IGRint       grid_size=sizeof(struct GRid), ncomps[2];

      /* trace and cross section curves OBJIDs */
      struct GRid  *traces_grid=NULL;
      struct GRid  *sections_grid=NULL; 

      /* 
       * collect all the trace and cross section curves grid and get the
       * total number of components of cross-section and trace curves.
       */
      traces_grid   = (struct GRid *) alloca(ntrc_cvs * grid_size);
      sections_grid = (struct GRid *) alloca(nsec_cvs * grid_size);
      add$status( test = !traces_grid || !sections_grid, msg = *EFmsg, 
          code = EMS_E_NoDynamicMemory, str = "EFPlaceSkinSurface : Insufficient Memory", 
          action = GOTO_VALUE, value = wrapup );

      for(inx=0; inx<ntrc_cvs; inx++)
        traces_grid[inx] = trc_cvs[inx].located_obj;  

      for(inx=0; inx<nsec_cvs; inx++)
        sections_grid[inx] = sec_cvs[inx].located_obj;

      EFMatch(&OMmsg, ntrc_cvs, nsec_cvs, traces_grid, sections_grid, ncomps);
      add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail, 
          str = "EFPlaceSkinSurface : Insufficient Memory", 
          action = GOTO_VALUE, value = wrapup );

      /*
       * The number of components of cross section and trace curves represents
       * the number of split points along cross-section and trace curves.
       */
      if(ncomps[0] > 1)
      {
        nsplit_trc = ncomps[0];
        split_trc = (IGRdouble *) alloca(nsplit_trc * d_size);
        
        for(inx=0; inx<nsplit_trc; inx++)
          split_trc[inx] = (double) inx / (double) nsplit_trc;
      }

      if( ncomps[1] > 1 )
      {
        nsplit_sec = ncomps[1];
        split_sec = (IGRdouble *) alloca(nsplit_sec * d_size);
        
        for(inx=0; inx<nsplit_sec; inx++)
          split_sec[inx] = (double) inx / (double) nsplit_sec;
      }
    }

    /* 
     * STEP #2 (TOTAL LIST OF SPLIT PARAMETERS : SORT : REMOVAL OF DUPLICATES)
     *         generate the total list of split points, sort them in the incre-
     *         asing order and remove the duplicates if any.
     */
    if( ncusp_u || nsplit_sec || nsplit_v || nsplit_trc )
    {
      nsplit_u = ncusp_u + nsplit_sec + 2;
      nsplit_v = ncusp_v + nsplit_trc + 2;

      split_u = (IGRdouble *) alloca(nsplit_u * d_size);
      split_v = (IGRdouble *) alloca(nsplit_v * d_size);
      add$status( test = !split_u || !split_v , msg = *EFmsg, code = EMS_E_NoDynamicMemory,
          str = "EFPlaceSkinSurface : Insufficient Memory", 
          action = GOTO_VALUE, value = wrapup );

      split_u[0] = split_v[0] = 0.0;
      split_u[nsplit_u-1] = split_v[nsplit_v-1] = 1.0;

      if(nsplit_sec)
        OM_BLOCK_MOVE(split_sec, &split_u[1], nsplit_sec * d_size);
      if(ncusp_u)
        OM_BLOCK_MOVE(cusp_u, &split_u[nsplit_sec+1], ncusp_u * d_size);
     
      if(nsplit_trc)
        OM_BLOCK_MOVE(split_trc, &split_v[1], nsplit_trc * d_size);
      if(ncusp_v)
        OM_BLOCK_MOVE(cusp_v, &split_v[nsplit_trc+1], ncusp_v * d_size);

      /*
       * sort the parameters and remove the duplicates, if any.
       */
      if(nsplit_u > 2)
      {
        qsort(split_u, nsplit_u, d_size, compare_doubles);
        elim_adj_reps(split_u, &nsplit_u);
      }

      if(nsplit_v > 2)
      {
        qsort(split_v, nsplit_v, d_size, compare_doubles);
        elim_adj_reps(split_v, &nsplit_v);
      }
    }
    
    /*
     * check whether composite surface can be generated or not.
     */
    if( nsplit_u > 2 || nsplit_v > 2 )
      can_create_composite = TRUE;

    /*
     * STEP #4 (SPLIT THE SURFACE AT SPLIT PARAMETERS AND CREATE A COMPOSITE
     *          SURFACE)
     */
    if( can_create_composite ) // if there are any split points 
    {
      IGRint     u,v;
      IGRdouble  par1[2], par2[2], par3[2];

      /* allocate the memory for split surface geometry */
      BSallocsf( order_u, order_v, (npoles_u + 2 * order_u - 1), 
                 (npoles_v + 2 * order_v -1), p_surface->rational,
                 (2*p_surface->num_boundaries), &split_surface, &BSmsg );
      add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
          str = "EFPlaceSkinSurface : BSallocsf error",
          action = GOTO_VALUE, value = wrapup );

      split_surface->rational = p_surface->rational;
      split_surface->num_boundaries = p_surface->num_boundaries;
      split_surface->pos_orient = p_surface->pos_orient;

      /* allocate the memrory to hold split surface object IDs */
      split_surf_objids = (GRobjid *) alloca( nsplit_u * nsplit_v * 
                                              sizeof(GRobjid));

      /*
       * SPLIT THE SURFACE AND CREATE THE PARTIAL SURFACES.
       */
      for(v=0; v<nsplit_v-1; v++)
      {
        /* get the first, last and intermediate v parameters */
        par1[1] = split_v[v];
        par3[1] = split_v[v+1];
        par2[1] = par1[1] + ((par3[1] - par1[1]) * 0.5);

        for(u=0; u<nsplit_u-1; u++)
        {
          /* get the first, last and intermediate u parameters */
          par1[0] = split_u[u];
          par3[0] = split_u[u+1];
          par2[0] = par1[0] + ((par3[0] - par1[0]) * 0.5);

          /* split the surface */
          BSpartofsf(p_surface, par1, par2, par3, 2, split_surface, &BSmsg);
          add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
              str = "EFPlaceSkinSurface : BSpartofsf error",
              action = GOTO_VALUE, value = wrapup );

          /*
           * since the knot vectors of the partial surface returned by 
           * above math function are not normalized, they need to be 
           * normalized before constructing the object.
           */
          BSnrsfkntvc(split_surface);

          split_surf_objids[n_sf] = NULL_OBJID;

          /*
           * Construct the surface object from the above partial surface.
           */
          OMsts = EFspecial_case_from_geom( &OMmsg, split_surface, cons_list,
                                            &split_surf_objids[n_sf] );
          add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
              str = "EFPlaceSkinSurface : EFspecial_case_from_geom error",
              action = GOTO_VALUE, value = wrapup );

          /* increment the surface number */
          n_sf++;
        } /* end of v-splits */
      } /* end of u-splits */

      /*
       * Create a composite surface 
       */
      OMsts = om$construct( classid = OPP_EMSsfstitch_class_id,
                            p_objid = &skin_grid->objid, 
                            osnum   = osnum,
                 msg = message EMSsfstitch.EMmake_comp( &OMmsg, 
                               (nsplit_u - 1) * (nsplit_v - 1),
                               split_surf_objids, cons_list->env_info,
                               NULL, NULL, NULL, NULL, NULL) );
      add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFPlaceSkinSurface : om$construct error", 
          action = GOTO_VALUE, value = wrapup );

      /*
       * Change class to EMSgencompsf
       */
      OMsts = om$send( msg = message EMSsfstitch.EMmake_primitive1( &OMmsg,
                                     cons_list->env_info, skin_grid),
                       senderid = skin_grid->objid,
                       targetid = skin_grid->objid,
                       targetos = osnum );
      add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFPlaceSkinSurface : EMmake_primitive1 error", 
          action = GOTO_VALUE, value = wrapup );

      /*
       * Fill the skin surface info
       */
      if( skin_info )
      {
        skin_info->ncusp_u = ncusp_u; skin_info->ncusp_v = ncusp_v;
        skin_info->nsplit_sec = nsplit_sec, skin_info->nsplit_trc = nsplit_trc;
        skin_info->nsplit_u = nsplit_u; skin_info->nsplit_v = nsplit_v;

        if( ncusp_u )
        {
          skin_info->cusp_u = (double *) malloc( ncusp_u * d_size);
          OM_BLOCK_MOVE(cusp_u, skin_info->cusp_u, (ncusp_u * d_size));
        }

        if( ncusp_v )
        {
          skin_info->cusp_v = (double *) malloc(ncusp_v * d_size);
          OM_BLOCK_MOVE(cusp_v, skin_info->cusp_v, (ncusp_v * d_size));
        }

        if( nsplit_sec )
        {
          skin_info->split_sec = (double *) malloc(nsplit_sec * d_size);
          OM_BLOCK_MOVE(split_sec, skin_info->split_sec, (nsplit_sec * d_size));
        }

        if( nsplit_trc )
        {
          skin_info->split_trc = (double *) malloc(nsplit_trc * d_size);
          OM_BLOCK_MOVE(split_trc, skin_info->split_trc, (nsplit_trc * d_size));
        }

        if( nsplit_u )
        {
          skin_info->split_u = (double *) malloc(nsplit_u * d_size);
          OM_BLOCK_MOVE(split_u, skin_info->split_u, (nsplit_u * d_size));
        }

        if( nsplit_v )
        {
          skin_info->split_v = (double *) malloc(nsplit_v * d_size);
          OM_BLOCK_MOVE(split_v, skin_info->split_v, (nsplit_v * d_size));
        }

        skin_info->split_surfs = (GRobjid *) malloc(n_sf * sizeof(GRobjid));
        OM_BLOCK_MOVE(split_surf_objids, skin_info->split_surfs, 
                      n_sf * sizeof(GRobjid));
      }/* end of skin_info */

    } /* End of Splits */
    else
    {
      OMsts = EFspecial_case_from_geom( &OMmsg, p_surface, cons_list, 
                                        &skin_grid->objid );
      add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFPlaceSkinSurface : EFspecial_case_from_geom error", 
          action = GOTO_VALUE, value = wrapup );
    } /* End of no splits */

  } /* End of Need to Make Composite Surface */
  else
  {
    /* 
     * As the composite surface is not needed, then create a single surface
     * from the skinned surface geometry.
     */
    OMsts = EFspecial_case_from_geom( &OMmsg, p_surface, cons_list, 
                                      &skin_grid->objid );
    add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
        str = "EFPlaceSkinSurface : EFspecial_case_from_geom error", 
        action = GOTO_VALUE, value = wrapup );
  } /* End of else if madecomp  */
  
wrapup :
  /* 
   * if there is a failure, then remove the intermediate split surface objects
   * created 
   */
  if( !(*EFmsg&1) )
  { 
    int i;

    for(i=0; i<n_sf; i++)
      DeleteObject( &split_surf_objids[i], cons_list->env_info );
  }

  /*
   * Free the surface geometrices 
   */
  if(p_surface) BSfreesf(&BSmsg, p_surface);
  if(split_surface) BSfreesf(&BSmsg, split_surface);

  return OMsts;
}

/*
 *
 * NAME
 *    EFPlaceSkinSolid
 *
 * ABSTRACT
 *    This function places a skinning solid given the cross section 
 *    curve(s) and trace curve(s) and returns the skin surface info.
 *
 * SYNOPSIS
 *
 * IGRlong               *EFmsg,     O  Return Status
 * IGRlong               options,    I  Options defined in addrmopts.h
 * struct GRvg_construct *cons_list, I  Construction List
 * IGRint                nsec_cvs,   I  Number of Cross-section curves
 * struct GRlc_info      *sec_cvs,   I  Cross-Section Curves Info
 * IGRint                ntrc_cvs,   I  Number of Trace Curves
 * struct GRlc_info      *trc_cvs,   I  Trace Curves Info
 * struct GRid           *skin_grid, O  Created Skinned Solid GRid
 * struct SkinSurfInfo   *skin_info  O  Skin Solid Info if required 
 *                                      otherwise NULL.
 *
 * DESCRIPTION
 *
 * RETURN VALUE 
 *
 *    EMS_S_Success        Successful
 *    EMS_E_Fail           Failure 
 *
 * NOTES
 * 
 * INDEX
 *
 * KEYWORDS
 *    skinning,solid,composite
 *
 * HISTORY
 *    Sanjay    12/13/94    Creation 
 *
 */
IGRlong EFPlaceSkinSolid (
IGRlong               *EFmsg,
IGRlong               options,  /* SKIN_OPT_SMOOTH, SKIN_OPT_ABSOLUTE, 
                                   SKIN_OPT_MADECOMP, SKIN_OPT_CLOSED */
struct GRvg_construct *cons_list,
IGRint                nsec_cvs,
struct GRlc_info      *sec_cvs,
IGRint                ntrc_cvs,
struct GRlc_info      *trc_cvs,
struct GRid           *skin_grid,
struct SkinSurfInfo   *skin_info )
{
  /* general */
  IGRlong  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
  OMuword  osnum = cons_list->env_info->md_id.osnum;
  struct GRid surf_grid;

  /* INITIALIZATION */
  *EFmsg = EMS_S_Success; 
  surf_grid.objid = NULL_OBJID;
  skin_grid->objid = NULL_OBJID;

  /* 
   * Create Skin Surface 
   */
  OMsts = EFPlaceSkinSurface( &OMmsg, options, cons_list, nsec_cvs, sec_cvs,
                              ntrc_cvs, trc_cvs, &surf_grid, skin_info );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFPlaceSkinSolid : EFPlaceSkinSurface error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Cap the surface to create a solid
   */
  OMsts = om$construct( classid = OPP_EMSsfsolid_class_id,
                        p_objid = &skin_grid->objid,
                        osnum   = osnum,
                        msg = message EMSsfsolid.EMcap_thyself( &OMmsg, 
                                      cons_list, &surf_grid.objid ) 
                      );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFPlaceSkinSolid : EFPlaceSkinSurface error",
      action = GOTO_VALUE, value = wrapup );

  skin_grid->osnum = osnum;


wrapup :
  /*
   * If there is a failure, Delete the intermediate surface object if created
   */
  if( !(1&*EFmsg) && surf_grid.objid != NULL_OBJID )
  {
    DeleteObject( &surf_grid.objid, cons_list->env_info );
  }

  return OMsts;
}

end implementation Root;
