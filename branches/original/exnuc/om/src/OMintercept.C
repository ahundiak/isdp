/*
---------------------------------------------------------------------------
	Name:			OMintercept.C
	Author:			Grace Oliver
	Creation Date:		Apr-14-1987
	Operating System(s):	Unix SYSV, v3
	Abstract:

		som_set_intercept
		som_cancel_intercept
		som_get_intercept

---------------------------------------------------------------------------
*/

#include	"OMobjectcomm.h"
#include	"OMintercept.h"
#include	"OMspecify.h"
#include	"OMrelation.h"
#include	"OMintprims.h"

extern OM_p_INTRCPT_HT	OM_GA_IntrcptHshTbl;


/*
------------- Revision History ------------------------------------------------

geo001	14-apr-1987	Implement for OM4.1 and 4.2


------------- Function Description --------------------------------------------

This primitive is used to force all messages directed to one object to be
sent to another object.

-------------------------------------------------------------------------------
*/                                                                  

int som_set_intercept( OMuword osnum, OM_S_OBJID objid, OMuword target_osnum,
                       OM_S_OBJID target_objid)
{
   int                  sts,i,hash_func_index, found_index;
   OM_p_MSG_INTRCPT	hashtable, newhashtable;

   /*================================*/
   /* Check Validate objid & osnum   */
   /*================================*/

   if (!(1&(sts = om$is_objid_valid(objid=objid, osnum=osnum))))
   {
      return (sts);
   }
   /*===================================================*/
   /* Check to see if osnum/objid already has intercept */
   /*===================================================*/

   if(OM_GA_OSDs[osnum]->Spacemap[objid].flags & OM_SM_has_msgintrcpt)
   {
	return(OM_E_INTERCEPTED);
   }

   /*=============================================*/
   /* If 1st intercept set, initialize hash table */
   /*=============================================*/

   if (! OM_GA_IntrcptHshTbl )
   {
     if(! (OM_GA_IntrcptHshTbl = om$calloc(num=OM_Gw_maxOS,
			structure = OM_S_INTRCPT_HT)))
     {
	return(OM_E_NODYNMEM);
     }
   }
   if (! (OM_GA_IntrcptHshTbl[osnum].hash_table) )
   {
     if(! (hashtable = OM_GA_IntrcptHshTbl[osnum].hash_table =
			om$calloc(num=OM_K_MSGINTR_HSHTBL_INITSIZE,
			structure = OM_S_MSG_INTRCPT)))
     {
	return(OM_E_NODYNMEM);
     }
     OM_GA_IntrcptHshTbl[osnum].cur_size = OM_K_MSGINTR_HSHTBL_INITSIZE;
     OM_GA_IntrcptHshTbl[osnum].next_free = OM_K_MSGINTR_HSHTBL_SIZE;
	/* num_entries is zero from calloc */

     /*=====================================================*/
     /* Link Up Overflow Entries so point to next free.     */
     /* The last overflow entries' next is zero from calloc */
     /* Initialize objid's to NULLOBJID to note unused slot */
     /*=====================================================*/
   
     for(i=OM_K_MSGINTR_HSHTBL_SIZE; i<OM_K_MSGINTR_HSHTBL_INITSIZE-1; i++)
     {
       hashtable[i].next = i+1;
     }
     for(i=0; i<OM_K_MSGINTR_HSHTBL_SIZE; i++)
     {
       hashtable[i].intercept_objid = NULL_OBJID;
     }
   }
   /* Otherwise hashtable already exists */
   else
   {
      hashtable = OM_GA_IntrcptHshTbl[osnum].hash_table;
   }
   /*============================================*/
   /* Add intercept record to osnum's hash table */
   /*============================================*/

   OM_MSGINTR_HSHFUNC(objid, hash_func_index)
   if(IF_NULL_OBJID(hashtable[hash_func_index].intercept_objid))
	found_index = hash_func_index;
   else
   {
      /* find last link of hash_func_index in overflow area */
     while(hashtable[hash_func_index].next)
	hash_func_index = hashtable[hash_func_index].next;
     if(OM_GA_IntrcptHshTbl[osnum].next_free)
     {
      found_index = hashtable[hash_func_index].next =
	OM_GA_IntrcptHshTbl[osnum].next_free;
      OM_GA_IntrcptHshTbl[osnum].next_free = hashtable[found_index].next;
     }
     else	/* overflow area used up; extend it; realloc region */
     {		/* initialize new overflow area                     */
      if(!(newhashtable=(OM_p_MSG_INTRCPT)om$realloc(ptr=(char *) hashtable,
	size=(OM_GA_IntrcptHshTbl[osnum].cur_size +
	OM_K_MSGINTR_HSHTBL_EXTSIZE) * sizeof(OM_S_MSG_INTRCPT))))
      {
	return(OM_E_NODYNMEM);
      }
      hashtable = OM_GA_IntrcptHshTbl[osnum].hash_table = newhashtable;
      found_index = hashtable[hash_func_index].next = OM_GA_IntrcptHshTbl[osnum].cur_size;
      OM_GA_IntrcptHshTbl[osnum].next_free = OM_GA_IntrcptHshTbl[osnum].cur_size+1;
      for(i=OM_GA_IntrcptHshTbl[osnum].cur_size+1;
	  i<OM_GA_IntrcptHshTbl[osnum].cur_size+OM_K_MSGINTR_HSHTBL_EXTSIZE-1;
	  i++)
      {
        hashtable[i].next = i+1;
      }
      OM_GA_IntrcptHshTbl[osnum].cur_size += OM_K_MSGINTR_HSHTBL_EXTSIZE;
      hashtable[OM_GA_IntrcptHshTbl[osnum].cur_size-1].next = NULL;
     }
   }
   /*=============*/
   /* found slot  */
   /*=============*/
   OM_GA_IntrcptHshTbl[osnum].num_entries++;
   hashtable[found_index].intercept_objid = objid;
   hashtable[found_index].to_osnum = target_osnum;
   hashtable[found_index].to_objid = target_objid;
   hashtable[found_index].next = NULL;
   /*=======================*/
   /* Set has_intercept bit */
   /*=======================*/
   OM_GA_OSDs[osnum]->Spacemap[objid].flags |= OM_SM_has_msgintrcpt;
   return ( OM_S_SUCCESS );
}


