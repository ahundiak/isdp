/* $Id: OMTagConi.I,v 1.4 2001/03/22 22:49:38 anand Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:        vdtag/OMTagConi.I
 *
 * Description:
 *      This file was originally was in EXNUC/src/om directory. 
 *
 *	The debug method has to be modified to retrieve the instance data
 *	of the OMTagCon objects. Also added a function to expose the instance
 *	data to outside world. 
 *
 *	The file is modified mainly to read the instance data to verify them
 *	whether the objects stored in the OMTagCon is valid or not. When the
 *	the data is invalid, the ppl written deletes the OMTagCon objects.
 *	
 *	As such these objects and it contents should get cleaned automatically
 *	when we detach/remove the relation with the Reference files. But in
 *	some cases, these cleaning operation doesn't happen, hence the need
 *	for the ppl ( $VDS/vdppl/COz_DelTag.u ).
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: OMTagConi.I,v $
 *      Revision 1.4  2001/03/22 22:49:38  anand
 *      Removed static keyword from global variable definition.
 *
 *      Revision 1.3  2001/02/14 21:34:02  ramarao
 *      Removed v_dbgmacros.h file, since it none of its macros are used.
 *
 *      Revision 1.2  2001/01/11 19:52:31  art
 *      sp merge
 *
# Revision 1.2  2000/12/04  14:54:36  pinnacle
# Replaced: vds/vdtag/OMTagConi.I for:  by impd252 for Service Pack
#
# Revision 1.1  2000/11/22  23:58:46  pinnacle
# Created: vds/vdtag/OMTagConi.I by apazhani for Service Pack
#
 *
 * History:
 *      11/22/2000        Alwin 	 Creation
 *      01/11/2001        ah             sp merge
 *************************************************************************/

class implementation OMTagCon;

#if defined (NT)
#include  <stdio.h>
#endif

#include  <string.h>
#include  "OMspecify.h"
#include  "OMrelation.h"
#include  "OMintprims.h"
#include  "OMmetaclass.h"
#include  "OMerrordef.h"
#include  "OMmacros.h"

from OMOSCO import initialize;
from OMTag  import get_record_vla;

extern OMuint OM_Gi_tagcon_slot;

%safe
static int OMTagCon_change_mode = 0;
%endsafe

/* following static variables allow to us access the instance data of the
OMTagCon object in a PPL. The pointers of the instance data are exposed 
through the function call EXGetTagConRecordInstance(). Alwin
*/
static struct OM_sd_connect_record *pConnectionRecord;
static int nInstanceConnectionRecord;
static int nInstanceFirstTag;
static int nInstanceFirstFree;

%safe
/* 
 * this will be set to "0", when cleaning the OMTagCon Objects using the ppl
 * COz_DelTag.u
 */
int nDEBUG_ON = 1; 
%endsafe

method initialize ( OMuword other_os )
{
   int                   sts;
   OM_p_TAGCON_LINK      p_tc_link;
   OM_S_CHANSELECT       csel, my_csel;

   /*===========================================================*/
   /*  check if global array of pointers to tagcon lists exist  */
   /*===========================================================*/

   if (! OM_GA_p_tagcon )
   {
      OM_GA_p_tagcon = (OM_p_TAGCON_LINK *) om$calloc 
                     ( size = OM_Gw_maxOS * sizeof(OM_p_TAGCON_LINK) );
      if (! OM_GA_p_tagcon ) return (OM_E_NODYNMEM);
   }

   /*===========================================*/
   /*  allocate and link in a global structure  */
   /*  to represent this TagCon object          */
   /*===========================================*/

   p_tc_link = om$malloc(structure=OM_S_TAGCON_LINK);
   if (!p_tc_link) return (OM_E_NODYNMEM);

   p_tc_link->objid = my_id;
   strncpy ( p_tc_link->int_osname, OM_GA_OSDs[other_os]->InternalName, 
             OM_K_MAXINTOSNAME_LEN );
   
   if ( OM_GA_p_tagcon[OM_Gw_current_OS] )
   {
      p_tc_link->next = OM_GA_p_tagcon[OM_Gw_current_OS];
      OM_GA_p_tagcon[OM_Gw_current_OS] = p_tc_link;
   }
   else
   {
      OM_GA_p_tagcon[OM_Gw_current_OS] = p_tc_link;
      p_tc_link->next = 0;
   }

   /*==================================*/
   /*  initialize the TagCon instance  */
   /*==================================*/

   ME.OMTagCon->first_tag  = OM_K_TAGEND;
   ME.OMTagCon->first_free = OM_K_TAGEND;
   ME.OMTagCon->count      = 0;
   strncpy ( ME.OMTagCon->osname, p_tc_link->int_osname,
             OM_K_MAXINTOSNAME_LEN );

   /*====================================================================*/
   /*  connect the new instance to the OSO via the "to_GrpDscs" channel  */
   /*====================================================================*/

   csel.type = OM_e_name;
   csel.u_sel.name = "OMObjSpace.to_GrpDscs";

   my_csel.type = OM_e_addr;
   my_csel.u_sel.addr = &ME.OMTagCon->to_OSO;

   sts = om$send ( msg = message Root.connect ( csel, 0, my_id, 
                            OM_Gw_current_OS, my_csel, 0),
                   targetid = OM_GO_current_OS_objid );
   if (!(1&sts)) return (sts);

   return (OM_S_SUCCESS);
}


method delete ( int defer )
{
   OM_p_TAGCON_LINK   p_link1, p_link2;

   p_link1 = OM_GA_p_tagcon[OM_Gw_current_OS];

   /*================================================================*/
   /*  locate the tagcon link that represents the oid being deleted  */
   /*================================================================*/

   p_link2 = 0;
   while ( p_link1->objid != my_id )
   {
      p_link2 = p_link1;
      p_link1 = p_link1->next;
   }

   if ( p_link2 )
      p_link2->next = p_link1->next;
   else
      OM_GA_p_tagcon[OM_Gw_current_OS] = p_link1->next;

   om$dealloc ( ptr = (char *) p_link1 );

   om$send ( mode = OM_e_wrt_message,
             msg = message Root.delete(0),
             targetid = my_id );

   return (OM_S_SUCCESS);
}


