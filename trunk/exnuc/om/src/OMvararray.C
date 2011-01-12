/*----------------------------------------------------------------------------

   File:  OMvararray.C

   Description:  Runtime support for variable length arrays.

   Revisions :								

    6/13/86 PLH - Changed so that arrays are always aligned on the	
  		  size of their members (or 8 max).  (for Clipper)	
  									
    7/7/86  PLH - 4.0 Changes. 						
  		  Initial object size no longer includes VLAs.		
  		  Default dimensions may no longer be overridden at	
  		  construct time.  Parameters to find_initial_size	
  		  initialize_offsets have changed.			
  		  Changed to accomodate changes in object header.  Now	
  		  uses pointer to spacemap rather than "me".		
  		  Routine names regularized.				
  									
    8/1/86  RME - Remove references to p_array.  A self-relative offset 
                  (i_offset) is used to access the elements in the VLA.  
                  Due to the new algorithm used in som_vla_collapse, the 
                  order of the array definitions and descriptors may not 
                  necessarily represent the physical order in which the 
                  arrays are stored in the object.                                 

    3/1/87  JHM - Stop using malloc for outriggers.  Instead, allocate
		  space from the same cluster that contains the object 
		  using the som_find_space routine.  The size of an 
		  outrigger is automatically set in the header of the 
		  allocated block.  It is in the second longword.


    3/3/87  RME - Added som_vla_remove_outriggers to enable delete object
                  to recover space without having to collapse an object.

    4/6/87  RME - Added code to set dimension to update field in the cluster
                  composite to keep track of the number of bytes actually
                  used in a vla.

   4/14/87  RME - Get size of object now returns an aligned size.

   4/29/87  RME - Changes to vla set dimension:
                  Make outriggers actually get smaller.  An outrigger
                  set to zero size is removed.  These changes are
                  necessary because objects are no longer collapsed
                  by default.  It also makes the job of determining
                  the number of bytes allocated in a cluster easier.

   5/5/87   RME - remove som_vla_collapse and add parameter to
                  remove_outriggers so it can access the cluster composite.

   5/8/87   RME - fixed size in outrigger hdr, it did not include the 
                  hdr size itself.

   5/13/87  RME - Changed set dimension routine entirely.  Removed all
                  references to OM_Gi_VLA_outside_bytes.  Also changed
                  get size of object.  There was no longer any need to
                  sort arrays.  Everything is now aligned.


   9/11/87  RME - Changed the self-relative offset back to pointer.  Also,
                  zero size arrays have a NULL pointer in the object. A
                  "fixup" routine was added to convert to/from offsets
                  for writing/reading objects.

   9/22/87  RME - New changes for channels.  Channels are now a special
                  case of vla in that their size is computed differently.

  10/07/87  RME - changed som_vla_fixup to not check the count field 
			in the vla descriptor.

  10/13/87  RME - Changed the parameters to set dimension.  Instead of
			a pointer to the spacemap, osnum objid are passed in.

  12/16/87  GEO - OM4.5 clustering changes to spacemap and objecthdr
			data structures.  Also outrigger objecthdr will
			contain high order bit on (indicator that this
			is an outrigger) and its vad's element size.

   1/19/88  GEO - In set dimension where outrigger is getting larger,
		 	if move data flag is false then free space first
			and then create new outrigger.  
---------------------------------------------------------------------------*/

#include <stdio.h>
#include "OMobjectcomm.h"
#include "OMcluster.h"

#ifndef OM_D_INTPRIMS
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#endif

#ifdef BIG_ENDIAN
#include "OMport.h"
extern int      OM_Gf_ioMode;
extern void     *OM_Gp_inst_in;
extern void     *OM_Gp_inst_out;
#endif

extern int som_create_outrigger();
extern OM_S_CSD	*OM_GA_CSDarray;

int	OM_setdim_validate_counter=0;

#define ALIGN(x) (((int)(x)+7)&((int)~7))


#define IF_VLA_OUTSIDE_OBJECT(p,me) \
( ( (( PTR(p) > (char*)(me)+OM_GETOBJSIZE(((OM_p_OBJECTHDR)(me))->i_size)) || \
     ( PTR(p) < (char*)(me) )) && ( PTR(p) )  \
  ) ? 1:0 )

#define PTR(p)  ((char *)(((OM_p_VARLENARR_DESCR)(p))->i_offset))



struct OM_sd_inrigger_data
{
   int     *p_offset;  /* Used to change the array pointer if the array
                          moves during compression. */
   OMuint  byte_size;  /* Total aligned byte size of this array. */
};

typedef struct OM_sd_inrigger_data OM_S_INRIGGER_DATA;
typedef struct OM_sd_inrigger_data *OM_p_INRIGGER_DATA;


OM_p_INRIGGER_DATA OM_GA_inrigger_data = 0;
int                OM_Gi_inrigger_data_size = 0;
int                OM_Gi_min_free_space = 64;



static int create_outrigger(p_clustcmp, p_pcd, new_size, ele_size, pp_new)

/*-----------------------------------------------------------------------------
   Description:

   Creates a new outrigger to store vla data.
-----------------------------------------------------------------------------*/

OM_p_LCD      p_clustcmp;    /* Pointer to cluster descriptor. */
OM_p_PCD      p_pcd;         /* Pointer to my phy cluster descriptor */
OMuint        new_size;      /* No. of bytes to allocate. */
OMuint        ele_size;      /* Index of the array definition. */
char          **pp_new;      /* Return the pointer to new array. */

