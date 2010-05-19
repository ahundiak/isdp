/* $Id: VDdrwGm.S,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/VDdrwGm.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwGm.S,v $
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
# Revision 1.1  1995/06/27  18:23:42  pinnacle
# Created: vddraw/imp/VDdrwGm.S by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/06/95	adz		creation date
 *
 * -------------------------------------------------------------------*/

class specification VDdrwGm (0:0) of VDSroot;

/*+cd
 -------------------------------------------------------------------------

  Class	VDdrwGm

  Superclass:
	VDSroot

  Abstract
	The 2d/3d graphical container.      

  Design Reference
	none

  Overridden Methods

       GRgetobjinfo		Displays the type of the surface
				when it is located.

       VDgetObjDef		Get Object specific information.

  Rejected Methods
       none

  Notes/Remarks
       none

 -------------------------------------------------------------------------
-cd*/	/* data class */

instance VDdrwGm
{
        /*
         * None
         */
};


/*---------------------
 * Messages
 */


/*+mo
 -------------------------------------------------------------------------
  Overridden Message from GRgraphics
 -------------------------------------------------------------------------
-mo*/

override	GRgetobjinfo;


/*+mo
 -------------------------------------------------------------------------
  Overridden Message from VDSroot
 -------------------------------------------------------------------------
-mo*/

override	VDgetObjDef;

end specification VDdrwGm;

