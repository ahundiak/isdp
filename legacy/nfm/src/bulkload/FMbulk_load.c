#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h> 
#include "UNIX_or_VMS.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "WFcommands.h"
#include "ERR.h"
#include "NFMstruct.h"
#include "DEBUG.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include "NFMdisplays.h"
#include "NFMbulk.h"

extern struct NFMwf_info  NFAwf_info;
extern struct NFMoperation NFAoperation;


extern long sqlstatus;
 
bulk_load ()
{
FILE   *status_file;
long   status;
int    i, j, k, m, q, r, pos, pos2, err_pos, off;
struct SCcolumn_data_st data;
struct SCcolumn_data_st data2;
struct SCcolumn_data_st err_data;
int    FORM_FILLED;
int    NOT_FIRST_TIME = FALSE;
int    VALIDATE_OK = TRUE;
int    QUERY_OK = TRUE;
int    ADD_OK = TRUE;
int    ROW_SELECT = TRUE;
int    catalog_no = -1;
int    CHECKIN_OK = TRUE;
int    tot_data;
int    tot_data2;
int    tot_err_data;
int    sa_index = 0;
int    type_index = 0;
int    rev_index = 0;
int    flag_index = 0;
int    cat_index = 0;
int    status_index = 0;
int    name_index = 0;
int    desc_index = 0;
int    max_index = 0;
int    saname_pos;
int    sano_pos;
int    pathname_pos = 0;
long   NFMuser_id = 0;
char   def_revision[15];
char   def_versions[15];
char   def_type[15];
char   def_storage[20];
char   def_acl[20];
char   def_flag[5];
char   storage_num[10];
char   acl_num[10];
char   cisano_index[10];
char   aclno_index[10];
char   err_str[15];
char   status_file_name[40];
char   upper_level_path[80];
long   delete_sa_flag ;
char   previous_path[80];
char   present_path[80];
char   saname[80] ;
char   value[80];
char   upper_level_sano[80];
char   one_or_all[2];
char   **data_ptr;
char   **rmt_data_ptr;
char   **column_ptr;
char   **rmt_column_ptr;
char   **column;
char   **my_data;
MEMptr out_list = NULL;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr ci_attr = NULL;
MEMptr ci_data = NULL;
MEMptr sa_data = NULL;
MEMptr sa_attr = NULL;
MEMptr sa_value = NULL;

static char *fname = "bulk_load";
NDXptr index;



    _NFMR_str ("%s", "Enter bulk_load");
/*
	_NFMdebug_st.NFMRdebug_on = 1 ;
	strcpy (_NFMdebug_st.NFMRdebug_file, "/dev/console") ; 
	_NFMdebug_st.NFIdebug_on = 1 ;
	strcpy (_NFMdebug_st.NFIdebug_file, "/dev/console") ; 
    _NFMRdebug((fname,  "Enter"));
	_NFMR_str ("NFMRdebug enabled %s", "") ;
    _NFIdebug((fname, "NFMRdebug not enabled %s", ""));
*/

    data.num_of_rows = 7;
    data.num_of_cols = 2;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));

   /* SSRS - 8/11/93 - data.col_width casted to (char *) */
    memset ((char *)data.col_width,  0,  (data.num_of_cols * sizeof (int)));

    data.col_width[0] = 35;
    data.col_width[1] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Appropriate Data. Press <PF1>.");

    data.selectable = (int *) malloc (tot_data * sizeof (int));

