/*
Name
        LCget_info

Description
        This function will format a string based on information 
        retrieved from the object.  The string will presently hold the
        element type and layer number.  Since the information in  this
        string is volatile, the formatting of the string has been
        isolated to one function.

Notes
	This is called from the accept/reject routines, LCselect and
	LCpselect.

History
        rc      07/20/87    Started documentation
        mrm     04/03/91    added element name to output string
        mrm     09/20/91    changed mechanism for getting name from
                            di$untranslate to GRgraphics.GRgetname since
                            some applications do not store object names
                            in GRNUC directories
        scw     07/13/92    Ansi conversion
        mrm     12/22/93    Added osnum/objid when LocInfo is active
	sam     02/14/94    Added one instruction to LCalt_get_info() so
			    that dload works on SUN.
*/

class implementation Root;

#include "grimport.h"
#include "OMprimitives.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "grerr.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"

#define MAXSTRING 64                       /* keep output string reasonable */
#define LAYERLENGTH 14                     /* strlen(" - layer xxxx") + NULL */
#define TYPENAME (MAXSTRING - LAYERLENGTH) /* max for type/name string */

from GRgraphics import GRgetobjinfo, GRgetname;
from GRvg import GRgetsymb;

extern OMuword OPP_GRgrset_class_id;

#argsused
IGRint LCalt_get_info(OM_S_OBJID id, OMuword osnum, IGRchar *str)
{	
    id = NULL_OBJID;	/* Atleast one instruction for dload to work */
    return(FALSE);
}
    
IGRint LCget_info(OM_S_OBJID id, OMuword osnum, IGRchar *str)
{
    OMuword classid;
    IGRchar pathname[DI_PATH_MAX], name[DI_PATH_MAX], buf[DI_PATH_MAX];
    IGRlong sts, msg = MSSUCC;
    struct GRobj_info info;
    struct GRsymbology symb;

    *str = NULL;

    // check for an alternate locate string
    sts = LCalt_get_info(id, osnum, str);
    if (sts & 1) return(TRUE);

    // Check for a named locate which produces a set of located objects (e.g.
    // "line*"). The info is set to "" since that is what is done when a fence
    // is used.
    om$get_classid(objid = id, osnum = osnum, p_classid = &classid);
    if (om$is_ancestry_valid(superclassid = OPP_GRgrset_class_id,
                             subclassid = classid) == OM_S_SUCCESS)
    {
        str[0] = NULL;
        return(TRUE);
    }

    // get the object type
    sts = om$send(msg = message GRgraphics.GRgetobjinfo(&msg, &info), 
                  senderid = NULL_OBJID,
                  targetid = id,
                  targetos = osnum);
    if (sts & msg & 1)
        strcpy(str, info.type);
    else
        ex$message(msgnumb = GR_I_Unknown, buff = str);

    // get the object name
    sts = om$send(msg = message GRgraphics.GRgetname(&msg, pathname),
                  senderid = NULL_OBJID,
                  targetid = id,
                  targetos = osnum);

    if (sts & msg & 1)
    {
        // strip off the directory name
        sts = di$split(pathname = pathname, name = name);
              
        if ((sts & 1) && name[0] && (strlen(name) + strlen(str) < TYPENAME))
        {
            sprintf(buf, " - %s", name);
            strcat(str, buf);
        }
    }

    // get the object layer
    sts = om$send(msg = message GRvg.GRgetsymb(&msg, &symb),
                  senderid = NULL_OBJID,
                  targetid = id,
                  targetos = osnum);

    if ((sts & msg & 1) && (msg != GR_I_NO_LAYER))
    {
        sprintf(buf, " - layer %d", symb.level);
        strcat(str, buf);
    }

    // if any of the LocInfo stuff is active, display the osnum/objid as well
    if (GRGetLocateInfoFlags(NULL))
    {
        sprintf(buf, " - [%d, %d]", osnum, id);
        strcat(str, buf);
    }

    return (TRUE);
}

end implementation Root;
