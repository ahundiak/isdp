#include  <string.h>
#include  "OMminimum.h"
#include  "OMspecify.h"
#include  "OMrelation.h"
#include  "OMintprims.h"
#include  "OMerrordef.h"
#include  "OMmacros.h"
#include  "OMtags.h"
#include  "OMmetaclass.h"
#include  "OMlimits.h"

int ARone_side_connect ( os, oid, chsel, iso_oid, iso_ndx, chan_ndx )

OMuword               os;
OM_S_OBJID            oid;
OM_p_CHANSELECT       chsel;
OM_S_OBJID            iso_oid;
OMuword               iso_ndx;
int                   chan_ndx;

{
   int                sts;
   OM_S_CONNECT_SIDE  ss1, ss2;
   OM_p_CONNECT_SIDE  s1=&ss1, s2=&ss2;
   OM_p_CHANNEL_LINK  link;
   OM_S_CHANNEL_HDR   chan2;
   OM_p_CHANNEL_HDR   p_chan2=&chan2;

   sts = om$connect_build_side ( osnum  = os,
                                 objid  = oid,
                                 chsel  = chsel,
                                 relidx = chan_ndx,
                                 side   = s1 );
   if (!(1&sts)) return (sts);

   s1->iso_objid = NULL_OBJID;

   s2->pp_chan = &p_chan2;
   chan2.flags = OM_CH_m_m;

   sts = om$connect_get_chent ( side1 = s1,
                                side2 = s2 );
   if (!(1&sts)) return (sts);

   /*=====================================================*/
   /* Restricted channels are not a problem because these */
   /* are all ISO connections                             */
   /*=====================================================*/
   
   link = s1->p_chlink;
   link->objid           = iso_oid;
   link->hdr.u1.isoindex = iso_ndx;
   link->hdr.flags       = 0;
   link->channum.classid = 0;                       /* TagCon ndx here */
   link->channum.number  = 0;

   if ( (*s1->pp_chan)->flags & OM_CH_singleton )
      (*s1->pp_chan)->flags |= OM_CH_full;

   s1->chused = TRUE;

   om$connect_release_side ( side1 = s1 );

   return (OM_S_SUCCESS);
}


/*--------------------------------------------------------------------
**
**  This function will return the target channel name for a given
**   restricted channel number. NOTE: This assumes that the channum
**   which is given was derived via om$get_channel_number or by some
**   other means by which the classid portion is an active classid.
**   
**--------------------------------------------------------------------*/

int ARget_restricted_target ( channum, channame )

OM_S_CHANNUM  channum;
char          *channame;

{
   OM_p_CLASSDEF           p_acld;
   OM_p_CHANNEL_TYPE_DEFN  p_type;

   if ((channum.classid > OM_Gw_numclasses) ||
       (!(p_acld = OM_GA_active_classes[channum.classid])) ||
       (!(p_acld->w_numchannels)))
   {
      return (OM_E_NOSUCHCLASS);
   }

   p_type = p_acld->ChanDefns[channum.number].p_type;
   if (!(p_type->w_flags & CD_restricted)) return (OM_E_INVARG);

   strcpy ( channame, (char *) p_type->classids );

   return (OM_S_SUCCESS);
}


/*---------------------------------------------------------------------
**
**    This function given a channel number,  will look at the channel
**     definition and if the channel is relatively ordered it will
**     change the definition to be absolutely ordered and return TRUE.
**     When the function returns TRUE the pointer to the channel
**     definition will also be returned in order to speed things up
**     for ARchange_to_rel.
**
**     If the channel was not relatively ordered then the function
**     will return FALSE.
**
**---------------------------------------------------------------------
*/

int ARchange_chan_to_abs ( channum, pp_chdef )

OM_S_CHANNUM        channum;
OM_p_CHANNEL_DEFN  *pp_chdef;

