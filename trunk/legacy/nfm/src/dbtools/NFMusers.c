#include "machine.h"
#include "DBTOOLS.h"

 extern struct NFMglobal_st NFMglobal ;

 long NFMget_user_no (user_id, user_name, user_no)
   long    user_id;
   char    *user_name;
   long    *user_no;
   {
     static char *fname = "NFMget_user_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *user_no = 0;

     _NFMdebug ((fname, "User Name = <%s>\n",  user_name)) ;

     sprintf (sql_str, "WHERE %s = '%s'", "n_username", user_name);

     status = NFMget_attr_value (user_id, "NFMUSERS", "n_userno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_USER, "", NULL);
           _NFMdebug ((fname, "No Such User : status = <0x%.8x>\n", NFM_E_BAD_USER));
           return (NFM_E_BAD_USER);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *user_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : User No = <%d>\n", *user_no)) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_user_name (user_id, user_no, user_name)
   long    user_id;
   long    user_no;
   char    *user_name;
   {
  static char *fname = "NFMget_user_name" ;
     long    status;
     char    sql_str [1024];

     user_name [0] = 0;

     _NFMdebug ((fname, "User No   = <%d>  ", user_no  ));

     sprintf (sql_str, "WHERE %s = %d", "n_userno", user_no);

     status = NFMget_attr_value (user_id, "NFMUSERS", "n_username",
              sql_str, user_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_USER, "", NULL);
           _NFMdebug ((fname, "No Such User : status = <0x%.8x>\n", NFM_E_BAD_USER));
           return (NFM_E_BAD_USER);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : User Name = <%s>\n", user_name));
     return (NFM_S_SUCCESS);
   }


long NFMget_current_user_name (user_id, user_name)
     long    user_id;
     char    *user_name;
{
  static char *fname = "NFMget_current_user_name" ;

  user_id = user_id ;
  strcpy (user_name, NFMglobal.NFMusername) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}
