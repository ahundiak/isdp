#include <stdio.h>
#include <string.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLfull_mirror_archive

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmirror.c

Author: Rob Whitesell

Date:    August 3, 1992

Description:
			This function replaces all above functions by doing the mirror archive
				in full at the time of request.  This is possible since we no 
				longer have to use the mcm server to access optical disks.
			The function mount the checkin and the mirror archive storage 
				locations, and copies the cifilename from one to the other.
			It then reports via the results file that the mirror archive worked 
				or failed.

Examples:
          BLfull_mirror_archive();

Return Status:
			0			-success
			non-0		-UMS error number

History:

******************************************************************************/
  
long BLfull_mirror_archive (itemno,co_file,cisano,masano)
	long  itemno;   /* I -item number */
	char *co_file;  /* I -checkout filename */
	long  cisano;   /* I -checkin storage area number */
	long  masano;   /* I -mirror archive storage area number */
{
long   status;
static long last_ci=-1;
static char ci_node[MAX_ASCII_LINE_LEN];
static char ci_path[MAX_ASCII_LINE_LEN];
static char ci_user[MAX_ASCII_LINE_LEN];
static char ci_passwd[MAX_ASCII_LINE_LEN];
static long last_ma=-1;
static char ma_node[MAX_ASCII_LINE_LEN];
static char ma_path[MAX_ASCII_LINE_LEN];
static char ma_user[MAX_ASCII_LINE_LEN];
static char ma_passwd[MAX_ASCII_LINE_LEN];
char  *error_m;
char   od_file[32];
char   sql_line[256];
char   ci_full[MAX_ASCII_LINE_LEN],ci_resolved[MAX_ASCII_LINE_LEN];
char   ma_full[MAX_ASCII_LINE_LEN],ma_resolved[MAX_ASCII_LINE_LEN];
char   command[512];
char   *test;

extern char *utl_mount();

   if (flags.dbg)
      fprintf(dbgfile,"Entering BLfull_mirror_archive().\n");

	mirror_count++;

	if (!valid_sa(cisano) || !valid_sa(masano)) {
		BLwrite_result(DMD_E_BAD_M_INFO,"");
		BLwrite_result(DMD_W_RIS_ERROR,error_m);
		BLwrite_result(DMD_F_BAD_M_A,co_file);
		return(DMD_E_BAD_M_INFO);
		}

   if (last_ci != cisano) {
      status = NFMa_sa_information(cisano,ci_node,ci_path,ci_user,ci_passwd
												,&error_m);
      if (status) {
         BLwrite_result(DMD_E_BAD_M_INFO,"");
         BLwrite_result(DMD_W_RIS_ERROR,error_m);
         BLwrite_result(DMD_F_BAD_M_A,co_file);
         return(status);
         }
      last_ci = cisano;
      }

   if (last_ma != masano) {
      status = NFMa_sa_information(masano,ma_node,ma_path,ma_user,ma_passwd
												,&error_m);
      if (status) {
         BLwrite_result(DMD_E_BAD_M_INFO,"");
         BLwrite_result(DMD_W_RIS_ERROR,error_m);
         BLwrite_result(DMD_F_BAD_M_A,co_file);
         return(status);
         }
      last_ma = masano;
      }

   if (flags.dbg)
      fprintf(dbgfile,"Storage Area Information\n\tcheckin node <%s>\t\tpath <%s>\n\tmirror node <%s>\t\tpath <%s>\n"
		,ci_node,ci_path,ma_node,ma_path);

   if (!ci_node[0] || !ci_path[0] || !ma_node[0] || !ma_path[0]) {
      BLwrite_result(DMD_E_BAD_M_INFO,"");
      BLwrite_result(DMD_F_BAD_M_A,co_file);
      return(DMD_E_BAD_M_INFO);
      }
      
   sprintf(sql_line,"select %s from f_%s where %s=%d and %s='%s' and %s=any (select max(%s) from f_%s where %s='%s' and %s=%d)"
                   ,P_CI_FILE,parameters.catalog_name,P_ITEM_NUM,itemno
                   ,P_CO_FILE,BL_ticked(co_file),P_FILE_VER,P_FILE_VER
                   ,parameters.catalog_name,P_CO_FILE,BL_ticked(co_file)
                   ,P_ITEM_NUM,itemno);
   status = single_select(sql_line,od_file,&error_m);

   if (status!=DMD_S_SUCCESS || !od_file[0]) {
      status = NFMa_find_cifilename(parameters.catalog_name,itemno,co_file
                                   ,od_file,&error_m);
      if (status || !od_file[0]) {
         BLwrite_result(DMD_E_BAD_M_INFO,"");
         BLwrite_result(DMD_F_BAD_M_A,co_file);
         return(DMD_E_BAD_M_INFO);
         }
      }

	if (ci_path[strlen(ci_path)-1]=='/') ci_path[strlen(ci_path)-1]=0;
	if (ma_path[strlen(ma_path)-1]=='/') ma_path[strlen(ma_path)-1]=0;

   test=utl_mount(ci_node,ci_path,ci_resolved);
   if (test) {
      BLwrite_result(DMD_E_CANT_MOUNT,sa_names[cisano]);
      BLwrite_result(DMD_E_M_NET_ERROR,test);
      BLwrite_result(DMD_F_BAD_M_A,co_file);
      return(DMD_E_BAD_M_COPY);
      }
   sprintf(ci_full,"%s/%s",ci_resolved,od_file);

   test=utl_mount(ma_node,ma_path,ma_resolved);
   if (test) {
      BLwrite_result(DMD_E_CANT_MOUNT,sa_names[masano]);
      BLwrite_result(DMD_E_M_NET_ERROR,test);
      BLwrite_result(DMD_F_BAD_M_A,co_file);
      return(DMD_E_BAD_M_COPY);
      }
   sprintf(ma_full,"%s/%s",ma_resolved,od_file);

   if (flags.dbg)
      fprintf(dbgfile,"Copying file <%s> node <%s> to file <%s> node <%s>\n"
             ,ci_full,ci_node,ma_full,ma_node);
	sprintf(command,"/bin/cp %s %s >/dev/null 2>$1",ci_full,ma_full);

	status=system(command);

	if (status) {
      BLwrite_result(DMD_E_CANT_COPY,sa_names[masano]);
      BLwrite_result(DMD_E_M_NET_ERROR,test);
      BLwrite_result(DMD_F_BAD_M_A,co_file);
      return(DMD_E_BAD_M_COPY);
		}

	BLwrite_result(DMD_I_GOOD_M_A,co_file);
	mirror_okay++;
   return(0);
} /* end BLfull_mcm_out */
