/* $Id: VDdrwTbl.S,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp/VDdrwTbl
 *
 * Description:
 *
 *      This is the class for table objects. The table object represents one
 *	logical table which may be split into one or more parts on same or
 *	different sheets. 
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R.Manem         Creation Date
 *      06/19/95        R.Manem         override GRdelete, removed nbTableParts
 *					instance
 *      07/10/95        R.Manem         added VDgetAdsTblName, VDputAdsTblName
 *					messages
 *	07/21/95	R.Manem		Added tblType to instance
 *					and methods for accessing it.
 *	09/06/95	R.Manem		Overrode GRcopy
 * -------------------------------------------------------------------------
 */


class specification VDdrwTbl (1:0) of GRflxown;

#include "VDdrwlo.h"

/*+v
*/
	
instance VDdrwTbl
{
	IGRchar		tblLayoutName[VD_DRWLO_CHR_IDFLD];
					/* Name of table layout (format) */

	IGRchar		tblType[VD_DRWLO_CHR_IDFLD];
					/* Type of table layout */

	IGRshort	approvalStatus;	/* Table approval status */

	IGRchar		adsTblName[VD_DRWLO_CHR_IDFLD];
					/* attribute driven symbol tbl name */
};

/*
-v*/


/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
	GRgetobjinfo from GRgraphics

  Abstract
	Returns "TABLE"

  Arguments
	IGRlong			*msg	  O	Return code
	struct GRobj_info	*info	  O	Object info string

 ---------------------------------------------------------------------------
-mo*/

override	GRgetobjinfo;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        GRdelete from GRgraphics

  Abstract
        Overridden to delete all the rows of the table along with the
	header components

  Arguments
        IGRlong                 *msg      O     completion code
        struct GRmd_env         *md_env   I     structure containing context
                                                info

 -------------------------------------------------------------------------
-mo*/

override        GRdelete;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	GRcopy from GRgraphics

  Abstract
	Overridden to prevent copy of table.

  Arguments
	IGRlong		*msg	  	O	Return code
	struct GRmd_env	*obj_dsenv 	I	Object's present env
	struct GRmd_env	*new_dsenv 	I	Object's copy env
	GRobjid		*newobjid	O	objid of copied object

  Return Status
	status  = OM_S_SUCCESS
	*msg	= MSSUCC

  Notes :
	*newobjid is set to NULL_OBJID; A message is displayed in status
	field.

 -------------------------------------------------------------------------
-mo*/

override	GRcopy;

/*+me
 ---------------------------------------------------------------------------
  Public Message VDinitTbl

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDinitTbl(   IGRlong         *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTableLayoutName

  Abstract
	This method gets the table layout name

  Arguments
	IGRlong		*msg 	  	O	Return code
	IGRchar		*tblLayoutName  O	Table layout name
						(bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetTableLayoutName(	IGRlong		*msg;
				IGRchar 	*tblLayoutName );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputTableLayoutName

  Abstract
        This method puts the table layout name

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *tblLayoutName  I       Table layout name
                                                (bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDputTableLayoutName(   IGRlong         *msg;
                                IGRchar         *tblLayoutName );


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTableType

  Abstract
	This method gets the type of the table layout

  Arguments
	IGRlong		*msg 	  	O	Return code
	IGRchar		*tblType  	O	Table type
						(bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetTableType(	IGRlong		*msg;
			IGRchar 	*tblType );


/*+me
 ---------------------------------------------------------------------------
  Public Message VDputTableType

  Abstract
        This method puts the table type

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *tblType  	I       Table type
                                                (bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDputTableType( IGRlong         *msg;
			IGRchar 	*tblType );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetAdsTblName

  Abstract
	This method gets the attribute driven symbol table name

  Arguments
	IGRlong		*msg 	  	O	Return code
	IGRchar		*adsTblName     O	ADS Table name
						(bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetAdsTblName(	IGRlong		*msg;
				IGRchar 	*adsTblName );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputAdsTblName

  Abstract
	This method puts the attribute driven symbol table name

  Arguments
	IGRlong		*msg 	  	O	Return code
	IGRchar		*adsTblName     I	ADS Table name
						(bufsize  = VD_DRWLO_CHR_IDFLD )

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDputAdsTblName(	IGRlong		*msg;
				IGRchar 	*adsTblName );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTableParts

  Abstract
        This method gets the number/list of parts in this table.

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          *nbParts   O     Nb of parts
	struct GRid	*list	   O	 List of headers

  Notes/Remarks
	Suppress output for list if NULL
	Memory for list must be allocated by caller.  

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetTableParts( 	IGRlong		*msg;
				IGRint		*nbParts;
				struct GRid	*list );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDaddHeaders

  Abstract
        This method adds the header objects as its component. The connection
	is flexible.

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          nbHdrs     I     Nb of table headers
	struct GRid	*list	   I     List of header objects

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDaddHeaders( 	IGRlong 	*msg;
                      	IGRint  	nbHdrs;
			struct GRid	*list );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDremoveHeaders

  Abstract
        This method disconnects the header objects from its component
	channel.

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          nbHdrs     I     Nb of table headers
        struct GRid     *list      I     List of header objects

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDremoveHeaders(   IGRlong         *msg;
                           IGRint          nbHdrs;
                           struct GRid     *list );


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTotalNbOfRows

  Abstract
        This method gets the total number of rows in the table

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          *nbRows    O     Total Number of rows

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetTotalNbOfRows( IGRlong    *msg;
                            IGRint     *nbRows );

end specification VDdrwTbl;

