/*
 * This is the master .sl file for class ECconst and should be "sliced" by 
 * using the command -- $slic ECconst.sl.  This will produce the .S and .I 
 * files for ECconst.
 * See also the alternate command .sl files -->
 *
 *	ECcyl.sl -- "place cylinder by axis & radius",1
 *	ECsphere.sl -- "place sphere by center & radius",2
 *
 * The alternate command .sl files should be "sliced" by using the command
 * --  $slic -si ECxxxx.sl.  This will produce the state driver for the
 * alternate command object without writing over the .S and .I files
 * produced from ECconst.sl.  This methodology is used where possible to
 * replace branching on mytype within a command object.  All simple
 * placement commands can be implemented as ECconst commands in this way.
 * When new placement commands are created using this methodology, the
 * preceeding list of alternate command files should be updated as well as
 * the files ECmkmsg.h and ECmkmsgdef.h.
 */

command_string  "dummy construct",0
class           ECconst
super_class     ECcmd
product_name	"$MODEL"		/* (V 1.1) */
options			"Vt"
start_state  terminate

specification
/*
Abstract
	This class is an abstract command object class.  EMS command objects
	which construct a single new graphics object as a result of processing
	should be descendents of this class.  This includes placement commands 
	and some manipulation commands.

Notes
                          ANCESTRY 

                          Root

                          super_cmd

                          CEO

                          ECcmd

History

02-Jul-87 J. Brooke King Changed "some_string"
	kdb/dfh		02/01/87	creation date
	kdb  		02/23/87	completed adding states, 
					        changed argument lists for
                            EMstorepoint to match new list
    kdb/dhm     05/13/87    put all methods into one dummy state
    dhm         06/03/87    overrode the dynamics from ECcmd.
                            changed EMgenerl_construct to get the
                            construct and display environment. changed
                            EMdisplay_construst_lines to get display
                            environment.
    dhm			07/17/87	added the method init_construct.
	dhm			01/12/88	converted to 1.1.0.
*/

instance
{
  struct GRvg_construct	    construct_list;
  struct GRid 		    go_objid;
}


implementation
#include "EMS.h"
#include <OMobjectcomm.h>
#include <stdio.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <grdpbmacros.h>
#include <msdef.h>
#include <bserr.h>
#include <bsparameters.h>
#include <igrdef.h>
#include <ECmkmsgdef.h>
#include <ECmkmsg.h>
#include <ECcmd_def.h>
#include "emserr.h"

from GRgraphics import GRdisplay;


action init
{
/*
Notes
	This method is overriden by ECconst in order to initialize the 
	instance data of ECconst.

Assumption

Bugs

History
	dfh	02/02/87	initial version

Algorithm
	This method sends a message with respect to message to perform the
	parent class (ECcmd) init method and then gets the symbology, active 
	level, active display, and the database type.
*/

  IGRlong  msg;

  status = om$send(mode = OM_e_wrt_message,
                   msg = message ECcmd.init(type, str_ptr),
                   targetid = my_id);
  if (!(status & 1))
      goto quit;

 me->construct_list.msg = &me->ret;
 me->construct_list.env_info = NULL;
 me->construct_list.newflag = FALSE;
 me->construct_list.geometry =  NULL;
 me->construct_list.class_attr = NULL;
 me->construct_list.level = NULL;
 me->construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE
                                                | GRIS_NEW;
 me->construct_list.display = NULL;
 me->construct_list.name = NULL;

}


action init_construct
/*
Abstract
	This method gets the construction environment and the active default
	parameters.  It then initializes me->construct_list's env_info,
	level, and display components of its structure.  This is used before
	doing constructs.

Notes
	For an example of usage see the method EMgeneral_construct below.

Arguments
	sts		pointer to an error return code.

History
	dhm		7/17/87
*/
{
  struct EX_button  button;
  IGRlong   size, num_bytes;

  button.x = me->point[0][0];
  button.y = me->point[0][1];
  button.z = me->point[0][2];
  size = sizeof(struct GRmd_env);
  
  gr$get_construct_env(msg = sts,
                       point = &button,
                       sizbuf = &size,
                       buffer = &me->ModuleInfo,
                       nret = &num_bytes);
  EMerr_hndlr(EMis_error(*sts), status, OM_E_ABORT, quit);

  status = om$send(mode = OM_e_wrt_message,
                   msg = message ECcmd.EMget_active_dpb(sts),
                   senderid = my_id,
                   targetid = my_id);
  EMomerr_hndlr(status, quit, "EMget_active_dpb error");
  EMerr_hndlr(EMis_error(*sts), status, OM_E_ABORT, quit);

  me->construct_list.env_info = &me->ModuleInfo;
  me->construct_list.level = me->ActiveLevel;
  me->construct_list.display = &me->ActiveDisplay;

}


action EMdisplay_construct_lines (IGRlong *msg;
		 		  IGRint num_pnts;
				  IGRpoint *point; 
				  enum GRdpmode display_mode)

/*
Notes
	Input 
	--------
	IGRint num_pnts -- actual number of points in point set

	IGRpoint *point -- The point set array is always passed to this
	  routine as the address of the first element of the array, i.e. 
	  ME.command_object->point, point, etc., where point is an array
	  of type IGRpoint.

	enum GRdpmode display mode  -- This parameter controls how the 
	  construction lines should be displayed. (See exec/include/dp.h 
	  for possible values.)

	Output
	------
	IGRlong *msg -- Return error codes for method.
			EMS_S_Success -- display was successful
			EMS_E_InvalidArg -- invalid arguments

	Returns an OM_S_SUCCESS if successful.  Returns the failed OM 
	message if unsuccessful.

Assumption

Bugs

History
        kdb		2/1/1987		initial version.

Algorithm
	This routine is used for locally displaying construction
	lines using a set of points.
	This method calls the function ECdisplayPointSetByBuffer0 to
	display the construction lines.  It is necessary to have this
	method declared rather than calling the function directly because 
	of a limitation of COB.
*/ 

{
  IGRlong	ECdisplayPointSetByBuffer0();
 
  *msg = MSSUCC;

  status = om$send(mode = OM_e_wrt_message,
                   msg = message ECcmd.EMget_active_dpb(msg),
                   senderid = my_id,
                   targetid = my_id);
  EMomerr_hndlr(status, quit, "EMget_active_dpb error");
  EMerr_hndlr(EMis_error(*msg), status, OM_E_ABORT, quit);

  ECdisplayPointSetByBuffer0(msg, me->ActiveDisplay,
				  me->ModuleInfo, my_id, num_pnts, 
				  point, display_mode, IGRPY);
  EMerr_hndlr(EMis_error(*msg), status, OM_E_ABORT, quit);

}
