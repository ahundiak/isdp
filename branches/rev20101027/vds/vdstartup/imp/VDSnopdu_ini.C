/* $Id: VDSnopdu_ini.C,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/imp / VDSnopdu_ini.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSnopdu_ini.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/09/26  22:30:26  pinnacle
 * Replaced: vdstartup/imp/VDSnopdu_ini.C for:  by sundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/****************************************************************************

      VDSnopdu_ini.c - Initialization for non PDU version of VDS

      Returns 1 if OK
              0 if error

      Written 92-11-10 by Roger Malmgren

****************************************************************************/

#include <stdio.h>
#include "OMlimits.h"		/* defines OM_K_MAXOSNAME_LEN */

#include "igrtypedef.h"
#include "OMtypes.h"
#include "ex.h"

#include "exmacros.h"		/* defines ex$global */
#include "PDUstr.h"		/* defines struct PDUrefresh */
#include "PDUuser.h"		/* defines struct PDUuser */

extern int VD_PDU_present;
extern struct PDUrefresh *refresh;
extern struct PDUuser *user;

#define MAX_CHAR_LINE	81
#define MAX_CHAR_WORD	25

/* */
extern int	uname(),
		malloc(),
		/* strncpy(), */
		ACconstruct_path(),
                ASsuper_construct(),
		VDScheck_pdu(),
                VDsuper_construct();
/* */
int VDSnopdu_init()
{
   struct EX_var_list ex_var[2];
   IGRint var_size, bad_var;
   char path[OM_K_MAXOSNAME_LEN], node[OM_K_MAXOSNAME_LEN];
   static int first = 1;

   /* Check if PDU is downloaded to workstation */
   if (!VDScheck_pdu()) return 0;

   if (!VD_PDU_present && first) /* First call only - not after retrieve file */
   {
      first = 0;
      /* PDU not present - initialize refresh and user structures */
      if (refresh == NULL)
         refresh = (struct PDUrefresh *) malloc (sizeof(struct PDUrefresh));

      refresh->rev_project = "";
      refresh->rev_catalog = "";
      refresh->cat_path = "";
      refresh->rev_partid = "";
      refresh->rev_revision = "";
      refresh->rev_filename = "";
      refresh->rev_parttype = "";
      refresh->rev_description = "";

      refresh->new_project = "";
      refresh->new_catalog = "";
      refresh->new_partid = "";
      refresh->new_revision = "";
      refresh->new_parttype = "";
      refresh->new_description = "";

      refresh->act_project = "";
      refresh->act_catalog = "";
      refresh->act_partid = "";
      refresh->act_revision = "";
      refresh->act_filename = "";
      refresh->act_description = "";
      refresh->act_parttype = "";

      refresh->parm_part_list = NULL;   
      refresh->parm_value_list = NULL;
      refresh->status = 0;

      if (user == NULL)
        user = (struct PDUuser *) malloc (sizeof(struct PDUuser));

      user->username = NULL;
      user->environment = NULL;
      user->server = NULL;
      user->passwd = NULL;
      user->user_id = NULL;
      user->storage_name = NULL;

      user->wrkst_username = NULL;
      user->wrkst_passwd = NULL;

      user->wrkst_cwd = NULL;

      /* Get current working directory */
      var_size = sizeof( path );
      ex_var[0].var       = EX_WORKING_DIR;
      ex_var[0].var_value = path;
      ex_var[0].num_bytes = &var_size;

      ex_var[1].var = NULL;
      if (!ex$global ( mode = EX_INQ,
                       var  = &ex_var[0],
                       which_error = &bad_var ))
         printf("Failed to get current working directory\n");
      else
      {
         if (strcmp(path,"/"))
         {
            /* Get rid of the last '/' */
            path[strlen(path) - 1] = NULL;
         }
         VdsPtrStrcpy(&user->wrkst_cwd,path);
      }

      user->wrkst_node = NULL;

      /* Get workstation node name - calling execute_unix_com since I couldn't
         get system function uname() to work */
      if (!execute_unix_com("\\uname -n",OM_K_MAXOSNAME_LEN,node))
      {
         printf("Failed to get workstation node name\n");
      }
      else 
      {
         VdsPtrStrcpy(&user->wrkst_node,node);
      }
   }
   return 1;
}

int execute_unix_com(command,nchar,result)
char command[];
int  nchar;
char result[];
{
     int                i;
     FILE *             t_file;
     char               buffer[81];
     char *             t_name;
        if (( t_name=tmpnam((char *)NULL)) == NULL)  return 0;

        sprintf(buffer,"%s > %s",command,t_name);
        system(buffer);
        if ((t_file = (FILE *)fopen(t_name,"r")) == NULL) return 0;

        if (fgets(result,nchar-1, t_file) == NULL) return 0;
        result[nchar-1] = NULL;
        for(i=0;i<strlen(result); i++)
          {
           if (result[i] == '\n')
             {
              result[i] = NULL;
              break;
             }
          }
        fclose (t_file);
        unlink(t_name);
        return 1;
}

