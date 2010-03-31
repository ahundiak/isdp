
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

/*		Apogee compliant		*/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <FI.h>

#include "wl.h"

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "dpstruct.h"
#include "msdef.h"
#include "msmacros.h"
#include "godef.h"
#include "go.h"
#include "bs.h"
#include "bsparameters.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSprop.h"
#include "EMSlcdef.h"
#include "madef.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hsmsg.h"
#include "hsdef.h"
#include "HStl_global.h"
#include "hsurf.h"
#include "hsvhl.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSlvhl.h"
#include "HSplot.h"
#include "HSplot_def.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "DEso.h"

#include "VEsodef.h"
#include "VEsomacros.h"

/* Prototypes */
#include "bsunwght_p.h"
#include "bsactivsplt.h"
#include "HSpr_lvhl.h"


/*-----------------------------
 *  for function
 *     HSbcurve_tiler
 */

#include "HSpr_tiler_f.h"

/*----------------------------
 *  for function
 *     HPwrite_curve
 *     HPwrite_curve_info
 *     HPwrite_draw_range
 */

#include "HSpr_hplot.h"

/*---------------------------
 *  for function
 *     HSinit_heartbeat
 */

#include "HSpr_co_func.h"

/*---------------------------*/


extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_EMSboundary_class_id;

extern IGRboolean DPdynamic_update_in_progress;

%safe
static struct IGRbsp_curve *temp_curve;
static struct GRvg_construct cons_args;
static struct IGRdisplay curve_attr;
static struct GRmd_env HSmaster_env;
static IGRlong cons_msg;
static char first_time = TRUE;
static double active_z = 0.0;

struct HStemp_curve_info
{
   double *poles, *knots, *weights;
   int num_poles, num_knots, num_weights;
};

static struct HStemp_curve_info HStemp_curve_mem = {NULL, NULL, NULL, 0, 0, 0};

static char activated_string[40];
static char completed_string[40];
static int num_activated;
static int num_completed;

static int bs_ptr_size = 0;
static struct IGRbsp_curve *bs_ptr = NULL;

static IGRshort id_matrix_type = MAIDMX;
static IGRmatrix id_matrix = {1.0, 0.0, 0.0, 0.0,
   0.0, 1.0, 0.0, 0.0,
   0.0, 0.0, 1.0, 0.0,
0.0, 0.0, 0.0, 1.0};

static IGRboolean symbol_found = FALSE;

%endsafe

from GRvg import GRconstruct;
from GRvg import GRgetsize;
from GRvg import GRgetgeom;
from GRgraphics import GRgetrang;
from GRmodule import GRmdaddwrng;
from EMSboundary import EMgetxyzobj;
from EMSedge import EMget_props;
from OMObjSpace import get_status;

#define	DEBUG	0

/*---HSlvhl_set_active_z---------------------------------------------------*/

void HSlvhl_set_active_z( double act_z )

/*
DESCRIPTION
        Initialize the active_z global static
        
PARAMETERS
        act_z	:(IN) :  Active Z value to initialize with
        
HISTORY
        03/03/92	M. Lanier
                Creation Date
                
*/

{
   active_z = -act_z;
}

/*--- HSis_os_read_only ---------------------------------------------------*/

IGRboolean HSis_os_read_only( OMuword osnum )

/*
DESCRIPTION
        This function returns TRUE if an object space is read-only and
        FALSE otherwise.

HISTORY
        S.P. Rogers  11/13/91  Creation Date
*/

{
   IGRlong sts;
   OM_S_OSSTATUS os_status;

   /* determine the read/write status of the object space */
   os_status.stattype = OM_OS_STATUS_MISC;
   sts = om$send( msg = message OMObjSpace.get_status( &os_status ),
                  senderid = NULL_OBJID,
                  targetid = 0, /* Object Space Object is always object 0 */
                  targetos = osnum );

   return ( ( os_status.stat.misc.OSflags & OM_e_loados_ro ) );

}/* HSis_os_read_only */

/*---transform--------------------------------*/

