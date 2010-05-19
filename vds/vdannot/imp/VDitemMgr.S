/* $Id: VDitemMgr.S,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $ */

/* I/VDS
 *
 * File:        vdannot/imp/VDitemMgr.S
 *
 * Description:
 *
 *	The item bubble manager is responsible for managing all item
 *	bubbles in a file, per BOM table.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitemMgr.S,v $
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
# Revision 1.3  1995/07/13  14:36:58  pinnacle
# Replaced: vdannot/imp/VDitemMgr.S for:  by jwfrosch for vds.240
#
 *
 * History:
 *
 *	12/07/94	R.Manem		Creation Date
 *	12/12/94	R. Manem	New messages VDconnectItmObjs
 *
 *	6/15/95		tlb		Modify to use VDitemSet
 * 					Drop methods: 
 *						VDgetFreeItemNo
 *						VDitemNosDeleted
 *						VDgetPfxForDefn
 */

class specification VDitemMgr (1:0) of GRcmpowner;

/*------------------------------------------------------------------------*/
/*+me
  Public Message VDconnectItmObjs

  Abstract
        This message is used to connect item objects to the appropriate
	VDitemSet objects.

  Arguments
        IGRlong         *msg      O     Return code
	char 		*tblName  I	BOM table name
        IGRint           nbObjs   I     Number of item objects in list
        struct Grid     *itmObjs  I     List of item objects to connect

  Status/Return Code
      status == OM_S_SUCCESS    if success;

-me*/

message VDconnectItmObjs( IGRlong 	*msg;
			  char 		*tblName;
			  IGRint	 nbObjs;
			  struct GRid	*itmObjs );

/*------------------------------------------------------------------------*/
/*+me
  Public Message VDcleanUp

  Abstract
        This message is used to clean up the VDitemSet objects, deleting them
	if they are empty.

  Arguments
        IGRlong         *msg      O     Return code

  Status/Return Code
      status == OM_S_SUCCESS    if success;

-me*/

message VDcleanUp( IGRlong       *msg );

end specification VDitemMgr;
