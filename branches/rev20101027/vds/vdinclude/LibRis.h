/* $Id: LibRis.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / LibRis.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: LibRis.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#define RIS_NULL	-1281
#define RIS_STMT	1024

RisSuccess (string)
 
char *string;
  {
   exec sql begin declare section;
     char *p_sqlerror;
   exec sql end declare section;
  
   if (SQLCODE != RIS_SUCCESS)
     {
      exec sql report error into :p_sqlerror;
      printf ("\nsqlerror in <%s>\n%s\n", string, p_sqlerror);
      return (0);
     }
   else
      return (1);
  }

RisNullValue ()
  { 
   if      (SQLCODE == RIS_NULL)				return 1;
   else if (SQLCODE == END_OF_DATA) if (!RisSuccess ("fetch")) 	exit (1);
   else 							return 0;
  }

RisEndOfData ()
  {
   if      (SQLCODE == RIS_SUCCESS)	return 0;
   else if (SQLCODE == END_OF_DATA)	return 1;
   else if (!RisSuccess ("fetch"))	exit (1);
  }


exec_sql_open_cursor1 (string, variable) 

char *string;
char *variable;
  {
   exec sql begin declare section;
     char StmtString[1024];
   exec sql end declare section;
  
   int i;

   for (i=0 ; string[i] != '%'; i= i+1);
   if (string[i+1] == 's')
      sprintf (StmtString, string, variable);
   else
      sprintf (StmtString, string, *((int *)variable));
   if (DebugFlag & TOTAL) 
      printf ("\n<%s>\n\n", StmtString);
   exec sql prepare statement1 from :StmtString;
   exec sql declare cursor1 cursor for statement1;
   exec sql open cursor1;
  }


exec_sql_close_cursor1 ()
  {
   exec sql close cursor1;
   exec sql clear statement1;
  }


exec_sql_execute (string, variable) 

char *string;
char *variable;
  {
   exec sql begin declare section;
     char StmtString[1024];
   exec sql end declare section;
  
   int i;

   if (variable != NULL)
     {
      for (i=0 ; string[i] != '%'; i= i+1);
      if (string[i+1] == 's')
         sprintf (StmtString, string, variable);
      else
         sprintf (StmtString, string, *((int *)variable));
     }
   else
      strcpy (StmtString, string);
   if (DebugFlag & TOTAL) 
         printf ("\n<%s>\n\n", StmtString);

   exec sql prepare statement from :StmtString;
   exec sql execute statement;
   if (!RisSuccess (StmtString)) exit (1);
   exec sql clear statement;
  }
