/* #######################    APOGEE COMPILED   ######################## */

#include   "coimport.h"
#include   "codebug.h"
#include   "OMminimum.h"
#include   "OMprimitives.h"
#include   "OMerrordef.h"
#include   "igrtypedef.h"
#include   "igetypedef.h"
#include   "msdef.h"
#include   "msmacros.h"
#include   "godef.h"
#include   "gr.h"
#include   "igr.h"
#include   "igrdp.h"
#include   "ex.h"
#include   "exdef.h"
#include   "exmacros.h"
#include   "go.h"
#include   "griodef.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "igrmacros.h"
#include   "grmessage.h"
#include   "DIdef.h"
#include   "DItypedef.h"
#include   "DIprims.h"
#include   "DIglob.h"

extern IGRint GR_G_dir_mode;

/*
 *  append input to usr directory of OS directory if mode is 1 ( USER )
 *
 *  example  path1 = ":hello"
 *           path2 = ":<dgn>:usr:hello"
 */
#argsused
CO_xlate_from_user_mode ( mode, path1, path2 )
    IGRint   mode;
    IGRchar *path1;
    IGRchar *path2;

{
    DIint      status;
    DIchar     copy[DI_PATH_MAX];

    status = DIstrcpy ( copy, path1 );
    status = DIstrcpy ( path2, copy );

    return ( status );
}

/*
 *  truncate usr directory name from input if mode is 1 ( USER )
 *
 *  example  path1 = ":<dgn>:usr:hello"
 *           path2 = ":hello"
 */
#argsused
CO_xlate_to_user_mode ( mode, path1, path2 )
    IGRint   mode;
    IGRchar *path1;
    IGRchar *path2;

{
    DIint      status;
    DIchar     copy    [DI_PATH_MAX];

    status = DIstrcpy ( copy, path1 );
    status = DIstrcpy ( path2, copy );
    return ( status );
}
