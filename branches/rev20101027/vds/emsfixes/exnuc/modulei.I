/* $Id: modulei.I,v 1.3 2001/01/13 00:42:14 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/exnuc / modulei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: modulei.I,v $
 *	Revision 1.3  2001/01/13 00:42:14  hans
 *	SP16 modifications
 *	
 *	Revision 1.2  2001/01/12 23:20:46  hans
 *	SP16 modifications
 *
 *	Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *	Initial import to CVS
 *
# Revision 1.1  2000/10/18  18:26:06  pinnacle
# ylong
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/05/26  19:03:04  pinnacle
# Replaced: emsfixes/exnuc/modulei.I for:  by jwfrosch for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/11/03  17:18:16  pinnacle
# Replaced: ./emsfixes/exnuc/modulei.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/09/25  22:53:08  pinnacle
# Replaced: emsfixes/exnuc/modulei.I for:  by sundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	05/26/97	HF		Merged EMS/EXNUC 3.3 & VDS fixes
 *					(without these VDS will crash at startup)
 *	10/19/00	ylong		TR179900971
 * -------------------------------------------------------------------*/

/*
 *     File: modulei.I  (to dload in I/VDS)
 *
 *     09/29/94      rmn      Avoid sending sleep twice to the GRgsmgr object
 *                            to eliminate error/warning messages during a
 *                            retrieve=no or exit=no
 */

class implementation module;

from global_class import wake_up, sleep, super_construct, place;
from IGEwsys      import clear, activate;

#include <OMmacros.h>
#include <ex.h>
#include <exdef.h>
#include <expriv.h>
#include <string.h>
#include <execmsg.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <FI.h>
#include <exudata.h>

#include "exsysdep.h"

#ifdef X11
#include <X11/Xlib.h>
%safe
#include "XFIproto_pub.h"
%endsafe
#endif

#ifdef ENV5
%safe
#include "FIproto_pub.h"
%endsafe
#endif

#include <stdio.h>

#ifdef X11
extern Display *EXdisplay;
#endif

#ifdef ENV5
extern Form MS_panel_menu;
extern Form MS_bar_menu;
#endif

extern Form  EX_msg_form;
extern Form  EX_msg_form_left;
extern int   EX_two_message_strips;

extern struct module_params **module_data;
extern struct EX_visible_module *module_table;
extern char CS_path_name[];
extern char EX_runname[];
extern struct EX_global EX_global_var;
extern OM_S_OBJID EX_cmdserver_id;
extern OM_S_OBJID EX_exec_id;
extern unsigned int OM_Gf_verbose_warning;
extern int EX_same_file;

static int EX_temp_wakeup;

#define debug      0
#define wakupdebug 0
#define helpdebug  0
#define NEWHELP    1

#ifdef SUNOS5
%undef sleep
#endif


method get_chan_cnt ( OM_S_OBJID owner_id;
                      char *chan_name;
                      uint *count )
{
   int              status;
   OM_S_CHANSELECT  chandef1;
   OMuword          os_num;

   status = om$os_name_to_number (
                          osname  = module_data[OM_Gw_current_OS]->CS_OS_name,
                          p_osnum = &os_num );

   if(!(1&status)) return(OM_E_ERROR);

   chandef1.type = OM_e_name;
   strcpy ( chandef1.u_sel.name, chan_name );

   status = om$get_channel_count ( osnum        = os_num,
                                   objid        = owner_id,
                                   p_chanselect = &chandef1,
                                   count        = count );
   if(!(1&status)) return(OM_E_ERROR);
   return(OM_S_SUCCESS);
}


method get_chan_obj ( OM_S_OBJID owner_id;
                      char *chan_name;
                      OM_S_OBJECT_LINKAGE *list;
                      uint size;
                      uint *count )
{
   int              status;
   OM_S_CHANSELECT  chandef1;
   OMuword          os_num;

   status = om$os_name_to_number (
                           osname  = module_data[OM_Gw_current_OS]->CS_OS_name,
                           p_osnum = &os_num );
   if(!(1&status)) return(OM_E_ERROR);

   chandef1.type = OM_e_name;
   strcpy ( chandef1.u_sel.name, chan_name );

   status = om$get_channel_objects ( osnum        = os_num,
                                     objid        = owner_id,
                                     p_chanselect = &chandef1,
                                     list         = list,
                                     size         = size,
                                     count        = count );
   if(!(1&status)) return(OM_E_ERROR);

   return(OM_S_SUCCESS);
}


