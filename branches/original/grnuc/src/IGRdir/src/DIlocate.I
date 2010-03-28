/* #######################    APOGEE COMPILED   ######################## */
class implementation Root;


#include "coimport.h"
#include <OMerrordef.h>
#include <OMminimum.h>
#include <OMmacros.h>
#include <OMprimitives.h>

#include "igrtypedef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#define DEBUG
#include "DIomac.h"

#include <stdio.h>


#ifndef IDRAW
DIlocate ( regexp, function, arg )
	   DIchar *regexp	/* The regular expression		IN  */;
	   DIint  (*function) ()/* The function to be called		IN  */;
	   DIchar *arg		/* The first argument    		IN  */;
/*.DIlocate */
{
  DIint  i, status, count;
  DIchar fullname [DI_PATH_MAX], dirname [DI_PATH_MAX], basename [DI_PATH_MAX];
  DIgrid grid, context;

  /*"regexp : '%s'\n", regexp */
  status = di$start_dump ( regexp = regexp, ptr = &count );
  /*"count : %d\n", count */
  
  for (i = 0; (i < count) && (status == DIR_S_SUCCESS); i++)
  {
    status = di$fetch_dump ( line   = fullname,
                             p_grid = &grid,
                             index  = i );
    if (status == DIR_S_SUCCESS)
    {
      /*"name [%d] : '%s' - (%d, %d)\n", i, fullname, grid.osnum, grid.objid */
      di$split ( pathname = fullname, dirname = dirname, name = basename );
      /*"dirname : '%s', basename : '%s'\n", dirname, basename */

      /*|find the context */
      {
        DIint i;

        context.osnum = (0); context.objid = (OM_S_OBJID)-1;

        /*|look for a guy called ref */
        for (i = strlen ( fullname ) - 1; i >= 0; i-- )
          if (fullname [i - 3] == DIR_G_car_dir)
            if (fullname [i - 2] == 'r')
              if (fullname [i - 1] == 'e')
                if (fullname [i] == 'f')
                   break;
        if (i >= 0)
        {
          for (i += 2; i < strlen ( fullname ); i++)
            if (fullname [i] == DIR_G_car_dir)
              break;
          fullname [i] = '\0';

          /*"found a ref in %d : '%s'\n", i - 3, fullname */
          di$translate ( objname = fullname, p_objid = &context.objid,
                         p_osnum = &context.osnum );
          /*|get the object on the channel */
          {
             OMuint              count;
             OM_S_CHANSELECT     chan;
             OM_S_OBJECT_LINKAGE list [1];

             chan.type = OM_e_name;
             chan.u_sel.name = "to_context";
             om$get_channel_objects ( osnum        = context.osnum,
                                      objid        = context.objid,
                                      p_chanselect = &chan,
                                      list         = list,
                                      size         = 1,
                                      count        = &count );
             /*"context : (%d, %d)\n", list [0].osnum, list [0].S_objid */
             context.osnum = list [0].osnum;
             context.objid = list [0].S_objid;
          }
        }
      }

      /*|call the function */
      status = function ( arg, dirname, basename, grid, context );
    }
  }

  return status;
}
#endif /* IDRAW */



#argsused
DImount_ref ( attach_os, logical, osnum, context )
              DIspacenum attach_os	/* The attachment object space	IN  */;
              DIchar     *logical	/* The logical name		IN  */;
	      DIspacenum osnum		/* Osnum to be mounted		IN  */;
              DIgrid     context	/* The context to connect to	IN  */;
/*.DImount_ref */
{

/*
  DIint  status;
  DIchar logical_name [DI_PATH_MAX];
*/
  /*|bug in change_class --> return */
  return OM_S_SUCCESS;

#if 0
  if (*logical == DIR_G_car_dir)
    di$strcpy ( from = logical, to = logical_name );
  else
  {
    status = DIstmocpy ( logical_name, "ref", NULL, attach_os );
    if (status == DIR_S_SUCCESS)
    {
      /*|make sure that ref exists */
      di$mkdir ( dirname = logical_name );
      status = di$strcat ( to = logical_name, from = logical );
    }
  }

  /*"logical name : '%s'\n", logical_name */
  if (status == DIR_S_SUCCESS)
  {
    DIobjid    dir_id;
    DIspacenum dir_os;

    /*"looking for : '%s'\n", logical_name */
    status = di$translate ( objname = logical_name, p_objid = &dir_id,
                            p_osnum = &dir_os );
    if (status == DIR_W_NAME_NOT_FOUND)
    {
      /*|not there : mount it */
      status = di$mount ( logical = logical_name,
                          osnum   = osnum, classname = "GRlink" );
    }
    else
    {
      DIint      stat;

      /*|was already mounted, change the class */
      stat = om$change_class ( osnum = dir_os, objid = dir_id,
                               classname = "GRlink" );
      if (stat != OM_S_SUCCESS)
      {
        /* fprintf ( stderr, "DImount_ref: change class " ); */
        om$report_error ( sts = stat );
        status = DIR_E_ABORT;
      }
    }

    if (status == DIR_S_SUCCESS)
    {
      DIint           stat;
      OM_S_CHANSELECT chan1, chan2;
      DIspacenum      osnum;
      DIobjid         objid;

      /*|get the link id */
      di$translate ( objname = logical_name,
                     p_osnum = &osnum, p_objid = &objid );

      /*"connect : (%d, %d) - (%d, %d)\n", osnum, objid, context.osnum, context.objid */
      chan1.type = OM_e_name; chan1.u_sel.name = "to_misc";
      chan2.type = OM_e_name; chan2.u_sel.name = "to_context";

      stat = om$send ( mode = OM_e_wrt_object,
                       msg  = message Root.connect ( chan1, NULL, objid,
                                                     osnum, chan2, NULL),
                       senderid = objid,
                       targetid = context.objid,
                       targetos = context.osnum );
      if((stat&1)!=1)
      {
        status = DIR_E_ABORT;
        om$report_error( sts = stat );
      }
    }
  }

  return status;
#endif
}


end implementation Root;
