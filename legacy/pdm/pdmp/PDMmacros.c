#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"

extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
static	long   status;
static  char   s[1024];
extern PDMexec_ptr PDMexec;


int PDMsget_macro_format(return_buffer)
	MEMptr	*return_buffer;
{
	MEMptr	format_buffer = NULL;
	MEMptr	bufr = NULL;
	int		p_familyno;
	int		i, nx;
	long	n_tableno, pdc_tableno;
	char	pdc_table[30];
	char	datatype[20];
	char	**data;
	char	sql_str[512];

	PDMdebug("ENTER:PDMsget_macro_format\n");
	status = PDMi_query_familyno(PDMexec->catalog,&p_familyno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_query_familyno failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}	
	status = PDMget_table_no(PDMexec->catalog,"catalog",&n_tableno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMget_table_no failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}	
	sprintf(pdc_table,"y_%s",PDMexec->catalog);
	status = PDMget_table_no(pdc_table,pdc_table,&pdc_tableno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMget_table_no failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}	
	sprintf(sql_str,"%s %s %d %s",
	"SELECT p_name,p_seqno,p_iotype FROM pdmparameters",
	"WHERE p_familyno = ",p_familyno,
	"ORDER BY p_seqno");
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	status = MEMopen(&format_buffer,512);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMopen failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(format_buffer,"p_childno","integer");
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
	}
	data = (char **) bufr->data_ptr;
	for(i=0;i<bufr->rows;i++)
	{
		nx = i * bufr->columns;
		datatype[0] = '\0';
	    if(!strncmp(data[nx+2],"S",1))
		{
			status = PDMi_find_datatype(n_tableno,data[nx],datatype);
			if(status != PDM_S_SUCCESS)
			{
				MEMclose(&bufr);
				sprintf(s,"PDMi_find_datatype failed status %d\n",
				status); PDMdebug(s);
				return(status);
			}
			status = MEMwrite_format(format_buffer,data[nx],datatype);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(&bufr);
				sprintf(s,"MEMwrite_format failed status %d\n",status);
				PDMdebug(s);
				return(PDM_E_OPEN_BUFFER);
			}
		}
		else
		{
			status = PDMi_find_datatype(pdc_tableno,data[nx],datatype);
			if(status != PDM_S_SUCCESS)
			{
				MEMclose(&bufr);
				sprintf(s,"PDMi_find_datatype failed status %d\n",
				status); PDMdebug(s);
				return(status);
			}
			status = MEMwrite_format(format_buffer,data[nx],datatype);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(&bufr);
				sprintf(s,"MEMwrite_format failed status %d\n",status);
				PDMdebug(s);
				return(PDM_E_OPEN_BUFFER);
			}
		}
	}
if(PDMdebug_on)
{
	MEMprint_buffer("format_buffer",format_buffer,PDM_DEBUG_FILE);
}
	*return_buffer = format_buffer;
	PDMdebug("EXIT:PDMsget_macro_format\n");
	return(PDM_S_SUCCESS);
}

/*
          ADD MACRO LIBRARY TO THE PDM DATABASE

Macro libraries are tracked as regular parts in a macro PDMcatalog. Macro
libraries can exist in more than one catalog. It's not a rule that they
all belong to one catalog. But macro libraries can't be added to a regular
PDM catalog. Macro Catalogs are different from the regular PDM catalogs.

- Kumar Narayanan
*/

int PDMadd_macro_library( mac_cat, attr_bufr, data_bufr)
char *mac_cat;     /*Catalog to which the macro library should be attached*/
MEMptr attr_bufr;  /*Attributes  of the macro catalog*/
MEMptr data_bufr;  /*Data for each attribute of the macro library */

