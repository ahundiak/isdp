/* $Id: VDdrwTblHdr.S,v 1.2 2002/04/09 15:16:32 ylong Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp/VDdrwTblHdr
 *
 * Description:
 *
 *      This represents the table header object. All header objects of a 
 *	table will be owned by the VDdrwTbl object.  There will be one header
 *	object for each part of a table.  Each VDdrwTblHdr object
 *	controls all rows of the table part it represents.
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R.Manem         Creation Date
 *      05/15/95        R.Manem         Added VDrowNoToGRid and 
 *					VDgetRowHeight messages
 *	06/23/95	R.Manem		Overrode GRdelete, added VDdeleteHdr msg
 *					New instance hdrInfo
 *	07/14/95	R.Manem		Modified VDinsertRow arg. description
 *					Modified VDgetRowConstructInfo args.
 *	07/19/95	R.Manem		Removed VDupdateRowNumbers and 
 *					VDmoveRow messages; No overriding of
 *					NDparent_deleted message
 *	08/15/95	R.Manem		Added NDmove_to_root
 *	09/06/95	R.Manem		Overrode GRcopy
 * -------------------------------------------------------------------------
 */


class specification VDdrwTblHdr (1:0) of VDSroot;

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

/*+v
*/
	
instance VDdrwTblHdr
{
	IGRint		tblPartNo;	/* Sequence number of the table part 
					   represented by this header */
	IGRchar		tblLayoutName[VD_DRWLO_CHR_IDFLD];	
					/* table layout name */
	IGRshort	tblOrient;	/* table orientation :
						   VD_DRWLO_EN_DESCEND or
						   VD_DRWLO_EN_ASCEND */
	IGRshort	csLocation;	/* location of the coord sys :
						   left (VD_DRW_CS_LOC_LEFT)
						   right (VD_DRW_CS_LOC_RIGHT)*/
	IGRmatrix	tMatrix;	/* transformation matrix from local 
					   coordinate system to world 
					   coordinate system */
	IGRint		startRowNo;	/* Starting row number */ 
	IGRshort	hdrInfo;	/* Bits for header info :
					   Currently only one bit.  Other
					   bits can be used for future expansion
					   Bit 0 : 0 = do not delete header
						   1 = delete header
					*/
	IGRshort	headerType;	/* Type of header 
						   VD_DRWLO_EN_HEADER,
                                                   VD_DRWLO_EN_BRKHDR */
	IGRshort	trailerType;	/* type of trailer 
						   VD_DRWLO_EN_TRAILER,
                                                   VD_DRWLO_EN_BRKTRLR */
	IGRshort	toConstructType; /* Construct type :
						   VD_DRW_CNST_HDR,
						   VD_DRW_CNST_TRL,
						   VD_DRW_CNST_BOTH */
	IGRdouble	headerCornerPoint[3]; /* corner point of header 
						 relative to cs origin */

	variable IGRdouble	rowHeights[0];	
				/* heights of each row 
				   If the  dimension of vla is 8, then
				   0   : for height of header
				   1-6 : for row heights
				   7   : for height of trailer
				   Whether or not the header/trailer is present
				   the first and last index of the vla are
				   reserved for the header and trailer heights
				*/

	channel { (rel_ordered, one_to_many, initial=1, increment=1)
		VDdrwTblRow.to_tblHdr; } to_tblRows;
					/* channel to connect the table header 
					   object to all its rows */
};

/*
-v*/

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        GRgetobjinfo from ACncpx

  Abstract
        Reports information about the object.
        Returns "TABLE "<table-name>": header (part <table part number>)"

  Arguments
        IGRlong                 *msg      O     Return code
        struct GRobj_info       *info     O     Object info string

 ---------------------------------------------------------------------------
-mo*/

override        GRgetobjinfo;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        GRdelete from GRgraphics

  Abstract
        This method deletes the graphics objects from the object space.
        Overridden to avoid deleting myself, if the delete flag is not set.
        This prevents accidental deletion of header, using the delete
        button.  Header can only be deleted through the VDdeleteHdr message
        which will set the delete flag to 1.

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
	Overridden to prevent copy of table header.

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
 ---------------------------------------------------------------------------
  Overridden Message
        NDmove_to_root from NDnode

  Abstract
        When the coordinate system is deleted, reconstruct one, based on
	the instance matrix.  Make it non-displayable.

  Arguments
        IGRlong         *msg            O       return code
        struct GRid     *src_grid       O       GRid of the created object
        struct GRmd_env *md_env         I       module env
 ---------------------------------------------------------------------------
