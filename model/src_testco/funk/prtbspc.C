#include "EMS.h"
#include <stdio.h>
#include <math.h>

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif
# include "emsdattyp.h"

# include "grdpbdef.h"
# include "grdpbmacros.h"

# include "wanginc.h"

struct EMSedgebound
{
  IGRdouble param;    
                     
  IGRshort span_inx; 
};

/* end of gr.h replacement */

/* ************************************************************************

   Following is a list of debug functions:

   prtbspc - prints a bspline curve to a specified file.
   prtbsps - prints a bspline surface to a specified file.
   prted   - prints a EMSsfintedpar structure to a given file
   prtpy   - prints a EMSpypoint structure to a given file

History
   PP : 01/01/88 Creation
   gupta : 08/11/89 added outtng fro massprops tiler dumping      
  Sudha  : 07/02/93 Modified for BSprototypes ansification
********************************************************************** */
#include "emsinter.h"
#include "emssfint.h"
#include "emserr.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsprintbsps.h"
#include "bsprintbspc.h"
#include "bsnorvec.h"


int prtbsps (surf)
struct IGRbsp_surface *surf;
{
  char filename[20];
  FILE *datfile;
  IGRboolean bssts;
  
  printf ("Filename _: ");
  scanf ("%s", filename);
  datfile = fopen (filename, "w");
  bssts = BSprintbsps (datfile, NULL, surf, FALSE);
  fclose (datfile);
  return (1);
}


int prtbsps_def (srf)
struct IGRbsp_surface *srf;
{
  char filename[20];
  FILE *datfile;
  
  printf ("Filename _: ");
  scanf ("%s", filename);
  if (!strcmp (filename, "."))
    datfile = stderr;
  else
    datfile = fopen (filename, "w");
  if (!datfile)
    return (0);

  fprintf (datfile, "U and V order : %d %d\n",
   srf->u_order, srf->v_order);
  fprintf (datfile, "U and V periodic : %d %d\n",
   srf->u_periodic, srf->v_periodic);
  fprintf (datfile, "U and V non-uniform : %d %d\n",
   srf->u_non_uniform, srf->v_non_uniform);
  fprintf (datfile, "U and V num-poles : %d %d\n",
   srf->u_num_poles, srf->v_num_poles);
  fprintf (datfile, "U and V num-knots : %d %d\n",
   srf->u_num_knots, srf->v_num_knots);
  fprintf (datfile, "U and V phy-closed : %d %d\n",
   srf->u_phy_closed, srf->v_phy_closed);
  fprintf (datfile, "Rational : %d\n",
   srf->rational);
  fprintf (datfile, "Planar : %d\n",
   srf->planar);
  fprintf (datfile, "Pos-orient : %d\n",
   srf->pos_orient);
  fprintf (datfile, "On-off : %d\n",
   srf->on_off);

  if (datfile != stderr)
    fclose (datfile);
  return (1);
}

void prtbspc (curve)
struct IGRbsp_curve *curve;
{
  char filename[20];
  FILE *datfile;
  IGRboolean bssts;
  
  printf ("Filename _: ");
  scanf ("%s", filename);
  datfile = fopen (filename, "w");
  bssts = BSprintbspc (datfile, NULL, curve, FALSE);
  fclose (datfile);
}

void prtpy(pypoint)
struct EMSpypoint *pypoint;
{
 FILE *datfile;
 struct EMSpypoint *ptr;
 char filename[20];
 IGRint count;

 printf("Filename :");
 scanf("%s", filename);
 datfile = fopen(filename,"w");

 ptr = pypoint;
 count = 1;
 while (ptr != NULL)
 {
  fprintf (datfile, "\n%d) address %x\n", count, ptr);
  fprintf (datfile," uv point %.15f %.15f \n", ptr->point[0], ptr->point[1]);
  fprintf (datfile," param spanindx %.15f %d \n", ptr->param,ptr->span_inx);
  fprintf (datfile," props %x \n", ptr->props);
  fprintf (datfile," info %x \n", ptr->info);
  count ++;
  ptr = ptr->next;
 }
 fclose(datfile);

