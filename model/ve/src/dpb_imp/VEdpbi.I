
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $

HISTORY

        Sudha   07/28/93        Modified for BSprototype ansification
*/

class implementation VEdpb;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "igetypedef.h"

#include "bsparameters.h"
#include "bstypes.h"
#include "bsxtractpar.h"

#include "OMmacros.h"

#include "exdef.h"
#include "exmacros.h"

#include "msdef.h"

#include "dpdef.h"
#include "dp.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "vewinmacros.h"
#include "veerr.h"
#include "ve_inst.h"

/* prototype files */
#include "VEpr_dpb.h"

/*--- debug --------------------------------------------------*/

method debug()

/*
NAME
	VEdpb.debug

KEYWORD
	debug

DESCRIPTION
	Dump the instance of a VEdpb object to standard error

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	fprintf( stderr, "VEdpb INSTANCE DATA\n" );
	fprintf( stderr, "   FLAGS: 0x%X\n", me->flags );
	fprintf( stderr, "   GAPPING DISTANCE: %lf\n", me->gapping_distance );
	fprintf( stderr, "   TRACE TOL:        %lf\n", me->trace_tol );
	fprintf( stderr, "   SURF THRESHOLD:   %d\n", me->surf_threshold );
	fprintf( stderr, "   CURVE THRESHOLD:  %d\n", me->curve_threshold );
	fprintf( stderr, "   SERVER: %s\n", me->server );
	fprintf( stderr, "   USER NAME: %s\n", me->user_name );
	fprintf( stderr, "   PASSWORD: %s\n", me->password );
	fprintf( stderr, "   RESULTS-FILE: %s\n", me->results_file );
	fprintf( stderr, "   START-TIME: %s\n", me->start_time );

	return( OM_S_SUCCESS );
	} /* debug */


/*--- super_construct -------------------------------------------------------*/

method super_construct()

/*
NAME
	VEdpb.super_construct

DESCRIPTION
	Load default instance data in a VEdpb object

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong      msg;
	IGRlong      rc;
	IGRint       size, level, bytes_ret;
	IGRdouble    cht;

	msg = MSSUCC;

	/* get the CHT */
	BSxtractpar( &rc, BSTOLCHRDHT, &cht );

	/* get the active level */
	size = sizeof( IGRint );
	gr$get_active_level( msg    = &msg,
	                     sizbuf = &size,
	                     buffer = &level,
	                     nret   = &bytes_ret );

	me->flags =  VE_VHL_NO_TRACE |
	             VE_VHL_OUTPUT_SOLID_SELF_HIDDEN |
	             VE_VHL_ATTACH_RESULTS_FILE;

	me->gapping_distance = 10.0 * cht;
	me->trace_tol = 1.2 * cht;
	me->surf_threshold = 16;
	me->curve_threshold = 255;

	me->server[0] = '\0';
	me->user_name[0] = '\0';
	me->password[0] = '\0';
	me->results_file[0] = '\0';
	me->start_time[0] = '\0';

	return( OM_S_SUCCESS );
	}

/*--- copy_instance_to_other_VEdpb -------------------------------------*/

method copy_instance_to_other_VEdpb( OM_S_OBJID objid; OMuword osnum )

/*
NAME
	VEdpb.copy_instance_to_other_VEdpb

DESCRIPTION
	This method copies all of the instance data in a VEdpb object 
	to another VEdpb object

PARAMETERS
	objid (IN) - the object id of the VEdpb to copy the instance data
	             to
	osnum (IN) - the object space number of the VEdpb

GLOBALS USED
	none

HISTORY
	xx/xx/91    S.P. Rogers
	   Creation Date
*/

	{

	om$send( msg = message VEdpb.set_flags( me->flags),
	         targetid = objid, targetos = osnum );

	om$send( msg = message VEdpb.set_gapping_distance( me->gapping_distance ),
	         targetid = objid, targetos = osnum );

	om$send( msg = message VEdpb.set_trace_tol( me->trace_tol ),
	         targetid = objid, targetos = osnum );

	om$send( msg = message VEdpb.set_reduction_thresholds( me->surf_threshold, me->curve_threshold ),
	         targetid = objid, targetos = osnum );

	om$send( msg = message VEdpb.set_last_bg_info( me->server, me->user_name, me->password,
	                                               me->results_file, me->start_time ),
	         targetid = objid, targetos = osnum );

	return( OM_S_SUCCESS );
	}  /* copy_instance_to_other_VEdpb */


/*--- get_flags --------------------------------------------------------*/

