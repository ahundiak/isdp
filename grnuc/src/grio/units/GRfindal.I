/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRunit

    METHOD NAME:  GRunitfin_als
     
-----
%SC%    

-----
%EN%
     ON ENTRY: 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
       (none)

-----
%EX%
     ON EXIT: 

          NAME         DATA TYPE               DESCRIPTION
     --------------   ----------- -----------------------------------------

-----
%MD%

    MODULES, MACROS AND METHODS INVOKED: 

    -------------------------------------------------------------------------
    Macros: 
    -------------------------------------------------------------------------
    Modules: 
    ----------------------------------------------------------------------
    Methods: 

-----
%NB%

     NOTES: 

-----
%CH%

     CHANGE HISTORY: 
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------


  Method Name: 
     
  Method Description:  


----*/
/* EH */


class implementation GRunit;

extern int  alias_compare();

#include "grimport.h"
method GRunitfin_als(IGRlong    *rc;
                     GRIOalias_name    *alias;
                     IGRshort   *def_index; 
                     IGRboolean *located)


{
  struct GRIOalias_entry   *search_alias_ptr,search_alias;
  IGRshort             i;
  IGRint               len;
  IGRint               loc_msg = 0;
  
  *rc = MSSUCC;
  *located = FALSE;
  
  /*
   *  see if alias exist
   */
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
  if(ME.GRunit->num_alias > 0 )
    {
   search_alias_ptr =(struct GRIOalias_entry *)bsearch((char *)(&search_alias),
					  (char *)ME.GRunit->alias_list,
						  ME.GRunit->num_alias,
					  sizeof(struct GRIOalias_entry),
                                                 alias_compare);
   if(search_alias_ptr != NULL)
     {
       *located = TRUE;
       *def_index = search_alias_ptr->index;
     }
 }
  
  if(loc_msg == GRIO_W_ALIAS_TRUNC) *rc = GRIO_W_ALIAS_TRUNC;
  return( OM_S_SUCCESS );
  
}  

end implementation GRunit;

