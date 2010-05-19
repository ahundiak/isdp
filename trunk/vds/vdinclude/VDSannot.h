/* $Id: VDSannot.h,v 1.3 2001/01/10 16:46:25 art Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSannot.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSannot.h,v $
 *	Revision 1.3  2001/01/10 16:46:25  art
 *	sp merge
 *	
 *	Revision 1.2  2001/01/09 21:49:31  art
 *	ah
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *
 * Revision 1.2  2000/10/26  17:48:12  pinnacle
 * pn
 *
 * Revision 1.1  2000/10/26  17:24:08  pinnacle
 * pn
 *
 * Revision 1.1  2000/05/03  21:13:42  pinnacle
 * Created: vds/vdinclude/VDSannot.h by apazhani for Service Pack
 *
 * Revision 1.2  2000/02/15  20:19:16  pinnacle
 * pnoel
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1997/11/05  08:20:32  pinnacle
 * Replaced: vdinclude/VDSannot.h for:  by ksundar for vds
 *
 * Revision 1.3  1997/09/18  03:12:06  pinnacle
 * Replaced: vdinclude/VDSannot.h for:  by mdong for vds
 *
 * Revision 1.2  1997/08/26  22:11:42  pinnacle
 * Replaced: vdinclude/VDSannot.h for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 *
 * History:
 *
 *			  --		Creation
 *	12/07/94	R. Manem	flag for VDgetFreeItemNo message :
 *						INQ_ONLY, ASSIGN
 *
 *	12/  /94	R. Manem	gadget labels for "Review Elements
 *					with Item Numbers" form
 *
 *	06/30/95	Y.Zhu	        gadget labels and struct 
 *                                      VDitmPrefixInfo for "Define Item Prefix
 *                                      Definition"
 *	07/15/95	Y.Zhu	        modify gadget labels for Rev Item  #
 *
 *	11/05/95	Sundar	        Added gadgets EXP_TYP_FIELD &
 *					EXP_NAM_FIELD for expression
 *	05/03/2000	Alwin	        Added gadgets for BOX Ratio's
 *      10/26/2000      Paul Noel       Added defaults for some gadgets
 *
 *      01/09/01        ah              sp merge
 * -------------------------------------------------------------------*/


/****************************************************************************


		File:	VDSannot.h
		Type:   c include file
		Use:	Defines constants for Leader Line form Parameters
		Date:	19 September 1991 - Genesis -
		Autr:	adz - isdc
		
***************************************************************************/

#ifndef VDSannot_include

#define VDSannot_include

#define		VD_CREATE_FORMAT	0
#define		VD_PLACE_FORMATS	1
#define		VD_PLACE_ITEM		2
#define		VD_PLACE_WELD		3

#define		VD_READ_FORMATS		4
#define		VD_WRITE_FORMATS	5

/* gadget labels for the form VDSFormDef */
#define 	EXIST_FORMAT  	13
#define		MACRO_LIST	14
#define		MACRO_NAME	16
#define 	TXT_OUTPUT	18
#define 	PARAS_FIELD 	22
#define 	EXP_TYP_FIELD 	15
#define 	EXP_NAM_FIELD 	23
#define 	FORMAT_OUTPUT	24
#define		EXPR_NAME	27
#define		WRITE_FORMATS	29
#define		READ_FORMATS	30
#define		DELETE_FORMAT	31

#define		VD_TL_TOP	19
#define		VD_TL_CENTER	20
#define		VD_TL_BOTTOM	21
#define		VD_TL_UNDER	22

/* gadget labels for the form VDRevElWtItem */

#define		VD_ITM_EXPR_FLD		16
#define		VD_HLT_OPT_BTN		19
#define		VD_ITM_LIST_FLD		18
#define		VD_TBL_NAME_FLD		14
#define		VD_FIT_OBJ_LST		21
#define		VD_ITM_BAL_TOG		13
#define		VD_ITM_FIT_NME		23
#define		VD_ITM_FIT_FLD		24
#define		VD_ITM_FIT_3DO		22

/* buffer size for text in VDRevElWtItem form */

#define 	MAXROWSIZE		64

/*
 * gadgets for placement angle of formatted text
 */
#define		VD_TEXT_ANGLE		43

