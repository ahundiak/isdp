/* $Id: GRoupi.I,v 1.2 2001/01/13 00:23:32 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc / GRoupi.I
 *
 * Description:
 *
 * This is just a copy of  GRoupi.I file. We need to dynamically load this file
 * to regain the toggle the permission validating process by using the defined
 * global static variable. In this process two functions have been written to
 * toggle the permission on and off, where needed.  Alwin 06/05/2000
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: GRoupi.I,v $
 *      Revision 1.2  2001/01/13 00:23:32  hans
 *      SP16 modifications
 *
 *      Revision 1.1  2001/01/13 00:04:51  hans
 *      SP16 modifications
 *
# Revision 1.1  2000/06/05  14:42:06  pinnacle
# Created: vds/emsfixes/grnuc/GRoupi.I by apazhani for Service Pack
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/05/2000      Alwin           Added two function to control the
 *					validation process.
 * -------------------------------------------------------------------*/

/*
H.Bequet                                                       GRoupi.I

ABSTRACT :
--------

This is the implementation file of the class GRoup.  This class
provides a group based protection mechanism for the objects.


HISTORY :
-------

   04/29/1988 : HGB - Creation Date
   06/04/1992 : EMS - change PATH_MAX to DI_PATH_MAX

*/

class implementation GRoup;

#include <string.h>
#include <stdio.h>

#include "OMerrordef.h"
#include "OMmacros.h"

#include "GRprims.h"


#include "OMprimitives.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"

#include "GRtypedef.h"
#include "GRdef.h"
#include "GRglob.h"

#define DEBUG
#include "DIdebug.h"

#include "DIomac.h"


from GRoups import init;
from GRoups import change_group;

#define offset 1300357585
#define high   3355201852
#define low    1300357706

#define OFF    0
#define ON     1

/* added to toggle the permission validating process. Alwin */
static int	VD_GRValidateDisabled;

method init ( GRint *status, type; GRchar *pword, *groupname )
{
  GRchar  name  [DI_PATH_MAX];
  GRobjid groupid;

  strcpy ( name, GR_G_root );

  *status = di$split ( pathname = groupname,
 	               name     = &(name[strlen (name)]) );

  *status = di$translate ( objname = name, p_objid = &groupid );
  if (*status == DIR_S_SUCCESS)
    *status = GR_E_NAME_DUP;
  else
  {
    /*"check that the type is valid : %d\n", type */
    if ((type == DIR_D_PRIVATE)||(type == DIR_D_READ)||(type == DIR_D_PUBLIC))
    {
      GRchar salt [3];

      me->type = type;

      salt[0] = groupname[0];
      salt[1] = groupname[strlen(groupname)-1];
      salt[2] = '\0';

      /*"salt === '%s'\n", salt */
      /*"from passwd === '%s'\n", pword */

      *status = GRpasswd ( pword, me->passwd, salt );
      /*"to the crypted '%s'\n", me->passwd */
    }
    else
      *status = GR_E_INVARG;

    if (*status == GR_S_SUCCESS)
    {
      /*"About ready to do an add_name for '%s'\n", name */
      *status = di$add_name ( objname = name,
                              objid   = my_id );

      if (*status != DIR_S_SUCCESS)
      {
        di$report_error (sts=*status, comment = "GRoup.add_group->di$add_name");
        *status = GR_E_ABORT;
      }
      else
	*status = GR_S_SUCCESS;
    }
  }

  return OM_S_SUCCESS;
}


method get_type ( GRint *type )
{
  *type = me->type;

  return OM_S_SUCCESS;
}


method change_passwd (GRint *status; GRchar *old_pword, *new_pword, *groupname)
{
  /*"old passwd === '%s'\n", old_pword */

  om_send ( GRoup.check_passwd ( status, old_pword, groupname ), my_id, my_id );

  if (*status == GR_S_SUCCESS)
  {
    GRchar salt [3];

    salt[0] = groupname[0];
    salt[1] = groupname[strlen(groupname)-1];
    salt[2] = '\0';

    /*"salt === '%s'\n", salt */
    /*"from passwd === '%s'\n", new_pword */

    *status = GRpasswd ( new_pword, me->passwd, salt );
    /*"to the crypted '%s'\n", me->passwd */
  }
  else
    *status = GR_E_PERMISSION;

  return OM_S_SUCCESS;
}


