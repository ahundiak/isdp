#ifndef refobj_include
#define refobj_include

/*
 * The following structures are used in the function EFref_obj_check, which is
 * supposedly a temporary function until GRreffile's GRfunction method is
 * changed to prevent sending to the same reference file again and again.
 * Once the function GRref_obj_check goes away, this include file should too,
 * so only use it if you are calling GRref_obj_check.
 */

struct ref_obj_entry
{
    GRobjid     objid;
    GRspacenum  osnum;
    IGRdouble   matrix[16];
};

struct ref_objects
{
    IGRint                 num_entries;
    IGRint                 num_avail_entries;
    struct ref_obj_entry  *entries;
};

#endif