static void transform( double matrix[4][4],
                            double p[3],
                            int rational,
                            double *weight )

{
   double new_x, new_y, new_z;


   /* Transform 3D points */

   new_x = ( matrix[0][0] * p[0] ) +
      ( matrix[0][1] * p[1] ) +
      ( matrix[0][2] * p[2] );
   new_y = ( matrix[1][0] * p[0] ) +
      ( matrix[1][1] * p[1] ) +
      ( matrix[1][2] * p[2] );
   new_z = ( matrix[2][0] * p[0] ) +
      ( matrix[2][1] * p[1] ) +
      ( matrix[2][2] * p[2] );

   if ( rational )
   {
      p[0] = new_x + ( matrix[0][3] * *weight );
      p[1] = new_y + ( matrix[1][3] * *weight );
      p[2] = new_z + ( matrix[2][3] * *weight );
   }
   else
   {
      p[0] = new_x + matrix[0][3];
      p[1] = new_y + matrix[1][3];
      p[2] = new_z + matrix[2][3];
   }
}

/*---- HSget_temp_curve_storage -------------------------------------------*/


/*
DESCRIPTION
        This function returns temporary space for the poles, knots and weights
        of a curve.
        
HISTORY
        S.P. Rogers  09/29/87  Creation Date
*/


void HSget_temp_curve_storage( struct IGRbsp_curve * curve,
                                    struct IGRbsp_curve * sc )

{

   /* check the space that is already allocated to see if it is big enough */

   if ( sc->num_poles > HStemp_curve_mem.num_poles )
   {
      if ( HStemp_curve_mem.poles )
         free( ( IGRchar * ) HStemp_curve_mem.poles );
      HStemp_curve_mem.num_poles = sc->num_poles;
      HStemp_curve_mem.poles =
         ( IGRdouble * ) malloc( HStemp_curve_mem.num_poles * 3 * sizeof( IGRdouble ) );
   }

   if ( sc->num_knots > HStemp_curve_mem.num_knots )
   {
      if ( HStemp_curve_mem.knots )
         free( ( IGRchar * ) HStemp_curve_mem.knots );
      HStemp_curve_mem.num_knots = sc->num_knots;
      HStemp_curve_mem.knots =
         ( IGRdouble * ) malloc( HStemp_curve_mem.num_knots * sizeof( IGRdouble ) );
   }

   if ( sc->rational )
   {
      if ( sc->num_poles > HStemp_curve_mem.num_weights )
      {
         if ( HStemp_curve_mem.weights )
            free( ( IGRchar * ) HStemp_curve_mem.weights );
         HStemp_curve_mem.num_weights = sc->num_poles;
         HStemp_curve_mem.weights =
            ( IGRdouble * ) malloc( HStemp_curve_mem.num_weights * sizeof( IGRdouble ) );
      }
   }

   memcpy( curve, sc, sizeof( struct IGRbsp_curve ) );

   curve->poles = HStemp_curve_mem.poles;
   curve->knots = HStemp_curve_mem.knots;
   curve->weights = HStemp_curve_mem.weights;

   memcpy( curve->poles, sc->poles, sc->num_poles * 3 * sizeof( double ) );
   memcpy( curve->knots, sc->knots, sc->num_knots * sizeof( double ) );

   if ( sc->rational )
      memcpy( curve->weights, sc->weights, sc->num_poles * sizeof( double ) );
}

#define MAPCOLOR( color )	\
	((((color)-tiling_parms.base_color) / tiling_parms.number_shades) + 1)

/*---HSlvhl_split_and_tile_curve--------------------------------------------------------*/

void HSlvhl_split_and_tile_curve( IGRint * file_id,
                                       struct IGRbsp_curve * curve,
                                       double us,
                                       double ue,
                                       int options,
                                       int pipe_no,
                                       int color,
                                       int acc_mode,
                                       int accuracy,
                                       double win_cht,
                                       double *clip_range )

