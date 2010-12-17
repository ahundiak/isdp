#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"

extern int      PDMdebug_on;
extern char PDM_DEBUG_FILE[];
static  long   status;
static  char   s[1024];
extern PDMexec_ptr PDMexec;

/* GET THE VIEWS WHICH ARE NOT CATALOGS

   PDM parametric part family catalogs are stored as views  of
   pdmparametric, palloc, pdmparameters, and dynamic_attributes tables.
   They are distinctly different from regular catalogs, since there
   are no f_catalog tables and v_catalog tables for these parametric
   catalogs. But there will be entries for the tables in nfmcatalogs and
   pdmloc tables. The way a parametric table/view is differenciated from
   regular catalog tables, is by checking the entry in nfmtables, and
   risviews tables. 

int PDMget_views_of_paracat(para_views)
MEMptr  *para_views; Output of views of tables which form
                        the parametric part family

Example 1:
If you want the views which are not the catalogs

                       output_bufr:
 p_viewname    n_catalogdesc
 Valves        engine valves
 Heads         Cylinder heads


Return Codes:
PDM_S_SUCCESS - Successful Completion
*/


int PDMget_views_of_paracat(para_views)
MEMptr  *para_views;

{

char  *fname = "PDMget_views_of_paracat";
char    sql_str[512];


        _PDMdebug(fname, "Enter:\n");
        sql_str[0] = '\0';

      sprintf(sql_str,"SELECT n_catalogname, n_catalogdesc FROM nfmcatalogs WHERE n_identifier = 'PDM' AND n_type = 'CID' OR n_type = 'EID'");
           
           status = SQLquery(sql_str, para_views, 512);
            if(status != SQL_S_SUCCESS)
              {
                MEMclose(para_views);
                if(status == SQL_I_NO_ROWS_FOUND)
                {
                _PDMdebug(fname,"No view defined status %d\n",status);
                return (PDM_I_NO_VIEW);
                 }
                else
                 {
                _PDMdebug(fname,"SQLquery failed status %d\n",status);
                return (PDM_I_NO_VIEW);
                 }
               }
        _PDMdebug(fname, "Exit:\n");

         return(PDM_S_SUCCESS);
}

/*
STORE USAGE ID OF EXISTING CATALOG

At one time a catalog can have only one usage id.
But the usage_id can be changed,deleted. If a usage_id already exists,
that will be updated.


int PDMstore_usageid_cat(catalog_name, usage_id)
char       *catalog_name; Input - given catalog name 
char       *usage_id;     Input - Usage_id 

Example 1:
If you want to store the usage_id "Front End structure" for a catalog
called "FES"


Return Codes:
PDM_S_SUCCESS  - Successful Completion
PDM_E_CATALOG_NOT_FOUND - Catalog not found in PDMdatabase.

*/


int PDMstore_usageid_cat (catalog_name , usage_id)
char *catalog_name;
char *usage_id;
{
int    catno;
char  *fname = "PDMstore_usageid_cat";
char    sql_str[512];
long   status;


        _PDMdebug(fname, "Enter:\n");
        sql_str[0] = '\0';

status = PDMris_get_catno(catalog_name,&catno);
                if(status != SQL_S_SUCCESS)
                {
                       if(status == SQL_I_NO_ROWS_FOUND) 
                           return (PDM_E_CATALOG_NOT_FOUND);
                       else
                       return(PDM_E_SQL_STMT);

                 }

      sprintf(sql_str,"UPDATE  pdmcatalogs SET p_defname = '%s' WHERE \
           n_catalogno = %d ",usage_id, catno);
           status = SQLstmt(sql_str);
            if(status != SQL_S_SUCCESS)
              {
               if(status == SQL_I_NO_ROWS_FOUND)
              {
      sprintf(sql_str,"INSERT INTO  pdmcatalogs (n_catalogno, p_defname) \
                       VALUES ('%s','%s')", catno, usage_id);
           status = SQLstmt(sql_str);
                 if(status != SQL_S_SUCCESS)
                  {
                _PDMdebug(fname,"SQLquery failed status %d\n",status);
                return (status);
                  }
              }
               else
                  {
                _PDMdebug(fname,"SQLquery failed status %d\n",status);
                return (status);
                  }
             }
        _PDMdebug(fname, "Exit:\n");

        return(PDM_S_SUCCESS);
}

/*
 GET ATTRIBUTES OF A VIEW

 Parametric catalog/family definition is stored as a view of some
 tables. This function gets the attr_bufr, data_bufr, and list bufr of the
 given view . In the NFM database the view is stored as a template 

*/

