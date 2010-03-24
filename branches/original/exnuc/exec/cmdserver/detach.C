/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME        EX_cmddetach ()
 
     Abstract:          This function takes a command control table and
                        a module type as input and detach the command
                        table from that module.
                        The reference count is decremented by 1, and if
                        it is down to 0, the memory occupied by the
                        command table and the command index table will
                        be returned to the system.  
-----
%SC%

        status = EX_cmddetach ( &msg, module_type );

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

    module_type    IGRlong      - module type.

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
    *msg            IGRlong     - EXSUCC : success.
                                  EXe_mod_type : error in module type.
                                  EXe_cmd_addr : error in address of the
                                        command table for that module type.
                                  EXe_cmd_ndx_addr : error in address of
                                        command index table for that
                                        module type.
                                  EXe_not_attached : module not attached.
        value = TRUE if success
                FALSE if failure.

----*/


#include <igrtypedef.h>
#include <exdef.h>
#include <expriv.h>
#include <exlanguage.h>
#include <malloc.h>

extern struct EX_cmd_cntrl *EX_cmdlist_ptr;
extern struct diacritic       *EX_diacritic;

IGRint EX_cmddetach ( msg, module_type )

IGRlong *msg;
IGRlong module_type;

{
    struct EX_cmd_cntrl *cmd_list;
    IGRint status;

    status = FALSE;

    cmd_list = EX_cmdlist_ptr;
    while (cmd_list->mod_type != module_type)
      {
        if (cmd_list->next != 0)
          cmd_list = cmd_list->next;
        else
          return (FALSE);
      }
    --cmd_list->reference_count;

        status = TRUE;
        *msg = EXSUCC;

        if (! cmd_list->reference_count )
        {
            if (! cmd_list->cmd_ndx )
            {
                status = FALSE;
                *msg = EXe_cmd_ndx_addr;
            }
            else
            {
                free ( cmd_list->cmd_ndx );
            }

            if (! cmd_list->cmd )
            {
                status = FALSE;
                *msg = EXe_cmd_addr;
            }
            else
            {
                free ( cmd_list->cmd );
            }
            if (cmd_list == EX_cmdlist_ptr)
                EX_cmdlist_ptr = cmd_list->next;
            free (cmd_list);
        }
    if ( EX_diacritic )
       {
       free ( EX_diacritic );
       EX_diacritic = 0;
       }

    return ( status );
} /* EX_cmddetach */
