#include "machine.h"
#include "CMDTOOLS.h"
#include "NFMfto_buf.h"

  extern struct NFMglobal_st NFMglobal ;

long _NFMinsert_synonym (sql_buffer, column_name, data, read_flag, 
			 synonym_list) 
     MEMptr sql_buffer ;
     char *column_name ;
     char **data ;
     char *read_flag ;
     MEMptr *synonym_list ;
{
  long status, i ;
  static char *fname = "_NFMinsert_synonym" ;
  char   sql_str [100] ;

  for (i=0; i<sql_buffer->rows; i++)
    {
      if (strcmp (data [i*sql_buffer->columns+2], column_name) == 0)
	{
	  sprintf (sql_str, "%s\1%s\1", 
		   data [i*sql_buffer->columns], read_flag) ;
	  status = MEMwrite (*synonym_list, sql_str);
	  if (status != MEM_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "MEMwrite : <0x%.8x>", status));
	      return (NFM_E_MEM);
	    }
	  status = MEMbuild_array (*synonym_list) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      _NFMdebug ((fname, "MEMbuild_array *synonym_list : status = <0x%.8x>\n",
			  status)) ;
	      return (NFM_E_MEM) ;
	    }
	  break ;
	}
    }

  if (i == sql_buffer-> rows)
    {
      _NFMdebug ((fname, "corrupted buffer\n")) ;
      ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", "") ;
      return (NFM_E_CORRUPTED_BUFFERS) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
long _NFMrename_NFMencrypted_to_ud (sano, cat_no, file_no, filename,
				    move_buffer)
     long sano ;
     long cat_no ;
     long file_no ;
     char *filename ;
     MEMptr *move_buffer ;
{
  char *fname = "_NFMrename_NFMencrypted_to_ud" ;
  long status ;
  struct fto_buf file_buffer ;

  _NFMdebug ((fname, "sano %d : cat_no %d : file_no %d : filename %s\n",
	      sano, cat_no, file_no, filename)) ;

  status = _NFMget_sano_info_fto_buf (sano,  "",  &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get sano info status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  if (!(*move_buffer))
    {
      status = NFMbuild_fto_buffer (move_buffer, MEM_SIZE) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Build fto buffer : status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
    }

  file_buffer.n_status1 = NFM_RENAME ;
  /* old name is encrypted -> n_cifilename */
  status = NFMget_file_name (NFMglobal.NFMuserid,
			     cat_no, file_no,
			     file_buffer.n_cifilename) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get file name : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  /* new name n_cofilename */
  strcpy (file_buffer.n_cofilename, filename) ;
  _NFMdebug ((fname, "renamed to %s\n", filename)) ;
  status = NFMload_fto_buf (move_buffer, &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMrename_ud_to_NFMencrypted (sano, cat_no, file_no, filename, 
				    move_buffer)
     long sano ;
     long cat_no ;
     long file_no ;
     char *filename ;
     MEMptr *move_buffer ;
{
  char *fname = "_NFMrename_ud_to_NFMencrypted" ;
  long status ;
  struct fto_buf file_buffer ;

  _NFMdebug ((fname, "sano %d : cat_no %d : file_no %d : filename %s\n",
	      sano, cat_no, file_no, filename)) ;

  status = _NFMget_sano_info_fto_buf (sano, "",  &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get sano info status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  if (!(*move_buffer))
    {
      status = NFMbuild_fto_buffer (move_buffer, MEM_SIZE) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, 
		      "Build fto buffer : status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
    }

  file_buffer.n_status1 = NFM_RENAME ;
/* new name is encrypted -> n_cifilename */
  status = NFMget_file_name (NFMglobal.NFMuserid,
			     cat_no, file_no,
			     file_buffer.n_cofilename) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get file name : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

/* old name n_cofilename */
  strcpy (file_buffer.n_cifilename, filename) ;

  status = NFMload_fto_buf (move_buffer, &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMrename_NFMencrypted_to_NFMencrypted (sano, cat_no, from_file_no, 
					      to_file_no,
					      move_buffer)
     long sano ;
     long cat_no ;
     long from_file_no ;
     long to_file_no ;
     MEMptr *move_buffer ;
{
  char *fname = "_NFMrename_NFMencrypted_to_NFMencrypted" ;
  long status ;
  struct fto_buf file_buffer ;

  _NFMdebug ((fname, "sano %d : cat_no %d : from file_no %d : to file_no %d\n",
	      sano, cat_no, from_file_no, to_file_no)) ;

  status = _NFMget_sano_info_fto_buf (sano,  "",  &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get sano info status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (!(*move_buffer))
    {
      status = NFMbuild_fto_buffer (move_buffer, MEM_SIZE) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Build fto buffer : status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
    }

  file_buffer.n_status1 = NFM_RENAME ;
  /* old name is encrypted -> n_cifilename */
  status = NFMget_file_name (NFMglobal.NFMuserid,
			     cat_no, from_file_no,
			     file_buffer.n_cifilename) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get file name : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  /* new name n_cofilename */

  status = NFMget_file_name (NFMglobal.NFMuserid,
			     cat_no, to_file_no,
			     file_buffer.n_cofilename) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get file name : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "renamed to %s -> %s\n", 
	      file_buffer.n_cifilename, file_buffer.n_cofilename)) ;

  status = NFMload_fto_buf (move_buffer, &file_buffer) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

