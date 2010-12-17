#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMlisten.h"
#include "NFMerrordef.h"
#include "NFMmach_id.h"
#include "ERR.h"
#include "DEBUG.h"

/* 12/8/92 - KT - remove '#ifdef __unix__'
#ifdef __unix__
#endif
*/

#include <pwd.h>

/* 12/8/92 - KT - remove '#ifdef __unix__'
#ifdef __unix__
#endif
*/
      struct passwd *pwd;

#define BUFFER_SIZE 1000
/****** called by NFMSlayer *******/
 long NFMcl_get_bulk_data (node_name, user_name, passwd, protocol, 
                           in_list, out_list)
   char     *node_name, *user_name, *passwd;
   long     protocol;
   MEMptr   in_list, *out_list;

   {
char *fname="NFMcl_get_bulk_data ";
      long    status, status1, sock_no;
      char    dec_passwd [50];

      _NFMdebug((fname,"Enter> Nodename <%s> username <%s>\n Password <%s> protocol <%d>\n",
node_name,user_name,passwd,protocol));


      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
	 status=NFM_E_NET_DECRYPT;
	 ERRload_struct(NFM,status,"%s","Password");
         _NFMdebug ((fname,"Decrypt Passwd  failed Password <%s>: status = <0x%.8x>\n",
                   passwd,status));
         return (status);
       }

      _NFMdebug ((fname,"Decrypt Passwd : NOT PRINTED\n"));

      status = NFMconnect (node_name, user_name,dec_passwd,
                           NFM_TCP_PORT, NFM_XNS_PORT, &sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL Connect Failed : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMcl_send_buffer (&sock_no, NFM_BULK_LOAD, in_list);
      if (status != NFM_S_SUCCESS)
       {
         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"CL Send Failed : status = <0x%.8x>\n",
                   status));
         return (status);
       }      

      status1 = NFM_S_SUCCESS;

      status = NFMcl_receive_buffer (&sock_no, &status1, out_list);
      if (status != NFM_S_SUCCESS)
       {
         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"Rec Failed : status = <0x%.8x>\n",status));
         return (status);
       }      
/*** outlist will have information ******/
 
      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname," CL Exit Failed : status = <0x%.8x>\n",
                   status));
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Server Get Bulk Data : status1 = <0x%.8x>\n",
         status1));
         return (status1);
       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

/******* this is called by file server *******/
/******* outlist will have 2 buffers *********/
/****** appended one has the size    ********/
/****** second has the information **********/

 long NFMser_get_bulk_data (in_list, out_list)
   MEMptr    in_list;
   MEMptr    *out_list;
   {
char *fname="NFMser_get_bulk_data ";
      int      i, j;
      long     status, max_dir_size = 0;
      char     **column_ptr, **data_ptr;
      char     size_str [50], tmp_str [512] ;
      char     str[256];
      char     mode[2], path[81], username[20], opsys[11];
      MEMptr   temp_list = NULL ;

      _NFMdebug ((fname,"ENtry>\n", ""));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
	status=NFM_E_MEM_FAILURE;
	ERRload_struct(NFM,status,"%s","MEMbuild_array");
         _NFMdebug ((fname," MEM Build Array failed : status = <0x%.8x>\n",
                   status));
         return (status);
       }

      column_ptr  = (char **) (in_list) -> column_ptr;
      data_ptr    = (char **) (in_list) -> data_ptr;

    for (i=0; i<in_list->columns; ++i)
        {
             if (strcmp (column_ptr[i], "n_mode") == 0)
                 strcpy (mode, data_ptr[i]);

        else if (strcmp (column_ptr[i], "n_pathname") == 0)
                 strcpy (path, data_ptr[i]);

        else if (strcmp (column_ptr[i], "n_username") == 0)
                 strcpy (username, data_ptr[i]);

        else if (strcmp (column_ptr[i], "n_opsys") == 0)
                 strcpy (opsys, data_ptr[i]);

        }

    _NFMdebug((fname,"mode <%s> path <%s> <username <%s>\nopsys <%s> path <%s>\n",
mode,path,username,opsys,path));

    /* path is blank, get user's default directory */
    if (strcmp (path, "") == 0)
        {
        if ((pwd = (struct passwd *) getpwnam (username)) == NULL)
            {
            _NFMdebug ((fname,"getpwname: Failed for username <%s> error: <0x%.8x>\n",
                      username,NFM_E_FAILURE));
            ERRload_struct (NFM, NFM_E_FAILURE, "%s%s", "getpwnam failed",
                            username); 
            return (NFM_E_FAILURE);
            }
        strcpy (path, pwd->pw_dir);
        _NFMdebug ((fname,"path  : <%s>\n", path));
        }

    /* call different functions per operating system */

   /* Comparison of opertating system with UNIX added for SUNOS port.
      Check if any other operating system name needs to be included.
      SSRS - 30/11/93
   */
        if (strncmp (opsys,  "CLIX",  4) == 0 || strncmp(opsys, "UNIX",  4) == 0)
           {
             status = NFMclix_bulk_dir (path, out_list, mode, &max_dir_size);
             if (status != NFM_S_SUCCESS)
                 { 
                 _NFMdebug ((fname,"NFMclix_bulk_dir Failed: status:<0x%.8x>\n",
                           status));
                 return (status);
                 }
             }

    else if (strncmp (opsys, "VMS", 3) == 0)
             {
             status = NFMvms_bulk_dir (path, out_list, mode, &max_dir_size);
             if (status != NFM_S_SUCCESS)
                 {
                 _NFMdebug ((fname,"NFMvms_bulk_dir Failed: status = <0x%8x>\n",
                           status));
                 return (status);
                 }
             }

      /* Second argument is missing for MEMopen(). Passing 'max_dir_size'
         obtained from NFMclix_bulk_dir/NFMvms_bulk_dir as the second argument.
         Check if this is OK.
         SSRS - 30/11/93
      */
      /*status = MEMopen (&temp_list) ;*/
      status = MEMopen (&temp_list,  max_dir_size) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&temp_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	/* MEMappend changed to MEMopen in debug statement.
	             SSRS - 30/11/93
        */
	  _NFMdebug ((fname, "MEMopen failed : status = <0x%.8x>\n",
		      status)) ;
	  return (NFM_E_MEM) ;
	}

      status = MEMwrite_format (temp_list, "max_directory_size", "integer") ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&temp_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	/* MEMappend changed to MEMwrite_format in debug statement.
           SSRS - 30/11/93
          */
	  _NFMdebug ((fname, "MEMwrite_format  failed : status = <0x%.8x>\n",
		      status)) ;
	  return (NFM_E_MEM) ;
	}

      _NFMSdebug ((fname,  "max directory size is %d\n", 
	max_dir_size)) ;
	
      sprintf (tmp_str, "%d\001", max_dir_size) ;

      status = MEMwrite (temp_list, tmp_str);
      if (status != MEM_S_SUCCESS)
      {
         _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
         return (status);
      }

      status = MEMappend (temp_list, *out_list) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&temp_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMappend failed : status = <0x%.8x>\n",
		      status)) ;
	  return (NFM_E_MEM) ;
	}

      status = MEMclose (&temp_list) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&temp_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMappend failed : status = <0x%.8x>\n",
		      status)) ;
	  return (NFM_E_MEM) ;
	}

      _NFMdebug ((fname,"SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }


