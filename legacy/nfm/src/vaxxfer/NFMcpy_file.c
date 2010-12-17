#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

 long NFMcopy_in_files (user_id, list)
   long    user_id;
   MEMptr  *list;
   {
     long     status, atol ();
     char     **column, **data;
     long     x, y, count, protocol;
     long     i, j, k, l, m, n, o, p, q, r, s, t;
     MEMptr   trans_list = NULL, sa_list = NULL;
     long     NFMftp_copy_file (),NFMfmu_copy_file();
     char *fname="NFMcopy_in_files";
     

     _NFMdebug ((fname,"Entry: User Id = <%d>\n", user_id));

     if (_NFMdebug_st.NFMdebug_on)
       MEMprint_buffer ("Copy List", *list, _NFMdebug_st.NFMdebug_file);

/*  Commented out by B.W. 1/15/92.  NFMtime_stamp functions are no longer used
     if (_NFMdebug_st.NFMdebug_on)
       NFMtime_stamp_start (_NFMdebug_st.NFMdebug_file);
*/
     
     status = MEMbuild_array (*list);
     if (status != MEM_S_SUCCESS)
      {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",
         NFM_E_MEM));
         return (NFM_E_MEM);
      }

     column = (char **) (*list) -> column_ptr;
     data   = (char **) (*list) -> data_ptr;

     i = -1; j = -1; k = -1; l = -1; m = -1; n = -1;
     o = -1; p = -1; q = -1; r = -1; s = -1; t = -1;

     for (y = 0; y < (*list) -> columns; ++y)
      {
              if (! strcmp (column [y], "n_sano"))       i = y;
         else if (! strcmp (column [y], "n_nodename"))   j = y;
         else if (! strcmp (column [y], "n_username"))   k = y;
         else if (! strcmp (column [y], "n_passwd"))     l = y;
         else if (! strcmp (column [y], "n_tcpip"))      m = y;
         else if (! strcmp (column [y], "n_xns"))        n = y;
         else if (! strcmp (column [y], "n_decnet"))     o = y;
         else if (! strcmp (column [y], "n_pathname"))   p = y;
         else if (! strcmp (column [y], "n_machid"))     q = y;
         else if (! strcmp (column [y], "n_opsys"))      r = y;
         else if (! strcmp (column [y], "n_cifilesize")) s = y;
         else if (! strcmp (column [y], "n_status"))     t = y;
      }

     if (i < 0 || j < 0 || k < 0 || l < 0 || 
         m < 0 || n < 0 || o < 0 || p < 0 ||
         q < 0 || r < 0 || s < 0 || t < 0)
      {
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug( (fname," Corrupted Buffers : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
      }

     for (x = 0; x < (*list) -> rows; ++x)
      {
        count = (*list) -> columns * x;

        if ((! strcmp (data [count + t], "copy"))  &&
            (! strcmp (data [count + s], "-1")))
         {
                 if (! strcmp (data [count + m], "Y"))   protocol = NET_TCP;
            else if (! strcmp (data [count + n], "Y"))   protocol = NET_XNS; /* VAX - IGI */
            else                                         protocol = NULL;

            status = NFMget_sa_no_buffer (user_id, atol (data [count + i]), 
                     &sa_list);
            if (status != NFM_S_SUCCESS)
             {
               MEMclose (&sa_list);
               _NFMdebug ((fname,"SA Buff Info : status = <0x%.8x>\n",
               status));
               return (status);
             }

            status = MEMappend (*list, sa_list);
/*          if (status !=  NFM_S_SUCCESS)  DUR 1/6/91 */
            if (status !=  MEM_S_SUCCESS)
             {
               MEMclose (&sa_list);
           	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug( (fname,"MEM Append : status = <0x%.8x>\n", NFM_E_MEM));
               return (NFM_E_MEM);
             }

            /* Comparision with UNIX added for SUN - SSRS - 7/12/93 */
            if ((! strcmp (data [count + q], "CLIX")) ||
                (! strcmp (data [count + q], "UNIX"))   )
             {
               status = NFMcl_copy_file (data [count + j], data [count + k],
                        data [count + l], protocol, sa_list, &trans_list);
               if (status != NFM_S_SUCCESS)
                {
                   MEMclose (&sa_list);
                   MEMclose (&trans_list);
           	   ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
                   _NFMdebug ((fname," Copy File : status = <0x%.8x>\n",
                   NFM_E_CORRUPTED_BUFFERS));
                   return (NFM_E_CORRUPTED_BUFFERS);
                }
             }
            else   if((! strcmp (data [count + q], "VAX")) && 
                      (protocol == NET_XNS))  /* VAX - IGI */
	     {
               status = NFMfmu_copy_file (data [count + j], data [count + k],
                        data [count + l], sa_list, &trans_list);
               if (status != NFM_S_SUCCESS)
                {
                   MEMclose (&sa_list);
                   MEMclose (&trans_list);
                   ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
                   _NFMdebug ((fname,"FMU Copy File : status = <0x%.8x>\n",
                   NFM_E_CORRUPTED_BUFFERS));
                   return (NFM_E_CORRUPTED_BUFFERS);
                }
             }
            else
             {
               status = NFMftp_copy_file (data [count + j], data [count + k],
                        data [count + l], sa_list, &trans_list);
               if (status != NFM_S_SUCCESS)
                {
                   MEMclose (&sa_list);
                   MEMclose (&trans_list);
                   /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
                   _NFMdebug ((fname,"FTP: Copy File : status = <0x%.8x>\n",
                   NFM_E_CORRUPTED_BUFFERS));
                   return (NFM_E_CORRUPTED_BUFFERS);
                }
             }

            status = MEMclose (&sa_list);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&trans_list);
               /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug( (fname,"MEM Close : status = <0x%.8x>\n",
               NFM_E_MEM));
               return (NFM_E_MEM);
             }

            status = MEMbuild_array (trans_list);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&trans_list);
               /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",
               NFM_E_MEM));
               return (NFM_E_MEM);
             }

            if ((*list) -> rows != trans_list -> rows)
             {
               MEMclose (&trans_list);
               /* status = NFMerror (NFM_E_FILE_IN_TRANSFER); */
           status = ERRload_struct (NFM, NFM_E_FILE_IN_TRANSFER, "", NULL);
               _NFMdebug( (fname," File Copy Trans : status = <0x%.8x>\n",
               NFM_E_FILE_IN_TRANSFER));
               return (NFM_E_FILE_IN_TRANSFER);
             }

           status = MEMclose (list);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (&trans_list);
              /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname,"MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
               return (NFM_E_MEM);
             }

            status = MEMsplit_copy_buffer (trans_list, list, 0);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&trans_list);
               /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug( (fname,"MEM Copy : status = <0x%.8x>\n", NFM_E_MEM));
               return (NFM_E_MEM);
             }
                        
            status = MEMclose (&trans_list);
            if (status != MEM_S_SUCCESS)
             {
               /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname," MEM Close : status = <0x%.8x>\n",
               NFM_E_MEM));
               return (NFM_E_MEM);
             }

            status = MEMbuild_array (*list);
            if (status != MEM_S_SUCCESS)
             {
               /* status = NFMerror (NFM_E_MEM); */
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n",
               NFM_E_MEM));
               return (NFM_E_MEM);     
             }

            column = (char **) (*list) -> column_ptr;
            data   = (char **) (*list) -> data_ptr;
          }
      }

