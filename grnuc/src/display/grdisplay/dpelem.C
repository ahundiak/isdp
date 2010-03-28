#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

/* prototype files */
#include "dpdiselem.h"
#include "dpelem.h"


IGRint DPelem(msg, buffer, dpmode, dp_info)

   IGRlong 			*msg;
   struct DPele_header		*buffer;
   enum GRdpmode 		dpmode;
   struct DP_information 	*dp_info;

   {
      IGRint  status, sts;


	status = DPdiselem( &sts, buffer, &dpmode, dp_info);
	*msg = sts;
	return(status);
	
   }
