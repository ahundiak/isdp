/************************************************
 *** definitions for the Product Data Manager ***
 ************************************************/

#ifndef PDMdef
#define PDMdef	1

/* PDM constants */
#define PDM_DATABASE_ATTRS  1
#define PDM_LOC_ATTRS	    2
#define PDM_BOM_ATTRS	    3
#define PDM_CATALOG_ATTRS   4
#define PDM_USER_ATTRS	    5
#define PDM_BUFFER_TERM     '\1'
#define PDM_BUFFER_SIZE	    7000

/* form display coordinates */
#define PDM_FORM_XCOORD		10
#define PDM_FORM_YCOORD		74
#define PDM_REFRESH_XCOORD	505
#define PDM_REFRESH_YCOORD	469
#define PDM_SEARCH_XCOORD	20
#define PDM_SEARCH_YCOORD	74
#define PDM_BUTTON_XCOORD	20
#define PDM_BUTTON_YCOORD	74
#define PDM_ATTR_XCOORD		20
#define PDM_ATTR_YCOORD		74

/* NFM constants */
#define PDU_NFM_ATTR_COL	0
#define PDU_NFM_DATA_COL	1
#define PDU_NFM_SYN_COL		2
#define PDU_NFM_PDM_COL	        3
#define PDU_NFM_READ_COL	4
#define PDU_NFM_WRITE_COL	5
#define PDU_NFM_UPDATE_COL	6
#define PDU_NFM_DELETE_COL	7
#define PDU_NFM_REQ_COL		8
#define PDU_NFM_CHKIN_COL       9
#define PDU_NFM_CHKOUT_COL      10
#define PDU_NFM_SEQNO_COL	11
#define PDU_NFM_ATTRNO_COL      12
#define PDU_NFM_TABLENO_COL     13
#define PDU_NFM_LISTNO_COL	14
#define PDU_NFM_ADVICE_COL      15
#define PDU_NFM_MOD_OFFSET	16	

#define PDU_NFM_DATA_ROW	0
#define PDU_NFM_DEFAULT_ROW	0
#define PDU_NFM_DISP_VAL_COL	1
#define PDU_NFM_ATTRDEF_LEN	30
#define PDU_NFM_ATTR_LEN	20
#define PDU_NFM_DATATYPE_LEN	15
#define PDU_NFM_SYN_LEN		40
#define PDU_NFM_BUFF_COLS	16
#define PDU_NFM_USERNAME_COL	0
#define PDU_NFM_PASSWD_COL	1
#define PDU_NFM_ENV_COL		2

/* RPS constants */
#define PDU_RPS_ATTR_COL	0
#define PDU_RPS_POS_COL		1
#define PDU_RPS_WIDTH_COL	2
#define PDU_RPS_JUST_COL	3
#define PDU_RPS_TYPE_COL	4

/* types of forms */
#define PDU_ADD_ITEM		0
#define PDU_ADD_TABLE		1
#define PDU_MOD_ITEM		2
#define PDU_LIST_ITEMS		3
#define PDU_COPY_ITEM		4
#define PDU_COPY_CAT		5
#define PDU_REVIEW_ITEM		6
#define PDU_ADD_PART            7
#define PDU_MOD_PART            8
#define PDU_PLACE_PART          9

