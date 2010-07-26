/*
  ABSTRACT :
  --------

   This file constains the programmer DIinterface.
*/

class implementation DIrectory;

#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIprims.h"
#include "DIdef.h"
#include "DIomac.h"

/*
   The following entry points are called by DImain (they have the same
   argument list !).
*/

DIadd_name ( full_name, target_name, target_grid, base_name,
             base_objid, new_name, p_objid, p_osnum )
             DIchar     *full_name	/* Full path name		IN  */;
             DIchar     *target_name	/* Directory name		IN  */;
             DIgrid     target_grid	/* Directory grid		IN  */;
             DIchar     *base_name	/* Base name to be added	IN  */;
             DIobjid    base_objid	/* Base objid to be named	IN  */;
             DIchar     *new_name	/* Not used			IN  */;
             DIobjid    *p_objid	/* Not used			OUT */;
             DIspacenum *p_osnum	/* Pointer to object osnum	OUT */;
/* This procedure is used to add a name in the directory sub-system */
{
  DIint status;

  full_name = new_name = NULL;
  p_objid = NULL;
  /* target_name is NULL when a mkdir is in process */
  if (target_name && DIancestry_valid ( target_grid.osnum, base_objid, DIR_G_IGRdir_clid ))
    /* add the directory to the tree */
    status = DIR_E_INVARG;
  else
    om_send_for ( IGRdir.add ( &status, base_name, base_objid, NULL ),
                  NULL_OBJID, target_grid.objid, target_grid.osnum );

  if (p_osnum && status == DIR_S_SUCCESS) *p_osnum = target_grid.osnum;

  return status;
}

static DIchar DIR_G_last_path [DI_PATH_MAX];

#argsused

DItranslate ( full_name, target_name, target_grid, base_name, base_objid,
              new_name, p_objid, p_osnum )
              DIchar     *full_name	/* Full path name		IN  */;
              DIchar     *target_name	/* Directory name		IN  */;
              DIgrid     target_grid	/* Directory grid		IN  */;
              DIchar     *base_name	/* Base name to be translated	IN  */;
              DIobjid    base_objid	/* Not used			IN  */;
              DIchar     *new_name	/* Not used			IN  */;
              DIobjid    *p_objid	/* Pointer to object objid	OUT */;
              DIspacenum *p_osnum	/* Pointer to object osnum	OUT */;
/* This procedure is used to translate a name from the directory sub-system */
{
  DIint status = DIR_S_SUCCESS;

  DIstrcpy ( DIR_G_last_path, full_name );
  if (base_name [0] == '\0') base_objid = target_grid.objid;
  if (base_objid == NULL_OBJID) status = DIR_W_NAME_NOT_FOUND;
  if (p_objid) *p_objid = base_objid;
  if (p_osnum) *p_osnum = target_grid.osnum;

  return status;
}


#argsused

DIrename ( full_name, target_name, target_grid, base_name, base_objid,
           new_name, p_objid, p_osnum )
           DIchar     *full_name	/* Full path name		IN  */;
           DIchar     *target_name	/* Directory name		IN  */;
           DIgrid     target_grid	/* Directory grid		IN  */;
           DIchar     *base_name	/* Base name to be translated	IN  */;
           DIobjid    base_objid	/* Objid object			IN  */;
           DIchar     *new_name		/* New object name		IN  */;
           DIobjid    *p_objid		/* Pointer to object objid	OUT */;
           DIspacenum *p_osnum		/* Pointer to object osnum	OUT */;
