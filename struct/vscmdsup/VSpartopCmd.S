/*
	I/STRUCT
*/
class specification VSpartopCmd(1:0) of VSlocateCmd ;

/*+c
	This class defines utilities for command which performs operations
	on objects (the operands) with other objects (the operators) to
	give out results.
	For example notching a beam (operand( with one or several solids
	(operator) give out a notched beam (result).
	There may be several operands, in which case the operation is
	performed on each operand with all the operators, giving out as
	one result per operand.
-c*/

#ifndef vscmddef_include
#	include "vscmddef.h"
#endif

instance VSpartopCmd {
	/*
	 * Count of operands and operators.
	 */
	int		oprndCount,
			oprtrCount ;

	/*
	 * Minimum and maximum count of operators allowed.
	 */
	int		minOprtr,
			maxOprtr ;
	/*
	 * Command flags.
	 */
	unsigned	partOpFlags ;

	/*
	 * Pointer to class attributes.
	 */
	char		*classAttr ;
} ;

/*+d
Message setFlags

Abstract
	Sets operation flags in "me->partOpFlags".
Argument
	IN	int	flag	ORing of the following masks:

			VS_m_POconstWithSymb    Use active symbology
			VS_m_POconstWithRep     Use active display rep.
			VS_m_POnoOperandRedisp  Do not redisplay operand
			VS_m_POnoOperatorErase  Do not erase operators
			VS_m_POallOprtsOn1Opnd	All operators on one operand
-d*/
message setFlags( int flags ) ;

/*+d
Message setMinMaxOperators

Abstract
	To be called form a COB state table: sets the minimum and maximum
	numbers of operator that command will accept.
Arguments
	IN	int	min	Minimum number of operators.
	IN	int	max	Maximum number of operators.
-d*/
message setMinMaxOperators( int min, max ) ;

/*+d
Message store_operand

Abstract
	To be called form a COB state table after a "filter locate" on an
	EX_DATA response type: stores the located object as an operand.
Arguments
	OUT	long	*msg	Completion code.
	IN	int	putQ	TRUE/FALSE, it TRUE put accept point onto the
				software event queue (to allow chain locate).
-d*/
message store_operand( long *msg ; int putQ ) ;

/*+d
Message store_operator

Abstract
	To be called form a COB state table after a "filter locate" on
	an EX_DATA response type: stores the located object as an operator.
Arguments
	OUT	long	*msg	Completion code.
	IN	int	putQ	TRUE/FALSE, it TRUE put accept point onto the
				software event queue (to allow chain locate).
-d*/
message store_operator( long *msg ; int putQ  ) ;

/*+d
Message process_fence

Abstract
	To be called form a COB state table after a "filter locate" on
	an EX_OBJID response type: the object returned by locate may be a set
	(from a group generator). Processes the elements in the fence and
	stores them either as operands or as operators.
Arguments
	OUT	long	*msg	Completion code.
	IN	int	type	Type of the objects to be stored:
				- VS_K_OPRND	: as operands
				- VS_K_OPRTR	: as operators
-d*/
message process_fence( long *msg ; int type ) ;

/*+d
Message discard_operators

Abstract
	Resets the list of operators to "empty".
Argument
	OUT	long	*msg	Completion code.
-d*/
message discard_operators( long *msg ) ;

/*+d
Message discard_all_input

Abstract
	Resets the lists of operands and operators to "empty". For example
	when command is restarted.
Argument
	OUT	long	*msg	Completion code.
-d*/
message discard_all_input( long *msg ) ;

/*+d
Message operation

Abstract
	Implemented as this level to construct an object of class
				"me->const_class"
	(which must be sub-class of VScpx) with all the operand and the
	operators as parents (this message assumes only one operand).
	It will construct the object with the active symbologu if the
	flag "VS_m_POconstWithSymb" has been set (generally the result
	has the same symbology as the operand it comes from), and the
	active display representation if the flag "VS_m_POconstWithRep"
	has been set (same story).
	It will redisplay the operands in case of error (operations
	often erase the operands) unless the flag "VS_m_POnoOperandRedisp"
	has been set.
Argument
	OUT	long	*msg	Completion code:
				- VS_K_ACT_SUCCESS	All OK.
				- VS_K_NEED_OP		Not enough operators.
				- VS_K_RESTART_CMD	Operation failed,
							but you may restart.
				- VS_K_ABORT_CMD	Severe error, better
							exit command.
Note
	For all other behaviors than that above described, this message must
	be ovveriden.
-d*/
message operation( long *msg ) ;

/*+d
Message construct

Abstract
	Given a construction list, constructs the object.
Arguments
	OUT	long			*msg	Completion code.
	IN	struct GRvg_construct	*cst	Construction list.
-d*/
message construct( long *msg ; struct GRvg_construct *cst ) ;

/*+d
Message handleError

Abstract
	Takes the appropriate action accoring to the value of "error":
	- VS_K_TOO_MANY_OPS	Too many operators input: discard them and
				force COB to return to the previous state.
	- VS_K_RESTART_CMD	Forces command to restart.
	- VS_K_ABORT_CMD	Forces command to terminate
	- VS_K_NO_FENCE		No object in fence. Stays in same state.
	In addition, an ad hoc message is output to the status field.
Argument
	IN	int	error	One of the above error code.
-d*/
message handleError( int error ) ;

/*+d
Message setErrorStatus

Abstract
	Interprets the error message and outputs a information message which
	describes it. `msg' may be an EXNUC, GRNUC, EMS, etc. completion code.
	such as "EMS_E_IntersectClosure".
Arguments
	IN	long	msg	One of the error codes above.
	IN	int	wait	Time in second to sleep (may be 0).
-d*/
message setErrorStatus(	long msg ; int wait ) ;

/*+d
Message displaySurfaceNormal

Abstract
	Displays the normal of the last-located object, supposing that it is
	a surface.
Argument
	IN	enum GRdpmode	mode	Display mode.
-d*/
message displaySurfaceNormal( enum GRdpmode mode ) ;

message decrease_operator() ;

end specification VSpartopCmd ;
