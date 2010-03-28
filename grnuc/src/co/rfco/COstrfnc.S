class specification COstrfnc (1:0) of COgrpevent;



#include "igrtypedef.h"
#include "dp.h"


instance COstrfnc
{
    IGRmatrix	matrix;
    IGRshort mx_type;
    struct GRevent event_array[2];
};


override construct_fence_set;

override build_locate_criteria;

message connect_fence_to_inside_channel ();

message store_event (int f, t);

message get_matrix ();

message fix_up_fence (int props);

message draw_objects (enum GRdpmode mode);

message transform ();

message stretch ();

message copy_event (int f, t);

message generate_new_prism ();

end specification COstrfnc;
