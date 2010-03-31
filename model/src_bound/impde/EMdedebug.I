/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdumedge;

#include "EMS.h"
#include <stdio.h>
#include <ctype.h>
#include "emsdef.h"

extern OMuword	OPP_EMSdumedge_class_id;

method debug()
{
  IGRchar errmsg[EMMAXERRMSG_LEN], yes[20], type[50];
  IGRint stat_OM, i;
  IGRlong    mthd_stat;
  struct IGRpolyline pygeom;
  FILE *fileptr;
  void EFget_string_for_edge_type();
       

  pygeom.points = NULL;
  pygeom.num_points = 0;
  stat_OM = EMS_S_Success;
  strcpy (errmsg, "EMSdumedge.debug");
 
/* Get my geometry
*/
   stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&mthd_stat,
			NULL, MAXINT, FALSE, NULL, &pygeom, NULL, NULL),
			targetid = my_id);
   if (!(1&stat_OM&mthd_stat)) goto ret_end;

  {
     EFget_string_for_edge_type(ME.EMSedge->curve_type, type);
     fprintf (stderr, "\tDummy edge:\n\tObjectid %d\n", my_id);
     fprintf (stderr, "\tProperties 0x%x\n", ME.EMSedge->ed_props);
     fprintf (stderr, "\tCurve Type %d -- %s\n", ME.EMSedge->curve_type, type);
     fprintf (stderr, "\tBounds:\n");
     fprintf (stderr, "\t  begin: spaninx =%d	par=%5.12lf\n",
				ME.EMSpartedge->boundary[0].span_inx,
				ME.EMSpartedge->boundary[0].param);
     fprintf (stderr, "\t  end  : spaninx =%d	par=%5.12lf\n",
				ME.EMSpartedge->boundary[1].span_inx,
				ME.EMSpartedge->boundary[1].param);
   }

  fprintf (stderr, "Write (logical)geometry to file? y/n [n] ");
  scanf ("%s", yes);
  if (toupper (yes[0]) == 'Y')
  {
    fprintf (stderr, "Filename _: ");
    scanf ("%s", yes);
    fileptr = fopen (yes, "a");
    fprintf (fileptr, "%d\n", pygeom.num_points);
    for (i=0; i<pygeom.num_points; i++)
       fprintf (fileptr, "%5.12lf %5.12lf\n",pygeom.points[i*2], 
					     pygeom.points[i*2+1]);
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
      for (i=0; i<pygeom.num_points; i++)
        fprintf (stderr, "\tPoint %2d) %5.12lf %5.12lf\n", i, 
           pygeom.points[i*2], pygeom.points[i*2+1]);
    }

ret_end:

  if(pygeom.points) free(pygeom.points);
  return (stat_OM);
}

end implementation EMSdumedge;
