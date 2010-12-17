#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_command_no (user_id, command_name, command_no)
   long    user_id;
   char    *command_name;
   long    *command_no;
   {
     static char *fname = "NFMget_command_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *command_no = 0;

     _NFMdebug ((fname, "Command Name = <%s>\n", command_name));


     sprintf (sql_str, "WHERE %s = '%s'", "n_commandname", command_name);

     status = NFMget_attr_value (user_id, "NFMCOMMANDS", "n_commandno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_COMMAND, "", NULL);
           _NFMdebug ((fname, "No Such Command : status = <0x%.8x>\n", NFM_E_BAD_COMMAND));
           return (NFM_E_BAD_COMMAND);
         }

        return (status);
      }

     *command_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : Command No = <%d>\n", *command_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_command_name (user_id, command_no, command_name)
   long    user_id;
   long    command_no;
   char    *command_name;
   {
     static char *fname = "NFMget_command_name" ;
     long    status;
     char    sql_str [1024];

     command_name [0] = 0;

     _NFMdebug ((fname, "Command No   = <%d>\n", command_no  ));

     sprintf (sql_str, "WHERE %s = %d", "n_commandno", command_no);

     status = NFMget_attr_value (user_id, "NFMCOMMANDS", "n_commandname",
              sql_str, command_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_COMMAND, "", NULL);
           _NFMdebug ((fname, "No Such Command : status = <0x%.8x>\n",
           NFM_E_BAD_COMMAND));
           return (NFM_E_BAD_COMMAND);
         }

        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Command Name = <%s>\n", command_name));
     return (NFM_S_SUCCESS);
   }


  long NFMget_command_entity (user_id, command_no, entity)
   long    user_id;
   long    command_no;
   char    *entity;
   {
     static char *fname = "NFMget_command_entity" ;
     long    status;
     char    sql_str [1024];
     char    value [50];

     entity[0] = 0;

     _NFMdebug ((fname, "Command No   = <%d>  ", command_no));

     sprintf (sql_str, "WHERE %s = %d", "n_commandno", command_no);

     status = NFMget_attr_value (user_id, "NFMCOMMANDS", "n_entity",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_COMMAND, "", NULL);
           _NFMdebug ((fname, "No Such Command : status = <0x%.8x>\n",
           NFM_E_BAD_COMMAND));
           return (NFM_E_BAD_COMMAND);
         }

        return (status);
      }


    strcpy(entity,value);

/*          if (! strcmp (value, "NFMNOENTITY"))  *entity = NFMNOENTITY;
     else if (! strcmp (value, "NFMSDP"))       *entity = NFMSDP;
     else if (! strcmp (value, "NFMADMIN"))     *entity = NFMADMIN;
     else if (! strcmp (value, "NFMCATALOG"))   *entity = NFMCATALOG;
     else if (! strcmp (value, "NFMPROJECT"))   *entity = NFMPROJECT;
     else if (! strcmp (value, "NFMITEM"))      *entity = NFMITEM;
*/
     _NFMdebug ((fname, "SUCCESSFUL :  Entity = <%s>  ", entity));
     return (NFM_S_SUCCESS);
   }

 long NFMget_nfm_command_no (user_id, command_name, command_no)
   long    user_id;
   char    *command_name;
   long    *command_no;
   {
     static char *fname = "NFMget_nfm_command_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *command_no = 0;

     _NFMdebug ((fname, "Command Name = <%s>  ", command_name));

     sprintf (sql_str, "WHERE %s = '%s'", "n_commandname", command_name);

     status = NFMget_attr_value (user_id, "NFMCOMMANDS", "n_commandno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_COMMAND, "", NULL);
           _NFMdebug ((fname, "No Such Command : status = <0x%.8x>\n",
           NFM_E_BAD_COMMAND));
           return (NFM_E_BAD_COMMAND);
         }

        return (status);
      }

     *command_no = atol (value);

     _NFMdebug ((fname, "APP COMMAND NO = <%d>\n", *command_no));

     status = NFMget_attr_value (user_id, "NFMCOMMANDS", "n_nfmcommandno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_COMMAND, "", NULL);
           _NFMdebug ((fname, "No Such Command : status = <0x%.8x>\n",
           NFM_E_BAD_COMMAND));
           return (NFM_E_BAD_COMMAND);
         }

        return (status);
      }

     if (atol (value) > 0)
       *command_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : NFM COMMAND NO = <%d>\n", *command_no));
     return (NFM_S_SUCCESS);
   }
