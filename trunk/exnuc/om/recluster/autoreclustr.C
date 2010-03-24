/*====================================================================*
 *                                                                    *
 *                        REAUTOCLUSTER UTILITY                       *
 *                                                                    *
 *  This program acts on a filed object space, regrouping objects     *
 *  into logical clusters so as to make the most efficient use of     *
 *  memory when loaded by OM.  The new reclustered object space is    *
 *  written to a new file, leaving the original file intact.  Users   *
 *  may specify the physical cluster size limit to use (default is    *
 *  30720 bytes), as well as which existing logical clusters to       *
 *  leave as they are.  The purpose of reautoclustering is to correct *
 *  fragmentation of OM memory caused by random deletion of objects,  *
 *  leaving many less-than-half-full logical clusters (caused mainly  *
 *  by EMS "file fence" operation).                                   *
 *                                                                    *
 *====================================================================*/


/*
   Oct 6th 1994 3.1  Made provision to grow 'newfiled_oid' and
		     'nefiled_classid' arrays as required. Previously
		     it was assumed that the count of new Cluster0
		     objects would at the most be double of existing
		     count in the process of reclustering an OS. -Mohan


   June 1993   2.4   Add support for filenames longer than 14 chars.
                     OM_K_MAXOSNAME_LEN is the upper limit on OS file
                     names.  MAXPATHLEN is the limit on the entire
                     pathname of an OS file.  This change doesn't
                     affect CLIX systems, which are still limited to
                     14-char filenames.
                     Also, go ahead and delete empty cluster objects
                     without calling OM to do it.  Remove OM stage
                     (which was only called to do a proper delete of
                     the empty OMCluster objects) and save substantially
                     on memory & disk overhead.  Any damage done will
                     be in writeControlData.
*/


#include    "exsysdep.h"

#include    <stdio.h>
#include    <fcntl.h>
#include    <ctype.h>
#include    <time.h>
#include    <errno.h>
#include    <sys/utsname.h>
#include    <sys/param.h>
#include    <signal.h>
#include    <unistd.h>
#include    <sys/stat.h>

#include    "OMminimum.h"
#include    "OMparameters.h"
#include    "OMOSfilehdr.h"
#include    "OMmetaclass.h"
#include    "OMerrordef.h"
#include    "version.h"

#ifdef BIG_ENDIAN
#include    "OMport.h"

extern void    som_swapint();
extern void    som_swapshort();

#define	BLOCKMOVE(count, src, dest) memcpy(dest, src, count)
#endif

#ifdef SVR4
#define _NSIG	34
#endif

#if defined (IRIX) || defined (BSD)
#if defined (IRIX5)
#define NSIG 34
#endif
#define _NSIG  NSIG
#endif

#define  GETOBJSIZE(size)  ((size & 0x7ffffff8) - 8)
#define  OMFILEHDRSIZE  512
#define  BLOCKSIZE      512
#define  ALIGN(x)    (((x) + 7) & ~7)
#define  OMCLUSTERSIZE  ALIGN(sizeof(struct OMCluster_instance))

/* Define size of buffers used for storing file names */

#define  MAXFILENAMELEN 14

/*
#ifdef CLIX
#define  MAXFILENAMELEN 14
#else
#define  MAXFILENAMELEN OM_K_MAXOSNAME_LEN
#endif
*/


#define  READIT(buffer, bufsize) \
{ \
            if (fread(buffer, 1, bufsize, osfp) != bufsize) \
            { \
               fprintf(stdout, "autorecluster: fread failed at loc %d.  Attempted read size %d\n", \
                  ftell(osfp), bufsize); \
               return(0); \
            } \
}

#define  WRITEIT(buffer, bufsize) \
{ \
            if (fwrite(buffer, 1, bufsize, outfp) != bufsize) \
            { \
               fprintf(stdout, "autorecluster: fwrite failed at loc: %d.  Attempted write size: %d\n", \
                  ftell(outfp), bufsize); \
               return(0); \
            } \
}

extern int     optind;
extern char    *optarg;
extern char    EX_runname[];

#ifdef BIG_ENDIAN
   int      tempint;
   short    tempshort;
#endif

unsigned int   osoSize,         /* Size field from OSO obj header */
               oscoSize,        /* Size field from cluster OSCO obj header */
               clustersSize,    /* From OSD.  Changes if add or delete clstrs */
               newClustersSize, /* Greater of largest cnum or clustersSize */
               clustCnt,        /* Current number of cluster objects */
               objCnt,          /* Current count of cluster 0 objects */
               numC0Objs,       /* Total number of cluster 0 objects */
               objsToRecluster, /* Sum of objs in clusters to recluster */
               firstObjfp,      /* File position just beyond header info */
               phyClustSize,    /* Physical cluster size (default 30720) */
               stetIndex,       /* Size of stet clusters array */
               c0pos,           /* Current file pos into new cluster 0 */
               inpos,           /* File position within input file */
               outpos,          /* Non-cluster 0 file pos within output file */
               *c0filed_oid,    /* Original cluster 0 filed oid list */
               *newfiled_oid,   /* Filed oid list for new cluster 0 */
               newIndex,        /* Index of new cluster 0 filed oid list */
               *oidList,        /* Array size of spacemap to show free oids */
               oidListIndex,    /* Where to start looking for free oid */
               *deleteOids,     /* Array of oids to delete after reclustering */
               toClusDscsSize,  /* Current size of the to_ClusDscs channel */
               origToClusDscsSize;

unsigned int	newCount,	/*  Purify fix    -Mohan  10/06/94  */
		non_aligned_size,
		is_aligned = 0;

FILE           *osfp, *outfp, *fopen();   /* osfp is the original obj space */
unsigned short *c0filed_classid, *newfiled_classid;
char           includeUserSpec, verbose;  /* Flags for command line options */
char           appVer[BLOCKSIZE*9];
char           pid[6], node[10]; /* Used with file locking */
char           inLockFile[MAXPATHLEN+1], outLockFile[MAXPATHLEN+1];

void   (*sig_func[_NSIG])() = {SIG_ERR, SIG_ERR};

INGR_p_PRODUCT_DEF OM_GA_appl_version[32];
int               OM_Gi_number_of_appl_ids;

struct OMObjSpace_instance 
{
   char        CreTimeDate[16];
   char        TimeDate[16];
   struct OM_sd_OS_filehdr_OM *p_filehdr;
   struct OM_sd_OSD OSD;
   int         OS_HoleCount;
   struct OM_sd_varlenarr_descr OS_holes_descr;
   int         FirstISO;
   struct OM_sd_varlenarr_descr iso_d_descr;
   struct OM_sd_varlenarr_descr freeoids_descr;
/* each one of the following fileds is a self-relative ptr to channel */
   int         to_OSCOs;	
   int         to_ClusDscs;
   int         to_GrpDscs;
   int         to_NamObjDir;
} *oso;
struct OMCluster_instance 
{
   struct OM_sd_varlenarr_descr i_filed_oid_list_descr;
   struct OM_sd_varlenarr_descr w_filed_classid_list_descr;
   unsigned int   i_my_file_ptr;
   unsigned int   i_fil_num_objects;
   unsigned int   i_fil_byte_size;
   unsigned int   to_OSO;
   OM_S_LCD       lcd;
};

struct cluster_to_OSO
{
   unsigned short flags;
   unsigned short count;
   unsigned short classid;
   unsigned short number;
   unsigned int   oid;
   unsigned int   align;
} toOSOchan;

struct OMOSCO_instance
{
   OM_S_OSCO                     OSCO;
   unsigned int                  to_OSO;
   struct OM_sd_varlenarr_descr  component_list_descr;
   struct OM_sd_varlenarr_descr  vla_list_descr;
   struct OM_sd_varlenarr_descr  chan_info_descr;
   struct OM_sd_varlenarr_descr  res_classname_descr;
   struct OM_sd_varlenarr_descr  res_channum_descr;
   int                           component_size;
   unsigned short                num_parents;
} *clusterOsco;
struct chan
{
   unsigned short flags;
   unsigned short count;
};
struct chanLink
{
   unsigned short flags;
   unsigned short count;
   unsigned short classid;
   unsigned short number;
   unsigned int   oid;
};
struct bigTail
{
   unsigned int   collapse_count;
   unsigned int   last_index;
   unsigned int   size;
};
struct littleTail
{
   unsigned short collapse_count;
   unsigned short last_index;
};
struct chan      *toClusDscs;

struct chanLink  nullToClusDscs = {0, 0, 0, 0, 0xffffffff};
/*
struct chanLink  toClusDscsEntry = {0x0100, 0x0000, 1, 0, 0xffffffff};
*/

struct OMCluster_instance     *clus0, **clustArr;
struct OM_sd_OS_filehdr_OM filehdr, hdr;
unsigned short                *stetList; /* Clus nums given with -s (stet) */
char                          filename[MAXPATHLEN+1], outfile[MAXPATHLEN+1];


OM_S_FILEOBJHDR   objHdr;

void sigtrap(sig)
int   sig;
{
   fclose(osfp);
   fclose(outfp);
   unlink(outfile);
   modifyAccess(inLockFile, 'V');
   modifyAccess(outLockFile, 'V');
   sig_func[sig](sig);
   exit(0);
}

/*====================================================================*
 *                                                                    *
 *  writeControlData()                                                *
 *                                                                    *
 *  All non-OM clusters and their cluster objects have been written.  *
 *  Update the OMCluster OSCO reference count to reflect the new      *
 *  number of cluster objects and write the OSCO.  Update the OSO     *
 *  and write it.  Update the file header and write it.  All done.    *
 *                                                                    *
 *====================================================================*/
