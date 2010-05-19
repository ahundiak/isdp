/* $Id: VDsetmgr.S,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdgraphics/imp / VDsetmgr.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsetmgr.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:50  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* I/VDS
 *
 * File:         ~VDS/vdset/VDsetmgr.S
 *
 * Description:
 *      This class defines SetManager used in I/VDS to manage Sets 
 *
 * History:
 *      06/10/94        Chaya V. Rao
 *
 */
/*============================================================================*/

class specification VDsetmgr(1:0) of GRcmpowner;

instance VDsetmgr
{
};

/*
 *  This method sends a VDdelete_if_empty message to all sets it is connected
 *  to.  Thereby, all sets that are empty are deleted .
 */
message VDclean_up
    (
	long		*msg;		/* i/o - return status	*/
	struct GRmd_env *md_env;	/* i	module Info	*/
    );

end specification VDsetmgr;