-mo*/

override        NDmove_to_root;

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        VDgetObjDef from VDSroot

  Abstract
        Returns the definition of the object

  Arguments
        IGRlong                 *msg      O     Return code
        VDobjDef                *objDef   O     Object definition

 ---------------------------------------------------------------------------
-mo*/

override        VDgetObjDef;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACmplace_from_def from ACncpx

  Abstract
        Place an occurence of the macro in the design file.

  Arguments
      int               *suc            O       0 FAILED 1 SUCCESS
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

        IGRlong         *rc;             O      MSSUCC if success, MSFAIL
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

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        NDcompute_node from NDnode

  Abstract
        Recomputes a node.  Since the header has only one graphical parent
        (the coordinate system), recompute of the header is nothing but a
        GRxform.

  Arguments
      IGRlong           *msg            O       completion code
      IGRint            cn_type         I       reserved
      IGRint	        count           I       number of roots
      struct GRid       *list           I       list of roots
      struct GRmd_env   *md_env         I       module env

  Status/Return Code
     OM_S_SUCCESS       if success;
 -------------------------------------------------------------------------
-mo*/

override        NDcompute_node;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        NDupdate from NDnode

  Abstract
        Updates a node.  
	Overridden to avoid removing myself from range tree.

  Arguments
      	IGRint        	*msg            O       completion code
      	IGRint        	cn_type         I       compute type
      	IGRint        	count           I       number of parents
      	struct GRid   	*parents        I       list of parents
	IGRint		*parent_state	I	completion code of 
						parents compute
	struct GRid	*context	I	context GRid
	struct GRid	*new_objid	O	new GRid of the associative
						element if it changes.
    	struct GRmd_env *md_env         I       module env

  Status/Return Code
     OM_S_SUCCESS       if success;
 -------------------------------------------------------------------------
-mo*/

override NDupdate;

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        VDcompute from VDSroot

  Abstract
        Forces recompute of the object.
	Overridden to call VDconstructHdrTrl.

  Arguments
        IGRlong                 *msg      O     Return code

  Status/Return Code
	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails

 ---------------------------------------------------------------------------
-mo*/

override        VDcompute;

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
 ---------------------------------------------------------------------------
  Public Message VDinitTblHdr

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDinitTblHdr(   IGRlong         *msg );