/*
------------- Revision History ------------------------------------------

geo001	14-apr-1987	Implement for OM4.1 and 4.2

------------- Function Description --------------------------------------

This primitive is used to cancel message interception.

--------------------------------------------------------------------------
*/

int som_cancel_intercept (OMuword osnum, OM_S_OBJID objid)
{
   int              	sts, hash_func_index,
			temp_func_index, prev_func_index=NULL;
   OM_p_MSG_INTRCPT	hashtable;

   /*================================*/
   /* Check Validate objid & osnum   */
   /*================================*/

   if (!(1&(sts = om$is_objid_valid(objid=objid, osnum=osnum))))
   {
      return (sts);
   }
   /*===============================================================*/
   /* Check whether hashtable exists and has_msgintrcpt bit setting */
   /*===============================================================*/

   if( (! OM_GA_IntrcptHshTbl) ||
       (! (hashtable = OM_GA_IntrcptHshTbl[osnum].hash_table)) ||
       (! (OM_GA_OSDs[osnum]->Spacemap[objid].flags & OM_SM_has_msgintrcpt)))
   {
      return(OM_W_NOINTERCEPT);
   }
   /*=================================================*/
   /* Delete intercept record from osnum's hash table */
   /* First find osnum/objid's entry in hash table    */
   /*=================================================*/

   OM_MSGINTR_HSHFUNC(objid, hash_func_index)
   if(IF_NULL_OBJID(hashtable[hash_func_index].intercept_objid))
   {
      return(OM_W_NOINTERCEPT);
   }
   while(hashtable[hash_func_index].intercept_objid != objid)
   {
      if(hashtable[hash_func_index].next)
      {
	prev_func_index = hash_func_index;
	hash_func_index = hashtable[hash_func_index].next;
      }
      else
        return(OM_W_NOINTERCEPT);
   }
   /*====================================================*/
   /* 3 cases: hash_func_index within original hashtable */
   /*               has next or no next		         */
   /*          hash_func_index within overflow area      */
   /*====================================================*/
   if(hash_func_index >= OM_K_MSGINTR_HSHTBL_SIZE)  /* OVERFLOW AREA */
   {
     hashtable[prev_func_index].next = hashtable[hash_func_index].next;
     hashtable[hash_func_index].next = OM_GA_IntrcptHshTbl[osnum].next_free;
     OM_GA_IntrcptHshTbl[osnum].next_free = hash_func_index;
   }
   else		/* WITHIN ORIGINAL HASHTABLE AREA */
   {
     if(temp_func_index=hashtable[hash_func_index].next) /* has next link */
     {
	OM_BLOCK_MOVE(&hashtable[temp_func_index],
		&hashtable[hash_func_index],sizeof(OM_S_MSG_INTRCPT));
	hashtable[temp_func_index].next = OM_GA_IntrcptHshTbl[osnum].next_free;
	OM_GA_IntrcptHshTbl[osnum].next_free = temp_func_index;
     }
     else				/* no next; end of linked list */
     {
	hashtable[hash_func_index].intercept_objid = NULL_OBJID;
     }
   }
   OM_GA_IntrcptHshTbl[osnum].num_entries--;
   
   /*====================================*/
   /* If last intercept, free hash table */
   /*====================================*/

   if(! OM_GA_IntrcptHshTbl[osnum].num_entries)
   {
     int	i, found=0;

	om$dealloc(ptr=(char *) hashtable);
        OM_GA_IntrcptHshTbl[osnum].hash_table = NULL;
        OM_GA_IntrcptHshTbl[osnum].cur_size = 0;
        OM_GA_IntrcptHshTbl[osnum].num_entries = 0;
        OM_GA_IntrcptHshTbl[osnum].next_free = NULL;
	for(i=0; (OMuword) i<OM_Gw_maxOS; i++) /* Any hashtables still exist? */
        {
	  if(OM_GA_IntrcptHshTbl[i].hash_table)
	  {
		found = TRUE;
		break;
	  }
        }
        if(! found)
        {
	  om$dealloc(ptr=(char *) OM_GA_IntrcptHshTbl);
          OM_GA_IntrcptHshTbl=NULL;
	}
   }
   /*=========================*/
   /* Clear has_intercept bit */
   /*=========================*/
   OM_GA_OSDs[osnum]->Spacemap[objid].flags &= ~(OMbyte)OM_SM_has_msgintrcpt;
   return(OM_S_SUCCESS);
}


