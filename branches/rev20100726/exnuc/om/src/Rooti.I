class	implementation	Root;

#include <stdio.h>
#ifdef NT
#include <stdlib.h>
#endif
#include "OMobjectcomm.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMintercept.h"

#if defined (NT)
extern int rand();
#elif defined (SYSV) || defined (BSD)
extern double drand48 __((void));
#endif

extern int som_ISO_check_logical_disconnect();
extern int som_ISO_change_entry();
extern int som_perhaps_add_tagcon_rec();
extern int som_perhaps_change_tagcon_rec();
extern int som_show_channel();
extern int som_show_object();
extern int som_show_chlink();
extern int som_show_res_link();

extern int OM_Gf_check_chan_dups;
extern OM_p_INTRCPT_HT  OM_GA_IntrcptHshTbl;
extern OM_S_CSD	*OM_GA_CSDarray;

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ debug */
method	debug ()
{
 printf("Root.debug\n");
 som_show_object(OM_Gw_current_OS, my_id);
 return(OM_S_SUCCESS);
}
/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ unknown */
method	unknown (OM_S_MESSAGE *msg)
{
 return(OM_W_UNKNOWN_MSG);
}
/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ delete */
method	delete  (int flag)
{
  OMuword		*Tmp_ActToFil;	/* active to filed classid map   */
  OMuword		*Tmp_FilToAct;	/* filed to active classid map   */
  OM_p_LCD		*Tmp_Clusters;	/* ptr to array of ptrs to       */
                                        /* cluster composites            */
  OM_p_OSCO             *Tmp_OSCO_list;     /* ptr to array of ptrs to OSCOs */
  OM_p_SPAMAPENT	Tmp_Spacemap;	/* ptr to spacemap array         */
  OM_p_OSD		p_osd;

  if ( p_spacemap->flags & OM_SM_send_depth )
  {
     if ( p_spacemap->flags & OM_SM_Rootdel_pending )
     {
        return (OM_S_SUCCESS);
     }
     else
     {
        p_spacemap->flags |= OM_SM_Rootdel_pending;
        return (OM_S_SUCCESS);
     }
  }
  /* are we deleting the oso here? */
  if( my_id == OM_GO_current_OS_objid &&
      OM_GA_OSDs[OM_Gw_current_OS]->flags&OM_OSD_Rootdel_pending)
  {
	p_osd = OM_GA_OSDs[OM_Gw_current_OS];

	/* get temporary pointers to the osd pointer fields */
	Tmp_ActToFil = p_osd->ActToFil;
  	Tmp_FilToAct = p_osd->FilToAct;	
  	Tmp_Clusters = p_osd->Clusters;	
  	Tmp_OSCO_list = p_osd->OSCO_list;
  	Tmp_Spacemap = p_osd->Spacemap;	

	/* free msg intercept hashtable if one exists */

	if(OM_GA_IntrcptHshTbl && OM_GA_IntrcptHshTbl[OM_Gw_current_OS].hash_table)
        {
	  om$dealloc(ptr=(char *) OM_GA_IntrcptHshTbl[OM_Gw_current_OS].hash_table);
          OM_GA_IntrcptHshTbl[OM_Gw_current_OS].hash_table = 0;
        }

	/* free up cluster 0 */

	om$cleanup_cluster(p_clustcmp=p_osd->Clusters[0]);

	/* now delete the last vestiges of a once mighty object space.. */

	om$dealloc(ptr=(char *) Tmp_ActToFil);
	om$dealloc(ptr=(char *) Tmp_FilToAct);
	om$dealloc(ptr=(char *) Tmp_Clusters);
	om$dealloc(ptr=(char *) Tmp_OSCO_list);
	om$dealloc(ptr=(char *) Tmp_Spacemap);

	OM_GA_OSDs[OM_Gw_current_OS] = NULL;

	/* Now that the os is gone, restore the fa mapsize to the
	/* current number of classes. If the number of classes increases,
	/* the oscos will extend the f/a maps
	*/

	OM_GA_fa_mapsize[OM_Gw_current_OS] = OM_Gw_numclasses;	
    	return(OM_S_SUCCESS);
  }
  else
  {
	p_spacemap->flags &= (~OM_SM_Rootdel_pending);

  	return (om$delete_object 
	       (osnum=OM_Gw_current_OS, object=(OM_p_OBJECTHDR) me,
                objid=my_id));
  }

}
/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ connect */
method connect 
		(OM_S_CHANSELECT to_sel;
		 int to_idx;
		 OM_S_OBJID fr_objid;
		 OMuword fr_os;
		 OM_S_CHANSELECT fr_sel;
		 int fr_idx)
{
 int sts, sts2;
 OM_S_CONNECT_SIDE side1, side2;
 OM_p_CONNECT_SIDE s1 = &side1;
 OM_p_CONNECT_SIDE s2 = &side2;

#ifdef DEBUG
  printf("~~~Root.connect\n");
#endif

 sts = om$connect_build_side(osnum=OM_Gw_current_OS, objid=my_id,
		chsel=&to_sel, relidx=fr_idx, side=s1);
 if (1 & sts) { 
   sts = om$connect_build_side(osnum=fr_os, objid=fr_objid,
		chsel=&fr_sel, relidx=to_idx, side=s2);
   if ( 1 & sts ) {
     sts = om$connect_complete_sides ( side1=s1, side2=s2 );
     if (1 & sts) {
       if ( OM_Gf_check_chan_dups &&
            om$connect_if_connected(side1=s1, side2=s2)) {
         sts = som_ISO_check_logical_disconnect ( s1, s2 );
         if (1 & sts) {
           sts2 = som_perhaps_add_tagcon_rec ( s1, s2 );            
           if (!(1&sts2)) sts = sts2;
         }
       }
       else if ( ! om$connect_check_classlist(side1=s1, side2=s2)) {
	  sts = OM_E_CLASS_CONFLICT;
       }
       else {  /* OK if not connected */
	 sts = om$connect_get_chent(side1=s1, side2=s2);
	 if ( 1 & sts ) {
	   sts = om$connect_get_chent(side1=s2, side2=s1);
	   if ( 1 & sts) {
	     sts = om$connect_doconnect(side1=s1, side2=s2);
	     if ( 1 & sts ) {
		sts = om$connect_doconnect (side1=s2, side2=s1);
		if (!(1&sts)) {
		   om$connect_disconnect (side1=s1,side2=s2);
		}
		else if (s1->iso_index != s2->iso_index) {
#ifdef DEBUG
  printf("Root_connect - iso index mismatch\n");
  dumpiso();
  exit(1);
#endif
		  printf("Root_connect - iso index mismatch\n");
		  sts = OM_E_INTERNALS_CORRUPT;
		  om$connect_disconnect(side1=s1,side2=s2);
		  om$connect_disconnect(side1=s2,side2=s1);
		}
                else {
                  sts = som_perhaps_add_tagcon_rec ( s1, s2 );
                  if (!(1&sts)) {
                    om$connect_disconnect(side1=s1,side2=s2);
                    om$connect_disconnect(side1=s2,side2=s1);
                  }
                }
	     }
           }
	 }
       }
     }
   }
   om$connect_release_side(side1=s2);
 }
 om$connect_release_side(side1=s1);
#ifdef DEBUG
  printf("~~xRoot.connect\n");
#endif
 if (sts != OM_S_SUCCESS) {
   return(sts);
 }
 if (s1->status != OM_S_SUCCESS) {
   return(s1->status);
 }
 return(s2->status);
}
/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++++++++++++++ disconnect */
method disconnect
		(OM_S_CHANSELECT to_sel;
		 OM_S_OBJID fr_objid;
		 OMuword fr_os;
		 OM_S_CHANSELECT fr_sel)
{
 int sts;
 OM_S_CONNECT_SIDE side1, side2;
 OM_p_CONNECT_SIDE s1 = &side1;
 OM_p_CONNECT_SIDE s2 = &side2;

#ifdef DEBUG
  printf("~~~Root.disconnect\n");
#endif

 sts = om$connect_build_side(osnum=OM_Gw_current_OS, objid=my_id, 
		chsel=&to_sel, relidx=0, side=s1);
 if (1 & sts) { 
   sts = om$connect_build_side(osnum=fr_os, objid=fr_objid,
		chsel=&fr_sel, relidx=0, side=s2);
   if ( 1 & sts ) {
     sts = om$connect_complete_sides ( side1=s1, side2=s2 );
     if (1 & sts) {
       if ( ! om$connect_if_connected(side1=s1, side2=s2)) {
	  sts = OM_W_NOTONCHAN;
       }
       else {  /* OK if connected */
	 om$connect_disconnect( side1=s1, side2=s2 );
	 om$connect_disconnect( side1=s2, side2=s1 );
       }
     }
   }
   om$connect_release_side(side1=s2);
 }
 om$connect_release_side(side1=s1);
#ifdef DEBUG
  printf("~~xRoot.disconnect\n");
#endif
 if (sts != OM_S_SUCCESS) {
   return(sts);
 }
 if (s1->status != OM_S_SUCCESS) {
   return(s1->status);
 }
 return(s2->status);
}

