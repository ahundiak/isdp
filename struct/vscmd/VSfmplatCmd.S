/*
	I/STRUCT
*/
class specification VSfmplatCmd(0:0) of VSqryRdbCmd, VSlocateCmd ;

#include "EMSmsgdef.h"
#include "vsdef.h"
#include "vs.h"
#include "vsdpb.h"
#include "vsdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsRDBmacros.h"
#include "vsRDBdef.h"
#include "vsplatedef.h"
#include "vsplformdef.h"
#include "vsiomacros.h"
#include "vsqryrdbdef.h"

instance VSfmplatCmd {
	/*
	 * Values of cut-off thickness and offset.
	 */
	double	cut_off,
		offset ;
	/*
	 * Index of current member class, member type.
	 */
	int	clsIndex,
		typIndex,
	/*
	 * Count user attributes.
	 */
		usrAttCount,

		number_of_plates,

	/*
	 * Orientation of plate.
	 */
	 	orientation ;

	char	*stock,
		*source,
		*approval_status,
		*construction_status,
		*notes,
		*directory,
		cnstDir[DI_PATH_MAX],
		basename[DI_PATH_MAX] ;
	/*
	 * Fireproofing Thickness
	 */
	double 	fireproofing ;

	/*
	 * Change Number.
	 */
	int 	change_number ;

	char	**usrNamList,			/* List of names for user  */
						/* attributes.		   */
		**usrSynList ;			/* List of syntaxes for    */
						/* user attributes.	   */
	
	long	clsMsg[VS_rdb_MAXCLASSES],	/* List of member class	   */
						/*  description messages   */
		typMsg[VS_rdb_MAXPLTYPES] ;	/* List of member type	   */
						/*  description messages   */

	int	clsCode[VS_rdb_MAXCLASSES],     /* Class code list	   */
		typCode[VS_rdb_MAXPLTYPES] ;    /* Type code list	   */

	int	ActGrp ;			/* Active gadget group     */
						/* displayed.	     	   */

	struct GRid	UAid ;			/* Id of collection.	   */

	char		*fm_ptr ;		/* C-based form ptr	   */

	IGRboolean	nameModified;		/* Flag to check if name 
						   is modified		   */

#define	VS_K_form_active	0x00001
#define VS_K_init_failed	0x00002
#define VS_K_initial_ntf	0x00004
#define VS_K_deflt_cutoff	0x00080
#define VS_K_cmd_error		0x00100
#define VS_K_no_attributes	0x00400
#define VS_K_command_stacked	0x00800
#define VS_K_modify_form	0x01000
#define VS_K_no_object_located  0x02000
#define VS_K_message_set	0x04000
#define VS_K_change_usr_attr	0x08000

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
	Overriden to erase plate form.
Arguments
	See message "sleep" of class "super_cmd"
-o*/
	sleep,

/*+o
Message delete

Abstract
	Overriden to store iplate form location and size.
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
	Fills and displays plate form at the last location with the
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
	Fills all gadgets of plate form.
Argument
	OUT	long	*msg	Completion code.
-d*/
message	fill_form( long *msg ) ;

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
	VS_m_prt	: load thicknesses (ASCII part name)
	VS_m_par	: load values of thicknesses.

	#defined in "vsqryrdbdef.h".
-d*/
message QueryRDB(	long	*msg ;
			int	action,
				fillForm ) ;

message fillFormWithRdbData( long *msg ; int action ) ;

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
Message tellUser

Abstract
	Writes a message to the form's message field. Clear field it if
	`msgnum' is MS_NO_MSG.
Arguments
	IN	long	msgnum	Number of message.
-d*/
message tellUser( long msgnum ) ;

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
	Writes active plate attributes to the DPB.
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
Message display_support_normal

Abstract
	Displays first support's normal vector.
Argument
	enum GRdpmode	dpmode	Display mode of normal vector.
-d*/
message display_support_normal( enum GRdpmode mode ) ;

/*+d
Message overrideForm

Abstract
	Overrides default setings of form.
-d*/
message overrideForm() ;

/*+d
Message updCutOff

Abstract
	Update the cut-off value. This value is accepted, if it's superior to
	the thickness value, else the cut-off value is set to thickness.
Arguments
	OUT	long		*msg	Completion code.
	IN	double		value	the Cut-off value keyin.
-d*/
message updCutOff( long *msg ; double value ) ;

message getCnstDefaults() ;

end specification VSfmplatCmd ;
