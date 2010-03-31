
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSgragad;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <tools.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "msdef.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "hswinmacros.h"
#include "hsurferrpriv.h"

#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"

%safe
#include "HSpr_gragad.h"
%endsafe

extern OMuword OPP_IGEgragad_class_id;

/*--- HSconnect_instance_to_gragad --------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRlong HSconnect_instance_to_gragad( IGRlong *msg,
					   OM_S_OBJID inst_id,
					   OM_S_OBJID win_id,
					      OMuword win_os )
#else
	IGRlong HSconnect_instance_to_gragad( msg, inst_id, win_id, win_os )

	IGRlong    *msg;
	OM_S_OBJID inst_id;
	OM_S_OBJID win_id;
	OMuword    win_os;
#endif

/*
DESCRIPTION
	This function connects a HSinstance object to an IGEgragad.
	If a failure occurs, *msg is set to MSFAIL.  Otherwise, *msg
	is set to MSSUCC.

HISTORY
	S.P. Rogers  02/16/90  Creation Date
*/

	{
	IGRlong         sts;
	OM_S_CHANSELECT to_support;
	OM_S_CHANSELECT to_gragad;

	*msg = MSSUCC;

	/* connect HSinstance object to slot 0 of the gragad's instance data support channel */
	sts = om$make_chanselect( channame = "HSinstance.to_gragad", p_chanselect = &to_gragad );

	   OM_ERRCHK( sts, "HSconnect_instance_to_gragad:  om$make_chanselect for HSinstance failed" );

	sts = om$make_chanselect( channame = "IGEgragad.inst_support", p_chanselect = &to_support );

	   OM_ERRCHK( sts, "HSconnect_instance_to_gragad:  om$make_chanselect for IGEgragad failed" );

	sts = om$send( msg      = message Root.connect( to_gragad, 0,
	                                                win_id, win_os,
	                                                to_support, NULL ),
	               senderid = win_id,
	               targetid = inst_id,
	               targetos = win_os );
	               
	   OM_ERRCHK( sts, "HSconnect_instance_to_gragad:  Root.connect failed" );

	if ( sts != OM_S_SUCCESS )
	   *msg = MSFAIL;

	return( (*msg == MSSUCC) ? 0 : 1 );

	}  /* HSconnect_instance_to_gragad */


/*--- HSget_saved_instance_id ---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRlong HSget_saved_instance_id( IGRlong *msg,
				      OM_S_OBJID win_id,
				         OMuword win_os,
				      OM_S_OBJID *instance_id )
#else
	IGRlong HSget_saved_instance_id( msg, win_id, win_os, instance_id )

	IGRlong    *msg;
	OM_S_OBJID win_id;
	OMuword    win_os;
	OM_S_OBJID *instance_id;
#endif

/*
DESCRIPTION
	This function finds the object id of a HSinstance object that is
	attached to a gragad.  If the gragad doesn't have a HSinstance object
	attached to it, the object id is set to NULL_OBJID.  If (win_id,win_os)
	is not a subclass of IGEgragad (i.e., not a window), *msg is set
	to MSFAIL.

HISTORY
	S.P. Rogers  02/12/90  Creation Date
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

	   OM_ERRCHK( sts, "HSget_saved_instance_id: om$make_chanselect failed" );
	
	sts = om$get_objid_at_index( osnum = win_os,
	                             objid = win_id,
	                             p_chanselect = &to_support,
	                             index = 0,
	                             objidaddr = &temp_objid,
	                             osnumaddr = &temp_osnum );

	if ( sts == OM_S_SUCCESS )
	   *instance_id = temp_objid;

	return( (*msg == MSSUCC) ? 0 : 1 );

	}  /* HSget_saved_instance_id */


/*--- HSsave_instance --------------------------------------------*/

method HSsave_instance( IGRlong *msg )

/*
DESCRIPTION
	This method saves the instance data of a HS gragad by constructing a
	copy of itself, changing the class of the copy to HSinstance and
	then connecting the HSinstance object to its window support channel
	that is defined by IGEgragad.

HISTORY
	S.P. Rogers  02/12/90  Creation Date
*/

	{
	IGRlong         sts;
	OM_S_OBJID      inst_id;

	*msg = MSSUCC;

	/* construct and copy myself */
	sts = om$construct_and_copy( objid = my_id, p_objid = &inst_id );

	   OM_ERRCHK( sts, "HSsave_instance:  om$construct_and_copy failed" );

	/* change class of copy to HSinstance */
	sts = om$change_class( objid = inst_id, classname = "HSinstance" );

	   OM_ERRCHK( sts, "HSsave_instance:  om$change_class failed" );

	HSconnect_instance_to_gragad( msg, inst_id, my_id, OM_Gw_current_OS );

	return( OM_S_SUCCESS );

	}  /* HSsave_instance */


/*--- HSrestore_instance --------------------------------------------*/

method HSrestore_instance( IGRlong *msg )

/*
DESCRIPTION
	This method restores the instance data of a HS gragad.  If the HSgragad
	has a HSinstance object attached, its data is copied to the HSgragad
	and it is deleted.  If the HS gragad doesn't have a HSinstance object
	attached, default instance data is loaded into the HSgragad.

HISTORY
	S.P. Rogers  02/12/90  Creation Date
*/

	{
	IGRlong                        sts;
	OM_S_OBJID                     inst_id;
	IGRlong                        which_error;
	IGRlong                        ret_bytes;
	struct HStotal_window_instance total_instance;
	struct var_list                var_list[2];

	*msg = MSSUCC;

	var_list[0].var            = HS_TOTAL_INSTANCE;
	var_list[0].var_ptr        = (IGRchar *) &total_instance;
	var_list[0].num_bytes      = sizeof( struct HStotal_window_instance );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	hs$get_saved_instance_id( msg = msg,
	                          win_id = my_id,
	                          instance_id = &inst_id );

	if ( inst_id == NULL_OBJID )
	   {
	   /* get default instance data and copy it into my instance data */
	   HSget_default_instance( msg, &which_error, var_list );
	   }
	else
	   {
	   /* get the instance data from the HSinstance object */
	   /* and copy it into my instance data                */
	   hs$get_window_instance_data( msg = msg,
	                                win_id = inst_id,
	                                which_error = &which_error,
	                                var_list = var_list );

	   /* delete the instance object */
	   sts = om$send( msg      = message Root.delete( 0 ),
	                  targetid = inst_id );

	      OM_ERRCHK( sts, "HSrestore_instance: Root.delete failed" );
	   }

	hs$set_window_instance_data( msg = msg,
	                             win_id = my_id,
	                             which_error = &which_error,
	                             var_list = var_list );

	return( OM_S_SUCCESS );
	}  /* HSrestore_instance */
	   
end implementation HSgragad;