/* SSRS - 8/11/93 - data.selectable casted to (char *) */
    memset ((char *)data.selectable,  0,  (tot_data * sizeof (int)));

    for (i=5; i<tot_data; i+=data.num_of_cols)
        {
        data.selectable[i] = 1;
        }
    _NFIdebug((fname, " the no.of_col is <0x%.8x>\n", i));
    data.hidden = (int *) malloc (tot_data * sizeof (int));


    /* SSRS - 8/11/93 - data.hidden casted to (char *) */
    memset ((char *)data.hidden,  0,  (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Catalog To Load");
    NFAput_string (&data.data[1], NFMcatalog);
    NFAput_string (&data.data[2], "Storage Area To Bulk Load From");
    NFAput_string (&data.data[3], NFMstorage);
    NFAput_string (&data.data[4], "Default File Revision");
    NFAput_string (&data.data[5], "0");
    NFAput_string (&data.data[6], "Default Maximum Versions");
    NFAput_string (&data.data[7], "1");
    NFAput_string (&data.data[8], "Default File Type");
    NFAput_string (&data.data[10], "Automatic Flag? ('A' or 'B')");
    NFAput_string (&data.data[12], "Bulk Load Output File");
    strcpy (status_file_name, NFMcatalog);
    strcat (status_file_name, ".bulk");
    NFAput_string (&data.data[13], status_file_name);

    cat_index = 1;        
    sa_index = 3;
    rev_index = 5;
    max_index = 7;
    type_index = 9;
    flag_index = 11;
    status_index = 13;
    SCclear_msg();
    
    /* open bulk load status file */

    if ((status_file = fopen (status_file_name, "a+")) == NULL)
        {
        SCdisplay_msg ("NFM:  Cannot Open Bulk Load Output File.");
        }

    _NFMR_str("%s", "call SCprocess_column_form");

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFMR_num("return from SCprocess_column_form -> %d", data.sts);

        if (data.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            for (i=1; i<tot_data; i+=data.num_of_cols)
                {
                if (data.data[i] == 0)
                    NFAput_string (&data.data[i], "");
                else
                    status = NFAvalidate_string ("char(256)", data.data[i]);
                }

            if (strcmp (data.data[flag_index], "a") == 0)
                NFAput_string (&data.data[flag_index], "A");

            if (strcmp (data.data[flag_index], "b") == 0)
                NFAput_string (&data.data[flag_index], "B");

            if ((strcmp (data.data[flag_index], "A") != 0) &&
                (strcmp (data.data[flag_index], "B") != 0) &&
                (strcmp (data.data[flag_index], "") != 0))
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  Invalid Flag.");
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFMR_str("%s",  "Cancel from form. Return.");
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
        return (NFI_W_FORM_CANCELED);
        }

    strcpy (def_revision, data.data[rev_index]);
    strcpy (def_versions, data.data[max_index]);
    strcpy (def_type, data.data[type_index]);
    strcpy (def_flag, data.data[flag_index]);

    status = NFMone_or_all (one_or_all);
    if (status != NFM_S_SUCCESS)
     {
        _NFMR_num("one_or_all: <0x%.8x>\n", status);
        return(status);
     }         

    _NFMRdebug(( fname,  "one_or_all\n"));
    SCdisplay_msg ("working ");


    _NFIdebug ((fname, "One or All   -> <%s>", one_or_all));
    _NFIdebug ((fname, "Storage Area -> <%s>", data.data[sa_index]));

/*    strcpy (upper_level_saname, NFMstorage);*/
/*
    _NFMR_str ("This is a storage name %s\n", saname);
  
    status = NFMRget_sa_no (NFMuser_id, saname, sa_num);

    if (status != NFM_S_SUCCESS)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        NFMerr_ret (status);
        NFMRset_error (status, "NFMbulk_load : NFMRget_sa_no.");
        return (NFM_E_FAILURE);
        }
    
    status = NFMRget_sa_no_info (NFMuser_id, sa_num, node_name, 
    user_name, enc_passwd, path_name, dev_type, machid, op_sys, tcp, xns, dec);

    _NFMR_str ("The value of path_name is :%s\n", path_name);
    if (status != NFM_S_SUCCESS)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        NFMerr_ret (status);
        NFMRset_error (status, "NFMbulk_load : NFMRget_sa_no_info.");
        return (NFM_E_FAILURE);
        }

    NFMdecrypt (enc_passwd, dec_passwd);


    _NFMR_str("NFMRget_bulk_data : node : <%s>", node_name);
    _NFMR_str ("NFMRget_bulk_data : user : <%s>", user_name);
    _NFMR_str ( "NFMRget_bulk_data : passwd : <%s>", dec_passwd);

*/

  status = NFMRquery_change_sa_attributes (NFMuser_id, NFMstorage,  
                                             &sa_attr, 
                                             &sa_data, 
                                             &sa_value);
  _NFMR_num ("Return From NFMRquery_change_sa_attributes: <0x%.8x>\n", status);

  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_attr);
      MEMclose (&sa_data);
      MEMclose (&sa_value);
      return (status);
    }

  /* put information in buffer */

  status = MEMbuild_array (sa_data) ;
  my_data = (char **) sa_data -> data_ptr ;

  if (status != MEM_S_SUCCESS)
    {
      return (NFM_E_MEM) ;
    }

  column = (char **) sa_data -> column_ptr ;

  for (i=0; i<sa_attr->rows; i++)
    {
       value [0] = 0 ;

       if (! strcmp (column [i],  "n_sano"))
        {
         strcpy (upper_level_sano, my_data[i]);
         sano_pos = i ;
        }

       if (! strcmp (column [i],  "n_saname"))
        {
         strcpy (saname, my_data[i]);
         saname_pos = i ;
        }

       if (! strcmp (column [i],  "n_pathname"))

        {
         strcpy (upper_level_path, my_data[i]);
         pathname_pos = i ;
        }

       else if (!strcmp(column[i], "n_passwd"))
	    {

       	  NFMdecrypt (my_data[i], value);
        }
	
	   else if (! strcmp (column [i],  "n_type"))
	    {
	      strcpy (value,  "T") ;
	    }

       else continue ;

 if ((strlen (value)) || (!strcmp (column[i], "n_passwd")))
  {
      _NFMRdebug ((fname, "writing value %s into row 1 : column %d\n",
	                       value, i+1)) ;
      status = MEMwrite_data (sa_data,  value,  1,  i+1) ;
    if (status != MEM_S_SUCCESS)
     {
        _NFMR_num("This is a failure for this <0x%.8x>\n", status);
        return(status);
     }
   }
 }

  /*MEMprint_buffer ("sa_data",  sa_data,  "/dev/console") ;*/


