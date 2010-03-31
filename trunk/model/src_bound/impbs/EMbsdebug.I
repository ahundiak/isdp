/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include <stdio.h>
#include <ctype.h>
#include "emsdef.h"

method debug()
{
  IGRchar errmsg[EMMAXERRMSG_LEN], yes[20], type[50];
  IGRint stat_OM, i;
  IGRlong msg_loc;
  struct IGRbsp_curve uvcurve;
  void EFget_string_for_edge_type();

  FILE *fileptr;

  uvcurve.poles = NULL;
  uvcurve.knots = NULL;
  uvcurve.weights = NULL;
  uvcurve.bdrys = NULL;

  stat_OM = EMS_S_Success;
  strcpy (errmsg, "EMSbsedge.debug");
  EFget_string_for_edge_type(ME.EMSedge->curve_type, type);
  fprintf (stderr, "\nBS edge:\n\tObjectid %d\n", my_id);
  fprintf (stderr, "\tEdge properties 0x%x\n", ME.EMSedge->ed_props);
  fprintf (stderr, "\tBS properties 0x%x\n", ME.EMSbsedge->bs_props);
  fprintf (stderr, "\tCurve Type %d -- %s\n", ME.EMSedge->curve_type, type);
  fprintf (stderr, "\tCreator %d\n", ME.EMSboundary->creator_id);

  fprintf (stderr, "Write (logical) geometry to file? y/n [y] ");
  scanf ("%s", yes);
  if (toupper (yes[0]) == 'Y')
  {
       IGRlong   mthd_stat;
       struct IGRpolyline pygeom;
       
       pygeom.points = NULL;

       fprintf (stderr, "Filename _: ");
       scanf ("%s", yes);
       fileptr = fopen (yes, "a");

       stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&mthd_stat,
                            NULL, MAXINT, 0, NULL, &pygeom, NULL, NULL),
                            targetid = my_id);
       if (!(1&stat_OM&mthd_stat)) goto ret_end;

       fprintf (fileptr, "%d\n", pygeom.num_points);
       for (i=0; i<pygeom.num_points; i++)
           fprintf (fileptr, "%5.20lf %5.20lf\n",
             pygeom.points[i*2], pygeom.points[i*2+1]);
       fclose (fileptr);
  }
 else if (toupper (yes[0]) == 'Q')
  {
   stat_OM = OM_I_STOP_SENDING;
   goto ret_end;
  }

  fprintf (stderr, "Show (logical) geometry on screen ? y/n [y] ");
  scanf ("%s", yes);
 if (toupper (yes[0]) == 'Q')
  {
   stat_OM = OM_I_STOP_SENDING;
   goto ret_end;
  }
  else if (toupper(yes[0]) != 'N')
  {
    stat_OM = om$send (msg = message EMSbsedge.EMgetbcgeom
                     (&msg_loc,0, 1,FALSE,NULL, &uvcurve, NULL, NULL),
                    targetid = my_id);
    if (!(1&stat_OM&msg_loc))goto ret_end;

    fprintf(stderr,"no_of_poles %d\n", uvcurve.num_poles);
    fprintf(stderr,"no_of_knots %d\n", uvcurve.num_knots);
    fprintf(stderr,"order rational periodic %d %d %d \n", 
                     uvcurve.order, uvcurve.rational,
                     uvcurve.periodic);

    fprintf (stderr,"\n The poles are \n");

    for (i=0; i<uvcurve.num_poles; i++)
      fprintf (stderr, "%5.20lf %5.20lf\n",
        uvcurve.poles[3*i], uvcurve.poles[3*i + 1]);
    fprintf(stderr,"\n The knots are \n");

    for (i=0; i<uvcurve.num_knots; i++)
      fprintf (stderr, "%5.20lf \n",
        uvcurve.knots[i]);
    if (uvcurve.rational)
     {
      fprintf(stderr, "The weights are \n");
     for (i=0; i < uvcurve.num_poles; i++)
      fprintf(stderr,"%5.20lf \n", uvcurve.weights[i]);
     }
  }

ret_end:
  if (uvcurve.poles) free (uvcurve.poles);
  if (uvcurve.knots) free (uvcurve.knots);
  if (uvcurve.weights) free (uvcurve.weights);
  if (uvcurve.bdrys) free (uvcurve.bdrys);

  return (stat_OM);
}

end implementation EMSbsedge;
