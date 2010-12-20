#include "machine.h"
#include "INIT.h"
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>

extern long sqlstatus;
extern MSGptr NFMRmsg_ptr;
char   NFMprint_file[40]   = {"\0"};
char   SCexec[30] = {"Initialize"};
char   SCuser_cmd_file[150] = {"\0"};
char   SCadmin_cmd_file[150] = {"\0"};
extern char NFMCWD[] ;

nfm_init ()
{
  static char *fname = "nfm_init" ;
  long   status;
  int    i, j, k, x ;
  int    tot_data;
  int    pos = 0;
  int    count = 0, status1;
  struct SCcolumn_data_st data;
  struct SCcolumn_data_st SYdata;
  int    FORM_FILLED, break_flag = 0 ;
  NDXptr index ;
  char   **data_ptr, **column_ptr ;
  char   **n_data_ptr, **d_data;
  MEMptr node_attr = NULL, node_data = NULL ;
  MEMptr sa_attr = NULL, sa_data = NULL ;
  MEMptr user_attr = NULL, user_data = NULL ;
  MEMptr db_attr = NULL, db_data = NULL ;
  MEMptr db2_attr = NULL, db2_data = NULL ;
  MEMptr os_attr = NULL, os_data = NULL ;
  char   nodename [50], user_name [50], *c_status, message [512] ;
  char   tmp_str [512], debug_file [512] ;
  char   SYserver[100], SYinterfaces[100];
  struct passwd *pwd_ptr ;
  struct stat buf ;
  int    i_status ;
  char   db_type[50];
  
  if ((NFMRmsg_ptr.debug_on) || (_NFMdebug_st.NFMRdebug_on))
    {
      if (strlen (_NFMdebug_st.NFMRdebug_file))
	strcpy (debug_file, _NFMdebug_st.NFMRdebug_file) ;
      else
	strcpy (debug_file, NFMRmsg_ptr.debug_file) ;
      
      NFMmsg_ptr.debug_on = 1;
      strcpy (NFMmsg_ptr.debug_file, debug_file) ;
      _NFMdebug_st.NFMdebug_on = 1 ;
      strcpy (_NFMdebug_st.NFMdebug_file, debug_file) ;
      _NFMdebug_st.SQLdebug_on = 1 ;
      strcpy (_NFMdebug_st.SQLdebug_file, debug_file) ;
      _NFMdebug ((fname, "DEBUG GOES TO %s\n", _NFMdebug_st.NFMdebug_file));
    }

    status = NFMpre_user_interface () ;

    if (status != NFM_S_SUCCESS) 
      {
        _NFMdebug ((fname, "Before User Interface Failed :  <0x%.8x> ", 
		   status));
        return (status);
      }

    status = NFMi_init_attr (&node_attr, &node_data, &sa_attr, &sa_data,
			     &user_attr, &user_data, &db_attr, &db_data,
			     &db2_attr, &db2_data, &os_attr, &os_data);
	

    /* process server node form */

   status = MEMbuild_array (node_attr);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
        }

    data_ptr = (char **) node_attr->data_ptr;
    column_ptr = (char **) node_attr->column_ptr;

    NFMfill_index (node_attr, &index);

    count = 0;
    for (i=0; i<node_attr->rows*node_attr->columns; i+=node_attr->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFMdebug ((fname, "Displayable fields : <%d>", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 24;
    data.col_width[1] = 10;
    data.col_width[2] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "I/NFM Server Node Info");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Attribute");
    NFMput_string (&data.data[1], "Data Type");
/*                  data.data[2]                */
/*                  data.data[3]                */
/*                  data.data[4]                */
/*                  data.data[5]                */

    for (i=pos, j=0; i<tot_data; j+=node_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFMput_string (&data.data[i], data_ptr[j+index.syn]);
            NFMput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<node_attr->rows*node_attr->columns; i+=node_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* if attribute is readable but not writeable, don't select it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<node_attr->rows*node_attr->columns; i+=node_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
        }

/* HARD-CODE DEFAULT INIT VALUES */

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0; j<(node_attr->rows*node_attr->columns); j+=node_attr->columns)
            {
                 if ((strcmp (data_ptr[j+index.name], "n_nodedesc") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "I/NFM Server Node");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_tcpip") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "Y");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_xns") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     /* Default option set to N for SCO/SUN - SSRS 14 Apr 94 */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
                         NFMput_string (&data.data[i+2], "N");
#		     else
                         NFMput_string (&data.data[i+2], "Y");
#                    endif
/*                     data.selectable[i+2] = 0; */
                     break;
                     }
            else if ((strcmp (data_ptr[j+index.name], "n_netware") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "N");
                     break;
                     }
            else if ((strcmp (data_ptr[j+index.name], "n_decnet") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "N");
                     break;
                     }
            else if ((strcmp (data_ptr[j+index.name], "n_nfs") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "N");
                     break;
                     }
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFMdebug ((fname, "SCprocess_column_form -> %d", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFMput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFMvalidate_nulls (node_attr, index, data, pos,
                                        &FORM_FILLED);

            }  /* data.sts != FORM_CANCELED */
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFMdebug ((fname, "Cancel from form. <%s>.", "Return"));
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, "") ;
        return (FORM_CANCELED);
        }

    status = MEMbuild_array (node_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
        return (NFM_E_MEM);
        }

    n_data_ptr = (char **) node_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<node_data->columns; j+=node_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            status = MEMwrite_data (node_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&node_attr);
                MEMclose (&node_data);
                NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                _NFMdebug ((fname, "MEMwrite_data :  <0x%.8x> ", status));
                return (NFM_E_MEM);
                }
            i+=data.num_of_cols;
            }
        }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);


    /* process storage area form */

    status = MEMbuild_array (sa_attr);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&sa_attr);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
        return (NFM_E_MEM);
        }

    data_ptr = (char **) sa_attr->data_ptr;
    column_ptr = (char **) sa_attr->column_ptr;

    NFMfill_index (sa_attr, &index);

    count = 0;
    for (i=0; i<sa_attr->rows*sa_attr->columns; i+=sa_attr->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFMdebug ((fname, "Displayable fields : <%d>", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 24;
    data.col_width[1] = 10;
    data.col_width[2] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "I/NFM Storage Area Info");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Attribute");
    NFMput_string (&data.data[1], "Data Type");
/*                  data.data[2]                */
/*                  data.data[3]                */
/*                  data.data[4]                */
/*                  data.data[5]                */

    for (i=pos, j=0; i<tot_data; j+=sa_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFMput_string (&data.data[i], data_ptr[j+index.syn]);
            NFMput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<sa_attr->rows*sa_attr->columns; i+=sa_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* if attribute is readable but not writeable, don't select it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<sa_attr->rows*sa_attr->columns; i+=sa_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
        }

/* HARD-CODE DEFAULT INIT VALUES */

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0; j<(sa_attr->rows*sa_attr->columns); j+=sa_attr->columns)
            {
                 if ((strcmp (data_ptr[j+index.name], "n_saname") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfm");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_username") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfmadmin");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_passwd") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfmadmin");
                     break;
                     }
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFMdebug ((fname, "SCprocess_column_form -> %d", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFMput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFMvalidate_nulls (sa_attr, index, data, pos,
                                        &FORM_FILLED);

            }  /* data.sts != FORM_CANCELED */
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFMdebug ((fname, "Cancel from form. <%s>.", "Return"));
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL) ;
        return (FORM_CANCELED);
        }

    break_flag = 0 ;

    for (i=pos; i<tot_data && !break_flag ; i+=data.num_of_cols)
      {
        for (j=0; j<(sa_attr->rows*sa_attr->columns) && !break_flag; j+=sa_attr->columns)
	  {
	    if ((strcmp (data_ptr[j+index.name], "n_username") == 0) &&
		(strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
	      {
		strcpy (user_name, data.data [i+2]) ;
		break_flag = 1 ;
	      }
	  }
      }

     if (user_name [0] == 0)
       {
	 sprintf (message, "Invalid NFM administrator user\n") ;
	 ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
			 "Invalid NFM administrator user") ;
	 return (NFM_E_MESSAGE) ;
       }

     pwd_ptr = (struct passwd *) getpwnam (user_name) ;
  
     if (pwd_ptr == NULL)
       {
	 
	 sprintf (message, "No entry in /etc/passwd exist for %s\n",user_name);
	 _INIT_str (message) ;
	 ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
	 return (NFM_E_MESSAGE) ;
	 
       }
     
     _NFMdebug ((fname, "Login path for %s is %s\n", 
		 user_name, pwd_ptr ->pw_dir));
     
/*     free (pwd_ptr) ; */

     if (strcmp (pwd_ptr->pw_dir, NFMCWD))
       {
	 _INIT_str ("Initialize must run from nfmadmin login directory") ;
	 _NFMdebug ((fname, 
		     "Initialize must run from nfmadmin login directory")) ;
	 ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
			 "Initialize must run from nfmadmin login directory");
	 return (NFM_E_MESSAGE) ;
       }

    status = MEMbuild_array (sa_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
        return (NFM_E_MEM);
        }

    n_data_ptr = (char **) sa_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<sa_data->columns; j+=sa_attr->columns, ++k)
        {
        if ((strcmp (data_ptr[j+index.w], "Y") == 0) ||
	    (strcmp (data_ptr[j+index.r], "Y") == 0))
            {
            status = MEMwrite_data (sa_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&node_attr);
                MEMclose (&node_data);
                MEMclose (&sa_attr);
                MEMclose (&sa_data);
                NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                _NFMdebug ((fname, "MEMwrite_data :  <0x%.8x> ", status));
                return (NFM_E_MEM);
                }
            i+=data.num_of_cols;
            }
        }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    /* process admin user form */

    status = MEMbuild_array (user_attr);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&user_attr);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
        return (NFM_E_MEM);
        }

    data_ptr = (char **) user_attr->data_ptr;
    column_ptr = (char **) user_attr->column_ptr;

    NFMfill_index (user_attr, &index);

    count = 0;
    for (i=0; i<user_attr->rows*user_attr->columns; i+=user_attr->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFMdebug ((fname, "Displayable fields : <%d>", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 24;
    data.col_width[1] = 10;
    data.col_width[2] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "I/NFM Administrator Info");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Attribute");
    NFMput_string (&data.data[1], "Data Type");
/*                  data.data[2]                */
/*                  data.data[3]                */
/*                  data.data[4]                */
/*                  data.data[5]                */

    for (i=pos, j=0; i<tot_data; j+=user_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFMput_string (&data.data[i], data_ptr[j+index.syn]);
            NFMput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<user_attr->rows*user_attr->columns; i+=user_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* if attribute is readable but not writeable, don't select it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<user_attr->rows*user_attr->columns; i+=user_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
        }

/* HARD-CODE DEFAULT INIT VALUES */

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0; j<(user_attr->rows*user_attr->columns); j+=user_attr->columns)
            {
                 if ((strcmp (data_ptr[j+index.name], "n_userdesc") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "I/NFM Administrator");
                     break;
                     }
            else if ((strcmp (data_ptr[j+index.name], "n_emailaddr") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfmadmin");
                     break;
                     }
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFMdebug ((fname, "SCprocess_column_form -> %d", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFMput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFMvalidate_nulls (user_attr, index, data, pos,
                                        &FORM_FILLED);

            }  /* data.sts != FORM_CANCELED */
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFMdebug ((fname, "Cancel from form. <%s>.", "Return"));
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct (NFI, NFI_W_FORM_CANCELED, "", "") ;
        return (FORM_CANCELED);
        }

    status = MEMbuild_array (user_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&user_attr);
        MEMclose (&user_data);
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
        return (NFM_E_MEM);
        }

    n_data_ptr = (char **) user_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<user_data->columns; j+=user_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            status = MEMwrite_data (user_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&node_attr);
                MEMclose (&node_data);
                MEMclose (&sa_attr);
                MEMclose (&sa_data);
                MEMclose (&user_attr);
                MEMclose (&user_data);
                NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                _NFMdebug ((fname, "MEMwrite_data :  <0x%.8x> ", status));
                return (NFM_E_MEM);
                }
            i+=data.num_of_cols;
            }
        }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    /* process RIS form */

    status = MEMbuild_array (db_attr);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&user_attr);
        MEMclose (&user_data);
        MEMclose (&db_attr);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
        return (NFM_E_MEM);
        }

    data_ptr = (char **) db_attr->data_ptr;
    column_ptr = (char **) db_attr->column_ptr;

    NFMfill_index (db_attr, &index);

    count = 0;
    for (i=0; i<db_attr->rows*db_attr->columns; i+=db_attr->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFMdebug ((fname, "Displayable fields : <%d>", count));

/*  Do not skip top 2 rows */
/*    pos = 6; */
/*    data.num_of_rows = count + 2; */
    pos = 0 ;
    data.num_of_rows = count ;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
/* KT - 3/15/93 - changing the column width to 22 from 24 - caused strange
                  allignment and missing characters!
*/
    data.col_width[0] = 22;
    data.col_width[1] = 10;
    data.col_width[2] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "RDBMS Info");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos + 2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Attribute");
    NFMput_string (&data.data[1], "Data Type");
/*                  data.data[2]                */
/*                  data.data[3]                */
/*                  data.data[4]                */
/*                  data.data[5]                */

    for (i=pos, j=0; i<tot_data; j+=db_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFMput_string (&data.data[i], data_ptr[j+index.syn]);
            NFMput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<db_attr->rows*db_attr->columns; i+=db_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* if attribute is readable but not writeable, don't select it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<db_attr->rows*db_attr->columns; i+=db_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
        }

/* HARD-CODE DEFAULT INIT VALUES */

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0; j<(db_attr->rows*db_attr->columns); j+=db_attr->columns)
            {
                 if ((strcmp (data_ptr[j+index.name], "n_srvname") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfm");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_envname") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfm");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_rdbmstype") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
                         NFMput_string (&data.data[i+2], "sybase");
#                    else
                         NFMput_string (&data.data[i+2], "informix");
#                    endif
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_rdbmshome") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
                       NFMput_string (&data.data[i+2], "/u/sybase");
#                    else

		       strcpy (tmp_str, "/usr/informix") ;
		       i_status = stat (tmp_str, &buf) ;
		       if (i_status)  /* 0 is successful */
			 {
			   _NFMdebug ((fname, 
				       "/usr/informix does not exist\n")) ;
			   for (x=1; x<10; x++)
			     {
			       sprintf (tmp_str, "/usr%d/informix", x) ;
			       i_status = stat (tmp_str, &buf) ;
			       if (i_status == 0) break ;
			     }
			   if (x == 10) strcpy (tmp_str, "/usr/informix") ;
			 }
		       _NFMdebug ((fname, "dir for informix is %s\n",
				   tmp_str)) ;
		       NFMput_string (&data.data[i+2], tmp_str) ;
#                      endif
		       break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_risdb") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
		       sprintf (tmp_str, "%s/nfm", NFMCWD) ;
		       NFMput_string (&data.data[i+2], tmp_str) ;
		       break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_envnode") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
		       nodename [0] = 0;
		       
		       /* missing 4rth arg added -- SSRS 31 jan 94 */

		       c_status = (char *) clh_vbyop ("TEMPLATE",
					"NODENAME", nodename, 50);
		       if (c_status)
			 {
			   MEMclose (&node_attr);
			   MEMclose (&node_data);
			   MEMclose (&sa_attr);
			   MEMclose (&sa_data);
			   MEMclose (&user_attr);
			   MEMclose (&user_data);
			   MEMclose (&db_attr);
			   status = NFM_E_BAD_TEMPLATE ;
			   status = ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, "", NULL);
			   _NFMdebug ((fname, "Node Name Not Defined : status = <0x%.8x>\n",
				     NFM_E_BAD_TEMPLATE));
			   return (NFM_E_BAD_TEMPLATE);
			 }

                     NFMput_string (&data.data[i+2], nodename);
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_srvnetwork") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     /*Default option set to TCP for SCO/SUN - SSRS 14 Apr 94 */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
                         NFMput_string (&data.data[i+2], "tcp");
