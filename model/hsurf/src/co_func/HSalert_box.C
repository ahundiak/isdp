
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

/*		Apogee compliant		*/

#include <stdio.h>
#include <math.h>
#include <FI.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "msdef.h"
#include "msmacros.h"
#include "hsmsg.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "HSpr_render.h"

#include "HSpr_co_func.h"

/*----------------------
 *  for functions
 *     HStexture_file_not_found
 *     HStexture_file_same_as_output_file
 */

#include "HSpr_render.h"

/*-----------------------*/

/*---HSpix_count-----------------------------------------*/

/*
NAME
    HSpix_count
    
DESCRIPTION
    Display message that HSURF was unable to allocate z buffer
    memory for the active window

FUNCTIONS CALLED
    ex$message
    FI_message_box
        
HISTORY
    ??/??/??    M. Lanier
        Created
*/

void HSpix_count (void)

    {
    char      HSmsg0[45], HSmsg1[45];
    char      HSmsg2[45], HSmsg3[45];
    char      HSmsg4[45], HSmsg5[45];
    char      HSmsg6[45], HSmsg7[45], HSmessage[400];

    ex$message (msgnumb = HS_E_TooMuchMem0, buff = HSmsg0);
    ex$message (msgnumb = HS_E_TooMuchMem1, buff = HSmsg1);
    ex$message (msgnumb = HS_E_TooMuchMem2, buff = HSmsg2);
    ex$message (msgnumb = HS_E_TooMuchMem3, buff = HSmsg3);
    ex$message (msgnumb = HS_E_TooMuchMem4, buff = HSmsg4);
    ex$message (msgnumb = HS_E_TooMuchMem5, buff = HSmsg5);
    ex$message (msgnumb = HS_E_TooMuchMem6, buff = HSmsg6);
    ex$message (msgnumb = HS_E_TooMuchMem7, buff = HSmsg7);

    sprintf (HSmessage, "%s  %s\n\n %s\n %s\n %s %s\n\n%s %s",
             HSmsg0, HSmsg1, HSmsg2, HSmsg3, HSmsg4, HSmsg5, HSmsg6, HSmsg7);

    ex$message (msgnumb = HS_W_WarnTitle, buff = HSmsg0);
    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    HSmsg0, FI_RED, "swiss742", 36.0,
                    HSmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);

    }   /* HSpix_count */

/*---HSout_of_zrange------------------------------------------*/

/*
NAME
    HSout_of_zrange
    
DESCRIPTION
    Display a warning that the user is placing in a shading
    window, an object whose zrange exceeds that of the
    shading window.
    
KEYWORDS
    zrange
    message

PARAMETERS
    lwin_no: (IN):  Logical window number

FUNCTIONS CALLED
    WLget_window_name
    ex$messages
    FI_message_box
        
HISTORY
    ??/??/??    M. Lanier(?)
        Created    
*/

void HSout_of_zrange (WLuint32  lwin_no)

    {
    char     *window_name;
    char     HSmsg0[65], HSmsg1[45];
    char     HSmsg2[45], HSmsg3[45];
    char     HSmsg4[45], HSmessage[245];


    WLget_window_name( lwin_no, &window_name );

    ex$message (msgnumb = HS_E_OutOfZRange0, buff = HSmsg0);
    ex$message (msgnumb = HS_E_OutOfZRange1, buff = HSmsg1);
    ex$message (msgnumb = HS_E_OutOfZRange2, buff = HSmsg2);
    ex$message (msgnumb = HS_E_OutOfZRange3, buff = HSmsg3);
    ex$message (msgnumb = HS_E_OutOfZRange4, buff = HSmsg4);

    sprintf (HSmessage, "%s '%s' %s\n\n%s\n    %s\n    %s",
             HSmsg0, window_name, HSmsg1, HSmsg2, HSmsg3, HSmsg4);

    ex$message (msgnumb = HS_W_WarnTitle, buff = HSmsg0);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    HSmsg0, FI_RED, "swiss742", 36.0,
                    HSmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);

    }   /* HSout_of_zrange */


