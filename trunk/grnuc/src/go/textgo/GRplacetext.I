/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     CLASS NAME   GRtext
 
     Abstract: This function will either construct and display a
               text object or display the text without constructing
               it. The text string, text length, origin, and rotation
               matrix must be given. Other attributes are optional
               and, if not passed in, will be picked up from the DPB.
-----
%SC%
     Value = GRplace_text (msg,text_string,text_length,origin,rot_matrix,
                           lbs_matrix,DatabaseType,classname,ActiveDisplay,
                           ActiveLevel,Properties,ModuleInfo,TextSymb,
                           ActiveAngle,mode,win_objid,flags,buffer)

-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------     ------------            ---------------------------
     *text_string   IGRuchar                text string
     *text_length   IGRshort                length of text string
     origin         GRpoint                 placement pt of text string
     *rot_matrix    IGRdouble               view rotation matrix used
     *lbs_matrix    IGRdouble               local bounded system matrix
     *DatabaseType  IGRchar                 type of database (2d,3d,3i)
     *classname     IGRchar                 type of class to create
     *ActiveDisplay struct IGRdisplay       display parameters to use
     ActiveLevel    IGRshort                level to place text on
     *Properties    IGRushort               the object's graphic properties
                                            (displayable, locatable, etc.);
                                            #defines for these properties
                                            can be found in godef.h
                                            NOTE:  setting the GRFILLED_DISPLAY
                                            bit will NOT result in the text
                                            being filled - the appropriate bit
                                            in the TextSymb structure below
                                            must be set
     *ModuleInfo    struct GRmd_env         module environment
     *TextSymb      struct GRdpb_text_symb  text symbology
     ActiveAngle    IGRdouble               active angle
     *mode          GRdpmode                display mode
     *win_objid     GRobjid                 object id of window
     flags          IGRint                  miscellaneous flags
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *buffer      GRid            object id of constructed text object

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

-----
%RL%

     RELATIONS REFERENCED: none

-----
%NB%

     NOTES:  

-----
%CH%
     CHANGE HISTORY:
        
        DEK  09/17/87 : Design date.
        DEK  09/17/87 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This function will either construct and display a text object 
or display the text without constructing it. The text string, text 
length, origin, and rotation matrix must be given. Other attributes 
are optional and, if not passed in, will be picked up from the DPB.
----*/
/*EH*/

class implementation GRtext;

#include   "msdef.h"
#include   "gotextdef.h"
#include   "grdpbmacros.h"
#include   "dpmacros.h"
#include   "OMmacros.h"
#include   "exmacros.h"
#include   "fontdef.h"
#include   "font.h"
#include   "gotext.h"
#include   "grdpbdef.h"
#include   "grdpb.h"
#include   "dp.h"
#include   "grimport.h"

IGRint GRplace_text (msg,text_string,text_length,origin,rot_matrix,lbs_matrix,
                     DatabaseType,classname,ActiveDisplay,ActiveLevel,
                     Properties,ModuleInfo,TextSymb,ActiveAngle,mode,
                     win_objid,flags,buffer)

IGRlong                 *msg;            /* completion code             */
IGRuchar                *text_string;    /* text string                 */
IGRshort                *text_length;    /* length of text string       */
IGRpoint                origin;          /* origin point for string     */
IGRdouble               *rot_matrix;     /* view rotation matrix        */
IGRdouble               *lbs_matrix;     /* local bounded system matrix */
IGRchar                 *DatabaseType;   /* type of database using      */
IGRchar                 *classname;      /* type of class to create     */
struct IGRdisplay       *ActiveDisplay;  /* active display parameters   */
IGRshort                ActiveLevel;     /* level to place text on      */
IGRushort               *Properties;     /* graphics properties         */
struct GRmd_env         *ModuleInfo;     /* module environment info.    */
struct GRdpb_text_symb  *TextSymb;       /* text symbology parameters   */
IGRdouble               ActiveAngle;     /* active angle                */
enum GRdpmode           mode;            /* display mode                */
GRobjid                 win_objid;       /* window(s) to display text   */
IGRint                  flags;           /* miscellaneous flags         */
struct GRid             *buffer;         /* objid and osnum of text obj */
{
   IGRint               nbytes_in_buffer;   /* number bytes needed      */
   IGRint               nbytes_transferred; /* number bytes returned    */
   IGRchar              database_type[MAX_DB_TYPE_SIZE];
   IGRchar              class_name[12];
   struct IGRdisplay    active_display;     /* local display parameters */
   IGRshort             active_level;       /* local active level       */
   IGRushort            properties;         /* graphics properties      */
   struct GRmd_env      module_info;        /* local module environment */
   struct GRdpb_text_symb text_symb;        /* local text symbology     */
   IGRdouble            active_angle;       /* local active angle       */
   enum GRdpmode        dpmode;             /* display mode             */
   GRobjid              window_objid;       /* local window(s) to disp  */
   IGRlong              status;             /* return status            */