{
   IGRlong sts;
   IGRlong rc1;
   IGRboolean tst_planar = FALSE;
   int sizbuf, nret, msg;


/*
fprintf( stderr, "HSlvhl_plot_and_tile_curve: \n" );
fprintf( stderr, "   start, stop -- %f %f\n", us, ue );
*/

   if ( first_time )
   {
      first_time = FALSE;

      temp_curve = ( struct IGRbsp_curve * ) malloc( sizeof( struct IGRbsp_curve ) );

      sizbuf = sizeof( struct GRmd_env );

      gr$get_module_env( 
                         msg = &msg,
                         sizbuf = &sizbuf,
                         buffer = &HSmaster_env,
                         nret = &nret );

      /* set the master env objid to NULL so the curve will not be added to
       * the rtree */

      HSmaster_env.md_id.objid = NULL_OBJID;

      cons_args.msg = &cons_msg;
      cons_args.env_info = &HSmaster_env;
      cons_args.newflag = FALSE;
      cons_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      cons_args.class_attr = NULL;
      cons_args.name = NULL;
      cons_args.display = &curve_attr;
   }

   HSget_temp_curve_storage( 
                             temp_curve,
                             curve );

   /* split out span into temporary curve */

   sts = BSactivsplt( &rc1,
                      curve,
                      &us,
                      &ue,
                      temp_curve,
                      &tst_planar );

   BS_STSCHK( sts, "HSlvhl_split_and_tile_curve: BSactivsplt - bad sts" );
   BS_ERRCHK( rc1, "HSlvhl_split_and_tile_curve: BSactivsplt failed" );

   if ( rc1 != BSSUCC )
      return;

   if ( file_id == NULL )
   {
      HSbcurve_tiler( 
                      pipe_no,
                      temp_curve,
                      color,
                      options,
                      TRUE,
                      acc_mode,
                      accuracy,
                      win_cht,
                      clip_range );
   }
   else
   {
      HPwrite_draw_range( 
                          file_id,
                          NURB_EDGE,
                          ( int ) 99,
                          NULL );

      HPwrite_curve_info( 
                          file_id,
                          temp_curve,
                          3,
                          NULL );
   }
}

/*---HSlvhl_create_curve--------------------------------------------------------*/

void HSlvhl_create_curve( struct IGRbsp_curve * curve,
                               double us,
                               double ue,
                               unsigned short color,
                               unsigned char weight,
                               unsigned char style,
                               short layer )