/*  strcpy (upper_level_path,  path_name) ;

  _NFMR_str("This is a upper_level_path %s\n", upper_level_path);*/

  previous_path[0] = 0 ;
  present_path [0] = 0 ;

/* do not delete sa of upper level path */

  delete_sa_flag = 0 ;

  _NFMR_str("This is a previous_path %s\n", previous_path);

    status = NFMRget_bulk_data (NFMuser_id, data.data[sa_index], 
       one_or_all, &out_list);

    if (status != NFM_S_SUCCESS)
        {
          NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
          free (data.data);
          NFMerr_ret (status);
          NFMRset_error (status, "NFMbulk_load : NFMRget_bulk_data.");
          return (NFM_E_FAILURE);
        }

    _NFMR_num ("NFMRget_bulk_data :status : <0x%.8x>", status);

    MEMbuild_array (out_list);

    rmt_data_ptr = (char **) out_list->data_ptr;
    rmt_column_ptr = (char **) out_list->column_ptr;

    _NFMR_str("%s","Enter MEMbuild_array");

    if (NFMRmsg_ptr.debug_on)
        MEMprint_buffers ("Listener Data", out_list, NFMRmsg_ptr.debug_file);

    for (i=0; i<out_list->columns; ++i)
     {
       if (strcmp (rmt_column_ptr[i], "n_name") == 0)
       name_index = i;

       else if (strcmp (rmt_column_ptr[i], "n_directory") == 0)
                desc_index = i;
     }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

