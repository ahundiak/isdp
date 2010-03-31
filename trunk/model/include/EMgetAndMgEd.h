
IGRlong GetEdgesAndMerge(
                         IGRlong *EMmsg,
                         GRobjid new_surf,
                         struct GRvg_construct construct_list,
                         IGRboolean is_simple_surf,
                         GRobjid *surfs,
                         GRobjid ref_id,
                         struct GRmd_env *md_env,
                         IGRint  *num_merge_edges, 
                         GRobjid **mg_edges,    
                         IGRint  *num_merged,     
                         GRobjid **conn_edges,     
                         IGRint   *num_sort,
                         GRobjid **sorted_edges);

