#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

 long NFMmove_files_in (user_id, sa_no, passwd, list)
   long    user_id;
   long    sa_no;
   char    *passwd;
   MEMptr  *list;
   {
char *fname="NFMmove_files_in ";
     long     status;
     MEMptr   sa_list = NULL, trans_list = NULL, sa1_list = NULL;
     char     **column, **data;
     long      y, i, j, k, l, m, n, o, protocol;
     char     encr_passwd [50];
     long     NFMfmu_ftp_get_files_in ();

     _NFMdebug ((fname,"MV FILES IN : User Id = <%d>  ", user_id));
     _NFMdebug ((fname,"MV FILES IN : SA   No = <%d>  ", sa_no  ));
     _NFMdebug ((fname,"MV FILES IN : Passwd  = <%s>\n", passwd ));

     if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("Move In list ", *list, _NFMdebug_st.NFMdebug_file);

/* Commented out by B.W. 1/15/92 
     if (_NFMdebug_st.NFMdebug_on)
       NFMtime_stamp_start (_NFMdebug_st.NFMdebug_file);
*/
    
     status = NFMget_sa_no_buffer (user_id, sa_no, &sa_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        _NFMdebug ((fname,"MV FILES IN : SA Buff Info : status = <0x%.8x>\n", status));
        return (status);        
      }

     status = MEMappend (*list, sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname,"MV FILES IN : MEM Append : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMbuild_array (sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
        _NFMdebug ((fname,"MV FILES IN : MEM Build Array : status = <0x%.8x>\n",
        NFM_E_MEM));
        return (NFM_E_MEM);        
      }

     column = (char **) sa_list -> column_ptr;
     data   = (char **) sa_list -> data_ptr;

     i = -1; j = -1; k = -1; l = -1; m = -1; n = -1; o = -1;

     for (y = 0; y < sa_list -> columns; ++y)
      {
              if (! strcmp (column [y], "n_nodename"))   i = y;
         else if (! strcmp (column [y], "n_username"))   j = y;
         else if (! strcmp (column [y], "n_passwd"))     k = y;
         else if (! strcmp (column [y], "n_tcpip"))      l = y;
         else if (! strcmp (column [y], "n_xns"))        m = y;
         else if (! strcmp (column [y], "n_decnet"))     n = y;
         else if (! strcmp (column [y], "n_machid"))     o = y;
      }

     if (i < 0 || j < 0 || k < 0 || l < 0 || m < 0 || n < 0 || o < 0 )
      {
        MEMclose (&sa_list);
        /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
      status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL); 
        _NFMdebug ((fname,"MV FILES IN : Corrupted Buffer : status = <0x%.8x>\n",
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
           _NFMdebug ((fname,"MV FILES IN : NFM Encrypt : status = <0x%.8x>\n",
           NFM_E_NET));
           return (NFM_E_NET);
         }

        status = MEMwrite_data (sa_list, encr_passwd, 1, k + 1);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
           _NFMdebug ((fname,"MV FILES IN : MEM Wr Data : status = <0x%.8x>\n",
           NFM_E_MEM));
           return (NFM_E_MEM);
         }
      }

          if (! strcmp (data [l], "Y")) protocol = NET_TCP;
     else if (! strcmp (data [m], "Y")) protocol = NET_XNS;
     else                               protocol = NULL;


     /* Added comparision with UNIX added for SUN port - SSRS - 7/12/93 */
     if ((! strcmp (data [o], "CLIX")) || (! strcmp (data [o],  "UNIX")))
      {
        status = NFMcl_get_files_in (data [i], data [j], data [k],
                 protocol, sa_list, &trans_list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"MV FILES IN : Get Files In : status = <0x%.8x>\n",
           status));
           return (status);             
         }
      }
     else    if ((! strcmp (data [o], "VAX")) && (protocol == NET_XNS)) /* VAX - IGI */
      {
        status = NFMget_sa_no_buffer (user_id, 1, &sa1_list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           _NFMdebug ((fname,"MV FILES IN : SA Buff Info : status = <0x%.8x>\n",
           status));
           return (status);        
         }

        status = NFMfmu_ftp_get_files_in (user_id, data [i],
                 data [j], data [k], sa_list, sa1_list, &trans_list,NET_FMU);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"MV FILES IN : Get Files In : status = <0x%.8x>\n",
           status));
           return (status);             
         }

        status = MEMclose (&sa1_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
           _NFMdebug ((fname,"MV FILES IN : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
           return (NFM_E_MEM);             
         }

      }
     else
      {
        status = NFMget_sa_no_buffer (user_id, 1, &sa1_list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           _NFMdebug ((fname,"MV FILES IN : SA Buff Info : status = <0x%.8x>\n",
           status));
           return (status);        
         }

        status = NFMfmu_ftp_get_files_in (user_id, data [i],
                 data [j], data [k], sa_list, sa1_list, &trans_list,NET_FTP);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           _NFMdebug ((fname,"MV FILES IN : Get Files In : status = <0x%.8x>\n",
           status));
           return (status);             
         }

        status = MEMclose (&sa1_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&sa_list);
           MEMclose (&trans_list);
           /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
           _NFMdebug ((fname,"MV FILES IN : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
           return (NFM_E_MEM);             
         }
      }

     status = MEMclose (&sa_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
        _NFMdebug ((fname,"MV FILES IN : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMbuild_array (trans_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
        _NFMdebug ((fname,"MV FILES IN : MEM Build Array : status = <0x%.8x>\n",
        NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     if ((*list) -> rows != trans_list -> rows)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_FILE_IN_TRANSFER); */
      status = ERRload_struct (NFM, NFM_E_FILE_IN_TRANSFER, "", NULL); 
        _NFMdebug ((fname,"MV FILES IN : File In Trans : status = <0x%.8x>\n",
        NFM_E_FILE_IN_TRANSFER));
        return (status);             
      }

     status = MEMclose (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
        _NFMdebug ((fname,"MV FILES IN : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);             
      }

     status = MEMsplit_copy_buffer (trans_list, list, 0);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&trans_list);
        /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
        _NFMdebug ((fname,"MV FILES IN : MEM Copy : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);     
      }

     status = MEMclose (&trans_list);
     if (status != MEM_S_SUCCESS)
      {
        /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
        _NFMdebug ((fname,"MV FILES IN : MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
        return (NFM_E_MEM);     
      }

/* Commented out by B.W. 1/15/92 
     if (_NFMdebug_st.NFMdebug_on)
       NFMtime_stamp_stop ("MOVE IN FILES", _NFMdebug_st.NFMdebug_file);
*/

     if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("Move In list ", *list, _NFMdebug_st.NFMdebug_file);

     _NFMdebug ((fname,"MV FILES IN : SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }

 long NFMundo_move_files_in (user_id, sa_no, passwd, list)
   long    user_id;
   long    sa_no;
   char    *passwd;
   MEMptr  *list;
   {
char *fname="NFMundo_move_files_in ";
     long     status;

     _NFMdebug ((fname,"UNDO MV FILES IN : User Id   = <%d>  ", user_id));
/*      Name = <%s> has been changed to Name = <%d> -- MVR 1/12/93 */
     _NFMdebug ((fname, "UNDO MV FILES IN : SA   Name = <%d>  ",  sa_no ));
/*    Passwd = <%d> has been changed to passwd = <%s> -- MVR 1/12/93 */
     _NFMdebug ((fname, "UNDO MV FILES IN : Passwd    = <%s>\n",  passwd));

     if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("Undo Move In list ", *list,
                         _NFMdebug_st.NFMdebug_file);
 
     status = NFMdelete_in_files (user_id, sa_no, passwd, list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,"UNDO MV FILES IN : Del Files : status = <0x%.8x>\n", 
        status));
        return (status);     
      }

     if (_NFMdebug_st.NFMdebug_on)
       MEMprint_buffer ("Undo Move In list ", *list,
                        _NFMdebug_st.NFMdebug_file);

     _NFMdebug ((fname,"UNDO MV FILES IN : SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }

 long NFMfmu_ftp_get_files_in (user_id, node_name, user_name, passwd,
                           in_list, sa1_list, out_list,type)
   char    *node_name, *user_name, *passwd;
   MEMptr  in_list, sa1_list, *out_list;
   long type ;
   {
char *fname="NFMfmu_ftp_get_files_in ";
      long     status;
      long     x, y, count;
      long     i1, j1, k1, l1, m1, n1, o1;
      long     p1, q1, r1, s1, t1, u1, v1, w1;
      long     i2, j2, k2, l2, m2, n2, o2, p2, q2, r2;
      char     **column, **data, **column2, **data2, **data3, **data4;
      char     size_str [50], dec_pass [50];
      char     dst_file [512], temp [50];
      long     size, protocol;
      MEMptr   sa_list = NULL, temp_list = NULL, trans_list = NULL;

      _NFMdebug ((fname,"FTP FILES IN : Node Name = <%s>  ", node_name));
      _NFMdebug ((fname,"FTP FILES IN : User Name = <%s>  ", user_name));
      _NFMdebug ((fname,"FTP FILES IN : Passwd    = <%s>\n", passwd   ));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"FTP FILES IN : MEM Build Array : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Reset No : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &temp_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Build Array : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = MEMbuild_array (sa1_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Build Array : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Build Array : status = <0x%.8x>\n",
         status));
         return (status);
       }

      column  = (char **) (*out_list) -> column_ptr;
      data    = (char **) (*out_list) -> data_ptr;

      column2 = (char **) sa_list -> column_ptr;
      data2   = (char **) sa_list -> data_ptr;

      data3   = (char **) sa1_list -> data_ptr;

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
         MEMclose (&temp_list);
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
      status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL); 
         _NFMdebug ((fname,"FTP FILES IN : Corrupted Buffer : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
       }

      i2 = -1; j2 = -1; k2 = -1; l2 = -1; m2 = -1; 
      n2 = -1; o2 = -1; p2 = -1; q2 = -1; r2 = -1;

      for (y = 0; y < sa_list -> columns; ++y)
       {
              if (! strcmp (column2 [y], "n_sano"))         i2 = y;
         else if (! strcmp (column2 [y], "n_nodename"))     j2 = y;
         else if (! strcmp (column2 [y], "n_username"))     k2 = y;
         else if (! strcmp (column2 [y], "n_passwd"))       l2 = y;
         else if (! strcmp (column2 [y], "n_pathname"))     m2 = y;
         else if (! strcmp (column2 [y], "n_tcpip"))        n2 = y;
         else if (! strcmp (column2 [y], "n_xns"))          o2 = y;
         else if (! strcmp (column2 [y], "n_decnet"))       p2 = y;
         else if (! strcmp (column2 [y], "n_machid"))       q2 = y;
         else if (! strcmp (column2 [y], "n_opsys"))        r2 = y;
       }

      if (i2 < 0 || j2 < 0 || k2 < 0 || l2 < 0 || m2 < 0 || 
          n2 < 0 || o2 < 0 || p2 < 0 || q2 < 0 || r2 < 0)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
      status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL); 
         _NFMdebug ((fname,"FTP FILES IN : Corrupted Buffer : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
       }

      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if ((! strcmp (data [count + w1], "move")) &&
             (! strcmp (data [count + u1], "-1")))
          {
            dst_file [0] = 0;

            sprintf (temp, "%dXXXXXX", x);
            sprintf (dst_file, "/usr/tmp/%s",  mktemp (temp));

            status = MEMwrite_data (temp_list, dst_file, x + 1, t1 + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&sa_list);
               MEMclose (&temp_list);
               /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
               _NFMdebug ((fname,"FTP FILES IN : MEM Write Data : status = <0x%.8x>\n",
               NFM_E_MEM));
               return (NFM_E_MEM);
             }
          }
       }

      status = MEMappend (temp_list, sa1_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
         _NFMdebug ((fname,"FTP FILES IN : MEM Append : status = <0x%.8x>\n",
         NFM_E_MEM));
         return (NFM_E_MEM);
       }

      status = MEMbuild_array (sa1_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
         _NFMdebug ((fname,"FTP FILES IN : MEM Build Array : status = <0x%.8x>\n",
         NFM_E_MEM));
         return (NFM_E_MEM);
       }

      data3 = (char **) sa1_list -> data_ptr;

           if (! strcmp (data3 [n2], "Y")) protocol = NET_TCP;
      else if (! strcmp (data3 [o2], "Y")) protocol = NET_XNS;
      else                                 protocol = NULL;

      status = NFMcl_get_files_in (data3 [j2], data3 [k2], data3 [l2],
               protocol, sa1_list, &trans_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         MEMclose (&trans_list);
         _NFMdebug ((fname,"FTP FILES IN : Get Files On Server : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = MEMbuild_array (trans_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         MEMclose (&trans_list);
         /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
         _NFMdebug ((fname,"FTP FILES IN : Get Files On Server : status = <0x%.8x>\n",
         NFM_E_MEM));
         return (NFM_E_MEM);
       }

      data4 = (char **) trans_list -> data_ptr;

      if ((*out_list) -> rows != trans_list -> rows)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         MEMclose (&trans_list);
         /* status = NFMerror (NFM_E_FILE_OUT_TRANSFER); */
      status = ERRload_struct (NFM, NFM_E_FILE_OUT_TRANSFER, "", NULL); 
         _NFMdebug ((fname,"FTP FILES IN : File Out Trans : status = <0x%.8x>\n",
         NFM_E_FILE_OUT_TRANSFER));
         return (NFM_E_FILE_OUT_TRANSFER);
       }

      status = NFMdecrypt (data2 [l2], dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         MEMclose (&trans_list);
         /* status = NFMerror (NFM_E_NET); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
         _NFMdebug ((fname,"FTP FILES IN : Decrypt Passwd : status = <0x%.8x>\n",
         NFM_E_MEM));
         return (NFM_E_MEM);
       }

      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if ((! strcmp (data [count + w1], "move")) &&
             (! strcmp (data [count + u1], "-1")))
          {
            status = NFMappend_path_file (data2 [r2],
                     data2 [m2], data [count + t1], dst_file);
            if (status != NFM_S_SUCCESS)
             {
               MEMclose (&sa_list);
               MEMclose (&temp_list);
               MEMclose (&trans_list);
               _NFMdebug ((fname,"FTP FILES IN : Append Path : status = <0x%.8x>\n",
               status));
               return (status);
             }
            
	    if(type == NET_FTP)
	    {
            status = NFMftp_send (data2 [j2], data2 [k2], dec_pass,
                     data4 [count + t1], dst_file, data [count + v1], &size);
            if (status != NFM_S_SUCCESS)
             {
               MEMclose (&sa_list);
               MEMclose (&temp_list);
               MEMclose (&trans_list);
               /* status = NFMerror (status); */
      status = ERRload_struct (NFM, status, "", NULL); 
               _NFMdebug ((fname,"FTP FILES IN : Rec File : status = <0x%.8x>\n",
               status));
               return (status);
             }
	   }
	   else if (type == NET_FMU )
           {
            status = NETfmu_con_send (data2 [j2], data2 [k2], dec_pass,
                     data4 [count + t1], dst_file, data [count + v1], (int *)&size);
            if (status != NET_S_SUCCESS)
             {
               MEMclose (&sa_list);
               MEMclose (&temp_list);
               MEMclose (&trans_list);
               _NFMdebug ((fname,"FMU FILES IN : Rec File : status = <0x%.8x>\n",
               status));
               return (status);
             }
	   }
	   else return (NFM_E_FAILURE);

            sprintf (size_str, "%d", size);

            status = MEMwrite_data (*out_list, size_str, x + 1, u1 + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&sa_list);
               MEMclose (&temp_list);
               MEMclose (&trans_list);
               /* status = NFMerror (NFM_E_MEM); */
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
               _NFMdebug ((fname,"FTP FILES IN : MEM Write Data : status = <0x%.8x>\n",
               NFM_E_MEM));
               return (NFM_E_MEM);
             }
          }
       }

      NFMdelete_in_files (user_id, atol(data3 [i2]), "", &trans_list);

      status = MEMclose (&trans_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         MEMclose (&temp_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      

      status = MEMclose (&temp_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         _NFMdebug ((fname,"FTP FILES IN : MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      

      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"FTP FILES IN : MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      
     
     _NFMdebug ((fname,"FTP FILES IN : SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }
