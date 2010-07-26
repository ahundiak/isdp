class specification COcpparal (1:0) of CEO_LOCATE;



#include "comndef.h"
#include "comn.h"


instance COcpparal
{
    struct GRlc_info original;  /* located object */
    struct GRevent cpevents[3]; /* input events */
    struct GRlc_dynamics lcdyn; /* locate dynamics info */
    struct COcppdy cppinfo;     /* info to pass to dynamics */
};


message store_event (int f, t);

message use_events ();

message store_original ();

message restore_original ();

override dynamics;

message erase_hilite_plane ();

message setup_locate ();

end specification COcpparal;
