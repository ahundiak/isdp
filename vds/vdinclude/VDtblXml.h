/* $Id: VDtblXml.h,v 1.14 2002/05/11 03:01:19 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdinclude/VDtblXml.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtblXml.h,v $
 *      Revision 1.14  2002/05/11 03:01:19  ylong
 *      *** empty log message ***
 *
 *      Revision 1.13  2002/04/23 14:18:49  ylong
 *      *** empty log message ***
 *
 *      Revision 1.12  2001/10/18 14:26:32  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/10/08 14:22:22  ylong
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/09/25 17:52:26  paul_noel
 *      *** empty log message ***
 *
 *      Revision 1.9  2001/08/29 21:03:52  ylong
 *      *** empty log message ***
 *
 *      Revision 1.8  2001/08/23 20:50:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/08/23 20:41:03  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/08/22 18:20:11  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/08/20 23:43:43  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/08/20 14:20:55  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/08/20 13:41:54  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/08/17 20:16:10  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/08/17 14:40:39  ylong
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 07/18/01	ylong		Creation
 * 10/18/01     ah              Removed reference to cDom
 ***************************************************************************/
#ifndef VDtblXml_include
#define VDtblXml_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDdrwlo_include
#include "VDdrwlo.h"
#endif

#ifndef   VDdrwtbl_include
#include "VDdrwtbl.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*--------------------------------------------------------------
 * xml table directory 
 */
#define	VD_XTBL_DIR			"xml_tbls"

/*--------------------------------------------------------------
 * xml node attributes
 */

/* for table object */
#define	VD_XTBL_TBL_ATTR_TXT_TBLID		"object_id"
#define	VD_XTBL_TBL_ATTR_TXT_NAME		"name"
#define	VD_XTBL_TBL_ATTR_TXT_DESC		"description"

/* for table definition */
#define	VD_XTBL_LO_ATTR_TXT_LAYOUT		"layout_name"
#define	VD_XTBL_LO_ATTR_TXT_TBLTYP		"layout_type"
#define	VD_XTBL_LO_ATTR_TXT_DESC		"description"
#define VD_XTBL_LO_ATTR_TXT_ADS			"ads_name"
#define	VD_XTBL_LO_ATTR_TXT_APPROV		"approval"

/* for table header columns */
#define	VD_XTBL_COL_ATTR_TXT_FLDID		"field_id"
#define	VD_XTBL_COL_ATTR_TXT_TITLE		"title"
#define	VD_XTBL_COL_ATTR_INT_COLNO		"column_no"
#define	VD_XTBL_COL_ATTR_INT_LINNO		"line_no"
#define	VD_XTBL_COL_ATTR_INT_GRPTYP		"group_type"
#define	VD_XTBL_COL_ATTR_INT_RECTYP		"record_type"
#define	VD_XTBL_COL_ATTR_INT_DATTYP		"data_type"

/* for table sets */

#define	VD_XTBL_TBLSETS_ATTR_INT_CRTYP		"create_type"
#define	VD_XTBL_TBLSETS_ATTR_TXT_ROOT		"root_node"
#define	VD_XTBL_TBLSETS_ATTR_TXT_PATH		"path"
#define	VD_XTBL_TBLSETS_ATTR_TXT_PROC		"process"
#define	VD_XTBL_TBLSETS_ATTR_TXT_INDEX		"index"
#define	VD_XTBL_TBLSETS_ATTR_TXT_FILE		"file_name"
#define	VD_XTBL_TBLSETS_ATTR_TXT_SEPAR		"separator"

/* for table set */

#define	VD_XTBL_TBLSET_ATTR_INT_PTNO		"part_no"
#define VD_XTBL_TBLSET_ATTR_INT_ORIENT		"orient"
#define VD_XTBL_TBLSET_ATTR_INT_CSLOC		"cs_loc"
#define VD_XTBL_TBLSET_ATTR_INT_HDRTYP		"header_type"
#define VD_XTBL_TBLSET_ATTR_INT_TRLTYP		"trailer_type"
#define VD_XTBL_TBLSET_ATTR_INT_CONSTYP		"construct_type"
#define VD_XTBL_TBLSET_ATTR_INT_START		"start_row_no"
#define VD_XTBL_TBLSET_ATTR_INT_NBROWS		"number_rows"

#define VD_XTBL_HDR_ATTR_TXT_HDRID		"object_id"

