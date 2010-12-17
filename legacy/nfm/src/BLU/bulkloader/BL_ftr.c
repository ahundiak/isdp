#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/* callable functions */
long  BL_ftr_index();
long  BL_ftr_add_file();
char* BL_collection_name();  
void  BL_stop_ftr_engine();     
long  BL_start_ftr_engine();   


/* internal global variables */
long  BL_ftr_initialized=0;
char  FTR_node[64],FTR_path[1024];
char  BL_collections[4096];


/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

Doc:    BLget_all_files

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BL_ftr.c

Author: Rob Whitesell

Date:   August 27, 1992

Description:
        This function looks in the collection and finds the location of all 
          the files that have already been put there.
        This is designed to allow full indexing (with fille checking) it 
          be performed.

Examples:
        status=BLget_all_files(col,cat,cid);

Return Status:
			DMD_S_SUCCESS       -success

History:

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

long	BLget_all_files(col,cat,cid)
	char *col; /* I -name of the collection */
	char *cat; /* I -name of the catalog */
	long cid;  /* I - highest cid to go to */
{
#ifndef INTEL_SOLARIS                  /* IntelPort - srinivas 16th june 1995 */
char item_no[16],file_no[16];
char node[32],path[256],cifile[32],cofile[32];
char loc_file[256],tmpfile[64];
char sql[512],*error_m;
long i;

extern char *utl_mount();

   if (flags.dbg)
		fprintf(dbgfile,"BLget_all_files - collection <%s> high cid <%d>"
					,col,cid);

	for (i=1;i<cid;i++) {
		if (flags.dbg) fprintf(dbgfile,"\n\tcid <%d> ",i);

		if (FTR_get_catalog_field_info(col,i,FTR_ITEM_NUM,item_no))
			continue;
		if (flags.dbg) fprintf(dbgfile,"item <%s> ",item_no);

		if (FTR_get_catalog_field_info(col,i,FTR_FILE_NUM,file_no))
			continue;
		if (flags.dbg) fprintf(dbgfile,"file <%s> ",file_no);

		sprintf(sql,"select n_nodename,n_pathname,n_cifilename,n_cofilename from nfmnodes,nfmstoragearea,f_%s where n_itemnum=%s and n_fileno=%s and n_sano=n_cisano and nfmnodes.n_nodeno=nfmstoragearea.n_nodeno"
					,cat,item_no,file_no);
		if (NFMa_multi_select(sql,2048,NULL,"n_nodename",1,node,&error_m))
			continue;
		if (flags.dbg) fprintf(dbgfile,"node <%s> ",node);

		if (NFMa_multi_select(NULL,2048,NULL,"n_pathname",1,path,&error_m))
			continue;
		if (flags.dbg) fprintf(dbgfile,"path <%s> ",path);

		if (NFMa_multi_select(NULL,2048,NULL,"n_cifilename",1,cifile,&error_m))
			continue;
		if (flags.dbg) fprintf(dbgfile,"ci <%s> ",cifile);

		if (NFMa_multi_select(NULL,2048,NULL,"n_cofilename",1,cofile,&error_m))
			continue;
		if (flags.dbg) fprintf(dbgfile,"co <%s> ",cofile);

		if (!cifile[0]
			 && NFMa_find_cifilename(parameters.catalog_name,atoi(item_no)
											,cofile,cifile,&error_m))
			continue;
		if (flags.dbg) fprintf(dbgfile,"ci <%s> ",cifile);

		if (utl_mount(node,path,loc_file))
			continue;

		strcat(loc_file,"/"); strcat(loc_file,cifile);
		if (flags.dbg) fprintf(dbgfile,"loc <%s> ",loc_file);
		sprintf(tmpfile,"/usr/tmp/%s",cifile);

		link(loc_file,tmpfile);
		}
	if (flags.dbg) fprintf(dbgfile,"\n");
#endif                   /* IntelPort - srinivas 16th june 1995 */
	return(0);
}


/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

Doc:    BL_ftr_index

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BL_ftr.c

Author: Rob Whitesell

Date:   June 14, 1992

Description:
			This function initiates and waits for the ftr indexing procedure.
			It should be called after all files are added to the collection.

Examples:
        status=BL_ftr_index();

Return Status:
			DMD_S_SUCCESS       -success

