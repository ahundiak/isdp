/*
  ABSTRACT

  The abstract class NDnode is the parent class for all the elements with
  associations built into the design as constraints.

  The NDnode class and the graph manager primitives acting on it (describde in
  the file NDmacros.h) allow the definition of a directed graph of dependency
  with the following assumptions : 
     
  - An element depends upon root and can have other elements depending
    upon him. It can't act on the elements it is depending upon, and it's
    behaviour can't be modified by elements depending upon it.

  - The only information an element will ask to the elements it is depending
    upon is their geometry or numerical value. Never mind how this value
    or geometry has been obtained.

  - All the components of the graph are supposed to understand a set of
    message that will define their behaviour on generic operation 
    (compute, give_structure, display, copy, delete). This message are
    declared in the NDnode class.

  What to override?

  - NDcompute_node to define the behaviour of the element

  - NDcopy, NDdelete if om$construct_and_copy, Root.delete are 
    not enough for the element

  and optionally,

  - NDprint and NDprint_root  : print the element to PPL file

  - NDget_state and NDchange_state: if the default 0 state
                                    is not enough

  - NDgive_structure  :
    
  - NDgive_value      : If the element could return a numeric value

  - ASreturn_go       : If the element is a graphic object or could
                        return the graphic object it ownes (or is 
                        connected to usin notify channel)


  HISTORY

  H.B.     mars 86  initial design
  JLA - DP dec  87  redesign
  JLA      June 88  implementation without instances 
  JLA      June 91  2.0 release
  WBC      June 93  Added the message NDparent_rf_detached.
*/

class specification NDnode (0:0) of Root;

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "msdef.h"
#include "parametric.h"
#include "nd.h"
#include "growner.h"
#include "macro.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message NDget_objects
(
  int type;
  struct GRid *list;
  int size;
  struct GRid **buffer;
  int ifrom;
  int ito;
  int *count;
);

message NDget_virtual_objects
(
  int type;
  struct GRid *list;
  int size;
  struct GRid **buffer;
  int ifrom;
  int ito;
  int *count;
  int *virt_count;
);

message NDconnect_graph
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *fr_env;
  struct GRmd_env *to_env;
  struct NDcp_list *copied_element;
  int copied_size;
  int nb_root;
  int *root_index;
  int my_index;
);

message NDconnect
(
  int nb_root;
  struct GRid *root;
  struct GRid original;
  IGRint type;
);

message NDdisconnect
(
  int nb_root;
  struct GRid *root;
);

message NDchange_connect
(
  int nb_change;
  struct GRid *old;
  struct GRid *new;
);

message NDupdate
(
  int *msg;
  int cn_type;
  int count;
  struct GRid *parents;
  int * parent_state;
  struct GRid *context;
  struct GRid *new_objid;
  struct GRmd_env *md_env;
);

message NDcompute_node
(
  IGRlong *msg;
  IGRint cn_type;
  IGRint count;
  struct GRid list [];
  struct GRmd_env *md_env;
);

message NDs_compute_node
(
  IGRlong *msg;
  IGRint cn_type;
  struct GRmd_env *md_env;
);

message NDchange_node
(
  struct GRmd_env *obsolete_argument;
);

message NDgive_structure
(
  IGRlong *msg;
  struct ret_struct *str;
  struct GRmd_env *md_env;
);

message NDprint
(
  struct GRmd_env *md_env;
  FILE *stream;
);

message NDprint_root
(
  struct GRmd_env *md_env;
  FILE *stream;
);

message NDdelete
(
  struct GRmd_env *md_env;
);

message NDplace
(
  struct GRas *assoc_list;
  struct GRmd_env *md_env;
  char *go_cnst_lis;
);

message NDget_state
(
  IGRchar *n_state;
);

message NDchg_state
(
  IGRchar mask;
  IGRchar n_state;
);
  
