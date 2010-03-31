/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

extern GRclassid OPP_EMSparamgm_class_id;
extern GRclassid OPP_EMSparampt_class_id;
extern GRclassid OPP_EMSparamvc_class_id;
extern GRclassid OPP_EMSparampl_class_id;

#define NUM_CHECK_CLASSES 3

extern GRclassid OPP_GRgraphics_class_id;

from EMSparamgm import EMdisplay;

method EMdisplay_geomparam (IGRlong *msg; IGRushort opts;
                            IGRshort *mattyp; IGRmatrix mat;
                            IGRushort param_types;
                            struct GRid *disp_id)
{
  IGRchar *stackptr;
  IGRint i, num_displayed, num_parents, num_eligpars;
  IGRlong msg_loc, stat_OM;
  GRobjid parobj;
  GRclassid parentclass, classes[NUM_CHECK_CLASSES];
  GRspacenum paros;
  enum GRdpmode dpmode;
  struct GRsymbology symb;
  struct IGRdisplay disp_attr;
  struct GRid *eligpars;
  OM_S_CLASSLIST classlist;
  OM_S_CHANSELECT chan_to_parents;
  OM_S_OBJECT_LINKAGE *parentobjs;
  extern IGRboolean EMclass_eligible();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stackptr = NULL;
  num_displayed = 0;

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
  stackptr = (IGRchar *) parentobjs;

  eligpars = (struct GRid *)stackalloc (num_parents * sizeof (struct GRid));
  EMerr_hndlr (!parentobjs || !eligpars, *msg, EMS_E_NoStackMemory, ret_end);

  om$get_channel_objects (object = me, p_chanselect = &chan_to_parents,
   count = (OMuint *)&num_parents, size = num_parents, list = parentobjs);

  /*
   * Obtain the sub-list of parents that are eligible geometric 
   * parameters
   */

  if (param_types & EMSparam_virtualpars)
    {
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
        {
        eligpars[num_eligpars].osnum = OM_Gw_current_OS;
        eligpars[num_eligpars++].objid = parobj;
        }
      }
  
    /*
     * Send the special display message - EMSparamgm.EMdisplay to these
     * eligible geometric parameters.
     */

    stat_OM = om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb),
               targetid = my_id);
    if (EMSerror (stat_OM & msg_loc))
      {
      disp_attr.color = 0;
      disp_attr.weight = 1;
      disp_attr.style = 0;
      }
    else
      {
      disp_attr = symb.display_attr;
      disp_attr.weight++;
      }

    for (i=0; i<num_eligpars; i++)
      {
      om$send (msg = message EMSparamgm.EMdisplay (&msg_loc, opts, mattyp,
       mat, &disp_attr, GRhd, disp_id), targetid = eligpars[i].objid);
      num_displayed++;
      }
    }

  /*
   * Obtain the sub-list of parents that are eligible "GRgraphics"
   * parameters.
   */

  if (param_types & EMSparam_grid)
    {
    num_eligpars = 0;
    for (i=0; i<num_parents; i++)
      {
      parobj = parentobjs[i].S_objid;
      paros = parentobjs[i].osnum;
      om$get_classid (objid = parobj, osnum = paros, p_classid = &parentclass);
  
      if (om$is_ancestry_valid (subclassid = parentclass,
           superclassid = OPP_GRgraphics_class_id) == OM_S_SUCCESS)
        {
        eligpars[num_eligpars].osnum = paros;
        eligpars[num_eligpars++].objid = parobj;
        }
      }
  
    dpmode = GRhd;
    for (i=0; i<num_eligpars; i++)
      {
      om$send (msg = message GRgraphics.GRdisplay (&msg_loc, mattyp, mat,
       &dpmode, disp_id), targetid = eligpars[i].objid,
       targetos = eligpars[i].osnum);
      num_displayed++;
      }
    }

  /*
   * If no parameter that satisfies the criteria set in "param_types"
   * exists for this object (no parameter was displayed), then return
   * the code EMS_I_NotFound.
   */

  if (!num_displayed)
    *msg = EMS_I_NotFound;

ret_end:
  if (stackptr)
    stackfree (stackptr);

  EMWRAPUP (*msg, stat_OM, "EMSassoc.EMdispgmpar");
  return (stat_OM);
}

end implementation EMSassoc;