int PDMget_attr_of_view(table_type, table_name, identifier, attr_list, data_list, value_list)
   char     *table_type;
   char     *table_name;
   char     *identifier;
   MEMptr   *attr_list; 
   MEMptr   *data_list; 
   MEMptr   *value_list;
{
     char   *fname = "PDMget_attr_of_view" ;
     long   status, template_no ;
     char   sql_str [1024] ;
     long _NFMget_template_no ();

     _PDMdebug (fname, "Table  Type = <%s> : Table Name = <%s>\n",
                 table_type, table_name);

     NFMchange_case (table_type, 1);
     if (! strcmp (table_name, "nfmsystem")) NFMchange_case (table_name, 1);

status = _NFMget_template_no (table_type, table_name, identifier,
                               &template_no);
     if (status != NFM_S_SUCCESS)
       {
         _PDMdebug (fname, "Get Table No : status = <0x%.8x>\n",
                     status);
         return (PDM_E_VIEW_NOT_FOUND);
       }

     sprintf (sql_str, "n_tableno = %d", template_no) ;

     status = NFMget_table_attr (PDMexec->user_id, sql_str, "", attr_list);
     if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         MEMclose (value_list);
         _PDMdebug (fname, "Get Tab Attr : status = <0x%.8x>\n",
                     status);
         return (status);
       }
status = _NFMget_data_value (*attr_list, data_list, value_list,
                                  "A", "R") ;
     if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         MEMclose (value_list);
         _PDMdebug (fname, "Get Data Values : status = <0x%.8x>\n",
                     status);
         return (PDM_E_GET_ATTRIBUTES);
       }

     _PDMdebug (fname, "SUCCESSFUL\n") ;
     return (PDM_S_SUCCESS);
   }


/*
LOOK FOR DYNAMIC TABLE GIVEN A SET OF ATTRIBUTES

 This function gets one or more dynamic table name which houses a gives set of
 attributes. This is achieved by querying the nfmattributes table and
 nfmtables table. You can either match the synonym or the attribute name.
 The max. no of attributes to search for is 50  

int  PDMget_dyntable_for_attr(flag, attr_bufr, dyn_bufr,attr_bufr )
int    flag;      Input - 1 - attr match, 2 - synonym match
                          3 - attr and synonym match
                          4 - attr and datatype match
                          5 - synonym and datatype match
                          6 - attr,synonym, and datatype match 
MEMptr attr_bufr; Input - Attributes to be scanned for a dynamic table 
MEMptr *dyn_bufr; Output- List of dynamic tables which house the given attrs

Format of attr_bufr:

n_name char(20) n_synonym char (40) n_datatype  char (15)


Format of the dyn_bufr:

n_tablename char(20)

Nested query will do this job:

select distinct n_tableno from nfmattributes where
        n_tableno in (Select n_tableno from nfmattributes where n_name = 'n_item
name' ) AND
        n_tableno in (Select n_tableno from nfmattributes where n_name = 'n_item
nrev' ) AND
        n_tableno in (Select n_tableno from nfmattributes where n_name = 'n_seti
ndicator' ) AND
        n_tableno in (Select n_tableno from nfmattributes where n_name = 'p_part
type' );

Return status:

PDM_S_SUCCESS       - Successful Completion
PDM_E_NO_TABLE      - No match found
PDM_E_TOO_MANY_ATTR - Too many attributes to match for
*/


int  PDMget_dyntable_for_attr(flag, attr_bufr, dyn_bufr )
int    flag;
MEMptr attr_bufr; 
MEMptr *dyn_bufr;

