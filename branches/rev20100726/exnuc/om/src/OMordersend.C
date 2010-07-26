/*
---------------------------------------------------------------------------
Routine Name:	som_ordered_send
Abstract:

This routine is called to send to a sequence of objects contained in an 
ordered relation.  The routine assumes that the channel points to a
relation which is ordered; otherwise, it would not have been called.

Sample Invocation:

       som_ordered_send (wrt_flag, msg, senderid, pp_chan_hdr,
                           p_chandef, p_tail, p_chandata, index1, index2)

Entry Variable Description:

OM_E_WRT_FLAG		wrt_flag	wrt message or object
OM_p_MESSAGE		msg		message structure
OM_S_OBJID		senderid	message sender
OM_p_CHANNEL_HDR	*pp_chan_hdr	ptr to ptr to chan hdr
OM_p_CHANNEL_DEFN	p_chandef	channel definition
OM_p_BIG_TAIL    	p_tail		channel tail
int			p_chandata	ptr to channel data
int			index1		starting position for send
int			index2		ending position for send

Exit Variable Description:

function value:		OM_S_SUCCESS
			OM_E_OBJECT_LOCKED
			OM_E_NOSUCHOBJ
			OM_E_STOP_SENDING
			OM_E_INVALIDRANGE

kek001  18-jun-1986	Completely rewritten for 4.0

ems001  23-oct-1986     Fixed a bug which was causing improper termination
                         of the main send loop.

ems002  03-nov-1986     Changed so as not to terminate main send loop on
                         OM_E_NOSUCHCLASS.

ems003  04-nov-1986     Altered range check to allow zero lower index for
                         an empty channel.

ems004  16-feb-1987     Added method cache for send.

geo001  19-feb-1987	If in oden, do not cache send.

geo002	12-may-1987	Add restricted channel handling.

tlr001  22-sep-1987	Add p_chandef, p_tail and p_chandata args and 
			update for new channel definitions

geo003	11-dec-1987	OM4.5 clustering changes to objecthdr & spacemap
---------------------------------------------------------------------------
*/

#include	 "OMobjectcomm.h"
#include	 "OMspecify.h"
#include	 "OMrelation.h"
#include         "OMintprims.h"
#include         "OMmetaclass.h"
#include         "OMsend.h"

extern OMuint OM_Gf_min_caching_send;
extern OMuword Root_OPP_delete_method_index;
extern OMuword Root_OPP_unknown_method_index;
extern int	Root_Root_delete_method();


