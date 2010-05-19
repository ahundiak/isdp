/* $Id: VDCmdAttMgr.S,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdequip/com / VDCmdAttMgr.S
 *
 * Description:
 *
 *	Command object for the management of the attributes in a form.
 *	The attributes are stored in 3 ACrg_coll (static, dynamic and user).
 *	
 *	The user can also have a list of non displayable attributes.
 *
 *	The Gadgets of the form are:
 *
 *		GadgToggle: toggle to display dynamic or static attributes.
 *
 *		StatDynFld: 3 column field (name, type, value) to display 
 *			    static and dynamic attributes.
 *			    (non deletable attributes, values modifiable only
 *			     for dynamic ).
 *		UserFld:    3 column field (name, type, value) to display 
 *			    user attributes (displayed with dynamic).
 *
 *	The instances need to be initialised by the subclasses.
 *
 * Dependencies:
 *
 *      VDS_LOCATE
 *
 * Revision History:
 *	$Log: VDCmdAttMgr.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *	12/01/93	P. Lacroix	Creation date
 * 
 * -------------------------------------------------------------------------
 */

class specification VDCmdAttMgr (1:0) of VDS_LOCATE;



/*+cd
 -----------------------------------------------------------------------------
  Class		VDCmdAttMgr

  Superclass:
      	VDS_LOCATE

  Abstract
	Command object for the management of the attributes in a form.
	The attributes are stored in 3 ACrg_coll (static, dynamic and user).
	
  Methods

	
	VDSetAttList	Public	Set the appropriate list of attributes in the 
				form depending on the type of attributes to 
				display.

	VDSaveListDyn	Public	Save the dynamic and user attributes displayed
				in the form.

	VDSelectTog	Public	called when the toggle static/dynamic is pushed.

	VDSetRgAtt	Public	Set the list of attributes into the instances.

	VDGetRgAtt	Public	Get the list of attributes from the instances.


  Overridden Methods

	form_notification	Implements the gadgets.

	init_all		Initialise the instances

	delete_all		Free memory.

	verify_input_row	verifies the usr input.

  Rejected Methods

	VDSetRgAtt, VDGetRgAtt.
  
  Notes/Remarks
    The instances (form and gadgets) need to be initialised by the subclasses.

 ------------------------------------------------------------------------------
-cd*/	/* data class */

#include <stdio.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

#include "ACrg_collect.h"


/*+v
 -------------------------------------------------------------------------

*/

instance VDCmdAttMgr
{
  int			nb_static;
  int			nb_dynamic;
  int			nb_user;
  struct ACrg_coll 	*static_att;  
  struct ACrg_coll 	*dynamic_att;  /* the attributes */
  struct ACrg_coll      *user_att;

  int    		nb_NonDsp;
  char 			**NonDsp; 	/* list of non displayable attribute 
					   names */

  int			GadgToggle;     /* toggle to display the dynamic or 
					   static attributes field */

  int			StatDynFld;	/* field used to display static or 
					   dynamic attributes (non deletable 
					   attributes) */

  int			UserFld;	/* field used to display user 
					   attributes */

  char			*form_att_ptr;	/* ptr to the form */

};

/*
 -------------------------------------------------------------------------
-v*/

/*---------------------
 * Messages 
 */

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
 	form_notification from CEO

  Abstract

 CEO.form_notification is called whenever a I/Forms form is given input     
 by the user.  It is analogous to super_cmd.form_input(); however, no input 
 is present in the "value" argument if the gadget type is a field.  See the 
 I/Forms Forms documentation about querying a form's gadgets to get their   
 values.                                                                    

 It has been overriden to implement the selection of a part in the database.

  Arguments

  int    	form_label;  	label of form which received user  input 
  int    	gadget_label;   gadget label  which received user  input 
  double 	value;          value of gadget ( or field row # )       
  char 		* form_ptr ;    ptr to I/Forms form which received input 

 -------------------------------------------------------------------------
-mo*/

override form_notification;


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	init_all from VDS_LOCATE

  Abstract
	That method initialise the instances.
	It has been overriden in order to initialise my instances.
	
  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

override init_all;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	delete_all from VDS_LOCATE

  Abstract
	That method is called at the delete of the command. It basically
	free all the allocated arrays.

	It has been overriden to free my own instances.

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always
 
 -------------------------------------------------------------------------
-mo*/

override delete_all;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	verify_input_row from VDS_LOCATE

  Abstract
      Verify the user input in the given label field.

      It has been overriden to use my me->StatDynFld and me->UserFld
      gadgets.

  Arguments
	long 		*sts		O	Completion code
        char    	*form_ptr       I       form pointer
        int     	label           I       gadget label where to verify

  Status/Return Code
      status == OM_S_SUCCESS   always
 
 -------------------------------------------------------------------------
-mo*/

override verify_input_row;


/*+me
 -------------------------------------------------------------------------
  Public Message VDSetAttList

  Abstract
	Set the appropriate list of attributes in the form depending
	on the type: 
			type = 0 for static attributes			  
 			type = 1 for dynamic  				  
 			type = 2 for users				  

	It Takes into account the non displayable attributes.

  Arguments

   long 		* sts		O: Completion code
   IGRint		type		I: 0 = static, 1=dynamic, 2=user

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDSetAttList ( long * sts; IGRint type);

/*+me
 -------------------------------------------------------------------------
  Public Message VDSaveListDyn

  Abstract
 	Save the dynamic and user attributes displayed in the form 
	into the instances.

  Arguments

   long 		* sts		O: Completion code
   IGRchar 		* my_message	O: message info 

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDSaveListDyn ( long * sts; IGRchar *my_message);

/*+me
 -------------------------------------------------------------------------
  Public Message VDSelectTog

  Abstract
	Called when the toggle static/dynamic is changing state.
	It displays the good list of attributes (static or dynamic) 
	in the form.

  Arguments

   long 		* sts		O: Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDSelectTog( long *sts);

/*+me
 -------------------------------------------------------------------------
  Public Message VDSetRgAtt 

  Abstract
 	Set the list of attributes into the instances 

  Arguments

   long 		* sts		O: Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDSetRgAtt ( long * sts);

/*+me
 -------------------------------------------------------------------------
  Public Message VDGetRgAtt 

  Abstract
 	Get the list of attributes from the instances 

  Arguments

   long 		* sts		O: Completion code
   IGRint		*nb_static	O: nb static attributes 
   IGRint 		*nb_dynamic 	O: nb dynamic attributes 
   IGRint 		*nb_user 	O: nb user attributes 
   struct ACrg_coll 	**static_att	O: list of static attributes 
   struct ACrg_coll 	**dynamic_att	O: list of dynamic attributes 
   struct ACrg_coll 	**user_att	O: list of user attributes 


  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

message VDGetRgAtt ( long * sts; IGRint	*nb_static; IGRint *nb_dynamic; 
		     IGRint *nb_user; struct ACrg_coll **static_att;
		     struct ACrg_coll **dynamic_att;struct ACrg_coll **user_att);

reject	VDSetRgAtt, VDGetRgAtt;

end specification VDCmdAttMgr;
