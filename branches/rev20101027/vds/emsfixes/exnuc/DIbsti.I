/* $Id: DIbsti.I,v 1.2 2001/01/13 00:41:54 hans Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/exnuc/DIbsti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: DIbsti.I,v $
 *	Revision 1.2  2001/01/13 00:41:54  hans
 *	SP16 modifications
 *	
 *
 * History:
 * MM/DD/YY  AUTHOR     DESCRIPTION
 * 05/14/00  Rama Rao   Fixed a problem where user can not bring up a file.
 *                      TR#179901524
 * -------------------------------------------------------------------*/
/*
   ABSTRACT :
   --------

   This class implements a B-tree.  It has been written for the
   directory sub-system (IGRdir).

   This class is a private class.
*/

class implementation DIbst;

#include <stdio.h>
#include <memory.h>
#include <string.h>
#if defined (SYSV) || defined (BSD)
#include <search.h>
#endif

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "DIprims.h"
#include "DIdef.h"
#include "DIglob.h"

static DIchar **DIBcur_index, *DIBcur_buffer, *DIBcur_string;

static DIint DIBdecr_index;

static void DIBdecr ( p, ord, level )
                      DIint *p, ord, level;
{ level=0; if ((ord == 0) || (ord == 3)) if ((int)(*p) >= DIBdecr_index) (*p)--; }


#define DEBUG
#include "DIomac.h"

DIBcomp_strings ( p1, p2 )
                  int p1, p2   /* The strings to be compared     IN */;
{

/* Start VDS Correction - Rama Rao */
  if( p2 < 0 ) return -1;
/* End VDS Correction - Rama Rao */

  return strcmp (
  ((p1 >= 0) ? &DIBcur_buffer [(int)DIBcur_index [p1]] :
   DIBcur_string), &DIBcur_buffer [(int)DIBcur_index [p2]] );
}


method wakeup ( DIint *status )
{
  if (!my_tree)
  { DIint   i, j, k, count, limit;
    DIchar  my_name [DI_PATH_MAX], /* *ptr_dir, */  *objname;
    DIobjid info;

    /* init myself and create data and the B-tree */
    om_send_me ( DIstorage.init ( status ) );

    /* convert to 1.3.X representation -> will be deleted in 2.0 */
    if (my_buf_size ())
    {
      DIint  len;

      /* remove the ':' put in 1.2.0 and converter		*/
      for (i = 0; i < (DIint) my_buf_size (); i += len + my_size )
      {
        len = strlen ( &my_buf [i] ) + 1;
        if (my_buf [i] == DIR_G_car_dir && !my_buf [i + 1])
        {
          len--;
          for (j = i; j < (DIint) my_buf_size () - 1; j++)
            my_buf [j] = my_buf [j + 1];
          set_buf_size ( my_buf_size () - 1 );
        }
      }

      for (i = 0; i < (DIint) my_buf_size (); i += len + my_size )
      { len = strlen ( &my_buf [i] ) + 1;
        memcpy ( (char *) &info, (char *) &my_buf [i + len], (int) my_size );
        for (j = i + len - 1; j >= i; j--)
          my_buf [j + my_size] = my_buf [j];
        memcpy ( (char *) &my_buf [i], (char *) &info, (int) my_size );
      }
    }

    /* untranslate me */
    di$start_untrans ( objid = my_id, ptr = &count );

    for ( i = my_size, limit = my_buf_size (); i < limit; my_free++, i += strlen ( &my_buf [i] ) + my_size + 1 )
    { DIrealloc ( my_data, DIint *, (my_free + 1) * sizeof ( DIint ) );
      my_data [my_free] = i;
      if (my_free >= B_TREE_LIMIT)
      { if (my_free == B_TREE_LIMIT)
        { /* add the existing ones in the B-tree */
          for (j = 0; j < B_TREE_LIMIT; j++)
            if (my_buf [my_data [j]]) btree_add ( j ); }
        if (*ind_nm ( my_free )) btree_add ( my_free ); }

      /* update the untree */
      for (memcpy ( (char *) &info, (char *) index_id ( my_free ),
         (int) my_size ), k = 0, objname = ind_nm ( my_free ); k < count; k++)
      { di$fetch_untrans ( index = k, objname = my_name );
        /* update the untranslate tree */
        DIunall ( OM_Gw_current_OS, info, my_name, objname, 0, NULL, NULL ); }
      /* set the object's bit: this guy has a name */
      OM_DI_SET ( OM_Gw_current_OS, info ); }}

  return OM_S_SUCCESS;
}