{
   IGRlong sts;
   IGRlong rc1;
   IGRboolean tst_planar = FALSE;
   OM_S_OBJID new_object;
   int sizbuf, nret, msg;
   OMuword object_class_id;
   int i, j;


/**
fprintf( stderr, "HSlvhl_create_curve: \n" );
fprintf( stderr, "   start, stop -- %f %f\n", us, ue );
fprintf( stderr, "   color -------- %d\n", color );
fprintf( stderr, "   weight ------- %d\n", weight );
fprintf( stderr, "   style -------- %d\n", style );
**/

   if ( first_time )
   {
      first_time = FALSE;

      temp_curve = ( struct IGRbsp_curve * ) malloc( sizeof( struct IGRbsp_curve ) );

      sizbuf = sizeof( struct GRmd_env );

      gr$get_module_env( 
                         msg = &msg,
                         sizbuf = &sizbuf,
                         buffer = &HSmaster_env,
                         nret = &nret );

      /* set the master env objid to NULL so the curve will not be added to
       * the rtree */

      HSmaster_env.md_id.objid = NULL_OBJID;

      cons_args.msg = &cons_msg;
      cons_args.env_info = &HSmaster_env;
      cons_args.newflag = FALSE;
      cons_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_VE_CURVE;
      cons_args.class_attr = NULL;
      cons_args.name = NULL;
      cons_args.display = &curve_attr;
   }

   HSget_temp_curve_storage( 
                             temp_curve,
                             curve );

   curve_attr.weight = weight;
   curve_attr.style = style;
   curve_attr.color = color;
   cons_args.level = layer;

   /* split out span into temporary curve */

   sts = BSactivsplt( &rc1,
                      curve,
                      &us,
                      &ue,
                      temp_curve,
                      &tst_planar );

   BS_STSCHK( sts, "HSlvhl_create_curve: BSactivsplt - bad sts" );
   BS_ERRCHK( rc1, "HSlvhl_create_curve: BSactivsplt failed" );

   if ( rc1 != BSSUCC )
      return;

   if ( HSlvhl.output_2d )
      for ( i = 0, j = 0; i < temp_curve->num_poles; i++, j += 3 )
      {

         /* for each pole, transform to the view, set z to active z and
          * transform back to world */

         transform( 
                    HSlvhl.t_matrix,
                    &temp_curve->poles[j],
                    temp_curve->rational,
                    &temp_curve->weights[i] );

         /* flatten curve to active Z of the window */

         if ( temp_curve->rational )
            temp_curve->poles[j + 2] = active_z * temp_curve->weights[i];
         else
            temp_curve->poles[j + 2] = active_z;

         transform( 
                    HSlvhl.i_matrix,
                    &temp_curve->poles[j],
                    temp_curve->rational,
                    &temp_curve->weights[i] );
      }

   cons_args.geometry = ( char * ) temp_curve;

   if ( temp_curve->order == 2 )
   {
      object_class_id = ( temp_curve->num_poles == 2 ) ?
         OPP_GR3dlineseg_class_id : OPP_GR3dlinestr_class_id;

      if ( temp_curve->rational )
      {

         /* Rational linestring => unweight the poles so */
         /* the geometry will be posted correctly.	 */

         BSunwght_p( 
                     &rc1,
                     temp_curve->poles,
                     temp_curve->weights,
                     &temp_curve->num_poles,
                     temp_curve->poles );

         BS_ERRCHK( rc1, "HSlvhl_create_curve: BSunwght_p failed" );

         temp_curve->rational = FALSE;
      } /* end: if ( temp_curve->rational ) */
   }
   else
      object_class_id = OPP_GRbcsubbc_class_id;

   cons_args.geometry = ( char * ) temp_curve;

   sts = om$construct( 
                       msg = message GRvg.GRconstruct( &cons_args ),
                       osnum = HSmaster_env.md_id.osnum,
                       classid = object_class_id,
                       p_objid = &new_object );

   OM_ERRCHK( sts, "HSlvhl_create_curve: om$construct failed" );

   HSlvhl_add_curve_to_pool( new_object );
}

/*--- HSget_model_space_counterpart ---------------------------------*/

void HSget_model_space_counterpart( IGRboolean create,
                                         OM_S_OBJID edge_id,
                                         OMuword edge_os,
                                         struct GRmdenv_info * mdenv_info,
                                         GRobjid * msc_id )

/*
DESCRIPTION
        This function gets the model space counterpart for an edge.
*/

{
   IGRshort options;
   IGRlong msg;
   IGRint sts;
   OMuword edge_classid;

   *msc_id = NULL_OBJID;

   om$get_classid( objid = edge_id, osnum = edge_os, p_classid = &edge_classid );

   if ( om$is_ancestry_valid( subclassid = edge_classid,
                 superclassid = OPP_EMSboundary_class_id ) == OM_S_SUCCESS )
   {
      /* edge is from a loop => get MSC id by sending EMgetxyzobj assuming   */
      /* that the edge is the dominant edge if it is from a shared edge pair */
      options = ( create ) ? 0 : EMSlcopt_existingmsc;
      sts = om$send( msg = message EMSboundary.EMgetxyzobj( &msg,
                                                            options,
                                                            mdenv_info,
                                                            NULL, NULL,
                                                            NULL, NULL,
                                                            edge_os,
                                                            msc_id ),
                     senderid = NULL_OBJID,
                     targetid = edge_id,
                     targetos = edge_os );

      OM_ERRCHK( sts, "HSget_model_space_counterpart:  EMgetxyzobj send failed" );
      MSG_ERRCHK( msg, "HSget_model_space_counterpart:  EMgetxyzobj failed" );
   }
   else
   {
      /* edge is a standalone curve => it is its own MSC */
      *msc_id = edge_id;
   }

}


