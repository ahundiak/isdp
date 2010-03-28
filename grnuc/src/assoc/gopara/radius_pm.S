class specification radius_pm (0:1) of expression;

/*
ABSTRACT : radius_pm is the class of parameter measuring the radius of circle
           (or arc of circle) or the radius of curvature of general b_spline

           Roots of this element :

           - a circle, an arc of circle or a general curve

	   - if the first root is a general curve, a point to define 
	     by projection on the curve where the center of curvature has
	     to be evaluated.
*/

override GRvg;

override NDcompute_node,NDplace,NDprint,NDmove_to_root;

reject modify;

/*
OVERRIDE MOTIVATION
    Specific behaviour for
        NDplace          : placement.
			   asso_lis->as_attr is a pointer to the name of
			   the radius pm (NULL pointer --> parameter whitout
	 	           name)
        NDcompute_node   : recompute after a parent change
        NDmodify         : doesn't allow a syntax modification
        NDprint          : print via graph_printer to ppl file
        NDmove_to_root   : transform to a regular expression

*/


end specification radius_pm;
