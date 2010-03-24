#include "exsysdep.h"

#ifdef BIG_ENDIAN

/*
 +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +

 +  Port Big Endian Object Space Routines                          +
    -------------------------------------
 +                                                                 +
    These are low-level routines for reading OM structures from a
 +  filed object space and converting them to Big Endian format.   +
    These routines are used by OM, dros and autorecluster images
 +  running on Big Endian systems (such as the Sun).               +

 +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +
 */


#include <stdio.h>
#include "OMminimum.h"
#include "OMOSfilehdr.h"
#include "OMmacros.h"
#include "OMport.h"
#include "dros.h"

extern char *som_malloc(),
            *som_calloc(),
            *som_realloc();
extern void som_dealloc();
extern char *memcpy();

char *OM_Gp_inst_in, *OM_Gp_inst_out;

/* The following global flag gets set on entry to OMCluster.fault
 * (READ_PORT) and OMFiledOS.write (WRITE_PORT).  On reads, we're
 * porting Clipper file format to Big Endian memory format; on writes,
 * Big Endian memory format to Clipper file format.
 */

OMuint   OM_Gf_ioMode = READ_PORT;

void swapshort(src, dest)
unsigned char  *src, *dest;
{
   dest[0] = src[1];
   dest[1] = src[0];
}

void swapint(src, dest)
unsigned char  *src, *dest;
{
   dest[0] = src[3];
   dest[1] = src[2];
   dest[2] = src[1];
   dest[3] = src[0];
}

int bigend_portHdr(hdr)
OM_S_OS_FILEHDR   *hdr;
{
   /*------------------------------------------------------------
      This routine is called after the filed object space has
      been fopen-ed and the file header read OR when the write
      method has set up the file header and is about to write
      it to file.  Caller passes us a pointer to its header, we
      copy it to a local file header structure, then put the
      results of our conversions in the caller's header.

     ------------------------------------------------------------
    */

   int   ii;
   union
   {
      unsigned char     Char[sizeof(OM_S_OS_FILEHDR)];
      OM_S_OS_FILEHDR   Hdr;
   }  oldHdr;

   /* Character strings do not change format between Clipper and
    * Sun big endian.  Do one massive memcpy to get all of the
    * file header character strings copied from the input header
    * to our local copy.
    */

   memcpy(&oldHdr.Char[0], (char *) hdr, sizeof(OM_S_OS_FILEHDR));

   for (ii=0; ii<8; ii+=2) /* Convert magic #, version #'s, # clusters */
      swapshort(&oldHdr.Char[ii], &(((char *) hdr)[ii]));

   for (ii=8; ii<52; ii+=4)   /* Convert i_size through S_OS_object (oid) */
   {
      swapint(&oldHdr.Char[ii], &(((char *) hdr)[ii]));
   }
   swapshort((char *) &oldHdr.Hdr.OSOfiledClassid,
      (char *) &hdr->OSOfiledClassid);
   swapint((char *) &oldHdr.Hdr.os_flags, (char *) &hdr->os_flags);
   swapint((char *) &oldHdr.Hdr.hdr_checksum, (char *) &hdr->hdr_checksum);
   return(1);
}


int bigend_portOSO(size, OSO, flag)
OMuint         size;
char           *OSO;
unsigned char  flag;
{
   /* Routine to convert the OSO from little endian to big endian
    * (or big to little in write case).  'size' is the size field
    * of the OSO's object header (in big endian form -- it's a value
    * we can use without having to convert it first).  'OSO' is the
    * instance data to be converted (including the object header).
    * Caller expects the converted object to be placed in the same
    * buffer 'OSO' points to, so we'll convert to a temporary buffer
    * and, if successful, copy the results to caller's buffer.
    */

   int                        oidOffset,          /* Offsets from Root */
                              to_OSOoffset,
                              iso_dOffset,
                              iso_dCount,
                              freeoidsOffset,
                              to_OSCOsOffset,
                              to_ClusDscsOffset,
                              to_GrpDscsOffset,
                              to_NamObjDirOffset,
                              temp,
                              ii;
   char                       *oso;
   struct OMObjSpace_instance *objspace,
                              *Objspace;
   struct OMCluster_instance  *cluster,
                              *Cluster;

   /* 'OSO' and 'oso' are pointers to the object header of the input
    * and output Object Space Object.
    * 'Objspace' and 'objspace' point directly to the OMObjSpace
    * component of the Obj Space Object.  Be careful when calculating
    * offsets as to what the offset is to.
    */

   if (!(oso = (char *) om$malloc(size = size)))
      return(0);

   /* Convert object header and OMCluster component */

   bigend_portOMCluster(size, OSO, &oso, flag);

   /* Get handy pointers to OSO's components */

   Cluster = (struct OMCluster_instance *) OSO;
   cluster = (struct OMCluster_instance *) oso;
   Objspace = (struct OMObjSpace_instance *)
      &OSO[sizeof(struct OMCluster_instance)];
   objspace = (struct OMObjSpace_instance *)
      &oso[sizeof(struct OMCluster_instance)];

   memcpy((char *) objspace, (char *) Objspace, 32);  /* Copy timestamps */
   swapint((char *) &Objspace->p_filehdr, (char *) &objspace->p_filehdr);

   /* Convert the OSD */

   for (ii = (int) &Objspace->OSD.lcfq_lh.next - (int) OSO;
      ii<(int) &Objspace->OSD.OSnum - (int) OSO; ii+=4)
      swapint(&OSO[ii], &oso[ii]);
   swapshort((char *) &Objspace->OSD.OSnum, (char *) &objspace->OSD.OSnum);
   memcpy(objspace->OSD.name, Objspace->OSD.name,
      ((int) &Objspace->OSD.ActToFil - (int) Objspace->OSD.name));


   /* Convert the rest of the OMObjSpace instance, which is all ints
    * down to the vla's and channels.
    */

   /* Figure out where the OMCluster component's vlas start and end */

   if (flag == READ_PORT)
   {
      oidOffset = cluster->i_filed_oid_list_descr.i_offset +
         ((int) &cluster->i_filed_oid_list_descr.i_offset - (int) oso);
      to_OSOoffset = cluster->to_OSO + ((int) &cluster->to_OSO - (int) oso);
   }
   else
   {
      oidOffset = Cluster->i_filed_oid_list_descr.i_offset +
         ((int) &Cluster->i_filed_oid_list_descr.i_offset - (int) OSO);
      to_OSOoffset = Cluster->to_OSO + ((int) &Cluster->to_OSO - (int) OSO);
   }

   /* Convert remaining ints in fixed part of OMObjSpace component
    * down to OMCluster oid vla.
    */

   for (ii = (int) &Objspace->OSD.ActToFil - (int) OSO; ii < oidOffset; ii+=4)
      swapint(&OSO[ii], &oso[ii]);

   /* Figure out where the OMObjSpace component's vlas start and end */

   if (flag == READ_PORT)
   {
      if (objspace->iso_d_descr.i_offset)
      {
         iso_dOffset = objspace->iso_d_descr.i_offset +
            ((int) &objspace->iso_d_descr.i_offset - (int) oso);
         iso_dCount = objspace->iso_d_descr.i_count;
      }
      else
         iso_dOffset = 0;
      if (objspace->freeoids_descr.i_offset)
         freeoidsOffset = objspace->freeoids_descr.i_offset +
            ((int) &objspace->freeoids_descr.i_offset - (int) oso);
      else
         freeoidsOffset = 0;

      to_OSCOsOffset = objspace->to_OSCOs + ((int) &objspace->to_OSCOs -
         (int) oso);
      to_ClusDscsOffset = objspace->to_ClusDscs + ((int)
         &objspace->to_ClusDscs - (int) oso);
      to_GrpDscsOffset = objspace->to_GrpDscs + ((int)
         &objspace->to_GrpDscs - (int) oso);
      if (objspace->to_NamObjDir)
         to_NamObjDirOffset = objspace->to_NamObjDir +
            ((int) &objspace->to_NamObjDir - (int) oso);
      else
         to_NamObjDirOffset = 0;
   }
   else
   {
      if (Objspace->iso_d_descr.i_offset)
      {
         iso_dOffset = Objspace->iso_d_descr.i_offset +
            ((int) &Objspace->iso_d_descr.i_offset - (int) OSO);
         iso_dCount = Objspace->iso_d_descr.i_count;
      }
      else
         iso_dOffset = 0;
      if (Objspace->freeoids_descr.i_offset)
         freeoidsOffset = Objspace->freeoids_descr.i_offset +
            ((int) &Objspace->freeoids_descr.i_offset - (int) OSO);
      else
         freeoidsOffset = 0;

      to_OSCOsOffset = Objspace->to_OSCOs + ((int) &Objspace->to_OSCOs -
         (int) OSO);
      to_ClusDscsOffset = Objspace->to_ClusDscs + ((int)
         &Objspace->to_ClusDscs - (int) OSO);
      to_GrpDscsOffset = Objspace->to_GrpDscs + ((int)
         &Objspace->to_GrpDscs - (int) OSO);
      if (Objspace->to_NamObjDir)
         to_NamObjDirOffset = Objspace->to_NamObjDir +
            ((int) &Objspace->to_NamObjDir - (int) OSO);
      else
         to_NamObjDirOffset = 0;
   }

   /* Pick up just beyond the OMCluster to_OSO channel and convert
    * ints down to the iso_d vla.
    */

   temp = iso_dOffset ? iso_dOffset : freeoidsOffset;
   for (ii = (int) to_OSOoffset + 16; ii < (temp ? temp :
      to_OSCOsOffset); ii+=4)
      swapint(&OSO[ii], &oso[ii]);

   /* Convert the iso_d vla (char array followed by an int) */

   if (iso_dOffset)
   {
      memcpy(&oso[iso_dOffset], &OSO[iso_dOffset],
         (freeoidsOffset ? freeoidsOffset : to_OSCOsOffset) - iso_dOffset);
      for (ii=1; ii<=iso_dCount; ii++)
         swapint(&OSO[(iso_dOffset +
            (ii * (OM_K_MAXINTOSNAME_LEN + 4))) - 4],
            &oso[(iso_dOffset + (ii * (OM_K_MAXINTOSNAME_LEN + 4))) - 4]);
   }

   /* Convert the freeoids vla (int) */

   if (freeoidsOffset)
      for (ii = (int) freeoidsOffset; (int) &OSO[ii] < to_OSCOsOffset; ii+=4)
         swapint(&OSO[ii], &oso[ii]);

   /* Convert the channels (2 shorts followed by chan links) */

   swapshort(&OSO[to_OSCOsOffset], &oso[to_OSCOsOffset]);
   swapshort(&OSO[to_OSCOsOffset + 2], &oso[to_OSCOsOffset + 2]);
   for (ii = to_OSCOsOffset + 4; ii < to_ClusDscsOffset; ii+=12)
   {
      swapshort(&OSO[ii], &oso[ii]);
      swapshort(&OSO[ii+2], &oso[ii+2]);
      swapshort(&OSO[ii+4], &oso[ii+4]);
      swapshort(&OSO[ii+6], &oso[ii+6]);
      swapint(&OSO[ii+8], &oso[ii+8]);
   }

   swapshort(&OSO[to_ClusDscsOffset], &oso[to_ClusDscsOffset]);
   swapshort(&OSO[to_ClusDscsOffset + 2], &oso[to_ClusDscsOffset + 2]);
   for (ii = to_ClusDscsOffset + 4; ii < to_GrpDscsOffset; ii+=12)
   {
      swapshort(&OSO[ii], &oso[ii]);
      swapshort(&OSO[ii+2], &oso[ii+2]);
      swapshort(&OSO[ii+4], &oso[ii+4]);
      swapshort(&OSO[ii+6], &oso[ii+6]);
      swapint(&OSO[ii+8], &oso[ii+8]);
   }

   swapshort(&OSO[to_GrpDscsOffset], &oso[to_GrpDscsOffset]);
   swapshort(&OSO[to_GrpDscsOffset + 2], &oso[to_GrpDscsOffset + 2]);
   if (to_NamObjDirOffset)
   {
      for (ii = to_GrpDscsOffset + 4; ii < to_NamObjDirOffset; ii+=12)
      {
         swapshort(&OSO[ii], &oso[ii]);
         swapshort(&OSO[ii+2], &oso[ii+2]);
         swapshort(&OSO[ii+4], &oso[ii+4]);
         swapshort(&OSO[ii+6], &oso[ii+6]);
         swapint(&OSO[ii+8], &oso[ii+8]);
      }

      swapshort(&OSO[to_NamObjDirOffset], &oso[to_NamObjDirOffset]);
      swapshort(&OSO[to_NamObjDirOffset + 2], &oso[to_NamObjDirOffset + 2]);
      for (ii = to_NamObjDirOffset + 4; ii < size; ii+=12)
      {
         swapshort(&OSO[ii], &oso[ii]);
         swapshort(&OSO[ii+2], &oso[ii+2]);
         swapshort(&OSO[ii+4], &oso[ii+4]);
         swapshort(&OSO[ii+6], &oso[ii+6]);
         swapint(&OSO[ii+8], &oso[ii+8]);
      }
   }
   else
      for (ii = to_GrpDscsOffset + 4; ii < size; ii+=12)
      {
         swapshort(&OSO[ii], &oso[ii]);
         swapshort(&OSO[ii+2], &oso[ii+2]);
         swapshort(&OSO[ii+4], &oso[ii+4]);
         swapshort(&OSO[ii+6], &oso[ii+6]);
         swapint(&OSO[ii+8], &oso[ii+8]);
      }

   /* All done!  Return the guy we malloc-ed either in *convertedOSO
    * or in input OSO buffer.
    */

   memcpy((char *) OSO, (char *) oso, size);
   om$dealloc(ptr=oso);
   return(1);
}

