#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMmetaclass.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMtags.h"

extern OMuword OMTag_OPP_initialize_method_index;
extern OMuword OMTag_OPP_insert_tag_method_index;
extern OMuword OMTag_OPP_remove_tag_method_index;
extern OMuword OMTag_OPP_get_record_vla_method_index;
/*
----------------------------------------------------------------------
	Revision History:

geo001	14-dec-1987	OM4.5 clustering changes.
----------------------------------------------------------------------
*/

/*-------------------------------------------------------------------------
   Description:

   Called "tag" an object.  The tag is a unique 32-bit number associated 
   with the objid.  The oid and tag pair constitute a tag record.  Tag 
   records for each OS are stored in an OMTag object.
--------------------------------------------------------------------------*/

int som_tag_object (
OMuword         osnum,       /* OS containing this object. */
OM_p_OBJECTHDR  p_object,    /* Pointer to this object. */
OM_S_OBJID      objid,       /* My oid. */
OMuint          *p_tag)      /* Pointer to store the resulting tag. */
{
   int           sts;
   OM_S_RIP      rip;
   OM_p_CLASSDEF p_acld;  
   OM_S_MESSAGE  insert_msg;

   struct OM_sd_insert_tag_args
   {
      OM_S_OBJID      objid;
      OMuint          *p_tag;
      OM_p_TAG_RECORD p_tag_rec;
   } insert_tag_args;


   /*-------------------------------*/
   /*  Check if tagging is enabled  */
   /*-------------------------------*/

   if ( ! OM_Gf_tagging_enabled ) 
      return (OM_W_TAGDISABLED);

   /*-----------------------*/
   /*  Validate parameters. */
   /*-----------------------*/

   if (!(1&(sts = om$is_objid_valid(objid=objid, osnum=osnum))))
      return (OM_E_NOSUCHOBJ);

   if (!p_object)
   {
      if (!(1&(sts = om$get_any_instance(osnum=osnum,objid=objid,p_rip=&rip))))
         return (sts);

      p_object = rip.p_object;
   }
   else
      rip.p_object = NULL;

   sts = om$get_class ( osnum = osnum,
                        object = p_object,
                        pp_cld = &p_acld );
   if (!(1&sts)) 
   {
      if (rip.p_object)
         om$release_instance(rip=rip);
      return (sts);
   }

   if (!(p_acld->flags & OM_CLDf_TAGGABLE))
   {
      if (rip.p_object)
         om$release_instance(rip=rip);
      return (OM_W_NOTTAGGABLE);
   }

   if (OM_OBJ_IS_TAGGED(p_object->i_size))
   {
      if (rip.p_object)
         om$release_instance(rip=rip);

      return (OM_E_TAGEXISTS);
   }

   /*---------------------------------------------------------------------*/
   /*  Create an OMTag object in the specified OS if one does not exist.  */
   /*---------------------------------------------------------------------*/

   if ( (!OM_GA_tag_oids) || (IF_NULL_OBJID(OM_GA_tag_oids[osnum])) )
   {
      OM_S_MESSAGE  init_msg;
      OM_S_OBJID    tag_oid;
      OM_S_NEIGHBOR neighbor;
     
      struct OM_sd_initialize_args
      {
         int flag;
      } initialize_args;

      init_msg.select.DefClassid = OM_K_OMTAG_ACTCLASSID;
      init_msg.select.ReqClassid = OM_K_OMTAG_ACTCLASSID;
      init_msg.select.FuncIndex  = OMTag_OPP_initialize_method_index;
      init_msg.size              = sizeof(struct OM_sd_initialize_args);
      init_msg.p_arglist         = (char *)&initialize_args;

      initialize_args.flag = TRUE;

      neighbor.clusterid = 0;
      neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;

      sts = om$construct(classid = OM_K_OMTAG_ACTCLASSID,
			 neighbor = neighbor,
                         p_objid = &tag_oid,
                         osnum = osnum,
                         msg = &init_msg );

      if (!(1&sts))
      {
         if (rip.p_object)
            om$release_instance(rip=rip);

         return (sts);
      }

#ifdef DEBUG
printf("som_tag_object: tag_oid = %d\n", tag_oid);
#endif

      OM_GA_tag_oids[osnum] = tag_oid;
   }

   /*-------------------------------------*/
   /*  Insert a tag record for this oid.  */
   /*-------------------------------------*/

   insert_msg.select.DefClassid = OM_K_OMTAG_ACTCLASSID;
   insert_msg.select.ReqClassid = OM_K_OMTAG_ACTCLASSID;
   insert_msg.select.FuncIndex  = OMTag_OPP_insert_tag_method_index;
   insert_msg.size              = sizeof(struct OM_sd_insert_tag_args);
   insert_msg.p_arglist         = (char *)&insert_tag_args;

   insert_tag_args.objid = objid;
   insert_tag_args.p_tag = p_tag;
   insert_tag_args.p_tag_rec = NULL;

   sts = om$send(msg = &insert_msg,
                 senderid = NULL_OBJID,
                 targetid = OM_GA_tag_oids[osnum],
                 targetos = osnum );


   if (!(1&sts))
   {
      if (rip.p_object)
         om$release_instance(rip=rip);

      return (sts);
   }

   OM_SET_OBJ_IS_TAGGED(p_object->i_size);

   return (OM_S_SUCCESS);
}


