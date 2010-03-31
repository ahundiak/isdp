
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
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

#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"
#include "hsmacros.h"

#include "HSpr_bundle.h"


method add_tex_file(IGRchar *filename;  unsigned short *index; unsigned short actindex )

/*
NAME
   add_tex_file

KEYWORD
   Bundle Tables

DESCRIPTION
   This method does the following
       If the filename is already present in the texture table, it returns the
       index.
       else
       It inserts the filename into the texture table using the following rule
          Find a deleted or empty entry  or an entry with ref ct of zero 
          (unless it is the active texture file) and insert it.

PARAMETERS
       filename  (IN) - The filename to be added to the texture table
       index     (OUT)- Index of the resulting add.
       actindex  (IN) - Index of the currently active texture table.

GLOBALS USED
    none

HISTORY
    --/--/91   Shridar SubramaniaN

*/

   
{
    IGRint found, place_found,  cur_file_vla_size;
    unsigned short i,curr_vla_size;

 
    found = 0;
    curr_vla_size = om$dimension_of(varray = me->tex_file_index);
    cur_file_vla_size = om$dimension_of(varray = me->filenames);
    for (i=1;i< curr_vla_size && (!found);i++)
    {
      if (me->tex_file_index[i].offset != -1)
      {
         if (strcmp(filename, &me->filenames[me->tex_file_index[i].offset])==0)
           {
             found = 1;
             *index = i;
           }
      }
    }


    if (!found)
    {
         place_found =0;
         for (i=1;i< curr_vla_size && (!place_found) ; i++)
         {
          if (i!=actindex)
          {
            if (me->tex_file_index[i].ref_ct==0)
            {
              place_found = 1;
              me->tex_file_index[i].offset = me->last_offset;
              cur_file_vla_size = om$dimension_of(varray = me->filenames);
              if ((me->last_offset + strlen(filename) +1) > cur_file_vla_size)
               {
                 om$vla_set_dimension(varray = me->filenames, 
                                      size = me->last_offset + strlen(filename) +2);
               }
                   
              strcpy(&me->filenames[me->last_offset], filename);
              *index = i;
              me->last_offset = me->last_offset +  strlen(filename) +1;
            }
           }
          }             
          if  (!place_found)
          {
            if (curr_vla_size >=255)
               *index =0;
            else
            {
               om$vla_set_dimension(varray = me->tex_file_index,
                                     size = curr_vla_size + 4);
               me->tex_file_index[curr_vla_size ].offset = me->last_offset;
               me->tex_file_index[curr_vla_size ].ref_ct =  0;
               if ((me->last_offset + strlen(filename) +1) > cur_file_vla_size)
               {
                 om$vla_set_dimension(varray = me->filenames,
                                      size = me->last_offset + strlen(filename) +2);
               }

               strcpy(&me->filenames[me->last_offset], filename);
               me->last_offset = me->last_offset + strlen(filename) +1;
               *index = curr_vla_size ;
               for(i=curr_vla_size+1; i< curr_vla_size +4;i++)
               {
                   me->tex_file_index[i].offset = -1;
                   me->tex_file_index[i].ref_ct = 0;
               }
            }
         }
      }
   return(OM_S_SUCCESS);
   }
        







method add_texture_file(IGRchar *filename; IGRint active; unsigned short  *index )

/*
NAME
     add_texture_file

KEYWORD
     Bundle Tables

DESCRIPTION
     This method determines if the active texture file needs to be replaced
     with the current filename . If yes it does so, else it calls the
     add_tex_file method.

PARAMETERS
     filename (IN) - Filename to be added to the texture table
     active   (IN) - Flag indicating whether the filename corresponds an active 
                       texture index parameter.
     index    (OUT) - Index returned.

GLOBALS USED
     none

HISTORY
     --/--/91

*/

{
  int sts;
  unsigned short actindex, curr_vla_size; 

  curr_vla_size = om$dimension_of(varray = me->tex_file_index);

  hs$get_active_shading_symb(tex_index = &actindex);
  if((active) && (actindex !=0))
  {
      if (me->tex_file_index[actindex].ref_ct==0)
      {
         HSrm_tex_file(me->filenames, me->tex_file_index, actindex, 
                       &me->last_offset,curr_vla_size);

         me->tex_file_index[actindex].offset= me->last_offset;
         strcpy(&me->filenames[me->last_offset],filename);
         me->last_offset = me->last_offset  + strlen(filename) +1;
         *index = actindex;
      }
      else
        sts = om$send (msg = message HStex_table.add_tex_file (filename, index,actindex),
	               senderid = my_id,
                       targetid = my_id);
   }
   else
       sts = om$send (msg = message HStex_table.add_tex_file (filename, index,actindex),
	               senderid = my_id,
                       targetid = my_id);
return(OM_S_SUCCESS);
}

  
end implementation HStex_table;
