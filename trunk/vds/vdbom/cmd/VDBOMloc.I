/* $Id: VDBOMloc.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdbom/cmd / VDBOMloc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDBOMloc.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1994/12/12  20:47:42  pinnacle
# Replaced:  vdbom/cmd/*.[IS] r#
#
# Revision 1.2  1994/12/07  15:29:24  pinnacle
# Replaced:  vdbom/cmd r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/07/94        R. Manem        OPE enhancements :
 *                                      - store_tblName method (new)
 *	12/12/94	R. Manem	- Modify BOM support : validation of
 *					  number of objects for assoc BOM
 *
 * -------------------------------------------------------------------*/



class implementation VDCmdBOM;

#include "OMprimitives.h"
#include "OMmacros.h"
#include "string.h"
#include "vdparmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "exproto.h"
#include "VDCmdDef.h"
#include "VDbom.h"
#include "coparamac.h"
#include "coparadef.h"
#include "csmacros.h"
#include "bstypes.h"
#include "madef.h"
#include "maidmx.h"
#include "VDSFilter.h"
#include "FI.h"
#include "FEI.h"

/*
#define DEBUG
*/

#define MAXROWSIZE         64
#define DEF_COL_LENGTH     15

from ACcpx           import find_macro;
from ACcpx_defn      import ACgive_name;
from ACrg_collect    import ACget_named_attribute;

method store_bom( long *sts )
{
     IGRchar        *macroName = NULL;
     struct GRid    macro_def;
     long    status = OM_S_SUCCESS;

     *sts = VD_SUCCESS;

     /* store the id of the located object */

     me->bomGrid.obj_id  = me->event1.located_object[0].located_obj ;
     me->bomGrid.mod_env = me->event1.located_object[0].module_info ;

#ifdef DEBUG
     printf("\nbom grid = <%d, %d>\n", me->bomGrid.obj_id.osnum,
                                       me->bomGrid.obj_id.objid );
#endif

     if( me->bomGrid.obj_id.osnum != 2 )
     {
          UI_status( "Object must be in active design file" );
          *sts = VD_RESTART_CMD;
          goto wrapup;
     }

     /* get the macro definition */

     status = om$send( msg      = message ACcpx.find_macro( &macro_def ),
                       targetid = me->bomGrid.obj_id.objid,
                       targetos = me->bomGrid.obj_id.osnum );
     as$status();

     if( !(status & 1) )
     {
          *sts = VD_RESTART_CMD;
          goto wrapup;
     }

#ifdef DEBUG
     printf("\nMacro defn id  = <%d, %d>\n", macro_def.objid, macro_def.osnum );
#endif

     /* get the name of the macro */

     status = om$send( msg      = message ACcpx_defn.ACgive_name( &macroName ),
                       targetid = macro_def.objid,
                       targetos = macro_def.osnum );
     as$status();

     if( !(status & 1) )
     {
          *sts = VD_RESTART_CMD;
          goto wrapup;
     }

#ifdef DEBUG
     printf("\nMacroName = %s\n", macroName );
#endif

     /* 
      * if macro name is not bom, then bom table has not been located 
      * Restart command
      */

     if( strcmp( macroName, "bom" ) )
     {
          *sts = VD_RESTART_CMD;
          goto wrapup;
     }

wrapup :

     if( !macroName )
          free( macroName );

     return OM_S_SUCCESS;
}


method store_tblName( long *sts )
{
     IGRint  len = 0;
     long    status = OM_S_SUCCESS;

     *sts = VD_SUCCESS;

     len = strlen( me->event1.event.keyin ) + 1;

     if( len == 1 )
     {
          *sts = VD_RESTART_CMD;
          goto quit;
     }

     status = om$vla_set_dimension( varray = me->tblName, size = len );
     as$status();

     if( status == OM_E_NODYNMEM )
     {
          *sts = VD_ERROR;
          goto quit;
     }

     strcpy( me->tblName, me->event1.event.keyin );

#ifdef DEBUG
     printf("\nTable name = %s\n", me->tblName );
#endif

quit :
     return OM_S_SUCCESS;
}



method store_cs( long *sts )
{

     *sts = VD_SUCCESS;

     me->csGrid.obj_id  = me->event1.located_object[0].located_obj ;
     me->csGrid.mod_env = me->event1.located_object[0].module_info ;

     me->window         = me->event1.event.button;

     return OM_S_SUCCESS;
}


method store_window( long *sts )
{

     *sts = VD_SUCCESS;

     me->window         = me->event1.event.button;

     return OM_S_SUCCESS;
}
/*+me
 -------------------------------------------------------------------------
  Public Message process_locate

  Abstract
        Processes the located elements

  Arguments
        long    *sts           O       Completion code

  Status 
      status    OM_S_SUCCESS    if success
                OM_E_NODYNMEM   no dynamic memory
                OW_W_ABORT      some other error

  Return Code 
      sts       VD_SUCCESS      if success
                VD_RESTART_CMD  if command has to be restarted
                VD_ERROR        if error 

 -------------------------------------------------------------------------
-me*/

method process_locate( long *sts )
{

long              msg, 
                  status = OM_S_SUCCESS;
int               i, nbObjs; 
struct GRobj_env  *lObjs = NULL;

     *sts = VD_SUCCESS;

     /* get the list of located objects */

     status = 
     as$start_fence( set = &me->event1.located_object[0].located_obj,
                     set_env = &me->event1.located_object[0].module_info,
                     nb_obj           = &nbObjs,
                     p_obj_env        = &lObjs,
                     response         = me->response,
                     response_data    = me->response_data);

#ifdef DEBUG
   printf("\nProcess_locate :\n   lObj : %d, %d\n", lObjs[0].obj_id.objid,
                                                    lObjs[0].obj_id.osnum );
   printf("\n  Module env : md_id = %d, %d\n", lObjs[0].mod_env.md_id.objid,
                                               lObjs[0].mod_env.md_id.osnum );
#endif

     if( !(status & 1) )
     {
          *sts = VD_ERROR;
          goto quit;
     }

#ifdef DEBUG
     printf("\nNo of objects returned = %d\n", nbObjs);
#endif

     /* allocate memory for located objects  and store the objects */

     if( !nbObjs )
     {
          *sts = VD_RESTART_CMD;
          goto quit;
     }

     if( me->mytype == CREATE )
     {
          status = om$vla_set_dimension( varray = me->locObjs,
                                         size   = nbObjs );
          if( !(status & 1) )
          {
               printf("\nError : dynamic allocation\n");
               *sts = VD_ERROR;
               goto quit;
          }
               
          for( i = 0 ; i < nbObjs ; i++ )
               me->locObjs[i] = lObjs[i];
     
          me->nbLocObjs = nbObjs;
     }
     else if( me->mytype == MODIFY )
     {
          for( i = 0 ; i < nbObjs ; i++ )
          {
               status = om$send( msg = message VDS_LOCATE.addLocatedObject( 
                                               &msg,
                                               &lObjs[i].obj_id,
                                               &lObjs[i].mod_env,
                                               OM_K_MAXINT ),
                                 targetid = my_id );

               if( msg == OM_S_SUCCESS )
                    me->nbLocObjs++;
               else if( msg == OM_E_ABORT )
               {
                    *sts = VD_ERROR;
                    goto quit;
               }
          }

          /* validate associativity option of objects */

          if( me->assocOption && me->nbLocObjs > MAX_OBJECTS )
          {
              UI_status( "Warning : Changing to non-associative BOM" );
              me->assocOption = 0;
          }

     }

quit :
     ASend_fence();
     return OM_S_SUCCESS;
}

end implementation VDCmdBOM;
