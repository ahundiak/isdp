command_string  "record and playback",0,RAPcobCO
class           RAPcobCO
super_class     CEO_LOCATE
spec_path       "$PLATFORM/co/spec"
start_state     terminate
product_name    "$GRNUC"


specification

implementation

#include "coimport.h"
#include "grerr.h"
#include "grmessage.h"
#include "codef.h"
#include "msdef.h"
#include "dpdef.h"
#include "griodef.h"
#include <stdio.h>
#include <limits.h>
#include "RAPdefs.h"
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

from RAPinlisnr import init_new_file,append_to_file,remove_last_command,finish;


action init
{
   OM_S_OBJID nod_id;


   status = om$send ( msg = message CEO_LOCATE.init ( type, str_ptr ),
                      targetid = my_id,
                      mode = OM_e_wrt_message );


   /* Create the RAP NOD if it does not already exist */

   status = ex$get_NOD(NODname = NOD_NAME,
                       pobjid = &nod_id,
                       create = TRUE,
                       modid = OM_GO_TransOS_0,
                       mod_osnum = OM_Gw_TransOSnum_0);
}


action does_listener_exist
{
   OM_S_OBJID lisnr_id;


   *sts = MSSUCC;

   /* see if the listener object exists */

   status = ex$get_objid_from_NOD(NODname = NOD_NAME,
                                objname = LISTENER_NAME,
                                pobjid = &lisnr_id,
                                modid = OM_GO_TransOS_0,
                                mod_osnum = OM_Gw_TransOSnum_0);

   if (status != OM_S_SUCCESS)
   {
      *sts = MSFAIL;
   }
}


action remove_last_command
{
   OM_S_OBJID lisnr_id;

   status = ex$get_objid_from_NOD(NODname = NOD_NAME,
                                objname = LISTENER_NAME,
                                pobjid = &lisnr_id,
                                modid = OM_GO_TransOS_0,
                                mod_osnum = OM_Gw_TransOSnum_0);

   if (status == OM_S_SUCCESS)
   {
      status = om$send(msg = message RAPinlisnr.remove_last_command(),
                       targetid = lisnr_id,
                       targetos = OM_Gw_TransOSnum_0);
   }
}


action have_filename (int *sts;  int  file_flag)
{
   char filename[DI_PATH_MAX];
   FILE *fp;
   OM_S_OBJID lisnr_id;
   IGRboolean    screw_it_up = TRUE;


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
       fp = fopen(filename,"w");
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
          status = om$construct (classname = "RAPinlisnr", 
                                osnum = OM_Gw_TransOSnum_0,
                                p_objid = &lisnr_id,
                                msg = message RAPinlisnr.init_new_file (fp));
        }
        else
        {
           status = om$construct (classname = "RAPinlisnr", 
                                osnum = OM_Gw_TransOSnum_0,
                                p_objid = &lisnr_id,
                                msg = message RAPinlisnr.append_to_file (fp));
        }

        if (status == OM_S_SUCCESS)
        {
           status = ex$add_name_to_NOD(NODname = NOD_NAME,
                                   objname = LISTENER_NAME,
                                   objid = lisnr_id,
                                   mod_osnum = OM_Gw_TransOSnum_0);
    
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
}



action stop_record
{
    OM_S_OBJID lisnr_id;


    *sts = MSSUCC;

    /* get id of listener object from NOD */

    status = ex$get_objid_from_NOD(NODname = NOD_NAME,
                                   objname = LISTENER_NAME,
                                   pobjid = &lisnr_id,
                                   modid = OM_GO_TransOS_0,
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

       status = om$send (msg = message RAPinlisnr.finish (), 
		         targetid = lisnr_id,
                         targetos = OM_Gw_TransOSnum_0);

       /* delete the listener.  this also removes the listener id from
	  the NOD.
        */

       status = om$send (msg = message Root.delete (0), 
       	                 targetid = lisnr_id,
		         targetos = OM_Gw_TransOSnum_0);
   }
}