#		     else
                         NFMput_string (&data.data[i+2], "xns");
#		     endif
                     break;
                     }

/*
            else if ((strcmp (data_ptr[j+index.name], "n_risuser") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "risdba");
                     break;
                     }
 */
            else if ((strcmp (data_ptr[j+index.name], "n_schname") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfm");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_schpwd") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfm");
                     break;
                     }
/*
            else if ((strcmp (data_ptr[j+index.name], "n_schuser") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfmdba");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_defsch") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "risdba");
                     break;
                     }
 */
	    else if ((strcmp (data_ptr[j+index.name], "n_env_usr") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfmadmin");
                     break;
                     }

	    else if ((strcmp (data_ptr[j+index.name], "n_env_usr_pwd") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "nfmadmin");
                     break;
                     }

            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFMdebug ((fname, "SCprocess_column_form -> %d", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFMput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFMvalidate_nulls (db_attr, index, data, pos,
                                        &FORM_FILLED);

            }  /* data.sts != FORM_CANCELED */
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFMdebug ((fname, "Cancel from form. <%s>.", "Return"));
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct (NFI, NFI_W_FORM_CANCELED, "", "") ;
        return (FORM_CANCELED);
        }

    status = MEMbuild_array (db_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_attr);
        MEMclose (&node_data);
        MEMclose (&sa_attr);
        MEMclose (&sa_data);
        MEMclose (&user_attr);
        MEMclose (&user_data);
        MEMclose (&db_attr);
        MEMclose (&db_data);
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
        return (NFM_E_MEM);
        }

    n_data_ptr = (char **) db_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<db_data->columns; j+=db_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            status = MEMwrite_data (db_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&node_attr);
                MEMclose (&node_data);
                MEMclose (&sa_attr);
                MEMclose (&sa_data);
                MEMclose (&user_attr);
                MEMclose (&user_data);
                MEMclose (&db_attr);
                MEMclose (&db_data);
                NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                _NFMdebug ((fname, "MEMwrite_data :  <0x%.8x> ", status));
                return (NFM_E_MEM);
                }
            i+=data.num_of_cols;
            }
        }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    status = MEMbuild_array (db_data) ;
    if (status != MEM_S_SUCCESS)
      {
	MEMclose (&node_attr);
	MEMclose (&node_data);
	MEMclose (&sa_attr);
	MEMclose (&sa_data);
	MEMclose (&user_attr);
	MEMclose (&user_data);
	MEMclose (&db_attr);
	MEMclose (&db_data);
	_NFMdebug ((fname, "MEMwrite_data :  <0x%.8x> ", status));
	return (NFM_E_MEM);
      }

    data_ptr  = (char **) db_data->data_ptr ;

    NFMlower_case (data_ptr [2], data_ptr [2]);
    if (strcmp (data_ptr [2], "db2") == 0)
      {
/*******  DB2 Form is applicable **********/

	status = MEMbuild_array (db2_attr);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&node_attr);
	    MEMclose (&node_data);
	    MEMclose (&sa_attr);
	    MEMclose (&sa_data);
	    MEMclose (&user_attr);
	    MEMclose (&user_data);
	    MEMclose (&db_attr);
	    MEMclose (&db2_attr) ;
	    _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
	    return (NFM_E_MEM);
	  }
	
	data_ptr = (char **) db2_attr->data_ptr;
	column_ptr = (char **) db2_attr->column_ptr;
	
	NFMfill_index (db2_attr, &index);
	
	
	count = 0;
    for (i=0; i<db2_attr->rows*db2_attr->columns; i+=db2_attr->columns)
      {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
	  ++count;
      }
	
	_NFMdebug ((fname, "Displayable fields : <%d>", count));

	/*  Skip top 2 rows */
	pos = 6; 
	data.num_of_rows = count + 2;
	/*    pos = 0 ;
	      data.num_of_rows = count ;
	      */
	data.num_of_cols = 3;
	tot_data = data.num_of_cols * data.num_of_rows;
	data.freeze_rows_count = 0;
	data.select_set_expected = FALSE;
	data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
	memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
	
	data.col_width[0] = 24;
	data.col_width[1] = 10;
	data.col_width[2] = 40;
	data.new_rows_expected = FALSE;
	strcpy (data.title, "RDBMS Info");
	
	data.selectable = (int *) malloc (tot_data * sizeof (int));
	memset (data.selectable, 0, (tot_data * sizeof (int)));
	
	for (i=pos + 2; i<tot_data; i+=data.num_of_cols)
	  data.selectable[i] = 1;
	
	data.hidden = (int *) malloc (tot_data * sizeof (int));
	memset (data.hidden, 0, (tot_data * sizeof (int)));

	/* allocate and initialize space to store data */
	
	data.data = (char **) malloc (tot_data * sizeof (char *));
	memset (data.data, NULL, (tot_data * sizeof (char *)));
	
	NFMput_string (&data.data[0], "Attribute");
	NFMput_string (&data.data[1], "Data Type");
	/*                  data.data[2]                */
	/*                  data.data[3]                */
	/*                  data.data[4]                */
	/*                  data.data[5]                */
	
	for (i=pos, j=0; i<tot_data; j+=db2_attr->columns)
	  {
	    if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
		(strcmp (data_ptr[j+index.w], "Y") == 0))
	      {
		NFMput_string (&data.data[i], data_ptr[j+index.syn]);
		NFMput_string (&data.data[i+1], data_ptr[j+index.dt]);
		i+=data.num_of_cols;
	      }
	  }
	
    /* if attribute is writable but not readable, hide it */
	for (j=pos; j<tot_data; j+=data.num_of_cols)
	  {
	    for (i=0; i<db2_attr->rows*db2_attr->columns; i+=db2_attr->columns)
	      {
		if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
		     (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
		    ((strcmp (data_ptr[i+index.r], "N") == 0) &&
		     (strcmp (data_ptr[i+index.w], "Y") == 0)))
		  {
		    data.hidden[j+2] = 1;
		    break;
		  }
	      }
	  }
	
	/* if attribute is readable but not writeable, don't select it */
	for (j=pos; j<tot_data; j+=data.num_of_cols)
	  {
	    for (i=0; i<db2_attr->rows*db2_attr->columns; i+=db2_attr->columns)
	      {
		if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
		     (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
		    ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
		     (strcmp (data_ptr[i+index.w], "N") == 0)))
		  {
		    data.selectable[j+2] = 0;
		    break;
		  }
	      }
	  }