/*---HSlvhl_output_soo_span--------------------------------------------------------*/

void HSlvhl_output_soo_span( struct IGRbsp_curve * curve,
                                  double us,
                                  double ue,
                                  int visibility )

{
   GRobjid msc_id;
   IGRshort span_type;
   double u_parms[2];

   if ( ( ue - us ) < 0.000001 )
      return;

   if ( visibility == VISIBLE )
      return;
   else
   {
      HSget_model_space_counterpart( TRUE, HSlvhl.edge_id, HSlvhl.edge_os,
                                     &HSlvhl.md_env.md_env, &msc_id );

      if ( msc_id != NULL_OBJID )
      {
         if ( us <= 0.0 )
            us = 0.0;
         if ( ue >= 1.0 )
            ue = 1.0;

         u_parms[0] = us;
         u_parms[1] = ue;

         span_type = HE_HIDDEN_SPAN;
         VEplace_multiple_soos( 1, u_parms, &span_type, FALSE, msc_id, &HSlvhl.md_env );
      }
   }
}

/*---HSlvhl_output_curve_span--------------------------------------------------------*/

/*
HISTORY
   12/3/93   M. Lanier
      Added case for non-RAMP mode object
*/

void HSlvhl_output_curve_span( struct IGRbsp_curve * curve,
                                    double uleft,
                                    double uright,
                                    int visibility )

{
/**
fprintf( stderr, "\nHSoutput_span: \n" );
fprintf( stderr, "   start, stop -- %f %f\n", uleft, uright );
fprintf( stderr, "   visibility --- %d\n", visibility );
fprintf( stderr, "   color -------- %d\n", element_parms.color );
**/


   if ( !( ( tiling_parms.processing_mode & HS_PMODE_DISPLAY_HIDDEN_LINES ) ||
           ( visibility == VISIBLE ) ) )
      return;


   /* output orignal curve from uleft to uright */

   if( !active_window->using_ramps )
      {
      if ( visibility == VISIBLE )
         {
         HSlvhl_create_curve( 
            curve,
            uleft, uright,
            HSlvhl.visible_symbology.flags & DPB_USE_ORIG_COLOR ?
               element_parms.color_logical : HSlvhl.visible_symbology.color,
            HSlvhl.visible_symbology.flags & DPB_USE_ORIG_WEIGHT ?
               element_parms.visible_weight : HSlvhl.visible_symbology.weight,
            HSlvhl.visible_symbology.flags & DPB_USE_ORIG_STYLE ?
               element_parms.visible_style : HSlvhl.visible_symbology.style,
            HSlvhl.visible_layer );
         }
      else
         {
         HSlvhl_create_curve( 
            curve,
            uleft, uright,
            HSlvhl.hidden_symbology.flags & DPB_USE_ORIG_COLOR ?
               element_parms.color_logical : HSlvhl.hidden_symbology.color,
            HSlvhl.hidden_symbology.flags & DPB_USE_ORIG_WEIGHT ?
               element_parms.visible_weight : HSlvhl.hidden_symbology.weight,
            HSlvhl.hidden_symbology.flags & DPB_USE_ORIG_STYLE ?
               element_parms.visible_style : HSlvhl.hidden_symbology.style,
            HSlvhl.hidden_layer );
         }
      }      
   else
      {
      if ( visibility == VISIBLE )
         {
         HSlvhl_create_curve( 
            curve,
            uleft, uright,
            HSlvhl.visible_symbology.flags & DPB_USE_ORIG_COLOR ?
               MAPCOLOR( element_parms.color ) : HSlvhl.visible_symbology.color,
            HSlvhl.visible_symbology.flags & DPB_USE_ORIG_WEIGHT ?
               element_parms.visible_weight : HSlvhl.visible_symbology.weight,
            HSlvhl.visible_symbology.flags & DPB_USE_ORIG_STYLE ?
               element_parms.visible_style : HSlvhl.visible_symbology.style,
            HSlvhl.visible_layer );
         }
      else
         {
         HSlvhl_create_curve( 
            curve,
            uleft, uright,
            HSlvhl.hidden_symbology.flags & DPB_USE_ORIG_COLOR ?
               MAPCOLOR( element_parms.color ) : HSlvhl.hidden_symbology.color,
            HSlvhl.hidden_symbology.flags & DPB_USE_ORIG_WEIGHT ?
               element_parms.visible_weight : HSlvhl.hidden_symbology.weight,
            HSlvhl.hidden_symbology.flags & DPB_USE_ORIG_STYLE ?
               element_parms.visible_style : HSlvhl.hidden_symbology.style,
            HSlvhl.hidden_layer );
         }
      }
   }

