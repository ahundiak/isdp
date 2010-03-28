#ifndef dimco_include

#define dimco_include

/* States for placement command object */

#define STATE_P_LOC_ORIG		0
#define STATE_P_LOC_MEAS		1
#define STATE_P_SEL_AXIS		2
#define STATE_P_POS_TEXT		3
#define STATE_P_HOR_TEXT		4
#define STATE_P_LOC_MEAS2		5
#define STATE_P_POS_TEXT2		6
#define STATE_P_HOR_TEXT2		7
#define STATE_P_LOC_ORTH_ORIG		8
#define STATE_P_SEL_QUAD		9
#define STATE_P_LOC_ANGL_CENT		10
#define STATE_P_LOC_DIM			11
#define STATE_P_LOC_JOG_PT		12
#define STATE_P_LOC_JOG_PT1		13
#define STATE_P_LOC_JOG_PT2		14

/* States for copy command */

#define STATE_C_LOC_DIM			0
#define STATE_C_LOC_ORIG		1
#define STATE_C_LOC_MEAS		2

/* States for Annotation placement command object */

#define STATE_P_LOC_ARROW_ELT		12
#define STATE_P_LOC_LEAD_ELT		13
#define STATE_P_POS_ARROW		14
#define STATE_P_GET_EVNT		15

/* States for change terminator type command */

#define STATE_CT_LOC_TERM		0
#define STATE_CT_CHG_TERM		1

/* Gadget labels - copy dim command */

#define GAD_TOGGLE_TRAK		12
#define GAD_TOGGLE_TERM		13

#define MAIN_FORM	0
#define SUB_FORM	1
#define SUB_FORM1	1
#define SUB_FORM2	2
#define SUB_FORM3	3
#define SUB_FORM4	4

struct DMobj_info
{
	struct GRid grid, context;
	IGRpoint lnproj;
	struct GRparms par;
};

#endif

