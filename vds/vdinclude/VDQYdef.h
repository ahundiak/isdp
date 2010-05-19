/*
 * I/VDS
 *
 * definition for the query command
 */

#ifndef	vdqydef_include
	#define	vdqydef_include


#define QUERY_LEN   4096
#define QY_E_SYNTAX     -1

/*
 * gadget used in the form_interface.
 */

#define LIST_FORM   0

/* Gadgets */

#define QUIT			4
#define EXIT			1
#define MESSAGE			10

#define FORM_TITLE		11
#define ELEM_TYPE_TITLE		13
#define CONDITION_TITLE		57
#define VALUE_TITLE		52

#define QUERY			48
#define QUERY_TITLE		53
#define	QUERY_NAME		55
#define	QUERY_DESCRIPTION	56
#define	QUERY_NAME_TITLE	61
#define	QUERY_DESCR_TITLE	63

#define	QUERY_CMD_DELETE	58
#define	QUERY_CMD_LOAD		59
#define	QUERY_CMD_SAVE		60


#define LOCATE_OBJECT		15
#define BACKUP_BUTTON		31

#define MACRO_LIST		12
#define MACRO_FIELD		42

#define WHERE_CHECK		17
#define WHERE_NOT_CHECK		18

#define ATTRIBUTE_LIST		43
#define ATTRIBUTE_FIELD		62

#define ATTR_SYMB_TOGGLE	44

#define NE			25
#define EQ			26
#define GE			27
#define LE			29
#define GT			30
#define LT			32

#define VALUE_FIELD		51
#define VALUE_LIST		45

#define AND_CHECK		73
#define AND_NOT_CHECK		74
#define XOR_CHECK		47
#define OR_CHECK		75
#define OR_NOT_CHECK		76

#define EDIT_QRY_TOGGLE		92

#define NEW_NAME_TITLE 		89
#define NEW_NAME 		90

#define EDIT_QUERY		91
#define EDIT_QUERY_TITLE	87

#define QRY_CHECK_IN	        93

/* Query States */

#define NO_STATE		-1
#define MACRO			0
#define WHEREG			1
#define ATTRIBUTE		2
#define CONDITION		3
#define VALUE1			4
#define CONJUNCTION		5


#define MAX_CHAR_LINE		81


/*
 * gadgets for the load/delete/save
 */

#define	QRY_SUB_DELETE_TITLE	11
#define	QRY_SUB_LOAD_TITLE	16
#define	QRY_SUB_SAVE_TITLE	19

#define	QRY_SUB_FILE_TITLE	15
#define	QRY_SUB_FILE		12

#define	QRY_SUB_NAME_TITLE	14
#define	QRY_SUB_NAME		13

#define	QRY_SUB_ALL_BUTTON	17
#define	QRY_SUB_CLR_BUTTON	18

#define	QRY_SUB_PFX_TOGGLE	20
/*
 * Command Object types.
 */
#define	QRY_COB_LOAD		0
#define	QRY_COB_SAVE		1
#define	QRY_COB_DELETE		2

#define	QRY_COB_CRT		0
#define	QRY_COB_EXEC		1


/*
 * form gadgets for VDquery0 (select queries)
 */
#define	QRY_SEL_EXIST_TITLE		61
#define	QRY_SEL_EXIST			15
#define	QRY_SEL_FILE_OPT_TOGGLE		24
#define	QRY_SEL_REVIEW_BUTTON		19
#define	QRY_SEL_DESC_TITLE		12
#define	QRY_SEL_DESC			56
#define	QRY_SEL_SET_ACTIVE		17
#define	QRY_SEL_RESET_ACTIVE		18
#define	QRY_SEL_ACTIVE_TITLE		13
#define	QRY_SEL_ACTIVE			16
#define	QRY_SEL_DEF_TITLE		53
#define	QRY_SEL_DEF			48
#define	QRY_SEL_SORT_LIST_TOGGLE	21
#define	QRY_SEL_SORT_LIST		22


/*
 * Query strings to use.
 */
#define	QRY_str_DIR_NAME	"query"

#define	VD_QRY_Classname	"VDquery"

/*
 * Query key-words in the ASCII file.
 */
#define	VD_QRY_FILE_COMMENT	"#"
#define	VD_QRY_ASCII_NAME	"<Name>"
#define	VD_QRY_ASCII_DEFINITION	"<Definition>"
#define	VD_QRY_ASCII_COMMENT	"<Comment>"	
#define	VD_QRY_ASCII_PREFIX	"<Prefix>"	

#define	VD_QRY_ASCII_HEADER	"Queries Support File Version 1.0"

#define	VD_QRY_ASCII_szNAME	6
#define	VD_QRY_ASCII_szDEF	12
#define	VD_QRY_ASCII_szCOMMENT	9	
#define	VD_QRY_ASCII_szPREFIX	8	

#define VD_LOCATE_STATUS	255   /* used for locate button on VDquery1 */
#define VD_LOCATE_OBJECT	256   /* used for locate button on VDquery1 */
#define VD_FORM_DISPLAY		257   /* used for locate button on VDquery1 */
#define VD_END_LOCATE           258

#define MAX_NB_LIST 3

/* type of list */

#define ELT_TYPE    1
#define ELT_ATTR    2
#define ELT_VAL     3

/* state table variable */
#define VD_QRY_ERROR 		0 
#define VD_QRY_SUCCESS 		1 
#define VD_QRY_START_IN_FORM	2 
#define VD_QRY_CHECK_EVN        3

/* constants for querylis and query class_name */ 
#define 	Qrylistnum      50
#define 	Qrylistlen      256
#define 	Qrynamenum      100
#define 	Qrynamelen      30

#define 	MAX_NB_ATT	25
#define 	MAX_NAME	30


struct AttrDef{
	IGRchar			name[DI_PATH_MAX];
	int			nb_value;
	IGRchar			**value;
};

struct ElemType{
	IGRint			selected;
	IGRchar			user_name[DI_PATH_MAX];
	IGRchar			real_name[DI_PATH_MAX];
	int			nb_att;
	struct AttrDef		att[MAX_NB_ATT];
};

struct List{
    int     type;
    int     nb_alloc;
    int     num;
    IGRchar **name;
};

struct  att_val
{

        IGRshort        type;
        IGRchar         att_name[DI_PATH_MAX];
        union
        {

                IGRchar         att_txt[DI_PATH_MAX];
                IGRdouble       att_exp;
        } value;
};

struct Qry_coll
{

        IGRchar                 ename[DI_PATH_MAX];
        IGRchar                 iname[DI_PATH_MAX];
        IGRint                  nb_att;
        struct  att_val         desc[MAX_NB_ATT];
};

struct VD_macclsstr
{
        IGRchar                 *mac_name;
        IGRchar                 *cls_name;
};
/* add filename, 1/2/96 */
struct Qry_list
{
        IGRchar                 name[DI_PATH_MAX];
        IGRchar                 filename[MAX_NAME];
};

#endif
