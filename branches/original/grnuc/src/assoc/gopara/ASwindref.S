/*
ABSTRACT : ASwindref is the class of associative local coordinate systems 
	   defined by an origine, with a constant matrix, as defined in 
           the place method.

	   This objet has one root, a point which defines the origine of the
           coor. syst.




CHANGE HISTORY
	
  D.Payannet   14 nov  86 : design date
*/

class specification ASwindref (0:1) of ASref;

override GRvg;
 override GRnotify;
override GRgencs;

override NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	place        	 : placement. asso_lis->as_attr is a pointer to an 
			   IGRmatrix. This matrix defines the orientation of
			   its axes. (be carrefull the matrix is :
			   [ Ux,Vx,Wx,Ox, Uy,Vy,Wy,Oy, Uz,Vz,Wz,Oz, 0,0,0,1 ]
			   where U,V,W are the axis of the cor. syst. and 
                           O is not used).
	compute_node 	 : recompute after a parent change. Particularity :
	print	     	 : print via graph_printer to ci
	ASpossible_parent: return possible parents
\*/


end specification ASwindref;
