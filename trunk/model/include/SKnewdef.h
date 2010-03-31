/* header file for new skinning interface */

/*---global defines---*/
/* FORMS */
#define CASE_FORM		100
#define GLOBAL_OPTIONS_FORM	101
#define SHAPE_OPTIONS_FORM	102
#define ORIENT_OPTIONS_FORM	103

/* for switching dependend on me->mytype */
#define SURFACE 0
#define SOLID 1

/*--defines for EFManSkCsFrm.I----*/
#define SkCs_EXECUTE_FORM	0
#define SkCs_DELETE_FORM	1

#define EVENT_MASK (GRm_RJT_MOVEON | GRm_OBJID | GRm_DATA | GRm_MOVE_ON |\
                    GRm_VALUE | GRm_STRING | GRm_CHAR | GRm_FORM_FINISHED |\
                    GRm_RESTART | GRm_BACK_UP)

/*---defines for OPTIONS FORMS---*/
/* on GLOBAL_OPTIONS_FORM and SHAPE_OPTIONS_FORM */
#define GROUP1        21
#define GROUP2        24
#define SkOp_COMPOSITE_TGL       20
#define SkOp_COMPOSITE_TXT       19
#define SkOp_SMOOTH_TGL          23
#define SkOp_SMOOTH_TXT          22
#define SkOp_TANGENCY_TGL        17
#define SkOp_TANGENCY_TXT        18
#define SkOp_SHAPE_BTN           25

/* only on SHAPE_OPTIONS_FORM */
#define SkOp_HTSCALING_TGL       13
#define SkOp_HTSCALING_TXT       12
#define SkOp_ORIENT_BTN          28
#define SkOp_ORIENT_BTN_REL      16
#define SkOp_ORIENT_BTN_ABS      26
#define SkOp_ORIENT_TXT          27
#define SkOp_LAWCRV_FLD          15
#define SkOp_LAWCRV_TXT          14

/* on ORIENT_OPTIONS_FORM */
#define SkOp_ORIENT_GRP          14
#define SkOp_AUTO_ORIENT_BTN     28
#define SkOp_REL_ORIENT_BTN      29
#define SkOp_ABS_ORIENT_BTN      30

/*------- routine headers ----------------------------------------------*/

/* EFManSkCsFrm.I */
extern void SkCs_manag (IGRboolean SkCs_form_not_exists,int *myevent_resp,
                       int *response, char *response_data,int *skin_case);
extern void SkCs_delete_form (void);
extern void SkCs_notif( int f_label, int g_label, double value, Form fp);
extern int SkCs_display_form (IGRboolean create);

/* ECplcskini.I */
extern void SkOp_set_skinn_option (IGRboolean surface_is_open, int SkOp_options_case,
Form fp);