/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++++++++ range_disconnect */
method range_disconnect
		(OM_S_CHANSELECT to_sel;
		 int low_idx;
		 int hi_idx)
{
 int sts, num, ii, indx;
 int del_count, del_max;
 OM_S_CONNECT_SIDE side1, *s1 = &side1;
 OM_S_CONNECT_SIDE side2, *s2 = &side2;
 OM_p_CHANNEL_HDR p_chan;
 OM_p_CHANNEL_LINK  link=NULL;
 OM_p_OBJID	    p_objid=NULL;
 char		    set_in_use=FALSE;
 OMuword            s1def_flags;

#ifdef DEBUG
  printf("~~~Root.range_disconnect\n");
#endif

 sts = om$connect_build_side(osnum=OM_Gw_current_OS, objid=my_id,
		chsel=&to_sel, relidx=0, side=s1);
 if (!(1 & sts)) {
    om$connect_release_side (side1=s1);
    return(sts);
 }

 p_chan = *(s1->pp_chan);
 if (!p_chan) {
   om$connect_release_side (side1=s1);
   return (OM_I_CHAN_EMPTY);
 }

 s1def_flags = s1->chdef->p_type->w_flags;

 if (s1def_flags & CD_absordered) {
   num = s1->tail.last_index;
 }
 else if ( s1def_flags & CD_relordered ) {
   num = s1->tail.last_index - s1->tail.collapse_count;
 }
 else { /* must be an ordered relation for range disconnect */
   om$connect_release_side(side1=s1);
   return(OM_W_NOTORDERED);
 }

 if (low_idx < 0 || low_idx > num || low_idx > hi_idx) {
   om$connect_release_side(side1=s1);
   return(OM_E_INVALIDRANGE);
 }
 if (hi_idx > num) {
   hi_idx = num;
 }

 if (p_chan->flags & OM_CH_restricted)
   p_objid = (OM_p_OBJID)s1->p_chandata;
 else
   link = (OM_p_CHANNEL_LINK)s1->p_chandata;

 if (p_chan->flags & OM_CH_relordered) {
   if (s1->tail.collapse_count) {
     indx = 0;
     if ( p_chan->flags & OM_CH_restricted ) {
       for (ii=0; ;p_objid++, indx++) { /* skip all holes in channel array */
         if ( ! IF_NULL_OBJID(*p_objid)) {
           ii++;
           if (ii > low_idx) break;
         }
       }
     }
     else {  /* not restricted */
       link = (OM_p_CHANNEL_LINK)(s1->p_chandata);
       for (ii=0; ;link++, indx++) { /* skip all holes in channel array */
         if ( ! IF_NULL_OBJID(link->objid)) {
           ii++;
	   if (ii > low_idx) break;
         }
       }
     }
   }  /* if collapse count not 0 */
   else {
     indx = low_idx;
     if ( p_chan->flags & OM_CH_restricted ) {
       p_objid += indx;
     }
     else {
      link += indx;
     }
   }
 }	/* if relatively ordered */
 else {  /* absordered - can be fixed or regular */
   indx = low_idx;
   if ( p_chan->flags & OM_CH_restricted ) {
      p_objid += indx;
   }
   else {
     link += indx;
   }
 }	/* if absolutely ordered */

 if (!(p_chan->flags & OM_CH_in_use)) {
    set_in_use = TRUE;
    p_chan->flags |= OM_CH_in_use;
 }

 del_max = hi_idx - indx + 1;
 del_count = 0;
 sts = OM_S_SUCCESS;


 if ( p_chan->flags & OM_CH_restricted ) {
   for (;;) {   
     if ( ! IF_NULL_OBJID(*p_objid)) {
       del_count++;
       s1->p_chlink = (OM_p_CHANNEL_LINK)p_objid;
       sts = om$connect_pside ( side1=s1, side2=s2 );
       if ( 1 & sts ) {
         if (sts == OM_S_SUCCESS) {  /* s2 OS may not be loaded - let dangle */
	   om$connect_disconnect   ( side1=s2, side2=s1 );
	   om$connect_release_side ( side1=s2 );
         }
         om$connect_disconnect   ( side1=s1, side2=s2 );
	 om$connect_return_chent ( side1=s1 );
       }
       else {
         printf("Root_range_disconnect: som_connect_pside fail\n");
	 return (sts);
       }
     }
     else if (p_chan->flags & OM_CH_absordered) { 
       del_count++;
     }
     if (del_count >= del_max) break;
     indx++;
     if (indx >= (int) s1->tail.last_index) break;
     p_objid = (OM_p_OBJID)(s1->p_chandata) + indx;
   }  /* for */
 }
 else {    /* not restricted */
   for (;;) {
     if ( ! IF_NULL_OBJID(link->objid)) {
       del_count++;
       s1->p_chlink = link;
       sts = om$connect_pside ( side1=s1, side2=s2 );
       if ( 1 & sts ) {
	 if (sts == OM_S_SUCCESS) {  /* s2 OS may not be loaded - let dangle */
	   om$connect_disconnect   ( side1=s2, side2=s1 );
	   om$connect_release_side ( side1=s2 );
  	 }
	 om$connect_disconnect   ( side1=s1, side2=s2 );
	 om$connect_return_chent ( side1=s1 );
       }
       else {
	 printf("Root_range_disconnect: som_connect_pside fail\n");
	 return (sts);
       }
     }
     else if (p_chan->flags & OM_CH_absordered) { 
       del_count++;
     }
     if (del_count >= del_max) break;
     indx++;
     if (indx >= (int) s1->tail.last_index) break;
     link = (OM_p_CHANNEL_LINK)(s1->p_chandata) + indx;
   }
 }

 if (set_in_use)
   p_chan->flags &= (~OM_CH_in_use); /* clear in_use flag if you set it */
 om$connect_release_side (side1=s1);

#ifdef DEBUG
  printf("~~xRoot.range_disconnect\n");
#endif

 return(sts);
}

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++ wild_disconnect */
method wild_disconnect
		(OM_S_CHANSELECT to_sel)
{
 int sts, num, ii;
 OM_S_CONNECT_SIDE side1, *s1 = &side1;
 OM_S_CONNECT_SIDE side2, *s2 = &side2;
 OM_p_CHANNEL_HDR p_chan;
 OM_p_CHANNEL_LINK  link=NULL;
 OM_p_OBJID	    p_objid=NULL;
 char		    set_in_use=FALSE;
 OMuword            s1def_flags;

#ifdef DEBUG
  printf("~~~Root.wild_disconnect\n");
#endif

 sts = om$connect_build_side(osnum=OM_Gw_current_OS, objid=my_id,
		chsel=&to_sel, relidx=0, side=s1);
 if (!(1 & sts)) {
   om$connect_release_side (side1=s1);
   return(sts);
 }

 p_chan = *(s1->pp_chan);
 if (!p_chan) {
   om$connect_release_side (side1=s1);
   return (OM_I_CHAN_EMPTY);
 }
 num = s1->tail.last_index;
 s1def_flags = s1->chdef->p_type->w_flags;

 if ( s1def_flags & CD_restricted )
   p_objid = (OM_p_OBJID)(s1->p_chandata);
 else
   link = (OM_p_CHANNEL_LINK)(s1->p_chandata);

 if ((!(s1def_flags & (CD_1_1|CD_m_1))) && 
     (!(p_chan->flags & OM_CH_in_use))) {
   set_in_use = TRUE;
   p_chan->flags |= OM_CH_in_use;
 }

 if ( s1def_flags & CD_restricted ) {
   for (ii=num; ii > 0; ii--, p_objid++) {
     if ( ! IF_NULL_OBJID(*p_objid)) {
       s1->p_chlink = (OM_p_CHANNEL_LINK)p_objid;
       sts = om$connect_pside ( side1=s1, side2=s2 );
       if ( 1 & sts ) {
         if (sts == OM_S_SUCCESS) {  /* s2 OS may not be loaded - let dangle */
  	   om$connect_disconnect   ( side1=s2, side2=s1 );
	   om$connect_release_side ( side1=s2 );
         }
         om$connect_disconnect   ( side1=s1, side2=s2 );
         om$connect_return_chent ( side1=s1 );
       }
       else {
         printf("Root_wild_disconnect: som_connect_pside fail\n");
         return (sts);
       }
     } /* close if ! NULL_OBJID */
   } /* close for */
 }
 else { 
   for (ii=num; ii > 0; ii--, link++) {
     if ( ! IF_NULL_OBJID(link->objid)) {
       s1->p_chlink = link;
       sts = om$connect_pside ( side1=s1, side2=s2 );
       if ( 1 & sts ) {
         if (sts == OM_S_SUCCESS) {  /* s2 OS may not be loaded - let dangle */
  	   om$connect_disconnect   ( side1=s2, side2=s1 );
	   om$connect_release_side ( side1=s2 );
         }
         om$connect_disconnect   ( side1=s1, side2=s2 );
         om$connect_return_chent ( side1=s1 );
       }
       else {
         if (sts == OM_W_OSNOTACTIVE) {
           om$connect_disconnect   ( side1=s1, side2=s2 );
           om$connect_return_chent ( side1=s1 );
         }
         else {
           printf("Root_wild_disconnect: som_connect_pside fail\n");
           return (sts);
         }
       }
     } /* close if ! NULL_OBJID */
   } /* close for */
 } /* not restricted */

 if (!(s1def_flags & (CD_1_1|CD_m_1))) {
   if (set_in_use) 
      p_chan->flags &= (~OM_CH_in_use); /* clear in_use flag if you set it */
 }

 om$connect_release_side (side1=s1);
 return(OM_S_SUCCESS);

}

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++++++++ move_chan */
method move_chan
		(OM_S_CHANSELECT to_sel;
		 OM_S_OBJID fr_objid;
		 OMuword fr_os;
		 OM_S_CHANSELECT fr_sel)
{
 int sts;
 OM_S_CONNECT_SIDE side1, *s1 = &side1; /* for source of move */
 OM_S_CONNECT_SIDE side2, *s2 = &side2; /* for target of move */
 OM_S_CONNECT_SIDE side3, *s3 = &side3; /* for an object being moved */
 OM_p_CHANNEL_HDR   p_chan1;
 OM_p_CHANNEL_LINK link1=NULL;
 OM_p_OBJID        p_objid1=NULL;
 char		   set_in_use=FALSE;
 int ii, num1, s1res1chan, s3res1chan;
 OMuword  s1def_flags;

#ifdef DEBUG
  printf("~~~Root.move_chan\n");
#endif

 sts = om$connect_build_side(osnum=fr_os, objid=fr_objid, 
		chsel=&fr_sel, relidx=0, side=s1);
 if (1 & sts) { 
   if (!(*(s1->pp_chan))) {   /* from side empty? */
     om$connect_release_side (side1=s1);
     return (OM_I_CHAN_EMPTY);
   }
   sts = om$connect_build_side(osnum=OM_Gw_current_OS, objid=my_id,
		chsel=&to_sel, relidx=0, side=s2);
   if ( 1 & sts ) {
     sts = om$connect_move_check (side1=s1, side2=s2, copy_flag=FALSE);

		 /* if s2 can receive s1 connects */

     if ( sts == OM_S_SUCCESS ) {
       s1res1chan = 0;
       p_chan1 = *(s1->pp_chan);
       s1def_flags = s1->chdef->p_type->w_flags;
       num1 = s1->tail.last_index;
       if ( s1def_flags & CD_restricted ) {
         if ( s1def_flags & (CD_1_1|CD_m_1)) s1res1chan = 1;
         p_objid1 = (OM_p_OBJID)(s1->p_chandata);
       }
       else
         link1 = (OM_p_CHANNEL_LINK)(s1->p_chandata);

       if ( (!(s1def_flags & (CD_1_1|CD_m_1))) &&
            (!(p_chan1->flags & OM_CH_in_use))) {
         set_in_use = TRUE;
         p_chan1->flags |= OM_CH_in_use;
       }

       if (s1->osnum == s2->osnum) {   /* source and target in same os */
         if ( s1def_flags & CD_restricted ) {
           for (ii=0; ii<num1; ii++, p_objid1++) {
             if ( ! IF_NULL_OBJID ( *p_objid1 )) {
               s1->p_chlink = (OM_p_CHANNEL_LINK)p_objid1;
	       s2->relidx   = ii;
	       sts = om$connect_pside(side1=s1, side2=s3);
	       if (!(1&sts)) {
		 printf("Root_move_chan: som_connect_pside fail\n");
		 return(sts);
	       }
	       sts = om$connect_get_chent(side1=s2, side2=s3);
	       if (!(1&sts)) {
		 printf("Root_move_chan: som_connect_get_chent fail");
		 return(sts);
	       }

               /* connection in same OS */

               s3res1chan = 0;
 	       if ( s3->chdef->p_type->w_flags & CD_restricted ) {
                 if (s3->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {
                   s3res1chan = 1;
                   *((OM_p_OBJID)(s3->p_chlink)) = s2->objid << 1;
                   *((OM_p_OBJID)(s3->p_chlink)) |= 1;
                 }
                 else {
                   *((OM_p_OBJID)(s3->p_chlink)) = s2->objid;
                 }
               }
     	       else {
	         s3->p_chlink->channum = s2->channum;
	         s3->p_chlink->objid   = s2->objid;
	       }
	    
	       if ( !s3res1chan &&
                    (s2->chdef->p_type->w_flags & (CD_1_1 | CD_1_m))) {
 	         (*(s3->pp_chan))->flags |= OM_CH_full;
	       }
 	       else if ( !s3res1chan &&
                         (!(s3->chdef->p_type->w_flags & (CD_1_1 | CD_m_1)))) {
	         (*(s3->pp_chan))->flags &= ~ OM_CH_full;
	       }
	       s3->chused = TRUE;  /* don't return this channel entry */
	       om$connect_release_side (side1=s3);

               if ( s2->chdef->p_type->w_flags & CD_restricted ) {
                 if ( s1res1chan )
                   *((OM_p_OBJID)s2->p_chlink) = (*p_objid1 >> 1);
                 else
                   *((OM_p_OBJID)s2->p_chlink) = *p_objid1;
                 if (s2->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {
                   *((OM_p_OBJID)s2->p_chlink) <<= 1;
                   *((OM_p_OBJID)s2->p_chlink) |= 1;
                 }
               }
               else {		/* build link */
	         s2->p_chlink->hdr.flags = OM_CL_to_object;
	         s2->p_chlink->channum = s1->chdef->p_type->channum;;
                 if ( s1res1chan )
                   s2->p_chlink->objid = (*p_objid1 >> 1);
                 else
                   s2->p_chlink->objid = *p_objid1;
	       }

	       s1->chused   = FALSE;  /* cause entry to be returned */
	       sts = om$connect_return_chent (side1=s1);
	       if (!(1&sts)) {
		 printf("Root_move_chan: som_connect_return_chent fail");
		 return(sts);
	       }
	     } /* end if ! NULL_OBJID */
	   } /* end for */
         }
         else {       
	   for (ii=0; ii<num1; ii++, link1++) {
	     if ( ! IF_NULL_OBJID ( link1->objid )) {
	       s1->p_chlink = link1;
	       s2->relidx   = ii;
	       sts = om$connect_pside(side1=s1, side2=s3);
	       if (!(1&sts)) {
		 printf("Root_move_chan: som_connect_pside fail\n");
		 return(sts);
	       }
	       sts = om$connect_get_chent(side1=s2, side2=s3);
	       if (!(1&sts)) {
		 printf("Root_move_chan: som_connect_get_chent fail");
		 return(sts);
	       }
               s3res1chan = 0;
	       if ( ! IF_NULL_OBJID(s1->iso_objid)) {
	         som_ISO_change_entry(s1->osnum, s1->iso_objid, 
			s2->objid, &s2->channum, link1->hdr.u1.isoindex);
                 sts = som_perhaps_change_tagcon_rec ( s1, s2, s3 );
                 if (!(1&sts)) {
                   om$report_error(sts=sts);
                   printf("Root_move_chan:som_perhaps_change_tagcon_rec fail");
                   return (sts);
                 }
	       }
	       else { /* connection in same OS */
	         if ( s3->chdef->p_type->w_flags & CD_restricted ) {
                   if ( s3->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {
                     s3res1chan = 1;
                     *((OM_p_OBJID)(s3->p_chlink)) = s2->objid << 1;
                     *((OM_p_OBJID)(s3->p_chlink)) |= 1;
                   }
                   else {
                     *((OM_p_OBJID)(s3->p_chlink)) = s2->objid;
                   }
                 }
     	         else {
	           s3->p_chlink->channum = s2->channum;
	           s3->p_chlink->objid   = s2->objid;
	         }
	       }
	       if ( !s3res1chan &&
                    (s2->chdef->p_type->w_flags & (CD_1_1 | CD_1_m))) {
 	         (*(s3->pp_chan))->flags |= OM_CH_full;
	       }
 	       else if ( !s3res1chan &&
                         (!(s3->chdef->p_type->w_flags & (CD_1_1 | CD_m_1)))) {
	         (*(s3->pp_chan))->flags &= ~ OM_CH_full;
	       }
	       s3->chused = TRUE;  /* don't return this channel entry */
	       om$connect_release_side (side1=s3);

               if (s2->chdef->p_type->w_flags & CD_restricted) {
                 if (s2->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {
                   *((OM_p_OBJID)(s2->p_chlink)) = link1->objid << 1;
                   *((OM_p_OBJID)(s2->p_chlink)) |= 1;
                 }
                 else {
                   *((OM_p_OBJID)(s2->p_chlink)) = link1->objid;
                 }
               }
	       else {        
 	         *s2->p_chlink = *link1;  /* move the entry */
	       }

  	       s1->chused   = FALSE;  /* cause entry to be returned */
	       sts = om$connect_return_chent (side1=s1);
	       if (!(1&sts)) {
		 printf("Root_move_chan: som_connect_return_chent fail");
		 return(sts);
	       }
	     } /* end if ! NULL_OBJID */
	   } /* end for */
         }
       }
       else { /* source and target are in different OS */
	      /* disconnect and reconnect each link */
	 for (ii=0; ii<num1; ii++, link1++) {
	   if ( ! IF_NULL_OBJID ( link1->objid )) {
	     s1->p_chlink = link1;
	     s2->relidx = ii;
	     sts = om$connect_pside(side1=s1, side2=s3);
	     if (!(1&sts)) {
	       printf("Root_move_chan: som_connect_pside fail 2\n");
	       return(sts);
	     }
	     s1->chused = FALSE;  /* cause link to be returned */
		/* first disconnect s1 from s3 */
	     om$connect_disconnect(side1=s1, side2=s3);
	     om$connect_return_chent(side1=s1);
	     om$connect_disconnect(side1=s3, side2=s1);
	     om$connect_return_chent(side1=s3);
		/* then connect s2 to s3 */
	     sts = om$connect_complete_sides(side1=s2, side2=s3);
	     if (!(1&sts)) {
	       printf("Root_move_chan: som_connect_complete_sides\n");
	       return(sts);
	     }
	     sts = om$connect_get_chent(side1=s2, side2=s3);
	     if (!(1&sts)) {
	       printf("Root_move_chan: som_connect_get_chent 2\n");
	       return(sts);
	     }
	     sts = om$connect_get_chent(side1=s3, side2=s2);
	     if (!(1&sts)) {
	       printf("Root_move_chan: som_connect_get_chent 3");
	       return(sts);
	     }
	     om$connect_doconnect(side1=s2, side2=s3);
	     om$connect_doconnect(side1=s3, side2=s2);
             som_perhaps_add_tagcon_rec ( s2, s3 );
	     s3->chused = TRUE;
	     om$connect_release_side (side1=s3);
	   } /* end if ! NULL_OBJID */
	 } /* end for */
       }   /* end else - different OS */

       s2->chused = TRUE;
       if (!( s1->chdef->p_type->w_flags & (CD_1_1|CD_m_1))) {
         if (set_in_use) p_chan1->flags &= (~OM_CH_in_use);
       }
     }
   }
   om$connect_release_side (side1=s2);
 }

 om$connect_release_side (side1=s1);

#ifdef DEBUG
  printf("~~xRoot.move_chan\n");
#endif

 return(sts);
}

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++++++++ copy_chan */
method copy_chan
		(OM_S_CHANSELECT to_sel;
		 OM_S_OBJID fr_objid;
		 OMuword fr_os;
		 OM_S_CHANSELECT fr_sel)
{
 int sts;
 OM_S_CONNECT_SIDE side1, *s1 = &side1; /* for source of move */
 OM_S_CONNECT_SIDE side2, *s2 = &side2; /* for target of move */
 OM_S_CONNECT_SIDE side3, *s3 = &side3; /* for an object being moved */
 OM_p_CHANNEL_HDR  p_chan1;
 OM_p_CHANNEL_LINK link1=NULL;
 OM_p_OBJID	   p_objid1=NULL;
 char		   set_in_use=FALSE;
 int ii, num1;
 OMuword s1def_flags, s2def_flags;

#ifdef DEBUG
  printf("~~~Root.copy_chan\n");
#endif

 sts = om$connect_build_side(osnum=fr_os, objid=fr_objid, 
		chsel=&fr_sel, relidx=0, side=s1);
 if (1 & sts) {
   if (!(*(s1->pp_chan))) {  /* from side empty? */
     om$connect_release_side (side1=s1);
     return (OM_I_CHAN_EMPTY);
   }
   sts = om$connect_build_side(osnum=OM_Gw_current_OS, objid=my_id,
		chsel=&to_sel, relidx=0, side=s2);
   if ( 1 & sts ) {
     sts = om$connect_move_check (side1=s1, side2=s2, copy_flag=TRUE);

		 /* if s2 can receive s1 connects */

     s1def_flags = s1->chdef->p_type->w_flags;
     s2def_flags = s2->chdef->p_type->w_flags;
     if ( sts == OM_S_SUCCESS ) {
       p_chan1 = *(s1->pp_chan);
       num1 = s1->tail.last_index;
       if ( s1def_flags & CD_restricted ) {
         p_objid1 = (OM_p_OBJID)(s1->p_chandata);
       }
       else {
         link1 = (OM_p_CHANNEL_LINK)(s1->p_chandata);
       }
       if ((!(s1def_flags & (CD_1_1|CD_m_1))) &&
           (!(p_chan1->flags & OM_CH_in_use))) {
         set_in_use = TRUE;
         p_chan1->flags |= OM_CH_in_use;
       }
       if ( s1def_flags & CD_restricted ) {
         for (ii=0; ii<num1; ii++, p_objid1++) {
	   if ( ! IF_NULL_OBJID ( *p_objid1 )) {
	     s1->p_chlink = (OM_p_CHANNEL_LINK)p_objid1;
	     s2->relidx   = ii;
	     sts = om$connect_pside(side1=s1, side2=s3);
	     if (!(1&sts)) {
	       printf("Root_copy_chan: som_connect_pside fail\n");
	       return(sts);
	     }
	     sts = om$connect_complete_sides(side1=s2, side2=s3);
	     if (!(1&sts)) {
	       printf("Root_copy_chan: som_connect_complete_sides\n");
	       return(sts);
	     }
	     sts = om$connect_get_chent(side1=s2, side2=s3);
	     if (!(1&sts)) {
	       printf("Root_copy_chan: som_connect_get_chent fail 1\n");
	       return(sts);
	     }
 	     sts = om$connect_get_chent(side1=s3, side2=s2);
	     if (!(1&sts)) {
	       printf("Root_copy_chan: som_connect_get_chent fail 2");
	       return(sts);
	     }
 	     om$connect_doconnect(side1=s2, side2=s3);
	     om$connect_doconnect(side1=s3, side2=s2);
 	     s3->chused = TRUE;  /* don't return this channel entry */
	     om$connect_release_side (side1=s3);
	   } /* end if ! NULL_OBJID */
         } /* end for */
       } /* end if restricted */
       else {
         for (ii=0; ii<num1; ii++, link1++) {
	   if ( ! IF_NULL_OBJID ( link1->objid )) {
	     s1->p_chlink = link1;
	     s2->relidx   = ii;
	     sts = om$connect_pside(side1=s1, side2=s3);
	     if (!(1&sts)) {
	       printf("Root_copy_chan: som_connect_pside fail\n");
	       return(sts);
	     }
	     sts = om$connect_complete_sides(side1=s2, side2=s3);
	     if (!(1&sts)) {
 	       printf("Root_copy_chan: som_connect_complete_sides\n");
	       return(sts);
	     }
	     sts = om$connect_get_chent(side1=s2, side2=s3);
	     if (!(1&sts)) {
	       printf("Root_copy_chan: som_connect_get_chent fail 1\n");
	       return(sts);
	     }
	     sts = om$connect_get_chent(side1=s3, side2=s2);
	     if (!(1&sts)) {
	       printf("Root_copy_chan: som_connect_get_chent fail 2\n");
	       return(sts);
	     }
	     om$connect_doconnect(side1=s2, side2=s3);
	     om$connect_doconnect(side1=s3, side2=s2);
             som_perhaps_add_tagcon_rec ( s2, s3 );
 	     s3->chused = TRUE;  /* don't return this channel entry */
	     om$connect_release_side (side1=s3);
	   } /* end if ! NULL_OBJID */
         } /* end for */
       } /* end if restricted */
       s2->chused = TRUE;
       if (!(p_chan1->flags & OM_CH_singleton)) {
         if (set_in_use) p_chan1->flags &= (~OM_CH_in_use);
       }
     }  /* end if sts move_check */
   } /* end if sts second build_side */
   om$connect_release_side (side1=s2);
 } /* end if sts first build_side */

 s1->chused = TRUE;
 om$connect_release_side (side1=s1);

#ifdef DEBUG
  printf("~~xRoot.copy_chan\n");
#endif

 return(sts);

}

#undef DEBUG


/*-----------------------------------------------------------------------*/

#ifdef NT
#define RAND_INT( L, U )				\
	(int)( L +                                      \
        (int) ((U-L) * (((double) rand()) / RAND_MAX)) )
#else
#define RAND_INT( L, U )				\
	(int)( L + (U-L)*drand48() )
#endif

#define SWAP( A, B, OPTYPE )				\
	{						\
	OPTYPE temp;					\
	temp = A;					\
	A = B;						\
	B = temp;					\
	}
	
/*---------------------------------------------------------------------*/

static void OM_qsort_objlnks( lower, upper, list)

	int			lower;	/* Lower bound of partition */
	int			upper;	/* Upper bound of partition */
	OM_p_OBJECT_LINKAGE	list;   /* List to be sorted	    */

{
register int i, lastlow;
OM_S_OBJECT_LINKAGE t;


if ( upper > lower )
    {
    i=RAND_INT( lower,  upper );
    SWAP( list[lower], list[i], OM_S_OBJECT_LINKAGE );
    t = list[lower];
    lastlow = lower;
    for ( i=lower+1; i<=upper; i++)
	{
	if (( list[i].osnum <  t.osnum ) ||
           (( list[i].osnum == t.osnum ) &&
            ( list[i].S_objid <  t.S_objid )) ||
	    ((list[i].osnum == t.osnum ) && (list[i].S_objid == t.S_objid )
	      && ( list[i].channum.classid < t.channum.classid )) ||
	    ((list[i].osnum == t.osnum ) && (list[i].S_objid == t.S_objid )
	      && ( list[i].channum.classid == t.channum.classid )
	      && ( list[i].channum.number < t.channum.number )))
	    { 
	    lastlow++;
	    SWAP( list[lastlow], list[i], OM_S_OBJECT_LINKAGE );
	    }
	}
    SWAP( list[lower], list[lastlow], OM_S_OBJECT_LINKAGE );
    OM_qsort_objlnks( lower,  lastlow-1, list );
    OM_qsort_objlnks( lastlow+1, upper, list );
    }
}

								/*+medesc*/

/*---------------------------------------------------------------------------*/

method set_operation 
	(OM_S_CHANSELECT 	to_sel;
	 OM_S_OBJID 		op2_objid;
	 OMuword		op2_os;
	 OM_S_CHANSELECT	op2_sel;
	 OM_S_OBJID		op3_objid;
	 OMuword		op3_os;
	 OM_S_CHANSELECT	op3_sel;
	 char			operation;
	 OMuword		preserve)




/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ set_operation */
/*
	      	Set Operations

	        If resultant objid (my_id) is neither op2_objid or op3_objid
		and if preserve is set (1) then op2_objid and op3_objid
		will not be changed.  If preserve is clear (0) 
		then op2_objid and op3_objid's channels (op2_sel & op3_sel) 
		will be wild disconnected.

		SET DIFFERENCE OPERATION ( 'd' or 'D' ):

		This routine determines the set difference between the
		sets of objects defined by the 2 input objids (op2_objid &
	        op3_objid), their channels (op2_sel & op3_sel), and their
		os numbers (op2_os & op3_os).  The resulting set difference 
		is connected to result objid's channel ( to_sel).  
		
		SET UNION OPERATION ( 'u' or 'U' ):

		This routine determines the set union between the sets
		of objects defined by the 2 input objids,their osnums,
		and their channels.  The resulting set union is connected to 
		the result objid, via result channel (to_sel).
		 
		SET INTERSECTION OPERATION ( 'i' or 'I' ):

		This routine determines the set intersection between the sets
		of objects defined by the 2 input objids, osnums and 
		channels.  The resulting set intersection is connected to the
		result objid, via result channel (to_sel).

*/								/*-medesc*/


{
int 			i=0;
int                     j=0;
int	 		sts;
OMuint			resltcnt, cnt2, cnt3, temp_sm_cnt, tmpcnt=0;
OMuint		        count2, count3, result_count, temp_count;
OM_S_OBJECT_LINKAGE 	*list2=NULL;
OM_S_OBJECT_LINKAGE     *list3=NULL;
OM_S_OBJECT_LINKAGE	*result_list, *temp_list;
OM_S_OBJID	 	temp_sm_objid, temp_objid=0;
OM_p_CHANSELECT		p_temp_sm_chansel;
OM_S_CHANSELECT		temp_sel, temp_chansel;
OMuword			temp_sm_osnum, temp_osnum=0;
OMbyte			equal, equal2, equal3;
#ifdef DEBUG
int			testcount;
#endif

/* Get channel count for future use. */

sts=om$get_channel_count(osnum=op2_os, 
		objid=op2_objid, 
		p_chanselect=&op2_sel, 
		count=&cnt2);
if (!(sts&1)) return(sts);

sts=om$get_channel_count(osnum=op3_os, 
		objid=op3_objid, 
		p_chanselect=&op3_sel, 
		count=&cnt3);
if (!(sts&1)) return(sts);

sts=om$get_channel_count(osnum=OM_Gw_current_OS, 
		objid=my_id, 
		p_chanselect=&to_sel, 
		count=&resltcnt);
if (!(sts&1)) return(sts);


#ifdef DEBUG
printf("\n*** CHANNEL COUNTS ***\n");
printf("cnt2 = %d\n", cnt2 );
printf("cnt3 = %d\n", cnt3 );
printf("resltcnt = %d\n", resltcnt);
printf("*************************\n");
#endif

switch ( operation )  /* switch on set operator */
{
  case 'i':	/* Set Intersection Operation : symbol ^ means intersection */
  case 'I':
  	/* case of all 3 operands equal:  no-op */

   	/* Ai = Ai ^ Ai */

#ifdef DEBUG
	printf("\n*** INTERSECTION ***\n");
#endif

        if (!(sts=om$is_oper_equal(osnum1=OM_Gw_current_OS, osnum2=op2_os, objid1=my_id, objid2=op2_objid, chanselect1=to_sel, chanselect2=op2_sel, equal=&equal2)&1))
	   return(sts);

        if (!(sts=om$is_oper_equal(osnum1=OM_Gw_current_OS, osnum2=op3_os, objid1=my_id, objid2=op3_objid, chanselect1=to_sel, chanselect2=op3_sel, equal=&equal3)&1))
	       return(sts);

	if ( equal2 && equal3 )
		{
#ifdef DEBUG
		    printf("*** all 3 operands are equal ***\n");
#endif
		    return(OM_S_SUCCESS);
	 	}



	/* case of objid2 or objid3 NULL :  empty set result */

   	if ( cnt2==0 || cnt3==0 )

	{
#ifdef DEBUG
	    printf("\nIntersection case of obj2 or obj3 NULL; empty set result\n");
#endif	    

	    /* Clear Out Result Channel if not empty */


            if ( resltcnt != 0 )
	    {

	    sts=om$send(msg=message Root.wild_disconnect(to_sel), 
			senderid=my_id, 
			targetid=my_id
			);
	    if (!(sts&1))return(sts);

            }

	    /* Do Not Preserve Relations Situation */

	    if ( ! preserve )
	    {
		if ( cnt2 != 0 )
		{
		sts=om$send(msg=message Root.wild_disconnect(op2_sel), 
			    senderid=op2_objid, 
			    targetid=op2_objid, 
			    targetos=op2_os
			    );

		if (!(sts&1)) return(sts);
		}

		if ( cnt3 != 0 )
		{

		sts=om$send(msg=message Root.wild_disconnect(op3_sel), 
			    senderid=op3_objid, 
		            targetid=op3_objid, 
			    targetos=op3_os
			    );
		if (!(sts&1)) return(sts);
		}
	    }
	    return (OM_S_SUCCESS);
	}

	/* case of operand1 and operand2 equal */

	/* Ai = Aj ^ Aj */
	/*       or     */
	/* Ci = Aj ^ Aj */

        if (!(sts=om$is_oper_equal(osnum1=op2_os, osnum2=op3_os, objid1=op2_objid, objid2=op3_objid, chanselect1=op2_sel, chanselect2=op3_sel,equal=&equal)&1))
	   return(sts);

        if ( equal )
	{

#ifdef DEBUG
	    printf("\n*** Intersection case of op2 and op3 equal ***\n");
#endif

	    /* Clear Out Result Channel if not empty */

	    if ( resltcnt != 0 )
	    {
		sts=om$send(msg=message Root.wild_disconnect(to_sel), 
			    senderid=my_id, 
			    targetid=my_id
			    );
		if (!(sts&1)) return(sts);
	    }
	    if (! preserve )		/* Do not preserve set */
	    {
	        /* Move Channel from operand to result */

	        if ( cnt2 != 0 )
		{
		sts=om$send(msg=message Root.move_chan
			(to_sel, op2_objid, op2_os, op2_sel),
			senderid=my_id, 
			targetid=my_id
			);
		if (!(sts&1)) return(sts);
		}
	    }  /* Do not preserve set */

	    else

	    {	/* Preserve set */

		if ( cnt2 != 0 )
		{
		sts=om$send(msg=message Root.copy_chan
			(to_sel, op2_objid, op2_os, op2_sel), 
			senderid=my_id, 
			targetid=my_id
			);
		if (!(sts&1)) return(sts);
		}
	    }  /* preserve set */

	    return( OM_S_SUCCESS);
	}

	/* Determine sizes of lists and Allocate lists for channel sets */

	
	   list2 = (OM_p_OBJECT_LINKAGE)
                     om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE) *
                     cnt2);
	    if(!list2)
	    {
		return(OM_E_NO_OBJECT_SPACE);
	    }

	    sts=om$get_channel_objects(osnum=op2_os, 
		objid=op2_objid, 
		p_chanselect=&op2_sel, 
		list=list2, 
		size=cnt2, 
		count=&count2 );
	    if (!(sts&1))
	    {
		om$dealloc(ptr=(char *) list2);
		return(sts);
	    }

            if (count2 > 1)
  	       OM_qsort_objlnks(0, count2-1, list2);  /* sort list2 */
	
	   list3 = (OM_p_OBJECT_LINKAGE)
                     om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE) *
                     cnt3);
	    if(!list3)
	    {
		om$dealloc(ptr=(char *) list2);
		return(OM_E_NO_OBJECT_SPACE);
	    }

	    sts=om$get_channel_objects(osnum=op3_os, 
		objid=op3_objid, 
		p_chanselect=&op3_sel, 
		list=list3, 
		size=cnt3, 
		count=&count3 );
	    if (!(sts&1))
	    {
		om$dealloc(ptr=(char *) list2);
		om$dealloc(ptr=(char *) list3);
		return(sts);
	    }

            if (count3 > 1)
	       OM_qsort_objlnks(0, count3-1, list3);  /* sort list1 */


	/* case of result operand equal to either operand1 or operand2 */

	/* Ai = Ai ^ Aj */
	/*      or      */
	/* Ai = Ai ^ Bk */
	/*      or	 */
	/* Ai = Aj ^ Ai */
	/*      or      */
        /* Ai = Bk ^ Ai */

	if ( equal2 || equal3 )

	{
#ifdef DEBUG
	printf("*** result equal to either op2 or op3 ***\n");
#endif
	    if ( equal2 )
	    {
		result_list = list2;
		temp_list = list3;
		result_count = count2;
		temp_count = count3;
		temp_objid = op3_objid;
		temp_osnum = op3_os;
		temp_chansel = op3_sel;
	    }
	    else
	    {
		result_list = list3;
		temp_list = list2;
		result_count = count3;
		temp_count = count2;
		temp_objid = op2_objid;
		temp_osnum = op2_os;
		temp_chansel = op2_sel;
	    }

	/* Compare object sets and build resultant intersection set */

        i = 0;
        j = 0;
	do

	{
	   if ((result_list[i].S_objid == temp_list[j].S_objid )
                                           &&
               (result_list[i].osnum == temp_list[j].osnum))
	   {
		i++;
		j++;
	   }
	   else
	   {

            if(((result_list[i].S_objid > temp_list[j].S_objid )
                                           &&
                (result_list[i].osnum == temp_list[j].osnum)) 
                                           ||
                (result_list[i].osnum > temp_list[j].osnum))
              {
		    j++;
	      }
	      else	/* must be < */
	      {
		    /* Build a selector for the disconnect */
		  
		    temp_sel.type = OM_e_num;
		    temp_sel.u_sel.number = result_list[i].channum;

		    sts=om$send(msg=message Root.disconnect
				(to_sel, result_list[i].S_objid,
				result_list[i].osnum, temp_sel ),
				senderid=my_id,
				targetid=my_id
				);
		    if (!(sts&1))
		    {
			om$dealloc(ptr=(char *) list2);
			om$dealloc(ptr=(char *) list3);
			return(sts);
		    }
		    i++;
	      }  /* else: < */
	   }  /* else: > */

	} while (i < (int) result_count && j < (int) temp_count );

	for (; i < (int) result_count; i++)
	{

            /* Build selector for disconnect. */

	    temp_sel.type = OM_e_num;
	    temp_sel.u_sel.number = result_list[i].channum;

	    sts=om$send(msg=message Root.disconnect
			(to_sel, result_list[i].S_objid,
			result_list[i].osnum, temp_sel),
			senderid=my_id,
			targetid=my_id);

	    if (!(sts&1))
		{
		    om$dealloc(ptr=(char *) list2);
		    om$dealloc(ptr=(char *) list3);
		    return(sts);
		}
	}  /* for */

	if (! preserve )
	{
	    sts=om$send(msg=message Root.wild_disconnect
			(temp_chansel),
			senderid=temp_objid,
			targetid=temp_objid, 
			targetos=temp_osnum
			);
	    if (!(sts&1))			    
	    {
		om$dealloc (ptr=(char *) list2);
		om$dealloc (ptr=(char *) list3);
		return (sts);
	    }
	}
	om$dealloc (ptr=(char *) list2);
	om$dealloc (ptr=(char *) list3);
	return (OM_S_SUCCESS);
    }

	/* 3 operand case */
	/* Ai = Aj ^ Ak, Ai = Aj ^ Bk, Ci = Aj ^ Ak, Ci = Aj ^ Bk */

	/* Clear Out Result Channel if not empty */

#ifdef DEBUG
	printf("*** all 3 operands are different ***\n");
#endif

	if ( resltcnt != 0)
	{
	    sts=om$send(msg=message Root.wild_disconnect
			(to_sel), 
			senderid=my_id, 
			targetid=my_id
			);
	    if (!(sts&1))			
	    {
		om$dealloc (ptr=(char *) list2);
		om$dealloc (ptr=(char *) list3);
		return (sts);
	    }
	}

	/* disconnect before connecting in case only 1 object may be */
	/* on other side of this channel */

	if (! preserve )
	{
	    sts=om$send(msg=message Root.wild_disconnect
			(op2_sel), 
			senderid=op2_objid, 
			targetid=op2_objid, 
			targetos=op2_os
			);
	    if (!(sts&1))
	    {
		om$dealloc (ptr=(char *) list2);
		om$dealloc (ptr=(char *) list3);
		return (sts);
	    }

	    sts=om$send(msg=message Root.wild_disconnect
			(op3_sel), 
			senderid=op3_objid, 
			targetid=op3_objid, 
			targetos=op3_os
			);
	    if (!(sts&1))
	    {
		om$dealloc (ptr=(char *) list2);
		om$dealloc (ptr=(char *) list3);
		return (sts);
	    }
	}

        i = 0;
        j = 0;

	do

	{
	    if (( list2[i].S_objid == list3[j].S_objid )
                                           &&
                ( list2[i].osnum == list3[j].osnum ))
	    {

	      	temp_sel.type = OM_e_num;
		temp_sel.u_sel.number = list2[i].channum;
		

		sts=om$send(msg=message Root.connect
			(to_sel, OM_K_MAXINT, list2[i].S_objid, 
			list2[i].osnum, temp_sel, OM_K_MAXINT), 
			senderid=my_id, 
			targetid=my_id
			);

		if (!(sts&1))
		{
		    om$dealloc (ptr=(char *) list3);
		    om$dealloc (ptr=(char *) list2);
		    return (sts);
		}

		i++;
		j++;
	    }
	    else
	    {
		if (( list2[i].osnum <  list3[j].osnum ) ||
                   (( list2[i].osnum == list3[j].osnum ) &&
                    (list2[i].S_objid < list3[j].S_objid)))

		{
		    i++;
		}
		else
		{
		    j++;
		}  /* else: > */
	    }  /* else: < */
	}  while ( i < (int) count2 && j < (int) count3 );

	break;


  case 'u':	/* Set Union Operation */
  case 'U':
	/* case of all 3 operands equal:  no-op */

	/* Ai = Ai + Ai */

#ifdef DEBUG
	printf("\n*** UNION ***\n");
#endif

        if (!(sts=om$is_oper_equal(osnum1=op2_os, osnum2=op3_os, objid1=op2_objid, objid2=op3_objid, chanselect1=op2_sel, chanselect2=op3_sel, equal=&equal2)&1))
	   return(sts);

        if (!(sts=om$is_oper_equal(osnum1=OM_Gw_current_OS, osnum2=op3_os, objid1=my_id, objid2=op3_objid, chanselect1=to_sel, chanselect2=op3_sel, equal=&equal3)&1))
	   return(sts);

	if ( equal2 && equal3 )

	   {
#ifdef DEBUG
	   printf("*** all 3 operands are equal ***\n");
#endif
	   return( OM_S_SUCCESS );
	   }


	/* case of operand1 and operand2 equal */
	else
	{

	/* Ai = Aj + Aj */
	/*       or     */
	/* Ci = Aj + Aj */


	    if ( equal2 )
	    {

#ifdef	    DEBUG
	    printf("*** UNION case of op2 == op3 ***\n");
#endif	   

	    /* Clear Out Result Channel if not empty */

		if ( resltcnt != 0 )
	    	{

#ifdef DEBUG
		    printf("*** wild disconnect result channel ***\n");
#endif
		    sts=om$send(msg=message Root.wild_disconnect
					(to_sel), 
					senderid=my_id, 
					targetid=my_id
					);
		    if (!(sts&1)) return(sts);
	    	}

	        if( ! preserve )		/* Do not preserve set */

		{
	            /* Move Channel from operand to result */

		    if ( cnt2 != 0 )
		    {
		       sts=om$send(msg=message Root.move_chan
                   	    (to_sel, op2_objid, op2_os, op2_sel), 
			    senderid=my_id, 
			    targetid=my_id
			    );
			if (!(sts&1)) return(sts);
			
		    }
		}  /* Do not preserve set */
		else
		{	/* Preserve set */

#ifdef DEBUG
		printf("*** Preserve set ***\n");
#endif
		if ( cnt2 != 0 )
		   {

#ifdef DEBUG
		   printf("*** Copy op2 to result channel ***\n");
#endif

		   sts=om$send(msg=message Root.copy_chan
			(to_sel, op2_objid, op2_os, op2_sel), 
			senderid=my_id, 
			targetid=my_id
			);
		   if (!(sts&1)) return(sts);

#ifdef DEBUG
		   printf("*** get channel count after copy ***\n");
		   sts=om$get_channel_count(osnum=OM_Gw_current_OS,
				objid=my_id,
				p_chanselect=&to_sel,
				count=&testcount);
		   if (!(sts&1)) return(sts);
		   printf("*** channel count of result = %d\n", testcount);
		   sts=om$get_channel_count(osnum=op2_os,
				objid=op2_objid,
				p_chanselect=&op2_sel,
				count=&testcount);
		   if (!(sts&1)) return(sts);
		   printf("*** channel count of op2 = %d\n\n", testcount);
#endif

				
		   }
		}  /* preserve sets */
	    }  /* operand1 and operand2 equal */
	


	/* case of result operand equal to either operand1 or operand2 */

        else
        {

	/* Ai = Ai + Aj */
	/*      or      */
	/* Ai = Ai + Bk */
	/*      or	 */
	/* Ai = Aj + Ai */
	/*      or      */
	/* Ai = Bk + Ai */
	

		
		if (!(sts=om$is_oper_equal(osnum1=OM_Gw_current_OS, osnum2=op2_os, objid1=my_id, objid2=op2_objid, chanselect1=to_sel, chanselect2=op2_sel, equal=&equal2)&1))
	   return(sts);

		if ( equal2 || equal3 )

		{   /* if result equal to one if the operands */

#ifdef DEBUG
		    printf("*** result == to op2 || op3 ***\n");
#endif

		    if ( equal2 )
		    {
#ifdef DEBUG
			printf("op2 == result\n");
#endif
			temp_osnum = op3_os;
			temp_objid = op3_objid;	/* the operand that is not result */
			tmpcnt = cnt3;
			temp_chansel = op3_sel;
		    }
		    else
		    {
#ifdef DEBUG
		   	printf("op3 == result\n");
#endif
			temp_osnum = op2_os;
			temp_objid = op2_objid;
			tmpcnt = cnt2;
			temp_chansel = op2_sel;
		    }

		    if ( tmpcnt == 0 )		/* empty set to be added */
		    {
			return (OM_S_SUCCESS);		
		    }

		    /* build list of object set to be added to result */

		    else

		    {  	/* Determine sizes of lists and Allocate lists for channel sets */

		   list2 = (OM_p_OBJECT_LINKAGE)
        	             om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE) *
                	     tmpcnt);
		    if(!list2)
		    {
			return(OM_E_NO_OBJECT_SPACE);
		    }
	
		    sts=om$get_channel_objects(
			osnum=temp_osnum, 
			objid=temp_objid, 
			p_chanselect=&temp_chansel, 
			list=list2, 
			size=tmpcnt, 
			count=&count2 );
#ifdef DEBUG
		    printf("count from get_channel_objects to add: %d\n", count2);
		    printf("Show object we just did get_channel_objects on \n");
		    som_show_object( temp_osnum, temp_objid );
#endif 
		    if (!(sts&1))
		    {
			om$dealloc(ptr=(char *) list2);
			return(sts);
		    }
		    

		/* disconnect before connecting in case channel  */
		/* may only have one guy on the other side */

		        if( ! preserve )  /* Do not preserve relation set */
			{
#ifdef DEBUG
			    printf("Disconnect before connecting \n");
#endif
			    sts=om$send(msg=message Root.wild_disconnect
					( temp_chansel ), 
					senderid=temp_objid, 
					targetid=temp_objid, 
					targetos=temp_osnum
					);
			    if (!(sts&1)) 
			    {
				om$dealloc(ptr=(char *) list2);
				return(sts);
			    }
#ifdef DEBUG
	                    printf("Show object after wild_disconnect\n");
			    som_show_object( temp_osnum, temp_objid );
#endif
			}

			/* Connect to result set */

#ifdef DEBUG
			printf("Connect to result set \n");
#endif
			for(i=0; i< (int) count2; i++)
			{
			
#ifdef DEBUG
			    printf("Show list2[%d].S_objid\n",i);
		    	    som_show_object( list2[i].osnum,list2[i].S_objid );
#endif

			    temp_sel.type = OM_e_num;
			    temp_sel.u_sel.number = list2[i].channum;
			    
			    sts=om$send(msg=message Root.connect
				(to_sel, OM_K_MAXINT, list2[i].S_objid, 
				list2[i].osnum, temp_sel, OM_K_MAXINT), 
				senderid=my_id, 
				targetid=my_id);
			    if (!(sts&1))
			    {
				om$dealloc(ptr=(char *) list2);
				return(sts);
			    }

			}  /* for */

		    }  /* result set equal to one of other sets being unioned */
		 }  /* if: result = one of opers */

		else  /* case of 3 operands */

		/* Ai = Aj + Ak, Ai = Aj + Bk, Ci = Aj + Ak, Ci = Aj + Bk */

		{   /* 3 operand case */
		    /* Disconnect result channel if not empty */

#ifdef DEBUG
		    printf("*** all 3 operands are different ***\n");
#endif
		    if ( resltcnt != 0)
		    {

		   	sts=om$send(msg=message Root.wild_disconnect
				(to_sel), 	
				senderid=my_id, 
				targetid=my_id);
			if (!(sts&1)) return(sts);
	    	    }  

		    /* Both operand sets are empty */
		    		
		    if ( cnt2 == 0 && cnt3 == 0 )
		    {
			return (OM_S_SUCCESS);
		    }

		    /* case where one set is empty */

		    if ( cnt2 == 0 )
		    {
		      if( ! preserve )
		      {

			sts=om$send(msg=message Root.move_chan
			  (to_sel, op3_objid, op3_os,op3_sel),
			  senderid=my_id, 
			  targetid=my_id);
			if (!(sts&1)) return(sts);
			return (OM_S_SUCCESS);
		      }
		      else
		      {
		        temp_chansel = op3_sel;
			temp_osnum = op3_os;
		        temp_objid = op3_objid;
			tmpcnt = cnt3;
		        count2 = 0;
		      }
		    }
		    else
		    {
		      if ( cnt3 == 0 )
		      {
		        if( ! preserve )
		        {

			  sts=om$send(msg=message Root.move_chan
			     (to_sel, op2_objid, op2_os, op2_sel),
			     senderid=my_id, 
			     targetid=my_id);
			  if (!(sts&1)) return(sts);
			  return (OM_S_SUCCESS);
		        }
		        else
		        {
		          temp_chansel = op2_sel;
			  temp_osnum = op2_os;
		          temp_objid = op2_objid;
			  tmpcnt = cnt2;
		          count2 = 0;
		        }
		      }  /* objid2 is NULL */
		    } /* objid1 is not NULL */

		    /* Case where either set is empty; Must be Preserve */

		    if ( cnt2 == 0 || cnt3 == 0 )  /* Either operands NULL */
		    {     /* allocate list */
#ifdef DEBUG
			printf("*** UNION where op2 || op3 NULL ***\n");
#endif

		        list2 =(OM_p_OBJECT_LINKAGE)om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE)*tmpcnt);

			if( ! list2 )
			    {
		     		return(OM_E_NO_OBJECT_SPACE);
			    }
	
			sts=om$get_channel_objects(osnum=temp_osnum, 
				objid=temp_objid, 
				p_chanselect=&temp_chansel, 
				list=list2, 
				size=tmpcnt, 
				count=&count2 );
			if (!(sts&1))
			   {
       		           om$dealloc(ptr=(char *) list2);
		           return(sts);
   	                   }

			/* Connect to result set */

			for(i=0; i< (int) count2; i++)
			{

			    temp_sel.type = OM_e_num;
			    temp_sel.u_sel.number = list2[i].channum;

			    sts=om$send(msg=message Root.connect
				(to_sel, OM_K_MAXINT, list2[i].S_objid, 
				list2[i].osnum, temp_sel, OM_K_MAXINT), 
				senderid=my_id, 
				targetid=my_id );
			    if (!(sts&1))
			    {
				om$dealloc(ptr=(char *) list2);
				return(sts);
			    }
			}  /* for */
		    om$dealloc (ptr=(char *) list2);
		    return (OM_S_SUCCESS);
		    }  /* either operands NULL & preserve */

		    /* Neither operand set is empty & Do not preserve */

		    if ( ! preserve )
		    {
			/* determine larger of two sets */

		        if ( cnt2 >= cnt3 )		        
                        {
			    temp_objid = op2_objid;
			    temp_chansel = op2_sel;
			    temp_osnum = op2_os;
			    temp_sm_objid = op3_objid;
			    temp_sm_cnt = cnt3;
			    temp_sm_osnum = op3_os;
			    p_temp_sm_chansel = &op3_sel;
		        }
		        else
		        {
			    temp_objid = op3_objid;
			    temp_chansel = op3_sel;
			    temp_osnum = op3_os;
			    temp_sm_objid = op2_objid;
			    temp_sm_cnt = cnt2;
			    temp_sm_osnum = op2_os;
			    p_temp_sm_chansel = &op2_sel;
		        }

		        /* move channel of largest set to result */

			sts=om$send(msg=message Root.move_chan
				(to_sel, temp_objid, temp_osnum, 
				temp_chansel), 
				senderid=my_id, 
				targetid=my_id );
			if (!(sts&1)) return(sts);
			
		        /*  Get List of smaller object set &  */
		        /*  then connect it to result channel */

			/* allocate list */

			list2 = (OM_p_OBJECT_LINKAGE)om$malloc
				(size=sizeof(OM_S_OBJECT_LINKAGE)*temp_sm_cnt);
			if(!list2)
			    {
		     		return(OM_E_NO_OBJECT_SPACE);
			    }

			sts=om$get_channel_objects(osnum=temp_sm_osnum, 
				objid=temp_sm_objid, 
				p_chanselect=p_temp_sm_chansel, 
				list=list2, 
				size=temp_sm_cnt, 
				count=&count2 );
				
			if (!(sts&1))
	   	    	    {
			        om$dealloc (ptr=(char *) list2);
		                return (sts);
	   	            }
		
		/* disconnect before connecting, in case channel */
		/* may have only one guy on its other side */

			sts=om$send(msg=message Root.wild_disconnect
			   	(*p_temp_sm_chansel), 
				senderid=temp_sm_objid, 
				targetid=temp_sm_objid, 
				targetos=temp_sm_osnum );
			if (!(sts&1))				
			{
			    om$dealloc(ptr=(char *) list2);
			    return (sts);
			}

			/* Connect to result set */

			for(i=0; i< (int) count2; i++)
			{
			    temp_sel.type = OM_e_num;
			    temp_sel.u_sel.number = list2[i].channum;
			    
			    sts=om$send(msg=message Root.connect
				(to_sel, OM_K_MAXINT, list2[i].S_objid, 
				list2[i].osnum, temp_sel, OM_K_MAXINT), 
				senderid=my_id,
				targetid=my_id );
				
			    if (!(sts&1))
			    {
				om$dealloc(ptr=(char *) list2);
				return(sts);
			    }
			}  /* for */
			om$dealloc(ptr=(char *) list2);
			return (OM_S_SUCCESS);
		    }  /* do not preserve - both operands nonempty */

		    /* Both operands nonempty & preserve sets */

		    /* allocate lists and connect each set to result */


		    list2 = (OM_p_OBJECT_LINKAGE) 
                         om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE)*cnt2);
	            if (!list2)
			{
		     	    return(OM_E_NO_OBJECT_SPACE);
			}

		    sts=om$get_channel_objects(osnum=op2_os, 
			objid=op2_objid, 
			p_chanselect=&op2_sel, 
			list=list2, 
			size=cnt2, 
			count=&count2 );
		    
		    if (!(sts&1))
	   	    	{
			    om$dealloc(ptr=(char *) list2);
		            return (sts);
	   	        }

		    /* Connect to result set */

		    for(i=0; i < (int) count2; i++)
		    {
			temp_sel.type = OM_e_num;
			temp_sel.u_sel.number = list2[i].channum;

			sts=om$send(msg=message Root.connect
			   (to_sel, OM_K_MAXINT, list2[i].S_objid, 
			    list2[i].osnum, temp_sel, OM_K_MAXINT), 
			    senderid=my_id, 
			    targetid=my_id );
			    

			if (!(sts&1))
			{
				om$dealloc(ptr=(char *) list2);
				return(sts);
			}
		    }  /* for */

		    /* allocate list for objid2's set */

		    list3 = (OM_p_OBJECT_LINKAGE)
                          om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE)*cnt3);
	            if (!list3)
			{
			    om$dealloc(ptr=(char *) list2);
		     	    return(OM_E_NO_OBJECT_SPACE);
			}

		     sts=om$get_channel_objects
			(osnum=op3_os, 
			objid=op3_objid, 
			p_chanselect=&op3_sel, 
			list=list3, 
			size=cnt3, 
			count=&count3);
			

		     if (!(sts&1))
	   	    	{
			    om$dealloc(ptr=(char *) list3);
			    om$dealloc(ptr=(char *) list2);
		            return (sts);
	   	        }

		    /* Connect to result set */

		    for(i=0; i < (int) count3; i++)
		    {
		
			temp_sel.type = OM_e_num;
			temp_sel.u_sel.number = list3[i].channum;
			
			sts=om$send(msg=message Root.connect
			   (to_sel, OM_K_MAXINT, list3[i].S_objid, 
			   list3[i].osnum, temp_sel, OM_K_MAXINT), 
			senderid=my_id, 
			targetid=my_id );
			
			if (!(sts&1))
			{
			    om$dealloc(ptr=(char *) list2);
			    om$dealloc(ptr=(char *) list3);
			    return(sts);
			}
		    }  /* for */
		}  /* else: 3 operand case */
	    }  /* else:  either oper1 or oper2 = result oper */
	}  /* else:  oper1 = oper2 */
	break;

  case 'd':	/* Set Difference Operation */
  case 'D': 
	/* case of subtractor equal to subtrahend or			*/
	/*	   subtractor's chan equal to NULL:    Empty set result */


	/* Ai = Ai - Ai */
	/*     or       */
	/* Ci = Aj - Aj */

