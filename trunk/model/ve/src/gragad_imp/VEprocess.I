
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
#include <string.h>

#include <FI.h>

#include "igetypedef.h"
#include "igrtypedef.h"

#include "OMmacros.h"

#include "bsparameters.h"
#include "bstypes.h"
#include "bschgdeppar.h"
#include "bschangepar.h"

#include "msdef.h"
#include "msmacros.h"

#include "dpstruct.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "ve_timing.h"
#include "veerr.h"
#include "vemsg.h"
#include "VEsodef.h"
#include "VEsomacros.h"

/* prototype files */
#include "VEpr_driver.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"


extern struct GRmd_env VEmaster_env;

#if TIMING
static struct tms  start_time;
static struct tms  end_time;

extern IGRint      VEnum_proj_points;
extern struct tms  VEs_time;
extern struct tms  VEe_time;
extern IGRdouble   VEtime_part;
extern IGRdouble   VEtime_cvcv;
extern IGRdouble   VEtime_cvslf;
extern IGRdouble   VEtime_ptproj;
extern IGRdouble   VEtime_ptloc;
extern IGRdouble   VEtime_trim;
extern IGRdouble   VEtime_datred;
extern IGRdouble   VEtime_water;
extern IGRdouble   VEtime_cvred;
extern IGRdouble   VEtime_multrim;
extern IGRdouble   VEtime_2sfpart;
extern IGRdouble   VEtime_shprtcl;
extern IGRdouble   VEtime_csprtcl;
extern IGRdouble   VEtime_partcsp;
extern IGRdouble   VEtime_smprtcl;
extern IGRint      VEcount_part;
extern IGRint      VEcount_cvcv;
extern IGRint      VEcount_cvslf;
extern IGRint      VEcount_ptproj;
extern IGRint      VEcount_ptloc;
extern IGRint      VEcount_trim;
extern IGRint      VEcount_datred;
extern IGRint      VEcount_water;
extern IGRint      VEcount_cvred;
extern IGRint      VEcount_multrim;
extern IGRint      VEcount_2sfpart;
extern IGRint      VEcount_shprtcl;
extern IGRint      VEcount_csprtcl;
extern IGRint      VEcount_partcsp;
extern IGRint      VEcount_smprtcl;

/*--- VEinit_timing -------------------------------------------------------------*/

static void VEinit_timing(
    void )

/*
NAME
	VEinit_timing (static)

KEYWORD
	debug

DESCRIPTION
	This function starts the timing functions of VE

PARAMETERS
	none

GLOBALS USED
	start_time, end_time (static)
	VEs_time, VEe_time
	VEnum_proj_points
	VEtime_part, VEtime_cvcv, VEtime_cvslf, VEtime_ptproj,
	VEtime_ptloc, VEtime_trim, VEtime_datred, VEtime_water,
	VEtime_cvred, VEtime_multrim, VEtime_2sfpart, VEtime_shprtcl,
	VEtime_csprtcl, VEtime_partcsp, VEtime_smprtcl
	VEcount_part, VEcount_cvcv, VEcount_cvslf, VEcount_ptproj,
	VEcount_ptloc, VEcount_trim, VEcount_datred, VEcount_water,
	VEcount_cvred, VEcount_multrim, VEcount_2sfpart, VEcount_shprtcl,
	VEcount_csprtcl, VEcount_partcsp, VEcount_smprtcl

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	VEnum_proj_points = 0;

	VEtime_part = VEtime_cvcv = VEtime_cvslf = VEtime_water = 
	VEtime_ptproj = VEtime_ptloc = VEtime_trim = VEtime_datred = 
        VEtime_cvred = VEtime_multrim = VEtime_2sfpart = VEtime_shprtcl =
	VEtime_csprtcl = VEtime_partcsp = VEtime_smprtcl = 0.0;

	VEcount_part = VEcount_cvcv = VEcount_cvslf = VEcount_water = 
	VEcount_ptproj = VEcount_ptloc = VEcount_trim = VEcount_datred = 
        VEcount_cvred = VEcount_multrim = VEcount_2sfpart = VEcount_shprtcl =
	VEcount_csprtcl = VEcount_partcsp = VEtime_smprtcl = 0;

	times( &start_time );
	}  /* VEinit_timing */


/*--- VEstop_timing -------------------------------------------------------------*/

static void VEstop_timing(
   void )

