/*
ABSTRACT:
         The ASindptwlim class is the class of associatif points depending on
         a barycentric coordinate with limits. 

         This object has 1 to 3 roots:
          - 2  points or,
	  - 1  curve  or,
	  - 1  curve and 2 points.
	  
NOTE:
       The index point is not fully defined by its roots. A barycentric
       coordinate is stored in the instance .



CHANGE HISTORY:

     momo may 89  : design date
     jla  Sep 89  : make it sub class of ASindexpt

*/

class specification ASindptwlim (0:1) of ASindexpt;


override GRvg;
 override GRnotify;
override ASindex_bary,NDprint;      /* class specific			     */

/*\
MOTIVATION
	NDprint	     	  : print via graph_printer to ci.
\*/

end specification ASindptwlim;