method mod_info ( int mode;
                  IGRchar *ver;
                  int verlen;
                  IGRchar *app;
                  int applen )
{
   int  rc, status;

   rc = OM_S_SUCCESS;

   if (ver)
   {
      if (mode == EX_INQ)
      {
         if (verlen < (strlen(ME.module->version) + 1))
	 {
	    printf( "In module get info verlen too short, need %d\n",
                     strlen( ME.module->version) + 1 );
            rc = OM_E_ERROR;
         }
         else
         {
            strcpy ( ver, ME.module->version );
         }
      }
      if (mode == EX_SET)
      {
         if (verlen  >  om$dimension_of(varray = ME.module->version ))
         {
            status = om$vla_set_dimension ( varray = ME.module->version,
                                            size   = verlen + 1 );
         }
         strcpy ( ME.module->version, ver );
      }
   }
   if (app)
   {
      if (mode == EX_INQ)
      {
         if (applen < (strlen(ME.module->application) + 1))
         {
            printf("In module get info applen too short, need %d\n",
                        strlen(ME.module->application) + 1 );
            rc = OM_E_ERROR;
         }
         else
         {
            strcpy ( app, ME.module->application );
         }
      }
      if (mode == EX_SET)
      {
         if (applen  >  om$dimension_of(varray = ME.module->application))
         {
            status = om$vla_set_dimension ( varray = ME.module->application,
                                            size   = applen + 1 );
         }
         strcpy( ME.module->application, app);
      }
   }
   return(rc);
}


