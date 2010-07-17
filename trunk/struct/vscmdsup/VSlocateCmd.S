/*
	I/STRUCT
*/
class specification VSlocateCmd(0:1) of CEO_LOCATE ;

#ifndef didef
#	include "DIdef.h"
#endif
#ifndef DItypedef_include
#	include "DItypedef.h"
#endif
#ifndef diglob
#	include "DIglob.h"
#endif
#ifndef DIprims
#	include "DIprims.h"
#endif
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "growner.h"
#include "vsgraphicenv.h"
#include "vscmddef.h"
#include "vscmd.h"

instance VSlocateCmd {

	/*
	 * Symbolic key assigned to command (nothing to do with the command
	 * key of the Message Sub-System, several commands may have the same
	 * key), to be used as input to VDS's translation table.
	 */
	GRname				matchKey ;
	/*
	 * Array holding the located objects, this is preferred to the locate
	 * channel since we may have to gather non-graphic objects which cannot
	 * be held by the locate channel.
	 */
	variable struct GRobj_env	locObjs[0] ;

	/*
	 * If TRUE does not perform highlight and unhighlight of located objects
	 * as command wakes up or goes to sleep.
	 */
	int				suppressHilite,

	/*
	 * State masks.
	 */
#define VS_m_CmdStacked		0x1	/* If command has been stacked    */
					execFlags ;
	/*
	 * Argument to locate action handler.
	 */
	VSlocateArgs			LCAHarg ;

	/*
	 * Pointer to process-fence action handler function.
	 */
	int				(*PFAH) __(( struct GRobj_env *o,
							VSfenceArgs *a )) ;

	/*
	 * Argument to process-fence action handler.
	 */
	VSfenceArgs			PFAHarg ;

	/*
	 * Message key to error message displayed by abortCmd method.
	 */
	long				stskey ;
	struct GRmd_env			cstEnv ;

	/*
	 * Form pointers and their corresponding windows where dynamic-tracking
	 * of mouse cursor has been turned on.
	 */
	VSgrEnvWindow			 dynWno[VS_K_MAX_DYN_FORMS] ;
	char				*dynFrm[VS_K_MAX_DYN_FORMS] ;

	/*
	 * The current working directory.
	 */
	char				Cwd[DI_PATH_MAX] ;

	/*
	 * The Active Display Representation.
	 */
	struct VDSsymb			ActiveRep ;
	struct GRid			constructedObject,
					expression ;
	/*
	 * Used to save the notification routine of a form when we temporarily
	 * override it.
	 */
	int				(*previousNotification)() ;

	/*
	 * Locate-gadget-on-form.
	 * - Label of located gadget.
	 * - Label of gadget defining an area on form to which located will be
	 *   limited (if -1, area of all form).
	 * - Pointer to form where locate takes place.
	 */
	int				locatedGadget,
					locGadgetArea ;
	char				*locatedForm ;

} ; 

override	init,
		wakeup,
		sleep,
		delete,
		filter ;

/*+d
Message addLocObj

Abstract
	Puts a graphic object in the locate list and stores its environment.
Arguments
	IN	struct GRid	objToAdd	Id of object to add.
	IN	struct GRmd_env	envToAdd	Mod. env. of object to add.
	IN	int		index		Index in list where object
						must be added.
Note
	If `envToAdd' is NULL, the identity matrix will be used.
-d*/
message addLocObj(	struct GRid	*objToAdd ;
			struct GRmd_env	*envToAdd ;
			int		index ; ) ;

/*+d
Message getLocObjs

Abstract
	Gets a list of located objects from the first one (at index 0) up.
Arguments
	OUT	long			*msg	Completion code.
	IN	int			size	Size of output array.
	OUT	struct GRobj_env	*list	Array where objects will be put.
-d*/
message getLocObjs( long *msg ; int size ; struct GRobj_env *list ) ;

/*+d
Message getLocObjAtIndex

Abstract
	Gets one located object.
Arguments
	OUT	long			*msg	Completion code.
	IN	int			index	Index of wanted object.
	OUT	struct GRobj_env	*locObj Object at desired index.	
-d*/
message getLocObjAtIndex( long *msg ; int index ; struct GRobj_env *locObj ) ;

/*+d
Message rmLastLocObjs

Abstract
	Removes the last-located objects (those at the end of the list)
	from the locate list.
Arguments
	IN	int	from_index	Starting index from which objects will
					be removed from the locate list.
Note
	To remove all objects set `from_index' to `0'.
-d*/
message rmLastLocObjs( int from_index ) ;

