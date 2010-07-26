/*
  ABSTRACT :
  --------

  This file contains the necessary entry points to boot the directory
  sub-system.
*/

class implementation DIrectory;

#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIprims.h"
#include "GRtypedef.h"
#include "GRdef.h"
#include "GRprims.h"
#include "DIdef.h"

#define DEBUG
#include "DIdebug.h"

#include "DIomac.h"

#define offset 1300357585
#define high   3355201852
#define low    1300357706

from DIlink   import set_target;

static DIchar mot [9];
static DIchar **ospaths	/* path name to the object space  */;

extern OMuword OM_Gw_maxOS;

void DIbuild_mot ()
/*
   This entry point is used to build the super user password.
*/
{
  DIint  l1, l2;

  l1 = high - offset;
  memcpy ( mot, (char *) &l1, sizeof ( GRint ) );
  l2 = low - offset;
  memcpy ( &(mot [sizeof ( GRint )]), (char *) &l2, sizeof ( GRint ) );
}

DIboot ()
/*
   This procedure initializes the directory sub-system.  It returns 
   DIR_S_SUCCESS if everything is ok.
*/
{
  DIint  status = DIR_S_SUCCESS;
  extern DIclassid OPP_IGRdir_class_id, OPP_DIrectory_class_id, OPP_DIlink_class_id,
                   OPP_DIroot_class_id;

  if (!DIR_G_init)
  {
    DIgrid  trs_grid;
    OMuword i;

    ospaths = (DIchar **)malloc ( (OM_Gw_maxOS + 2) * sizeof ( char * ) );
    if (ospaths)
      for (i = 0; i <= OM_Gw_maxOS; i++)
        ospaths [i] = NULL;    
    else
      return OM_E_NODYNMEM;

    /* initialize the B-trees */
    DIBinit ();
    /* the classids */
    DIR_G_IGRdir_clid = OPP_IGRdir_class_id;
    DIR_G_DIrectory_clid = OPP_DIrectory_class_id;
    DIR_G_DIlink_clid = OPP_DIlink_class_id;
    DIR_G_DIroot_clid = OPP_DIroot_class_id;

    /* The current directory name and id */
    DIR_G_str_dir [0] = DIR_G_car_dir;
    DIR_G_str_dir [1] = '\0';
    strcpy ( DIR_G_cur_dir_name, DIR_G_str_dir );
    DIR_G_cur_dir_id = NULL_OBJID;
    DIR_G_cur_dir_os = 0;

    /* The home directory */
    strcpy ( DIR_G_home_name, DIR_G_str_dir );

    /* create the root directory	*/
    DIR_G_root_os = OM_Gw_TransOSnum_0;
    DIR_G_root_id = DIconstruct ( "DIrectory", OM_Gw_TransOSnum_0 );

    /* The current directory name and id */
    DIR_G_cur_dir_id = DIR_G_root_id;
    DIR_G_cur_dir_os = DIR_G_root_os;

    DIcreate_untree ( DIR_G_root_os );
    DIunall ( DIR_G_root_os, DIR_G_root_id, "", "", 0, NULL, NULL );

    /* attach the transient OS */
    di$mount ( logical = ":transient", osnum = OM_Gw_TransOSnum_0 );

    /* The previous current directory name and id */
    strcpy ( DIR_G_prev_cur_name, DIR_G_cur_dir_name );
    DIR_G_prev_cur_id = DIR_G_cur_dir_id;
    DIR_G_prev_cur_os = DIR_G_cur_dir_os;
    DIR_G_init = 1;

    /* initialize the groups */
    status = gr$init ();
    if (status != GR_S_SUCCESS)
      gr$report_error ( sts = (GRint) status, comment = "Group Initialization" );

    /* the current group must be usr */
    status = gr$cg ( groupname = "usr", passwd = "" );
    if (status != GR_S_SUCCESS)
      gr$report_error ( sts = status, comment = "cg ( usr )" );

    /* the group of :transient must be usr */
    DIbuild_mot ();
    DImasterRetrieve ( &status, ":transient", 0,
       (DIchar *) &trs_grid, NULL, NULL );
    om$send ( msg      = message GRoups.change_group ( &status, mot ),
              targetid = trs_grid.objid, targetos = trs_grid.osnum,
              senderid = NULL_OBJID );
  }

  return status;
} 


