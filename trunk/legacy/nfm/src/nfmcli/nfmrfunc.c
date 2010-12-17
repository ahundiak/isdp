#include "machine.h"
#include <process.h>
#include <stdlib.h>
#include <stdio.h>
#include <malloc.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <ctype.h>
#include <string.h>
#include <stdarg.h>
#include <io.h>
#include "CLIerrordef.h"
#include "CLIstruct.h"
#include "CLIextern.h"
#include "NFMerrordef.h"
#include "NFMfto_buf.h"
#include "pc.h"
#include "proto.h"
#include <memcheck.h>
#include "NETstruct.h"

short clnt_fd;
long clientid;
extern char *buffer;
extern char npath[51];
/* extern char *CLI_ERR_MSG; */
extern struct add_item_info ADD_ITEM_st ;

long NFMRpc_add_item( )
{
  char *fname = "NFMRpc_add_item" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data , tmp_str [512];
  long rows, columns, status, size, no_of_cols ;
  char s_status [50], s_cat_num [50] ;
  long NFMpcfile_server () ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_ADD_ITEM ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;

  no_of_cols = 10 ;
  rows = *src = 2 ; src ++ ;      
  columns = *src = no_of_cols ; src ++ ;
/********* FIRST ROW ********************/
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen ("n_catalogname") + 1 ;
  sizes_array [1] = strlen ("n_itemname") + 1 ;
  sizes_array [2] = strlen ("n_itemrev") + 1 ;
  sizes_array [3] = strlen ("n_description") + 1 ;
  sizes_array [4] = strlen ("n_versionlimit") + 1 ;
  sizes_array [5] = strlen ("n_aclname") + 1 ;
  sizes_array [6] = strlen ("n_cofilename") + 1 ;
  sizes_array [7] = strlen ("n_filetype") + 1 ;
  sizes_array [8] = strlen ("n_cisaname") + 1 ;
  sizes_array [9] = strlen ("n_cifilename") + 1 ;


  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, "n_catalogname") ;
  data += strlen ("n_catalogname") + 1 ;
  strcpy (data, "n_itemname") ;
  data += strlen ("n_itemname") + 1 ;
  strcpy (data, "n_itemrev") ;
  data += strlen ("n_itemrev") + 1;
  strcpy (data, "n_description") ;
  data += strlen ("n_description") + 1;       
  strcpy (data, "n_versionlimit") ;
  data += strlen ("n_versionlimit") + 1;   
  strcpy (data, "n_aclname") ;
  data += strlen ("n_aclname") + 1 ;
  strcpy (data, "n_cofilename") ;
  data += strlen ("n_cofilename") + 1 ;
  strcpy (data, "n_filetype") ;
  data += strlen ("n_filetype") + 1;
  strcpy (data, "n_cisaname") ;
  data += strlen ("n_cisaname") + 1;       
  strcpy (data, "n_cifilename") ;
  data += strlen ("n_cifilename") + 1;   
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  src = data ;
/************** SECOND ROW ******************************/

  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (CLIcatalog) + 1 ;
  sizes_array [1] = strlen (ADD_ITEM_st.item) + 1 ;
  sizes_array [2] = strlen (ADD_ITEM_st.rev) + 1 ;
  sizes_array [3] = strlen (ADD_ITEM_st.description) + 1 ;
  sizes_array [4] = strlen (ADD_ITEM_st.version) + 1 ;
  sizes_array [5] = strlen (ADD_ITEM_st.aclname) + 1 ;
  sizes_array [6] = strlen (ADD_ITEM_st.localfile) + 1 ;
  sizes_array [7] = strlen (ADD_ITEM_st.filetype) + 1 ;
  sizes_array [8] = strlen (ADD_ITEM_st.cisaname) + 1 ;
  sizes_array [9] = strlen (ADD_ITEM_st.cifile) + 1 ;


  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, CLIcatalog) ;
  data += strlen (CLIcatalog) + 1 ;
  strcpy (data, ADD_ITEM_st.item) ;
  data += strlen (ADD_ITEM_st.item) + 1 ;
  strcpy (data, ADD_ITEM_st.rev) ;
  data += strlen (ADD_ITEM_st.rev) + 1;
  strcpy (data, ADD_ITEM_st.description) ;
  data += strlen (ADD_ITEM_st.description) + 1;       
  strcpy (data, ADD_ITEM_st.version) ;
  data += strlen (ADD_ITEM_st.version) + 1;   
  strcpy (data, ADD_ITEM_st.aclname) ;
  data += strlen (ADD_ITEM_st.aclname) + 1 ;
  strcpy (data, ADD_ITEM_st.localfile) ;
  data += strlen (ADD_ITEM_st.localfile) + 1 ;
  strcpy (data, ADD_ITEM_st.filetype) ;
  data += strlen (ADD_ITEM_st.filetype) + 1;
  strcpy (data, ADD_ITEM_st.cisaname) ;
  data += strlen (ADD_ITEM_st.cisaname) + 1;       
  strcpy (data, ADD_ITEM_st.cifile) ;
  data += strlen (ADD_ITEM_st.cifile) + 1;   
  *size_of_block = (short) ((long)data - (long) size_of_block) ;

/************************************************/

  size = (long) (data - buffer) ; 
  struct_ptr -> size = size ;
  _CLI_str ("NFMRpc_add_item : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

/********** mms - Do not need this ******
  sprintf (tmp_str, "%ld", buffer) ;
  _CLI_str ("buffer address is %s\n", tmp_str) ;

  status = NFMpcfile_server () ;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (s_status, "0x%.8lx", status) ;
      _CLI_str ("NFMpcfile_server failed : status = <%s>\n", s_status) ;
      return(status) ;
    }
*************************/

  struct_ptr = (struct NETbuffer_info *) buffer ;

  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return( status );
}



long NFMRcheckin_item( catalog, cat_num, item, rev, storage, 
		      wf_info, operation)
     char	*catalog;
     long       cat_num;
     char	*item;
     char	*rev;
     char      *storage;
     struct    NFMwf_info    wf_info;
     struct    NFMoperation  operation;
{
  char *fname = "NFMRcheckin_item" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data , tmp_str [512];
  long rows, columns, status, size ;
  char s_status [50], s_cat_num [50] ;
  long NFMpcfile_server () ;
  