/*
   This function is used to rename an named object.  Note that a directory
   CANNOT be renamed.
*/
{
  static char *clnm = "ACcpx";
  DIint status;
  OMuword clid = -1;

  if (base_objid == NULL_OBJID)
    return DIR_W_NAME_NOT_FOUND;

  if (DIancestry_valid ( target_grid.osnum, base_objid, DIR_G_IGRdir_clid ))
  {
    if (new_name)
      if (*new_name)
      {
        if ((status = di$link ( objname  = full_name,
                                newname  = new_name )) == DIR_S_SUCCESS)
        status = di$rmdir ( dirname = full_name ); }
      else
        status = DIR_E_INVARG;
    else
    {
      OMuword	subclassid ;

      // HF: 01/22/2002 - Cannot have GRNUC dependency (OPP_ACcpx_class_id)...
      om$get_classid ( classname = clnm, p_classid = &clid );

      if( ( 1 & om$get_classid( objid           = base_objid,
                                osnum           = target_grid.osnum,
                                p_classid       = &subclassid ) )
             && om$is_ancestry_valid( superclassid    = clid,	// OPP_ACcpx_class_id,
                                      subclassid      = subclassid)==OM_S_SUCCESS)
      {
        om_send_for ( IGRdir.remove ( &status, base_name, 0 ),
                      NULL_OBJID, target_grid.objid, target_grid.osnum );
        status = DIR_S_SUCCESS;
      }
      else
        status = DIR_E_INVARG;
    }
  }
  else
  {
    /* make sure that name is in there */
    om_send_for ( IGRdir.translate ( &status, base_name, 0, NULL, NULL ),
                  NULL_OBJID, target_grid.objid, target_grid.osnum );
    if (status == DIR_S_SUCCESS)
    {
      /* make sure we have the right to modify that directory */
      om_send_for ( GRoups.validate ( &status, DIR_R_WRITE ),
                    NULL_OBJID, target_grid.objid, target_grid.osnum );
      if (status == DIR_S_SUCCESS)
      {
        if (new_name)
        {
          DIchar full_name [DI_PATH_MAX];

          if ((status = DIexpanse ( new_name, full_name )) == DIR_S_SUCCESS)
            status = di$add_name ( objname = full_name, objid = base_objid );
        }
        if (status == OM_S_SUCCESS)
          om_send_for ( IGRdir.remove ( &status, base_name, 0 ),
                        NULL_OBJID, target_grid.objid, target_grid.osnum );
      }
    }
  }

  return status;
}

#argsused

DImkdir ( full_name, target_name, target_grid, base_name, base_objid,
          class_name, p_dirid, p_osnum )
          DIchar     *full_name		/* Full path name		IN  */;
          DIchar     *target_name	/* Directory name		IN  */;
          DIgrid     target_grid	/* Directory grid		IN  */;
          DIchar     *base_name		/* Not used			IN  */;
          DIobjid    base_objid		/* Not used			IN  */;
          DIchar     *class_name	/* Name of the class to create	IN  */;
          DIobjid    *p_dirid		/* Pointer to object objid	OUT */;
          DIspacenum *p_osnum		/* Pointer to object osnum	OUT */;
{
  DIint  status = DIR_S_SUCCESS;
  DIgrid new_grid;

  if (base_objid == NULL_OBJID)
  { if (base_name [0] == '\0')
      status = DIR_E_INVARG;
    else
    {
      status = DIcreate_dir ( (class_name) ? class_name : "DIrectory",
          full_name, base_name, target_grid, &new_grid );
    }
  }
  else
  { status = DIR_E_DIR_DUP;
    new_grid.objid = base_objid;
    new_grid.osnum = target_grid.osnum; }

  if (p_dirid) *p_dirid = new_grid.objid;
  if (p_osnum) *p_osnum = new_grid.osnum;

  return status;
}

#argsused

DIrmdir ( full_name, target_name, target_grid, base_name, base_objid,
          new_name, p_dirid, p_osnum )
          DIchar     *full_name		/* Full path name		IN  */;
          DIchar     *target_name	/* Directory name		IN  */;
          DIgrid     target_grid	/* Directory grid		IN  */;
          DIchar     *base_name		/* Base name of object		IN  */;
          DIobjid    base_objid		/* Directory objid		IN  */;
          DIchar     *new_name		/* Not used			IN  */;
          DIobjid    *p_dirid		/* Not used			OUT */;
          DIspacenum *p_osnum		/* Not used			OUT */;
