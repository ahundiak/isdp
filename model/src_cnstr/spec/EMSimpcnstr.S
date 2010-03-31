/*
  DESCRIPTION

    This is an abstract class that is the super class for all implicit
    constraints that define geometric constraints. This excludes 2D
    variational geometry constraints.

  HISTORY

    SS  :  03/14/91  :  Creation
*/

class specification EMSimpcnstr (2:0) of EMScnstr;

message EMgeomhandle (IGRlong *msg; IGRushort opts;
                      struct GRmd_env *md_env; GRobjid *geom_handle);

override
 NDupdate, NDgive_structure;

end specification EMSimpcnstr;
