/* $Id: VDSver_login.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VDSver_login.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSver_login.C,v $
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
 * Revision 1.1  1995/12/20  19:48:06  pinnacle
 * Created: vdris/imp/VDSver_login.C by jwfrosch for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	12/20/95    HF		Added VDdebug.h & __<fnc. calls>
 *					(Intel Solaris database problem)
 *	04/19/96   tlb		Add prototypes
 *
 * -------------------------------------------------------------------*/

#include        <stdio.h>
#include	<string.h>
#include        <PDUerror.h>
#include        <PDUuser.h>
#include	"VDSris_def.h"
#include	"VDdebug.h"
#include	"v_risproto.h"

//#define		VD_DEBUG	1


extern  struct  PDUuser         *user;
extern  int  VD_PDU_present;
extern  char VDSenvir_name[];
extern  char VDSproject_num[];

/*-------------------------------------------------------------------------*/
int VDSverify_login ()
{
   /***************************************************************************/
   /*                                                                         */
   /*   This routine checks to see if a user has logged in to VDS             */
   /*   and have selected a VDS project.                                      */
   /*   If so user->username contains a username and VDSproject_name contains */
   /***************************************************************************/

/*
   if (user->username == 0 || !strcmp(user->username, "") || user->passwd == 0 || !strcmp(user->passwd, ""))
   {
       return PDM_E_FAILURE;
   }
   else
   {
      if (VD_PDU_present) sprintf(VDSenvir_name,"pdme_%s",user->environment);
   }
   return PDM_S_SUCCESS;
*/
  __enterFunction ( name = "VDSverify_login" );

  __printf ( "VD_PDU_present = %d"  , `VD_PDU_present` );
  __printf ( "VDSenvir_name  = <%s>", `VDSenvir_name` );
  __printf ( "user->username = %#x ", `user->username` );
  __printf ( "user           = %#x ", `user` );

   if (VD_PDU_present)
   {
      if (user == NULL)
      {
  __exit_error_Function ( name = "VDSverify_login");
	return PDM_E_FAILURE;
      }

//         user = (struct PDUuser *) malloc (sizeof(struct PDUuser));

      if (user->username == NULL /*|| !strcmp(user->username, "") || user->passwd == 0 || !strcmp(user->passwd, "")*/ )
      {
  __exit_error_Function ( name = "VDSverify_login");
          return PDM_E_FAILURE;
      }
      else if ( strcmp(user->username, "") == 0 )
      {
  __exit_error_Function ( name = "VDSverify_login" );
          return PDM_E_FAILURE;
      }
      else
      {
         sprintf(VDSenvir_name,"pdme_%s",user->environment);
  __printf ( "user->username = <%s>, user->environment = <%s>", `user->username, user->environment` );
      }
   }
   else
   {
      if (VDSenvir_name == 0 || !strcmp(VDSenvir_name, ""))
      {
  __exit_error_Function ( name = "VDSverify_login" );
          return PDM_E_FAILURE;
      }
   }

  __exitFunction ( name = "VDSverify_login" );

   return PDM_S_SUCCESS;
}
