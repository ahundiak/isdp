/*
---------------------------------------------------------------------------

	Name:			OMsupport.c
	Author:			Chuck Puckett
	Creation Date:		24-aug-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	This module contains those routines usually classified as
	"miscellaneous".

	Revision History:  

	vwl001	jul-10-1986	change OM_report_error to som_report_error

       	ems001	feb-24-1986	Added support for UNIX system errors
                               	in OM_report_error.  Also added the
                               	include for UNIXerrdef.h

      	kek001	mar-23-1986  	removed minor channel
			     	reference, changed loop in calloc

       	ems002  mar-24-1986  	made OM_calloc call calloc 
                                added OM_report_version

	kek002  apr-15-1985  	change OM_areport_error to OM_report_error

	cgp001	21-apr-1986	OM3.2 mods. Fix bug in construct object
				so that we detect and fixup any modified VLA
				that may have been modified in construct
				routine. Also,  make OM_delete_object
				ALWAYS succeed.

	plh001  21-apr-1986	OM3.2. Copy_me now works for objects with
				expanded VLAs.

	jkm001  24-jun-1986	Move all the construct stuff into OMconstruct.c

	jaj001  07-jul-1986	Added OM_E_CLASS_CHKSUM_MISMATCH warning.

        rme001  22-apr-1987     Change make neighbor to accept an unknown
                                message return as success.  (OMTag and
                                OMTagCon objects can now be on the same
                                channel as group objects.)

        ems003  21-may-1987     Removed make_message calls.

        rme002  10-aug-1987     Removed declaration of calloc in som_calloc.
				This declaration made the function ptr a 
				local variable.

	geo001	14-dec-1987	OM4.5 clustering changes.

	saw001	8-sep-1988	Add som_getClusterFromObject.

	hb001	14-jun-1990	Added Henri's make-message cache for
				speed during Exnum/COB initialization.
---------------------------------------------------------------------------
*/

#define 	OM_DEFINE_ERRMSG 	1	/* expand OM error messages */
#define         UNIX_D_DEFINE_ERRMSG    1       /* expand UNIX error mesages*/ 

#include 	"OMobjectcomm.h"
#include        "OMspecify.h"
#include        "OMrelation.h"
#include        "OMintprims.h"
#include 	"OMmetaclass.h"
#include        "UNIXerrdef.h"
#include	<stdio.h>
#include	<string.h>
#include        "OMDB.h"
#include        <errno.h>

extern   OMuword  OM_Gw_major_version;
extern   OMuword  OM_Gw_minor_version;
extern   OMuword  OMGroup_OPP_my_oid_method_index;
extern	 OM_S_CSD *OM_GA_CSDarray;



/*
-------------------------------------------------------------------------------
Abstract:

 This routine reports OM error messages on stdout.

---------------------------------------------------------------------------
*/

void som_report_error (sts)

OMulong	sts;	/* the OM status code, defined in OMerrordef.h */