#if DEBUG
/*---dump_curve--------------------------------------------------------*/

static dump_curve( struct IGRbsp_curve * curve )

{
   IGRint ui, index;

   fprintf( stderr, "\n\nCurve Definition:\n" );
   fprintf( stderr, "  order      = %d\n", curve->order );
   fprintf( stderr, "  num_poles  = %d\n", curve->num_poles );
   fprintf( stderr, "  num_knots  = %d\n", curve->num_knots );
   fprintf( stderr, "  rational   = %d\n\n", curve->rational );

   if ( curve->rational != 0 )
   {
      fprintf( stderr, "  Poles (u, x, y, z, w):\n" );

      for ( ui = 0; ui < curve->num_poles; ui++ )
         fprintf( stderr, "%5d %13.5lf %13.5lf %13.5lf %13.5lf\n",
                  ui,
                  curve->poles[( ui ) * 3] / curve->weights[ui],
                  curve->poles[( ui ) * 3 + 1] / curve->weights[ui],
                  curve->poles[( ui ) * 3 + 2] / curve->weights[ui],
                  curve->weights[ui] );
   }
   else
   {
      fprintf( stderr, "  Poles (u, x, y, z):\n" );

      for ( ui = 0; ui < curve->num_poles; ui++ )
         fprintf( stderr, "%5d %13.5lf %13.5lf %13.5lf\n",
                  ui,
                  curve->poles[( ui ) * 3],
                  curve->poles[( ui ) * 3 + 1],
                  curve->poles[( ui ) * 3 + 2] );
   }

   fprintf( stderr, "\n  knots:\n" );

   for ( index = 0; index < curve->num_knots; index++ )
      fprintf( stderr, "%17.9lf\n", curve->knots[index] );
}

#endif


/*---HSlvhl_add_curves_to_rtree----------------------------------------__*/

void HSlvhl_add_curves_to_rtree( void )

{
   GRobjid curve;
   IGRint sizbuf, nret;
   IGRlong msg;
   GRrange range;
   IGRboolean world = FALSE;
   IGRlong status;

   /* reset the curve pool so that we can start getting stuff from it */

   HSlvhl_reset_curve_pool(  );

   /* get the environment information */

   sizbuf = sizeof( struct GRmd_env );

   gr$get_module_env( 
                      msg = &msg,
                      sizbuf = &sizbuf,
                      buffer = &HSmaster_env,
                      nret = &nret );

   curve = HSlvhl_get_curve_from_pool(  );
   while ( curve != NULL )
   {

      /* get the range */

      status = om$send( mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRgetrang( 
                                                            & msg,
                                                            &id_matrix_type,
                                                            id_matrix,
                                                            &world,
                                                            range ),
                        senderid = HSmaster_env.md_id.objid,
                        targetid = curve,
                        targetos = HSmaster_env.md_id.osnum );

      if ( status & 1 )
      {
         status = om$send( mode = OM_e_wrt_object,
                           msg = message GRmodule.GRmdaddwrng( 
                                                               & msg,
                                                               range,
                                                               &curve ),
                           senderid = curve,
                           targetid = HSmaster_env.md_id.objid,
                           targetos = HSmaster_env.md_id.osnum );
      }

      if ( !( 1 & status & msg ) )
      {
         om$send( msg = message Root.delete( 0 ),
                  senderid = curve,
                  targetid = curve,
                  targetos = HSmaster_env.md_id.osnum );
      }

      curve = HSlvhl_get_curve_from_pool(  );
   }
}