method set_up ()
{
   int              sts;
   OMuint           count;
   OMuword          flags;
   OMuword          osnum;
   OMuword          ndx, i;
   OM_S_OBJID       tag_oid;
   OM_p_TAGCON_LINK p_tc_link;
   OM_p_TAG_RECORD  p_tag_rec;
   struct OM_sd_connect_record *p_con_rec;
   
   /*===========================================================*/
   /*  check if global array of pointers to tagcon lists exist  */
   /*===========================================================*/

#ifdef vdsDEBUG
	printf("\n method set_up >> \n" );
#endif
   if (! OM_GA_p_tagcon )
   {
      OM_GA_p_tagcon = (OM_p_TAGCON_LINK *) om$calloc 
                     ( size = OM_Gw_maxOS * sizeof(OM_p_TAGCON_LINK) );
      if (! OM_GA_p_tagcon ) return (OM_E_NODYNMEM);
   }

   /*===========================================*/
   /*  allocate and link in a global structure  */
   /*  to represent this TagCon object          */
   /*===========================================*/

   p_tc_link = om$malloc(structure=OM_S_TAGCON_LINK);
   if (!p_tc_link) return (OM_E_NODYNMEM);

   p_tc_link->objid = my_id;
   strncpy ( p_tc_link->int_osname, ME.OMTagCon->osname, 
             OM_K_MAXINTOSNAME_LEN );

   if ( OM_GA_p_tagcon[OM_Gw_current_OS] )
   {
      p_tc_link->next = OM_GA_p_tagcon[OM_Gw_current_OS];
      OM_GA_p_tagcon[OM_Gw_current_OS] = p_tc_link;
   }
   else
   {
      OM_GA_p_tagcon[OM_Gw_current_OS] = p_tc_link;
      p_tc_link->next = 0;
   }

   /*===================================================*/
   /*  remove all connect records marked as unresolved  */
   /*===================================================*/

   p_con_rec = &ME.OMTagCon->con_rec[0];
   ndx = ME.OMTagCon->first_tag;
   while ( ndx != OM_K_TAGEND )
   {
      if ( p_con_rec[ndx].flags & OM_TCf_unresolved_connection )
      {
#ifdef vdsDEBUG
	printf("\n\t  Remove all connect records - unresolved \n" );
	printf("\n\t  Internal OS name :: %s \n", ME.OMTagCon->osname );
#endif
         i = ndx;
         ndx = p_con_rec[ndx].next;
         sts = om$send ( msg = message OMTagCon.remove ( i ),
                         targetid = my_id );
         if (!(1&sts))
         {
            printf ("OMTagCon.set_up: error from remove msg to ndx %d\n",i);
         }
      }
      else
      {
         ndx = p_con_rec[ndx].next;
      }
   }

   /*=========================================================*/
   /*  check if there is a need to issue a reconnect message  */   
   /*=========================================================*/

   if ( OM_GA_tag_oids )
   {
      sts = om$os_internal_name_to_number ( osname = ME.OMTagCon->osname,
                                            p_osnum = &osnum );
      if (1&sts)
      {
         if ( !IF_NULL_OBJID(tag_oid = OM_GA_tag_oids[osnum]) )
         {
            sts = om$send ( msg = message OMTag.get_record_vla (&p_tag_rec,
                                                               &count, &flags),
                            targetid = tag_oid,
                            targetos = osnum );
            if (!(1&sts)) return (sts);

#ifdef vdsDEBUG
	printf("\n\t  Reconnect record \n" );
#endif
            sts = om$send ( msg = message OMTagCon.reconnect (p_tag_rec,
                                                              count, flags),
                            targetid = my_id );
            if (!(1&sts)) return (sts);
         }
      }
   }

   return (OM_S_SUCCESS);
}


method add ( OM_S_TAG_CON_INFO *info_str; OM_p_CHANNEL_LINK p_chan_link )
{
   int        sts;
   OMuword    slot, cnt, i;
   OMuword    ndx, lndx=0;
   struct OM_sd_connect_record *p_con_rec;

   /*=============================*/
   /*  get a slot for new record  */
   /*=============================*/

   if ( ME.OMTagCon->first_free != OM_K_TAGEND )
   {
      slot = ME.OMTagCon->first_free;
      ME.OMTagCon->first_free = 
         ME.OMTagCon->con_rec[ME.OMTagCon->first_free].next;
   }
   else
   {
      sts = om$vla_set_dimension ( varray = ME.OMTagCon->con_rec,
                                size = ME.OMTagCon->count + OM_Gw_tagcon_inc );
      if (!(1&sts)) return (sts);

      /*============================*/
      /*  initialize the free list  */
      /*============================*/

      if ( OM_Gw_tagcon_inc > 1 )
      {
         cnt = ME.OMTagCon->count;
         p_con_rec = &ME.OMTagCon->con_rec[0];

         ME.OMTagCon->first_free = cnt + 1;
         for ( i=1; i<(OMuword) (OM_Gw_tagcon_inc-1); i++ )
         {
            p_con_rec[cnt+i].next = cnt + i + 1;
         }
         p_con_rec[cnt+i].next = OM_K_TAGEND;
      }

      slot = ME.OMTagCon->count;
   }

   ME.OMTagCon->count++;

   p_con_rec = &ME.OMTagCon->con_rec[0];

   /*=============================================================*/
   /*  insert new record in tag order via the doubly linked list  */
   /*=============================================================*/

   if ( ME.OMTagCon->first_tag == OM_K_TAGEND )
   {
      ME.OMTagCon->first_tag = slot;
      p_con_rec[slot].next = OM_K_TAGEND;
      p_con_rec[slot].prev = OM_K_TAGEND;
   }
   else
   {
      ndx = ME.OMTagCon->first_tag;
      while ( ndx != OM_K_TAGEND )
      {
         if ( p_con_rec[ndx].tag > info_str->tag ) break;
         lndx = ndx;
         ndx  = p_con_rec[ndx].next;
      }
 
      if ( ndx == ME.OMTagCon->first_tag )
      {
         p_con_rec[slot].next = ME.OMTagCon->first_tag;
         p_con_rec[slot].prev = OM_K_TAGEND;
         ME.OMTagCon->first_tag          = slot; 
         p_con_rec[ndx].prev  = slot;
      }
      else if ( ndx == OM_K_TAGEND )
      {
         p_con_rec[slot].next = OM_K_TAGEND;
         p_con_rec[slot].prev = lndx;
         p_con_rec[lndx].next = slot;
      }
      else
      {
         p_con_rec[slot].next = ndx;
         p_con_rec[slot].prev = lndx;
         p_con_rec[p_con_rec[ndx].prev].next = slot;
         p_con_rec[ndx].prev  = slot;
      }
   }

   /*================================*/
   /*  initialize the new vla entry  */
   /*================================*/

   p_con_rec[slot].objid       = info_str->objid;
   p_con_rec[slot].tag         = info_str->tag;
   p_con_rec[slot].cnum        = info_str->chan;
   p_con_rec[slot].other_cnum  = info_str->tag_chan;
   p_con_rec[slot].index       = info_str->index;
   p_con_rec[slot].other_index = info_str->tag_index;   
   p_con_rec[slot].version     = info_str->version;
   p_con_rec[slot].flags       = 0;

   /*==========================================================*/
   /*  set the channum field in the channel link to the index  */
   /*==========================================================*/

   p_chan_link->channum.number = slot;
   p_chan_link->channum.classid = OM_K_NOTUSING_CLASSID;

   return (OM_S_SUCCESS);
}

