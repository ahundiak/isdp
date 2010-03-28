class implementation Root;

#include <stdio.h>
#include <string.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"
#include "exmacros.h"

#define RASTER_COMPONENT    0
#define COMMAND_COMPONENT   1
#define BOTH_COMPONENT      2

#define TRUE     1
#define FALSE    0

%safe
static ras_loaded = 0;
static cmd_loaded = 0;
%endsafe

from global_class import wake_up;

void IMload_raster_component()
{
  IGRint	status;
  IGRint	done;
  IGRint	i;
  IGRint       	OMmsg;
  IGRchar      	path[132];
  IGRchar	filename[132];
  FILE	    	*fp;
  IGRchar	*filelist[2];
  IGRchar	*prodlist[2];
  IGRchar	*pathlist[2];
  struct GRid	mgr_id;
  struct GRid   mod;
  IGRshort     	is_ras_loaded = 0;
  IGRshort     	is_cmd_loaded = 0;

  extern void IMcheck_dload_status(IGRshort, IGRshort *, IGRshort *);
  extern void IMreset_dload_status(IGRshort);

  fp = 0;		/* Initialize file pointer */

  IMcheck_dload_status(RASTER_COMPONENT, &is_ras_loaded, &is_cmd_loaded);
  if( is_ras_loaded )
  {
#ifdef DEBUG
    printf("Raster component has already been loaded\n");
#endif
    goto wrapup;
  }
   
/*  loop until the stop process is found     */
  status = TRUE;
  done = FALSE;

  for (i = 0; ((status == TRUE) && (done == FALSE)); i++)
  {
    if (status = ex$get_path(index=i, 
                             path = path,
			     type = EX_PRODUCT_PATH,
			     len = sizeof(path)))	    
    {
      strcat(path,"raster/");

      sprintf(filename, "%sconfig/dload/raster/", path);
#if defined( SUNOS )
      strcat(filename, "grraster.so");
#elif defined( SUNOS5 )
      strcat(filename, "grraster.so");
#elif defined( IRIX )
      strcat(filename, "grraster.so");
#elif defined( IRIX5 )
      strcat(filename, "grraster.so");
#elif defined( CLIX )
      strcat(filename, "grraster.o");
#else
#error: A system type must be defined
#endif

      if (fp = fopen(filename,"r"))
      {
        done = TRUE;
      }
    }
  }

  if (done)
  {
    fclose(fp);
    filelist[0] = filename;
    filelist[1] = 0;
    prodlist[0] = "Imagerast";
    prodlist[1] = 0;
    pathlist[0] = path;	/* config and config/dload/port directories will be */
    pathlist[1] = 0;	/* delivered under $GRNUC/raster/config/dload/..    */

#ifdef DEBUG
    printf("dyn loading %s\n",filelist[0]);
#endif
    som_dload_class(filelist, prodlist, pathlist);

    ex$get_cur_mod(id = &mod.objid,
                   osnum = &mod.osnum);

    OMmsg = ex$get_super(mod_id = mod.objid, mod_osnum = mod.osnum,
   		         super_name = "Rastfile Mgr",
		         super_class = "GRfrastmgr",
		         create = FALSE,
		         super_id = &mgr_id.objid, 
		         super_osnum = &mgr_id.osnum);

     if (OMmsg & 1)
     {
#ifdef DEBUG
       printf("sending wakeup to id = %d, osnum = %d\n",
  	       mgr_id.objid,mgr_id.osnum);
#endif
       om$send(msg = message global_class.wake_up(),
               senderid = NULL_OBJID,
       	       targetid = mgr_id.objid,
	       targetos = mgr_id.osnum);
#ifdef DEBUG
       printf("return from wakeup\n");
#endif
     }
  }
  else
  {
#ifdef DEBUG
    printf("Could not determine location of Raster component\n");
#endif
    IMreset_dload_status(RASTER_COMPONENT);
  }
wrapup:
;
}

