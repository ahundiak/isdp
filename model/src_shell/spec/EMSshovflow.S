/* ###################   APOGEE COMPILED   ################## */
/*
  ABSTRACT

    This class represents the objects that contain the object-ids of the
    objects that have overflowed out of the shell manager. They house
    those shells that can temporarily no longer be used since they have
    entered a binding relationship. Before the object-space is saved,
    a cleanup message is sent to it. The table is scanned for any object-id
    that may no longer be valid or represents an object that is no longer
    in a binding relationship. Such objects are removed from the table
    and a Root.delete sent to them.

  HISTORY

    SS  :  09/15/88  :  Creation
*/

class specification EMSshovflow (1:1) of EMSshobjmgr;

instance EMSshovflow
  {
  /*
   * Unique constant identifier (defined in the file containing the validator
   * functions - EMshvalid.I), identifying the function that should be used
   * to validate the object stored in this object.
   */

  IGRint vfunc_identifier;

  /*
   * Channel to connect to the primary shell-manager for
   * which this object is the overflow store. A different
   * channel is used to avoid confusion. The channel "to_overflow"
   * is never used by this object and could have been rejected
   * if that was possible.
   */

  channel {(many_to_one)} to_shobjmgr;
  };

override EMSobjmgr;

override EMsleep, EMwakeup, EMputovflow, debug;

reject EMinit;

message EMovfinit (IGRlong *msg; GRobjid shobjmgr;
                   IGRboolean (*vfunc)()); 

message EMgetvfuncident (IGRlong *msg; IGRint *vfunc_ident);

end specification EMSshovflow;