#define	VD_XTBL_ROW_ATTR_TXT_ROWID		"object_id"
#define	VD_XTBL_ROW_ATTR_TXT_ITEMNO		"item_no"
#define	VD_XTBL_ROW_ATTR_TXT_QTYEXP		"qty_exp"
#define	VD_XTBL_ROW_ATTR_INT_ROWNO		"row_no"
#define	VD_XTBL_ROW_ATTR_INT_INFO		"row_info"
#define	VD_XTBL_ROW_ATTR_INT_NBOBJ		"number_objects"

#define	VD_XTBL_OBJ_ATTR_TXT_OBJID		"object_id"
#define	VD_XTBL_OBJ_ATTR_TXT_PATH		"path"

#define	VD_XTBL_CELL_ATTR_TXT_DEFAULT		"default_value"
#define	VD_XTBL_CELL_ATTR_TXT_VALUE		"value"
#define	VD_XTBL_CELL_ATTR_INT_COLNO		"column_no"
#define	VD_XTBL_CELL_ATTR_INT_LINNO		"line_no"

/* common use */
#define	VD_XTBL_ATTR_TXT_OBJID			"object_id"

/*--------------------------------------------------------------
 * xml node type, such as table, header, row, cell, etc. 
 */
#define	VD_XTBL_NODE_TYPE_TBLS		"tables"
#define	VD_XTBL_NODE_TYPE_TBL		"table"
#define	VD_XTBL_NODE_TYPE_LO		"layout"
#define	VD_XTBL_NODE_TYPE_COL		"column"
#define	VD_XTBL_NODE_TYPE_TBLSET	"table_set"
#define	VD_XTBL_NODE_TYPE_TBLSETS	"table_sets"
#define	VD_XTBL_NODE_TYPE_HDR		"header"
#define	VD_XTBL_NODE_TYPE_ROWS		"rows"
#define	VD_XTBL_NODE_TYPE_ROW		"row"
#define	VD_XTBL_NODE_TYPE_OBJS		"objects"
#define	VD_XTBL_NODE_TYPE_OBJ		"object"
#define	VD_XTBL_NODE_TYPE_CELLS		"cells"
#define	VD_XTBL_NODE_TYPE_CELL		"cell"


/*
 * Export table option
 */
typedef struct {
	IGRint		cnt;
	IGRint		*colNos;
	IGRint		*linNos;
} VDxtblFldOpt;

/*---------------------------------------------------------------
 * Routines 
 */

extern IGRlong VDtblXmlCrTblNode __((
				TGRid   *tblID,
				IGRchar *desc,
				TGRid   *xtblID ));

extern IGRlong VDtblXmlCrLayoutNode __((  
				TGRid   *tblID,
                                TGRid   *xtblID, 
				TGRid   *xloID ));

extern IGRlong VDtblXmlCrHdrNode __((
				TGRid   *hdrID,
				TGRid   *xtblSet,
				TGRid   *xhdrID ));

extern IGRlong VDtblXmlCrLoColNodes __((  
				TGRid   *tblID,
				TGRid   *xloID,
				TGRid   **xcolIDs,
				IGRint	*nbCols));

extern IGRlong VDtblXmlCrObjNodes __((
				TGRid   *rowID,
				TGRid   *xobjSet,
				TGRid   **xobjIDs,
				IGRint	*nbObjs ));

extern IGRlong VDtblXmlCrCellNodes __((
				TGRid   *rowID,
				TGRid   *xcellSet,
				TGRid   **xcellIDs,
				IGRint	*nbCells ));

extern IGRlong VDtblXmlCrRowNodes __((
				TGRid   *hdrID,
				TGRid   *xtblSet,
				TGRid   **xrowIDs,
				IGRint	*nbRows ));

extern IGRlong VDtblXmlCrTblSetNodes __((
				TGRid   *tblID,
				TGRid   *xtblID,
				TGRid   **xtblSets,
				IGRint	*nbTblSets ));

extern IGRlong VDtblXmlCrTblSetsNode __((
				TGRid   *tblID,
				TGRid   *xtreeID,
				TGRid   *xtblSetsID ));

/*+M -----------------------------------------------------------------
Macro	vd$astbl_getRowData()

Abstract
	Get row data from asci table file

Arguments
	IN	IGRchar		*filename	ascii file name
	IN	IGRint		rowInd		row index
	OUT	IGRchar		***rowBuf	rows buffer
	OUT	IGRint		*nbRows		number of rows in rowBuf
	IN	IGRint		colInd		column index
	OUT	IGRchar		**colBuf	columns buffer
	OUT	IGRint		*nbCols		number of columns in colBuf
	OUT	IGRchar		*layout		table layout name
	OUT	IGRchar		*separator	deliminator for cells

Note:
	rowInd and colInd are set to -1 as default to get all rows or
	columns, otherwise, return specified row or column
-M*/