/*+d
Message dpLocObjs

Abstract
	Displays the located objects.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		from_index	Starting index from which
						objects will be displayed.
	IN	enum GRdpmode	dpmode		Display mode
Note
	To display all objects set `from_index' to `0'.
-d*/
message dpLocObjs( long *msg ; int from_index ; enum GRdpmode dpmode ) ;

/*+d
Message abortCmd

Abstract
	Forces command to jump back to state "terminate".
Arguments
	OUT	long	*msg		Completion code.
-d*/
message abortCmd( long *msg ) ;

/*+d
Message formCreationByPtr

Abstract
	Creates a new form given its label and file name.
Arguments
	IN	int	label	Form label.
	IN	char	*file	File name of form.
	OUT	char	**form	Form pointer.
-d*/
message formCreationByPtr( int label ; char *file, **form ) ;

/*+d
Message formOpByPtr

Abstract
	Performs an operation on a form given its form pointer
Arguments
	IN	char	*form	Pointer to form.
	IN	int	opCode	Code of operation (#defined in "vscmddef.h" ).
-d*/
message formOpByPtr( char *form ; int opCode ) ;

/*+d
Message formOpByIndex

Abstract
	Performs an operation on a form given its index in "me->forms".
Arguments
	IN	int	index	Index of form.
	IN	int	opCode	Code of operation (#defined in "vscmddef.h" ).
-d*/
message formOpByIndex( int index ; int opCode ) ;

/*+d
Message initial_notification

Abstract
	Id the initial-gadget-notification trapping device has been set for
	some form with messages formOpByPtr/Index, this message will be sent
	to self each time a gadget is touched.
Arguments
	They are those of an initial-gadget-notification routine as described
	in the I/FORMS Programmer's Manual.
-d*/
message initial_notification(	int	form_label,
					gadget ;
				double	value ;
				char	*form ) ;

/*+d
Message window_notification

Abstract
	If the window-event trapping device has been set for some form with
	messages formOpByPtr/Index, this message will be sent to self each
	time a gadget is touched.
Arguments
	They are those of a window-event routine as described in the I/FORMS
	Programmer's Manual.
-d*/
message window_notification(	int	form_label,
					event ;
				char	*form ) ;

/*+d
Message button_notification

Abstract
	Id the button-event trapping device has been set for some form with
	messages formOpByPtr/Index, this message will be sent to self each
	time a gadget is touched.
Arguments
	They are those of a button-event routine as described in the I/FORMS
	Programmer's Manual.
-d*/
message button_notification(	int	form_label,
					xpos,
					ypos,
					button_number,
					transition,
					time_tag ;
				char	*form ;
				int	*rc ) ;

/*+d
Message set_dynamics_in_form

Abstract
	Turns on the dynamic tracking of mouse cursor. As cursor flies over the
	form, the message "mouse" is sent to the command object each time the
	position changes.
	Instead of filter "get_event", filter "VSget_event_with_dynamics"
	(#defined in vscmddef.h") must be used for the tracking to be performed.
Arguments
	OUT	long		*msg	Completion code.
	IN	char		*form	Pointer to form were tracking must be
					enabled.
-d*/
message set_dynamics_in_form( long *msg ; char *form ) ;

/*+d
Message stop_dynamics_in_form

Abstract
	Turn off dynamic tracking of mouse cursor.
Arguments
	OUT	long		*msg	Completion code.
	IN	char		*form	Pointer to form were tracking must be
					disabled.
-d*/
message stop_dynamics_in_form( long *msg ; char *form ) ;

/*+d
Message get_event_with_dynamics

Abstract
	Supporting get-event message for dynamic tracking of mouse cursor in
	forms, invoked in COB's "filter" message.
Arguments
	Same as message filter of class CEO.
-d*/
message get_event_with_dynamics( int	*response ;
				char	*response_data ) ;

/*+d
Message mouse

Abstract
	Message sent to command when dynamic tracking if cursor is on and
	the mouse cursor has changed position over a form.
Arguments
	OUT	long		*msg	Completion code.
	IN	char		*form	Pointer to form over which cursor is.
	IN	int		x	x of cursor on form.
	IN	int		y	y of cursor on form.
Note
	If `*msg' is even, tracking is stopped. This message is implemented as
	a no-op at this level.
-d*/
message mouse( long *msg ; char *form ; int x, y ) ;

/*+d
Message waitTimer

Abstract
	Pauses for several seconds; useful when exiting command and writing
	to the status field, to prevent any command upon which this command was
	stacked to erase the status field immediately upon its wakeup and not
	give the user the chance to see it.
Argument
	IN	int	time	Time to pause in seconds.
-d*/
message waitTimer( int time ) ;

