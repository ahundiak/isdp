/*
 * Macros for sending OM messages form PPL files.
 * E BEEKER Nov '87
 * File dependency: OMminimum.h ( only if OM_p_CHANSELECT p_chanselect is used
 *                  in "ci$send" )
 */

#ifndef cisend_include
#define cisend_include


#define WRT_object	0
#define WRT_message	1
#ifndef NULL
#	define NULL 0
#endif
/****************************** ci$send ******************************/
/*
 *	General purpose macro to send a message from a PPL file.
 *
 * ARGUMENTS:
 *		message		the message to be sent
 * GRobj	targetid	the target object id
 * char		*targetname	the target object name
 *				NB: "targetid" and "targetname" are exclusive
 *				before sending a message to a named object,
 *				the user must be sure that this object 
 *				has a name ( see Doc on naming objects )
 * short	targetos	the target object space number or
 * char		*targetos	the target object space name.
 * char		*channame	the channel name
 * OM_p_CHANSELECT p_chanselect	the channel selector
 * int		construct	TRUE : constructs the object.
 *				FALSE: does not construct the object.
 * int 		verbose		TRUE : will output OM error messages during send
 *				FALSE: no (default)
 * int		mode		WRT_object/ WRT_message	
 *				see OM manual
 *
 * RETURN CODE
 *	ci$send returns 	1: in case of success
 *				an OM return code in case of error
 *				( OM return codes defined in OMerrordef.h )
 *
 * EXAMPLES:

(1)	if( ci$send( msg      = message ci.get_value( 0, "var", &i, sizeof i ),
		     targetid = my_id(),
		     targetos = my_os() ) != 1 ) {
		 write( "message failed\n" );
		 goto err;
	}


(2)	ci$send( msg		= message FIform.display_form(&Mes, -1, -1),
		 targetname	= "my_form",
		 targetos   	= my_os() ) ;

 */

#omdef ci$send(	msg,
		  targetid
		^ targetname,
		targetos	= -1,
		channame	= (char *)0,
		p_chanselect	= NULL, 
		construct	= 0,
		mode		= WRT_object,
		verbose		= 0 )

#if om$specified(channame) && om$specified(p_chanselect)
#	omerror "`channame' OR `p_chanselect' must be specified"
#endif

#if om$specified( targetid )
	CIsend(	msg,
		(targetid),
		(targetos),
		(construct),
		(mode),
		(channame),
		(verbose),
		(p_chanselect) )
#elif om$specified( targetname )
	CIsend(	msg,
		(targetname),
		(targetos),
		(construct),
		(mode),
		(channame),
		(verbose),
		(p_chanselect) )
#endif

#endomdef

#endif
