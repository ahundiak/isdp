class	implementation	OMISO;

/*
Class:		OMISO

This file contains methods for following messages:

		debug
		delete
		set_OSnumber
		reset_OSnumber
		unlink_entry
		unlink_all
		resolve_yourself
		dissolve_yourself
		get_index_oid
		fixup_for_write

Author:		Kerry Kilbride
Creation Date:	apr-1986
Imported Methods:


Change History:

cgp001	29-apr-1986	OM3.2	Change resolve yourself so that it gets
				rid of any accidental transient
				connections. Add new message 
				(wefixup_for_write) that sets flags if are
				are a transient OS.

kek001  07-may-1986	OM3.2	fix get_index_oid to return correct major
				channel number when ISO points to rel.
				fix for loops based on vla siz.

rme001	05-may-1987	OM4.2	remove calls to movary.
*/

#include	<stdio.h>
#include 	"OMobjectcomm.h"
#include	"OMspecify.h"
#include	"OMrelation.h"
#include 	"OMintprims.h"
#include	"OMmetaclass.h"
#include        "OMtags.h"

extern int	som_ISO_delete_entry();
extern int	som_ISO_print();
extern int	som_ISO_set_dimension();
extern int	som_connect_build_fake_side();
extern int	som_disconnect_from_ISO();
extern int	som_show_object();

extern  OMuword	OM_Gw_defISO_size;
extern  OMuword	OM_Gw_defISO_ext;
extern  OMuword	OM_Gw_defISOdir_size;
extern  OMuword	OM_Gw_defISOdir_ext;

#define P(p) ((struct ISO_data *)(p##_descr.i_offset))

%safe
 int OM_Gi_OMISO_debug=0;
%endsafe

from OMObjSpace import remove_iso, find_iso;

/*
  OMISO.debug
  -----------

  Override debug method first invokes Root.debug then fomats and prints
  ISO instance data.
*/

 method	debug ()
{
  int		count, ii;
  
  om$send (mode= OM_e_wrt_message, msg=message Root.debug(), targetid=my_id);
  printf ("\n");
  printf ("Flags:        %8x ", ME.OMISO->w_ISO_flags);
  if (ME.OMISO->w_ISO_flags & ISO_no_target) printf ("[no_target] ");
  if (ME.OMISO->w_ISO_flags & ISO_to_transient) printf ("[to_transient] ");
  printf ("\n");
  printf ("Dangle cnt:   %8d\n", ME.OMISO->w_dcount);
  printf ("Target OS #:  %8d\n", ME.OMISO->osnum);
  printf ("Target ISO:   %8d\n", ME.OMISO->S_target_iso);
  count = om$dimension_of(varray=ME.OMISO->iso_d);
  printf ("array size:   %8d\n\n", count);
  for (ii=0;  ii < count-1; ii++)
  {
    if (ME.OMISO->iso_d[ii].w_flags != 0)
    {
      printf ("  element %3d: flags= %8x ", ii, ME.OMISO->iso_d[ii].w_flags);
      if (ME.OMISO->iso_d[ii].w_flags & ISO_disconnected) {
        printf ("[disconnected] \n");
      }
      else if (ME.OMISO->iso_d[ii].w_flags & ISO_logical_disconnect) {
        printf ("[logically disconnected] \n");
      }
      else if (ME.OMISO->iso_d[ii].w_flags & ISO_logical_connect) {
        printf ("[logically connected] \n");
      }
      if (!(ME.OMISO->iso_d[ii].w_flags & 
                               (ISO_disconnected|ISO_logical_disconnect)))
      {
         printf ("\n    target objid: %8d, channum: %3d.%4d\n",
         ME.OMISO->iso_d[ii].iso_u.s_objid, ME.OMISO->iso_d[ii].chan.classid,
	 ME.OMISO->iso_d[ii].chan.number);
      }
    }
  }
  return (OM_S_SUCCESS);
}


/*
   Override delete so that is illegal to delete ISO if any connections
   still exist.

   defer_flag - passed to Root.delete
*/

method	delete (int defer_flag)
{
  int		bound, ii;
  
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_delete defer=%d obj=%d,%d\n",
			defer_flag,OM_Gw_current_OS,my_id);
 }
#endif
  bound = om$dimension_of(varray=ME.OMISO->iso_d);
  for (ii=0; ii < bound; ii++)
  {
    if (ME.OMISO->iso_d[ii].w_flags != 0)
    {
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
   printf("OMISO_delete OM_E_OBJECT_LOCKED\n");
 }
#endif
      return (OM_E_OBJECT_LOCKED);
    }
  }
  return (om$send (mode=OM_e_wrt_message, 
			msg = message Root.delete (TRUE), targetid = my_id));
}


/*
	reset_OSnumber tells us that a the target OS is leaving.
*/
method	reset_OSnumber	()
{
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_reset_OSnumber obj=%d,%d\n",
		OM_Gw_current_OS,my_id);
 }
#endif
  ME.OMISO->osnum = (OMuword) OM_K_OSNOTHERE;
  ME.OMISO->w_ISO_flags |= ISO_no_target;
  return (OM_S_SUCCESS);
}


/*	
  set_OSnumber informs us that an ISO's target has just been
  (re)constructed & what its OS number is.
*/

method	set_OSnumber	(OMuword target_OS)
{
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_set_OSnumber target_OS=%d obj=%d,%d\n",target_OS,
		OM_Gw_current_OS,my_id);
 }
#endif
  ME.OMISO->osnum = target_OS;
  ME.OMISO->w_ISO_flags &= ~ISO_no_target;
  if (OM_GA_OSDs[target_OS]->flags & OM_e_loados_ro)
     ME.OMISO->w_ISO_flags |= ISO_to_read_only;
  else
     ME.OMISO->w_ISO_flags &= ~ISO_to_read_only;
  return (OM_S_SUCCESS);
}

/*
  unlink_all unlinks all objects that are connected to this ISO in this OS 

  unlink_entry unlinks a single entry from the ISO.
*/
method	unlink_entry	(OMuword entry_index)
{
  int		sts;
  
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_unlink_entry ndx=%d obj=%d,%d\n",entry_index,
		OM_Gw_current_OS,my_id);
 }
#endif
  if (ME.OMISO->iso_d[entry_index].w_flags & ISO_disconnected)
  {
     ME.OMISO->iso_d[entry_index].w_flags = 0;
  }
  else if (ME.OMISO->iso_d[entry_index].w_flags & ISO_to_object)
  {
    if (!(1&(sts = som_disconnect_from_ISO 
     		     (OM_Gw_current_OS, my_id, me, entry_index))))
    {
      return (sts);
    }
  }
  return (som_ISO_delete_entry (OM_Gw_current_OS, my_id, me, entry_index));
}


/*
  unlink_all unlinks all objects that are connected to this ISO in this OS 
*/
method	unlink_all ()
{
  int		upper_bound, ii, sts;
  
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_unlink_all obj=%d,%d\n",
		OM_Gw_current_OS,my_id);
 }
#endif
  upper_bound = om$dimension_of(varray=ME.OMISO->iso_d);
  for (ii = (upper_bound-1); ii >= 0; ii--)
  {
    if (ME.OMISO->iso_d[ii].w_flags & ISO_to_object)
    {
      if (!(1&(sts = om$send (msg = message OMISO.unlink_entry (ii), 
				     targetid = my_id))))
      {
        return (sts);
      }
    }
  }
  return (OM_S_SUCCESS);
}


