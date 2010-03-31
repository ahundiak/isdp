/*
  DESCRIPTION

    This function is use to generate default names for various objects
    in the system.

  HISTORY

    SS  :  03/15/91  :  Creation
*/

class implementation EMSapb;

#include "exdef.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EMSasnucdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"

#include "actparam.h"

#define FIRST_CHAR  0
#define SECOND_CHAR 1

static IGRboolean aflag;
static GRspacenum osn;


IGRboolean EMdefnewname ( objname, os, type )
char       *objname;
GRspacenum os;
int        type;
{
  IGRboolean found;
  int        tryinx, index;
  long       stat_func, stat_gen;
  GRobjid    apbid, dumid;
  char       CurrentDirectory [DI_PATH_MAX];
  GRspacenum osnum, ModuleOs;

  stat_func = TRUE;

  /*
   * If reference file activation is on, then the current directory
   * must be the 'usr' of the activated os.  Satish
   */
 aflag = pwIsActivationOn();
 if (aflag)
 {
    osn = pwGetActiveOs();

    stat_gen = di$give_pathname ( pathname = CurrentDirectory, osnum =osn);
    EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );
    stat_gen = di$cd ( dirname = CurrentDirectory );
    EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );
    stat_gen = di$cd ( dirname = "usr" );
    EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );
 }
 else
 {

  /*
   * The current directory must be in the master file
   */
  stat_gen = di$pwd ( dirname = CurrentDirectory );
  EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );

  stat_gen = di$give_osnum ( pathname = CurrentDirectory, p_osnum = &osnum );
  EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );

  stat_gen = ex$get_cur_mod ( osnum = &ModuleOs );
  EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );
  
  if (osnum != ModuleOs)
  {
    /*
     * We must cd to the usr directory of the master
     */
    stat_gen = di$give_pathname ( pathname = CurrentDirectory, osnum = ModuleOs );
    EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );
    stat_gen = di$cd ( dirname = CurrentDirectory );
    EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );
    stat_gen = di$cd ( dirname = "usr" );
    EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );
  }
 }

  stat_gen = EMgetapbid ( &os, &apbid, &os );
  EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );

  found = FALSE;
  for (tryinx = 0; tryinx < 1000; tryinx++)
  {
    stat_gen = om$send (msg = message EMSapb.EMgetrunindex ( type, &index ),
        targetid = apbid, targetos = os, senderid = NULL_OBJID );
    EMerr_hndlr ( EMSerror (stat_gen), stat_func, FALSE, ret_end );

    if (type == EMSdistance)
      objname[FIRST_CHAR] = 'd';
    else 
      if (type == EMSangle)
        objname[FIRST_CHAR] = 'a';
      else 
        if (type == EMSscalar)
          objname[FIRST_CHAR] = 'x';
        else 
          if (type == EMSpoint)
            objname[FIRST_CHAR] = 'p';
          else 
            if (type == EMSvector)
              objname[FIRST_CHAR] = 'l';
            else 
              if (type == EMSinfplane)
                objname[FIRST_CHAR] = 'p';
              else 
                if (type == EMSraddist)
                  objname[FIRST_CHAR] = 'r';
                else
                  objname[FIRST_CHAR] = 'g';

    sprintf ( &objname [SECOND_CHAR], "%d", index );
    stat_gen = di$translate ( objname = objname, p_objid = &dumid );
    if (stat_gen != DIR_S_SUCCESS)
    {
      found = TRUE;
      break;
    }
  }

  if (!found)
    stat_func = FALSE;

ret_end:
  return stat_func;
}



end implementation EMSapb;
