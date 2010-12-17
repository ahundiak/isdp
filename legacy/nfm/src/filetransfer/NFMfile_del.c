#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

 long NFMcl_delete_files_co (node_name, user_name, passwd, protocol, 
                             in_list, out_list)
   char     *node_name, *user_name, *passwd;
   long     protocol;
   MEMptr   in_list, *out_list;
   {
char *fname="NFMcl_delete_files_co ";
      long    status, status1, sock_no;
      char    dec_passwd [50];

      _NFMdebug((fname,"nodename <%s> username <%s> password <%s> protocol <%d>\n",
node_name,user_name,passwd,protocol));

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT;
         _NFMdebug ((fname,"Decrypt Passwd password : status = <0x%.8x>\n",
         status));
	ERRload_struct(NFM,status,"%s","Password");
         return (status);
       }

      status = NFMconnect (node_name, user_name,dec_passwd,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL Connect Failed : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMcl_send_buffer (&sock_no, NFM_DELETE_OUT_FILES, in_list);
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
         _NFMdebug ((fname,"CL Rec Failed : status = <0x%.8x>\n",
         status));
         return (status);
       }      
 
      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL Exit Failed : status = <0x%.8x>\n",
         status));
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Server Del Files Out: status1 = <0x%.8x>\n",
         status1));
	ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","Server Delete File Failed", status1);
         return (status1);
       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMser_delete_files_co (in_list, out_list)
   MEMptr    in_list;
   MEMptr    *out_list;
   {
char *fname="NFMser_delete_files_co ";
      long     status, status1, status2, status3, status4;
      long     x, y, count;
      long     i1, j1, k1, l1, m1, n1;
      long     o1, p1, q1, r1, s1, t1, u1;
      long     i2, m2, n2, o2, p2, q2, r2;
      char     **column, **data, **column2, **data2;
      char     src_file [512], file_name [512];
      MEMptr   sa_list = NULL;

      _NFMdebug ((fname,"Entry\n"));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM split copy buffer : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMsplit_copy_buffer");
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM reset buffer no : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMreset_buffer_no");
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM split copy buffer : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMsplit_copy_buffer");
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      column  = (char **) (*out_list) -> column_ptr;
      data    = (char **) (*out_list) -> data_ptr;

      column2 = (char **) sa_list -> column_ptr;
      data2   = (char **) sa_list -> data_ptr;

      i1 = -1; j1 = -1; k1 = -1; l1 = -1; m1 = -1;
      n1 = -1; o1 = -1; p1 = -1; q1 = -1; r1 = -1;
      s1 = -1; t1 = -1; u1 = -1;

      for (y = 0; y < (*out_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_sano"))         i1 = y;
         else if (! strcmp (column [y], "n_nodename"))     j1 = y;
         else if (! strcmp (column [y], "n_username"))     k1 = y;
         else if (! strcmp (column [y], "n_passwd"))       l1 = y;
         else if (! strcmp (column [y], "n_pathname"))     m1 = y;
         else if (! strcmp (column [y], "n_tcpip"))        n1 = y;
         else if (! strcmp (column [y], "n_xns"))          o1 = y;
         else if (! strcmp (column [y], "n_decnet"))       p1 = y;
         else if (! strcmp (column [y], "n_machid"))       q1 = y;
         else if (! strcmp (column [y], "n_opsys"))        r1 = y;
         else if (! strcmp (column [y], "n_cofilename"))   s1 = y;
         else if (! strcmp (column [y], "n_cifilesize"))   t1 = y;
         else if (! strcmp (column [y], "n_status"))       u1 = y;
       }

      if (i1 < 0 || j1 < 0 || k1 < 0 || l1 < 0 || m1 < 0 ||
          n1 < 0 || o1 < 0 || p1 < 0 || q1 < 0 || r1 < 0 ||
          s1 < 0 || t1 < 0 || u1 < 0)
       {
         MEMclose (&sa_list);
         status = NFM_E_CORRUPTED_BUFFERS;
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, status, "%s", "sa_list");
         return (status);
       }

      i2 = -1; m2 = -1; n2 = -1; o2 = -1; p2 = -1; q2 = -1; r2 = -1;

      for (y = 0; y < sa_list -> columns; ++y)
       {
              if (! strcmp (column2 [y], "n_sano"))         i2 = y;
         else if (! strcmp (column2 [y], "n_pathname"))     m2 = y;
         else if (! strcmp (column2 [y], "n_tcpip"))        n2 = y;
         else if (! strcmp (column2 [y], "n_xns"))          o2 = y;
         else if (! strcmp (column2 [y], "n_decnet"))       p2 = y;
         else if (! strcmp (column2 [y], "n_machid"))       q2 = y;
         else if (! strcmp (column2 [y], "n_opsys"))        r2 = y;
       }

      if (i2 < 0 || m2 < 0 || n2 <  0 || o2 < 0 || 
          p2 < 0 || q2 < 0 || r2 < 0)
       {
         MEMclose (&sa_list);
         status = NFM_E_CORRUPTED_BUFFERS;
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, status, "%s", "sa_list");
         return (status);
       }

      status1 = NFM_S_SUCCESS;    status2 = NFM_S_SUCCESS;
      status3 = NFM_S_SUCCESS;    status4 = NFM_S_SUCCESS;

      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if (((! strcmp (data [count + u1], "move"))    ||
              (! strcmp (data [count + u1], "delete"))) &&
              (atol (data [count + t1]) >= 0))
          {
            status = NFMappend_path_file (data2 [r2],
                     data2 [m2], data [count + s1], src_file);
            if (status != NFM_S_SUCCESS)
             {
               MEMclose (&sa_list);
               _NFMdebug ((fname,"Append Path : status = <0x%.8x>\n", status));
               if (status1 != NFM_S_SUCCESS) status1 = status;
             }

            status = NFMget_full_name (src_file, file_name);
            if (status != NFM_S_SUCCESS)
             {
               MEMclose (&sa_list);
               status = NFM_E_NET;
               _NFMdebug ((fname,"Get File Name : status = <0x%.8x>\n", status));
               if (status2 != NFM_S_SUCCESS) status2 = status;
             }

            status = unlink (file_name);
            if (status) /* OK */
             {
               MEMclose (&sa_list);
               status = NFM_E_UNLINK_FILE;
               _NFMdebug ((fname,"Unlink File filename <%s> Error No : status = <%d>\n",file_name, errno));
               ERRload_struct (NFM, status, "%s%d", file_name,errno);
               if (status3 != NFM_S_SUCCESS) status3 = status;
             }

            status = MEMwrite_data (*out_list, "-1", x + 1, t1 + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&sa_list);
               status = NFM_E_MEM_FAILURE;
               _NFMdebug ((fname,"MEM Wr Data : status = <0x%.8x>\n", status));
               ERRload_struct(NFM,status,"%s","MEMwrite_data");
               if (status4 != NFM_S_SUCCESS) status4 = status;
             }
          }
       }

      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM Close : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMclose");
         return (status);
       }      

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Append File Name : status = <0x%.8x>\n",
         status1));
         return (status1);
       }

      if (status2 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Append File Name : status = <0x%.8x>\n",
         status2));
         return (status2);
       }

      if (status3 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Wr Data : status = <0x%.8x>\n", status3));
         return (status3);
       }

      if (status4 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Wr Data : status = <0x%.8x>\n", status4));
         return (status4);
       }

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMcl_delete_files_ci (node_name, user_name, passwd, protocol, 
                             in_list, out_list)
   char     *node_name, *user_name, *passwd;
   long     protocol;
   MEMptr   in_list, *out_list;
   {
char *fname="NFMcl_delete_files_ci ";
      long    status, status1, sock_no;
      char    dec_passwd [50];

      _NFMdebug((fname,"nodename <%s> username <%s> password <%s> protocol <%d>\n",
node_name,user_name,passwd,protocol));

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT;
         _NFMdebug ((fname,"Decrypt Passwd : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","Password");
         return (status);
       }

      status = NFMconnect (node_name, user_name,dec_passwd,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL Connect Failed : status = <0x%.8x>\n", status));
         return (status);
       }

      status = NFMcl_send_buffer (&sock_no, NFM_DELETE_IN_FILES, in_list);
      if (status != NFM_S_SUCCESS)
       {
         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"CL Send Failed : status = <0x%.8x>\n", status));
         return (status);
       }      

      status1 = NFM_S_SUCCESS;

      status = NFMcl_receive_buffer (&sock_no, &status1, out_list);
      if (status != NFM_S_SUCCESS)
       {
         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"CL Rec Failed : status = <0x%.8x>\n", status));
         return (status);
       }      
 
      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL Exit Failed : status = <0x%.8x>\n", status));
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Server Del Files Out: status1 = <0x%.8x>\n", status1));
	ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","Server Delete Files Out Failed",status1);
         return (status1);
       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMser_delete_files_ci (in_list, out_list)
   MEMptr    in_list;
   MEMptr    *out_list;
   {
char *fname="NFMser_delete_files_ci ";
      long     status, status1, status2, status3;
      long     x, y, count;
      long     i1, j1, k1, l1, m1, n1;
      long     o1, p1, q1, r1, s1, t1, u1;
      long     i2, m2, n2, o2, p2, q2, r2;
      char     **column, **data, **column2, **data2;
      char     src_file [512];
      MEMptr   sa_list = NULL;

      _NFMdebug ((fname,"Entry \n"));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",status));
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM split copy buffer  : status = <0x%.8x>\n",status));
         ERRload_struct(NFM,status,"%s","MEMsplit_copy_buffer");
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM reset buffer no : status = <0x%.8x>\n",status));
         ERRload_struct(NFM,status,"%s","MEMreset_buffer_no");
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM split copy buffer  : status = <0x%.8x>\n",status));
         ERRload_struct(NFM,status,"%s","MEMsplit_copy_buffer");
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",status));
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",status));
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      column  = (char **) (*out_list) -> column_ptr;
      data    = (char **) (*out_list) -> data_ptr;

      column2 = (char **) sa_list -> column_ptr;
      data2   = (char **) sa_list -> data_ptr;

      i1 = -1; j1 = -1; k1 = -1; l1 = -1; m1 = -1;
      n1 = -1; o1 = -1; p1 = -1; q1 = -1; r1 = -1;
      s1 = -1; t1 = -1; u1 = -1;

      for (y = 0; y < (*out_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_sano"))         i1 = y;
         else if (! strcmp (column [y], "n_nodename"))     j1 = y;
         else if (! strcmp (column [y], "n_username"))     k1 = y;
         else if (! strcmp (column [y], "n_passwd"))       l1 = y;
         else if (! strcmp (column [y], "n_pathname"))     m1 = y;
         else if (! strcmp (column [y], "n_tcpip"))        n1 = y;
         else if (! strcmp (column [y], "n_xns"))          o1 = y;
         else if (! strcmp (column [y], "n_decnet"))       p1 = y;
         else if (! strcmp (column [y], "n_machid"))       q1 = y;
         else if (! strcmp (column [y], "n_opsys"))        r1 = y;
         else if (! strcmp (column [y], "n_cifilename"))   s1 = y;
         else if (! strcmp (column [y], "n_cifilesize"))   t1 = y;
         else if (! strcmp (column [y], "n_status"))       u1 = y;
       }

      if (i1 < 0 || j1 < 0 || k1 < 0 || l1 < 0 || m1 < 0 ||
          n1 < 0 || o1 < 0 || p1 < 0 || q1 < 0 || r1 < 0 ||
          s1 < 0 || t1 < 0 || u1 < 0)
       {
         MEMclose (&sa_list);
         status = NFM_E_CORRUPTED_BUFFERS;
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, status, "%s", "sa_list");
         return (status);
       }

      i2 = -1; m2 = -1; n2 = -1; o2 = -1; p2 = -1; q2 = -1; r2 = -1;

      for (y = 0; y < sa_list -> columns; ++y)
       {
              if (! strcmp (column2 [y], "n_sano"))         i2 = y;
         else if (! strcmp (column2 [y], "n_pathname"))     m2 = y;
         else if (! strcmp (column2 [y], "n_tcpip"))        n2 = y;
         else if (! strcmp (column2 [y], "n_xns"))          o2 = y;
         else if (! strcmp (column2 [y], "n_decnet"))       p2 = y;
         else if (! strcmp (column2 [y], "n_machid"))       q2 = y;
         else if (! strcmp (column2 [y], "n_opsys"))        r2 = y;
       }

      if (i2 < 0 || m2 < 0 || n2 <  0 || o2 < 0 || 
          p2 < 0 || q2 < 0 || r2 < 0)
       {
         MEMclose (&sa_list);
         status = NFM_E_CORRUPTED_BUFFERS;
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, status, "%s", "sa_list");
         return (status);
       }

      status1 = NFM_S_SUCCESS;
      status2 = NFM_S_SUCCESS;
      status3 = NFM_S_SUCCESS;

      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if (! strcmp (data [count + i1], data2 [i2]))
          {
            if (((! strcmp (data [count + u1], "move"))    ||
                 (! strcmp (data [count + u1], "copy"))    ||
                 (! strcmp (data [count + u1], "delete"))) &&
                (atol (data [count + t1]) >= 0))
             {
               status = NFMappend_path_file (data2 [r2],
                        data2 [m2], data [count + s1], src_file);
               if (status != NFM_S_SUCCESS)
                {
/*                  MEMclose (&sa_list); */
                  _NFMdebug ((fname,"Append Path : status = <0x%.8x>\n", status));
                  if (status1 == NFM_S_SUCCESS) status1 = status;
                }

               status = unlink (src_file);
               if (status) /* OK */
                {
/*                  MEMclose (&sa_list); */
                  status = NFM_E_UNLINK_FILE;
                  _NFMdebug ((fname,"Error No : status = <%d> status = <0x%.8x>\n", errno,status));
                  ERRload_struct (NFM, status, "%s", src_file);
                  if (status2 == NFM_S_SUCCESS) status2 = status;
                }
 
               status = MEMwrite_data (*out_list, "-1", x + 1, t1 + 1);
               if (status != MEM_S_SUCCESS)
                {
/*                  MEMclose (&sa_list); */
                  status = NFM_E_MEM_FAILURE;
                  _NFMdebug ((fname,"MEM Wr Data : status = <0x%.8x>\n", status));
                 ERRload_struct(NFM,status,"%s","MEMwrite_data");
		 if (status3 == NFM_S_SUCCESS) status3 = status;
                }
             }
          }
       }

      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
         status = NFM_E_MEM_FAILURE;
         _NFMdebug ((fname,"MEM Close : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMclose");
         return (status);
       }      

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Append File Name : status1 = <0x%.8x>\n", status1));
         return (status1);
       }

      if (status2 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Append File Name : status2 = <0x%.8x>\n", status2));
         return (status2);
       }

      if (status3 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Wr Data : status3 = <0x%.8x>\n", status3));
         return (status3);
       }

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }
