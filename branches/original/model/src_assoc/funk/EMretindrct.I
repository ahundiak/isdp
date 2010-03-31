/* ###################   ANSI   COMPILED   ################## */
class implementation EMSpointer;

extern OMuword OPP_SKgeometry_class_id;

IGRlong EMreturn_indirection(EMmsg, options, component_GRid, 
                             ptr_GRid, create)
IGRlong *EMmsg;
unsigned int options;
struct GRid *component_GRid;
struct GRid *ptr_GRid;
IGRboolean create;
/*
 * This function will return an indirection object for an entity if
 * one exists. If one does not exist then if the field create is set
 * to TRUE then an object will be created. This pointer will be created
 * in the same object space as the component.
 *
 * Arguments
 *  Input
 *   options : IGRint : Currently not supported
 *   component_GRid   : Component whose indirection object
 *                      is to be returned.
 *   create           : Option whether to create or not.
 *
 * Output
 *   EMmsg : Completione code
 *   ptr_GRid : Indirection object
 *
 * Notes
 *  Following are valid completion codes:
 *   EMS_S_Success: If all goes well
 *   EMS_E_InvalidArg : If there can never be a pointer for the component
 *                      being passed.
 *
 * History
 *   Creation : PP : 03/27/92
 */

{
 IGRlong status, chan_count,i;
 IGRboolean found = FALSE;
 OM_S_CHANSELECT children;
 OM_S_OBJECT_LINKAGE *children_linkage = NULL;
 struct GRid creator_GRid, src_GRid, temp_GRid;
 OMuword constr_os;
 extern OMuword OPP_EMSboundary_class_id,
                OPP_EMSsurface_class_id,
                OPP_GRcurve_class_id;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 constr_os = component_GRid->osnum;

 ptr_GRid->objid = NULL_OBJID;
 temp_GRid.objid = NULL_OBJID;
 src_GRid.objid = NULL_OBJID;
 creator_GRid.objid = NULL_OBJID;

 creator_GRid.osnum = component_GRid->osnum;

 if ((EFisAncestryValid(EMmsg, component_GRid->objid, component_GRid->osnum,
                        OPP_EMSboundary_class_id, FALSE)) ||
     (EFisAncestryValid(EMmsg, component_GRid->objid, component_GRid->osnum,
                        OPP_EMSsurface_class_id, FALSE)))
 {
  status = EFget_creator_id (EMmsg, component_GRid->objid, 
                            component_GRid->osnum,
                            &creator_GRid.objid,
                            NULL);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
/*
 * The following kludge is being put in to ensure that NC objects handle
 * the mergers/deletions of profiles.
 * pp 11/08//93
 */
 else if (EFisAncestryValid(EMmsg, component_GRid->objid, 
                             component_GRid->osnum,
                             OPP_SKgeometry_class_id, FALSE))
 {
  *ptr_GRid = *component_GRid;
  return (OM_S_SUCCESS);
 }
 else if (EFisAncestryValid(EMmsg, component_GRid->objid, 
                             component_GRid->osnum,
                             OPP_GRcurve_class_id, FALSE))
 {
   ASget_as_owner (component_GRid, &creator_GRid);
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  return (status);
 }

/*
 * If there is no creator then a component does not make sense.
 * OR
 * If the creator is the same as the component, then too a
 * component does not make sense.
 */

 if (((creator_GRid.objid == (component_GRid->objid)) &&
     (creator_GRid.osnum == (component_GRid->osnum))) ||
     (creator_GRid.objid == NULL_OBJID))
 {
  *EMmsg = EMS_E_InvalidArg;
  return (status);
 }

/*
 * If the creator is not the same as the component and if he is
 * is non-associative construct a source and look on his
 * parent channel for the pointer object. Construct the source with a
 * NULL_OBJID for context, since the pointer is going to be in the same
 * file as the creator.
 *
 * If the creator is associative then look on his parent channel for the
 * pointer object.
 */

if (!(EFisAncestryValid(EMmsg, creator_GRid.objid, creator_GRid.osnum, 
                          OPP_NDnodein_class_id, FALSE)))
{
  struct GRid temp_context;
  temp_context.objid = NULL_OBJID;
  status = ASmake_source_from_go(EMmsg,&creator_GRid,&temp_context,
                                constr_os,&src_GRid);
  if (!(1&status&*EMmsg)) goto wrapup;
}
else
 src_GRid = creator_GRid;

/*
 * If this is true there has been some major foul up.
 */
if (src_GRid.osnum != creator_GRid.osnum)
{
 *EMmsg = EMS_E_InvalidCase;
 goto wrapup;
}

 
/*
 * Determine whether a pointer object already exists by looking for
 * objects on the children channel of the creator's source which could
 * either be a sourcein, source or the creator himself. 
 */

 status = om$make_chanselect(channame = "NDchildren.children",
                             p_chanselect = &children);
 if (!(1&status)) goto wrapup;

 status = om$get_channel_count(p_chanselect = &children,
                               objid = src_GRid.objid,
                               osnum = src_GRid.osnum,
                               count = (OMuint *)&chan_count);
 if (!(1&status)) goto wrapup;

 if (chan_count)
 {
  children_linkage = (OM_S_OBJECT_LINKAGE *) stackalloc(chan_count *   
                     sizeof (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr(!children_linkage, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$get_channel_objects(objid = src_GRid.objid,
                                  osnum = src_GRid.osnum,
                                  p_chanselect = &children,
                                  list = children_linkage,
                                  size = chan_count,
                                  count =(OMuint *) &chan_count);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 
 found = FALSE;
 for (i=0;i<chan_count;i++)
 {
  temp_GRid.objid = NULL_OBJID;
  om$send (msg = message NDnode.ASreturn_go(&temp_GRid,NULL,
                          NULL),
                    senderid = NULL_OBJID,
                    targetid = children_linkage[i].S_objid,
                    targetos = children_linkage[i].osnum);

  if (temp_GRid.objid == (component_GRid->objid))
   {
    ptr_GRid->objid = children_linkage[i].S_objid;
    ptr_GRid->osnum = children_linkage[i].osnum;
    found = TRUE;
    *EMmsg = EMS_I_Found;
    break;
   }
  }
 }

 if (!found)
 {
  if (create)
  {
   struct GRid context_GRid;
   context_GRid.objid = NULL_OBJID;
   
   status = om$construct(classid = OPP_EMSpointer_class_id,
                       p_objid = &ptr_GRid->objid,
                       osnum = component_GRid->osnum);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

   ptr_GRid->osnum = component_GRid->osnum;

   status = om$send (msg = message EMSpointer.EMinit(EMmsg, 
                         NULL,
                         &src_GRid, &context_GRid, component_GRid->objid),
                   senderid = NULL_OBJID,
                   targetid = ptr_GRid->objid,
                   targetos = ptr_GRid->osnum);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  }
  else
   ptr_GRid->objid = NULL_OBJID;
 }


wrapup:
 if (children_linkage) stackfree (children_linkage);
 EMWRAPUP (*EMmsg, status, "In EFcreate_return_indirection error");
 return (status);
}

end implementation EMSpointer;
