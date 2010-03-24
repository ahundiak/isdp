/*
---------------------------------------------------------------------------

	Name:			OMconnect.c
	Author:			kerry Kilbride
	Creation Date:		17-jun-1986
	Operating System(s):	Unix SYSV, v2
	Abstract:

	This module contains OM channel connect and disconnect method
	helper subroutines routines.

	NOTE:  #define DEBUG to compile in routine entry debug prints.
	       #define DEBUGx to compile in routine exit debug prints.

		extern int OM_Gi_conn_debug is used to determine whether
				or not prints will be made.  If 0 then
				no prints; if != 0 then debug output
				will go to std out.  Default is 0;


---------------------------------------------------------------------------

	Revision History:
	kek001	01-jun-1986	Completely new for OM 4.0
        geo001  18-feb-1987     Add vla_collapse check optimization
        rme001  05-may-1987     Removed move array routine.
        ems001  08-may-1987     Added restricted channel mods.
*/

#include	"exsysdep.h"
#include	<stdio.h>
#include	<string.h>
#include	"OMobjectcomm.h"
#include	"OMrelation.h"
#include	"OMintprims.h"
#include        "OMmetaclass.h"

#ifdef BIG_ENDIAN
#include	"OMport.h"
extern int	OM_Gf_ioMode;
extern void	*OM_Gp_inst_in;
extern void	*OM_Gp_inst_out;
#endif

extern void som_show_object();
extern int som_ISOdir_get_iso();
extern int som_ISOdir_find_iso();
extern int som_ISO_mark_entry();
extern int som_ISO_add_entry();
extern int som_ISO_fillside();
extern int som_ISO_check_empty();
extern int som_perhaps_remove_tagcon_rec();

extern int    OM_Gi_percent_extend_chan;
extern int    OM_Gi_maxchan_size;
extern int    OM_Gi_defchan_size;
extern int    OM_Gi_defchan_ext;
extern OMuint OM_Gi_tagcon_slot;
extern int    OM_setdim_validate_counter;
extern OMuword OMOSCO_OPP_get_res_cnum_method_index;
extern OMuword OMOSCO_OPP_get_chan_info_method_index;
extern OMuword OMOSCO_OPP_get_all_vla_info_method_index;

#ifdef DEBUG
       int    OM_Gi_conn_debug = 0;
#endif


/*
  som_collapse_channel
  --------------------

  Called to reduce channel array size after a disconnect.  If channel
  send depth is zero will remove internal "holes" (not for absordered).
  In any case will remove any "holes" at end of array.  Will reduce
  array size if new size is below an extend size.
*/
  
 int som_collapse_channel(
 OMuword           os,		/* OS number of oid */
 OM_S_OBJID        oid,		/* object containing channel */
 OM_p_CHANNEL_HDR  *pp_chan,	/* channel to collapse */
 OM_p_CHANNEL_DEFN chdef,	/* definition of channel */
 int               *p_chandata, /* ptr to channel data */
 OM_p_BIG_TAIL      p_tail,     /* ptr to channel tail */
 OM_p_CLASSDEF      p_acld)     /* ptr classdef */

 {
  OM_p_CHANNEL_LINK link1, link2, link3, link4;
  OM_p_OBJID        olink1, olink2, olink3, olink4;
  int sts;
  OMuint hole_size, chan_count, null_cnt;
  int need, size;
  int in_size, ex_size;
  OM_S_CONNECT_SIDE s1;
  OM_p_CHANNEL_HDR chan = *pp_chan;
  OMuint limit, orig_li, orig_cc, mv_src;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_collapse_channel os=%d oid=%d, chan=%#x chdef=%#x\n",
		os,oid,chan,chdef);
 }
#endif

  if (chan->flags & (OM_CH_in_use|OM_CH_preset)) {
    om$connect_add_tail (p_chan=chan, p_chandata=p_chandata, tail=p_tail);
    return (OM_S_SUCCESS);
  }

  orig_li = p_tail->last_index;
  orig_cc = p_tail->collapse_count;
  if (p_tail->last_index) {
    if (chan->flags & OM_CH_absordered) {
      if (chan->flags & OM_CH_restricted) {
        olink1 = (OM_p_OBJID)p_chandata + (p_tail->last_index-1);
        while (((int*)olink1 >= p_chandata) && (IF_NULL_OBJID(*olink1))) --olink1;
        p_tail->last_index = ((OMuint)(olink1+1) - (OMuint)p_chandata) /
                              sizeof(OM_S_OBJID);
      }
      else {
        link1 = (OM_p_CHANNEL_LINK)p_chandata + (p_tail->last_index-1);
        while (((int*)link1 >= p_chandata) && (IF_NULL_OBJID(link1->objid))) --link1;
        p_tail->last_index = ((OMuint)(link1+1) - (OMuint)p_chandata) /
                              sizeof(OM_S_CHANNEL_LINK);
      }
    }
    else {  /* rel ordered or standard channel */
      if (orig_cc) {
        if (chan->flags & OM_CH_restricted) {
          olink1 = olink2 = (OM_p_OBJID)p_chandata;
          olink3 = olink1 + p_tail->last_index;
          while ((olink1 < olink3) && (! IF_NULL_OBJID(*olink1))) ++olink1;
          olink4 = olink1;
          olink2 = olink1 + 1;
          while (olink2 < olink3 && p_tail->collapse_count) {
            while ((olink2 < olink3) && (IF_NULL_OBJID(*olink2))) ++olink2;
            if (olink2 == olink3) break;
            hole_size = (OMuint)olink2 - (OMuint)olink1;
            null_cnt = (OMuint)olink2 - (OMuint)olink4;
            ++olink2;
            while ((olink2 < olink3) && (! IF_NULL_OBJID(*olink2))) ++olink2;
            OM_BLOCK_MOVE ((OMuint)olink1 + hole_size, olink1,
                        (OMuint)olink2 - (OMuint)((OMuint)olink1 + hole_size));
            olink1 = (OM_p_OBJID)((OMuint)olink2 - hole_size);
            olink4 = olink2;
            ++olink2;
            p_tail->collapse_count -= (null_cnt / sizeof(OM_S_OBJID));
          }
          p_tail->collapse_count = 0;
          p_tail->last_index = orig_li - orig_cc;
          if (olink2 < olink3 ) {
            mv_src = (OMuint)olink1 + (orig_cc * sizeof(OM_S_OBJID));
            OM_BLOCK_MOVE ( mv_src, olink1, (OMuint)olink3 - mv_src );
          }
        }
        else {
          link1 = link2 = (OM_p_CHANNEL_LINK)p_chandata;
          link3 = link1 + p_tail->last_index;
          while ((link1 < link3) && (! IF_NULL_OBJID(link1->objid))) ++link1;
          link4 = link1;
          link2 = link1 + 1;
          while (link2 < link3 && p_tail->collapse_count) {
            while ((link2 < link3) && (IF_NULL_OBJID(link2->objid))) ++link2;
            if (link2 == link3) break;
            hole_size = (OMuint)link2 - (OMuint)link1;
            null_cnt = (OMuint)link2 - (OMuint)link4;
            ++link2;
            while ((link2 < link3) && (! IF_NULL_OBJID(link2->objid))) ++link2;
            OM_BLOCK_MOVE ((OMuint)link1 + hole_size, link1,
                          (OMuint)link2 - (OMuint)((OMuint)link1 + hole_size));
            link1 = (OM_p_CHANNEL_LINK)((OMuint)link2 - hole_size);
            link4 = link2;
            ++link2;
            p_tail->collapse_count -= (null_cnt / sizeof(OM_S_CHANNEL_LINK));
          }
          p_tail->collapse_count = 0;
          p_tail->last_index = orig_li - orig_cc;
          if (link2 < link3 ) {
            mv_src = (OMuint)link1 + (orig_cc * sizeof(OM_S_CHANNEL_LINK));
            OM_BLOCK_MOVE ( mv_src, link1, (OMuint)link3 - mv_src );
          }
        }
      }
    }
  }

 /* reduce size of vla if falling below an extend size or to zero */
 
 need = p_tail->last_index;
 if ( chan->flags & OM_CH_bigchan )
   size = p_tail->size;
 else
   size = chan->u1.count;
 chan_count = size;
 if ( need < size ) { /* may need to reduce */
   in_size = chdef->p_type->InitCount;
   if ( in_size == -1 ) {
      in_size = OM_Gi_defchan_size;
   }
   ex_size = chdef->p_type->ExtCount;
   if ( ex_size == -1 ) {
      ex_size = OM_Gi_defchan_ext;
   }

   limit = ((size * (OM_Gi_percent_extend_chan+10))/100);
   if ( limit > (OMuint) ex_size ) ex_size = limit;
   
   if ( ! need ) {
      size = 0;		/* empty - collapse to zero */
   }
   else {
      if ( need < in_size) {
	need = in_size;    /* need at lease Init if need any */
      }
      while ( need < (size - ex_size)) {
	size -= ex_size;   /* reduce by extend size until small enough */
      }
   }
   if ( (OMuint) size < chan_count ) { /* do need to reduce */
     sts = om$get_any_instance(osnum = os, objid = oid, p_rip = &s1.rip);
     if ( ! (1 & sts) ) {
	om$report_error(sts=sts);
	BUGCHECK("som_collapse_channel: no instance for oid");
	return(OM_F_BUGCHECK);
     }
     if (p_acld) {
       s1.p_cld = p_acld;
     }
     else {
       sts = om$get_class(osnum=os, object=s1.rip.p_object, pp_cld=&s1.p_cld);
       if (!(1&sts)) {
         return(sts);
       }
     }

     s1.osnum      = os;
     s1.objid      = oid;
     s1.chdef      = chdef;
     s1.p_chandata = p_chandata;
     s1.pp_chan    = pp_chan;

     sts = om$connect_chan_alloc ( side1 = &s1,
                                   num_ents = size );
     if ( ! (1 & sts) ) {
	om$report_error(sts=sts);
	printf ("som_collapse_channel: om$connect_chan_alloc fail");
	return(sts);
     }
     pp_chan = s1.pp_chan;
     p_chandata = s1.p_chandata;
     om$release_any_instance (osnum = os, rip = s1.rip);
   } /* end if do need to reduce */
 }  /* end if may need to reduce */
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_collapse_channel\n");
 }
#endif

 if (*pp_chan) {
   om$connect_add_tail ( p_chan=*pp_chan, p_chandata=p_chandata, tail=p_tail);
 } 
 return(OM_S_SUCCESS);
 }


/*
  som_connect_build_side
  ----------------------
 
  Private subroutine used by connect and disconnect methods.
  Builds first part of OM_S_CONNECT_SIDE structure using parameters
  supplied to a method that describe one "side" of a connect or
  disconnect operation.  
*/

 int som_connect_build_side(
 OMuword os,			/* OS number of object */
 OM_S_OBJID oid,		/* object containing channel */
 OM_p_CHANSELECT chsel,		/* channel descriptor that defines
				   which channel in object to use */
 int relidx,			/* relative index for ordered channels
				   ! note ! - reverse association from 
				   that used when method called.  This
				   index will be used to find an entry
				   slot in THIS channel. */
 OM_p_CONNECT_SIDE s1)		/* points to structure that will be
				   built using supplied parameters */

 {
  int sts;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_build_side os=%d oid=%d, chsel.type=",os,oid);
  switch (chsel->type) {
   case OM_e_name:
      printf("NAME");
      break;
   case OM_e_num:
      printf("NUMBER");
      break;
   case OM_e_addr:
      printf("ADDRESS");
      break;
   default:
      printf("UNKNOWN");
   }
   printf(" relidx=%d\n",relidx);
 }
