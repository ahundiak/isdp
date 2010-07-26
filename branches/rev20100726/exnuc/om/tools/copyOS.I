class 	implementation	OMFiledOS;

#include "exsysdep.h"
#include "OMmetaclass.h"
#include "OMmacros.h"
#include "version.h"
#include "OMOSfilehdr.h"
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <hash.h>

from OMISO       import unlink_all;

extern INGR_p_PRODUCT_DEF  OM_GA_appl_version[];
extern int                 OM_Gi_number_of_appl_ids;
extern char                EX_runname[];
extern OMuint              OM_Gf_fileLocking;

#ifdef BIG_ENDIAN
extern int                 som_load_dictionary();
extern int                 som_dload_conversion_functions();

char     proddataFile[MAXPATHLEN+1];
#endif

#define MAXFILENAMELEN 14

EX_error_box(vs, msg, title)
int   vs;
char  *msg, *title;
{
   if (vs)
      fprintf(stderr, "\n%s%s\n", msg, title);
   return(1);
}

/*
 *    Revision History
 *
 *    7/92     Change command line interface.  Used to allow only
 *             2 args, input file & output file (and optionally a
 *             3rd, -tc to remove tag connects, but wasn't published
 *             and no one ever used it), but are now allowing users
 *             to copy a group of interrelated input files to a group
 *             of output files, updating all Tag Connect entries in
 *             the output files to reflect new internal OS names.
 *             Change was necessary due to associativity in 2.0 MDEM.
 *
 *    6/93     Add support for long file names on systems other than
 *             Clix.  Also add -p option for specifying product_data
 *             file or location on BIG_ENDIAN systems.
 */

