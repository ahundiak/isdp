/*\
ABSTRACT : The ASsrctext is the class of text elements having position defined
           relatively to other elements of the design. The printed text is
	   defined by a IGResintx structure (text string, size, justif ...).

           The possible parents of this object are :

           - a point (optionnal). This point defines the position of the text
	     according to the conventionnal justification pass in the
	     corresponding field of tx_attr.

           - a line or a circle (optionnal). This curve will define the 
	     direction of the text. Depending on the value of the flag pass to
             the place method, text orientation versus curve orientation will
             have
		- same orientation
		- opposit orientation
		- independant orientation. The curve only gives the direction.
		  The orientation on this direction is automaticly chosen to 
		  have a text y axis and a coord syst. y axis
			   in the same alf plane

	   - an optionnal plane or local coordinate system (referential) .
             In automatic mode, this root is used to decide if the text has to
	     be writen in the same direction of the support or in the opposit 
             one. If no support, the text is writen in the x axis direction of
	     the plane. 
             If no plane defined, the default plane is the plane Oxy. 


CHANGE HISTORY :
        jla       21-sep-87 : design
\*/

class specification ASsrctext (0:1) of GRtext,ASnode;

instance  ASsrctext
  {
    IGRdouble trans[3]; /* position of text in LOCAL COORDINATE from origine  */

    IGRchar flag;
		 /* 00000001 asked : text and support same orientation        */
		 /* 00000010 asked : text and support reverse orientation     */
		 /* 00000000 asked : text orientation is chosen to have text  */
                 /*                  y axe in same orientation as coord. syst.*/

		 /* 00000000 asked : when text orientation versus curve       */
		 /*                  changes only change x justif (default)   */
		 /* 00100000 asked : changes x and y justif                   */
		 /* 01000000 asked : changes y justif only (NOT IMPLEMENTED)  */
		 /* 01100000 asked : doesn't change justif (NOT IMPLEMENTED)  */
		 

                 /* 00000100 actual : same orientation as support             */
		 /* 00001000 actual : reverse direction from support          */
		 /* 00010000 actual : text versus line orientation has        */
		 /*                   been changed since placement            */
  };

  override GRvg;
  override GRtext;
override GRnotify;

message ASevaluate(IGRint num; struct GRid *list; IGRint *type;
		   struct GRmd_env *md_env);

/* ABSTRACT
   Message definition to be overriden by sub class which want to evaluate the 
   text string relative to other components of the design.
   These sub class have to override the message, evaluate the text string and
   store it using the function call:status = AStext_store(text,stren(text));

   ARGUMENTS
   IN num   : number of roots
   IN list  : array of roots
   IN type  : geometric type of each root, according to declared type in
	      parametric.h
   IN md_env : module env information
*/


override NDplace,NDcompute_node,NDgive_structure,NDprint,NDprint_root;
override ACcompute_node;

override GRxform;
override GRchgtextattr, GRchgtxstring, GRgettxattr, 
	 GRtxfillbuf, GRfield_inquire, GRdpemptytext, GRreplace_text, 
         GRchange_flag, GRpostabsg;


/*\
MOTIVATION :
  NDplace : assoc_list->as_attr is a pointer to double. In the corresponding array
	  - the first value is "flag" described in class specification. Only
            asked bits have to be defined. A 0 value is default.

          - the 3 following are the vector describing offset from origine point.

  NDcompute_node :   When a root of the element has changed, evaluate the
          new text string (message ASevaluate) and recompute position of text.

  NDgive_structure : Return le local bounded sytem definition corresponding to the
	  text

  GRxform : Allows a move of the text, changing the xtrans value

  ACmap_to_visible map_from_visible : save or take instance from macro header

  NDprint, NDprint_root : for the graph printer.

  ACcompute_node : recompute when the object belongs to a symbol macro.

  others :just redirect the message to the graphic object and update dependency
	  if necessary
\*/

end specification ASsrctext;
