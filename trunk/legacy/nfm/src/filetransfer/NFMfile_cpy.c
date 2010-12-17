#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

 long NFMcl_copy_file (node_name, user_name, passwd, protocol, 
                    in_list, out_list)
   char     *node_name, *user_name, *passwd;
   long     protocol;
   MEMptr   in_list, *out_list;
   {
char *fname="NFMcl_copy_file ";
      long    status, status1, sock_no;
      char    dec_passwd [50];

      _NFMdebug((fname,"nodename <%s> username <%s> password <%s> protocol <%d>\n",
node_name,user_name,passwd,protocol));

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Decrypt Passwd : status = <0x%.8x>\n",status));
	status=NFM_E_NET_DECRYPT;
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

      status = NFMcl_send_buffer (&sock_no, NFM_COPY_FILE, in_list);
      if (status != NFM_S_SUCCESS)
       {
         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"CL Send Failed : status = <0x%.8x>\n",status));
         return (status);
       }      

      status1 = NFM_S_SUCCESS;

      status = NFMcl_receive_buffer (&sock_no, &status1, out_list);
      if (status != NFM_S_SUCCESS)
       {
         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"CL Rec Failed : status = <0x%.8x>\n",status));
         return (status);
       }      
 
      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL Exit Failed : status = <0x%.8x>\n",status));
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Server Copy File Failed: status1 = <0x%.8x>\n",
         status1));
	 ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","Server Copy File Failed",status1);
         return (status1);
       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMser_copy_file (in_list, out_list)
   MEMptr    in_list;
   MEMptr    *out_list;
   {
char *fname="NFMser_copy_file ";
      long     status;
      long     x, y, count;
      long     i1, j1, k1, l1, m1, n1, o1;
      long     p1, q1, r1, s1, t1, u1, v1, w1;
      long     i2, m2, n2, o2, p2, q2, r2;
      char     **column, **data, **column2, **data2;
      char     size_str [50];
      char     src_file [512], dst_file [512];
      long     size;
      MEMptr   sa_list = NULL;

      _NFMdebug ((fname,"Entry\n", ""));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
	status=NFM_E_MEM_FAILURE;
	ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname," MEM Copy : status = <0x%.8x>\n", status));
	status=NFM_E_MEM_FAILURE;
	ERRload_struct(NFM,status,"%s","MEMsplit_copy_buffer");
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"MEM Resetbuffer No : status = <0x%.8x>\n", status));
	status=NFM_E_MEM_FAILURE;
	ERRload_struct(NFM,status,"%s","MEMreset_buffer_no");
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname," MEM Copy : status = <0x%.8x>\n", status));
	status=NFM_E_MEM_FAILURE;
	ERRload_struct(NFM,status,"%s","MEMsplit_copy_buffer");
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
	status=NFM_E_MEM_FAILURE;
	ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
	status=NFM_E_MEM_FAILURE;
	ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      column  = (char **) (*out_list) -> column_ptr;
      data    = (char **) (*out_list) -> data_ptr;

      column2 = (char **) sa_list -> column_ptr;
      data2   = (char **) sa_list -> data_ptr;

      i1 = -1; j1 = -1; k1 = -1; l1 = -1; m1 = -1;
      n1 = -1; o1 = -1; p1 = -1; q1 = -1; r1 = -1;
      s1 = -1; t1 = -1; u1 = -1; v1 = -1; w1 = -1;

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
         else if (! strcmp (column [y], "n_cofilename"))   t1 = y;
         else if (! strcmp (column [y], "n_cifilesize"))   u1 = y;
         else if (! strcmp (column [y], "n_filetype"))     v1 = y;
         else if (! strcmp (column [y], "n_status"))       w1 = y;
       }

      if (i1 < 0 || j1 < 0 || k1 < 0 || l1 < 0 || m1 < 0 ||
          n1 < 0 || o1 < 0 || p1 < 0 || q1 < 0 || r1 < 0 ||
          s1 < 0 || t1 < 0 || u1 < 0 || v1 < 0 || w1 < 0)
       {
         MEMclose (&sa_list);
	status=NFM_E_CORRUPTED_BUFFERS;
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
	status=NFM_E_CORRUPTED_BUFFERS;
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, status, "%s", "sa_list");
         return (status);
       }

      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if (! strcmp (data2 [i2], data [count + i1]))
          {
            if ((! strcmp (data [count + w1], "copy")) ||
                (! strcmp (data [count + u1], "-1")))
             {
               status = NFMappend_path_file (data2 [r2],
                        data2 [m2], data [count + s1], src_file);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                            status));
                  return (status);
                }

               status = NFMappend_path_file (data2 [r2],
                        data2 [m2], data [count + t1], dst_file);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  _NFMdebug ((fname,"Append Path : status = <0x%.8x>\n",
                            status));
                  return (status);
                }

               status = NFMcopy_file (src_file, dst_file,
                        data [count + v1], &size, 0);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  _NFMdebug ((fname," NFM Copy File : status = <0x%.8x>\n",
                  status));
                  return (status);
                }

               if (size < 0)
                {
                  MEMclose (&sa_list);
                  status = NFM_E_INVALID_FILE_SIZE;
                  _NFMdebug ((fname," Bad File size : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (NFM, status, "%d", size);
                  return (status);
                }

               sprintf (size_str, "%d", size);

               status = MEMwrite_data (*out_list, size_str, x + 1, u1 + 1);
               if (status != MEM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  status = NFM_E_MEM_FAILURE;
                  _NFMdebug ((fname,"MEM Wr Data : status = <0x%.8x>\n",
                            status));
		  ERRload_struct(NFM,status,"%s","MEMwrite_data");
                  return (status);
                }
             }
          }
       }

      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
	status=NFM_E_MEM_FAILURE;
         ERRload_struct (NFM, status, "%s", "MEMclose");
         _NFMdebug ((fname,"MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      

      _NFMdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }
