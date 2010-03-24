/*====================================================================*/
/*                                                                    */
/* DrOS Initialization                                                */
/*                                                                    */
/* 1)  Parse the command line                                         */
/* 2)  Report what's known about the file (Header ok, structure ok,   */
/*     checksum ok, timestamp, node, Clix version, image name, error  */
/*     messages)                                                      */
/* 3)  Generate tables of object ids & classids, etc.                 */
/*                                                                    */
/*====================================================================*/

#include    "exsysdep.h"
#include    <stdio.h>
#include    <string.h>
#include    <fcntl.h>
#include    <ctype.h>
#include    <errno.h>
#include    <sys/param.h>
#include    "OMOSfilehdr.h"
#include    "OMmetaclass.h"
#include    "OMspecify.h"
#include    "dros.h"

#ifdef BIG_ENDIAN
#include    "OMport.h"

extern int           bigend_portHdr(),
                     bigend_portOSO(),
                     bigend_portOMCluster(),
                     bigend_portOMOSCO(),
                     bigend_portOMISO(),
                     bigend_portOMGroup(),
                     bigend_portOMTag(),
                     bigend_portOMTagCon(),
                     bigend_portOMrtree(),
                     swapint(),
                     swapshort();
#endif

extern char          *som_malloc(),
                     *som_calloc(),
                     *som_realloc();
extern void          som_dealloc(),
                     addLink(),
                     setFlag(),
                     fixHeader(),
                     removeEntry(),
                     validateTagVla(),
                     validateClassRefcnt(),
                     addToTagTree();

extern int           reportError(),
                     count_iso(),
                     getOSCObyClassName(),
                     validateCluster(),
                     dros_val_chan(),
                     sort_routine(),
                     getopt(),
                     optind;
extern char          *optarg,
                     *getenv();
extern struct tagNode *lookupTag();

extern unsigned int  os_size,          /* Size of object space file */
                     objCnt,           /* Num objs found in file by stepping */
                     mode,             /* Dr.OS mode flags */
                     OSflags,          /* Object space flags */
                     errcnt,           /* Error id for errorlog file entries */
                     firstObjfp,       /* File ptr to first obj (512 or 1024) */
                     iso_count,        /* Number of iso objs in cluster 0 */
                     cluster_count,    /* Number of cluster objs on oso chan */
                     osco_count,       /* Number of osco objs on oso channel */
                     group_count,      /* Number of groups on oso channel */
                     tag_count,        /* Number of valid entries in tagRec */
                     *iso_oid,
                     *classRefcnt,
                     *iso_summary,
                     highOid;
extern FILE          *osfp,            /* File descriptors */
                     *errlogfp,
                     *outfp,
                     *logfile;
extern struct OMCluster_instance
                     *clust0,
                     **cluster,
                     **clustbyfp,
                     **clustbyid;
extern struct OMOSCO_instance
                     **oscobyfp,
                     **oscobyid;
extern struct OMISO_instance
                     **iso;
extern struct OMObjSpace_instance
                     *oso;
extern struct OMGroup_array
                     *group;
extern struct ISOd_data
                     *iso_dir;
extern struct classstats *classStats;
extern unsigned short high_classid,
                     highCnum;
extern char          *optarg,
                     outputFile[],
                     verbose,          /* Print-extra-messages flag */
                     badTag,           /* Tag-validation-has-failed flag */
                     OSname;
extern struct OM_sd_OS_filehdr_OM
                     filehdr;
extern struct tagNode   *tagTree;
extern struct tagLink   *tagRemoveEntryList;
extern struct tagLink   *tagFixHeaderList;
extern struct tagLink   **endOfTagFixHeaderList;
extern struct tagLink   **endOfTagRemoveEntryList;
extern struct sort_element *sort_classname;

int                  topOfFilehdr,
                     tagconPatchCount,
                     tagVlaOffset,
                     tagSize;
unsigned int         tagOid,
                     class_count;
struct statsbyid     *objTable = 0;
char                 **tagconPatchList,
                     filename[MAXPATHLEN+1],
#ifdef CLIX
                     ddpPath[MAXPATHLEN+1],
#endif
                     tag,
                     tagconPatch = 0;
struct OMTag_instance *tagRec;
struct OM_sd_tag_record *tagVla;
struct _to_OSO
{
   unsigned short flags;
   unsigned short count;
   unsigned short classid;
   unsigned short number;
   unsigned int   oid;
   unsigned int   align;
};
struct TagConClass
{
   OMuword              classid;
   OMuint               count;
   OMuint               oid;     /* TagCon object id */
   OMuint               fp;      /* TagCon object file pointer */
   struct TagConClass   *next;
} *TagConClasses;


validateChannels(oid)
unsigned int   oid;
{
   int                           len;
   OMuint                        ii, j, jj, kk, objSize, *pp_chan;
   OMuword                       fil_classid, type, count;
   OM_S_CHANNUM                  target_res_chan, channum;
   OM_S_BIG_TAIL                 *p_tail, tail;
   OM_p_CHANNEL_HDR              p_chan;
   struct OMOSCO_instance        *pOSCO;
   struct component_list_struct  *component_list;
   struct sd_vla_list            *vla_list;
   struct sd_chan_info           *chan_info;
   char                          *res_classname;
   unsigned short                *res_channum;
   static char                   *p_object;
   static OMuint                 curSize = 0;

#ifdef BIG_ENDIAN
   int                           tempint;
   short                         tempshort;
#endif

   fil_classid = objTable[oid].classid;

#ifdef DEBUG
printf("oid: %d  class: %d\n", oid, fil_classid);
#endif

   pOSCO = oscobyid[fil_classid];      /* Classids & obj sizes are all ok */
   fseek(osfp, objTable[oid].fp + 8, 0);
   if (curSize < (objSize = (objTable[oid].size & 0xfffffff8)))
   {
      curSize = objSize;
      if (!p_object)
      {
         if (!(p_object = (char *) om$malloc(size=curSize)))
         {
            fprintf(stdout, "Could not allocate %d bytes to validate channels for object at %d.\n        Object id: %d   Class id: %d  Cluster: %d\n",
               curSize, objTable[oid].fp, oid, fil_classid,
               objTable[oid].cluster_num);
            return(0);
         }
      }
      else if (!(p_object = (char *) om$realloc(ptr=(char *) p_object,
         size=curSize)))
      {
         fprintf(stdout, "Could not allocate %d bytes to validate channels for object at %d.\n        Object id: %d   Class id: %d  Cluster: %d\n",
            curSize, objTable[oid].fp, oid, fil_classid,
            objTable[oid].cluster_num);
         return(0);
      }
   }

#ifdef DEBUG
printf("&object: 0x%x\n", p_object);
#endif

   if (fread(p_object, 1, objSize, osfp) != objSize)
   {
      fprintf(stdout, "Offset %d. Could not read %d bytes to validate channels for object.\n        Object id: %d   Class id: %d  Cluster: %d\n",
         objTable[oid].fp, objSize, oid, fil_classid,
         objTable[oid].cluster_num);
      return(0);
   }
   component_list = (struct component_list_struct *)
      (pOSCO->component_list_descr.i_offset +
      (char *) &pOSCO->component_list_descr.i_offset);

#ifdef DEBUG
printf("# components: %d\n", pOSCO->component_list_descr.i_count);
#endif

   for (ii=0; ii<pOSCO->component_list_descr.i_count; ++ii)
   {
      if (!component_list[ii].offset)
         continue;
      if (!oscobyid[component_list[ii].classid])
      {
         reportError("\n%6d. Offset %d.  Component %d of object %d is invalid.\n        Classid %d (%s).\n",
            ++errcnt, objTable[oid].fp, ii, oid, fil_classid,
            pOSCO->OSCO.s_name);
         continue;
      }
      chan_info = (struct sd_chan_info *) (oscobyid[component_list[ii].
         classid]->chan_info_descr.i_offset + (char *) &oscobyid
         [component_list[ii].classid]->chan_info_descr.i_offset);
      res_classname = (char *) (oscobyid[component_list[ii].classid]->
         res_classname_descr.i_offset + (char *) &oscobyid
         [component_list[ii].classid]->res_classname_descr.i_offset);
      res_channum = (unsigned short *) (oscobyid[component_list[ii].classid]->
         res_channum_descr.i_offset + (char *) &oscobyid
         [component_list[ii].classid]->res_channum_descr.i_offset);
      vla_list = (struct sd_vla_list *) (oscobyid[component_list[ii].
         classid]->vla_list_descr.i_offset + (char *) &oscobyid
         [component_list[ii].classid]->vla_list_descr.i_offset);

      /*===========================================*/
      /* loop thru all channels for this component */
      /*===========================================*/

#ifdef DEBUG
printf("%d.  # channels: %d\n", ii, oscobyid[component_list[ii].classid]->
	chan_info_descr.i_count);
#endif

      for (j=0;
           j<oscobyid[component_list[ii].classid]->vla_list_descr.i_count;
           ++j )
      {
         int   *pp_vla;

         pp_vla = (int *) ((int) p_object +
            component_list[ii].offset + vla_list[j].offset);

#ifdef BIG_ENDIAN
         swapint(pp_vla, &tempint);
         *pp_vla = tempint;
#endif

         if (!*pp_vla)
            continue;
         if (*pp_vla % 4)
         {
            reportError("\n%6d. Offset %d.  File vla offset (%d) not aligned.  Vla %d of\n        component %d.  Object id: %d  Class id: %d  Vla location: %d\n",
               ++errcnt, objTable[oid].fp, *pp_vla, j, ii, oid, fil_classid,
               ((objTable[oid].fp + 8) + component_list[ii].offset +
               vla_list[j].offset));

#ifdef BIG_ENDIAN
            swapint(pp_vla, &tempint);
            *pp_vla = tempint;
#endif
            continue;
         }
         if (((*pp_vla + (char *) pp_vla) < p_object) ||
             ((*pp_vla + (char *) pp_vla) > (p_object + objSize)))
         {
            reportError("\n%6d. Offset %d.  Bad vla file offset (%d).  Vla %d of\n        component %d.  Object id: %d  Class id: %d  Vla location: %d\n",
               ++errcnt, objTable[oid].fp, *pp_vla, j, ii, oid, fil_classid,
               ((objTable[oid].fp +8) + component_list[ii].offset +
               vla_list[j].offset));

#ifdef BIG_ENDIAN
            swapint(pp_vla, &tempint);
            *pp_vla = tempint;
#endif
            continue;
         }

#ifdef BIG_ENDIAN
         swapint(pp_vla, &tempint);
         *pp_vla = tempint;
#endif

      }
      for (j=kk=jj=0;
           j<oscobyid[component_list[ii].classid]->chan_info_descr.i_count;
           ++j )
      {
         unsigned int      *p_oid, objid;
         OM_p_CHANNEL_LINK p_link;
         type = chan_info[j].type;

#ifdef DEBUG
printf("  component_list[%d].offset: %d   chan_info[%d].offset: %d\n",
   ii, component_list[ii].offset, j, chan_info[j].offset);
#endif

         pp_chan = (OMuint *) (p_object +
            component_list[ii].offset + chan_info[j].offset);
         if (!*pp_chan)
            continue;                  /* Empty channel */

#ifdef BIG_ENDIAN
         swapint(pp_chan, &tempint);
         *pp_chan = tempint;
#endif

         p_chan = (OM_p_CHANNEL_HDR) ((char *) pp_chan + *pp_chan);

         if (type & CD_restricted)
         {
            /*=========================================*/
            /* format restricted target channel number */
            /*=========================================*/

#ifdef DEBUG
printf("   Restricted\n");
#endif

            p_link = 0;
            target_res_chan.number = res_channum[jj];
            len = strlen(&res_classname[kk]);
            if ((target_res_chan.classid =
               getOSCObyClassName(&res_classname[kk])) == 65535)
            {
               return(0);
            }
            kk += (len + 1);
            ++jj;

            if ((type & CD_1_1) || (type & CD_m_1)) {   /* res1chan */
               count = 1;
               if ((objid = *pp_chan >> 1) > highOid)
               {
                  reportError("\n%6d. Offset %d.  Restricted channel %d of component %d at offset %d\n        contains an invalid target id (%d).  Object id: %d  Class id: %d\n",
                     ++errcnt, objTable[oid].fp, j, ii,
                     ((objTable[oid].fp + 8) + component_list[ii].offset +
                     chan_info[j].offset), objid, oid, fil_classid);

#ifdef BIG_ENDIAN
                  swapint(pp_chan, &tempint);
                  *pp_chan = tempint;
#endif
                  continue;
               }
               p_oid = &objid;

#ifdef BIG_ENDIAN
               swapint(p_oid, &tempint);
               *p_oid = tempint;
#endif
            }
            else {
               if (((char *) p_chan < p_object) ||
                   ((char *) p_chan > (p_object + objSize)))
               {
                  reportError("\n%6d. Offset %d.  Bad channel file offset (%d).  Channel %d of\n        component %d.  Object id: %d  Class id: %d  Channel location: %d\n",
                     ++errcnt, objTable[oid].fp, p_chan, j, ii, oid,
                     fil_classid, ((objTable[oid].fp + 8) +
                     component_list[ii].offset + chan_info[j].offset));

#ifdef BIG_ENDIAN
                  swapint(pp_chan, &tempint);
                  *pp_chan = tempint;
#endif
                  continue;
               }

#ifdef BIG_ENDIAN
               swapshort(&p_chan->flags, &tempshort);
               p_chan->flags = tempshort;
#endif

               if ( p_chan->flags & OM_CH_bigchan ) {
                  if (objSize < (65535 * 4))
                  {
                     reportError("\n%6d. Offset %d.  Channel %d of component %d at offset %d is\n        incorrectly marked as a 'big channel'.  Object id: %d  Class id: %d\n",
                        ++errcnt, objTable[oid].fp, j, ii,
                        ((objTable[oid].fp + 8) + component_list[ii].offset +
                        chan_info[j].offset), oid, fil_classid);

#ifdef BIG_ENDIAN
                     swapint(pp_chan, &tempint);
                     *pp_chan = tempint;
#endif
                     continue;
                  }
                  p_oid = (unsigned int *)((OMuint)p_chan + sizeof(OM_S_BIG_TAIL) +
                                       sizeof(OM_S_CHANNEL_HDR));

                  p_tail = (OM_p_BIG_TAIL)((OMuint)p_chan + 
                                       sizeof(OM_S_CHANNEL_HDR));
                  count = p_tail->last_index;

#ifdef BIG_ENDIAN
                  swapshort(&count, &tempshort);
                  count = tempshort;
#endif

               } 
               else {
                  p_oid = (unsigned int *)((OMuint)p_chan + 
                                       sizeof(OM_S_CHANNEL_HDR));

                  if (p_chan->flags & OM_CH_tail_exists)
                  {
                     if (p_chan->flags & OM_CH_bigchan)
                     {
                        tail = *((OM_p_BIG_TAIL) ((OMuint) (p_chan) +
                           sizeof(OM_S_CHANNEL_HDR)));
                     }
                     else
                     {
                        OMuword           link_size;
                        OM_p_LITTLE_TAIL  p_ltail;
                        if (p_chan->flags & OM_CH_restricted)
                           link_size = sizeof(OM_S_OBJID);
                        else
                           link_size = sizeof(OM_S_CHANNEL_LINK);

#ifdef BIG_ENDIAN
                        swapshort(&p_chan->u1.count, &tempshort);
                        p_chan->u1.count = tempshort;
#endif

                        p_ltail = ((OM_p_LITTLE_TAIL) ((OMuint)
                           p_chan + sizeof(OM_S_CHANNEL_HDR) +
                           (p_chan->u1.count - 1) * link_size));

#ifdef BIG_ENDIAN
                        swapshort(&p_chan->u1.count, &tempshort);
                        p_chan->u1.count = tempshort;
#endif

                        tail.last_index = p_ltail->last_index;
                     }
                     count = tail.last_index;
                  }
                  else
                  {
                     count = p_chan->u1.count;
                  }

#ifdef BIG_ENDIAN
                  swapshort(&count, &tempshort);         /* Swap */
                  count = tempshort;
#endif

               }

#ifdef BIG_ENDIAN
               swapshort(&p_chan->flags, &tempshort);    /* Swap back */
               p_chan->flags = tempshort;
#endif
            }
         }
         else {  /* not restricted */

#ifdef DEBUG
printf("   Not restricted\n");
#endif

            if (*pp_chan % 4)
            {
               reportError("\n%6d. Offset %d.  File channel offset (%d) not aligned.  Channel %d of\n        component %d.  Object id: %d  Class id: %d  Channel location: %d\n",
                  ++errcnt, objTable[oid].fp, *pp_chan, j, ii, oid, fil_classid,
                  ((objTable[oid].fp + 8) + component_list[ii].offset +
                  chan_info[j].offset));

#ifdef BIG_ENDIAN
               swapint(pp_chan, &tempint);
               *pp_chan = tempint;
#endif
               continue;
            }
            if (((*pp_chan + (char *) pp_chan) < p_object) ||
                ((*pp_chan + (char *) pp_chan) > (p_object + objSize)))
            {
               reportError("\n%6d. Offset %d.  Bad channel file offset (%d).  Channel %d of\n        component %d.  Object id: %d  Class id: %d  Channel location: %d\n",
                  ++errcnt, objTable[oid].fp, *pp_chan, j, ii, oid, fil_classid,
                  ((objTable[oid].fp + 8) + component_list[ii].offset +
                  chan_info[j].offset));

#ifdef BIG_ENDIAN
               swapint(pp_chan, &tempint);
               *pp_chan = tempint;
#endif
               continue;
            }
            if (((char *) p_chan < p_object) ||
                ((char *) p_chan > (p_object + objSize)))
            {
               reportError("\n%6d. Offset %d.  Bad channel file offset (%d).  Channel %d of\n        component %d.  Object id: %d  Class id: %d  Channel location: %d\n",
                  ++errcnt, objTable[oid].fp, p_chan, j, ii, oid, fil_classid,
                  ((objTable[oid].fp + 8) + component_list[ii].offset +
                  chan_info[j].offset));

#ifdef BIG_ENDIAN
               swapint(pp_chan, &tempint);
               *pp_chan = tempint;
#endif
               continue;
            }
            p_oid = 0;
            target_res_chan.number  = 0;
            target_res_chan.classid = 0;

#ifdef BIG_ENDIAN
            swapshort(&p_chan->flags, &tempshort);
            p_chan->flags = tempshort;
#endif

            if (p_chan->flags & OM_CH_singleton) {
               p_link = (OM_p_CHANNEL_LINK) p_chan;
               count = 1;
            }
            else {
               if (p_chan->flags & OM_CH_bigchan) {
                  p_link = (OM_p_CHANNEL_LINK)((OMuint)p_chan + 
                                               sizeof(OM_S_BIG_TAIL) + 
                                               sizeof(OM_S_CHANNEL_HDR));
                  p_tail = (OM_p_BIG_TAIL)((OMuint)p_chan + 
                                       sizeof(OM_S_CHANNEL_HDR));

#ifdef BIG_ENDIAN
                  swapint(&p_tail, &tempint);
                  count = ((OM_p_BIG_TAIL) tempint)->last_index;
#else
                  count = p_tail->last_index;
#endif

               }
               else {
                  p_link = (OM_p_CHANNEL_LINK)((OMuint)p_chan + 
                                               sizeof(OM_S_CHANNEL_HDR));

                  if (p_chan->flags & OM_CH_tail_exists)
                  {
                     if (p_chan->flags & OM_CH_bigchan)
                     {
                        tail = *((OM_p_BIG_TAIL) ((OMuint) (p_chan) +
                           sizeof(OM_S_CHANNEL_HDR)));
                     }
                     else
                     {
                        OMuword           link_size;
                        OM_p_LITTLE_TAIL  p_ltail;
                        if (p_chan->flags & OM_CH_restricted)
                           link_size = sizeof(OM_S_OBJID);
                        else
                           link_size = sizeof(OM_S_CHANNEL_LINK);

#ifdef BIG_ENDIAN
                        swapshort(&p_chan->u1.count, &tempshort);
                        p_chan->u1.count = tempshort;
#endif

                        p_ltail = ((OM_p_LITTLE_TAIL) ((OMuint)
                           p_chan + sizeof(OM_S_CHANNEL_HDR) +
                           (p_chan->u1.count - 1) * link_size));

#ifdef BIG_ENDIAN
                        swapshort(&p_chan->u1.count, &tempshort);
                        p_chan->u1.count = tempshort;
#endif

                        tail.last_index = p_ltail->last_index;
                     }
                     count = tail.last_index;
                  }
                  else {
                     count = p_chan->u1.count;
                  }
               }

#ifdef BIG_ENDIAN
               swapshort(&count, &tempshort);
               count = tempshort;
#endif
            }
         }

#ifdef BIG_ENDIAN
         swapint(pp_chan, &tempint);
         *pp_chan = tempint;
#endif
         /*===========================================*/
         /* now send the channel info off to the main */
         /* validation function                       */
         /*===========================================*/

         channum.classid = component_list[ii].classid;
         channum.number  = j;

#ifdef DEBUG
printf("   channum.classid: %d  channum.number: %d\n",
	channum.classid, j);
#endif
  
         if (!dros_val_chan (p_oid, p_link, count, target_res_chan,
                              oid, channum))
         {
            /* error should have been reported already */

#ifdef BIG_ENDIAN
            swapshort(&count, &tempshort);
            count = tempshort;
#endif

            return(0);
         }

#ifdef BIG_ENDIAN
         swapshort(&count, &tempshort);
         count = tempshort;
#endif

      }
   }
   return(1);
}


