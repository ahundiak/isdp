/* $Id: VDdrw3d.S,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrw3d.S
 *
 * Description:
 *
 *      Class defining the behavior of the modeling object in respect to
 *	if control solid object.
 *	The object can be in a shape with review total graphical 
 *	representation before boolean against the solid.
 *
 * Dependencies:
 *
 *      VDdrwObj
 *
 * History:
 *
 *	06/07/95	adz		creation date.
 *
 * -------------------------------------------------------------------------
 */

class specification VDdrw3d (0:0) of VDdrwObj ;

/*+v
 */
 
instance VDdrw3d
{
        /*
	 * Management channel
         * 	Private channel between the VDdrw3dVw (volume) object and
         * 	all the VDdrw3d objects.
         */

        channel { (many_to_one, initial=1, increment=1)
                VDdrw3dVw.to_3d ; }   to_set3 ;

	/*
	 * Object state information.
	 *
	 *	Bit states			0x.... ....
	 *	    (0)		/    (1)
	 *
	 *	Processed	/ Copied	0x.... ...1
	 *	Inside Solid	/ Overlapping	0x.... ..1.	
	 *
	 *	Associtive	/ Non ...	0x1... ....
	 *
	 */
};

/*-v
 */

/*+cd
 -------------------------------------------------------------------------

  Class	VDdrw3d

  Superclass:
	VDdrwObj

  Abstract
      
	This class is created to review an object representaion (copy)
	of an 3D model object relative to the VDdrw3dVw display limitation.
	
	Object which are interfering with the Solid-union object of the 
	VDdrw3dVw (the inherited union solid of VDmdlvw) are truncated
	(cut) to the volume border.

  Design Reference
	none

  Overridden Methods

     ACmplace_from_def	    Place the macro definition.

     ACconstruct_feet	    Generates the feet.

     NDctl_parent_type	    Check the object against the real macro.

     NDget_parent_type	    Give the real macro name back.

     VDgetObjDef	    Get Object specific onformation.

  Rejected Methods
       none

  Notes/Remarks
       none

 -------------------------------------------------------------------------
-cd*/


/*---------------------
 * Messages
 */

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from ACncpx
 -------------------------------------------------------------------------
-mo*/

override 	ACmplace_from_def,
		ACconstruct_feet;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from NDnode
 -------------------------------------------------------------------------
-mo*/

override 	NDctl_parent_type,
		NDget_parent_type;

/*+mo
 -------------------------------------------------------------------------
  Overriden Message from VDSroot
 -------------------------------------------------------------------------
-mo*/

override	VDgetObjDef;

end specification VDdrw3d;