writeControlData()
{
   int   ii, objSize;

   objHdr.tag = 0;            /* No Cluster 0 objects have tags */
   objHdr.version = 0;

   /*=========================================================*/
   /* Write the osco for OMCluster containing current count   */
   /* of cluster objects.  Write the new OSO and file header. */
   /*=========================================================*/
   fseek(osfp, filehdr.fp_appver, 0);
   if (filehdr.i_num_appver)
   {
      int   size, ofp;
      size = OM_K_APPVER_LEN * filehdr.i_num_appver;
      ofp = filehdr.fp_appver + (size + (BLOCKSIZE - (size % BLOCKSIZE)));
      if (fread(appVer, 1, (ofp - OMFILEHDRSIZE), osfp) !=
         (ofp - OMFILEHDRSIZE))
      {
         fprintf(stdout, "Read error reading application version stamps.\n");
         return(0);
      }
   }
   fclose(osfp);

   /* Write the updated OSCO for class OMCluster */

   if (!clusterOsco)
      return(0);
   clusterOsco->OSCO.i_refcnt = clustCnt;
   filehdr.w_num_clusters = clustCnt + 1; /* Include OSO tho not an OMCluster */

/******   TR 119422055     -Mohan
   newfiled_oid[newIndex] = clusterOsco->OSCO.OSCO_oid;
   newfiled_classid[newIndex++] = OM_K_OMOSCO_ACTCLASSID;
*******/

   if( !(newIndex < newCount) )
   {
     newCount += 50;
     newfiled_oid = (unsigned int *)realloc( newfiled_oid, newCount * 4 );
     newfiled_classid = (unsigned short *)realloc( newfiled_classid, newCount * 2 );
   }
   newfiled_oid[newIndex] = clusterOsco->OSCO.OSCO_oid;
   newfiled_classid[newIndex++] = OM_K_OMOSCO_ACTCLASSID;

#ifdef BIG_ENDIAN
   objHdr.classid = 0x0b00;
   som_swapint(&clusterOsco->OSCO.OSCO_oid, &objHdr.oid);
   tempint = (oscoSize +8) | OM_OHf_has_VLA;
   som_swapint(&tempint, &objHdr.i_size);
   bigend_portOMOSCO(oscoSize, clusterOsco, WRITE_PORT);
#else
   objHdr.classid = OM_K_OMOSCO_ACTCLASSID;
   objHdr.oid = clusterOsco->OSCO.OSCO_oid;
   objHdr.i_size = (oscoSize + 8) | OM_OHf_has_VLA;
#endif

   fseek(outfp, c0pos, 0);
   WRITEIT(&objHdr, sizeof(OM_S_FILEOBJHDR));
   fwrite(clusterOsco, 1, oscoSize, outfp);
   c0pos += oscoSize + sizeof(OM_S_FILEOBJHDR);

   /* Generate a new OSO and write it */

   ((struct OMObjSpace_instance *) (((char *) clus0) + OMCLUSTERSIZE))->
      OSD.ClustersSize = newClustersSize;

/*******    TR 119422055    -Mohan
   if ((toClusDscsSize != origToClusDscsSize) && (toClusDscsSize % 8))
      toClusDscsSize = ALIGN(toClusDscsSize);
********/

   if ((toClusDscsSize != origToClusDscsSize) && (toClusDscsSize % 8))
   {
      is_aligned = 1;
      non_aligned_size = toClusDscsSize;
      toClusDscsSize = ALIGN(toClusDscsSize);
   }

/********   TR 119422055   -Mohan
   newfiled_oid[newIndex] = clus0->lcd.oid;
   newfiled_classid[newIndex++] = OM_K_OMFILEDOS_ACTCLASSID;
*********/

   if( !(newIndex < newCount) )
   {
     newCount += 50;
     newfiled_oid = (unsigned int *)realloc( newfiled_oid, newCount * 4 );
     newfiled_classid = (unsigned short *)realloc( newfiled_classid, newCount * 2 );
   }
   newfiled_oid[newIndex] = clus0->lcd.oid;
   newfiled_classid[newIndex++] = OM_K_OMFILEDOS_ACTCLASSID;

   filehdr.fp_OSO = ftell(outfp);

   objHdr.oid = 0;
#ifdef BIG_ENDIAN
   objHdr.classid = 0x0700;
#else
   objHdr.classid = OM_K_OMFILEDOS_ACTCLASSID;
#endif

   if ((newIndex != clus0->i_fil_num_objects) ||
      (toClusDscsSize != origToClusDscsSize))
   {
      /* Number of OMCluster objects has changed due to reclustering */

      int                        diffVlas, diffAll;
      unsigned int               oidSize, classidSize;
      struct OMCluster_instance  *newClus0;
      struct OMObjSpace_instance *newOSO;

#ifdef BIG_ENDIAN
      struct OMObjSpace_instance *oldOSO;
#endif

      /* We added or deleted some OMCluster objects as a result of
       * reclustering the file.  The filed_oid and filed_classid
       * vla's have grown or shrunk, so we must adjust vla and
       * channel offsets throughout the OSO.
       */

      diffVlas = (((oidSize = ALIGN(newIndex * 4)) -
         ALIGN(clus0->i_fil_num_objects * 4)) +
         ((classidSize = ALIGN(newIndex * 2)) -
         ALIGN(clus0->i_fil_num_objects * 2)));
      diffAll = diffVlas + (toClusDscsSize - origToClusDscsSize);

      osoSize = GETOBJSIZE(osoSize);  /* Size of old OSO minus header */
      objSize = (int) osoSize + diffAll;  /* New size (no flags, no header) */

#ifdef BIG_ENDIAN
      /* Make the buffer big enough to hold the object header
       * (objSize), then change newClus0 to point beyond the
       * header and subtract header size from objSize.
       */

      if (!(newClus0 = (struct OMCluster_instance *) calloc(1,
         objSize)))    /* Object size + obj header size */
      {
         fprintf(stdout,
            "autorecluster: Could not allocate memory for new OSO (%d bytes).\n",
            objSize);
         return(0);
      }
      objSize -= 8;
      newClus0 = (struct OMCluster_instance *) ((int) newClus0 + 8);
#else
      if (!(newClus0 = (struct OMCluster_instance *) calloc(1, objSize)))
      {
         fprintf(stdout,
            "autorecluster: Could not allocate memory for new OSO (%d bytes).\n",
            objSize);
         return(0);
      }
#endif

      newClus0->i_filed_oid_list_descr.i_offset = OMCLUSTERSIZE +
         ALIGN(sizeof(struct OMObjSpace_instance));
      newClus0->i_filed_oid_list_descr.i_count = newIndex;
      newClus0->w_filed_classid_list_descr.i_offset =
         clus0->w_filed_classid_list_descr.i_offset + (oidSize -
         ALIGN(clus0->i_fil_num_objects * 4));
      newClus0->w_filed_classid_list_descr.i_count = newIndex;
      newClus0->i_my_file_ptr = filehdr.fp_OSO;
      newClus0->i_fil_num_objects = newIndex;
      newClus0->lcd.i_file_ptr = clus0->lcd.i_file_ptr;
      newClus0->i_fil_byte_size = (newClus0->i_my_file_ptr -
         newClus0->lcd.i_file_ptr) + sizeof(OM_S_FILEOBJHDR) + objSize;
      newClus0->to_OSO = (int) clus0->to_OSO + diffVlas;

      newOSO = (struct OMObjSpace_instance *) ((char *) clus0 +
         OMCLUSTERSIZE);
      if (newOSO->OS_holes_descr.i_offset)
         newOSO->OS_holes_descr.i_offset += diffVlas;
      if (newOSO->iso_d_descr.i_offset)
         newOSO->iso_d_descr.i_offset += diffVlas;
      if (newOSO->freeoids_descr.i_offset)
         newOSO->freeoids_descr.i_offset += diffVlas;
      newOSO->to_OSCOs += diffVlas;
      newOSO->to_ClusDscs += diffVlas;

      if (newOSO->to_GrpDscs)
         newOSO->to_GrpDscs += diffAll;
      if (newOSO->to_NamObjDir)
         newOSO->to_NamObjDir += diffAll;

#ifdef BIG_ENDIAN
      oldOSO = newOSO;
      newOSO = (struct OMObjSpace_instance *) ((char *) newClus0 +
         OMCLUSTERSIZE);
      BLOCKMOVE(ALIGN(sizeof(struct OMObjSpace_instance)),
         (char *) oldOSO, (char *) newOSO);
#endif

      objSize = (objSize + 8) | OM_OHf_has_VLA;
      objHdr.i_size = objSize;

#ifdef BIG_ENDIAN
      WRITEIT(&objHdr, 8); /* Write part of obj header */

      /* Have to put all pieces of new OSO into one buffer so it may
       * be converted before being written to the file.
       */

      BLOCKMOVE(oidSize, (char *) newfiled_oid,
         (char *) ((int) &newClus0->i_filed_oid_list_descr.i_offset +
         newClus0->i_filed_oid_list_descr.i_offset));
      BLOCKMOVE(classidSize, (char *) newfiled_classid,
         (char *) ((int) &newClus0->w_filed_classid_list_descr.i_offset +
         newClus0->w_filed_classid_list_descr.i_offset));
      BLOCKMOVE(sizeof(struct cluster_to_OSO), (char *) &toOSOchan.flags,
         (char *) ((int) &newClus0->to_OSO + newClus0->to_OSO));

      BLOCKMOVE((((int) &(newOSO->to_ClusDscs) +
         (newOSO->to_ClusDscs-diffVlas)) -
         ((int) &(newOSO->OS_holes_descr) +
         ((int) newOSO->OS_holes_descr.i_offset - diffVlas))),
         (char *) ((int) &oldOSO->OS_holes_descr.i_offset +
         ((int) oldOSO->OS_holes_descr.i_offset - diffVlas)),
         (char *) ((int) &newOSO->OS_holes_descr.i_offset +
         newOSO->OS_holes_descr.i_offset));

/********   TR 119422055   -Mohan
      BLOCKMOVE(toClusDscsSize, (char *) toClusDscs,
         (char *) ((int) &newOSO->to_ClusDscs + newOSO->to_ClusDscs));
********/

      if( is_aligned )
         BLOCKMOVE(non_aligned_size, (char *) toClusDscs,
             (char *) ((int) &newOSO->to_ClusDscs + newOSO->to_ClusDscs));
      else
         BLOCKMOVE(toClusDscsSize, (char *) toClusDscs,
             (char *) ((int) &newOSO->to_ClusDscs + newOSO->to_ClusDscs));

      /* Move the remainder of the OSO data (the Group channel and
         the IGRdir channel).  'osoSize' in the Big Endian world
         is the size of the buffer containing the in-memory obj
         header, the OMCluster instance and the OMObjSpace instance.
         'clus0' points to the OMCluster instance.  'newOSO' points
         to the OMObjSpace instance.  'to_GrpDscs' has already been
         updated to reflect the size of the new OSO, so in the
         following BLOCKMOVE, you have to undo that update (subtract
         'diffAll').
       */

      BLOCKMOVE(((osoSize - 8) + (int) clus0) -
         ((int) &oldOSO->to_GrpDscs + ((int) oldOSO->to_GrpDscs - diffAll)),
         (char *) ((int) &oldOSO->to_GrpDscs + ((int) oldOSO->to_GrpDscs-diffAll)),
         (char *) ((int) &newOSO->to_GrpDscs + newOSO->to_GrpDscs));

      newClus0 = (struct OMCluster_instance *) ((int) newClus0 - 8);
      BLOCKMOVE(8, (char *) &objHdr.oid, (char *) newClus0);
      objSize &= 0x7ffffff8;  /* Clear flags */

      som_bigend_portOSO(objSize, newClus0, WRITE_PORT);
      WRITEIT(newClus0, objSize);
      som_bigend_portOSO(objSize, newClus0, READ_PORT);
      newClus0 = (struct OMCluster_instance *) ((int) newClus0 + 8);
      clus0 = (struct OMCluster_instance *) ((int) clus0 - 8);
#else
      WRITEIT(&objHdr, sizeof(OM_S_FILEOBJHDR)); /* Write obj header */
      WRITEIT(newClus0, OMCLUSTERSIZE);      /* Write cluster instance */
      WRITEIT(newOSO, (ALIGN(sizeof(struct OMObjSpace_instance)))); /* OSO */
      WRITEIT(newfiled_oid, oidSize);        /* filed_oid array (aligned) */
      WRITEIT(newfiled_classid, classidSize); /* filed_classid array (aligned) */
      WRITEIT(&toOSOchan, (sizeof(struct cluster_to_OSO)));  /* toOSO channel */

      /* Write from OS_holes array up to to_ClusDscs channel */

      WRITEIT(((char *) &(newOSO->OS_holes_descr.i_offset) +
         ((int) newOSO->OS_holes_descr.i_offset-diffVlas)),
         (((char *) &(newOSO->to_ClusDscs) + (newOSO->to_ClusDscs-diffVlas)) -
         ((char *) &(newOSO->OS_holes_descr) +
         ((int) newOSO->OS_holes_descr.i_offset - diffVlas))));

      WRITEIT((char *) toClusDscs, toClusDscsSize);

      WRITEIT(((char *) &(newOSO->to_GrpDscs) +
         ((int) newOSO->to_GrpDscs-diffAll)),
         ((osoSize + (char *) clus0) -
         ((char *) &(newOSO->to_GrpDscs) +
         ((int) newOSO->to_GrpDscs-diffAll))));

/*
printf("Bytes written for OSO: %d\n", sizeof(OM_S_FILEOBJHDR) +
   OMCLUSTERSIZE + ALIGN(sizeof(struct OMObjSpace_instance)) + oidSize
   + classidSize + toClusDscsSize + (((char *) &(newOSO->to_ClusDscs) + (newOSO->to_ClusDscs-diffVlas)) -
         ((char *) &(newOSO->OS_holes_descr) +
         ((int) newOSO->OS_holes_descr.i_offset - diffVlas))) +
         ((osoSize + (char *) clus0) -
         ((char *) &(newOSO->to_GrpDscs) +
         ((int) newOSO->to_GrpDscs-diffAll))));
*/
#endif

      free((char *) clus0);
      clus0 = newClus0;
   }
   else
   {
      /* Vla's remain the same size - just copy the new to the old. */

      for (ii=0; ii<clus0->i_fil_num_objects; ii++)
      {
         c0filed_oid[ii] = newfiled_oid[ii];
         c0filed_classid[ii] = newfiled_classid[ii];
      }
      clus0->i_my_file_ptr = filehdr.fp_OSO;

#ifdef BIG_ENDIAN
      objSize = GETOBJSIZE(osoSize);      /* OSO size has not changed */
      clus0->i_fil_byte_size = (clus0->i_my_file_ptr -
         clus0->lcd.i_file_ptr) + (objSize-8) + sizeof(OM_S_FILEOBJHDR);
      clus0 = (struct OMCluster_instance *) ((int) clus0 - 8);
      WRITEIT(&objHdr, 8);
      som_bigend_portOSO(objSize, clus0, WRITE_PORT);
      fwrite(clus0, 1, objSize, outfp);
      som_bigend_portOSO(objSize, clus0, READ_PORT);

      clus0 = (struct OMCluster_instance *) ((int) clus0 + 8);
#else
      objSize = GETOBJSIZE(osoSize);      /* OSO size has not changed */
      clus0->i_fil_byte_size = (clus0->i_my_file_ptr -
         clus0->lcd.i_file_ptr) + objSize + sizeof(OM_S_FILEOBJHDR);
      objHdr.i_size = osoSize;
      WRITEIT(&objHdr, sizeof(OM_S_FILEOBJHDR));
      fwrite(clus0, 1, objSize, outfp);
#endif

   }

   filehdr.i_size = ftell(outfp);       /* Save size of file */
   filehdr.i_num_objs += newIndex;
   filehdr.fp_Cluster_instance = filehdr.fp_OSO + 16;
   filehdr.fp_OSO_instance = filehdr.fp_Cluster_instance + OMCLUSTERSIZE;
   while (oidListIndex >= filehdr.i_spacemap_size) /* If added lots of objs */
      filehdr.i_spacemap_size += 1024;
   if (filehdr.i_num_appver)
   {
      int   size, ofp;
      size = OM_K_APPVER_LEN * filehdr.i_num_appver;
      ofp = filehdr.fp_appver + (size + (BLOCKSIZE - (size % BLOCKSIZE)));
      fseek(outfp, filehdr.fp_appver, 0);
      if (fwrite(appVer, 1, (ofp - OMFILEHDRSIZE), outfp) !=
         (ofp - OMFILEHDRSIZE))
      {
         fprintf(stdout, "Error writing application version stamps.\n");
         return(0);
      }
   }
   strcpy(filehdr.dros_msgstr, "Successful recluster");

   rechecksum();

#ifdef BIG_ENDIAN
   som_bigend_portHdr(&filehdr);
#endif

   fseek(outfp, 0, 0);
   fwrite(&filehdr, 1, OMFILEHDRSIZE, outfp);

#ifdef BIG_ENDIAN
   som_bigend_portHdr(&filehdr);
   clus0 = (struct OMCluster_instance *) ((int) clus0 - 8);
#endif

   free((char *) newfiled_oid);
   free((char *) newfiled_classid);
   free((char *) clus0);

/*****
        The following line of code has been added as per recommendations of
        SunSoft      -Mohan
********/
#ifdef X11
   if(fsync( (int) outfp->_file )) fprintf( stderr, "Problem in writing file out to disk\n");
#endif

   fflush(outfp);
   fclose(outfp);
   return(1);
}


