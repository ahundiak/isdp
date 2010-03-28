/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRunit

    METHOD NAME:  GRunitdel_als
     

     CHANGE HISTORY: 

     Design Date:     BMR  12/03/86     
     Fixes, Comments: DLW  03/14/89

----*/

class implementation GRunit;

#include "grimport.h"
#include "OMmacros.h"

method GRunitdel_als(IGRlong          *msg;          /* return code           */
                     GRIOalias_name   *alias;        /* alias to be removed   */
                     IGRshort         *def_index;    /* value alias points to */
                     IGRboolean       *last_alias_deleted;
                     IGRshort         *flag)         /* are all aliases which */
						     /* point to this value to*/
						     /* be  deleted?          */
{
  IGRlong              status = 1;
  IGRshort             i,j,index=0;
  IGRboolean           located;
  struct               GRIOalias_entry search_alias;
  IGRint               len;
  IGRint               loc_msg = 0;

  *msg = MSSUCC;
  *last_alias_deleted = TRUE;
  
  len = strlen((IGRchar *)alias);
  if(len >= GRIO_MAX_ALIAS_SIZE) 
    {
      len = GRIO_MAX_ALIAS_SIZE-1;
      loc_msg = GRIO_W_ALIAS_TRUNC;
    }
  strncpy(search_alias.alias,(IGRchar *)alias,len);
  search_alias.alias[len]=0;
  for(i=0; search_alias.alias[i] != 0; i++)
    {
      search_alias.alias[i] = toupper(search_alias.alias[i]);
    }
  for (index=0; (index < ME.GRunit->num_alias && status); index++)
    {
      status = strcmp(ME.GRunit->alias_list[index].alias,search_alias.alias);
    }
  index--;
  if(status != 0)        /* alias not found in list */
    {
      *msg = MSFAIL;
      goto quit;
    }
  
  /*
   * get index into the array of values
   */
  *def_index = ME.GRunit->alias_list[index].index;
  
  status = om$send(msg = message GRunit.GRunitfin_als( msg,
						      (GRIOalias_name *)alias,
						      def_index,
						      &located),
		   targetid = my_id);
  
  /*
   * remove aliase(s)
   */
  if((index==0) && (ME.GRunit->num_alias==1))   /* only one alias left */
    {
      *last_alias_deleted = TRUE;
      
      ME.GRunit->num_alias--;
      status = OM_SET_DIMENSION(ME.GRunit->alias_list,
				ME.GRunit->num_alias);
    }
  else if(*flag)                           /* remove all associated aliases */
    {
      for(i=0; i<ME.GRunit->num_alias; i++)
	{
	  if(ME.GRunit->alias_list[i].index == *def_index)
	    {
	      for(j=(index); j<(ME.GRunit->num_alias-1); j++)
		{
		  len = strlen(ME.GRunit->alias_list[j+1].alias);
		  if(len >= GRIO_MAX_ALIAS_SIZE) 
		    {
		      len = GRIO_MAX_ALIAS_SIZE-1;
		      loc_msg =   GRIO_W_ALIAS_TRUNC;
		    }
		  strncpy(ME.GRunit->alias_list[j].alias,
			 ME.GRunit->alias_list[j+1].alias,len);
		  ME.GRunit->alias_list[j].alias[len]=0;
		  ME.GRunit->alias_list[j].index = 
		    ME.GRunit->alias_list[j+1].index;
		}
	      ME.GRunit->num_alias--;
	      status = OM_SET_DIMENSION(ME.GRunit->alias_list,
					ME.GRunit->num_alias);
	    }
	}
    }
  else /* remove only this alias */
    {
      for(i=index; i<(ME.GRunit->num_alias-1); i++)
	{
	  len = strlen(ME.GRunit->alias_list[i+1].alias);
	  if(len >= GRIO_MAX_ALIAS_SIZE) 
	    {
	      len = GRIO_MAX_ALIAS_SIZE-1;
	      loc_msg =   GRIO_W_ALIAS_TRUNC;
	    }
	  strncpy(ME.GRunit->alias_list[i].alias,
		 ME.GRunit->alias_list[i+1].alias,len);
	  ME.GRunit->alias_list[i].alias[len]=0;
	  ME.GRunit->alias_list[i].index = 
	    ME.GRunit->alias_list[i+1].index;
	}
      ME.GRunit->num_alias--;
      status = OM_SET_DIMENSION(ME.GRunit->alias_list,
				ME.GRunit->num_alias);
    }
  
  /*
   *   check to see if all aliases that correspond to alias's definition
   *   were deleted
   */
  for(i=0; i<ME.GRunit->num_alias; i++)
    {
      if(ME.GRunit->alias_list[i].index == *def_index)
	{
	  *last_alias_deleted = FALSE;
	}
    }
 quit: 
  
  /*
   * if last_alias_deleted is true, then the calling routine is
   * going to remove the value that the alias pointed to, from 
   * ME.GRvar->var_list.  So, we have to decrement all the indexes
   * that are higher than the one we removed, so the indexes 
   * still point to the correct value.
   */
  
  if (*last_alias_deleted)
    {
      for (i=0; i<ME.GRunit->num_alias; i++)
	{
	  if (ME.GRunit->alias_list[i].index > *def_index)
	    {
	      ME.GRunit->alias_list[i].index = 
		ME.GRunit->alias_list[i].index-1;
	    } 
	}
    }
  if(loc_msg == GRIO_W_ALIAS_TRUNC) *msg = GRIO_W_ALIAS_TRUNC;
  return( OM_S_SUCCESS );
}

end implementation GRunit;


