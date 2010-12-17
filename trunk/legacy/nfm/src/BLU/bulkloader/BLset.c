#include <stdio.h>
#include <string.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLset

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLset.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function controls the addition of items as members of a set.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLset();

Return Status:
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error status returned by NFMa_add_set_item() on failure.

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -updated to use new data sturcts

******************************************************************************/

long BLset ()
{
long   status;
char  buf1[5];

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLset.\n");

   BLwrite_result(DMD_I_TRY_SET,"");
   BLwrite_result(DMD_I_SET_NAME,parameters.set_name);

   /* increment operation counter */
   T_count.sets_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_SET);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!strcmp(parameters.item_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset because no item name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!strcmp(parameters.item_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset because no item rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (!strcmp(parameters.set_catalog,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_CATALOG);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset because no set catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (!BLvalid_cat(parameters.set_catalog,NFM_CAT)) {
      BLwrite_result(DMD_W_CAT_NO_EXIST,parameters.set_catalog);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset cause cat not found <%s>\n"
                        ,parameters.set_catalog);
      return(DMD_W_SYNTAX_ERR);
      }

   if (!strcmp(parameters.set_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset because no set name.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (!strcmp(parameters.set_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset because no set rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (!strcmp(parameters.set_mode,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_MODE);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset because no set mode.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!strcmp(parameters.set_mode,PRIMARY))
      strcpy(buf1,"P");
   else if (!strcmp(parameters.set_mode,SECONDARY))
      strcpy(buf1,"S");
   else {
      BLwrite_result(DMD_W_BAD_SET_MODE,parameters.set_mode);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset because bad set mode <%s>.\n"
                        ,parameters.set_mode);
      return(DMD_W_SYNTAX_ERR);
      }
     

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFMa_add_set_item \n");

   status = NFMa_add_set_item(parameters.set_catalog,parameters.set_name
                             ,parameters.set_rev,parameters.catalog_name
                             ,parameters.item_name,parameters.item_rev,buf1);
   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_add_set_item ->status = %x\n",status);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_SET);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset bad set status.\n");
      return(status);
      }
 
   flags.set = 0;
   T_count.sets_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_SET);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLset normally.\n");
   return(DMD_S_SUCCESS);

} /* end BLset */


/******************************************************************************

Doc:    BLset_in

	Copyright (c) 1994
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLset.c

Author: Rob Whitesell

Date:   21-SEPTEMBER-1994

Description:
        This function controls the checkin of a set.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLset_in();

Return Status:
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error status returned by NFMa_set_in() on failure.

History:

******************************************************************************/

long BLset_in ()
{
long   status;
long i,co_sa;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLset_in.\n");

   BLwrite_result(DMD_I_TRY_SET_IN,"");
   BLwrite_result(DMD_I_SET_NAME,parameters.set_name);

   /* increment operation counter */
   T_count.setins_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_SETIN);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!parameters.set_name[0]) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SETIN);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_in because no set name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!parameters.set_rev[0]) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SETIN);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_in because no set rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* find check out storage area */
   if (((i=parameters.cosa_index)<0)||(!attributes[i].data[0][0])){
      BLwrite_result(DMD_W_MISSING_INFO,OP_SETIN);
      BLwrite_result(DMD_W_MISSING_PARAM,P_CO_SA);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_in() because no co_sa.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   co_sa = atoi(attributes[i].data[0]);
   if (!(status=valid_sa(co_sa))) {
      BLwrite_result(DMD_W_BAD_INFO,P_CO_SA);
      BLwrite_result(DMD_W_BAD_VALUE,attributes[i].data[0]);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_in() because bad co_sa.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   if (status != 1) {
         BLwrite_result(DMD_F_INTERN_ERR,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_in() because bad malloc. \n");
      return(DMD_F_INTERN_ERR);
      }

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFMa_set_in \n");

   status = NFMa_set_in(parameters.catalog_name,parameters.set_name
                             ,parameters.set_rev,sa_names[co_sa]);
   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_set_in ->status = %x\n",status);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_SETIN);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_in bad set status.\n");
      return(status);
      }
 
   flags.setin = 0;
   T_count.setins_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_SETIN);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLset_in normally.\n");
   return(DMD_S_SUCCESS);

} /* end BLset_in */


/******************************************************************************

Doc:    BLset_out

	Copyright (c) 1994
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLset.c

Author: Rob Whitesell

Date:   21-SEPTEMBER-1994

Description:
        This function controls the checkout of a set.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLset_out();

Return Status:
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error status returned by NFMa_set_out() on failure.

History:

******************************************************************************/

long BLset_out ()
{
long   status;
long i,co_sa;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLset_out.\n");

   BLwrite_result(DMD_I_TRY_SET_OUT,"");
   BLwrite_result(DMD_I_SET_NAME,parameters.set_name);

   /* increment operation counter */
   T_count.setouts_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_SETOUT);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!parameters.set_name[0]) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SETOUT);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_out because no set name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!parameters.set_rev[0]) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_SETOUT);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_out because no set rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* find check out storage area */
   if (((i=parameters.cosa_index)<0)||(!attributes[i].data[0][0])){
      BLwrite_result(DMD_W_MISSING_INFO,OP_SETOUT);
      BLwrite_result(DMD_W_MISSING_PARAM,P_CO_SA);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_out() because no co_sa.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   co_sa = atoi(attributes[i].data[0]);
   if (!(status=valid_sa(co_sa))) {
      BLwrite_result(DMD_W_BAD_INFO,P_CO_SA);
      BLwrite_result(DMD_W_BAD_VALUE,attributes[i].data[0]);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_out() because bad co_sa.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   if (status != 1) {
         BLwrite_result(DMD_F_INTERN_ERR,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_out() because bad malloc. \n");
      return(DMD_F_INTERN_ERR);
      }

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFMa_set_out \n");

   status = NFMa_set_out(parameters.catalog_name,parameters.set_name
                             ,parameters.set_rev,sa_names[co_sa]);
   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_set_out ->status = %x\n",status);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_SETOUT);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLset_out bad set status.\n");
      return(status);
      }
 
   flags.setout = 0;
   T_count.setouts_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_SETOUT);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLset_out normally.\n");
   return(DMD_S_SUCCESS);

} /* end BLset_out */