/*

  This method makes a pass for all dangles, sending a unlink message to the
   target OS for each dangle. As each unlink is successful, the ISO entry is
   deleted (via call to OM_ISO_delete_entry). Then, after all is OK, a
   set_OSnumber message is set to the target OS to use our current OS, and we
   use the target OS in our ISO
  cgp002
  A check is made to see if this ISO was accidentally left from a write, and
   was a link to a transient OS. If so, then we disconnect all connections in
   our OS to this ISO, deleting each ISO entry as we go along. The last delete
   should cause this ISO to also go away.
  cgp003
  Send a "resolve_yourself" message to target ISO when he is here.
*/

method	resolve_yourself (char *target_OSintname)
{
  int		ii, sts, bound;
  OMuword	target_OS;
  OMuword       del_ISO;
  
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_resolve_yourself: OSname=%s, my OS#=%d\n",
		target_OSintname, OM_Gw_current_OS);
 }
#endif
  if (ME.OMISO->w_ISO_flags & ISO_to_transient)
  {
    bound = om$dimension_of(varray=ME.OMISO->iso_d);
    for (ii=(bound-1); ii >= 0; ii--)
    {
      if (ME.OMISO->iso_d[ii].w_flags & ISO_disconnected) 
      {
         ME.OMISO->iso_d[ii].w_flags = 0;
         som_ISO_delete_entry (OM_Gw_current_OS, my_id, me, ii);
         continue;
      }
      if (ME.OMISO->iso_d[ii].w_flags & ISO_to_object )
      {
        som_disconnect_from_ISO (OM_Gw_current_OS, my_id, me, ii);
        som_ISO_delete_entry (OM_Gw_current_OS, my_id, me, ii);
      }
    }
    return (om$send (msg = message Root.delete (TRUE), targetid=my_id));
  }

  if (ME.OMISO->w_ISO_flags & ISO_to_read_only)
  {
    bound = om$dimension_of(varray=ME.OMISO->iso_d);
    del_ISO = 1;
    for (ii=(bound-1); ii >= 0; ii--)
    {
      if (ME.OMISO->iso_d[ii].w_flags & ISO_to_object )
      {
        if (ME.OMISO->iso_d[ii].w_flags & ISO_logical_connect)
        {
          som_disconnect_from_ISO (OM_Gw_current_OS, my_id, me, ii);
          som_ISO_delete_entry (OM_Gw_current_OS, my_id, me, ii);
        }
        else
        {
          del_ISO = 0;
        }
      }
    }
    if (del_ISO)
      return (om$send (msg = message Root.delete (TRUE), targetid=my_id));
  }
  
/* target OS currently availanble? */

  if (!(1&(sts = om$os_internal_name_to_number 
        	     (osname = target_OSintname, p_osnum = &target_OS))))
  {

    ME.OMISO->osnum        = (OMuword) OM_K_OSNOTHERE;
    ME.OMISO->w_ISO_flags |= ISO_no_target;
    return (OM_S_SUCCESS);
  }
  else
  {
    return (om$send (msg = message OMISO.do_dangles (target_OS, TRUE), 
			    targetid = my_id));
  }
}


method	do_dangles (OMuword target_OS;int SendToPartner)
{
  int		sts, ii, bound;
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_do_dangles: t_OS=%d S2P=%d d_count=%d obj=%d,%d\n",
	target_OS,SendToPartner,ME.OMISO->w_dcount,
		OM_Gw_current_OS,my_id);
 }
#endif
  if (ME.OMISO->w_dcount != 0)		/* any dangles at all? */
  {
    bound = om$dimension_of(varray=ME.OMISO->iso_d);
    for (ii=(bound-1); ii >= 0 ; ii--)
    {
      /*==================================*/
      /*  check for disconnection dangle  */
      /*==================================*/

      if (ME.OMISO->iso_d[ii].w_flags & ISO_disconnected)
      {
        if (!(1&(sts = om$send (msg = message OMISO.unlink_entry (ii), 
				targetid = ME.OMISO->S_target_iso, 
				targetos = target_OS))))
        {
          BUGCHECK ("OMISO.do_dangles: Send(->Filed) to _unlink failed");
          continue;
        }
        if (!(1&(sts = som_ISO_delete_entry(OM_Gw_current_OS, my_id, me, ii))))
        {
          BUGCHECK ("OMISO.do_dangles: (->Filed) delete my entry failed");
          continue;
        }
      } /* if currrent entry is a disconnected dangle */

      /*=======================================*/
      /*  check for logical connection dangle  */
      /*=======================================*/

      if (ME.OMISO->iso_d[ii].w_flags & ISO_logical_connect)
      {
         sts = om$send (msg = message OMISO.unlink_entry(ii),
                        targetid = my_id );
         if (!(1&sts))
         {
            BUGCHECK("OMISO.do_dangles: _unlink of logical connect failed");
            continue;
         }
      } /* if current entry is a logically connected dangle  */
    } /* for loop to get rid of dangles */
  } /* if any dangles */
  ME.OMISO->osnum = target_OS;
  ME.OMISO->w_ISO_flags &= ~ISO_no_target;
  if (OM_GA_OSDs[target_OS]->flags & OM_e_loados_ro)
     ME.OMISO->w_ISO_flags |= ISO_to_read_only;
  else
     ME.OMISO->w_ISO_flags &= ~ISO_to_read_only;

  if (!SendToPartner)
  {
    return (OM_S_SUCCESS);
  }
  
  sts = om$send (msg = message OMISO.do_dangles (OM_Gw_current_OS, FALSE), 
                 targetid = ME.OMISO->S_target_iso, targetos = target_OS);
  if (!(1&(sts)))
  {
    sts = om$send (msg = message OMISO.unlink_all(), targetid = my_id);
    return (om$send (msg = message Root.delete (TRUE), targetid=my_id));
  }
  return (om$send (msg = message OMISO.set_OSnumber (OM_Gw_current_OS), 
		   targetid = ME.OMISO->S_target_iso, targetos = target_OS));
}


/* dissolve_yourself

  This method determines the OS type for "our" OS and the target OS. 
The only current valid types are MOSDOS, transient, and filed. It
then handles them as follows:

Ours	Theirs		What-to-do
----	------		----------

MOSDOS	any		BUGCHECK - should be no ISO connections to MOSDOS 
			spaces as of this writing.

any	MOSDOS		BUGCHECK - should be no ISO connections to MOSDOS 
			spaces as of this writing.

Trans	Trans		Send an ISO.reset_OS message to target. Since they
			are transient, this is easiest and most efficient
			thing to do.

Trans	Filed		Send an ISO.unlink_all message so that filed will
			essentially dissolve all connections to this ISO.
			Then turn myself off.

Filed	Trans		For everybody in our side, find everybody on their
			side,  and issue a real disconnect. There can be no
			references left to transient spaces. Since we
			disconnect EVERYBODY on our side, this ISO will
			also go away,  so that is all we need to do.

Filed	Filed		Send an ISO.reset_OS message to target,  informing
			it that this ISO connection is no longer valid.


 we invent this macro to make up switch values rather than having nested
   switches */

#define US_THEM(our_type, their_type) (our_type << 8) + their_type

method	dissolve_yourself (OMuword target_OS)
{
  int		ii, sts, upper_bound;
  OM_S_OBJID	theirside_oid, myside_oid=0;
  OM_S_CHANNUM	myside_channum, their_channum;
  OM_S_CHANSELECT t_sel, f_sel;
  OMbyte          us_ro, them_ro;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_dissolve_yourself target_OS=%d obj=%d,%d\n",target_OS,
		OM_Gw_current_OS,my_id);
 }
