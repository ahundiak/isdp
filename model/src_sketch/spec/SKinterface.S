/*
  DESCRIPTION

    This is an abstract class which provides the geometric handle
    to a set of constraints which need to behave as one.
*/

class specification SKinterface (2:0) of SKconstraint;

instance SKinterface
  {
  channel {(many_to_many, rel_ordered)} to_member_constrs;
  };

#ifndef BASE_EMS

message SKconnect_to_member (IGRlong *msg; IGRushort opts;
                             GRobjid member_cnstr;
                             IGRint member_inx, interface_inx);
override
  debug,
  GRgetobjinfo,
  SKintcopy, SKgetconstrs, SKgetpseudovarlist;

#endif

end specification SKinterface;

