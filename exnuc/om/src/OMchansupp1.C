/*
---------------------------------------------------------------------------

	Name:			OMchansupp1.c
	Author:			Chuck Puckett
	Creation Date:		21-oct-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	This module contains OM channel support routines.

	Revision History:

rme001  30-jun-1986     change to reflect 4.0 channels.

geo001  07-may-1987	change to handle restricted channels.

ems001  14-may-1987     fixed bug in get_channel_count with singletons in
                         Read Only OS's

rme002  25-may-1987 	Optimized som_get_channel for speed.  Changed 
			 the way som_get_channel_number uses om$parse_channame

---------------------------------------------------------------------------
*/

#ifndef OM_D_OBJECTCOMM
#include	"OMobjectcomm.h"
#endif

#ifndef OM_D_INTPRIMS
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#endif

#include <stdio.h>
#include <string.h>

extern int OM_Gi_maxchan_size;


/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++ som_get_channel_number */

int som_get_channel_number(channame, p_channum)

/*----------------------------------------------------------------------------
    Description:

    Builds a channel number structure given a channame.  Channame must
    include a class name and a channel name.  
----------------------------------------------------------------------------*/

char               *channame;     /*  the channame  */
OM_p_CHANNUM       p_channum;     /*  pointer to resulting channel number  */
								/*-fndesc*/
{
   int                 sts;             /*  function return status  */
   OMuword             classid;         /*  active classid  */
   OM_p_CLASSDEF       p_cld;           /*  pointer to ACLD  */
   OM_p_CHANNEL_DEFN   p_chandef;       /*  pointer to a chan definition  */   
   OMbyte              transmap_index;  /*  index to message map entry  */
   OM_p_MSGMAP         p_msg;           /*  pointer to a message map entry  */
   OMuword             channumber;      /*  counter for ChanDefns array  */
   OMuword             limit;           /*  loop invariant  */
   char                *p_dot;          /*  ptr to dot in channame string  */

   /*------------------------------------------------------*/
   /*  See if the class name is part of the channel name.  */
   /*------------------------------------------------------*/

   om$parse_channame(channame=channame, pp_dot=&p_dot);

   if( ! p_dot )
      return (OM_E_AMBIGUOUS_CHANNAME);

   *p_dot = '\0';
   
   /*------------------------------------------*/
   /*  Get active classid and pointer to ACLD  */
   /*------------------------------------------*/

   sts = om$get_class
            (classname=channame,
             p_classid=&classid,
             pp_cld=&p_cld);

   *p_dot = '.';
   if (!(1&sts)) return (sts);

   channame = p_dot + 1;

   /*---------------------------------------------------*/
   /*  Get pointer to message map entry for this class  */
   /*---------------------------------------------------*/

   /*  get translation map index  */

   if ( (classid < p_cld->w_baseclass) ||
        (classid > p_cld->w_maxclass) ||
        (OM_K_NULL_TRANS == 
          (transmap_index = p_cld->p_transmap[classid - p_cld->w_baseclass])) )
   {
      /*  class is not defined  */

      return (OM_E_NOSUCHCLASS);
   }

   /*  get message map pointer  */

   p_msg = p_cld->MsgMap+transmap_index;


   /*------------------------------------------------------------*/
   /*  Loop through the channel definitions to find a match for  */
   /*  the channel name.                                         */
   /*------------------------------------------------------------*/

   p_chandef = p_msg->ChanDefns;
   limit = p_msg->NumChan;

   for (channumber=0; channumber < limit; channumber++, p_chandef++)
   {
      if (! strcmp(channame, p_chandef->s_name))
      {
         /*  found the matching channel name  */
   
         p_channum->classid = classid;
         p_channum->number = channumber;

         return (OM_S_SUCCESS);
      }
   }
   
   /*  matching channel name not found  */

   return (OM_E_INVCHAN);
}


/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++++ som_get_channel_name */

int som_get_channel_name (channame ,channum )

/*
    Description:

    Uses a channum structure to build a channame string.  The channame
    contains a class name, followed by a period, followed by the name
    of the channel.

*/

OM_S_CHANNUM       channum;      /*  channel number  */
char               *channame;    /*  channel name.  Note: should be declared
                                     in the calling program as follows:
                                     char   channame[OM_K_MAXCHANNAME_LEN]
                                 */

{
   OM_p_CLASSDEF       p_cld;           /*  pointer to ACLD  */
   OM_p_CHANNEL_DEFN   p_chandef;       /*  pointer to a chan definition  */   
   OMbyte              transmap_index;  /*  index to message map entry  */
   OM_p_MSGMAP         p_msg;           /*  pointer to a message map entry  */

   /*---------------------------------------------*/
   /*  Use active classid to get pointer to ACLD  */
   /*---------------------------------------------*/

   if ( (channum.classid >= OM_Gw_next_class_index) ||
        (NULL == (p_cld = OM_GA_active_classes[channum.classid])) )
   {
      return (OM_E_NOSUCHCLASS);
   }

   /*---------------------------------------------------*/
   /*  Get pointer to message map entry for this class  */
   /*---------------------------------------------------*/

   /*  get translation map index  */

   if ( (channum.classid < p_cld->w_baseclass) ||
        (channum.classid > p_cld->w_maxclass) ||
        (OM_K_NULL_TRANS == 
            (transmap_index = 
             p_cld->p_transmap[channum.classid - p_cld->w_baseclass]))  )
   {
      /*  class is not defined in the translation map  */      

      return (OM_E_NOSUCHCLASS);
   }

   /*  get message map pointer  */

   p_msg = p_cld->MsgMap+transmap_index;

   /*---------------------------------------------------------*/
   /*  Get the channel name from the appropriate channel def  */
   /*---------------------------------------------------------*/

   if (channum.number >= p_msg->NumChan)
   {
      /*  invalid channel number for this class  */

      return (OM_E_INVCHAN);
   }

   /*  Get pointer to the channel definition for this channel number.  */

   p_chandef = p_msg->ChanDefns + channum.number;

   /*  return the classname and channel name  */

   strncpy(channame,p_cld->s_name,OM_K_MAXCLASS_LEN);
   strncat(channame,".",1);
   strncat(channame,p_chandef->s_name,OM_K_MAXCHANNEL_LEN);

   return (OM_S_SUCCESS);
}


/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++ som_get_channel */


/*-----------------------------------------------------------------------------
    Description:

    Returns a pointer to a channel and optionally returns a pointer to
    the channel definition. (The later is returned if pp_chandef is not NULL)

-----------------------------------------------------------------------------*/

