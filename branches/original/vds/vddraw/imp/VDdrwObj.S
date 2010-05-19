/* $Id: VDdrwObj.S,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrwObj.S
 *
 * Description:
 *
 *      Superclass controling the common interact between the drawing objects.
 *	This class controls the object information as well as the status
 *	of the object.
 *
 * Dependencies:
 *
 *      VDSroot
 *
 * History:
 *
 *      23/06/95	adz		Creation Date. 
 *      07/27/97        Sundar          Added GRdrop method.
 *
 * -------------------------------------------------------------------------
 */


class specification VDdrwObj (0:1) of VDSroot;

/*+cd
 -------------------------------------------------------------------------

  Class	VDdrwObj

  Superclass:
	VDSroot

  Abstract

  Design Reference
	none

  Overridden Methods

       GRgetobjinfo		Displays the type of the surface
				when it is located.

       GRdelete			Check the control object to clean-up.

       GRxform			Send message to graphical component channel.

       GRgetattr		Get object specific attributes.

       GRputattr		Put object specific attributes.

       GRdrop                   Drop the graphics of the object.

       ACgive_structure		See localy and by parent.

       ACfind_temp_obj		See localy and by parent.

       NDmove_to_root		Control the move template collector.

       ACreturn_foot		Try to return info. (even when is degraded).

       VDSgetUsrAttributes      Define the method that was rejected in VDSroot.

       VDSmodUsrAttributes      Define the method that was rejected in VDSroot.

       VDprint			Print the object instance information.

  Rejected Methods
       none

  Notes/Remarks
       none

 -------------------------------------------------------------------------
-cd*/	/* data class */

instance VDdrwObj
{
	/*
	 * Object Info	The macro, occurence and design file are stored as
	 *		instance to reference against the main object.
	 *
	 *		me->info		: macro[graphical_macro]
	 *		me->info[me->index[0]]	: occurence
	 *		me->info[me->index[1]]	: design 
	 */
	variable	IGRchar		info[0];
			IGRint		indx[2];

	/*
	 * Object state information.
	 *
	 *	Bit states			0x.... ....
	 *	    (0)		/    (1)
	 *
	 *	Select		/ Trans		0x.... ...1	
	 *	Active		/ Detached	0x.... ..1.
	 *	Locatable	/ Non ...	0x.... .1..
	 *	Model Object	/ Implied Mat	0x.... 1...
	 *
	 *	Associative	/ Non ...	0x1... ....
	 *
	 * For the VDdrw3d object:
	 *
	 *      Processed       / Copied        0x.... ...1
         *      Inside Solid    / Overlapping   0x.... ..1.
         *
         *      Associtive      / Non ...       0x1... ....
	 *
	 */
			IGRushort	stsMask ;
};


/*---------------------
 * Messages
 */

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from NDnode
 -------------------------------------------------------------------------
-mo*/

override        NDmove_to_root,
		ACreturn_foot;
	

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from ACncpx
 -------------------------------------------------------------------------
-mo*/

override        ACgive_structure,
		ACfind_temp_obj;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from GRgraphics
 -------------------------------------------------------------------------
-mo*/

override 	GRgetobjinfo,
		GRxform,
		GRdelete,
		GRgetattr,
		GRputattr,
		GRdrop;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from VDSroot
 -------------------------------------------------------------------------
-mo*/

override        VDSgetUsrAttributes,
		VDSmodUsrAttributes,
		VDprint;

end specification VDdrwObj;

