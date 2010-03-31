
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $

HISTORY

        Sudha   07/28/93        Modified for BSprototype ansification
*/

class implementation VEgragad;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bsparameters.h"
#include "bstypes.h"
#include "bsxtractpar.h"

#include "msdef.h"

#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "veerr.h"
#include "vemsg.h"
#include "vedpbmacros.h"

#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
#include "VEpr_dpb.h"

/* External Global Variables */
extern struct VEenv_info         *VEenv_list;
extern struct VEid_list          *VEcommon_id_list;
extern struct GRmd_env           VEmaster_env;
extern struct VEresults_info     VEoutput_data;
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEwindow_info      VEwin_info;
extern struct VEtolerance_info   VEtolerances;
extern IGRboolean                VEreport_errors;
extern IGRboolean                VEuse_classification_alg;
extern IGRboolean                VEcolor_classification;
extern IGRboolean                VEstroke_all_ints;
extern IGRdouble                 VEstroke_cht;

method VEinit_globals( IGRint *msg; IGRboolean batch_mode; IGRboolean output_soos )

/*
NAME
	VEgragad.VEinit_globals

DESCRIPTION
	Method to initialize VE global data based on instance data

PARAMETERS
	msg (OUT) - status return
	batch_mode (IN) - TRUE, if running a batch job
	output_soos (IN) - TRUE, if symbology overrides are to be output

GLOBALS USED
	VEenv_list
	VEcommon_id_list
	VEmaster_env
	VEoutput_data
	VEexec_parms
	VEexec_status
	VEwin_info
	VEtolerances
	VEreport_errors
	VEuse_classification_alg
	VEcolor_classification

HISTORY
	01/16/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong         rc;
	IGRint          bytes_requested;
	IGRint          bytes_returned;
	IGRchar         *expansion;
	IGRuint         hs_vhl_flags;
	IGRuint         ve_vhl_flags;
	IGRboolean      hidden_line_display;
	IGRshort        short_surf_threshold, short_curve_threshold;

	*msg = MSSUCC;

	ve$get_dpb_flags( flags = &ve_vhl_flags );

	hs$get_vhl_layers( vhl_visible_layer = &VEoutput_data.visible_level,
	                   vhl_hidden_layer = &VEoutput_data.hidden_level,
	                   vhl_text_layer = &VEoutput_data.text_level );

	hs$get_shading_flags( vhl_flags = &hs_vhl_flags );

	gr$get_hidden_so_on( buffer = &hidden_line_display );
	if ( ! hidden_line_display )
	   VEoutput_data.hidden_level = NO_HIDDEN_OUTPUT;

	VEoutput_data.output_2d = !(hs_vhl_flags & HS_VHL_RESULTS_DIM);
	VEoutput_data.output_curves = ! output_soos;
	VEoutput_data.output_solid_self_hidden_edges = ve_vhl_flags & VE_VHL_OUTPUT_SOLID_SELF_HIDDEN;
	VEoutput_data.copy_text = hs_vhl_flags & HS_VHL_TEXT_COPY;
	VEoutput_data.delete_overrides = hs_vhl_flags & HS_VHL_DELETE_OVERRIDES;

	VEwin_info.VEwin_grid.objid = my_id;
	VEwin_info.VEwin_grid.osnum = OM_Gw_current_OS;

	if ( output_soos )
	   VEsetup_soo_view( my_id, VEwin_info.VEwin_grid.osnum );

	/* only write error messages if VE_REPORT_ERRORS */
	/* environment variable is defined to be 1      */
	expansion = getenv( "VE_REPORT_ERRORS" );
	VEreport_errors = (expansion) && (expansion[0] == '1');

	/* if VE_USE_CLASSIFICATION_ALG is defined to be 1 in the  */
	/* environment, use the new classification based algorithm */
	expansion = getenv( "VE_USE_CLASSIFICATION_ALG" );
	VEuse_classification_alg = (expansion) && (expansion[0] == '1');

	/* if VE_COLOR_CLASSIFICATION is defined to be 1 in the */
	/* environment, output edges in colors that represent   */
	/* their classification.                                */
	expansion = getenv( "VE_COLOR_CLASSIFICATION" );
	VEcolor_classification = (expansion) && (expansion[0] == '1');

	/* if VE_STROKE_ALL_INTS is defined to be 1 in the */
	/* environment, stroke all curves to linestrings   */
	/* before curve/curve intersection                 */
	expansion = getenv( "VE_STROKE_ALL_INTS" );
	VEstroke_all_ints = (expansion) && (expansion[0] == '1');

	/* if VE_STROKE_CHT is defined in the environment,  */
	/* use its value as the CHT to stroke all curves to */
        /* linestrings before curve/curve intersection      */
	VEstroke_cht = 0.0;
	expansion = getenv( "VE_STROKE_CHT" );
	if ( expansion )
	   sscanf( expansion, "%lf", &VEstroke_cht );

	/* Initialize batch variable => based on parameter passed in   */
	/* and not the system batch flag.  If batch_mode is TRUE, then */
	/* we are processing a file that was created through the batch */
	/* job submission process (i.e., it has the required directory */
	/* structure.                                                  */
	VEexec_parms.VEbatch = batch_mode;

	/* get the current module environment */
	bytes_requested = sizeof( struct GRmd_env );
	gr$get_module_env( msg    = msg,
	                   sizbuf = &bytes_requested,
	                   buffer = &VEmaster_env,
	                   nret   = &bytes_returned );

	/* get the system CHT */
	BSxtractpar( &rc, BSTOLCHRDHT, &VEtolerances.VEsystem_cht );

	/* get the system base tol */
	BSxtractpar( &rc, BSTOLBASIS, &VEtolerances.VEsystem_base_tol );
	
	VEcommon_id_list                   = NULL;
	VEexec_status.VEint_save_denied    = FALSE;
	VEexec_status.VEabort              = FALSE;
	VEexec_status.VEprev_output_found  = FALSE;
	VEexec_status.VEupdate_window      = FALSE;
	VEexec_status.VEread_only_found    = FALSE;
	VEexec_status.VEsymbol_found       = FALSE;
	VEexec_status.VEtotal_elems        = 0;
	VEexec_status.VEfinished_elems     = 0;
	VEexec_status.VEactivated_elems    = 0;
	VEexec_status.VEattach_count       = 0;
	VEexec_status.VEunique_edge_id     = -1;
	VEexec_status.VEnext_saved_cvcv_id = 0;

	VEexec_parms.VEprocessing_wireframe = hs_vhl_flags & HS_VHL_PROCESS_WIREFRAME;
	VEexec_parms.VEturn_ref_files_off = (VEoutput_data.output_curves) &&
	                                    (hs_vhl_flags & HS_VHL_REF_DISPLAY_OFF);

	VEexec_parms.VEhiding  = hs_vhl_flags & HS_VHL_HIDING;
	VEexec_parms.VEtracing = ! (ve_vhl_flags & VE_VHL_NO_TRACE);
	VEexec_parms.VEcopying = (! VEexec_parms.VEhiding) && (! VEexec_parms.VEtracing);

	if ( VEoutput_data.output_curves )
	   VEexec_parms.VEprocess_tangent_edges = TRUE;  /* always process tangent edges in CVE */
	else
	   VEexec_parms.VEprocess_tangent_edges = !(hs_vhl_flags & HS_VHL_DONT_PROCESS_TANGENT);

	memcpy( VEwin_info.VEmaster_layers, me->gragad.levels, sizeof( IGRint ) * 32 );

	gr$get_hidden_edge_sym( buffer = &VEoutput_data.hidden_symb );
	gr$get_visible_edge_sym( buffer = &VEoutput_data.visible_symb );

        VEexec_parms.VEdata_reduction = (ve_vhl_flags & VE_VHL_DATA_REDUCTION);

	ve$get_reduction_thresholds( surf_threshold = &short_surf_threshold,
	                             curve_threshold = &short_curve_threshold );

	VEexec_parms.VEsurf_threshold = short_surf_threshold;
	VEexec_parms.VEcurve_threshold = short_curve_threshold;

	VEexec_parms.VEgapping = ve_vhl_flags & VE_VHL_GAPPING_LINES;
	ve$get_gapping_distance( gapping_distance = &VEexec_parms.VEgapping_distance );

	VEtolerances.VEscaled_base_tol  = VEtolerances.VEsystem_base_tol;
	VEtolerances.VEscaled_cht       = VEtolerances.VEsystem_cht;
	ve$get_trace_tol( trace_tol = &VEtolerances.VEscaled_trace_tol );

	VEenv_list = NULL;

        /* Setup transformations and determine the world to viewport scale */
	VEset_transformations( (struct DPgra_gad *)ME.IGEgragad );

	if ( hs_vhl_flags & HS_VHL_CLIP_TO_FENCE )
	   VEprocess_fence( my_id );

	/* calculate the middle of the window in Y */
	VEwin_info.VEy_middle = VEwin_info.clip_range[YMIN] +
	                   ((VEwin_info.clip_range[YMAX] - VEwin_info.clip_range[YMIN]) * 0.5);

	/* initialize messages used by VE */
	VEinit_messages();

	/* initialize the memory used by VE */
	VEinit_memory_management();

	return( OM_S_SUCCESS );
	}

end implementation VEgragad;
