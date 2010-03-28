/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSget_object 

Description
   This method will return the object and module environment for the
   objects between from_obj and to_obj.

   *msg          IGRlong              return code
   array[]       struct GRobj_env     An array of GRid's and module
                                      environments.
   array_size    IGRint               Size of array in bytes.
   *count        IGRint               The number of objects returned.
   from_obj      IGRint               The base index
   to_obj        IGRint               The high index

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     mrm          09/05/90    Fixed to work for multiple savesets
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "grgs.h"

%safe 
static int chan_init=0;
static OM_S_CHANSELECT to_overlap;
%endsafe

method GSget_object (IGRlong *msg; struct GRobj_env array[];
                    IGRint  array_size; IGRint *count; IGRint from_obj; 
                    IGRint to_obj)
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRint            i;
IGRint            count1, count2;
IGRint            temp = 0;
unsigned int      num_sv;
IGRint		  total_processed;
IGRint		  begin_processing,get_them_all;
IGRint            sv_to_obj;
IGRint            sv_from_obj = 0;
IGRint            current_array_size;
IGRint            current_array_index;

   *msg = MSSUCC;

   /* send to GRgrset to pick up the objects on the to_sets channel */

   om_msg = om$send (mode = OM_e_wrt_message,
                     msg = message GRgrset.GSget_object
                          (msg, array, array_size, count, from_obj, to_obj),
                     targetid = my_id);

   if (!(om_msg & *msg & 1)) goto finish;

   /* now get the objects on the overlap channel */

   if (!chan_init)
   {
      om$make_chanselect(channame ="GRfcset.clip_overlap",
                         p_chanselect= &to_overlap);
      chan_init = 1;
   }

   current_array_size  = array_size;
   current_array_index = *count;

   /* get a count of the objects already processed in GRgrset */

   count2 = 0;

   om$send (mode = OM_e_wrt_message,
            msg = message GRgrset.GSinqcount (&ret_msg, &count2),
            targetid = my_id);

   if (to_obj < count2) goto finish;   /* already finished */

   /*
    *  Get the total number of objects owned by the graphics set.
    */

   count1 = 0;

   om$send (msg = message GRgrset.GSinqcount (&ret_msg, &count1),
            targetid = my_id);

   /* make count relative to zero */

   count1--;

   /* 
    *  Validation 
    */

   if ((from_obj > count1) || (from_obj < 0) || (to_obj < 0) || (!array_size))
   {
      *count = 0;
      *msg = MSFAIL;
      return (OM_S_SUCCESS);
   }

   if (to_obj >= count1)
   {
      to_obj = count1;
      get_them_all = 1;
   }
   else
   {
      get_them_all = 0;
   }

   /*
    *  Get the channel count of the number of savesets.
    */

   om$get_channel_count (object= me,
                         p_chanselect = &to_overlap, 
                         count = &num_sv);

   sv_to_obj = to_obj;
   total_processed = count2;
   begin_processing = 0;

   for (i = 0;
        i < num_sv && current_array_size > 0 && total_processed <= to_obj;
        i++)
   {
      count1 = 0;

      om$send (msg = message GRgrset.GSinqcount (&ret_msg, &count1),
               p_chanselect = &to_overlap,
               from = i,
               to = i);

      if (count1)
      {
	 if (!begin_processing)
	 {
	    if (total_processed + count1 >= from_obj)
	    {
	        begin_processing = 1;
		sv_from_obj = from_obj - total_processed;
                if (sv_from_obj < 0) sv_from_obj = 0;
	    }
	 }
	 if (begin_processing)
	 {
	     if (!get_them_all)
	     {
	     	sv_to_obj = to_obj - total_processed;
	     }

             om$send (msg = message GRgrset.GSget_object
                           (&ret_msg, &array[current_array_index],
                            current_array_size, &temp,
                            sv_from_obj, sv_to_obj),
                      p_chanselect = &to_overlap,
                      from = i,
                      to = i);

              sv_from_obj = 0;
              current_array_size -= temp * sizeof (struct GRobj_env);
              current_array_index += temp;
	      *count += temp;
	      temp = 0;
         }
	 total_processed += count1;
      }
   }   

finish:

   return (OM_S_SUCCESS);
}
end implementation GRfcset;
