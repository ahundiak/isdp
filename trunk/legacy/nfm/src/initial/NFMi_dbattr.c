#include "machine.h"
#include "INIT.h"

 long NFMi_init_attr (node_attr, node_data, st_attr, st_data,
                      user_attr, user_data, db_attr, db_data,
		      db2_attr, db2_data, os_attr, os_data)
   MEMptr   *node_attr, *node_data, *st_attr, *st_data;
   MEMptr   *user_attr, *user_data, *db_attr, *db_data;
   MEMptr   *db2_attr, *db2_data, *os_attr, *os_data;
   {
     static char *fname = "NFMi_init_attr" ;
     long    status, user_id ;
     MEMptr value_list = NULL ;
     long    NFMi_query_db ();
     long    NFMi_query_db2 () ;
     long    NFMi_query_node ();
     long    NFMi_query_storage_area () ;
     long    NFMi_query_user();
     long    NFMi_query_os();


      _NFMdebug ((fname, "INIT ATTR : %s\n", ""));

      status = NFMi_query_node (node_attr, node_data);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (node_attr);
         MEMclose (node_data);
         _NFMdebug ((fname, "Qry Node Attr : status =  <0x%.8x> \n", status));
         return (status);
       }

      status = NFMi_query_storage_area (st_attr, st_data);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (node_attr);
         MEMclose (node_data);
         MEMclose (st_attr);
         MEMclose (st_data);
         _NFMdebug ((fname, "Qry ST Attr : status =  <0x%.8x> \n", status));
         return (status);
       }

      status = NFMi_query_user (user_attr, user_data);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (node_attr);
         MEMclose (node_data);
         MEMclose (st_attr);
         MEMclose (st_data);
         MEMclose (user_attr);
         MEMclose (user_data);
         _NFMdebug ((fname, "Qry USER Attr : status =  <0x%.8x> \n", status));
         return (status);
       }

      status = NFMi_query_db (db_attr, db_data);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (node_attr);
         MEMclose (node_data);
         MEMclose (st_attr);
         MEMclose (st_data);
         MEMclose (user_attr);
         MEMclose (user_data);
         MEMclose (db_attr);
         MEMclose (db_data);
         _NFMdebug ((fname, "Qry DB Attr : status =  <0x%.8x> \n", status));
         return (status);
       }

      status = NFMi_query_db2 (db2_attr, db2_data);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (node_attr);
         MEMclose (node_data);
         MEMclose (st_attr);
         MEMclose (st_data);
         MEMclose (user_attr);
         MEMclose (user_data);
         MEMclose (db_attr);
         MEMclose (db_data);
	 MEMclose (db2_attr);
	 MEMclose (db2_data) ;
         _NFMdebug ((fname, "Qry DB Attr : status =  <0x%.8x> \n", status));
         return (status);
       }

      status = NFMi_query_os (os_attr, os_data);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (node_attr);
         MEMclose (node_data);
         MEMclose (st_attr);
         MEMclose (st_data);
         MEMclose (user_attr);
         MEMclose (user_data);
         MEMclose (db_attr);
         MEMclose (db_data);
	 MEMclose (db2_attr);
	 MEMclose (db2_data) ;
	 MEMclose (os_attr);
	 MEMclose (os_data) ;
         _NFMdebug ((fname, "Qry DB Attr : status =  <0x%.8x> \n", status));
         return (status);
       }
      _NFMdebug ((fname, "SUCCESSFUL\n")) ;

      return (NFM_S_SUCCESS);
   }


 long NFMi_query_db (attr_list, data_list)
   MEMptr  *attr_list, *data_list;
   {
     static char *fname = "NFMi_query_db" ;
      long     status;
      long      x, y, count, a = -1, b = -1;
      char     **column, **data;
      char     *sql_str;

      _NFMdebug ((fname, "QRY DB : <%s>\n", ""));

      status = NFMi_template (attr_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", status));
         return (status);
       }

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }

       for (x = 0; x < 11; ++x) 
       {
        sql_str [0] = 0;

        switch (x)
         {
          case 0 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_srvname", "char(9)", "Server Name", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
	   0,0,0,0);
          break;

          case 1 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_envname", "char(9)", "Environment Name", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x,
	  0,0,0,0);
          break;

          case 2 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_rdbmstype", "char(10)", "RDBMS Type",
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x,
	  0,0,0,0);
          break;

          case 3 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_rdbmshome", "char(50)", "RDBMS Home Directory",
          "NFM", "Y", "Y", "N", "N", "Y", "N", "N", x, 
	  0,0,0,0);
          break;

          case 4 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_risdb", "char(50)", "DB Path (PATH w/SE)",
          "NFM", "Y", "Y", "N", "N", "Y", "N", "N", x, 
	  0,0,0,0);
          break;

          case 5 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_envnode", "char(50)", "Environment Node", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 6 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_srvnetwork", "char(3)", "Environment Network", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 7 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_schname", "char(18)", "Schema Name",
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 8 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_schpwd", "char(18)", "Schema Password", 
          "NFM", "N", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 9 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_env_usr", "char(14)", "Environment Username", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 10 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_env_usr_pwd", "char(14)", "Env User Password", 
          "NFM", "N", "Y", "N", "N", "N", "N", "N", x, 
	  0,0,0,0);
          break;

         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           _NFMdebug ((fname, "MEM Write (attr_list): status = <0x%.8x>\n",
		     status));
           return (status);
         }
       }
      free (sql_str);

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (status);         
       }

      data   = (char **) (*attr_list) -> data_ptr;
      column = (char **) (*attr_list) -> column_ptr;

      for (y = 0; y < (*attr_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      if (a < 0 || b < 0)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Bad Buffers : status = <0x%.8x>\n", status));
         return (status);         
       }

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (status);         
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);         
       }
      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
          count = (*attr_list) -> columns * x;

          status = MEMwrite_format (*data_list,
                   data [count + a], data [count + b]);
          if (status != MEM_S_SUCCESS)
           {
              free (sql_str);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
              status));
              return (status);
           }

          strcat (sql_str, "\1");
	}

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      free (sql_str); 
      
      _NFMdebug ((fname, "SUCCESSFUL\n"));
      return (NFM_S_SUCCESS);
   }


 long NFMi_query_db2 (attr_list, data_list)
   MEMptr  *attr_list, *data_list;
   {
     static char *fname = "NFMi_query_db2" ;
      long     status;
      long      x, y, count, a = -1, b = -1;
      char     **column, **data;
      char     *sql_str;

      _NFMdebug ((fname, "QRY DB : <%s>\n", ""));

      status = NFMi_template (attr_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", status));
         return (status);
       }

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }

      for (x = 0; x < 8 ; ++x)
       {
        sql_str [0] = 0;

        switch (x)
         {
          case 0 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "ris_lu_name", "char(15)", "RIS LU Name", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 1 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "host_lu_name", "char(15)", "Host LU Name", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 2 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "host_prog_name", "char(15)", "Host Program Name", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 3 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "lu62_mode_name", "char(15)", "LU62 Mode Name", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 4 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "arch", "char(15)", "Architecture", 
          "NFM", "Y", "N", "N", "N", "N","N", "N", x, 
          0,0,0,0);
          break;

          case 5 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "os", "char(15)", "Operating System", 
          "NFM", "Y", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 6 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "env", "char(15)", "DB2 Environment",
          "NFM", "Y", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 7 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "db2_net_protl", "char(15)", "DB2 Net Protocol", 
          "NFM", "Y", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           _NFMdebug ((fname, "MEM Write (attr_list): status = <0x%.8x>\n",
		     status));
           return (status);
         }
       }

      free (sql_str);

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (status);         
       }

      data   = (char **) (*attr_list) -> data_ptr;
      column = (char **) (*attr_list) -> column_ptr;

      for (y = 0; y < (*attr_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      if (a < 0 || b < 0)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Bad Buffers : status = <0x%.8x>\n", status));
         return (status);         
       }

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (status);         
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);         
       }
      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
          count = (*attr_list) -> columns * x;

          status = MEMwrite_format (*data_list,
                   data [count + a], data [count + b]);
          if (status != MEM_S_SUCCESS)
           {
              free (sql_str);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
              status));
              return (status);
           }

          strcat (sql_str, "\1");
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      free (sql_str); 
      
      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }   

 long NFMi_query_node (attr_list, data_list)
   MEMptr  *attr_list, *data_list;
   {
     static char *fname = "NFMi_query_node" ;
      long     status;
      long      x, y, count, a = -1, b = -1;
      char     **column, **data;
      char     *sql_str;

      _NFMdebug ((fname, "NODE TABLE : %s\n", ""));

      status = NFMi_template (attr_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Def Tab Attr : status =  <0x%.8x> \n", status));
         return (status);
       }

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Def Tab Attr : status =  <0x%.8x> \n", 
                    NFM_E_MALLOC));
         return ( NFM_E_MALLOC);
       }

      for (x = 0; x < 10; ++x)
       {
        sql_str [0] = 0;

        switch (x)
         {
          case 0 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_nodeno", "integer", "Node Number", 
          "NFM", "N", "N", "N", "N", "N", "N", "N", x,
	  0,0,0,0);
          break;

          case 1 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_nodename", "char(30)", "Node Name", 
          "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 2 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_nodedesc", "char(20)", "Node Description",
          "NFM", "Y", "Y", "Y", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;

          case 3 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_tcpip", "char(1)", "TCP/IP", 
          "NFM", "Y", "Y", "Y", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;

          case 4 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_xns", "char(1)", "XNS",
          "NFM", "Y", "Y", "Y", "N", "Y", "N", "N", x, 
          0,0,0,0) ;
          break;

          case 5 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_decnet", "char(1)", "DECNET",
          "NFM", "Y", "Y", "Y", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;


          case 6 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_netware", "char(1)", "NETWARE",
          "NFM", "Y", "Y", "Y", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;

          case 7 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_nfs", "char(1)", "NFS",
          "NFM", "Y", "Y", "Y", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;

          case 8 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_machid", "char(10)", "Machine Type", 
          "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 9 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_opsys", "char(10)", "Operating System", 
          "NFM", "N", "N", "N", "N", "N",  "N", "N", x, 
          0,0,0,0);
          break;
         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           _NFMdebug ((fname, "MEM Write : status =  <0x%.8x> \n", status));
           return (status);
         }
       }

      free (sql_str);

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Build Array : status =  <0x%.8x> \n",
         status));
         return (status);         
       }

      data   = (char **) (*attr_list) -> data_ptr;
      column = (char **) (*attr_list) -> column_ptr;

      for (y = 0; y < (*attr_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      if (a < 0 || b < 0)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Bad Buffers : status =  <0x%.8x> \n", status));
         return (status);         
       }

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Open : status =  <0x%.8x> \n", status));
         return (status);         
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM,NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status =  <0x%.8x> \n",
         NFM_E_MALLOC));
         return (NFM_E_MALLOC);         
       }
      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
          count = (*attr_list) -> columns * x;

          status = MEMwrite_format (*data_list,
                   data [count + a], data [count + b]);
          if (status != MEM_S_SUCCESS)
           {
              free (sql_str);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Wr Format : status =  <0x%.8x> \n",
              status));
              return (status);
           }

          strcat (sql_str, "\1");
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status =  <0x%.8x> \n", status));
         return (status);

       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status =  <0x%.8x> \n", status));
         return (status);
       }

      free (sql_str); 
      
      _NFMdebug ((fname, "SUCCESSFUL : status =  <0x%.8x> \n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }   

 long NFMi_query_storage_area (attr_list, data_list)
   MEMptr  *attr_list, *data_list;
   {
     static char *fname = "NFMi_query_storage_area" ;
      long     status;
      long      x, y, count, a = -1, b = -1;
      char     **column, **data;
      char     *sql_str;

      _NFMdebug ((fname, "DEV TABLE : %s\n", ""));

      status = NFMi_template (attr_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Def Tab Attr : status =  <0x%.8x> \n", status));
         return (status);
       }

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Def Tab Attr : status =  <0x%.8x> \n", 
                   NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }

      for (x = 0; x < 9; ++x)
       {
        sql_str [0] = 0;

        switch (x)
         {
          case 0 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_sano", "integer", "Storage Area Number", 
          "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 1 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_saname", "char(14)", "Storage Area Name", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 2 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_nodeno", "integer", "Node Name", 
          "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 3 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_username", "char(14)", "User Name",
          "NFM", "Y", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 4 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_passwd", "char(14)", "Password", 
          "NFM", "N", "Y", "N", "N", "N","N", "N", x, 
          0,0,0,0);
          break;

          case 5 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_pathname", "char(50)", "Path Name",
          "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 6 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_devicetype", "char(2)", "Device Type",
          "NFM", "N", "N", "N", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;

          case 7 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_nfs", "char(1)", "Mounted via NFS", 
          "NFM", "N", "N", "N", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;

          case 8 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_type", "char(1)", "Type",
          "NFM", "N", "N", "N", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;

         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           _NFMdebug ((fname, "MEM Write : status =  <0x%.8x> \n", status));
           return (status);
         }
       }

      free (sql_str);

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Build Array : status =  <0x%.8x> \n",
         status));
         return (status);         
       }

      data   = (char **) (*attr_list) -> data_ptr;
      column = (char **) (*attr_list) -> column_ptr;

      for (y = 0; y < (*attr_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      if (a < 0 || b < 0)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Bad Buffers : status =  <0x%.8x> \n", status));
         return (status);         
       }

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Open : status =  <0x%.8x> \n", status));
         return (status);         
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status =  <0x%.8x> \n", 
                   NFM_E_MALLOC));
         return (NFM_E_MALLOC);         
       }
      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
          count = (*attr_list) -> columns * x;

          status = MEMwrite_format (*data_list,
                   data [count + a], data [count + b]);
          if (status != MEM_S_SUCCESS)
           {
              free (sql_str);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Wr Format : status =  <0x%.8x> \n",
              status));
              return (status);
           }

          strcat (sql_str, "\1");
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status =  <0x%.8x> \n", status));
         return (status);
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status =  <0x%.8x> \n", status));
         return (status);
       }

      free (sql_str); 
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }   

 long NFMi_query_user (attr_list, data_list)
   MEMptr  *attr_list, *data_list;
   {
     static char *fname = "NFMi_query_user" ;
      long     status;
      long      x, y, count, a = -1, b = -1;
      char     **column, **data;
      char     *sql_str;

      _NFMdebug ((fname, "USER TABLE : <%s>\n", ""));

      status = NFMi_template (attr_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", status));
         return (status);
       }

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", 
                   NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }

      for (x = 0; x < 5; ++x)
       {
        sql_str [0] = 0;

        switch (x)
         {
          case 0 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_userno", "integer", "User Number", 
          "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 1 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_username", "char(14)", "User Name", 
          "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 2 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_passwd", "char(14)", "Password", 
          "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 3 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_userdesc", "char(20)", "Description", 
          "NFM", "Y", "Y", "Y", "N", "Y", "N", "N", x, 
          0,0,0,0);
          break;

          case 4 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_emailaddr", "char(30)", "Mail Address", 
          "NFM", "Y", "Y", "Y", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;
         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (status);
         }
       }

      free (sql_str);

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
         status));
         return (status);         
       }

      data   = (char **) (*attr_list) -> data_ptr;
      column = (char **) (*attr_list) -> column_ptr;

      for (y = 0; y < (*attr_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      if (a < 0 || b < 0)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Bad Buffers : status = <0x%.8x>\n", status));
         return (status);         
       }

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (status);         
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
         NFM_E_MALLOC));
         return (NFM_E_MALLOC);         
       }
      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
          count = (*attr_list) -> columns * x;

          status = MEMwrite_format (*data_list,
                   data [count + a], data [count + b]);
          if (status != MEM_S_SUCCESS)
           {
              free (sql_str);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
              status));
              return (status);
           }

          strcat (sql_str, "\1");
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      free (sql_str); 
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }   

