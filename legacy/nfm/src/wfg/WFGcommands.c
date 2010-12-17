#include "machine.h"
#include "WFG.h"
#include "WFGdefs.h"


/***************************************************************************
 *                                                                         *
 *  Date:  October 11, 1991.                                               *
 *                                                                         *
 *  Functions:  WFGadd_commands                                            *
 *  Functions:  WFGupdate_commands                                         *
 *              _WFGadd_commands                                           *
 *              _WFGdelete_commands                                        *
 *                                                                         *
 * These functions are used by the workflow generator.                     * 
 *                                                                         *
 ***************************************************************************/


long WFGprocess_commands (num_cmds, command_list)
  int           num_cmds; 
  struct WFFcommand_st command_list[]; 
  {
    long    status;
    static  char *fname = "WFGprocess_commands";

    long WFGupdate_commands ();

    _NFMdebug ((fname, " num_commands = <%d>\n", num_cmds));

    /* Begin the transaction */

    status = NFMstop_transaction (0);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname,": Stop Transaction : status = <0x%.8x>\n", status));
       return (status);
     } 

    /* Delete the commands from the database */

    status = WFGupdate_commands (num_cmds, command_list, WFF_DROP);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_commands : status = <0x%.8x>\n",
                    status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Add the commands from the database */

    status = WFGupdate_commands (num_cmds, command_list, WFF_ADD);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_commands : status = <0x%.8x>\n",
                    status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Commit the work */

    status = NFMstart_transaction (0);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname,": Stop Transaction : status = <0x%.8x>\n", status));
       return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long WFGupdate_commands (num_cmds, command_list, upd_order)
  int           num_cmds; 
  struct WFFcommand_st command_list[]; 
  char          *upd_order; /* WFF_ADD, WFF_DROP, "" = don't care about order */
  {
    int     i;
    long    status;
    static  char *fname = "WFGupdate_commands";

    extern long _WFGadd_command ();
    extern long _WFGdelete_command ();

    _NFMdebug ((fname, " num_commands = <%d>\n", num_cmds));

    for (i = 0; i < num_cmds; ++i)
     {
        if ((strcmp (command_list[i].status, WFF_ADD) == 0) &&
            (strcmp (upd_order, WFF_DROP) != 0))
         {
            status = _WFGadd_command (command_list[i]);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGadd_command : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
        else if ((strcmp (command_list[i].status, WFF_DROP) == 0) &&
                 (strcmp (upd_order, WFF_ADD) != 0))
         {
            status = _WFGdelete_command (command_list[i].command_name);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGdelete_command : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
     }  

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGadd_command (command_info)
  struct  WFFcommand_st command_info; 
  {
    long    status;
    long    command_no; 
    char    out_str[256];
    char    sql_str[512];
    static  char *fname = "_WFGadd_command";

    _NFMdebug ((fname, " Command Name = <%s>\n", command_info.command_name));

    /* get the command_no index */

    status = NFMget_serial_slot ((long) 0, "nfmcommands", "n_commandno",
                                 &command_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " NFMget_serial_slot : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* if there are any single quotes in command name tic them (RIS require) */

    out_str[0] = 0;
    WFGtic_it (command_info.command_name, out_str);

    /* add the command to the command table */

    sprintf (sql_str, "INSERT INTO nfmcommands (n_commandno,n_commandname, n_application, n_transcommand, n_entity, n_nfmcommandno) VALUES (%d, '%s', '%s', '%s', '%s', %s)",
             command_no, out_str, command_info.app_name,
             command_info.trans_cmd, command_info.entity,
             command_info.nfm_cmd_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
        status = NFM_E_SQL_STMT;
        ERRload_struct (NFM, status, NULL);
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGdelete_command (command_name)
  char  *command_name; 
  {
    long    status;
    long    command_no = 0;
    char    sql_str[256];
    static  char *fname = "_WFGdelete_command";

    _NFMdebug ((fname, " Command Name = <%s>\n", command_name));

     status = _WFGget_command_no (command_name, &command_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, " _WFGget_command_no : status = <0x%.8x>\n",
                    status));
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    /* delete the command from the command table */

    sprintf (sql_str, "DELETE FROM nfmcommands WHERE n_commandno = %d",
             command_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
        status = NFM_E_SQL_STMT;
        ERRload_struct (NFM, status, NULL);
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    /* return the serial slot */

    status = NFMreturn_serial_slot ((long) 0, "nfmcommands", "n_commandno",
                                 command_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " NFMget_serial_slot : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

