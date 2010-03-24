class implementation Root;

#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define AS_DEBUG

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

from DIbobpt	import init, retrieve_info, remove_info, remove_dup_info,
                       store_info;

entry ()
/*.entry */
{
  DIint   om_status, status, i, count;
  DIobjid btree_id, objid;
  DIchar  *objname, *dirname, **dirnames, **objnames;

  /*!return 1 */
  DIBinit ();
  
  /*|construct the B-tree */
  om_status = om$construct( classname = "DIbobpt",
                            p_objid   = &btree_id,
                            msg       = message DIbobpt.init ( &status ) ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "B-tree creation" );

  /*|add several synonyms to the b-tree */
  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:lines" );
  strcpy ( objname, "l1" );
  objid = 1;

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:lines" );
  strcpy ( objname, "l2" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:lines" );
  strcpy ( objname, "l3" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:lines" );
  strcpy ( objname, "l4" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr2:lines" );
  strcpy ( objname, "l1" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr2:lines" );
  strcpy ( objname, "l2" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr2:lines" );
  strcpy ( objname, "l3" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr2:lines" );
  strcpy ( objname, "l4" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );


  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:points" );
  strcpy ( objname, "l1" );
  objid = 123;

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:points" );
  strcpy ( objname, "l2" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:points" );
  strcpy ( objname, "l3" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:points" );
  strcpy ( objname, "l4" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr2:points" );
  strcpy ( objname, "l1" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr2:points" );
  strcpy ( objname, "l2" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr2:points" );
  strcpy ( objname, "l3" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr2:points" );
  strcpy ( objname, "l4" );

  om_send ( message DIbobpt.store_info ( &status, objid, dirname, objname ),
            NULL_OBJID, btree_id, "entry->DIbobpt.store_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "store_info", sts = status );

  /*|send a debug to the B-tree */
  om_send ( message DIbobpt.debug (),
            NULL_OBJID, btree_id, "entry->DIbobpt.debug" );

  /*|remove some synonyms */
  dirname = (DIchar *) malloc ( 128 );
  objname = (DIchar *) malloc ( 128 );
  strcpy ( dirname, ":usr1:points" );
  strcpy ( objname, "l2" );
  objid = 123;
  om$send (  msg = message DIbobpt.remove_dup_info ( &status, objid,
                                                     dirname, objname ),
             senderid = NULL_OBJID,
             targetid = btree_id );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send (  message DIbobpt.remove_dup_info ( &status, objid,
                                               ":usr2:points", "l2" ),
             NULL_OBJID, btree_id, "entry->DIbobpt.remove_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send (  message DIbobpt.remove_dup_info ( &status, objid,
                                               ":usr2:points", "l1" ),
             NULL_OBJID, btree_id, "entry->DIbobpt.remove_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send (  message DIbobpt.remove_dup_info ( &status, objid,
                                               ":usr2:points", "l3" ),
             NULL_OBJID, btree_id, "entry->DIbobpt.remove_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send (  message DIbobpt.remove_dup_info ( &status, objid,
                                               ":usr2:points", "l4" ),
             NULL_OBJID, btree_id, "entry->DIbobpt.remove_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send (  message DIbobpt.remove_dup_info ( &status, objid,
                                               ":usr1:points", "l1" ),
             NULL_OBJID, btree_id, "entry->DIbobpt.remove_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send (  message DIbobpt.remove_dup_info ( &status, objid,
                                               ":usr1:points", "l3" ),
             NULL_OBJID, btree_id, "entry->DIbobpt.remove_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send (  message DIbobpt.remove_dup_info ( &status, objid,
                                               ":usr1:points", "l3" ),
             NULL_OBJID, btree_id, "entry->DIbobpt.remove_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send (  message DIbobpt.remove_dup_info ( &status, objid,
                                               ":usr1:points", "l4" ),
             NULL_OBJID, btree_id, "entry->DIbobpt.remove_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "remove_dup_info", sts = status );

  om_send ( message DIbobpt.debug (),
            NULL_OBJID, btree_id, "entry->DIbobpt.debug" );

  /*|retrieve the synonyms */
  objid = 123;
  om_send (  message DIbobpt.retrieve_info ( &status, objid, 
                                             &count, &dirnames, &objnames ),
             NULL_OBJID, btree_id, "entry->DIbobpt.retrieve_info" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "retrieve_info", sts = status );

  printf ( "count : %d\n", count );
  for (i = 0; i < count; i++)
    printf ( "name [%d] : '%s:%s'\n", i, dirnames [i], objnames [i] );

  return 1;
}

end implementation Root;
