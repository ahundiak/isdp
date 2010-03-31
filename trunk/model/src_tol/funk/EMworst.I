/* ###################   APOGEE COMPILED   ################## */

/******

	History:

	Created  :   ????
	Satya    :   When driving dimensions cause  the driven dimension to 
        (30/8/94)    flip about its dimension origin, the results are 
                     incorrect. TR# 11925069. 

		     while calculating the worst case low value of a driven 
                     dimension, the value got from a dimension method 
		     "DMroot.get_info" is given as the low value. But
                     the method gives just the distance between the two 
                     lines and does not take care of the sign. Hence the 
                     value which is negative for the test case is printed as 
                     positive. While computing the values of worst case 
		     tolerances for driving dimensions the delta values by 
                     which the driving dimensions change are computed for
		     high values and low values independently.

                     The sum of absolute values of the delta values computed 
	             give the total movement of the line segments between 
                     which the driven dimension is placed.  Here it is assumed 
                     that the delta values got from high value computation of
		     driving dimensions always contribute towards increasing 
	             the driven dimension and delta values from low value 
                     computation towards decreasing the dimension.
		     While calculating the worst case low value of driven 
                     dimension, if the original driven dimension between the 
                     lines is lesser than the total of the low value's  delta 
		     values , the sign is reversed for the driven dimension 
                     value computed.
*****/

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
#include "msdef.h"
#include "msmacros.h"
#include "EC_S.h"
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


void EMworst(  EMmsg,
               num_of_dims,
               driving_dim_name,
               driving_dim_grid,
               driven_dim_type,
               driving_dim_value,
               driving_dim_hi_tol,
               driving_dim_low_tol,
               driving_dim_sel,
               driven_dim_grid,
               env,
               sensitivity,
               driving_dim_worst_val1,
               driving_dim_worst_val2,
               driven_dim_worst_val1,
               driven_dim_worst_val2 )

 IGRint        *num_of_dims, *driven_dim_type, *driving_dim_sel;

 IGRdouble     *driving_dim_value, 
               *driving_dim_hi_tol, 
               *sensitivity,
               *driving_dim_worst_val1,
               *driving_dim_worst_val2,
               *driven_dim_worst_val1,
               *driven_dim_worst_val2,
               *driving_dim_low_tol;

 struct GRid   *driving_dim_grid;
 struct GRid   *driven_dim_grid;
 struct GRmd_env  *env;
 IGRlong          *EMmsg;
 IGRchar *driving_dim_name[];

 {
    
  struct  GRid     driving_grid, driven_grid;
  struct  diminfo  driven_dim_info;
  double           del_value, value;
  IGRchar          temp_name[DI_PATH_MAX] ;
  IGRchar          new_value[DI_PATH_MAX] ;
  IGRboolean       save;
  int              jj, ii, sts=OM_S_SUCCESS;
  IGRlong          msg=EMS_S_Success;
  IGRchar          string1[60];
  double	   del_value_lo;
  struct  diminfo  driven_dim_orig_info;

  extern IGRboolean ASbroadcast_in_progress;

/********************* worst case tolerance **************************/

  driven_grid = *(driven_dim_grid);
  
  sts = om$send (msg = message DMroot.get_info((IGRint *)&msg,
                            env, &driven_dim_orig_info),
        senderid = NULL_OBJID,
        targetid = driven_grid.objid,
        targetos = driven_grid.osnum);
  ERROR(sts, 1, "get info error")

  if(*driven_dim_type == STACKED_ANGULAR  || *driven_dim_type == SINGLE_ARC_ANGLE ||
        *driven_dim_type == STRINGED_ANGULAR)
    driven_dim_orig_info.dim_value *= 180.0/PI;
 
  del_value_lo = 0.0;
  
  for(jj=0;jj<3;jj++)
  {
  save = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;
     for(ii=0;ii< *num_of_dims;ii++)
     {
       if( *(driving_dim_sel + ii) == 1)
        {
         strcpy(string1, driving_dim_name[ii]);
         ex$message( msgnumb = EMS_S_AnalzingWsCs,
                     var = string1,
                     type  = "%s" );

          driving_grid = *(driving_dim_grid+ii);

          del_value = 0.0;
          if(jj == 0)
           {
           if( *(sensitivity+ii) > 0)
             del_value = *(driving_dim_hi_tol+ii);
           else if( *(sensitivity+ii) < 0)
             del_value = *(driving_dim_low_tol+ii);
           }
           else if(jj==1)
           {
           if( *(sensitivity+ii) < 0)
             del_value = *(driving_dim_hi_tol+ii);
           else if( *(sensitivity+ii) > 0)
             del_value = *(driving_dim_low_tol+ii);
           del_value_lo = del_value_lo + fabs(del_value);
           }
           else
            del_value = 0.0;

           value = *(driving_dim_value+ii) + del_value ; 

           temp_name[0] = '\0';
           new_value[0] = '\0';

           sprintf(new_value,"%lf",value);
           if(jj==0)
             *(driving_dim_worst_val1+ii) = value;
           else if(jj==1) 
             *(driving_dim_worst_val2+ii) = value;

           
           sts = om$send (msg = message expression.modify(temp_name,
                           new_value,(IGRshort *)&msg),
               senderid = NULL_OBJID,
               targetid = driving_grid.objid,
               targetos = driving_grid.osnum);

           if(!(sts&msg))
           {
             fprintf(stderr,"Expression modify error: \n");
             fprintf(stderr,"dimension %s \n", driving_dim_name[ii]);
             *(driving_dim_sel + ii) = 3; 
           }
      
        }
     }
     sts = nd$update_graph(cn_type =ND_COMP_NO_ERASE | ND_COMP_NO_DISPLAY, md_env =  env);
     ASbroadcast_in_progress = save;

     sts = om$send (msg = message DMroot.get_info((IGRint *)&msg,env,&driven_dim_info),
                    senderid = NULL_OBJID,
                    targetid = driven_grid.objid,
                    targetos = driven_grid.osnum);
     ERROR(sts, 1, "get info error")

     if(*driven_dim_type == STACKED_ANGULAR  || *driven_dim_type == SINGLE_ARC_ANGLE ||
        *driven_dim_type == STRINGED_ANGULAR)
           driven_dim_info.dim_value *= 180.0/PI;
     if(jj==0)
       *driven_dim_worst_val1 = driven_dim_info.dim_value;
     /****
     If the original value of driven dimension is lesser than
     final net value of the modified dimension the sign of the
     dimension is now being reversed. TR# 11925069 - Satya
     ***/
     else if(jj==1)
     {
       if(driven_dim_orig_info.dim_value < del_value_lo)
         driven_dim_info.dim_value = -driven_dim_info.dim_value;
       *driven_dim_worst_val2 = driven_dim_info.dim_value;
     }
  }

/**************************** restore values *****************************
*************************************************************************/

   wrapup:

   *EMmsg = msg;
   EMWRAPUP(msg, sts, "EMworst");
   return;
 }

end implementation Root;