#endif

  s1->osnum = os;
  s1->objid = oid;
  s1->relidx = relidx;
  s1->status = OM_S_SUCCESS;
  s1->pp_chan = NULL;
  s1->p_chlink = NULL;
  s1->chused = TRUE;
  s1->iso_objid = NULL_OBJID;
  s1->iso_index = 0;
  s1->p_chandata = 0;
  s1->tail.last_index = 0;
  s1->tail.collapse_count = 0;
  s1->chdef = 0;            /* for release side and unk class */

  sts = om$get_any_instance(osnum = os, objid = oid, p_rip = &s1->rip);
  if (!(1&sts)) {
    s1->rip.p_object = NULL;  /* to avoid release_any_instance attempt */
    return(sts);
  }
  sts = om$get_class(osnum=os, object=s1->rip.p_object, pp_cld=&s1->p_cld);
  if (!(1&sts)) {
    return(sts);
  }

  sts = om$get_channel(osnum = os, object = s1->rip.p_object,
		       p_chanselect = chsel, pp_channel = &s1->pp_chan,
		       pp_chandef = &s1->chdef, pp_chandata=&s1->p_chandata,
                       p_channum = &s1->channum, p_tail=&s1->tail );
  if (!(1&sts)) {
    s1->chdef = 0;            /* for release side and unk class */
    return(sts);
  }

  s1->channum.classid = OM_GA_OSDs[os]->ActToFil[s1->channum.classid];

#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_build_side\n");
  som_connect_show_side(NULL,s1);
 }
#endif
  return(OM_S_SUCCESS);
 }



/*
  som_connect_build_fake_side
  ---------------------------
 
  Private function used to create a side struct for unknown classes.
  Typically called from som_connect_pside when wild disconnecting an
  unknown class from an object that is being deleted.
*/

 int som_connect_build_fake_side (os, oid, channum, channame, other_cnum, s1)

 OMuword os;			/* OS number of object */
 OM_S_OBJID oid;		/* object containing channel */
 OM_S_CHANNUM channum;          /* channel number (if channame is NULL) */
 char *channame;                /* channel name (for restricted targets) */
 OM_S_CHANNUM other_cnum;       /* channel number of known side */
 OM_p_CONNECT_SIDE s1;		/* points to structure that will be
				   built using supplied parameters */

 {
  int             sts, compoff, chanoff;
  char           *dot_pos;
  OMuword         chtyp, i;
  OM_p_OSCO      *p_OSCOlist;
  OM_S_OBJID      OSCO_oid;
  OM_S_MESSAGE    msg;
  OM_S_CHANSELECT csel;

  struct sd_get_chan_args {
     OMuword       fil_classid;
     OM_S_CHANNUM  channum;
     int          *p_compoff;
     int          *p_chanoff;
     OMuword      *p_type;
  } get_chan_args;  

  struct sd_get_res_cnum_args {
     OMuword  cnum;
     OMuword *res_cnum;
  } get_res_cnum_args;

  struct sd_get_all_vla_args {
     OMuword              fil_classid;
     OMuint              *p_fixed_size;
     OM_p_VARLENARR_DEFN *pp_vad;
     OMuword             *num_vla;
  } get_all_vla_args;


  s1->osnum = os;
  s1->objid = oid;
  s1->relidx = 0;
  s1->status = OM_S_SUCCESS;
  s1->pp_chan = NULL;
  s1->p_chlink = NULL;
  s1->chused = TRUE;
  s1->iso_objid = NULL_OBJID;
  s1->iso_index = 0;
  s1->p_chandata = 0;
  s1->tail.last_index = 0;
  s1->tail.collapse_count = 0;

  sts = om$get_any_instance(osnum = os, objid = oid, p_rip = &s1->rip);
  if (!(1&sts)) {
    s1->rip.p_object = NULL;  /* to avoid release_any_instance attempt */
    return(sts);
  }

  /*=================================================*/
  /* allocate a channel defn and a channel type defn */
  /*=================================================*/

  if (!(s1->chdef = om$malloc(structure=OM_S_CHANNEL_DEFN))) {
     return (OM_E_NODYNMEM);
  }
  if (!(s1->chdef->p_type = om$malloc(structure=OM_S_CHANNEL_TYPE_DEFN))) {
     return (OM_E_NODYNMEM);
  }

  /*=============================================================*/
  /* if channame given then restricted to unknown class' channel */
  /*=============================================================*/

  if (channame) {
     /*==============================================================*/
     /* send to OSCO of other_cnum.classid to get restricted channum */
     /*==============================================================*/

     msg.select.DefClassid = OM_K_OMOSCO_ACTCLASSID;
     msg.select.ReqClassid = OM_K_OMOSCO_ACTCLASSID;
     msg.select.FuncIndex  = OMOSCO_OPP_get_res_cnum_method_index;
     msg.size              = sizeof(struct sd_get_res_cnum_args);
     msg.p_arglist         = (char *)&get_res_cnum_args;

     get_res_cnum_args.cnum = other_cnum.number;
     get_res_cnum_args.res_cnum = &channum.number;

     OSCO_oid = OM_GA_OSDs[os]->OSCO_list[OM_GA_OSDs[os]->FilToAct[other_cnum.classid]]->OSCO_oid;

     sts = om$send ( msg = &msg,
                     senderid = OSCO_oid,
                     targetid = OSCO_oid,
                     targetos = os );
     if (!(1&sts)) {
        om$dealloc (ptr = (char *) s1->chdef->p_type);
        om$dealloc (ptr = (char *) s1->chdef);
        return (sts);
     }

     /*============================================================*/
     /*  in case this is a known component's channel look thru     */
     /*  the active OSCO list to see if we can find the classname  */
     /*============================================================*/

     dot_pos = (char *) strchr(channame,'.');
     *dot_pos = 0;
     p_OSCOlist = OM_GA_OSDs[os]->OSCO_list;

     for (i=0; i<OM_Gw_numclasses; ++i) {
        if (p_OSCOlist[i] && (!strcmp(channame,p_OSCOlist[i]->s_name))) break;
     }

     /*=============================================================*/
     /*  check if we did not find the channel in a known component  */
     /*=============================================================*/

     if ( i == OM_Gw_numclasses ) {
        channum.classid = (OMuword)OM_GA_OSDs[os]->Spacemap[oid].p_acld;
     }
     else {
        channum.classid = p_OSCOlist[i]->w_classid;
     }
     *dot_pos = '.';  /* restore dot (although channame not used further) */
  }

  /*===============================================*/
  /*  gather vla info to create vla_defns in acld  */
  /*===============================================*/

  if (!(s1->p_cld = om$calloc(structure=OM_S_CLASSDEF))) {
     om$dealloc (ptr = (char *) s1->chdef->p_type);
     om$dealloc (ptr = (char *) s1->chdef);
     return (OM_E_NODYNMEM);
  }

  msg.select.DefClassid = OM_K_OMOSCO_ACTCLASSID;
  msg.select.ReqClassid = OM_K_OMOSCO_ACTCLASSID;
  msg.select.FuncIndex  = OMOSCO_OPP_get_all_vla_info_method_index;
  msg.size              = sizeof (struct sd_get_all_vla_args);
  msg.p_arglist         = (char *)&get_all_vla_args;

  csel.u_sel.name = "OMObjSpace.to_OSCOs";
  csel.type = OM_e_name;

  get_all_vla_args.fil_classid = (OMuword)s1->rip.p_mapentry->p_acld;
  get_all_vla_args.p_fixed_size = &s1->p_cld->i_instance_size;
  get_all_vla_args.pp_vad      = &s1->p_cld->p_varlenarr_defns;
  get_all_vla_args.num_vla     = &s1->p_cld->w_num_varlenarrays;  

  sts = om$send ( msg = &msg,
                  senderid = 0,
                  p_chanselect = &csel,
                  targetos = os );
  if (!(1&sts)) {
     om$dealloc (ptr = (char *) s1->chdef->p_type);
     om$dealloc (ptr = (char *) s1->p_cld);
     om$dealloc (ptr = (char *) s1->chdef);
     return (sts);
  }

  /*=============*/
  /*  vla fixup  */
  /*=============*/

  s1->p_cld->w_classid = (OMuword)s1->rip.p_mapentry->p_acld;
  s1->rip.p_mapentry->p_acld = s1->p_cld;

#ifdef BIG_ENDIAN
  OM_Gf_ioMode   = READ_PORT;
  OM_Gp_inst_in  = s1->rip.p_object;
  OM_Gp_inst_out = s1->rip.p_object;

  sts = som_endian_vla_fixup ( s1, 'r' );
  if (!(1&sts)) return (sts);
#endif
#ifdef LITTLE_ENDIAN
  sts = om$vla_fixup (p_object=s1->rip.p_object, type='r');
  if (!(1&sts)) return (sts);
#endif

  /*===========================================================*/
  /* send down OSCO channel find channel info of unknown class */
  /*===========================================================*/

  msg.select.DefClassid = OM_K_OMOSCO_ACTCLASSID;
  msg.select.ReqClassid = OM_K_OMOSCO_ACTCLASSID;
  msg.select.FuncIndex  = OMOSCO_OPP_get_chan_info_method_index;
  msg.size              = sizeof(struct sd_get_chan_args);
  msg.p_arglist         = (char *)&get_chan_args;

  get_chan_args.channum     = channum;
  get_chan_args.fil_classid = get_all_vla_args.fil_classid;
  get_chan_args.p_compoff   = &compoff;
  get_chan_args.p_chanoff   = &chanoff;
  get_chan_args.p_type      = &chtyp;

  sts = om$send ( msg = &msg,
                  senderid = 0,
                  p_chanselect = &csel,
                  targetos = os );
  if (!(1&sts)) {
     om$dealloc (ptr = (char *) s1->chdef->p_type);
     om$dealloc (ptr = (char *) s1->p_cld);
     om$dealloc (ptr = (char *) s1->chdef);
     return (sts);
  }

  s1->chdef->i_offset = compoff + chanoff;
  s1->chdef->p_type->w_flags = chtyp;
  s1->chdef->p_type->ExtCount = OM_K_MAXINT;
  s1->chdef->p_type->InitCount = 0;
  s1->chdef->p_type->ClassCount = 0;

  /*=============================================*/
  /*  now we must do that som_get_channel thing  */
  /*=============================================*/

  s1->pp_chan = (OM_p_CHANNEL_HDR *)((OMuint)s1->rip.p_object + s1->chdef->i_offset);

#ifdef BIG_ENDIAN
  /*  do vla fixup reverse and convert the value -- except for res1chan  */

  if (!((chtyp & CD_restricted) && (chtyp & (CD_1_1 | CD_m_1)))) { 
    *s1->pp_chan = (OM_p_CHANNEL_HDR)((int)*s1->pp_chan - (int)s1->pp_chan);
    OMPORT_CONV_INT ( s1->pp_chan, 1 );
  }

  sts = som_convert_channel ( s1->pp_chan );
  if (!(1&sts)) return (sts);

  /*  do vla fixup  -- except for res1chan  */

  if (!((chtyp & CD_restricted) && (chtyp & (CD_1_1 | CD_m_1)))) { 
    *s1->pp_chan = (OM_p_CHANNEL_HDR)((int)*s1->pp_chan + (int)s1->pp_chan); 
  }
#endif

  if ((chtyp & CD_restricted) && (chtyp & (CD_1_1 | CD_m_1))) { /* res1chan */
    s1->p_chandata = (int *)s1->pp_chan;
    s1->tail.last_index = 1;
    s1->tail.collapse_count = 0;
    s1->tail.size = 0;
  }
  else if (chtyp & (CD_1_1 | CD_m_1)) { /* singleton */
    s1->p_chandata = (int *)*s1->pp_chan;
    s1->tail.last_index = 1;
    s1->tail.collapse_count = 0;
    s1->tail.size = 0;
  }
  else {     
    s1->p_chandata = (int *)((OMuint)*s1->pp_chan + sizeof(OM_S_CHANNEL_HDR));
    if ((*s1->pp_chan)->flags & OM_CH_bigchan)
      s1->p_chandata = (int *)((OMuint)s1->p_chandata + sizeof(OM_S_BIG_TAIL));
    OM_GET_TAIL(*s1->pp_chan, s1->tail);
  }

  /*===========================================================*/
  /*  mark side to detect that it represents an unknown class  */
  /*  and needs to perform cleanup in release_side             */
  /*===========================================================*/

  s1->chdef->s_name = 0;

#ifdef BIG_ENDIAN
  /*================================================================*/
  /*  This block-o-code is a quick kludge to fix an unknown object  */
  /*  problem on BIG ENDIAN machines.  This only recipient of this  */
  /*  kludge is the function som_aligned_vla_size in OMvararray.C   */
  /*  Essentailly we are marking the channels which are not part    */
  /*  of this build_fake_side so that we know to convert the two    */
  /*  shorts in the header in that function -- and of course it     */
  /*  will also convert the shorts back                             */
  /*================================================================*/

  for (i=0; i<s1->p_cld->w_num_varlenarrays; ++i) {
     if (s1->p_cld->p_varlenarr_defns[i].type == 1) {   /* channel */
        if (s1->p_cld->p_varlenarr_defns[i].w_offset != s1->chdef->i_offset) {
           s1->p_cld->p_varlenarr_defns[i].w_count = 27977;
        }
     }
  }
#endif

  return(OM_S_SUCCESS);
 }



