/*
---------------------------------------------------------------------------

	Name:			OMmacros.h
	Author:			Chuck Puckett
	Creation Date:		24-aug-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	Contains various operational macros.

	Revision History:  

ems001  11-07-85  Add OM_BLOCK_MOVE.

jhm001  11-08-85  Add OM_FIND_ENTRY and OM_FIND_REL_ENTRY.

cgp001	14-nov-1985	move CONVERT_OBJID to OMobjid.h

cgp002	4-feb-1986	add BUGCHECK macro

kek001  14-apr-1986     remove unused int dummy from OM_GET_CHAN_PTR
			change p_list name in OM_FIND_ENTRY and
			OM_FIND_REL_ENTRY

gja001	17-apr-1086	added OM_SEND_VIA_ISO

cgp003	18-may-1986	add OMWARNING macro

ems002  27-jun-1986     4.0 mods - remove OM_FIND_ENTRY and OM_FIND_REL_ENTRY

ems003  15-jul-1986     Move contents of OMobjid.h here.

ems004  22-jul-1986     Removed old macros (GET_INSTANCE, GET_ACLD_FROM_ME...)

ems005  13-nov-1986     Made OM_SEND_VIA_ISO check for logical disconnection
                         return from som_ISO_fetch.

ems006  19-nov-1986     Changed order of args to blkmv macro - count first.

ems007  06-mar-1987     Added move_data flag to set dimension macros.
                        
rme001  22-sep-1987     Changed the parameters to vla set dimension.

geo001	24-nov-1987	Add status macros for state of object;
			filed, swapped, or in memory.
			
geo002	01-dec-1987	Add status and manipulate macros for object
			header flag bits (lower 2 bits of size)

geo003	10-mar-1988	Add macros to identify an object's logical cluster
			number, to report if any pcd of an lcd is in memory
			and to report number of freebytes an lcd has. 
			Construct via rtree needs these.
---------------------------------------------------------------------------
*/

#ifndef	OM_D_MACROS
#define	OM_D_MACROS	1

#ifndef OM_D_CLUSTER
#include	"OMcluster.h"
#endif

/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int blkmv __((int n, char *s, char *d));
extern int som_ISO_fetch __((OMuword OSnum1, OMuword index,
		OM_S_OBJID iso_objid, OMuword *OSnum2, OM_S_OBJID *objid,
		OM_p_CHANNUM chan, OMuword *flags));
extern int som_vla_set_dimension __((int *p_offset, unsigned int *p_count,
		OMuint dim, OMuword osnum, OM_S_OBJID objid,
		OM_p_CLASSDEF p_acld, int move_data));

#if defined(__cplusplus)
}
#endif

/*----------------------------------------------------------------------------*/

#define REPORT_OM_ERR(sts1) if (!(1&sts1)) om$report_error (sts=sts1)

#define OM_BLOCK_MOVE(S,D,N) blkmv(N, (char *) (S), (char *) (D))

