/*
	I/STRUCT
*/
class specification VSfmcppfCmd(0:0) of VSqryRdbCmd, VSlocateCmd ;

#include "vscppf.h"
#include "vssectiondef.h"
#include "vsxsfrpldef.h"
#include "vsxsfrpl.h"

instance VSfmcppfCmd {
	/*
	 * Form pointer.
	 */
	char	*fm_ptr ;

	/*
	 * Number of plates for constructing composite profile.
	 */
	int	number_of_plates,

	/*
	 * plate number in left column of pseudo multicolumn field.
	 */
		active_plate,

	/*
	 * Count of orientations.
	 */
		ornCount ;

	/*
	 * List of materials, grades, family types, thickness, orientation.
	 */
	char	**ornList ;

	/*
	 * Scale of design.
	 */
	double	scale ;

	/*
	 * Plate definition.
	 */
	VScompProfPlateDef	plates[VS_K_MAX_XSPLATES] ;

	/*
	 * Composite profile connection.
	 */
	VSxsPlConn		connection[VS_K_MAX_XSPLATES] ;

	/*
	 * Composite profile object and type.
	 */
	struct GRid		profile ;
	char			profile_type[VS_K_MAXDBNAME] ;

	/*
	 * Stick plate to move.
	 */
	int			plate2_stick,
				side2 ;

	/*
	 * flag.
	 */
	long			flag ;

#define VS_K_init_failed	 0x00001
#define VS_K_cmd_error		 0x00002
#define VS_K_command_stacked	 0x00020
#define VS_K_message_set	 0x00040
#define VS_K_unknown_shape	 0x00080
#define VS_K_construction_error  0x00100
#define VS_K_exit_cmd		 0x00200
#define VS_K_restart_cmd	 0x00400
#define VS_K_all_plates_stick	 0x00800
#define VS_K_offset_draw	 0x01000
#define VS_K_locate_plate	 0x02000

} ;

override wakeup,
	 sleep,
	 delete ;

message createForm() ;

message load_attributes( long *msg ) ;

message QueryRDB(	long	*msg ;

#define VS_m_thk_L	0x1000
#define VS_m_thk_R	0x2000
			int	action,
				fillForm ) ;

message fillFormWithRdbData( long *msg ; int action ) ;

message was_init_successful( long *msg ) ;

message enable_form( int *sts ) ;
reject	enable_form ;

message disable_form( int *sts ) ;
reject	disable_form ;

message fill_form( long *msg ) ;

message fill_pseudo_mcf( long *msg ) ;

end specification VSfmcppfCmd ;
