/* $Id: VDdrwTblRow.S,v 1.2 2001/02/07 20:22:58 ramarao Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp/VDdrwTblRow.S
 *
 * Description:
 *
 *      This class represents an individual row of a table. 
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R.Manem         Creation Date
 *      06/05/95        R.Manem         Added VDisRowLinedOut message
 *      06/19/95        R.Manem         Changed item number representation.
 *					Compacted instance data.
 *      07/19/95        R.Manem         Removed VDputOverriddenValues message
 *      09/06/95        R.Manem         Overrode GRcopy
 *      09/13/95        R.Manem         Added messages : VDputUserDefRowFlag,
 *					VDputLineOutFlag, VDisUserDefinedRow
 * -------------------------------------------------------------------------
 */


class specification VDdrwTblRow (1:0) of VDSroot;

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

/*+v
*/
	
instance VDdrwTblRow
{
	variable IGRchar	itemNumber[1];	/* item number string */
	IGRint			rowNumber;	
	IGRshort		rowInfo;	/* row information bits :
						   (From right most bit)
						   Bit 0 : delete flag
							   0 - do not delete row
							   1 - delete row
							 This flag is set by
							 VDdeleteRow method
						   Bit 1 : lineoutFlag,
							   0 - row not lined out
							   1 - row is lined out
						   Bit 2 : quantity computation
							   0 - COUNT	
							   1 - EXPRESSION
						   Bit 3 : user-defined row
							   0 - not user-def row
							   1 - user-defined row	
						*/
	variable IGRchar 	qtyExp[1];	/* quantity expression */

	channel { (many_to_one, initial=1, increment=1)
		VDdrwTblHdr.to_tblRows; } to_tblHdr;
						/* channel to connect the
						   row objects to the 
						   corresponding table header*/
};

/*
-v*/


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	GRgetobjinfo from ACncpx

  Abstract
        Reports information about the object.
        Returns "TABLE "<table-name>":row(<row_number>)"

  Arguments
	IGRlong			*msg	  O	Return code
	struct GRobj_info	*info	  O	Object info string

 -------------------------------------------------------------------------
-mo*/

override	GRgetobjinfo;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	GRcopy from GRgraphics

  Abstract
	Overridden to prevent copy of table row.

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

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	GRdelete from GRgraphics

  Abstract
	This method deletes the graphics objects from the object space.
	Overridden to avoid deleting myself, if the delete flag is not set.  
	This prevents accidental deletion of row, by user using the delete
	button.  Row can only be deleted through the VDdeleteRow message 
	which will set the delete flag to 1.

  Arguments
	IGRlong			*msg	  O	completion code
	struct GRmd_env		*md_env	  I	structure containing context
						info

 -------------------------------------------------------------------------
-mo*/

override	GRdelete;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        VDgetObjDef from VDSroot

  Abstract
        Returns the definition of the object

  Arguments
        IGRlong                 *msg      O     Return code
        VDobjDef       		*objDef   O     Object definition

 -------------------------------------------------------------------------
-mo*/

override        VDgetObjDef;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACmplace_from_def from ACncpx

  Abstract
        Place an occurence of the macro in the design file.
	Needs to be overridden because the class has instance data.

  Arguments
      int               *rc             O       0 FAILED 1 SUCCESS
      int               prop            I       see macro.h
      char              rep             I       navsea representation
      char              *macro_name     I       the macro to place
      int               numb_obj        I       the number of real template
      struct GRid       *uplist         I       the list of templates
      struct GRid       *def_occ        I       transfer context has to be
                                                performed from this default
                                                occurence
      struct GRmd_env   *mod_env        I       module env

  Status/Return Code
     OM_S_SUCCESS       if success;
     OM_E_ABORT         if fails

 -------------------------------------------------------------------------
-mo*/

override        ACmplace_from_def;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACconstruct_feet from ACncpx

  Abstract
        Generates the resultant feet set, given the compute parameters.
        A NULLOBJID or a short list in feet_list are considered as temporary
        missing feet. A corresponding error is given to give foot access.


  Arguments

        IGRlong         *msg;            O      MSSUCC if success, MSFAIL
                                                if not.
        IGRint          cn_type;         I      reserved for future use
        IGRint          count;           I      number of roots
        struct GRid     list[];          I      list of roots the element is
                                                depending.
        struct GRmd_env *md_env;         I      current md_env
        IGRint          *fcount;         O      Number of feet (can be less
                                                than declared)
        struct GRid     *feet_list      I/O     This array array is initialized
                                                at input to the nb of declared
                                                feet. The method fills the
                                                array.

  Status/Return Code
     OM_S_SUCCESS       if success;
     OM_E_ABORT         if fails

 -------------------------------------------------------------------------
