class implementation Root;

# include "EMS.h"
# include <stdio.h>
%safe
# include <math.h>
%endsafe
# include <string.h>
# include "madef.h"
# include "bsparameters.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "msdef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "emsdef.h"
# include "emserr.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "emssfint.h"
# include "EMSerrnumdef.h"
# include "EMSerrordef.h"
# include "OMmacros.h"

from EMSedge import EMgetpygeom;
from EMSsubbs import EMpartolbasis;

int prtinters (inters)
struct EMSinters *inters;
{
  IGRlong msg_loc, sts;
  IGRshort matrix_type;
  IGRmatrix matrix;
  IGRdouble partol, stroke_tol;
  IGRboolean world, success, dont_stroke;
  char filename[20];
  int prtdatapts, prtmoreinfo, modify, prtuvpy, loc_modify, modified;
  int i, inters_inx, intobj_inx;
  GRspacenum osnum;
  GRobjid objid;
  struct EMSintobj *intobj;
  FILE *prtfile, *datfile, *uvdatfile;
  void prtdat(), prtsfintedpar(), modintobj();
  
  printf ("Filename _: ");
  scanf ("%s", filename);
  datfile = fopen (filename, "w");
  if (!datfile)
    {
    fprintf (stderr, "Bad file name\n");
    return (FALSE);
    }

  printf ("Print data points (1/0) _: ");
  scanf ("%d", &prtdatapts);
  
  printf ("Print more info points (1/0) _: ");
  scanf ("%d", &prtmoreinfo);
  
  printf ("Option to modify intersection node (1/0) _: ");
  scanf ("%d", &modify);

  printf ("Option to write out uv-date to file (1/0) _: ");
  scanf ("%d", &prtuvpy);
  if (prtuvpy)
    {
    printf ("UV-data filename _: ");
    scanf ("%s", filename);
    uvdatfile = fopen (filename, "w");
    if (!uvdatfile)
      {
      fprintf (stderr, "Bad file name\n");
      return (FALSE);
      }
    }
  else
    uvdatfile = NULL;