  _CLI_str( "%s : ENTER", fname) ;
  sprintf (s_cat_num, "%ld", cat_num) ;
  _CLI_str( "NFMRcheckin_item : catalog    <%s>", catalog );
  _CLI_str ("NFMRcheckin_item : catalog no <%s>", s_cat_num) ;
  _CLI_str( "NFMRcheckin_item : item       <%s>", item );
  _CLI_str( "NFMRcheckin_item : revision   <%s>", rev );
  _CLI_str( "NFMRcheckin_item : storage    <%s>", storage );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CHECKIN_ITEM ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = 5 ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (s_cat_num) + 1 ;
  sizes_array [2] = strlen (item) + 1 ;
  sizes_array [3] = strlen (rev) + 1 ;
  sizes_array [4] = strlen (storage) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, s_cat_num) ;
  data += strlen (s_cat_num) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  strcpy (data, storage) ;
  data += strlen (storage) + 1;   
  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcheckin_item : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

  sprintf (tmp_str, "%ld", buffer) ;
  _CLI_str ("buffer address is %s\n", tmp_str) ;

  status = NFMpcfile_server () ;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (s_status, "0x%.8lx", status) ;
      _CLI_str ("NFMpcfile_server failed : status = <%s>\n", s_status) ;
      return(status) ;
    }

  struct_ptr = (struct NETbuffer_info *) buffer ;

  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return( status );
}


long NFMRcheckout_item( catalog, cat_num,  item, rev, storage,
		       wf_info, operation )
     char	  *catalog;
     long         cat_num ;
     char	  *item;
     char	  *rev;
     char      *storage;
     struct  NFMwf_info    wf_info;
     struct  NFMoperation  operation;
{
  char *fname = "NFMRcheckout_item" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, s_cat_num [50], tmp_str [512];
  long rows, columns, status, size ;
  
  _CLI_str( "%s : ENTER", fname) ;
  sprintf (s_cat_num , "%ld", cat_num) ;
  _CLI_str( "NFMRcheckout_item : catalog    <%s>", catalog );
  _CLI_str ("NFMRcheckout_item : cat_num    <%s>", s_cat_num) ;
  _CLI_str( "NFMRcheckout_item : item       <%s>", item );
  _CLI_str( "NFMRcheckout_item : revision   <%s>", rev );
  _CLI_str( "NFMRcheckout_item : storage    <%s>", storage );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CHECKOUT_ITEM ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = 5 ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (s_cat_num) + 1 ;
  sizes_array [2] = strlen (item) + 1 ;
  sizes_array [3] = strlen (rev) + 1 ;
  sizes_array [4] = strlen (storage) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, s_cat_num);
  data += strlen (s_cat_num) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  strcpy (data, storage) ;
  data += strlen (storage) + 1;   
  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcheckout_item : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  
  struct_ptr = (struct NETbuffer_info *) buffer ;

  status = NFMpcfile_server ()  ;
  if (status != NFM_S_SUCCESS)
    {
      return (status) ;
    }
  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;

   return( status );
}

long NFMRcancel_check_out_item( catalog, cat_num, item, rev, 
			       wf_info, operation)
     char	*catalog;
     long       cat_num;
     char	*item;
     char	*rev;
     struct    NFMwf_info    wf_info;
     struct    NFMoperation  operation;
{
  char *fname = "NFMRcancel_check_out_item" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data , tmp_str [512];
  long rows, columns, status, size ;
  char s_status [50], s_cat_num [50] ;
  long NFMpcfile_server () ;
  
  _CLI_str( "%s : ENTER", fname) ;
  sprintf (s_cat_num, "%ld", cat_num) ;
  _CLI_str( "NFMRcancel_checkout_item : catalog    <%s>", catalog );
  _CLI_str ("NFMRcancel_checkout_item_item : catalog no <%s>", s_cat_num) ;
  _CLI_str( "NFMRcancel_checkout_item : item       <%s>", item );
  _CLI_str( "NFMRcancel_checkout_item : revision   <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CANCEL_CO_ITEM ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = 4 ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (s_cat_num) + 1 ;
  sizes_array [2] = strlen (item) + 1 ;
  sizes_array [3] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, s_cat_num) ;
  data += strlen (s_cat_num) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_checkout_item : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

  sprintf (tmp_str, "%ld", buffer) ;
  _CLI_str ("buffer address is %s\n", tmp_str) ;

  status = NFMpcfile_server () ;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (s_status, "0x%.8lx", status) ;
      _CLI_str ("NFMpcfile_server failed : status = <%s>\n", s_status) ;
      return(status) ;
    }

  struct_ptr = (struct NETbuffer_info *) buffer ;

  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return( status );
}

long NFMRcheckin_set( catalog, cat_num, set, rev, set_num, storage,
		     wf_info, member_operations, operation, level)
     char          *catalog;
     long       cat_num;
     char       *set;
     char       *rev;
     long       set_num;
     char      *storage;
     struct     NFMwf_info    wf_info;
     long       member_operations ;
     struct     NFMoperation  *operation;
     long       level ;
{
  char *fname = "NFMRcheckin_set" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512];
  long rows, columns, status, size ;
  char s_status [50], s_cat_num [50], s_set_num [50] ;

  _CLI_str ("%s : ENTER", fname) ;

  sprintf (s_cat_num, "%ld", cat_num) ;
  sprintf (s_set_num, "%ld", set_num) ;
  _CLI_str( "NFMRcheckin_set : catalog    <%s>", catalog );
  _CLI_str ("NFMRcheckin_set : catalog no <%s>", s_cat_num) ;
  _CLI_str( "NFMRcheckin_set : item       <%s>", set );
  _CLI_str( "NFMRcheckin_set : revision   <%s>", rev );
  _CLI_str ("NFMRcheckin_set : set no <%s>", s_set_num) ;
  _CLI_str( "NFMRcheckin_set : storage    <%s>", storage );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CHECKIN_SET ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = 6 ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (s_cat_num) + 1 ;
  sizes_array [2] = strlen (set) + 1 ;
  sizes_array [3] = strlen (rev) + 1 ;
  sizes_array [4] = strlen (s_set_num) + 1 ;
  sizes_array [5] = strlen (storage) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, s_cat_num) ;
  data += strlen (s_cat_num) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  strcpy (data, s_set_num) ;
  data += strlen (s_set_num) + 1;   
  strcpy (data, storage) ;
  data += strlen (storage) + 1;   
  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcheckin_set : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

  sprintf (tmp_str, "%ld", buffer) ;
  _CLI_str ("buffer address is %s\n", tmp_str) ;

  status = NFMpcfile_server () ;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (s_status, "0x%.8lx", status) ;
      _CLI_str ("NFMpcfile_server failed : status = <%s>\n", s_status) ;
      return(status) ;
    }

  struct_ptr = (struct NETbuffer_info *) buffer ;
  
  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  
  return (status) ;
}