/*
  This function is used to remove a directory from the directory
  sub-system.  Its not legitimate to delete the current directory
  or a non-empty IGRdir.
*/
{
  DIint   status = DIR_S_SUCCESS;
  DIunode node;

  if (base_objid == NULL_OBJID) return DIR_W_DIR_NOT_FOUND;
  if (DIancestry_valid ( target_grid.osnum, base_objid, DIR_G_IGRdir_clid ))
  { /* refuse to kill current directory or root */
    if (((base_objid != DIR_G_cur_dir_id) ||
         (target_grid.osnum != DIR_G_cur_dir_os)) && (base_name [0] != '\0'))
    {
      DIchar full_name [DI_PATH_MAX], target_name [DI_PATH_MAX];
      DIint  i, j, syno = 0;

      status = di$untranslate ( osnum = target_grid.osnum, objid = target_grid.objid,
                                ptr   = &syno, objname = target_name );

      /* find all the synonyms for the directory to be removed */
      DIunall ( target_grid.osnum, base_objid, NULL, NULL, 0, &node, NULL );
      if (syno == node.count)
      { om_send_for ( DIstorage.is_empty ( &status ), NULL_OBJID, base_objid, target_grid.osnum );
        if (!status) status = DIR_E_DIR_NOT_EMPTY; }
      else
        status = DIR_S_SUCCESS;

      if (status == DIR_S_SUCCESS)
      { /* are we allowed to write in the owner ? */
        om$send ( msg      = message GRoups.validate ( &status, DIR_R_WRITE ),
                  senderid = NULL_OBJID,
                  targetid = target_grid.objid,
                  targetos = target_grid.osnum );

        for (i = 0; (i < syno) && (status == DIR_S_SUCCESS); i++)
        { DIchar **lines;
          DIgrid *grids, grid;
          DIint  count;

          DIstrcpy ( full_name, target_name );
          DIstrcat ( full_name, base_name );

          /* find the tree underneath the removed directory */
          status = di$find ( regexp = "*", options = 0, ptr = &count,
                             start_dir = full_name, lines = &lines, grids = &grids );
          /*
           * It's ok if there is nothing under
           */
          if (status != DIR_S_SUCCESS)
          {
            status = DIR_S_SUCCESS;
            break;
          }
          grid.osnum = target_grid.osnum;
          grid.objid = base_objid;
          DIadd_grid_line ( &lines, &grids, full_name, grid, count++ );
          /* exchange first and last entry */
          { DIchar *ptr;
            DIgrid grid;

            ptr = lines [0]; lines [0] = lines [count - 1]; lines [count - 1] = ptr;
            grid = grids [0]; grids [0] = grids [count - 1]; grids [count -1] = grid; }

          for (j = count - 1; j >= 0; j--)
          { DIchar dir_name [DI_PATH_MAX], base_name [DI_PATH_MAX];

            di$split ( pathname = lines [j], dirname = dir_name, name = base_name );
            if (j)
              DIunall ( grids [j].osnum, grids [j].objid, dir_name, base_name, 1, NULL, NULL );
            if (DIancestry_valid ( grids [j].osnum, grids [j].objid, DIR_G_IGRdir_clid ))
            {
              if (DIancestry_valid ( grids [j].osnum, grids [j].objid, DIR_G_DIlink_clid ))
              { DIcheck_link ( (grids [j].osnum), (grids [j].objid) )
                DIunall ( grids [j].osnum, grids [j].objid, dir_name, base_name, 1, NULL, NULL ); }}}

          DIfree ( grids )
          di$free ( lines = lines, count = count );
          if ((i + 1) < syno)
            status = di$untranslate ( osnum = target_grid.osnum,
                                      objid = target_grid.objid, index = i + 1,
                                      ptr   = &syno, objname = target_name ); } /* for */

        if (status == DIR_S_SUCCESS)
        { /* rm directory from its owner */
          om_send_for ( IGRdir.remove ( &status, base_name, 0 ),
                        NULL_OBJID, target_grid.objid, target_grid.osnum );

          /*
           * Make sure the DIlink is gone as well
           */
          if (DIancestry_valid ( target_grid.osnum, base_objid, DIR_G_DIlink_clid ))
          {
            DIspacenum osnum = target_grid.osnum;
            DIobjid    objid = base_objid;

            DIcheck_link ( (osnum), (objid) )
            DIunall ( osnum, objid, target_name, base_name, 1, NULL, NULL );
          }

          if ((status == DIR_S_SUCCESS) && (node.count == syno))
          { om_send_for ( Root.delete ( 0 ), NULL_OBJID, base_objid, target_grid.osnum );
            /* clear the previous directory if needed */
            if ((DIR_G_prev_cur_id == base_objid) && (DIR_G_prev_cur_os == target_grid.osnum))
            { DIR_G_prev_cur_id = DIR_G_cur_dir_id;
              DIR_G_prev_cur_os = DIR_G_cur_dir_os;
              DIstrcpy ( DIR_G_prev_cur_name, DIR_G_cur_dir_name ); }}}}}
    else
      status = DIR_E_INVARG;
  }
  else
    status = DIR_W_DIR_NOT_FOUND;

  return status;
}


