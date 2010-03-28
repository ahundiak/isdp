class specification COdynsetvw (1:0) of COwindow, COtools;



#include "FI.h"


instance COdynsetvw
{
	IGRdouble	coi_pnt[3];
	IGRdouble	eye_pnt[3];
	IGRdouble	vup_pnt[3];
	IGRdouble 	vup_vec[3];
	IGRdouble	angle_radius;
	IGRdouble	vrp_pnt[3];
 	IGRdouble	depths[2];
	IGRdouble	near_pnt[3];
	IGRdouble	far_pnt[3];
	IGRdouble	proj_pt[3];
	IGRshort	input;
	IGRshort	dsp_on_off;
	IGRdouble	vpn_pnt[3];
	IGRdouble	vpn_vec[3];
	IGRint		state_flag;
	IGRint		form_flag;
	struct IGRdisplay *dis_attr[5];
	struct IGRdisplay solid;
	struct IGRdisplay dashed;	
	IGRboolean	vw_type_persp;
	IGRint 		cvt_flag;
	IGRint          dyn_state;
};


message find_state ( long * sts );

override dynamics;

message dyninit ( long * sts );

override status_disp;

override form_notification;

message default_setup ( long * sts );

message store_coi ( long * sts );

message store_eye_pnt ( long * sts );

message store_vup ( long * sts );

message calc_angle ( long * sts );

message calc_radius ( long * sts );

message store_radius ( long * sts );

message store_angle ( long * sts );

message calc_dist ( long * sts );

message store_dist ( long * sts );

message store_far_dist ( long * sts );

message norm_vwvec ( long * sts );

message store_vrp ( long * sts );

message store_vpn ( long * sts );

message set_view ( long * sts );

message cvt ( long * sts );

end specification COdynsetvw;
