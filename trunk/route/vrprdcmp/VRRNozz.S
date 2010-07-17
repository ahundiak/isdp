/* $Id: VRRNozz.S,v 1.3 2001/02/20 01:16:54 build Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRRNozz.S
 *
 * Description:
 *
 * Dependencies:
 *		SUBCLASS OF:    VRNozzle, VRRway
 *
 * Revision History:
 *	$Log: VRRNozz.S,v $
 *	Revision 1.3  2001/02/20 01:16:54  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 17:43:19  anand
 *	SP merge (removed #ifdef PLOAD262 - #endif)
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  2000/07/10  19:09:04  pinnacle
# Created: route/vrprdcmp/VRRNozz.S by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1995/12/17  18:09:36  pinnacle
# Replaced: ./vrprdcmp/VRRNozz.S for:  by azuurhou for route240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/22/91	xxx		creation date.
 *	07/10/00	Alwin		Override VRGetSpecComp and VRGetSearch
 *					methods for Raceway Nozzle. CR179901003
 *
 ***************************************************************************/

class specification VRRNozz (0:1) of VRNozzle, VRRway;

#include "vrdbgmacros.h"

  instance VRRNozz 
  {
  };

/*--------------------------------------------------------------------------*/
override GRvg;		/* reject GRvg instances */

override VDgetObjDef;
override VRGetDefName;

override VRGetSpecComp;
override VRGetSearch;

end specification VRRNozz ;