{
  FILE      *output;
  
  if (OM_Gf_errToStdout) output = stdout;
  else output = stderr;
   
  fprintf (output, "Error status = %x, \n", sts);

  switch (sts)
  {
  case OM_S_SUCCESS:
    fprintf (output, "OM-S-SUCCESS, Operation successfully completed.\n");
    break;
  case OM_W_UNKNOWN_MSG:
    fprintf (output, "%s\n", OM_erm_UNKNOWN_MSG);
    break;
  case  OM_E_OBJECT_OVERSIZED:
    fprintf (output, "%s\n",  OM_E_erm_OBJECT_OVERSIZED);
    break;
  case OM_E_OBJECT_LOCKED:
    fprintf (output, "%s\n", OM_erm_OBJECT_LOCKED);
    break;
  case OM_I_STOP_SENDING:
    fprintf (output, "%s\n", OM_erm_STOP_SENDING);
    break;
  case OM_E_NO_RELATION:
    fprintf (output, "%s\n", OM_erm_NO_RELATION);
    break;
  case OM_F_BUGCHECK:
    fprintf (output, "%s\n", OM_erm_BUGCHECK);
    break;
  case OM_E_NOTIMPL:
    fprintf (output, "%s\n", OM_erm_NOTIMPL);
    break;
  case OM_E_NODYNMEM:
    fprintf (output, "%s\n", OM_erm_NODYNMEM);
    break;
  case OM_W_CLASS_EXISTS:
    fprintf (output, "%s\n", OM_erm_CLASS_EXISTS);
    break;
  case OM_E_NOPARENT:
    fprintf (output, "%s\n", OM_erm_NOPARENT);
    break;
  case OM_E_BADCLASSNAME:
    fprintf (output, "%s\n", OM_erm_BADCLASSNAME);
    break;
  case OM_E_TOOMANYCLASSES:
    fprintf (output, "%s\n", OM_erm_TOOMANYCLASSES);
    break;
  case OM_E_NO_OBJECT_SPACE:
    fprintf (output, "%s\n", OM_erm_NO_OBJECT_SPACE);
    break;
  case OM_E_NOSUCHCLASS:
    fprintf (output, "%s\n", OM_erm_NOSUCHCLASS);
    break;
  case OM_E_REL_MISMATCH:
    fprintf (output, "%s\n", OM_erm_REL_MISMATCH);
    break;
  case OM_E_CHAN_OVERFLOW:
    fprintf (output, "%s\n", OM_erm_CHAN_OVERFLOW);
    break;
  case OM_E_INVCHAN:
    fprintf (output, "%s\n", OM_erm_INVCHAN);
    break;
  case OM_E_NOSUCHOBJ:
    fprintf (output, "%s\n", OM_erm_NOSUCHOBJ);
    break;
  case OM_E_CHAN_NOTEMPTY:
    fprintf (output, "%s\n", OM_erm_CHAN_NOTEMPTY);
    break;
  case OM_I_CHAN_EMPTY:
    fprintf (output, "%s\n", OM_erm_CHAN_EMPTY);
    break;
  case OM_W_NOTONCHAN:
    fprintf (output, "%s\n", OM_erm_NOTONCHAN);
    break;
  case OM_I_LISTOVFLOW:
    fprintf (output, "%s\n", OM_erm_LISTOVFLOW);
    break;
  case OM_E_INVARG:
    fprintf (output, "%s\n", OM_erm_INVARG);
    break;
  case OM_I_OBJONCHAN:
    fprintf (output, "%s\n", OM_erm_OBJONCHAN);
    break;
  case OM_I_RELVANISHED:
    fprintf (output, "%s\n", OM_erm_RELVANISHED);
    break;
  case OM_F_VERSION_MISMATCH:
    fprintf (output, "%s\n", OM_erm_VERSION_MISMATCH);
    break;
  case OM_W_OBJSPACE_EXISTS:
    fprintf (output, "%s\n", OM_erm_OBJSPACE_EXISTS);
    break;
  case OM_E_NO_OS_AVAIL:
    fprintf (output, "%s\n", OM_erm_NO_OS_AVAIL);
    break;
  case OM_I_DEFER_SUCCESS:
    fprintf (output, "%s\n", OM_erm_DEFER_SUCCESS);
    break;
  case OM_E_INVALIDRANGE:
    fprintf (output, "%s\n", OM_erm_INVALIDRANGE);
    break;
  case OM_E_NOSUCHOS:
    fprintf (output, "%s\n", OM_erm_NOSUCHOS);
    break;
  case OM_E_IOERR:
    fprintf (output, "%s\n", OM_erm_IOERR);
    break;
  case OM_E_INCONOIDS:
    fprintf (output, "%s\n", OM_erm_INCONOIDS);
    break;
  case OM_E_INCONOPSYS:
    fprintf (output, "%s\n", OM_erm_INCONOPSYS);
    break;
  case OM_E_INCONCPUS:
    fprintf (output, "%s\n", OM_erm_INCONCPUS);
    break;
  case OM_E_INVOSHDR:
    fprintf (output, "%s\n", OM_erm_INVOSHDR);
    break;
  case OM_E_NOSUCHREL:
    fprintf (output, "%s\n", OM_erm_NOSUCHREL);
    break;
  case OM_E_BADSTATE:
    fprintf (output, "%s\n", OM_erm_BADSTATE);
    break;
  case OM_I_ADDEDATEND:
    fprintf (output, "%s\n", OM_erm_ADDEDATEND);
    break;
  case OM_E_MSGNOTSUPP:
    fprintf (output, "%s\n", OM_E_erm_MSGNOTSUPP);
    break;
  case OM_E_BADCLASS:
    fprintf (output, "%s\n", OM_E_erm_BADCLASS);
    break;
  case OM_W_WARNING:
    fprintf (output, "%s\n", OM_W_erm_WARNING);
    break;
  case OM_E_ERROR:
    fprintf (output, "%s\n", OM_E_erm_ERROR);
    break;
  case OM_F_SEVERE:
    fprintf (output, "%s\n", OM_F_erm_SEVERE);
    break;
  case OM_E_NOEXTEND:
    fprintf (output, "%s\n", OM_E_erm_NOEXTEND);
    break;
  case OM_W_NOTORDERED:
    fprintf (output, "%s\n", OM_W_erm_NOTORDERED);
    break;
  case OM_E_NAMETOOLONG:
    fprintf (output, "%s\n", OM_E_erm_NAMETOOLONG);
    break;
  case OM_W_INDEXEMPTY:
    fprintf (output, "%s\n", OM_W_erm_INDEXEMPTY);
    break;
  case OM_I_FILEOVRWRTN:
    fprintf (output, "%s\n", OM_I_erm_FILEOVRWRTN);
    break;
  case OM_W_ISODIRONOS:
    fprintf (output, "%s\n", OM_W_erm_ISODIRONOS);
    break;
  case OM_E_NOEXTEND_OS:
    fprintf (output, "%s\n", OM_E_erm_NOEXTEND_OS);
    break;
  case OM_E_OS_ALLOC:
    fprintf (output, "%s\n", OM_E_erm_OS_ALLOC);
    break;
  case OM_I_INVANCESTRY:
    fprintf (output, "%s\n", OM_I_erm_INVANCESTRY);
    break;
  case OM_I_NOPARENT:
    fprintf (output, "%s\n", OM_I_erm_NOPARENT);
    break;
  case OM_E_FILEEXISTS:
    fprintf (output, "%s\n", OM_E_erm_FILEEXISTS);
    break;
  case OM_W_OSNOTACTIVE:
    fprintf (output, "%s\n", OM_W_erm_OSNOTACTIVE);
    break;
  case OM_W_USE_ISO_IF:
    fprintf (output, "%s\n", OM_W_erm_USE_ISO_IF);
    break;
  case OM_E_DIREXISTS:
    fprintf (output, "%s\n", OM_E_erm_DIREXISTS);
    break;
  case OM_E_NODIREXISTS:
    fprintf (output, "%s\n", OM_E_erm_NODIREXISTS);
    break;
  case OM_E_INDEXERROR:
    fprintf (output, "%s\n", OM_E_erm_INDEXERROR);
    break;
  case OM_E_OIDNAMEINUSE:
    fprintf (output, "%s\n", OM_E_erm_OIDNAMEINUSE);
    break;
  case OM_E_TOOMANYNAMES:
    fprintf (output, "%s\n", OM_E_erm_TOOMANYNAMES);
    break;
  case OM_W_NAMENOTFOUND:
    fprintf (output, "%s\n", OM_W_erm_NAMENOTFOUND);
    break;
  case OM_E_NOINDEXEXISTS:
    fprintf (output, "%s\n", OM_E_erm_NOINDEXEXISTS);
    break;
  case OM_E_OIDNOTNAMED:
    fprintf (output, "%s\n", OM_E_erm_OIDNOTNAMED);
    break;
  case OM_E_INDEXNOTEMPTY:
    fprintf (output, "%s\n", OM_E_erm_INDEXNOTEMPTY);
    break;
  case OM_E_CHNSELTYPINV:
    fprintf (output, "%s\n", OM_E_erm_CHNSELTYPINV);
    break;
  case OM_E_EXCEEDFANOUT:
    fprintf (output, "%s\n", OM_E_erm_EXCEEDFANOUT);
    break;
  case OM_E_CLASSNOTANCESTOR:
    fprintf (output, "%s\n", OM_E_erm_CLASSNOTANCESTOR);
    break;
  case OM_E_CHANNOTFOUND:
    fprintf (output, "%s\n", OM_E_erm_CHANNOTFOUND);
    break;
  case OM_I_ISAUNION:
    fprintf (output, "%s\n", OM_I_erm_ISAUNION);
    break;
  case OM_W_CLASS_CHKSUM_MISMATCH:
    fprintf (output, "%s\n", OM_W_erm_CLASS_CHKSUM_MISMATCH);
    break;
  case OM_E_INVINDEX:
    fprintf (output, "%s\n", OM_E_erm_INVINDEX);
    break;
  case OM_E_INVCLUSTERID:
    fprintf (output, "%s\n", OM_E_erm_INVCLUSTERID);
    break;
  case OM_E_MAX_CLUSTERS_ALLOWED:
    fprintf (output, "%s\n", OM_E_erm_MAX_CLUSTERS_ALLOWED);
    break;
  case OM_E_CLASS_CONFLICT:
    fprintf (output, "%s\n", OM_E_erm_CLASS_CONFLICT);
    break;
  case OM_I_NO_FREE_OIDS:
    fprintf (output, "%s\n", OM_I_erm_NO_FREE_OIDS);
    break;
  case OM_E_NO_EXTEND_GROUP:
    fprintf (output, "%s\n", OM_E_erm_NO_EXTEND_GROUP);
    break;
  case OM_E_NOTTREEROOT:
    fprintf (output, "%s\n", OM_E_erm_NOTTREEROOT);
    break;
  case OM_E_NO_DELETE_GROUP:
    fprintf (output, "%s\n", OM_E_erm_NO_DELETE_GROUP);
    break;
  case OM_E_NO_DELETE_CLUSTER:
    fprintf (output, "%s\n", OM_E_erm_NO_DELETE_CLUSTER);
    break;
  case OM_E_AMBIGUOUS_CHANNAME:
    fprintf (output, "%s\n", OM_E_erm_AMBIGUOUS_CHANNAME);
    break;
  case OM_E_NOPASSPASS:
    fprintf (output, "%s\n", OM_E_erm_NOPASSPASS);
    break;
  case OM_E_INVSTSTYPE:
    fprintf (output, "%s\n", OM_E_erm_INVSTSTYPE);
    break;
  case OM_E_OBJSIZE_TOOBIG:
    fprintf (output, "%s\n", OM_E_erm_OBJSIZE_TOOBIG);
    break;
  case OM_E_NOEXTEND_GROUP:
    fprintf (output, "%s\n", OM_E_erm_NOEXTEND_GROUP);
    break;
  case OM_E_ILLEGAL_GROUP0:
    fprintf (output, "%s\n", OM_E_erm_ILLEGAL_GROUP0);
    break;
  case OM_E_DUPGRPNAME:
    fprintf (output, "%s\n", OM_E_erm_DUPGRPNAME);
    break;
  case OM_E_DUPCLUSTNAME:
    fprintf (output, "%s\n", OM_E_erm_DUPCLUSTNAME);
    break;
  case OM_E_WRITE_ERROR:
    fprintf (output, "%s\n", OM_E_erm_WRITE_ERROR);
    break;
  case OM_E_READ_ERROR:
    fprintf (output, "%s\n", OM_E_erm_READ_ERROR);
    break;
  case OM_W_SIZE_TOO_SMALL:
    fprintf (output, "%s\n", OM_W_erm_SIZE_TOO_SMALL);
    break;
  case OM_E_NULL_STRING:
    fprintf (output, "%s\n", OM_E_erm_NULL_STRING);
    break;
  case OM_I_READ_FROM_FILE:
    fprintf (output, "%s\n", OM_I_erm_READ_FROM_FILE);
    break;
  case OM_W_OS_NOT_IN_MOSD:
    fprintf (output, "%s\n", OM_W_erm_OS_NOT_IN_MOSD);
    break;
  case OM_E_NO_DISK_SPACE:
    fprintf (output, "%s\n", OM_E_erm_NO_DISK_SPACE);
    break;
  case OM_E_MOSDOS_OS:
    fprintf (output, "%s\n", OM_E_erm_MOSDOS_OS);
    break;
  case OM_E_TRANS_OS:
    fprintf (output, "%s\n", OM_E_erm_TRANS_OS);
    break;
  case OM_E_DUPSYMNAME:
    fprintf (output, "%s\n", OM_E_erm_DUPSYMNAME);
    break;
  case OM_I_UNABLE_TO_CONNECT:
    fprintf (output, "%s\n", OM_I_erm_UNABLE_TO_CONNECT);
    break;
  case OM_E_BADCHAN_TYPE:
    fprintf (output, "%s\n", OM_E_erm_BADCHAN_TYPE);
    break;
  case OM_I_NOMATCH:
    fprintf (output, "%s\n", OM_I_erm_NOMATCH);
    break;
  case OM_E_SYMBOLNOTFOUND:
    fprintf (output, "%s\n", OM_E_erm_SYMBOLNOTFOUND);
    break;
  case OM_I_LOGICAL_DISCONNECT:
    fprintf (output, "%s\n", OM_I_erm_LOGICAL_DISCONNECT);
    break;
  case  OM_E_SPECIAL_FILE:
    fprintf (output, "%s\n",  OM_E_erm_SPECIAL_FILE);
    break;
  case  OM_E_INACCESSABLE_FILE:
    fprintf (output, "%s\n",  OM_E_erm_INACCESSABLE_FILE);
    break;
  case  OM_I_NOEXIST_WRITEABLE_FILE:
    fprintf (output, "%s\n",  OM_I_erm_NOEXIST_WRITEABLE_FILE);
    break;
  case  OM_I_EXIST_READONLY_FILE:
    fprintf (output, "%s\n",  OM_I_erm_EXIST_READONLY_FILE);
    break;
  case  OM_I_EXIST_READ_WRITE_FILE:
    fprintf (output, "%s\n",  OM_I_erm_EXIST_READ_WRITE_FILE);
    break;
  case  OM_I_READ_FROM_RO_FILE:
    fprintf (output, "%s\n",  OM_I_erm_READ_FROM_RO_FILE);
    break;
  case  OM_E_FILEISDIR:
    fprintf (output, "%s\n",  OM_E_erm_FILEISDIR);
    break;
  case  OM_E_INTERNALS_CORRUPT:
    fprintf (output, "%s\n",  OM_E_erm_INTERNALS_CORRUPT);
    break;
  case  OM_E_NOTTAGGED:
    fprintf (output, "%s\n",  OM_E_erm_NOTTAGGED);
    break;
  case  OM_E_TAGEXISTS:
    fprintf (output, "%s\n",  OM_E_erm_TAGEXISTS);
    break;
  case  OM_W_NOTTAGGED:
    fprintf (output, "%s\n",  OM_W_erm_NOTTAGGED);
    break;
  case  OM_E_NOSUCHTAG:
    fprintf (output, "%s\n",  OM_E_erm_NOSUCHTAG);
    break;
  case  OM_E_NOAVAILABLETAG:
    fprintf (output, "%s\n",  OM_E_erm_NOAVAILABLETAG);
    break;
  case  OM_E_BADSENDDEPTH:
    fprintf (output, "%s\n",  OM_E_erm_BADSENDDEPTH);
    break;
  case  OM_E_BADPROMCLASS:
    fprintf (output, "%s\n",  OM_E_erm_BADPROMCLASS);
    break;
  case  OM_E_INTERCEPTED:
    fprintf (output, "%s\n",  OM_E_erm_INTERCEPTED);
    break;
  case  OM_W_NOINTERCEPT:
    fprintf (output, "%s\n",  OM_W_erm_NOINTERCEPT);
    break;
  case  OM_W_NODYNLOAD:
    fprintf (output, "%s\n",  OM_W_erm_NODYNLOAD);
    break;
  case  OM_E_NOSUCHMSG:
    fprintf (output, "%s\n",  OM_E_erm_NOSUCHMSG);
    break;
  case  OM_W_REJECTED_METHOD:
    fprintf (output, "%s\n",  OM_W_erm_REJECTED_METHOD);
    break;
  case  OM_E_ABORT:
    fprintf (output, "%s\n",  OM_E_erm_ABORT);
    break;
  case  OM_W_ABORT:
    fprintf (output, "%s\n",  OM_W_erm_ABORT);
    break;
  case  OM_E_FROM_RTREE:
    fprintf (output, "%s\n",  OM_E_erm_FROM_RTREE);
    break;
  case  OM_E_CYCLEINSUPGROUP:
    fprintf (output, "%s\n",  OM_E_erm_CYCLEINSUPGROUP);
    break;
  case  OM_W_NOSUCHMEMBER:
    fprintf (output, "%s\n",  OM_W_erm_NOSUCHMEMBER);
    break;
  case  OM_W_NOTTAGGABLE:
    fprintf (output, "%s\n",  OM_W_erm_NOTTAGGABLE);
    break;
  case  OM_W_TAGDISABLED:
    fprintf (output, "%s\n",  OM_W_erm_TAGDISABLED);
    break;
  case  OM_I_OBJNOTTAGGED:
    fprintf (output, "%s\n",  OM_I_erm_OBJNOTTAGGED);
    break;
  case  OM_I_DUPLICATE_OS:
    fprintf (output, "%s\n",  OM_I_erm_DUPLICATE_OS);
    break;
  case  OM_I_DUPLICATE_OS_RO:
    fprintf (output, "%s\n",  OM_I_erm_DUPLICATE_OS_RO);
    break;
  case OM_E_FILEOVRWRTN:
    fprintf (output, "%s\n", OM_E_erm_FILEOVRWRTN);
    break;

/*=========================*/
/* UNIX system error codes */
/*=========================*/

  case UNIX_E_EPERM:
    fprintf (output, "%s\n", UNIX_E_erm_EPERM);
    break;
  case UNIX_E_ENOENT:
    fprintf (output, "%s\n", UNIX_E_erm_ENOENT);
    break;
  case UNIX_E_ESRCH:
    fprintf (output, "%s\n", UNIX_E_erm_ESRCH);
    break;
  case UNIX_E_EINTR:
    fprintf (output, "%s\n", UNIX_E_erm_EINTR);
    break;
  case UNIX_E_EIO:
    fprintf (output, "%s\n", UNIX_E_erm_EIO);
    break;
  case UNIX_E_ENXIO:
    fprintf (output, "%s\n", UNIX_E_erm_ENXIO);
    break;
  case UNIX_E_E2BIG:
    fprintf (output, "%s\n", UNIX_E_erm_E2BIG);
    break;
  case UNIX_E_ENOEXEC:
    fprintf (output, "%s\n", UNIX_E_erm_ENOEXEC);
    break;
  case UNIX_E_EBADF:
    fprintf (output, "%s\n", UNIX_E_erm_EBADF);
    break;
  case UNIX_E_ECHILD:
    fprintf (output, "%s\n", UNIX_E_erm_ECHILD);
    break;
  case UNIX_E_EAGAIN:
    fprintf (output, "%s\n", UNIX_E_erm_EAGAIN);
    break;
  case UNIX_E_ENOMEM:
    fprintf (output, "%s\n", UNIX_E_erm_ENOMEM);
    break;
  case UNIX_E_EACCES:
    fprintf (output, "%s\n", UNIX_E_erm_EACCES);
    break;
  case UNIX_E_EFAULT:
    fprintf (output, "%s\n", UNIX_E_erm_EFAULT);
    break;
  case UNIX_E_ENOTBLK:
    fprintf (output, "%s\n", UNIX_E_erm_ENOTBLK);
    break;
  case UNIX_E_EBUSY:
    fprintf (output, "%s\n", UNIX_E_erm_EBUSY);
    break;
  case UNIX_E_EEXIST:
    fprintf (output, "%s\n", UNIX_E_erm_EEXIST);
    break;
  case UNIX_E_EXDEV:
    fprintf (output, "%s\n", UNIX_E_erm_EXDEV);
    break;
  case UNIX_E_ENODEV:
    fprintf (output, "%s\n", UNIX_E_erm_ENODEV);
    break;
  case UNIX_E_ENOTDIR:
    fprintf (output, "%s\n", UNIX_E_erm_ENOTDIR);
    break;
  case UNIX_E_EISDIR:
    fprintf (output, "%s\n", UNIX_E_erm_EISDIR);
    break;
  case UNIX_E_EINVAL:
    fprintf (output, "%s\n", UNIX_E_erm_EINVAL);
    break;
  case UNIX_E_ENFILE:
    fprintf (output, "%s\n", UNIX_E_erm_ENFILE);
    break;
  case UNIX_E_EMFILE:
    fprintf (output, "%s\n", UNIX_E_erm_EMFILE);
    break;
  case UNIX_E_ENOTTY:
    fprintf (output, "%s\n", UNIX_E_erm_ENOTTY);
    break;
  case UNIX_E_ETXTBSY:
    fprintf (output, "%s\n", UNIX_E_erm_ETXTBSY);
    break;
  case UNIX_E_EFBIG:
    fprintf (output, "%s\n", UNIX_E_erm_EFBIG);
    break;
  case UNIX_E_ENOSPC:
    fprintf (output, "%s\n", UNIX_E_erm_ENOSPC);
    break;
  case UNIX_E_ESPIPE:
    fprintf (output, "%s\n", UNIX_E_erm_ESPIPE);
    break;
  case UNIX_E_EROFS:
    fprintf (output, "%s\n", UNIX_E_erm_EROFS);
    break;
  case UNIX_E_EMLINK:
    fprintf (output, "%s\n", UNIX_E_erm_EMLINK);
    break;
  case UNIX_E_EPIPE:
    fprintf (output, "%s\n", UNIX_E_erm_EPIPE);
    break;
  case UNIX_E_EDOM:
    fprintf (output, "%s\n", UNIX_E_erm_EDOM);
    break;
  case UNIX_E_ERANGE:
    fprintf (output, "%s\n", UNIX_E_erm_ERANGE);
    break;
  case UNIX_E_ENOMSG:
    fprintf (output, "%s\n", UNIX_E_erm_ENOMSG);
    break;
  case UNIX_E_EIDRM:
    fprintf (output, "%s\n", UNIX_E_erm_EIDRM);
    break;
  case UNIX_E_ECHRNG:
    fprintf (output, "%s\n", UNIX_E_erm_ECHRNG);
    break;
  case UNIX_E_EL2NSYNC:
    fprintf (output, "%s\n", UNIX_E_erm_EL2NSYNC);
    break;
  case UNIX_E_EL3HLT:
    fprintf (output, "%s\n", UNIX_E_erm_EL3HLT);
    break;
  case UNIX_E_EL3RST:
    fprintf (output, "%s\n", UNIX_E_erm_EL3RST);
    break;
  case UNIX_E_ELNRNG:
    fprintf (output, "%s\n", UNIX_E_erm_ELNRNG);
    break;
  case UNIX_E_EUNATCH:
    fprintf (output, "%s\n", UNIX_E_erm_EUNATCH);
    break;
  case UNIX_E_ENOCSI:
    fprintf (output, "%s\n", UNIX_E_erm_ENOCSI);
    break;
  case UNIX_E_EL2HLT:
    fprintf (output, "%s\n", UNIX_E_erm_EL2HLT);
    break;
  case UNIX_E_EDEADLK:
    fprintf (output, "%s\n", UNIX_E_erm_EDEADLK);
    break;

/* Not a recognized error code, so give appropriate unknown message */

  default:
    switch (7 & sts)
    {
    case INFO:
      fprintf (output, "OM_I_, unknown informational status\n");
      break;
    case WARN:
      fprintf (output, "OM_W_, unknown error status\n");
      break;
    case ERRO:
      fprintf (output, "OM_E_, unknown error status\n");
      break;
    case SEVE:
      fprintf (output, "OM_F_, unknown error status\n");
      break;
    default:
      fprintf (output, "OM_?_, unknown error status\n");
      break;
    }
    break;
  }
}