#if defined (NT)
%undef remove
#endif

method remove( OMuword vla_ndx )
{
   int        sts;
   OMuword    vla_size, classid;
   struct OM_sd_connect_record *p_con_rec;

   /*======================================*/
   /*  perform range check on given index  */
   /*======================================*/
#ifdef vdsDEBUG
	printf("\n\t Method remove >> \n" );
#endif

   if ( ME.OMTagCon->first_tag == OM_K_TAGEND ) 
   {
#ifdef vdsDEBUG
	printf("\n\t End of Tag \n" );
	printf("\n\t  Method End \n" );
#endif
      return (OM_E_INVARG);
   }

   vla_size = om$dimension_of ( varray = ME.OMTagCon->con_rec );

   if ( vla_ndx > vla_size )
   {
#ifdef vdsDEBUG
	printf("\n\t  VLA Size : %d", vla_size );
	printf("\n\t  Index Size : %d", vla_ndx );
	printf("\n\t Index is out of range \n" );
	printf("\n\t  Method End \n" );
#endif
      return (OM_E_INVARG);
   }

   p_con_rec = &ME.OMTagCon->con_rec[0];

   /*============================================================*/
   /*  decrement OSCO refcnt and delete OSCO if it goes to zero  */
   /*============================================================*/

   if ((classid = OM_GA_filed_to_active[p_con_rec[vla_ndx].other_cnum.classid])
      == OM_K_NOTUSING_CLASSID)
      return(OM_S_SUCCESS);

   if(!(--(OM_Gp_CurOSD->OSCO_list[classid]->i_refcnt))
                        &&
        (!(OM_Gp_CurOSD->OSCO_list[classid]->w_child_refcnt)))
   {
#ifdef vdsDEBUG
	printf("\n\t  Decrementing the OMOSCO Class count by 1 \n" );
	printf("\n\t Delete Object Id : <%d> \n", OM_Gp_CurOSD->OSCO_list[classid]->OSCO_oid );
	printf("\n\t  Returning BAD STATUS : Method End \n" );
#endif
      sts = om$send( msg      = message OMOSCO.delete(0), 
                     senderid = NULL_OBJID,
                     targetid = OM_Gp_CurOSD->OSCO_list[classid]->OSCO_oid );
      if (!(1&sts)) return(sts);
   }

   /*==============================================*/
   /*  if record is at head of list update header  */
   /*==============================================*/

   if ( vla_ndx == ME.OMTagCon->first_tag )
   {
      ME.OMTagCon->first_tag = p_con_rec[vla_ndx].next;
   }
   else
   {
      p_con_rec[p_con_rec[vla_ndx].prev].next = p_con_rec[vla_ndx].next;
   }   

   /*===========================================================*/
   /*  if record is at tail of list no need to update previous  */
   /*===========================================================*/

   if ( p_con_rec[vla_ndx].next != OM_K_TAGEND )
   {
      p_con_rec[p_con_rec[vla_ndx].next].prev = p_con_rec[vla_ndx].prev;
   }

   /*====================*/
   /*  update free list  */
   /*====================*/

   p_con_rec[vla_ndx].next = ME.OMTagCon->first_free;
   ME.OMTagCon->first_free = vla_ndx;

   /*====================================================*/
   /*  if count goes to zero - delete the TagCon object  */
   /*====================================================*/

   if ( --ME.OMTagCon->count == 0 )
   {
      if (!OMTagCon_change_mode)
         om$send ( msg = message OMTagCon.delete(0),
                   targetid = my_id );
   }
#ifdef vdsDEBUG
	printf("\n\t <<End Method remove \n" );
#endif
   return (OM_S_SUCCESS);
}