rechecksum()
{
   unsigned int   ii, bcount,
                  size,
                  checksum,
                  loc;
   char           buffer[16384];

   bcount = filehdr.i_size - sizeof(OM_S_OS_FILEHDR);
   checksum = 0;
   fseek(outfp, sizeof(OM_S_OS_FILEHDR), 0);
   loc = sizeof(OM_S_OS_FILEHDR);
   while(bcount)
   {
      if (bcount > 16384)
         size = 16384;
      else
         size = bcount;
      if (fread(buffer, 1, size, outfp) != size)
      {
         printf("autorecluster: Could not read file to recompute checksum.\n");
         return(0);
      }
      bcount -= size;
      for (ii=0; ii<size; ii++, loc++)
         checksum += (unsigned char) buffer[ii] + loc;
   }

   filehdr.checksum = checksum;
   memcpy(&buffer[0], &filehdr, sizeof(OM_S_OS_FILEHDR));
   for (ii=checksum=0; ii<434; ii++)
      checksum += (unsigned char) buffer[ii] + ii;
   filehdr.hdr_checksum = checksum;

   return(1);
}



/*============================================================*
 *                                                            *
 *  getNextInputCluster()                                     *
 *                                                            *
 *  Returns index of the next cluster object on the clustArr  *
 *  (array of cluster objects of clusters to be reclustered). *
 *                                                            *
 *============================================================*/

getNextInputCluster(lastIndex)
unsigned int   lastIndex;
{
   int   ii;

   for (ii=lastIndex; ii<clustersSize; ii++)
   {
      if (clustArr[ii] && ((int) clustArr[ii] != -1))
         return(ii);
   }
   fprintf(stdout,
      "autorecluster: %d objects remaining to be reclustered with no\n   associated cluster.  Cannot continue.\n",
      objsToRecluster);
   return(0);
}


/*============================================================*
 *                                                            *
 *  getFreeCnum(outcls)                                       *
 *                                                            *
 *============================================================*/
getFreeCnum(outcls)
struct OMCluster_instance  *outcls;
{
   int               ii;
   struct chanLink   *clusDscs;

   clusDscs = (struct chanLink *) ((char *) toClusDscs + sizeof(struct chan));
   for (ii=1; ii<clustersSize; ii++)
   {
      if (!clustArr[ii])
      {
         clustArr[ii] = (struct OMCluster_instance *) -1;
         outcls->lcd.w_cluster_num = (unsigned short) ii;
         clusDscs[ii].flags = 0x0100;
         clusDscs[ii].count = 0;
         clusDscs[ii].classid = 1;
         clusDscs[ii].number = 0;
         clusDscs[ii].oid = outcls->lcd.oid;
         clustCnt++;
         return(1);
      }
   }
 
   /* Didn't find a free cluster number within current clusters array */

   if (newClustersSize >= toClusDscs->count)    /* If no room in toClusDscs */
   {
      if (toClusDscsSize == origToClusDscsSize)
      {
         struct chan       *ptr;
         struct chanLink   *oldLink, *newLink;
         OMuword           jj;

         /* Current toClusDscs is part of clus0/oso object - can't realloc */

         if (!(ptr = (struct chan *) calloc(1,
            (/*ALIGN*/(toClusDscsSize + sizeof(struct chanLink))))))
         {
            fprintf(stdout,
               "autorecluster: Could not allocate toClusDscs channel to add new cluster object.\n");
            return(0);
         }

         /* Copy data from OSO's to_ClusDscs channel to our new copy of it */

         ptr->flags = toClusDscs->flags;     /* Copy the channel header */
         ptr->count = toClusDscs->count;
         oldLink = (struct chanLink *) ((char *) toClusDscs +
            sizeof(struct chan));
         newLink = (struct chanLink *) ((char *) ptr + sizeof(struct chan));
         for (jj=0; jj<ptr->count; jj++)  /* Copy the channel links */
            newLink[jj] = oldLink[jj];
         toClusDscs = ptr;             /* Point to new copy of to_ClusDscs */
      }
      else
      {
         /* Have already had to calloc a new toClusDscs structure */

         if (!(toClusDscs = (struct chan *) realloc((char *) toClusDscs,
               (/*ALIGN*/(toClusDscsSize + sizeof(struct chanLink))))))
         {
            fprintf(stdout,
               "autorecluster: Could not reallocate toClusDscs channel to add new cluster object.\n");
            return(0);
         }
      }
      toClusDscs->count++;          /* Show we added a new link */
      toClusDscsSize = /*ALIGN*/(toClusDscsSize + sizeof(struct chanLink));
      clusDscs = (struct chanLink *) ((char *) toClusDscs +
         sizeof(struct chan));
   }
   clusDscs[newClustersSize].flags = 0x0100;
   clusDscs[newClustersSize].count = 0;
   clusDscs[newClustersSize].classid = 1;
   clusDscs[newClustersSize].number = 0;
   clusDscs[newClustersSize].oid = outcls->lcd.oid;
   outcls->lcd.w_cluster_num = (unsigned short) newClustersSize;
   newClustersSize++;
   clustCnt++;
   return(1);
}


/*============================================================*
 *                                                            *
 *  initBigObject(bocls)                                      *
 *                                                            *
 *  Fill in big object cluster object with constant data.     *
 *                                                            *
 *============================================================*/

initBigObject(bocls)
struct OMCluster_instance  *bocls;
{
   struct cluster_to_OSO   *toc;

   bocls->i_filed_oid_list_descr.i_offset =
      bocls->w_filed_classid_list_descr.i_offset = OMCLUSTERSIZE;
   bocls->i_filed_oid_list_descr.i_count =
      bocls->w_filed_classid_list_descr.i_count =
      bocls->i_fil_num_objects = 1;
   bocls->to_OSO = 52;              /* Hard-coded-as-hell */
   toc = (struct cluster_to_OSO *) ((char *) bocls + 80);
   toc->flags = toOSOchan.flags;
   toc->count = toOSOchan.count;
   toc->classid = toOSOchan.classid;
   toc->number = toOSOchan.number;
   toc->oid = toOSOchan.oid;
   toc->align = toOSOchan.align;
}


/*============================================================*
 *                                                            *
 *  writeBigObject(bocls, size, bosize)                       *
 *                                                            *
 *  bocls points to the cluster object; bosize is the size of *
 *  the cluster object; size is the file size of the big obj. *
 *                                                            *
 *============================================================*/

writeBigObject(bocls, size, bosize)
struct OMCluster_instance  *bocls;
unsigned int               size, bosize;
{
   unsigned int   objsize;

#ifdef BIG_ENDIAN
   unsigned int   tempint;
#endif

   objsize = GETOBJSIZE(size) + sizeof(OM_S_FILEOBJHDR);
   fseek(osfp, inpos, 0);
   fseek(outfp, outpos, 0);
   fmove(objsize);                     /* Write the big object */
   bocls->i_fil_byte_size = objsize;
   bocls->lcd.i_file_ptr = outpos;
   outpos = ftell(outfp);
   if (!(bocls->lcd.oid = getFreeOid()))
   {
      fprintf(stdout, "autorecluster: Could not get an oid for cluster object.\n");
      return(0);
   }
   if (!getFreeCnum(bocls))
   {
      fprintf(stdout, "autorecluster: Could not get a cluster number.\n");
      return(0);
   }
   bocls->lcd.flags = 0;

/******   TR 119422055   -Mohan
   newfiled_oid[newIndex] = bocls->lcd.oid;
   newfiled_classid[newIndex++] = OM_K_OMCLUSTER_ACTCLASSID;
******/

   if( !(newIndex < newCount) )
   {
     newCount += 50;
     newfiled_oid = (unsigned int *)realloc( newfiled_oid, newCount * 4 );
     newfiled_classid = (unsigned short *)realloc( newfiled_classid, newCount * 2 );
   }
   newfiled_oid[newIndex] = bocls->lcd.oid;
   newfiled_classid[newIndex++] = OM_K_OMCLUSTER_ACTCLASSID;

   fseek(outfp, c0pos, 0);    /* Write the bo cluster object */
   objHdr.tag = 0;
   objHdr.version = 0;

#ifdef BIG_ENDIAN
   objHdr.classid = 0x0100;
   som_swapint(&bocls->lcd.oid, &objHdr.oid);
   tempint = (bosize + 8) | OM_OHf_has_VLA;
   som_swapint(&tempint, &objHdr.i_size);
#else
   objHdr.classid = OM_K_OMCLUSTER_ACTCLASSID;
   objHdr.oid = bocls->lcd.oid;
   objHdr.i_size = bosize + 8 | OM_OHf_has_VLA;
#endif

   WRITEIT(&objHdr, sizeof(OM_S_FILEOBJHDR));

#ifdef BIG_ENDIAN
   bigend_portOMCluster(bosize, bocls, WRITE_PORT);
#endif

   WRITEIT(bocls, bosize);   /* Already wrote the object header */
   c0pos += bosize + sizeof(OM_S_FILEOBJHDR);
   filehdr.i_num_objs++;
   return(1);
}


/*============================================================*
 *                                                            *
 *  writeNewCluster(inbeginfp, bytesToCopy, outcls,           *
 *     outfiled_oid, outfiled_classid, outIndex)              *
 *                                                            *
 *============================================================*/

writeNewCluster(inbeginfp, bytesToCopy, outcls, outfiled_oid,
   outfiled_classid, outIndex)
unsigned int               inbeginfp, bytesToCopy;
struct OMCluster_instance  *outcls;
unsigned int               *outfiled_oid;
unsigned short             *outfiled_classid;
unsigned int               outIndex;
{
   unsigned int               outclsSize, oidSize, classSize;

#ifdef BIG_ENDIAN
   struct OMCluster_instance  *outguy;
#endif

   fseek(osfp, inbeginfp, 0);
   fseek(outfp, outpos, 0);
   if (!fmove(bytesToCopy))
   {
      fprintf(stdout, "autorecluster: Could not copy cluster to new file.\n");
      return(0);
   }
   outcls->i_filed_oid_list_descr.i_count =     /* Store num objects */
      outcls->w_filed_classid_list_descr.i_count =
      outcls->i_fil_num_objects = outIndex;
   outcls->w_filed_classid_list_descr.i_offset = (OMCLUSTERSIZE-8) +
      (oidSize = ALIGN(outIndex * 4));
   outclsSize = (8 + OMCLUSTERSIZE +                   /* Header + inst data */
      oidSize + (classSize = ALIGN(outIndex * 2)) +    /* + the 2 vla's      */
      sizeof(struct cluster_to_OSO)) | OM_OHf_has_VLA; /* + the chan & flags */
   outcls->to_OSO = 36 + oidSize + classSize;
   outcls->lcd.flags = 0;

/*******   TR 119422055     -Mohan
   newfiled_oid[newIndex] = outcls->lcd.oid;
   newfiled_classid[newIndex++] = OM_K_OMCLUSTER_ACTCLASSID;
*******/

   if( !(newIndex < newCount) )
   {
     newCount += 50;
     newfiled_oid = (unsigned int *)realloc( newfiled_oid, newCount * 4 );
     newfiled_classid = (unsigned short *)realloc( newfiled_classid, newCount * 2 );
   }
   newfiled_oid[newIndex] = outcls->lcd.oid;
   newfiled_classid[newIndex++] = OM_K_OMCLUSTER_ACTCLASSID;

   fseek(outfp, c0pos, 0);    /* Write the cluster object */
   objHdr.tag = 0;
   objHdr.version = 0;

#ifdef BIG_ENDIAN
   objHdr.classid = 0x0100;
   som_swapint(&outcls->lcd.oid, &objHdr.oid);
   som_swapint(&outclsSize, &objHdr.i_size);

   WRITEIT(&objHdr, sizeof(OM_S_FILEOBJHDR));
   if (!(outguy = (struct OMCluster_instance *) calloc(1, outclsSize)))
   {
      fprintf(stderr, "autorecluster: Could not allocate %d bytes.\n",
         outclsSize);
      exit(1);
   }
   BLOCKMOVE(sizeof(struct OMCluster_instance), (char *) outcls, (char *) outguy);
   BLOCKMOVE(oidSize, (char *) outfiled_oid, (char *) ((int) outguy +
      sizeof(struct OMCluster_instance)));
   BLOCKMOVE(classSize, (char *) outfiled_classid, (char *) ((int) outguy +
      sizeof(struct OMCluster_instance) + oidSize));
   BLOCKMOVE(sizeof(struct cluster_to_OSO), (char *) &toOSOchan.flags,
      (char *) ((int) outguy +
      sizeof(struct OMCluster_instance) + oidSize + classSize));
   bigend_portOMCluster(outclsSize, outguy, WRITE_PORT);
   WRITEIT(outguy, outclsSize);
   free((char *) outguy);
#else
   objHdr.classid = OM_K_OMCLUSTER_ACTCLASSID;
   objHdr.oid = outcls->lcd.oid;
   objHdr.i_size = outclsSize;

   WRITEIT(&objHdr, sizeof(OM_S_FILEOBJHDR));
   WRITEIT(outcls, (sizeof(struct OMCluster_instance)));
   WRITEIT(outfiled_oid, oidSize);
   WRITEIT(outfiled_classid, classSize);
   WRITEIT(&toOSOchan, sizeof(struct cluster_to_OSO));
#endif

   if (verbose)
   {
      fprintf(stdout,
         "\nNew Cluster:  Cluster number %d at location %d (%d objects, %d bytes)\n",
            outcls->lcd.w_cluster_num, outcls->lcd.i_file_ptr,
            outcls->i_fil_num_objects, outcls->i_fil_byte_size);
      fprintf(stdout,
         "              Cluster object (id %d) at file location %d\n",
            outcls->lcd.oid, c0pos);
   }
   c0pos += GETOBJSIZE(outclsSize) + sizeof(OM_S_FILEOBJHDR);
   filehdr.i_num_objs += outcls->i_fil_num_objects;
   return(1);
}


