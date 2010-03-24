/*
---------------------------------------------------------------------------
	Name:			OMsend.c
	Author:			Chuck Puckett
	Creation Date:		Aug-5-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

		som_send_object
		som_send_channel
                som_send_foreign

	Revision History:

cgp001	31-oct-1985	made all ODIN calls defined dependent

cgp002	15-nov-1985	Major OS mods.

jhm001  19-nov-1985	Modified arg list for collapse_relation to pass
			objid by value.

cgp003	19-nov-1985	Major Mod: change invocation syntax for (all sends
			to specify "wrt object" or "wrt message" via flag.

jhm002  20-nov-1985     Not exiting send loop on error return from method.

cgp004	4-dec-1985	fix bug in send_channel ("&" vs. "<=" precedence).
			Also,  add send_foreign.

ems001  3-feb-1986      Corrected collapse logic in channel send.

kek001	23-mar-1986	remove minor channel references

gja001	17-apr-1986	Added modifications for ISO's

ems002  02-jul-1986     4.0 modifications

tlr001  22-sep-1987 	4.4 channel modifications

---------------------------------------------------------------------------
*/

#include	"OMobjectcomm.h"
#include	"OMspecify.h"
#include	"OMrelation.h"
#include        "OMintprims.h"
#include        "OMmetaclass.h"
#include        "OMsend.h"

extern int	Root_Root_delete_method();

#ifdef DEBUG
int OM_Gd_send = 0;		/* debug variable for send */
#endif

#ifdef VALSPMAP

void OM_validate_spacemap();

/* Fabricate OMOSCO add class message */

OM_S_METHSELECT OMOSCO_add_class_msgsel = {OM_K_OMOSCO_ACTCLASSID,
				           OM_K_OMOSCO_ACTCLASSID,
				           2};
OMbyte	OM_in_construct_os = FALSE;		/* do not validate
if true */

#endif

extern OMuword  Root_OPP_delete_method_index;
extern OMuword  Root_OPP_unknown_method_index;

extern OMuint   OM_Gf_min_caching_send;


/*
------------- Function Description --------------------------------------------

  Function name:    som_send_object ( wrt_flag, msg, senderid,
                                      targetid, channum )

  Input arguments:  
                    OM_E_WRT_FLAG    wrt_flag    How message is the be sent
                    OM_p_MESSAGE     msg         Message to be sent
                    OM_S_OBJID       senderid    Object id of sender
                    OM_S_OBJID       targetid    Object id of target
                    OM_S_CHANNUM     channum     Channel that the message is
                                                  being sent on.  Valid for
                                                  channel sends only.
  Output arguments: None.

  Sends a message from "senderid" directly to "objid". The instance data is
  made valid and software locked. The message is validated against legal
  methods. If these checks pass, then the method is invoked. The method
  invoked is dependent on the mode in which the message is being sent.

------------- Revision History ------------------------------------------------

cgp001	15-nov-1985	Massive change for OS. Don't check for NULL objid.
			put in deferred delete processing. Varlength array
			fixups.

cgp002	19-nov-1985	Use wrt flag.

cgp003	20-nov-1985	Fix unknown message delivery.

gja001	17-apr-1986	OM_Gw_current_OS was replaced by OM_Gw_senders_OS as
			the senders Object Space.  Removed test for ISO, for
			that is done prior to this call.

cgp004	20-apr-1986	OM3.2; new delete semantics. Defer Root.delete, WRT_msg

gja002	22-may-1986	With the possibility of  nested sends OM_Gw_senders_OS
			is saved and reset to  the  current OS  (if the target
			object sends  a  message the current OS is the senders 
			OS).  The saved OS is then submitted to the determined
			method and  assigned  back  to  OM_Gw_senders_OS  upon
			return.       ***> I SEND THEREFORE I AM <***.

ems001  02-jul-1986     4.0 modifications

ems002  03-nov-1986     Changed error exit from OM_E_NOSUCHOBJ to 
                        OM_E_NOSUCHCLASS if class is not active.

-------------------------------------------------------------------------------
*/

int som_send_object ( wrt_flag, msg, senderid, targetid, channum )

OM_E_WRT_FLAG   wrt_flag;
OM_p_MESSAGE    msg;
OM_S_OBJID      senderid;
OM_S_OBJID      targetid;
OM_S_CHANNUM    channum;

