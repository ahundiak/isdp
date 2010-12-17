#include "sql.h"

#line 1 "SQLerror.rc"
#include "machine.h"
#include "SQL.h"
#include "ris_err.h"
/*
#include "RISdbs_err.h"
#include "RISusr_err.h"
#include "RIStrn_err.h"
#include "RISdds_err.h"
*/

#define ABS(x) (((x) < 0) ? -(x) : (x))

 extern struct SQLglobal_st SQLglobal ;

 long SQLerror (code1, code2, code3)
   long    code1, code2, code3;
   {
     static char *fname = "SQLerror" ;

#line 19 "SQLerror.rc"

char * err_ptr;

#line 20 "SQLerror.rc"

long dbcode1,  dbcode2;

#line 22 "SQLerror.rc"
 
     char     message [512], str [10] ;
     long     error_no ;
	
     code2 = code2 ;
     code3 = code3 ;
     if (code1 != SQL_I_NO_ROWS_FOUND       &&
         code1 != SQL_E_DATA_TYPE           &&
         code1 != SQL_E_FORMAT_MISMATCH     &&
         code1 != SQL_E_MALLOC              &&
         code1 != SQL_E_MEM                 &&
         code1 != SQL_E_NO_FORMAT_MISMATCH)
      {

/******** EXTENDED MESSAGE BOTH RIS and DBMS ***********/
RISint_report_error(0,&err_ptr);

#line 37 "SQLerror.rc"

        _SQLdebug ((fname, "EXTENDED RIS/DBMS MSG : <\n%s\n>\n", err_ptr));

/******** DBMS ERROR ***********************************/

        dbcode1 = dbca -> sqlerrd [1];
        dbcode2 = dbca -> sqlcode;

        SQLglobal.DBerror_no =  ABS (dbcode1) << 16 | ABS (dbcode2);
        sprintf (SQLglobal.DBerror_msg, "%s", dbca->sqlerrm.sqlerrmc);

       if (risca ->sqlcode)
        {
	  message [0] = 0 ;
          str [0] = 0 ;
	  _SQLdebug ((fname, "risca -> sqlcode <%d>\n", risca -> sqlcode)) ;

          if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            code1 = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
       	    code1 = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
	    code1 = SQL_E_DUP_ATTR_NAME ;
     else if (risca -> sqlcode == RIS_E_INVALID_LOCK_TABLES)
	    code1 = SQL_E_INVALID_LOCK_TABLES;
     else if (risca -> sqlcode == RIS_E_UNKNOWN_RELATION)
	    code1 = SQL_E_UNKNOWN_RELATION;
     else 
	  {
	    code1= SQL_E_MESSAGE ;
	    sprintf (message, "%s", risca->sqlerrm.sqlerrmc) ;
	    strcpy (str, "%s") ;
	  }
        }
	ERRload_struct (SQL, code1, str, message) ;
      }
     error_no =  ABS (code1);

     _SQLdebug ((fname, "SQL ERROR : <0x%.8x>\n", error_no));
     return (error_no);
  }




