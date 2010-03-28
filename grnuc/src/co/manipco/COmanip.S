class specification COmanip (1:0) of CEO_GSLOCATE;



#include "comndef.h"
#include "comn.h"


instance COmanip
{
    IGRdouble               tmatrix[16];        /* transformation matrix */
    struct COmnlcdyn        dynargs;            /* locate dynamics info */
    struct GRlc_dynamics    lcdyn;              /* locate dynamics info */
    struct GRevent          mnevents[MNEVENTS]; /* input events */
};


message store_event (int f, t);

message get_matrix ();

message transform ();

message transform_copy ();

message copy_events (int f, t);

message store_value (int i; double x);

message check_planarity (int a, b, c);

message setup_lcdyn (int cmd);

message erase_hilite_plane ();

override dynamics;

override wakeup;

override sleep;

message show_attribute ();

end specification COmanip;
