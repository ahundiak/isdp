/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*\
Name
   GRbuild_prism_helper

Description
   This is a helper function it returns most of the information needed
   to build a prism.  This function works on the assumption that the
   prism will be built in a specific window.  

   *msg                    IGRlong        completion code
   *window_id              stuct GRid     object id of the window.
   wld_to_vw_matrix[]      IGRdouble      The world to view matrix.
   vw_volume[6]            IGRdouble      The vw volume in view coordinates
   view_origin[4]          IGRdouble      The view origin
   vw_to_wld_matrix[]      IGRdouble      The view to world matrix.
   wld_vw_volume[6]        IGRdouble      The vw volume in wld coordinates
   local_to_wld_matrix[]   IGRdouble      The local to world matrix, llf of
                                          wld_vw_volume is  the origin.
   wld_to_local_matrix[]   IGRdouble      The world to local matrix.
   *height                 IGRdouble      The height of the vw_volume
                                          in local coordinates.

Notes
   The following arguments may be NULL.
      -  wld_to_vw_matrix
      -  vw_volume
      -  view_origin
      -  vw_to_wld_matrix
      -  wld_vw_volume
      -  local_to_wld_matrix
      -  wld_to_local_matrix
      -  height

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    07/13/87    Creation date.
\*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "OMerrordef.h"

IGRint GRbuild_prism_helper (msg, window_id, wld_to_vw_matrix, vw_volume,
                             view_origin, vw_to_wld_matrix, wld_vw_volume,
                             local_to_wld_matrix,  wld_to_local_matrix,
                             height)
