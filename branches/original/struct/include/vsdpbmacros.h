/*
 * I/STRUCT
 * Macros to access the Default Parameter Block.
 */

#ifndef vsdpbmacros_include
#	define vsdpbmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

/*+M
Macro vs$get_act_pm

Abstract
	Returns and active parameter from the DPB.
Arguments
	IN	long			*msg		MSSUCC, MSFAIL [severe],
	IN	enum VSdpb_parm		param		Parameter to retrieve,
	OUT	char			*p_arg		Memory to store value
							(See below),
Note
	_B_ : beam, _P_ : plate, _J_ : joint
	Parameter			Type of p_arg		Comment
	---------------------------------------------------------------
	VS_e_dpb_B_x_offset		double *
	VS_e_dpb_B_y_offset		double *
	VS_e_dpb_B_rotation		double *
	VS_e_dpb_B_symmetry		int *
	VS_e_dpb_B_cardinal_point	enum VScardinal_point *
	VS_e_dpb_B_material		char **			volatile
	VS_e_dpb_B_grade		char **			volatile
	VS_e_dpb_B_type			char **			volatile
	VS_e_dpb_B_shape		char **			volatile
	VS_e_dpb_B_stock		char **			volatile
	VS_e_dpb_B_source		char **			volatile
	VS_e_dpb_B_notes		char **			volatile
	VS_e_dpb_B_name_pattern		char **			volatile
	VS_e_dpb_B_form			struct VSdpb_form_pos *
	VS_e_dpb_P_material		char **			volatile
	VS_e_dpb_P_grade		char **			volatile
	VS_e_dpb_P_type			char **			volatile
	VS_e_dpb_P_stock		char **			volatile
	VS_e_dpb_P_source		char **			volatile
	VS_e_dpb_P_notes		char **			volatile
	VS_e_dpb_P_thickness		double *
	VS_e_dpb_P_thkname		char **			volatile
	VS_e_dpb_P_name_pattern		char **			volatile
	VS_e_dpb_P_cut_off		double *
	VS_e_dpb_P_offset		double *
	VS_e_dpb_P_orientation		int *
	VS_e_dpb_P_form			struct VSdpb_form_pos *
	VS_e_dpb_apprv_status		char **			volatile
	VS_e_dpb_const_status		char **			volatile
	VS_e_dpb_fireproofing_thk	double *
	VS_e_dpb_J_weldAttr		VSweldAttr *
*/
extern int
VSdpb_get			__((	long			*msg,
					enum VSdpb_parm		param,
					char			*p_arg )) ;

#omdef	vs$get_act_pm( msg, param, p_arg )
	VSdpb_get( (msg), (param), (char *) (p_arg) )
#endomdef

/*+M
Macro vs$get_massp_toggle

Abstract
	Returns the value of the mass properties compute toggle.
Arguments
	OUT	long		*msg		MSSUCC, MSFAIL [severe]
	OUT	int		*p_toggle	TRUE/FALSE
-M*/
#omdef	vs$get_massp_toggle( msg, p_toggle )
	VSdpb_get( (msg), VS_e_dpb_mass_props_toggle, (char *) (p_toggle) )
#endomdef

/*+M
Macro vs$get_beam_arrow_size

Abstract
	Returns the value of the default size for arrow at end of beams in
	light representation.
Arguments
	OUT	long		*msg		MSSUCC, MSFAIL [severe]
	OUT	double		*p_size		Size of arrows.
-M*/
#omdef	vs$get_beam_arrow_size( msg, p_size )
	VSdpb_get( (msg), VS_e_dpb_beam_arrow_size, (char *) (p_size) )
#endomdef

