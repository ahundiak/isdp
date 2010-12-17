#include		<stdio.h>
#include		"SQLerrordef.h"
#include 		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"PDMdbs_err.h"
#include		"MEMstruct.h"
#include		"PDUerror.h"
#include		"PDUfile_def.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"

extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
extern          char    PDMdynamic_table[20];
static 		char		s[1024];
static		long		status;
extern PDMexec_ptr PDMexec;


/* CODED  on June 30, 92 by Kumar Narayanan for catalog classification 
QUERY CLASSIFICATION:

PDMexec->operation = 1 - If catalog names and descriptions are needed 
PDMexec->operation = 0  If catalog names and descriptions are not needed 
 input_buffer   - buffer of datatype MEMptr 
                -   Format of input buffer:
                        p_depth integer, p_class char(40)
output_buffer   - buffer of datatype MEMptr 
                      Format of output buffer:
 p_depth integer, p_class char(40), n_catalogname char(20), n_catalogdesc
                                                                    char(40)

   RETURN CODES:

  PDM_S_SUCCESS                on success
   The following are fatal errors meaning that the 
   function failed. The following point are worth noting.
   (a) It is possible to fail while trying to reset(rollback).
       This happens when the function tests for fatal errors and 
	   accordingly tries to reset/rollback.
   (b) Some are a result of checks on the PDU interface. Though this 
	   interface may be stable soon the NET layer may cause problems.

  PDM_E_RESET_BUFFER 		MEM Sub systems 
  PDM_E_COPY_BUFFER 		failures.
  PDM_E_BUILD_ARRAY
  PDM_E_NUMBER_OF_BUFFERS   The appended list of buffers doesn't contain the required number of buffers.
  PDM_E_BUFFER_FORMAT       System Buffers are of incorrect format (NFM & PDM)
  PDM_E_CATALOG_EXISTS	    Catalog exists (PDM check)
  PDM_E_QUERY_CLASS	    NFM function to create catalog
						    failed.
  PDM_E_SYSTEM_CORRUPTED    
*/

