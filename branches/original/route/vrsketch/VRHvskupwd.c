/* $Id: VRHvskupwd.c,v 1.1.1.1 2001/01/04 21:13:09 cvs Exp $  */
/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpara/VRHvskupwd.c
 *
 * Description:
 *    This function updates the width/depth fields in the VRHvSkParams form
 *  based on the shape code and the size-computation method.
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      12/29/97        law     CR179801061-associate width/depth/equiv-dia.
 *************************************************************************/

#include "OMerrordef.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRsketchdef.h"
#include "vrparameters.h"
#include "FI.h"
#define         VR_RECT_S       0x0000  /* */
#define         VR_OVAL_S       0x0001  /* */
#define         VR_CIRC_S       0x0002  /* */
#define         VR_CORNER_S     0x0003  /* */


int VRHvskupdwd(form_ptr,in_shape,max_depth,diameter,radius)
unsigned char * form_ptr;
int in_shape;
double max_depth;
double diameter;
double radius;

{
int row,col,sel_flag,r_pos,Nbattr;
double corner_dim;
double width_val,depth_val;
char method_str[40];
int status;
int shape;
double loc_max_depth;
int i,store_width,store_depth;

row = 0;
col = 0;
sel_flag = 0;
status = 1;

   FIfld_set_text( form_ptr, MESSAGE, 0, 0,"", sel_flag );
   if(in_shape == HV_C_SHAPE) shape = VR_CIRC_S;
   else if(in_shape == HV_O_SHAPE) shape = VR_OVAL_S;
   else if(in_shape == HV_R_SHAPE) shape = VR_RECT_S;
   else if(in_shape == HV_RS_SHAPE) shape = VR_CORNER_S;
   else
       shape = VR_RECT_S;

   FIfld_get_value( form_ptr,HV_WIDTH, row, col,&width_val,&sel_flag,&r_pos);

   /* Get depth value from form */
   FIfld_get_value( form_ptr,HV_DEPTH, row, col,&depth_val,&sel_flag,&r_pos);


   /* If rounded corner, get radius */
   radius = 0.;

   corner_dim = 2.0 * radius + 1.0;

   loc_max_depth = max_depth;
   if(corner_dim > max_depth)
   {
     loc_max_depth = corner_dim;
   }

   FIfld_get_text(form_ptr,SIZE_COMP_METHOD,row,col,27,
                            (unsigned char *) method_str, &sel_flag, &r_pos );

   if (shape == VR_CIRC_S )
   {
      if(!strncmp(method_str,"Compute Width",13))
      {
         depth_val = diameter;
         if(loc_max_depth < depth_val && loc_max_depth > 0.0)
         {
            depth_val = loc_max_depth;
            FIfld_set_text( form_ptr, MESSAGE, 0, 0,
               "Input depth Greater Than MaxDepth", sel_flag );
            depth_val = loc_max_depth;
         }
         width_val = depth_val;

      }
      else
      {
         FIfld_set_mode(form_ptr, HV_WIDTH, 0, FI_INSERT);
         if(!strncmp(method_str,"Compute Depth",13))
         {
            width_val = diameter;
         }
         if(loc_max_depth < width_val && loc_max_depth > 0.0)
         {
            width_val = loc_max_depth;
            FIfld_set_text( form_ptr, MESSAGE, 0, 0,
               "Input depth Greater Than MaxDepth", sel_flag );
         }
         depth_val = width_val;
         FIg_erase(form_ptr,HV_DEPTH);
      }
   }
   else if(!strncmp(method_str,"Compute Depth",13))
   {

             if((corner_dim > width_val) && (shape == VR_CORNER_S ))
             {
                width_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                       "Size must be greater than corners", sel_flag );
             }
             /* Compute depth */
             status = VRHsiz_compute(form_ptr,&width_val,&depth_val,radius,
                                                   diameter,"depth",shape);

             /*** Added for TR179800380 */
             if(depth_val > loc_max_depth && loc_max_depth > 0.0)
             {
               depth_val = loc_max_depth;
               FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                       "Comp depth Greater Than MaxDepth", sel_flag );
             }
             if((corner_dim > depth_val) && (shape == VR_CORNER_S ))
             {
                depth_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                       "Size must be greater than corners", sel_flag );
             }

             FIfld_set_mode(form_ptr, HV_WIDTH,0, FI_INSERT);
             FIg_display( form_ptr, HV_WIDTH);
             FIfld_set_mode(form_ptr, HV_DEPTH, 0, FI_REVIEW);
             /*** Added for TR179800380 */
             FIg_display( form_ptr, HV_DEPTH );
   }
   else if(!strncmp(method_str,"Compute Width",13))
   {
             /*** Modified for TR179800380 */
             /* Get depth value from collection */
             if(depth_val > loc_max_depth && loc_max_depth > 0.0)
             {
               FIfld_set_text( form_ptr, MESSAGE, 0, 0,
               "Input depth Greater Than MaxDepth", sel_flag );
               depth_val = loc_max_depth;
               FIfld_set_value(  form_ptr, HV_DEPTH, row, col,width_val,
                                                                   sel_flag );
             }
             /*** Added for TR179800380 */
             if((corner_dim > depth_val) && (shape == VR_CORNER_S ))
             {
                depth_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                   "Size must be greater than corners", sel_flag );
             }
             /* compute width */
             status = VRHsiz_compute(form_ptr,&width_val,&depth_val,radius,
                                     diameter,"width",shape);

             /*** Added for TR179800380 */
             if((corner_dim > width_val) && (shape == VR_CORNER_S ))
             {
                width_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                   "Size must be greater than corners", sel_flag );
             }
             FIfld_set_mode(form_ptr, HV_DEPTH, 0, FI_INSERT);
             FIg_display( form_ptr, HV_DEPTH );

             FIfld_set_mode(form_ptr, HV_WIDTH,0, FI_REVIEW);
             FIg_display( form_ptr, HV_WIDTH);
   }
   else
   {
             /*** Added for TR179800380 */
             FIg_display( form_ptr, HV_DEPTH );
             FIfld_set_mode(form_ptr, HV_DEPTH, 0, FI_INSERT);
             FIfld_set_mode(form_ptr, HV_WIDTH,0, FI_INSERT);

             if(depth_val > loc_max_depth && loc_max_depth > 0.0)
             {
               FIfld_set_text( form_ptr, MESSAGE, 0, 0,
               "Depth Greater Than MaxDepth", sel_flag );
               depth_val = loc_max_depth;
             }
             if((corner_dim > depth_val) && (shape == VR_CORNER_S ))
             {
                depth_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                   "Size must be greater than corners", sel_flag );
             }
             if((corner_dim > width_val) && (shape == VR_CORNER_S ))
             {
                width_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                   "Size must be greater than corners", sel_flag );
             }
   }
          /* Do not store width and depth for circular until form run */
   FIfld_set_value(  form_ptr, HV_DEPTH, row, col,depth_val,sel_flag );
   FIfld_set_value(  form_ptr, HV_WIDTH,row, col,width_val,sel_flag );

return (OM_S_SUCCESS); 
}