int som_ordered_send (wrt_flag, msg, senderid, pp_chan_hdr, 
	p_chandef, p_tail, p_chandata, index1, index2)

 OM_E_WRT_FLAG		wrt_flag;
 OM_p_MESSAGE		msg;
 OM_S_OBJID		senderid;
 OM_p_CHANNEL_HDR	*pp_chan_hdr;
 OM_p_CHANNEL_DEFN	p_chandef;
 OM_p_BIG_TAIL   	p_tail;
 int			*p_chandata;
 int			index1;
 int			index2;
 {
  int   		ii, i;
  OMuword               osnum;
  int   		nument;		/* max number of active entries */
  int			sts;		/* Function return status	 */
  int   		send_count;	/* Current number of sends	 */
  int   		send_max;	/* Total number of sends	 */
  OM_p_CHANNEL_HDR	p_chan_hdr;     /* pointer to channel header	*/
  OM_p_CHANNEL_LINK	p_link=NULL;	/* to current channel entry 	*/
  OM_p_CHANNEL_LINK     p_last_link=NULL; /* bailout detector             */
  OM_p_OBJID		p_choid=NULL;	/* to current restricted chan oid */
  OM_p_OBJID            p_last_choid=NULL; /* bailout detector             */
  int			lndx;		/* link index */
  int			up;		/* true if index1 <= index2 */
  int			internal_sts;	/* internal send sts, UNKNOWN MSG */
  int			sts2;		/* do not override I-STOP-SENDING */
  OM_S_CHANNUM		reschannum;	/* restricted channel's channum */

/******  Cache Structure ********/

   OM_S_SEND_CACHE  cache[OM_K_CACHE_SIZE];
   OM_p_SEND_CACHE  p_cache=NULL;

/******  Needed for send macros ******/

   OM_S_RIP		rip;
   OM_p_CLASSDEF	p_ACLD=NULL;
   OMuword		saved_senderOS;
   OMuword              OS2;
   char			set_in_use=FALSE;	/* Did I set send depth? */
   OM_S_CHANNUM         chan2;
   OMuword              flag2;
   OM_S_OBJID           send_objid;

  osnum = OM_Gw_current_OS;

  p_chan_hdr = *pp_chan_hdr;

  if ( p_chan_hdr->flags & OM_CH_absordered ) {
    nument = p_tail->last_index;
  }
  else if (p_chan_hdr->flags & OM_CH_relordered) {
    nument = p_tail->last_index - p_tail->collapse_count;
  }
  else { 
    return(OM_W_NOTORDERED);
  }

  if ( nument == 0 ) return (OM_I_CHAN_EMPTY);

  if (index1 <= index2) { /* going up from index1 to index2 */
    if (index1 < 0) index1 = 0;
    if (index1 > nument) { /* start index must be in range */
       return(OM_E_INVALIDRANGE);
    }
    if (index2 >= nument) {  
      index2 = nument - 1;
    }
    send_max = index2 - index1 + 1;
    up = TRUE;
  }
  else { /* index1 > index2 */  /* going down from index1 to index2 */
    if (index2 < 0) index2 = 0;
    if (index2 > nument) { /* lowest index must be in range */
       return(OM_E_INVALIDRANGE);
    }
    if (index1 >= nument) {  
      index1 = nument - 1;
    }
    send_max = index1 - index2 + 1;
    up = FALSE;
  }
  
  if ( send_max <= 0 ) return (OM_S_SUCCESS);
   
   /*==================================*/
   /*  clear function cache if needed  */
   /*==================================*/

   if( (OMuint) send_max >= OM_Gf_min_caching_send )
   {
      for (i=0;i<OM_K_CACHE_SIZE;i++) cache[i].classid = 0xffff;
   }

/* find first possible link entry */

  if ( !( p_chan_hdr->flags & OM_CH_in_use) )
     {

/*   p_chan_hdr->depth++; */

     set_in_use = TRUE;
     p_chan_hdr->flags |= OM_CH_in_use;
     }

   /*===========================*/
   /* Restricted Channel or Not	*/
   /*===========================*/

  if ( p_chan_hdr->flags & OM_CH_restricted )
  {
    p_choid = (OM_p_OBJID)(p_chandata);
    p_last_choid = p_choid + p_tail->last_index;
  }
  else
  {
    p_link = (OM_p_CHANNEL_LINK)(p_chandata);
    p_last_link = p_link + p_tail->last_index;
  }

  if (p_tail->collapse_count && (p_chan_hdr->flags & OM_CH_relordered)) {
     lndx = 0;
     if ( p_chan_hdr->flags & OM_CH_restricted )
     {
      for (ii=0; ; ) {   /* skip all holes in channel array */
	if ( ! IF_NULL_OBJID(*p_choid)) {
	   ii++;
	   if (ii > index1) {
	      break;
	   }
	}
	p_choid++;
	lndx++;
      }
     }
     else	/* nonrestricted channel */
     {
      for (ii=0; ; ) {   /* skip all holes in channel array */
	if ( ! IF_NULL_OBJID(p_link->objid)) {
	   ii++;
	   if (ii > index1) {
	      break;
	   }
	}
	p_link++;
	lndx++;
      }
     }
  }
  else {	/* not relatively ordered with holes */
     lndx = index1;
     if ( p_chan_hdr->flags & OM_CH_restricted )
     {
	p_choid += lndx;
     }
     else
     {
        p_link += lndx;
     }
  }

/* now loop through entries and send */

  send_count = 0;
  sts = OM_S_SUCCESS;
	/*====================*/
	/* restricted channel */
	/*====================*/
  if ( p_chan_hdr->flags & OM_CH_restricted )
  {
   reschannum = p_chandef->p_type->channum;

   for (;;) {
     if (p_choid >= p_last_choid) break;
     if ( ! IF_NULL_OBJID(*p_choid)) {
         send_count++;
         send_objid = *p_choid;

         /*========================*/
         /*  is caching warrented  */
         /*========================*/
   
         if(((OMuint) send_max < OM_Gf_min_caching_send) ||
             (OM_Gp_CurSpaceMap[send_objid].flags & 
                 (OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt)))
         {
            sts=om$send_obj_int(mode=wrt_flag, msg=msg,
				senderid=senderid, targetid=send_objid,
				channum=reschannum);
         }
         else
         {
            OM_CACHE_SEND(senderid,send_objid,rip,p_cache,cache,p_ACLD,
                          wrt_flag,msg,reschannum,sts,internal_sts,err1);
            if( (1&sts) && (1&internal_sts) )
            {
               if ( rip.p_mapentry->flags & OM_SM_send_depth )
               {
                  OM_PREP_SEND(rip,saved_senderOS);

                  sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry,reschannum, p_ACLD);

                  OM_COMPLETE_SEND(rip,saved_senderOS,send_objid);
               }
               else
               {
		  if(p_cache->p_method != Root_Root_delete_method)
                  {
                      rip.p_mapentry->flags |= OM_SM_send_depth;
                      OM_PREP_SEND(rip,saved_senderOS);

                      sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry,reschannum, p_ACLD);

                      OM_COMPLETE_SEND_ROOTDEL(rip,p_ACLD,saved_senderOS,senderid,
                             send_objid,reschannum,sts);
                  }
                  else
                  {
                      OMuword my_sdi;
                      my_sdi = rip.p_mapentry->sdi;
                      OM_PREP_SEND(rip,saved_senderOS);

                      sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry,reschannum, p_ACLD);

                      OM_Gw_senders_OS = saved_senderOS;
                      OM_GA_CSDarray[my_sdi].PostSendDepth++;
                  }
               }
               om$release_instance(rip=rip);
	    }
         }

         if ( OM_Gw_current_OS != osnum )
         {
            om$make_current_os(osnum=osnum);
         }

       if((sts==OM_I_STOP_SENDING) || ((!(1&sts)) && (sts&SEV_LEV)) &&
          (sts != OM_E_NOSUCHCLASS)){
	 break;
       }
     }
     else if (p_chan_hdr->flags & OM_CH_absordered) {
       send_count++;
     }
     if (send_count >= send_max) {
       break;
     }
     if ( up ) {
       if (lndx++ >= (int) p_tail->last_index) {
 	 break;
       }
     }
     else { /* ! up */
       if (lndx-- < 0) {
	 break;
       }
     }
     if ( p_chan_hdr != *pp_chan_hdr )	/* Channel Moved */
     {
   	p_chan_hdr = *pp_chan_hdr;
        if (p_chan_hdr->flags & OM_CH_bigchan)
           p_choid = (OM_p_OBJID)((OMuint)p_chan_hdr + sizeof(OM_S_BIG_TAIL) +
                                 sizeof(OM_S_CHANNEL_HDR));
        else
           p_choid = (OM_p_OBJID)((OMuint)p_chan_hdr + 
                                 sizeof(OM_S_CHANNEL_HDR));
        p_last_choid = p_choid + p_tail->last_index;
     }
     p_choid = OM_PTR_TO_RESCHAN_LINK(p_chan_hdr) + lndx;
   }
  }
	/*=======================*/
	/* nonrestricted channel */
	/*=======================*/
  else
  {
   for (;;) {
     if (p_link >= p_last_link) break;
     if ( ! IF_NULL_OBJID(p_link->objid)) {
         send_count++;
         if (p_link->hdr.flags & OM_CL_to_object) 
         {
            send_objid = p_link->objid;
            chan2 = p_link->channum;
            chan2.classid = OM_GA_filed_to_active[chan2.classid];
         }
         else  /* to iso */
         {
            sts = som_ISO_fetch (osnum,p_link->hdr.u1.isoindex, p_link->objid,
				 &OS2, &send_objid,
                                 &chan2, &flag2);
            if (sts == OM_W_OSNOTACTIVE ||
                sts == OM_I_LOGICAL_DISCONNECT) goto next_link;
            if (!(1&sts)) return(sts);

            saved_senderOS = OM_Gw_senders_OS;
            om$make_current_os(osnum=OS2);
            OM_Gw_senders_OS = saved_senderOS;
         }

         /*========================*/
         /*  is caching warrented  */
         /*========================*/
   
         if(((OMuint) send_max < OM_Gf_min_caching_send) ||
             (OM_Gp_CurSpaceMap[send_objid].flags & 
                 (OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt)))
         {
            sts=om$send_obj_int(mode=wrt_flag, msg=msg,
				senderid=senderid, targetid=send_objid,
				channum=chan2);
         }
         else
         {
            OM_CACHE_SEND(senderid,send_objid,rip,p_cache,cache,p_ACLD,
                         wrt_flag,msg,chan2,sts,internal_sts,err2);
            if( (1&sts) && (1&internal_sts) )
            {
               if ( rip.p_mapentry->flags & OM_SM_send_depth )
               {
                  OM_PREP_SEND(rip,saved_senderOS);

                  sts = p_cache->p_method (msg, saved_senderOS, senderid,
                          send_objid,rip.p_mapentry,chan2, p_ACLD);

                  OM_COMPLETE_SEND(rip,saved_senderOS,send_objid);
               }
               else
               {
		  if(p_cache->p_method != Root_Root_delete_method)
		  {
                     rip.p_mapentry->flags |= OM_SM_send_depth;
                     OM_PREP_SEND(rip,saved_senderOS);

                     sts = p_cache->p_method (msg, saved_senderOS, senderid,
                          send_objid,rip.p_mapentry,chan2, p_ACLD);

                     OM_COMPLETE_SEND_ROOTDEL(rip,p_ACLD,saved_senderOS,senderid,
                                   send_objid,chan2,sts);
                  }
                  else
		  {
		     OMuword my_sdi;
		     my_sdi = rip.p_mapentry->sdi;
                     OM_PREP_SEND(rip,saved_senderOS);

                     sts = p_cache->p_method (msg, saved_senderOS, senderid,
                          send_objid,rip.p_mapentry,chan2, p_ACLD);

                     OM_Gw_senders_OS = saved_senderOS;
                     OM_GA_CSDarray[my_sdi].PostSendDepth++;
                  }
               }
               om$release_instance(rip=rip);
	    }
         }

         if ( OM_Gw_current_OS != osnum )
         {
            om$make_current_os(osnum=osnum);
         }

       if((sts==OM_I_STOP_SENDING) || ((!(1&sts)) && (sts&SEV_LEV)) &&
          (sts != OM_E_NOSUCHCLASS)){
	 break;
       }
     }
     else if (p_chan_hdr->flags & OM_CH_absordered) {
       send_count++;
     }
next_link:
     if (send_count >= send_max) {
       break;
     }
     if ( up ) {
       if (lndx++ >= (int) p_tail->last_index) {
 	 break;
       }
     }
     else { /* ! up */
       if (lndx-- < 0) {
	 break;
       }
     }
     if ( p_chan_hdr != *pp_chan_hdr ) 	/* Channel Moved */
     {
	p_chan_hdr = *pp_chan_hdr;
        if (p_chan_hdr->flags & OM_CH_bigchan)
           p_link = (OM_p_CHANNEL_LINK)((OMuint)p_chan_hdr + 
                      sizeof(OM_S_BIG_TAIL) + sizeof(OM_S_CHANNEL_HDR));
        else
           p_link = (OM_p_CHANNEL_LINK)((OMuint)p_chan_hdr + 
                                 sizeof(OM_S_CHANNEL_HDR));
        p_last_link = p_link + p_tail->last_index;
     }
     p_link = OM_PTR_TO_CHAN_LINK(p_chan_hdr) + lndx;
   }
  }

  if (  set_in_use ) 
    {
    p_chan_hdr = *pp_chan_hdr;  /* in case it moved */
    p_chan_hdr->flags &= (~OM_CH_in_use);
    OM_GET_TAIL(p_chan_hdr,*p_tail);
    if ( p_chan_hdr->flags & OM_CH_bigchan )
      p_chandata = (int *)((OMuint)p_chan_hdr + sizeof(OM_S_CHANNEL_HDR) + 
                          sizeof(OM_S_BIG_TAIL));
    else
      p_chandata = (int *)((OMuint)p_chan_hdr + sizeof(OM_S_CHANNEL_HDR));

    if(!(1&(sts2 = om$collapse_channel(osnum=osnum, objid=senderid, 
	              pp_chan=pp_chan_hdr, chdef=p_chandef, 
		      p_chandata=p_chandata, p_tail=p_tail) )))
        sts = sts2;
    }
  return (sts);
 }
