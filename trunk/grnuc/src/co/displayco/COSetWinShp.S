class specification COSetWinShp (1:0) of CEO_GSLOCATE;


#include "wl.h"
#include "FI.h"


instance COSetWinShp
{
        /* information about the graphic gadget constructed */
        struct GRid window;
        struct GRid gragad_ids[100];
        OM_S_OBJID  window_id;
        IGRchar     gragad_name[200];
        WLuint32    lwin_no;
        IGRint      dep_extents[6];
        IGRint      width;
        IGRint      height;

        WLuint16    lscreen_no;
        IGRint      screen_width;
        IGRint      screen_height;
        IGRint      max_width;
        IGRint      max_height;

        IGRdouble   aspect_ratio;
        IGRint      std_shp_row;
        IGRchar     standard_shape[200];
        IGRchar     std_name[25][25];
        IGRdouble   aspect[25];
        IGRint      switch1;
        Form        form_ptr;
        IGRint      num_gragad_ids;
        IGRint      previous_check;
        IGRint      previous_check_list;
        };


message print_error ( long * sts );

message set_data ( long * sts );

message initialize_instance ( long * sts );

message which_state ( long * sts );

message set_form_defaults ( long * sts );

override form_notification;

message get_selected_window ( IGRint *sts; IGRint single_window );

end specification COSetWinShp;
