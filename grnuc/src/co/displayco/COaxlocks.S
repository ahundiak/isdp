class specification COaxlocks (1:0) of CEO_LOCATE;



#include  "codp.h"


instance COaxlocks
{
    struct  DPvwinfo    	info;
    struct  DPprojs_info    	info1;

    IGRdouble                   pnts[12];
    struct IGRline              boreline;
    IGRpoint                    brlnpt1;
    IGRpoint                    brlnpt2;
};


message dspl_buffrs1 ( long * sts );

message project_point1 ( long * sts );

message dspl_buffrs ( long * sts );

message project_point ( long * sts );

message get_pt11 ( long * sts );

message get_pt22 ( long * sts );

message get_pt1 ( long * sts );

message get_pt2 ( long * sts );

end specification COaxlocks;