/*
  som_connect_release_fake
  ------------------------
 
  Private function used to cleanup a side struct for unknown classes.
  Typically called from som_connect_release_pside.
*/

 int som_connect_release_fake (s1)

 OM_p_CONNECT_SIDE s1;		/* points to side to be cleaned up */
 {
   int sts;
   OM_GA_OSDs[s1->osnum]->Spacemap[s1->objid].flags &= ~OM_SM_array_mod;

#ifdef BIG_ENDIAN
   OM_Gf_ioMode   = WRITE_PORT;
 
   sts = som_endian_vla_fixup ( s1, 'w' );
   if (!(1&sts)) return (sts);

   sts = OMPORT_CONV_INT ( s1->pp_chan, 1);
   if (!sts) return (OM_E_ERROR);

   sts = som_convert_channel ( s1->pp_chan );
   if (!(1&sts)) return (sts);

   OM_Gp_inst_in  = 0;
   OM_Gp_inst_out = 0;
#endif
#ifdef LITTLE_ENDIAN
   sts = om$vla_fixup (p_object=s1->rip.p_object, type='w');
#endif

   s1->rip.p_mapentry->p_acld = (OM_p_CLASSDEF)s1->p_cld->w_classid;
   
   om$dealloc ( ptr = (char *) s1->p_cld );
   om$dealloc ( ptr = (char *) s1->chdef->p_type );
   om$dealloc ( ptr = (char *) s1->chdef );

   return (OM_S_SUCCESS);
 }




/*
  som_connect_check_classlist
  ---------------------------
 
  Private subroutine used by connect and disconnect methods.
  Validate that connection is allowed between s1 and s2 based
  on class list specified in channel.
*/

 int som_connect_check_classlist (s1, s2)

 OM_p_CONNECT_SIDE  s1;		/* structure describing object and channel
				   on one "side" of a proposed connection */
 OM_p_CONNECT_SIDE  s2;		/* structure describing object and channel
				   on other "side" */
 {
  int ii, cnt;
  OMuword **cls, tcls;
  OM_p_CLASSDEF pcld;

 	/* check s1 channel will allow s2 target */
  cnt = s1->chdef->p_type->ClassCount;
  if ( cnt ) {  /* if not wild card */
    if (s1->chdef->p_type->w_flags & CD_restricted ) {
      if (( s1->osnum != s2->osnum ) ||
          (s1->chdef->p_type->channum.classid !=
           OM_GA_OSDs[s2->osnum]->FilToAct[s2->channum.classid]) ||
          (s1->chdef->p_type->channum.number != s2->channum.number))
        return(FALSE);
    }
    else {
      pcld = s2->p_cld;
      cls  = s1->chdef->p_type->classids;
      for (ii=cnt; ii > 0 ; ii--) {
         tcls = **cls++;
         if (tcls < pcld->w_baseclass || tcls > pcld->w_maxclass) {
  	   continue;
         }
         if (OM_K_NULL_TRANS != pcld->p_transmap[tcls - pcld->w_baseclass]) {
	   break;
         }
      }
      if ( ! ii ) {
        return(FALSE);  /* s1 will not accept s2 target */
      }
    }
  }
 	/* check s2 channel will allow s1 target */
  cnt = s2->chdef->p_type->ClassCount;
  if ( ! cnt ) {  /* wild card */
    return(TRUE);
  }
  if (s2->chdef->p_type->w_flags & CD_restricted ) {
    if (( s1->osnum != s2->osnum ) ||
        (s2->chdef->p_type->channum.classid !=
         OM_GA_OSDs[s1->osnum]->FilToAct[s1->channum.classid]) ||
        (s2->chdef->p_type->channum.number != s1->channum.number))
      return(FALSE);
    else
      return(TRUE);
  }
  else {
    pcld = s1->p_cld;
    cls  = s2->chdef->p_type->classids;
    for (ii=cnt; ii > 0 ; ii--) {
      tcls = **cls++;
      if (tcls < pcld->w_baseclass || tcls > pcld->w_maxclass) {
        continue;
      }
      if (OM_K_NULL_TRANS != pcld->p_transmap[tcls - pcld->w_baseclass]) {
        return(TRUE);
      }
    }
  }
  return(FALSE);  /* s2 will not accept s1 target */
 }
/*



/*
  som_connect_complete_sides
  --------------------------

  Private subroutine used by connect and disconnect methods.
  First a side structure is built for each side separately using
  som_connect_build_side.  Then both sides are examined here for
  the possiblity of an across object space "ISO" connection.
  If it is an ISO type connection then the ISO objid for each side
  will be located and is objid placed in its associated side structure.
*/  

 int som_connect_complete_sides (s1, s2)

 OM_p_CONNECT_SIDE  s1;		/* structure describing object and channel
				   on one "side" of a proposed or actual
				   connection */
 OM_p_CONNECT_SIDE  s2;		/* structure describing object and channel
				   on other "side" */
 {
  int sts;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_complete_sides\n");
 }
#endif
  if (s1->osnum != s2->osnum) {  /* within object space case */
    sts = som_ISOdir_get_iso(s1->osnum,s2->osnum,&s1->iso_objid);
    if (!(1 & sts)) {
       om$report_error(sts=sts);
       BUGCHECK("som_connect_complete_sides: som_ISOdir_get_iso fail");
       return(OM_F_BUGCHECK);
    }
    sts = som_ISOdir_find_iso(s2->osnum,s1->osnum,&s2->iso_objid);
    if (!(1 & sts)) {
       om$report_error(sts=sts);
       BUGCHECK("som_connect_complete_sides: som_ISOdir_find_iso fail");
       return(OM_F_BUGCHECK);
    }
  }
  else {
    s1->iso_objid = NULL_OBJID;
    s2->iso_objid = NULL_OBJID;
  }
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_complete_sides\n");
 }
#endif
  return (OM_S_SUCCESS);
 }



/*
  som_connect_disconnect
  ----------------------

  Called when an object/channel described by a "side" structure
  is to be disconnected.  If there is an ISO connection then the
  ISO entry is "marked" for disconnect.  The the chused field
  is set FALSE.  This will cause the channel entry to be returned
  when the side is released. Side 2 is used only to detect a logical
  disconnection between RO and RW object spaces.
*/

 int som_connect_disconnect(s1, s2 )

 OM_p_CONNECT_SIDE  s1;		/* structure describing object, channel,
				   and channel entry on one "side" of an 
				   existing connection */
 OM_p_CONNECT_SIDE  s2;         /* same structure for for other "side" */
 {
  int sts;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_disconnect\n");
  som_connect_show_side("  side1 ",s1);
 }
#endif
  if (!IF_NULL_OBJID(s1->iso_objid)) {
     sts = som_ISO_mark_entry(s1->osnum, s1->iso_objid, s1->iso_index,
                              s2->osnum, s1, s2);
     if (!(1 & sts)) {
	om$report_error(sts=sts);
	BUGCHECK("som_connect_disconnect: som_ISO_mark_entry fail");
	return(OM_F_BUGCHECK);
     }
     s1->iso_objid = NULL_OBJID;
     if ((sts == OM_I_LOGICAL_DISCONNECT) || 
         (s2->osnum == (OMuword)OM_K_OSNOTHERE)) {
        s1->chused = TRUE;
     }
     else {
        s1->chused = FALSE;
     }

     sts = som_perhaps_remove_tagcon_rec ( s1, s2 );
     if (!(1&sts)) {
        om$report_error(sts=sts);
        printf("som_connect_disconnect:som_perhaps_remove_tagcon_rec fail\n");
     }
     else {
        sts = OM_S_SUCCESS;
     }
  }
  else {
     s1->chused = FALSE;
     sts = OM_S_SUCCESS;
  }
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_disconnect\n");
 }
#endif
  return(sts);
 }



/*
  som_connect_doconnect
  ---------------------

  Called when it has been determined that a connection is to be made.
  The side structures are complete with an availble channel entry
  allocated.  This routine will complete the channel linkage for side1
  including any necessary ISO connection.  Side2 will beused only to 
  determine the target of the connection.  
*/

 int som_connect_doconnect (s1, s2 )

 OM_p_CONNECT_SIDE  s1;		/* structure describing object, channel,
				   and channel entry of side to be 
				   connected */
 OM_p_CONNECT_SIDE  s2;		/* structure describing object, channel,
				   and channel entry of side that is the
				   target of side1 connection */
 {
  int sts;
  OM_p_CHANNEL_LINK link;
  OM_p_OBJID        olink;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_doconnect\n");
  som_connect_show_side("  side1 ",s1);
  som_connect_show_side("  side2 ",s2);
 }
#endif
  if (s1->chdef->p_type->w_flags & CD_restricted) {
    if (s1->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {    /* res1chan? */
      olink = (OM_p_OBJID)s1->pp_chan;
      *olink = (s2->objid << 1);
      *olink |= 1;
    }
    else {
      olink = (OM_p_OBJID)s1->p_chlink;
      *olink = s2->objid;
    }
  }
  else {  /* not restricted */
    link = s1->p_chlink;
    if ( ! IF_NULL_OBJID(s1->iso_objid) ) {
      sts = som_ISO_add_entry(s1->osnum, s1->iso_objid, s1->objid,
			     &s1->channum, &s1->iso_index, s2->osnum);
      if (!(1 & sts)) {
	om$report_error(sts=sts);
	BUGCHECK("som_connect_doconnect: som_ISO_add_entry fail");
	return(OM_F_BUGCHECK);
      }
      link->hdr.u1.isoindex  = s1->iso_index;
      link->objid            = s1->iso_objid;

      /* check if connect is via the TagCon reconnect method  */
      /* if so then reinstate the slot number in the chanlink */

      if (OM_Gi_tagcon_slot && (s1->osnum != OM_Gw_current_OS)) {
        link->channum.classid  = OM_K_NOTUSING_CLASSID;
        link->channum.number   = OM_Gi_tagcon_slot-1;  /* since 0 is valid */
      }
      else {
        link->channum.classid  = 0;
        link->channum.number   = 0;
      }
    }
    else { /* to another object in this OS */
      link->hdr.flags  |= OM_CL_to_object;
      link->objid     = s2->objid;
      link->channum   = s2->channum;
    }
  }
  s1->chused = TRUE;
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_doconnect\n");
 }
#endif
  return(OM_S_SUCCESS);
 }



/*
  som_connect_get_chent
  ---------------------

  Called to allocate a channel entry.  If the channel is a variable
  length array type it will be expanded if necessary.  If the channel
  is ordered the allocated link will be in the correct position.
  Side1 defines the object/channel for the link allocation which will
  be refelected by the contents of side1->p_chlink.
  Side2 will be used to check for legal fan in/out; no channel will
  be allocated for side2 
*/  

 int som_connect_get_chent(s1, s2 )

 OM_p_CONNECT_SIDE  s1;		/* structure describing object and channel
				   to receive allocated channel entry. */
 OM_p_CONNECT_SIDE  s2;		/* structure describing object and channel
				   that is target of side1 connection */
 {
  OM_p_CHANNEL_HDR  chan;
  OM_p_CHANNEL_LINK link;
  OM_p_OBJID        olink;
  int need;		/* channel size needed by this request */
  int in_size, ex_size;
  int oldsize, newsize;
  int sts, numents;
  int ii;
  OMuword s1def_flags;
  OMuint incr;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_get_chent\n");
  som_connect_show_side("  side1 ",s1);
  som_connect_show_side("  side2 ",s2);
 }