   status = MSSUCC;

   if (classname == NULL)
   {
      if (DatabaseType == NULL)
      {
         /*
          *  get the default database type from the DPB
          */

         nbytes_in_buffer = MAX_DB_TYPE_SIZE;
         gr$get_database_type(msg = msg,
                              sizbuf = &nbytes_in_buffer,
                              buffer = database_type,
                              nret = &nbytes_transferred);

         strcpy(class_name,"GR");
         strcat(class_name,database_type);
         strcat(class_name,"text");
      }
      else
      {
         strcpy(class_name,"GR");
         strcat(class_name,DatabaseType);
         strcat(class_name,"text");
      }
   }
   else
   {
      strcpy(class_name,classname);
   }

   if (ActiveDisplay == NULL)
   {
      /*
       *  get the default display symbology data from the DPB
       */

      nbytes_in_buffer = sizeof(active_display);
      gr$get_active_display(msg = msg,
                            sizbuf = &nbytes_in_buffer,
                            buffer = &active_display,
                            nret = &nbytes_transferred);
   }
   else
   {
      active_display = *ActiveDisplay;
   }

   if (ActiveLevel == -1)
   {
      /*
       *  get the default active level from the DPB
       */

      nbytes_in_buffer = sizeof(active_level);
      gr$get_active_level(msg = msg,
                          sizbuf = &nbytes_in_buffer,
                          buffer = &active_level,
                          nret = &nbytes_transferred);
   }
   else
   {
      active_level = ActiveLevel;
   }

   if (Properties == NULL)
   {
      /*
       * get the default properties from the DPB
       */

      nbytes_in_buffer = sizeof(properties);
      gr$get_active_prop(msg = msg,
                         sizbuf = &nbytes_in_buffer,
                         buffer = &properties,
                         nret = &nbytes_transferred);
   }
   else
   {
      properties = *Properties;
   }

   /*
    * must clear the GRFILLED_DISPLAY bit in properties; to have filled text
    * the GRFILLED_TEXT bit must be set in the text symbology structure's
    * Active_flags member
    */

   properties &= ~GRFILLED_DISPLAY;

   if (ModuleInfo == NULL)
   {
      /*
       * get the default module environment from the DPB
       */

      nbytes_in_buffer = sizeof(module_info);
      gr$get_module_env(msg = msg,
                        sizbuf = &nbytes_in_buffer,
                        buffer = &module_info,
                        nret = &nbytes_transferred);
   }
   else
   {
      module_info = *ModuleInfo;
   }

   if (TextSymb == NULL)
   {
      /*
       * get the default text symbology parameters from the DPB
       */

      nbytes_in_buffer = sizeof(text_symb);
      gr$get_text_symb(msg = msg,
                       sizbuf = &nbytes_in_buffer,
                       buffer = &text_symb,
                       nret = &nbytes_transferred);
   }
   else
   {
      text_symb = *TextSymb;
   }

   active_angle = ActiveAngle;
   dpmode = mode;
   window_objid = win_objid;

   if (buffer == NULL)
   {
      GRdisptext(msg,text_string,text_length,origin,rot_matrix,lbs_matrix,
                 &active_display,&active_level,&module_info,&text_symb,
                 &properties,&active_angle,&dpmode,&window_objid,flags);
   }
   else
   {
      GRcreatetext(msg,text_string,text_length,origin,rot_matrix,lbs_matrix,
                   class_name,&active_display,&active_level,&module_info,
                   &text_symb,&properties,&active_angle,&dpmode,&window_objid,
                   flags,buffer);
   }

   return(status);
}
end implementation GRtext;
