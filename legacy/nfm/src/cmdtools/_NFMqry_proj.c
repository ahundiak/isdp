#include "machine.h"
#include "CMDTOOLS.h"
#include "WFstruct.h"

  extern struct WFstruct WFinfo ;

long _NFMquery_project_members (user_id, project_name, attr_list, data_list)
     long     user_id;
     char     *project_name;
     MEMptr   *attr_list, *data_list;
{
  char *fname="_NFMquery_project_members";
  long     status;
  long     catoffset = 0, itemoffset = 0, projoffset = 0;
  char     p_name[50];
  char     cit_str [1024];
  long     proj_no ;
  long     NFMprojectcit_attributes ();
  long     NFMload_project_members ();
  
  _NFMdebug ((fname,"Project Name = <%s> ", project_name ));
  
  if (strlen (project_name))
    {
      status = NFMget_project_no (user_id, project_name, &proj_no); 
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "NFMget_project_no : status = <0x%.8x>\n",
		      status));
	  return (status);
	}
      _NFMdebug ((fname, "Project Number = <%d>", proj_no));
    }
  else
    {
      _NFMdebug ((fname, "Blank Project Name : status = <0x%.8x>\n",
		  NFM_E_BAD_PROJECT));
      ERRload_struct (NFM, NFM_E_BAD_PROJECT, "", "") ;
      return (NFM_E_BAD_PROJECT) ;
    }

/********* done at validation ************      
      sprintf (sql_str, "SELECT n_mapno FROM nfmprojectaclmap \
WHERE n_projectno = %ld", proj_no ) ;
      
      status = SQLquery (sql_str, &list, 512);
      if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&list);
	 
	 if ((status ) == SQL_I_NO_ROWS_FOUND)
	   {
	     ERRload_struct(NFM,NFM_E_NO_PROJECT_ACL_MAP,"",NULL);
	     _NFMdebug ((fname, "Project Not Mapped to ACL : status = <0x%.8x>\n", status));
	     return (NFM_E_NO_PROJECT_ACL_MAP);
	   }
	 
	 ERRload_struct(NFM,NFM_E_SQL_QUERY,"",NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);
      }

      MEMclose(&list); list = NULL;

     sprintf (sql_str, "SELECT n_mapno FROM nfmprojectsamap \
WHERE n_projectno = %ld", proj_no ) ;

     status = SQLquery (sql_str, &list, 512);
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&list);
	 
	 if ((status ) == SQL_I_NO_ROWS_FOUND)
	   {
	     ERRload_struct(NFM,NFM_E_NO_PROJECT_SA_MAP,"",NULL);
	     _NFMdebug ((fname, "Project Not Mapped to SA : status = <0x%.8x>\n", status));
	     return (NFM_E_NO_PROJECT_SA_MAP);
	   }
	 
	 ERRload_struct(NFM,NFM_E_SQL_QUERY,"",NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);
      }

      MEMclose(&list); list = NULL;
************** done in validation *********************************/
  cit_str [0] = 0;
  p_name [0] = 0;
  status = NFMprojectcit_attributes (user_id, &projoffset, &catoffset, 
				     &itemoffset, p_name, cit_str, 
				     attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      _NFMdebug ((fname, "Query Project Cit Attr : status = <0x%.8x>\n",
		  status));
      return (status); 
    }
  
  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
		  status));
      return (NFM_E_MEM); 
    }
  
  status = NFMload_project_members (user_id, project_name, p_name, 
				    projoffset,  catoffset, 
				    itemoffset, cit_str, 
				    *attr_list, *data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      _NFMdebug ((fname, "Load Project Members : status = <0x%.8x>\n",
		  status));
      return (status); 
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}