int bigend_portOMCluster(size, Cluster, convertedCluster, flag)
OMuint          size;
struct OMCluster_instance *Cluster, **convertedCluster;
unsigned char   flag;
{
   struct OMCluster_instance  *cluster;
   int                        oidOffset,
                              classidOffset,
                              to_OSOoffset,
                              ii;

   if ((int) *convertedCluster == (int) Cluster)
   {
      /* Caller did not provide a buffer for the converted cluster,
       * so he wants it returned in Cluster.  Allocate a temporary
       * cluster to store the converted cluster in, then return it
       * in place of the original Cluster.
       */
      if (!(cluster = (struct OMCluster_instance *) om$malloc(size = size)))
         return(0);
   }
   else
      cluster = *convertedCluster;

   for (ii=0; ii<(16 * 4); ii+=4)     /* Swap the first 16 ints */
      swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);
   swapshort((char *) &Cluster->lcd.w_cluster_num,
      (char *) &cluster->lcd.w_cluster_num);
   swapshort((char *) &Cluster->lcd.flags, (char *) &cluster->lcd.flags);
   swapint((char *) &Cluster->lcd.i_cur_bytes_allocated,
      (char *) &cluster->lcd.i_cur_bytes_allocated);

   /*
    * Ok.  We've converted the object header and the fixed part of
    * the OMCluster component.  Next we'll convert the filed_oid
    * vla (int), then the filed_classid vla (short), then finish
    * out the rest of the OMCluster component (ints).  We need to
    * get the vla offsets from the instance data itself to determine
    * the location and sizes of the vlas.  If this is a conversion
    * on read, then we use the offsets in 'cluster' (newly converted);
    * if this is a conversion for write, we use the offsets in 'Cluster'.
    */

   if (cluster->i_filed_oid_list_descr.i_offset)
      oidOffset = (int) &cluster->i_filed_oid_list_descr.i_offset -
         (int) cluster;
   else
      oidOffset = 0;
   if (cluster->w_filed_classid_list_descr.i_offset)
      classidOffset = (int) &cluster->w_filed_classid_list_descr.i_offset -
         (int) cluster;
   else
      classidOffset = 0;
   if (cluster->to_OSO)
      to_OSOoffset = (int) &cluster->to_OSO - (int) cluster;
   else
      to_OSOoffset = 0;
   if (flag == READ_PORT)
   {
      oidOffset += cluster->i_filed_oid_list_descr.i_offset;
      classidOffset += cluster->w_filed_classid_list_descr.i_offset;
      to_OSOoffset += cluster->to_OSO;
   }
   else
   {
      oidOffset += Cluster->i_filed_oid_list_descr.i_offset;
      classidOffset += Cluster->w_filed_classid_list_descr.i_offset;
      to_OSOoffset += Cluster->to_OSO;
   }
   if (oidOffset)
      for (ii=oidOffset; ii<classidOffset; ii+=4)
         swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);

   if (classidOffset)
      for (ii=classidOffset; ii<to_OSOoffset; ii+=2)
         swapshort(&((char *) Cluster)[ii], &((char *) cluster)[ii]);

   if (to_OSOoffset)
   {
      for (ii=to_OSOoffset; ii<(to_OSOoffset + 8); ii+=2)
         swapshort(&((char *) Cluster)[ii], &((char *) cluster)[ii]);
      for (ii=to_OSOoffset + 8; ii<(to_OSOoffset + 16); ii+=4)
         swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);
   }
   if ((int) *convertedCluster == (int) Cluster)
   {
      memcpy((char *) *convertedCluster, (char *) cluster, size);
   }
   if (cluster->lcd.w_cluster_num)
      om$dealloc(ptr=cluster);
   return(1);
}