#endif
  switch (US_THEM (OM_GA_OSDs[OM_Gw_current_OS]->type,
		   OM_GA_OSDs[target_OS]->type))
  {

  case US_THEM (OM_OSD_trans, OM_OSD_trans):
  case US_THEM (OM_OSD_filed, OM_OSD_filed):
    us_ro   = OM_Gp_CurOSD->flags & OM_e_loados_ro;
    them_ro = OM_GA_OSDs[target_OS]->flags & OM_e_loados_ro;
    if (us_ro && !them_ro) {
       om$send ( msg      = message OMISO.resolve_yourself("OuTrAgEoUs_NaMe"),
                 targetid = ME.OMISO->S_target_iso,
                 targetos = target_OS );
    }
    else if (!us_ro && them_ro) {
       om$send ( msg      = message OMISO.resolve_yourself("OuTrAgEoUs_NaMe"),
                 targetid = my_id );
    }

    ME.OMISO->osnum = (OMuword) OM_K_OSNOTHERE;
    ME.OMISO->w_ISO_flags |= ISO_no_target;  
    return (om$send (msg = message OMISO.reset_OSnumber (), 
		     targetid = ME.OMISO->S_target_iso, targetos = target_OS));

  case US_THEM (OM_OSD_trans, OM_OSD_filed):
    ME.OMISO->osnum = (OMuword) OM_K_OSNOTHERE;
    ME.OMISO->w_ISO_flags |= ISO_no_target;  
    return (om$send(msg = message OMISO.unlink_all (), 
		    targetid = ME.OMISO->S_target_iso, targetos = target_OS));
  case US_THEM (OM_OSD_filed, OM_OSD_trans):
    upper_bound = om$dimension_of(varray=ME.OMISO->iso_d);
    for (ii=(upper_bound-1); ii >= 0 ; ii--)
    {
      if (ME.OMISO->iso_d[ii].w_flags != 0)
      {
        if (ME.OMISO->iso_d[ii].w_flags & ISO_to_object)
	{
	  myside_oid = ME.OMISO->iso_d[ii].iso_u.s_objid;
	  myside_channum = ME.OMISO->iso_d[ii].chan;
          myside_channum.classid = OM_GA_filed_to_active[myside_channum.classid];
	}
	else
	{
	  BUGCHECK ("OMISO.dissolve_yourself: Not to_object myside");
	}
	if (!(1&(sts = om$send (msg = message OMISO.get_index_oid 
				  (ii, &theirside_oid, &their_channum),
				targetid = ME.OMISO->S_target_iso, 
				targetos = target_OS))))
	{
	  BUGCHECK ("OMISO.dissolve_yourself: send to target failed");
	  return (sts);
	}
	t_sel.type = f_sel.type = OM_e_num;
	t_sel.u_sel.number = myside_channum;
	f_sel.u_sel.number = their_channum;
	sts = om$send (msg = message Root.disconnect ( 
			t_sel,
			theirside_oid, target_OS, f_sel),
		       targetid = myside_oid);
	if (!(1&sts))
	{
	  BUGCHECK("OMISO.dissolve_yourself: disconnect fail");
	  return (sts);
	  
	}
      }
    }
    ME.OMISO->osnum = (OMuword) OM_K_OSNOTHERE;
    ME.OMISO->w_ISO_flags |= ISO_no_target;
    return (OM_S_SUCCESS);
  default:
    BUGCHECK ("OMISO.dissolve_yourself: unsupported OS type");
    return (OM_F_BUGCHECK);
  }
}


/*
   This method returns the "original" object (and channel number) that was
   connected along this ISO
*/
method	get_index_oid	(OMuword index; OM_S_OBJID *oid; OM_S_CHANNUM *channum)
{
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("OMISO_get_index_oid ndx=%d\n",index);
 }
#endif
  if (index >= om$dimension_of(varray=ME.OMISO->iso_d))
  {
    return (OM_E_INVARG);
  }
  if (ME.OMISO->iso_d[index].w_flags == 0)
  {
    return (OM_E_NOSUCHOBJ);
  }

  if (ME.OMISO->iso_d[index].w_flags & ISO_to_object)
  {
    *oid = ME.OMISO->iso_d[index].iso_u.s_objid;
    *channum = ME.OMISO->iso_d[index].chan;
    channum->classid = OM_GA_filed_to_active[channum->classid];
    return (OM_S_SUCCESS);
  }
  BUGCHECK ("OMISO.get_index_oid: invalid ISO entry");
  return (OM_F_BUGCHECK);
}


/*
  All this does for now is set a flag in the ISO header denoting that this ISO
   is connected to a transient OS. This can be detected when the OS is
   reloaded and all connections disbanded at that time. Note that this is
   easier to do for intermediate writes than trying to temporarily dissolve
   connections, only to resolve them back after the write
*/
method	fixup_for_write ()
{
  if ((!(ME.OMISO->w_ISO_flags & ISO_no_target))
  			&&
      (OM_GA_OSDs[ME.OMISO->osnum]->type == OM_OSD_trans))
  {
    ME.OMISO->w_ISO_flags |= ISO_to_transient;
  }
  return (OM_S_SUCCESS);
}


method is_readonly ()
{
   int d, i;

   if (!ME.OMISO->w_ISO_flags & ISO_to_read_only) return (OM_W_ISODIRONOS);
   d = om$dimension_of (varray = ME.OMISO->iso_d);
   for (i=0; i<d; ++i)
      if ((ME.OMISO->iso_d[i].w_flags) &&
          ((ME.OMISO->iso_d[i].w_flags & 0x0f) == ISO_to_object))
         return (OM_W_ISODIRONOS);
   return (OM_S_SUCCESS);
}


/*
   Given an iso entry index disconnect whatever it points to.
   Operates only in this ISO's OS.
   Does not modify ISO.
*/
som_disconnect_from_ISO( osn, oid, MYME, ndx)
 OMuword	osn;		/* this OS number */
 OM_S_OBJID	oid;		/* oid of ISO */
 struct OMISO_total_instance *MYME; /* instance pointer for this oid */
 OMuword	ndx; 		/* ISO entry index to be disconnected */
 {
  struct ISO_data	*p_data;
  int			ii, sts;
  OM_S_CHANSELECT	chsel;
  OM_S_CONNECT_SIDE	side, *s1 = &side;
  OM_p_CHANNEL_LINK	link;
  struct OMISO_instance	*myme;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_disconnect_from_ISO osn=%d oid=%d MYME=%x ndx=%d\n",
		osn,oid,MYME,ndx);
 }
#endif
  myme = &(MYME->OMISO);
  p_data = &(P(myme->iso_d)[ndx]);
  chsel.type = OM_e_num;

  if(OM_GA_OSDs[osn]->Spacemap[p_data->iso_u.s_objid].flags&OM_SM_unknown_obj){
    sts = som_connect_build_fake_side (osn, p_data->iso_u.s_objid, 
                             p_data->chan, 0, NULL_CHANNUM, s1);
    if (!(1&sts)) {
      BUGCHECK("som_disconnect_from_iso: som_connect_build_fake_side fail");
      return(OM_F_BUGCHECK);
    }    
  }
  else {
    chsel.u_sel.number = p_data->chan;
    chsel.u_sel.number.classid=OM_GA_OSDs[osn]->FilToAct[p_data->chan.classid];

    sts = om$connect_build_side(osnum = osn, objid = p_data->iso_u.s_objid,
                                chsel =  &chsel, relidx = 0, side = s1);
    if (!(1 & sts)) {
      BUGCHECK("som_disconnect_from_iso: som_connect_build_side fail");
      return(OM_F_BUGCHECK);
    }
  }

  link = (OM_p_CHANNEL_LINK)(s1->p_chandata);

  for (ii=s1->tail.last_index; ii>0; ii--, link++) {
    if (IF_EQ_OBJID(link->objid, oid) && link->hdr.u1.isoindex == ndx) {
      break;
    }
  }
  if ( ! ii ) {
     BUGCHECK("som_disconnect_from_iso: cant find channel entry");
     return(OM_F_BUGCHECK);
  }
  side.p_chlink = link;
  side.chused   = FALSE;
  om$connect_release_side (side1 = s1);
  return(OM_S_SUCCESS);
 }


/*
  add a new entry to ISO - extend VLA if necessary 
*/
som_ISO_add_entry (osn, i_oid, n_oid, chan, p_ndx, other_osn)
 OMuword       osn;	/* os number */
 OM_S_OBJID  i_oid;	/* objid of ISO */
 OM_S_OBJID  n_oid;	/* objid for new entry */
 OM_p_CHANNUM chan;	/* channel number being connected */
 OMuword    *p_ndx;	/* return - ISO index used */
 OMuword other_osn;     /* os number of other "side" */
 {
  struct ISO_data *p_data;
  OM_S_RIP  rip;
  int i, vsz, need_move;
  struct OMISO_instance *myme;
  int sts;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_ISO_add_entry osn=%d ioid=%d new_oid=%d chn=%d\n",
		osn,i_oid,n_oid,chan);
 }
#endif
  sts = om$get_any_instance(osnum = osn, objid = i_oid, p_rip = &rip);
  if (! (1 & sts)) {
     BUGCHECK("som_ISO_add_entry: no ISO instance");
     return(OM_F_BUGCHECK);
  }
  myme = &(((struct OMISO_total_instance *) rip.p_object)->OMISO);
  vsz = om$dimension_of(varray=myme->iso_d);
	/* if no room for new entry - extend VLA and init */
  if ( myme->i_first < 0 ) {
     if (!(1&(sts=som_ISO_set_dimension(osn, i_oid, &myme->iso_d_descr, 
				(OMuint)(vsz + OM_Gw_defISO_ext))))){
	BUGCHECK("som_ISO_add_entry: som_ISO_set_dimension fail");
	return(OM_F_BUGCHECK);
     }
     need_move = 1;
     myme->i_first = vsz;
     p_data = &P(myme->iso_d)[vsz];
     vsz = om$dimension_of(varray=myme->iso_d);
     for (i=myme->i_first; i<vsz; ) {
	p_data->w_flags = 0;
	(p_data++)->iso_u.i_next = ++i;
     }
     (p_data-1)->iso_u.i_next = -1;
  }
  else {
     need_move = 0;
  }
  *p_ndx = myme->i_first;
  p_data = &P(myme->iso_d)[myme->i_first];
  myme->i_first = p_data->iso_u.i_next;
/* !!!!!!!!!!!!! debug only !!!!!!!!!!!!!!!!! */
  if (( myme->i_first != -1) && P(myme->iso_d)[myme->i_first].w_flags != 0) {
    printf("OMISO_add_entry i_first trap\n");
    som_ISO_print(osn, i_oid);
    exit(1);
  }
  p_data->chan  = *chan;
  p_data->iso_u.s_objid = n_oid;
  p_data->w_flags = ISO_to_object;
  
  /* check for logical connection between RO and RW OS's */

  if (!(OM_GA_OSDs[osn]->flags & OM_e_loados_ro) &&
       (OM_GA_OSDs[other_osn]->flags & OM_e_loados_ro)) {
     p_data->w_flags |= ISO_logical_connect;
     myme->w_dcount++;
  }   
  om$release_any_instance(osnum = osn, rip = rip);
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("xsom_ISO_add_entry - vsz=%d return index=%d\n",vsz,*p_ndx);
 }
#endif
  return (OM_S_SUCCESS);
 }


/*
   Change fields in an existing ISO entry
*/
som_ISO_change_entry(f_osn, i_oid, n_oid, chan, ndx)

OMuword	   f_osn;	/* os number for this ISO */
OM_S_OBJID i_oid;	/* this ISO objid */
OM_S_OBJID n_oid;	/* change entry to this objid */
OM_p_CHANNUM chan;	/* change entry to this channel */
OMuword	   ndx;		/* index of entry to be changed */
 {
 struct OMISO_instance *myme;
 struct ISO_data *p_data;
 OM_S_RIP rip;
 OMuword vsz;
 int sts;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_ISO_change_entry osn=%d ioid=%d new_oid=%d chn=%d flg=%x",
		f_osn,i_oid,n_oid,chan);
  printf(" ndx=%d\n",ndx);
 }
#endif
 sts = om$get_any_instance(osnum = f_osn, objid = i_oid, p_rip = &rip);
 if (! (1 & sts)) {
    BUGCHECK("som_ISO_change_entry: no ISO instance");
    return(OM_F_BUGCHECK);
 }
 myme = &(((struct OMISO_total_instance *) rip.p_object)->OMISO);
 vsz = om$dimension_of(varray=myme->iso_d);
 if ( ndx >= vsz ) {
    BUGCHECK("som_ISO_change_entry: index too large for VLA");
    return(OM_F_BUGCHECK);
 }
 p_data = &P(myme->iso_d)[ndx];
 if ( ! p_data->w_flags ) {
    BUGCHECK("som_ISO_change_entry: entry not in use");
    return(OM_F_BUGCHECK);
 }
 p_data->chan  = *chan;
 p_data->iso_u.s_objid = n_oid;
 om$release_any_instance(osnum = f_osn, rip = rip);
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("xsom_ISO_change_entry\n");
 }
#endif
 return(OM_S_SUCCESS);
} 


/*
   Check if ISO empty (ie has no entries).
   IF so remove from ISOdir and then delete ISO.
*/
som_ISO_check_empty (osn, i_oid)
 OMuword    osn;		/* ISO os space number */
 OM_S_OBJID i_oid;		/* ISO objid */
 {
  struct OMISO_instance *myme;
  struct ISO_data *p_data;
  int i, vsz, sts;
  OM_S_RIP rip;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_ISO_check_empty: osn=%d oid=%d\n",osn,i_oid);
 }
#endif
  sts = om$get_any_instance(osnum = osn, objid = i_oid, p_rip = &rip);
  if ( ! ( 1 & sts )) {
     return(sts);
  }
  myme = &(((struct OMISO_total_instance *) rip.p_object)->OMISO);
  p_data = P(myme->iso_d);
  vsz = om$dimension_of(varray=myme->iso_d);
  for (i=vsz; i > 0; i--, p_data++) {
     if (p_data->w_flags) {
	om$release_any_instance(osnum = osn, rip = rip);
	return(OM_S_SUCCESS);
     }
  }
  
	/*  none in use - remove ISO from ISOdir and delete ISO */
  sts = om$send(msg = message OMObjSpace.remove_iso ( i_oid ),
		   senderid = 0,
		   targetos = osn, targetid = OM_GA_OSDs[osn]->OSO_Oid);
 if (!(1 & sts)) {
    BUGCHECK("som_ISO_check_empty: ISOdir_remove_iso fail");
    return (OM_F_BUGCHECK);
 }
 if (!(1 & om$send (msg = message OMISO.delete (TRUE),
		   senderid = 0,
		   targetid = i_oid, targetos = osn))) {
    BUGCHECK("som_ISO_check_empty: send OMISO.delete failed");
    return (OM_F_BUGCHECK);
 }
 return (OM_S_SUCCESS);
 }


/* 
   construct an ISO object with default VLA size
   contents are NOT initialized
   returns ISO objid thru passed pointer
*/
som_ISO_construct(osn, p_oid)
OMuword	     osn;	/* os number */
OM_p_OBJID p_oid;       /* pointer used to return ISO oid */
 {
  struct OMISO_instance *myme;
  int sts;
  OM_S_RIP rip;
  OM_S_NEIGHBOR neighbor;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_ISO_construct osn=%d\n",osn);
 }