int PDMquery_classification ( input_buffer, output_class)
  MEMptr        input_buffer; 
  MEMptr        *output_class;
  {

        char            *fname = "PDMquery_classification";
        char            search[100];
        MEMptr          class_bufr = NULL;
        char            **data = NULL;
        long            status = PDM_S_SUCCESS; /* PDM_S_SUCCESS APOGEE */
        char            search_str[1024];
        char            search_str1[1024];
        char            catalog[21];
        char            sql_str[512];
        char            depth_col[25];
        char            depth_col1[25];
        char            type[5];
        char            class[51];
        char            **cat_data;
        char            catalogdesc[80];
        char            mem_str[250];
        int             s_flag = 0, current_depth,i,nxi;

        _PDMdebug(fname, "Enter:..\n");
        _PDMdebug(fname, "Operation -> %d :\n", PDMexec->operation);

        if(PDMdebug_on)
                MEMprint_buffer("input_buffer",input_buffer, PDM_DEBUG_FILE);

          status = MEMbuild_array(input_buffer);
          if(status != MEM_S_SUCCESS)
          {
	  _PDMdebug(fname,"MEMbuild_array failed status %d\n", status);
	  return(PDM_E_BUILD_ARRAY);
           }
         data  = (char **) input_buffer->data_ptr;

         /* Make the where clause to include the previous classification path */
         if((input_buffer->rows > 0) && (input_buffer != NULL))
         {
   current_depth = atoi(data[0]); /* if (current_depth == 0) current_depth =1;*/
        search_str[0]='\0';
        search_str1[0]='\0';
         if (strlen(data[1]) && strcmp(data[1],""))
          {
           strcpy(search_str,"WHERE");
           strcpy(search_str1,"WHERE");
                s_flag = 1;
          }
         for (i=0 ; i < input_buffer->rows; i++)
          {
          nxi = i * input_buffer->columns;
          if(current_depth != 0)
           {
            if(atoi(data[nxi]) > current_depth)
            current_depth = atoi (data[nxi]);
            }
            search[0] = '\0';
            if(s_flag == 1)
            {
            if(strlen(data[nxi]) && strcmp(data[nxi+1],""))
            {
            sprintf(search," t2.p_level%d = '%s'", atoi(data[nxi]),data[nxi+1]);
            strcat(search_str, search); 
            sprintf(search," p_level%d = '%s'", atoi(data[nxi]),data[nxi+1]);
            strcat(search_str1, search); 
             if( i != (input_buffer->rows -1))
                  {
                  strcat(search_str," and ");
                  strcat(search_str1," and ");
                   }
             }
           }
          }

         sql_str[0]='\0';
         
           sprintf( depth_col, "t2.p_level%d", (current_depth+1));
           sprintf( depth_col1, "p_level%d", (current_depth+1));
         }
         else
         {
           strcpy(search_str,"WHERE "); strcpy(depth_col,"t2.p_level1");
           strcpy(search_str1,""); strcpy(depth_col1,"p_level1");
          }

         if(PDMexec->operation == 1)
         {
          if (strlen(PDMexec->project) > 1)
       /* If the multiple sa were mapped to same catalog, and also to the
          same project, duplicate rows were retrieved. Added distinct 
          catalogname to these queries. MaC 113093 */
            sprintf(sql_str, " %s %s %s %s %s '%s' %s %s %s ",
           "SELECT DISTINCT (t1.n_catalogname), t1.n_catalogdesc, t2.p_depth ",
           " FROM nfmcatalogs t1, pdmcatalogs t2 , nfmprojects t3, ",
           " nfmcatalogsamap t4,nfmprojectsamap t5 ",
           search_str, 
           " t1.n_catalogno = t2.n_catalogno  AND t3.n_projectname = ",
           PDMexec->project,
           " AND t5.n_projectno = t3.n_projectno AND t4.n_mapno = t5.n_mapno ",
           " AND t4.n_catalogno = t1.n_catalogno ",
           " ORDER BY t1.n_catalogname");
         else
         {
          if(!strcmp(search_str,"WHERE "))
            sprintf(sql_str," %s %s %s %s ",
            "SELECT DISTINCT (t1.n_catalogname), t1.n_catalogdesc, t2.p_depth ",
            "FROM nfmcatalogs t1, pdmcatalogs t2 ",
            search_str,
            " t1.n_catalogno = t2.n_catalogno ORDER BY n_catalogname");
          else
            sprintf(sql_str," %s %s %s %s %s ",
             "SELECT DISTINCT (t1.n_catalogname),t1.n_catalogdesc, t2.p_depth ",
             " FROM nfmcatalogs t1, pdmcatalogs t2",
             search_str,
             "  AND t1.n_catalogno = t2.n_catalogno ",
             " ORDER BY n_catalogname");
          }
         }
         else
          sprintf(sql_str,
            "SELECT DISTINCT (%s)  FROM  pdmcatalogs %s ORDER BY %s", 
                                      depth_col1, search_str1, depth_col1);
    
         _PDMdebug(fname,"Calling SQLquery:\n%s\n", sql_str);

         status = SQLquery(sql_str,&class_bufr, 1024);
         if(status != SQL_S_SUCCESS) {
           MEMclose(&class_bufr);
           if(status == SQL_I_NO_ROWS_FOUND) {
              _PDMdebug(fname,"No catalogs or classification in this path\n");
              return(PDM_I_NO_CAT_IN_PATH);
              }
           _PDMdebug(fname,"SQLquery failed status %d\n", status);
           return(status);
           } 

          status = MEMbuild_array(class_bufr);
             if(status != MEM_S_SUCCESS)
               {
                   MEMclose(&class_bufr);
                  _PDMdebug(fname,"MEMbuild array failed status %d\n", status);
                   return(status);
                } 

            cat_data  = (char **) class_bufr->data_ptr;
        if ((PDMdebug_on) && (*output_class))
                MEMprint_buffer("output_class",*output_class, PDM_DEBUG_FILE);

           status = MEMopen(output_class,512);
            if(status != MEM_S_SUCCESS)
               {
                   MEMclose(&class_bufr);
                  _PDMdebug(fname,"MEMopen of output class failed status %d\n", status);
                     return(status);
                } 

           status = MEMwrite_format(*output_class,"p_depth","integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*output_class,depth_col1, "char(50)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*output_class,"n_catalogname", "char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*output_class,"n_catalogdesc", "char(40)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*output_class,"class_type","char(2)");
           if(status != MEM_S_SUCCESS)
                  {
                   MEMclose(&class_bufr);
                  _PDMdebug(fname,"MEMwrite_format failed status %d\n", status);
                   return(status);
                  } 

            for(i=0; i < class_bufr->rows; i++)
            {
                nxi = i * class_bufr->columns;
            if(PDMexec->operation == 1)
            {
            strcpy(catalog,cat_data[nxi]);
            strcpy(catalogdesc,cat_data[nxi+1]);
            strcpy(type,"C");
            strcpy(class,"");
             }
           else
           {
            strcpy(type,"CL");
            strcpy(catalog,"");
            strcpy(class,cat_data[nxi]);
            strcpy(catalogdesc,"");
            }
              sprintf(mem_str,"%s\1%s\1%s\1%s\1%s\1", "" , class, catalog,catalogdesc,type);

          status = MEMwrite(*output_class, mem_str);
             if(status != MEM_S_SUCCESS)
                   {
                     MEMclose(&class_bufr);
                  _PDMdebug(fname,"MEMwrite failed status %d\n", status);
                     return(status);
                   } 

               } 
               MEMclose(&class_bufr);
    if(PDMexec->operation != 1)
    {
  if((input_buffer->rows > 0) && (strcmp(search_str,"")) && (depth_col != NULL && strcmp(depth_col,""))) 
      {
      if(strlen(PDMexec->project) > 1) {
       /* If the multiple sa were mapped to same catalog, and also to the
          same project, duplicate rows were retrieved. Added distinct 
          catalogname to these queries. MaC 113093 */

         sprintf(sql_str, "%s %s %s %s %s %s %s %s %s %s '%s' %s %s %s ",
           "SELECT DISTINCT (t1.n_catalogname), t1.n_catalogdesc, t2.p_depth ",
           " FROM nfmcatalogs t1, pdmcatalogs t2 , nfmprojects t3,",
           " nfmcatalogsamap t4, nfmprojectsamap t5 ", search_str,
           " AND t1.n_catalogno = t2.n_catalogno AND (",
           depth_col, "  is NULL or ", depth_col, " = '') ",
           " AND t3.n_projectname = ", PDMexec->project,
           "  AND t5.n_projectno = t3.n_projectno",
           "  AND t4.n_mapno = t5.n_mapno AND t4.n_catalogno = t1.n_catalogno",
           "  ORDER BY t1.n_catalogname");
       }
      else
       {
       if(!strcmp(search_str,"WHERE "))
          sprintf(sql_str, " %s %s %s %s %s %s %s %s %s ",
            "SELECT DISTINCT (t1.n_catalogname), t1.n_catalogdesc, t2.p_depth",
            "  FROM nfmcatalogs t1, pdmcatalogs t2", search_str ,
            "  t1.n_catalogno = t2.n_catalogno and (",
             depth_col, " is NULL or ", depth_col, " = '') ",
            " ORDER BY n_catalogname");
      else
          sprintf(sql_str,"SELECT DISTINCT (t1.n_catalogname), t1.n_catalogdesc, t2.p_depth FROM nfmcatalogs t1, pdmcatalogs t2 %s  AND t1.n_catalogno = t2.n_catalogno and (%s is NULL or %s = '') ORDER BY n_catalogname", search_str , depth_col, depth_col);
        }
       }
     else
     {
      if(strlen(PDMexec->project) > 1)
        sprintf(sql_str, " %s %s %s %s %s %s '%s' %s %s %s ",
         "SELECT DISTINCT (t1.n_catalogname), t1.n_catalogdesc, t2.p_depth ",
         " FROM nfmcatalogs t1, pdmcatalogs t2 , nfmprojects t3, ",
         " nfmcatalogsamap t4,nfmprojectsamap t5 WHERE ",
         " t1.n_catalogno = t2.n_catalogno AND ",
         " (t2.p_level1 is NULL or p_level1 = '') ",
         " AND t3.n_projectname =  ",
         PDMexec->project,
         " AND t5.n_projectno = t3.n_projectno ",
         " AND t4.n_mapno = t5.n_mapno AND t4.n_catalogno = t1.n_catalogno ",
         " ORDER BY t1.n_catalogname");
      else
        sprintf(sql_str, " %s %s %s %s %s ",
           "SELECT t1.n_catalogname, t1.n_catalogdesc, t2.p_depth ",
           " FROM nfmcatalogs t1, pdmcatalogs t2 where ",
           " t1.n_catalogno = t2.n_catalogno AND ",
           " (t2.p_level1 is NULL or t2.p_level1 = '') ",
           " ORDER BY n_catalogname");
      }
      _PDMdebug(fname,"Calling SQLquery:\n%s\n", sql_str);
      status = SQLquery(sql_str,&class_bufr, 1024);
      if(status != SQL_S_SUCCESS) {
        MEMclose(&class_bufr);
        if(status == SQL_I_NO_ROWS_FOUND) {
           MEMclose(&class_bufr);
           _PDMdebug(fname, "No catalogs as class :\n");
           _PDMdebug(fname, "Exit :\n");
           status = MEMbuild_array(*output_class);
           if(status != MEM_S_SUCCESS) {
              _PDMdebug(fname,
                "MEMbuild array of output_class failed status %d\n", status);
              return(status);
              } 
           if(((*output_class)->rows == 0) || (*output_class == NULL)) 
                return(PDM_I_NO_CAT_IN_PATH);
           else 
                return(PDM_S_SUCCESS);
             }
        else
           {
           _PDMdebug(fname,"SQLquery failed status %d\n", status);
           return(status);
           }
       } 

          status = MEMbuild_array(class_bufr);
             if(status != MEM_S_SUCCESS)
               {
                     MEMclose(&class_bufr);
                  _PDMdebug(fname,"MEMbuild array failed status %d\n", status);
                     return(status);
                   } 

            cat_data  = (char **) class_bufr->data_ptr;

            for(i=0; i < class_bufr->rows; i++)
            {

                nxi = i * class_bufr->columns;
                strcpy(catalog, cat_data[nxi]);
                strcpy(catalogdesc, cat_data[nxi+1]);
                  
            if(PDMexec->operation == 1)
sprintf(mem_str,"%s\1\1%s\1%s\1%s\1", cat_data[nxi+2] ,catalog,catalogdesc,"C");
             else
sprintf(mem_str,"%s\1%s\1\1%s\1%s\1", cat_data[nxi+2] ,catalog,catalogdesc,"C");


          status = MEMwrite(*output_class, mem_str);
             if(status != MEM_S_SUCCESS)
                   {
                     MEMclose(&class_bufr);
                  _PDMdebug(fname,"MEMwrite failed status %d\n", status);
                     return(status);
                   } 
           }

                     MEMclose(&class_bufr);
      }
        if ((PDMdebug_on) && (*output_class))
                MEMprint_buffer("output_class",*output_class, PDM_DEBUG_FILE);
        _PDMdebug(fname, "Exit:..\n");
           if ((*output_class == NULL) || ((*output_class)->rows == 0))
              return(PDM_I_NO_CAT_IN_PATH);
           else return(PDM_S_SUCCESS);
}