/*+d
Message checkPWD

Abstract
	To be called from a COB state table: checks that the current working
	directory is OK for naming objects: it is in the active design file,
	is not protected and is not a closed collection; otherwise, a warning
	is output to the status field.
Arguments
	None.
-d*/
message checkPWD() ;

/*+d
Message setupActionHandler

Abstract
	To be called from a COB state table: sets the locate action handler
	(me->actiuon_handler) and the process-fence action handler -if
	applicable- (me->PFAH).
Arguments
	OUT	long		*msg		Completion code.
	IN	int		LCAHcode	Of action handler
						(#defined in vscmddef.h).
	IN	int		arg		Argument of action handler.

-d*/
message setupActionHandler( long *msg ; int LCAHcode ; long arg ) ;

/*+d
Message setupAHrejectSts

Abstract
	To be called from a COB state table: sets the key of the message which
	will be printed to the status field when a located object is refused
	by the locate action handler. This message must be sent after the
	message "setupActionHandler".
	By default, no message is output when an object is rejected.
Argument
	IN	long	msgKey	Message key (number) of message in Message
				Sub-System.
-d*/
message setupAHrejectSts( long msgKey ) ;

/*+d
Message locate_action_handler

Abstract
	If the LCAHcode passes in "setupActionHandler" is
	"VS_K_actionHandlerInCmd_LCAH", this message will be sent to the
	command object to implement its action handler, either by the
	regular locate filter or by the macro `vs$process_fence' if its
	field `filter' has been set to `me->PFAH'.
Arguments
	OUT	int			*keepIt	TRUE : object accepted
						FALSE: object rejected.
	IN	enum GRlocate_action	*action	Same as for any locate handler.
	IN	struct GRlc_info	*entry 	Same as for any locate handler.
	IN	struct LC_action_args	*args	Same as for any locate handler.
Note
	When this message is sent from `vs$process_fence' the arguments
	`action' and `args' are set to NULL since they are not available.
-d*/
message locate_action_handler( int			*keepIt ;
			       enum GRlocate_action	*action ;
			       struct GRlc_info		*entry ;
			       struct LC_action_args	*args ) ;

/*+d
Message keyin_key

Abstract
	To be called from a COB state table: outputs a message to the key-in
	field.
Argument
	IN	long	msgnumb	Message number in the Message Sub-System of
				the message to output.
-d*/
message keyin_key( long msgnumb ) ;

/*+d
Message locateGadget

Abstract
	Supporting locate message for locating gadgets on a form, invoked in
	COB's "filter" message. Corresponds to the "VSlocateGadget" filter
	type to be invoked form a COB state stable as :

		filter VSlocateGadget
Arguments
	Same as message filter of class CEO.
-d*/
message locateGadget(	int	*response ;
			char	*response_data ) ;

/*+d
Message processLocate

Abstract
	Message supporting the Accept/Reject cycle of a gadget-locate.
Arguments
	IN	char	*form	Form where locate is going on.
	IN	int	gadget	Label of gadget on form which defined the
				locate area.
Note
	How to get gadget-locate working:

	1.- In the COB state table, invoke filter "VSlocateGadget" :
		filter VSlocateGadget

	2.- In the form_notification action, when the gadget defining the
	    locate area (eg. a rectangle) has been hit, send a "processLocate"
	    message to self:

		action form_notification {
		   ...
		   switch( gadget_label ) {
		     ...
		     case LOCATE_AREA_GADGET :
			om$send( msg      = message VSlocate.processLocate(
						     form_ptr, gadget_label ),
				 targetid = my_id ) ;
			break ;
		     ...
		   }
		   ...		
		}

	3. - If a gadget has been located and accepted, then the filter
	     "VSgadgetLocate" will receive a
	    		"GR_UNKNOWN_TYPE.VS_K_GADGET_LOCATED"
	     response, and the label of the located gadget will be stored in
			"me->locatedGadget"
	     Eg.

		filter VSlocateGadget
			on EX_BACK_UP	state -
			on EX_RESTART	state start
			on GR_UNKNOWN_TYPE.VS_K_GADGET_LOCATED
				do your_action
				...
-d*/
message processLocate( char *form ; int gadget ) ;

/*+d
Message setMatchKey

Abstract
	To be called from a COB state table (eg. "at init do setMachkey(...)"):
	sets the match key used by some commands to use VDS's translation
	table. The purpose of the translation table is the following:
	given a command that constructs one objects using several objects as
	input (such as building a beam from a support surface and axis),
	ask the translation table for the symbology and directory where to
	name object given one input object and a key (the match key).
	The translation table is made from a config file created by the user.
Argument
	IN	char	*matchKey	The commnd's match key.
-d*/
message setMatchKey( char *matchKey ) ;

end specification VSlocateCmd ;
