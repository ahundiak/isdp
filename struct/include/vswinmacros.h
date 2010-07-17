/*
	I/STRUCT
*/
#ifndef vswinmacros_include
#define vswinmacros_include

/*+M
Macros vs$cstSomeObjcVw

Abstract
	Constructs a window and a gadget which will only display one graphic
	object.
Arguments
	OUT	long		*msg		Completion code.
	IN	char		*windowName	Name of window.
	OUT	struct GRid	*someObjcWin	Id of window.
	OUT	struct GRid	*someObjcGad	Id of gadget.
Node
	Sample usage :

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
-M*/

#omdef	vs$cstSomeObjcVw( msg, windowName, someObjcWin, someObjcGad )
	VScstSomeObjcVw( (msg), (windowName), (someObjcWin), (someObjcGad) )
#endomdef

#endif
