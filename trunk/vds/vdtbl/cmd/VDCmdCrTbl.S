/* $Id: VDCmdCrTbl.S,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDCmdCrTbl.S
 *
 * Description:
 *	Command for creating and modifying tables
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      04/24/95        R. Manem        Added VDupdateOrgRowValues and
 *					VDshowRowContents methods
 *	05/15/95	R. Manem	Added new methods for "modify Table" cmd
 *	06/27/95	R. Manem	Added nbNewLocObjs instance
 *	07/14/95	R. Manem	Att driven symbol support
 *	07/20/95	R. Manem	Added VDvalidateItemNos message
 *	07/24/95	R. Manem	Added validate_assoc_updmode, 
 *					lineout_table_row messages
 *	08/16/95	R. Manem	Added VDcheckColSize message
 *	09/13/95	R. Manem	Added remove_lineout message
 *	10/10/95	R. Manem	Added recompute_table message
 *					and is_table_uptodate action
 * 	12/15/97	vini 		CR-179526497
 *
 * -------------------------------------------------------------------*/


class specification VDCmdCrTbl (1:0) of VDS_LOCATE;

#include "VDdrwlo.h"
#include "VDtblCmdDef.h"

/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class VDCmdCrTbl

  Superclass
      VDS_LOCATE

  Abstract
        The Command Object provides a form interface for creating
	general tables including BOM
        
  Methods

      my_init   		Public     	Initialization

      init_create_form  	Public  	Initialization of the create 
						table form

      init_split_form  		Public  	Initialization of the split 
						table form

      update_form  		Public  	Initializes the form for newly
						located objects

      init_from_table  		Public  	Initializes from located table
						for "Modify Table" and "Split
						Table" command

      wrap_up 			Public 		Wraps up the CO.

      store_and_process_table	Public 		Stores the located table 

      store_cs			Public 		Stores the located cs 

      get_tbl_format		Public 		Gets table format

      get_tbl_type		Public 		Gets table type

      get_existing_cs		Public 		Gets the existing coordinate
						systems for the table parts.

      validate_assoc_updmode	Public 		Validates associative update
						mode

      check_to_locate_cs	Public 		Checks whether cs needs to be
						located or not.

      process_locate		Public 		Stores the located set of 
						elements

      process_rowno		Public 		Stores the located row number

      lineout_table_row		Public 		Lines out the located table row

      remove_lineout		Public 		Removes line out

      recompute_table		Public 		Recomputes the table

      is_table_uptodate		Public 		Checks if all rows of the 
						table are up-to-date

      process_ads_tblname	Public 		Proceses the ADS table name

      setup_rowList		Public 		Sets up row info list

      place_table		Public 		Generates the table
      
      place_headers		Public 		Generates the table headers
      
      VDrowToBeDeleted		Public 		Adds the specified row id to
						be deleted to the delete list

      handle_row_delete		Public 		Deletes the row ids, if any,
						deletes headers, if reqd
      
      disconnect_rows		Public 		Disconnects the rows from
						existing headers
      
      VDinitInvDatCols		Public 		Initializes the invisible
						data columns
      
      VDstoreSelectedColumnList	Public 		Stores the list of columns
						selected in the form
      
      VDupdateVisColDisp	Public 		Updates the visible column disp
      
      VDdeleteVisCol		Public 		Deletes column in vis mcf
      
      VDinsertVisCol		Public 		Inserts a column in vis mcf
      
      VDupdate1stCol		Public 		Updates R.No column in vis and
						inv mcfs 
      
      VDupdateRow		Public 		Updates the values in a row
      
      VDupdateOrgRowValues	Public 		Updates the row values in the
						review row values field
      
      VDshowRowContents		Public 		Shows the contents of a row

      VDvalidateItemNos		Public 		Validates uniqueness of item
						numbers

      VDcheckColSize		Public 		Checks if the column will
						fit in the form or not

      VDprocessCreateForm	Public 		Processes the create table form 
      
      VDprocessSplitForm	Public 		Processes the split table form 
      
      VDmoveRows		Public 		Moves a block of rows
      
      VDcopyColumn		Public 		Copies a column from one
						mcf to another
      
      VDsummarizeRows		Public 		Summarizes rows
      
      VDitemizeRow		Public 		Itemizes a row
      

  Overridden Methods

     form_notification  	Notification routine for VDcreateTable 
				and VDsplitTable forms

  Forms

     Create/Modify Table 	VDcreateTable     
     Split Table 		VDsplitTable      


 -------------------------------------------------------------------------

