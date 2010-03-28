/*\
    ABSTRACT
    AScenpt is the class of associative points at the center of a circle or of
    an arc. It also gives the center of curvature of a general bspline for a
    given position on curve.

    The roots of this object are  (one to tree ):

       - the  curve.

       - if general b_spline a point defining by projection on the curve
         the position where the center of curvature is to be computed. 

       - optionnal a local coordinate system. If defined, the cent_point is
         projected in its Oxy plane.

    HISTORY
       S.Frezefond  feb - 87 : design date 
       jla          july  87 : center of curvature of bspline,
			       project in ref plane
\*/

class specification AScenpt (0:1) of ASpoint;

override GRvg;
override GRnotify;

override NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
 OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	  : placement.
	NDcompute_node 	  : recompute after a parent change.
	NDprint	     	  : print via graph_printer to ci.
	GRgetobjinfo 	  : UI_status when locate.
	ASpossible_parent : return possible parents.
\*/


end specification AScenpt;
