/* ###################   APOGEE COMPILED   ################## */

/*
ABSTRACT

    This class implements the associative key curve for composite curve
    The roots of this object are :
     - a composite curve
  
     - a coordinate system or a plane. The keycurve is projected in the Oxy
       plane. ( optional )

     - an optional  point. ( track point )


CHANGE HISTORY:

        momo  12-juin-89  : Design date
   
*/

class specification ASkeycurve (0:1) of GRbcsubbc,ASbspline;

instance ASkeycurve
{
  IGRdouble param;  /* parameter on curve             */
};


override GRvg;

override  NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
MOTIVATION
  NDplace            - placement. as_attr is a pointer on a IGRpoint. This 
		       "snap point" allows the selection of the nearest
		       key segment.
  NDcompute_node     - maintain the key segment on vertex when curve is modified
  NDprint            - edit to ci file
  GRgetobjinfo       - adequate message field on locate
  ASpossible_parent  - return possible roots and type
\*/


end specification ASkeycurve;
