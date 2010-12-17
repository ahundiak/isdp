#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

 long NFMcl_get_files_out (node_name, user_name, passwd,
                           protocol, in_list, out_list)
   char     *node_name, *user_name, *passwd;
   long     protocol;
   MEMptr   in_list, *out_list;
   {
char *fname="NFMcl_get_files_out ";
      long    status, status1, sock_no;
      char    dec_passwd [50];

      _NFMdebug((fname,"Nodename <%s> username <%s> passwd <%s> protocol <%d>\n",
node_name,user_name,passwd,protocol));

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT;
         _NFMdebug ((fname,"Decrypt Passwd : status = <0x%.8x>\n",
                   status)); 
	ERRload_struct(NFM,status,"%s","Password");
         return (status);
       }

      sock_no = -1;

      status = NFMconnect (node_name, user_name,dec_passwd,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL Connect Failed : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMcl_send_buffer (&sock_no, NFM_SEND_FILES, in_list);
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
         _NFMdebug ((fname,"CL Exit Failed : status = <0x%.8x>\n",status));
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Server Send Files Failed: status1 = <0x%.8x>\n",
         status1));
	ERRload_struct(NFM,NFM_E_SERVER_SEND_FAILED,"");
         return (status1);
       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMser_get_files_out (in_list, out_list)
   MEMptr    in_list;
   MEMptr    *out_list;
   {
      char *fname="NFMser_get_files_out ";
      long     status;
      long     x, y, count, count1;
      long     i1, j1, k1, l1, m1, n1, o1;
      long     p1, q1, r1, s1, t1, u1, v1, w1;
      long     m2, n2, o2, p2, q2, r2;
      char     **column, **data, **column2, **data2;
      char     size_str [50], dec_pass [50], temp_sa [50];
      char     src_file [512], dst_file [512];
      long     size, protocol;
      MEMptr   sa_list = NULL;
      long     NFMftp_send ();
      int     *FILE_SOCK,FILE_SOCK_VAL ;

      _NFMdebug ((fname,"Entry\n"));
      FILE_SOCK = &FILE_SOCK_VAL;
      *FILE_SOCK = -1 ;

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         status = NFM_E_MEM_FAILURE;
	 ERRload_struct(NFM,status,"%s","MEMbuild_array");
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",
                   status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
	 ERRload_struct(NFM,status,"%s","MEMsplit_copy_buffer");
         _NFMdebug ((fname,"MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
	 ERRload_struct(NFM,status,"%s","MEMreset_buffer_no");
         _NFMdebug ((fname,"MEM Reset No : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
	 ERRload_struct(NFM,status,"%s","MEMsplit_copy_buffer");
         _NFMdebug ((fname,"MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
	 ERRload_struct(NFM,status,"%s","MEMbuild_array");
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",
                   status));
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         status = NFM_E_MEM_FAILURE;
	 ERRload_struct(NFM,status,"%s","MEMbuild_array");
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",
                   status));
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
         status = NFM_E_CORRUPTED_BUFFERS;
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n",
         status));
         ERRload_struct (NFM, status, "%s", "sa_list");
         return (status);
       }

      m2 = -1; n2 = -1; o2 = -1; p2 = -1; q2 = -1; r2 = -1;

      for (y = 0; y < sa_list -> columns; ++y)
       {
              if (! strcmp (column2 [y], "n_pathname"))     m2 = y;
         else if (! strcmp (column2 [y], "n_tcpip"))        n2 = y;
         else if (! strcmp (column2 [y], "n_xns"))          o2 = y;
         else if (! strcmp (column2 [y], "n_decnet"))       p2 = y;
         else if (! strcmp (column2 [y], "n_machid"))       q2 = y;
         else if (! strcmp (column2 [y], "n_opsys"))        r2 = y;
       }

      if (m2 < 0 || n2 <  0 || o2 < 0 || p2 < 0 || q2 < 0 || r2 < 0)
       {
         MEMclose (&sa_list);
         status = NFM_E_CORRUPTED_BUFFERS;
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n",
         status));
         ERRload_struct (NFM, status, "%s", "sa_list");
         return (status);
       }

      temp_sa [0] = 0;

      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;
	 _NFMdebug((fname,"mach_id <%s> status <%s> size <%s>\n",data[count+q1],
data[count+w1],data[count+u1]));

         if ((! strcmp (data [count + w1], "move")) &&
             (! strcmp (data [count + u1], "-1")))
          {
            if (strcmp (data [count + i1], temp_sa))
             {
               status = NFMdisconnect (FILE_SOCK);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  _NFMdebug ((fname,"NFMdisconnect: status = <0x%.8x>\n", status));
                  return (status);
                }

               if ((! strcmp (data2 [n2], data [count + n1])) &&
                   (! strcmp (data2 [n2], "Y")))  
                 protocol = NET_TCP;
               else if ((! strcmp (data2 [o2], data [count + o1])) &&
                        (! strcmp (data2 [o2], "Y")))  
                 protocol = NET_XNS;
               else   
                 protocol = NULL;

               status = NFMdecrypt (data [count + l1], dec_pass);
               if (status != NFM_S_SUCCESS)
                {
                  NFMdisconnect(FILE_SOCK);
                  MEMclose (&sa_list);
                  status = NFM_E_NET_DECRYPT;
                  _NFMdebug ((fname,"NFM Decrypt : status = <0x%.8x>\n",
                  status));
		  ERRload_struct(NFM,status,"%s","Password");
                  return (status);
                }

               sprintf (temp_sa, "%s", data [count + i1]);

               if ((! strcmp (data [count + q1], "CLIX")))
                {
                  status = NFMconnect (data [count + j1], 
                           data [count + k1], dec_pass,NFM_TCP_PORT,
			   NFM_XNS_PORT,FILE_SOCK, protocol);
                  if (status != NFM_S_SUCCESS)
                   {
                     NFMdisconnect(FILE_SOCK);
                     MEMclose (&sa_list);
                     _NFMdebug ((fname,"File Conn : status = <0x%.8x>\n",
                     status));
                     return (status);
                   }
                }
             }

            for (y = x; y < (*out_list) -> rows; ++y)
             {
               count1 = (*out_list) -> columns * y;

               if ((! strcmp (data [count1 + w1], "move")) &&
                   (! strcmp (data [count1 + u1], "-1"))   &&
                   (! strcmp (data [count1 + i1], temp_sa)))
                {
                  status = NFMappend_path_file (data2 [r2],
                           data2 [m2], data [count1 + t1], src_file);
                  if (status != NFM_S_SUCCESS)
                   {
                     NFMdisconnect(FILE_SOCK);
                     MEMclose (&sa_list);
                     _NFMdebug ((fname,"Append Path: status = <0x%.8x>\n",
                     status));
                     return (status);
                   }

                  status = NFMappend_path_file (data [count1 + r1],
                           data [count1 + m1], data [count1 + s1], dst_file);
                  if (status != NFM_S_SUCCESS)
                   {
                     NFMdisconnect(FILE_SOCK);
                     MEMclose (&sa_list);
                     _NFMdebug ((fname,"Append Path: status = <0x%.8x>\n",
                     status));
                     return (status);
                   }

                  size = 0;

                  if ((! strcmp (data [count1 + q1], "CLIX")))
                   {
                     status = NFMfile_send (src_file, dst_file,
                              data [count1 + v1], (int *)&size,FILE_SOCK,0);
                     if (status != NFM_S_SUCCESS)
                      {
                        NFMdisconnect(FILE_SOCK);
                        MEMclose (&sa_list);
                        _NFMdebug ((fname,"Send File: status =<0x%.8x>\n",
                        status));
                        return (status);
                      }
                   }
                  else    if((! strcmp (data [count1 + q1], "VAX")) && (protocol == NET_XNS)) /* VAX - IGI */
		   {
                     status = NETfmu_con_send (data [count1 + j1],
                              data [count1 + k1], dec_pass, src_file, dst_file,
                              data [count1 + v1], (int *)&size);
                     if (status != NET_S_SUCCESS)
                      {
                        NFMdisconnect(FILE_SOCK);
                        MEMclose (&sa_list);
                        _NFMdebug ((fname,"FMU Send File: status =<0x%.8x>\n",
                        status));
                        return (status);
                      }                     
		   }
                  else
                   {
                     status = NFMftp_send (data [count1 + j1],
                              data [count1 + k1], dec_pass, src_file, dst_file,
                              data [count1 + v1], &size);
                     if (status != NFM_S_SUCCESS)
                      {
                        NFMdisconnect(FILE_SOCK);
                        MEMclose (&sa_list);
                        _NFMdebug ((fname,"FTP Send File: status =<0x%.8x>\n",
                        status));
                        return (status);
                      }                     
                   }
               
                  if (size < 0)
                   {
                     NFMdisconnect(FILE_SOCK);
                     MEMclose (&sa_list);
                     status = NFM_E_INVALID_FILE_SIZE;
                     _NFMdebug ((fname,"Bad F Size: status = <0x%.8x>\n",
                     status));
		     ERRload_struct(NFM,status,"");
                     return (status);
                   }
 
                  sprintf (size_str, "%d", size);

                  status = MEMwrite_data (*out_list, size_str, y + 1, u1 + 1);
                  if (status != MEM_S_SUCCESS)
                   {
                     NFMdisconnect(FILE_SOCK);
                     MEMclose (&sa_list);
                     status = NFM_E_MEM_FAILURE;
                     _NFMdebug ((fname,"MEM Wr Data: status = <0x%.8x>\n",
                     status));
		     ERRload_struct(NFM,status,"%s","MEMwrite_data");
                     return (status);
                   }
                }
             }
          }
       }

      status = NFMdisconnect(FILE_SOCK) ;
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"NFMdisconnect: status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
         status = NFM_E_MEM_FAILURE;
	 ERRload_struct(NFM,status,"%s","MEMclose");
         _NFMdebug ((fname,"MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      
      
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

