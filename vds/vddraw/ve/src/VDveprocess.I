/* $Id: VDveprocess.I,v 1.3 2001/10/20 18:41:14 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/ve/src/VDveprocess.I
 *
 * Description:
 *		Adaption of I/EMS visible edges package to support
 *		VDS visualization process, based par object process.
 *
 * Dependencies:
 *	dh	Developed this VDS driver as a "black box" which makes use
 *		of MODEL's VE processing.
 *
 * Revision History:
 *	$Log: VDveprocess.I,v $
 *	Revision 1.3  2001/10/20 18:41:14  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/10/20 18:16:03  ylong
 *	fix for TR# MP5511
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.11  1996/03/18  11:03:58  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
#
# Revision 1.10  1995/11/30  20:39:42  pinnacle
# Replaced: vddraw/ve/src/VDveprocess.I for:  by azuurhou for vds.240
#
# Revision 1.9  1995/11/22  23:48:58  pinnacle
# Replaced: ./vddraw/ve/src/VDveprocess.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/10/26  15:33:20  pinnacle
# Replaced: vddraw/ve/src/VDveprocess.I for:  by tdumbach for vds.240
#
# Revision 1.7  1995/09/25  13:35:48  pinnacle
# Replaced: vddraw/ve/src/VDveprocess.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/01/95	dh		creation date
 *	09/21/95	adz		adapt the cht to bastol in process.
 *	10/20/01	Jayadev	        Hidden line output always for VDS
 *                                      visualization process - TR# MP5511	
 *
 ***************************************************************************/
/*
HISTORY
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <string.h>
#include <values.h>
#include <stdlib.h>

#include <FI.h>

#include "vd_ve.h"

#include "OMmacros.h"

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

#include "igrdef.h"
#include "igr.h"
#include "dp.h"
#include "vedef.h"
#include "ve.h"
#include "ve_inst.h"
#include "dpchan.h"
#include "dpdef.h"

#include "bsparameters.h"
#include "bstypes.h"
#include "bschgdeppar.h"
#include "bschangepar.h"

#include "bs.h"

#include "bsxtractpar.h"

#include "bsvalues_cl.h"

#include "msdef.h"
#include "msmacros.h"

#include "dpstruct.h"
#include "dpmacros.h"

#include "godef.h"
#include "igrdp.h"
#include "go.h"

#include "grgs.h"
#include "grgsmacros.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "ve_timing.h"
#include "veerr.h"
#include "vemsg.h"
#include "VEsodef.h"
#include "VEsomacros.h"

#include "vedpbmacros.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"

/* prototype files */
#include "VEpr_driver.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "VEpr_dpb.h"


#define		VD_MAXINT	2147483647.0
IGRboolean VDve_set_transformations();

/* static prototypes */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* The following call is used by "#if TIMING" code; add back in if desired */
/*  - dh 4/3/95 */
/*
 # if defined(__cplusplus)
 extern "C"
 {
 # endif

 static IGRint VEcount_bucket_entries __( ( struct VEsort_record * bucket ) );

 # if defined(__cplusplus)
 }

 # endif
*/

#undef __


/* Add "#if TIMING" code (new2.add) here if desired  - dh 4/3/95 */


/* External - global variables */
extern struct GRmd_env VEmaster_env;
extern struct VEexecution_parms VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEtolerance_info VEtolerances;
extern struct VEenv_info *VEenv_list;

extern struct VEsort_record **VEbuckets;

extern struct VEid_list *VEcommon_id_list;
extern struct VEresults_info VEoutput_data;
extern struct VEwindow_info VEwin_info;
extern IGRboolean VEreport_errors;
extern IGRboolean VEuse_classification_alg;
extern IGRboolean VEcolor_classification;
extern IGRboolean VEstroke_all_ints;
extern IGRdouble VEstroke_cht;

extern struct VDve_elem_buf *VDvis_buf;
extern struct VDve_elem_buf *VDhid_buf;
extern IGRboolean VDve_processing;

/* Global:  indicates special VDS-specific processing is in effect, which */
/* does not output results for "reference elements" from the entry point */
/* VDref_elem_ve_process */
extern IGRboolean VDS_REF_ELEM_PROCESSING;

/*--- VDve_collect_elements -----------------------------------------------*/

void VDve_collect_elements( struct VDve_elem_buf * elem_buf )
/*
NAME
   VDve_collect_elements

DESCRIPTION
   Collect & sort all of the elements specified by the user.  The objects
   should be in a buffer that is passed into this function.

PARAMETERS
   elem_buf (IN)  -  buffer of 3D geometry elements (specified by
                    object ID and environment info) to be processed
GLOBALS USED
   VEexec_parms
   VEbuckets

HISTORY
   dh  3/1/95  Creation Date
*/
{
   IGRlong msg;
   struct GRid fence_grid;
   struct GRobj_env *curr_elem; /* pointer to current element in list */
   IGRchar temp_string[60];
   int i;

   ex$message( msgnumb = ( VE_I_ClassAndSort ), buff = temp_string );
   VEinit_heartbeat( temp_string );

   VEinit_sort( FALSE );

   /* get the fence object's id */
   fence_grid.objid = NULL_OBJID;
   fence_grid.osnum = 0;
   gr$gsget_fence( msg = &msg, fence_id = &fence_grid );

   /* Init poiner to start of buffer */
   curr_elem = elem_buf->obj_info_p;

   /* find out how many objects were located */
#if DEBUG_LOCATE
   fprintf( stderr, "Objects on channel:  %d\n\n", elem_buf->count );
   fprintf( stderr, "The located objects are:\n\n" );
#endif

   /* get each located object individually and classify it */
   for ( i = 0; i < elem_buf->count; i++ )
   {
      VEupdate_heartbeat(  );

      VEclassify_located_object( &( curr_elem->obj_id ), NULL,
                                 curr_elem->mod_env.md_env.matrix,
                                 curr_elem->mod_env.md_env.matrix_type,
                                 &( curr_elem->mod_env ), NULL, FALSE,
                                 &fence_grid, -1 );
      curr_elem++;
   }    /* end: for */
}/* VDve_collect_elements */

/*--- VDve_init_global_buffers --------------------------------------------*/

void VDve_init_global_buffers( struct VDve_elem_buf * vis_buf,
                               struct VDve_elem_buf * hid_buf )
/*
NAME
   VDve_init_global_buffers

DESCRIPTION
   Initialize global buffers for VDS use, acknowledging that the caller may
   have provided previously used buffers for recycling.

PARAMETERS
   vis_buf (IN)  -  possibly empty buffer of visible 3D curves
   hid_buf (IN)  -  possibly empty buffer of hidden 3D curves

GLOBALS USED
   VDvis_buf
   VDhid_buf

HISTORY
   dh  3/27/95  Creation Date
*/
{
   VDvis_buf = vis_buf;
   VDhid_buf = hid_buf;

   if ( NULL == VDvis_buf )
   {
      /* allocate a buffer to "prime the pump" and initialize to "empty" */
      VDvis_buf = ( struct VDve_elem_buf * ) malloc( sizeof( struct
                                                          VDve_elem_buf ) );
      VDvis_buf->obj_info_p = ( struct GRobj_env * ) calloc( VDbuf_incr,
                                               sizeof( struct GRobj_env ) );
      VDvis_buf->buf_siz = VDbuf_incr;
      VDvis_buf->count = 0;
   }
   else
   {
      /* initialize the buffer to "empty" */
      if ( NULL == VDvis_buf->obj_info_p )
      {
         VDvis_buf->buf_siz = 0;
      }
      VDvis_buf->count = 0;
   }

   if ( NULL == VDhid_buf )
   {
      /* allocate a buffer to "prime the pump" and initialize to "empty" */
      VDhid_buf = ( struct VDve_elem_buf * ) malloc( sizeof( struct
                                                          VDve_elem_buf ) );
      VDhid_buf->obj_info_p = ( struct GRobj_env * ) calloc( VDbuf_incr,
                                               sizeof( struct GRobj_env ) );
      VDhid_buf->buf_siz = VDbuf_incr;
      VDhid_buf->count = 0;
   }
   else
   {
      /* initialize the buffer to "empty" */
      if ( NULL == VDhid_buf->obj_info_p )
      {
         VDhid_buf->buf_siz = 0;
      }
      VDhid_buf->count = 0;
   }
}/* VDve_init_global_buffers */

/*--- VDve_process --------------------------------------------------------*/

IGRint VDve_process( IGRint * msg,
                            struct VDve_elem_buf * elem_buf,
                            struct VDve_elem_buf * vis_buf,
                            struct VDve_elem_buf * hid_buf,
                            IGRdouble VDwld_to_viewport[4][4],
                            IGRdouble VDviewport_to_wld[4][4],
                            IGRdouble VDrotation[4][4],
                            IGRdouble VDwld_to_view[4][4] )
