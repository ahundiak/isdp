#include "machine.h"
#include <stdio.h>

# include "CLIstruct.h"
#include "NFIerrordef.h"
/* ifdef UNIX changed to OS_UNIX -- MVR 27 Dec 1993*/
#ifdef OS_UNIX
#include "CLI.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "DEBUG.h"
#include "ERR.h"
#else
# include "CLIerrordef.h"
# include "CLIextern.h"
# include "NFMerrordef.h"
#include "NETstruct.h"
# include "proto.h"
# include <memcheck.h>

#endif
# include "WFcommands.h"

extern struct add_item_info ADD_ITEM_st ;
/* ifndef UNIX changed to OS_UNIX -- MVR 27 Dec 1993*/
#ifndef OS_UNIX
    extern char *buffer ;
#endif

long  CLIadd_item( )
{
    long  interactive, process ;
/* ifdef UNIX changed to OS_UNIX -- MVR 27 Dec 1993*/
#ifdef OS_UNIX
    long clix_add_item () ;
#else
    long pc_add_item ();
#endif

    _CLI_str( "%s", "Entering CLIadd_item" );
    interactive = 0 ;
    process = 0 ;

    fprintf (stderr, "Working..\n") ;
/* ifdef UNIX changed to OS_UNIX -- MVR 27 Dec 1993*/
#ifdef OS_UNIX
    clix_add_item () ;
#else
    pc_add_item () ;
#endif
    
    _CLI_str( "%s", "Exiting CLIadd_item" );
    
    return( CLI_S_SUCCESS );
  }
    