-cmd*/

/*+v
 -------------------------------------------------------------------------
  Abstract

  Notes/Remarks

*/

instance VDCmdCrTbl
{
    IGRint			maxLinesPerRow;	/* number of lines per 
						   row defined in the table 
						   layout definition */

    IGRshort			formState;	/* state of the form */

    IGRchar			tblTypeName[VD_DRWLO_CHR_IDFLD]; 	
						/* table type name */

    IGRshort			tblType; 	/* table type code :
						   VD_DRW_TBLTYPE_BOM 
						   VD_DRW_TBLTYPE_GEN */

    IGRchar			tblLayoutName[VD_DRWLO_CHR_IDFLD];	 
						/* name of the table layout */

    IGRchar			adsTblName[VD_DRWLO_CHR_IDFLD]; 	
						/* att driven symbol tbl name */

    IGRint			nbNewLocObjs;	/* number of newly located
						   objects */

    IGRint			nbCs;		/* number of coord systems */

    struct GRobj_env		tblObj;		/* located table object */

    IGRint			nbSelCols;	/* number of columns selected */

    variable IGRint		selColList[15];	/* list of column numbers being
						   displayed in the form */

    variable IGRint		splitLocs[0];	/* list of row locations for
						   splitting table */

    variable struct GRid	rowsDel[0];	/* list of rows to be deleted */
    variable struct GRid	hdrIds[0];	/* list of table hdrs */
    variable struct GRid	cpyHdrs[0];	/* list of table hdr copies */
    variable struct GRobj_env	cs[0];		/* list of coordinate systems */

    variable struct VDdrw_rowInfo	rows[0];	
						/* list of row info */
						
    variable struct VDdrwlo_apifix	fixRecs[0];
						/* list of fixed text records */
    variable struct VDdrwlo_data	datRecs[0];
						/* list of data records */

	variable struct GRobj_env      VDlocRows[0];   /* selected rows */
	variable struct VDdrw_rowInfo  tblRows[0];    /* table row info */
};

/*
 -------------------------------------------------------------------------
-v*/

/*+me
 ---------------------------------------------------------------------------
  Public Message my_init

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS    

  Return Code
	*sts = VD_SUCCESS
	       VD_ERROR	( if error )
      
 ---------------------------------------------------------------------------
-me*/

message my_init ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message init_create_form

  Abstract
        This method initializes the VDcreateTable form 

  Arguments
        IGRlong         *sts            O       Return code

  Status code
      status == OM_S_SUCCESS    

  Return Code
      *sts = VD_SUCCESS   
 ---------------------------------------------------------------------------
-me*/

message init_create_form ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message init_split_form

  Abstract
        This method initializes the VDsplitTable form 

  Arguments
        IGRlong         *sts            O       Return code

  Status
	status = OM_S_SUCCESS

  Return Code
	*sts = VD_SUCCESS   
 ---------------------------------------------------------------------------
-me*/

message init_split_form ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message update_form

  Abstract
        This method initialized the columns of the invisible mcf, for the
	newly located objects.

  Arguments
        IGRlong         *sts            O       Return code

  Status
	status = OM_S_SUCCESS

  Return Code
      *sts = 	VD_SUCCESS
		VD_ERROR	(if no memory)
 ---------------------------------------------------------------------------
-me*/