method check_passwd ( GRint *status; GRchar *passwd; GRchar *groupname )
{
  GRchar salt [3];

  /*"the passwd is    '%s'\n", passwd */
  /*"the groupname is '%s'\n", groupname */

  salt[0] = groupname[0];
  salt[1] = groupname[strlen(groupname)-1];
  salt[2] = '\0';

  /*"the salt is      '%s'\n", salt */
  *status = GR_match ( passwd, me->passwd, salt );

  return OM_S_SUCCESS;
}


/* The following entry points are the group primitives */

GRinit ( )
/*.GRinit */
{
  GRint  status;
  GRchar passwd [9];
  GRint  l1, l2;

  l1 = high - offset;
  /*|initialize the grouping scheme */

  memcpy ( passwd, (char *) &l1, sizeof ( GRint ) );
  l2 = low - offset;

  status = di$mkdir (dirname = ":groups" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "gr$init : di$mkdir is wrong" );

  memcpy ( (char *) &(passwd [sizeof ( GRint )]), (char *) &l2, sizeof ( GRint ) );

  status = gr$add_group ( groupname = "sys",
                          passwd = passwd, type = DIR_D_READ );
  if (status != GR_S_SUCCESS)
    gr$report_error (sts = status, comment = "gr$init : gr$add_group ( sys )");

  status = gr$add_group ( groupname = "usr", passwd = "", type = DIR_D_PUBLIC );
  if (status != GR_S_SUCCESS)
    gr$report_error (sts = status, comment = "gr$init : gr$add_group ( usr )");

  status = gr$add_group ( groupname = "ige", passwd = "IGE", type = DIR_D_READ );
  if (status != GR_S_SUCCESS)
    gr$report_error (sts = status, comment = "gr$init : gr$add_group ( usr )");

  status = gr$cg ( groupname = "sys", passwd = passwd, flag = 1 );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "gr$init : gr$cg ( sys )" );

  return GR_S_SUCCESS;
}


GRadd_group ( groupname, type, passwd )
              GRchar *groupname	/* The new group name			IN  */;
              GRint  type	/* The new group type			IN  */;
              GRchar *passwd	/* The new group password (optional)	IN  */;
/*.GRadd_group */
{
  GRint      status, om_status;
  GRobjid    groupid;
  GRchar     pword [GR_passwd_max];

  if ( passwd )
    strncpy (pword, passwd, GR_passwd_max) [GR_passwd_max - 1] = '\0';
  else
    strcpy (pword, "");

  /*"group name   = '%s'\n", groupname */
  /*"group type   = '%d'\n", type      */
  /*"group passwd = '%s'\n", pword     */
  /*|construct the object ... */

  om_status = om$construct( osnum     = OM_Gw_TransOSnum_0,
                            classname = "GRoup",
	                    p_objid   = &groupid,
		            msg = message GRoup.init (&status, type, pword,
						      groupname));
  if (om_status != OM_S_SUCCESS)
  {
    om$report_error ( sts = om_status );
    status = GR_E_ABORT;
  }
  else
    if (status != GR_S_SUCCESS)
    {
      /*|delete the object */
      om_send_for ( Root.delete ( 1 ), NULL_OBJID, groupid, OM_Gw_TransOSnum_0 );
    }

  return status;
}


%safe
static int GRValidateDisabled = 0;
%endsafe


void GRDisableValidate ()
/*
 * This routine disables the validation
 */
{
  GRValidateDisabled = 1;
}


void GREnableValidate ()
/*
 * This routine enables the validation
 */
{
  GRValidateDisabled = 0;
}


GRvalidate ( type, groupind )
             GRint type 	/* The type of operation		IN  */;
             GRint groupind	/* The group index			IN  */;
