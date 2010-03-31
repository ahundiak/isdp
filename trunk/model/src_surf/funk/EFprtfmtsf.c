/* ###################   APOGEE COMPILED   ################## */
# include "EMS.h"
# include <stdio.h>
# include <math.h>
# include <string.h>
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
# include "EMSfmtsf.h"

/*
  Description

     This file contains the functions used in debugging the
     converting a surface from EMS to IGDS format.

  History
 
     RC   05/18/89    Creation Date
*/

int prt_grinfo(gr_info)
struct EMSgr_info *gr_info;
{
  char filename[20];
  FILE *fileptr;
  int prt_grbndfn();
  int  i, bix;

  printf ("Filename_: ");
  scanf ("%s", filename);
  fileptr = fopen(filename, "w");
  
  fprintf (fileptr, "************* Group Info *************\n\n");

  for (i= 0; i < 4; i++)
   fprintf (fileptr, "gr_range[%1d] = %.10e \n", i, gr_info->range[i]);  

  fprintf (fileptr, "num_grbnds = %d \n", gr_info->num_bnds);  

  fprintf (fileptr, "grbnd_arrsz = %d \n", gr_info->grbnd_arrsz);  

  fprintf (fileptr, "overflow = %d \n", gr_info->overflow); 

  fprintf (fileptr, "num_type_25_needed = %d \n", gr_info->num_type_25_needed);

  for (bix = 0; bix < gr_info->num_bnds; bix++)
  {
    fprintf (fileptr, "\n\n *** GRbnd # %d ***\n\n", bix);
    prt_grbndfn (fileptr, gr_info->grbnd_info[bix]);
    fprintf (fileptr, "\n \n");
  
  } /* for (bix = 0; bix < gr_info->num_bnds; bix++) */
 
  fclose (fileptr);

} /* int prt_grinfo() */


int prt_grbnd(grbnd_info)
struct EMSgrbnd_info *grbnd_info;
{
  char filename[20];
  FILE *fileptr;
  int prt_grbndfn();

  printf ("Filename_: ");
  scanf ("%s", filename);
  fileptr = fopen(filename, "w");
  
  fprintf (fileptr, "\n\n ************* Grbnd Info *************\n\n");

  prt_grbndfn (fileptr, grbnd_info);
  fclose (fileptr);

} /* int prt_grbnd(grbnd_info) */


int prt_sbnd(sbnd_info)
struct EMSsbnd_info *sbnd_info;
{
  char filename[20];
  FILE *fileptr;
  int prt_sbndfn();

  printf ("Filename_: ");
  scanf ("%s", filename);
  fileptr = fopen(filename, "w");
  
  prt_grbndfn (fileptr, TRUE, sbnd_info);
  fclose (fileptr);

} /* int prt_sbnd(sbnd_info) */


int prt_grbndfn (fileptr, grbnd_info)
  FILE                 *fileptr;
  struct EMSgrbnd_info *grbnd_info;
{
 int  i;
 int prt_sbndfn();

 for (i = 0; i < 4; i++) 
  fprintf (fileptr, " grbnd_range[%1d] = %.12e \n", i, grbnd_info->range[i]);
 
 fprintf (fileptr, "num_pts = %d \n", grbnd_info->num_pts);
 fprintf (fileptr, "whole_bnd = %d \n", grbnd_info->whole_bnd);
 fprintf (fileptr, "sbnd_info = 0x%x\n", grbnd_info->sbnd_info);

 prt_sbndfn(fileptr, grbnd_info->whole_bnd, grbnd_info->sbnd_info);

 return(TRUE);

} /* int prt_grbndfn() */


int prt_sbndfn (fileptr, whole_grbnd, sbnd_info)

 FILE                 *fileptr;
 IGRboolean           whole_grbnd;
 struct EMSsbnd_info  *sbnd_info;

{
 int i, num_sbnds = 0;;

 while (sbnd_info)
 {
   
   fprintf (fileptr, "\n\n******** Sbnd Info # %d******** \n\n",num_sbnds++);
   fprintf (fileptr, "bnd_info = 0x%x \n", sbnd_info->bnd_info);
   for (i = 0; i < 4; i++)
    fprintf (fileptr, "sbnd_range[%1d] = %.12e\n", i,sbnd_info->range[i]);

    fprintf (fileptr, "beg_pt[0] = %.12e \n", sbnd_info->beg_pt[0]);     
    fprintf (fileptr, "beg_pt[1] = %.12e \n", sbnd_info->beg_pt[1]);     
    fprintf (fileptr, "end_pt[0] = %.12e \n", sbnd_info->end_pt[0]);     
    fprintf (fileptr, "end_pt[1] = %.12e \n", sbnd_info->end_pt[1]);

    fprintf (fileptr, "beg_inx = %d \n", sbnd_info->beg_inx);     
    fprintf (fileptr, "end_inx = %d \n", sbnd_info->end_inx);     
        

   fprintf (fileptr, "num_pts = %d \n", sbnd_info->num_pts);
   fprintf (fileptr, "next = 0x%x \n", sbnd_info->next);     
     
   sbnd_info = sbnd_info->next;   
   
 } /* while (sbnd_info) */

 
 return (TRUE);

} /* int prt_sbndfn () */

int prt_values (num_values, values)
 int   num_values;
 char  *values;
{
  int i, *int_values, value_type;
  double *dbl_values;

  fprintf (stderr, "Values type: Intiger[0] : Double[1] > ");
  scanf  ("%d", &value_type);

  fprintf (stderr, "\n \n");

  if (value_type == 0) int_values = (int *) values;
  else dbl_values = (double *) values;

  for (i = 0; i < num_values; i++)
  {
   switch (value_type)
   {
     case 0:
       fprintf (stderr, "values[%d] = %d \n", i, int_values[i]);
      break;
     case 1:
       fprintf (stderr, "values[%d] = %.15e \n", i, dbl_values[i]);
      break;

     default:
      break;
   }
  } /* for (i = 0; i < num_values; i++) */
 return (TRUE);
}
