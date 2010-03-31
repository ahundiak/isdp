
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:52 $
$Locker:  $
*/


#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>

#include "wl.h"
#include <sys/stat.h>
#include <sys/fcntl.h>

#ifndef X11
#include <sys/dir.h>
#endif

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "growner.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "go.h"
#include "msdef.h"
#include "msmacros.h"
#include "FI.h"
#include "pidef.h"
#include "plotmacros.h"
#include "transdef.h"
#include "HSplot.h"
#include "HSplot_def.h"
#include "HSplot_label.h"
#include "hsdef.h"
#include "hsmsg.h"
#include "hsmacros.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_hplot.h"

/*-----------------------------------
 *  for function
 *    HSclassify_located_object
 */

#include "HSpr_lvhl.h"

/*----------------------------------
 *  for function
 *     HFI_confirm_box
 */

#include "HSpr_co_func.h"

/*----------------------------------*/


#define ACCESS_MODE		0777

static IGRint HPstub (IGRshort object_os,
                             IGRboolean is_symbol)
   {
   return (TRUE);
   }

static void HPstub2 (OM_S_OBJID text_id,
                          OMuword text_os,
                          IGRdouble * matrix,
                          IGRshort matrix_type,
                          struct GRmd_env * master_env)
   {
   }

static char HPstopped = FALSE;

/*
extern void	HPwrite_surface();
extern void	HPwrite_curve();
*/

/*---HPsave_defaults------------------------------------------------------------------*/

/*
NAME
        HPsave_defaults: static
        
KEYWORDS
        shaded plotting
        static
        defaults
        
DESCRIPTION
        Save default information in either the design file dpb or the
        HSplot.def file
        
PARAMETERS
        info	:(IN) :  structure containing the information to save
        
GLOBALS USED
        -none-
        
FUNCTIONS CALLED
        hs$set_hplot_info
        HPfiledef
        
HISTORY
        ??/??/??	M. Lanier
                Created
*/

static void HPsave_defaults (struct HSplot_info * info)

   {
   if (info->con_flags & HP_CONTROL_USE_DPB_DEFAULTS)
      {
      hs$set_hplot_info (hplot_flags = &info->dpb_flags,
                         plot_file = info->plotfile,
                         raster_file = info->rasterfile,
                         text_file = info->textfile,
                         plot_queue = info->queue,
                         plot_x_size = &info->size_x,
                         plot_y_size = &info->size_y,
                         plot_scale = &info->scale,
                         num_copies = &info->copies,
                         date = info->date,
                         line_width_const = &info->line_width_const,
                         max_line_width = &info->max_line_width,
                         raster_type = &info->raster_type);
      }
   else
      {
      HPfiledef (
                 FALSE,
                 info->plotfile,
                 info->rasterfile,
                 info->textfile,
                 info->queue,
                 info->date,
                 &info->size_x,
                 &info->size_y,
                 &info->scale,
                 &info->copies,
                 &info->line_width_const,
                 &info->max_line_width,
                 &info->raster_type,
                 (IGRint *) & info->dpb_flags);
      }
   }

extern OMuword OPP_GRsmhdr_class_id;
extern OMuword OPP_SKgmhndlpt_class_id;
extern OMuword OPP_SKline_class_id;
extern OMuword OPP_SKpoint_class_id;
extern OMuword OPP_SKarc_class_id;
extern OMuword OPP_DMlincpx_class_id;
extern OMuword OPP_DMtxldr_class_id;
extern OMuword OPP_DMsglpara_class_id;
extern OMuword OPP_DMtxbln_class_id;
extern OMuword OPP_DMframe_class_id;
extern OMuword OPP_DMradjog_class_id;
extern OMuword OPP_DMlindia_class_id;

/*---HPwrite_object-------------------------------------------------------------------*/

/*
NAME
        HPwrite_object: static
        
KEYWORDS
        shaded plotting
        filter
        
DESCRIPTION
        Recieve an object from the plot$create_plotfile call and format
        a call to the HSURF/LVHL classify routine.  Pass in the name
        of the function that will write surfaces and curve into the
        shaded plotfile
        
PARAMETERS
        object		:(IN) : objid, osnum of the object
        module		:(IN) : module environment of the object
        props		:(IN) : properties word of the object
        sym		:(IN) : symbology information for the object
        info		:(IN) : filter data
        
GLOBALS USED
        -none-
        
FUNCTIONS CALLED
        IGEstop
        om$get_classid		: used to check
        om$is_ancestry_valid	: for symbol headers
        HSclassify_located_object
        
HISTORY
        ??/??/??	M. Lanier
                Created
                
        07/16/93	M. Lanier
                Add test to ignore horizonal constraints
*/