{
   int                  sts,internal_sts;
   OM_S_RIP             rip;
   OM_p_CLASSDEF        p_ACLD=NULL;
   OM_p_FUNCPTR         f=NULL;
   OMuword              saved_senderOS;

#ifdef DEBUG
{
/* display the name of the message being sent in the form classname.message */
struct OM_sd_methdefn	*p_meth;
int i,j;
OM_p_CLASSDEF p_acld;
p_acld = OM_GA_active_classes[msg->select.DefClassid];
j = p_acld->w_nummethods - msg->select.FuncIndex - 1;
for(p_meth = p_acld->p_methdefns,i=0; i<j; i++,p_meth = p_meth->next) ;
if(OM_Gd_send)printf("SEND --Sending message %s.%s  \n",
p_acld->s_name, p_meth->s_name); }
#endif

   OM_GET_FUNCTION_PTR(f,rip,p_ACLD,wrt_flag,msg,senderid,targetid,channum,sts,internal_sts,err1)
   if( (!(1&sts)) || (!(1&internal_sts)) )
   {
     return(sts);
   }

   if ( rip.p_mapentry->flags & OM_SM_send_depth ) {
     OM_PREP_SEND(rip,saved_senderOS);

#ifdef VALSPMAP
     OM_validate_spacemap(msg->select, targetid, 0);
#endif

     sts = f ( msg, saved_senderOS, senderid, targetid, rip.p_mapentry,
                channum, p_ACLD );

#ifdef VALSPMAP
     OM_validate_spacemap(msg->select, targetid, 1);
#endif
 
     OM_COMPLETE_SEND(rip,saved_senderOS,targetid);
   }
   else {
     if( f != Root_Root_delete_method )
     {
       rip.p_mapentry->flags |= OM_SM_send_depth;
       OM_PREP_SEND(rip,saved_senderOS);

#ifdef VALSPMAP
       OM_validate_spacemap(msg->select, targetid, 0);
#endif

       sts = f ( msg, saved_senderOS, senderid, targetid, rip.p_mapentry,
                channum, p_ACLD );

#ifdef VALSPMAP
       OM_validate_spacemap(msg->select, targetid, 1);
#endif
 
       OM_COMPLETE_SEND_ROOTDEL(rip,p_ACLD,saved_senderOS,senderid,targetid,channum,sts);
     }
     else   /* root.delete */
     {
       OMuword my_sdi;

       my_sdi = rip.p_mapentry->sdi;
       OM_PREP_SEND(rip,saved_senderOS);

#ifdef VALSPMAP
       OM_validate_spacemap(msg->select, targetid, 0);
#endif

       sts = f ( msg, saved_senderOS, senderid, targetid, rip.p_mapentry,
                channum, p_ACLD );

#ifdef VALSPMAP
       OM_validate_spacemap(msg->select, targetid, 1);
#endif
       OM_Gw_senders_OS = saved_senderOS;
       OM_GA_CSDarray[my_sdi].PostSendDepth++;
    }
  }

   return ( sts );
}


/*
------------- Function Description --------------------------------------------

  Function name:    som_send_channel ( wrt_flag, msg, osnum,
                                       senderid, p_chansel, from, to )
 
  Input arguments:
                    OM_E_WRT_FLAG   wrt_flag  How message is to be sent
                    OM_p_MESSAGE    msg       Message to be sent          
                    OMuword         osnum     OS number of senderid
                    OM_S_OBJID      senderid  Object id of sender
                    OM_p_CHANSELECT p_chansel Pointer to channel selector for
                                               sender's channel
                    int             from      Starting index for ordered send
                    int             to        Ending index for ordered send

  Output arguments: None.
   
  This function will send a message to each object on a given channel of
  a given object.  If there are no objects on the specified channel then
  the function will return OM_E_CHAN_EMPTY.  If an error occurs during
  one of the sends,  then the channel send will be aborted at that point
  and the function will return the error message that was returned by the
  method in which the error occurred.  Note that an unknown message will
  not result in the termination of the channel send.

------------- Revision History ------------------------------------------------

ems    23-oct-1986   Fixed a bug which caused improper termination of the
                      main send loop.

ems    03-nov-1986   Altered termination code for main send loop so as
                      not to stop on OM_E_NOSUCHCLASS.

geo    12-may-1987   Added restricted channel handling

jkm    07-jul-1987   fixed bug in channel send due to moving channel. p_link
		     needs to be recomputed every time.

tlr    22-sep-1987   4.4 channel changes

ems    05-apr-1989   Make sure in_chan contains active classid.

-------------------------------------------------------------------------------
*/