long NFMqry_items_in_cat_for_project (user_id, project_name, catalog_name,
				      data_list)
     long     user_id;
     char     *project_name;
     char     *catalog_name ;
     MEMptr   *data_list;
{
  char *fname = "NFMqry_items_in_cat_for_project";
  long     status;
  MEMptr   owned_list = NULL ;
  MEMptr   ref_list = NULL ;
  char     sql_str [1024], sano_str [1024], acl_str [1024] ;
  char     cit_str [100], item_str [1024], str [512], owned_str [100];
  long     proj_no, cat_no ;
  int      i ;
  char     **owned_data, **ref_data ;
  
  _NFMdebug ((fname,"Project Name = <%s> : Catalog Name = <%s>\n", 
	      project_name, catalog_name));
  
  if (strlen (project_name))
    {
      status = NFMget_project_no (user_id, project_name, &proj_no); 
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "NFMget_project_no : status = <0x%.8x>\n",
		      status));
	  return (status);
	}
      _NFMdebug ((fname, "Project Number = <%d>", proj_no));
    }
  else
    {
      _NFMdebug ((fname, "Blank Project Name : status = <0x%.8x>\n",
		  NFM_E_BAD_PROJECT));
      return (NFM_E_BAD_PROJECT) ;
    }
  
  if (strlen (catalog_name))
    {
      status = NFMget_catalog_no (user_id, catalog_name, &cat_no) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "NFMget_catalog_no : status = <0x%.8x>\n",
		      status));
	  return (status);
	}
      _NFMdebug ((fname, "Catalog Number = <%d>", cat_no));
    }
  else
    {
      _NFMdebug ((fname, "Blank Catalog Name : status = <0x%.8x>\n",
		  NFM_E_BAD_CATALOG));
      return (NFM_E_BAD_CATALOG) ;
    }
  
  /*  GET ITEMS THAT ARE POTENTIAL OWNED MEMBERS TO THE PROJECT */
  sprintf (cit_str, "SELECT n_itemno \
FROM NFMPROJECTCIT WHERE n_catalogno = %d", cat_no) ;
  
  sprintf (acl_str, "SELECT NFMCATALOGACLMAP.n_aclno \
FROM NFMCATALOGACLMAP, NFMPROJECTACLMAP \
WHERE NFMCATALOGACLMAP.n_mapno = NFMPROJECTACLMAP.n_mapno \
AND   NFMPROJECTACLMAP.n_projectno = %d \
AND   NFMCATALOGACLMAP.n_catalogno = %d", 
	   proj_no, cat_no) ;
  
  sprintf (sano_str, "SELECT NFMCATALOGSAMAP.n_sano  \
FROM NFMCATALOGSAMAP, NFMPROJECTSAMAP \
WHERE NFMCATALOGSAMAP.n_mapno = NFMPROJECTSAMAP.n_mapno \
AND   NFMPROJECTSAMAP.n_projectno = %d \
AND   NFMCATALOGSAMAP.n_catalogno = %d", 
	   proj_no, cat_no) ;
  
  sprintf (item_str, "SELECT n_itemnum FROM f_%s  \
WHERE n_cisano NOT IN (%s)", 
	   catalog_name, sano_str) ;
  
  sprintf (sql_str, "SELECT DISTINCT %s, %s \
FROM %s WHERE n_itemno NOT IN (%s AND n_type = 'O') \
AND n_aclno IN (%s) \
AND n_itemno NOT IN (%s)",
	   "n_itemname", "n_itemrev",
	   catalog_name, cit_str, acl_str, item_str);
  
  status = SQLquery (sql_str, &owned_list, 2*MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&owned_list);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
      _NFMdebug ((fname, "SQL Query Syntax Error  = <0x%.8x>\n", status));
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (owned_list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&owned_list);
      ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
      _NFMdebug ((fname, "Failure : MEMbuild_array : status <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  owned_data = (char **) owned_list->data_ptr ;
  
  sprintf (owned_str, "SELECT n_itemno FROM NFMPROJECTCIT \
WHERE n_catalogno = %d AND  n_type= 'O'",
	   cat_no) ;
  
  /*  GET ITEMS THAT ARE POTENTIAL REFERENCED MEMBERS TO THE PROJECT */
  
  sprintf (sql_str, "SELECT DISTINCT %s, %s \
FROM %s  WHERE n_itemno NOT IN (%s AND (n_type= 'R' OR n_type = 'O') AND n_projectno = %d)\
AND (n_aclno NOT IN (%s) \
OR n_itemno IN (%s) \
OR n_itemno IN (%s))",
	   "n_itemname", "n_itemrev",
	   catalog_name, cit_str, proj_no, acl_str, item_str,
	   owned_str) ;
  
  status = SQLquery (sql_str, &ref_list, 2*MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&owned_list);
      MEMclose (&ref_list);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
      _NFMdebug ((fname, "Sql Query Failed : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (ref_list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&owned_list);
      MEMclose (&ref_list);
      ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  
  if ((ref_list->rows == 0) && (owned_list->rows == 0))
    {
      MEMclose (&owned_list);
      MEMclose (&ref_list);
      ERRload_struct (NFM, NFM_E_NO_ITEMS_FOUND_IN_CAT, "", NULL) ;
      _NFMdebug ((fname, "No items found : status = <0x%.8x>", status));
      return (NFM_E_NO_ITEMS_FOUND_IN_CAT);          
    }
  
  ref_data = (char **) ref_list->data_ptr ;
  
  status = MEMopen (data_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&owned_list);
      MEMclose (&ref_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "Failure : MEM Open : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  status = MEMwrite_format (*data_list, "n_itemname", "char(60)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&owned_list);
      MEMclose (&ref_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "Failure : MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  status = MEMwrite_format (*data_list, "n_itemrev", "char(60)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&owned_list);
      MEMclose (&ref_list);
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "Failure : MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  status = MEMwrite_format (*data_list, "n_type", "char(1)");
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&owned_list);
      MEMclose (&ref_list);
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "Failure : MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  for (i=0; i<owned_list->rows; i++)
    {
      strcpy (str, owned_data [i*owned_list->columns]);
      strcat (str, "\1");
      strcat (str, owned_data [i*owned_list->columns+1]) ;
      strcat (str, "\1");
      if (! strcmp (WFinfo.current_statename, "PROJECT MAPPED"))
	strcat (str, "O");
      else
	strcat (str, "R");
      strcat (str, "\1");
      
      status = MEMwrite (*data_list, str);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&owned_list);
	  MEMclose (&ref_list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "Failure : MEMwrite : <0x%.8x>", status));
	  return (NFM_E_MEM);
	}
    }
  
  for (i=0; i<ref_list->rows; i++)
    {
      strcpy (str, ref_data [i*ref_list->columns]);
      strcat (str, "\1");
      strcat (str, ref_data [i*ref_list->columns+1]) ;
      strcat (str, "\1");
      strcat (str, "R");
      strcat (str, "\1");
      
      status = MEMwrite (*data_list, str);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&owned_list);
	  MEMclose (&ref_list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "Failure : MEMwrite : <0x%.8x>", status));
	  return (NFM_E_MEM);
	}
    }
  
  status = MEMclose (&ref_list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&owned_list);
      _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      return (NFM_E_MEM);
    }
  
  status = MEMclose (&owned_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : MEMclose : status = <0x%.8x>\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      return (NFM_E_MEM);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}

long NFMload_project_members (user_id, proj_name, p_name, c_projoffset, 
			      c_catoffset, c_itemoffset, cit_str, 
			      attr_list, data_list)
     long    user_id;
     char    *proj_name;         /* name of the project. */
     char    *p_name;            /* n_name for "n_projectno" in projcit. */
     long    c_projoffset, c_catoffset, c_itemoffset;
     char    *cit_str;           /* attributes to be used in the query. */ 
   MEMptr  attr_list, data_list;
{
  char *fname="NFMload_project_members ";
  long      status, atol ();
  long      proj_no;
  int       found;
  char      *sql_str;
  MEMptr    list = NULL;
  char      **column,  **data;
  char      **column1, **data1;
  long      a, x, y, z, count, count1; 
  char      cat_name [100];
  char      item_name [NFM_ITEMNAME+1];
  char      item_rev [NFM_ITEMREV +1] ;
  
  _NFMdebug ((fname,"Project Name = <%s> : P Name = <%s> : Projoffset = <%d> : Catoffset = <%d> : Itemoffset = <%d> : Cit Str = <%s>\n",
	      proj_name, p_name, c_projoffset, c_catoffset,
	      c_itemoffset, cit_str));
  
  proj_no = 0; 
  if (strlen(proj_name))
    {
      status = NFMget_project_no (user_id, proj_name, &proj_no); 
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "NFMget_project_no : status = <0x%.8x>\n",
                      status));
	  return (status);
	}
      _NFMdebug ((fname, "Project Number = <%d>", proj_no));
      
      sql_str = (char *) malloc (strlen (cit_str) + 2 * MEM_SIZE);
      if (! sql_str)
	{
	  ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	  _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		      NFM_E_MALLOC));
	  return (NFM_E_MALLOC);
	}
      sql_str [0] = 0;
      
      sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %d",
	       cit_str, "NFMPROJECTCIT", p_name, proj_no);
      
      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) &&
	  ((status) != SQL_I_NO_ROWS_FOUND))
	{
	  free (sql_str);
	  MEMclose (&list);
	  ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	  _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", 
		      status));
	  _NFMdebug ((fname,"GET PROJ MEM : sql_str = <%s>\n", sql_str));
	  return ( NFM_E_SQL_QUERY); 
	}
      
      free (sql_str);
      
      if ((status) == SQL_I_NO_ROWS_FOUND)
	{
	  MEMclose (&list) ;
	  _NFMdebug ((fname,"GET PROJ MEM : %s\n","NO ITEMS EXIST FOR GIVEN PROJECT"));
/******* this function is called in both delete and add, can not return
         this error because the interface will no add members when this
         call fails 
	  ERRload_struct (NFM, NFM_E_NO_MEMBERS_IN_PROJECT, "%s", proj_name) ;
	  return (NFM_E_NO_MEMBERS_IN_PROJECT) ;  
**************/
	}
      else
	{
	  column = (char **) attr_list -> column_ptr;
	  data   = (char **) attr_list -> data_ptr;
	  
	  a = -1; 
	  
	  for (y = 0; y < attr_list -> columns; ++y)
	    {
	      if (! strcmp (column [y], "n_name"))       a = y;
	    }
	  
	  status = MEMbuild_array (list);
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "Failure : MEM Build Array : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_MEM);
	    }
	  
	  column1 = (char **) list -> column_ptr;
	  data1   = (char **) list -> data_ptr;
	  
	  sql_str = (char *) malloc (list -> row_size + 1024);
	  if (! sql_str)
	    {
	      free (sql_str);
	      MEMclose (&list);
	      ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	      _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
			  NFM_E_MALLOC));
	      return (NFM_E_MALLOC);
	    }
	  sql_str [0] = 0;
	  
	  for (y = 0; y < list -> rows; ++y)
	    {
	      count1 = list -> columns * y;
	      
	      status = NFMget_catalog_name (user_id,
					    atol (data1 [count1 + c_catoffset]), cat_name);
	      if (status != NFM_S_SUCCESS)
                {
                  free (sql_str);
                  MEMclose (&list);
                  _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
			      status));
                  return (status);
                }
	      
	      status = NFMget_item_name (user_id, cat_name,
					 atol (data1 [count1 + c_itemoffset]),
					 item_name, item_rev);
	      if (status != NFM_S_SUCCESS)
                {
                  free (sql_str);
                  MEMclose (&list);
                  _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
			      status));
                  return (status);
                }
	      
	      sql_str [0] = 0;
	      
	      for (x = 0; x < attr_list -> rows; ++x)
                {
		  count = attr_list -> columns * x;
		  
		  _NFMdebug ((fname,"attr column : <%s>", data [count + a]));
		  
		  if (! strcmp (data [count + a], "n_status"));
		  else if (! strcmp (data [count + a], "n_catalogname"))
		    strcat (sql_str, cat_name) ;
		  else if (! strcmp (data [count + a], "n_itemname"))
		    strcat (sql_str, item_name);
		  else if (! strcmp (data [count + a], "n_itemrev"))
		    strcat (sql_str, item_rev);
		  else if (! strcmp (data [count + a], "n_projectname"))
                    {
		      strcat (sql_str, proj_name);
                    }
		  else
                    {
                      found = 0;
		      
                      for (z = 0; ((z < list -> columns) && (! found)); ++z)   
			{
			  _NFMdebug ((fname,"data column : <%s>", 
				      column1 [z]));
			  if (! strcmp (data [count + a], column1 [z]))
			    {
			      strcat (sql_str, data1 [count1 + z]);
			      found = 1;
			    }
			}
		      
                      if (! found)
			{
			  free (sql_str);
			  MEMclose (&list);
			  ERRload_struct (NFM,NFM_E_CORRUPTED_BUFFERS, "",
					  NULL);
			  _NFMdebug ((fname, "Buff Crpt : status = <0x%.8x>\n",
				      NFM_E_CORRUPTED_BUFFERS));
			  return (NFM_E_CORRUPTED_BUFFERS);                   
			}
                    }
		  
		  strcat (sql_str, "\1");
                }
	      
	      status = MEMwrite (data_list, sql_str);
	      if (status != MEM_S_SUCCESS)
                {
                  free (sql_str);
                  MEMclose (&list);
		  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                  _NFMdebug ((fname, "Failure : MEM Write : status = <0x%.8x>\n",
			      status));
                  return (NFM_E_MEM);
                }
	    }
	  
	  free (sql_str);
	}
      
      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "Failure : MEM Close : status = <0x%.8x>\n",
		      status));
	  return (NFM_E_MEM);
	}
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}
    