/*--------------------------------------------------------------------------
   Description:

   Used to remove a tag from an object.  The tag record for the specified
   object is removed, and the object is marked as untagged.
--------------------------------------------------------------------------*/

int som_remove_object_tag (
OMuword           osnum,        /*  OS containing object to be untagged.  */
OM_p_OBJECTHDR    p_object,     /*  Pointer to object being untagged.  */
OM_S_OBJID        objid)        /*  Object id of object to be untagged.  */
{
   OM_S_MESSAGE remove_msg;
   OM_S_RIP     rip;
   int          sts;

   struct OM_sd_remove_tag_args
   {
      OM_S_OBJID      objid;
   }   remove_tag_args;


   /*-----------------------*/
   /*  Validate parameters. */
   /*-----------------------*/

   if ((OM_Gw_maxOS < osnum) || (NULL == OM_GA_OSDs[osnum]))
      return (OM_E_NOSUCHOS);

   if (!(1&(sts = om$is_objid_valid(objid=objid, osnum=osnum))))
      return (OM_E_NOSUCHOBJ);

   if (!p_object)
   {
      if (!(1&(sts = om$get_any_instance(osnum=osnum,objid=objid,p_rip=&rip))))
         return (sts);

      p_object = rip.p_object;
   }
   else
      rip.p_object = NULL;

   if (!OM_OBJ_IS_TAGGED(p_object->i_size))
      return (OM_E_NOTTAGGED);

   /*-------------------------------------*/
   /*  Remove a tag record for this oid.  */
   /*-------------------------------------*/

   remove_msg.select.DefClassid = OM_K_OMTAG_ACTCLASSID;
   remove_msg.select.ReqClassid = OM_K_OMTAG_ACTCLASSID;
   remove_msg.select.FuncIndex  = OMTag_OPP_remove_tag_method_index;
   remove_msg.size              = sizeof(struct OM_sd_remove_tag_args);
   remove_msg.p_arglist         = (char *)&remove_tag_args;

   remove_tag_args.objid = objid;

   sts = om$send(msg = &remove_msg,
                 senderid = NULL_OBJID,
                 targetid = OM_GA_tag_oids[osnum],
                 targetos = osnum );

   OM_CLEAR_OBJ_IS_TAGGED(p_object->i_size);

   if (!(1&sts))
   {
      if (rip.p_object)
         om$release_instance(rip=rip);

      return (sts);
   }

   return (OM_S_SUCCESS);
}


#ifdef DEBUG
OMuint OM_Gi_tag_free_hash_count = 0;
#endif

/*---------------------------------------------------------------------------
   Description:

   Returns the tag and version associated with the specified objid.
   The index in the OMTag object's vla of tag records is also optionally
   returned.  If p_free is not NULL, a hash entry will be reclaimed and the
   index of the free'ed entry will be returned.
--------------------------------------------------------------------------*/ 

int som_objid_to_tag(
OMuword          osnum,        /*  OS number containing the object.  */
OM_S_OBJID       objid,        /*  Object id to be translated.  */
OMuint           *p_tag,       /*  Used to return the tag (if not NULL).  */
OMuword          *p_version,   /*  Used to return version (if not NULL).  */
OMuint           *p_index,     /*  Used to return vla index (if not NULL). */
void             *tag_rec,     /*  Optional vla of tag records.  */
OMuint           *p_free,      /*  Optional ptr to index of free hash entry. */
OMuword          **pp_version) /*  Used to return a pointer to the version. */
{
   OM_p_TAG_HASHENT   hashtable;        /*  Hash table for osnum.  */
   OMuint             cur;              /*  Index of current hash entry.  */
   OMuint             *p_prev_next;     /*  Address of the previous entry's
                                            index to next.  Used to unlink
                                            an entry from the list.  */
   int                sts;              /*  OM return status.  */

   OM_S_MESSAGE         get_record_vla_msg;
   OM_S_GETRECVLA_ARGS  get_record_vla_args;

   /*-----------------------*/
   /*  Validate parameters. */
   /*-----------------------*/

   if (!(1&(sts = om$is_objid_valid(objid=objid, osnum=osnum))))
      return (OM_E_NOSUCHOBJ);

   if (!((p_tag) || (p_version) || (p_index) || (pp_version)))
      return (OM_E_INVARG);

   /*-------------------------------------------------------------*/
   /*  Hash the oid and check to see if it is in the hash table.  */
   /*-------------------------------------------------------------*/

   cur = OM_TAG_HASHOBJID(objid);

   if ( (!OM_GA_p_tag_hashtable) ||
        (NULL == (hashtable = OM_GA_p_tag_hashtable[osnum])) ||
        (hashtable[cur].index == OM_K_TAG_FREEHASH)  )
      return (OM_W_NOTTAGGED);

   /*------------------------------------------*/
   /*  Get the pointer to the tag record vla.  */
   /*------------------------------------------*/

   if (tag_rec == NULL)
   {
      get_record_vla_msg.select.DefClassid = OM_K_OMTAG_ACTCLASSID;
      get_record_vla_msg.select.ReqClassid = OM_K_OMTAG_ACTCLASSID;
      get_record_vla_msg.select.FuncIndex  = OMTag_OPP_get_record_vla_method_index;
      get_record_vla_msg.size              = sizeof(OM_S_GETRECVLA_ARGS);
      get_record_vla_msg.p_arglist         = (char *)&get_record_vla_args;

      get_record_vla_args.pp_tag_rec = (OM_p_TAG_RECORD *) &tag_rec;
      get_record_vla_args.p_count = NULL;
      get_record_vla_args.p_flags = NULL;

      sts = om$send(msg = &get_record_vla_msg,
                    senderid = NULL_OBJID,
                    targetid = OM_GA_tag_oids[osnum],
                    targetos = osnum );

      if (!(1&sts))
         return (sts);
   }

   /*-------------------------------------------------*/
   /*  Look for the objid in the vla of tag records.  */
   /*-------------------------------------------------*/

   if (p_free)
      *p_free = 0;

   p_prev_next = NULL;

   if (! IF_EQ_OBJID(objid, ((OM_p_TAG_RECORD) tag_rec)[hashtable[cur].index].objid))
   {
      /*--------------------------------------------------*/
      /*  Need to search list of collisions for a match.  */
      /*--------------------------------------------------*/

      p_prev_next = &hashtable[cur].next;
      cur = hashtable[cur].next;
 
      while ((cur != 0) && 
             (! IF_EQ_OBJID(objid, ((OM_p_TAG_RECORD) tag_rec)[hashtable[cur].index].objid)) )
      {
         p_prev_next = &hashtable[cur].next;
         cur = hashtable[cur].next;         
      }

      if (cur == 0)
         return (OM_W_NOTTAGGED);
   }

   /*------------------------------*/
   /*  Return all requested data.  */
   /*------------------------------*/

   if (p_index)
      *p_index = hashtable[cur].index;      

   if (p_tag)
      *p_tag = ((OM_p_TAG_RECORD) tag_rec)[hashtable[cur].index].tag;

   if (p_version)
      *p_version = ((OM_p_TAG_RECORD) tag_rec)[hashtable[cur].index].version;

   if (pp_version)
      *pp_version = &(((OM_p_TAG_RECORD) tag_rec)[hashtable[cur].index].version);

   /*-----------------------------------------------------------------*/
   /*  Check to see if the hash entry should be set free.  If the     */
   /*  head of the collision list is to be free, copy the next link   */
   /*  into the head and free the next link.  Otherwise, remove a     */
   /*  link from the collision list.                                  */
   /*-----------------------------------------------------------------*/

   if (p_free)
   {
#ifdef DEBUG
      printf("som_objid_to_tag: freeing hash entry osnum = %d, objid = %d\n",
         osnum, objid);
      ++OM_Gi_tag_free_hash_count;
#endif
      if (p_prev_next)
      {
         /*-----------------------------------------------*/
         /*  Unlink the hash entry and return its index.  */
         /*-----------------------------------------------*/

         *p_prev_next = hashtable[cur].next;
         *p_free = cur;
#ifdef DEBUG
         printf("som_objid_to_tag: hashtable[%d].next = %d, free = %d\n",
            (OM_p_TAG_HASHENT)p_prev_next-hashtable, hashtable[cur].next, cur);
#endif
      }
      else
      {
         /*----------------------------------------------*/
         /*  New head for the collision list.  Free any  */
         /*  entry after the head of the list.           */
         /*----------------------------------------------*/

         if (hashtable[cur].next)
         {
            *p_free = hashtable[cur].next;

#ifdef DEBUG
            printf("som_objid_to_tag: free = %d, ", hashtable[cur].next);
#endif
            hashtable[cur].index = hashtable[hashtable[cur].next].index;

#ifdef DEBUG
            printf("hashtable[%d].index = %d, ", cur, hashtable[cur].index);
#endif
            hashtable[cur].next = hashtable[hashtable[cur].next].next;

#ifdef DEBUG
            printf("hashtable[%d].next = %d\n\n", cur, hashtable[cur].next);
#endif
         }
         else
         {
            hashtable[cur].index = OM_K_TAG_FREEHASH;

#ifdef DEBUG
            printf("som_objid_to_tag: hashtable[%d].index = %d\n\n", cur, hashtable[cur].index);
#endif   
         }
      }
   }

   return (OM_S_SUCCESS);
}


