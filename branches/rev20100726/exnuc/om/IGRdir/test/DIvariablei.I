/*
    H.Bequet 12/02/1988                                           DIvariablei.I 

    ABSTRACT :
    --------

    This is the implementation file of the variable table.  This class provides
    a layered naming capability with full support of the UNIX directory
    system user interface.  It also provides pseudo-objects: the variables.
    The supported data types are described in DIvardef.h

    HISTORY :
    -------

    12/02/1988 : HGB - Creation Date
*/

class implementation DIvariable;

#define  DEBUG

#include <string.h>
#include "OMobjid.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIomac.h"
#include "DIprims.h"


method untranslate ( DIint *status; DIobjid objid; DIchar *name )
/*
   This method is used to find a name knowing an objid
*/
{
  *status = di$untranslate ( objid = objid, objname = name );

  return OM_S_SUCCESS;
} /* method untranslate */



method i_find ( DIint *status; DIchar *my_name; DIchar **exp_buf; DIint buf_count;
                DIint level, max_level, *deep; DIchar ***lines; DIgrid **grids;
                DIint *count; DIchar options )
{
  *status = OM_S_SUCCESS;
  if (!me->tree)
  {
    om_send ( DIstorage.wakeup ( status ), my_id, my_id );
  }

  if (*status == OM_S_SUCCESS)
    if (options & OPT_TRAILER)
    {
      DIchar  **my_lines, prefix [PATH_MAX];
      DIint   my_count, i, dir_index;
      DIgrid  *my_grids;

      DIvalidate ( status, DIR_R_READ )
      /*"my_name : '%s', *count : %d\n", my_name, *count */
      *deep = (*deep > level) ? *deep : level;
      /*"*deep : %d, level : %d\n", *deep, level */
      my_count = 0;
      my_grids = NULL;
      om_send ( IGRdir.dump ( status, "*", NULL, &my_lines, &my_grids, 
                              &my_count, options & (OPT_ALL | OPT_SYS) ), my_id, my_id );

      if (options & OPT_LEVEL)
        for (i = 0, prefix [0] = '\0'; i < level; i++)
          strcat ( prefix, "  " );
      else
        strcpy ( prefix, my_name );
      /*"prefix : '%s'\n", prefix */

      /* add entries to the table */
      for (i = 0, dir_index = 0; i < my_count; i++)
      {
        DIchar  fullname [PATH_MAX];

        if (my_lines [i])
        {
          /*"multi_step with '%s'\n", my_lines [i] */
          if ((DImulti_step ( my_lines [i], exp_buf, buf_count )) && 
              ((my_lines [i] [0] != '.') || (options & OPT_ALL)))
          {
            /* build the full name */
            DIstrcpy ( fullname, prefix );
            if (options & OPT_LEVEL)
              strcat ( fullname, my_lines [i] );
            else
              DIstrcat ( fullname, my_lines [i] );

            /*"options : %d\n", options */
            if (options & OPT_TRAILER)
            {
              DIchar tmp [PATH_MAX];
              DIint  status;
              DIdata data;

              om_send ( DIvariable.retrieve_variable ( &status, my_lines [i], &data ),
                        my_id, my_id );
              /*"add the value to '%s'\n", fullname */
              switch (data.type)
              {
                case DI_app: sprintf ( tmp, " = ??? <CANNOT PRINT APPLICATION DATA>" );
                             break;
                case DI_char: sprintf ( tmp, " = '%s'", data.var.str );
                              break;
                case DI_int:  sprintf ( tmp, " = %d", data.var.i );
                              break;
                case DI_objid: sprintf ( tmp, " = %d", data.var.objid );
                               break;
                case DI_double: sprintf ( tmp, " = %lf", data.var.d );
                                break;
                case DI_point: sprintf ( tmp, " = (%lf, %lf, %lf)",
                                         data.var.p [0], data.var.p [1],
                                         data.var.p [2] );
                               break;
                default: sprintf ( tmp, " = ??? illegal data type, BUG ??" ); 
              }
              strncat ( fullname, tmp, PATH_MAX ) [PATH_MAX - 1] = '\0';
            }
            /*"the full name : '%s'\n", fullname */
            DIadd_grid_line ( lines, grids, fullname, my_grids [i], *count );
            (*count)++;
          }
        }
        else
        {
          /*|unnamed object */
          if (options & OPT_SYS)
          {
            DIstrcpy ( fullname, my_name );
            DIstrcat ( fullname, DIR_G_str_dir );
            /*"the full name : '%s'\n", fullname */
            DIadd_grid_line ( lines, grids, fullname, my_grids [i], *count );
          }
          else
            DIadd_grid_line ( lines, grids, NULL, my_grids [i], *count );
          (*count)++;
        }

        /* check if we want to propagate the message */
        if (my_grids [i].objid != my_id)
          if (DIancestry_valid ( OM_Gw_current_OS, my_grids [i].objid, DIR_G_IGRdir_clid ))
            if ((max_level < 0) || (level < (max_level - 1)))
            {
              DIchar his_name [PATH_MAX];

              DIstrcpy ( his_name, my_name );
              DIstrcat ( his_name, my_lines [i] );
              om_send ( IGRdir.i_find ( status, his_name, exp_buf, 
                        buf_count, level + 1, max_level, deep, lines, grids, count, options ),
                        my_id, my_grids [i].objid );
            }
      }

      di$free ( lines = my_lines, count = my_count );
      if (my_count) DIfree ( my_grids );
      if (*count == 0)
        *status = DIR_W_NAME_NOT_FOUND;
      else
        *status = DIR_S_SUCCESS;
    }
    else
    {
      om_send_msg ( IGRdir.i_find ( status, my_name, exp_buf, buf_count, level,
                                    max_level, deep, lines, grids, count, options ),
                    my_id, my_id );
    }

  return OM_S_SUCCESS;
}


