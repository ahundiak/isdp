/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Load the structure information of the buffer.    *
*                                                                   *
* Arguements       long MEMno_rows (list, offset)                   *
*                       MEMptr  list;                               *
*                       long    offset;                             *
*                                                                   *
* Algorithm        Calculate the number of columns for the buffer.  *
*                  Load the format and column information for the   *
*                  buffer and get the row size. Next calculate the  *
*                  number of rows and load the data information.    *
*                                                                   *
* Return Status    MEM_S_SUCCESS     : SUCCESS.                     *
*                  MEM_E_NULL_LIST   : FAILURE.                     *
*                  MEM_E_NULL_BUFFER : FAILURE.                     *
*                  MEM_E_DAT_TYPE    : FAILURE.                     *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMformat_list ()                                *
*                  MEMcolumn_list ()                                *
*                  MEMdata_list ()                                  *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*********************************************************************
********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "ERR.h"
#include "MEM.h"
#include "DEBUG.h"

long MEMno_columns (MEMptr list, long offset)
{
  long   status;
  long   data_offset, buffer_size;
  long   i, j, k;
  static char *fname = "MEMno_columns";

  // Arg check
  g_return_val_if_fail(list,            MEM_E_NULL_LIST);
  g_return_val_if_fail(list->buffer_ptr,MEM_E_NULL_BUFFER);

  buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED + offset);
  data_offset = atol (list -> buffer_ptr + MEM_DATA_OFFSET + offset);

  j = 0;

  if (data_offset)  k = data_offset + offset;
  else              k = buffer_size + offset;

  for (i = MEM_HEADER_END + offset + 1;
       i < k && list -> buffer_ptr [i] != '\n'; ++i)
  {
    if (list -> buffer_ptr [i] == '\1')  j = j + 1;
  }

  if (j)
  {
    g_return_val_if_fail(!(j % 2),MEM_E_CORRUPTED_BUFFER);
    list -> columns = j / 2;
  }
  else list -> columns = 0;
     
  return (MEM_S_SUCCESS);
}