/*******************************************************************
Display Retrieved Data
********************************************************************/

    data.num_of_rows = out_list->rows + 2;
    data.num_of_cols = 4;
    pos = 8;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));

    /* SSRS - 8/11/93 - data.col_width casted to (char *) */
    memset ((char *)data.col_width,  0,  (data.num_of_cols * sizeof (int)));

    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    data.col_width[0] = 15;
    data.col_width[1] = 10;
    data.col_width[2] = 35;
    data.col_width[3] = 5;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Accept/Change Bulk Load File Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));

    /* SSRS - 8/11/93 - data.selectable casted to (char *) */
    memset ((char *)data.selectable,  0,  (tot_data * sizeof (int)));

    for (i=pos; i<tot_data; ++i)
        data.selectable[i] = 1;

    for (i=2; i< data.num_of_rows; ++i)
      {
        off = i * data.num_of_cols;
        data.selectable[off] = 0;   /* KT 2/24/93 - Disallow itemname keyins */
        data.selectable[off+2] = 0;
      }
    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Item Name");
    NFAput_string (&data.data[1], "Revision");
    NFAput_string (&data.data[2], "Path Name");
    NFAput_string (&data.data[3], "Flag?");
    NFAput_string (&data.data[4], "");
    NFAput_string (&data.data[5], "");
    NFAput_string (&data.data[6], "");
    NFAput_string (&data.data[7], "");

    for (i=pos, j=0; i<tot_data; i+=data.num_of_cols, j+=out_list->columns)
        {
        NFAput_string (&data.data[i], rmt_data_ptr[j+name_index]);
        NFAput_string (&data.data[i+1], def_revision);
        NFAput_string (&data.data[i+2], rmt_data_ptr[j+desc_index]);
        NFAput_string (&data.data[i+3], def_flag);
        }

    _NFMR_str("%s", "call SCprocess_column_form");

    /* process column form until file_name has been entered */
    do
     {
      FORM_FILLED = TRUE;
      status = SCprocess_column_form (&data, NFMprint_file);
      SCclear_msg ();

      _NFMR_num("return from SCprocess_column_form -> %d", data.sts);

      if (data.sts != FORM_CANCELED)
       {
         /* make string valid length and strip trailing blanks */
         for (i=pos; i<tot_data; i+=data.num_of_cols)
          {
            /* item name */
            status = NFAvalidate_string ("char(60)", data.data[i]);

            /* item revision */
            status = NFAvalidate_string ("char(15)", data.data[i+1]);

            /* item description */
            status = NFAvalidate_string ("char(50)", data.data[i+2]);

            /* automatic flagging? */
            status = NFAvalidate_string ("char(1)", data.data[i+3]);

            if (strcmp (data.data[i+3], "a") == 0)
                NFAput_string (&data.data[i+3], "A");

                if (strcmp (data.data[i+3], "b") == 0)
                    NFAput_string (&data.data[i+3], "B");

                if ((strcmp (data.data[i+3], "A") != 0) &&
                    (strcmp (data.data[i+3], "B") != 0) &&
                    (strcmp (data.data[i+3], "") != 0))
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM: Invalid Flag for <%s>.", data.data[i]);
                    SCdisplay_msg (msg);
                    }
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        _NFMR_str("%s", "Cancel from form. Return.");
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
        return (NFI_W_FORM_CANCELED);
        }

/*************************************************************************
Prepare to add items (get default storage area and ACL first time only
**************************************************************************/

    SCdisplay_msg ("Working..");

    status = NFMRvalidate_user_access (NFMuser_id, ADD_ITEM, "", "",
                                       NFMcatalog, "", "");
    if (status != NFM_S_SUCCESS)
        return (NFM_S_SUCCESS);

    status = NFMRquery_add_item_attributes (NFMuser_id, NFMcatalog,
                                            &attr_list, &data_list,
                                            &value_list);

    if (status != NFM_S_SUCCESS)
        {
        NFMerr_ret (status);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFMRset_error (status, "NFMbulk_load : NFMRquery_add_item_attributes.");
        return (status);
        }

    status = MEMbuild_array (attr_list);

    if (status != MEM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct(NFI,  NFI_E_MEMORY,  "%s%s",  "NFMadd_item", 
                       "MEMbuild_array");

       }
    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    NFMRfill_index (attr_list, &index);

    status = MEMbuild_array (value_list);

    pos2 = 15;
    data2.num_of_rows = data.num_of_rows + 1;
    data2.num_of_cols = 5;
    tot_data2 = data2.num_of_cols * data2.num_of_rows;
    data2.freeze_rows_count = 3;
    data2.select_set_expected = FALSE;
    data2.col_width = (int *) malloc (data2.num_of_cols * sizeof (int));
    memset (data2.col_width, 0, (data2.num_of_cols * sizeof (int)));
    
    data2.col_width[0] = 15;
    data2.col_width[1] = 15;
    data2.col_width[2] = 20;
    data2.col_width[3] = 8;
    data2.col_width[4] = 4;
    data2.new_rows_expected = FALSE;
    strcpy (data2.title, "Accept/Change Item Information");

    data2.selectable = (int *) malloc (tot_data2 * sizeof (int));
    memset (data2.selectable, 0, (tot_data2 * sizeof (int)));

    for (i=pos2+1; i<tot_data2; i+=data2.num_of_cols)
        {
        data2.selectable[i] = 1;
        data2.selectable[i+1] = 1;
        data2.selectable[i+2] = 1;
        data2.selectable[i+3] = 1;
        }

    data2.hidden = (int *) malloc (tot_data2 * sizeof (int));

    /* SSRS - 8/11/93 - data2.hidden casted to (char *) */
    memset ((char *)data2.hidden,  0,  (tot_data2 * sizeof (int)));

    /* allocate and initialize space to store data */

    data2.data = (char **) malloc (tot_data2 * sizeof (char *));
    memset (data2.data, NULL, (tot_data2 * sizeof (char *)));

    NFAput_string (&data2.data[0], "Item");
    NFAput_string (&data2.data[5], "Name");
    NFAput_string (&data2.data[10], "");

    NFAput_string (&data2.data[1], "Storage");
    NFAput_string (&data2.data[6], " Area");
    NFAput_string (&data2.data[11], "");

    NFAput_string (&data2.data[2], "ACL");
    NFAput_string (&data2.data[7], "Name");
    NFAput_string (&data2.data[12], "");

    NFAput_string (&data2.data[3], "Maximum");
    NFAput_string (&data2.data[8], "Versions");
    NFAput_string (&data2.data[13], "");

    NFAput_string (&data2.data[4], "File");
    NFAput_string (&data2.data[9], "Type");
    NFAput_string (&data2.data[14], "");

    status = MEMbuild_array (data_list);

    /* if there is a value list, display the list and let them
       choose the value */
   ROW_SELECT = TRUE;
    for (j=0, k=0; j<(attr_list->columns*attr_list->rows); j+=attr_list->columns, ++k)
     {
      if (strcmp (data_ptr[j+index.list], "0") != 0)
        {
         /* if there is a value list, display the list and let them
          choose the value */

          if (strcmp (data_ptr[j+index.name], "n_cisano") == 0)
            {
              strcpy (cisano_index, data_ptr[j+index.list]);
              status = NFMget_value_list_string (cisano_index,
                                           value_list, data_ptr[j+index.name],
                                           data_ptr[j+index.syn], storage_num,
                                           def_storage);

              _NFMR_str("NFMbulk_load :storage_num : <%s>", storage_num);

              _NFMR_str("NFMbulk_laod : def_storage : <%s>", def_storage);

              if (status != NFM_S_SUCCESS)
               {
                 MEMclose (&attr_list);
                 MEMclose (&value_list);
                 MEMclose (&data_list);
                 NFMRset_error(status,"NFMbulk_load:NFMget_value_list_string.");

                _NFMR_num("NFMbulk_load :NFMget_value_list_string : <0x%.8x>",  status);

                 return (NFM_S_SUCCESS);
                }
             }

         else if (strcmp (data_ptr[j+index.name], "n_aclno") == 0)
           {
             strcpy (aclno_index, data_ptr[j+index.list]);
             status = NFMget_value_list_string (aclno_index,
                                           value_list, data_ptr[j+index.name],
                                           data_ptr[j+index.syn], acl_num,
                                           def_acl);

            _NFMR_str ("NFMbulk_laod : acl_num : <%s>", acl_num);
            _NFMR_str ("NFMbulk_load : def_acl : <%s>", def_acl);

            if (status != NFM_S_SUCCESS)
             {
               MEMclose (&attr_list);
               MEMclose (&value_list);
               MEMclose (&data_list);
               NFMRset_error (status, "NFMbulk_load : NFMget_value_list_string.");
               return (NFM_S_SUCCESS);
              }
           }
        }
     }

    _NFMR_str ("NFMbulk_load : def_storage : <%s>", def_storage);
    _NFMR_str ("NFMbulk_load : def_acl     : <%s>", def_acl);

    for (i=pos2, j=pos; i<tot_data2; i+=data2.num_of_cols, j+=data.num_of_cols)
     {
        NFAput_string (&data2.data[i], data.data[j]);
        NFAput_string (&data2.data[i+1], def_storage);
        NFAput_string (&data2.data[i+2], def_acl);
        NFAput_string (&data2.data[i+3], def_versions);
        NFAput_string (&data2.data[i+4], def_type);
     }

    /* process column form until file_name has been entered */
    do
      {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data2, NFMprint_file);
        SCclear_msg ();

        _NFMR_num ("return from SCprocess_column_form -> %d", data2.sts);

        if (data2.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            for (i=pos2+1; i<tot_data2; i+=data2.num_of_cols)
                {
                /* storage area */
                status = NFAvalidate_string ("char(20)", data2.data[i]);
                status = NFMvalidate_list_entity (cisano_index, value_list,
                                                  "n_saname", data2.data[i],
                                                  storage_num);
                if (status != NFM_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM: Invalid Storage Area for <%s>",
                             data2.data[i-1]);
                    SCdisplay_msg (msg);
                    }

                /* ACL name */
                status = NFAvalidate_string ("char(20)", data2.data[i+1]);
                status = NFMvalidate_list_entity (aclno_index, value_list,
                                                  "n_aclname", data2.data[i+1],
                                                  acl_num);
                if (status != NFM_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM: Invalid ACL Name for <%s>",
                             data2.data[i-1]);
                    SCdisplay_msg (msg);
                    }


                /* max versions */
                status = NFAvalidate_string ("char(5)", data2.data[i+2]);

                /* file type */
                status = NFAvalidate_string ("char(5)", data2.data[i+3]);
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data2.sts != FORM_CANCELED));

    if (data2.sts == FORM_CANCELED)
        {

        NFAfree_list (data2.data, data2.num_of_rows, data2.num_of_cols);
        free (data2.data);

        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFMRset_error (FORM_CANCELED, "NFMbulk_load : Cancel Command.");
        ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
        return (NFI_W_FORM_CANCELED);
        }

    /* open bulk load status file */

    if ((status_file = fopen (status_file_name, "a+")) == NULL)
        {
        SCdisplay_msg ("NFM:  Cannot Open Bulk Load Output File.");
        return (NFM_E_FAILURE);
        }

    /* set up error data form */

    err_pos = 8;
    err_data.num_of_rows = data2.num_of_rows - 1;
    err_data.num_of_cols = 4;
    tot_err_data = err_data.num_of_cols * err_data.num_of_rows;
    err_data.freeze_rows_count = 2;
    err_data.select_set_expected = FALSE;
    err_data.col_width = (int *) malloc (err_data.num_of_cols * sizeof (int));