method reconnect ( OM_p_TAG_RECORD p_tag_rec; OMuint count; OMuword flags )
{
   int                         sts;
   char                        inc_tag, inc_tagcon;
   OMuint                      save_Gf_tag_flag;
   OMuint                      my_count;
   OMuword                     j, osnum;
   OMuword                     tag_version;
   OM_S_OBJID                  tag_objid;
   struct OM_sd_connect_record *p_con_rec;
   OM_S_CHANSELECT             csel, tag_csel;

   /*=================================================*/
   /*  disable tag connects during reconnect process  */
   /*=================================================*/

   save_Gf_tag_flag = OM_Gf_tagged_connects;
   OM_Gf_tagged_connects = 0;

   my_count = 1;
   j = ME.OMTagCon->first_tag;
   if ( j == OM_K_TAGEND ) 
   {
      OM_Gf_tagged_connects = save_Gf_tag_flag;
      OM_Gi_tagcon_slot = 0;
      return (OM_S_SUCCESS);
   }
   p_con_rec = &ME.OMTagCon->con_rec[j];

   /*========================================*/
   /*  convert internal osname to os number  */
   /*========================================*/

   sts = om$os_internal_name_to_number ( osname = ME.OMTagCon->osname,
                                         p_osnum = &osnum );
   if (!(1&sts)) 
   {
      OM_Gf_tagged_connects = save_Gf_tag_flag;
      OM_Gi_tagcon_slot = 0;
      return (sts);                  /* may need an info here */
   }

   /*==============================================*/
   /*  check if tags are in an unordered state     */
   /*  this will only happen if over four billion  */
   /*  tags have been allocated - very rare        */
   /*==============================================*/

   if ( flags & OM_Tf_tags_unordered )
   {
      do 
      {
         p_con_rec = &ME.OMTagCon->con_rec[j];

         sts = om$tag_to_objid ( osnum = osnum,
                                 tag = p_con_rec->tag,
                                 p_objid = &tag_objid,
                                 p_version = &tag_version );

         if (!(1&sts))
         {
            p_con_rec->flags |= OM_TCf_unresolved_connection;
         }
         else
         {
            /*==============================*/
            /*  check for version mismatch  */
            /*==============================*/

            if ( p_con_rec->version != tag_version )
            {
               p_con_rec->flags |= OM_TCf_version_mismatch;
            }
            else
            {
               p_con_rec->flags &= (~OM_TCf_version_mismatch);
            }

            /*============================*/
            /*  perform the reconnection  */
            /*============================*/

            tag_csel.type = OM_e_num;
            tag_csel.u_sel.number = p_con_rec->other_cnum;
            /*  note - OSCO in this OS preserves filed classid  */
            tag_csel.u_sel.number.classid = 
                  OM_GA_filed_to_active[tag_csel.u_sel.number.classid];

            csel.type = OM_e_num;
            csel.u_sel.number = p_con_rec->cnum;
            csel.u_sel.number.classid = 
                  OM_GA_filed_to_active[csel.u_sel.number.classid];

/*  KLUDGE : The version converter has not taken care of Tag connections
		for ASsourcein objects. The following is to get around that
		problem    -Mohan   */
	{
	   char      classname[OM_K_MAXCLASS_LEN];

	    om$get_classname( objid = p_con_rec->objid,
			      classname = classname );
	    if(!strcmp(classname, "ASsourcein"))
	    {
		strcpy(classname, "ASsource");
		om$get_classid( classname = classname,
				p_classid = &csel.u_sel.number.classid );
	    }
	}
/* End of KLUDGE  */

            /*  set global so connect will reinstate slot num in chlink  */

            OM_Gi_tagcon_slot = j + 1;

            om$disable_intercept ( osnum = osnum,
                                   objid = tag_objid );

            sts = om$send ( mode = OM_e_wrt_message,
                            msg = message Root.connect ( tag_csel, 
                            p_con_rec->other_index, p_con_rec->objid,
                            OM_Gw_current_OS, csel, p_con_rec->index ),
                            senderid = p_con_rec->objid,
                            targetid = tag_objid,
                            targetos = osnum );
            if (!(1&sts) && (sts != OM_E_NOSUCHCLASS))
            {
               p_con_rec->flags |= OM_TCf_unresolved_connection;
            }
         }
         j = p_con_rec->next;
        
      } while ( j != OM_K_TAGEND );
   }
   else
   {
      /*============================*/
      /*  tag records are in order  */
      /*============================*/

      while ( 1 )
      {
         /*============================================*/
         /*  set flags to incriment pointers to false  */
         /*============================================*/

         inc_tag = 0;
         inc_tagcon = 0;

         /*====================================*/
         /*  skip holes in the tag record vla  */
         /*====================================*/

         if (IF_NULL_OBJID(p_tag_rec->objid))
         {
            inc_tag = 1;
         }

         /*===========================*/
         /*  check for matching tags  */
         /*===========================*/

         else if ( p_con_rec->tag == p_tag_rec->tag )
         {
            /*==============================*/
            /*  check for version mismatch  */
            /*==============================*/

            if ( p_con_rec->version != p_tag_rec->version )
            {
               p_con_rec->flags |= OM_TCf_version_mismatch;
            }
            else
            {
               p_con_rec->flags &= (~OM_TCf_version_mismatch);
            }

            /*============================*/
            /*  Perform the reconnection  */
            /*============================*/

            tag_csel.type = OM_e_num;
            tag_csel.u_sel.number = p_con_rec->other_cnum;
            /*  note - OSCO in this OS preserves filed classid  */
            tag_csel.u_sel.number.classid = 
                  OM_GA_filed_to_active[tag_csel.u_sel.number.classid];

            csel.type = OM_e_num;
            csel.u_sel.number = p_con_rec->cnum;
            csel.u_sel.number.classid = 
                  OM_GA_filed_to_active[csel.u_sel.number.classid];

/*  KLUDGE : The version converter has not taken care of Tag connections
		for ASsourcein objects. The following is to get around that
		problem    -Mohan   */
	{
	   char      classname[OM_K_MAXCLASS_LEN];

	    om$get_classname( objid = p_con_rec->objid,
			      classname = classname );
	    if(!strcmp(classname, "ASsourcein"))
	    {
		strcpy(classname, "ASsource");
		om$get_classid( classname = classname,
				p_classid = &csel.u_sel.number.classid );
	    }
	}
/* End of KLUDGE  */

            /*  set global so connect will reinstate slot num in chlink  */

            OM_Gi_tagcon_slot = j + 1;

            om$disable_intercept ( osnum = osnum,
                                   objid = p_tag_rec->objid );

            sts = om$send ( mode = OM_e_wrt_message,
                            msg = message Root.connect ( tag_csel, 
                            p_con_rec->other_index, p_con_rec->objid,
                            OM_Gw_current_OS, csel, p_con_rec->index ),
                            senderid = p_con_rec->objid,
                            targetid = p_tag_rec->objid,
                            targetos = osnum );
            if (!(1&sts) && (sts != OM_E_NOSUCHCLASS))
            {
               p_con_rec->flags |= OM_TCf_unresolved_connection;
            }

            inc_tagcon = 1;            
         }
         else if ( p_con_rec->tag > p_tag_rec->tag )
         {
            inc_tag = 1;
         }
         else
         {
            p_con_rec->flags |= OM_TCf_unresolved_connection;
            inc_tagcon = 1;
         }

         if ( inc_tagcon )
         {
            j = p_con_rec->next;
        
            /*=================================*/
            /*  check for loop exit condition  */
            /*=================================*/

            if ( j == OM_K_TAGEND ) break;
            p_con_rec = &ME.OMTagCon->con_rec[j];
         }

         if ( inc_tag )
         {
            if ( my_count == count )
            {
               do
               {
                  p_con_rec = &ME.OMTagCon->con_rec[j];
                  p_con_rec->flags |= OM_TCf_unresolved_connection;
                  j = p_con_rec->next;
               }  while ( j != OM_K_TAGEND );
 
               OM_Gf_tagged_connects = save_Gf_tag_flag;
               OM_Gi_tagcon_slot = 0;
               return (OM_S_SUCCESS);
            }
            p_tag_rec++;
            my_count++;
         }
      }
   }

   OM_Gf_tagged_connects = save_Gf_tag_flag;
   OM_Gi_tagcon_slot = 0;
   return (OM_S_SUCCESS);
}


method identify_yourself ( OMuword tag_osnum; OMuword *first_tag; 
                           struct OM_sd_connect_record **p_con_rec )
{
   OM_p_OSD  p_osd;

   /*=====================================*/
   /*  convert internal osname to number  */
   /*=====================================*/

   if ((tag_osnum < OM_Gw_maxOS) && (NULL != (p_osd = OM_GA_OSDs[tag_osnum])))
   {
      if (!strncmp(ME.OMTagCon->osname, p_osd->InternalName, 
                   OM_K_MAXINTOSNAME_LEN))
      {
         *first_tag = ME.OMTagCon->first_tag;
         *p_con_rec = &ME.OMTagCon->con_rec[0];
         return (OM_I_STOP_SENDING);
      }
   }
   return (OM_S_SUCCESS);
}

/*====================================================================*/
/*  This method is used to disconnect any connections represented in  */
/*   the TagCon vla.  A flag is set to bypass the removal of the      */
/*   TagCon record when the disconnect occurs                         */
/*====================================================================*/