#endif

  neighbor.clusterid = 0;
  neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;

  sts = om$construct(classid = OM_K_OMISO_ACTCLASSID, p_objid = p_oid,
		     osnum = osn, neighbor = neighbor );
  if (!(1 & sts)) {
    om$report_error(sts = sts);
#ifdef DEBUG
    printf("som_ISO_construct om$construct fail\n");
    exit(1);
#endif
    BUGCHECK("som_ISO_construct: construct fail");
    return(sts);
  }
  sts = om$get_any_instance(osnum = osn, objid = *p_oid, p_rip = &rip);
  if (!(1 & sts)) {
    BUGCHECK("som_ISO_construct: get_any_instance fail");
    return(sts);
  }
  myme = &(((struct OMISO_total_instance *) rip.p_object)->OMISO);
  sts = som_ISO_set_dimension(osn, *p_oid, &myme->iso_d_descr, (OMuint)OM_Gw_defISO_size);
  if (!(1 & sts)) {
    om$report_error(sts=sts);
    BUGCHECK("som_ISO_construct: set_dimension fail");
    return(sts);
  }
  return (OM_S_SUCCESS);
 }


/*
   An ISO entry has been marked for delete or disconnect in both
   spaces.  In this os make the entry available.  If the ISO is
   then empty delete it and remove it from the ISOdir.  If there
   are still entries in use but there are a block of available 
   entries at the end of the VLA that exceed the extend size then
   reduce the size of the VLA.
*/
som_ISO_delete_entry(osn, i_oid, MYME, ndx)
 OMuword    osn;		/* ISO os space number */
 OM_S_OBJID i_oid;		/* ISO objid */
 struct OMISO_total_instance *MYME;	/* ISO instance pointer */
 OMuword     ndx;		/* index of entry to delete */
 {
  struct ISO_data *p_data;
  struct OMISO_instance *myme;
  int i, vsz, sts;
  OM_S_RIP rip;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_ISO_delete_entry osn=%d oid=%d MYME=%x ndx=%d\n",
		osn,i_oid,MYME,ndx);
 }
#endif
  myme = &(MYME->OMISO);
  p_data = &P(myme->iso_d)[ndx];
	/* make this entry available */
  p_data->iso_u.i_next = myme->i_first;
  p_data->w_flags = 0;
  myme->i_first = ndx;
/* !!!!!!!!!!!!! debug only !!!!!!!!!!!!!!!!! */
  if ((myme->i_first != -1) && P(myme->iso_d)[myme->i_first].w_flags != 0) {
    printf("OMISO_delete_entry i_first trap\n");
    som_ISO_print(osn, i_oid);
    exit(1);
  }
  myme->w_dcount--;  /* reduce dangle count -- always set when marked */
	/* scan for in use entry with largest index */
  vsz = om$dimension_of(varray=myme->iso_d);
  p_data = &P(myme->iso_d)[vsz];
  for (i=vsz; i > 0; i--) {
     if ((--p_data)->w_flags) {
	break; 	/* this one is in use */
     }
  }
	/* if none in use - remove ISO from ISOdir and delete ISO */
  if ( ! i ) {
     sts = om$send(msg = message OMObjSpace.remove_iso ( i_oid ),
		   senderid = 0,
		   targetos = osn, targetid = OM_GA_OSDs[osn]->OSO_Oid);
     if (!(1 & sts)) {
	BUGCHECK("som_ISO_delete_entry: ISOdir_remove_iso fail");
	return (OM_F_BUGCHECK);
     }
     if (!(1 & om$send (msg = message OMISO.delete (TRUE),
		   senderid = 0,
		   targetid = i_oid, targetos = osn))) {
       BUGCHECK("som_ISO_delete_entry: send OMISO.delete failed");
       return (OM_F_BUGCHECK);
     }
  }
 	/* if chunk at end larger than extend size reduce VLA */
  else {
    if ( i < (int) OM_Gw_defISO_size ) {
      i = OM_Gw_defISO_size;
    }
    if ( (vsz - i) > (int) OM_Gw_defISO_ext) {
     while ( (vsz - i) > (int) OM_Gw_defISO_ext) {
	vsz -= OM_Gw_defISO_ext;
     }
	/* need rip for set_dimension */     
     if (!(1 & om$get_any_instance(osnum=osn, objid = i_oid, p_rip = &rip))) {
	BUGCHECK("som_ISO_delete_entry: get_any_instance fail");
	return (OM_F_BUGCHECK);
     }
     if (!(1 & som_ISO_set_dimension(osn, i_oid, &myme->iso_d_descr, (OMuint)vsz))) {
	BUGCHECK("som_ISO_delete_entry: set_dimension fail");
	return (OM_F_BUGCHECK);
     }
     om$release_any_instance (osnum = osn, rip = rip );
     myme->i_first = -1;	/* relink all empty entries */
     vsz = om$dimension_of(varray=myme->iso_d) - 1;
     p_data = &P(myme->iso_d)[vsz];
     for (i=vsz; i >= 0; i--) {
	if (! p_data->w_flags ) { /* this one is empty */
	   p_data->iso_u.i_next = myme->i_first;
	   myme->i_first = i;
	}
	p_data--;
     }
/* !!!!!!!!!!!!! debug only !!!!!!!!!!!!!!!!! */
  if ((myme->i_first != -1) && P(myme->iso_d)[myme->i_first].w_flags != 0) {
    printf("OMISO_delete_entry  2 i_first trap\n");
    som_ISO_print(osn, i_oid);
    exit(1);
  }
    }  /* end if */
  } /* end else */
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("xsom_ISO_delete_entry  vsz=%d\n",vsz);
 }
#endif
   return (OM_S_SUCCESS);
 }


/*
   set initial values for an ISO object
*/
som_ISO_init_iso (f_osn,f_oid, t_osn,t_oid)

OMuword	   f_osn;	/* from os number */
OM_S_OBJID f_oid;	/* from ISO object objid */
OMuword	   t_osn;	/* target os number */
OM_S_OBJID t_oid;	/* target ISO object objid */
 {
  OM_S_RIP rip;
  struct OMISO_instance *myme;
  int vsz, i, sts;
  struct ISO_data *p_data;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_ISO_init_iso fosn=%d foid=%d tosn=%d toid=%d\n",
		f_osn,f_oid,t_osn,t_oid);
 }
#endif
  sts = om$get_any_instance(osnum = f_osn, objid = f_oid, p_rip = &rip);
  if (!(1& sts)) {
      BUGCHECK("som_ISO_init_iso: no ISO instance");
      return(OM_F_BUGCHECK);
  }
  myme = &(((struct OMISO_total_instance *) rip.p_object)->OMISO);
  vsz = om$dimension_of(varray=myme->iso_d);
  myme->osnum = t_osn;
  myme->w_ISO_flags = 0;
  if (OM_GA_OSDs[t_osn]->flags & OM_e_loados_ro)
    myme->w_ISO_flags |= ISO_to_read_only;
  myme->w_dcount = 0;
  myme->S_target_iso = t_oid;
  myme->i_first = 0;
  p_data = P(myme->iso_d);
  for (i=0; i < vsz; ) {
     p_data->w_flags = 0;
     (p_data++)->iso_u.i_next = ++i;
  }
  (p_data-1)->iso_u.i_next = -1;
  om$release_any_instance(osnum = f_osn, rip = rip);
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("xOM_ISO_init_iso\n");
 }
#endif
  return(OM_S_SUCCESS);
 }


/*
   mark an ISO entry as ISO_disconnected.
   if the target of is loaded and the corresponding ISO's entry
   has also been marked then delete the entry from BOTH ISO's
   which by extension may result in the ISO and its ISOdir being
   deleted as well
*/
som_ISO_mark_entry(f_osn, i_oid, m_ndx, other_osn, s1, s2)