{
   OMuint            size;        /* Total size of the outrigger. */
   int               sts;         /* OM return status. */
   OM_p_OBJECTHDR    p_outrigger; /* Pointer to the new outrigger. */

   /*------------------------------------------------------------------*/
   /*  Now, allocate a block of memory from an extent in the cluster.  */
   /*  The "find space" routine will record the size in the header.    */
   /*------------------------------------------------------------------*/

   size = ALIGN(new_size + sizeof(OM_S_OBJECTHDR));

   sts = som_create_outrigger( p_clustcmp, p_pcd,
                        size, &p_outrigger);
   if (!(1&sts))  
      return (sts);

   /*-----------------------------------------------------------------*/
   /*  Set classid so anyone stepping through the extent will know    */
   /*  that this is a vla chunk.                                      */
   /*-----------------------------------------------------------------*/

   p_outrigger->oid = ele_size;
   OM_SETFREEBIT(p_outrigger->oid)
   *pp_new = (char *) p_outrigger + sizeof(OM_S_OBJECTHDR);

   return (OM_S_SUCCESS);
}      



int som_aligned_vla_size(p_vad, p_descr)

/*-----------------------------------------------------------------------------
   Description:

   Returns the aligned byte size of an array.
-----------------------------------------------------------------------------*/

OM_p_VARLENARR_DEFN  p_vad;      /* pointer to the array definition. */
OM_p_VARLENARR_DESCR p_descr;    /* pointer to the array descriptor. */

{
   int size = 0;

   if (p_descr->i_offset)
   {
      if (p_vad->type)
      {
         /*--------------------------*/
         /* This array is a channel. */
         /*--------------------------*/

         OMuint chan_count;
         OM_p_BIG_TAIL p_tail;
         OM_p_CHANNEL_HDR ptr = (OM_p_CHANNEL_HDR) p_descr->i_offset;

#ifdef BIG_ENDIAN
         /*==========================================================*/
         /*  This block-o-logic is a quick kludge to fix an unknown  */
         /*  object problem for BIG ENDIAN machines.  See the code   */
         /*  in som_connect_build_fake_side for the setup            */
         /*==========================================================*/

         if (p_vad->w_count == 27977) {
            OM_Gf_ioMode   = READ_PORT;         
            OMPORT_CONV_SHORT ( ptr, 2 );
         }
#endif

         if (ptr->flags & OM_CH_singleton)
         {
            if (ptr->flags & OM_CH_restricted)
               size = sizeof(OM_S_RESTRICTED_ONECHAN);
            else
               size = sizeof(OM_S_CHANNEL_LINK);
         }/* if singelton channel */
         else
         {
            size = sizeof(OM_S_CHANNEL_HDR);

            if (ptr->flags & OM_CH_bigchan)
            {
               p_tail = (OM_p_BIG_TAIL)((OMuint)ptr +sizeof(OM_S_CHANNEL_HDR));
               chan_count = p_tail->size;
            }
            else
            {
               chan_count = ptr->u1.count;
            }
            if (ptr->flags & OM_CH_restricted)
               size += chan_count * sizeof(OM_S_OBJID);
            else
               size += chan_count * sizeof(OM_S_CHANNEL_LINK);
         }/* else not a singleton channel */

#ifdef BIG_ENDIAN
         if (p_vad->w_count == 27977) {    /*  see note above  */
            OM_Gf_ioMode   = WRITE_PORT;
            OMPORT_CONV_SHORT ( ptr, 2 );
         }
#endif

      }/* if array is a channel */
      else
      {
         /*------------------------------*/
         /* This array is not a channel. */
         /*------------------------------*/

         size = p_descr->i_count * p_vad->w_per_elt_size;

      }/* else array is not a channel */
   }/* if array is not empty */

   return (ALIGN(size));
}      



/*----------------------------------------------------------------------------
    Description:

    Increases or decreases the size of a VLA.

----------------------------------------------------------------------------*/

int som_vla_set_dimension (
int                  *p_offset,   /*  Pointer to the pointer to array data. */
unsigned int         *p_count,    /*  Pointer to the current element count. */
OMuint               dim,	  /*  new dimension of array. */
OMuword		     osnum,       /*  OS for "me". */
OM_S_OBJID	     objid,       /*  "my_id" */
OM_p_CLASSDEF        p_acld,      /*  pointer to class definition structure */
int                  move_data)   /*  TRUE or FALSE to save old data. */

