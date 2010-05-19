class implementation OMTag;

#include <stdio.h>
#include <string.h>
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMerrordef.h"
#include "OMmacros.h"

from OMTagCon import reconnect;


method initialize(int flag)

/*----------------------------------------------------------------------------
   Description:

   Used to set up the initial data structures for an OMTag object.

   flag - Used to suppress the initialization of some of the instance
          data.  flag == TRUE:  this message is being sent to a newly
          constructed OMTag object.  Initialize all instance data.
          flag == FALSE:  this message is being sent to an OMTag object
          that was just loaded back into memory.  Do not initialize all
          the instance data.
----------------------------------------------------------------------------*/
{
   OM_S_CHANSELECT mysel, OSOsel;
   int             sts;

   /*-------------------------------------------------------------*/
   /*  Create global array of hash table pointers and OMTag oids  */
   /*  if they don't already exist.                               */
   /*-------------------------------------------------------------*/

   if (! OM_GA_tag_oids)
   {
      OMuword ii;

      if (NULL == (OM_GA_tag_oids = (OM_p_OBJID) om$calloc(num=OM_Gw_maxOS,
                                               size=sizeof(OM_S_OBJID)) ))
         return (OM_E_NODYNMEM);

      if (NULL == (OM_GA_p_tag_hashtable = (OM_p_TAG_HASHENT *)
                  om$calloc(num=OM_Gw_maxOS,
                               size=sizeof(OM_p_TAG_HASHENT))))
         return (OM_E_NODYNMEM);

      for (ii=0; ii < OM_Gw_maxOS; ii++)
         OM_GA_tag_oids[ii] = NULL_OBJID;
   }

   /*--------------------------*/
   /*  Create the hash table.  */
   /*--------------------------*/
  
   OM_GA_p_tag_hashtable[OM_Gw_current_OS] = (OM_p_TAG_HASHENT) 
                                   om$calloc(num=OM_Gw_tag_hashtable_size,
                                                size=sizeof(OM_S_TAG_HASHENT));

   if (OM_GA_p_tag_hashtable[OM_Gw_current_OS]) 
   { 
      OMuword ii;

      for (ii=0; ii < OM_Gw_tag_hashtable_size; ++ii)
         OM_GA_p_tag_hashtable[OM_Gw_current_OS][ii].index = OM_K_TAG_FREEHASH;

      ME.OMTag->h_free = 0;

      ME.OMTag->hash_block_size = OM_Gw_tag_hashtable_size;
   } 
   else
      return (OM_E_NODYNMEM);


   if (flag)
   {
      /*----------------------------------------------------*/
      /*  I am a newly constructed OMTag object.  Need to   */
      /*  connect myself to the "Group" channel on my OSO.  */
      /*----------------------------------------------------*/

      mysel.type = OM_e_addr;
      mysel.u_sel.addr = &ME.OMTag->to_OSO;

      OSOsel.type = OM_e_name;
      OSOsel.u_sel.name = "OMObjSpace.to_GrpDscs";

      sts = om$send (senderid = my_id,
                     targetid = OM_GO_current_OS_objid,
                     msg = message Root.connect (OSOsel,
                                                 0,
                                                 my_id,
                                                 OM_Gw_current_OS,
                                                 mysel,
                                                 0 ) );
      if (!(1&sts)) 
      {
         om$dealloc(ptr=(char *) OM_GA_p_tag_hashtable[OM_Gw_current_OS]);
         OM_GA_p_tag_hashtable[OM_Gw_current_OS] = NULL;
      
         return (sts);
      }

      ME.OMTag->flags = 0;
      ME.OMTag->next_tag = 0;
      ME.OMTag->next_index = 0;
      ME.OMTag->num_tags = 0;
   }
   
   /*----------------------------------------------*/
   /*  Put my objid into the global array of oids. */
   /*----------------------------------------------*/

   OM_GA_tag_oids[OM_Gw_current_OS] = my_id;

   return (OM_S_SUCCESS);

}