method init ( DIint *status )
{
  om_send_msg ( IGRdir.init ( status ), my_id, my_id );
  om_send_msg ( GRoups.init ( status ), my_id, my_id );
  om_send ( DIstorage.init ( status ), my_id, my_id );

  return OM_S_SUCCESS;
}

method debug ()
{
  om_send_msg ( IGRdir.debug (), my_id, my_id );
  om_send_msg ( DIbstvar.debug (), my_id, my_id );

  return OM_S_SUCCESS;
}


/* The following Globals are transmitted to the DIvr_driver */
static OM_p_CLASSLIST DIR_G_classlist	/* classlist of elements to be listed	*/;
static DIchar	      ***DIR_G_lines	/* buffer to malloc			*/;
static DIgrid	      **DIR_G_grids	/* buffer to malloc			*/;
static DIchar	      DIR_G_options	/* options to be considered		*/;
static DIint          DIR_G_count	/* number of processed itmes		*/;
static DIint          DIR_G_level	/* number of levels in the reg. exp.	*/;

DIvr_driver ( btype, node, dirid, index )
              DIchar  btype	/* type of Btree			IN  */,
                      *node	/* pointer to node			IN  */;
              DIobjid dirid	/* directory objid			IN  */;
	      DIint   index	/* index of the current node		IN  */;