method get_flags( IGRuint *flags )

/*
NAME
	VEdpb.get_flags

DESCRIPTION
	Get the flags word from a VEdpb

PARAMETERS
	flags (OUT) - the flags word

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	*flags = me->flags;
	return( OM_S_SUCCESS );
	}  /* get_flags */

/*--- set_flags --------------------------------------------------------*/

method set_flags( IGRuint flags )

/*
NAME
	VEdpb.set_flags

DESCRIPTION
	Set the flags word in a VEdpb

PARAMETERS
	flags (IN) - the flags word

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	me->flags = flags;
	return( OM_S_SUCCESS );
	}  /* set_flags */

/*--- get_gapping_distance --------------------------------------------*/

method get_gapping_distance( IGRdouble *gapping_distance )

/*
NAME
	VEdpb.get_gapping_distance

DESCRIPTION
	Get the gapping distance from a VEdpb

PARAMETERS
	gapping_distance (OUT) - the flags word

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	*gapping_distance = me->gapping_distance;
	return( OM_S_SUCCESS );
	}  /* get_gapping_distance */

/*--- set_gapping_distance --------------------------------------------*/

method set_gapping_distance( IGRdouble gapping_distance )

/*
NAME
	VEdpb.set_gapping_distance

DESCRIPTION
	Set the gapping distance in a VEdpb

PARAMETERS
	gapping_distance (IN) - the gapping distance

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	me->gapping_distance = gapping_distance;
	return( OM_S_SUCCESS );
	}  /* set_gapping_distance */

/*--- get_trace_tol --------------------------------------------------*/

method get_trace_tol( IGRdouble *trace_tol )

/*
NAME
	VEdpb.get_trace_tol

DESCRIPTION
	Get the tracing tolerance from a VEdpb

PARAMETERS
	trace_tol (OUT) - the tracing tolerance

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	*trace_tol = me->trace_tol;
	return( OM_S_SUCCESS );
	}  /* get_trace_tol */

/*--- set_trace_tol --------------------------------------------------*/

method set_trace_tol( IGRdouble trace_tol )

/*
NAME
	VEdpb.set_trace_tol

DESCRIPTION
	Set the tracing tolerance in a VEdpb

PARAMETERS
	trace_tol (IN) - the tracing tolerance

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	me->trace_tol = trace_tol;
	return( OM_S_SUCCESS );
	}  /* set_trace_tol */

/*--- get_reduction_thresholds ----------------------------------------*/

method get_reduction_thresholds( IGRshort *surf_threshold; IGRshort *curve_threshold )

/*
NAME
	VEdpb.get_reduction_thresholds

DESCRIPTION
	Get the reduction thresholds from a VEdpb

PARAMETERS
	surf_threshold (OUT) - the surface reduction threshold
	curve_threshold (OUT) - the curve reduction threshold

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	*surf_threshold = me->surf_threshold;
	*curve_threshold = me->curve_threshold;
	return( OM_S_SUCCESS );
	}  /* get_reduction_thresholds */

/*--- set_reduction_thresholds ----------------------------------------*/

method set_reduction_thresholds( IGRshort surf_threshold; IGRshort curve_threshold )

/*
NAME
	VEdpb.set_reduction_thresholds

DESCRIPTION
	Set the reduction thresholds in a VEdpb

PARAMETERS
	surf_threshold (IN) - the surface reduction threshold
	curve_threshold (IN) - the curve reduction threshold

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	me->surf_threshold = surf_threshold;
	me->curve_threshold = curve_threshold;
	return( OM_S_SUCCESS );
	}  /* set_reduction_thresholds */

/*--- get_last_bg_info ------------------------------------------------*/

method get_last_bg_info( IGRchar *last_server; IGRchar *last_user_name;
	                 IGRchar *last_password; IGRchar *last_results_file; IGRchar *last_start_time )

/*
NAME
	VEdpb.get_last_bg_info

DESCRIPTION
	Get the last background job information from a VEdpb

PARAMETERS
	last_server (OUT) - the last server
	last_user_name (OUT) - the last user name
	last_password (OUT) - the last password
	last_results_file (OUT) - the last results file name
	last_start_time (OUT) - the last starting time

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	strcpy( last_server, me->server );
	strcpy( last_user_name, me->user_name );
	strcpy( last_password, me->password );
	strcpy( last_results_file, me->results_file );
	strcpy( last_start_time, me->start_time );

	return( OM_S_SUCCESS );
	}  /* get_last_server */