long NFMRcheckout_set( catalog, cat_num, set, rev, set_num, storage,
                wf_info, member_operations, operation, level)
        char          *catalog;
        long       cat_num;
        char          *set;
        char          *rev;
        long       set_num;
        char      *storage;
        struct  NFMwf_info    wf_info;
        long     member_operations ;
        struct  NFMoperation  *operation;
        long          level ;
{
  char *fname = "NFMRcheckout_set" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512];
  long rows, columns, status, size ;
  char s_status [50], s_cat_num [50], s_set_num [50] ;

  _CLI_str ("%s : ENTER", fname) ;
  sprintf (s_cat_num, "%ld", cat_num) ;
  sprintf (s_set_num, "%ld", set_num) ;
  _CLI_str( "NFMRcheckout_set : catalog    <%s>", catalog );
  _CLI_str ("NFMRcheckout_set : catalog no <%s>", s_cat_num) ;
  _CLI_str( "NFMRcheckout_set : item       <%s>", set );
  _CLI_str( "NFMRcheckout_set : revision   <%s>", rev );
  _CLI_str ("NFMRcheckout_set : set no <%s>", s_set_num) ;
  _CLI_str( "NFMRcheckout_set : storage    <%s>", storage );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CHECKOUT_SET ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = 6 ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (s_cat_num) + 1 ;
  sizes_array [2] = strlen (set) + 1 ;
  sizes_array [3] = strlen (rev) + 1 ;
  sizes_array [4] = strlen (s_set_num) + 1 ;
  sizes_array [5] = strlen (storage) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, s_cat_num) ;
  data += strlen (s_cat_num) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  strcpy (data, s_set_num) ;
  data += strlen (s_set_num) + 1;   
  strcpy (data, storage) ;
  data += strlen (storage) + 1;   
  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcheckout_set : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

  sprintf (tmp_str, "%ld", buffer) ;
  _CLI_str ("buffer address is %s\n", tmp_str) ;

  status = NFMpcfile_server () ;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (s_status, "0x%.8lx", status) ;
      _CLI_str ("NFMpcfile_server failed : status = <%s>\n", s_status) ;
      return(status) ;
    }

  struct_ptr = (struct NETbuffer_info *) buffer ;
  
  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;

  return (status) ;
}

long NFMRcancel_check_out_set (catalog, cat_num, set, rev, set_num, 
                wf_info, member_operations, operation, level)
        char          *catalog;
        long       cat_num;
        char          *set;
        char          *rev;
        long       set_num;
        struct  NFMwf_info    wf_info;
        long     member_operations ;
        struct  NFMoperation  *operation;
        long          level ;
{
  char *fname = "NFMRcancel_check_out_set" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512];
  long rows, columns, status, size ;
  char s_status [50], s_cat_num [50], s_set_num [50] ;

  _CLI_str ("%s : ENTER", fname) ;
  sprintf (s_cat_num, "%ld", cat_num) ;
  sprintf (s_set_num, "%ld", set_num) ;
  _CLI_str( "NFMRcancel_check_out_set : catalog    <%s>", catalog );
  _CLI_str ("NFMRcancel_check_out_set : catalog no <%s>", s_cat_num) ;
  _CLI_str( "NFMRcancel_check_out_set : item       <%s>", set );
  _CLI_str( "NFMRcancel_check_out_set : revision   <%s>", rev );
  _CLI_str ("NFMRcancel_check_out_set : set no <%s>", s_set_num) ;
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CANCEL_CO_SET ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = 6 ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (s_cat_num) + 1 ;
  sizes_array [2] = strlen (set) + 1 ;
  sizes_array [3] = strlen (rev) + 1 ;
  sizes_array [4] = strlen (s_set_num) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, s_cat_num) ;
  data += strlen (s_cat_num) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  strcpy (data, s_set_num) ;
  data += strlen (s_set_num) + 1;   
  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_check_out_set : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

  sprintf (tmp_str, "%ld", buffer) ;
  _CLI_str ("buffer address is %s\n", tmp_str) ;

  status = NFMpcfile_server () ;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (s_status, "0x%.8lx", status) ;
      _CLI_str ("NFMpcfile_server failed : status = <%s>\n", s_status) ;
      return(status) ;
    }

  struct_ptr = (struct NETbuffer_info *) buffer ;
  
  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;

  return (status) ;
}

long NFMRcopy_item( catalog, cat_num, item, rev, storage, 
		       wf_info, operation )
	char	  *catalog;
        long      cat_num ;
	char	  *item;
	char	  *rev;
	char      *storage;
	struct  NFMwf_info    wf_info;
	struct  NFMoperation  operation;
{
  char *fname = "NFMRcopy_item" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, s_cat_num [50], tmp_str [512] ;
  long rows, columns, status, size ;
	
  _CLI_str( "%s : ENTER", fname) ;
  
  sprintf (s_cat_num, "%ld", cat_num) ;
  _CLI_str( "NFMRcopy_item : catalog    <%s>", catalog );
  _CLI_str( "NFMRcopy_item : catalog no <%s>", s_cat_num) ;
  _CLI_str( "NFMRcopy_item : item       <%s>", item );
  _CLI_str( "NFMRcopy_item : revision   <%s>", rev );
  _CLI_str( "NFMRcopy_item : storage    <%s>", storage );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_COPY_ITEM ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = 5 ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (s_cat_num) + 1 ;
  sizes_array [2] = strlen (item) + 1 ;
  sizes_array [3] = strlen (rev) + 1 ;
  sizes_array [4] = strlen (storage) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, s_cat_num);
  data += strlen (s_cat_num) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  strcpy (data, storage) ;
  data += strlen (storage) + 1;   
  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcopy_item : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  
  status = NFMpcfile_server ()  ;
  if (status != NFM_S_SUCCESS)
    {
      return (status) ;
    }
  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;

  return( status );
}

long NFMRcopy_set( catalog, cat_num, set, rev, set_num, storage,
		  wf_info, member_operations, operation, level )
     char          *catalog;
     long       cat_num;
     char          *set;
     char          *rev;
     long       set_num;
     char      *storage;
     struct  NFMwf_info    wf_info;
     long    member_operations ;
     struct  NFMoperation  *operation;
     long       level ;
{
  char *fname = "NFMRcopy_set" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512];
  long rows, columns, status, size ;
  char s_status [50], s_cat_num [50], s_set_num [50] ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  sprintf (s_cat_num, "%ld", cat_num) ;
  sprintf (s_set_num, "%ld", set_num) ;
  _CLI_str( "NFMRcancel_check_out_set : catalog    <%s>", catalog );
  _CLI_str ("NFMRcancel_check_out_set : catalog no <%s>", s_cat_num) ;
  _CLI_str( "NFMRcancel_check_out_set : item       <%s>", set );
  _CLI_str( "NFMRcancel_check_out_set : revision   <%s>", rev );
  _CLI_str ("NFMRcancel_check_out_set : set no <%s>", s_set_num) ;
  _CLI_str( "NFMRcancel_check_out_set : storage    <%s>", storage );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_COPY_SET ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = 6 ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (s_cat_num) + 1 ;
  sizes_array [2] = strlen (set) + 1 ;
  sizes_array [3] = strlen (rev) + 1 ;
  sizes_array [4] = strlen (s_set_num) + 1 ;
  sizes_array [5] = strlen (storage) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, s_cat_num) ;
  data += strlen (s_cat_num) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  strcpy (data, s_set_num) ;
  data += strlen (s_set_num) + 1;   
  strcpy (data, storage) ;
  data += strlen (storage) + 1;   
  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_check_out_set : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

  sprintf (tmp_str, "%ld", buffer) ;
  _CLI_str ("buffer address is %s\n", tmp_str) ;

  status = NFMpcfile_server () ;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (s_status, "0x%.8lx", status) ;
      _CLI_str ("NFMpcfile_server failed : status = <%s>\n", s_status) ;
      return(status) ;
    }

  struct_ptr = (struct NETbuffer_info *) buffer ;
  
  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  
  return (status) ;
}