{
   OMbyte             tndx;
   OM_p_CLASSDEF      p_cld;
   OM_p_MSGMAP        p_msg;
   OM_p_CHANNEL_DEFN  p_chdef;

   p_cld = OM_GA_active_classes[channum.classid];
   tndx  = p_cld->p_transmap[channum.classid - p_cld->w_baseclass];
   p_msg = p_cld->MsgMap + tndx;
   p_chdef = p_msg->ChanDefns + channum.number;
   if ( p_chdef->p_type->w_flags & CD_relordered )
   {
      p_chdef->p_type->w_flags &= ~CD_relordered;
      p_chdef->p_type->w_flags | = CD_absordered;
      *pp_chdef = p_chdef;
      return (TRUE);
   }
   return (FALSE);
}


/*---------------------------------------------------------------------
**
**    This function given a pointer to a channel definition will
**     set the flags to change it back to a relatively ordered
**     channel.  NOTE: this function assumes that the channel
**     definition had previously been altered by ARchange_to_abs.
**
**---------------------------------------------------------------------
*/

int ARchange_chan_to_rel ( p_chdef )

OM_p_CHANNEL_DEFN  p_chdef;

{
   p_chdef->p_type->w_flags &= ~CD_absordered;
   p_chdef->p_type->w_flags |=  CD_relordered;
   return (TRUE);
}

/******************************************************************************/
/*
**	The following function(s) are used to traverse the spacemap of
**	a given object space; returning all the valid object ids in that
**	object space.  It is assumed that no new objects are being created
**	while stepping through the spacemap.
**
**	ARpass_start should be called first.  Then ARpass_next should be
**	called until the returned objid is NULL_OBJID (or until it returns
**	an error).  After calling ARpass_start, use ARpass_end to stop
**	the pass before initializing another pass.  ARpass_end is
**	automatically called by ARpass_next when the end of the valid objid
**	list is reached.
**
**	All the functions return TRUE on success and FALSE on error.
*/

static int	ARin_pass = FALSE;
static OMuword	ARpass_osnum = 0;
static int	ARpass_next_oid = 0;

int	ARpass_start(osnum)
OMuword	osnum;
{
	int	ret = FALSE;

	if (!ARin_pass)
	{
		if (osnum < OM_Gw_maxOS && OM_GA_OSDs[osnum])
		{
			ARin_pass = TRUE;
			ARpass_osnum = osnum;
			ARpass_next_oid = 0;
			ret = TRUE;
		}
	}
	return ret;
}

int	ARpass_end(osnum)
OMuword	osnum;
{
	if (!ARin_pass || ARpass_osnum != osnum)
		return FALSE;
	else
	{
		ARin_pass = FALSE;
		ARpass_osnum = 0;
		ARpass_next_oid = 0;
		return TRUE;
	}
}

#define SPECIAL_OM_CLASS(P_SM)					\
	(!((P_SM)->flags & OM_SM_unknown_obj)			\
			&&					\
	((P_SM)->p_acld->w_classid == OM_K_OMGROUP_ACTCLASSID	\
			||					\
	(P_SM)->p_acld->w_classid == OM_K_OMCLUSTER_ACTCLASSID	\
			||					\
	(P_SM)->p_acld->w_classid == OM_K_OMFILEDOS_ACTCLASSID))

int	ARpass_next(osnum, p_objid)
OMuword		osnum;
OM_S_OBJID	*p_objid;
{
	int	ret = FALSE;

	if (ARin_pass && ARpass_osnum == osnum)
	{
		OM_p_OSD	p_OSD = 0;

		if (osnum < OM_Gw_maxOS && (p_OSD = OM_GA_OSDs[osnum]))
		{
			if ((OMuint) ARpass_next_oid >= p_OSD->CurSpaceMapSize)
			{
				*p_objid = NULL_OBJID;
				ret = ARpass_end(osnum);
			}
			else
			{
				OM_p_SPAMAPENT	p_spacemap;

				p_spacemap = &p_OSD->Spacemap[ARpass_next_oid];

				if (p_spacemap->flags & OM_SM_in_use
						&&
					!SPECIAL_OM_CLASS(p_spacemap))
				{	
					*p_objid = ARpass_next_oid;
					++ARpass_next_oid;
					ret = TRUE;
				}
				else
				{
					/*
					**	Find next greatest oid.
					*/
					++ARpass_next_oid;
					ret = ARpass_next(osnum, p_objid);
				}
			}
		}
	}

	return ret;
}


