class implementation EMSedittree;

method NDselect_copy(long *msg;int select_type;
			struct GRid *selected_obj;
                        int *info;
		        int selected_size, *selected_nb)
{
 *msg = MSSUCC;
 
 *selected_nb = 1;
 if (selected_size > 0)
 {
  selected_obj[0].objid = ME.EMSedittree->node_id;
  selected_obj[0].osnum = ME.EMSedittree->node_os;
 }

 return (OM_S_SUCCESS);
}

method  NDdisplay(IGRint obsolet;enum GRdpmode mode;struct GRmd_env *md_env)
{
 return (om$send (msg = OPPmargs,
                  targetid = ME.EMSedittree->node_id,
                  targetos = ME.EMSedittree->node_os));
 }

method NDget_objects(int type;struct GRid *list;int size;struct GRid **buffer;
		       int ifrom,ito,*count)
{
 return (om$send (msg = OPPmargs,
                  targetid = ME.EMSedittree->node_id,
                  targetos = ME.EMSedittree->node_os));
}

method NDgive_structure (IGRlong *EMmsg; struct ret_struct *str;
                         struct GRmd_env *md_env)
/* ********************************************************
Description
 This override returns the type in str->type as other_generic.

History
 Creation : PP :03/08/91
*********************************************************** */
{
 *EMmsg = MSSUCC;
 str->type = other_generic;
 return (OM_S_SUCCESS);
}
end implementation EMSedittree;

