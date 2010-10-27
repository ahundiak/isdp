/*
HISTORY  Sudha  07/28/93  Modified for BSprototype ansification
         ML  12/94  Made get_graphics_edges work-around
         dh  3/14/95  no longer call get_graphics_edges for VDS
*/
class implementation Root;

#define CHECK_RETURN_CODES	0

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"

#include "exdef.h"
#include "ex.h"

#include "DIdef.h"

#include "msdef.h"
#include "gr.h"

#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"

#include "dpstruct.h"

#include "bstypes.h"
#include "bscv_copy.h"
#include "bsisfprtlns.h"
#include "bsparameters.h"

#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSasnuc.h"
#include "EMSmsgdef.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "bserr.h"

/* prototype files */
#include "VEpr_marking.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
#include "bssfpartrg.h"
#include "bschrdlkts.h"
#include "bsptlnplan.h"

#include "dp.h"
#include "grdpbdef.h"
#include "GRdpbfunc.h"
#include "GRsetinq.h"
#include "grdpbmacros.h"

extern struct VEresults_info VEoutput_data;

from EMSsubbs import EMget_graphics_edges;
from GRvg import GRgenabsg;
from GRvg import GRgetsize;
from GRvg import GRgetgeom;

extern struct GRmd_env VEmaster_env;
extern struct VEwindow_info VEwin_info;
extern struct VEexecution_status VEexec_status;

extern IGRboolean VDS_is_running;  /* tells whether VDS is running at all */

%safe
static struct IGRbsp_surface *bs_ptr = NULL;
static int bs_ptr_size = 0;

%endsafe

/*---VEget_surface_geometry-----------------------------------*/

static void VEget_surface_geometry( struct VEelement_header *elem )

   {
   IGRlong		msg, status;
   IGRlong		object_size;

   /*
    * get buffer size required by the b-spline object
    */
 
   status = om$send( msg = message GRvg.GRgetsize(
                                           &msg,
                                           &elem->env->matrix_type,
                                           elem->env->matrix,
                                           &object_size ),
                senderid = elem->objid,
                targetid = elem->objid,
                targetos = elem->env->osnum );
 
   OM_ERRCHK( status, "failed to GRgetsize\n" );
   MSG_ERRCHK( msg, "failed to GRgetsize\n" );
 

   /*
    * allocate space for geometry and retrieve it.
    */
 
   if( bs_ptr == NULL )
      {
      bs_ptr_size = (object_size + 256) & 0x7fffff00;
      bs_ptr = (struct IGRbsp_surface *)malloc( bs_ptr_size );
      }
   else
      {
      if( object_size > bs_ptr_size )
         {
         free( bs_ptr );
         bs_ptr_size = (object_size + 256) & 0x7fffff00;
         bs_ptr = (struct IGRbsp_surface *)malloc( bs_ptr_size );
         }
      }
 
   status = om$send( msg = message GRvg.GRgetgeom (
                                           &msg,
                                           &elem->env->matrix_type,
                                           elem->env->matrix,
                                           (IGRchar *)bs_ptr ),
                senderid = elem->objid,
                targetid = elem->objid,
                targetos = elem->env->osnum );
   }

/*---VEcreate_horizon_edges-----------------------------------*/