/*========================================================================

The following function will return the classname of the object when
given an (osnum,objid) pair as input.  This will handle the case of
an unknown class as well as known classes.

=========================================================================*/

int ARget_classname ( osnum, objid, classname )

OMuword     osnum;        /* Input */
OM_S_OBJID  objid;        /* Input */
char       *classname;    /* Output - must have allocated space as the
                                      classname will be strcpy'ed to
                                      this address - dimension to
                                      OM_K_MAXCLASS_LEN  */
{
   OMuint          i;
   OMuword         fil_classid;
   OM_p_SPAMAPENT  p_sm;
   OM_p_OSD        p_osd;

   struct my_osco {
     char       hdr[8];
     OM_S_OSCO  osco;
   } *p_osco;


   if ((osnum > OM_Gw_maxOS) || (!(p_osd = OM_GA_OSDs[osnum]))) 
      return (OM_E_NOSUCHOS);

   if (objid > p_osd->CurSpaceMapSize) return (OM_E_NOSUCHOBJ);

   p_sm = &p_osd->Spacemap[objid];
   if (p_sm->flags & OM_SM_in_use) {
      if (p_sm->flags & OM_SM_unknown_obj) {
         fil_classid = (OMuword)p_sm->p_acld;
         p_sm = &p_osd->Spacemap[1];
         for (i=1; i<p_osd->CurSpaceMapSize; ++p_sm, ++i) {
            if ((p_sm->flags & OM_SM_in_use) && (p_sm->flags & OM_SM_in_mem) &&
                (!(p_sm->flags & OM_SM_unknown_obj)) &&
                (p_sm->p_acld->w_classid == OM_K_OMOSCO_ACTCLASSID)) {
               p_osco = (struct my_osco *)p_sm->state.object;
               if (p_osco->osco.w_classid == fil_classid) {
                  strcpy (classname, p_osco->osco.s_name);
                  return (OM_S_SUCCESS);
               }
            }
         }
      }
      else {
         return (om$get_classname( osnum = osnum,
                                   objid = objid,
                                   classname = classname ));
      }
   }
   else
      return (OM_E_NOSUCHOBJ);

   return (OM_E_ERROR);  /*  This is a stopper in case the OSCO was 
                             not located  - it should never happen  */
}


/*-----------------------------------------------------------------------
**  This function will return the tag of an object which is involved
**  via a tagged connection (TagCon) with the given (oid,channum)
**
**  This function will only find the first match and return - there
**  is no provision for a case where the (oid,channum) are involved
**  in multiple connections with tagged objects in other object spaces.
**
**  There will be no validation of the (oid,channum) passed in - the
**  only use of these values will be to match the contents of the TagCon
**  vla records.  The oid must be in the current_OS.
**
**------------------------------------------------------------------------
*/

int ARget_tagcon_tag ( oid, channum, p_tag )