/* ifdef UNIX changed to OS_UNIX -- MVR 27 Dec 1993*/
#ifdef OS_UNIX
long clix_add_item ()
{
  char *fname = "clix_add_item" ;
  long status ;
  int   subsystem;
  MEMptr attr_list = NULL, data_list = NULL, value_list = NULL ;
  long   col, null_offset=-1, name_offset=-1, offset, i, write_offset =-1;
  long   list_no, z, offset_z, valueno_offset=-1 ;
  char **column, **data=NULL, **value_ptr, **data1;
  char tmp_str [1024] ;
  char  message[256] = {"\0"};
  char aclMsg[1024], tt_str[128], cisaMsg[1024];
  long  user_id = 0;
  long  interactive, process ;
  long  err_no=NFM_S_SUCCESS;
  long  process_mode  ;

  interactive = 0 ; process = 0 ;  process_mode = 0 ;
  do
    {
      ERRreset_struct () ;
/* if in process mode do not validate or query */
      if (! process_mode)
	{
	  status = NFMRvalidate_user_access ( user_id, ADD_ITEM, 
					     "NFM_ITEM_WORKFLOW",
					     "",
					     CLIcatalog, "", "");
	  
	  if (status != NFM_S_SUCCESS)
	    {
	      ERRget_message( message );
	      ERRreset_struct();
	      _CLI_num( "Validate user access Message : <0x%.8lx>", status );
	      _CLI_str( "Validate user access Message : %s", message );
	      CLIprint( CLIout_file, "Validate User Access Message : %s", 
		       message) ;
	      CLIprint( stderr, "Validate User Access Message : %s", message) ;
	      MEMclose (&attr_list) ;
	      MEMclose (&data_list) ;
	      MEMclose (&value_list) ;
	      CLIreset_add_item_st () ;
	      return( CLI_E_FAILURE );
	    }
	  
	  
	  status = NFMRquery_add_item_attributes (user_id, CLIcatalog,
						  &attr_list, &data_list,
						  &value_list) ;
	  
	  if (status != NFM_S_SUCCESS)
	    {
	      ERRget_message( message );
	      ERRreset_struct();
	      _CLI_num( "Failure :  <0x%.8lx>", status );
	      _CLI_str( "Failure : %s", message );
	      CLIprint( CLIout_file, "NFMRquery_add_item_attributes Message : %s", message) ;
	      CLIprint( stderr, "NFMRquery_add_item_attributes Message : %s", 
		       message) ;
	      MEMclose (&attr_list) ;
	      MEMclose (&data_list) ;
	      MEMclose (&value_list) ;
	      CLIreset_add_item_st () ;
	      return( CLI_E_FAILURE );
	    }
	  
	  status = MEMbuild_array (attr_list) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&attr_list) ;
	      MEMclose (&data_list) ;
	      MEMclose (&value_list) ;
	      CLIreset_add_item_st () ;
	      _CLI_num ("MEMbuild_array : status = <0x%.8x>", status) ;
	      return (NFM_E_MEM) ;
	    }
	  
	  column = (char **) attr_list->column_ptr ;
	  data = (char **) attr_list -> data_ptr ;
	  
	  status = MEMbuild_array (data_list) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _CLI_num ("MEMbuild_array : status = <0x%.8x>", status) ;
	      MEMclose (&attr_list) ;
	      MEMclose (&data_list) ;
	      MEMclose (&value_list) ;
	      CLIreset_add_item_st () ;
	      return (NFM_E_MEM) ;
	    }
	  
	  data1 = (char **) data_list->data_ptr ;
	  
	  name_offset = -1 ; null_offset = -1 ; write_offset = -1;
	  for (i=0; i<attr_list->columns; i++)
	    {
	      if (strcmp (column [i], "n_name") == 0) name_offset = i ;
	      else if (strcmp (column [i], "n_null") == 0) null_offset = i ;
	      else if (strcmp (column [i], "n_write") == 0) write_offset = i ;
	      else if (strcmp (column [i], "n_valueno") == 0) valueno_offset = i ;
	    }
	  
	  /**** get defaults *****/
	  for (i=0; i<attr_list->rows; i++)
	    {
	      offset = i*attr_list->columns ;
	      _CLI_str ("comparing <%s>", data[offset+name_offset]) ;
	      _CLI_str ("data is <%s>", data1[i]) ;
	      if (strcmp (data[offset+name_offset], "n_itemname") == 0)
		{
		  strcpy (ADD_ITEM_st.item, data1[i]) ;
		}
	      else if (strcmp (data[offset+name_offset], "n_itemrev") == 0)
		{
		  strcpy (ADD_ITEM_st.rev, data1[i]) ;
		}
	      else if (strcmp (data[offset+name_offset], "n_itemdesc") == 0)
		{
		  strcpy (ADD_ITEM_st.description,data1[i]) ;
		}
	      else if (strcmp (data[offset+name_offset], "n_versionlimit") == 0)
		{
		  strcpy (ADD_ITEM_st.version, data1[i]) ;
		}
	      else if (strcmp (data[offset+name_offset], "n_aclno") == 0)
		{
		  if (strlen(data1[i]))
		    {
		      list_no = atol (data [offset + valueno_offset]) ;
		      _CLI_num ("reset to acl <%d>", list_no) ;
		      if ((status = MEMreset_buffer_no
			   (value_list, list_no)) != MEM_S_SUCCESS)
			{
			  _CLI_num ("MEMreset_buffer_no = <0x%.8x>", status) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_MEM);
			}
		      
		      _CLI_num ("value list has %d rows", value_list->rows) ;
		      
		      value_ptr = (char **) value_list->data_ptr ;
		      
		      for (z=0; z<value_list->rows;z++)
			{
			  offset_z = z*(value_list->columns) ;
			  _CLI_str ("Comparing <%s> ", data1[i]);
			  _CLI_str (" with <%s>", value_ptr[offset_z]) ;
 
                          /* 8/3/94 TR 249203127 */
                          if (z > 0)
                          {
                            sprintf (tt_str, " or %s", value_ptr[offset_z]);
                            strcat (aclMsg, tt_str);
                          }
                          else
                            strcpy (aclMsg, value_ptr[offset_z]);
			  
			  if (strcmp (data1[i],
				      value_ptr[offset_z]) == 0)
			    {
			      strcpy (ADD_ITEM_st.aclname, value_ptr[offset_z+2]) ;
			      _CLI_str ("aclno is <%s>", ADD_ITEM_st.aclname) ;
			      break ;
			    }
			}
                      /* 8/3/94 TR 249203127 */
                      if (z == value_list->rows)
                      {
                        CLIprint (stderr, 
                          "Input ACL <%s> is not acceptable, please use <%s>", data1[i], aclMsg);
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        CLIreset_add_item_st ();
                        return (NFM_E_FAILURE);
                      }
		    }
		}
	      else if (strcmp (data[offset+name_offset], "n_cofilename") == 0)
		{
		  strcpy (ADD_ITEM_st.localfile, data1[i]) ;
		}
	      else if (strcmp (data[offset+name_offset], "n_filetype") == 0)
		{
		  strcpy (ADD_ITEM_st.filetype, data1[i]) ;
		}
	      else if (strcmp (data[offset+name_offset], "n_cisano") == 0)
		{
		  if (strlen(data1[i]))
		    {
		      list_no = atol (data [offset + valueno_offset]) ;
		      if ((status = MEMreset_buffer_no
			   (value_list, list_no)) != MEM_S_SUCCESS)
			{
			  _CLI_num ("MEMreset_buffer_no = <0x%.8x>", status) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_MEM);
			}
		      
		      _CLI_num ("value list has %d rows", value_list->rows) ;
		      
		      value_ptr = (char **) value_list->data_ptr ;
		      
		      for (z=0; z<value_list->rows;z++)
			{
			  offset_z = z*(value_list->columns) ;
			  _CLI_str ("Comparing <%s> ", data1[i]);
			  _CLI_str (" with <%s>", value_ptr[offset_z]) ;
                          /* 8/3/94 TR 249203127 */
                          if (z > 0)
                          {
                            sprintf (tt_str, " or %s", value_ptr[offset_z]);
                            strcat (cisaMsg, tt_str);
                          }
                          else
                            strcpy (cisaMsg, value_ptr[offset_z]);
			  
			  if (strcmp (data1[i],
				      value_ptr[offset_z]) == 0)
			    {
			      strcpy (ADD_ITEM_st.cisaname, value_ptr[offset_z+1]) ;
			      _CLI_str ("storagearea is <%s>", ADD_ITEM_st.cisaname) ;
			      break ;
			    }
			}
                      /* 8/3/94 TR 249203127 */
                      if (z == value_list->rows)
                      {
                        CLIprint (stderr, "Input storage area <%s> is not acceptable, please use <%s>",  data1[i], cisaMsg);
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        CLIreset_add_item_st ();
                        return (NFM_E_FAILURE);
                      }
 
		    }
		}
	      else if (strcmp (data[offset+name_offset], "n_cifilename") == 0)
		{
		  strcpy (ADD_ITEM_st.cifile, data1[i]) ;
		}
	    }
	}