#endif

  /*======================================================*/
  /*  test to make sure that an object cannot connect to  */
  /*  itself on the exact same channel                    */
  /*======================================================*/

  if (s1->pp_chan == s2->pp_chan) return (OM_E_INVCHAN);

  s1def_flags = s1->chdef->p_type->w_flags;

  if ( !(*s1->pp_chan) ) { /* no channel allocated */
    if ( (s1def_flags & CD_restricted) &&
         (s1def_flags & (CD_1_1 | CD_m_1))) {
      s1->p_chlink = (OM_p_CHANNEL_LINK)s1->pp_chan;
      s1->chused   = FALSE;
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_get_chent\n");
  som_connect_show_side("  side1 ",s1);
  som_connect_show_side("  side2 ",s2);
 }
#endif
      return(OM_S_SUCCESS);
    }
    else {
      if (s1def_flags & (CD_1_1 | CD_m_1)) 
        numents = 1;
      else {
        numents = s1->chdef->p_type->InitCount;
        if (numents == -1) numents = OM_Gi_defchan_size;
        if (!numents) numents = s1->chdef->p_type->ExtCount;
        if (numents <= 0) numents = OM_Gi_defchan_size;
      }
      if (!(1&(sts = om$connect_chan_alloc ( side1 = s1,
                                             num_ents = numents )))) {
        return (sts);
      }
    }
  }

  if ((s1def_flags & CD_restricted) &&             /*  res1chan?  */
      (s1def_flags & (CD_1_1|CD_m_1))) {
    return(OM_E_EXCEEDFANOUT);
  }

  chan = *s1->pp_chan;
  if (chan->flags & OM_CH_full) {  /* connected and limited to single */
    return(OM_E_EXCEEDFANOUT);
  }
  if (chan->flags & OM_CH_singleton) {
    chan->flags |= OM_CH_full;
    s1->p_chlink = (OM_p_CHANNEL_LINK)s1->p_chandata;
    s1->chused   = FALSE;
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_get_chent\n");
  som_connect_show_side("  side1 ",s1);
  som_connect_show_side("  side2 ",s2);
 }
#endif
    return(OM_S_SUCCESS);
  }
	/* If other channel fan in/out spec would limit - must be empty */
  if (s2->chdef->p_type->w_flags & (CD_1_1 | CD_1_m)) {
    if (s1->tail.last_index) {
       return(OM_E_EXCEEDFANOUT);
    }
  }
	/* determine how big the channel must be to accomodate this request */
  if (chan->flags & OM_CH_absordered) {
    if (s1->relidx == OM_K_MAXINT) { 
      if (chan->flags & OM_CH_restricted) {
        olink = (OM_p_OBJID)s1->p_chandata + (s1->tail.size - 1);
        while (((char *) olink >= (char *) s1->p_chandata) &&
           (IF_NULL_OBJID(*olink))) --olink;
        ++olink;
        s1->relidx = ((OMuint)olink - (OMuint)s1->p_chandata) /
                       sizeof(OM_S_OBJID);
      }
      else {
        link = (OM_p_CHANNEL_LINK)s1->p_chandata + (s1->tail.size - 1);
        while (((char *) link >= (char *) s1->p_chandata) &&
           (IF_NULL_OBJID(link->objid))) --link;
        ++link;
        s1->relidx = ((OMuint)link - (OMuint)s1->p_chandata) /
                     sizeof(OM_S_CHANNEL_LINK);
      }
    }
    need = s1->relidx;
  }
  else if (chan->flags & OM_CH_relordered) {
    if (chan->flags & OM_CH_in_use) {
      need = s1->tail.last_index;
    }
    else {
      need = s1->tail.last_index - s1->tail.collapse_count;
    }
  }
  else {
    need = s1->tail.last_index;
  }
  need++; /* change from largest index to largest size */
  	/* enlarge channel var len array if and as needed */
  if ( chan->flags & OM_CH_bigchan )
    oldsize = newsize = s1->tail.size;
  else
    oldsize = newsize = chan->u1.count;
  if ( need > oldsize ) {
    if ( need > OM_Gi_maxchan_size ) {
       return(OM_E_CHAN_OVERFLOW);
    }
    in_size = s1->chdef->p_type->InitCount;
    if ( in_size == -1 ) {
       in_size = OM_Gi_defchan_size;
    }
    ex_size = s1->chdef->p_type->ExtCount;
    if ( ex_size == -1 ) {
       ex_size = OM_Gi_defchan_ext;
    }
    while ( need > newsize ) {
      if ( newsize ) {
	if ( ! ex_size ) {
	   return(OM_E_NOEXTEND);
 	}
        incr = ((oldsize * (OM_Gi_percent_extend_chan))/100);
        if ( incr > (OMuint) ex_size ) ex_size = incr;
	newsize += ex_size;
      }
      else {
	if ( ! in_size ) {   /* initial size explicitly zero */
	  if ( ! ex_size ) { /* both initiial and exten are zero */
	    return(OM_E_NOEXTEND);
	  }
	  else {
	    newsize = ex_size; /* no initial so use extend */
 	  }
	}
	else {
	  newsize = in_size;  /* just use initial */
	}
      }
    }

    sts = om$connect_chan_alloc ( side1 = s1,
                                  num_ents = newsize );
    if ( ! (1 & sts) ) {
      om$report_error(sts=sts);
      printf ("som_connect_get_chent: som_connect_chan_alloc fail\n");
      return(sts);
    }
    chan = *s1->pp_chan;                  /* in case it moved */
    if (chan->flags & OM_CH_restricted) {
      olink = (OM_p_OBJID) s1->p_chandata;
      olink += oldsize;
      for (ii=(newsize - oldsize); ii>0; ii--, olink++ ) {
        *olink = NULL_OBJID;
      }
    }
    else {  /* not restricted */
      link = (OM_p_CHANNEL_LINK) s1->p_chandata;
      link += oldsize;
      for (ii=(newsize - oldsize); ii>0; ii--, link++ ) {
        link->objid     = NULL_OBJID;
        link->hdr.flags = 0;
      }
    }
  }
	/* determine where the new link should be */
  if (chan->flags & OM_CH_absordered) {
    if (chan->flags & OM_CH_restricted) {
      olink = (OM_p_OBJID) s1->p_chandata;
      olink += s1->relidx;
      if ( ! IF_NULL_OBJID(*olink)) {
        return(OM_E_INDEXNOTEMPTY);   /* this entry already in use */
      }
      s1->p_chlink = (OM_p_CHANNEL_LINK)olink;
    }
    else {  /* not restricted */
      link = (OM_p_CHANNEL_LINK) s1->p_chandata;
      link += s1->relidx;
      if ( ! IF_NULL_OBJID(link->objid)) {
        return(OM_E_INDEXNOTEMPTY);   /* this entry already in use */
      }
      s1->p_chlink = link;
      if (!(chan->flags & OM_CH_singleton)) {
        link->hdr.flags = link->hdr.u1.isoindex = 0;
      }
    }
    if ( (OMuint) s1->relidx >= s1->tail.last_index ) 
      s1->tail.last_index = s1->relidx + 1;
  }
  else if ( chan->flags & OM_CH_relordered ) {
    sts = om$connect_insert_rel( side1=s1 );
    if ( sts != OM_S_SUCCESS ) {
       return(sts);	/* only OM_F_BUGCHECK possible */
    }
  }
  else {
    if ((chan->flags & OM_CH_preset) && (s1->tail.collapse_count)) {
      s1->relidx = OM_K_MAXINT;
      sts = om$connect_insert_rel( side1=s1 );
      if ( sts != OM_S_SUCCESS ) {
         return(sts);	/* only OM_F_BUGCHECK possible */
      }
    }
    else {
      if (chan->flags & OM_CH_restricted) {
        olink = (OM_p_OBJID) s1->p_chandata;
        olink += s1->tail.last_index;
        s1->p_chlink = (OM_p_CHANNEL_LINK) olink;
      }
      else {
        link = (OM_p_CHANNEL_LINK) s1->p_chandata;
        link += s1->tail.last_index;
        s1->p_chlink = link;
        if (!(chan->flags & OM_CH_singleton)) {
          link->hdr.flags = link->hdr.u1.isoindex = 0;
        }
      }
      s1->tail.last_index++;
    }
  }
  if (s2->chdef->p_type->w_flags & (CD_1_1 | CD_1_m)) {
    chan->flags |= OM_CH_full; /* limited to one after this connect */
  }
  s1->chused = FALSE;
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_get_chent\n");
  som_connect_show_side("  side1 ",s1);
  som_connect_show_side("  side2 ",s2);
 }
#endif
  return(OM_S_SUCCESS);
 }



/*
  som_connect_chan_alloc
  ----------------------

  Called to allocate a channel outrigger.  The channel may be new or an
  old channel which is getting larger or smaller.  If it is a new channel
  then all fields will be initialized as new.  

*/

 int som_connect_chan_alloc (s1, num_ents)

 OM_p_CONNECT_SIDE  s1;               /* side with channel to be allocated */
 int                num_ents;         /* number of entries for new channel */
 {
   int               i, sts;
   int               new;
   int               new_bigchan=0;
   int               old_bigchan=0;
   OMuint            count, sv_count=0;
   OMuint            size;
   OMuint            old_ents;
   OMuint            mv_start;
   OMuword           cd_flags;
   OMuword           restricted;
   OMuword           singleton;
   OM_p_BIG_TAIL     p_big_tail;
   OM_p_CHANNEL_HDR  p_chan;

   p_chan = *s1->pp_chan;
   cd_flags   = s1->chdef->p_type->w_flags;
   restricted = cd_flags & CD_restricted;
   singleton  = cd_flags & (CD_1_1 | CD_m_1);

   if (!p_chan) {
     count = 0;
     new   = 1;
   }
   else {
     if ( singleton ) {
       if ( restricted )
          count = sizeof(OM_S_RESTRICTED_ONECHAN);
       else
          count = sizeof(OM_S_CHANNEL_LINK);
     }
     else {
       if ( p_chan->flags & OM_CH_bigchan ) {
         old_bigchan = 1;
         p_big_tail = (OM_p_BIG_TAIL)((OMuint)p_chan +
                      sizeof(OM_S_CHANNEL_HDR));
         old_ents = p_big_tail->size;
       }
       else {
         old_ents = p_chan->u1.count;
       }
       if ( restricted )
         count = old_ents * sizeof(OM_S_OBJID) + sizeof(OM_S_CHANNEL_HDR);
       else
         count = old_ents * sizeof(OM_S_CHANNEL_LINK) +
                 sizeof(OM_S_CHANNEL_HDR);
       sv_count = count;
       if ( old_bigchan ) count += sizeof(OM_S_BIG_TAIL);
     }
     count /= sizeof(long);
     new   = 0;
   }

   if ( num_ents ) {
     if ( singleton ) {
       if ( restricted )
         size = sizeof(OM_S_RESTRICTED_ONECHAN);
       else
         size = sizeof(OM_S_CHANNEL_LINK);
     }
     else {
       if ( restricted )
         size = num_ents * sizeof(OM_S_OBJID) + sizeof(OM_S_CHANNEL_HDR);
       else
         size = num_ents * sizeof(OM_S_CHANNEL_LINK) +sizeof(OM_S_CHANNEL_HDR);
     }
     if ( num_ents > OM_K_BIGCHAN_LIMIT ) {
       new_bigchan = 1;
       size += sizeof(OM_S_BIG_TAIL);
     }
     else if ( old_bigchan ) {    /*  check boundary condition  */
       sv_count = size;
       if ( restricted ) {
         num_ents += (sizeof(OM_S_BIG_TAIL)/sizeof(int));
         size += ((sizeof(OM_S_BIG_TAIL)/sizeof(int)) * sizeof(OM_S_OBJID));
       }
       else {
         ++num_ents;
         size += sizeof(OM_S_CHANNEL_LINK);
       }
       if ( num_ents > OM_K_BIGCHAN_LIMIT ) {
         new_bigchan = 1;
         size += sizeof(OM_S_BIG_TAIL);
       }
     }
     size /= sizeof(long);
   }
   else {
     size = 0;
   }

   /*  set the dimension for the channel - note that the size is the  */
   /*  number of longwords needed for channel data including the      */
   /*  space for the channel header                                   */

   if (!(1&(sts = om$vla_set_dimension ( pp_data    = (int *) s1->pp_chan,
                                         p_count    = &count,
                                         size       = size,
                                         osnum      = s1->osnum,
                                         objid      = s1->objid,
                                         p_cld      = s1->p_cld )))) {
     return (sts);
   }

   /*===========================================================*/
   /*  transition from existing regular channel to BIG channel  */
   /*===========================================================*/

   if ( new_bigchan && !new && !old_bigchan ) {
     mv_start = ((OMuint)*s1->pp_chan + sizeof(OM_S_CHANNEL_HDR));
     OM_BLOCK_MOVE( mv_start, mv_start+sizeof(OM_S_BIG_TAIL), sv_count);
   }

   /*==================================================*/
   /*  transition from BIG channel to regular channel  */
   /*==================================================*/

   if ( old_bigchan && num_ents && !new_bigchan ) {
     mv_start = ((OMuint)*s1->pp_chan + sizeof(OM_S_CHANNEL_HDR) +
                 sizeof(OM_S_BIG_TAIL));
     OM_BLOCK_MOVE ( mv_start, (mv_start-sizeof(OM_S_BIG_TAIL)), sv_count );
   }

   if ( num_ents ) {
     p_chan = *s1->pp_chan;

     s1->tail.size = num_ents;
     if ( new_bigchan ) {
       s1->p_chandata = (int *)((OMuint)p_chan +
                          sizeof(OM_S_CHANNEL_HDR) + sizeof(OM_S_BIG_TAIL));
       p_big_tail = (OM_p_BIG_TAIL)((OMuint)p_chan + sizeof(OM_S_CHANNEL_HDR));
       p_big_tail->size = num_ents;
     }
     else {
       if ( !restricted && singleton )
         s1->p_chandata = (int *)p_chan;
       else
         s1->p_chandata = (int *)((OMuint)p_chan + sizeof(OM_S_CHANNEL_HDR));
     }

     if ( new ) {
       p_chan->flags = cd_flags;
       if ( new_bigchan ) p_chan->flags |= OM_CH_bigchan;
       if ( singleton ) {
         p_chan->flags |= OM_CH_singleton;
         p_chan->u1.count = 0;
       }
       else {
         if ( new_bigchan )
           p_chan->u1.count = 0;
         else
           p_chan->u1.count = num_ents;
       }

       if ( restricted ) {
         OM_p_OBJID p_oid = (OM_p_OBJID) s1->p_chandata;
         for ( i=0; i<num_ents; ++i, ++p_oid ) *p_oid = NULL_OBJID;
       }
       else {
         OM_p_CHANNEL_LINK p_link = (OM_p_CHANNEL_LINK) s1->p_chandata;
         for ( i=0; i<num_ents; ++i, ++p_link ) p_link->objid = NULL_OBJID;
       }
     }
     else {
       if ( new_bigchan ) {
         p_chan->flags |= OM_CH_bigchan;
         p_chan->u1.count = 0;
       }
       else {
         p_chan->flags &= ~OM_CH_bigchan;
         p_chan->u1.count = num_ents;
       }
     }
   }
   return (OM_S_SUCCESS);
 }




