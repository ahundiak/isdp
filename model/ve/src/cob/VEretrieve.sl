
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:41:59 $
$Locker:  $
*/


class		VEretrieve
super_class	VEedgescmds
command_string	VEM_M_ReEdReSe,3,VERtEdRsFS
product_name	"$MODEL"
start_state	start
form            "HLRtvEdgRsSv",0,0,0,0

specification

/* structure containing all information about a job */
struct VEretrieve_struct
   {
   struct VEjob_info job_info;        /* job submittal information                         */
   struct GRid       window;          /* GRid of window to which job belongs               */ 
   IGRint            win_sequence_no; /* job number w.r.t. other jobs from the same window */
   };

instance
	{
	variable struct VEretrieve_struct jobs[0];   /* array of outstanding jobs    */
	IGRint                            job_index; /* index of job to be retrieved */
	IGRint                            num_jobs;  /* number of outstanding jobs   */
	}

implementation

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <FI.h>

#include "OMindex.h"
#include "OMlimits.h"
#include "OMmacros.h"

#include "exdef.h"

#include "refdef.h"
#include "ref.h"

#include "dpdef.h"
#include "dpmacros.h"

#include "msdef.h"
#include "msmacros.h"

#include "veerr.h"
#include "vewinmacros.h"
#include "vedpbmacros.h"
#include "veretform.h"
#include "vemsg.h"

#include "EMdtmacros.h"
#include "EMSdatumdef.h"

#include "dpstruct.h"

#define if_bad(sts) if (!(sts&1))

/* prototype files */
#include "VEpr_dpb.h"
#include "VEpr_utilfnc.h"
#include "VEpr_gragad.h"


from GRgraphics import GRconstruct, GRdisplay;
from IGEgragad  import DPinrot;

state_table

#include "vemsg.h"

at wakeup
   do initialize_instance_data
   do load_form_data

state start
   message_key  VEM_M_ReEdReSe
   execute check_for_background_jobs

      on SUCCESS
         state service_form
      on ELSE
         state terminate

state service_form
   display_form 0
   filter       wfi

      on EX_FORM_FINISHED
	do erase_form 0
        do get_the_files
        state terminate
      on ELSE
	state terminate


/*--- load_form_data -------------------------------------------------------------*/

action load_form_data

/*
NAME
	VEretrieve.load_form_data

DESCRIPTION
	This action initializes the form with all of the outstanding
	background jobs.

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             msg;
	IGRlong             total_found;
	IGRint              num_ids;
	IGRint              ii, jj, seq;
	IGRlong             ret_bytes;
	IGRlong             which_error;
	IGRint              old_num_jobs;
	struct GRid         window_ids[40];
	struct VEbatch_info batch_info;
	struct var_list     var_list[2];
	struct var_list     wire_var_list[2];
	Form                form_ptr;
	IGRchar             gragad_name[GRNAME_SIZE];

	form_ptr = me->forms[0].form_ptr;

	var_list[0].var = VE_BATCH_INFO;
	var_list[0].var_ptr = (IGRchar *) &batch_info;
	var_list[0].num_bytes = sizeof( struct VEbatch_info );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var = END_PARAM;

	wire_var_list[0].var            = GRAGAD_NAME;
	wire_var_list[0].var_ptr        = gragad_name;
	wire_var_list[0].num_bytes      = sizeof( gragad_name );
	wire_var_list[0].bytes_returned = &ret_bytes;
	wire_var_list[1].var            = END_PARAM;

	/* get all the outstanding background jobs from all of the windows */
	num_ids = 0;
	dp$get_gragad_id( msg         = &msg,
	                  name        = "*",
                          array_size  = 40,
                          total_num   = &total_found,
	                  numberofids = &num_ids,
	                  found_GRids = window_ids,
	                  type_gragad = ALL_TYPES );

	me->num_jobs = 0;
	for ( ii = 0; ii < num_ids; ii++ )
	   {
	   ve$get_window_instance_data( msg = &msg,
	                                win_id = window_ids[ii].objid,
	                                win_os = window_ids[ii].osnum,
	                                var_list = var_list,
	                                which_error = &which_error );

	   if ( batch_info.num_jobs )
	      {
	      /* this window has outstanding jobs => get its name and */
	      /* load its jobs into my instance data                  */
	      dp$inq_set_gragad( msg          = &msg,
	                         inq0_set1    = 0,
	                         osnum        = window_ids[ii].osnum,
	                         gragad_objid = window_ids[ii].objid,
	                         which_error  = &which_error,
	                         var_list     = wire_var_list );

	          MSG_ERRCHK( msg, "VEretrieve: dp$inq_set_gragad failed" );

	      old_num_jobs = me->num_jobs;
	      me->num_jobs += batch_info.num_jobs;
	      FIfld_set_num_rows( form_ptr, VE_RER_RET_JOB_LIST, me->num_jobs );
	      om$vla_set_dimension( varray = me->jobs, size = me->num_jobs );

	      for ( seq = 0,jj = old_num_jobs; jj < me->num_jobs; jj++, seq++ )
	         {
	         memcpy( &me->jobs[jj].job_info, &batch_info.job_info[seq], sizeof( struct VEjob_info ) );
	         memcpy( &me->jobs[jj].window, &window_ids[ii], sizeof( struct GRid ) );
	         me->jobs[jj].win_sequence_no = seq;

	         FIfld_set_text( form_ptr, VE_RER_RET_JOB_LIST, jj, 0, gragad_name, (jj==0) );

	         FIfld_set_text( form_ptr, VE_RER_RET_JOB_LIST, jj, 1,
	                         me->jobs[jj].job_info.results_fname, (jj==0) );
	         }

	      free( (IGRchar *) batch_info.job_info );
	      }

	   }

	if ( me->ve_vhl_flags & VE_VHL_ATTACH_RESULTS_FILE )
	   FIg_set_state_off( form_ptr, VE_RER_ATTACH_RESULTS_TOG );
	else
	   FIg_set_state_on( form_ptr, VE_RER_ATTACH_RESULTS_TOG );

	return( OM_S_SUCCESS );
	}  /* load_form_data */


