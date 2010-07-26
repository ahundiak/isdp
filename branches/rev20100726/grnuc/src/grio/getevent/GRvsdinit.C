/* #######################    APOGEE COMPILED   ######################## */
/*
    GRvsdinit() - function to allocate memory for the variable string 
                  descriptor structure and initialize its fields.
 */

#include "codebug.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igr.h"
#include "exdef.h"
#include "griodef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "msdef.h"
#include "igrmacros.h"
#include "griopriv.h"


extern struct GR_vsd  vsd;

IGRlong  GRvsdinit()
{
   _m_debug_str( "GRvsdinit no longer active" );
   _m_debug( _print_vsd_contents( vsd ) );

   return( MSSUCC );
}