/*
---------------------------------------------------------------------------
Routine Name:	som_malloc
Abstract:

  This routine handles all dynmamic memory allocation for OM.

Sample Invocation:

	om$malloc (size=10)

Entry Variable Description:

OMuint			size	byte size to allocate

Exit Variable Description:

	Function value:	NULL => no dynamic memory available
			o/w ,  points to allocated memory.

Modules Invoked:

	malloc

---------------------------------------------------------------------------
*/

#include 	<malloc.h>

char	*som_malloc (size)

OMuint	size;

{
  if (size) return (malloc (size));
  else return (NULL);
}

/*
---------------------------------------------------------------------------
Routine Name:	som_realloc
Abstract:

  This routine handles all dynmamic memory reallocation for OM.

Sample Invocation:

	om$realloc (ptr=p_str, size=40)

Entry Variable Description:

char			*ptr    pointer to block being resized
OMuint			size	new byte size to make block

Exit Variable Description:

	Function value:	NULL => no dynamic memory available
			o/w ,  points to allocated memory.

Modules Invoked:

	realloc

Notes:  The block is possibly moved.
	The contents will be unchanged up to the lesser of the
	new and old sizes.
---------------------------------------------------------------------------
*/

char	*som_realloc (ptr, size)

char	*ptr;
OMuint	size;

