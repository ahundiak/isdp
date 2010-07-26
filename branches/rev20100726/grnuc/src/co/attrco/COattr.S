class specification COattr (1:0) of COtools, COdpb, CEO_LOCATE;



#include "attrco.h"




override form_notification;

message set_gadgets ();

override get;

override put;

message toggle_lock ( long * sts );

end specification COattr;
