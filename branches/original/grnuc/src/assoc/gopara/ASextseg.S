
class specification ASextseg (0:1) of ASmodlin;


/*\
   ABSTRACT : 
	     ASextseg is the class used to extend associatively line to a 
	     specified point.

	     The possible roos of this object are:
		- the line to extend,
		- point to which the line is to be extended
	        - track point (optionnal). At placement time the start point or
		  end point of the line is extended. On a recompute the start or
		  end point is extended again. If a track point is defined, the
		  orientation of the line to know which one is the start and
		  which one is the end, is defined by the extend point --> track
		  point vector.

   NOTE :     This class may desappear in the near future. Therefore, your are
	      encourage to use the ASmodbsp class which performs the same 
	      function on general b_spline.

   HISTORY :
	jla     21-jan-87 : Design date
\*/

 override GRvg;
 override NDplace;

/*\ OVERRIDE MOTIVATION

         NDplace : initializes specific instances inherit from ASmodlin to 
	 	   extend (typ_mod par_mod) and call ther ASmodlin.place
		   method with respect to message. The as_attr argument is a
		   pointer to an IGRpoint. This  point defines the end point
		   to extend (nearest).
\*/


end specification ASextseg;