 datfile = stderr;
 ptr = pypoint;
 count = 1;
 while (ptr != NULL)
 {
  fprintf (datfile, "\n%d) address %x\n", count, ptr);
  fprintf (datfile," uv point %.15f %.15f \n", ptr->point[0], ptr->point[1]);
  fprintf (datfile," param spanindx %.15f %d \n", ptr->param,ptr->span_inx);
  fprintf (datfile," props %x \n", ptr->props);
  fprintf (datfile," info %x \n", ptr->info);
  count ++;
  ptr = ptr->next;
 }
return;
}

void prted(edpar)
struct EMSsfintedpar *edpar;
{
 FILE *datfile;
 struct EMSsfintedpar *ptr;
 char filename[20];
 IGRint count;
 printf("Filename :");
 scanf ("%s", filename);
 datfile = fopen (filename,"w");

 ptr = edpar;
 count = 1;
 while (ptr != NULL)
 {
  fprintf (datfile, "\n%d) address %x\n", count, ptr);
  fprintf (datfile, "intloc %d \n", ptr->intloc);
  fprintf (datfile, "edgeid %d \n", ptr->edgeid);
  fprintf (datfile, "edgepar %d %.15f \n", ptr->edgepar.span_inx,
                                           ptr->edgepar.param);
  fprintf (datfile, "Point %.15f %.15f \n", ptr->point[0], ptr->point[1]);
  fprintf (datfile, "info %x \n", ptr->info);
  ptr = ptr->next;
  count ++;
 }
 fclose(datfile);

 datfile = stderr;
 ptr = edpar;
 count = 1;
 while (ptr != NULL)
 {
  fprintf (datfile, "\n%d) address %x\n", count, ptr);
  fprintf (datfile, "intloc %d \n", ptr->intloc);
  fprintf (datfile, "edgeid %d \n", ptr->edgeid);
  fprintf (datfile, "edgepar %d %.15f \n", ptr->edgepar.span_inx,
                                           ptr->edgepar.param);
  fprintf (datfile, "Point %.15f %.15f \n", ptr->point[0], ptr->point[1]);
  fprintf (datfile, "info %x \n", ptr->info);
  ptr = ptr->next;
  count ++;
 }

 return;
}

void prtfct(surf_data,output_to_db)
struct BNsf_data *surf_data;
{
 char filename[20];
 FILE *datfile;
 IGRlong		i, j, k,facet_id, patch_cnt;
 IGRshort		*facet_map;
 struct BNpatch	*patch_data;
 struct Facetloop 	*loop_data;
 

 printf("Filename: ");
 scanf("%s", filename);
 datfile = fopen(filename,"a");

 fprintf (datfile, "**************************************** \n\n");

 fprintf(datfile,"Total Num patch %d \n", surf_data->n_pat);

  for(patch_cnt=0; patch_cnt < surf_data->n_pat; patch_cnt++)
   {
     patch_data = (struct BNpatch *)(surf_data->pat_ary[patch_cnt]);

     fprintf(datfile,"Patch Cnt solid nu nv %d %d %d %d \n",
                      patch_cnt, patch_data->solid, patch_data->nu, 
                      patch_data->nv);

     fprintf (datfile,"us ud vs vd %lf %lf %lf %lf \n",
              patch_data->us, patch_data->ud, patch_data->vs,
              patch_data->vd);

     if(patch_data -> solid == 0)	continue;	/* next patch */

/*   What's left are:
 *    wholly solids
 *    partial facets with loops in them
 */

     facet_map = patch_data->bit_map;

     facet_id = 0;

     for(i = 0; i < patch_data->nv - 1; i ++)
      {
	for(j = 0; j < patch_data->nu - 1; j ++)
	 {
	   if( (patch_data->solid == 1) || 
	       (facet_map[facet_id] == 1) )
	    {
             fprintf (datfile, "facetid facet_map %d %d \n",
                      facet_id, facet_map[facet_id]);
	    }
	   facet_id ++;
	 }	
      }	

/*
 *   All quad elements have been considered. Now consider
 *   the cases  with loops in them
 */

     if ((patch_data->solid == -1) && (!patch_data->n_loop))
      fprintf (stderr, "Possible error in facetting \n");

     if( !patch_data->n_loop) continue;	

     fprintf(datfile,"Number loop %d \n", patch_data->n_loop);

     for(i = 0; i < patch_data->n_loop; i ++)
      {
	loop_data = (struct Facetloop *)&patch_data->fct_lp[i];
        fprintf(datfile,"Loop data , np %d \n", loop_data->np);
      }	
   }