static void VEcreate_horizon_edges ( struct VEelement_header *elem,
                                     struct VEedge_header    **tail )

   {
   struct VEedge_header	*edge;

   BSrc			rc;
   IGRdouble		u_range[2], v_range[2], z_vector[3];
   IGRdouble		normal[3];
   IGRint		num_groups, i;
   IGRint		code;
   struct BSpartgrp	*groups;
   struct BSpartgrp	*temp_group;
   struct IGRbsp_curve	curve;
   struct IGRpolyline	polyline;

   u_range[0] = bs_ptr->u_knots[bs_ptr->u_order - 1];
   u_range[1] = bs_ptr->u_knots[bs_ptr->u_num_knots - bs_ptr->u_order];
   v_range[0] = bs_ptr->v_knots[bs_ptr->v_order - 1];
   v_range[1] = bs_ptr->v_knots[bs_ptr->v_num_knots - bs_ptr->v_order];

   num_groups = 0;

   /* find the parting lines for this surface */

   z_vector[0] = VEwin_info.VErot_matrix[2][0];
   z_vector[1] = VEwin_info.VErot_matrix[2][1];
   z_vector[2] = VEwin_info.VErot_matrix[2][2];

   BSsfpartrg( bs_ptr,
               z_vector,
               u_range,
               v_range,
               1,
               &num_groups,
               &groups,
               &rc);

   BS_ERRCHK (rc, "HScreate_horizon_edges: BSsfpartrg failed");

   if (rc == BSSUCC)
      {

      /* process each group as a separate edge */

      for (i = 0; i < num_groups; i++)
         {

         edge = VEalloc_edge_header();
         if( !edge ) break;

         edge->edge_id = VEexec_status.VEunique_edge_id--;
         edge->type = HORIZON_CURVE;
/*
         edge->status = EDGE_IS_ISOCURVE;
         edge->iso_parm = NULL;
*/

         /* Places poles and num poles in the curve structure */

         curve.num_poles = groups->num;
         curve.poles = (IGRdouble *) groups->pts;

         /* allocate memory for knots */

         curve.num_knots = curve.num_poles + 2;
         curve.knots = (IGRdouble *) malloc (curve.num_knots * sizeof (IGRdouble));

         curve.order = 2;
         curve.periodic = FALSE;
         curve.non_uniform = TRUE;
         curve.rational = FALSE;
         curve.weights = NULL;
         curve.planar = FALSE;
         curve.phy_closed = FALSE;
         curve.num_boundaries = 0;
         curve.bdrys = NULL;

         /* space knots with respect to arc length between poles */

         BSchrdlkts( &rc,
                     &curve.num_poles,
                     curve.poles,
                     &curve.order,
                     &curve.periodic,
                     curve.knots);

         BS_ERRCHK (rc, "HScreate_horizon_edges: BSchrdlkts failed");

         /* check the planarity of the horizon line */

         BSptlnplan( curve.num_poles,
                     curve.rational,
                     (IGRpoint *) curve.poles,
                     curve.weights,
                     &code,
                     normal,
                     &rc);

         BS_ERRCHK (rc, "HScreate_horizon_edge: BSptlnplan failed");

         switch (code)
            {
            case 1:
            case 2:
            case 4: 

               /* parting line collapses to a point, line or is non-planar */

               curve.planar = FALSE;
               break;

            case 3:

               /* parting line is planar */

               curve.planar = TRUE;
               break;

               }

         edge->gm_curve3d = VEalloc_geom_curve( curve.order,
                                                curve.num_poles,
                                                curve.rational,
                                                curve.num_boundaries );

         if( !edge->gm_curve3d )
            {
            VEfree_edge_header( edge );
            break;
            }

         BScv_copy( &rc, &curve, edge->gm_curve3d->bspcv );

         VEtrans_curve_to_view( edge->gm_curve3d->bspcv );

         edge->gm_curve3d->type = VEget_edge_geom_type( edge->edge_id, 
                                                        elem->env->osnum, 
                                                        TRUE );

         edge->gm_curve3d->geom_prop = FALSE;
         edge->gm_curve3d->bscv_flag = TRUE;

         edge->visib_list = VEconstruct_visib_list( edge->gm_curve3d->bspcv, VISIBLE );

         if( elem->flags & HAS_BOUNDARIES )
            {
            polyline.num_points = groups->num;
            polyline.points = (IGRdouble *)groups->par;
            edge = VEtrim_polyline( elem, edge, &polyline, GENERAL_POLY );
            }


         VEadd_edges_to_list( edge, &elem->edges, tail );

         if (curve.knots != NULL) free (curve.knots);

         temp_group = groups;
         groups = groups->next;

         /* free uv array in group header */

         free ((IGRchar *) temp_group->par);

         /* free parting group header */

         free ((IGRchar *) temp_group);
         }
      }
   }

/*--- VEmark_surface_edges ---------------------------------------------*/

void VEmark_surface_edges( elem )
   struct VEelement_header *elem;