{
   OM_p_OBJECTHDR  me;           /* Pointer to object containing the array. */
   OM_p_LCD   p_clustcmp=NULL;   /* Pointer to cluster descriptor. */
   OM_p_OBJECTHDR  p_free;       /* Ptr to chunk of memory to be set free. */
   OMuint          free_flag=0;  /* What type of chunk is set free. */
   OMuword         num_arrays;   /* No. of vlas in the object. */
   char            *p_array;     /* Pointer to the array data. */
   int             cur_bytes=0;  /* No. bytes currently used by the array. */
   int             need_bytes=0; /* No. of bytes after dimensioning. */
   int             sts=OM_S_SUCCESS;          /* OM return status. */
   int             diff=0;       /* Difference in byte size of the array 
                                    before and after the dimensioning. */
   int             size_in_hdr;  /* Aligned size in object header. */
   int		   objhdr_flags; /* Objhdr flags: lower 3 bits of size. */
   int             fixed_size;   /* Aligned size of fixed instance data. */
   OM_p_SPAMAPENT  p_spacemap;   /* pointer to spacemap entry for object. */
   OM_p_PCD	   pcd;          /* pcd in which object exists */

   if (!(num_arrays = p_acld->w_num_varlenarrays))
      return (OM_E_INVARG);

   p_spacemap = &(OM_GA_OSDs[osnum]->Spacemap[objid]);
   me = p_spacemap->state.object;
   pcd = OM_GA_CSDarray[p_spacemap->sdi].p_pcd;
   p_array = (char *)(*p_offset);
   size_in_hdr = OM_GETOBJSIZE(me->i_size);
   objhdr_flags = OM_GETLOW3BITS(me->i_size);
   fixed_size = ALIGN(p_acld->i_instance_size);

#  ifdef DEBUG
      printf("set_dim: entering hdr size %d\n",size_in_hdr);
#  endif

   p_free = NULL;

   if (! IF_VLA_OUTSIDE_OBJECT(p_offset, me))
   {
      /*------------------------------------------------------------*/
      /*  The array to be dimensioned is an inrigger.  Its data is  */
      /*  included as part of the size field in the object hdr.     */
      /*------------------------------------------------------------*/
   
      OM_p_VARLENARR_DEFN  vad;  /* Array of vla definitions. */
      OM_p_VARLENARR_DESCR p;    /* Local ptr to array descriptor. */
      int     free_space;     /* Bytes of free space inside the object. */
      char    *front_ptr;     /* Ptr to free space before the array. */
      char    *back_ptr;      /* Ptr to end of slot for this array. */
      int     front_bytes;    /* Size of the above. */
      int     back_bytes;     /* Size of free space after the array. */
      int     at_end;         /* TRUE if vla located at the end of object. */
      int     in_bytes;       /* Total no. of bytes used by inriggers. */
      int     num_inriggers;  /* No. of arrays inside the object. */
      OMuword w_def_indx;     /* Index of the array definition. */
      OMuint  ele_size=0;     /* vla element size */
      char    *tmp_p_array;   /* Local pointer to array data. */
      OMuint  tmp_array_size; /* Aligned size of an array. */
      OMuword ii;             /* Loop counter. */
      OMuword csd_flag;       /* Current flag settings on csd */

      csd_flag = pcd->p_csd->flag;  /* Might have to test for Big obj later */
      if (! OM_GA_inrigger_data)
      {
         /*------------------------------------------------------------*/
         /*  Allocate enough space to store info on all inriggers.     */
         /*  Have to store this data because dimensioning an in-       */
         /*  rigger could possibly involve free space recovery within  */
         /*  the object.                                               */
         /*------------------------------------------------------------*/

         OM_GA_inrigger_data = (OM_p_INRIGGER_DATA) 
            om$malloc(size=(sizeof(OM_S_INRIGGER_DATA)*num_arrays));

         OM_Gi_inrigger_data_size = num_arrays;
      }
      else
      {
         if ((OMuword) OM_Gi_inrigger_data_size < num_arrays)
         {
            OM_GA_inrigger_data = (OM_p_INRIGGER_DATA) 
               om$realloc(size=(sizeof(OM_S_INRIGGER_DATA)*num_arrays),
                          ptr=(char *) OM_GA_inrigger_data);

            OM_Gi_inrigger_data_size = num_arrays;
         }
      }

      if (! OM_GA_inrigger_data)
         return (OM_E_NODYNMEM);

      vad = p_acld->p_varlenarr_defns;
      num_inriggers = 0;
      in_bytes = 0;
      at_end = 1;
      w_def_indx = 0xffff;
      
      front_ptr = (char *)me + fixed_size;
      front_bytes = 0;
      back_bytes = 0;
      back_ptr = (char *)me + size_in_hdr;

      free_space = 0;

      /*-------------------------------------------*/
      /*  Loop through all the array definitions.  */
      /*-------------------------------------------*/


      for (ii=0; ii < num_arrays; ++ii)
      {
         p = (OM_p_VARLENARR_DESCR)(vad[ii].w_offset + (char *) me);
         tmp_p_array = PTR(p);
         tmp_array_size = som_aligned_vla_size(&(vad[ii]),p);

         if ((int *) p == p_offset)
         {
            /*------------------------------------------------------*/
            /*  Found myself.  Return if array will stay the same.  */
            /*------------------------------------------------------*/

            if ((*p_count) == dim)
               return (OM_S_SUCCESS);

            cur_bytes = tmp_array_size;
            need_bytes = ALIGN(dim * vad[ii].w_per_elt_size);

            if (!(diff = cur_bytes - need_bytes))
            {
               (*p_count) = dim;
               return (OM_S_SUCCESS);
            }

            p_clustcmp = OM_GA_CSDarray[p_spacemap->sdi].p_pcd->p_lcd;

	    w_def_indx = ii;
            ele_size = vad[ii].w_per_elt_size;
            in_bytes += cur_bytes;

            if (! cur_bytes)
            {
               /*-------------------------------------------------------*/
               /*  The array is currently of size zero.  Do the noble   */
               /*  thing:  create a new outrigger then get out of this  */
               /*  mess.                                                */
               /*-------------------------------------------------------*/

               sts = create_outrigger(p_clustcmp, 
				      pcd,
                                      need_bytes,
                                      ele_size, 
                                      &p_array);
               if (!(1&sts))
                  return (sts);

               (*p_offset) = (int)p_array;
               (*p_count) = dim;
               p_spacemap->flags |= OM_SM_array_mod;

               return (OM_S_SUCCESS);
            }

         }/* if found myself */
         else
         {
            /*----------------------------------------------------------*/
            /*  When I am an inrigger and array p is an inrigger need   */
            /*  to find any free chunk before or after me.              */
            /*----------------------------------------------------------*/

            if (! IF_VLA_OUTSIDE_OBJECT(p, me))
            {
               char *p_end;  /* Ptr to the aligned end of array p. */

               OM_GA_inrigger_data[num_inriggers].p_offset = &(p->i_offset);
               OM_GA_inrigger_data[num_inriggers].byte_size = tmp_array_size;

               ++num_inriggers;

               in_bytes += tmp_array_size;

               p_end = tmp_p_array + tmp_array_size;

               if ( (p_end > front_ptr) &&
                    (p_end <= p_array) )
               {
                  front_ptr = p_end;
                  front_bytes = p_array - p_end;
               }
               else
               {
                  if ( (tmp_p_array > p_array) &&
                       (tmp_p_array < back_ptr) )
                  {
                     back_ptr = tmp_p_array;
                     at_end = 0;
                     back_bytes = tmp_p_array - p_array;
                  }
               }

            }/* if array p is an inrigger */
         }/* else array p is not me */
      }/* loop through array definitions */
   
      if (w_def_indx == 0xffff)
         return (OM_E_INVARG);

      if (back_bytes)
         back_bytes -= cur_bytes;

      if (dim == 0)
      {
         /*----------------------------------*/
         /*  Setting an inrigger to size 0.  */
         /*----------------------------------*/

         if (at_end)
         {
            me->i_size = size_in_hdr - (front_bytes + cur_bytes + back_bytes);
	    OM_SETLOW3BITS(me->i_size, objhdr_flags);
         }
         else
         {
            free_space = size_in_hdr -
                         fixed_size -
                         in_bytes +
                         cur_bytes;

         }/* else not at end of object */

         (*p_offset) = 0;

      }/* if setting dimension to zero */
      else
      {
         if (diff < 0)
         {
            /*-------------------------------*/
            /*  Inrigger is getting larger.  */
            /*-------------------------------*/

            if (cur_bytes + back_bytes < need_bytes)
            {
               /*-----------------------------------------------*/
               /*  Array hasn't room to expand without moving.  */
               /*-----------------------------------------------*/
               if (cur_bytes + front_bytes + back_bytes >= need_bytes)
               {
                  /*------------------------------------------------------*/
                  /*  Room inside the object if the array is moved "up".  */
                  /*------------------------------------------------------*/

                  if (move_data)
                     OM_BLOCK_MOVE(p_array, front_ptr, cur_bytes);

                  p_array = front_ptr;
                  (*p_offset) = (int) p_array;

                  if (at_end)
                  {
                     /*-----------------------------------------------------*/
                     /*  Free up any unused space at the end of the object. */
                     /*-----------------------------------------------------*/

                     me->i_size = (int)p_array + need_bytes - (int)me;
	    	     OM_SETLOW3BITS(me->i_size, objhdr_flags);

                  }/* if at end of object */
                  
                     
               }/* if room with array moved "up" */
               else
               {
                  /*-----------------------------------*/
                  /*  Have to create a new outrigger.  */
                  /*-----------------------------------*/

                  char *p_new_data;     /* Pointer to the new array. */

                  sts = create_outrigger(p_clustcmp, 
					 pcd,
                                         need_bytes, 
                                         ele_size,
                                         &p_new_data);
                  if (!(1&sts))
                     return (sts);
            
                  if (move_data)
                     OM_BLOCK_MOVE(p_array, p_new_data, cur_bytes);

                  (*p_offset) = (int)p_new_data;

                  if (at_end)
                  {
                     /*-------------------------------------------*/
                     /*  Need to free as much space as possible.  */
                     /*-------------------------------------------*/

                     me->i_size = size_in_hdr - (front_bytes + 
                                                 cur_bytes + 
                                                 back_bytes);
	    	     OM_SETLOW3BITS(me->i_size, objhdr_flags);

                     /*  Have to subtract the size of the inrigger here
                         to insure that the call to free will be correct. */

                  }/* if at end of object. */
                  else
                  {
                     free_space = size_in_hdr -
                                  fixed_size -
                                  in_bytes +
                                  cur_bytes;

                  }/* else not at end of object */
               }/* else creating new outrigger */
            }/* else array must be moved */
         }/* if inrigger is getting larger */
         else
         {
            /*--------------------------------*/
            /*  Inrigger is getting smaller.  */
            /*--------------------------------*/

            if (at_end)
            {
               /*-----------------------------------------------------*/
               /*  Free up any unused space at the end of the object. */
               /*-----------------------------------------------------*/

               me->i_size = (int)p_array + need_bytes - (int)me;
     	       OM_SETLOW3BITS(me->i_size, objhdr_flags);

            }/* if at end of object */
            else
            {
               free_space = size_in_hdr - fixed_size - in_bytes + diff;

               /*-------------------------------------------------*/
               /*  Put myself in the list of inriggers because I  */
               /*  might have to be moved if compressed.          */
               /*-------------------------------------------------*/
 
               (*p_count) = dim;

               OM_GA_inrigger_data[num_inriggers].p_offset = p_offset;
               OM_GA_inrigger_data[num_inriggers].byte_size = need_bytes;

               ++num_inriggers;
            }/* else not at end of object */

         }/* else inrigger getting smaller */
      }/* else not setting to size zero */

      /*---------------------------------------------------------*/
      /*  Check to see if free space in the object needs to be   */
      /*  reclaimed.  Unused space is reclaimed if it is greater */
      /*  than 12.5% of the total vla data contained in the ob-  */
      /*  ject and if it is  greater than the minimum amount of  */
      /*  space we are willing to go after.                      */
      /*---------------------------------------------------------*/

      if ( (free_space > (in_bytes >> 3)) &&
           (free_space > OM_Gi_min_free_space) )
      {
         /*----------------------------------------------------*/
         /*  Sort the array of inriggers into ascending order  */
         /*  on PTR.                                           */
         /*----------------------------------------------------*/

         char *move_to;
         int  gap, jj;
         OM_p_INRIGGER_DATA in = OM_GA_inrigger_data;
         OM_S_INRIGGER_DATA tmp;

#ifdef COMPRESS_CHECK
   printf("som_vla_set_dimension: compressing inrigger data\n");
#endif

         for (gap = num_inriggers/2; gap > 0; gap /= 2)
            for (ii = gap; ii < (OMuword) num_inriggers; ii++)
               for (jj = ii-gap; jj >=0; jj -= gap)
                  if (*(in[jj].p_offset) > *(in[jj+gap].p_offset))
                  {
                     tmp = in[jj];
                     in[jj] = in[jj+gap];
                     in[jj+gap] = tmp;
                  }

         /*------------------------------------------------------*/
         /*  Pull the inriggers up as far as possible to remove  */
         /*  any free space.                                     */
         /*------------------------------------------------------*/

         me->i_size = size_in_hdr - free_space;
  	 OM_SETLOW3BITS(me->i_size, objhdr_flags);
         move_to = (char *)me + fixed_size;

         for (ii=0; ii < (OMuword) num_inriggers; ++ii)
         {
            tmp_p_array = (char *) *(in[ii].p_offset);
            tmp_array_size = in[ii].byte_size;

            if ((tmp_p_array) && (tmp_p_array != move_to))
            {
               OM_BLOCK_MOVE(tmp_p_array, move_to, tmp_array_size);
               *(in[ii].p_offset) = (int)move_to;
            }

            move_to += tmp_array_size;
         }/* for all inriggers */

      }/* if free greater than threshold */

      /*----------------------------------------------------------------*/
      /*  Set up p_free if free space exists at the end of the object.  */
      /*----------------------------------------------------------------*/

      if ((int) OM_GETOBJSIZE(me->i_size) != size_in_hdr)
      {
         if (!(csd_flag & OM_BIG))  /* Flags upon entry to this routine */
         {
            /* Object is within a slot */

            p_free = (OM_p_OBJECTHDR)((int)me + OM_GETOBJSIZE(me->i_size));
            p_free->i_size = size_in_hdr - OM_GETOBJSIZE(me->i_size);
            free_flag = OM_K_OUTPART;
         }
         else     /* Obj is in sheap (big obj), can't call om$free_space */
         {
            /* Freeing an inrigger of a Big Object.  pcd->i_totalsize
             * represents the size of the main big object chunk which
             * contains the inrigger (it is the size of the chunk
             * pointed to by pcd->p_csd->p_addr); it is reduced by the
             * size of the deleted inrigger.  pcd->i_totalWsheap is
             * the size of the entire Big Object, including all
             * outriggers; it also must be reduced by the size of the
             * deleted inrigger.  saw 11/92
             */

/* If you build this for +++ PURIFY +++, cut here ---- */

            /* If built with Libxc malloc, 'me' doesn't change
               its value.  If not built with Libxc malloc, then
               any pointer to old 'me' has to be updated (spacemap,
               array of tag objects if obj=OMTag, etc)
             */

            if (!(me = (OM_p_OBJECTHDR)
               om$realloc(ptr=(char *) me, size=me->i_size + sizeof(OM_S_OBJECTHDR))))
               return(OM_E_NODYNMEM);
            pcd->i_totalWsheap -= size_in_hdr - OM_GETOBJSIZE(me->i_size);
            pcd->i_totalsize -= size_in_hdr - OM_GETOBJSIZE(me->i_size);

/* --- through here.  So for +++ PURIFY +++, the Big Object gets compressed
   by the code up above, but we don't reallocate it here so that 'me'
   won't change.  We'll just live with the empty memory at the end of
   the Big Object.  Reset the size field of the object header and we're
   done.   saw 9/93

OM_SETLOW3BITS((me->i_size = size_in_hdr), objhdr_flags);

*/
         }
      }

   }/* if I am an inrigger */
   else
   {
      /*------------------------------------------------------------------*/
      /*  Array to be dimensioned is an outrigger.  Its data is stored    */
      /*  outside of the object.  The size field in the object hdr does   */
      /*  not include the size of outrigger data.  Outriggers themselves  */
      /*  are stored as psuedo-objects in the same cluster as the object  */
      /*  which owns the array.  Outriggers have object hdrs that are     */
      /*  slightly different than conventional objects.  The oid field    */
      /*  is used to store the element size of the vla & its high order   */
      /*  bit is turned on.                                               */
      /*------------------------------------------------------------------*/

      OM_p_OBJECTHDR p_outrigger;  /* Pointer to the outrigger. */
      OMuint         element_size; /* Size of one array element. */
      
      if ((*p_count) == dim)
         return (OM_S_SUCCESS);

      p_outrigger = (OM_p_OBJECTHDR) (p_array - sizeof(OM_S_OBJECTHDR));

      element_size = OM_GETFREESIZE(p_outrigger->oid);

      need_bytes = ALIGN(element_size * dim);
      cur_bytes = p_outrigger->i_size - sizeof(OM_S_OBJECTHDR);

      if (!(diff = cur_bytes - need_bytes))
      {
         (*p_count) = dim;
         return (OM_S_SUCCESS);
      }

      p_clustcmp = OM_GA_CSDarray[p_spacemap->sdi].p_pcd->p_lcd;

      if (diff > 0)
      {
         if (dim != 0)
         {
            /*-----------------------------------------------------------*/
            /*  Outrigger is getting smaller.  Need to free part of      */
            /*  the outrigger.  Create a "fake object" by creating       */
            /*  an object hdr at the start of the space to be set free.  */
            /*-----------------------------------------------------------*/

            /*-----------------------------------------------------------*/
	    /*  Is outrigger within physical cluster extent or is it     */
	    /*  in sheap? Set p_free accordingly. Realloc in the case    */
	    /*  of sheap and update relevant pcd and lcd fields.         */
	    /*  But when inside extent, p_free should point to new       */
	    /*  area which becomes freed (i.e. new free header)	  	 */
            /*-----------------------------------------------------------*/

      	    if(pcd->p_csd->p_addr <= (char *) p_outrigger
			&&
	       (pcd->p_csd->p_addr + pcd->i_totalsize > (char *) p_outrigger)
                   && !(pcd->p_csd->flag & OM_BIG))
	    {
              p_free = (OM_p_OBJECTHDR) (p_array + need_bytes);
              p_free->i_size = diff;
              free_flag = OM_K_OUTPART;
              p_outrigger->i_size -= diff;
	    }
	    else
	    {
              p_outrigger->i_size -= diff;
	      if(!(*p_offset=(int) om$realloc(ptr=(char *)p_outrigger, 
			size=need_bytes + sizeof(OM_S_OBJECTHDR))))
	          return(OM_E_NODYNMEM);
              *p_offset += sizeof(OM_S_OBJECTHDR);
	      pcd->i_totalWsheap -= diff;
	    }
         }
         else
         {
            /*--------------------------------*/            
            /*  Setting outrigger to size 0.  */
            /*--------------------------------*/

            p_free = p_outrigger;
            free_flag = OM_K_VLA;

            (*p_offset) = 0;
         }
      }/* if outrigger is getting smaller */
      else
      {
         /*-----------------------------------------------------------------*/
         /*  Outrigger getting larger.  Have to create a new outrigger and  */
         /*  free the old one.                                              */
         /*-----------------------------------------------------------------*/

         char *p_new_data;  /* Ptr to the new array. */
	 OMuint ele_size;

         /*-----------------------------------------------------------------*/
	 /* When data is not to be moved, free space then create new one.   */
         /*-----------------------------------------------------------------*/

	 ele_size = OM_GETFREESIZE(p_outrigger->oid);
	 if(! move_data)
	 {
	      sts = om$free_space( p_clustcmp=p_clustcmp,
                           p_instance=p_outrigger,
                           flag=OM_K_VLA,
                           osnum=osnum,
                           p_extent=pcd );

	      p_free = NULL;
	 }
	 else
	 {
	      p_free = p_outrigger;
	      free_flag = OM_K_VLA;
	 }

         sts = create_outrigger(p_clustcmp, 
				pcd,
                                need_bytes, 
                                ele_size, 
                                &p_new_data);
         if (!(1&sts))
            return (sts);

         if (move_data)
            OM_BLOCK_MOVE(p_array, p_new_data, cur_bytes);

         (*p_offset) = (int)p_new_data;

      }/* if outrigger getting larger */

   }/* else I am an outrigger */

   p_spacemap->flags |= OM_SM_array_mod;
   (*p_count) = dim;

   if (p_free)
   {
      /*-----------------------------*/
      /*  Free the necessary chunk.  */
      /*-----------------------------*/

      sts = om$free_space( p_clustcmp=p_clustcmp,
                           p_instance=p_free,
                           flag=free_flag,
                           osnum=osnum,
                           p_extent=pcd );
   }

   return (sts);
}



