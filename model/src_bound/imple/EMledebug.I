/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlinedge;

#include "EMS.h"
#include <stdio.h>
#include <ctype.h>

method debug()
{
  IGRchar errmsg[EMMAXERRMSG_LEN], yes[20], type[50];
  IGRint stat_OM, i;
  FILE *fileptr;
  void EFget_string_for_edge_type();
  IGRboolean	is_iso = FALSE;

  stat_OM = EMS_S_Success;
  strcpy (errmsg, "EMSlinedge.debug");

  is_iso = ME.EMSedge->ed_props & EMED_ISO ? TRUE : FALSE;

  EFget_string_for_edge_type(ME.EMSedge->curve_type, type);
  fprintf (stderr, "\nLinear edge:\n\tObjectid %d\n", my_id);
  fprintf (stderr, "\tProperties 0x%x\n", ME.EMSedge->ed_props);
  fprintf (stderr, "\tCurve Type %d -- %s\n", ME.EMSedge->curve_type, type);
  fprintf (stderr, "\tCreator %d\n", ME.EMSboundary->creator_id);
  if(is_iso)
   fprintf(stderr, "\tIso Edge\n");
  fprintf (stderr, "\tNumber of points %d\n", ME.EMSlinedge->num_points);

  fprintf (stderr, "Write (logical)geometry to file? y/n [n] ");
  scanf ("%s", yes);

  if (toupper(yes[0]) == 'Y')
    {
    fprintf (stderr, "Filename _: ");
    scanf ("%s", yes);
    fileptr = fopen (yes, "a");
    fprintf (fileptr, "%d\n", ME.EMSlinedge->num_points);
    if (ME.EMSedge->ed_props & EMED_REVERSED)
     {
      for (i=ME.EMSlinedge->num_points-1; i >= 0; i--)
       fprintf (fileptr, "%5.12lf %5.12lf\n",
         ME.EMSlinedge->points[i*2], ME.EMSlinedge->points[i*2+1]);
     }
    else
     {
      for (i=0; i<ME.EMSlinedge->num_points; i++)
        fprintf (fileptr, "%5.12lf %5.12lf\n",
         ME.EMSlinedge->points[i*2], ME.EMSlinedge->points[i*2+1]);
     }
    fclose (fileptr);
    }
   else if (toupper (yes[0]) == 'Q')
    {
     stat_OM = OM_I_STOP_SENDING;
     goto ret_end;
    }

  fprintf (stderr, "Show (logical)geometry on screen ? y/n [y] ");
  scanf ("%s", yes);
  if (toupper (yes[0]) == 'Q')
   {
    stat_OM = OM_I_STOP_SENDING;
    goto ret_end;
   }
  else if (toupper(yes[0]) != 'N')
  {
    if (ME.EMSedge->ed_props & EMED_REVERSED)
    {
      for (i=ME.EMSlinedge->num_points-1; i>=0; i--)
        fprintf (stderr, "\tPoint %2d) %5.12lf %5.12lf\n", i, 
        ME.EMSlinedge->points[i*2], ME.EMSlinedge->points[i*2+1]);
    }
    else
    {
      for (i=0; i<ME.EMSlinedge->num_points; i++)
        fprintf (stderr, "\tPoint %2d) %5.12lf %5.12lf\n", i, 
        ME.EMSlinedge->points[i*2], ME.EMSlinedge->points[i*2+1]);
    }
  }

ret_end:
  return (stat_OM);
}

end implementation EMSlinedge;
