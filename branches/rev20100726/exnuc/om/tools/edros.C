#include <exsysdep.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <time.h>
#include <ctype.h>
#include <signal.h>
#include <math.h>

#include "OMOSfilehdr.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMmetaclass.h"
#include "OMrtreedef.h"
#include "dros.h"
#ifdef CLIX
#include "drosddp.h"
#endif
#include "OMport.h"

extern char *som_malloc(),
            *som_calloc(),
            *som_realloc();
extern void som_dealloc();
extern void display_iso(),
            rDisp(),
            display_header(),
            appDisp(),
            hexdump(),
            printOSname(),
            drosInit(),
            parseCommandLine(),
            wild_card(),
	    om_validation(),
	    validate_header(),
	    restore_checksums(),
            modify_appver_stamps(),
	    putback_om_magic(),
 	    validate_misc();
extern int
            calculate_main_checksum(),
            calculate_hdr_checksum();

extern int  drosAbort(), tagRepair(),
            getOSCObyClassName(),
            classname_dir(),
            system(),
            detectHoles();
#ifdef CLIX
extern int  dros_parddp(),
            dros_parddp_free(),
            init_inst_form();
#endif
extern struct statsbyid  *objTable;
extern char filename[],
            ddpPath[],
            tag;

/* Externs for OM validation */
extern FILE  *errfp;

#define ISO_disconnected       1	/* this os obj has disconnected   */
#define ISO_to_object          2        /* s_objid points to object       */
#define ISO_logical_disconnect 4        /* flags disconnect on RO side of */
                                        /* RW to RO OS connection         */
#define ISO_logical_connect    8        /* flags connect on RW side of    */
                                        /* RW to RO OS connection         */

/* --- definitions for ISO instance element w_ISO_flags --- */

#define ISO_no_target	       1	/* target OS not loaded           */
#define ISO_to_transient       2	/* taregt ISO was a transient     */
#define ISO_to_read_only       4        /* target OS is read only         */

/**********************
 *                    *
 *  GLOBAL VARIABLES  *
 *                    *
 **********************/

unsigned int   os_size,          /* Actual file system size of file */
               OSflags,          /* State of the object space */
               errcnt,           /* Number of errors reported so far */
               objCnt,           /* Number of objects reachable from the
                                    beginning of the file */
               mode,
               firstObjfp,       /* File offset of first object */
               iso_count,        /* Number of iso objs in cluster 0 */
               cluster_count,    /* Number of clusters on OSO channel */
               osco_count,       /* Number of oscos on OSO channel */
               group_count,      /* Number of groups on OSO channel */
               tag_count,        /* Number of valid entries in tagRec */
               *iso_oid,
               *classRefcnt,
               *iso_summary,
               highOid;
FILE           *osfp,            /* Object space file pointer */
               *outfp,
               *errlogfp,
               *logfile;
struct OMCluster_instance  *clust0,
               **cluster,
               **clustbyfp,      /* Indices to cluster array in file order */
               **clustbyid;      /* Indices to cluster array by cluster num */
struct OMOSCO_instance
               **oscobyid,       /* Indices to osco array by class id */
               **oscobyfp;       /* Indices to osco array by file order */
struct OMISO_instance **iso;
struct OMGroup_array *group;
struct ISOd_data *iso_dir;
OM_p_CHANNEL_HDR clusdscs;       /* OSD channel to clusters */
struct OMObjSpace_instance *oso = NULL;
unsigned short high_classid,
               highCnum;
char           outputFile[MAXPATHLEN+1],
               logfname[MAXPATHLEN+1],
               buffer[512],
               verbose,          /* Print verbose validation messages */
               OSname;
struct OM_sd_OS_filehdr_OM  filehdr;      /* OM file header */
struct classstats *classStats;
struct sort_element *sort_classname = NULL;


/*********************
 *                   *
 *  D I S P L A Y S  *
 *                   *
 *********************/

void createLog()
{
   if (logfile)
   {
      fprintf(logfile, "*** Warning: Log file already open!\n");
      fprintf(logfile, "The current active log file is: %s\n", logfname);
      fprintf(logfile, "Once a new log file is opened, the old one will be closed.\n\n");
      fprintf(logfile, "Do you really want to open a new one?\n");
      fprintf(logfile, "(y/n)> ");
      fprintf(stdout, "*** Warning: Log file(s) already open! ");
      fprintf(stdout, "The current active log file is: %s\n", logfname);
      fprintf(stdout, "Once a new log file is opened, the old one will be closed. \n\n");
      fprintf(stdout, "Do you really want to open a new one?\n");
      fprintf(stdout, "(y/n)> ");
      do 
      {
         scanf("%c", &buffer[0]);
         fprintf(logfile, "%c\n", buffer[0]);
      } while (buffer[0] != 'y' && buffer[0] != 'n');
      if (buffer[0] == 'n')
         return;
      fclose(logfile);
   }
   fprintf(stdout, "Enter log filename> ");
/*   fflush(stdin);*/
   scanf(" %[^\n]", logfname);
   logfile = fopen(logfname, "w");
   if (!logfile)
      fprintf(stdout, "Failed to open <%s> for write\n", logfname);
}

void fDisp()
{
   int               ii, start = 0;
   int               limit = 0;
   unsigned int      *filed_oid, jj;
   unsigned short    *filed_classid;
   char              flag, *ptr, *ptr2;

   fprintf(stdout, "Object/Classid/Size/File Pointer lists by cluster\n");
   if (logfile)
      fprintf(logfile, "Object/Classid/Size/File pointer lists by cluster\n");
   fprintf(stdout, "There are %d clusters in this object space\n", cluster_count);
   flag = 1;
   while (flag)
   {
      fprintf(stdout, "   Enter an cluster number (displays object data for one cluster),\n");
      fprintf(stdout, "         a range of cluster numbers (e.g., 0-10),\n");
      fprintf(stdout, "              or\n");
      fprintf(stdout, "         'A' (displays data for ALL clusters)\n");
      start = limit = 0;
      scanf("%s", buffer);
      flag = 0;
      if (buffer[0] != 'A')
      {
         if (ptr = (char *) strchr(buffer, '-'))
         {
            *ptr = '\0';
            for (ii=0; ii<(int) strlen(buffer); ii++)
            {
               if (!isdigit(buffer[ii]))
               {
                  flag = 1;
                  continue;
               }
            }
            start = atoi(buffer);
            if (ptr2 = (char *) strchr(++ptr,'-'))
               *ptr2 = '\0';
            ptr2 = ptr;
            for (ii=0; ii< (int) strlen(ptr2); ii++)
            {
               if (!isdigit(*ptr2++))
               {
                  flag = 1;
                  continue;
               }
            }
            limit = atoi(ptr);
         }
         else
         {
            for (ii=0; ii< (int) strlen(buffer); ii++)
            {
               if (!isdigit(buffer[ii]))
               {
                  flag = 1;
                  continue;
               }
            }
            start = atoi(buffer);
         }
         if (!limit)
            limit = start;
      }
      else
         limit = highCnum;
   }
   if (start > (int) highCnum)
      start = highCnum;
   if (limit < start)
      limit = start;
   for (ii=start; ii <= limit; ii++)
   {
      if (!clustbyid[ii])
         continue;
      fprintf(stdout, "\n>>Cluster %d (offset=%d size=%d objects=%d)----- \n",
         ii, clustbyid[ii]->lcd.i_file_ptr,
         clustbyid[ii]->i_fil_byte_size, clustbyid[ii]->i_fil_num_objects);
      if (logfile)
         fprintf(logfile, "\n>>Cluster %d (offset=%d size=%d objects=%d)----- \n",
         ii, clustbyid[ii]->lcd.i_file_ptr,
         clustbyid[ii]->i_fil_byte_size, clustbyid[ii]->i_fil_num_objects);
      filed_oid = (unsigned int *) ((char *) &(clustbyid[ii]->
         i_filed_oid_list_descr.i_offset) + clustbyid[ii]->
         i_filed_oid_list_descr.i_offset);
      filed_classid = (unsigned short *) ((char *) &(clustbyid[ii]->
         w_filed_classid_list_descr.i_offset) +
         clustbyid[ii]->w_filed_classid_list_descr.i_offset);
      fprintf(stdout, "  Object   Classid   Size     File Pointer\n");
      if (logfile)
         fprintf(logfile, "  Object   Classid   Size     File Pointer\n");
      for (jj=0; jj < clustbyid[ii]->i_filed_oid_list_descr.i_count; jj++)
      {
         fprintf(stdout, "%7d    %5d   %6d   %10d\n",
            filed_oid[jj], filed_classid[jj],
            GETOBJSIZE(objTable[filed_oid[jj]].size),
            objTable[filed_oid[jj]].fp);
         if (logfile) fprintf(logfile, "%7d    %5d   %6d   %10d\n",
            filed_oid[jj], filed_classid[jj],
            GETOBJSIZE(objTable[filed_oid[jj]].size),
            objTable[filed_oid[jj]].fp);
      }
      fprintf(stdout, "\n");
      if (logfile) fprintf(logfile, "\n");
   }
}

void gDisp()
{
   unsigned int      ii, skip=0;
   int               hour, month, day, year, minute;
   char              *date_start;
   struct OM_sd_OSD  *OSD;
   static char  *months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
   static char  *ampm[] = {"am", "pm"};

   OSD = &oso->OSD;
   if (strlen(OSD->InternalName) > OM_K_MAXINTOSNAME_LEN)
      OSD->InternalName[OM_K_MAXINTOSNAME_LEN-1] = '\0';
   fprintf(stdout, "\nGeneral statistics for OS %s\n", OSD->name);
   date_start = (char *) ((int) strchr(OSD->InternalName, '~') + 1);
   while(!(ii=strspn(date_start, "0123456789")) ||
      (*(date_start+ii) != '~'))
   {
      if (!*date_start)
      {
         skip = 1;
         break;
      }
      date_start = strchr(date_start, '~') + 1;
   }
   if (!skip)
   {
      sscanf(date_start, "%2d%2d%4d%2d%2d",
         &month, &day, &year, &hour, &minute);
      ii = hour/12;	
      hour %= 12;
      fprintf(stdout, "Filename: %s\nOS creation date: %d:%.2d %s %s %d, %4d\n",
         filename, hour, minute, ampm[ii], months[month-1], day, year);
   }
   fprintf(stdout, "Objects in file = %d\n", objCnt);
   fprintf(stdout, "Internal name: %s\n", OSD->InternalName);
   fprintf(stdout, "osname: %s\n", OSD->name);
   fprintf(stdout, "OSO oid: %d     Group 0 oid: %d     osnum: %d\n",
      OSD->OSO_Oid, OSD->Group0_Oid, OSD->OSnum);
   fprintf(stdout, "Type:");
   if (logfile) 
   {
      fprintf(logfile, "General statistics for OS %s\n", OSD->name);
      fprintf(logfile, "Filename: %s\n", filename);
      if (!skip)
         fprintf(logfile, "OS creation date: %d:%.2d %s %s %d, %4d\n",
            hour, minute, ampm[ii], months[month-1], day, year);
      fprintf(logfile, "Objects in file = %d\n", objCnt);
      fprintf(logfile, "Internal name: %s\n", OSD->InternalName);
      fprintf(logfile, "osname: %s\n", OSD->name);
      fprintf(logfile, "OSO oid: %d     Group 0 oid: %d     osnum: %d\n", OSD->OSO_Oid, OSD->Group0_Oid, OSD->OSnum);
      fprintf(logfile, "Type:");
   }
   switch (OSD->type)
   {
      case (OM_OSD_MOSDOS):
         fprintf(stdout, " MOSDOS  ");
         if (logfile) fprintf(logfile, " MOSDOS  ");
         break;
      case (OM_OSD_trans):
         fprintf(stdout, " Transient  ");
         if (logfile) fprintf(logfile, " Transient  ");
         break;
      case (OM_OSD_filed):
         fprintf(stdout, " Filed  ");
         if (logfile) fprintf(logfile, " Filed  ");
         break;
      default:
         fprintf(stdout, " Unknown type (%X) (hex)  ", OSD->type);
         if (logfile) fprintf(logfile, " Unknown type (%X) (hex)  ", OSD->type);
         break;
   }
   if (OSD->flags)
   {
      fprintf(stdout, "Flag(s) at write: ");
      if (OSD->flags&OM_OSD_inuse)
         fprintf(stdout, "Inuse ");
      if (OSD->flags&OM_OSD_nowrite)
         fprintf(stdout, "Nowrite ");
      if (OSD->flags&OM_OSD_compress_on_wrt)
         fprintf(stdout, "Compress_on_wrt ");
      if (OSD->flags&OM_OSD_modified)
         fprintf(stdout, "Modified ");
      if (OSD->flags&OM_OSD_ISOmodified)
         fprintf(stdout, "ISOmodified ");
      if (OSD->flags&OM_e_loados_ro)
         fprintf(stdout, "read only ");
      if (OSD->flags&OM_OSD_Rootdel_pending)
         fprintf(stdout, "Delete pending ");
      if (logfile)
      {
         fprintf(logfile, "Flag(s) at write: ");
         if (OSD->flags&OM_OSD_inuse)
            fprintf(logfile, "Inuse ");
         if (OSD->flags&OM_OSD_nowrite)
            fprintf(logfile, "Nowrite ");
         if (OSD->flags&OM_OSD_compress_on_wrt)
            fprintf(logfile, "Compress_on_wrt ");
         if (OSD->flags&OM_OSD_modified)
            fprintf(logfile, "Modified ");
         if (OSD->flags&OM_OSD_ISOmodified)
            fprintf(logfile, "ISOmodified ");
         if (OSD->flags&OM_e_loados_ro)
            fprintf(logfile, "read only ");
         if (OSD->flags&OM_OSD_Rootdel_pending)
            fprintf(logfile, "Delete pending ");
      }
   }
   else
   {
      fprintf(stdout, " No flags set ");
      if (logfile) fprintf(logfile, " No flags set ");
   }
   fprintf(stdout, "\nSpacemap size: %-d  Number of clusters: %d\n\n",
      OSD->CurSpaceMapSize, cluster_count);
   if (logfile)
      fprintf(logfile, "\nSpacemap size: %-d  Number of clusters: %d\n\n",
         OSD->CurSpaceMapSize, cluster_count);

   /* List the clusters in the order they were written */

   for(ii=0; ii<cluster_count; ii++)
   {
      fprintf(stdout, "Cluster %3d :  First byte: %-5d | Length: %5d | Last byte: %5d \n\n",
         clustbyfp[ii]->lcd.w_cluster_num,
         clustbyfp[ii]->lcd.i_file_ptr,
         clustbyfp[ii]->i_fil_byte_size,
         clustbyfp[ii]->lcd.i_file_ptr + clustbyfp[ii]->i_fil_byte_size-1);
      if (logfile) fprintf(logfile, "Cluster %3d :  First byte: %-5d | Length: %5d | Last byte: %5d \n\n",
         clustbyfp[ii]->lcd.w_cluster_num,
         clustbyfp[ii]->lcd.i_file_ptr,
         clustbyfp[ii]->i_fil_byte_size,
         clustbyfp[ii]->lcd.i_file_ptr +
         clustbyfp[ii]->i_fil_byte_size-1);
   }
}

void GDisp()
{
   unsigned int   ii;

   if(group_count)
   {
      for (ii=0; ii<group_count; ii++)
      {
         if (objTable[group[ii].inst->oid].classid != OM_K_OMGROUP_ACTCLASSID)
            continue;
         fprintf(stdout, ">> Group id(oid): %-3d  Cluster: %-2d  Size: %-6d Init/Ext %4d/%-4d Next: %d\n",
            group[ii].inst->groupid, group[ii].inst->clusternum,
            group[ii].inst->size, group[ii].inst->initial_size,
            group[ii].inst->extend_size, group[ii].inst->next_avail);
         fprintf(stdout, "   Name: %s\n\n", group[ii].inst->name);
         if (logfile)
         {
            fprintf(logfile, ">> Group id(oid): %-3d  Cluster: %-2d  Size: %-6d Init/Ext %4d/%-4d Next: %d\n",
               group[ii].inst->groupid, group[ii].inst->clusternum,
               group[ii].inst->size, group[ii].inst->initial_size,
               group[ii].inst->extend_size, group[ii].inst->next_avail);
            fprintf(logfile, "   Name: %s\n\n",group[ii].inst->name);
         }
      }
   }
   else
   {
      fprintf(stdout, "No group objects in file.\n");
      if (logfile) fprintf(logfile, "No group objects in file.\n");
   }
}

void iDisp()
{
   unsigned int   ii, jj;

   if (iso_count)
   {
      for (ii=0; ii<oso->iso_d_descr.i_count; ii++)
      if (strcmp(iso_dir[ii].s_int_os_name, ""))
      {
         fprintf(stdout, "\n>>Internal OS name of target OS: %s | Oid of iso %d \n",
            iso_dir[ii].s_int_os_name, iso_dir[ii].iso_u.s_objid);
         if (logfile)
            fprintf(logfile, "\n>>Internal OS name of target OS: %s | Oid of iso %d \n",
               iso_dir[ii].s_int_os_name, iso_dir[ii].iso_u.s_objid);

         /* Match the oid of the iso object to the oid array.
         /* The order that the iso's appear in the vla may not be
         /* the same order that they appear in the file. */

         for (jj=0; jj<iso_count; jj++)
            if (iso_oid[jj] == iso_dir[ii].iso_u.s_objid) 
         {
            display_iso(iso[jj]);
            break;
         }
      }
   }
   else
   {
      fprintf(stdout, "No ISO objects in the file.\n");
      if (logfile) fprintf(logfile, "No ISO objects in the file.\n");
   }
}

void IDisp()
{
   unsigned int   ii;

   /* summary iso information */
   if (iso_count)
   {
      fprintf(stdout, "-- ISO links by class --\n");
      fprintf(stdout, " Links   Classname\n");
      if (logfile)
      {
         fprintf(logfile, "-- ISO links by class --\n");
         fprintf(logfile, " Links   Classname\n");
      }
      for (ii=0; ii<osco_count; ii++)
         if (iso_summary[ii]) 
         {
            fprintf(stdout, "  %4d   %s\n", iso_summary[ii], oscobyid[ii]->OSCO.s_name);
            if (logfile) fprintf(logfile, "  %4d   %s\n",
               iso_summary[ii], oscobyid[ii]->OSCO.s_name);
         }
   }
   else
   {
      fprintf(stdout, "No ISO objects in file.\n");
      if (logfile) fprintf(logfile, "No ISO objects in file.\n");
   }
}

void CDisp()
{
   unsigned int   ii, jj, *filed_oid;
   unsigned short *filed_classid;

   for (ii=0; ii<=highCnum; ii++)    
   {
      if (!clustbyid[ii])
         continue;
      fprintf(stdout, "\n>>Cluster %3d -----------",
         clustbyid[ii]->lcd.w_cluster_num);
      if (clustbyid[ii]->lcd.flags & OM_USERSPEC)
         fprintf(stdout, " (User specified)\n");
      else
         fprintf(stdout, "\n");
      fprintf(stdout, "  Offset(fp): %-7d Objects: %-4d\n",
         clustbyid[ii]->lcd.i_file_ptr, clustbyid[ii]->i_fil_num_objects);
      fprintf(stdout, "  Oid: %-4d  File size: %-7d  In-memory size: %-7d\n",
         clustbyid[ii]->lcd.oid, clustbyid[ii]->i_fil_byte_size,
         clustbyid[ii]->i_fil_byte_size - (clustbyid[ii]->i_fil_num_objects
         * 8));
      fprintf(stdout, "\n- Class summary -\n");
      if (logfile)
      {
         fprintf(logfile, "\n>>Cluster %3d -----------\n", clustbyid[ii]->lcd.w_cluster_num);
         if (clustbyid[ii]->lcd.flags & OM_USERSPEC)
            fprintf(logfile, " (User specified)\n");
         else
            fprintf(logfile, "\n");
         fprintf(logfile, "  Offset(fp): %-7d Objects: %-4d\n",
            clustbyid[ii]->lcd.i_file_ptr, clustbyid[ii]->i_fil_num_objects);
         fprintf(logfile, "  Oid: %-4d  File size: %-7d  In-memory size: %-7d\n",
            clustbyid[ii]->lcd.oid, clustbyid[ii]->i_fil_byte_size,
            clustbyid[ii]->i_fil_byte_size - (clustbyid[ii]->i_fil_num_objects
            * 8));
         fprintf(logfile, "\n- Class summary -\n");
      }

      /* give a summary of the objects of different classes */

      filed_oid = (unsigned int *) ((char *) &(clustbyid[ii]->
         i_filed_oid_list_descr.i_offset) + clustbyid[ii]->
         i_filed_oid_list_descr.i_offset);
      filed_classid = (unsigned short *) ((char *) &(clustbyid[ii]->
         w_filed_classid_list_descr.i_offset) +
         clustbyid[ii]->w_filed_classid_list_descr.i_offset);
      fprintf(stdout, "Classname      -classid-   -count-   -used-   -%% used-   -avg size-\n");
      if (logfile) fprintf(logfile,
         "Classname      -classid-   -count-   -used-   -%% used-   -avg size-\n");
      for(jj=0; jj<=(unsigned int)high_classid; jj++)
         classStats[jj].count = classStats[jj].size = 0;
      for (jj=0; jj<clustbyid[ii]->i_fil_num_objects; jj++)
      {
         classStats[filed_classid[jj]].count++;
         classStats[filed_classid[jj]].size +=
            GETOBJSIZE(objTable[filed_oid[jj]].size);
      }
      for(jj=0; jj<=(unsigned int) high_classid; jj++)
      {
         float used;

         if (classStats[jj].count)
         {
            if (!classStats[jj].size)
               used = (float) 0.;
            else
               used = (float) 100. * ((float) classStats[jj].size)/
               ((float) clustbyid[ii]->i_fil_byte_size);
            fprintf(stdout, "%-15s %5d     %7d  %8d  %8.1f%%    %9.1f\n",
               oscobyid[jj]->OSCO.s_name, jj,
               classStats[jj].count,
               classStats[jj].size,
               used,
               ((float) classStats[jj].size/
               (float) classStats[jj].count));
            if (logfile)
               fprintf(logfile,
                  "%-15s %5d     %7d  %8d  %8.1f%%    %9.1f\n",
                  oscobyid[jj]->OSCO.s_name, jj,
                  classStats[jj].count,
                  classStats[jj].size,
                  used,
                  ((float) classStats[jj].size/
                  (float) classStats[jj].count));
         }
      }
      fprintf(stdout, "\n\n");
      if (logfile) fprintf(logfile, "\n\n");
   }
}


void oDisp()
{
   unsigned int   start, limit, ii;
   char           flag, *ptr, *ptr2;

   /* show objects, clusters, classes, sizes and file pointers */
   fprintf(stdout, "There are %d objects in this object space, id's ranging from 0 to %d\n",
      objCnt, highOid);
   if (logfile)
      fprintf(logfile,"There are %d objects in this object space, id's ranging from 0 to %d\n",
         objCnt, highOid);
   flag = 1;
   while (flag)
   {
      fprintf(stdout, "   Enter an object id (displays data for a single object),\n");
      fprintf(stdout, "         a range of object id's (e.g., 0-100),\n");
      fprintf(stdout, "                 or\n");
      fprintf(stdout, "         'A' (displays data for ALL objects)\n");
      start = limit = 0;
      scanf("%s", buffer);
      flag = 0;
      if (buffer[0] != 'A')
      {
         if (ptr=(char *) strchr(buffer,'-'))
         {
            *ptr = '\0';
            for (ii=0; ii< (unsigned int) strlen(buffer); ii++)
            {
               if (!isdigit(buffer[ii]))
               {
                  flag = 1;
                  continue;
               }
            }
            start = (unsigned int) atoi(buffer);
            if (ptr2 = (char *) strchr(++ptr,'-'))
               *ptr2 = '\0';
            ptr2 = ptr;
            for (ii=0; ii< (unsigned int) strlen(ptr2); ii++)
            {
               if (!isdigit(*ptr2++))
               {
                  flag = 1;
                  continue;
               }
            }
            limit = atoi(ptr);
         }
         else
         {
            for (ii=0; ii< (unsigned int) strlen(buffer); ii++)
            {
               if (!isdigit(buffer[ii]))
               {
                  flag = 1;
                  continue;
               }
            }
            start = (unsigned int) atoi(buffer); /* Display single cluster */
         }
         if (!limit)
            limit = start;
      }
      else
         limit = highOid;
   }
   if (start > highOid)
      start = highOid;
   if (limit < start)
      limit = start;
   if (limit > highOid)
   {
      fprintf(stdout, "No such object id: %d\n", limit);
      if (logfile)
         fprintf(logfile, "No such object id: %d\n", limit);
      return;
   }
   fprintf(stdout, "\n>>Objects %d through %d----------- \n",
      start, limit);
   if (logfile)
      fprintf(logfile, "\n>>Objects %d through %d----------- \n",
         start, limit);
   fprintf(stdout, " Object   Cluster   Classid   Size   File Pointer\n");
   if (logfile)
      fprintf(logfile, " Object   Cluster   Classid   Size   File Pointer\n");
   for (ii=start; ii<=limit; ii++)
   {
      if (!objTable[ii].classid)
      {
         fprintf(stdout, "%d -- Unused object id\n", ii);
         if (logfile)
            fprintf(logfile,"%d -- Unused object id\n", ii);
      }
      else
      {
         fprintf(stdout, "%7d   %5d     %5d   %6d   %10d\n",
            ii, objTable[ii].cluster_num, objTable[ii].classid,
            GETOBJSIZE(objTable[ii].size), objTable[ii].fp);
         if (logfile)
         {
            fprintf(logfile, "%7d   %5d     %5d   %6d   %10d\n",
               ii, objTable[ii].cluster_num, objTable[ii].classid,
               GETOBJSIZE(objTable[ii].size), objTable[ii].fp);
         }
      }
   }
}

void rDisp()
{
   FILE           *op;
   unsigned int   ii;
   int            rtreeClassid, oid, jj, lfentries, nlentries,
                  leaf_count, nonleaf_count, *objid_p;
   float          *rtreePage;
   R_PAGE_3D_FLT  *cur_page_p;
   DB_3D_FLT_BOX  *key_p;
   char           printflag, yesNo;
   struct
   {
      int         oid;
      int         i_size;
      int         count;
      int         objid;
      float       rtreePage[1022];
      char        filler[500];
   } rtreeBuf;

   if (!(rtreeClassid = getOSCObyClassName("GRrtree")))
   {
      fprintf(stdout, "There are no Rtree objects in this file.\n");
      if (logfile)
         fprintf(logfile, "There are no rtree objects in this file.\n");
      return;
   }
   fprintf(stdout, "Evaluating Rtree.  GRrtree class id = %d\n",
      rtreeClassid);
   if (logfile)
      fprintf(logfile, "Evaluating Rtree.  GRrtree class id = %d\n",
         rtreeClassid);
   fprintf(stdout, "Do you want to see the Rtree pages? [n]: ");
   printflag = 0;
   fflush(stdin);
   yesNo = getc(stdin);
   fflush(stdin);
   if (yesNo == 'y' || yesNo == 'Y')
      printflag = 1;

   lfentries = nlentries = nonleaf_count = leaf_count = 0;
   if ( !( op = fopen( "/usr/tmp/leafobjs.dat", "w") ) )
   {
      fprintf(stdout, "Error opening /usr/tmp/leafobjs.dat\n");
      return;
   }
   for (ii=0; ii<=highOid; ii++)
   {
      if (objTable[ii].classid == 16 || objTable[ii].classid == rtreeClassid)
      {
         fseek(osfp, objTable[ii].fp + 8, 0);
         if (fread(&rtreeBuf, 1, (objTable[ii].size & 0xfffffff8), osfp)
            != (objTable[ii].size & 0xfffffff8))
         {
            printf("read error\n");
            continue;
         }
         if (printflag)
         {
            fprintf(stdout, "*** Object id %6d, Offset %d ***\n",
               ii, objTable[ii].fp);
            if (logfile)
               fprintf(logfile, "*** Object id %6d, Offset %d ***\n",
                  ii, objTable[ii].fp);
         }

#ifdef BIG_ENDIAN
         bigend_portOMrtree((objTable[ii].size & 0xfffffff8), &rtreeBuf,
            READ_PORT);
#endif

         rtreePage = (float *) ((int) &rtreeBuf.oid + 8); /* Point past hdr */
         cur_page_p = (R_PAGE_3D_FLT *) &rtreePage[2];
         key_p = cur_page_p->Key;
         objid_p = (int *) cur_page_p->Objid;
         if ( NOT_R_LEAF(cur_page_p->Header.Page_type) )
         {
            /* process non-leaf page */

            if (printflag)
            {
               fprintf(stdout, "NON-LEAF  <%d>\n", cur_page_p->Header.Page_type);
               if (logfile)
                  fprintf(logfile, "NON-LEAF  <%d>\n", cur_page_p->Header.Page_type);
            }
            nonleaf_count++;
            for (jj = 0; jj < (int) cur_page_p->Header.Key_count; jj++)
            {
               if (printflag)
               {
                  fprintf(stdout, "%3d <%6d>  {%8.3f,%8.3f,%8.3f}  {%8.3f,%8.3f,%8.3f}\n",
                     jj, *objid_p,
                     key_p->xmin, key_p->ymin, key_p->zmin,
                     key_p->xmax, key_p->ymax, key_p->zmax );
                  if (logfile)
                     fprintf(logfile, "%3d <%6d>  {%8.3f,%8.3f,%8.3f}  {%8.3f,%8.3f,%8.3f}\n",
                        jj, *objid_p,
                        key_p->xmin, key_p->ymin, key_p->zmin,
                        key_p->xmax, key_p->ymax, key_p->zmax );
                  if ( key_p->xmin > key_p->xmax )
                  {
                     fprintf(stdout, "ERROR: inverted x coord: ");
                     fprintf(stdout, "xmin=%f, xmax=%f\n", key_p->xmin, key_p->xmax);
                     if (logfile)
                        fprintf(logfile, "ERROR: inverted x coord: ");
                        fprintf(logfile, "xmin=%f, xmax=%f\n", key_p->xmin, key_p->xmax);
                  }
                  if ( key_p->ymin > key_p->ymax )
                  {
                     fprintf(stdout, "ERROR: inverted y coord: ");
                     fprintf(stdout, "ymin=%f, ymax=%f\n", key_p->ymin, key_p->ymax);
                     if (logfile)
                        fprintf(logfile, "ERROR: inverted y coord: ");
                        fprintf(logfile, "ymin=%f, ymax=%f\n", key_p->ymin, key_p->ymax);
                  }
                  if ( key_p->zmin > key_p->zmax )
                  {
                     fprintf(stdout, "ERROR: inverted z coord: ");
                     fprintf(stdout, "zmin=%f, zmax=%f\n", key_p->zmin, key_p->zmax);
                     if (logfile)
                        fprintf(logfile, "ERROR: inverted z coord: ");
                        fprintf(logfile, "zmin=%f, zmax=%f\n", key_p->zmin, key_p->zmax);
                  }
               }
               nlentries++;
               key_p += 1;
               objid_p += 1;
            }
         }
         else
         {
            /* process leaf page */
            if (printflag)
            {
               fprintf(stdout, "LEAF  <%d>\n", cur_page_p->Header.Page_type);
               if (logfile)
                  fprintf(logfile, "LEAF  <%d>\n", cur_page_p->Header.Page_type);
            }
            leaf_count++;
            for (jj = 0; jj < (int) cur_page_p->Header.Key_count; jj++)
            {
               fwrite(objid_p, 1, 4, op);
               if (printflag)
               {
                  fprintf(stdout, "%3d <%6d>  {%8.3f,%8.3f,%8.3f}  {%8.3f,%8.3f,%8.3f}\n",
                     jj, *objid_p,
                     key_p->xmin, key_p->ymin, key_p->zmin,
                     key_p->xmax, key_p->ymax, key_p->zmax );
                  if (logfile)
                     fprintf(logfile, "%3d <%6d>  {%8.3f,%8.3f,%8.3f}  {%8.3f,%8.3f,%8.3f}\n",
                        jj, *objid_p,
                        key_p->xmin, key_p->ymin, key_p->zmin,
                        key_p->xmax, key_p->ymax, key_p->zmax );
                  if ( key_p->xmin > key_p->xmax )
                  {
                     fprintf(stdout, "ERROR: inverted x coord: ");
                     fprintf(stdout, "xmin=%f, xmax=%f\n", key_p->xmin, key_p->xmax);
                     if (logfile)
                        fprintf(logfile, "ERROR: inverted x coord: ");
                        fprintf(logfile, "xmin=%f, xmax=%f\n", key_p->xmin, key_p->xmax);
                  }
                  if ( key_p->ymin > key_p->ymax )
                  {
                     fprintf(stdout, "ERROR: inverted y coord: ");
                     fprintf(stdout, "ymin=%f, ymax=%f\n", key_p->ymin, key_p->ymax);
                     if (logfile)
                        fprintf(logfile, "ERROR: inverted y coord: ");
                        fprintf(logfile, "ymin=%f, ymax=%f\n", key_p->ymin, key_p->ymax);
                  }
                  if ( key_p->zmin > key_p->zmax )
                  {
                     fprintf(stdout, "ERROR: inverted z coord: ");
                     fprintf(stdout, "zmin=%f, zmax=%f\n", key_p->zmin, key_p->zmax);
                     if (logfile)
                        fprintf(logfile, "ERROR: inverted z coord: ");
                        fprintf(logfile, "zmin=%f, zmax=%f\n", key_p->zmin, key_p->zmax);
                  }
               }
               key_p += 1;
               objid_p += 1;
            }	   /* for */
            lfentries += (jj+1);
         }
      }
   }
   if (nlentries != (leaf_count + nonleaf_count -1))
   {
      fprintf(stdout, "Corrupt tree structure!\n");
      if (logfile)
         fprintf(logfile, "Corrupt tree structure!\n");
   }
   fprintf(stdout, "   Leaf entries count      = %d\n", lfentries);
   fprintf(stdout, "   Non-leaf entries count  = %d\n", nlentries);
   fprintf(stdout, "   Leaf page count         = %d\n", leaf_count);
   fprintf(stdout, "   Non Leaf page count     = %d\n", nonleaf_count);
   fprintf(stdout, "\nSpace efficiency = %5.2f %%\n",
       (((float)lfentries+nlentries)*100.0)/ 
       (R_MAX_KEYS_3D_FLT*(leaf_count+nonleaf_count)) );
   fprintf(stdout, "\nThe following object ids appear in the Rtree but are not valid:\n");
   if (logfile)
   {
      fprintf(logfile, "   Leaf entries count      = %d\n", lfentries);
      fprintf(logfile, "   Non-leaf entries count  = %d\n", nlentries);
      fprintf(logfile, "   Leaf page count         = %d\n", leaf_count);
      fprintf(logfile, "   Non Leaf page count     = %d\n", nonleaf_count);
      fprintf(logfile, "\nSpace efficiency = %5.2f %%\n",
          (((float)lfentries+nlentries)*100.0)/ 
          (R_MAX_KEYS_3D_FLT*(leaf_count+nonleaf_count)) );
      fprintf(logfile, "\nThe following object ids appear in the Rtree but are not valid:\n");
   }
   fclose(op);
   if (!(op = fopen("/usr/tmp/leafobjs.dat", "r")))
      return;
   fseek(op, 0, 0);
   while(fread(&oid, 1, 4, op) == 4)
   {
      if (!objTable[oid].classid)
      {
         fprintf(stdout, "%d\n", oid);
         if (logfile)
            fprintf(logfile, "%d\n", oid);
      }
   }
   fclose(op);
}


void RDisp()
{
   /* Display OMTagCon info */

   unsigned int   ii, first = 1;

   for (ii=0; ii<group_count; ii++)
   {
      if (objTable[group[ii].inst->oid].classid != OM_K_OMTAGCON_ACTCLASSID)
         continue;
      if (first)
      {
         fprintf(stdout, "\nThere are OMTag connections to the following files:\n");
         if (logfile)
            fprintf(logfile, "\nThere are OMTag connections to the following files:\n");
         first = 0;
      }
      fprintf(stdout, "%s\n",
         ((struct OMTagCon_instance *) group[ii].inst)->osname);
      if (logfile)
         fprintf(logfile, "%s\n",
            ((struct OMTagCon_instance *) group[ii].inst)->osname);
   }
}


/***********************************************************************/
/*display_channel(p_channel)
OM_p_CHANNEL_HDR  p_channel;
{
   OM_p_CHANNEL_LINK    p_chanlnk;
   OM_S_BIG_TAIL    tail;

   p_chanlnk = OM_PTR_TO_CHAN_LINK(p_channel);
   fprintf(stdout, "Channel structure for channel %d.%d \n",
      p_chanlnk->channum.classid, p_chanlnk->channum.number);

   fprintf(stdout, "Flags: ");

   if (p_channel->flags & OM_CH_singleton) {
      fprintf(stdout, " OM_CH_singleton");
   }
   if (p_channel->flags & OM_CH_1_1) {
      fprintf(stdout, " OM_CH_1_1");
   }
   if (p_channel->flags & OM_CH_m_1) {
      fprintf(stdout, " OM_CH_m_1");
   }
   if (p_channel->flags & OM_CH_1_m) {
      fprintf(stdout, " OM_CH_1_m");
   }
   if (p_channel->flags & OM_CH_m_m) {
      fprintf(stdout, " OM_CH_m_m");
   }
   if (p_channel->flags & OM_CH_absordered) {
      fprintf(stdout, " OM_CH_absordered");
   }
   if (p_channel->flags & OM_CH_relordered) {
      fprintf(stdout, " OM_CH_relordered");
   }
   if (p_channel->flags & OM_CH_full) {
      fprintf(stdout, " OM_CH_full");
   }
   if (p_channel->flags & OM_CH_restricted) {
      fprintf(stdout, " OM_CH_restricted");
   }
   if (p_channel->flags & OM_CH_in_use) {
      fprintf(stdout, " OM_CH_in_use");
   }
   if (p_channel->flags & OM_CH_tail_exists) {
      fprintf(stdout, " OM_CH_tail_exist");
   }
   if (p_channel->flags & OM_CH_collapse_count) {
      fprintf(stdout, " OM_CH_collapse_count");
   }
   fprintf(stdout, " )\n");

   OM_GET_TAIL(p_channel, tail);
*/
  /* The send depth is replaced by the flag of OM_CH_in_use */
/*
   fprintf(stdout, "Collapse: %d | Last index: %d | Count: %d \n",
      tail.collapse_count, tail.last_index, p_channel->u1.count);

   if (logfile)
   {
      fprintf(logfile, "Channel structure for channel %d.%d \n",
         p_chanlnk->channum.classid, p_chanlnk->channum.number);

      fprintf(logfile, "Flags: ");

      if (p_channel->flags & OM_CH_singleton) {
         fprintf(logfile, " OM_CH_singleton");
      }
      if (p_channel->flags & OM_CH_1_1) {
         fprintf(logfile, " OM_CH_1_1");
      }
      if (p_channel->flags & OM_CH_m_1) {
         fprintf(logfile, " OM_CH_m_1");
      }
      if (p_channel->flags & OM_CH_1_m) {
         fprintf(logfile, " OM_CH_1_m");
      }
      if (p_channel->flags & OM_CH_m_m) {
         fprintf(logfile, " OM_CH_m_m");
      }
      if (p_channel->flags & OM_CH_absordered) {
         fprintf(logfile, " OM_CH_absordered");
      }
      if (p_channel->flags & OM_CH_relordered) {
         fprintf(logfile, " OM_CH_relordered");
      }
      if (p_channel->flags & OM_CH_full) {
         fprintf(logfile, " OM_CH_full");
      }
      if (p_channel->flags & OM_CH_restricted) {
         fprintf(logfile, " OM_CH_restricted");
      }
      if (p_channel->flags & OM_CH_in_use) {
         fprintf(logfile, " OM_CH_in_use");
      }
      if (p_channel->flags & OM_CH_tail_exists) {
         fprintf(logfile, " OM_CH_tail_exist");
      }
      if (p_channel->flags & OM_CH_collapse_count) {
         fprintf(logfile, " OM_CH_collapse_count");
      }
      fprintf(logfile, " )\n");

      fprintf(logfile, "Collapse: %d | Last index: %d | Count: %d \n",
         tail.collapse_count, tail.last_index, p_channel->u1.count);
   }
}
*/


