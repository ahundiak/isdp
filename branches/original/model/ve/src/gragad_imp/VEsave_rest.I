
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

class implementation VEgragad;

#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "OMerrordef.h"

#include "msdef.h"

#include "vewinmacros.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_gragad.h"

extern OMuword OPP_IGEgragad_class_id;

/*--- VEconnect_instance_to_gragad --------------------------------------------*/

IGRlong VEconnect_instance_to_gragad( IGRlong    *msg,
				      OM_S_OBJID inst_id,
				      OM_S_OBJID win_id,
				      OMuword    win_os )

/*
NAME
	VEconnect_instance_to_gragad

DESCRIPTION
	This function connects a VEinstance object to an IGEgragad.
	If a failure occurs, *msg is set to MSFAIL.  Otherwise, *msg
	is set to MSSUCC.

PARAMETERS
	msg (OUT) - status return
	inst_id (IN) - object id of instance object to connect to the IGEgragad
	win_id (IN) - object id of the IGEgragad
	win_os (IN) - object space number of the IGEgragad

RETURN VALUES
	0 - if successful
	1 - otherwise

GLOBALS USED
	none

HISTORY
	02/16/90    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong         sts;
	OM_S_CHANSELECT to_support;
	OM_S_CHANSELECT to_gragad;

	*msg = MSSUCC;

	/* connect VEinstance object to slot 1 of the gragad's instance data support channel */
	sts = om$make_chanselect( channame = "VEinstance.to_gragad", p_chanselect = &to_gragad );

	   OM_ERRCHK( sts, "VEconnect_instance_to_gragad:  om$make_chanselect for VEinstance failed" );

	sts = om$make_chanselect( channame = "IGEgragad.inst_support", p_chanselect = &to_support );

	   OM_ERRCHK( sts, "VEconnect_instance_to_gragad:  om$make_chanselect for IGEgragad failed" );

	sts = om$send( msg      = message Root.connect( to_gragad, 1,
	                                                win_id, win_os,
	                                                to_support, NULL ),
	               senderid = win_id,
	               targetid = inst_id,
	               targetos = win_os );
	               
	   OM_ERRCHK( sts, "VEconnect_instance_to_gragad:  Root.connect failed" );

	if ( sts != OM_S_SUCCESS )
	   *msg = MSFAIL;

	return( (*msg == MSSUCC) ? 0 : 1 );
	}  /* VEconnect_instance_to_gragad */


/*--- VEget_saved_instance_id ---------------------------------------*/

IGRlong VEget_saved_instance_id( IGRlong    *msg,
				 OM_S_OBJID win_id,
				 OMuword    win_os,
				 OM_S_OBJID *instance_id )

/*
NAME
	VEget_saved_instance_id

DESCRIPTION
	This function finds the object id of a VEinstance object that is
	attached to a gragad.  If the gragad doesn't have a VEinstance object
	attached to it, the object id is set to NULL_OBJID.  If (win_id,win_os)
	is not a subclass of IGEgragad (i.e., not a window), *msg is set
	to MSFAIL.

PARAMETERS
	msg (OUT) - status return
	win_id (IN) - object id of the IGEgragad
	win_os (IN) - object space number of the IGEgragad
	instance_id (IN) - object id of instance object connected to the
	                   IGEgragad

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
	IGRlong         sts;
	OMuword         classid;
	OMuword         temp_osnum;
	OM_S_OBJID      temp_objid;
	OM_S_CHANSELECT to_support;

	om$get_classid( objid = win_id, osnum = win_os, p_classid = &classid );

	if ( om$is_ancestry_valid( subclassid = classid,
	                           superclassid = OPP_IGEgragad_class_id ) != OM_S_SUCCESS )
	   {
	   /* object isn't a window */
	   *instance_id = NULL_OBJID;
	   *msg = MSFAIL;
	   return( 1 );
	   }

	*msg = MSSUCC;
	*instance_id = NULL_OBJID;

	/* get the channel objects of the window */
	sts = om$make_chanselect( channame = "IGEgragad.inst_support", p_chanselect = &to_support );

	   OM_ERRCHK( sts, "VEget_saved_instance_id: om$make_chanselect failed" );
	
	sts = om$get_objid_at_index( osnum = win_os,
	                             objid = win_id,
	                             p_chanselect = &to_support,
	                             index = 1,
	                             objidaddr = &temp_objid,
	                             osnumaddr = &temp_osnum );

	if ( sts == OM_S_SUCCESS )
	   *instance_id = temp_objid;

	return( (*msg == MSSUCC) ? 0 : 1 );
	}  /* VEget_saved_instance_id */