method prep_write()
{
   int        sts;
   OMuint     save_Gf_tag_flag;
   OMuword    ndx, tag_osnum;
   OM_S_OBJID tag_objid;
   OM_S_CHANSELECT csel, tag_csel;
   struct OM_sd_connect_record *p_con_rec;

   sts = om$os_internal_name_to_number ( osname  = ME.OMTagCon->osname,
                                         p_osnum = &tag_osnum );
   if (!(1&sts))
   {
      return (OM_S_SUCCESS);
   }

   /*========================================================*/
   /*  disable removal of TagCon records during disconnects  */
   /*========================================================*/

   save_Gf_tag_flag = OM_Gf_tagged_connects;
   OM_Gf_tagged_connects = OM_K_TAGEND;

   tag_csel.type = OM_e_num;
   csel.type     = OM_e_num;

   /*====================================================*/
   /*  loop thru connect records performing disconnects  */
   /*====================================================*/

   ndx = ME.OMTagCon->first_tag;
   while ( ndx != OM_K_TAGEND ) 
   {
      p_con_rec = &ME.OMTagCon->con_rec[ndx];

      sts = om$tag_to_objid ( osnum   = tag_osnum,
                              tag     = p_con_rec->tag,
                              p_objid = &tag_objid );
                     
      if (1&sts) 
      {
         tag_csel.u_sel.number = p_con_rec->other_cnum;
         /* remember tag side cnum filed classid is mapped on tagcon side */
         tag_csel.u_sel.number.classid = 
              OM_GA_filed_to_active[tag_csel.u_sel.number.classid];
         csel.u_sel.number = p_con_rec->cnum;
         csel.u_sel.number.classid = 
              OM_GA_filed_to_active[csel.u_sel.number.classid];

         om$disable_intercept ( osnum = tag_osnum,
                                objid = tag_objid );

         om$send ( mode = OM_e_wrt_message,
                   msg = message Root.disconnect ( tag_csel, p_con_rec->objid,
                        OM_Gw_current_OS, csel ),
                   senderid = p_con_rec->objid,
                   targetid = tag_objid,
                   targetos = tag_osnum );
      }
      ndx = p_con_rec->next;
   }

   OM_Gf_tagged_connects = save_Gf_tag_flag;
   return (OM_S_SUCCESS);
}

method debug ()
{
   int              sts;
   OMuword          i, target_os;
   struct OM_sd_connect_record *p;

   if( nDEBUG_ON )
   {
     printf ("---------- OMTagCon ----------\n");
     printf ("OSnum................ %d\n",OM_Gw_current_OS);
     printf ("Oid.................. %d\n",my_id);
     printf ("First_tag............ %d\n",ME.OMTagCon->first_tag);
     printf ("First_free........... %d\n",ME.OMTagCon->first_free);
     printf ("Count................ %d\n",ME.OMTagCon->count); 
     printf ("Internal OS name..... %s\n",ME.OMTagCon->osname);
     printf ("Corresponding OSnum.. ");
   }

   sts = om$os_internal_name_to_number(osname=ME.OMTagCon->osname,
                                       p_osnum=&target_os);

   if( nDEBUG_ON == 0 )
   {
     nInstanceConnectionRecord = ME.OMTagCon->count;
     nInstanceFirstTag = ME.OMTagCon->first_tag;
     nInstanceFirstFree = ME.OMTagCon->first_free;
     pConnectionRecord = ME.OMTagCon->con_rec;
   }

   if( nDEBUG_ON )
   {
     if (!(1&sts))
	printf ("Not Active\n");
     else
	printf ("%d\n",target_os);
   }

   i = ME.OMTagCon->first_tag;
   if ( i == OM_K_TAGEND )
   {
     if( nDEBUG_ON )
     {
	printf ("No TagCon records in use\n");
     }
   }
   else
   {
      if( nDEBUG_ON )
      {
	 printf ("TagCon record list follows in tag order\n");
	 printf (" slot    tag  oid   ver  tcnum    cnum      tidx        idx");
	 printf ("   flag  next  prev\n");
      }

      while ( i != OM_K_TAGEND )
      {
         p = &ME.OMTagCon->con_rec[i];
	 if( nDEBUG_ON )
	 {
	    printf ("%5d %6d %4d %5d %3d/%3d %3d/%3d %10d %10d %4d %5d %5d\n",
		    i,p->tag,p->objid,p->version,p->other_cnum.classid,
		    p->other_cnum.number,p->cnum.classid,p->cnum.number,
		    p->other_index, p->index, p->flags, p->next, p->prev);
	 }
         i = p->next;

      }
   }
   return(OM_S_SUCCESS);
}

int som_flagged_tag_connects (OMuword osnum, OMuword tag_osnum,
                              OMuint *p_count, OMuint size,
                              OM_p_TAG_CON_INFO p_tag_info, OMuword mask )
{
   int              sts;
   OMuword          ndx;
   OMuword          save_osnum;    
   OM_S_CHANSELECT  csel;
   struct OM_sd_connect_record *p_con_rec;

   save_osnum = OM_Gw_current_OS;

   if ( osnum != OM_Gw_current_OS )
   {
      if ((osnum > OM_Gw_maxOS) || (NULL == OM_GA_OSDs[osnum]))
      {
         return (OM_E_NOSUCHOS);
      }
      om$make_current_os ( osnum = osnum );
   }

   csel.type = OM_e_name;
   csel.u_sel.name = "OMObjSpace.to_GrpDscs";

   /*======================================================================*/
   /*  issue a channel send to all TagCon objects to match with tag_osnum  */
   /*======================================================================*/

   sts = om$send ( msg = message OMTagCon.identify_yourself (tag_osnum, &ndx,
                                                             &p_con_rec),
                   senderid = OM_GO_current_OS_objid,
                   p_chanselect = &csel );
   if ( sts != OM_I_STOP_SENDING )
   {
       if ( save_osnum != OM_Gw_current_OS )
       {
          om$make_current_os ( osnum = save_osnum );
       }
       return (OM_E_NOSUCHOS);
   }

   *p_count = 0;

   /*===============================================================*/
   /*  loop thru tag connect records checking given mask condition  */
   /*===============================================================*/

   while ( ndx != OM_K_TAGEND )
   {
      if ( p_con_rec[ndx].flags & mask )
      {
         if ( size )
         {
            if ( *p_count < size )
            {
               p_tag_info[*p_count].objid     = p_con_rec[ndx].objid;
               p_tag_info[*p_count].tag       = p_con_rec[ndx].tag;
               p_tag_info[*p_count].chan      = p_con_rec[ndx].cnum;
               p_tag_info[*p_count].chan.classid = 
                      OM_GA_filed_to_active[p_con_rec[ndx].cnum.classid];
               p_tag_info[*p_count].tag_chan  = p_con_rec[ndx].other_cnum;
               p_tag_info[*p_count].tag_chan.classid  = 
                      OM_GA_filed_to_active[p_con_rec[ndx].other_cnum.classid];
               p_tag_info[*p_count].index     = p_con_rec[ndx].index;
               p_tag_info[*p_count].tag_index = p_con_rec[ndx].other_index;
               p_tag_info[*p_count].version   = p_con_rec[ndx].version;
               if ( *p_count == (size-1) ) 
               {
                  (*p_count)++;
                  break;             
               }
            }
         }
         (*p_count)++;
      }
      ndx = p_con_rec[ndx].next;
   }   
   
   if ( save_osnum != OM_Gw_current_OS )
   {
      om$make_current_os ( osnum = save_osnum );
   }
   return (OM_S_SUCCESS);
}

