/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   variable sub-system.  Note that an empty B-tree does not require
   any space but a pointer and a variable array descriptor.

   The key is a string and the date is a variable (see DItypedef.h).

   
   HISTORY :
   -------

   11/10/1988 : H. BEQUET - Creation Date.
*/

class implementation DIbstvar;

#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIomac.h"

#define DEBUG 

method get_type ( DIint *type )
{
  *type = DIR_D_STRING_POINTER;

  return OM_S_SUCCESS;
}

extern DIint DIvar_sizes []/* variable sizes		*/;
extern DIchar *DIbstob_mem /* last accessed string 	*/;

method store_variable ( DIint *status; DIchar *key; DIdata info )
{
  DIchar *node, *data;

  /*|malloc node */
  if (info.type == DI_char)
  {
    /*|char-->malloc the size of the string */
    DImalloc ( node, DIchar *, strlen ( key ) + strlen ( info.var.str ) + 3,
               DIR_E_ABORT );
  }
  else
    if (info.type == DI_app)
    {
      /*|application data->malloc name + type + size + data */
      DImalloc ( node, DIchar *,
                 strlen ( key ) + 2 + sizeof ( DIint ) + info.var.app.size,
                 DIR_E_ABORT );
    }
    else
    {
      /*|not char-->fixed size malloc */
      DImalloc ( node, DIchar *, strlen ( key ) + 2 + DIvar_sizes [info.type],
                 DIR_E_ABORT );
    }

  /*"key: '%s', info points to variable (type: %d)\n", key, info.type */
  DIstrcpy ( node, key );
  data = node + strlen ( key ) + 1;
  DIbstob_mem = node;

  /*|move the type */
  *data++ = info.type;

  /*|move the data */
  switch (info.type)
  {
    case DI_app: memcpy ( data, &(info.var.app.size), sizeof ( DIint ) );
                 data += sizeof ( DIint );
                 memcpy ( data, info.var.app.data, info.var.app.size );
                 break;
    case DI_char: strcpy ( data, info.var.str );
                  break;
    case DI_objid: memcpy ( data, &info.var.objid, sizeof ( DIobjid ) );
                   break;
    case DI_int: memcpy ( data, &info.var.i, sizeof ( DIint ) );
                 break;
    case DI_double: memcpy ( data, &info.var.d, sizeof ( DIdouble ) );
                    break;
    case DI_point: memcpy ( data, info.var.p, 3 * sizeof ( DIdouble ) );
                   break;
    default: /*|Illegal data type */
             *status = DIR_E_INVARG;
             return OM_S_SUCCESS;
  }

  om$send ( msg      = message DIbst.add ( status, (char *)node ),
            targetid = my_id );

  if (DIR_S_SUCCESS != *status)
  {
    /*|Problem ... */
    DIfree ( node );
  }

  return OM_S_SUCCESS;
}



method retrieve_variable ( DIint *status; DIchar *key; DIdata *p_info )
{
  DIchar *buffer;

  om$send ( msg      = message DIbst.retrieve ( status, key, &buffer ),
            targetid = my_id );

  if (DIR_S_SUCCESS == *status)
    if (p_info)
    {
      DIchar *data;

      data = buffer + strlen ( key ) + 1;
      p_info->type = *data++;
      /*"type is: %d\n", p_info->type */
      /*|move the data */
      switch (p_info->type)
      {
        case DI_app: memcpy ( &(p_info->var.app.size), data, sizeof ( DIint ) );
                     data += sizeof ( DIint );
                     memcpy ( p_info->var.app.data, data, p_info->var.app.size );
                     break;
        case DI_char: p_info->var.str = data;
                      break;
        case DI_objid: memcpy ( &(p_info->var.objid), data, sizeof ( DIobjid ) );
                       break;
        case DI_int: memcpy ( &(p_info->var.i), data, sizeof ( DIint ) );
                     break;
        case DI_double: memcpy ( &(p_info->var.d), data, sizeof ( DIdouble ) );
                        break;
        case DI_point: memcpy ( p_info->var.p, data, 3 * sizeof ( DIdouble ) );
                       break;
        default: /*|Illegal data type (bug ?) */
                 *status = DIR_E_ABORT;
      }
    }
    else
      *status = DIR_E_INVARG;

  return OM_S_SUCCESS;
}


method remove_info ( DIint *status; DIchar *key )
{
  DIchar *buffer;

  om$send ( msg      = message DIbst.remove ( status, key, &buffer ),
            targetid = my_id );

  if (*status == DIR_S_SUCCESS)
  {
    extern DIchar *DIbstob_mem;

    DIbstob_mem = NULL;
    DIfree ( buffer );
  }

  return OM_S_SUCCESS;
}


method change_variable ( DIint *status; DIchar *key; DIdata info )
{
  DIchar *buffer;
  DIint  index;

  *status = DIBfind ( key, &buffer, me->tree, &index );
  if (DIR_S_SUCCESS == *status)
  {
    DIchar *data;

    if (buffer [strlen ( buffer ) + 1] == DI_objid)
    {
      printf ( "The untree MUST be updated\n" );
    }
    /*|realloc buffer */
    if (info.type == DI_char)
    {
      /*|char-->malloc the size of the string */
      DIrealloc ( buffer, DIchar *, strlen ( key ) + strlen ( info.var.str ) + 3,
                  DIR_E_ABORT );
    }
    else
      if (info.type == DI_app)
      {
        /*|char-->malloc name + type + size + sizeof data */
        DIrealloc ( buffer, DIchar *,
                    strlen ( key ) + 2 + sizeof ( DIint ) + info.var.app.size,
                    DIR_E_ABORT );
      }
      else
      {
        /*|not char-->fixed size malloc */
        DIrealloc ( buffer, DIchar *, strlen ( key ) + 2 + DIvar_sizes [info.type],
                    DIR_E_ABORT );
      }

    /*"key: '%s', info points to variable (type: %d)\n", key, info.type */
    data = buffer + strlen ( key ) + 1;

    /*|move the type */
    *data++ = info.type;

    /*|move the data */
    switch (info.type)
    {
      case DI_app: memcpy ( data, &(info.var.app.size), sizeof ( DIint ) );
                   data += sizeof ( DIint );
                   memcpy ( data, info.var.app.data, info.var.app.size );
                   break;
      case DI_char: strcpy ( data, info.var.str );
                    break;
      case DI_objid: memcpy ( data, &info.var.objid, sizeof ( DIobjid ) );
                     /*|NEED to be put in untree */
                     break;
      case DI_int: memcpy ( data, &info.var.i, sizeof ( DIint ) );
                   break;
      case DI_double: memcpy ( data, &info.var.d, sizeof ( DIdouble ) );
                      break;
      case DI_point: memcpy ( data, info.var.p, 3 * sizeof ( DIdouble ) );
                     break;
    }

    /*|update the B-tree */
    me->tree->data [index] = buffer;
  }

  return OM_S_SUCCESS;
}



method list ( DIint *status; DIchar *reg_exp; DIint *count; DIint (*driver) () )
{
  char reg [PATH_MAX], **reg_buffer;
  int  i, counter, reg_count;

  *status = DIR_S_SUCCESS;

  if (reg_exp)
    if (reg_exp [0])
      strncpy ( reg, reg_exp, PATH_MAX ) [PATH_MAX - 1] = '\0';
    else
      strcpy ( reg, "*" );
  else
    strcpy ( reg, "*" );

  /*"regular expression to be used : '%s'\n", reg */
  /*|Compile the regular expression */
  DImulti_parse ( reg, &reg_buffer, &reg_count );

  for (i = 1, counter = 0; i < me->tree->nfree; i++)
    if (me->tree->data [i])
    {
      /*"processing '%s'\n", me->tree->data [i] */

      if (DImulti_step ( me->tree->data [i], reg_buffer, reg_count ))
      {
        if ((*status = (*driver) ( me->tree->type, me->tree->data [i],
                                   my_id, i - 1 )) != DIR_S_SUCCESS)
          break;
        counter++;
      }
    }

  /* free buffer space */
  for (i = 0; i < reg_count; i++)
    DIfree ( reg_buffer [i] );

  DIfree ( reg_buffer );

  if (count)
    *count = counter;

  return ( OM_S_SUCCESS );
}


DIls_var_driver ( type, node, dirid, index )
                  DIchar  type	/* type of Btree			IN  */,
                          *node	/* pointer to node			IN  */;
                  DIobjid dirid	/* directory objid			IN  */;
     	          DIint   index	/* index of the current node		IN  */;
