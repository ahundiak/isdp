/* $Id: VRHvupdwd.c,v 1.1.1.1 2001/01/04 21:13:00 cvs Exp $  */
/*************************************************************************
 * I/ROUTE
 *
 * File:        vrpara/VRHvupdwd.c
 *
 * Description:
 *    This function updates the width/depth fields in the VRHvDgPar form
 *  based on the shape code and the size-computation method.
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      12/29/97        law     CR179700399-associate width/depth/equiv-dia.
 *      02/09/98        law     TR179800380- max width constraint on width.
 *************************************************************************/

#include "OMerrordef.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRchgattrdef.h"
#include "vrparameters.h"
#include "FI.h"

int VRHvupd_wd(form_ptr,shape,width_io,depth_io,dValue,nbattr,ListAttr)
unsigned char * form_ptr;
int shape;
double *width_io;
double *depth_io;
double *dValue;
int *nbattr;
struct ACrg_coll *ListAttr;

{
int row,col,sel_flag,r_pos,Nbattr;
double radius, corner_dim;  /* TR179800380 */
double diameter;
double width_val,depth_val,max_depth;
char method_str[40];
int status;
int i,store_width,store_depth;  /* TR179800380 */

row = 0;
col = 0;
sel_flag = 0;
status = 1;

   /* Get width value from form */
             /*** Added for TR179800380 */
   FIfld_get_value( form_ptr,MAX_WIDTH, row, col,&max_depth,&sel_flag,&r_pos);

   FIfld_get_value( form_ptr,W_SIZE, row, col,&width_val,&sel_flag,&r_pos);

   /* Get depth value from form */
   FIfld_get_value( form_ptr,D_SIZE, row, col,&depth_val,&sel_flag,&r_pos);


   FIfld_get_value( form_ptr,EQUIV_DIAM, row, col,
                                               &diameter,&sel_flag,&r_pos);
   /* If rounded corner, get radius */
   radius = 0.;
   if(shape == VR_CORNER_S)
   {
      FIfld_get_value( form_ptr,CORNER_RADIUS, row, col,
                                               &radius,&sel_flag,&r_pos);
   }

             /*** Added for TR179800380 */
   corner_dim = 2.0 * radius + 1.0;

   if(corner_dim > max_depth)
   {
     max_depth = corner_dim;
   }

   FIfld_get_text(form_ptr,SIZE_COMP_METHOD,row,col,MAX_FIELD,
                            (unsigned char *) method_str, &sel_flag, &r_pos );

             /*** Added for TR179800380 */
   if (shape == VR_CIRC_S)
   {
      if(!strncmp(method_str,"Compute Width",13))
      {
         depth_val = diameter;
         if(max_depth < depth_val && max_depth > 0.0)
         {
            depth_val = max_depth;
            FIfld_set_text( form_ptr, MESSAGE, 0, 0,
               "Input depth Greater Than Max-Depth", sel_flag );
            depth_val = max_depth;
         }
         width_val = depth_val;

      }
      else
      {
         FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
         if(!strncmp(method_str,"Compute Depth",13))
         {
            width_val = diameter;
         }
         if(max_depth < width_val && max_depth > 0.0)
         {
            width_val = max_depth;
            FIfld_set_text( form_ptr, MESSAGE, 0, 0,
               "Input depth Greater Than Max-Depth", sel_flag );
         }
         depth_val = width_val;
         FIg_erase(form_ptr,D_SIZE);
      }
      FIfld_set_value(  form_ptr, D_SIZE, row, col,depth_val,sel_flag );
      FIfld_set_value(  form_ptr, W_SIZE, row, col,width_val,sel_flag );
   }
   else if(!strncmp(method_str,"Compute Depth",13))
   {

             if((corner_dim > width_val) && (shape == VR_CORNER_S))
             {
                width_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                       "Size must be greater than corners", sel_flag );
             }
   /* end add for TR179800380 */
             /* Compute depth */
             status = VRHsiz_compute(form_ptr,&width_val,&depth_val,radius,
                                                   diameter,"depth",shape);