/*----------------------------------------------------------------------------
   Description:

   Changes the version contained in the tag record for the specified
   objid.
----------------------------------------------------------------------------*/

int som_change_tag_version (
OMuword     osnum,        /*  Object space containing the tagged object.  */
OM_S_OBJID  objid,        /*  Object id of the tagged object.  */
OMuword     version,      /*  New value for version.  */
OMbyte      flag)         /*  0 == use specified version.  1 == increment the
                              old version by one.  */
{
   int       sts;
   OMuword   *p_old_version;

   /*-------------------------------------------------*/
   /*  Get a pointer to where the version is stored.  */
   /*-------------------------------------------------*/

   sts = om$get_tag_data(osnum=osnum,
                         objid=objid,
                         pp_version=&p_old_version);
   if (!(1&sts))
      return (sts);

   if (flag)
      ++(*p_old_version);
   else
      *p_old_version = version;

   return (OM_S_SUCCESS);
}


int som_set_tag_os (OMuword *p_prev_osnum, OMuword osnum)

/*---------------------------------------------------------------------------
   Description:

   Establishes the specified object space as the one which contains tagged
   objects.  When tagging is enabled, any connection to a tagged object in
   the specified object space will be a tagged connection.
---------------------------------------------------------------------------*/

{
   if ((OM_Gw_maxOS < osnum) || (NULL == OM_GA_OSDs[osnum]))
      return (OM_E_NOSUCHOS);

   *p_prev_osnum = OM_Gw_tagged_osnum;
   OM_Gw_tagged_osnum = osnum;

   return (OM_S_SUCCESS);
}


/*----------------------------------------------------------------------------
   Description:

   Translates a tag into an object id.  Optionally, the tag version is
   also returned.
----------------------------------------------------------------------------*/