/*
  som_connect_if_connected
  ------------------------

  Called to determine whether side1 object/channel is connected to 
  side2 object/channel.
  Returns true if sides already connect and completes description of connection
  for both side structures to include correct channel link pointer and
  ISO index if any.
  Returns false if not already connected.
*/

 int som_connect_if_connected (s1, s2) 
 
 OM_p_CONNECT_SIDE s1;			/* structure describing one "side"
					   of proposed or actual connection */
 OM_p_CONNECT_SIDE s2;			/* structure describing other "side" */
 {
 char s1res=1, s2res=1;         /* assume both sides are restricted */
 int ii, jj;
 OM_p_CHANNEL_LINK lt2;
 OM_p_CHANNEL_LINK link1=NULL;
 OM_p_CHANNEL_LINK link2=NULL;
 OM_p_OBJID        olink1=NULL;
 OM_p_OBJID        olink2=NULL;
 OM_p_OBJID        olt2;
 OM_p_CHANNEL_HDR  chan1, chan2;
 int num1, num2;
 OMuword s1def_flags, s2def_flags;
 OM_S_OBJID  my_oid1, my_oid2;
 OM_p_CONNECT_SIDE tmp_side;
 
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_if_connected\n");
  som_connect_show_side("  side1 ",s1);
  som_connect_show_side("  side2 ",s2);
 }
#endif
 chan1 = *s1->pp_chan;
 if ( !chan1 ) return (FALSE);   /* empty channel */
 chan2 = *s2->pp_chan;
 if ( !chan2 ) return (FALSE);   /* empty channel */

 my_oid1 = 0;
 my_oid2 = 0;

 /*=================================================================*/
 /*  compare size of channels so that outer looping is done on the  */
 /*  smaller sized channel - this makes connect checks faster       */
 /*  there is no hope for the disconnect case since both sides      */
 /*  must be searched entirely to pinpoint the linkages             */
 /*=================================================================*/

 if ( s1->tail.last_index > s2->tail.last_index ) {
   tmp_side = s1;
   s1 = s2;
   s2 = tmp_side;
   chan1 = *s1->pp_chan;
   chan2 = *s2->pp_chan;
 }

 s1def_flags = s1->chdef->p_type->w_flags;
 if (s1def_flags & (CD_1_1|CD_m_1)) {
   num1 = 1;
   if (s1def_flags & CD_restricted) {
     my_oid1 = *((OM_p_OBJID)s1->pp_chan) >> 1;
     olink1 = (OM_p_OBJID) &my_oid1;
   }
   else {
     link1 = (OM_p_CHANNEL_LINK) s1->p_chandata;
     s1res = 0;
   }
 }
 else {
   num1 = s1->tail.last_index;
   if (chan1->flags & OM_CH_restricted) {
     olink1 = (OM_p_OBJID) s1->p_chandata;
   }
   else {
     link1 = (OM_p_CHANNEL_LINK) s1->p_chandata;
     s1res = 0;
   }
 }

 s2def_flags = s2->chdef->p_type->w_flags;
 if (s2def_flags & (CD_1_1|CD_m_1)) {
   num2 = 1;
   if (s2def_flags & CD_restricted) {
     my_oid2 = *((OM_p_OBJID)s2->pp_chan) >> 1;
     olink2 = (OM_p_OBJID) &my_oid2;
   }
   else {
     link2 = (OM_p_CHANNEL_LINK) s2->p_chandata;
     s2res = 0;
   }
 }
 else {
   num2 = s2->tail.last_index;
   if (chan2->flags & OM_CH_restricted) {
     olink2 = (OM_p_OBJID) s2->p_chandata;
   }
   else {
     link2 = (OM_p_CHANNEL_LINK) s2->p_chandata;
     s2res = 0;
   }
 }



 if (!IF_NULL_OBJID(s1->iso_objid)) { /* connected via ISO */

   /*  check for restricted channel attempting connect via ISO  */

   if ((s1def_flags & CD_restricted) || (s2def_flags & CD_restricted)) {
      return (FALSE);
   }

   for (ii = num1; ii > 0; ii--) {
     if (IF_EQ_OBJID(link1->objid, s1->iso_objid)) {
       lt2 = link2;
       for (jj=num2; jj > 0; jj--) {
	 if (IF_EQ_OBJID(lt2->objid, s2->iso_objid) &&
		(lt2->hdr.u1.isoindex == link1->hdr.u1.isoindex)) {
	   s1->p_chlink = link1;
	   s2->p_chlink = lt2;
	   s1->iso_index = link1->hdr.u1.isoindex;
	   s2->iso_index = lt2->hdr.u1.isoindex;
	   s1->chused = TRUE;
	   s2->chused = TRUE;
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- TRUE\n");
 }
#endif
	   return(TRUE);
	 }
	 lt2++;
       }
     }
     link1++;
   }
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- FALSE\n");
 }
#endif
   return(FALSE);  
 }
 else { /* not iso connection */
   /*=========================*/
   /*  both sides restricted  */
   /*=========================*/
   if ( s1res && s2res ) {
     /*====================================================================*/
     /*  since both are restricted make sure channels jive before looping  */
     /*====================================================================*/
     if ((OM_GA_OSDs[s1->osnum]->FilToAct[s1->channum.classid] !=
          s2->chdef->p_type->channum.classid) ||
         (s1->chdef->p_type->channum.number != s2->channum.number) ||
         (OM_GA_OSDs[s2->osnum]->FilToAct[s2->channum.classid] !=
          s1->chdef->p_type->channum.classid) ||
         (s2->chdef->p_type->channum.number != s1->channum.number)) {
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- FALSE\n");
 }
#endif
       return (FALSE);
     }
     for (ii= num1; ii > 0; ii--) {
       if (IF_EQ_OBJID(*olink1,s2->objid)) {
         olt2 = olink2;
         for (jj= num2; jj > 0; jj--) {
	   if (IF_EQ_OBJID(*olt2,s1->objid)) {
             if (my_oid1) 
               s1->p_chlink = (OM_p_CHANNEL_LINK)s1->pp_chan;
             else
               s1->p_chlink = (OM_p_CHANNEL_LINK)olink1;
             if (my_oid2)
	       s2->p_chlink = (OM_p_CHANNEL_LINK)s2->pp_chan;
             else
	       s2->p_chlink = (OM_p_CHANNEL_LINK)olt2;
	     s1->chused = TRUE;
	     s2->chused = TRUE;
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- TRUE\n");
 }
#endif
	     return(TRUE);
	   }
	   olt2++;
         }
         BUGCHECK("som_connect_if_connect: one side connect 2");
         return(FALSE);
       }
       olink1++;
     }
   }
   /*==========================*/
   /*  only side 1 restricted  */
   /*==========================*/
   else if ( s1res ) {
     if ((OM_GA_OSDs[s2->osnum]->FilToAct[s2->channum.classid] !=
          s1->chdef->p_type->channum.classid) ||
         (s1->chdef->p_type->channum.number != s2->channum.number)) { 
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- FALSE\n");
 }
#endif
       return(FALSE);
     }
     for (ii= num1; ii > 0; ii--) {
       if (IF_EQ_OBJID(*olink1,s2->objid)) {
         lt2 = link2;
         for (jj= num2; jj > 0; jj--) {
	   if (IF_EQ_OBJID(lt2->objid,s1->objid) &&
		  lt2->channum.classid == s1->channum.classid &&
		  lt2->channum.number  == s1->channum.number) {
             if (my_oid1)
	       s1->p_chlink = (OM_p_CHANNEL_LINK)s1->pp_chan;
             else
	       s1->p_chlink = (OM_p_CHANNEL_LINK)olink1;
	     s2->p_chlink = lt2;
	     s1->chused = TRUE;
	     s2->chused = TRUE;
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- TRUE\n");
 }
#endif
	     return(TRUE);
	   }
	   lt2++;
         }
         BUGCHECK("som_connect_if_connect: one side connect 2");
         return(FALSE);
       }
       olink1++;
     }
   }
   /*==========================*/
   /*  only side 2 restricted  */
   /*==========================*/
   else if ( s2res ) {
     if ((OM_GA_OSDs[s1->osnum]->FilToAct[s1->channum.classid] !=
          s2->chdef->p_type->channum.classid) ||
         (s2->chdef->p_type->channum.number != s1->channum.number)) {
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- FALSE\n");
 }
#endif
       return(FALSE);
     }
     for (ii= num1; ii > 0; ii--) {
       if (IF_EQ_OBJID(link1->objid,s2->objid) && 
		  link1->channum.classid == s2->channum.classid &&
		  link1->channum.number  == s2->channum.number) {
         olt2 = olink2;
         for (jj= num2; jj > 0; jj--) {
	   if (IF_EQ_OBJID(*olt2,s1->objid)) {
	     s1->p_chlink = link1;
             if (my_oid2)
	       s2->p_chlink = (OM_p_CHANNEL_LINK)s2->pp_chan;
             else
	       s2->p_chlink = (OM_p_CHANNEL_LINK)olt2;
	     s1->chused = TRUE;
	     s2->chused = TRUE;
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- TRUE\n");
 }
#endif
	     return(TRUE);
	   }
	   olt2++;
         }
         BUGCHECK("som_connect_if_connect: one side connect 2");
         return(FALSE);
       }
       link1++;
     }
   }
   /*==============================*/
   /*  neither side is restricted  */
   /*==============================*/
   else {
     for (ii= num1; ii > 0; ii--) {
       if (IF_EQ_OBJID(link1->objid,s2->objid) && 
		  link1->channum.classid == s2->channum.classid &&
		  link1->channum.number  == s2->channum.number) {
         lt2 = link2;
         for (jj= num2; jj > 0; jj--) {
	   if (IF_EQ_OBJID(lt2->objid,s1->objid) &&
		  lt2->channum.classid == s1->channum.classid &&
		  lt2->channum.number  == s1->channum.number) {
	     s1->p_chlink = link1;
	     s2->p_chlink = lt2;
	     s1->chused = TRUE;
	     s2->chused = TRUE;
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- TRUE\n");
 }
#endif
	     return(TRUE);
	   }
	   lt2++;
         }
         BUGCHECK("som_connect_if_connect: one side connect 2");
         return(FALSE);
       }
       link1++;
     }
   }