/* attribute name */
#define PDU_NFM_VERSIONLIMIT    "n_versionlimit"  
#define PDU_NFM_CATALOG_NAME	"n_catalogname"
#define PDU_NFM_CATALOG_DESC	"n_catalogdesc"
#define PDU_NFM_CATALOG_APPL	"n_application"
#define PDU_NFM_CATALOG_TYPE	"n_type"
#define PDU_NFM_ACL_NO		"n_aclno"
#define PDU_NFM_RPTNAME		"n_reportname"
#define PDU_BOM_CATALOG_NAME	"p_catalogname"
#define PDU_BOM_CATALOG_WIDTH	"15"
#define PDU_NFM_ITEM_NO		"n_itemno"
#define PDU_PARTID_ATTR		"n_itemname"
#define PDU_REVISION_ATTR	"n_itemrev"
#define PDU_PARTTYPE_ATTR	"p_parttype"
#define PDU_EXPLODE_ATTR	"p_explode"
#define PDU_FILENAME_ATTR	"n_cofilename"
#define PDU_NFM_STATE_NO	"n_stateno"
#define PDU_CREATE_DATE		"p_creationdate"
#define PDU_CREATE_TIME		"p_creationtime"
#define PDU_UPDATE_DATE		"p_udpatedate"
#define PDU_UPDATE_TIME		"p_updatetime"
#define PDU_NFM_ITEMLOCK	"n_itemlock"
#define PDU_NFM_COOUT		"n_coout"
#define PDU_NFM_COLEVEL		"n_colevel"
#define PDU_NFM_ARCHIVE		"n_archivestate"
#define PDU_NFM_PREVSTATE	"n_prevstateno"
#define PDU_NFM_ITEMNUM		"n_itemnum"
#define PDU_NFM_CREATOR		"n_creator"
#define PDU_NFM_UPDATER		"n_updater"
#define PDU_NFM_FILENO		"n_fileno"
#define PDU_NFM_FILECLASS	"n_fileclass"
#define PDU_NFM_FILEVERS	"n_fileversion"
#define PDU_NFM_ARCHNO		"n_archiveno"
#define PDU_NFM_PENDFLAG	"n_pendingflag"
#define PDU_NFM_PENDUSER	"n_pendinguser"
#define PDU_NFM_CIFILENAME	"n_cifilename"
#define PDU_NFM_CIFILESIZE	"n_cifilesize"
#define PDU_NFM_CIUSER		"n_ciuser"
#define PDU_NFM_CIDATE		"n_cidate"
#define PDU_NFM_CITIME		"n_citime"
#define PDU_NFM_FILECO		"n_fileco"
#define PDU_NFM_COCMT		"n_cocomment"
#define PDU_NFM_COSANO		"n_cosano"
#define PDU_NFM_CISANO          "n_cisano"
#define PDU_NFM_COUSER		"n_couser"
#define PDU_NFM_CODATE		"n_codate"
#define PDU_NFM_COTIME		"n_cotime"
#define PDU_ATTACHED_ATTR	"p_attached"
#define PDU_ASSEMBLY_ATTR	"p_assembly"
#define PDU_MAXLEVEL_ATTR	"p_maxlevel"
#define PDU_ATTACHED_WIDTH	"2"
#define PDU_ORIENT_ATTR		"p_orient"
#define PDU_ORIENT_WIDTH	"281"
#define PDU_LEVEL_ATTR		"p_level"
#define PDU_LEVEL_WIDTH		"15"
#define PDU_SEQNUM_ATTR		"p_seqno"
#define PDU_SEQNUM_WIDTH	"2"
#define PDU_VIEWID_ATTR		"p_viewid"
#define PDU_VIEWID_WIDTH	"26"
#define PDU_SERIAL_ATTR		"p_childno"
#define PDU_SERIAL_WIDTH	"21"
#define PDU_QUANTITY_ATTR	"p_quantity"
#define PDU_INCPARTRPT_ATTR	"p_incpartrpt"

/* parameter column positions */
#define PDU_PARANUM_COL		0
#define PDU_PARATYPE_COL	1
#define PDU_PARANAME_COL	2
#define PDU_PARADATA_COL	3
#define PDU_IOTYPE_COL		4
#define PDM_PARANUM_COL		0
#define PDM_PARANAME_COL	1
#define PDM_PARADATA_COL	2
#define PDM_PARATYPE_COL	3
#define PDM_IOTYPE_COL		4

/* report list types */
#define LOC_FORMAT_LIST		0
#define LOC_SEARCH_LIST		1
#define LOC_SORT_LIST		2
#define CAT_FORMAT_LIST		3
#define CAT_SEARCH_LIST		4
#define CAT_SORT_LIST		5

/* grnuc values */
#define MAX_VALUE               256

/* PDM dynamic attr constants */
#define PDU_DYN_ATTRNO_COL      0
#define PDU_DYN_ATTR_COL        1
#define PDU_DYN_DATA_COL        2
#define PDU_DYN_SYN_COL         3
#define PDU_DYN_WRITE_COL       4
#define PDU_DYN_REQ_COL         5

/* PDM dynamic attr constants */
#define PDU_DYN_DEFAULT_VAL_COL 0
#define PDU_DYN_LISTNO_COL      1
#define PDU_DYN_MAX_VAL_COL     2
#define PDU_DYN_MIN_VAL_COL     3

/* general constants */
#ifndef NULLSTR
#define NULLSTR			""
#endif
#ifndef NULLCHAR
#define NULLCHAR		'\0'
#endif
#ifndef NULL
#define NULL			0
#endif
#ifndef TRUE
#define TRUE			1
#endif
#ifndef FALSE
#define FALSE			0
#endif


#endif

