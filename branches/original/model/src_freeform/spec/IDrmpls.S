class specification IDrmpls (1:0) of IDdisp_poly, IDundo, ECelement;

/* Command object types */

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

instance IDrmpls
 {
	/* alex - added this to save event point	*/
	IGRpoint	del_pole;

  IGRboolean    row;            /* If TRUE then row of poles is the active
                                   mode should the pole selection mode
                                   be row. */ 
  IGRint        num_poles;      /* num poles being moved */
  IGRint        del_pole_index; /* pole selected by user	*/
  IGRint        from_pole_inx;      /* From pole only applicable if range */
  IGRint        surf_size;      /* size of the amount of memory being
                                   pointed by surf_ptr */
                                   
  IGRint        num_pole_events;/* Number of times the user has picked
                                   either individual poles / row / range. */
  struct IGRbsp_surface *surf_ptr; /* Pointer to the surface geometry */

  variable      IGRint indices[MAX_POLES];
  variable      IGRint num_poles_array[MAX_EVENTS];
  struct   GRevent 		locate_event;
  struct   GRlc_stack 		locate_stack;
  struct   GRlc_info 	        surface;

  struct GRlc_info save_surf;
 };
 
override execute, init, wakeup,sleep ;

message hilite_bez_patch(IGRboolean draw);

message get_pole_position(struct GRevent *event;IGRint *pole_index;
                          IGRboolean *onpolygon);

message display_polygon(IGRboolean display; IGRboolean update_display);

message display_indices(IGRlong from_index; 
                        IGRlong to_index; 
                        IGRboolean draw);

message IDcreate_line_string(IGRboolean draw);

message store_row(IGRboolean row; IGRint index);

message storepoles_in_volume(IGRlong *msg; 
                            IGRint type; 
                            struct GRmd_env *mdenv;
                            struct GRid *volume);


message store_geom(IGRlong *msg);
message init_variables();
message change_surface_by_deleting_row();

message add_pole_event(IGRint num_poles);

message add_pole(IGRint num_poles; IGRint *inx);

message display_pole_event(IGRboolean display);

message backup_pole_event();

override delete;

end specification IDrmpls;

