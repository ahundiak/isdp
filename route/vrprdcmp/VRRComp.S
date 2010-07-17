/* $Id: VRRComp.S,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/* I/ROUTE
 *
 * File:	vrprdcmp / VRRComp.S
 *
 * Description:
 *		
 *	Instantiated class for all RWAY simple components
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	   ???		???		Creation
 *	09/29/94	Manyam		Override ACgive_structure
 *
 */
class specification VRRComp (0:1) of VRComponent, VRRway;

  instance VRRComp
  {
  };

/*---------------------
 * Messages 
 */

override	GRvg;		/* reject GRvg instances */

override	VDgetObjDef;
override	VRGetDefName;

/*+mo
  Overridden Message
        ACgive_structure from NDmacro

  Abstract
	Need to return the feet that are specific to RWAY application

-mo*/

override	ACgive_structure;

end specification VRRComp;
