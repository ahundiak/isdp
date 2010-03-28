/* 
  ABSTRACT

  The GRconnector class is a subclass of GRgraphics. The channel
  declared at this class is to be used for objects which
  want to own graphics.  Objects subclassed under this class 
  which want to use this channel will be allowed to connect 
  only to objects that are subclasses of GRxxxx.


  HISTORY
	
  MAS 09/03/87 : Creation date
*/

class specification GRconnector (1:1) of GRgraphics;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance GRconnector
{
    channel {(rel_ordered,many_to_many,initial=1,increment=1)
		GRcmpowner.to_components;} to_owners;
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS
 
message GRrigidconn
(
  IGRlong *msg;
  struct GRid *owners_id;
  IGRlong *owners_index;
);

message GRflexconn
(
  IGRlong *msg;
  IGRlong *flag;
  struct GRid *owners_id;
  IGRlong *owners_index;
  IGRlong *graphics_index;
);

message GRdisconn
(
  IGRlong *msg;
  struct GRid *owners_id;
);

override 
  GRprint,
  GRread;

#endif
 
end specification GRconnector;