#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_if_connected --- FALSE\n");
 }
#endif
   return(FALSE);
 }
}



/*
  som_connect_insert_rel
  ----------------------

  This routine is called to find a link into the array of
  links in an ordered channel.  It is assumed that room exists in
  the channel for the new link.  If holes exist in the current
  array, some entries are shifted to open a position for the new link.
  Otherwise, all entries past the desired location must be shifted. 
*/

 int som_connect_insert_rel( s1 )

 OM_p_CONNECT_SIDE s1;			/* describes the object/channel 
					   to use to find a link entry
					   corresponding to the index in
					   s1->relidx. */
 {
 OM_p_CHANNEL_HDR chan;

 int    holes, used;
 OMuint ii, chan_count;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_insert_rel\n");
  som_connect_show_side("  side1 ",s1);
 }
#endif
 chan = *s1->pp_chan;
 ii = s1->tail.last_index - s1->tail.collapse_count;
 if ( (OMuint) s1->relidx  >= ii )  {
    s1->status  = OM_I_ADDEDATEND;
    s1->relidx = ii;;
 }
 /*==================================*/
 /*  check for a restrcited channel  */
 /*==================================*/
 if (chan->flags & OM_CH_restricted) {
   OM_p_OBJID link, bhole, ahole, spot, max;

   link = (OM_p_OBJID) s1->p_chandata;
   max =  link + s1->tail.last_index;
   holes = s1->tail.collapse_count;
   if ( ! holes ) { /* array is compact move up to make room */
     spot = link + s1->relidx;
     if (max > spot) {
       OM_BLOCK_MOVE(spot, spot+1, (OMuint)(max)-(OMuint)spot);
     }
     *spot = NULL_OBJID;
     s1->p_chlink = (OM_p_CHANNEL_LINK)spot;
     s1->chused = FALSE;
     s1->tail.last_index++;
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
   printf("~xsom_connect_insert_rel\n");
 }
#endif
     return(OM_S_SUCCESS);
   }
   /* There are holes in the channel array.
      Find the correct spot for the new entries and the
      nearest holes before and after the spot.  
      Then do the shortest move from the spot to a hole to make room 
   */
   ahole = bhole = NULL;
   if ( chan->flags & OM_CH_bigchan )
     chan_count = s1->tail.size;
   else
     chan_count = chan->u1.count;
   for (used=0; ; link++) { /* look for spot and before hole */
     if ( used == s1->relidx ) { /* should go in this entry */
       if ((bhole) && (link == max) && 
           (s1->tail.last_index < chan_count)) {
         s1->tail.last_index++;
         s1->tail.collapse_count++;   /* this will be decremented below */
         *max = NULL_OBJID;
       }
       break;
     }
     if (link == max) {
       BUGCHECK("som_connect_insert_rel: no hole");
       return(OM_F_BUGCHECK);
     }
     if (IF_NULL_OBJID(*link)) {
       holes--;
       bhole = link;
     }
     else { 
       used++;
     }
   }

   if ((bhole) && (!IF_NULL_OBJID(*link))) --link;

	/* link now points to the channel entry in which the 
           new link should be placed. */

   spot = link;
   if ( ! IF_NULL_OBJID(*spot)) { /* this spot occupied */
     if ( holes ) { /* look for holes after the spot */
       for (link++; link < max; link++) {
         if (IF_NULL_OBJID(*link)) {
   	   ahole = link;
	   break;
         }
       }
       if (link == max) {
         BUGCHECK("som_connect_insert_rel: no hole 2");
         return(OM_F_BUGCHECK);
       }
     }
     if ((ahole != NULL) && (bhole != NULL)) { /* find closest hole */
       if ((spot - bhole) >= (ahole - spot)) {
         bhole = NULL;   /* after hole is closer */
       }
       else {
         ahole = NULL;   /* before hole is closer */
       }
     }
     if ( ahole != NULL ) {
       if ( ahole > spot ) {
         OM_BLOCK_MOVE(spot, spot+1, (OMuint)ahole-(OMuint)spot);
       }
     }
     else {
       if ( bhole < spot ) {
         OM_BLOCK_MOVE (bhole+1, bhole, (OMuint)spot-(OMuint)bhole);
       }
     }
   }
   s1->tail.collapse_count--;
   *spot = NULL_OBJID;
   s1->p_chlink = (OM_p_CHANNEL_LINK)spot; 
   s1->chused = FALSE;
 }
 else { 
   /*==========================*/
   /*  channel not restrcited  */
   /*==========================*/
   OM_p_CHANNEL_LINK link, bhole, ahole, spot, max;

   link = (OM_p_CHANNEL_LINK) s1->p_chandata;
   max =  link + s1->tail.last_index;
   holes = s1->tail.collapse_count;
   if ( ! holes ) { /* array is compact move up to make room */
     spot = link + s1->relidx;
     if (max > spot) {
       OM_BLOCK_MOVE(spot, spot+1, (OMuint)(max)-(OMuint)spot);
     }
     spot->objid = NULL_OBJID;
     spot->hdr.flags = 0;
     s1->p_chlink = spot;
     s1->chused = FALSE;
     s1->tail.last_index++;
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
   printf("~xsom_connect_insert_rel\n");
 }
#endif
     return(OM_S_SUCCESS);
   }
   /* There are holes in the channel array.
      Find the correct spot for the new entries and the
      nearest holes before and after the spot.  
      Then do the shortest move from the spot to a hole to make room 
   */
   ahole = bhole = NULL;
   if ( chan->flags & OM_CH_bigchan )
     chan_count = s1->tail.size;
   else
     chan_count = chan->u1.count;
   for (used=0; ; link++) { /* look for spot and before hole */
     if ( used == s1->relidx ) { /* should go in this entry */
       if ((bhole) && (link == max) && 
           (s1->tail.last_index < chan_count)) {
         s1->tail.last_index++;
         s1->tail.collapse_count++;   /* this will be decremented below */
         max->objid = NULL_OBJID;
       }
       break;
     }
     if (link == max) {
       BUGCHECK("som_connect_insert_rel: no hole");
       return(OM_F_BUGCHECK);
     }
     if (IF_NULL_OBJID(link->objid)) {
       holes--;
       bhole = link;
     }
     else { 
       used++;
     }
   }

   if ((bhole) && (!IF_NULL_OBJID(link->objid))) --link;

	/* link now points to the channel entry in which the 
           new link should be placed. */

   spot = link;
   if ( ! IF_NULL_OBJID(spot->objid)) { /* this spot occupied */
     if ( holes ) { /* look for holes after the spot */
       for (link++; link < max; link++) {
         if (IF_NULL_OBJID(link->objid)) {
   	   ahole = link;
	   break;
         }
       }
       if (link == max) {
         BUGCHECK("som_connect_insert_rel: no hole 2");
         return(OM_F_BUGCHECK);
       }
     }
     if ((ahole != NULL) && (bhole != NULL)) { /* find closest hole */
       if ((spot - bhole) >= (ahole - spot)) {
         bhole = NULL;   /* after hole is closer */
       }
       else {
         ahole = NULL;   /* before hole is closer */
       }
     }
     if ( ahole != NULL ) {
       if ( ahole > spot ) {
         OM_BLOCK_MOVE(spot, spot+1, (OMuint)ahole-(OMuint)spot);
       }
     }
     else {
       if ( bhole < spot ) {
         OM_BLOCK_MOVE (bhole+1, bhole, (OMuint)spot-(OMuint)bhole);
       }
     }
   }
   s1->tail.collapse_count--;
   spot->objid = NULL_OBJID;
   spot->hdr.flags = 0;
   s1->p_chlink = spot; 
   s1->chused = FALSE;
 }
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_insert_rel\n");
 }
#endif
 return (OM_S_SUCCESS);
 }



/*
  som_connect_move_check
  ----------------------

  Check to make sure than a move_chan or copy_chan from object/channel defined
  by s1 to object/channel defined by s2 can complete successfully.  This
  determination is made by considering fan in/out, valid class lists, channel
  capacities and what not.  A certain amount of ad hocery.
  If all appears well returns OM_S_SUCCESS else some other status.
*/

 som_connect_move_check (s1, s2, copy_flag)
 OM_p_CONNECT_SIDE s1;			/* structure describing from "side"
					   of move or copy */
 OM_p_CONNECT_SIDE s2;			/* structure describing target or
					   destination "side" */
 int copy_flag;				/* 0 for move_chan; != for copy_chan */
 {
  OM_p_CHANNEL_LINK tlink, link1=NULL;
  OM_p_OBJID        otlink, olink1=NULL;
  OM_p_CHANNEL_HDR  chan1, chan2, chan3;
  OMuint ii, chan_count;
  int sts;
  OM_S_CONNECT_SIDE side3, *s3 = &side3;
  int num1;     /* number of channel links including holes */
  int size1;	/* number of existing source connections */
  int max1ind=0;  /* max source index - when target is absordered */
  int max2sz;   /* max possible target channel size */
  OMuword s1def_flags, s2def_flags;
  OM_S_OBJID my_oid1;
  int        past_pside=0;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_move_check\n");
  som_connect_show_side("  side1 ",s1);
  som_connect_show_side("  side2 ",s2);
 }
#endif

  chan1 = *s1->pp_chan;
  chan2 = *s2->pp_chan;
  s1def_flags = s1->chdef->p_type->w_flags;
  s2def_flags = s2->chdef->p_type->w_flags;

  if ( ! chan1 ) return (OM_I_CHAN_EMPTY);

  if (copy_flag) {
    if (s2def_flags & (CD_1_1 | CD_1_m)) {
      return(OM_E_EXCEEDFANOUT); /* can't copy others would have too many */
    }
  }    
/* ------ determine source number of connections -------- */

  my_oid1 = 0;
  if ( s1def_flags & (CD_1_1|CD_m_1)) {
    num1 = 1;
    if (s1def_flags & CD_restricted) {
      my_oid1 = *((OM_p_OBJID)s1->p_chandata) >> 1;
      olink1 = (OM_p_OBJID) &my_oid1;
      size1 = 1;
    }
    else {  /* not restrcited */
      link1 = (OM_p_CHANNEL_LINK) s1->p_chandata;
      if ( ! IF_NULL_OBJID(link1->objid) ) {
        size1 = 1;
      }
      else { 
        size1 = 0;
      }
    }
  }
  else {  /* not a singleton */
    num1 = s1->tail.last_index;
    if (chan1->flags & OM_CH_absordered) {
      max1ind = s1->tail.last_index;
      size1   = 0;
      if (chan1->flags & OM_CH_restricted) {
        otlink = (OM_p_OBJID) s1->p_chandata;
        for (ii=max1ind; ii > 0; ii--, otlink++) {
 	  if ( ! IF_NULL_OBJID(*otlink)) {
	    size1++;
	  }
        }
      }
      else {  /* not restricted */
        link1 = (OM_p_CHANNEL_LINK) s1->p_chandata;
        tlink   = link1;
        for (ii=max1ind; ii > 0; ii--, tlink++) {
 	  if ( ! IF_NULL_OBJID(tlink->objid) ) {
	    size1++;
	  }
        }
      }
    }
    else { /* not ordered or relordered */
      if (chan1->flags & OM_CH_restricted )
        olink1 = (OM_p_OBJID) s1->p_chandata;
      else
        link1 = (OM_p_CHANNEL_LINK) s1->p_chandata;
      size1 = s1->tail.last_index - s1->tail.collapse_count;
      max1ind = size1;
    }
  }
  if ( ! size1 ) {
    return(OM_I_CHAN_EMPTY);
  }
