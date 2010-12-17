#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLbulkload

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLbulkload.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module controls the execution of the bulkload process.
        It performs the main loop that reads the bulkload file.
  
        Algorithm:
          1)   Log into NFM.
          2)   Read configuration section, validate catalogs, and build
               data structures needed to hold data records as they are read.
               NOTE: as of version 3.0.0.0 the cfg section no longer exists.
          2.5) Create any catalogs that do not already exist.
               Catalogs are defined in the section that used th have the 
                 cfg information.
          3)   Read data records one by one and perform the desired operations.
                 -operations are read, their flags set, and parameters loaded.
                 -data is read into catalogs buffers.
                 -operations are systematically performed.
                 -results and reload files are written.

        Notes:
          *At one point in time the NFM Server had a major flaw.  It tended to 
            grow in virtual size at an alarming rate.  The work-around for this
            was to log out of the NFM server when the size began to affect the 
            time it took to perform an operation.  Once the NFM server process 
            died we logged back in and returned to earlier performance.
          *This was fixed by NFM, but the code is still in place.  The timing
            function can be turned on by having a file in /usr/tmp called
            timer.err.  The first line in this file is the line to write out
            the timing messages to.  The logout has been disabled.
           

Examples:
          BLbulkload();

Return Status:
          (none)

History:
     06/28/91  wrw  -added code to support NFM copy operation.
     08/06/91  wrw  -added code to create catalogs if needed.
     08/21/91  wrw  -added code to support NFM create_set operation.
     08/23/91  wrw  -added code to support NFM add_to_project operation.
     08/26/91  wrw  -added code to support NFM modify_item operation.
     09/03/91  wrw  -added standard header and converted externs to .h
     09/12/91  wrw  -added code to support the reporting of mirror archive 
                       results.
     12/03/91  wrw  -added code to support the -developer option.
     02/01/92  wrw  -added code to support the -sts option.
     02/02/92  wrw  -changed the way .blk records are stored.
     06/14/92  wrw  -added operation ftr_index stuff
                    -added more stuff to go to the .sts file
     08/03/92  wrw  -changed the handling of mirror archiving.
     08/25/92  wrw  -added more stuff for ftr_index
     09/02/94  wrw  -added support for set check in and out

******************************************************************************/

