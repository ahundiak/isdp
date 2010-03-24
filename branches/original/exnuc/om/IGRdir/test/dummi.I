class implementation dummy;

#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"


method test_pass ( int *Count )
{
  *Count = *Count + 1;
  return OM_S_SUCCESS;
}


method test_connect ( DIobjid his_id )
{
  int  i, status, index, loc_index;
  long clock (), c1, c2, c3;
  OM_S_CHANSELECT chan1, chan2;
  DIobjid objid;


  c1 = clock ();

  /* connect and disconnect my self a thousand times */
  chan1.type = OM_e_name;
  chan1.u_sel.name = "chan";
  chan2.type = OM_e_name;
  chan2.u_sel.name = "chan";

  for (i = 0; i < 1000; i++)
  {
    status = om$send ( mode = OM_e_wrt_object,
                       msg  = message Root.connect ( chan1, NULL, my_id,
                                                     OM_Gw_current_OS, chan2,
                                                     NULL),
                       senderid = my_id,
                       targetid = his_id );
    if((status&1)!=1)
    {
      printf( "om_connect in file %s at line %d (%d)\n", __FILE__, __LINE__, i );
      om$report_error( sts = status );
    }
    else
    {
      OM_S_CHANSELECT chan;
      DIint count;

      chan.type = OM_e_name;
      chan.u_sel.name = "chan";
      status = om$get_channel_count ( objid = his_id,
                                      p_chanselect = &chan, count = &count );
      if (status != OM_S_SUCCESS)
        om$report_error ( sts = status );
      if (count)
      {
        OM_S_OBJECT_LINKAGE *list;

        list = (OM_S_OBJECT_LINKAGE *) malloc ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
        if (list)
        {
          DIint i;

          om$get_channel_objects ( objid = his_id,
                                   p_chanselect = &chan,
                                   list = list, size = count, count = &count );
          if (status != OM_S_SUCCESS)
            om$report_error ( sts = status );
          if (count != 1)
            printf ( "dummy.test_connect: count problem : %d\n", count );
          else
            if (list [0].S_objid != my_id)
              printf ( "dummy.test_connect: incompatibility problem : %d, %d\n",
                       my_id, list [0].S_objid );
        }

        DIfree ( list )
      }
      else fprintf ( stderr, "dummy.test_connect: CAN'T MALLOC\n" );

      status = om$get_channel_count ( objid = my_id,
                                      p_chanselect = &chan, count = &count );
      if (status != OM_S_SUCCESS)
        om$report_error ( sts = status );
      if (count)
      {
        OM_S_OBJECT_LINKAGE *list;

        list = (OM_S_OBJECT_LINKAGE *) malloc ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
        if (list)
        {
          DIint i;

          om$get_channel_objects ( objid = my_id,
                                   p_chanselect = &chan,
                                   list = list, size = count, count = &count );
          if (status != OM_S_SUCCESS)
            om$report_error ( sts = status );
          if (count != 1)
            printf ( "dummy.test_connect: count problem : %d\n", count );
          else
            if (list [0].S_objid != his_id)
              printf ( "dummy.test_connect: incompatibility problem : %d, %d\n",
                       my_id, list [0].S_objid );
        }

        DIfree ( list )
      }
      else fprintf ( stderr, "dummy.test_connect: CAN'T MALLOC\n" );

      status = om$send ( mode = OM_e_wrt_object,
                         msg  = message Root.disconnect ( chan1, my_id,
                                                          OM_Gw_current_OS, chan2 ),
                         senderid = my_id,
                         targetid = his_id );
      if((status&1)!=1)
      {
        printf( "om_disconnect in file %s at line %d\n", __FILE__, __LINE__ );
        om$report_error( sts = status );
      }
    }
  }

  c2 = clock ();
  printf ( "time for 1000 channel connection - retrieve - delete : %2.1lf\n",
           (c2 - c1) * 0.000001 );


  /* add and remove my self from the current a thousand times */
  for (i = 0; i < 1000; i++)
  {
    status = di$add_index ( p_index = &index, objid = my_id );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "dummy.test_connect : add_index" );
    else
    {
      status = di$index ( index = index, p_objid = &objid );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "dummy.test_connect : index" );
      else
      {
        if (objid != my_id)
          printf ( "incompatibility problem : %d - %d\n", my_id, objid );
       
        status = di$untranslate ( objid = my_id, objname = NULL,
                                  p_index = &loc_index );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "dummy.test_connect : untranslate" );
        else
          if (index != loc_index)
            printf ( "index - untrans problem : %d - %d\n", index, loc_index );

        status = di$rm_index ( index = index );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "dummy.test_connect : rm_index" );
      }
    }
  }

  c3 = clock ();
  printf ( "time for 1000 add index - index - remove by index : %2.1lf\n",
           (c3 - c2) * 0.000001 );

  return OM_S_SUCCESS;
}

end implementation dummy;
