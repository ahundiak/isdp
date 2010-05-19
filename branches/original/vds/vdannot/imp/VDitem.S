/* $Id: VDitem.S,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $ */

/* I/VDS
 *
 * File:        vdannot/imp/VDitem.S
 *
 * Description:
 *
 *	Item bubble class - 
 *	An item bubble consists of a bubble shape containing an item number
 *	and an optional leader line.  An item number is a string consisting
 *	of an optional alphanumeric prefix with a sequence number (positive
 *	integer. Table name stored in corresponding VDitemSet object.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitem.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.3  1995/07/25  22:47:14  pinnacle
# Replaced: vdannot/imp/* for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/07/13  14:36:26  pinnacle
# Replaced: vdannot/imp/VDitem.S for:  by jwfrosch for vds.240
#
 *
 * History:
 *
 *      11/29/94        R.Manem    Creation Date
 *	6/15/95		tlb	   Simplified instance variables, rename channel
 */

class specification VDitem (1:0) of DMtxbln;

/*+v
*/

instance VDitem
{
  variable IGRchar	ItemNum[1];	/* item number string		*/
  variable IGRchar	buf1[0];	/* buffer - for future use	*/

  /*
   * channel to connect the item objects to the corresponding BOM set
   */
  channel { (many_to_one, initial=1, increment=1) VDitemSet.to_items; } to_bomset;
};

/*
-v*/

/*------------------------------------------------------------------------*/

/*+mo
  Overridden Message
	GRgetobjinfo from DMtxbln

  Abstract
	Returns the item number string with the table name having the format :
		"ItemNumber (<tblName>:<ItemNum>)"
        eg.	"ItemNumber (EqpBOM_00[mod.d]:P-2)"

  Arguments
	IGRlong			*msg	  O	Return code
	struct GRobj_info	*info	  O	Object info string

-mo*/

override	GRgetobjinfo;

override	GRdelete,
		NDmove_to_root,
		gather_data,
		GRxform;

override	DMcompute_node;	/* For associative update of text in Balloon */
				/* when ItemNum in Row from BOM Table changes */

/*------------------------------------------------------------------------*/
/*+me
  Public Message VDgetItemInfo

  Abstract
	This method gets the item number and table name

  Arguments
	IGRlong		*msg 	  O	Return code
	IGRchar		**ItemNum O	Item number
	IGRchar		**tblName O	Table name

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
-me*/

message VDgetItemInfo( 	IGRlong		*msg;
		 	IGRchar 	**ItemNum;
			IGRchar 	**tblName );

/*------------------------------------------------------------------------*/
/*+me
  Public Message VDputItemInfo

  Abstract
        This method puts the item number.

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          *ItemNum  I     Item number

  Notes/Remarks
	NULL could be used as any input.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
-me*/

message VDputItemInfo( 	IGRlong		*msg;
			IGRchar		*ItemNum );

/*------------------------------------------------------------------------*/
 /*+me
  Public Message VDgetNbBreakPts

  Abstract
	This method gets the number of breakpoints of the leaderline

  Arguments
	IGRlong		*msg		O	Return code
	IGRint	 	*NbBreakPts	O
  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
-me*/

message VDgetNbBreakPts(IGRlong		*msg;
			IGRint	 	*NbBreakPts );

/*------------------------------------------------------------------------*/
    
end specification VDitem;