#ifdef DEBUG
	printf("\n*** DIFFERENCE ***\n");
#endif

        if (!(sts=om$is_oper_equal(osnum1=op2_os, osnum2=op3_os, objid1=op2_objid, objid2=op3_objid, chanselect1=op2_sel, chanselect2=op3_sel, equal=&equal2)&1))
	   return(sts);

	if ( equal2 || cnt2 == 0 )

	{   				/* if empty set case */
#ifdef DEBUG
	    printf("*** DIFF op2 == op3 or op2 == NULL ***\n");
#endif

	    if ( resltcnt != 0 )
	    {
	       sts=om$send(msg=message Root.wild_disconnect
			(to_sel), 
			senderid=my_id, 
			targetid=my_id );
	       if ( ! ( sts & 1 ) ) return( sts );
	    }

	    if ( cnt3 != 0 &&  ( !preserve ) )
	    {
	       sts=om$send(msg=message Root.wild_disconnect
			(op3_sel), 
			senderid=op3_objid, 
			targetid=op3_objid, 
			targetos=op3_os
			 );
	       if ( ! ( sts & 1 ) ) return( sts );
	    }
	}  /* end if: empty set case */

	else
	{

	    /* Determine sizes of lists and Allocate lists for channel sets */
		
		list2 = (OM_p_OBJECT_LINKAGE) 
                     om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE)*cnt2);
		if(!list2)
		{
		    return(OM_E_NO_OBJECT_SPACE);
		}


		if ( cnt3 != 0 )
		   {
		   list3 = (OM_p_OBJECT_LINKAGE)
                        om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE)*cnt3);
		   if(!list3)
		       {
		          if (list2) om$dealloc(ptr=(char *) list2);
		          return(OM_E_NO_OBJECT_SPACE);
		       }
	           } /* op3 count not zero */

            /* case with resultant channel equal to subtractor channel, and  */
	    /*	    subtrahend different 		*/

	     /* Ai = Ai - Bk */
	     /*      or      */
	     /* Ai = Ai - Aj */

            if (!(sts=om$is_oper_equal(osnum1=op2_os, osnum2=OM_Gw_current_OS, objid1=op2_objid, objid2=my_id, chanselect1=op2_sel, chanselect2=to_sel, equal=&equal2)&1))
	    return(sts);
	    
	    if ( equal2 )
	    {
#ifdef DEBUG
	      printf("*** DIFF reslt == op2 && op3 different ***\n");
#endif
	      if( cnt3 != 0 )   /* An empty subtrahend set is a no-op */
	      {

		/* Get Object Sets if chan1's objid or chan2's objid is a relation */

		sts=om$get_channel_objects(
			osnum=op2_os, 
			objid=op2_objid, 
			p_chanselect=&op2_sel, 
			list=list2, 
			size=cnt2, 
			count=&count2 );
		if (!(sts&1)) 
	   	    {
		        om$dealloc(ptr=(char *) list2);
		        om$dealloc(ptr=(char *) list3);
		        return (sts);
	   	    }
		
		sts=om$get_channel_objects(
			osnum=op3_os, 
			objid=op3_objid, 
			p_chanselect=&op3_sel, 
			list=list3, 
			size=cnt3, 
			count=&count3 );
		if (!(sts&1))
	   	    {
		        om$dealloc(ptr=(char *) list2);
		        om$dealloc(ptr=(char *) list3);
		        return (sts);
	   	    }

	   	/* Sort Lists */

	        if(count2 > 1)
	   	{
		    OM_qsort_objlnks( 0, count2-1, list2);
	   	}

	        if(count3 > 1)
	   	{
		    OM_qsort_objlnks( 0, count3-1, list3);
	   	}
	
	    	/* Compare object sets and build resultant difference set */
		/* only disconnect objids found in both lists */

                i = 0;
                j = 0;

		do
		{
		    if((list2[i].osnum <  list3[j].osnum) ||
                      ((list2[i].osnum == list3[j].osnum) &&
                       (list2[i].S_objid < list3[j].S_objid)))
		    {
			i++;
		    }
		    else
		    {
		      if((list2[i].osnum >  list3[j].osnum) ||
                        ((list2[i].osnum == list3[j].osnum) &&
                        (list2[i].S_objid > list3[j].S_objid)))
			{
			    j++;
			}
			else	/* must be equal */
			{
			    temp_sel.type = OM_e_num;
			    temp_sel.u_sel.number = list2[i].channum;
			    

			    sts=om$send(msg=message Root.disconnect
				(op2_sel, list2[i].S_objid, 
				list2[i].osnum, temp_sel), 
				senderid=op2_objid, 
				targetid=op2_objid, 
				targetos=op2_os );
			    if (!(sts&1))
			    {
		    		om$dealloc(ptr=(char *) list2);
		    		om$dealloc(ptr=(char *) list3);
				return(sts);
			    }
			    i++;
			    j++;
			}
		    }
		} while( i < (int) count2 && j < (int) count3 );

		if ( ! preserve )
		{			/* if ! preserve */
		    sts=om$send(msg=message Root.wild_disconnect
			(op3_sel), 
			senderid=op3_objid, 
			targetid=op3_objid, 
			targetos=op3_os );
		    if (!(sts&1))
	      	    {
			om$dealloc(ptr=(char *) list3);
		        om$dealloc(ptr=(char *) list2);
			return (sts);
	      	    }
		}		
	      }  /* not the no-op situation */

	    }  /* if: case where result = subtractor */

	    else

	            /* all other cases: 3 different sets or        */
		    /* resultant channel equals subtrahend channel */

		    /* Ai = Aj - Ak, Ai = Aj - Bk, Ci = Aj - Ak, Ci = Aj - Bk */
		    /* Ai = Aj - Ai, Ai = Bk - Ai */

	    {
	      /* if subtrahend set is empty: clear result & move channel */

#ifdef DEBUG
	      printf("*** DIFF all 3 ops different or result equals subtrahend ***\n");
#endif

	      if ( cnt3 == 0 )
	      {
	        /* Clear out resultant channel */

	        if ( resltcnt != 0 )
	   	{
		    sts=om$send(msg=message Root.wild_disconnect
			(to_sel), 
			senderid=my_id, 
			targetid=my_id );
		    if (!(sts&1))
	      	    {
		        om$dealloc(ptr=(char *) list2);
			return (sts);
	      	    }
	   	}

		if ( ! preserve )	/* Do not preserve set */
		{
		    /* Move channel from subtractor to result */

		    sts=om$send(msg=message Root.move_chan
			(to_sel, op2_objid, op2_os, op2_sel), 
			senderid=my_id, 
			targetid=my_id );
		    if (!(sts&1))			
		    {
		        om$dealloc(ptr=(char *) list2);
		        return (sts);
		    }
		}
		else	/* Preserve set */
		{

		   /* Copy channel! */

#ifdef DEBUG
		   printf("*** Preserve - Copy op2 to result channel ***\n");
#endif
		   sts=om$send(msg=message Root.copy_chan
			(to_sel, op2_objid, op2_os, op2_sel), 
			senderid=my_id, 
			targetid=my_id
			);
		   if (!(sts&1)) return(sts);

		}  /* preserve set */
	      }  /* subtrahend set is empty */

	      else
	      {

		/* Get object sets if chan1 or chan2's objid */

		sts=om$get_channel_objects(
			osnum=op2_os, 
			objid=op2_objid, 
			p_chanselect=&op2_sel, 
			list=list2, 
			size=cnt2, 
			count=&count2 );
			
		if (!(sts&1))
	   	    {
			if (list3) om$dealloc(ptr=(char *) list3);
			om$dealloc(ptr=(char *) list2);
		        return (sts);
	   	    }

		sts=om$get_channel_objects(
			osnum=op3_os, 
			objid=op3_objid, 
			p_chanselect=&op3_sel, 
			list=list3, 
			size=cnt3, 
			count=&count3 );

		if (!(sts&1))
	   	    {
			om$dealloc(ptr=(char *) list3);
			if (list2) om$dealloc(ptr=(char *) list2);
		        return (sts);
	   	    }

	   	/* Sort Lists */

	        if( count2 > 1 )
	   	{
		    OM_qsort_objlnks( 0, count2-1, list2 );
	   	}

	        if( count3 > 1 )
	   	{
		    OM_qsort_objlnks( 0, count3-1, list3 );
	   	}
	
	        /* Clear out resultant channel */

	        if ( resltcnt != 0 )
	   	{
		    sts=om$send(msg=message Root.wild_disconnect
			(to_sel), 
			senderid=my_id, 
			targetid=my_id );
		    if (!(sts&1))			
	      	    {
			om$dealloc(ptr=(char *) list2);
			om$dealloc(ptr=(char *) list3);
			return (sts);
	      	    }
	   	}

		/* disconnect before connecting, in case this channel */
		/* may only have one guy on its other side */

		if ( ! preserve )
		{

		    sts=om$send(msg=message Root.wild_disconnect
			(op3_sel), 
			senderid=op3_objid, 
			targetid=op3_objid, 
			targetos=op3_os );
		    if (!(sts&1))
	      	    {
			om$dealloc(ptr=(char *) list3);
		        om$dealloc(ptr=(char *) list2);
			return (sts);
	      	    }

		    sts=om$send(msg=message Root.wild_disconnect
			(op2_sel), 
			senderid=op2_objid, 
			targetid=op2_objid, 
			targetos=op2_os );
		    if (!(sts&1))
	      	    {
			om$dealloc(ptr=(char *) list3);
		        om$dealloc(ptr=(char *) list2);
			return (sts);
	      	    }
		}		

	    	/* Compare object sets and build resultant difference set */

                i = 0;
                j = 0;

		do
		{
		    if ((list2[i].osnum == list3[j].osnum) &&
                        (list2[i].S_objid == list3[j].S_objid))
		    {
			i++;
			j++;
		    }
		    else
		    {
		      if((list2[i].osnum >  list3[j].osnum) ||
                        ((list2[i].osnum == list3[j].osnum) &&
                        (list2[i].S_objid > list3[j].S_objid)))
			{
			    j++;
			}
			else	/* must be < */
			{
			    temp_sel.type = OM_e_num;
			    temp_sel.u_sel.number = list2[i].channum;
			    
			    sts=om$send(msg=message Root.connect
				(to_sel, OM_K_MAXINT, list2[i].S_objid, 
				list2[i].osnum, temp_sel, OM_K_MAXINT), 
				senderid=my_id, 
				targetid=my_id );
			    if (!(sts&1))
			    {
			        om$dealloc(ptr=(char *) list2);
			        om$dealloc(ptr=(char *) list3);
				return(sts);
			    }
			    i++;
			}
		    }
		} while( i < (int) count2 && j < (int) count3 );

		for (; i < (int) count2; i++ )
		{

		    temp_sel.type = OM_e_num;
		    temp_sel.u_sel.number = list2[i].channum;
		    
		    sts=om$send(msg=message Root.connect
			(to_sel, OM_K_MAXINT, list2[i].S_objid, 
			list2[i].osnum, temp_sel, OM_K_MAXINT), 
			senderid=my_id, 
			targetid=my_id );
		    if (!(sts&1))

		    {
			    om$dealloc(ptr=(char *) list2);
			    om$dealloc(ptr=(char *) list3);
			    return(sts);
		    }
		}  /* for */

	      }  /* Subtrahend Set Not empty */
	    }  /* end all other cases */
	}  /* else result is not empty set */

	break;
	
   default:	/* Invalid Operator */

	return(OM_E_INVARG);

}  /* switch */

