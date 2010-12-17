#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/* Global Variables (used only in this .c)*/
long  hold_pos;
long  file_num;

/* functions in this .c */
long BLdatarec();
void write_rld_to_delm();
long find_op();
long find_attr();
void clear_op_stuff();


/******************************************************************************

Doc:    BLdatarec

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLdatarec.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module performs the reading and parsing of the data records found
           in the .blk file.
        It reads the operation division and loads the flag and parameters
           structures.
        It loads the values for the attributes.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLdatarec();

Return Status:
          DMD_W_SYNTAX_ERROR   - bad data found
          DMD_W_EOF_FOUND      - EOF found in the .blk file
          DMD_S_SUCCESS        - success
          any error status returned by find_op() on failure
          any error status returned by find_attr() on failure

History:

     07/03/91  wrw  -fixed bug in BLdatarec() operation while loop so that it
                       now returns syntax error if no ops found.
     07/23/91  wrw  -made errors written to rld when found, not by calling 
                       routine.  (Better diagnostics.)
     08/07/91  wrw  -made find_index() check that the catalog was created
                       properly.
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -changed the way attribute data is stored.
                    -removed the functions clear_attr_stuff() and find_index()

******************************************************************************/
long BLdatarec ()
{
long   status;
char  work[MAX_ASCII_LINE_LEN+1];
char  hold[MAX_ASCII_LINE_LEN+1];
char *spot;

   if (flags.dbg)
      fprintf (dbgfile,"Entering BLdatarec().\n");

   /* clear parameters and flags */
   clear_op_stuff();

   /* Save file position so that we can write out the reload file exactly
      as it is if syntax error occurs. */
   hold_pos = ftell(bulkload);

   /* read operation division, parse, and load */
   while (1) {
      if (ignore_comments()==DMD_W_EOF_FOUND) {
         if (flags.dbg)
            fprintf(dbgfile,"Exiting BLdatarec because of EOF\n");
         if (flags.ops_found) {
            BLwrite_result(DMD_I_VALID_OP_DIV,"");
            return(DMD_S_SUCCESS);
            }
         else
            return(DMD_W_EOF_FOUND);       /* no more data records found */
         }

      if (fgets(work,MAX_ASCII_LINE_LEN,bulkload)==NULL) {
         if (flags.dbg)
            fprintf(dbgfile,"Exiting BLdatarec because of EOF\n");
         if (flags.ops_found) {
            BLwrite_result(DMD_I_VALID_OP_DIV,"");
            return(DMD_S_SUCCESS);
            }
         else
            return(DMD_W_EOF_FOUND);       /* no more data records found */
         }

      /* put null character instead of new line */
      spot = strrchr(work,'\n');
      if (spot)
         strcpy(spot,"\0");
      else 
         work[MAX_ASCII_LINE_LEN]='\0';

      if (!strcmp(work,RECORD_DELIMIT)) {
         if (flags.dbg)
            fprintf(dbgfile,"Exiting BLdatarec because no data division\n");
         if (flags.ops_found) {
            BLwrite_result(DMD_I_VALID_OP_DIV,"");
            return(DMD_S_SUCCESS);
            }
         else {
            BLwrite_result(DMD_W_NO_OPS,"");
            return(DMD_W_SYNTAX_ERROR);      /* no operations found */
            }
         }

      if (!strcmp(work,DIVISION_DELIMIT))
         break;                               /* go to read data division */

      if (flags.dbg)
         fprintf(dbgfile,"Parsing: %s\n",work);

      /* find out what operation we have and set flags, load params */
      strcpy(hold,work);
      if ((status=find_op(work)) == DMD_S_SUCCESS)
         continue;
      else {
         write_rld_to_delm(hold_pos);
         return (status);
         }
      } /* end while (read op) loop */

   if (!flags.ops_found) {
      BLwrite_result(DMD_W_NO_OPS,"");
      write_rld_to_delm(hold_pos);
      return(DMD_W_SYNTAX_ERROR);      /* no operations found */
      }

   /* report good op division syntax */
   BLwrite_result(DMD_I_VALID_OP_DIV,"");
   
   /* clear out attributes stuff */
   if ((status=BLclear_attrs())!=DMD_S_SUCCESS) {
      write_rld_to_delm(hold_pos);
      return(status);
      }

   /* parse the data section, load data structures */
   data_div_pos = ftell(bulkload);
   file_num=0;
   while (1) {
      if (ignore_comments()==DMD_W_EOF_FOUND) {
         if (flags.dbg)
            fprintf(dbgfile,"Exiting BLdatarec because of EOF\n");
         return(DMD_W_EOF_FOUND);          /* no more data records found */
         }

      if (fgets(work,MAX_ASCII_LINE_LEN,bulkload)==NULL) {
         if (flags.dbg)
            fprintf(dbgfile,"Exiting BLdatarec because of EOF\n");
         return(DMD_W_EOF_FOUND);          /* no more data records found */
         }

      /* put null character instead of new line */
      spot = strrchr(work,'\n');
      if (spot)
         strcpy(spot,"\0");
      else 
         work[MAX_ASCII_LINE_LEN]='\0';

      if (!strcmp(work,RECORD_DELIMIT))
         break;                               /* done with data division */

      if (flags.dbg)
         fprintf(dbgfile,"Parsing: %s\n",work);

      /* find out what attribute we have and load data structure */
      strcpy(hold,work);
      if ((status=find_attr(work)) == DMD_S_SUCCESS)
         continue;
      else {
         write_rld_to_delm(hold_pos);
         if (flags.dbg) 
            fprintf(dbgfile,"Exiting BLdatarec() due to an error\n");
         return (status);
         }
      }

   /* report good data division syntax */
   BLwrite_result(DMD_I_VALID_DAT_DIV,"");
   
   if (flags.dbg)
      fprintf (dbgfile,"Exiting BLdatarec() normally.\n");
 
   return(DMD_S_SUCCESS);

} /* end BLdatarec */