/*  Commented out by B.W. 1/15/92.  NFMtime_stamp functions are no longer used
     if (_NFMdebug_st.NFMdebug_on)
       NFMtime_stamp_stop ("COPY FILE", _NFMdebug_st.NFMdebug_file);
*/

     if (_NFMdebug_st.NFMdebug_on)
       MEMprint_buffer ("Copy List", *list, _NFMdebug_st.NFMdebug_file);
     
     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }

 long NFMftp_copy_file (node_name, user_name, passwd, 
                        in_list, out_list)
   char     *node_name, *user_name, *passwd;
   MEMptr   in_list, *out_list;
   {
      long    status, atol ();
      char    **column, **data, **column2, **data2;
      long    x, y, count;
      long    i1, j1, k1, l1, m1, n1, o1;
      long    p1, q1, r1, s1, t1, u1, v1, w1;
      long    i2, m2, n2, o2, p2, q2, r2;
      char    size_str [50], f_temp [100], dec_pass [50];
      char    f_script [100], f_stderr [100], f_stdout [100];
      char    src_file [512], dst_file [512], str [1024];
      MEMptr  sa_list = NULL;
      FILE    *infile, *fopen ();
      struct  stat fbuff;
      char *fname="NFMftp_copy_file";

      _NFMdebug((fname,"Entry: node_name <%s> user_name <%s> passwd <%s>\n",node_name,user_name,passwd));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug( (fname,"MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug((fname,"MEM Reset No : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug( (fname,"MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
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
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
       }

      sprintf (f_script,  "/usr/tmp/%s",  mktemp ("NFMdel1XXXXXXX"));
      sprintf (f_stderr,  "/usr/tmp/%s",  mktemp ("NFMdel2XXXXXXX"));
      sprintf (f_stdout,  "/usr/tmp/%s",  mktemp ("NFMdel3XXXXXXX"));
      sprintf (f_temp,    "/usr/tmp/%s",  mktemp ("NFMdel4XXXXXXX"));

      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&sa_list);
	 ERRload_struct(NFM,NFM_E_NET_DECRYPT,"%s","Password");
         _NFMdebug( (fname,"Dec Passwd : status = <0x%.8x>\n", status));
         return (NFM_E_NET_DECRYPT);  
       }

      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if (! strcmp (data [count + i1], data2 [i2]))
          {
            if ((! strcmp (data [count + w1], "copy")) &&
                (atol (data [count + u1]) == -1))
             {
               status = NFMappend_path_file (data2 [q2],
                        data2 [m2], data [count + t1], src_file);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
                  return (status);
                }

               status = NFMappend_path_file (data2 [q2],
                        data2 [m2], data [count + s1], dst_file);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
                  return (status);
                }

               infile = fopen (f_script, "w");
               if (! infile)
                {
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_OPEN_FILE); */
           status = ERRload_struct (NFM, NFM_E_OPEN_FILE, "", NULL);
                  _NFMdebug( (fname," Open File : status = <0x%.8x>\n", NFM_E_OPEN_FILE));
                  return (NFM_E_OPEN_FILE);
                }

               sprintf (str, "user %s %s\nbinary\nget %s %s\nquit\n",
                        user_name, passwd, src_file, f_temp);

               _NFMdebug((fname,"COPY SRCIPT : <%s>\n", str));

               status = fwrite (str, sizeof (char), strlen (str), infile);
               if (status != strlen (str))
                {
                  fclose (infile);
                  unlink (f_script);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_WRITE_FILE); */
           status = ERRload_struct (NFM, NFM_E_WRITE_FILE, "", NULL);
                  _NFMdebug((fname, "Write To File : status = <0x%.8x>\n",
                  NFM_E_WRITE_FILE));
                  return (NFM_E_WRITE_FILE);  
                }

               fclose (infile);

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
                  unlink (f_temp);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_STAT); */
           status = ERRload_struct (NFM, NFM_E_STAT, "", NULL);
                  _NFMdebug( (fname,"Stat Failed : status = <0x%.8x>\n", NFM_E_STAT));
                  return (NFM_E_STAT);
                }

               if (fbuff.st_size)
                {
                  unlink (f_stderr);
                  unlink (f_temp);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_FTP_REC_FAILED); */
           status = ERRload_struct (NFM, NFM_E_FTP_REC_FAILED, "", NULL);
                  _NFMdebug((fname,"FTP CPY : FTP Rec : status = <0x%.8x>\n", NFM_E_FTP_REC_FAILED));
                  return (NFM_E_FTP_REC_FAILED);
                }

               unlink (f_stderr);

