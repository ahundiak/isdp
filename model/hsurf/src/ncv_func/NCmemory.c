
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "hnmilling.h"
#include "hnerror.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "hnmill.h"
#include "HSpr_ncv_fun.h"

#define MAX_NUM_DEXEL_BUFFERS   26


/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern struct NC_error_flags    NCerror_flags;


/*******************
 * LOCAL VARIABLES *
 *******************/

static IGRint           NCextra_buffer_size = 8192;
static unsigned short   NCcurrent_dexel_buffer = 0;

static struct NCdexel   *NCfree_list;      /* the free dexel list */

static struct
{
   struct NCdexel    *dexbuf;              /* this entire buffer */
   struct NCdexel    *dexel;               /* the next available dexel */
   IGRint            num_dexels;           /* number of untouched dexels left */
} NCdexel_buffer[MAX_NUM_DEXEL_BUFFERS];   /* dexel buffer array */


/*
 *  Prototype declaration for static functions
 */


#if defined (__)
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* NCmemory.c */
static IGRboolean NCadd_another_dexel_buffer __((void));

#if defined(__cplusplus)
}
#endif


#undef __



/*-----NCget_next_dexel------------------------------------------------------*/

   struct NCdexel *NCget_next_dexel( struct NCdexel *dexel )

/* ABSTRACT: NCget_next_dexel decodes the next address field of the given dexel
 *           and returns it in pointer form.
 *
 * HISTORY:   07/25/88   Created.         C. M. Jablonski
 *
 */

{
   return ((dexel->next_hi) ?
           ((struct NCdexel *) ((unsigned long)dexel->next_lo +
                                NCdexel_buffer[dexel->next_hi].dexbuf)) :
           (NULL));
}


/*-----NCinit_dexel_buffers---------------------------------------------------*/

void NCinit_dexel_buffers( IGRint arry_size,
            struct NCdexel **dexarry,
               NCzbuf **zb,
               NCzbuf **zb2,
               NCcbuf **cb )

/*
 * ABSTRACT:  NCinit_dexel_buffers allocates the dexel array, color buffer,
 *            z-buffers  and first dexel buffer.  If there is an allocation
 *            error, all memory is deallocated and NCerror_flags.memory_fault
 *            is set to TRUE.
 *
 * HISTORY:   07/25/88   Created.         C. M. Jablonski
 *
 */

{
   /* allocate the window arrays */
   if (*dexarry = (struct NCdexel *)malloc(arry_size * sizeof(struct NCdexel)))
   {
      if (*zb = (NCzbuf *)malloc(arry_size * sizeof(NCzbuf)))
      {
         if (*zb2 = (NCzbuf *)malloc(arry_size * sizeof(NCzbuf)))
         {
            if (*cb = (NCcbuf *)malloc(arry_size * sizeof(NCcbuf)))
            {
               if (NCdexel_buffer[1].dexbuf = (struct NCdexel *)malloc
                                 (NCextra_buffer_size * sizeof(struct NCdexel)))
               {
                  /* Initialize the buffer.  NOTE: we don't use              */
                  /* NCdexel_buffer[0] because this makes for a quicker test */
                  /* in NCget_next_dexel().                                  */
                  NCcurrent_dexel_buffer = 1;
                  NCdexel_buffer[1].num_dexels = NCextra_buffer_size;
                  NCdexel_buffer[1].dexel =
                                 NCdexel_buffer[NCcurrent_dexel_buffer].dexbuf;

                  /* initialize the free list */
                  NCfree_list = NULL;

                  /* skip the first dexel (will be used if allocation error  */
                  /* later)                                                  */
                  NCdexel_buffer[1].num_dexels--;
                  NCdexel_buffer[1].dexel++;
               }
               else
               { /* allocation error, so clean up */
                  free(*cb);
                  *cb = NULL;

                  free(*zb2);
                  *zb2 = NULL;

                  free(*zb);
                  *zb = NULL;

                  free(*dexarry);
                  *dexarry = NULL;

                  NCerror_flags.memory_fault = TRUE;
               }
            }
            else
            { /* allocation error, so clean up */
               free(*zb2);
               *zb2 = NULL;

               free(*zb);
               *zb = NULL;

               free(*dexarry);
               *dexarry = NULL;

               NCerror_flags.memory_fault = TRUE;
            }
         }
         else
         { /* allocation error, so clean up */
            free(*zb);
            *zb = NULL;

            free(*dexarry);
            *dexarry = NULL;

            NCerror_flags.memory_fault = TRUE;
         }
      }
      else
      { /* allocation error, so clean up */
         free(*dexarry);
         *dexarry = NULL;

         NCerror_flags.memory_fault = TRUE;
      }
   }
   else
   { /* allocation error, so clean up */
      NCerror_flags.memory_fault = TRUE;
   }
}