static int hash_objid(p_me, objid, index)
/*----------------------------------------------------------------------------
   Used to add an object to the 
   global tag hash.
----------------------------------------------------------------------------*/
instance OMTag *p_me;
OM_S_OBJID     objid;
int            index;
{
   OM_p_TAG_HASHENT  hashtable;   /* Hash table for this object space. */
   int               hash_index;  /* Hash table index for this hash entry.  */
         
   hashtable = OM_GA_p_tag_hashtable[OM_Gw_current_OS];

   /*-------------------------------------*/
   /*  Insert objid into the hash table.  */
   /*-------------------------------------*/

   hash_index = OM_TAG_HASHOBJID(objid);

   if (hashtable[hash_index].index != OM_K_TAG_FREEHASH)
   {
      /*--------------*/
      /*  Collision.  */
      /*--------------*/
 
      OMuint  cur;  /* Index used to traverse hash free list. */

      if (p_me->h_free == 0)
      {
         /*------------------------------------------------------*/
         /*  Free list is empty, allocate another block of free  */
         /*  entries.                                            */
         /*------------------------------------------------------*/

         int ii;
         int start_size = p_me->hash_block_size;
         int new_size = start_size + OM_Gw_tag_hash_extendsize;

         if (NULL == ( hashtable =
               (OM_p_TAG_HASHENT) om$realloc(ptr=(char *) OM_GA_p_tag_hashtable[OM_Gw_current_OS],
                        size=new_size * sizeof(OM_S_TAG_HASHENT)) ))
         {
            return (OM_E_NODYNMEM);
         }

         OM_GA_p_tag_hashtable[OM_Gw_current_OS] = hashtable;

         for (ii=start_size; ii < new_size - 1; ++ii)
         {
            hashtable[ii].next = ii+1;
            hashtable[ii].index = OM_K_TAG_FREEHASH;
         }

         p_me->h_free = start_size;

         hashtable[new_size - 1].next = 0;
         hashtable[new_size - 1].index = OM_K_TAG_FREEHASH;
           
         p_me->hash_block_size = new_size;
      }        
      
      cur = p_me->h_free;
      p_me->h_free = hashtable[cur].next;

      hashtable[cur].next = hashtable[hash_index].next;
      hashtable[cur].index = index;
      hashtable[hash_index].next = cur;
   }
   else
   {
      hashtable[hash_index].index = index;
      hashtable[hash_index].next = 0;
   }
 
   return (OM_S_SUCCESS);
}


method insert_tag (OM_S_OBJID objid; OMuint *p_tag; OM_p_TAG_RECORD p_tag_rec)

/*----------------------------------------------------------------------------
   Description:

   Used to insert a tag record for the specified objid into this object
   space.  This method works one of two ways:

   If p_tag_rec is NULL, new tag is generated and a new entry is made in
   the vla of tag records.  If p_tag_rec is not NULL,  it is assumed to
   point to a structure containing the tag, version, and the index in the
   tag record vla itself to be used for the new tag record.  This second
   method is used by move tag to enable an existing tag to be associated
   with a different objid.

   objid -     object id of object to be tagged.
   p_tag -     pointer used to return the resulting tag.
   p_tag_rec - pointer to a tag record to be copied into the specified
               index.
-----------------------------------------------------------------------------*/
{
   int               index;       /* Index of new tag record. */
   int               size;        /* Current size of tag record array. */
   int               sts;
   
   if (p_tag_rec)
   {
      /*-------------------------------------------------------*/
      /*  Use an existing record as specified by this struct.  */
      /*-------------------------------------------------------*/

      index = p_tag_rec->objid;

      ME.OMTag->tag_rec[index].objid = objid;
      ME.OMTag->tag_rec[index].tag = p_tag_rec->tag;
      ME.OMTag->tag_rec[index].version = p_tag_rec->version;
   }
   else
   {
      /*---------------------------------------------------*/
      /*  Get the index in the array to store another tag. */
      /*---------------------------------------------------*/

      size = om$dimension_of(varray=ME.OMTag->tag_rec);
 
      if (size == ME.OMTag->next_index)
      {
         int ii, new_size, incr;
         extern int OM_Gi_percent_extend_tag;

         if (!size || ((OMuword) (incr = size * OM_Gi_percent_extend_tag / 100) <
             OM_Gw_tag_rec_extendsize))
            incr = OM_Gw_tag_rec_extendsize;

         new_size = size + incr;

#ifdef DEBUG
         printf("OMTag.insert_tag: vla from %d to %d\n",
		size, new_size);
#endif
         sts = om$vla_set_dimension(varray=ME.OMTag->tag_rec, 
                                    size=new_size);
         if (!(1&sts))
            return (sts);

         /*-----------------------------------*/
         /*  Mark the new entries as unused.  */
         /*-----------------------------------*/

         for (ii=size; ii < new_size; ++ii)
            ME.OMTag->tag_rec[ii].objid = NULL_OBJID;
          
         /*--------------------------------------------------------*/
         /*  Clear the compressed flag.  This indicates there are  */
         /*  some unused entries.                                  */
         /*--------------------------------------------------------*/

         ME.OMTag->flags &= ~OM_Tf_vla_compressed;
      }

      index = ME.OMTag->next_index;
      ++ME.OMTag->next_index;

      /*------------------------------------*/
      /*  Set info. in the new tag record.  */
      /*------------------------------------*/
      
      ME.OMTag->tag_rec[index].objid = objid;
      ME.OMTag->tag_rec[index].version = 0;

      if (!(ME.OMTag->flags & OM_Tf_recycling_tags))
      {
         *p_tag = ME.OMTag->tag_rec[index].tag = ME.OMTag->next_tag;

         /*---------------------------------*/
         /*  Find the next tag to be used.  */
         /*---------------------------------*/

         if (ME.OMTag->next_tag != OM_K_MAXOBJECT_TAG)
            ++ME.OMTag->next_tag;
         else
            ME.OMTag->flags |= OM_Tf_recycling_tags;
      }
      else
      {
         /*----------------------------------------*/
         /*  Have to search for an available tag.  */
         /*----------------------------------------*/
    
         int    size;       /*  Number of elements in tag record vla.  */
         int    not_found;  /*  Flag indicating when a tag has been found.  */
         OMuint tag;        /*  Possible available tag.  */

         size = om$dimension_of(varray=ME.OMTag->tag_rec);
         not_found = TRUE;
         tag = 0;

         while ((not_found) && (tag != OM_K_MAXOBJECT_TAG))
         {
            int ii;

            not_found = FALSE;

            for (ii=0; ii < size; ++size)
            {
               if (! IF_NULL_OBJID(ME.OMTag->tag_rec[ii].objid))
                  if (ME.OMTag->tag_rec[ii].tag == tag)
                  {
                     not_found = TRUE;
                     break;
                  }
            }

            if (not_found)
               ++tag;

         }/*  Searching for an available tag.  */

         if (not_found)
            return (OM_E_NOAVAILABLETAG);

         *p_tag = ME.OMTag->tag_rec[index].tag = tag;

         ME.OMTag->flags |= OM_Tf_tags_unordered;
      }
   }

   /*-------------------------------------*/
   /*  Insert objid into the hash table.  */
   /*-------------------------------------*/

   if (!(1&(sts = hash_objid((instance OMTag *) ME.Root, objid, index))))
      return sts;

   ++ME.OMTag->num_tags;

   return (OM_S_SUCCESS);
}



method remove_tag(OM_S_OBJID objid)

/*--------------------------------------------------------------------------
   Description:

   Used to remove a tag record for the specified objid.  The hash entry
   associated with the tag record is put back on the free list.

   objid - identifies object whose tag is to be removed.
--------------------------------------------------------------------------*/
{
   int               sts;
   OMuint            index;    /*  Vla index of tag record for this objid.  */
   OMuint            l_free;     /*  Index of the free'ed hash entry or
                                   NULL if a hash entry was not free'ed.  */

   /*----------------------------------------------------------------------*/
   /*  Retrieve the tag record for the specified object id.  Get_tag_data  */
   /*  will automatically free a tag record's hash entry  when p_free is   */
   /*  not NULL.  (If the hash entry is in the table itself (not a col-    */
   /*  lision), it will be marked as free and no hash entry is returned    */
   /*  to the free list.)                                                  */
   /*----------------------------------------------------------------------*/

   sts = om$get_tag_data (objid=objid, 
                          p_index=&index,   
                          tag_rec=ME.OMTag->tag_rec,
                          p_free=&l_free );
   if (!(1&sts))
      return (sts);

   ME.OMTag->tag_rec[index].objid = NULL_OBJID;
   
   /*--------------------------------------------------------------*/
   /*  Clear the compressed flag to indicate a "hole" in the vla.  */
   /*--------------------------------------------------------------*/
   
   ME.OMTag->flags &= ~OM_Tf_vla_compressed;

   if (l_free)
   {
      /*------------------------------------------------*/
      /*  Return the free hash entry to the free list.  */
      /*------------------------------------------------*/

      OM_p_TAG_HASHENT  hashtable = OM_GA_p_tag_hashtable[OM_Gw_current_OS];

      if (ME.OMTag->h_free)
         hashtable[l_free].next = ME.OMTag->h_free;
      else
         hashtable[l_free].next = 0;

      hashtable[l_free].index = OM_K_TAG_FREEHASH;
      ME.OMTag->h_free = l_free;
   }
   
   if ((--ME.OMTag->num_tags) == 0)
   {
      /*----------------------------*/
      /*  Last tag, Delete myself.  */
      /*----------------------------*/

      sts = om$send( msg = message Root.delete(TRUE),
                     targetid = my_id );
      if (!(1&sts))
         return (sts);
   }

   return (OM_S_SUCCESS);
}



