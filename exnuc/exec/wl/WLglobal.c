#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "wl.h"
#include "igrtypedef.h"
#include "wl_internal.h"
 
struct WLIscreen WLIscreens_arr[WL_MAX_SCREENS];
int WLIactive_screen;
int WLIinitialized = 0;
int WLIbatch_mode = 0;
int WLInum_phy_screens = 0;
int WLIreport_error = WLI_FALSE;
int WLISRwin_no = -1;
int WLIdefault_vlt_no[WL_MAX_SCREENS];
WLfont WLIdefault_font;
int WLIline_style_factor = WLI_FALSE;
struct WLIstyle_struct WLIline_style[WL_MAX_STYLES];
 
#if defined( WIN32 )
static char WLIwin_class_name[1000]="WLI_WINDOWS";
static char WLIapp_main_class_name[1000]="WLI_MAIN_WINDOWS";
#endif
 
#if defined( OPENGL )
GLUtriangulatorObj *gl_triangulator = NULL;

GLXContext gl_share_context = NULL;
int gl_attrib_list[] = { GLX_USE_GL, None };
int WLIglx_last_win_type = -1;
#endif

#if defined (XGL)
Xgl_sys_state	sys_state = NULL;
#endif

int		WLhilite_enabled = TRUE;