/* HARD-CODE DEFAULT INIT VALUES */
	for (i=pos; i<tot_data; i+=data.num_of_cols)
	  {
	    for (j=0; j<(db2_attr->rows*db2_attr->columns); j+=db2_attr->columns)
	      {
		if ((strcmp (data_ptr[j+index.name], "arch") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
		  {
		    NFMput_string (&data.data[i+2], "s370");
		    break;
		  }
		
		else if ((strcmp (data_ptr[j+index.name], "os") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
		  {
		    NFMput_string (&data.data[i+2], "mvs");
		    break;
		  }
		
		else if ((strcmp (data_ptr[j+index.name], "env") == 0) &&
			 (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
		  {
		    NFMput_string (&data.data[i+2], "cics");
		    break;
		  }

		else if ((strcmp (data_ptr[j+index.name], "db2_net_protl") == 0) &&
			 (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
		  {
		    NFMput_string (&data.data[i+2], "lu6.2");
		    break;
		  }
	      }
	  }

	/* process column form until file_name has been entered */
	do
	  {
	    FORM_FILLED = TRUE;
	    status = SCprocess_column_form (&data, NFMprint_file);
	    SCclear_msg ();
	    
	    _NFMdebug ((fname, "SCprocess_column_form -> %d", data.sts));
	    
	    if (data.sts != FORM_CANCELED)
	      {
		status = NFMput_and_validate_data (data.data, pos+2, tot_data,
						   data.num_of_cols);
		
		/* if attribute is required ("n_null" == "N"),
		   user must keyin a value */
		
		status = NFMvalidate_nulls (db2_attr, index, data, pos,
					    &FORM_FILLED);
		
	      }  /* data.sts != FORM_CANCELED */
	  }
	while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));
	
	if (data.sts == FORM_CANCELED)
	  {
	    _NFMdebug ((fname, "Cancel from form. <%s>.", "Return"));
	    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
	    free (data.data);
	    ERRload_struct (NFI, NFI_W_FORM_CANCELED, "", "") ;
	    return (FORM_CANCELED);
	  }
	
	status = MEMbuild_array (db2_data);
	if (status != MEM_S_SUCCESS)
	  {
	    MEMclose (&node_attr);
	    MEMclose (&node_data);
	    MEMclose (&sa_attr);
	    MEMclose (&sa_data);
	    MEMclose (&user_attr);
	    MEMclose (&user_data);
	    MEMclose (&db_attr);
	    MEMclose (&db_data);
	    MEMclose (&db2_attr) ;
	    MEMclose (&db2_data) ;
	    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
	    free (data.data);
	    _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
	    return (NFM_E_MEM);
	  }

	n_data_ptr = (char **) db2_data->data_ptr;
	
	for (i=pos+2, j=0, k=0; k<db2_data->columns; j+=db2_attr->columns, ++k)
	  {
	    status = MEMwrite_data (db2_data, data.data[i], 1, k+1);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (&node_attr);
		MEMclose (&node_data);
		MEMclose (&sa_attr);
		MEMclose (&sa_data);
		MEMclose (&user_attr);
		MEMclose (&user_data);
		MEMclose (&db_attr);
		MEMclose (&db_data);
		MEMclose (&db2_attr) ;
		MEMclose (&db2_data) ;
		NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
		free (data.data);
		_NFMdebug ((fname, "MEMwrite_data :  <0x%.8x> ", status));
		return (NFM_E_MEM);
	      }
	    i+=data.num_of_cols;
	  }
	
	NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
	free (data.data);
      }
   else if (strcmp (data_ptr [2], "sybase") == 0)
      {
/*******  SQL SERVER NAME Form is applicable **********/

	pos = 4; 
	SYdata.num_of_rows = 4;
	SYdata.num_of_cols = 2;
	tot_data = SYdata.num_of_cols * SYdata.num_of_rows;
	SYdata.freeze_rows_count = 0;
	SYdata.select_set_expected = FALSE;
	SYdata.col_width = (int *) malloc (SYdata.num_of_cols * sizeof (int));
	memset (SYdata.col_width, 0, (SYdata.num_of_cols * sizeof (int)));
	
	SYdata.col_width[0] = 24;
	SYdata.col_width[1] = 40;

	SYdata.new_rows_expected = FALSE;
	strcpy (SYdata.title, "SYBASE Information");
	
	SYdata.selectable = (int *) malloc (tot_data * sizeof (int));
	memset (SYdata.selectable, 0, (tot_data * sizeof (int)));
	
        SYdata.selectable[5] = 1;
        SYdata.selectable[7] = 1;
	
	SYdata.hidden = (int *) malloc (tot_data * sizeof (int));
	memset (SYdata.hidden, 0, (tot_data * sizeof (int)));

	/* allocate and initialize space to store data */
	
	SYdata.data = (char **) malloc (tot_data * sizeof (char *));
	memset (SYdata.data, NULL, (tot_data * sizeof (char *)));
	
	NFMput_string (&SYdata.data[4], "SYBASE Server Name");
	NFMput_string (&SYdata.data[5], "SYBASE");
	NFMput_string (&SYdata.data[6], "Interfaces Filename");
	NFMput_string (&SYdata.data[7], "interfaces");
	
	/* process column form until server_name has been entered */
	do
	  {
	    FORM_FILLED = TRUE;
	    status = SCprocess_column_form (&SYdata, NFMprint_file);
	    SCclear_msg ();
	    
	    _NFMdebug ((fname, "SCprocess_column_form -> %d", SYdata.sts));
	    
	    if (SYdata.sts != FORM_CANCELED)
	      {
		 if (strcmp(SYdata.data[5], "" ) == 0 )
		 {
	                SCdisplay_msg("NFM:  Must specify SYBASE server name/s.");
			FORM_FILLED = FALSE;
		 }
		
		 if (strcmp(SYdata.data[7], "" ) == 0 )
		 {
	                SCdisplay_msg("NFM:  Must specify interfaces file/s.");
			FORM_FILLED = FALSE;
		 }
		
	      }  /* SYdata.sts != FORM_CANCELED */
	  }
	while ((FORM_FILLED == FALSE) && (SYdata.sts != FORM_CANCELED));
	
	if (SYdata.sts == FORM_CANCELED)
	  {
	    _NFMdebug ((fname, "Cancel from form. <%s>.", "Return"));
	    NFMfree_list (SYdata.data, SYdata.num_of_rows, SYdata.num_of_cols);
	    free (SYdata.data);
	    ERRload_struct (NFI, NFI_W_FORM_CANCELED, "", "") ;
	    return (FORM_CANCELED);
	  }
	_NFMdebug(( fname, "SQL Server Name <%s>\n", SYdata.data[5]));
	_NFMdebug(( fname, "Interfaces File <%s>\n", SYdata.data[7]));
	strcpy (SYserver, SYdata.data[5]);
	strcpy (SYinterfaces, SYdata.data[7]);
	NFMfree_list (SYdata.data, SYdata.num_of_rows, SYdata.num_of_cols);
	free (SYdata.data);
    } /* end if (sybase) */

	/* **********added by naidu -- 31 Jan 1995***********/
    /* process OS info form */

   status = MEMbuild_array (os_attr);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&node_attr);
	MEMclose (&node_data);
	MEMclose (&sa_attr);
	MEMclose (&sa_data);
	MEMclose (&user_attr);
	MEMclose (&user_data);
	MEMclose (&db_attr);
	MEMclose (&db_data);
	MEMclose (&db2_attr) ;
	MEMclose (&db2_data) ;
        MEMclose (&os_attr);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
        }

    data_ptr = (char **) os_attr->data_ptr;
    column_ptr = (char **) os_attr->column_ptr;

    NFMfill_index (os_attr, &index);
/* temp added by naidu -- 1 Feb 95  **************/
    d_data = (char **) db_data->data_ptr;
    strcpy(db_type, d_data [2]);
    NFMupper_case (db_type, db_type);
    _NFMdebug ((fname, "DB_Type :  %s ", db_type));
    if (strcmp(db_type, "ORACLE") != 0) 
    {
    _NFMdebug ((fname, "InsidIf.....  %s ", db_type));
	strcpy(data_ptr[os_attr->columns+index.r], "N");
	strcpy(data_ptr[os_attr->columns+index.w], "N");
	strcpy(data_ptr[2*os_attr->columns+index.r], "N");
	strcpy(data_ptr[2*os_attr->columns+index.w], "N");
    }

    count = 0;
    for (i=0; i<os_attr->rows*os_attr->columns; i+=os_attr->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFMdebug ((fname, "Displayable fields : <%d>", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 24;
    data.col_width[1] = 10;
    data.col_width[2] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "OS User Info");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Attribute");
    NFMput_string (&data.data[1], "Data Type");
/*                  data.data[2]                */
/*                  data.data[3]                */
/*                  data.data[4]                */
/*                  data.data[5]                */

/* ****** temp added by naidu for db_type to check ** 1 Feb 95 **********/
    for (i=pos, j=0; i<tot_data; j+=node_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFMput_string (&data.data[i], data_ptr[j+index.syn]);
            NFMput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<os_attr->rows*os_attr->columns; i+=os_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* if attribute is readable but not writeable, don't select it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<os_attr->rows*os_attr->columns; i+=os_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.name], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
        }

/* HARD-CODE DEFAULT INIT VALUES */
/* ***** stopped here , cont... 1-feb-95 ... Naidu ********/
    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0; j<(os_attr->rows*os_attr->columns); j+=os_attr->columns)
            {
                 if ((strcmp (data_ptr[j+index.name], "n_osname") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], "UNIX");
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_username") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                     NFMput_string (&data.data[i+2], d_data [9]);
                     break;
                     }

            else if ((strcmp (data_ptr[j+index.name], "n_passwd") == 0) &&
                     (strcmp (data.data[i], data_ptr[j+index.syn]) == 0))
                     {
                         NFMput_string (&data.data[i+2], d_data [10]);
                     break;
                     }
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFMdebug ((fname, "SCprocess_column_form -> %d", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFMput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFMvalidate_nulls (os_attr, index, data, pos,
                                        &FORM_FILLED);

            }  /* data.sts != FORM_CANCELED */
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFMdebug ((fname, "Cancel from form. <%s>.", "Return"));
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, "") ;
        return (FORM_CANCELED);
        }

    status = MEMbuild_array (os_data);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&os_attr);
        MEMclose (&os_data);
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        _NFMdebug ((fname, "MEMbuild_array :  <0x%.8x> ", status));
        return (NFM_E_MEM);
        }

    n_data_ptr = (char **) os_data->data_ptr;

    for (i=pos+2, j=0, k=0; k<os_data->columns; j+=os_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            status = MEMwrite_data (os_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&node_attr);
                MEMclose (&node_data);
                MEMclose (&sa_attr);
                MEMclose (&sa_data);
                MEMclose (&user_attr);
                MEMclose (&user_data);
                MEMclose (&db_attr);
                MEMclose (&db_data);
                MEMclose (&db2_attr);
                MEMclose (&db2_data);
                MEMclose (&os_attr);
                MEMclose (&os_data);
                NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                _NFMdebug ((fname, "MEMwrite_data :  <0x%.8x> ", status));
                return (NFM_E_MEM);
                }
            i+=data.num_of_cols;
            }
        }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
	/* ***************EOF addition by naidu  ***********/
