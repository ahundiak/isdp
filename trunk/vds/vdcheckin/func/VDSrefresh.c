/* $Id: VDSrefresh.c,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/func / VDSrefresh.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSrefresh.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
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

#include	<stdio.h>
#include	"PDUerror.h"
#include	"PDUstr.h"
#include	"PDUuser.h"
#include	"PDMfs.h"

#include	"VDSserver.h"
#include	"VDSris_def.h"
#include	"VDScheckin.h"

#define         AS_DEBUG        1

extern	struct	PDUrefresh	*refresh;
extern  struct  PDUuser		*user;
extern  int	VD_PDU_present;

/* MF (19-Jan_1992) : modification to use review/active PDU refresh area */


int VdsDatabaseAccess ( usr,
			passwd, 
			project,
			catalog,
			partid,
			revision,
			filename,
			rev_flag )

  	char		usr[];
  	char		passwd[];
  	char		project[];
  	char		catalog[];
  	char		partid[];
  	char		revision[];
  	char		filename[];
	int		*rev_flag;

  /*.VDSdatabase_access */
 {

	int		status;

	/*|Check PDU login */
  	if (VDSverify_login() != PDM_S_SUCCESS)
        {
    	   UI_status("User not logged in to Database");
    	   printf("User not logged in to Database\n");
           return DB_WARNING;
        }

	/*|Check PDU refresh area */
	if (refresh == NULL)
   	  {
    	   UI_status("No refresh area defined");
    	   printf("No refresh area defined\n");
    	   return DB_WARNING;
   	  }
	if (VD_PDU_present)
	{
	  /* PDU is present */
	  if((status = PDUvalid_catalog("",refresh->act_catalog)) != PDM_S_SUCCESS)
          {
           if (( status = PDUvalid_catalog("",refresh->rev_catalog)) != PDM_S_SUCCESS
               ||   (refresh->rev_partid[0] == PDM_FS_DIRECTORY))
             {
              /* No PDM part defined */
              UI_status("No PDM part defined");
              printf("No PDM part defined\n");
              return DB_WARNING;
             }
           else *rev_flag = 1;
          }
	  else *rev_flag = 0;  
	}
	else
	{
	   /* PDU is not present */
           if (!VDSverify_catalog(refresh->rev_catalog))
           {
              /* No part defined for non-PDU version*/
              UI_status("No part defined");
              printf("No part defined\n");
              return DB_WARNING;
           }
           else *rev_flag = 1;
	}
	
	strcpy ( usr,    "");
    	strcpy ( passwd,  "");
    	strcpy ( project,  "");
    	strcpy ( catalog,  "");
    	strcpy ( partid,  "");
    	strcpy ( revision, "");
    	strcpy ( filename, "");

  	if (user->wrkst_username != NULL) 
    	  {
	   /*|Get user->wrkst_username */
     	   strcpy( usr,user->wrkst_username);
    	  }
	else
	  {
	   /*|Extract wrkst_username from server file */
	   if (VdsExtractDecodedString ( TITLE_LOG_NAM,
					 usr) == 0) return FAILURE;
    	  }
     	/*"user: <%s>\n", usr */

  	if (user->wrkst_passwd   != NULL) 
    	  {
	   /*|Get user->wrkst_passwd */
     	   strcpy( passwd,   user->wrkst_passwd);
    	  }
	else
	  {
	   /*|Extract wrkst_passwd from server file */
	   if (VdsExtractDecodedString ( TITLE_LOG_PWD,
					 passwd) == 0) return FAILURE;
    	  }
     	/*"passwd: <%s>\n", passwd */
	if (*rev_flag == 0)
    	  {
  	   if (refresh->act_project    != NULL) 
    	     {
	      /*|Get refresh->act_project */
     	      strcpy( project,  refresh->act_project);
    	     }
    	  }
	else
    	  {
  	   if (refresh->rev_project    != NULL) 
    	     {
	      /*|Get refresh->rev_project */
     	      strcpy( project,  refresh->rev_project);
    	     }
    	  }
     	/*"project: <%s>\n", project*/

	if (*rev_flag == 0)
    	  {
  	   if (refresh->act_catalog    != NULL) 
    	     {
	      /*|Get refresh->act_catalog */
     	      strcpy( catalog,  refresh->act_catalog);
    	     }
    	  }
	else
    	  {
  	   if (refresh->rev_catalog    != NULL) 
    	     {
	      /*|Get refresh->rev_catalog */
     	      strcpy( catalog,  refresh->rev_catalog);
    	     }
    	  }
     	/*"catalog: <%s>\n", catalog*/

	if (*rev_flag == 0)
    	  {
  	   if (refresh->act_partid    != NULL) 
    	     {
	      /*|Get refresh->act_partid */
     	      strcpy( partid,  refresh->act_partid);
    	     }
    	  }
	else
    	  {
  	   if (refresh->rev_partid    != NULL) 
    	     {
	      /*|Get refresh->rev_partid */
     	      strcpy( partid,  refresh->rev_partid);
    	     }
    	  }
     	/*"partid: <%s>\n", partid*/

	if (*rev_flag == 0)
    	  {
  	   if (refresh->act_revision    != NULL) 
    	     {
	      /*|Get refresh->act_revision */
     	      strcpy( revision,  refresh->act_revision);
    	     }
    	  }
	else
    	  {
  	   if (refresh->rev_revision    != NULL) 
    	     {
	      /*|Get refresh->rev_revision */
     	      strcpy( revision,  refresh->rev_revision);
    	     }
    	  }
     	/*"revision: <%s>\n", revision*/

	if (*rev_flag == 0)
    	  {
  	   if (refresh->act_filename    != NULL) 
    	     {
	      /*|Get refresh->act_filename */
     	      strcpy( filename,  refresh->act_filename);
    	     }
    	  }
	else
    	  {
  	   if (refresh->rev_filename    != NULL) 
    	     {
	      /*|Get refresh->rev_filename */
     	      strcpy( filename,  refresh->rev_filename);
    	     }
    	  }
     	/*"filename: <%s>\n", filename*/

  	return SUCCESS;
 }