int bigend_portOMOSCO(size, OSCO, flag)
OMuint                  size;
struct OMOSCO_instance  *OSCO;
unsigned char           flag;
{
   struct OMOSCO_instance  *osco;
   int                     ii,
                           to_OSOoffset,
                           compOffset,
                           compCount,
                           vlaOffset,
                           vlaCount,
                           chanOffset,
                           chanCount,
                           resclassOffset,
                           resclassCount,
                           resOffset,
                           resCount;

   if (!(osco = (struct OMOSCO_instance *) om$malloc(size=size)))
      return(0);

   memcpy((char *) osco, (char *) OSCO, size);
   swapint(&osco->oid, &OSCO->oid);
   swapint(&osco->i_size, &OSCO->i_size);
   swapshort(&osco->OSCO.w_classid, &OSCO->OSCO.w_classid);
   swapshort(&osco->OSCO.w_child_refcnt, &OSCO->OSCO.w_child_refcnt);
   swapshort(&osco->OSCO.w_oppmaj_version, &OSCO->OSCO.w_oppmaj_version);
   swapshort(&osco->OSCO.w_oppmin_version, &OSCO->OSCO.w_oppmin_version);
   swapshort(&osco->OSCO.w_major_version, &OSCO->OSCO.w_major_version);
   swapshort(&osco->OSCO.w_minor_version, &OSCO->OSCO.w_minor_version);
   swapint(&osco->OSCO.i_refcnt, &OSCO->OSCO.i_refcnt);
   swapint(&osco->OSCO.OSCO_oid, &OSCO->OSCO.OSCO_oid);
   swapint(&osco->to_OSO, &OSCO->to_OSO);
   swapint(&osco->component_list_descr.i_offset,
      &OSCO->component_list_descr.i_offset);
   swapint(&osco->component_list_descr.i_count,
      &OSCO->component_list_descr.i_count);
   swapint(&osco->vla_list_descr.i_offset, &OSCO->vla_list_descr.i_offset);
   swapint(&osco->vla_list_descr.i_count, &OSCO->vla_list_descr.i_count);
   swapint(&osco->chan_info_descr.i_offset, &OSCO->chan_info_descr.i_offset);
   swapint(&osco->chan_info_descr.i_count, &OSCO->chan_info_descr.i_count);
   swapint(&osco->res_classname_descr.i_offset,
      &OSCO->res_classname_descr.i_offset);
   swapint(&osco->res_classname_descr.i_count,
      &OSCO->res_classname_descr.i_count);
   swapint(&osco->res_channum_descr.i_offset,
      &OSCO->res_channum_descr.i_offset);
   swapint(&osco->res_channum_descr.i_count,
      &OSCO->res_channum_descr.i_count);
   swapint(&osco->component_size, &OSCO->component_size);
   swapint(&osco->num_parents, &OSCO->num_parents);
   if (osco->to_OSO)
      to_OSOoffset = (int) &osco->to_OSO - (int) osco;
   else
      to_OSOoffset = 0;
   if (osco->component_list_descr.i_offset)
      compOffset = (int) &OSCO->component_list_descr.i_offset - (int) OSCO;
   else
      compOffset = 0;
   if (osco->vla_list_descr.i_offset)
      vlaOffset = (int) &OSCO->vla_list_descr.i_offset - (int) OSCO;
   else
      vlaOffset = 0;
   if (osco->chan_info_descr.i_offset)
      chanOffset = (int) &OSCO->chan_info_descr.i_offset - (int) OSCO;
   else
      chanOffset = 0;
   if (osco->res_classname_descr.i_offset)
      resclassOffset = (int) &OSCO->res_classname_descr.i_offset - (int) OSCO;
   else
      resclassOffset = 0;
   if (osco->res_channum_descr.i_offset)
      resOffset = (int) &OSCO->res_channum_descr.i_offset - (int) OSCO;
   else
      resOffset = 0;
   if (flag == READ_PORT)
   {
      to_OSOoffset += OSCO->to_OSO;
      compOffset += OSCO->component_list_descr.i_offset;
      compCount = OSCO->component_list_descr.i_count;
      vlaOffset += OSCO->vla_list_descr.i_offset;
      vlaCount = OSCO->vla_list_descr.i_count;
      chanOffset += OSCO->chan_info_descr.i_offset;
      chanCount = OSCO->chan_info_descr.i_count;
      resclassOffset += OSCO->res_classname_descr.i_offset;
      resOffset += OSCO->res_channum_descr.i_offset;
      resCount = OSCO->res_channum_descr.i_count;
   }
   else
   {
      to_OSOoffset += osco->to_OSO;
      compOffset += osco->component_list_descr.i_offset;
      compCount = osco->component_list_descr.i_count;
      vlaOffset += osco->vla_list_descr.i_offset;
      vlaCount = osco->vla_list_descr.i_count;
      chanOffset += osco->chan_info_descr.i_offset;
      chanCount = osco->chan_info_descr.i_count;
      resclassOffset += osco->res_classname_descr.i_offset;
      resOffset += osco->res_channum_descr.i_offset;
      resCount = osco->res_channum_descr.i_count;
   }
   if (to_OSOoffset)
   {
      for (ii=to_OSOoffset; ii<(to_OSOoffset + 8); ii+=2)
         swapshort(&((char *) osco)[ii], &((char *) OSCO)[ii]);
      for (ii=to_OSOoffset + 8; ii<(to_OSOoffset + 16); ii+=4)
         swapint(&((char *) osco)[ii], &((char *) OSCO)[ii]);
   }
   if (compOffset)
      for (ii=0; ii<compCount; ii++, compOffset+=4)
      {
         swapshort(&((char *) osco)[compOffset],
            &((char *) OSCO)[compOffset]);
         swapshort(&((char *) osco)[compOffset+2],
            &((char *) OSCO)[compOffset+2]);
      }
   if (vlaOffset)
      for (ii=0; ii<vlaCount; ii++, vlaOffset+=4)
      {
         swapshort(&((char *) osco)[vlaOffset],
            &((char *) OSCO)[vlaOffset]);
         swapshort(&((char *) osco)[vlaOffset+2],
            &((char *) OSCO)[vlaOffset+2]);
      }
   if (chanOffset)
      for (ii=0; ii<chanCount; ii++, chanOffset+=4)
      {
         swapshort(&((char *) osco)[chanOffset],
            &((char *) OSCO)[chanOffset]);
         swapshort(&((char *) osco)[chanOffset+2],
            &((char *) OSCO)[chanOffset+2]);
      }
   if (resOffset)
      for (ii=0; ii<resCount; ii++, resOffset+=2)
         swapshort(&((char *) osco)[resOffset], &((char *) OSCO)[resOffset]);
   om$dealloc(ptr=osco);

   return(1);
}