int dros_val_chan ( p_oid, p_link, count, target_res_chan, my_oid, 
                    my_channum )
OM_p_OBJID         p_oid;
OM_p_CHANNEL_LINK  p_link;
OMuint             count;
OM_S_CHANNUM       target_res_chan;
OM_S_OBJID         my_oid;
OM_S_CHANNUM       my_channum;
{
   OMuint             i, oid;
   OMuword            flags;
   OM_S_CHANNUM       channum;

#ifdef BIG_ENDIAN
   OMuint             tempint;
   short              tempshort;
#endif

   /*=======================*/
   /* loop for each linkage */
   /*=======================*/

   for ( i=0; i<count; ++i ) {
      if (p_oid) {
         oid     = p_oid[i];

#ifdef BIG_ENDIAN
         swapint(&oid, &tempint);
         oid = tempint;
#endif

         channum = target_res_chan;
         flags   = OM_CL_to_object;
      }
      else {
         oid     = p_link[i].objid;
         channum = p_link[i].channum;
         flags   = p_link[i].hdr.flags;

#ifdef BIG_ENDIAN
         swapint(&oid, &tempint);
         oid = tempint;
         swapshort(&channum.classid, &tempshort);
         channum.classid = tempshort;
         swapshort(&channum.number, &tempshort);
         channum.number = tempshort;
         swapshort(&flags, &tempshort);
         flags = tempshort;
#endif

      }

      if (IF_NULL_OBJID(oid)) continue;

      /*==================*/
      /* validate linkage */
      /*==================*/

      if ((oid > highOid) || !objTable[oid].classid) {
         reportError("\n%6d. Offset %d.  Invalid object id (%d) found on channel (%d,%d)\n        of object %d.  Channel index: %d.\n",
               ++errcnt, objTable[my_oid].fp, oid,
               my_channum.classid, my_channum.number, my_oid, i);
         continue;
      }

      if (flags & OM_CL_to_object) {
         if ((channum.classid > high_classid) || !oscobyid[channum.classid])
         {
            reportError("\n%6d. Invalid Channum (%d,%d) found on Oid %d Channum(%d,%d) index %d\n",
                    ++errcnt, channum.classid, channum.number, my_oid,
                    my_channum.classid, my_channum.number, i);
            continue;
         }

/*
         if (!dros_check_connect(my_oid,my_channum,oid,channum)) {
            printf("Connection invalid - Oid %d Channum (%d,%d)\n",
                    oid,channum.classid,channum.number);
            printf("          found on - Oid %d Channum (%d,%d) index %d\n",
                    my_oid,my_channum.classid,my_channum.number,i);
         }
*/
      }
/*
      else {
*/
         /*================*/
         /* ISO connection */
         /*================*/
/*

         iso_ndx = p_link[i].hdr.u1.isoindex;
         if (!dros_check_iso_connect(my_oid,oid,channum,iso_ndx)) {
           printf("ISO Connection invalid - ISOoid %d ISOindex %d\n",
                    oid,iso_ndx);
           printf("              found on - Oid %d Channum (%d,%d) index %d\n",
                    my_oid,my_channum.classid,my_channum.number,i);
         }
      }
*/
   }
   return(1);
}

/*=======================================================*
 *                                                       *
 *  detectHoles(beginfp, endfp, threshold, &checksum)    *
 *                                                       *
 *  Scan the file from beginfp through endfp, reporting  *
 *  sections of zeroes greater than threshold, and       *
 *  returning total number of zeroes found.              *
 *                                                       * 
 *=======================================================*/
int detectHoles(beginfp, endfp, threshold, checksum)
unsigned int   beginfp;
unsigned int   endfp;
int            threshold;
char           *checksum; /* Flag indicating whether or not to take checksum */
{
   int            bcount, size, ii, zeroes, zcount, fp;
   unsigned int   main_checksum;
   char           buffer[61440];

   if (beginfp >= os_size)
      return(0);
   if (endfp > os_size)
      endfp = os_size;
   main_checksum = 0;
   if (*checksum && (beginfp > OMFILEHDRSIZE))
   {
      fp = OMFILEHDRSIZE;
      fseek(osfp, OMFILEHDRSIZE, 0);
      bcount = beginfp - OMFILEHDRSIZE;
      while(bcount)
      {
         if (bcount > 61440)
            size = 61440;
         else
            size = bcount;
         if ((int) fread(buffer, 1, size, osfp) != size)
         {
            reportError("\n%6d. Error trying to read %d bytes at offset %d.\n        File location %d.\n",
               ++errcnt, size, fp, ftell(osfp));
            return(0);
         }
         bcount -= size;
         for (ii=0; ii<size; ii++, fp++)
            main_checksum += (unsigned char) buffer[ii] + fp;
      }
   }
   fseek(osfp, beginfp, 0);
   fp = beginfp;
   zeroes = zcount = 0;
   bcount = endfp - beginfp;
   while(bcount)
   {
      if (bcount > 61440)
         size = 61440;
      else
         size = bcount;
      if ((int) fread(buffer, 1, size, osfp) != size)
      {
         reportError("\n%6d. Error trying to read %d bytes at offset %d.\n        File location %d.\n",
            ++errcnt, size, beginfp, ftell(osfp));
         return(0);
      }
      bcount -= size;
      for (ii=0; ii<size; ii++, fp++)
      {
         main_checksum += (unsigned char) buffer[ii] + fp;
         if (buffer[ii] == 0x00)
            zcount++;
         else
         {
            if (zcount > 8)
            {
               zeroes += zcount;
               if (zcount >= threshold)
               {
                  reportError("\n%6d. Offsets %d-%d.  (Informational)  %d consecutive zeroes.\n",
                     ++errcnt, fp-zcount, fp, zcount);
               }
            }
            zcount = 0;
         }
      }
   }
   zeroes += zcount;
   if (zcount >= threshold)
   {
      reportError("\n%6d. Offsets %d-%d.  %d consecutive zeroes found.\n        File size is %d.  The last %d%% of the file is zeroes.\n",
         ++errcnt, (fp-zcount), fp, zcount, os_size, ((zcount*100)/os_size));
      fp -= zcount;
      if ((fp == 10240) || (fp == 272384)) /* Zeroes from page boundary */
         mode |= MINIMUM;
   }
   if (*checksum)
   {
      if (filehdr.checksum != main_checksum)
      {
         reportError("\n%6d. Offset %d.  File checksum in header (%d) is not valid.\n        Checksum is %d.\n",
            ++errcnt, ((int)&filehdr.checksum - topOfFilehdr),
            filehdr.checksum, main_checksum);
         *checksum = 0;
      }
   }
   return(zeroes);
}


/*===================================================================*
 *                                                                   *
 *  validateHdr(hdr)                                                 *
 *                                                                   *
 *  Validation of an OS header.  The file header is passed in as an  *
 *  argument so that in-memory (e.g., editted) copies of the file    *
 *  header may be verified as well as the original file header.      *
 *                                                                   *
 *===================================================================*/
validateHdr(hdr)
struct OM_sd_OS_filehdr_OM *hdr;
{
   unsigned int   checksum, ii, beginErrcnt;
   unsigned char  *buff;

   if (!hdr->hdr_checksum)
   {
      reportError("\n%6d. Offset %d.  The file header checksum is zero.\n",
         ++errcnt, ((int) &hdr->hdr_checksum - (int) hdr));
   }
   else
   {
      buff = (unsigned char *) hdr;
      for (ii=checksum=0; ii<434; ii++)
         checksum += buff[ii] + ii;
      if (checksum != hdr->hdr_checksum)
      {
         reportError("\n%6d. Offset %d.  Header checksum (%d) is not valid.\n        Checksum is %d.\n",
            ++errcnt, ((int) &hdr->hdr_checksum - (int) hdr),
            hdr->hdr_checksum, checksum);
      }
   }
   beginErrcnt = errcnt;
   if ((!hdr->w_major_version && !hdr->w_minor_version) &&
       hdr->write_msgstr[0])
   {
      reportError("\n%6d. An I/O error occurred while saving the file.  The file\n        was not completely written and is not retrievable.\n",
         ++errcnt);
      mode |= MINIMUM;
      return(0);           /* No use to verify rest of file header */
   }
   if (hdr->magic != OM_K_MAGIC)
   {
      reportError("\n%6d. Offset 0, File Header.  Invalid file magic number.\n",
         ++errcnt);
   }
   if (hdr->w_major_version != 2)
   {
      reportError("\n%6d. Offset %d, File Header.  Invalid OM Version: %d.%d.\n",
         ++errcnt, ((int) &hdr->w_major_version - (int) hdr),
         hdr->w_major_version, hdr->w_minor_version);
   }
   if (hdr->fp_appver)
   {
      int   appversize;
      appversize = OM_K_APPVER_LEN * hdr->i_num_appver;
      firstObjfp = hdr->fp_appver + (appversize + (512 - appversize % 512));
   }
   else
      firstObjfp = OMFILEHDRSIZE;
   if (os_size != hdr->i_size)
   {
      if (hdr->i_size > os_size)
         reportError("\n%6d. Offset %d, File Header.  Size field (%d) does not match the\n        actual size of the file (%d).  Difference is %d bytes.\n        File may have been truncated.\n",
            ++errcnt, ((int) &hdr->i_size - (int) hdr),
            hdr->i_size, os_size, (hdr->i_size-os_size));
      else
         reportError("\n%6d. Offset %d, File Header.  Size field (%d) does not match the\n        actual size of the file (%d).  Difference is %d bytes.\n",
            ++errcnt, ((int) &hdr->i_size - (int) hdr),
            hdr->i_size, os_size, (hdr->i_size-os_size));
   }
   if (hdr->fp_cluster0 > os_size)
   {
      reportError("\n%6d. Offset %d, File Header.  Cluster 0 file pointer (%d) is\n        beyond end of file.  Cluster 0 objects are not accessible.\n",
         ++errcnt, ((int) &hdr->fp_cluster0 - (int) hdr), hdr->fp_cluster0);
   }
   if (hdr->fp_OSO > os_size)
   {
      reportError("\n%6d. Offset %d, File Header.  OSO file pointer (%d) is beyond\n        the end of the file.  The OSO is unaccessible.\n",
         ++errcnt, ((int) &hdr->fp_OSO - (int) hdr), hdr->fp_OSO);
   }
   if (hdr->fp_OSO_instance > os_size)
   {
      reportError("\n%6d. Offset %d, File Header.  The OSO instance file pointer\n        (%d) is beyond end of file (%d).  The OSO is unaccessible.\n",
         ++errcnt, ((int) &hdr->fp_OSO_instance - (int) hdr),
         hdr->fp_OSO_instance, os_size);
   }
   if (hdr->fp_Cluster_instance > os_size)
   {
      reportError("\n%6d. Offset %d, File Header.  Cluster 0 instance file pointer (%d) is\n        beyond the end of the file (%d).  The OSO is unaccessible.\n",
         ++errcnt, ((int) &hdr->fp_Cluster_instance - (int) hdr),
         hdr->fp_Cluster_instance, os_size);
   }
   if (hdr->fp_Cluster_instance > hdr->fp_OSO_instance)
   {
      reportError("\n%6d. Offset %d, File Header.  The Cluster 0 instance pointer is\n        beyond the OSO instance pointer.  The OSO is corrupt and the file\n        is not retrievable.\n",
         ++errcnt, ((int) &hdr->fp_Cluster_instance - (int) hdr),
         hdr->fp_OSO_instance);
   }
   if (hdr->fp_Cluster_instance > hdr->fp_OSO+16)
   {
      reportError("\n%6d. Offset %d, File Header.  OSO file pointer (%d) is inconsistent\n        with the pointer to the Cluster 0 instance (%d).\n",
         ++errcnt, ((int) &hdr->fp_OSO - (int) hdr),
         hdr->fp_OSO, hdr->fp_Cluster_instance);
   }
   if (hdr->fp_OSO_instance > hdr->fp_OSO+80)
   {
      reportError("\n%6d. Offset %d, File Header.  OSO file pointer (%d) is inconsistent\n        with the pointer to the OSO instance (%d).\n",
         ++errcnt, ((int) &hdr->fp_OSO - (int) hdr),
         hdr->fp_OSO, hdr->fp_OSO_instance);
   }
   if (hdr->S_OS_object > hdr->i_spacemap_size)
   {
      reportError("\n%6d. Offset %d, File Header.  The OSO object id (%d) is larger than\n        the spacemap size (%d).  File is not retrievable.\n",
         ++errcnt, ((int) &hdr->S_OS_object - (int) hdr),
         hdr->S_OS_object, hdr->i_spacemap_size);
   }
   if (!(strlen(hdr->stop_time) == 25 && isalpha(hdr->stop_time[0]) &&
       isalpha(hdr->stop_time[1]) && isalpha(hdr->stop_time[2]) &&
       (hdr->stop_time[3] == ' ') && isalpha(hdr->stop_time[4]) &&
       isalpha(hdr->stop_time[5]) && isalpha(hdr->stop_time[6]) &&
       (hdr->stop_time[7] == ' ') && (isdigit(hdr->stop_time[8]) ||
       (hdr->stop_time[8] == ' ')) &&
       isdigit(hdr->stop_time[9]) && (hdr->stop_time[10] == ' ') &&
       isdigit(hdr->stop_time[11]) && isdigit(hdr->stop_time[12]) &&
       (hdr->stop_time[13] == ':') && isdigit(hdr->stop_time[14]) &&
       isdigit(hdr->stop_time[15]) && (hdr->stop_time[16] == ':') &&
       isdigit(hdr->stop_time[17]) && isdigit(hdr->stop_time[18]) &&
       (hdr->stop_time[19] == ' ') && isdigit(hdr->stop_time[20]) &&
       isdigit(hdr->stop_time[21]) && isdigit(hdr->stop_time[22]) &&
       isdigit(hdr->stop_time[23])))
   {
      reportError("\n%6d. Offset %d, File Header.  End-of-write timestamp is not valid: <%s>.\n",
         ++errcnt, ((int) hdr->stop_time - (int) hdr),
         hdr->stop_time);
   }
   if ((errcnt == beginErrcnt) && !(mode & MINIMUM))
   {
      OSflags |= HEADERVALID;
      return(1);
   }
   else
      return(0);
}