OMuword	    f_osn;	/* os number for this ISO */
OM_S_OBJID  i_oid;	/* this ISO objid */
OMuword	    m_ndx;	/* index of entry to be marked */
OMuword other_osn;      /* os number of other "side" */
OM_p_CONNECT_SIDE s1;  /* ptr to side1 - for tagcon_1side case */
OM_p_CONNECT_SIDE s2;  /* ptr to side2 - for tagcon_1side case */
 {
 struct OMISO_instance *myme, *tu;
 struct ISO_data *p_data, *p_data2;
 OM_S_RIP rip, t_rip;
 int vsz, sts;
 OMbyte RO_to_RW_disconnect=0;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_ISO_mark_entry osn=%d oid=%d ndx=%d\n",
		f_osn,i_oid,m_ndx);
 }
#endif

 if (other_osn != (OMuword)OM_K_OSNOTHERE) {
    if ((!(OM_GA_OSDs[f_osn]->flags & OM_e_loados_ro) &&
          (OM_GA_OSDs[other_osn]->flags & OM_e_loados_ro)) ||
       (!(OM_GA_OSDs[other_osn]->flags & OM_e_loados_ro) &&
         (OM_GA_OSDs[f_osn]->flags & OM_e_loados_ro))) {
      RO_to_RW_disconnect = 1;
    }
 }

 /*  ignore RO mode if dealing with a transient OS  */

 if (other_osn != (OMuword)OM_K_OSNOTHERE) {
    if ((RO_to_RW_disconnect) && ((OM_GA_OSDs[f_osn]->type == OM_OSD_trans) ||
                              (OM_GA_OSDs[other_osn]->type == OM_OSD_trans)))
      RO_to_RW_disconnect = 0;
 }

 /*  ignore RO mode if in OMTagCon.prep_write  */

 if ( OM_Gf_tagged_connects == OM_K_TAGEND ) RO_to_RW_disconnect = 0;

 sts = om$get_any_instance(osnum = f_osn, objid = i_oid, p_rip = &rip);
 if (! (1 & sts)) {
    BUGCHECK("som_ISO_mark_entry: no ISO instance");
    return(OM_F_BUGCHECK);
 }
 myme = &(((struct OMISO_total_instance *) rip.p_object)->OMISO);
 vsz = om$dimension_of(varray=myme->iso_d);
 if ( (int) m_ndx >= vsz ) {
    BUGCHECK("som_ISO_mark_entry: index too large for VLA");
    return(OM_F_BUGCHECK);
 }
 p_data = &P(myme->iso_d)[m_ndx];
 if ( ! p_data->w_flags ) {
    BUGCHECK("som_ISO_mark_entry: entry not in use");
    return(OM_F_BUGCHECK);
 }

 if ((RO_to_RW_disconnect) && !(OM_GA_OSDs[f_osn]->flags & OM_e_loados_ro)) {
    if (p_data->w_flags & ISO_logical_connect) {
       RO_to_RW_disconnect = 0;
       myme->w_dcount--;
    }
    else {
       return (OM_I_LOGICAL_DISCONNECT); 
    }
 }

 p_data2 = 0;

 if ( RO_to_RW_disconnect ) {
    if (!(myme->w_ISO_flags & ISO_no_target)) {
       sts = om$get_any_instance(osnum = myme->osnum, objid=myme->S_target_iso,
			   p_rip = &t_rip);
       if ( ! ( 1 & sts )) {
          BUGCHECK("som_ISO_mark_entry: no instance for target ISO");
          return(OM_F_BUGCHECK);
       }
       tu = &(((struct OMISO_total_instance *) t_rip.p_object)->OMISO);
       p_data2 = &P(tu->iso_d)[m_ndx];
       if (!(p_data2->w_flags & ISO_logical_connect)) {
          p_data->w_flags |= ISO_logical_disconnect;
          om$release_any_instance(osnum=f_osn, rip=rip);
          return (OM_I_LOGICAL_DISCONNECT);
       }
    }
    else {
       p_data->w_flags |= ISO_logical_disconnect;
       om$release_any_instance(osnum=f_osn, rip=rip);
       return (OM_I_LOGICAL_DISCONNECT);
    }
 }

 p_data->w_flags |= ISO_disconnected;
 myme->w_dcount++;

 /*------------------------------------------------------------------------
 **  Check for the special case of a one-side disconnect which is also
 **  an OMTagCon connect - if this is the case then proceed to disconnect 
 **  this side and set some flags in s2 for later processing in the
 **  som_perhaps_remove_tagcon_rec code
 **------------------------------------------------------------------------
 */

 if ((other_osn == (OMuword)OM_K_OSNOTHERE) &&
     (s1->p_chlink->channum.classid == OM_K_NOTUSING_CLASSID)) {
   OM_S_OBJID my_tmp_oid;

   /*  first we must get the internal OS name to which this ISO is directed */

   my_tmp_oid = i_oid;
   sts = om$send ( msg = message OMObjSpace.find_iso ((OMuword)OM_K_OSNOTHERE,
                                                      &my_tmp_oid),
                   senderid = i_oid,
                   targetid = 0,
                   targetos = f_osn );
   if (!(1&sts)) {
      BUGCHECK("som_ISO_mark_entry: find_iso fail");
      return (OM_F_BUGCHECK);
   }

   s2->chused = 7;   /*  set a flag for som_perhaps_remove_tagcon_rec  */

   /*  store address of int_osname buffer in s2->chandata  */
   s2->p_chandata = (int *)my_tmp_oid;   

   /*  Now we delete the ISO entry in this ISO only  */

   if (!(1 & som_ISO_delete_entry(f_osn, i_oid, 
                      (struct OMISO_total_instance *) rip.p_object, m_ndx))) {
	BUGCHECK("som_ISO_mark_entry: som_ISO_delete_entry TC1 fail");
	return(OM_F_BUGCHECK);
   }
   return (OM_S_SUCCESS);
 }

 if (! p_data2 ) {
    if ( myme->w_ISO_flags & ISO_no_target ) {
       om$release_any_instance(osnum = f_osn, rip = rip);
       return(OM_S_SUCCESS);  /* target os not loaded - can't continue */
    }
    sts = om$get_any_instance(osnum = myme->osnum, objid = myme->S_target_iso,
   			   p_rip = &t_rip);
    if ( ! ( 1 & sts )) {
       BUGCHECK("som_ISO_mark_entry: no instance for target ISO");
       return(OM_F_BUGCHECK);
    }
    tu = &(((struct OMISO_total_instance *) t_rip.p_object)->OMISO);
    p_data = &P(tu->iso_d)[m_ndx];
 }
 else {
    p_data = p_data2;
 }
	/* if both sides marked - delete both entries */
 if (  ( ISO_disconnected & p_data->w_flags)) {
    if (!(1 & som_ISO_delete_entry(myme->osnum,myme->S_target_iso,
       (struct OMISO_total_instance *) t_rip.p_object,m_ndx))) {
	BUGCHECK("som_ISO_mark_entry: som_ISO_delete_entry 1 fail");
	return(OM_F_BUGCHECK);
    }
    if (!(1 & som_ISO_delete_entry(f_osn, i_oid, 
       (struct OMISO_total_instance *) rip.p_object, m_ndx))) {
	BUGCHECK("som_ISO_mark_entry: som_ISO_delete_entry 1 fail");
	return(OM_F_BUGCHECK);
    }
 }
 om$release_any_instance(osnum = myme->osnum, rip = t_rip);
 om$release_any_instance(osnum = f_osn,     rip = rip);
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("xOM_ISO_mark_entry\n");
 }
#endif
 return (OM_S_SUCCESS);
} 