/*-----NCadd_another_dexel_buffer--------------------------------------------*/

static IGRboolean NCadd_another_dexel_buffer(void)

/*
 * ABSTRACT: NCadd_another_dexel_buffer mallocs space for the next dexel buffer.
 *           It returns FALSE of there is an allocation error.
 *
 * HISTORY:   07/25/88   Created.         C. M. Jablonski
 */

{
   if ((!NCerror_flags.memory_fault) &&
       (++NCcurrent_dexel_buffer < MAX_NUM_DEXEL_BUFFERS) &&
       (NCdexel_buffer[NCcurrent_dexel_buffer].dexbuf = (struct NCdexel *)malloc
                                (NCextra_buffer_size * sizeof(struct NCdexel))))
   {
      /* initialize the buffer */
      NCdexel_buffer[NCcurrent_dexel_buffer].num_dexels = NCextra_buffer_size;
      NCdexel_buffer[NCcurrent_dexel_buffer].dexel =
                                NCdexel_buffer[NCcurrent_dexel_buffer].dexbuf;
      return (TRUE);
   }
   else
   {
      /* reset the current buffer to force another call to this routine */
      if (!NCerror_flags.memory_fault) NCcurrent_dexel_buffer--;

      return (FALSE);
   }
}


/*-----NCcleanup_dexel_buffers------------------------------------------------*/

void NCcleanup_dexel_buffers(void)

/*
 * ABSTRACT:   NCcleanup_dexel_buffers frees up all the dexel buffers.
 *
 * HISTORY:   07/25/88   Created.         C. M. Jablonski
 *
 */

{
   int   i;

   for ( i=1; i<=NCcurrent_dexel_buffer; i++ )
   {
      free ( NCdexel_buffer[i].dexbuf );

      NCdexel_buffer[i].dexbuf = NULL;
      NCdexel_buffer[i].dexel = NULL;
      NCdexel_buffer[i].num_dexels = 0;
   }
}


/*-----NCfree_dexel-----------------------------------------------------------*/

void NCfree_dexel( struct NCdexel **dpp )

/*
 * ABSTRACT: NCfree_init_dexel adds the given dexel to the initial buffer's
 *           free list.  The dexel is assumed to have its own coded address in
 *           its next field, and it is linked into the free list via the
 *           next_free_dexel field.
 *
 * HISTORY:   07/25/88   Created.         C. M. Jablonski
 *
 */

{

   (*dpp)->u.next_free_dexel = NCfree_list;
   NCfree_list = *dpp;
   *dpp = NULL;
}


/*-----NCalloc_dexel----------------------------------------------------------*/

void NCalloc_dexel( struct NCdexel **dpp )

/*
 * ABSTRACT: NCalloc_dexel gets a dexel from the free lists or the current
 *           dexel buffer and assigns its address to the given dexel pointer.
 *           NOTE: the dexel next field contains its own coded address.
 *
 * HISTORY:   07/25/88   Created.         C. M. Jablonski
 *
 */

{
   if (*dpp = NCfree_list)
   {
      NCfree_list = NCfree_list->u.next_free_dexel;
   }
   else
   {
      if ((NCdexel_buffer[NCcurrent_dexel_buffer].num_dexels > 0) ||
          (NCadd_another_dexel_buffer()))
      {
         /* pull the dexel out of the current buffer */
         *dpp = NCdexel_buffer[NCcurrent_dexel_buffer].dexel++;
         NCdexel_buffer[NCcurrent_dexel_buffer].num_dexels--;

         /* set the next field to contain this dexel's own coded address */
         (*dpp)->next_hi = NCcurrent_dexel_buffer;
         (*dpp)->next_lo = (unsigned short)(*dpp -
                                NCdexel_buffer[NCcurrent_dexel_buffer].dexbuf);
      }
      else
      {
         /* out of memory */
         NCerror_flags.memory_fault = TRUE;

         /* set the pointer to the default dexel */
         *dpp = NCdexel_buffer[1].dexbuf;
         (*dpp)->next_hi = 0;
         (*dpp)->next_lo = (unsigned short)0;
      }
   }
}
