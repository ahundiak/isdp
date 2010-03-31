class implementation Root;
 
#include <string.h>
#include <stdlib.h>
#include "OMlimits.h"
#include "OMtypes.h"
#include "OMOSfilehdr.h" 
#ifdef BIG_ENDIAN
#include "OMport.h"
extern int som_bigend_portHdr();
extern int som_convert_instance();
extern OMuint OM_Gf_ioMode;
#endif
#include "igrtypedef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/os.h"
#include "PWapi/objaccess.h"
#include "PWgmdata.h"
#include "PWapi/clsid.h"
#include "PWapi/ommisc.h"
#include "PWapi/msgsend.h"

#define STRING_MATCH 0

from OMFiledOS import set_state;

extern IGRboolean GRabsg_del_all();

/*
  ABSTRACT

  This function initializes OM. It needs to be called just once during the
  execution of a process that utilizes OM.
*/

PWresult omRuntimeInit
(
)
{
  return (PWresult) som_runtime_init (0, (char **) NULL);
}


/*
  ABSTRACT

  This function constructs an object space from an OM-datafile. The object
  space constructed is always a filed object space (OMFiledOS). The object
  space number along with the objid of the object-space object is returned.

  Optionally, if the output argument -- 'numobjs_in_space' -- is passed in
  as non-NULL, this function computes the number of objects constructed within
  this object space and returns it in the location.
*/

PWresult omConstructOS 
(
  char *filename,
  PWobjid *osobjid,
  PWosnum *osnum,
  int *numobjs_in_space
)
{
  char osclassname[OM_K_MAXCLASS_LEN];
  
  strcpy (osclassname, "OMFiledOS");
  return (PWresult) som_construct_os_by_name (osclassname, osnum, filename, 
                     osobjid, 0, 0, (unsigned int *)numobjs_in_space, 0, 0, 0, (char *) NULL);
}


/*
  ABSTRACT

  This function retrieves the os number given a file that has been already
  loaded in the OM susb-system.
*/

PWresult omFileNameToOS 
(
  char *filename,
  PWosnum *osnum
)
{
  char   intFileName[32];
  FILE   *fp = NULL;
  PWresult result=PW_K_Success;
  unsigned int   oso_instance, i, tempint;
  void lswapint();

  memset(intFileName, 0, 32);

#ifndef NT
  if ( (fp = fopen(filename, "r")) == NULL)
#else
  if ( (fp = fopen(filename, "rb")) == NULL)
#endif
  {
    OnErrorState (TRUE, result,
      SetError (PW_K_Pathway, PW_K_NotFound), wrapup);
  }

  fseek(fp, 28, 0); // fp_OSO_instance

  if (fread(&oso_instance, 1, 4, fp) != 4)
  {
    OnErrorState (TRUE, result,
      SetError (PW_K_Pathway, PW_K_Internal), wrapup);
  }

#ifdef BIG_ENDIAN
  lswapint(&oso_instance, &tempint);
  oso_instance = tempint;
#endif

  fseek(fp, oso_instance + 182, 0);
  if (fread(intFileName, 1, 32, fp) != 32)
  {
   OnErrorState (TRUE, result,
     SetError (PW_K_Pathway, PW_K_Internal), wrapup);
  }

  for (i=0; i< OM_Gw_maxOS; i=i++)
  {
    if (OM_GA_OSDs[i] && !(strcmp(intFileName, OM_GA_OSDs[i]->InternalName)))
    {
      *osnum = i;
      break;
    }
  }

  OnErrorState ( (OM_Gw_maxOS == i), result,
    SetError (PW_K_Pathway, PW_K_NotFound), wrapup);

wrapup:
  if(fp) { fclose(fp); fp = NULL; }
  PW_Wrapup (result, "omFileNameToOS");
  return (result);
}


PWresult omDeleteOS
(
  PWosnum osnum
)
{
  int defer = 0, sts;
  PWobjid filed_id;
  PWresult result=PW_K_Success;
  IGRboolean delall_ok = FALSE;

  delall_ok = GRabsg_del_all();


  filed_id = omObjOfClass (omClassidFromName ("OMFiledOS", osnum), osnum);
  OnErrorState (filed_id == PW_K_NullObjid, result,
   SetError (PW_K_Pathway, PW_K_NotFound), wrapup);

  sts = om$send( msg = message OMFiledOS.set_state((int)0),
	  senderid = filed_id, targetid = filed_id, targetos = osnum);
  OnErrorState (!(1&sts), result,
   SetError (PW_K_Pathway, PW_K_Internal), wrapup);

  sts = om$send( msg = message OMFiledOS.delete(defer),
	  senderid = filed_id, targetid = filed_id, targetos = osnum);
  OnErrorState (!(1&sts), result,
   SetError (PW_K_Pathway, PW_K_Internal), wrapup);

wrapup:
  PW_Wrapup (result, "omDeleteOS");
  return (result);
}


 
/*
  ABSTRACT
 
  This function Writes the object space . 
  Give as input the objid and osnum returned by omConstructOS().

*/

PWresult omWriteOS 
( 
  PWosnum osnum,
  PWobjid osobjid
)
{
  char answer[40], new_filename[PW_K_MaxStringLen], *p_name=NULL;
  PWresult result = PW_K_Success;
  struct PWommsg write_messg;
  struct {char *osname;} write_args;

  answer[0] = new_filename[0] = 0; // Keep compiler happy
  write_args.osname = p_name;
  result = omMakeMessage ("OMFiledOS", "write", (void *) &write_args, 
            sizeof (write_args), &write_messg);
  som_report_error( result);
  OnErrorCode (result, wrapup);

  result = omSend (&write_messg, osobjid, osnum, PW_K_NullObjid, FALSE);
  som_report_error( result );
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "omWriteOS");
  return ( result );
}

/*
  ABSTRACT
 
  This function sets the state flag to non-save and deletes the
  object space.
 
*/

PWresult omCloseOS 
(
  PWosnum osnum
)
{
  struct PWommsg setstate_messg;
  struct PWommsg delete_messg;
  struct {int set_state;} setstate_args;
  struct {int defer_flag;} delete_args;
  PWobjid  osobjid = PW_K_NullObjid;
  PWresult result;

  IGRboolean delall_ok = FALSE;

  delall_ok = GRabsg_del_all();


  osobjid = omObjOfClass (omClassidFromName ("OMFiledOS", osnum), osnum); 

  setstate_args.set_state = 0;
  result = omMakeMessage ("OMFiledOS", "set_state", (void *) &setstate_args, 
            sizeof (setstate_args), &setstate_messg);
  som_report_error( result);
  OnErrorCode (result, wrapup);

  result = omSend (&setstate_messg, osobjid, osnum, PW_K_NullObjid, FALSE);
  som_report_error( result );
  OnErrorCode (result, wrapup);

  delete_args.defer_flag = 0;
  result = omMakeMessage ("OMFiledOS", "delete", (void *) &delete_args, 
            sizeof (delete_args), &delete_messg);
  som_report_error( result);
  OnErrorCode (result, wrapup);

  result = omSend (&delete_messg, osobjid, osnum, PW_K_NullObjid, FALSE);
  som_report_error( result );
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "omCloseOS");
  return ( result );
}

/*
  ABSTRACT

  Given an object space number -- 'os', this function outputs the full
  path name of the file it corresponds to. The 'filename' string is
  expected to be atleast PW_K_MaxCharFilename.
*/

PWresult omGetFileName 
(
  PWosnum os,
  char *filename
)
{
   PWresult result=PW_K_Success;

   om$os_number_to_name (osnum = os, osname = filename);
  
   return (result);
}

/*
  ABSTRACT

  This function gets the version of the product in which the file was
  most recently updated (saved). The product is spelt out in a string
  input, 'prodname', eg: "I/MODEL". The function outputs the four-piece
  version stamp (eg: 03.02.00.29) in the arguments -- 'ver[0]' (eg:3),
  'ver[1]' (eg: 2), 'ver[2]' (eg: 0), 'ver[3]' (eg: 29). The output 
  array 'ver' of size 4, is to be allocated by the caller.
*/

PWresult omGetProdVersion
(
  PWosnum os,
  char *prodname,
  int ver[4]
)
{
  PWboolean found=FALSE;
  char filename[PW_K_MaxCharFilename+1];
  char appver_str[OM_K_APPVER_LEN+1];
  char delimiters[5],  *token;
  int i, j, num_appver, num_bytes;
  FILE *file=NULL;
  PWresult result=PW_K_Success;
  OM_S_OS_FILEHDR hdr;

  for (i=0; i<4; i++)
    ver[i] = 0;

  /*
   * Obtain the disk-file name of this os
   */

  result = omGetFileName (os, filename);
  OnErrorCode (result, wrapup);

  /*
   * Open the file for read
   */

  file = fopen (filename, "r");
  OnErrorState (!file, result, SetError (PW_K_OM, PW_K_NotFound), wrapup);

  /*
   * Read in the header of the OS. Take care to flip the bytes if this
   * code is being used on a big-endian platform (Sun).
   */

  fseek (file, 0, 0);
  if (fread (&hdr, 1, sizeof(OM_S_OS_FILEHDR), file) != 
      sizeof (OM_S_OS_FILEHDR))
    OnErrorState (TRUE, result, SetError (PW_K_OM, PW_K_Internal), wrapup);

# ifdef BIG_ENDIAN
  OM_Gf_ioMode = READ_PORT;
  som_bigend_portHdr ((OM_S_OS_FILEHDR *) &hdr.magic);
# endif

  /*
   * For every application version stamp found in the header, retrieve
   * the string and scan it for the prod-name supplied as input to this
   * function. On finding it, scan the string further for the version
   * numbers.
   */

  num_appver = hdr.i_num_appver;
  OnErrorState (!num_appver, result, SetError (PW_K_OM, PW_K_NotFound),
   wrapup);

  fseek (file, hdr.fp_appver, 0);
  for (i=0; i<num_appver; i++)
  {
    num_bytes = fread (appver_str, 1, OM_K_APPVER_LEN, file);
    OnErrorState (num_bytes != OM_K_APPVER_LEN, result, 
     SetError (PW_K_OM, PW_K_NotFound), wrapup);

    token = strtok (appver_str, " ");
    if (strcmp (appver_str, prodname) == STRING_MATCH)
    {
      for (j=0; j<4; j++)
      {
        strcpy (delimiters, " ");
        if (j < 3)
          strcat (delimiters, ".");
        token = strtok (NULL, " .");
        OnErrorState (!token, result, SetError (PW_K_OM, PW_K_NotFound),
         wrapup);

        ver[j] = atoi (token);
      }
      found = TRUE;
    }
  }
  OnErrorState (!found, result, SetError (PW_K_OM, PW_K_NotFound),
   wrapup);

wrapup:
  PW_Wrapup (result, "omGetSaveVersion");
  return (result);
}

#ifdef BIG_ENDIAN
void lswapint(src, dest)
unsigned char  *src, *dest;
{
   dest[0] = src[3];
   dest[1] = src[2];
   dest[2] = src[1];
   dest[3] = src[0];
}
#endif


end implementation Root;

