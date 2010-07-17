/* $Id: VLunwObj.S,v 1.2 2001/01/18 17:40:35 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwObj.S
 *
 * Description: Specification file for Unwrap Object.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwObj.S,v $
 *      Revision 1.2  2001/01/18 17:40:35  ramarao
 *      Overridden NDparent_deleted method for VLunwObj object.
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:46  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1997/10/31  19:25:22  pinnacle
# Replaced: src/unwext/VLunwObj.S for:  by rchennup for loft
#
# Revision 1.1  1997/10/28  15:29:22  pinnacle
# Created: src/unwext/VLunwObj.S by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *************************************************************************/

class specification VLunwObj (0:0) of VDSroot ;

#include "vlstructure.h"

instance VLunwObj
{
	channel { (rel_ordered, one_to_many, initial=1, increment=1)
		VLunwFeat.to_obj ; }	to_feat ; 

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

	/* Visualization support filename */
	variable	IGRchar		visual[0] ;

	/*
	 * Visualization support information.
	 */
		IGRint			drwLevel[32] ;	 //Ref Levels
		struct	IGRlbsys	drwLbs ;	 //Range Context
		IGRdouble		drwPnt[3] ;	 //Project Point
		IGRdouble		drwVec[3] ;	 //Project Vector

	struct unw_obj_plat       	dev;
	IGRdouble                 	fromMat[16];
	IGRdouble                 	toMat[16];
	IGRint			  	EdgeCount;
	variable struct EdgeMatch 	EdgeList[0];
};

/* -------------------------------------------------------------------------

  Class	VLunwObj

  Superclass:
	VDSroot

  Abstract
      
	This object is :

	- created to control the result of visualization ;
	- is not the physical parent object of the VLunwFeat object.
	- can inform that type of VLunwFeat objects are availble.
	- control the following grouping commands:
		- recompute.
		- move of feature objects in view.
		- delete of feature objects in view.
		- return list of VLunwFeat objects.
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


message VDdeleteIfEmpty( long			*msg;
			 struct GRmd_env	*md_env  );

message VLgetInst_devSrf(  struct IGRbsp_surface **devsrf );

override NDparent_deleted;

end specification VLunwObj;