/*--- check_for_background_jobs ----------------------------------------------*/

action check_for_background_jobs

/*
NAME
	VEretrieve.check_for_background_jobs

DESCRIPTION
	This action checks to see if any background jobs have been
	job submitted.

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{

	if ( me->num_jobs == 0 )
	   {
	   ex$message( msgnumb = VE_E_NoBgJob )
	   *sts = OM_W_WARNING;
	   }
	else
           *sts = OM_S_SUCCESS;

	} /* check_for_background_jobs */


/*--- form_notification -----------------------------------------*/

action form_notification

/*
NAME
	VEretrieve.form_notification

DESCRIPTION
	This action processes the form inputs for the Retrieve Edge
	Results From Server command

PARAMETERS
	form_label (IN) - the label of the form receiving input
	gadget_label (IN) - the label of the gadget receiving input
	value ((IN) - the new value of the gadget
	form_ptr (IN) - pointer to the form receiving input

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	    Creation Date
*/

	{
	IGRint position;

	/* Find out the number of the gadget */
	switch ( gadget_label )
	   {
	   case VE_RER_X_BUTTON:

	      _put_response( resp = MOVE_ON );
	      break;

	   case VE_RER_EXECUTE_BUTTON:

	      _put_response( resp = EX_FORM_FINISHED );

	      FIfld_get_active_row( form_ptr, VE_RER_RET_JOB_LIST, &me->job_index, &position );

	      /* save the state of the attach results toggle */
	      ve$set_dpb_flags( flags = me->ve_vhl_flags );
	      break;

	   case VE_RER_ATTACH_RESULTS_TOG :

	      me->ve_vhl_flags ^= VE_VHL_ATTACH_RESULTS_FILE;
	      break;

	   case VE_RER_RET_JOB_LIST :

	      /* make sure the selected row is displayable as selected      */
	      /* if this call is not here and the same row is selected      */
	      /* two times in a row, it doesn't appear selected on the form */
	      FIfld_set_select( form_ptr, VE_RER_RET_JOB_LIST, (int) value, 0, TRUE );
	      break;

	   }  /* end: switch */

	}  /* form_notification */


/*--- get_the_files ----------------------------------------------------------*/

action get_the_files