/*============================================================*
 *                                                            *
 *  walkObjects(beginfp, endfp)                               *
 *                                                            *
 *  Walk the file between the given beginning file pointer    *
 *  and the end file pointer, checking the size field of      *
 *  object headers for each object.  Report strange sizes     *
 *  and read errors.  Gets count of objects in object space.  *
 *                                                            * 
 *============================================================*/
OMuint walkObjects(beginfp, endfp)
int   beginfp;
int   endfp;
{
   int      objsize, fp;
   OMuint   numObjs = 0;

   if (!beginfp)
      beginfp = OMFILEHDRSIZE;
   fseek(osfp, beginfp + 12, 0);
   fp = ftell(osfp);

   /*=============================================================*/
   /* Step through object headers of the file as far as possible, */
   /* counting objects and verifying their size fields.           */
   /*=============================================================*/
   while (fp < endfp)
   {
      unsigned int   size;

      if (fread(&size, 1, 4, osfp) != 4)
      {
         reportError("\n%6d. Offset %d.  Error reading %dth object header after offset %d.\n",
            ++errcnt, fp, numObjs+1, beginfp);
         return(0);
      }

#ifdef BIG_ENDIAN
      swapint(&size, &objsize);
      size = objsize;
#endif

      if (((objsize = (GETOBJSIZE(size)-12)) <= 0) ||
          ((objsize + fp) > endfp))
      {
         reportError("\n%6d. Offset %d.  Bad object size (%d) for %dth object from\n        offset %d.\n",
            ++errcnt, fp, size, numObjs+1, beginfp);
         return(0);
      }
      else        /* Found a good object header */
      {
         fp += objsize + 12;  /* Point to size field of next header */
         numObjs++;
         fseek(osfp, fp, 0);
      }
   }
   if (numObjs != filehdr.i_num_objs)
   {
      reportError("\n%6d. The count of objects found in the file (%d) does not\n        match the number recorded in the file header (%d).\n",
         ++errcnt, numObjs+1, filehdr.i_num_objs);
   }
   return(numObjs);
}


/*============================================================*
 *                                                            *
 *  validateObjSizes(cluster)                                 *
 *                                                            *
 *  Same as walkObjects, except that walks only the objects   *
 *  of a cluster and also checks the object size against the  *
 *  object's class size.                                      *
 *                                                            *
 *============================================================*/
int validateObjSizes(cluster)
struct OMCluster_instance  *cluster;
{
   int               objsize, fp, beginfp, endfp, numObjs = 0;
   unsigned int      *filed_oid;
   unsigned short    *filed_classid, cnum;
   OM_S_FILEOBJHDR   objHdr;

   beginfp = cluster->lcd.i_file_ptr;
   endfp = cluster->lcd.i_file_ptr + cluster->i_fil_byte_size;
   filed_oid = (unsigned int *) ((char *) &(cluster->i_filed_oid_list_descr.
      i_offset) + cluster->i_filed_oid_list_descr.i_offset);
   filed_classid = (unsigned short *) ((char *) &(cluster->
      w_filed_classid_list_descr.i_offset) +
      cluster->w_filed_classid_list_descr.i_offset);
   cnum = cluster->lcd.w_cluster_num;
   fseek(osfp, beginfp, 0);
   fp = ftell(osfp);

   /*=============================================================*/
   /* Step through object headers of the file as far as possible, */
   /* counting objects and verifying their size fields.           */
   /*=============================================================*/
   while (fp < endfp)
   {

#ifdef BIG_ENDIAN
      int      tempint;
      short    tempshort;
#endif

      if (fread(&objHdr, 1, sizeof(OM_S_FILEOBJHDR), osfp) !=
         sizeof(OM_S_FILEOBJHDR))
      {
         reportError("\n%6d. Offset %d, Cluster %d.  Error reading %dth object header.\n        Object id: %d  Class id: %d\n",
            ++errcnt, fp, cnum, numObjs+1, filed_oid[numObjs],
            filed_classid[numObjs]);
         return(0);
      }

#ifdef BIG_ENDIAN
      swapint(&objHdr.oid, &tempint);
      objHdr.oid = tempint;
      swapint(&objHdr.i_size, &tempint);
      objHdr.i_size = tempint;
      swapshort(&objHdr.classid, &tempshort);
      objHdr.classid = tempshort;
#endif

      if (objHdr.oid != filed_oid[numObjs])
      {
         reportError("\n%6d. Offset %d, Cluster %d.  Bad object id (%d) for %dth object.\n        Object id should be %d.  Class id: %d\n",
            ++errcnt, fp, cnum, objHdr.oid, numObjs+1, filed_oid[numObjs],
            filed_classid[numObjs]);
         return(0);
      }
      if (objHdr.classid != filed_classid[numObjs])
      {
         reportError("\n%6d. Offset %d, Cluster %d.  Bad class id (%d) for %dth object.\n        Class id should be %d.  Object id: %d\n",
            ++errcnt, fp, cnum, objHdr.classid, numObjs+1,
            filed_classid[numObjs], filed_oid[numObjs]);
         return(0);
      }
      if (((objsize = (GETOBJSIZE(objHdr.i_size))) <= 0) ||
         ((objsize + fp) > endfp))
      {
         reportError("\n%6d. Offset %d, Cluster %d.  Bad object size (%d) for %dth object.\n        Object id: %d  Class id: %d  Objects in cluster: %d\n",
            ++errcnt, fp, cnum, objHdr.i_size, numObjs+1, filed_oid[numObjs],
            filed_classid[numObjs], cluster->i_fil_num_objects);
         return(0);
      }
      else if (!oscobyid[filed_classid[numObjs]])
      {
         reportError("\n%6d. Offset %d, Cluster %d.  Invalid class id (%d) for %dth object.\n        Object id: %d\n",
            ++errcnt, fp, cnum, filed_classid[numObjs], numObjs+1,
            filed_oid[numObjs]);
         mode |= MINIMUM;
      }
      else if ((objsize - 8) < oscobyid[filed_classid[numObjs]]->component_size)
      {
         /* Oscos for super_para & GRgsmgr have incorrect component_size
          * due to MAXPATHLEN.  Need to ignore this error.  2.1 10/30/92
          */
         if (strcmp(oscobyid[filed_classid[numObjs]]->OSCO.s_name, "super_para") &&
            strcmp(oscobyid[filed_classid[numObjs]]->OSCO.s_name, "GRgsmgr"))
         {
            reportError("\n%6d. Offset %d, Cluster %d.  Object size (%d) for %dth object is\n        too small for its class.  Object id: %d  Class id: %d\n",
               ++errcnt, fp, cnum, objHdr.i_size, numObjs+1, filed_oid[numObjs],
               filed_classid[numObjs]);
            mode |= MINIMUM;
         }
      }
      fp += objsize;
      numObjs++;
      fseek(osfp, fp, 0);
   }
   return(numObjs);
}


/*======================================*
 *                                      *
 *  validateOSO(OSO, size, hdr)         *
 *                                      *
 *  Validates the object space object.  *
 *                                      * 
 *======================================*/
validateOSO(OSO, size, hdr)
struct OMObjSpace_instance *OSO;
int                        size;
struct OM_sd_OS_filehdr_OM *hdr;
{
   int               fp;
   OMuint            ii, jj, count;
   struct OM_sd_OSD  *OSD;
   struct OShole     *OS_holes;
   OM_p_CHANNEL_HDR  to_ClusDscs, to_OSCOs, to_GrpDscs;
   OM_p_CHANNEL_LINK link;
   OM_S_BIG_TAIL     tail;

   for (ii=0; ii<12; ii++)
   {
      if (isdigit(OSO->CreTimeDate[ii]))
         continue;
      else
      {
         reportError("\n%6d. OSO.  Invalid creation date timestamp: <%s>.\n",
            ++errcnt, OSO->CreTimeDate);
         break;               /* Continue checking oso */
      }
   }
   if (OSO->p_filehdr)       /* File header is always at offset 0 */
   {
      reportError("\n%6d. OSO.  Invalid file header offset: %d.  Should be 0.\n",
         ++errcnt, OSO->p_filehdr);
   }
   OSD = &OSO->OSD;
   if (strlen(OSD->InternalName) > OM_K_MAXOSNAME_LEN)
   {
      reportError("\n%6d. OSO.  Internal OS name larger than maximum length allowed (%d).\n        Internal Name: <%s>\n",
         ++errcnt, OM_K_MAXOSNAME_LEN, OSD->InternalName);
   }
   if (OSD->OSO_Oid != hdr->S_OS_object)
   {
      reportError("\n%6d. OSO.  Object id of OSO stored in file header (%d) does not\n        match that stored in the OSD (%d).\n",
         ++errcnt, hdr->S_OS_object, OSD->OSO_Oid);
   }
   if (OSD->Group0_Oid != 1)
   {
      reportError("\n%6d. OSO.  Invalid Group 0 object id in the OSD: %d.  Should be 1.\n",
         ++errcnt, OSD->Group0_Oid);
   }
   if (OSD->type != OM_OSD_filed)
   {
      reportError("\n%6d. OSO.  Invalid object space type in the OSD %d.  Should be 3.\n",
         ++errcnt, OSD->type);
   }
   if (OSD->flags & OM_OSD_nowrite)
   {
      reportError("\n%6d. OSO.  Invalid flags in the OSD: %d.\n", ++errcnt, OSD->flags);
   }
   if (OSD->CurSpaceMapSize != hdr->i_spacemap_size)
   {
      reportError("\n%6d. OSO.  Spacemap size in the OSD (%d) does not match that in the\n        file header (%d).\n",
         ++errcnt, OSD->CurSpaceMapSize, hdr->i_spacemap_size);
   }
   if (OSD->ClustersSize < hdr->w_num_clusters)
   {
      reportError("\n%6d. OSO.  ClustersSize size in the OSD (%d) is too small.\n",
         ++errcnt, OSD->ClustersSize);
   }
   if ((int) OSO->OS_holes_descr.i_count < 0)
   {
      reportError("\n%6d. OSO.  Invalid file hole count in OSO: %d.\n",
         ++errcnt, OSO->OS_holes_descr.i_count);
   }
   OS_holes = (struct OShole *) (OSO->OS_holes_descr.i_offset + 
      (char *) &OSO->OS_holes_descr.i_offset);
   for (fp=ii=0; ii<OSO->OS_holes_descr.i_count; fp=OS_holes[ii].FilePtr,ii++)
   {
      if ((int) OS_holes[ii].FilePtr < fp)
      {
         reportError("\n%6d. OSO.  Fileptr field of %dth entry in OSO file hole list\n        is invalid.  Fileptr=%d, Size=%d.\n",
            ++errcnt, ii, OS_holes[ii].FilePtr, OS_holes[ii].size);
         break;
      }
      if (OS_holes[ii].size == (unsigned int) -1)
         break;
      if (OS_holes[ii].size != (OS_holes[ii+1].FilePtr - OS_holes[ii].FilePtr))
      {
         reportError("\n%6d. OSO.  Size field of %dth entry in file hole list is invalid.\n        FilePtr: %d, Size: %d.\n",
            ++errcnt, ii, OS_holes[ii].FilePtr, OS_holes[ii].size);
         break;
      }
   }

   if (count = oso->iso_d_descr.i_count)
   {
      iso_dir = (struct ISOd_data *) (oso->iso_d_descr.i_offset +
         (char *) &oso->iso_d_descr.i_offset);
      for (ii=0; ii<count; ii++)
         if (iso_dir[ii].s_int_os_name[0])
            iso_count++;
      if (!(iso = (struct OMISO_instance **) om$malloc(size=4 * iso_count)))
      {
         fprintf(stdout, "Cannot allocate %d bytes for iso object list.\n",
            4 * iso_count);
         mode |= MINIMUM;
         return(0);
      }
      if (!(iso_oid = (unsigned int *) om$malloc(size=4 * iso_count)))
      {
         fprintf(stdout, "Cannot allocate %d bytes for iso object list.\n",
            4 * iso_count);
         mode |= MINIMUM;
         return(0);
      }
      for (ii=jj=0; ii<count; ii++)
         if (iso_dir[ii].s_int_os_name[0])
         {
            iso_oid[jj] = iso_dir[ii].iso_u.s_objid;
            jj++;
         }
   }

   if ((oso->to_OSCOs > size) || (oso->to_OSCOs <= 0))
   {
      reportError("\n%6d. OSO.  Bad file offset for to_OSCOs channel.  OSCO objects\n        are inaccessible.  to_OSCOs offset: %d\n        OSO file offset: %d   File size: %d\n",
         ++errcnt, oso->to_OSCOs, hdr->fp_OSO_instance, os_size);
      mode |= MINIMUM;
   }
   if ((oso->to_ClusDscs > size) || (oso->to_ClusDscs <= 0))
   {
      reportError("\n%6d. OSO.  Bad file offset for to_ClusDscs channel.  Clusters\n        cannot be faulted in.  to_ClusDscs offset: %d\n        OSO file offset: %d   File size: %d\n",
         ++errcnt, oso->to_ClusDscs, hdr->fp_OSO_instance, os_size);
      mode |= MINIMUM;
   }
   if ((oso->to_GrpDscs > size) || (oso->to_GrpDscs <= 0))
   {
      reportError("\n%6d. OSO.  Bad file offset for to_GrpDscs channel.  Group\n        objects are inaccessible.  to_GrpDscs offset: %d\n        OSO file offset: %d   File size: %d\n",
         ++errcnt, oso->to_GrpDscs, hdr->fp_OSO_instance, os_size);
   }
   if ((oso->to_NamObjDir > size) || (oso->to_NamObjDir < 0))
   {
      reportError("\n%6d. OSO.  Bad file offset for to_NamObjDir channel.\n        to_NamObjDir offset: %d  OSO file offset: %d   File size: %d.\n",
         ++errcnt, oso->to_NamObjDir, hdr->fp_OSO_instance, os_size);
   }

