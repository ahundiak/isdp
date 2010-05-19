/* $Id: COm_plName.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/COm_plName.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: COm_plName.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  20:10:38  pinnacle
# Fixed Warnings
#
# Revision 1.1  1997/10/29  22:47:16  pinnacle
# TR179701965 Macro Naming
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 *      10/29/97  ah      TR179701965 Macros not getting named properly
 *         when placed in directory other than current directory
 *         problem with di$translate, need to cd first
 *         
 ***************************************************************************/

class implementation COm_place;

#include "OMmacros.h"
#include "coparadef.h"
#include "coparamac.h"
#include "ci.h"
#include "ciexecmacros.h"
#define  PATH_MAX 256
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "asdef.h"
#include "asmacros.h"
#include "FI.h"
#include "nd.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "asbox.h"
#include "dpmacros.h"
#include "ACrg_collect.h"

#include "lcdef.h"
#include "lcmacros.h"

#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"

/* -----------------------------------
 * Modify
 */

method generate_hdr_name()
{
  IGRlong status,msg;
  char    *c,*c1,*strrchr();
  int     i;
  struct  GRid Object_GRid;
  char    tmp_name[PATH_MAX];
  short   dummy_level;
  struct  IGRdisplay dummy_display;
 
  IGRchar pwdPath[DI_PATH_MAX];
  IGRchar usrPath[DI_PATH_MAX];
  struct  GRid dirID;

  // Get rid of warning
  if (SCI_fileid);

  /*| Automatic name generation for occurences */
  if(me->hdr_name[0] == '\0') return OM_S_SUCCESS;

  status = om$send(
    msg = message COm_place.get_active_symb(
      &dummy_level,
      &dummy_display,
       tmp_name
    ),
    targetid = my_id
  );
  if(!(status&1)) tmp_name[0] = '\0';
  sprintf(tmp_name,"%s:%s",tmp_name,me->hdr_name);

  /* TR179701965 */
  /* Need to cd to usr directory to ensure di$translate working properly */
  /* Might be better to just cd into target directory then look for name */

  ex$get_cur_mod  (osnum = &dirID.osnum);
  di$give_pathname(osnum =  dirID.osnum, pathname = usrPath);
  di$strcat(to= usrPath,from = "usr");

  *pwdPath = 0;
  di$pwd(dirname = pwdPath);
  di$cd (dirname = usrPath);

  // Already have name?
  msg = di$translate(
    objname = tmp_name,
    p_objid = &Object_GRid.objid,
    p_osnum = &Object_GRid.osnum
  );

  if( msg == DIR_S_SUCCESS) {

    /* if the name is name_##, find pointer to the suffix */ 

    c = strrchr(tmp_name,'_');

    if(c != NULL) {
      i = strtol(c+1,&c1,10);
      if(*c1 != '\0') c = NULL;
    }

    if(c == NULL) c = tmp_name + strlen(tmp_name);

    /* find correct suffix */

    for(i=0;i<1000;i++) {

      if(i<100) sprintf(c,"_%02d",i);
      else      sprintf(c,"_%03d",i);

      /*" hdr_name %s\n",me->hdr_name*/
      msg = di$translate(
        objname = tmp_name,
        p_objid = &Object_GRid.objid,
        p_osnum = &Object_GRid.osnum 
      );
      if( msg != DIR_S_SUCCESS) break;
    }

    /* generate name + suffix */
    if(i>=1000) me->hdr_name[0] = '\0';
    else  { 
      c = strrchr(tmp_name,':');
      if(c == NULL) c = tmp_name;
      else c++;
      strcpy(me->hdr_name,c);
    }
  }

  /* Write the name on the form */

  if(me->form_names_ptr) {
    COm_display_names(me->form_names_ptr,me->hdr_name, me->temp_name);
  }

  if (*pwdPath) {
    di$cd(dirname = pwdPath);
  }

  return OM_S_SUCCESS;
}

end implementation COm_place;