static IGRint HPwrite_object (struct GRid * object,
                          struct GRmd_env * module,
                                 IGRshort props,
                       struct GRsymbology * sym,
                       struct HSplot_info * info)

   {
   struct GRid fence_grid;
   IGRint status;
   OMuword elem_classid;

   /* Check the stop sign status and quit if selected */

/*
{
IGRchar classname[50];

om$get_classname( osnum = object->osnum,
                  objid = object->objid,
                  classname = classname );

fprintf( stderr, "   Classifying %d:%d - %s\n", object->objid, object->osnum, classname );
}
*/

   if (HPstopped = IGEstop ())
      return (GU_TERMINATE_PLOT);

   /* If the object is the fence, and fence contents is active skip it */

   if (!(info->dpb_flags & HS_PLOT_WINDOW_CONTENTS) &&
       (info->con_flags & HP_CONTROL_FENCE_DEFINED))
      if (object->osnum == info->fence.osnum &&
          object->objid == info->fence.objid)
         return (GU_SKIP_ELEMENT);

   /* If the object is a symbol header, or an horizonal constaint, return,
    * process it. */

   om$get_classid (osnum = object->osnum,
                   objid = object->objid,
                   p_classid = &elem_classid);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_GRsmhdr_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_SKgmhndlpt_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_SKline_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_SKpoint_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_DMlincpx_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_DMtxldr_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_DMsglpara_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_DMtxbln_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_DMframe_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_DMradjog_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   if ((om$is_ancestry_valid (subclassid = elem_classid,
                            superclassid = OPP_DMlindia_class_id) == OM_S_SUCCESS))
      return (GU_PROCESS_ELEMENT);

   fence_grid.objid = NULL_OBJID;
   fence_grid.osnum = 0;

   info->con_flags &= ~(HP_CONTROL_WRITTEN_TO_PLOTFILE | HP_CONTROL_WRITE_TO_PLOTFILE_ERROR);

   info->properties = props;
   info->symbology = sym;

   HSclassify_located_object (
                              object,
                              module,
                              module->md_env.matrix,
                              &module->md_env.matrix_type,
                              &fence_grid,
                              TRUE,
                              HPstub,
                              HPwrite_surface,
                              HPwrite_curve,
                              HPstub2,
                              (IGRchar *) info,
                              NULL);

   if (info->dpb_flags & HS_PLOT_CREATE_TEXTFILE)
      if (info->con_flags & HP_CONTROL_WRITTEN_TO_PLOTFILE)
         status = GU_SKIP_ELEMENT;
      else if (info->con_flags & HP_CONTROL_WRITE_TO_PLOTFILE_ERROR)
         status = GU_TERMINATE_PLOT;
      else
         status = GU_PROCESS_ELEMENT;
   else
      status = GU_SKIP_ELEMENT;

/*
   switch( status )
      {
      case GU_SKIP_ELEMENT: fprintf( stderr, "GU_SKIP_ELEMENT\n" );	break;
      case GU_PROCESS_ELEMENT: fprintf( stderr, "GU_PROCESS_ELEMENT\n" );	break;
      case GU_TERMINATE_PLOT: fprintf( stderr, "GU_TERMINATE_PLOT\n" );	break;
      }
*/

   return (status);
   }

/*---HPcreate_form_notify-------------------------------*/

/*
NAME
        HPcreate_form_notify
        
KEYWORDS
        shaded plotting
        create shaded plotfile
        notification
        
DESCRIPTION
        Notification routine for the create shaded plotfile
        form
        
PARAMETERS
        gadget_label	:(IN) : Id of the gadget selected
        info		:
        
GLOBALS USED
        -none-
        
FUNCTIONS CALLED
        FI_confirm_box		FI_message_box
        FIf_get_location	FIfld_set_text
        FIg_disable		FIg_get_text
        FIg_reset		FIg_set_state_off
        FIg_set_state_on	FIg_set_text
        HPdisplay_queue_form	HPdisplay_submit_form
        HPfind_fence		HPsave_defaults
        HPwrite_header		HPwrite_init
        IGEresetstop		close
        creat			ex$message
        getenv			lseek
        memcpy			open
        plot$create_plotfile	sleep
        sprintf			sscanf
        stat (sun only)		statl (clipper only)
        strcat			strcmp
        strlen			unlink

HISTORY
        ??/??/??	M. Lanier
                Created
*/