/*
   This driver will be called for each node that has a name that match the
   regular expression.
*/
/*.DIls_var_driver */
{
  if (type != DIR_D_STRING_POINTER)
    return DIR_E_INVARG;
  else
  {
    DIchar *data;
    DIint  type;

    printf ( "'%s' - ", node );
    data = node + strlen ( node ) + 1;
    type = *data++;

    switch (type)
    {
      case DI_app: printf ( "app - <CANNOT PRINT APPLICATION DATA>" );
                   break;
      case DI_char: printf ( "char - '%s'", data );
                    break;
      case DI_int:  {
                      DIint i;
                      memcpy ( &i, data, sizeof ( DIint ) );
                      printf ( "int - %d", i );
                    }
                    break;
      case DI_objid: {
                       DIobjid objid;
                       memcpy ( &objid, data, sizeof ( DIobjid ) );
                       printf ( "objid - %d", objid );
                     }
                     break;
      case DI_double: {
                        DIdouble d;
                        memcpy ( &d, data, sizeof ( DIdouble ) );
                        printf ( "double - %lf", d );
                      }
                      break;
      case DI_point: {
                       DIdouble p [3];
                       memcpy ( p, data, 3 * sizeof ( DIdouble ) );
                       printf ( "point - (%lf, %lf, %lf)", p [0], p [1], p [2] );
                     }
                     break;
      default: printf ( "illegal data type" ); 
    }

    printf ( "\n" );
  }

  return DIR_S_SUCCESS;
}


method store_info ( DIint *status; DIchar *key; DIobjid info )
{
  DIdata var;

  var.type = DI_objid;
  var.var.objid = info;
  om_send ( DIbstvar.store_variable ( status, key, var ), my_id, my_id );

  return OM_S_SUCCESS;
}



method retrieve_info ( DIint *status; DIchar *key; DIobjid *info )
{
  DIdata var;

  om_send ( DIbstvar.retrieve_variable ( status, key, &var ), my_id, my_id );

  if (*status == DIR_S_SUCCESS)
    if (var.type != DI_objid)
      *status = DIR_E_INVARG;
    else
      *info = var.var.objid;

  return OM_S_SUCCESS;
}


method sleep ( DIint *status, keep )
{
  DIint i, act_size, ptr, om_status, incr;

  *status = DIR_S_SUCCESS;
  if (!me->tree)
  {
    /*|this guy is already asleep ! */
    return OM_S_SUCCESS;
  }

  /* estimate the size : 6 is the average name length */
  act_size = me->tree->nfree * 10	/* that is just an estimate */;
  incr     = 100;
  ptr      = 0;

  om_status = om$vla_set_dimension ( varray = me->buffer, size = act_size );
  if (om_status != OM_S_SUCCESS)
    *status = DIR_E_ABORT;
  else
  {
    int req_space;

    /*"save each active entry in the vla (tree->nfree : %d)\n", me->tree->nfree */
    for (i = 1; i < me->tree->nfree; i++)
      if (me->tree->data [i])
      {
        DIchar *node = me->tree->data [i];
        DIint  name_len, data_len, type;
         

        /*"processing : '%s'\n", node */
        name_len = strlen ( node ) + 1;
        type = node [name_len];
        /*"type: %d\n", type */
        if (type == DI_char)
          data_len = strlen ( &(node [name_len + 1]) ) + 1;
        else
          if (type == DI_app)
          {
            memcpy ( &data_len, &(node [name_len + 1]), sizeof ( DIint ) );
            /*"size of data: %d\n", data_len */
            data_len = sizeof ( DIint ) + data_len;
          }
          else
            data_len = DIvar_sizes [type];

        req_space = name_len + data_len + 1 /* type */;
        if ((req_space + ptr) > act_size)
        {
          int max = (req_space < incr) ? incr : req_space;

          act_size += max;
          /*"reserve more space : %d (%d)\n", max, act_size */
          om_status = om$vla_set_dimension ( varray = me->buffer,
                                             size   = act_size );
          if (om_status != OM_S_SUCCESS)
          {
            /*|aborting */
            *status = DIR_E_ABORT;
            break;
          }
        }

        /*|move everything */
        memcpy ( &(me->buffer [ptr]), node, req_space );
        ptr += req_space;
      }
  }

  /*"adjust vla size : %d\n", ptr */
  om_status = om$vla_set_dimension ( varray = me->buffer, size = ptr );
  if (om_status != OM_S_SUCCESS)
    *status = DIR_E_ABORT;

  if (!keep)
  {
    for (i = me->tree->nfree - 1; i >= 1; i--)
    {
      DIchar *buffer, *node = me->tree->data [i];

      /*|remove info from the btree */
      DIBrm ( node, &buffer, me->tree, NULL );
      /*|free node */
      DIfree ( node );
    }

    /*|free tree */
    DIfree ( me->tree->data );
    DIfree ( me->tree );

    /*me->tree == NULL means that the data are in the vla */
    me->tree = NULL;
  }

  return OM_S_SUCCESS;
}



