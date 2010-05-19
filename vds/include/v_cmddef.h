/* $Id: v_cmddef.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/v_cmddef.h
 *
 * Description:
 *		Include file to support the command action return codes.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_cmddef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/11/01  15:23:02  pinnacle
 * Replaced: include/v_cmddef.h for:  by v250_int for vds
 *
 * Revision 1.1  1997/10/23  21:28:00  pinnacle
 * Created: include/v_cmddef.h by jwfrosch for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/23/97	adz		creation date
 *
 ***************************************************************************/
#ifndef v_cmddef_include
#	define v_cmddef_include

/*
 * Return codes of actions.
 */
#define	VD_K_ACT_SUCCESS	0x01
#define VD_K_RESTART_CMD	0x02
#define VD_K_ABORT_CMD		0x04
#define	VD_K_TOO_MANY_OPS	0x06
#define	VD_K_NEED_OP		0x08
#define VD_K_NO_FENCE		0x10
#define VD_K_NO_WINDOW		0x20
#define VD_K_OBJONCHEXIST	0x40
#define VD_K_FORM_EXIST		0x80
#define VD_K_NO_OBJ		0x100
/*
 * Codes for operators and operands.
 */
#define	VD_K_OPRND	1
#define	VD_K_OPRTR	2

/*
 * Form-operation codes of messages formOpByPtr and formOpByIndex of class
 * VDS_LOCATE (copied from STRUCT).
 */
#define VD_FIf_DISPLAY		0
#define VD_FIf_ERASE		1
#define VD_FIf_RESET		2
#define VD_FIf_DELETE		3
#define VD_FIf_WNEVENT_ON	4
#define VD_FIf_WNEVENT_OFF	5
#define VD_FIf_BTEVENT_ON	6
#define VD_FIf_BTEVENT_OFF	7
#define VD_FIf_INITNTFY_ON	8
#define VD_FIf_INITNTFY_OFF	9

/*
 * Flags for VDS_LOCATE / VDSCmdReport.
 */
#define VD_m_POconstWithSymb	0x1	/* Use active symbology		*/
#define VD_m_POconstWithRep	0x2	/* Use active display rep.	*/
#define VD_m_POnoOperandRedisp	0x4	/* Do not redisplay operand	*/
#define VD_m_POnoOperatorErase	0x8	/* Do not erase operators	*/
#define VD_m_POallOprtsOn1Opnd	0x10	/* All operators on one operand	*/

/*
 * The get-expression filter number.
 */
#define VDget_exp 			200
/*
 * The get-event with dynamic interception of the cursor movement filter number.
 */
#define VDget_event_with_dynamics	201
#define VDlocateGadget			202

/*
 * Define for COB's subtype used with command GR_UNKNOWN_TYPE.
 */
     
#define VD_K_LOAD_ATTR		255
#define VD_K_CH_STATE		254
#define VD_K_DYN_MOUSE		256
#define VD_K_END_STATE		257
#define VD_K_SAME_STATE		258
#define VD_K_DROP_ELEM  	259
#define VD_K_FILE_ACCEPTED	260
#define VD_K_FILE_CANCELED	261
#define VD_K_FILE_STARTED	262
#define VD_K_GADGET_LOCATED	263
#define VD_K_FORM_MOVEON	264
#define VD_K_GOTO_PLATE         265

/*
 * Maximum number of forms with dynamic cursor movement notification.
 */
#define VD_K_MAX_DYN_FORMS	5

/*
 * Codes of locate action handlers.
 */
#define VD_K_RESET_LCAH				0x000
#define VD_K_isSupportOfBeam_LCAH		0x001
#define VD_K_isSupportOfStiffener_LCAH		0x002
#define VD_K_notSupportOfPlate_LCAH		0x008
#define VD_K_actionHandlerInCmd_LCAH		0x010
#define VD_K_filterFeature_LCAH			0x020
#define VD_K_filterFeatureNeg_LCAH		0x040
#define VD_K_rejectSubClass_LCAH		0x080
#define VD_K_isAnEditableFeature_LCAH		0x100
#define VD_K_isAnExtOrOrgStiffener_LCAH 	0x200
#define VD_K_isAClosedPlanarCurve_LCAH		0x400
#define VD_K_noFrozenFeature_LCAH		0x800

#endif