DIpwd ( dirname, p_dirid, p_osnum )
        DIchar     *dirname	/* Current directory name		OUT */;
        DIobjid    *p_dirid	/* Current directory objid		OUT */;
        DIspacenum *p_osnum	/* Current directory osnum		OUT */;
{
  if (dirname)
  { DIstrcpy ( dirname, DIR_G_cur_dir_name );
    if (dirname [0] == '\0') DIstrcpy ( dirname, DIR_G_str_dir ); }
  if (p_dirid) *p_dirid = DIR_G_cur_dir_id;
  if (p_osnum) *p_osnum = DIR_G_cur_dir_os;

  return DIR_S_SUCCESS;
}



DIcd ( DIchar *dirname1, DIspacenum osnum, DIobjid *p_dirid,
       DIspacenum *p_osnum, DIchar *path, DIint synpath )
{
  DIint  status = DIR_S_SUCCESS;
  DIgrid dir_grid;

  if ((dirname1 != NULL) || (dirname1 ? *dirname1 : 0))
  { DIchar dirname [DI_PATH_MAX];

    /* check for '-' */
    DIstrcpy ( dirname, (DIstrcmp ( dirname1, "-" )) ? dirname1 : DIR_G_prev_cur_name );
    if (!*dirname) DIstrcpy ( dirname, DIR_G_str_dir );
    if ((status = di$translate ( objname = dirname,
  			         path    = path,
                                 synpath = synpath,
                                 osnum   = osnum,
                                 p_objid = &dir_grid.objid,
                                 p_osnum = &dir_grid.osnum )) == DIR_S_SUCCESS)
    {
      DIstrcpy ( dirname, DIR_G_last_path );
      /* check the class (must a directory) */
      if (!DIancestry_valid ( dir_grid.osnum, dir_grid.objid, DIR_G_IGRdir_clid ))
        status = DIR_W_NAME_NOT_FOUND;
    }

    if (status == DIR_W_NAME_NOT_FOUND) status = DIR_W_DIR_NOT_FOUND;

    if (status == DIR_S_SUCCESS)
    { /* save actual current directory */
      DIstrcpy ( DIR_G_prev_cur_name, DIR_G_cur_dir_name );
      DIcheck_link ( (dir_grid.osnum), (dir_grid.objid) )
      DIR_G_cur_dir_os = dir_grid.osnum;
      DIR_G_cur_dir_id = dir_grid.objid;
      DIstrcpy ( DIR_G_cur_dir_name, dirname );
    }
  }
  else
    status = DIR_E_INVARG;

  if (status == DIR_S_SUCCESS)
  { if (p_dirid) *p_dirid = dir_grid.objid;
    if (p_osnum) *p_osnum = dir_grid.osnum; }

  return status;
}


