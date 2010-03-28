/*
	An associative class for Circular Diameter Dimension.

	Roots:

	1)	Dimension Plane

	2)	Environment Parameters

	3)	Local Parameters

	4)	Element to be dimensioned

	u_parameter value must be specified in DMattr for
	NDplace message.

*/

class specification DMcirdia(2:0) of DMlinear;

override GRvg;

override NDplace;
override get_orig_meas;
override get_dimension_plane;

end specification DMcirdia;