/* SSRS - 8/11/93 - err_data.col_width casted to (char *) */
   memset ((char *)err_data.col_width,  0,  (err_data.num_of_cols *sizeof (int)));
      
    err_data.col_width[0] = 15;
    err_data.col_width[1] = 15;
    err_data.col_width[2] = 15;
    err_data.col_width[3] = 16;
    err_data.new_rows_expected = FALSE;
    strcpy (err_data.title, "Status/Error Information");

    err_data.selectable = (int *) malloc (tot_err_data * sizeof (int));

    /* SSRS - 8/11/93 - err_data.selectable casted to (char *) */
    memset ((char *)err_data.selectable,  0,  (tot_err_data * sizeof (int)));

    err_data.hidden = (int *) malloc (tot_err_data * sizeof (int));

    /* SSRS - 8/11/93 - err_data.hidden casted to (char *) */
    memset ((char *)err_data.hidden,  0,  (tot_err_data * sizeof (int)));

    /* allocate and initialize space to store data */

    err_data.data = (char **) malloc (tot_err_data * sizeof (char *));
    memset (err_data.data, NULL, (tot_err_data * sizeof (char *)));

    NFAput_string (&err_data.data[0], "Item");
    NFAput_string (&err_data.data[1], "Add Status");
    NFAput_string (&err_data.data[2], "Checkin Status");
    NFAput_string (&err_data.data[3], "Auto Flag Status");
    NFAput_string (&err_data.data[4], "");
    NFAput_string (&err_data.data[5], "");
    NFAput_string (&err_data.data[6], "");
    NFAput_string (&err_data.data[7], "");

