class implementation Root;

#include <stdio.h>                      /* Needed for print statements */

%safe
#include <math.h>
%endsafe
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "EMSopt.h"
#include "gr.h"
#include "igr.h"
#include "maerr.h"
#include "EMSbnddef.h"
#include "EMSlogic.h"
#include "EMSmsgdef.h"
#include "EMScmacros.h"
#include "OMmacros.h"
#include "EMSlmdef.h"
#include "EMSdpb.h"
#include "nddef.h"
#include "ndmacros.h"
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


#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if (! (1 & sts_stupid & error_number)) goto wrapup;\
 }

from DMroot import return_dim_go,get_info;
from expression import modify;

  double floor() ;

  void  EMstats1(num_of_dim,
                driving_dimension_grid,
                driving_dim_type,
                driving_dim_value,
                driving_dim_low_tol,
                driving_dim_hi_tol,
                driving_dim_sel,
                driving_dim_dist_name,
                driving_dim_sigma,
                driving_dim_mu,
                driving_dim_eta,
                driving_dim_sense,
                drivn_dim_grid,
                drivn_dim_moments,
                histogram,
                driven_dim_env,
                number)

        struct GRmd_env  *driven_dim_env;
        struct GRid  *drivn_dim_grid;
        struct GRid  *driving_dimension_grid;

        int  *num_of_dim, number;

        IGRboolean   *driving_dim_sel;

        double  *driving_dim_hi_tol,
                *driving_dim_type,
                *driving_dim_value,
                *driving_dim_low_tol,
                *histogram,
                *driving_dim_sigma,
                *driving_dim_mu,
                *driving_dim_eta,
                *driving_dim_sense,
                *drivn_dim_moments;

        char    *driving_dim_dist_name;
  {
        IGRlong msg = EMS_S_Success;
        long  seed ;
        IGRchar    temp_name[DI_PATH_MAX], new_value[DI_PATH_MAX];

        struct GRmd_env *env;
        struct diminfo  drive_dim_info;
        struct GRid driven_dim_grid;
        struct GRid driving_dim_grid;

        double sigma  ;
        double devs;
        double sum=0.0;
        double driven_dim_value[1000];
        double squar_sum[1000] ,moment, doment,
               driven_dim_max,driven_dim_min;
        double value;
        double  deviation;

        extern IGRboolean ASbroadcast_in_progress;
        IGRboolean save;

        IGRint ij, ii, jj;
        IGRlong sts;

      env =  driven_dim_env;
      driven_dim_grid = *drivn_dim_grid;

/*********** start monte carlo simulation ****************/

      seed = -1;

  for(jj=0; jj<number; jj++)
   {
    for(ii=0; ii< *num_of_dim; ii++)
     {
      /**** get driving dimension random values *******************/

     if( *(driving_dim_sel+ii) == TRUE)
     {
       switch( *(driving_dim_dist_name + ii) )
       {
       case 'T':  /* truncated normal */
       case 't':
               if(*(driving_dim_sigma +ii) == 0.)
               *(driving_dim_sigma +ii) =
                    (*(driving_dim_hi_tol+ii)- *(driving_dim_low_tol+ii))/4 ;
               do{
               EMgauss(&seed,&devs);
               devs =  *(driving_dim_value+ii)  + 
                       ( *(driving_dim_sigma +ii) * devs); 
               }while(
                   ( devs > *(driving_dim_value+ii)+ *(driving_dim_hi_tol+ii) )
                || ( devs < *(driving_dim_value+ii)+ *(driving_dim_low_tol+ii) )
                     );
               break;

       case 'n':
       case 'N':  /* normal */
               if(*(driving_dim_sigma +ii) == 0.)
                  *(driving_dim_sigma + ii) = 
                     (*(driving_dim_hi_tol+ii)- *(driving_dim_low_tol+ii))/6;
               EMgauss(&seed,&devs);
               devs =  *(driving_dim_value+ii)  + 
                       ( *(driving_dim_sigma +ii) * devs); 
               break;

       case 'd':
       case 'D':  /* default normal */
               sigma=(*(driving_dim_hi_tol+ii)- *(driving_dim_low_tol+ii))/6 ;
               EMgauss(&seed,&devs);
               devs =  *(driving_dim_value+ii)+ (sigma  *  devs); 
               break;

       case 'w':
       case 'W':  /* weibull */
               do{
               EMweibull( (driving_dim_sigma +ii),
                          (driving_dim_eta +ii),
                          &seed,
                          &devs);
               devs += *(driving_dim_mu+ii);
               }while(
                   ( devs > *(driving_dim_value+ii)+ *(driving_dim_hi_tol+ii) )
                || ( devs < *(driving_dim_value+ii)+ *(driving_dim_low_tol+ii) )
                     );
               break;

       case 'u':   /* uniform */
       case 'U':
               EMrand(&seed,&devs);
               devs *= (*(driving_dim_hi_tol+ii) - *(driving_dim_low_tol+ii));
               devs += *(driving_dim_value+ii);
               break;
                   /* and more may be */
       }

      /**** recalculate driven dimension **********************/

           if ((*(driving_dim_type+ii) == STACKED_ANGULAR) ||
              (*(driving_dim_type+ii) == STRINGED_ANGULAR))
               value = devs  * PI/180; 
           else
               value = devs ; 

           temp_name[0] = '\0';
           new_value[0] = '\0';

           driving_dim_grid = *(driving_dimension_grid+ii);

           sprintf(new_value,"%lf",value);
           sts = om$send (msg = message expression.modify(temp_name,
                           new_value,(IGRshort *)&msg),
               senderid = NULL_OBJID,
               targetid = driving_dim_grid.objid,
               targetos = driving_dim_grid.osnum);
           ERROR(sts, msg, "SKexplicit.SKstorevalue.error");

           save = ASbroadcast_in_progress;
           ASbroadcast_in_progress = TRUE;
         sts = nd$update_graph(cn_type = ND_COMP_NO_DISPLAY | ND_COMP_NO_ERASE,
                                  md_env = env);
           ASbroadcast_in_progress = save;

       }
/*
         save = ASbroadcast_in_progress;
         ASbroadcast_in_progress = TRUE;
         sts = nd$update_graph(cn_type = ND_COMP_NO_DISPLAY | ND_COMP_NO_ERASE,
                                 md_env = env);
         ASbroadcast_in_progress = save;
*/
     }

           sts = om$send (msg = message DMroot.get_info((IGRint *)&msg,
                            env, &drive_dim_info),
               senderid = NULL_OBJID,
               targetid = driven_dim_grid.objid,
               targetos = driven_dim_grid.osnum);
           ERROR(sts, 1, "get info error")

          driven_dim_value[jj]= drive_dim_info.dim_value;
          sum +=  drive_dim_info.dim_value;
          squar_sum[jj] = drive_dim_info.dim_value * drive_dim_info.dim_value;
      
   }
 
/************** calculate statistics *************************/

      moment = sum/number;

      doment = 0.;
      for(jj=0;jj< number;jj++)
     {
      doment += (squar_sum[jj] - moment * moment);
     }
      if(doment > 0 )
        doment = sqrt(doment/number);
      else
        doment = 0;

      *drivn_dim_moments = moment;
      *(drivn_dim_moments+1) = doment;
      
      driven_dim_max = moment + 3* doment;
      driven_dim_min = moment - 3* doment;

      for(ii=0;ii<9;ii++)
        *(histogram+ii)=0.;

      for(ii=0; ii< number ;ii++)
         {
            deviation = (driven_dim_value[ii] - moment )/ doment;
            ij = (int)floor(deviation);
            *(histogram+4+ij) += 1.;
         }

      for(ii=0;ii<8;ii++)
         *(histogram+ii) *= 100.0/number;
                            
/*************************** restore values ***********************************/

      for(ii=0;ii< *num_of_dim;ii++)
        {
        if( *(driving_dim_sel + ii) == TRUE)
          {
           if ((*(driving_dim_type+ii) == STACKED_ANGULAR) ||
               (*(driving_dim_type+ii) == STRINGED_ANGULAR))
                value = *(driving_dim_value+ii)   * PI/180; 
           else
                value = *(driving_dim_value+ii)  ; 

           temp_name[0] = '\0';
           new_value[0] = '\0';

           sprintf(new_value,"%lf",value);
           sts = om$send (msg = message expression.modify(temp_name,
                           new_value,(IGRshort *)&msg),
               senderid = NULL_OBJID,
               targetid = driving_dim_grid.objid,
               targetos = driving_dim_grid.osnum);
           ERROR(sts, msg, "SKexplicit.SKstorevalue.error");

           save = ASbroadcast_in_progress;
           ASbroadcast_in_progress = TRUE;
           sts = nd$update_graph(cn_type =ND_COMP_NO_ERASE | ND_COMP_NO_DISPLAY,
           md_env =  env);
           ASbroadcast_in_progress = save;
          }
        }
wrapup:
 return;
}
end implementation Root;
