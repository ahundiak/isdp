#include <stdio.h>
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMcluster.h"

extern int som_aligned_vla_size();

extern OMuword Root_OPP_delete_method_index;
extern OMuword Root_OPP_wild_disconnect_method_index;

void display_vla_descr( p_descr, type )
	OM_p_VARLENARR_DESCR p_descr;
	OMbyte type;			/* 1 - Channel */

{

printf("\n***** VARLENARR DESCR *****\n");
printf("  &descr  :	%d\n",p_descr);
if ( type )
   { 
   printf("  VLA is Channel\n");
   printf("  p_chan_hdr:	%x\n", p_descr->i_offset);
   }
else
   {
   printf("  i_offset:	%x\n",p_descr->i_offset);
   printf("  i_count :	%d\n",p_descr->i_count);
   }
printf("***************************\n\n");

}


void display_vla_defn( num, p_defns )
	OMuword	num;
	OM_p_VARLENARR_DEFN	p_defns;

{

OMuword i;

printf("\n***** VARLENARR DEFNS *****\n");
for (i=0; i<num; i++)
   {
   printf("         --- Entry %d ---\n", i);
   printf("   w_offset      : %d\n", p_defns[i].w_offset);
   printf("   w_count       : %d\n", p_defns[i].w_count);
   printf("   w_per_elt_size: %d\n", p_defns[i].w_per_elt_size);
   printf("   type	    : %d\n", p_defns[i].type);
   }
printf("***************************\n\n");

}


