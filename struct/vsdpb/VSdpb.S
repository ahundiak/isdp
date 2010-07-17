/*
	I/STRUCT
*/
class specification VSdpb(0:0) of global_class ;

#ifndef OM_D_MACROS
#	include "OMmacros.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"		/* IGE typedefs GR*		*/
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"		/* Typedef IGR*			*/
#endif
#ifndef gr_include
#	include "gr.h"			/* Typedef GR*			*/
#endif
#include "vspart.h"
#include "vsweld.h"
#include "vsdpb.h"

struct VSdpb_flags	{
	unsigned short	B_symmetry		: 2,
			B_cardinal_point	: 4,
			P_orientation		: 1,
			massp_toggle		: 1 ;
} ;

instance VSdpb {

	double
/*
 * Double floating point beam attributes.
 */

				B_x_offset,	/* Beam x-offset	*/
				B_y_offset,	/* Beam y-offset	*/
				B_rotation,	/* Beam rotation	*/
				B_arw_size,	/* Size of beam arrows	*/

/*
 * Double floating point plate attributes.
 */
				P_thickness,
				P_cut_off,
				P_offset ;
	variable char
/*
 * ASCII beam attributes.
 */
				B_material	[0],
				B_grade 	[0],
				B_type		[0],
				B_shape    	[0],
				B_stock		[0],
				B_source	[0],
				B_notes		[0],
				B_name_pattern	[0],
/*
 * ASCII plate attributes.
 */
				P_material	[0],
				P_grade		[0],
				P_type		[0],
				P_stock		[0],
				P_source	[0],
				P_notes		[0],
				P_thkname	[0],
				P_name_pattern	[0] ;

/*
 * Joint weld attribute.
 */
	VSweldAttr		J_weldAttr ;

/*
 * Joint allowance.
 */
	float			J_allowance ;

/*
 * Approval and construction statuses.
 */
	variable char		ApprovalSts	[0],
				ConstructionSts	[0] ;
/*
 * Fireproofing thickness
 */
 	double			FireProofingThk ;

/*
 * Beam and plate form layouts.
 */
	struct VSdpb_form_pos	B_form,
				P_form ;

/*
 * Plate and beam flags.
 */
	struct VSdpb_flags	flags ;
} ;

override	super_construct,
		wake_up,
		sleep ;

/*+d
Message get

Abstract
 	Retrieves a parameter from the parameter block.
Arguments
	OUT	long			*msg	MSSUCC	: success.
						MSINARG	: `type' unrecognized.
						MSFAIL	: severe.
	IN	enum VSdpb_parm		type	Desired value.
	OUT	char			*pm	Address of buffer to receive
						value.
-d*/
message	get(	long		*msg ;
		enum VSdpb_parm	type ;
		char		*pm ; ) ;

/*+d
Message put

Abstract
 	Sets a parameter in the parameter block.
Arguments
	OUT	long			*msg	MSSUCC	: success
						MSINARG	: `type' unrecognized
						MSFAIL	: severe
	IN	enum VSdpb_parm		type	Desired value.
	IN	char			*pm	Address of buffer to get value
						from.
-d*/
message	put(	long		*msg ;
		enum VSdpb_parm	type ;
		char		*pm ; ) ;

/*+d
Message have_beam_data

Abstract
	Checks that DPB has been loaded with beam data.
Argument
	OUT	int	*loaded		TRUE/FALSE
-d*/
message have_beam_data( int *loaded ) ;

/*+d
Message have_plate_data

Abstract
	Checks that DPB has been loaded with plate data.
Argument
	OUT	int	*loaded		TRUE/FALSE
-d*/
message have_plate_data( int *loaded ) ;

end specification VSdpb ;

