/* ###################   APOGEE COMPILED   ################## */

#include "EMS.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igetypedef.h"
#include "gr.h"

#define MAX_WINDOWS  40

extern int EMcompare_vectors();


/*

History  
   Jack  11/23/91  Created
   Jack  12/08/91  Added the goto wrapup after the if statement after the
                   dp$inq_set_gragad call.  This should have already been there.
   msm   10/03/92  ANSI-C conversion.

*/


IGRlong EFwin_parallel_ref_pln( EMmsg,
                                md_id,                     
                                rp_z_vector,
                                window_found,
                                window_grid )

IGRlong         *EMmsg;
struct GRid     *md_id;
IGRvector        rp_z_vector;
IGRint          *window_found;
struct GRid     *window_grid;

{
  IGRlong      sts = OM_S_SUCCESS;
  struct GRid  wind_ids[MAX_WINDOWS];
  IGRint       total_num = 0,
               total_returned = 0,
               which_error,
               num;
  IGRlong      bytes_ret;
  struct var_list list[2];
  IGRmatrix    matrix;
  IGRdouble    z_vector[3];
  
  sts = dp$get_gragad_id(msg = EMmsg,
                         mod_GRid = md_id,
                         name = "*",
                         array_size = MAX_WINDOWS,
                         total_num = &total_num,
                         numberofids = &total_returned,
                         found_GRids = wind_ids,
                         type_gragad = IGE_GG | ACTIVE_GG);
  if(!(1 & sts & *EMmsg))
    goto wrapup;
  if(total_returned == 0)
    goto wrapup;

   for(num = 0; num < total_returned; num++)
     {
      list[0].var = WLD_TO_VIEW;
      list[0].var_ptr = (IGRchar *)matrix;
      list[0].num_bytes = sizeof(IGRdouble) * 16;
      list[0].bytes_returned = &bytes_ret;

      list[1].var = END_PARAM;
      list[1].var_ptr = NULL;
      list[1].num_bytes = 0;
      list[1].bytes_returned = NULL;
 
      sts = dp$inq_set_gragad(msg          = EMmsg,
                              osnum        = wind_ids[num].osnum,
                              gragad_objid = wind_ids[num].objid,
                              which_error  = &which_error,
                              var_list     = list);
      if(!(1 & sts & *EMmsg))
         goto wrapup;

      z_vector[0] = matrix[8];       
      z_vector[1] = matrix[9];       
      z_vector[2] = matrix[10];             

      if(EMcompare_vectors(rp_z_vector,
                           z_vector,
                           NULL))
       {
         window_grid->osnum = wind_ids[num].osnum;
         window_grid->objid = wind_ids[num].objid;         
        *window_found = TRUE;         
         goto wrapup;
       }                                                                        
     }

wrapup:  
  return(sts);
}                                 
                    
