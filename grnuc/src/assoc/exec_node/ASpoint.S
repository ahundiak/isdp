/*
ABSTRACT :
         The abstract class ASpoint is the parent class for all the parametric
	 points with associations build into the design as constraints.

CHANGE HISTORY :
        ch           jul-86 : design date
        jla       10-mar-87 : union class
        jla          dec-87 : suppression of give_strucuture and GRlocowner 
 			      override
       momo       06-fev-89 : add poststr method

NOTE : The GRlocowner override was used to make point more locatable, 
       dividing the distance to locate point. Since the located object are
       no longer obtained in  increasing distance order, we don't know how to
       obtain this possibility.

*/

class specification ASpoint (0:1) of GRpoint,ASlinear;

override GRvg;
override ASpoststr;

/* override GRlocowner; */

end specification ASpoint;