if (list2)
{
    om$dealloc(ptr= (char *) list2 );
}
if (list3)
{
    om$dealloc(ptr= (char *) list3 );
}
return (OM_S_SUCCESS);

}

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++ som_show_all_channels */
int som_show_all_channels (os, ins, p_cld)
 OMuword os;
 OM_p_OBJECTHDR ins;
 OM_p_CLASSDEF  p_cld;
 {
  OM_p_MSGMAP pmap;
  OM_p_CHANNEL_DEFN chdef;
  OM_p_CHANNEL_HDR p_chan_hdr;
  OMuword ii, jj;

  pmap = p_cld->MsgMap;
  for (ii=0; ii < p_cld->NumMsgClasses; ii++, pmap++) {
   if (pmap->NumChan) {
    printf("----> channels defined by class=%d (%s)  offset=%d num_chan=%d\n",
		pmap->classid, OM_GA_active_classes[pmap->classid]->s_name,
		pmap->offset, pmap->NumChan);
    chdef = pmap->ChanDefns;
    for (jj=0; jj<pmap->NumChan; jj++, chdef++) 
       {
       p_chan_hdr = (OM_p_CHANNEL_HDR)(*((int *)((OMuint)ins + pmap->offset + chdef->i_offset)));
       som_show_channel(os, p_chan_hdr, chdef, TRUE, p_cld, pmap);
       }
   }
  }
  return(OM_S_SUCCESS);
 }
