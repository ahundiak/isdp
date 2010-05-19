/* $Id: VDS_project.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VDS_project.C
 *
 * Description:
 * VDS project functions
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDS_project.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
 * Revision 1.2  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 * 	11/20/92 Roger Malmgren created
 *	04/19/96   tlb		Add prototypes
 *
 * -------------------------------------------------------------------*/


#include 	<stdio.h>
#include	<string.h>

#include 	"vdbmacros.h" 
#include	"v_risproto.h"

extern char VDSproject_name[];


/***********************************************************************/
/* VDSget_projectno - Get current project number */
int VDSget_projectno( prj_no )

int  *prj_no;		/* Project number         (O) */

/* Returns 1 if OK
           0 if error
*/
{
  char  search[81];
  char  proj_no[25];
  int   sts;
  char  **buf;
  int   num;
  int   n_attr;

  *prj_no = 0;

  /* ---- Get prj_no from table vds_project */

  if (!strcmp(VDSproject_name,"") || VDSproject_name == NULL) return 0;

  sprintf(search, "prj_name = '%s'",VDSproject_name);
  n_attr = 1;
  sts =
  vdb$RisSelect(  select     =    "prj_no",
                  table_name =    "vds_proj",
                  where      =    search,
                  order      =    NULL,
                  group      =    NULL,
                  numselect  =    n_attr,
                  p_numrows  =    &num,
                  p_buffer   =    &buf );
 
  if(sts != 1 || num <= 0) return 0;

  vdb$RisExtractValue (  nbrows    =    num,
                         nbcolumns =    n_attr,
                         buffer    =    buf,
                         row       =    0,
                         column    =    0,
                         value     =    proj_no);

  sscanf(proj_no,"%d",prj_no);
  vdb$RisFreeBuffer (  buffer   =    buf,
                       size     =    n_attr * num);

  return 1;
}