/******************************************************************************

Doc:    write_rld_to_delm

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLdatarec.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function writes a data record to the reload (.rld) file.  
        It starts on a give position, and writes until it hits a data record
           delimit line (RECORD_DELIMIT).
        It writes its own messages to the results file.

Examples:
          write_rld_to_delm(start_file_position);

Return Status:
          (none)

History:
     07/23/91  wrw  -made errors written to rld when found, not by calling 
                       routine.  (Better diagnostics.)
     09/03/91  wrw  -added standard header

******************************************************************************/

void write_rld_to_delm (pos)
long pos;                       /* I - file position to start at in .blk */
{
char work[MAX_ASCII_LINE_LEN+1];

   fseek(bulkload,pos,0);
   while (fgets(work,MAX_ASCII_LINE_LEN,bulkload)) {
      fprintf(reload,"%s",work);
      if (!strncmp(work,RECORD_DELIMIT,1)) 
         return;
      }
   return;
} /* end write_rld_to_delm() */


/******************************************************************************

Doc:    find_op

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLdatarec.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function parses a line from the operation division of a record in
           the .blk file.
        It locates and stores the operation and its parameters in the global
           structures that will hold the data record.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = find_op(operation_text);

Return Status:
          DMD_W_OP_UNKNOWN       - operation could not be identified.
          DMD_W_NOT_ALL_PARAMS   - all the parameters need for this operation
                                     were not supplied.
          DMD_W_ITM_TOO_LONG     - the item name was too long.
          DMD_W_CAT_TOO_LONG     - the catalog name was too long.
          DMD_S_SUCCESS          - success

History:

     06/28/91  wrw  -added code to support the NFM copy command.
     07/23/91  wrw  -made errors written to rld when found, not by calling 
                       routine.  (Better diagnostics.)
     08/21/91  wrw  -added code to support the NFM create_set command.
     08/23/91  wrw  -added code to support the NFM add_to_project command.
     08/26/91  wrw  -added code to support the NFM modify_item command.
     09/03/91  wrw  -added standard header
     06/14/92  wrw  -added code to suport the ftr index command.
     09/02/94  wrw  -added support for the set check in and out

******************************************************************************/

