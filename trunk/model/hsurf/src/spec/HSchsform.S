class specification HSchsform (1:0) of HSwindow;



#include "wl.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "FI.h"
#include "HSchs_label.h"
#include "hsurf.h"
#include "hsmsg.h"


instance HSchsform
{
	IGRdouble		tracing_tolerance;
	IGRdouble		gapping_distance;

	Form			form_ptr;
	IGRint			switch1;
	IGRboolean		assoc_flag;
	
	IGRchar			window_name[GRNAME_SIZE];
	unsigned char		clip_to_fence;
	unsigned char		process_wireframe;
	unsigned char		resolution;
	unsigned char		tracing;
	unsigned char		gapping;
	unsigned char		delete_overrides;
	unsigned char		process_tangent;
	};


message check_for_old_files ( long * sts );

message spawn_elements_in_view ( long * sts );

message which_state ( long * sts );

message validate_window ( long * sts );

message get_window_name ( long * sts );

message get_dpb_info ( long * sts );

message set_dpb_info ( long * sts );

message form_init ( long * sts );

override form_notification;

message HSchs_init ( long * sts );

message HSchs_wakeup ( long * sts );

message HSchs_sleep ( long * sts );

message HSchs_delete ( long * sts );

message process ( long * sts );

end specification HSchsform;
