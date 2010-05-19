
/* $Id: VDSnode.S,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */
/* I/VDS
 *
 * File:        VDSnode.S
 *
 * Description:
 *      Super class of all associative objects of products 
 *	which do not have previous superclass ACncpx but ASnode.
 *      I/VDS, I/SMAN, I/STRUCT, I/ROUTE and I/LOFT.
 *
 *
 * Revision History:
 *	$Log: VDSnode.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
# Revision 1.2  1995/03/02  22:52:04  pinnacle
# Replaced: vdroot by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      09/28/94        Ad Zuurhout	Creation Date
 */

/*+cd

  Class VDSnode

  Superclass:
        ASnode

  Abstract

  Design Reference

  Methods

  Overridden Methods

  Rejected Methods

  Notes/Remarks
       none

-cd*/   /* data class */


class specification VDSnode(0:0) of ASnode ;

/*+mo

  Overridden Message

  Abstract

-mo*/

/*+me
  Public Message 

  Abstract

  Arguments

  Notes/Remarks

  Status/Return Code

-me*/


end specification VDSnode ;
