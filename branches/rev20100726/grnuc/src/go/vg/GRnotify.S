/* 
  ABSTRACT

  The GRnotify class is a subclass of GRgraphics. Objects
  Subclassed under this class will notify the notification
  listeners about what methods operate on the object.  The
  notification listeners are objects subclassed under
  GRlistener  and are connected to the graphics object by
  the channel, "notification," defined on GRnotify class.


  HISTORY
	
  MAS 09/03/87 : Creation date
*/

class specification GRnotify (1:1) of GRgraphics;

#include <stdio.h>

/*------------------ INSTANCE DATA SECTION -------------------*/

instance GRnotify
{
    channel {(many_to_many,initial=1,increment=1)} notification;
};
 
taggable;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message GRntfyconn
(
  IGRlong *msg;
  struct GRid *listeners_id;
  OM_S_CHANSELECT *listeners_chan;
  IGRint *listeners_index;
  IGRboolean *make_tagged_connect;
  GRspacenum *tagged_os;
);

message GRntfydisconn
(
  IGRlong *msg;
  struct GRid *listeners_id;
  OM_S_CHANSELECT *listeners_chan;
);

message GRmksource
(
  IGRlong *msg;
  struct GRid *context;
  GRspacenum target_os;
  struct GRid *source;
  IGRint option;
);

reject 
  GRmksource;

override
  GRprint,
  GRread;

#endif

end specification GRnotify;