IGRlong        *msg;
struct GRid    *window_id;
IGRdouble      wld_to_vw_matrix[];
IGRdouble      vw_volume[];
IGRdouble      view_origin[];
IGRdouble      vw_to_wld_matrix[];
IGRdouble      wld_vw_volume[];
IGRdouble      local_to_wld_matrix[];
IGRdouble      wld_to_local_matrix[];
IGRdouble      *height;
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRlong           temp;
IGRlong           two;
IGRint            i;
IGRshort          matrix_type;
IGRdouble         internal_wld_to_vw_matrix[16];
IGRdouble         internal_vw_volume[6];
IGRdouble         internal_view_origin[4];
IGRdouble         internal_vw_to_wld_matrix[16];
IGRdouble         internal_wld_vw_volume[6];
struct var_list   var_list[4];

   *msg = MSSUCC;
   two = 2;

   /*
    *  Get the world to view matrix.  This matrix just contains
    *  rotation.
    */

   var_list[0].var = WLD_TO_VIEW;
   var_list[0].var_ptr = (char *)internal_wld_to_vw_matrix;
   var_list[0].num_bytes = sizeof (IGRdouble) * 16;
   var_list[0].bytes_returned = &temp;

   var_list[1].var = VW_VOLUME;
   var_list[1].var_ptr = (char *)internal_vw_volume;
   var_list[1].num_bytes = sizeof (IGRdouble) * 6;
   var_list[1].bytes_returned = &temp;

   var_list[2].var = VIEW_ORIGIN;
   var_list[2].var_ptr = (char *)internal_view_origin;
   var_list[2].num_bytes = sizeof (IGRdouble) * 4;
   var_list[2].bytes_returned = &temp;

   var_list[3].var = END_PARAM;
   var_list[3].var_ptr = NULL;
   var_list[3].num_bytes = NULL;
   var_list[3].bytes_returned = NULL;
   
   om_msg = dp$inq_set_gragad (msg = &ret_msg,
            osnum = window_id->osnum, gragad_objid = window_id->objid,
            which_error = &temp, var_list = var_list);

   if (om_msg & ret_msg & 1)
   {
      /*
       *  Build the vw_to_wld_matrix which will take the view volume 
       *  from the view coordinate system to the world coordinate system.
       *  local_to_world_matrix * (pt - 0) + view origin in world
       */

      internal_vw_to_wld_matrix[0]  =  internal_wld_to_vw_matrix[0];
      internal_vw_to_wld_matrix[1]  =  internal_wld_to_vw_matrix[4];
      internal_vw_to_wld_matrix[2]  =  internal_wld_to_vw_matrix[8];
      internal_vw_to_wld_matrix[3]  =  internal_view_origin[0];
      internal_vw_to_wld_matrix[4]  =  internal_wld_to_vw_matrix[1];
      internal_vw_to_wld_matrix[5]  =  internal_wld_to_vw_matrix[5];
      internal_vw_to_wld_matrix[6]  =  internal_wld_to_vw_matrix[9];
      internal_vw_to_wld_matrix[7]  =  internal_view_origin[1];
      internal_vw_to_wld_matrix[8]  =  internal_wld_to_vw_matrix[2];
      internal_vw_to_wld_matrix[9]  =  internal_wld_to_vw_matrix[6];
      internal_vw_to_wld_matrix[10] =  internal_wld_to_vw_matrix[10];
      internal_vw_to_wld_matrix[11] =  internal_view_origin[2];
      internal_vw_to_wld_matrix[12] =  internal_wld_to_vw_matrix[12];
      internal_vw_to_wld_matrix[13] =  internal_wld_to_vw_matrix[13];
      internal_vw_to_wld_matrix[14] =  internal_wld_to_vw_matrix[14];
      internal_vw_to_wld_matrix[15] =  internal_wld_to_vw_matrix[15];

      /*
       *  Transform the vw_volume to world coordinates.
       */

      MAtypemx(&ret_msg, internal_vw_to_wld_matrix, &matrix_type);
      MAoptsxform (&ret_msg, &two, &matrix_type, 
                   internal_vw_to_wld_matrix, internal_vw_volume, 
                   internal_wld_vw_volume);

      if (wld_to_vw_matrix)
      {
         for (i=0; i < 16; ++i)
         {
            wld_to_vw_matrix[i] = internal_wld_to_vw_matrix[i];
         }
      }

      if (vw_volume)
      {
         for (i=0; i < 6; ++i)
         {
            vw_volume[i] = internal_vw_volume[i];
         }
      }
               
      if (view_origin)
      {
         for (i=0; i < 4; ++i)
         {
            view_origin[i] = internal_view_origin[i];
         }
      }
               
      if (vw_to_wld_matrix)
      {
         for (i=0; i < 16; ++i)
         {
            vw_to_wld_matrix[i] = internal_vw_to_wld_matrix[i];
         }
      }

      if (wld_vw_volume)
      {
         for (i=0; i < 6; ++i)
         {
            wld_vw_volume[i] = internal_wld_vw_volume[i];
         }
      }

      if (wld_to_local_matrix)
      {
         /*
          *  Build the wld_to_local_matrix to take elements from  world
          *  coordinates to local coordinates. This local coordinate
          *  system will be aligned with the view and translated about the
          *  lower left front of the view volume.
          */

         for (i=0; i < 16; ++i)
         {
            wld_to_local_matrix[i] = internal_wld_to_vw_matrix[i];
         }

         wld_to_local_matrix[3] -= internal_vw_volume[0];
         wld_to_local_matrix[7] -= internal_vw_volume[1];
         wld_to_local_matrix[11] -= internal_vw_volume[2];
      }

      if (local_to_wld_matrix)
      {
         /*
          *  Build the local_to_wld_matrix to take elements from 
          *  local coordinates to world coordinates.  
          *  local_to_world_matrix * (pt - 0) + origin in world.
          */

         local_to_wld_matrix[0]  =  internal_wld_to_vw_matrix[0];
         local_to_wld_matrix[1]  =  internal_wld_to_vw_matrix[4];
         local_to_wld_matrix[2]  =  internal_wld_to_vw_matrix[8];
         local_to_wld_matrix[3]  =  internal_wld_vw_volume[0];
         local_to_wld_matrix[4]  =  internal_wld_to_vw_matrix[1];
         local_to_wld_matrix[5]  =  internal_wld_to_vw_matrix[5];
         local_to_wld_matrix[6]  =  internal_wld_to_vw_matrix[9];
         local_to_wld_matrix[7]  =  internal_wld_vw_volume[1];
         local_to_wld_matrix[8]  =  internal_wld_to_vw_matrix[2];
         local_to_wld_matrix[9]  =  internal_wld_to_vw_matrix[6];
         local_to_wld_matrix[10] =  internal_wld_to_vw_matrix[10];
         local_to_wld_matrix[11] =  internal_wld_vw_volume[2];
         local_to_wld_matrix[12] =  internal_wld_to_vw_matrix[12];
         local_to_wld_matrix[13] =  internal_wld_to_vw_matrix[13];
         local_to_wld_matrix[14] =  internal_wld_to_vw_matrix[14];
         local_to_wld_matrix[15] =  internal_wld_to_vw_matrix[15];
      }

      if (height)
      {
         /*
          *  The height of the prism is equal to the depth
          *  of the view.  The view volume is in view coordinates.
          *  This depth is given by taking difference between the    
          *  view volume high and view volume low.
          */
   
         *height = internal_vw_volume[5] - internal_vw_volume[2];
      }
   }
   return(OM_S_SUCCESS);
}
