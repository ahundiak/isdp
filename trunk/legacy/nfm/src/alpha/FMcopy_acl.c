#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"
#include "WFcommands.h"

long copy_acl_users ()

{
  long   status;
  int    i, j, k;
  int    tot_data;
  int    max_attr_len = 0;
  int    max_syn_len = 0;
  int    max_dtype_len = 0;
  int    pos;
  int    count = 0;
  int    FORM_FILLED;
  struct SCcolumn_data_st data;
  char   index_num[20];
  char   **n_data_ptr;
  char   **data_ptr;
  char   **column_ptr;
  char   acl_name [NFM_ACLNAME+1] ;
  char   title [512] ;
  char   old_work[200];
  char   string1[100];
  char   string2[100];
  char   object1[20];
  char   object2[20];
  long   wfno, offset ;
  MEMptr attr_list = NULL;
  MEMptr data_list = NULL; 
  MEMptr value_list = NULL;
  char   condition [200], value[200] ;
  NDXptr index;
  long type_pos, valueno_pos, name_pos, number_pos, new_number_pos ;
  struct SCfree_data_st ac_data;
  NFMlist list_struct;

  static char *fname = "NFAcopy_acl_users";
  
  SCdisplay_msg ("Working..");    
/*
  strcpy (NFMacl, "NFM_ITEM_ACL") ;
  strcpy (NFMworkflow, "NFM_ITEM_WORKFLOW") ;
*/
   if (strcmp(NFMacl,"") == 0)
    {

        if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ACLS, "%s", NFMworkflow)) != UMS_S_SUCCESS)
         {
          _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
          sprintf (title, "Choose ACL to Copy");
         }

          SCdisplay_msg ("Working..");

          NFAfill_list_struct (&list_struct, DSP_ACLS,
          SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1, "", "", "",
          "", "", NFMworkflow, "", title);

          status = NFAdisplay_elements (&ac_data, list_struct);
          NFAfree_list_struct (&list_struct);

          if (status != NFI_S_SUCCESS)
           return (status);

          for (i=0; i<ac_data.num_of_rows; ++i)
           {
              j = i * ac_data.num_of_cols;
              if (ac_data.select_set[i] == 1)
               {
                 strcpy(NFMacl, ac_data.data[j+1]);
                 break;
                }
            }

    NFAfree_list (ac_data.data, ac_data.num_of_rows, ac_data.num_of_cols);
    free (ac_data.data);
    SCdisplay_msg ("Working..");
  }

  /*** first form ****/
  strcpy (condition, "n_workflowtype = 'I'") ;
  status = NFMRquery_acl_attributes_condition (condition,
					       &attr_list,
					       &data_list,
					       &value_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list);
      MEMclose (&data_list) ;
      MEMclose (&value_list);
      return (status);
    }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      ERRload_struct(NFI, NFI_E_MEMORY,"%s%s","NFMcopy_acl","MEMbuild_array");
      return (NFI_E_FAILURE);
    }
  
  data_ptr = (char **) attr_list->data_ptr;
  
  NFMRfill_index (attr_list, &index);
  
  count = 0;
  for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
    {
      if ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
	  (strcmp (data_ptr[i+index.w], "Y") == 0))
	++count;
    }
  
  _NFIdebug ((fname, "Displayable fields : <%d>\n", count));
  
  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      ERRload_struct(NFI, NFI_E_MEMORY,"%s%s","NFMcopy_acl","MEMbuild_array");
      return (NFI_E_FAILURE);
    }
  
  n_data_ptr = (char **) data_list->data_ptr;
  column_ptr = (char **) data_list->column_ptr;
  
  status = MEMbuild_array (value_list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      ERRload_struct(NFI, NFI_E_MEMORY,"%s%s","NFMcopy_acl","MEMbuild_array");
      return (NFI_E_FAILURE);
    }
  
  data.num_of_rows = count;
  data.num_of_cols = 3;
  tot_data = data.num_of_cols * data.num_of_rows;
  data.freeze_rows_count = 0;
  data.select_set_expected = FALSE;
  data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
  memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
  
  data.col_width[0] = 15;
  data.col_width[1] = 10;
  data.col_width[2] = 20;
  data.new_rows_expected = FALSE;
  strcpy (data.title, "Enter Access Control List Name");
  
  data.selectable = (int *) malloc (tot_data * sizeof (int));
  memset (data.selectable, 0, (tot_data * sizeof (int)));
  
  for (i=0; i<tot_data; i+=data.num_of_cols)
    data.selectable[i+2] = 1;
  
  data.hidden = (int *) malloc (tot_data * sizeof (int));
  memset (data.hidden, 0, (tot_data * sizeof (int)));
  
  /* allocate and initialize space to store data */
  
  data.data = (char **) malloc (tot_data * sizeof (char *));
  memset (data.data, NULL, (tot_data * sizeof (char *)));
  
  NFAput_string (&data.data[0], "ACL Name");
  
  for (i=0, j=0; i<tot_data; j+=attr_list->columns)
    {
      if ((strcmp (data_ptr[j+index.r], "Y") == 0) &&
	  (strcmp (data_ptr[j+index.w], "Y") == 0))
	{
	  if (strcmp (data_ptr[j+index.syn], "") != 0)
	    NFAput_string (&data.data[i], data_ptr[j+index.syn]);
	  else
	    NFAput_string (&data.data[i], data_ptr[j+index.name]);
	  NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
	  i+=data.num_of_cols;
	}
    }
  
  for (i=2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
    {
      if ((strcmp (data_ptr[j+index.r], "Y") == 0) &&
	  (strcmp (data_ptr[j+index.w], "Y") == 0))
	{
	  /* see if there is a value list for this attribute */
	  if (strcmp (data_ptr[j+index.list], "0") == 0)
	    {
	      /* if not, insert data from the data list */
	      NFAput_string (&data.data[i], n_data_ptr[k]);
	      i+=data.num_of_cols;
	    }
	  else
	    {
	      /* if so display the list and let them choose the value */
              status = NFAget_value_list_index_workflow (data_ptr[j+index.list]
                , value_list, data_ptr[j+index.name],
	          data_ptr[j+index.syn], index_num);
	      if (status != NFI_S_SUCCESS)
		{
		  MEMclose (&attr_list);
		  MEMclose (&value_list);
		  MEMclose (&data_list);
		  return (status);
		}
	      
	      NFAput_string (&data.data[i], index_num);
	      data.selectable[i] = 0;
	      
	      /* if this is a workflow value list, save the workflow name */
	      if (strcmp (data_ptr[j+index.nfm], "n_workflowno") == 0)
		{
		  status = NFAget_value_list_name (data_ptr[j+index.list],
						   value_list, index_num, NFMworkflow);

		  if (status != NFI_S_SUCCESS)
		    {
		      MEMclose (&attr_list);
		      MEMclose (&value_list);
		      MEMclose (&data_list);
		      return (status);
		    }
		}
	      i+=data.num_of_cols;
	    }
	}
    }
  
  _NFIdebug ((fname, "workflow : <%s>\n", NFMworkflow));
  
  /* process column form until an ACL Name has been entered */
  do
    {
      FORM_FILLED = TRUE;
      status = SCprocess_column_form (&data, NFMprint_file);
      SCclear_msg ();
      
      _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));
      
      if (data.sts != FORM_CANCELED)
	{
	  status = NFAput_and_validate_data (data.data, 2, tot_data,
					     data.num_of_cols);
	  
	  /* if attribute is required ("n_null" == "N"),
	     user must keyin a value */
	  
	  status = NFAvalidate_nulls (attr_list, index, data, 2,
				      &FORM_FILLED);
	}
    }
  while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));
  
  if (data.sts == FORM_CANCELED)
    {
      NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
      free (data.data);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      return (NFI_W_COMMAND_CANCELLED);
    }
  
  for (i=0; i<tot_data; i+=data.num_of_cols)
    {
      for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
	{
	  if (((strcmp (data_ptr[j+index.syn], data.data[i]) == 0) ||
	       (strcmp (data_ptr[j+index.name], data.data[i]) == 0)) &&
	      (strcmp (data_ptr[j+index.w], "Y") == 0))
	    {
	      status = MEMwrite_data (data_list, data.data[i+2], 1, k+1);
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (&attr_list);
		  MEMclose (&data_list);
		  MEMclose (&value_list);
		  NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
		  free (data.data);
		  ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMcopy_acl",
				 "MEMwrite_data");
		  return (NFI_E_FAILURE);
		}
	      if (strcmp (data_ptr[j+index.nfm], "n_aclname") == 0)
		strcpy (acl_name, data.data[i+2]);
	      else if (strcmp (data_ptr[j+index.nfm], "n_workflowno") == 0)
		wfno = atol (data.data[i+2]) ;
	      break;
	    }
	}
    }
  
  _NFIdebug ((fname, "ACL Name : <%s>\n", acl_name));
  _NFIdebug ((fname, "Workflow No : <%d>\n", wfno));

  NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
  free (data.data);
  
  _NFIdebug ((fname, "NFMcopy_acl_users -> <0x%.8x>\n", status));
  
  
  MEMclose (&attr_list) ;
  MEMclose (&data_list) ;
  MEMclose (&value_list) ;

  /*** second form ****/

  SCdisplay_msg("Working..") ;
  status = NFMRget_acl_classes_for_copy  (NFMacl, wfno,
					  &attr_list,
					  &value_list);
  
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&attr_list);
      MEMclose (&value_list);
      return (status);
    }
  
  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&attr_list);
      MEMclose (&value_list);
      ERRload_struct(NFI, NFI_E_MEMORY, "%s%s", "NFMcopy_acl",
		     "MEMbuild_array");
      return (status);
    }
  
  data_ptr = (char **) attr_list->data_ptr;
  column_ptr = (char **) attr_list->column_ptr;

  for (i=0; i<attr_list->columns; i++)
  {
	if (strcmp (column_ptr[i], "type") == 0) type_pos = i ;
        else if (strcmp (column_ptr[i], "name") == 0) name_pos = i ; 
        else if (strcmp (column_ptr[i], "number") == 0) number_pos = i ; 
        else if (strcmp (column_ptr[i], "new_number") == 0) new_number_pos = i ; 
        else if (strcmp (column_ptr[i], "n_valueno") == 0) valueno_pos = i ; 
  } 
  
  for (i=0; i<attr_list->rows; ++i)
    {
	offset = i*attr_list->columns ;
	sprintf (title, "") ;

	if (strcmp (data_ptr[offset+type_pos], "class") == 0)
	    {
	    strcpy (object1, "class");
	    strcpy (object2, "users");
	    }
	else
	    {
	    strcpy (object1, "signoff state");	
	    strcpy (object2, "signoff users");	
	    }
	sprintf (string1, "Choose %s in old ACL '%s' for %s in %s", object1, 
            NFMacl,object2, object1);
	sprintf (string2, "'%s' of new ACL '%s'", data_ptr [offset+name_pos], acl_name);
        status = NFAget_value_list_index_header (value_list,
                                              atol(data_ptr [offset+valueno_pos]),
					      title,
					      value, string1, string2) ; 
	if (status != NFI_S_SUCCESS) 
        {
	   MEMclose (&attr_list) ;
	   MEMclose (&value_list) ;
	   return (status) ;
        }
	status = MEMwrite_data (attr_list, value, i+1, new_number_pos+1) ;
	if (status != MEM_S_SUCCESS)
        {
          _NFIdebug ((fname, "MEMwrite_data : failed = <0x%.8x>\n", status));
          ERRload_struct (NFI, NFI_E_MEM, "", "") ;
	  return (NFI_E_MEM) ;
        }
	_NFIdebug ((fname, "selection for <%s> was <%s>\n", 
                   data_ptr[offset+type_pos], value)) ;
   }
  
  SCdisplay_msg ("Working..");    

  if (_NFMdebug_st.NFIdebug_on)  
       MEMprint_buffer ("attr_list", attr_list, 
	_NFMdebug_st.NFIdebug_file) ;
  
  status = NFMRcopy_acl_users (acl_name, 
			 wfno,
			 NFMacl,
			 attr_list) ;
  
  _NFIdebug(( fname, "Return from NFMcopy_acl -> 0x%.8x\n", status));
  
  MEMclose (&attr_list);
  MEMclose (&data_list);
  MEMclose (&value_list);

  strcpy(NFMacl, acl_name);

  if (status != NFM_S_SUCCESS)
    return (status);
  
  NFAmake_msg (msg);
  _NFIdebug(( fname, "%s\n", msg));
  SCdisplay_ref (msg);
	
  return (NFI_S_SUCCESS);
}