History:

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

long	BL_ftr_index()
{
#ifndef INTEL_SOLARIS                   /* IntelPort - srinivas 16th june 1995 */
char *s,*f;
long status;

   BLwrite_result(DMD_I_FREE_FORM," ");

	if (flags.dbg)
		fprintf(dbgfile,"BL_ftr_index - FTR_collections <%s>\n",BL_collections);
	s=strtok((f=strdup(BL_collections)),"\t");
	do {
		if (!s || !strlen(s)) continue;
		BLwrite_result(DMD_I_TRY_INDEX,s);
		status=FTR_invoke_quick_indexing(s);
		if (status) {
			BLwrite_result(DMD_F_INDEX_FAILED,s);
			}
		else {
			BLwrite_result(DMD_S_OP_SUCCESS,OP_FTR_INDEX);
			}
		} while (s=strtok(NULL,"\t"));
	free(f);
#endif                   /* IntelPort - srinivas 16th june 1995 */
	return(DMD_S_SUCCESS);
}


/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

Doc:    BL_ftr_add_file

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BL_ftr.c

Author: Rob Whitesell

Date:   June 14, 1992

Description:
			This function adds current file to a collection so that it may be
				indexed later.
			It tries to add the file supplied as a parameter.  If no file is
				supplied, it tries to add the file given in !n_cofilename.
			Since !n_cofilename is checked in, it uses the checked in file.

Examples:
        status=BL_ftr_add_file();

Return Status:
			DMD_E_BAD_FTR_FILE  -could not access file to index
			DMD_E_BAD_MOD_FTR   -could not modify the collection fields
			DMD_E_BAD_ADD_FTR   -could not add the file to the collection
			DMD_S_SUCCESS   -success

History:
  08/18/92  wrw  -major mods in design

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

