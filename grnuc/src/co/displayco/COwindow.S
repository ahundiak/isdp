class specification COwindow (1:0) of CEO_LOCATE;



#include      "dpfile.h"


instance COwindow
{
        IGRdouble    pts[9];
	IGRint       num_id;
	struct GRid  ggid[MAX_WINDOW];
        struct GRid  source_id;
        struct GRevent event11;
        IGRdouble    rotation[4][4];
	IGRchar      long_name[256];
};


message get_graphic_gadget ( IGRint flag ; IGRint num_wnds ; IGRint err_flg);

message get_dt_pt (IGRint index);

message init_kyin ( long * sts );

message get_type_view (IGRint *sts;IGRint use_default);

message get_wndid ( long * sts );

message copy_window ( long * sts );

end specification COwindow;