/*---HSwrong_window-----------------------------------------*/

/*
NAME
    HSwrong_window
    
DESCRIPTION
    Display a message that says that the user cannot convert
    a window to shading if that window is no a virtual screen
    that does not support shaded displays
    
FUNCTIONS CALLED
    ex$message
    FI_message_box
    
HISTORY
    ??/??/??    (??)
        Created
*/

void HSwrong_window (void)

    {
    char HSmessage[250];
    char title_msg[100];

    ex$message (msgnumb = HS_E_WrongVirtScreen, buff = HSmessage);
    ex$message (msgnumb = HS_W_WarnTitle, buff = title_msg);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    title_msg, FI_RED, "swiss742", 36.0,
                    HSmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);

    }   /* HSwrong_window */

/*---HSnew_vs--------------------------------------------------*/

/*
NAME
    HSnew_vs
    
DESCRIPTION
    Display a message telling the user that a shading window
    cannot be moved to another virtual screen
    
FUNCTIONS CALLED
    ex$message
    FI_message_box
    
HISTORY
    ??/??/??    S. Rogers
        Created
    
*/

void HSnew_vs (void)

    {
    char HSmessage[250];
    char title_msg[100];

    ex$message (msgnumb = HS_E_NewVirtScreen, buff = HSmessage);
    ex$message (msgnumb = HS_W_WarnTitle, buff = title_msg);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    title_msg, FI_RED, "swiss742", 36.0,
                    HSmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);

    }   /* HSnew_vs */

/*---HSreconfiguring_user_table-----------------------------------------*/

/*
NAME
    HSreconfiguring_user_table
    
DESCRIPTION
    Display a message telling the user that the user colortable
    saved in the file is not compatable for the current workstation
    
FUNCTIONS CALLED
    ex$message
    FI_message_box
    
HISTORY
    ??/??/??    S. Rogers(?)
         Created
*/

void HSreconfiguring_user_table (IGRboolean edgeII_flag)

    {
    char temp_msg[100], HSmessage[1000];

    HSmessage[0] = '\0';

    if (edgeII_flag)
        {
        /* re-configuring a user table to run in true color mode */
        /* on an EDGE II                                         */
        ex$message (msgnumb = HS_E_ReconfigEdgeIICTbl0, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigEdgeIICTbl1, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigEdgeIICTbl2, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigEdgeIICTbl3, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigEdgeIICTbl4, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigEdgeIICTbl5, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigEdgeIICTbl6, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigEdgeIICTbl7, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        }
    else
        {
        /* re-configuring a user table and we aren't in true color mode */
        ex$message (msgnumb = HS_E_ReconfigCTbl0, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigCTbl1, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        ex$message (msgnumb = HS_E_ReconfigCTbl2, buff = temp_msg);
        sprintf (HSmessage, "%s %s", HSmessage, temp_msg);
        }

    ex$message (msgnumb = HS_W_WarnTitle, buff = temp_msg);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    temp_msg, FI_RED, "swiss742", 36.0,
                    HSmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);

    }   /* HSreconfiguring_user_table */

/*---HSnot_enough_planes_to_render---------------------------------*/

/*
NAME
    HSnot_enough_planes_to_render
    
DESCRIPTION
    Display a message telling the user that the window's
    virtual screen does not enough bit planes for rendering
    
FUNCTIONS CALLED
    ex$message
    FI_message_box
    
HISTORY
    ??/??/??    S. Rogers
        Created
*/

void HSnot_enough_planes_to_render (void)

    {
    char HSmessage[250], title_msg[100];

    ex$message (msgnumb = HS_E_NotEnoughToRender, buff = HSmessage);
    ex$message (msgnumb = HS_W_WarnTitle, buff = title_msg);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    title_msg, FI_RED, "swiss742", 36.0,
                    HSmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);

    }   /* HSnot_enough_planes_to_render */