/* 
  Help by filling in OM_p_CONNECT_SIDE with some iso related stuff.
  Uses s1 as a base - needs s1->iso_objid and s1->iso_index.
  Will fill in s2->osnum, s2->objid, s2->channum, s2->iso_index, and
	s2->iso_index (same as s1->iso_index).
  returns OM_W_OSNOTACTIVE if other os not loaded.

  note: OM_p_CONNECT_SIDE is defined in OMrelation.h
*/
int som_ISO_fillside ( s1, s2)
 OM_p_CONNECT_SIDE s1;		/* points target */
 OM_p_CONNECT_SIDE s2;		/* will contain target data */
 {
   OM_S_RIP       iso_rip1, iso_rip2;
   struct  OMISO_instance  *myme, *p_iso2;
   struct  ISO_data *p_iso_data;
   int sts;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
   printf("~~som_ISO_fillside\n");
   som_connect_show_side("  s1 ",s1);
 }
#endif
	/*  get pointer to source ISO instance  */
   sts = om$get_any_instance (osnum = s1->osnum, objid = s1->iso_objid,
			      p_rip = &iso_rip1);
   if (!(1 & sts)) {
      BUGCHECK("som_ISO_fillside: no ISO instance for s1");
      return (OM_F_BUGCHECK);
   }
   myme = &(((struct OMISO_total_instance *) iso_rip1.p_object)->OMISO);
	/*  verify that destination OS is active  */
   if ( myme->w_ISO_flags & ISO_no_target )  {
      om$release_any_instance(osnum = s1->osnum, rip = iso_rip1);
      s2->osnum = (OMuword)OM_K_OSNOTHERE;
      return (OM_W_OSNOTACTIVE);
   }

   p_iso_data = &(P(myme->iso_d)[s1->iso_index]);
   if ( ! IF_EQ_OBJID(s1->objid, p_iso_data->iso_u.s_objid) ) {
/* !!!!!!!!!!!! remove after debug !!!!!!!!!!!!!!!! */
      printf("som_ISO_fillside: iso %d[%d] does not point to me\n",
		s1->iso_objid, s1->iso_index);
      som_show_object(s1->osnum, s1->objid);
      som_ISO_print(s1->osnum, s1->iso_objid);
      exit(1);

      BUGCHECK("som_ISO_fillside: iso does not point to me");
      om$release_any_instance(osnum = s1->osnum, rip = iso_rip1);
      return (OM_E_BADSTATE);
   }
     
   s2->osnum = myme->osnum;
   s2->iso_objid = myme->S_target_iso;

	/*  get pointer to destination ISO instance  */
   sts = om$get_any_instance(osnum = s2->osnum, objid = s2->iso_objid,
				p_rip = &iso_rip2);
   if (!(1 & sts))   {
      BUGCHECK("som_ISO_fillside: no ISO instance s2");
      om$release_any_instance(osnum = s1->osnum, rip = iso_rip1);
      return (OM_F_BUGCHECK);   
   }
   p_iso2 = &(((struct OMISO_total_instance *) iso_rip2.p_object)->OMISO);
   p_iso_data = &(P(p_iso2->iso_d)[s1->iso_index]);

   if ( p_iso_data->w_flags & ISO_disconnected )
   {
#ifdef DEBUG
      printf("som_ISO_fillside: one side disconnected\n");
      exit(1);
#endif
      BUGCHECK("som_ISO_fillside: one side disconnected");
      om$release_any_instance(osnum = s1->osnum, rip = iso_rip1 );
      om$release_any_instance(osnum = s2->osnum, rip = iso_rip2 );
      return (OM_E_BADSTATE);
   }
   s2->objid = p_iso_data->iso_u.s_objid;
   s2->channum = p_iso_data->chan;
   s2->iso_index = s1->iso_index;

   om$release_any_instance(osnum = s1->osnum, rip = iso_rip1 );
   om$release_any_instance(osnum = s2->osnum, rip = iso_rip2 );
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
   printf("~xsom_ISO_fillside\n");
   som_connect_show_side("  s2 ",s2);
 }
#endif
   return (OM_S_SUCCESS);
}


/*
  Call OM_VLA_set_dimension to change size of specified var len array.
  Subroutine since p_cld is not used by ISO code and is looked up here.
*/
int som_ISO_set_dimension(os, objid, p_vd, sz)
 OMuword os;		/* Object Space number */
 OM_S_OBJID objid;      /* ISO's object id. */
 OM_p_VARLENARR_DESCR p_vd; /* points to array desc to be modified */
 OMuint sz;		/* new size of array */
 {
  OM_p_CLASSDEF p_cld;
  int	sts;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
  printf("som_ISO_set_dimension: os=%d objid=%d v_d=%#x sz=%d\n",
		os,objid,p_vd,sz);
  printf("som_ISO_set_dim: w_count=%d w_offset=%d\n", 
		p_vd->w_count, p_vd->w_offset);
 }
#endif
  sts = om$get_class(osnum = os, objid = objid, pp_cld = &p_cld);
  if ( ! (1 & sts) ) {
    BUGCHECK("som_ISO_set_dimension: get_class fail");
    return(sts);
  }
  sts = om$vla_set_dimension (p_vladescr=p_vd, 
                              size=sz, 
			      osnum=os,
			      objid=objid,
                              p_cld=p_cld);
  if ( ! (1 & sts) ) {
#ifdef DEBUG
    printf("som_ISO_set_dimension: VLA_set_dim fail\n");
    om$report_error(sts = sts);
    exit(1);
#endif
    BUGCHECK("som_ISO_set_dimension: set_dimension fail");
    return(sts);
  }
  return(OM_S_SUCCESS);
 }


/*
  Print ISO contents
*/
som_ISO_print (osn, i_oid)
 OMuword	     osn;	/* os number */
 OM_S_OBJID  i_oid;		/* objid of ISO */
 {
  struct ISO_data *p_data;
  OM_S_RIP  rip;
  int sts, vsz;
  struct OMISO_instance *myme;
  OMuword tos, tflg, i;
  OM_S_OBJID toid;
  OM_S_CHANNUM tch;

  sts = om$get_any_instance(osnum = osn, objid = i_oid, p_rip = &rip);
  if (! (1&sts)) {
     BUGCHECK("OM_ISO_print: no ISO instance");
     return(OM_F_BUGCHECK);
  }
  myme = &(((struct OMISO_total_instance *) rip.p_object)->OMISO);
  vsz = om$dimension_of(varray=myme->iso_d);
  PMSPRNT(
("\n    toid=%d,%d iso_oid=%d addr=0x%x flg=0x%x dang_cnt=%d VLA_sz=%d 1st=%d\n",
	myme->osnum,myme->S_target_iso,
	i_oid,myme,myme->w_ISO_flags,myme->w_dcount,
	vsz,myme->i_first));
  /* if no room for new entry - extend VLA and init */
  p_data = P(myme->iso_d);
  for (i=0; i<(OMuword)vsz; i++ ) {
     if (p_data->w_flags) {
	PMSPRNT(("    ISO entry=%d flgs=0x%x this side %d,%d(%d.%d) target ",
		  i, p_data->w_flags, osn, p_data->iso_u.s_objid,
		  p_data->chan.classid, p_data->chan.number));
        if (myme->w_ISO_flags & ISO_no_target) {
	   PMSPRNT((" NOT LOADED\n"));
	}
	else {
	   sts = som_ISO_fetch( osn, i, i_oid, &tos, &toid, &tch, &tflg);
           if ( sts == OM_I_LOGICAL_DISCONNECT ) {
              PMSPRNT((" LOGICALLY DISCONNECTED\n"));
           }
           else {
              PMSPRNT((" %d,%d(%d.%d)\n",tos,toid,tch.classid,tch.number));
           }
	}
     }
     p_data++;
  }
  om$release_any_instance(osnum = osn, rip = rip);
  return (1);
 }