method module.sleep (int type_sleep)
{
   int                   i;
   int                   status;
   IGRlong               msg;
   OM_S_CHANSELECT       chandef1;
   OM_S_OBJECT_LINKAGE  *linkage;
   OM_S_OBJECT_LINKAGE  *lnkg;
   OMuint                number_objs;
   OMuint                count;
   char                  class_name[OM_K_MAXCLASS_LEN];
   int                   is_super_present = 0;
   GRclassid             class_id;

   if (type_sleep == EX_REAL_SLEEP)
   {
      if (ex$is_interactive() &&
         (module_data[OM_Gw_current_OS]->visible_flag > 0))
      {
         chandef1.type = OM_e_name;
         chandef1.u_sel.name = "windows";

         status = om$send ( mode         = OM_e_wrt_object,
                            msg          = message IGEwsys.clear(&msg),
                            senderid     = my_id,
                            p_chanselect = &chandef1 );
      }
   }

   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "super";

   status = om$get_channel_count ( osnum        = OM_Gw_current_OS,
                                   objid        = my_id,
                                   p_chanselect = &chandef1,
                                   count        = &number_objs );
   if (!(1&status))
   {
      printf("IN module sleep get channel count error\n");
      om$report_error(sts = status);
      return (status);
   }

   linkage = NULL;
   if( number_objs > 0 )
   {
      linkage = (OM_S_OBJECT_LINKAGE *)
                    malloc( sizeof(OM_S_OBJECT_LINKAGE) * number_objs );
   }

   status = om$get_channel_objects ( osnum        = OM_Gw_current_OS,
                                     objid        = my_id,
                                     p_chanselect = &chandef1,
                                     list         = linkage,
                                     size         = number_objs,
                                     count        = &count );
   if (!(1&status))
   {
      printf("IN module sleep get channel objects error\n");
      om$report_error(sts = status);
      if (linkage) free(linkage);
      return (status);
   }

   lnkg = linkage;

   /*
    * If Super_rfmgr object is present, set flag to 1
    */

   for( i = 0 ; i < number_objs ; i++, lnkg++ )
   {
      status = om$get_classid( osnum     = OM_Gw_current_OS,
                               objid     = lnkg->S_objid,
                               p_classid = &class_id );

      if( om$is_ancestry_valid( subclassid       = class_id,
                                superclassname   = "Super_rfmgr" )
                                == OM_S_SUCCESS )
      {
           is_super_present = 1;
           break;
      }
   }

   lnkg = linkage;

   /*======================================*/
   /*  notice semicolon - walk to the end  */
   /*======================================*/

   for (i = 1; i< number_objs; i++,lnkg++);

   for (i=number_objs; i >= 1; i--, lnkg--)
   {
      /*
       * We must avoid sending sleep twice to the GRgsmgr object.
       * Sending sleep twice to GRgsmgr object generates a lot of
       * error/warning messages, because of the di$find in that method.
       * The sleep method of Super_rfmgr object, sends a sleep to the
       * set manager.  So if there is Super_rfmgr object present
       * we must not send sleep again to the set manager
       */

      status = om$get_classid( osnum     = OM_Gw_current_OS,
                               objid     = lnkg->S_objid,
                               p_classid = &class_id );
      if( !(status &1)) continue ;

      if( om$is_ancestry_valid( subclassid     = class_id,
                                superclassname = "GRgsmgr" )
                                == OM_S_SUCCESS  && is_super_present )
           continue;

      status = om$send ( mode     = OM_e_wrt_object,
                         msg      = message global_class.sleep(type_sleep),
                         senderid = my_id,
                         targetid = lnkg->S_objid,
                         targetos = OM_Gw_current_OS );
      if (!(1&status))
      {
         if (OM_Gf_verbose_warning  || (status != OM_E_NOSUCHCLASS))
         {
            printf("-1- send to global_class.sleep status = %x\n",status);
            om$report_error(sts = status);

            class_name[0] = '\0';
            om$get_classname ( osnum     = OM_Gw_current_OS,
                               objid     = lnkg->S_objid,
                               classname = class_name );
            printf("super index = <%d> super class = <%s>\n",i,class_name);
         }
      }
   }
   if (linkage) free(linkage);

   ME.module->mod_data = (*((struct module_instance_data *)
                                        module_data[OM_Gw_current_OS]));

   /*
    * The following fix was made for Reference File Activation in EMS96.
    * Explanation :
    * When a reference file is deleted or detached, reference files module
    * receives a sleep. If a check is not made to determine if it is the
    * master file or the reference file that is going down, we end up
    * deallocing the storage used for storing the actvation details.
    * After deleting the ref. file, if any command using activation is poked,
    * a check is made internally to determine if any ref. file is activated.
    * This accesses the storage to get the details, causing the crash.
    *
    * Check is now being made to avoid the crash. Also to make sure that
    * master does not dealloc before other ref. files sleep, the initial code
    * for activation has been moved down after a return from other ref. file
    * module sleep.
    *                                           - Satish (20th May 1996)
    */

   if (type_sleep == EX_REAL_SLEEP)
   {
      if (module_data[OM_Gw_current_OS]->visible_flag > 0)
      {
         exExitUData();
      }
      else
      {
         exUDataActref rfact;
         int sts;

         sts = exRecvUData(EX_UDATA_ACTREF, (char *)&rfact);
         if (rfact.aflag)
         {
            rfact.aflag = FALSE;
            rfact.osn   = 0;
            rfact.refid.objid = NULL_OBJID;

            sts = exPostUData(EX_UDATA_ACTREF, (char *)&rfact);
         }
      }
   }

   if (type_sleep == EX_REAL_SLEEP) om$sm_dealloc(ptr =
                                 (char *)module_data[OM_Gw_current_OS]);

   return(OM_S_SUCCESS);

}


