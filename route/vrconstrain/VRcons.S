
/* 
    ABSTRACT

Constrain solver class

*/

class specification VRcons (0:0) of NDnode; 

#include "vrconsdef.h"
#include "vrcons.h"

instance VRcons
 {
  variable struct GRid conc[10];
  int nb_conc;

  variable struct GRid plane[10];
  variable short plane_state[10];
  variable int unknown_index[10];
  variable int plane_vectoriel[10];
  variable double plane_eq[40];
  variable int iteration[40];
  int nb_plane;

/* dimension for resolution with 40 unknown 20 inegalities */

#define NB_UNK  100
#define NB_CONS 30

  variable double matrix[(NB_CONS+1)*NB_UNK];
  variable double smem[2*NB_CONS];
  int nb_unknown;
  int max_unknown;
  int nb_equation;
  int max_equation;

  int solver_state;
  int iteration_number;
 };



override NDget_virtual_objects,
	 NDget_objects,
	 NDcompute_node,
	 NDcopy,
	 NDdelete,
	 NDsleep;




/* ABSTRACT :

get_virtual_objects : Returns the constrain solver as parent of the constrains
		      it solves

get_objects	    : Returns no roots no dependent

compute_node	    : Resolve the constrain system

copy		    : does not copy

delete		    : does not delete

sleep		    : does not go to file 

*/


message VRinit_solver();

/* ABSTRACT :
  initialization when constructed 
*/

message VRset_solver_state(int state);
message VRget_solver_state(int *state);

/* ABSTRACT :
  Set solver state to one of the follwing value :
  - VR_SOLVER_INACTIVE  : Solver is inactive 
  - VR_SOLVER_INITIAL   : Solver is active and waiting for the first constrain
			  to take into account
  - VR_SOLVER_FIRST     : First resolution after a move
  - VR_SOLVER_PROPAGATE : Triing to solve the constrain system is propagating
			  modification to other elements
  - VR_SOLVER_CONVERGE  : Propagation is now impossible, try to solve constraint
			  by modifiing the request.
*/

message VRinit_constrain();

/* ABSTRACT :
 Initialize the list of constraint that must solve the constrain solver
*/
 
message VRadd_constrain(struct GRid *obj);


/* ABSTRACT :

add an object defining constraint in the list of constraint to solve

*/


message VRstore_plane(struct GRid *obj; int *index; int obj_state;
	 	      struct GRmd_env *md_env);

/* ABSTRACT :
Store a constrained planed and return its index

*/

message VRverify_af_constrain(int cons_type;
                             double *cons_value; int nb_value;
                             int *obj_index;int nb_obj;
                             int *verify;
			     struct GRmd_env *md_env);

/* ABSTRACT :
   Check if the affine constraint is verified
   and build corresponding system of equations
*/

message VRsolve_af_constrain(int *suc);

message VRexpand_matrix(int new_unknown,new_equation);

message VRcompress_matrix();

message VRalloc_plane(int plane_size);

end specification VRcons;