long NFMprojectcit_attributes (user_id, projoffset, catoffset, itemoffset,
			       p_no, cit_str, attr_list, data_list)
     long     user_id;                        /* I */
     long     *projoffset;                    /* O */
     long     *catoffset;                     /* O */
     long     *itemoffset;                    /* O */
     char     *p_no;                          /* O */
     char     *cit_str;                       /* O */
     MEMptr   *attr_list, *data_list;         /* I */
{
  char *fname="NFMprojectcit_attributes ";
  long     status;
  MEMptr   cit_attr = NULL;
  char     **column, **format, **data;
  long     a, x, y, count, insert, comma;
  char     *sql_str, *sql_str1, value [50];
  char     column_name  [50], data_type  [20];
  char     column_name1 [50], data_type1 [20];
  
  _NFMdebug ((fname, "Projoffset = <%d> : Catoffset = <%d> : Itemoffset = <%d> : Proj Attr = <%s> : Cit Str = <%s>\n",
	      projoffset, catoffset, itemoffset, p_no, cit_str));
  
  status = NFMquery_table_definition (user_id,
				      "NFMSYSTEM", "NFMPROJECTCIT", &cit_attr);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&cit_attr);
      _NFMdebug ((fname, "Get Table Attr : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  
  status = MEMbuild_array (cit_attr);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&cit_attr);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "Failure : MEM Build Array : status = <0x%.8x>\n", 
		  status));
      return (NFM_E_MEM);
    }
  
  column = (char **) cit_attr -> column_ptr;
  format = (char **) cit_attr -> format_ptr;
  data   = (char **) cit_attr -> data_ptr;
  
  status = MEMopen (attr_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "Failure : MEM Open : status = <0x%.8x>\n",
		  status));
      return (NFM_E_MEM);
    }
  
  a = -1; 
  
  for (y = 0; y < cit_attr -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))      a = y;
      
      status = MEMwrite_format (*attr_list, column [y], format [y]);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&cit_attr);
	  MEMclose (attr_list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "Failure : MEM Wr For : status = <0x%.8x>\n", status));
	  return (NFM_E_MEM);
	}
    }
  
  sql_str = (char *) malloc ((*attr_list) -> row_size);
  if (! sql_str)
    {
      MEMclose (&cit_attr);
      MEMclose (attr_list);
      ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
      _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
      return (NFM_E_MALLOC);
    }
  
  /*       add :: n_status char(10)   */

  sql_str [0] = 0;
  
  for (y = 0; y < cit_attr -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))
	{
	  strcat  (sql_str, "n_status");
	  sprintf (column_name,   "%s", "n_status");
	}
      else if (! strcmp (column [y], "n_datatype"))
	{
	  strcat  (sql_str, "char(10)");
	  sprintf (data_type, "%s", "char(10)");
	}
      else if (! strcmp (column [y], "n_synonym"))
	strcat (sql_str, "Status");
      else if (! strcmp (column [y], "n_nfmname"))
	strcat (sql_str, "n_status"); 
      else if (! strcmp (column [y], "n_opentonfm"))
	strcat (sql_str, "Y"); 
      else if (! strcmp (column [y], "n_application"))
	strcat (sql_str, "NFM"); 
      else if (! strcmp (column [y], "n_read"))
	strcat (sql_str, "N");
      else if (! strcmp (column [y], "n_write"))
	strcat (sql_str, "N");
      else if (! strcmp (column [y], "n_update"))
	strcat (sql_str, "N");
      else if (! strcmp (column [y], "n_delete"))
	strcat (sql_str, "N");
      else if (! strcmp (column [y], "n_null"))
	strcat (sql_str, "N");
      /*         else if (! strcmp (column [y], "n_keyin"))
		 strcat (sql_str, "0"); */
      else if (! strcmp (column [y], "n_checkin"))
	strcat (sql_str, "N");
      else if (! strcmp (column [y], "n_checkout"))
	strcat (sql_str, "N");
      else if (! strcmp (column [y], "n_seqno"))
	{
	  sprintf (value, "%d", (*attr_list) -> rows);
	  strcat (sql_str, value);
	}
      else if (! strcmp (column [y], "n_valueno"))
	strcat (sql_str, "0");
      
      strcat (sql_str, "\1");
    }
  
  status = MEMwrite (*attr_list, sql_str);
  if (status != MEM_S_SUCCESS)
    {
      free (sql_str);
      MEMclose (&cit_attr);
      MEMclose (attr_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "Failure : MEM Write : status = <0x%.8x>\n", status));
      return (NFM_E_MEM);
    }
  
  status = MEMopen (data_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      free (sql_str);
      MEMclose (&cit_attr);
      MEMclose (attr_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "Failure : MEM Open : status = <0x%.8x>\n", status));
      return (NFM_E_MEM);
    }
  
  status = MEMwrite_format (*data_list, column_name, data_type);
  if (status != MEM_S_SUCCESS)
    {
      free (sql_str);
      MEMclose (&cit_attr);
      MEMclose (attr_list);
      MEMclose (data_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "Failure : MEM Wr For : status = <0x%.8x>\n", status));
      return (NFM_E_MEM);
    }
  
  sql_str1 = (char *) malloc ((*attr_list) -> row_size);
  if (! sql_str1)
    {
      free (sql_str);
      MEMclose (&cit_attr);
      MEMclose (attr_list);
      MEMclose (data_list);
      ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
      _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", 
		  NFM_E_MALLOC));
      return (NFM_E_MALLOC);
    }
  
  for (x = 0; x < cit_attr -> rows; ++x)
    {
      count = cit_attr -> columns * x;
      
      sql_str      [0] = 0;    sql_str1   [0] = 0;
      
      column_name  [0] = 0;    data_type  [0] = 0;
      column_name1 [0] = 0;    data_type1 [0] = 0;
      
      insert = 1;
      
      if (! strcmp (data [count + a], "n_archiveno"))         insert = 0;
      else if (! strcmp (data [count + a], "n_archiveflag"))  insert = 0;
      else if (! strcmp (data [count + a], "n_projectno"))
	{
	  sprintf (p_no, "%s", data[count + a]);
	  for (y = 0; y < cit_attr -> columns; ++y)
	    {
	      if (! strcmp (column [y], "n_name"))
                {
                  strcat (sql_str, "n_projectname");
                  sprintf (column_name, "%s", "n_projectname");
                }
	      else if (! strcmp (column [y], "n_datatype"))
                {
                  strcat (sql_str, "char(20)");
                  sprintf (data_type, "%s", "char(20)");
                }
	      else if (! strcmp (column [y], "n_synonym"))
                {
                  strcat (sql_str, "Project Name");
                }
	      else if (! strcmp (column [y], "n_nfmname"))
                {
                  strcat (sql_str, "n_projectname");
                }
	      else
                {
                  strcat (sql_str, data [count + y]);
                }
	      
	      strcat (sql_str, "\1");
	    }
	}
      else if (! strcmp (data [count + a], "n_catalogno"))
	{
	  for (y = 0; y < cit_attr -> columns; ++y)
	    {
	      if (! strcmp (column [y], "n_name"))
                {
                  strcat (sql_str, "n_catalogname");
                  sprintf (column_name, "%s", "n_catalogname");
                }
	      else if (! strcmp (column [y], "n_datatype"))
                {
                  strcat (sql_str, "char(20)");
                  sprintf (data_type, "%s", "char(20)");
                }
	      else if (! strcmp (column [y], "n_synonym"))
                {
                  strcat (sql_str, "Catalog Name");
                }
	      else if (! strcmp (column [y], "n_nfmname"))
                {
                  strcat (sql_str, "n_catalogname");
                }
	      else
                {
                  strcat (sql_str, data [count + y]);
                }
	      
	      strcat (sql_str, "\1");
	    }
	}
      else if (! strcmp (data [count + a], "n_itemno"))
	{
	  insert = 2;
	  
	  for (y = 0; y < cit_attr -> columns; ++y)
	    {
	      if (! strcmp (column [y], "n_name"))
                {
                  strcat (sql_str,  "n_itemname");
                  strcat (sql_str1, "n_itemrev");
		  
                  sprintf (column_name, "%s", "n_itemname");
                  sprintf (column_name1, "%s", "n_itemrev");
                }
	      else if (! strcmp (column [y], "n_datatype"))
                {
                  strcat (sql_str,  "char(60)");
                  strcat (sql_str1, "char(60)");
		  
                  sprintf (data_type,  "%s", "char(60)");
                  sprintf (data_type1, "%s", "char(60)");
                }
	      else if (! strcmp (column [y], "n_nfmname"))
                {
                  strcat (sql_str,  "n_itemname");
                  strcat (sql_str1, "n_itemrev");
                }
	      else if (! strcmp (column [y], "n_synonym"))
                {
                  strcat (sql_str,  "Item Name");
                  strcat (sql_str1, "Item Revision");
                }
               else
                {
                  strcat (sql_str,  data [count + y]);
                  strcat (sql_str1, data [count + y]);
                }

               strcat (sql_str,  "\1");
               strcat (sql_str1, "\1");
             }
          }
         else
          {
            for (y = 0; y < cit_attr -> columns; ++y)
             {
               if (! strcmp (column [y], "n_name"))
                {
                  strcat  (sql_str, data [count + y]);
                  sprintf (column_name, "%s", data [count + y]);
                }
               else if (! strcmp (column [y], "n_datatype"))
                {
                  strcat  (sql_str, data [count + y]);
                  sprintf (data_type, "%s", data [count + y]);
                }
               else 
                  strcat (sql_str, data [count + y]);
               strcat (sql_str, "\1");
             }
          }

         if (insert)
          {
            status = MEMwrite (*attr_list, sql_str);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               MEMclose (&cit_attr);
               MEMclose (attr_list);
               MEMclose (data_list);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Failure : MEM Write : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
	    
            status = MEMwrite_format (*data_list, column_name, data_type);
            if (status != MEM_S_SUCCESS)
	      {
		free (sql_str);
		free (sql_str1);
		MEMclose (&cit_attr);
		MEMclose (attr_list);
		MEMclose (data_list);
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_NFMdebug ((fname, "Failure : MEM Wr For : status = <0x%.8x>\n",
			    status));
		return (NFM_E_MEM);
	      }
	    
            if (insert == 2)
	      {
		status = MEMwrite (*attr_list, sql_str1);
		if (status != MEM_S_SUCCESS)
		  {
		    free (sql_str);
		    free (sql_str1);
		    MEMclose (&cit_attr);
		    MEMclose (attr_list);
		    MEMclose (data_list);
		    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		    _NFMdebug ((fname, "Failure : MEM Write : status = <0x%.8x>\n", 
				status));
		    return (NFM_E_MEM);
		  }
		
		status = MEMwrite_format (*data_list, column_name1, data_type1);
		if (status != MEM_S_SUCCESS)
		  {
		    free (sql_str);
		    free (sql_str1);
		    MEMclose (&cit_attr);
		    MEMclose (attr_list);
		    MEMclose (data_list);
		    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		    _NFMdebug ((fname, "Failure : MEM Wr For : status = <0x%.8x>\n", 
				status));
		    return (NFM_E_MEM);
		  }
	      }
          }
    }
  
  free (sql_str1);
  free (sql_str);
  
  comma  = 0; y = 0;
  
  for (x = 0; x < cit_attr -> rows; ++x)
    {
      count = cit_attr -> columns * x;
      
      if ((! strcmp (data [count + a], "n_archiveno")) ||
	  (! strcmp (data [count + a], "n_archiveflag")));
      else
	{
	  if (comma)  strcat (cit_str, ", ");
	  comma = 1;
	  
	  if (! strcmp (data [count + a], "n_catalogno"))
	    *catoffset = y;
	  else if (! strcmp (data [count + a], "n_itemno"))
	    *itemoffset = y;
	  else if (! strcmp (data [count + a], "n_projectno"))
	    {
	      *projoffset = y;
	    }
	  
	  strcat (cit_str, data [count + a]);
	  
	  y = y + 1;
	}
    }
  
  status = MEMclose (&cit_attr);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "Failure : MEM Close : status = <0x%.8x>\n", status));
      return (NFM_E_MEM);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}

