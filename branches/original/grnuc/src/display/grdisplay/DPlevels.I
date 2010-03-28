/*----
%GP% CODE CLASSIFICATION
-----
%HD%
        CLASS NAME:     IGEgragad
        METHOD NAME:    DPlevels

        Abstract:      turns levels on or off in a window

-----
%SC%
        IGEgragad.DPlevels(&msg,&levels,num,&mask,on_off)
-----
%EN%
        ON ENTRY:

        NAME      DATA TYPE             DESCRIPTION
       ------    -----------            ----------------------------

       *levels	  IGRint		 an array of levels to be turned
					 on or off
					
       *levels_mask IGRint		 a mask of levels to be turned on
					 correspond to the low values
					
					   The levels from low[i] to
					   high[i] will be turned on
					   or off depending on the flag.
					
       num_of_entries IGRint		 the number level entries

       on_off	  IGRint	         whether to turn the levels on
					 or off
					
       update     IGRnit		 whether to update 

-----
%EX%
        ON EXIT:

        NAME    DATA TYPE       DESCRIPTION
       ------  -----------    ----------------------------
        *msg    IGRlong         return status
                                  MSSUCC - successfully completed
                                  MSFAIL - unsuccessfully completed
-----
%MD%
        MODULES AND METHODS INVOKED:

-----
%RL%
        RELATIONS REFERENCED:
-----
%NB%
        NOTES:
-----
%CH%
        CHANGE HISTORY

        AET 11/19/86     : Design date.
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

          This method will turn the levels on or off depending on the
	  on/off flag.  It will turn on/off levels from low[i] to 
	  high[i].
	
----*/
/*EH*/


class implementation IGEgragad;

#include "grimport.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

/* prototype files */
%safe
#include "GRdpbfunc.h"
#include "dpmacgenupd.h"
%endsafe


	method DPlevels(IGRlong *msg; IGRint *levels; IGRint num_of_entries; 
			IGRint *level_mask; IGRboolean on_off;
			IGRboolean update)


{
      IGRint     i,j;
      IGRint     status = TRUE;
      IGRshort   act_level;
      IGRint	 num_bits = sizeof(IGRint)*8;
      IGRint	 num_of_ints = ((DP_NUM_OF_LEVELS - 1) / (num_bits)) + 1;
      IGRint	 old_level[((DP_NUM_OF_LEVELS - 1) / (sizeof(IGRint)*8)) + 1];
      IGRint	 temp_level[((DP_NUM_OF_LEVELS - 1) / (sizeof(IGRint)*8)) + 1];
      IGRboolean need_update = FALSE;
      enum GRdpmode mode;

	
	status = gr$get_active_level(buffer = (IGRchar *)&act_level);
				

	if (level_mask)
	{
	   level_mask[act_level/num_bits] &= ~((IGRint) (1 << (act_level % num_bits)));
	}
	
	for (i=0; i< ((DP_NUM_OF_LEVELS - 1) / (num_bits)) + 1 ; i++)
	{
	   temp_level[i] = 0;
	}
	
	if (on_off == TRUE)
	{
	   mode = GRbd;
	
	   if (levels)
	   {
	      for(i = 0; i < num_of_entries; i++)
	      {
		 if ((levels[i] >= 0) && (levels[i] < DP_NUM_OF_LEVELS))
		 {
		    if (!(ME.IGEgragad->gragad.levels[levels[i]/num_bits] &
			(IGRint) (1 << (levels[i] % num_bits))))
		    {
		       temp_level[levels[i]/num_bits] |= 
					(IGRint) (1 << (levels[i] % num_bits));
					
		       ME.IGEgragad->gragad.levels[levels[i]/num_bits] |= 
					(IGRint) (1 << (levels[i] % num_bits));
					
		       need_update = TRUE;
		
		    }
		 }
	      }
	   }
	   else
	   {
	/* calculate the number of ints needed to contain all 
		the levels					*/
		
	
	      for(i = 0; i < num_of_ints; i++)
	      {
		  for (j=0; j<num_bits; j++)
		  {
		     if ((level_mask[i] & (1 << j)) && 
			 (!(ME.IGEgragad->gragad.levels[i] & (1 << j))))
		     {
			temp_level[i] |= (IGRint) (1 << j);
			need_update = TRUE;
		     }
		  }
		
	          ME.IGEgragad->gragad.levels[i] |= level_mask[i];
	      }
	   }
		
	}
	else
	{
	   mode= GRbe;
	
	   if (levels)
	   {
	      for(i = 0; i < num_of_entries; i++)
	      {
		 if ((levels[i] >= 0) && (levels[i] < DP_NUM_OF_LEVELS) &&
		      (levels[i] != act_level))
		 {
		    if ((ME.IGEgragad->gragad.levels[levels[i]/num_bits] &
			(IGRint) (1 << (levels[i] % num_bits))))
		    {
		       temp_level[levels[i]/num_bits] |= 
					(IGRint) (1 << (levels[i] % num_bits));
					
		       ME.IGEgragad->gragad.levels[levels[i]/num_bits] &= 
					~((IGRint) (1 << (levels[i] % num_bits)));
					
					
		       need_update = TRUE;
		
		    }
		
		    ME.IGEgragad->gragad.levels[levels[i]/num_bits] &= 
					~((IGRint) (1 << (levels[i] % num_bits)));
		 }
	      }
	   }
	   else
	   {
	/* calculate the number of ints needed to contain all 
		the levels					*/
		
	
	      for(i = 0; i < num_of_ints; i++)
	      {
		  for (j=0; j<num_bits; j++)
		  {
		     if ((level_mask[i] & (1 << j)) && 
			 ((ME.IGEgragad->gragad.levels[i] & (1 << j))))
		     {
			temp_level[i] |= (IGRint) (1 << j);
			need_update = TRUE;
		     }
		  }
		
	          ME.IGEgragad->gragad.levels[i] &= ~level_mask[i];
	      }
	   }
		
	}
	
	if (need_update && update)
	{
		
	  for (i=0; i<((DP_NUM_OF_LEVELS - 1) / (num_bits)) + 1; i++)
	  {
	     old_level[i] = ME.IGEgragad->gragad.levels[i];
	     ME.IGEgragad->gragad.levels[i] = temp_level[i];
	  }



	  if (!(ME.IGEgragad->gragad.flags & DP_DELAY))
	  {	
	     status = dp$gen_update(msg = msg,
				 mode = mode,
				 erase = FALSE,
				 objid = my_id);
	  }
	  else
	  {
	     ex$message ( msgnumb = GR_I_DlyOn);
	  }


	  for (i=0; i<((DP_NUM_OF_LEVELS - 1) / (num_bits)) + 1; i++)
	  {
	     ME.IGEgragad->gragad.levels[i] = old_level[i];
	  }
       }

   return(status);
 }

end implementation IGEgragad;
