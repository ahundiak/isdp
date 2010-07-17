
/* 

    ABSTRACT

This message defines the protocol that must implement an objet that wants
to define constrain on its parents

*/

class specification VRconc (0:0) of NDnode; 

#include "vrcons.h"
#include "vrconsdef.h"


message VRget_nb_constrain(int *nb_cons);

/*
ABSTRACT :

This message returns the number of constrains that the object defines

ARGUMENTS :

int nb_cons O : number of constrains
*/


message VRget_constrain(IGRlong *suc; int i; int *cons_type;
	      struct GRid *cons_obj; int *nb_obj; int size_obj;
	      double *cons_val; int *nb_val; int size_val);

/*
ABSTRACT :

This message returns the definition of the ith constrain defined by the object
with 0 <= i < nb_constrain (define above).

The constrained object must be
- on parents of the objects (planes defining a component)
- on the object itself (fixed plane for example) 


ARGUMENTS

int *suc        O : completion code 

int i	        I : index of the queried constraint

int *cons_type O : Type of constrain as defined in VRconsdef.h
                   Possible values are
		   VRCONS_PARA
		   VRCONS_ANGL
		   VRCONS_1PT
		   VRCONS_2PT
		   VRCONS_FIX

GRid *obj O       : GRids of the constrained objects. These objects must be 
		    parents of the VRcons object.
                    NB : could be modified to int *index1: index of
			 the constrained objects on the parent channel.

int *nb_obj O     : number of objects constrained

int size_obj I    : size of obj

double *cons_val O : values  associated to the constrain

int *nb_val O     : number of values associated to the constrain.

int size_val I    : size of the array cons_values. If less than nb_values
                   the information returned by cons_values is truncated.
*/


override NDget_virtual_objects, NDcompute_node, NDplace ;


/* ABSTRACT :

Returns the constrain solver as virtual dependent of the constrained object

*/

reject VRget_nb_constrain, VRget_constrain;

            

end specification VRconc;
