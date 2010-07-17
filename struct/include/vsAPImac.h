/*	
	I/STRUCT 
*/

#ifndef vsAPImac_include
#	define vsAPImac_include

#ifndef acrepdef_include
#	include "acrepdef.h"
#endif

#ifndef vsplatedef_include
#	include "vsplatedef.h"
#endif

#ifndef vsbeamdef_include
#	include "vsbeamdef.h"
#endif

#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

#ifndef vs_include
#	include "vs.h"
#endif

/*+M
Macro vs$return_gr_copy

Abstract
        Return the graphical caopy of the structural element.
Arguments
        OUT     long                    *msg            Completion code.
        IN      struct GRmd_env         *strEnv         Structure enviroment
        IN      struct GRid             strElement      Structural element
        OUT     struct GRid             *solidRep       copy in AC_3D_REP
-M*/
extern long
VSreturn_gr_copy        __((     IGRlong                *msg ,
                                 struct GRmd_env        *strEnv ,
                                 struct GRid            strElement,
                                 struct GRid            *solidRep  ));

#omdef vs$return_gr_copy( msg, strEnv, strElement, solidRep )
        VSreturn_gr_copy( (msg), (strEnv), (strElement), (solidRep ) )
#endomdef

#endif /* vsAPImacros_include */

