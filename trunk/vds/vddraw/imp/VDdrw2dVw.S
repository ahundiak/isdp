/* $Id: VDdrw2dVw.S,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrw2dVw.S
 *
 * Description:
 *
 *      Class defining the behavior of the volume of the VDmdlView object.
 *	This class construct the Union volume of the given Volumes of the
 *	VDmdView object.
 *
 * Dependencies:
 *
 *      VDSroot
 *	VDdrwMgr	Control object which keep trace of all existing
 *			VDdrw2dVw objects.
 *
 * Revision History:
 *	$Log: VDdrw2dVw.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
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
# Revision 1.2  1995/07/11  20:13:26  pinnacle
# Replaced: vddraw/imp/VDdrw2dVw.S for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/27  18:20:32  pinnacle
# Created: vddraw/imp/VDdrw2dVw.S by azuurhou for vds.240
#
 *
 * History:
 *
 *      06/06/95	adz		Creation Date. 
 *
 * -------------------------------------------------------------------------
 */

class specification VDdrw2dVw (0:0) of VDSroot ;

/*+v
*/

instance VDdrw2dVw
{
	/*
	 * Private channel between the VDdrw2dVw (volume) object and
	 * all the VDdrw2d occurence objects.
	 */
	channel { (rel_ordered, one_to_many, initial=1, increment=1)
		VDdrw2d.to_set2 ; }	to_2d ; 

	/*
	 * Each object neads to have an unique name.
	 */
	variable	IGRchar		name[0];

	/*
	 * Each set has a name and a description field of the drawing-view
	 * note.
	 * Data Structure need to be flexible enough for all
	 * drawing-note information:
	 *	- Note Name.
	 *	- Note Scale.
	 *	- Note Location.	( G-7 )
	 *	- Note Description.
	 *	- Note Reference	( A-3 )
	 */
	variable	IGRchar		note[0] ;
	variable	IGRint		indx[0] ;

	/*
	 * visualization support file/filename.
	 *	used for select group processing.
	 *	used for transparent object processing.
	 *	used for other processing.
	 */
	variable	IGRchar		visual_2d[0] ;
	variable	IGRchar		transp_2d[0] ;
	variable	IGRchar		detach_2d[0] ;

	/*
	 * Visualization support information.
	 */
		IGRint			drwLevel[32] ;	/* Ref Levels */
		struct	IGRlbsys	drwLbs ;	/* Range Context */
		IGRdouble		drwPnt[3] ;	/* Project Point */
		IGRdouble		drwVec[3] ;	/* Project Vector */
};

/*-v
 */

/*+cd
 -------------------------------------------------------------------------

  Class	VDdrw2dVw

  Superclass:
	VDSroot

  Abstract
      
	This object is :

	- created to control the result of visualization ;
	- is not the physical parent object of the VDdrw2d object.
	- can inform that type of VDdrw3d objects are availble.
	- control the following grouping commands:
		- recompute.
		- move of 2d objects in view.
		- delete of 2d objects in view.
		- return list of VDdrw2d objects.
		- return list of Parent objects.

	- locatable as the drawing-view note.

  Design Reference
	none

  Overridden Methods

     VDSgetUsrAttributes    Define the method that was rejected in VDSroot.

     VDSmodUsrAttributes    Define the method that was rejected in VDSroot.

     ACgive_structure	    Find structure of current object.

     ACfind_temp_obj	    Find the template object.

     ACconstruct_feet	    Generates the feet.

     ACmplace_from_def	    Macro Contruction object.

     NDupdate		    Update the Object and check for dependents.

     GRgetobjinfo	    Displays the object information.

     GRgetattr              Get object specific attributes.

     GRputattr              Put object specific attributes.

     GRgetrang		    Get the total range of drawing-view.

     VDgetObjDef	    Get Object specific information.

     VDprint		    Show object information.

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
		GRgetrang,
		GRxform,
		GRdisplay,
		GRcopy,
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


end specification VDdrw2dVw;

