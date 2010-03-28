class implementation ASnode;

#include "elmt.h"
#include "hcode.h"
#include "graph.h"
#include "nddef.h"
#include "ndmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"

/* the compute_node of obj aborts. I change the state of this object and its
   dependency to make them not recomputed 
   This function can be called during a broadcast 
*/

NDdegraded_dep(obj) 
struct GRid obj;
 {
  struct graph my_graph;
  extern IGRboolean ASbroadcast_in_progress;
  IGRboolean save_br;
  int nb_obj,i_obj;
  struct GRid *list;
  IGRlong status;
  
/* get sub graph */

  NDinit_graph(&my_graph,DEFAULT_MODULO,DEFAULT_SIZE,DEFAULT_SIZE);
  nd$get_graph(p_root = &obj,
	       nb_root = 1,
	       p_graph = &my_graph);
  save_br = ASbroadcast_in_progress;
  ASbroadcast_in_progress = FALSE;

  nd$get_list_in_graph(acc_type = ND_ROOT | ND_BODY ,
		       p_count = &nb_obj,
		       p_graph = &my_graph);

  if(nb_obj > 1)
    {
     list = (struct GRid *) om$malloc(size = nb_obj*sizeof(struct GRid));
     if(list == NULL) return OM_W_ABORT;

     nd$get_list_in_graph(acc_type = ND_ROOT | ND_BODY ,
		          list = list,
		          size = nb_obj,
		          p_graph = &my_graph);
    }
  else
    {
     list = &obj; 
    }

/* Set the state of the object to degraded and remove its name */
  
  for (i_obj = 0 ; i_obj<nb_obj ; i_obj++)
   {
    status = om$send(msg = message NDnode.NDchg_state(ND_DEGRADED,ND_DEGRADED),
		     senderid = NULL_OBJID,
                     targetid = list[i_obj].objid,
	             targetos = list[i_obj].osnum);
    as$status();
                    
    di$rm_objid( objid = list[i_obj].objid,
	         osnum = list[i_obj].osnum);
   }
  ASbroadcast_in_progress  = save_br;
  NDremove_graph(&my_graph);
  if(nb_obj != 1) om$dealloc(ptr = list);
  return OM_S_SUCCESS;
  }

end implementation ASnode; 
