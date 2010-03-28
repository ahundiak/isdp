/*%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRunit

    METHOD NAME:  GRunitadd_als
     CHANGE HISTORY: 

     Design Date:     BMR  12/03/86     
     ansi conversion  scw  07/14/92

----*/

class implementation GRunit;

#include "grimport.h"
#include "OMmacros.h"

 /*
  * compare function used by binary search and qsort.
  */
 int alias_compare(alias1,alias2)
 struct GRIOalias_entry *alias1, *alias2;
   {
         return( strcmp(alias1->alias, alias2->alias));
   }

method GRunitadd_als(IGRlong          *rc;
                     IGRshort         *def_index;
                     IGRboolean       *modify_flag;
                     IGRboolean       *alias_added;
                     IGRshort         *num_alias;
                     GRIOalias_name   *alias_list)
     
{
  IGRlong              status;
  IGRshort             dummy;
  IGRshort             i,j,index;
  IGRboolean           located,delete_flag,last_alias_deleted;
  IGRchar              tmp1[GRIO_MAX_ALIAS_SIZE];
  IGRint               len;
  IGRint               loc_msg = 0;

  *rc = MSSUCC;
  delete_flag = FALSE;
  *alias_added = FALSE;
  
  /*
   *  check to see if alias exist
   */
  for(i=0; i<*num_alias; i++)    /* check all alias */
    {
      status = om$send(msg = message GRunit.GRunitfin_als(
                                          rc, 
					  (GRIOalias_name *)alias_list[i],
					  &index,
					  &located),
		       targetid = my_id);
      if(located && *modify_flag)     /* delete current alias */
	{
	  status = om$send(msg = message GRunit.GRunitdel_als(
                                           rc, 
					   (GRIOalias_name *)alias_list[i],
					   &dummy,
					   &last_alias_deleted,
					   &delete_flag),
			   targetid = my_id);
	}
      if( (!located) || (located && *modify_flag) )
	{
	  *alias_added = TRUE;
	  ME.GRunit->num_alias++;    /* make room for new entry */
	  status = OM_SET_DIMENSION(ME.GRunit->alias_list,
				    ME.GRunit->num_alias);
	  /* move name into instance data */
	  /* KLUDGE */
	  len = strlen(alias_list[i]);
	  if(len >= GRIO_MAX_ALIAS_SIZE)   
	    {
	      len = GRIO_MAX_ALIAS_SIZE-1;
	      loc_msg = GRIO_W_ALIAS_TRUNC;
	   }
	  strncpy(tmp1,alias_list[i],len);
          tmp1[len] =0;
	  for(j=0; tmp1[j] != 0; j++)
	    {
	      tmp1[j] = toupper(tmp1[j]);
	    }
	  strcpy(ME.GRunit->alias_list[(ME.GRunit->num_alias -1)].alias,
		 tmp1);
	  /* END KLUDGE */
	  
	  ME.GRunit->alias_list[(ME.GRunit->num_alias - 1)].index =
	    *def_index;
	}
    }  /*end for */
  
  /*
   * sort alias list in instance data
   */
  qsort( (char *)ME.GRunit->alias_list,
          ME.GRunit->num_alias,
          sizeof(struct GRIOalias_entry),
          (IGRint (*)())alias_compare);

  if(loc_msg == GRIO_W_ALIAS_TRUNC) *rc = GRIO_W_ALIAS_TRUNC;
  return( OM_S_SUCCESS );
}

end implementation GRunit;