/*
 * gadgets for display the box
 */
#define         VD_DISP_BOX     35	/* yes rectangle */
#define         VD_ADISP_BOX    31	/* auto rectangle */

/*
 * box option gadgets.
 */
#define		VD_BOX_NO	42
#define		VD_BOX_AUTO	43
#define		VD_BOX_YES	44
#define		VD_BOX_RAT_TEXT	46  /* added by Alwin */
#define		VD_BOX_RAT_VAL	50  /* added by Alwin */
#define		VD_BOX_RAT_TEXT_AU	73  /* added by Alwin */
#define		VD_BOX_RAT_VAL_AU	74  /* added by Alwin */
#define		VD_BOX_ELLIPSE	70
#define		VD_TEXT_CAPS	48
#define		VD_TEXT_MIRROR	47
#define		VD_TEXT_REVERSE	49

/*
 * gadgets for the auto formatted text command.
 */
#define		VDTEXTANGLE	43
#define		VDTEXTCAPS	69
#define		VDTEXTREVERSE	71

#define		VD_BOX_NO_I		0
#define		VD_BOX_AUTO_I		1
#define		VD_BOX_YES_I		2
#define		VD_TEXT_CAPS_I		5
#define		VD_BOX_ELLIPSE_I	10

/*
 * box display instance values.
 */
#define		VD_box_NO_DISPLAY	0x0001
#define		VD_box_AUTOMATIC	0x0002
#define		VD_box_DISPLAY		0x0004
#define		VD_box_ELLIPSE		0x0008
#define		VD_text_CAPS		0x0001
#define		VD_text_QUERY_INFO	0x0002
#define		VD_text_MIRROR		0x0004
#define		VD_text_REVERSE		0x0008

/*
 * Parameter Selection by bit operation
 */
#define 	NOT_SELECTED    0x0
#define 	SELECTED        0x1
#define 	NOT_SELECTABLE  0x2

/*
 * Info for constant sizes.
 */
#define		MSG_SIZE	80
#define		TEXT_SIZE	256
/*
#define		DB_TEXT_SIZE	512
*/
#define		DB_TEXT_SIZE	80
#define		BUFFER_MAX	1000
#define		MAX_FORMAT	20
#define		macro_MAX	40
#define		ROW_MAX		10 

#define		NO_MORE_PARAMS	-1

/* For VDSleader directory */
#define 	TEXT_FROM_EXPRESSION	26
#define 	STATE_P_LOC_EXPN	16
#define 	AN_ROOT_EXPN		3
#define 	BACK_TO_FORMAT_COMMAND  255

/* form interface constants */
#define		VD_FTEXT_CANCEL		1
#define		VD_FTEXT_ACCEPT		2
#define		VD_FTEXT_TERMINATE	3
#define		VD_FTEXT_FORM_INFO	255

#define		VD_FTEXT_EXPR_MAX	20

/* read/write constands */
#define	VD_FTEXT_FILE	"TextFormat"
#define	VD_FTEXT_DIR	":formats"
#define	VD_FTEXT_LDLINE	"ldline_"
#define	VD_FTEXT_LDTEXT	"ldtext_"
#define VD_FTEXT_FORMAT	"format"
#define	VD_FTEXT_TEXT	"TEXT"
#define	VD_FTEXT_FOR	"for"
#define	VD_FTEXT_OPEN	"{"
#define	VD_FTEXT_CLOSE	"}"

/*
 * sub-directory names
 */
#define	VD_FTEXT_STRING	"string"
#define VD_FTEXT_PARAMS	"params"

#define	VD_FOR_DEFAULT	"mac_def"

#define	VD_FTEXT_GLOBAL	"global"


/*
 * flag for VDgetFreeItemNo method of item manager
 */

#define INQ_ONLY        1
#define ASSIGN          2


/*
 * read/write constants
 */
#define VD_FTEXT_SUCCESS	1
#define VD_FTEXT_NO_FILE	2
#define	VD_FTEXT_NOT_READABLE	3
#define VD_FTEXT_SEVERE_ERROR	4
#define	VD_FTEXT_NOT_WRITEABLE	5

/*
 * text attribute
 */