/*
   This driver will be called for each node that has a name that match the
   regular expression.  Some globals are used to exchange the data.
*/
/*.DIvr_driver */
{
  DIchar  *key, buffer [PATH_MAX];
  DIobjid objid;
  DIchar  *data;
  DIint   type;

  if (btype != DIR_D_STRING_POINTER)
    return DIR_E_INVARG;

  /*"dirid : %d, index : %d\n", dirid, index */
  data = node + strlen ( node ) + 1;
  type = *data++;
  key = node;
  if (type == DI_objid)
    memcpy ( &objid, data, sizeof ( DIobjid ) );
  else
    if (DIR_G_options & OPT_SYS)
      return DIR_S_SUCCESS;
    else
      objid = dirid;

  /*"options  : %d, OPT_TRAILER : %d\n", DIR_G_options, OPT_TRAILER */
  if ((key) ? (key [0] != '.') || (DIR_G_options & OPT_ALL) : 1)
  {
    if ((key) && (DIR_G_options & OPT_TRAILER))
    {
      DIchar trailer [PATH_MAX];

      key = buffer;
      strncpy ( key, node, PATH_MAX ) [PATH_MAX - 1] = '\0';
      /*|add the trailer if any */
      DIget_trailer_with_id ( OM_Gw_current_OS, objid, trailer );
      strncat ( key, trailer, PATH_MAX ) [PATH_MAX - 1] = '\0';
    }

    /*^ if (key) printf ( "after trailer, key : '%s'\n", key ); */
    if (DIcheck_class ( DIR_G_classlist, OM_Gw_current_OS, objid ))
    {
      if (DIR_G_grids)
      {
        DIgrid grid;

        grid.osnum = OM_Gw_current_OS;
        grid.objid = objid;
        DIadd_grid ( DIR_G_grids, DIR_G_count, grid );
      }

      if (DIR_G_lines)
        DIadd_line ( DIR_G_lines, DIR_G_count, key );
      DIR_G_count++;
    }
  }

  return DIR_S_SUCCESS;
}


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

  /*"the regular expression is : '%s'\n", (reg_exp) ? reg_exp : "*" */
  DIR_G_classlist = classlist;  DIR_G_lines     = lines;
  DIR_G_grids     = grids;      DIR_G_options   = options;
  DIR_G_count     = *count;     DIR_G_level     = DIget_level ( reg_exp );

  if (di$is_regexp ( regexp = (reg_exp) ? reg_exp : "*" ))
  {
    /*|regular expression -> list */
    om_send ( DIstorage.list ( status, reg_exp, count, DIvr_driver ), my_id, my_id );
  }
  else
  {
    DIint  type;
    DIchar *buf;

    /*|not a regular expression -> translate */
    om_send ( DIstorage.get_type ( &type ), my_id, my_id );

    om_send ( DIstorage.retrieve ( status, reg_exp, &buf ), my_id, my_id );
    if (*status == DIR_S_SUCCESS)
      DIvr_driver ( type, buf, my_id, NULL );
  }

  if (*status == DIR_S_SUCCESS)
  {
    *count = DIR_G_count;
    if (DIR_G_count)
      *status = DIR_S_SUCCESS;
    else
      *status = (DIstrcmp (reg_exp, "*")) ? DIR_W_NAME_NOT_FOUND : DIR_I_DIR_EMPTY;
  }

  return OM_S_SUCCESS;
} /* method dump */


method set ( DIint *status; DIchar *ascii )
{
  DIchar name [PATH_MAX], *syntax;
  DIint  i;
  DIdata info;

  /*"ascii: '%s'\n", ascii */
  *status = DIR_S_SUCCESS;
  for (i = 0; ascii [i] != '='; i++)
    name [i] = ascii [i];
  name [i++] = '\0';
  syntax = &(ascii [i]);

  /*"name: '%s', syntax: '%s'\n", name, syntax */
  /*|find out the type */
  if (strchr ( syntax, '\'' ))
  {
    /*|text */
    info.type = DI_char;
    /*|remove the ' */
    info.var.str = &syntax [1];
    syntax [strlen ( syntax ) - 1] = '\0';
  }
  else
    if (strchr ( syntax, ',' ))
    {
      /*|point */
      info.type = DI_point;
      sscanf ( syntax, "%lf,%lf,%lf",
               &(info.var.p [0]), &(info.var.p [1]), &(info.var.p [2]) );
    }
    else
      if (strchr ( syntax, '.' ))
      {
        /*|double */
        info.type = DI_double;
        sscanf ( syntax, "%lf", &(info.var.d) );
      }
      else
      {
        /*|int */
        info.type = DI_int;
        sscanf ( syntax, "%d", &(info.var.i) );
      }

  om_send ( DIbstvar.store_variable ( status, name, info ),
            NULL_OBJID, my_id );
  if (*status == DIR_E_NAME_DUP)
  {
    om_send ( DIbstvar.change_variable ( status, name, info ),
              NULL_OBJID, my_id );
    if (*status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "DIbstvar.change_variable" );
  }

  return OM_S_SUCCESS;
}


end implementation DIvariable;