   to_OSCOs = (OM_p_CHANNEL_HDR) ((char *) &oso->to_OSCOs + oso->to_OSCOs);
   if (to_OSCOs->flags & OM_CH_tail_exists)
   {
      OM_GET_TAIL(to_OSCOs, tail);
      count = tail.last_index;
   }
   else
      count = to_OSCOs->u1.count;
   link = (OM_p_CHANNEL_LINK)
      ((char *) to_OSCOs + sizeof(OM_S_CHANNEL_HDR));
   for (osco_count=ii=0; ii<count; ii++)
   {
      if (link[ii].objid == 0xffffffff)
         continue;
      if (link[ii].objid > OSD->CurSpaceMapSize)
      {
         reportError("\n%6d. OSO.  Invalid object id on OSO->to_OSCOs[%d]: %d.\n        Class data structures are corrupt.\n",
            ++errcnt, ii, link[ii].objid);
         mode |= MINIMUM;
      }
      else
         osco_count++;
   }
   to_ClusDscs = (OM_p_CHANNEL_HDR) ((char *) &oso->to_ClusDscs +
      oso->to_ClusDscs);
   if (to_ClusDscs->flags & OM_CH_tail_exists)
   {
      OM_GET_TAIL(to_ClusDscs, tail);
      highCnum = tail.last_index;
   }
   else
      highCnum = to_ClusDscs->u1.count;
   link = (OM_p_CHANNEL_LINK)
      ((char *) to_ClusDscs + sizeof(OM_S_CHANNEL_HDR));
   for (cluster_count=ii=jj=0; ii<highCnum; ii++)
   {
      if (link[ii].objid == 0xffffffff)
         continue;
      if (link[ii].objid > OSD->CurSpaceMapSize)
      {
         reportError("\n%6d. OSO.  Invalid object id on OSO->to_ClusDscs[%d]: %d.\n        Cluster data structures are corrupt.\n",
            ++errcnt, ii, link[ii].objid);
         mode |= MINIMUM;
      }
      else
      {
         cluster_count++;
         jj = ii;
      }
   }
   highCnum = jj;
   if (cluster_count < hdr->w_num_clusters)
   {
      reportError("\n%6d. OSO.  The number of cluster objects on the OSO->to_ClusDscs\n        channel (%d) is less than the number of clusters written (%d).\n",
         ++errcnt, cluster_count, hdr->w_num_clusters);
   }
   to_GrpDscs = (OM_p_CHANNEL_HDR) ((char *) &oso->to_GrpDscs +
      oso->to_GrpDscs);
   if (to_GrpDscs->flags & OM_CH_tail_exists)
   {
      OM_GET_TAIL(to_GrpDscs, tail);
      count = tail.last_index;
   }
   else
      count = to_GrpDscs->u1.count;
   link = (OM_p_CHANNEL_LINK)
      ((char *) to_GrpDscs + sizeof(OM_S_CHANNEL_HDR));
   for (group_count=ii=0; ii<count; ii++)
   {
      if (link[ii].objid == 0xffffffff)
         continue;
      if (link[ii].objid > OSD->CurSpaceMapSize)
      {
         reportError("\n%6d. OSO.  Invalid object id on OSO->to_GrpDscs[%d]: %d.\n        Group data structures are corrupt.\n",
            ++errcnt, ii, link[ii].objid);
      }
      else
         group_count++;
   }
   return(1);
}


/*=============================================================*
 *                                                             *
 *  validateCluster0(cluster, size, hdr)                       *
 *                                                             *
 *  Validates the OSO, the Cluster 0 object, the Meta-objects  *
 *  in Cluster 0, and the file header fields pertaining to     *
 *  Cluster 0.  The cluster argument could be a pointer to     *
 *  a copy of the file version of Cluster 0 or an editted      *
 *  Cluster 0.  Same for the file header.                      *
 *                                                             * 
 *=============================================================*/
validateCluster0(clust, size, hdr)
struct OMCluster_instance  *clust;
int                        size;
struct OM_sd_OS_filehdr_OM *hdr;
{
   char      osoValid, clust0Valid;

   /*==========================================================*/
   /*  check for mismatch of OSO object id  -- should be zero  */
   /*==========================================================*/

   if (clust->oid != hdr->S_OS_object) {
      reportError("\n%6d. OSO object id mismatch -- Instance oid:%d, hdr oid:%d\n",
         ++errcnt, clust->oid, hdr->S_OS_object);
      mode |= MINIMUM;
      return(0);              /* ERROR RETURN */
   }

   oso = (struct OMObjSpace_instance *) ((char *) clust +
      sizeof(struct OMCluster_instance));
   if (!(osoValid = (validateOSO(oso, size, hdr)) ? 1 : 0))
      oso = NULL;
   clust0Valid = (validateCluster(clust0, size, hdr->fp_OSO)) ? 1 : 0;
   return(1);
}


/*============================================================*
 *                                                            *
 *  validateCluster(clust, size, fp)                          *
 *                                                            *
 *  Validates a cluster object given the pointer to the       *
 *  cluster object and its size.                              *
 *                                                            * 
 *============================================================*/
validateCluster(clust, size, fp)
struct OMCluster_instance  *clust;
int                        size, fp;
{
   OMuint         beginErrcnt;
   OMuword        cnum;
   struct _to_OSO *toOSOchan;

   beginErrcnt = errcnt;
   cnum = clust->lcd.w_cluster_num;

   if (verbose)
      fprintf(stdout, "\n ++++ Validating the cluster object for Cluster %d at offset %d. ++++\n", cnum, fp);
   if (((short) cnum < 0) || (cnum > highCnum))
   {
      reportError("\n%6d. Offset %d.  Cluster number (%d) is incorrect.\n",
         ++errcnt, fp, cnum);
      mode |= MINIMUM;
      return(0);              /* ERROR RETURN */
   }

   if (!((clust->i_fil_num_objects == clust->i_filed_oid_list_descr.
       i_count) && (clust->i_fil_num_objects == clust->
       w_filed_classid_list_descr.i_count)))
   {
      reportError("\n%6d. Cluster %d.  Object count field is incorrect.\n        Filed object ids: %d  Filed class ids: %d  Object count: %d\n",
         ++errcnt, cnum, clust->i_filed_oid_list_descr.i_count, clust->
         w_filed_classid_list_descr.i_count, clust->i_fil_num_objects);
   }
   if ((clust->lcd.i_file_ptr == 0) && (clust->i_fil_byte_size == 0)
      && (clust->i_fil_num_objects == 0))
   {
      reportError("\n%6d. Cluster %d, Offset %d.  Cluster object for empty cluster found.\n",
         ++errcnt, cnum, fp);
      beginErrcnt++;
   }
   else
   {
      if ((clust->lcd.i_file_ptr < 512) || (clust->lcd.i_file_ptr > os_size))
      {
         reportError("\n%6d. Cluster %d, Offset %d.  Cluster file pointer (%d) is incorrect.\n",
            ++errcnt, cnum, fp, clust->lcd.i_file_ptr);
         mode |= MINIMUM;
         return(0);              /* ERROR RETURN */
      }
      if (clust->i_fil_num_objects && (clust->i_fil_byte_size <= 0))
      {
         reportError("\n%6d. Cluster %d.  Size (%d) is incorrect.  The\n        cluster should hold %d objects.\n",
            ++errcnt, cnum, clust->i_fil_byte_size, clust->i_fil_num_objects);
      }
      if ((clust->i_fil_byte_size + clust->lcd.i_file_ptr) > os_size)
      {
         reportError("\n%6d. Cluster %d.  Cluster size (%d) extends beyond end of file.\n",
            ++errcnt, cnum, clust->i_fil_byte_size);
      }
   }

   if (clust->to_OSO > (OMuint) size)
   {
      reportError("\n%6d. Cluster %d.  Bad file offset for to_OSO channel: %d.\n",
         ++errcnt, cnum, clust->to_OSO);
   }

   toOSOchan = (struct _to_OSO *) ((int) &clust->to_OSO + clust->to_OSO);

   if (toOSOchan->flags != (unsigned short)
       (OM_CH_full | OM_CH_m_1 | OM_CH_singleton | 0x0100))
   {
      reportError("\n%6d. Offset %d, Cluster %d.  to_OSO flags field (%d) should be %d.\n",
         ++errcnt, fp, cnum, toOSOchan->flags,
         (OM_CH_full|OM_CH_m_1|OM_CH_singleton|0x0100));
   }
   if (toOSOchan->count)
   {
      reportError("\n%6d. Offset %d, Cluster %d.  to_OSO count field (%d) should be zero.\n",
         ++errcnt, fp, cnum, toOSOchan->count);
   }
   if (toOSOchan->classid != OM_K_OMOBJSPACE_ACTCLASSID)
   {
      reportError("\n%6d. Offset %d, Cluster %d.  to_OSO classid field (%d)\n        should be %d.\n",
         ++errcnt, fp, cnum, toOSOchan->classid, OM_K_OMOBJSPACE_ACTCLASSID);
   }
   if (toOSOchan->number != 1)
   {
      reportError("\n%6d. Offset %d, Cluster %d.  to_OSO number field (%d) should be 1.\n",
         ++errcnt, fp, cnum, toOSOchan->number);
   }
   if (toOSOchan->oid)
   {
      reportError("\n%6d. Offset %d, Cluster %d.  to_OSO oid field (%d)\n        should be zero.\n",
         ++errcnt, fp, cnum, toOSOchan->oid);
   }
   if (cnum)
   {
      if ((clust->lcd.oid <= 0) || (clust->lcd.oid > filehdr.i_spacemap_size))
      {
         reportError("\n%6d. Cluster %d.  Object id (%d) is not a valid object id.\n",
            ++errcnt, cnum, clust->lcd.oid);
      }
   }
   else if (clust->lcd.oid)
   {
      reportError("\n%6d. Cluster 0.  Object id (%d) is incorrect.\n",
         ++errcnt, clust->lcd.oid);
   }
   if (beginErrcnt != errcnt)
      return(0);
   return(1);
}


void blkmove(size, inbuf, outbuf)
unsigned int   size;
char           *inbuf, *outbuf;
{
   OMuint   ii;
   for (ii=0; ii<size; ii++)
      *outbuf++ = *inbuf++;
}



/*============================================================*
 *                                                            *
 *  sortByFp()                                                *
 *                                                            *
 *  Sort cluster objects by the file pointer to the actual    *
 *  clusters.  We will have 3 arrays of pointers to cluster   *
 *  objects: cluster (cluster objects in the order they occur *
 *  in Cluster 0), clustbyid (cluster objects in order of     *
 *  their cluster numbers) and clustbyfp (cluster objects in  *
 *  order their clusters were written to file).               *
 *                                                            *
 *============================================================*/
void sortByFp()
{
   OMuint   ii, jj, kk;
   clustbyfp[0] = cluster[0];
   for (ii=1; ii<cluster_count; ii++)
   {
      for (jj=0; jj < ii; jj++)
      {
         if (cluster[ii]->lcd.i_file_ptr < clustbyfp[jj]->lcd.i_file_ptr)
         {
            for (kk=ii; kk>jj; kk--)
               clustbyfp[kk] = clustbyfp[kk-1];
            break;
         }
      }
      clustbyfp[jj] = cluster[ii];
   }
}


/*============================================================*
 *                                                            *
 *  validateTagVla()                                          *
 *                                                            *
 *  Validates the entries in the Tag record after the         *
 *  objTable structure has been set up                        *
 *                                                            *
 *============================================================*/
void validateTagVla()
{
   struct tagNode *p;
   unsigned int   ii, oid;

   /* Build the tag tree, leave out duplicate entries for same oid */

   for (ii=0; ii<tagRec->tag_rec_descr.i_count; ++ii)
   {
      unsigned int   oid;
      struct tagNode *entry;

      if ((oid = tagVla[ii].objid) == 0xffffffff)
         continue;

      if (oid > highOid)
      {
         tagVla[ii].objid = 0xffffffff;
         addLink(&endOfTagRemoveEntryList, ii);
         reportError("\n%6d. Tag Record.  Bad object id stored in Tag Record.\n        Entry: %d  Object id: %d  Tag: %d  Version: %d\n",
            ++errcnt, ii, oid, tagVla[ii].tag, tagVla[ii].version);
         continue;
      }
      if (!(objTable[oid].classid))
      {
         tagVla[ii].objid = 0xffffffff;
         addLink(&endOfTagRemoveEntryList, ii);
         reportError("\n%6d. Tag Record.  Entry found for a non-existent object.\n        Entry: %d  Object id: %d  Tag: %d  Version: %d\n",
            ++errcnt, ii, oid, tagVla[ii].tag, tagVla[ii].version);
         continue;
      }
      if (objTable[oid].classid < 64)
      {
         tagVla[ii].objid = 0xffffffff;
         addLink(&endOfTagRemoveEntryList, ii);
         reportError("\n%6d. Tag Record.  Entry found for a non-taggable object.\n        Entry: %d  Object id: %d  Class id: %d  Tag: %d  Version: %d\n",
            ++errcnt, ii, oid, objTable[oid].classid, tagVla[ii].tag, tagVla[ii].version);
         continue;
      }

      if (!(entry = (struct tagNode *) lookupTag(&tagTree, oid)))
      {
         addToTagTree((struct OM_sd_tag_record *) &tagVla[ii], ii);
      }
      else
      {
         /* A tag entry for this oid has already been found and added
          * to the AVL tree.  Clear one or the other of the entries.
          */

         reportError("\n%6d. Offset %d, Tag array.  Multiple tag entries for object id %d.\n        Tag ids %d (at offset %d) and %d.\n",
            ++errcnt, tagVlaOffset + (ii * tagSize), oid, entry->entry,
            tagVlaOffset + (entry->index * tagSize), tagVla[ii].tag);

         if (((tagVla[ii].tag == objTable[oid].tag) &&
             (entry->entry == objTable[oid].tag)) ||
            ((tagVla[ii].tag != objTable[oid].tag) &&
             (entry->entry != objTable[oid].tag)))
         {
            /* Either the tag id in objTable matches the tag id in
             * both entries or it doesn't match either's tag id.
             * Keep the entry with the most reasonable version.
             */
            if (tagVla[ii].version & 0x8000)
            {
               /* Current guy looks corrupt.  Keep the guy already in tree. */

               tagVla[ii].objid = 0xffffffff;
               addLink(&endOfTagRemoveEntryList, ii);
            }
            else
            {
               /* Replace the old guy with the current guy */

               tagVla[entry->index].objid = 0xffffffff;
               addLink(&endOfTagRemoveEntryList, entry->index);
               entry->index = ii;
               entry->entry = tagVla[ii].tag;
            }
         }
         else
         {
            /* The tag id matched only one of the entries' tag ids. */

            if (tagVla[ii].tag == objTable[oid].tag)
            {
               /* Replace the guy already in the tree with the
                * current guy.
                */

               tagVla[entry->index].objid = 0xffffffff;
               addLink(&endOfTagRemoveEntryList, entry->index);
               entry->index = ii;
               entry->entry = tagVla[ii].tag;
            }
            else
            {
               /* Keep the guy already in the tree. */

               tagVla[ii].objid = 0xffffffff;
               addLink(&endOfTagRemoveEntryList, ii);
            }
         }
      }
   }

   for (ii=0; ii<tagRec->tag_rec_descr.i_count; ++ii)
   {
      if ((oid = tagVla[ii].objid) == 0xffffffff)
         continue;
      if (tagVla[ii].tag >= tagRec->next_tag)
      {
         addLink(&endOfTagRemoveEntryList, ii);
         reportError("\n%6d. Tag Record.  Tag id is out of range.\n        Entry: %d  Object id: %d  Tag: %d  Version: %d\n",
            ++errcnt, ii, oid, tagVla[ii].tag, tagVla[ii].version);
         if ((p = (struct tagNode *) lookupTag(&tagTree, oid)) &&
            (p->index == ii))
         {
            objTable[oid].tag = 0;
            objTable[oid].version = 0;
            objTable[oid].size &= ~OM_OHf_is_tagged;
            addLink(&endOfTagFixHeaderList, oid);
         }
      }
      else if ((objTable[oid].tag != tagVla[ii].tag) ||
         (objTable[oid].version != tagVla[ii].version))
      {
         reportError("\n%6d. Tag Record.  Tag entry does not match object header.\n        Entry: %d  Object id: %d  Tag: %d  Version: %d\n",
            ++errcnt, ii, oid, tagVla[ii].tag, tagVla[ii].version);
         if (!(objTable[oid].size & OM_OHf_is_tagged))
         {
            addLink(&endOfTagRemoveEntryList, ii);
            objTable[oid].tag = 0;
            objTable[oid].version = 0;
         }
         else
         {
            addLink(&endOfTagFixHeaderList, oid);
            objTable[oid].tag = tagVla[ii].tag;
            objTable[oid].version = tagVla[ii].version;
            objTable[oid].size |= OM_OHf_is_tagged;
         }
      }
      else if (!(objTable[oid].size & OM_OHf_is_tagged))
      {
         addLink(&endOfTagRemoveEntryList, oid);
         reportError("\n%6d. Tag Record.  Entry found for a non-tagged object.\n        Entry: %d  Object id: %d  Tag: %d  Version: %d\n        Cluster id: %d  Class id: %d\n",
            ++errcnt, ii, oid, tagVla[ii].tag,
            tagVla[ii].version, objTable[oid].cluster_num,
            objTable[oid].classid);
      }
   }

   for (oid=1; oid<=highOid; oid++)
   {
      if ((objTable[oid].size & OM_OHf_is_tagged) &&
         !(p = lookupTag(&tagTree, oid)))
      {
         objTable[oid].tag = 0;
         objTable[oid].version = 0;
         objTable[oid].size &= ~OM_OHf_is_tagged;
         addLink(&endOfTagFixHeaderList, oid);
         reportError("\n%6d. Offset %d.  Tagged object not recorded in Tag Record.\n        Object id: %d  Cluster id: %d  Class id: %d.\n",
            ++errcnt, objTable[oid].fp, oid, objTable[oid].cluster_num,
            objTable[oid].classid);
      }
   }

}

