/* $Id: VDSutil.c,v 1.2 2001/02/14 15:22:19 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDSutil.c
 *
 * Description: Gather some functionalities about reading and ascii file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSutil.c,v $
 *	Revision 1.2  2001/02/14 15:22:19  ramarao
 *	Added VD_report_error function.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
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
 *	12/30/91	CH		File Creation.
 *	02/14/01	RR		Added reporting error function.
 * -------------------------------------------------------------------*/

#include <stdio.h>
#define OM_DEFINE_ERRMSG
#include "OMerrordef.h"
#define UNIX_D_DEFINE_ERRMSG
#include "UNIXerrdef.h"

#define TRUE	1

/*                                                                      */
/* VDSOpenFile:                                                         */
/*                                                                      */
/* Given a file name, opens it.                                         */
/* Product is the product name. If not used put NULL.                   */
/* If the product name is used, a ralative path (sub_dir) to it can be  */
/* defined (NULL if not used).                                          */
/*                                                                      */
/* If product name is defined "cur_dir" indicates if the funtion tries  */
/* first to open it in the current dir or not                           */
/*                                                                      */
/* Return FALSE if false.                                               */
/*                                                                      */
/* Simple call VDSOpenFile("file_name", "Vds", "config", FASLE, &fp);   */
/*                                                                      */
/*                                                                      */


VDSOpenFile(file, product, sub_dir, cur_dir, fp)
char *file;	/* file name 				 (I) */
char *product;  /* Product name				 (I) */
char *sub_dir;  /* relative dir under the product        (I) */
int  cur_dir;	/* TRUE => look first in the current dir (I) */
FILE **fp;	/* pointeur to the file 		 (O) */
{
 char product_path[256];

 *fp = NULL;
 if(file == NULL) return 0;

 if(product == NULL || cur_dir == TRUE)
  {
   *fp=fopen(file,"r");
   if(*fp!=NULL)
    {
     /* The file is opened */
     return 1;
    }
  }

 if(product != NULL)
  {
   /* Try the product path */
   if(get_modtype_data(product,NULL,NULL,NULL,NULL,product_path) == 0)
    {
     /* Something wrong like the product name ... */
     return 0;
    }

   strcat(product_path,"/");

   if(*sub_dir != NULL)
    {
     /* add the sub path */
     strcat(product_path,sub_dir);
     strcat(product_path,"/");
    }
   strcat(product_path,file);
   *fp=fopen(product_path,"r");

   if(*fp!=NULL) return 1;
  }
 return 0;
}


VDSGetNextWord(buf, out_buf, size_out_buf, sep, next_buf)
char		*buf;		/* Input buffer		(I)   */
char		*out_buf;	/* Output buffer	(O)   */
int		 size_out_buf;  /* size of out_buf      (I)   */
char		 sep;		/* The used separator	(I)   */
char		**next_buf;     /* next word to look    (O)   */
{
 int 	i;
 char  *ptr, *strchr(), *strrchr();


 if(buf == NULL) return 0;

 /* look for the seperator in buf */
 ptr = NULL;
 ptr = strchr(buf,sep);
 if(ptr == NULL)
  {
   /* No more separator so end of line */
   *next_buf = NULL;
  }
 else
  {
   /* prepare for the next word */
   *ptr = '\0';
   *next_buf = &ptr[1];
  }


 /*| Take out first spaces */
 for(i=0;i<strlen(buf);i++)
  {
   if(buf[i] != ' ' && buf[i] != '\t') { ptr = &buf[i]; break; }
  }


 if(ptr == NULL ) { out_buf[0] = '\0'; return 1; }


 /* Take last first spaces */
 for(i=strlen(ptr)-1;i>0;i--)
  {
   if(ptr[i] != ' ' && ptr[i] != '\t') { ptr[i+1] = '\0'; break; }
  }

 if(strlen(ptr) < 1) { out_buf[0] = '\0'; return 1; }

 strncpy(out_buf, ptr, size_out_buf-1);
 if(strlen(ptr) > size_out_buf-1) out_buf[size_out_buf-1] = '\0';
 else			          out_buf[strlen(ptr)]    = '\0';

 /* Extracted word done */
 return 1;
}

void VD_report_error( sts , file_pointer )

long 	sts;    	/* the OM status code, defined in OMerrordef.h */
FILE    *file_pointer;  /* Output File Pointer */

{
  FILE      *output;

  output = file_pointer;

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