/*.GRvalidate */
{
  GRint      status;
  GRint      group_type;
  GRobjid    groupid;
  GRspacenum osnum;

  if (GRValidateDisabled)
    return GR_S_SUCCESS;

  //static variable used for switch off the validating process. Alwin
  if( VD_GRValidateDisabled == 0 )
	GR_validate = OFF;

  if (GR_validate == ON)
  {

    GR_validate = OFF;

    if ((GR_cur_gr_ind == groupind) || (GR_cur_gr_ind == GR_system))
    {
      /*"group index is cur or sys -=> '%d'\n", groupind */
      if ((type == GR_R_READ) || (type == GR_R_WRITE))
        status = GR_S_SUCCESS;
      else
        status = GR_E_INVARG;
    }
    else
    {
      /*"This is the current group index '%d'\n", GR_cur_gr_ind */

      status = di$index ( dirname = GR_G_root, index = groupind,
                          p_objid = &groupid, p_osnum = &osnum );

      if (status == DIR_S_SUCCESS)
      {
        om_send_for ( GRoup.get_type ( &group_type ), NULL_OBJID, groupid, osnum );

        /*"current group index = '%d'\n", GR_cur_gr_ind  */
        /*"current group type  = '%d'\n", GR_cur_gr_type */
        /*"check group index   = '%d'\n", groupind       */
        /*"check group type    = '%d'\n", group_type     */

        switch ( type )
        {
          case GR_R_READ  :   status = (group_type == DIR_D_PRIVATE)
                                     ? GR_E_PERMISSION : GR_S_SUCCESS;
		              break;

          case GR_R_WRITE :   status = (group_type == DIR_D_PUBLIC)
                                     ? GR_S_SUCCESS : GR_E_PERMISSION;
		              break;

          default         :   status = GR_E_INVARG;
        }
      }
      else
        status = GR_E_ABORT;
    }
  }
  else
  {
    /*"GR_validate was turned OFF\n" */
    status = GR_S_SUCCESS;
  }

  GR_validate = ON;

  return status;
}


GRpwg ( groupname, p_groupid, p_osnum, p_groupind )
        GRchar     *groupname	/* The current group name		OUT */;
        GRspacenum *p_osnum	/* The current group osnum		OUT */;
        GRobjid    *p_groupid	/* The current group object id		OUT */;
        GRint      *p_groupind	/* The current group index		OUT */;
/*.GRpwg */
{
  /*|getting the pwg information */

  /*"groupname : %d\n", (GRint) groupname */
  if ( groupname )
    strcpy ( groupname, GR_cur_gr_name );

  /*"p_osnum : %d\n", (GRint) p_osnum */
  if ( p_osnum )
    *p_osnum = GR_cur_gr_os;

  /*"p_groupid : %d\n", (GRint) p_groupid */
  if ( p_groupid )
    *p_groupid = GR_cur_gr_id;

  /*"p_groupind : %d\n", (GRint) p_groupind */
  if ( p_groupind )
    *p_groupind = GR_cur_gr_ind;

  return GR_S_SUCCESS;
}


GRcg ( groupname, passwd, p_osnum, p_groupid, p_groupind, flag )
       GRchar     *groupname	/* The current group name		IN  */;
       GRchar     *passwd	/* The current group password		IN  */;
       GRspacenum *p_osnum	/* The current group osnum      	OUT */;
       GRobjid    *p_groupid	/* The current group object id		OUT */;
       GRint      *p_groupind	/* The current group index 		OUT */;
       GRint      flag         	/* flag = 0, update GR_prev_gr_name     IN  */;
