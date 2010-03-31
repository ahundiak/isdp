/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
# include <memory.h>        /* memset function      */
# include "OMerrordef.h"    /* OM error coedes      */
# include "OMminimum.h"     /* GRalign              */
# include "OMprimitives.h"  /* om$calloc            */
# include "EMSmsgdef.h"     /* EMS error messages   */
# include "EMSlogic.h"      /* EMSmsgReport         */
# include "EMStypedef.h"    /* EMSmsgReport         */
# include "EMScmacros.h"    /* EMSmsgReport         */
# include "igrtypedef.h"    /* GRalign              */
# include "gocmacros.h"     /* GRalign              */

/*
    This routine will get the amount of memory specified by either
    allocating memory or pointing to the buffer. If clear is speciified,
    the memory will be all zeros.
*/

void EFgetMemory(EMmsg, element_size, num_elements, buffer, buffer_size,
                 options, ptr)

long    *EMmsg;         /* Return code                                  */
int     element_size;   /* Number of bytes per element                  */
int     num_elements;   /* Number of elements                           */
char    *buffer;        /* Buffer provided bu the caller                */
int     buffer_size;    /* Size of the buffer                           */
char    options;        /* If non-zero the memory will be set to zeros  */
char    **ptr;          /* Pointer to the memory                        */
{
  int   num_bytes;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;

  /*
   * If the element size is 1, don't bother aligning the pointer.
   */
  if(element_size IS 1) options &= ~ 2;

  num_bytes = num_elements * element_size;
  if(num_bytes + element_size - 1 < buffer_size)
  {
    /*
     * Get the memory from the buffer
     */
    switch(options)
    {
      case 0:
        /*
         * Don't clear memory or align the pointer.
         */
        *ptr = buffer;
        break;

      case 1:
        /*
         * Clear memory, but don't align the pointer
         */
        *ptr = memset(buffer, 0, num_bytes);
        break;

      case 2:
        /*
         * Align the pointer, but don't clear memory.
         */
        if((element_size != 2) && (element_size != 4))
          element_size = 8;
        *ptr = GRalign_bdry(element_size, buffer);
        break;

      case 3:
        /*
         * clear memory and align the pointer
         */
        if((element_size != 2) && (element_size != 4))
          element_size = 8;
        *ptr = memset(GRalign_bdry(element_size, buffer), 0, num_bytes);
        break;

      default:
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
    }
  }
  else
  {
    /*
     * Allocate the memory
     */
    switch(options)
    {
      case 0: case 2:
        *ptr = om$malloc(size = num_bytes);
        if(! *ptr) *EMmsg = EMS_E_NoDynamicMemory;
        else *EMmsg = EMS_I_DynamicMemoryAllocated;
        break;

      case 1: case 3:
        *ptr = om$calloc(size = num_bytes);
        if(! *ptr) *EMmsg = EMS_E_NoDynamicMemory;
        else *EMmsg = EMS_I_DynamicMemoryAllocated;
        break;

      default:
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
    }
  }

wrapup:
  EMSmsgReport(*EMmsg, "EFgetMemory", FALSE);
  return;
}
