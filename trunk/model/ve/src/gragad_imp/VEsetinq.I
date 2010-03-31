
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

class implementation VEinstance;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bsparameters.h"

#include "OMmacros.h"

#include "msdef.h"

#include "dpdef.h"
#include "dp.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "vewinmacros.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_gragad.h"

extern OMuword OPP_IGEgragad_class_id;

/*--- VEget_default_instance -----------------------------------------*/

IGRlong VEget_default_instance( msg, which_error, list )

	IGRlong         *msg;
	IGRlong         *which_error;
	struct var_list *list;

/*
NAME
	VEget_default_instance

DESCRIPTION
	This function returns the default instance data for a VE gragad.

PARAMETERS
	msg (OUT) - status return
	which_error (OUT) - which parameter failed, if an error occurred
	list (IN) - list of parameters whose default value is to be
	                returned

GLOBALS USED
	none

RETURN VALUES
	0 - if successful
	1 - otherwise

HISTORY
	02/12/90    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean              storage;
	struct VEbatch_info     *batch_info;

	*msg = MSSUCC;

	storage = TRUE;
	while ( (storage) && (list->var != END_PARAM) )
	   {
	   switch( list->var )
	      {
	      case VE_BATCH_INFO :

	         if ( storage = (list->num_bytes >= sizeof( struct VEbatch_info )) )
	            {
	            *(list->bytes_returned) = sizeof( struct VEbatch_info );
	            batch_info = (struct VEbatch_info *) list->var_ptr;
	            batch_info->num_jobs = 0;
	            batch_info->job_info = NULL;
	            }
	         break;
	           
	      default :

	         storage = FALSE;
	         break;

	      }  /* end: switch */

	   /* If there was an error, then return the flag of the */
	   /* attribute that the error occured on                */
	   if (!storage)
	      {
	      *which_error = list->var;
	      *msg = MSFAIL;
	      }

	   list++;
	   }  /* end: while */

	return( (*msg == MSSUCC) ? 0 : 1 );
	}  /* VEget_default_instance */


/*--- VEget_window_instance_data -------------------------------------*/

IGRlong VEget_window_instance_data(	IGRlong         *msg,
					OM_S_OBJID      win_id,
					OMuword         win_os,
					IGRlong         *which_error,
					struct var_list *list )

/*
NAME
	VEget_window_instance_data

DESCRIPTION
	This function gets the VE instance data for a window.  There are
	4 cases:

	   1) (win_id,win_os) is a VEgragad -> its instance data is returned

	   2) (win_id,win_os) is a sublcass of IGEgragad and has a VEinstance
	      object attached -> the VEinstance object's instance data is
	      returned

	   3) (win_id,win_os) is a subclass of IGEgragad and doesn't have a
	      VEinstance object attached -> default instance data is returned

	   4) (win_id,win_os) is not a subclass of IGEgragad => error and
	      *msg is set to MSFAIL

PARAMETERS
	msg (OUT) - status return
	win_id (IN) - the gragad whose instance data is to be returned
	win_os (IN) - the object space number of the gragad
	which_error (OUT) - which parameter failed, if an error occurred
	list (IN) - list of parameters whose value is to be returned

GLOBALS USED
	none

RETURN VALUES
	0 - if successful
	1 - otherwise

HISTORY
	02/12/90    S.P. Rogers
	   Creation Date
*/
	   
	{
	IGRlong    sts;
	OM_S_OBJID ve_inst_id;
	OMuword    win_classid;

	*msg = MSSUCC;

	om$get_classid( objid = win_id, osnum = win_os, p_classid = &win_classid );

	if ( om$is_ancestry_valid( subclassid = win_classid,
	                           superclassid = OPP_VEinstance_class_id ) == OM_S_SUCCESS )
	   {
	   /* object has VEinstance in its ancestry => get instance data from it */
	   sts = om$send( msg      = message VEinstance.VEinquire( msg, which_error, list ),
	                  targetid = win_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );
	   }
	else
	   {
	   /* see if there's a VEinstance object attached to this window */
	   ve$get_saved_instance_id( msg         = msg,
	                             win_id      = win_id,
	                             win_os      = win_os,
	                             instance_id = &ve_inst_id );

	   if ( *msg != MSSUCC )
	      return( 1 );  /* object isn't a subclass of IGEgragad */

	   if ( ve_inst_id != NULL_OBJID )
	      {
	      /* window has a VEinstance object attached to it => get instance data from it */
	      sts = om$send( msg      = message VEinstance.VEinquire( msg, which_error, list ),
	                     targetid = ve_inst_id,
	                     targetos = win_os,
	                     senderid = NULL_OBJID );
	      }
	   else if ( om$is_ancestry_valid( subclassid = win_classid,
	                                   superclassid = OPP_IGEgragad_class_id ) == OM_S_SUCCESS )
	      {
	      /* window with no VE instace data => return default instance data */
	      VEget_default_instance( msg, which_error, list );
	      }
	   }

	return( (*msg == MSSUCC) ? 0 : 1 );
	}  /* VEget_window_instance_data */


