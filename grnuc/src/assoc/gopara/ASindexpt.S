/*
ABSTRACT:
         The ASindexpt class is the class of associatif points depending on
         a barycentric coordinate. 

         This object has 1 to 3 roots:
          - 2  points or,
	  - 1  curve  or,
	  - 1  curve and 2 points.
	  
NOTE:
       The index point is not fully defined by its roots. A barycentric
       coordinate is stored in the instance .



CHANGE HISTORY:

     S.Frezefond  jul 86   : conversion to ems
     S.Frezefond  mar 86   : exec0 design date
     C.Heraud     Oct 86   : Modif. for the assoc.
     jla          Mar 87   : Support implementation
     jla          May 87   : override xform. specific on circle compute.
     jla          Nov 87   : override modify
     jla 	  Sep 89   : transform the function ASindex_bary into a method
			     to just override this method for the ASindptwlim
			     class
*/

class specification ASindexpt (0:1) of ASpoint;


instance ASindexpt 
 {
	IGRdouble bary_fact;      /* barycentric coordinate */
 };

 override GRvg;
 override GRnotify;
override NDcompute_node, NDplace,NDprint, ASpossible_parent;
override ACcompute_node;
override GRxform, GRmodify, GRgetobjinfo; 
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

message ASindex_bary(IGRint case_nb; struct GRmd_env *md_env;
		     struct ret_struct *pardef; struct GRid *parent;
		     IGRdouble *pt_init, *pt_track, *bary, *pt_res);

end specification ASindexpt;
