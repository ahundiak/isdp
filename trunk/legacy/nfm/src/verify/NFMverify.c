#include "machine.h"
#include <stdio.h>
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMstruct.h"

#define NFM_TEMP_ITEMNO 0
#define NFM_TEMP_VERSIONLIMIT 1
#define NFM_TEMP_ITEMNUM 0
#define NFM_TEMP_CIFILENAME 1
#define NFM_TEMP_FILEVERSION 2
#define NFM_TEMP_FILENO 3
#define NFM_TEMP_ITEMNAME 0
#define NFM_TEMP_ITEMREV 1
#define NFM_TEMP_ARCHIVESTATE 2
#define NFM_DEFAULT_FILE "/dev/console"
#define NFM_TEMP_DASH "---------                               -------------       ---------\n"
#define NFM_TEMP_ITEM_NAME "ITEM NAME                               "
#define NFM_TEMP_ITEM_REV  "ITEM REVISION       "
#define NFM_TEMP_BACKED_UP "BACKED UP"
#define NFM_TEMP_BLANK_40  "                                        "
#define NFM_TEMP_BLANK_20  "                    "

extern long NFMuserid;

extern char *optarg;
main (argc, argv)
int argc;
char *argv[];
{
  char *fname="NFMverify";
  char sql_str[1024];
  char c;
  char server[30], environment[30];
  char user[30], upasswd[30];
  char output_file[40]; 
  char debug_file[40];
  char **cat_data, **item_data, **file_data, **data, **data2;
  char item_no[20], item_name[20], item_rev[20], version_limit[20], 
       item_num[20], archive_state[20],
       file_no[20], file_version[20], ci_filename[20];
  char filename[20];
  char buf_str[300], temp_str[30];
  int cat_count, item_count, file_count, count;
  int x, y, z;
  long status;
  long user_id, table_no, ftable_no;
  long set_d=0;
  MEMptr login_attr=NULL, login_data=NULL, login_value=NULL, login_wf=NULL;
  MEMptr cat_list=NULL, item_list=NULL, file_list=NULL, list=NULL;
  MEMptr list2=NULL;
  FILE *f;
 

  strcpy (user, "\0"); strcpy (upasswd, "\0");
  strcpy (server, "\0"); strcpy (environment, "\0");
  strcpy (debug_file, NFM_DEFAULT_FILE);

  while ((c = getopt (argc, argv, "rnads:e:p:u:o:")) != -1)
  {
    switch (c)
    {
      case 's':
        strcpy (server, optarg);
        _NFMdebug ((fname, "turned %c, server = %s\n", c, server));
        break;
      case 'e':
        sprintf (environment, "nfme_%s",optarg);
        _NFMdebug ((fname, "turned %c, server = %s\n", c, environment));
        break;
      case 'u':
        strcpy (user, optarg);
        _NFMdebug ((fname, "turned %c database = %s\n", c, user));
        break;
      case 'p':
        strcpy (upasswd, optarg);
        _NFMdebug ((fname, "turned %c database password = %s\n", c, upasswd));
        break;
      case 'o':
        strcpy (debug_file, optarg);
        strcpy (_NFMdebug_st.NFMdebug_file, debug_file);
        strcpy (_NFMdebug_st.SQLdebug_file, debug_file);
        _NFMdebug ((fname, "turned %c debug_file %s\n", c, optarg));
        break;
      case 'd':
        set_d = 1;
        _NFMdebug_st.NFMdebug_on = 1; 
        _NFMdebug_st.SQLdebug_on = 1; 
        strcpy (_NFMdebug_st.NFMdebug_file, debug_file);
        strcpy (_NFMdebug_st.SQLdebug_file, debug_file);
        _NFMdebug ((fname, "turned %c\n", c));
        break;
      default:
        printf ("Usage: Nfmverify -s server -e environment -u username \n\
                        -p password [-d -o debug_output]\n");
        return (NFM_E_FAILURE);
    }
  }

  strcpy (output_file, "/usr/tmp/NFMverify");
  if ((f = fopen (output_file, "w")) == (FILE *) NULL)
  {
    _NFMdebug ((fname, "failed to open %s to write\n", output_file));
    return (NFM_E_FAILURE);
  }

  if ( strlen (environment) && strlen(user) && strlen (upasswd))
  {
    _NFMdebug ((fname, "Login with server %s environment %s user %s\n",
                server, environment, user));
  }
  else
  {
    if (set_d)
    {
      _NFMdebug ((fname, "Given information is not complete\n\
                  server [%s] environment [%s] user [%s] password [%s]\n",
                  server, environment, user, upasswd));
    }
    else
    {
      printf ("Given information is not complete\n\
               server [%s] environment [%s] user [%s] password [%s]\n",
               server, environment, user, upasswd);
    }
    return (NFM_E_FAILURE);
  }

  status = NFMlog_in (user, upasswd, environment, "NFM");
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMlogin: 0x%.8x\n", status));
    return (status);
  }

  strcpy (sql_str, "select n_catalogname from nfmcatalogs");

  status = SQLquery (sql_str, &cat_list, MEM_SIZE);

  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ((fname, "SQLquery %s: 0x%.8x\n", sql_str, status));
    return (status);
  }

  status = MEMbuild_array (cat_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array: 0x%.8x\n", status));
    return (status);
  }

  cat_data = (char **) cat_list->data_ptr;
  for (x = 0; x < cat_list->rows; x ++)
  {
    cat_count = cat_list->columns * x;
    _NFMdebug ((fname, "Process catalog %s\n", cat_data[cat_count]));
    if (!strcmp (cat_data[cat_count], "nfmsyscat"))
      continue;
    sprintf (buf_str, "\nREPORT FOR CATALOG <%s>\n\n",
             cat_data[cat_count]);
    fputs (buf_str, f);
    sprintf (buf_str, "%s%s%s\n", NFM_TEMP_ITEM_NAME,
                      NFM_TEMP_ITEM_REV, NFM_TEMP_BACKED_UP);
    fputs (buf_str, f);
    strcpy (buf_str, NFM_TEMP_DASH);
    fputs (buf_str, f);
    
    sprintf (sql_str, "%s %s '%s' %s 'f_%s'",
             "select n_tablename, n_tableno from nfmtables where",
             "n_tablename =", cat_data[cat_count], "or n_tablename =",
             cat_data[cat_count]);
    status = SQLquery (sql_str, &list, MEM_SIZE);
    if (status !=  SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery %s: 0x%.8x\n", status));
      return (status);
    }
    status = MEMbuild_array (list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array: 0x%.8x\n", status));
      return (status);
    }

    data = (char **) list->data_ptr;
    for (y = 0; y < list->rows; y ++)
    {
      count = list->columns * y;
      if (strncmp (data[count], "f_", 2))
        table_no = atol (data[count+1]);
      else
        ftable_no = atol (data[count+1]);
    }

    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose: 0x%.8x\n", status));
      return (status);
    }

    sprintf (sql_str, 
             "%s %d %s %d %s %s %s %s %s",
             "select n_name from nfmattributes where (n_tableno =",
             table_no, "or n_tableno =", ftable_no, 
             ") and (n_name = 'n_itemno' or n_name = 'n_itemname' or",
             "n_name = 'n_itemrev' or n_name = 'n_fileno' or",
             "n_name = 'n_versionlimit' or n_name = 'n_itemnum' or ",
             "n_name = 'n_cifilename' or n_name = 'n_fileversion' or",
             "n_name = 'n_archivestate')");

    status = SQLquery (sql_str, &list, MEM_SIZE);
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery %s: 0x%.8x\n", sql_str, status));
      return (status);
    }

    status = MEMbuild_array (list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array: 0x%.8x\n", status));
      return (status);
    }
   
    data = (char **) list->data_ptr;

    for (y = 0; y < list->rows; y++)
    {
      count = list->columns * y;
      _NFMdebug ((fname, "data[%d] %s\n", count, data[count]));
      if (!strcmp (data[count], "n_itemname"))
        strcpy (item_name, data[count]);
      else if (!strcmp (data[count], "n_itemrev"))
        strcpy (item_rev, data[count]);
      else if (!strcmp (data[count], "n_itemnum"))
        strcpy (item_num, data[count]);
      else if (!strcmp (data[count], "n_itemno"))
        strcpy (item_no, data[count]);
      else if (!strcmp (data[count], "n_fileno"))
        strcpy (file_no, data[count]);
      else if (!strcmp (data[count], "n_versionlimit"))
        strcpy (version_limit, data[count+1]);
      else if (!strcmp (data[count], "n_cifilename"))
        strcpy (ci_filename, data[count]);
      else if (!strcmp (data[count], "n_fileversion"))
        strcpy (file_version, data[count]);
      else if (!strcmp (data[count], "n_archivestate"))
        strcpy (archive_state, data[count]);
    }

    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose: 0x%.8x\n", status));
      return (status);
    }
    
    sprintf (sql_str, "%s %s, %s, %s %s %s %s %s %s %s %s f_%s %s",
             "select", item_name, item_rev, archive_state, "from", 
             cat_data[cat_count],
              "where", item_no, "not in (select", item_num, "from",
              cat_data[cat_count], ")"); 
    status = SQLquery (sql_str, &item_list, MEM_SIZE);
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, 
            "No item in this catalog is without the record\n"));
      sprintf (buf_str, "\n\nEND OF REPORT <%s>\n", cat_data[cat_count]);
      fputs (buf_str, f );
      continue;
    }
    else if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery %s: 0x%.8x\n", sql_str, status));
      return (status);
    }

    status = MEMbuild_array (item_list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array: 0x%.8x\n", status));
      return (status);
    }

    item_data = (char **) item_list->data_ptr;
    for (y = 0; y < item_list->rows; y++)
    {
      item_count = item_list->columns * y;
      strcpy (buf_str, item_data[item_count+NFM_TEMP_ITEMNAME]);
      for (z = strlen (item_data[item_count+NFM_TEMP_ITEMNAME]); z < 40; z++)
        strcat (buf_str, " ");
      strcat (buf_str, item_data[item_count+NFM_TEMP_ITEMREV]);
      for (z = strlen (item_data[item_count+NFM_TEMP_ITEMREV]); z < 20; z++)
        strcat (buf_str, " ");
      if (strcmp (item_data[item_count+NFM_TEMP_ARCHIVESTATE], "B"))
      {
        strcpy (temp_str, "  N");
      }
      else 
      {
        strcpy (temp_str, "  Y");
      }
      strcat (buf_str, temp_str);
      strcat (buf_str, "\n");
      fputs (buf_str, f);
    }

    status = MEMclose (&item_list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose: 0x%.8x\n", status));
      return (status);
    }
    sprintf (buf_str, "\n\nEND OF REPORT <%s>\n\n", cat_data[cat_count]);
    fputs (buf_str, f);
  }

  _NFMdebug ((fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
