
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

class implementation VEgragad;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <string.h>

#include <sys/utsname.h>

#include "bs.h"

#include "OMlimits.h"
#include "OMmacros.h"

#include "msdef.h"
#include "msmacros.h"

#include "madef.h"

#include "exdef.h"
#include "exmacros.h"

#include "igewindef.h"

#include "dpdef.h"
#include "dpmacros.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "veerr.h"
#include "vemsg.h"

/* prototype files */
#include "VEpr_driver.h"
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"

/* Global Variables Used By VE */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEresults_info     VEoutput_data;


/*--- VEsubmit_batch -------------------------------------------------*/

method VEsubmit_batch( IGRint          *msg;
	               struct GRid     *co_grid;
	               OM_S_CHANSELECT *gschansel;
	               IGRchar         *results_name;
	               IGRchar         *server_name;
	               IGRchar         *user_name;
	               IGRchar         *password;
	               IGRchar         *start_time )

/*
NAME
	VEgragad.VEsubmatch_batch

DESCRIPTION
	This method performs the functions required to set up a file
	for batch processing on a server and spawns the processes
	required to execute the VE job on the server.  The functions it
	does are:

	   1) Reads in the VE seed object space

	   2) Sets up the VE window in the invisible module exactly
	      the same as the window the user is running

	   3) Copies DPB and color table information to the invisible module

	   4) Copies all of the located elements to the invisible module

	   5) Writes the invisible module to the disk

	   6) Writes the shell scripts that will run the batch job

	   7) Forks the shell script that will start the batch execution

PARAMETERS
	msg (OUT) - return status
	co_grid (IN) - GRid of the command object that has the input
	               graphic set on its channel
	gschansel (IN) - channel selector for the command object channel
	                 containing the input graphic set
	results_name (IN) - the results file name of the batch job
	server_name (IN) - server to use to run that batch job
	user_name (IN) - username to login to the server
	password (IN) - password to login to the server
	start_time (IN) - start time of the job in NQS format

GLOBALS USED
	VEexec_parms
	VEexec_status
	VEoutput_data

HISTORY
	8/22/88    S.P. Rogers
	   Creation date
*/

	{
	IGRchar             *argu[2];
	IGRchar             gragad_name[GRNAME_SIZE];
	IGRchar             fname[OM_K_MAXOSNAME_LEN];
	IGRchar             osname[OM_K_MAXOSNAME_LEN];
	IGRchar             mount_name[OM_K_MAXOSNAME_LEN];
	IGRchar             working_dir[1024];
	IGRchar             support_dir[1024];
	IGRchar             cur_filename[OM_K_MAXOSNAME_LEN];
	IGRchar             fork_name[128];
	IGRchar             background_script[128];
	IGRchar             escaped_server[100], server[100];
	IGRchar             temp_string[128];
	IGRshort            prev_msg_status;
	IGRshort            prev_dummy;
	IGRshort            active_layer;
	IGRlong             sts;
 	IGRlong             ii;
	IGRint              file_no;
	IGRlong             ret_bytes;
	IGRlong             which_error;
	IGRlong             bytes_requested;
	IGRlong             bytes_returned;
	IGRdouble           *mat;
	FILE                *log_file;
	struct var_list     var_list[2];
	struct GRmd_env     invis_env;
	struct GRid         invis_module;
	struct GRid         gragad;
	struct GRid         parent;
	struct GRid         invis_gragad;
	struct GRid         invis_parent;
	struct utsname      name;
	IGRchar             unique_name[UNIQUE_NAME_SIZE];


	*msg = MSSUCC;

	sts = om$send( msg      = message VEgragad.VEinit_globals( msg, FALSE, FALSE ),
	               targetid = my_id );

	/* get the node name of this machine */
	uname( &name );

	/* get the current active layer */
	bytes_requested = sizeof( IGRshort );
	gr$get_active_level( msg    = msg,
	                     sizbuf = &bytes_requested,
	                     buffer = &active_layer,
	                     nret   = &bytes_returned );

	/* get my window name */
	var_list[0].var            = GRAGAD_NAME;
	var_list[0].var_ptr        = gragad_name;
	var_list[0].num_bytes      = sizeof( gragad_name );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	dp$inq_set_gragad( msg          = msg,
	                   inq0_set1    = 0,
	                   osnum        = OM_Gw_current_OS,
	                   gragad_objid = my_id,
	                   which_error  = &which_error,
	                   var_list     = var_list );

	    MSG_ERRCHK( *msg, "VEprocess_batch: dp$inq_set_gragad failed" );

	(void) VEget_directory_names( working_dir, 1024,
	                              support_dir, 1024,
	                              cur_filename, OM_K_MAXOSNAME_LEN );

	VEgenerate_unique_name( name.nodename, unique_name );

	/* save batch job data in my instance data */
	me->num_batch_jobs++;
	om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );

	strcpy( me->job_info[me->num_batch_jobs - 1].results_fname, results_name );
	strcpy( me->job_info[me->num_batch_jobs - 1].server_name, server_name );
	strcpy( me->job_info[me->num_batch_jobs - 1].user_name, user_name );
	strcpy( me->job_info[me->num_batch_jobs - 1].password, password );
	strcpy( me->job_info[me->num_batch_jobs - 1].unique_name, unique_name );

	strcpy( server, server_name );
	strcat( server, "." );
	strcat( server, user_name );
	if ( strlen( password ) )
	   {
	   strcat( server, "." );
	   strcat( server, password );
	   }

	/* save the current view origin so it can be used to */
	/* re-attach the background results later            */
	memcpy( me->job_info[me->num_batch_jobs - 1].view_origin, 
	        me->gragad.origin,
	        sizeof( IGRdouble ) * 3 );

	/* copy seed file to working directory with unique name */
	sprintf( fname, "%s%s.ems", working_dir, unique_name );
	if ( ! VEcopy_seed_file( fname ) )
	   {
	   /* can't copy seed file => restore instance data and return */
	   me->num_batch_jobs--;
	   om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );

	   ex$message( msgnumb = VE_E_CantCopySeed );
 	   sleep( 3 );
	   return( OM_E_ERROR );
	   }

	/* retrieve the ve batch seed file OS as an invisible module */
	ex$message( msgnumb = VE_I_RetBgSeedFile );

	sprintf( temp_string, "%s.ems", unique_name );
	DIstmocpy( mount_name, temp_string, NULL, OM_Gw_current_OS );
	ex$retrieve_module( filename   = fname,
	                    ftype      = EX_invisible,
	                    file_no    = &file_no,
	                    mod_type   = 2,
	                    fstat      = EX_old_module,
	                    mount_name = mount_name,
	                    msg        = msg );

	if ( *msg != EX_succ )
	   {
	   /* remove the copied seed file if it exists */
	   EX_rm( fname );

	   /* restore instance data */
	   me->num_batch_jobs--;
	   om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );

	   ex$message( msgnumb = VE_E_CantRetrieveSeed );
	   sleep( 3 );

	   return( OM_E_ERROR );
	   }

	/* get the module GRid of the invisible module */
	ex$get_invis_info_by_index( index     = file_no,
	                            mod_id    = &invis_module.objid,
	                            mod_osnum = &invis_module.osnum );

	/* change the internal name of the invisible object space so it can be   */
	/* used as a reference file without running into duplicate name problems */
	sprintf( osname, "%s%s", working_dir, results_name );
	sts = om$change_os_name( osnum      = invis_module.osnum,
	                         new_osname = osname,
	                         overwrite  = OM_e_overwrite );

	   OM_ERRCHK( sts, "VEsubmit_batch:  om$change_os_name failed" );

	if ( ! VEcreate_default_directory( invis_module.osnum ) )
	   {
	   /* remove the copied seed file if it exists */
	   EX_rm( fname );

	   /* restore instance data */
	   me->num_batch_jobs--;
	   om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );

	   ex$message( msgnumb = VE_E_CantRetrieveSeed );
	   sleep( 3 );

	   return( OM_E_ERROR );
	   }

	ex$message( msgnumb = VE_I_InitBgFile );

	/* find a layer to put all displayed elements on in the batch object space */
	for ( VEexec_parms.displayed_layer = 1023;
	      VEexec_parms.displayed_layer > 0; VEexec_parms.displayed_layer-- )
	   {
	   if ( (VEexec_parms.displayed_layer != active_layer) &&
	        (VEexec_parms.displayed_layer != VEoutput_data.visible_level) &&
	        (VEexec_parms.displayed_layer != VEoutput_data.hidden_level) )
	      break;
	   }  /* end: for */

	/* find a layer to put the non-displayed components of composite objects */
	for ( VEexec_parms.non_displayed_layer = VEexec_parms.displayed_layer - 1;
	      VEexec_parms.non_displayed_layer > 0; VEexec_parms.non_displayed_layer-- )
	   {
	   if ( (VEexec_parms.non_displayed_layer != active_layer) &&
	        (VEexec_parms.non_displayed_layer != VEoutput_data.visible_level) &&
	        (VEexec_parms.non_displayed_layer != VEoutput_data.hidden_level) )
	      break;

	   }  /* end: for */

	gragad.objid = my_id;
	gragad.osnum = OM_Gw_current_OS;

 	/* Get the id's of the objects */
	if (! VEget_needed_ids( gragad_name, &gragad, &invis_module, &parent, &invis_gragad, &invis_parent ) )
	   {
	   /* remove the copied seed file if it exists */
	   EX_rm( fname );

	   /* restore instance data */
	   me->num_batch_jobs--;
	   om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );

           ex$message( msgnumb = VE_I_NoWin, field = ERROR_FIELD );
	   sleep( 3 );
	   return( OM_E_ERROR );
	   }

	/* Setup the VE window in the invisible module */
	VEsetup_invis_ve_gragad( &gragad, &invis_gragad, &parent, &invis_parent );

	/* Copy the DPB data to the invisible module */
	VEcopy_dpb_info( &invis_module );

	/* Copy the Color Table information to the invisible module */
	VEcopy_color_table_info( &invis_module );

	/* set up a module environment structure for the invisible module */
	invis_env.md_id.objid = invis_module.objid;
	invis_env.md_id.osnum = invis_module.osnum;

	invis_env.md_env.matrix_type = MAIDMX;
	mat = invis_env.md_env.matrix;
	for ( ii = 0; ii < 16; ii++ )
	   mat[ii] = 0.0;

	mat[0] = mat[5] = mat[10] = mat[15] = 1.0;

	ex$message( msgnumb = VE_I_CopyToBgFile );

	/* collect the located elements and copy them to the invisible module */
	VEcollect_elements( co_grid, gschansel, &invis_env, TRUE );

	/* free the memory used by VE */
	VEfree_memory();

	if ( VEexec_status.VEtotal_elems != 0 )
	   {
	   /* write the invisible module to disk */
	   ex$message( msgnumb = VE_I_SavingBgFile );
	   sts = ex$close_module( index = file_no, flag = 1, ftype = EX_invisible );

	      OM_ERRCHK( sts, "VEprocess_batch: ex$close_module failed" );

	   if ( sts != OM_S_SUCCESS )
	      {
	      /* error closing/saving batch object space */
	      ex$message( msgnumb = VE_E_CantSaveBgFile );

	      sleep( 3 );

	      /* remove copied seed file */
	      EX_rm( fname );

	      /* restore instance data */
	      me->num_batch_jobs--;
	      om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );

	      return( OM_E_ERROR );
	      }

	   /* write the current master file to disk so the gragad */
	   /* instance data changes will be preserved             */
	   ex$message( msgnumb = VE_I_SavingDgnFile );

	   ms$onoff( msg       = (IGRlong *)msg,
	             prevstate = &prev_msg_status,
	             type      = MS_OFF );

	   sts = ex$save_module( ftype = EX_visible, filename = cur_filename );

	   ms$onoff( msg       = (IGRlong *)msg,
	             setstate  = prev_msg_status,
	             prevstate = &prev_dummy,
	             type      = MS_SET );

	   if ( sts == 0 )
	      {
	      /* error saving current design file */
	      ex$message( msgnumb = VE_E_CantSaveDgnFile );
	      sleep( 3 );

	      /* remove copied seed file */
	      EX_rm( fname );

	      /* restore instance data */
	      me->num_batch_jobs--;
	      om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );

	      return( OM_E_ERROR );
	      }

	   /* create the log file */
	   ex$message( msgnumb = VE_I_SubmittingJob );

	   log_file = VEcreate_log_file( working_dir,
	                                 unique_name,
	                                 name.nodename,
	                                 cur_filename,
	                                 gragad_name,
	                                 server,
	                                 me->job_info[me->num_batch_jobs - 1].results_fname );

	   VEescape_special_characters( server, escaped_server );

	   /* generate the shell scripts required to run the background job */
	   VE_initialize_bg( invis_gragad.objid, working_dir, unique_name, escaped_server,
	                     name.nodename, FALSE, start_time, background_script );

	   /* close the log file */
	   fclose( log_file );

	   /* fork the background script to start the background job */
	   strcpy( fork_name, working_dir );
	   strcat( fork_name, background_script );
	   argu[0] = fork_name;
	   sts = ex$fork( num_entry   = 1,
	                  argu        = argu,
	                  delete_flag = 0 );

	   if ( sts == 0 )
	      {
	      /* error forking script for background job */

	      /* restore instance data */
	      me->num_batch_jobs--;
	      om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );

	      ex$message( buff = temp_string, msgnumb = VE_I_ForkErr ); 
	      fprintf( stderr, "%s\n", temp_string );
	      }

	   }  /* end: if ( VEexec_status.VEtotal_elems != 0.0 ) */
	else
	   {
	   /* no processable elements were located => close the invisible */
	   /* module without saving it and remove it                      */
	   ex$close_module( index = file_no, flag = 0, ftype = EX_invisible );

	   /* restore instance data */
	   me->num_batch_jobs--;
	   om$vla_set_dimension( varray = me->job_info, size = me->num_batch_jobs );
	   EX_rm( fname );
	   }

	return( OM_S_SUCCESS );

	}  /* VEsubmit_batch */

end implementation VEgragad;