/*============================================================*
 *                                                            *
 *  validateTag(Tag, size, fp)                                *
 *                                                            *
 *============================================================*/
validateTag(Tag, size, fp)
struct OMTag_instance   *Tag;
int                     size, fp;
{
   OMuint         beginErrcnt, ii;
   struct _to_OSO *toOSOchan;

   beginErrcnt = errcnt;
   if (verbose)
      fprintf(stdout, "\n ++++ Validating Tag object at offset %d. ++++\n", fp);
   if ((int) Tag->next_tag < 0)
   {
      reportError("\n%6d. Offset %d.  Tag object next_tag field (%d) is invalid.\n",
         ++errcnt, fp, Tag->next_tag);
   }
   if (Tag->num_tags > filehdr.i_spacemap_size)
   {
      reportError("\n%6d. Offset %d.  Tag object num_tags field (%d) is invalid.\n",
         ++errcnt, fp, Tag->num_tags);
   }
   if (Tag->next_index < 0)
   {
      reportError("\n%6d. Offset %d.  Tag object next_index field (%d) is invalid.\n",
         ++errcnt, fp, Tag->next_index);
   }
   if ((Tag->to_OSO <= 0) || (Tag->to_OSO > (OMuint) size))
   {
      reportError("\n%6d. Offset %d, Tag object.  Bad file offset for to_OSO channel: %d.\n",
         ++errcnt, fp, Tag->to_OSO);
   }

   toOSOchan = (struct _to_OSO *) ((int) &Tag->to_OSO + Tag->to_OSO);

   if (toOSOchan->flags != (unsigned short)
       (OM_CH_full | OM_CH_m_1 | OM_CH_singleton | 0x0100))
   {
      reportError("\n%6d. Offset %d, Tag object.  to_OSO flags field (%d) should be %d.\n",
         ++errcnt, fp, toOSOchan->flags,
         (OM_CH_full|OM_CH_m_1|OM_CH_singleton|0x0100));
   }
   if (toOSOchan->count)
   {
      reportError("\n%6d. Offset %d, Tag object.  to_OSO count field (%d) should be zero.\n",
         ++errcnt, fp, toOSOchan->count);
   }
   if (toOSOchan->classid != OM_K_OMOBJSPACE_ACTCLASSID)
   {
      reportError("\n%6d. Offset %d, Tag objects.  to_OSO classid field (%d) should be %d.\n",
         ++errcnt, fp, toOSOchan->classid, OM_K_OMOBJSPACE_ACTCLASSID);
   }
   if (toOSOchan->number != 2)
   {
      reportError("\n%6d. Offset %d, Tag object.  to_OSO number field (%d) should be 2.\n",
         ++errcnt, fp, toOSOchan->number);
   }
   if (toOSOchan->oid)
   {
      reportError("\n%6d. Offset %d, Tag object.  to_OSO oid field (%d) should be zero.\n",
         ++errcnt, fp, toOSOchan->oid);
   }
   tagVla = (struct OM_sd_tag_record *) ((char *)
      (&Tag->tag_rec_descr.i_offset) + Tag->tag_rec_descr.i_offset);
   tagVlaOffset = fp + Tag->tag_rec_descr.i_offset +
      ((int) ((char *) &Tag->tag_rec_descr.i_offset - (char *) &Tag->next_tag));
   tagSize = sizeof(struct OM_sd_tag_record);

   endOfTagFixHeaderList = &tagFixHeaderList;
   endOfTagRemoveEntryList = &tagRemoveEntryList;
   for (ii=tag_count=0; ii<Tag->tag_rec_descr.i_count; ++ii)
   {
      unsigned int   oid;

      if ((oid = tagVla[ii].objid) == 0xffffffff)
         continue;
      tag_count++;
   }
   if (tag_count != Tag->num_tags)
   {
      reportError("\n%6d. Offset %d, Tag object.  Number of entries in Tag object (%d)\n        does not match tag count in Tag object (%d).\n",
         ++errcnt, fp, tag_count, Tag->num_tags);
   }
   return((errcnt == beginErrcnt) ? 1 : 0);
}


/*============================================================*
 *                                                            *
 *  validateISO(ISO, size, fp)                                *
 *                                                            *
 *============================================================*/
validateISO(ISO, size, fp)
struct OMISO_instance   *ISO;
int                     size, fp;
{
   OMuint   beginErrcnt;

   beginErrcnt = errcnt;
   if (verbose)
      fprintf(stdout, "\n ++++ Validating ISO object at offset %d. ++++\n", fp);
   if ((short) ISO->osnum > 500)
   {
      reportError("\n%6d. Offset %d, ISO.  Object space number (%d) is invalid.\n",
         ++errcnt, fp, ISO->osnum);
   }
   if (ISO->w_ISO_flags && ISO->w_ISO_flags > 3)
   {
      reportError("\n%6d. Offset %d, ISO.  Invalid flags (%d).\n",
         ++errcnt, fp, ISO->w_ISO_flags);
   }
   if ((int) ISO->S_target_iso < 0)
   {
      reportError("\n%6d. Offset %d, ISO.  Target ISO (%d) is invalid.\n",
         ++errcnt, fp, ISO->S_target_iso);
   }
   if (ISO->i_first < 0)
   {
      reportError("\n%6d. Offset %d, ISO.  First available index (%d) is invalid.\n",
         ++errcnt, fp, ISO->i_first);
   }
   if (ISO->iso_d_descr.i_offset < 0 || ISO->iso_d_descr.i_offset > size ||
      (ISO->iso_d_descr.i_count && !ISO->iso_d_descr.i_offset))
   {
      reportError("\n%6d. Offset %d, ISO.  Invalid channel number.\n",
         ++errcnt, fp);
   }
   return((errcnt == beginErrcnt) ? 1 : 0);
}


/*============================================================*
 *                                                            *
 *  validateGroup(group, size, fp)                            *
 *                                                            *
 *============================================================*/

#argsused

validateGroup(group, size, fp)
struct OMGroup_instance  *group;
int                     size, fp;
{
   OMuint   beginErrcnt;

   beginErrcnt = errcnt;
   if (verbose)
      fprintf(stdout, "\n ++++ Validating group object at offset %d. ++++\n", fp);
   return( (errcnt != beginErrcnt) ? 0 : 1);
}


/*============================================================*
 *                                                            *
 *  validateRtree(rtree, size, fp)                            *
 *                                                            *
 *============================================================*/

#argsused

validateRtree(rtree, size, fp)
char  *rtree;
int   size, fp;
{
   OMuint   beginErrcnt;

   beginErrcnt = errcnt;
   if (verbose)
      fprintf(stdout, "\n ++++ Validating rtree object at offset %d. ++++\n", fp);
   return( (errcnt != beginErrcnt) ? 0 : 1);
}


/*============================================================*
 *                                                            *
 *  validateTagCon(TagCon, size, fp)                          *
 *                                                            *
 *============================================================*/

#argsused

validateTagCon(TagCon, size, fp)
struct OMTagCon_instance   *TagCon;
int                        size, fp;
{
   int                           found;
   OMuint                        beginErrcnt, ii;
   struct _to_OSO                *toOSOchan;
   struct OM_sd_connect_record   *con_rec;
   OMuword                       prev;
   struct TagConClass            *ptr, *pptr;

   if (verbose)
      fprintf(stdout, "\n ++++ Validating Tag Connect object at offset %d. ++++\n", fp);
   beginErrcnt = errcnt;
   if (TagCon->first_tag == 0xffff)
   {
      /* Empty TagCon case */

      if (TagCon->count)
      {
         reportError("\n%6d. Offset %d, TagCon.  TagCon count is %d, but\n        \"first_tag\" field shows it should be 0.\n",
            ++errcnt, fp, TagCon->count);
      }
      if (TagCon->first_free != 0xffff)
      {
         reportError("\n%6d. Offset %d, TagCon.  TagCon \"first_free\" is %d, but\n        \"first_tag\" field shows it should be -1.\n",
            ++errcnt, fp, TagCon->first_free);
      }
   }
   else
   {
      if (!TagCon->count)
      {
         reportError("\n%6d. Offset %d, TagCon.  \"count\" field is 0, but\n        should be %d.\n",
            ++errcnt, fp, TagCon->first_free - 1);
      }

      toOSOchan = (struct _to_OSO *) ((int) &TagCon->to_OSO + TagCon->to_OSO);

      if (toOSOchan->flags != (unsigned short)
          (OM_CH_full | OM_CH_m_1 | OM_CH_singleton | 0x0100))
      {
         reportError("\n%6d. Offset %d, TagCon.  to_OSO flags field (%d) should be %d.\n",
            ++errcnt, fp, toOSOchan->flags,
            (OM_CH_full|OM_CH_m_1|OM_CH_singleton|0x0100));
      }
      if (toOSOchan->count)
      {
         reportError("\n%6d. Offset %d, TagCon.  to_OSO count field (%d) should be zero.\n",
            ++errcnt, fp, toOSOchan->count);
      }
      if (toOSOchan->classid != OM_K_OMOBJSPACE_ACTCLASSID)
      {
         reportError("\n%6d. Offset %d, TagCon.  to_OSO classid field (%d) should be 4.\n",
            ++errcnt, fp, toOSOchan->classid);
      }
      if (toOSOchan->number != 2)
      {
         reportError("\n%6d. Offset %d, TagCon.  to_OSO number field (%d) should be 0.\n",
            ++errcnt, fp, toOSOchan->number);
      }
      if (toOSOchan->oid)
      {
         reportError("\n%6d. Offset %d, TagCon.  to_OSO oid field (%d) should be zero.\n",
            ++errcnt, fp, toOSOchan->oid);
      }

      if (!TagConClasses)
      {
         if (!(TagConClasses = (struct TagConClass *) som_malloc(sizeof(struct
            TagConClass))))
         {
            fprintf(stdout, "Could not allocate %d bytes.  Cannot continue validation.\n",
               sizeof(struct TagConClass));
            return(0);
         }
         TagConClasses->classid = 0;
         TagConClasses->next = NULL;
         TagConClasses->oid = TagCon->oid;
         TagConClasses->fp = fp;
      }
      
      con_rec = (struct OM_sd_connect_record *)
         ((int) &TagCon->con_rec_descr.i_offset +
         TagCon->con_rec_descr.i_offset);
      prev = 0xffff;
      for (ii=TagCon->first_tag; ii<TagCon->con_rec_descr.i_count;
         ii = con_rec[ii].next)
      {
         if (prev != con_rec[ii].prev)
         {
            reportError("\n%6d. Offset %d, TagCon.  Index of previous connect record\n        is invalid (%d).  Should be %d.\n",
               ++errcnt, fp, con_rec[ii].prev, prev);
         }
         ptr = TagConClasses;
         pptr = ptr;
         found = 0;
         while(ptr)
         {
            if (!ptr->classid)
            {
               ptr->classid = con_rec[ii].other_cnum.classid;
               ptr->count = 1;
               found = 1;
               break;
            }
            else if (ptr->classid == con_rec[ii].other_cnum.classid)
            {
               found = 1;
               ptr->count++;
               break;
            }
            pptr = ptr;
            ptr = ptr->next;
         }
         if (!found)
         {
            if (!(pptr->next = (struct TagConClass *) som_malloc(sizeof(struct
               TagConClass))))
            {
               fprintf(stdout, "Could not allocate %d bytes.  Cannot continue validation.\n",
                  sizeof(struct TagConClass));
               return(0);
            }
            ptr = pptr->next;
            ptr->classid = con_rec[ii].other_cnum.classid;
            ptr->count = 1;
            ptr->next = NULL;
            ptr->oid = TagCon->oid;
            ptr->fp = fp;
         }
         prev = ii;
         if (con_rec[ii].next == 0xffff)
            break;
      }
   }
   return( (errcnt != beginErrcnt) ? 0 : 1);
}


/*============================================================*
 *                                                            *
 *  validateOSCO(osco, size, fp)                              *
 *                                                            *
 *============================================================*/
validateOSCO(osco, size, fp)
struct OMOSCO_instance  *osco;
int                     size, fp;
{
   OMuint         beginErrcnt;
   struct _to_OSO *toOSOchan;

   beginErrcnt = errcnt;
   if (verbose)
      fprintf(stdout, "\n ++++ Validating class object <%s> at offset %d. ++++\n", osco->OSCO.s_name, fp);
   if ((short) osco->OSCO.w_classid < 0)
   {
      reportError("\n%6d. Offset %d, OSCO.  Class object contains an invalid class id (%d).\n",
         ++errcnt, fp, osco->OSCO.w_classid);
   }
   if (osco->OSCO.w_child_refcnt > filehdr.i_spacemap_size)
   {
      reportError("\n%6d. Offset %d, OSCO.  Class object contains an invalid child reference count (%d).\n",
         ++errcnt, fp, osco->OSCO.w_child_refcnt);
   }
   if (osco->OSCO.i_refcnt > filehdr.i_spacemap_size)
   {
      if (strcmp(osco->OSCO.s_name, "GRnotify") &&
          strcmp(osco->OSCO.s_name, "GRreffile"))
         reportError("\n%6d. Offset %d, OSCO.  Class object contains an invalid reference count (%d).\n",
            ++errcnt, fp, osco->OSCO.i_refcnt);
   }
   if (osco->OSCO.OSCO_oid > filehdr.i_spacemap_size)
   {
      reportError("\n%6d. Offset %d, OSCO.  Class object has an invalid oid (%d).\n",
         ++errcnt, fp, osco->OSCO.OSCO_oid);
   }

   toOSOchan = (struct _to_OSO *) ((int) &osco->to_OSO + osco->to_OSO);

   if (toOSOchan->flags != (unsigned short)
       (OM_CH_full | OM_CH_m_1 | OM_CH_singleton | 0x0100))
   {
      reportError("\n%6d. Offset %d, OSCO.  to_OSO flags field (%d) should be %d.\n",
         ++errcnt, fp, toOSOchan->flags,
         (OM_CH_full|OM_CH_m_1|OM_CH_singleton|0x0100));
   }
   if (toOSOchan->count)
   {
      reportError("\n%6d. Offset %d, OSCO.  to_OSO count field (%d) should be zero.\n",
         ++errcnt, fp, toOSOchan->count);
   }
   if (toOSOchan->classid != OM_K_OMOBJSPACE_ACTCLASSID)
   {
      reportError("\n%6d. Offset %d, OSCO.  to_OSO classid field (%d) should be %d.\n",
         ++errcnt, fp, toOSOchan->classid, OM_K_OMOBJSPACE_ACTCLASSID);
   }
   if (toOSOchan->number)
   {
      reportError("\n%6d. Offset %d, OSCO.  to_OSO number field (%d) should be 0.\n",
         ++errcnt, fp, toOSOchan->number);
   }
   if (toOSOchan->oid)
   {
      reportError("\n%6d. Offset %d, OSCO.  to_OSO oid field (%d) should be zero.\n",
         ++errcnt, fp, toOSOchan->oid);
   }
   if (osco->component_list_descr.i_offset < 0 ||
       osco->component_list_descr.i_offset > size ||
      (osco->component_list_descr.i_count &&
       !osco->component_list_descr.i_offset))
   {
      reportError("\n%6d. Offset %d, OSCO.  Invalid component list.\n",
         ++errcnt, fp);
   }
   if (osco->vla_list_descr.i_offset < 0 ||
       osco->vla_list_descr.i_offset > size ||
      (osco->vla_list_descr.i_count &&
       !osco->vla_list_descr.i_offset))
   {
      reportError("\n%6d. Offset %d, OSCO.  Invalid vla list.\n",
         ++errcnt, fp);
   }
   if (osco->chan_info_descr.i_offset < 0 ||
       osco->chan_info_descr.i_offset > size ||
      (osco->chan_info_descr.i_count &&
       !osco->chan_info_descr.i_offset))
   {
      reportError("\n%6d. Offset %d, OSCO.  Invalid channel information.\n",
         ++errcnt, fp);
   }
   if (osco->res_classname_descr.i_offset < 0 ||
       osco->res_classname_descr.i_offset > size ||
      (osco->res_classname_descr.i_count &&
       !osco->res_classname_descr.i_offset))
   {
      reportError("\n%6d. Offset %d, OSCO.  Invalid class name.\n",
         ++errcnt, fp);
   }
   if (osco->res_channum_descr.i_offset < 0 ||
       osco->res_channum_descr.i_offset > size ||
      (osco->res_channum_descr.i_count &&
       !osco->res_channum_descr.i_offset))
   {
      reportError("\n%6d. Offset %d, OSCO.  Invalid channel number.\n",
         ++errcnt, fp);
   }
   if (osco->component_size < 0 || osco->component_size > (int) os_size)
   {
      reportError("\n%6d. Offset %d, OSCO.  Component size (%d) is invalid.\n",
         ++errcnt, fp, osco->component_size);
   }
   if (osco->num_parents > filehdr.i_spacemap_size)
   {
      reportError("\n%6d. Offset %d, OSCO.  Number of parents (%d) is invalid.\n",
         ++errcnt, fp, osco->num_parents);
   }
   return( (errcnt != beginErrcnt) ? 0 : 1);
}