/*+M
Macro vs$put_act_pm

Abstract
	Sets an active parameter.
Arguments
	OUT 	long			*msg		MSSUCC, MSFAIL [severe].
	IN	enum VSdpb_parm		param		Parameter to retrieve.
	IN	char			*p_arg		Input value (See below).
Note
	_B_ : beam, _P_ : plate _J_ : joint
	Parameter			Type of p_arg		Comment
	---------------------------------------------------------------
	VS_e_dpb_B_x_offset		double *
	VS_e_dpb_B_y_offset		double *
	VS_e_dpb_B_rotation		double *
	VS_e_dpb_B_symmetry		int *
	VS_e_dpb_B_cardinal_point	enum VScardinal_point *
	VS_e_dpb_B_material		char *
	VS_e_dpb_B_grade		char *
	VS_e_dpb_B_type			char *
	VS_e_dpb_B_shape		char *
	VS_e_dpb_B_stock		char *
	VS_e_dpb_B_source		char *
	VS_e_dpb_B_notes		char *
	VS_e_dpb_B_name_pattern		char *
	VS_e_dpb_B_form			struct VSdpb_form_pos *
	VS_e_dpb_P_material		char *
	VS_e_dpb_P_grade		char *
	VS_e_dpb_P_type			char *
	VS_e_dpb_P_stock		char *
	VS_e_dpb_P_source		char *
	VS_e_dpb_P_notes		char *
	VS_e_dpb_P_thickness		double *
	VS_e_dpb_P_name_pattern		char *
	VS_e_dpb_P_thkname		char *
	VS_e_dpb_P_cut_off		double *
	VS_e_dpb_P_offset		double *
	VS_e_dpb_P_orientation		int *
	VS_e_dpb_P_form			struct VSdpb_form_pos *
	VS_e_dpb_apprv_status		char *
	VS_e_dpb_const_status		char *
	VS_e_dpb_fireproofing_thk	double *
	VS_e_dpb_J_weldAttr		VSweldAttr *
-M*/
extern int
VSdpb_put			__((	long			*msg,
					enum VSdpb_parm		param,
					char			*p_arg )) ;

#omdef	vs$put_act_pm( msg, param, p_arg )
	VSdpb_put( (msg), (param), (char *) (p_arg) )
#endomdef


/*+M
Macro vs$put_massp_toggle

Abstract
	Sets the value of the mass properties compute toggle.
Arguments
	OUT	long		*msg		MSSUCC, MSFAIL [severe].
	IN	int		*p_toggle	TRUE/FALSE.
-M*/
#omdef	vs$put_massp_toggle( msg, p_toggle )
	VSdpb_put( (msg), VS_e_dpb_mass_props_toggle, (char *) (p_toggle) )
#endomdef

/*+M
Macro vs$put_beam_arrow_size

Abstract
	Sets the value of the default size for arrow at end of beams in
	light representation.
Arguments
	OUT	long		*msg		MSSUCC, MSFAIL [severe]
	IN	double		*p_size		Size of arrows.
-M*/
#omdef	vs$put_beam_arrow_size( msg, p_size )
	VSdpb_put( (msg), VS_e_dpb_beam_arrow_size, (char *) (p_size) )
#endomdef

/*+M
Macro vs$getVersionStampId

Abstract
	Returns the id of the object storing the version of I/STRUCT with which
	a file was made.
Arguments
	IN	OMuword		osnum		Object space number of file.
	OUT	OM_S_OBJID	*stampId	Id of version object.
-M*/
extern int
VSgetVersionStampId		__((	OMuword		osnum,
					OM_S_OBJID	*stampId )) ;

#omdef vs$getVersionStampId( osnum, stampId )
	VSgetVersionStampId( (osnum), (stampId) )
#endomdef

/*+M
Macro vs$getDpbCollAttr

Abstract
	Retrieves by name the value of an attribute in the DPB's collection.
Arguments
	IN	long	*msg		Completion code
	IN	char	*name		Name of attribute.
	OUT	char	*p_value	Value of attribute.
-M*/
extern long
VSgetDpbCollAttr		__((	long	*msg,
					char	*name,
					char	*p_value )) ;

#omdef vs$getDpbCollAttr( msg, name, p_value )
	VSgetDpbCollAttr( (msg), (name), (char *) (p_value) )
#endomdef

/*+M
Macro vs$putDpbCollAttr

Abstract
	Sets by name the value of an attribute in the DPB's collection.

Arguments
	IN	long	*msg		Completion code
	IN	char	*name		Name of attribute.
	IN	char	*value		Value of attribute.
*/
extern long
VSputDpbCollAttr		__((	long	*msg,
					char	*name,
					char	*value )) ;

#omdef vs$putDpbCollAttr( msg, name, value )
	VSputDpbCollAttr( (msg), (name), (char *) (value) )
#endomdef

#endif /* vsdpbmacros_include */