/*--- VEsave_instance --------------------------------------------*/

method VEsave_instance( IGRlong *msg )

/*
NAME
	VEgragad.VEsave_instance

DESCRIPTION
	This method saves the instance data of a VE gragad by constructing a
	copy of itself, changing the class of the copy to VEinstance and
	then connecting the VEinstance object to its window support channel
	that is defined by IGEgragad.

PARAMETERS
	msg (OUT) - status return

GLOBALS USED
	none

HISTORY
	02/12/90    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong         sts;
	OM_S_OBJID      inst_id;

	*msg = MSSUCC;

	/* construct and copy myself */
	sts = om$construct_and_copy( objid = my_id, p_objid = &inst_id );

	   OM_ERRCHK( sts, "VEsave_instance:  om$construct_and_copy failed" );

	/* change class of copy to VEinstance */
	sts = om$change_class( objid = inst_id, classname = "VEinstance" );

	   OM_ERRCHK( sts, "VEsave_instance:  om$change_class failed" );

	VEconnect_instance_to_gragad( msg, inst_id, my_id, OM_Gw_current_OS );

	return( OM_S_SUCCESS );

	}  /* VEsave_instance */


/*--- VErestore_instance --------------------------------------------*/

method VErestore_instance( IGRlong *msg )

/*
NAME
	VEgragad.VErestore_instance

DESCRIPTION
	This method restores the instance data of a VE gragad.  If the VEgragad
	has a VEinstance object attached, its data is copied to the VEgragad
	and it is deleted.  If the VE gragad doesn't have a VEinstance object
	attached, default instance data is loaded into the VEgragad.

PARAMETERS
	msg (OUT) - status return

GLOBALS USED
	none

HISTORY
	02/12/90    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             sts;
	OM_S_OBJID          inst_id;
	IGRlong             which_error;
	IGRlong             ret_bytes;
	struct VEbatch_info batch_info;
	struct var_list     var_list[2];

	*msg = MSSUCC;

	var_list[0].var            = VE_BATCH_INFO;
	var_list[0].var_ptr        = (IGRchar *) &batch_info;
	var_list[0].num_bytes      = sizeof( struct VEbatch_info );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	ve$get_saved_instance_id( msg = msg,
	                          win_id = my_id,
	                          instance_id = &inst_id );

	if ( inst_id == NULL_OBJID )
	   {
	   /* get default instance data and copy it into my instance data */
	   VEget_default_instance( msg, &which_error, var_list );
	   }
	else
	   {
	   /* get the instance data from the VEinstance object */
	   /* and copy it into my instance data                */
	   ve$get_window_instance_data( msg = msg,
	                                win_id = inst_id,
	                                which_error = &which_error,
	                                var_list = var_list );

	   /* delete the instance object */
	   sts = om$send( msg      = message Root.delete( 0 ),
	                  targetid = inst_id );

	      OM_ERRCHK( sts, "VErestore_instance: Root.delete failed" );
	   }

	ve$set_window_instance_data( msg = msg,
	                             win_id = my_id,
	                             which_error = &which_error,
	                             var_list = var_list );

	return( OM_S_SUCCESS );
	}  /* VErestore_instance */
	   
end implementation VEgragad;
