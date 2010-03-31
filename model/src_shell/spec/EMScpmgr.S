/* ###################   APOGEE COMPILED   ################## */
class specification EMScpmgr (1:2) of EMSobjmgr;

instance EMScpmgr
  {
  IGRint num_entries;
  variable GRobjid cptbl[][2];
  };

override EMinit, EMwakeup, EMsleep, EMvalidate, debug, delete;

message EMputentry (IGRlong *msg; IGRushort option;
                    IGRint num_elems; GRobjid key[], cp[]);

message EMgetentry (IGRlong *msg; IGRushort option;
                    IGRint num_elems; GRobjid key[], cp[]);

message EMdelentry (IGRlong *msg; IGRushort option;
                    IGRint num_elems; GRobjid key[], cp[]);

end specification EMScpmgr;
