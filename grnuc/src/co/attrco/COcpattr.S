class specification COcpattr (1:0) of COtools, COdpb, CEO_GSLOCATE;



#include <fontdef.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIprims.h>
#include "cpattrco.h"


instance COcpattr
{
    IGRulong mask;
};


override form_notification;

message form_init ();

message form_update (IGRuint upd_mask);

override arg_name_to_value;

message list_names ();

end specification COcpattr;
