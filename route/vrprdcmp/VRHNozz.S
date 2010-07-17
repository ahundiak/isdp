/* $Id: VRHNozz.S,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRHNozz.S
 *
 * Description:
 *
 * Dependencies:
 *		SUBCLASS OF:    VRNozzle, VRHvac
 *
 * Revision History:
 *	$Log: VRHNozz.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1995/12/17  18:06:38  pinnacle
# Replaced: ./vrprdcmp/VRHNozz.S for:  by azuurhou for route240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/22/91	adz		creation date
 *
 ***************************************************************************/

class specification VRHNozz (0:1) of VRNozzle, VRHvac;

  instance VRHNozz 
  {
  };

/*--------------------------------------------------------------------------*/
override GRvg;		/* reject GRvg instances */

override VDgetObjDef;
override VRGetDefName;
override VRGetModel;

end specification VRHNozz ;