NAME
	VEstop_timing (static)

KEYWORD
	debug

DESCRIPTION
	This function stops the timing functions of VE and prints the results
	to standard error.

PARAMETERS
	none

GLOBALS USED
	start_time, end_time (static)
	VEs_time, VEe_time
	VEnum_proj_points
	VEtime_part, VEtime_cvcv, VEtime_cvslf, VEtime_ptproj,
	VEtime_ptloc, VEtime_trim, VEtime_datred, VEtime_water,
	VEtime_cvred, VEtime_multrim, VEtime_2sfpart, VEtime_shprtcl,
	VEtime_csprtcl, VEtime_partcsp, VEtime_smprtcl
	VEcount_part, VEcount_cvcv, VEcount_cvslf, VEcount_ptproj,
	VEcount_ptloc, VEcount_trim, VEcount_datred, VEcount_water,
	VEcount_cvred, VEcount_multrim, VEcount_2sfpart, VEcount_shprtcl,
	VEcount_csprtcl, VEcount_partcsp, VEcount_smprtcl

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRdouble total_time;

	times( &end_time );
	total_time = ((end_time.tms_stime + end_time.tms_utime) -
                      (start_time.tms_stime + start_time.tms_utime)) / 60.0;

	fprintf( stderr, "\nTotal time = %lf seconds\n", total_time );

	fprintf( stderr, "\n" );
	fprintf( stderr, "                           CALLS    CPU TIME  TIME/CALL  PERCENT\n" );
	fprintf( stderr, "                          -------   --------- ---------  -------\n" );
	fprintf( stderr, "   Parting Lines:        %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_part, VEtime_part,
	         (VEcount_part == 0) ? 0.0 : (VEtime_part / (float) VEcount_part),
	         (VEtime_part / total_time) * 100.0 );

	fprintf( stderr, "   Curve/Curve Int:      %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_cvcv, VEtime_cvcv,
	         (VEcount_cvcv == 0) ? 0.0 : (VEtime_cvcv / (float) VEcount_cvcv),
	         (VEtime_cvcv / total_time) * 100.0 );

	fprintf( stderr, "   Curve-Self Int:       %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_cvslf, VEtime_cvslf,
	         (VEcount_cvslf == 0) ? 0.0 : (VEtime_cvslf / (float) VEcount_cvslf),
	         (VEtime_cvslf / total_time) * 100.0 );
 
	fprintf( stderr, "   Waterfall Alg:        %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_water, VEtime_water,
	         (VEcount_water == 0) ? 0.0 : (VEtime_water / (float) VEcount_water),
	         (VEtime_water / total_time) * 100.0 );

	fprintf( stderr, "   Point Projection:     %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_ptproj, VEtime_ptproj,
	         (VEcount_ptproj == 0) ? 0.0 : (VEtime_ptproj / (float) VEcount_ptproj),
	         (VEtime_ptproj / total_time) * 100.0 );

	fprintf( stderr, "   Trimming:             %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_trim, VEtime_trim,
	         (VEcount_trim == 0) ? 0.0 : (VEtime_trim / (float) VEcount_trim),
	         (VEtime_trim / total_time) * 100.0 );

	fprintf( stderr, "   Point Location:       %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_ptloc, VEtime_ptloc,
	         (VEcount_ptloc == 0) ? 0.0 : (VEtime_ptloc / (float) VEcount_ptloc),
	         (VEtime_ptloc / total_time) * 100.0 );

	fprintf( stderr, "   Data Reduction:       %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_datred, VEtime_datred,
	         (VEcount_datred == 0) ? 0.0 : (VEtime_datred / (float) VEcount_datred),
	         (VEtime_datred / total_time) * 100.0 );

	fprintf( stderr, "   Curve Reduction:      %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_cvred, VEtime_cvred,
	         (VEcount_cvred == 0) ? 0.0 : (VEtime_cvred / (float) VEcount_cvred),
	         (VEtime_cvred / total_time) * 100.0 );

	fprintf( stderr, "   Multiple Trimming:    %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_multrim, VEtime_multrim, 
	         (VEcount_multrim == 0) ? 0.0 : (VEtime_multrim / (float) VEcount_multrim),
	         (VEtime_multrim / total_time) * 100.0 );

	fprintf( stderr, "   Shared Edge Parting:  %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_2sfpart, VEtime_2sfpart, 
	         (VEcount_2sfpart == 0) ? 0.0 : (VEtime_2sfpart / (float) VEcount_2sfpart),
	         (VEtime_2sfpart / total_time) * 100.0 );

	fprintf( stderr, "   Shared Edge Classify: %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_shprtcl, VEtime_shprtcl, 
	         (VEcount_shprtcl == 0) ? 0.0 : (VEtime_shprtcl / (float) VEcount_shprtcl),
	         (VEtime_shprtcl / total_time) * 100.0 );

	fprintf( stderr, "   Cusp Parting Line:    %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_partcsp, VEtime_partcsp, 
	         (VEcount_partcsp == 0) ? 0.0 : (VEtime_partcsp / (float) VEcount_partcsp),
	         (VEtime_partcsp / total_time) * 100.0 );

	fprintf( stderr, "   Cusp Part Classify:   %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_csprtcl, VEtime_csprtcl, 
	         (VEcount_csprtcl == 0) ? 0.0 : (VEtime_csprtcl / (float) VEcount_csprtcl),
	         (VEtime_csprtcl / total_time) * 100.0 );

	fprintf( stderr, "   Smooth Part Classify: %7d  %9.2lf  %9.4lf  %7.2lf\n",
	         VEcount_smprtcl, VEtime_smprtcl, 
	         (VEcount_smprtcl == 0) ? 0.0 : (VEtime_smprtcl / (float) VEcount_smprtcl),
	         (VEtime_smprtcl / total_time) * 100.0 );

	fprintf( stderr, "\n      Total Number of Projection Points: %d\n", VEnum_proj_points );

	}  /* VEstop_timing */