int bigend_portOMISO(size, ISO, flag)
OMuint                  size;
struct OMISO_instance   *ISO;
unsigned char           flag;
{
   struct OMISO_instance   *iso;
   int                     ii,
                           vlaOffset,
                           vlaCount;

   if (!(iso = (struct OMISO_instance *) om$malloc(size=size)))
      return(0);

   memcpy((char *) iso, (char *) ISO, size);    /* Copy ISO to iso */
   swapint(&iso->oid, &ISO->oid);
   swapint(&iso->i_size, &ISO->i_size);
   swapshort(&iso->osnum, &ISO->osnum);
   swapshort(&iso->w_ISO_flags, &ISO->w_ISO_flags);
   swapshort(&iso->w_dcount, &ISO->w_dcount);
   swapshort(&iso->w_dummy, &ISO->w_dummy);
   swapint(&iso->S_target_iso, &ISO->S_target_iso);
   swapint(&iso->i_first, &ISO->i_first);
   swapint(&iso->iso_d_descr.i_offset, &ISO->iso_d_descr.i_offset);
   swapint(&iso->iso_d_descr.i_count, &ISO->iso_d_descr.i_count);

   if (ISO->iso_d_descr.i_count)
      vlaOffset = (int) &ISO->iso_d_descr.i_offset - (int) ISO;
   else
      vlaOffset = 0;
   if (flag == READ_PORT)
   {
      vlaOffset += ISO->iso_d_descr.i_offset;
      vlaCount = ISO->iso_d_descr.i_count;
   }
   else
   {
      vlaOffset += iso->iso_d_descr.i_offset;
      vlaCount = iso->iso_d_descr.i_count;
   }

   if (vlaOffset)
   {
      for (ii=0; (ii<vlaCount) && (vlaOffset<size) ; ii++, vlaOffset+=12)
      {
         swapshort(&((char *) iso)[vlaOffset],
            &((char *) ISO)[vlaOffset]);
         swapshort(&((char *) iso)[vlaOffset+2],
            &((char *) ISO)[vlaOffset+2]);
         swapshort(&((char *) iso)[vlaOffset+4],
            &((char *) ISO)[vlaOffset+4]);
         swapshort(&((char *) iso)[vlaOffset+6],
            &((char *) ISO)[vlaOffset+6]);
         swapint(&((char *) iso)[vlaOffset+8],
            &((char *) ISO)[vlaOffset+8]);
      }
   }

   om$dealloc(ptr=iso);
   return(1);
}