/*--- VEset_window_instance_data -------------------------------------*/

IGRlong VEset_window_instance_data(	IGRlong         *msg,
					OM_S_OBJID      win_id,
					OMuword         win_os,
					IGRlong         *which_error,
					struct var_list *list)

/*
NAME
	VEset_window_instance_data

DESCRIPTION
	This function changes the VE instance data for a window.  There are 4
	cases:

	   1) (win_id,win_os) is a VEgragad -> its instance data is changed

	   2) (win_id,win_os) is a sublcass of IGEgragad and has a VEinstance
	      object attached -> the VEinstance object's instance data is
	      changed

	   3) (win_id,win_os) is a subclass of IGEgragad and doesn't have a
	      VEinstance object attached -> a VEinstance object is constructed
	      and attached to (win_id,win_os) and its instnace data is
	      changed

	   4) (win_id,win_os) is not a subclass of IGEgragad => error and
	      *msg is set to MSFAIL
	   
PARAMETERS
	msg (OUT) - status return
	win_id (IN) - the gragad whose instance data is to be set
	win_os (IN) - the object space number of the gragad
	which_error (OUT) - which parameter failed, if an error occurred
	list (IN) - list of parameters whose value is to be set

GLOBALS USED
	none

RETURN VALUES
	0 - if successful
	1 - otherwise

HISTORY
	02/12/90    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID ve_inst_id;
	OMuword    win_classid;

	*msg = MSSUCC;

	om$get_classid( objid = win_id, osnum = win_os, p_classid = &win_classid );

	if ( om$is_ancestry_valid( subclassid = win_classid,
	                           superclassid = OPP_VEinstance_class_id ) == OM_S_SUCCESS )
	   {
	   /* object has VEinstance in its ancestry => set its instance data */
	   /* object is a VE window => set its instance data */
	   sts = om$send( msg      = message VEinstance.VEset( msg, which_error, list ),
	                  targetid = win_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "VEset_window_instance_data:  VEinstance.VEset send failed" );

	   }
	else
	   {
	   /* see if there's a VEinstance object attached to this window */
	   ve$get_saved_instance_id( msg = msg,
	                             win_id = win_id,
	                             win_os = win_os,
	                             instance_id = &ve_inst_id );

	   if ( *msg != MSSUCC )
	      return( 1 );  /* object isn't a subclass of IGEgragad */

	   if ( ve_inst_id != NULL_OBJID )
	      {
	      /* window has a VEinstance object attached to it => set its instance data */
	      sts = om$send( msg      = message VEinstance.VEset( msg, which_error, list ),
	                     targetid = ve_inst_id,
	                     targetos = win_os,
	                     senderid = NULL_OBJID );

	         OM_ERRCHK( sts, "VEset_window_instance_data:  VEinstance.VEset send failed" );
	      }
	   else if ( om$is_ancestry_valid( subclassid = win_classid,
	                                   superclassid = OPP_IGEgragad_class_id ) == OM_S_SUCCESS )
	      {
	      /* construct a VEinstance object, connect it to this window, and */
	      /* set the instance data in the VEinstance object                */
	      sts = om$construct( osnum = win_os,
	                          classid = OPP_VEinstance_class_id,
	                          p_objid = &ve_inst_id );

	         OM_ERRCHK( sts, "VEset_window_instance_data:  construct of VEinstance failed" );

	      VEconnect_instance_to_gragad( msg, ve_inst_id, win_id, win_os );

	      sts = om$send( msg      = message VEinstance.VEset( msg, which_error, list ),
	                     targetid = ve_inst_id,
	                     targetos = win_os,
	                     senderid = NULL_OBJID );

	         OM_ERRCHK( sts, "VEset_window_instance_data:  VEinstance.VEset send failed" );
	      }
	   }

	return( (*msg == MSSUCC) ? 0 : 1 );
	}  /* VEset_window_instance_data */


/*--- VEinquire -----------------------------------------------------------*/

method VEinquire( IGRlong         *msg;
	          IGRlong         *which_error;
	          struct var_list *list )