method sleep ( DIint *sts, keep )
{
  *sts = DIR_S_SUCCESS;
  if (!keep)
  { DIint i, j;

    /* get rid of the B-tree ? */
    if (my_root)
      for (DIBcur_index = (DIchar **) my_data,
           DIBcur_buffer = &me->buffer[0],
           i = (DIint) (my_free - 1); i >= 0 ; i--)
        if (*(DIBcur_string = ind_nm ( i ))) tdelete ((void *) -1, (void **) &my_root, my_cmp );

    /* convert to 1.2.X representation -> will be deleted in 2.0 */
    if (my_buf_size ())
    { DIint   len;
      DIobjid info;

      for (i = 0; i < (DIint) my_buf_size (); i += len + my_size )
      { len = strlen ( &my_buf [i + my_size] ) + 1;
        memcpy ( (char *) &info, (char *) &my_buf [i], (int) my_size );
        for (j = i; j < i + len; j++)
          my_buf [j] = my_buf [j + my_size];
        memcpy ( (char *) &my_buf [i + len], (char *) &info, (int) my_size ); }}

    /* get rid of the index and the descriptor */
    DIfree ( my_data );
    DIfree ( my_tree ); }

  return OM_S_SUCCESS;
}


method store_info ( DIint *sts; DIchar *key, *info; DIint *p_index )
{
  DIint   i, fin = my_buf_size ();
  DIint   len = (key) ? strlen ( key ) : 0;

  if (key)
  { /* look if already there */
    om_send_me ( DIbst.retrieve_info ( sts, key, 0, NULL, NULL, NULL ) );
    if (*sts == DIR_S_SUCCESS)
    { *sts = DIR_E_NAME_DUP;
      return OM_S_SUCCESS; }}
  if (p_index) *p_index = my_free;
  if ((*sts = set_buf_size ( len + my_size + 1 + fin ))== DIR_S_SUCCESS)
  { strcpy ( (char *) memcpy(&my_buf [fin], info, my_size ) + my_size,
             (key) ? key : "" );
    /* add it to the index */
    DIrealloc ( my_data, DIint *, (my_free + 1) * sizeof ( DIint ) );
    my_data [my_free++] = fin + my_size;
    if (my_free >= B_TREE_LIMIT)
    { if (my_free == B_TREE_LIMIT)
        /* add the existing ones in the B-tree */
        for (i = 0; i < B_TREE_LIMIT; i++)
          if (my_buf [my_data [i]]) btree_add ( i ); }
    /* add the name into the B-tree ? */
    if (key && my_root) btree_add ( my_free - 1 );

    /* add the node in the untree */
    if (my_size == sizeof ( DIobjid ))
    { DIint   i, count;
      DIchar  my_name [DI_PATH_MAX];
      DIobjid objid;

      memcpy ( (char *) &objid, (char *) info, (int) my_size );
      /* untranslate me */
      di$start_untrans ( objid = my_id, ptr = &count );
      for (i = 0; i < count; i++)
      { di$fetch_untrans ( index = i, objname = my_name );
        /* update the untranslate tree */
        DIunall ( OM_Gw_current_OS, objid, (*my_name) ? my_name : "",
                  &my_buf[my_data [my_free - 1]], 0, NULL, NULL ); }
      /* set the object's bit: this guy has a name */
      OM_DI_SET ( OM_Gw_current_OS, objid ); }}

  return OM_S_SUCCESS;
}


