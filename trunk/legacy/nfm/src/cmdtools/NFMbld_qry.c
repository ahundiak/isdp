#include "machine.h"
#include <stdio.h> 
#include <string.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"

/*  This routine takes the query structure and builds a buffer of RIS
 *  table attributes. This buffer is used in creating an advanced query
 *  browselist.
 */

long _NFMbuildRISattributes (qInfo, attrList)
    struct NFMquery_ftr_info qInfo; /* I - Structure of query info. */
    MEMptr *attrList;		   /* O - List of RIS attributes and
	    			    * datatypes */
{
    long    status;
    int     start;
    int     chrCnt;
    int     len;
    int     i;
    char    table[31];
    char    attr[31];
    char    tableAttr[70];
    char    fmt[20];
    char    cmdLine[200];
    char    *ts;
    char    *svStr;
    char    **data_ptr;
    MEMptr  buffer = NULL;
    static  char *fname = "_NFMbuildRISattributes";

    /*  Format the return buffer */
    status = MEMopen (attrList, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (attrList);
        _NFMdebug ((fname, "MEMopen = <0x%.8x>\n", status)); 
        ERRload_struct (NFM, NFM_E_MEM, NULL);
        return (status);
    }
    status = MEMwrite_format (*attrList, "attrName", "char(70)");
    if (status != MEM_S_SUCCESS)
    {
         MEMclose (attrList);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
    }
    status = MEMwrite_format (*attrList, "dataType", "char(20)");
    if (status != MEM_S_SUCCESS)
    {
         MEMclose (attrList);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
    }

    /*  Check for the case of NO RIS attributes */
    if (strlen(qInfo.aqs) == 0)
    {
	_NFMdebug ((fname, "NO RIS ATTRIBUTES chosen to display.\n" ));
	return (NFM_S_SUCCESS);
    }

    /*  The qInfo.aqs has the list of RIS attributes we want displayed */
    svStr = qInfo.aqs;
    strncpy (tableAttr, " ", 70);
    strncpy (attr, " ", 31);
    strncpy (table, " ", 31);
for (start=0, chrCnt=0, ts=svStr; chrCnt!=(strlen(qInfo.aqs)+1); 
     ++svStr, ++chrCnt)
{
   if ((*svStr == ',') || (*svStr == '\0'))
   {
     strncpy (tableAttr, ts, (chrCnt-start));
     _NFMdebug ((fname, "Table and attr <%s>\n", tableAttr));
     len = strlen(tableAttr);

     /* Now split up table and attribute name */
     for (i=0; i<len; ++i)
     {
       if (tableAttr[i] == '.')
       {
         strncpy (table, tableAttr, i);
         strncpy (attr, (tableAttr)+i+1, (len-i-1));
         _NFMdebug ((fname, "Table <%s>  Attr <%s>\n", table, attr ));
         /* Query the riscolumns table for this attribute in	
          * this table. Write to buffers.
          */

/* JUJARE - 3 Aug 95
   ris_colums cannot be accessed through RIS interface for RIS 5.0 and later.
   So Changed ris_columns to ris5columns  */

	 sprintf (cmdLine, "SELECT ris_type_string,char_max_length FROM ris5columns WHERE table_name = '%s' AND column_name = '%s'", table, attr);
	 status = SQLquery (cmdLine, &buffer, 512);
         if (status != SQL_S_SUCCESS)
	 {
            _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
	    MEMclose (&buffer);
	    return (status);
	 }
	 status = MEMbuild_array (buffer);
         if (status != MEM_S_SUCCESS)
         {
            MEMclose (&buffer);
            _NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
            return (status);
         }
         data_ptr = (char**) buffer->data_ptr;
         if (strcmp(data_ptr[0], "char") == 0)
	    sprintf (fmt, "%s(%s)", data_ptr[0], data_ptr[1]);
	 else if (strncmp(data_ptr[0], "int",3) == 0)
	    sprintf (fmt, "%s", "integer");
	 else
	    sprintf (fmt, "%s", data_ptr[0]);
	 /*  Write row into buffer */
	 sprintf (cmdLine, "%s\1%s\1", tableAttr, fmt);
	 status = MEMwrite (*attrList, cmdLine);
         if (status != MEM_S_SUCCESS)
	 {
            MEMclose (&buffer);
            _NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
            return (status);
         }
         MEMclose (&buffer);
	 buffer = NULL;	 
         /* Update counters if necessary */
 	 if (*svStr == ',')
         {
	   ++svStr;
	   ++chrCnt;
	   break;
	 }
      } /* end if (tableAttr = '.') */
    } /* end for loop of tableAttr */
    strncpy( tableAttr, " ", 70);
    strncpy( table, " ", 31);
    strncpy( attr, " ", 31);
    ts = svStr;
    start = chrCnt;
  } /* end if (*svStr = ',') */
  if (*svStr == '\0')
    break;
} /* end for loop */

    return (NFM_S_SUCCESS);
}

/*  This routine, given an input query structure returns the
 *  advanced query SELECT, FROM and WHERE clauses. This is
 *  a separate routine in the event any special editing is
 *  needed. (Though none is done now).
 */
long _NFMgetAdvancedClauses (qInfo, selectClause, fromClause, whereClause)
   struct NFMquery_ftr_info qInfo; /* I - Structure of query info */
   char   **selectClause;           /* O - Advanced select clause */
   char   **fromClause;             /* O - Advanced from clause */
   char   **whereClause;            /* O - Advanced where clause */
{
   char   *fname = "_NFMgetAdvancedClauses";

   _NFMdebug ((fname, "Entering ...\n"));
   _NFMdebug ((fname, "SELECT <%s>\n", qInfo.aqs));
   _NFMdebug ((fname, "FROM   <%s>\n", qInfo.aqf));
   _NFMdebug ((fname, "WHERE  <%s>\n", qInfo.aqw));

   *selectClause = qInfo.aqs;

    *fromClause = strchr(qInfo.aqf,',');
    if(*fromClause != (char *)0)
	    ++(*fromClause);


   *whereClause  = qInfo.aqw;

   _NFMdebug((fname, "Returning ...\n"));

   return (NFM_S_SUCCESS);
}