/*.GRcg */
{
  GRint      status, test;             /* test = 1, check password */
  GRchar     pword   [GR_passwd_max];
  GRchar     gr_name [DI_PATH_MAX];
  GRobjid    groupid;
  GRspacenum osnum;

  if ( passwd )
    strncpy (pword, passwd, GR_passwd_max) [GR_passwd_max - 1] = '\0';
  else
    strcpy (pword, "");

  if ( ! flag )
    flag = 0;

  if ( groupname )
  {
    GRchar name  [DI_PATH_MAX];
    GRint  length;

    strcpy ( gr_name, groupname );
   /*"change to groupname = '%s'\n", gr_name */
   /*"with the passwd     = '%s'\n", pword   */
   /*"the current group   = '%s'\n", GR_cur_gr_name  */
   /*"the previous group  = '%s'\n", GR_prev_gr_name */

    if ( strcmp ( gr_name, "-" ) )
      test = 1;
    else
    {
      /*"we have a cg - on our hands\n" */
      if ( strcmp ( GR_prev_gr_name, "sys" ) )
      {
        /*"cg -   now becomes cg '%s'\n", GR_prev_gr_name */
	strcpy ( gr_name, GR_prev_gr_name );
      }
      else
      {
        /*"cg -   was cg 'sys', now is cg '%s'\n", GR_cur_gr_name */
	strcpy ( gr_name, GR_cur_gr_name );
      }
      flag = 0;
      test = 0;
    }

    DIstrcpy ( name, GR_G_root );
    status = di$split ( pathname = gr_name,
		        name     = &(name[length = strlen (name)]) );

    status = di$translate ( objname = name,
			    p_objid = &groupid, p_osnum = &osnum );
    if (status == DIR_S_SUCCESS)
    {
      if (GR_cur_gr_ind != GR_system)
      {
	if ( test )
	{
          om_send_for ( GRoup.check_passwd (&status, pword, &name[length]),
                        NULL_OBJID, groupid, osnum );
	}
	else
	{
	  /*"CG -   doesn't check passwd\n" */
	  status = GR_S_SUCCESS;
	}
      }
      else
      {
	/*"CG from sys doesn't check passwd\n" */
	status = GR_S_SUCCESS;
      }

      if (status == GR_S_SUCCESS)
      {
	GRint index;

	/*|let's find the index */
	status = di$unindex ( dirname = GR_G_root,
                              objid   = groupid, p_index = &index );

	if (status == DIR_S_SUCCESS)
	{
	  if ( ! flag )
	  {
            status = gr$pwg ( groupname = GR_prev_gr_name );
	    /*"previous group now set to '%s'\n", GR_prev_gr_name */
	  }

	  strcpy ( GR_cur_gr_name, &(name [length]) );
	  /*"current group now set to '%s'\n", GR_cur_gr_name */
	  GR_cur_gr_os  = osnum;
	  GR_cur_gr_id  = groupid;
	  GR_cur_gr_ind = index;

          om_send_for ( GRoup.get_type ((GRint *) &GR_cur_gr_type ),
                        NULL_OBJID, groupid, osnum );

          status = gr$pwg ( p_osnum    = p_osnum,
		            p_groupid  = p_groupid,
		            p_groupind = p_groupind );
        }
	else
	  status = GR_E_ABORT;
      }
      else
        status = GR_E_PERMISSION;
    }
    else
    {
      /*"the name I tried to translate was '%s'\n", name */
      status = GR_W_NAME_NOT_FOUND;
    }
  }
  else
    status = GR_E_INVARG;

  return status;
}


GRchange_passwd ( name, old_passwd, new_passwd )
                  GRchar *name       /* The group name			IN  */;
	 	  GRchar *old_passwd /* The old group password		IN  */;
                  GRchar *new_passwd /* The new group password		IN  */;
