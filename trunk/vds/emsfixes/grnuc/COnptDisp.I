/* $Id: COnptDisp.I,v 1.2 2001/09/11 21:10:42 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc/COnptDisp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/26/01        Jayadev         TR#MP5413 - hilite unconditionally
 *
 * -------------------------------------------------------------------*/

class implementation COnpt;



#include "coimport.h"
#include "codebug.h"
#include "grerr.h"
#include "grmessage.h"
#include "codef.h"
#include "godef.h"
#include "msdef.h"
#include "madef.h"
#include "dpdef.h"
#include "griodef.h"
#include "grio.h"
#include "comisc.h"
#include "comiscmac.h"
#include "coniarray.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "msmacros.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "igrmacros.h"
#include "lcmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "growner.h"
#include "grsymmacros.h"
#include "maerr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include <stdio.h>

extern IGRlong VDatGetConsumingChild();

/* COnpt2.I - display stuff */
/*
 erase_hilite 
 display_first_located_object 
 display_second_located_object 
 display_cs_type 
 hilite_element 
 display_cdpath 
 display_active_parms 
 const_dynamics 
 */


from GRgraphics import   GRdisplay;


method const_dynamics ( long *sts; int dyn_index )
{
  

  struct GRevent *events[NUMBER_OF_EVENTS];

  *sts = MSSUCC;

  /*  KLUDGE - handle negative index - set to absolute value */
  dyn_index = ( dyn_index < 0 ) ? ( - dyn_index ) : ( dyn_index );

  /*
   *  make sure that the function index is in the range allowable,
   *  make sure that there is that many functions, and that the
   *  index is greater than zero
   */
  if ( !CO_ni_index_in_range( dyn_index ) )
  {
    return( OM_S_SUCCESS);
  }
  if ( !CO_ni_index_in_range( me->mytype ) )
  {
    return( OM_S_SUCCESS);
  }


  /*
   *  set up the array of events so that the function that we
   *  called will know all the data points an values that the user
   *  has entered.
   */
  set_up_event_array;

  if ( queue_empty && vsd_empty )
  {
    ex$message( in_buff       = me->prompt,
                field         = PROMPT_FIELD,
                justification = RIGHT_JUS );
  }

  /*
   *  now, call the object dynamics routine.
   */
  CO_GA_ni_funcs[ dyn_index ]( me->mytype,
                               events,
                              &me->ModuleInfo,
                               my_id,
                               OM_Gw_current_OS,
                              &me->const_chansel,
                               NULL );

  return OM_S_SUCCESS;
}


method erase_hilite ( long * sts )
{
  *sts = MSSUCC;

  /*
   *  erase the hilite plane
   */
  dp$erase_hilite( msg = sts );

  return OM_S_SUCCESS;
}


method display_first_located_object ( long * sts )
{
  int status;

  struct GRid         ModuleGrid;
  OM_S_CHANSELECT     MyChannelStruct;

  /*
   *  initialize the channel structure
   */
  status = om$make_chanselect(chanaddr     = &me->ToFirstLocated,
                              p_chanselect = &MyChannelStruct );

  /*
   *  get the active module
   */
  status = ex$get_cur_mod(id    = &ModuleGrid.objid,
                          osnum = &ModuleGrid.osnum );

  status = om$send(msg = message GRgraphics.GRdisplay(
                           (IGRlong *)sts,
                           &me->FirstContext.md_env.matrix_type,
                            me->FirstContext.md_env.matrix,
                           &me->DisplayMode,
                           &ModuleGrid ),
                   p_chanselect = &MyChannelStruct );

  *sts = MSSUCC;
  return OM_S_SUCCESS;
}

method display_second_located_object ( long * sts )
{
  int status = OM_S_SUCCESS;

  struct GRid          ModuleGrid;
  OM_S_CHANSELECT      MyChannelStruct;

  /*
   *  initialize the channel structure
   */
  status = om$make_chanselect(chanaddr     = &me->ToSecondLocated,
                              p_chanselect = &MyChannelStruct );

  /*
   *  get the active module
   */
  status = ex$get_cur_mod(id    = &ModuleGrid.objid,
                          osnum = &ModuleGrid.osnum );
  status = om$send(msg = message GRgraphics.GRdisplay(
                            (IGRlong *)sts,
                            &me->SecondContext.md_env.matrix_type,
                             me->SecondContext.md_env.matrix,
                            &me->DisplayMode,
                            &ModuleGrid ),
                   p_chanselect = &MyChannelStruct );

  *sts = MSSUCC;

  return OM_S_SUCCESS;
}