/*      process_mode = 0 ; */
      status = CLIedit_ai_mode ( &interactive, &process, process_mode );
      if (status != CLI_S_SUCCESS)
	{
	  /* cancel out */
	  /* load cancel command */
	  ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, "", "") ;
	  ERRget_message( message );
	  ERRget_number( &err_no, &subsystem );
	  NFMRset_wf_state ( "NFM", err_no, message ) ;
	  fprintf (stderr, "   Command Cancelled\n") ;
	  MEMclose (&attr_list) ;
	  MEMclose (&data_list) ;
	  MEMclose (&value_list) ;
	  CLIreset_add_item_st () ;
	  return (CLI_S_SUCCESS) ;
	}
      
      /* check for non-null values */
      for (i=0; i<attr_list->rows; i++)
	{
	  col = 0 ;
	  offset = attr_list->columns*i;
      /* not null value */
	  if (strcmp (data [offset+write_offset], "Y") == 0)
	    {
	      tmp_str [0] = 0 ;
	      if (strcmp (data [offset+name_offset], "n_itemname") == 0)
		{
		  col = i ;
		  if (strlen (ADD_ITEM_st.item))
		    strcpy (tmp_str, ADD_ITEM_st.item) ;
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  _CLI_str ("column <%s> can not be null",
				    data [offset+name_offset]) ; 
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ; 
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		  
		}
	      else if (strcmp (data [offset+name_offset], "n_itemrev") == 0)
		{
		  col = i;
		  if (strlen (ADD_ITEM_st.rev))
		    strcpy (tmp_str, ADD_ITEM_st.rev);
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  _CLI_str ("column <%s> can not be null\n",
				    data [offset+name_offset]) ;
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		}
	      else if (strcmp (data [offset+name_offset], "n_itemdesc") == 0)
		{
		  col = i;
		  if (strlen (ADD_ITEM_st.description))
		    strcpy (tmp_str, ADD_ITEM_st.description);
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  _CLI_str ("column <%s> can not be null",
				    data [offset+name_offset]) ;
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		}
	      else if (strcmp (data [offset+name_offset], "n_versionlimit") == 0)
		{
		  col = i;
		  if (strlen (ADD_ITEM_st.version))
		    strcpy (tmp_str, ADD_ITEM_st.version);
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		}
	      else if (strcmp (data [offset+name_offset], "n_aclno") == 0)
		{
		  col = i;
		  /********* go thru value list and get aclno *************/
		  if (strlen (ADD_ITEM_st.aclname))
		    {
		      list_no = atol (data [offset + valueno_offset]) ;
		      _CLI_num ("reset to acl <%d>", list_no) ;
		      if ((status = MEMreset_buffer_no
			   (value_list, list_no)) != MEM_S_SUCCESS)
			{
			  _CLI_num ("MEMreset_buffer_no = <0x%.8x>", status) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_MEM);
			}
		      
		      _CLI_num ("value list has %d rows", value_list->rows) ;
		      
		      value_ptr = (char **) value_list->data_ptr ;
		      
		      for (z=0; z<value_list->rows;z++)
			{
			  offset_z = z*(value_list->columns) ;
			  _CLI_str ("Comparing <%s> ", ADD_ITEM_st.aclname) ;
			  _CLI_str (" with <%s>", value_ptr[offset_z+2]) ;

                          /* 8/3/94 TR 249203127 */
                          if (z > 0)
                          {
                            sprintf (tt_str, " or %s", value_ptr[offset_z+2]);
                            strcat (aclMsg, tt_str);
                          }
                          else
                            strcpy (aclMsg, value_ptr[offset_z+2]);

			  
			  if (strcmp (ADD_ITEM_st.aclname, 
				      value_ptr[offset_z+2]) == 0)
			    {
			      strcpy (tmp_str, value_ptr[offset_z]) ;
			      _CLI_str ("aclno is <%s>", tmp_str) ;
			      break ;
			    }
			}

                      /* 8/3/94 TR 249203127 */
                      if (z == value_list->rows)
                      {
                        CLIprint (stderr, 
                          "Input ACL <%s> is not acceptable, please use <%s>", ADD_ITEM_st.aclname, aclMsg);
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        CLIreset_add_item_st ();
                        return (NFM_E_FAILURE);
                      }
		    }
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  _CLI_str ("column <%s> can not be null",
				    data [offset+name_offset]) ;
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		}
	      else if (strcmp (data [offset+name_offset], "n_cofilename") == 0)
		{
		  col = i;
		  if (strlen (ADD_ITEM_st.localfile))
		    strcpy (tmp_str, ADD_ITEM_st.localfile);
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  _CLI_str ("column <%s> can not be null",
				    data [offset+name_offset]) ;
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		}
	      else if (strcmp (data [offset+name_offset], "n_filetype") == 0)
		{
		  col = i;
		  if (strlen (ADD_ITEM_st.filetype))
		    strcpy (tmp_str, ADD_ITEM_st.filetype);
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  _CLI_str ("column <%s> can not be null",
				    data [offset+name_offset]) ;
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		}
	      else if (strcmp (data [offset+name_offset], "n_cisano") == 0)
		{
		  col = i;
		  /********* go thru value list and get aclno *************/
		  if (strlen (ADD_ITEM_st.cisaname))
		    {
		      list_no = atol (data [offset + valueno_offset]) ;
		      _CLI_num ("reset to acl <%d>", list_no) ;
		      if ((status = MEMreset_buffer_no
			   (value_list, list_no)) != MEM_S_SUCCESS)
			{
			  _CLI_num ("MEMreset_buffer_no = <0x%.8x>", status) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_MEM);
			}
		      
		      _CLI_num ("value list has %d rows", value_list->rows) ;
		      
		      value_ptr = (char **) value_list->data_ptr ;
		      
		      for (z=0; z<value_list->rows;z++)
			{
			  offset_z = z*(value_list->columns) ;
			  _CLI_str ("Comparing <%s> ", ADD_ITEM_st.cisaname) ;
			  _CLI_str (" with <%s>", value_ptr[offset_z+1]) ;
			  
                          /* 8/3/94 TR 249203127 */
                          if (z > 0)
                          {
                            sprintf (tt_str, " or %s", value_ptr[offset_z+1]);
                            strcat (cisaMsg, tt_str);
                          }
                          else
                            strcpy (cisaMsg, value_ptr[offset_z+1]);

			  if (strcmp (ADD_ITEM_st.cisaname, value_ptr[offset_z+1]) == 0)
			    {
			      strcpy (tmp_str, value_ptr[offset_z]) ;
			      _CLI_str ("cisano is <%s>", tmp_str) ;
			      break ;
			    }
			}

                      /* 8/3/94 TR 249203127 */
                      if (z == value_list->rows)
                      {
                        CLIprint (stderr, "Input storage area <%s> is not acceptable, please use <%s>",  ADD_ITEM_st.cisaname, cisaMsg);
                        MEMclose (&attr_list);
                        MEMclose (&data_list);
                        MEMclose (&value_list);
                        CLIreset_add_item_st ();
                        return (NFM_E_FAILURE);
                      }
		    }
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  _CLI_str ("column <%s> can not be null",
				    data [offset+name_offset]) ;
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		}
	      else if (strcmp (data [offset+name_offset], "n_cifilename") == 0)
		{
		  col = i;
		  if (strlen (ADD_ITEM_st.cifile))
		    strcpy (tmp_str, ADD_ITEM_st.cifile);
		  else
		    {
		      if (strcmp (data [offset+null_offset], "N") == 0)
			{
			  _CLI_str ("column <%s> can not be null",
				    data [offset+name_offset]) ;
			  CLIprint (stderr, "column <%s> can not be null",
				    data [offset+name_offset]) ;
			  MEMclose (&attr_list) ;
			  MEMclose (&data_list) ;
			  MEMclose (&value_list) ;
			  CLIreset_add_item_st () ;
			  return (NFM_E_FAILURE) ;
			}
		      else continue ;
		    }
		}
	      else 
		{
		  /* user define attributes */
		}
	      if (strlen (tmp_str))
		{
		  status = MEMwrite_data (data_list, tmp_str, 1, col+1);
		  if (status != MEM_S_SUCCESS)
		    {
		      _CLI_num ("MEMwrite_data <0x%.8x>", status) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		      MEMclose (&attr_list) ;
		      MEMclose (&data_list) ;
		      MEMclose (&value_list) ;
		      CLIreset_add_item_st () ;
		      return (NFM_E_MEM) ;
		    }
		}
	    }
	}
      
      status = NFMRadd_item( user_id,CLIcatalog, 
			    attr_list, data_list) ;
      
      ERRget_message( message );
      ERRget_number( &err_no, &subsystem );
      
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_num("Add item Message : <0x%.8lx>", status);
	  _CLI_str("Add item Message : %s", message);
	  CLIprint (CLIout_file,
		    "Add item <%s.%s> from catalog <%s> Message : %s",
		    ADD_ITEM_st.item, ADD_ITEM_st.rev, CLIcatalog, message) ;
	  CLIprint (stderr,
		    "Add item <%s.%s> from catalog <%s> Message : %s",
		    ADD_ITEM_st.item, ADD_ITEM_st.rev, CLIcatalog, message) ;
	}
      
      if (NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS)
	{
	  ERRget_message( message );
	  ERRreset_struct();
	  _CLI_str( "%s : Set to State Message", fname );
	  CLIprint( CLIout_file, "Add item Message : %s", message);
	  CLIprint( stderr, "Add item Message : %s",message);
	  MEMclose (&attr_list) ;
	  MEMclose (&data_list) ;
	  MEMclose (&value_list) ;
	  CLIreset_add_item_st () ;
	  return( CLI_E_FAILURE );
	}	
      
      process_mode = 0 ;
      if (status  != NFM_S_SUCCESS)
	{  
	  _CLI_str("%s : EXIT", fname);
	  if (interactive) process_mode = 1 ;
	  if (process) process_mode = 1 ;
	}
      else
	{
	  /******* SUCCESSFUL either pc or clix *********/
	  fprintf( CLIout_file, "   Successful Add item.\n" );
	  fprintf( stderr , "   Successful Add item.\n" );
	  strcpy (CLIitem, ADD_ITEM_st.item) ;
	  strcpy (CLIrev, ADD_ITEM_st.rev) ;
/*	  if ((interactive) && (process)) process_mode = 1 ; */
	  if (process) process_mode = 1 ;
	}
    } while (process_mode) ;

  MEMclose (&attr_list) ;
  MEMclose (&data_list) ;
  MEMclose (&value_list) ;
  CLIreset_add_item_st () ;

  return (CLI_S_SUCCESS) ;
}
#else