 fclose(datfile);
 return;
}

void outfct(surf_data)
struct BNsf_data *surf_data;
{
 char filename[20];
 FILE *datfile;
 IGRlong		i, j, k,facet_id, patch_cnt;
 IGRshort		*facet_map;
 struct BNpatch	*patch_data;
 struct Facetloop 	*loop_data;
 struct GRvg_construct construct_list;
 struct IGRdisplay active_display;
 IGRshort active_level;
 IGRint m;
 struct GRmd_env md_env;
 IGRint a_id, c_id;
 IGRchar errmsg[EMMAXERRMSG_LEN];
 IGRint bytes_in, bytes_out;
 IGRlong msg_loc;
 OM_S_OBJID objid;
 IGRlong status;
 IGRint number_of_points;
 IGRpoint points[5];

 msg_loc = 1;
 status = 1;


  bytes_in = sizeof (struct IGRdisplay);
  gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
      buffer = &active_display, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

  bytes_in = sizeof (IGRshort);
  gr$get_active_level (msg = &msg_loc, sizbuf = &bytes_in,
      buffer = &active_level, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

  bytes_in = sizeof (struct GRmd_env);
  gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
      buffer = &md_env, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

 construct_list.msg = &msg_loc;
 construct_list.env_info = NULL;
 construct_list.newflag = FALSE;
 construct_list.geometry =  NULL;
 construct_list.class_attr = NULL;
 construct_list.level = NULL;
 construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE
                                                | GRIS_NEW;
 construct_list.display = NULL;
 construct_list.name = NULL;

 construct_list.env_info = &md_env;
 construct_list.level = active_level;
 construct_list.display = &active_display;

  for(patch_cnt=0; patch_cnt < surf_data->n_pat; patch_cnt++)
   {
     patch_data = (struct BNpatch *)(surf_data->pat_ary[patch_cnt]);

     if(patch_data -> solid == 0)	continue;	/* next patch */

/*   What's left are:
 *    wholly solids
 *    partial facets with loops in them
 */
     facet_map = patch_data->bit_map;

     facet_id = 0;
     a_id     = 0;
     c_id     = patch_data->nu;


     for(i = 0; i < patch_data->nv - 1; i ++)
      {
	for(j = 0; j < patch_data->nu - 1; j ++)
	 {
	   if( (patch_data->solid == 1) || 
	       (facet_map[facet_id] == 1) )
	    {
             for (m=0;m<3;m++)
             {
              points[0][m] = patch_data->xyz_tp[a_id][m];
              points[1][m] = patch_data->xyz_tp[a_id+1][m];
              points[3][m] = patch_data->xyz_tp[c_id][m];  
              points[2][m] = patch_data->xyz_tp[c_id+1][m];
              points[4][m] = patch_data->xyz_tp[a_id][m];
             }

             number_of_points = 5;
             
             construct_list.display->color = 0;
             EFplace_line_string(NULL_OBJID, &construct_list, number_of_points,
             points,&objid,&msg_loc);
             if (!(1&msg_loc)) goto wrapup;
	    }
	   facet_id ++;
	   a_id ++;	/* points to u=0 point */
	   c_id ++;	/* points to u=0 point */
	 }	
	a_id ++;	/* points to u=0 point */
	c_id ++;	/* points to u=0 point */
      }	

/*
 *   All quad elements have been considered. Now consider
 *   the cases  with loops in them
 */

     if ((patch_data->solid == -1) && (!patch_data->n_loop))
      fprintf (stderr, "Possible error in facetting \n");

     if( !patch_data->n_loop) continue;	


     for(i = 0; i < patch_data->n_loop; i ++)
      {
	loop_data = (struct Facetloop *)&patch_data->fct_lp[i];
        construct_list.display->color = 1;
        EFplace_line_string(NULL_OBJID, &construct_list, loop_data->np,
        loop_data->xyz, &objid,&msg_loc);
        if (!(1&msg_loc)) goto wrapup;
      }	
   }

wrapup:
 if (!(1&msg_loc))
 {
  fprintf(stderr, "Error in ouputting facets into database \n");
 }
 return;
}

void outtng(points)
IGRdouble *points;
{
 struct GRvg_construct construct_list;
 struct IGRdisplay active_display;
 IGRshort active_level;
 struct GRmd_env md_env;
 IGRint bytes_in, bytes_out;
 IGRlong msg_loc;
 OM_S_OBJID objid;
 IGRlong status;
 IGRint number_of_points;

 msg_loc = 1;
 status = 1;

  bytes_in = sizeof (struct IGRdisplay);
  gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
      buffer = &active_display, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

  bytes_in = sizeof (IGRshort);
  gr$get_active_level (msg = &msg_loc, sizbuf = &bytes_in,
      buffer = &active_level, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

  bytes_in = sizeof (struct GRmd_env);
  gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
      buffer = &md_env, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

 construct_list.msg = &msg_loc;
 construct_list.env_info = NULL;
 construct_list.newflag = FALSE;
 construct_list.geometry =  NULL;
 construct_list.class_attr = NULL;
 construct_list.level = NULL;
 construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE
                                                | GRIS_NEW;
 construct_list.display = NULL;
 construct_list.name = NULL;

 construct_list.env_info = &md_env;
 construct_list.level = active_level;
 construct_list.display = &active_display;

 number_of_points = 4;
             
 EFplace_line_string(NULL_OBJID, &construct_list, number_of_points,
                     points, &objid, &msg_loc);
 if (!(1&msg_loc)) goto wrapup;

wrapup:
 if (!(1&msg_loc))
 {
  fprintf(stderr, "Error in ouputting facets into database \n");
 }
 return;
}

void output_point_vector(inpoint, invector)
IGRdouble *inpoint;
IGRdouble *invector;

{
 IGRlong status;
 IGRlong msg_loc;
 struct GRvg_construct construct_list;
 struct IGRdisplay active_display;
 IGRshort active_level;
 struct GRmd_env md_env;
 IGRint bytes_in, bytes_out;
 OM_S_OBJID objid;
 IGRint number_of_points;
 IGRint i;
 IGRdouble vector[3];
 IGRpoint points[2];

 msg_loc = 1;
 status = 1;


  bytes_in = sizeof (struct IGRdisplay);
  gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
      buffer = &active_display, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

  bytes_in = sizeof (IGRshort);
  gr$get_active_level (msg = &msg_loc, sizbuf = &bytes_in,
      buffer = &active_level, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

  bytes_in = sizeof (struct GRmd_env);
  gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
      buffer = &md_env, nret = &bytes_out);
  if (!(1&msg_loc)) goto wrapup;

 construct_list.msg = &msg_loc;
 construct_list.env_info = NULL;
 construct_list.newflag = FALSE;
 construct_list.geometry =  NULL;
 construct_list.class_attr = NULL;
 construct_list.level = NULL;
 construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE
                                                | GRIS_NEW;
 construct_list.display = NULL;
 construct_list.name = NULL;

 construct_list.env_info = &md_env;
 construct_list.level = active_level;
 construct_list.display = &active_display;

 number_of_points = 2;

 for (i=0;i<3;i++)
  vector[i] = invector[i];
 
 BSnorvec(&msg_loc, vector);
 msg_loc = 1;

 for (i=0;i<3;i++)
 {
  points[0][i] = inpoint[i];
  points[1][i] = vector[i] + inpoint[i];
 }

 construct_list.display->color = 3;
 EFplace_line_string(NULL_OBJID, &construct_list, number_of_points,
 points, &objid,&msg_loc);
 if (!(1&msg_loc)) goto wrapup;

wrapup:
if (!(1&msg_loc)) fprintf(stderr,"Error in displ normal\n");
return;
}