long NFMRflag_item_archive( user_id, catalog, item, rev )
     long          user_id;
     char          *catalog;
     char          *item;
     char          *rev;
{
  char *fname = "NFMRflag_item_archive" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512] ;
  long rows, columns, status, size ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  _CLI_str( "NFMRflag_item_archive : catalog  <%s>", catalog );
  _CLI_str( "NFMRflag_item_archive : item     <%s>", item );
  _CLI_str( "NFMRflag_item_archive : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_FLAG_ITEM_ARCHIVE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (item) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;       
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRflag_item_archive : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  
  return (status) ;
}

long NFMRflag_item_backup( user_id, catalog, item, rev )
     long          user_id;
     char          *catalog;
     char          *item;
     char          *rev;
{
  char *fname = "NFMRflag_item_backup" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512] ;
  long rows, columns, status, size ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  _CLI_str( "NFMRflag_item_backup : catalog  <%s>", catalog );
  _CLI_str( "NFMRflag_item_backup : item     <%s>", item );
  _CLI_str( "NFMRflag_item_backup : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_FLAG_ITEM_BACKUP ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ; 
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (item) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short))) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRflag_item_backup : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRflag_item_restore( user_id, catalog, item, rev )
        long          user_id;
        char          *catalog;
        char          *item;
        char          *rev;
{
  char *fname= "NFMRflag_item_restore" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512] ;
  long rows, columns, status, size ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  _CLI_str( "NFMRflag_item_restore : catalog  <%s>", catalog );
  _CLI_str( "NFMRflag_item_restore : item     <%s>", item );
  _CLI_str( "NFMRflag_item_restore : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_FLAG_ITEM_RESTORE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (item) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short))) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRflag_item_restore : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRflag_set_archive( user_id, catalog, set, rev )
     long          user_id;
     char          *catalog;
     char          *set;
     char          *rev;
{
  char *fname = "NFMRflag_set_archive" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512] ;
  long rows, columns, status, size ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  _CLI_str( "NFMRflag_set_archive : catalog  <%s>", catalog );
  _CLI_str( "NFMRflag_set_archive : set      <%s>", set );
  _CLI_str( "NFMRflag_set_archive : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_FLAG_SET_ARCHIVE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (set) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short))) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRflag_set_archive : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;

  return (status) ;
}

long NFMRflag_set_backup( user_id, catalog, set, rev )
     long          user_id;
     char          *catalog;
     char          *set;
     char          *rev;
{
  char *fname = "NFMRflag_set_backup" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512] ;
  long rows, columns, status, size ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  _CLI_str( "NFMRflag_set_backup : catalog  <%s>", catalog );
  _CLI_str( "NFMRflag_set_backup : item     <%s>", set );
  _CLI_str( "NFMRflag_set_backup : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_FLAG_SET_BACKUP ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof(short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (set) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short))) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRflag_set_backup : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRflag_set_restore( user_id, catalog, set, rev )
     long          user_id;
     char          *catalog;
     char          *set;
     char          *rev;
{
  char *fname = "NFMRflag_set_restore" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512] ;
  long rows, columns, status, size ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  _CLI_str( "NFMRflag_set_restore : catalog  <%s>", catalog );
  _CLI_str( "NFMRflag_set_restore : set      <%s>", set );
  _CLI_str( "NFMRflag_set_restore : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_FLAG_SET_RESTORE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (set) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns *  sizeof (short))) ;
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRflag_set_restore : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}


long NFMRpc_post_log_in( internet_address, default_st_area, cwd, nfs_node, nfs_sa )
     char          internet_address[31]; 
     char          default_st_area[16];
     char          cwd[51];
     char          nfs_node[2];
     char      nfs_sa[2];
{
  char *fname="NFMRpc_post_log_in" ;
  struct NETbuffer_info *struct_ptr ;
  long   *src ;
  short  *sizes_array, *size_of_block ;
  char   *data, tmp_str [512] ;
  long   rows, columns, status, size ;
  
  _CLI_str ( "%s : ENTER", fname ) ;
  
  _CLI_str ( "NFMRpc_post_login : internet_address <%s>\n", internet_address );
  _CLI_str ( "NFMRpc_post_login : default_st_area <%s>\n", default_st_area );
  _CLI_str ( "NFMRpc_post_login : cwd  <%s>\n", cwd );
  _CLI_str ( "NFMRpc_post_login : nfs_node <%s>\n", nfs_node );
  _CLI_str ( "NFMRpc_post_login : nfs_sa <%s>\n", nfs_sa );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request = PC_POST_LOGIN ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src++ ;   /* row */
  columns = *src = 5 ; src++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (internet_address) + 1 ;
  sizes_array [1] = strlen (default_st_area) + 1 ;
  sizes_array [2] = strlen (cwd) + 1 ;
  sizes_array [3] = strlen (nfs_node) + 1 ;
  sizes_array [4] = strlen (nfs_sa) + 1 ;
  data = (char *) ((long) sizes_array + ((long)columns * (long)sizeof (short)));
  strcpy (data, internet_address) ;
  data += strlen (internet_address) + 1 ;
  strcpy (data, default_st_area) ;
  data += strlen (default_st_area) + 1 ;
  strcpy (data, cwd) ;
  data += strlen (cwd) + 1 ;
  strcpy (data, nfs_node) ;
  data += strlen (nfs_node) + 1 ;
  strcpy (data, nfs_sa) ;
  data += strlen (nfs_sa) + 1 ;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRpc_post_login : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRlog_in( username, password, environment, application )
     char          *username; 
     char          *password;
     char          *environment;
     char          *application;
{
  char *fname = "NFMRlog_in" ;
  struct NETbuffer_info *struct_ptr ;
  long   *src ;
  short *sizes_array, *size_of_block ;
  char   *data, tmp_str [512] ;
  long   rows, columns, status, size ;
  
  _CLI_str ( "%s : ENTER", fname) ;
  
  _CLI_str ( "NFMRlogin : environment <%s>\n", environment );
  _CLI_str ( "NFMRlogin : username  <%s>\n", username );
  _CLI_str ( "NFMRlogin : password  <%s>\n", password );
  _CLI_str ( "NFMRlogin : application <%s>\n", application );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request = PC_LOGIN ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src++ ;   /* row */
  columns = *src = 4 ; src++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long) src + (long) sizeof (short)) ;
  sizes_array [0] = strlen (username) + 1 ;
  sizes_array [1] = strlen (password) + 1 ;
  sizes_array [2] = strlen (environment) + 1 ;
  sizes_array [3] = strlen (application) + 1 ;
  data = (char *) ((long) sizes_array + ((long)columns * (long)sizeof (short)));
  strcpy (data, username) ;
  data += strlen (username) + 1 ;
  strcpy (data, password) ;
  data += strlen (password) + 1 ;
  strcpy (data, environment) ;
  data += strlen (environment) + 1 ;
  strcpy (data, application) ;
  data += strlen (application) + 1 ;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRlog_in : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRlogout( )
{
  char *fname = "NFMRlogout" ;
  struct NETbuffer_info info, *struct_ptr;
  long   size ;
  long   status ;
  char   tmp_str [512] ;
  
  _CLI_str( "%s : ENTER", fname ) ;
  
  info.request = PC_LOGOUT ;
  size = info.size = (long) sizeof (struct NETbuffer_info) ;
  _CLI_str ( "sending buffer of size %ld\n",
	    info.size) ;
  _CLI_str ( "sending request %d\n", info.request) ;
  
  status = NETbuffer_send ((char *) &info, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      client_stop (clnt_fd) ;
      _CLI_str ( "NFMRlogout : NETbuffer_send : status = <%d>\n",
		status) ;
      return (status) ; 
    }
  
  status = NETbuffer_receive ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      client_stop (clnt_fd) ;
      _CLI_str ("NFMRlogout : NETbuffer_receive : status = <%d>\n",
		status) ;
      return (status) ;
    }
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>",
               fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long ERRget_message( msg )
     char *msg;
{
  _CLI_str( "%s", "Entering ERRget_message" );
  
  strcpy( msg, "Error Executing Previous Command" );
  
  _CLI_str( "%s", "Exiting ERRget_message" );
  
  return( NFM_S_SUCCESS );
}

long NFMRconnect( node, username )
     char *node;
     char *username ;
{
  char *fname = "NFMRconnect" ;
  short x, n;
  long  size, status;
  struct NETbuffer_info buffer_info ;
  
  _CLI_str ( "%s : ENTER", fname) ;
  _CLI_str ("node %s", node) ;
  _CLI_str ( "username %s", username) ;
  n = strlen( node );
  for( x=0; x < n; x++ ) node[x] = (char) tolower( (int) node[x] );
  
  /* Establish connection to server */
  
  clnt_fd = client_init( node, 1585, 3L ); 
 
  if( clnt_fd < 0 )
    {
      /* Return Error Code */
      return((long)clnt_fd);
    }
 
  size = buffer_info.size = sizeof (struct NETbuffer_info) ;
  strcpy (buffer_info.username, username) ;
  _CLI_str ("Send username : %s",buffer_info.username); 
  _CLI_str ("     size     : %d",size); 
 
  status = NETbuffer_send ((char *) &buffer_info, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send : status = <%d>\n",
		status) ;
      return (status) ;
    }
  
  status = NETbuffer_receive ((char *)&buffer_info, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive : status = <%d>\n",
		status) ;
      return (status) ;
    }

  _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (NFM_S_SUCCESS) ;
} /* end of NFMRconnect */