long pc_add_item ()
{
  char *fname = "pc_add_item" ;
  long status, err_no, interactive, process, process_mode ;
  char returned_string[256] = {"\0"};
  short *size_array_ptr, *size_array_ptr1 ;
  char *data, *data1, message [512] ;
  struct NETbuffer_info *struct_ptr ;
  long rows, cols, *long_ptr, y ;
  short *block_size_ptr, next_block_size ;
  
  _CLI_str ("%s : ENTER", fname) ;

  interactive = 0 ; process = 0 ;  process_mode = 0 ;
  do
    {
/* if in process mode do not validate or query */
      if (! process_mode)
	{
	  /* validate user access and query_add_item */

	  status = NFMRvalidate_user_access ( 0, ADD_ITEM, 
					     "NFM_ITEM_WORKFLOW",
					     "",
					     CLIcatalog, "", "");
	  
	  if (status != NFM_S_SUCCESS)
	    {
	      _CLI_str( "Validate user access Message : <0x%.8lx>", status );
	      CLIprint( stderr, "Validate User Access Message\n") ;
	      CLIreset_add_item_st () ;
	      return( CLI_E_FAILURE );
	    }
	  
	  status = NFMRpc_query_add_item () ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _CLI_str( "PC query_add_item Message : <0x%.8lx>",
		       status );
	      CLIreset_add_item_st () ;
	      return( CLI_E_FAILURE );
	    }
	  _CLI_str ("skip the header %s", "") ;
/**** SKIP THE HEADER *****/
	  struct_ptr = (struct NETbuffer_info *) buffer ;
	  long_ptr = (long *) (buffer+sizeof (struct NETbuffer_info)) ;
	  rows = *long_ptr ; ++long_ptr ;
	  cols = *long_ptr ; ++long_ptr ;
	  _CLI_num ("rows <%d>", rows) ;
	  _CLI_num ("cols <%d>", cols) ;

	  block_size_ptr = (short *) long_ptr ;

	  next_block_size = *block_size_ptr ;
	  _CLI_num ("first block size <%d>", next_block_size) ;
/*** FIRST ROW HAS COLUMN NAME ***/	  
	  size_array_ptr = (long)block_size_ptr+sizeof(short) ;
	  size_array_ptr1 = (long)block_size_ptr+(long)next_block_size+sizeof(short) ;
	  data = ((char *) (long)size_array_ptr +  (cols * sizeof (short))) ;
	  data1 = ((char *) (long)size_array_ptr1 +  (cols * sizeof (short))) ;
	  for (y=0; y<cols; y++)
	    {
	      _CLI_str ("comparing <%s>", data) ;
	      _CLI_str ("store <%s>", data1) ;
	      if (strncmp (data, "n_itemname", 10) == 0)
		{
		  strcpy (ADD_ITEM_st.item, data1) ;
		}
	      else if (strncmp (data, "n_itemrev", 9) == 0)
		{
		  strcpy (ADD_ITEM_st.rev, data1) ;
		}
	      else if (strncmp (data, "n_itemdesc",10) == 0)
		{
		  strcpy (ADD_ITEM_st.description,data1) ;
		}
	      else if (strncmp (data, "n_versionlimit",14) == 0)
		{
		  strcpy (ADD_ITEM_st.version, data1) ;
		}
	      else if (strncmp (data, "n_aclname",9) == 0)
		{
		  strcpy (ADD_ITEM_st.aclname, data1) ;
		}
	      else if (strncmp (data, "n_cofilename",11) == 0)
		{
		  strcpy (ADD_ITEM_st.localfile, data1) ;
		}
	      else if (strncmp (data, "n_filetype",9) == 0)
		{
		  strcpy (ADD_ITEM_st.filetype, data1) ;
		}
	      else if (strncmp (data, "n_cisaname",9) == 0)
		{
		  strcpy (ADD_ITEM_st.cisaname, data1) ;
		}
	      else if (strncmp (data, "n_cifilename",12) == 0)
		{
		  strcpy (ADD_ITEM_st.cifile, data1) ;
		}
	      
	      data  += *size_array_ptr ;
	      data1 += *size_array_ptr1 ;
	      ++size_array_ptr ;
	      ++size_array_ptr1 ;
	    }
	}
      
      process_mode = 0 ;
      status = CLIedit_ai_mode ( &interactive, &process, process_mode );
      if (status != CLI_S_SUCCESS)
	{
	  /* cancel out */
	  /* load cancel command */
	  NFMRset_wf_state ( "NFM", NFI_W_COMMAND_CANCELLED,
			    "Command cancelled")  ;
	  fprintf (stderr, "   Command Cancelled\n") ;
	  CLIreset_add_item_st () ;
	  return (CLI_S_SUCCESS) ;
	}
      
      /* add item and validate */
      status = NFMRpc_add_item () ;
      _NFMget_server_response (err_no, message, returned_string) ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str("Add item Message : <0x%.8lx>", status);
	  _CLI_str("Add item Message : %s", message);
	  CLIprint (CLIout_file,
		    "Add item <%s.%s> from catalog <%s> Message : %s",
		    ADD_ITEM_st.item, ADD_ITEM_st.rev, CLIcatalog, message) ;
	  CLIprint (stderr,
		    "Add item <%s.%s> from catalog <%s> Message : %s",
		    ADD_ITEM_st.item, ADD_ITEM_st.rev, CLIcatalog, message) ;
	}

      /******* SUCCESSFUL either pc or clix *********/
/*******
      fprintf( CLIout_file, "   Successful Add item.\n" );
      fprintf( stderr , "   Successful Add item.\n" );
      strcpy (CLIitem, ADD_ITEM_st.item) ;
      strcpy (CLIrev, ADD_ITEM_st.rev) ;
**********/      
      if (status  != NFM_S_SUCCESS)
	{  
	  _CLI_str("%s : EXIT", fname);
	  if (interactive) process_mode = 1 ;
	}
      else
	{
	  /******* SUCCESSFUL either pc or clix *********/
	  fprintf( CLIout_file, "   Successful Add item.\n" );
	  fprintf( stderr , "   Successful Add item.\n" );
	  strcpy (CLIitem, ADD_ITEM_st.item) ;
	  strcpy (CLIrev, ADD_ITEM_st.rev) ;
	  if ((interactive) && (process)) process_mode = 1 ;
	}
    } while (process_mode) ;

  CLIreset_add_item_st () ;
  return (CLI_S_SUCCESS) ;
}

#endif