/*--- set_last_bg_info ------------------------------------------------*/

method set_last_bg_info( IGRchar *last_server; IGRchar *last_user_name;
	                 IGRchar *last_password; IGRchar *last_results_file; IGRchar *last_start_time )

/*
NAME
	VEdpb.set_last_bg_info

DESCRIPTION
	Set the last background job information in a VEdpb

PARAMETERS
	last_server (OUT) - the last server
	last_user_name (OUT) - the last user name
	last_password (OUT) - the last password
	last_results_file (OUT) - the last results file name
	last_start_time (OUT) - the last starting time

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	strcpy( me->server, last_server );
	strcpy( me->user_name, last_user_name );
	strcpy( me->password, last_password );
	strcpy( me->results_file, last_results_file );
	strcpy( me->start_time, last_start_time );

	return( OM_S_SUCCESS );
	}  /* set_last_bg_info */

/* ################## FUNCTIONS USED TO ACCESS DPB DATA ################## */

/* Functions return 0 if successful, 1 if a failure occurs */

/*--- VEget_dpb_super -----------------------------------------------------*/

void VEget_dpb_super( super_id, super_os )

	OM_S_OBJID	*super_id;
	OMuword		*super_os;

/*
NAME
	VEget_dpb_super

DESCRIPTION
	Get the VEdpb super object for the master object space

PARAMETERS
	super_id (OUT) - the object id of the VEdpb
	super_os (OUT) - the object space number of the VEdpb

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	OM_S_OBJID	temp_mod_id;
	OMuword		temp_mod_os;

	ex$get_cur_mod( osnum = &temp_mod_os, id = &temp_mod_id );

	ex$get_super( mod_id      = temp_mod_id,
	              mod_osnum   = temp_mod_os,
	              super_name  = "VEdpb",
	              super_class = "VEdpb",
	              super_id    = super_id,
	              super_osnum = super_os,
	              create      = 1 );

	}  /* VEget_dpb_super */

/*--- VEdpb_copy_data_to_other_os ------------------------------------------*/

IGRint VEdpb_copy_data_to_other_os( OMuword osnum )

/*
NAME
	VEdpb_copy_data_to_other_os

DESCRIPTION
	Copy the data from the master file VEdpb to a VEdpb in another
	object space

PARAMETERS
	osnum (in) - the object space number of the VEdpb to receive the
	             data

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID mod_id;
	OM_S_OBJID super_id;
	OMuword    super_os;
	OM_S_OBJID other_super_id;
	OMuword    other_super_os;

	ex$get_modid( mod_osnum = osnum, mod_id = &mod_id );

	ex$get_super( mod_id      = mod_id,
	              mod_osnum   = osnum,
	              super_name  = "VEdpb",
	              super_class = "VEdpb",
	              super_id    = &other_super_id,
	              super_osnum = &other_super_os,
	              create      = 1 );

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg = message VEdpb.copy_instance_to_other_VEdpb( other_super_id, other_super_os ),
	               targetid = super_id, targetos = super_os, senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_copy_data_to_other_os */


/*--- VEdpb_get_flags -----------------------------------------*/

IGRint VEdpb_get_flags( flags )

	IGRuint *flags;

/*
NAME
	VEdpb_get_flags

DESCRIPTION
	This function gets the flags from the current module.

PARAMETERS
	flags (OUT) - the flags word

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.get_flags( flags ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_get_flags */


/*--- VEdpb_set_flags -----------------------------------------*/

IGRint VEdpb_set_flags( flags )

	IGRuint flags;

/*
NAME
	VEdpb_set_flags

DESCRIPTION
	This function sets the flags in the current module.

PARAMETERS
	flags (IN) - the flags word

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.set_flags( flags ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_set_flags */


/*--- VEdpb_get_gapping_distance -----------------------------------------*/

IGRint VEdpb_get_gapping_distance( gapping_distance )

	IGRdouble *gapping_distance;

/*
NAME
	VEdpb_get_gapping_distance

DESCRIPTION
	This function gets the gapping distance from the current module.

PARAMETERS
	gapping_distance (OUT) - the gapping distance

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.get_gapping_distance( gapping_distance ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_get_gapping_distance */


/*--- VEdpb_set_gapping_distance -----------------------------------------*/

IGRint VEdpb_set_gapping_distance( gapping_distance )

	IGRdouble gapping_distance;

/*
NAME
	VEdpb_set_gapping_distance

DESCRIPTION
	This function sets the gapping distance in the current module.

PARAMETERS
	gapping_distance (IN) - the gapping distance

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.set_gapping_distance( gapping_distance ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_set_gapping_distance */


