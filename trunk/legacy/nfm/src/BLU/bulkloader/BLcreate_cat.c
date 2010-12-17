#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "MCC_make_red.h"
#include "BLvars.h"

/******************************************************************************

Doc:    BLcreate_cat

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcreate_cat.c

Author: Rob Whitesell

Date:   06-AUGUST-1991

Description:
        This module controls the creation of any catalogs that do not already
           exist.
        It writes its own messages to the results file.
        Algorithm:
           1) Read catalog name and see if it already exists.
           2) Build table creation buffer
           3) If NFM attributes are found, create NFM catalog, else create RIS.

Examples:
          BLcreate_cat();

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -modified for 3.0.0.0 .blk file (no cfg section)
     10/21/92  wrw  -removed creation of f_ index

******************************************************************************/

void BLcreate_cat ()
{
long   nfm_cat=0;
long   status,size,curr=0;
long   attr=0;
char *buffer,*error_m,hold[50];
char *name,*syn,*tp;
char   work[MAX_ASCII_LINE_LEN];
char   catalog[MAX_ASCII_LINE_LEN];
int    build_buffer=0;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLcreate_cat.\n");

   size = 3072;
   buffer = (char *) malloc(size * sizeof(char));

   ignore_comments();

   while (fgets(work,MAX_ASCII_LINE_LEN,bulkload)) {
      fprintf(reload,"%s",work);

      ignore_comments(); /* get the fp in write place for next read */

      work[strlen(work)-1]=0;
      if (    work[0]!=PARAM_DELIMIT 
          || !strncmp(work,SECTION_DELIMIT,strlen(SECTION_DELIMIT))) {
         if (build_buffer) { 
            /* submit the catalog buffer we have prev built */
            if (flags.dbg)
            fprintf(dbgfile,"Buffer --cut here --\n%s\n--cut here--\n",buffer);
      
            if (nfm_cat) {
               /* create the NFM catalog */
               status = NFM2_create_catalog(catalog,buffer,attr,strlen(buffer));
               if (status) {
                  BLwrite_result(DMD_W_CREATE_FAIL,catalog);
                  NFMa_write_result();
                  }
               else {
                  BLwrite_result(DMD_I_NFM_CAT_CREATE,catalog);
                  /* we are done if this we are running in NFM mode */
                  if (!flags.nfm_mode) {
                     sprintf(hold,"%s_rl",catalog);
                     status = NFM2_create_catalog(hold,redline_data
                                                 ,redline_attrs,redline_size);
                     if (status) {
                        BLwrite_result(DMD_W_CREATE_FAIL,hold);
                        NFMa_write_result();
                        }
                     else {
                        /* create the d_ table */
                        sprintf(hold,"d_%s",catalog);
                        status = NFMa_create_d_(hold,&error_m);
                        if (status) {
                            BLwrite_result(DMD_W_CREATE_FAIL,hold);
                            BLwrite_result(DMD_W_RIS_ERROR,error_m);
                            }
                        else {
                           /* create the ref_doc table if needed */
                           if (!BLvalid_cat("ref_doc",RIS_CAT))
                              status = NFMa_create_ref_doc(&error_m);
                           if (status) {
                              BLwrite_result(DMD_W_CREATE_FAIL,"ref_doc");
                              BLwrite_result(DMD_W_RIS_ERROR,error_m);
                              }
                           else {
                              BLwrite_result(DMD_I_DMDS_CREATE,"");
                              }  /* everything was successful */
                           }  /* create d_ table worked */
                        }  /* create redline catalog worked */
                     }  /* should create DMANDS catalogs */
                  }  /* create NFM catalog worked */
               }  /* catalog is NFM */
            else {
               status = NFMa_create_table(catalog,buffer,attr,strlen(buffer)
                                         ,&error_m);
               if (status) {
                  BLwrite_result(DMD_W_CREATE_FAIL,catalog);
                  BLwrite_result(DMD_W_RIS_ERROR,error_m);
                  }
               else {
                  BLwrite_result(DMD_I_RIS_CAT_CREATE,catalog);
                  }
               }
            }

         if (!strncmp(work,SECTION_DELIMIT,strlen(SECTION_DELIMIT)))
            break;

         if (!BLvalid_cat(work,NFM_CAT)&&!BLvalid_cat(work,RIS_CAT)) {
            /* this catalog needs to be created */
            if (!buffer) {
               BLwrite_result(DMD_E_BAD_ALLOC,"");
               if (flags.dbg)
                  fprintf(dbgfile,"returning 'cause bad malloc\n");
               return;
               }
            strcpy(catalog,work);
            build_buffer = 1; nfm_cat = 0;
            buffer[0] = 0; curr = 0; attr = 0;
            BLwrite_result(DMD_I_CREATE_CAT,catalog);
            }
         else {
            build_buffer = 0;
            }
         continue;
         }

      /* line is not a catalog name; build buffer if needed */
      if (!build_buffer) continue;

      name=work+1;
      syn=strchr(name,PARAM_DELIMIT)+1;
      tp=strrchr(work,PARAM_DELIMIT)+1;
      if (!name || !syn || ! tp) {
         BLwrite_result(DMD_E_BAD_CATALOG_LINE,work);
         build_buffer=0;
         continue;
         }
      *(syn-1)=0;
      *(tp-1)=0;

      if (!strcmp(name,P_ITEM_NAME))
         nfm_cat = 1;

      if (   !strcmp(name,D_MULT_PAGE) || !strcmp(name,D_REDUCED)
          || !strcmp(name,D_MIRROR)    || !strcmp(name,D_DESC))
          continue;

      attr++;
      /* write in the attribute name */
      if (size<=(curr+=(strlen(name)+1))) {
         buffer = realloc(buffer,((size+=1024)*sizeof(char)));
         if (!buffer) {
            BLwrite_result(DMD_E_BAD_ALLOC,"");
            if (flags.dbg)
               fprintf(dbgfile,"returning 'cause bad malloc\n");
            return;
            }
         }
      strcat(buffer,name);
      strcat(buffer,"\n");
         
      /* write in the type */
      if (size<(curr+=(strlen(tp)+1))) {
         buffer = realloc(buffer,((size+=1024)*sizeof(char)));
         if (!buffer) {
            BLwrite_result(DMD_E_BAD_ALLOC,"");
            if (flags.dbg)
               fprintf(dbgfile,"returning 'cause bad malloc\n");
            return;
            }
         }
      strcat(buffer,tp);
      strcat(buffer,"\n");
   
      /* write our the synonym */
      if (size<=(curr+=(strlen(syn)+1))) {
         buffer = realloc(buffer,((size+=1024)*sizeof(char)));
         if (!buffer) {
            BLwrite_result(DMD_E_BAD_ALLOC,"");
            if (flags.dbg)
               fprintf(dbgfile,"returning 'cause bad malloc\n");
            return;
            }
         }
      strcat(buffer,syn);
      strcat(buffer,"\n");
      } /* main while loop */

   free(buffer);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLcreate_cat normally.\n");

} /* end BLcreate_cat */