som_change_class(
OMuword		osnum,
OM_S_OBJID	objid,
char 	       	*classname,
OMuint          sd_override)
{

OMuword		old_classid, new_classid, sv_flags;
OMuint		align_size;
OMuint          size, chan_count, tmp_tag;
int		i, j, k, ii, count, jj=0;
OMuint          rel_offset;
OM_S_OBJID	new_objid;
OM_S_SPAMAPENT  tmp;
OM_p_BIG_TAIL   p_tail;
OM_p_VARLENARR_DESCR p_old_descr, p_new_descr;
OM_p_OBJECTHDR  p_object, p_new_object;
OM_p_CHANNEL_HDR 	  p_chan_hdr;
OM_p_CLASSDEF	p_curold_cld, p_cld, p_old_acld, p_new_acld;
OM_p_LCD	clustcmp;
OM_S_MESSAGE	msg, wild_disconnect_msg;
char		found;
int		flag=TRUE;
OM_p_SPAMAPENT  p_spacemap, p_spacemap_ent;
OMuint		p_old, p_new, old_tagged, new_taggable;
int 		sts;
OM_S_NEIGHBOR	neighbor;

#ifdef DEBUG
OMuint          offset;
#endif

struct save_descr_str
   {
   OM_p_VARLENARR_DESCR	addr;
   int		offset;
   int		count;
   int          vla_defn_ndx;
   } *p_save_descr=NULL;

struct wild_disconnect_struct
   {
   OM_S_CHANSELECT	to_sel;
   } wild_disconnect_args;

/*********************************************************/
/* Check send depth of object                            */
/*********************************************************/

if ( sd_override != OM_K_change_class_sd_override ) {
   if ( OM_GA_OSDs[osnum]->Spacemap[objid].flags & OM_SM_send_depth ) {
      return(OM_E_BADSENDDEPTH);
   }
}

/*********************************************************/
/* Get classid and acld for old class                    */
/*********************************************************/

if (!(1&(sts = om$get_class( osnum=osnum, objid=objid, 
	p_classid=&old_classid, pp_cld=&p_old_acld ))))
	return(sts);

if (  (old_classid == OM_K_ROOT_ACTCLASSID)
   || (old_classid == OM_K_OMOSCO_ACTCLASSID)
   || (old_classid == OM_K_OMGROUP_ACTCLASSID)
   || (old_classid == OM_K_OMCLUSTER_ACTCLASSID)
   || (old_classid == OM_K_OMOBJSPACE_ACTCLASSID)
   || (old_classid == OM_K_OMMOSD_ACTCLASSID)
   || (old_classid == OM_K_OMISO_ACTCLASSID)
   || (old_classid == OM_K_OMMOSDOS_ACTCLASSID)
   || (old_classid == OM_K_OMFILEDOS_ACTCLASSID)
   || (old_classid == OM_K_OMTRANSOS_ACTCLASSID)  )
	return(OM_E_BADPROMCLASS);

/*********************************************************/
/* Get classid and acld for new class                    */
/*********************************************************/

if (!(1&(sts = om$get_class( osnum=osnum, classname=classname, 
		    p_classid=&new_classid, pp_cld=&p_new_acld))))
	return(sts);

if (  (new_classid == OM_K_ROOT_ACTCLASSID)
   || (new_classid == OM_K_OMOSCO_ACTCLASSID)
   || (new_classid == OM_K_OMGROUP_ACTCLASSID)
   || (new_classid == OM_K_OMCLUSTER_ACTCLASSID)
   || (new_classid == OM_K_OMOBJSPACE_ACTCLASSID)
   || (new_classid == OM_K_OMMOSD_ACTCLASSID)
   || (new_classid == OM_K_OMISO_ACTCLASSID)
   || (new_classid == OM_K_OMMOSDOS_ACTCLASSID)
   || (new_classid == OM_K_OMFILEDOS_ACTCLASSID)
   || (new_classid == OM_K_OMTRANSOS_ACTCLASSID)  )
	return(OM_E_BADPROMCLASS);

#ifdef DEBUG
/*
printf("\n--- Old classid ---\n");
dump_class(p_old_acld);
dump_msgmap(p_old_acld->MsgMap, p_old_acld->NumMsgClasses);
printf("\n--- New classid ---\n");
dump_class(p_new_acld);
dump_msgmap(p_new_acld->MsgMap, p_new_acld->NumMsgClasses);
*/
#endif

/*********************************************************/
/*     Construct an instance of the new class	         */
/*********************************************************/

if (!(1&(sts = om$make_neighbor(osnum=osnum, objid=objid,
				p_neighbor=&neighbor))))
  return(sts);

/*
**	Temporarily (sp?) disable tagging to avoid creating
**	an extra tag.
*/

/*  is old object tagged  */

p_spacemap = OM_GA_OSDs[osnum]->Spacemap;
p_object = p_spacemap[objid].state.object;
old_tagged = p_object->i_size & OM_OHf_is_tagged;

/*  is new object taggable  */

new_taggable = p_new_acld->flags & OM_CLDf_TAGGABLE;

tmp_tag = om$enable_tagging(flag=0);

if (!(1&(sts = om$construct(classname=classname, osnum=osnum, 
                            neighbor=neighbor, p_objid=&new_objid))))
{
  om$enable_tagging(flag=tmp_tag);
  return(sts);
}

om$enable_tagging(flag=tmp_tag);
p_spacemap = OM_GA_OSDs[osnum]->Spacemap;
p_object = p_spacemap[objid].state.object;
p_new_object = p_spacemap[new_objid].state.object;

#ifdef DEBUG
printf("\n--- objid: %d\n", objid);
printf("--- new_objid: %d\n", new_objid);
printf("--- p_object: %d   %x\n", p_object, p_object);
printf("---     size: %d\n", OM_GETOBJSIZE(p_object->i_size));
printf("--- p_new_object: %d   %x\n\n", p_new_object, p_new_object);
printf("---     size: %d\n", OM_GETOBJSIZE(p_new_object->i_size));
#endif

/*  do that tag swap thing  */

if (old_tagged) {
  if (new_taggable) {
    p_new_object->i_size |= OM_OHf_is_tagged;
  }
  else {  /* get rid of old tag */
     sts = om$remove_tag ( osnum = osnum,
                           objid = objid );
     if (!(1&sts)) return (sts);
  }
}
	
/*********************************************************/
/* Copy common component class instance data             */
/*********************************************************/

wild_disconnect_msg.select.DefClassid = OM_K_ROOT_ACTCLASSID;
wild_disconnect_msg.select.ReqClassid = OM_K_ROOT_ACTCLASSID;
wild_disconnect_msg.select.FuncIndex  = Root_OPP_wild_disconnect_method_index;
wild_disconnect_msg.size              = sizeof(struct wild_disconnect_struct);
wild_disconnect_msg.p_arglist         = (char *)&wild_disconnect_args;

for ( i=1; (OMuword) i<p_old_acld->NumMsgClasses; i++ ) {
 
  /* check for rejected instance data */

  if (p_old_acld->MsgMap[i].offset  == 0 && 
      p_old_acld->MsgMap[i].classid != 0 ) continue;

  p_old = (OMuint)p_object + p_old_acld->MsgMap[i].offset;

  p_curold_cld = OM_GA_active_classes[p_old_acld->MsgMap[i].classid];

#ifdef DEBUG
  printf("\n--- loop %d through old class component list ---\n", i);
  printf("--- Old Component: %s\n", (p_curold_cld->s_name);
  printf("--- p_old: %d\n", p_old);
#endif

  found = 0;
  for ( j=1; (OMuword) j<p_new_acld->NumMsgClasses; j++ )	{

    /*  check for rejected instance data */

    if (p_new_acld->MsgMap[j].offset  == 0 &&
        p_new_acld->MsgMap[j].classid != 0 ) continue;

    p_new = (OMuint)p_new_object + p_new_acld->MsgMap[j].offset;

    p_cld = OM_GA_active_classes[p_new_acld->MsgMap[j].classid];

#ifdef DEBUG
    printf("\n--- loop %d through new class component list ---\n", j);
    printf("--- New Component: %s\n", p_cld->s_name);
    printf("--- p_new: %d\n", p_new);
#endif

    if (p_old_acld->MsgMap[i].classid == p_new_acld->MsgMap[j].classid) {

      /*     Found a common component class       */
      /* Does this component class have VLAs?     */

      if ( p_cld->w_num_varlenarrays > 0 ) {

#ifdef DEBUG
        printf("--- Common component with vla's ---\n");
        display_vla_defn(p_old_acld->w_num_varlenarrays,p_old_acld->p_varlenarr_defns);
#endif
        jj = 0;
	      
        /* Allocate structure used for saving VLA descriptor
           information so it can be restored after block move
           of instance data from one object to another wipes it out */

        if (NULL==(p_save_descr = (struct save_descr_str *)om$malloc(
           size=sizeof(struct save_descr_str)*p_old_acld->w_num_varlenarrays)))
          return(OM_E_NODYNMEM);

        for ( ii=p_old_acld->w_num_varlenarrays-1; ii>=0; ii-- ) {
          if ( (p_old_acld->MsgMap[i].offset <=
                p_old_acld->p_varlenarr_defns[ii].w_offset) &&
              ((p_old_acld->MsgMap[i].offset+p_curold_cld->NewInstanceSize) >
                p_old_acld->p_varlenarr_defns[ii].w_offset) ) {

            /* VLA belongs to this component class */

            rel_offset = p_old_acld->p_varlenarr_defns[ii].w_offset
			 - p_old_acld->MsgMap[i].offset;

            /* Determine the ptrs to VLA descriptors - use relative
               offset within the component to figure ptr for new guy. */

            p_old_descr = (OM_p_VARLENARR_DESCR)((OMuint)p_object
		          + p_old_acld->p_varlenarr_defns[ii].w_offset);
            p_new_descr = (OM_p_VARLENARR_DESCR)((OMuint)p_new_object
		          + p_new_acld->MsgMap[j].offset + rel_offset);

#ifdef DEBUG
	    offset=p_old_acld->MsgMap[i].offset;
	    printf("\n--- component offset: %d\n", offset);
            printf("--- rel_offset: %d\n", rel_offset);
	    printf("- p_old_descr\n");
	    char type = p_old_acld->p_varlenarr_defns[ii].type;
	    display_vla_descr(p_old_descr, type);
            printf("- p_new_descr\n");
	    display_vla_descr(p_new_descr, type);
#endif
            if ( p_old_descr->i_offset ) {

              /* if VLA or channel not empty */
              /* Determine VLA align size    */

              align_size = som_aligned_vla_size(
			     &(p_old_acld->p_varlenarr_defns[ii]),
			     p_old_descr);

              if ( p_old_acld->p_varlenarr_defns[ii].type ) {

                /* VLA is a Channel */

                p_chan_hdr = (OM_p_CHANNEL_HDR)(p_old_descr->i_offset);
		count = 0; /* new channel */

		if (p_chan_hdr->flags & OM_CH_singleton) {
                  if (p_chan_hdr->flags & OM_CH_restricted) {
                    size = sizeof(OM_S_RESTRICTED_ONECHAN);
                  }
                  else {
                    size = sizeof(OM_S_CHANNEL_LINK);
                  }
                }
                else {
                  if (p_chan_hdr->flags & OM_CH_bigchan) {
                     p_tail = (OM_p_BIG_TAIL)((OMuint)p_chan_hdr +
                                        sizeof(OM_S_CHANNEL_HDR));
                     chan_count = p_tail->size;
                  }
                  else {
                     chan_count = p_chan_hdr->u1.count;
                  }

                  if (p_chan_hdr->flags & OM_CH_restricted) {
                    size = chan_count * sizeof(OM_S_OBJID) +
                           sizeof(OM_S_CHANNEL_HDR);
                  }
                  else {
                    size = chan_count * sizeof(OM_S_CHANNEL_LINK) +
                           sizeof(OM_S_CHANNEL_HDR);
                  }
                }
                size /= sizeof(long);                

                if (!(1&(sts=om$vla_set_dimension(
		 	   pp_data=(int *) p_new_descr,	/* pp_chan_hdr */
			   p_count=(OMuint *) &count,
			   osnum=osnum,
			   objid=new_objid,
			   p_cld=p_new_acld,
			   size=size))))
		   return(sts);
	      }
	      else {

                /* Is VLA initialize size big enough already? */

                if (p_old_descr->i_count > p_new_descr->i_count) {
 	          if (!(1&(sts=om$vla_set_dimension(
			     p_vladescr=p_new_descr,
			     osnum=osnum,
			     objid=new_objid,
			     p_cld=p_new_acld,
			     size=p_old_descr->i_count))))
		     return(sts);
	        }
	      }

#ifdef DEBUG
              printf("\n--- After Possible Set Dimension ---\n");
	      display_vla_descr(p_new_descr, type);
	      printf("\n--- Moving VLA portion ---\n");
              printf("\n--- moving vla information of size %d\n", align_size);
#endif
              OM_BLOCK_MOVE((int *)(p_old_descr->i_offset),
	                    (int *)(p_new_descr->i_offset),
		            align_size);

 	      /* Save new descriptor for restore after block move */

  	      p_save_descr[jj].addr = p_new_descr;
	      p_save_descr[jj].offset = p_new_descr->i_offset;
	      if (!(p_old_acld->p_varlenarr_defns[ii].type))
		 p_save_descr[jj].count = p_new_descr->i_count;
              p_save_descr[jj].vla_defn_ndx = ii;
              ++jj;
            }
	    else {   /* VLA empty */
              p_save_descr[jj].addr = p_new_descr;
	      p_save_descr[jj].offset = 0;
              if (!(p_old_acld->p_varlenarr_defns[ii].type))
		p_save_descr[jj].count = 0;
              p_save_descr[jj].vla_defn_ndx = ii;
              ++jj;
	    }
	  } /* If offset in correct range */		
        } /* End for num of VLAs */
      } /* if has VLAs */

      /*     Block move the static portion     */

#ifdef DEBUG
      printf("\n--- Moving static portion ---\n");
#endif

      OM_BLOCK_MOVE((int *)p_old,(int *)p_new,p_curold_cld->NewInstanceSize);

      /*     Restore VLA descriptors       */

      if (p_cld->w_num_varlenarrays > 0) {
        for (ii=0; ii<jj; ii++) {
          p_save_descr[ii].addr->i_offset = p_save_descr[ii].offset;
          if (!p_old_acld->p_varlenarr_defns[p_save_descr[ii].vla_defn_ndx].type)
            p_save_descr[ii].addr->i_count = p_save_descr[ii].count;
#ifdef DEBUG
          printf("\n--- After restore of vla descriptor ---\n");
	  display_vla_descr(p_save_descr[ii].addr, p_cld->p_varlenarr_defns[ii].type);
#endif	     
	}
        om$dealloc ( ptr = (char *) p_save_descr );
      }
      found = TRUE;
      break;
    }
  } /* End for all new classes components */

  if ( !found ) {

    /* This class is not a component class - wild disconnect */

    wild_disconnect_args.to_sel.type = OM_e_name;
    for ( k = 0; (OMuword) k<p_curold_cld->w_numchannels; k++ )	{
      wild_disconnect_args.to_sel.u_sel.name = p_curold_cld->ChanDefns[k].s_name;	
      if (!(1&(sts=om$send(mode = OM_e_wrt_message,
			   msg = &wild_disconnect_msg,
			   senderid = NULL_OBJID,
			   targetid = objid,
                           targetos = osnum))))
        return(sts);
    }
  }
}

/***************************************************************/
/* Move new guy's spacemap data to old guys spacemap slot      */
/* and change oids in objhdrs				       */
/***************************************************************/

#ifdef DEBUG
printf("\n--- Swap places in Space Map ---\n\n");
#endif

/*  save some spacemap flags before swap  */

sv_flags = p_spacemap[objid].flags & 
           (OM_SM_has_di_name|OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt);

OM_BLOCK_MOVE(&(p_spacemap[objid]),&tmp,sizeof(OM_S_SPAMAPENT));

OM_BLOCK_MOVE(&(p_spacemap[new_objid]),	&(p_spacemap[objid]),
              sizeof(OM_S_SPAMAPENT));

OM_BLOCK_MOVE(&tmp,&(p_spacemap[new_objid]),sizeof(OM_S_SPAMAPENT));

p_object->oid = new_objid;
p_new_object->oid = objid;

/*  reinstate save spacemap flags  */

p_spacemap[objid].flags |= sv_flags;
p_spacemap[new_objid].flags &= (~sv_flags);

/***************************************************************/
/*           Delete the old object                             */
/***************************************************************/

/****************************************************************
if (!(1&(sts = om$delete_object(osnum=osnum,
                                object=p_object,
                                objid=new_objid))))
  return(sts);

****************************************************************/

p_spacemap_ent = &p_spacemap[new_objid];
if ( p_spacemap_ent->flags & OM_SM_array_mod ) {
  OM_p_CLASSDEF  p_cld = p_spacemap_ent->p_acld;
  clustcmp = OM_GA_CSDarray[p_spacemap_ent->sdi].p_pcd->p_lcd;
  if(!(1&(sts = som_vla_remove_outriggers(osnum, p_spacemap_ent, p_cld, clustcmp))))
    return(sts);
}

/*=====================================================*/
/* Decrement OSCO ref cnt; if zero send delete to OSCO */
/*=====================================================*/

if (!(--(OM_GA_OSDs[osnum]->OSCO_list[old_classid]->i_refcnt)) &&
   (!(OM_GA_OSDs[osnum]->OSCO_list[old_classid]->w_child_refcnt))) {
  msg.select.DefClassid = OM_K_ROOT_ACTCLASSID;
  msg.select.ReqClassid = OM_K_OMOSCO_ACTCLASSID;
  msg.select.FuncIndex  = Root_OPP_delete_method_index;
  msg.size              = sizeof(OMuint);
  msg.p_arglist         = (char *)&flag;

  if(!(1&(sts=om$send(msg=&msg, senderid=NULL_OBJID,
 		targetid=OM_GA_OSDs[osnum]->OSCO_list[old_classid]->OSCO_oid,
		targetos=osnum)))) {
    return(sts);
  }
}

/*===========================================================*/
/* Put Instance Into Free List Of Its Owning Cluster Extent; */
/*===========================================================*/

clustcmp = OM_GA_CSDarray[p_spacemap_ent->sdi].p_pcd->p_lcd;
if (!(1&(sts = om$free_space(p_clustcmp = clustcmp,
	                     p_instance = p_object,
                             flag       = (OMuint)OM_K_OBJECT,
	                     osnum      = osnum, 
                             p_extent   = OM_GA_CSDarray[p_spacemap_ent->sdi].p_pcd))))
  return(sts);

/*=========== */  
/* Free Objid */
/*=========== */  

OM_FREE_OBJID( new_objid, osnum );

return(OM_S_SUCCESS);

}