/*=======================================================================
      function:  som_ISO_fetch

      description:  This function is used to traverse across the ISO
                      zone between two object spaces and fetch information
                      about the object on the other side.

      input args:   OMuword	 OSnum1     Source Object Space number
                    OMuword      index      ISO index
                    OM_S_OBJID   iso_objid  Source ISO object id

      output args:  OMuword      *OSnum2    Destination Object Space number
                    OM_S_OBJID   *objid     Destination object id
                    OM_S_CHANNUM *chan      Destination object's channel number
                    OMuword      *flags     Destination object's flag word

      change history:
=======================================================================*/


int som_ISO_fetch ( OMuword OSnum1, OMuword index, OM_S_OBJID iso_objid,
                    OMuword *OSnum2, OM_S_OBJID *objid, OM_p_CHANNUM chan,
                    OMuword *flags )
{
   OM_S_RIP       iso_rip1, iso_rip2;
   struct  OMISO_instance  *myme, *p_iso2;
   struct  ISO_data *p_iso_data;
   int sts;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
   printf("~~som_ISO_fetch: OSnum1=%d index=%d iso_oid=%d\n",OSnum1,index,
		iso_objid);
 }
#endif
	/*  get pointer to source ISO instance  */
   sts = om$get_any_instance(osnum = OSnum1, objid=iso_objid, p_rip=&iso_rip1);
   if (!(1 & sts)) {
      return (sts);
   }
   myme = &(((struct OMISO_total_instance *) iso_rip1.p_object)->OMISO);
   *OSnum2 = myme->osnum;
	/*  verify that destination OS is active  */
   if ( myme->w_ISO_flags & ISO_no_target )  {
      om$release_any_instance (osnum = OSnum1, rip = iso_rip1);
      return (OM_W_OSNOTACTIVE);
   }
  
   /* check for logical disconnection */

   p_iso_data = &(P(myme->iso_d)[index]);
   if ( p_iso_data->w_flags & ISO_logical_disconnect ) {
      om$release_any_instance (osnum=OSnum1, rip=iso_rip1);
      return (OM_I_LOGICAL_DISCONNECT);
   }

	/*  get pointer to destination ISO instance  */
   sts = om$get_any_instance(osnum = *OSnum2, objid = myme->S_target_iso,
				p_rip = &iso_rip2 );
   if (!(1 & sts))
   {
      BUGCHECK("som_ISO_fetch: target ISO no instance");
      om$release_any_instance(osnum = OSnum1, rip = iso_rip1 );
      return (OM_F_BUGCHECK);
   }
   p_iso2 = &(((struct OMISO_total_instance *) iso_rip2.p_object)->OMISO);
   p_iso_data = &(P(p_iso2->iso_d)[index]);

   /* check for logical disconnection */

   if ( p_iso_data->w_flags & ISO_logical_disconnect ) {
      om$release_any_instance (osnum=OSnum1, rip=iso_rip1);
      om$release_any_instance (osnum=OSnum2, rip=iso_rip2);
      return (OM_I_LOGICAL_DISCONNECT);
   }

   if ( p_iso_data->w_flags & ISO_disconnected )
   {
      BUGCHECK("som_ISO_fetch: one side disconnected");
      om$release_any_instance(osnum = OSnum1, rip = iso_rip1);
      om$release_any_instance(osnum = OSnum2, rip = iso_rip2);
      return (OM_E_BADSTATE);
   }
   *objid = p_iso_data->iso_u.s_objid;
   *chan = p_iso_data->chan;
   chan->classid = OM_GA_OSDs[*OSnum2]->FilToAct[chan->classid];
   *flags = 0;

   om$release_any_instance(osnum = OSnum1, rip = iso_rip1);
   om$release_any_instance(osnum = OSnum2, rip = iso_rip2);
#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
   printf("~xsom_ISO_fetch: OSnum2=%d oid=%d chan=(%d,%d) flags=%#x\n",
	   *OSnum2, *objid, chan->classid, chan->number, *flags);
 }
#endif 
   return (OM_S_SUCCESS);
}


/*=======================================================================
      function:  OM_ISO_update_objid

      description:  This function is used to store a new objid in an
                      existing ISO data entry.

      input args:   OMuword      OSnum      Object Space number
                    OMuword      index      ISO index
                    OM_S_OBJID   iso_objid  ISO object id
                    OM_S_OBJID   new_objid  New objid to store

      output args:  none

      change history:
=======================================================================*/


int som_ISO_update_objid ( OSnum, index, iso_objid, new_objid )

OMuword      OSnum, index;
OM_S_OBJID   iso_objid, new_objid;
{
   OM_S_RIP                iso_rip;
   struct  OMISO_instance  *p_iso;
   int sts;

#ifdef DEBUG
 if (OM_Gi_OMISO_debug) {
   printf("som_ISO_update_objid osn=%d, ndx=%d, i_oid=%d new_oid=%d\n",
	   OSnum,index,iso_objid,new_objid);
 }
#endif
   sts = om$get_any_instance(osnum = OSnum, objid = iso_objid, p_rip=&iso_rip);
   if (!(1 & sts)) {
      return (sts);
   }
   p_iso = &(((struct OMISO_total_instance *) iso_rip.p_object)->OMISO);
	/* update the objid in the ISO data array  */
   P(p_iso->iso_d)[index].iso_u.s_objid = new_objid;
   om$release_any_instance(osnum = OSnum, rip = iso_rip);
   return (OM_S_SUCCESS);
}


/*=======================================================================
      function:  som_ISO_check_logical_disconnect

      description:  This function is used to check for logical disconnection
                      between an object in a RO object space and an object
                      in a RW object space.  If the logical disconnection
                      exists then this function will clear the flags stating
                      such.

      input args:   OM_p_CONNECT_SIDE       s1
                    OM_p_CONNECT_SIDE       s2

      output args:  none

      change history:
=======================================================================*/


int som_ISO_check_logical_disconnect ( s1, s2 )

OM_p_CONNECT_SIDE s1, s2;
{
   int                   sts;
   OM_S_RIP              rip;
   struct OMISO_instance *myme;
   struct ISO_data       *p_data;
   OM_S_CONNECT_SIDE     *ts;

   if ((!(OM_GA_OSDs[s1->osnum]->flags & OM_e_loados_ro) &&
         (OM_GA_OSDs[s2->osnum]->flags & OM_e_loados_ro)) ||
       (!(OM_GA_OSDs[s2->osnum]->flags & OM_e_loados_ro) &&
         (OM_GA_OSDs[s1->osnum]->flags & OM_e_loados_ro))) 
   {
      if ( OM_GA_OSDs[s1->osnum]->flags & OM_e_loados_ro )
         ts = s1;
      else
         ts = s2;

      sts = om$get_any_instance ( osnum=ts->osnum, objid=ts->iso_objid,
                                  p_rip=&rip );
      if (!(1&sts))
      {
         BUGCHECK("som_ISO_check_logical_disconnect:get_any_instance fail");
         return(OM_E_BADSTATE);
      }

      myme = &(((struct OMISO_total_instance *)rip.p_object)->OMISO);
      p_data = &(P(myme->iso_d)[ts->iso_index]);

      if ( p_data->w_flags & ISO_logical_disconnect )
      {
         p_data->w_flags &= ~(ISO_logical_disconnect);
         sts = OM_S_SUCCESS;
      }
      else
      {
         sts = OM_I_OBJONCHAN;
      }
      om$release_any_instance (osnum=ts->osnum, rip=rip);
   }
   else
   {
      sts = OM_I_OBJONCHAN;
   }
   return (sts);
} 
end	implementation	OMISO;