message update_form ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message init_from_table

  Abstract
        This method initializes the instance data from the located table.
	This message is sent during "Modify Table" and "Split Table" 
	command after locating an existing table.

  Arguments
        IGRlong         *sts            O       Return code

  Status
	status = OM_S_SUCCESS

  Return Code
      *sts = 	VD_SUCCESS
		VD_ERROR	(if no memory)
 ---------------------------------------------------------------------------
-me*/

message init_from_table ( long * sts );


/*+me
 ---------------------------------------------------------------------------
  Public Message wrap_up

  Abstract
        This method wraps up the command

  Arguments
        IGRlong         *sts            O       Return code

  Status
	status = OM_S_SUCCESS

  Return Code
      *sts = 	VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message wrap_up ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message store_and_process_table

  Abstract
        This method stores the located table.
	It also gets the list of table headers and stores them
	in the instance data. Copies of the headers are made.  

  Arguments
        IGRlong         *sts            O       Return code

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts = 	VD_SUCCESS
		VD_ERROR ( no memory )
 ---------------------------------------------------------------------------
-me*/

message store_and_process_table ( long * sts );
message VDgettherow ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message store_cs

  Abstract
        This method stores the located coordinate system.

  Arguments
        IGRlong         *sts            O       Return code

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts = 	VD_SUCCESS
		VD_ERROR ( no memory )
 ---------------------------------------------------------------------------
-me*/

message store_cs ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message summ_and_sort_objs

  Abstract
        This method summarizes and sorts the newly located objects.

  Arguments
        IGRlong         *sts            O       Return code

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS  if success
                VD_ERROR if  no memory
 ---------------------------------------------------------------------------
-me*/