/* 12/9/92 - KT - Replace 'Stat' with 'stat'
               status = Stat (f_temp, &fbuff);
*/
               status = stat (f_temp, &fbuff);
               if (status) /* OK */
                {
                  unlink (f_temp);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_STAT); */
           status = ERRload_struct (NFM, NFM_E_STAT, "", NULL);
                  _NFMdebug ((fname,"Stat Failed : status = <0x%.8x>\n", NFM_E_STAT));
                  return (NFM_E_STAT);
                }

               sprintf (size_str, "%d", fbuff.st_size);

               infile = fopen (f_script, "w");
               if (! infile)
                {
                  unlink (f_temp);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_OPEN_FILE); */
           status = ERRload_struct (NFM, NFM_E_OPEN_FILE, "", NULL);
                  _NFMdebug((fname," Open File : status = <0x%.8x>\n", NFM_E_OPEN_FILE));
                  return (NFM_E_OPEN_FILE);
                }

               sprintf (str, "user %s %s\nbinary\nput %s %s\nquit\n",
                        user_name, passwd, f_temp, dst_file);

               _NFMdebug((fname,"COPY SRCIPT : <%s>\n", str));

               status = fwrite (str, sizeof (char), strlen (str), infile);
               if (status != strlen (str))
                {
                  fclose (infile);
                  unlink (f_temp);
                  unlink (f_script);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_WRITE_FILE); */
           status = ERRload_struct (NFM, NFM_E_WRITE_FILE, "", NULL);
                  _NFMdebug((fname," Write To File : status = <0x%.8x>\n",
                  NFM_E_WRITE_FILE));
                  return (NFM_E_WRITE_FILE);  
                }

               fclose (infile);

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
                  unlink (f_temp);
                  unlink (f_stderr);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_STAT); */
           status = ERRload_struct (NFM, NFM_E_STAT, "", NULL);
                  _NFMdebug((fname,"FTP CPY : Stat Failed : status = <0x%.8x>\n", NFM_E_STAT));
                  return (NFM_E_STAT);
                }

               if (fbuff.st_size)
                {
                  unlink (f_stderr);
                  unlink (f_temp);
                  MEMclose (&sa_list);
                  /* status = NFMerror (NFM_E_FTP_SEND_FAILED); */
           status = ERRload_struct (NFM, NFM_E_FTP_SEND_FAILED, "", NULL);
                  _NFMdebug((fname," FTP Send : status = <0x%.8x>\n", NFM_E_FTP_SEND_FAILED));
                  return (NFM_E_FTP_SEND_FAILED);
                }

               unlink (f_temp);

               status = MEMwrite_data (*out_list, size_str, x + 1, u1 + 1);
               if (status != MEM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  /* status = NFMerror (status); */
           status = ERRload_struct (NFM, status, "", NULL);
                  _NFMdebug((fname,"MEM Wr Data : status = <0x%.8x>\n",
                  status));
                  return (status);
                }
             }
          }
       }
 
      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
          status = NFM_E_MEM ;
           status = ERRload_struct (NFM, status, "", NULL);
         _NFMdebug((fname,"MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      

      _NFMdebug((fname," SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);     
   }
 long NFMfmu_copy_file (node_name, user_name, passwd, 
                        in_list, out_list)
   char     *node_name, *user_name, *passwd;
   MEMptr   in_list, *out_list;
   {
      long    status, atol ();
      char    **column, **data, **column2, **data2;
      long    x, y, count;
      long    i1, j1, k1, l1, m1, n1, o1;
      long    p1, q1, r1, s1, t1, u1, v1, w1;
      long    i2, m2, n2, o2, p2, q2, r2;
      int file_size ;
      char *attribute="";
      char    size_str [50], f_temp [100], dec_pass [50];
      char    src_file [512], dst_file [512];
      MEMptr  sa_list = NULL;
      char *fname="NFMfmu_copy_file";

      _NFMdebug((fname,"Entry: node_name <%s> user_name <%s> passwd <%s>\n",node_name,user_name,passwd));

      status = MEMbuild_array (in_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, &sa_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug( (fname,"MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMreset_buffer_no (in_list, 2);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug((fname,"MEM Reset No : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMsplit_copy_buffer (in_list, out_list, 0);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug( (fname,"MEM Copy : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (sa_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (*out_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&sa_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
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
         /* status = NFMerror (NFM_E_CORRUPTED_BUFFERS); */
           status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS);
       }


      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&sa_list);
	 ERRload_struct(NFM,NFM_E_NET_DECRYPT,"%s","Password");
         _NFMdebug( (fname,"Dec Passwd : status = <0x%.8x>\n", status));
         return (NFM_E_NET_DECRYPT);  
       }


      for (x = 0; x < (*out_list) -> rows; ++x)
       {
         count = (*out_list) -> columns * x;

         if (! strcmp (data [count + i1], data2 [i2]))
          {
            if ((! strcmp (data [count + w1], "copy")) &&
                (atol (data [count + u1]) == -1))
             {
               status = NFMappend_path_file (data2 [q2],
                        data2 [m2], data [count + t1], src_file);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
                  return (status);
                }

               status = NFMappend_path_file (data2 [q2],
                        data2 [m2], data [count + s1], dst_file);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
                  return (status);
                }
	       status = NETfmu_con_receive(node_name,user_name,passwd,src_file,f_temp,attribute,&file_size);
	       if(status != NET_S_SUCCESS)
                {
                  unlink (f_temp);
                  MEMclose (&sa_list);
           	  ERRload_struct (NFM, NFM_E_FAILURE, "%s%x", "NETfmu_con_receive",status);
                  _NFMdebug ((fname,"NETfmu_con_receive Failed : status = <0x%.8x>\n", status));
                  return (NFM_E_FAILURE);
                }

               sprintf (size_str, "%d", file_size);
	       status = NETfmu_con_send(node_name,user_name,passwd,src_file,f_temp,attribute,&file_size);
	       if(status != NET_S_SUCCESS)
                {
                  unlink (f_temp);
                  MEMclose (&sa_list);
           	  ERRload_struct (NFM, NFM_E_FAILURE, "%s%x", "NETfmu_con_send",status);
                  _NFMdebug ((fname,"NETfmu_con_send Failed : status = <0x%.8x>\n", status));
                  return (NFM_E_FAILURE);
                }

               status = MEMwrite_data (*out_list, size_str, x + 1, u1 + 1);
               if (status != MEM_S_SUCCESS)
                {
                  MEMclose (&sa_list);
                  /* status = NFMerror (status); */
           status = ERRload_struct (NFM, status, "", NULL);
                  _NFMdebug((fname,"MEM Wr Data : status = <0x%.8x>\n",
                  status));
                  return (status);
                }
             }
          }
       }
 
      status = MEMclose (&sa_list);
      if (status != MEM_S_SUCCESS)
       {
          status = NFM_E_MEM ;
           status = ERRload_struct (NFM, status, "", NULL);
         _NFMdebug((fname,"MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }      

      _NFMdebug((fname," SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);     
}
