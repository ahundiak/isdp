#include "machine.h"
#include "DBTOOLS.h"
#include "WFstruct.h"

  extern struct WFstruct WFinfo ;

 long NFMget_project_no (user_id, project_name, project_no)
   long    user_id;
   char    *project_name;
   long    *project_no;
   {
     static char *fname = "NFMget_project_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *project_no = 0;

     _NFMdebug ((fname, "Project Name = <%s>  ", project_name));

     sprintf (sql_str, "WHERE %s = '%s'", "n_projectname", project_name);

     status = NFMget_attr_value (user_id, "NFMPROJECTS", "n_projectno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           /* status = NFMerror (NFM_E_BAD_PROJECT); */
           status = ERRload_struct (NFM, NFM_E_BAD_PROJECT, "", NULL);
           _NFMdebug ((fname, "No Such Project : status = <0x%.8x>\n", NFM_E_BAD_PROJECT));
           return (NFM_E_BAD_PROJECT);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *project_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : Project No = <%d>\n", *project_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_project_name (user_id, project_no, project_name)
   long    user_id;
   long    project_no;
   char    *project_name;
   {
     static char *fname = "NFMget_project_name" ;
     long    status;
     char    sql_str [1024];

     project_name [0] = 0;

     _NFMdebug ((fname, "Project No   = <%d>\n ", project_no  ));

     sprintf (sql_str, "WHERE %s = %d", "n_projectno", project_no);

     status = NFMget_attr_value (user_id, "NFMPROJECTS", "n_projectname",
              sql_str, project_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           /* status = NFMerror (NFM_E_BAD_PROJECT); */
           status = ERRload_struct (NFM, NFM_E_BAD_PROJECT, "", NULL);
           _NFMdebug ((fname, "No Such Project : status = <0x%.8x>\n",
           NFM_E_BAD_PROJECT));
           return (NFM_E_BAD_PROJECT);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Project Name = <%s>\n", project_name));
     return (NFM_S_SUCCESS);
   }
 long NFMcheck_projectcit_empty (user_id, proj_no)
   long    user_id;
   long    proj_no;
   {
     static char *fname = "NFMcheck_projectcit_empty" ;
     long   status;
     long   m_status;
     char   sql_str     [256];
     MEMptr sql_buffer = NULL; 

     _NFMdebug ((fname, "Proj No   = <%d>\n", proj_no));

     sprintf (sql_str, "SELECT * FROM NFMPROJECTCIT WHERE %s = %d",
	      "n_projectno", proj_no);

     status = SQLquery (sql_str, &sql_buffer, 1024);

     m_status = MEMclose (&sql_buffer);
     if (m_status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", m_status));
        return (NFM_E_MEM);
      }

     if (status != SQL_S_SUCCESS) 
     {
        if ((status ) == SQL_I_NO_ROWS_FOUND)
        {
           _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
                     NFM_S_SUCCESS));
           return (NFM_S_SUCCESS);
        }
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query : status = <0x%.8x>\n",  status));
     }

     ERRload_struct (NFM, NFM_E_PROJECT_MEM_EXISTS, "", NULL);
     _NFMdebug ((fname, "Projectcit Not Empty : status = <0x%.8x>\n",
              NFM_E_PROJECT_MEM_EXISTS ));
     status = NFM_E_PROJECT_MEM_EXISTS;
     return (status);
   }


 long NFMcheck_project_aclmap_empty (user_id, proj_no)
   long    user_id;
   long    proj_no;
   {
     static char *fname = "NFMcheck_project_aclmap_empty" ;
     long   status;
     long   m_status;
     char   sql_str     [256];
     MEMptr sql_buffer = NULL; 

     _NFMdebug ((fname, "Proj No   = <%d>\n", proj_no));

     sprintf (sql_str, "SELECT * FROM NFMPROJECTACLMAP WHERE %s = %d",
	      "n_projectno", proj_no);

     status = SQLquery (sql_str, &sql_buffer, 1024);

     m_status = MEMclose (&sql_buffer);
     if (m_status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", m_status));
        return (NFM_E_MEM);
      }

     if (status != SQL_S_SUCCESS) 
     {
        if ((status) == SQL_I_NO_ROWS_FOUND)
        {
           _NFMdebug ((fname, "SUCCESSFUL\n")) ;
           return (NFM_S_SUCCESS);
        }
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query : status = <0x%.8x>\n",  status));
     }

        ERRload_struct (NFM, NFM_E_PROJ_ACL_MAP_EXISTS, "", NULL);
     _NFMdebug ((fname, "Projectaclmap Not Empty : status = <0x%.8x>\n",
               NFM_E_PROJ_ACL_MAP_EXISTS));
     status = NFM_E_PROJ_ACL_MAP_EXISTS;
     return (status);
   }


 long NFMcheck_project_samap_empty (user_id, proj_no)
   long    user_id;
   long    proj_no;
   {
     static char *fname = "NFMcheck_project_samap_empty" ;
     long   status;
     long   m_status;
     char   sql_str     [256];
     MEMptr sql_buffer = NULL; 

     _NFMdebug ((fname, "Proj No   = <%d>\n", proj_no));

     sprintf (sql_str, "SELECT * FROM NFMPROJECTSAMAP WHERE %s = %d",
	      "n_projectno", proj_no);

     status = SQLquery (sql_str, &sql_buffer, 1024);

     m_status = MEMclose (&sql_buffer);
     if (m_status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", m_status));
        return (NFM_E_MEM);
      }

     if (status != SQL_S_SUCCESS) 
     {
        if ((status) == SQL_I_NO_ROWS_FOUND)
        {
           _NFMdebug ((fname, "SUCCESSFUL\n")) ;
           return (NFM_S_SUCCESS);
        }
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query : status = <0x%.8x>\n",  status));
     }

        ERRload_struct (NFM, NFM_E_PROJ_SA_MAP_EXISTS, "", NULL);
     _NFMdebug ((fname, "Projectaclmap Not Empty : status = <0x%.8x>\n",
               NFM_E_PROJ_SA_MAP_EXISTS));
     status = NFM_E_PROJ_SA_MAP_EXISTS;
     return (status);
   }


 long NFMdelete_lop_entry (user_id, proj_no)
   long    user_id;
   long    proj_no;
   {
     static char *fname = "NFMdelete_lop_entry" ;
     long      status;
     char      sql_str [256];

     _NFMdebug ((fname, "Proj No = <%d>\n", proj_no ));

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d", 
	      "NFMPROJECTS", "n_projectno", proj_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (NFM_E_SQL_STMT);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }



 /************************************************************************
  *                                                                      *
  *   Function: NFMinternal_add_project_member.                          *
  *   Date:     March 11, 1990                                           *
  *                                                                      *
  *   This function assumes that users cannot modify the NFMPROJECTCIT   *
  *   table.                                                             *  
  *                                                                      *
  ************************************************************************/

 long NFMinternal_add_project_member (user_id, proj_no, cat_no, item_no) 
   long       user_id;
   long       proj_no;
   long       cat_no;
   long       item_no;
   {
      static char *fname = "NFMinternal_add_project_member" ;
      long      status;
      long      cit_no;
      char      sql_str [1024];

      _NFMdebug ((fname, "Project No  = <%d> : Cat No = <%d> : Item No = <%d>\n", 
		  proj_no, cat_no, item_no));
      cit_no = 0;

      status = NFMget_serial_slot (user_id, "nfmprojectcit",
                                   "n_citno", &cit_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
         status));
         return (status);          
       }

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      sprintf (sql_str,  
      "INSERT INTO %s (%s %s) VALUES (%d, %d, %d, %d, '%s', %d, '%s')",
      "NFMPROJECTCIT", "n_citno, n_projectno, n_catalogno, n_itemno, ",
      "n_type, n_archiveno, n_archiveflag", cit_no, proj_no, cat_no,
      item_no, "O", 0, "");

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		     status));
         return (NFM_E_SQL_STMT); 
       }

      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
    }