/*============================================================*
 *                                                            *
 *  validateClassRefcnt()                                     *
 *                                                            *
 *============================================================*/
void validateClassRefcnt()
{
   OMuword              ii;
   struct TagConClass   *ptr, *p;

   ptr = TagConClasses;
   while(ptr)
   {
      if ((ptr->classid > high_classid) || !oscobyid[ptr->classid])
      {
         reportError("\n%6d. Offset %d.  TagCon object (id %d) lists an invalid\n        class id (%d).\n",
            ++errcnt, ptr->fp, ptr->oid, ptr->classid);
      }
      else
         classRefcnt[ptr->classid] += ptr->count;
      p = ptr;
      ptr = ptr->next;
      som_dealloc((char *) p);
   }
   for (ii=0; ii<=high_classid; ii++)
   {
      if (classRefcnt[ii])
      {
         if (!oscobyid[ii])
         {
            reportError("\n%6d. No class object for class %d.  %d objects of this class found.\n",
               ++errcnt, ii, classRefcnt[ii]);
         }
         else if (oscobyid[ii]->OSCO.i_refcnt != classRefcnt[ii])
         {
            if (strcmp(oscobyid[ii]->OSCO.s_name, "GRreffile") &&
               strcmp(oscobyid[ii]->OSCO.s_name, "GRnotify"))
               reportError("\n%6d. %d objects of class <%s> (class id: %d) found,\n        but class object reference count is %d.\n",
                  ++errcnt, classRefcnt[ii], oscobyid[ii]->OSCO.s_name,
                  ii, oscobyid[ii]->OSCO.i_refcnt);
         }
      }
      else if (oscobyid[ii] && oscobyid[ii]->OSCO.i_refcnt &&
         oscobyid[ii]->OSCO.i_refcnt > oscobyid[ii]->OSCO.w_child_refcnt)
      {
         reportError("\n%6d. Class object reference count for class <%s> (class id: %d)\n        is %d, but no objects of this class found in the file.\n",
            ++errcnt, oscobyid[ii]->OSCO.s_name, ii,
            oscobyid[ii]->OSCO.i_refcnt);
      }
   }
}

/*============================================================*
 *                                                            *
 *  walkCluster0(c0)                                          *
 *                                                            *
 *============================================================*/
int walkCluster0(c0)
struct OMCluster_instance  *c0;
{
   unsigned int   ii, jj, count, *filed_oid, bufsize, numObjs, fp, endfp,
                  c_index, o_index, i_index, g_index, totalObjs, obj_count;
   unsigned short cnum, *filed_classid;
   char           *buf;

   tag = 0;             /* No tag object found so far */
   badTag = 0;
   high_classid = 0;
   TagConClasses = NULL;
   filed_oid = (unsigned int *) ((char *) &(c0->i_filed_oid_list_descr.
      i_offset) + c0->i_filed_oid_list_descr.i_offset);
   filed_classid = (unsigned short *) ((char *) &(c0->
      w_filed_classid_list_descr.i_offset) +
      c0->w_filed_classid_list_descr.i_offset);

   totalObjs = numObjs = c_index = o_index = i_index = g_index = 0;
   fp = c0->lcd.i_file_ptr;
   endfp = os_size;              /* Cluster 0 is always last cluster in file */
   fseek(osfp, fp, 0);
   buf = (char *) om$malloc(size=61440);
   bufsize = 61440;
   if (!(cluster = (struct OMCluster_instance **)
      om$calloc(num=cluster_count, size=4)))
   {
      fprintf(stdout, "Cannot allocate %d bytes for cluster object list.\n",
         4 * cluster_count);
      mode |= MINIMUM;
      return(0);
   }
   if (!(clustbyfp = (struct OMCluster_instance **)
      om$calloc(num=cluster_count, size=4)))
   {
      fprintf(stdout, "Cannot allocate %d bytes for cluster object list.\n",
         4 * cluster_count);
      mode |= MINIMUM;
      return(0);
   }
   if (!(clustbyid = (struct OMCluster_instance **)
       om$calloc(num=(highCnum+1), size=4)))
   {
      fprintf(stdout, "Cannot allocate %d bytes for cluster object list.\n",
         4 * (highCnum+1));
      mode |= MINIMUM;
      return(0);
   }
   if (!(oscobyfp = (struct OMOSCO_instance **)
      om$calloc(num=osco_count, size=4)))
   {
      fprintf(stdout, "Cannot allocate %d bytes for osco object list.\n",
         4 * osco_count);
      mode |= MINIMUM;
      return(0);
   }
   if (!(group = (struct OMGroup_array *)
      om$calloc(num=group_count, size=sizeof(struct OMGroup_array))))
   {
      fprintf(stdout, "Cannot allocate %d bytes for group object list.\n",
         sizeof(struct OMGroup_array) * group_count);
      mode |= MINIMUM;
      return(0);
   }

   /*=============================================================*/
   /* Step through object headers of cluster0 as far as possible, */
   /* counting objects and verifying their size fields.           */
   /*=============================================================*/
   while (fp < endfp)
   {
      unsigned int   size, objsize;

      fseek(osfp, 12, 1);
      if (fread(&size, 1, 4, osfp) != 4)
      {
         reportError("\n%6d. Offset %d, Cluster 0.  Error trying to read %dth object header.\n        Cannot validate any further.\n",
            ++errcnt, fp, numObjs+1);
         mode |= MINIMUM;
         return(0);
      }

#ifdef BIG_ENDIAN
      swapint(&size, &objsize);
      size = objsize;
#endif
      if (((objsize = size & 0xfffffff8) <= 0) ||
         ((objsize + fp) > endfp))
      {
         reportError("\n%6d. Offset %d, Cluster 0.  Bad object size (%d) for %dth object.\n        Object id: %d  Class id: %d.\n",
            ++errcnt,fp, size, numObjs+1, filed_oid[numObjs],
            filed_classid[numObjs]);
         mode |= MINIMUM;
         return(0);
      }
      if (bufsize < objsize)
      {
         buf = (char *) om$realloc(ptr=(char *) buf, size=objsize);
         bufsize = objsize;
      }

      /* Read the instance data */

      fseek(osfp, -8, 1);
      if (fread(buf, 1, objsize, osfp) != objsize)
      {
         reportError("\n%6d. Offset %d, Cluster 0.  Error reading %dth object.\n        Object id: %d  Class id: %d  Size: %d.\n",
            ++errcnt, fp, numObjs+1, filed_oid[numObjs], filed_classid[numObjs],
            size);
         mode |= MINIMUM;
         return(0);
      }

      /* Found a good object header - validate it according to its class */

      switch (filed_classid[numObjs])
      {
         case OM_K_ROOT_ACTCLASSID :               /* 0 */
            reportError("\n%6d. Offset %d, Cluster 0.  The %dth object is of class Root.  There\n        should be no objects of this class.  Object id: %d  Class id: %d\n",
                  ++errcnt, fp, numObjs+1, filed_oid[numObjs],
                  filed_classid[numObjs]);
            break;

         case OM_K_OMCLUSTER_ACTCLASSID :          /* 1 */

#ifdef BIG_ENDIAN
            if (!bigend_portOMCluster(objsize, buf, &buf, READ_PORT))
            {
               reportError("\n%6d. Offset %d, Cluster 0.  Found a cluster object that could\n        not be converted.\n",
                  ++errcnt, fp);
               mode |= MINIMUM;
               break;
            }
#endif

            if (!validateCluster(((struct OMCluster_instance *) buf),
                objsize, fp))
               mode |= MINIMUM;
            else if (c_index+1 > cluster_count)
            {
               /* If true now, we're already in trouble cause we haven't
                  added cluster 0 object to the cluster list yet. */
               reportError("\n%6d. Offset %d, Cluster 0.  Found more cluster objects than\n        number listed on the OSO to_ClusDscs channel (%d).\n        Indicates corruption.\n",
                  ++errcnt, fp, cluster_count);
               mode |= MINIMUM;
               if (cluster)
               {
                  if (!(cluster = (struct OMCluster_instance **)
                      om$realloc(ptr=(char *) cluster,
                         size=(4 * (c_index + 1)))))
                  {
                     fprintf(stdout, "Cannot allocate %d bytes for cluster object list.\n",
                        4 * (c_index = 1));
                     mode |= MINIMUM;
                     return(0);
                  }
               }
               else
               {
                  if (!(cluster = (struct OMCluster_instance **)
                      om$malloc(size=4 * (c_index + 1))))
                  {
                     fprintf(stdout, "Cannot allocate %d bytes for cluster object list.\n",
                        4 * (c_index = 1));
                     mode |= MINIMUM;
                     return(0);
                  }
               }
            }
            if (!(cluster[c_index] = (struct OMCluster_instance *)
                  om$malloc(size=objsize)))
            {
               fprintf(stdout, "Could not malloc %d bytes for cluster object.  Cannot continue.\n",
                  objsize);
               mode |= MINIMUM;
               return(0);           /* ERROR RETURN */
            }
            blkmove(objsize, buf, (char *) cluster[c_index]);
            totalObjs += cluster[c_index]->i_fil_num_objects;
            if ((cluster[c_index]->lcd.w_cluster_num <= highCnum) &&
                clustbyid[cluster[c_index]->lcd.w_cluster_num])
            {
               reportError("\n%6d. Offset %d, Cluster 0.  More than one cluster object with id %d.\n",
                     ++errcnt, fp, cluster[c_index]->lcd.w_cluster_num);
               mode |= MINIMUM;
            }
            clustbyid[cluster[c_index]->lcd.w_cluster_num] =
               cluster[c_index];
            c_index++;
            break;

         case OM_K_OMISO_ACTCLASSID :              /* 2 */
            if (i_index + 1 > iso_count)
            {
               reportError("\n%6d. Offset %d, Cluster 0.  More ISO objects found than are\n        listed on the OSO iso_d array.  Indicates corruption.\n",
                  ++errcnt, fp);
               if (iso)
               {
                  iso = (struct OMISO_instance **) om$realloc(ptr=(char *) iso,
                     size=(4 * (i_index + 1)));
               }
               else
               {
                  if (!(iso = (struct OMISO_instance **)
                     om$malloc(size=4 * (i_index + 1))))
                  {
                     fprintf(stdout, "Cannot allocate %d bytes for iso object list.\n",
                        4 * (i_index = 1));
                     mode |= MINIMUM;
                     return(0);
                  }
               }
            }

#ifdef BIG_ENDIAN
            if (!bigend_portOMISO(objsize, buf, READ_PORT))
            {
               reportError("\n%6d. Offset %d, Cluster 0.  Found an ISO object that could\n        not be converted.\n",
                  ++errcnt, fp);
               mode |= MINIMUM;
               break;
            }
#endif

            if (validateISO((struct OMISO_instance *) buf, objsize, fp))
            {
               if (!(iso[i_index] = (struct OMISO_instance *)
                  om$malloc(size=objsize)))
               {
                  fprintf(stdout, "Could not malloc %d bytes for ISO object.  Cannot continue.\n",
                     objsize);
                  mode |= MINIMUM;
                  return(0);           /* ERROR RETURN */
               }
               blkmove(objsize, buf, (char *) iso[i_index++]);
            }
            break;

         case OM_K_OMOBJSPACE_ACTCLASSID :         /* 4 */
            reportError("\n%6d. Offset %d, Cluster 0.  The %dth object is an OMOBJSPACE Object.\n        It should not be in the file.  Object id: %d  Class id: %d\n",
                  ++errcnt, fp, numObjs+1, filed_oid[numObjs],
                  filed_classid[numObjs]);
            break;

         case OM_K_OMMOSDOS_ACTCLASSID :           /* 5 */
            reportError("\n%6d. Offset %d, Cluster 0.  The %dth object is an OMMOSDOS Object.\n        It should not be in the file.  Object id: %d  Class id: %d\n",
                  ++errcnt, fp, numObjs+1, filed_oid[numObjs],
                  filed_classid[numObjs]);
            break;

         case OM_K_OMTRANSOS_ACTCLASSID :          /* 6 */
            reportError("\n%6d. Offset %d, Cluster 0.  The %dth object is a Transient Object.\n        Space object.  It should not be in the file.  Object id: %d  Class id: %d\n",
                  ++errcnt, fp, numObjs+1, filed_oid[numObjs],
                  filed_classid[numObjs]);
            break;

         case OM_K_OMFILEDOS_ACTCLASSID :          /* 7 */
            /* This should be the OSO object, which was already verified */
            if ((fp != clust0->i_my_file_ptr) || filed_oid[numObjs])
            {
               reportError("\n%6d. Offset %d, Cluster 0.  The %dth object is a false OSO.\n        Object id: %d  Class id: %d.\n",
                     ++errcnt, fp, numObjs+1, filed_oid[numObjs],
                     filed_classid[numObjs]);
            }
            break;

         case OM_K_OMMOSD_ACTCLASSID :             /* 8 */
            reportError("\n%6d. Offset %d, Cluster 0.  The %dth object is an OMMOSD Object.\n        It should not be in the file.  Object id: %d  Class id: %d\n",
                  ++errcnt, fp, numObjs+1, filed_oid[numObjs],
                  filed_classid[numObjs]);
            break;

         case OM_K_OMGROUP_ACTCLASSID :            /* 10 */
#ifdef BIG_ENDIAN
            if (!bigend_portOMGroup(objsize, buf, READ_PORT))
            {
               reportError("\n%6d. Offset %d, Cluster 0.  Found a group object that could\n        not be converted.\n",
                  ++errcnt, fp);
               mode |= MINIMUM;
               break;
            }
#endif
            if (!validateGroup(((struct OMGroup_instance *) buf),
                objsize, fp))
               mode |= MINIMUM;
            if (g_index > group_count)
            {
               reportError("\n%6d. Offset %d, Cluster 0.  More group objects found than are\n        listed on the OSO to_GrpDscs channel.  Indicates corruption.\n",
                  ++errcnt, fp);
               mode |= MINIMUM;
            }
            else
            {
               if (!(group[g_index].inst = (struct OMGroup_instance *)
                     om$malloc(size=objsize)))
               {
                  fprintf(stdout, "Could not malloc %d bytes for Group object.  Cannot continue.\n",
                     objsize);
                  mode |= MINIMUM;
                  return(0);           /* ERROR RETURN */
               }
               blkmove(objsize, buf, (char *) &group[g_index].inst->oid);
            }
            group[g_index].classid = OM_K_OMGROUP_ACTCLASSID;
            group[g_index++].fp = fp;
            break;

         case OM_K_OMOSCO_ACTCLASSID :             /* 11 */

#ifdef BIG_ENDIAN
            if (!bigend_portOMOSCO(objsize, buf, READ_PORT))
            {
               reportError("\n%6d. Offset %d, Cluster 0.  Found a class object that could\n        not be converted.\n",
                  ++errcnt, fp);
               mode |= MINIMUM;
               break;
            }
#endif

            if (!validateOSCO(((struct OMOSCO_instance *) buf),
                objsize, fp))
               mode |= MINIMUM;
            if (o_index > osco_count)
            {
               reportError("\n%6d. Offset %d, Cluster 0.  Found a class object, but have\n        already found number listed on the OSO to_OSCOs channel (%d).\n        Indicates corruption.\n",
                  ++errcnt, fp, osco_count);
               mode |= MINIMUM;
            }
            else
            {
               if (!(oscobyfp[o_index] = (struct OMOSCO_instance *)
                     om$malloc(size=objsize)))
               {
                  fprintf(stdout, "Could not malloc %d bytes for OSCO object.  Cannot continue.\n",
                     objsize);
                  mode |= MINIMUM;
                  return(0);           /* ERROR RETURN */
               }
               blkmove(objsize, buf, (char *) oscobyfp[o_index]);
               if (oscobyfp[o_index]->OSCO.w_classid > high_classid)
                  high_classid = oscobyfp[o_index]->OSCO.w_classid;
            }
            o_index++;
            break;

/*%%%*/         case OM_K_OMINDEX_ACTCLASSID :            /* 12 */
            break;

/*%%%*/         case OM_K_OMBTREE_ACTCLASSID :            /* 13 */
            break;

/*%%%*/         case OM_K_OMLNKBTREE_ACTCLASSID :         /* 14 */
            break;

         case OM_K_OMRTREE_ACTCLASSID :            /* 16 */
#ifdef BIG_ENDIAN
            if (!bigend_portOMrtree(objsize, buf, READ_PORT))
            {
               reportError("\n%6d. Offset %d, Cluster 0.  Found an Rtree object that could\n        not be converted.\n",
                  ++errcnt, fp);
               mode |= MINIMUM;
               break;
            }
#endif
            validateRtree(buf, objsize, fp);
            break;

         case OM_K_OMTAG_ACTCLASSID :              /* 29 */
            if (tag)
            {
               reportError("\n%6d. Offset %d.  More than one Tag object found.\n",
                  ++errcnt, fp);
               mode |= MINIMUM;
            }
            else
            {
#ifdef BIG_ENDIAN
               if (!bigend_portOMTag(objsize, buf, READ_PORT))
               {
                  reportError("\n%6d. Offset %d, Cluster 0.  Found a tag object that could\n        not be converted.\n",
                     ++errcnt, fp);
                  mode |= MINIMUM;
                  break;
               }
#endif
               validateTag((struct OMTag_instance *) buf, objsize, fp);
               if (!(tagRec = (struct OMTag_instance *)
                  om$malloc(size=objsize)))
               {
                  fprintf(stdout, "Could not malloc %d bytes for Tag object.  Cannot continue.\n",
                     objsize);
                  mode |= MINIMUM;
                  return(0);           /* ERROR RETURN */
               }
               blkmove(objsize, buf, (char *) tagRec);
               tagOid = filed_oid[numObjs];
               tagVla = (struct OM_sd_tag_record *) ((char *)
                  (&tagRec->tag_rec_descr.i_offset) +
                  tagRec->tag_rec_descr.i_offset);
            }
            tag++;
            break;

         case OM_K_OMTAGCON_ACTCLASSID :           /* 30 */

#ifdef BIG_ENDIAN
            if (!bigend_portOMTagCon(objsize, buf, READ_PORT))
            {
               reportError("\n%6d. Offset %d, Cluster 0.  Found a tag connect object that\n        could not be converted.\n",
                  ++errcnt, fp);
               mode |= MINIMUM;
               break;
            }
#endif
            validateTagCon((struct OMTagCon_instance *) buf, objsize, fp);
            if (g_index > group_count)
            {
               reportError("\n%6d. Offset %d, Cluster 0.  More TagCon objects found than are\n        listed on the OSO to_GrpDscs channel.  Indicates corruption.\n",
                  ++errcnt, fp);
            }
            else
            {
               if (!(group[g_index].inst = (struct OMGroup_instance *)
                     om$malloc(size=objsize)))
               {
                  fprintf(stdout, "Could not malloc %d bytes for TagCon object.  Cannot continue.\n",
                     objsize);
                  mode |= MINIMUM;
                  return(0);           /* ERROR RETURN */
               }
               blkmove(objsize, buf, (char *) &group[g_index].inst->oid);
            }
            group[g_index].classid = OM_K_OMTAGCON_ACTCLASSID;
            group[g_index++].fp = fp;
            break;

/*%%%*/         case OM_K_OMSUPGROUP_ACTCLASSID :         /* 31 */
            break;

         default :
            /* This could be the OSO object, which was already verified,
             * with some superclass of OMFiledOS
             */
            if ((fp != clust0->i_my_file_ptr) || filed_oid[numObjs])
            {
               reportError("\n%6d. Offset %d, Cluster 0.  The %dth object is a non-metaclass \n        object.  Object id: %d  Class id: %d.\n",
                  ++errcnt, fp, numObjs+1, filed_oid[numObjs],
                  filed_classid[numObjs]);
            }
            break;
      }

      fp += objsize + 8;
      numObjs++;
      fseek(osfp, fp, 0);
   }
   if (buf) om$dealloc(ptr=(char *) buf);