/*
        GET CLASSIFICATION OF EXISTING CATALOG

At one time a catalog can have only one classification path.
But the classification path can be changed,deleted. There are seperate
protocols to do that.


int PDMget_class_of_cat(catalog_name, class_path)
char    *catalog_name;  Input - given catalog name 
MEMptr   *class_path;   Output - Classification path 

                      Format of output buffer:
 p_level1 char(40), level_2 char(40), level_3 char(40) ...... level_n char(40)

Example 1:
If you want the classification for a catalog called "FES"

                       output_bufr:
 p_level1       level_2      level_3    level_4
 Mechanical    Equipment    Sheetmetal    NULL

Example 2:
If the catalog doesn't have any classifications at level 1 , then a error
will be returned [PDM_I_NO_CLASS]. But the output buffer will have the
unique classifications at level 1. This aviods one more query to the
database for displaying the level 1 classifications, if the user wants
to classify the given catalog.


Return Codes:
PDM_S_SUCCESS  - Successful Completion
PDM_I_NO_CLASS - Catalog doen't have any classification.
PDM_E_CATALOG_NOT_FOUND - Catalog not found in PDMdatabase.

- Kumar Narayanan
*/

int PDMget_class_of_cat(catalog_name, class_path)
char    *catalog_name;
MEMptr  *class_path;

