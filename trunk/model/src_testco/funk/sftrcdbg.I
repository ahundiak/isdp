class implementation EMSedge;

#include "EMS.h"
#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfint.h"
#include "emssfintdef.h"
#include "emsdef.h"
#include "emserr.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

IGRboolean sfinttrace_dbg (mattyp, mat, num_grps, num_subgrps_grp,
                           num_elems_subgrp, elems, subgrp_rev, elem_rev,
                           grp_closed, subgrp_closed)

IGRshort *mattyp; /* Can be NULL (for identity matrix) */
IGRmatrix mat; /* Can be NULL (for identity mattrix) */
IGRint num_grps, *num_subgrps_grp, **num_elems_subgrp;
struct EMSintobj ***elems;
IGRboolean **subgrp_rev, ***elem_rev, *grp_closed, **subgrp_closed;
{
  IGRboolean endinfo;
  IGRchar filename1[50], filename2[50], string[50];
  IGRshort mattyp_loc;
  IGRint i, j, k, l, startnum, stopnum, num_rows, num_points, len;
  IGRlong stat_OM, msg_loc;
  IGRdouble pt[3], dumpt[3], *mat_loc, *points;
  IGRmatrix mat_loc_mem;
  struct EMSintobj *elem;
  struct IGRpolyline poly;
  FILE *datfile, *datfile_grp;
  void EMidmatrix();
  IGRint prtsfintedpar();

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  poly.points = NULL;

  getfilename:
  printf ("Statistics output file (or type '[no]ne') _: ");
  scanf ("%s", filename1);
  if (toupper (filename1[0]) == 'N' && toupper (filename1[1]) == 'O')
    goto ret_end;
  else
    {
    len = strlen (filename1);
    for (i=len-1; i>=0; i--)
      {
      if (filename1[i] == '/')
        break;
      }
    if (len-i-1 > 9)
      {
      printf ("Filename should be 9 characters or less\n");
      goto getfilename;
      }
    else if (! (datfile = fopen (filename1, "w")))
      {
      printf ("Bad file name\n");
      goto getfilename;
      }
    }

  if (!mattyp || !mat)
    {
    mat_loc = mat_loc_mem;
    EMidmatrix (&msg_loc, &mattyp_loc, mat_loc);
    }
  else
    {
    mat_loc = mat;
    mattyp_loc = *mattyp;
    }
    
  printf ("End-point information wanted y/n _: ");
  scanf ("%s", string);
  if (toupper (string[0]) == 'N')
    endinfo = FALSE;
  else
    endinfo = TRUE;

  strcpy (filename2, filename1);
  strcat (filename2, "Grps");
  printf ("UV-data for these groups, output in %s\n", filename2);
  datfile_grp = fopen (filename2, "w");

  fprintf (datfile, "Number of groups _: %d\n", num_grps);
  startnum = 1;
  for (i=0; i<num_grps; i++)
    {
    fprintf (datfile, "Grp %d)\n", i+1);
    if (grp_closed[i])
      fprintf (datfile, "  Closed in model-space.\n");
    else
      fprintf (datfile, "  Open in model-space.\n");
    fprintf (datfile, "  Number of sub-groups _: %d\n", num_subgrps_grp[i]);

    fprintf (datfile, "  {\n   Info for this group in datafile %s:\n",
     filename2);
    for (j=0; j<num_subgrps_grp[i]; j++)
      {
      stopnum = startnum + num_elems_subgrp[i][j] - 1;
      fprintf (datfile, "   Linestrs %d - %d for subgrp %d, on surface %d\n", 
       startnum, stopnum, j+1, elems[i][j]->this_obj_node->this_obj.objid);
      startnum = stopnum + 1;
      }
    fprintf (datfile, "  }\n\n");

    if (!endinfo)
      continue;

    for (j=0; j<num_subgrps_grp[i]; j++)
      {
      fprintf (datfile, "  Subgrp %d)\n", j+1);
      if (subgrp_closed[i][j])
        fprintf (datfile, "    Closed in uv-space.");
      else
        fprintf (datfile, "    Open in uv-space.");
      if (subgrp_rev[i][j])
        fprintf (datfile, " Reversed.\n");
      else
        fprintf (datfile, "\n");

      elem = elems[i][j];
      fprintf (datfile, "    Surface id _: %d\n", 
               elem->this_obj_node->this_obj.objid);
      fprintf (datfile, "    Number of elements _: %d\n", 
               num_elems_subgrp[i][j]);
      for (k=0; k<num_elems_subgrp[i][j]; k++)
        {
        fprintf (datfile, "    Elem %d)\n", k+1);
        if (elem_rev[i][j][k])
          fprintf (datfile, "      Reversed.\n");
        fprintf (datfile, "      Other surface _: %d\n", 
          elem->other_intobj_node->this_obj_node->this_obj.objid);
        fprintf (datfile, "      Props 0x%x\n", elem->props);
        if (k == 0)
          {
          fprintf (datfile, "      Free subgrp start:\n");

          stat_OM = EMgetendpts_uv (&msg_loc, &elem->this_uvintobj, 
                     elem->reversed, 1, pt, dumpt);
          EMomerr_exit (stat_OM & msg_loc, ret_end);
          fprintf (datfile, "        %5.12lf %5.12lf\n", pt[0], pt[1]);

          stat_OM = EMgetendpts_xyz (&msg_loc, &mattyp_loc, mat_loc, 
                     &elem->this_xyzintobj, elem->reversed, 1,
                     pt, dumpt);
          EMomerr_exit (stat_OM & msg_loc, ret_end);
          fprintf (datfile, "        %5.12lf %5.12lf %5.12lf\n", 
                   pt[0], pt[1], pt[2]);
          if (elem->more_info)
            {
            fprintf (datfile, "        Incidence info:\n");
            if (elem->reversed)
              prtsfintedpar (datfile, 10,
               ((struct EMSsfintedpar *) elem->more_info)->next);
            else
              prtsfintedpar (datfile, 10, elem->more_info);
            }
          }
        if (k == num_elems_subgrp[i][j]-1)
          {
          fprintf (datfile, "      Free subgrp stop:\n");

          stat_OM = EMgetendpts_uv (&msg_loc, &elem->this_uvintobj, 
                     elem->reversed, 1, dumpt, pt);
          EMomerr_exit (stat_OM & msg_loc, ret_end);
          fprintf (datfile, "        %5.12lf %5.12lf\n", pt[0], pt[1]);

          stat_OM = EMgetendpts_xyz (&msg_loc, &mattyp_loc, mat_loc, 
                     &elem->this_xyzintobj, elem->reversed, 1,
                     dumpt, pt);
          EMomerr_exit (stat_OM & msg_loc, ret_end);
          fprintf (datfile, "        %5.12lf %5.12lf %5.12lf\n", 
                   pt[0], pt[1], pt[2]);
          if (elem->more_info)
            {
            fprintf (datfile, "        Incidence info:\n");
            if (elem->reversed)
              prtsfintedpar (datfile, 10, elem->more_info);
            else
              prtsfintedpar (datfile, 10,
               ((struct EMSsfintedpar *) elem->more_info)->next);
            }
          fprintf (datfile, "\n");
          }
    
        if (elem->this_uvintobj.datatype == EMSdata_object)
          {
          stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&msg_loc,
                     0, MAXINT, elem->reversed, NULL, &poly, NULL, NULL),
                     targetid = elem->this_uvintobj.data.object->objid,
                     targetos = elem->this_uvintobj.data.object->osnum,
                     senderid = NULL_OBJID);
          EMomerr_exit (stat_OM & msg_loc, ret_end);
          num_points = poly.num_points;
          points = poly.points;
          }
        else if (elem->this_uvintobj.datatype == EMSdata_poly2d)
          {
          num_points = elem->this_uvintobj.data.poly->num_points;
          points = elem->this_uvintobj.data.poly->points;
          }
        else
          fprintf (datfile_grp, "Data cannot be printed.\n");

        if (num_points)
          fprintf (datfile_grp, "%d\n", num_points);
        for (l=0; l<num_points*2; l+=2)
          fprintf (datfile_grp, "%7.12lf %7.12lf\n", points[l], points[l+1]);
        if (poly.points)
          om$dealloc (ptr = poly.points);
        poly.points = NULL;

        elem = elem->next;
        }
      }
    }
  fclose (datfile_grp);
  fclose (datfile);

ret_end:
  if (poly.points)
    om$dealloc (ptr = poly.points);

  if (EMSerror (stat_OM & msg_loc))
    fprintf (stderr, "Error in EMsftrcdbg\n");
  return (!EMSerror (stat_OM & msg_loc));
}

end implementation EMSedge;