/*
NAME
   VDve_process

DESCRIPTION
   Drive the Visible Edges process for VDS purposes.  The graphics elements
   should be in a buffer that is passed into this function.  Buffers of
   visible and (optionally) hidden 3D curves are returned.

   Visible and (optionally) hidden curves are created as a side effect on
   "default" visible and hidden layers, respectively, using "default"
   symbology settings.  (The caller obviously may change layer and
   symbology of these elements as desired.)

PARAMETERS
   msg  -  status indicator
   elem_buf (IN)  -  buffer of 3D geometry elements (specified by object ID &
         environment info) to be processed
   vis_buf (OUT)  -  buffer of visible 3D curves created by this process
   hid_buf (OUT)  -  buffer of hidden 3D curves created by this process; will
         be NULL if "no hidden output" is specified
   VDwld_to_viewport (IN) - equivalent of gragad's world-to-viewport
         transformation matrix
   VDviewport_to_wld (IN) - equivalent of gragad's viewport-to-world
         transformation matrix
   VDrotation (IN) - equivalent of gragad's view rotation matrix
   VDwld_to_view (IN) - equivalent of gragad's viewport-to-view
         transformation matrix

GLOBALS USED
   VEenv_list
   VEcommon_id_list
   VEmaster_env
   VEoutput_data
   VEexec_parms
   VEexec_status
   VEexec_status.VEtotal_elems
   VEexec_status.VEprev_output_found
   VEexec_status.VEupdate_window
   VEwin_info
   VEtolerances
   VEtolerances.system_base_tol
   VEtolerances.system_cht
   VEreport_errors
   VEuse_classification_alg
   VEcolor_classification
   VDvisbuf, VDhidbuf
   VDve_processing

HISTORY
  3/1/95  dh  Creation Date
*/
{
   IGRlong rc;
   IGRint i, bytes_requested, bytes_returned;
   IGRchar *expansion;
   IGRuint hs_vhl_flags, ve_vhl_flags;
   IGRboolean hidden_line_display;
   IGRshort short_surf_threshold, short_curve_threshold;
   IGRchar error_msg[150];
   IGRchar title_msg[15];
   IGRdouble	sys_cht_value ;
   IGRboolean sts_bool=0;

   /* equivalent of gragad's dit clip range in screen units relative */
   /* to the window origin; could be made a parameter of this function */
   /* if so desired */
   IGRdouble VDdit_clip_range[6];

   /* equivalent of gragad's active z in the viewing coordinate */
   /* system; could be made a parameter of this function if desired */
   IGRdouble VDact_z;

#if TIMING
/*
    VEinit_timing();
*/
#endif

   *msg = MSSUCC;

   /* Tell internal functions that VDS VE processing is being done */
   VDve_processing = TRUE;

   /* initialize global variables */

   ve$get_dpb_flags( flags = &ve_vhl_flags );   /* from VEdpb */
   hs$get_vhl_layers( vhl_visible_layer = &VEoutput_data.visible_level,
                      vhl_hidden_layer = &VEoutput_data.hidden_level,
                      vhl_text_layer = &VEoutput_data.text_level );
   hs$get_shading_flags( vhl_flags = &hs_vhl_flags );   /* from HSdpb */

   gr$get_hidden_so_on( buffer = &hidden_line_display );
   // fix for TR# 5511
   if (( !hidden_line_display ) && (!VDve_processing))
      VEoutput_data.hidden_level = NO_HIDDEN_OUTPUT;

   VEoutput_data.output_2d = !( HS_VHL_RESULTS_DIM );
			/* !(hs_vhl_flags & HS_VHL_RESULTS_DIM); */
   VEoutput_data.output_curves = TRUE;  /* ! output_soos; */
   VEoutput_data.output_solid_self_hidden_edges =
      ve_vhl_flags & VE_VHL_OUTPUT_SOLID_SELF_HIDDEN;
   VEoutput_data.copy_text = !( HS_VHL_TEXT_COPY );
				/* hs_vhl_flags & HS_VHL_TEXT_COPY; */
   VEoutput_data.delete_overrides = hs_vhl_flags &
      HS_VHL_DELETE_OVERRIDES;

   /* only write error messages if VE_REPORT_ERRORS environment */
   /* variable is defined to be 1 */
   expansion = getenv( "VE_REPORT_ERRORS" );
   VEreport_errors = ( expansion ) && ( expansion[0] == '1' );

   /* if VE_USE_CLASSIFICATION_ALG is defined to be 1 in the */
   /* environment, use the new classification based algorithm */
   expansion = getenv( "VE_USE_CLASSIFICATION_ALG" );
   VEuse_classification_alg = ( expansion ) && ( expansion[0] == '1' );

   /* if VE_COLOR_CLASSIFICATION is defined to be 1 in the */
   /* environment, output edges in colors that represent their */
   /* classification. */
   expansion = getenv( "VE_COLOR_CLASSIFICATION" );
   VEcolor_classification = ( expansion ) && ( expansion[0] == '1' );

   /* if VE_STROKE_ALL_INTS is defined to be 1 in the environment, */
   /* stroke all curves to linestrings before curve/curve */
   /* intersection */
   expansion = getenv( "VE_STROKE_ALL_INTS" );
   VEstroke_all_ints = ( expansion ) && ( expansion[0] == '1' );

   /* if VE_STROKE_CHT is defined in the environment, use its value as */
   /* the CHT to stroke all curves to linestrings before curve/curve */
   /* intersection */
   VEstroke_cht = 0.0;
   expansion = getenv( "VE_STROKE_CHT" );
   if ( expansion )
      sscanf( expansion, "%lf", &VEstroke_cht );

   /* Initialize batch variable => based on parameter passed in and */
   /* not the system batch flag.  If batch_mode is TRUE, then we are */
   /* processing a file that was created through the batch job */
   /* submission process (i.e., it has the required directory */
   /* structure). */
   VEexec_parms.VEbatch = FALSE;        /* batch_mode; */

   /* get the current module environment */
   bytes_requested = sizeof( struct GRmd_env );
   gr$get_module_env( msg = msg, sizbuf = &bytes_requested,
                      buffer = &VEmaster_env, nret = &bytes_returned );

   /* get the system CHT and the system base tol */
  
   BSxtractpar( &rc, BSTOLBASIS, &VEtolerances.VEsystem_base_tol );
   BSxtractpar( &rc, BSTOLCHRDHT, &sys_cht_value );
   BSchangepar( &rc, BSTOLCHRDHT, VEtolerances.VEsystem_base_tol );
   BSxtractpar( &rc, BSTOLCHRDHT, &VEtolerances.VEsystem_cht );

   VEcommon_id_list = NULL;
   VEexec_status.VEint_save_denied = FALSE;
   VEexec_status.VEabort = FALSE;
   VEexec_status.VEprev_output_found = FALSE;
   VEexec_status.VEupdate_window = FALSE;
   VEexec_status.VEread_only_found = FALSE;
   VEexec_status.VEsymbol_found = FALSE;
   VEexec_status.VEtotal_elems = 0;
   VEexec_status.VEfinished_elems = 0;
   VEexec_status.VEactivated_elems = 0;
   VEexec_status.VEattach_count = 0;
   VEexec_status.VEunique_edge_id = -1;
   VEexec_status.VEnext_saved_cvcv_id = 0;

   VEexec_parms.VEprocessing_wireframe = HS_VHL_PROCESS_WIREFRAME;
			/* hs_vhl_flags & HS_VHL_PROCESS_WIREFRAME; */
   VEexec_parms.VEturn_ref_files_off = !( HS_VHL_REF_DISPLAY_OFF );
   /* (VEoutput_data.output_curves) && */
   /* (hs_vhl_flags & HS_VHL_REF_DISPLAY_OFF); */

   VEexec_parms.VEhiding = HS_VHL_HIDING;
				/* hs_vhl_flags & HS_VHL_HIDING; */
   VEexec_parms.VEtracing = !( VE_VHL_NO_TRACE );
			/* ! (ve_vhl_flags & VE_VHL_NO_TRACE); */
   VEexec_parms.VEcopying = ( !VEexec_parms.VEhiding ) &&
      ( !VEexec_parms.VEtracing );

   /* Always process tangent edges in CVE */
   VEexec_parms.VEprocess_tangent_edges = TRUE;

   for ( i = 0; i < 32; i++ )
   {
      VEwin_info.VEmaster_layers[i] = ~0;  /* hardwire to "all layers on" */
   }

   gr$get_hidden_edge_sym( buffer = &VEoutput_data.hidden_symb );
   gr$get_visible_edge_sym( buffer = &VEoutput_data.visible_symb );

   VEexec_parms.VEdata_reduction = ( ve_vhl_flags &
                                     VE_VHL_DATA_REDUCTION );

   ve$get_reduction_thresholds( surf_threshold = &short_surf_threshold,
                                curve_threshold = &short_curve_threshold );

   VEexec_parms.VEsurf_threshold = short_surf_threshold;
   VEexec_parms.VEcurve_threshold = short_curve_threshold;

   VEexec_parms.VEgapping = !( VE_VHL_GAPPING_LINES );
			/* ve_vhl_flags & VE_VHL_GAPPING_LINES; */

   VEtolerances.VEscaled_base_tol = VEtolerances.VEsystem_base_tol;
   VEtolerances.VEscaled_cht = VEtolerances.VEsystem_cht;
   VEtolerances.VEscaled_trace_tol = 10 * VEtolerances.VEsystem_base_tol ;

   VEenv_list = NULL;

   /* Set dit clip range to max range possible to "disable" clipping */
   /* always. */
   VDdit_clip_range[0] = VDdit_clip_range[1] = VDdit_clip_range[2] = 
	(double) (-VD_MAXINT);
   VDdit_clip_range[3] = VDdit_clip_range[4] = VDdit_clip_range[5] =
	(double) (VD_MAXINT);

   /* Since 3D output is "hard-wired" for this function, set VDact_z */
   /* to a supposed "don't care" value. */
   VDact_z = 0.0;

   /* Setup transformations and determine the world to viewport scale */
   sts_bool = VDve_set_transformations( VDdit_clip_range, VDwld_to_viewport,
                             VDviewport_to_wld, VDrotation, VDwld_to_view,
                             VDact_z );

   /* calculate the middle of the window in Y */
   VEwin_info.VEy_middle = VEwin_info.clip_range[YMIN] + ( 0.5 *
            ( VEwin_info.clip_range[YMAX] - VEwin_info.clip_range[YMIN] ) );

   VEinit_messages(  );  /* initialize messages used by VE */

   VEinit_memory_management(  );  /* initialize the memory used by VE */

   /* Initialize global buffers for VDS use */
   VDve_init_global_buffers( vis_buf, hid_buf );


   /* End of global variable initialization */


   /* collect the located elements and put them in the sort structure */
   VDve_collect_elements( elem_buf );

   /* process the elements */
   if ( VEexec_status.VEtotal_elems != 0 )
   {
      VEdisplay_processing_message(  );
      VEprocess_elements(  );
   }
   else
   {

#ifdef	NOT_NEEDED

      if ( VEexec_status.VEprev_output_found )
      {
         /* the only elements specified were the results of previous */
         /* Visible Edges processing */
         ex$message( buff = error_msg, msgnumb = VE_I_Discard );
      }
      else
      {
         /* No processable elements were located */
         ex$message( buff = error_msg, msgnumb = VE_I_NoneProcessed )
      }
      ex$message( buff = title_msg, msgnumb = VE_I_WarnTitle );
      FI_message_box( FI_CURRENT_SCREEN, -1, -1, title_msg, FI_RED,
                      "swiss742", 36.0, error_msg, FI_BLACK, "swiss742",
                      18.0, FI_LEFT_JUSTIFIED, 40 );
#endif

     UI_status(" No Output Processed ");
   }

   VEfree_memory(  );  /* free the memory used by VE */

   /* restore the system base tol and the system CHT */
   BSchgdeppar( VEtolerances.VEsystem_base_tol, &rc );
   BSchangepar( &rc, BSTOLCHRDHT, VEtolerances.VEsystem_cht );
   BSchangepar( &rc, BSTOLCHRDHT, sys_cht_value );

   /* Restore VE processing state to FALSE for regular processing */
   VDve_processing = FALSE;

   /* Make visible and hidden buffers of newly created objects */
   /* available to caller, who is responsible for freeing the memory. */
   vis_buf = VDvis_buf;
   hid_buf = VDhid_buf;
   VDvis_buf = VDhid_buf = NULL;

#if TIMING
/*
    VEstop_timing();
*/
#endif

   return ( ( VEexec_status.VEtotal_elems != 0 ) ? OM_S_SUCCESS :
            OM_W_WARNING );
}/* VDve_process */