void HPcreate_form_notify (IGRint gadget_label,
               struct HSplot_info * info)

   {
   char buf[256], buf0[125], buf1[40], buf2[40], buf3[40];
   IGRlong sts, msg;
   int status, i;
   int xpos, ypos;
   char *textfile;

#  ifdef CLIX
   struct statl stbuf;
#  else
   struct stat stbuf;
#  endif

   info->switch1 = 0;
   switch (gadget_label)
      {
      case CP_PLOTFILE:

         /*
          * Support of the shaded plotfile field.  Get the shaded plotfile
          * name from the field
          */

         FIg_get_text (info->displayed_form, CP_PLOTFILE, buf);


         /*
          * If the name in the field is identical to that that is already
          * stored in the info structure, don't do anything
          */

         if (strcmp (buf, info->plotfile) == 0)
            break;


         /*
          * If the file already exist display a messages and as the user to
          * accept or reject (overwrite or other name)
          */

#        ifdef CLIX
         if (!statl (buf, &stbuf))
#        else
         if (!stat (buf, &stbuf))
#        endif
            {
            ex$message (msgnumb = HS_E_OvrWrtPflHd, buff = buf1);
            ex$message (msgnumb = HS_E_OvrWrtPflCan2, buff = buf2);
            ex$message (msgnumb = HS_E_OvrWrtPflChk, buff = buf3);

            sprintf (buf0, "%s\n%s\n%s", buf1, buf2, buf3);

            ex$message (msgnumb = HS_E_OvrWrtPflNotice, buff = buf1);

            FIf_get_location (info->displayed_form, &xpos, &ypos);

            FIg_disable (info->displayed_form, FI_FORM_GROUP);
#           ifndef X11
            status = FI_confirm_box (
                                     FI_CURRENT_SCREEN,
                                     xpos + 178, ypos + 94,
                                     buf1,
                                     FI_RED,
                                     "swiss742",
                                     36.0,
                                     buf0,
                                     FI_BLACK,
                                     "swiss742",
                                     18.0,
                                     FI_LEFT_JUSTIFIED,
                                     FI_ACCEPT | FI_CANCEL,
                                     40);
#           else
            status = HFI_confirm_box (
                                      FI_CURRENT_SCREEN,
                                      xpos + 178, ypos + 94,
                                      buf1,
                                      FI_RED,
                                      "swiss742",
                                      36.0,
                                      buf0,
                                      FI_BLACK,
                                      "swiss742",
                                      18.0,
                                      FI_LEFT_JUSTIFIED,
                                      FI_ACCEPT | FI_CANCEL,
                                      40);
#           endif
            FIg_enable (info->displayed_form, FI_FORM_GROUP);

            if (status)
               {

               /* The user has chosen to use the new name. If the save
                * plotfile flag is not set, delete the old plotfile before
                * loading the name of the new one */

               if (!(info->dpb_flags & HS_PLOT_SAVE_PLOTFILE))
                  unlink (info->plotfile);

               memcpy (info->plotfile, buf, strlen (buf) + 1);
               }
            else
               {

               /* The user has chosen to not use the new name */

               FIfld_set_text (info->displayed_form,
                               CP_PLOTFILE,
                               0, 0, info->plotfile, 0);
               }
            }
         else
            {

            /* Before coping the name of the new file into the info
             * structure, delete the old file, if the save flag is not
             * checked. */

            if (!(info->dpb_flags & HS_PLOT_SAVE_PLOTFILE))
               unlink (info->plotfile);

            memcpy (info->plotfile, buf, strlen (buf) + 1);
            }

         break;

      case CP_TEXTFILE:

         /*
          * Support of the IGDS textfile field.  Get the textfile name from
          * the field
          */

         FIg_get_text (info->displayed_form, CP_TEXTFILE, buf);

         if (buf[0] == ' ' || buf[0] == 0 ||
             ((strcmp (buf, info->textfile) == 0) &&
              info->dpb_flags & HS_PLOT_CREATE_TEXTFILE))
            {
            info->dpb_flags &= ~HS_PLOT_CREATE_TEXTFILE;
            info->con_flags &= ~HP_CONTROL_SUBMIT_TEXTFILE;

            ex$message (msgnumb = HS_I_NA, buff = buf);
            
            FIfld_set_text (info->displayed_form,
                            CP_TEXTFILE,
                            0, 0, buf, 0);
            }
         else
            {
            info->dpb_flags |= HS_PLOT_CREATE_TEXTFILE;
            info->con_flags |= HP_CONTROL_SUBMIT_TEXTFILE;

            if (buf[0] == '-')
               {
               memcpy (buf, info->textfile, strlen (info->textfile) + 1);

               FIfld_set_text (info->displayed_form,
                               CP_TEXTFILE,
                               0, 0, buf, 0);
               }


            /* If the name in the field is identical to that that is already
             * stored in the info structure, don't do anything */

            if (strcmp (buf, info->textfile) == 0)
               break;

            /* If the file already exist display a messages and ask the user
             * to accept or reject (overwrite or other name) */

#           ifdef CLIX
            if (!statl (buf, &stbuf))
#           else
            if (!stat (buf, &stbuf))
#           endif
               {
               ex$message (msgnumb = HS_E_OvrWrtTflHd, buff = buf1);
               ex$message (msgnumb = HS_E_OvrWrtPflCan2, buff = buf2);
               ex$message (msgnumb = HS_E_OvrWrtPflChk, buff = buf3);

               sprintf (buf0, "%s\n%s\n%s", buf1, buf2, buf3);

               ex$message (msgnumb = HS_E_OvrWrtPflNotice, buff = buf1);

               FIf_get_location (info->displayed_form, &xpos, &ypos);

               FIg_disable (info->displayed_form, FI_FORM_GROUP);
#              ifndef X11
               status = FI_confirm_box (
                                        FI_CURRENT_SCREEN,
                                        xpos + 178, ypos + 144,
                                        buf1,
                                        FI_RED,
                                        "swiss742",
                                        36.0,
                                        buf0,
                                        FI_BLACK,
                                        "swiss742",
                                        18.0,
                                        FI_LEFT_JUSTIFIED,
                                        FI_ACCEPT | FI_CANCEL,
                                        40);
#              else
               status = HFI_confirm_box (
                                         FI_CURRENT_SCREEN,
                                         xpos + 178, ypos + 144,
                                         buf1,
                                         FI_RED,
                                         "swiss742",
                                         36.0,
                                         buf0,
                                         FI_BLACK,
                                         "swiss742",
                                         18.0,
                                         FI_LEFT_JUSTIFIED,
                                         FI_ACCEPT | FI_CANCEL,
                                         40);
#              endif
               FIg_enable (info->displayed_form, FI_FORM_GROUP);

               if (status)
                  {

                  /* The user choose to use the new name. If the save
                   * testfile flag is not set, delete the old plotfile before
                   * loading the name of the new one */

                  if (!(info->dpb_flags & HS_PLOT_SAVE_TEXTFILE))
                     unlink (info->textfile);

                  memcpy (info->textfile, buf, strlen (buf) + 1);
                  }
               else
                  {

                  /* The user choose not to use the new name, reset the field
                   * back to the old name. */

                  FIfld_set_text (
                                  info->displayed_form,
                                  CP_TEXTFILE,
                                  0, 0, info->textfile, 0);
                  }
               }
            else
               {

               /* before changing the name of the textfile in the info
                * structure, delete the file by the old textfile name */

               if (!(info->dpb_flags & HS_PLOT_SAVE_TEXTFILE))
                  unlink (info->textfile);

               memcpy (info->textfile, buf, strlen (buf) + 1);
               }
            }

         break;

      case CP_RASTERFILE:

         /* Support of the rasterfile field.  Get the rasterfile name from
          * the field and set in the info structure */

         FIg_get_text (info->displayed_form, CP_RASTERFILE, info->rasterfile);
         break;

      case CP_SAVE_PLOTFILE:

         /* Support of the save plotfile toggle.  Toggle the state of the
          * save plotfile flag in the info structure */

         if (info->dpb_flags & HS_PLOT_SAVE_PLOTFILE)
            info->dpb_flags &= ~HS_PLOT_SAVE_PLOTFILE;
         else
            info->dpb_flags |= HS_PLOT_SAVE_PLOTFILE;
         break;

      case CP_SAVE_TEXTFILE:

         /* Support of the save textfile toggle.  Toggle the state of the
          * save textfile flag in the info structure */

         if (info->dpb_flags & HS_PLOT_SAVE_TEXTFILE)
            info->dpb_flags &= ~HS_PLOT_SAVE_TEXTFILE;
         else
            info->dpb_flags |= HS_PLOT_SAVE_TEXTFILE;
         break;

      case CP_SAVE_RASTERFILE:

         /* Support of the save rasterfile toggle.  Toggle the state of the
          * save rasterfile flag in the info structure */

         if (info->dpb_flags & HS_PLOT_SAVE_RASTERFILE)
            info->dpb_flags &= ~HS_PLOT_SAVE_RASTERFILE;
         else
            info->dpb_flags |= HS_PLOT_SAVE_RASTERFILE;
         break;

      case CP_FENCE_WINDOW_CONTENTS:

         /* If the flag is window contents, toggle to fence contents */

         if (info->dpb_flags & HS_PLOT_WINDOW_CONTENTS)
            {

            /* Find the fence */

            HPfind_fence (info);

            if (!(info->con_flags & HP_CONTROL_FENCE_DEFINED))
               {

               /* Fence is not defined.  Set the mode back to window and tell
                * the user why. */

               FIg_set_state_on (info->create_form, CP_FENCE_WINDOW_CONTENTS);
               sprintf (info->command, "GRSlEInV");
               ex$message (msgnumb = HS_I_NoFenceActive, buff = buf0);

               if (!(info->con_flags & HP_CONTROL_WINDOW_DEFINED))
                  {

                  /* Window is not selected, prompt the user to select one */

                  ex$message (msgnumb = HS_P_SelShdWin, buff = buf1);

                  strcat (buf0, ": ");
                  strcat (buf0, buf1);
                  }

               FIg_set_text (info->create_form, CP_STATUS_FIELD, buf0);
               }
            else
               {

               /* There is a fence defined. Is it in a parallel shading
                * window */

               if (!(info->con_flags & HP_CONTROL_FENCE_IN_SHADING_WINDOW) ||
                   !(info->con_flags & HP_CONTROL_FENCE_IN_PARALLEL_WINDOW))
                  {

                  /* The fence is not in a shading window.  Set the mode back
                   * to window contents */

                  FIg_set_state_on (info->create_form, CP_FENCE_WINDOW_CONTENTS);
                  sprintf (info->command, "GRSlEInV");

                  if (!(info->con_flags & HP_CONTROL_FENCE_IN_SHADING_WINDOW))
                     {
                     ex$message (msgnumb = HS_I_FncNtInShdWndw, buff = buf0);
                     }
                  else
                     {
                     ex$message (msgnumb = HS_I_FncNtInParWndw, buff = buf0);
                     }

                  if (!(info->con_flags & HP_CONTROL_WINDOW_DEFINED))
                     {

                     /* Window is not selected, prompt the user to select one */

                     ex$message (msgnumb = HS_P_SelShdWin, buff = buf1);

                     strcat (buf0, ": ");
                     strcat (buf0, buf1);
                     }

                  FIg_set_text (info->create_form, CP_STATUS_FIELD, buf0);
                  }
               else
                  {

                  /* There is an active window and it is in a shading window */

                  info->dpb_flags &= ~HS_PLOT_WINDOW_CONTENTS;
                  FIg_set_state_off (info->create_form, CP_FENCE_WINDOW_CONTENTS);
                  FIg_set_text (info->create_form, CP_STATUS_FIELD, " ");
                  sprintf (info->command, "GRSlEInOvF");
                  }
               }
            }
         else
            {

            /* Toggle from fence to window contents */

            info->dpb_flags |= HS_PLOT_WINDOW_CONTENTS;
            sprintf (info->command, "GRSlEInV");
            FIg_set_state_on (info->create_form, CP_FENCE_WINDOW_CONTENTS);

            if (!(info->con_flags & HP_CONTROL_WINDOW_DEFINED))
               {
               ex$message (msgnumb = HS_P_SelShdWin, buff = buf0);
               FIg_set_text (info->create_form, CP_STATUS_FIELD, buf0);
               }
            else
               {
               FIg_set_text (info->create_form, CP_STATUS_FIELD, " ");
               }
            }

         break;

      case CP_PLOT_QUEUE_STATUS:

         /* Support of the Plot Queue Status button.  This activates The
          * Shaded Plot Queue Status form */

         FIg_reset (info->displayed_form, gadget_label);
         FIg_disable (info->displayed_form, FI_FORM_GROUP);

         info->con_flags &= ~HP_CONTROL_CREATE_FORM_DISPLAYED;
         info->con_flags |= HP_CONTROL_CREATE_FORM_DISABLED;
         info->con_flags |= HP_CONTROL_STATUS_FORM_DISPLAYED;

         HPdisplay_queue_form (info);
         break;

      case CP_SUBMIT_PLOT:

         /* Support of the Submit Plot button.  This activates the Submit
          * Shaded Plot File form. */

         FIg_reset (info->displayed_form, gadget_label);
         FIg_disable (info->displayed_form, FI_FORM_GROUP);

         info->con_flags &= ~HP_CONTROL_CREATE_FORM_DISPLAYED;
         info->con_flags |= HP_CONTROL_CREATE_FORM_DISABLED;
         info->con_flags |= HP_CONTROL_SUBMIT_FORM_DISPLAYED;

         HPdisplay_submit_form (info);
         break;

      case CP_EXECUTE:

         /* Support of the Execute button. */

         if (!(info->dpb_flags & HS_PLOT_WINDOW_CONTENTS) ||
             info->con_flags & HP_CONTROL_WINDOW_DEFINED)
            {
            ex$message (msgnumb = HS_I_CrPltFl, buff = buf);
            FIg_set_text (info->displayed_form, CP_STATUS_FIELD, buf);

            info->file_id = (IGRlong) open (info->plotfile, O_RDONLY, 0);

            if (info->file_id == -1)
               {

               /* file does not exist, has to be created  */

               info->file_id = (IGRlong) creat (info->plotfile, ACCESS_MODE);
               }
            else
               {

               /* file exists, can be opened for reading */

               info->file_id = (IGRlong) open (info->plotfile, O_RDWR | O_TRUNC, 0);
               }

            if (info->file_id == -1)
               {
               ex$message (msgnumb = HS_E_ErrOpenFile, buff = buf);
               FIg_set_text (info->displayed_form, CP_STATUS_FIELD, buf);
               }
            else
               {
               char color_table[100];
               int collect_and_classify;
               extern char *getenv ();
               char *expr;

               HPwrite_init ();
               HPwrite_header (info, 1);

               collect_and_classify = 0;
               expr = getenv ("HSplot_collect_and_classify");
               if (expr)
                  sscanf (expr, "%d", &collect_and_classify);

               if (collect_and_classify)
                  {
                  fprintf (stderr, "CSPF: Using collect and classify\n");
                  info->con_flags |= HP_CONTROL_EXIT;
                  info->switch1 = EXECUTE_COMMAND;
                  }
               else
                  {
                  sprintf (color_table, "/usr3/ingr/grnuc/config/bwplot.tbl");

                  if (info->dpb_flags & HS_PLOT_CREATE_TEXTFILE)
                     textfile = info->textfile;
                  else
                     textfile = info->unique_textfile;

                  HPstopped = FALSE;

                  if (info->dpb_flags & HS_PLOT_WINDOW_CONTENTS)
                     {
                     sts = plot$create_plotfile (
                                                 msg = &msg,
                                                 module = &info->module,
                                                 dbtype = "3d",
                                                 range = info->range,
                                                 window = &info->window,
                                                 plotfile = textfile,
                     /* color_table = color_table, */
                                           filter_function = HPwrite_object,
                                             filter_data = (IGRchar *) info,
                                                 status = buf);
                     }
                  else
                     {
                     sts = plot$create_plotfile (
                                                 msg = &msg,
                                                 module = &info->module,
                                                 dbtype = "3d",
                                                 range = info->fence_range,
                                               window = &info->fence_window,
                                                 cvprism = info->prism,
                                                 plotfile = textfile,
                     /* color_table = color_table, */
                                           filter_function = HPwrite_object,
                                             filter_data = (IGRchar *) info,
                                                 status = buf);
                     }

                  IGEresetstop ();

                  if (HPstopped)
                     {
                     ex$message (msgnumb = HS_I_PartPflDel, buff = buf0);
                     ex$message (msgnumb = HS_E_OvrWrtPflNotice, buff = buf1);

                     FIf_get_location (info->displayed_form, &xpos, &ypos);

                     status = FI_message_box (
                                              FI_CURRENT_SCREEN,
                                              xpos + 178, ypos + 94,
                                              buf1,
                                              FI_RED,
                                              "swiss742",
                                              36.0,
                                              buf0,
                                              FI_BLACK,
                                              "swiss742",
                                              18.0,
                                              FI_LEFT_JUSTIFIED,
                                              40);

                     close (info->file_id);
                     unlink (info->plotfile);

                     ex$message (msgnumb = HS_I_PltFlDel, buff = buf);
                     FIg_set_text (info->displayed_form, CP_STATUS_FIELD, buf);

                     if (info->dpb_flags & HS_PLOT_WINDOW_CONTENTS)
                        {
                        sleep (2);

                        ex$message (msgnumb = HS_P_SelShdWin, buff = buf);
                        FIg_set_text (info->displayed_form, CP_STATUS_FIELD, buf);

                        info->con_flags &= ~HP_CONTROL_WINDOW_DEFINED;
                        }

                     break;
                     }

                  /* rewind the file and rewrite the header of the header.
                   * note the "0" argument here and "1" before */

                  lseek (info->file_id, (long) 0, 0);

                  HPwrite_header (info, 0);

                  close (info->file_id);

                  ex$message (msgnumb = HS_I_PltFlCrd, buff = buf);
                  FIg_set_text (info->displayed_form, CP_STATUS_FIELD, buf);

                  if (info->dpb_flags & HS_PLOT_WINDOW_CONTENTS)
                     {
                     sleep (2);

                     ex$message (msgnumb = HS_P_SelShdWin, buff = buf);
                     FIg_set_text (info->displayed_form, CP_STATUS_FIELD, buf);

                     info->con_flags &= ~HP_CONTROL_WINDOW_DEFINED;
                     }

                  /* delete textfile if disabled */

                  i = strlen (textfile);
                  memcpy (buf, textfile, i + 1);

                  buf[i - 4] = '.';
                  buf[i - 3] = 't';
                  buf[i - 2] = 'b';
                  buf[i - 1] = 'l';
                  buf[i] = 0;

                  unlink (buf);

                  if (!(info->dpb_flags & HS_PLOT_CREATE_TEXTFILE))
                     unlink (textfile);
                  }
               }
            }
         else
            {
            ex$message (msgnumb = HS_E_WinNtSel, buff = buf0);
            FIg_set_text (info->create_form, CP_STATUS_FIELD, buf0);
            }
         break;

      case CP_CANCEL:
         info->con_flags |= HP_CONTROL_EXIT;
         info->switch1 = EXIT_COMMAND;
         break;


      case CP_CHECK:
         HPsave_defaults (info);
         info->con_flags |= HP_CONTROL_EXIT;
         info->switch1 = EXIT_COMMAND;
         break;

      default:
         break;
         }
   }