-mo*/

override        ACconstruct_feet;

/*+me
 -------------------------------------------------------------------------

  Public Message VDcreate

  Abstract
        This message fills all the parameters of the macro and
        place it.
	Overridden to avoid setting state to ND_DONT_MVRT.  Object should not
	be deleted if any parent is deleted.

  Arguments
        IGRlong         *msg            O : Completion code.
        IGRint          nbAttr          I : nb attributes in the ACrg_coll
        struct ACrg_coll *Attr          I : the attributes
        IGRchar         *macroName      I : Name of macro.
        IGRint          prop            I : Compute properties.
        IGRint          nbParents       I : number of graphical parent objects
        struct GRid     *parents        I : the surface

  Status/Return Code
        OM_S_SUCCESS    if success;
        OM_E_ABORT      if fails


 -------------------------------------------------------------------------
-me*/

override        VDcreate;

/*+me
 -------------------------------------------------------------------------
  Public Message VDinitTblRow

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDinitTblRow( IGRlong	*msg );

/*+me
 -------------------------------------------------------------------------
  Public Message VDconstructRow

  Abstract
        This method constructs the feet of the row object and 
	does ACchange_feet

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/


message VDconstructRow(   IGRlong         *msg );

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetRowNumber

  Abstract
	This method gets the row number

  Arguments
	IGRlong		*msg 	  O	Return code
	IGRint		*rowNo	  O	Row number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDgetRowNumber( IGRlong		*msg;
			IGRint		*rowNo );

/*+me
 -------------------------------------------------------------------------
  Public Message VDputRowNumber

  Abstract
        This method puts the row number

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          rowNo     O     Row number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDputRowNumber( IGRlong         *msg;
                        IGRint          rowNo );

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetParentObjectList

  Abstract
        This method returns the list of parent 3D objects connected indirectly
	through the associative set.

  Arguments
        IGRlong         	*msg      O     Return code
        IGRint          	*nbObjs   O     Number of objects
	struct GRobj_env 	*list	  O     List of objects.

  Notes/Remarks
	Memory must be allocated for list by the caller.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDgetParentObjectList( 	IGRlong         	*msg;
                        	IGRint          	*nbObjs;
				struct GRobj_env	*list );

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetParentSetId

  Abstract
        This method returns the GRid of the VDdrwSet parent object.

  Arguments
        IGRlong                 *msg      O     Return code
        struct GRid             *setId    O     GRid of set

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDgetParentSetId( 	IGRlong        	*msg;
				struct GRid	*setId );

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetItemNumber

  Abstract
        This method gets the item number, and the pfx string for the row

  Arguments
        IGRlong         *msg      O     Return code
	IGRint		*bufSize  O	size of buffer = strlen(itemNo) + 1
        IGRchar         *itemNo   O     Item Number string

  Notes/Remarks
	Memory for itemNo to be allocated by caller. 
	If itemNo = NULL, output is suppressed

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDgetItemNumber(	IGRlong		*msg;
				IGRint		*bufSize;
		 		IGRchar 	*itemNo );

/*+me
 -------------------------------------------------------------------------
  Public Message VDputItemNumber

  Abstract
        This method puts the item number for the row

  Arguments
        IGRlong         *msg      O     Return code
        IGRchar         *itemNo   I     Item Number string

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDputItemNumber(        IGRlong         *msg;
                                IGRchar         *itemNo );

/*+me
 -------------------------------------------------------------------------
  Public Message VDputQtyExpr

  Abstract
        This method puts expression for quantity

  Arguments
        IGRlong         	*msg 	O     Return code
        struct VDdrwlo_qtyExp	qty  	I     Expression for quantity 

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDputQtyExpr(	IGRlong         	*msg;
			struct VDdrwlo_qtyExp	qty );

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetQtyExpr

  Abstract
        This method gets the expression for quantity

  Arguments
        IGRlong         	*msg 	O     Return code
        struct VDdrwlo_qtyExp	*qty  	O     Expression for quantity 

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDgetQtyExpr(	IGRlong         	*msg;
			struct VDdrwlo_qtyExp	*qty );

/*+me
 -------------------------------------------------------------------------
  Public Message VDmoveRow

  Abstract
        This method moves itself by doing a GRxform on all its components.

  Arguments
        IGRlong         *msg      O     Return code
	IGRshort        *matType  I     Matrix type
	IGRmatrix       matrix    I     input transformation matrix

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDmoveRow( 	IGRlong 	*msg;
			IGRshort	*matType;
			IGRmatrix	matrix );


/*+me
 -------------------------------------------------------------------------
  Public Message VDdeleteRow

  Abstract
        This method deletes itself and its parent associative set object.

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDdeleteRow( IGRlong         *msg );

/*+me
 -------------------------------------------------------------------------
  Public Message VDparentSetEmpty

  Abstract
        This message notifies the row that the parent set has become empty.
	This message will be sent by the parent set during its NDmove_to_root
	execution, if it finds that all its parents have been deleted.
	The method should do line-out handling.

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDparentSetEmpty( IGRlong  *msg );

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetCurrentRowValues

  Abstract
        This message will return the existing row values.  Useful during
	Modify Table command.  

  Arguments
        IGRlong         *msg       O     Return code
	IGRint		*nbValues  O     Number of values in the list
	IGRint		**lineNos  O     list of line numbers
	IGRint		**colNos   O     Corresponding list of column numbers
	IGRchar		***values  O     List of values

  Notes/Remarks
	The memory for each of the values will be allocated, as also the 
	memory for the list of pointers to the values.  All double values 
	will be converted to string type.
	Memory for lineNos and colNos array will be allocated.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDgetCurrentRowValues(	IGRlong  	*msg;
				IGRint		*nbValues;
				IGRint		**lineNos;
				IGRint		**colNos;
				IGRchar		***values );

/*+me
 -------------------------------------------------------------------------
  Public Message VDisRowLinedOut

  Abstract
        This message tells whether the row is lined out or not

  Arguments
        IGRlong         *msg       	O     Return code
	IGRshort	*isLinedOut 	O     1 = lined out, 0 = not lined out

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDisRowLinedOut(IGRlong  	*msg;
			IGRshort	*isLinedOut );

/*+me
 -------------------------------------------------------------------------
  Public Message VDputUserDefRowFlag

  Abstract
        This message sets or resets the user-defined row flag

  Arguments
        IGRlong         *msg       	O     Return code
	IGRshort	flag 		I     1 = is user-defined row 
					      0 = not user-defined row 

  Status/Return Code
      status == OM_S_SUCCESS    always ;
 -------------------------------------------------------------------------
-me*/

