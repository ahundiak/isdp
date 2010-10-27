/*
 * Form Defines For Support Curves
 */

#define VDSUP_FRM_MAIN  250

#define VDSUP_CMD_CRV_PL 0
#define VDSUP_CMD_OFF_PL 1
#define VDSUP_CMD_EQU_PL 2
#define VDSUP_CMD_CRV_MD 3
#define VDSUP_CMD_OFF_MD 4
#define VDSUP_CMD_EQU_MD 5

#define VDSUP_YES 10
#define VDSUP_NO  20


#define VDSUP_FRM_B_ACCEPT  1
#define VDSUP_FRM_B_EXECUTE 2
#define VDSUP_FRM_B_CANCEL  4
#define VDSUP_FRM_F_INFO    9
#define VDSUP_FRM_F_STATUS 10

#define VDSUP_FRM_B_CLEAR  15

#define VDSUP_FRM_L_OBJECTS  12
#define VDSUP_FRM_F_NAME     19
#define VDSUP_FRM_T_TITLE    33

#define VDSUP_FRM_G_MET 40
#define VDSUP_FRM_G_LAW 41
#define VDSUP_FRM_G_INT 42


typedef struct {
  IGRlong item; /* Row number */ 
  IGRlong idx;  /* Index */
  IGRlong exp;  /* Expression */
  IGRlong typ;  /* Object identifier */
  IGRlong col;  /* Purpose, Offset or Purpose and Offset column for input */
} VDCsupROW;


IGRstat VDCsupGetROW(VDCsupROW *rowList, int item, VDCsupROW *row);
IGRstat	VDsupGetNextOccName(IGRchar *full_name, IGRchar *name);

/* Object Type Code - invisible 4th form column */

#define VDSUP_OBJ_BASE_SURF  0
#define VDSUP_OBJ_BASE_OBJ1  1
#define VDSUP_OBJ_BASE_OBJ2  2
#define VDSUP_OBJ_DIR        3
#define VDSUP_OBJ_SEL        4
#define VDSUP_OBJ_TRACE1     5
#define VDSUP_OBJ_TRACE2     6
#define VDSUP_OBJ_CUT1       7
#define VDSUP_OBJ_CUT2       8
#define VDSUP_OBJ_DIS1       9 
#define VDSUP_OBJ_DIS2      10
#define VDSUP_OBJ_CNT       11
#define VDSUP_OBJ_TRACE     12

/* Column Identifier: 0=Item, 1=Name, 2=Expression */

#define VDSUP_ITEM_COL   0
#define VDSUP_NAME_COL   1
#define VDSUP_EXPR_COL   2

/* Macro for listing up to 50 trace objects in column one of form */

#define  LISTTRACES(row)\
for( i=3; i<=50; i++ )\
{\
  strcpy(trace_string, "Trace Object ");\
  sprintf( buff, "%d", i );\
  strcat( trace_string, buff );\
  FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, row, 0, trace_string, 0 );\
  row++;\
}
