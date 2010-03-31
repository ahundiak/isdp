/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method checks the validity of the contents of this shell-manager.
    If the return code is EMS_I_InvalidCase, there is a problem with the
    contents.

    The severity number returned indicates the extent of the damage. Lowest
    severity is 1 and increases with the number of errors found.

  HISTORY

    SS  :  08/07/89  :  Creation
*/

class implementation EMScpmgr;

#include "OMmacros.h"
#include "EMSprop.h"
#include "EMSlcdef.h"

#define LOCAL_BUFF_SIZE 5

#define KEY 0
#define CP  1

#define ONE   0
#define TWO   1
#define THREE 2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRcurve_class_id, OPP_GRbspline_class_id;
extern GRclassid OPP_EMSloop_class_bid, OPP_EMSedge_class_id;

from OMObjSpace import pass;
from EMSboundary import EMreturn_my_id, EMgetxyzobj;
from EMSloop import EMget_props;
from EMSedge import EMget_props;

method EMvalidate (IGRlong *msg; IGRushort options; 
                   FILE *logfile; IGRchar *info; IGRint *severity)
{
  IGRboolean found;
  IGRushort props;
  IGRint inx, classinx, num_entries, num_keyclasses, num_cpclasses;
  IGRint severity_loc;
  IGRulong label;
  IGRlong msg_loc, stat_OM, keystat, cpstat;
  GRclassid keyclassid, cpclassid, *keyclasses=NULL, *cpclasses=NULL;
  GRclassid keyclassmem[LOCAL_BUFF_SIZE], cpclassmem[LOCAL_BUFF_SIZE];
  GRobjid (*objects)[2], dumobj, osobj;
  OM_S_CLASSLIST classlist;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  severity_loc = 0;

  /*
   * Initialize the local varaibles. Some variables are initialized to
   * values specific to this object's label.
   */

  num_entries = ME.EMScpmgr->num_entries;
  objects = ME.EMScpmgr->cptbl;
  label = ME.EMSobjmgr->label;

  if (options & EMS_OBJMGR_LABELSPEC && label == EMScp_sfbdry)
    {
    num_keyclasses = 2;
    keyclasses = keyclassmem;
    keyclasses[ONE] = OPP_EMSedge_class_id;
    keyclasses[TWO] = OPP_EMSloop_class_id;
    num_cpclasses = 2;
    cpclasses = cpclassmem;
    cpclasses[ONE] = OPP_GRbspline_class_id;
    cpclasses[TWO] = OPP_GRcurve_class_id;
    }
  else
    {
    num_keyclasses = 0;
    num_cpclasses = 0;
    }

  /*
   * Perform the generic validation. Check if the objects of the table
   * belong to the specified classes.
   */

  inx = 0;
  while (inx < num_entries)
    {
    keystat = om$get_classid (objid = objects[inx][KEY],
               p_classid = &keyclassid);
    if (EMSerror (keystat))
      severity_loc++;

    cpstat = om$get_classid (objid = objects[inx][CP],
              p_classid = &cpclassid);
    if (EMSerror (cpstat))
      severity_loc++;

    if (!EMSerror (keystat) && !EMSerror (cpstat))
      {
      found = FALSE;
      for (classinx=0; classinx<num_keyclasses; classinx++)
        {
        keystat = om$is_ancestry_valid (subclassid = keyclassid,
                   superclassid = keyclasses[classinx]);

        cpstat = om$is_ancestry_valid (subclassid = cpclassid,
                  superclassid = cpclasses[classinx]);

        if (keystat == OM_S_SUCCESS && cpstat == OM_S_SUCCESS)
          {
          if (options & EMS_OBJMGR_LABELSPEC)
            {
            if (label == EMScp_sfbdry)
              {
              OM_S_OBJID  mscobj;

              stat_OM = om$send (msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mscobj),
                                 targetid = objects[inx][KEY]);
              EMomerr_exit (stat_OM, ret_end);

              if (classinx == ONE)
                stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                           &props), targetid = objects[inx][KEY]);
              else
                stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                           &props), targetid = objects[inx][KEY]);
              EMomerr_exit (stat_OM, ret_end);

              if (classinx == ONE && props & EMED_MSCEXISTS ||
                  classinx == TWO && props & EMLP_MSCEXISTS)
                found = TRUE;
              else
                found = FALSE;
              }
            }
          else
            found = TRUE;
          break;
          }
        }

      if (!found)
        {
        keystat = FALSE;
        cpstat = FALSE;
        severity_loc++;
        }
      }

    if (EMSerror (keystat) || EMSerror (cpstat))
      {
      if (options & EMS_OBJMGR_CORRECT)
        {
        stat_OM = om$send (msg = message EMScpmgr.EMdelentry (&msg_loc, 
                   EMScpmanip_keywise, 1, &objects[inx][KEY], &dumobj),
                   targetid = my_id);
        EMomerr_exit (stat_OM, ret_end);
        inx--;
        num_entries--;
        }
      }
    inx++;
    }
  
  /*
   * If the option is to perform the label-specific validation, do
   * so.
   */

  if (options & EMS_OBJMGR_LABELSPEC)
    {
    if (label == EMScp_sfbdry)
      {
      stat_OM = om$osnum_to_oso_objid (osnum = OM_Gw_current_OS,
                 p_objid = &osobj);
      EMomerr_exit (stat_OM, ret_end);

      classlist.w_count = 1;
      classlist.w_flags = OM_CLST_subclass;
      for (classinx=ONE; classinx<=TWO; classinx++)
        {
        classlist.p_classes = 
         classinx == ONE ? &OPP_EMSedge_class_id : &OPP_EMSloop_class_id;
        stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                   OM_e_wrt_object, message EMSboundary.EMgetxyzobj
                   (&msg_loc, EMSlcopt_existingmsc | EMSlcopt_nocommon |
                   EMSlcopt_debug, NULL, NULL, NULL, NULL, NULL,
                   OM_Gw_current_OS, &dumobj)), targetid = osobj);
        EMomerr_exit (stat_OM, ret_end);
        }
      }
    }

ret_end:
  if (severity_loc)
    fprintf (stderr, "Invalid cp-manager %d. Severity %d\n", my_id,
     severity_loc);

  *severity += severity_loc;
  if (*severity)
    *msg = EMS_I_InvalidCase;

  return (stat_OM);
}

end implementation EMScpmgr;