/* ---------- make sure that target channel is empty */
/* ---------- and that target can accept source number of connects */
  if ( s2def_flags & (CD_1_1 | CD_m_1) ) {
    if (chan2 && (s2def_flags & CD_restricted)) {   /*  res1chan?  */
       return(OM_E_INVCHAN);  /* target must be empty */
    }
    if (chan2 && chan2->flags & OM_CH_full) {
       return(OM_E_INVCHAN);  /* target must be empty */
    }
    if ( size1 > 1 ) {
       return(OM_E_NOEXTEND);
    }
  }
  else {  /* var len channel */
    if ( s2->tail.last_index - s2->tail.collapse_count ) {
       return(OM_E_INVCHAN);  /* target must be empty */
    }
    max2sz = s2->chdef->p_type->ExtCount;
    if ( max2sz == -1 ) {
      max2sz = OM_Gi_defchan_ext;
    }
    if ( max2sz ) {  /* if there is an extend size the channel can get big */
      max2sz = OM_Gi_maxchan_size;
    }
    else {  /* was no extend size - use initial size */
      max2sz = s2->chdef->p_type->InitCount;
      if ( max2sz == -1 ) {
	max2sz = OM_Gi_defchan_size;
      }
    }
    if (s2->chdef->p_type->w_flags & CD_absordered) {
      if (max1ind > max2sz) {
	return(OM_E_NOEXTEND);
      }
    }
    else if ( size1 > max2sz ) {
     return(OM_E_NOEXTEND);
    }
  }
/* ---------- scan all objects to be moved -------------- */
/* ---------- insure channel classid match -------------- */
/* ---------- if copy flag set moved channel must be able to expand */
/* ---------- if any moved object in other os - that os must be loaded */
 sts = OM_S_SUCCESS;
 if ( s1def_flags & CD_restricted) {
   otlink = olink1;
   for (ii=0; (int) ii < num1; ii++, otlink++ ) {
     if (!IF_NULL_OBJID(*otlink)) {
       if ( my_oid1 ) 
         s1->p_chlink = (OM_p_CHANNEL_LINK)s1->pp_chan;
       else
         s1->p_chlink = (OM_p_CHANNEL_LINK)otlink;
       s1->chused = TRUE;
       past_pside = 0;
       sts = om$connect_pside(side1=s1, side2=s3);
       if ( sts != OM_S_SUCCESS ) {
 	 break;
       }
       past_pside = 1;
       if ( ! om$connect_check_classlist(side1=s2, side2=s3)) {
         sts = OM_E_CLASS_CONFLICT;
         break;
       }
       chan3 = *s3->pp_chan;
       if (copy_flag) {  /* copy operation */
         if (s3->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {
           if (s3->chdef->p_type->w_flags & CD_restricted) {
             if (chan3) {
               sts = OM_E_NOEXTEND;
               break;
             }
           }
           else {
             if (!(chan3->flags & OM_CH_full)) continue;
           }
         }
         if (chan3->flags & OM_CH_full) {
  	   sts = OM_E_NOEXTEND;
           break;
         }

         if (chan3->flags & OM_CH_absordered) {
	   sts = OM_E_INDEXNOTEMPTY;
         }
         if ( chan3->flags & OM_CH_bigchan )
           chan_count = s3->tail.size;
         else
           chan_count = chan3->u1.count;
         if ( ! s3->chdef->p_type->ExtCount ) { /* can't extend */
	   if ((s3->tail.last_index - s3->tail.collapse_count) >= 
   					           chan_count) {
	     sts = OM_E_NOEXTEND;
	     break;
    	   }
         }
       }
       om$connect_release_side(side1=s3);
     }
   } /* end for */
 } 
 else {  /* not restrcited */
   tlink = link1;
   for (ii=0; (int) ii < num1; ii++, tlink++ ) {
     if (!IF_NULL_OBJID(tlink->objid)) {
       s1->p_chlink = tlink;
       s1->chused = TRUE;
       past_pside = 0;
       sts = om$connect_pside(side1=s1, side2=s3);
       if ( sts != OM_S_SUCCESS ) {
 	 break;
       }
       past_pside = 1;
       if ( ! om$connect_check_classlist(side1=s2, side2=s3)) {
         sts = OM_E_CLASS_CONFLICT;
         break;
       }
       chan3 = *s3->pp_chan;
       if (copy_flag) {  /* copy operation */
         if (s3->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {
           if (s3->chdef->p_type->w_flags & CD_restricted) {
             if (chan3) {
               sts = OM_E_NOEXTEND;
               break;
             }
           }
           else {
             if (!(chan3->flags & OM_CH_full)) continue;
           }
         }
         if (chan3->flags & OM_CH_full) {
  	   sts = OM_E_NOEXTEND;
           break;
         }

         if (chan3->flags & OM_CH_absordered) {
	   sts = OM_E_INDEXNOTEMPTY;
         }
         if ( chan3->flags & OM_CH_bigchan )
           chan_count = s3->tail.size;
         else
           chan_count = chan3->u1.count;
         if ( ! s3->chdef->p_type->ExtCount ) { /* can't extend */
	   if ((s3->tail.last_index - s3->tail.collapse_count) >= 
					           chan_count) {
	     sts = OM_E_NOEXTEND;
	     break;
    	   }
         }
       }
       om$connect_release_side(side1=s3);
     }
   } /* end for */
 }
 if (past_pside && (sts != OM_S_SUCCESS)) {
   om$connect_release_side(side1=s3);
 }
 s1->p_chlink = NULL;
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_move_check\n");
  if (sts != OM_S_SUCCESS) {
    printf("som_connect_move_check return sts ");
    om$report_error(sts=sts);
  }
 }
#endif
 return(sts);
 }



/*
  som_connect_pside
  -----------------

  Builds a OM_S_CONNECT_SIDE structure in area pointed to by s2.
  Uses as a base the s1 structure and the target pointed to
  by the s1->p_chlink entry.
*/
 int som_connect_pside ( s1, s2 )

 OM_p_CONNECT_SIDE s1;			/* structure describing
					   object/channel/link  that 
					   define target */
 OM_p_CONNECT_SIDE s2;			/* resulting (output) structure
					   describing target */
 {
  int  ii, num2, sts, chan2res, unkobj=0;
  OM_p_CHANNEL_LINK link1, link2=NULL;
  OM_p_OBJID        olink2=NULL;
  OM_S_CHANSELECT   chsel;
  OM_p_CHANNEL_HDR  chan2;
  OM_S_OBJID	    iso_sav;
  OM_S_OBJID        my_oid;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_pside\n");
  som_connect_show_side("  side1 ",s1);
 }
#endif
  if (s1->chdef->p_type->w_flags & CD_restricted) {
    s1->iso_objid = NULL_OBJID;
    s1->iso_index = 0;
    s2->osnum     = s1->osnum;
    iso_sav       = NULL_OBJID;
    if (s1->chdef->p_type->w_flags & (CD_1_1|CD_m_1))
      s2->objid   = *((OM_p_OBJID)s1->p_chlink) >> 1;
    else
      s2->objid   = *((OM_p_OBJID)s1->p_chlink);
    if (OM_GA_OSDs[s2->osnum]->Spacemap[s2->objid].flags & OM_SM_unknown_obj) {
       unkobj = 1;
    }
    else {
      chsel.u_sel.number = s1->chdef->p_type->channum; /* has active classid */
    }
  }
  else {  /* not restricted */
    link1 = s1->p_chlink;
    if (!(link1->hdr.flags & OM_CL_to_object)) {
      s1->iso_objid = link1->objid;
      s1->iso_index = link1->hdr.u1.isoindex;
      sts = som_ISO_fillside ( s1, s2 );
      if (sts == OM_W_OSNOTACTIVE ) {
        return(sts);
      }
      if (sts != OM_S_SUCCESS) {
        om$report_error(sts=sts);
        BUGCHECK("som_connect_pside: som_ISO_fillside fail");
        return(OM_F_BUGCHECK);
      }
      iso_sav = s2->iso_objid;	/* build_side clears this field */
      if (OM_GA_OSDs[s2->osnum]->Spacemap[s2->objid].flags & OM_SM_unknown_obj)
        unkobj = 1;
      else
        chsel.u_sel.number = s2->channum;
    }
    else {  /* not iso case */
      s1->iso_objid = NULL_OBJID;
      s1->iso_index = 0;
      s2->osnum     = s1->osnum;
      s2->objid     = link1->objid;
      iso_sav       = NULL_OBJID;
      chsel.u_sel.number = link1->channum;
      if (OM_GA_OSDs[s2->osnum]->Spacemap[s2->objid].flags &OM_SM_unknown_obj){
        s2->channum = link1->channum;
        unkobj = 1;
      }
    }
    if (!unkobj)
      chsel.u_sel.number.classid =
         OM_GA_OSDs[s2->osnum]->FilToAct[chsel.u_sel.number.classid];

  }

  /*================================*/
  /*  test for unknown object case  */
  /*================================*/

  if (unkobj) {
    sts = som_connect_build_fake_side(s2->osnum, s2->objid, s2->channum, 
        (char *) ((s1->chdef->p_type->w_flags&CD_restricted) ?
        s1->chdef->p_type->classids : 0), s1->channum, s2);
    if (!(1&sts)) return (sts);
  }
  else {
    chsel.type = OM_e_num;

    sts = om$connect_build_side(osnum=s2->osnum, objid=s2->objid, 
		 		chsel=&chsel, relidx=0, side=s2);
    if (!(1 & sts)) {
        om$report_error(sts=sts);
        BUGCHECK("som_connect_pside: som_connect_build_side fail");
        return(OM_F_BUGCHECK);
    }
  }

  chan2 = *s2->pp_chan;
  if (!chan2) {
     printf("********************************************************\n");
     printf("******************** in pside : chan2 is zero !! *******\n");
     printf("********************************************************\n");
     return(OM_F_BUGCHECK);
  }
  if (s2->chdef->p_type->w_flags & CD_restricted ) 
    chan2res = 1;
  else
    chan2res = 0;

  my_oid = 0;
  if (s2->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {
    num2 = 1;
    if ( chan2res ) {
      my_oid = *((OM_p_OBJID) s2->pp_chan) >> 1;
      olink2 = (OM_p_OBJID) &my_oid;
    }
    else {
      link2 = (OM_p_CHANNEL_LINK) s2->p_chandata;
    }
  }
  else {
    num2 = s2->tail.last_index;
    if ( chan2res )
      olink2 = (OM_p_OBJID) s2->p_chandata;
    else
      link2 = (OM_p_CHANNEL_LINK) s2->p_chandata;
  }
  if ( ! IF_NULL_OBJID(iso_sav)) { /* connected via iso */
    for (ii=0; ii < num2; ii++, link2++) {
      if (IF_EQ_OBJID(iso_sav, link2->objid) && 
			(s1->iso_index == link2->hdr.u1.isoindex)) {
        s2->p_chlink = link2;
        s2->relidx   = ii;
	s2->iso_objid = iso_sav;
  	s2->iso_index = link2->hdr.u1.isoindex;
        break;
      }
    } /* end for */
  }
  else {  /* same object space */
    if ( chan2res ) {
      for (ii=0; ii < num2; ii++, olink2++) {
        if (IF_EQ_OBJID(s1->objid, *olink2)) {
          if ( my_oid )
            s2->p_chlink = (OM_p_CHANNEL_LINK)s2->pp_chan;   /*  res1chan  */
          else
            s2->p_chlink = (OM_p_CHANNEL_LINK)olink2;
          s2->relidx   = ii;
          break;
        }
      }
    }
    else {  /* not restricted */
      for (ii=0; ii < num2; ii++, link2++) {
        if (IF_EQ_OBJID(s1->objid, link2->objid) && 
 		  (s1->channum.classid == link2->channum.classid) && 
		  (s1->channum.number == link2->channum.number))  {
          s2->p_chlink = link2;
          s2->relidx   = ii;
          break;
        }
      }
    }
  }   /* end else */
  if ( ii == num2 ) {
#ifdef DEBUG
     printf("som_connect_pside: target channel not linked\n");
     som_connect_show_side(" side1 ",s1);
     som_connect_show_side(" side2 ",s2);
     if (!IF_NULL_OBJID(s1->osnum)) 
	som_ISO_print(s1->osnum, s1->iso_objid);
     if (!IF_NULL_OBJID(iso_sav)) {
	printf("pside: iso_sav = %d\n",iso_sav);
	som_ISO_print(s2->osnum, iso_sav);
     }
     som_show_object(s1->osnum, s1->objid);
     som_show_object(s2->osnum, s2->objid);
     exit(1);
#endif
     BUGCHECK("som_connect_pside: target channel not linked");
     return(OM_F_BUGCHECK);
  }
  s2->chused = TRUE;	/* usual case don't release */
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_pside\n");
  som_connect_show_side("  side2 ",s2);
 }
