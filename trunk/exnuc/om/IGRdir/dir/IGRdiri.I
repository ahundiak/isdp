/*
    ABSTRACT :
    --------

    This is the implementation file of the class IGRdir.  This class provides
    a layered naming capability with full support of the UNIX directory
    system user interface.  It also supports the reference file attachments.
*/
class implementation IGRdir;


#undef close
#include <string.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIdef.h"
#include "DIprims.h"

#define DEBUG
#include "DIdebug.h"

#include "DIomac.h"

from DIstorage import store_info, retrieve_info, remove_info, list, get_type, close;
from GRoups    import validate;

method init ( DIint *status )
{
  *status = DIR_S_SUCCESS;
  return OM_S_SUCCESS;
}
  
struct argument { char *name; };

method i_find ( DIint  *status;
                DIchar *my_name; 
                DIchar **exp_buf;
                DIint  buf_count;
                DIint  level, max_level, *deep;
                DIchar ***lines; 
                DIgrid **grids;
                DIint  *count;
                DIchar options )
/*
   This method is used to search for an entry in me and my sub-directories.
*/
{
  DIchar  **my_lines, prefix [DI_PATH_MAX];
  DIint   my_count, i, dir_index, om_st, propagate;
  DIgrid  *my_grids;
  extern  OMuword OPP_DIstorage_class_id;

  DIvalidate ( status, DIR_R_READ )
  *deep = (*deep > level) ? *deep : level;
  my_count = 0;
  my_grids = NULL;
  my_lines = NULL;
  om_st = om$send ( msg = message IGRdir.dump ( status, "*", NULL, &my_lines, 
                                                &my_grids, &my_count, 
                                                options & (OPT_ALL | OPT_SYS) ),
                    targetid = my_id );
  if (om_st != OM_S_SUCCESS)
    return om_st;

  if (options & OPT_LEVEL)
     for (i = 0, prefix [0] = '\0'; i < level; i++)
       strcat ( prefix, "  " );
  else
     strcpy ( prefix, my_name );

  /* add entries to the table */
  for (i = 0, dir_index = 0; i < my_count; i++)
  {
    DIchar  fullname [DI_PATH_MAX];

    if (my_lines [i])
    {
      if ((DImulti_step ( my_lines [i], exp_buf, buf_count )) && 
          ((my_lines [i] [0] != '.') || (options & OPT_ALL)))
      {
        /* build the full name */
        DIstrcpy ( fullname, prefix );
        if (options & OPT_LEVEL)
          strcat ( fullname, my_lines [i] );
        else
          DIstrcat ( fullname, my_lines [i] );
        if (options & OPT_TRAILER)
        {
          OM_S_MESSAGE           msg;
          int                    sts;
          struct argument        argument;
          OMuword                clid;

          /* get the output from the class */
          argument.name = fullname;
          sts = om$get_classid ( objid = my_grids [i].objid, osnum = my_grids [i].osnum, 
             p_classid = &clid );

          if (sts == OM_S_SUCCESS)
          {
            sts = om$make_message ( classid    = clid,
                                    methodname = "DIgive_output",
                                    size       = sizeof ( argument ),
                                    p_arglist  = &argument,
                                    p_msg      = &msg );
            if (sts == OM_S_SUCCESS)
              sts = om$send ( msg = &msg,
                              targetid = my_grids [i].objid, targetos = my_grids [i].osnum );
            if (sts != OM_S_SUCCESS)
            {
              /* the class does not understand the message: get the trailer */
              DIchar trailer [DI_PATH_MAX], tmp [DI_PATH_MAX];
    
              sprintf ( tmp, "%c%s%c%s", DIR_G_car_dir, my_name, DIR_G_car_dir, my_lines [i] );
              DIget_trailer ( tmp, trailer );
              strcat ( fullname, trailer );
            }
          }
        }
        DIadd_grid_line ( lines, grids, fullname, my_grids [i], *count );
        (*count)++;
      }
    }
    else
    {
      /* unnamed object */
      if (options & OPT_SYS)
      {
        DIstrcpy ( fullname, my_name );
        DIstrcat ( fullname, DIR_G_str_dir );
        DIadd_grid_line ( lines, grids, fullname, my_grids [i], *count );
      }
      else
        DIadd_grid_line ( lines, grids, NULL, my_grids [i], *count );
      (*count)++;
    }

    /* check if we want to propagate the message */
    if (options & OPT_SYS)
       propagate = DIancestry_valid ( OM_Gw_current_OS, my_grids [i].objid, 
                                      OPP_DIstorage_class_id );
    else
       propagate = 1;
    if (propagate)
      if (my_grids [i].objid != my_id)
        if (DIancestry_valid ( OM_Gw_current_OS, my_grids [i].objid, 
                               DIR_G_IGRdir_clid ))
          if ((max_level < 0) || (level < (max_level - 1)))
          {
            DIchar his_name [DI_PATH_MAX];
            DIint  om_st;
            DIgrid dummy;

            DIstrcpy ( his_name, my_name );
            DIstrcat ( his_name, my_lines [i] );
            om_st = om$send ( msg = message IGRdir.i_find ( status, his_name, 
                                                            exp_buf, buf_count,
                                                            level + 1, max_level, 
                                                            deep, lines, grids, 
                                                            count, options ),
                              targetid = my_grids [i].objid );
            if (om_st != OM_S_SUCCESS)
              /* if it's a link with no message interception: delete it */
              if (DIancestry_valid ( OM_Gw_current_OS, my_grids [i].objid, 
                                     DIR_G_DIlink_clid ) &&
                  om$get_intercept ( objid = my_grids [i].objid,
                                     p_target_osnum = &dummy.osnum,
                                     p_target_objid = &dummy.objid ) != OM_S_SUCCESS)
              {
                int local_st;

                /* get rid of the guy */
                om$send ( msg = message Root.delete ( 1 ),
                          targetid = my_grids [i].objid );
              
                om$send ( msg = message IGRdir.remove ( &local_st, my_lines [i], 0 ),
                          targetid = my_id );
              
                /* remove his name from the list */
                (*count)--;
              }
          }
  }

  di$free ( lines = my_lines, count = my_count );
  if (my_count) DIfree ( my_grids );
  if (*count == 0)
     *status = DIR_W_NAME_NOT_FOUND;
  else
     *status = DIR_S_SUCCESS;

  return OM_S_SUCCESS;
}


