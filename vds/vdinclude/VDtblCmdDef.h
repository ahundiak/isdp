
/* $Id: VDtblCmdDef.h,v 1.22 2001/10/11 22:39:28 paul_noel Exp $  */

/* I/VDS
 *
 * File:        $VDS/vdinclude/VDtblCmdDef.h
 *
 * Description:
 *      This include file defines gadget labels for forms, data structures, 
 *	for table commands
 *	
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDtblCmdDef.h,v $
 *	Revision 1.22  2001/10/11 22:39:28  paul_noel
 *	*** empty log message ***
 *	
 *	Revision 1.21  2001/08/23 21:04:06  paul_noel
 *	*** empty log message ***
 *	
 *	Revision 1.20  2001/08/20 20:29:46  paul_noel
 *	Update for new xml functionality
 *	
 *	Revision 1.19  2001/08/02 16:18:31  paul_noel
 *	*** empty log message ***
 *	
 *	Revision 1.18  2001/07/28 17:18:33  paul_noel
 *	ah
 *	
 *	Revision 1.17  2001/05/25 13:28:25  paul_noel
 *	Fix map solution CR5006
 *	
 *	Revision 1.14  2001/05/21 12:24:10  paul_noel
 *	update extern for VDtblGetMapInfo
 *	
 *	Revision 1.9  2001/05/07 14:28:55  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.8  2001/05/02 21:30:28  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.7  2001/04/25 20:43:48  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.6  2001/04/24 21:17:26  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.5  2001/04/20 13:07:59  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/04/17 22:13:35  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/04/06 15:16:10  ylong
 *	TR3320
 *	
 *	Revision 1.2  2001/01/10 16:46:25  art
 *	sp merge
 *	
 *
 * History:
 *
 *      04/14/95  	R. Manem 	Creation 
 *      04/24/95  	R. Manem 	Modified names of review attribute
 *					gadgets
 *      05/15/95  	R. Manem 	Modified VDdrw_rowInfo structure
 *					to handle new format for summarization
 *					criteria
 *	05/26/95	R. Manem	Added "Split Table" definitions
 *	06/07/95	Y. Zhu	        Added "Edit Table Row" definitions
 *	07/14/95	Y. Zhu	        Added att driven symbol gadget labels
 *	08/16/95	R. Manem	Added constants for column, char sizes
 * 	12/15/97 	vini		added VD_TBL_SELECT_ALL .
 *      01/10/01        ah              sp merge
 */

#ifndef vd_vdtblcmddef_include
#       define vd_vdtblcmddef_include

#ifndef acrg_collect_include
#	include "ACrg_collect.h"
#endif

#ifndef VDdrwlo_h
#	include "VDdrwlo.h"
#endif

/* form pointer */

#define VD_FP          me^^CEO.forms[0].form_ptr

/* command types */

#define	CREATE_TABLE			0
#define	MODIFY_TABLE			1
#define	SPLIT_TABLE			2
#define	VD_CMD_TBL_HDR			3
#define	VD_CMD_STBL_PL			4
#define	VD_CMD_ITBL_PL			5

/* form labels */

#define CREATE_TABLE_FORM		0
#define SPLIT_TABLE_FORM		1
#define VD_FORM_PLTBLHDR		2
#define VD_FORM_PLSTBL			3

/* form names */

#define VD_PLHDR_FORM_NAME         "VDplaceTblHdr"
#define VD_PLSTBL_FORM_NAME         "VDplStageTbl"

/* table type code */

#define VD_DRW_TBLTYPE_BOM		10
#define VD_DRW_TBLTYPE_GEN		11

/* names of table types */

#define VD_DRW_BOM_TYPE_NAME		"BOM"
#define VD_DRW_BOMX_TYPE_NAME		"BOMX"

/* column title for user defined columns to be used in Create Table Form */

#define VD_DRW_USERCOL_TITLE		"USER_DEFINED"
#define VD_DRW_FIXEDTEXT_TITLE		"FIXED_TEXT"
#define VD_DRW_ITEMNO_TITLE		"ITEMNO"
#define VD_DRW_QUANTITY_TITLE		"QUANTITY"
#define VD_DRW_OVERFLOW_TITLE 		"OVERFLOW"

/* Stage table type */

#define VD_STBL_PART_LIST		"Part List"
#define VD_STBL_INDEX			"Index"
#define VD_STBL_MODEL			"Model_obj"
#define VD_STBL_ITEM                    "Item"
#define VD_DRW_STBL_PLIST		0
#define VD_DRW_STBL_INDEX		1
#define VD_DRW_STBL_MODEL		2
#define VD_DRW_STBL_ITEM                3

/* gadgets for "Place Table Header/Create Table by Stage" form */

#define VD_HDR_TBL_TITLE		11
#define VD_HDR_TBL_TYPE_FLD		14
#define VD_HDR_SRCH_BTN			16
#define VD_HDR_NB_FMTS_TXT		13
#define VD_HDR_FMT_LIST_FLD		17
#define VD_HDR_TBL_LOC_BTN		22
#define VD_HDR_SHOW_BTN			20
#define VD_HDR_TBL_NAME_FLD		24