{
 char   *fname = "PDMget_class_of_cat";
 char   **data;
 MEMptr bufr = NULL;
 char   sql_str[512];
 int    catno;
 char   *column_str;

        
        _PDMdebug(fname,"Enter:\n");
        status = PDMris_get_catno(catalog_name,&catno);
        if(status != SQL_S_SUCCESS)
        {
                return(PDM_E_CATALOG_NOT_FOUND);
        }
	sql_str[0] = '\0';
	sprintf(sql_str,"SELECT p_depth from pdmcatalogs where n_catalogno = %d", catno);
		status = SQLquery(sql_str, &bufr, 512);
                if(status != SQL_S_SUCCESS)
                  {
                     if(status == SQL_I_NO_ROWS_FOUND)
                       {
                          return(PDM_I_NO_CLASS);
                        }
                      else return (status);
                  }

          status = MEMbuild_array(bufr);
           if(status != MEM_S_SUCCESS)
            {
              MEMclose(&bufr);
	  sprintf(s,"MEMbuild_array failed status %d\n",
	  status); PDMdebug(s);
	  return(PDM_I_NO_CLASS);
             }
         data  = (char **) bufr->data_ptr;

      status = PDMget_pdmloc_levels(atoi (data[0]), &column_str);
        if(status != PDM_S_SUCCESS)
          {
             column_str = (char *) malloc (20);
              strcpy(column_str,"p_level1");
           }
            if(!strcmp(column_str,"")) strcpy(column_str,"p_level1"); 
        
	sql_str[0] = '\0';
	sprintf(sql_str,"SELECT %s from pdmcatalogs where n_catalogno = %d",column_str, catno);
		status = SQLquery(sql_str, class_path, 512);
                if(status != SQL_S_SUCCESS)
                  {
                     if(status == SQL_I_NO_ROWS_FOUND)
                       {
                          MEMclose(class_path);
                          MEMclose(&bufr);
                          return(PDM_I_NO_CLASS);
                        }
                      else return (status);
                  }
           MEMclose(&bufr);

        _PDMdebug(fname,"Exit:\n");
      return(PDM_S_SUCCESS);
}