/****** This section deals with the os info list *******/

/*---HSlvhl_init_os_info----------------------------------------*/

void HSlvhl_init_os_info( void )

{
   HSlvhl.os_info = NULL;
}

/*---HSlvhl_free_os_info----------------------------------------*/

void HSlvhl_free_os_info( void )

{
   struct HSlvhl_os_info *curr, *next;

   curr = HSlvhl.os_info;
   while ( curr != NULL )
   {
      next = curr->next;
      free( curr );
      curr = next;
   }

   HSlvhl.os_info = NULL;
}

/*---HSlvhl_create_soos_for_os----------------------------------------*/

void HSlvhl_create_soos_for_os( void )

{
   struct HSlvhl_os_info *curr;
   GRobjid objid;
   IGRlong msg;
   IGRint resolution;
   IGRboolean master_env_processed = FALSE;

   resolution = ( HSlvhl.resolution == HS_VHL_LOW_RES ) ? VESO_LOW_RES : VESO_MED_RES;
   curr = HSlvhl.os_info;
   while ( curr != NULL )
   {
      ve$create_soo( msg = &msg,
                     osnum = curr->osnum,
                     num_surfaces = num_activated,      /* treat everything
                                                         * activated as a
                                                         * surface */
                     num_curves = 0,
                     resolution = resolution,
                     p_objid = &objid );

      if ( curr->osnum == HSlvhl.md_env.md_id.osnum )
         master_env_processed = TRUE;
      curr = curr->next;
   }

   if ( !master_env_processed )
   {
      /* need to make a DEso hash table in the master file because horizon */
      /* curves are in it regardless of where their surface is             */
      ve$create_soo( msg = &msg,
                     osnum = HSlvhl.md_env.md_id.osnum,
                     num_surfaces = num_activated,      /* treat everything
                                                         * activated as a
                                                         * surface */
                     num_curves = 0,
                     resolution = resolution,
                     p_objid = &objid );

   }

}

/*---HSlvhl_build_os_info_list----------------------------------*/

IGRint HSlvhl_build_os_info_list( IGRshort object_os,
                                         IGRboolean is_symbol )
{
   struct HSlvhl_os_info *curr;


   /* locate the input os, in the current os list.  If it doesn't exist, add
    * a new entry. */

   curr = HSlvhl.os_info;
   while ( curr != NULL )
   {
      if ( curr->osnum == object_os )
         break;
      else
         curr = curr->next;
   }

   /* if there is not an entry for the os, then create one */

   if ( curr == NULL )
   {
      curr = ( struct HSlvhl_os_info * ) malloc( sizeof( struct HSlvhl_os_info ) );

      curr->osnum = object_os;
      curr->surface_count = 0;
      curr->curve_count = 0;

      curr->readonly = HSis_os_read_only( object_os );

      curr->next = HSlvhl.os_info;
      HSlvhl.os_info = curr;
   }

   if ( is_symbol && !symbol_found )
   {
      symbol_found = 1;
      ex$message( msgnumb = HS_I_NoSymbols );
      sleep( 3 );
   }

   return ( TRUE );
}


/*---HSget_num_activated_completed----------------------------*/

void HSget_num_activated_completed( IGRint * na, IGRint * nc )

{
   *na = num_activated;
   *nc = num_completed;
}

/*---HSinit_activated_completed-------------------------------*/

void HSinit_activated_completed( void )

