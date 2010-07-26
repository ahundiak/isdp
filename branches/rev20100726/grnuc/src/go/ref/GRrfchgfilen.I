/*

Name
  GRrfchgfilen.I

Description
  This file contains the method to change the filename of a reference file.

Notes

*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "referr.h"
#include "exmacros.h"

/*
Name
  GRchgfilename

Abstract
  Change the filename of a reference file

Synopsis
  GRchgfilename(msg,new_filename,new_mount_name)

  long  *msg            O    Completion code
  char  *new_filename   I    the new filename for the reference file
  char  *new_mount_name I    the name for mounting the reference file

Description
  This method changes the file name stored in the reference
  file object.  The old file, if available, is closed and the
  new file will be opened.

Return Value
  The possible return code values in the msg field are:

  MSSUCC - successful completion
  MSFAIL - error occured

Notes

Index

Keywords
  method, reference-file

History
  05/04/87 : MAS : creation date
  07/04/89 : jhw : Remove mount name before calling GRname_reffile
  07/06/92 : dhm : ANSI conversion
  02/10/93 : dhm : fix for TR 119301097
  04/02/93 : jhw : fix for TR 119303815, remove of file from writables list.

*/

extern unsigned int OM_Gf_verbose_warning;

from Super_rfmgr import 
    translate, force_translate, add, force_add, remove_file_name;

method GRchgfilename ( long *msg; char *new_filename; char *new_mount_name )
{
  IGRboolean  constr_flag=TRUE;
  long        type;
  long        OMmsg, has_a_name;
  int         dimension, dimension2;
  int         sts;
  char        logical[DI_PATH_MAX];
  char        temp_name[DI_PATH_MAX];
  char        split_name[DI_PATH_MAX];
  struct GRid refmgr;
  GRspacenum  osnum, temp_osnum;
  GRobjid     modid;
  struct GRid context, ref_id;

  OMmsg = OM_S_SUCCESS;
  *msg = MSSUCC;

  dimension = om$dimension_of ( varray = me->filename );

  if (dimension)
  {
    type = 0;
    om$send ( msg = message GRreffile.GRrfclose ( msg, &type ), targetid = my_id );
/*  }  TR 119301097 - moved this block to include code that only needs to be
       done if there is already a filename */

  /* 
      Check whether the current attachment is writable or force_writable.
      Remove the entry from the writable list if it is there; then add the new
      name.  The message interface to the writable list is used rather than
      the function interface since not all of the functions accept an object
      space number, since there are some cases (notably Revise Assembly, when
      updating attachments) that use this method when the current space is not
      the same as the master space.
  */
  ex$get_modid(mod_id = &modid, mod_osnum = OM_Gw_current_OS);
  ex$get_super(mod_id = modid,
               mod_osnum = OM_Gw_current_OS,
               super_name = "Ref Mgr",
               create = 0,
               super_id = &refmgr.objid,
               super_osnum = &refmgr.osnum);
  sts = om$send(msg = message Super_rfmgr.translate(msg, me->filename),
                targetid = refmgr.objid,
                targetos = refmgr.osnum);
  if (sts & *msg & 1)
  {
      /* file is writable - remove the old name from the list */
      /* 
       * TR119303815 - Comment out remove_file_name send in GRrfchgfilename
       * method since the GRrfclose, called above, will remove the filename 
       * from the writables list if it's the last ref attach with that
       * file.
      sts = om$send(msg = message Super_rfmgr.remove_file_name(msg, 
                                                               me->filename),
                                  targetid = refmgr.objid,
                                  targetos = refmgr.osnum);
      if (!(sts & *msg & 1) && OM_Gf_verbose_warning)
          printf("Failed to remove %s from the writable list\n", me->filename);
      */

      /* is it a force writable? */
      sts = om$send(msg = message Super_rfmgr.force_translate(msg, 
                                                              me->filename),
                    targetid = refmgr.objid,
                    targetos = refmgr.osnum);

      if (sts & *msg & 1)
          /* file is force writable - add it to the list */
          sts = om$send(msg = message Super_rfmgr.force_add(msg, new_filename),
                        targetid = refmgr.objid,
                        targetos = refmgr.osnum);
      else
          /* add the new name to the list */
          sts = om$send(msg = message Super_rfmgr.add(msg, new_filename),
                        targetid = refmgr.objid,
                        targetos = refmgr.osnum);
      if (!(sts & *msg & 1) && OM_Gf_verbose_warning)
          printf("Failed to add %s to the writable list\n", new_filename);
  }

  }  /* end if (dimension) */

  dimension2 = strlen ( new_filename )+1;
  if (dimension < dimension2)
    OMmsg = om$vla_set_dimension ( size = dimension2, varray = me->filename );

  if (1 & OMmsg)
  {
    OMmsg = om$vla_set_dimension ( size = 0, varray = me->osname );
    if (1 & OMmsg)
    {
      ref_id.objid = my_id;
      ref_id.osnum = OM_Gw_current_OS;

      /*
       * Store the new filename. 
       * The translator depends on this newfilename being
       * in the instance data of the reffile object even if 
       * the directory for that file could not be mounted.
       */
      strcpy(me->filename, new_filename);

      /*
       * Remove the old mount name.
       * 
       * NOTE: The old name must be removed since the
       *       GRname_reffile function checks for duplicate
       *       names. By removing the old name before calling
       *       the GRname_reffile function the caller can 
       *       change the filename and keep the old mountname.
       */
      has_a_name = di$untranslate ( objname = temp_name, objid = my_id );
      if (1 & has_a_name)
      {
        /* an error from untranslate is okay, the attachment was
         * created by the translator.
         */
        di$rm_name ( regexp = temp_name );

        /*
         * If a null string is passed in for the new mount name
         * don't change the mount name.
         */

        if (new_mount_name[0] == '\0')
        {
          di$split ( pathname = temp_name, name = split_name );
          new_mount_name = split_name;
        }
      }

      /*
       * Rename the reference file.
       */
      OMmsg = GRname_reffile ( msg, new_mount_name, new_filename, &ref_id, &constr_flag,
       logical );
      if (!(1 & OMmsg))
      {
        if (*msg == GRNAMEDUPLICATED)
          if (1 & has_a_name)
            di$mkpath ( pathname = temp_name, objid = my_id, p_osnum = &temp_osnum );
        goto wrapup;
      }

      constr_flag = FALSE;
      OMmsg = om$send ( msg = message GRreffile.GRrfinit ( msg, &constr_flag, logical,
       &osnum, &modid, &context ), targetid = my_id );
    }
    else
      *msg = MSFAIL;
  }
  else
    *msg = MSFAIL;

wrapup:
  GR_NOTIFY_LISTENERS ( msg, &OMmsg, GR_ATTR_MODIFIED );
  return OMmsg;
}


end  implementation GRreffile;