#define VD_STBL_TBL_TITLE		37
#define VD_STBL_CR_TYPE_TXT		25
#define VD_STBL_CR_TYPE_FLD		26
#define VD_STBL_STAGE_TXT		27
#define VD_STBL_STAGE_FLD		28
#define VD_STBL_NAME_TXT		29
#define VD_STBL_NAME_FLD		30
#define VD_STBL_TREESET_FLD		31
#define VD_STBL_INDEXTYP_TXT		35
#define VD_STBL_INDEXTYP_FLD		36
#define VD_STBL_FILE_TXT		32
#define VD_STBL_SET_TXT			33
#define VD_STBL_TYPE_TXT		34
#define VD_STBL_ITEM_TGL		38
#define VD_STBL_ITEM_TXT		39
#define VD_STBL_STARTNO_FLD		40
#define VD_STBL_STARTNO_TXT		41
#define VD_STBL_ADS_TXT			47
#define VD_STBL_ADS_FLD			48
#define VD_STBL_MSG_FLD			10
#define VD_STBL_TREE_COLS               58
#define VD_STBL_DAT_TXT                 59
#define VD_STBL_DAT_TOG                 60

#define VD_ITBL_TBL_TITLE		42
#define VD_ITBL_IMPORTF_TXT		43
#define VD_ITBL_IMPORTF_FLD		44
#define VD_ITBL_SEPARATOR_TXT		45
#define VD_ITBL_SEPARATOR_FLD		46
#define VD_ITBL_COLS_FLD                49
#define VD_ITBL_DAT_TXT                 50
#define VD_ITBL_MAP_TXT                 51
#define VD_ITBL_COL_TXT                 52
#define VD_ITBL_ADD_BTN                 53
#define VD_ITBL_SUB_BTN                 54
#define VD_ITBL_MVS_TXT                 55
#define VD_ITBL_UP_BTN                  56
#define VD_ITBL_DN_BTN                  57
#define VD_ITBL_TOP_LINE                62
#define VD_ITBL_MID_LINE                63
#define VD_ITBL_STYLE_BTN               64
#define VD_ITBL_STYLE_FLD               65


/* gadgets for "Create/Modify Table" form */

#define VD_TBL_FORM_TITLE		11

#define VD_TBL_SELCOL_LIST_FLD		12
#define VD_TBL_SHOW_SELCOL_BTN		19

#define VD_TBL_ADS_TXT			31
#define VD_TBL_ADS_FLD			16
#define VD_TBL_SUM_SELROWS_BTN		17
#define VD_TBL_ITEM_SELROW_BTN		18
#define VD_TBL_SHOW_ROWCNTS_BTN		39
#define VD_TBL_GEN_ITEMNBS_BTN		15

#define VD_TBL_ROW_CNTS_FLD		48
#define VD_TBL_ROWCNTS_ACC_BTN		54

#define VD_TBL_MOVE_UP_BTN		29
#define VD_TBL_MOVE_DN_BTN		30
#define VD_TBL_SCROLL_TO_BTN		40
#define VD_TBL_SCROLL_TO_FLD		43
#define VD_TBL_BLK_START_FLD		41
#define VD_TBL_BLK_END_FLD		36

#define VD_TBL_BLK_START_TXT		25
#define VD_TBL_BLK_END_TXT		28

#define VD_TBL_MOVE_TYPE_BTN		49
#define VD_TBL_STEP_SIZE_FLD		42

#define VD_TBL_ADD_ROW_BTN		38
#define VD_TBL_DEL_ROW_BTN		37

#define VD_TBL_VIS_COLDISP_FLD		21
#define VD_TBL_INV_COLDISP_FLD		34

#define VD_TBL_VIS_COLTITL_FLD		24
#define VD_TBL_INV_COLTITL_FLD		35

#define VD_TBL_SCROLL_LEFT_BTN		45
#define VD_TBL_SCROLL_RIGHT_BTN		44

#define VD_TBL_REV_ROWVALS_BTN		32
#define VD_TBL_REV_ROWVALS_FLD		33

#define VD_TBL_BOM_BTNS_GRP		47
#define VD_TBL_BOM_ATTR_GRP		52

#define VD_TBL_COLDISP_GRP		50
#define VD_TBL_ROWCNTS_GRP		57

#define VD_TBL_SELECT_ALL		58

#define VD_TBL_RESET_ROW_BTN		59
#define VD_TBL_RESET_ROW_TGL		60
#define VD_TBL_SELECT_ITEMS             61

/* reset options */
#define VD_TBL_RESET_OPT_COL		"column"
#define VD_TBL_RESET_OPT_ROW		"row"
#define VD_TBL_RESET_OPT_ROWCOL		"row*col"
#define VD_TBL_RESET_OPT_TBL		"table"


/* form states for "Create Table" command */

#define VD_TBL_BLNK_DISP_ST		1
#define VD_TBL_COL_DISP_ST		2
#define VD_TBL_ROW_CNTS_ST		3

/* gadgets for "Split Table" form */

