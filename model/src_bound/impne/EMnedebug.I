/* ###################   APOGEE COMPILED   ################## */
class implementation EMSnatedge;

#include <stdio.h>
#include <ctype.h>

method debug()
{
  IGRchar errmsg[EMMAXERRMSG_LEN], yes[20], type[50];
  IGRint stat_OM, i;
  IGRlong msg_loc;
  FILE *fileptr;
  void EFget_string_for_edge_type();

  stat_OM = EMS_S_Success;
  strcpy (errmsg, "EMSnatedge.debug");

  EFget_string_for_edge_type(ME.EMSedge->curve_type, type);
  fprintf (stderr, "\nNatural edge:\n\tObjectid %d\n", my_id);
  fprintf (stderr, "\tProperties 0x%x\n", ME.EMSedge->ed_props);
  fprintf (stderr, "\tCurve Type %d -- %s\n", ME.EMSedge->curve_type, type);
  fprintf (stderr, "\tCreator %d\n", ME.EMSboundary->creator_id);
  fprintf (stderr, "\tLocation:\n\t %d\n",ME.EMSnatedge->location & 0x3);


  fprintf (stderr, "Write geometry to file? y/n [n] ");
  scanf ("%s", yes);
  if (toupper(yes[0]) == 'Y')
  {
    IGRint  num_points = 2;
    IGRdouble points[4];
    void      EMnatpoints();

    EMnatpoints(&msg_loc, ME.EMSnatedge->location & 0x3, points);

    fprintf (stderr, "Filename _: ");
    scanf ("%s", yes);
    fileptr = fopen (yes, "a");
    fprintf (fileptr, "%d\n", num_points);
    for (i=0; i<num_points; i++)
      fprintf (fileptr, "%lf %lf\n",points[i*2], points[i*2+1]);
    fclose (fileptr);
  }
  else if (toupper (yes[0]) == 'Q')
   stat_OM = OM_I_STOP_SENDING;

ret_end:
  return (stat_OM);
}

end implementation EMSnatedge;
