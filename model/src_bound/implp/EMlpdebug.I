class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include <ctype.h>
#include "emsdef.h"
#include "emseligible.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern OMuword OPP_EMSptgralp_class_id, OPP_EMSopenloop_class_id, 
	       OPP_EMSgraloop_class_id;

from EMSedge import EMexecuteCurveFunction;
	
method debug()
{
  IGRboolean first_edge;
  IGRchar keyin, filename[20];
  IGRushort options;
  IGRint stat_OM, i, j;
  IGRuint inner_count, edge_count;
  IGRlong msg_loc;
  GRclassid my_class;
  struct IGRpolyline *poly;
  struct EMSinters *inters;
  struct EMSintobj *intobj;
  OM_S_CHANSELECT chan_to_inner, chan_to_edges;
  FILE *fileptr;
  extern void EMinters_data_free(), EMinters_free();
  extern IGRint EMcatcvdata();
  IGRshort mattyp;
  IGRmatrix mat;

  inters = NULL;

  stat_OM = om$get_classid(object = me, p_classid = &my_class);

  stat_OM = EMmake_chanselect (EMSloop_to_inner, &chan_to_inner);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (objid = my_id, p_chanselect =
             &chan_to_inner, count = &inner_count);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (objid = my_id, p_chanselect =
             &chan_to_edges, count = &edge_count);
  EMomerr_exit (stat_OM, ret_end);

  if (my_class == OPP_EMSptgralp_class_id)
    fprintf (stderr, "\nPoint Loop:\n\tObjectid %d\n", my_id);

  else if (my_class == OPP_EMSopenloop_class_id)
    fprintf (stderr, "\nOpen Loop:\n\tObjectid %d\n", my_id);

  else if (my_class == OPP_EMSgraloop_class_id)
    fprintf (stderr, "\nGraphic Loop:\n\tObjectid %d\n", my_id);

  else
    fprintf (stderr, "\nLoop:\n\tObjectid %d\n", my_id);

  fprintf (stderr, "\tProperties 0x%x\n", ME.EMSloop->lp_props);
  fprintf (stderr, "\tCreator %d\n", ME.EMSboundary->creator_id);
  fprintf (stderr, "\tRange min [%5.12lf, %5.12lf], max [%5.12lf %5.12lf]\n",
   ME.EMSloop->range[0], ME.EMSloop->range[1],
   ME.EMSloop->range[2], ME.EMSloop->range[3]);
  fprintf (stderr, "\tNumber of edges %d\n", edge_count);  
  fprintf (stderr, "\tNumber of child loops %d\n", inner_count);
  if (edge_count)
    {
    EFgetchar (stderr, "Write geometry to file y/n [n] ", &keyin);
    if (toupper (keyin) == 'Y')
      {
      fprintf (stderr, "Filename _: ");
      scanf ("%s", filename);
      fileptr = (FILE *) fopen (filename, "w");
      
      inters = NULL;
      first_edge = TRUE;
      options = EMSeligible_ParametricGeom;
      EMidmatrix(&msg_loc, &mattyp, mat);
      stat_OM = om$send (msg = message EMSedge.EMexecuteCurveFunction 
                 (&msg_loc, NULL, &mattyp, mat, NULL_OBJID, EMcatcvdata, 
                 (char *)&inters,
                 &first_edge, options), p_chanselect = &chan_to_edges);
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
      }
    else if (toupper (keyin) == 'Q')
      {
       stat_OM = OM_I_STOP_SENDING;
       goto ret_end;
      }

    EFgetchar (stderr, "Debug Edges? y/n [n] ", &keyin);
    if (toupper (keyin) == 'Y')
      {
      for (i=0; i<edge_count; i++)
        {
        stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_edges,
                   from = i, to = i);
        EMomerr_exit (stat_OM, ret_end);
	if(stat_OM == OM_I_STOP_SENDING) goto ret_end;
        }
      }
    else if (toupper (keyin) == 'Q')
      {
       stat_OM = OM_I_STOP_SENDING;
       goto ret_end;
      }
    }

  if (inner_count)
    {
    EFgetchar (stderr, "Debug Inner Loops? y/n [n] ", &keyin);
    if (toupper (keyin) == 'Y')
      {
      for (i=0; i<inner_count; i++)
        {
        fprintf (stderr, "\n\t...... Loop's-[%d] Inner Loop ......\n",my_id);
        stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_inner,
                   from = i, to = i);
        EMomerr_exit (stat_OM, ret_end);
        }
      fprintf (stderr, "\n\t...... End Of Loop-[%d] ......\n", my_id);
      }
    else if (toupper (keyin) == 'Q')
      {
       stat_OM = OM_I_STOP_SENDING;
       goto ret_end;
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

end implementation EMSloop;