/********************************************************************/
/* this routine does a simple bubble sort on a field in the sort_list
/* array. There are 3 types of sorts, character, integer and string.
/* the caller will fill in the elements of the array with the values to
/* be sorted in the appropriate field in the structure. There is also
/* a pointer field to keep track of where the value came from, if necessary.
*/

sort_routine(sort_list, num_elements, sort_type)
struct sort_element  *sort_list;
int                  num_elements, sort_type;
{
   int                  ii, jj;
   struct sort_element  work_element;

   if(num_elements <= 1)
      return(1);

   for(ii=0; ii<num_elements - 1; ++ii)
      for(jj=ii+1; jj<num_elements; ++jj)
      {
         /* int sort? */
         if ((sort_type == INT_SORT) && 
             (sort_list[ii].sort_integer > sort_list[jj].sort_integer))
         {
            work_element = sort_list[ii];
            sort_list[ii] = sort_list[jj];
            sort_list[jj] = work_element;
         }
         /* char sort? */	
         if ((sort_type == CHAR_SORT) && 
            (sort_list[ii].sort_char > sort_list[jj].sort_char))
         {
            work_element = sort_list[ii];
            sort_list[ii] = sort_list[jj];
            sort_list[jj] = work_element;
         }
         /* string sort? */	
         if ((sort_type == STRING_SORT) && (strcmp(sort_list[ii].sort_string,
            sort_list[jj].sort_string) > 0))
         {
            work_element = sort_list[ii];
            sort_list[ii] = sort_list[jj];
            sort_list[jj] = work_element;
         }
      }
      return(1);
}


/**********************************************************************/
void display_iso(p_iso)
struct OMISO_instance *p_iso;
{
   unsigned int      oid, ii;
   short             chan_classid = 0;
   char              oid_classname[100], channel_classname[100];
   struct ISO_data   *iso_data;

   if (logfile)
   {
      fprintf(logfile, "   Dangles: %d | Target iso oid: %d | Flags: ",
         p_iso->w_dcount,p_iso->S_target_iso);
      if (p_iso->w_ISO_flags&ISO_no_target)
         fprintf(logfile, "Target OS not loaded");
      if (p_iso->w_ISO_flags&ISO_to_transient)
         fprintf(logfile, "; Target OS is transient");
      fprintf(logfile, "\n\n");
   } 
   fprintf(stdout, "   Dangles: %d | Target iso oid: %d | Flags: ",
      p_iso->w_dcount,p_iso->S_target_iso);

   if (p_iso->w_ISO_flags&ISO_no_target)
      fprintf(stdout, "Target OS not loaded");
   if (p_iso->w_ISO_flags&ISO_to_transient)
      fprintf(stdout, "; Target OS is transient");
   fprintf(stdout, "\n\n");
   iso_data = (struct ISO_data *) ((char *) &p_iso->iso_d_descr.i_offset +
      p_iso->iso_d_descr.i_offset);

   for (ii=0; ii<p_iso->iso_d_descr.i_count; ii++)
   {
      if (iso_data[ii].w_flags & ISO_to_object)
      {
         if (!(iso_data[ii].w_flags & ISO_disconnected))
         {
            /* Get the classname and classid of this oid. */

            if (((oid = iso_data[ii].iso_u.s_objid) > highOid) ||
                !(objTable[oid].fp))
               fprintf(stdout, "\nObject id %d is not valid.\n", oid);
            else if (objTable[oid].classid > high_classid ||
                     !oscobyid[objTable[oid].classid])
               fprintf(stdout, "\nObject id %d has an invalid class id %d.\n",
                  oid, objTable[oid].classid);
            else
            {
               strcpy(oid_classname, oscobyid[objTable[oid].classid]->OSCO.s_name);
               if (((chan_classid = iso_data[ii].chan.classid) >
                    (int) high_classid) || !oscobyid[chan_classid])
                  fprintf(stdout, "\nChannel classid (%d) is invalid.\n",
                     chan_classid);
               else
                  strcpy(channel_classname,
                  oscobyid[chan_classid]->OSCO.s_name);
            }
            if (logfile)
            {
               fprintf(logfile, "   Classid of To oid: %3d | Classname: %s \n",
                  chan_classid, oid_classname);
               fprintf(logfile, "   To oid: %3d | Channel %3d.%2d (def class %s)\n",
                  oid, chan_classid,
                  iso_data[ii].chan.number, channel_classname);
            }

            fprintf(stdout, "   Classid of To oid: %3d | Classname: %s \n",
               chan_classid, oid_classname);
            fprintf(stdout, "   To oid: %3d | Channel %3d.%2d (def class %s)\n",
               oid, chan_classid,
               iso_data[ii].chan.number, channel_classname);
         }
         else
         {
            oid = iso_data[ii].iso_u.s_objid;
            fprintf(stdout, "   To oid: %3d\n", oid);
            if (logfile)
               fprintf(logfile, "   To oid: %3d\n", oid);
         }

         fprintf(stdout, "   Flags: (%X hex)",iso_data[ii].w_flags);
         if (iso_data[ii].w_flags & ISO_disconnected)
            fprintf(stdout, "(OS obj disconnected)");
         if (iso_data[ii].w_flags & ISO_to_object) 
            fprintf(stdout, "(iso points to an object)\n");
         fprintf(stdout, "   ------------------------------------------\n");
         if (logfile)
         {
            fprintf(logfile, "   Flags: (%X hex)",iso_data[ii].w_flags);
            if (iso_data[ii].w_flags & ISO_disconnected)
               fprintf(logfile, "(OS obj disconnected)");
            if (iso_data[ii].w_flags & ISO_to_object) 
               fprintf(logfile, "(iso points to an object)\n");
            fprintf(logfile, "   -------------------------------------------\n");
         }
      }
   }           /* end of iso for loop */
}


/********************************************/
/* Routine to dump an object from the file. */
/********************************************/
void dump_object()
{
   int               fp, objSize, fileSize, ii, jj, kk, ll, nn;
   char              *obj, getting_input, cont, buff[17];
   unsigned char     *p;
   OM_S_FILEOBJHDR   objHdr;

#ifdef BIG_ENDIAN
   short             tempshort;
#endif

   getting_input = 1;
   fp = 0;
   fseek(osfp,0,2);
   fileSize = ftell(osfp);
   fprintf(stdout, "Enter file location of object to dump: ");

   while (getting_input)
   {
      scanf("%d", &fp);
      if (!fp)
         fp = 512;
      if (fp >= fileSize)
      {
         fprintf(stdout, "Please enter the file location of an object that is between 0 and\n");
         fprintf(stdout, "%d (the end of the file): \n", fileSize);
         fflush(stdin);
      }
      else
         getting_input = 0;
   }

   if (logfile)
      fprintf(logfile,"Enter file location of object to dump: %d\n",fp);
   buff[16] = 0;
   while(1)
   {
      fseek(osfp, fp, 0);
      if (fread(&objHdr, sizeof(OM_S_FILEOBJHDR), 1, osfp) != 1)
      {
         fprintf(stdout, "Error occurred during read.  Cannot continue from here.\n");
         if (logfile)
            fprintf(logfile,"Error occurred during read.  Cannot continue from here.\n");
         break;
      }

#ifdef BIG_ENDIAN
      swapint(&objHdr.i_size, &nn);
      objHdr.i_size = nn;
      swapint(&objHdr.oid, &nn);
      objHdr.oid = nn;
      swapint(&objHdr.tag, &nn);
      objHdr.tag = nn;
      swapshort(&objHdr.classid, &tempshort);
      objHdr.classid = tempshort;
      swapshort(&objHdr.version, &tempshort);
      objHdr.version = tempshort;
#endif

      objSize = GETOBJSIZE(objHdr.i_size);    /* File size of object */
      fprintf(stdout, "\n\n%8d  Obj id: %d  Class: %d  Tag: %d  Tag Version: %d  Size: %d",
         fp, objHdr.oid, objHdr.classid, objHdr.tag, objHdr.version, objSize);
      if (logfile)
         fprintf(logfile, "\n\n%8d  Obj id: %d  Class: %d  Tag: %d  Tag Version: %d  Size: %d",
            fp, objHdr.oid, objHdr.classid, objHdr.tag, objHdr.version, objSize);
      fprintf(stdout, "\n\nContinue? [<CR> to skip to next object, 'd' to dump object, 'q' to quit]: ");
      fflush(stdin);
      cont = getc(stdin);
      fflush(stdin);
      if (cont == 'q')
      {
         if (logfile) fprintf(logfile,"q\n");
         break;
      }
      else if (cont == 'd')
      {
         obj = (char *) om$malloc(size=objSize);
         if (!obj)
         {
            fprintf(stdout, "Could not allocate %d bytes.\n", objSize);
            return;
         }
         fseek(osfp, fp, 0);
         if ((ii = fread(obj, 1, objSize, osfp)) != objSize)
         {
            fprintf(stdout, "\nError occurred during read.  Cannot continue from here.\n");
            if (logfile)
               fprintf(logfile,"\nError occurred during read.  Cannot continue from here.\n");
            om$dealloc(ptr = (char *) obj);
            break;
         }
         kk = objSize;
         p = (unsigned char *) obj;
         fprintf(stdout, "\n");
         if (logfile) fprintf(logfile, "\n");
         for (ii=0, nn=0; ii<objSize/16; ii++)
         {
            fprintf(stdout, "%8d",fp);
            if (logfile) fprintf(logfile,"%8d",fp);
            for (jj=0; jj<4; jj++)
            {
               fprintf(stdout, " ");
               if (logfile) fprintf(logfile," ");
               for (ll=0; ll<4; ll++)
               {
                  fprintf(stdout, "%2.2x", *p);
                  if (logfile) fprintf(logfile, "%2.2x", *p);
                  if (isprint(*p))
                     buff[nn++] = *p;
                  else
                     buff[nn++] = '.';
                  p++;
               }
            }
            fprintf(stdout, " | %s\n",buff);
            if (logfile) fprintf(logfile," | %s\n",buff);
            kk -= 16;
            fp += 16;
            nn = 0;
         }
         if (kk)
         {
            fprintf(stdout, "%8d",fp);
            if (logfile) fprintf(logfile,"%8d",fp);
            for (ii=0; ii<kk; ii++)
            {
               if (!(ii%4))
               {
                  fprintf(stdout, " ");
                  if (logfile) fprintf(logfile," ");
               }
               fprintf(stdout, "%2.2x",*p);
               if (logfile) fprintf(logfile,"%2.2x",*p);
               if (isprint(*p))
                  buff[nn++] = *p;
               else
                  buff[nn++] = '.';
               buff[nn] = 0;
               p++;
               fp++;
            }
            for (ii=0; ii<(36-((2*kk)+(kk/4))); ii++)
            {
               fprintf(stdout, " ");
               if (logfile) fprintf(logfile," ");
            }
            fprintf(stdout, " | %s\n", buff);
            if (logfile) fprintf(logfile," | %s\n", buff);
         }
         om$dealloc(ptr = (char *) obj);
      }
      else
         fp += objSize;
   }
}


/***********************************************************/
/* Routine to deposit a value into the filed object space. */
/***********************************************************/

void deposit()
{
   int               sts, pos, filesize, filepos=0;
   time_t            clk;
   char              message[64], data, getting_user_input, changing_bytes;

   fprintf(stdout, "This option allows you to deposit data into the file a byte at\n");
   fprintf(stdout, "a time.  After you enter the file location where changes will be\n");
   fprintf(stdout, "made, Dr. OS prompts you for data to be deposited at each byte\n");
   fprintf(stdout, "from that point on, until you enter 'q' to quit depositing.\n\n");

   fseek(osfp, 0, 2);
   filesize = ftell(osfp);
   getting_user_input = 1;
   while (getting_user_input)
   {
      fprintf(stdout, "Enter the file location of the first byte to be changed: ");
      scanf("%s",buffer);
      filepos = atoi(buffer);
      if (filepos >= filesize)
      {
         fprintf(stdout, "   Maximum file position is %d\n", filesize);
         continue;
      }
      if (logfile)
         fprintf(logfile,"Enter the file location of the first byte to be changed: %d",filepos);

      pos = filepos;
      changing_bytes = 1;
      while (changing_bytes)
      {
         fseek(osfp, pos, 0);
         if (!fread(buffer, 1, 1, osfp))
         {
            perror("Read error");
            return;
         }
         fseek(osfp, pos, 0);
         fprintf(stdout, "Current value of byte at loc. %d: %2.2x (hex)\n",
            pos, buffer[0]);
         if (logfile)
            fprintf(logfile,"Current value of byte at loc. %d: %2.2x (hex)\n",
               pos, buffer[0]);
         fprintf(stdout, "Enter new value in hexadecimal [q to quit]: ");
         scanf("%s", buffer);
         if (buffer[0] == 'q')
            changing_bytes = 0;
         else
         {
            if ((buffer[0] <= '9') && (buffer[0] >= '0'))
               buffer[0] -= 0x30;
            else if ((buffer[0] <= 'F') && (buffer[0] >= 'A'))
               buffer[0] -= 0x37;
            else if ((buffer[0] <= 'f') && (buffer[0] >= 'a'))
               buffer[0] -= 0x57;
            else
            {
               changing_bytes = 0;
               continue;
            }
            if (buffer[1])
            {
               if ((buffer[1] <= '9') && (buffer[1] >= '0'))
                  buffer[1] -= 0x30;
               else if ((buffer[1] <= 'F') && (buffer[1] >= 'A'))
                  buffer[1] -= 0x37;
               else if ((buffer[1] <= 'f') && (buffer[1] >= 'a'))
                  buffer[1] -= 0x57;
               else
               {
                  changing_bytes = 0;
                  continue;
               }
               data = (buffer[0] << 4) | 0x0f;
               data &= (buffer[1] | 0xf0);
            }
            else
               data = buffer[0];
            fputc(data,osfp);
            pos++;

            if (logfile)
               fprintf(logfile,"Enter new value in hexadecimal: %2.2x\n",data);
         }
         getting_user_input = 0;
      }
   }		/* End of while (getting_user_input) */

   fseek(osfp, (int) filehdr.dros_msgstr - (int) &filehdr, 0);
   clk = time(0);
   sprintf(message, "%s Location %d modified by Dr. OS", ctime(&clk), filepos);
   sts = fwrite(message, 64, 1, osfp);
}



/********************************************************************/
void display_header()
{
   fprintf(stdout, "\nOSheader contents ------------------------------------\n");
   fprintf(stdout, "OM version            %d.%d\n",filehdr.w_major_version,
      filehdr.w_minor_version);
   fprintf(stdout, "Data written          %d bytes (%d clusters, %d objects)\n",
         filehdr.i_size, filehdr.w_num_clusters, filehdr.i_num_objs);
   fprintf(stdout, "Cluster 0 file loc    %d\n",filehdr.fp_cluster0);
   fprintf(stdout, "OSO file loc          %d\n",filehdr.fp_OSO);
   fprintf(stdout, "Cluster 0 inst loc    %d\n",filehdr.fp_Cluster_instance);
   fprintf(stdout, "OSO instance file loc %d\n",filehdr.fp_OSO_instance);
   fprintf(stdout, "OS object id          %d\n",filehdr.S_OS_object);
   fprintf(stdout, "OSO filed classid     %d/%s\n",filehdr.OSOfiledClassid,
      filehdr.s_OSO_classname);
   fprintf(stdout, "Spacemap size         %d entries\n",filehdr.i_spacemap_size);
   fprintf(stdout, "Appl ver file loc     %d\n",filehdr.fp_appver);
   fprintf(stdout, "Num appl versions     %d\n",filehdr.i_num_appver);
   fprintf(stdout, "Write OS start time   %s"  ,filehdr.start_time);
   fprintf(stdout, "Write OS end time     %s"  ,filehdr.stop_time);
   fprintf(stdout, "Write OS error msg    %s\n",filehdr.write_msgstr);
   if (filehdr.image_name[0])
      fprintf(stdout, "Image name            %s\n",filehdr.image_name);
   fprintf(stdout, "Object Space Type     %d\n", filehdr.os_flags);
   fprintf(stdout, "Processor             %s, Node %s\n",filehdr.syst.mach_name.machine,
      filehdr.syst.mach_name.nodename);
   fprintf(stdout, "System                %s %s %s\n",filehdr.syst.mach_name.sysname,
      filehdr.syst.mach_name.release, filehdr.syst.mach_name.version);
   if (!strcmp(filehdr.dros_msgstr, "Successful recluster"))
         fprintf(stdout, "%s\n", filehdr.dros_msgstr);
   fprintf(stdout, "-------------------------------------------------------\n");

   if (logfile) {
      fprintf(logfile,"\n\nOSheader contents ------------------------------------\n");
      fprintf(logfile,"OM version            %d.%d\n",
         filehdr.w_major_version, filehdr.w_minor_version);
      fprintf(logfile, "Data written          %d bytes (%d clusters, %d objects)\n",
            filehdr.i_size, filehdr.w_num_clusters, filehdr.i_num_objs);
      fprintf(logfile,"Cluster 0 file loc    %d\n",filehdr.fp_cluster0);
      fprintf(logfile,"OSO file loc          %d\n",filehdr.fp_OSO);
      fprintf(logfile,"Cluster 0 inst loc    %d\n",filehdr.fp_Cluster_instance);
      fprintf(logfile,"OSO instance file loc %d\n",filehdr.fp_OSO_instance);
      fprintf(logfile,"OS object id          %d\n",filehdr.S_OS_object);
      fprintf(logfile,"OSO filed classid     %d/%s\n",filehdr.OSOfiledClassid,
         filehdr.s_OSO_classname);
      fprintf(logfile,"Spacemap size         %d entries\n",filehdr.i_spacemap_size);
      fprintf(logfile,"Appl ver file loc     %d\n",filehdr.fp_appver);
      fprintf(logfile,"Num appl versions     %d\n",filehdr.i_num_appver);
      fprintf(logfile,"Write OS start time   %s"  ,filehdr.start_time);
      fprintf(logfile,"Write OS end time     %s"  ,filehdr.stop_time);
      fprintf(logfile,"Write OS error msg    %s\n",filehdr.write_msgstr);
      if (filehdr.image_name[0])
         fprintf(stdout, "Image name            %s\n",filehdr.image_name);
      fprintf(logfile, "Object Space Type     %d\n", filehdr.os_flags);
      fprintf(logfile,"Processor             %s, Node %s\n",
         filehdr.syst.mach_name.machine, filehdr.syst.mach_name.nodename);
      fprintf(logfile,"System                %s %s %s\n",
         filehdr.syst.mach_name.sysname, filehdr.syst.mach_name.release,
         filehdr.syst.mach_name.version);
      if (!strcmp(filehdr.dros_msgstr, "Successful recluster"))
         fprintf(logfile, "%s\n", filehdr.dros_msgstr);
      fprintf(logfile,"-------------------------------------------------------\n");
   }
}


void appDisp()
{
   unsigned int   ii;
   char           appver[32];

   if (filehdr.fp_appver && (-1 == (fseek(osfp, filehdr.fp_appver, 0))))
   {
      fprintf(stdout, "\nError seeking to application version stamps.\n");
      fclose(osfp);
      return;
   }      
   fprintf (stdout, "Application Version Stamps ----------------------------\n");
   if (logfile)
      fprintf(logfile,"Application Version Stamps ----------------------------\n");
   for (ii=0; ii<filehdr.i_num_appver; ++ii)
   {
      if (32 != (fread (appver, 1, 32, osfp)))
         fprintf(stdout, "\nError reading application version stamp %d at %d.\n",
            ii, ftell(osfp));
      fprintf(stdout, "%s\n", appver);
      if (logfile)
         fprintf(logfile, "%s\n", appver);
   }
   fprintf(stdout, "-------------------------------------------------------\n");
   if (logfile)
      fprintf(logfile,"-------------------------------------------------------\n");
}



/*****************************************************************/
void display_osco(p_OSCO)
struct OMOSCO_instance *p_OSCO;
{
   int                     kk, ll, len, off;
   unsigned int            ii, jj;
   unsigned short          *res_channum, typ;
   struct sd_chan_info     *chan_info;
   char                    *res_class;
   struct component_list_struct *component_list;
   struct sd_vla_list           *vla_list;

   if (!p_OSCO)
      return;
   fprintf(stdout, "------Class %s (version %d.%d) ------\n",p_OSCO->OSCO.s_name,
      p_OSCO->OSCO.w_major_version, p_OSCO->OSCO.w_minor_version);

   fprintf(stdout, "Classid: %d  opp ver: %d.%d  Num of objs: %d  Active Subclasses %d  Oid %d\n",
      p_OSCO->OSCO.w_classid,p_OSCO->OSCO.w_oppmaj_version,           
      p_OSCO->OSCO.w_oppmin_version,p_OSCO->OSCO.i_refcnt,                   
      p_OSCO->OSCO.w_child_refcnt, p_OSCO->OSCO.OSCO_oid);

   component_list = (struct component_list_struct *)
      (p_OSCO->component_list_descr.i_offset +
      (char *) &p_OSCO->component_list_descr.i_offset);
   fprintf(stdout, "  Number of parents: %d  Component size: %d\n  Ancestry: %\n",
      p_OSCO->num_parents,p_OSCO->component_size,
      p_OSCO->component_list_descr.i_count);
   for (ii=0; ii<p_OSCO->component_list_descr.i_count; ii++)
   {
      if (!oscobyid[component_list[ii].classid])
      {
         fprintf(stdout, "\n    ***** ERROR: Component %d does not exist! *****\n\n", ii);
         continue;
      }
      fprintf(stdout, "    %s    Classid: %d   Offset: %d\n",
         oscobyid[component_list[ii].classid]->OSCO.s_name,
         component_list[ii].classid,component_list[ii].offset);
      off = component_list[ii].offset;

      vla_list = (struct sd_vla_list *) (oscobyid[component_list[ii].classid]->
         vla_list_descr.i_offset + (char *) &oscobyid
         [component_list[ii].classid]->vla_list_descr.i_offset);
      fprintf(stdout, "       Number of variable length arrays: %d\n",
         oscobyid[component_list[ii].classid]->vla_list_descr.i_count);
      for (jj=0; jj<oscobyid[component_list[ii].classid]->
         vla_list_descr.i_count; jj++)
         fprintf(stdout, "         Element size: %-5d Offset from object: %d\n",
            vla_list[jj].elt_size,vla_list[jj].offset+off);

      chan_info = (struct sd_chan_info *) (oscobyid[component_list[ii].
         classid]->chan_info_descr.i_offset + (char *) &oscobyid
         [component_list[ii].classid]->chan_info_descr.i_offset);
      res_class = (char *) (oscobyid[component_list[ii].classid]->
         res_classname_descr.i_offset + (char *) &oscobyid
         [component_list[ii].classid]->res_classname_descr.i_offset);
      res_channum = (unsigned short *) (oscobyid[component_list[ii].classid]->
         res_channum_descr.i_offset + (char *) &oscobyid
         [component_list[ii].classid]->res_channum_descr.i_offset);

      fprintf(stdout, "       Number of channels: %d\n",oscobyid
         [component_list[ii].classid]->chan_info_descr.i_count);

      kk = ll = 0;
      for (jj=0; jj<oscobyid[component_list[ii].classid]->
           chan_info_descr.i_count; jj++) {
         fprintf(stdout, "         Offset: %d  Type:",chan_info[jj].offset+off);
         typ = chan_info[jj].type;
         if (typ & CD_1_1) fprintf(stdout, " 1_1");
         if (typ & CD_1_m) fprintf(stdout, " 1_m");
         if (typ & CD_m_1) fprintf(stdout, " m_1");
         if (typ & CD_m_m) fprintf(stdout, " m_m");
         if (typ & CD_absordered) fprintf(stdout, " absordered");
         if (typ & CD_relordered) fprintf(stdout, " relordered");
         if (typ & CD_restricted) {
            fprintf(stdout, " restricted to ");
            len = strlen(&res_class[kk]);
            fprintf(stdout, "(%s,%d)",&res_class[kk],res_channum[ll]);
            kk += (len + 1);
            ++ll;
         }
         fprintf(stdout, "\n");
      }
   }

   if (logfile)
   {
      fprintf(logfile, "------Class %s (version %d.%d) ------\n",p_OSCO->OSCO.s_name, p_OSCO->OSCO.w_major_version, p_OSCO->OSCO.w_minor_version);
      fprintf(logfile, "Classid: %d  opp ver: %d.%d  Num of objs: %d  Active Subclasses %d  Oid: %d\n",
         p_OSCO->OSCO.w_classid, p_OSCO->OSCO.w_oppmaj_version,
         p_OSCO->OSCO.w_oppmin_version, p_OSCO->OSCO.i_refcnt,
         p_OSCO->OSCO.w_child_refcnt, p_OSCO->OSCO.OSCO_oid);
      fprintf(logfile,"     Number of parents: %d  Component size: %d\n  Ancestry: %\n",
         p_OSCO->num_parents,p_OSCO->component_size,
         p_OSCO->component_list_descr.i_count);
      for (ii=0; ii<p_OSCO->component_list_descr.i_count; ii++)
      {
         if (!oscobyid[component_list[ii].classid])
         {
            fprintf(logfile, "\n    ***** ERROR: Component %d does not exist! *****\n\n", ii);
            continue;
         }
         fprintf(logfile,"    %s    Classid: %d   Offset: %d\n",
            oscobyid[component_list[ii].classid]->OSCO.s_name,
            component_list[ii].classid,component_list[ii].offset);

         off = component_list[ii].offset;

         vla_list = (struct sd_vla_list *) (oscobyid[component_list[ii].
            classid]->vla_list_descr.i_offset + (char *) &oscobyid
            [component_list[ii].classid]->vla_list_descr.i_offset);
         fprintf(logfile,"       Number of variable length arrays: %d\n",
            oscobyid[component_list[ii].classid]->vla_list_descr.i_count);
         for (jj=0; jj<oscobyid[component_list[ii].classid]->
            vla_list_descr.i_count; jj++)
            fprintf(logfile,"         Element size: %-5d Offset from object: %d\n",
               vla_list[jj].elt_size,vla_list[jj].offset+off);

         chan_info = (struct sd_chan_info *) (oscobyid[component_list[ii].
            classid]->chan_info_descr.i_offset + (char *) &oscobyid
            [component_list[ii].classid]->chan_info_descr.i_offset);
         res_class = (char *) (oscobyid[component_list[ii].classid]->
            res_classname_descr.i_offset + (char *) &oscobyid
            [component_list[ii].classid]->res_classname_descr.i_offset);
         res_channum = (unsigned short *) (oscobyid[component_list[ii].
            classid]->res_channum_descr.i_offset + (char *) &oscobyid
            [component_list[ii].classid]->res_channum_descr.i_offset);
         fprintf(logfile,"       Number of channels: %d\n",oscobyid
            [component_list[ii].classid]->chan_info_descr.i_count);

         kk = ll = 0;
         for (jj=0; jj<oscobyid[component_list[ii].classid]->
              chan_info_descr.i_count; jj++) {
            fprintf(logfile,"         Offset: %d  Type:",
                    chan_info[jj].offset+off);
            typ = chan_info[jj].type;
            if (typ & CD_1_1) fprintf(logfile," 1_1");
            if (typ & CD_1_m) fprintf(logfile," 1_m");
            if (typ & CD_m_1) fprintf(logfile," m_1");
            if (typ & CD_m_m) fprintf(logfile," m_m");
            if (typ & CD_absordered) fprintf(logfile," absordered");
            if (typ & CD_relordered) fprintf(logfile," relordered");
            if (typ & CD_restricted) {
               fprintf(logfile," restricted to ");
               len = strlen(&res_class[kk]);
               fprintf(logfile,"(%s,%d)",&res_class[kk],res_channum[ll]);
               kk += (len + 1);
               ++ll;
            }
            fprintf(logfile,"\n");
         }
      }
   }
}