int som_test_connection (OMuword osnum, OM_S_OBJID objid,
                         OM_p_CHANSELECT csel, OMuword tag_osnum,
                         OM_S_OBJID tag_objid,
                         OM_p_CHANSELECT tag_csel, OMuword *p_version,
                         OMuword *p_tag_version, int force_flag )
{
   int              sts;
   OMuint           tag;
   OMuword          ndx;
   OM_S_CHANNUM     cnum, tag_cnum;
   OM_p_CHANNEL_HDR *pp_chan, *pp_tag_chan;
   OM_S_CHANSELECT  os_csel;
   struct OM_sd_connect_record *p_con_rec;

   sts = om$get_channel ( osnum        = osnum, 
                          objid        = objid, 
                          p_chanselect = csel, 
                          pp_channel   = &pp_chan,
                          p_channum    = &cnum );
   if (!(1&sts)) return (sts);

   sts = om$get_channel ( osnum        = tag_osnum, 
                          objid        = tag_objid, 
                          p_chanselect = tag_csel, 
                          pp_channel   = &pp_tag_chan,
                          p_channum    = &tag_cnum );
   if (!(1&sts)) return (sts);

   /*=======================================================*/
   /*  note : make these contain the needed filed classids  */
   /*         remember that tagcon os maps filed classid    */
   /*         for tag side (for translation protection)     */
   /*=======================================================*/

   cnum.classid = OM_GA_OSDs[osnum]->ActToFil[cnum.classid];
   tag_cnum.classid = OM_GA_OSDs[osnum]->ActToFil[tag_cnum.classid];

   sts = om$objid_to_tag ( osnum = tag_osnum, 
                           objid = tag_objid, 
                           p_tag = &tag, 
                           p_version = p_tag_version );
   if (!(1&sts)) return (sts);

   os_csel.type = OM_e_name;
   os_csel.u_sel.name = "OMObjSpace.to_GrpDscs";

   sts = om$send ( msg = message OMTagCon.identify_yourself ( tag_osnum,
                                                          &ndx, &p_con_rec),
                   senderid = OM_GO_current_OS_objid, 
                   p_chanselect = &os_csel, 
                   targetos = osnum );
   if ( sts != OM_I_STOP_SENDING ) return (OM_E_NOSUCHOS);

   while ( ndx != OM_K_TAGEND )
   {
      if ( p_con_rec[ndx].tag == tag )
      {
	 if ( IF_EQ_OBJID(p_con_rec[ndx].objid, objid) &&
	      ((p_con_rec[ndx].cnum.classid == cnum.classid) &&
	       (p_con_rec[ndx].cnum.number == cnum.number))
	                    &&
	      ((p_con_rec[ndx].other_cnum.classid == tag_cnum.classid) &&
	       (p_con_rec[ndx].other_cnum.number == tag_cnum.number)))
	 {
	    *p_version = p_con_rec[ndx].version;
	    if ( force_flag ) p_con_rec[ndx].version = *p_tag_version;
	    return (OM_S_SUCCESS);
	 }
      }
      ndx = p_con_rec[ndx].next;
   }
   return (OM_E_NOTTAGGED);
}

int som_perhaps_add_tagcon_rec ( s1, s2 )

OM_p_CONNECT_SIDE  s1, s2;

{
   int                 sts;            /* status                            */
   int                 constructFlag;   /* construct flag                    */
   OMuint              tag;            /* tag of object                     */
   OMuword             version;        /* version of tag                    */
   OMuword             ts_actclassid;  /* tag side active classid (channum) */
   OM_S_OBJID          tc_oid;         /* oid of TagCon object              */
   OM_p_TAGCON_LINK    p_link;         /* ptr to tagcon link                */
   OM_p_CONNECT_SIDE   ts;             /* tag side                          */
   OM_p_CONNECT_SIDE   tcs;            /* tag connect side                  */
   OM_S_TAG_CON_INFO   info_str;       /* TagCon info struct                */
   OM_S_OBJID          OSCO_objid;     /* OSCO oid                          */

#ifndef TRUE
#define TRUE			(1)
#endif
#ifndef FALSE
#define FALSE			(0)
#endif

   /*========================================*/
   /*  check if tagged connects are enabled  */
   /*========================================*/

   if ( OM_Gf_tagged_connects )
   {
      /*======================================*/
      /*  check if this is an ISO connection  */
      /*======================================*/

      if ( s1->osnum != s2->osnum )
      {
         if ( s1->osnum == OM_Gw_tagged_osnum )
         {
            ts  = s1;
            tcs = s2;
         }
         else if ( s2->osnum == OM_Gw_tagged_osnum )
         {
            ts  = s2;
            tcs = s1;
         }
         else
         {
            return (OM_S_SUCCESS);
         }

         /*==========================================*/
         /*  check if the tag side object has a tag  */
         /*==========================================*/
 
         if (!OM_OBJ_IS_TAGGED(ts->rip.p_object->i_size))
         {
            return (OM_S_SUCCESS);
         }

         /*================================================*/
         /*  check if the tag connect linkage already has  */
         /*  a tag connect record associated with it       */
         /*================================================*/

         if ((tcs->p_chlink) && 
             (tcs->p_chlink->channum.classid == OM_K_NOTUSING_CLASSID))
         {
            return (OM_S_SUCCESS);
         }

         sts = om$objid_to_tag ( osnum = ts->osnum,
                                 objid = ts->objid,
                                 p_tag = &tag,
                                 p_version = &version );
         if (!(1&sts))
         {
            printf ("Perhaps_add_tagcon: Unable to convert oid to tag\n");
            return (OM_E_INTERNALS_CORRUPT);
         }

         /*==============================================================*/
         /*  well now it is obvious that a tag connect record is needed  */
         /*  so check and see if there is a TagCon object in existence   */
         /*==============================================================*/

         constructFlag = TRUE;
         if (OM_GA_p_tagcon && OM_GA_p_tagcon[tcs->osnum])
         {
            p_link = OM_GA_p_tagcon[tcs->osnum];
            while ( p_link )
            {
               if ( ! strncmp(p_link->int_osname, 
                              OM_GA_OSDs[ts->osnum]->InternalName, 
                              OM_K_MAXINTOSNAME_LEN))
               {
                  tc_oid = p_link->objid;
                  constructFlag = FALSE;
                  break;
               }
               p_link = p_link->next;
            }
         }

         /*==========================================*/
         /*  construct the TagCon object if need be  */
         /*==========================================*/

         if ( constructFlag ) 
         {
	    OM_S_NEIGHBOR	neighbor;

	    neighbor.clusterid = 0;
	    neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
            sts = om$construct ( classid = OM_K_OMTAGCON_ACTCLASSID,
                                 osnum   = tcs->osnum,
                                 p_objid = &tc_oid,
                                 neighbor = neighbor,
                                 msg = message OMTagCon.initialize(ts->osnum));
            if (!(1&sts)) return (sts);                                 
         }

         /*========================================*/
         /*  initialize the TagCon info structure  */
         /*========================================*/

         info_str.objid     = tcs->objid;
         info_str.chan      = tcs->channum;
         info_str.index     = tcs->relidx;
         info_str.tag       = tag;
         info_str.tag_chan  = ts->channum;
         info_str.tag_index = ts->relidx;
         info_str.version   = version;

         /*=========================================================*/
         /*  check if an OSCO exists for the class on the Tag side  */
         /*  note - the OSCO preserves the filed classid stored in  */
         /*         the tagcon rec for the channum on the tag side  */
         /*=========================================================*/

         ts_actclassid = OM_GA_OSDs[ts->osnum]->FilToAct[ts->channum.classid];

         if ( OM_GA_OSDs[tcs->osnum]->OSCO_list[ts_actclassid] == NULL )
         {
            OM_S_NEIGHBOR   neighbor;

            neighbor.clusterid = 0;
            neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;

            if (!(1&(sts = om$construct (classid  = OM_K_OMOSCO_ACTCLASSID,
                                         neighbor = neighbor,
                                         osnum    = tcs->osnum,
                                         p_objid  = &OSCO_objid,
                                         msg      = message OMOSCO.initialize
                                 (OM_GA_active_classes[ts_actclassid], 1)))))
            {
               return (sts);
            }
            OM_GA_OSDs[tcs->osnum]->OSCO_list[ts_actclassid]=(OM_p_OSCO)
              ((int)OM_GA_OSDs[tcs->osnum]->Spacemap[OSCO_objid].state.object +
              sizeof(OM_S_OBJECTHDR));
         }
         else
         {
           OM_GA_OSDs[tcs->osnum]->OSCO_list[ts_actclassid]->i_refcnt++;
         }

         /*==============================================================*/
         /*  change tag side channum to have filed classid in tagcon OS  */
         /*==============================================================*/

         info_str.tag_chan.classid = 
                      OM_GA_OSDs[tcs->osnum]->ActToFil[ts_actclassid];
               
         /*=============================================*/
         /*  send the add message to the TagCon object  */
         /*=============================================*/

         sts = om$send ( msg = message OMTagCon.add(&info_str,tcs->p_chlink),
                         senderid = tc_oid,
                         targetid = tc_oid,
                         targetos = tcs->osnum );
         if (!(1&sts)) return (sts);
      }
   }
   return (OM_S_SUCCESS);
}