int bigend_portOMGroup(size, GROUP, flag)
OMuint                  size;
struct OMGroup_instance   *GROUP;
unsigned char           flag;
{
   struct OMGroup_instance   *group;
   int                     ii,
                           to_OSOoffset,
                           to_parentOffset,
                           vlaOffset,
                           vlaCount;

   if (!(group = (struct OMGroup_instance *) om$malloc(size=size)))
      return(0);

   memcpy((char *) group, (char *) GROUP, size);   /* Copy GROUP to group */
   swapint(&group->oid, &GROUP->oid);
   swapint(&group->i_size, &GROUP->i_size);
   swapint(&group->groupid, &GROUP->groupid);
   swapshort(&group->clusternum, &GROUP->clusternum);
   swapint(&group->size, &GROUP->size);
   swapint(&group->initial_size, &GROUP->initial_size);
   swapint(&group->extend_size, &GROUP->extend_size);
   swapint(&group->next_avail, &GROUP->next_avail);

   swapint(&group->to_OSO, &GROUP->to_OSO);
   swapint(&group->to_parent, &GROUP->to_parent);
   swapint(&group->extent_descr.i_offset, &GROUP->extent_descr.i_offset);
   swapint(&group->extent_descr.i_count, &GROUP->extent_descr.i_count);

   if (group->to_OSO)
      to_OSOoffset = (int) &GROUP->to_OSO - (int) GROUP;
   else
      to_OSOoffset = 0;
   if (group->to_parent)
      to_parentOffset = (int) &GROUP->to_parent - (int) GROUP;
   else
      to_parentOffset = 0;
   if (GROUP->extent_descr.i_count)
      vlaOffset = (int) &GROUP->extent_descr.i_offset - (int) GROUP;
   else
      vlaOffset = 0;
   if (flag == READ_PORT)
   {
      to_OSOoffset += GROUP->to_OSO;
      to_parentOffset += GROUP->to_parent;
      vlaOffset += GROUP->extent_descr.i_offset;
      vlaCount = GROUP->extent_descr.i_count;
   }
   else
   {
      to_OSOoffset += group->to_OSO;
      to_parentOffset += group->to_parent;
      vlaOffset += group->extent_descr.i_offset;
      vlaCount = group->extent_descr.i_count;
   }

   if (vlaOffset)
   {
      for (ii=vlaOffset; ii<(vlaOffset + (vlaCount*2)); ii+=4)
         swapint(&((char *) group)[ii], &((char *) GROUP)[ii]);
   }
   if (to_OSOoffset)
   {
      for (ii=to_OSOoffset; ii<(to_OSOoffset + 8); ii+=2)
         swapshort(&((char *) group)[ii], &((char *) GROUP)[ii]);
      for (ii=to_OSOoffset + 8; ii<(to_OSOoffset + 16); ii+=4)
         swapint(&((char *) group)[ii], &((char *) GROUP)[ii]);
   }
   if (to_parentOffset)
   {
      for (ii=to_parentOffset; ii<(to_parentOffset + 8); ii+=2)
         swapshort(&((char *) group)[ii], &((char *) GROUP)[ii]);
      for (ii=to_parentOffset + 8; ii<(to_parentOffset + 16); ii+=4)
         swapint(&((char *) group)[ii], &((char *) GROUP)[ii]);
   }

   om$dealloc(ptr=group);
   return(1);
}

