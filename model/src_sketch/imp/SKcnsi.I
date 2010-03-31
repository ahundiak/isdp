class implementation SKconstraint;

#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include <alloca.h>

from SKvariable import SKgetvar;
from GRundo     import sleep;

method SKmakejacobian (long *msg; unsigned short options;
                       struct SKsolvevars *solvedvars, *unsolvedvars;
                       double *jacobian_row; double *funcval)
{
  *msg = EMS_S_Success;
  return OM_S_SUCCESS;
}


static int compare_objids (p1, p2)
GRobjid *p1, *p2;
{
  return (*p1 < *p2 ? -1 : (*p1 == *p2 ? 0 : 1));
}


method SKorder_points(long *msg; unsigned short options;
                      int num_pts; GRobjid *pt_ids;
                      char *moreinfo)
{
 *msg = EMS_S_Success;

 qsort (pt_ids, num_pts, sizeof (GRobjid), compare_objids);

 return OM_S_SUCCESS;
}


method SKgetpseudovarlist (long *msg; unsigned short opts;
                           struct SKsolvevars **varlist)
{
 *msg = EMS_S_Success;
 return OM_S_SUCCESS;
}


method GRdisplay (long *msg; short *type; IGRmatrix matrix;
                  enum GRdpmode *mode; struct GRid *display_info)
{
  OM_S_CHANSELECT chan_to_comps;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_comps);

  *msg = EMS_S_Success;
  return OM_S_SUCCESS;
}


method debug()
{
  char classname[OM_K_MAXCLASS_LEN];
  short idmattyp;
  int i;
  OMuint count, num_pts;
  long msg_loc;
  IGRpoint xypt, xyzpt;
  IGRmatrix idmat;
  GRobjid obj;
  OM_S_OBJECT_LINKAGE *objlist;
  OM_S_CHANSELECT cnstr_pts_chan, chan_to_super, chan_to_member;

  strcpy (classname, "Unknown classname");
  om$get_classname (object = me, classname = classname);
  fprintf (stderr, "%s : %d objid\n", classname, my_id);

  fprintf (stderr, "\tProps : 0x%x", ME.SKconstraint->props);
  if (ME.SKconstraint->props & SK_GROUND_X)
    fprintf (stderr, " SK_GROUND_X");
  if (ME.SKconstraint->props & SK_GROUND_Y)
    fprintf (stderr, " SK_GROUND_Y");
  if (ME.SKconstraint->props & SK_TEMPORARY)
    fprintf (stderr, " SK_TEMPORARY");
  if (ME.SKconstraint->props & SK_NOVALUE)
    fprintf (stderr, " SK_NOVALUE");
  if (ME.SKconstraint->props & SK_HORIZONTAL)
    fprintf (stderr, " SK_HORIZONTAL");
  if (ME.SKconstraint->props & SK_INVISIBLEHNDL)
    fprintf (stderr, " SK_INVISIBLEHNDL");
  if (ME.SKconstraint->props & SK_MODIFIED)
    fprintf (stderr, " SK_MODIFIED");
  if (ME.SKconstraint->props & SK_NEWADD)
    fprintf (stderr, " SK_NEWADD");
  if (ME.SKconstraint->props & SK_USERADD)
    fprintf (stderr, " SK_USERADD");
  if (ME.SKconstraint->props &SK_PARAMETER_DIM )
    fprintf (stderr, " SK_PARAMETER_DIM");
  if (ME.SKconstraint->props & SK_SELFCNSTR)
    fprintf (stderr, " SK_SELFCNSTR");
  if (ME.SKconstraint->props & SK_CLOCKWISE_ANGLE)
    fprintf (stderr, " SK_CLOCKWISE_ANGLE");
  if (ME.SKconstraint->props & SK_NEGATIVE_AXIS)
    fprintf (stderr, " SK_NEGATIVE_AXIS");
  if (ME.SKconstraint->props & SK_HALFVALUE)
    fprintf (stderr, " SK_HALFVALUE");
  if (ME.SKconstraint->props & SK_UNITSCONVERT)
    fprintf (stderr, " SK_UNITSCONVERT");
  if (ME.SKconstraint->props & SK_SUPPLEMENT)
    fprintf (stderr, " SK_SUPPLEMENT");

  om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &obj),
           targetid = my_id);
  fprintf (stderr, "\n\tMgr : %d\n", obj);

  EMmake_chanselect (SKconstraint_to_super_constrs, &chan_to_super);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_super,
                        count = &count);
  fprintf (stderr, "\tNum super : %d\n", count);
  if (count)
  {
    objlist = (OM_p_OBJECT_LINKAGE) alloca (count * sizeof (OM_S_OBJECT_LINKAGE));
    om$get_channel_objects (object = me, p_chanselect = &chan_to_super,
                            size = count, list = objlist, count = &count);
    for (i=0; i<count; i++)
      fprintf (stderr, "\t %d) Super obj : %d\n", i, objlist[i].S_objid);
  }

  EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_member);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_member,
                        count = &count);
  fprintf (stderr, "\tNum member : %d\n", count);
  if (count)
  {
    objlist = (OM_p_OBJECT_LINKAGE) alloca (count * sizeof (OM_S_OBJECT_LINKAGE));
    om$get_channel_objects (object = me, p_chanselect = &chan_to_member,
                            size = count, list = objlist, count = &count);
    for (i=0; i<count; i++)
      fprintf (stderr, "\t %d) Member obj : %d\n", i, objlist[i].S_objid);
  }

  EMmake_chanselect (SKconstraint_to_variables, &cnstr_pts_chan);
  num_pts = 0;
  om$get_channel_count (object = me, p_chanselect = &cnstr_pts_chan,
                        count = &num_pts);
  fprintf (stderr, "\tNum points : %d\n", num_pts);
  if (num_pts)
  {
    EMidmatrix (&msg_loc, &idmattyp, idmat);

    objlist = (OM_p_OBJECT_LINKAGE) alloca (num_pts * sizeof (OM_S_OBJECT_LINKAGE));
    om$get_channel_objects (object = me, p_chanselect = &cnstr_pts_chan,
                            size= num_pts, list = objlist, count = &num_pts);
    for (i=0; i<num_pts; i++)
    {
      om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL, NULL, NULL,
       xypt), targetid = objlist[i].S_objid);

      om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL, &idmattyp,
       idmat, xyzpt), targetid = objlist[i].S_objid);

      fprintf (stderr, "\t %d) Pt obj %d : [%lf %lf] [%lf %lf %lf]\n", 
       i, objlist[i].S_objid, xypt[X], xypt[Y], xyzpt[X], xyzpt[Y], xyzpt[Z]);
    }
  }

  fprintf (stderr, "\n");
  return OM_S_SUCCESS;
}


