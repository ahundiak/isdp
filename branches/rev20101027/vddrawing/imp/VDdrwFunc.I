/* $Id: VDdrwFunc.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp/ VDdrwFunc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwFunc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.8  1998/01/29  22:11:20  pinnacle
# ah
#
# Revision 1.7  1998/01/15  20:19:04  pinnacle
# Changed setup_Name
#
# Revision 1.6  1998/01/07  20:58:38  pinnacle
# Replaced: vddrawing/imp/VDdrwFunc.I for:  by yzhu for vds
#
# Revision 1.5  1997/12/19  17:11:02  pinnacle
# setupForm
#
# Revision 1.2  1997/12/18  08:21:22  pinnacle
# Replaced: vddrawing/imp/VDdrwFunc.I for: CR 179603526 by smpathak for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/08/07  23:02:28  pinnacle
# Replaced: vddrawing/imp/VDdrwFunc.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/24  22:23:12  pinnacle
# Created: vddrawing/imp/VDdrwFunc.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY  AUTHOR  DESCRIPTION
 *	12/19/97  ah      Deleted extern from setup_Name
 *			  Added VD to some commands
 *	01/15/98  ah      Changed setup_Name to VDdraw_setup_Name
 *	01/29/98  ah      Got rid of global VDdraw_setup_Name,
 *                        Made it static and added get/set routines
 *                        Kept crashing when accessed from struct.
 *			  Also created vddrwproto.h for prototypes.
 * -------------------------------------------------------------------*/

/*
 * DESCIPTION
 *	Service functions moved from vddrawing/cmd 
 *	
 * HISTORY:
 *	15/10/93	Copy of functions to be called in for creation for
 *			of the drawing macros.
 */

class implementation Root;

#include <stdio.h>
#include <ctype.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"

#include "msmacros.h"
#include "ASmessages.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "ACdb_info.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "go.h"
#include "ACcheckin.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "AS_status.h"
#include "VDmsg.h"
#include "FI.h"
#include "OMprimitives.h"
#include "griodef.h"
#include "griomacros.h"

#include "vddrwproto.h"

#define PREDEFINED_FEET 4
#define PREDEF0 "macro"
#define PREDEF1 "occurence"
#define PREDEF2 "design"
#define PREDEF3 "quantity"

from   NDnode  import   NDgive_structure;

extern  char * calloc();
extern  char * realloc();

static IGRchar g_VDdrwSetupFileName[128];

IGRint VDdrwSetSetupFileName(IGRchar *setupName)
{
  strcpy(g_VDdrwSetupFileName,setupName);
  return 1;
}

IGRint VDdrwGetSetupFileName(IGRchar *setupName)
{
  strcpy(setupName,g_VDdrwSetupFileName);
  return 1;
}

IGRint VDinit_from_drawing_setup()
{
  // printf("Entered VDinit_from_drawing_setup\n");
  return FALSE;
}

IGRint VDread_from_drawing_setup(
  IGRchar  *drawing_macro_name,
  IGRchar  *model_macro_name,
  IGRchar **feet_names,
  IGRint   *nb_feet,
  IGRint    max_feet
)
{

  IGRchar  *dummy_name;
  IGRchar **dum_name;

  IGRint   *dummy_feet; 
  IGRint    dum_feet;

  // printf("Entered VDread_from_drawing_setup\n");

  dummy_name = drawing_macro_name ;
  dummy_name = model_macro_name ;
  dum_name   = feet_names ;
  dummy_feet = nb_feet ;
  dum_feet   = max_feet ;
 
  return EOF;
}

