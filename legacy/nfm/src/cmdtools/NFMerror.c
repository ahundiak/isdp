#include "machine.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "NFMfto_buf.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"

long _NFMextract_info_from_buf (st_code, buf, client, cmd, type, cat_name, 
        item_name, item_rev)

/* if return status of this function is == NFM_E_ERROR_NOT_LOADED,
   ERRload_struct might need to be called from "caller" if any error display
   is desired  */  

long st_code;  /* I: stauts of NFMfs_... call */
MEMptr buf;    /* I: should be a buffer returned from NFMfs_... call */
long client, cmd, type;
char *cat_name, *item_name, *item_rev;

{
  char *fname="_NFMextract_info_from_buf";
  long status;
  long x, index;
  char **data;

  _NFMdebug ((fname, "ENTER: client [%s] cmd [%d] type [%d]\n\
             cat_name [%s] item_name [%s] item_rev [%s] st_code [%d]\n",
             client, cmd, type, cat_name, item_name, item_rev, st_code));

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("buf", buf, _NFMdebug_st.NFMdebug_file);
 
  if (buf == (MEMptr ) NULL)
  {
    _NFMdebug ((fname, "calling this function with buf == NULL is useless\n"));
    return (NFM_E_ERROR_NOT_LOADED);
  }

  status = MEMbuild_array (buf);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "failed to build buf\n"));
    return (NFM_E_ERROR_NOT_LOADED);
  }

  data = (char **) buf->data_ptr;

  switch (cmd)
  {
    case NFM_CHANGE_FILE_INFORMATION:
      if (st_code == NFM_E_STAT_CO_FILENAME)
      {
        for (x = 1; x < buf->rows; x ++)
        {
          index = buf->columns * x;
          _NFMdebug ((fname, "buf[%d] FTO_STATUS1 = %s\n", x,
                        data[index+FTO_STATUS1]));
          if (atol (data[index+FTO_STATUS1]) != NFM_TRANSFERED)
          {
            _NFMdebug ((fname, 
              "file [%s] in [%s] of machine [%s] not accessble\n",
              data[index+FTO_COFILENAME], data[index+FTO_PATHNAME],
              data[index+FTO_NODENAME]));
            ERRload_struct (NFM, NFM_E_CF_ACCESS_FILE, "%s%s%s",
              data[index+FTO_COFILENAME], data[index+FTO_PATHNAME],
              data[index+FTO_NODENAME]);
            break;
          }
        }
      }
      else
      {
        _NFMdebug ((fname, 
           "case == NFM_CHANGE_FILE_INFORMATION, Error is not loaded yet\n"));
        return (NFM_E_ERROR_NOT_LOADED);
      }
      break;
    default:
      _NFMdebug ((fname, "case == default, Error is not loaded yet\n"));
      return (NFM_E_ERROR_NOT_LOADED);
  }
      
  _NFMdebug ((fname, "EXIT: successful\n"));
  return (NFM_S_SUCCESS);
}