{
  if ( size && ptr ) return (realloc (ptr, size));
  else return (NULL);
}

/*
---------------------------------------------------------------------------
Routine Name:	som_calloc
Abstract:

Gets and clears memory.

Sample Invocation:

	om$calloc (number=3, size=10)

Entry Variable Description:

OMuint		number		number of things to get
OMuint		size		size of each one.

Change History:

kek001	23-mar-1986	changed loop clearing allocate memory

ems002  24-mar-1986     changed to simply call calloc

rme001  10-aug-1987	removed declaration of calloc.
---------------------------------------------------------------------------
*/

char	*som_calloc (number, size)

OMuint		number;
OMuint		size;

{
  if ((! number) || (! size)) return (NULL);

  return ((char *)calloc(number,size));
}

/*
---------------------------------------------------------------------------
Routine Name:	som_dealloc
Abstract:

 This routine handles all deallocation of dynamic memory for OM.
 
Sample Invocation:

	om$dealloc (ptr=p_str)

Entry Variable Description:

void		*ptr	pointer to memory to deallocate

---------------------------------------------------------------------------
*/

void som_dealloc (ptr)

void 	*ptr;

{
  if ( ptr ) free (ptr);
}


/*
	hb001	make_message cache
*/

#define    KEY_SIZE        OM_K_MAXCLASS_LEN + 64
#define    NUM_ENTRIES     127

