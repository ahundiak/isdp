
/********************** - DMlincpx - ******************************

This class represents the complex linear dimensions, both stacked
and stringed linear dimensions. It subclasses from DMlinear class
overriding the necessary messages.

*******************************************************************/


class specification DMlincpx (2:0) of DMlinear;

override GRvg;

message compute_proj_disp(
	IGRchar mea_trak;
	IGRchar proj_side;
	IGRdouble trak_dist;
	IGRboolean first_in_cpx;
	IGRchar *proj_disp);

message swap_if_needed(struct GRmd_env *md_env);

override DMplace;

/* - Override DMlinear messages - */

override get_mea_trak_info;
override get_orig_meas;

/* - Override DMcomplex messages - */

override set_proj_disp;
override give_rel_pos;
override fill_info;
override change_dimension_origin;
override change_dimension_measurement;

end specification DMlincpx;