{

char  *fname = "PDMadd_macro_library";
MEMptr bufr = NULL;
char   sql_str[512];
char   **column_ptr,**data;
int    a1,a2,i;


    _PDMdebug(fname,"Enter:\n");
sprintf(sql_str,"SELECT n_catalogno FROM nfmcatalogs WHERE n_catalogname = '%s' AND n_type = 'MAC'",mac_cat );
        status = SQLquery(sql_str,&bufr,512);
        if(status == SQL_S_SUCCESS)
           {
           }
        else
        {
                MEMclose(&bufr);
                if(status == SQL_I_NO_ROWS_FOUND)
                {
               sprintf("Catalog <%s> is not macro catalog \n",mac_cat);
                PDMdebug(s);
                return(PDM_E_FAILURE);
                }
 else
                {
                        PDMdebug("SQL query failed \n");
                        return(PDM_E_SQL_QUERY);
                }
        }


        /* may have to load some PDM data here */

        status = MEMbuild_array(data_bufr);
        if(status != MEM_S_SUCCESS)
        {
       MEMclose(&attr_bufr);
       MEMclose(&data_bufr);
       PDMdebug("PDMadd_part:\n");
       sprintf(s,"MEMbuild_array failed : status %d\n",
                        status);
       PDMdebug(s);
           return(PDM_E_BUILD_ARRAY);
        }
       if(PDMdebug_on)
       {
        MEMprint_buffer("attr_bufr",attr_bufr,PDM_DEBUG_FILE);
        MEMprint_buffer("data_bufr",data_bufr,PDM_DEBUG_FILE);
        }

        column_ptr = (char **) data_bufr->column_ptr;
        data = (char **) data_bufr->data_ptr;
        a1 = -1; a2 = -1;
        for(i=0;i<data_bufr->columns;i++)
        {
                if(!strcmp(column_ptr[i],"p_parttype")) a1 = i;
                if(!strcmp(column_ptr[i],"p_explode"))  a2 = i;
        }
        if(a1 == -1 || a2 == -1)
        {
       PDMdebug("PDMadd_part:\n");
       sprintf(s,"failed to set offsets in data_list\n");
       PDMdebug(s);
           return(PDM_E_BUFFER_FORMAT);
        }
        if(!strcmp(data[a1],"") || !strlen(data[a1]))
        {
                /* default p_maxlevel is 0 */
/*
                s[0] = '\0';
 sprintf(s,"%d",0);
           */
                status = MEMwrite_data(data_bufr,"M",1,a1+1);
                if(status != MEM_S_SUCCESS)
{
                        PDMdebug("PDMadd_part:\n");
                        sprintf(s,"MEMwrite_data failed : status %d\n",
                        status);
                        PDMdebug(s);
                        return(PDM_E_WRITE_COLUMN);
                }
        }

        /* if p_explode is not set default to Y */

        if(!strcmp(data[a2],"") || !strlen(data[a2]))
        {
                status = MEMwrite_data(data_bufr,"N",1,a2+1);
                if(status != MEM_S_SUCCESS)
                {
                        sprintf(s,"MEMwrite_data failed : status %d\n",
                        status);
                        PDMdebug(s);
                        return(PDM_E_WRITE_COLUMN);
                }
        }

    status = NFMadd_item(PDMexec->user_id,mac_cat, attr_bufr,data_bufr);
    if(status != NFM_S_SUCCESS)
    {
                MEMclose(&attr_bufr);
                MEMclose(&data_bufr);
                PDMdebug("PDMadd_part :\n");
                sprintf(s,"NFMadd_item failed status -> %d \n",
                        status);
                PDMdebug(s);
            if(status == NFM_E_DUP_ITEM)
                        return(PDM_E_FAILURE);
        else
                        return(status);
    }
    MEMclose(&attr_bufr);
    MEMclose(&data_bufr);
    PDMdebug("EXIT:PDMadd_macro_library\n");
    return(PDM_S_SUCCESS);
}

/*
          STORE THE PARAMETERS IN THE PDMPARAMETERS TABLE


   All the parameters of the macros are stored  in the pdmparameters table.
   A index to the palloc table is the macro name. The parametric family is
   the view of the tables. 

int PDMstore_parameters(parameters)
MEMptr parameters;  Input buffer of parameters 

Format of input buffer:

n_catalogname char(20) p_library char(40) p_macro char (20)
p_parametername char(40) p_parametertype char(10) p_iotype char (5)
 
- Kumar Narayanan
*/

