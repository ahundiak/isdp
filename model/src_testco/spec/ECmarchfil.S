/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

  This spec file is for command Round manually
  This is a marching fillet command with rolling ball technique to do the 
  following:

  1. Place a fillet surface between 2 surfaces
  2. Place a rolling ball (spherical patch) between 3 surfaces
  3. Trim a previously placed fillet against 
     a. tangent surfaces or 
     b. intersecting surfaces


  NOTES

  The above 4 option are presented on a form.  6 more options are also 
  presented on the form to

  a) change the marching direction
  b) to UNDO the last operation
  c) to start a new marching fillet chain
  d) extend current fillet
  e) set fillet extension for new fillets
  d) add fillets to a list of fillets

  A running stack of all objects (fillets & sph patches) is maintained in
  VLA eles, and a a running stack of copies of all objects is maintained 
  in VLA copies.  

  Since a user can change march direction, a sepatate VLA march_stack should be
  used to track the march using some indexes This data structure will be handy
  to keep track of 'UNDO' beyond previous 'change direction'.

  Total elements in the chain are 0 to num_nodes-1.  Current element (march
  front) is eles[march_front].


  HISTORY

    pac  :  11/18/92  :  Creation
    scw  :  08/14/94  :  clarified sleep method
*/
   
class specification ECmarchfil (1:1) of ECelements;

#include "ECmf.h"

instance ECmarchfil
  {
  IGRdouble radius;
  IGRdouble fil_extend;
  IGRboolean material_side;
  char *form_ptr;
  IGRint form_option;
  IGRboolean new_chain;
  IGRboolean disp_trim;
  IGRint curr_ele_type;    /* useful when marching from curr ele */
  IGRdouble march_edge;    /* V par of march edge */
  IGRpoint march_arrow[2]; /* base and tip in XYZ space */
  IGRint march_front;      /* index into ele_stack */
  IGRint num_nodes;
  variable struct ele_stack eles[ELEMS_ARRAY_INCR];  
  variable struct ele_stack copies[ELEMS_ARRAY_INCR];  
  IGRushort fil_opts;
  IGRint    fil_num_segs;
  IGRdouble *fil_str_segs;
  IGRdouble *fil_end_segs;
  struct GRid *fil_grid;
  struct IGRbsp_surface *fil_surf;
  IGRushort fil_degen_opt;
  struct GRid fil_base_surfs[2];
  };

override init, execute, wakeup, super_cmd.sleep, delete, get_locate_criteria, proc_locobj;

/*
 * message set_new_locate_criteria(IGRlong *msg; char *class);
 * as the name suggests, set a new locate criterion.
 * see ECelementsi.I for details
 */

message set_new_locate_criteria(IGRlong *msg; char *class);

/*
 * message push_node(IGRlong *msg; struct ele_stack *ele_id);
 * save newly created object (fillet OR sph. patch) & update counter on # of 
 * objects in the ele stack
 * input : pointer to ele.  
 * output: new object & copy are saved in the instance data VLA ele_stack
 * elements of instance data affected are march_front, num_nodes, eles, copies
 */

message push_node(IGRlong *msg; struct ele_stack *ele_id);


/* 
 * message pop_node(IGRlong *msg);
 * send this message to undo last operation
 * this message will update list of fillets/sph patches in the instance data 
 * elements of instance data affected are march_front, num_nodes, eles, copies
 */

message pop_node(IGRlong *msg);


/*
 * message disp_march_dir(IGRlong *msg; IGRushort opts);
 * display march direction.  currently we hilite marching edge for a fillet
 * and all 3 edges for a sph. patch.  see method for documentation on opts
 * Also update march_arrow base & tip in the instance data
 */

message disp_march_dir(IGRlong *msg; IGRushort opts);

/*
 * set form state in  the instance data as to what form button was poked
 * read the method (obvs. code) for details
 */

message do_form_notification(IGRint form_label, gad_label; IGRdouble value; 
                             char *form_ptr);

end specification ECmarchfil;
