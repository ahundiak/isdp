/*
-------------------------------------------------------------------------------
Name:			OMobjspace.c
Author:			Chuck Puckett
Creation Date:		9-sep-1985
Operating System(s):	Unix SYSV, v2
Abstract:

This module contains routines to manage object Space for OM.

Revision History:

cgp001	13-oct-1985	change all flag (OMuint) references to "defined"
			style

cgp002	31-oct-1985	change object header initialization

cgp003	12-nov-1985	Begin to really make OS work.

cgp004	16-nov-1985	Add write, pass, delete methods. Add filed OS
			capability. fix bug that failed to create classid
			and relid maps.

cgp005	26-nov-1985	Make OS's "real" classes. Put only support routines
			here. Including construct routines.

gja001	14-mar-1986	Add code to change OS name (OM_change_OS_name)

cgp006	21-apr-1986	Make construct_OS_by_classid test for VLA mods after
			successful construct.

cgp007	22-apr-1986	Make dissolve_ISOs and resolve_ISOs do real work.

ems001  21-may-1987     Removed make_message calls.
-------------------------------------------------------------------------------
*/

#include	"OMobjectcomm.h"
#include 	"OMmetaclass.h"
#include 	"UNIXerrdef.h"
#include	<stdio.h>
#include	<errno.h>
#include	<string.h>
#if defined (NT)
#include        <stdlib.h>
#endif

extern void             OM_extract_filename();
extern void             OM_get_time();

extern	OM_S_OBJID	OM_GO_current_MOSD;
extern	OMuword		OM_Gw_first_OS_avail;
extern	OMuword		OM_Gw_maxOS;
extern  OMuword         OMObjSpace_OPP_change_name_method_index;


/*
-------------------------------------------------------------------------------

Routine Name:	som_convert_os_name_to_number
		som_convert_os_number_to_name
Abstract:

perform the indicated conversions.

Sample Invocation:

	som_convert_os_name_to_number (name, p_number)
	som_convert_os_number_to_name (number, name)

Entry Variable Description:

char		*name		name array (should be dimensioned 
  				OM_K_MAXOS_NAME chars)
OMuword		*p_number	place to put result number
OMuword		number		Objspace number

-------------------------------------------------------------------------------
*/

int som_convert_os_name_to_number (name, OSnum)
char		*name;
OMuword		*OSnum;
{
  int	ii;

  if (name == NULL)
  {
    return (OM_E_INVARG);
  }
  
  if (NULL == strlen (name))
  {
    return (OM_E_INVARG);
  }
  
  for (ii=0; (OMuword) ii < OM_Gw_maxOS; ii++)
  {
    if ( OM_GA_OSDs[ii]		&&
	(!strcmp (OM_GA_OSDs[ii]->name, name))
				&&
	(OM_GA_OSDs[ii]->flags & OM_OSD_inuse))
    {
      *OSnum = ii;
      return (OM_S_SUCCESS);
    }
  }
  return (OM_E_NOSUCHOS);

}

int som_convert_os_number_to_name (OMuword OSnum, char * name)
{

  if ((OSnum <= OM_Gw_maxOS)
    	     &&
       OM_GA_OSDs[OSnum]
	     &&
      (OM_GA_OSDs[OSnum]->flags & OM_OSD_inuse))
  {
    strcpy (name, OM_GA_OSDs[OSnum]->name);
    return (OM_S_SUCCESS);
  }
  return (OM_E_NOSUCHOS);
}

int som_convert_internal_osname_to_number (char *name, OMuword * OSnum)
{

  int				ii;
  
  if (NULL == strlen (name))
  {
    return (OM_E_INVARG);
  }
  
  for (ii=0; (OMuword) ii < OM_Gw_maxOS; ii++)
  {
    if ((OM_GA_OSDs[ii] != NULL) 
		&&
	(!strcmp (OM_GA_OSDs[ii]->InternalName, name)))
    {
      *OSnum = ii;
      return (OM_S_SUCCESS);
    }
  }
  return (OM_E_NOSUCHOS);
}

int som_convert_number_to_internal_osname (OMuword OSnum, char * name)
{

  if ((OSnum <= OM_Gw_maxOS)
    	     &&
      (OM_GA_OSDs[OSnum] != NULL))
  {
    strcpy (name, OM_GA_OSDs[OSnum]->InternalName);
    return (OM_S_SUCCESS);
  }
  return (OM_E_NOSUCHOS);
}

/*
-------------------------------------------------------------------------------
Routine Name:	OM_calcOShdr_chksum
Abstract:

calculate OS file header checksum.

-------------------------------------------------------------------------------
*/

OMuint	OM_calcOShdr_chksum (OMhdr, size)

OMuint				*OMhdr;	/* pretend its an array of LWs */
OMuint				size;

{
  int    ii;
  OMuint sum;
  
  sum = 0;
  size = size >> 2;		/* make byte count LW count */
  for (ii=0; ii < (int)(size-2); ii++)
    sum = OMhdr[ii] + sum;
  return (sum);
}


/*
-------------------------------------------------------------------------------
Routine Name:	OM_make_internal_OS_name
Abstract:

 Generate an internal OS name based on OS name + date/time

-------------------------------------------------------------------------------
*/

void OM_make_internal_OS_name (in_name, out_name)

char				*in_name, *out_name;

{
  char		filename[OM_K_MAXINTOSNAME_LEN*2];
  int		fname_len;
  
/* get filename (or OS name), and leave space for separator, time, 
   random number, and NULL terminator */

  OM_extract_filename (in_name, filename,OM_K_MAXINTOSNAME_LEN-12-4-2-1);
  fname_len = strlen(filename);
  filename[fname_len] = '~';
  OM_get_time (&(filename[fname_len+1]));
  sprintf (&(filename[fname_len+1+12]), 
    "~%04X", rand ());
  filename [fname_len+1+12+1+4] = NULL;
  strncpy (out_name, filename, OM_K_MAXINTOSNAME_LEN-1);
  out_name [OM_K_MAXINTOSNAME_LEN-1] = NULL;	/* insure numm terminated */
}



