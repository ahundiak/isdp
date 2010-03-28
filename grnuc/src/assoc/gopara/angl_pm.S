class specification angl_pm (0:0) of expression;

/*\
ABSTRACT :  angl_pm is the class of parameter measuring  an angle.
            This object has 1 to 3 roots :
	  
          - an arc of circle. The parameter measures the corresponding angle.

	  - Measure the angle from the first to the second line. Since the
	    object can't suppose the direction of the line, angle is modulus
	    180 degres.

	  - 3 points P0,P1,P2. The parameter measure the angle around P0 from
	    P1 to P2 in the anticlockwise direction. Value is modulus 360
            degrees.

	 For the angle between lines or points, the anticlockwise direction
         is defined at placement time with a view vector. The main axis of
	 this vector is stored in the instance of the object (me->axe) for
	 future evaluation.


         Value returned in DEGREES



HISTORY : 
         jla       jul-86 : design
*/


instance angl_pm
 {
  IGRchar axe;    /* axe to have angle continuity when recompute */
 };

override GRvg;


override NDplace,NDcompute_node,NDprint,NDmove_to_root;

override NDattach_to_cs,NDdetach_from_cs;

reject modify;
/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement. asso_lis->as_attr is a pointer to an 
			   IGRvector. This vector is the "view vector". It 
			   defines the positive sens of measure.
                           (be carrefull, to obtain an anti clock wise sens
			   in th oxy plane, view vector has to be (0,0,-1))
	NDcompute_node 	 : recompute after a parent change
	modify		 : doesn't allow a syntax modification of the expression
	NDprint	     	 : print via graph_printer to ci
        NDmove_to_root   : transform to a regular expression


\*/


end specification angl_pm;