#define TEXTANGLE		0
#define TEXTCAPS		1
#define TEXTCAPS_NO		2
#define TEXTMIRROR		3
#define TEXTMIRROR_NO		4
#define TEXTREVERSE		5
#define TEXTREVERSE_NO		6


/* gadgets name for "Define Item Prefix Definition" */
#define	VD_DIPD_DEL_ROW         15
#define	VD_DIPD_INS_ROW         13
#define	VD_DIPD_ARROW_U         18
#define	VD_DIPD_ARROW_D         19
#define	VD_DIPD_SEL_FLD         14
#define	VD_DIPD_FORM_INFO       200 
#define	VD_DIPD_FORM_CANCEL     100
#define	VD_DIPD_FORM_EXECUTE    101 
#define	VD_DIPD_FORM_ACCEPT     102 
#define	VD_DIPD_FORM_DELROW     103 
#define	VD_DIPD_FORM_INSROW     104 

#define VDCHGPREV               1
#define VDCHGNEXT               2
#define VDDELSELE               3

#define VD_DIPD_MAX_QRY_NAME_LEN 17
#define VD_DIPD_MAX_QRY_DESC_LEN 81
#define VD_DIPD_MAX_QRY_DEF_LEN  1024

#define VD_FP          me^^CEO.forms[0].form_ptr 


/* structure for input/output */
struct	VDldline_expr{
	IGRchar	formatname[MAX_FORMAT];	/* format expression name	*/
	IGRchar	string[DB_TEXT_SIZE];	/* format string 	*/
	IGRchar	params[DB_TEXT_SIZE];	/* used parametrs	*/
	struct	GRid	expr_id;
};

struct  VDmacro_occ{
        IGRint  nb_exprs;               /* number of active expressions */
        IGRchar macro[TEXT_SIZE];       /* macro_name */
};

/* structures for Review elements with item number command object */

struct 	VDitemInfo 
{
	struct GRid	itemId;
	IGRchar		*itemStr;
};


struct	VDtblInfo
{
	IGRchar		*tblName;
	IGRint		nbItems;
	IGRint		startIndex;
};

struct VDitmQryPfxInfo{
      struct GRid          qry_id;  /* query ids          */
      struct GRmd_env      qry_env; /* query env          */
      IGRchar              qry_name[VD_DIPD_MAX_QRY_NAME_LEN];/* qry name */
      IGRchar              qry_def[VD_DIPD_MAX_QRY_DEF_LEN];/* qry def */
      IGRchar              qry_desc[VD_DIPD_MAX_QRY_DESC_LEN];/* qry desc */
      IGRint               pfx_index;/* prefix index */
      IGRchar              pfx_name[VD_DIPD_MAX_QRY_NAME_LEN]; /* prefix name */
      IGRint               mod_flag;  /* =0 not modified, =1 modified */
};

/* used for instance */
struct  VDitemInfoNew
{
        struct GRid     itemId;
        IGRchar        itemStr[40];
};
struct  VDtblInfoNew
{
        IGRchar         tblName[50];
        IGRint          nbItems;
        IGRint          startIndex;
};
struct  VDFrmtxt
{
	IGRdouble	textAngle;
	IGRuchar	textCaps;
	IGRuchar	textMirror;
	IGRuchar	textReverse;
};

typedef struct
{
  IGRchar       LdOffset[TEXT_SIZE];
  IGRchar       LdLeader[TEXT_SIZE];
  IGRchar       LdAngle[TEXT_SIZE];
  IGRchar       X[TEXT_SIZE];
  IGRchar       Y[TEXT_SIZE];
  IGRchar       Z[TEXT_SIZE];
  IGRboolean    Offset;
  IGRboolean    Leader;
  IGRboolean    Action; 
} TVDFrmAuTxtData;



#endif
#if 0
typedef struct
{
  IGRchar       LdOffset[TEXT_SIZE];
  IGRchar       LdLeader[TEXT_SIZE];
  IGRchar       LdAngle[TEXT_SIZE];
  IGRchar       X[TEXT_SIZE];
  IGRchar       Y[TEXT_SIZE];
  IGRchar       Z[TEXT_SIZE];
  IGRboolean    Offset;
  IGRboolean    Leader;
  IGRboolean    Action;
} TVDFrmAuTxtData;
#endif