method find ( DIint *status; DIchar *reg_exp1; DIchar ***lines; DIgrid **grids;
              DIint *count; DIint max_level, *deep; DIchar options )
/*
   This method is used to search for an entry in me and my sub-directories.
*/
{
  DIint  level, buf_count;
  DIchar **expbuf, my_name [DI_PATH_MAX];
  
  /* check that the operation is valid */
  DIvalidate ( status, DIR_R_READ )
  *status = di$untranslate ( objname = my_name, objid = my_id );

  *count = 0;  *deep  = 0;
  level  = 0;  expbuf = NULL;
  
  DImulti_parse ( reg_exp1, &expbuf, &buf_count );
  om_send_me ( IGRdir.i_find ( status, my_name, expbuf, buf_count, level, 
                               max_level, deep, lines, grids, count, options ) );
  if (expbuf) di$free ( lines = expbuf, count = buf_count );

  return OM_S_SUCCESS;
}

#define INCREMENT 64

DIadd_line ( lines, count, info )
             DIchar ***lines					/* IN/OUT */;
             DIint  count					/* IN     */;
             DIchar *info					/* IN     */;
{
  if (count)
  {
    if (!((count + 1) % INCREMENT))
      DIrealloc ( *lines, DIchar **, (count + INCREMENT) * sizeof ( DIchar * ) )
  }
  else
    DImalloc ( *lines, DIchar **, INCREMENT * sizeof ( DIchar * ) )

  if (info)
  { 
    DImalloc ( (*lines) [count], DIchar *, strlen ( info ) * sizeof ( DIchar ) + 1 );
    strcpy ( (*lines) [count], info ); 
  }
  else
    (*lines) [count] = info;

  return DIR_S_SUCCESS;
}


DIadd_grid ( grids, count, info )
             DIgrid **grids					/* IN/OUT */;
             DIint  count					/* IN     */;
             DIgrid info					/* IN     */;
{
  if (count)
  {
    if (!((count + 1) % INCREMENT))
      DIrealloc ( *grids, DIgrid *, (count + INCREMENT) * sizeof ( DIgrid ) )
  }
  else
    DImalloc ( *grids, DIgrid *, INCREMENT * sizeof ( DIgrid ) )
  (*grids) [count] = info;

  return DIR_S_SUCCESS;
}



/* The following Globals are transmitted to the DIls_driver */

extern OM_p_CLASSLIST DIR_G_classlist	/* classlist of elements to be listed	*/;
extern DIchar	       ***DIR_G_lines	/* buffer to malloc			*/;
extern DIgrid	       **DIR_G_grids	/* buffer to malloc			*/;
extern DIchar	       DIR_G_options	/* options to be considered		*/;
extern DIint          DIR_G_count	/* number of processed itmes		*/;
extern DIint          DIR_G_level	/* number of levels in the reg. exp.	*/;