method wake_up (int vis_flag)     /* 0-invis, 1-vis, 2-wake after temp sleep */
{
   int                   i;
   int                   status;
   int                   found_color;
   IGRlong               msg;
   OMuint                number_objs;
   OMuint                save_numobjs;
   OMuint                count;
   OMuword               os_num;
   char                  class_name[OM_K_MAXCLASS_LEN];
   OM_S_CHANSELECT       chandef1;
   OM_S_CHANSELECT       chandef2;
   OM_S_OBJECT_LINKAGE  *linkage;
   OM_S_OBJECT_LINKAGE  *lnkg;
   OM_S_OBJID            mod_objid;
   OM_S_OBJID            col_objid;
   OMuword               mod_osnum;
   OMuword               col_osnum;
   OM_S_OBJID GRpalmgr;
   int save_flag;
   int in_master_file;

   ASassoc_init();
   ACinit( my_id );

   status = exInitUData();
   if (status != UDATA_SUCCESS)
      printf("User Data Mechanism not initialized\n");

   in_master_file = 0;
   GRpalmgr = NULL_OBJID;
   for (i = 0; i < EX_MAX_MODULES; i++)
   {
      if (module_table[i].obj_space_num == OM_Gw_current_OS)
      {
      in_master_file = 1;
      break;
      }
   }

   if ((EX_same_file == 0) & (vis_flag != 2))
   {
      module_data[OM_Gw_current_OS] =
                om$sm_malloc(structure = struct module_params);
      *((struct module_instance_data *) module_data[OM_Gw_current_OS]) =
                                                         ME.module->mod_data;
      module_data[OM_Gw_current_OS]->module_id = my_id;
   }

   if (vis_flag == 2)  /* temp wakeup */
   {
      EX_temp_wakeup = 1;  /* set temp wake up before send to super */
   }
   else
   {
      module_data[OM_Gw_current_OS]->visible_flag = vis_flag;
      EX_temp_wakeup = 0;

      if (vis_flag == 1)  /* visible file */
      {
         EX_global_var.module_type =  -1;
      }
   }

   status = om$os_number_to_name ( osnum = OM_Gw_current_OS,
                          osname = module_data[OM_Gw_current_OS]->CS_OS_name);

   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "super";

   status = om$get_channel_count( osnum        = OM_Gw_current_OS,
                                  objid        = my_id,
                                  p_chanselect = &chandef1,
			          count        = &number_objs );
   if( !( 1& status) )
   {
       printf("IN module wake up get channel count error\n");
       om$report_error(sts = status);
       return (status);
   }

   linkage = NULL;
   save_numobjs = 0;

   if (number_objs > 0)
   {
      linkage = (OM_S_OBJECT_LINKAGE *)
                  malloc(sizeof(OM_S_OBJECT_LINKAGE) * number_objs);
      if (!linkage) return (OM_E_NODYNMEM);
      save_numobjs = number_objs;
   }

   status = om$get_channel_objects ( osnum        = OM_Gw_current_OS,
                                     objid        = my_id,
                                     p_chanselect = &chandef1,
                                     list         = linkage,
                                     size         = number_objs,
                                     count        = &count );
   if (!(1&status))
   {
      printf("IN module wake up get channel objects error\n");
      om$report_error(sts = status);
      if (linkage) free(linkage);
      return (status);
   }

   lnkg = linkage;
   found_color = 0;


   for (i = 0; i< number_objs; i++,lnkg++)
   {
      class_name[0] = '\0';
      status = om$get_classname ( osnum     = OM_Gw_current_OS,
                                  objid     = lnkg->S_objid,
                                  classname = class_name );

      if ((!strcmp(class_name,"IGEcolor2")) ||
          (!strcmp(class_name,"IGEcolor")))
      {
       /*the color object will always be the first super to get wakeup*/
         status = om$send ( mode     = OM_e_wrt_object,
                            msg      = message global_class.wake_up(),
                            senderid = my_id,
                            targetid = lnkg->S_objid,
                            targetos = OM_Gw_current_OS );
         if (!(1&status))
         {
            printf("IN module wake up global class IGEcolor\n");
            om$report_error(sts = status);
         }
         lnkg->S_objid = NULL_OBJID;
         found_color = 1;
         break;
      }
   }

   if (!found_color)
   {
      /*==========================================================*/
      /*  Niether IGEcolor or IGEcolor2 is there - so create one  */
      /*==========================================================*/

      ex$get_cur_mod ( id    = &mod_objid,
                       osnum = &mod_osnum );

      status = ex$get_super ( mod_id      = mod_objid,
                              mod_osnum   = mod_osnum,
                              super_name  = "IGECOLOR2",
                              create      = TRUE,
                              super_class = "IGEcolor2",
                              super_id    = &col_objid,
                              super_osnum = &col_osnum);
   }

   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "super";

   status = om$get_channel_count ( osnum        = OM_Gw_current_OS,
                                   objid        = my_id,
                                   p_chanselect = &chandef1,
                                   count        = &number_objs );
   if (!(1&status))
   {
      printf("IN module wake up get chennel count error\n");
      om$report_error(sts = status);
      if (linkage) free (linkage);
      return (status);
   }

   if (number_objs > 0)
   {
      if (linkage && (number_objs > save_numobjs))
      {
         linkage = (OM_S_OBJECT_LINKAGE *)
                   realloc(linkage, sizeof(OM_S_OBJECT_LINKAGE) * number_objs);
      }
      else
      {
         if (!linkage)
            linkage = (OM_S_OBJECT_LINKAGE *)
                      malloc(sizeof(OM_S_OBJECT_LINKAGE) * number_objs);
      }
      if (!linkage) return (OM_E_NODYNMEM);
   }

   status = om$get_channel_objects ( osnum        = OM_Gw_current_OS,
                                     objid        = my_id,
                                     p_chanselect = &chandef1,
                                     list         = linkage,
                                     size         = number_objs,
                                     count        = &count );
   if(!(1&status))
   {
      printf("IN module wake up get chennel objects error\n");
      om$report_error(sts = status);
      if (linkage) free(linkage);
      return (status);
   }
/******* FIX FOR ASSEMBLIES TO ENABLE THE Super_rfmgr TO BE WOKENUP BEFORE THE
         EMasmmgr.
********/
   {
    OM_S_OBJID mgr_objid;
    int asmmgr_indx=-1;

        for (i = 0; i< number_objs; i++)
        {
          class_name[0] = '\0';
          status = om$get_classname ( osnum     = OM_Gw_current_OS,
                                      objid     = linkage[i].S_objid,
                                      classname = class_name );

          if (!strcmp(class_name,"EMasmmgr"))
                asmmgr_indx = i;

          if (!strcmp(class_name,"Super_rfmgr"))
                break;
        }

        /* If assembly manager and refmanager are found and if the refmanager
           index is higher than assembly manager index, swap the two objects
           in the linkage list.
        */
        if ((asmmgr_indx != -1) && (i != number_objs) && (i > asmmgr_indx))
        {
            mgr_objid = linkage[asmmgr_indx].S_objid;
            linkage[asmmgr_indx].S_objid = linkage[i].S_objid;
            linkage[i].S_objid = mgr_objid;
        }
   }
/********* END OF FIX ******************/

   lnkg = linkage;
   for (i = 0; i< number_objs; i++,lnkg++)
   {
      /*==================================================================*/
      /*  this is done again because wake_up is recursive and on wakeup   */
      /*  to reference file manager vis_flag = 1, set EX_temp_wake_up =0  */
      /*  and is never reset causing palette menu problems                */
      /*==================================================================*/

      if (vis_flag == 2)  /* temp wakeup */
      {
         EX_temp_wakeup = 1;  /* set temp wake up before send to super */
      }
      else  /* not temp */
      {
         EX_temp_wakeup = 0;
      }

      class_name[0] = '\0';
      status = om$get_classname ( osnum     = OM_Gw_current_OS,
                                  objid     = lnkg->S_objid,
                                  classname = class_name );

      if ((!strcmp(class_name,"GRpalmgr")))
      {

         GRpalmgr = lnkg->S_objid;
         /*send him wake_up last for 2 reasons,one he wants to be the last to
           draw also journaling expects it in this order*/
         continue;
      }


      if ( !((strcmp( class_name,"IGEcolor2" ) == 0 ) ||
             (strcmp( class_name,"IGEcolor"  ) == 0 )) )

      {
        status = om$send ( mode     = OM_e_wrt_object,
                         msg      = message global_class.wake_up(),
                         senderid = my_id,
                         targetid = lnkg->S_objid,
                         targetos = OM_Gw_current_OS );
      if (!(1&status))
      {
         class_name[0] = '\0';
         om$get_classname ( osnum     = OM_Gw_current_OS,
	                    objid     = lnkg->S_objid,
                            classname = class_name );

         if (!strcmp(class_name,"Super_rfmgr"))
	 {
            /*  number of files execeeded , increase MAX_REF_FILES  */
            ex$message(msgnumb = EX_F_FileLimit);
            if (linkage) free (linkage);
            return(OM_E_NO_OS_AVAIL);
         }

         if (status != OM_E_NOSUCHCLASS)
	 {
           if (OM_Gf_verbose_warning)
           {
              printf("-2- send to global_class.wake_up status = %x\n",status);
              om$report_error(sts = status);
              printf("super index = <%d> super class = <%s>\n",i,class_name);
           }
	 }
      }
    }/*end if not color do not send color another wakeup*/
   }/*end of for lop*/

#ifdef TIMING_TEST
   EX_end_timing("Module wake_up til wsys activate");
#endif

   if (vis_flag == 1)
   {
      os_num = OM_Gw_current_OS;
      if (ex$is_interactive())
      {
         chandef1.type = OM_e_name;
         chandef1.u_sel.name = "exec.hw_win";
         chandef2.type = OM_e_name;
         chandef2.u_sel.name = "module.windows";

         if (EX_same_file != 1)
         {
#ifdef TIMING_TEST
            EX_start_timing();
#endif

            status = om$send ( mode         = OM_e_wrt_object,
                               msg         = message IGEwsys.activate(&msg,-1),
                               senderid     = my_id,
                               p_chanselect = &chandef2,
                               targetos     = os_num,
                               from         = NULL,
                               to           = OM_K_MAXINT );
            check_error_status(status,"module.wakeup, window.activate error");

#ifdef TIMING_TEST
            EX_end_timing("reactivate window -----");
#endif
         }
      }
   }
   if (in_master_file)
   {
    EX_in_save_command(&save_flag);
    if (save_flag)
     {
     EX_store_window_on_save();
     }

                     /*store igewindows in journal file if from save*/
   if ( GRpalmgr != NULL_OBJID)
   {
      if (vis_flag == 2 )  /* temp wakeup */
       {
        EX_temp_wakeup = 1;  /* set temp wake up before send to super */
       }
      else  /* not temp */
       {
        EX_temp_wakeup = 0;
       }
       /*the grpalmgr object will always be the last super to get wakeup*/
         status = om$send ( mode     = OM_e_wrt_object,
                            msg      = message global_class.wake_up(),
                            senderid = my_id,
                            targetid = GRpalmgr,
                            targetos = OM_Gw_current_OS );
         if (!(1&status))
         {
            printf("IN module wake up global class IGEcolor\n");
            om$report_error(sts = status);
         }
     }
   }/*end if in master*/
   if (linkage) free (linkage);
   EX_temp_wakeup = 0;
   return(OM_S_SUCCESS);

}


