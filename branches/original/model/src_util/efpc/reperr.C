#define OM_DEFINE_ERRMSG 1
#define UNIX_D_DEFINE_ERRMSG 1

#include 	"OMobjectcomm.h"
#include        "OMintprims.h"
#include 	"OMmetaclass.h"
#include        "UNIXerrdef.h"

/* +++ 4.0 ++++++++++++++++++++++++++++++++++++++++++++++++ som_report_error */

void som_report_error (xx_fnindex,sts)

int 	xx_fnindex;	/* used by the debugger */
OMulong	sts;	/* the OM status code, defined in OMerrordef.h */
						/*-fndesc*/
{
  printf ("Error status = %x, \n", sts);
  switch (sts)
  {
  case OM_S_SUCCESS:
    printf ("OM-S-SUCCESS, Operation successfully completed.\n");
    break;
  case OM_W_UNKNOWN_MSG:
    printf ("%s\n", OM_erm_UNKNOWN_MSG);
    break;
  case OM_W_ABORT:
    printf ("%s\n", OM_W_erm_ABORT);
    break;
  case OM_E_ABORT:
    printf ("%s\n", OM_E_erm_ABORT);
    break;
  case OM_E_OBJECT_LOCKED:
    printf ("%s\n", OM_erm_OBJECT_LOCKED);
    break;
  case OM_I_STOP_SENDING:
    printf ("%s\n", OM_erm_STOP_SENDING);
    break;
  case OM_E_NO_RELATION:
    printf ("%s\n", OM_erm_NO_RELATION);
    break;
  case OM_F_BUGCHECK:
    printf ("%s\n", OM_erm_BUGCHECK);
    break;
  case OM_E_NOTIMPL:
    printf ("%s\n", OM_erm_NOTIMPL);
    break;
  case OM_E_NODYNMEM:
    printf ("%s\n", OM_erm_NODYNMEM);
    break;
  case OM_W_CLASS_EXISTS:
    printf ("%s\n", OM_erm_CLASS_EXISTS);
    break;
  case OM_E_NOPARENT:
    printf ("%s\n", OM_erm_NOPARENT);
    break;
  case OM_E_BADCLASSNAME:
    printf ("%s\n", OM_erm_BADCLASSNAME);
    break;
  case OM_E_TOOMANYCLASSES:
    printf ("%s\n", OM_erm_TOOMANYCLASSES);
    break;
  case OM_E_NO_OBJECT_SPACE:
    printf ("%s\n", OM_erm_NO_OBJECT_SPACE);
    break;
  case OM_E_NOSUCHCLASS:
    printf ("%s\n", OM_erm_NOSUCHCLASS);
    break;
  case OM_E_REL_MISMATCH:
    printf ("%s\n", OM_erm_REL_MISMATCH);
    break;
  case OM_E_CHAN_OVERFLOW:
    printf ("%s\n", OM_erm_CHAN_OVERFLOW);
    break;
  case OM_E_INVCHAN:
    printf ("%s\n", OM_erm_INVCHAN);
    break;
  case OM_E_NOSUCHOBJ:
    printf ("%s\n", OM_erm_NOSUCHOBJ);
    break;
  case OM_E_CHAN_NOTEMPTY:
    printf ("%s\n", OM_erm_CHAN_NOTEMPTY);
    break;
  case OM_I_CHAN_EMPTY:
    printf ("%s\n", OM_erm_CHAN_EMPTY);
    break;
  case OM_W_NOTONCHAN:
    printf ("%s\n", OM_erm_NOTONCHAN);
    break;
  case OM_I_LISTOVFLOW:
    printf ("%s\n", OM_erm_LISTOVFLOW);
    break;
  case OM_E_INVARG:
    printf ("%s\n", OM_erm_INVARG);
    break;
  case OM_I_OBJONCHAN:
    printf ("%s\n", OM_erm_OBJONCHAN);
    break;
  case OM_I_RELVANISHED:
    printf ("%s\n", OM_erm_RELVANISHED);
    break;
  case OM_F_VERSION_MISMATCH:
    printf ("%s\n", OM_erm_VERSION_MISMATCH);
    break;
  case OM_W_OBJSPACE_EXISTS:
    printf ("%s\n", OM_erm_OBJSPACE_EXISTS);
    break;
  case OM_E_NO_OS_AVAIL:
    printf ("%s\n", OM_erm_NO_OS_AVAIL);
    break;
  case OM_I_DEFER_SUCCESS:
    printf ("%s\n", OM_erm_DEFER_SUCCESS);
    break;
  case OM_E_INVALIDRANGE:
    printf ("%s\n", OM_erm_INVALIDRANGE);
    break;
  case OM_E_NOSUCHOS:
    printf ("%s\n", OM_erm_NOSUCHOS);
    break;
  case OM_E_IOERR:
    printf ("%s\n", OM_erm_IOERR);
    break;
  case OM_E_INCONOIDS:
    printf ("%s\n", OM_erm_INCONOIDS);
    break;
  case OM_E_INCONOPSYS:
    printf ("%s\n", OM_erm_INCONOPSYS);
    break;
  case OM_E_INCONCPUS:
    printf ("%s\n", OM_erm_INCONCPUS);
    break;
  case OM_E_INVOSHDR:
    printf ("%s\n", OM_erm_INVOSHDR);
    break;
  case OM_E_NOSUCHREL:
    printf ("%s\n", OM_erm_NOSUCHREL);
    break;
  case OM_E_BADSTATE:
    printf ("%s\n", OM_erm_BADSTATE);
    break;
  case OM_I_ADDEDATEND:
    printf ("%s\n", OM_erm_ADDEDATEND);
    break;
  case OM_E_MSGNOTSUPP:
    printf ("%s\n", OM_E_erm_MSGNOTSUPP);
    break;
  case OM_E_NOEXTEND:
    printf ("%s\n", OM_E_erm_NOEXTEND);
    break;
  case OM_E_BADCLASS:
    printf ("%s\n", OM_E_erm_BADCLASS);
    break;
  case OM_W_WARNING:
    printf ("%s\n", OM_W_erm_WARNING);
    break;
  case OM_E_ERROR:
    printf ("%s\n", OM_E_erm_ERROR);
    break;
  case OM_F_SEVERE:
    printf ("%s\n", OM_F_erm_SEVERE);
    break;
  case OM_W_NOTORDERED:
    printf ("%s\n", OM_W_erm_NOTORDERED);
    break;
  case OM_E_NAMETOOLONG:
    printf ("%s\n", OM_E_erm_NAMETOOLONG);
    break;
  case OM_W_INDEXEMPTY:
    printf ("%s\n", OM_W_erm_INDEXEMPTY);
    break;
  case OM_I_FILEOVRWRTN:
    printf ("%s\n", OM_I_erm_FILEOVRWRTN);
    break;
  case OM_W_ISODIRONOS:
    printf ("%s\n", OM_W_erm_ISODIRONOS);
    break;
  case OM_E_NOEXTEND_OS:
    printf ("%s\n", OM_E_erm_NOEXTEND_OS);
    break;
  case OM_E_OS_ALLOC:
    printf ("%s\n", OM_E_erm_OS_ALLOC);
    break;
  case OM_I_INVANCESTRY:
    printf ("%s\n", OM_I_erm_INVANCESTRY);
    break;
  case OM_I_NOPARENT:
    printf ("%s\n", OM_I_erm_NOPARENT);
    break;
  case OM_E_FILEEXISTS:
    printf ("%s\n", OM_E_erm_FILEEXISTS);
    break;
  case OM_W_OSNOTACTIVE:
    printf ("%s\n", OM_W_erm_OSNOTACTIVE);
    break;
  case OM_W_USE_ISO_IF:
    printf ("%s\n", OM_W_erm_USE_ISO_IF);
    break;
  case OM_E_DIREXISTS:
    printf ("%s\n", OM_E_erm_DIREXISTS);
    break;
  case OM_E_NODIREXISTS:
    printf ("%s\n", OM_E_erm_NODIREXISTS);
    break;
  case OM_E_INDEXERROR:
    printf ("%s\n", OM_E_erm_INDEXERROR);
    break;
  case OM_E_OIDNAMEINUSE:
    printf ("%s\n", OM_E_erm_OIDNAMEINUSE);
    break;
  case OM_E_TOOMANYNAMES:
    printf ("%s\n", OM_E_erm_TOOMANYNAMES);
    break;
  case OM_W_NAMENOTFOUND:
    printf ("%s\n", OM_W_erm_NAMENOTFOUND);
    break;
  case OM_E_NOINDEXEXISTS:
    printf ("%s\n", OM_E_erm_NOINDEXEXISTS);
    break;
  case OM_E_OIDNOTNAMED:
    printf ("%s\n", OM_E_erm_OIDNOTNAMED);
    break;
  case OM_E_INDEXNOTEMPTY:
    printf ("%s\n", OM_E_erm_INDEXNOTEMPTY);
    break;
  case OM_E_CHNSELTYPINV:
    printf ("%s\n", OM_E_erm_CHNSELTYPINV);
    break;
  case OM_E_EXCEEDFANOUT:
    printf ("%s\n", OM_E_erm_EXCEEDFANOUT);
    break;
  case OM_E_CLASSNOTANCESTOR:
    printf ("%s\n", OM_E_erm_CLASSNOTANCESTOR);
    break;
  case OM_E_CHANNOTFOUND:
    printf ("%s\n", OM_E_erm_CHANNOTFOUND);
    break;
  case OM_I_ISAUNION:
    printf ("%s\n", OM_I_erm_ISAUNION);
    break;
  case OM_W_CLASS_CHKSUM_MISMATCH:
    printf ("%s\n", OM_W_erm_CLASS_CHKSUM_MISMATCH);
    break;
  case OM_E_INVINDEX:
    printf ("%s\n", OM_E_erm_INVINDEX);
    break;
  case OM_E_INVCLUSTERID:
    printf ("%s\n", OM_E_erm_INVCLUSTERID);
    break;
  case OM_E_NOEXTEND_CLUSTER:
    printf ("%s\n", OM_E_erm_NOEXTEND_CLUSTER);
    break;
  case OM_E_MAX_CLUSTERS_ALLOWED:
    printf ("%s\n", OM_E_erm_MAX_CLUSTERS_ALLOWED);
    break;
  case OM_E_CLASS_CONFLICT:
    printf ("%s\n", OM_E_erm_CLASS_CONFLICT);
    break;
  case OM_I_NO_FREE_OIDS:
    printf ("%s\n", OM_I_erm_NO_FREE_OIDS);
    break;
  case OM_E_NO_EXTEND_GROUP:
    printf ("%s\n", OM_E_erm_NO_EXTEND_GROUP);
    break;
  case OM_E_NO_DELETE_GROUP:
    printf ("%s\n", OM_E_erm_NO_DELETE_GROUP);
    break;
  case OM_E_NO_DELETE_CLUSTER:
    printf ("%s\n", OM_E_erm_NO_DELETE_CLUSTER);
    break;
  case OM_E_AMBIGUOUS_CHANNAME:
    printf ("%s\n", OM_E_erm_AMBIGUOUS_CHANNAME);
    break;
  case OM_E_NOPASSPASS:
    printf ("%s\n", OM_E_erm_NOPASSPASS);
    break;
  case OM_E_INVSTSTYPE:
    printf ("%s\n", OM_E_erm_INVSTSTYPE);
    break;
  case OM_E_OBJSIZE_TOOBIG:
    printf ("%s\n", OM_E_erm_OBJSIZE_TOOBIG);
    break;
  case OM_E_CLUSTEXT_TOOBIG:
    printf ("%s\n", OM_E_erm_CLUSTEXT_TOOBIG);
    break;
  case OM_E_NOEXTEND_GROUP:
    printf ("%s\n", OM_E_erm_NOEXTEND_GROUP);
    break;
  case OM_E_ILLEGAL_GROUP0:
    printf ("%s\n", OM_E_erm_ILLEGAL_GROUP0);
    break;
  case OM_E_DUPGRPNAME:
    printf ("%s\n", OM_E_erm_DUPGRPNAME);
    break;
  case OM_E_DUPCLUSTNAME:
    printf ("%s\n", OM_E_erm_DUPCLUSTNAME);
    break;
  case OM_E_WRITE_ERROR:
    printf ("%s\n", OM_E_erm_WRITE_ERROR);
    break;
  case OM_E_READ_ERROR:
    printf ("%s\n", OM_E_erm_READ_ERROR);
    break;
  case OM_W_SIZE_TOO_SMALL:
    printf ("%s\n", OM_W_erm_SIZE_TOO_SMALL);
    break;
  case OM_E_NULL_STRING:
    printf ("%s\n", OM_E_erm_NULL_STRING);
    break;
  case OM_I_READ_FROM_FILE:
    printf ("%s\n", OM_I_erm_READ_FROM_FILE);
    break;
  case OM_W_OS_NOT_IN_MOSD:
    printf ("%s\n", OM_W_erm_OS_NOT_IN_MOSD);
    break;
  case OM_E_NO_DISK_SPACE:
    printf ("%s\n", OM_E_erm_NO_DISK_SPACE);
    break;
  case OM_E_MOSDOS_OS:
    printf ("%s\n", OM_E_erm_MOSDOS_OS);
    break;
  case OM_E_TRANS_OS:
    printf ("%s\n", OM_E_erm_TRANS_OS);
    break;
  case OM_E_DUPSYMNAME:
    printf ("%s\n", OM_E_erm_DUPSYMNAME);
    break;
  case OM_I_UNABLE_TO_CONNECT:
    printf ("%s\n", OM_I_erm_UNABLE_TO_CONNECT);
    break;
  case OM_E_BADCHAN_TYPE:
    printf ("%s\n", OM_E_erm_BADCHAN_TYPE);
    break;
  case OM_I_NOMATCH:
    printf ("%s\n", OM_I_erm_NOMATCH);
    break;
  case OM_E_SYMBOLNOTFOUND:
    printf ("%s\n", OM_E_erm_SYMBOLNOTFOUND);
    break;
  case OM_I_LOGICAL_DISCONNECT:
    printf ("%s\n", OM_I_erm_LOGICAL_DISCONNECT);
    break;
  case  OM_E_SPECIAL_FILE:
    printf("%s\n",  OM_E_erm_SPECIAL_FILE);
    break;
  case  OM_E_INACCESSABLE_FILE:
    printf("%s\n",  OM_E_erm_INACCESSABLE_FILE);
    break;
  case  OM_I_NOEXIST_WRITEABLE_FILE:
    printf("%s\n",  OM_I_erm_NOEXIST_WRITEABLE_FILE);
    break;
  case  OM_I_EXIST_READONLY_FILE:
    printf("%s\n",  OM_I_erm_EXIST_READONLY_FILE);
    break;
  case  OM_I_EXIST_READ_WRITE_FILE:
    printf("%s\n",  OM_I_erm_EXIST_READ_WRITE_FILE);
    break;
  case  OM_I_READ_FROM_RO_FILE:
    printf("%s\n",  OM_I_erm_READ_FROM_RO_FILE);
    break;
  case  OM_E_FILEISDIR:
    printf("%s\n",  OM_E_erm_FILEISDIR);
    break;
  case  OM_E_INVSWAPMARKS:
    printf("%s\n",  OM_E_erm_INVSWAPMARKS);
    break;
  case  OM_E_INV_CLUSTEXT:
    printf("%s\n",  OM_E_erm_INV_CLUSTEXT);
    break;
  case  OM_E_INTERNALS_CORRUPT:
    printf("%s\n",  OM_E_erm_INTERNALS_CORRUPT);
    break;
  case  OM_E_NOTTAGGED:
    printf("%s\n",  OM_E_erm_NOTTAGGED);
    break;
  case  OM_E_TAGEXISTS:
    printf("%s\n",  OM_E_erm_TAGEXISTS);
    break;
  case  OM_W_NOTTAGGED:
    printf("%s\n",  OM_W_erm_NOTTAGGED);
    break;
  case  OM_E_NOSUCHTAG:
    printf("%s\n",  OM_E_erm_NOSUCHTAG);
    break;
  case  OM_E_NOAVAILABLETAG:
    printf("%s\n",  OM_E_erm_NOAVAILABLETAG);
    break;
  case  OM_E_BADSENDDEPTH:
    printf("%s\n",  OM_E_erm_BADSENDDEPTH);
    break;
  case  OM_E_BADPROMCLASS:
    printf("%s\n",  OM_E_erm_BADPROMCLASS);
    break;
  case  OM_E_INTERCEPTED:
    printf("%s\n",  OM_E_erm_INTERCEPTED);
    break;
  case  OM_W_NOINTERCEPT:
    printf("%s\n",  OM_W_erm_NOINTERCEPT);
    break;

/*=========================*/
/* UNIX system error codes */
/*=========================*/

  case UNIX_E_EPERM:
    printf ("%s\n", UNIX_E_erm_EPERM);
    break;
  case UNIX_E_ENOENT:
    printf ("%s\n", UNIX_E_erm_ENOENT);
    break;
  case UNIX_E_ESRCH:
    printf ("%s\n", UNIX_E_erm_ESRCH);
    break;
  case UNIX_E_EINTR:
    printf ("%s\n", UNIX_E_erm_EINTR);
    break;
  case UNIX_E_EIO:
    printf ("%s\n", UNIX_E_erm_EIO);
    break;
  case UNIX_E_ENXIO:
    printf ("%s\n", UNIX_E_erm_ENXIO);
    break;
  case UNIX_E_E2BIG:
    printf ("%s\n", UNIX_E_erm_E2BIG);
    break;
  case UNIX_E_ENOEXEC:
    printf ("%s\n", UNIX_E_erm_ENOEXEC);
    break;
  case UNIX_E_EBADF:
    printf ("%s\n", UNIX_E_erm_EBADF);
    break;
  case UNIX_E_ECHILD:
    printf ("%s\n", UNIX_E_erm_ECHILD);
    break;
  case UNIX_E_EAGAIN:
    printf ("%s\n", UNIX_E_erm_EAGAIN);
    break;
  case UNIX_E_ENOMEM:
    printf ("%s\n", UNIX_E_erm_ENOMEM);
    break;
  case UNIX_E_EACCES:
    printf ("%s\n", UNIX_E_erm_EACCES);
    break;
  case UNIX_E_EFAULT:
    printf ("%s\n", UNIX_E_erm_EFAULT);
    break;
  case UNIX_E_ENOTBLK:
    printf ("%s\n", UNIX_E_erm_ENOTBLK);
    break;
  case UNIX_E_EBUSY:
    printf ("%s\n", UNIX_E_erm_EBUSY);
    break;
  case UNIX_E_EEXIST:
    printf ("%s\n", UNIX_E_erm_EEXIST);
    break;
  case UNIX_E_EXDEV:
    printf ("%s\n", UNIX_E_erm_EXDEV);
    break;
  case UNIX_E_ENODEV:
    printf ("%s\n", UNIX_E_erm_ENODEV);
    break;
  case UNIX_E_ENOTDIR:
    printf ("%s\n", UNIX_E_erm_ENOTDIR);
    break;
  case UNIX_E_EISDIR:
    printf ("%s\n", UNIX_E_erm_EISDIR);
    break;
  case UNIX_E_EINVAL:
    printf ("%s\n", UNIX_E_erm_EINVAL);
    break;
  case UNIX_E_ENFILE:
    printf ("%s\n", UNIX_E_erm_ENFILE);
    break;
  case UNIX_E_EMFILE:
    printf ("%s\n", UNIX_E_erm_EMFILE);
    break;
  case UNIX_E_ENOTTY:
    printf ("%s\n", UNIX_E_erm_ENOTTY);
    break;
  case UNIX_E_ETXTBSY:
    printf ("%s\n", UNIX_E_erm_ETXTBSY);
    break;
  case UNIX_E_EFBIG:
    printf ("%s\n", UNIX_E_erm_EFBIG);
    break;
  case UNIX_E_ENOSPC:
    printf ("%s\n", UNIX_E_erm_ENOSPC);
    break;
  case UNIX_E_ESPIPE:
    printf ("%s\n", UNIX_E_erm_ESPIPE);
    break;
  case UNIX_E_EROFS:
    printf ("%s\n", UNIX_E_erm_EROFS);
    break;
  case UNIX_E_EMLINK:
    printf ("%s\n", UNIX_E_erm_EMLINK);
    break;
  case UNIX_E_EPIPE:
    printf ("%s\n", UNIX_E_erm_EPIPE);
    break;
  case UNIX_E_EDOM:
    printf ("%s\n", UNIX_E_erm_EDOM);
    break;
  case UNIX_E_ERANGE:
    printf ("%s\n", UNIX_E_erm_ERANGE);
    break;
  case UNIX_E_ENOMSG:
    printf ("%s\n", UNIX_E_erm_ENOMSG);
    break;
  case UNIX_E_EIDRM:
    printf ("%s\n", UNIX_E_erm_EIDRM);
    break;
  case UNIX_E_ECHRNG:
    printf ("%s\n", UNIX_E_erm_ECHRNG);
    break;
  case UNIX_E_EL2NSYNC:
    printf ("%s\n", UNIX_E_erm_EL2NSYNC);
    break;
  case UNIX_E_EL3HLT:
    printf ("%s\n", UNIX_E_erm_EL3HLT);
    break;
  case UNIX_E_EL3RST:
    printf ("%s\n", UNIX_E_erm_EL3RST);
    break;
  case UNIX_E_ELNRNG:
    printf ("%s\n", UNIX_E_erm_ELNRNG);
    break;
  case UNIX_E_EUNATCH:
    printf ("%s\n", UNIX_E_erm_EUNATCH);
    break;
  case UNIX_E_ENOCSI:
    printf ("%s\n", UNIX_E_erm_ENOCSI);
    break;
  case UNIX_E_EL2HLT:
    printf ("%s\n", UNIX_E_erm_EL2HLT);
    break;
  case UNIX_E_EDEADLK:
    printf ("%s\n", UNIX_E_erm_EDEADLK);
    break;

/* Not a recognized error code, so give appropriate unknown message */

  default:
    switch (7 & sts)
    {
    case INFO:
      printf ("OM_I_, unknown informational status\n");
      break;
    case WARN:
      printf ("OM_W_, unknown error status\n");
      break;
    case ERRO:
      printf ("OM_E_, unknown error status\n");
      break;
    case SEVE:
      printf ("OM_F_, unknown error status\n");
      break;
    default:
      printf ("OM_?_, unknown error status\n");
      break;
    }
    break;
  }
}