DIls_driver ( DIchar type, DIchar *p_id, DIchar *name )
/*
   This driver will be called for each node that has a name that match the
   regular expression.  Some globals are used to exchange the data.
*/
{
  DIchar  *key, buffer [DI_PATH_MAX];
  DIobjid objid;
  DIgrid  grid;

  memcpy ( (char *) &objid, (char *) p_id, sizeof ( DIobjid ) );
  memcpy ( (char *) &grid, (char *) p_id, sizeof ( DIgrid ) );
  key = name;
  if ((key) ? DIget_level ( key ) == DIR_G_level : 1)
  {
    if ((key) ? (key [0] != '.') || (DIR_G_options & OPT_ALL) : 1)
    {
      if ((key) && (DIR_G_options & OPT_TRAILER))
      {
        OM_S_MESSAGE           msg;
        DIint                  sts;
        struct { char *name; } argument;
        OMuword                clid;

        /* we don't want to modify the directory entry */
        key = (DIchar *)buffer;
        strncpy ( key, name, DI_PATH_MAX ) [DI_PATH_MAX - 1] = '\0';

        /* get the output from the class */
        argument.name = key;
        sts = om$get_classid ( objid = objid, p_classid = &clid );
        if (sts == OM_S_SUCCESS)
        {
          sts = om$make_message ( classid    = clid,
                                methodname = "DIgive_output",
                                size       = sizeof ( argument ),
                                p_arglist  = &argument,
                                p_msg      = &msg );
          if (sts == OM_S_SUCCESS)
            sts = om$send ( msg = &msg, senderid = NULL_OBJID,
                            targetid = objid, targetos = OM_Gw_current_OS );
        }

        if (sts != OM_S_SUCCESS)
        {
          DIchar trailer [DI_PATH_MAX];

          /* add the trailer if any */
          DIget_trailer_with_id ( OM_Gw_current_OS, objid, trailer );
          strncat ( key, trailer, DI_PATH_MAX ) [DI_PATH_MAX - 1] = '\0';
        }
      }

      if (DIcheck_class ( DIR_G_classlist, OM_Gw_current_OS, objid ))
      {
        if (DIR_G_grids)
        {
          if (type == DIR_D_STRING_OBJID)
          {
            grid.osnum = OM_Gw_current_OS;
            grid.objid = objid;
          }
          DIadd_grid ( DIR_G_grids, DIR_G_count, grid );
        }

        if (DIR_G_lines)
          DIadd_line ( DIR_G_lines, DIR_G_count, (key) ? key : "" );
        DIR_G_count++;
      }
    }
  }

  return DIR_S_SUCCESS;
}



method ls ( DIint          *status			/* OUT */;
            DIchar         *reg_exp			/* IN  */;
            DIchar         ***lines			/* OUT */;
            DIint          *count			/* OUT */;
            DIchar         options			/* IN  */ )
/*
   This method lists the entry (key) of a IGRdir.
*/
{
  om_send_me ( IGRdir.dump ( status, reg_exp, NULL, lines, NULL, count, options ) );

  return OM_S_SUCCESS;
} /* method ls */



method dump ( DIint          *status			/* OUT */;
              DIchar         *reg_exp			/* IN  */;
              OM_p_CLASSLIST classlist                  /* IN  */;
              DIchar         ***lines			/* OUT */;
              DIgrid         **grids			/* OUT */;
              DIint          *count			/* OUT */;
              DIchar         options			/* IN  */ )
