/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

extern GRclassid OPP_EMSparamgm_class_id;
extern GRclassid OPP_EMSparampt_class_id;
extern GRclassid OPP_EMSparamvc_class_id;
extern GRclassid OPP_EMSparampl_class_id;

#define NUM_CHECK_CLASSES 3

struct parmindist
  {
  GRobjid parobj;
  IGRdouble mindist;
  };

from EMSparamgm import EMlnmindist;

method EMlocate_geomparam (IGRlong *msg; IGRushort opts;
                           IGRshort *mattyp; IGRmatrix mat;
                           IGRushort param_types;
                           struct IGRline *boreline;
                           IGRint num_in_buff; GRobjid *buff;
                           IGRint *num_geomparms; GRobjid **geomparms)
{
  IGRchar *stackptr;
  IGRint i, j, num_parents, num_eligpars;
  IGRlong msg_loc, stat_OM;
  GRobjid parobj;
  GRclassid parentclass, classes[NUM_CHECK_CLASSES];
  GRspacenum paros;
  struct parmindist *eligpars, temp_eligpars;
  OM_S_CLASSLIST classlist;
  OM_S_CHANSELECT chan_to_parents;
  OM_S_OBJECT_LINKAGE *parentobjs;
  extern IGRboolean EMclass_eligible();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_geomparms = 0;
  *geomparms = NULL;

  stackptr = NULL;

  /*
   * Obtain the list of this object's geometric parameters that are
   * indicated as eligible by the "param_types" mask.
   */

  EMmake_chanselect (NDfather_father, &chan_to_parents);
 
  num_parents = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_parents,
   count = (OMuint *)&num_parents);

  parentobjs = (OM_p_OBJECT_LINKAGE) stackalloc (num_parents * 
                           sizeof (OM_S_OBJECT_LINKAGE));
  stackptr = (IGRchar *)parentobjs;
  eligpars = (struct parmindist *) stackalloc (num_parents * 
                                                 sizeof (struct parmindist));
  EMerr_hndlr (!parentobjs || !eligpars, *msg, EMS_E_NoStackMemory, ret_end);

  om$get_channel_objects (object = me, p_chanselect = &chan_to_parents,
   count = (OMuint *)&num_parents, size = num_parents, list = parentobjs);

  /*
   * Obtain the sub-list of parents that are eligible geometric 
   * parameters
   */

  classlist.w_count = 0;
  classlist.w_flags = OM_CLST_subclass;
  classlist.p_classes = classes;
  if (param_types & EMSparam_point)
    classes[classlist.w_count++] = OPP_EMSparampt_class_id;
  if (param_types & EMSparam_vector)
    classes[classlist.w_count++] = OPP_EMSparamvc_class_id;
  if (param_types & EMSparam_plane)
    classes[classlist.w_count++] = OPP_EMSparampl_class_id;

  num_eligpars = 0;
  for (i=0; i<num_parents; i++)
    {
    parobj = parentobjs[i].S_objid;
    paros = parentobjs[i].osnum;
    om$get_classid (objid = parobj, osnum = paros, p_classid = &parentclass);

    if (EMclass_eligible (parentclass, &classlist) &&
        paros == OM_Gw_current_OS)
      eligpars[num_eligpars++].parobj = parobj;
    }

  /*
   * Send to each geometric parameter object in this newly constructed
   * list, the message to obtain it's minimum distance with the boreline.
   */
 
  for (i=0; i<num_eligpars; i++)
    {
    stat_OM = om$send (msg = message EMSparamgm.EMlnmindist (&msg_loc, NULL,
               mattyp, mat, boreline, &eligpars[i].mindist),
               targetid = eligpars[i].parobj);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Sort out the eligpars in increasing order using minimum distance
   * as the criteria.
   */

  for (i=0; i<num_eligpars-1; i++)
    for (j=0; j<num_eligpars-i-1; j++)
      if (eligpars[j].mindist > eligpars[j+1].mindist)
        {
        temp_eligpars = eligpars[j];
        eligpars[j] = eligpars[j+1];
        eligpars[j+1] = temp_eligpars;
        }

  /*
   * Format the output extracting the par-objids from
   * the list processed above.
   */

  if (num_in_buff && buff && num_in_buff >= num_eligpars)
    *geomparms = buff;
  else
    *geomparms = (GRobjid *)om$malloc (size = num_eligpars * sizeof (GRobjid));
  EMerr_hndlr (!*geomparms, *msg, EMS_E_NoDynamicMemory, ret_end);

  for (i=0; i<num_eligpars; i++)
    (*geomparms)[i] = eligpars[i].parobj;
  *num_geomparms = num_eligpars;

ret_end:
  if (stackptr)
    stackfree (stackptr);

  EMWRAPUP (*msg, stat_OM, "EMSassoc.EMlocpargm");
  return (stat_OM);
}

end implementation EMSassoc;

