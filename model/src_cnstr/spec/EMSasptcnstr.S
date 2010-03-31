/*
  DESCRIPTION

    This is an instantiable class which stands for a fully defined
    associative point.

  HISTORY

    SS  :  03/14/91  :  Creation
    RA  :  04/15/93  :  Inherited GRgetobjinfo, debug, GRdisplay and
                        GRlocate_owner from EMSimpcnstr to make it consistent with
                        the rest of the constraints.
*/

class specification EMSasptcnstr (2:0) of EMSimpcnstr, DMsrc;

message EMalt_init (IGRlong *msg; IGRushort opts;
                    struct GRmd_env *md_env;
                    IGRint num_parents;
                    struct GRid *parents; 
                    IGRushort cnstr_props; IGRchar *moreinfo;
                    IGRint num_children;
                    struct GRid *children);
override 
  NDupdate,
  EMinit, EMgetgeomlocus;

from EMSimpcnstr inherit
  ASreturn_go,
  ACbecome_macro, ACcopy_to_Groot,
  NDselect_copy, NDconnect_graph, NDdisplay,
  GRgetobjinfo, debug,
  GRdisplay, GRlocate_owner;

end specification EMSasptcnstr;