             /*** Added for TR179800380 */
             if(depth_val > max_depth && max_depth > 0.0)
             {
               depth_val = max_depth;
               FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                       "Computed depth Greater Than Max-Depth", sel_flag );
             }
             if((corner_dim > depth_val) && (shape == VR_CORNER_S))
             {
                depth_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                       "Size must be greater than corners", sel_flag );
             }

             FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
             FIg_display( form_ptr, W_SIZE );
             FIfld_set_mode(form_ptr, D_SIZE, 0, FI_REVIEW);
             /*** Added for TR179800380 */
             FIfld_set_value(  form_ptr, W_SIZE, row, col,width_val,sel_flag );
             FIfld_set_value(  form_ptr, D_SIZE, row, col,depth_val,sel_flag );
             FIg_display( form_ptr, D_SIZE );
   }
   else if(!strncmp(method_str,"Compute Width",13))
   {
             /*** Modified for TR179800380 */
             /* Get depth value from collection */
             if(depth_val > max_depth && max_depth > 0.0)
             {
               FIfld_set_text( form_ptr, MESSAGE, 0, 0,
               "Input depth Greater Than Max-Depth", sel_flag );
               depth_val = max_depth;
               FIfld_set_value(  form_ptr, D_SIZE, row, col,width_val,
                                                                   sel_flag );
             }
             /*** Added for TR179800380 */
             if((corner_dim > depth_val) && (shape == VR_CORNER_S))
             {
                depth_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                   "Size must be greater than corners", sel_flag );
             }
             /* compute width */
             status = VRHsiz_compute(form_ptr,&width_val,&depth_val,radius,
                                     diameter,"width",shape);

             /*** Added for TR179800380 */
             if((corner_dim > width_val) && (shape == VR_CORNER_S))
             {
                width_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                   "Size must be greater than corners", sel_flag );
             }
             FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
             FIfld_set_value(  form_ptr, D_SIZE, row, col,depth_val,sel_flag );
             FIg_display( form_ptr, D_SIZE );

             FIfld_set_mode(form_ptr, W_SIZE, 0, FI_REVIEW);
             FIfld_set_value(  form_ptr, W_SIZE, row, col,width_val,sel_flag );
             FIg_display( form_ptr, W_SIZE );
   }
   else
   {
             /*** Added for TR179800380 */
             FIg_display( form_ptr, D_SIZE );
             FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
             FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);

             if(depth_val > max_depth && max_depth > 0.0)
             {
               FIfld_set_text( form_ptr, MESSAGE, 0, 0,
               "Depth Value Greater Than Max-Depth", sel_flag );
               depth_val = max_depth;
             }
             if((corner_dim > depth_val) && (shape == VR_CORNER_S))
             {
                depth_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                   "Size must be greater than corners", sel_flag );
             }
             if((corner_dim > width_val) && (shape == VR_CORNER_S))
             {
                width_val = corner_dim;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                   "Size must be greater than corners", sel_flag );
             }
             FIfld_set_value(form_ptr, W_SIZE,row, col,width_val,sel_flag );
             FIfld_set_value(form_ptr, D_SIZE,row, col,depth_val,sel_flag );
   }
          /* Do not store width and depth for circular until form run */
   if(shape == VR_CIRC_S)
   {
                FIfld_set_value(form_ptr, W_SIZE,row, col,width_val,sel_flag );
                FIfld_set_value(form_ptr, D_SIZE,row, col,depth_val,sel_flag );
   }
   else
   {  /*** End of add for TR179800380 */

                Nbattr = *nbattr;
                /* Below added for TR179800380 */
                store_depth = 1;
                store_width = 1;
                for( i = 0; i < Nbattr; i++);
                {
                  if(!strcmp((ListAttr+i)->name),VR_N_DEPTH1_DB)
                  {
                    (ListAttr+i)->desc.value.att_exp = depth_val;
                    store_depth = 0;
                  }
                  else if(!strcmp((ListAttr+i)->name),VR_N_DEPTH2_DB)
                  {
                    (ListAttr+i)->desc.value.att_exp = depth_val;
                  }
                  else if(!strcmp((ListAttr+i)->name),VR_N_WIDTH1_DB)
                  {
                    (ListAttr+i)->desc.value.att_exp = width_val;
                    store_width = 0;
                  }
                  else if(!strcmp((ListAttr+i)->name),VR_N_WIDTH2_DB)
                  {
                    (ListAttr+i)->desc.value.att_exp = width_val;
                  }
                }
                if(store_width)
                {
                   strcpy( (ListAttr+Nbattr)->name , VR_N_WIDTH1_DB );
                   (ListAttr+Nbattr)->desc.type = AC_ATTRIB_DOUBLE;
                   (ListAttr+Nbattr)->desc.value.att_exp = width_val;
                   if(Nbattr == 0)
                     *dValue = width_val;
                   Nbattr = Nbattr + 1;
                   strcpy( (ListAttr+Nbattr)->name , VR_N_WIDTH2_DB );
                   (ListAttr+Nbattr)->desc.type = AC_ATTRIB_DOUBLE;
                   (ListAttr+Nbattr)->desc.value.att_exp = width_val;
                   *nbattr = *nbattr + 2;
                }
                if(store_depth)
                {
                   strcpy( (ListAttr+Nbattr)->name , VR_N_DEPTH1_DB );
                   (ListAttr+Nbattr)->desc.type = AC_ATTRIB_DOUBLE;
                   (ListAttr+Nbattr)->desc.value.att_exp = depth_val;
                   Nbattr = Nbattr + 1;
                   strcpy( (ListAttr+Nbattr)->name , VR_N_DEPTH2_DB );
                   (ListAttr+Nbattr)->desc.type = AC_ATTRIB_DOUBLE;
                   (ListAttr+Nbattr)->desc.value.att_exp = depth_val;
                   *nbattr = *nbattr + 2;
                }
                /* End add for TR179800380 */
   }

   *depth_io = depth_val;
   *width_io = width_val;

return (OM_S_SUCCESS); 
}
