#include "machine.h"
#include "NFMA.h"

 long NFMdelete_user (user_id, user_name)
   long    user_id;
   char    *user_name;
   {
      static char *fname = "NFMdelete_user" ;
      long      status, atol ();
      char      sql_str [1024];
      long      user_no;
      long      NFMcheck_user_in_acls ();
      long      NFMcheck_user_in_signoff ();
      long      NFMcheck_user_in_project ();

      _NFMdebug ((fname, "User Name = <%s>\n", user_name));

      if (! strcmp (user_name, "PUBLIC"))
      {
        _NFMdebug ((fname, "Deleting the user <PUBLIC> is not allowed\n"));
        ERRload_struct (NFM, NFM_E_DU_PUBLIC, "", NULL);
        return (NFM_E_DU_PUBLIC);
      }

      status = NFMget_user_no (user_id, user_name, &user_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get User No : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMcheck_user_in_acls (user_id, user_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Chk User In Acl : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMcheck_user_in_signoff (user_id, user_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Chk User In Sign Off : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMcheck_user_in_project (user_id, user_name);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Chk User In Proj : status = <0x%.8x>\n",
         status));
         return (status);
       }

      sprintf (sql_str, "DELETE FROM NFMUSERS WHERE n_userno = %d",
	       user_no);

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         NFMrollback_transaction (0);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		     status));
         return (NFM_E_SQL_STMT);
       }

      status = NFMreturn_serial_slot (user_id, "nfmusers",
                "n_userno", user_no);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "Return Serial Slot : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
         status));
         return (status);
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMcheck_user_in_acls (user_id, user_no)
   long    user_id;
   long    user_no;
   {
      static char *fname = "NFMcheck_user_in_acls" ;
      long     status, atol ();
      char     sql_str [1024], value [50];

      _NFMdebug ((fname, "User No = <%d>\n", user_no));

      sprintf (sql_str, "WHERE n_userno = %d", user_no);

      status = NFMget_attr_value (user_id, "NFMACLUSERS", "n_userno",
               sql_str, value);
      if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
       {
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
         status));
         return (status);
       }

      if (atol (value) > 0)
       {
         ERRload_struct (NFM, NFM_E_ACL_USER, "", NULL);
         _NFMdebug ((fname, "Still Acl User : status = <0x%.8x>\n",
         NFM_E_ACL_USER));
         return (NFM_E_ACL_USER);
       }

      _NFMdebug ((fname, "SUCCESSFUl : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMcheck_user_in_signoff (user_id, user_no)
   long    user_id;
   long    user_no;
   {
     static char *fname = "NFMcheck_user_in_signoff" ;
      long     status, atol ();
      char     sql_str [1024], value [50];

      _NFMdebug ((fname, "User No = <%d>\n", user_no));

     sprintf (sql_str, "WHERE n_userno = %d", user_no);

      status = NFMget_attr_value (user_id, "NFMSIGNOFFUSERS", "n_userno",
               sql_str, value);
      if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
       {
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
         status));
         return (status);
       }

      if (atol (value) > 0)
       {
         ERRload_struct (NFM, NFM_E_SIGNOFF_USER, "", NULL);
         _NFMdebug ((fname, "Still Sign User : status = <0x%.8x>\n",
         NFM_E_SIGNOFF_USER));
         return (NFM_E_SIGNOFF_USER);
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMcheck_user_in_project (user_id, user_name)
   long    user_id;
   char    *user_name;
   {
     static char *fname = "NFMcheck_user_in_project" ;
      long     status, atol ();
      char     sql_str [1024], value [50];

      _NFMdebug ((fname, "User Name = <%s>\n", user_name));

     sprintf (sql_str, "WHERE n_projectmgr = '%s'", user_name);

      status = NFMget_attr_value (user_id, "NFMPROJECTS", "n_projectmgr",
               sql_str, value);
      if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
       {
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
         status));
         return (status);
       }

      if (atol (value) > 0)
       {
         ERRload_struct (NFM, NFM_E_PROJECT_MGR, "", NULL);
         _NFMdebug ((fname, "User Is Project Mgr : status = <0x%.8x>\n",
         NFM_E_PROJECT_MGR));
         return (NFM_E_PROJECT_MGR);
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }
