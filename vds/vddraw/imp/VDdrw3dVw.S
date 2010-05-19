/* $Id: VDdrw3dVw.S,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrw3dVw.S
 *
 * Description:
 *
 *      Class defining the behavior of the volume of the VDmdlView object or
 *	an select set of objects. The objects controled by this class, 
 *	VDdrw3d can be in copy or intersect state with the internal solid.
 *
 * Dependencies:
 *
 *      VDSroot
 *
 * History:
 *
 *      06/06/95	adz		Creation Date. 
 *
 * -------------------------------------------------------------------------
 */

class specification VDdrw3dVw (0:0) of VDSroot ;

/*+v
*/

instance VDdrw3dVw
{
	/*
	 * Private channel between the VDdrw3dVw (volume) object and
	 * all the Section Cuts occurence objects.
	 */
	channel { (rel_ordered, one_to_many, initial=1, increment=1)
		VDdrw3d.to_set3 ; }	to_3d ; 

        /*
         * Each object neads to have an unique name.
         */
        variable        IGRchar         name[0];

	/*
	 * support filename for all section objects in the list. The name
	 * saved.
	 */
	variable	char		visual_3d[20] ;

	/*
	 * destination level for 3d visualization objects.
	 */
			short		level_3d;

	/*
	 * Compute flag for connected 3d visualization objects.
	 */
			int		compute ;

	/*
	 * the offset of the VDdrw3dVw in repect to the selected 
	 * 3dVw-View object.
	 */
			double		vol_offset ;

	/*
	 * Parent Information.
	 *	-	occurence name.
	 *	-	description.
	 *	-	design file
	 */
	variable	IGRchar		info[0] ;
			IGRint		indx[2] ;
};

/*-v
 */

/*+cd
 -------------------------------------------------------------------------

  Class	VDdrw3dVw

  Superclass:
	VDSroot

  Abstract
      
	This class is created to control the result of 3d visualization
	objects relative the VDdrw3dVw object. This object is not the physical
	parent object of the VDdrw3d object. It keep trace from which
	solid the object is based on. A private channel "to_set/to_3d"
	keep the connect between the VDdrw3dVw object and all the
	VDdrw3d object inside his model. This allow us to find all processed
	objects and do global operation on all the 3d-visualization objects.

	This object contain a copy of the solid object with the offset used
	for processing.  The 3d-visualization objects are not associative
	dependent of the volume limitation.
	Through user interface commands VDdrw3dVw object we can manipulate
	the set of VDdrw3d objects.


  Design Reference
	none

  Inherit Methods

     VDcreate		Public	Fills the parameters of the macro and place it.

  Overridden Methods

     VDSgetUsrAttributes    Define the method that was rejected in VDSroot.

     VDSmodUsrAttributes    Define the method that was rejected in VDSroot.

     ACgive_structure	    Find structure of current object.

     ACfind_temp_obj	    Find the template object.

     ACconstruct_feet	    Generates the feet.

     ACmplace_from_def	    Macro Contruction object.

     NDupdate		    Update the Object and check for dependents.

     GRgetobjinfo	    Displays the type of the surface when it is located.

     GRgetattr              Get object specific attributes.

     GRputattr              Put object specific attributes.


     VDgetObjDef	    Get Object specific onformation.

     VDprint		    SHow object information.

     VDcompute		    Compute the objects inside the list.

  Rejected Methods
       none

  Notes/Remarks
       none

 -------------------------------------------------------------------------
-cd*/	/* data class */


/*---------------------
 * Messages
 */

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from ACncpx
 -------------------------------------------------------------------------
-mo*/

override 	ACmplace_from_def,
		ACgive_structure,
		ACfind_temp_obj,
		ACconstruct_feet;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from NDnode
 -------------------------------------------------------------------------
-mo*/

override 	NDupdate;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from GRgraphics
 -------------------------------------------------------------------------
-mo*/

override 	GRgetobjinfo,
		GRgetattr,
		GRputattr,
		GRdelete ; 

/*+mo
 -------------------------------------------------------------------------
  Overriden Message from VDSroot
 -------------------------------------------------------------------------
-mo*/

override	VDgetObjDef,
		VDprint,
		VDcompute,
		VDSgetUsrAttributes,
		VDSmodUsrAttributes;

/*+me
 -------------------------------------------------------------------------
  Public Message VDdeleteIfEmpty

  Abstract
	Delete the VDdrw2dVw object when no more objects are connected to
	him.

  Arguments
   	long		*sts		O: Completion code
	struct GRmd_env	*md_env		I: Module Environment.

  Status/Return Code
	status == OM_S_SUCCESS    always

 -------------------------------------------------------------------------
-me*/

message VDdeleteIfEmpty(long		*msg;
			struct GRmd_env	*md_env  );


end specification VDdrw3dVw;