method get_record_vla(OM_p_TAG_RECORD *pp_tag_rec; 
                      OMuint *p_count;
                      OMuword *p_flags )

/*----------------------------------------------------------------------------
   Description:

   Returns the address of the tag record vla.  Optionally the count
   of the number of elements and the flags word are also returned.
   Note:  Use of this message assumes that the vla DOES NOT MOVE.  

   pp_tag_rec - Used to return the pointer to the first element in the
                vla.

   p_count - Used to return the size of the vla.

   p_flags - Used to return the flags word.
----------------------------------------------------------------------------*/
{
   *pp_tag_rec = ME.OMTag->tag_rec;

   if (p_count)
      *p_count = ME.OMTag->next_index;

   if (p_flags)
      *p_flags = ME.OMTag->flags;

   return (OM_S_SUCCESS);
}



method delete (int flag)

/*----------------------------------------------------------------------------
   Description:

   Used to delete an OMTag object.  Free's the hash table and updates
   any global arrays.

   flag - passed to Root.delete
----------------------------------------------------------------------------*/
{
   int sts;

   sts = om$send(msg = message Root.delete(flag),
                 mode = OM_e_wrt_message,
                 targetid = my_id);
 
   if (!(1&sts))
      return(sts);

   om$dealloc(ptr=(char *) OM_GA_p_tag_hashtable[OM_Gw_current_OS]);

   OM_GA_tag_oids[OM_Gw_current_OS] = NULL_OBJID;
   OM_GA_p_tag_hashtable[OM_Gw_current_OS] = NULL;

   return (OM_S_SUCCESS);
}



static int compress(tag_rec, size, p_first_null)

/*----------------------------------------------------------------------------
   Description:

   Called by the set_up method to remove any null entries from the vla
   of tag records.  

-----------------------------------------------------------------------------*/

OM_p_TAG_RECORD tag_rec;        /*  Pointer the first tag record in vla.  */
int             size;           /*  Dimension of the vla of tag records.  */
int             *p_first_null;  /*  Used to return the index of the first
                                    null entry in the compressed vla.  */
{
   int dest;  /*  Index where next tag is moved to.  */
   int src;   /*  Index of the first NON-NULL entry found.  */
   int jj;

   *p_first_null = 0;

   src = dest = 0;
   while (src < size)
   {
      int len;  /*  Number of entries to be moved from src to dest.  */

      /*--------------------------------------*/
      /*  dest will be the first null entry.  */
      /*--------------------------------------*/

      while (!IF_NULL_OBJID(tag_rec[dest].objid))
      {
         ++dest;
         ++*p_first_null;

         if (dest == size)
            return (OM_S_SUCCESS);
      }

      /*----------------------------------------------------*/
      /*  src will be the first non-null entry after dest.  */
      /*----------------------------------------------------*/

      if (src < dest)
         src = dest;

      while (IF_NULL_OBJID(tag_rec[src].objid))
      {
         ++src;

         /*-----------------------------------------------*/
         /*  Are all the elements from dest to end null?  */
         /*-----------------------------------------------*/

         if (src == size)  
            return (OM_S_SUCCESS);
      }

      /*--------------------------------------------------*/
      /*  len will be the number of records to be moved.  */
      /*--------------------------------------------------*/

      len = 0;
      while (!IF_NULL_OBJID(tag_rec[src+len].objid))
      {
         ++len;

         if (src+len == size)
            break;
      }
      
      /*--------------------------------------------*/
      /*  Move len tag record(s) from src to dest.  */
      /*--------------------------------------------*/

      OM_BLOCK_MOVE(tag_rec+src, tag_rec+dest, len*sizeof(*tag_rec));

      /*----------------------------------*/
      /*  Set the src record(s) to null.  */
      /*----------------------------------*/

      *p_first_null += len;
      dest += len;
      for (jj = 0; jj < len; ++jj)
         if (src+jj >= dest)
         {
            tag_rec[src+jj].objid = NULL_OBJID;
            tag_rec[src+jj].tag = 0;
            tag_rec[src+jj].version = 0;
         }

      src += len;
   }

   return (OM_S_SUCCESS);
}