DIsu ( group )
       DIchar *group	/* The current group				OUT */;
/*
   This entry point is used to go in super user mode.  The current group
   is returned in group.
*/
{
  DIint status=0;

  if (DIR_G_init)
  {
    status = gr$pwg ( groupname = group );
    if (status != GR_S_SUCCESS)
      gr$report_error ( sts = (GRint) status, comment = "pwg" );
    status = gr$cg ( groupname = "sys", passwd = mot );
    if (status != GR_S_SUCCESS)
      gr$report_error ( sts = (GRint) status, comment = "cg ( sys )" );
  }

  return status;
}

           
DIback_su ( group )
            DIchar *group	/* The new group			IN  */;
/*
   This entry point is used to change the group to group from su mode.
*/
{
  DIint status;

  if (DIR_G_init)
  {
    status = gr$cg ( groupname = group );
    if (status != GR_S_SUCCESS)
      gr$report_error ( sts = status, comment = "cg ( ... )" );
  }
  
  return DIR_S_SUCCESS;
}


DImount ( DIchar *name, DIspacenum osnum, DIchar *classname )
/*
    This procedure mounts the object space osnum with a logical name.
*/
{
  OMuword i;
  DIint  status;
  DIgrid link_grid, dir_grid;
  DIchar fullname [DI_PATH_MAX], logical_name [DI_PATH_MAX], 
         dir_name [DI_PATH_MAX];
  DIchar group [DI_PATH_MAX];
                            
  if (osnum > OM_Gw_maxOS) return DIR_E_ABORT;
  if (om$is_objid_valid ( osnum = osnum, objid = 0 ) != OM_S_SUCCESS)
    return DIR_E_INVARG;

  /* update list of pathnames to os */
  for (i = 0; i <= OM_Gw_maxOS; i++)
    if (ospaths [i])
    {
      DIfree ( ospaths [i] );
      ospaths [i] = NULL;
    }

  if ((status = di$split ( pathname = name, dirname = dir_name,
                           name = logical_name )) == DIR_S_SUCCESS)
  {
    if ((status = DIstrcpy ( fullname, dir_name )) == DIR_S_SUCCESS)
     if ((status = DIstrcat ( fullname, logical_name )) == DIR_S_SUCCESS)
      if ((status = DIterminator ( fullname )) == DIR_S_SUCCESS)
      {
        /* create an untranslate table for that os */
        DIcreate_untree ( osnum );

        DIterminator ( dir_name );
        DImasterRetrieve ( &status, dir_name, 0, (DIchar *) &dir_grid,
           NULL, NULL );

        /* never attach yourself to a link */
        DIcheck_link ( (dir_grid.osnum), (dir_grid.objid) )

        DIsu ( group );
        status = DIcreate_dir ( (classname) ? classname : "DIlink",
                                fullname, logical_name, dir_grid, &link_grid );
        DIback_su ( group );

        /* change its group */
        om$send ( msg      = message GRoups.change_group ( &status, mot ),
                  targetid = link_grid.objid, targetos = link_grid.osnum,
                  senderid = NULL_OBJID );

        if (status == DIR_S_SUCCESS)
        {
          DIgrid root_grid;
          DIint  j, syno = 0;

          DIfind_root ( root_grid.osnum = osnum, &(root_grid.objid) );
          if (root_grid.objid == NULL_OBJID)
            root_grid.objid = DIconstruct ( "DIroot", osnum );

          if (root_grid.objid != NULL_OBJID)
          {
            DIgrid  grid;

            /* put the root in the untree */
            DIunall ( root_grid.osnum, root_grid.objid, dir_name,
               logical_name, 0, NULL, NULL );

            /* divert the messages from the link to the root */
            om_send_for ( DIlink.set_target ( &status, root_grid ),
                          NULL_OBJID, link_grid.objid, link_grid.osnum );

            /* update untree */
            DImasterRetrieve ( &status, dir_name, 0,
               (DIchar *) &grid, NULL, NULL );

            if (status != DIR_S_SUCCESS)
              di$report_error ( comment = "translate ( ... )", sts = status );
            di$start_untrans ( osnum = grid.osnum, objid = grid.objid, ptr = &syno );

            for (j = 0; (j < syno) && (status == DIR_S_SUCCESS); j++)
            { 
              DIint   count;
              DIchar  dir_name [DI_PATH_MAX], full_name [DI_PATH_MAX];

              di$fetch_untrans ( objname = dir_name, index = j );
              DIstrcpy ( full_name, dir_name );
              DIstrcat ( full_name, logical_name );

              /*
               * We do a find to wakeup the directories. This process is also going
               * to populate the untranslate tree.
               */
              DIsu ( group );
              di$find ( start_dir = full_name, ptr = &count, options = OPT_ALL|OPT_SYS );
              DIback_su ( group );
            }
          }
          else
            status = DIR_E_ABORT;
        }
      }
  }

  return status;
}


