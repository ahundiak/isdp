class specification EMSpartsupp (1:0) of NDnodein, GRowner;

/* partial suppression support class for dpr nodes.*/

#include "EMSmsgdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMStypedef.h"
#include "emsdef.h"
#include "EMSprop.h"

struct EMScomp_vla_struct
{
  GRobjid   comp_id;
  IGRuint   num_ptrs;
  IGRushort comp_index;
};

instance EMSpartsupp
{
  variable struct EMScomp_vla_struct comp_info[];
  variable GRobjid ptr_ids[];
};

not_taggable;

override NDchildren;

message EMget_index_of_comp_id(IGRlong   *EMmsg; 
                               GRobjid   group_comp_id;
                               IGRushort *group_comp_inx;
                               IGRuint   *total_group_count;
                               IGRushort options);

message EMget_comp_info(IGRlong         *EMmsg;
                        IGRuint         *group_count;
                        GRobjid         **group_comp_ids;
                        IGRushort       **group_comp_indices;
                        IGRushort       options);

message EMget_partial_suppress_id(IGRlong         *EMmsg;
                                  GRobjid         *partial_suppress_id;
                                  OMuword         options);

message EMmove_comp(IGRlong    *EMmsg; 
                    GRobjid    dpr;
                    IGRboolean to_partail_suppress;
                    GRobjid    group_comp_id;
                    OMuword    options);
 
message EMdelete_group_comp(IGRlong     *EMmsg;
                            GRobjid     group_comp_id;
                            struct GRmd_env *env;
                            OMuword         options);

override
    NDcompute_node,
    NDmove_to_root,
    debug;
       
end specification EMSpartsupp;