int som_tag_to_objid (
OMuword     osnum,       /*  Object space that contains the tagged object.  */
OMuint      tag,         /*  Tag that identifies the object.  */
OM_p_OBJID  p_objid,     /*  Pointer to the returned objid.  */
OMuword     *p_version)  /*  Pointer to the returned version.  */
{
   OM_S_MESSAGE         get_record_vla_msg;   /*  Message to access OMTag 
                                                  object. */
   OM_S_GETRECVLA_ARGS  get_record_vla_args;
   OM_p_TAG_RECORD      tag_rec;              /*  Array of tag records.  */
   int                  count;                /*  Number of tag records.  */
   OMuword              flags;                /*  OMTag flag word.  */
   int                  sts;                  /*  OM return status.  */

   /*----------------------------*/   
   /*  Validate the parameters.  */
   /*----------------------------*/

   if ((OM_Gw_maxOS <= osnum) || (NULL == OM_GA_OSDs[osnum]))
      return (OM_E_NOSUCHOS);

   if ( (! OM_GA_tag_oids) || (IF_NULL_OBJID(OM_GA_tag_oids[osnum])) )
      return (OM_E_NOSUCHTAG);

   /*------------------------------------------------*/
   /*  Get access to instance data of OMTag object.  */
   /*------------------------------------------------*/

   get_record_vla_msg.select.DefClassid = OM_K_OMTAG_ACTCLASSID;
   get_record_vla_msg.select.ReqClassid = OM_K_OMTAG_ACTCLASSID;
   get_record_vla_msg.select.FuncIndex  = OMTag_OPP_get_record_vla_method_index;
   get_record_vla_msg.size              = sizeof(OM_S_GETRECVLA_ARGS);
   get_record_vla_msg.p_arglist         = (char *)&get_record_vla_args;

   get_record_vla_args.pp_tag_rec = &tag_rec;
   get_record_vla_args.p_count = (OMuint *) &count;
   get_record_vla_args.p_flags = &flags;

   sts = om$send(msg = &get_record_vla_msg,
                 senderid = NULL_OBJID,
                 targetid = OM_GA_tag_oids[osnum],
                 targetos = osnum );

   if (!(1&sts))
      return (sts);
  
   /*-------------------------------------------------------*/
   /*  Search for the specified tag in the tag record vla.  */
   /*-------------------------------------------------------*/

   if (flags & OM_Tf_tags_unordered)
   {
      /*----------------------*/
      /*  Sequential search.  */
      /*----------------------*/

      int ii;

      for (ii=0; ii < count; ++ii)
         if (! IF_NULL_OBJID(tag_rec[ii].objid) )
            if (tag == tag_rec[ii].tag)
            {
               *p_objid = tag_rec[ii].objid;

               if (p_version)
                  *p_version = tag_rec[ii].version;

               return (OM_S_SUCCESS);
            }
   }
   else
   {
      /*--------------------------------------------------------------*/
      /*  Modified binary search.  Since the array can contain null   */
      /*  entries, the binary search algorithm must search for a      */
      /*  non-null entry before making any comparisons.               */
      /*--------------------------------------------------------------*/

      int  L;    /* Leftmost subscript of list to search */
      int  R;    /* Rightmost subscript of list to search */
      int  M;    /* Middle subcript of list to search */

      for (L=0, R=count-1, M=(R+L)/2; L <= R; M=(R+L)/2)
      {
         int oldM;   /*  Saves original middle subscript.  */
         int back;   /*  Indicates searching backward for a non-null entry.  */

         back = TRUE;
         oldM = M;

         while (IF_NULL_OBJID(tag_rec[M].objid))
         {
            /*--------------------------------*/
            /*  Search for a non-null entry.  */
            /*--------------------------------*/

            if (back)
            {
               /*---------------------------------*/
               /*  Searching backward from oldM.  */
               /*---------------------------------*/

               --M;
               
               if (M < L)
               {
                  /*--------------------------------------------*/
                  /*  All entries before oldM are null.  Start  */
                  /*  searching forward from oldM.              */
                  /*--------------------------------------------*/

                  M = oldM;
                  back = FALSE;
               }
            }
            else
            {
               /*----------------------*/
               /*  Searching forward.  */
               /*----------------------*/

               ++M;
 
               if (M > R)
               {
                  /*---------------------------------*/
                  /*  Never found a non-null entry.  */
                  /*---------------------------------*/

                  return (OM_E_NOSUCHTAG);
               }
            }

         }/*  End of search for non-null entry.  */
                  
         if (tag == tag_rec[M].tag)
         {
            *p_objid = tag_rec[M].objid;

            if (p_version)
               *p_version = tag_rec[M].version;

            return(OM_S_SUCCESS);
         }
         else 
         {
            if (tag < tag_rec[M].tag)
               R = M - 1;
            else
               L = M + 1;            
         }
      }

   }/*  End of modified binary search.  */


   /*--------------*/
   /*  Not found.  */
   /*--------------*/

   return (OM_E_NOSUCHTAG);
}