  inters_inx = 0;
  while (inters)
    {
     success =  MAidmx(&msg_loc,(IGRdouble *)matrix);
     matrix_type = MAIDMX;
     world = TRUE;
     dont_stroke = FALSE;
     sts = om$send (msg=message EMSsubbs.EMpartolbasis (&msg_loc, 
                       &matrix_type, matrix, &world/*not used*/,
                       TRUE/*not used*/, &partol),
                    senderid = NULL_OBJID,
                    targetid = inters->this_obj.objid,
                    targetos = inters->this_obj.osnum);
     
     if (! (1 & sts & msg_loc))
     {
        fprintf (stderr, "Error getting parametric tolerance for surface %d\n",
                   inters->this_obj.objid);
        dont_stroke = TRUE;
     }
     else
     {  success = EFextract_par(BSTOLCHRDHT, partol, &stroke_tol, &msg_loc);
        if (!(1&msg_loc) || !success)
        {
          fprintf (stderr, "Error getting stroke tolerance for surface %d\n",
                   inters->this_obj.objid);
          dont_stroke = TRUE;
        }
     }

    fprintf (datfile, "%d) Surface [%d,%d] - npts %d, ncvs %d\n",
     inters_inx, inters->this_obj.objid, inters->this_obj.osnum,
     inters->num_pts, inters->num_cvs);
    if (modify)
      fprintf (stderr, "%d) Surface [%d,%d] - npts %d, ncvs %d\n",
       inters_inx, inters->this_obj.objid, inters->this_obj.osnum,
       inters->num_pts, inters->num_cvs);

    for (i=0; i<2; i++)
      {
      intobj = i==0 ? inters->pts : inters->cvs;
      intobj_inx = 0;
      if (modify)
        loc_modify = 1;
      else
        loc_modify = 0;
      while (intobj)
        {
        if (loc_modify)
          prtfile = stderr;
        else
          prtfile = datfile;

        fprintf (prtfile, "\t Intersection %d, address 0x%x\n",
         intobj_inx, intobj);
        fprintf (prtfile, "\t Reversed %d\n\t Props 0x%x \n",
         intobj->reversed, intobj->props);
	fprintf (prtfile, "\t Fwd : 0x%x    Bwd : 0x%x\n", 
	 intobj->fwd, intobj->bwd);
        objid = intobj->this_obj_node->this_obj.objid;
        osnum = intobj->this_obj_node->this_obj.osnum;
        if (objid != inters->this_obj.objid ||osnum != inters->this_obj.osnum)
          fprintf (prtfile, "\t Link back WRONG [%d, %d]\n", objid, osnum);
        if (intobj->other_intobj_node)
          {
          objid = intobj->other_intobj_node->this_obj_node->this_obj.objid;
          osnum = intobj->other_intobj_node->this_obj_node->this_obj.osnum;
          }
        else
          {
          objid = NULL_OBJID;
          osnum = 99;
          }
        fprintf (prtfile, "\t Other object [%d, %d], other node 0x%x\n",
         objid, osnum, intobj->other_intobj_node);
        
        fprintf (prtfile, "\t xyz:\n");
        prtdat (prtfile, &intobj->this_xyzintobj, FALSE,
         prtdatapts, NULL, NULL);

        /* send stroke tol only if necessary (NP 4/23/93)*/

        fprintf (prtfile, "\t uv:\n");
        if (intobj->this_uvintobj.datatype == EMSdata_curve3d)
        { 
         prtdat (prtfile, &intobj->this_uvintobj, FALSE,
                prtdatapts, uvdatfile, dont_stroke? NULL : &stroke_tol);
        }
        else
        {
           prtdat (prtfile, &intobj->this_uvintobj, FALSE, 
                        prtdatapts, uvdatfile, NULL);
        }

        if (prtmoreinfo)
          {
          fprintf (prtfile, "\t more:\n");
          if (intobj->more_info)
            {
            prtsfintedpar (prtfile, 9, intobj->more_info);
            if (((struct EMSsfintedpar *) intobj->more_info)->next)
              prtsfintedpar (prtfile, 9,
               ((struct EMSsfintedpar *) intobj->more_info)->next);
            }
          }
        fprintf (prtfile, "\n");

        if (loc_modify)
          {
          modintobj (&intobj, &modified);
          if (modified)
            fprintf (stderr, "Repeating this intobj....\n");
          else
            loc_modify = FALSE;
          }
        else
          {
          intobj = intobj->next; 
          intobj_inx++;
          if (modify)
            loc_modify = TRUE;
          }
        }
      if (intobj_inx)
        fprintf (stderr, "%d) %d intobjs on %d\n", inters_inx, intobj_inx,
         inters->this_obj.objid);
      }
    inters = inters->next;
    inters_inx++;
    }
  fprintf (datfile, "Total of %d intersecting surfaces\n", inters_inx);
  if (modify)
    fprintf (stderr, "Total of %d intersecting surfaces\n", inters_inx);
  if(uvdatfile) fclose(uvdatfile);
  fclose (datfile);
  return(1);
}

/* NOTE: "moredatfile" and "stroke_tol" should always be NULL for model space
 * ----  data (i.e. XYZ).
 */