OM_S_OBJID    oid;
OM_S_CHANNUM  channum;
OMuint       *p_tag;
{
   OMuword              ndx;
   OM_p_TAGCON_LINK     p_tc_link;

   struct sd_my_tagcon {
     char root[8];
     OMuword first_tag;
     OMuword first_free;
     char osname[OM_K_MAXINTOSNAME_LEN];
     OMuint count;
     OMuint chan;
     OMuint vla_ptr;
     OMuint vla_cnt;
   } *p_my_tagcon;

   struct sd_tagcon_rec {
      OM_S_OBJID     objid;
      OMuint         tag;
      OM_S_CHANNUM   cnum;
      OM_S_CHANNUM   other_cnum;
      OMuword        index;
      OMuword        other_index;
      OMuword        version;
      OMuword        flags;
      OMuword        next;
      OMuword        prev;
   } *p_vla;

   if (!OM_GA_p_tagcon) return (OM_E_NOTTAGGED);

   /*===============================================*/
   /*  convert given channum to have filed classid  */
   /*===============================================*/

   channum.classid = OM_GA_active_to_filed[channum.classid];

   /*=============================================================*/
   /*  for each OMTagCon object in the list - search its vla for  */
   /*  a match on the (oid,channum)                               */
   /*=============================================================*/

   p_tc_link = OM_GA_p_tagcon[OM_Gw_current_OS];

   while ( p_tc_link ) {

      /*===============================================================*/
      /*  get a pointer to the TagCon vla  - we'll have to cheat here  */
      /*===============================================================*/

      p_my_tagcon = (struct sd_my_tagcon *)
                    OM_Gp_CurSpaceMap[p_tc_link->objid].state.object;

      p_vla = (struct sd_tagcon_rec *)p_my_tagcon->vla_ptr;
      ndx = p_my_tagcon->first_tag;

      /*======================================================*/
      /*  loop thru the vla checking for (oid,channum) match  */
      /*======================================================*/

      while ( ndx != OM_K_TAGEND ) {
         if ((p_vla[ndx].objid == oid) &&
             (p_vla[ndx].cnum.classid == channum.classid) &&
             (p_vla[ndx].cnum.number == channum.number)) {
            *p_tag = p_vla[ndx].tag;
            return (OM_S_SUCCESS);
         }         
         ndx = p_vla[ndx].next;
      }
      p_tc_link = p_tc_link->next;
   }

   return (OM_E_NOTTAGGED);
}

int ARset_all_tag_bits(osnum, tagoid)
/*
**	Given an object space number and the object id of an OMTag object,
**	set the tag bit for every object in the tag vla.
*/
OMuword		osnum;	/* OS containing the OMTag object and objects to set. */
OM_S_OBJID	tagoid;	/* Object id of the OMTag object. */
{
	OM_S_MESSAGE		get_record_vla_msg;
	OM_S_GETRECVLA_ARGS	get_record_vla_args;
	extern OMuword		OMTag_OPP_get_record_vla_method_index;
	int			sts;
	OM_p_TAG_RECORD		p_tag_rec;
	OMuint			count, i;
	OMuword			flags;
	
	get_record_vla_msg.select.DefClassid = OM_K_OMTAG_ACTCLASSID;
	get_record_vla_msg.select.ReqClassid = OM_K_OMTAG_ACTCLASSID;
	get_record_vla_msg.select.FuncIndex  = OMTag_OPP_get_record_vla_method_index;
	get_record_vla_msg.size = sizeof(get_record_vla_args);
	get_record_vla_msg.p_arglist = (char *)&get_record_vla_args;

	get_record_vla_args.pp_tag_rec = &p_tag_rec;
	get_record_vla_args.p_count = &count;
	get_record_vla_args.p_flags = &flags;

	sts = om$send(msg = &get_record_vla_msg,
		targetid = tagoid,
		targetos = osnum,
		senderid = NULL_OBJID);
	if (!(1&sts))
		return sts;

	for (i = 0; i < count; ++i)
	{
		OM_S_OBJID	objid;

		objid = p_tag_rec[i].objid;
		if (!IF_NULL_OBJID(objid))
		{
			OM_S_RIP	rip;

			sts = om$get_any_instance(p_rip = &rip, 
				objid = objid,
				osnum = osnum);
			if (!(1&sts))
				return sts;
			rip.p_object->i_size |= OM_OHf_is_tagged;
		}
	}

	return OM_S_SUCCESS;
}
