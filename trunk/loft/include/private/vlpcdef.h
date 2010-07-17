/*
		I/LOFT profile card define.
*/

#ifndef vlpcdef_include
#define	vlpcdef_include

// drawing border anchor point
#define	INST_POINT_VAR_NAME	"InstPoint"
#define INST_POINT_RADICAL	"i"

// strudel PC file name
#define VLPC_GR_FILE		"graphicPc"
#define VLPC_TXT_FILE		"textPc"

// PC predefined view
#define VLPC_VIEW_SIDE		"side"
#define VLPC_VIEW_BOTTOM	"bottom"
#define VLPC_VIEW_UNKNOWN	"unknown"

// PC marking support
#define VLPC_DEF_ATT_CMD	"~~cmd"
#define VLPC_REF_MARK_CMD	"refline"
#define VLPC_END_TREAT_CMD	"et"
#define VLPC_DEF_ATT_ORIENT	"~~orientation"

// PC state definition
#define	VLPC_START		"vl-pc-Start"
#define VLPC_END		"vl-pc-End"
#define VLPC_LAB		"vl-pc-Label"
#define	VLPC_START_STIFF	"vl-pc-StartStiffener"
#define VLPC_END_STIFF		"vl-pc-EndStiffener"
#define VLPC_REF_MARKING	"vl-pc-ReferenceMark"
#define VLPC_BEND_LINES		"vl-pc-BendLines"
#define VLPC_BORDER		"vl-pc-Border"
#define VLPC_INITIALIZE		"vl-pc-Initialize"

// PC key word definition
#define VLPC_MAC_DEF_ATTR	"vl-pc-McDefAttribute"
#define	VLPC_MAC_POS		"vl-pc-McPosition"
#define	VLPC_MAC_ANGLE		"vl-pc-McAngle"
#define	VLPC_MAC_SIDE		"vl-pc-McSide"
#define VLPC_ET1_POS		"vl-pc-FirstEtPosition"
#define VLPC_INTER_ETS_LEN	"vl-pc-InterEtsLength"

#define VLPC_ROTATE_CS		"vl-pc-RotateCs"

#define VLPC_SET_LABEL		"vl-pc-SetLabel"
#define VLPC_SET_LAB_ORIG	"vl-pc-SetLabelOrigin"
#define VLPC_GET_LAB_ORIG	"vl-pc-GetLabelOrigin"
#define VLPC_GET_LAB_TEXT	"vl-pc-GetLabelText"
#define VLPC_GET_LAB_REF	"vl-pc-GetLabelReference"

#define	VLPC_VIEW_CS		"vl-pc-ViewCs"
#define	VLPC_VIEW_END_CS	"vl-pc-ViewEndCs"
#define VLPC_VIEW_MAC_CS	"vl-pc-ViewMcCs"
#define	VLPC_BORDER_PT		"vl-pc-BorderAnchorPoint"
#define	VLPC_INST_PT		"vl-pc-BorderInstPoint"
#define VLPC_BORDER_MEMBER	"vl-pc-BorderMember"
#define VLPC_GET_STIFF		"vl-pc-GetStiff"
#define VLPC_GET_FOOT		"vl-pc-GetBorderFoot"
#define VLPC_PLACE_BEND		"vl-pc-PlaceBendLines"
#define VLPC_GET_VIEWNAME	"vl-pc-GetViewName"
#define VLPC_GET_MACROLIST	"vl-pc-GetMacroList"
#define VLPC_GET_MACROPOSITIONS	"vl-pc-GetMacroPositions"
#define VLPC_IS_CURVED_BEAM	"vl-pc-IsCurvedBeam"
#define VLPC_SET_BORDER		"vl-pc-SetBorder"
#define VLPC_SET_WEBRIGHT	"vl-pc-SetWebRight"
#define VLPC_PLACE_BENDTABLE	"vl-pc-PlaceBendTable"
#define VLPC_TERMINATE          "vl-pc-Terminate"
#define VLPC_SETEXTREMEDIM	"vl-pc-SetExtremeDim"
#define VLPC_SETMACBOTHET	"vl-pc-SetMacBothET"
#define VLPC_SETMACOPENET	"vl-pc-SetMacOpenET"
#define VLPC_GETPLTTHKDIR	"vl-pc-GetPlateThkDir"
#define VLPC_STF_MARK           "vl-pc-StiffenerMark"
#define VLPC_GETXBASE		"vl-pc-GetXBase"
#define VLPC_GETSTARTPOINT	"vl-pc-GetStartPoint"

// PC output definition
#define VLPC_PROJECTION		"vl-pc-ViewProjection"
#define VLPC_MEMBER		"vl-pc-ViewMember"

// PC Text predefined attributes
#define VLPC_LAB_ORIG		"labelOrigin"
#define VLPC_LAB_REF		"labelReference"
#define VLPC_LAB_TEXT		"labelText"
#define VLPC_LAB_LEN		"labelLen"

// PC Graphic predefined attributes
#define VLPC_STIFF_LEN		"stiffLength"
#define VLPC_STIFF_WID		"stiffWidth"
#define	VLPC_MC_ET1_POS		"et1Pos"
#define VLPC_MC_ETS_LEN		"etsLen"

// PC Text index of context list
#define VLPC_IDX_BORDER		0
#define VLPC_IDX_SUPPORT	1
#define VLPC_IDX_COL		2
#define VLPC_IDX_ACHEADER	3

// PC macro info mask
#define	VLPC_MAC_XY		0x0001
#define	VLPC_MAC_ALPHA		0x0002
#define	VLPC_MAC_RANGE		0x0004

// PC text macro definition
#define	VLPC_ATTRIBUTES_BOX	"att_box"



/* ************************************************************************** */
#endif