main (argc, argv)
int   argc;
char *argv[];
{
   int                           aa, i, j, sts, count, len, filecnt,
                                 tcFileCnt, argind;
   FILE                          *fp = NULL;
   OMuword                       os, tagcon_flag=0;
   OM_S_OBJID                    os_oid;
   HASHTABLE                     *htable = NULL;
   static char                   *params[]={"AUTORECLUSTER=0",
                                            "FILELOCKING=2", 0};
#ifdef BIG_ENDIAN
   char                          *pdata, *eol;
   struct stat                   statbuf;
#endif

#ifdef CLIX
   struct statl                  fbuf, fbuf2;
#else
   struct stat                   fbuf, fbuf2;
#endif

   char                          *ptr, *outfile, **argfiles,
                                 outputfilename[MAXPATHLEN+1],
                                 lockFile[MAXPATHLEN+1],
                                 buffer[MAXPATHLEN+1], multi=0;
   struct OM_sd_OS_filehdr_OM    filehdr;
#ifdef BIG_ENDIAN
   char                          usage[60]=
                "\nUsage: copyOS [-tc] [-p <product_data file>] file1 file2\n";
#else
   char                          usage[35]=
                                 "\nUsage: copyOS [-tc] file1 file2\n";
#endif

   struct tagconRec
   {
      OM_S_OBJID        oid;
      struct tagconRec  *next;
   } *rec, **prec;
   struct tagconFile
   {
      char              *oldfilename;
      char              *newfilename;
      char              oldOSname[OM_K_MAXINTOSNAME_LEN+1];
      char              newOSname[OM_K_MAXINTOSNAME_LEN+1];
      char              filechanged;
      struct tagconRec  *tcRec;  /* Linked list of TagCon objects in file */
   }  tcFile, *ptcFile, **files=NULL;

   if (argc < 3)
   {
      fprintf(stderr, "Bad argument%s\n", usage);
      exit(1);
   }
   if (!(argfiles = (char **) om$malloc(size = argc * sizeof(char *))))
   {
      fprintf(stderr, "Out of memory\n");
      exit(1);
   }
   argind = 1;
   filecnt = 0;
   while (argind < argc)
   {
      if (!strcmp(argv[argind], "-?") || !strcmp(argv[argind], "-h"))
      {
         fprintf(stderr, "%s", usage);
         exit(0);
      }
      if (!strcmp(argv[argind], "-tc"))
      {
         if (tagcon_flag)  /* Already specified */
         {
            fprintf(stderr, "Bad argument%s", usage);
            exit(0);
         }

         /* User (probably Ed) wants to remove tag connects */

         tagcon_flag = 1;
      }
      else if (!strcmp(argv[argind], "-m"))
      {
         if (multi)  /* Already specified */
         {
            fprintf(stderr, "Bad argument%s", usage);
            exit(1);
         }
         multi = 1;
      }
#ifdef BIG_ENDIAN
      else if ((argv[argind][0] == '-') && (argv[argind][1] == 'p'))
      {
         /* -p specifies full path of product_data file */

         if (argv[argind][2] == '\0')
            strncpy(proddataFile, argv[++argind], MAXPATHLEN);
         else
            strncpy(proddataFile, &argv[argind][2], MAXPATHLEN);
         proddataFile[MAXPATHLEN] = '\0';
      }
#endif
      else if (argv[argind][0] == '-')
      {
         fprintf(stderr, "Bad argument%s", usage);
         exit(1);
      }
      else
      {
         /* Assume this is a filename, either an input file or
          * an output file.  Make sure the length of the filename
          * does not exceed maximum allowed (currently 14 chars).
          */
         argfiles[filecnt++] = argv[argind];
         if (argv[argind][len = (strlen(argv[argind]) - 1)] == '/')
            argv[argind][len] = 0x00; /* If last char is '/', get rid of it */
         if (ptr = (char *) strrchr(argv[argind], '/'))
            ptr++;
         if (ptr && (strlen(ptr) > MAXFILENAMELEN))
         {
            fprintf(stderr, "copyOS::File name too long, %s\n", argv[argind]);
            exit(1);
         }
      }
      argind++;
   }
   if ((!multi && (filecnt > 2)) || (multi && filecnt && (filecnt % 2)))
   {
      fprintf(stderr, "Bad argument%s", usage);
      exit(1);
   }

   sts = om$runtime_init( paramc     = 2,
                          param_list = params );
   if (!(1&sts)) {
      fprintf(stderr, "copyOS::Error from om$runtime_init\n");
      om$report_error(sts=sts);
      exit(1);
   }

#ifdef BIG_ENDIAN
   {
      FILE  *pfp;
      char  *sep = " \t";
      char  *run_name, *logo, *module, *srch_path,
            *config_path, *prod_path;

      if (!proddataFile[0])
      {
         char  *ingrhome;

         if(ingrhome = (char *) getenv("INGRHOME"))
         {
            int nbytes = MAXPATHLEN - 14;  /* Leave room in buff for /product_data\0 */

            strncpy(proddataFile,ingrhome, nbytes);
            proddataFile[nbytes] = '\0';
            strcat(proddataFile,"/product_data");
         }
         else
            strcpy(&proddataFile[0], "/usr/ip32/product_data");  /* Default file name */
      }
      if (stat(proddataFile, &statbuf) == -1)
      {
         fprintf(stderr, "copyOS: Could not access %s.\n", proddataFile);
         perror("");
         exit(1);
      }
      if (!(pfp = (FILE *) fopen(proddataFile, "r")))
      {
         fprintf(stderr, "copyOS: could not open %s.\n", proddataFile);
         perror("");
         exit(1);
      }
      if (!(pdata = (char *) om$malloc(size = statbuf.st_size + 1)))
      {
         fprintf(stderr, "copyOS: could not allocate %d bytes for product info.\n",
            statbuf.st_size + 1);
         fclose(pfp);
         exit(1);
      }
      if (fread(pdata, 1, statbuf.st_size, pfp) != statbuf.st_size)
      {
         fprintf(stderr, "copyOS: could not read %s.\n", proddataFile);
         fclose(pfp);
         exit(1);
      }
      fclose(pfp);

   pdata[statbuf.st_size] = '\0';  /* To halt runaway strchr calls */

   for (ptr = pdata; eol = (char *) strchr (ptr, '\n'); ptr = eol + 1)
   {
      *eol = '\0';
      if (*ptr == '#')
         continue;

      buffer[0] = '\0';
      if (ptr = (char *) strchr (ptr, '"'))
      {
         run_name    = (char *) strtok (++ptr, "\"");
         logo        = (char *) strtok (0, sep);
         module      = (char *) strtok (0, sep);
         srch_path   = (char *) strtok (0, sep);
         config_path = (char *) strtok (0, sep);
         prod_path   = (char *) strtok (0, sep);

         if (!run_name || !config_path)
            continue;
         if (strcmp(run_name, "Exnuc"))
            continue;
         sprintf(buffer, "%s/config/class_defns", config_path);
         break;
      }
   }
   if (!buffer[0])
   {
      fprintf(stderr, "Could not find Exnuc entry in product_data file.\n");
      exit(0);
   }
   if (!(1&(sts = som_load_dictionary(buffer))))
      exit(sts);
   sprintf(buffer, "%s/config/dload/port", config_path);
   if (!(1&(sts = som_dload_conversion_functions(buffer))))
      exit(sts);
   om$dealloc(ptr = pdata);  /* Unverified copy of product_data file */
   }
#endif

   /* Loop through command line dealing with a pair of args at a time
    * (input file and output file).
    */

   tcFileCnt = 0;

   if (filecnt > 2)     /* If we're copying multiple files */
   {
      if (!(htable = (HASHTABLE *) hashinit(struct tagconFile,
         ((filecnt < 100) ? 125 : filecnt + ((filecnt * 125)/100)), hashc,
         strcmp, oldOSname[0], 0)))
      {
         fprintf(stderr, "copyOS: hashinit failed\n");
         exit(1);
      }
      if (!(files = (struct tagconFile **) om$calloc(size=4,
         num=filecnt+1)))
      {
         fprintf(stderr, "copyOS::Not enough memory to allocate tag connect info\n");
         exit(1);
      }
   }
   argind = 0;
   aa = 0;
   while ((argind + 1) < filecnt)
   {
      /*=============================*/
      /*  do not allow copy to self  */
      /*=============================*/

      if (!strcmp(argfiles[argind], argfiles[argind+1]))
      {
         fprintf(stderr, "copyOS:Not valid to copy to same file <%s>\n",
            argfiles[argind]);
         exit(1);
      }

      /*=============================*/
      /*  make sure old file exists  */
      /*=============================*/

      if (!(fp = (FILE *) fopen(argfiles[argind], "r")))
      {
         fprintf(stderr, "copyOS:Error opening old file %s\n",
            argfiles[argind]);
         exit(1);
      }
      fclose(fp);

      outfile = argfiles[argind+1];
      if (!(fp = (FILE *) fopen(argfiles[argind+1], "a"))) /* Writable? */
      {
         if (errno == EISDIR)    /* Second arg is a directory name */
         {
            if (!strchr(argfiles[argind], '/'))
               sprintf(outputfilename, "%s/%s", argfiles[argind+1],
                  argfiles[argind]);
            else
               sprintf(outputfilename, "%s%s",
                  argfiles[argind+1], strrchr(argfiles[argind], '/'));
            if (fp = (FILE *) fopen(outputfilename, "a"))  /* Can file be written? */
	    {
               outfile = outputfilename;
		fclose( fp );			/*  Get rid off the file  */
		unlink( outfile );		/*  as it is created down */
	    }
            else
            {
               perror("open failed");
               exit(1);
            }
         }
         else
         {
            perror("open failed");
            exit(1);
         }
      }
      else
      {					/* Get rid off the file as it  */
      	fclose(fp);			/* is created down the lane    */
      	unlink(argfiles[argind+1]);
      }

#ifdef CLIX
      if (statl(argfiles[argind], &fbuf) == -1)
#else
      if (stat(argfiles[argind], &fbuf) == -1)
#endif
      {
         perror("stat system call failed");
         exit(1);
      }
#ifdef CLIX
      if (statl(outfile, &fbuf2) == -1)
#else
      if (stat(outfile, &fbuf2) == -1)
#endif
      {
         if (errno != ENOENT)
         {
            perror("stat system call failed");
            exit(1);
         }
      }
      else if (fbuf.st_ino == fbuf2.st_ino)
      {
         fprintf(stderr, "copyOS::Not valid to copy to same file\n");
         exit(1);
      }

      /*==============*/
      /*  initialize  */
      /*==============*/

      strcpy(buffer, argfiles[argind]);
      if (ptr = (char *) strrchr(buffer, '/'))
      {
         ptr++;
         strncpy(lockFile, buffer, len = (int)(ptr-buffer));
         lockFile[len] = NULL;
      }
      else ptr = buffer;
      strcat(lockFile, "lock");
      if (!access(lockFile, 00))
         OM_Gf_fileLocking = 2;
      else
      {
         strcpy(buffer, outfile);
         if (ptr = (char *) strrchr(buffer, '/'))
         {
            ptr++;
            strncpy(lockFile, buffer, len = (int)(ptr-buffer));
            lockFile[len] = NULL;
         }
         else ptr = buffer;
         strcat(lockFile, "lock");
         if (!access(lockFile, 00))
            OM_Gf_fileLocking = 2;
         else
            OM_Gf_fileLocking = 0;
      }

      /*====================*/
      /*  construct the OS  */
      /*====================*/

      sts = om$construct_os ( classname = "OMFiledOS",
                              osnum     = &os,
                              osname    = argfiles[argind],
                              p_objid   = &os_oid,
                              loadmode  = OM_e_loados_ro );
      if (!(1&sts)) {
         fprintf(stderr, "copyOS::Error loading os from file %s\n", argfiles[argind]);
         om$report_error(sts=sts);
         exit(1);
      }

      if (!(fp = (FILE *) fopen(argfiles[argind], "r")))
      {
         fprintf(stderr, "copyOS::Error opening old file %s\n", argfiles[argind]);
         exit(1);
      }
      if (512 != fread(&filehdr, 1, 512, fp))
      {
         fprintf(stderr, "copyOS::Error reading object space header.\n");
         close(fp);
         exit(1);
      }

#ifdef BIG_ENDIAN
      som_swapint(&filehdr.fp_appver, &sts);
      filehdr.fp_appver = sts;
      som_swapint(&filehdr.i_num_appver, &sts);
      filehdr.i_num_appver = sts;
#endif

      if (filehdr.fp_appver && (-1 == (fseek(fp, filehdr.fp_appver, 0))))
      {
         fprintf(stderr, "copyOS::Error seeking to application version stamps.\n");
         close(fp);
         exit(1);
      }      
      for (i=OM_Gi_number_of_appl_ids=0; i<filehdr.i_num_appver; ++i)
      {
         if (!(OM_GA_appl_version[i] = (struct INGR_sd_product_def *)
            calloc(1, sizeof(struct INGR_sd_product_def))))
         {
            fprintf(stderr, "copyOS::Could not allocate memory for version stamps.\n");
            close(fp);
            exit(1);
         }
         if (!(OM_GA_appl_version[i]->curr_version = (char *) malloc(32)))
         {
            fprintf(stderr, "copyOS::Could not allocate memory for version stamps.\n");
            close(fp);
            exit(1);
         }
         if (32 != (fread (OM_GA_appl_version[i]->curr_version,
            1, 32, fp)))
            fprintf(stderr, "copyOS::Error reading application version stamp %d at %d.\n",
               i, ftell(fp));
         else
            OM_Gi_number_of_appl_ids++;
         OM_GA_appl_version[i]->version_check_func = NULL;
      }
      fclose(fp);

      {
         struct OMFiledOS_total_instance  *myME;
         struct OMObjSpace_instance       *myme;
         struct ISOd_data                 *p_isod;
         OM_p_CHANNEL_HDR                 p_chan;
         OM_p_CHANNEL_LINK                p_link;
         OM_S_BIG_TAIL                    tail;

         /*===================*/
         /*  delete all ISOs  */
         /*===================*/

         myME = (struct OMFiledOS_total_instance *)
                OM_GA_OSDs[os]->Spacemap[os_oid].state.object;

         myme = &(myME->OMObjSpace);

         i = myme->iso_d_descr.i_count;
         p_isod = (struct ISOd_data *)myme->iso_d_descr.i_offset;

         for (j=0; j<i; ++j) {
            if (p_isod[j].s_int_os_name[0]) {
               om$send ( msg      = message OMISO.unlink_all(),
                         senderid = os_oid,
                         targetid = p_isod[j].iso_u.s_objid,
                         targetos = os );
            }
         }

         tcFile.oldfilename = argfiles[argind];
         tcFile.newfilename = argfiles[argind+1];
         strcpy(tcFile.oldOSname, OM_GA_OSDs[2]->InternalName);
         tcFile.tcRec = NULL;
         tcFile.filechanged = 0;
         prec = &tcFile.tcRec;
         p_chan = myme->to_GrpDscs;
         if (p_chan)
         {
            if (p_chan->flags & OM_CH_tail_exists)
            {
               OM_GET_TAIL(p_chan,tail);
               count = tail.last_index;
            }
            else
               count = p_chan->u1.count;

            p_link = (OM_p_CHANNEL_LINK) ((OMuint) p_chan + 
               sizeof(OM_S_CHANNEL_HDR));
            for (i=0; i<count; ++i)
            {
               if (IF_NULL_OBJID(p_link[i].objid))
                  continue;
               if (p_link[i].channum.classid == OM_K_OMTAGCON_ACTCLASSID)
               {
                  if (tagcon_flag)  /* Delete tagcons */
                  {
                     sts = om$send ( msg = message Root.delete(0),
                                     senderid = os_oid,
                                     targetid = p_link[i].objid,
                                     targetos = os );
                  }
                  else
                  {
                     if (!(*prec = (struct tagconRec *)
                        om$malloc(size=sizeof(struct tagconRec))))
                     {
                        fprintf(stderr, "copyOS::Could not allocate memory for tag connects.\n");
                        exit(1);
                     }
                     (*prec)->oid = p_link[i].objid;
                     (*prec)->next = NULL;
                     prec = &((*prec)->next);
                     tcFileCnt++;
                  }
               }
            }
         }
      }

      /*=====================================*/
      /*  change the osname to the new name  */
      /*=====================================*/

      OM_GA_OSDs[os]->flags &= ~OM_e_loados_ro;
      if (!(1 & (sts = om$send (
                msg = message OMObjSpace.change_name(outfile,OM_e_overwrite_rrr),
                senderid = os_oid,
                targetid = os_oid,
                targetos = os ))))
      {
         om$report_error(sts=sts);
         exit(1);
      }
      if (filecnt > 2)
      {
         strcpy(tcFile.newOSname, OM_GA_OSDs[2]->InternalName);
         if (!(files[aa++] = (struct tagconFile *) hashadd(htable, &tcFile, 0)))
         {
            fprintf(stderr, "copyOS:: hashadd failed for %s\n",
               OM_GA_OSDs[2]->InternalName);
         }
      }

      /*=====================================*/
      /*  delete the os - forcing the write  */
      /*=====================================*/

      strcpy(EX_runname, filehdr.image_name);
      if (!(1 & (sts = om$send ( msg      = message OMFiledOS.delete(1),
                senderid = os_oid,
                targetid = os_oid,
                targetos = os ))))
      {
         om$report_error(sts=sts);
         exit(1);
      }
      argind += 2;      /* Point to input file of next input-output pair */
   }

   if ((filecnt > 2) && tcFileCnt)
   {
      /* We must update Tag Connect records in the new files we've
       * created to reflect a connection to the newly copied files'
       * internal OS names rather than the old OS names.
       */

      aa = 0;
      while (aa < filecnt)
      {
         if (ptcFile = files[aa])
         {
            struct tagconFile *table;
            struct objhdr
            {
               OMuint   oid;
               OMuint   i_size;
               OMuword  filler1;
               OMuword  filler2;
               char     oldOSname[OM_K_MAXINTOSNAME_LEN];
            } objHdr;

            if (rec = ptcFile->tcRec)
            {
               if ((fp = (FILE *) fopen(ptcFile->newfilename, "r+")) &&
                  fread(&filehdr, 1, 512, fp))
               {
                  while (rec)
                  {
#ifdef BIG_ENDIAN
                     som_swapint(&filehdr.fp_cluster0, &i);
                     i += 8;
                     som_swapint(&filehdr.i_size, &j);
#else
                     i = filehdr.fp_cluster0 + 8;
                     j = filehdr.i_size;
#endif

                     while (i < j)
                     {
                        fseek(fp, i, 0);
                        if (fread(&objHdr, 1, sizeof(struct objhdr), fp) !=
                           sizeof(struct objhdr))
                        {
                           fprintf(stderr, "copyOS::Could not write updated tag connect to file %s.\n",
                              ptcFile->newfilename);
                        }

#ifdef BIG_ENDIAN
                        som_swapint(&objHdr.oid, &sts);
                        objHdr.oid = sts;
                        som_swapint(&objHdr.i_size, &sts);
                        objHdr.i_size = sts;
#endif

                        if (objHdr.oid == rec->oid)
                           break;
                        i += (objHdr.i_size & 0xfffffff8) + 8;
                     }
                     if (table = hashlookup(htable, objHdr.oldOSname))
                     {
                        fseek(fp, 0-(OM_K_MAXINTOSNAME_LEN), 1);
                        if (fwrite(table->newOSname, 1,
                           OM_K_MAXINTOSNAME_LEN, fp) != OM_K_MAXINTOSNAME_LEN)
                        {
                           fprintf(stderr, "copyOS::Could not write updated tag connect to file %s.\n",
                              ptcFile->newfilename);
                        }
                        ptcFile->filechanged = 1;
                     }
                     rec = rec->next;
                  }
                  fclose(fp);
               }
               else
               {
                  fprintf(stderr, "copyOS::Could not open file %s to update tag connections.\n",
                     ptcFile->newfilename);
                  break;
               }
            }
         }
         aa++;
      }
      aa = 0;
      while (aa < filecnt)
      {
         if ((ptcFile = files[aa]) && ptcFile->filechanged)
         {
            if ((fp = (FILE *) fopen(ptcFile->newfilename, "r+")) &&
               fread(&filehdr, 1, 512, fp))
            {
#ifdef BIG_ENDIAN
               som_swapint(&filehdr.fp_cluster0, &i);
               i += 8;
               som_swapint(&filehdr.i_size, &j);
#else
               i = filehdr.fp_cluster0 + 8;
               j = filehdr.i_size;
#endif

               {
                  /* Re-checksum the file */

                  int            ii, fileloc, bcount, size;
                  unsigned char  *ptr, buffer[16384];

                  filehdr.checksum = 0;
                  fileloc = sizeof(struct OM_sd_OS_filehdr_OM);
                  fseek(fp, fileloc, 0);
                  bcount = j - fileloc;
                  while(bcount)
                  {
                     if (bcount > 16384)
                        size = 16384;
                     else
                        size = bcount;
                     if (fread(buffer, 1, size, fp) != size)
                     {
                        fprintf(stderr, "copyOS:: Could not re-checksum file %s\n",
                           ptcFile->newfilename);
                        continue;
                     }
                     bcount -= size;
                     for (ii=0; ii<size; ii++, fileloc++)
                        filehdr.checksum += (unsigned char) buffer[ii] +
                           fileloc;
                  }
                  ptr = (unsigned char *) &filehdr.magic;
                  for (ii=filehdr.hdr_checksum=0; ii<434; ii++, ptr++)
                     filehdr.hdr_checksum += ii + *ptr;

#ifdef BIG_ENDIAN
                  som_swapint(&filehdr.checksum, &sts);
                  filehdr.checksum = sts;
                  som_swapint(&filehdr.hdr_checksum, &sts);
                  filehdr.hdr_checksum = sts;
#endif

                  fseek(fp, 0, 0);
                  fwrite(&filehdr, 1,
                     sizeof(struct OM_sd_OS_filehdr_OM), fp);
               }
               fclose(fp);
            }
         }
         aa++;
      }
   }

   exit(0);
}

end implementation OMFiledOS;