/*============================================================*
 *                                                            *
 *  deleteEmptyCluster()                                      *
 *                                                            *
 *  Remove OMCluster objects that are left over.              *
 *============================================================*/

deleteEmptyCluster()
{
   int               ii;
   struct chanLink   *clusDscs;

   clusDscs = (struct chanLink *) ((char *) toClusDscs + sizeof(struct chan));
   for (ii=1; ii< clustersSize; ii++)
   {
      if (deleteOids[ii])
      {
         clusDscs[ii] = nullToClusDscs;
         clustCnt--;
      }
   }
   return(1);
}


/*============================================================*
 *                                                            *
 *  autocluster()                                             *
 *                                                            *
 *  Note: any symbol beginning with 'bo' pertains to big      *
 *  objects.                                                  *
 *============================================================*/

autocluster()
{
   unsigned int               ii, objsize, bytesToCopy,
                              inbeginfp, clusSize, boSize, inMemSize,
                              *infiled_oid, *outfiled_oid, outIndex,
                              cIndex, *filed_oid = NULL;
   unsigned short             *infiled_classid, *outfiled_classid,
                              *filed_classid = NULL;
   struct OMCluster_instance  *incls, *outcls, *bocls;
   struct savedRange
   {
      unsigned int      inbeginfp;
      unsigned int      bytesToCopy;
      struct savedRange *next;
   }                          *rangeBlocks, *ptr, *prev;

   incls = outcls = bocls = NULL;
   rangeBlocks = 0;
   cIndex = 1;                   /* Available cluster numbers index */
   inbeginfp = 0;                /* Where input cluster data begins */
   clusSize = OMCLUSTERSIZE +          /* Max clus object size */
      ALIGN(4 * objsToRecluster) + ALIGN(2 * objsToRecluster) +
      sizeof(struct cluster_to_OSO);

   /* A big object cluster contains the OMCluster fixed instance
    * data, a filed_oid array containing one object id and alignment
    * padding, a filed_classid array containing one classid and
    * alignment padding, and the to_OSO channel.
    */

   boSize = OMCLUSTERSIZE + 8 + 8 + sizeof(struct cluster_to_OSO);

   /*=================================================================*/
   /* Create a generic cluster object for writing out our new cluster */
   /* objects.  Make its oid and classid vla's large enough to hold   */
   /* all of the objects being reclustered, so we'll always be sure   */
   /* those vla's are large enough.  They can be adjusted down once   */
   /* it's known how many objects will be written to the current      */
   /* cluster.  outfiled_oid will point to the super-large oid vla    */
   /* immediately following the fixed part of outcls; outfiled_       */
   /* classid points to the super-large classid vla that follows the  */
   /* oid vla plus alignment (to an 8-byte boundary).  Following that */
   /* should be the to_OSO channel, but we'll just write it to file   */
   /* separately, and be sure to include it in the object size field. */
   /*=================================================================*/

   if (!(outcls = (struct OMCluster_instance *) calloc(1,
      (clusSize + (ALIGN(4 * objsToRecluster)) +
      (ALIGN(2 * objsToRecluster))))))
   {
      fprintf(stdout, "autorecluster: Could not allocate %d bytes for cluster object.\n",
         (clusSize + (ALIGN(4 * objsToRecluster)) +
         (ALIGN(2 * objsToRecluster))));
      return(0);
   }
   if (!(outcls->lcd.oid = getFreeOid()))
   {
      fprintf(stdout, "autorecluster: Could not get an oid for cluster object.\n");
      return(0);
   }
   inMemSize = 0;       /* The size the cluster will be in memory (as
                           opposed to its file size, which is bigger) */
   if (!getFreeCnum(outcls))
   {
      fprintf(stdout, "autorecluster: Could not get a cluster number.\n");
      return(0);
   }
   outfiled_oid = (unsigned int *) ((char *) &(outcls->i_filed_oid_list_descr.
         i_offset) + OMCLUSTERSIZE);
   outfiled_classid = (unsigned short *) ((char *) &(outcls->
      w_filed_classid_list_descr.i_offset) + (OMCLUSTERSIZE-8) +
      ALIGN(4 * objsToRecluster));
   outcls->i_filed_oid_list_descr.i_offset = OMCLUSTERSIZE;
   toOSOchan.flags = OM_CH_full | OM_CH_m_1 | OM_CH_singleton | 0x0100;
   toOSOchan.count = 0;
   toOSOchan.classid = OM_K_OMOBJSPACE_ACTCLASSID;
   toOSOchan.number = 1;
   toOSOchan.oid = 0;
   toOSOchan.align = 0;

   if (!(cIndex = getNextInputCluster(cIndex)))
      return(0);
   incls = clustArr[cIndex];
   infiled_oid = (unsigned int *) ((char *) &(incls->i_filed_oid_list_descr.
      i_offset) + incls->i_filed_oid_list_descr.i_offset);
   infiled_classid = (unsigned short *) ((char *) &(incls->
      w_filed_classid_list_descr.i_offset) +
      incls->w_filed_classid_list_descr.i_offset);
   outIndex = 0;     /* oid & classid vla index for outcls */
   outcls->lcd.i_file_ptr = outpos;
   bytesToCopy = 0;
   
   while(objsToRecluster)
   {
      ii = 0;
      inpos = inbeginfp = incls->lcd.i_file_ptr; /* Where to start copying */
      while (ii < incls->i_fil_num_objects)
      {
         /*======================================================*/
         /* While there are objects remaining in this cluster,   */
         /* add them to the new cluster currently being written. */
         /*======================================================*/

         fseek(osfp, inpos, 0);
         READIT(&objHdr, sizeof(OM_S_FILEOBJHDR));

#ifdef BIG_ENDIAN
         som_swapint(&objHdr.i_size, &objsize);
#else
         objsize = objHdr.i_size;
#endif

         objsize = GETOBJSIZE(objsize);
         if (objsize > phyClustSize)
         {
            /*========================================================*/
            /* Big objects are pulled into their own cluster.  Get a  */
            /* new cluster object for this big object.  Write the big */
            /* object, then fix up its cluster object and write it.   */
            /*========================================================*/
            if (!bocls)
            {
               if (!(bocls = (struct OMCluster_instance *)
                  calloc(1, boSize)))
               {
                  fprintf(stdout, "autorecluster: Could not allocate %d bytes for big cluster object.\n",
                     boSize);
                  return(0);
               }
               initBigObject(bocls);
               filed_oid = (unsigned int *) (((char *) bocls) + OMCLUSTERSIZE);
               filed_classid = (unsigned short *) (((char *) bocls) +
                  OMCLUSTERSIZE + 8);
            }
            filed_oid[0] = infiled_oid[ii];
            filed_classid[0] = infiled_classid[ii];

#ifdef BIG_ENDIAN
            som_swapint(&objHdr.i_size, &tempint);
            if (!writeBigObject(bocls, tempint, boSize))
#else
            if (!writeBigObject(bocls, objHdr.i_size, boSize))
#endif

            {
               fprintf(stdout, "autorecluster: Could not write big object at %d.\n",
                  inpos);
               return(0);
            }
            outcls->lcd.i_file_ptr = outpos;
            if (bytesToCopy)
            {
               if (!(ptr = (struct savedRange *)
                   calloc(1, sizeof(struct savedRange))))
               {
                  fprintf(stdout, "autorecluster: Could not allocate %d bytes.\n",
                     sizeof(struct savedRange));
                  return(0);
               }
               ptr->inbeginfp = inbeginfp;
               ptr->bytesToCopy = bytesToCopy;
               if (!rangeBlocks)
                  rangeBlocks = ptr;
               else
               {
                  prev = rangeBlocks;
                  while (prev->next)
                     prev = prev->next;
                  prev->next = ptr;
               }
               bytesToCopy = 0;
            }
            inbeginfp = ftell(osfp);

            if (bocls)
            {
               free(bocls);
               bocls = NULL;
            }
         }              /* End of if big object */
         else if ((inMemSize + objsize + 8) < phyClustSize)
         {
            /*=================================*/
            /* Object fits in current cluster. */
            /*=================================*/
            outcls->i_fil_byte_size += objsize +
               sizeof(OM_S_FILEOBJHDR);
            inMemSize += objsize + 8;
            bytesToCopy += objsize + sizeof(OM_S_FILEOBJHDR);
            outfiled_oid[outIndex] = infiled_oid[ii];
            outfiled_classid[outIndex++] = infiled_classid[ii];
         }              /* End of else if fits in current cluster */
         else
         {
            /*=====================================*/
            /* Can't fit object in cluster.  Close */
            /* off cluster and start a new one.    */
            /*=====================================*/
            if (ptr = rangeBlocks)
            {
               while (ptr)
               {
                  fseek(osfp, ptr->inbeginfp, 0);
                  fseek(outfp, outpos, 0);
                  if (!fmove(ptr->bytesToCopy))
                  {
                     fprintf(stdout, "autorecluster: Could not copy cluster to new file.\n");
                     return(0);
                  }
                  outpos += ptr->bytesToCopy;
                  prev = ptr;
                  ptr = ptr->next;
                  free((char *) prev);
               }
               rangeBlocks = NULL;
            }
            writeNewCluster(inbeginfp, bytesToCopy, outcls, outfiled_oid,
               outfiled_classid, outIndex);

            outpos += bytesToCopy;
            inbeginfp += bytesToCopy;
            bytesToCopy = 0;

            /* Get new output cluster object */
            if (!(outcls->lcd.oid = getFreeOid()))
            {
               fprintf(stdout, "autorecluster: Could not get an oid for cluster object.\n");
               return(0);
            }
            if (!getFreeCnum(outcls))
            {
               fprintf(stdout, "autorecluster: Could not get a cluster number.\n");
               return(0);
            }
            outIndex = 0;                 /* Starting a new output cluster */
            outcls->i_fil_byte_size = inMemSize = 0;
            outcls->lcd.i_file_ptr = outpos;
            fseek(osfp, inpos, 0);      /* Seek back to current object */
            continue;      /* Don't adjust object counters */
         }              /* End of else won't fit in current cluster */
         ii++;                /* Next object of input cluster */
         objsToRecluster--;   /* One less object to recluster */
         inpos += objsize + sizeof(OM_S_FILEOBJHDR); /* Input file obj ptr */
      }                 /* End of while objects remaining in incls */

      /* Get next cluster to recluster */

      if (bytesToCopy) /* If objs have been added to a clstr, but not written */
      {
         if (objsToRecluster)    /* If there are still objs to put in clstrs */
         {
            if (!(ptr = (struct savedRange *)
                calloc(1, sizeof(struct savedRange))))
            {
               fprintf(stdout, "autorecluster: Could not allocate %d bytes.\n",
                  sizeof(struct savedRange));
               return(0);
            }
            ptr->inbeginfp = inbeginfp;
            ptr->bytesToCopy = bytesToCopy;
            if (!rangeBlocks)
               rangeBlocks = ptr;
            else
            {
               prev = rangeBlocks;
               while (prev->next)
                  prev = prev->next;
               prev->next = ptr;
            }
            bytesToCopy = 0;
         }
         else                    /* No objs remaining after these */
         {
            if (ptr = rangeBlocks)
            {
               while (ptr)
               {
                  fseek(osfp, ptr->inbeginfp, 0);
                  fseek(outfp, outpos, 0);
                  if (!fmove(ptr->bytesToCopy))
                  {
                     fprintf(stdout, "autorecluster: Could not copy cluster to new file.\n");
                     return(0);
                  }
                  outpos += ptr->bytesToCopy;
                  prev = ptr;
                  ptr = ptr->next;
                  free((char *) prev);
               }
               rangeBlocks = NULL;
            }
            fseek(osfp, inbeginfp, 0);
            fseek(outfp, outpos, 0);
            if (!fmove(bytesToCopy))
            {
               fprintf(stdout, "autorecluster: Could not copy cluster to new file.\n");
               return(0);
            }
            outpos += bytesToCopy;
            bytesToCopy = 0;
            break;               /* All objs have been written */
         }
      }
      else if (!objsToRecluster)    /* All objs have been clustered & written */
         break;

      if (!(cIndex = getNextInputCluster(++cIndex)))
         return(0);
      incls = clustArr[cIndex];
      inbeginfp = incls->lcd.i_file_ptr;
      infiled_oid = (unsigned int *) ((char *) &(incls->i_filed_oid_list_descr.
         i_offset) + incls->i_filed_oid_list_descr.i_offset);
      infiled_classid = (unsigned short *) ((char *) &(incls->
         w_filed_classid_list_descr.i_offset) +
         incls->w_filed_classid_list_descr.i_offset);
   }                    /* End of while objects left to recluster */

   if (outIndex)
   {
      /* Partial cluster still needs to be written out. */
      writeNewCluster(inbeginfp, bytesToCopy, outcls, outfiled_oid,
         outfiled_classid, outIndex);
      outpos += bytesToCopy;
   }
   deleteEmptyCluster();

   free((char *) outcls);
   if (bocls)
      free((char *) bocls);
   for (ii=0; ii<clustersSize; ii++)
      if (clustArr[ii] && ((int) clustArr[ii] != -1))
         free((char *) clustArr[ii]);
   free((char *) clustArr);
   if (oidList)
      free((char *) oidList); /* We're through creating new objects */
   return(1);
}


