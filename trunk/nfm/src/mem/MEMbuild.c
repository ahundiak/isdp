/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Build the column array, format array and data    *
*                  array for the memory structure.                  *
*                                                                   *
* Arguements       long MEMbuild_array (list)                       *
*                       MEMptr  list;                               *
*                                                                   *
* Algorithm        Set the first byte to indicate the structure     *
*                  information is for the first buffer and call     *
*                  MEMload_structure with 0 offset.                 *
*                                                                   *
* Return Status    MEM_E_NULL_LIST    : Failure.                    *
*                  MEM_E_NULL_BUFFER  : Failure.                    *
*                  MEM_E_INVALID_SIZE : Failure.                    *
*                  MEM_S_SUCCESS      : Success.                    *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMload_structure ()                             *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 9, 1992                  *
*                   Comments     : Removed calls to MEMerror().     *
*                                  Added calls to ERRload_struct(). * 
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

#include "ERR.h"
#include "DEBUG.h"
#include "MEM.h"

static int tracex = 0;

long MEMbuild_array (MEMptr list)
{
  static char *fname = "MEMbuild_array";
  long  status;
  long  buffer_size, x;

  // Say hi
  if (tracex) { g_message(">>> %s\n",fname); }

  // Check args
  g_return_val_if_fail(list,            MEM_E_NULL_LIST);
  g_return_val_if_fail(list->buffer_ptr,MEM_E_NULL_BUFFER);

  buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED);
  g_return_val_if_fail(buffer_size,MEM_E_INVALID_SIZE);

  status = (int) MEMload_structure (list, 0);
  g_return_val_if_fail(status == MEM_S_SUCCESS,status);

  x = atol (list -> buffer_ptr + MEM_NO_BUFFER);
  if (x)
  {
    *(list -> buffer_ptr + MEM_NO_BUFFER) = (char) 0x31;
    for( x = 1; x < MEM_INT_SIZE; ++x)
    {
      *(list -> buffer_ptr + MEM_NO_BUFFER + x) = (char) 0x00;
    }
    *(list -> buffer_ptr + MEM_REALLOC_SIZE - 1) = (char) 0x00;
  }
  return (MEM_S_SUCCESS);
}
