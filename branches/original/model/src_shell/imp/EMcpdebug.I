/* ###################   APOGEE COMPILED   ################## */
class implementation EMScpmgr;

#include <stdio.h>

method debug ()
{
  IGRint i;
  IGRlong stat_OM;

  stat_OM = OM_S_SUCCESS;

  fprintf (stderr, "Tag: %d\n", ME.EMSobjmgr->label);
  fprintf (stderr, "Num entries: %d\n", ME.EMScpmgr->num_entries);
  for (i=0; i<ME.EMScpmgr->num_entries; i++)
    fprintf (stderr, "%d) %d %d\n", i, ME.EMScpmgr->cptbl[i][0],
     ME.EMScpmgr->cptbl[i][1]);

  return (stat_OM);
}

end implementation EMScpmgr;