/*
NAME
	VEretrieve.get_the_files

DESCRIPTION
	gets the log file from the server
	if background job finished, gets the result object space

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	    Creation Date
*/

	{
	char		filename[200];		/* name of log or error file */
	char		*argu[2];		/* arguments to fork */
	char            server[100], escaped_server[100];
	char            escaped_results_fname[100];
	IGRint          ii;
	IGRint          ret;
	IGRlong	  	ret_bytes;
	IGRlong         set_msg;
	IGRlong	  	msg;
	IGRlong	 	which_error;
	IGRboolean	is_ok;			/* flag, F => error happened */
	IGRboolean      clear_window_flags;
	struct var_list VEvar_list[2];		/* inquire window data arg list */
	IGRchar         working_dir[1024];
	IGRchar         support_dir[1024];
	IGRchar         cur_filename[1024];
	IGRchar         buffer[400];
     	IGRchar         temp_buff[100];
	IGRchar         log_file[128];
	IGRchar         start_time[30];
	IGRint          num_processed, num_activated, num_completed, num_minutes, num_seconds;
	IGRint          attach_results;
	struct VEbatch_info batch_info;

	*sts = OM_S_SUCCESS;

	ex$message( field = PROMPT_FIELD, in_buff = " " );
	ex$message( msgnumb = VE_I_BgStatusCheck );

	attach_results = me->ve_vhl_flags & VE_VHL_ATTACH_RESULTS_FILE;

	strcpy( server, me->jobs[me->job_index].job_info.server_name );
	strcat( server, "." );
	strcat( server, me->jobs[me->job_index].job_info.user_name );
	if ( strlen(me->jobs[me->job_index].job_info.password) )
	   {
	   strcat( server, "." );
	   strcat( server, me->jobs[me->job_index].job_info.password );
	   }
	
	VEescape_special_characters( server, escaped_server );
	VEescape_special_characters( me->jobs[me->job_index].job_info.results_fname, escaped_results_fname );

	(void )VEget_directory_names( working_dir, 1024,
	                              support_dir, 1024, 
	                              cur_filename, 1024 );

	/* create shell script file and run it to check for server done */
	status = VEwrite_check_bg_results_script( working_dir,
	                                          me->jobs[me->job_index].job_info.unique_name,
	                                          escaped_server, filename );
	if_bad( status )
	   {
	   ex$message( msgnumb = status )
	   sleep( 3 );
	   return( OM_S_SUCCESS );
	   }

	argu[0] = filename;
	ret = ex$fork( num_entry = 1,
	               argu = argu,
	               wait_flag = TRUE );

	/* return code from forked script is in high order byte of 'ret' */
	switch ( ret >> 8 )
	   {
	   case 0:

	      /* the background job is finished */
	      is_ok = clear_window_flags = TRUE;
	      break;

	   case 1:

	      /* background job not done */
	      is_ok = clear_window_flags = FALSE;

	      /* get processing status from log file in /usr/tmp */
	      sprintf( log_file, "/usr/tmp/%s.log", me->jobs[me->job_index].job_info.unique_name );
	      VEparse_log_file_for_status( log_file, start_time, &num_processed, 
	                                   &num_activated, &num_completed, &num_minutes, &num_seconds );
	      EX_rm( log_file );

	      if ( (strlen(start_time) == 0) || (num_processed == 0) )
	         {
	         /* the background job hasn't started yet or it is still in */
	         /* the process of sorting the elements to be processed     */
	         ex$message( msgnumb = VE_I_JobNotStarted, buff = buffer );
	         }
	      else
	         {
	         /* format message showind status of job */
	         ex$message( msgnumb = VE_I_JobNotDone0, buff = buffer );

	         ex$message( msgnumb = VE_I_JobNotDone1,
	                     buff    = temp_buff,
	                     type    = "%s%d",
	                     var     = `start_time,num_processed` );
	      
	         sprintf( buffer, "%s %s", buffer, temp_buff );

	         ex$message( msgnumb = VE_I_JobNotDone2,
	                     buff    = temp_buff,
	                     type    = "%d%d",
	                     var     = `num_activated,num_completed` );
	         sprintf( buffer, "%s %s", buffer, temp_buff );

	         ex$message( msgnumb = VE_I_JobNotDone3,
	                     buff    = temp_buff,
	                     type    = "%d%d",
	                     var     = `num_minutes,num_seconds` );
	         sprintf( buffer, "%s %s", buffer, temp_buff );
	         }

	      ex$message( in_buff = "", field = ERROR_FIELD );

              ex$message( msgnumb = VE_I_InfoTitle, 
                          buff    = temp_buff );

	      FI_message_box( FI_CURRENT_SCREEN, -1, -1,
	                      temp_buff, FI_BLUE, "swiss742", 36.0,
	                      buffer, FI_BLACK, "swiss742", 18.0,
	                      FI_LEFT_JUSTIFIED, 40 );
	      break;

	   case 2:

	      /* catastrophic failure => can't find log file on server */
	      is_ok = FALSE;
	      clear_window_flags = TRUE;

	      ex$message( field = ERROR_FIELD, in_buff = " " );

	      ex$message( msgnumb = VE_F_BgNoFiles1,
	                  buff    = buffer );
	      strcat( buffer, " " );
	      ex$message( msgnumb = VE_F_BgNoFiles2,
	                  buff    = &buffer[strlen(buffer)] );

              ex$message( msgnumb = VE_I_WarnTitle, 
                          buff    = temp_buff );

	      FI_message_box( FI_CURRENT_SCREEN, -1, -1,
	                      temp_buff, FI_RED, "swiss742", 36.0,
	                      buffer, FI_BLACK, "swiss742", 18.0,
	                      FI_LEFT_JUSTIFIED, 40 );
	      break;

	   case 3:

	      /* can't connect to server */
	      is_ok = clear_window_flags = FALSE;
	      ex$message( msgnumb = VE_E_CantConnect );
	      sleep( 3 );
	      break;

	   default :

	      is_ok = clear_window_flags = FALSE;

	   }  /* end: switch */

	/* create shell script to retrieve results and start it in background */
	if ( is_ok )
	   {
	   status = VEwrite_retrieve_bg_results_script( working_dir,
	                                                me->jobs[me->job_index].job_info.unique_name,
	                                                escaped_server,
	                                                escaped_results_fname,
	                                                attach_results,
	                                                filename );

	   if_bad( status )
	      {
	      ex$message( msgnumb = status )
	      sleep( 3 );
	      }
	   else
	      {
	      ex$message( msgnumb = VE_I_CopyResProc )
	      argu[0] = filename;
	      ret = ex$fork( num_entry   = 1,
	                     argu        = argu,
	                     wait_flag   = attach_results,
	                     delete_flag = 0 );

	      if ( attach_results )
	         {
	         /* return code from forked script is in high order byte of 'ret' */
	         switch ( ret >> 8 )
	            {
	            case 0 :

	               /* transfer was o.k. => attach file */
	               *sts = om$send( targetid = my_id,
	                                msg     = message VEretrieve.attach_results( &msg ) );
	               break;

	            case 1 :

	               /* transfer failed -> report error */
	               ex$message( msgnumb = VE_F_RecResult,
	                           type    = "%s",
	                           var     = `me->jobs[me->job_index].job_info.results_fname` );
	               sleep( 3 );
	               break;

	            }  /* end: switch */

	         }  /* end: if ( attach_results ) */

	      ex$message( msgnumb = VE_I_LogFileIs,
	                  type    = "%s",
	                  var     = `me->jobs[me->job_index].job_info.unique_name` );

	      sleep( 3 );
	      }

	   }  /* end: if ( is_ok ) */

	if ( clear_window_flags )
	   {
	   /* get the window's instance data again */
	   /* delete job from window instance data */
	   VEvar_list[0].var            = VE_BATCH_INFO;
	   VEvar_list[0].var_ptr        = (IGRchar *) &batch_info;
	   VEvar_list[0].num_bytes      = sizeof( struct VEbatch_info );
	   VEvar_list[0].bytes_returned = &ret_bytes;
	   VEvar_list[1].var            = END_PARAM;

	   ve$get_window_instance_data( msg         = &set_msg,
	                                win_id      = me->jobs[me->job_index].window.objid,
	                                win_os      = me->jobs[me->job_index].window.osnum,
	                                which_error = &which_error,
	                                var_list    = VEvar_list );

	   
	   for ( ii = me->jobs[me->job_index].win_sequence_no + 1; ii < batch_info.num_jobs; ii++ )
	       memcpy( &batch_info.job_info[ii-1], &batch_info.job_info[ii], sizeof( struct VEbatch_info ) );

	   batch_info.num_jobs--;
	      
	   ve$set_window_instance_data( msg         = &set_msg,
	                                win_id      = me->jobs[me->job_index].window.objid,
	                                win_os      = me->jobs[me->job_index].window.osnum,
	                                which_error = &which_error,
	                                var_list    = VEvar_list );

	   if ( batch_info.job_info )
	      {
	      free( (IGRchar *) batch_info.job_info );
	      batch_info.job_info = NULL;
	      batch_info.num_jobs = 0;
	      }

	   }  /* end: if ( clear_window_flags ) */

	} /* get_the_files */


