#include "machine.h"
#include "WFG.h"

 /**************************************************************************
  *                                                                        *
  *   WFGquick_login :                                                     *
  *                                                                        *
  *   This function will log a user into I/NFM by doing the following.     *
  *                                                                        *
  *   1.  Get the environment schema name, schema passwd from the          *
  *       environment file.
  *   2.  Open the schema.                                                 *
  *   3.  Query the users table to see if the specified user exists.       *
  *       The username/passwd must be the same as in the NFMusers table    * 
  *                                                                        *
  **************************************************************************/

extern NFMprocess_id;
/* extern long NFM_PL_LOCK   = 0603; */
extern NFMuserid ;            /* userno << 16 | pid */


long WFGquick_login (user_id, user_name, passwd, env)

   long     *user_id;    /* O : The user_no << 16 | process_id */
   char     *user_name;  /* I : Users login name   */
   char     *passwd;     /* I : Users login passwd */
   char     *env;        /* I : login environment  */
{
      static char  *fname    = "WFGquick_login" ;
      static char  *env_type = "nfme_";  /* need to change if envtype changes */
      long     status, atol ();
      int      getpid ();
      char     sql_str [512], e_schema[60], e_passwd [60];
      MEMptr   list = NULL;
      char     schema_name[40];
      char     schema_passwd[40];
      char     node_name[60];
      char     *clh_vbyop (), *clh_status = NULL;
      char     **data;
      long     user_no;
      long     NFMlogoff ();

      _NFMdebug ((fname, "User Name   = <%s>\n", user_name));
      _NFMdebug ((fname, "Environment = <%s>\n", env));

      sprintf (node_name, "%s%s", env_type, env);
      _NFMdebug ((fname, "Node Name = <%s>\n", node_name));

      strcpy (schema_name, "");
      strcpy (schema_passwd, "");

      /*   Get the encrypted environment schema name from the 
           environment file.                                    */

      clh_status = clh_vbyop (node_name, "NETPROP20", e_schema, 25);
      if (clh_status)
      {
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", "clh_vbyop", clh_status);
        _NFMdebug ((fname, "clh_vboyp : status = <%s>\n", clh_status));  
        _NFMdebug ((fname, "Returning : status = <0x%.8x>\n", NFM_E_CLH));  
        free (clh_status);
        return (NFM_E_CLH);
      }

      free (clh_status);
      clh_status = NULL;
      _NFMdebug ((fname, "Encrypted Schema Name = <%s>\n", e_schema));

      /* Decrypt the schema name */

      status = NETdecrypt (e_schema, schema_name);
      if (status != NET_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_NET, NULL);
         _NFMdebug ((fname, "NETdecrypt Failed : status = <0x%.8x>\n", status));
         return (NFM_E_NET);
       }
      _NFMdebug ((fname, "Decrypted Schema Name = <%s>\n", schema_name));


      /*   Get the encrypted environment schema password from the 
           environment file.                                    */

      clh_status = clh_vbyop (node_name, "NETPROP21", e_passwd, 25);
      if (clh_status)
      {
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", "clh_vbyop", clh_status);
        _NFMdebug ((fname, "clh_vboyp : status = <%s>\n", clh_status));  
        _NFMdebug ((fname, "Returning : status = <0x%.8x>\n", NFM_E_CLH));  
        free (clh_status);
        return (NFM_E_CLH);
      }

      free (clh_status);
      clh_status = NULL;

      /* Decrypt the schema password */

      status = NETdecrypt (e_passwd, schema_passwd);
      if (status != NET_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_NET, NULL);
         _NFMdebug ((fname, "NETdecrypt Failed : status = <0x%.8x>\n", status));
         return (NFM_E_NET);
       }
      _NFMdebug ((fname, "Schema Password = <%s>\n", schema_passwd));

      /* Open the RIS schema */

      if (!strcmp (schema_passwd, ""))
         sprintf (sql_str, "DEFAULT SCHEMA %s", schema_name);
      else
         sprintf (sql_str, "DEFAULT SCHEMA %s.%s", schema_name, schema_passwd);

      _NFMdebug ((fname, "Schema Stmt = <%s>\n", sql_str));
      status = SQLexec_imm (sql_str);
      if (status != SQL_S_SUCCESS)
       {
          ERRload_struct (NFM, NFM_E_SQL_STMT, NULL);
          _NFMdebug ((fname, "Default Schema : status = <0x%.8x>\n",
                      status));
          return (NFM_E_SQL_STMT);
        }
      _NFMdebug ((fname, "Schema Opened.\n"));

      /*  Query the NFMUSERS table for the user/encrypted password and get
          the n_userno for the user if he/she exists.                      */

      sprintf (sql_str, "SELECT %s FROM nfmusers WHERE %s = '%s'",
               "n_userno, n_passwd", "n_username", user_name);
      _NFMdebug ((fname, "SQL Str = <%s>\n", sql_str));

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if (status != SQL_S_SUCCESS)
       {
          MEMclose (&list);
          NFMlogoff ();

          /*   Bad Login */
          if ((status) == SQL_I_NO_ROWS_FOUND)
           {
              ERRload_struct (NFM, NFM_E_BAD_USER, NULL);
              _NFMdebug ((fname, " Bad LOGIN : status = <0x%.8x>\n",
                          NFM_E_BAD_USER));
              return (NFM_E_BAD_USER);
           }

          /*      bad return from query             */

          ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL);
          _NFMdebug ((fname, "Query Syntax : status = <0x%.8x>\n", status));
          return (NFM_E_SQL_QUERY);
       }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
      {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "%s%x", "MEMbuild_array", status);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status)) ;
         return (NFM_E_MEM);
       }

      data = (char **) list->data_ptr;     

      user_no = atol (data[0]);
      _NFMdebug ((fname, "User No = <%d>\n", user_no));

      /*  Decrypt the password obtained from the query */

      status = NETdecrypt (data[1], e_passwd);
      if (status != NET_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_NET, NULL);
         _NFMdebug ((fname, "NETdecrypt Failed : status = <0x%.8x>\n", status));
         return (NFM_E_NET);
       }

      MEMclose (&list);

      if (strcmp (passwd, e_passwd))
       {
           ERRload_struct (NFM, NFM_E_BAD_USER, NULL);
           _NFMdebug ((fname, " Passwd  = <%s>\n", passwd));
           _NFMdebug ((fname, "Invalid Passwd : status = <0x%.8x>\n",
                       NFM_E_BAD_USER));
           return (NFM_E_BAD_USER);
       }

      NFMprocess_id = (long) getpid ();

      _NFMdebug ((fname, "PID  = <%d> : User No = <%d>\n", NFMprocess_id,
                  user_no)) ;

      *user_id = (user_no << 16) | NFMprocess_id;
      NFMuserid = *user_id;

      /* NFM_PL_LOCK = *user_id;  */

      _NFMdebug ((fname, "Returning Success = <%d>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
}