extern	IGRlong	VDtbl_getASCIIinput __((
				IGRchar	*filename,
				IGRint	rowInd,
				IGRchar	***rowBuf,
				IGRint	*nbRows,
				IGRint	colInd,
				IGRchar	**colBuf,
				IGRint	*nbCols,
				IGRchar	*layout,
				IGRchar	*separator ));

#define	VDtbl_getASCIIrows( filename, rowBuf, nbRows ) \
 VDtbl_getASCIIinput(filename, -1, rowBuf, nbRows, -1, NULL, NULL, NULL,NULL)


#omdef vd$astbl_getRowData (	filename,
				rowInd		= -1,
				rowBuf		= NULL,
				nbRows		= NULL,
				colInd		= -1,
				colBuf		= NULL,
				nbCols		= NULL,
				layout		= NULL,
				separator	= NULL )
				
	VDtbl_getASCIIinput (	(filename),
				(rowInd),
				(rowBuf),
				(nbRows),
				(colInd),
				(colBuf),
				(nbCols),
				(layout),
				(separator) )

#endomdef

/*+M -----------------------------------------------------------------
Macro	vd$xmltbl_getRowData()

Abstract
	Get row data from XML

Arguments
	IN	struct GRid	*xtreeID	xml table tree id (opt)
	IN	IGRchar		*xmlBuf		xml buffer (opt)
	IN	IGRchar		*xmlFile	xml file name (opt)
	IN	IGRchar		*separator	deliminator for cells
	IN	IGRint		rowInd		row index
	OUT	IGRchar		***rowBuf	rows buffer
	OUT	IGRint		*nbRows		number of rows in rowBuf
	IN	IGRint		colInd		column index
	OUT	IGRchar		**colBuf	columns buffer
	OUT	IGRint		*nbCols		number of columns in colBuf

Note:
	rowInd and colInd are set to -1 as default to get all rows or
	columns, otherwise, return specified row or column
-M*/

extern IGRlong VDtblXmlGetRowDataFromXml __((
				TGRid	*xtreeID,
				IGRchar	*xmlBuf,
				IGRchar	*xmlFile,
				IGRchar	*separator,
				IGRint	rowInd,
				IGRchar	***rowBuf,
				IGRint	*nbRows,
				IGRint	colInd,
				IGRchar	**colBuf,
				IGRint	*nbCols ));

#omdef vd$xmltbl_getRowData (	xtreeID		= NULL,
				xmlBuf		= NULL,
				xmlFile		= NULL,
				separator	= NULL,
				rowInd		= -1,
				rowBuf		= NULL,
				nbRows		= NULL,
				colInd		= -1,
				colBuf		= NULL,
				nbCols		= NULL )

	VDtblXmlGetRowDataFromXml (	(xtreeID),
					(xmlBuf),
					(xmlFile),
					(separator),
					(rowInd),
					(rowBuf),
					(nbRows),
					(colInd),
					(colBuf),
					(nbCols) )

#endomdef

/*+M -----------------------------------------------------------------
Macro	vd$xmltbl_modByColOpt

Abstract
	Modify an existing xml by filtering out columns not wanted

Arguments
	IN	VDxtblColOpt	*cols		columns needed 
	IN/OUT	struct GRid	*xtreeID	xml tree id (OPT)
	IN/OUT	IGRchar		*xmlBuf		xml buffer (OPT)
	IN/OUT	IGRchar		*xmlFile	xml file name (OPT)

-M*/

extern IGRlong VDtblXmlModifyByOpt __((
				TGRid		*xtreeID,
                                IGRchar		**xmlBuf,
                                IGRchar		*xmlFile,
                                VDxtblFldOpt	*flds ));

#omdef vd$xmltbl_modByColOpt (	xtreeID  = NULL,
				xmlBuf   = NULL,
				xmlFile  = NULL,
				flds )

	VDtblXmlModifyByOpt (	(xtreeID),
				(xmlBuf),
				(xmlFile),
				(flds) )

#endomdef


/*+M -----------------------------------------------------------------
Macro	vd$xmltbl_create

Abstract
	Export table to xml

Arguments
	IN	struct GRid	*tblID		table id
	IN	VDxtblFldOpt	*fldOpt		field options
	IN	IGRchar		*xmlFile	xml file name for output (OPT)
	IN	IGRchar		*domName	object name for output (OPT)
	OUT	struct GRid	*domID		output object for xml (OPT)
	OUT	struct GRid	*xtreeID	output xml tree (OPT)
	OUT	IGRchar		**xmlBuf	output xml to buffer (OPT)

Note
	domName is output object name of domID. Do not give this name unless
	you have specific use for it. The function will generate the object
	name by post-fix _xml to table name.

	user has to delete xtreeID using VDctxDeleteNode(xtreeID) after use.
	VDct1DeleteRootObject(domID) can be used to delete domID, but Art may
	implement another one to do it.
-M*/