/*.GRchange_passwd */
{
  GRint      status;
  GRchar     old_pword [GR_passwd_max];
  GRchar     new_pword [GR_passwd_max];
  GRspacenum osnum;
  GRobjid    groupid;
  GRint      length;
  GRchar     name2 [DI_PATH_MAX];

  if ( old_passwd )
    strncpy (old_pword, old_passwd, GR_passwd_max) [GR_passwd_max - 1] = '\0';
  else
    strcpy (old_pword, "");

  if ( new_passwd )
    strncpy (new_pword, new_passwd, GR_passwd_max) [GR_passwd_max - 1] = '\0';
  else
    strcpy (new_pword, "");

  /*"group name = '%s'\n", name       */
  /*"old passwd = '%s'\n", old_pword  */

  DIstrcpy ( name2, GR_G_root );
  status = di$split ( pathname = name,
                      name     = &(name2[length = strlen (name2)]) );

  status = di$translate (objname = name2, p_osnum = &osnum, p_objid = &groupid);
  if (status != DIR_S_SUCCESS)
    status = GR_W_NAME_NOT_FOUND;
  else
  {
    om_send_for ( GRoup.change_passwd ( &status, old_pword, new_pword,
                                        &name2[length] ),
                  NULL_OBJID, groupid, osnum );
  }

  return status;
}


GRreport_error ( status, comment )
                 GRint  status	  /* Error status			IN  */;
	 	 GRchar *comment  /* The comment to be printed		IN  */;
/*
   This function prints an error message corresponding to the status.
*/
/*.GRreport_error */
{
  if (comment) fprintf ( stderr, "%s\n", comment );
  fprintf ( stderr, "Group Report Error (%d) ", status );

  if (!(status & 0x7)) fprintf ( stderr, "WARNING " );
  if (status & SEVE) fprintf ( stderr, "SEVERE " );
  if (status & ERRO) fprintf ( stderr, "ERROR " );
  if (status & SUCC) fprintf ( stderr, "SUCCESS " );
  fprintf ( stderr, ": " );

  switch ( status)
  {
    case  GR_S_SUCCESS        : fprintf ( stderr,
                                          "Operation Succesfully Completed\n" );
                                 break;
    case  GR_E_ABORT          : fprintf ( stderr,
                                          "Operation Aborted\n" );
                                 break;
    case  GR_E_NAME_DUP       : fprintf ( stderr,
                                          "Group Name Duplicated\n" );
                                 break;
    case  GR_W_NAME_NOT_FOUND : fprintf ( stderr,
                                          "Group Name NOT Found\n" );
                                 break;
    case  GR_E_INVARG         : fprintf ( stderr,
                                          "Invalid Argument\n" );
                                 break;
    case  GR_E_OVFLOW         : fprintf ( stderr,
                                          "Overflow in Name\n" );
                                 break;
    case  GR_E_PERMISSION     : fprintf ( stderr,
                                          "Permission Violation\n" );
                                 break;
    case  GR_E_PRIVATE        : fprintf ( stderr,
                                          "Private Group Protection\n" );
                                 break;
    case  GR_E_READ_ONLY      : fprintf ( stderr,
                                          "Read_Only Group Protection\n" );
                                 break;
    case  GR_E_PASSWD         : fprintf ( stderr,
                                          "Invalid Password\n" );
                                 break;
    case  GR_W_NOT_IMPL       : fprintf ( stderr,
                                          "Feature NOT Implemented\n" );
                                 break;

    default                   : fprintf ( stderr,
                                          "Unknown Error Status\n" );
  }

  return GR_S_SUCCESS;
}


GRpasswd ( passwd, crypted, salt )
           GRchar *passwd	/* The password to be encrypted		IN  */;
           GRchar *crypted	/* The result of encryption		OUT */;
           GRchar *salt		/* A 2-character string 		IN */;
/*
   This function is used to encrypt a password.
*/
/*.GRpasswd */
{
  GRint  i, length = strlen ( passwd );

  /*"passwd  === '%s'\n", passwd  */
  /*"salt    === '%s'\n", salt    */

  for (i = 0; i < length; i++)
  {
    crypted [i] = ((passwd [i] - 36) * 53 + (salt [0] * 24) - salt [1]) % 128;
    if (!crypted [i])
      crypted [i] = salt [i % 2];
  }

  crypted [i] = '\0';
  /*"crypted === '%s'\n", crypted */

  return GR_S_SUCCESS;
}


GR_match ( candidate, crypted, salt )
          GRchar *candidate	/* The password to be encrypted		IN  */;
          GRchar *crypted	/* The crypted password			IN  */;
          GRchar *salt		/* A 2-character string 		IN  */;
