class specification COevgen (1:0) of CEO_LOCATE;



#define MAXEVENTS    4


instance COevgen
{
    struct GRevent      events[MAXEVENTS];    /* event pushed on queue */
};


message use_events ();

message store_event (int f, t);

message push_event (int n);

message display_coords (int n);

message move_angle_to_event (int n);

message setup_select_handler ();

message display_segment (int object_index;
                        enum GRdpmode element_mode, extension_mode);

message erase_hilite_plane ();

end specification COevgen;