{
   IGRchar processing_string[60];

   num_activated = 0;
   num_completed = 0;

   if ( DPdynamic_update_in_progress )
   {
      return;
   }

   /* If we are doing LVHL, first or second pass, set the activated string to
    * activated, and the completed string to completed. */

   if ( tiling_parms.processing_mode & HS_PMODE_LVHL_SURFACE ||
        tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES )
   {
      ex$message( msgnumb = HS_I_Activated,
                  buff = activated_string );

      ex$message( msgnumb = HS_I_Completed,
                  buff = completed_string );

      ex$message( msgnumb = HS_I_Processing,
                  buff = processing_string );

      HSinit_heartbeat( processing_string );
   }

   /* If we are doing RHL first pass, set the activated string to elements
    * activated. */

   else if ( tiling_parms.processing_mode & HS_PMODE_RHL_SURFACE )
   {
      ex$message( msgnumb = HS_I_ElementsActivated,
                  buff = activated_string );
   }

   /* If we are doing RHL second pass, display "displaying" in the keyin
    * field */

   else if ( tiling_parms.processing_mode & HS_PMODE_RHL_EDGES )
   {
      ex$message( msgnumb = HS_I_DisplayingElements,
                  buff = activated_string );

      ex$message( in_buff = activated_string,
                  field = KEYIN_FIELD );
   }
}

/*---HSupdate_activated_completed-----------------------------*/

void HSupdate_activated_completed( void )

{
   IGRchar temp_string[100];

   /* This message will only display if the processing mode is RHL surfaces,
    * LVHL surfaces or LVHL edges.  For LVHL, display # activated, #
    * completed; for RHL (surface pass only) display # activated.  Updated
    * the num_activated first pass, num_completed second pass. */

   if ( tiling_parms.processing_mode & ( HS_PMODE_RHL_SURFACE | HS_PMODE_LVHL_SURFACE ) )
      num_activated++;
   else if ( tiling_parms.processing_mode & ( HS_PMODE_LVHL_EDGES ) )
      num_completed++;

   if ( DPdynamic_update_in_progress )
   {
      return;
   }

   if ( tiling_parms.processing_mode & ( HS_PMODE_LVHL_SURFACE | HS_PMODE_LVHL_EDGES ) )
      sprintf( temp_string, "%d %s, %d %s",
               num_activated, activated_string,
               num_completed, completed_string );
   else if ( tiling_parms.processing_mode & ( HS_PMODE_RHL_SURFACE ) )
      sprintf( temp_string, "%d %s",
               num_activated, activated_string );

   if ( tiling_parms.processing_mode & ( HS_PMODE_LVHL_SURFACE | HS_PMODE_LVHL_EDGES | HS_PMODE_RHL_SURFACE ) )
      ex$message( in_buff = temp_string,
                  field = KEYIN_FIELD );
}

/*---HSget_curve_geometry_from_pline--------------------------------------------------*/

IGRint HSget_curve_geometry_from_pline( GRobjid objid,
                                               GRspacenum osnum,
                                           struct GRmdenv_info * mdenv_info,
                                               struct IGRbsp_curve ** curve )

{
   IGRlong msg;
   IGRint status;
   IGRlong object_size;

   status = om$send( msg = message GRvg.GRgetsize( 
                                                   &msg,
                                                   &mdenv_info->matrix_type,
                                                   mdenv_info->matrix,
                                                   &object_size ),
                     senderid = objid,
                     targetid = objid,
                     targetos = osnum );

   OM_ERRCHK( status, "failed to GRgetsize\n" );
   if ( !( ( status & msg ) & 1 ) )
      return ( status );

   if ( bs_ptr == NULL )
   {
      bs_ptr_size = ( object_size + 256 ) & 0x7fffff00;
      bs_ptr = ( struct IGRbsp_curve * ) malloc( bs_ptr_size );
   }
   else
   {
      if ( object_size > bs_ptr_size )
      {
         free( bs_ptr );
         bs_ptr_size = ( object_size + 256 ) & 0x7fffff00;
         bs_ptr = ( struct IGRbsp_curve * ) malloc( bs_ptr_size );
      }
   }

   status = om$send( msg = message GRvg.GRgetgeom( 
                                                   &msg,
                                                   &mdenv_info->matrix_type,
                                                   mdenv_info->matrix,
                                                   ( IGRchar * ) bs_ptr ),
                     senderid = objid,
                     targetid = objid,
                     targetos = osnum );

   OM_ERRCHK( status, "failed to GRgetgeom\n" );
   if ( !( ( status & msg ) & 1 ) )
      return ( status );

   *curve = bs_ptr;

   return ( OM_S_SUCCESS );
}

end implementation Root;