/* Kumar Narayanan - Written to support classifications of catalogs
  This function returns the classification level string 
*/

int PDMget_pdmloc_levels(level, loc_str)
int level;
char **loc_str;
{
char   *fname = "PDMget_pdmloc_levels";
int     i =0,catno;
char   sql_str[512];
MEMptr bufr=NULL;
char   **column;

     _PDMdebug(fname, "Enter: \n");
        status = PDMris_get_catno("pdmseedfiles",&catno);
        if(status != SQL_S_SUCCESS)
        {
                return(PDM_E_CATALOG_NOT_FOUND);
        }

     sql_str[0] = '\0';

     sprintf(sql_str,"SELECT * FROM pdmcatalogs WHERE n_catalogno = %d",catno);
	status = SQLquery(sql_str, &bufr, 512);
        if(status != SQL_S_SUCCESS)
        {
           if(status == SQL_I_NO_ROWS_FOUND)
            {
             }
             else return (status);
         }

        if(PDMdebug_on)
        {
                MEMprint_buffer("column_bufr",bufr, PDM_DEBUG_FILE);
        }
        status = MEMbuild_array(bufr);
           if(status != MEM_S_SUCCESS)
              {
              MEMclose(&bufr);
             loc_str = (char **) malloc (20);
              strcpy(*loc_str,"p_level1");
	       sprintf(s,"MEMbuild_array failed status %d\n",
	         status); PDMdebug(s);
              _PDMdebug(fname, "Exit: \n");
               }
         if(status == MEM_S_SUCCESS)
       {
          column = (char **) bufr->column_ptr;
        *loc_str = (char *) malloc ( bufr->columns * 20);
         
        *loc_str[0] = '\0';

      
        for(i=5; i < (level+ 5) ; i++)
        {
          strcat (*loc_str,column[i]);
          if (i != (level + 4)) strcat (*loc_str,", ");
        }            
       
           MEMclose(&bufr);
      }
     _PDMdebug(fname, "Exit: \n");
        return(PDM_S_SUCCESS);
}
         