int som_perhaps_remove_tagcon_rec ( s1, s2 )

OM_p_CONNECT_SIDE  s1, s2;

{
   int                sts;
   OM_p_TAGCON_LINK   p_link;

   /*======================================*/
   /*  check if removal has been disabled  */
   /*======================================*/

   if ( OM_Gf_tagged_connects == OM_K_TAGEND ) return (OM_S_SUCCESS);

   if ((s1->p_chlink) && 
       (s1->p_chlink->channum.classid == OM_K_NOTUSING_CLASSID))
   {
      p_link = OM_GA_p_tagcon[s1->osnum];

      /*----------------------------------------------------------------------
      **  check for the one-side tagcon disconnect where a wild_disconnect
      **  is being done for an object - but the other OS is not loaded
      **  This would have been detected in som_ISO_mark_entry and s2->chused
      **  would have been set to 7 and a buffer would have been om$malloced
      **  and filled with the ISO's target internalOSname - the address of
      **  the buffer would then be placed in s2->p-chandata - note that the
      **  free of this buffer is done here
      **----------------------------------------------------------------------
      */

      if ((s2->osnum == (OMuword)OM_K_OSNOTHERE) && (s2->chused == 7)) {
         while ( p_link )
         {
            if ( !strncmp(p_link->int_osname, 
                          (char *) s2->p_chandata,
                          OM_K_MAXINTOSNAME_LEN)) break;
            p_link = p_link->next;
         }
         om$dealloc(ptr = (char *) s2->p_chandata);
      }
      else {                 /* normal case */
         while ( p_link )
         {
            if ( !strncmp(p_link->int_osname, 
                          OM_GA_OSDs[s2->osnum]->InternalName,
                          OM_K_MAXINTOSNAME_LEN)) break;
            p_link = p_link->next;
         }
      }
      if ( ! p_link ) 
      {
         /*=================================================*/
         /*  check if OMTagCon object is in a transient OS  */
         /*=================================================*/

         if (OM_GA_OSDs[s1->osnum]->type & OM_OSD_trans)
         {
            return (OM_S_SUCCESS);
         }

        printf("som_perhaps_remove_tagcon_rec:target TagCon link not found\n");
        return (OM_E_INTERNALS_CORRUPT);
      }

      sts = om$send (msg=message OMTagCon.remove((OMuword) s1->p_chlink->channum.number),
                     senderid = p_link->objid,
                     targetid = p_link->objid,
                     targetos = s1->osnum );

      s1->p_chlink->channum.number  = 0;
      s1->p_chlink->channum.classid = 0;

      if (!(1&sts)) return (sts);

   }
   return (OM_S_SUCCESS);
}

int som_perhaps_change_tagcon_rec ( s1, s2, s3 )

OM_p_CONNECT_SIDE s1, s2, s3;

