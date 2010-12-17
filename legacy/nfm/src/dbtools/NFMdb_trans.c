#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

#define      NULL    ((char *) 0)

 long NFM_TRANSACTION = -1;

 long NFMset_autocommit_off (type)
   long    type;
   {
     char *fname = "NFMset_autocommit_off" ;
      long    status;

      _NFMdebug ((fname, "Type : status = <0x%.8x>\n", type));

      if (NFM_TRANSACTION == -1)
       {
          status = SQLstmt ("SET TRANSACTION AUTOCOMMIT OFF");
          if (status != SQL_S_SUCCESS)
           {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
             _NFMdebug ((fname, "Stop Auto Commit : status = <0x%.8x>\n",
             NFM_E_SQL_STMT));
             return (NFM_E_SQL_STMT);
           }

          NFM_TRANSACTION = type;
        }

       _NFMdebug ((fname, "SUCCESSFUL : NFM_TRANSACTION VALUE IS %d\n",
		   NFM_TRANSACTION)) ;
       return (NFM_S_SUCCESS);
   }

 long NFMset_autocommit_on (type)
   long    type;
   {
     char *fname = "NFMset_autocommit_on";
      long    status;

      _NFMdebug ((fname, "status = <0x%.8x>\n", type));

      if (NFM_TRANSACTION == type)
       {
          status = SQLstmt ("COMMIT WORK");
          if (status != SQL_S_SUCCESS)
           {
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
             _NFMdebug ((fname, "Commit Work : status = <0x%.8x>\n",
             NFM_E_SQL_STMT));
             return (NFM_E_SQL_STMT);
           }

          status = SQLstmt ("SET TRANSACTION AUTOCOMMIT ON");
          if (status != SQL_S_SUCCESS)
           {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
             _NFMdebug ((fname, "Stop Auto Commit : status = <0x%.8x>\n",
             NFM_E_SQL_STMT));
             return (NFM_E_SQL_STMT);
           }

          NFM_TRANSACTION = -1;
        }

       _NFMdebug ((fname, "SUCCESSFUL : NFM_TRANSACTION VALUE IS %d\n",
		   NFM_TRANSACTION)) ;
       return (NFM_S_SUCCESS);
   }
 long NFMstop_transaction (type)
   long    type;
   {
     char *fname = "NFMstop_transaction" ;
      long    status;

      _NFMdebug ((fname, "Type : status = <0x%.8x>\n", type));

      if (NFM_TRANSACTION == -1)
       {
          status = SQLstmt ("SET TRANSACTION AUTOCOMMIT OFF");
          if (status != SQL_S_SUCCESS)
           {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
             _NFMdebug ((fname, "Stop Auto Commit : status = <0x%.8x>\n",
             NFM_E_SQL_STMT));
             return (NFM_E_SQL_STMT);
           }

          NFM_TRANSACTION = type;
        }

       _NFMdebug ((fname, "SUCCESSFUL : NFM_TRANSACTION VALUE IS %d\n",
		   NFM_TRANSACTION)) ;
       return (NFM_S_SUCCESS);
   }

 long NFMstart_transaction (type)
   long    type;
   {
     char *fname = "NFMstart_transaction" ;
      long    status;

      _NFMdebug ((fname, "status = <0x%.8x>\n", type));

      if (NFM_TRANSACTION == type)
       {
          status = SQLstmt ("COMMIT WORK");
          if (status != SQL_S_SUCCESS)
           {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
             _NFMdebug ((fname, "Commit Work : status = <0x%.8x>\n",
             NFM_E_SQL_STMT));
             return (NFM_E_SQL_STMT);
           }

          status = SQLstmt ("SET TRANSACTION AUTOCOMMIT ON");
          if (status != SQL_S_SUCCESS)
           {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
             _NFMdebug ((fname, "Stop Auto Commit : status = <0x%.8x>\n",
             NFM_E_SQL_STMT));
             return (NFM_E_SQL_STMT);
           }

          NFM_TRANSACTION = -1;
        }

       _NFMdebug ((fname, "SUCCESSFUL : NFM_TRANSACTION VALUE IS %d\n",
		   NFM_TRANSACTION)) ;
       return (NFM_S_SUCCESS);
   }

 long NFMrollback_transaction (type)
   long    type;
   {
     char *fname = "NFMrollback_transaction" ;
      long    status;

      _NFMdebug ((fname, "Type : status = <0x%.8x>\n", type));

      if (NFM_TRANSACTION == type)
       {
          status = SQLstmt ("ROLLBACK WORK");
          if (status != SQL_S_SUCCESS)
           {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
             _NFMdebug ((fname, "Rollback Work : status = <0x%.8x>\n",
             NFM_E_SQL_STMT));
             return (NFM_E_SQL_STMT);
           }

          status = SQLstmt ("SET TRANSACTION AUTOCOMMIT ON");
          if (status != SQL_S_SUCCESS)
           {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
             _NFMdebug ((fname, "Start Commit : status = <0x%.8x>\n",
             NFM_E_SQL_STMT));
             return (NFM_E_SQL_STMT);
           }

          NFM_TRANSACTION = -1;
        }

       _NFMdebug ((fname, "SUCCESSFUL : NFM_TRANSACTION VALUE IS %d\n",
		   NFM_TRANSACTION)) ;
       return (NFM_S_SUCCESS);
   }

 long NFMcheck_transaction ()
   {
     char *fname = "NFMcheck_transaction" ;
      long    status;

      _NFMdebug ((fname, "ENTER\n")) ;

      if (NFM_TRANSACTION != -1)
       {
      ERRload_struct (NFM, NFM_E_TRANSACTION_OFF, "", NULL); 
          _NFMdebug ((fname, "Auto Commit Off : status = <0x%.8x>\n",
          NFM_E_TRANSACTION_OFF));
          return (NFM_E_TRANSACTION_OFF);
        }

       _NFMdebug ((fname, "SUCCESSFUL : NFM_TRANSACTION VALUE IS %d\n",
		   NFM_TRANSACTION)) ;
       return (NFM_S_SUCCESS);
   }

/* Suggested by Melania, to set NFM_TRASACTION for DM/Mgr */
long NFMsetNFM_TRANSACTION (type)
	long type ;
{
	char *fname = "NFMsetNFM_TRANSACTION" ;

	_NFMdebug ((fname, "setting NFM_TRANSACTION to %d\n", type)) ;
	NFM_TRANSACTION = type ;
	return (NFM_S_SUCCESS) ;
}
/* End - Suggested by Melania, to set NFM_TRASACTION for DM/Mgr */