/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++++++++ som_show_channel */

#argsused

int som_show_channel (os, p_chan_hdr, chdef, sholinks, p_cld, p_map)
 OMuword os;
 OM_p_CHANNEL_HDR p_chan_hdr;
 OM_p_CHANNEL_DEFN chdef;
 int sholinks;		/* if TRUE show channel links else don't */
 OM_p_CLASSDEF p_cld;
 OM_p_MSGMAP p_map;
 {
  OMuint                 ii, i, j;
  int                    res1chan;
  OM_p_CHANNEL_LINK      link;
  OM_p_CHANNEL_TYPE_DEFN tdef;
  OM_S_CHANNUM		 channum;
  OM_S_BIG_TAIL          tail;
  OM_p_OBJID	         p_objid;
  char                   cname[OM_K_MAXCHANNAME_LEN];
  OMuword **ppclass;

  tdef = chdef->p_type;
  printf("---> channel name=\"%s\" offset=%d Init=%d Extend=%d flags=(",
	chdef->s_name,chdef->i_offset,tdef->InitCount,tdef->ExtCount);
  if (tdef->w_flags & CD_1_1) {
    printf(" CD_1_1");
  }
  if (tdef->w_flags & CD_m_1) {
    printf(" CD_m_1");
  }
  if (tdef->w_flags & CD_1_m) {
    printf(" CD_1_m");
  }
  if (tdef->w_flags & CD_m_m) {
    printf(" CD_m_m");
  }
  if (tdef->w_flags & CD_absordered) {
    printf(" CD_absordered");
  }
  if (tdef->w_flags & CD_relordered) {
    printf(" CD_relordered");
  }
  if (tdef->w_flags & CD_restricted) {
    printf(" CD_restricted");
  }


  printf(" )\n");
  if (tdef->ClassCount) 
    {
    printf(" ClassCount=%d Classes=(",tdef->ClassCount);
    if ( tdef->w_flags & CD_restricted )
      {
      printf(" %d (%s)", tdef->channum.classid, (char *)tdef->classids);
      }
    else
      {
       ppclass = tdef->classids;
       for (ii=tdef->ClassCount; ii>0; ii--, ppclass++) 
        {
        if ((ppclass != NULL) && (*ppclass != NULL)) 
         {
         printf(" %d (%s)",**ppclass, OM_GA_active_classes[**ppclass]->s_name);
         }
        else 
         {
         printf(" CLASSLIST - PREMATURE END\n");
         break;
         }
        }
       }    
    printf(")\n");
  } /* end if ClassCount */

  i = j = 0;
  while (OM_GA_active_classes[p_map->classid]->s_name[i]) 
      {cname[i]=OM_GA_active_classes[p_map->classid]->s_name[i];++i;}
  cname[i++]='.';
  while (chdef->s_name[j]) cname[i++]=chdef->s_name[j++];
  cname[i]=0;

  om$get_channel_number(channame=cname, p_channum=&channum);

  printf(" channel number=%d.%d is ", channum.classid, channum.number);
  if (tdef->w_flags & CD_1_1) {
    printf(" 1_1");
  }
  res1chan = 0;
  if (tdef->w_flags & (CD_1_1 | CD_m_1)) {
    if (tdef->w_flags & CD_restricted) res1chan = 1;
    printf(" singleton ");
  }
  if (tdef->w_flags & CD_m_1) {
    printf(" m_1");
  }
  if (tdef->w_flags & CD_1_m) {
    printf(" 1_m");
  }
  if (tdef->w_flags & CD_m_m) {
    printf(" m_m");
  }
  if (tdef->w_flags & CD_absordered) {
    printf(" absordered");
  }
  if (tdef->w_flags & CD_relordered) {
    printf(" relordered");
  }
  if ( !res1chan && (p_chan_hdr && (p_chan_hdr->flags & OM_CH_full))) {
    printf(" full");
  }
  if (tdef->w_flags & CD_restricted) {
    printf(" restricted");
  }
  if ( !res1chan && (p_chan_hdr && (p_chan_hdr->flags & OM_CH_in_use))) {
    printf(" in use");
  }
  if ( !res1chan && (p_chan_hdr && (p_chan_hdr->flags & OM_CH_tail_exists))) {
    printf(" tail exists");
  }
  if ( !res1chan && (p_chan_hdr && (p_chan_hdr->flags & OM_CH_bigchan))) {
    printf(" bigchan");
  }

  printf("\n");

  if (! p_chan_hdr )
  {
    if (tdef->w_flags & (CD_m_m|CD_1_m)) 
    {
      printf(" collapse_count=0 last_index=0 depth=0 VLA_sz=0\n");
    }
    else
    {
      printf(" NO CONNECTION\n");
    }
    return (OM_S_SUCCESS);
  }

  if (tdef->w_flags & (CD_1_1|CD_m_1))        /* singleton? */
  {
    if ( tdef->w_flags & CD_restricted )
    {
      som_show_res_link(tdef, p_chan_hdr);
    }
    else
    {
      link = (OM_p_CHANNEL_LINK)(p_chan_hdr);
      if (IF_NULL_OBJID(link->objid)) 
      {
        printf(" NO CONNECTION\n");
      }
      else 
      {
        som_show_chlink(os, link);
      }
    }
  }   /* end if singleton */         
  else 

  {  /* not singleton */

    OM_GET_TAIL(p_chan_hdr, tail);

    printf(" collapse_count=%d last_index=%d depth=%d VLA_sz=%d\n",
   	   tail.collapse_count, tail.last_index, 
           (p_chan_hdr->flags&OM_CH_in_use)?1:0,tail.size);

    if ( p_chan_hdr->flags & OM_CH_restricted )
    {
     p_objid = OM_PTR_TO_RESCHAN_LINK(p_chan_hdr);
     for (ii=0; ii < tail.last_index; ii++, p_objid++) 
     {
       if (IF_NULL_OBJID(*p_objid)) 
       {
	  printf(" HOLE\n");
       }
       else 
       {
	  som_show_res_link(tdef, *p_objid);
       }
     }
   }   /* end if restricted channel */
   else
   {
     link = OM_PTR_TO_CHAN_LINK(p_chan_hdr);
     for (ii=0; ii < tail.last_index; ii++, link++) 
     {
       if (IF_NULL_OBJID(link->objid)) 
       {
	  printf(" HOLE\n");
       }
       else 
       {
	  som_show_chlink(os, link);
       }
     }
   }   /* end if not restricted channel */
 
 }  /* end if not singleton */

  return(OM_S_SUCCESS);

 }