/*
NAME
	VEgragad.VEinquire

DESCRIPTION
	Inquire method of the window.  Will look at the arguments in
	list and returned the requested information from the
	hidden line instance data

PARAMETERS
	msg (OUT) - status return
	which_error (OUT) - which parameter failed, if an error occurred
	list (IN) - list of parameters whose value is to be inquired

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean              storage;
	struct VEbatch_info     *batch_info;

	*msg = MSSUCC;

	storage = TRUE;
	while ( (storage) && (list->var != END_PARAM) )
	   {
	   switch( list->var )
	      {
	      case VE_BATCH_INFO :

	         if ( storage = (list->num_bytes >= sizeof( struct VEbatch_info )) )
	            {
	            batch_info = (struct VEbatch_info *) list->var_ptr;
	            *(list->bytes_returned) = sizeof( struct VEbatch_info );
	            batch_info->num_jobs = me->num_batch_jobs;

	            if ( me->num_batch_jobs > 0 )
	               {
	               /* allocate space for batch info */
	               batch_info->job_info =  
	                  (struct VEjob_info *) malloc( me->num_batch_jobs * sizeof( struct VEjob_info ) );
	               memcpy( batch_info->job_info,
	                       me->job_info,
	                       sizeof( struct VEjob_info ) * me->num_batch_jobs );
	               }
	            else
	               batch_info->job_info = NULL;
	            }
	         break;
	           
	      default :

	         storage = FALSE;
	         break;

	      }  /* end: switch */

	   /* If there was an error, then return the flag of the */
	   /* attribute that the error occured on                */
	   if (!storage)
	      {
	      *which_error = list->var;
	      *msg = MSFAIL;
	      }

	   list++;
	   }  /* end: while */

	return( OM_S_SUCCESS );

	}   /* VEinquire */


/*--- VEset --------------------------------------------------------------*/

method VEset( IGRlong         *msg;
	      IGRlong         *which_error;
	      struct var_list *list )

/*
NAME
	VEgragad.VEset

DESCRIPTION
	Set method for the window

PARAMETERS
	msg (OUT) - status return
	which_error (OUT) - which parameter failed, if an error occurred
	list (IN) - list of parameters whose value is to be set

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean              storage;
	struct VEbatch_info     *batch_info;

	*msg = MSSUCC;

	storage = TRUE;
	while ( (storage) && (list->var != END_PARAM) )
	   {
	   switch( list->var )
	      {
	      case VE_BATCH_INFO :

	         if ( storage = (list->num_bytes >= sizeof( struct VEbatch_info )) )
	            {
	            batch_info = (struct VEbatch_info *) list->var_ptr;
	            *(list->bytes_returned) = sizeof( struct VEbatch_info );
	            me->num_batch_jobs = batch_info->num_jobs;

	            if ( batch_info->num_jobs > 0 )
	               {
	               om$vla_set_dimension( varray = me->job_info, size = batch_info->num_jobs );
	               memcpy( me->job_info,
	                       batch_info->job_info,
	                       batch_info->num_jobs * sizeof( struct VEjob_info ) );
	               }
	            }

	         break;
	         
	      default :

	         storage = FALSE;
	         break;

	      }  /* end: switch */

	   if (!storage)
	      {
	      *which_error = list->var;
	      *msg = MSFAIL;
	      }

	   list++;
	   } /* end: while */

	return( OM_S_SUCCESS );

	}   /* VEset */


/*--- debug --------------------------------------------------------*/

method debug()

/*
NAME
	VEgragad.debug

DESCRIPTION
	Dump the instance data to standard error

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRint ii;

	fprintf( stderr, "VEgragad/VEinstance INSTANCE DATA\n\n" );

	fprintf( stderr, "   NUM-BATCH-JOBS: %d\n", me->num_batch_jobs );

	for ( ii = 0; ii < me->num_batch_jobs; ii++ )
	   {
	   fprintf( stderr, "      JOB: %d\n", ii );
	   fprintf( stderr, "         RESULTS-FILE-NAME: %s\n", me->job_info[ii].results_fname );
	   fprintf( stderr, "         SERVER-NAME: %s\n", me->job_info[ii].server_name );
	   fprintf( stderr, "         USER-NAME: %s\n", me->job_info[ii].user_name );
	   fprintf( stderr, "         PASSWORD: %s\n", me->job_info[ii].password );
	   fprintf( stderr, "         UNIQUE-NAME: %s\n", me->job_info[ii].unique_name );
	   fprintf( stderr, "         VIEW-ORIGIN: %lf %lf %lf\n",
	            me->job_info[ii].view_origin[0],
	            me->job_info[ii].view_origin[1],
	            me->job_info[ii].view_origin[2] );
	   }

	return( OM_S_SUCCESS );

	}  /* debug */

end implementation VEinstance;


