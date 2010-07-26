
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME        EX_cmdinit()
 
     Abstract:          This function initializes the command control
                        structures for all module types.
  
-----
%SC%

        status = EX_cmdinit ( module_type, &cmd_cntrl );

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

    *cmd_cntrl struct EX_cmd_cntrl - address of command table control
                                     structure.

        value = TRUE for success and
                FALSE for failure.
-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:

-----
%CH%
     CHANGE HISTORY:
        
        czn  05/06/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------



----*/
/*EH*/

#include <igrtypedef.h>
#include <exdef.h>
#include <expriv.h>
#include <malloc.h>
extern struct EX_cmd_cntrl *EX_cmdlist_ptr;

IGRint EX_cmdinit ( module_type, cmd_list )

IGRlong module_type;
struct EX_cmd_cntrl **cmd_list;

{

      *cmd_list = (struct EX_cmd_cntrl *)malloc(sizeof(struct EX_cmd_cntrl));
      if (*cmd_list)
        {
          (*cmd_list)->no_of_cmd = 0;
          (*cmd_list)->mod_type = module_type;
          (*cmd_list)->reference_count = 0; 
          (*cmd_list)->cmd_ndx = NULL;
          (*cmd_list)->cmd = NULL;
          (*cmd_list)->next = 0;
          return (TRUE);
        }
     else
        return (FALSE);
     
} /* EX_cmdinit */