/*
      
 GET USAGE ID OF EXISTING CATALOG

At one time a catalog can have only one usage id.
But the usage_id can be changed,deleted. There are seperate
protocols to do that.


int PDMget_usageid_cat(catalog_name, usage_id)
char       *catalog_name;  Input - given catalog name 
usage_id   **usage_id;     Output - Usage_id
                           Size of char 40. Need not allocate memory,
                             But need to free it up 

Example 1:
If you want the usage_id for a catalog called "FES"
                       output:
"Front End Structure"
Example 2:
If the catalog doesn't have any usage_id , then a NULL STRING
will be returned. But the return status will be still PDM_S_SUCCESS.


Return Codes:
PDM_S_SUCCESS  - Successful Completion
PDM_E_CATALOG_NOT_FOUND - Catalog not found in PDMdatabase.
 
- Kumar Narayanan
*/

int PDMget_usageid_cat (catalog_name, usage_id)
char  *catalog_name;
char  **usage_id;
{
char  *fname = "PDMget_usageid_cat";
int    catno;
char   sql_str[512];
char    **data;
MEMptr temp_bufr = NULL;

        _PDMdebug(fname,"Enter:\n");
        status = PDMris_get_catno(catalog_name,&catno);
        if(status != SQL_S_SUCCESS)
        {
                return(PDM_E_CATALOG_NOT_FOUND);
        }
  sprintf(sql_str, "SELECT p_defname FROM pdmcatalogs WHERE n_catalogno = %d ", catno);
        status = SQLquery(sql_str,&temp_bufr,1024);
        if(status != SQL_S_SUCCESS)
        {
                if(status == SQL_I_NO_ROWS_FOUND)
                {
                        return(PDM_I_NO_USAGE_ID);
                }
                return(PDM_E_SQL_QUERY);
        }
        status = MEMbuild_array(temp_bufr);
        if(status != MEM_S_SUCCESS)
        {
                MEMclose(&temp_bufr);
                return(PDM_E_BUILD_ARRAY);
        }
        data = (char **) temp_bufr->data_ptr;

        *usage_id = (char *) malloc (40);
         
         strcpy(*usage_id, data[0]);

         MEMclose(&temp_bufr);
        _PDMdebug(fname,"Exit:\n");
        return(PDM_S_SUCCESS);

}


/*
GET THE ATTRIBUTES OF TEMPLATE CATALOG

This function gets the attribute information for a given template catalog.

- Kumar Narayanan

*/
long PDMtemplate_catalog_attributes (catalog_name,
                                     attr_list, data_list, value_list)
   char     *catalog_name ;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "PDMtemplate_catalog_attributes" ;
     long     status;
     long     _NFMget_table_attr ();
     long     _NFMget_data_info ();

     _PDMdebug (fname, "ENTER\n") ;

     status = _NFMget_table_attr (catalog_name,  attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
         _PDMdebug (fname, "Table attr : status = <0x%.8x>\n, status") ;
         return (status) ;
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
        return (status);
      }

     _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n",
     PDM_S_SUCCESS);
     return (PDM_S_SUCCESS);
   }


/*

STORE CLASSIFICATION PATH IN PDMCATALOGS


PDM function call for storing the classification path of a given catalog.
At a time, a catalog can have only one classification path[ It can't follow
multiple paths ].

The previous classification path of the catalog will be deleted[ If it exists].
If the level doesn't exist in the database, a new level is created.
More than one catalog can be classified at a time.


int PDMstore_classification(class_path)
MEMptr class_path;  Input 

Input:
Format of input buffer:
n_catalogname char(20)  p_usageid char(40) level_1 char(40) level_2 char(40)..

Example 1:
If you want to store the classifications selected classes of Mechanical,Equipmen
t,Sheetmetal of a catalog like "FES"

                       input_buffer:
 n_catalogname   p_usageid         level_1     level_2   level_3     level_4
 FES             Europe standard   Mechanical  Equipment Sheetmeetal NULL


Example 2:
If you want store the  classifications of more than one catalog :
 n_catalogname   p_usageid         level_1     level_2   level_3     level_4 le
 FES             Europe standard   Mechanical  Equipment Sheetmeetal NULL
 Axle            ANSI              Mechanical  Machined  NULL
 WHEEL           ISI               Mechanical  Machined  FRONT       LH      NUL


Return Codes:
PDM_S_SUCCESS - Successful Completion

- Kumar Narayanan
*/


int PDMstore_classification(class_path)
MEMptr class_path; 