/*--- attach_results ----------------------------------------------------------*/

action attach_results

/*
NAME
	VEretrieve.attach_results

DESCRIPTION
	This action attaches the results file to the current master file as
	a reference file.

PARAMETERS
	none

GLOBALS USED
	none

HiSTORY
	xx/xx/xx    S.P. Rogers
	    Creation Date
*/

	{
	IGRlong               msg;
	IGRuint               ref_properties;
	OMuword               ref_classid;
	OM_S_OBJID            ref_id;
	IGRchar               filename[16];
	IGRdouble             window_rotation[16];
	enum GRdpmode         dpmode;
	struct IGRlbsys       lbsys;
	struct GRvg_construct const_list;
	struct GRrf_info      rf_info;
	IGRint                ref_plane_lock_mode;

	
	ex$message( msgnumb = VE_I_AttachingResults );

	/* turn ref plane lock off, if it is on */
	ems$ref_plane_lock( msg = &msg,
	                    options = EMS_REF_PLANE_LOCK_INQ,
	                    mode = &ref_plane_lock_mode );

	if ( ref_plane_lock_mode == EMS_REF_PLANE_LOCK_ON )
	   ems$ref_plane_lock( msg = &msg,
	                       options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET );

	/* get the rotation matrix of the gragad */
	*sts = om$send( msg      = message IGEgragad.DPinrot( &msg, window_rotation ),
	                targetid = me->jobs[me->job_index].window.objid,
	                targetos = me->jobs[me->job_index].window.osnum );

	om$get_classid( classname = "GRreffile", p_classid = &ref_classid );

	const_list.msg        = &msg;
	const_list.env_info   = &me->ModuleInfo;
	const_list.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	const_list.geometry   = (IGRchar *) &lbsys;
	const_list.display    = &me->ActiveDisplay;
	const_list.level      = me->ActiveLevel;
	const_list.newflag    = FALSE;
	const_list.name       = NULL;
	const_list.class_attr = (IGRchar *) &rf_info;

	strcpy( filename, me->jobs[me->job_index].job_info.results_fname );
	ref_properties = GRRF_IS_READ_ONLY;

	rf_info.filename        = filename;
	rf_info.named_view      = "EdgesResults";
	rf_info.clip_poly       = NULL;
	rf_info.prism_classname = NULL;
	rf_info.description     = NULL;
	rf_info.ref_properties  = &ref_properties;
	rf_info.scale           = NULL;

	/* build local bounded system for attachment */
	GRformlbsys( &msg, window_rotation, me->jobs[me->job_index].job_info.view_origin, &lbsys );

	   MSG_ERRCHK( msg, "VEretrieve: GRfomrlbsys failed" );

	*sts = om$construct( osnum     = me->ModuleInfo.md_id.osnum,
	                     obj_osnum = me->ModuleInfo.md_id.osnum,
	                     classid   = ref_classid,
	                     msg       = message GRgraphics.GRconstruct( &const_list ),
	                     p_objid   = &ref_id );


	   OM_ERRCHK( *sts, "VEretrieve: om$construct_failed" );
	   MSG_ERRCHK( msg, "VEretrieve: GRgraphics.GRconstruct failed" );

	/* turn ref plane lock back on, if required */
	if ( ref_plane_lock_mode == EMS_REF_PLANE_LOCK_ON )
	    ems$ref_plane_lock( msg = &msg,
	                        options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET );
	/* display ref file */
	dpmode = GRbd;
	*sts = om$send( msg = message GRgraphics.GRdisplay( &msg,
	                                                    &me->ModuleInfo.md_env.matrix_type,
	                                                    me->ModuleInfo.md_env.matrix,
	                                                    &dpmode,
	                                                    &me->ModuleInfo.md_id ),
	                targetid = ref_id,
	                targetos = me->ModuleInfo.md_id.osnum );

	   OM_ERRCHK( *sts, "VEretrieve: GRgraphics.GRdisplay send failed" );
	   MSG_ERRCHK( msg, "VEretrieve: GRgraphics.GRdisplay failed" );

	}  /* attach_results */
