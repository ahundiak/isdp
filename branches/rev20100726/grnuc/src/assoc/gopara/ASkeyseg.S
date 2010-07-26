
/*\
ABSTRACT

    This class implements the associative key segement for line string
    The roots of this object are :
     - a linestring
  
     - a coordinate system or a plane (optionnal) . If defined, the keyseg is
       projected in the Oxy plane.

     - a track point (optionnal).

    The key segment has the following characteristics :


    At placement time is taken the nearest sgement from the snap point.

    On a move or modification, the keysegment is maintained on the same vertex

NOTE :
    If user delete or add vertex : not implemented

CHANGE HISTORY:
   
    jla     july-88 : Design date
	
\*/

class specification ASkeyseg (0:1) of ASline;

instance ASkeyseg 
 {
	IGRdouble param;  /* parameter on curve             */
 };

override GRvg;
 override GRnotify;

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


end specification ASkeyseg;