/*============================================================*
 *                                                            *
 *  getFreeOid()                                              *
 *                                                            *
 *  Finds the next free object id in the spacemap.  If all    *
 *  are used, the just use next highest oid (will have to up  *
 *  the spacemap size in the header later in this case).      *
 *  This is for the rare (we hope) case where we have to add  *
 *  new cluster objects, and we need object id's for them.    *
 *                                                            *
 *============================================================*/
int getFreeOid()
{
   while (oidListIndex < filehdr.i_spacemap_size)
      if (!oidList[oidListIndex++])
         return(oidListIndex-1);    /* I'm assuming return(ii++) won't work */

   /* Won't get here unless we ran out of oids */
   if (oidList)
   {
      free((char *) oidList);
      return(oidListIndex);
   }
   else
      return(++oidListIndex);
}


/*============================================================*
 *                                                            *
 *  validateObjSizes(clus)                                    *
 *                                                            *
 *  Walk the file between the beginning file pointer          *
 *  and the end file pointer, checking the size field of      *
 *  object headers for each object.  Report strange sizes     *
 *  and read errors.  Gets count of objects in object space.  *
 *                                                            * 
 *============================================================*/
int validateObjSizes(clus)
struct OMCluster_instance  *clus;
{
   int   objsize, fp, endfp, objs;
   unsigned int      *filed_oid;
   unsigned short    *filed_classid;

   objs = 0;
   endfp = clus->lcd.i_file_ptr + clus->i_fil_byte_size;

   filed_oid = (unsigned int *) ((char *) &(clus->i_filed_oid_list_descr.
      i_offset) + clus->i_filed_oid_list_descr.i_offset);
   filed_classid = (unsigned short *) ((char *) &(clus->
      w_filed_classid_list_descr.i_offset) +
      clus->w_filed_classid_list_descr.i_offset);
   fseek(osfp, clus->lcd.i_file_ptr + 12, 0); /* Seek to first i_size field */
   fp = clus->lcd.i_file_ptr;

   /*=============================================================*/
   /* Step through object headers of the file as far as possible, */
   /* counting objects and verifying their size fields.           */
   /*=============================================================*/
   while (fp < endfp)
   {
      if (fread(&objsize, 1, 4, osfp) != 4)
      {
         fprintf(stdout,
            "Read error trying to read %dth object header in Cluster %d after offset %d.\nObject id %d, Classid %d, File location %d.\n",
            objs, clus->lcd.w_cluster_num, clus->lcd.i_file_ptr,
            filed_oid[objs], filed_classid[objs], fp);
         return(0);
      }

#ifdef BIG_ENDIAN
      som_swapint(&objsize, &tempint);
      objsize = tempint;
#endif

      if (((objsize = (GETOBJSIZE(objsize))) <= 0) ||
          ((objsize + fp + sizeof(OM_S_FILEOBJHDR)) > endfp))
      {
         fprintf(stdout,
            "\nCluster %d: Bad object size (%d) for %dth object from beginning of\n   cluster (%d).  Object id %d, Classid %d, File location %d.\n",
            clus->lcd.w_cluster_num, objsize, objs, clus->lcd.i_file_ptr,
            filed_oid[objs], filed_classid[objs], fp);
         fprintf(stdout, "   Cluster size %d, Number of objects %d.\n",
            clus->i_fil_byte_size, clus->i_fil_num_objects);
         return(0);
      }
      else        /* Found a good object header */
      {
         fp += objsize + sizeof(OM_S_FILEOBJHDR);
         oidList[filed_oid[objs]] = 1;    /* Oid is in use */
         objs++;
         fseek(osfp, fp + 12, 0);
      }
   }
   if (objs != clus->i_fil_num_objects)
   {
      fprintf(stdout,
         "\nCluster %d: Number of objects found was %d; should have been %d.\n",
         clus->lcd.w_cluster_num, objs, clus->i_fil_num_objects);
         return(0);
   }
   return(1);
}


/*============================================================*
 *                                                            *
 *  fmove(count)                                              *
 *                                                            *
 *  Move <count> bytes from the input o.s. to the new o.s.    *
 *  Assumes seeks have been made to proper file locations.    *
 *                                                            *
 *============================================================*/
fmove(count)
unsigned int   count;
{
   register bsize;
   char     buf[61440];
	
   while (count > 0)
   {
      if (count > 61440)
         bsize = 61440;
      else
         bsize = count;
      READIT(buf, bsize);
      WRITEIT(buf, bsize);
      count -= bsize;
   }
   return(1);
}


/*============================================================*
 *                                                            *
 *  writeC0Obj(objsize, c0index)                              *
 *                                                            *
 *  Copy a Cluster 0 object to the new file.                  *
 *                                                            *
 *============================================================*/
writeC0Obj(objsize, c0index)
unsigned int   objsize, c0index;
{
   /*=========================================*/
   /* Write object to new cluster 0, updating */
   /* new filed oid and filed classid lists.  */
   /*=========================================*/
   fseek(osfp, inpos, 0);
   fseek(outfp, c0pos, 0);
   fmove(objsize);   /* Copy object from input file to output file */
   c0pos += objsize;

/*******   TR 119422055    -Mohan
   newfiled_oid[newIndex] = c0filed_oid[c0index];
   newfiled_classid[newIndex++] = c0filed_classid[c0index];
*******/

   if( !(newIndex < newCount) )
   {
     newCount += 50;
     newfiled_oid = (unsigned int *)realloc( newfiled_oid, newCount * 4 );
     newfiled_classid = (unsigned short *)realloc( newfiled_classid, newCount * 2 );
   }
   newfiled_oid[newIndex] = c0filed_oid[c0index];
   newfiled_classid[newIndex++] = c0filed_classid[c0index];
}


/*============================================================*
 *                                                            *
 *  walkCluster0()                                            *
 *                                                            *
 *  Step through Cluster 0 an object at a time, copying       *
 *  objects that won't change to the new Cluster 0 in the     *
 *  new file.  As cluster objects are encountered, determine  *
 *  whether they will be reclustered or remain as is.  If     *
 *  they're to be reclustered, save the cluster object, but   *
 *  don't write it to the new file (yet); if they're to stay  *
 *  the same, copy the cluster itself to the new file, then   *
 *  copy the cluster obj.                                     *
 *                                                            *
 *============================================================*/
int walkCluster0()
{
   unsigned int               ii, objsize;
   unsigned short             cnum;
   char                       foundOsco;
   struct OMCluster_instance  *cluster;

   fseek(osfp, filehdr.fp_OSO + 12, 0);
   if (fread(&osoSize, 1, 4, osfp) != 4)
   {
      fprintf(stdout, "autorecluster: Read of Cluster 0 object header failed");
      return(0);
   }

#ifdef BIG_ENDIAN
   som_swapint(&osoSize, &ii);
   osoSize = ii + 8;    /* Include obj header for conversion routine */
   fseek(osfp, -8, 1);
#endif

   if (!(clus0 = (struct OMCluster_instance *)
      malloc((objsize = GETOBJSIZE(osoSize)))))
   {
      fprintf(stdout, "autorecluster: malloc failed for %d bytes (Cluster 0 structure)",
         objsize);
      return(0);
   }
   if (fread(clus0, 1, objsize, osfp) != objsize)
   {
      fprintf(stdout, "autorecluster: Read of Cluster 0 object failed");
      return(0);
   }

#ifdef BIG_ENDIAN
   som_bigend_portOSO(objsize, clus0, READ_PORT);
   objsize -= 8;
   clus0 = (struct OMCluster_instance *) ((int) clus0 + 8);
#endif

   if (!(oidList = (unsigned int *) calloc(4, filehdr.i_spacemap_size)))
   {
      fprintf(stdout, "autorecluster: Could not allocate %d bytes for free oid list.\n",
         filehdr.i_spacemap_size);
         return(0);
   }
   oidList[0] = oidListIndex = 1;
   if (!validateObjSizes(clus0))
   {
      fprintf(stdout, "autorecluster: Cluster 0 of file <%s> is not valid.  Cannot continue.\n",
         filename);
         return(0);
   }
   numC0Objs = clus0->i_fil_num_objects;
   toClusDscs = (struct chan *) ((char *) &((struct OMObjSpace_instance *)
      ((char *) clus0 + OMCLUSTERSIZE))->to_ClusDscs +
      ((struct OMObjSpace_instance *) ((char *) clus0 + OMCLUSTERSIZE))->
      to_ClusDscs);

   if (toClusDscs->flags & OM_CH_tail_exists)
   {
      if (toClusDscs->flags & OM_CH_bigchan)
         toClusDscsSize = ((((struct bigTail *) ((char *) toClusDscs + 4))->
            last_index) * sizeof(struct chanLink)) + sizeof(struct chan);
      else
         toClusDscsSize = ((((struct littleTail *) (((char *) toClusDscs + 4) +
            ((toClusDscs->count-1) * sizeof(struct chanLink))))->last_index) *
            sizeof(struct chanLink)) + sizeof(struct chan);
   }
   else
      toClusDscsSize = (toClusDscs->count *
         sizeof(struct chanLink)) + sizeof(struct chan);
   if (toClusDscsSize % 8)
      toClusDscsSize = ALIGN(toClusDscsSize);
   origToClusDscsSize = toClusDscsSize;

   if ((clustersSize = ((struct OMObjSpace_instance *) (((char *) clus0) +
        OMCLUSTERSIZE))->OSD.ClustersSize) > toClusDscs->count)
      clustersSize = toClusDscs->count;

   newClustersSize = clustersSize;

   if (!(clustArr = (struct OMCluster_instance **) calloc(4, clustersSize)))
   {
      fprintf(stdout, "autorecluster: Could not allocate %d bytes for cluster array.\n",
         (4 * clustersSize));
         return(0);
   }
   if (!(deleteOids = (unsigned int *) calloc(4, clustersSize)))
   {
      fprintf(stdout, "autorecluster: Could not allocate %d bytes for cluster oid array.\n",
         (4 * clustersSize));
         return(0);
   }

   /* Mark clusters the user wants to remain as they are (-s option). */

   for (ii=0; ii<stetIndex; ii++)
      if ((unsigned int) stetList[ii] < clustersSize)
         clustArr[(unsigned int) stetList[ii]] =
         (struct OMCluster_instance *) -1;
   if (stetList)
      free((char *) stetList);   

   /*=================================================================*/
   /* Save a copy of Cluster 0's original filed oid and filed classid */
   /* lists.  Generate new lists to store new order of C0 objects.    */
   /*=================================================================*/
   c0filed_oid = (unsigned int *) ((char *) &(clus0->i_filed_oid_list_descr.
      i_offset) + clus0->i_filed_oid_list_descr.i_offset);
   c0filed_classid = (unsigned short *) ((char *) &(clus0->
      w_filed_classid_list_descr.i_offset) +
      clus0->w_filed_classid_list_descr.i_offset);

   if (!(newfiled_oid = (unsigned int *) calloc(4, (numC0Objs*2))))
   {
      fprintf(stdout, "autorecluster: Could not allocate %d bytes for filed oid list.\n",
         (numC0Objs * 4));
         return(0);
   }
   if (!(newfiled_classid = (unsigned short *) calloc(2, (numC0Objs*2))))
   {
      fprintf(stdout, "autorecluster: Could not allocate %d bytes for filed classid list.\n",
         (numC0Objs * 2));
         return(0);
   }

   newCount = numC0Objs * 2;
   objCnt = clustCnt = objsToRecluster = newIndex = 0;
   foundOsco = 0;
   inpos = c0pos = clus0->lcd.i_file_ptr;
   outpos = firstObjfp;       /* Where to begin copying clusters */

   /*=============================================================*/
   /* Step through object headers of the file as far as possible, */
   /* counting objects and verifying their size fields.           */
   /*=============================================================*/
   while (inpos < filehdr.i_size)    /* While stepping through Cluster 0 */
   {
      fseek(osfp, inpos, 0);
      if (fread(&objHdr, 1, sizeof(OM_S_FILEOBJHDR), osfp) !=
         sizeof(OM_S_FILEOBJHDR))
      {
         fprintf(stdout,
            "Read error trying to read %dth object in Cluster 0 at location %d.\n",
            objCnt, inpos);
         return(0);
      }

#ifdef BIG_ENDIAN
      som_swapint(&objHdr.i_size, &objsize);
      objsize = GETOBJSIZE(objsize);
#else
      objsize = GETOBJSIZE(objHdr.i_size);
#endif

      /* objsize is the instance data size, excluding the object header
       * entirely.  objHdr.i_size is the in-memory object size plus
       * object header flags.  The total size of an object in the file
       * is objsize + sizeof(OM_S_FILEOBJHDR).
       */

      if (c0filed_classid[objCnt] == OM_K_OMFILEDOS_ACTCLASSID);  /* OSO */
      else if (c0filed_classid[objCnt] == OM_K_OMCLUSTER_ACTCLASSID)
      {
         /* Found a cluster object */

         if (!(cluster = (struct OMCluster_instance *) malloc(objsize)))
         {
            fprintf(stdout, "Cannot allocate %d bytes for cluster object.\n",
               objsize);
            return(0);
         }
         if (fread(cluster, 1, objsize, osfp) != objsize)
         {
            fprintf(stdout,
               "Read error trying to read %dth object in Cluster 0 at location %d.\nObject id %d, Class id %d, Size %d\n",
               objCnt+1, inpos, c0filed_oid[objCnt], c0filed_classid[objCnt], objsize);
            return(0);
         }

#ifdef BIG_ENDIAN
         bigend_portOMCluster(objsize, cluster, READ_PORT);
#endif

         if (!validateObjSizes(cluster))
            return(0);
         cnum = cluster->lcd.w_cluster_num;

         /*================================================================*/
         /* If cluster is a user-specified cluster and user didn't specify */
         /* -u, OR cluster is a big object cluster OR cluster was listed   */
         /* with -s option (stet cluster), then copy the cluster as is to  */
         /* the new file -- we're not to recluster this cluster's objects. */
         /*================================================================*/

         if (((cluster->lcd.flags & OM_USERSPEC) && !includeUserSpec) ||
             ((cluster->i_fil_num_objects == 1) &&
              (cluster->i_fil_byte_size > (phyClustSize - 4))) ||
             ((int) clustArr[cnum] == -1))
         {
            if (verbose)
            {
               fprintf(stdout,
                  "\nMoving Cluster %d (size %d, %d objects) to file location %d with no changes.\n",
                  cnum, cluster->i_fil_byte_size,
                  cluster->i_fil_num_objects, outpos);
            }
            clustArr[cnum] = (struct OMCluster_instance *) -1;
            if (!copyCluster(cluster, outpos))
               return(0);
            cluster->lcd.i_file_ptr = outpos;   /* Store new file position */
            outpos += cluster->i_fil_byte_size; /* Point beyond cluster */
            fseek(outfp, c0pos, 0);
            fwrite(&objHdr, 1, sizeof(OM_S_FILEOBJHDR), outfp);
            newfiled_oid[newIndex] = cluster->lcd.oid; /* Update obj lists */
            newfiled_classid[newIndex++] = OM_K_OMCLUSTER_ACTCLASSID;

#ifdef BIG_ENDIAN

            /* The cluster object had been converted in memory in order
             * to validate it.  We've modified it's file pointer, so
             * it can't be copied from the old file to the new.  We
             * have to convert the in-memory copy & write it to the
             * new file.
             */

            bigend_portOMCluster(objsize, cluster, WRITE_PORT);
#endif

            fwrite(cluster, 1, objsize, outfp);
            c0pos += objsize + sizeof(OM_S_FILEOBJHDR);
         }
         else
         {
            /*===========================================================*/
            /* This cluster's objects are to be reclustered.  Don't copy */
            /* this cluster object to the new cluster 0 yet.  Save the   */
            /* object and its size field for use when reclustering.      */
            /*===========================================================*/

            clustArr[cnum] = cluster;
            objsToRecluster += cluster->i_fil_num_objects;
            deleteOids[cnum] = cluster->lcd.oid;
         }
         clustCnt++;       /* Current number of cluster objects */
      }                 /* End of else if obj is a cluster obj */
      else
      {
         /*============================================================*/
         /* Object isn't the OSO or a cluster object.  See if it's an  */
         /* OSCO object; if so, and it's the Cluster OSCO, don't copy  */
         /* it to the new file yet, as we may have to change its       */
         /* reference count field if we add or delete cluster objects. */
         /*============================================================*/

         if (!foundOsco && (c0filed_classid[objCnt] == OM_K_OMOSCO_ACTCLASSID))
         {
            /* Found an osco object */

            if (!(clusterOsco = (struct OMOSCO_instance *) malloc(objsize)))
            {
               fprintf(stdout, "Cannot allocate %d bytes for osco object.\n",
                  objsize);
               return(0);
            }
            if (fread(clusterOsco, 1, objsize, osfp) != objsize)
            {
               fprintf(stdout,
                  "Read error trying to read %dth object in Cluster 0 at location %d.\nObject id %d, Class id %d, Size %d\n",
                  objCnt+1, inpos, c0filed_oid[objCnt], c0filed_classid[objCnt], objsize);
            }
            if (!strncmp(clusterOsco->OSCO.s_name, "OMCluster", 9))
            {
               foundOsco = 1;    /* This is the OMCluster OSCO */
               oscoSize = objsize;

#ifdef BIG_ENDIAN
               bigend_portOMOSCO(objsize, clusterOsco, READ_PORT);
#endif

            }
            else
            {
               /*===========================================================*/
               /* We don't need this OSCO object.  Copy it to the new file. */
               /*===========================================================*/

               writeC0Obj(objsize + sizeof(OM_S_FILEOBJHDR), objCnt);
               free((char *) clusterOsco);
            }
         }              /* End of if obj is an OSCO object */
         else

            /*======================================================*/
            /* We don't need this object.  Copy it to the new file. */
            /*======================================================*/

            writeC0Obj(objsize + sizeof(OM_S_FILEOBJHDR), objCnt);
      }
      inpos += objsize + sizeof(OM_S_FILEOBJHDR);
      objCnt++;
   }                    /* End of while stepping through Cluster 0 */

   return(1);
}


