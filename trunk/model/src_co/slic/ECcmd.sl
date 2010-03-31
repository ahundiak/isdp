command_string  "ECcmd parent"
class           ECcmd
super_class     CEO_LOCATE
product_name	"$MODEL"	/* (V 1.1) */
options			"Vt"
start_state  terminate


specification
/*
Abstract
	This class is an abstract command object class.  EMS command objects
	which store data button points and objects should be descendents of
    this class.  This includes placement commands and most manipulation
    commands.

Notes
						ANCESTRY 

						Root

						super_cmd
	
						CEO_LOCATE

History

	sjv	12/15/87	V 1.1 change in struct GRevent;
				event1.event.value.value to event1.event.value

				DYrblineseg to EFrblineseg in action dynamics

				CObrln_mod to EFboreline in action EMstorepoint

02-Jul-87 J. Brooke King Changed "some_string"
	kdb/dfh		02/01/87	creation date
	kdb			03/05/87	added symbology and display
							information
	kdb			03/18/87	changed point and value to VLA
    kdb			04/13/87	added methods EMsave_located_object
										  EMpush_button_on_stack
    dhm         05/13/87    converted it to COB and put all methods
                            in the .sl file
    dhm			06/03/87    added EMget_active_dpb and EMset_up_dyn_pnt.
                            changed the init and changed dynamics.
	dhm			07/17/87	changed me->value[0] in EMstorepoint to
                            me->value[me->num_values].
	dhm			01/12/88	converted to 1.1.0.
    dhm         6/1/88      added Jeff J.'s code.
*/