/*
------------- Revision History ------------------------------------------------

geo001	14-apr-1987	Implement for OM4.1 and 4.2

------------- Function Description --------------------------------------------

This primitive is used to retrieve the object space number and object id
of the object that is receiving all messages for the specified object.

-------------------------------------------------------------------------------
*/

int som_get_intercept (OMuword osnum, OM_S_OBJID objid,
                       OMuword *p_target_osnum, OM_p_OBJID p_target_objid)
{ 
   int               sts, hash_func_index;
   OM_p_MSG_INTRCPT  hashtable;

   /*================================*/
   /* Check Validate objid & osnum   */
   /*================================*/

   if (!(1&(sts = om$is_objid_valid(objid=objid, osnum=osnum))))
   {
      return (sts);
   }
   /*===============================================================*/
   /* Check whether hashtable exists and has_msgintrcpt bit setting */
   /*===============================================================*/

   if( (! OM_GA_IntrcptHshTbl) ||
       (! (hashtable = OM_GA_IntrcptHshTbl[osnum].hash_table)) ||
       (! (OM_GA_OSDs[osnum]->Spacemap[objid].flags & OM_SM_has_msgintrcpt)))
   {
      return(OM_W_NOINTERCEPT);
   }
   /*==================================================*/
   /* Return intercept targets from osnum's hash table */
   /*==================================================*/

   OM_MSGINTR_HSHFUNC(objid, hash_func_index)
   if(IF_NULL_OBJID(hashtable[hash_func_index].intercept_objid))
   {
      return(OM_W_NOINTERCEPT);
   }
   while(hashtable[hash_func_index].intercept_objid != objid)
   {
      if(hashtable[hash_func_index].next)
	hash_func_index = hashtable[hash_func_index].next;
      else
	return(OM_W_NOINTERCEPT);
   }
   *p_target_osnum = hashtable[hash_func_index].to_osnum;
   *p_target_objid = hashtable[hash_func_index].to_objid;
   return(OM_S_SUCCESS);
}

/*
------------- Revision History ------------------------------------------------

sss001	20-jul-1988	Implement for OM4.5 (cls_k)

------------- Function Description --------------------------------------------

This primitive is used to disable the message intercption mechanism.

-------------------------------------------------------------------------------
*/

int som_disable_intercept (OMuword osnum, OM_S_OBJID objid)
{
   int               sts;


   /*================================*/
   /*     Validate objid & osnum     */
   /*================================*/

   if (!(1&(sts = om$is_objid_valid(objid=objid, osnum=osnum))))
   {
      return (sts);
   }
   /*===============================================================*/
   /* Check whether hashtable exists and has_msgintrcpt bit setting */
   /*===============================================================*/

   if( (! OM_GA_IntrcptHshTbl) ||
       (! OM_GA_IntrcptHshTbl[osnum].hash_table) ||
       (! (OM_GA_OSDs[osnum]->Spacemap[objid].flags & OM_SM_has_msgintrcpt)))
   {
      return(OM_W_NOINTERCEPT);
   }
 
   /*=========================*/
   /* Set disable_intrcpt bit */
   /*=========================*/
   OM_GA_OSDs[osnum]->Spacemap[objid].flags |= OM_SM_disable_intrcpt;
   return(OM_S_SUCCESS);
}
