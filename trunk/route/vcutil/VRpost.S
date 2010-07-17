/* $Id: VRpost.S,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:	VRpost.S
 *
 * Description:
 *	This is an transient object, used for posting specially the instance
 *	date of an object. We delete the object after posting the data to DB.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRpost.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1999/01/28  20:15:12  pinnacle
# Created: vcutil/VRpost.S by lawaddel for route
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12-Jan-1999	Louis		Creation
 * -------------------------------------------------------------------*/

class specification VRpost (0:1) of ACdb_info, VDSroot, ACrg_collect;

instance VRpost
{
   struct GRid CompSeq_no;

   variable
   IGRchar extender[0];
};

override ACgive_structure;

/****************************************************************/
/*C Specific methods to cables */
/****************************************************************/

/* To get the CompSeqNo from the VRpost object */
message VRGetCompSeqNo(IGRlong *msg;
                       struct GRid *CompSeqNo); 

/* To Set the CompSeqNo into the VRpost object */
message VRSetCompSeqNo(IGRlong *msg;
                       struct GRid CompSeqNo); 

end specification VRpost;
