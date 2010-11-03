class implementation Root;

#include <stdio.h>                      /* Needed for print statements */
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "EMSopt.h"
#include "igr.h"
#include "maerr.h"
#include "EMSbnddef.h"
#include "EMSlogic.h"
#include "EMSmsgdef.h"
#include "EMScmacros.h"
#include "OMmacros.h"
#include "EMSlmdef.h"
#include "EMSdpb.h"
#include "godef.h"
#include "exfi.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dim.h"
#include "dimdef.h"
#include "DItypedef.h" /* Following files are for di$translate */
#include "DIdef.h" 
#include "DIglob.h" 
#include "DIprims.h"
#include "madef.h"
#include "SKdef.h"
#include "emserr.h"
#include <alloca.h> 	/*DLB addition 3/12/92*/
#include "EC_S.h"
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if (! (1 & sts_stupid & error_number)) goto wrapup;\
 }

from DMroot import return_dim_go,get_info;
from expression import modify;

  void  EMsense(EMmsg,
                num_of_dim,
                driving_dimension_name,
                driving_dimension_grid,
                driven_dim_type,
                driving_dim_value,
                driving_dim_low_tol,
                driving_dim_hi_tol,
                driving_dim_sel,
                driven_dimension_grid,
                driven_dimension_env,
                sensitivity,
                percent_contribution)

        struct GRmd_env  *driven_dimension_env;
        struct GRid      *driven_dimension_grid, *driving_dimension_grid;
     IGRdouble           *driving_dim_hi_tol,
                         *driving_dim_value;
     IGRdouble           *driving_dim_low_tol;
     IGRdouble           *sensitivity;
     IGRdouble           *percent_contribution ;

        int     *num_of_dim,
                *driven_dim_type;

        IGRint      *driving_dim_sel;
        IGRlong     *EMmsg;
        IGRchar     *driving_dimension_name[];
  {

        IGRlong           msg = EMS_S_Success;
        struct GRmd_env   *env;
        struct diminfo    drive_dim_info;
        struct GRid       driven_dim_grid;
        struct GRid       driving_dim_grid;
        IGRchar           temp_name[DI_PATH_MAX], new_value[DI_PATH_MAX];
        IGRdouble         *out_range,  *sigma_squard;
        IGRdouble         value,del_value,old_value_0=0, old_value_1=0;
        IGRdouble         sum, sigma_squard_HLM = 0.0;
        IGRint            sts1, sts, ii,iii, jj;
        IGRint            old_index_0=0, old_index_1=0;
        extern IGRboolean ASbroadcast_in_progress;
        IGRboolean        save;
        IGRchar           string1[60];

        out_range = (IGRdouble *)alloca(*num_of_dim * sizeof(IGRdouble));
        sigma_squard= (IGRdouble *)alloca(*num_of_dim * sizeof(IGRdouble));

        env = driven_dimension_env;
        driven_dim_grid = *driven_dimension_grid;

        sts = sts1 = OM_S_SUCCESS;

           sts = om$send (msg = message DMroot.get_info((IGRint *)&msg,
                            env, &drive_dim_info),
               senderid = NULL_OBJID,
               targetid = driven_dim_grid.objid,
               targetos = driven_dim_grid.osnum);
           ERROR(sts, 1, "get info error")
       
      sigma_squard_HLM = 0.0;
      for(ii=0,iii=0; ii< *num_of_dim; ii++)
      {
        *(sensitivity+ii) = 0.; 
        sigma_squard[ii] = 0.;
        out_range[ii]=0.;
        if( *(driving_dim_sel +ii)== 1)
        {
           strcpy(string1,driving_dimension_name[ii]);
           ex$message(msgnumb =  EMS_S_AnalzingSens,
             var = string1,
             type = "%s");

           driving_dim_grid = *(driving_dimension_grid+ii);
           old_index_1=ii;
           old_value_1 = *(driving_dim_value+ii);
           sum=0.0;

         for(jj=0;jj<2;jj++)
            {
            save = ASbroadcast_in_progress;
            ASbroadcast_in_progress = TRUE;

           if(jj ==0 && iii > 0)
             {
             value = old_value_0  ; 
             temp_name[0] = '\0';
             new_value[0] = '\0';
             sprintf(new_value,"%lf",value);
             sts = om$send (msg = message expression.modify(temp_name,
                           new_value,(IGRshort *)&msg),
               senderid = NULL_OBJID,
               targetid = driving_dimension_grid[old_index_0].objid,
               targetos = driving_dimension_grid[old_index_0].osnum);
             }

           if(jj == 0)
              del_value = *(driving_dim_hi_tol+ii);
           else
              del_value = *(driving_dim_low_tol+ii);

           value = old_value_1 + del_value ; 

           temp_name[0] = '\0';
           new_value[0] = '\0';

           sprintf(new_value,"%lf",value);
           sts = om$send (msg = message expression.modify(temp_name,
                           new_value,(IGRshort *)&msg),
               senderid = NULL_OBJID,
               targetid = driving_dim_grid.objid,
               targetos = driving_dim_grid.osnum);


           sts1 = nd$update_graph(cn_type = ND_COMP_NO_DISPLAY |
                                      ND_COMP_NO_ERASE, md_env =  env);
           ASbroadcast_in_progress = save;
           /* ERROR(sts1, 1, "update graph error") */

           if(!(sts&msg))
            {
            fprintf(stderr,"Expression modify error :\n");
            fprintf(stderr,
           "ignoring dimension %s in analysis. \n", driving_dimension_name[ii]);
            *driving_dim_sel = 3;

             EMrestore(EMmsg,
                   num_of_dim,
                   driving_dimension_grid,
                   driven_dim_type,
                   driving_dim_value,
                   driving_dim_sel,
                   env);
             ERROR(sts, 1, "restore values error")
             break;
             }

           sts = om$send (msg = message DMroot.get_info((IGRint *)&msg,
                            env, &drive_dim_info),
               senderid = NULL_OBJID,
               targetid = driven_dim_grid.objid,
               targetos = driven_dim_grid.osnum);
           ERROR(sts, 1, "get info error")

          if( *driven_dim_type == STACKED_ANGULAR ||
                   *driven_dim_type == SINGLE_ARC_ANGLE ||
                        *driven_dim_type == STRINGED_ANGULAR)
                             drive_dim_info.dim_value *= 180.0/PI;
            if(jj == 0)
              sum += drive_dim_info.dim_value;
            else
              sum -= drive_dim_info.dim_value;

            }

         out_range[ii] = *(driving_dim_hi_tol+ii) - *(driving_dim_low_tol+ii);
         if(!(out_range[ii] == 0.0))
          *(sensitivity+ii) = sum / out_range[ii]; 
         sigma_squard[ii] = sum * sum / 36;
         sigma_squard_HLM  += sigma_squard[ii];
         iii++;
         old_value_0 = old_value_1;
         old_index_0 = old_index_1;
        }
      }
     

     for(iii=0;iii< *num_of_dim;iii++)
     {
     if(sigma_squard_HLM == 0)
       *(percent_contribution+iii)= 0.;
     else
       *(percent_contribution+iii)= sigma_squard[iii]/ sigma_squard_HLM * 100.;
     }
    

 wrapup:
     *EMmsg=msg;
     EMWRAPUP(msg, sts, "EMsense");
 return;
}

end implementation Root;