#define OM_SET_DIMENSION(varray,size) \
   som_vla_set_dimension(&(varray##_descr.i_offset),&(varray##_descr.i_count),(size),(OM_Gw_current_OS),(my_id),(p_ACLD),1)

#define OM_DIMENSION_OF(varray)  varray##_descr.i_count

#define SOM_SET_DIMENSION(varray,size,osnum,objid,p_cld,move_data) \
   som_vla_set_dimension(&(varray##_descr.i_offset),&(varray##_descr.i_count),(size),(osnum),(objid),(p_cld),(move_data))

#define SOM_DIMENSION_OF(varray)  varray##_descr.i_count

#define	OM_K_CHANNEL_SIZE	sizeof (struct OM_sd_channel_linkage)


#define OMWARNING(msg) if (OM_Gf_verbose_warning) printf(msg)
#define OMWARNING1(msg, arg1) if (OM_Gf_verbose_warning) printf(msg, arg1)
#define OMWARNING2(msg, arg1, arg2) if (OM_Gf_verbose_warning) \
 printf(msg, arg1, arg2)
#define OMWARNING3(msg, arg1, arg2, arg3) if (OM_Gf_verbose_warning) \
 printf(msg, arg1, arg2, arg3)

#define OMERRMSG(msg) if (OM_Gf_verbose_error) printf(msg)
#define OMERRMSG1(msg, arg1) if (OM_Gf_verbose_error) printf(msg, arg1)
#define OMERRMSG2(msg, arg1, arg2) if (OM_Gf_verbose_error) \
 printf(msg, arg1, arg2)
#define OMERRMSG3(msg, arg1, arg2, arg3) if (OM_Gf_verbose_error) \
 printf(msg, arg1, arg2, arg3)

#define BUGCHECK(msg) \
{ int ii=0;\
if (OM_Gf_bugcheck_fatal) printf ("OM-F-FATAL_BUGCHECK: \n"); \
else printf ("OM-F-BUGCHECK: \n"); \
printf("At line %d of OM source file: %s\n",__LINE__,__FILE__); \
printf (msg); \
printf ("\n"); \
printf ("\n"); \
if (OM_Gf_bugcheck_fatal) OM_Gf_bugcheck_fatal = OM_Gf_bugcheck_fatal/ii; \
}


#define OM_SEND_VIA_ISO(WRT_flg, message, senderid, ISO_obj, ISO_ndx, status) \
{									\
 OMuword	OSnum2, FLAGS;		     				\
 OM_S_CHANNUM   CHAN;                     				\
 OM_S_OBJID	OBJID;							\
 									\
 (status) = som_ISO_fetch( OM_Gw_current_OS, ISO_ndx, ISO_obj, 		\
			&OSnum2, &OBJID, &CHAN, &FLAGS );		\
 if ((status)==OM_I_LOGICAL_DISCONNECT)                                 \
 {                                                                      \
    (status) = OM_S_SUCCESS;                                            \
 }                                                                      \
 else                                                                   \
 {                                                                      \
    if( (status) & 1 )							\
    {                                                                   \
      (status) = om$send_foreign (mode=WRT_flg, msg=message,            \
                 senderid=senderid, targetid=OBJID, targetos=OSnum2,    \
                 channum=CHAN);                                         \
    }									\
 }                                                                      \
}

#define	IF_EQ_OBJID(obj1, obj2) ((obj1) == (obj2))

#define IF_NULL_OBJID(objid) (((OMuint) (objid)) == NULL_OBJID)

#define OM_GET_TAIL(p_chan,tail) 	\
{					\
  OMuword           flags;		\
  OMuword           link_size;		\
  OM_p_LITTLE_TAIL  p_ltail;            \
  register OMuint             i;       	\
  register OM_p_CHANNEL_LINK  p_link;   \
  register OM_p_OBJID         p_oid;    \
					\
  flags = ((OM_p_CHANNEL_HDR)(p_chan))->flags; 	\
						\
  if (flags & OM_CH_tail_exists) {              \
    if (flags & OM_CH_bigchan) {                \
      (tail) = *((OM_p_BIG_TAIL)((OMuint)(p_chan)+sizeof(OM_S_CHANNEL_HDR))); \
    }						\
    else {					\
      if (flags & OM_CH_restricted)		\
        link_size = sizeof(OM_S_OBJID);		\
      else					\
        link_size = sizeof(OM_S_CHANNEL_LINK);	\
						\
      p_ltail= ((OM_p_LITTLE_TAIL)((OMuint)(p_chan)+sizeof(OM_S_CHANNEL_HDR)+ \
      (((OM_p_CHANNEL_HDR)(p_chan))->u1.count-1) * link_size) ); \
      (tail).last_index = p_ltail->last_index;                 \
      (tail).collapse_count = p_ltail->collapse_count;         \
      (tail).size = ((OM_p_CHANNEL_HDR)(p_chan))->u1.count;    \
    }							       \
  }							       \
  else {						       \
    (tail).last_index = ((OM_p_CHANNEL_HDR)(p_chan))->u1.count;\
    (tail).collapse_count = 0;			       	       \
    (tail).size = ((OM_p_CHANNEL_HDR)(p_chan))->u1.count;      \
    if (flags & OM_CH_collapse_count) {                        \
      if (flags & OM_CH_restricted) {                          \
        p_oid = (OM_p_OBJID) ((OMuint)p_chan + sizeof(OM_S_CHANNEL_HDR));\
        for (i=0;i<(tail).last_index;++i,++p_oid)	       \
          if (IF_NULL_OBJID(*p_oid)) ++(tail).collapse_count;  \
      }							       \
      else { 						       \
        p_link=(OM_p_CHANNEL_LINK)((OMuint)p_chan + sizeof(OM_S_CHANNEL_HDR));\
        for (i=0;i<(tail).last_index;++i,++p_link)	       \
          if (IF_NULL_OBJID(p_link->objid)) ++(tail).collapse_count;  \
      }							       \
    }                                                          \
  }							       \
}								

#define OM_PTR_TO_CHAN_LINK(p_chan) \
    (((p_chan)->flags & OM_CH_bigchan)\
      ? ((OM_p_CHANNEL_LINK)((OMuint)(p_chan) + sizeof(OM_S_CHANNEL_HDR) + \
                                                sizeof(OM_S_BIG_TAIL))) \
      : ((OM_p_CHANNEL_LINK)((OMuint)(p_chan) + sizeof(OM_S_CHANNEL_HDR))))

#define OM_PTR_TO_RESCHAN_LINK(p_chan) \
    (((p_chan)->flags & OM_CH_bigchan)\
      ? ((OM_p_OBJID)((OMuint)(p_chan) + sizeof(OM_S_CHANNEL_HDR) + \
                                         sizeof(OM_S_BIG_TAIL))) \
      : ((OM_p_OBJID)((OMuint)(p_chan) + sizeof(OM_S_CHANNEL_HDR))))


#define OM_PTR_TO_RESONECHAN(p_chan) (p_chan)

/*=========================================================*/
/* Status of Object: input spacemap flags and evaluates to */
/* true if it is that status else evaluates to false.      */
/* 1 macro for each of 4 possible states.                  */
/*=========================================================*/

#define OM_OBJ_IN_MEM(flags)	\
  (flags & OM_SM_in_use && flags & OM_SM_in_mem)

#define OM_OBJ_IN_FILE(flags)   \
  (flags & OM_SM_in_use && !(flags & OM_SM_in_mem))

#define OM_OBJ_INVALID(flags)    \
  (!(flags & OM_SM_in_use) && !(flags & OM_SM_in_mem))

#define OM_IS_RESIDENT(osnum, objid) \
   OM_OBJ_IN_MEM(OM_GA_OSDs[(osnum)]->Spacemap[(objid)].flags)

/*============================================================*/
/* Status of ObjectHeader flag bits: input object header size */
/* and evaluates to true if bit is set else evaluates to      */
/* false.   set and clear macros do that operation for the    */
/* indicated bit. 			                      */
/*============================================================*/

#define OM_OBJ_HAS_VLA(hdrsize)	\
  ((hdrsize) & OM_OHf_has_VLA)

#define OM_SET_OBJ_HAS_VLA(hdrsize)	\
  (hdrsize) = (hdrsize) | OM_OHf_has_VLA;

#define OM_CLEAR_OBJ_HAS_VLA(hdrsize)	\
  (hdrsize) = (hdrsize) & ~OM_OHf_has_VLA;

#define OM_OBJ_IS_TAGGED(hdrsize)	\
  (hdrsize & OM_OHf_is_tagged)

#define OM_SET_OBJ_IS_TAGGED(hdrsize)	\
  (hdrsize) = (hdrsize) | OM_OHf_is_tagged;

#define OM_CLEAR_OBJ_IS_TAGGED(hdrsize)	\
  (hdrsize) = (hdrsize) & ~OM_OHf_is_tagged;

        /*=================================================*/
        /* object header's size field should ignore the    */
        /* lower 3 bits since they are used for flag  bits */
        /* as noted in OMminimum.h and compress uses 1.    */
        /*=================================================*/

        /* following macro looks at size value; without lower 3 bits */

#define OM_GETOBJSIZE(objsize) ( (objsize) & 0x7ffffff8 )

#define OM_ALIGN_OBJECT_SIZE(size) (((int)(size)+7)&((int)~7))

#define OM_GETLOW3BITS(x) (x & 0x00000007)

#define OM_SETLOW3BITS(x,y) (x = x | y)

/*============================================================*/
/* Macros needed by construct via rtree, to assist finding a  */
/* logical cluster in which to construct new object.          */
/* GetLogicalCluster uses an osnum/objid pair and reports     */
/* its logical cluster number (an OMuword).		      */
/* ClusterInMem uses logical cluster number and osnum to      */
/* report T/F whether it has any physical clusters in memory. */
/* LcdFreeSize uses osnum and logical cluster number to       */
/* report the number of free bytes in the logical cluster.    */
/*============================================================*/

#define OM_GET_LOGICAL_CLUSTER(osnum,oid,clustnum)	\
{							\
 if( OM_OBJ_IN_MEM(OM_GA_OSDs[(osnum)]->Spacemap[(oid)].flags) ) \
    (clustnum) = OM_GA_CSDarray[OM_GA_OSDs[(osnum)]->Spacemap[(oid)].sdi].p_pcd->p_lcd->w_cluster_num; \
 else	\
 {	\
    if( OM_OBJ_IN_FILE(OM_GA_OSDs[(osnum)]->Spacemap[(oid)].flags) ) \
        (clustnum) = OM_GA_OSDs[(osnum)]->Spacemap[(oid)].state.filed_obj.clusterid; \
    else \
	(clustnum) = OM_K_NOTACLUSTER; \
 }	\
}

#define OM_CLUSTER_IN_MEM(osnum,lcn,state) \
{		\
 OM_p_PCD	pcd;  \
 			\
 (state) = FALSE;	\
 if(! OM_QUEUE_EMPTY(OM_GA_OSDs[(osnum)]->Clusters[(lcn)]->pcdq_lh.next) ) \
 {	\
   pcd = (OM_p_PCD)(OM_GA_OSDs[(osnum)]->Clusters[(lcn)]->pcdq_lh.next); \
   while (pcd != (OM_p_PCD)(&(OM_GA_OSDs[(osnum)]->Clusters[(lcn)]->pcdq_lh)))\
   {	\
     if( (! pcd->p_lump) && pcd->p_csd ) \
     {	\
	(state) = TRUE;	\
	break; \
     } \
     else \
        pcd = (OM_p_PCD)(pcd->pcdq.next); \
   }	\
 }	\
}

#define OM_LCD_FREE_SIZE(osnum,lcn,freebytes) \
{	\
 OM_p_PCD	pcd;	\
 OM_p_LCD	lcd;	\
 			\
 (freebytes) = NULL;				\
 lcd = OM_GA_OSDs[(osnum)]->Clusters[(lcn)];	\
 pcd = lcd->pcdq_lh.next;			\
 while(pcd != &(lcd->pcdq_lh.next))		\
 {						\
  (freebytes) += pcd->i_totalfree;		\
  pcd = pcd->pcdq.next;				\
 }						\
}


/*===========================================================*/
/*  macros to set and reset the DI name bit in the spacemap  */
/*===========================================================*/

#define OM_DI_SET(os,oid) OM_GA_OSDs[(os)]->Spacemap[(oid)].flags|=OM_SM_has_di_name;

#define OM_DI_RESET(os,oid) OM_GA_OSDs[(os)]->Spacemap[(oid)].flags&=(~OM_SM_has_di_name);


/*==========================================*/
/* Doubly-Linked Queue Macros */
/*==========================================*/

  /* Args: ptr to queue listhead, size to grow, 
	structure type of queue element, queue field name within structure */
#define	OM_GROW_QUEUE(listhead, growsize, sd, field) \
{ \
  sd	*p_tmp; \
  if(!(((OM_p_DLINK)(listhead))->next=(OM_p_DLINK)om$malloc(size=(growsize)*sizeof(sd)))) \
    return(OM_E_NODYNMEM); \
  for(p_tmp=(sd *)((OM_p_DLINK)(listhead))->next; \
      p_tmp < ((sd *)((OM_p_DLINK)(listhead))->next)+(growsize); \
      p_tmp++) \
  { \
    p_tmp->field.next = ((OM_p_DLINK) &((p_tmp+1)->field.next)); \
    p_tmp->field.prev = ((OM_p_DLINK) &((p_tmp-1)->field.next)); \
  } \
  (char *)(((OM_p_DLINK)(listhead))->next) += OM_SD_FIELD_OFFSET(sd, field); \
  ((OM_p_DLINK)(listhead))->prev = ((OM_p_DLINK) &((p_tmp-1)->field.next)); \
  ((OM_p_DLINK)(listhead))->prev->next = ((OM_p_DLINK)(listhead)); \
  ((OM_p_DLINK)(listhead))->next->prev = ((OM_p_DLINK)(listhead)); \
}

 /* Args: ptr to queue listhead, ptr to DLINK of element to be queued */

#define	OM_QUEUE_AT_TAIL(listhead, element) \
{ \
  ((OM_p_DLINK)(element))->prev = ((OM_p_DLINK)(listhead))->prev; \
  ((OM_p_DLINK)(element))->next = ((OM_p_DLINK)(listhead));       \
  ((OM_p_DLINK)(listhead))->prev->next = ((OM_p_DLINK)(element)); \
  ((OM_p_DLINK)(listhead))->prev = ((OM_p_DLINK)(element));       \
}

 /* Args: ptr to queue listhead, ptr to DLINK of element to be queued */

#define	OM_QUEUE_AT_HEAD(listhead, element) \
{ \
  ((OM_p_DLINK)(element))->prev = ((OM_p_DLINK)(listhead));   	\
  ((OM_p_DLINK)(element))->next = ((OM_p_DLINK)(listhead))->next; \
  ((OM_p_DLINK)(listhead))->next->prev = ((OM_p_DLINK)(element)); \
  ((OM_p_DLINK)(listhead))->next = ((OM_p_DLINK)(element));       \
}

 /* Args: ptr to queue listhead, ptr to DLINK of element to be dequeued */
 /* The first element on the queue is dequeued and
    its ptr to DLINK is placed in element */

#define	OM_DEQUEUE_FROM_HEAD(listhead, element, type) \
{ \
    (element) = (type) (((OM_p_DLINK)(listhead))->next);	\
    ((OM_p_DLINK)(listhead))->next = ((OM_p_DLINK)(element))->next;	\
    ((OM_p_DLINK)(element))->next->prev = ((OM_p_DLINK)(listhead)); \
    ((OM_p_DLINK)(element))->next = ((OM_p_DLINK)(element))->prev = NULL; \
}

 /* Args: ptr to queue listhead, ptr to DLINK of element to be dequeued */
 /* The last element on the queue is dequeued and
    its ptr to DLINK is placed in element */

#define	OM_DEQUEUE_FROM_TAIL(listhead, element) \
{ \
    (element) = ((OM_p_DLINK)(listhead))->prev;	\
    ((OM_p_DLINK)(listhead))->prev = ((OM_p_DLINK)(element))->prev;	\
    ((OM_p_DLINK)(element))->prev->next = ((OM_p_DLINK)(listhead)); \
    ((OM_p_DLINK)(element))->next = ((OM_p_DLINK)(element))->prev = NULL; \
}

 /* Arg: ptr to DLINK of element to be dequeued */
 /* Element is dequeued */
    
#define	OM_DEQUEUE_ELEMENT(element) \
{ \
    ((OM_p_DLINK)(element))->prev->next = ((OM_p_DLINK)(element))->next; \
    ((OM_p_DLINK)(element))->next->prev = ((OM_p_DLINK)(element))->prev; \
    ((OM_p_DLINK)(element))->next = ((OM_p_DLINK)(element))->prev = NULL; \
}

 /* Arg: ptrs to DLINK of element to queue to and element to be queued */
 /* Element is queued */
    
#define	OM_QUEUE_ELEMENT(toelement, element) \
{ \
    ((OM_p_DLINK)(element))->next = ((OM_p_DLINK)(toelement))->next; \
    ((OM_p_DLINK)(toelement))->next->prev = ((OM_p_DLINK)(element)); \
    ((OM_p_DLINK)(toelement))->next = ((OM_p_DLINK)(element)); \
    ((OM_p_DLINK)(element))->prev = ((OM_p_DLINK)(toelement)); \
}

 /* Returns True when queue is empty.  Args: ptr to queue listhead */

#define OM_QUEUE_EMPTY(listhead) \
  ( (((OM_p_DLINK)(listhead)) == ((OM_p_DLINK)(listhead))->next) && \
    (((OM_p_DLINK)(listhead)) == ((OM_p_DLINK)(listhead))->prev))

 /* Prints Listhead and dlink elements in queue */
 
#define OM_PRINT_QUEUE(listhead) \
{ \
  OM_p_DLINK	tmp=listhead->next; \
  printf("\nListHead  next: %8x  prev: %8x",listhead->next,listhead->prev); \
  while( tmp != listhead ) \
  { \
    printf("\n          next: %8x  prev: %8x",tmp->next,tmp->prev); \
    tmp = tmp->next; \
  } \
}

#define	PMSPRNT(pt) if (!OMpms_prnt pt) return (0)
#define	PMSPRNTHDR(pt) if (!OMpms_prntHdr pt) return (0)

#endif
