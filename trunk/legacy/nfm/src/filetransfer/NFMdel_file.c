#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

 long NFMdelete_in_files (user_id, sa_no, passwd, list)
   long    user_id;
   long    sa_no;
   char    *passwd;
   MEMptr  *list;
   {
     char *fname="NFMdelete_in_files ";
     long     status;
     MEMptr   sa_list = NULL, trans_list = NULL;
     char     **column, **data;
     long      y, i, j, k, l, m, n, o, p, q, r, protocol;
     char     encr_passwd [50];
     long     NFMftp_delete_files_co (),NFMfmu_delete_files();

     _NFMdebug ((fname,"DEL IN FILES : User Id = <%d>  ", user_id));
     _NFMdebug ((fname,"DEL IN FILES : SA   No = <%d>  ", sa_no  ));
     _NFMdebug ((fname,"DEL IN FILES : Passwd  = <%s>\n", passwd ));

     if (_NFMdebug_st.NFMdebug_on)
       MEMprint_buffer ("Del Files List", *list, _NFMdebug_st.NFMdebug_file);

     status = NFMget_sa_no_buffer (user_id, sa_no, &sa_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        _NFMdebug ((fname,"DEL IN FILES : SA Buff Info : status = <0x%.8x>\n", status));
        return (status);        
      }

     status = MEMappend (*list, sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : MEM Append : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMbuild_array (sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : MEM Build Array : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);        
      }

     column = (char **) sa_list -> column_ptr;
     data   = (char **) sa_list -> data_ptr;

     i = -1; j = -1; k = -1; l = -1; m = -1;
     n = -1; o = -1; p = -1; q = -1; r = -1;

     for (y = 0; y < sa_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_sano"))        i = y;
         else if (! strcmp (column [y], "n_nodename"))    j = y;
         else if (! strcmp (column [y], "n_username"))    k = y;
         else if (! strcmp (column [y], "n_passwd"))      l = y;
         else if (! strcmp (column [y], "n_pathname"))    m = y;
         else if (! strcmp (column [y], "n_tcpip"))       n = y;
         else if (! strcmp (column [y], "n_xns"))         o = y;
         else if (! strcmp (column [y], "n_decnet"))      p = y;
         else if (! strcmp (column [y], "n_machid"))      q = y;
         else if (! strcmp (column [y], "n_opsys"))       r = y;
      }

     if (i < 0 || j < 0 || k < 0 || l < 0 || m < 0 ||
         n < 0 || o < 0 || p < 0 || q < 0 || r < 0)
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
        return (NFM_E_CORRUPTED_BUFFERS);
      }

     if (strlen (passwd))
      {
        status = NFMencrypt (passwd, encr_passwd);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           /* status = NFMerror (NFM_E_NET); */
           status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
           _NFMdebug ((fname,"DEL IN FILES : NFM Encrypt : status = <0x%.8x>\n", NFM_E_NET));
           return (NFM_E_NET);             
         }

        status = MEMwrite_data (sa_list, encr_passwd, 1, l + 1);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname,"DEL IN FILES : MEM Wr Data : status = <0x%.8x>\n", NFM_E_MEM));
           return (NFM_E_MEM);             
         }
      }

          if (! strcmp (data [n], "Y")) protocol = NET_TCP;
     else if (! strcmp (data [o], "Y")) protocol = NET_XNS;
     else                               protocol = NULL;

  /* Added comparision with UNIX for SUN - SSRS - 7/12/93 */

     if ((! strcmp (data [q], "CLIX")) || (!strcmp (data[q],  "UNIX")))
      {
        status = NFMcl_delete_files_co (data [j], data [k], data [l],
                 protocol, sa_list, &trans_list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"DEL IN FILES : Del Co Files : status = <0x%.8x>\n", status));
           return (status);             
         }
      }
     else    if ((! strcmp (data [q], "VAX")) && (protocol == NET_XNS))/* VAX - IGI */
      {
        status = NFMfmu_delete_files (data [j], data [k], data [l],
                 sa_list, &trans_list,FMU_DEL_CO);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"DEL IN FILES : Del Co Files : status = <0x%.8x>\n", status));
           return (status);             
         }
      }
     else
      {
        status = NFMftp_delete_files_co (data [j], data [k], data [l],
                 sa_list, &trans_list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"DEL IN FILES : Del Co Files : status = <0x%.8x>\n", status));
           return (status);             
         }
      }

     status = MEMclose (&sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMbuild_array (trans_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : MEM Build Array : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     if ((*list) -> rows != trans_list -> rows)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_DELETE_FILE); */
           status = ERRload_struct (NFM, NFM_E_DELETE_FILE, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : File Out Trans : status = <0x%.8x>\n", NFM_E_DELETE_FILE));
        return (NFM_E_DELETE_FILE);             
      }

     status = MEMclose (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMsplit_copy_buffer (trans_list, list, 0);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : MEM Copy : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);     
      }

     status = MEMclose (&trans_list);
     if (status != MEM_S_SUCCESS)
      {
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL IN FILES : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);     
      }

     if (_NFMdebug_st.NFMdebug_on)
       MEMprint_buffer ("Del Files List", *list, _NFMdebug_st.NFMdebug_file);

     _NFMdebug ((fname,"DEL IN FILES : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMdelete_out_files (user_id, sa_no, passwd, list)
   long    user_id;
   long    sa_no; 
   char    *passwd;
   MEMptr  *list;
   {
char *fname="NFMdelete_out_files ";
     long     status;
     MEMptr   sa_list = NULL, trans_list = NULL;
     char     **column, **data;
     long      y, i, j, k, l, m, n, o, p, q, r, protocol;
     char     encr_passwd [50];
     long     NFMftp_delete_files_ci (),NFMfmu_delete_files();

     _NFMdebug ((fname,"DEL OUT FILES : User Id = <%d>  ", user_id));
     _NFMdebug ((fname,"DEL OUT FILES : SA   No = <%d>  ", sa_no  ));
     _NFMdebug ((fname,"DEL OUT FILES : Passwd  = <%s>\n", passwd ));

     if (_NFMdebug_st.NFMdebug_on)
       MEMprint_buffer ("Del Files List", *list, _NFMdebug_st.NFMdebug_file);

     status = NFMget_sa_no_buffer (user_id, sa_no, &sa_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        _NFMdebug ((fname,"DEL OUT FILES : SA Buff Info : status = <0x%.8x>\n", status));
        return (status);        
      }

     status = MEMappend (*list, sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : MEM Append : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMbuild_array (sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : MEM Build Array : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);        
      }

     column = (char **) sa_list -> column_ptr;
     data   = (char **) sa_list -> data_ptr;

     i = -1; j = -1; k = -1; l = -1; m = -1;
     n = -1; o = -1; p = -1; q = -1; r = -1;

     for (y = 0; y < sa_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_sano"))        i = y;
         else if (! strcmp (column [y], "n_nodename"))    j = y;
         else if (! strcmp (column [y], "n_username"))    k = y;
         else if (! strcmp (column [y], "n_passwd"))      l = y;
         else if (! strcmp (column [y], "n_pathname"))    m = y;
         else if (! strcmp (column [y], "n_tcpip"))       n = y;
         else if (! strcmp (column [y], "n_xns"))         o = y;
         else if (! strcmp (column [y], "n_decnet"))      p = y;
         else if (! strcmp (column [y], "n_machid"))      q = y;
         else if (! strcmp (column [y], "n_opsys"))       r = y;
      }

     if (i < 0 || j < 0 || k < 0 || l < 0 || m < 0 ||
         n < 0 || o < 0 || p < 0 || q < 0 || r < 0)
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : Corrupted Buffer : status = <0x%.8x>\n",
        NFM_E_CORRUPTED_BUFFERS));
        return (NFM_E_CORRUPTED_BUFFERS);
      }

     if (strlen (passwd))
      {
        status = NFMencrypt (passwd, encr_passwd);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           /* status = NFMerror (NFM_E_NET); */
           status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
           _NFMdebug ((fname,"DEL OUT FILES : NFM Encrypt : status = <0x%.8x>\n", NFM_E_NET));
           return (NFM_E_NET);             
         }

        status = MEMwrite_data (sa_list, encr_passwd, 1, l + 1);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname,"DEL OUT FILES : MEM Wr Data : status = <0x%.8x>\n", NFM_E_MEM));
           return (NFM_E_MEM);             
         }
      }

          if (! strcmp (data [n], "Y")) protocol = NET_TCP;
     else if (! strcmp (data [o], "Y")) protocol = NET_XNS;
     else                               protocol = NULL;
  /* Added comparision with UNIX for SUN - SSRS - 7/12/93 */
     if ((! strcmp (data [q], "CLIX")) || (!strcmp (data [q],  "UNIX")))
      {
        status = NFMcl_delete_files_ci (data [j], data [k], data [l],
                 protocol, sa_list, &trans_list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"DEL OUT FILES : Get Files In : status = <0x%.8x>\n", status));
           return (status);             
         }
      }
     else    if ( (! strcmp (data [q], "VAX")) && (protocol == NET_XNS)) /* VAX - IGI */
      {
        status = NFMfmu_delete_files (data [j], data [k], data [l],
                 sa_list, &trans_list,FMU_DEL_CI);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"DEL IN FILES : Del Co Files : status = <0x%.8x>\n", status));
           return (status);             
         }
      }
     else
      {
        status = NFMftp_delete_files_ci (data [j], data [k], data [l],
                 sa_list, &trans_list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"DEL IN FILES : Del Co Files : status = <0x%.8x>\n", status));
           return (status);             
         }
      }

     status = MEMclose (&sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMbuild_array (trans_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : MEM Build Array : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     if ((*list) -> rows != trans_list -> rows)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_DELETE_FILE); */
           status = ERRload_struct (NFM, NFM_E_DELETE_FILE, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : File Out Trans : status = <0x%.8x>\n", NFM_E_DELETE_FILE));
        return (NFM_E_DELETE_FILE);             
      }

     status = MEMclose (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMsplit_copy_buffer (trans_list, list, 0);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : MEM Copy : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);     
      }

     status = MEMclose (&trans_list);
     if (status != MEM_S_SUCCESS)
      {
        /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"DEL OUT FILES : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);     
      }

     if (_NFMdebug_st.NFMdebug_on)
       MEMprint_buffer ("Del Files List", *list, _NFMdebug_st.NFMdebug_file);

     _NFMdebug ((fname,"DEL OUT FILES : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMftp_delete_files_co (node_name, user_name, passwd, 
                              in_list, out_list)
   char    *node_name, *user_name, *passwd;
   MEMptr  in_list, *out_list;
   {
char *fname="NFMftp_delete_files_co ";
      long     status;
      long     x, y, count;
      long     i1, j1, k1, l1, m1, n1;
      long     o1, p1, q1, r1, s1, t1, u1;
      long     i2, m2, n2, o2, p2, q2, r2;
      char     **column, **data, **column2, **data2;
      char     str [1024], src_file [512], dec_pass [50];
      long     delete;
      MEMptr   sa_list = NULL;
      char     f_script [100], f_stderr [100], f_stdout [100];
      FILE     *infile, *fopen ();
      struct   stat  fbuff;

      _NFMdebug ((fname,"FTP DEL CO : Node Name = <%s>  ", node_name));
      _NFMdebug ((fname,"FTP DEL CO : User Name = <%s>  ", user_name));
      _NFMdebug ((fname,"FTP DEL CO : Passwd    = <%s>\n", passwd   ));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"FTP DEL CO : MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CO : MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CO : MEM Reset No : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CO : MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CO : MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CO : MEM Build Array : status = <0x%.8x>\n", status));
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
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname,"FTP DEL CO : Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
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
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname,"FTP DEL CO : Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
       }

      sprintf (f_script,  "/usr/tmp/%s",  mktemp ("NFMdel1XXXXXXX"));
      sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("NFMdel2XXXXXXX"));
      sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("NFMdel3XXXXXXX"));

      infile = fopen (f_script, "w");
      if (! infile)
       {
          MEMclose (&sa_list);
          /* status = NFMerror (NFM_E_OPEN_FILE); */
           status = ERRload_struct (NFM, NFM_E_OPEN_FILE, "", NULL);
          _NFMdebug ((fname,"FTP DEL CO : Open File : status = <0x%.8x>\n", NFM_E_OPEN_FILE));
          return (NFM_E_OPEN_FILE);
       }

      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         fclose (infile);
         unlink (f_script);
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CO : Dec Passwd : status = <0x%.8x>\n", status));
         return (status);  
       }

      sprintf (str, "user %s %s\n", user_name, dec_pass);

      _NFMdebug ((fname,"FTP DEL CO : DELETE SCRIPT : <%s>\n", str));

      status = fwrite (str, sizeof (char), strlen (str), infile);
      if (status < strlen (str))
       {
         fclose (infile);
         unlink (f_script);
         MEMclose (&sa_list);
         /* status = NFMerror (NFM_E_WRITE_FILE); */
           status = ERRload_struct (NFM, NFM_E_WRITE_FILE, "", NULL);
         _NFMdebug ((fname,"FTP DEL CO : Write To File : status = <0x%.8x>\n", NFM_E_WRITE_FILE));
         return (NFM_E_WRITE_FILE);  
       }

      delete = 0;
   
      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if (((! strcmp (data [count + u1], "move"))    ||
              (! strcmp (data [count + u1], "copy"))    ||
              (! strcmp (data [count + u1], "delete"))) &&
             (atol (data [count + t1]) >= 0))
          {
            status = NFMappend_path_file (data2 [r2],
                     data2 [m2], data [count + s1], src_file);
            if (status != NFM_S_SUCCESS)
             {
               fclose (infile);
               unlink (f_script);
               MEMclose (&sa_list);
               _NFMdebug ((fname,"FTP DEL CO : Append Path : status = <0x%.8x>\n",
               status));
               return (status);
             }

            sprintf (str, "delete %s\n", src_file);

            _NFMdebug ((fname,"FTP DEL CO : DELETE SCRIPT : <%s>\n", str));

            status = fwrite (str, sizeof (char), strlen (str), infile);
            if (status != strlen (str))
             {
               fclose (infile);
               unlink (f_script);
               MEMclose (&sa_list);
               /* status = NFMerror (NFM_E_WRITE_FILE); */
           status = ERRload_struct (NFM, NFM_E_WRITE_FILE, "", NULL);
               _NFMdebug ((fname,"FTP DEL CO : Write To File : status = <0x%.8x>\n",
               NFM_E_WRITE_FILE));
               return (NFM_E_WRITE_FILE);  
             }

            delete = 1;
          }
       }

      sprintf (str, "quit\n");
 
      _NFMdebug ((fname,"FTP DEL CO : DELETE SCRIPT : <%s>\n", str));
 
      status = fwrite (str, sizeof (char), strlen (str), infile);
      if (status != strlen (str))
       {
         fclose (infile);
         unlink (f_script);
         MEMclose (&sa_list);
         /* status = NFMerror (NFM_E_WRITE_FILE); */
           status = ERRload_struct (NFM, NFM_E_WRITE_FILE, "", NULL);
         _NFMdebug ((fname,"FTP DEL CO : Write To File : status = <0x%.8x>\n", NFM_E_WRITE_FILE));
         return (NFM_E_WRITE_FILE);  
       }
 
      fclose (infile);
     
      if (delete)
       {
         sprintf (str, "ftp -n %s < %s > %s 2> %s",
                  node_name, f_script, f_stdout, f_stderr);

         _NFMdebug ((fname,"FTP DEL CO : COMMAND STR : <%s>\n", str));

         system (str);

         unlink (f_script);
         unlink (f_stdout);

/* 12/9/92 - KT - Replace 'Stat' with 'stat'
         status = Stat (f_stderr, &fbuff);
*/
         status = stat (f_stderr, &fbuff);
         if (status) /* OK */
          {
             unlink (f_stderr);
             MEMclose (&sa_list);
             /* status = NFMerror (NFM_E_STAT); */
           status = ERRload_struct (NFM, NFM_E_STAT, "", NULL);
             _NFMdebug ((fname,"FTP DEL CO : Stat Failed : status = <0x%.8x>\n", NFM_E_STAT));
             return (NFM_E_STAT);
          }

         if (fbuff.st_size)
          {
             unlink (f_stderr);
             MEMclose (&sa_list);
             /* status = NFMerror (NFM_E_FTP_DELETE_CO_FAILED); */
           status = ERRload_struct (NFM, NFM_E_FTP_DELETE_CO_FAILED, "", NULL);
             _NFMdebug ((fname,"FTP DEL CO : FTP Rec : status = <0x%.8x>\n", NFM_E_FTP_DELETE_CO_FAILED));
             return (NFM_E_FTP_DELETE_CO_FAILED);
          }

         unlink (f_stderr);

         for (x = 0; x < (*out_list) -> rows; ++x)
          {
            count = (*out_list) -> columns * x;

            if (((! strcmp (data [count + u1], "move"))    ||
                 (! strcmp (data [count + u1], "copy"))    ||
                 (! strcmp (data [count + u1], "delete"))) &&
                (atol (data [count + t1]) >= 0))
             {
               status = MEMwrite_data (*out_list, "-1", x + 1, t1 + 1);
               if (status != MEM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  /* status = NFMerror (status); */
           status = ERRload_struct (NFM, status, "", NULL);
                  _NFMdebug ((fname,"FTP DEL CO : MEM Wr Data : status = <0x%.8x>\n",
                  status));
                  return (status);
                }
             }
          }
       }
      else
        unlink (f_stderr);
      
      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"FTP DEL CO : MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      

      _NFMdebug ((fname,"FTP DEL CO : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);      
   }

 long NFMftp_delete_files_ci (node_name, user_name, passwd, 
                              in_list, out_list)
   char    *node_name, *user_name, *passwd;
   MEMptr  in_list, *out_list;
   {
char *fname="NFMftp_delete_files_ci ";
      long     status;
      long     x, y, count;
      long     i1, j1, k1, l1, m1, n1;
      long     o1, p1, q1, r1, s1, t1, u1;
      long     i2, m2, n2, o2, p2, q2, r2;
      char     **column, **data, **column2, **data2;
      char     str [1024], src_file [512], dec_pass [50];
      long     delete;
      MEMptr   sa_list = NULL;
      char     f_script [100], f_stderr [100], f_stdout [100];
      FILE     *infile, *fopen ();
      struct   stat  fbuff;

      _NFMdebug ((fname,"FTP DEL CI : Node Name = <%s>  ", node_name));
      _NFMdebug ((fname,"FTP DEL CI : User Name = <%s>  ", user_name));
      _NFMdebug ((fname,"FTP DEL CI : Passwd    = <%s>\n", passwd   ));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"FTP DEL CI : MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CI : MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CI : MEM Reset No : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CI : MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CI : MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CI : MEM Build Array : status = <0x%.8x>\n", status));
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
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname,"FTP DEL CI : Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
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
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname,"FTP DEL CI : Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
       }

      sprintf (f_script,  "/usr/tmp/%s",  mktemp ("NFMdel1XXXXXXX"));
      sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("NFMdel2XXXXXXX"));
      sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("NFMdel3XXXXXXX"));

      infile = fopen (f_script, "w");
      if (! infile)
       {
          MEMclose (&sa_list);
          /* status = NFMerror (NFM_E_OPEN_FILE); */
           status = ERRload_struct (NFM, NFM_E_OPEN_FILE, "", NULL);
          _NFMdebug ((fname,"FTP DEL CI : Open File : status = <0x%.8x>\n", NFM_E_OPEN_FILE));
          return (NFM_E_OPEN_FILE);
       }

      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         fclose (infile);
         unlink (f_script);
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP DEL CI : Dec Passwd : status = <0x%.8x>\n", status));
         return (status);  
       }

      sprintf (str, "user %s %s\n", user_name, dec_pass);
   
      _NFMdebug ((fname,"FTP DEL CI : DELETE SCRIPT : <%s>\n", str));

      status = fwrite (str, sizeof (char), strlen (str), infile);
      if (status < strlen (str))
       {
         fclose (infile);
         unlink (f_script);
         MEMclose (&sa_list);
         /* status = NFMerror (NFM_E_WRITE_FILE); */
           status = ERRload_struct (NFM, NFM_E_WRITE_FILE, "", NULL);
         _NFMdebug ((fname,"FTP DEL CI : Write To File : status = <0x%.8x>\n", NFM_E_WRITE_FILE));
         return (NFM_E_WRITE_FILE);  
       }

      delete = 0;
   
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
                  fclose (infile);
                  unlink (f_script);
                  MEMclose (&sa_list);
                  _NFMdebug ((fname,"FTP DEL CI : Append Path : status = <0x%.8x>\n",
                  status));
                  return (status);
                }

               sprintf (str, "delete %s\n", src_file);

               _NFMdebug ((fname,"FTP DEL CI : DELETE SCRIPT : <%s>\n", str));

               status = fwrite (str, sizeof (char), strlen (str), infile);
               if (status != strlen (str))
                {
                  fclose (infile);
                  unlink (f_script);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_WRITE_FILE); */
           status = ERRload_struct (NFM, NFM_E_WRITE_FILE, "", NULL);
                  _NFMdebug ((fname,"FTP DEL CI : Write To File : status = <0x%.8x>\n",
                  NFM_E_WRITE_FILE));
                  return (NFM_E_WRITE_FILE);  
                }

               delete = 1;
             }
          }
       }

      sprintf (str, "quit\n");

      _NFMdebug ((fname,"FTP DEL CI : DELETE SCRIPT : <%s>\n", str));
 
      status = fwrite (str, sizeof (char), strlen (str), infile);
      if (status != strlen (str))
       {
         fclose (infile);
         unlink (f_script);
         MEMclose (&sa_list);
         /* status = NFMerror (NFM_E_WRITE_FILE); */
           status = ERRload_struct (NFM, NFM_E_WRITE_FILE, "", NULL);
         _NFMdebug ((fname,"FTP DEL CI : Write To File : status = <0x%.8x>\n", NFM_E_WRITE_FILE));
         return (NFM_E_WRITE_FILE);  
       }
 
      fclose (infile);
     
      if (delete)
       {
         sprintf (str, "ftp -n %s < %s > %s 2> %s",
                  node_name, f_script, f_stdout, f_stderr);

         system (str);

         unlink (f_script);
         unlink (f_stdout);
 
/* 12/9/92 - KT - Replace 'Stat' with 'stat'
         status = Stat (f_stderr, &fbuff);
*/
         status = stat (f_stderr, &fbuff);
         if (status) /* OK */
          {
             unlink (f_stderr);
             MEMclose (&sa_list);
             /* status = NFMerror (NFM_E_STAT); */
           status = ERRload_struct (NFM, NFM_E_STAT, "", NULL);
             _NFMdebug ((fname,"FTP DEL CI : Stat Failed : status = <0x%.8x>\n", NFM_E_STAT));
             return (NFM_E_STAT);
          }

         if (fbuff.st_size)
          {
             unlink (f_stderr);
             MEMclose (&sa_list);
             /* status = NFMerror (NFM_E_FTP_DELETE_CI_FAILED); */
           status = ERRload_struct (NFM, NFM_E_FTP_DELETE_CI_FAILED, "", NULL);
             _NFMdebug ((fname,"FTP DEL CI : FTP Rec : status = <0x%.8x>\n", NFM_E_FTP_DELETE_CI_FAILED));
             return (NFM_E_FTP_DELETE_CI_FAILED);
          }

         unlink (f_stderr);

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
                  status = MEMwrite_data (*out_list, "-1", x + 1, t1 + 1);
                  if (status != MEM_S_SUCCESS)
                   {
                     MEMclose (&sa_list);
                     /* status = NFMerror (status); */
           status = ERRload_struct (NFM, status, "", NULL);
                     _NFMdebug ((fname,"FTP DEL CI : MEM Wr Data : status = <0x%.8x>\n",
                     status));
                     return (status);
                   }
                }
             }
          }
       }
      else
        unlink (f_stderr);
      
      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"FTP DEL CI : MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      

      _NFMdebug ((fname,"FTP DEL CI : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);      
   }

 long NFMfmu_delete_files (node_name, user_name, passwd, 
                              in_list, out_list,type)
   char    *node_name, *user_name, *passwd;
   MEMptr  in_list, *out_list;
   long type ;
   {
      char *fname="NFMfmu_delete_files ";
      long     status;
      long     x, y, count;
      long     i1, j1, k1, l1, m1, n1;
      long     o1, p1, q1, r1, s1, t1, u1;
      long     i2, m2, n2, o2, p2, q2, r2;
      char     **column, **data, **column2, **data2;
      char     str [1024], src_file [512], dec_pass [50];
      long     pos;
      MEMptr   sa_list = NULL;

      _NFMdebug((fname,"Entry Username <%s> Nodename <%s> passwd <%s>\n",
node_name,user_name,passwd));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug((fname," MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug((fname,"MEM Reset No : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ( (fname,"MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug((fname,"MEM Build Array : status = <0x%.8x>\n", status));
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
         else if (type== FMU_DEL_CO && (! strcmp (column [y], "n_cofilename")))   s1 = y;
         else if (type== FMU_DEL_CI && (! strcmp (column [y], "n_cifilename")))   s1 = y;
         else if (! strcmp (column [y], "n_cifilesize"))   t1 = y;
         else if (! strcmp (column [y], "n_status"))       u1 = y;
       }

      if (i1 < 0 || j1 < 0 || k1 < 0 || l1 < 0 || m1 < 0 ||
          n1 < 0 || o1 < 0 || p1 < 0 || q1 < 0 || r1 < 0 ||
          s1 < 0 || t1 < 0 || u1 < 0)
       {
         MEMclose (&sa_list);
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
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
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
       }

      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname," Dec Passwd : status = <0x%.8x>\n", status));
         return (status);  
       }

      status = NETfmu_connect(node_name,user_name,dec_pass);
      if(status != NET_S_SUCCESS)
	{
		 MEMclose(&sa_list);
		 _NFMdebug((fname,"fmu_connect failed to nodename <%s> username <%s> password <%s>\n",node_name,user_name,dec_pass));
		 return(status);
	}
   
      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if (type== FMU_DEL_CO || (! strcmp (data [count + i1], data2 [i2])))
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
                  MEMclose (&sa_list);
		  NETfmu_disconnect();
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
                  return (status);
                }
	       
	       NFMconvert_to_vax_file(src_file);
               sprintf (str, "delete %s", src_file);
	       status = NFMfmu_rcmd(str,"");
	       if(status!=NFM_S_SUCCESS && status != NFM_I_NO_OUTPUT )
		{
                  MEMclose (&sa_list);
		  NETfmu_disconnect();
                  _NFMdebug ((fname," fmu_rcmd failed for command <%s>: status = <0x%.8x>\n",str, status));
			return(status);
		}
             }
          }
       }

      status=NETfmu_disconnect();
      if(status != NET_S_SUCCESS )
      {
            MEMclose (&sa_list);
          _NFMdebug ((fname," fmu_disconnect failed  status = <0x%.8x>\n", status));
            return(status);
      }

         for (x = 0; x < (*out_list) -> rows; ++x)
          {
            count = (*out_list) -> columns * x;

         if (type== FMU_DEL_CO || (! strcmp (data [count + i1], data2 [i2])))
             {
               if (((! strcmp (data [count + u1], "move"))    ||
                    (! strcmp (data [count + u1], "copy"))    ||
                    (! strcmp (data [count + u1], "delete"))) &&
                   (atol (data [count + t1]) >= 0))
                {
                  status = MEMwrite_data (*out_list, "-1", x + 1, t1 + 1);
                  if (status != MEM_S_SUCCESS)
                   {
                     MEMclose (&sa_list);
                     status = ERRload_struct (NFM, status, "", NULL);
                     _NFMdebug ((fname," MEM Wr Data : status = <0x%.8x>\n",
                     status));
                     return (status);
                   }
                }
             }
          }
      
      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug( (fname,"MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);      
   }

