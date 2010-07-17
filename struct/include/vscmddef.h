/*
	I/STRUCT
	Command action return codes.
*/
#ifndef vscmddef_include
#	define vscmddef_include

/*
 * Return codes of actions.
 */
#define	VS_K_ACT_SUCCESS	0x01
#define VS_K_RESTART_CMD	0x02
#define VS_K_ABORT_CMD		0x04
#define	VS_K_TOO_MANY_OPS	0x06
#define	VS_K_NEED_OP		0x08
#define VS_K_NO_FENCE		0x10
#define VS_K_NO_WINDOW		0x20
#define VS_K_OBJONCHEXIST	0x40
#define VS_K_FORM_EXIST		0x80
#define VS_K_NO_OBJ		0x100
/*
 * Codes for operators and operands.
 */
#define	VS_K_OPRND	1
#define	VS_K_OPRTR	2

/*
 * Form-operation codes of messages formOpByPtr and formOpByIndex of class
 * VSlocateCmd.
 */
#define VS_FIf_DISPLAY		0
#define VS_FIf_ERASE		1
#define VS_FIf_RESET		2
#define VS_FIf_DELETE		3
#define VS_FIf_WNEVENT_ON	4
#define VS_FIf_WNEVENT_OFF	5
#define VS_FIf_BTEVENT_ON	6
#define VS_FIf_BTEVENT_OFF	7
#define VS_FIf_INITNTFY_ON	8
#define VS_FIf_INITNTFY_OFF	9

/*
 * Flags for VSpartopCmd.
 */
#define VS_m_POconstWithSymb	0x1	/* Use active symbology		*/
#define VS_m_POconstWithRep	0x2	/* Use active display rep.	*/
#define VS_m_POnoOperandRedisp	0x4	/* Do not redisplay operand	*/
#define VS_m_POnoOperatorErase	0x8	/* Do not erase operators	*/
#define VS_m_POallOprtsOn1Opnd	0x10	/* All operators on one operand	*/

/*
 * The get-expression filter number.
 */
#define VSget_exp 			200
/*
 * The get-event with dynamic interception of the cursor movement filter number.
 */
#define VSget_event_with_dynamics	201
#define VSlocateGadget			202

/*
 * Define for COB's subtype used with command GR_UNKNOWN_TYPE.
 */
     
#define VS_K_LOAD_ATTR		255
#define VS_K_CH_STATE		254
#define VS_K_DYN_MOUSE		256
#define VS_K_END_STATE		257
#define VS_K_SAME_STATE		258
#define VS_K_DROP_ELEM  	259
#define VS_K_FILE_ACCEPTED	260
#define VS_K_FILE_CANCELED	261
#define VS_K_FILE_STARTED	262
#define VS_K_GADGET_LOCATED	263
#define VS_K_FORM_MOVEON	264
#define VS_K_GOTO_PLATE         265

/*
 * Maximum number of forms with dynamic cursor movement notification.
 */
#define VS_K_MAX_DYN_FORMS	5

/*
 * Codes of locate action handlers.
 */
#define VS_K_RESET_LCAH				0x000
#define VS_K_isSupportOfBeam_LCAH		0x001
#define VS_K_isSupportOfStiffener_LCAH		0x002
#define VS_K_notSupportOfPlate_LCAH		0x008
#define VS_K_actionHandlerInCmd_LCAH		0x010
#define VS_K_filterFeature_LCAH			0x020
#define VS_K_filterFeatureNeg_LCAH		0x040
#define VS_K_rejectSubClass_LCAH		0x080
#define VS_K_isAnEditableFeature_LCAH		0x100
#define VS_K_isAnExtOrOrgStiffener_LCAH 	0x200
#define VS_K_isAClosedPlanarCurve_LCAH		0x400
#define VS_K_noFrozenFeature_LCAH		0x800

#endif