void display_class_info()          /* c option */
{
   unsigned int   ii;
   unsigned short jj;
   char           c[80];

   while (1)
   {
      fprintf(stdout, "\nClass-display> ");
      scanf("%s", c);
      if (logfile)
         fprintf(logfile, "\nClass-display> %c\n", c[0]);

      switch(c[0])
      {
         case 'a':
            for (ii = 0; ii<osco_count; ii++)
               display_osco((struct OMOSCO_instance *)
                  sort_classname[ii].p_sort_struct);
            break;
         case 'A':
            for (jj = 0; jj<=high_classid; jj++)
               if (oscobyid[jj])
                  display_osco(oscobyid[jj]);
            break;
         case 'd':
            for (ii = osco_count-1; ii!=0xffffffff; ii--)
               display_osco((struct OMOSCO_instance *)
                  sort_classname[ii].p_sort_struct);
            break;
         case 'D':
            for (jj = high_classid; jj!=0xffff; jj--)
               display_osco(oscobyid[jj]);
            break;
         case 'n':
            classname_dir(sort_classname);
            break;
         case 'u':
            fprintf(stdout, "Shell command> ");
            scanf("%[^\n]", buffer);
            if (logfile)
               fprintf(logfile, "Shell command> %s\n", buffer);
            system(buffer);
            break;
         case 'c':	
            fprintf(stdout, "Enter classid> ");
            scanf("%d", &ii);
            if (logfile)
               fprintf(logfile, "Enter classid> %d\n", ii);
            jj = (unsigned short) ii;
            if (jj <= high_classid && oscobyid[jj])
               display_osco(oscobyid[jj]);
            else
            {
               fprintf(stdout, "Classid %d not found.\n", jj);
               if (logfile)
                  fprintf(logfile, "Classid %d not found.\n", jj);
            }
            break;
         case 'q': 
            return;
         default:
            fprintf(stdout, "\n===== Options are =====\n");
            fprintf(stdout, "q - to quit.\n");
            fprintf(stdout, "a - all classes sorted ascendingly by name.\n");
            fprintf(stdout, "A - all classes sorted ascendingly classid).\n");
            fprintf(stdout, "d - all classes sorted descendingly by name.\n");
            fprintf(stdout, "D - all classes sorted descendingly by classid).\n");
            fprintf(stdout, "c - specific class description by classid.\n");
            fprintf(stdout, "n - get specific subsets of classnames ");
            fprintf(stdout, "using '*' and '?' metacharacters.\n");
            fprintf(stdout, "    Default display is name only. Use '-l' after");
            fprintf(stdout, " name to display statistics of\n");
            fprintf(stdout, "    the classes. Use -C to display in columns.\n");
            fprintf(stdout, "u - get and execute a shell command.\n");
            break;
      }        /* end of switch */
   }        /* end of while loop */
}


/*===============================================================*/
/* Use like ls command to display classnames. Display in columns */
/* or not, use the metacharacters '*' and '?'                    */
/* The osco list passed into here is already sorted by classname */
/*===============================================================*/

int classname_dir(osco_list)
struct sort_element *osco_list;
{
   char     command_buffer[64], option_buffer[25];
   unsigned int oo;
   int      ii, jj, l_option, s_option, C_option, num_returned;
   char     **search_list, **return_list;

   search_list = (char **) om$malloc(size=sizeof(struct sort_element) *
      osco_count);
   if (!search_list)
   {
      fprintf(stdout, "Could not allocate %d bytes.\n",
      sizeof(struct sort_element) * osco_count);
      return(0);
   }
   return_list = (char **) om$malloc(size=sizeof(struct sort_element) *
      osco_count);
   if (!return_list)
   {
      fprintf(stdout, "Could not allocate %d bytes.\n",
         sizeof(struct sort_element) * osco_count);
      return(0);
   }

   /*initialize the strings to be searched */
   for(oo=0; oo<osco_count; oo++)
      search_list[oo] = osco_list[oo].sort_string;

   while(1)
   {
      fprintf(stdout, "classes (-q to quit, -h for help)>");
      scanf("%s%[^\n]",command_buffer,option_buffer);

      if (logfile)
      {
         fprintf(logfile, "classes (-q to quit, -h for help)>");
         fprintf(logfile, "%s %s\n", command_buffer, option_buffer);
      }
      if (!strcmp("-q",command_buffer)) break;
      if (!strcmp("-h",command_buffer)) 
      {
         fprintf(stdout, "\n Use metacharacters and options as with the UNIX 'ls' command.\n");
         fprintf(stdout, " Use * by itself for all classes, '*' means 0 or more characters,\n");
         fprintf(stdout, " '?' means any single character.  \n");
         fprintf(stdout, " Default display is name only. Use '-l' after");
         fprintf(stdout, " name to display statistics of\n");
         fprintf(stdout, " the classes. Use -C to display in columns.\n");
         fprintf(stdout, " Use -s to display # of objects in the class(es).");
         fprintf(stdout, " Examples:\n\n");
         fprintf(stdout, "   classes (-q to quit, -h for help)>* -l\n");
         fprintf(stdout, "   (would display statistics of all classes in the object space.)\n");
         fprintf(stdout, "\n   classes (-q to quit, -h for help)>*command*\n");
         fprintf(stdout, "   (would display all classes with the embedded word 'command')\n");
         fprintf(stdout, "\n   classes (-q to quit, -h for help)>??grafix\n");
         fprintf(stdout, "   (would display all classes whose names are 8 characters long\n");
         fprintf(stdout, "   and which end with 'grafix')\n\n");
         continue;
      }

#ifdef DEBUG
fprintf(stdout, "Command buffer = \"%s\"\n",command_buffer);
fprintf(stdout, "Option buffer = \"%s\"\n",option_buffer);	
#endif

      ii = strlen(option_buffer);

      /* see if any options were specified */
      for(jj=ii, s_option=l_option=C_option=0; jj>=0; jj--)
      {
         if(!strcmp(&option_buffer[jj],"-l") || 
            !strcmp(&option_buffer[jj],"- l"))
         {
            l_option = 1;
            option_buffer[jj] = '\0';
         }
         if(!strcmp(&option_buffer[jj],"-s") || 
            !strcmp(&option_buffer[jj],"- s"))
         {
            s_option = 1;
            option_buffer[jj] = '\0';
         }
         if(!strcmp(&option_buffer[jj],"-C") || 
            !strcmp(&option_buffer[jj],"- C"))
         {
            C_option = 1;
            option_buffer[jj] = '\0';
         }
      }

#ifdef DEBUG
fprintf(stdout, "s_option = %d l_option = %d; C_option = %d\n",
	s_option,l_option,C_option);
#endif

      /* now get the names desired */

#ifdef DEBUG
fprintf(stdout, "sending in:\n");
for(oo=0; oo<osco_count; oo++)
{
   fprintf(stdout, "%16s\n",search_list[oo]);
}
#endif

      wild_card(search_list, osco_count, command_buffer, return_list,
         &num_returned);

      fprintf(stdout, "\nFound %d (of %d) matches to pattern \"%s\"\n",
         num_returned,osco_count, command_buffer);
      if (logfile)
         fprintf(logfile, "\nFound %d (of %d) matches to pattern \"%s\"\n",
            num_returned,osco_count, command_buffer);

      if(l_option)
      {

#ifdef DEBUG
fprintf(stdout, "processing '-l' option \n");
#endif

         for(ii=0; ii<num_returned; ii++)
         {
            display_osco(oscobyid[getOSCObyClassName(return_list[ii])]);
         }
      }
      else if (C_option)
      {

#ifdef DEBUG
fprintf(stdout, "processing '-C' option \n");
#endif

         for(ii=0; ii<num_returned; ii++)
         {
            fprintf(stdout, "%16s",return_list[ii]);
            if (logfile) fprintf(logfile, "%16s",return_list[ii]);
            if (!(ii+1)%5)
            {
               fprintf(stdout, "\n");
               if (logfile) fprintf(logfile, "\n");
            }
         }
         fprintf(stdout, "\n\n");	
         if (logfile) fprintf(logfile,"\n\n");	
      }
      else /* default display. names in one column */
         for(ii=0; ii<num_returned; ii++)
         {
            for(jj=ii;strcmp(osco_list[jj].sort_string,return_list[ii]);jj++);
               if (logfile)
               {
                  fprintf(logfile, "%s ",osco_list[jj].sort_string);
                  if (s_option)
                     fprintf(logfile, " Objects: %d\n", ((struct OMOSCO_instance *)
                     osco_list[jj].p_sort_struct)->OSCO.i_refcnt);
                  else fprintf(logfile,"\n");
               }

            fprintf(stdout, "%s ",osco_list[jj].sort_string);
            if (s_option)
               fprintf(stdout, " Objects: %d\n", ((struct OMOSCO_instance *)
                  osco_list[jj].p_sort_struct)->OSCO.i_refcnt);
            else fprintf(stdout, "\n");
         }
   }        /* end of do forever */
   return(1);
}


int getOSCObyClassName(className)
char  *className;
{
   int   ii, sts, start, end;

   start = 0;
   end = osco_count - 1;
   ii = end / 2;
   while (ii >= start && ii <= end)
   {
      if (!(sts = strcmp(sort_classname[ii].sort_string, className)))
         return((int) ((struct OMOSCO_instance *) sort_classname[ii].
            p_sort_struct)->OSCO.w_classid);
      if (sts < 0)
         start = ii + 1;      /* Never search lower than this index */
      else
         end = ii - 1;
      if (end == start)
         ii = start;
      else
         ii = start + ((end - start) / 2);
   }
   return(-1);
}

count_iso(p_iso)
struct OMISO_instance   *p_iso;
{
   OMuint   ii, oid;
   OMuword  classid;
   struct ISO_data   *iso_data;

   /* Sum the classes of objects which have iso links for a particular iso */

   iso_data = (struct ISO_data *) ((char *) &p_iso->iso_d_descr.i_offset +
      p_iso->iso_d_descr.i_offset);
   if (!iso_summary)
   {
      if (!(iso_summary = (unsigned int *) om$calloc(num=high_classid + 1,
         size=4)))
      {
         fprintf(stdout, "Could not allocate %d bytes for ISO structure.\n",
            (high_classid + 1) * 4);
         return(0);
      }
   }
   for (ii=p_iso->i_first; ii<p_iso->iso_d_descr.i_count; ii++)
   {
      if ((iso_data[ii].w_flags & ISO_to_object) &&
         !(iso_data[ii].w_flags & ISO_disconnected))
      {
         /* Get the classname and classid of this oid. */

         if ((oid = iso_data[ii].iso_u.s_objid) > highOid ||
             !(objTable[oid].fp))
            fprintf(stdout, "\nObject id %d is not valid.\n", oid);
         else if (((classid = objTable[oid].classid) > high_classid) ||
                  !oscobyid[classid])
            fprintf(stdout, "\nObject id %d has an invalid class id %d.\n",
               oid, classid);
         else
         {
            if (oscobyid[classid]->OSCO.w_classid)
            {
               /* we found this oid's osco */
               iso_summary[classid]++;
               break;
            }
         }
      }
   }
   return(1);
}


