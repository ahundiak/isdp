/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMSgraloop;

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS message codes    */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMFRT_UPTODATE       */
# endif

#include "emsmacros.h"
#include "emserr.h"

method EMreset( IGRlong           *EMmsg; 
                IGRushort  options )
/*
Abstract

    This method is used to reset the graphic loop status.

Options

    EMS_O_OUTOFDATE : This option indicates that the graphics
                      loop object is out of date with the current
                      boundaries. The graphics loop must be
                      calculated before any display can succeed.

    EMS_O_RETRIM    : This option indicates that the graphics
                      loop object is out of date with the current
                      boundaries, but that the graphics loop will not
                      be automatically calculated or displayed. 
                      Operations on the graphics loop (such as locate) 
                      will work on the old data until a update is
                      performed.

History
    24-APR-91  SCW  Genesis

*/

{
  IGRlong status;

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(options & EMS_GL_OUTOFDATE) me^^EMShelper.props &= ~EMGL_UPTODATE;
  if(options & EMS_GL_HOLD) me^^EMShelper.props &= ~EMGL_HOLD_UPDATE;
  
  return( status );
}

end implementation EMSgraloop;