struct cache_entry
{
   char                key[KEY_SIZE];
   OM_S_MESSAGE        msg;
};

static  struct cache_entry msg_cache[NUM_ENTRIES];
static  int hits=0,tries=0,num_entries=0;
static  char query_key [KEY_SIZE];
static  int index;

/*---------------------------------------------------------------------------*/
int som_print_mess_cache()
{
   short i;
   double percent;

   percent = ((double)((double)hits/(double)tries))*100.0;      
   printf("cache hit rate : %d %d = %f percent\n",hits,tries,percent);
   for(i=0; i<NUM_ENTRIES; i++)
   {
     if(msg_cache[i].key[0]!=0)
       printf("mess_cache entry[%d] <%s>\n",i,msg_cache[i].key);
   }
   return(1);
}

/*---------------------------------------------------------------------------*/

#argsused

int som_add_mess_cache ( class_name, meth_name, p_msg )
char		 	 *class_name, *meth_name;
OM_p_MESSAGE		 p_msg;
{
   num_entries++;   

   msg_cache [index].msg = *p_msg;
   strcpy ( msg_cache [index].key, query_key );

   return OM_S_SUCCESS;
}

/*
-------------------------------------------------------------------------------
Routine Name:	som_make_message
Abstract:

This routine constructs a message from class names and method names.
It also takes in the size of the argument structure and a pointer to it.
The idea is that we will put theses pieces of info where OM KNOWS they go.

Sample Invocation:

     som_make_message(class_name, classid, meth_name, size, p_arglist, p_msg)

Entry Variable Description:

char		*class_name	class_name that goes into method selector
OMuword         classid         class id
void		*meth_name	method name
OMuword		size     	byte size of argument structure (best gotten
  				by sizeof (struct X))
struct		*p_arglist	pointer to argument list (structure)
OM_p_MESSAGE	p_msg   	Place to put message stuff

Change Hostory:

cgp001	17-nov-1985	fix a bug and change call parameters to TOTALLY
			fill in the MESSAGE struct.

ems001  24-jul-1986     4.0 update

ems002  11-feb-1987     Add classid to arg list.

-------------------------------------------------------------------------------
*/