static int rehash(p_me, tag_rec, size)
/*----------------------------------------------------------------------------
   Re-enters all the tags into the 
   global hash table.
----------------------------------------------------------------------------*/
instance OMTag  *p_me;
OM_p_TAG_RECORD tag_rec;
int             size;
{
   int ii;
   int sts;

   for (ii = 0; ii < size; ++ii)
      if (!IF_NULL_OBJID(tag_rec[ii].objid))
      {
         if (!(1&(sts = hash_objid(p_me, tag_rec[ii].objid, ii))))
            return sts;
         ++p_me->num_tags;
      }

   return (OM_S_SUCCESS);
}



method set_up()

/*----------------------------------------------------------------------------
   Description:

   This message should be sent at object space construct time.  The OMTag
   object will rebuild its hash table and compress any "holes" in the
   vla of tag records.  A search is made of all active os to find any
   OMTagCon objects with matching connect records.  A "reconnect" message
   will be sent to all matching OMTagCon objects to re-establish tagged
   connections.
----------------------------------------------------------------------------*/
{
   int sts;           /*  OM return status.  */
   int temp_num_tags; /*  Temporary storage for number of tags.  */
   int size;          /*  Current dimension of vla of tag records.  */
  
   /*--------------------------------------------------------------------*/
   /*  Save the current number of tags.  Set the number of tags to zero  */
   /*  because the insertion method will increment as each tag is re-    */
   /*  inserted into the hash table.                                     */
   /*--------------------------------------------------------------------*/

   temp_num_tags = ME.OMTag->num_tags;
   ME.OMTag->num_tags = 0;

   /*----------------------------------------------------*/
   /*  Initialize the hash table and the global arrays.  */
   /*----------------------------------------------------*/

   sts = om$send(msg = message OMTag.initialize(FALSE),
                 targetid = my_id);

   if (!(1&sts))
      return (sts);

   /*------------------------------------------------------------------*/
   /*  Compress any "holes" in the vla of tag records and rebuild the  */
   /*  hash table.                                                     */
   /*------------------------------------------------------------------*/

   size = om$dimension_of(varray=ME.OMTag->tag_rec);

   compress(ME.OMTag->tag_rec, size, &ME.OMTag->next_index);

   sts = rehash((instance OMTag *) ME.Root, ME.OMTag->tag_rec, size); 
   if (!(1&sts))
   {
      if (OM_GA_p_tag_hashtable)
      {
         om$dealloc(ptr=(char *) OM_GA_p_tag_hashtable[OM_Gw_current_OS]);
         OM_GA_p_tag_hashtable[OM_Gw_current_OS] = NULL;
         OM_GA_tag_oids[OM_Gw_current_OS] = NULL_OBJID;
      }
  
      return (sts);
   }

   /*-------------------------------------------------------------------*/
   /*  Make sure that the same number of tag records remain after the   */
   /*  compression.                                                     */
   /*-------------------------------------------------------------------*/

   if (temp_num_tags != (int) ME.OMTag->num_tags)
   {
      BUGCHECK("The number of tag records found does not match the stored number of records\n");
      return (OM_F_BUGCHECK);
   }

   /*-------------------------------------------------------------------*/
   /*  Reduce the size of the vla to exactly the number of tag records  */
   /*  needed.                                                          */
   /*-------------------------------------------------------------------*/

   sts = om$vla_set_dimension(varray = ME.OMTag->tag_rec,
                              size = ME.OMTag->num_tags );

   if (!(1&sts))
   {
      if (OM_GA_p_tag_hashtable)
      {
         om$dealloc(ptr=(char *) OM_GA_p_tag_hashtable[OM_Gw_current_OS]);
         OM_GA_p_tag_hashtable[OM_Gw_current_OS] = NULL;
         OM_GA_tag_oids[OM_Gw_current_OS] = NULL_OBJID;
      }
 
      return (sts);
   }

   ME.OMTag->flags |= OM_Tf_vla_compressed;

   /*-------------------------------------------------------------*/
   /*  Search all active object spaces for OMTagCon objects that  */
   /*  contain tag connection records for this object space.      */
   /*-------------------------------------------------------------*/

   if (OM_GA_p_tagcon)
   {
      OMuword ii;

      for (ii = 0; ii < OM_Gw_maxOS; ++ii)
      {
         OM_p_TAGCON_LINK p_cur;       /*  Pointer to current link.  */
         OMuint           not_found;   /*  Indicates a matching OMTagCon object
                                           was found.  */
 
         p_cur = OM_GA_p_tagcon[ii];
         not_found = TRUE;

         while ((p_cur) && (not_found))
         {
            /*-----------------------------------------------------*/
            /*  Searching OS "ii" for a matching OMTagCon object.  */
            /*-----------------------------------------------------*/

            if (not_found = strncmp(p_cur->int_osname, 
                                    OM_GA_OSDs[OM_Gw_current_OS]->InternalName,
                                    OM_K_MAXINTOSNAME_LEN))
               p_cur = p_cur->next;
         }

         if (p_cur)
         {
            /*----------------------------------------------------*/
            /*  Send a reconnect message to the OMTagCon object.  */
            /*----------------------------------------------------*/

            sts = om$send(msg = message OMTagCon.reconnect(ME.OMTag->tag_rec,
                                                           ME.OMTag->num_tags,
                                                           ME.OMTag->flags),
                          targetid = p_cur->objid,
                          targetos = ii);
  
            if (!(1&sts))
               return (sts);
         }

      }/*  Loop through all active OS.  */
   }/*  If any OMTagCon objects exist.  */


   return (OM_S_SUCCESS);
}



