/* $Id: VDRAPcobCOi.I,v 1.3 2001/03/06 15:11:13 hans Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrap / VDRAPcobCOi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDRAPcobCOi.I,v $
 *	Revision 1.3  2001/03/06 15:11:13  hans
 *	Append to file if less than 12H old.
 *	
 *	Revision 1.2  2001/03/05 15:45:24  hans
 *	*** empty log message ***
 *	
 *	Revision 1.1  2001/03/02 22:55:45  hans
 *	Created
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	03/02/2001	HF		Creation
 *					Adapted from GRNUC "start and record"
 *
 * -------------------------------------------------------------------*/

class implementation VDRAPcobCO;

#include "sys/types.h"
#include "sys/stat.h"

#include "coimport.h"
#include "grerr.h"
#include "grmessage.h"
#include "codef.h"
#include "msdef.h"
#include "dpdef.h"
#include "griodef.h"
#include <stdio.h>
#include <limits.h>
#include "VDRAPdefs.h"
#include "exdef.h"
#include "exmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "FEI.h"

from VDRAPlisnr import init_new_file,append_to_file,remove_last_command,finish;

method init ( int type ; char * str_ptr )
{
  int  status = OM_S_SUCCESS;

   OM_S_OBJID nod_id;

   status = om$send ( msg      = message CEO_LOCATE.init ( type, str_ptr ),
                      targetid = my_id,
                      mode     = OM_e_wrt_message );

   /* Create the VDRAP NOD if it does not already exist */

   status = ex$get_NOD(NODname   = NOD_NAME,
                       pobjid    = &nod_id,
                       create    = TRUE,
                       modid     = OM_GO_TransOS_0,
                       mod_osnum = OM_Gw_TransOSnum_0);
quit:
  return OM_S_SUCCESS;
}

method does_listener_exist ( long * sts )
{
  int  status = OM_S_SUCCESS;

   OM_S_OBJID lisnr_id;

   *sts = MSSUCC;

   /* see if the listener object exists */

   status = ex$get_objid_from_NOD(NODname = NOD_NAME,
                                objname   = LISTENER_NAME,
                                pobjid    = &lisnr_id,
                                modid     = OM_GO_TransOS_0,
                                mod_osnum = OM_Gw_TransOSnum_0);

   if (status != OM_S_SUCCESS)
   {
      *sts = MSFAIL;
   }
quit:
  return OM_S_SUCCESS;
}

method remove_last_command ( long * sts )
{
  int  status = OM_S_SUCCESS;

   OM_S_OBJID lisnr_id;

   status = ex$get_objid_from_NOD(NODname = NOD_NAME,
                                objname   = LISTENER_NAME,
                                pobjid    = &lisnr_id,
                                modid     = OM_GO_TransOS_0,
                                mod_osnum = OM_Gw_TransOSnum_0);

   if (status == OM_S_SUCCESS)
   {
      status = om$send(msg      = message VDRAPlisnr.remove_last_command(),
                       targetid = lisnr_id,
                       targetos = OM_Gw_TransOSnum_0);
   }
quit:
  return OM_S_SUCCESS;
}

method have_filename (int *sts;  int  file_flag)
{
  int  status = OM_S_SUCCESS;

   char        filename[DI_PATH_MAX];
   FILE       *fp;
   OM_S_OBJID  lisnr_id;
   IGRboolean  screw_it_up = TRUE;

   *sts = MSSUCC;

   /* check for null pointer for SUN.  TGM 11/21/91 */
   if (me->event1.subtype)
   {
     strcpy(filename,me->event1.event.keyin);
   }
   else
   {
    if (strlen( (IGRchar *) &me->event1.subtype) == GRst_DEFAULT)
    {
       strcpy(filename,DEFAULT_FILE);
    }
    else
    {
       strcpy(filename,me->event1.event.keyin);
    }
   }

   if( TRis_object_file( filename ) )
   {
      char buffer [DI_PATH_MAX];

      ex$message ( msgnumb = GR_P_FlExOv, buff = buffer );
      if(GRconfirm_box ( buffer ) == TRUE)
        screw_it_up = TRUE;
      else
        screw_it_up = FALSE;
   }

   if( !screw_it_up )
   {
     *sts = MSINARG;
   }
   else
   {
     if ( file_flag == CREATE)
     {
       struct stat fileStat;
       time_t      current_time;

       // Check the status ...
       fileStat.st_size = 0;
       stat(filename, &fileStat);

       // Current time ...
       time(&current_time);

       if (FALSE)
       {
         int delta = current_time - fileStat.st_mtime;
         printf("current_time = %d, fileStat.st_mtime = %d, delta = %d\n", current_time, fileStat.st_mtime, delta);
       }

       // If filesize == 0 OR file is older than 12 hours ...
       if (fileStat.st_size < 1 || (current_time - fileStat.st_mtime) > 12 * 3600)
       {
         fp = fopen(filename,"w");	// Create new file
       }
       else
       {
         fp = fopen(filename,"a+");	// Append to file
       }
     }
     else
     {
       fp = fopen(filename,"r+");
     }

     if (fp == NULL)  /* user given file cannot be opened */
     {
        *sts = MSFAIL;
     }
     else    /* file has been opened */
     {
        if ( file_flag == CREATE )
        {
          status = om$construct (classname = "VDRAPlisnr",
                                 osnum     = OM_Gw_TransOSnum_0,
                                 p_objid   = &lisnr_id,
                                 msg       = message VDRAPlisnr.init_new_file (fp));
        }
        else
        {
           status = om$construct (classname = "VDRAPlisnr",
                                  osnum     = OM_Gw_TransOSnum_0,
                                  p_objid   = &lisnr_id,
                                  msg       = message VDRAPlisnr.append_to_file (fp));
        }

        if (status == OM_S_SUCCESS)
        {
           status = ex$add_name_to_NOD(NODname = NOD_NAME,
                                   objname     = LISTENER_NAME,
                                   objid       = lisnr_id,
                                   mod_osnum   = OM_Gw_TransOSnum_0);

           status = ex$attach_input_listener (objid = lisnr_id,
                                              osnum = OM_Gw_TransOSnum_0);

           *sts = MSSUCC;
        }
        else
        {
           *sts = MSFAIL;
        }
     }
   }
quit:
  return OM_S_SUCCESS;
}

method stop_record ( long * sts )
{
  int  status = OM_S_SUCCESS;

    OM_S_OBJID lisnr_id;

    *sts = MSSUCC;

    /* get id of listener object from NOD */

    status = ex$get_objid_from_NOD(NODname   = NOD_NAME,
                                   objname   = LISTENER_NAME,
                                   pobjid    = &lisnr_id,
                                   modid     = OM_GO_TransOS_0,
                                   mod_osnum = OM_Gw_TransOSnum_0);

    if (status != OM_S_SUCCESS)
    {
        *sts = MSFAIL;
    }
    else
    {
       /* detach input listener from software queue */

       status = ex$detach_input_listener(objid = lisnr_id,
                                         osnum = OM_Gw_TransOSnum_0);

       /* tell the listener to finish up ( close ci file,etc ) */

       status = om$send (msg      = message VDRAPlisnr.finish (),
                         targetid = lisnr_id,
                         targetos = OM_Gw_TransOSnum_0);

       /* delete the listener.  this also removes the listener id from the NOD. */

       status = om$send (msg      = message Root.delete (0),
                         targetid = lisnr_id,
                         targetos = OM_Gw_TransOSnum_0);
   }
quit:
  return OM_S_SUCCESS;
}

end implementation VDRAPcobCO;
