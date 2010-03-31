class implementation EMSloopset;

#include "EMS.h"
#include <stdio.h>
#include <ctype.h>
#include "emsdef.h"
#include "emseligible.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSedge import EMexecuteCurveFunction;

method debug()
{
  IGRboolean first_edge;
  IGRchar keyin, filename[20];
  IGRushort options;
  IGRint stat_OM, i, j;
  IGRuint count;
  IGRlong msg_loc, send_rc;
  struct IGRpolyline *poly;
  struct EMSinters *inters;
  struct EMSintobj *intobj;
  OM_S_CHANSELECT chan_to_loops;
  FILE *fileptr;
  extern void EMinters_data_free(), EMinters_free();
  extern IGRint EMcatcvdata();
  extern IGRboolean EMSplotUVspace;
  IGRshort mattyp;
  IGRmatrix mat;

  inters = NULL;

  stat_OM = EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (objid = my_id, p_chanselect =
             &chan_to_loops, count = &count);
  EMomerr_exit (stat_OM, ret_end);
   
  fprintf (stderr, "\nLoopset:\n\tObjectid %d\n", my_id);
  fprintf (stderr, "\tProperties 0x%x\n", ME.EMSloopset->ls_props);
  fprintf (stderr, "\tNumber of child loops %d\n", count);

  if (EMSplotUVspace) /* "z display UV space" */
  {
   fileptr = (FILE *) fopen("/tmp/uvplot", "w");
   strcpy ( filename, "uvplot" );
   goto plot;
  }

  if (count)
    {
    EFgetchar (stderr, "Write geometry to file y/n [n] ", &keyin);
    if (toupper (keyin) == 'Y')
      {
      fprintf (stderr, "Filename _: ");
      scanf ("%s", filename);
      fileptr = (FILE *) fopen (filename, "w");
    plot:      
      inters = NULL;
      first_edge = TRUE;
      options = EMSeligible_ParametricGeom;
      EMidmatrix(&msg_loc, &mattyp, mat);
      stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
                 message EMSedge.EMexecuteCurveFunction (&msg_loc, NULL,
                 &mattyp, mat, NULL_OBJID, EMcatcvdata, (char *)&inters,
                 &first_edge, options), MAXINT, 1, &OPP_EMSedge_class_id,
                 TRUE, NULL, NULL, NULL), p_chanselect = &chan_to_loops);
      EMomerr_exit (stat_OM, ret_end);

      intobj = inters->cvs;
      for (i=0; i<inters->num_cvs; i++)
        {
        poly = intobj->this_uvintobj.data.poly;
        fprintf (fileptr, "%d\n", poly->num_points);
        for (j=0; j<poly->num_points; j++)
          fprintf (fileptr, "%5.12lf %5.12lf\n",
           poly->points[j*2], poly->points[j*2+1]);
        intobj = intobj->next;
        }
      fprintf (stderr, "%d poly segments output in %s\n",
      inters->num_cvs, filename);
      fclose (fileptr);
      if(EMSplotUVspace) goto ret_end;
      }

    fprintf (stderr, "'q' at any Lp/Ed prompt to STOP for this surf\n");
    EFgetchar (stderr, "Continue? y/n [n] ", &keyin);
    if (toupper (keyin) == 'Y')
      {
      for (i=0; i<count; i++)
        {
        fprintf (stderr, "\n\t****** Loopset's-[%d] Child ******\n", my_id);
        stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_loops,
                   from =i, to = i);
        EMomerr_exit (stat_OM, ret_end);
        if(stat_OM == OM_I_STOP_SENDING) goto ret_end;
        }
      fprintf (stderr, "\n\t****** End Of Loopset ******\n");
      }
    }

ret_end:
  if (inters)
    {
    EMinters_data_free (&msg_loc, inters, MAXINT, NULL, NULL);
    EMinters_free (inters, MAXINT);
    }    
  return (stat_OM);
}

end implementation EMSloopset;