#define VD_TBL_SPL_LOC_ROW_BTN		18
#define VD_TBL_SPL_LOC_ROW_TXT		20
#define VD_TBL_SPL_PART_LST_FLD		12
#define VD_TBL_SPL_NUM_ROWS_TXT		21

/* return codes for locate */

#define	VD_TBL_LOCATE_ROW		258
#define	VD_TBL_LOCATE_CS		259
#define	VD_TBL_NO_CS_NEEDED		260

/* types for the flag in VDdrw_rowInfo structure */

#define VD_DRW_ROW_OLD			0
#define VD_DRW_ROW_NEW			1
#define VD_DRW_ROW_MOD			2

/* parameters for column sizes */

#define VD_TBL_SCROLL_WIDTH		26
#define VD_TBL_ROWNO_COL_CHARS		4
#define VD_TBL_COLSEP_WIDTH		4
#define VD_TBL_CHAR_WIDTH		9
#define VD_TBL_CONST_FACTOR		14

/* parameters used for edit tble row */
#define VD_ETR_FORM_ACCEPT          	1
#define VD_ETR_FORM_EXECUTE             2
#define VD_ETR_FORM_CANCEL              4

#define VD_ETR_INV_ORI_ROW                  12
#define VD_ETR_VIS_ORI_ROW                  21

#define VD_ETR_INV_NEW_ROW                  15
#define VD_ETR_VIS_NEW_ROW                  22

#define VD_ETR_INV_TIT_ROW                  18
#define VD_ETR_VIS_TIT_ROW                  20

#define VD_ETR_SHIF_COL_NUM             12
#define VD_ETR_SCRL_LIF_BTN             13
#define VD_ETR_SCRL_RIG_BTN             17
#define VD_ETR_NEXT_ROW                 25
#define VD_ETR_PREV_ROW                 26
#define VD_ETR_TEXT_SIZE                80
#define VD_ETR_LINE_OUT                 254
#define VD_ETR_FORM_INFO        	255
#define VD_ETR_FORM_DISPLAY             256
#define VD_ETR_FORM_PREVROW             257
#define VD_ETR_FORM_NEXTROW             258
#define VD_ETR_colWidthMax              14

#define	VD_ETR_RVT_ROW_BTN		315
#define VD_ETR_RVT_ROW_TGL		318

#define VD_ETR_viewWidthMax             3*VD_ETR_colWidthMax
#define VD_ETR_defaultShiftCol          1

/* Check Tables command form */
#define VD_DRW_CHECK_TABLE              17

/* type definitions for VDdrw_mapInfo structure */
#define VD_DRW_TYPE_XML                "XML"
#define VD_DRW_TYPE_PPL                "PPL"
#define VD_DRW_TYPE_TXT                "TXT"

/* structure storing the map info for the "Create Table by Import" command */
struct VDdrw_mapInfo   
{
  IGRchar  type[24];   /* defines the type of the data <PPL> <XML> <TXT> etc */
  IGRint   rows;       /* defines the number of rows of data in the allocation */
  IGRchar  **maps;     /* actual char data location */
};


/* structure storing the row info for the "Create/Modify" command */
struct VDdrw_rowInfo
{
	struct GRid		rowId;		/* GRid of the VDdrwTblRow 
						   object */
	IGRint			nbObjs;		/* number of objects in that 
						   row */
	IGRint			startIndex;	/* starting index in the list of
						   located objects */
	struct VDdrwlo_qtyExp	qty;		/* quantity info */
	IGRshort		flag;		/* flag specifying whether 
						   the row has been modified 
						   or is new */
};

struct VDdrw_colInfo
{
	IGRint		nbLines;	/* number of lines in this column */
	IGRint		nbChars;	/* max number of characters (column
					   width) */
	IGRchar		(*colTitles)[VD_DRWLO_CHR_DESC];
					/* list of titles for this column
					   - will not actually
					   correspond to the entries in the
					   table header */
};

/* structure for edit table row */

struct VDhdrRowinfo{
       IGRint           nbHdrRows;     /* number of row in this hdr */
       IGRint           startRowNo;    /* starting row number of this hdr*/
       struct GRid      hdrIds;        /* hdr ids                        */
};

struct VDrowDataList{
       IGRint           lineNos;      /* line index in the row         */
       IGRint           colNos;       /* column index in the  table    */
       IGRchar          *values;      /* data in (linNo, colNos)       */
};


/* structure for Stage table and Import table information */

struct VDtblStImInfo {
	IGRchar		importFile[1023]; /* import file name for CTBI      */
         IGRchar         styleSheet[1023];  /* style sheet name for CTBI    */
  
	IGRchar		separator[10];	 /* separator for each value in row */

	IGRint		itemNoOpt;	 /* iten number on or off           */
	IGRint		startItemNo;	 /* start item number               */

	IGRchar		adsTblName[80];  /* attribute driven symbol name    */
        IGRint          fileType;        /* fileType 
					 * 0 = txt
					 * 1 = xml
					 * 2 = PPL
	 				 * other? not yet selected */
        struct         VDdrw_mapInfo    mapInfo;        /* mapping data */
  
  
};

#endif /* vd_vdtblcmddef_include */