int som_vla_collapse_copy (p_orig_object, p_copy, p_copy_spacemap, classdef)

/*----------------------------------------------------------------------------
    Description:

    Consolidates a newly constructed copy of an object.  All VLAs are
    moved into the copy.

-----------------------------------------------------------------------------*/

OM_p_OBJECTHDR p_orig_object;    /*  Pointer to the original object. */
OM_p_OBJECTHDR p_copy;           /*  Pointer to the copy object.  */
OM_p_SPAMAPENT p_copy_spacemap;  /*  Pointer to spacemap entry of the copy. */
OM_p_CLASSDEF  classdef;         /*  Pointer to active class definition.  */

{
   OM_p_OBJECTHDR      me;

   /* Get array definitions from class definition structure. */
  
   OM_p_VARLENARR_DEFN vad      = classdef->p_varlenarr_defns;
   OM_p_VARLENARR_DEFN stop_vad = classdef->w_num_varlenarrays + vad;
   int                 total_size = ALIGN(classdef->i_instance_size);

   register OM_p_VARLENARR_DESCR p;  /*  Pointer to the descriptor  */
   char *start_ptr;                  /*  Where to move the array.  */
   int byte_count;                   /*  Array byte size.          */

   /*--------------------------------------------------------*/
   /*  Get the instance pointer of the copy either from the  */
   /*  spacemap entry or from the parameter.                 */
   /*--------------------------------------------------------*/

   if (p_copy_spacemap)
   {
      me = p_copy_spacemap->state.object;  
   }
   else
   {
      if (p_copy)
      {
         me = p_copy;
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   /*-----------------------------------------------------------------*/
   /*  Loop through all the var array definitions to copy the arrays  */
   /*  and assign new offsets.                                        */
   /*-----------------------------------------------------------------*/

   start_ptr = (char*)me + total_size;	   /* Point beyond fixed data */

   for (; vad < stop_vad; ++vad)       /* All vla descr's in classdef */
   {

      /*  Get the pointer to the descriptors of the COPY.  */

      p = (OM_p_VARLENARR_DESCR)(vad->w_offset+(char*)me);
      if (byte_count = som_aligned_vla_size(vad, p))	/* Vla's size */
         p->i_offset = (int) start_ptr;	      /* Vla descr ptr to vla */
      else
         p->i_offset = 0;

      /*-------------------------------------------------------------*/
      /*  Get a pointer to the descriptor in the original to obtain  */
      /*  a pointer to the original array.                           */
      /*-------------------------------------------------------------*/

      p = (OM_p_VARLENARR_DESCR)(vad->w_offset + (char *)p_orig_object);
      if (byte_count)
      {
         OM_BLOCK_MOVE (PTR(p), start_ptr, byte_count);
         start_ptr += byte_count;	/* Point to next vla location */
      }
   }
 
   /*  If the copy has a spacemap entry, clear the flag.  */

   if (p_copy_spacemap)
   {
      p_copy_spacemap->flags &= ~OM_SM_array_mod; /*clear array_mod flag*/
   }

   return (OM_S_SUCCESS);

} /* som_vla_collapse_copy */



int som_vla_fixup (OM_p_OBJECTHDR p_object, char type)

/*----------------------------------------------------------------------------
    Description:

    Used with object space read and write to convert vla offsets to pointers
    or vla pointers to offsets respectively.

-----------------------------------------------------------------------------*/

/* OM_p_OBJECTHDR p_object;    pointer to the object.
   char           type;        'w' convert to offset, 'r' convert to ptr. */

{
   /* Get array definitions from class definition structure. */
  
   OM_p_CLASSDEF  p_acld;
   OM_p_VARLENARR_DEFN vad;
   OM_p_VARLENARR_DEFN stop_vad;
   OMuword classid;

   register OM_p_VARLENARR_DESCR p;  /*  Pointer to the descriptor  */

   p_acld = OM_Gp_CurSpaceMap[p_object->oid].p_acld;
   classid = p_acld->w_classid;

   if (!classid)
   {
      BUGCHECK("som_vla_fixup: filed classid mapped to active classid of 0.");
   }
   else
      if (OM_K_NOTUSING_CLASSID == classid)
         return (OM_S_SUCCESS);  /* this class is not known to the system. */

   vad = p_acld->p_varlenarr_defns;   
   stop_vad = p_acld->w_num_varlenarrays + vad;
   
   /*------------------------------------------------------------------*/
   /*  Loop through all the var array definitions to assign offsets    */
   /*  or pointers.  THE ARRAYS MUST ALWAYS BE COLLAPSED IN VAD ORDER. */
   /*------------------------------------------------------------------*/

   for (; vad < stop_vad; ++vad)
   {
      p = (OM_p_VARLENARR_DESCR)(vad->w_offset+(char*)p_object);

      if (p->i_offset)
      {
         if ('r' == type)
            p->i_offset += (int)&(p->i_offset);
         else
            p->i_offset -= (int)&(p->i_offset);
      }
   }
 
   return (OM_S_SUCCESS);

} /* som_vla_fixup */



int som_vla_find_initial_size (p_acld, size)

/*----------------------------------------------------------------------------
    Description:

    Computes the initial (byte) size of an object including all VLAs.
    (The VLA sizes are the initial sizes specified in the array
    declarations.)
-----------------------------------------------------------------------------*/

OM_p_CLASSDEF p_acld;
OMuint *size;	/* output value */

{
   OM_p_VARLENARR_DEFN def, lastdef;

   /*-----------------------------------------------------------*/
   /*  Start size of the object equal to the size of the fixed  */
   /*  portion of the object.                                   */
   /*-----------------------------------------------------------*/

   *size = ALIGN(p_acld->i_instance_size);

   if (!p_acld->w_num_varlenarrays) 
      return (OM_S_SUCCESS);

   /*------------------------------------------------------------------*/
   /*  Loop through all the var array definitions and add the size of  */
   /*  each array to the size of the object.                           */
   /*------------------------------------------------------------------*/

   for (lastdef=(def=p_acld->p_varlenarr_defns)+p_acld->w_num_varlenarrays;
        def < lastdef;
        ++def)
      if (def->w_count)
      {
         *size += ALIGN(def->w_per_elt_size * def->w_count);
      }

   if (*size > OM_K_MAXOBJ_SIZE) return (OM_E_OBJSIZE_TOOBIG);

   return (OM_S_SUCCESS);

} /* som_vla_find_initial_size */



int som_vla_initialize_offsets (p_acld, p_instance)

/*----------------------------------------------------------------------------
    Description:

    Sets the VLA descriptor offset fields for all VLAs in the object.
    The offset to the array is simply a direct pointer to the data.
-----------------------------------------------------------------------------*/

OM_p_CLASSDEF   p_acld;
OM_p_OBJECTHDR  p_instance;

{

   OM_p_VARLENARR_DEFN def, lastdef;
   int size;


   if (!p_acld->p_varlenarr_defns) return (OM_S_SUCCESS);

   OM_SET_OBJ_HAS_VLA(p_instance->i_size);

   /*-----------------------------------------------------------*/
   /*  Set the object size to the size of the fixed portion of  */
   /*  object.                                                  */
   /*-----------------------------------------------------------*/

   size = ALIGN(p_acld->i_instance_size);
     
   /*--------------------------------------------------------------*/
   /*  Loop through all the array definitions and compute the new  */
   /*  offsets.                                                    */
   /*--------------------------------------------------------------*/

   for (lastdef=(def=p_acld->p_varlenarr_defns)+p_acld->w_num_varlenarrays;
        def < lastdef;
        ++def)
   {
       OM_p_VARLENARR_DESCR p;
       p = (OM_p_VARLENARR_DESCR)(((char *)p_instance) + def->w_offset);

       if (! def->type)
       {
          /* Not a channel */

          p->i_count = def->w_count;

          if (p->i_count) 
             p->i_offset = size + (int)p_instance;
          else
             p->i_offset = 0;

          size += ALIGN(p->i_count * def->w_per_elt_size);
       }
       else
          p->i_offset = 0;
   }


   return (OM_S_SUCCESS);

}



int som_vla_get_size_of_object (me, classdef, p_fixed_size, p_size)

/*---------------------------------------------------------------------------
    Description:

    Computes the byte size of an object excluding and including VLAs.

----------------------------------------------------------------------------*/

OM_p_OBJECTHDR  me;             /* Instance pointer. */
OM_p_CLASSDEF   classdef;       /* pointer to ACLD. */
int             *p_fixed_size;  /* (Returned) size of the fixed portion of
                                   the object.  */
int             *p_size;        /* (Returned) size of the object if the VLAs
                                   were collapsed.  */

{
   register OM_p_VARLENARR_DEFN  vad;        /* VLA definitions */
   register OM_p_VARLENARR_DESCR p;          /* pointer to VLA descriptor */
   register int                  total_size; /* Accumalated size of object. */
   int                           count;      /* Number of vlas */
   int                           ii;         /* loop counter */


   vad = classdef->p_varlenarr_defns;

   if (!vad)
   {
      /*----------------------------------------------*/
      /*  Return size from object header if no VLAs.  */
      /*----------------------------------------------*/

      *p_size = *p_fixed_size =  OM_GETOBJSIZE(me->i_size);

      return (OM_S_SUCCESS);
   }

   /*-----------------------------------------------------*/
   /*  Loop through all the arrays and compute the total  */
   /*  aligned size of all arrays.                        */
   /*-----------------------------------------------------*/

   count = classdef->w_num_varlenarrays;
   total_size = *p_fixed_size = ALIGN(classdef->i_instance_size);

   for (ii=0; ii < count; ii++)
   {
      p = (OM_p_VARLENARR_DESCR)(vad[ii].w_offset + (char*)me);
      total_size += som_aligned_vla_size(&(vad[ii]),p);
   }

   *p_size = total_size;


   return (OM_S_SUCCESS);
} 



/*----------------------------------------------------------------------------
   Description:

   Called by delete object to free all the outriggers owned by this
   object.  This routine also adds any unused space in the object to
   the bytes allocated field in the cluster composite.  This avoids
   a double subtraction.  (vla_set_dimension has already subtracted 
   this free space and the free_space routine called by delete_object
   will subtract it again.)
----------------------------------------------------------------------------*/

int som_vla_remove_outriggers(
OMuword        osnum,       /* Object space containing the object. */
OM_p_SPAMAPENT p_spacemap,  /* Pointer to space map entry for the object
                               being deleted. */
OM_p_CLASSDEF  p_acld,      /* Pointer to my acld. */
OM_p_LCD       p_clustcmp)  /* Pointer to my cluster composite. */

{
   int                   ii;	        /* loop variable */
   int                   count;		/* number of varrays in object */
   OM_p_VARLENARR_DEFN   vad;   	/* var length array definitions */
   OM_p_VARLENARR_DESCR  p;	        /* Pointer to current array linkage */
   OM_p_OBJECTHDR        me;            /* Pointer to object being deleted. */
   int                   sts;
   int                   *p_data;       /* Pointer to vla data */
   int                   sum;           /* Sum of the aligned inrigger sizes.*/
   OM_p_PCD		 pcd;		/* Pointer to physical cluster descr */

   count = p_acld->w_num_varlenarrays;

   if (count == 0)
      return (OM_S_SUCCESS);

   /*-------------------------------------------------------------------*/
   /*  Loop through all the array definitions and free any outriggers.  */
   /*-------------------------------------------------------------------*/

   me = p_spacemap->state.object;
   vad   = p_acld->p_varlenarr_defns;
   pcd = OM_GA_CSDarray[p_spacemap->sdi].p_pcd;
   sum = 0;

   for (ii=0; ii < count; ii++)
   {
      p = (OM_p_VARLENARR_DESCR) (vad[ii].w_offset + (char *)me);

      if (IF_VLA_OUTSIDE_OBJECT(p,me))
      {
         p_data = ((int*)(PTR(p)));


         sts = om$free_space(p_clustcmp=p_clustcmp, 
                              p_instance=(OM_p_OBJECTHDR) (p_data-2), 
                              flag=(OMuint) OM_K_VLA, 
                              osnum=osnum, 
                              p_extent=pcd);

         if (!(1&sts))
            return (sts);
      }
      else
      {
         /*-------------------------------------------------------------*/
         /*  Need to keep a sum of the aligned inrigger sizes in order  */
         /*  to compute the free space within an object.                */
         /*-------------------------------------------------------------*/

         sum += som_aligned_vla_size(&(vad[ii]),p);
      }
   }

   return (OM_S_SUCCESS);
}