#define WRITE_HEADER \
   { \
   info->file_id = (IGRlong)open( info->plotfile, O_WRONLY, 0 ); \
   if( info->file_id != -1 ) \
      { \
      HPwrite_header( info, 0 ); \
      close( info->file_id ); \
      } \
   }

/*---HPsubmit_form_notify-------------------------------*/

/*
NAME
        HPsubmit_form_notify

KEYWORDS
        shaded plotting
        submit shaded plotfile
        notification
        
DESCRIPTION
        notification routine for the submit shaded plotfile
        form
        
PARAMETERS
        gadget_label	:(IN) : id of gadget selected
        into		:(IN) : shaded plotting info
        
GLOBALS USED

FUNCTIONS CALLED
        FIf_erase		FIfld_get_list_text
        FIfld_get_text		FIfld_set_text
        FIg_disable		FIg_get_text
        FIg_reset		HPdisplay_create_form
        HPdisplay_option_form	HPdisplay_queue_form
        HPexecute		HPpqinfo
        HPsave_defaults		HPsizescale
        HPspformatqinfo		HPsubmit_form_notify
        ex$message		sprintf
        sscanf			unlink

HISTORY
        ??/??/??	M. Lanier
                Created
*/

#if defined(__STDC__) || defined(__cplusplus)
void HPsubmit_form_notify (IGRint gadget_label,
                                struct HSplot_info * info)