static som_search_ancestors ( p_ACLD, p_msg, meth_name )

OM_p_CLASSDEF   p_ACLD;
OM_p_MESSAGE    p_msg;
char            *meth_name;

{
   int            i, sts;
   OM_p_ANCESTRY  p_ancestor;
   OM_p_CLASSDEF  p_anc_ACLD;
   OM_p_METHDEFN  p_methdef;

   if ( p_ACLD->w_classid != OM_K_ROOT_ACTCLASSID )
   {
      for ( i=p_ACLD->w_numparents-1; i>=0; i-- )
      {
         p_ancestor = p_ACLD->A_ancestor_list + i;
         p_anc_ACLD = OM_GA_active_classes[*p_ancestor->p_classid];
         p_methdef = p_anc_ACLD->p_methdefns;
         while ( p_methdef )
         {
            if (!strcmp (p_methdef->s_name, meth_name))
            {
               p_msg->select.DefClassid = p_anc_ACLD->w_classid;
               p_msg->select.FuncIndex  = p_methdef->w_methidx;
               return (OM_S_SUCCESS);
            }
            p_methdef = p_methdef->next;        
         }
         sts = som_search_ancestors(p_anc_ACLD, p_msg, meth_name);
         if ( sts == OM_S_SUCCESS ) return (sts);
      }
   }
   return (OM_W_UNKNOWN_MSG);
}



