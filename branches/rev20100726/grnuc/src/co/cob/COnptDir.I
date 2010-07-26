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
#include "grsymmacros.h"
#include "maerr.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include <stdio.h>

/* COnptDir.I - directory stuff */
/*
  get_first_name 
  mvdir 
  create_directory 
  add_object_to_directory 
  start_dir 
  graphic_cd
 */

method get_first_name ( long * sts )
{
  int status = OM_S_SUCCESS;

  extern DIint GR_G_dir_mode;

  if (me->first_event.response == STRING )
  {
    DIchar tmp [DI_PATH_MAX];

    *sts = MSSUCC;

    if (GR_G_dir_mode)
    {
      DIstrcpy ( tmp, me->first_event.event.keyin );
      CO_xlate_from_user_mode ( 1, tmp, me->first_event.event.keyin );
    }
  }
  else
  {
    IGRlong              NumberObjectsFound;
    OM_S_OBJECT_LINKAGE  ChannelLinkage[1];/* linkage to objects on channel */

    status = lc$get_channel_objects ( objid = my_id,
                                      p_chanselect = &me->located_chansel,
                                      list = ChannelLinkage,
                                      size = 1,
                                      count = &NumberObjectsFound );

    if (NumberObjectsFound != 1)
      *sts = 2;
    else
    {
      DIchar old_name [DI_PATH_MAX];

      _m_checkq( status );

      /*|find the name of this guy */
      if (di$untranslate ( osnum = ChannelLinkage[0].osnum,
                           objid = ChannelLinkage[0].S_objid,
                           objname = old_name ) != DIR_S_SUCCESS)
        *sts = DIR_W_NAME_NOT_FOUND;
      else
       if (!DIancestry_valid ( ChannelLinkage[0].osnum,
                               ChannelLinkage[0].S_objid, DIR_G_IGRdir_clid ))
         di$split ( pathname = old_name, dirname = old_name );
   
      me->first_event.response = STRING;
      strcpy ( me->first_event.event.keyin, old_name );

      {
        DIchar tmp [DI_PATH_MAX];

        if (GR_G_dir_mode)
          CO_xlate_to_user_mode ( 1, old_name, tmp );
        else
          DIstrcpy ( tmp, old_name );

        ex$message ( field         = ERROR_FIELD,
                     msgnumb       = GR_S_OLD_NAME, 
                     justification = LEFT_JUS,  
                     type          = "%s",
                     var           = tmp );
      }
    }
  }
quit:
  return OM_S_SUCCESS;
}

method mvdir ( long * sts )
{
  DIchar old_name [DI_PATH_MAX], new_name [DI_PATH_MAX];
  struct GRid grid;
  extern DIint GR_G_dir_mode;

  DIstrcpy ( old_name, me->first_event.event.keyin );
  
  if (GR_G_dir_mode)
  {
    CO_xlate_from_user_mode ( 1, me->second_event.event.keyin, new_name );
  }
  else
  {
    DIstrcpy ( new_name, me->second_event.event.keyin );
  }

  /*|test the class : must be directory */
  *sts = di$translate ( objname = old_name,
                        p_objid = &grid.objid, p_osnum = &grid.osnum );
  if (*sts == DIR_S_SUCCESS)
  {
    if (!DIancestry_valid ( grid.osnum, grid.objid, DIR_G_IGRdir_clid ))
    {
      *sts = DIR_E_INVARG;
    }
    else
    {
      *sts = DIR_S_SUCCESS;
    }
  }

  if (*sts == DIR_S_SUCCESS)
  {
    *sts = di$rename ( oldname = old_name, newname = new_name );
  }

  return OM_S_SUCCESS;
}

method create_directory ( long *sts; IGRchar *dirname )
{
  int status = OM_S_SUCCESS;

  struct GRid  ModuleGrid;

  /*
   *  get the active module
   */
  status = ex$get_cur_mod( id    = &ModuleGrid.objid,
                           osnum = &ModuleGrid.osnum );

  status = di$mkdir ( dirname = dirname, osnum = ModuleGrid.osnum );
  
  return OM_S_SUCCESS;
}

method add_object_to_directory ( long *sts; OM_S_CHANSELECT *p_chansel )
{
  int status = OM_S_SUCCESS;

  OM_S_OBJECT_LINKAGE        chan_linkage[1];
  IGRlong                    num_objects_found;
  IGRlong                    msg;
  IGRint                     object_index;
  IGRchar                    dirname [280];
  struct GRid                add_object;
  extern DIint               DIadd_index();  /* these are used by the three */
  extern DIint               DIrm_index();   /* macros when they expand     */
  extern DIint               DIunindex();


  status = lc$get_channel_objects(objid = my_id,
                                  osnum = OM_Gw_current_OS,
                                  p_chanselect = p_chansel,
                                  list = chan_linkage,
                                  size = 1,
                                  count = &num_objects_found );

  add_object.objid = chan_linkage[0].S_objid;              
  add_object.osnum = chan_linkage[0].osnum;

  /* display object, on top of everything else */

  dp$display (msg = &msg,
              mode = GRbd,
              oids = &add_object);

  /* build directory name */

  DIstmocpy ( dirname, "display_list", 0, add_object.osnum);

  /* get index of the object in directory (if it is in the directory) */

  status = di$unindex (dirname = dirname,
                        p_index = &object_index,
                        objid = add_object.objid);

  /* remove the object from the directory (if it is in the directory) */

  if (status  == OM_S_SUCCESS)
  {
     status = di$rm_index (dirname = dirname,
                           index = object_index);
  }

  /* add the object at the end of the directory */

  status = di$add_index (dirname = dirname,
                          objid = add_object.objid);
  return OM_S_SUCCESS;
}

method start_dir ( long * sts )
{
  DIspacenum mod_osnum;
  DIobjid    mod_id,
             super_id;
  DIchar     base[DI_PATH_MAX];

  ex$get_cur_mod ( id = &mod_id, osnum = &mod_osnum );
  ex$get_super ( create      = 1,
                 mod_id      = mod_id,
                 mod_osnum   = mod_osnum,
                 super_id    = &super_id,
                 super_name  = "super_dir",
                 super_class = "super_dir" );

  /*
   * KLUDGE -- unitl 2.0 we use a directory to indicate that a unit is
   *           "scalable"; remove the three lines of code below for 2.0
   *           release!!!
   */
  di$give_pathname( osnum = mod_osnum, pathname = base );    
  di$strcat( to = base, from = "scalable:UOM_DISTANCE:");
  di$mkpath( pathname = base );

  return OM_S_SUCCESS;
}

method graphic_cd ( long * sts )
{
  int status = OM_S_SUCCESS;

  *sts = MSSUCC;

  status = di$untranslate(
              osnum = me->first_event.located_object[0].located_obj.osnum,
              objid = me->first_event.located_object[0].located_obj.objid,
              objname = me->first_event.event.keyin );

  if ( status != DIR_S_SUCCESS )
  {
     *sts = DIR_W_NAME_NOT_FOUND;
  }
  else
  {
    di$split ( pathname = me->first_event.event.keyin,
               dirname = me->seventh_event.event.keyin );

    di$cvt_name_for_output ( s_path = me->first_event.event.keyin );

    di$cvt_name_for_output ( s_path = me->seventh_event.event.keyin );
  }
  return OM_S_SUCCESS;
}


end implementation COnpt;