/*--- VEdpb_get_trace_tol -----------------------------------------*/

IGRint VEdpb_get_trace_tol( trace_tol )

	IGRdouble *trace_tol;

/*
NAME
	VEdpb_get_trace_tol

DESCRIPTION
	This function gets the tracing tolerance from the current module.

PARAMETERS
	trace_tol (OUT) - the tracing tolerance

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.get_trace_tol( trace_tol ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_get_trace_tol */


/*--- VEdpb_set_trace_tol -----------------------------------------*/

IGRint VEdpb_set_trace_tol( trace_tol )

	IGRdouble trace_tol;

/*
NAME
	VEdpb_set_trace_tol

DESCRIPTION
	This function sets the tracing tolerance in the current module.

PARAMETERS
	trace_tol (IN) - the tracing tolerance

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.set_trace_tol( trace_tol ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_set_trace_tol */


/*--- VEdpb_get_reduction_thresholds -----------------------------------------*/

IGRint VEdpb_get_reduction_thresholds( surf_threshold, curve_threshold )

	IGRshort *surf_threshold, *curve_threshold;

/*
NAME
	VEdpb_get_reduction_thresholds

DESCRIPTION
	This function gets the reduction thresholds from the current module.

PARAMETERS
	surf_threshold (OUT) - the surface reduction threshold
	curve_threshold (OUT) - the curve reduction threshold

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.get_reduction_thresholds( surf_threshold, curve_threshold ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_get_reduction_thresholds */


/*--- VEdpb_set_reduction_thresholds -----------------------------------------*/

#if defined(__STDC__)
IGRint VEdpb_set_reduction_thresholds(  IGRshort surf_threshold, 
					IGRshort curve_threshold)
#else
IGRint VEdpb_set_reduction_thresholds( surf_threshold, curve_threshold )

	IGRshort surf_threshold, curve_threshold;
#endif

/*
NAME
	VEdpb_set_reduction_thresholds

DESCRIPTION
	This function sets the reduction thresholds in the current module.

PARAMETERS
	surf_threshold (IN) - the surface reduction threshold
	curve_threshold (IN) - the curve reduction threshold

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.set_reduction_thresholds( surf_threshold, curve_threshold ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_set_reduction_thresholds */


/*--- VEdpb_get_last_bg_info -----------------------------------------*/

IGRint VEdpb_get_last_bg_info( last_server, last_user_name, last_password, last_results_file, last_start_time )

	IGRchar *last_server;
	IGRchar *last_user_name;
	IGRchar *last_password;
	IGRchar *last_results_file;
	IGRchar *last_start_time;

/*
NAME
	VEdpb_get_last_bg_info

DESCRIPTION
	This function gets the last background job information 
	from the current module.

PARAMETERS
	last_server (OUT) - the last server
	last_user_name (OUT) - the last user name
	last_password (OUT) - the last password
	last_results_file (OUT) - the last results file name
	last_start_time (OUT) - the last starting time

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.get_last_bg_info( last_server, last_user_name,
	                                                          last_password, last_results_file, last_start_time ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_get_last_bg_info */


/*--- VEdpb_set_last_bg_info -----------------------------------------*/

IGRint VEdpb_set_last_bg_info( last_server, last_user_name, last_password, last_results_file, last_start_time )

	IGRchar *last_server;
	IGRchar *last_user_name;
	IGRchar *last_password;
	IGRchar *last_results_file;
	IGRchar *last_start_time;

/*
NAME
	VEdpb_set_last_bg_info

DESCRIPTION
	This function sets the last background job information 
	in the current module.

PARAMETERS
	last_server (IN) - the last server
	last_user_name (IN) - the last user name
	last_password (IN) - the last password
	last_results_file (IN) - the last results file name
	last_start_time (IN) - the last starting time

GLOBALS USED
	none

HISTORY
	04/23/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts;
	OM_S_OBJID super_id;
	OMuword    super_os;

	VEget_dpb_super( &super_id, &super_os );

	sts = om$send( msg      = message VEdpb.set_last_bg_info( last_server, last_user_name, 
	                                                          last_password, last_results_file, last_start_time ),
	               targetid = super_id,
	               targetos = super_os,
	               senderid = NULL_OBJID );

	return( (sts == OM_S_SUCCESS) ? 0 : 1 );
	}  /* VEdpb_set_last_bg_info */

end implementation VEdpb;