/*
   This function is used to check if candidate can be the encrypted password.
*/
/*.GR_match */
{
  GRchar tmp [GR_passwd_max];
  GRint  status;

  /*|encrypt the candidate */
  GRpasswd ( candidate, tmp, salt );

  /*|check the result */
  if (strcmp ( crypted, tmp ))
    status = GR_E_PASSWD;
  else
    status = GR_S_SUCCESS;

  return status;
}


GRchange_group ( GRchar * objname, GRobjid objid, GRspacenum osnum,
                 GRobjid new_gr_id,
                 GRchar * new_gr_name, GRchar * new_passwd, GRchar * old_passwd )
/*
    This function is used to change an object's group to the current group
*/
/*.GRchange_group */
{
  GRint      status, index, type;
  GRchar     old_pword [GR_passwd_max];
  GRchar     name [DI_PATH_MAX];
  GRobjid    id;
  GRspacenum object;

  if (old_passwd)
    strcpy (old_pword, old_passwd);
  else
    strcpy (old_pword, "");

  /*|Now entering GRchange_group */
  /*"objid      = '%d'\n", objid     */
  /*"osnum      = '%d'\n", osnum     */
  /*"old_passwd = '%s'\n", old_pword */
  if (objname)
    /*"objname    = '%s'\n", objname */

  if ((objname) && (objid == NULL_OBJID))
  {
    /*"only objname was given '%s'\n", objname */
    status = di$translate ( objname = objname,
                            p_objid = &objid, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      status = GR_W_NAME_NOT_FOUND;
    else
      status = GR_S_SUCCESS;
  }

  if (objid == NULL_OBJID)
  {
    /*|you forgot to give me the object information */
    status = GR_E_INVARG;
  }
  else
    status = GR_S_SUCCESS;

  if (status == GR_S_SUCCESS)
  {
    if ((new_gr_id) && (! new_gr_name))
    {
      /*"only new group id specified '%d'\n", new_gr_id */
      status = di$untranslate ( objname = new_gr_name,
                                objid = new_gr_id, osnum = OM_Gw_TransOSnum_0 );
      if (status != DIR_S_SUCCESS)
        status = GR_W_NAME_NOT_FOUND;
      else
        status = GR_S_SUCCESS;
    }

    if (new_gr_name)
    {
      /*|store the current group information */
      status = gr$pwg ( groupname = name, p_groupid = &id,
		        p_groupind = &index, p_osnum = &object );

      om_send_for ( GRoup.get_type ( &type ),
                    NULL_OBJID, GR_cur_gr_id, GR_cur_gr_os );

      if (status == GR_S_SUCCESS)
      {
        /*"new_gr_name is '%s'\n", new_gr_name */
        status = gr$cg ( groupname = new_gr_name,
			 passwd = new_passwd, flag = 1 );
      }
    }
    else
    {
      /*|nothing new was specified */
      status = GR_S_SUCCESS;
    }

    if (status == GR_S_SUCCESS)
    {
      /*"send change_group msg for objid '%d',osnum '%d'\n", objid, osnum */

      om_send_for ( GRoups.change_group ( &status, old_pword ),
                    NULL_OBJID, objid, osnum );

      if ((status == GR_S_SUCCESS) && (new_gr_name))
      {
	/*|restore the environment */
	strcpy (GR_cur_gr_name, name);
	GR_cur_gr_ind  = index;
	GR_cur_gr_id   = id;
	GR_cur_gr_os   = object;
	GR_cur_gr_type = type;
      }
    }
  }

  return status;
}

/*
 * Call the function VD_GRDisableValidate() to switch off the validating
 * or permission check code.
 * Call the function VD_GREnableValidate() to switch on the permission
 * validating code. Alwin
 */
void VD_GRDisableValidate ()
{
  VD_GRValidateDisabled = 0;
}

void VD_GREnableValidate ()
{
  VD_GRValidateDisabled = 1;
}

end implementation GRoup;