long NFMRdisconnect() 
{
  char *fname = "NFMRdisconnect" ;
  long status, size;
  struct NETbuffer_info info, *struct_ptr ;
  short x;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  info.request = PC_EXIT ;
  size = info.size = sizeof (struct NETbuffer_info) ;
  status = NETbuffer_send ((char *) &info, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str (" NETbuffer_send failed : status = <%d>\n",
		status) ;
      return (status); 
    }
  status = NETbuffer_receive ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str (" NETbuffer_receive failed : status = <%d>\n",
		status) ;
      return (status) ;
    }
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  
  x = client_stop(clnt_fd);

  if ( x < 0 )
    {
      /* Return Error Code */
      return((long)x);
    }
  
  _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (NFM_S_SUCCESS) ;
} /* end of NFMRdisconnect */



long NFMRcancel_item_archive_flag( user_id, catalog, item, rev )
     long          user_id;
     char          *catalog;
     char          *item;
     char          *rev;
{
  char *fname = "NFMRcancel_item_archive_flag" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  char tmp_str [512] ;
  
  _CLI_str( "ENTER : %s", fname ) ;
  
  _CLI_str( "NFMRcancel_item_archive_flag : catalog  <%s>", catalog );
  _CLI_str( "NFMRcancel_item_archive_flag : item     <%s>", item );
  _CLI_str( "NFMRcancel_item_archive_flag : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CANCEL_ITEM_ARCHIVE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (item) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns  * sizeof (short)));
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_item_archive_flag : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
        {
	  _CLI_str ("NETbuffer_receive failed : status = <%d>",
		    status) ;
	  return (status) ;
        }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return( status ) ;
}

long NFMRcancel_item_backup_flag( user_id, catalog, item, rev )
     long          user_id; 
     char          *catalog;
     char          *item;
     char          *rev;
{
  char *fname = "NFMRcancel_item_backup_flag" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  char tmp_str [512] ;
  
  _CLI_str( "%s", "Entering NFMRcancel_item_backup_flag" );
  
  _CLI_str( "NFMRcancel_item_backup_flag : catalog  <%s>", catalog );
        _CLI_str( "NFMRcancel_item_backup_flag : item     <%s>", item );
  _CLI_str( "NFMRcancel_item_backup_flag : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CANCEL_ITEM_BACKUP ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (item) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns  * sizeof (short)));
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  size = (long) (data - buffer) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_item_backup : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return( status );
}

long NFMRcancel_item_restore_flag( user_id, catalog, item, rev )
     long          user_id; 
     char          *catalog;
     char          *item;
     char          *rev;
{
  char *fname = "NFMRcancel_item_restore_flag" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  char tmp_str [512] ;

  _CLI_str( "%s", "Entering NFMRcancel_item_restore_flag" );
  
  _CLI_str( "NFMRcancel_item_restore : catalog  <%s>", catalog );
  _CLI_str( "NFMRcancel_item_restore : item     <%s>", item );
  _CLI_str( "NFMRcancel_item_restore : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CANCEL_ITEM_RESTORE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block =  (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (item) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short)));
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, item) ;
  data += strlen (item) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_item_restore : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRcancel_set_archive_flag( user_id, catalog, set, rev )
     long          user_id;
     char          *catalog;
     char          *set;
     char          *rev;
{
  char *fname = "NFMRcancel_set_archive_flag" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  char tmp_str [512] ;
  
  _CLI_str( "%s", "Entering NFMRcancel_set_archive_flag" );
  
  _CLI_str( "NFMRcancel_set_archive : catalog  <%s>", catalog );
  _CLI_str( "NFMRcancel_set_archive : set      <%s>", set );
  _CLI_str( "NFMRcancel_set_archive : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CANCEL_SET_ARCHIVE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (set) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short)));
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_set_archive : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRcancel_set_backup_flag( user_id, catalog, set, rev )
     long          user_id; 
     char          *catalog;
     char          *set;
     char          *rev;
{
  char *fname = "NFMRcancel_set_backup_flag" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  char tmp_str [512] ;

  _CLI_str( "%s", "Entering NFMRcancel_set_backup_flag" );
  
  _CLI_str( "NFMRcancel_set_backup : catalog  <%s>", catalog );
  _CLI_str( "NFMRcancel_set_backup : set      <%s>", set );
  _CLI_str( "NFMRcancel_set_backup : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CANCEL_SET_BACKUP ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (set) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short)));
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_set_backup : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRcancel_set_restore_flag( user_id, catalog, set, rev )
     long          user_id;
     char          *catalog;
     char          *set;
     char          *rev;
{
  char *fname = "NFMRcancel_set_restore_flag" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  char tmp_str [512] ;
  
  _CLI_str( "%s", "Entering NFMRcancel_set_restore_flag" );
  
  _CLI_str( "NFMRcancel_set_restore : catalog  <%s>", catalog );
  _CLI_str( "NFMRcancel_set_restore : set     <%s>", set );
  _CLI_str( "NFMRcancel_set_restore : revision <%s>", rev );
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_CANCEL_SET_RESTORE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog) + 1 ;
  sizes_array [1] = strlen (set) + 1 ;
  sizes_array [2] = strlen (rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short)));
  strcpy (data, catalog) ;
  data += strlen (catalog) + 1 ;
  strcpy (data, set) ;
  data += strlen (set) + 1;
  strcpy (data, rev) ;
  data += strlen (rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRcancel_set_restore : size of buffer sent %d\n", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRvalidate_user_access (user_id, command, workflow, project,
                               catalog_name, item_name, item_rev)

     long    user_id;       /* i - user id for access */
     char    *command;      /* i - the command to be performed */
     char    *workflow;     /* i - workflow name */
     char    *project;      /* i - the active project */
     char    *catalog_name; /* i - the active catalog */
     char    *item_name;    /* i - the active item */
     char    *item_rev;     /* i - the active item's revision */
{
  char *fname = "NFMRvalidate_user_access" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  char tmp_str [512] ;
  
  _CLI_str( "ENTER : %s", fname) ;

  _CLI_str( "NFMRvalidate_user_access : command  <%s>", command ) ;
  _CLI_str( "NFMRvalidate_user_access : workflow <%s>", workflow ) ;
  _CLI_str( "NFMRvalidate_user_access : project  <%s>", project ) ;
  _CLI_str( "NFMRvalidate_user_access : catalog  <%s>", catalog_name ) ;
  _CLI_str( "NFMRvalidate_user_access : item     <%s>", item_name ) ;
  _CLI_str( "NFMRvalidate_user_access : revision <%s>", item_rev ) ;

  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_VALIDATE_USER_ACCESS ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 6 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (command) + 1 ;
  sizes_array [1] = strlen (workflow) + 1 ;
  sizes_array [2] = strlen (project) + 1 ;
  sizes_array [3] = strlen (catalog_name) + 1 ;
  sizes_array [4] = strlen (item_name) + 1 ;
  sizes_array [5] = strlen (item_rev) + 1 ;
  data = (char *) ((long) sizes_array + (columns * sizeof (short)));
  strcpy (data, command) ;
  data += strlen (command) + 1 ;
  strcpy (data, workflow) ;
  data += strlen (workflow) + 1;
  strcpy (data, project) ;
  data += strlen (project) + 1;
  strcpy (data, catalog_name) ;
  data += strlen (catalog_name) + 1 ;
  strcpy (data, item_name) ;
  data += strlen (item_name) + 1;
  strcpy (data, item_rev) ;
  data += strlen (item_rev) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRvalidate_user_access : size of buffer sent %d\n", size) ;

  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRset_wf_state (application, err_number, err_message )

char    *application ; /* i - application */
long    err_number ;   /* i - error number */
char    *err_message ; /* i - error message */
{
  char *fname = "NFMRset_to_state" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  char tmp_str [512] ;
  char s_err_no [20] ;

  _CLI_str( "ENTER : %s", fname) ;

  sprintf (s_err_no, "%ld", err_number) ;
  _CLI_str( "NFMRset_to_state : application  <%s>", application) ;
  _CLI_str( "NFMRset_to_state : err_number  <%s>", s_err_no) ;
  _CLI_str( "NFMRset_to_state : err_message  <%s>", err_message) ;

  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_SET_TO_STATE ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src = 1 ; src ++ ;      /* rows */
  columns = *src = 3 ; src ++ ;   /* columns */
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;

  sizes_array [0] = strlen (application) + 1 ;
  sizes_array [1] = strlen (s_err_no) + 1 ;
  sizes_array [2] = strlen (err_message) + 1 ;

  data = (char *) ((long) sizes_array + (columns * sizeof (short)));
  strcpy (data, application) ;
  data += strlen (application) + 1 ;
  strcpy (data, s_err_no) ;
  data += strlen (s_err_no) + 1 ;
  strcpy (data, err_message) ;
  data += strlen (err_message) + 1;
  size = (long) (data - buffer) ;
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRset_to_state : size of buffer sent %d\n", size) ;

  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long NFMRpc_display_items(catalog_name, search_name, sort_name )
     char *catalog_name ;
     char *search_name ;
     char *sort_name ;
{
  char *fname = "NFMRpc_display_items" ;
  struct NETbuffer_info *struct_ptr ;
  long *src, size ;
  short *sizes_array, *size_of_block, *size_array_ptr, *size_array_ptr1 ;
  short *block_size_ptr, block_size ;
  char *data , tmp_str [512], *data1 ;
  long rows, columns, status, no_of_cols,i, cols, *long_ptr, y ;
  long cols1, rows1 ;
  char s_status [50], s_cat_num [50] ;
  char *dt_buffer = NULL ;
  long NFMpcfile_server () ;
  FILE *fd ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  /* open file for append */
  fd = fopen (CLIdisplay_file, "a") ;
  if (fd == NULL)
  {
    return (status) ;
  }

  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_DISPLAY_ITEMS ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;

  no_of_cols = 3 ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = no_of_cols ; src ++ ;
  size_of_block = (short *) src ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  sizes_array [0] = strlen (catalog_name) + 1 ;
  sizes_array [1] = strlen (search_name) + 1 ;
  sizes_array [2] = strlen (sort_name) + 1 ;

  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, catalog_name) ;
  data += strlen (catalog_name) + 1 ;
  strcpy (data, search_name) ;
  data += strlen (search_name) + 1 ;
  strcpy (data, sort_name) ;
  data += strlen (sort_name) + 1 ;

  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRpc_display_items : size of buffer sent %d", size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }

/******** RECEIVE DATATYPE **********/
  dt_buffer = (char *) malloc (PC_ALLOCATION_SIZE/2) ;
  if (dt_buffer == NULL)
    {
      _CLI_str ("Malloc failed : status = <0x%.8x>", status) ;
      return (NFM_E_MALLOC) ;
    }

  _CLI_str ("receiving datatype buffer..") ;
  status = NETbuffer_receive ((char *) dt_buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      free (dt_buffer) ;
      _CLI_str ("NETbuffer_receive (dt_buffer) failed : status = <0x%.8x>", status) ;
      return (status) ;
    }  

  /****** get rows and columns *******/
  struct_ptr  = (struct NETbuffer_info *) dt_buffer ;
  long_ptr = (long *) (dt_buffer + sizeof (struct NETbuffer_info)) ;
  rows = *long_ptr ; ++long_ptr ;
  cols = *long_ptr ;
  size_array_ptr1 = (short *) (dt_buffer + sizeof(struct NETbuffer_info) + sizeof(short) + (2*sizeof(long))) ;
  data1 = (long) size_array_ptr1 + (cols * sizeof (short)) ;

  _CLI_num ("rows sent by client  %d", rows) ;
  _CLI_num ("cols sent by client %d", cols) ;

  /******* send response *************/
  size = sizeof (struct NETbuffer_info) ;
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr->size = size ;
  struct_ptr -> request = NFM_S_SUCCESS ;
  
  _CLI_num ("send response (0x%.8x) for datatype buffer...", NFM_S_SUCCESS) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  _CLI_num ("status is <0x%.8x>", status) ;
  if (status != NFM_S_SUCCESS)
    {
      free (dt_buffer) ;
      _CLI_num ("buffer send failed : status = <0x%.8x>", status);
      return (status) ;
    }
  /******* RECEIVE SYNONYM ****************/
  _CLI_str ("receiving syn_buffer buffer..") ;
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      free (dt_buffer) ;
      _CLI_str ("NETbuffer_receive failed (buffer) : status = <0x%.8x>",
		status) ;
      return (status) ;
    }  
/****** get rows and columns *******/
  struct_ptr  = (struct NETbuffer_info *) buffer ;
  long_ptr = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows1 = *long_ptr ; ++long_ptr ;
  cols1 = *long_ptr ; ++long_ptr ;
  _CLI_num ("rows are %d", rows1) ;
  _CLI_num ("cols are %d", cols1) ;

  block_size_ptr = (short *) long_ptr ;
  block_size = *block_size_ptr ;
  size_array_ptr = (long)block_size_ptr + (long)sizeof(short) ;
  data = (long)size_array_ptr + ((long)cols1 * (long)sizeof (short)) ;

  for (y=0; y<rows1; y++)
    {
      if (! strcmp  (data1, "integer" ))   size = 15;
      else if (! strcmp  (data1, "smallint"))   size = 15;
      else if (! strcmp  (data1, "double"  ))   size = 50;
      else if (! strcmp  (data1, "real"    ))   size = 50;
      else if (! strcmp  (data1, "decimal" ))   size = 15;
      else if (! strcmp  (data1, "date"    ))   size = 15;
      else if (! strcmp  (data1, "timestamp"))  size = 21;
      else if (! strncmp (data1, "char(", 5))
	{
	  sscanf (data1, "%5s%d", tmp_str, &size);
	}
      else size = 15 ;
      sprintf (tmp_str, "%%-%ds ", size) ;
      fprintf (fd, tmp_str, data) ;
      
      block_size_ptr = (long)block_size_ptr +(long)*block_size_ptr ;
      size_array_ptr = (long)block_size_ptr + (long) sizeof (short) ;
      data = (long)size_array_ptr + ((long)cols1 * (long)sizeof (short)) ;

      data1 += *size_array_ptr1 ;
      ++size_array_ptr1 ;
    }

  fprintf (fd, "\n") ;
  
  size_array_ptr1 = (short *) (dt_buffer + sizeof(struct NETbuffer_info)+sizeof(short) + 2*sizeof(long)) ;
  data1 = (char *) size_array_ptr1 + (cols * sizeof (short)) ;

  for (y=0; y<cols; y++)
    {
      if (! strcmp  (data1, "integer" ))   size = 15;
      else if (! strcmp  (data1, "smallint"))   size = 15;
      else if (! strcmp  (data1, "double"  ))   size = 50;
      else if (! strcmp  (data1, "real"    ))   size = 50;
      else if (! strcmp  (data1, "decimal" ))   size = 15;
      else if (! strcmp  (data1, "date"    ))   size = 15;
      else if (! strcmp  (data1, "timestamp"))  size = 21;
      else if (! strncmp (data1, "char(", 5))
	{
	  sscanf (data1, "%5s%d", tmp_str, &size);
	}
      else size = 15 ;
      sprintf (tmp_str, "%%-%ds ", size) ;
      fprintf (fd, tmp_str, data1) ;
      _CLI_str ("writing <%s>", data1) ;
      data1 += *size_array_ptr1 ;
      ++size_array_ptr1 ;
    }
  fprintf (fd, "\n\n") ;


  /******* send response *************/
  size = sizeof (struct NETbuffer_info) ;
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr->size = size ;
  struct_ptr -> request = NFM_S_SUCCESS ;

  _CLI_num ("send response (0x%.8x) for synonym buffer...", NFM_S_SUCCESS) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_num ("buffer send failed : status = <0x%.8x>\n",
		  status) ;
      return (status) ;
    }

/********** RECEIVE DATA ************************/
  _CLI_str ("receiving data buffer header..") ;
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  _CLI_num ("status is <0x%.8x>", status) ;
  if (status != NFM_S_SUCCESS)
    {
      free (dt_buffer) ;
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

/****** get rows and columns *******/
  struct_ptr  = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ;
  long_ptr = (long *) (buffer+ sizeof (struct NETbuffer_info)) ;
  rows = *long_ptr ; ++long_ptr ;
  cols = *long_ptr ;
  _CLI_num ("rows sent by client  %d", rows) ;
  _CLI_num ("cols sent by client %d", cols) ;
  
/******* send response *************/
  size = sizeof (struct NETbuffer_info) ;
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr->size = size ;
  struct_ptr -> request = NFM_S_SUCCESS ;

  _CLI_num ("send response (0x%.8x) from header...", NFM_S_SUCCESS) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      free (dt_buffer) ;
      _CLI_num ("buffer send failed : status = <0x%.8x>\n",
		  status) ;
      return (status) ;
    }
  /* check for aborts */
  
  fprintf (stderr, "Please wait ... retrieving %d items\n",
	   rows) ;
  
  /* receive all rows one row at a time */
  for (i=0; i<rows; i++)
    {
      _CLI_num ("RECEIVING ROW %d. Waiting for client ...", 
		i+1) ;
      status = NETbuffer_receive ((char *) buffer, &size);
      if (status != NFM_S_SUCCESS) 
	{
	  free (dt_buffer) ;
	  _CLI_num ("buffer receive failed : status = <0x%.8x>\n",
		      status) ;
	  return (status) ;
	} 

/******* I have problems with this for now
      status = _NFMcheck_status () ;
      if (status != NFM_S_SUCCESS)
	{
	  free (dt_buffer) ;
	  _CLI_str ("operation aborted : status = <0x%.8x>", status) ;
	  break ;
	}
*********/

      size_array_ptr = (short *) (buffer+sizeof(short));
      data = ((char *) size_array_ptr +  (cols * sizeof (short))) ;

      size_array_ptr1 = (short *) (dt_buffer + sizeof(struct NETbuffer_info)+sizeof(short) + 2*sizeof(long)) ;
      data1 = (char *) size_array_ptr1 + (cols * sizeof (short)) ;

      fprintf (fd, "%d : ", i+1) ; 
      for (y=0; y<cols; y++)
	{
	  if (! strcmp  (data1, "integer" ))   size = 15;
	  else if (! strcmp  (data1, "smallint"))   size = 15;
	  else if (! strcmp  (data1, "double"  ))   size = 50;
	  else if (! strcmp  (data1, "real"    ))   size = 50;
	  else if (! strcmp  (data1, "decimal" ))   size = 15;
	  else if (! strcmp  (data1, "date"    ))   size = 15;
	  else if (! strcmp  (data1, "timestamp"))  size = 21;
	  else if (! strncmp (data1, "char(", 5))
	    {
	      sscanf (data1, "%5s%d", tmp_str, &size);
	    }
	  else size = 15 ;
	  sprintf (tmp_str, "%%-%ds ", size) ;
/*	  _CLI_str ("data <%s> ", data1) ;
	  _CLI_str ("data <%s> ", data) ;
*/
	  fprintf (fd, tmp_str, data) ;

	  data += *size_array_ptr ;
	  ++size_array_ptr ;
	  data1 += *size_array_ptr1 ;
	  ++size_array_ptr1 ;
	}
/*      fprintf (fd, "\n%d : ", i) ; */

      struct_ptr = (struct NETbuffer_info *) buffer ;
      struct_ptr -> request  = NFM_S_SUCCESS ;
      size = struct_ptr -> size = sizeof (struct NETbuffer_info) ;
      _CLI_str ("Sending RESPONSE to client..") ;
      status = NETbuffer_send ((char *) buffer, &size) ;
      if (status != NFM_S_SUCCESS)
	{
	  free (dt_buffer) ;
	  _CLI_num ("buffer send failed : status = <0x%.8x>",
		      status) ;
	  return (status) ;
	}
    }  /* for */

  free (dt_buffer) ;
  fclose (fd) ;

  _CLI_str ("RECEIVING COMMAND. Waiting for client ...");
  status = NETbuffer_receive ((char *) buffer, &size);
  if (status != NFM_S_SUCCESS) 
  {
    _CLI_num ("buffer receive failed : status = <0x%.8x>\n",
	      status) ;
    return (status) ;
  } 

  struct_ptr = (struct NETbuffer_info *) buffer ;

  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
    }
  else
    _CLI_str ("%s : SUCCESSFUL", fname) ;
  return( status );
}

/* query add item */
long NFMRpc_query_add_item ()
{
  char *fname = "NFMRpc_query_add_item";
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data , tmp_str [512];
  long rows, columns, status, size, no_of_cols ;
  char s_status [50], s_cat_num [50], *buffer1 ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  PC_QUERY_ADD_ITEM ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;

  no_of_cols = 1 ;
  rows = *src = 1 ; src ++ ;      
  columns = *src = no_of_cols ; src ++ ;
  size_of_block = (short *) src ;
  _CLI_num ("src <%ld>", src) ;
  _CLI_num ("sizeof <%ld>", sizeof(short)) ;
  sizes_array = (short *) ((long)src + sizeof (short)) ;
  _CLI_num ("sizes_array <%ld>", sizes_array) ;
  sizes_array [0] = strlen (CLIcatalog) + 1 ;

  data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
  strcpy (data, CLIcatalog) ;
  data += strlen (CLIcatalog) + 1 ;

  size = (long) (data - buffer) ; 
  *size_of_block = (short) ((long)data - (long) size_of_block) ;
  struct_ptr -> size = size ;
  _CLI_str ("NFMRpc_query_add_item_attributes : size of buffer sent %d\n", 
	    size) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }

  _CLI_str ("waiting for buffer of data%s", "") ;
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  _CLI_str ("received buffer %s", "") ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

  _CLI_str ("waiting for status buffer%s","") ;
  buffer1 = (char *) malloc (PC_ALLOCATION_SIZE/2) ;
  if (buffer1 == NULL)
    {
      _CLI_str ("malloc failed") ;
      return (NFM_E_MALLOC) ;
    }

  struct_ptr = (struct NETbuffer_info *) buffer1 ;
  struct_ptr -> request  = NFM_S_SUCCESS ;
  size = struct_ptr -> size = sizeof (struct NETbuffer_info) ;
  _CLI_str ("Sending RESPONSE to server..") ;
  status = NETbuffer_send ((char *) buffer1, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      free (buffer1) ;
      _CLI_num ("buffer send failed : status = <0x%.8x>",
		status) ;
      return (status) ;
    }

  status = NETbuffer_receive ((char *) buffer1, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      free (buffer1) ;
      _CLI_str ("NETbuffer_receive failed : status = <%d>",
		status) ;
      return (status) ;
    }  

  struct_ptr = (struct NETbuffer_info *) buffer1 ;
  status=struct_ptr -> request;
  if (status != NFM_S_SUCCESS)
    {
      free (buffer1) ;
      sprintf (tmp_str, "%s : FAILURE : status = <0x%.8lx>", 
	       fname, status) ;
      _CLI_str ("%s", tmp_str) ;
      return (status) ;
    }

  _CLI_str ("%s : SUCCESSFUL", fname) ;
  free (buffer1) ;
  _CLI_num ("returning <0x%.8lx>", status) ;
  return (status) ;
}


