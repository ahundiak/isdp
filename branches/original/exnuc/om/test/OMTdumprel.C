#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"

static int print_link (os, p_link, p_olink, res_cnum)

OMuword            os;
OM_p_CHANNEL_LINK  p_link;
OM_p_OBJID         p_olink;
OM_S_CHANNUM       res_cnum;

{
   int           sts;
   OMuword       os2;
   OM_S_OBJID    objid;
   OMuword       my_flags;
   OM_S_CHANNUM  channum;
 
   if ( p_olink != NULL )
      {
      os2 = os;
      objid = *p_olink;
      channum = res_cnum;
      my_flags = OM_CL_to_object;
      }
   else if ( p_link != NULL )
      {
      if ( p_link->hdr.flags & OM_CL_to_object )
        {
        os2 = os;
        objid = p_link->objid;
        channum = p_link->channum;
        my_flags = p_link->hdr.flags;
        }
      else
        {
        sts = som_ISO_fetch ( os, p_link->hdr.u1.isoindex, p_link->objid, 
                          &os2, &objid, &channum, &my_flags );
        if (!(1&sts)) return (sts);
        if (sts==OM_I_LOGICAL_DISCONNECT) return(OM_S_SUCCESS);
        my_flags = p_link->hdr.flags;
        }
      }

   printf (" %3d     %5d      %3d         %3d    ",os2,objid,channum.number,
                                       channum.classid);
   if ( my_flags & OM_CL_to_object ) printf (" to_object");
   else printf (" to_iso");
   printf ("\n");
   return(1);
}


int   OMT_dump_relation(osnum, objid, chan_name)
OMuword         osnum;
OM_S_OBJID      objid;
char           *chan_name;

{
   int                         i,sts,res;
   OM_p_CHANNEL_HDR            *pp_chan_hdr, p_chan_hdr;
   OM_S_CHANSELECT             chanselect;
   OM_p_OBJID                  p_olink=NULL;
   OM_p_CHANNEL_LINK           p_link=NULL;
   OM_p_CHANNEL_DEFN           p_chdef;
   OM_S_CHANNUM                channum, res_cnum;
   int			       *p_chandata;
   OM_S_BIG_TAIL	       tail;

  chanselect.type = OM_e_name;
  chanselect.u_sel.name = chan_name;

  sts = om$get_channel ( osnum        = osnum,		
                         objid        = objid,				
			 p_chanselect = &chanselect,		
			 pp_channel   = &pp_chan_hdr,
                         pp_chandef   = &p_chdef,
			 pp_chandata  = &p_chandata,
                         p_channum    = &channum,
			 p_tail       = &tail );

  p_chan_hdr = *pp_chan_hdr;
  if ( !p_chan_hdr )
  {
     printf("============== Channel is empty =============\n");
     return(OM_I_CHAN_EMPTY);
  }

  printf ("\n================= Dump Relation =====================\n\n");
  printf (" Objid ........................ %d\n",objid);
  printf (" OSnum ........................ %d\n",osnum);
  printf (" Channel number ............... %d\n",channum.number);
  printf (" Class id ..................... %d\n",channum.classid);
  printf (" Class name ................... %s\n",
                    OM_GA_active_classes[channum.classid]->s_name);
  printf (" Channel flags ................");
  if ( p_chan_hdr->flags & OM_CH_singleton )  printf (" singleton");
  if ( p_chan_hdr->flags & OM_CH_1_1 )        printf (" 1_1");
  if ( p_chan_hdr->flags & OM_CH_m_1 )        printf (" m_1");
  if ( p_chan_hdr->flags & OM_CH_1_m )        printf (" 1_m");
  if ( p_chan_hdr->flags & OM_CH_m_m )        printf (" m_m");
  if ( p_chan_hdr->flags & OM_CH_absordered ) printf (" absordered");
  if ( p_chan_hdr->flags & OM_CH_relordered ) printf (" relordered");
  if ( p_chan_hdr->flags & OM_CH_full )       printf (" full");
  if ( p_chan_hdr->flags & OM_CH_restricted ) printf (" restricted");
  if ( p_chan_hdr->flags & OM_CH_in_use )     printf (" in_use");
  if ( p_chan_hdr->flags & OM_CH_tail_exists )printf (" tail_exists");

  printf ("\n");

  if ( p_chan_hdr->flags & OM_CH_restricted )
  {
     res = 1;
     res_cnum = p_chdef->p_type->channum;
     p_olink = (OM_p_OBJID)(p_chandata);
  }
  else
  {
     res = 0;
     p_link = (OM_p_CHANNEL_LINK)(p_chandata);
  }

  if ( p_chan_hdr->flags & OM_CH_singleton )
  {
     printf (" ************** linkage information **********\n");
     printf (" OSnum    Objid    channel    classid    flags\n");    
     if ( res )
     {
       if (!IF_NULL_OBJID(*p_olink))
       {
          sts = print_link ( osnum, (OM_p_CHANNEL_LINK) NULL, p_olink,
             res_cnum );
          if (!(1&sts)) return(sts);
       }
     }
     else
     {
       if (!IF_NULL_OBJID(p_link->objid))
       {
          sts = print_link ( osnum, p_link, (OM_p_OBJID) NULL, res_cnum );
          if (!(1&sts)) return(sts);
       }
     }

  }
  else
  {
     printf (" Collapse count ............... %d\n", tail.collapse_count);
     printf (" Last index ................... %d\n", tail.last_index);
     printf (" ************** linkage information **********\n");
     printf (" OSnum    Objid    channel    classid    flags\n");    
  
     if ( res ) 
     {
        for ( i=0; i<tail.last_index; i++ )
        {
           if (!(IF_NULL_OBJID(*p_olink)))
           {
              sts = print_link ( osnum, (OM_p_CHANNEL_LINK) NULL, p_olink,
                 res_cnum );
              if (!(1&sts)) return(sts);
           }
           p_olink++;
        }
     }
     else
     {
        for ( i=0; i<tail.last_index; i++ )
        {
           if (!(IF_NULL_OBJID(p_link->objid)))
           {
              sts = print_link ( osnum, p_link, (OM_p_OBJID) NULL, res_cnum );
              if (!(1&sts)) return(sts);
           }
           p_link++;
        }
     }
  }
  printf ("\n");
  return(sts);
}