int som_send_channel (
OM_E_WRT_FLAG			WRT_flag,
OM_p_MESSAGE			msg,
OMuword                         osnum,
OM_S_OBJID			senderid,
OM_p_CHANSELECT			p_chansel,  
int				from,
int				to)

{
   int   		set_senders_depth;
   OMuint	        nument, i, ii;
   int  		sts, sts2,internal_sts;
   OM_p_CHANNEL_LINK    p_link=NULL;
   OM_p_OBJID		p_choid=NULL;
   OM_p_CHANNEL_DEFN    p_chandef;
   OM_S_CHANNUM		reschannum;
   OM_p_CHANNEL_HDR     *pp_chan_hdr, p_chan_hdr;
   OMuword              saved_osnum;
   OM_S_OBJID           send_objid;
   OMuword              OS2;
   OMuword              flag2;
   OM_S_CHANNUM         chan2;
   OM_S_RIP		rip2;	
   int                  res1chan=0;
   OMuword              def_flags;

/******  Cache Structure ********/

   OM_S_SEND_CACHE  cache[OM_K_CACHE_SIZE];
   OM_p_SEND_CACHE  p_cache=NULL;

/******  Needed for send macros ******/

   OM_S_RIP		rip;
   OM_p_CLASSDEF	p_ACLD=NULL;
   OMuword		saved_senderOS;
   int			*p_chandata;
   OM_S_BIG_TAIL	tail;
   char			set_in_use=FALSE;

   /*==============================*/
   /*  check if OS is not current  */
   /*==============================*/

   if ( osnum != OM_Gw_current_OS )
   {
      if ((OM_Gw_maxOS < osnum) || (!OM_GA_OSDs[osnum]))
      {
         return (OM_E_NOSUCHOS);
      }
      saved_osnum = OM_Gw_current_OS;
      om$make_current_os (osnum=osnum);
   }
   else
   {  
      saved_osnum = OM_Gw_current_OS;
   }

   /*===================================================*/
   /*  get a pointer to the channel via om$get_channel  */
   /*===================================================*/

   if (!(1&(sts = om$get_channel ( objid=senderid, p_chanselect=p_chansel,
           pp_channel=&pp_chan_hdr, pp_chandef=&p_chandef,
           pp_chandata=&p_chandata, p_tail=&tail ))))
   {
      if ( saved_osnum != OM_Gw_current_OS )
      {
         om$make_current_os (osnum=saved_osnum);
      }
      return (sts);
   }

   p_chan_hdr = *pp_chan_hdr;

   if ((p_chan_hdr == NULL) || (tail.last_index-tail.collapse_count == 0))
   {
      if ( saved_osnum != OM_Gw_current_OS )
      {
         om$make_current_os (osnum=saved_osnum);
      }
      return( OM_I_CHAN_EMPTY);
   }

   /*==================================================================*/
   /* Get the instance. we must increment the sender's send depth here */
   /*==================================================================*/

   if (!(1&(sts = om$get_instance(objid=senderid,p_rip=&rip2))))
   {
      if ( saved_osnum != OM_Gw_current_OS )
      {
         om$make_current_os (osnum=saved_osnum);
      }
      return(sts);
   }

   if (rip2.p_mapentry->flags & OM_SM_send_depth)
   {
      set_senders_depth = 0;
   }
   else 
   {
      set_senders_depth = 1;
      rip2.p_mapentry->flags |= OM_SM_send_depth;
   }
   OM_GA_CSDarray[rip2.p_mapentry->sdi].PreSendDepth++;

   /*================================*/
   /*  check for an ordered channel  */
   /*================================*/

   def_flags = p_chandef->p_type->w_flags;

   if (def_flags & (CD_absordered | CD_relordered)) 
   {  
      sts = om$ordered_send( mode=WRT_flag, msg=msg, senderid=senderid, 
              pp_chan_hdr=pp_chan_hdr, p_chandef=p_chandef, p_tail=&tail,
 	      p_chandata=p_chandata, from=from, to=to );
      goto cleanup;
   }

   /*============================*/
   /*  check for singleton case  */
   /*============================*/

   nument = tail.last_index;

   if (def_flags & CD_restricted)
   {
        if ( def_flags & (CD_1_1|CD_m_1)) res1chan = 1;
	p_choid = (OM_p_OBJID)(p_chandata);
   }
   else
   {
        p_link = (OM_p_CHANNEL_LINK)(p_chandata);
   }

   if ( !res1chan && (!(p_chan_hdr->flags & OM_CH_in_use)))
   {
      set_in_use = TRUE;
      p_chan_hdr->flags |= OM_CH_in_use;
   }

   /*==================================*/
   /*  clear function cache if needed  */
   /*==================================*/

   if ( nument >= OM_Gf_min_caching_send )
   {
      for (i=0;i<OM_K_CACHE_SIZE;i++) cache[i].classid = 0xffff;
   }

   /*==============================*/
   /*  main loop for channel send  */
   /*  Restricted Channels         */
   /*==============================*/

  if (def_flags & CD_restricted)
  {
   reschannum = p_chandef->p_type->channum;
   for (ii=0; ii < nument; ii++, p_choid++)
   {
      
      /*===================================================================*/
      /* point to the first oid. Do this each time because the channel may */
      /* have moved 							   */
      /* do only if the channel is not a singleton, if it is a singleton,  */
      /* we don't need to worry about resetting the link. 		   */
      /*===================================================================*/

      if ( p_chan_hdr != *pp_chan_hdr )   /* must have moved */
      {
           p_chan_hdr = *pp_chan_hdr;
           p_choid = OM_PTR_TO_RESCHAN_LINK(p_chan_hdr);
	   p_choid += ii;		/* point to the correct oid */
      }

      if ( ! (IF_NULL_OBJID(*p_choid))) 
      {
         if (res1chan) 
            send_objid = *p_choid >> 1;
         else
            send_objid = *p_choid;

         /*========================*/
         /*  is caching warrented  */
         /*========================*/
   
         if((nument < OM_Gf_min_caching_send) ||
             (OM_Gp_CurSpaceMap[send_objid].flags & 
                    (OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt)))
         {
            sts=om$send_obj_int(mode=WRT_flag, msg=msg,
			senderid=senderid, targetid=send_objid,
			channum=reschannum);
         }
         else
         {
            OM_CACHE_SEND(senderid,send_objid,rip,p_cache,cache,p_ACLD,
                        WRT_flag,msg,reschannum,sts,internal_sts,err2);
            if( (1&sts) && (1&internal_sts) )
    	    {
               if ( rip.p_mapentry->flags & OM_SM_send_depth )
               {
                  OM_PREP_SEND(rip,saved_senderOS);

                  sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry, reschannum, p_ACLD);

                  OM_COMPLETE_SEND(rip,saved_senderOS,send_objid);
               }
               else
               {
                  if(p_cache->p_method != Root_Root_delete_method)
                  {
                     rip.p_mapentry->flags |= OM_SM_send_depth;
                     OM_PREP_SEND(rip,saved_senderOS);

                     sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry, reschannum, p_ACLD);

                     OM_COMPLETE_SEND_ROOTDEL(rip,p_ACLD,saved_senderOS,senderid,
                                   send_objid,reschannum,sts);
                  }
                  else
                  {
                     OMuword  my_sdi;

                     my_sdi = rip.p_mapentry->sdi;
                     OM_PREP_SEND(rip,saved_senderOS);

                     sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry, reschannum, p_ACLD);

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

         /*=====================*/
         /*  check send status  */
         /*=====================*/

         if ((sts == OM_I_STOP_SENDING) || ((!(1&sts)) && (sts & SEV_LEV)) &&
             (sts != OM_E_NOSUCHCLASS))
         {
            break;
         }
      }		/* end of if the oid is non null */
   }		/* end of do for all oids */
  }		/* end of if this is a restricted channel */

   /*==============================*/
   /*  main loop for channel send  */
   /*  Non Restricted Channels     */
   /*==============================*/
  else
  {
   for (ii=0; ii < nument; ii++, p_link++)
   {
      if ( p_chan_hdr != *pp_chan_hdr ) /* must have moved */
      {
	   p_chan_hdr = *pp_chan_hdr;
      	   p_link = OM_PTR_TO_CHAN_LINK(p_chan_hdr);
      	   p_link += ii; 		/* point to correct link */
      }

      if ( ! (IF_EQ_OBJID(p_link->objid, NULL_OBJID))) 
      {
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
	    if ( sts == OM_W_OSNOTACTIVE || sts == OM_I_LOGICAL_DISCONNECT )
	    {
		continue;
	    }
            if (!(1&sts)) goto cleanup;

            saved_senderOS = OM_Gw_senders_OS;
            om$make_current_os(osnum=OS2);
            OM_Gw_senders_OS = saved_senderOS;
         }

         /*========================*/
         /*  is caching warrented  */
         /*========================*/
   
         if((nument < OM_Gf_min_caching_send) ||
            (OM_Gp_CurSpaceMap[send_objid].flags & 
                 (OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt)))
         {
            sts=om$send_obj_int(mode=WRT_flag, msg=msg,
			senderid=senderid, targetid=send_objid,
			channum=chan2);
         }
         else
         {
            OM_CACHE_SEND(senderid,send_objid,rip,p_cache,cache,p_ACLD,
                        WRT_flag,msg,chan2,sts,internal_sts,err3);
            if( (1&sts) && (1&internal_sts) )
    	    {
               if ( rip.p_mapentry->flags & OM_SM_send_depth )
               {
                  OM_PREP_SEND(rip,saved_senderOS);

                  sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry, chan2, p_ACLD);

                  OM_COMPLETE_SEND(rip,saved_senderOS,send_objid);
               }
               else
               {
                  if(p_cache->p_method != Root_Root_delete_method)
                  {
                     rip.p_mapentry->flags |= OM_SM_send_depth;
                     OM_PREP_SEND(rip,saved_senderOS);

                     sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry, chan2, p_ACLD);

                     OM_COMPLETE_SEND_ROOTDEL(rip,p_ACLD,saved_senderOS,senderid,
                                   send_objid,chan2,sts);
                  }
                  else
                  {
                     OMuword  my_sdi;

                     my_sdi = rip.p_mapentry->sdi;
                     OM_PREP_SEND(rip,saved_senderOS);

                     sts = p_cache->p_method (msg, saved_senderOS, senderid, 
                          send_objid,rip.p_mapentry, reschannum, p_ACLD);

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

         /*=====================*/
         /*  check send status  */
         /*=====================*/

         if ((sts == OM_I_STOP_SENDING) || ((!(1&sts)) && (sts & SEV_LEV)) &&
             (sts != OM_E_NOSUCHCLASS))
         {
            break;
         }
      }		/* end of if this objid is non null */
   }		/* end of do for all the objects on the channel */
  }		/* end of if this is a non restricted channel */

cleanup:   
   if ( !res1chan 
           && 
        !(def_flags & (CD_1_1 | CD_m_1))
           &&
        !(def_flags & (CD_absordered | CD_relordered)) )
   {
      if ( set_in_use ) 
      {
	 p_chan_hdr = *pp_chan_hdr;   /* in case it moved */
 	 p_chan_hdr->flags &= (~OM_CH_in_use);
         OM_GET_TAIL(p_chan_hdr,tail);
         if ( p_chan_hdr->flags & OM_CH_bigchan )
           p_chandata = (int *)((OMuint)*pp_chan_hdr+sizeof(OM_S_CHANNEL_HDR)+
                                sizeof(OM_S_BIG_TAIL));
         else
           p_chandata = (int *)((OMuint)*pp_chan_hdr+sizeof(OM_S_CHANNEL_HDR));
         
         if (!(1&(sts2 = om$collapse_channel(osnum=OM_Gw_current_OS, 
               objid=senderid, pp_chan=pp_chan_hdr, 
	       chdef=p_chandef, p_chandata=p_chandata,
	       p_tail=&tail))))
         {
            sts = sts2;
         }
      }
   }

   if ( saved_osnum != OM_Gw_current_OS )
   {
      om$make_current_os (osnum=saved_osnum);
   }

   rip2.p_mapentry = &OM_GA_OSDs[osnum]->Spacemap[senderid];
   if (set_senders_depth)
   {
      OM_S_MESSAGE         Rootdel_msg;			
							
      rip2.p_mapentry->flags &= ~OM_SM_send_depth;	
							
      /*=================================*/		
      /*  check for Root.delete pending  */		
      /*=================================*/		
							
      if ( rip2.p_mapentry->flags & OM_SM_Rootdel_pending )
      {							
         /*===================================*/		
         /*  fabricate a Root.delete message  */		
         /*===================================*/		

         int dummy_defer;

         Rootdel_msg.select.DefClassid = OM_K_ROOT_ACTCLASSID;  
         Rootdel_msg.select.ReqClassid = OM_K_ROOT_ACTCLASSID;
         Rootdel_msg.select.FuncIndex  = Root_OPP_delete_method_index;
         Rootdel_msg.size = sizeof(int);
         Rootdel_msg.p_arglist = (char *)&dummy_defer;	
							
         /*=============================*/			
         /*  invoke Root.delete method  */			
         /*=============================*/			
							
         sts2 = Root_Root_delete_method( &Rootdel_msg, 
                                         OM_Gw_senders_OS, 
                                         senderid, 
                                         senderid, 
                                         rip2.p_mapentry, 
                                         NULL_CHANNUM, 
                                         rip2.p_mapentry->p_acld );
         if (!(1&sts2))
            sts = sts2;
      }							
   }
   OM_GA_CSDarray[rip2.p_mapentry->sdi].PreSendDepth--;
   om$release_instance (rip = rip2);
   return(sts);
}


/*
------------- Function Description --------------------------------------------

  Function name:    som_send_foreign ( wrt_flag, msg, senderid, 
                                       targetid, osnum, in_channum )
 
  Input arguments:  
                    OM_E_WRT_FLAG   wrt_flag   How message is to be sent
                    OM_p_MESSAGE    msg        Message to be sent
                    OM_S_OBJID      senderid   Object id of sender - Assumed
                                                to be in current OS
                    OM_S_OBJID      targetid   Object id of target
                    OMuword         osnum      Object space number of target
                    OM_S_CHANNUM    in_channum Channel number message came
                                                in on

  Output arguments: None.

  Used to send directly to an object in another OS.  Current OS is saved and
  then restored after send is completed. (This save/restore is not done if one 
  accidentally sending to one's own space).

------------- Revision History ------------------------------------------------

gja001	17-apr-1986	Replaced body with the Macro "OM_SEND_FOREIGN"

ems001  12-dec-1986     Added "in_channum" arg

-------------------------------------------------------------------------------
*/

int som_send_foreign (
OM_E_WRT_FLAG			WRT_flag,
OM_p_MESSAGE			message,
OM_S_OBJID			senderid,
OM_S_OBJID			targetid,
OMuword				osnum,
OM_S_CHANNUM                    in_channum)

{
   int				sts;
   OMuword                      saved_osnum;
   OMuword                      saved_senders_osnum;

   /*=========================*/
   /*  check for valid osnum  */
   /*=========================*/

   if ((OM_Gw_maxOS < osnum) || (OM_GA_OSDs[osnum] == NULL))
   {
      return (OM_E_NOSUCHOS);
   }

   /*================================================*/
   /*  save osnum's in locals for later restoration  */
   /*================================================*/

   saved_osnum = OM_Gw_current_OS;
   saved_senders_osnum = OM_Gw_senders_OS;
   if ( OM_Gw_current_OS != osnum )
   {
      om$make_current_os ( osnum=osnum );
      OM_Gw_senders_OS = saved_senders_osnum;
   }

   /*===========================*/
   /*  perform the actual send  */
   /*===========================*/

   sts = om$send_obj_int ( mode=WRT_flag, msg=message, senderid=senderid, 
                           targetid=targetid, channum=in_channum );

   /*==============*/
   /*  restore OS  */
   /*==============*/

   if ( OM_Gw_current_OS != saved_osnum )
   {
      om$make_current_os ( osnum=saved_osnum );
   }

   OM_Gw_senders_OS = saved_senders_osnum;

   return (sts);
}


#ifdef VALSPMAP

void print_msg( select, objid, flag )

OM_S_METHSELECT	select;
OM_S_OBJID	objid;
OMbyte		flag;

{
char	ba[10];
OM_p_METHDEFN	p_methdefn;

if ( flag )
   strcpy(ba,"after");
else
   strcpy(ba,"before");
      
printf("\n======= CORRUPTION OCCURRED =======\n");
printf("Found corruption %s sending the following message to objid %d.\n\n", ba, objid);
printf("Osnum : %d\n", OM_Gw_current_OS);
printf("Defining class : %s\n", OM_GA_active_classes[select.DefClassid]->s_name);
printf("Requesting class : %s\n", OM_GA_active_classes[select.ReqClassid]->s_name);

p_methdefn = OM_GA_active_classes[select.DefClassid]->p_methdefns;
while (p_methdefn->w_methidx != select.FuncIndex)
      {
      p_methdefn = p_methdefn->next;
      if (p_methdefn == NULL)
         {
         printf("Method definition table corrupt for this class.\n");
         return;
         }
      } /* end while */

printf("Method name: %s\n\n", p_methdefn->s_name);

}


void print_objhdr( p_object )

OM_p_OBJECTHDR	p_object;

{
OMuword		act_classid;

printf("\n=== Object Header ===\n");
printf("w_classid : %d\n", p_object->w_classid);

if (p_object->w_classid != 0)
   {
   act_classid = OM_GA_filed_to_active[p_object->w_classid];
   printf("class name : %s\n", OM_GA_active_classes[act_classid]->s_name);
   } 

if (p_object->w_flags & OM_OHf_has_VLA)
   printf("object has VLA\n");

if (p_object->w_flags & OM_OHf_is_tagged)
   printf("object is tagged\n");

if (p_object->w_flags & OM_OHf_max_clusterid)
   printf("max cluster id not allowed\n");

printf("i_size : %d\n\n", p_object->i_size);

}

void OM_validate_spacemap( select, targetid, flag )
	
	OM_S_METHSELECT	select;
	OM_S_OBJID	targetid;
	OMbyte		flag;		/* 0 - before send */
					/* 1 - after send  */
{
 uword     	act_classid;
 int       	ii;
 OMuint      	flags;
 OM_p_SPAMAPENT p_spamapent;
 OM_p_OBJECTHDR p_object;

if ( ! OM_in_construct_os &&        /* not in om$construct_os */
    select != OMOSCO_add_class_msgsel) /* not dynamic class
processing */
{

if (OM_Gp_CurSpaceMap) 
    {

    for (ii=0,p_spamapent=OM_Gp_CurSpaceMap; 
         ii < OM_Gp_CurSpaceMap;  ii++, p_spamapent++) 
        {
        flags = p_spamapent->flags;
        if ( (flags & OM_SM_in_use) && (flags & OM_SM_in_mem) )
          {
            p_object = p_spamapent->state.object;
	    if (p_object->oid >= OM_Gp_CurSpaceMap)
               {
	       print_msg(select, targetid, flag);
               printf("Object header oid is > space map size.\n");
	       print_objhdr(p_object);
	       break;
	       }

  	    if ( OM_GETOBJSIZE(p_object->i_size) == 0 )
	       {
	       print_msg(select, targetid, flag);
               printf("Object header size is zero.\n");
	       print_objhdr(p_object);
	       break;
	       }

  	    if ( OM_GETOBJSIZE(p_object->i_size) + (int)p_object > 
		 OM_GA_CSDarray[OM_Gp_CurSpaceMap[p_object->oid].sdi].p_addr +
		 OM_GA_CSDarray[OM_Gp_CurSpaceMap[p_object->oid].sdi].p_pcd->i_totalsize )
	       {
	       print_msg(select, targetid, flag);
               printf("Object header size extends object past end of pcd.\n");
	       print_objhdr(p_object);
	       break;
	       }

            if ( OM_Gp_CurOSD->OSCO_list[OM_K_OMGROUP_ACTCLASSID] )
	    {
	    if( OM_Gp_CurSpaceMap[p_object->oid].flags & OM_SM_unknown_obj
		|| !(OM_Gp_CurSpaceMap[p_object->oid].p_acld) )
	    {
		print_msg(select,targetid,flag);
		printf("Object is of unknown class\n");
		print_objhdr(p_object);
		break;
	    }
	    act_classid = OM_Gp_CurSpaceMap[p_object->oid].p_acld->w_classid;
            if ( (act_classid != OM_K_NOTUSING_CLASSID) &&
	         (! (act_classid > 0) ) ) 
            {
	       print_msg(select, targetid, flag);
               printf("Bad active classid : %d.\n", act_classid);
	       print_objhdr(p_object);
	       break;
            }
            if ( act_classid != OM_K_NOTUSING_CLASSID )
		{
		if ( ! OM_GA_active_classes[act_classid] )
		   {
	           print_msg(select, targetid, flag);
                   printf("No acld exists for classid : %d.\n", act_classid);
	           print_objhdr(p_object);
	           break;
		   }
		}
	    }	/* if Group OSCO exists */
            } /* if in_use */
      } /* for ii < p_OSD->CurSpaceMapSize */
   }  /* if spacemap */
 else
   {
   print_msg(select, targetid, flag);
   printf("Spacemap corrupt; size is 0.\n");
   }

}
}

#endif