copyCluster(cluster, pos)
struct OMCluster_instance  *cluster;
unsigned int   pos;
{
   fseek(osfp, cluster->lcd.i_file_ptr, 0);
   fseek(outfp, pos, 0);
   fmove(cluster->i_fil_byte_size);
   filehdr.i_num_objs += cluster->i_fil_num_objects;
   return(1);
}



struct OM_sd_lockFileRec *som_getLockFile(fd, count)
int   fd, *count;
{
   int                        bcnt;
   struct stat                buf;
   struct OM_sd_lockFileRec   *rec = NULL;

   /* Use fstat to get size of the lock file, allocate memory to
    * holds its contents, and read it in.  Return pointer to
    * memory.
    */

   lseek(fd, 0, 0);
   if (!fstat(fd, &buf))
   {
      bcnt = (*count = buf.st_size / sizeof(struct OM_sd_lockFileRec)) *
         sizeof(struct OM_sd_lockFileRec);
      if (rec = (struct OM_sd_lockFileRec *) malloc(bcnt))
      {
         if (bcnt != read(fd, rec, bcnt))
            rec = NULL;
      }
   }
   return(rec);
}


lockit(char *filename, char *lockfile)
/* char     *filename;        Design file that lock file will govern */
/* char     *lockfile;        The name of the lock file */
{
   int                        fd, index, count, ii;
   struct OM_sd_lockFileRec   filelbuf, *rec;
   time_t                     clk;

   if ((fd = open(lockfile, O_RDWR | O_CREAT)) == -1)
   {
      perror("FileLocking:Could not open lock file");
      return(0);
   }

   if (lockf(fd, F_TLOCK, 0) == -1)
   {
      printf("FileLocking:Could not lock file <%s>\n", lockfile);
      perror("");
      return(0);
   }
   lseek(fd, 0, 0);
   index = -1;
   count = 0;
   if (rec = (struct OM_sd_lockFileRec *) som_getLockFile(fd, &count))
   {
      for (ii=0; ii<count; ii++)
      {
         if (rec[ii].code == 'V')
            index = ii;
         else if (rec[ii].code == 'W')
         {
            printf("FileLocking:Process %c%c%c%c%c on node %s has write access to file <%s>.\nNo other process may access that file.\n",
               rec[ii].pid[0], rec[ii].pid[1], rec[ii].pid[2],
               rec[ii].pid[3], rec[ii].pid[4], rec[ii].node, filename);
            goto err;
         }
      }
   }
   if (index != -1)
      lseek(fd, index * sizeof(struct OM_sd_lockFileRec), 0);
   filelbuf.code = 'R';
   clk = time(0);
   strcpy(filelbuf.timestamp, &(ctime(&clk))[4]);
   strcpy(filelbuf.pid, pid);
   strcpy(filelbuf.osnum, "     ");
   strncpy(filelbuf.node, node, 9);
   if (write(fd, &filelbuf, sizeof(struct OM_sd_lockFileRec)) == -1)
   {
      printf("FileLocking:Write to <%s> failed.  Cannot access file <%s>.\n",
         lockfile, filename);
   }
err:
   if (lockf(fd, F_ULOCK, 0) == -1)
   {
      printf("FileLocking:Could not unlock file <%s>!\n", lockfile);
      perror("");
   }
   chmod(lockfile, 0666);
   close(fd);
   return(1);
}



modifyAccess(lfname, newMode)
char  *lfname, newMode;
{
   char                       buf[2], found, error = 0;
   int                        ii, fd, count;
   struct OM_sd_lockFileRec   *rec;
   static char                errmsg[] =
                                 {"FileLocking: Could not "};

   if (access(lfname, 00))
      return(1);
   buf[0] = newMode;
   if (!(fd = open(lfname, O_RDWR)))
   {
      printf("%sopen lock file <%s>\n", errmsg, lfname);
      perror("");
      return(0);
   }
   if (lockf(fd, F_TLOCK, 0) == -1)
   {
      printf("%slock file <%s>\n", errmsg, lfname);
      perror("");
      close(fd);
      return(0);
   }

   /* We found the file.  Read each of its entries and make void
    * any entries with our pid.  Nothing happens if we don't
    * find any.
    */
   if (!(rec = (struct OM_sd_lockFileRec *) som_getLockFile(fd, &count)))
   {
      printf("%sread lock file <%s>\n", errmsg, lfname);
      if (lockf(fd, F_ULOCK, 0) == -1)
      {
         printf("%sunlock file <%s>\n", errmsg, lfname);
         perror("");
      }
      close(fd);
      return(0);
   }
   found = 0;
   ii = 0;
   for (; ii<count; ii++)
   {
      if (rec[ii].code == 'V')
         continue;
      if (!strncmp(rec[ii].pid, pid, 5))
      {
         if (strncmp(rec[ii].node, node, 9))
            continue;
         switch (rec[ii].code)
         {
            case 'F':
               if ((newMode != 'R') && (newMode != 'r') && (newMode != 'V'))
                  error = 1;
               break;
            case 'M':
               if ((newMode != 'W') && (newMode != 'V'))
                  error = 1;
               break;
            case 'R':
               if ((newMode != 'F') && (newMode != 'r') && (newMode != 'V'))
                  error = 1;
               break;
            case 'r':
               if (newMode != 'V')
                  error = 1;
               break;
            case 'W':
               if ((newMode != 'M') && (newMode != 'V'))
                  error = 1;
               break;
         }
         if (error)
            buf[0] = 'V';
         lseek(fd, (ii * (sizeof(struct OM_sd_lockFileRec))), 0);
         write(fd, buf, 1);
         goto done;
      }
   }
   if (!found && (newMode != 'V') && (newMode != 'r'))
      printf("%schange file access to %c\n", errmsg, newMode);

   else if (error)
      printf("%schange file access from %c to %c\n",
         errmsg, rec[ii].code, newMode);

done:
   if (lockf(fd, F_ULOCK, 0) == -1)
   {
      printf("%sunlock file <%s>\n", errmsg, lfname);
      perror("");
   }
   close(fd);
   return(1);
}



/*===================================================================*
 *                                                                   *
 *  checkHdrFormat()                                                 *
 *                                                                   *
 *  Simple check to make sure input file has an OM filed OS header.  *
 *                                                                   *
 *===================================================================*/
checkHdrFormat()
{
   int   osSize=0;

   fseek(osfp, 0, 2);    /* Seek to end of file */
   if (!(osSize = ftell(osfp)) || (osSize == EOF) ||
        (osSize < OMFILEHDRSIZE))
      return(0);
   fseek(osfp, 0, 0);
   if (OMFILEHDRSIZE != fread(&filehdr, 1, OMFILEHDRSIZE, osfp))
   {
      fprintf(stdout, "autorecluster: Error reading obj space header");
      return(0);
   }

#ifdef BIG_ENDIAN
   som_bigend_portHdr(&filehdr.magic);
#endif

   if (filehdr.magic != OM_K_MAGIC)
      return(0);
   if (!strcmp(filehdr.write_msgstr, "Successful write"));
   else if (!(strlen(filehdr.stop_time) == 25 && isalpha(filehdr.stop_time[0])
       && isalpha(filehdr.stop_time[1]) && isalpha(filehdr.stop_time[2]) &&
       (filehdr.stop_time[3] == ' ') && isalpha(filehdr.stop_time[4]) &&
       isalpha(filehdr.stop_time[5]) && isalpha(filehdr.stop_time[6]) &&
       (filehdr.stop_time[7] == ' ') && (isdigit(filehdr.stop_time[8]) ||
       (filehdr.stop_time[8] == ' ')) &&
       isdigit(filehdr.stop_time[9]) && (filehdr.stop_time[10] == ' ') &&
       isdigit(filehdr.stop_time[11]) && isdigit(filehdr.stop_time[12]) &&
       (filehdr.stop_time[13] == ':') && isdigit(filehdr.stop_time[14]) &&
       isdigit(filehdr.stop_time[15]) && (filehdr.stop_time[16] == ':') &&
       isdigit(filehdr.stop_time[17]) && isdigit(filehdr.stop_time[18]) &&
       (filehdr.stop_time[19] == ' ') && isdigit(filehdr.stop_time[20]) &&
       isdigit(filehdr.stop_time[21]) && isdigit(filehdr.stop_time[22]) &&
       isdigit(filehdr.stop_time[23])))
      return(0);
   if (filehdr.fp_appver)
   {
      firstObjfp = OMFILEHDRSIZE + (filehdr.i_num_appver * OM_K_APPVER_LEN);
      firstObjfp += /*(firstObjfp % BLOCKSIZE) ?*/
         (BLOCKSIZE - (firstObjfp % BLOCKSIZE))/* : 0*/;
   }
   else
      firstObjfp = OMFILEHDRSIZE;
   filehdr.i_size = osSize;
   filehdr.i_num_objs = 0;
   return(1);
}


