/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
method EMtree_traverse(IGRlong *EMmsg; OM_p_MESSAGE messg; 
                       IGRint num_classes; GRclassid *classids;
                       IGRboolean down)
/*
  DESCRIPTION

  This method is used to drop messages off to surfaces owned by a composite
  node.  The message carried on the argument-list is applied to the relevant
  objects at this node. 

  The objects relevant for this override to send to are - 
       i) surfaces and
      ii) the composite objects (including solids)

  The attempt to send to the surface objects is done first
  then the composite is sent to.

  ARGUMENTS

  messg            - Input: The message that is to be applied to the
                            relevant objects visted.
  num_classes      - Input: The number of classids specified in the
                            'classids' array.
  classids         - Input: Array containing the classids of the objects
                            at each node visited, which should
                            receive 'messg'.  Super-classids may be
                            specified to include a whole gang of types.
  down             - Input: If TRUE, the traversal proceeds 'down' the
                            tree, else it proceeds upwards.
  
  RETURN VALUE

  The return code will be one of the following:

  Success  
    - EMS_S_Success
      All went well

  Error condition


  BUGS

    The "down" flag is ignored and the send takes place only downward.

  HISTORY

    SS  :  05/01/87  :  Creation
    SS  :  05/25/87  :  Added the tree_depth, classids and the 'down' 
                        arguments.
    SS  :  05/30/87  :  Added the send to objects on notification channel.
    DLB :  06/15/87  :  Took the tree trav method at the loop level and
                        copied it to compsurf making several modifications.
    DLB :  11/01/87  :  Modified for version 1.1.0
 */
{
  IGRlong         OM_stat;
  IGRint          i, j, list_cnt;
  struct GRid     my_GRid, *my_list;
  OM_S_CHANSELECT to_comps;
  OMuword         my_classid;


  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*If the list of classids indicates that the message needs to be
   * applied to my comps (or certain subclass of comps), so be it.
   */
  OM_stat = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
  if (!(1 & OM_stat)) goto wrapup;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  for(i = 0; i < num_classes; i ++)
  {
    list_cnt = 0;
    my_list = NULL;
    EFgetobjids(EMmsg, &my_GRid, &to_comps, &my_list, &list_cnt, 
                classids[i], NULL, NULL);
    if (!(1 & *EMmsg)) goto wrapup;
   
    for (j = 0; j < list_cnt; j ++)
    {
      OM_stat = om$send(msg = messg, 
                        targetid = my_list[j].objid);
      if (!(1 & OM_stat)) goto wrapup;
    }
    if (my_list) om$dealloc(ptr = my_list);
  }

  /*If the list of classids passed in indicates that the
   * message is to be sent to my_self, so be it.
   */

  OM_stat = om$get_classid(object = me, p_classid = &my_classid);
  if (!(1 & OM_stat)) goto wrapup;  

  for (i = 0; i < num_classes; i++)
  {
    if (classids[i] == my_classid || 
        om$is_ancestry_valid(subclassid = my_classid,
                             superclassid = classids[i]) == OM_S_SUCCESS)
    {
      OM_stat = om$send (msg = messg, targetid = my_id);
      if (!(1 & OM_stat)) goto wrapup;
      break;
    }
  }
 
 wrapup:
  if (my_list) om$dealloc(ptr = my_list);
  EMWRAPUP (*EMmsg, OM_stat, "EMScompsurf.EMtree_traverse");
  return (OM_stat);
}
end implementation EMScompsurf;
