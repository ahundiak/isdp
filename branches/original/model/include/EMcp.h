#ifndef EMcp_include
#define EMcp_include

struct EMgraph_cp_info
{
 IGRint graph_count;
 struct NDcp_list *graph_array;
};

struct EMcp_info
{
 IGRlong num_entries;
 IGRlong array_size;
 GRobjid *objid_array;
 struct EMgraph_cp_info graph_info;
};

#define EMS_COPY_ASSOCIATIVE 0x01

#endif