method retrieve_info ( DIint *sts; DIchar *key; DIint ind;
                       DIchar *info; DIchar *name; DIint *p_ind )
/* This method is used to retrieve an entry from the tree */
{
  DIint index = ind;

  *sts = DIR_S_SUCCESS;
  if (key)
    if (my_root)
      btree_get ( key, index )
    else
      for (index = 0; index < my_free; index++)
        if (!strcmp ( ind_nm ( index ), key )) break;
  if (index < 0)
    *sts = DIR_W_NAME_NOT_FOUND;
  else
    if (index >= my_free)
      *sts = (key) ? DIR_W_NAME_NOT_FOUND : DIR_E_OVFLOW;
    else
    { my_last = index;
      if (info) memcpy ( info, index_id ( index ), my_size );
      if (p_ind) *p_ind = index;
      if (name) strcpy ( name, ind_nm ( index ) ); }

  return OM_S_SUCCESS;
}


method remove_info ( DIint *sts; DIchar *key; DIint ind )
{
  DIint   index, deleted, delta = 0;
  DIobjid objid;

  /* find it */
  om_send_me ( DIbst.retrieve_info ( sts, key, ind, (DIchar *)&objid, (DIchar *)NULL, &index ) );
  if (*sts == DIR_S_SUCCESS)
  { /* update untree and object bit */
    DIchar my_name [DI_PATH_MAX];
    DIint  i, syno;

    di$start_untrans ( objid = my_id, ptr = &syno );
    for (i = 0, deleted = 0; i < syno; i++)
    { di$fetch_untrans ( objname = my_name, index = i );
      DIunall ( OM_Gw_current_OS, objid, my_name, ind_nm ( index ), 1, NULL, &deleted ); }
    if (deleted) OM_DI_RESET ( OM_Gw_current_OS, objid );

    /* remove it */
    if (my_root) btree_delete ( index );
    if (index == my_free - 1)
      set_buf_size ( my_data [index] - my_size );
    else
    { delta = my_data [index + 1] - my_data [index];
      memcpy ( index_id (index), index_id (index) + delta, my_buf_size () - my_data [index + 1] + my_size );
      inc_my_buf ( -delta ); }

    for (i = index; i < my_free - 1; i++)
      my_data [i] = my_data [i + 1] - delta;
    DIrealloc ( my_data, DIint *, (my_free--) * sizeof ( DIint ) ); }

  return OM_S_SUCCESS;
}


method list ( DIint *status; DIchar *reg_exp; DIint *count; DIint (*driver) () )
{
  DIchar reg [DI_PATH_MAX], **reg_buffer, *p;
  DIint  i, counter, reg_count, is_star = 0;

  *status = DIR_S_SUCCESS;
  ( (char *) (strncpy ( reg,
            (reg_exp) ? ((*reg_exp) ? reg_exp : "*") : "*",
            DI_PATH_MAX ))) [DI_PATH_MAX - 1] = '\0';

  /* Compile the regular expression */
  if (strcmp ( "*", reg ))
    DImulti_parse ( reg, &reg_buffer, &reg_count );
  else
    is_star = 1;

  for (i = 0, counter = 0; i < my_free; i++)
  {
    p = ind_nm ( i );
    if (is_star ? 1 : (DImulti_step ( p, reg_buffer, reg_count )))
    { if ((*status = (*driver) (my_type,
         index_id(i),
         (*p) ? (((*p == DIR_G_car_dir) && !(*(p+1))) ? NULL : p) : NULL ))
         != DIR_S_SUCCESS)
          break;
        counter++;
    }
  }

  /* free buffer space */
  if (!is_star)
  {
    for (i = 0; i < reg_count; i++)
      DIfree ( reg_buffer [i] );
    DIfree ( reg_buffer );
  }

  if (count) *count = counter;

  return OM_S_SUCCESS;
}


end implementation DIbst;