#else
void HPsubmit_form_notify (gadget_label, info)

   IGRint gadget_label;
   struct HSplot_info *info;

#endif

   {
   IGRint sel, row;
   IGRchar buf[128], unit[18];
   IGRlong status;
   IGRint itmp;

   /* process the input */

   info->switch1 = 0;
   switch (gadget_label)
      {
      case SP_CANCEL:

         FIf_erase (info->displayed_form);
         FIf_erase (info->create_form);
         info->switch1 = EXIT_COMMAND;
         info->displayed_form = NULL;
         info->displayed_form_no = 0;
         info->con_flags |= HP_CONTROL_EXIT;
         break;

      case SP_CHECK:
         FIf_erase (info->displayed_form);
         FIf_erase (info->create_form);
         info->switch1 = EXIT_COMMAND;
         info->displayed_form = NULL;
         info->displayed_form_no = 0;
         info->con_flags |= HP_CONTROL_EXIT;

         WRITE_HEADER

         HPsave_defaults (info);
         break;

      case SP_CONVERT_WINDOW:
         FIg_disable (info->displayed_form, gadget_label);
         break;

      case SP_EXECUTE:
         ex$message (msgnumb = HS_I_Working, buff = buf);
         FIfld_set_text (info->displayed_form, SP_INFO, 0, 0,
                         buf, 0);

         WRITE_HEADER

         HPexecute (info, buf);
         buf[64] = NULL;
         FIfld_set_text (info->displayed_form, SP_INFO, 0, 0, buf, 0);

         /* if not set, turn "old file" flag on */
         if (!(info->dpb_flags & HS_PLOT_OLD_FILE))
            info->dpb_flags |= HS_PLOT_OLD_FILE;
         break;

      case SP_PLOTFILE:
         FIfld_get_text (
                         info->displayed_form,
                         gadget_label,
                         0, 0, 128, buf,
                         &sel, &row);

         if (buf[0] != '-')
            {
            if (info->dpb_flags & HS_PLOT_SAVE_PLOTFILE)
               unlink (info->plotfile);

            sprintf (info->plotfile, "%s", buf);
            }
         else
            FIfld_set_text (
                            info->displayed_form,
                            SP_PLOTFILE,
                            0, 0,
                            info->plotfile, 0);


         /* Set the plotfile bit and mask out the rasterfile bit */

         info->con_flags |= HP_CONTROL_SUBMIT_PLOTFILE;
         info->con_flags &= ~HP_CONTROL_SUBMIT_RASTERFILE;

         ex$message (msgnumb = HS_I_NA, buff = buf);
         FIfld_set_text (
                         info->displayed_form,
                         SP_RASTERFILE,
                         0, 0, buf, 0);
         break;

      case SP_TEXTFILE:
         FIfld_get_text (
                         info->displayed_form,
                         gadget_label,
                         0, 0, 128, buf,
                         &sel, &row);

         if (buf[0] == ' ' || buf[0] == 0)
            {
            info->con_flags &= ~HP_CONTROL_SUBMIT_TEXTFILE;

            ex$message (msgnumb = HS_I_NA, buff = buf);
            FIfld_set_text (
                            info->displayed_form,
                            SP_TEXTFILE,
                            0, 0, buf, 0);
            }
         else
            {
            if (buf[0] != '-')
               sprintf (info->textfile, "%s", buf);
            else
               FIfld_set_text (
                               info->displayed_form,
                               SP_TEXTFILE,
                               0, 0,
                               info->textfile, 0);

            info->con_flags |= HP_CONTROL_SUBMIT_TEXTFILE;
            }
         break;

      case SP_RASTERFILE:
         FIfld_get_text (
                         info->displayed_form,
                         gadget_label,
                         0, 0, 128, buf,
                         &sel, &row);

         if (buf[0] != '-')
            sprintf (info->rasterfile, "%s", buf);
         else
            FIfld_set_text (
                            info->displayed_form,
                            SP_RASTERFILE,
                            0, 0,
                            info->rasterfile, 0);

         info->con_flags |= HP_CONTROL_SUBMIT_RASTERFILE;
         info->con_flags &= ~HP_CONTROL_SUBMIT_PLOTFILE;

         ex$message (msgnumb = HS_I_NA, buff = buf);
         FIfld_set_text (
                         info->displayed_form,
                         SP_PLOTFILE,
                         0, 0, buf, 0);
         break;

      case SP_QUEUE:
         FIfld_get_text( info->displayed_form,
                         gadget_label,
                         0, 0, 128, buf,
                         &sel, &row);

         sscanf (buf, "%s", info->queue);

         status = HPpqinfo( info->queue,
                            &info->plotter_max[0],
                            &info->plotter_max[1],
                            &info->plotter_resolution,
                            unit);

         if (!(status & 1))
            {

            /* grab the first plotter in the list */

            FIfld_get_list_text( info->displayed_form,
                                 SP_QUEUE,
                                 0, 0, 128, buf, &sel);

            sscanf (buf, "%s", info->queue);

            HPpqinfo( info->queue,
                      &info->plotter_max[0],
                      &info->plotter_max[1],
                      &info->plotter_resolution,
                      unit);
            }

         HPspformatqinfo( info->queue,
                          info->plotter_max[0],
                          info->plotter_max[1],
                          info->plotter_resolution,
                          unit,
                          buf);


         FIfld_set_text( info->displayed_form,
                         SP_QUEUE,
                         0, 0, buf, 0);

         /* compensate for changes in device dimensions, in plotsize */

         HPsubmit_form_notify( SP_SCALE,
                               info);
         break;

      case SP_X:
      case SP_Y:
      case SP_SCALE:
/*fprintf( stderr, "size/scale needs work.  One has to disable when the other is active\n" );*/
         HPsizescale (info, gadget_label, info->displayed_form);
         break;

      case SP_DATE:
         FIg_get_text (
                       info->displayed_form,
                       gadget_label,
                       buf);

         sprintf (info->date, "%s", buf);
         break;

      case SP_COPIES:
         FIfld_get_text (
                         info->displayed_form,
                         gadget_label,
                         0, 0, 128, buf,
                         &sel, &row);

         if (sscanf (buf, "%d", &itmp) <= 0)
            {
            sprintf (buf, "%1d", info->copies);
            FIfld_set_text (
                            info->displayed_form,
                            SP_COPIES,
                            0, 0, buf, 0);

            break;
            }

         info->copies = itmp;
         break;

/*
removed because I belive that these gadgets are no longer on the
submit form.. Mike 11-7-97

      case SP_BLACK_AND_WHITE:
         if (info->dpb_flags & HS_PLOT_BLACK_AND_WHITE)
            info->dpb_flags &= ~HS_PLOT_BLACK_AND_WHITE;
         else
            info->dpb_flags |= HS_PLOT_BLACK_AND_WHITE;
         break;

      case SP_WHITE_BACKGROUND:
         if (info->dpb_flags & HS_PLOT_WHITE_BACKGROUND)
            info->dpb_flags &= ~HS_PLOT_WHITE_BACKGROUND;
         else
            info->dpb_flags |= HS_PLOT_WHITE_BACKGROUND;
         break;
*/

      case SP_MAIL_BEGIN:
         if (info->dpb_flags & HS_PLOT_MAIL_AT_BEGIN)
            info->dpb_flags &= ~HS_PLOT_MAIL_AT_BEGIN;
         else
            info->dpb_flags |= HS_PLOT_MAIL_AT_BEGIN;
         break;

      case SP_MAIL_END:
         if (info->dpb_flags & HS_PLOT_MAIL_AT_END)
            info->dpb_flags &= ~HS_PLOT_MAIL_AT_END;
         else
            info->dpb_flags |= HS_PLOT_MAIL_AT_END;
         break;

      case SP_JOB_STATUS:
/*
         ex$message (msgnumb = HS_I_Working, buff = buf);
         FIfld_set_text (info->displayed_form, SP_INFO, 0, 0, buf, 0);

         FIg_reset (info->displayed_form, gadget_label);
*/
fprintf( stderr, "case for JOB_STATUS commented out: %s %d\n", __FILE__, __LINE__ );
         break;

      case SP_SHADING_QUEUE_STATUS:
         FIf_erase (info->displayed_form);

         info->con_flags &= ~HP_CONTROL_SUBMIT_FORM_DISPLAYED;
         info->con_flags |= HP_CONTROL_STATUS_FORM_DISPLAYED;

         HPdisplay_queue_form (info);
         break;

      case SP_OPTION:
         FIg_reset (info->displayed_form, gadget_label);

         info->opt_flags = info->dpb_flags & (HS_PLOT_BLACK_AND_WHITE | HS_PLOT_WHITE_BACKGROUND | HS_PLOT_EXCLUDE_WIREFRAME);

         info->t_line_width_const = info->line_width_const;
         info->t_max_line_width = info->max_line_width;
         info->t_raster_type = info->raster_type;

         info->con_flags |= HP_CONTROL_OPTION_FORM_DISPLAYED;

         HPdisplay_option_form (info);
         break;

      case SP_CREATE_SHADED_PLOTFILE:
         FIf_erase (info->displayed_form);

         info->con_flags &= ~HP_CONTROL_SUBMIT_FORM_DISPLAYED;
         info->con_flags &= ~HP_CONTROL_CREATE_FORM_DISABLED;
         info->con_flags |= HP_CONTROL_CREATE_FORM_DISPLAYED;

         HPdisplay_create_form (info);
         break;

      default:
         break;
         }
   }