/*---HSnot_enough_planes_for_RGB------------------------------------------*/

/*
NAME
    HSnot_enough_planes_for_RGB
    
DESCRIPTION
    Display a message telling the user that the window's virtual
    screen does not have enough planes to display RGB data
    
FUNCTIONS CALLED
    ex$message
    FI_message_box
    
HISTORY
    ??/??/??    S. Rogers
        Created
*/

void HSnot_enough_planes_for_RGB (void)

    {
    char HSmessage[250], title_msg[100];

    ex$message (msgnumb = HS_E_NotEnoughForRGB, buff = HSmessage);
    ex$message (msgnumb = HS_W_WarnTitle, buff = title_msg);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    title_msg, FI_RED, "swiss742", 36.0,
                    HSmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);

    }   /* HSnot_enough_planes_for_RGB */

/*---HSnot_enough_planes_to_shade------------------------------------------*/

/*
NAME
    HSnot_enough_planes_to_shade
    
DESCRIPTION
    Display a message telling the user that the window's virtual
    screen does not have enough planes for shading
    
FUNCTIONS CALLED
    ex$message
    FI_message_box
    
HISTORY
    ??/??/??    S. Rogers
        Created
*/

void HSnot_enough_planes_to_shade (char *win_name)

    {
    char temp_msg[100], HSmessage[250];

    HSmessage[0] = '\0';
    ex$message (msgnumb = HS_E_NotEnoughToShade0,
                buff = HSmessage,
                var = `win_name `,
                type = "%s");

    ex$message (msgnumb = HS_E_NotEnoughToShade1, buff = temp_msg);
    sprintf (HSmessage, "%s %s", HSmessage, temp_msg);

    ex$message (msgnumb = HS_W_WarnTitle, buff = temp_msg);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    temp_msg, FI_RED, "swiss742", 36.0,
                    HSmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);

    }   /* HSnot_enough_planes_to_shade */

/*---HStexture_file_not_found------------------------------------*/

/*
NAME
    HStexture_file_not_found
    
DESCRIPTION
    Display a message telling the user that the named texture
    file count be found
    
FUNCTIONS CALLED
    ex$message
    FI_message_box
    
PARAMETERS
    filename: (IN): The name of the texture file that count be found
    
HISTORY
    ??/??/??    S. Rogers(?)
        Created
*/

void HStexture_file_not_found (IGRchar * filename)

    {
    IGRchar temp_message[100], final_message[250];

    ex$message (msgnumb = HS_E_NoTextureFile1, buff = final_message,
                var = `filename `, type = "%s");
    ex$message (msgnumb = HS_E_NoTextureFile2, buff = temp_message);

    strcat (final_message, " ");
    strcat (final_message, temp_message);

    ex$message (msgnumb = HS_W_NoteTitle, buff = temp_message);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    temp_message, FI_BLUE, "swiss742", 36.0,
                    final_message, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 50);

    }   /* HStexture_file_not_found */

/*---HStexture_file_same_as_output_file------------------------------*/

/*
NAME
    HStexture_file_same_as_output_file
    
DESCRIPTION
    Display message telling user that the named texture file is
    the same as the output design file
    
PARAMETERS
    filename: (IN): texture filename
    
FUNCTIONS CALLED
    ex$message
    FI_message_box
    
HISTORY
    ??/??/??    S. Rogers
        Created
*/

void HStexture_file_same_as_output_file (IGRchar * filename)

    {
    IGRchar temp_message[100], final_message[250];

    ex$message (msgnumb = HS_E_TextureIsOutput1, buff = final_message,
                var = `filename `, type = "%s");
    ex$message (msgnumb = HS_E_TextureIsOutput2, buff = temp_message);

    strcat (final_message, " ");
    strcat (final_message, temp_message);

    ex$message (msgnumb = HS_W_NoteTitle, buff = temp_message);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    temp_message, FI_BLUE, "swiss742", 36.0,
                    final_message, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 50);

    }   /* HStexture_file_same_as_output_file */
