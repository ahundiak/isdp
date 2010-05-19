/* $Id: main.C,v 1.1 2001/01/11 22:16:23 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/copics/main.C
 *
 * Description: Convert xml files to copics
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: main.C,v $
 * Revision 1.1  2001/01/11 22:16:23  art
 * sp merge
 *
 * Revision 1.3  2000/12/08  17:04:12  pinnacle
 * ah
 *
 * Revision 1.2  2000/10/11  20:22:34  pinnacle
 * js
 *
 * Revision 1.1  2000/07/17  19:21:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/05/00  ah      Creation
 *
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDxml.h"
#include "VDvlaInfo.h"

#include <stdio.h>
#include <FI.h>
#include "VDct1Copics.h"
#include "VDct1CopForm.h"

static int traceFlag;

/* -----------------------------------------------
 * Wake up the form
 */
extern VDct1NotifyCopForm();


Display *display;

extern char *exefile();


/* --------------------------------------------------------
 * Look through config directories for access control file
 */
static char getFormPath(char *formPath)
{
  int i;
  char buf[1056];

  *buf = 0;
  
  strcpy( buf , exefile() ) ;
  if (*buf == 0) return 0;
  
  *strrchr( buf, '/' ) = '\0' ;
  *strrchr( buf, '/' ) = '\0' ;
  sprintf( formPath, "%s/config/english/forms", buf ) ;
  
  return 1;
  
}

static int initViewCopInfo()
{
  int     sts;
  Form    form;
  
  sts = FIf_new (555, VDCT1_FORM_COP_F_NAME , VDct1NotifyCopForm, &form);
  if( sts ) {
		fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
		return sts;
	}
  sts = FIf_display( form );
  
  return 0;
  
}

int main()
{
  IGRstat sts;
  IGRchar *display_name = "";
  IGRchar formPath[1056];
  
  
  //printf("-------- Beginning Run ------\n");
  //  VDct1CopAssyGenerateCopics("WWayTree_1234.xml");

  //VDct1CopPalGenerateCopics("PalAssys_1234.xml");

  if (( display = XOpenDisplay (display_name)) == None) {
    fprintf(stderr, "%s: cannot connect to X server %s\n", XDisplayName (display_name));
    exit (-1);
  }
  
  FSEnter( display, 0 );
  
  FI_enter (display, DefaultColormap(display,DefaultScreen(display)) , 32);

  sts = getFormPath(formPath);
  if (! (sts & 1)) {
    printf("### Form not found\n");
    exit (-1);
  }
  
        FI_set_form_path( formPath );

	FI_set_symbol_path( formPath );
  
  sts = initViewCopInfo();
  
  if ( !(sts & 1)) FI_process_forms();
  
  XCloseDisplay( display );
  
 
}