void prtdat (datfile, datasel, rev, prtpts, moredatfile, stroke_tol)
FILE *datfile;
struct EMSdataselect *datasel;
IGRboolean rev, prtpts;
FILE *moredatfile;
IGRdouble *stroke_tol;
{
  union EMSdata data;
  IGRint i, num_pts, dim;
  IGRlong msg_loc;
  IGRdouble *pt1, *pt2, *pts, par;
  IGRboolean success;
  struct IGRpolyline poly;
  struct EMSpartolbasis partolbasis;
  enum EMSdatatype datatype;

  /* I dont know why "prtpts" parameter has never been used in this function,
   * but I am writing a dummy line to prevent compiler warnings. (NP)
   */
  prtpts = prtpts;
  
  data = datasel->data;
  datatype = datasel->datatype;
  if (datatype == EMSdata_null)
    fprintf (datfile, "\t  NULL data\n");
  else if (datatype == EMSdata_object)
    {
    fprintf (datfile, "\t  Data object\n");
    fprintf (datfile, "\t   [%d, %d]\n",
     data.object->objid, data.object->osnum);
    if (moredatfile)
      {
      poly.num_points = 0;
      poly.points = NULL;
      partolbasis.is_valid = TRUE;
      partolbasis.tol = 0.00001;
      om$send (msg = message EMSedge.EMgetpygeom (&msg_loc, 0, MAXINT,
       FALSE, NULL, &poly, &partolbasis, NULL), targetid = data.object->objid,
       targetos = data.object->osnum, senderid = NULL_OBJID);
      if (poly.num_points &&  poly.points)
        {
        pywritefunk (moredatfile, 2, poly.num_points, poly.points);
        om$dealloc (ptr = poly.points);
        }
      }
    }
  else if (datatype == EMSdata_poly2d || datatype == EMSdata_poly3d)
    {
    if (datatype == EMSdata_poly2d)
      {
      dim = 2;
      fprintf (datfile, "\t  Data poly-2D\n");
      }
    else
      { 
      dim = 3;
      fprintf (datfile, "\t  Data poly-3D\n");
      }
    pts = data.poly->points;
    num_pts = data.poly->num_points;
    fprintf (datfile, "\t   Num points %d\n", num_pts);
    pt1 = rev ? &pts[(num_pts-1)*dim] : pts;
    pt2 = rev ? pts : &pts[(num_pts-1)*dim];
    if (dim == 2)
      {
      fprintf (datfile, "\t    start: %lf %lf\n", pt1[0], pt1[1]);
      fprintf (datfile, "\t    stop : %lf %lf\n", pt2[0], pt2[1]);
      if (moredatfile)
        pywritefunk (moredatfile, 2, num_pts, pts);
      }
    else
      {
      fprintf (datfile, "\t    start: %lf %lf %lf\n", pt1[0], pt1[1], pt1[2]);
      fprintf (datfile, "\t    stop : %lf %lf %lf\n", pt2[0], pt2[1], pt2[2]);
      }
    }
  else if (datatype == EMSdata_curve2d || datatype == EMSdata_curve3d)
    {
    if (datatype == EMSdata_curve2d)
      fprintf (datfile, "\t  Data curve-2D\n");
    else
      fprintf (datfile, "\t  Data curve-3D\n");
    fprintf (datfile, "\t   Order %d, num_poles %d, rational %d\n",
     data.curve->order, data.curve->num_poles, data.curve->rational);
    if(datatype == EMSdata_curve3d)
     {
      IGRdouble	start_pts[3], stop_pts[3];
      IGRint	sts, msg, EMgetendpts_xyz();

      pt1 = start_pts;
      pt2 = stop_pts;
      sts = EMgetendpts_xyz (&msg, NULL, NULL, datasel, rev, 1, pt1, pt2);
      if(1 & sts & msg)
       {
        fprintf (datfile, "\t    start: %lf %lf %lf\n", pt1[0], pt1[1], 
							pt1[2]);
        fprintf (datfile, "\t    stop : %lf %lf %lf\n", pt2[0], pt2[1], 
							pt2[2]);
       }
       
       /***********************************************************************/
       /* make sure that XYZ data will not be printed to moreinfo file, by 
        * sending in NULL for "moredatfile" for "this_xyzintobj". This is 
        * because there is no way to differentiate between UV and XYZ 
        * data in here (unlike the poly2D/poly3D case). (NP 4/23/93).
        */
       if (moredatfile && stroke_tol)
       {

           success = EFstroke_the_curve (data.curve,stroke_tol,&poly,&msg_loc);
           
           if (!(1&msg_loc) || !success)
           {
              fprintf (stderr, "Error stroking curve3d dataselect \n");
           }
           else
           {

             num_pts = poly.num_points;
             pts = (IGRdouble *) (poly.points);
  
             /* compress the 3D polyline array into 2D, by dropping the Z dim*/
             EM3dto2d (pts, num_pts);
  
            /* Make doubly sure that the stroked points are within parametric
             * space.
             */
             for (i=0 ; i< 2*num_pts; i++)
             {
                par = pts[i];
                if (par < 0.0)
                  par = 0.0;
                else if (par > 1.0)
                  par = 1.0;
                pts[i] = par;
             }
          
             pywritefunk (moredatfile, 2, num_pts, pts);
  
           }

           if (poly.points)
             free(poly.points); /* alloced by "EFstroke_the_curve"*/

       }
       /***********************************************************************/
     }

    }
}

void prtsfintedpar (datfile, lead_blanks, edpar)
FILE *datfile;
IGRint lead_blanks;
struct EMSsfintedpar *edpar;
{
    int i;
    char str[40];
    
    strcpy (str, "");
    for (i=0; i<lead_blanks; i++)
      strcat (str, " ");

    fprintf (datfile, "%sEdge %d\n", str, edpar->edgeid);
 
