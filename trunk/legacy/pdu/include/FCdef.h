#define ERROR_CHK							       \
	if(!(sts & 0x00000001)) {					       \
	  printf("PDUfc -- error at line %d in \"%s\"\n",__LINE__,__FILE__);   \
	  om$report_error(sts=sts);					       \
	  return(OM_S_SUCCESS); 					       \
	}

#define ERROR_HEADER(name) 					\
        printf("PDUfc -- %s -- Error at line %d in \"%s\"\n", 	\
               name,__LINE__,__FILE__);

#define LIST_SIZE	120
#define MAX_FORMS	5
#define MAX_COLUMN_COUNT	100

#define TWO_COLUMN_FORM		10
#define FOUR_COLUMN_FORM	11
#define THREE_COLUMN_FORM	12
#define FREE_FORMAT_FORM	13
#define LOGIN_FORM		14
#define REFRESH_FORM		15
#define PRINT_FORM		16
#define BUTTON_FORM		17
#define ATTR_FORM		18
#define SEARCH_FORM		19
#define DEFINE_FORM		20
#define REVIEW_FORM		21
#define SECURITY_FORM		22
#define SIX_COLUMN_FORM		23

#define LEFT_JUSTIFIED		0
#define CENTER_JUSTIFIED	1
#define RIGHT_JUSTIFIED		2

#define NO_CANCEL	0
#define CANCEL_ALLOWED	1

#define DISPLAYED	0
#define SELECTED	1
#define ALL		2

#define HEADER		0
#define NO_HEADER	1

#define WRITE		0
#define APPEND		1

#define SETUP		0
#define V_SCROLL	1
#define H_SCROLL	2
#define RUN_TIME	3

#define ACTIVATE	1
#define DEACTIVATE	2

#define USER		0
#define ADMIN		1

#define NO_SELECT_SET		0
#define SELECT_SET_SINGLE_ROW	1
#define SELECT_SET_MULTI_ROW	2

#define NO_ATTR_LIST		0
#define SINGLE_SELECT_ATTR_LIST	1
#define MULTI_SELECT_ATTR_LIST	2
#define MULTI_ATTR_LISTS	3

#define NO_REQUIRED_DATA	0
#define COLUMN_REQUIRED_DATA	1
#define POSITION_REQUIRED_DATA	2

#define BUTTON_FORM_ALREADY_DISPLAYED	0
#define BUTTON_FORM_CANCEL		1
#define BUTTON_FORM_DELETE		2
#define BUTTON_FORM_INSERT		3
#define BUTTON_FORM_CHANGE		4

#define	LOGICAL		1
#define RELATIONAL	2
#define PARENTHESES	3

#define UNUSED		65
#define EQUAL		66
#define NOT_EQUAL	67
#define MATCH		68
#define GREATER		69
#define GREATER_EQUAL	70
#define LESS_EQUAL	71
#define LESS		72
#define AND		73
#define OR		74
#define NOT		75
#define O_PARENTHESES	76
#define C_PARENTHESES	77

#define SUCCESS				0
#define MISSING_BEGINNING_NODE		1

#define NOT_RELATIONAL_NODE		2
#define NO_LEFT_HAND_EXPRESSION		3
#define NO_RIGHT_HAND_EXPRESSION	4

#define INVALID_PARENTHESES		5
#define NOT_LOGICAL_OPERATOR		6
#define INVALID_VALUE			7

#define PDU_CHAR		1
#define PDU_STRING		2
#define PDU_INTEGER		3
#define PDU_FLOAT		4
#define PDU_DATE		5
#define PDU_SMALLINT		6

#define FREEZE		1
#define UNFREEZE	2

#define DEFINE_REVIEW		1
#define DEFINE_BOM		2
#define DEFINE_CAT		3

#define TWO_COL_REG		0
#define TWO_COL_SORT		1

#define SIX_COL_REG		0
#define SIX_COL_NONGRA		1

#define DEFINE_FORM_NO_ACTION	0
#define DEFINE_FORM_INSERT	1
#define DEFINE_FORM_REPLACE	2
#define DEFINE_FORM_DELETE	3
#define DEFINE_FORM_EDIT	4
#define DEFINE_FORM_VARIABLE	5
#define DEFINE_FORM_LITERAL	6

#define DELETE_PT1		0
#define DELETE_PT2		1
#define DELETE_ACCEPT_REJECT	2

#define EDIT_PT1		0
#define EDIT_CHANGE_VALUES	1

#define REVIEW 			0
#define ACTIVE			1
#define FORMAT			2

#define PRINT_FREE_FORMAT	0
#define PRINT_REVIEW		1
