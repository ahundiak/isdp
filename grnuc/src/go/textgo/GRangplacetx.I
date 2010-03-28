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
     Value = GRang_place_text (msg,text_string,text_length,origin,rot_matrix,
                               lbs_matrix,DatabaseType,classname,ActiveDisplay,
                               ActiveLevel,Properties,ModuleInfo,TextSymb,mode
                               win_objid,flags,buffer)

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
     mode           enum GRdpmode           display mode
     win_objid      GRobjid                 window(s) to display text
     flags          IGRint                  miscellaneous flags
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *buffer      struct GRid     objid and osnum of text obj

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
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "dp.h"
#include   "grimport.h"

IGRint GRang_place_text (msg,text_string,text_length,origin,rot_matrix,
                         lbs_matrix,DatabaseType,classname,ActiveDisplay,
                         ActiveLevel,Properties,ModuleInfo,TextSymb,mode,
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
enum GRdpmode           mode;            /* display mode                */
GRobjid                 win_objid;       /* window(s) to display text   */
IGRint                  flags;           /* miscellaneous flags         */
struct GRid             *buffer;         /* objid and osnum of text obj */
{
   IGRint               nbytes_in_buffer;   /* number bytes needed      */
   IGRint               nbytes_transferred; /* number bytes returned    */
   IGRdouble            active_angle;       /* local active angle       */
   IGRlong              status;             /* return status            */

   status = MSSUCC;

   /* 
    * get the default active angle from the DPB
    */

   nbytes_in_buffer = sizeof(active_angle);
   gr$get_active_angle(msg = msg,
                       sizbuf = &nbytes_in_buffer,
                       buffer = &active_angle,
                       nret = &nbytes_transferred);

   GRplace_text (msg,text_string,text_length,origin,rot_matrix,lbs_matrix,
                 DatabaseType,classname,ActiveDisplay,ActiveLevel,
                 Properties,ModuleInfo,TextSymb,active_angle,mode,
                 win_objid,flags,buffer);

   return (status);
}
end implementation GRtext;