{


        char            *fname = "PDMstore_classification";
        MEMptr          class_bufr = NULL;
        MEMptr          bufr = NULL;
        char            search[100];
        char            **data = NULL, **column = NULL;
        long            status = PDM_S_SUCCESS; 
        long            status1 = SQL_S_SUCCESS; 
        char            search_str[1024];
        char            sql_str[1024];
        char            sql_str1[512];
        char            value_str[1024];
        char            dyn_table[41];
        char            usage_id[100];
        int             i,nxi, current_depth = 0, cat_no;
        char            **cat_data;


        _PDMdebug(fname, "Enter:..\n");

        if(PDMdebug_on)
        {
                MEMprint_buffer("class_path",class_path, PDM_DEBUG_FILE);
        }
   status = MEMbuild_array(class_path);
           if(status != MEM_S_SUCCESS)
            {
                     MEMclose(&class_path);
	  sprintf(s,"MEMbuild_array failed status %d\n",
	  status); PDMdebug(s);
	  return(PDM_E_BUILD_ARRAY);
             }
         data  = (char **) class_path->data_ptr;
         column  = (char **) class_path->column_ptr;

         /***************************************************************
         for (i=0 ; i < class_path->columns; i++)
          {
              nxi = i * class_path->columns;
               if(atoi(data[nxi]) > current_depth)
                      current_depth = atoi (data[nxi]);
              search[0] = '\0';
              sprintf(search,"p_level%s = '%s' and ", data[nxi],data[nxi+1]);
            strcat(search_str, search); 
          }
          Make the where clause to include the previous 
            classification path
           ***************************************************************/

           current_depth = atoi(data[0]);

         for (i=0 ; i < class_path->rows; i++)
          {
              nxi = i * class_path->columns;

           status =  PDMris_get_catno (data[nxi], &cat_no);
             if (status != SQL_S_SUCCESS) {
              _PDMdebug (fname, "PDMris_get_catno: status %d\n", status);
               return(PDM_E_CATALOG_NOT_FOUND);
                        }

           _PDMdebug(fname, "PDMdynamic_table : [%s]\n", PDMdynamic_table);

           dyn_table[0] = '\0';
           status = PDMget_dyntable_for_catalog (data[nxi], dyn_table);
           if (status != PDM_S_SUCCESS) {
             _PDMdebug(fname, 
               "PDMget_dyntable_for_catalog failed status %d\n",status);
             return(status);
           }
            
           _PDMdebug(fname, "dyn table name: <%s>\n", dyn_table);

           if (strlen (dyn_table) > 0) {
              PDMdynamic_table[0] = '\0';
              strcpy (PDMdynamic_table, dyn_table);
            }
           
         sql_str[0]='\0';
            
            if((strlen(data[nxi+1]) > 1) && (strcmp(data[nxi+1],""))) 
            strcpy(usage_id, data[nxi+1]);
            else strcpy(usage_id, "");

     sprintf(sql_str,"SELECT p_defname, p_depth FROM  pdmcatalogs WHERE n_catalogno = %d", cat_no);
             status = SQLquery(sql_str,&class_bufr, 1024);
                if(status != SQL_S_SUCCESS)
                    {
                     if(status == SQL_I_NO_ROWS_FOUND)
                      {
                       }
                      else
                      {
                  _PDMdebug(fname,"SQLquery failed status %d\n", status);
                     return(status);
                       }
                     } 
                   else
                    {
                     status = MEMbuild_array(class_bufr);
                      if(status != MEM_S_SUCCESS)
                       {
                     MEMclose(&class_bufr);
                     MEMclose(&class_path);
                  _PDMdebug(fname,"MEMbuild array failed status %d\n", status);
                     return(status);
                         } 
            cat_data  = (char **) class_bufr->data_ptr;
               
            if(!strcmp(usage_id,""))
                   strcpy(usage_id, cat_data[0]);
    sprintf(sql_str,"DELETE  FROM  pdmcatalogs WHERE n_catalogno = %d", cat_no);
             status = SQLstmt(sql_str);
               if(status != SQL_S_SUCCESS)
                 {
                  _PDMdebug(fname,"SQLquery failed status %d\n", status);
                 }
               MEMclose(&class_bufr);
               }
                  
           current_depth = 0;

              strcpy(search_str,""); 
              strcpy(value_str,""); 
         for (i=2 ; i < class_path->columns; i++)
          {
               if( (strlen(data[i]) > 1) && (strcmp(data[i],"")))
                 {
                      current_depth++;
              search[0] = '\0';
              strcat(search_str,", "); 
              sprintf(search,"p_level%d",current_depth);
            strcat(search_str, search); 
              strcat(value_str,",'"); 
            strcat(value_str, data[nxi+i]); 
              strcat(value_str,"'"); 
                 }
          }
          if(!strcmp(PDMdynamic_table,""))
     sprintf(sql_str,"INSERT INTO  pdmcatalogs(n_catalogno, p_depth, p_defname %s)  VALUES (%d,%d, '%s' %s )",search_str, cat_no, current_depth, usage_id, value_str);
       else
     sprintf(sql_str,"INSERT INTO  pdmcatalogs(n_catalogno, p_depth, p_dyntable, p_defname %s)  VALUES (%d,%d, '%s', '%s' %s )",search_str, cat_no, current_depth, PDMdynamic_table,usage_id, value_str);
             status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS)
                 {
     sprintf(sql_str1,"SELECT %s FROM pdmcatalogs WHERE n_catalogno = -1",(search_str+1));
                   status1 = SQLquery(sql_str1, &bufr, 512);
                    if(status1 == SQL_I_NO_ROWS_FOUND)
                      {
                       MEMclose(&bufr);
                  _PDMdebug(fname,"Could not insert path for %s\n", data[nxi]);
                  _PDMdebug(fname,"SQLstmt failed status %d\n", status);
                   return(status);
                      }
                   else
                      {
                       MEMclose(&bufr);
         status =  PDMadd_more_levels(class_path);
           if(status != PDM_S_SUCCESS)
              {
           _PDMdebug(fname,"PDMadd_more_levels failed %d\n", status);
             return(status);
              }
             status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS)
                          {
                  _PDMdebug(fname,"Could not insert path for %s\n", data[nxi]);
                  _PDMdebug(fname,"SQLstmt failed status %d\n", status);
                   return(status);
                          }
                       }
                 }
        }
        _PDMdebug(fname, "Exit:..\n");

      return(PDM_S_SUCCESS);
}