#argsused
IGRint VDread_from_DrawingTable(
  FILE     *input_file,
  IGRchar  *drawing_macro_name,
  IGRchar  *model_macro_name,
  IGRchar **feet_names,
  IGRint   *nb_feet,
  IGRint    max_feet
)
{

 char input[180];

   /* Read names of drawing macro and model macro
      -2 is because ci_mac_def.ACplace only accept ci_macro with
      name= macro_MAX_CHAR-1
   */

   if(fscanf(input_file,"%s",input) == EOF) return EOF;

   strncpy(drawing_macro_name,input,macro_MAX_CHAR-1);
   drawing_macro_name[macro_MAX_CHAR-2] = '\0';

   fscanf(input_file,"%s",input);
   if(strcmp(input,"of") != 0) goto error;

   fscanf(input_file,"%s",input);
   strncpy(model_macro_name,input,macro_MAX_CHAR);
   model_macro_name[macro_MAX_CHAR-1] = '\0';

   /* loop to get feet name, name given in part list, type */

   fscanf(input_file,"%s",input);
   if(strcmp(input,"{") != 0) goto error;

   *nb_feet = 0;
   while(1)
   {
    if(fscanf(input_file,"%s",input) == EOF) goto error;
    if(strcmp(input,"}") == 0) break;
    strncpy(feet_names[*nb_feet],input,macro_MAX_CHAR);
    (feet_names[*nb_feet])[macro_MAX_CHAR-1] = '\0';
    if(fscanf(input_file,"%s",input) == EOF) goto error;
    if(input[0] == 'u'|| input[0] == 'U') continue; /* ignore user attributes */
    (*nb_feet)++;
   }
  return 1;

 error :
   sprintf(input,"error in the drawing macro %s\n",drawing_macro_name);
   UI_status(input);
   return EOF;

}

/*

   That's just to maintain old stuff, when drawing information was not in
   the drawing extraction langage
*/

IGRint VDinit_from_DrawingTable(FILE **input_file)
{
 char input[200],full_name[200];
 long status;
 int i;

 /* Try to open the file in the current directory */

 *input_file = (FILE *) fopen("DrawingTable","r");

 /* Search in config directories */

 if(!*input_file)
  {
   for(i=0;i<30;i=i+1)
   {
    status = ex$get_path(index = i,
                         path = input,
                         len = 180,
                         type = EX_CONFIG_PATH);
    if(!(status&1)) break;
    sprintf(full_name,"%s/config/DrawingTable",input);
    *input_file = (FILE *) fopen(full_name,"r");
    if (*input_file) break;
    sprintf(full_name,"%s/config/drawing_macro",input); /* old shit */
    *input_file = (FILE *) fopen(full_name,"r");
    if (*input_file) break;
   }
  }
 return OM_S_SUCCESS;
}

/* Get the key that identifies the design file in the data base */
IGRint VDget_design_name( 
  GRspacenum       osnum, 
  IGRchar         *design_key, 
  struct GRmd_env *md_env
)
{
#define EXPRESSION_NAME "IGENOD:VDmodel_key"
static  GRspacenum memosnum = 0;
struct  ret_struct rst;
long    status,msg;
char    *c,*strrchr();
char    design_name[256];
char    input[256];
OM_S_OBJID exp;

  /*
   * Try to find PDM/PDU identifier
   */
  status = di$translate(objname = EXPRESSION_NAME,
                        osnum = osnum,
                        p_objid = &exp);

  if(status&1){
    status =
    om$send(msg      = message NDnode.NDgive_structure(&msg,&rst,md_env),
            senderid = NULL_OBJID,
            targetid = exp,
            targetos = osnum);
    if((status&1) && rst.type == text_type){

      strcpy(design_key,rst.var.text_st.text_string);
    }
    else status = OM_W_ABORT;
  }

  /*
   * If not found take the filename and tell the user
   */

  if(!(status&1)){

    status = di$give_pathname (osnum = osnum, pathname = design_name );
    c = strrchr(design_name,':');
    if(c) c++;
    else c = design_name;
    strcpy(design_key,c);
    if(osnum != memosnum){
      memosnum = osnum;
      sprintf(input,"Warning, model %s has not been checked in.\n",design_key );
      UI_status(input);
    }
  }
  return( TRUE );
}


IGRint VDadd_predef_feet(
  IGRint   *nb_feet,
  IGRchar **feet_names
)
{
/*
 * add predefined strings to the feet_names in the
 * feet_names list
 */
  strcpy(feet_names[(*nb_feet)++],PREDEF0);
  strcpy(feet_names[(*nb_feet)++],PREDEF1);
  strcpy(feet_names[(*nb_feet)++],PREDEF2);
  strcpy(feet_names[(*nb_feet)++],PREDEF3);
  strcpy(feet_names[(*nb_feet)++],"geom");

  return( TRUE );
}


IGRint VDinit_feet_name( 
  IGRchar  *ftname, 
  IGRchar **feet_names, 
  IGRint    nb
)
{
/*
 * Initialization of the feet_name list
 */
int i;
  for( i=0; i<nb; i++) {
    sprintf(ftname,"$%d",i);
    feet_names[i] = ftname;
    ftname += macro_MAX_CHAR;
  }
  return( TRUE );
}

end implementation Root;