/*
   This method dumps the entry (key + data) of an IGRdir.
*/
{
  DIvalidate ( status, DIR_R_READ )
  if (!count) { *status = DIR_E_INVARG; return OM_W_ABORT; }

  DIR_G_classlist = classlist;  DIR_G_lines     = lines;
  DIR_G_grids     = grids;      DIR_G_options   = options;
  DIR_G_count     = *count;     DIR_G_level     = DIget_level ( reg_exp );

  if (di$is_regexp ( regexp = (reg_exp) ? reg_exp : "*" ))
  {
    int om_st;
    
    /* regular expression -> list */
    om_st = om$send ( msg = message DIstorage.list ( status, reg_exp, count, 
                                                     (DIint (*)())DIls_driver ),
                      targetid = my_id );
    if (om_st != OM_S_SUCCESS)
      return om_st;
  }
  else
  { DIint  type;
    DIgrid grid;

    /* not a regular expression -> translate */
    om_send_me ( DIstorage.get_type ( &type ) );
    om_send_me ( DIstorage.retrieve_info ( status, reg_exp, 0,
       (DIchar *) &grid, NULL, NULL ) );
    if (*status == DIR_S_SUCCESS)
      DIls_driver ( (DIchar) type, (DIchar *) &grid, reg_exp ); }

  if (*status == DIR_S_SUCCESS)
  { *count = DIR_G_count;
    if (DIR_G_count)
      *status = DIR_S_SUCCESS;
    else
      if (reg_exp)
        *status = (DIstrcmp ( reg_exp, "*")) ? DIR_W_NAME_NOT_FOUND : DIR_I_DIR_EMPTY; 
      else
        *status =  DIR_I_DIR_EMPTY;
  }

  return OM_S_SUCCESS;
} /* method dump */


method pass ( DIint          *status;
              OM_S_MESSAGE   msg;
              OM_E_WRT_FLAG  flag;
              DIchar         *reg_exp; 
              OM_p_CLASSLIST classlist )
/*
    This method is used to send a message to all the objects that match
   the regular expression.
*/
{
  DIvalidate ( status, DIR_R_READ )
  *status = DIpass ( flag, &msg, reg_exp, classlist );
  return OM_S_SUCCESS;
} /* method pass */


method add ( DIint *status; DIchar *name; DIobjid objid; DIint *p_index )
/*
   This message is used to add the objid to the target directory; if a name is specified,
   it must be unique.
*/
{
  DIvalidate ( status, DIR_R_WRITE )
  if ((name) ? strchr ( name, DIR_G_car_dir ) : NULL)
    *status = DIR_E_ILL_NAME;
  else
    if (om$is_objid_valid ( objid = objid ) == OM_S_SUCCESS)
      om_send_me ( DIstorage.store_info ( status, name, (DIchar *) &objid,
         p_index ) )
    else
      *status = DIR_E_INVARG;

  return OM_S_SUCCESS;

} /* method add */


%undef remove


method remove ( DIint *status; DIchar *name; DIint index )
/* 
   This method removes the given object (by name or by index) from the directory.
*/
{
  DIvalidate ( status, DIR_R_WRITE )
  if (name ? strchr ( name, DIR_G_car_dir ) : NULL)
    *status = DIR_E_ILL_NAME;
  else
    om_send_me ( DIstorage.remove_info ( status, name, index ) );

  return OM_S_SUCCESS;
} /* method remove */


method translate ( DIint *status; DIchar *name; DIint index; DIchar *p_name; DIobjid *p_objid )
/* 
   This method is sent to translate a name or an index into an objid.
*/
{
  DIvalidate ( status, DIR_R_READ )
  if ((name) ? strchr ( name, DIR_G_car_dir ) : NULL)
    *status = DIR_E_ILL_NAME;
  else
    om_send_me ( DIstorage.retrieve_info ( status, name, index,
       (DIchar *) p_objid, p_name, NULL ) )

  return OM_S_SUCCESS;
} /* method translate */


method unindex ( DIint *status; DIint *index; DIchar *name; DIobjid objid )
/* 
   This method is sent to translate a name into an index.
*/
{
  DIint   i;
  DIchar  loc_name [DI_PATH_MAX];
  DIobjid loc_objid;

  for (i = 0, loc_name [0] = '\0', loc_objid = NULL_OBJID, *status = DIR_S_SUCCESS;
       *status == DIR_S_SUCCESS; i++)
  { om_send_me ( IGRdir.translate ( status, NULL, i, loc_name, &loc_objid ) );
    if ((name) && (loc_name))
    { if (!DIstrcmp ( loc_name, name )) break; }
    else
    { if (*status == DIR_W_NO_NAME)
        *status = DIR_S_SUCCESS;
      if (objid == loc_objid) break; }}

  if (*status == DIR_S_SUCCESS)
    *index = i;
  else
    if (*status == DIR_E_OVFLOW) *status = DIR_W_NAME_NOT_FOUND;

  return OM_S_SUCCESS;
} /* method unindex */



method delete ( DIint not_used )
/* 
   This method is sent to delete a directory.
*/
{
  DIint status;

  status = DIR_S_SUCCESS;
  om_send_me ( DIstorage.close ( &status ) );
  if (status == DIR_S_SUCCESS)
    om_send_me_msg ( Root.delete ( not_used ) );

  return status;
} /* method delete */



end implementation IGRdir;