method execute_mod ( int *response; char *response_data )
{
   return(OM_S_SUCCESS);
}


method GRmod_passon ( IGRlong          *msg;
                      OM_S_MESSAGE     *pass_msg;
                      IGRchar          *chan;
                      IGRint           *begin;
                      IGRint           *fin)
{
   static OM_S_CHANSELECT  chandef1;
   static char             last_name[OM_K_MAXCHANNAME_LEN+1] = { 0 };

   *msg = OM_S_SUCCESS;

   if (strcmp ( last_name, chan ))
   {
      int status;

      chandef1.type = OM_e_num;
      status = om$get_channel_number ( channame  = chan,
                                         p_channum = &chandef1.u_sel.number );
      if (!(status&1))
      {
         if (OM_Gf_verbose_warning)
         {
            fprintf(stderr, "%s, line %d\n", __FILE__, __LINE__);
            om$report_error ( sts = status );
         }
         chandef1.type = OM_e_name;
         chandef1.u_sel.name = chan;
         *last_name = '\0';
      }
      else
         strcpy ( last_name, chan );
   }

   return ( om$send ( mode         = OM_e_wrt_object,
                      msg          = pass_msg,
                      senderid     = my_id,
                      p_chanselect = &chandef1,
                      from         = *begin,
                      to           = *fin));
}