long	BL_ftr_add_file()
{
#ifndef INTEL_SOLARIS                   /* IntelPort - srinivas 16th june 1995 */
char *col;
int found,i,max_no,cof;
char sql[512],node[32],path[128],cifile[32],cisano[32];
char item_no[32],file_no[32];
char *error_m,*s,*f;
int  cid;
long status;
char work[256],tmp[32],loc_file[256],*file_ptr;

extern char*	utl_mount();

   if (!BL_ftr_initialized)
      if (BL_start_ftr_engine()) return(1);

	T_count.ftr_indexs_found++;
	cof = parameters.co_file_index;
	max_no = attributes[cof].stored;

	col=BL_collection_name(parameters.catalog_name);
	if (!col) {
		BLwrite_result(DMD_E_NO_COLLECTION,parameters.catalog_name);
		return(DMD_E_NO_COLLECTION);
		}

	for (i=0;i<max_no;i++)
		if (!strncmp(attributes[cof].data[i],FTR_INDIC,1)) {
			file_ptr=&attributes[cof].data[i][1];

			BLwrite_result(DMD_I_TRY_SETUP_INDEX,file_ptr);

			sprintf(sql,"select n_cifilename,n_fileno,n_itemno,n_cisano from %s,f_%s where n_itemno=n_itemnum and n_itemname='%s' and n_itemrev='%s' and n_cofilename='%s' and n_fileversion=(select max(n_fileversion) from f_%s where n_itemnum = n_itemno)"
						,parameters.catalog_name,parameters.catalog_name
						,BL_ticked(parameters.item_name)
						,BL_ticked(parameters.item_rev),BL_ticked(file_ptr)
						,parameters.catalog_name);
			if (flags.dbg) fprintf(dbgfile,"BL_ftr_add_file - sql <%s>\n",sql);
			NFMa_multi_select(sql,2048,NULL,"n_fileno",1,file_no,&error_m);
			NFMa_multi_select(NULL,2048,NULL,"n_itemno",1,item_no,&error_m);
			NFMa_multi_select(NULL,2048,NULL,"n_cifilename",1,cifile,&error_m);
			NFMa_multi_select(NULL,2048,NULL,"n_cisano",1,cisano,&error_m);
			if (flags.dbg) 
				fprintf(dbgfile,"BL_ftr_add_file - item <%s> file <%s> cisano %s\n"
							,item_no,file_no,cisano);

			if (!cifile[0])
				NFMa_find_cifilename(parameters.catalog_name,atoi(item_no),file_ptr
											,cifile,&error_m);
			if (flags.dbg) 
				fprintf(dbgfile,"BL_ftr_add_file - ci file <%s>\n",cifile);


			sprintf(sql,"select n_nodename,n_pathname from nfmnodes,nfmstoragearea where n_sano=%s and nfmnodes.n_nodeno=nfmstoragearea.n_nodeno"
						,cisano);
			if (flags.dbg) fprintf(dbgfile,"BL_ftr_add_file - sql <%s>\n",sql);
			NFMa_multi_select(sql,2048,NULL,"n_nodename",1,node,&error_m);
			NFMa_multi_select(NULL,2048,NULL,"n_pathname",1,path,&error_m);
			if (flags.dbg) 
				fprintf(dbgfile,"BL_ftr_add_file - node <%s> path <%s>\n",node
							,path);

			s=utl_mount(node,path,loc_file);
			if (s) {
				BLwrite_result(DMD_E_CANT_MOUNT,sa_names[atoi(cisano)]);
				BLwrite_result(DMD_E_M_NET_ERROR,s);
				BLwrite_result(DMD_E_BAD_ADD_FTR,col);
				}

			if (flags.dbg) 
				fprintf(dbgfile,"BL_ftr_add_file - local dir <%s>\n",loc_file);

			strcat(loc_file,"/");
			strcat(loc_file,cifile);

			if (flags.dbg) 
				fprintf(dbgfile,"BL_ftr_add_file - local file <%s>\n",loc_file);
   		if (access(loc_file,0)) {
				BLwrite_result(DMD_E_BAD_FTR_FILE,file_ptr);
				return(DMD_E_BAD_FTR_FILE);
				}

			sprintf(tmp,"/usr/tmp/%s",cifile);
			if (flags.dbg) 
				fprintf(dbgfile,"BL_ftr_add_file - tmp file <%s>\n",tmp);
			if (symlink(loc_file,tmp)) {
				BLwrite_result(DMD_E_BAD_FTR_FILE,file_ptr);
				return(DMD_E_BAD_FTR_FILE);
				}

			status=FTR_add_file_to_collection(col,tmp,"s");
			if ((cid=status)<0) {
				BLwrite_result(DMD_E_BAD_ADD_FTR,col);
				return(DMD_E_BAD_ADD_FTR);
				}

			/* add this collection to the list of those that need indexing */
			if (flags.dbg)
				fprintf(dbgfile,"BL_ftr_add_file - (before) FTR_collections <%s>\n"
             		,BL_collections);
			found=0;
			s=strtok((f=strdup(BL_collections)),"\t");
			do {
				if (found=!strcmp(s,col)) break;
				} while (s=strtok(NULL,"\t"));
			free(f);
			if (!found) {
				sprintf(work,"%s\t",col);
				strcat(BL_collections,work);
				}
			if (flags.dbg)
				fprintf(dbgfile,"BL_ftr_add_file - (after) FTR_collections <%s>\n"
							,BL_collections);

			if (flags.nfm_mode || flags.ftr_mode) continue;

			status=FTR_update_catalog_field_info(col,cid,FTR_ITEM_NUM,item_no);
			if (!status)
				status=FTR_update_catalog_field_info(col,cid,FTR_FILE_NUM,file_no);

			if (status) {
				BLwrite_result(DMD_E_BAD_MOD_FTR,col);
				return(DMD_E_BAD_MOD_FTR);
				}
			}

	BLwrite_result(DMD_S_FTR_PREPARE,"");
	T_count.ftr_indexs_performed++;
	flags.ftr_index=0;
#endif                   /* IntelPort - srinivas 16th june 1995 */
	return(DMD_S_SUCCESS);
}


/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

Doc:    BL_collection_name

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BL_ftr.c

Author: Rob Whitesell

Date:   March 14, 1992

Description:
        This function will return the collection name for a given catalog.

Examples:
        BL_collection_name(catalog);

Return Status:
        NULL     -catalog has no collection
        * -> collection name (read only)

History:

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