long find_op (work)
char *work;                     /* I - text line from the operation division */
{
char *spot;
char *t2,*tmp;

   /* check if operation found was 'catalog' */
   if (!strncmp(work,OP_CATALOG,7)) {
      flags.ops_found = flags.catalog = 1;
      spot = strchr(work,PARAM_DELIMIT);
      if (spot && (strlen(spot)<MAX_CAT_NAME_LEN)) {
         spot++; /* move past colon */
         if (spot)
            strcpy(parameters.catalog_name,spot);
         if (flags.dbg)
            fprintf(dbgfile,"parameters.catalog=%s\n",parameters.catalog_name);
         if (BLvalid_cat(parameters.catalog_name,NFM_CAT))
            parameters.catalog_type=NFM_CAT;
         else if (BLvalid_cat(parameters.catalog_name,RIS_CAT))
            parameters.catalog_type=RIS_CAT;
         else {
            BLwrite_result(DMD_W_CAT_NO_EXIST,parameters.catalog_name);
            return(DMD_W_CAT_NO_EXIST);
            }
         return(DMD_S_SUCCESS);
         }
      if (!spot) 
         return(DMD_S_SUCCESS);
      else {  
         BLwrite_result(DMD_W_CAT_TOO_LONG,spot);
         return(DMD_W_CAT_TOO_LONG);
         }
      }

   /* check if operation found was 'add' */
   if (!strncmp(work,OP_ADD,3)) {
      flags.ops_found = flags.add = 1;
      spot = strrchr(work,PARAM_DELIMIT);
      if (spot) {
         if (strcmp(++spot,"\0"))
            parameters.acl_no = atoi(spot);
         if (flags.dbg)
            fprintf(dbgfile,"parameters.acl_no=%d\n",parameters.acl_no);
         strcpy(--spot,"\0");
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.item_rev,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.item_rev=%s\n",parameters.item_rev);
            strcpy(--spot,"\0");
            }
         spot = strchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.item_name,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.item_name=%s\n"
                              ,parameters.item_name);
            return(DMD_S_SUCCESS);
            }
         }
      else 
         return(DMD_S_SUCCESS);
      if (spot) {
         BLwrite_result(DMD_W_ITM_TOO_LONG,spot);
         return(DMD_W_ITM_TOO_LONG);
         }
      else {
         BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_ADD);
         return(DMD_W_NOT_ALL_PARAMS);
         }
      }

   /* check if operation found was 'project' */
   if (!strncmp(work,OP_PROJECT,7)) {
      flags.ops_found = flags.project = 1;
      spot = strrchr(work,PARAM_DELIMIT);
      if (spot) {
         if (strcmp(++spot,"\0"))
            strcpy(parameters.project_type,spot);
         if (flags.dbg)
            fprintf(dbgfile,"parameters.project_type=<%s>\n"
                           ,parameters.project_type);
         strcpy(--spot,"\0");
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.project_name,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.project_name=%s\n"
                              ,parameters.project_name);
            return(DMD_S_SUCCESS);
            }
         }
      else 
        return(DMD_S_SUCCESS);
      /* if we get below this line error was found */
      if (spot) {
         BLwrite_result(DMD_W_PROJ_TOO_LONG,spot);
         return(DMD_W_ITM_TOO_LONG);
         }
      else {
         BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_PROJECT);
         return(DMD_W_NOT_ALL_PARAMS);
         }
      }

   /* check if operation found was 'modify' */
   if (!strncmp(work,OP_MODIFY,6)) {
      flags.ops_found = flags.modify = 1;
      spot = strrchr(work,PARAM_DELIMIT);
      if (spot) {
         if (strcmp(++spot,"\0"))
            strcpy(parameters.item_rev,spot);
         if (flags.dbg)
            fprintf(dbgfile,"parameters.item_rev=%s\n",parameters.item_rev);
         strcpy(--spot,"\0");
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.item_name,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.item_name=%s\n"
                              ,parameters.item_name);
            return(DMD_S_SUCCESS);
            }
         }
      else 
        return(DMD_S_SUCCESS);
      /* if we get below this line error was found */
      if (spot) {
         BLwrite_result(DMD_W_ITM_TOO_LONG,spot);
         return(DMD_W_ITM_TOO_LONG);
         }
      else {
         BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_MODIFY);
         return(DMD_W_NOT_ALL_PARAMS);
         }
      }

   /* check if operation found was 'delete' */
   if (!strncmp(work,OP_DELETE,6)) {
      flags.ops_found = flags.delete = 1;
      spot = strrchr(work,PARAM_DELIMIT);
      if (spot) {
         if (strcmp(++spot,"\0"))
            strcpy(parameters.item_rev,spot);
         if (flags.dbg)
            fprintf(dbgfile,"parameters.item_rev=%s\n",parameters.item_rev);
         strcpy(--spot,"\0");
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.item_name,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.item_name=%s\n"
                              ,parameters.item_name);
            return(DMD_S_SUCCESS);
            }
         }
      else 
        return(DMD_S_SUCCESS);
      /* if we get below this line error was found */
      if (spot) {
         BLwrite_result(DMD_W_ITM_TOO_LONG,spot);
         return(DMD_W_ITM_TOO_LONG);
         }
      else {
         BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_DELETE);
         return(DMD_W_NOT_ALL_PARAMS);
         }
      }

   /* check if operation found was 'checkin' or 'checkout' or 'copy'*/
   if (!strncmp(work,OP_CHECKIN,7) || !strncmp(work,OP_CHECKOUT,8)
                                   || !strncmp(work,OP_COPY,4)) {
      if (!strncmp(work,OP_CHECKIN,7))
         flags.ops_found = flags.checkin = 1;
      else if (!strncmp(work,OP_CHECKOUT,8))
         flags.ops_found = flags.checkout = 1;
      else
         flags.ops_found = flags.copy = 1;
      spot = strrchr(work,PARAM_DELIMIT);
      if (spot) {
         if (strcmp(++spot,"\0"))
            strcpy(parameters.item_rev,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.item_rev=%s\n",parameters.item_rev);
         strcpy(--spot,"\0");
         spot = strchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.item_name,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.item_name=%s\n"
                              ,parameters.item_name);
            return(DMD_S_SUCCESS);
            }
         }
      else 
        return(DMD_S_SUCCESS);
      /* if we get below this line error was found */
      if (spot) {
         BLwrite_result(DMD_W_ITM_TOO_LONG,spot);
         return(DMD_W_ITM_TOO_LONG);
         }
      else {
         if (flags.checkin)
            BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_CHECKIN);
         else if (flags.checkout)
            BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_CHECKOUT);
         else if (flags.copy)
            BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_COPY);
         return(DMD_W_NOT_ALL_PARAMS);
         }
      }

   /* check if operation found was 'set_in' or 'set_out' */
   if (!strncmp(work,OP_SETIN,6) || !strncmp(work,OP_SETOUT,7)) {
      if (!strncmp(work,OP_SETIN,6))
         flags.ops_found = flags.setin = 1;
      else
         flags.ops_found = flags.setout = 1;
      spot = strrchr(work,PARAM_DELIMIT);
      if (spot) {
         if (strcmp(++spot,"\0"))
            strcpy(parameters.set_rev,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.set_rev=%s\n",parameters.set_rev);
         strcpy(--spot,"\0");
         spot = strchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.set_name,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.set_name=%s\n"
                              ,parameters.set_name);
            return(DMD_S_SUCCESS);
            }
         }
      else 
        return(DMD_S_SUCCESS);
      /* if we get below this line error was found */
      if (spot) {
         BLwrite_result(DMD_W_ITM_TOO_LONG,spot);
         return(DMD_W_ITM_TOO_LONG);
         }
      else {
         if (flags.setin)
            BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_SETIN);
         else
            BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_SETOUT);
         return(DMD_W_NOT_ALL_PARAMS);
         }
      }

   /* check if operation found was 'create_set' */
   if (!strncmp(work,OP_CREATE_SET,10)) {
      flags.ops_found = flags.create_set = 1;
      spot = strrchr(work,PARAM_DELIMIT);
      if (spot) {
         if (strcmp(++spot,"\0"))
            parameters.set_acl_no = atoi(spot);
         if (flags.dbg)
            fprintf(dbgfile,"parameters.set_acl_no=%d\n",parameters.set_acl_no);
         strcpy(--spot,"\0");
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_REV_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.set_rev,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.set_rev=%s\n",parameters.set_rev);
            strcpy(--spot,"\0");
            }
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.set_name,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.set_name=%s\n",parameters.set_name);
            strcpy(--spot,"\0");
            }
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_CAT_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.set_catalog,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.set_catalog=%s\n"
                              ,parameters.set_catalog);
            return(DMD_S_SUCCESS);
            }
         }
      else 
        return(DMD_S_SUCCESS);
      /* if we get below this line error was found */
      if (spot) {
         BLwrite_result(DMD_W_ITM_TOO_LONG,spot);
         return(DMD_W_ITM_TOO_LONG);
         }
      else {
         BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_CREATE_SET);
         return(DMD_W_NOT_ALL_PARAMS);
         }
      }

   /* check if operation found was'set' */
   if (!strncmp(work,OP_SET,3)) {
      flags.ops_found = flags.set = 1;
      spot = strrchr(work,PARAM_DELIMIT);
      if (spot) {
         if (strcmp(++spot,"\0"))
            strcpy(parameters.set_mode,spot);
         if (flags.dbg)
            fprintf(dbgfile,"parameters.set_mode=%s\n",parameters.set_mode);
         strcpy(--spot,"\0");
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_REV_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.set_rev,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.set_rev=%s\n",parameters.set_rev);
            strcpy(--spot,"\0");
            }
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_ITEM_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.set_name,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.set_name=%s\n",parameters.set_name);
            strcpy(--spot,"\0");
            }
         spot = strrchr(work,PARAM_DELIMIT);
         if (spot && strlen(spot)<MAX_CAT_NAME_LEN) {
            if (strcmp(++spot,"\0"))
               strcpy(parameters.set_catalog,spot);
            if (flags.dbg)
               fprintf(dbgfile,"parameters.set_catalog=%s\n"
                              ,parameters.set_catalog);
            return(DMD_S_SUCCESS);
            }
         }
      else 
        return(DMD_S_SUCCESS);
      /* if we get below this line error was found */
      if (spot) {
         BLwrite_result(DMD_W_ITM_TOO_LONG,spot);
         return(DMD_W_ITM_TOO_LONG);
         }
      else {
         BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_SET);
         return(DMD_W_NOT_ALL_PARAMS);
         }
      }

   /* check if RIS insert */
   if (!strncmp(work,OP_RISINSERT,10)) {
      flags.ops_found = flags.RISinsert = 1;
      return(DMD_S_SUCCESS);
      }

   /* check if RIS delete */
   if (!strncmp(work,OP_RISDELETE,10)) {
      flags.ops_found = flags.RISdelete = 1;
      return(DMD_S_SUCCESS);
      }

   /* check if operation found was 'ftr_index' */
   if (!strncmp(work,OP_FTR_INDEX,9)) {
      flags.ops_found = flags.ftr_index = 1;
		tmp=work;
		spot=strchr(tmp,PARAM_DELIMIT);
		if (spot) {*spot=0; tmp=spot+1;}
		spot=strchr(tmp,PARAM_DELIMIT);
      if (spot) {
			t2=tmp; *spot=0; tmp=spot+1; spot=t2;
         if (strlen(spot))
				strcpy(parameters.ftr_coll,spot);
			else if (flags.ftr_mode) {
				BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_FTR_INDEX);
				return(DMD_W_NOT_ALL_PARAMS);
            }
			if (flags.dbg)
			fprintf(dbgfile,"parameters.ftr_coll=%s\n",parameters.ftr_coll);

			spot=strchr(tmp,PARAM_DELIMIT);
         if (strlen(spot)) {
				t2=tmp; *spot=0; tmp=spot+1; spot=t2;
				strcpy(parameters.ftr_file,spot);
				}
			else if (flags.ftr_mode) {
				BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_FTR_INDEX);
				return(DMD_W_NOT_ALL_PARAMS);
            }
			if (flags.dbg)
			fprintf(dbgfile,"parameters.ftr_file=%s\n",parameters.ftr_file);

			spot=strchr(tmp,PARAM_DELIMIT);
         if (strlen(spot)) {
				t2=tmp; *spot=0; tmp=spot+1; spot=t2;
				strcpy(parameters.filter_list,spot);
				}
			if (flags.dbg)
			fprintf(dbgfile,"parameters.filter_list=%s\n",parameters.filter_list);
         }
		else if (flags.ftr_mode) {
			BLwrite_result(DMD_W_NOT_ALL_PARAMS,OP_FTR_INDEX);
			return(DMD_W_NOT_ALL_PARAMS);
			}
		return(DMD_S_SUCCESS);
      }

   /* if we get to here the operation was unknown */
   BLwrite_result(DMD_W_OP_UNKNOWN,work);
   return(DMD_W_OP_UNKNOWN);
} /* end find_op */


