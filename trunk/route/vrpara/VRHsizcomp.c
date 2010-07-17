/* $Id: VRHsizcomp.c,v 1.2 2002/04/10 19:52:10 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpara/VRHsizcomp.c
 *
 * Description:
 *    This function iterates on the diameter until the value is within
 *    1/10000 of the value of the diameter or 500 iterations.
 *    For a rounded corner duct, if either the input or output values of
 *    width or depth are less than twice the radius, the values returned
 *    are equal to twice the radius.
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      12/29/97        law     CR179700399-associate width/depth/equiv-dia.
 *      05/18/98        law     CR179801061-min dimension = 2* rad +1
 *      04/05/02        law     TR5649-standardize tolerance with VRGetTol
 *************************************************************************/
#include "VRchgattrdef.h"
#define M_PI            3.14159265358979323846
/*
#include "VRsize.h"
#include "VRdef.h"
*/
#include "VRMath.h"

int VRHsiz_compute(form_ptr,width_val,depth_val,radius,diameter,
                                                           outputvar,shape)
char *form_ptr;
double *width_val;
double *depth_val;
double radius;
char outputvar[6];
double diameter;
int shape;

{
extern double pow();
extern double fabs();
double dia_comp;

double loc_width;
double loc_depth;
double loc_temp1,loc_temp2;
double loc_dia;
double vardlta;
double l_w,l_d;

int force_val;
int iter;
int status;
int sel_flag;
char mess_field[40];
double tol;

status = 1;
loc_dia = diameter;
sel_flag = 0;
loc_width = 0.;
loc_depth = 0.;
/* Assume output is 0. */
if(!strcmp(outputvar,"depth"))
{
  loc_width = *width_val;
  if ((shape == VR_CORNER_S) && ((2. * radius) > loc_width))
  {
     FIfld_set_text( form_ptr, MESSAGE, 0, 0,
            "Least Allowable width is twice the corner radius", sel_flag );
     return 0;
  }
}
else
{
  loc_depth = *depth_val;
  if ((shape == VR_CORNER_S) && (2. * radius > loc_depth))
  {
     FIfld_set_text( form_ptr, MESSAGE, 0, 0,
            "Least Allowable depth is twice the corner radius", sel_flag );
     return 0;
  }
}
force_val = 0;
if (shape == VR_CORNER_S)
   {
      if (2. * radius > loc_width)
      {
         loc_width = 2.0 * radius;
         force_val = 1;
      }
      if (2. * radius > loc_depth)
      {
         loc_depth = 2.0 * radius;
         force_val = 1;
      }
   }
iter = 0;
vardlta = 1.0;
dia_comp = 0.0;
tol = diameter * VRGetTol(VR_DIST_TOL);
while(fabs(loc_dia - dia_comp) > tol)
{
   if(!strcmp(outputvar,"width"))
   {
      loc_width = loc_width + vardlta;
   }
   else
   {
      loc_depth = loc_depth + vardlta;
   }
      iter++;
      switch( shape )
      {
         case VR_CIRC_S:
           dia_comp = diameter;
           loc_width = diameter;
           loc_depth = loc_width;
           break;
         case VR_RECT_S:
           dia_comp = 1.3 * pow((loc_width*loc_depth),0.625) /
                            pow((loc_width+loc_depth),0.25);
           break;
         case VR_OVAL_S:
           /* This equation assumed width > depth, so swap if necessary */
           l_w = loc_width;
           l_d = loc_depth;
           if(loc_width < loc_depth)
           {
             l_d = loc_width;
             l_w = loc_depth;
           }
           loc_temp1 = M_PI * l_d * l_d / 4.0 + l_d * ( l_w - l_d);
           loc_temp2 = (M_PI * l_d) + 2 * (l_w - l_d);
           dia_comp = 1.55 * pow(loc_temp1,0.625) / pow(loc_temp2,0.25);
           break;
         case VR_CORNER_S:
           /* The assumption is radius < 1/2 width or depth-else error */
           /* The coefficient used was same as for rectangular (1.3)   */
           /* The assumption is (area)^0.625 / (perimeter/2)^0.25      */
           /* Note that if radius = 0, same equation as rectangular    */

           loc_temp1 = 2.0 * radius * (loc_width - 2 * radius)
                     + 2.0 * M_PI * radius 
                     + loc_width * (loc_depth - 2 * radius);
           loc_temp2 = loc_depth + loc_width + radius * (M_PI -4);

           dia_comp = 1.3 * pow(loc_temp1,0.625) / pow(loc_temp2,0.25);

           if((iter == 1) && force_val && (dia_comp > loc_dia))
           {
             loc_dia = dia_comp;
             sprintf(mess_field,"Minimum Dimension = 2xRadius");
             FIfld_set_text( form_ptr, MESSAGE, 0, 0,mess_field, sel_flag );
           }             
           break;
      }

   if((vardlta > 0.0) && (dia_comp > loc_dia))
   {
     vardlta = - vardlta / 2.0;
   }
   else if ((vardlta < 0.0) && (loc_dia > dia_comp))
   {
     vardlta = fabs(vardlta) / 2.0;
   }
   if(iter > 500)
   {
      loc_dia = dia_comp;
      sprintf(mess_field,"Too many iterations, answer +/-%lf",vardlta);
      FIfld_set_text( form_ptr, MESSAGE, 0, 0,mess_field, sel_flag );
   }
}
if (shape == VR_CORNER_S)
   {
      if (2. * radius > loc_width)
      {
         loc_width = 2.0 * radius + 1;
         FIfld_set_text( form_ptr, MESSAGE, 0, 0,
            "Least Allowable width is twice the corner radius", sel_flag );
      }
      if (2. * radius > loc_depth)
      {
         loc_depth = 2.0 * radius + 1;
         FIfld_set_text( form_ptr, MESSAGE, 0, 0,
            "Least Allowable depth is twice the corner radius", sel_flag );
      }
   }
*width_val = loc_width;
*depth_val = loc_depth;

return status;
}
