/*
	I/STRUCT
*/
class specification VSsomeObjcVw (0:0) of GRlistener, IGEgragad ;

/*+c
	Class for a graphic gadget belonging to a graphic window (GRwindow)
	which only displays one graphic object. The gadget is connected to
	the graphics object via the graphic object's notification channel so
	that if the graphic object is deleted, this gadget sends a delete
	message to the window it belong to.

	To construct a window with a one-object display gadget, invoke the
	macro vs$cstSomeObjcVw #defined in vswinmacros.h :

	long		sts,
			msg ;
	GRname		windowName ;	// Name for window
	struct GRid	someObjcWin,	// One-object window
			someObjcGad,	// One-object gadget
			objToDisplay ;	// The one object to display

	sts = vs$cstSomeObjcVw(	msg		= &msg,
				windowName	= windowName,
				someObjcWin	= &someObjcWin,
				someObjcGad	= &someObjcGad ) ;

	The window is constructed in the active design file.
	The tell gadget which object to exclusively display :

	sts = om$send(	msg	= message VSsomeObjcVw.setObjectToDisplay(
								&objToDisplay ),
			targetid= someObjcGad->objid,
			targetos= someObjcGad->osnum ) ;

	Have view fitted to object to display :

	sts = om$send(	msg	= message VSsomeObjcVw.DPfit(
						 &msg, 0 // ignored ),
			targetid= someObjcGad->objid,
			targetos= someObjcGad->osnum ) ;

	If you wish to delete the window and its gadget :

	sts = om$send(	msg	= message Root.delete( 0 ),
			targetid= someObjcWin->objid,
			targetos= someObjcWin->osnum ) ;
-c*/

instance VSsomeObjcVw {
	channel	{ ( initial = 1, increment = 1) } toObjToDisplay ;
} ;

override

/*+o
Message DPgen_update

Abstract
	Update self using the object you are connected to instead of querying
	the Range Tree.
Arguments
	See message DPgen_update of class IGEgragad.
-o*/
	DPgen_update,

/*+o
Message DPdisbyoid

Abstract
	Only display the object you are connected to if it is in the list of
	objects to display, else do nothing.
Arguments
	See message DPdisbyoid of class IGEdisplay.
-o*/
	DPdisbyoid,

/*+o
Message DPfit

Abstract
	Fit self using the range of the object you are connected to.
Arguments
	See message DPfit of class IGEgragad.
-o*/
	DPfit,

/*+o
Message DPdisbyoid

Abstract
	React to the notification that the object you are connected to has
	been deleted and send a delete message to the window you belong to.
Arguments
	See messageGRnotifylis of class GRlistener.
-o*/
	GRnotifylis ;

/*+d
Message setObjectToDisplay

Abstract
	Connect self to object input as argument. First disconnect from previous
	object if any.
Arguments
	IN	struct GRid	*theObjToDisplay	Object to be seen in
							view.
-d*/
message setObjectToDisplay( struct GRid *theObjToDisplay ) ;

/*+d
Message getObjectToDisplay

Abstract
	Returns the object you are connected to. Should you be connected to
	nobody then returns NULL_OBJID.
Arguments
	OUT	struct GRid	*theObjToDisplay	Object to be seen in
							view.
-d*/
message getObjectToDisplay( struct GRid *theObjToDisplay ) ;

end specification VSsomeObjcVw ;