    if (edpar->edgeid != NULL_OBJID)
      {
      if (edpar->intloc == EMScvint_middle)
        fprintf (datfile, "%sLocation middle\n", str);
      else if (edpar->intloc == EMScvint_lfend)
        fprintf (datfile, "%sLocation lfend\n", str);
      else if (edpar->intloc == EMScvint_rtend)
        fprintf (datfile, "%sLocation rtend\n", str);
      else
        fprintf (datfile, "%sBad Location\n", str);

      fprintf (datfile, 
       "%s edgepar: pt [%lf %lf]\n%s          par %lf, span %d\n", str, 
       edpar->point[0], edpar->point[1], str, edpar->edgepar.param,
       edpar->edgepar.span_inx);
      fprintf (datfile, "%s Info 0x%x\n", str, edpar->info);
      }
}

void modintobj (p_intobj, modified)
struct EMSintobj **p_intobj;
int *modified;
{
  IGRchar resp;
  IGRint inx, input;
  IGRint objid1, objid2;
  IGRlong msg_loc;
  IGRdouble p;
  struct EMSsfintedpar *edpar, *tmp_edpar;
  struct EMSintobj *intobj;
  struct EMSintobj *EMdelintobj();

  intobj = *p_intobj;
  EFgetchar (stderr, "Want to modify this node? y/[n] _: ", &resp);
  if (toupper (resp) == 'Y')
    {
    EFgetchar (stderr, "Flip boundary params y/[n] _: ", &resp);
    if (toupper (resp) == 'Y')
      {
      edpar = (struct EMSsfintedpar *)intobj->more_info;
      tmp_edpar = edpar->next;
      intobj->more_info = (IGRchar *) tmp_edpar;
      edpar->next = edpar->next->next;
      tmp_edpar->next = edpar;
      }

    EFgetchar (stderr, "Toggle reverse flag y/[n] _: ", &resp);
    if (toupper (resp) == 'Y')
      intobj->reversed = !intobj->reversed;

    EFgetchar (stderr, "New incident edge ids: y/[n] _: ", &resp);
    if (toupper (resp) == 'Y')
      {
      printf ("edge id1 [0 for NULL_OBJID] _: ");
      scanf ("%d", &objid1);
      if (objid1 == 0)
        objid1 = NULL_OBJID;
      printf ("edge id2 [0 for NULL_OBJID] _: ");
      scanf ("%d", &objid2);
      if (objid2 == 0)
        objid2 = NULL_OBJID;
      edpar = (struct EMSsfintedpar *)intobj->more_info;
      edpar->edgeid = objid1;
      edpar->next->edgeid = objid2;
      }

    EFgetchar (stderr, "New Split params: y/[n] _: ", &resp);
    if (toupper (resp) == 'Y')
      {
      edpar = (struct EMSsfintedpar *)intobj->more_info;
      if(!IF_NULL_OBJID(edpar->edgeid))
       {
        printf ("edge1 param [spaninx param] _: ");
        scanf ("%d %lf", &inx, &p);
        edpar->edgepar.span_inx = inx;
        edpar->edgepar.param = p;
       }
      edpar = edpar->next;
      if(!IF_NULL_OBJID(edpar->edgeid))
       {
        printf ("edge2 param [spaninx param] _: ");
        scanf ("%d %lf", &inx, &p);
        edpar->edgepar.span_inx = inx;
        edpar->edgepar.param = p;
       }
      }

    EFgetchar (stderr, "New props: y/[n] _: ", &resp);
    if (toupper (resp) == 'Y')
      {
      printf ("Current props - (0x%x), change to _: 0x", intobj->props);
      scanf ("%x", &input);
      intobj->props = input;
      }

    EFgetchar (stderr, "New Fwd pointer: y/[n] _: ", &resp);
    if (toupper (resp) == 'Y')
      {
      printf ("Current Fwd - (0x%x), change to _: 0x", intobj->fwd);
      scanf ("%x", &input);
      intobj->fwd = (struct EMSintobj *) input;
      }

    EFgetchar (stderr, "New Bwd pointer: y/[n] _: ", &resp);
    if (toupper (resp) == 'Y')
      {
      printf ("Current Bwd - (0x%x), change to _: 0x", intobj->bwd);
      scanf ("%x", &input);
      intobj->bwd = (struct EMSintobj *) input;
      }

    *modified = TRUE;
    }
  else
    {
    EFgetchar (stderr, "Want to delete this node: y/[n] _: ", &resp);
    if (toupper (resp) == 'Y')
      *p_intobj = EMdelintobj (&msg_loc, intobj);
    *modified = FALSE;
    }
}

end implementation Root;
