/* ###################   APOGEE COMPILED   ################## */
class specification ECmvpls (1:0) of ECelement;

/* Command object types */

#include "FI.h"

#define MOVE_POLES 0
#define MOVE_NODES 1


#define MAX_POLES 20
#define MAX_EVENTS 20
#define VOLUME_LOCATED 0x1
#define FENCE_LOCATED 0x2
#define SOLID_LOCATED 0x4

#define INDIVIDUALLY 13
#define ROW 14
#define RANGE 15
#define VECTOR 18
#define NORMAL_TO_ELEMENT 19

#define EQUALLY 22
#define DIRECTLY 23
#define INVERSELY 24
#define MAG_BORDER 25
#define MAGNITUDE 20
#define SAVE 1

instance ECmvpls
 {
  IGRboolean	savedis;        /* saved polygon display of object */
  IGRboolean    form_displayed; /* Field for indicating whether the status
                                   display form is activated or not */
  IGRboolean    row;            /* If TRUE then row of poles is the active
                                   mode should the pole selection mode
                                   be row. */ 
  IGRboolean    magnitude_gadgets_displayed; /* If the selection of normal
                                                element is true then this
                                                states whether the additional
                                                gadgets are displayed */
  IGRint        pole_selection; /* Can be ROW,INDIVIDUALLY, RANGE */
  IGRint        direction;      /* vector or normal to element */
  IGRint        mag;            /* Amount of movement for each pole */
  IGRint        num_poles;      /* num poles being moved */
  IGRint        from_pole_inx;      /* From pole only applicable if range */
  IGRint        to_pole_inx;        /* only applicable if range */
  IGRpoint      from_point;     /* From point of the movement vector */
  IGRpoint      to_point;       /* To point of the movement vector */
  IGRint        surf_size;      /* size of the amount of memory being
                                   pointed by surf_ptr */
                                   
  IGRint        num_pole_events;/* Number of times the user has picked
                                   either individual poles / row / range. */
  struct IGRbsp_surface *surf_ptr; /* Pointer to the surface geometry */
  variable      IGRint indices[MAX_POLES];
  variable      IGRint num_poles_array[MAX_EVENTS];
  variable      IGRdouble vectors[MAX_POLES*3];
  variable      IGRdouble pts[MAX_POLES*3];
  variable      IGRdouble dists[MAX_POLES];
  struct   GRevent 		locate_event;
  struct   GRlc_stack 		locate_stack;
  struct   GRlc_info 	        surface;
  struct   GRlc_info            normal_element;

  struct GRlc_info save_surf;
  IGRint   u_insert; 
  IGRint   v_insert;
  IGRint   unum;
  IGRint   vnum;
  IGRint   num_pts;
  IGRdouble *u_vals;
  IGRdouble *v_vals;
  IGRdouble *node_pts;
  IGRdouble *weights;
  Form      form1;
 };
 
override execute, init, wakeup,sleep ;

message get_pole_position(struct GRevent *event;IGRint *pole_index;
                          IGRboolean *onpolygon);

message display_polygon(IGRboolean display);

message display_indices(IGRlong from_index; 
                        IGRlong to_index; 
                        IGRboolean draw);

message store_row(IGRboolean row; IGRint index);

message storepoles_in_volume(IGRlong *msg; 
                            IGRint type; 
                            struct GRmd_env *mdenv;
                            struct GRid *volume);


message store_geom(IGRlong *msg);

message add_pole_event(IGRint num_poles);

message add_pole(IGRint num_poles; IGRint *inx);

message display_pole_event(IGRboolean all; IGRboolean display);

message backup_pole_event();

message do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
                IGRdouble value);

override status_disp, 
         delete;

end specification ECmvpls;

