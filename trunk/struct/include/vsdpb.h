/*
 * I/STRUCT
 * Type definition for the Default Parameter Block.
 */
#ifndef vsdpb_include
#	define vsdpb_include

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif

struct VS_s_FileVersion {
	OMbyte rr, uu, ss, tt ;
} ;
typedef struct VS_s_FileVersion VSfileVersion ;

enum VSdpb_parm	{
/*
 * Beams
 */
	VS_e_dpb_B_x_offset,
	VS_e_dpb_B_y_offset,
	VS_e_dpb_B_rotation,
	VS_e_dpb_B_symmetry,
	VS_e_dpb_B_cardinal_point,
	VS_e_dpb_B_material,
	VS_e_dpb_B_grade,
	VS_e_dpb_B_type,
	VS_e_dpb_B_shape,
	VS_e_dpb_B_stock,
	VS_e_dpb_B_source,
	VS_e_dpb_B_notes,
	VS_e_dpb_B_name_pattern,
	VS_e_dpb_B_form,	
/*
 * Plates.
 */
	VS_e_dpb_P_material,
	VS_e_dpb_P_grade,
	VS_e_dpb_P_type,
	VS_e_dpb_P_stock,
	VS_e_dpb_P_source,
	VS_e_dpb_P_notes,
	VS_e_dpb_P_thickness,
	VS_e_dpb_P_thkname,
	VS_e_dpb_P_cut_off,
	VS_e_dpb_P_offset,
	VS_e_dpb_P_orientation,
	VS_e_dpb_P_name_pattern,
	VS_e_dpb_P_form,

/*
 * Joints
 */
 	VS_e_dpb_J_weldAttr,
 	VS_e_dpb_J_Allowance,
/*
 * Miscellanious.
 */
	VS_e_dpb_mass_props_toggle,
	VS_e_dpb_beam_arrow_size,
	VS_e_dpb_apprv_status,
	VS_e_dpb_const_status,
	VS_e_dpb_fireproofing_thk,
	VS_e_end_param	/* This identifier must be the last	*/
} ;

/*
 * Cardinal points
 */
enum VScardinal_point {
	VS_e_UPP_LEFT =  0,	/* upper-left    corner			*/
	VS_e_LFT_MIDD =  1,	/* left-middle   point			*/
	VS_e_BOT_LEFT =  2,	/* bottom-left   corner			*/
	VS_e_TOP_MIDD =  3,	/* top-middle    point			*/
	VS_e_BOT_MIDD =  4,	/* bottom-middle point			*/
	VS_e_UPP_RGHT =  5,	/* upper-right   corner			*/
	VS_e_GEO_CENT =  6,	/* geometric     center			*/
	VS_e_RGH_MIDD =  7,	/* right-middle  point			*/
	VS_e_BOT_RGHT =  8,	/* bottom-right  point			*/
	VS_e_LFT_PROJ =  9,	/* left  projection of center of gravity*/
	VS_e_TOP_PROJ =	10,	/* top   projection of center of gravity*/
	VS_e_RGH_PROJ = 11	/* right projection of center of gravity*/
} ;

/*
 * Symmetry codes
 */
enum VSsymmetry {
			VS_e_No_Symm	= 0,
			VS_e_X_Symm	= 1,
			VS_e_Y_Symm	= 2,
			VS_e_XY_Symm	= 3
} ;

/*
 * Form layout.
 */
struct VSdpb_form_pos {
	unsigned short	x,
			y,
			width,
			height ;
	unsigned char	screen ;
} ;		
#endif /* vsdpb_include */