long NFMqry_proj_members (user_id, project_name, attr_list, data_list)
     long     user_id;
     char     *project_name;
     MEMptr   *attr_list, *data_list;
{
  char *fname="NFMqry_proj_members";
  long     status, prev_cat_no ;
  MEMptr   list = NULL ;
  char     sql_str [1024], **data, **column ;
  long     proj_no ;
  int      y, count, cat_off, item_off, item_rev_off, type_off,x ;
  char     cat_name [50], item_name [NFM_ITEMNAME +1] ;
  char     item_rev [NFM_ITEMREV+1], type [5] ;
  long     _NFMprojectcit_buffer (), atol ();
  
  _NFMdebug ((fname,"Project Name = <%s> ", project_name ));
  
  if (strlen (project_name))
    {
      status = NFMget_project_no (user_id, project_name, &proj_no); 
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "NFMget_project_no : status = <0x%.8x>\n",
		      status));
	  return (status);
	}
      _NFMdebug ((fname, "Project Number = <%d>", proj_no));
    }
  else
    {
      _NFMdebug ((fname, "Blank Project Name : status = <0x%.8x>\n",
		  NFM_E_BAD_PROJECT));
      return (NFM_E_BAD_PROJECT) ;
    }
  
  sprintf (sql_str, "SELECT n_mapno FROM nfmprojectaclmap \
WHERE n_projectno = %ld", proj_no ) ;
  
  status = SQLquery (sql_str, &list, 512);
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      
      if ((status ) == SQL_I_NO_ROWS_FOUND)
	{
	  ERRload_struct(NFM,NFM_E_NO_PROJECT_ACL_MAP,"",NULL);
	  _NFMdebug ((fname, "Project Not Mapped to ACL : status = <0x%.8x>\n", status));
	  return (NFM_E_NO_PROJECT_ACL_MAP);
	}
      
      ERRload_struct(NFM,NFM_E_SQL_QUERY,"",NULL);
      _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		  status));
      return (NFM_E_SQL_QUERY);
    }
  
  MEMclose(&list); list = NULL;
  
  sprintf (sql_str, "SELECT n_mapno FROM nfmprojectsamap \
WHERE n_projectno = %ld", proj_no ) ;
  
  status = SQLquery (sql_str, &list, 512);
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      
      if ((status ) == SQL_I_NO_ROWS_FOUND)
	{
	  ERRload_struct(NFM,NFM_E_NO_PROJECT_SA_MAP,"",NULL);
	  _NFMdebug ((fname, "Project Not Mapped to SA : status = <0x%.8x>\n", status));
	  return (NFM_E_NO_PROJECT_SA_MAP);
	}
      
      ERRload_struct(NFM,NFM_E_SQL_QUERY,"",NULL);
      _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		  status));
      return (NFM_E_SQL_QUERY);
    }
  
  MEMclose(&list); list = NULL;
  
  status = _NFMprojectcit_buffer (user_id, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      _NFMdebug ((fname, "Query Project Cit Attr : status = <0x%.8x>\n",
		  status));
      return (status); 
    }
  
  sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %d ORDER BY n_catalogno",
	   "n_catalogno, n_itemno, n_type",
	   "NFMPROJECTCIT", "n_projectno", proj_no);
  
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) &&
      ((status) != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&list);
      ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
      _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", 
		  status));
      _NFMdebug ((fname,"GET PROJ MEM : sql_str = <%s>\n", sql_str));
      return ( NFM_E_SQL_QUERY); 
    }
  
  if ((status) == SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname,"GET PROJ MEM : %s\n","NO ITEMS EXIST FOR GIVEN PROJECT"));
      ERRload_struct (NFM, NFM_E_NO_MEMBERS_IN_PROJECT, 
		      "%s", project_name) ;
      return (NFM_E_NO_MEMBERS_IN_PROJECT) ;  
    }
  
  status = MEMbuild_array (*data_list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "Failure : MEMbuild_array : status <0x%.8x>\n",
		  status)) ;
      MEMclose (&list) ;
      return (NFM_E_MEM) ;
    }
  
  column = (char **) (*data_list) -> column_ptr;
  
  cat_off =-1; item_off = -1; item_rev_off = -1; type_off = -1;
  for (y=0; y< (*data_list)->columns; y++)
    {
      if (strcmp (column [y], "n_catalogname") == 0) cat_off = y ;
      else if (strcmp (column [y], "n_itemname") ==0) item_off = y ;
      else if (strcmp (column [y], "n_itemrev") ==0)  item_rev_off = y;
      else if (strcmp (column [y], "n_type") == 0)    type_off = y ;
    }
  
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "Failure : MEM Build Array : status = <0x%.8x>\n",
		  status));
      return (NFM_E_MEM);
    }
  
  data   = (char **) list -> data_ptr;
  
  prev_cat_no = 0  ;
  
  for (y = 0; y < list -> rows; ++y)
    {
      count = list -> columns * y;
      cat_name [0] = 0 ;
      item_name [0] = 0 ;
      item_rev [0] = 0 ;
      type [0] = 0 ;
      
      if (prev_cat_no != atol (data [count]))
	{
	  status = NFMget_catalog_name (user_id,
					atol (data [count]), cat_name);
	  if (status != NFM_S_SUCCESS)
	    {
	      MEMclose (&list);
	      _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
			  status));
	      ERRload_struct (NFM, NFM_E_BAD_CATALOG, "", NULL) ;
	      return (status);
	    }
	  prev_cat_no = atol (data [count]) ;
	}
      
      status = NFMget_item_name (user_id, cat_name,
				 atol (data [count+1]),
				 item_name, item_rev);
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (&list);
	  _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
		      status));
	  ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL) ;
	  return (status);
	}
      
      strcpy (type, data [count+2]) ;
      
      sql_str [0] = 0;
      
      for (x =0; x <(*data_list)->columns ; x++)
	{
	  if (x==cat_off)
	    strcat (sql_str, cat_name);
	  else if (x==item_off)
	    strcat (sql_str, item_name) ;
	  else if (x==item_rev_off)
	    strcat (sql_str, item_rev) ;
	  else if (x==type_off)
	    strcat (sql_str, type) ;
	  strcat (sql_str, "\1") ;
	}
      
      _NFMdebug ((fname, "Cat Name = <%s> : Item Name = <%s> : Item Rev = <%s> : Type = <%s>\n",
		  cat_name, item_name, item_rev, type)) ;
      
      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&list);
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "Failure : MEM Write : status = <0x%.8x>\n",
		      status));
	  return (NFM_E_MEM);
	}
    }
  
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "Failure : MEM Close : status = <0x%.8x>\n",
		  status));
      return (NFM_E_MEM);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS); 
}


