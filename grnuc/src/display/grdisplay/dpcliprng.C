
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "msdef.h"

/* prototype files */
#include "dpsetrng.h"
#include "dpclpstack.h"
#include "dpgetrng.h"
#include "dpcliprng.h"

#define min(a,b) (a < b ? a : b)
#define max(a,b) (a > b ? a : b)

IGRint DPintr_clp_rng(msg, old_range,range,dp_info)

   IGRlong 			*msg;
   IGRdouble			*old_range;
   IGRdouble			*range;
   struct DP_information	*dp_info;


    {


     IGRdouble	 dit_range[6];
     IGRdouble   temp_range[6];
     IGRdouble	 *cur_range;
     IGRshort	 rect;
     IGRshort	 front;
     IGRshort	 back;
     IGRint	 ret_val;


	ret_val = TRUE;
	*msg = MSSUCC;

	DPgetrng(msg, (IGRdouble *)dp_info->gragad->wld_to_viewport,
		     &dp_info->gragad->range_chk,range,dit_range);

	cur_range = dp_info->gragad->dit_clip_range;


	if (!DPintr_2_rng(msg,dit_range,cur_range,temp_range))
	{
	   ret_val = FALSE;
	}
	else
	{
	   old_range[0] = cur_range[0];
	   old_range[1] = cur_range[1];
	   old_range[2] = cur_range[2];
	   old_range[3] = cur_range[3];
	   old_range[4] = cur_range[4];
	   old_range[5] = cur_range[5];

	   cur_range[0] = temp_range[0];
	   cur_range[1] = temp_range[1];
	   cur_range[2] = temp_range[2];
	   cur_range[3] = temp_range[3];
	   cur_range[4] = temp_range[4];
	   cur_range[5] = temp_range[5];

           rect = dp_info->gragad->flags & CLIP;
           front = dp_info->gragad->flags & FRONT_CLIP;
           back = dp_info->gragad->flags & BACK_CLIP;

           /* added vw_volume parameter for OPENGL setup for perspective */	
           DPpush_clip(msg,rect,front,back,temp_range,
		    dp_info->gragad->gpipe_id, dp_info->gragad->vw_volume );

	}



	return(ret_val);
    }


void DPreset_clp_rng(msg,old_range,dp_info)

   IGRlong 			*msg;
   IGRdouble			*old_range;
   struct DP_information	*dp_info;

  {


    IGRshort	rect;
    IGRshort	front;
    IGRshort	back;
    IGRdouble	*range;


	range = dp_info->gragad->dit_clip_range;

	rect = dp_info->gragad->flags & CLIP;
 	front = dp_info->gragad->flags & FRONT_CLIP;
	back = dp_info->gragad->flags & BACK_CLIP;

        /* added vw_volume parameter for OPENGL setup for perspective */	
        DPpush_clip(msg,rect,front,back,old_range,
		    dp_info->gragad->gpipe_id , dp_info->gragad->vw_volume );
    

	range[0] = old_range[0];
	range[1] = old_range[1];
	range[2] = old_range[2];
	range[3] = old_range[3];
	range[4] = old_range[4];
	range[5] = old_range[5];


   }


IGRint	DPintr_rng(msg,wld_range,dit_range,matrix,new_dit_range)

   IGRlong	*msg;
   IGRdouble	*wld_range;
   IGRdouble	*dit_range;
   IGRdouble	*matrix;
   IGRdouble	*new_dit_range;

{

    struct DPrange_check	range_chk;
    IGRdouble			new_range[6];
    IGRint			ret_val;


	ret_val = TRUE;
	*msg = MSSUCC;
 
	DPsetrng(msg,matrix,&range_chk);
	DPgetrng(msg,matrix,&range_chk,wld_range,new_range);


	ret_val= DPintr_2_rng(msg,new_range,dit_range,new_dit_range);
	

	return(ret_val);

}



IGRint	DPintr_2_rng(msg,range1,range2,new_range)

   IGRlong	*msg;
   IGRdouble    *range1;
   IGRdouble    *range2;
   IGRdouble	*new_range;

{

   IGRint ret_val;

	ret_val = TRUE;
	*msg = MSSUCC;

	new_range[0] = max(range1[0],range2[0]);
	new_range[1] = max(range1[1],range2[1]);
	new_range[2] = max(range1[2],range2[2]);
	new_range[3] = min(range1[3],range2[3]);
	new_range[4] = min(range1[4],range2[4]);
	new_range[5] = min(range1[5],range2[5]);	


	if (new_range[0] > new_range[3])
	{
	   ret_val = FALSE;
	   *msg = MSFAIL;
	}
	else
	{
	   if (new_range[1] > new_range[4])
	   {
	      ret_val = FALSE;
   	      *msg = MSFAIL;
	   }
	   else 
	   {
	      if (new_range[2] > new_range[5])
	      {
		 ret_val = FALSE;
	         *msg = MSFAIL;
	      }
	   }
	}

	return(ret_val);
}