/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++ som_show_chlink */
int som_show_chlink(os, link)
 OMuword os;
 OM_p_CHANNEL_LINK link;
 {
  int     sts;
  OMuword os1, flg;
  OM_S_OBJID oid;
  OM_S_CHANNUM ch;

  if ( link->hdr.flags & OM_CL_to_object )
    {
    printf("  To object objid=%2d,%3d",os,link->objid);
    printf(" channum=%d.%d\n",link->channum.classid,link->channum.number);
    }
  else 
    {
    sts = som_ISO_fetch(os, link->hdr.u1.isoindex, link->objid, 
                        &os1, &oid, &ch, &flg);
    if (sts == OM_I_LOGICAL_DISCONNECT) return (OM_S_SUCCESS);
    printf("  To ISO objid=%2d  index=%3d",link->objid,link->hdr.u1.isoindex);
    printf(" channum=%3d.%2d target is %2d,%3d\n",
				ch.classid,ch.number,os1,oid);
  }
  return(OM_S_SUCCESS);
 }

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++ som_show_res_link */
int som_show_res_link(tdef,objid )
  OM_p_CHANNEL_TYPE_DEFN   tdef;
  OM_S_OBJID		   objid;
 {
    if (tdef->w_flags & (CD_1_1|CD_m_1)) objid = objid >> 1;
    printf("  To object objid= %3d", objid);
    printf(" channum=%d.%d\n",tdef->channum.classid,tdef->channum.number);

  return(OM_S_SUCCESS);
 }