   cluster[c_index++] = clust0;
   if (c_index < cluster_count)
   {
      reportError("\n%6d. Cluster 0.  Less cluster objects found (%d) than were listed on the\n        OSO to_ClusDscs channel (%d).  This indicates missing clusters.\n",
         ++errcnt, c_index, cluster_count);
      mode |= MINIMUM;
   }
   cluster_count = c_index;
   if (o_index < osco_count)
   {
      reportError("\n%6d. Cluster 0.  Less class objects found (%d) than were listed on the\n        OSO to_OSCOs channel (%d).  Indicates missing class objects.\n",
         ++errcnt, o_index, osco_count);
      mode |= MINIMUM;
   }
   group_count = g_index;
   if (i_index < iso_count)
   {
      reportError("\n%6d. Cluster 0.  Number of ISO objects found (%d) does not equal\n        number in the OSO iso_d array (%d).\n",
         ++errcnt, i_index, iso_count);
      iso_count = i_index;
   }
   cluster[c_index] = clustbyid[0] = clust0;
   if (!QUICK && ((totalObjs += clust0->i_fil_num_objects) != objCnt))
   {
      reportError("\n%6d. Cluster 0.  The sum of objects listed for clusters (%d) does not\n        equal the number of objects found in the file (%d).\n",
         ++errcnt, totalObjs, objCnt);
      mode |= MINIMUM;
   }
   objCnt = totalObjs;

   /*==============================================*/
   /* Scan clusters list for overlapping clusters. */
   /*==============================================*/
   sortByFp();                               /* Fill in clustbyfp array */
   for (ii=0; (ii<cluster_count-1) && clustbyfp[ii] && clustbyfp[ii+1]; ii++)
   {
      if (clustbyfp[ii+1]->i_fil_byte_size &&
          ((clustbyfp[ii]->lcd.i_file_ptr + clustbyfp[ii]->i_fil_byte_size) >
          clustbyfp[ii+1]->lcd.i_file_ptr))
      {
         reportError("\n%6d. Cluster %d (offsets %d-%d, size %d) and\n        Cluster %d (offsets %d-%d, size %d) overlap in the file.\n",
            ++errcnt,
            clustbyfp[ii]->lcd.w_cluster_num,
            clustbyfp[ii]->lcd.i_file_ptr,
            (clustbyfp[ii]->lcd.i_file_ptr + clustbyfp[ii]->i_fil_byte_size - 1),
            clustbyfp[ii]->i_fil_byte_size,
            clustbyfp[ii+1]->lcd.w_cluster_num,
            clustbyfp[ii+1]->lcd.i_file_ptr,
            (clustbyfp[ii+1]->lcd.i_file_ptr + clustbyfp[ii+1]->
            i_fil_byte_size - 1), clustbyfp[ii+1]->i_fil_byte_size);
      }
   }

   if (!(oscobyid = (struct OMOSCO_instance **)
      om$calloc(num=(high_classid+1), size=4)))
   {
      fprintf(stdout, "Cannot allocate %d bytes for osco object list.\n",
         4 * (high_classid+1));
      mode |= MINIMUM;
      return(0);
   }
   if (!(classRefcnt = (unsigned int *)
      om$calloc(num=(high_classid+1), size=4)))
   {
      fprintf(stdout, "Cannot allocate %d bytes for osco reference count list.\n",
         4 * (high_classid+1));
      mode |= MINIMUM;
      return(0);
   }
   for (ii=class_count=obj_count=0; ii<osco_count; ii++)
   {
      if (oscobyid[oscobyfp[ii]->OSCO.w_classid])
      {
         if (strcmp(oscobyid[oscobyfp[ii]->OSCO.w_classid]->OSCO.s_name,
            oscobyfp[ii]->OSCO.s_name))
         {
            reportError("\n%6d. Cluster 0.  Class object for class <%s> has same\n        class id (%d) as class <%s>.\n",
                  ++errcnt, oscobyfp[ii]->OSCO.s_name,
                  oscobyfp[ii]->OSCO.w_classid,
                  oscobyid[oscobyfp[ii]->OSCO.w_classid]->OSCO.s_name);
         }
         else
            reportError("\n%6d. Cluster 0.  More than one class object for class <%s>.\n        Class id: %d.\n",
                  ++errcnt, oscobyfp[ii]->OSCO.s_name,
                  oscobyfp[ii]->OSCO.w_classid);
/* %%%%%%         mode |= MINIMUM; */
      }
      else
      {
         oscobyid[oscobyfp[ii]->OSCO.w_classid] = oscobyfp[ii];
         obj_count += oscobyfp[ii]->OSCO.i_refcnt;
         class_count++;
      }
   }
   if (class_count != osco_count)
   {
      reportError("\n%6d. Cluster 0.  Only %d valid class objects for this file.\n        Should be %d.\n",
         ++errcnt, class_count, osco_count);
   }

/* %%%%%%% Can't make this test.  The sum of OSCO refcounts may not
           equal the number of objects in the file because a
           GRreffile OSCO might have a bogus refcount (because of
           reference file connections).

  if (obj_count != objCnt)
   {
      reportError("\n%6d. Cluster 0.  The sum of class reference counts (%d) does not\n        equal the number of objects found in the file (%d).\n",
         ++errcnt, obj_count, objCnt);
   }
*/
   for (cnum=jj=1; cnum<=highCnum; cnum++)
   {
      if (clustbyid[cnum])
      {
         if ((count = validateObjSizes(clustbyid[cnum])) !=
             clustbyid[cnum]->i_fil_num_objects)
         {
            reportError("\n%6d. Cluster %d.  Cluster object is inconsistent with the cluster.\n        The object count in the cluster object (%d) does not match number\n        of objects found in the file (%d).\n",
               ++errcnt, cnum, clustbyid[cnum]->i_fil_num_objects, count);
            mode |= MINIMUM;
         }
         jj++;
      }
   }
   if (jj != cluster_count)
   {
      reportError("\n%6d. Cluster 0.  Only %d cluster objects in file.  Should be %d.\n",
         ++errcnt, jj, cluster_count);
      mode |= MINIMUM;
   }

   return(numObjs);
}


printOSname()
{
   if (oso)
   {
      fprintf(stdout, "\nInternal object space name: %s\n",
         oso->OSD.InternalName);
      if (logfile)
         fprintf(logfile, "\nInternal object space name: %s\n",
            oso->OSD.InternalName);
      return(1);
   }
   else
   {
      fprintf(stdout, "\nObject space object information is not available.\n\n");
      if (logfile)
         fprintf(logfile,
            "\nObject space object information is not available.\n\n");
      return(0);
   }
}


/*===================================================================*
 *                                                                   *
 *  checkHdrFormat()                                                 *
 *                                                                   *
 *  Simple check to make sure input file has an OM filed OS header.  *
 *  Initializes os_size.                                             *
 *                                                                   *
 *===================================================================*/
checkHdrFormat()
{
   topOfFilehdr = (int) &filehdr.magic;
   if (fseek(osfp,0,2))    /* Seek to end of file */
   {
      perror("Seek failed");
      return(0);
   }
   if (!(os_size = ftell(osfp)) || (os_size ==(unsigned int)  EOF) ||
        (os_size < (unsigned int) OMFILEHDRSIZE))
      return(0);
   if (fseek(osfp, 0, 0))
   {
      perror("Seek failed");
      return(0);
   }
   if (OMFILEHDRSIZE != fread(&filehdr, 1, OMFILEHDRSIZE, osfp))
   {
      reportError("\n%6d. Offset %d.  Error reading obj space header.\n",
         ++errcnt, ftell(osfp));
      return(0);
   }

#ifdef BIG_ENDIAN
   bigend_portHdr(&filehdr);
#endif

   if (filehdr.dros_msgstr[0] &&
       strcmp(filehdr.dros_msgstr, "Successful recluster"))
      fprintf(stdout, "\n\n +++ FILE HAS BEEN EDITED SINCE IT WAS WRITTEN. +++\n");
   if (!(strlen(filehdr.start_time) == 25 && isalpha(filehdr.start_time[0]) &&
       isalpha(filehdr.start_time[1]) && isalpha(filehdr.start_time[2]) &&
       (filehdr.start_time[3] == ' ') && isalpha(filehdr.start_time[4]) &&
       isalpha(filehdr.start_time[5]) && isalpha(filehdr.start_time[6]) &&
       (filehdr.start_time[7] == ' ') && (isdigit(filehdr.start_time[8]) ||
       (filehdr.start_time[8] == ' ')) &&
       isdigit(filehdr.start_time[9]) && (filehdr.start_time[10] == ' ') &&
       isdigit(filehdr.start_time[11]) && isdigit(filehdr.start_time[12]) &&
       (filehdr.start_time[13] == ':') && isdigit(filehdr.start_time[14]) &&
       isdigit(filehdr.start_time[15]) && (filehdr.start_time[16] == ':') &&
       isdigit(filehdr.start_time[17]) && isdigit(filehdr.start_time[18]) &&
       (filehdr.start_time[19] == ' ') && isdigit(filehdr.start_time[20]) &&
       isdigit(filehdr.start_time[21]) && isdigit(filehdr.start_time[22]) &&
       isdigit(filehdr.start_time[23])))
   {
      return(0);
   }
   return(1);
}