method GRmd_add_super ( IGRchar *super_name;
                        OM_S_OBJID *super_id;
                        int wakeup_flag )
{
   IGRlong          status;
   OM_S_CHANSELECT  chandef1;

   status = om$construct ( classname = super_name,
                           p_objid   = super_id,
                           msg       = message global_class.super_construct());
   if (!(1&status))
   {
      printf("OM_construct %s error\n",super_name);
      om$report_error(sts = status);
      return (OM_E_ERROR);
   }

   chandef1.type = OM_e_addr;
   chandef1.u_sel.addr = &ME.module->super;

   status = om$send ( mode     = OM_e_wrt_object,
                      msg      = message global_class.place(&chandef1),
                      targetid = *super_id );

   check_error_status(status,"module_init, global_class.place error");
   if (!(1&status)) return(OM_E_ERROR);
  if (wakeup_flag)
   {
   status = om$send ( mode     = OM_e_wrt_object,
                      msg      = message global_class.wake_up(),
                      targetid = *super_id );

   check_error_status(status,"module_init, global_class.wake_up error");
   if (!(1&status)) return(OM_E_ERROR);
   }
   return (OM_S_SUCCESS);
}


method delete (int flag)
{
   printf(" You can not delete this module object\n");
   printf(" delete module object : sender_id = <%d> sender_os = <%d>\n ",
            sender_id,sender_os);
   return(OM_E_ERROR);
}