/*---HPstatus_form_notify-------------------------------*/

/*
NAME
        HPstatus_form_notify
        
KEYWORDS
        shaded plotting
        queue status
        
DESCRIPTION
        notification routine for the shaded queue status form
        
PARAMTERS
        gadget_label	:(IN) : id of the gadget selected
        into		:(IN) : shaded plotting info
        
GLOBALS USED
        -none-
        
FUNCTIONS CALLED
        FIf_erase
        FIfld_get_text
        FIfld_set_select
        FIfld_set_text
        FIg_disable
        FIg_display
        FIg_reset
        HPcancel_plot
        HPdisplay_create_form
        HPdisplay_submit_form
        HPsave_defaults
        HPupdate_queue_status
        ex$message
        sscanf
        strlen

HISTORY
        ??/??/??	M. Lanier
                Created
*/

#if defined(__STDC__) || defined(__cplusplus)
void HPstatus_form_notify (IGRint gadget_label,
                                struct HSplot_info * info)
#else
void HPstatus_form_notify (gadget_label, info)

   IGRint gadget_label;
   struct HSplot_info *info;

#endif

   {
   IGRchar buf[128], jobnum[32];
   IGRint sel;
   IGRint row, sts;
   IGRint value = 0;

   /* clear the message field */

   info->switch1 = 0;
   FIfld_get_text (info->displayed_form,
                   FI_MSG_FIELD,
                   0,
                   0,
                   128,
                   buf,
                   &sel,
                   &row);
   if (strlen (buf))
      {
      FIfld_set_text (info->displayed_form,
                      FI_MSG_FIELD,
                      0,
                      0,
                      "",
                      0);
      FIg_display (info->displayed_form, FI_MSG_FIELD);
      }

   switch (gadget_label)
      {
      case FI_ACCEPT:
         FIf_erase (info->displayed_form);
         FIf_erase (info->create_form);
         info->switch1 = EXIT_COMMAND;
         info->displayed_form = NULL;
         info->displayed_form_no = 0;
         info->con_flags |= HP_CONTROL_EXIT;

         HPsave_defaults (info);
         break;

      case FI_CANCEL:
         FIf_erase (info->displayed_form);
         FIf_erase (info->create_form);
         info->switch1 = EXIT_COMMAND;
         info->displayed_form = NULL;
         info->displayed_form_no = 0;
         info->con_flags |= HP_CONTROL_EXIT;
         break;

      case FI_HELP:
         break;

      case FI_CVT_TO_PERM_WIN:
         FIg_disable (info->displayed_form, gadget_label);
         break;

      case FI_EXECUTE:
      case QS_UPDATE:
      case QS_QUEUE:
         ex$message (msgnumb = HS_I_Working, buff = buf);

         FIfld_set_text (info->displayed_form,
                         FI_MSG_FIELD,
                         0,
                         0,
                         buf,
                         0);

         HPupdate_queue_status (info);

         if (gadget_label != QS_QUEUE)
            {
            FIg_reset (info->displayed_form, gadget_label);
            }
         break;

      case QS_JOB_LIST:
         FIfld_get_active_row (
                               info->displayed_form,
                               gadget_label,
                               &value,
                               &row);

         FIfld_get_text (
                         info->displayed_form,
                         gadget_label,
                         value,
                         0, 128,
                         buf,
                         &sel, &row);

         sts = sscanf (buf,
                       "%s %*s %s",
                       jobnum,
                       info->job_to_can);

         if (!strchr (jobnum, ':'))
            {
            info->job_to_can[0] = NULL;
            FIfld_set_select (
                              info->displayed_form,
                              gadget_label,
                              value,
                              0, FALSE);
            }

         break;

      case QS_CANCEL_PLOT:
         ex$message (msgnumb = HS_I_Working, buff = buf);

         FIfld_set_text (info->displayed_form,
                         FI_MSG_FIELD,
                         0,
                         0,
                         buf,
                         0);

         HPcancel_plot (
                        gadget_label,
                        info);

         FIg_reset (info->displayed_form, gadget_label);
         break;

      case QS_SUBMIT_PLOT:
         FIf_erase (info->displayed_form);

         info->con_flags &= ~HP_CONTROL_STATUS_FORM_DISPLAYED;
         info->con_flags |= HP_CONTROL_SUBMIT_FORM_DISPLAYED;

         HPdisplay_submit_form (info);
         break;

      case QS_CREATE_PLOT:
         FIf_erase (info->displayed_form);

         info->con_flags &= ~HP_CONTROL_STATUS_FORM_DISPLAYED;
         info->con_flags &= ~HP_CONTROL_CREATE_FORM_DISABLED;
         info->con_flags |= HP_CONTROL_CREATE_FORM_DISPLAYED;

         HPdisplay_create_form (info);
         break;

      default:
         break;
         }
   }