char*	BL_collection_name(catalog)
   char *catalog;  /* I - name of the catalog to derive collection name for */
{
#ifndef INTEL_SOLARIS                   /* IntelPort - srinivas 16th june 1995 */
static char cats[5][64]={"","","","",""};
static char cols[5][256]={"","","","",""};
static long wght[5]={0,0,0,0,0};
long i,min,idx,sts;
char tmp[2048];

   if (!BL_ftr_initialized)
      if (BL_start_ftr_engine()) return((char *)NULL);

   /* check local cash */
   for (i=0;i<5&&cats[i][0];i++)
      if (!strcmp(catalog,cats[i])) {
         wght[i]++; 
         if (cols[i][0]) 
            return(cols[i]);
         else
            return((char *)NULL);
         }

   min=wght[idx=0];
   for (i=0;i<5;i++)
      if (wght[i]<min) min=wght[idx=i];
   sprintf(cols[idx],"%d",BL_catalog_no(catalog));

	sprintf(tmp,"%s",cols[idx]);
	if (flags.dbg) fprintf(dbgfile,"BL_collection_name - opening <%s>\n",tmp);

	if ((sts=FTR_open_collection(tmp))) {
		sprintf(tmp,"%s/%s",FTR_path,cols[idx]);
		if (flags.dbg) fprintf(dbgfile,"BL_collection_name -creating <%s>\n",tmp);
		sts = FTR_create_collection(tmp);
		if (sts) {
			BLwrite_result(DMD_E_NO_CREATE_COL,catalog);
			cols[idx][0]=0;
			}
		else {
			sprintf(tmp,"%s",cols[idx]);
			sts=FTR_open_collection(tmp);
			}
		}
	if (sts) {
		BLwrite_result(DMD_E_NO_OPEN_COL,catalog);
		cols[idx][0]=0;
		}

   wght[idx]=1;
   strcpy(cats[idx],catalog);
   if (cols[idx][0])
      return(cols[idx]);
   else
      return((char *)NULL);
#endif                   /* IntelPort - srinivas 16th june 1995 */
return((char *)NULL); /* IntelPort - srinivas 16th june 1995 */
}


/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

Doc:    BL_start_ftr_engine

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BL_ftr.c

Author: Rob Whitesell

Date:   March 14, 1992

Description:          -Internal Function-
        This function starts the FTR engine for use with DMANDS.

Examples:
        BL_start_ftr_engine();

Return Status:
        0     - success  
        non 0 - failure (return value is a UMS message)

History:

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

long	BL_start_ftr_engine()
{
#ifndef INTEL_SOLARIS                   /* IntelPort - srinivas 16th june 1995 */
char *s;
char *error_m;
char sql[216];
char new_path[256];
char tmp[2048];

static long tried=0;

extern char*	utl_mount();

   if (BL_ftr_initialized) return(0);
	if (tried) return(1);
	tried=1;
  
	sprintf(sql,"select n_nodename,n_pathname from nfmnodes,nfmstoragearea where n_saname='NFMFILES' and nfmnodes.n_nodeno=nfmstoragearea.n_nodeno");

	NFMa_multi_select(sql,2048,NULL,"n_nodename",1,FTR_node,&error_m);
	NFMa_multi_select(NULL,2048,NULL,"n_pathname",1,FTR_path,&error_m);

   if (FTR_path[strlen(FTR_path)-1]=='/') FTR_path[strlen(FTR_path)-1]=0;
   s=strrchr(FTR_path,'/');
   strcpy(++s,"dmd_ftr");
 
setuid(0);setgid(3);
	utl_mount(FTR_node,FTR_path,new_path);
	strcpy(FTR_path,new_path);
	if (access(FTR_path,0)) {
		return(1);
		}
	sprintf(tmp,"FULPATH=%s:/usr/ip32/dmanager/bin:.",FTR_path);
	s=(char *)malloc(strlen(tmp)+5);
	strcpy(s,tmp);
	putenv(s);
	s=(char *)malloc(16);
	sprintf(s,"FTNPATH=");
	putenv(s);
	s=(char *)malloc(20);
	sprintf(s,"FULTEMP=/usr/tmp");
	putenv(s);

	if (flags.dbg) 
		fprintf(dbgfile,"BL_start_ftr_engine - FULPATH set to <%s>\n",s);

   if (FTR_initialize_api()) {
      return(1);
      }

   BL_ftr_initialized=1;
#endif                   /* IntelPort - srinivas 16th june 1995 */
   return(0);
}