/*******************************************************************/
void hexdump(byte_rev)
int byte_rev;
/* dump parts of the file in hex with printable ascii out to the side.
/* if byte_rev is true, display byte  reversed hex and ascii.
/* ask for a starting byte and a number of bytes (20 minimum, one page 
/* default). if more than 400, stop after each page and wait to 
/* display more.
*/
{
 int i,k,strt,length;
 char cmd[20],bad_cmd;
 /* declaring this buffer 'unsigned' will allow us to display
 /* hex characters 80-FF 
 */
 unsigned char output_buffer[21];

 length = 0;
 strt = -1;
 do
   {
   fprintf(stdout, "Starting byte/number of bytes (dec):");
   scanf("%d/%d",&strt,&length);
   if (logfile)
     {
     fprintf(logfile, "Starting byte/number of bytes (dec):");
     fprintf(logfile, "%d/%d\n", strt, length);
     }
   } while ( strt < 0 );

 /* if length is 0, set to a 20 line page..*/
 if (length <= 0) length = 20*20;

 /* get the number of lines to display (minimum 1) */
 length = (length + 19) / 20;

 /* print hex stuff until the user wants to quit. */
 do
   {
   for (i=0; i<length; i++)  /* for number of 20 character lines*/
     {
     int amount_read;

     /* get a line (20 bytes) from the file */
     fseek(osfp,strt+i*20,0);
     if ((amount_read=fread (output_buffer,1,20,osfp)) != 20) 
       {
       int ii=amount_read,jj;

       if (ii)
	 {
	 for (jj=ii; jj < 20; jj++)
	   output_buffer[jj] = ' ';
 	 fprintf(stdout, "%5d: ",strt+i*20);
 	 if (logfile) fprintf(logfile, "%5d: ",strt+i*20);
         for (k=0; k<20; k++)
           {
	   if (logfile)
	     {
             if (k < ii)
	       fprintf(logfile, "%2.2X",output_buffer[k]);
             else
               fprintf(logfile, "  ");
	     if (!((k+1)%4)) fprintf(logfile, " ");
	     }
	
           if (k < ii)
	     fprintf(stdout, "%2.2X",output_buffer[k]);
           else
             fprintf(stdout, "  ");
	   if (!((k+1)%4)) fprintf(stdout, " ");
	   }
	 fprintf(stdout, "| ");
	 fprintf(logfile, "| ");
	 for (k=0; k<ii; k++)
	   {
	   if (logfile)
	     {
	     if (isprint(output_buffer[k]))
               fprintf(logfile, "%c",output_buffer[k]);
	     else
	       fprintf(logfile, ".");
	     }
	
	   if (isprint(output_buffer[k]))
      	     fprintf(stdout, "%c",output_buffer[k]);
	   else
	     fprintf(stdout, ".");
	   }
         fprintf(stdout, "\n");
         if (logfile) fprintf(logfile, "\n");
         }
       else
         {
         fprintf(stdout, "** unable to read at position %d **\n",strt+i*20);
	 if (logfile) fprintf(logfile, "** unable to read at position %d **\n",strt+i*20);
	 }
       }
     else 
       {
       /* print the line in hex and in ascii. */
       /* first print the displacement */

       if (!byte_rev)
         {
 	 if ( strt < 10000)
	   fprintf(stdout, "%5d: ",strt+i*20);
 	 else     fprintf(stdout, "%10d: ",strt+i*20);

         if (logfile)
           {
     	   if ( strt < 10000)
	     fprintf(logfile, "%5d: ",strt+i*20);
 	   else
             fprintf(logfile, "%10d: ",strt+i*20);
           }

 	 /*
 	 /* now the buffer in hex, 8 hex characters at a time
	 /* for 5 blocks of characters 
	 */
	
	 for (k=0; k<20; k++)
	   {
	   fprintf(stdout, "%2.2X",output_buffer[k]);
	   if (!((k+1)%4)) fprintf(stdout, " ");
	
           if (logfile)
             {
	     fprintf(logfile, "%2.2X",output_buffer[k]);
	     if (!((k+1)%4)) fprintf(logfile, " ");
	     }
	   }

 	 fprintf(stdout, "| ");	/* fence to separate hex and ascii*/
 	 if (logfile) fprintf(logfile, "| ");	/* fence to separate hex and ascii*/

 	 /*
	 /* now in ascii. non-printable characters are indicated
	 /* by '.'
	 */

 	 for (k=0; k<20; k++)
           {
	   if (logfile)
	     {
	     if (isprint(output_buffer[k]))
	       fprintf(logfile, "%c",output_buffer[k]);
	     else 
	       fprintf(logfile, ".");	
	     }
	   if (isprint(output_buffer[k]))
	     fprintf(stdout, "%c",output_buffer[k]);
	   else 
	     fprintf(stdout, ".");	
           }
	 fprintf(stdout, "\n"); 
	 if (logfile) fprintf(logfile, "\n"); 
         } 	/* end of if not byte reversed .. */
       else	/* display byte reversed .. */
	 {
 	 /*
	 /* now the buffer in hex, 8 hex characters at a time
	 /* for 5 blocks of characters 
	 */
	
         for (k=19; k>=0; k--)
	   {
	   if (logfile)
	     {
  	     fprintf(logfile, "%2.2X",output_buffer[k]);
	     if (!((k)%4)) fprintf(logfile, " ");
	     }
	
	   fprintf(stdout, "%2.2X",output_buffer[k]);
	   if (!((k)%4)) fprintf(stdout, " ");
	   }

         if ( strt < 10000)
 	   fprintf(stdout, "<-%5d ",strt+i*20);
         else
           fprintf(stdout, "<%10d",strt+i*20);

         fprintf(stdout, "| ");	/* fence to separate hex and ascii*/

         if (logfile)
           {
           if ( strt < 10000)
 	     fprintf(logfile, "<-%5d ",strt+i*20);
           else
             fprintf(logfile, "<%10d",strt+i*20);

           fprintf(logfile, "| ");	/* fence to separate hex and ascii*/
           }

         /*
         /* now in ascii. non-printable characters are indicated
         /* by '.'
         */

         for (k=19; k>=0; k--)
           {
	   if (logfile)
	     {
             if (isprint(output_buffer[k]))
	       fprintf(logfile, "%c",output_buffer[k]);
             else fprintf(logfile, ".");	
             }

           if (isprint(output_buffer[k]))
	     fprintf(stdout, "%c",output_buffer[k]);
           else fprintf(stdout, ".");	
	   }
         fprintf(stdout, "\n"); 
         if (logfile) fprintf(logfile, "\n"); 
         }       /* end of display byte reversed		*/
       }       /* end of else we read ok, display. . 	*/
     }		/* end of do for the number of lines 	*/

   /* now get a command from the user.*/
   /* we go backward and forward through the file by re-adjusting
   /* the starting point. we might also toggle the value of byte_rev.
   */

   bad_cmd = 1;
   do
     {
     fprintf(stdout, ":");
     scanf(" %s",cmd);
     if (logfile)
       {
       fprintf(logfile, ":");
       fprintf(logfile, " %c\n", cmd[0]);
       }
     switch (cmd[0])
       {
       case 'q':
	    bad_cmd = 0;
	    break;
       case '-':  /* move back one byte */
	    bad_cmd = 0;
	    strt --;
	    break;
       case '+':  /* move up one byte */
	    bad_cmd = 0;
	    strt ++;
	    break;
       case 'f':
	    byte_rev = 0;
	    strt += length*20;
	    bad_cmd = 0;
	    length = 20;
	    break;
       case 'F':
	    byte_rev = 1;
	    strt += length*20;
	    bad_cmd = 0;
	    length = 20;
	    break;
       case 'b':
	    byte_rev = 0;
	    strt -= length*20;
	    if (strt < 0) strt = 0;
	    bad_cmd = 0;
	    length = 20;
	    break;
       case 'B':
	    byte_rev = 1;
	    strt -= length*20;
	    if (strt < 0) strt = 0;
            bad_cmd = 0;
	    length = 20;
	    break;
       case 't':
	    byte_rev = 0;
	    bad_cmd = 0;
	    break;
       case 'T':
	    byte_rev = 1;
	    bad_cmd = 0;
	    break;
       default:
	    fprintf(stdout, "\nq - quit\n");
	    fprintf(stdout, "f  page forward \n");
	    fprintf(stdout, "F  page forward (byte reversed) \n");
	    fprintf(stdout, "b  page backward \n");
	    fprintf(stdout, "B  page backward (byte reversed)\n");
	    fprintf(stdout, "- (minus) move back one byte\n");
	    fprintf(stdout, "+ (plus)  move forward one byte\n");
	    fprintf(stdout, "t  this screen \n");
	    fprintf(stdout, "T this screen (byte reversed)\n\n");
	    break;
       }	/* end of switch .. */
     }	while (bad_cmd);
   } while (cmd[0] != 'q');	/* end of do while the command isnt quit*/
	
 fprintf(stdout, "\n");	/* get to a new line */
 if (logfile)
   fprintf(logfile, "\n");	/* get to a new line */
}


#ifdef CLIX
static void free_ddp(p_class, num_comp)
DROS_p_CLASS  p_class;
int           num_comp;
{
   int i;

   for (i=0; i<num_comp; ++i)
      if (p_class[i].size) dros_parddp_free(&p_class[i]);
   om$dealloc(ptr = (char *) p_class);
}

examineInst()
{
   int                            ii, num_comp, sts, *p_comp_off;
   unsigned int                   oid;
   char                           *path, ddpfile[128];
   struct stat                    buf;
   DROS_p_CLASS                   p_class;
   struct OMOSCO_instance         *p_osco;
   struct component_list_struct   *component_list;

   fprintf(stdout, "Enter object id of object to examine: ");
   scanf("%d", &oid);
   if ((oid > highOid) || !objTable[oid].size) {
      fprintf(stdout, "*** Invalid object id ***\n");
      return (0);
   }
   if (logfile)
      fprintf(logfile, "Enter object id of object to examine: %d", oid);

   p_osco = oscobyid[objTable[oid].classid];
   component_list = (struct component_list_struct *) (p_osco->
      component_list_descr.i_offset +
      (char *) &p_osco->component_list_descr.i_offset);
   num_comp = p_osco->component_list_descr.i_count;

   if (!(p_class = (DROS_p_CLASS) om$calloc(num=num_comp,
      size=sizeof(DROS_S_CLASS))))
   {
      fprintf(stdout, "Could not allocate %d bytes for component array.\n",
        num_comp*sizeof(DROS_S_CLASS));
      return(0);
   }
   if (!(p_comp_off = (int *) om$malloc(size = num_comp * sizeof(int))))
   {
      fprintf(stdout, "Could not allocate %d bytes for comp_off array.\n",
        num_comp * sizeof(int));
      return(0);
   }

   /* get path for ddp files */

   if (ddpPath[0])
      path = &ddpPath[0];
   else
      path = (char *) getenv("DROSDDPDIR");

   /* parse the class structure for each component */

   for (ii=0; ii<num_comp; ++ii) {
      p_osco = oscobyid[component_list[ii].classid];
      p_comp_off[ii] = component_list[ii].offset;

      if (!path)
         sprintf(ddpfile, "%s.", p_osco->OSCO.s_name);
      else
         sprintf(ddpfile, "%s/%s.", path,p_osco->OSCO.s_name);

      /* make sure ddp file exists */
   
      if (-1 == stat(ddpfile, &buf)) {
         fprintf(stdout, "*** Could not find ddp file %s ***\n", ddpfile);
         free_ddp(p_class, num_comp);
         om$dealloc(ptr = (char *) p_comp_off);
         return(0);
      }
      strcpy(p_class[ii].class, p_osco->OSCO.s_name);
      sts = dros_parddp(ddpfile, &p_class[ii], ii);
   }

#ifdef DEBUG
   for (ii=0; ii<num_comp; ++ii) dros_dmpddp (p_class+ii);
#endif

   init_inst_form ( p_class, num_comp, p_comp_off, oid );
   free_ddp(p_class, num_comp);
   om$dealloc(ptr = (char *) p_comp_off);
   return(1);
}
#endif


void zeroReport()
{
   OMuint   beginfp, endfp;
   int      threshold, area, zeroes;
   char     checksumflag;

   beginfp = firstObjfp;
   endfp = os_size;
   threshold = 8192;

   fprintf(stdout, "By default, this option will scan the file from the location\n");
   fprintf(stdout, "of the first object (%d) through the end of the file (%d)\n",
      firstObjfp, os_size);
   fprintf(stdout, "and report any contiguous areas of zero data larger than 8192 bytes.\n");

   fprintf(stdout, "\nStarting file location [%d]: ", beginfp);
   fflush(stdin);
   gets(buffer);
   if (buffer[0])
   {
      beginfp = (unsigned int) atoi(buffer);
      if (beginfp >= os_size)
         beginfp = firstObjfp;
      if (os_size < beginfp)
         beginfp = os_size;
   }
   fprintf(stdout, "Ending file location [%d]: ", endfp);
   fflush(stdin);
   gets(buffer);
   if (buffer[0])
   {
      if (endfp > os_size)
         endfp = os_size;
   }
   if (endfp < beginfp)
      endfp = beginfp;
   fprintf(stdout, "Threshold [8192]: ");
   fflush(stdin);
   gets(buffer);
   if (buffer[0])
      threshold = atoi(buffer);
   if (!(area = endfp - beginfp))
      area = 1;
   fprintf(stdout, "\nScanning from %d through %d (%d bytes) for areas of\nat least %d zeroes.\n",
      beginfp, endfp, area, threshold);
   if (logfile)
      fprintf(logfile, "Scanning from %d through %d (%d bytes) for areas of at least %d zeroes.\n",
         beginfp, endfp, area, threshold);
   checksumflag = 0;
   zeroes = detectHoles(beginfp, endfp, threshold, &checksumflag);
   fprintf(stdout, "\n%d percent of the area scanned (%d bytes) is zero data.\nFile size is %d.\n",
      (zeroes * 100) / area, area, os_size);
   if (logfile)
      fprintf(logfile, "\n%d percent of the area scanned (%d bytes) is zero data.\nFile size is %d.\n",
      (zeroes * 100) / area, area, os_size);
}


void om_validation()
{
   int choice = 9;

   while(1)
   {
      printf("\n		Validation Menu\n\n");
      printf("	1. Header Validation\n");
      printf("	2. Miscellaneous Validation\n");
      printf("	9. Exit validation menu\n\n");
      printf("	   Enter your choice ->  ");
      scanf("%d", &choice);
   
      switch(choice)
      {
         case    1 : validate_header();
                        break;

         case    2 : validate_misc();
                        break;

         case    9 : return;
 
         default   : printf("Incorrect choice.\n");
      }
   }
   
}