/******  naidu    10 APR 95 ************* */
 long NFMi_query_os (attr_list, data_list)
   MEMptr  *attr_list, *data_list;
   {
     static char *fname = "NFMi_query_os" ;
      long     status;
      long      x, y, count, a = -1, b = -1;
      char     **column, **data;
      char     *sql_str;

      _NFMdebug ((fname, "USER TABLE : <%s>\n", ""));

      status = NFMi_template (attr_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", status));
         return (status);
       }

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", 
                   NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }

      for (x = 0; x < 3; ++x)
       {
        sql_str [0] = 0;

        switch (x)
         {
          case 0 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_osname", "char(20)", "OS Name ", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 1 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_username", "char(14)", "User Name", 
          "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

          case 2 : 
           sprintf (sql_str,
	   "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
          "n_passwd", "char(14)", "Password", 
          "NFM", "N", "Y", "N", "N", "N", "N", "N", x, 
          0,0,0,0);
          break;

         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (status);
         }
       }

      free (sql_str);

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
         status));
         return (status);         
       }

      data   = (char **) (*attr_list) -> data_ptr;
      column = (char **) (*attr_list) -> column_ptr;

      for (y = 0; y < (*attr_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      if (a < 0 || b < 0)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Bad Buffers : status = <0x%.8x>\n", status));
         return (status);         
       }

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (status);         
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         /* status = NFMerror (NFM_E_MALLOC); */
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
         NFM_E_MALLOC));
         return (NFM_E_MALLOC);         
       }
      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
          count = (*attr_list) -> columns * x;

          status = MEMwrite_format (*data_list,
                   data [count + a], data [count + b]);
          if (status != MEM_S_SUCCESS)
           {
              free (sql_str);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
              status));
              return (status);
           }

          strcat (sql_str, "\1");
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      free (sql_str); 
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }   