method GRchgprops ( long *msg; short *action; short *props )
{
  OMuword         classid;

  *msg = EMS_S_Success;

  om$send ( msg = message GRowner.GRchgprops ( msg, action, props ), 
     mode = OM_e_wrt_message, 
     targetid = my_id );
  
  /* I want to set my property bit otherwise e a e will locate me */
  if (*props & (GRIS_DISPLAYABLE | GRIS_LOCATABLE))
    om$send ( msg = message GRvg.GRchgprops ( msg, action, props ), 
       mode = OM_e_wrt_message, 
       targetid = my_id );

  /* in case the senderid is the undo object, we flush the undo queue */
  if ((*props & (GRIS_LOCATABLE | GRIS_DISPLAYABLE)) && (*action == 0))
  {
    om$get_classid ( objid = sender_id, osnum = sender_os, 
    p_classid = &classid );
    if (classid == OPP_GRundo_class_id)
    {
      struct GRmd_env md_env;
      
      om$send ( msg = message GRundo.sleep ( 0 ), targetid = sender_id );
      md_env.md_id.osnum = OM_Gw_current_OS;
      ex$get_modid ( mod_osnum = md_env.md_id.osnum, mod_id = &md_env.md_id.objid );
      om$send ( msg = message GRgraphics.GRdelete ( msg, &md_env ), targetid = my_id );
    }
  }

  return OM_S_SUCCESS;
}


method GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
  *msg = EMS_S_Success;
  *newobjid = NULL_OBJID;
  
  return OM_S_SUCCESS;
}


end implementation SKconstraint;