/******************************************************************************

Doc:    find_attr

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLdatarec.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function parses a valid line from the data division of a data 
           record found in the .blk file.
        It finds the attribute in the global structure and loads its value.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = find_attr(attr_text_line);

Return Status:
          DMD_W_ATT_NOT_FOUND     - attribute was not found in the global 
                                      data structure.
          DMD_F_INTERN_ERR        - bad malloc
          DMD_W_BAD_FILE_GROUP    - more values for some attribute were found
                                      than there are files.
          DMD_W_NO_DATA_FOUND     - there was no data specified for this attr
          DMD_S_SUCCESS           - success

History:

     07/23/91  wrw  -made errors written to rld when found, not by calling 
                       routine.  (Better diagnostics.)
     09/03/91  wrw  -added standard header
     06/14/92  wrw  -added code for ftr attributes

******************************************************************************/

long find_attr(attr)
char *attr;               /* I - line of attribute text from .blk file */
{
long   status;
long   slot;
char *data;
char  hold[MAX_ATTRIBUTE_LEN];

   hold[0]=0;
   /* handle special cases */
   if (attr[0] == RR_KEY) {
      attr++;
      strcpy(hold,RR_INDIC);
      }
   if (attr[0] == RL_KEY) {
      attr++;
      strcpy(hold,RL_INDIC);
      }
   if (attr[0] == FTR_KEY) {
      attr++;
      strcpy(hold,FTR_INDIC);
      }

   /* find the data */
   data = strchr(attr,PARAM_DELIMIT);
   if (data) {
		*data=0;
      data++;
      strcat(hold,data);
      }
   else {
      BLwrite_result(DMD_W_NO_DATA_FOUND,attr);
      return(DMD_W_NO_DATA_FOUND);
      }

   /* setup for next file group if needed */
   if (!strcmp(attr,P_CO_FILE))
      file_num++;
   if (flags.dbg)
      fprintf(dbgfile,"# of files now is: %d\n",file_num);

   /* put data in the correct location */
   if (file_num)
      status=BLstore_attrs(attr,&slot,hold,file_num);
   else
      status=BLstore_attrs(attr,&slot,hold,1);
   if (status != DMD_S_SUCCESS) return(status);

   /* write out parameters */
   if (!strcmp(attr,P_CO_FILE))
      parameters.co_file_index = slot;
   else if (!strcmp(attr,P_CI_FILE))
      parameters.ci_file_index = slot;
   else if (!strcmp(attr,P_CO_SA))
      parameters.cosa_index = slot;
   else if (!strcmp(attr,P_CI_SA))
      parameters.cisa_index = slot;
   else if (!strcmp(attr,P_FILE_TYPE))
      parameters.type_index = slot;
   else if (!strcmp(attr,P_CO_COMM))
      parameters.co_comm_index = slot;
   else if (!strcmp(attr,P_ITEM_NAME)&&!strcmp(parameters.item_name,""))
      strcpy(parameters.item_name,data);
   else if (!strcmp(attr,P_ITEM_REV)&&!strcmp(parameters.item_rev,""))
      strcpy(parameters.item_rev,data);
   else if (!strcmp(attr,P_ACL_NO)&&(parameters.acl_no<0))
      parameters.acl_no=atoi(data);

   return (DMD_S_SUCCESS);
} /* end find_attr */


