/* $Id: VDitemSet.S,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $ */

/* I/VDS
 *
 * File:        vdannot/imp/VDitemSet
 *
 * Description:
 *
 *      The item BOM set, maintains the list of item bubbles for
 *	each BOM table.  All VDitemSet objects are connected as 
 *	components to the item manager.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitemSet.S,v $
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
# Revision 1.1  1995/07/13  14:38:34  pinnacle
# Created: vdannot/imp/VDitemSet.S by jwfrosch for vds.240
#
 *
 * History:
 *
 *	6/15/95		tlb		Created from VDitemSet.S
 *					Add method VDisFree
 */

class specification VDitemSet (1:0) of GRflxown;

/*+v
  Abstract
	
*/
		
instance VDitemSet
{
  variable IGRchar  	tblName[1];	/* table name			*/
  variable IGRchar	buf1[0];	/* buffer - for future use	*/

  /*
   * channel to connect the BOM set to item objects 
   */
  channel { (rel_ordered, one_to_many, initial=1, increment=1)
                VDitem.to_bomset; } to_items;
};

/*
-v*/

/*------------------------------------------------------------------------*/
/*+me
  Private Message VDgetSetInfo

  Abstract
	Gets the object definition, prefix/postfix string, 
	and the name of the table

  Arguments
	IGRlong		 *msg	  O	Return code
	IGRchar		**tblName O	name of BOM table

  Notes
	NULL may be passed for any output string variable if its value is
	not desired. 
	Memory will be allocated for the output strings, and has to be freed
	by the caller.

  Status/Return Code
      status == OM_S_SUCCESS    if success;

-me*/

message VDgetSetInfo( IGRlong   *msg;
		      IGRchar  **tblName );

/*------------------------------------------------------------------------*/

/*+me
  Private Message VDputSetInfo

  Abstract
        Puts the object definition, prefix/postfix string,
        and the name of the table

  Arguments
        IGRlong         *msg      O     Return code
        IGRchar         *tblName  I     name of BOM table

  Notes
        NULL pointer may be passed for any input string variable 
	if no change to the existing instance variable is desired.

  Status/Return Code
      status == OM_S_SUCCESS    if success;

-me*/

message VDputSetInfo( IGRlong  *msg;
		      IGRchar  *tblName );

/*------------------------------------------------------------------------*/
/*+me
  Private Message VDisEmpty

  Abstract
        This method checks if the set is empty

  Arguments
        IGRlong         *msg      O     Return code
        IGRboolean      *isEmpty  O  

  Status/Return Code
      status == OM_S_SUCCESS    if success;
-me*/

message  VDisEmpty( IGRlong 		*msg;
		    IGRboolean  	*isEmpty );

/*------------------------------------------------------------------------*/
/*+me
  Private Message VDdisconDelItmObj

  Abstract
        This method disconnects the given item object and deletes it.

  Arguments
        IGRlong         *msg      O     Return code
	struct GRid	itmObj    I	Item object to delete

  Status/Return Code
      status == OM_S_SUCCESS    if success;
-me*/

message  VDdisconDelItmObj( IGRlong   	*msg;
			    struct GRid	itmObj );

end specification VDitemSet;