/* for each row:
    1. validate user access for "ADD ITEM" (except the first one)
    2. add the item (if user attributes, show form)
    3. set the to_state
    4. validate user access for "CHECKIN ITEM"
    5. prepare the item for checkin
    6. check in the item
    7. set the to_state
    8. if there is an automatic flag to be set:
       a. validate user access
       b. flag for either ARCHIVE or BACKUP
       c. set the to_state
*/

    NOT_FIRST_TIME = FALSE;

    for (i=pos2, m=pos, q=err_pos, r=0;
         i<tot_data2;
         i+=data2.num_of_cols, m+=data.num_of_cols, q+=err_data.num_of_cols,
         r+=out_list->columns)
        {
        /* insert item into error form */
        NFAput_string (&err_data.data[q], data.data[m]);

        VALIDATE_OK = TRUE;
        QUERY_OK = TRUE;
        ADD_OK = TRUE;

        if (NOT_FIRST_TIME)
            {
            /* We already validated for the first one to query for the
               attributes. (However, we MUST query every time). */

              status = NFMRvalidate_user_access (NFMuser_id, ADD_ITEM, "", "",
                                                  NFMcatalog, "", "");
            if (status != NFM_S_SUCCESS)
                {
                VALIDATE_OK = FALSE;
                sprintf (err_str, "Validate: %d", status);
                NFAput_string (&err_data.data[q+1], err_str);
                record_status (status_file, "VALIDATE: ADD ITEM",
                               data.data[m], data.data[m+1], status);
                }

            /* test to see whether or not this needs to be called
               for each item - YES, it must be called for each item! */
            status = NFMRquery_add_item_attributes (NFMuser_id, NFMcatalog,
                                                    &attr_list, &data_list,
                                                    &value_list);

            if (status != NFM_S_SUCCESS)
                {
                QUERY_OK = FALSE;
                sprintf (err_str, "Query: %d", status);
                NFAput_string (&err_data.data[q+1], err_str);
                record_status (status_file, "QUERY: ADD ITEM",
                               data.data[m], data.data[m+1], status);
                }

            status = MEMbuild_array (attr_list);

            data_ptr = (char **) attr_list->data_ptr;
            column_ptr = (char **) attr_list->column_ptr;

            NFMRfill_index (attr_list, &index);

            status = MEMbuild_array (value_list);
            status = MEMbuild_array (data_list);
            }

        NOT_FIRST_TIME = TRUE;

        /* if the validate was successful */
        if ((VALIDATE_OK) && (QUERY_OK))
            {
            ADD_OK = TRUE;
            /* insert the data to add each new item */

            for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
              {
                if (strcmp (data_ptr[j+index.name], "n_itemname") == 0)
                   status = MEMwrite_data (data_list, data.data[m], 1, k+1);

                else if (strcmp (data_ptr[j+index.name],  "n_cofilename")== 0)
                 {

                  status = MEMwrite_data (data_list, data.data[m], 1, k+1);
                 }

                else if (strcmp (data_ptr[j+index.name], "n_itemrev") == 0)
                   status = MEMwrite_data (data_list, data.data[m+1], 1, k+1);

                else if (strcmp (data_ptr[j+index.name], "n_itemdesc") == 0)
                   status = MEMwrite_data (data_list, data.data[m+2], 1, k+1);

                else if (strcmp (data_ptr[j+index.name], "n_cisano") == 0)
                  {
                    status = NFMvalidate_list_entity (cisano_index,value_list,
                              "n_saname", data2.data[i+1], storage_num);
                    status = MEMwrite_data (data_list, storage_num, 1, k+1);
                  }

                else if (strcmp (data_ptr[j+index.name], "n_aclno") == 0)
                  {
                    status = NFMvalidate_list_entity (aclno_index,value_list,
                              "n_aclname", data2.data[i+2], acl_num);
                         status = MEMwrite_data (data_list, acl_num, 1, k+1);
                  }

               else if (strcmp (data_ptr[j+index.name], "n_versionlimit") == 0)
                   status = MEMwrite_data (data_list, data2.data[i+3], 1, k+1);

                else if (strcmp (data_ptr[j+index.name], "n_filetype") == 0)
                   status = MEMwrite_data (data_list, data2.data[i+4], 1, k+1);

            }

         /* MEMprint_buffer("List data", data_list, "/dev/console");*/

            if (NFMRmsg_ptr.debug_on)
               MEMprint_buffer ("ADD ITEM", data_list, NFMRmsg_ptr.debug_file);

            /* if there are user attributes, allow keyin values */
            status = NFMuser_attr (attr_list, data_list, data.data[m]);
            if (status != NFM_S_SUCCESS)
             {
               status = NFI_W_FORM_CANCELED;
               _NFIdebug((fname, "retrun status is <0x%.8x>\n", status));
               ERRload_struct( NFM,  NFI_W_FORM_CANCELED,  NULL,  NULL );
               return (NFI_W_FORM_CANCELED); 
              }
                 
            sprintf (msg, "Adding Item <%s> ...", data.data[m]);
            SCdisplay_msg (msg);    

            if (NFMRmsg_ptr.debug_on)
             MEMprint_buffer ("DATA LIST", data_list, NFMRmsg_ptr.debug_file);

         status = NFMRadd_item (NFMuser_id, NFMcatalog, attr_list, data_list);

            if (status == NFI_W_COMMAND_CANCELLED)
               return(status);

            _NFMR_num("return from NFMRadd_item -> 0x%.8x", status);

            /* set the state for the "add item" */

             NFMRset_to_state (NFMuser_id, "NFM");
            
            if (status != NFM_S_SUCCESS)
             {
                ADD_OK=FALSE;
                sprintf (err_str, "Add: 0x%.8x", status);
                NFAput_string (&err_data.data[q+1], err_str);
              }
            else 
                 NFAput_string (&err_data.data[q+1], "Successful");

               record_status (status_file, "ADD ITEM",
                           data.data[m], data.data[m+1], status);

            /* if the add item was successful, checkin the item */
            if (ADD_OK)
             {
                /* validate the user for the "checkin" command */
          
               VALIDATE_OK = TRUE;

                   status = NFMRvalidate_user_access (NFMuser_id, CHECKIN_ITEM,
                   "", "", NFMcatalog, data.data[m], data.data[m+1]);

                if (status != NFM_S_SUCCESS)
                    {
                    VALIDATE_OK = FALSE;
                    sprintf (err_str, "Validate: %d", status);
                    NFAput_string (&err_data.data[q+2], err_str);
                    record_status (status_file, "VALIDATE: CHECKIN ITEM",
                                   data.data[m], data.data[m+1], status);

                    }
                 if (VALIDATE_OK)
                  {

                    sprintf (msg, "Checking In Item <%s> ...", data.data[m]);
                    SCdisplay_msg (msg);    

                
                    CHECKIN_OK = TRUE;
            		    strcpy (previous_path, present_path) ;
                           _NFMR_str("new path : <%s>", data.data[m+2]);
                           _NFMR_str("previous path : <%s>", previous_path) ;
                           _NFMR_num("delete flag : <%d>", delete_sa_flag) ;

                  if (strcmp (data.data [m+2],  previous_path))
                    {
	                if ((strcmp (previous_path, upper_level_path)) &&
	                     (delete_sa_flag))
                        {
			  _NFMR_str ("deleting saname <%s>",
				     saname) ;
                          /* do not delete upper level path */
                          status = NFMRdelete_storage_area (NFMuser_id, 
                                                           saname) ;
                          if (status != NFM_S_SUCCESS)
                          {
                            _NFMRdebug ((fname,  "ignoring error deleteting storagearea %s :status = <0x%.8x>\n", saname, status));
                            return(status);

                          }
                        }

                      /* insert path */
		       strcpy (present_path, data.data[m+2]) ;
                      status = MEMwrite_data (sa_data,  data.data[m+2], 
                                     1,  pathname_pos+1) ;
/*			MEMprint_buffers("with inserted path", sa_data, "/dev/console");*/

                      status = NFMRadd_return_sa_name (sa_attr, sa_data, 
                                        saname) ;
                      _NFMR_str( "Return the value of %s\n", saname);
                      _NFMR_num ("Return From NFMRadd_ret <0x%.8x>\n", status);


                    if ((status != NFM_S_SUCCESS) &&
	                  (status != NFM_E_DUP_ST_AREA))
                        {
	                      return(status);
                        } 
                    if (status == NFM_E_DUP_ST_AREA) 
		      {
                           delete_sa_flag = 0;
			   ERRreset_struct () ;
			 }

        			else 
                       delete_sa_flag = 1 ;
                   }
                 
 NFAset_global_config_info( NFM_WORKFLOW, CHECKIN_ITEM,NFMworkflow,"","NFM" );

  _NFMR_str("This is the value of i-1 %s\n", data2.data[i-1]);
  _NFMR_str("This is the value of i %s\n", data2.data[i]);
  _NFMR_str("This is the value of i+1 %s\n", data2.data[i+1]);


  status = NFMRcheckin_item (NFMcatalog,catalog_no,data.data[m],data.data[m+1],
   saname,NFAwf_info, NFAoperation);


   _NFMR_num ("return from NFMcheckin_item -> 0x%.8x", status);

        NFMRset_to_state (NFMuser_id, "NFM");

        if (status != NFM_S_SUCCESS)
         {
           CHECKIN_OK = FALSE;
           sprintf (err_str, "Checkin: %d", status);
           NFAput_string (&err_data.data[q+2], err_str);
         }
        else
           NFAput_string (&err_data.data[q+2], "Successful");
           record_status (status_file, "CHECKIN ITEM", data.data[m], 
                          data.data[m+1], status);
        if (CHECKIN_OK)
         {
          /* see if there is to be an automatic flag */

            if (strcmp (data.data[m+3], "") != 0)
             {
               /* need to flag the item for either ARCHIVE or BACKUP */

               sprintf (msg, "Flagging Item <%s> ...", data.data[m]);
               SCdisplay_msg (msg);    

               VALIDATE_OK = TRUE;

               if (strcmp (data.data[m+3], "A") == 0)
                {
                  /* flag the item for archive */

                  status = NFMRvalidate_user_access (NFMuser_id, 
                  FLAG_ITEM_ARCHIVE, "", "", NFMcatalog, data.data[m], 
                            data.data[m+1]);

                    if (status != NFM_S_SUCCESS)
                     {
                       VALIDATE_OK = FALSE;
                       sprintf (err_str, "Validate: %d", status);
                       NFAput_string (&err_data.data[q+3], err_str);

                       record_status (status_file,
                        "VALIDATE: FLAG ITEM FOR ARCHIVE",
                                         data.data[m], data.data[m+1], status);
                      }

                      if (VALIDATE_OK)
                      {
                        status = NFMRflag_item_archive (NFMuser_id, NFMcatalog,
                                      data.data[m], data.data[m+1]);

            _NFMR_num("return from NFMflag_item_archive -> 0x%.8x", status);

                      }
                  }

                  if (strcmp (data.data[m+3], "B") == 0)
                   {
                    /* flag the item for backup */

                     status = NFMRvalidate_user_access (NFMuser_id, 
                        FLAG_ITEM_BACKUP, "", "", NFMcatalog, 
                        data.data[m], data.data[m+1]);

                      if (status != NFM_S_SUCCESS)
                       {
                         VALIDATE_OK = FALSE;
                         sprintf (err_str, "Validate: %d", status);
                         NFAput_string (&err_data.data[q+3], err_str);
                         record_status (status_file,
                                    "VALIDATE: FLAG ITEM FOR BACKUP",
                                         data.data[m], data.data[m+1], status);
                        }

                        if (VALIDATE_OK)
                         {
                           status = NFMRflag_item_backup (NFMuser_id, 
                           NFMcatalog, data.data[m], data.data[m+1]);

          _NFMR_num("return from NFMflag_item_backup -> 0x%.8x", status);
                          }
                       }

            NFMRset_to_state (NFMuser_id, "NFM");
            if (status != NFM_S_SUCCESS)
             {
               sprintf (err_str, "Flag: %d", status);
               NFAput_string (&err_data.data[q+3], err_str);
             }

            else
               NFAput_string (&err_data.data[q+3], "Successful");

               record_status (status_file, "FLAG ITEM", data.data[m], 
                    data.data[m+1], status);

             }  /* end if ARCHIVE or BACKUP flag */

          }  /* end if COMPLETE_OK */

          MEMclose (&ci_attr);
          MEMclose (&ci_data);
  
       } /*end if VALIDATE_OK - Checkin */     

      }  /* end if ADD_OK */
    }  /* end if VALIDATE_OK - Add */

        /* test to see whether or not this needs to be called
           for each item */

        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);

      ERRreset_struct () ;

  }  /* end for each item */

    _NFMR_str("present_path : <%s>",  present_path) ;
    _NFMR_num("delete flag : <%d>",  delete_sa_flag);

       if ((strcmp(present_path, upper_level_path)) &&
	   (delete_sa_flag))
        {
           /* do not delet upper level path */
          status = NFMRdelete_storage_area(NFMuser_id, saname) ;
        }
        
        MEMclose (&sa_data);
        MEMclose (&sa_attr);
        MEMclose (&sa_value);

/***********************************************************************/

    MEMclose (&out_list);

    SCdisplay_msg ("<PF1> or <PF3> to cancel form.");

    status = SCprocess_column_form (&err_data, NFMprint_file);

 sprintf (msg,"NFM: Done Bulk Loading. See Ouput File <%s>.",status_file_name);
    SCdisplay_msg (msg);

    fclose (status_file);

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    NFAfree_list (data2.data, data2.num_of_rows, data2.num_of_cols);
    free (data2.data);
  
    NFAfree_list (err_data.data, err_data.num_of_rows, err_data.num_of_cols);
    free (err_data.data);

    return (NFM_S_SUCCESS); 
}