int som_make_message (char *class_name, OMuword classid, char *meth_name,
                      OMuword size, void *p_arglist, OM_p_MESSAGE p_msg)
{
   int             sts;
   OM_p_CLASSDEF   p_ACLD;
   OM_p_METHDEFN   p_methdef;
   register char   *ptr2 = class_name, *ptr1 = query_key;

   if (class_name)         /* hb001 */
   {
      /* Hash the class name */

      for (index = 0; *ptr2; )
        index += *ptr1++ = *ptr2++;
      index += *ptr1++ = '.';
      for (ptr2 = meth_name; *ptr2; )
        index += *ptr1++ = *ptr2++;
      *ptr1 = '\0';
      index %= NUM_ENTRIES;

      /* Look up the class in the message cache */

      if(!strcmp ( query_key, msg_cache [index].key ))
      {
          *p_msg = msg_cache[index].msg;
           p_msg->p_arglist = p_arglist;
           p_msg->size = size;

           return OM_S_SUCCESS;
       }
   }

   if ( class_name != NULL )
   {
      if (!(1&(sts = om$get_class ( classname=class_name, p_classid=&classid,
                                    pp_cld=&p_ACLD ))))
      {
         return (sts);
      }
   }
   else
   {
      if ( NULL == (p_ACLD = OM_GA_active_classes[classid]))
      {
         return (OM_E_NOSUCHCLASS);
      }
   }
 
   p_methdef = p_ACLD->p_methdefns;

   while (NULL != p_methdef)
   {
      if (!strcmp (p_methdef->s_name, meth_name))
      {
         p_msg->select.DefClassid = classid;
         p_msg->select.ReqClassid = classid;
         p_msg->select.FuncIndex  = p_methdef->w_methidx;
         p_msg->size = size;
         p_msg->p_arglist = p_arglist;
         if(class_name != NULL) som_add_mess_cache(class_name,meth_name,p_msg);
         return (OM_S_SUCCESS);
       }
       p_methdef = p_methdef->next;
   }
   p_msg->select.ReqClassid = classid;
   p_msg->size = size;
   p_msg->p_arglist = p_arglist;
   
   sts = som_search_ancestors(p_ACLD, p_msg, meth_name);
  if (sts == OM_S_SUCCESS && class_name)
     som_add_mess_cache(class_name,meth_name,p_msg);
  return(sts);
}


som_make_neighbor(
    OMuword	  osnum,
    OM_S_OBJID	  objid,
    OM_p_NEIGHBOR p_neighbor)
{
  OM_S_CHANSELECT	cs;
  OMuint		sts;
  OM_S_MESSAGE	msg;
  struct OM_sd_find_group_args
  {
    OM_S_OBJID	oid;
    OM_p_OBJID  p_grpoid;
  } arglist;

  /*==============*/
  /* Default Case */
  /*==============*/

  if( objid == NULL_OBJID )
  {
    p_neighbor->clusterid = 0;
    p_neighbor->groupid = NULL_OBJID;
    return(OM_S_SUCCESS);
  }

  /*======================*/
  /* Validate Input Objid */
  /*======================*/

  if(!(1&(sts = om$is_objid_valid(osnum=osnum, objid=objid) )))
	return(sts);

  /*===========================*/
  /* Fill in Objid's Clusterid */
  /*===========================*/

  if(OM_OBJ_IN_MEM(OM_GA_OSDs[osnum]->Spacemap[objid].flags))
    p_neighbor->clusterid = 
	OM_GA_CSDarray[OM_GA_OSDs[osnum]->Spacemap[objid].sdi].p_pcd->p_lcd->w_cluster_num;
  else
   if(OM_OBJ_IN_FILE(OM_GA_OSDs[osnum]->Spacemap[objid].flags))
	p_neighbor->clusterid = 
	   OM_GA_OSDs[osnum]->Spacemap[objid].state.filed_obj.clusterid;

  /*===================================*/
  /* Channel Send to OSO for Group Oid */
  /*===================================*/

  arglist.oid = objid;
  arglist.p_grpoid = &(p_neighbor->groupid);

  msg.select.DefClassid = OM_K_OMGROUP_ACTCLASSID;
  msg.select.ReqClassid = OM_K_OMGROUP_ACTCLASSID;
  msg.select.FuncIndex  = OMGroup_OPP_my_oid_method_index;
  msg.size              = sizeof(arglist);
  msg.p_arglist         = (char *)&arglist;

  cs.type = OM_e_name;
  cs.u_sel.name = "OMObjSpace.to_GrpDscs";
  sts = om$send(senderid=OM_GA_OSDs[osnum]->OSO_Oid,
		msg=&msg, mode=OM_e_wrt_message, targetos=osnum,
		p_chanselect=&cs);
  if ((sts != OM_W_UNKNOWN_MSG) && (sts != OM_S_SUCCESS))
    return(sts);

  return(OM_S_SUCCESS);
}


/*
-------------------------------------------------------------------------------
Routine Name:         som_report_version

Abstract:             This routine returns the major and minor version
                        numbers of the Object Manager (OM).

Sample Invocation:    som_report_version ( major, minor )


Exit Variable Description:

                      OMuword         *major          major version number
                      OMuword         *minor          minor version number

                      function returns:  OM_S_SUCCESS

-------------------------------------------------------------------------------
*/

int som_report_version ( major, minor )

OMuword  *major;
OMuword  *minor;

{
   *major = OM_Gw_major_version;
   *minor = OM_Gw_minor_version;
   return (OM_S_SUCCESS);
}



/********************************************************************/
/* dump routines 
*/
void dump_class(p_acld)
OM_p_CLASSDEF p_acld;
{
printf("Active class id %d\n",			p_acld->w_classid);
printf("Size in bytes of instance data %d\n",	p_acld->i_instance_size);
printf("Size in bytes of new instance data  %d\n",p_acld->NewInstanceSize);
printf("Active class major version number %d\n",p_acld->w_major_version);
printf("Active class minor version number %d\n",p_acld->w_minor_version);
printf("Version of opp %d.%d\n",		p_acld->w_oppmaj_version,
						p_acld->w_oppmin_version);
printf("Name of class %s\n",			p_acld->s_name);
printf("Flags %d\n",	                        p_acld->flags);
printf("Pointer to VLA defs %X\n",		p_acld->p_varlenarr_defns);
printf("Number of VLA's %d\n",			p_acld->w_num_varlenarrays);
printf("Number of immediate ancestors %d\n",	p_acld->w_numparents);
printf("Pointers to immediate ancestors' ACLD %X\n",p_acld->A_ancestor_list);
printf("List of class's subclasses %X\n",p_acld->p_subclass_list);
printf("Count of known channels %d\n",		p_acld->w_numchannels);
printf("Count of methods for this class %d\n",	p_acld->w_nummethods);
printf("Linked list  of meth defns %X\n",	p_acld->p_methdefns);
printf("List of instance definitions %X\n",	p_acld->p_instance_def);
printf("Vla initial size%d\n",		p_acld->initial_size);
printf("Number of classes this class recognizes %d\n",p_acld->NumRecClasses);
printf("Maximum legal classid (for messages) %d\n",p_acld->w_maxclass);
printf("Base of minimum classid (for messages) %d\n",p_acld->w_baseclass);
printf("Ptr to translator map %X\n",		p_acld->p_transmap);
printf("Size of classmap array %d\n",		p_acld->NumMsgClasses);
printf("Pointer to classmap array %X\n",	p_acld->MsgMap);

}