/*+me
 ---------------------------------------------------------------------------
  Public Message VDconstructHdrTrl

  Abstract
        This method constructs the row, by doing ACconstruct_feet, and 
	ACchange_feet

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDconstructHdrTrl( IGRlong         *msg );


/*+me
 -------------------------------------------------------------------------
  Public Message VDdeleteHdr

  Abstract
        This method sets the delete flag and deletes myself with GRdelete
	message

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDdeleteHdr( IGRlong         *msg );


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetRowInfo

  Abstract
        This method gets the row information : number of rows and starting row
	number 

  Arguments
        IGRlong         *msg      	O     	Return code
        IGRint          *nbRows   	O     	number of rows
	IGRint		*startRowNo	O 	Starting row number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetRowInfo( 	IGRlong         *msg;
			IGRint		*nbRows;
			IGRint		*startRowNo );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputStartRowNo

  Abstract
        This method puts the starting row number

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          startRowNo      I       Starting row number

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDputStartRowNo(   	IGRlong         *msg;
                        	IGRint  	startRowNo );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDrowNoToGRid

  Abstract
        This method converts the given row number to GRid of the row
	object.

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          rowNo      	I       Row number
	struct GRid	*rowId		O	GRid of the row object

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDrowNoToGRid(	IGRlong         *msg;
			IGRint		rowNo;
			struct GRid	*rowId );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDsetSizeOfRowHeights

  Abstract
        This method sets the dimension of rowHeights according to the number
	of rows. This method is only used when it is not consistent with 
	the number of rows. You may also need to re calculate each rowHeights
	based on the row graphics, because you can not trust the values of 
	rowHeights any more after the size is reset. Refer to
	VDtblValidateRows in vds/vdtbl/func/VDdrw_tblValid.I

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDsetSizeOfRowHeights( IGRlong    *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDsetMatrixFromCS

  Abstract
        This method computes and sets the transformation matrix, 
	using the parent coordinate system.  

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDsetMatrixFromCS( IGRlong    *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetConstructInfo

  Abstract
        This method gets the construction information : 
	header type, trailer type and the toConstructType

  Arguments
        IGRlong         *msg             O       Return code
        IGRshort        *headerType      O       type of header
        IGRshort        *trailerType     O       type of trailer
        IGRshort        *toConstructType O       what to construct

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetConstructInfo(   	IGRlong         *msg;
                        	IGRshort	*headerType;
                        	IGRshort	*trailerType;
                        	IGRshort	*toConstructType );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputConstructInfo

  Abstract
        This method puts the construction information :
        header type, trailer type and the toConstructType

  Arguments
        IGRlong         *msg             O       Return code
        IGRshort        *headerType      I       type of header
        IGRshort        *trailerType     I       type of trailer
        IGRshort        *toConstructType I       what to construct

  Notes/Remarks
	Don't put if NULL input

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDputConstructInfo(     IGRlong         *msg;
                                IGRshort        *headerType;
                                IGRshort        *trailerType;
                                IGRshort        *toConstructType );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetTableInfo

  Abstract
        This method gets the table information :
        table format name, table part number and table orientation

  Arguments
        IGRlong         *msg             O       Return code
        IGRchar         *tblLoName       O       table layout name
						 (size = VD_DRWLO_CHR_IDFLD)
        IGRint          *tblPartNo       O       Part number of the table
        IGRshort        *tblOrient       O       table orientation

  Notes/Remarks
	Suppress output if NULL

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetTableInfo( IGRlong         *msg;
			IGRchar        	*tblLoName;
			IGRint        	*tblPartNo;
			IGRshort        *tblOrient );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputTableInfo

  Abstract
        This method puts the table information :
        table format name, table part number and table orientation

  Arguments
        IGRlong         *msg             O       Return code
        IGRchar         *tblLoName       I       table layout name
        IGRint          *tblPartNo       I       Part number of the table
        IGRshort        *tblOrient       I       table orientation

  Notes/Remarks
        Suppress change if NULL

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDputTableInfo( IGRlong       	*msg;
			IGRchar        	*tblLoName;
			IGRint        	*tblPartNo;
			IGRshort       	*tblOrient );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetRowConstructInfo

  Abstract
        This method gets the row construction information :
        table format name, table orientation, coordinate system, 
	previous row's corner point and attribute driven symbol table name.

  Arguments
        IGRlong         *msg             O       Return code
        IGRint		rowNo		 I       Row number to construct
        IGRchar         *tblLoName       O       table layout name
						 (size = VD_DRWLO_CHR_IDFLD)
        IGRshort        *tblOrient       O       table orientation
	struct GRid	*csId		 O	 Coordinate system id
	IGRdouble	*cornerPoint	 O       row's corner point
        IGRchar         *adsTblName      O       att driven symbol table name

  Notes/Remarks
	Suppress output if NULL

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetRowConstructInfo(  IGRlong      	*msg;
				IGRint		rowNo;
                            	IGRchar      	*tblLoName;
                            	IGRshort     	*tblOrient;
				struct GRid	*csId;
                            	IGRdouble     	*cornerPoint;
				IGRchar		*adsTblName );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetRowHeight

  Abstract
        This method gets the height of a given row number.

  Arguments
        IGRlong         *msg             O       Return code
        IGRint		rowNo		 I       Row number
	IGRdouble	*rowHeight	 O       rows height 

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetRowHeight( IGRlong      	*msg;
			IGRint		rowNo;
			IGRdouble	*rowHeight );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetCornerPointForRow

  Abstract
        This method gets the corner point for a given row.  It is the Header
	corner point offset by the sum of all previous row heights.

	For top down orientation :

header corner pnt
		+ ----------------------------------
			header 
		-----------------------------------
			row 1 
		-----------------------------------
			row 2 
		+ ----------------------------------
corner pnt for row 3
	
	For bottom up orientation :

corner pnt for row 3
		+ ----------------------------------
			row 2 
		-----------------------------------
			row 1 
		-----------------------------------
			header  
		+ ----------------------------------
header corner pnt

ie, for top down orientation, corner point is on the top left corner
and for bottom up orientation, corner point is on the bottom left corner

  Arguments
        IGRlong         *msg      	O     	Return code
	IGRint		rowNo    	I	Input Row number
	IGRdouble	*cornerPoint	O	Corner point for row

  Notes/Remarks
        If the number of data rows in the table header is 10, and the start
        row number is 5, then the valid values for rowNo are 0,5,6...,14,15.
        (0 for header, 15 for the new row or trailer, 5 - 14 for existing rows).
        vla dimension is 12 (10rows + header + trailer).

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetCornerPointForRow( IGRlong 	*msg;
				IGRint		rowNo;	
				IGRdouble	*cornerPoint );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetCsLocation

  Abstract
        This method gets the location of the coordinate system
	(VD_DRW_CS_LOC_LEFT or VD_DRW_CS_LOC_RIGHT)

  Arguments
        IGRlong         *msg             O       Return code
        IGRshort        *csLoc           O       CS location 

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetCsLocation(     IGRlong             *msg;
                             IGRshort            *csLoc );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDputCsLocation

  Abstract
        This method puts the location of the coordinate system in the instance
        (VD_DRW_CS_LOC_LEFT or VD_DRW_CS_LOC_RIGHT)

  Arguments
        IGRlong         *msg             O       Return code
        IGRshort        csLoc            I       CS location

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDputCsLocation( IGRlong             *msg;
                         IGRshort            csLoc );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDnewRowHeight

  Abstract
	This message comes from the row object during its compute.
	It notifies the header of its new row height, which may or may not 
	have changed from its previous value.  The header compares the previous
	and new values to determine if it has changed, and accordingly moves
	the remaining rows and trailer. But if the previous height was 
	initialized to -1, it means that the following rows should not be moved.

  Arguments
        IGRlong         *msg             O       Return code
        IGRint          rowNo            I       Row number 
	IGRdouble       newHeight        I       New height of the row.

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDnewRowHeight(	IGRlong   	*msg;
                        IGRint   	rowNo;
			IGRdouble	newHeight );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDremoveRow

  Abstract
        This message will disconnect the specified row.  If delete option is
	indicated, then the row object will be sent a VDdeleteRow message

  Arguments
        IGRlong         *msg       O     Return code
	IGRshort	*delOpt	   I     Delete option :
					 1 = delete row, 0 = don't delete row
	IGRint		*rowNo     I     Row number to remove.
	struct GRid	*rowId	   I     GRid of the row object

  Notes/Remarks
	Either rowNo or rowId must be specified.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDremoveRow(    IGRlong   	*msg;
                        IGRshort 	delOpt;
			IGRint   	*rowNo;
			struct GRid	*rowId );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDinsertRow

  Abstract
        This message will insert the specified row at the specified location.  
	New flag specifies whether, this is a newly created row object
	whose feet need to be constructed, or a row object which
	needs to be recomputed or an existing object which simply has to 
	be moved to the specified location 

  Arguments
        IGRlong         *msg       	O     	Return code
        IGRshort        *newFlag   	I     	New flag :
						    2 = mod row (recompute)
                                         	    1 = new row (construct)
						    0 = existing row (move)
        IGRint	     	rowPos      	I     	position to insert row
        struct GRid     rowId      	I     	GRid of the VDdrwTblRow object.
        IGRdouble       *rowHeight      I       rowHeight if row is an 
						existing one
	IGRdouble 	*oldCornerPnt	I	Old corner point of the row.

  Notes/Remarks
        If row has to be moved, must specify oldCornerPnt and rowHeight
        If row is new or modified, pass NULL for these arguments
	If the rowPos is greater than the last row number then, it will be
	added after the last row, before the trailer.  The row number of 
	the row object will be updated according to the insert position.

  Status/Return Code
      status == OM_S_SUCCESS    if success;
                OM_W_ABORT      if insufficient arguments
                                or any other error
 ---------------------------------------------------------------------------
-me*/

message VDinsertRow(    IGRlong       	*msg;
                        IGRshort      	*newFlag;
			IGRint		rowPos;
                        struct GRid   	rowId;
			IGRdouble	*rowHeight;
			IGRdouble	*oldCornerPnt );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDaddAndConstructRows

  Abstract
        This message will add the given rows on its channel, and make the rows
	to construct feet.  The rows are assumed to be newly created and
	have their templates initialized.  The row numbers will be set by the
	header object automatically.  The rows will be added after the last
	row in the table part.

  Arguments
        IGRlong         *msg            O       Return code
	IGRint		nbRows		I	Number of rows to add
        struct GRid     *rowIds         I       GRids of the VDdrwTblRow 
						objects to be added.
  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDaddAndConstructRows(  IGRlong         *msg;
				IGRint		nbRows;
                        	struct GRid     *rowIds );



end specification VDdrwTblHdr;