{
   int                  sts;
   OMuword              tag_os, tagcon_os;
   OMuword              first_tag, slot;
   OM_p_TAGCON_LINK     p_link;
   OM_S_TAG_CON_INFO    info;
   struct OM_sd_connect_record *p_con_rec;
  
   /*=======================================================*/
   /*  check if one side of connection has a TagCon record  */
   /*=======================================================*/

   if ((s1->p_chlink) &&
       (s1->p_chlink->channum.classid == OM_K_NOTUSING_CLASSID))
   {
      tag_os    = s3->osnum;
      tagcon_os = s1->osnum;
      slot = s1->p_chlink->channum.number;
   }
   else if ((s3->p_chlink) &&
            (s3->p_chlink->channum.classid == OM_K_NOTUSING_CLASSID))
   {
      tag_os    = s1->osnum;
      tagcon_os = s3->osnum;
      slot = s3->p_chlink->channum.number;
   }
   else
   {
      return (OM_S_SUCCESS);
   }

   /*=======================================*/
   /*  locate the oid of the TagCon object  */
   /*=======================================*/

   p_link = OM_GA_p_tagcon[tagcon_os];
   while ( p_link )
   {
      if (!strncmp(p_link->int_osname, OM_GA_OSDs[tag_os]->InternalName,
                   OM_K_MAXINTOSNAME_LEN)) break;
      p_link = p_link->next;
   }

   if ( ! p_link )
   {
      /*=================================================*/
      /*  check if OMTagCon object is in a transient OS  */
      /*=================================================*/

      if (OM_GA_OSDs[tagcon_os]->type & OM_OSD_trans)
      {
         return (OM_S_SUCCESS);
      }

      printf("som_perhaps_change_tagcon_rec:TagCon link not found\n");
      return (OM_E_INTERNALS_CORRUPT);
   }

   /*=======================================*/
   /*  check if tag connect mode is active  */
   /*=======================================*/

   if ((OM_Gf_tagged_connects) && (tag_os == OM_Gw_tagged_osnum))
   {
      /*=============================================*/
      /*  send an identify msg to the TagCon object  */
      /*=============================================*/

      sts = om$send ( msg = message OMTagCon.identify_yourself(tag_os,
                                           &first_tag, &p_con_rec),
                      senderid = p_link->objid,
                      targetid = p_link->objid,
                      targetos = tagcon_os );
      if (sts != OM_I_STOP_SENDING)
      {
         printf("som_perhaps_change_tagcon_rec:identify_yourself failed\n");
         return (OM_E_INTERNALS_CORRUPT);
      }

      /*========================================================*/
      /*  change the (objid,channum) pair in the TagCon record  */
      /*========================================================*/

      if ( s1->osnum == tagcon_os )
      {
         /*==================================================================*/
         /*  new tagcon object - tag is unchanged - simply alter the record  */
         /*==================================================================*/

         p_con_rec[slot].objid = s2->objid;
         p_con_rec[slot].cnum  = s2->channum;

         s2->p_chlink->channum.classid = OM_K_NOTUSING_CLASSID;
         s2->p_chlink->channum.number  = slot;

         /*===========================================================*/
         /*  clear the old tag con chanlink because he/she no longer  */
         /*  has a tag con connection.                                */
         /*===========================================================*/

         s1->p_chlink->channum.classid = 0;
         s1->p_chlink->channum.number  = 0;
      }
      else
      {
         /*==========================================================*/
         /*  set change mode to prevent the removal of the OMTagCon  */
         /*  object when removing and adding the last tag con rec.   */
         /*==========================================================*/

         OMTagCon_change_mode = 1;

         /*======================================================*/
         /*  new tag object - must reinsert record in tag order  */
         /*======================================================*/

         info.objid     = p_con_rec[slot].objid; 
         info.chan      = p_con_rec[slot].cnum; 
         info.index     = p_con_rec[slot].index; 
         info.tag_index = p_con_rec[slot].other_index; 

         sts = om$send ( msg = message OMTagCon.remove ( slot ),
                         senderid = p_link->objid,
                         targetid = p_link->objid,
                         targetos = tagcon_os );

         if (tagcon_os == s1->osnum) {
            s1->p_chlink->channum.number  = 0;
            s1->p_chlink->channum.classid = 0;
         }
         else {
            s3->p_chlink->channum.number  = 0;
            s3->p_chlink->channum.classid = 0;
         }

         OMTagCon_change_mode = 0;

         if (!(1&sts)) return (sts);

         /*============================================================*/
         /*  alter the info structure to depict the new tagged object  */
         /*============================================================*/

         sts = om$objid_to_tag ( osnum = tag_os,
                                 objid = s2->objid,
                                 p_tag = &info.tag,
                                 p_version = &info.version );
         if (!(1&sts)) return (sts);

         info.tag_chan = s2->channum;

         sts = om$send ( msg = message OMTagCon.add ( &info, s3->p_chlink ),
                         senderid = p_link->objid,
                         targetid = p_link->objid,
                         targetos = tagcon_os );
         if (!(1&sts)) return (sts);
      }
   }
   else
   {
      /*============================*/
      /*  remove the TagCon record  */
      /*============================*/

      sts = om$send ( msg = message OMTagCon.remove(slot),
                      senderid = p_link->objid,
                      targetid = p_link->objid,
                      targetos = tagcon_os );

      if (tagcon_os == s1->osnum) {
         s1->p_chlink->channum.number  = 0;
         s1->p_chlink->channum.classid = 0;
      }
      else {
         s3->p_chlink->channum.number  = 0;
         s3->p_chlink->channum.classid = 0;
      }

      if (!(1&sts)) return(sts);
   }
   return (OM_S_SUCCESS);
}

/*=====================================================================*/
/*  This function is used to make a pass through all OMTagCon objects  */
/*  in the running system and issue a reconnect -- this is done to     */
/*  create the OMTagCons for objects of a previously unknown class     */
/*  which have become known via the switchprod                         */
/*=====================================================================*/

int som_tagcon_switchprod_update ()
{
   int                sts;
   OMuint             tag_count;
   OMuword            os, tag_osnum, tag_flags;
   OM_S_OBJID         tag_oid;
   OM_p_TAGCON_LINK   p_tc_link;
   OM_p_TAG_RECORD    p_tag_rec;

   if ( OM_GA_p_tagcon ) {
      for (os=1; os < OM_Gw_maxOS; ++os) {
         p_tc_link = OM_GA_p_tagcon[os];
         while (p_tc_link) {
            sts = om$os_internal_name_to_number ( osname=p_tc_link->int_osname,
                                                  p_osnum = &tag_osnum );
            if (1&sts) {
               if (OM_GA_tag_oids && 
                   !IF_NULL_OBJID(tag_oid = OM_GA_tag_oids[tag_osnum])) {

                  sts = om$send ( msg = message OMTag.get_record_vla
                                    (&p_tag_rec, &tag_count, &tag_flags),
                                  senderid = NULL_OBJID,
                                  targetid = tag_oid,
                                  targetos = tag_osnum );

                  sts = om$send ( msg = message OMTagCon.reconnect
                                    (p_tag_rec, tag_count, tag_flags),
                                  senderid = NULL_OBJID,
                                  targetid = p_tc_link->objid,
                                  targetos = os );
               }
            }
            p_tc_link = p_tc_link->next;
         }
      }
   }
   return (OM_S_SUCCESS);
}

/*
 * This function is called from "COz_DelTag.u" ppl, to retreive the
 * instance data of the OMTagCon objects.
 */
int EXGetTagConRecordInstance( int **nTagCount, int **nFirstTag, 
int **nFirstFree, struct OM_sd_connect_record **ppConRec)
{
  *ppConRec = pConnectionRecord;
  *nTagCount = &nInstanceConnectionRecord;
  *nFirstTag = &nInstanceFirstTag;
  *nFirstFree = &nInstanceFirstFree;
  return OM_S_SUCCESS;
}

end implementation OMTagCon;
