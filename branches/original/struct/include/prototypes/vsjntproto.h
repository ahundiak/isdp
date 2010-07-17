/* $Id: vsjntproto.h,v 1.1.1.1 2001/01/04 21:09:57 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VScstgroup.I
 *
 * Description: joint function prototypes
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsjntproto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:57  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1998/01/06  22:15:22  pinnacle
 * Joints
 *
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/06/98  ah      Creation
 ***************************************************************************/

#ifndef vsjntproto_include
#define vsjntproto_include

long VSconstructGroup( 
  long                  *msg,
  struct GRvg_construct	*cst,
  int			count,
  struct GRid		list[],
  struct GRid *group
);

long VSlinkGroup(
  long        *msg,
  struct GRid *group,
  struct GRid *listener
);

#endif