void IMload_command_component()
{
  IGRint	status;
  IGRint	done;
  IGRint	i;
  IGRint       	OMmsg;
  IGRchar      	path[132];
  IGRchar	filename1[132];
  IGRchar	filename2[132];
  FILE	    	*fp;
  IGRchar	*filelist[3];
  IGRchar	*prodlist[3];
  IGRchar	*pathlist[3];
  struct GRid	mgr_id;
  struct GRid	mod;
  IGRshort   	is_ras_loaded = 0;
  IGRshort   	is_cmd_loaded = 0;

  extern void IMcheck_dload_status(IGRshort, IGRshort *, IGRshort *);
  extern void IMreset_dload_status(IGRshort);

  fp = 0;		/* Initialize file pointer */

  IMcheck_dload_status(BOTH_COMPONENT, &is_ras_loaded, &is_cmd_loaded);
  if( is_ras_loaded && is_cmd_loaded )
  {
#ifdef DEBUG
    printf("Raster and Command components have already been loaded\n");
#endif
    goto wrapup;
  }
   
/*  loop until the stop process is found     */
  status = TRUE;
  done = FALSE;

  for (i = 0; ((status == TRUE) && (done == FALSE)); i++)
  {
    if (status = ex$get_path(index=i, 
			     path = path, 
			     type = EX_PRODUCT_PATH,
			     len = sizeof(path)))
    {
      strcat(path,"raster/");

      sprintf(filename1, "%sconfig/dload/raster/", path);
      sprintf(filename2, "%sconfig/dload/raster/", path);

#if defined( SUNOS )
      strcat(filename1,"grraster.so");
      strcat(filename2,"cmdraster.so");
#elif defined( SUNOS5 )
      strcat(filename1,"grraster.so");
      strcat(filename2,"cmdraster.so");
#elif defined( IRIX )
      strcat(filename1,"grraster.so");
      strcat(filename2,"cmdraster.so");
#elif defined( IRIX5 )
      strcat(filename1,"grraster.so");
      strcat(filename2,"cmdraster.so");
#elif defined( CLIX )
      strcat(filename1,"grraster.o");
      strcat(filename2,"cmdraster.o");
#else
#error: A system type must be defined
#endif

      if (fp = fopen(filename2,"r"))
      {
        done = TRUE;
      }
    }
  }

  if (done)
  {
    fclose(fp);
    if( is_ras_loaded )
    {
       filelist[0] = filename2;
       filelist[1] = 0;
       prodlist[0] = "Imagecmd";
       prodlist[1] = 0;
       pathlist[0] = path;/* config and config/dload/port directories will be */
       pathlist[1] = 0;   /* delivered under $GRNUC/config/dload/raster       */
#ifdef DEBUG
       printf("dyn loading %s\n",filelist[0]);
#endif
    }
    else
    {
      filelist[0] = filename1;
      filelist[1] = filename2;
      filelist[2] = 0;
      prodlist[0] = "Imagerast";
      prodlist[1] = "Imagecmd";
      prodlist[2] = 0;
      pathlist[0] = path; /* config and config/dload/port directories will be */
      pathlist[1] = path; /* delivered under $GRNUC/config/dload/raster       */
      pathlist[2] = 0;
 
#ifdef DEBUG
      printf("dyn loading %s\n",filelist[0]);
      printf("dyn loading %s\n",filelist[1]);
#endif
    }

    som_dload_class(filelist, prodlist, pathlist);   
                
    if( !is_ras_loaded )
    {
      ex$get_cur_mod(id = &mod.objid, 
                     osnum = &mod.osnum);

      OMmsg = ex$get_super(mod_id = mod.objid, mod_osnum = mod.osnum,
  		            super_name = "Rastfile Mgr",
		            super_class = "GRfrastmgr",
			    create = FALSE,
			    super_id = &mgr_id.objid, 
			    super_osnum = &mgr_id.osnum);

      if (OMmsg & 1)
      {
#ifdef DEBUG
        printf("sending wakeup to id = %d, osnum = %d\n",
		mgr_id.objid,mgr_id.osnum);
#endif
        om$send(msg = message global_class.wake_up(),
                    senderid = NULL_OBJID,
		    targetid = mgr_id.objid,
		    targetos = mgr_id.osnum);
#ifdef DEBUG
        printf("return from wakeup\n");
#endif
      }
    }
  }
  else
  { 
#ifdef DEBUG
    printf("Could not determine location of Command component\n");
#endif
    IMreset_dload_status(COMMAND_COMPONENT);
  }

wrapup:
;
}


void IMcheck_dload_status(IGRshort flag, IGRshort *raster, IGRshort *command)
/* 0 - flag denotes dload status of raster component is to be checked */
/* 1 - flag denotes dload status of command component is to be checked */
/* 2 - flag denotes dload status of both components is to be checked */
/* TRUE/FALSE - returned in raster/command denoting load status of each */
{
  switch( flag )
  {
    case RASTER_COMPONENT: /* Has the raster component been loaded? */
    {
      *raster = ras_loaded;
       ras_loaded = TRUE;
      break;
    }

    case COMMAND_COMPONENT: /* Has the raster component been loaded? */
    {
      *command = cmd_loaded;
      cmd_loaded = TRUE;  /* If command is not loaded, the raster component*/
      ras_loaded = TRUE;  /* will be loaded, followed by the cmd component */
      break;
    }

    case BOTH_COMPONENT: /* Has both components been loaded? */
    {
      *raster  = ras_loaded;
      *command = cmd_loaded;

      cmd_loaded = TRUE;  /* If command is not loaded, the raster component*/
      ras_loaded = TRUE;  /* will be loaded, followed by the cmd component */
      break;
    }
  }
}

void IMreset_dload_status(IGRshort component)
/* 0 - flag denotes reset dload status of raster component */
/* 1 - flag denotes reset dload status of command component */
/* 2 - flag denotes reset dload status of both components  */
{
  switch( component )
  {
    case RASTER_COMPONENT:
    {
       ras_loaded = FALSE;
      break;
    }

    case COMMAND_COMPONENT: 
    {
      cmd_loaded = FALSE;
      break;
    }

    case BOTH_COMPONENT: 
    {
      cmd_loaded = FALSE;
      ras_loaded = FALSE;
      break;
    }
  }
}

end implementation Root;