DIpass ( flag, msg, regexp, classes )
         OM_E_WRT_FLAG  flag	/* Type of send (message, object, ...	IN  */;
         DIchar         *regexp	/* Regular expression to match		IN  */;
         OM_p_MESSAGE   msg	/* Message to be sent			IN  */;
         OM_p_CLASSLIST classes/* Valid classes			IN  */;
/*
   This function send the message msg with the flag to all objects that
   match the regular expression.
*/
{
  DIint  i, om_st, sts, count;
  DIgrid grid;

  sts = di$start_dump ( regexp = regexp, p_classes = classes, ptr = &count, options = OPT_ALL );
  for (i = 0, om_st = 1; (i < count) && (sts == 1) && (om_st & 1); i++)
    if ((sts = di$fetch_dump ( index = i, p_grid = &grid )) == DIR_S_SUCCESS)
      om_st = om$send ( msg = msg, mode = flag, senderid = NULL_OBJID,
                        targetid = grid.objid, targetos = grid.osnum );

  return (om_st & OM_S_SUCCESS) ? sts : DIR_E_ABORT;
}


DIrm_objid (DIobjid objid, DIspacenum osnum )
/* This procedure is used to remove one entry from the directory sub-system */
{
  DIint  status, count = 0, i;
  DIchar name [DI_PATH_MAX];

  status = di$untranslate ( objid = objid, osnum = osnum, ptr = &count, objname = name );
  for (i = 0; (i < count) && ((status == DIR_S_SUCCESS) || (status == DIR_W_NO_NAME)); i++)
  { if ((status = di$untranslate ( objid = objid, osnum = osnum, objname = name )) == DIR_S_SUCCESS)
      status = di$rm_name ( regexp = name );
    else
      if (status == DIR_W_NO_NAME)
      { DIint index;

        di$untranslate ( objid = objid, osnum = osnum, objname = name, p_index = &index );
        status = di$rm_index ( dirname = name, index = index ); }}

  return (i > 0) ? (status == DIR_W_NAME_NOT_FOUND) ? DIR_S_SUCCESS : status : status;
}



DIgive_osnum ( pathname, p_osnum )
               DIchar      *pathname	/* Pathname to be analyzed	IN  */;
               DIspacenum  *p_osnum	/* Osnum of pathname		OUT */;
/* This procedure is used to find the osnum of a particular pathname */
{
  DIint  status = DIR_S_SUCCESS;
  DIchar fullname [DI_PATH_MAX];

  if ((status = DIexpanse ( pathname, fullname )) == DIR_S_SUCCESS)
  { DIint   i;
    DIgrid  grid;

    /* for each component do a translate until ok */
    for (i = strlen ( fullname ); i >= 0; )
    {
      DImasterRetrieve ( &status, fullname, 0, (DIchar *) &grid, NULL, NULL );
      if (status == DIR_S_SUCCESS)
      { DIcheck_link ( (grid.osnum), (grid.objid) )
        if (p_osnum) *p_osnum = grid.osnum;
        break; }

      /* remove one component */
      for (; (i >= 0) && (fullname [i] != DIR_G_car_dir); i--);
      fullname [i] = '\0'; }}

  return status;
}


DIsend ( DIchar *path, DIint synpath, OM_E_WRT_FLAG mode,
         DIobjid senderid, DIspacenum targetos, DIchar *targetname,
         OM_p_MESSAGE msg )
/*
   This procedure is used to send a message to a named object.
*/
{
  DIobjid    objid;
  DIint      status;
  DIspacenum osnum;

  if((status = di$translate ( osnum = targetos,
			      objname = targetname,
                              path = path,
                              synpath = synpath,
			      p_objid = &objid,
                              p_osnum = &osnum )) == DIR_S_SUCCESS)
  { status = om$send ( msg = msg, targetos = osnum, targetid = objid,
                       senderid = senderid, mode = mode );
    if (status != OM_S_SUCCESS)
    { om$report_error ( sts = status );
      status = DIR_E_ABORT; }}

  return status;
}

end implementation DIrectory;