main(argc, argv)
int   argc;
char  *argv[];
{
   char           *ptr, *fptr, *optr=NULL;
   char           option, child, phyClustSpecified, fileLocking;

   includeUserSpec = verbose = 0;
   child =                    /* Set by -C option, which is not advertised */
   phyClustSpecified = 0;     /* Set if -p <size> option used */
   fileLocking = 1;
   stetIndex = 0;
   osfp = outfp = NULL;
   phyClustSize = OM_K_PHYCLUSTERSIZE;
   filename[0] = outfile[0] = inLockFile[0] = outLockFile[0] = NULL;
   filename[MAXPATHLEN] = NULL;
   while (EOF != (option = getopt(argc, argv, "uvCf:o:p:s:h?")))
   {
      switch(option)
      {
         case 'C':
            child = 1;             /* FiledOS write method forked us */
            break;
         case 'f':               /* OS file to recluster */
            strncpy(&filename[0], optarg, MAXPATHLEN);
            break;
         case 'o':               /* Name of reclustered object space file */
            strncpy(&outfile[0], optarg, MAXPATHLEN);
            break;
         case 'p':               /* Physical cluster size */
            phyClustSize = atoi(optarg);
            phyClustSpecified = 1;        /* The -p arg was given */
            break;
         case 's':               /* Clusters to leave as they are */
            if (!stetList)
            {
               if (!(stetList = (unsigned short *) calloc(500, 2)))
               {
                  fprintf(stdout, "autorecluster: Could not allocate 1000 bytes.\n");
                  exit(0);
               }
            }
            stetList[stetIndex++] = (unsigned short) atoi(optarg);
            break;
         case 'u':               /* Recluster user-specified clusters, too */
            includeUserSpec = 1;
            break;
         case 'v':               /* Verbose mode */
            verbose = 1;
            break;
         case 'h':
         case '?':
            fprintf(stdout, 
" autorecluster: This utility reclusters the auto-clusters in an OM filed object space,\n");
         fprintf(stdout, 
"      so as to produce a more efficient memory utilization when the object\n");
            fprintf(stdout, 
"      space is next retrieved.\n\n");
         default:
            fprintf(stdout, 
" usage: autorecluster -f filename               file to be reclustered\n");
            fprintf(stdout, 
"                     [-o <outfilename>]         output file name\n");
            fprintf(stdout,
"                     [-v]                       verbose mode\n");
            fprintf(stdout, 
"                     [-u]                       recluster user-specified clusters also\n");
            fprintf(stdout, 
"                     [-p <size>]                cluster size (defaults to 30720 bytes)\n");
            fprintf(stdout, 
"                     [-s <clust#[,clust#...]>]  clusters to as they are\n");
            exit(0);
            break;
      }
   }

   /* 1.4.1 introduced optional file locking from within om.  Autorecluster
    * has to play the same game.  If a-r is running as a process forked by
    * filedOS.write, then the file being reclustered doesn't need to be
    * locked; its file name should be unique, making it unlikely to be
    * accessed by another om process.  If the -C & -p options were both
    * given, we'll assume we were called from filedOS.write, though the
    * same options could have been erroneously given from the command
    * line.  -C is undocumented, but you never know.
    *
    * If a-r was called from the command line, we always use a lock file
    * on both the input and output files, provided we can find the
    * appropriate "lock" subdirectories (if not, we run without file
    * locking).  "Use a lock file" means we don't recluster the input file
    * if there is already a lock on the file, and if there is no lock, we
    * put one there while we're using the file.
    */

   if (!filename[0])
      exit(0);
   if (filename[strlen(filename)-1] == '/')
      filename[strlen(filename)-1] = '\0';  /* If last char is /, get rid of it */
   if (!(ptr = (char *) strrchr(filename, '/')))
      fptr = filename;
   else
      fptr = ++ptr;
   fptr[MAXFILENAMELEN] = '\0';
   if (outfile[0])
   {
      if (outfile[strlen(outfile)] == '/')
         outfile[strlen(outfile)] = '\0';
      if (!(ptr = (char *) strrchr(outfile, '/')))
         optr = outfile;
      else
         optr = ++ptr;
      optr[MAXFILENAMELEN] = '\0';  /* 'optr' points within 'outfile' */
   
      if (!strcmp(filename, outfile))
      {
         fprintf(stdout, "The input and output file names should be different.\n");
         exit(1);
      }
   }


fileLocking = 0;

#if 0
   /* The -C option is not advertised.  We assume only filedOS.write
    * would use it to let us know we're a child process.  filedOS.write
    * also specifies -p, which most command-line a-r users wouldn't
    * specify.  We hope the combination of the 2 always means we were
    * called from filedOS.write & not the command line.
    */

   if (child && phyClustSpecified)  /* If both -C & -p specified */
      fileLocking = 0;
   else
   {
      /* We must have been called from the command line */

      int   len;

      if (fptr != filename)
      {
         /* Copy filename up through last '/' */

         strncpy(inLockFile, filename, len = (int)(fptr-filename));
         inLockFile[len] = NULL;
      }
      strcat(inLockFile, "lock");

      if (access(inLockFile, 06))
         fileLocking = 0;           /* No "lock" subdirectory */
      else
      {
         /* There is a lock subdirectory, so we'll assume file locking
          * is turned on for Ems.  If there's already a lock file for
          * the input file, see if anyone's got read or write access
          * to the file; if so, we exit, else we put a write lock on
          * it.  If there is no lock file, we create one with an
          * entry giving us read access.
          */

         unsigned int ii;
         struct utsname unamebuf;

         sprintf(pid, "%5d", getpid());
         uname(&unamebuf);
         strncpy(node, unamebuf.nodename, 8);
         node[8] = '\0';
         strcat(inLockFile, "/");
         strcat(inLockFile, fptr);

         /* Define a signal handler to clean up lock files
          * if we exit due to a signal.
          */

         for (ii=0; ii<_NSIG; ii++)
            sig_func[ii] = SIG_ERR;
         sig_func[SIGHUP] = signal (SIGHUP, sigtrap);
         sig_func[SIGINT] = signal (SIGINT, sigtrap);
         sig_func[SIGQUIT] = signal (SIGQUIT, sigtrap);
         sig_func[SIGILL] = signal (SIGILL, sigtrap);
         sig_func[SIGIOT] = signal (SIGIOT, sigtrap);
         sig_func[SIGEMT] = signal (SIGEMT, sigtrap);
         sig_func[SIGFPE] = signal (SIGFPE, sigtrap);
         sig_func[SIGBUS] = signal (SIGBUS, sigtrap);
         sig_func[SIGSEGV] = signal (SIGSEGV, sigtrap);
         sig_func[SIGSYS] = signal (SIGSYS, sigtrap);
         sig_func[SIGPIPE] = signal (SIGPIPE, sigtrap);
         sig_func[SIGPOLL] = signal (SIGPOLL, sigtrap);

         if (!lockit(filename, &inLockFile[0]))
            exit(1);
      }
   }
#endif

   if (!(osfp = fopen(filename, "r")))
   {
      perror(filename);
      fprintf(stdout, "autorecluster: Could not open object space file <%s>\n",
         filename);
      filename[0] = '\0';
      if (fileLocking)
         modifyAccess(inLockFile, 'V');
      exit(1);
   }
   else if (!checkHdrFormat())
   {
      fprintf(stdout, "autorecluster: %s is not a valid filed object space.\n",
         filename);
      goto error_exit;
   }

   if (!outfile[0])
   {
      int   ii;

      /* User didn't specify output file name.  Make one up. */

      strcpy(outfile, filename);
      if (fptr != filename)
         optr = outfile + (int)(fptr - filename);
      else
         optr = outfile;
      ii = strlen(outfile);
      if ((strlen(optr) == MAXFILENAMELEN) && (optr[MAXFILENAMELEN-2] == '.') &&
         (optr[MAXFILENAMELEN-1] == 'R'))
      {
         optr[MAXFILENAMELEN-2] = 'R';
         optr[MAXFILENAMELEN-1] = '\0';
      }
      else
      {
         if (strlen(optr) >= (MAXFILENAMELEN - 1))
         {
            ii--;
            if ((strlen(optr) - 1) == (MAXFILENAMELEN - 1))
               ii--;
         }
         outfile[ii++] = '.';
         outfile[ii++] = 'R';
         outfile[ii] = '\0';
      }
   }
   if (fileLocking)
   {
      int   len;

      if (optr != outfile)
      {
         strncpy(outLockFile, outfile, len = (int)(optr-outfile));
         outLockFile[len] = NULL;
      }
      strcat(outLockFile, "lock");

      if (access(outLockFile, 06))
         fileLocking = 0;           /* No "lock" subdirectory */
      else
      {
         sprintf(pid, "%5d", getpid());
         strcat(outLockFile, "/");
         strcat(outLockFile, optr);
         if (!lockit(outfile, &outLockFile[0]))
            goto error_exit;
      }
   }
   if (!(outfp = fopen(outfile, "w+")))
   {
      fprintf(stdout, "autorecluster: Could not open object space file <%s>\n",
         outfile);
      perror("");
      goto error_exit;
   }
   if (verbose)
   {
      fprintf(stdout, "Reclustering file <%s> to file <%s>.\n",
         filename, outfile);
   }

   /*================================================================*/
   /* Input and output files are open; flags are set to tell whether */
   /* to print verbose info and whether to recluster user-specified  */
   /* clusters (as well as auto-clusters).  Input file has been      */
   /* verified to be an OM filed object space.                       */
   /*                                                                */
   /* Read the oso, the cluster objects and the cluster osco object. */
   /* Copy clusters from the input object space to the new object    */
   /* space that are not being reclustered.  Copy objects from       */
   /* cluster 0 that are not changing from the in os to the out os.  */
   /*================================================================*/
   if (!walkCluster0())
      goto error_exit;

   /*================================================================*/
   /* Recluster the clusters not already copied and move them to the */
   /* new file.  Update the oso, the cluster osco, and the cluster   */
   /* objects to reflect changes.                                    */
   /*================================================================*/
   if (!autocluster())
      goto error_exit;
   if (!writeControlData())
      goto error_exit;

   if (fileLocking)
   {
      modifyAccess(inLockFile, 'V');
      modifyAccess(outLockFile, 'V');
   }

   if (verbose)
      fprintf(stdout, "Autorecluster successfully completed.\n");

   exit(0);

error_exit:
   if (osfp)
      fclose(osfp);
   if (outfp)
   {
      fclose(outfp);
      unlink(outfile);
   }
   if (fileLocking)
   {
      modifyAccess(inLockFile, 'V');
      modifyAccess(outLockFile, 'V');
   }
   exit(1);
}

#ifdef BIG_ENDIAN

void som_swapshort(src, dest)
unsigned char  *src, *dest;
{
   dest[0] = src[1];
   dest[1] = src[0];
}

void som_swapint(src, dest)
unsigned char  *src, *dest;
{
   dest[0] = src[3];
   dest[1] = src[2];
   dest[2] = src[1];
   dest[3] = src[0];
}

int bigend_portOMCluster(size, Cluster, flag)
OMuint                     size;
struct OMCluster_instance  *Cluster;
unsigned char              flag;
{
   struct OMCluster_instance  *cluster;
   int                        oidOffset,
                              classidOffset,
                              to_OSOoffset,
                              ii;

   if (!(cluster = (struct OMCluster_instance *) calloc(1, size)))
      return(0);

   for (ii=0; ii<(14 * 4); ii+=4)     /* Swap the first 14 ints */
      som_swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);
   som_swapshort((char *) &Cluster->lcd.w_cluster_num,
      (char *) &cluster->lcd.w_cluster_num);
   som_swapshort((char *) &Cluster->lcd.flags, (char *) &cluster->lcd.flags);
   som_swapint((char *) &Cluster->lcd.i_cur_bytes_allocated,
      (char *) &cluster->lcd.i_cur_bytes_allocated);

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
         som_swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);

   if (classidOffset)
      for (ii=classidOffset; ii<to_OSOoffset; ii+=2)
         som_swapshort(&((char *) Cluster)[ii], &((char *) cluster)[ii]);

   if (to_OSOoffset)
   {
      for (ii=to_OSOoffset; ii<(to_OSOoffset + 8); ii+=2)
         som_swapshort(&((char *) Cluster)[ii], &((char *) cluster)[ii]);
      for (ii=to_OSOoffset + 8; ii<(to_OSOoffset + 16); ii+=4)
         som_swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);
   }

   BLOCKMOVE(size, (char *) cluster, (char *) Cluster);
   free((char *) cluster);

   return(1);
}