DIumount ( dirname1, sleep, keep )
           DIchar *dirname1	/* The directory to unmount		IN  */;
           DIint  sleep		/* Send a sleep or not			IN  */;
           DIint  keep		/* Keep B-trees or not			IN  */;
/*
    This procedure umounts the object space osnum knowing its logical name.
*/
{
  DIint      status = DIR_S_SUCCESS, i, j, count;
  DIgrid     link_grid;
  DIobjid    objid, owner_id;
  DIspacenum osnum, owner_os;
  DIchar     name [DI_PATH_MAX], owner [DI_PATH_MAX], base [DI_PATH_MAX];
  DIchar     dirname [DI_PATH_MAX], group [DI_PATH_MAX], passwd [9];
  GRint      l1, l2;
                            
  sleep = keep = 0;
  /* update list of pathnames to os */
  for (i = 0; i <= (DIint) OM_Gw_maxOS; i++)
    if (ospaths [i])
    {
      DIfree ( ospaths [i] );
      ospaths [i] = NULL;
    }

  if ((status = DIexpanse ( dirname1, dirname )) != DIR_S_SUCCESS)
    return status;
  l1 = high - offset;

  /* initialize the grouping scheme */
  memcpy ( passwd, (char *) &l1, sizeof ( GRint ) );
  l2 = low - offset;

  /* save the current group */
  status = gr$pwg ( groupname = group );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "pwg" );

  /* the current group must be sys */
  memcpy ( &(passwd [sizeof ( GRint )]), (char *) &l2, sizeof ( GRint ) );
  status = gr$cg ( groupname = "sys", passwd = passwd );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "cg ( sys )" );

  if (!DIstrcmp ( dirname, DIR_G_cur_dir_name ))
    di$cd ( dirname = DIR_G_str_dir );
  DImasterRetrieve ( &status, dirname, 0, (DIchar *) &link_grid,
     NULL, NULL );
  if (status == DIR_S_SUCCESS)
  {
    DIint syno = 0;

    /* check that there is no synonym */
    status = di$start_untrans ( osnum = link_grid.osnum, ptr = &syno,
                                objid = link_grid.objid );
    om$get_intercept ( osnum = link_grid.osnum, objid = link_grid.objid,
                       p_target_osnum = &osnum, p_target_objid = &objid );

    if (syno > 1)
    {
      /* there is -> rmdir */
      status = di$rmdir ( dirname = dirname );
    }
    else
    {
      int quick_delete /* can we blow away the untranslate tree ? */;
      
      if (!DIancestry_valid ( link_grid.osnum, link_grid.objid, DIR_G_DIlink_clid ))
        /* it's not a link : ABORT */
        return DIR_E_INVARG;

      /* don't do it like UNIX ! */
      if (DIR_G_cur_dir_os == osnum) di$cd ( dirname = DIR_G_str_dir );

      /* get the number of synonyms of the parent */
      di$split ( pathname = dirname, dirname = owner, name = base );
      {
        DIgrid owner_grid;

        DImasterRetrieve ( &status, owner, 0, (DIchar *) &owner_grid,
           NULL, NULL );
        owner_os = owner_grid.osnum;
        owner_id = owner_grid.objid;
      }

      /* multiple mount ? */
      di$start_untrans ( osnum = osnum, objid = objid, ptr = &syno );
      quick_delete = syno == 1;
      
      di$start_untrans ( objid = owner_id, osnum = owner_os, ptr = &syno );

      for (j = 0; (j < syno) && (status == DIR_S_SUCCESS); j++)
      {
        DIchar owner [DI_PATH_MAX];

        di$fetch_untrans ( objname = owner, index = j );
        DIstrcpy ( name, owner );
        DIstrcat ( name, base );

        di$start_find ( start_dir = name, ptr = &count, options = OPT_ALL|OPT_SYS );
        for (i = 0; (i <= count) && (status == DIR_S_SUCCESS); i++)
        {
          DIchar line [DI_PATH_MAX], dirname [DI_PATH_MAX], 
                 *objname, buf [DI_PATH_MAX];
          DIgrid grid;
          DIint  loc_status;

          if (i == count)
          {
            /* process the directory itself */
            DIstrcpy ( line, name );
            grid = link_grid;
            loc_status = DIR_S_SUCCESS;
          }
          else
            loc_status = di$fetch_find ( line = line, p_grid = &grid,
               index = count - i - 1 );
          OM_DI_RESET ( grid.osnum, grid.objid );

          /*
           * If there are no synonyms then we can blow away the untranslate tree. This
           * is faster than removing names one at a time.
           */
          if (!quick_delete || i == count)
          {
            if (loc_status == DIR_W_NO_NAME)
            {
              /* This object has no name */
              DIstrcpy ( dirname, line );
              objname = NULL;
            }
            else
            {
              objname = buf;
              di$split ( pathname = line, dirname = dirname, name = objname );
            }
  
            DIunall ( grid.osnum, grid.objid, dirname, objname, 1, NULL, NULL );
          }
        }
      }

      if (status == DIR_S_SUCCESS)
      {
        di$untranslate ( osnum = link_grid.osnum, objid = link_grid.objid,
                         objname = name, ptr = &syno );

        if (!syno)
        {
          /* delete the link */
          om_send_for ( DIbstob.remove_info ( &status, base, 0 ), NULL_OBJID, owner_id, owner_os );
          om$cancel_intercept ( osnum = link_grid.osnum, objid = link_grid.objid );
          om_send_for ( DIlink.delete ( 1 ), NULL_OBJID, link_grid.objid, link_grid.osnum );
          DIunall ( osnum, objid, owner, base, 1, NULL, NULL );

          /* multiple mount ? */
          di$start_untrans ( osnum = osnum, objid = objid, ptr = &syno );

          if (!syno)
          {
            /* send sleep to root of os */
            om_send_for ( DIstorage.sleep ( &status, 0 /* keep */ ), NULL_OBJID, objid, osnum );
 
            /* last one -> delete the untree */
            DIquick_delete_untree ( osnum );
            
            /* take care of directories */
            for (i = 0; (i < count) && (status == DIR_S_SUCCESS); i++)
            {
              DIgrid grid;
              extern DIclassid OPP_DIstorage_class_id;
  
              di$fetch_find ( p_grid = &grid, index = i );
              if (DIancestry_valid ( grid.osnum, grid.objid, OPP_DIstorage_class_id ))
                om_send_for ( DIstorage.sleep ( &status, 0 ), NULL_OBJID, grid.objid, grid.osnum );
            }
          }
        }
      }
    }
  }
  
  {
    DIint status;

    status = gr$cg ( groupname = group, passwd = "" );
    if (status != GR_S_SUCCESS)
      gr$report_error ( sts = status, comment = "cg ( group )" );
  }

  return status;
}


DIgive_pathname ( DIspacenum osnum, DIchar *pathname )
/* This procedure is used to find a pathname of an osnum (untranslate osnum!) */
{
  DIint status;
                            
  if (osnum > OM_Gw_maxOS)
    status = DIR_E_INVARG;
  else
    if (ospaths [osnum])
      status = DIstrcpy ( pathname, ospaths [osnum] );
    else
    {
      DIgrid root;
  
      /* let't try to find it */
      root.objid = NULL_OBJID;
      DIfind_root ( root.osnum = osnum, &(root.objid) );
      if (root.objid == NULL_OBJID)
        status = DIR_E_INVARG;
      else
      {
        DImalloc ( ospaths [osnum], DIchar *, DI_PATH_MAX );
        if (di$untranslate ( osnum = root.osnum,
                             objid = root.objid,
                             objname = ospaths [osnum] ) == DIR_S_SUCCESS)
          status = DIstrcpy ( pathname, ospaths [osnum] );      
        else
        {
          DIfree ( ospaths [osnum] );
          ospaths [osnum] = NULL;
          status = DIR_E_INVARG;
        }
      }
    }

  return status;
}


end implementation DIrectory;

