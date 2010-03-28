class specification COsaveelem (1:0) of COgrpevent;



#include "dpdef.h"
#include "dpmacros.h"


instance COsaveelem
{
    struct gs_members
    {
        IGRint            num_objects;
        struct GRobj_env  *obj_env;
        struct GRmd_env   mod_env;
        GRclassid         clippoly_classid;
    } gs_info;
    struct GRevent  stored_event;
};


message get_select_set ();

message delete_no_connect ();

message put_message_on_queue (char *cmd_key);

message delete_graphics_set_flag (int gs_flag);

override clear_highlight;

message store_event ();

message put_queue ();

end specification COsaveelem;
