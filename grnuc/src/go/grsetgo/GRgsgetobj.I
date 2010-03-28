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
     mas          09/05/90    Fixed to work for multiple savesets
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "grgs.h"

%safe 
static int chan_init=0;
static OM_S_CHANSELECT chansel;
%endsafe

method GSget_object (IGRlong *msg; struct GRobj_env array[];
                    IGRint  array_size; IGRint *count; IGRint from_obj; 
                    IGRint to_obj)
{
IGRlong           ret_msg;
IGRint            i;
IGRint            count1;
IGRint            temp = 0;
unsigned int      num_sv;
IGRint		  total_processed;
IGRint		  begin_processing,get_them_all;
IGRint            sv_to_obj;
IGRint            sv_from_obj=0;
IGRint            current_array_size;
IGRint            current_array_index;

   *msg = MSSUCC;

   if (!chan_init)
   {
      om$make_chanselect(channame ="GRgrset.to_sets",
                         p_chanselect= &chansel);
      chan_init = 1;
   }

   current_array_size  = array_size;
   current_array_index = *count;

   /*
    *  Get the total number of objects owned by the graphics set.
    */

   count1 = 0;

   om$send (msg = message GRgrset.GSinqcount (&ret_msg, &count1),
            targetid = my_id);

   count1--;   /* Make count relative to zero */

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
                         p_chanselect = &chansel, 
                         count = &num_sv);

   sv_to_obj = to_obj;
   total_processed = 0;
   begin_processing = 0;

   for (i = 0;
        i < num_sv && current_array_size > 0 && total_processed <= to_obj;
        i++)
   {
      count1 = 0;

      om$send (msg = message GRgrset.GSinqcount (&ret_msg, &count1),
               p_chanselect = &chansel,
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
                      p_chanselect = &chansel,
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
   return (OM_S_SUCCESS);
}
end implementation GRgrset;
