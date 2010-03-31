/* ###################   APOGEE COMPILED   ################## */
/*
ABSTRACT:
         The ASindexcv class is the class of associatif curve on a surface 

         This object can have 

         1 root : a surface
           The curve on surface is not fully defined by its roots. A set of
           (u,v) coordinate value is stored in its instance.

         2 roots : a surface a curve
           The curve on the surface is the projection of the parent curve 
           perpendicular to the surface

         3 roots : a surface a curve and a line
           The curve in the surface is the projection of the parent curve
           in the direction defined by the line.

         When the curve on surface has 2 or 3 parents its internal instance
         data are not used.


	  
NOTE:



CHANGE HISTORY:

     jla 	  Dec 89   : Design date
     alc	  Jun 92   : Add ASget_uvwdef() method
*/

class specification ASindexcv (0:1) of ASbspline;

struct pole_def
  { double u;
    double v;
    double w;
    int leaf_index;   /* for composite surface (not used) */
  };

instance ASindexcv 
 {
	variable struct pole_def  poles[0];      /* u-v-w value */
 };

override GRvg;
override NDcompute_node, NDplace;
override ACcompute_node,ACmap_from_visible;
override GRxform, GRmodify, GRgetobjinfo; 


message ASget_uvwdef(IGRdouble *uvw_list ; IGRint size ; IGRint *count) ;
/*
	ABSTRACT :
		This method allows to get the list of (u,v,w) triplets
	  	stored in the object instances. 

	ARGUMENTS :
		O	*uvw_list (or NULL) 	buffer allocated by the caller
		I	size      (or 0)	buffer size in triplets
		O	*count			number of (u,v,w) triplet read

	USAGE :
		This method should be called twice :
	1) to get the number of (u,v,w) triplets stored in the object instances,
	   (e.g. ASget_uvwdef(NULL, 0, &size)), in order to allocate memory
	   before the next step.
	2) to retrieve the list of (u,v,w) triplets, (e.g. 
	   ASget_uvwdef(uvw_list, size, &count)).
 
	NOTES :

		For each pole of the projected curve on the surface, we 
	   associate first a vertex which is the pole itself (divided by its 
	   weight if the curve is a rational one), and then we compute a
	   triplet (u, v, w), as follows :
	   - u and v are the coordinates of the vertex in the parametric 
		  space of the surface,
	   - w is the minimum distance between the vertex and the surface.
*/


/*
MOTIVATION
    Specific behaviour for
	NDplace        	  : placement. The asso_lis->as_attr is a pointer on
                            a double value -> bary_fact.
	NDcompute_node 	  : recompute after a root has changed.
	NDprint	     	  : print via graph_printer to ci.
	GRgetobjinfo 	  : UI_status when locate.
	ASpossible_parent : return possible roots.
        GRxform,GRmodify  : allow a move of the index point acting on the 
			    bary_fact value.
	ACcompute_node	  : Recompute when the object belongs to a "symbol 
			    macro".
        ACmap_(from/to)_visible: Save or restore the barycentric coordinate from
			    macro header when indexpoint is used in a 
			    "symbol macro".
*/

end specification ASindexcv;