instance
{
  variable IGRdouble  	value[];  /* array of values */
  variable IGRpoint   	point[];  /* array of points */
  IGRdouble		tol;              /* tolerance for BSEXTRACTPAR    */
  IGRint		num_values;       /* number of values in the array */
  IGRint		num_points;       /* number of points in the array */
  struct GRlc_info          located_obj[10]; /* locate info for objects */
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
#include <bsparameters.h>
#include <bserr.h>
#include <ECcmd_def.h>
#include "emserr.h"

from GRgraphics import GRlnproject;
from GRgraphics import GRptproject;


action init
{
/*
Notes
	This method is overriden by ECcmd in order to extract the global
	tolerance value, active display, symbology, active level, and
	database type.  The variable length arrays for point and value
	are also initially dimensioned here.

Assumption

Bugs

History
	dfh	02/02/87	initial version
	kdb	03/18/87	added changes for variable length arrays
                    point and value
	dhm 01/13/88	converted for 1.1.0

Algorithm
	This method dimensions the VLAs point and value, sends a message 
	with respect to message to perform the parent class (CEO) init 
	method, extracts the tolerance using BSEXTRACTPAR, extracts the 
	active display, symbology, active level, and database type.
*/


  IGRlong  msg;
  IGRlong  NumberOfBytes, BytesReceived;

  me->num_points = 0;
  me->num_values = 0;

  status = om$send(mode = OM_e_wrt_message,
                   msg = message CEO_LOCATE.init(type, str_ptr),
                   targetid = my_id);
  EMomerr_hndlr(status, quit, "Send to CEO_LOCATE.init error");

  status = om$vla_set_dimension(varray = me->point, size = 10);
  EMomerr_hndlr(status, quit, "om$vla_set_dimension point error");

  status = om$vla_set_dimension(varray = me->value, size = 10);
  EMomerr_hndlr(status, quit, "om$vla_set_dimension point error");


  status = BSEXTRACTPAR(&msg, BSTOLLENVEC, me->tol);
  EMerr_hndlr((!status), status, OM_E_ABORT, quit);

}


action EMget_active_dpb
/*
Abstract
	This method get the active level, active display, active scale,
    and active angle.

Arguments
	*sts	int		return status field

Files
	ECcmdi.I, ECcmd.sl

History
	dfh		05/26/87	creation date
*/

{
  IGRlong  NumberOfBytes, BytesReceived;

  NumberOfBytes = sizeof(me->ActiveDisplay);
  gr$get_active_display(msg = &status,
                         sizbuf = &NumberOfBytes,
                         buffer = &me->ActiveDisplay,
                         nret = &BytesReceived );
  EMerr_hndlr(EMis_error(status), status, OM_E_ABORT, quit);
 
  NumberOfBytes = sizeof(me->ActiveLevel);
  gr$get_active_level(msg = &status,
                       sizbuf = &NumberOfBytes,
                       buffer = &me->ActiveLevel,
                       nret = &BytesReceived );
  EMerr_hndlr(EMis_error(status), status, OM_E_ABORT, quit);

  NumberOfBytes = sizeof(me->ActiveAngle);
  gr$get_active_angle(msg =  &status,
                      sizbuf = &NumberOfBytes,
                      buffer = &me->ActiveAngle,
                      nret = &BytesReceived);
  EMerr_hndlr(EMis_error(status), status, OM_E_ABORT, quit);

  NumberOfBytes = sizeof(me->ActiveScale);
  gr$get_active_scale(msg =  &status,
                      sizbuf = &NumberOfBytes,
                      buffer = &me->ActiveScale,
                      nret = &BytesReceived);
  EMerr_hndlr(EMis_error(status), status, OM_E_ABORT, quit);

}


action dynamics
/*
Abstract
	This method handles the dynamics for command objects.

Arguments
    dynamics int    selector switch for dynamics cases
	*sts	 int	return status field

Files
	ECcmdi.I, ECcmd.sl

History
	dfh		05/26/87	creation date
*/

{
  IGRpoint	dyn_point;	/* V 1.1, for EFrblineseg */

  *sts = OM_S_SUCCESS;
  switch (dynamics)
    {
      case off:
        break;
      case line:
        status = om$send(mode = OM_e_wrt_object,
                         msg = message ECcmd.EMget_active_dpb((IGRlong *) sts),
                         senderid = my_id,
                         targetid = my_id);
        EMomerr_hndlr(status, quit, "EMget_active_dpb error");
        dyn_point[ 0 ] = me -> event1.event.button.x;
        dyn_point[ 1 ] = me -> event1.event.button.y;
        dyn_point[ 2 ] = me -> event1.event.button.z;
        EFrblineseg( dyn_point, &me->ActiveDisplay );
        break;
      default:
        *sts = OM_E_ABORT;
        break;
    }
}


action EMsubtract_point
{
/*
Abstract
	This method subtracts one from num_points in ECcmd instance data.
	This is to be used if the command object does a reset back to a 
	state that had previously stored a point using EMstorepoint.

Arguments
	sts -- return code field.

Return Values
	Always returns a MSSUCC.

Files
	EMsubpnt.I

History
	dfh		03/11/87	Creation date.

*/

	*sts = MSSUCC;
	--me->num_points;

}


action EMsubtract_value
{
/*
Abstract
	This method subtracts one from num_values in ECcmd instance data.
	This is to be used if the command object does a reset back to a 
	state that had previously stored a value using EMstorevalue.

Arguments
	sts -- return code field.

Return Values
	Always returns a MSSUCC.

Files
	EMsubval.I

History
	dfh		03/11/87	Creation date.
*/

	*sts = MSSUCC;
	--me->num_values;

}


action EMstorepoint(IGRlong *msg;
                    IGRint type_store; 
                    IGRint check; 
                    GRobjid obj_id;
                    struct GRparms *prj_parms)
{
/*
Notes
	INPUT 
	--------
	struct GRevent event -- The command object should pass the event
	  returned from the input event.  This event will generally be 
	  contained in CEO's instance data.

	IGRint type_store -- This parameter is a flag used by the command
	  object to indicate whether the point should be stored directly 
	  from the event or projected onto an element.  The possible values
	  for this parameter are:
		 reg_input:    to store the point directly.
		 brln_input:   to project the point using a boreline.
		 ptprj_input:  to use a point project.
	  A NULL should be passed in when the command object doesn't want to 
	  store a point, but wants to check for an error or either wants
	  to have the length returned only.  These values are in the file
	  ECcmd_def.h. 

	IGRint check -- This parameter is used as a flag by the command
	  object to indicate whether the point should be validated for
	  uniqueness or against a tolerance value.  The possible values 
	  for this parameter are a:
		 unique:     to check the point for uniqueness (using the math
		   			 function BSdistncta).
		 distptpt:   to check the point against a tolerance using the
		 		     function BSdistptpt.
		 distptli:   to check the point against a tolerance using
		   			 the function BSdistptli.
	  A NULL should be passed when the command object
	  does not wish to validate the point or wishes to perform a
	  different validation check within its own method.  These values are
	  found in the files ECcmd_def.h

	GRobjid obj_id -- This parameter should contain the object id of
	  the element onto which a boreline or point project is to be done
	  (generally this is an object which has been located).  When the 
	  command object specifies a direct store of the event point obj_id
	  should be passed as NULL.


	OUTPUT
	--------
	IGRlong *msg -- Return error codes for the method.  MSINARG is used
	  if the check for uniquessness or tolerance fails.  MSFAIL is used
	  for all other cases.

	struct GRparms *prj_parms -- The projected parameters are returned
	  to the command object when the command object specifies that a
	  boreline or point project be done.  This parameter must be
	  passed in as the address of an actual variable of type struct
	  GRparms regardless of whether the command object intends to use
	  the parameters or not.  Currently the command objects more
	  frequently use the parameters of the projected point rather than
	  the actual point.  When the event is stored directly, this
	  parameter should be passed in as NULL.

	IGRpoint ln_pnt -- This is the point on the line which is used to
	  project a point onto the element during a boreline project.
	  It is included as a parameter in case a command object might 
	  need this point.  This parameter should be passed in as NULL 
	  when the event is stored directly.

	Returns an OM_S_SUCCESS if successful.  Returns the failed OM 
	message if unsuccessful.

Assumption

Bugs

History
   	kdb/dfh	12/23/1986  initial version.
	dfh		12/29/87	added msg to parameters and
						error values.
	kdb		01/05/87	changed format of program
						to 2 separate switch statements.
	kdb/dfh	01/05/87	added more cases to check.
	dfh		01/12/87	added length parameter.
	kdb		01/30/87	added null case to store
					    switch.  changed check
						for distance between
						a point and another point
						or a line to use event.event.button 
						as the current point.
	kdb		03/09/87	modified to use OM_BLOCK_MOVE
    dhm     05/13/87    added EMerr_hndlr and EMomerr_hndlr
    dhm     6/1/88      changed arguments.

Algorithm
	This method is used for storing the data points returned from 
	GRget_event into the instance data of a command object.  This 
	method will store points directly from the event or will project 
	the point using the boreline project routine GRlnproject or the
	point project routine GRptproject.
	Based on input parameters from the command object, the method
	switches to store points directly from the event, store them
	using a boreline project, or store them using a point project.  
	The command object also has the option to specify that the point 
	currently being stored be checked against all previous point(s) 
	for uniqueness or that it be checked for being within a tolerance 
	of the previous point or a line defined by the two previous points.
*/


  IGRint		index;
  IGRint		size_pnt = sizeof(IGRpoint);
  struct IGRline	boreline;
  IGRdouble		t;
  extern IGRdouble BSdistptpt();
  IGRlong		sts, msg1, num_elements;
  IGRpoint		pnt1, pnt2;
  extern IGRboolean		BSdistncta(), BSdistptli();
  struct GRmd_env	module_info; /* V 1.1 for passing the osnum */
  IGRpoint          ln_pt;

  *msg = MSSUCC;
  module_info = me->event1.located_object[0].module_info; /* V 1.1 */

  me->num_points = me->num_points + 1;
  index = me->num_points - 1;

  num_elements = om$dimension_of(varray = me->point);
  if (me->num_points > num_elements)
  {
      status = om$vla_set_dimension(varray = me->point,
				   size = num_elements + 1);
      EMomerr_hndlr(status, wrapup, "om$vla_set_dimension point error");
  }

  switch (type_store)
  {

	case NULL:
	{
		break;	/*  This is for those cases when the command
				 *  object only wants a length value computed
				 *  from the current point.  This length value
				 *  is computed when a check is done for the
				 *  distance between a point and another point
				 *  or a line.  The length value is stored
                 *  in the instance data in value[i].
				 */
	}


	case reg_input:
	{
		OM_BLOCK_MOVE(&me->event1.event.button, &me->point[index][0],
                      size_pnt);

		break;

	 }  /* END CASE REG_INPUT  */


	case brln_input:
	{
		boreline.point1 = pnt1;  /* allocates storage for */
		boreline.point2 = pnt2;  /* the boreline          */

		sts = EFboreline(&msg1, my_id, &me->event1, &boreline);

        EMerr_hndlr(EMis_error(sts) || EMis_error(msg1), *msg, MSFAIL,
                    wrapup);

		prj_parms->u = 5.0;  /* KLUDGE for tolerance.  IGE (Wings?)
                                has yet to fix this. */

		status = om$send(mode = OM_e_wrt_object,
			 	 msg = message GRgraphics.GRlnproject(&msg1,
					&module_info.md_env.matrix_type,
					module_info.md_env.matrix,
					&boreline, ln_pt, 
					me->point[index], &t, 
					prj_parms),
				 senderid = my_id,
				 targetid = obj_id,
				 targetos = module_info.md_id.osnum /* V 1.1 */
				 );
        EMomerr_hndlr(status, wrapup, "GRgraphics.GRlnproject");
        EMerr_hndlr(EMis_error(msg1), *msg, MSFAIL, wrapup);

		break;

	}   /* END CASE BRLN_INPUT */


	case ptprj_input:
	{
		status = om$send(mode = OM_e_wrt_object,
			  	 msg = message GRgraphics.GRptproject(&msg1,
					&module_info.md_env.matrix_type,
					module_info.md_env.matrix,
					&me->event1.event.button.x, 
					me->point[index],prj_parms),
				 senderid = my_id,
				 targetid = obj_id,
				 targetos = module_info.md_id.osnum); /* V 1.1 */
        EMomerr_hndlr(status, wrapup, "GRgraphics.GRptproject");
        EMerr_hndlr(EMis_error(msg1), *msg, MSFAIL, wrapup);

		break;

	}   /* END CASE PTPRJ_INPUT */


	default:
		*msg = MSFAIL;
		goto wrapup;

  }  /* END SWITCH TYPE_STORE */


  switch (check)
  {
	case unique:
	{
        sts = BSdistncta(me->num_points, me->point, &msg1);
        EMerr_hndlr(!sts, *msg, MSINARG, wrapup);

        break;

	}   /*  END CASE UNIQUE  */


	case distptpt:
	{
        me->value[me->num_values] = BSdistptpt(&msg1, me->point[index-1],
				                  &me->event1.event.button.x);
        EMerr_hndlr(BSERROR(msg1), *msg, MSFAIL, wrapup);

       	if (me->value[me->num_values] < me->tol)
        {
           *msg = MSINARG;
           goto wrapup;
        }

        me->num_values++;
       	break;

	} /*  END CASE DISTPTPT  */


	case distptli:
	{
		sts = BSdistptli(&msg1, &me->event1.event.button.x,
			             me->point[index-2], me->point[index-1], 
				         &me->value[me->num_values]);
        EMerr_hndlr(BSERROR(msg1), *msg, MSFAIL, wrapup);

		if (me->value[me->num_values] < me->tol)
        {
           *msg = MSINARG;
           goto wrapup;
        }

        me->num_values++;
		break;

	} /*  END CASE DISTPTLI  */

	default :
		goto quit;

  }  /*  END SWITCH CHECK  */

  goto quit;  /* only want to go to wrapup on an error */

wrapup:
  --me->num_points;
}


action EMstorevalue(
		IGRlong *msg; 			/* see notes section for */
		IGRint check;			/* full description of   */
		IGRdouble high;			/* method arguments      */
		IGRdouble low)
{
/*
Notes
	Input 
	--------
	IGRint check -- Type of check to perform. Possible values are
		1 -- less than
		2 -- less than or equal
		3 -- greater than
		4 -- greater than or equal
		5 -- within a range (inclusive)
		6 -- outside a range (inclusive)

	IGRdouble high -- high value 

	IGRdouble low -- low value 


	Output
	--------
	IGRlong *msg -- Return error codes for the method.  MSFAIL is returned
	  if the test condition is not met.

	Returns an OM_S_SUCCESS if successful.  Returns the failed OM 
	message if unsuccessful.

Assumption
	When using this routine, the positive test should be used, i.e. if
	the value is correct if it is greater than a tolerance, this routine
	should be referenced as -- 
	ECcmd.EMstorevalue(&me->ret, greater_than, 0, me->tol).

	The value is checked against low, which is the last argument, when 
	the test is greater_than or greater_than_equal.  The value is checked 
	against high, which is the next to last argument, when the test is
	less_than or less_than_equal.

	When checking for in range or outside a range, it is assumed that
	the check is inclusive, i.e. that in range is checking for 
	low <= event.event.value <= high and outside range is checking for
	event.event.value > high or event.event.value < low.

Bugs

History
	kdb		02/14/87	initial version.
	kdb		03/13/87	corrected to decrement counter
						num_values if the store fails.
	dhm     05/13/87    added EMomerr_hndlr.
	dhm		06/11/87	corrected cases less_than and greater_than.

Algorithm
	This method is used for storing keyed in values returned from 
	GRget_event into the instance data of a command object.  The 
	value can be checked against a high and/or low value to determine
	whether or not the value falls within a range or meets tolerance
	requirements, etc.
*/


  IGRint		  index;
  IGRlong		  num_elements;

  me->num_values = me->num_values + 1;
  *msg = MSSUCC;
  index = me->num_values - 1;  /* number of values in the array */

  num_elements = om$dimension_of(varray = me->value);
  if (me->num_points > num_elements)
  {
      status = om$vla_set_dimension(varray = me->value,
				   size = num_elements + 1);
      EMomerr_hndlr(status, quit, "om$vla_set_dimension value error");

  }


  switch (check)
  {

	case NULL:
	{
		break;
	}


	case less_than:
	{
		if (me->event1.event.value >= high) 
		{
		   --me->num_values;
		   *msg = MSFAIL;
		}
		else me->value[index] = me->event1.event.value;

		break;
	}


	case less_than_equal:
	{
		if (me->event1.event.value > high) 
		{
		   --me->num_values;
		   *msg = MSFAIL;
		}
		else me->value[index] = me->event1.event.value;

		break;
	}   /* END CASE LESS_THAN_EQUAL */


	case greater_than:
	{
		if (me->event1.event.value <= low)
		{
		   --me->num_values;
		   *msg = MSFAIL;
		}
		else me->value[index] = me->event1.event.value;
	
		break;
	}


	case greater_than_equal:
	{
		if (me->event1.event.value < low)
		{
		   --me->num_values;
		   *msg = MSFAIL;
		}
		else me->value[index] = me->event1.event.value;
	
		break;
	}   /* END CASE GREATER_THAN_EQUAL */


	case outside_range:
	{
		if ((me->event1.event.value <= high)
		   && (me->event1.event.value >= low))
		{
		   --me->num_values;
		   *msg = MSFAIL;
		}
		else
		   me->value[index] = me->event1.event.value;
		
		break;
	}   /* END CASE OUTSIDE_RANGE */


	case in_range:
	{
		if ((me->event1.event.value < low )
		   || (me->event1.event.value > high))
		{
		   --me->num_values;
		   *msg = MSFAIL;
		}
		else 
		   me->value[index] = me->event1.event.value;

        break;
	}   /* END CASE IN_RANGE */


	default:
		--me->num_values;
		*msg = MSINARG;
		goto quit;

  }  /* END SWITCH CHECK */

}


action EMsave_located_object(struct GRevent *event;
							 struct GRlc_info *located_object)
{
/*
Notes

Assumption

Bugs

History
	kdb			04/13/87		initial version.
    dhm         6/1/88          changed argument to be *event.
Algorithm
*/


  *located_object = event->located_object[0];

}


action EMpush_button_on_stack(struct GRevent *event)
{
/*
Notes

Assumption

Bugs

History
	kdb			04/13/87		initial version.

Algorithm
*/


  IGRlong	qsize;

  qsize = sizeof(event->event);
  status = ex$putque(msg = &me->ret,
		 		     response = me->response,
				     byte = &qsize,
				     buffer = (char *) &event->event);
  EMerr_hndlr(EMis_error(me->ret), status, OM_E_ABORT, quit);

}


action EMset_up_dyn_pnt
/*
Abstract
	This method puts the current point (ME.ECcmd->point) into
	ME.CEO->event1 so that the dynamics routine can do line dynamics
	off of it.

Arguments
	*sts	IGRlong		returns MSSUCC
	
Files
	ECcmd.sl, ECcmdi.I

History
	dfm		05/28/87	creation date
*/
{
  IGRint	index;

  *sts = MSSUCC;
  index = me->num_points - 1;

  me->event1.event.button.x = me->point[index][0];
  me->event1.event.button.y = me->point[index][1];
  me->event1.event.button.z = me->point[index][2];

}


action arg_name_to_value
	/* Incoming */
/*  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
/*  char	* class_name;	/* not NULL => argname used to start  */
				/*   with "me(class_name)->" of some  */
				/*   form; now this has been stripped */
				/* NULL => original arg had no "me->" */
/*  char  	* arg;		/* arg string to find a value for     */
	/* Outgoing */
/*  COB_arg_union * data;	/* value of arg string variable       */
/*  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
/*  char	* is_const;)	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
/*
  translate a string into its variable name value
  Jeff Johnson's code.
*/

{
  int		   arg_num;
  char		 * ch = '\0';


  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;

  if ( class_name[0] )	/*** arg string used to begin with "me->" ***/
    {
	/**************************************************************/
	/*		  ECcmd instance data			      */
	/**************************************************************/
      if ( !strcmp(arg, "tol") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->d = ME.ECcmd->tol;
	      * ret_type = _COB_arg_d;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECcmd->tol;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECcmd->tol ***/
      else if ( !strcmp(arg, "num_values") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = ME.ECcmd->num_values;
	      * ret_type = _COB_arg_i;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECcmd->num_values;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECcmd->num_values ***/
      else if ( !strcmp(arg, "num_points") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = ME.ECcmd->num_points;
	      * ret_type = _COB_arg_i;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECcmd->num_points;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECcmd->num_points ***/
      else if ( ! strcmp ( arg, "located_obj" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) ME.ECcmd->located_obj;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	}  /*** ME.ECcmd->located_obj ***/
      else if ( ! strncmp ( arg, "located_obj[", 12 ) )
	{
	  /*** get the # within the [ ]'s ***/
	  arg_num = COB_fetch_first_arg_num ( arg, &ch );

#define LC_OBJECT_DIM	10
	  if ( arg_num < 0  ||  arg_num >= LC_OBJECT_DIM )
	    {
	      fprintf ( stderr,
		"\nECcmd.arg_name_to_value():  Reference to ME.ECcmd->located_obj[%d]\n\tin state table argument is invalid\n\n", arg_num );
	    }
	  else
	    {
         if (ch[0] != '.')
         {
   	      if ( addr_mode == _COB_address )
	      {
	       data->p = (char *) &ME.ECcmd->located_obj[arg_num];
	       * ret_type = _COB_arg_p;
	       * is_const = 1;
	      }
         }
         else
         {
		 /*** eat up the "." after the closing ']' ***/
	      ch++;

	       COB_process_GRlc_info_arg ( addr_mode,
			& ME.ECcmd->located_obj[arg_num],
			ch, data, ret_type, is_const );
         }
        }
	}  /*** ME.ECcmd->located_obj[x].____ ***/
      else if ( ! strcmp ( arg, "value" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) ME.ECcmd->value;
	      * ret_type = _COB_arg_p;
	      /***  * is_const = 1;  THIS IS A VLA ***/
	    }
	}  /*** ME.ECcmd->value ***/
      else if ( ! strncmp ( arg, "value[", 6 ) )
	{
	  /*** get the # within the [ ]'s ***/
	  arg_num = COB_fetch_first_arg_num ( arg, &ch );

	  if ( arg_num < 0  ||  arg_num >= ME.ECcmd->num_values )
	    {
	      fprintf ( stderr,
		"\nECcmd.arg_name_to_value():  Reference to ME.ECcmd->value[%d]\n\tin state table argument is invalid\n\n", arg_num );
	    }
	  else
	    {
	      data->d = ME.ECcmd->value[arg_num];
	      * ret_type = _COB_arg_d;
	    }
	}  /*** ME.ECcmd->value[x] ***/
    }
  else	/*** arg string did not begin with "me->" ***/
    {
    }

	/*** if it's unknown, send it to parent ***/
  if ( * ret_type == _COB_UNKNOWN_ARG )
    {
      status = om$send ( targetid = my_id,
			 mode = OM_e_wrt_message,
			 msg = message CEO_LOCATE.arg_name_to_value (
					addr_mode, class_name, arg,
					data, ret_type, is_const ) );
      _check ( status );
    }

} /*** end of ECcmd.arg_name_to_value method ***/