int som_get_channel(
OMuword                osnum,          /*  object space of the channel */
OM_S_OBJID             objid,          /*  objid that contains the */
                                       /*  channel. */
OM_p_OBJECTHDR         p_object,       /*  pointer to instance  */
                                       /*  containing the channel. */
OM_p_CHANSELECT        p_chanselect,   /*  pointer to a channel selector. */
OM_p_CHANNEL_HDR       **ppp_channel,  /*  address to store chan ptr  */
OM_p_CHANNEL_DEFN      *pp_chandef,    /*  address to store chandef ptr */
int                   **pp_chandata,   /*  address to store chandata ptr */
OM_p_BIG_TAIL           p_tail,        /*  address to store tail info */
OM_p_CHANNUM            p_channum)     /*  address to store channum */

{
   int                  sts;               /*  return status          */
   OM_S_CHANNUM         channum;           /*  local channel number   */
   OM_p_CLASSDEF        p_cld;             /*  ACLD pointer           */
   OM_S_RIP             rip;          
   OMbyte               transmap_index;    /*  Translation map entry  */
   OM_p_MSGMAP          p_msg;
   OM_p_CHANNEL_DEFN    p_chandef;
   OMuword              flags=0;
   int                  res1chan;

   /*  set rip to use as a flag  */

   rip.p_object = NULL;

   /*---------------------------*/
   /*  get an instance pointer  */
   /*---------------------------*/

   if (p_object == NULL)
   {
      if (! IF_EQ_OBJID(objid, NULL_OBJID) )
      {
         if (osnum != OM_Gw_current_OS)
            sts = om$get_any_instance(osnum=osnum, 
                                      objid=objid, 
                                      p_rip=&rip);
         else
            sts = om$get_instance(objid=objid,
                                  p_rip=&rip);
         
         if (!(1&sts))  return (sts);
         p_object = rip.p_object;
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   /*-----------------------------*/
   /*  get a pointer to the ACLD  */
   /*-----------------------------*/

   if (rip.p_object)
         sts = om$get_class(osnum=osnum,
                            object=p_object,
                            pp_cld=&p_cld,
                            check_os=0);
   else
         sts = om$get_class(osnum=osnum,
                            object=p_object,
                            pp_cld=&p_cld);
   if (!(1&sts)) return (sts);

   /*------------------------------*/
   /*  interpret channel selector  */
   /*------------------------------*/

   switch (p_chanselect->type)
   {
      case OM_e_addr:         

        /*----------------------------*/ 
        /*  Case: By channel pointer  */
        /*----------------------------*/

         *ppp_channel = p_chanselect->u_sel.addr;

         /*  Note: mychan is returned with an active classid  */

         om$get_mychan ( p_object   = (int) p_object, 
                         p_cld      = p_cld, 
                         p_channel  = (int) *ppp_channel, 
                         pp_chandef = &p_chandef, 
                         p_channum  = &channum );
         if ( pp_chandef ) *pp_chandef = p_chandef;
         if ( p_channum  ) *p_channum  = channum;
         break;

      case OM_e_name:
      {
         /*-------------------------*/
         /*  Case: By channel name  */
         /*-------------------------*/

         char      *p_dot;      /* Ptr to the dot in the channame. */
         OMuword   NumMsg;      /* No. of message map entries. */
         OMuword   NumChan;     /* No. of channel definitions. */
         int       ii;
         OMuword   jj, tmp_jj=0;
         OMuword   classid;     /* Active classid of component class. */
         int       found;       /* Flag indicating found the channel. */
         char      *channame;   /* Local ptr to channame. */

         OM_p_MSGMAP       tmp_p_msg=NULL; /* Ptr to component's message map 
                                             entry. */
         OM_p_CHANNEL_DEFN tmp_p_chandef=NULL; /* Ptr to component's channel 
                                             definitions. */

         channame = p_chanselect->u_sel.name;         
         if (!channame)
            return (OM_E_INVCHAN);

         om$parse_channame(channame=channame, pp_dot=&p_dot);
   
         if (!p_dot)
         {   
            /*------------------------------------------*/         
            /*  Have to search the entire message map.  */
            /*------------------------------------------*/

            NumMsg = p_cld->NumMsgClasses;
            p_msg = p_cld->MsgMap + (NumMsg - 1);
         }
         else
         {
            /*--------------------------------------------------------------*/
            /*  Only have to look at one set of channel definitions for my  */
            /*  message map entry                                           */
            /*--------------------------------------------------------------*/

            *p_dot = '\0';
            sts = om$get_classid(classname=channame,
                                 p_classid=&classid);
            *p_dot = '.';

            if (!(1&sts))
               return (sts);

            if ( (classid < p_cld->w_baseclass) 
                              ||
                 (classid > p_cld->w_maxclass) 
                              ||
                 (OM_K_NULL_TRANS == 
                   (transmap_index = 
                       p_cld->p_transmap[classid - p_cld->w_baseclass])))
               return (OM_E_NOSUCHCLASS);

            p_msg = p_cld->MsgMap + transmap_index;
            NumMsg = 1;
            channame = p_dot + 1;
         }

         found = FALSE;

         for (ii=NumMsg; ii > 0; ii--, p_msg--)
         {
            NumChan = p_msg->NumChan;
            p_chandef = p_msg->ChanDefns;
         
            for (jj=0; jj < NumChan; jj++, p_chandef++)
               if(!strncmp(channame,p_chandef->s_name,OM_K_MAXCHANNEL_LEN))
               {
                  if (found)
                     return (OM_E_AMBIGUOUS_CHANNAME);

                  tmp_jj = jj;
                  tmp_p_msg = p_msg;
                  tmp_p_chandef = p_chandef;
                  found = TRUE;
               }  

         }/*loop over message map */
  
         if (! found)  
            return (OM_E_INVCHAN);

         /*--------------------------------------------------*/
         /*  Return the pointer to the channel and chandef.  */
         /*--------------------------------------------------*/

         *ppp_channel = (OM_p_CHANNEL_HDR *) ( (OMuint) p_object + 
                                             (OMuint) tmp_p_msg->offset + 
                                              tmp_p_chandef->i_offset );

         if (pp_chandef) *pp_chandef = tmp_p_chandef;
         if (p_channum) 
         {
           p_channum->number  = tmp_jj;
           p_channum->classid = tmp_p_msg->classid;
         }
         p_chandef = tmp_p_chandef;
         break;
      }
      case OM_e_num:         

         /*---------------------------*/
         /*  Case: By channel number  */
         /*---------------------------*/

         channum.classid = p_chanselect->u_sel.number.classid;
         channum.number = p_chanselect->u_sel.number.number;

         /*---------------------------------------------*/
         /*  Get translation map entry for this class.  */
         /*---------------------------------------------*/

         if ( (channum.classid < p_cld->w_baseclass) ||
              (channum.classid > p_cld->w_maxclass) ||
              (OM_K_NULL_TRANS ==
                 (transmap_index = 
                  p_cld->p_transmap[channum.classid - p_cld->w_baseclass])))
         {
            return (OM_E_INVCHAN);
         }

         /*-----------------------------------------*/
         /*  Get pointers to the message map entry  */
         /*  and channel definition for this class  */
         /*-----------------------------------------*/

         p_msg = p_cld->MsgMap + transmap_index;
   
         /*  Validate the channel number.  */
   
         if ( channum.number < p_msg->NumChan )
         {
            p_chandef = p_msg->ChanDefns + channum.number;
            if (pp_chandef) *pp_chandef = p_chandef;
         }
         else
         {
            return (OM_E_INVCHAN);
         }

         /*--------------------------------------------------------------*/
         /*  Add message map offset and chan def offset to the instance  */
         /*  pointer to obtain the channel pointer.                      */
         /*--------------------------------------------------------------*/

         *ppp_channel = (OM_p_CHANNEL_HDR *) ( (OMuint) p_object + 
                                             (OMuint) p_msg->offset + 
                                             p_chandef->i_offset );
         if (p_channum) *p_channum = channum;
         break;

      default:
         return (OM_E_CHNSELTYPINV);
   }

   /*--------------------------------*/
   /*  assume empty channel for now  */
   /*--------------------------------*/

   if ( p_tail ) 
   {
      p_tail->last_index = 0;
      p_tail->collapse_count = 0;
      p_tail->size = 0;
   }

   /*-------------------------------------------------*/
   /*  Is the channel pointer in the instance zero ?  */
   /*-------------------------------------------------*/

   if (!(*((int *)(*ppp_channel)))) 
   {
      return (OM_S_SUCCESS);
   }

   /*-----------------------------------------------------*/
   /*  Now check if a pointer to the channel data and/or  */
   /*  last_index has been requested                      */
   /*-----------------------------------------------------*/

   if ((p_chandef->p_type->w_flags & CD_restricted) &&
       (p_chandef->p_type->w_flags & (CD_1_1|CD_m_1)))
      res1chan = 1;
   else
      res1chan = 0;

   if ( pp_chandata )
   {
      if (res1chan)
      {
         *pp_chandata = (int *) *ppp_channel;
      }
      else
      {
         flags = (**ppp_channel)->flags;
         if (flags & OM_CH_singleton)
            *pp_chandata = (int *)**ppp_channel;
         else
            if (flags & OM_CH_bigchan)
               *pp_chandata = (int *)((OMuint)**ppp_channel + 
                           sizeof(OM_S_CHANNEL_HDR) + sizeof(OM_S_BIG_TAIL));
            else
               *pp_chandata = (int *)((OMuint)**ppp_channel + 
                                              sizeof(OM_S_CHANNEL_HDR));
      }
   }

   if ( p_tail ) 
   {
      if (res1chan || ((flags & OM_CH_singleton) && (flags & OM_CH_full)))
      {
         p_tail->last_index = p_tail->size = 1;
      }
      else
      {
         OM_GET_TAIL(**ppp_channel, *p_tail);
      }
   }

   return (OM_S_SUCCESS);
}


/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++ som_is_objid_on_channel */


/*
    Description:

    Finds the channel address and checks whether or not the object id 
    in question exists within the links of the given channel.

*/

int som_is_objid_on_channel(
OMuword                osnum_c,        /*  object space of the channel */
OM_S_OBJID             objid_c,        /*  objid that contains the */
                                       /*  channel. */
OM_p_OBJECTHDR         p_object_c,     /*  pointer to instance  */
                                       /*  containing the channel. */
OM_p_CHANSELECT        p_chanselect,   /*  pointer to a channel */
                                       /*  selector. */
OM_S_OBJID             objid,          /*  object id to search for.  */
OMuword                osnum2)         /*  object space of the object  */
                                       /*  to search for.  */

								/*-fndesc*/
{
   OM_p_CHANNEL_LINK	p_link;            /*  Pointer to first link.  */
   OM_p_OBJID		p_chanoid;	   /*  Pointer to first objid,  */
					   /*  used for restricted chan */
   int                  sts;               /*  Return status.  */
   OMuint               ii, numch;         /*  Loop counters.  */
   OM_p_CHANNEL_HDR    *p_channel;         /*  Pointer to channel itself.  */
   int                 *p_chandata;        /*  Pointer to channel data */
   OMuword              other_os;          /*  Returns from ISO stuff.  */
   OM_S_OBJID           other_objid;
   OM_S_CHANNUM         other_chan;
   OMuword              other_flags;
   OM_S_BIG_TAIL        tail;
   OM_p_CHANNEL_DEFN    p_chdef;

   /*-------------------------------------------*/
   /*  Get a pointer to the channel to search.  */
   /*-------------------------------------------*/

   sts = om$get_channel
            (osnum=osnum_c,
             objid=objid_c,
             object=p_object_c,
             p_chanselect=p_chanselect,
             pp_channel=&p_channel,
             pp_chandata=&p_chandata,
             pp_chandef=&p_chdef,
             p_tail=&tail);
   
   if (!(1&sts)) return (sts);

   if (!(*p_channel)) return (OM_W_NOTONCHAN);   

   numch = tail.last_index;

   if ( p_chdef->p_type->w_flags & CD_restricted )
   {
      /*-----------------------------------------------------*/
      /*  loop over all the objids trying to match the objid */
      /*-----------------------------------------------------*/

      p_chanoid = (OM_p_OBJID) p_chandata;

      if (p_chdef->p_type->w_flags & (CD_1_1|CD_m_1))
      {
         if (IF_EQ_OBJID((*p_chanoid>>1),objid) && (osnum_c == osnum2))
         {
            return (OM_S_SUCCESS);
         }
      }
      else
      {
         for (ii=0; ii < numch; ii++, p_chanoid++)
         { 
            if (IF_NULL_OBJID(*p_chanoid)) continue;

            if (IF_EQ_OBJID(*p_chanoid, objid) && (osnum_c == osnum2)) 
            { 
               return(OM_S_SUCCESS);
            } 
         }
      }
   }
   else
   {
      /*-----------------------------------------------------*/
      /*  loop over all the links trying to match the objid  */
      /*-----------------------------------------------------*/

      p_link = (OM_p_CHANNEL_LINK) p_chandata;

      for (ii=0; ii < numch; ii++, p_link++) 
      { 
         if (IF_NULL_OBJID(p_link->objid)) continue;
   
         if (p_link->hdr.flags & OM_CL_to_object)
         {
   	    if (IF_EQ_OBJID(p_link->objid, objid) && (osnum_c == osnum2)) 
            {
  	       return(OM_S_SUCCESS);
  	    }
         }
         else 
         {
            /*-------------------------*/
            /*  link connected to iso  */
            /*-------------------------*/

            if (1&(sts=som_ISO_fetch(osnum_c, p_link->hdr.u1.isoindex,
                        p_link->objid, &other_os, &other_objid, &other_chan, 
                        &other_flags))) 
            {
               if ( sts == OM_I_LOGICAL_DISCONNECT ) continue;

               /*  check for a match  */

               if (IF_EQ_OBJID(objid, other_objid) && (osnum2 == other_os))
               {
                  return (OM_S_SUCCESS);
               }
            } 
            else 
            {
               if ( sts == OM_W_OSNOTACTIVE ) continue;
  	       printf("som_is_objid_on_channel: som_ISO_fetch fail\n");
	       return(sts);
            }
         }
      } 
   }
   /*  objid not matched with any object id in the channel links.  */

   return (OM_W_NOTONCHAN);
}


/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++ som_get_channel_count */


/*
    Description:


    This routine counts the number of non null objids within a channel's
    links.  Various combinations of parameters are used to derive a 
    pointer to a specific channel from which the count is extracted.

*/

int    som_get_channel_count (
OMuword               osnum,        /*  object space number       */
OM_S_OBJID            objid,        /*  object id                 */
OM_p_OBJECTHDR        p_object,     /*  object instance pointer   */
OM_p_CHANSELECT       p_chanselect, /*  channel selector address  */
OMuint                *count)       /*  object count returned     */

{
   OM_p_CHANNEL_LINK	p_link;      	  /*  ptr to loop channel links      */
   OM_p_OBJID		p_chanoid; 	  /*  ptr to restricted channel oids */
   int                  sts;              /*  returned status                */
   OM_p_CHANNEL_HDR    *p_channel;        /*  channel pointer                */
   int                 *p_chandata;       /*  ptr to channel data            */
   OMuword              w_channel_flags;  /*  Flags word in the channel      */
   OMuint               numlinks;         /*  number of links in channel     */
   OMuint               loc_count;        /*  count of non null links        */
   OMuint               ii;               /*  loop counter                   */
   OMuword              os2;              /*  os for ISO_fetch               */
   OM_S_OBJID           oid2;             /*  oid for ISO_fetch              */
   OM_S_CHANNUM         ch2;              /*  channum for ISO_fetch          */
   OMuword              flg2;             /*  flag word for ISO_fetch        */
   OM_S_BIG_TAIL        tail;             /*  channel tail                   */
   OM_p_CHANNEL_DEFN    p_chdef;          /*  ptr to channel defn            */

   /*--------------------------------*/
   /*  Get a pointer to the channel  */
   /*--------------------------------*/

   sts = om$get_channel
            (osnum=osnum,
             objid=objid,
             object=p_object,
             p_chanselect=p_chanselect,
             pp_channel=&p_channel,
             pp_chandata=&p_chandata,
             pp_chandef=&p_chdef,
             p_tail=&tail);

   if (!(1&sts)) return (sts);

   *count = 0;

   if (!(*p_channel)) return (OM_S_SUCCESS);

   /*-----------------------*/
   /*  check res1chan case  */
   /*-----------------------*/

   if ((p_chdef->p_type->w_flags & CD_restricted) &&
       (p_chdef->p_type->w_flags & (CD_1_1|CD_m_1)))
   {
      *count = 1;
      return (OM_S_SUCCESS);
   }

   numlinks = tail.last_index;
   w_channel_flags = (*p_channel)->flags;

   if (w_channel_flags & OM_CH_singleton)
   {
      p_link = (OM_p_CHANNEL_LINK) p_chandata;     

      if (! IF_NULL_OBJID (p_link->objid))
      {
         if ( OM_Gw_RO_OS_count )
         {
            if (!(p_link->hdr.flags & OM_CL_to_object))
            {
               if (OM_I_LOGICAL_DISCONNECT != som_ISO_fetch (osnum, 
                     p_link->hdr.u1.isoindex, p_link->objid, &os2, &oid2, 
                     &ch2, &flg2))
               {
                  *count = 1;
               }
            }
            else
            {
               *count = 1;
            }
         }
         else
         {
            *count = 1;
         }
      }
      return (OM_S_SUCCESS);
   }

   /*---------------------*/
   /*  VLA used to store  */
   /*  channel links.     */
   /*---------------------*/

   if ( !(w_channel_flags & OM_CH_absordered) && !OM_Gw_RO_OS_count )
   {
      *count = numlinks - tail.collapse_count;
      return(OM_S_SUCCESS);
   }

   /*-------------------------------------*/
   /*  Absolute ordered or RO OS active   */
   /*  or fixed.                          */
   /*  Have to count the non null links.  */
   /*-------------------------------------*/

   loc_count = 0;

   if (w_channel_flags & OM_CH_restricted)
   {
      p_chanoid = (OM_p_OBJID) p_chandata;
 
      for (ii=0; ii < numlinks; ii++, p_chanoid++) 
      {
         if (! IF_NULL_OBJID(*p_chanoid)) loc_count++;
      }  
   
      *count = loc_count;
      return(OM_S_SUCCESS);
   }

   p_link = (OM_p_CHANNEL_LINK) p_chandata;

   if ( OM_Gw_RO_OS_count )
   {
      for (ii=0; ii < numlinks; ii++, p_link++) 
      {
         if (! IF_EQ_OBJID(p_link->objid, NULL_OBJID))
         {
            if ( !(p_link->hdr.flags & OM_CL_to_object))
            {
               if (OM_I_LOGICAL_DISCONNECT != som_ISO_fetch (osnum, 
                  p_link->hdr.u1.isoindex, p_link->objid, &os2, &oid2,
                  &ch2, &flg2))
               {
                  loc_count++;
               }
            }
            else
            {
               loc_count++;
            }
         }
      }  
   }
   else
   {
      for (ii=0; ii < numlinks; ii++, p_link++) 
      {
         if (! IF_EQ_OBJID(p_link->objid, NULL_OBJID))
         {
            loc_count++;
         }
      }  
   }
   
   *count = loc_count;
   return (OM_S_SUCCESS);
      
}


/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++ som_get_channel_objects */


/*
    Description:

    This routine builds a list of object linkages that are on a given 
    channel.  It will also return a count of the object linkages that 
    are put in the list.  The caller must allocate the space for the
    list.  The caller must also pass the size (number of object linkages) 
    that the list will hold.  The object linkages put in the list are those
    channel links that are in this channel.  For a description of an 
    object linkage see OMminimum.h

*/

int som_get_channel_objects(
OMuword               osnum,         /*  Os number containing channel.  */
OM_S_OBJID            objid,         /*  Object id containing channel.  */
OM_p_OBJECTHDR        p_object,      /*  Ptr to object containing channel.  */
OM_p_CHANSELECT       p_chanselect,  /*  Channel selector describing chan.  */
OM_S_OBJECT_LINKAGE   list[],        /*  List of linkages returned.  */
OMuint                size,          /*  Max no. of elements allowed in list.*/
OMuint                *count)        /*  No. of elements returned.  */

{
   OM_S_OBJECT_LINKAGE  tmp_objlink;   /*  Temporary storage          */
   OM_p_CHANNEL_LINK	p_chlink;      /*  Pointer to a channel link  */
   OM_p_OBJID		p_choid;       /*  Pointer to a channel oid   */
   int                  sts;
   OMuint               ii, 
                        loc_count,     /*  Count of non null links    */ 
			ch_count;      /*  Number of links in channel */
   OM_p_CHANNEL_HDR    *p_channel;
   OMuword              other_os;      /*  iso case return values     */
   OM_S_OBJID           other_objid;
   OM_S_CHANNUM         other_chan;
   OMuword              other_flags;
   OM_p_CHANNEL_DEFN	p_chandef;
   int                 *p_chandata;
   OM_S_BIG_TAIL        tail;

   /*-----------------------------------*/
   /*  Get a pointer to the channel to  */
   /*  search.                          */
   /*-----------------------------------*/

   sts = om$get_channel
            (osnum=osnum,
             objid=objid,
             object=p_object,
             p_chanselect=p_chanselect,
             pp_channel=&p_channel,
	     pp_chandef=&p_chandef,
             pp_chandata=&p_chandata,
             p_tail=&tail);

   if (!(1&sts)) return (sts);

   /*-----------------------------------*/
   /*  Get the number of channel links  */
   /*  and a pointer to first link.     */
   /*-----------------------------------*/

   *count=0;

   if (!(*p_channel)) return (OM_S_SUCCESS);

   ch_count = tail.last_index;
   loc_count = 0;

   if ( p_chandef->p_type->w_flags & CD_restricted )
   {
      p_choid = (OM_p_OBJID) p_chandata;
      tmp_objlink.channum = p_chandef->p_type->channum;
      tmp_objlink.w_flags = OM_CL_to_object;
      tmp_objlink.osnum   = osnum;  /*  link within this OS  */

      /*---------------------------*/
      /*  check for res1chan case  */
      /*---------------------------*/

      if ( p_chandef->p_type->w_flags & (CD_1_1|CD_m_1) )
      {
         if (loc_count+1 > size)  return (OM_I_LISTOVFLOW);
         tmp_objlink.S_objid = (*p_choid>>1);
         list[loc_count++] = tmp_objlink;
         *count = loc_count;
         return (OM_S_SUCCESS);
      }

      for (ii=0; ii < ch_count; ii++, p_choid++) 
      {
         if (IF_NULL_OBJID(*p_choid)) continue;

         if (loc_count+1 > size)  return (OM_I_LISTOVFLOW);

         tmp_objlink.S_objid = *p_choid;
         list[loc_count++] = tmp_objlink;
         *count = loc_count;

      }
      return(OM_S_SUCCESS);
   }

   /*-----------------------------------------------------------------*/
   /* loop through all the channel links copying them into list array */
   /*-----------------------------------------------------------------*/

   p_chlink = (OM_p_CHANNEL_LINK) p_chandata;

   for (ii=0; ii < ch_count; ii++, p_chlink++) 
   {
      if (IF_EQ_OBJID(p_chlink->objid, NULL_OBJID)) continue;

      if (loc_count+1 > size)  return (OM_I_LISTOVFLOW);

      if (p_chlink->hdr.flags & OM_CL_to_object)
      {
         /*---------------*/
         /*  object case  */
         /*---------------*/
         
         tmp_objlink.w_flags = p_chlink->hdr.flags;
         tmp_objlink.channum.classid = 
               OM_GA_OSDs[osnum]->FilToAct[p_chlink->channum.classid];
         tmp_objlink.channum.number = p_chlink->channum.number;
         tmp_objlink.osnum = osnum;  /*  link within this OS  */
         tmp_objlink.S_objid = p_chlink->objid;

         list[loc_count++] = tmp_objlink;
         *count = loc_count;
      }
      else 
      {
         /*------------*/
         /*  iso case  */
         /*------------*/

         if (1&(sts=som_ISO_fetch(osnum, p_chlink->hdr.u1.isoindex, 
                        p_chlink->objid, &other_os, &other_objid, 
                        &other_chan, &other_flags)))
         {
            if ( sts == OM_I_LOGICAL_DISCONNECT ) continue;

            tmp_objlink.w_flags = other_flags;
            tmp_objlink.channum = other_chan;
            tmp_objlink.osnum = other_os;
            tmp_objlink.S_objid = other_objid;
             
            list[loc_count++] = tmp_objlink;
            *count = loc_count;
         }
         else 
         {
            if ( sts == OM_W_OSNOTACTIVE ) continue;
            printf("som_get_channel_objects: som_ISO_fetch fail\n");
	    return(sts);
	 }
      }
   } 
   return (OM_S_SUCCESS);
}


/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++++ som_get_index */


/*
    Description:

    This routine uses a pointer to an ordered channel to search for an 
    objid.  If found it will return the relative or absolute index of
    the objid in the ordered channel.

*/

int som_get_index(
OMuword                  osnum_c,       /*  os number of the channel  */
OM_S_OBJID               objid_c,       /*  objid containing the channel */
OM_p_OBJECTHDR           p_object_c,    /*  pointer to instance containing  */
                                        /*    the channel.  */
OM_p_CHANSELECT          p_chanselect,  /*  pointer to a channel selector  */
OM_S_OBJID               objid,         /*  object id to search for  */
OMuword                  osnum2,        /*  Object Space number (ISO) of */
                                        /*   the object to search for.  */
OMuint                   *index)        /* index (output)           */


{
   OM_p_CHANNEL_HDR    *p_channel;          /* pointer to channel       */
   int                  sts;                /* status variable          */
   OM_p_CHANNEL_LINK    p_link;             /* pointer to channel link  */
   OM_p_OBJID		p_choid;	    /* restricted channel oid(s)*/
   OMuint               numlinks;           /* number of channel links  */
   OMuint               relindex;           /* relative index           */
   OMuint               absindex;           /* absolute index           */
   OMuword              w_channel_flags;    /* channel flags invariant  */
   OMuword              other_os;           /* ISO - OS  number         */
   OM_S_OBJID           other_objid;        /* ISO - object id          */
   OM_S_CHANNUM         other_channum;      /* ISO - chan number        */
   OMuword              other_w_flags;      /* ISO - flag word          */
   int                 *p_chandata;         /* ptr to channel data      */
   OM_S_BIG_TAIL        tail;               /* channel tail             */
   OM_p_CHANNEL_DEFN    p_chdef;            /* ptr to channel defn      */

   /*---------------------------------*/
   /*  Get a pointer to the channel.  */
   /*---------------------------------*/

   sts = om$get_channel
            (osnum=osnum_c,
             objid=objid_c,
             object=p_object_c,
             p_chanselect=p_chanselect,
             pp_channel=&p_channel,
             pp_chandata=&p_chandata,
             pp_chandef=&p_chdef,
             p_tail=&tail);

   if (!(1&sts)) return (sts);

   if (!(*p_channel)) return (OM_W_NOTONCHAN);

   /*-------------------------------------------------------------*/
   /*  make sure that the channel is either relative or absolute  */
   /*-------------------------------------------------------------*/



   if ( !(p_chdef->p_type->w_flags & (CD_absordered|CD_relordered)))
      return (OM_W_NOTORDERED);

   w_channel_flags = (*p_channel)->flags;
   numlinks = tail.last_index;

   /*-----------------------------------------------------------*/
   /*  Restricted Channel Case:					*/
   /*  loop over all the oids searching for a match with objid  */
   /*-----------------------------------------------------------*/

   if ( w_channel_flags & OM_CH_restricted )
   {
      p_choid = (OM_p_OBJID) p_chandata;

      for (relindex=0, absindex=0; absindex < numlinks; absindex++, p_choid++)
      {
         if (IF_NULL_OBJID(*p_choid)) continue;
  
         if (IF_EQ_OBJID(*p_choid, objid) && (osnum_c == osnum2))
         {
            if (w_channel_flags & OM_CH_absordered)
               *index = absindex;
            else
               *index = relindex;
        
            return (OM_S_SUCCESS);          
         }  
         else
         {
            relindex++;
         }
      }
   }
   else
   {
      /*-----------------------------------------------------------*/
      /*  Not Restricted Channel Case:			           */
      /*  loop over all the links searching for a match for objid  */
      /*-----------------------------------------------------------*/

      p_link = (OM_p_CHANNEL_LINK) p_chandata;

      for (relindex=0, absindex=0; absindex < numlinks; absindex++, p_link++)
      {
         if (IF_NULL_OBJID(p_link->objid)) continue;

         if (p_link->hdr.flags & OM_CL_to_object)
         {
            if (IF_EQ_OBJID(p_link->objid, objid) && (osnum_c == osnum2))
            {
               if (w_channel_flags & OM_CH_absordered)
                  *index = absindex;
               else
                  *index = relindex;
        
               return (OM_S_SUCCESS);          
            }  
            else
            {
               relindex++;
               continue;
            }
         }
         else
         {
            /*-------------------------------*/
            /*  link is connected to an ISO  */
            /*-------------------------------*/  
  
            if (1&(sts=som_ISO_fetch(osnum_c,p_link->hdr.u1.isoindex,
                   p_link->objid, &other_os,&other_objid,&other_channum,
                   &other_w_flags)))
            {
               if ( sts == OM_I_LOGICAL_DISCONNECT ) continue;
             
               if (IF_EQ_OBJID(objid, other_objid) &&  (osnum2 == other_os))
               {
                  if (w_channel_flags & OM_CH_absordered)
                     *index = absindex;
                  else
                     *index = relindex;
 
                  return (OM_S_SUCCESS);
               }
               else
               {
                  relindex++;
                  continue;
               }
            }
            else
            {
               if ( sts == OM_W_OSNOTACTIVE ) continue;
 	       printf("som_get_index: som_ISO_fetch fail\n");
               return (sts);
            }
         }
      }      
   }

   return (OM_W_NOTONCHAN);
}

 

/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++ som_get_objid_at_index */


/*
    Description:

    This routine uses a pointer to a channel to find the objid located at 
    the specified index.

*/

int som_get_objid_at_index(
OMuword                  osnum_c,       /*  os number of the channel  */
OM_S_OBJID               objid_c,       /*  objid containing the channel */
OM_p_OBJECTHDR           p_object_c,    /*  pointer to instance containing  */
                                        /*    the channel.  */
OM_p_CHANSELECT          p_chanselect,  /*  pointer to a channel selector  */
OMuint                   index,         /*  index of objid to return  */
OM_S_OBJID               *objid,        /*  object returned  */
OMuword                  *osnum2)       /*  Object Space number (ISO) of */
                                        /*    the objid returned.  */

{
   OM_p_CHANNEL_HDR    *p_channel;          /* pointer to channel       */
   int                 *p_chandata;         /* pointer to channel data  */
   int                  sts;                /* status variable          */
   OM_p_CHANNEL_LINK    p_link=NULL;        /* pointer to channel link  */
   OM_p_OBJID		p_choid=NULL;	    /* ptr to restricted chan oid*/
   OMuint               numlinks, ii;        /* number of channel links  */
   OMuint               relindex;           /* relative index           */
   OMuword              w_channel_flags;    /* channel flags invariant  */
   OMuword              other_os;           /* ISO - OS  number         */
   OM_S_OBJID           other_objid;        /* ISO - object id          */
   OM_S_CHANNUM         other_channum;      /* ISO - chan number        */
   OMuword              other_w_flags;      /* ISO - flag word          */
   OM_S_BIG_TAIL        tail;
   OM_p_CHANNEL_DEFN    p_chdef;

   /*---------------------------------*/
   /*  Get a pointer to the channel.  */
   /*---------------------------------*/

   sts = om$get_channel
            (osnum=osnum_c,
             objid=objid_c,
             object=p_object_c,
             p_chanselect=p_chanselect,
             pp_channel=&p_channel,
             pp_chandata=&p_chandata,
             pp_chandef=&p_chdef,
             p_tail=&tail);
   
   if (!(1&sts)) return (sts);

   if (!(*p_channel)) 
   {
      *objid = NULL_OBJID;
      *osnum2 = 0;
      return (OM_E_INVINDEX);
   }

   /*-------------------------------------------------------------*/
   /*  make sure that the channel is either relative or absolute  */
   /*-------------------------------------------------------------*/

   if ( !(p_chdef->p_type->w_flags & (CD_absordered|CD_relordered)))
   {
      return (OM_W_NOTORDERED);
   }

   w_channel_flags = (*p_channel)->flags;
   numlinks = tail.last_index;

   /*-----------------------------*/
   /*  Determine type of linkage  */
   /*-----------------------------*/

   if (index >= numlinks)
   {
      /*  index is out of range for this channel  */

      *objid = NULL_OBJID;
      *osnum2 = 0;
      return (OM_E_INVINDEX);
   }
      
   if (w_channel_flags & OM_CH_absordered) 
   {
      if (w_channel_flags & OM_CH_restricted)
      {
         p_choid = (OM_p_OBJID) p_chandata;
         p_choid += index;
      }
      else
      {
         p_link = (OM_p_CHANNEL_LINK) p_chandata;
         p_link += index;
      }
   }
   else	      /* relative ordered channels skip NULL slots
		   in calculating indexing */
   {
      /*  relative ordered channel & restricted  */

      if (w_channel_flags & OM_CH_restricted)
      {
         p_choid = (OM_p_OBJID) p_chandata;
         for (relindex=0, ii=0; ii < numlinks; ii++, p_choid++)
  	 { 
            if ((relindex == index) && (! IF_NULL_OBJID(*p_choid)))
            {
               break;
            }            
            if (! IF_NULL_OBJID(*p_choid))
            {
               relindex++;
            }            
	 }
      }
      else
      {
         p_link = (OM_p_CHANNEL_LINK) p_chandata;
         for (relindex=0, ii=0; ii < numlinks; ii++, p_link++)
         {
            if( (relindex == index) && (! IF_NULL_OBJID(p_link->objid)) )
            {
               break;
            }            
            if (! IF_NULL_OBJID(p_link->objid))
            {
               relindex++;
            }            
         }
      }
      if (relindex != index)
      {
         /*  relative index was out of range  */

         *objid = NULL_OBJID;
         *osnum2 = 0;
         return (OM_E_INVINDEX);
      }
      if (ii == numlinks)
      {
         if (w_channel_flags & OM_CH_restricted)
            --p_choid;
         else
            --p_link;
      }
   }

   /*-------------------------------------------------*/
   /*  First check for NULL objid.  		      */
   /*  Needed for Singleton & Absolute Ordered Cases. */
   /*-------------------------------------------------*/

   if (w_channel_flags & OM_CH_restricted)
   {
      if (IF_NULL_OBJID(*p_choid))
      {
         *objid = NULL_OBJID;
         *osnum2 = 0;
         return (OM_W_INDEXEMPTY);
      }
   }
   else
   {
      if (IF_NULL_OBJID(p_link->objid))
      {
         *objid = NULL_OBJID;
         *osnum2 = 0;
         return (OM_W_INDEXEMPTY);
      }
   }

   /*-------------------------------------------*/
   /*  Determine what the link is connected to  */
   /*-------------------------------------------*/

   if (w_channel_flags & OM_CH_restricted)
   {
      *objid = *p_choid;
      *osnum2 = osnum_c;
      return (OM_S_SUCCESS);
   }
   else
   {
      if (p_link->hdr.flags & OM_CL_to_object)
      {
         *objid = p_link->objid;
         *osnum2 = osnum_c;
         return (OM_S_SUCCESS);
      }
      else
      {
         if (1&(sts=som_ISO_fetch(osnum_c, p_link->hdr.u1.isoindex,
                   p_link->objid, &other_os, &other_objid, &other_channum,
                   &other_w_flags)))
         {
            if ( sts == OM_I_LOGICAL_DISCONNECT )
            {
               *objid = NULL_OBJID;
               *osnum2 = 0;
               return (OM_W_INDEXEMPTY);
            }

            *objid = other_objid;
            *osnum2 = other_os;
            return (OM_S_SUCCESS);
         }
         else
         {
            if ( sts == OM_W_OSNOTACTIVE ) 
	    {
               *objid = NULL_OBJID;
               *osnum2 = 0;
               return (sts);
	    }
	    else
            {
	       printf("som_get_objid_at_index: som_ISO_fetch fail\n");
               return (sts);
            }
         }
      }
   }
}

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++ som_is_oper_equal */


/*
**	om$is_oper_equal is a private macro used by set_operation.
**
**	This routine determines the equivalence of two operands.
**	The two operands are considered equivalent if their osnums,
**	objids, and channels are equal.  The flag equal is set to true
**	if these conditions are met.
*/

int som_is_oper_equal(
OMuword			osnum1,
OMuword                 osnum2,
OM_S_OBJID		objid1,
OM_S_OBJID              objid2,
OM_S_CHANSELECT 	chanselect1,
OM_S_CHANSELECT         chanselect2,
OMbyte			*equal)

{

OM_p_CHANSELECT 	p_greater_chan, p_lesser_chan;
OM_p_OBJID		p_lesser_objid;
OMuword			*p_lesser_osnum;
OM_S_CHANNUM		channum;
OM_p_CHANNEL_HDR	*pp_chanaddr;
int sts;

*equal = 0;

/* Check for equality on osnum and objid */

if ( osnum1 != osnum2 || (!IF_EQ_OBJID(objid1, objid2) ) )
	return( OM_S_SUCCESS );

/* Next, check for equal chanel selectors */

if ( chanselect1.type >= chanselect2.type )
	{
	p_greater_chan = &chanselect1;
	p_lesser_chan = &chanselect2;
	p_lesser_osnum = (OMuword *) &osnum2;
	p_lesser_objid = &objid2;
	}
else
	{
	p_greater_chan = &chanselect2;
	p_lesser_chan = &chanselect1;
        p_lesser_osnum = (OMuword *) &osnum1;
	p_lesser_objid = &objid1;
	}

switch ( (p_greater_chan->type)*3 + p_lesser_chan->type )
{    /* begin switch */

case 0:			/* greater:name & lesser:name */

	if ( strcmp(p_greater_chan->u_sel.name,p_lesser_chan->u_sel.name ))
		{
		return( OM_S_SUCCESS );
		}
	break;

	
case 3:			/* greater:number & lesser:name */

	sts=om$get_channel_number(channame=p_lesser_chan->u_sel.name, p_channum=&channum );
	if (!(sts&1)) return(sts);

	if ((p_greater_chan->u_sel.number.classid != channum.classid) ||
            (p_greater_chan->u_sel.number.number != channum.number))
		{
		return( OM_S_SUCCESS );
		}
	break;

case 4:			/* greater:number & lesser:number */

	if ((p_greater_chan->u_sel.number.classid !=
               p_lesser_chan->u_sel.number.classid) ||
            (p_greater_chan->u_sel.number.number !=
               p_lesser_chan->u_sel.number.number))
		{
		return( OM_S_SUCCESS );
		}
	break;

case 6:	
case 7:			/* greater:addr & lesser:name 
				 | greater:addr & lesser:number */

	sts=om$get_channel(osnum=*p_lesser_osnum, 
		 objid=*p_lesser_objid, 
		 p_chanselect=p_lesser_chan, 
		pp_channel=&pp_chanaddr);
	if (!(sts&1)) return(sts);

	if ( p_greater_chan->u_sel.addr != pp_chanaddr )
		{
		return( OM_S_SUCCESS );
		}
	break;
case 8:			/* greater:addr & lesser:addr */

	if ( p_greater_chan->u_sel.addr != p_lesser_chan->u_sel.addr )	
		{
		return( OM_S_SUCCESS );
		}
	break;

}

*equal = 1;

return( OM_S_SUCCESS );

}


/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++++++ som_parse_channame */


/*   
    Description:

    Separates a channame string into the classname and channel name.

*/

int som_parse_channame (
char           *channame,   /*  Pointer to the channame to parse.  */
char           *s_class,    /*  Array to hold the class name.  */
char           *s_channel)  /*  Array to hold the channel name.  */

{
   char   *p_separator;       /*  Pointer to the separator between the
                                  class name and channel name.  */
   char   separator = '.';    /*  Character used as a separator.  */
   int    ii;                 /*  Loop counter.  */

   /*-----------------------*/
   /*  Find the separator.  */
   /*-----------------------*/
   
   p_separator = (char *) strrchr(channame,separator);

   if (p_separator == NULL)
   {
      /*-------------------------------------------*/
      /*  Channame does not contain a class name.  */
      /*-------------------------------------------*/

      if (s_class != NULL)
      {
         /*  User wanted a class name.  */

         s_class[0] = '\0';
      }

      strncpy (s_channel,channame,OM_K_MAXCHANNEL_LEN);
      return (OM_S_SUCCESS);
   }

   /*--------------------------------------------*/
   /*  Class name and channel name in channame.  */
   /*--------------------------------------------*/

   if (s_class != NULL)
   {
      /*------------------------------*/
      /*  User wants the class name.  */
      /*------------------------------*/

      for (ii=0; ii <  p_separator - channame; ii++)
      {
         s_class[ii] = channame[ii];
         if ( (s_class[ii] == '\0') || (ii == OM_K_MAXCLASS_LEN) )  break;
      }

      if ((s_class[ii] != '\0') && (ii != OM_K_MAXCLASS_LEN))
      {
         s_class[ii] = '\0';
      }
   }

   strncpy(s_channel,p_separator+1,OM_K_MAXCHANNEL_LEN);
   return (OM_S_SUCCESS);
}

		

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++ som_make_chanselect */


/*
    Description:

    Fills in a channel selector structure given a channame string.
    The resulting channel selector will always be of type OM_e_num.
    Using the number type channel selector will improve efficiency
    by avoiding too many conversions from name to number.

*/

int som_make_chanselect (
char              *channame,     /*  Channame string.  */
OM_S_CHANNUM      channum,
OM_p_CHANNEL_HDR  *chanaddr,
OM_p_CHANSELECT   p_chanselect)  /*  Pointer to the resulting channel
                                     selector.  */

{
   OM_S_CHANNUM   my_channum;
   int            sts;

   if ( channame )
   {
      /*---------------------------------------------------------*/
      /*  Always return the number type to reduce the amount of  */
      /*  conversions from names to numbers.                     */
      /*---------------------------------------------------------*/

      p_chanselect->type = OM_e_num;
   
      /*---------------------------*/
      /*  Get the channel number.  */
      /*---------------------------*/

      if (!(1&(sts = om$get_channel_number(channame = channame,
                                           p_channum = &my_channum) )))
      {
         return (sts);
      }

      p_chanselect->u_sel.number = my_channum;
   }
   else if ((channum.number != NULL_CHANNUM.number) ||
            (channum.classid != NULL_CHANNUM.classid))
   {
      p_chanselect->type = OM_e_num;
      p_chanselect->u_sel.number = channum;
   }
   else
   {
      p_chanselect->type = OM_e_addr;
      p_chanselect->u_sel.addr = chanaddr;
   }

   return (OM_S_SUCCESS);

}


int som_get_mychan (
int                 me,
OM_p_CLASSDEF       p_acld,
int                 p_chan,
OM_p_CHANNEL_DEFN  *pp_chandef,
OM_p_CHANNUM        p_channum)
{
   OM_p_MSGMAP        p_msgmap;
   OM_p_CHANNEL_DEFN  p_chdef;
   OMuword            i;

   /*===============================================*/
   /*  determine which component the channel is in  */
   /*===============================================*/

   for (i=0, p_msgmap=p_acld->MsgMap; i<p_acld->NumMsgClasses; ++i, ++p_msgmap)
   {
      if ( me + (int) p_msgmap->offset > p_chan ) break;
   }

   --p_msgmap;
   while (!p_msgmap->offset) --p_msgmap;   /* for classes with no instance */

   /*================================================*/
   /*  determine which channel within the component  */
   /*================================================*/

   for (i=0, p_chdef=p_msgmap->ChanDefns; i<p_msgmap->NumChan; ++i, ++p_chdef)
   {
      if ( p_chan == me + (int) p_msgmap->offset + (int) p_chdef->i_offset)
         break;
   }

   if ( pp_chandef ) *pp_chandef = p_chdef;
   p_channum->classid = p_msgmap->classid;
   p_channum->number  = i;

   return (OM_S_SUCCESS);
}

int som_channel_preset (
OMuword           os,
OM_S_OBJID        oid,
OM_p_CHANSELECT   p_chansel,
OMuint            size)
{
   int                sts;
   OM_S_CONNECT_SIDE  s1;
   OM_S_BIG_TAIL      tail;

   if ( size > (OMuint) OM_Gi_maxchan_size ) return (OM_E_CHAN_OVERFLOW);

   sts = om$connect_build_side ( osnum  = os,
                                 objid  = oid,
                                 chsel  = p_chansel,
                                 relidx = 0,
                                 side   = &s1 );
   if (!(1&sts)) return (sts);

   if ((s1.chdef->p_type->w_flags & CD_restricted) &&  /* res1chan check */
       (s1.chdef->p_type->w_flags & (CD_1_1|CD_m_1)))
   {
      return (OM_S_SUCCESS);
   }

   /*  prevent preset from losing channel data  */

   if ( size <= s1.tail.size ) return (OM_S_SUCCESS);

   tail = s1.tail;

   sts = om$connect_chan_alloc ( side1    = &s1,
                                 num_ents = size );
   if (!(1&sts)) return (sts);

   (*s1.pp_chan)->flags |= OM_CH_preset;

   sts = om$connect_add_tail ( p_chan     = *s1.pp_chan,
                               p_chandata = s1.p_chandata,
                               tail       = &tail );
   if (!(1&sts)) return (sts);

   return (OM_S_SUCCESS);
}

int som_channel_unpreset (
OMuword           os,
OM_S_OBJID        oid,
OM_p_CHANSELECT   p_chansel,
int               collapse_flag)
{
   int                sts;
   int                *p_chandata;
   OM_p_CHANNEL_HDR   *pp_channel;
   OM_p_CHANNEL_DEFN  p_chdef;
   OM_S_BIG_TAIL      tail;

   sts = om$get_channel ( osnum        = os,
                          objid        = oid,
                          p_chanselect = p_chansel,
                          pp_channel   = &pp_channel,
                          pp_chandata  = &p_chandata,
                          pp_chandef   = &p_chdef,
                          p_tail       = &tail );
   if (!(1&sts)) return (sts);

   if ((p_chdef->p_type->w_flags & CD_restricted) &&  /* res1chan check */
       (p_chdef->p_type->w_flags & (CD_1_1|CD_m_1)))
   {
      return (OM_E_INVARG);
   }

   /*=======================================================*/
   /*  test for empty channel - be nice and return SUCCESS  */
   /*  even though it should be returned as INVARG          */
   /*=======================================================*/

   if (! *pp_channel) return (OM_S_SUCCESS);

   if ( (*pp_channel)->flags & OM_CH_preset )
      (*pp_channel)->flags &= (~OM_CH_preset);
   else
      return (OM_E_INVARG);

   if ( collapse_flag ) {
      sts = om$collapse_channel ( osnum      = os,
                                  objid      = oid,
                                  pp_chan    = pp_channel,
                                  chdef      = p_chdef,
                                  p_chandata = p_chandata,
                                  p_tail     = &tail );
      if (!(1&sts)) return (sts);
   }

   return (OM_S_SUCCESS);
}
