/*\
ABSTRACT
    ASlineortho is the class of parametric lines constructed orthogonal to
    a plane.

    The possible roots of this object are :

 --------------------------------------------------------------------------
 | parents  		    | ASlineorth orthogonal to the plane defined  |
 |--------------------------|---------------------------------------------|
 | 1 point , 1 coor. syst   | by the Oxy plane of the coor. syst.         |
 | 1 point , 1 planar curve | by this curve 				  |
 | 3 points                 | by the 3 points				  |
 --------------------------------------------------------------------------


 The midlle of the line is its first root. 
    


CHANGE HISTORY:
	
        jla  15-apr-87 design date
	ch      oct-87 plane implementation
\*/

class specification ASlineorth (0:1) of ASline;

override GRvg;
 override GRnotify;
override NDplace,NDcompute_node,NDprint,GRgetobjinfo, ASpossible_parent;

/*\
MOTIVATION
  NDplace            -placement. as_attr is a pointer to an IGRpoint.This point
		      defines the extends of the ortho line
  NDcompute_node     - recompute after parent change
  NDprint            - edit to ci
  GRgetobjinfo       - UIstatus message on locate
  ASpossible_parent  - return possible parents and type
\*/

end specification ASlineorth;