message NDparent_deleted
(
  IGRlong *msg;
  IGRint count_deleted;
  struct GRid list_deleted [];
  struct GRid *new_obj;
  struct GRmd_env *md_env;
);

message NDrm_assoc
(
  long *msg;
  struct GRid *new_object;
  struct GRmd_env *md_env;
);

message NDmove_to_root
(
  IGRlong *msg;
  struct GRid *src_grid;
  struct GRmd_env *md_env;
);

message NDchildren_deleted
(
  IGRlong *msg;
  IGRint count_deleted;
  struct GRid list_deleted [];
  struct GRid *new_obj;
  struct GRmd_env *md_env;
);

message NDdisplay
(
  IGRint obsolet;
  enum GRdpmode mode;
  struct GRmd_env *md_env;
);

message NDselect_copy
(
  long *msg;
  int select_type;
  struct GRid *selected_obj;
  int *info;
  int selected_size;
  int *selected_nb;
);

message NDcopy_graph
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *fr_env;
  struct GRmd_env *to_env;
  struct NDcp_list *copied_element;
  int copied_size;
  int my_index;
);
 
message NDcopy
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *fr_env;
  struct GRmd_env *to_env;
  struct GRid *newobjid;
);

message NDnotify_connect
(
  struct GRid new_connected;
);

message NDnotify_disconnect
(
  struct GRid previous_connected;
);

message NDpossible_parent
(
  IGRint ifrom;
  IGRint ito;
  IGRint *geom_code;
  IGRint *option_code;
  IGRint *nb_tot;
);
		 
message NDcopy_to_tmp_root
(
  long *msg;
  int cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
);

message NDmove_to_tmp_clone
(
  long *msg;
  struct GRid *clone;
);

message NDcopy_to_root
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
);

message NDmake_source
(
  IGRlong *msg;
  struct GRid *located_obj;
  struct GRid *context;
  char *path;
  GRspacenum as_osnum;
  struct GRid *as;
);
  
message ASreturn_go
(
  struct GRid *go;
  IGRshort *mat_type;
  IGRdouble *matrix;
);

message NDsleep
(
  struct GRmd_env *md_env;
);

message NDattach_to_cs
(
  IGRlong *msg;
  struct GRid cs_grid;
  struct GRid contents_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
);

message NDdetach_from_cs
(
  IGRlong *msg;
  struct GRid cs_grid;
  struct GRid contents_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
);

message NDattach_to_track_pt
(
  IGRlong *msg;
  struct GRid pt_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
);

message NDdetach_from_track_pt
(
  IGRlong *msg;
  struct GRid pt_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
);

message NDget_parent_type
(
  long *msg;
  int *type;
  char *info;
);

message NDctl_parent_type
(
  long *msg;
  int type;
  char *info;
);

message NDdrawing_copy_geom
(
  struct GRid *selected_elements;
  int nb_elements;
  struct GRid **drawing_elements;
  int *nb_drawing_elem;
  double *vector;
  double *point;
  int *level;
  struct IGRlbsys *lbsys;
  struct GRmd_env *from_env;
  struct GRmd_env *to_env;
);

message NDdrawing_copy_attr
(
  struct myfeet *attr_name;
  int nb_attr;
  struct GRid *drawing_attr;
  struct GRmd_env *from_env;
  struct GRmd_env *to_env;
);

message NDparent_rf_detached
(
  IGRlong *msg;
  struct GRid *parent_grid;
  struct GRmd_env *md_env;
  struct GRid *new_obj;
);

reject  
  NDget_objects,
  NDconnect,
  NDdisconnect,
  NDchange_connect,
  NDcompute_node,
  NDgive_structure,
  NDplace,
  NDdisplay,
  NDprint,
  NDprint_root,
  ASreturn_go,
  NDattach_to_cs,
  NDdetach_from_cs,
  NDattach_to_track_pt,
  NDdetach_from_track_pt,
  NDmove_to_tmp_clone,
  NDparent_rf_detached;

#endif

end specification NDnode;