/******************************************************************************

Doc:    clear_op_stuff

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLdatarec.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module clears out all global data fields associated with NFM and 
           RIS operations.
        It writes its own messages to the results file

Examples:
          clear_op_stuff();

Return Status:
          (none)

History:

     07/01/91  wrw  -added set_catalog and set_rev to the parameters
                     cleared by clear_op_stuff()
     09/03/91  wrw  -added standard header
     06/14/92  wrw  -added new operation ftr_index
     09/02/94  wrw  -added support for the set check in and out

******************************************************************************/

void clear_op_stuff ()
{
   flags.catalog = flags.add = flags.delete = flags.checkin = flags.checkout
                 = flags.set = flags.RISinsert = flags.RISdelete = flags.copy
                 = flags.modify = flags.ops_found = flags.create_set 
                 = flags.project = flags.ftr_index = flags.setin
                 = flags.setout = 0;
   parameters.acl_no = -1;
   parameters.set_acl_no = -1;
   parameters.catalog_name[0]=0;
   parameters.project_name[0]=0;
   parameters.project_type[0]=0;
   parameters.item_name[0]=0;
   parameters.item_rev[0]=0;
   parameters.set_name[0]=0;
   parameters.set_mode[0]=0;
   parameters.set_catalog[0]=0;
   parameters.set_rev[0]=0;
	parameters.ftr_coll[0]=0;
	parameters.ftr_file[0]=0;
	parameters.filter_list[0]=0;

   parameters.co_file_index = parameters.ci_file_index =
              parameters.cosa_index = parameters.cisa_index =
              parameters.type_index = parameters.co_comm_index = -1;

} /* end clear_op_stuff */