/* Kumar Narayanan - Written to support add more classification path to
   the classifications of catalogs
*/

int PDMadd_more_levels(class_path)
MEMptr class_path;
{
char   *fname = "PDMadd_more_levels";
int     i =0, k = 0, x = 0, found = 0;
char   sql_str[512], new_column[30];
MEMptr bufr=NULL;
char   **cur_col, **new_col, **new_for;

     _PDMdebug(fname, "Enter: \n");
     sql_str[0] = '\0';

  sprintf(sql_str,"SELECT * FROM pdmcatalogs WHERE n_catalogno = -1");
	status = SQLquery(sql_str, &bufr, 512);
        if(status != SQL_S_SUCCESS)
        {
           if(status == SQL_I_NO_ROWS_FOUND)
            {
             }
             else return (status);
        }

        if(PDMdebug_on)
        {
                MEMprint_buffer("column_bufr",bufr, PDM_DEBUG_FILE);
        }
        status = MEMbuild_array(bufr);
           if(status != MEM_S_SUCCESS)
              {
	       sprintf(s,"MEMbuild_array failed status %d\n",
	         status); PDMdebug(s);
              _PDMdebug(fname, "Exit: \n");
               return(status);
               }
            cur_col = (char **) bufr->column_ptr;
            new_col = (char **) class_path->column_ptr;
            new_for = (char **) class_path->format_ptr;

        for (i=2 ; i < class_path->columns; i++)
         {
           found = 0;
            x = strlen(new_col[i]);
            new_column[0] = '\0';
            if( new_col[i][x-2] != '_')
            {
            sprintf(new_column,"p_level%s", (new_col[i]+(x-2))); 
            for (k = 0; k < bufr->columns; k++)
             {
               if(!strcmp(new_column, cur_col[k]) )
                 {
                  found = 1;
                  break;
                 }
              }
           if( found == 0 )  
               {
             sql_str[0] = '\0';
            sprintf(sql_str, "ALTER TABLE pdmcatalogs add %s %s", 
                             new_column, new_for[i]);
               status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS)
                  {
          _PDMdebug(fname,"Could not alter table for %s\n", new_col[i]);
                  } 
               }

             }
          }
           MEMclose(&bufr);
     _PDMdebug(fname, "Exit: \n");
        return(PDM_S_SUCCESS);
}
         