extern	IGRlong VDtblXmlCreate __((
				TGRid   *tblID,
				VDxtblFldOpt	*fldOpt,
				IGRchar *xmlFile,
				IGRchar *domName,
				TGRid   *domID,
				TGRid   *xtreeID,
				IGRchar	**xmlBuf ));

#omdef vd$xmltbl_create (	tblID,
				fldOpt	 = NULL,
				xmlFile  = NULL,
				domName  = NULL,
				domID    = NULL,
				xtreeID  = NULL,
				xmlBuf   = NULL )

	VDtblXmlCreate (	(tblID),
				(fldOpt),
				(xmlFile),
				(domName),
				(domID),
				(xtreeID),
				(xmlBuf) )

#endomdef


/*+M -----------------------------------------------------------------
Macro	vd$tbl_createByXml

Abstract
	Place table by xml

Arguments
	IN	TGRobj_env	*csOE		coordinate
	IN	IGRshort	*csLocation	coordinate location:
						W_CS_LOC_LEFT,
						VD_DRW_CS_LOC_RIGHT
	IN	IGRchar		*loName^	table layout name
	IN	IGRchar		*xmlFile^	xml file name in full path
	IN	IGRchar		*xmlBuf^	xml buffer 
	IN	TGRid		*xtblId		xdom object
	IN	IGRchar		*xslFile	xsl file name in full path(opt)
	IN	IGRchar		*xslBuf		xsl buffer (opt)
	IN	TGRid		*xslId		xsl object (opt)
	OUT	TGRid		*table		table object (opt)

-M*/

extern	IGRlong VDdrw_crTblByXml __((
				TGRobj_env	*csOE,
				IGRshort	csLocation,
				IGRchar		*loName,
				IGRchar		*xmlFile,
				IGRchar		*xmlBuf,
				TGRid		*xtblId,
				IGRchar		*xslFile,
				IGRchar		*xslBuf,
				TGRid		*xslId,
				TGRid		*table ));

#omdef vd$tbl_createByXml (	csOE ,
				csLocation	= VD_DRW_CS_LOC_LEFT ,
				loName ,
				xmlFile		= NULL ^
				xmlBuf		= NULL ^
				xtblId		= NULL ,
				xslFile		= NULL ,
				xslBuf		= NULL ,
				xslId		= NULL ,
				table		= NULL )

	VDdrw_crTblByXml (	(csOE),
				(csLocation),
				(loName),
				(xmlFile),
				(xmlBuf),
				(xtblId),
				(xslFile),
				(xslBuf),
				(xslId),
				(table) )

#endomdef


/*+M -----------------------------------------------------------------
Macro	vd$xmltbl_global_get()

Abstract
	get global xml table

Arguments
	OUT	struct GRid	*xtblID		output xml table tree (OPT)
-M*/

extern	IGRlong	VDtblXmlGetXmlTblID __(( TGRid	*xtblID ));

#omdef	vd$xmltbl_global_get ( xtblID )

	VDtblXmlGetXmlTblID ( (xtblID) )

#endomdef

/*+M -----------------------------------------------------------------
Macro	vd$xmltbl_global_set()

Abstract
	Create a global xml table

Arguments
	IN	struct GRid	*tblID		table id
	OUT	struct GRid	*xtblID		global xml table (OPT)
-M*/

extern	IGRlong	VDtblXmlSetXmlTblID __((	TGRid	*tblID,
						IGRchar	*xBuf,
						IGRchar	*xFile,
						TGRid	*xtblID ));

#omdef	vd$xmltbl_global_set (	tblID	= NULL ^
				xBuf	= NULL ^
				xFile	= NULL,
				xtblID	= NULL )

	VDtblXmlSetXmlTblID (	(tblID),
				(xBuf),
				(xFile),
				(xtblID) )

#endomdef


/*+M -----------------------------------------------------------------
Macro	vd$xmltbl_global_delete()

Abstract
	delete global xml table
-M*/

extern	IGRlong	VDtblXmlDelXmlTblID __(( ));

#omdef	vd$xmltbl_global_delete ()

	VDtblXmlDelXmlTblID ()

#endomdef



/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
