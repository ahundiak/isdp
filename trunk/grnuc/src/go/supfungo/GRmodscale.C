/* #######################    APOGEE COMPILED   ######################## */

/*\
Name
   GRmodel_scale

Descripiton
   This function will convert a scale string to a scale matrix that
   will scale from reference file coordinates to master file coordinates.

   *msg                 IGRlong        completion code
   *mf_osnum            GRspacenum     osnum of the master file
   *rf_osnum            GRspacenum     osnum of the reference file
   *scale_string        IGRchar        string containing scale value
   rf_to_mf_scale_mx    IGRmatrix      reference file to master file scale

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- if failure

History
   Gray Winn   04/02/87 : Creation
   scw         06/23/92 : Added static ANSI C prototypes
\*/

#include "grimport.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "griomacros.h"

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static IGRint GRparse_rfscale __((IGRchar string[], IGRdouble *rf_conv, 
                                  IGRdouble *mf_conv, IGRdouble *conv));

#if defined(__cplusplus)
}
#endif
#undef __



IGRint GRmodel_scale (msg, mf_osnum, rf_osnum, scale_string,
                      rf_to_mf_scale_mx)
IGRlong     *msg;
GRspacenum  *mf_osnum;
GRspacenum  *rf_osnum;
IGRchar     *scale_string;
IGRmatrix   rf_to_mf_scale_mx;
{
IGRlong     om_msg,msg1;
IGRdouble   rf_conv, mf_conv, conv, rf_wu, mf_wu;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   MAidmx(&msg1, rf_to_mf_scale_mx);

   /*
    *  Call the variable object to convert any names.
    */

   /************ KLUDGE THIS OBJECT IS NOT READY YET **************/

   /*
    *  Call a function to parse the string.
    */

   om_msg = GRparse_rfscale (scale_string, &rf_conv, &mf_conv, &conv);

   if (om_msg == 0)
   {
      *msg = MSFAIL;
      return (OM_S_SUCCESS);
   }else if (om_msg == 2)
   {
      /*
       *  Call a macro to find the number of working units in the
       *  reference file space. 
       */

      om_msg = co$cvt_imp_to_wrk(msg = msg, unit_type = "UOM_DISTANCE",
               primary = rf_conv, result = &rf_wu, osnum = *rf_osnum);

      if ( 1 & om_msg & *msg)
      {

         /*
          *  Call a macro to find the number of working units in the
          *  master file space. 
          */

          om_msg = co$cvt_imp_to_wrk(msg = msg, unit_type = "UOM_DISTANCE",
               primary = mf_conv, result = &mf_wu, osnum = *mf_osnum);

          if ( 1 & om_msg & *msg)
	  {
              conv =  mf_wu / rf_wu;     /* rf to mf conv */
	  }
      }
   }            
   if ( 1 & om_msg & *msg)
   {
   	rf_to_mf_scale_mx[0]  = conv;
   	rf_to_mf_scale_mx[5]  = conv;
   	rf_to_mf_scale_mx[10] = conv;
   }
   else
   {
	om_msg = OM_E_ABORT;
   }

   return (om_msg);
}

/*\
DESCRIPTION
   This function is used to parse a string.  
   <string> = mf_conversion ":" rf_conversion OR conversion
   
   *string        IGRchar           string to be parsed.
   *rf_conv       IGRdouble         reference file conversion factor
   *mf_conv       IGRdouble         master file conversion factor
   *conv          IGRdouble         conversion factor

RETURN VALUES
   0  -  Failure
   1  -  Success  and simple conversion
   2  -  Success  and ratio

HISTORY
     Gray Winn    04/06/87    Creation date.
\*/

static IGRint GRparse_rfscale (string, rf_conv, mf_conv, conv)
IGRchar     string[];
IGRdouble   *rf_conv;
IGRdouble   *mf_conv;
IGRdouble   *conv;
{
IGRint   i, num_char;

   *mf_conv = 0;
   *rf_conv = 0;
   *conv = 0;
   num_char = strlen(string);
   num_char++;

   for (i=0; i < num_char; ++i)
   {
      if (string[i] == ':')
      {
         string[i] = '\0';
         sscanf (string, "%lf", mf_conv);
         string[i] = ':';  
         sscanf (&string[i+1], "%lf", rf_conv);
         if ( (*rf_conv == 0.0) || (*mf_conv == 0.0) ) return (0);
         return(2);
      }
   }

   sscanf (string, "%lf", conv);
   if (*conv == 0.0) return (0);
   return(1);
}