#endif
  return (OM_S_SUCCESS);
 }



/*
  som_connect_release_side
  ------------------------

  Release any instance held in OM_S_CONNECT_SIDE and return channel
  entry if assigned but not used.  Channel entry is considered used
  (ie to remain connected) if s1->chused is TRUE. Release of the object
  itself involves release of the rip structure.
*/
  
 int som_connect_release_side ( s1 )

 OM_p_CONNECT_SIDE s1;			/* structure defining 
					   object and channel link to
					   be released. */
 {
  OM_p_CHANNEL_HDR chan;
  int              sts;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_release_side\n");
  som_connect_show_side("  side1 ",s1);
 }
#endif
 if ( s1->pp_chan ) {
   chan = *s1->pp_chan;
   if ( chan != NULL ) {
     if ( ! s1->chused ) {
       om$connect_return_chent( side1=s1 );
     }
     if ( ! (s1->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) ) {
       if (s1->tail.collapse_count) {
         om$collapse_channel(osnum=s1->osnum, objid=s1->objid, 
	 	          pp_chan=s1->pp_chan, chdef=s1->chdef,
                          p_chandata=s1->p_chandata, p_tail=&s1->tail,
                          p_acld = s1->p_cld);
       }
       else {
         om$connect_add_tail ( p_chan=*s1->pp_chan, p_chandata=s1->p_chandata,
                              tail=&s1->tail );
       }
     }
     else {
       if (!(s1->chdef->p_type->w_flags & CD_restricted)) {
         if (!(chan->flags & OM_CH_full)) {
           sts = om$connect_chan_alloc ( side1 = s1, num_ents = 0 );
         }
       }
     }
   }
 }
 s1->p_chlink = NULL;
 if ( ! IF_NULL_OBJID (s1->iso_objid)) {
    som_ISO_check_empty(s1->osnum, s1->iso_objid);
    s1->iso_objid = NULL_OBJID;
 }

 /*  check for unknown class cleanup  */

 if (s1->chdef && !s1->chdef->s_name) som_connect_release_fake (s1);

 if ( s1->rip.p_object != NULL ) {
    om$release_any_instance(osnum = s1->osnum, rip = s1->rip);
 }
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_release_side\n");
 }
#endif
  return(OM_S_SUCCESS);
 }

/*
  som_connect_return_chent
  ------------------------

  Return (ie deallocate, make available) assigned channel entry if it was
  not used.
*/
  
 int som_connect_return_chent ( s1 )

 OM_p_CONNECT_SIDE s1;			/* structure defining channel 
					   and link to be released */
 {
 OM_p_CHANNEL_LINK link;
 OM_p_OBJID        olink;
 OM_p_CHANNEL_HDR  chan;
 OMuword s1def_flags;

#ifdef DEBUG
 if (OM_Gi_conn_debug) {
  printf("~~som_connect_return_chent\n");
  som_connect_show_side("  side1 ",s1);
 }
#endif
 if (s1->chused == TRUE) { /* channel link in use - don't return */
   return(OM_S_SUCCESS);
 }

 chan = *s1->pp_chan;
 s1def_flags = s1->chdef->p_type->w_flags;
 if (s1def_flags & CD_restricted ) {
   olink = (OM_p_OBJID)s1->p_chlink;
   if (olink == NULL) { 
     return(OM_S_SUCCESS);	/* channel link never assigned */
   }

   if ( s1def_flags & (CD_1_1|CD_m_1)) {     /*  res1chan?  */
     *olink = 0;
   }
   else {
     chan->flags &= ~OM_CH_full;
     *olink = NULL_OBJID;
   }
 }
 else {
   link = s1->p_chlink;
   if (link == NULL) { 
     return(OM_S_SUCCESS);	/* channel link never assigned */
   }
   chan->flags &= ~OM_CH_full;
   link->objid = NULL_OBJID;
   link->hdr.flags &= ~OM_CL_to_object;
   link->channum.classid = 0;
   link->channum.number  = 0;
 }
 s1->p_chlink = NULL;
 if ( ! (s1def_flags & (CD_1_1|CD_m_1))) {
   s1->tail.collapse_count++;
 }
#ifdef DEBUGx
 if (OM_Gi_conn_debug) {
  printf("~xsom_connect_return_chent\n");
 }
#endif
 return(OM_S_SUCCESS);
 }


/*
  som_connect_add_tail
  --------------------
 
  Called to update the tail structure of a channel.  Determines if the
  tail will fit in the channel.  No tail for absolutely ordered channels.

*/

int som_connect_add_tail ( p_chan, p_chandata, p_tail )

OM_p_CHANNEL_HDR    p_chan;      /* pointer to channel header  */
int                *p_chandata;  /* pointer to channel data    */
OM_p_BIG_TAIL       p_tail;      /* new tail to add to channel */
{
   OM_p_BIG_TAIL      p_big_tail;
   OM_p_LITTLE_TAIL   p_little_tail;

   if (!p_chan) return (OM_S_SUCCESS);

   if ( p_chan->flags & OM_CH_singleton ) return (OM_S_SUCCESS);

   if ( p_chan->flags & OM_CH_bigchan )
   {
      p_big_tail = (OM_p_BIG_TAIL)((OMuint)p_chan + sizeof(OM_S_CHANNEL_HDR));
      *p_big_tail = *p_tail;
      p_chan->flags |= OM_CH_tail_exists;
      p_chan->flags &= ~OM_CH_collapse_count;
      return (OM_S_SUCCESS);
   }

   if ( p_chan->flags & OM_CH_absordered ) return (OM_S_SUCCESS);
   if ( p_tail->last_index < p_chan->u1.count )
   {
      if ( p_chan->flags & OM_CH_restricted )
      {
         p_little_tail = (OM_p_LITTLE_TAIL)((OM_p_OBJID)p_chandata + 
                   (p_chan->u1.count-1));
      }
      else
      {
         p_little_tail = (OM_p_LITTLE_TAIL)((OM_p_CHANNEL_LINK)p_chandata + 
                   (p_chan->u1.count-1));
      }
      p_little_tail->last_index     = p_tail->last_index;
      p_little_tail->collapse_count = p_tail->collapse_count;
      p_chan->flags |= OM_CH_tail_exists;
      p_chan->flags &= ~OM_CH_collapse_count;
   }
   else
   {
      p_chan->flags &= ~OM_CH_tail_exists;
      if (p_tail->collapse_count) p_chan->flags |= OM_CH_collapse_count;
   }
   return (OM_S_SUCCESS);
}



/*
  som_connect_integrity
  ---------------------
 
  Called by test routines to validate channel connections.  Makes sure
  that all objects pointed to by the input object/channel do in fact
  point back to (are connected to) this object's channel.
*/

 som_connect_integrity(os, oid, chsel)

 OMuword os;				/* OS number of object */
 OM_S_OBJID oid;			/* object containing channel */
 OM_S_CHANSELECT chsel;			/* channel selector that defines
					   which channel in object to check */
 {
 int sts, num, ii, chan_res;
 OM_S_CONNECT_SIDE side1, *s1 = &side1;
 OM_S_CONNECT_SIDE side2, *s2 = &side2;
 OM_p_CHANNEL_HDR  chan;
 OM_p_CHANNEL_LINK link=NULL;
 OM_p_OBJID        olink=NULL;

 sts = om$connect_build_side(osnum=os, objid=oid,
		chsel=&chsel, relidx=0, side=s1);
 if (!(1 & sts)) {
    printf("som_connect_integrity: build_side fail for %d,%d (%d.%d)\n",
		os,oid,s1->channum.classid,s1->channum.number);
    om$report_error(sts = sts);
    som_show_object(os, oid);
    exit(1);    
 }
 chan = *s1->pp_chan;
 if (s1->chdef->p_type->w_flags & CD_restricted )
   chan_res = 1;
 else
   chan_res = 0;

 if (s1->chdef->p_type->w_flags & (CD_1_1|CD_m_1)) {
   num = 1;
   if (chan_res)
     olink = (OM_p_OBJID) s1->p_chandata;
   else
     link = (OM_p_CHANNEL_LINK) s1->p_chandata;
 }
 else { 
   num = s1->tail.last_index;
   if (chan_res)
     olink = (OM_p_OBJID) s1->p_chandata;
   else
     link = (OM_p_CHANNEL_LINK) s1->p_chandata;
 }
 if (chan_res) {
   for (ii=num; ii > 0; ii--, olink++) {
     if ( ! IF_NULL_OBJID(*olink)) {
       s1->p_chlink = (OM_p_CHANNEL_LINK)olink;
       s2->chused = TRUE;
       sts = om$connect_pside ( side1=s1, side2=s2 );
       if ( 1 & sts ) {
         om$connect_release_side( side1 = s2 );
       }
       else {
         printf("som_connect_integrity:pside fail for %d,%d(%d.%d) link=%#x\n",
		os,oid,s1->channum.classid,s1->channum.number, link);
         om$report_error(sts = sts);
         som_show_object(os, oid);
         exit(1);    
       }
     } /* close if ! NULL_OBJID */
   } /* close for */
 }
 else {  /* not restrcited */
   for (ii=num; ii > 0; ii--, link++) {
     if ( ! IF_NULL_OBJID(link->objid)) {
       s1->p_chlink = link;
       s2->chused = TRUE;
       sts = om$connect_pside ( side1=s1, side2=s2 );
       if ( 1 & sts ) {
         om$connect_release_side( side1 = s2 );
       }
       else {
         printf("som_connect_integrity:pside fail for %d,%d(%d.%d) link=%#x\n",
		os,oid,s1->channum.classid,s1->channum.number, link);
         om$report_error(sts = sts);
         som_show_object(os, oid);
         exit(1);    
       }
     } /* close if ! NULL_OBJID */
   } /* close for */
 }

 s1->chused = TRUE;
 om$connect_release_side (side1=s1);
 return(OM_S_SUCCESS);
}


/*
  som_connect_show_side
  ---------------------
  
  Called by debug prints to print contents of side structure.
  Only compiled if DEBUG defined.
*/

 int som_connect_show_side(str, s1)

 char *str;				/* string to identify print -
					   ignored if NULL */
 OM_p_CONNECT_SIDE s1;			/* side structure to print */
 {
  OMuword classid;

  if (str && *str) {
    printf("%s",str);
  }
  printf("---> CONNECT_SIDE <--- os=%d oid=%d relidx=%d ins=%#x map=%#x\n",
		s1->osnum, s1->objid, s1->relidx, s1->rip.p_object,
		s1->rip.p_mapentry);
  classid = OM_GA_OSDs[s1->osnum]->FilToAct[s1->channum.classid];
 printf("      ppchan=%#x chnum=%d.%d chdef=%#x pcld=%#x link=%#x chused=%d\n",
		s1->pp_chan, classid, s1->channum.number,
		s1->chdef, s1->p_cld, s1->p_chlink, s1->chused);
  printf("      p_chan=%#x p_chandata=%#x tail.li=%d tail.cc=%d\n",
                *s1->pp_chan, s1->p_chandata, s1->tail.last_index,
                s1->tail.collapse_count);
  if ( ! IF_NULL_OBJID(s1->iso_objid)) {
     printf("      iso_oid=%d  iso_index=%d\n",s1->iso_objid, s1->iso_index);
  }
#ifdef NOTNOW
if ((*s1->pp_chan)->flags & OM_CH_singleton) {
  som_show_channel(s1->osnum, *s1->pp_chan, s1->chdef, TRUE, s1->p_cld);
}
#endif
  return(OM_S_SUCCESS);
 }
