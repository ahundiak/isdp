/*
	An associative class for single parallel Dimension.

	Roots:

	1)	Linear element

	2)	"mea_axis" the vector made by the line with X-axis

	3)	"environ_param" - belonging to class "dim_param"

	4)	"local_param" - belonging to class "dim_param"

	5)	"cmpx_param" - belonging to class "dim_param"

*/

class specification DMsglpara(2:0) of DMlinear;

override GRvg;

override NDplace;
override get_dimension_plane;
override get_orig_meas;

end specification DMsglpara;
