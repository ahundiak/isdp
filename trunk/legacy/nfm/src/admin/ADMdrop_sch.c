#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "NFIerrordef.h"
#include "NETstruct.h"
#include "NFMdef.h"
#include "ERR.h"
#include "NFMsacdef.h"
#include "DEBUG.h"

char  SCHEMA [25];

 long ADMdrop_schema (env_name)
   char    *env_name;
   {
     long      status;
     char      env_node_name   [100];
     char      sch_name   [100], d_sch_name   [100];
     char      sch_pwd    [100], d_sch_pwd    [100];
     char      temp_str   [100], temp_file    [100];
     char      str[100];
     char	sql_str[2*SIZE];
     char *fname="ADMdef_schema",*clh_status;

     _NFMdebug ((fname,"Node Name = <%s>", env_name));
 /* HP-PORT IGI 25 Agu 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined (OS_HPUX) )
     clh_status = (char *)clh_vbyop (env_name, "NETPROP20", sch_name, 26);
#else
     clh_status = (char *)clh_vbyop (env_name, "NETPROP20", sch_name, 25);
#endif

     if (clh_status)
      {
        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname,"Get Schema Name : status = <0x%.8x>\nerror <%s>\n",
        NFM_E_NET,clh_status));
        return (NFM_E_NET);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_name);

     status = NFMdecrypt (temp_str, d_sch_name);
     if (status != NFM_S_SUCCESS)
      {
        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname,"Decr Sch Name : status = <0x%.8x>", NFM_E_NET));
        return (NFM_E_NET);
      }
 /* HP-PORT IGI 25 Agu 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX )|| defined(OS_HPUX) )
     clh_status = (char *)clh_vbyop (env_name, "NETPROP21", sch_pwd, 26);
#else
     clh_status = (char *)clh_vbyop (env_name, "NETPROP21", sch_pwd, 25);
#endif

     if (clh_status)
      {
        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname,"Get Schema Pwd : status = <0x%.8x>\n error <%s>\n",
        NFM_E_NET,clh_status));
        return (NFM_E_NET);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_pwd);

     status = NFMdecrypt (temp_str, d_sch_pwd);
     if (status != NFM_S_SUCCESS)
      {
        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname,"Decr Sch Pwd : status = <0x%.8x>", NFM_E_NET));
        return (NFM_E_NET);
      }

     if (! strlen (d_sch_pwd))      
       sprintf (sql_str, "DROP SCHEMA %s", d_sch_name);
     else
       sprintf (sql_str, "DROP SCHEMA %s.%s", d_sch_name, d_sch_pwd);
     
     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
    	_NFMdebug((fname,"SQL statement failed\n<%s>\n",sql_str));
        status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname,"Default Schema : status = <0x%.8x>", NFM_E_SQL_STMT));
        return (NFM_E_SQL_STMT);
      }
       
      _NFMdebug ((fname, "EXIT : status = <0x%.8x>\n", status));
      
      _NFMdebug ((fname, "EXIT\n"));
      return(NFM_S_SUCCESS);
}