message summ_and_sort_objs( long *sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message get_tbl_format

  Abstract
        This method gets the table format based on the table layout name, and
	stores the information in the instance data

  Arguments
        IGRlong         *sts            O       Return code

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS  if success
                VD_ERROR if  no memory 
 ---------------------------------------------------------------------------
-me*/

message get_tbl_format( long *sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message get_tbl_type

  Abstract
        This method returns the type of the table : bom or non-bom

  Arguments
        IGRlong         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
      	*sts =  VD_DRW_TBLTYPE_BOM ( Bom table header located )
                VD_DRW_TBLTYPE_GEN ( General table header located )
                VD_ERROR           ( Unknown table type )
 ---------------------------------------------------------------------------
-me*/

message get_tbl_type ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message get_existing_cs

  Abstract
        This method gets the existing coordinate systems from the 
	different individual table headers in the table.

  Arguments
        IGRlong         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS
		VD_ERROR           (if error)
 ---------------------------------------------------------------------------
-me*/

message get_existing_cs ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message validate_assoc_updmode

  Abstract
        This method validates associative update mode.  If it is set
	to delayed, the command must be terminated.

  Arguments
        IGRlong         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
      *sts =    VD_ERROR	if invalid mode
		VD_SUCCESS	if valid mode
 ---------------------------------------------------------------------------
-me*/

message validate_assoc_updmode( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message check_to_locate_cs

  Abstract
        This method determines whether any more coordinate systems need to
	be located or not.

  Arguments
        IGRlong         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
      *sts =    VD_TBL_LOCATE_CS	(if cs is needed)
		VD_TBL_NO_CS_NEEDED 	(if no cs is needed)
 ---------------------------------------------------------------------------
-me*/

message check_to_locate_cs( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message process_locate

  Abstract
        This method processes the located set of objects for BOM.

  Arguments
        IGRlong         *sts            O       Return code

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts = 	VD_SUCCESS
		VD_ERROR (no memory)
		VD_RESTART_CMD (no objects located)
 ---------------------------------------------------------------------------
-me*/

message process_locate ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message setup_rowList

  Abstract
        This method sets up the row info list 

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks
	It increases the dimension of me->rows by the specified number,
	and initialized the list.

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS (if success)
                VD_ERROR (no memory)
 ---------------------------------------------------------------------------
-me*/

message setup_rowList (	long 	*sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message place_table

  Abstract
        This method generates the body of the table by constructing the
	row objects and the trailer.  For "Modify Table" and "Split Table"
	the old row objects are either moved or reconstructed.  

  Arguments
        IGRlong         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
      	*sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message place_table ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message place_headers

  Abstract
        This method generates the required headers and trailers for
	"Split Table" command.

  Arguments
        long         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
	*sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message place_headers ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDrowToBeDeleted

  Abstract
        This method puts the row to be deleted in the instance vla

  Arguments
        IGRlong         *msg            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
	*sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message VDrowToBeDeleted ( 	IGRlong 	*msg;
				struct GRid	rowId );

/*+me
 ---------------------------------------------------------------------------
  Public Message handle_row_delete

  Abstract
        This method deletes the row objects whose rows were deleted or
	summarized in the form.  The last headers without any rows will
	also be deleted, and the splitLocs vla will be updated.

  Arguments
        long         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
	*sts = VD_SUCCESS
		VD_ERROR if error
 ---------------------------------------------------------------------------
-me*/

message handle_row_delete ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message disconnect_rows

  Abstract
        This method disconnects all the rows of existing header objects.
	Used just before "place_table"

  Arguments
        IGRlong         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
	*sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message disconnect_rows ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDinitInvDataCols

  Abstract
        This method initializes the rows in the inv columns, starting from
        startRowNo till the last row

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          startRowNo      I       Starting row number

  Status code
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDinitInvDataCols( 	IGRlong 	*msg;
				IGRint		startRowNo );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDstoreSelectedColumnList

  Abstract
        This method gets and stores the list of selected columns in the
        instance data

  Arguments
        IGRlong         *msg            O       Return code

  Status code
      status == OM_S_SUCCESS    

 ---------------------------------------------------------------------------
-me*/

message VDstoreSelectedColumnList( IGRlong *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDupdateVisColDisp

  Abstract
        This method updates the vis column display according to the
        selected column list.  The old columns are deleted and new columns
        are added to the vis mcf.

  Arguments
        IGRlong         *msg            O       Return code

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDupdateVisColDisp( IGRlong *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDdeleteVisCol

  Abstract
        This method deletes a column from the vis mcf.  It updates the
        corresponding inv mcf col before deletion

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          colIndex        I       Col index to delete

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDdeleteVisCol(	IGRlong 	*msg;
			IGRint		colIndex );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDinsertVisCol

  Abstract
        This method inserts a column in the vis mcf.  It updates the
        inserted column, by copying data from the corresponding inv column.

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          colNo           I       Col index of inv mcf to
                                                insert in the vis mcf
        IGRint          newPos          I       Pos in vis mcf, to insert col

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDinsertVisCol( IGRlong 	*msg;
			IGRint		colNo;
			IGRint		newPos );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDupdate1stCol

  Abstract
        This method updates the R.No column in both vis and inv mcfs.
        Summarized rows are indicated by the row number followed by a '*'

  Arguments
        IGRlong         *msg            O       Return code

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDupdate1stCol( IGRlong *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDupdateRow

  Abstract
        This method updates the given row in both vis and inv mcfs

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          rowNo           I       Row number to update

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDupdateRow( 	IGRlong 	*msg;
			IGRint		rowNo );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDupdateOrgRowValues

  Abstract
        This method updates the original row values in the 
	VD_TBL_REV_ROWVALS_FLD

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          rowNo           I       Row number  whose values are
						to be shown

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDupdateOrgRowValues( 	IGRlong 	*msg;
				IGRint		rowNo );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDshowRowContents

  Abstract
        This method expands a row, to show its default values in the
	VD_TBL_ROWCNTS_FLD

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          rowNo           I       Row number  whose values are
						to be shown

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDshowRowContents( 	IGRlong 	*msg;
				IGRint		rowNo );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDvalidateItemNos

  Abstract
        This method checks for uniqueness of item numbers.

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *messStr        O       Message to be displayed in
						message field of form, in
						case of incorrect item nos
	IGRint		bufSize		I	Size of message string

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDvalidateItemNos( 	IGRlong 	*msg;
				IGRchar		*messStr;
				IGRint		bufSize );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDcheckColSize

  Abstract
        This method checks if the columns in the visible mcf will fit
	on the form.

  Arguments
        IGRlong         *msg            O       Return code
	IGRint		gadLabel	I	The gadget label, for which
						the column display has to be
						updated :
						    VD_TBL_SHOW_SELCOL_BTN,
						    VD_TBL_SCROLL_LEFT_BTN,
						    VD_TBL_SCROLL_RIGHT_BTN
  Status
	status = OM_S_SUCCESS

  Return code

	*msg	= MSSUCC, if columns will fit on the form
		  MSFAIL, if columns will not fit

 ---------------------------------------------------------------------------
-me*/

message VDcheckColSize(	IGRlong 	*msg;
			IGRint		gadLabel );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDprocessCreateForm

  Abstract
        This method processes the create table form, after it is checked off.  
	It reads the field values and sets up the rg_collector template for
        the row objects.

  Arguments
        IGRlong         *msg            O       Return code

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDprocessCreateForm( IGRlong *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDprocessSplitForm

  Abstract
        This method reads the inpute from the split table form.
	It sets up the instance data for the split locations.

  Arguments
        IGRlong         *msg            O       Return code

  Status
	status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDprocessSplitForm( IGRlong *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message process_ads_tblname

  Abstract
        This method gets the ADS table name from the form, and updates
	the instance in VDdrwTbl class. It also sets the flag for recomputing
	all rows, if the name has changed

  Arguments
        long         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
	*sts == VD_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message process_ads_tblname( long *sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message process_rowno

  Abstract
        This method stores the located row number and updates the
	form.

  Arguments
        long         *sts            O       Return code

  Status code
	status = OM_S_SUCCESS

  Return Code
	*sts == VD_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message process_rowno( long *sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message lineout_table_row

  Abstract
        This method lines out a located table row after validating the row

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message lineout_table_row ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message remove_lineout

  Abstract
        This method removes the lineout of a table row

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message remove_lineout ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message recompute_table

  Abstract
        This method recomputes the table

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message recompute_table ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message is_table_uptodate

  Abstract
        This method checks if the table rows are up-to-date w.r.t the
	model objects. 

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts = 	VD_SUCCESS if up-to-date
		VD_ERROR if tbl rows need recomputing
 ---------------------------------------------------------------------------
-me*/

message is_table_uptodate ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDmoveRows

  Abstract
        This method moves a block of rows.

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          blkStart        I       Starting row number of block
                                                to move
        IGRint          blkEnd          I       Ending row number of block

  Status
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message VDmoveRows( 	IGRlong 	*msg;
			IGRint		stepSize;
			IGRint		blkStart;
			IGRint		blkEnd );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDcopyColumn

  Abstract
        This method copies a column from one mcf to another.  It also updates
        the flag for the rows if required.

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          fromMcf         I       Gadget label for source column
        IGRint          toMcf           I       Gadget label for dest col
        IGRint          srcCol          I       Source column index
        IGRint          destCol         I       Dest column index
        IGRint          updFlag         I       Update Flag : if 1, check
                                                for changes, and update the
                                                corresponding row flag.
                                                if 0, ignore changes.
  Status
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

message VDcopyColumn( 	IGRlong 	*msg;
			IGRint		fromMcf;
			IGRint		toMcf;
			IGRint		srcCol;
			IGRint		destCol;
			IGRint		updFlag );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDsummarizeRows

  Abstract
        This method gets the list of selected rows from the form and
        summarizes them

  Arguments
        IGRlong         *msg            O       Return code

  Status
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/


message VDsummarizeRows( IGRlong	*msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDitemizeRow

  Abstract
        This method itemizes the given summarized row.

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          rowNo           I       Row number to itemize

  Status
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDitemizeRow(	IGRlong		*msg;
			IGRint		rowNo );

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the CO

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input



 -------------------------------------------------------------------------
-mo*/

override form_notification;

end specification VDCmdCrTbl;