{

char *fname = "PDMget_dyntable_for_attr";
char  **column_ptr, **data;
int    i = 0, a1 = 0 ,a2 = 0 ,a3 = 0 ,y = 0 , yx = 0;
char   *sql_str, **no_data, where_str[200];
MEMptr bufr = NULL;


        _PDMdebug(fname, "PDMget_dyntable_for_attr");

        /* set required offsets */

         status = MEMbuild_array(attr_bufr);
        if(status != MEM_S_SUCCESS)
        {
                MEMclose(&attr_bufr);
                sprintf(s,"MEMbuild_array failed status %d\n",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
        }
           if(attr_bufr->rows > 50)
            {
                MEMclose(&attr_bufr);
                 *dyn_bufr = NULL;
                _PDMdebug(fname,"Too Many attributes to search for\n");
                return(PDM_E_TOO_MANY_ATTR);
             }
               
        column_ptr = (char **) attr_bufr->column_ptr;
        data = (char **) attr_bufr->data_ptr;
        for(i=0;i<attr_bufr->columns;i++)
        {
                if(!strcmp(column_ptr[i],"n_name")) a1 = i;
                if(!strcmp(column_ptr[i],"n_synonym"))    a2 = i;
                if(!strcmp(column_ptr[i],"n_datatype"))    a3 = i;
        }
        if(a1 == -1 || a2 == -1 || a3 == -1 )
        {
                PDMdebug("Couldnot set offsets in data_bufr\n");
                MEMclose(&attr_bufr);
                 *dyn_bufr = NULL;
                return(PDM_E_BUFFER_FORMAT);
        }

       sql_str = (char *) malloc (attr_bufr->rows * 200 + 500);
       memset( sql_str, NULL, (attr_bufr->rows * 200 + 500));
       sql_str[0]='\0';

     sprintf(sql_str, "Select distinct n_tableno from nfmattributes where");
       if(flag == 1)
         {
           for (y =0 ; y < attr_bufr->rows; y++)
             {
       where_str[0]='\0';
                yx = y * attr_bufr->columns;
           sprintf(where_str," n_tableno in (Select n_tableno from nfmattributes where n_name = '%s' )", data[yx+a1] );
         
            strcat (sql_str, where_str);
            if (y != (attr_bufr->rows - 1)) strcat (sql_str, "AND");
          }
        }
        else if (flag == 2)
         {
           for (y =0 ; y < attr_bufr->rows; y++)
             {
       where_str[0]='\0';
                yx = y * attr_bufr->columns;
           sprintf(where_str," n_tableno in (Select n_tableno from nfmattributes where and n_synonym = '%s' )",  data[yx+a2]);
         
            strcat (sql_str, where_str);
            if (y != (attr_bufr->rows - 1)) strcat (sql_str, "AND");
          }
        }
        else if (flag == 3)
         {
           for (y =0 ; y < attr_bufr->rows; y++)
             {
       where_str[0]='\0';
                yx = y * attr_bufr->columns;
           sprintf(where_str," n_tableno in (Select n_tableno from nfmattributes where n_name = '%s' and n_synonym = '%s' )", data[yx+a1] , data[yx+a2]);
         
            strcat (sql_str, where_str);
            if (y != (attr_bufr->rows - 1)) strcat (sql_str, "AND");
            }
         }
        else if (flag == 4)
         {
           for (y =0 ; y < attr_bufr->rows; y++)
             {
       where_str[0]='\0';
                yx = y * attr_bufr->columns;
           sprintf(where_str," n_tableno in (Select n_tableno from nfmattributes where n_name = '%s' and n_datatype = '%s' )", data[yx+a1] , data[yx+a3]);
         
            strcat (sql_str, where_str);
            if (y != (attr_bufr->rows - 1)) strcat (sql_str, "AND");
            }
         }
        else if (flag == 5)
         {
           for (y =0 ; y < attr_bufr->rows; y++)
             {
       where_str[0]='\0';
                yx = y * attr_bufr->columns;
           sprintf(where_str," n_tableno in (Select n_tableno from nfmattributes where n_synonym = '%s' and n_datatype = '%s' )", data[yx+a2] , data[yx+a3]);
         
            strcat (sql_str, where_str);
            if (y != (attr_bufr->rows - 1)) strcat (sql_str, "AND");
            }
         }
        else if (flag == 6)
         {
           for (y =0 ; y < attr_bufr->rows; y++)
             {
       where_str[0]='\0';
                yx = y * attr_bufr->columns;
           sprintf(where_str," n_tableno in (Select n_tableno from nfmattributes where n_name = '%s' and n_synonym = '%s' and n_datatype = '%s' )", data[yx +a1], data[yx+a2] , data[yx+a3]);
         
            strcat (sql_str, where_str);
            if (y != (attr_bufr->rows - 1)) strcat (sql_str, "AND");
            }
          }
         

       status = SQLquery (sql_str, &bufr, 512);
        if(status != SQL_S_SUCCESS)
           {
              MEMclose(&bufr);
                 *dyn_bufr = NULL;
              MEMclose(&attr_bufr);
              free(sql_str);
             if (status == SQL_I_NO_ROWS_FOUND)
                 {
                _PDMdebug(fname,"No common table has all these attributes\n");
                 return(PDM_E_NO_TABLE_MATCH);
                 }
             else
                 {
                _PDMdebug(fname,"SQLquery failed %d\n", status);
                 return(status);
                 }
            }

              free(sql_str);
              MEMclose(&attr_bufr);
         status = MEMbuild_array(bufr);
        if(status != MEM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf(s,"MEMbuild_array failed status %d\n",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
        }

        no_data = (char **) bufr->data_ptr;

         for (i=0; i < bufr->rows; i++)
          {
          
          where_str[0] = '\0';
          sprintf(where_str, "select n_tablename,n_tableno  from nfmtables wheren_tableno = %s", no_data[i]);

       status = SQLquery (sql_str, dyn_bufr, 512);
        if(status != SQL_S_SUCCESS)
           {
              MEMclose(dyn_bufr);
             if (status == SQL_I_NO_ROWS_FOUND)
                 {
                _PDMdebug(fname,"Table name is not found\n");
                 continue;
                 }
             else
                 {
                _PDMdebug(fname,"SQLquery failed %d\n", status);
                 return(status);
                 }
            }
        }

        MEMclose(&bufr);
        _PDMdebug(fname, "PDMget_dyntable_for_attr");
     return(PDM_S_SUCCESS);
}