int EX_is_temp_wakeup()
{
   return (EX_temp_wakeup);
}


void EX_init_session()
{
   int   status;
   long   msg;
   char  file_name[257];
   char  tmpfile[257];
   char *slash;
   int   path_found;
   int   j;

   status = exInitUData();
   if (status != UDATA_SUCCESS)
      printf("User Data Mechanism not initialized\n");

   if (ex$is_interactive())
   {
      ex$message ( msgnumb = EX_M_Clear );
      ex$message ( msgnumb = EX_M_Clear );

      /******************************************************/
      /*     load button definition                         */
      /******************************************************/

      status = ex$get_path ( index=0, path=file_name, len=sizeof(file_name) );
      strcat (file_name, "config/" );

      slash = strrchr (file_name, '/' );
      *slash = '\0';
      strcat (file_name, "/button_file" );

      status = EX_load_button ( &msg, file_name );
      if (!(1&status))
      {
         path_found = TRUE;
         for (j=1; !(1&status) && path_found; j++)
         {
            path_found = ex$get_path ( index = j,
                                       path  = tmpfile,
                                       len   = sizeof(tmpfile) );
            if (path_found)
            {
               strcat (tmpfile, "config/button_file" );
               status = EX_load_button ( &msg, tmpfile );
            }
         }
         if (!(1&status))
         {
            printf("\n Error loading button  keys %s \n",tmpfile);
         }
      }

      /******************************************************/
      /*     load function key                              */
      /******************************************************/

      slash = strrchr ( file_name, '/' );
      *slash = '\0';
      strcat ( file_name, "/function_key" );

      status = EX_load_funckey ( EX_INIT, file_name );
      if (!(1&status))
      {
         path_found = TRUE;
         for (j=1; !(1&status) && path_found; j++)
         {
            path_found = ex$get_path ( index = j,
                                       path  = tmpfile,
                                       len   = sizeof(tmpfile) );
            if (path_found)
            {
               strcat ( tmpfile, "config/function_key" );
               status = EX_load_funckey ( EX_INIT, tmpfile );
            }
         }
         if (!(1&status))
         {
            printf("\n Error loading function keys %s\n",tmpfile);
         }
      }
   }
}

end implementation module;