void BLbulkload () 
{
long   i, j, status;
char  work[MAX_ASCII_LINE_LEN];
char  wk2[MAX_ASCII_LINE_LEN];
long  hold_pos;
struct time_type 
          add,checkin,checkout,copy,Rinsert,Rdelete,set,create_set,project,
          modify,delete;
float  elapsed;
char  *tmp;
FILE  *fp,*tfp;

   /* Write results header */
   header_out(results);

   /* Log in to NFM */
   if (flags.dbg) {
      fprintf (dbgfile,"Entered BLbulkload() \n");
      fprintf (dbgfile,"-----server = .%s.\n",server);
      fprintf (dbgfile,"-----environment = .%s.\n",n_environ);
      fprintf (dbgfile,"-----user = .%s.\n",user);
      if (flags.developer)
         fprintf (dbgfile,"-----password = .%s.\n",password);
      else
         fprintf (dbgfile,"-----password = .Ha! Ha! You can't see it!.\n");
      fprintf (dbgfile,"About to log in to NFM.\n");
      }

   status = NFMa_login(server,n_environ,user,password,flags.dbg,1991);

   if (status <= 0) {
      BLwrite_result(DMD_F_BAD_LOGIN,"");
      if (flags.dbg)
         fprintf (dbgfile,"login failed-status = %d\n",status);
      return;
      }
   else 
      if (flags.dbg)
         fprintf (dbgfile,"login was successful.\n");

   /* check for and process (if found) a ris pre-load file */
   if (flags.ris_load) {
      fp = fopen(ris_fn,"r");
      if (!fp) 
         BLwrite_result(DMD_F_RIS_BAD_OPEN,"");
      else 
         BLRIS_pre_load(fp);
      }

   /* skip over the version number. */
   if (ignore_comments() == DMD_W_EOF_FOUND) {
      BLwrite_result(DMD_W_EOF_FOUND,"");
      return;
      }
   if (fgets(work,MAX_ASCII_LINE_LEN,bulkload) == NULL) {
      BLwrite_result(DMD_W_EOF_FOUND,"");
      return; 
      }
   fprintf(reload,"%s\n",VERSION);

   /* read the parameter delimitor to use */
   if (ignore_comments() == DMD_W_EOF_FOUND) {
      BLwrite_result(DMD_W_EOF_FOUND,"");
      return;
      }
   if (fgets(work,MAX_ASCII_LINE_LEN,bulkload) == NULL) {
      BLwrite_result(DMD_W_EOF_FOUND,"");
      return; 
      }
   work[strlen(work)-1]=0;
   if (flags.dbg)
      fprintf(dbgfile,"parameter delimiter=<%s>\n",work);
   fprintf(reload,"%s\n",work);
   tmp = strchr(work,'[');
   if (!tmp) {
      BLwrite_reload(DMD_F_NO_DELIM,"");
      return;
      }
   tmp++;
   if (!strncmp(++tmp,"]",1))
      PARAM_DELIMIT = (*(--tmp));
   else {
      BLwrite_reload(DMD_F_BAD_DELIM,work);
      return;
      }

   /* create any catalogs or ris tables that do not already exist */
   BLcreate_cat();

   /* allocate space of .blk records */
   attributes = (struct attr_type *) NULL;
   num_of_attr_alloc = 0;
   num_of_attributes = 0;
   BLallocate_attrs(ATTR_CHUNKS);

   /* allocate space for parameters */
   parameters.catalog_name = (char *)malloc((MAX_CAT_NAME_LEN+1)*sizeof(char));
   parameters.item_name = (char *)malloc((MAX_ITEM_NAME_LEN+1)*sizeof(char));
   parameters.item_rev = (char *)malloc((MAX_ITEM_REV_LEN+1)*sizeof(char));
   parameters.set_catalog = (char *)malloc((MAX_CAT_NAME_LEN+1)*sizeof(char));
   parameters.set_name = (char *)malloc((MAX_SET_NAME_LEN+1)*sizeof(char));
   parameters.set_rev = (char *)malloc((MAX_ITEM_REV_LEN+1)*sizeof(char));
   parameters.set_mode = (char *)malloc((MAX_SET_MODE_LEN+1)*sizeof(char));
   parameters.project_name = (char *)malloc((MAX_ITEM_NAME_LEN+1)*sizeof(char));
   parameters.project_type = (char *)malloc((MAX_PROJ_TYPE_LEN+1)*sizeof(char));
   parameters.ftr_coll = (char *)malloc(128*sizeof(char));
   parameters.ftr_file = (char *)malloc(128*sizeof(char));
   parameters.filter_list = (char *)malloc(128*sizeof(char));

   /* zero out counts */
   T_count.records_found = T_count.adds_found = T_count.adds_performed
       = T_count.deletes_found = T_count.deletes_performed 
       = T_count.checkins_found = T_count.checkins_performed 
       = T_count.checkouts_found = T_count.checkouts_performed 
       = T_count.setins_found = T_count.setins_performed 
       = T_count.setouts_found = T_count.setouts_performed 
       = T_count.copys_found = T_count.copys_performed 
       = T_count.sets_found = T_count.sets_performed
       = T_count.modifys_found = T_count.modifys_performed
       = T_count.projects_found = T_count.projects_performed
       = T_count.c_sets_found = T_count.c_sets_performed
       = T_count.RISinserts_found = T_count.RISinserts_performed
       = T_count.RISdeletes_found = T_count.RISdeletes_performed
       = T_count.ftr_indexs_found = T_count.ftr_indexs_performed = 0;
   
   if (flags.dbg)
      fprintf(dbgfile,"--Read configuration section--\n");

   if (flags.timer) {
      for (i=0;i<5;i++) 
         add.times[i] = checkin.times[i] = checkout.times[i] = Rinsert.times[i]
                      = Rdelete.times[i] = set.times[i] = delete.times[i] 
                      = copy.times[i] = create_set.times[i] = project.times[i]
                      = modify.times[i] = 0.0;
      add.count = checkin.count = checkout.count = copy.count = Rinsert.count 
                = Rdelete.count = set.count = delete.count = create_set.count 
                = project.count = modify.count = 0;
      add.low_avg = checkin.low_avg = checkout.low_avg = copy.low_avg 
                = Rinsert.low_avg = Rdelete.low_avg = set.low_avg 
                = delete.low_avg = create_set.low_avg = project.low_avg 
                = modify.low_avg = 1000.0;
      }

   /* loop till EOF */
   while (1) {
      /* print out header in results file */
      T_count.records_found++;
      hold_pos = ftell(results);
      fprintf(results,"\n");
      sprintf(work,"%d\0",T_count.records_found);
      BLwrite_result(DMD_I_FREE_FORM," ");
      BLwrite_result(DMD_I_BREAK_LINE,"");
      BLwrite_result(DMD_I_FREE_FORM," ");
      BLwrite_result(DMD_I_RUN_DATA_REC,work);

      status = BLdatarec();

      if (flags.dbg)
         fprintf(dbgfile,"--READ A RECORD--\n");

      if ((status != DMD_S_SUCCESS) && (status != DMD_W_EOF_FOUND)) {
         /* write .sts file if needed */
         if (flags.sts) {
            sprintf(work,"%d",T_count.records_found);
            BLwrite_sts(DMD_I_STS_JOB_NAME,work);
            BLwrite_sts(DMD_I_OPERATION_FAIL,"record");
            }
         continue;
         }

      if ((status == DMD_W_EOF_FOUND) && !flags.ops_found) {
         break;
         }

      if (flags.dbg) {
         fprintf (dbgfile,"---- DATA RECORD #%d ----\n",T_count.records_found);
         fprintf (dbgfile,
                "cat=%d add=%d proj=%d del=%d mod=%d ckin=%d ckout=%d set=%d c_set=%d Rin=%d Rout=%d ftr_idx %d setin=%d setout=%d\n"
                ,flags.catalog,flags.add,flags.project,flags.delete,flags.modify
                ,flags.checkin,flags.checkout,flags.set,flags.create_set
                ,flags.RISinsert,flags.RISdelete,flags.ftr_index,flags.setin
						,flags.setout);
         fprintf(dbgfile,
                "CAT=<%s> PJ_NAME=<%s> PJ_TYPE=<%s> \nITM=<%s> REV=<%s> ACL=<%d> \nSET_CAT=<%s> SET=<%s> SET_REV=<%s> SET_ACL_NO=<%d> SM=<%s> FTR <%s> <%s> <%s>\n"
                ,parameters.catalog_name
                ,parameters.project_name,parameters.project_type
                ,parameters.item_name,parameters.item_rev,parameters.acl_no
                ,parameters.set_catalog,parameters.set_name
                ,parameters.set_rev,parameters.set_acl_no,parameters.set_mode
                ,parameters.ftr_coll,parameters.ftr_file
                ,parameters.filter_list);
         for (i=0;i<num_of_attributes;i++) {
            fprintf(dbgfile,"%s ",attributes[i].name);
            for (j=0;j<attributes[i].stored;j++) 
                fprintf(dbgfile,"%s ",attributes[i].data[j]);
            }
         }  /* end if dbg */

      T_count.records_performed++;

      /* write .sts file if needed */
      if (flags.sts) {
         sprintf(work,"%d",T_count.records_found);
         BLwrite_sts(DMD_I_STS_JOB_NAME,work);
         }

      if (flags.catalog)
         status = BLcatalog();

      if (flags.add) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLadd_item();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Add operation: ");
               check_time(&add,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_ADD);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_ADD);
            }
         }

      if (flags.modify) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLmodify();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Modify operation: ");
               check_time(&modify,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_MODIFY);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_MODIFY);
            }
         }

      if (flags.project) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLproject();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Project operation: ");
               check_time(&project,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_PROJECT);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_PROJECT);
            }
         }

      if (flags.create_set) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLadd_set();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Create_set operation: ");
               check_time(&create_set,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_CREATE_SET);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_CREATE_SET);
            }
         }

      if (flags.set) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLset();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Set operation: ");
               check_time(&set,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_SET);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_SET);
            }
         }
      
      if (flags.checkout) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLcheck_out();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Checkout operation: ");
               check_time(&checkout,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_CHECKOUT);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_CHECKOUT);
            }
         }
      
      if (flags.checkin) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLcheck_in();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Checkin operation: ");
               check_time(&checkin,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_CHECKIN);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_CHECKIN);
            BL_write_capture_indexing_info();
            }
         }

		if (flags.setout) {
			status=BLset_out();
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_SETOUT);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_SETOUT);
            }
			}

		if (flags.setin) {
			status=BLset_in();
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_SETIN);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_SETIN);
            }
			}

      if (flags.copy) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLcopy();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Copy operation: ");
               check_time(&copy,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_COPY);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_COPY);
            }
         }
      
      if (flags.delete) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLdelete_item();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"Delete operation: ");
               check_time(&checkin,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_DELETE);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_DELETE);
            }
         }

      if (flags.RISinsert) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLRIS_insert();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"RIS insert operation: ");
               check_time(&Rinsert,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_RISINSERT);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_RISINSERT);
            }
         }

      if (flags.RISdelete) {
         if (flags.timer)
            timer(1,"",NULL,&elapsed);
         status = BLRIS_delete();
         if (flags.timer) {
            timer(0,"",NULL,&elapsed);
            if (status == DMD_S_SUCCESS) {
               fprintf(timerfile,"RIS delete operation: ");
               check_time(&Rdelete,elapsed);
               }
            }
         if (flags.sts) {
            if (status == DMD_S_SUCCESS) 
               BLwrite_sts(DMD_I_OPERATION_PASS,OP_RISDELETE);
            else
               BLwrite_sts(DMD_I_OPERATION_FAIL,OP_RISDELETE);
            }
         }

      if (flags.ftr_index) {
			status = BL_ftr_add_file();
         }

      /* if operations failed, their flags were left set */
      if (flags.add||flags.checkin   ||flags.RISinsert||flags.RISdelete
                   ||flags.checkout  ||flags.delete   ||flags.set 
                   ||flags.project   ||flags.modify   ||flags.create_set
                   ||flags.ftr_index ||flags.setin    ||flags.setout)
         BLwrite_reload();

      } /* end loop for read bulkload */

   /* re-position the results files and totals */
   fseek(results,hold_pos,0);
   T_count.records_found--;

   /* perform any ftr indexing needed */
	if (T_count.ftr_indexs_performed)
		BL_ftr_index();

   if (mirror_count || T_count.ftr_indexs_found)
      utl_umount();

	if (T_count.ftr_indexs_found) {
		tfp=popen("/bin/ls -F /usr/tmp|grep '@$'","r");
		while (tfp && fgets(work,MAX_ASCII_LINE_LEN,tfp)) {
			sprintf(wk2,"/usr/tmp/%s",work);
			wk2[strlen(wk2)-2]=0;
			unlink(wk2);
			}
		if (tfp)
			pclose(tfp);
		}

   BLwrite_result(DMD_I_FREE_FORM," ");
   BLwrite_result(DMD_I_BREAK_LINE,"");
   BLwrite_result(DMD_I_FREE_FORM," ");

   /* write out the totals */
   tail_out(results);
         
   if (flags.sts)
      BLwrite_sts(DMD_I_STS_END,"");

   /* close up the files */
   fclose(results);
   fclose(reload);
   fclose(bulkload);

   /* mail message to whoever is running this bulkload */
   if (!flags.no_mail)
      BLmail_results();

   /* log out of NFM */
   if (flags.dbg)
      fprintf(dbgfile,"About to log out of NFM\n");
   status = NFM2_logout();

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLbulkload() Normally\n");
   return;
}