bigend_portOMOSCO(size, OSCO, flag)
int                     size;
struct OMOSCO_instance  *OSCO;
char                    flag;
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

   if (!(osco = (struct OMOSCO_instance *) malloc(size)))
      return(0);

   memcpy((char *) osco, (char *) OSCO, size);
   som_swapshort(&osco->OSCO.w_classid, &OSCO->OSCO.w_classid);
   som_swapshort(&osco->OSCO.w_child_refcnt, &OSCO->OSCO.w_child_refcnt);
   som_swapshort(&osco->OSCO.w_oppmaj_version, &OSCO->OSCO.w_oppmaj_version);
   som_swapshort(&osco->OSCO.w_oppmin_version, &OSCO->OSCO.w_oppmin_version);
   som_swapshort(&osco->OSCO.w_major_version, &OSCO->OSCO.w_major_version);
   som_swapshort(&osco->OSCO.w_minor_version, &OSCO->OSCO.w_minor_version);
   som_swapint(&osco->OSCO.i_refcnt, &OSCO->OSCO.i_refcnt);
   som_swapint(&osco->OSCO.OSCO_oid, &OSCO->OSCO.OSCO_oid);
   som_swapint(&osco->to_OSO, &OSCO->to_OSO);
   som_swapint(&osco->component_list_descr.i_offset,
      &OSCO->component_list_descr.i_offset);
   som_swapint(&osco->component_list_descr.i_count,
      &OSCO->component_list_descr.i_count);
   som_swapint(&osco->vla_list_descr.i_offset, &OSCO->vla_list_descr.i_offset);
   som_swapint(&osco->vla_list_descr.i_count, &OSCO->vla_list_descr.i_count);
   som_swapint(&osco->chan_info_descr.i_offset, &OSCO->chan_info_descr.i_offset);
   som_swapint(&osco->chan_info_descr.i_count, &OSCO->chan_info_descr.i_count);
   som_swapint(&osco->res_classname_descr.i_offset,
      &OSCO->res_classname_descr.i_offset);
   som_swapint(&osco->res_classname_descr.i_count,
      &OSCO->res_classname_descr.i_count);
   som_swapint(&osco->res_channum_descr.i_offset,
      &OSCO->res_channum_descr.i_offset);
   som_swapint(&osco->res_channum_descr.i_count,
      &OSCO->res_channum_descr.i_count);
   som_swapint(&osco->component_size, &OSCO->component_size);
   som_swapint(&osco->num_parents, &OSCO->num_parents);
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
         som_swapshort(&((char *) osco)[ii], &((char *) OSCO)[ii]);
      for (ii=to_OSOoffset + 8; ii<(to_OSOoffset + 16); ii+=4)
         som_swapint(&((char *) osco)[ii], &((char *) OSCO)[ii]);
   }
   if (compOffset)
      for (ii=0; ii<compCount; ii++, compOffset+=4)
      {
         som_swapshort(&((char *) osco)[compOffset],
            &((char *) OSCO)[compOffset]);
         som_swapshort(&((char *) osco)[compOffset+2],
            &((char *) OSCO)[compOffset+2]);
      }
   if (vlaOffset)
      for (ii=0; ii<vlaCount; ii++, vlaOffset+=4)
      {
         som_swapshort(&((char *) osco)[vlaOffset],
            &((char *) OSCO)[vlaOffset]);
         som_swapshort(&((char *) osco)[vlaOffset+2],
            &((char *) OSCO)[vlaOffset+2]);
      }
   if (chanOffset)
      for (ii=0; ii<chanCount; ii++, chanOffset+=4)
      {
         som_swapshort(&((char *) osco)[chanOffset],
            &((char *) OSCO)[chanOffset]);
         som_swapshort(&((char *) osco)[chanOffset+2],
            &((char *) OSCO)[chanOffset+2]);
      }
   if (resOffset)
      for (ii=0; ii<resCount; ii++, resOffset+=2)
         som_swapshort(&((char *) osco)[resOffset], &((char *) OSCO)[resOffset]);
   free((char *) osco);

   return(1);
}

int som_bigend_portOSO(size, OSO, flag)
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

   if (!(oso = (char *) malloc(size)))
      return(0);

   /* Convert object header and OMCluster component */

   som_bigend_portOMCluster(size, OSO, &oso, flag);

   /* Get handy pointers to OSO's components */

   Cluster = (struct OMCluster_instance *) &OSO[sizeof(OM_S_OBJECTHDR)];
   cluster = (struct OMCluster_instance *) &oso[sizeof(OM_S_OBJECTHDR)];
   Objspace = (struct OMObjSpace_instance *)
      &OSO[sizeof(struct OMCluster_instance) + sizeof(OM_S_OBJECTHDR)];
   objspace = (struct OMObjSpace_instance *)
      &oso[sizeof(struct OMCluster_instance) + sizeof(OM_S_OBJECTHDR)];

   memcpy((char *) objspace, (char *) Objspace, 32);  /* Copy timestamps */
   som_swapint((char *) &Objspace->p_filehdr, (char *) &objspace->p_filehdr);

   /* Convert the OSD */

   for (ii = (int) &Objspace->OSD.lcfq_lh.next - (int) OSO;
      ii<(int) &Objspace->OSD.OSnum - (int) OSO; ii+=4)
      som_swapint(&OSO[ii], &oso[ii]);
   som_swapshort((char *) &Objspace->OSD.OSnum, (char *) &objspace->OSD.OSnum);
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
      som_swapint(&OSO[ii], &oso[ii]);

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
      som_swapint(&OSO[ii], &oso[ii]);

   /* Convert the iso_d vla (char array followed by an int) */

   if (iso_dOffset)
   {
      memcpy(&oso[iso_dOffset], &OSO[iso_dOffset],
         (freeoidsOffset ? freeoidsOffset : to_OSCOsOffset) - iso_dOffset);
      for (ii=1; ii<=iso_dCount; ii++)
         som_swapint(&OSO[(iso_dOffset +
            (ii * (OM_K_MAXINTOSNAME_LEN + 4))) - 4],
            &oso[(iso_dOffset + (ii * (OM_K_MAXINTOSNAME_LEN + 4))) - 4]);
   }

   /* Convert the freeoids vla (int) */

   if (freeoidsOffset)
      for (ii = (int) freeoidsOffset; (int) &OSO[ii] < to_OSCOsOffset; ii+=4)
         som_swapint(&OSO[ii], &oso[ii]);

   /* Convert the channels (2 shorts followed by chan links) */

   som_swapshort(&OSO[to_OSCOsOffset], &oso[to_OSCOsOffset]);
   som_swapshort(&OSO[to_OSCOsOffset + 2], &oso[to_OSCOsOffset + 2]);
   for (ii = to_OSCOsOffset + 4; ii < to_ClusDscsOffset; ii+=12)
   {
      som_swapshort(&OSO[ii], &oso[ii]);
      som_swapshort(&OSO[ii+2], &oso[ii+2]);
      som_swapshort(&OSO[ii+4], &oso[ii+4]);
      som_swapshort(&OSO[ii+6], &oso[ii+6]);
      som_swapint(&OSO[ii+8], &oso[ii+8]);
   }

   som_swapshort(&OSO[to_ClusDscsOffset], &oso[to_ClusDscsOffset]);
   som_swapshort(&OSO[to_ClusDscsOffset + 2], &oso[to_ClusDscsOffset + 2]);
   for (ii = to_ClusDscsOffset + 4; ii < to_GrpDscsOffset; ii+=12)
   {
      som_swapshort(&OSO[ii], &oso[ii]);
      som_swapshort(&OSO[ii+2], &oso[ii+2]);
      som_swapshort(&OSO[ii+4], &oso[ii+4]);
      som_swapshort(&OSO[ii+6], &oso[ii+6]);
      som_swapint(&OSO[ii+8], &oso[ii+8]);
   }

   som_swapshort(&OSO[to_GrpDscsOffset], &oso[to_GrpDscsOffset]);
   som_swapshort(&OSO[to_GrpDscsOffset + 2], &oso[to_GrpDscsOffset + 2]);
   if (to_NamObjDirOffset)
   {
      for (ii = to_GrpDscsOffset + 4; ii < to_NamObjDirOffset; ii+=12)
      {
         som_swapshort(&OSO[ii], &oso[ii]);
         som_swapshort(&OSO[ii+2], &oso[ii+2]);
         som_swapshort(&OSO[ii+4], &oso[ii+4]);
         som_swapshort(&OSO[ii+6], &oso[ii+6]);
         som_swapint(&OSO[ii+8], &oso[ii+8]);
      }

      som_swapshort(&OSO[to_NamObjDirOffset], &oso[to_NamObjDirOffset]);
      som_swapshort(&OSO[to_NamObjDirOffset + 2], &oso[to_NamObjDirOffset + 2]);
      for (ii = to_NamObjDirOffset + 4; ii < size; ii+=12)
      {
         som_swapshort(&OSO[ii], &oso[ii]);
         som_swapshort(&OSO[ii+2], &oso[ii+2]);
         som_swapshort(&OSO[ii+4], &oso[ii+4]);
         som_swapshort(&OSO[ii+6], &oso[ii+6]);
         som_swapint(&OSO[ii+8], &oso[ii+8]);
      }
   }
   else
      for (ii = to_GrpDscsOffset + 4; ii < size; ii+=12)
      {
         som_swapshort(&OSO[ii], &oso[ii]);
         som_swapshort(&OSO[ii+2], &oso[ii+2]);
         som_swapshort(&OSO[ii+4], &oso[ii+4]);
         som_swapshort(&OSO[ii+6], &oso[ii+6]);
         som_swapint(&OSO[ii+8], &oso[ii+8]);
      }

   /* All done!  Return the guy we malloc-ed either in *convertedOSO
    * or in input OSO buffer.
    */

   memcpy((char *) OSO, (char *) oso, size);
   free(oso);
   return(1);
}

int som_bigend_portOMCluster(size, CLUSTER, convertedCluster, flag)
OMuint          size;
char            *CLUSTER, **convertedCluster;
unsigned char   flag;
{
   struct OMCluster_instance  *cluster, *Cluster;
   int                        oidOffset,
                              classidOffset,
                              to_OSOoffset,
                              ii;

   /* Converted the object header */

   som_swapint(CLUSTER, *convertedCluster);
   som_swapint(&CLUSTER[4], &(*convertedCluster)[4]);
   Cluster = (struct OMCluster_instance *) ((int) CLUSTER +
      sizeof(OM_S_OBJECTHDR));

   if ((int) *convertedCluster == (int) CLUSTER)
   {
      /* Caller did not provide a buffer for the converted cluster,
       * so he wants it returned in Cluster.  Allocate a temporary
       * cluster to store the converted cluster in, then return it
       * in place of the original Cluster.
       */
      if (!(cluster = (struct OMCluster_instance *) malloc(size)))
         return(0);
   }
   else
      cluster = (struct OMCluster_instance *) ((int) (*convertedCluster) +
         sizeof(OM_S_OBJECTHDR));

   for (ii=0; ii<(14 * 4); ii+=4)     /* Swap the first 14 ints */
      som_swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);
   som_swapshort((char *) &Cluster->lcd.w_cluster_num,
      (char *) &cluster->lcd.w_cluster_num);
   som_swapshort((char *) &Cluster->lcd.flags, (char *) &cluster->lcd.flags);
   som_swapint((char *) &Cluster->lcd.i_cur_bytes_allocated,
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

   if (flag == READ_PORT)
   {
      oidOffset = cluster->i_filed_oid_list_descr.i_offset;
      classidOffset = cluster->w_filed_classid_list_descr.i_offset + ((int)
         &cluster->w_filed_classid_list_descr.i_offset - (int) cluster);
      to_OSOoffset = cluster->to_OSO +
         ((int) &cluster->to_OSO - (int) cluster);
   }
   else
   {
      oidOffset = Cluster->i_filed_oid_list_descr.i_offset;
      classidOffset = Cluster->w_filed_classid_list_descr.i_offset + ((int)
         &Cluster->w_filed_classid_list_descr.i_offset - (int) Cluster);
      to_OSOoffset = Cluster->to_OSO +
         ((int) &Cluster->to_OSO - (int) Cluster);
   }
   for (ii=oidOffset; ii<classidOffset; ii+=4)
      som_swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);

   for (ii=classidOffset; ii<to_OSOoffset; ii+=2)
      som_swapshort(&((char *) Cluster)[ii], &((char *) cluster)[ii]);

   for (ii=to_OSOoffset; ii<(to_OSOoffset + 8); ii+=2)
      som_swapshort(&((char *) Cluster)[ii], &((char *) cluster)[ii]);
   for (ii=to_OSOoffset + 8; ii<(to_OSOoffset + 16); ii+=4)
      som_swapint(&((char *) Cluster)[ii], &((char *) cluster)[ii]);

   if ((int) *convertedCluster == (int) Cluster)
   {
      memcpy((char *) ((int) *convertedCluster + sizeof(OM_S_OBJECTHDR)),
         (char *) cluster, size - sizeof(OM_S_OBJECTHDR));
   }
   return(1);
}


int som_bigend_portHdr(hdr)
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
      som_swapshort(&oldHdr.Char[ii], &(((char *) hdr)[ii]));

   for (ii=8; ii<52; ii+=4)   /* Convert i_size through S_OS_object (oid) */
   {
      som_swapint(&oldHdr.Char[ii], &(((char *) hdr)[ii]));
   }
   som_swapshort((char *) &oldHdr.Hdr.OSOfiledClassid,
      (char *) &hdr->OSOfiledClassid);
   som_swapint((char *) &oldHdr.Hdr.os_flags, (char *) &hdr->os_flags);
   som_swapint((char *) &oldHdr.Hdr.hdr_checksum, (char *) &hdr->hdr_checksum);
   return(1);
}

#endif   /* BIG_ENDIAN (byte swapping) */
