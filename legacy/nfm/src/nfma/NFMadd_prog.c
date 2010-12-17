#include "machine.h"
#include "NFMA.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <pwd.h>

extern struct NFMglobal_st NFMglobal;

long NFMadd_program (user_id, sa_name, program_name, program_desc, file_name)
long user_id;
char *sa_name;
char *program_name; 
char *program_desc;
char *file_name;
{
     long	 status;
     long     	 program_no;
     long        table_no;
     char        **data;
     char        new_file_name[14];
     char        dst_file[301];
     char        command[320];
     char        sql_str[1024];
     MEMptr      list = NULL;
     struct passwd *pw_entry;
     struct stat f_buff;
     static char *fname = "NFMadd_program";


     sa_name = sa_name; /* These lines will stop compiler warnings. */
     user_id = user_id;	   

     _NFMdebug ((fname, 
	"Program Name = <%s> : Program Description <%s> : filename <%s>\n", 
		program_name, program_desc, file_name));


/****  Determine if program name already exists in the "nfmprograms" 
       table.  If so, return unsuccessfully. ****/

     sprintf (sql_str,
	"SELECT * FROM NFMPROGRAMS WHERE n_programname = '%s'", program_name);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status == SQL_S_SUCCESS)
     {
         MEMclose (&list);
         _NFMdebug ((fname, "Program <%s> already exists\n", program_name));
         ERRload_struct (NFM, NFM_E_DUP_PROG, "", NULL);
         return(NFM_E_DUP_PROG);
     }
     else if (status != SQL_I_NO_ROWS_FOUND)
     {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname,"SQL Query Syntax : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_QUERY); 

     }
     
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
     {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }

     list = NULL;

/**** Insure that program file exists. ****/
/* KT - 12/7/92 - Replace 'Stat' with 'stat' */
     status = stat (file_name, &f_buff);
     if (status) 
     {
        _NFMdebug ((fname, 
                    "Stat failed : filename <%s> status <%d> errno <%d>\n",
		     file_name,status,errno));
        ERRload_struct(NFM, NFM_E_NO_PROG, "", NULL);
        return (NFM_E_NO_PROG);
     }

/**** Get unique index for program in nfmprograms table. ****/

     status = NFMget_serial_slot(0, "nfmprograms", "n_programno", &program_no);

     if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n", status));
        return (status);
     }

/**** In order to generate a unique NFM filename for this program file, 
      we will need the table number for "nfmprograms". This along with 
      the unique table index will be used in generating the filename. ****/

     sprintf (sql_str,
	"SELECT n_tableno FROM nfmtables WHERE n_tablename = 'nfmprograms'"); 
   
     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
     {
        MEMclose (&list);
        _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
        if (status != SQL_I_NO_ROWS_FOUND)
        {
            status = NFMerror (NFM_E_SQL_QUERY);
        }
        ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL);
        _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
        return (status);
     }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
     {
        MEMclose (&list);
        _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
       return (NFM_E_MEM);
     }

     data = (char **) list->data_ptr;
     table_no = atol (data[0]);
     MEMclose (&list);
     list = NULL;
      
     status = NFMnew_file_name (0, table_no, program_no, new_file_name); 
     if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, "Error generating unique filename\n"));
        return (status);
     }

/**** Copy program file to the SYSTEM storage area. The file in the SYSTEM 
      storage area will use the unique filename previously generated. The 
      original program file will no be deleted.****/

    status = NFMload_user_info ("nfmadmin");
    if (status != NFM_S_SUCCESS)
    {
       _NFMdebug ((fname, "Error loading user info : status <0x%.8x>\n",
		status));
       return (status);
    }

    /* Build path for environment directory */

    pw_entry = getpwnam ("nfmadmin");
    if (pw_entry == NULL)
    {
        _NFMdebug ((fname, "Cannot access local passwd file\n"));
        ERRload_struct(NFM, NFM_E_FAILURE, "%s%s", 
		"Load Program", "Cannot access passwd file");
        return (NFM_E_FAILURE);
    } 

    sprintf (dst_file, "%s/%s/%s/%s", pw_entry->pw_dir, 
		NFMglobal.environment_name, "system",new_file_name);
    
    status = NFM_mkpath (dst_file,0775);
    if (status != NFM_S_SUCCESS)
    {
        _NFMdebug ((fname, "NFM_mkpath failed : path <%s> : status <0x%.8x>\n",
				dst_file, status));
        return (status);
    }

    status = NFMcp(file_name, dst_file);
    if (status != NFM_S_SUCCESS)
    {
       _NFMdebug ((fname, "NFMcp <%s> <%s> Failed : status <%d>\n",
				file_name, dst_file, status));	
       return(status);
    }

/**** Insert program into nfmprograms table. ****/

     sprintf (sql_str,
        "INSERT INTO %s (%s, %s, %s, %s) VALUES ('%s', '%s', %d, '%s')", 
        "NFMPROGRAMS", "n_programname", "n_programdesc", "n_programno",
        "n_programfile", program_name, program_desc, program_no, new_file_name);

     _NFMdebug ((fname, "SQL : <%s>\n", sql_str));

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
     {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));

        sprintf (command, "rm %s",dst_file);

        status = NFMsystem_imm (command);
        if (status != NFM_S_SUCCESS)
        {
           _NFMdebug ((fname, "System Command <%s> Failed : status <%d>\n",
                                                             command, status));
        }
        return (NFM_E_SQL_STMT);
     }

    
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;

     return (NFM_S_SUCCESS);
  }