void parseCommandLine(argc, argv)
int   argc;
char  *argv[];
{
   FILE  *configfp;
   char  option;

   configfp = errlogfp = 0;
#ifdef CLIX
   ddpPath[0] = '\0';
#endif
   OSname = 0;
   while (EOF != (option = getopt(argc, argv, "c:D:f:l:mNqRsV")))
   {
      switch(option)
      {
         case 'c':                     /* Configuration file name */
            if (!(configfp = fopen(optarg, "r")))
            {
               perror(optarg);
               fprintf(stdout, "Could not open configuration file <%s>.\n",
                  optarg);
            }
            break;
         case 'f':                     /* OS file name */
            filename[MAXPATHLEN] = '\0';
            strncpy(filename, optarg, MAXPATHLEN);
            if (!(osfp = fopen(filename, "r+")))
            { 
              if (!(osfp = fopen(filename, "r")))
               {
                  perror(filename);
                  fprintf(stdout, "Could not open object space file <%s>.\n",
                     filename);
               }
               else
               {
                  fprintf(stdout, "Object space file <%s> opened read-only\n", filename);
                  mode |= READONLY;    /* We won't be able to modify file */
               }
            }
            break;
         case 'l':                     /* Errorlog file name */
            if (!(errlogfp = fopen(optarg, "w")))
            {
               perror(optarg);
               fprintf(stdout, "Could not open errorlog file <%s>.\n",
                  optarg);
            }
            break;
         case 'm':
            mode |= MINIMUM;
            break;
         case 'N':
            OSname = 1;
            mode |= QUICK;
            break;
         case 'q':
            mode |= QUICK;
            break;
         case 'R':      /* 'R' for 'reference file junk' */
            /* Save int osname pairs & adjust optind */
            tagconPatchCount = 0;
            if (!(tagconPatchList = (char **)
               om$malloc(size=(argc - 1) * sizeof(char *))))
            {
               fprintf(stdout, "\nCould not allocate %d bytes of memory - cannot continue.\n");
               exit(1);
            }
            while ((optind < argc) && (argv[optind][0] != '-'))
               tagconPatchList[tagconPatchCount++] = argv[optind++];
            tagconPatch = 1;
            mode |= QUICK;    /* Not really interested in validation */
            break;
         case 's':
            mode |= SOFTLOGGING;
            break;
#ifdef CLIX
         case 'D':
            strncpy(&ddpPath[0], optarg, MAXPATHLEN);
            ddpPath[MAXPATHLEN] = '\0';
            break;
#endif
         case 'V':
            verbose = 1;
            break;
         case 'h':
         case '?':
         default:
            fprintf(stdout, "\nusage: dros [-f filename] Object Space file\n");
            fprintf(stdout, "            [-c filename] Configuration file\n");
            fprintf(stdout, "            [-l filename] Errorlog file\n");
            fprintf(stdout, "            [-m]          Minimum Dr.OS\n");
            fprintf(stdout, "            [-q]          Bypass non-essential validation\n");
            fprintf(stdout, "            [-s]          Silently log errors to file\n");
#ifdef CLIX
            fprintf(stdout, "            [-D path]     Directory of ddp output files\n");
#endif
            fprintf(stdout, "            [-V]          Verbose validation messages\n");
            exit(1);
            break;
      }
   }

   if (!configfp)
   {
      char  *envguy;

      if (!(configfp = fopen("dros.conf", "r"))) /* Look in cur dir */
         if (envguy = (char *) getenv("DROSCONFIG"))     /* Try envr variable */
            configfp = fopen(envguy, "r");
   }
   if (configfp)
   {
      int   len;
      char  *command, commandLine[133];

      while (fgets(commandLine, 133, configfp))
      {
         if (commandLine[0] == '#')
            continue;
         command = commandLine;
         while(isspace(*command))
            command++;
         if ((len = strlen(command)) < 6)
            continue;
         if (command[len-1] == '\n')
            command[len-1] = '\0';
         if (!strncmp(command, "OSFILE", 6))
         {
            if (!osfp)
            {
               if (!(command = strchr(command, '=')))
                  continue;
               while(isspace(*(++command)));
               strncpy(filename, command, MAXPATHLEN);
               filename[MAXPATHLEN] = '\0';
               if (!(osfp = fopen(filename, "r+")))
               {
                  if (!(osfp = fopen(filename, "r")))
                  {
                     perror(filename);
                     fprintf(stdout, "\nCould not open object space file specified in config file <%s>\n",
                        filename);
                  }
                  else
                  {
                     fprintf(stdout, "Object space file <%s> opened read-only\n", filename);
                     mode |= READONLY;    /* We won't be able to modify file */
                  }
               }
            }
            else
               fprintf(stdout, "Object space file specified in config file overridden by -f option.\n");
         }
         else if (!strncmp(command, "OUTFILE", 7))
         {
            if (!outfp)
            {
               if (!(command = strchr(command, '=')))
                  continue;
               while(isspace(*(++command)));
               strncpy(outputFile, command, MAXPATHLEN);
               outputFile[MAXPATHLEN] = '\0';
               if (!(outfp = fopen(outputFile, "w")))
               {
                  perror(outputFile);
                  fprintf(stdout, "Could not open output file <%s> specified in config file.\n", outputFile);
               }
               else
                  mode |= EDIT;
            }
            else
               fprintf(stdout, "Output file specified in config file overridden by -o option.\n");
         }
         else if (!strncmp(command, "ERRORLOG", 8))
         {
            if (!errlogfp)
            {
               if (!(command = strchr(command, '=')))
                  continue;
               while(isspace(*(++command)));
               if (!(errlogfp = fopen(command, "w")))
               {
                  perror(command);
                  fprintf(stdout, "Could not open errorlog file specified in config file\n");
               }
            }
            else
               fprintf(stdout, "Errorlog file specified in config file overridden by -l option.\n");
         }
#ifdef CLIX
         else if (!strncmp(command, "DDPDIR", 6))
         {
            if (!ddpPath[0])
            {
               if (!(command = strchr(command, '=')))
                  continue;
               while(isspace(*(++command)));
               strcpy(ddpPath, command);
            }
            else
               fprintf(stdout, "DDPDIR specified in config file overridden by -D option.\n");
         }
#endif
         else
            fprintf(stdout, "Bad command line in config file\n   <%s>\n",
               commandLine);
      }
      fclose(configfp);
   }

   while (!osfp)
   {
      fprintf(stdout, "Filed object space name: ");
      scanf("%s", filename);
      if ((filename[0] == 'q') && (strlen(filename) == 1))
         exit(1);
      if (!(osfp = fopen(filename, "r+")))
      { 
        if (!(osfp = fopen(filename, "r")))
         {
            perror(filename);
            fprintf(stdout, "Object space file <%s> not opened\n", filename);
            exit(1);
         }
         else
         {
            fprintf(stdout, "Object space file <%s> opened read-only\n", filename);
            mode |= READONLY;    /* We won't be able to modify file */
         }
      }
   }
   if (mode & MINIMUM)
      verbose = 0;     /* Since we're not going to validate the file */
   if (tagconPatch)
   {
      if (mode & READONLY)
      {
         fprintf(stdout, "\nCannot apply OMTagCon patches to a read only file.\n");
         exit(EACCES);
      }
      if (mode & MINIMUM)
      {
         fprintf(stdout, "\nCannot apply OMTagCon patches in minimum mode.\n");
         exit(EINVAL);
      }
   }
}


drosInit()
{
   int   zeroes;

   if (!checkHdrFormat())     /* Makes sure we have a 4.5 obj space file */
      fprintf(stdout, "\nFile <%s> does not have a valid header.\n\n",
         filename);

   /*=================================================================*/
   /* MINIMUM mode can be specified by the -m switch on the command   */
   /* line.  That switch implies the user doesn't want validation to  */
   /* run nor for internals to be loaded.  MINIMUM mode allows simple */
   /* browsing (no instance data formatting) and no stats gathering.  */
   /* MINIMUM can also be set by a validation routine that fails.     */
   /* If VALID has been set in the fileheader, then validation has    */
   /* already been run & the file checked out; some validation can    */
   /* be by-passed.                                                   */
   /*=================================================================*/

   if (!(mode & MINIMUM) && !(mode & QUICK))
   {
      fprintf(stdout, "\n\n +++ Validating object space <%s> +++\n", filename);
      if (!(mode & MINIMUM))
      {
         char  checksumflag = 1;

         /* Validate the file structure */
         if (verbose)
            fprintf(stdout, "\n ++++ Validating the file header ++++\n");
         if (!validateHdr(&filehdr))    /* Check each field of file header */
            mode |= MINIMUM;
         if (!(mode & QUICK))  /* -q option = skip these 2 passes thru file */
         {
            if (verbose)
               fprintf(stdout, "\n ++++ Checking for zeroed-out data ++++\n");
            zeroes = detectHoles(firstObjfp, os_size, 8192, &checksumflag);
            if (verbose)
               fprintf(stdout, "\n ++++ Validating the object headers ++++\n");
            objCnt = walkObjects(firstObjfp, os_size);       /* Step thru os */
            if (checksumflag && !(mode & MINIMUM) && (OSflags & HEADERVALID))
               OSflags |= FILEVALID;
            else if (verbose)
               fprintf(stdout, "\n ++++ The file structure is NOT valid. ++++\n");
         }
      }
   }
   else objCnt = 0;

   if (!(MINIMUM & mode))
   {
      OMuint   size;

#ifdef BIG_ENDIAN
      int   tempint;
#endif

      if (verbose)
         fprintf(stdout, "\n ++++ Validating the OM data structures ++++\n");
      /* Read in Cluster 0/OSO object */
      fseek(osfp, filehdr.fp_OSO+12, 0);
      fread(&size, 1, 4, osfp); /* Get size of OSO */

#ifdef BIG_ENDIAN

      /* Convert the OSO size to a value we can understand */

      swapint(&size, &tempint);
      size = tempint;
#endif

      fseek(osfp, -8, 1);     /* Back up to object header */
      if (((size=(size & 0xfffffff8)) > 0) && (size < os_size))
      {
         if (!(clust0 = (struct OMCluster_instance *) om$malloc(size=size)))
         {
            fprintf(stdout, "Could not allocate %d bytes for Cluster 0/OSO object.\n        File cannot be validated further.\n",
               size);
            mode |= MINIMUM;
         }
         else
         {
            if ((OMuint) fread(clust0, 1, size, osfp) != size)
            {
               fprintf(stdout, "Read of Cluster 0/OSO object failed.\n");
               mode |= MINIMUM;
               om$dealloc(ptr=(char *) clust0);
            }
         }
      }
      else
      {
         reportError("\n%6d. Offset %d.  Bad size (%d) for OSO object.  Object\n        cannot be read, file cannot be retrieved nor further validated.\n",
            ++errcnt, filehdr.fp_OSO, size);
         mode |= MINIMUM;
      }
      if (clust0)
      {

#ifdef BIG_ENDIAN
         if (!bigend_portOSO(size, clust0, READ_PORT))
            mode &= MINIMUM;
#endif

         validateCluster0(clust0, size, &filehdr);    /* Clust0/OSO obj */
      }
      if (OSname)
      {
         if (oso)
            fprintf(stdout, "%s\n", oso->OSD.InternalName);
         exit(0);
      }
      if (!(mode & MINIMUM))
      {
         /* Initialize OM-like data structures */
         walkCluster0(clust0);            /* Read in all the objects we'll need */
      }
   }

   if (!(mode & MINIMUM))
   {
      /* Cluster 0 is pretty much validated by now */

      if (tagconPatch)
      {
         /* User specified the -R command line option.  We'll skip the
            rest of the file validation, put in his OMTagCon patches,
            rechecksum the file and quit.
          */
         OMuint   ii;
         int      jj;
         char     patched = 0;

         for (ii=0; ii<group_count; ii++)
         {
            if (group[ii].classid != OM_K_OMTAGCON_ACTCLASSID)
               continue;
            for (jj=0; (jj+1)<tagconPatchCount; jj+=2)
            {
               if (!strcmp(((struct OMTagCon_instance *) (group[ii].inst))->
                  osname, tagconPatchList[jj]))
               {
                  strcpy(((struct OMTagCon_instance *) (group[ii].inst))->osname,
                     tagconPatchList[jj+1]);

                  /* Patch the OMTagCon object in the file */
                  fseek(osfp, group[ii].fp + 8 +
                     ((int) &((struct OMTagCon_instance*)
                     (group[ii].inst))->osname[0] - (int) group[ii].inst), 0);
                  if (fwrite(tagconPatchList[jj+1], 1,
                     strlen(tagconPatchList[jj+1]) + 1, osfp) !=
                     (strlen(tagconPatchList[jj+1]) + 1))
                  {
                     fprintf(stdout, "\nCould not write to file location %d to patch OMTagCon object.  Cannot continue.\n",
                        group[ii].fp);
                     exit(1);
                  }
                  patched = 1;
                  break;
               }
            }
         }
         if (patched)
         {
            /* Rechecksum the file & file header */

            unsigned int   ii, bcount, size, fileloc, checksum = 0;
            unsigned char  buffer[8192];

            fileloc = sizeof(struct OM_sd_OS_filehdr_OM);
            bcount = filehdr.i_size - fileloc;
            fseek(osfp, fileloc, 0);
            while(bcount)
            {
               if (bcount > 8192)
                  size = 8192;
               else
                  size = bcount;
               if (fread(buffer, 1, size, osfp) != size)
               {
                  fprintf(stdout, "Could not read file to compute checksum.\n");
                  exit(1);
               }
               bcount -= size;
               for (ii=0; ii<size; ii++, fileloc++)
                  checksum += (unsigned char) buffer[ii] + fileloc;
            }
            fseek(osfp, (int) &filehdr.checksum - (int) &filehdr.magic, 0);

#ifdef BIG_ENDIAN
            swapint(&checksum, &ii);
            checksum = ii;
#endif

            fwrite(&checksum, 1, sizeof(unsigned int), osfp);
            checksum = 0;
            fseek(osfp, 0, 0);
            fread(buffer, 1, sizeof(struct OM_sd_OS_filehdr_OM), osfp);
            for (ii=checksum=0; ii<434; ii++)      /* Skip dros fields */
               checksum += (unsigned char) buffer[ii] + ii;
            fseek(osfp, (int) &filehdr.hdr_checksum - (int) &filehdr.magic, 0);

#ifdef BIG_ENDIAN
            swapint(&checksum, &ii);
            checksum = ii;
#endif

            fwrite(&checksum, 1, sizeof(unsigned int), osfp);
            fclose(osfp);
         }
         exit(0);
      }

      if (!(objTable = (struct statsbyid *)
         om$calloc(num=filehdr.i_spacemap_size,
         size=sizeof(struct statsbyid))))
      {
         fprintf(stdout, "\nCould not allocate %d bytes for object summary table.\nFile cannot be validated further.\n",
            sizeof(struct statsbyid) * filehdr.i_spacemap_size);
         mode |= MINIMUM;
      }
      else
      {
         unsigned int      ii, jj, oid, *filed_oid, fp, objsize;
         unsigned short    *filed_classid;
         OM_S_FILEOBJHDR   objHdr;

#ifdef BIG_ENDIAN
         int               tempint;
         short             tempshort;
#endif

         for (highOid=ii=0; ii<=highCnum; ii++)
         {
            char  tagCheck = 0;

            if (clustbyid[ii])
            {
               filed_oid = (unsigned int *) (clustbyid[ii]->
                  i_filed_oid_list_descr.i_offset + (int) 
                  &clustbyid[ii]->i_filed_oid_list_descr.i_offset);
               filed_classid = (unsigned short *) (clustbyid[ii]->
                  w_filed_classid_list_descr.i_offset +
                  (int) &clustbyid[ii]->w_filed_classid_list_descr.i_offset);
               fp = clustbyid[ii]->lcd.i_file_ptr;
               for (jj=0; jj<clustbyid[ii]->i_filed_oid_list_descr.i_count; jj++)
               {
                  fseek(osfp, fp, 0);
                  if (fread(&objHdr, 1, sizeof(OM_S_FILEOBJHDR), osfp) !=
                     sizeof(OM_S_FILEOBJHDR))
                  {
                     fprintf(stdout, "Read error at %d.  Cannot continue validation.\n",
                        ftell(osfp));
                     mode |= MINIMUM;
                     return(0);        /* ERROR RETURN */
                  }

#ifdef BIG_ENDIAN
                  swapint(&objHdr.i_size, &tempint);
                  objHdr.i_size = tempint;
                  swapint(&objHdr.tag, &tempint);
                  objHdr.tag = tempint;
                  swapshort(&objHdr.version, &tempshort);
                  objHdr.version = tempshort;
#endif

                  objsize = GETOBJSIZE(objHdr.i_size);
                  if ((oid = filed_oid[jj]) > highOid)
                     highOid = oid;
                  if (objTable[oid].fp)
                  {
                     reportError("\n%6d. Object id %d occurs more than once in the file.\n        Found in clusters %d (at offset %d) and %d (at offset %d).\n",
                        ++errcnt, oid, objTable[oid].cluster_num,
                        objTable[oid].fp, ii, fp);
                     mode |= MINIMUM;
                  }
                  else
                  {
                     objTable[oid].cluster_num = ii;
                     objTable[oid].size = objHdr.i_size;
                     objTable[oid].fp = fp;
                     objTable[oid].classid = filed_classid[jj];
                     objTable[oid].index = jj;
                     objTable[oid].tag = objHdr.tag;
                     objTable[oid].version = objHdr.version;
                     if (filed_classid[jj] > high_classid ||
                         !(oscobyid[filed_classid[jj]]))
                     {
                        reportError("\n%6d. There is no class object (OSCO) for class id of\n        object %d in Cluster %d at offset %d.  Class id %d.\n",
                           ++errcnt, oid, ii, fp, filed_classid[jj]);
                        mode |= MINIMUM;
                     }
                     else classRefcnt[filed_classid[jj]]++;
                     if (!tagCheck &&
                         (objHdr.i_size & OM_OHf_is_tagged) && !tag)
                     {
                        tagCheck = 1;
                        reportError("\n%6d. Offset %d. Tagged object found, but object space does not\n        contain a Tag object.  Object id: %d  Class id: %d.\n",
                           ++errcnt, fp, oid, filed_classid[jj]);
                     }
                  }
                  fp += objsize;
               }
            }
         }
         /* If there's a tag obj, we now have the info to check it */
         if (tag)
            validateTagVla();

         if (!(classStats = (struct classstats *)
            om$calloc(num=sizeof(struct classstats),
            size=high_classid+1)))
         {
            fprintf(stdout, "Could not allocate %d bytes.  Cannot continue.\n",
               (high_classid+1) * sizeof(struct classstats));
            mode |= MINIMUM;
         }
         if (!(sort_classname = (struct sort_element *) 
            om$malloc(size=sizeof(struct sort_element) * osco_count)))
         {
            fprintf(stdout, "\nCould not allocate %d bytes for class name structure.\n",
               sizeof(struct sort_element) * osco_count);
            mode |= MINIMUM;
         }
         else
         {
            for (ii=0; ii<osco_count; ii++)
            {
               /* Point the structures to the osco structs */
               sort_classname[ii].p_sort_struct = (unsigned int*) oscobyfp[ii];
               strcpy(sort_classname[ii].sort_string, oscobyfp[ii]->OSCO.s_name);
            }
            sort_routine(sort_classname, osco_count, STRING_SORT);
            validateClassRefcnt();  /* Match ref counts with objects found */

         }
         for (iso_summary=NULL, ii=0; ii<iso_count; ii++)
            count_iso(iso[ii]);

         if (!(mode & QUICK)) /* Nothing is dependent upon validateChannels */
         {
            for (ii=0; ii<highOid; ii++)
            {
               if (objTable[ii].classid)
                  validateChannels(ii);
            }
         }

      }
      if (classRefcnt)
         om$dealloc(ptr=(char *) classRefcnt);
   }

   if (!(mode & MINIMUM))
   {
      OSflags |= OMVALID;
      if (verbose)
         fprintf(stdout, "\n ++++ The OM data structures are valid. ++++\n");
   }
   else if (verbose)
      fprintf(stdout, "\n ++++ The OM data structures are NOT valid. ++++\n");

   return(1);
}
