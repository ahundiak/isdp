/*
	I/STRUCT
*/
class specification VSfmbeamCmd(0:0) of VSqryRdbCmd, VSlocateCmd ;

#include "EMSmsgdef.h"
#include "vs.h"
#include "vsdpb.h"
#include "vsdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsRDBdef.h"
#include "vsRDBmacros.h"
#include "vsbeamdef.h"
#include "vsbmformdef.h"
#include "vsiomacros.h"

instance VSfmbeamCmd {
	/*
	 * Index of current member class, member type.
	 */
	int	clsIndex,
		typIndex,
	/*
	 * Count user attributes.
	 */
		usrAttCount,

		number_of_beams ;

	/*
	 * Local Offset
	 */
	double	X_offset,
		Y_offset,
		rotation,
		
	/*
	 * Fireproofing Thickness
	 */
	 	fireproofing ;
	 	
	/*
	 * Change Number.
	 */
	int	change_number ;

	int	reference_point ;

	int	symmetry ;

	char	*stock,
		*source,
		*approval_status,
		*construction_status,
		*notes,
		*directory,
		cnstDir[DI_PATH_MAX],
		basename[DI_PATH_MAX] ;

	char	**usrNamList,			/* List of names for user  */
						/* attributes.		   */
		**usrSynList ;			/* List of syntaxes for    */
						/* user attributes.	   */

	long	clsMsg[VS_rdb_MAXCLASSES],	/* List of member class	   */
						/*  description messages   */
		typMsg[VS_rdb_MAXBMTYPES] ;	/* List of member type	   */
						/*  description messages   */

	int	clsCode[VS_rdb_MAXCLASSES],     /* Class code list	   */
		typCode[VS_rdb_MAXBMTYPES] ;    /* Type code list	   */

        double  display_ratio ;
		
	int	ActGrp ;			/* Active gadget group	   */ 
						/* displayed.	   	   */
	
	struct GRid	UAid ;			/* Id of collection.	   */
	
	char		*fm_ptr ;		/* C-based form ptr	   */
	
	unsigned short	ActBeam ;       	/* The beam to display     */
						/* section.                */

	int		position ;		/* Position for stiffener  */
						/* ( normal to side or     */
						/*   along plane ).        */

	IGRboolean	nameModified ;		/* Flag indicating whether */
						/* name of stiffener modified. */
	
#define	VS_K_form_active	0x00001
#define VS_K_init_failed	0x00002
#define VS_K_initial_ntf	0x00004
#define VS_K_cmd_error		0x00100
#define VS_K_command_stacked	0x00200
#define VS_K_first_inter_displ	0x00400
#define VS_K_modify_form        0x00800
#define VS_K_message_set	0x01000
#define VS_K_no_attributes	0x02000
#define VS_K_no_object_located	0x04000
#define VS_K_beam_constructed   0x08000
#define VS_K_change_usr_attr	0x10000
#define VS_K_change_cnst_type   0x20000
#define VS_K_change_gap_dtc	0x40000

	unsigned long	flag ;

} ;

override

/*+o
Message wakeup

Abstract
	Overriden display form.
Arguments
	See message "wakeup" of class "super_cmd".
-o*/
	wakeup,

/*+o
Message sleep

Abstract
	Overriden to erase beam form.
Arguments
	See message "sleep" of class "super_cmd"
-o*/
	sleep,

/*+o
Message delete

Abstract
	Overriden to store ibeam form location and size.
	See message "delete" of class "Root"
-o*/
	delete ;

/*+d
Message initToFailure

Abstract
	Initializes command to "failure" state, in case a connection to the
	RDB server is requested, and the connection is not successful.
Arguments
	None.
-d*/
message	initToFailure() ;

/*+d
Message createForm

Abstract
	Fills and displays beam form at the last location with the
	same size as when it was last dismissed.
-d*/
message	createForm() ;

/*+d
Message was_init_successful

Abstract
	Checks that command initialization (mainly access to RDB) was
	successful. If not successful, there is no purpose for the command
	to continue.
Argument
	OUT	long	*msg	Completion code.
-d*/
message was_init_successful( long *msg ) ;

/*+d
Message load_attributes

Abstract
	Gets attributes to fill form's gadgets.
Argument
	OUT	long	*msg	Completion code.
-d*/
message load_attributes( long *msg )  ;
reject load_attributes ;

/*+d
Message fill_form

Abstract
	Fills all gadgets of beam form.
Argument
	OUT	long	*msg	Completion code.
-d*/
message	fill_form( long *msg ) ;

/*+d
Message enable_form

Abstract
	Enables all modifiable gadgets of form.
Argument
	OUT	long	*msg		Completion code.
-d*/
message enable_form( long *msg ) ;

/*+d
Message disable_form

Abstract
	Disables all gadgets of form.
Argument
	OUT	long	*msg		Completion code.
-d*/
message disable_form( long *msg ) ;

/*+d
Message get_modifiable_gadgets

Abstract
	Returns the list of the modifiable gadgets of form.
Arguments
	OUT	long		*msg	Completion code.
	OUT	struct VSgadget **list	List of modifiable gadgets.
Note
	This message returns a pointer to static memory which therefore has
	not to be freed by the caller.
-d*/
message get_modifiable_gadgets( long *msg ; struct VSgadget **list ) ;
reject get_modifiable_gadgets ;

/*+d
Message write_to_DPB

Abstract
	Writes active beam attributes to the DPB.

Arguments
	OUT	long		*msg	Completion code.
-d*/
message write_to_DPB( long *msg ) ;

/*+d
Message initial_form_notification

Abstract
	This message is received by the command when a gadget which has
	the "initial-notification" attribute on is selected.
Arguments
	Same as message "form_notification" of class "CEO".
-d*/
override initial_form_notification ;

/*+d
Message tellUser

Abstract
	Writes a message to the form's message field. Clear field it if
	`msgnum' is MS_NO_MSG.
Arguments
	IN	long	msgnum	Number of message.
-d*/
message tellUser( long msgnum ) ;

/*+d
Message set_initial_gadget_attributes

Abstract
	initialize attributes of gadgets VS_K_bm_Material_Type, VS_K_bm_Material_Grade
	VS_K_bm_Shape_Name and  VS_K_bm_Section_Name to use the method 
	initial_notification.
Arguments
	OUT	long		*msg	Completion code.
-d*/
message  set_initial_gadget_attributes( long *msg );

/*+d
Message draw_section_on_form

Abstract
	draw the active section on the form.
Arguments
	OUT	long		*msg	Completion code.
-d*/
message draw_section_on_form( long *msg );

/*+d
Message QueryRDB

Abstract
	The main interface to the Relational Data Base. Rolls back former values
	should this query fail.
Arguments
	OUT	long	*msg		Completion code.
	IN	int	action		Action to perform.
	IN	int	fillForm	TRUE/FALSE.
Note
	`action' may be an ORing of the following:
	VS_m_mat	: load materials
	VS_m_grd	: load grades
	VS_m_fam	: load families
	VS_m_prt	: load sections
	VS_m_par	: load section parameters
-d*/
message QueryRDB(	long	*msg ;
			int	action,
				fillForm ) ;

message fillFormWithRdbData( long *msg ; int action ) ;

/*+d
Message fill_section_area_and_length_gadgets

Abstract
	This method retrieve the area end the length of the active section and
	fill corresponding gadgets.
Arguments
	OUT	long	*msg		Completion code.
-d*/
message fill_section_area_and_length_gadgets( long *msg ) ;

message getCnstDefaults() ;

end specification VSfmbeamCmd ;

