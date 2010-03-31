/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include <stdio.h>
#include <ctype.h>
#include "emsdef.h"
#include "OMmacros.h"

extern OMuword	OPP_EMSpartedge_class_id, OPP_EMSlinedge_class_id, 
		OPP_EMSnatedge_class_id, OPP_EMSbsedge_class_id;
		
		
method debug()
{
  IGRchar errmsg[EMMAXERRMSG_LEN], yes[20], type[50];
  IGRint sts, i;
  IGRlong EMmsg;
  IGRlong    mthd_stat;
  struct IGRpolyline pygeom;
  FILE *fileptr;
  void EFget_string_for_edge_type();       
  IGRboolean is_iso = FALSE, is_linear = FALSE, is_natural = FALSE, 
             is_bs = FALSE;
  GRobjid		bottom_edge = NULL_OBJID;
  OMuword	bot_classid;

  pygeom.points = NULL;
  pygeom.num_points = 0;
  sts = EMS_S_Success;
  strcpy (errmsg, "EMSpartedge.debug");
  is_iso = ME.EMSedge->ed_props & EMED_ISO ? TRUE : FALSE;
 
/* Get my geometry
*/
   sts = om$send (msg = message EMSedge.EMgetpygeom (&mthd_stat,
			NULL, MAXINT, 0, NULL, &pygeom, NULL, NULL),
			targetid = my_id);
   if (!(1&sts&mthd_stat)) goto wrapup;

  sts = om$send (msg = message EMSedge.EMget_bottom_edge (&EMmsg,
                          &bottom_edge), targetid = my_id);
  if (!(1&sts)) goto wrapup;

  /* Partedge must have a path to the full edge to be able to lead a 
     fruitful and enjoyable life. 
  */
  if(IF_NULL_OBJID(bottom_edge))
   {sts = OM_E_ABORT; goto wrapup;}

  sts = om$get_classid(objid = bottom_edge, 
                               p_classid = &bot_classid);
  if( !(1&sts)) goto wrapup;

  if ( (sts = om$is_ancestry_valid (superclassid = OPP_EMSnatedge_class_id, 
		 subclassid = bot_classid)) == OM_S_SUCCESS)
   is_natural = TRUE;
  else if((sts = om$is_ancestry_valid (superclassid = OPP_EMSlinedge_class_id, 
		 subclassid = bot_classid)) == OM_S_SUCCESS)
   is_linear = TRUE;
  else if((sts = om$is_ancestry_valid (superclassid = OPP_EMSbsedge_class_id, 
		 subclassid = bot_classid)) == OM_S_SUCCESS)
   is_bs = TRUE;
  else {sts = OM_E_ABORT; goto wrapup;}
	
  {
     EFget_string_for_edge_type(ME.EMSedge->curve_type, type);
     if(is_natural) 
      fprintf (stderr, "Part natural edge:\n\tObjectid %d\n", my_id);
     else if(is_linear) 
      fprintf (stderr, "Part linear edge:\n\tObjectid %d\n", my_id);
     else if(is_bs) 
      fprintf (stderr, "Part BS edge:\n\tObjectid %d\n", my_id);

     fprintf (stderr, "\tProperties 0x%x\n", ME.EMSedge->ed_props);
     fprintf (stderr, "\tCurve Type %d -- %s\n", ME.EMSedge->curve_type, type);
     fprintf(stderr, "\tCreator %d\n", ME.EMSboundary->creator_id);
     if(is_iso)
      fprintf(stderr, "\tIso Edge\n");
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
       fprintf (fileptr, "%5.12lf %5.12lf\n",pygeom.points[i*2], pygeom.points[i*2+1]);
    fclose (fileptr);
   }
  else if (toupper (yes[0]) == 'Q')
   {
    sts = OM_I_STOP_SENDING;
    goto wrapup;
   }

  fprintf (stderr, "Show (logical)geometry on screen ? y/n [y] ");
  scanf ("%s", yes);
  if (toupper (yes[0]) == 'Q')
   {
    sts = OM_I_STOP_SENDING;
    goto wrapup;
   }
  else if (toupper(yes[0]) != 'N')
    {
      for (i=0; i<pygeom.num_points; i++)
        fprintf (stderr, "\tPoint %2d) %5.12lf %5.12lf\n", i, 
           pygeom.points[i*2], pygeom.points[i*2+1]);
    }

wrapup:

  if(pygeom.points) free(pygeom.points);
  return (sts);
}

end implementation EMSpartedge;
