/* $Id: VDdrw2d.S,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrw2d.S
 *
 * Description:
 *
 *      Class defining the behavior of two dimensional representation of
 *	a three dimensional model object. The object shows the graphical	
 *	part of the object visible and hidden in perspect with the 
 *	other objects and within the object itselves.
 *
 * Dependencies:
 *
 *      VDdrwObj
 *
 * History:
 *
 *      06/06/95	adz		Creation Date. 
 *
 * -------------------------------------------------------------------------
 */


class specification VDdrw2d (0:1) of VDdrwObj;

/*+cd
 -------------------------------------------------------------------------

  Class	VDdrw2d

  Superclass:
	VDdrwObj

  Abstract
	The 2d visualization object.      

  Design Reference
	none

  Overridden Methods

       ACmplace_from_def 	Place an occurence of the macro in the design 
				file.

       ACconstruct_feet		Generates the feet.

       VDgetObjDef		Get Object specific information.

  Rejected Methods
       none

  Notes/Remarks
       none

 -------------------------------------------------------------------------
-cd*/	/* data class */

instance VDdrw2d
{
        /*
         * Management channel
         *      Private channel between the VDdrw2dVw grouping object and
         *      all the VDdrw2d objects.
         */

        channel { (many_to_one, initial=1, increment=1)
                VDdrw2dVw.to_2d ; }   to_set2 ;

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
	 */
};


/*---------------------
 * Messages
 */

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from ACncpx
 -------------------------------------------------------------------------
-mo*/

override        ACmplace_from_def,
		ACconstruct_feet ;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message from VDSroot
 -------------------------------------------------------------------------
-mo*/

override        VDgetObjDef;

end specification VDdrw2d;