void validate_header()
{
   int        choice = 9;
   static int err_logo = 0;

   if (!err_logo)
   {
      err_logo = 1;
      fprintf(errfp, "\n\nFile header validation\n----------------------\n\n");
   }

   while (1)
   {
      printf("\n             Header Validation\n\n");
      printf("     1. Restore checksums\n");
      printf("     2. Modify application version stamps\n");
      printf("     3. Put back OM magic\n");
      printf("     9. Exit this menu\n\n");
      printf("        Enter your choice ->  ");
      scanf("%d", &choice);

      switch(choice)
      {
         case    1 : restore_checksums(); 
                     break;

         case    2 : modify_appver_stamps();
                     break;

	 case    3 : putback_om_magic();  
                     break;

         case    9 : return;

         default   : printf("Incorrect choice.\n");
      }
   }
}


void validate_misc()
{
   int choice = 9;

   while (1)
   {
      printf("\n		Miscellaneous validation\n\n");
      printf("1.	\n");
      printf("2.	Exit this menu\n");
      scanf("%d", &choice);

      switch(choice)
      {
         default : printf("Sorry. Yet to be implemented.\n");
                   return;
      }
   }
}


void restore_checksums()
{
   unsigned int  main_checksum = 0, hdr_checksum = 0;
   unsigned long fp_remember;
#ifdef BIG_ENDIAN
   int                           tempint;
#endif
   static char    err_logo = 0;

   fp_remember = ftell(osfp);
   printf("Calculating file checksum ...\n");
   main_checksum = calculate_main_checksum();
   if (!main_checksum)
   {
      printf("File checksum calculation failed\n");
      fseek(osfp, fp_remember, 0);
      return;
   }
   fseek(osfp, 12, 0);
   printf("Correcting file checksum with %x\n", main_checksum);
#ifdef BIG_ENDIAN
         swapint(&main_checksum, &tempint);
         main_checksum = tempint;
#endif
   if (fwrite(&main_checksum, 4, 1, osfp) != 1)
   {
      printf("Error writing file checksum\n");
      fseek(osfp, fp_remember, 0);
      return;
   }

   printf("Calculating header chekcum ...\n");
   hdr_checksum = calculate_header_checksum();
   fseek(osfp, 508, 0);
   printf("Correcting header checksum with %x\n", hdr_checksum);
#ifdef BIG_ENDIAN
         swapint(&hdr_checksum, &tempint);
         hdr_checksum = tempint;
#endif
   if (fwrite(&hdr_checksum, 4, 1, osfp) != 1)
   {
      printf("Error writing header checksum\n");
      fseek(osfp, fp_remember, 0);
      return;
   }
   fseek(osfp, fp_remember, 0);

   if (!err_logo)
   {
      fprintf(errfp, "\nRestored cheksums.\n\n");
      err_logo = 1;
   }
}


void modify_appver_stamps()
{
   unsigned int                ii, choice = 0;
   char                        apver[32], ch;
   struct OM_sd_OS_filehdr_OM  my_filehdr;
   unsigned long               remember_fp;
   static   char               err_logo = 0;

   remember_fp = ftell(osfp);
   fseek(osfp, 0, 0);
   if (OMFILEHDRSIZE != fread(&my_filehdr, 1, OMFILEHDRSIZE, osfp))
   {
      printf("Read error while reading file header.\n");
      fseek(osfp, remember_fp, 0);
      return;
   }
   fseek(osfp, my_filehdr.fp_appver, 0);
   printf("The following are the application version stamps ...\n");
   for(ii=0; ii<my_filehdr.i_num_appver; ii++)
   {
      if (32 != (fread (apver, 1, 32, osfp)))
      {
         printf("Error reading application stamps\n");
         fseek(osfp, remember_fp, 0);
         return;
      }
      printf("%2d. %s\n", ii, apver);
   }
   printf("Key in your choice to modify ->  ");
   scanf("%d", &choice);
   memset(apver, 0, 32);
   printf("Key in the new value ->  ");
   scanf("%s", apver);
   printf("Are you sure to modify (y/n) ?");
   fflush(stdin);
   scanf("%c", &ch);
   if ( (ch != 'y') && (ch != 'Y') )
   {
      printf("Retaining old application version stamps\n");
      return;
   }

   fseek(osfp, my_filehdr.fp_appver + choice*32, 0);
   if ( fwrite(apver, 1, 32, osfp) != 32)
      printf("Error modifying app ver stamps.\n");
   else
      printf("Modified app ver stamp with %s\n", apver);
   
   fseek(osfp, remember_fp, 0);

   if (!err_logo)
   {
      fprintf(errfp, "\nModified application version stamps.\n\n");
      err_logo = 1;
   }
}


void putback_om_magic()
{
   char          ch, om_magic[2];
   unsigned long remember_fp;
   static   char err_logo = 0;

   printf("Sure to restore file magic with OM (y/n) ? ");
   fflush(stdin);
   scanf("%c", &ch);
   if ( (ch != 'y') && (ch != 'Y') )
   {
      printf("Retaining the old file magic\n");
      return;
   }
   remember_fp = ftell(osfp);

   fseek(osfp, 0, 0);
   om_magic[0] = 'O';
   om_magic[1] = 'M';
   if (fwrite(&om_magic, 1, 2, osfp) != 2)
      printf("Error writing OM magic\n");
   else
      printf("Replacing file magic with OM\n");
   
   fseek(osfp, remember_fp, 0);

   if (!err_logo)
   {
      fprintf(errfp, "\nPut back OM file magic.\n\n");
      err_logo = 1;
   }
}

void printOptions()
{
   char  command[80];

   while (1)
   {
      fprintf(stdout, "\n[Dr.OS] ");
      command[0] = 'q';
      scanf("%s",command);
      if (logfile)
         fprintf(logfile, "[Dr.OS] %c\n", command[0]);
      switch (command[0])
      {
         case 'a':
            appDisp();  /* Application version stamps */
            break;
         case 'c':
            display_class_info();   /* Class sub-menu */
            break;
         case 'C':
            CDisp();    /* Cluster stats for all clusters */
            break;
         case 'D':
            deposit();  /* Deposit hex values a byte at a time */
            break;
#ifdef CLIX
         case 'e':
            examineInst(); /* Show an object in a form */
            break;
#endif
         case 'f':
            fDisp();    /* Clusters stats */
            break;
         case 'g':
            gDisp();    /* General - cluster lay-out in file */
            break;
         case 'G':
            GDisp();    /* Group objects */
            break;
         case 'h':
            display_header();
            break;	
         case 'i':
            iDisp();    /* ISO's */
            break;
         case 'I':
            IDisp();    /* More ISO's */
            break;
         case 'l':	/* end log output */
            if (logfile)
               fclose(logfile);
            break;
         case 'L':	/* log output */
            createLog();
            break;
         case 'N':
            printOSname();    /* Print internal OS name */
            break;
         case 'o':
            oDisp();    /* Object stats by obj id */
            break;
         case 'O':
            dump_object(); /* Step through objects in file, dump in hex */
            break;
         case 'q':
            fprintf(stdout, "\nbye...\n");
            if (logfile)
               fprintf(logfile, "\nbye...\n");
            drosAbort();
            break;
         case 'r':
            rDisp();    /* Rtree display (same as old DrRtree output) */
            break;
         case 'R':
            RDisp();    /* Show OMTagCon attachments */
            break;
         case 'T':
            if (tag)       /* If tag problem detected, fix it in file */
            {
               if (mode & READONLY)
               {
                  fprintf(stdout, "Cannot repair file without write access to it.\n");
                  break;
               }
               tagRepair();
            }
            else
               fprintf(stdout, "There is no tag object in this object space.\n");
            break;
         case 'u':
            fprintf(stdout, "Shell command>");
            scanf(" %[^\n]", buffer);
            if (logfile)
               fprintf(logfile, "Shell command> %s\n", buffer);
            system(buffer);
            break;
	 case 'v':
	    om_validation();
            break;
         case 'x':
            hexdump(0);    /* Dump beginning at any file location */
            break;    
         case 'X':
            hexdump(1);
            break;
         case 'z':
            zeroReport();  /* Find areas of zero data */
            break;
         default:
            fprintf(stdout, " valid commands are :\n");
            fprintf(stdout, " q - Quit\n h - Display os header.\n");
            fprintf(stdout, " a - Display application version stamps\n");
            fprintf(stdout, " c - Display class info\n");
            fprintf(stdout, " C - Display cluster statistics.\n");
            fprintf(stdout, " D - Deposit a byte into the file.\n");
#ifdef CLIX
            fprintf(stdout, " e - Examine object instance data.\n");
#endif
            fprintf(stdout, " f - Show object/classid/size/file pointer by cluster.\n");
            fprintf(stdout, " g - Display general information.\n");
            fprintf(stdout, " G - Display Group statistics.\n");
            fprintf(stdout, " i - Display ISO information.\n");
            fprintf(stdout, " I - Display summary ISO information.\n");
            fprintf(stdout, " l - Close the current logfile.\n");
            fprintf(stdout, " L - Open a logfile. Subsequent output goes to the file.\n");
            fprintf(stdout, "     as well as the standard output.\n");
            fprintf(stdout, " N - Display internal object space name\n");
            fprintf(stdout, " o - Show object/classid/size/file pointer by object\n");
            fprintf(stdout, " O - Dump object in hex and ascii.\n");
            fprintf(stdout, " r - Display GRrtree info.\n");
            fprintf(stdout, " R - Display TagCon attachments\n");
            fprintf(stdout, " T - Repair tag record problems.\n");
            fprintf(stdout, " u - Get and execute a shell command.\n");
            fprintf(stdout, " v - Validation menu.\n"); 
            fprintf(stdout, " x - Hex dump of file data.\n");
            fprintf(stdout, " X - Byte-reversed hex dump.\n");
            fprintf(stdout, " z - Scan area of file for zero data.\n");
            break;
      }
   }
}


void printMinOptions()
{
   char  command[80];

   while (1)
   {
      fprintf(stdout, "\n[Dr.OS] ");
      command[0] = 'q';
      scanf("%s", command);
      if (logfile)
         fprintf(logfile, "\n[Dr.OS] %c\n", command[0]);
      switch (command[0])
      {
         case 'q':
            fprintf (stdout, "\nbye...\n");
            if (logfile)
               fprintf(logfile, "\nbye...\n");
            drosAbort();
            break;
         case 'a':
            appDisp();
            break;
         case 'L':	/* log output */
            createLog();
            break;
         case 'l':	/* end log output */
            if (logfile)
               fclose(logfile);
            break;
         case 'h':
            display_header();
            break;	
         case 'x':
            fprintf(stdout, "\n");
            if (logfile)
               fprintf(logfile, "\n");
            hexdump(0);
            break;    
         case 'X':
            hexdump(1);
            break;
         case 'u':
            fprintf(stdout, "Shell command>");
            scanf(" %[^\n]", buffer);
            if (logfile)
               fprintf(logfile, "Shell command> %s\n", buffer);
            system(buffer);
            break;
        case 'O':
            dump_object();
            break;
         case 'D':
            deposit();
            break;
         case 'z':
            zeroReport();
            break;
         default:
            fprintf(stdout, " valid commands are :\n");
            fprintf(stdout, " q - quit\n h - display os header\n");
            fprintf(stdout, " a - display application version stamps\n");
            fprintf(stdout, " D - deposit a byte into the file\n");
            fprintf(stdout, " L - open a logfile. Subsequent output goes to the file\n");
            fprintf(stdout, "     as well as the standard output.\n");
            fprintf(stdout, " l - Close the current logfile.\n");
            fprintf(stdout, " O - dump filed object in hex\n");
            fprintf(stdout, " x - display the file in hex\n");
            fprintf(stdout, " X - display the file in hex(byte reversed)\n");
            fprintf(stdout, " u - get and execute a shell command\n");
            fprintf(stdout, " z - scan file for zero data\n");
            break;
      }
   }
}

void sigCatch(sig)
int   sig;
{
#ifdef SYSV
   sigrelse(sig);
#endif
   signal(sig, (void (*)(int))sigCatch);
   if (mode & MINIMUM)
      printMinOptions();
   else
      printOptions();
}


/*************
 *           *
 *  M A I N  *
 *           *
 *************/

main(argc, argv, envr)
int   argc;
char  *argv[], **envr;
{
   /*=================================================================*/
   /* Initial setup.  Get runtime parameters, open files, set up user */
   /* interface.  drosInit fills in os_size, firstObjPtr, and sets    */
   /* OM13 and MINIMUM when applicable.  Also fills in filehdr.       */
   /*=================================================================*/
   mode = OSflags = errcnt = 0;
   verbose = 0;
   parseCommandLine(argc, argv, envr);
   drosInit();    /* Validates filehdr, om structures */

   if (!(mode & MINIMUM)) /* May have been set in drosInit or by command line */
   {
      /* File has been validated - User gets to use full-blown Dr.OS */
      signal(SIGINT, (void (*)(int)) sigCatch);
      printOptions();
   }
   else
   {
      /* Allow only minimal editting and OM validation */
      fprintf(stdout, "\nFile not valid or minimum mode selected.\n");
      signal(SIGINT, (void (*)(int)) sigCatch);
      printMinOptions();
   }
   drosAbort();
   return(0);
}
