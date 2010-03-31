class implementation SKgeometry;

/*
 * These overrides have been done to disallow any connections/disconnections
 * to the geometry objects on the parent-child channel.
 * We have to do this to preserve integrity of the variational geometry
 * structures.
 * pp 01/20/92
 */

method NDconnect_graph(IGRlong *msg; IGRint cp_type;
                 struct GRmd_env *fr_env,*to_env;
                 struct NDcp_list *copied_element; int copied_size;
                 int nb_root, *root_index;
                 int my_index)
{
 *msg = MSSUCC;
 return (OM_S_SUCCESS);
}

method NDconnect(int nb_root; struct GRid *root; struct GRid original;
		    IGRint type)
{
 return (OM_S_SUCCESS);
}

method NDdisconnect(int nb_root; struct GRid *root)
{
 return (OM_S_SUCCESS);
}

method NDchange_connect(int nb_change; struct GRid *old,*new)
{
 return (OM_S_SUCCESS);
}

end implementation SKgeometry;