method display_cs_type ( long * sts )
{

  IGRchar cs_type[MAX_CS_TYPE];
  IGRint  bytes_ret,
          buff_size = MAX_CS_TYPE;

  /*  
   *   retrieve the value of cs type from dpb
   */

  /* buffer for get_cs_type -  IGRchar[MAX_CS_TYPE]         */

  gr$get_cs_type ( msg    =  sts,
                   sizbuf = &buff_size,
                   buffer =  cs_type,
                   nret   = &bytes_ret );

  /*
   *   display the value of cs type in status field
   */

  ex$message ( field   = ERROR_FIELD,
               msgnumb = GR_I_ActCSTyp,
               justification = LEFT_JUS,  
               type    = "%s",
               var     = cs_type );

  return OM_S_SUCCESS;
}


method display_cdpath ( long * sts )
{
  /*
   *  display CDPATH in status field
   */
  ex$message ( field   = ERROR_FIELD,
               msgnumb = GR_S_Cdpath,
               type    = "%s",
               var     = DIR_G_cdpath);

  return OM_S_SUCCESS;
}

method hilite_element ( long * sts )
{
  /*
   * Highlight note - this only appears to be called from hilite.t - a
   * corresponding dehilite_element needs to be written in order to use
   * GRnhd from here.
   */
  long             msg;
  int              i, count, counter;
  char             reg[DI_PATH_MAX];
  DIgrid           grid;
  struct GRmd_env  mdEnv;
  struct GRobj_env chdEnv,objEnv;

  count   = 0;
  counter = 0;

  di$cvt_name_from_input ( u_path = me->first_event.event.keyin, s_path = reg );

  *sts = di$start_dump ( regexp = reg, ptr = &count );

  if ( *sts == DIR_S_SUCCESS )

  /*
   * Changed the hilite mode from GRhd -> GRhdo for
   * TR# MP5413 
   */
  gr$get_module_env( buffer = &mdEnv );
  for ( i=0; i<count; i++ )
  {
    *sts = di$fetch_dump ( p_grid = &grid, index = i );

    if (*sts == DIR_S_SUCCESS)
    {
      counter = ++counter;
      objEnv.obj_id.objid     = grid.objid;
      objEnv.obj_id.osnum     = grid.osnum;
      objEnv.mod_env          = mdEnv;
  
      /*
       * Get the last child in the chain with the name
       */
      VDatGetConsumingChild ( &objEnv, &chdEnv );
      *sts = dp$display ( msg  = &msg,
                          mode = GRhdo,
                          oids = &chdEnv.obj_id );
                          //oids = &grid );
    }
  }

  if (counter == 0)  
    *sts = DIR_E_INVARG;
  else
    *sts = DIR_S_SUCCESS;

  return OM_S_SUCCESS;
}

method display_active_parms ( IGRlong *sts; IGRlong mask )
{
  int status = OM_S_SUCCESS;

  IGRchar         string[MS_MAX_MSG_LENGTH];
  struct GRid     module_grid;

  *sts = MSSUCC;

  status = ex$get_cur_mod( id    = &module_grid.objid,
                           osnum = &module_grid.osnum );

  if( me->status_display_form_ptr != NULL )  mask = mask | CO_STATUS_FORM;

  status = CO_display_active_parms( sts,
                                   &module_grid,
                                    mask,
                                    string );

  /*
   *  if there was no error, put the formatted string
   *  into the status field
   */
  if ( !COERROR( status ) && !COERROR( *sts ) )
  {
     ex$message( field   = ERROR_FIELD,
                 in_buff = string );
  }
  else
  {
    ex$message( msgnumb = GR_E_ErrEnc,
                field   = ERROR_FIELD,
                justification = LEFT_JUS );
  }

  return OM_S_SUCCESS;
}


end implementation COnpt;