/*---------------------------------------------------------------------------
   Description:

   This primitive will transfer a tag to a previously untagged object.
   The new object must retain those channel(s) from the old object that
   were used in tagged connections.
--------------------------------------------------------------------------*/

int som_move_tag (
OMuword     osnum,       /*  Object space containing both objects.  */
OM_S_OBJID  old_objid,   /*  Object to be untagged.  */
OM_S_OBJID  new_objid)   /*  Object to be tagged with old objid's tag.  */
{
   OM_S_RIP         old_rip,  /*  Pointer's to both objects.  */ 
                    new_rip;
   OM_S_TAG_RECORD  t_rec;    /*  Struct to hold old objid's tag info.  */
   int              sts;      /*  OM return status.  */

   OM_S_MESSAGE     insert_msg;

   struct OM_sd_insert_tag_args
   {
      OM_S_OBJID      objid;
      OMuint          *p_tag;
      OM_p_TAG_RECORD p_tag_rec;
   } insert_tag_args;


   /*-----------------------*/
   /*  Validate parameters. */
   /*-----------------------*/

   if (!(1&(sts = om$get_any_instance(osnum=osnum,
                                      objid=old_objid,
                                      p_rip=&old_rip))))
      return (OM_E_NOSUCHOBJ);

   if (!(1&(sts = om$get_any_instance(osnum=osnum,
                                      objid=new_objid,
                                      p_rip=&new_rip))))
      return (OM_E_NOSUCHOBJ);

   /*------------------------------------------------------------------*/
   /*  New object should not be tagged.  Old object should be tagged.  */
   /*------------------------------------------------------------------*/
  
   if (OM_OBJ_IS_TAGGED(new_rip.p_object->i_size))
   {
      om$release_instance(rip=new_rip);
      om$release_instance(rip=old_rip);
      return (OM_E_TAGEXISTS);
   }

   if (!(OM_OBJ_IS_TAGGED(old_rip.p_object->i_size)))
   {
      om$release_instance(rip=new_rip);
      om$release_instance(rip=old_rip);
      return (OM_E_NOTTAGGED);
   }

   /*------------------------------------------------------------*/
   /*  Get the old objid's tag record.  The objid field will     */
   /*  temporarily hold the index of the tag record in the vla.  */
   /*------------------------------------------------------------*/

   sts = om$get_tag_data(osnum=osnum,
                         objid=old_objid,
                         p_tag=&t_rec.tag,
                         p_index=(OMuint *) &t_rec.objid,
                         p_version=&t_rec.version);
   if (!(1&sts))
   {
      om$release_instance(rip=new_rip);
      om$release_instance(rip=old_rip);
      return (sts);
   }

   /*--------------------------------------------*/
   /*  Remove the tag record for the old objid.  */
   /*--------------------------------------------*/

   sts = om$remove_tag(osnum=osnum,
                       objid=old_objid);
   if (!(1&sts))
   {
      om$release_instance(rip=new_rip);
      om$release_instance(rip=old_rip);
      return (sts);
   }

   /*--------------------------------------------------------------*/
   /*  Add a tag record into the same index as the old tag record  */
   /*  using the new objid.                                        */
   /*--------------------------------------------------------------*/

   insert_msg.select.DefClassid = OM_K_OMTAG_ACTCLASSID;
   insert_msg.select.ReqClassid = OM_K_OMTAG_ACTCLASSID;
   insert_msg.select.FuncIndex  = OMTag_OPP_insert_tag_method_index;
   insert_msg.size              = sizeof(struct OM_sd_insert_tag_args);
   insert_msg.p_arglist         = (char *)&insert_tag_args;

   insert_tag_args.objid = new_objid;
   insert_tag_args.p_tag = NULL;
   insert_tag_args.p_tag_rec = &t_rec;

   sts = om$send(msg = &insert_msg,
                 senderid = NULL_OBJID,
                 targetid = OM_GA_tag_oids[osnum],
                 targetos = osnum );
   if (!(1&sts))
   {
      om$release_instance(rip=new_rip);
      om$release_instance(rip=old_rip);
      return (sts);
   }

   OM_SET_OBJ_IS_TAGGED(new_rip.p_object->i_size);
   OM_CLEAR_OBJ_IS_TAGGED(old_rip.p_object->i_size);

   om$release_instance(rip=new_rip);
   om$release_instance(rip=old_rip);

   return (OM_S_SUCCESS);
}