message VDputUserDefRowFlag(	IGRlong  	*msg;
				IGRshort	flag );

/*+me
 -------------------------------------------------------------------------
  Public Message VDputLineOutFlag

  Abstract
        This message sets or resets the lineOut flag

  Arguments
        IGRlong         *msg       	O     Return code
	IGRshort	flag 		I     1 = lined out
					      0 = not lined out

  Status/Return Code
      status == OM_S_SUCCESS    always ;
 -------------------------------------------------------------------------
-me*/

message VDputLineOutFlag(	IGRlong  	*msg;
				IGRshort	flag );

/*+me
 -------------------------------------------------------------------------
  Public Message VDisUserDefinedRow

  Abstract
        This message tells whether the row is user defined or not 

  Arguments
        IGRlong         *msg       	O     Return code
	IGRshort	*isUserDef 	O     1 = user-def, 0 = not user-def

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDisUserDefinedRow(	IGRlong		*msg;
				IGRshort	*isUserDef );

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetTableHeader

  Abstract
	This method returns the table header object associated with the row.

  Arguments
        IGRlong         *msg            O     	Return code
	struct GRid	*TblHdrId	O	Table Header Object
	struct GRid	*TblId		O	Table Object

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDgetTableHeader(	IGRlong         *msg;
				struct GRid	*TblHdrId;
				struct GRid	*TblId 		);

end specification VDdrwTblRow;

