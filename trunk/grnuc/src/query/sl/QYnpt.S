class specification QYnpt (1:0) of CEO_GSLOCATE, COnpt;


#include "de.h"
#include "DIdef.h"
#include "DItypedef.h"


instance QYnpt
{
    char                dir_name [DI_PATH_MAX]	/* directory name	*/;
    struct GRid         ss_id;
    struct GRid         window_id;
    int                 query_state;
    int                 num_query_offsets;
    variable int        query_offsets[20];
};


override form_notification;

message init_query ();

message switch_query_state (int state; int reset);

message add_to_query (int label);

message back_up_query ();

message display_object ( long * sts );

override init;

override wakeup;

override sleep;

override filter;

override store_locate_context;

message store_query ( long * sts );

message send_query ( long * sts );

end specification QYnpt;
