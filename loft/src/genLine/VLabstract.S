/* $Id: VLabstract.S,v 1.1.1.1 2001/01/04 21:11:26 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	src/genLine / VLabstract.S
 *
 * Description:	abstract class defining common behavior of LOFT sub classes.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLabstract.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:26  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.3  1997/04/14  10:33:42  pinnacle
# Replaced: src/genLine/VLabstract.S for: header + GRdelete override by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/15/93   llc		creation.
 *	04/14/97   mf		header + GRdelete override.
 *************************************************************************/

class specification VLabstract(0:0) of VDSroot;

override	GRdelete;

override	GRgetobjinfo;

end specification VLabstract;
