#ifndef acrepmacros_include
#define acrepmacros_include


#omdef ac$get_def_NVrep(prep,esymb)
ACget_def_NVrep(prep,esymb)
#endomdef

#omdef ac$get_def_rep(prep,esymb)
ACget_def_NVrep(prep,esymb)
#endomdef

/* ABSTRACT

returns the active representation

  ARGUMENTS

unsigned *char prep       OUT : returned representation 
struct GRsymbology *esymb OUT : error symbology  

*/

#omdef ac$compute_rep_value(initial_rep= AC_NO_REP,
			    p_root = NULL,
			    nb_root = 0,
			    resulting_rep)

ACcompute_rep_value((initial_rep),(p_root),(nb_root),(resulting_rep)) 
#endomdef

/* ABSTRACT
Given a list of parents this macro computes the representation values
fo the dependent entity

   ARGUMENTS

   private for now ...


*/


#omdef ac$get_rep_col(col)
ACcreate_possible_rep_col(col)
#endomdef

/* ABSTRACT
This macro retrieves or creates in the current module a collection with the 
possible representation understand at VDS level. 
2D_representation
3D_representation
envelope 

 ARGUMENTS

struct GRid *coll OUT : collection with the possible representation

*/

#omdef ac$add_representation(name,value)
ACadd_representation(name,value)
#endomdef

/* ABSTRACT
This macro adds a representation to the collection of possible representation.

  ARGUMENTS

char *name IN : name given to the representation
int  value IN : its value

*/
   
#endif