/***********************************************************************/

void dump_msgmap(p_msgmap,count)
OM_p_MSGMAP	p_msgmap;	/* pointer to the dense array   */
int		count;		/* how many entries there are	*/
{
int i;

printf("Dumping %d message maps \n",count);
if (count <= 0 ) return;
for(i=0; i<count; i++)
{
printf("ptr to method table (hex) %X\n",p_msgmap->MethTbl);
printf("offset to instance data for this class %d\n",p_msgmap->	offset);
printf("classid for defining class %d\n",p_msgmap->classid);
printf("1st 16 chars of defining class name = %.16s\n",
	OM_GA_active_classes[p_msgmap->classid]->s_name);
printf("number of channels defined %d\n",p_msgmap->NumChan);
printf("ptr to channel definitions (hex) %X\n\n\n",p_msgmap->ChanDefns);

p_msgmap ++;	/* point to next entry */
}

}

/*************************************************************/

/* routine to dump an object header */
void dump_objhdr(p_object)
OM_p_OBJECTHDR	p_object;

{

	printf("Object's oid = %d\n",		p_object->oid);
	printf("Byte size = %d\n",OM_GETOBJSIZE(p_object->i_size));

	if (OM_OBJ_HAS_VLA(p_object->i_size))
	{
	  printf("Flag(s) are: Has_VLA ");
	  if (OM_OBJ_IS_TAGGED(p_object->i_size)) printf("& Is_TAGGED ");
	  printf("\n");
	}
	else printf("No Flags are set\n");
}

/******************************************************************

/*****************************************************************/

/* routine to dump the spacemap */
void dump_space(count,SpaceMap)
int count;			/* how many entries to look at 	*/
OM_p_SPAMAPENT	SpaceMap;	/* pointer to the spacemap	*/
/* the field SpaceMap in the OSD can be passed to this routine */
{
int i;

if ((count <= 0) || (SpaceMap == NULL)) return;

for(i=0; i<count; i++)
{
printf("Oid = %d\n",i);
printf("p_acld = %x\n", SpaceMap[i].p_acld);
printf("sdi if in mem = %x\n", SpaceMap[i].sdi);
printf("state as object ptr = %8X\n",		SpaceMap[i].state.object);
printf("state as dummy    = %d\n", SpaceMap[i].state.filed_obj.dummy);
printf("state as clusterid  = %d\n", SpaceMap[i].state.filed_obj.clusterid);
printf("state as _free oid  = %d\n",		SpaceMap[i].state.freeoid);

if(SpaceMap[i].flags)
{
  printf("Flag(s): ");
  if(SpaceMap[i].flags&OM_SM_array_mod)       printf("Modified_VLA ");
  if(SpaceMap[i].flags&OM_SM_Rootdel_pending) printf("Rootdel_pending ");
  if(SpaceMap[i].flags&OM_SM_in_use         ) printf("In_use ");
  if(SpaceMap[i].flags&OM_SM_in_mem	    ) printf("In_memory ");
  if(SpaceMap[i].flags&OM_SM_has_di_name    ) printf("Has_di_name ");
  if(SpaceMap[i].flags&OM_SM_has_msgintrcpt ) printf("Has_msgintrcpt ");
  if(SpaceMap[i].flags&OM_SM_send_depth	    ) printf("Elevated send depth ");
  printf("\n");
}
else printf("No Flags are set\n");

}
if (i < (count-1)) printf("\n");	/* put blank line between entries */
}


/******************************************************************/

void dump_trnmap(p_transmap,count)
/* routine to dump a translation map hanging off of an ACLD. 
/* it prints rows of 8 entries in the format (iii):jjj where 
/* iii is the index into the translation map (starting with 0)
/* and jjj is the decimal byte value at that point
/* if it is a null entry it will show up as 'xxx'
*/
unsigned char *p_transmap;
int count;
{

int i;
if (count <= 0) return;

for(i=0; i<count; i++)
{
if (p_transmap[i] == OM_K_NULL_TRANS)
 printf("(%.3u):xxx ",i);
else
 printf("(%.3u):%.3u ",i,p_transmap[i]);

if ((i) && (!((i+1)%8))) printf("\n");

}

}


/* saw001 */

int	som_getClusterFromObject (
OMuword	*pClustNum,
OMuint	objid,
OMuword	osnum)

{
   int               sts;
   OM_p_SPAMAPENT    p_mapentry;

   if (!(1&(sts=om$is_objid_valid(osnum=osnum, objid=objid))))
      return(sts);

   p_mapentry = &(OM_GA_OSDs[osnum]->Spacemap[objid]);

   if (p_mapentry->flags & OM_SM_in_mem)
   {
      if (p_mapentry->flags & OM_SM_in_use)
         *pClustNum = OM_GA_CSDarray[p_mapentry->sdi].p_pcd->
            p_lcd->w_cluster_num;               /* Object is resident */
   }
   else
      if (p_mapentry->flags & OM_SM_in_use)
         *pClustNum = p_mapentry->state.filed_obj.clusterid; /* Filed object */
      else
         return(OM_E_NOSUCHOBJ);

   return(OM_S_SUCCESS);
}
