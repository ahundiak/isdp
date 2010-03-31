
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

class implementation HStex_table;

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exmacros.h"

#include "hsmacros.h"
#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"
 



method super_construct()

/*
NAME
   super_construct

KEYWORD
   Bundle Tables

DESCRIPTION
   This method initializes the texture table instance data 

PARAMETERS
   none

GLOBALS USED
   none

HISTORY
   --/--/91  Shridar Subramanian

*/

{
 IGRint sts;
 GRobjid  mod_id;
 GRspacenum mod_os;
 unsigned short i;

 mod_os =  OM_Gw_current_OS;
 ex$get_modid( mod_osnum = OM_Gw_current_OS, mod_id = &mod_id );
 me->last_index = 1;
 me->last_offset = 0;

 
 for(i=0;i<8;i++)
  {
         me->tex_file_index[i].offset =-1;
         me->tex_file_index[i].ref_ct = 0;
   }
 sts = om$send(mode = OM_e_wrt_message,
               msg =message global_class.super_construct(),
               targetid = my_id);
 if (!(1&sts))
    return(FALSE);
 else
    return(TRUE);
}


method global_class.sleep(int temp_sleep)

/*
NAME
   sleep

KEYWORD
   Bundle Tables

DESCRIPTION
   This method resets the object id <==>os number array.

PARAMETERS
   none

GLOBALS USED
   none

HISTORY
   --/--/91  Shridar Subramanian
   08/15/94  scw    clarified sleep method

*/

{
/*extern void HSreset_texture_objid();*/

  HSreset_texture_objid(OM_Gw_current_OS);
return(OM_S_SUCCESS);
}



method wake_up()

/*
NAME
   wake_up

KEYWORD
   Bundle Tables

DESCRIPTION
   This method sets the object id <==>os number array.

PARAMETERS
   none

GLOBALS USED
   none

HISTORY
   --/--/91  Shridar Subramanian

*/

{
/*extern void HSset_texture_objid();*/

 HSset_texture_objid(OM_Gw_current_OS, my_id);


return(OM_S_SUCCESS);
}





method retrieve_texture_file(unsigned short index; IGRchar *filename)

/*
NAME
   retrieve_texture_file

KEYWORD
   Bundle Tables

DESCRIPTION
   This method retireves the texture file name, given the index.

PARAMETERS
   index     (IN) - The index of the texture file to be retrieved.
   filename  (OUT)- The retrieved texture filename .

GLOBALS USED
   none

HISTORY
   --/--/91  Shridar Subramanian

*/

{
  
  if (index !=0)
    if (me->tex_file_index[index].offset != -1)
    {
       strcpy(filename, &me->filenames[me->tex_file_index[index].offset]);
       return(TRUE);
    }
  
 
  return(FALSE);
}


method add_ref_ct (unsigned short index)

/*
NAME
   add_ref_ct

KEYWORD
   Bundle Tables

DESCRIPTION
   This method increments the reference count of an entry in the
   texture table.

PARAMETERS
   index     (IN) - The index of the texture file whose ref count is
                    to be incremented.

GLOBALS USED
   none

HISTORY
   --/--/91  Shridar Subramanian

*/

{
  me->tex_file_index[index].ref_ct++;
 
  return(OM_S_SUCCESS);
}


method delete_texture_file(unsigned short index)

/*
NAME
   delete_texture_file

KEYWORD
   Bundle Tables

DESCRIPTION
   This method either deletes an entry in the texture table or
   decrements the ref count associated with that entry, which ever
   is applicable.

PARAMETERS
   index     (IN) - The index of the texture file to be deleted

GLOBALS USED
   none

HISTORY
   --/--/91  Shridar Subramanian
*/

{
  unsigned short curr_vla_size;
  unsigned short actindex;


         if (me->tex_file_index[index].offset !=-1)
         {
		 curr_vla_size = om$dimension_of ( varray = me->tex_file_index);
		 me->tex_file_index[index].ref_ct--;
		 if(me->tex_file_index[index].ref_ct < = 0 )
		    me->tex_file_index[index].ref_ct=0;
		 

		 if(me->tex_file_index[index].ref_ct < = 0 )
		 {
		    hs$get_active_shading_symb(tex_index = &actindex);
		    if (index != actindex)
		    {
		      HSrm_tex_file(me->filenames, me->tex_file_index, index, 
				    &me->last_offset,curr_vla_size);
		      
		    }
		 }
                 return(TRUE);
         }
         else
                 return(FALSE);
}

method debug()

/*
NAME
   debug

KEYWORD
   Bundle Tables

DESCRIPTION
   This method prints out the contents of the texture table in the 
   following format
   filename          ref ct

PARAMETERS
   none

GLOBALS USED
   none

HISTORY
   --/--/91  Shridar Subramanian
*/

{
int i,curr_vla;
    
         curr_vla = om$dimension_of ( varray = me->tex_file_index);

    for(i=1;i<curr_vla;i++)
    
      if (me->tex_file_index[i].offset!=-1)
      {
         printf("Filename %s Ref ct %d\n",&me->filenames[me->tex_file_index[i].offset],me->tex_file_index[i].ref_ct);
      }

    return( OM_S_SUCCESS );
}


method validate_index(unsigned short index;IGRint *valid_index)

/*
NAME
   validate_index

KEYWORD
   Bundle Tables

DESCRIPTION
   This method validates the texture index.

PARAMETERS
   index       (IN) - Index to be validated
   valid_index (OUT) - 0 => invalid index
                       1 => valid index

GLOBALS USED
   none


HISTORY
   --/--/91  Shridar Subramanian
*/

{
   if (me->tex_file_index[index].offset == -1)
         *valid_index = 0;
   else
         *valid_index = 1;
   return( OM_S_SUCCESS );
}
     
end implementation HStex_table;