#define PROJECT_CREATION_STATE_NAME "PROJECT CREATED"
#define PROJECT_MAPPING_STATE_NAME  "PROJECT MAPPED"  

long _NFMcheck_project_state (proj_no)
     long proj_no ;
{
  char *fname = "_NFMcheck_project_state" ;
  long  status, project_state_changed = 0, atol() ;
  MEMptr sql_buffer = NULL ;
  char   **data, sql_str [1024] ;
  
  _NFMdebug ((fname, "ENTER : Project no <%d>\n", proj_no)) ;
  status = _NFMcheck_project_complete_mapping (proj_no) ;
  if ((status != NFM_S_SUCCESS) && (status != NFM_E_PROJ_NOT_MAPPED))
    {
      _NFMdebug ((fname, "failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  project_state_changed = 0 ;

  if (status == NFM_E_PROJ_NOT_MAPPED)
    {
      if (strcmp (WFinfo.current_statename, PROJECT_MAPPING_STATE_NAME) == 0)
	{
	  project_state_changed = 1 ;
	  strcpy (WFinfo.next_statename, PROJECT_CREATION_STATE_NAME) ;
	}
    }
  else
    {
      if (strcmp (WFinfo.current_statename, PROJECT_CREATION_STATE_NAME) == 0)
	{
	  project_state_changed = 1 ;
	  strcpy (WFinfo.next_statename, PROJECT_MAPPING_STATE_NAME) ;
	}
    }

  if (project_state_changed)
    {
      sprintf (sql_str, "SELECT n_stateno FROM NFMSTATES where n_statename = '%s'",
	       WFinfo.next_statename) ;

      status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
      if (status != SQL_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  if (status == SQL_I_NO_ROWS_FOUND)
	    {
	      _NFMdebug ((fname, "bad state %s\n", WFinfo.next_statename)) ;
	      ERRload_struct (NFM, NFM_E_BAD_STATE, "", "") ;
	      return (NFM_E_BAD_STATE) ;
	    }

	  ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	  _NFMdebug ((fname, "SQL Query : status = <0x%.8x>\n",  status));
	  return (NFM_E_SQL_QUERY) ;
	}
      
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}

      data = (char **) sql_buffer -> data_ptr ;

      WFinfo.next_state = atol (data [0]) ;

      status = MEMclose (&sql_buffer);
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
	  return (NFM_E_MEM);
	}
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMcheck_project_complete_mapping (proj_no) 
     long proj_no ;
{
  char *fname = "_NFMcheck_project_complete_mapping" ;
  long status ;
  char sql_str [1024] ;
  MEMptr sql_buffer = NULL ;

  _NFMdebug ((fname, "Project No <%d>\n", proj_no)) ;

  sprintf (sql_str, "SELECT a.n_projectno FROM NFMPROJECTSAMAP a, NFMPROJECTACLMAP b WHERE a.n_projectno = b.n_projectno and a.n_projectno = %d",
	   proj_no);

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
      _NFMdebug ((fname, "SQL Query : status = <0x%.8x>\n",  status));
      return (NFM_E_SQL_QUERY) ;
    }

  if (status == SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&sql_buffer) ;
/*  this is information information do no load ERR struct */
      _NFMdebug ((fname, "Project is not mapped\n")) ;
      return (NFM_E_PROJ_NOT_MAPPED) ;
    }

  status = MEMclose (&sql_buffer);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
      return (NFM_E_MEM);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
