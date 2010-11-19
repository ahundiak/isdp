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
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 9, 1992                  *
*                   Comments     : Added calls to ERRload_struct()  *
*                                  for non-success statuses.        *
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

#include "ERR.h"
#include "MEM.h"
#include "DEBUG.h"

long MEMno_rows (MEMptr list, long offset)
{
  long   status;
  long   data_offset, buffer_size;
  static char *fname = "MEMno_rows";

  // Arg check
  g_return_val_if_fail(list,            MEM_E_NULL_LIST);
  g_return_val_if_fail(list->buffer_ptr,MEM_E_NULL_BUFFER);

  buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED + offset);
  data_offset = atol (list -> buffer_ptr + MEM_DATA_OFFSET + offset);
     
  status = MEMrow_size (list, offset);
  g_return_val_if_fail(status == MEM_S_SUCCESS,status);

  if (data_offset) list -> rows = (buffer_size - data_offset) / list -> row_size;
  else             list -> rows = 0;

  return  (MEM_S_SUCCESS);
}
