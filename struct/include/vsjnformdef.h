/* $Id: vsjnformdef.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	source_directory_filename
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsjnformdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.4  1998/03/13  23:21:12  pinnacle
 * New Joints
 *
 * Revision 1.2  1998/01/06  09:20:28  pinnacle
 * Replaced: include/vsjnformdef.h for:  by svkadamb for struct
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/06/98  suresh  modification. Added new gadgets for 
 * 		     the modified user interface of joint
 *		     command 
 * 03/12/98  suresh  TR179800680 Add Modify New Joint
 ***************************************************************************/
/*
	I/STRUCT
	Gadget labels of "Set Active Joint Attributes" form.
	This form also used by command "Modify Joint"
*/
#ifndef vsjnformdef_include
#	define vsjnformdef_include

/*
 * Added for new "Set Active Joint Attributes" command
 */
#	define VS_K_jn_AttrForm_Name		"VSactnjnatt.fm"
/*
 * Name of form.
 */
#	define VS_K_jn_Form_Name		"VSactJnAttr.fm"
#	define VS_K_jn_UsrAttrFormName		"VSaddUsrAtt.fm"

/*
 * Form gadgets of VS_K_jn_Form_Name
 */
#	define VS_K_jn_Title		11
#	define VS_K_jn_Weld_Code	12
#	define VS_K_jn_Allowance	13
#	define VS_K_jn_Process		16
#	define VS_K_jn_FieldWeld	18
#	define VS_K_jn_MeltThru		19
#	define VS_K_jn_AllAround	20
#	define VS_K_jn_Flush		23
#	define VS_K_jn_Concave		48	//from 24
#	define VS_K_jn_Convex		25
#	define VS_K_jn_ArrowSide	27
#	define VS_K_jn_OtherSide	28
#	define VS_K_jn_BothSides	38
#	define VS_K_jn_GrooveAngle	32
#	define VS_K_jn_Pitch		30
#	define VS_K_jn_IncrLength	34
#	define VS_K_jn_UsrSymbol	37
#	define VS_K_jn_ArrowSideSym	39
#	define VS_K_jn_OtherSideSym	40
#	define VS_K_jn_BothSidesSym	41
#	define VS_K_jn_UsrAttrsBtn	42

/*
 * Form gadgets of VS_K_jn_UsrAttrFormName
 */
#	define VS_K_jn_UsrAttrMcf	12

/*
 * Indices of columns of MCF of label VS_K_jn_UsrAttrMcf
 */
#	define VS_K_jn_UAmcfNamCol	0
#	define VS_K_jn_UAmcfValCol	1

/*
 * Joint attributes form during placement 
 */
#	define VS_K_Jnt_Attribute_File         "VSPlJnAttr.fm"
 
/*
 * symbol for weld side 
 */
#define VS_K_jn_wldSideSym        16

/*
 * Listof gadgets showing the weld positions
 */
#	define VS_K_jn_FloorPos        26
#	define VS_K_jn_HorzPos         43
#	define VS_K_jn_CeilPos         24
#	define VS_K_jn_VertPos         44


/*
 * list of gadgets showing the weld sides
 */
#	define VS_K_jn_LeftSide        27
#	define VS_K_jn_RightSide       28


/*
 * shrinkage ratio
 */
#	define VS_K_jn_ShrkRatio       32

/*
 * used for modify joint and set active joint attributes commands
 */
#	define VS_K_jn_Shrinkage       45	

 
#define VS_K_jn_Dismiss_Execute 1
#define VS_K_jn_Execute         2
#define VS_K_jn_Revert          3
#define VS_K_jn_Dismiss         4

/*
 * wled size field
 */
#	define VS_K_jn_Weld_Size       13

#endif
