/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COsymplace

Description
   This is the command class for the place symbol, place cell,
   and place graphic group from library commands.

   0  - construct a cell.
   1  - construct a symbol.
   2  - construct a graphic group.
   3  - construct a view independent symbol.

History
   Gray Winn    02/02/87    Creation date.
   Gray Winn    12/17/87    Changes for version 1.1
   Gray Winn    03/28/88    Add the construct for a graphics group
\*/

class implementation COsymplace;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "codef.h"
#include "OMerrordef.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"

from GRgraphics   import GRdisplay;

/* 
 *  Control looping conditions
 */

#define SUCCESS     1     /* Continue looping                     */
#define RETCONTROL  2     /* Exit command and return(OM_S_SUCCESS */
#define FUNC_ERROR  3     /* Error then cleanup and restart       */

extern IGRint     DYsdinit();

/****************************************************************/
/*                       E X E C U T E                          */
/****************************************************************/

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
   IGRlong              om_msg;     /* OM return status       */
   IGRlong              ret_msg;    /* Function return code   */
   IGRlong              exit_code;  /* Loop control variable  */
   IGRpoint             origin;     /* origin of the symbol   */
   IGRint               msgnumb = 0;    /* message number         */
   unsigned short       properties;
   IGRmatrix            wld_to_vw_matrix;
   struct GRid          symbol_id;  /* symbol header id       */
   struct GRid          sdh_id;     /* symbol header id       */
   enum GRdpmode        dpmode;     /* display mode           */

   if (me->init_success & 1)
   {
      exit_code = SUCCESS;
   }
   else 
   {
      msgnumb = (me->init_success == 2) ? GR_F_NoActCelDfn : GR_E_ErrEncCmdTrm;
      ex$message (msgnumb = msgnumb);
      *response = TERMINATE;
      exit_code = RETCONTROL;
   }

   while (exit_code == SUCCESS)
   {
      if ((me->mytype == 1) || (me->mytype == 3))
      {
         msgnumb = GR_P_EntOrgSym;
      }
      else if (me->mytype == 0)
      {
         msgnumb = GR_P_EntCelOrg;
      }
#ifndef IDRAW
      else if (me->mytype == 2)
      {
         msgnumb = GR_P_EntOrgGrGrp;
      }
#endif IDRAW
      ex$message (msgnumb = msgnumb);

      /*
       *  Call the dynamics function to display the extents of the
       *  the symbol.  The cursor cooresponds to the origin.
       */

      DYsdinit(&ret_msg, me->scale, &me->active_angle, &me->active_symbol);

      /*
       *  Get the origin of the symbol
       */
      
      co$getevent(msg = &ret_msg,
         event_mask = GRm_DATA | GRm_RESTART | GRm_BACK_UP,
         response = response, response_data = response_data,
         event = &me->origin_event);

      UI_prompt ("");    
      switch (me->origin_event.response)
      {
         case DATA:
         {
            /* 
             *  Call a function to return the world to view_port 
             *  rotation matrix.
             */

            om_msg = GRget_window_matrix (&ret_msg, 
                     me->origin_event.event.button.osnum,
                     me->origin_event.event.button.objid,
                     wld_to_vw_matrix, NULL);

            if (COERROR(om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }

            origin[0] = me->origin_event.event.button.x;
            origin[1] = me->origin_event.event.button.y;
            origin[2] = me->origin_event.event.button.z;

            sdh_id.objid = me->active_symbol.objid;
            sdh_id.osnum = me->active_symbol.symbol_env.md_id.osnum;

            if ((me->mytype == 1) || (me->mytype == 3))
            {
#ifndef IDRAW
               if (me->mytype == 1)
               {
#endif IDRAW
                  properties = GRIS_NEW | GRIS_DISPLAYABLE | 
                               GRIS_LOCATABLE;
#ifndef IDRAW
               }
               else
               {
                  properties = GRIS_NEW | GRIS_DISPLAYABLE | 
                               GRIS_LOCATABLE | GRIS_VIEW_INDEP;
               }
#endif IDRAW
               om_msg = gr$sym_sm_place (
                        msg = &ret_msg, 
                        origin = origin,
                        angle = &me->active_angle,
                        scale = me->scale,
                        rot_matrix = wld_to_vw_matrix,
                        properties = properties,
                        level = me->level,
                        symbol_env = &me->active_symbol.symbol_env,
                        target_env = &me->ModuleInfo,
                        classname = me->classname,
                        sdh_id = &sdh_id,
                        sm_id = &symbol_id);
            }
            else if (me->mytype == 0)
            {
               om_msg = gr$sym_cl_place (
                        msg = &ret_msg, 
                        origin = origin,
                        angle = &me->active_angle,
                        scale = me->scale,
                        rot_matrix = wld_to_vw_matrix,
                        level = me->level,
                        symbol_env = &me->active_symbol.symbol_env,
                        target_env = &me->ModuleInfo,
                        classname = me->classname,
                        sdh_id = &sdh_id,
                        cl_id = &symbol_id);
            }
#ifndef IDRAW
            else if (me->mytype == 2)
            {
               om_msg = gr$sym_gg_place (
                        msg = &ret_msg, 
                        origin = origin,
                        angle = &me->active_angle,
                        scale = me->scale,
                        rot_matrix = wld_to_vw_matrix,
                        level = me->level,
                        symbol_env = &me->active_symbol.symbol_env,
                        target_env = &me->ModuleInfo,
                        classname = me->classname,
                        sdh_id = &sdh_id,
                        gg_id = &symbol_id);
            }
#endif IDRAW
            if (COERROR(om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }

            /*
             *  Display the symbol or the symbol reference.
             */
        
            dpmode = GRbd;

            om_msg = om$send(
                     msg = message GRgraphics.GRdisplay (&ret_msg,
                     &me->ModuleInfo.md_env.matrix_type,
                     me->ModuleInfo.md_env.matrix, &dpmode,
                     &me->ModuleInfo.md_id),
                     targetid = symbol_id.objid,
                     targetos = symbol_id.osnum);

            if (COERROR (om_msg & ret_msg))
            {
               exit_code = FUNC_ERROR;
               break;
            }
         }
         break;

         case EX_RESTART:
         case EX_BACK_UP:
         {
            /* 
             *  Remain at state_0.
             */
         }
         break;
                                        
         default:
         {
            /*
             *  Unknown event, return control to super_cmd
             */

             exit_code = RETCONTROL;
         }
         break;
      }  /* end of switch statement */
      
      if (exit_code == FUNC_ERROR)
      {
         ex$message (msgnumb = GR_E_ErrEncCmdRst);
         exit_code = SUCCESS;
      }
   }  /* end while        */
   return (OM_S_SUCCESS);
}  /* end execute method */

/****************************************************************/
/*                       W A K E U P                            */
/****************************************************************/

method wakeup (int pos)
{
   IGRint           msgnumb = 0;     /* message number                   */
   IGRlong          om_msg;      /* OM return status                 */
   IGRlong          ret_msg;     /* Function return code             */
   IGRlong          size;        /* Size of structure                */
   IGRlong          ret_size;    /* Size returned from DPB           */
   IGRchar          dbtype[MAX_DB_TYPE_SIZE];  /* Database type      */

   me->init_success = FALSE;

   /* 
    *  Get the module environment.
    */

   size = sizeof(me->ModuleInfo);
   if (gr$get_module_env (msg = &ret_msg,
                          sizbuf = &size, 
                          buffer = &me->ModuleInfo,
                          nret = &ret_size))
   {
      /* 
       *  Get the active symbol.  If an active symbol is defined 
       *  then return MSSUCC else return MSFAL.
       */

      om_msg = gr$symget_active_symbol (msg = &ret_msg, 
               act_symbol_def = &me->active_symbol);

      if (om_msg & ret_msg & 1)
      {
         /*
          *  display the active cell name
          */

         ex$message (msgnumb = GR_I_ActCel,
                     type = "%s",
                     var = `me->active_symbol.name`);

         /* 
          *  Get the active scale.
          */

         size = sizeof(struct GRdpb_scale);
         if (gr$get_active_scale (msg = &ret_msg, sizbuf = &size,
               buffer = &me->dpb_scale, nret = &ret_size))
         {
            me->scale[0] = me->dpb_scale.Active_xscale;
            me->scale[1] = me->dpb_scale.Active_yscale;
            me->scale[2] = me->dpb_scale.Active_zscale;

            /*
             *  Get the active angle (in radians)
             */

            size = sizeof (IGRdouble);
            if (gr$get_active_angle (msg = &ret_msg, sizbuf = &size,
               buffer = &me->active_angle, nret = &ret_size))
            {
               /* 
                *  Get the database type.
                */

               size = sizeof (dbtype);
               if (gr$get_database_type (msg = &ret_msg, sizbuf = &size,
                   buffer = dbtype, nret = &ret_size))
               {
                  /*
                   *  Get the active level
                   */

                  size = sizeof (me->level);
                  if (gr$get_active_level (msg = &ret_msg, sizbuf = &size,
                     buffer = &me->level, nret = &ret_size))
                  {
                     /*
                      *  build symbol header classname for the construct 
                      *  (in execute)
                      */
                  
                     if ((me->mytype == 1) || (me->mytype == 3))
                     {
                        if (dbtype[0] == '3' && dbtype[1] == 'd')
                        {
                           strcpy (me->classname, "GRsmhdr");
                        }
                        else
                        {
                           sprintf (me->classname, "GR%ssmhdr", dbtype);
                        }
                     }
                     else if (me->mytype == 0)
                     {
                        if (dbtype[0] == '3' && dbtype[1] == 'd')
                        {
                           strcpy (me->classname, "GRclhdr");
                        }
                        else
                        {
                           sprintf (me->classname, "GR%sclhdr", dbtype);
                        }
                     }
#ifndef IDRAW
                     else if (me->mytype == 2)
                     {
                        strcpy (me->classname, "GRgrgrp");
                     }
#endif IDRAW
                     me->init_success = 1;
                  }
               }
            }
         }
      }
      else
      {
         me->init_success = 2;
      }
   }  

   if (me->mytype == 0)
   {
      msgnumb = GRC_M_PlcCel;
   }
   else if (me->mytype == 1)
   {
      msgnumb = GRC_M_PlcSym;
   }
#ifndef IDRAW
   else if (me->mytype == 2)
   {
      msgnumb = GRC_M_PlcGrGrp;
   }
   else if (me->mytype == 3)
   {
      msgnumb = GRC_M_PlcVISym;
   }
#endif IDRAW
   ex$message (msgnumb = msgnumb);
   return (OM_S_SUCCESS);
}

end implementation COsymplace;
