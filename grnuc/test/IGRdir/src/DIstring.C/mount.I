class implementation Root;

#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#define MAX_MOUNT 10

from OMFiledOS import write;
main14 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


tst_mount ( logical, bad )
            DIchar *logical;
            DIint  bad;
/*
   This routine is supposed to test the mount feature. Mounting the same
   OS several times as well as defining links is tested.
*/
/*.tst_mount */
{
  DIint      status, om_status, i;
  DIchar     dirname [DI_PATH_MAX];
  DIobjid    objid, osid;
  DIspacenum osnum;

  /*- */
  /*"logical name : '%s'\n", logical */
  if (bad == 0)      	/*   Good input from link.in   */
  {
    /*|test 1 mount + several links */
    DIload ( "ref.dgn", &osnum, &osid, logical );

    for (i = 0; i < MAX_MOUNT; i++)
    {
      sprintf ( dirname, "%s_%d", logical, i );
      /*"linking '%s' to '%s'\n", logical, dirname */
      status = di$link ( objname = logical, newname = dirname );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: link" );
    }

    /*|add a name in one of them */
    om_status = om$construct(osnum     = osnum,
                             classname = "GRgraphics",
                             p_objid   = &objid ); 
    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );

    sprintf ( dirname, "%s:%s", logical, "first" );
    status = di$add_name ( objname = dirname, objid = objid );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_mount: add_name" );

    for (i = 0; i < MAX_MOUNT; i++)
    {
      DIchar tmp [DI_PATH_MAX];
      DIint  syno, j;

      sprintf ( dirname, "%s_%d:%s", logical, i, "first" );
      /*"translate '%s'\n", dirname */
      status = di$translate ( regexp = dirname, p_objid = &objid,
                              p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: translate (1)" );
      /*"untranslate (%d, %d)\n", osnum, objid */
      status = di$untranslate ( objname = tmp, objid = objid, osnum = osnum,
                                ptr = &syno );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: untranslate (1)" );
      for (j = 0; j < syno; j++)
      {
        DIspacenum loc_osnum;
        DIobjid    loc_objid;

        status = di$untranslate ( objname = tmp, objid = objid,
                                  index = j, osnum = osnum );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_mount: untranslate (2)" );

        /*"translate '%s'\n", tmp */
        status = di$translate ( regexp = tmp, p_objid = &loc_objid,
                                p_osnum = &loc_osnum );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_mount: translate (2)" );
        else
          if ((osnum != loc_osnum) || (objid != loc_objid))
            printf ( "mount : grid incompatibility : (%d, %d) - (%d, %d)\n",
                     osnum, objid, loc_osnum, loc_objid );
      }
    }

    /*"delete the object : (%d, %d)\n", osnum, objid */
    om_send_for ( Root.delete ( 1 ), NULL_OBJID, objid, osnum );

    /*|make a directory in one of them */
    sprintf ( dirname, "%s:%s", logical, "first" );
    status = di$mkdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_mount: mkdir" );

    for (i = 0; i < MAX_MOUNT; i++)
    {
      DIchar tmp [DI_PATH_MAX];
      DIint  syno, j;

      sprintf ( dirname, "%s_%d:%s", logical, i, "first" );
      /*"translate '%s'\n", dirname */
      status = di$translate ( regexp = dirname, p_objid = &objid,
                              p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: translate (1)" );
      /*"untranslate (%d, %d)\n", osnum, objid */
      status = di$untranslate ( objname = tmp, objid = objid, osnum = osnum,
                                ptr = &syno );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: untranslate (1)" );
      for (j = 0; j < syno; j++)
      {
        DIspacenum loc_osnum;
        DIobjid    loc_objid;

        status = di$untranslate ( objname = tmp, objid = objid,
                                  index = j, osnum = osnum );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_mount: untranslate (2)" );

        /*"translate '%s'\n", tmp */
        status = di$translate ( regexp = tmp, p_objid = &loc_objid,
                                p_osnum = &loc_osnum );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_mount: translate (2)" );
        else
          if ((osnum != loc_osnum) || (objid != loc_objid))
            printf ( "mount : grid incompatibility : (%d, %d) - (%d, %d)\n",
                     osnum, objid, loc_osnum, loc_objid );
      }
    }

    /*|delete the directory in one of them */
    sprintf ( dirname, "%s_%d:%s", logical, MAX_MOUNT / 2, "first" );
    /*"dirname : '%s'\n", dirname */
    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_mount: rmdir" );

    /*|delete the OS */
    /*-*/
    om_send_for ( OMFiledOS.delete ( 1 ), NULL_OBJID, osid, osnum );

    /*|test if we can access it */
    /*"translate '%s'\n", logical */
    status = di$translate ( regexp = logical, p_objid = &objid,
                            p_osnum = &osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( sts = status,
                        comment = "tst_mount: Good translate !! (1)" );

    sprintf ( dirname, "%s_%d:%s", logical, i, "first" );
    /*"translate '%s'\n", dirname */
    status = di$translate ( regexp = dirname, p_objid = &objid,
                            p_osnum = &osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( sts     = status,
                        comment = "tst_mount: Good translate !! (2)" );



    /*|test several mounts */
    DIload ( "ref.dgn", &osnum, &osid, logical );

    for (i = 0; i < MAX_MOUNT; i++)
    {
      sprintf ( dirname, "%s_%d", logical, i );
      /*"mounting %d as '%s'\n", osnum, dirname */
      status = di$mount ( logical = dirname, osnum = osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: di$mount" );
    }

    /*|add a name in one of them */
    om_status = om$construct(osnum     = osnum,
                             classname = "GRgraphics",
                             p_objid   = &objid ); 
    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );

    sprintf ( dirname, "%s:%s", logical, "first" );
    status = di$add_name ( objname = dirname, objid = objid );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_mount: add_name" );

    for (i = 0; i < MAX_MOUNT; i++)
    {
      DIchar tmp [DI_PATH_MAX];
      DIint  syno, j;

      sprintf ( dirname, "%s_%d:%s", logical, i, "first" );
      /*"translate '%s'\n", dirname */
      status = di$translate ( regexp = dirname, p_objid = &objid,
                              p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: translate (1)" );
      /*"untranslate (%d, %d)\n", osnum, objid */
      status = di$untranslate ( objname = tmp, objid = objid, osnum = osnum,
                                ptr = &syno );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: untranslate (1)" );
      for (j = 0; j < syno; j++)
      {
        DIspacenum loc_osnum;
        DIobjid    loc_objid;

        status = di$untranslate ( objname = tmp, objid = objid,
                                  index = j, osnum = osnum );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_mount: untranslate (2)" );

        /*"translate '%s'\n", tmp */
        status = di$translate ( regexp = tmp, p_objid = &loc_objid,
                                p_osnum = &loc_osnum );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_mount: translate (2)" );
        else
          if ((osnum != loc_osnum) || (objid != loc_objid))
            printf ( "mount : grid incompatibility : (%d, %d) - (%d, %d)\n",
                     osnum, objid, loc_osnum, loc_objid );
      }
    }

    /*"delete the object : (%d, %d)\n", osnum, objid */
    om_send_for ( Root.delete ( 1 ), NULL_OBJID, objid, osnum );

    /*|make a directory in one of them */
    sprintf ( dirname, "%s:%s", logical, "first" );
    status = di$mkdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_mount: mkdir" );

    for (i = 0; i < MAX_MOUNT; i++)
    {
      DIchar tmp [DI_PATH_MAX];
      DIint  syno, j;

      sprintf ( dirname, "%s_%d:%s", logical, i, "first" );
      /*"translate '%s'\n", dirname */
      status = di$translate ( regexp = dirname, p_objid = &objid,
                              p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: translate (1)" );
      /*"untranslate (%d, %d)\n", osnum, objid */
      status = di$untranslate ( objname = tmp, objid = objid, osnum = osnum,
                                ptr = &syno );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_mount: untranslate (1)" );
      for (j = 0; j < syno; j++)
      {
        DIspacenum loc_osnum;
        DIobjid    loc_objid;

        status = di$untranslate ( objname = tmp, objid = objid,
                                  index = j, osnum = osnum );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_mount: untranslate (2)" );

        /*"translate '%s'\n", tmp */
        status = di$translate ( regexp = tmp, p_objid = &loc_objid,
                                p_osnum = &loc_osnum );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_mount: translate (2)" );
        else
          if ((osnum != loc_osnum) || (objid != loc_objid))
            printf ( "mount : grid incompatibility : (%d, %d) - (%d, %d)\n",
                     osnum, objid, loc_osnum, loc_objid );
      }
    }

    /*|delete the directory in one of them */
    sprintf ( dirname, "%s_%d:%s", logical, MAX_MOUNT / 2, "first" );
    /*"dirname : '%s'\n", dirname */
    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_mount: rmdir" );

    /*|delete the OS */
    /*-*/
    om_send_for ( OMFiledOS.delete ( 1 ), NULL_OBJID, osid, osnum );

    /*|test if we can access it */
    /*"translate '%s'\n", logical */
    status = di$translate ( regexp = logical, p_objid = &objid,
                            p_osnum = &osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( sts = status,
                        comment = "tst_mount: Good translate !! (1)" );

    sprintf ( dirname, "%s_%d:%s", logical, i, "first" );
    /*"translate '%s'\n", dirname */
    status = di$translate ( regexp = dirname, p_objid = &objid,
                            p_osnum = &osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( sts     = status,
                        comment = "tst_mount: Good translate !! (2)" );

  }
  else      		/*   Bad input from link.in   */
  {
    /*|try to mount a missing osnum */
    osnum = 0;

    /*|load ref.dgn */
    DIload ( "ref.dgn", &osnum, &osid, logical );

    /*|try to loop */
    status = di$mount ( logical = "ref.dgn:recur", osnum = osnum );
    if (status == DIR_S_SUCCESS)
      printf ( "tst_mount : attempt to loop succeeded !!!\n" );
    else
    {
      /*|try to loop */
      status = di$link ( objname = "ref.dgn", newname = "ref.dgn:recur" );
      if (status == DIR_S_SUCCESS)
        printf ( "tst_mount : attempt to link for loop succeeded !!!\n" );
      else
      {
        /*|try to link to an existing one */
        status = di$link ( objname = "ref.dgn", newname = ":transient" );
        if (status == DIR_S_SUCCESS)
          printf ( "tst_mount : attempt to link succeeded !!!\n" );
      }
    }

  }

  return DIR_S_SUCCESS;
}

end implementation Root;