/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++ som_show_object */
int som_show_object (os, oid)
 OMuword    os;
 OM_S_OBJID oid;
 {
  OM_p_CLASSDEF p_cld;
  OM_S_RIP	rip;
  int 		ii, jj, sts;
  OM_p_OBJECTHDR ins;
  OM_p_SPAMAPENT spa;

  printf("\n-----> SHOW OBJECT ----> (%d,%d)\n",os,oid);
  sts = om$get_any_instance(osnum = os, objid = oid, p_rip = &rip);
  if (sts != OM_S_SUCCESS) {
    om$report_error(sts=sts);
    return(sts);
  }
  ins = rip.p_object;
  spa = rip.p_mapentry;
  printf(" filed_id=%d size=%d cluster_id=%d send depth elevated=",
		OM_GA_OSDs[os]->ActToFil[spa->p_acld->w_classid], 
		OM_GETOBJSIZE(ins->i_size), 
		OM_GA_CSDarray[spa->sdi].p_pcd->p_lcd->w_cluster_num);
  if(spa->flags & OM_SM_send_depth) printf("True\n");
  else 				    printf("False\n");
  if (OM_OBJ_HAS_VLA(ins->i_size)) {
    printf(" Has_VLA");
  }
  if (spa->flags & OM_SM_array_mod) {
    printf(" Array_mod");
  }
  if (spa->flags & OM_SM_Rootdel_pending) {
    printf(" Rootdel_pending");
  }
  if (spa->flags & OM_SM_has_di_name) {
    printf(" Has_di_name");
  }
  printf(" )\n");
  om$get_class(osnum = os, object = ins, pp_cld = &p_cld);
  printf(" active_id=%d name=\"%s\"\n",p_cld->w_classid,p_cld->s_name);
  printf(" base=%d max=%d trans=(",p_cld->w_baseclass,p_cld->w_maxclass);
  jj = p_cld->w_maxclass - p_cld->w_baseclass;
  for (ii=0; ii<=jj; ii++) {
    if (p_cld->p_transmap[ii] != OM_K_NULL_TRANS) {
      printf(" %d/%d",(p_cld->w_baseclass + ii),p_cld->p_transmap[ii]);
    }
  }
  printf(" )\n");
  som_show_all_channels(os, ins, p_cld);
  om$release_any_instance( osnum = os, rip = rip);
  return(OM_S_SUCCESS);
 }

#ifdef DONTCOMPILETILLFIXED
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++ OM_show_ancestry */
void OM_show_ancestry (OSnum, objid, p_cld, header, format)
OMuword			OSnum;
OM_S_OBJID		objid;
OM_p_CLASSDEF		p_cld;
char			*header;
char			*format;

{
  OM_p_CLASSDEF		p_daddy;
  char			OSname[OM_K_MAXOSNAME_LEN];
  
  if (!(1&OM_convert_OS_number_to_name (OSnum, OSname)))
  {
    strcpy (OSname, "Unknown ObjSpace (!)");
  }
  
  printf ("%s %x in ObjSpace: %s\n%s%s", 
    header, objid, OSname, format, p_cld -> s_name);
  p_daddy = p_cld->p_ancestor;
  while (p_daddy != NULL)
  {
    printf (", \n%s son of %s", format, p_daddy -> s_name);
    p_daddy = p_daddy -> p_ancestor;
  }
  printf ("\n");
}
#endif

method ARwrite( int *return_code; int starting )

{

return(OM_S_SUCCESS);

}

method ARread( int *return_code; char *keyword )

{

return(OM_S_SUCCESS);

}

end	implementation	Root;