/******************************************/

    SCclear_col_form ();

    SCdisplay_msg ("Working...");

    status = NFMris_init (node_attr, node_data, sa_attr, sa_data,
                      user_attr, user_data, db_attr, db_data,
		      db2_attr, db2_data, os_attr, os_data, SYserver, SYinterfaces) ;

    MEMclose (&node_attr);
    MEMclose (&node_data);
    MEMclose (&sa_attr);
    MEMclose (&sa_data);
    MEMclose (&user_attr);
    MEMclose (&user_data);
    MEMclose (&db_attr);
    MEMclose (&db_data);
    MEMclose (&db2_attr) ;
    MEMclose (&db2_data) ;
    MEMclose (&os_attr);
    MEMclose (&os_data);

    _NFMdebug ((fname, "return from init ->  <0x%.8x> ", status));

    switch (status)
        {
        case NFM_S_SUCCESS:
         status= system ("/usr/ip32/nfm/bin/NFMdmdftr.sh > /dev/null 2>&1");
         _NFMdebug(( fname, "dmd_ftr create?\n"));
         if (status<0)
           {
              _NFMdebug(( fname, "Error greating environment files\n"));
              return(status);
           }
          SCdisplay_msg ("NFM: Successful Completion.");
          break;
            
        default:
            break;
        }

    /* return FAILURE so that screen controller will exit */            
    return (status); 
}

