/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method outputs the instance data of this object in a more
    meaningful manner.

  HISTORY

    SS  :  04/06/88  :  Creation
*/

class implementation EMSshobjmgr;

#include "EMS.h"
#include <stdio.h>
#include <string.h>
#include "EMSmsgdef.h"

method debug ()
{
  IGRchar classname[OM_K_MAXCLASS_LEN];
  IGRint i, j, inx;
  IGRlong stat_OM;
  GRclassid *classids;

  stat_OM = OM_S_SUCCESS;

  fprintf (stderr, "Label: %d\n", ME.EMSobjmgr->label);
  fprintf (stderr, "Watermark: %d\n", ME.EMSshobjmgr->watermark);

  fprintf (stderr, "Num classes: %d\n\n", ME.EMSshobjmgr->numclasses);
  inx = 0;
  classids = ME.EMSshobjmgr->classids;
  for (i=0; i<ME.EMSshobjmgr->numclasses; i++)
    {
    stat_OM = om$get_classname (classid = classids[i], classname = classname);
    if (EMSerror (stat_OM))
      strcpy (classname, "Bad classid");
    stat_OM = OM_S_SUCCESS;

    fprintf (stderr, "%s [%d], num objects: %d\n", classname, classids[i],
     ME.EMSshobjmgr->numobjclass[i]);
    for (j=0; j<ME.EMSshobjmgr->numobjclass[i]; j++)
      fprintf (stderr, "\t%d) %d\n", j, ME.EMSshobjmgr->objects[inx++]);
    }
  fprintf (stderr, "Total number of objects: %d\n", 
   ME.EMSshobjmgr->numobjects);

  return (stat_OM);
}

end implementation EMSshobjmgr;