method rehash_objids()

/*----------------------------------------------------------------------------
   Description:

   This message is sent by the version converter to recreate the global
   tag hash table.
----------------------------------------------------------------------------*/
{
   int sts;           /*  OM return status.  */
   int temp_num_tags; /*  Temporary storage for number of tags.  */
   int size;          /*  Current dimension of vla of tag records.  */
  
   /*--------------------------------------------------------------------*/
   /*  Save the current number of tags.  Set the number of tags to zero  */
   /*  because the insertion method will increment as each tag is re-    */
   /*  inserted into the hash table.                                     */
   /*--------------------------------------------------------------------*/

   temp_num_tags = ME.OMTag->num_tags;
   ME.OMTag->num_tags = 0;

   /*----------------------------------------------------*/
   /*  Initialize the hash table and the global arrays.  */
   /*----------------------------------------------------*/

   sts = om$send(msg = message OMTag.initialize(FALSE),
                 targetid = my_id);

   if (!(1&sts))
      return (sts);

   /*------------------------------------------------------------------*/
   /*  Compress any "holes" in the vla of tag records and rebuild the  */
   /*  hash table.                                                     */
   /*------------------------------------------------------------------*/

   size = om$dimension_of(varray=ME.OMTag->tag_rec);

   compress(ME.OMTag->tag_rec, size, &ME.OMTag->next_index);

   sts = rehash((instance OMTag *) ME.Root, ME.OMTag->tag_rec, size); 
   if (!(1&sts))
   {
      if (OM_GA_p_tag_hashtable)
      {
         om$dealloc(ptr=(char *) OM_GA_p_tag_hashtable[OM_Gw_current_OS]);
         OM_GA_p_tag_hashtable[OM_Gw_current_OS] = NULL;
         OM_GA_tag_oids[OM_Gw_current_OS] = NULL_OBJID;
      }
  
      return (sts);
   }

   /*-------------------------------------------------------------------*/
   /*  Make sure that the same number of tag records remain after the   */
   /*  compression.                                                     */
   /*-------------------------------------------------------------------*/

   if (temp_num_tags != (int) ME.OMTag->num_tags)
   {
      BUGCHECK("The number of tag records found after rehash does not match the stored number of records\n");
      return (OM_F_BUGCHECK);
   }

   /*-------------------------------------------------------------------*/
   /*  Reduce the size of the vla to exactly the number of tag records  */
   /*  needed.                                                          */
   /*-------------------------------------------------------------------*/

   sts = om$vla_set_dimension(varray = ME.OMTag->tag_rec,
                              size = ME.OMTag->num_tags );

   if (!(1&sts))
   {
      if (OM_GA_p_tag_hashtable)
      {
         om$dealloc(ptr=(char *) OM_GA_p_tag_hashtable[OM_Gw_current_OS]);
         OM_GA_p_tag_hashtable[OM_Gw_current_OS] = NULL;
         OM_GA_tag_oids[OM_Gw_current_OS] = NULL_OBJID;
      }
 
      return (sts);
   }

   ME.OMTag->flags |= OM_Tf_vla_compressed;

   return (OM_S_SUCCESS);
}


