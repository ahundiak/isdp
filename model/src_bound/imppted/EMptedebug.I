/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

#include "EMS.h"
#include <stdio.h>
#include <ctype.h>

method debug()
{
  IGRchar errmsg[EMMAXERRMSG_LEN], yes[20], type[50];
  IGRint stat_OM;
  FILE *fileptr;
  void EFget_string_for_edge_type();

  stat_OM = EMS_S_Success;
  strcpy (errmsg, "EMSptedge.debug");

  EFget_string_for_edge_type(ME.EMSedge->curve_type, type);
  fprintf (stderr, "\nPoint edge:\n\tObjectid %d\n", my_id);
  fprintf (stderr, "\tProperties 0x%x\n", ME.EMSedge->ed_props);
  fprintf (stderr, "\tCurve Type %d -- %s\n", ME.EMSedge->curve_type, type);
  fprintf (stderr, "%5.12lf %5.12lf\n",
       ME.EMSptedge->point[0], ME.EMSptedge->point[1]);

  fprintf (stderr, "Write geometry to file? y/n [n] ");
  scanf ("%s", yes);
  if (toupper(yes[0]) == 'Y')
    {
    fprintf (stderr, "Filename _: ");
    scanf ("%s", yes);
    fileptr = fopen (yes, "a");
    fprintf (fileptr, "2\n");
    fprintf (fileptr, "%5.12lf %5.12lf\n",
       ME.EMSptedge->point[0], ME.EMSptedge->point[1]);
    fprintf (fileptr, "%5.12lf %5.12lf\n",
       ME.EMSptedge->point[0], ME.EMSptedge->point[1]);
    fclose (fileptr);
    }
   else if (toupper (yes[0]) == 'Q')
    stat_OM = OM_I_STOP_SENDING;

ret_end:
  return (stat_OM);
}

end implementation EMSptedge;
