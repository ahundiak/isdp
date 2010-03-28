class specification DPcodpb (2:0) of global_class;

/*
   This DPB stores information about the state of various
   Display commands that isn't stored in other instance
   data.
*/
   
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include <igrdp.h>

instance DPcodpb
	{
	/* Create color table instance data */
	IGRushort cct_flags;
	variable IGRchar ctable_filename[1];

	/* perspective flags */
	IGRushort persp_flags;

	/* set window shape flags */
	IGRushort sws_flags;

	/* room for expansion */
	variable IGRdouble  d_expansion[0];
	variable IGRint     i_expansion[0];
	variable IGRshort   s_expansion[0];
	variable IGRchar    c_expansion[0];

	};


override super_construct, debug, wake_up, sleep;

message get_cct_data( IGRushort *cct_flags; IGRchar *ctable_filename );
message set_cct_data( IGRushort cct_flags; IGRchar *ctable_filename );

message get_persp_flags( IGRushort *persp_flags );
message set_persp_flags( IGRushort persp_flags );

message get_sws_flags( IGRushort *sws_flags );
message set_sws_flags( IGRushort sws_flags );

message get_dls_flags( IGRushort *dls_flags );
message set_dls_flags( IGRushort dls_flags );

message get_mvv_flags( IGRushort *mvv_flags );
message set_mvv_flags( IGRushort mvv_flags );

message get_layer_flags( IGRushort *layer_flags );
message set_layer_flags( IGRushort layer_flags );

message get_dvd_flags( IGRushort *dvd_flags );
message set_dvd_flags( IGRushort dvd_flags );

message get_pixel_tolerance( IGRchar *pixel_tol );
message set_pixel_tolerance( IGRchar pixel_tol );

message get_dvd_speed( IGRchar *dvd_speed );
message set_dvd_speed( IGRchar dvd_speed );

message get_so_flags(IGRushort *so_flags; struct IGRdisplay *so_symbology);
message put_so_flags(IGRushort *so_flags; struct IGRdisplay *so_symbology);

end specification DPcodpb;