#endif

extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEtolerance_info   VEtolerances;
extern struct VEenv_info         *VEenv_list;


method VEprocess( IGRint          *msg;
	          struct GRid     *co_grid;
	          OM_S_CHANSELECT *gschansel;
	          IGRboolean      batch_mode;
	          IGRboolean      output_soos )

/*
NAME
	VEgragad.VEprocess

DESCRIPTION
	This is the driving method for the Visible Edges process.  It requires
	that the objects to be processed be located with the gs$locate() macro.

PARAMETERS
	msg - status indicator
	co_grid - GRid of command object who sent this message
	gschansel - channel selector of the graphic set locate channel of the
	            command object who sent this message
	batch_mode - flag indicating whether we are running batch mode VE
	output_soos - flag indicating whether SOs/curves should be output

GLOBALS USED
	VEexec_status.VEtotal_elems
	VEexec_status.VEprev_output_found
	VEexec_parms.VEbatch
	VEexec_status.VEupdate_window
	VEtolerances.system_base_tol
	VEtolerances.system_cht
	VEenv_list

HISTORY
	xx/xx/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong           rc;
	IGRlong           sts;
	IGRlong           msg2;
	GRspacenum        osnum;
	IGRchar           error_msg[150];
	IGRchar           title_msg[15];
	struct GRid       my_GRid;
	struct VEenv_info *env, *search_env;
	IGRint            curve_count, surf_count;
	OM_S_OBJID        so_objid;
	IGRboolean        master_env_processed;

#if TIMING
	VEinit_timing();
#endif

	*msg = MSSUCC;

	/* initialize global variables */
	sts = om$send( msg      = message VEgragad.VEinit_globals( msg, batch_mode, output_soos ),
	               targetid = my_id );

	if ( VEexec_parms.VEbatch )
	   VEinit_batch_logging( me->job_info[0].unique_name );

	/* collect the located elements and put them in the sort structure */
	VEcollect_elements( co_grid, gschansel, NULL, FALSE );

	if ( output_soos )
	   {
	   /* create a soo object for each object space (i.e., ref. file) */
	   master_env_processed = FALSE;
	   env = VEenv_list;
	   while ( env )
	      {
	      if ( !(env->flags & VE_ENV_PROCESSED) )
	         {
	         /* this environment hasn't been processed yet => process all environments */
	         /* with the same object space number                                      */
	         curve_count = env->num_curves;
	         surf_count = env->num_surfs;
	         search_env = env->next;
	         env->flags |= VE_ENV_PROCESSED;
	         while ( search_env )
	            {
	            if ( search_env->osnum == env->osnum )
	               {
	               curve_count += search_env->num_curves;
	               surf_count += search_env->num_surfs;
	               search_env->flags |= VE_ENV_PROCESSED;
	               }

	            search_env = search_env->next;
	            }  /* end: while */

	         ve$create_soo( msg          = &msg2,
	                        osnum        = env->osnum, 
	                        num_surfaces = surf_count,
	                        num_curves   = curve_count,
	                        resolution   = VESO_HIGH_RES,
	                        p_objid      = &so_objid );

	         if ( env->osnum == VEmaster_env.md_id.osnum )
	            {
	            master_env_processed = TRUE;
	            }

	         }  /* end: if ( !( env->flags & VE_ENV_PROCESSED) ) */

	      env = env->next;
	      }  /* end: while */

	   if ( ! master_env_processed )
	      {
	         /* create DEso object for master file, too. because */
	         /* horizon curves are always in the master file     */
	         ve$create_soo( msg          = &msg2,
	                        osnum        = VEmaster_env.md_id.osnum, 
	                        num_surfaces = 0,
	                        num_curves   = 100, /* ?? What do I put here ?? */
	                        resolution   = VESO_HIGH_RES,
	                        p_objid      = &so_objid );

	      }

	   }  /* end: if ( output_soos ) */

	/* process the elements */
	if ( VEexec_status.VEtotal_elems != 0 )
	   {
	   VEdisplay_processing_message();
	   VEprocess_elements();
	   }
	else
	   {
	   if ( VEexec_status.VEprev_output_found )
	      {
	      /* the only elements specified were the results of */
	      /* previous Visible Edges processing               */
	      ex$message( buff = error_msg, msgnumb = VE_I_Discard );
	      }
	   else
	      {
	      /* No processable elements were located */
	      ex$message( buff = error_msg, msgnumb = VE_I_NoneProcessed );
              }

	   if ( VEexec_parms.VEbatch )
              {
	      ex$message( buff = title_msg, msgnumb = VE_I_Err );
	      fprintf( stderr, "%s: %s\n", title_msg, error_msg );
              }
	   else
	      {
              ex$message( buff = title_msg, msgnumb = VE_I_WarnTitle );
              FI_message_box( FI_CURRENT_SCREEN, -1, -1,
                              title_msg, FI_RED, "swiss742", 36.0,
                              error_msg, FI_BLACK, "swiss742", 18.0,
                              FI_LEFT_JUSTIFIED, 40 );
	      }

	   }

	/* free the memory used by VE */
	VEfree_memory();

	if ( VEexec_status.VEupdate_window )
	   {
	   sts = om$send( mode     = OM_e_wrt_object,
	                  msg      = message IGEgragad.DPupdate( &msg2, NULL, FALSE ),
	                  targetid = my_id );

	      OM_ERRCHK( sts, "VEprocess: DPupdate send failed" );
	      MSG_ERRCHK( msg2, "VEprocess: DPupdate failed" );
	   }

	/* restore the system base tol */
	BSchgdeppar( VEtolerances.VEsystem_base_tol, &rc );

	/* restore the system CHT */
	BSchangepar( &rc, BSTOLCHRDHT, VEtolerances.VEsystem_cht );

	if ( VEexec_parms.VEbatch )
	   {
	   /* turn on all of the layers */
	   memset( me->gragad.levels, 0xFF, sizeof( IGRint ) * 32 );

	   /* create a saved view for this window that can be used */
	   /* to attach the results file back to the original file */
	   my_GRid.objid = my_id;
	   my_GRid.osnum = OM_Gw_current_OS;
	   osnum = OM_Gw_current_OS;
	   dp$savvw_cons( msg = msg, osnum = &osnum, vw_name = "EdgesResults", gg_id = &my_GRid );

	      MSG_ERRCHK( *msg, "VEprocess:  dp$savvw_cons failed" );
	   
	   VEturn_windows_off( my_id );
	   VEturn_all_ref_planes_off();

	   VEstop_batch_logging();

	   /* clear the batch info for this window */
	   me->num_batch_jobs = 0;
	   om$vla_set_dimension( varray = me->job_info, size = 0 );

	   }  /* end: if ( VEexec_parms.VEbatch ) */

#if TIMING
	VEstop_timing();
#endif

	return( (VEexec_status.VEtotal_elems != 0) ? OM_S_SUCCESS : OM_W_WARNING );
	}

end implementation  VEgragad;