int PDMstore_parameters(parm_bufr)
MEMptr parm_bufr;
{
  char *fname="PDMstore_parameters";
  char **data;
  int   i ,nxi;
  char  str1[512], sql_str[1024];


   _PDMdebug(fname,"Enter:\n");
   status = MEMbuild_array(parm_bufr);
   if(status != MEM_S_SUCCESS)
   {
       _PDMdebug(fname,"\tMEMbuild_array failed : status %d\n", status);
       status = PDM_E_BUILD_ARRAY;
       goto wrapup;
   }
   data = (char **) parm_bufr->data_ptr;


/* Turn off AUTO_COMMIT */

   status = PDMstop_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
        _PDMdebug(fname,"PDMstop_transaction failed : status %d\n",status);
        return(status);
   }

    sprintf(sql_str,"DELETE FROM pdmparameters  WHERE n_catalogname = '%s'",  data[0]);
         status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
                {
                        sprintf(s,"SQLstmt failed status %d\n",status);
                        PDMdebug(s);
                 }

/* add parameters to pdmparameters table */

   str1[0]='\0';

   sprintf(str1,"%s (%s,%s) ", "INSERT INTO pdmparameters ", "n_catalogname,n_synonym", "p_templatename,p_type,p_iotype,p_units");

   for(i=0;i<parm_bufr->rows;i++)
   {
                nxi = i * parm_bufr->columns;
                sprintf(sql_str,"%s VALUES('%s','%s','%s','%s','%s','%s')",
                str1,data[nxi], data[nxi+1],data[nxi+2],
                data[nxi+3],data[nxi+4], data[nxi+5]);
                status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS)
                {
                        sprintf(s,"SQLstmt failed status %d\n",status);
                        PDMdebug(s);
                        status = PDM_E_SQL_STMT;
                        goto wrapup;
                }
   }

   /* commit work */

   status = PDMstart_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
        sprintf(s,"PDMstart_transaction failed : status %d\n",status);
        PDMdebug(s);
        goto wrapup;
    }

   _PDMdebug(fname,"Exit:\n");
   return(PDM_S_SUCCESS);

   wrapup:
    PDMrollback_transaction(1200);
   _PDMdebug(fname,"Exit:\n");
    return(status);
}

/*
             STORE THE RELATIONSHIP between MACRO and Parametric Catalog


   All the parameters of the macros are stored  in the pdmparameters table.
   A index to the pdmparamloc table is the n_catalogname. p_macrocat is the
   catalog to which the macro library belongs. It is equivalent of a
   pdmlibraries catalog. From PDM2.0.0 there is no restriction that macro
   libraries should belong to one catalog type. They co-exist with with other
   parts. n_catalogname is the catalog which contains the parametric catalog.
   Each macro library contains multiple macros. This table is a contained-in-
   table of macrolib->macros. The sketch file *.rle [p_rle] is also stored
   in this table.

int PDMmap_catalog_macro(macros)
MEMptr macros; - Input buffer of macros

Format of input buffer:

n_catalogname char(18) -  Name of the parametric catalog
p_macrocat    char(18) -  Name of the macro library catalog -n_catalogname
p_macropartno char(40) -  Name of the macro library - n_itemname
p_macrorev    char(40) -  Revision of the macro library - n_itemrev
p_macroname   char(30) -  Name of the macro - EMS macro
p_rle         char(14) -  Sketch file associated with the EMS macro

E-R

Mac Cat - Mac Lib - Macro - Sketch
      1 : n     1 : n   1 : 1

Kumar Narayanan

*/