int som_validate_tag(osnum)
/*---------------------------------------------------------------------------
   Description:

   Used to validate the hash table and tag record vla.
--------------------------------------------------------------------------*/ 
OMuword          osnum;        /*  OS number containing the OMTag object.  */
{
   OM_p_TAG_RECORD    tag_rec;          /*  vla of tag records.  */
   OMuint             tag_rec_size;	/*  size of tag record vla. */
   OMuint             ii;
   OM_p_TAG_HASHENT   hashtable;        /*  Hash table for osnum.  */
   int                sts;              /*  OM return status.  */
   static int         count = 0;        /*  Number of activation times. */
   int                header = 0;       /*  Flag for printing vla header. */

   ++count;
   sts = OM_S_SUCCESS;

   if (! OM_GA_p_tag_hashtable ||
       (NULL == (hashtable = OM_GA_p_tag_hashtable[osnum])) ||
       IF_NULL_OBJID(OM_GA_tag_oids[osnum]))
   {
      /*printf("som_validate_tag: osnum = %d, no tags\n", osnum);
      return (OM_E_INVARG);*/
      return sts;
   }

   /*------------------------------------------*/
   /*  Get the pointer to the tag record vla.  */
   /*------------------------------------------*/

   sts = om$send(msg = message OMTag.get_record_vla(&tag_rec, &tag_rec_size, NULL),
                 senderid = NULL_OBJID,
                 targetid = OM_GA_tag_oids[osnum],
                 targetos = osnum );
   if (!(1&sts))
   {
      printf("som_validate_tag: osnum = %d, bad status from send to get tag_rec_vla, sts = 0x%.8x\n", osnum, sts);
      return (sts);
   }

   /*------------------------------------------------------------*/
   /*  For every oid in the tag_rec vla, make sure it is in the  */
   /*  global hash table.                                        */
   /*------------------------------------------------------------*/

   for (ii = 0; ii < tag_rec_size; ++ii)
   {
      OM_S_OBJID objid;
      OMuint     cur;              /*  Index of current hash entry.  */
      OMuint     startindex;

      /*-------------------------------------------------------------*/
      /*  Hash the oid and check to see if it is in the hash table.  */
      /*-------------------------------------------------------------*/

      objid = tag_rec[ii].objid;
      if (IF_NULL_OBJID(objid))
         continue;
      else if (!(1&(sts = om$is_objid_valid(objid=objid))))
      {
         if (!header)
         {
            printf("som_validate_tag: osnum = %d, bad tag record(s):\n", osnum);
            header = 1;
         }
         printf("tag_rec[%d].tag =\t%u\t\t0x%.8x\n", 
            ii, tag_rec[ii].tag, tag_rec[ii].tag);
         printf("tag_rec[%d].objid =\t%u\t0x%.8x\tBAD\n",
            ii, tag_rec[ii].objid, tag_rec[ii].objid);
         printf("tag_rec[%d].version=\t%u\t\t0x%.4x\n\n", 
            ii, tag_rec[ii].version, tag_rec[ii].version);
         continue;
      }

      startindex = OM_TAG_HASHOBJID(objid);

      if (! IF_EQ_OBJID(objid, tag_rec[hashtable[startindex].index].objid))
      {
         /*--------------------------------------------------*/
         /*  Need to search list of collisions for a match.  */
         /*--------------------------------------------------*/

         cur = hashtable[startindex].next;
 
         while ((cur != 0) && 
             (! IF_EQ_OBJID(objid, tag_rec[hashtable[cur].index].objid)) )
            cur = hashtable[cur].next;         

         if (cur == 0)
         {
            printf("som_validate_tag: %d: osnum = %d, could not find tag_rec[%d].objid = %d, startindex = %d,\n",
               count, osnum, ii, objid, startindex);
            sts = OM_E_INTERNALS_CORRUPT;
         }
      }
   }/* for all objects in the tag record vla. */

   return sts;
}

end implementation OMTag;
