#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NETstruct.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMstruct.h"

 struct NFMglobal_st NFMglobal ;
 extern int LOGIN_FLAG;

 long ADMlogoff (envname)

   char    *envname;
 {

     static char *fname = "ADMlogoff" ;
     char    *clh_vbyop ();
     long    status, tmp_flag ;
     char    sql_str [1024];
     char    temp_str [1024] ;
     char    d_sch_name [100], sch_name [100] ;
     char    *clh_status ;

     _NFMdebug ((fname, "ENTER\n")) ;
/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
     clh_status = clh_vbyop (envname, "NETPROP20", sch_name, 26); 
#else
     clh_status = clh_vbyop (envname, "NETPROP20", sch_name, 25); 
#endif

     if (clh_status)
         {
    	   ERRget_specific_number (NETS, &status) ;
	       if (status == NET_S_SUCCESS)
            {
        	     ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
	             ERRget_specific_number (NFM, &status) ;
            }
    	   if (status == NFM_S_SUCCESS)
            {
       	     ERRload_struct (NFM, NFM_E_CLH, "%s%s","nfm schema name",envname);
             _NFMdebug ((fname, "Get Schema Name : status = <0x%.8x>\n", NFM_E_CLH));
          	 return (NFM_E_CLH);
            }
         }
     
     sprintf (temp_str, "%*.*s", 25, 25, sch_name);

     status = NFMdecrypt (temp_str, d_sch_name);
     if (status != NFM_S_SUCCESS)
       { 
    	 ERRget_specific_number (NFM, &status) ;
    	 if (status == NFM_S_SUCCESS)
          {
     	   status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
          _NFMdebug ((fname,"Decrypt Schema Name : status = <0x%.8x>\n", status));
          return (status);
          }
       }

     /* default schema */
     
     _NFMdebug ((fname, "Executing close default schema statement\n")) ;
     tmp_flag = _NFMdebug_st.SQLdebug_on ;
     _NFMdebug_st.SQLdebug_on = 0 ;
     sprintf (sql_str, "CLOSE SCHEMA %s", d_sch_name);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
       {
    	 ERRget_specific_number (NFM, &status) ;
    	 if (status == NFM_S_SUCCESS)
          {
           ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Close Schema Stmt Failed") ;
           return (NFM_E_SQL_STMT) ;
          }
        }
     _NFMdebug_st.SQLdebug_on = tmp_flag ;

     _NFMdebug ((fname, "Total SQL Stmt SUCCESSFUL\n"));

     LOGIN_FLAG =1;
     return (NFM_S_SUCCESS);
   }
