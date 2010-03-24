/* OMsibling.C */

#include <stdio.h>
#include "OMobjectcomm.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"

/*=====================================================================*/
/*  this structure is used to record all siblings targeted for send    */
/*=====================================================================*/

typedef struct OSOBJ_pair					/* gja001 */
{
 OMuword	OSnum;		/* Object Space number	*/
 OM_S_OBJID	objid;		/* ID of object		*/
 OM_S_CHANNUM   chnum;		/* incoming channel number */
} S_OSOBJ_PAIR, *p_OSOBJ_PAIR;



/*=================================================================*/
/*  this function performs a shell-sort on a list of OSOBJ_pair's  */
/*=================================================================*/
static void som_sibling_sort(list, size)

 OMuint		size;	/* number of entries to sort */
 p_OSOBJ_PAIR	list;   /* List to be sorted	    */
{
 int 	i, j, k;
#define MAXNUMINTERVALS 15
 int	h[MAXNUMINTERVALS], *hp = h;
 S_OSOBJ_PAIR temp;

 if (size < 2) {
   return;
 }
 j=0;
 for (i=0; i < MAXNUMINTERVALS; i++) {
   *hp++ = j;
   j = (3 * j) + 1;
   if ((OMuint) j >= size ) {
     hp -= 2;
     break;
   }
 }
 if ( i == MAXNUMINTERVALS ) {
   BUGCHECK("som_sibling_send: too many siblings to sort");
   return;
 }
#undef MAXNUMINTERVALS

 for ( ; k = *hp; hp-- ) {
   for ( j = k; (OMuint) j < size; j++ ) {
     i = j - k;
     temp = list[j];
     while ( temp.OSnum < list[i].OSnum  ||
		( temp.OSnum == list[i].OSnum &&
			temp.objid < list[i].objid) ) {
	list[i+k] = list[i];
        i -= k;
	if ( i < 0 ) {
	   break;
	}
     }
     list[i+k] = temp;
   }
 }
 return;
}

/*
-------------------------------------------------------------------------------
Routine Name:	som_sibling_send

Abstract:       This object may be connected to one or more intermediate
		objects via the	specified channel. Each of these intermediate
		objects may be connected to target objects via the same 
		channel that connected them to this object.  Each of
		these targets is considered a "sibling" of this object.

		All such target siblings are gathered into an array and
		the array is sorted by osnum and oid.  The array is then
		traversed sending to each target while skipping duplicates.

                The send may be "inclusive" (send to self also) or "exclusive"
		(send to all but myself).  The sends will be done via the
		function OM_send_object.

Sample Invocation:

som_sibling_send (WRT_flag, message, senderid, channel, minor_chan, inclusive )

Entry Variable Description:

	   OM_E_WRT_FLAG	   WRT_flag	 wrt message or object
           OM_p_MESSAGE            message       message to send
           OM_S_OBJID              senderid      object id of sender
           OM_S_CHANNEL_LINKAGE    channel       channel
           uword                   minor_chan    minor channel number
           OM_E_INC_FLAG           inclusive     inclusive flag 

Exit Variable Description:

           function returns :   OM_S_SUCCESS          successful
                                OM_E_NO_OBJECT_SPACE  no temp storage avail.
                                OM_E_NO_RELATION      no relation for channel
                                OM_I_STOP_SENDING     sends were halted
                                send function returns see OM_send_object
Modules Invoked:

	som_ISO_fetch
	OM_qsort_objids	(look above)

cgp001	19-nov-1985	Use wrt flag.

gja001	21-apr-1986	Added code for ISO processing.

gja002 	23-may-1986	If the target object was on the "FROM" side of a
			relation then any "ISO" contained within relation
			objects pointed to by the target relation where
			not processed.

			Also, the wrong relation links were being processed if
			the target object was on the "FROM" side of a relation
			that was linked to another relation which also had
			links pointing to a relation.

ems001  23-oct-1986     Fixed a bug which caused improper termination of
                         the main send loop.

ems002  03-nov-1986     Changed so as not to terminate main send loop on
                         OM_E_NOSUCHCLASS.

ems003  07-may-1987     Fixed F/A classid bug.

geo001  12-may-1987	Add restricted channel handling.
-------------------------------------------------------------------------------
*/

int som_sibling_send
              ( WRT_flag, message, senderid, p_chansel, inclusive )

OM_E_WRT_FLAG	      WRT_flag;
OM_p_MESSAGE          message;       /*  message to be sent      */
OM_S_OBJID            senderid;      /*  objid of sender         */
OM_p_CHANSELECT	      p_chansel;     /*  points to channel selector */
OM_E_INC_FLAG         inclusive;     /*  inclusive flag */

{
   OM_p_CHANNEL_HDR   *pp_chan1, *pp_chan2;
   OM_p_CHANNEL_HDR   p_chan1, p_chan2;
   int                *p_chandata1, *p_chandata2;
   OM_S_BIG_TAIL      tail1, tail2;
   OM_p_CHANNEL_LINK  p_link1, p_link2;
   OM_p_OBJID         p_choid1, p_choid2;
   OMuint	      nument,  nument2;
   OM_p_CHANNEL_DEFN  p_chdef1, p_chdef2;
   OM_S_CHANSELECT    csel;
   S_OSOBJ_PAIR       last_OSobj;    /* struct describing last obj. sent to */
   p_OSOBJ_PAIR       list, tlist;   /* pointer to array of OS/objid pairs  */
   p_OSOBJ_PAIR       new_list;      /* pointer to new OS/objid array       */
   OMuint             count;         /* count of objids in list             */
   OMuint             list_max;      /* upper bound on list                 */
   OMuint             list_inc;      /* increment factor for expanding list */
   OMuint             i, i2;         /* index variables                     */
   int                sts;           /* status variable                     */
				     /* temporary storage for OS globals    */
   OM_S_CHANNUM	      chan2, chan3;  /* intermediate chan                   */
   OM_S_CHANNUM       my_channum;    /* "mychan"                            */
   OMuword	      flags;	     /* flags returned by ISO fetch	    */
   OM_S_OBJID	      oid2, oid3;
   OMuword	      os2, os3;
   int                c1res1chan;   
   int                c2res1chan;   

   /*=============================*/
   /*  initialize list variables  */
   /*=============================*/

   count = 0;
   list_max = 0;
   list_inc = 100;
   list = NULL;

   /*===========================*/
   /*  develop channel address  */
   /*===========================*/

   if (!(1&(sts = om$get_channel ( objid=senderid, p_chanselect=p_chansel,
                               pp_channel=&pp_chan1, pp_chandef=&p_chdef1,
                               pp_chandata = &p_chandata1, p_tail=&tail1,
                               p_channum = &my_channum ))))
   {
      return (sts);
   }   

   if ( !(*pp_chan1) || !tail1.last_index ) return (OM_S_SUCCESS);

   sts = OM_S_SUCCESS;

   p_chan1 = *pp_chan1;
   nument  = tail1.last_index;

   /*==========================*/
   /*  loop  to find siblings  */
   /*  channel is RESTRICTED   */
   /*==========================*/

   if (p_chdef1->p_type->w_flags & CD_restricted)
   {
    os2 = OM_Gw_current_OS;
    chan2 = p_chdef1->p_type->channum;
    p_choid1 = (OM_p_OBJID) p_chandata1;
    if (p_chdef1->p_type->w_flags & (CD_1_1|CD_m_1))
       c1res1chan = 1;
    else
       c1res1chan = 0;
    for (i=0; i < nument; i++, p_choid1++)
    {
      if ( IF_NULL_OBJID(*p_choid1))
      {
	continue;
      }
      if (c1res1chan)
         oid2 = *p_choid1 >> 1;
      else
         oid2 = *p_choid1;
      /*===========================================*/
      /* convert channel number to channel address */
      /*===========================================*/

      csel.type = OM_e_num;
      csel.u_sel.number = chan2;

      sts = om$get_channel ( osnum        = os2,
                             objid        = oid2,
                             p_chanselect = &csel,
                             pp_channel   = &pp_chan2,
                             pp_chandef   = &p_chdef2,
                             pp_chandata  = &p_chandata2,
                             p_tail       = &tail2 );
      if (!(1&sts)) return (sts);

     /*===================================================*/
     /*  loop over intermediate channel to find siblings  */
     /*===================================================*/

     p_chan2 = *pp_chan2;	
     nument2 = tail2.last_index;             /* this channel can't be empty */

     /*=============================*/
     /* chan2 is restricted channel */
     /*=============================*/
     if (p_chdef2->p_type->w_flags & CD_restricted)
     {
      os3 = os2;
      chan3 = p_chdef2->p_type->channum;
      p_choid2 = (OM_p_OBJID) p_chandata2;
      if (p_chdef2->p_type->w_flags & (CD_1_1|CD_m_1))
         c2res1chan = 1;
      else
         c2res1chan = 0;
      for (i2=0; i2 < nument2; i2++, p_choid2++)
      {
       if ( IF_NULL_OBJID(*p_choid2))
       {
 	 continue;
       }
       if (c2res1chan)
          oid3 = *p_choid2 >> 1;
       else
          oid3 = *p_choid2;

       /*=================================================================*/
       /* objid to the list (unless its this)- expand the list if needed  */
       /*=================================================================*/

       if (IF_EQ_OBJID(oid3,senderid) && (os3 == OM_Gw_current_OS)) {
	 continue;
       }
       if ( count == list_max )
       {
	 list_max = list_max + list_inc;
	 new_list = (p_OSOBJ_PAIR) 
			om$malloc(size=list_max*sizeof(S_OSOBJ_PAIR));
	 if ( new_list == NULL ) {
	   return (OM_E_NODYNMEM);
	 }
	 if (count) { 
	   OM_BLOCK_MOVE(list,new_list,count*sizeof(S_OSOBJ_PAIR));
	   om$dealloc (ptr=(char *)list);
         }
	 list = new_list;
       }
       list[count].OSnum   = os3;
       list[count].chnum   = chan3;
       list[count++].objid = oid3;
      }  /* end for over "intermediate" channel */
     }  /* end for restricted channel */
     else  /* not restricted channel */
     {
      p_link2 = (OM_p_CHANNEL_LINK) p_chandata2;
      for (i2=0; i2 < nument2; i2++, p_link2++)
      {
       if ( IF_NULL_OBJID(p_link2->objid))
       {
 	 continue;
       }
       if (p_link2->hdr.flags & OM_CL_to_object) 
       {
	 os3 = os2;
	 oid3 = p_link2->objid;
	 chan3 = p_link2->channum;
         chan3.classid = OM_GA_OSDs[os3]->FilToAct[chan3.classid];
       }
       else /* to an ISO */
       {
	 sts = som_ISO_fetch(os2, p_link2->hdr.u1.isoindex,
			p_link2->objid,&os3,&oid3,&chan3,&flags);
         if (sts == OM_I_LOGICAL_DISCONNECT ||
             sts == OM_W_OSNOTACTIVE) continue;
	 if (sts != OM_S_SUCCESS) 
	 {
	    return(sts);
         }
       }

       /*=================================================================*/
       /* objid to the list (unless its this)- expand the list if needed  */
       /*=================================================================*/

       if (IF_EQ_OBJID(oid3,senderid) && (os3 == OM_Gw_current_OS)) {
	 continue;
       }
       if ( count == list_max )
       {
	 list_max = list_max + list_inc;
	 new_list = (p_OSOBJ_PAIR) 
			om$malloc(size=list_max*sizeof(S_OSOBJ_PAIR));
	 if ( new_list == NULL ) {
	   return (OM_E_NO_OBJECT_SPACE);
	 }
	 if (count) { 
	   OM_BLOCK_MOVE(list,new_list,count*sizeof(S_OSOBJ_PAIR));
	   om$dealloc (ptr=(char *)list);
         }
	 list = new_list;
       }
       list[count].OSnum   = os3;
       list[count].chnum   = chan3;
       list[count++].objid = oid3;
      }  /* end for over "intermediate" channel */
     }  /* end if channel is not restricted */
    }  /* end for over "this" channel */
   }  /* channel is restricted */
   /*============================*/
   /*  loop  to find siblings    */
   /*  channel is NOT RESTRICTED */
   /*============================*/

   else
   {
    p_link1 = (OM_p_CHANNEL_LINK) p_chandata1;
    for (i=0; i < nument; i++, p_link1++)
    {
      if ( IF_NULL_OBJID(p_link1->objid))
      {
	continue;
      }
      if (p_link1->hdr.flags & OM_CL_to_object) 
      {
	os2 = OM_Gw_current_OS;
	oid2 = p_link1->objid;
	chan2 = p_link1->channum;
        chan2.classid = OM_GA_OSDs[os2]->FilToAct[chan2.classid];
      }
      else /* to an ISO */
      {
	sts = som_ISO_fetch(OM_Gw_current_OS, p_link1->hdr.u1.isoindex,
			p_link1->objid,&os2,&oid2,&chan2,&flags);
        if (sts == OM_I_LOGICAL_DISCONNECT ||
            sts == OM_W_OSNOTACTIVE) continue;
	if (sts != OM_S_SUCCESS) {
	   return(sts);
        }
      }
         /*===========================================*/
         /* convert channel number to channel address */
         /*===========================================*/

      csel.type = OM_e_num;
      csel.u_sel.number = chan2;

      sts = om$get_channel ( osnum        = os2,
                             objid        = oid2,
                             p_chanselect = &csel,
                             pp_channel   = &pp_chan2,
                             pp_chandef   = &p_chdef2,
                             pp_chandata  = &p_chandata2,
                             p_tail       = &tail2 );
      if (!(1&sts)) return (sts);

     /*===================================================*/
     /*  loop over intermediate channel to find siblings  */
     /*===================================================*/

     p_chan2 = *pp_chan2;	
     nument2 = tail2.last_index;

     /*=============================*/
     /* chan2 is restricted channel */
     /*=============================*/
     if (p_chdef2->p_type->w_flags & CD_restricted)
     {
      os3 = os2;
      chan3 = p_chdef2->p_type->channum;
      p_choid2 = (OM_p_OBJID) p_chandata2;
      if (p_chdef2->p_type->w_flags & (CD_1_1|CD_m_1))
        c2res1chan = 1;
      else
        c2res1chan = 0;
      for (i2=0; i2 < nument2; i2++, p_choid2++)
      {
       if ( IF_NULL_OBJID(*p_choid2))
       {
 	 continue;
       }
       if (c2res1chan)
          oid3 = *p_choid2 >> 1;
       else
          oid3 = *p_choid2;

       /*=================================================================*/
       /* objid to the list (unless its this)- expand the list if needed  */
       /*=================================================================*/

       if (IF_EQ_OBJID(oid3,senderid) && (os3 == OM_Gw_current_OS)) {
	 continue;
       }
       if ( count == list_max )
       {
	 list_max = list_max + list_inc;
	 new_list = (p_OSOBJ_PAIR) 
			om$malloc(size=list_max*sizeof(S_OSOBJ_PAIR));
	 if ( new_list == NULL ) {
	   return (OM_E_NO_OBJECT_SPACE);
	 }
	 if (count) { 
	   OM_BLOCK_MOVE(list,new_list,count*sizeof(S_OSOBJ_PAIR));
	   om$dealloc (ptr=(char *)list);
         }
	 list = new_list;
       }
       list[count].OSnum   = os3;
       list[count].chnum   = chan3;
       list[count++].objid = oid3;
      }  /* end for over "intermediate" channel */
     }  /* end if channel is restricted */
     else  /* not restricted channel */
     {
      p_link2 = (OM_p_CHANNEL_LINK) p_chandata2;
      for (i2=0; i2 < nument2; i2++, p_link2++)
      {
       if ( IF_NULL_OBJID(p_link2->objid))
       {
 	 continue;
       }
       if (p_link2->hdr.flags & OM_CL_to_object) 
       {
	 os3 = os2;
	 oid3 = p_link2->objid;
	 chan3 = p_link2->channum;
         chan3.classid = OM_GA_OSDs[os3]->FilToAct[chan3.classid];
       }
       else /* to an ISO */
       {
	 sts = som_ISO_fetch(os2, p_link2->hdr.u1.isoindex,
			p_link2->objid,&os3,&oid3,&chan3,&flags);
         if (sts == OM_I_LOGICAL_DISCONNECT ||
             sts == OM_W_OSNOTACTIVE) continue;
	 if (sts != OM_S_SUCCESS) 
	 {
	    return(sts);
         }
       }

       /*=================================================================*/
       /* objid to the list (unless its this)- expand the list if needed  */
       /*=================================================================*/

       if (IF_EQ_OBJID(oid3,senderid) && (os3 == OM_Gw_current_OS)) {
	 continue;
       }
       if ( count == list_max )
       {
	 list_max = list_max + list_inc;
	 new_list = (p_OSOBJ_PAIR) 
			om$malloc(size=list_max*sizeof(S_OSOBJ_PAIR));
	 if ( new_list == NULL ) {
	   return (OM_E_NO_OBJECT_SPACE);
	 }
	 if (count) { 
	   OM_BLOCK_MOVE(list,new_list,count*sizeof(S_OSOBJ_PAIR));
	   om$dealloc (ptr=(char *)list);
         }
	 list = new_list;
       }
       list[count].OSnum   = os3;
       list[count].chnum   = chan3;
       list[count++].objid = oid3;
      }  /* end for over "intermediate" channel */
     }  /* end if channel is not restricted */
    }  /* end for over "this" channel */
   } /* channel is not restricted */

   /*=================*/
   /*  sort the list  */
   /*=================*/
   
   som_sibling_sort ( list, count );

   /*=====================================================*/
   /*  sequentially process the list ignoring duplicates  */
   /*=====================================================*/

   last_OSobj.OSnum = OM_Gw_current_OS;
   last_OSobj.objid = NULL_OBJID;

   sts = OM_S_SUCCESS;
   tlist = list;
   for ( i=0; i < count; i++, tlist++ )
   {
     if (IF_EQ_OBJID(tlist->objid, last_OSobj.objid) &&
		     	 (tlist->OSnum == last_OSobj.OSnum )) {
	continue;   /* skip duplicates */
     }

     if( tlist->OSnum != OM_Gw_current_OS ) {
       sts = om$send_foreign ( mode=WRT_flag, msg=message, senderid=senderid,
                               targetid=tlist->objid, targetos=tlist->OSnum,
                               channum=tlist->chnum);
     }
     else {  /* in same object space */
       sts = om$send_obj_int ( mode=WRT_flag, msg=message, senderid=senderid,
                               targetid=tlist->objid, channum=tlist->chnum);
     }
     if ((sts == OM_I_STOP_SENDING) || ((!(1&sts)) && (sts & SEV_LEV)) &&
         (sts != OM_E_NOSUCHCLASS)) {
        om$dealloc ( ptr=(char *)list );
	return(sts);
     }
     last_OSobj = *tlist;
   }
   if ( list != NULL ) {
     om$dealloc ( ptr=(char *)list );
   }

   /*===================================*/
   /*  send to this object if inclusive */
   /*===================================*/

   if (inclusive == OM_e_inclusive) {
       sts = om$send_obj_int ( mode=WRT_flag, msg=message, senderid=senderid,
                               targetid=senderid, channum=my_channum);
   }
   return (sts);
}