/*
-------------------------------------------------------------------------------
Routine Name:	som_get_os_senddepth

Abstract:

Determine send depth of arbitrary Object Space. To get "my own OS" send
depth, use macro GET_MY_OS_SENDEPTH.

Sample Invocation:

	sts = om$get_os_senddepth (osnum=OSnum, p_depth=&depth);

Entry Variable Description:

OMuword		OSnum		Osnumber to get depth
int		depth		returned depth

-------------------------------------------------------------------------------
*/

int	som_get_os_senddepth (OMuword OSnum, OMuint *depth)
{
  OM_p_OSD	osd;
  OM_p_LCD	lcd;
  OM_p_PCD	pcd;
  int		i;

  osd = OM_GA_OSDs[OSnum];

  if ((OSnum <= OM_Gw_maxOS)
    	     &&
      (osd->flags & OM_OSD_inuse))
  {
    *depth = 0;
    /*  LOOP THRU ALL LOGICAL CLUSTER'S PHYSICAL CLUSTERS & SUM  */
    for(i=0; i<(int) osd->ClustersSize; i++)
    {
      lcd = osd->Clusters[i];
      if(! lcd)  continue;	/* UNUSED CLUSTER NUMBER */
      pcd = (OM_p_PCD)lcd->pcdq_lh.next;
      while(pcd != (OM_p_PCD)&(lcd->pcdq_lh.next))
      {
        *depth += (pcd->p_csd->PreSendDepth - pcd->p_csd->PostSendDepth);
        pcd = (OM_p_PCD)pcd->pcdq.next;
      }
    }
    return (OM_S_SUCCESS);
  }
  return (OM_E_NOSUCHOS);
}


/*
-------------------------------------------------------------------------------
Routine Name:	som_change_os_name
		som_change_os_name_by_name
Abstract:
	  Change the name of the given object space.  It must not have an
	associated ISO directory and if the given file name represents an
	existing file the overwrite flag must be turned on (OM_e_overwrite).
	The user has the option of specifying OS number or name by calling
	the appropriate routine listed above.

Sample Invocation:

	som_change_os_name( OSnum, name, overwrite)
	som_change_os_name_by_name( curr_name, name, overwrite)

Entry Variable Description:

OMuword	 	OSnum		Object Space Number
char		*name		new OS name (array should be dimensioned 
  				OM_K_MAXOS_NAME chars)
char		*curr_name	current OS name (array should be dimensioned 
  				OM_K_MAXOS_NAME chars)
OM_e_OVRWRT_FLG	overwrite	Flag which indicates whether or not to 
				overwrite the OS represented by the given
				name if it already exists

Exit Variable Description:

	Function Value:		OM_S_SUCCESS
				OM_E_NOSUCHOS
				OM_W_ISODIRONOS
				OM_E_FILEEXISTS
				OM_I_FILEOVRWRTN

Modules Invoked:

	OM_make_internal_OS_name

Notes:

	OM_e_OVRWRT_FLG::	OM_e_overwrite	-> overwrite OS if exists
				OM_e_no_ovrwrt  -> do not overwrite

Change History:

cgp001	24-apr-1986	OM3.2	Make this always happen if this is
				transient OS
-------------------------------------------------------------------------------
*/

int som_change_os_name (
OMuword		OSnum,
char		*name,
OM_e_OVRWRT_FLG	overwrite)
{

int sts;
OM_S_MESSAGE change_name_msg;

struct {
char *name;
OM_e_OVRWRT_FLG overwrite;
 } change_name_arg;

  /* verify good object space .. */

  if ((OSnum > OM_Gw_maxOS) || (OM_GA_OSDs[OSnum] == NULL))
   {
    return (OM_E_NOSUCHOS);
   }

  /* make a change name message */
  change_name_arg.name = name;
  change_name_arg.overwrite = overwrite;
  
  change_name_msg.select.DefClassid = OM_K_OMOBJSPACE_ACTCLASSID;
  change_name_msg.select.ReqClassid = OM_K_OMOBJSPACE_ACTCLASSID;
  change_name_msg.select.FuncIndex  = OMObjSpace_OPP_change_name_method_index;
  change_name_msg.size              = sizeof(change_name_arg);
  change_name_msg.p_arglist         = (char *)&change_name_arg;

  /* send a change_name message to the oso of the target os */

   return(sts = om$send(targetos = OSnum,
			 targetid = OM_GA_OSDs[OSnum]->OSO_Oid,
			 senderid = 0,
			 msg = &change_name_msg));

}


int som_change_os_name_by_name (curr_name, name, overwrite)

char		*curr_name,*name;
OM_e_OVRWRT_FLG	overwrite;
{

 OMuword	OSnum;
 int	sts;

 if(!(1&(sts=om$os_name_to_number(osname=curr_name,p_osnum= &OSnum))))
  {
   return(sts);
  }

  return( om$change_os_name( osnum=OSnum, new_osname=name, overwrite=overwrite) );

}

/* this routine will allow users to take an osnum and get the associated objid
/* of the oso 
*/
int som_osnum_to_oso_objid(OMuword osnum, OM_p_OBJID p_objid)

{
	if((osnum > OM_Gw_maxOS) || (OM_GA_OSDs[osnum] == NULL))
		 return(OM_E_NOSUCHOS);

	*p_objid = OM_GA_OSDs[osnum]->OSO_Oid;
	return(OM_S_SUCCESS);

}