method wakeup ( DIint *status )
{
  DIint i, size;

  *status = DIR_S_SUCCESS;
  if (!me->tree)
  {
    /*|rebuild the tree */
    om_send ( DIbstvar.init ( status ), my_id, my_id );
    size = om$dimension_of ( varray = me->buffer );
    for (i = 0; (i < size) && (*status == DIR_S_SUCCESS); )
    {
      DIdata var;
      DIchar name [PATH_MAX], *data;
      
      /*"active index: %d (%d)\n", i, me->buffer [i] */
      DIstrcpy ( name, &(me->buffer [i]) );
      i += strlen ( name ) + 1;
      var.type = me->buffer [i++];
      /*"name: '%s', type: %d\n", name, var.type */
      if (var.type == DI_char)
      {
        var.var.str = &(me->buffer [i]);
        i += strlen ( var.var.str ) + 1;
      }
      else
        if (var.type == DI_app)
        {
          memcpy ( &(var.var.app.size), &(me->buffer [i]), sizeof ( DIint ) );
          var.var.app.data = &(me->buffer [i + sizeof ( DIint )]);
          i += var.var.app.size + sizeof ( DIint );
        }
        else
        {
          switch (var.type)
          {
            case DI_int: memcpy ( &(var.var.i), &(me->buffer [i]), DIvar_sizes [var.type] );
                         break;
            case DI_objid: memcpy ( &(var.var.objid), &(me->buffer [i]), DIvar_sizes [var.type] );
                           break;
            case DI_double: memcpy ( &(var.var.str), &(me->buffer [i]), DIvar_sizes [var.type] );
                            break;
            case DI_point: memcpy ( &(var.var.str), &(me->buffer [i]), DIvar_sizes [var.type] );
                           break;
            default: fprintf ( stderr, "DIbstvar.wakeup: Illegal data type\n" );
          }
          i += DIvar_sizes [var.type];
        }

      if (*name)
        {om_send ( DIbstvar.store_variable ( status, name, var ), my_id, my_id );}
      else
        {om_send ( DIbstvar.store_var_index ( status, NULL, var ), my_id, my_id );}
    }
  }

  if (*status == DIR_S_SUCCESS)
  {
    /* these data are no longer needed */
    om$vla_set_dimension ( varray = me->buffer,
                           size   = NULL );
  }

  return OM_S_SUCCESS;
}


/* Access and retrieve variable by index */

method store_var_index ( DIint *status; DIint *index; DIdata info )
{
  *status = DIR_W_NOT_IMPL;

  return OM_S_SUCCESS;
}



method retrieve_var_index ( DIint *status; DIint index; DIchar *name; DIdata *info )
{
  *status = DIR_W_NOT_IMPL;

  return OM_S_SUCCESS;
}


method retrieve_index ( DIint *status; DIint index; DIchar *name; DIobjid *info )
{
  *status = DIR_W_NOT_IMPL;

  return OM_S_SUCCESS;
}


method store_index ( DIint *status; DIint *index; DIobjid info )
{
  *status = DIR_W_NOT_IMPL;

  return OM_S_SUCCESS;
}


method remove_index ( DIint *status; DIint index;
                      DIchar *name; DIobjid *p_objid )
{
  *status = DIR_W_NOT_IMPL;

  return OM_S_SUCCESS;
}


end implementation DIbstvar;