/*
NAME
        VEmark_surface_edges

DESCRIPTION
        This function marks the edges for a surface.

PARAMETERS
        elem (IN) - the element whose edge list is to be created

GLOBALS USED
        VDve_processing

HISTORY
        S.P. Rogers  07/05/91  Creation Date
        ML  12/94  Made get_graphics_edges work-around
        dh  3/14/95  no longer call get_graphics_edges for VDS
*/
{
   IGRlong sts = 0, msg = 0, rc = 0;
   IGRshort horizon_type;
   IGRint ii;
   IGRint num_horiz = 0, num_cusp = 0;
   IGRint num_parents = 2;
   struct GRid *horiz = NULL, *cusp = NULL;
   struct VEedge_header *tail = NULL;
   struct VEedge_header *loopset_edges;
   struct VEedge_header *edge;
   struct EMSobject_info parents[2];
   struct IGRbsp_curve *curve;

   /* get the loop set edges for the surface */
   loopset_edges = VEget_surf_edges_and_bdrys( elem );
   VEadd_edges_to_list( loopset_edges, &elem->edges, &tail );

   if ( elem->geom.gmsurf->bspsf->planar )
      return;   /* no horizon edges/cusps for planar surfaces */

   /* get the horizon edges and cusps for the surface */
   memcpy( &parents[0].grid, &elem->env->ref_plane,
           sizeof( struct GRid ) );
   if ( elem->env->ref_plane.osnum != elem->env->osnum )
   {
      /* ref. plane is in the master file because we are processing a */
      /* read-only reference file */
      memcpy( &parents[0].env, &VEmaster_env, sizeof( struct GRmd_env ) );
   }
   else
   {
      memcpy( &parents[0].env, &elem->env->md_env,
              sizeof( struct GRmd_env ) );
   }

   parents[1].grid.objid = elem->objid;
   parents[1].grid.osnum = elem->env->osnum;
   memcpy( &parents[1].env, &elem->env->md_env,
           sizeof( struct GRmd_env ) );

   /* if VDS is not running at all (whether CVE or VDS-specific VE */
   /* processing), get the graphic edges via message send; else skip */
   /* (for VDS) the error-precipitating message sends */
   if ( !VDS_is_running )
   {
      /* this message returns in 'msg' EMS_S_Success if it's returning */
      /* horizon edges and EMS_I_Success if it's returning horizon */
      /* curves */
      if ( !VEoutput_data.output_curves )
      {
         sts =
            om$send( msg = message EMSsubbs.EMget_graphics_edges( &msg,
                                                      &num_parents, parents,
                         ( EMS_OPT_HORIZON | EMS_OPT_CUSP | EMS_OPT_CREATE |
                           EMS_OPT_DELETE_HRZ | EMS_OPT_CREATE_HRZ_CVS ),
                         NULL, &num_horiz, &num_cusp, NULL, &horiz, &cusp ),
                     senderid = NULL_OBJID,
                     targetid = elem->objid,
                     targetos = elem->env->osnum );
      }
      else
      {
         sts =
            om$send( msg = message EMSsubbs.EMget_graphics_edges( &msg,
                                                      &num_parents, parents,
                     ( EMS_OPT_HORIZON | EMS_OPT_CUSP | EMS_OPT_DELETE_HRZ |
                       EMS_OPT_CREATE ),
                         NULL, &num_horiz, &num_cusp, NULL, &horiz, &cusp ),
                     senderid = NULL_OBJID,
                     targetid = elem->objid,
                     targetos = elem->env->osnum );
      }

      OM_ERRCHK( sts,
        "VEmark_surface_edges: EMSsubbs.EMget_graphics_edges send failed" );
      MSG_ERRCHK( msg,
             "VEmark_surface_edges: EMSsubbs.EMget_graphics_edges failed" );
   }

   if ( !( 1 & sts & msg ) )
   {
      /* 12/20/94 - Mike Lanier
       * 
       * We started getting alot of TRs (119423135, 119423752) that said that
       * CVE was not computing all the edges for the testcase.  The unique
       * thing about the cases was the surfaces were part of a macro.  In my
       * investigation, I found that the method EMget_graphics_edges was not
       * handling these cases, which it should have, and returned no edges.
       * I looked at the method, but knowing nothing about it and how it does
       * it's job, I was afraid that anything I did would do more harm than
       * good.  So, my only alternative was to trap the error and create my
       * own edges. (The same thing has been done in HSURF for low/med
       * CVE/PDD and RHL.)
       * 
       * Fortunatly for me, there was code in both HSURF and VE for creating the
       * edges.  HSURF called it's on rare occastion, and VE never called
       * it's.  I was able to fix Low/Med CVE/PDD and RHL by calling HSURF's
       * functions when EMget_graphics_edges failed, but had some problem
       * with the functions in VE.  VEmark_sharps_and_rules worked fine, but
       * VEmark_parting_lines did not handle all the cases that I was looking
       * at.  So, I took the HSURF function and modified it to run in VE.
       * 
       * As you see, I still use VEmark_sharps_and_rules, but have commented out
       * my call to VEmark_parting_lines, and have inserted a call to my
       * function from HSURF. (Actually, call the calls in this block, are
       * new as of 12/20/94, I just left the call to VEmark_parting_lines in
       * and commented out as a symbol of wishful thinking.
       * 
       * Mike.
       */
      VEget_surface_geometry( elem );
      VEcreate_horizon_edges( elem, &tail );
/*
      edge = VEmark_parting_lines( elem );
      VEadd_edges_to_list (edge, &elem->edges, &tail);
*/
      edge = VEmark_sharps_and_rules( elem );
      VEadd_edges_to_list( edge, &elem->edges, &tail );
      return;
   }

   horizon_type = ( msg == EMS_I_Success ) ? HORIZON_CURVE : HORIZON_EDGE;

   /* process the horizon edges */
   if ( num_horiz == 0 )
   {
/*
      edge = VEmark_parting_lines( elem );
      VEadd_edges_to_list (edge, &elem->edges, &tail);
*/
      VEget_surface_geometry( elem );
      VEcreate_horizon_edges( elem, &tail );
   }
   else
      for ( ii = 0; ii < num_horiz; ii++ )
      {
         edge = VEalloc_edge_header(  );

         if ( !edge )
            break;

         edge->edge_id = horiz[ii].objid;
         edge->type = horizon_type;

         if ( edge->type == HORIZON_EDGE )
         {
            edge->gm_curve3d =
               VEget_edge_geometry( elem->geom.gmsurf->bspsf,
                                    edge->edge_id, elem->env, TRUE );

            if ( !edge->gm_curve3d )
            {
               VEfree_edge_header( edge );
               break;
            }

            edge->gm_curve3d->type = VEget_edge_geom_type( edge->edge_id,
                                                  elem->env->osnum, FALSE );
         }
         else
         {
            /* Horizon curves are curve objects, not parametric edges */
            /* -> we must get the geometry like that of a standalone */
            /* curve.  Also, all horizon curves are created in the */
            /* master file regardless of where their corresponding */
            /* surface is */
            sts =
               om$send( msg = message GRvg.GRgenabsg( &msg,
                                           &VEmaster_env.md_env.matrix_type,
                                                 VEmaster_env.md_env.matrix,
                                                   ( IGRchar ** ) & curve ),
                        targetid = edge->edge_id,
                        targetos = VEmaster_env.md_id.osnum,
                        senderid = NULL_OBJID );

            if ( !( 1 & sts & msg ) )
            {
               break;
            }

            edge->gm_curve3d = VEalloc_geom_curve( curve->order,
                 curve->num_poles, curve->rational, curve->num_boundaries );

            if ( !edge->gm_curve3d )
            {
               VEfree_edge_header( edge );
               break;
            }

            BScv_copy( &rc, curve, edge->gm_curve3d->bspcv );

            BS_ERRCHK( rc, "VEmark_curve: BScv_copy failed" );

            /* must transform curve to viewing coordinates */
            VEtrans_curve_to_view( edge->gm_curve3d->bspcv );

            edge->gm_curve3d->type = VEget_edge_geom_type( edge->edge_id,
                                                   elem->env->osnum, TRUE );
         }

         edge->gm_curve3d->geom_prop = FALSE;
         edge->gm_curve3d->bscv_flag = TRUE;

         edge->visib_list =
            VEconstruct_visib_list( edge->gm_curve3d->bspcv, VISIBLE );

         VEadd_edges_to_list( edge, &elem->edges, &tail );
      } /* end: for */

   /* process the cusp edges */
   if ( num_cusp == 0 )
   {
      edge = VEmark_sharps_and_rules( elem );
      VEadd_edges_to_list( edge, &elem->edges, &tail );
   }
   else
      for ( ii = 0; ii < num_cusp; ii++ )
      {
         edge = VEalloc_edge_header(  );

         if ( !edge )
            break;

         edge->edge_id = cusp[ii].objid;

         edge->gm_curve3d = VEget_edge_geometry( elem->geom.gmsurf->bspsf,
                                           edge->edge_id, elem->env, TRUE );

         if ( !edge->gm_curve3d )
         {
            VEfree_edge_header( edge );
            break;
         }

         edge->type = SHARP;
         edge->gm_curve3d->type = VEget_edge_geom_type( edge->edge_id,
                                                  elem->env->osnum, FALSE );
         edge->gm_curve3d->geom_prop = FALSE;
         edge->gm_curve3d->bscv_flag = TRUE;

         edge->visib_list =
            VEconstruct_visib_list( edge->gm_curve3d->bspcv, VISIBLE );

         VEset_iso_edge_info( edge, elem->env->osnum,
                              ( IGRushort ) EMED_ISO );

         VEadd_edges_to_list( edge, &elem->edges, &tail );
      } /* end: for */

   if ( horiz )
      om$dealloc( ptr = horiz );        /* allocated with om$malloc() */

   if ( cusp )
      om$dealloc( ptr = cusp ); /* allocated with om$malloc() */
}/* VEmark_surface_edges */

end implementation Root;