/*---HPoption_form_notify-------------------------------*/

/*
NAME
        HPoption_form_notify
        
KEYWORDS
        shaded plotting
        
DESCRIPTION
        notification routine for the submit shaded plotfile options
        form
        
PARAMETERS
        gadget_label	:(IN) : id of the selected gadget
        info		:(IN) : shaded plotting global information
        
GLOBALS USED
        -none-
        
FUNCTIONS CALLED
        FIf_erase
        FIg_set_text
        FIg_set_on_text
        sscanf
        sprintf
        
HISTORY
        ??/??/??	M. Lanier
                Created
*/

#if defined(__STDC__) || defined(__cplusplus)
void HPoption_form_notify (IGRint gadget_label,
                                struct HSplot_info * info)
#else
void HPoption_form_notify (gadget_label, info)

   IGRint gadget_label;
   struct HSplot_info *info;

#endif

   {
   double dtmp;
   int itmp;
   char buff[80];

   switch (gadget_label)
      {
      case OP_CHECK:
         info->line_width_const = info->t_line_width_const;
         info->max_line_width = info->t_max_line_width;
         info->raster_type = info->t_raster_type;

         if (info->opt_flags & HS_PLOT_BLACK_AND_WHITE)
            info->dpb_flags |= HS_PLOT_BLACK_AND_WHITE;
         else
            info->dpb_flags &= ~HS_PLOT_BLACK_AND_WHITE;


         if (info->opt_flags & HS_PLOT_WHITE_BACKGROUND)
            info->dpb_flags |= HS_PLOT_WHITE_BACKGROUND;
         else
            info->dpb_flags &= ~HS_PLOT_WHITE_BACKGROUND;

         if (info->opt_flags & HS_PLOT_EXCLUDE_WIREFRAME)
            info->dpb_flags |= HS_PLOT_EXCLUDE_WIREFRAME;
         else
            info->dpb_flags &= ~HS_PLOT_EXCLUDE_WIREFRAME;

         FIf_erase (info->displayed_form);
         info->con_flags &= ~HP_CONTROL_OPTION_FORM_DISPLAYED;
         info->displayed_form = info->submit_form;
         break;

      case OP_CANCEL:
         FIf_erase (info->displayed_form);
         info->con_flags &= ~HP_CONTROL_OPTION_FORM_DISPLAYED;
         info->displayed_form = info->submit_form;
         break;

      case OP_LINE_WIDTH_CONSTANT:
         FIg_get_text (info->displayed_form, gadget_label, buff);
         sscanf (buff, "%lf", &dtmp);
         info->t_line_width_const = dtmp;
         break;

      case OP_MAX_LINE_WIDTH:
         FIg_get_text (info->displayed_form, gadget_label, buff);
         sscanf (buff, "%d", &itmp);
         info->t_max_line_width = itmp;
         break;

      case OP_BACKGROUND_COLOR:
         if (info->opt_flags & HS_PLOT_WHITE_BACKGROUND)
            info->opt_flags &= ~HS_PLOT_WHITE_BACKGROUND;
         else
            info->opt_flags |= HS_PLOT_WHITE_BACKGROUND;
         break;

      case OP_EXCLUDE_WIREFRAME_ELEMENTS:
         if (info->opt_flags & HS_PLOT_EXCLUDE_WIREFRAME)
            info->opt_flags &= ~HS_PLOT_EXCLUDE_WIREFRAME;
         else
            info->opt_flags |= HS_PLOT_EXCLUDE_WIREFRAME;
         break;

      case OP_EDGE_DISPLAY:
         sprintf (buff, "Background Color");
         if (info->opt_flags & HS_PLOT_BLACK_AND_WHITE)
            {
            info->opt_flags &= ~HS_PLOT_BLACK_AND_WHITE;
            sprintf (buff, "%s\nOriginal", buff);
            }
         else
            {
            info->opt_flags |= HS_PLOT_BLACK_AND_WHITE;
            sprintf (buff, "%s\nBlack", buff);
            }

         FIg_set_on_text (info->displayed_form, OP_BACKGROUND_COLOR, buff);
         break;

      case OP_RASTERFILE_DATA_TYPE:
         if (info->raster_type == 25)
            info->t_raster_type = 27;
         else
            info->t_raster_type = 25;
         break;
         }
   }