int bigend_portOMTagCon(size, TAGCON, flag)
OMuint                  size;
struct OMTagCon_instance   *TAGCON;
unsigned char           flag;
{
   struct OMTagCon_instance   *tagcon;
   int                        ii,
                              to_OSOoffset,
                              vlaOffset,
                              vlaCount;

   if (!(tagcon = (struct OMTagCon_instance *) om$malloc(size=size)))
      return(0);

   memcpy((char *) tagcon, (char *) TAGCON, size);
   swapint(&tagcon->oid, &TAGCON->oid);
   swapint(&tagcon->i_size, &TAGCON->i_size);
   swapshort(&tagcon->first_tag, &TAGCON->first_tag);
   swapshort(&tagcon->first_free, &TAGCON->first_free);
   swapint(&tagcon->count, &TAGCON->count);
   swapint(&tagcon->to_OSO, &TAGCON->to_OSO);
   swapint(&tagcon->con_rec_descr.i_offset, &TAGCON->con_rec_descr.i_offset);
   swapint(&tagcon->con_rec_descr.i_count, &TAGCON->con_rec_descr.i_count);

   if (TAGCON->to_OSO)
      to_OSOoffset = (int) &TAGCON->to_OSO - (int) TAGCON;
   else
      to_OSOoffset = 0;
   if (TAGCON->con_rec_descr.i_count)
      vlaOffset = (int) &TAGCON->con_rec_descr.i_offset - (int) TAGCON;
   else
      vlaOffset = 0;
   if (flag == READ_PORT)
   {
      to_OSOoffset += TAGCON->to_OSO;
      vlaOffset += TAGCON->con_rec_descr.i_offset;
      vlaCount = TAGCON->con_rec_descr.i_count;
   }
   else
   {
      to_OSOoffset += tagcon->to_OSO;
      vlaOffset += tagcon->con_rec_descr.i_offset;
      vlaCount = tagcon->con_rec_descr.i_count;
   }

   if (vlaOffset)
   {
      for (ii=0; ii<vlaCount; ii++, vlaOffset+=28)
      {
         swapint(&((char *) tagcon)[vlaOffset],
            &((char *) TAGCON)[vlaOffset]);
         swapint(&((char *) tagcon)[vlaOffset+4],
            &((char *) TAGCON)[vlaOffset+4]);
         swapshort(&((char *) tagcon)[vlaOffset+8],
            &((char *) TAGCON)[vlaOffset+8]);
         swapshort(&((char *) tagcon)[vlaOffset+10],
            &((char *) TAGCON)[vlaOffset+10]);
         swapshort(&((char *) tagcon)[vlaOffset+12],
            &((char *) TAGCON)[vlaOffset+12]);
         swapshort(&((char *) tagcon)[vlaOffset+14],
            &((char *) TAGCON)[vlaOffset+14]);
         swapshort(&((char *) tagcon)[vlaOffset+16],
            &((char *) TAGCON)[vlaOffset+16]);
         swapshort(&((char *) tagcon)[vlaOffset+18],
            &((char *) TAGCON)[vlaOffset+18]);
         swapshort(&((char *) tagcon)[vlaOffset+20],
            &((char *) TAGCON)[vlaOffset+20]);
         swapshort(&((char *) tagcon)[vlaOffset+22],
            &((char *) TAGCON)[vlaOffset+22]);
         swapshort(&((char *) tagcon)[vlaOffset+24],
            &((char *) TAGCON)[vlaOffset+24]);
         swapshort(&((char *) tagcon)[vlaOffset+26],
            &((char *) TAGCON)[vlaOffset+26]);
      }
   }
   if (to_OSOoffset)
   {
      for (ii=to_OSOoffset; ii<(to_OSOoffset + 8); ii+=2)
         swapshort(&((char *) tagcon)[ii], &((char *) TAGCON)[ii]);
      for (ii=to_OSOoffset + 8; ii<(to_OSOoffset + 16); ii+=4)
         swapint(&((char *) tagcon)[ii], &((char *) TAGCON)[ii]);
   }

   om$dealloc(ptr=tagcon);
   return(1);
}