/*--- VDref_elem_ve_process -----------------------------------------------*/

IGRint VDref_elem_ve_process( IGRint * msg,
                                   struct VDve_elem_buf * elem_buf,
                                   struct VDve_elem_buf * vis_buf,
                                   struct VDve_elem_buf * hid_buf,
                                   IGRdouble VDwld_to_viewport[4][4],
                                   IGRdouble VDviewport_to_wld[4][4],
                                   IGRdouble VDrotation[4][4],
                                   IGRdouble VDwld_to_view[4][4] )
/*
NAME
   VDref_elem_ve_process

DESCRIPTION
   Input includes a buffer of any number of curves, representing the edges of
   a VDS "extracted" object & its "operational envelope" (if displayable), as
   well as a single "reference" surface.  This single reference surface
   always appears as the last element in "elem_buf".  NOTE:  The last element
   in "elem_buf" MUST BE A SURFACE.

   Buffers of visible and (optionally) hidden 3D curves are returned,
   except for the reference surface.

   Visible and (optionally) hidden curves are created as a side effect on
   "default" visible and hidden layers, respectively, using "default"
   symbology settings.

PARAMETERS
   msg  -  status indicator
   elem_buf (IN)  -  buffer of 3D geometry elements (specified by object ID &
         environment info) to be processed; the last element is a single
         "reference" surface or solid
   vis_buf (OUT)  -  buffer of visible 3D curves created by this process
   hid_buf (OUT)  -  buffer of hidden 3D curves created by this process; will
         be NULL if "no hidden output" is specified
   VDwld_to_viewport (IN) - equivalent of gragad's world-to-viewport
         transformation matrix
   VDviewport_to_wld (IN) - equivalent of gragad's viewport-to-world
         transformation matrix
   VDrotation (IN) - equivalent of gragad's view rotation matrix
   VDwld_to_view (IN) - equivalent of gragad's viewport-to-view
         transformation matrix

GLOBALS USED
   VEenv_list
   VEcommon_id_list
   VEmaster_env
   VEoutput_data
   VEexec_parms
   VEexec_status
   VEexec_status.VEtotal_elems
   VEexec_status.VEprev_output_found
   VEexec_status.VEupdate_window
   VEwin_info
   VEtolerances
   VEtolerances.system_base_tol
   VEtolerances.system_cht
   VEreport_errors
   VEuse_classification_alg
   VEcolor_classification
   VDvisbuf, VDhidbuf
   VDve_processing
   VDS_REF_ELEM_PROCESSING

HISTORY
   3/16/95  dh  Creation Date
*/
{
   IGRlong rc;
   IGRint i, bytes_requested, bytes_returned;
   IGRchar *expansion;
   IGRuint hs_vhl_flags, ve_vhl_flags;
   IGRboolean hidden_line_display;
   IGRshort short_surf_threshold, short_curve_threshold;
   IGRchar error_msg[150];
   IGRchar title_msg[15];
   IGRboolean sts_bool=0;

   /* equivalent of gragad's dit clip range in screen units relative */
   /* to the window origin; could be made a parameter of this function */
   /* if so desired */
   IGRdouble VDdit_clip_range[6];
   IGRdouble	sys_cht_value ;

   /* equivalent of gragad's active z in the viewing coordinate */
   /* system; could be made a parameter of this function if desired */
   IGRdouble VDact_z;

#if TIMING
/*
    VEinit_timing();
*/
#endif

   *msg = MSSUCC;

   /* Tell internal functions that VDS VE processing is being done */
   VDve_processing = TRUE;

   /* initialize global variables */

   ve$get_dpb_flags( flags = &ve_vhl_flags );   /* from VEdpb */
   hs$get_vhl_layers( vhl_visible_layer = &VEoutput_data.visible_level,
                      vhl_hidden_layer = &VEoutput_data.hidden_level,
                      vhl_text_layer = &VEoutput_data.text_level );
   hs$get_shading_flags( vhl_flags = &hs_vhl_flags );   /* from HSdpb */

   gr$get_hidden_so_on( buffer = &hidden_line_display );

   // fix for TR# 5511
   if (( !hidden_line_display ) && (!VDve_processing))
      VEoutput_data.hidden_level = NO_HIDDEN_OUTPUT;

   VEoutput_data.output_2d = !( HS_VHL_RESULTS_DIM );
			/* !(hs_vhl_flags & HS_VHL_RESULTS_DIM); */
   VEoutput_data.output_curves = TRUE;  /* ! output_soos; */
   VEoutput_data.output_solid_self_hidden_edges =
      ve_vhl_flags & VE_VHL_OUTPUT_SOLID_SELF_HIDDEN;
   VEoutput_data.copy_text = !( HS_VHL_TEXT_COPY );
				/* hs_vhl_flags & HS_VHL_TEXT_COPY; */
   VEoutput_data.delete_overrides = hs_vhl_flags &
      HS_VHL_DELETE_OVERRIDES;

   /* only write error messages if VE_REPORT_ERRORS environment */
   /* variable is defined to be 1 */
   expansion = getenv( "VE_REPORT_ERRORS" );
   VEreport_errors = ( expansion ) && ( expansion[0] == '1' );

   /* if VE_USE_CLASSIFICATION_ALG is defined to be 1 in the */
   /* environment, use the new classification based algorithm */
   expansion = getenv( "VE_USE_CLASSIFICATION_ALG" );
   VEuse_classification_alg = ( expansion ) && ( expansion[0] == '1' );

   /* if VE_COLOR_CLASSIFICATION is defined to be 1 in the */
   /* environment, output edges in colors that represent their */
   /* classification. */
   expansion = getenv( "VE_COLOR_CLASSIFICATION" );
   VEcolor_classification = ( expansion ) && ( expansion[0] == '1' );

   /* if VE_STROKE_ALL_INTS is defined to be 1 in the environment, */
   /* stroke all curves to linestrings before curve/curve */
   /* intersection */
   expansion = getenv( "VE_STROKE_ALL_INTS" );
   VEstroke_all_ints = ( expansion ) && ( expansion[0] == '1' );

   /* if VE_STROKE_CHT is defined in the environment, use its value as */
   /* the CHT to stroke all curves to linestrings before curve/curve */
   /* intersection */
   VEstroke_cht = 0.0;
   expansion = getenv( "VE_STROKE_CHT" );
   if ( expansion )
      sscanf( expansion, "%lf", &VEstroke_cht );

   /* Initialize batch variable => based on parameter passed in and */
   /* not the system batch flag.  If batch_mode is TRUE, then we are */
   /* processing a file that was created through the batch job */
   /* submission process (i.e., it has the required directory */
   /* structure). */
   VEexec_parms.VEbatch = FALSE;        /* batch_mode; */

   /* get the current module environment */
   bytes_requested = sizeof( struct GRmd_env );
   gr$get_module_env( msg = msg, sizbuf = &bytes_requested,
                      buffer = &VEmaster_env, nret = &bytes_returned );

   /* get the system CHT and the system base tol */
   BSxtractpar( &rc, BSTOLBASIS, &VEtolerances.VEsystem_base_tol );
   BSxtractpar( &rc, BSTOLCHRDHT, &sys_cht_value );
   BSchangepar( &rc, BSTOLCHRDHT, VEtolerances.VEsystem_base_tol );
   BSxtractpar( &rc, BSTOLCHRDHT, &VEtolerances.VEsystem_cht );

   VEcommon_id_list = NULL;
   VEexec_status.VEint_save_denied = FALSE;
   VEexec_status.VEabort = FALSE;
   VEexec_status.VEprev_output_found = FALSE;
   VEexec_status.VEupdate_window = FALSE;
   VEexec_status.VEread_only_found = FALSE;
   VEexec_status.VEsymbol_found = FALSE;
   VEexec_status.VEtotal_elems = 0;
   VEexec_status.VEfinished_elems = 0;
   VEexec_status.VEactivated_elems = 0;
   VEexec_status.VEattach_count = 0;
   VEexec_status.VEunique_edge_id = -1;
   VEexec_status.VEnext_saved_cvcv_id = 0;

   VEexec_parms.VEprocessing_wireframe = HS_VHL_PROCESS_WIREFRAME;
			/* hs_vhl_flags & HS_VHL_PROCESS_WIREFRAME; */
   VEexec_parms.VEturn_ref_files_off = !( HS_VHL_REF_DISPLAY_OFF );
   /* (VEoutput_data.output_curves) && */
   /* (hs_vhl_flags & HS_VHL_REF_DISPLAY_OFF); */

   VEexec_parms.VEhiding = HS_VHL_HIDING;
				/* hs_vhl_flags & HS_VHL_HIDING; */
   VEexec_parms.VEtracing = ( VE_VHL_NO_TRACE );
			/* ! (ve_vhl_flags & VE_VHL_NO_TRACE); */
   VEexec_parms.VEcopying = ( !VEexec_parms.VEhiding ) &&
      ( !VEexec_parms.VEtracing );

   /* Always process tangent edges in CVE */
   VEexec_parms.VEprocess_tangent_edges = TRUE;

   for ( i = 0; i < 32; i++ )
   {
      VEwin_info.VEmaster_layers[i] = ~0;  /* hardwire to "all layers on" */
   }

   gr$get_hidden_edge_sym( buffer = &VEoutput_data.hidden_symb );
   gr$get_visible_edge_sym( buffer = &VEoutput_data.visible_symb );

   VEexec_parms.VEdata_reduction = ( ve_vhl_flags &
                                     VE_VHL_DATA_REDUCTION );

   ve$get_reduction_thresholds( surf_threshold = &short_surf_threshold,
                                curve_threshold = &short_curve_threshold );

   VEexec_parms.VEsurf_threshold = short_surf_threshold;
   VEexec_parms.VEcurve_threshold = short_curve_threshold;

   VEexec_parms.VEgapping = !( VE_VHL_GAPPING_LINES );
			/* ve_vhl_flags & VE_VHL_GAPPING_LINES; */

   VEtolerances.VEscaled_base_tol = VEtolerances.VEsystem_base_tol;
   VEtolerances.VEscaled_cht = VEtolerances.VEsystem_cht;
   VEtolerances.VEscaled_trace_tol = 10 * VEtolerances.VEsystem_base_tol  ;

   VEenv_list = NULL;

   /* Set dit clip range to max range possible to "disable" clipping */
   /* always. */
   VDdit_clip_range[0] = VDdit_clip_range[1] = VDdit_clip_range[2] = 
	(double) (-VD_MAXINT);
   VDdit_clip_range[3] = VDdit_clip_range[4] = VDdit_clip_range[5] =
	(double) (VD_MAXINT);


   /* Since 3D output is "hard-wired" for this function, set VDact_z */
   /* to a supposed "don't care" value. */
   VDact_z = 0.0;

   /* Setup transformations and determine the world to viewport scale */
   sts_bool = VDve_set_transformations( VDdit_clip_range, VDwld_to_viewport,
                             VDviewport_to_wld, VDrotation, VDwld_to_view,
                             VDact_z );

   /* calculate the middle of the window in Y */
   VEwin_info.VEy_middle = VEwin_info.clip_range[YMIN] + ( 0.5 *
            ( VEwin_info.clip_range[YMAX] - VEwin_info.clip_range[YMIN] ) );

   VEinit_messages(  );  /* initialize messages used by VE */

   VEinit_memory_management(  );  /* initialize the memory used by VE */

   /* Initialize global buffers for VDS use */
   VDve_init_global_buffers( vis_buf, hid_buf );


   /* Tell internal functions that special VDS-specific reference element */
   /* processing is in effect. */
   VDS_REF_ELEM_PROCESSING = TRUE;

   /* End of global variable initialization */


   /* collect the located elements and put them in the sort structure */
   VDve_collect_elements( elem_buf );

   /* process the elements */
   if ( VEexec_status.VEtotal_elems != 0 )
   {
      VEdisplay_processing_message(  );
      VEprocess_elements(  );
   }
   else
   {

#ifdef	NOT_NEEDED

      if ( VEexec_status.VEprev_output_found )
      {
         /* the only elements specified were the results of previous */
         /* Visible Edges processing */
         ex$message( buff = error_msg, msgnumb = VE_I_Discard );
      }
      else
      {
         /* No processable elements were located */
         ex$message( buff = error_msg, msgnumb = VE_I_NoneProcessed )
      }
      ex$message( buff = title_msg, msgnumb = VE_I_WarnTitle );
      FI_message_box( FI_CURRENT_SCREEN, -1, -1, title_msg, FI_RED,
                      "swiss742", 36.0, error_msg, FI_BLACK, "swiss742",
                      18.0, FI_LEFT_JUSTIFIED, 40 );
#endif

     UI_status(" No Output Processed ");
   }

   VEfree_memory(  );  /* free the memory used by VE */

   /* restore the system base tol and the system CHT */
   BSchgdeppar( VEtolerances.VEsystem_base_tol, &rc );
   BSchangepar( &rc, BSTOLCHRDHT, VEtolerances.VEsystem_cht );

   BSchangepar( &rc, BSTOLCHRDHT, sys_cht_value );

   /* Tell internal functions that special VDS-specific reference element */
   /* processing is now "off". */
   VDS_REF_ELEM_PROCESSING = FALSE;

   /* Restore VE processing state to FALSE for regular processing */
   VDve_processing = FALSE;

   /* Make visible and hidden buffers of newly created objects */
   /* available to caller, who is responsible for freeing the memory. */
   vis_buf = VDvis_buf;
   hid_buf = VDhid_buf;
   VDvis_buf = VDhid_buf = NULL;

#if TIMING
/*
    VEstop_timing();
*/
#endif

   return ( ( VEexec_status.VEtotal_elems != 0 ) ? OM_S_SUCCESS :
            OM_W_WARNING );
}/* VDref_elem_ve_process */

end implementation Root;