long _NFMprojectcit_buffer (user_id, attr_list, data_list)
     long user_id ;
     MEMptr *attr_list ;    /* Output */
     MEMptr *data_list ;    /* Output */
{
  static char *fname = "_NFMprojectcit_buffer" ;
  long status ;
  char sql_str [512] ;
  int  x,y, count, a,b ;
  char **data, **column ;
  
  _NFMdebug ((fname, "ENTER\n")) ;
  user_id = user_id ;
  status = NFMi_template (attr_list);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Template Failed :  status =  <0x%.8x> \n", status));
      return (status);
    }

  for (x = 0; x < 4; ++x)
    {
      sql_str [0] = 0;
      
      switch (x)
	{
	case 0 : 
	  sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
	  "n_catalogname", "char(20)", "Catalog Name", "n_catalogname",
	  "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 1 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
	  "n_itemname", "char(60)", "Item Name", "n_itemname",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 2 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_itemrev", "char(60)", "Item Rev", "n_itemrev",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 3 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_type", "char(2)", "Type (O,R)", "n_type",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

         }

      status = MEMwrite (*attr_list, sql_str);
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEM Write : status =  <0x%.8x> \n", 
		      status));
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	  return (NFM_E_MEM);
	}
    }
  
  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "Failure : MEM Build Array : status =  <0x%.8x> \n",
		  status));
      return (NFM_E_MEM);         
    }
  
  data   = (char **) (*attr_list) -> data_ptr;
  column = (char **) (*attr_list) -> column_ptr;
  
  a =-1; b= -1 ;
  for (y = 0; y < (*attr_list) -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))      a = y;
      else if (! strcmp (column [y], "n_datatype"))  b = y;
    }
  
  status = MEMopen (data_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : MEM Open : status =  <0x%.8x> \n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      return (NFM_E_MEM);         
    }
  
  for (x = 0; x < (*attr_list) -> rows; ++x)
    {
      count = (*attr_list) -> columns * x;
      
      status = MEMwrite_format (*data_list,
				data [count + a], data [count + b]);
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEM Wr Format : status =  <0x%.8x> \n",
		      status));
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	  return (NFM_E_MEM);
	}
      
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n"));
  return (NFM_S_SUCCESS) ;
}