int bigend_portOMTag(size, TAG, flag)
OMuint                  size;
struct OMTag_instance   *TAG;
unsigned char           flag;
{
   struct OMTag_instance   *tag;
   int                     ii,
                           to_OSOoffset,
                           vlaOffset,
                           vlaCount,
                           limit;

   if (!(tag = (struct OMTag_instance *) om$malloc(size=size)))
      return(0);

   memcpy((char *) tag, (char *) TAG, size);
   swapint(&tag->oid, &TAG->oid);
   swapint(&tag->i_size, &TAG->i_size);

   swapint(&tag->next_tag, &TAG->next_tag);
   swapint(&tag->num_tags, &TAG->num_tags);
   swapint(&tag->h_free, &TAG->h_free);
   swapint(&tag->next_index, &TAG->next_index);
   swapshort(&tag->flags, &TAG->flags);
   swapint(&tag->hash_block_size, &TAG->hash_block_size);
   swapint(&tag->tag_rec_descr.i_offset, &TAG->tag_rec_descr.i_offset);
   swapint(&tag->tag_rec_descr.i_count, &TAG->tag_rec_descr.i_count);
   swapint(&tag->to_OSO, &TAG->to_OSO);

   if (TAG->to_OSO)
      to_OSOoffset = (int) &TAG->to_OSO - (int) TAG;
   else
      to_OSOoffset = 0;
   if (TAG->tag_rec_descr.i_count)
      vlaOffset = (int) &TAG->tag_rec_descr.i_offset - (int) TAG;
   else
      vlaOffset = 0;
   if (flag == READ_PORT)
   {
      to_OSOoffset += TAG->to_OSO;
      vlaOffset += TAG->tag_rec_descr.i_offset;
      vlaCount = TAG->tag_rec_descr.i_count;
   }
   else
   {
      to_OSOoffset += tag->to_OSO;
      vlaOffset += tag->tag_rec_descr.i_offset;
      vlaCount = tag->tag_rec_descr.i_count;
   }

   limit = to_OSOoffset ? to_OSOoffset : size;
   if (vlaOffset)
   {
      for (ii=0; (ii<vlaCount) && (vlaOffset<limit); ii++, vlaOffset+=12)
      {
         swapint(&((char *) tag)[vlaOffset],
            &((char *) TAG)[vlaOffset]);
         swapint(&((char *) tag)[vlaOffset+4],
            &((char *) TAG)[vlaOffset+4]);
         swapshort(&((char *) tag)[vlaOffset+8],
            &((char *) TAG)[vlaOffset+8]);
      }
   }
   if (to_OSOoffset)
   {
      for (ii=to_OSOoffset; ii<(to_OSOoffset + 8); ii+=2)
         swapshort(&((char *) tag)[ii], &((char *) TAG)[ii]);
      for (ii=to_OSOoffset + 8; ii<size; ii+=4)
         swapint(&((char *) tag)[ii], &((char *) TAG)[ii]);
   }
   om$dealloc(ptr=tag);
   return(1);
}

int bigend_portOMrtree(size, RTREE, flag)
OMuint         size;
char           *RTREE;
unsigned char  flag;
{
   struct   OMrtree_instance
   {
      OMuint   oid;
      OMuint   i_size;
      int      count;
      OMuint   objid;
      char     Page_type;
      char     Rtree_type;
      char     Key_count;
      char     Filler_1;
      int      Page_count;
      int      Key[1020];
      char     filler[500];
   } rtree, *Rtree;
   int         ii;

   Rtree = (struct OMrtree_instance *) RTREE;
   swapint(&Rtree->oid, &rtree.oid);
   swapint(&Rtree->i_size, &rtree.i_size);
   swapint(&Rtree->count, &rtree.count);
   swapint(&Rtree->objid, &rtree.objid);
   rtree.Page_type = Rtree->Page_type;
   rtree.Rtree_type = Rtree->Rtree_type;
   rtree.Key_count = Rtree->Key_count;
   rtree.Filler_1 = Rtree->Filler_1;
   swapint(&Rtree->Page_count, &rtree.Page_count);
   for (ii=(int) &rtree.Key[0] - (int) &rtree.oid; ii<4096; ii+=4)
      swapint(&((char *) Rtree)[ii], &((char *) &rtree.oid)[ii]);

   memcpy((char *) RTREE, (char *) &rtree.oid, size);
   return(1);
}
#endif   /* _BIG_ENDIAN */