int PDMmap_catalog_macro(macro_bufr)
MEMptr macro_bufr;
{
  char *fname="PDMmap_catalog_macro";
  char **data;
  int   i ,nxi;
  char  str1[250], sql_str[1024];
  MEMptr bufr = NULL;


   _PDMdebug(fname,"Enter:\n");
   status = MEMbuild_array(macro_bufr);
   if(status != MEM_S_SUCCESS)
   {
       _PDMdebug(fname,"\tMEMbuild_array failed : status %d\n", status);
       status = PDM_E_BUILD_ARRAY;
       return (status);
   }
   data = (char **) macro_bufr->data_ptr;

   if(macro_bufr->rows == 0)
      return(PDM_E_NO_MACROS_FOUND);

/* Turn off AUTO_COMMIT */

   status = PDMstop_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
        _PDMdebug(fname,"PDMstop_transaction failed : status %d\n",status);
        return(status);
   }


/* add parameters to pdmparameters table */

   sprintf(str1,"%s (%s,%s) ", "INSERT INTO pdmparamloc ", "n_catalogname,p_macrocat", "p_macropartno,p_macrorev,p_macroname,p_rle");

   data = (char **) macro_bufr->data_ptr;
   for(i=0;i<macro_bufr->rows;i++)
   {
                nxi = i * macro_bufr->columns;

               sprintf(sql_str,"SELECT p_macroname FROM pdmparamloc WHERE n_catalogname = '%s' ", data[nxi]);
         status = SQLquery(sql_str,&bufr,512);
         if(status == SQL_I_NO_ROWS_FOUND)
           {
               if(!strcmp(data[nxi+4],""))
                   return(PDM_E_MACRO_NOT_FOUND);
                sprintf(sql_str,"%s VALUES('%s','%s','%s','%s','%s','%s')",
                str1,data[nxi], data[nxi+1],data[nxi+2],
                data[nxi+3],data[nxi+4], data[nxi+5]);
                status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS)
                {
                        sprintf(s,"SQLstmt failed status %d\n",status);
                        PDMdebug(s);
                        status = PDM_E_SQL_STMT;
                        goto wrapup;
                }
           }
          else
           {
               sprintf(sql_str,"UPDATE pdmparamloc SET  p_macrocat = '%s' , p_macropartno = '%s' , p_macrorev = '%s' , p_macroname = '%s', p_rle = '%s' WHERE n_catalogname = '%s'", data[nxi+1],data[nxi+2],data[nxi+3],data[nxi+4], data[nxi+5], data[nxi]);
         status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS)
                {
                        sprintf(s,"SQLstmt failed status %d\n",status);
                        PDMdebug(s);
                        status = PDM_E_SQL_STMT;
                        goto wrapup;
                 }
            }
    }

   /* commit work */

   status = PDMstart_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
        sprintf(s,"PDMstart_transaction failed : status %d\n",status);
        PDMdebug(s);
        goto wrapup;
    }

   _PDMdebug(fname,"Exit:\n");
    return(PDM_S_SUCCESS);

   wrapup:
    PDMrollback_transaction(1200);
   _PDMdebug(fname,"Exit:\n");
    return(status);
}

/*
          GET THE MACRO AND  THE PARAMETERS OF A CATALOG
 - Kumar Narayanan
*/


int PDMget_macro_parameters
(
char   *catalog,
MEMptr *macro ,  
MEMptr *parameters 
)
{
  char *fname="PDMget_macro_parameters";
  char  sql_str[512];


   _PDMdebug(fname,"Enter:\n");

    sprintf(sql_str,"SELECT *  FROM pdmparameters  WHERE n_catalogname = '%s'",  catalog);
         status = SQLquery(sql_str, parameters, 512);
                if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
                {
                        sprintf(s,"SQLstmt failed status %d\n",status);
                        PDMdebug(s);
                 }


   if(status == SQL_I_NO_ROWS_FOUND)
      return(PDM_E_NO_MACROS_FOUND);

    sprintf(sql_str,"SELECT *  FROM pdmparamloc  WHERE n_catalogname = '%s'",  catalog);
         status = SQLquery(sql_str, macro, 512);
                if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
                {
                        sprintf(s,"SQLstmt failed status %d\n",status);
                        PDMdebug(s);
                 }

   if(status == SQL_I_NO_ROWS_FOUND)
      return(PDM_E_NO_MACROS_FOUND);

   _PDMdebug(fname,"Exit:\n");
    return(PDM_S_SUCCESS);
}
