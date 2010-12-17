class implementation COpdu;

/*
   This file contains all functions for creating and manipulating a coordinate 
   system used as a graphical representation for part pointers in 2.0. 

   Author: Jamal Shakra 
   Date: 09-09-91
*/


#include        "unistd.h"
#include        "DItypedef.h"
#include        "DIdef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include 	"PDUerror.h"
#include 	"GRpart.h"
#include 	"msdef.h"
#include 	"godef.h"
#include        "csmacros.h"
#include        "PDUintdef.h"
#include        "MEMerrordef.h"
#include        "MEMstruct.h"
#include        "grdpbmacros.h"
#include        "grcoordsys.h"
#include        "csdef.h"
#include        "dpmacros.h"
#include        "dp.h"
#include        "dpdef.h"


/* External variables */
extern     struct GRid  PDU_window_id;


from   GRcoords  import   GRinitialize;
from   GRgencs  import   GRget_oid_from_name;
from   GRgraphics import  GRdelete;
from   GRgraphics import  GRconstruct;
from   IGEgragad  import  DPinrot;


/*
  This function creates a coordinate system. 
*/

IGRint PDUcreate_coorsys (
                          mod_env,               /* module environment */
                          csname,                /* coordinate sys. name. */
                          csdesc,                /* coordinate sys. desc. */
                          csid                   /* coordinate sys. id. */
                         )

 struct GRmd_env  mod_env;		/* INPUT */
 IGRchar          *csname;              /* INPUT */
 IGRchar          *csdesc;              /* INPUT */
 OM_S_OBJID       csid;		        /* OUTPUT */
{
 IGRlong          msg;
 IGRlong          status = PDM_S_SUCCESS;
 struct GRvg_construct constr_list; 
 struct IGRdisplay     ActiveDisplay; 

 _pdm_debug("In the PDUcreate_coorsys function",0);

 msg = MSSUCC;

 /* Initialize structures used to construct a coordinate system */
 constr_list.msg        = &msg;
 constr_list.env_info   = &mod_env;
 constr_list.display    = &ActiveDisplay;
 constr_list.geometry   = NULL;
 constr_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 constr_list.newflag    = FALSE;
 constr_list.name       = NULL;
 constr_list.class_attr = NULL;

 status = om$construct ( 
                        msg = message GRcoords.GRinitialize
                              ( &msg, csname, csdesc, &constr_list ), 
                        osnum = mod_env.md_id.osnum,
                        classname = "GRcoords",
                        p_objid = &csid 
                       );
 _pdm_rstatus2 ("om$construct (GRcoords)", status, msg);

  if ( (1&status) && (1 & msg) )
     {
      _pdm_debug("obj id of coord sys constructed = %d", csid);
     }
   
  else
    {
     _pdm_debug("PDUcreate_coorsys failed",0);
     status = PDM_E_COORSYS;
     return(status);
    }
 
 return(PDM_S_SUCCESS);
}
 
/*
  This function, given a coordinate system name, will return its id . 
*/

IGRint PDUget_coord_sys_id (
                            mod_env,               /* module environment */
                            csname,                /* coordinate sys. name. */
                            csid                   /* coordinate sys. id. */
                           )

 struct GRmd_env  mod_env;		/* INPUT */
 IGRchar          *csname;              /* INPUT */
 GRobjid          *csid;	        /* OUTPUT */
{
 IGRlong          status = PDM_S_SUCCESS;
 IGRint           i;
 IGRint           cs_count = 0;
 IGRchar          **cs_names;
 struct GRid      *cs_objects = NULL;
 OM_p_CLASSLIST   classlist;
 OMuword          classid;
 IGRchar          usr_dir[DI_PATH_MAX];
 IGRchar          regexp[DI_PATH_MAX];
 extern  OMuword  OPP_GRgencs_class_id;


 _pdm_debug("In the function PDUget_coord_sys_id", 0);
  
 _pdm_debug("cs name at entry = <%s>", csname);

 /* Get path to usr directory */
 di$give_pathname(
                  osnum = mod_env.md_id.osnum,
                  pathname = usr_dir
                 );

 strcat(usr_dir,":usr");

 /* Set up calss list info */
 /* Malloc classlist */
 classlist = (struct OM_sd_classlist *) malloc (sizeof
                       (struct OM_sd_classlist));

 /* Initialize certain fields in classlist */
 classlist->w_count = 1;
 classlist->w_flags = OM_CLST_internal;
 classlist->p_classes = &classid;

 /* Get all objects of class GRgencs */
 classid = OPP_GRgencs_class_id;

 strcpy(regexp, usr_dir);
 strcat(regexp, ":*");

 status = di$dump(
                  regexp = regexp,
                  p_classes = classlist,
                  grids = (DIgrid **)&cs_objects,
                  lines = &cs_names,
                  ptr = &cs_count
                 );

 if (!cs_count)
    {
     _pdm_debug("no GRgencs objects were found", 0);
     return(0);
    }

 _pdm_debug("%d coord. sys. were found", cs_count);

 /* Look for a matching cs name, if found, return its id */
 for (i = 0; i < cs_count; ++i)
     {
      /* Get rid off ":" at end of entry */
      PDUstrip_dir_entry(cs_names[i]);

      /* Get rid off "*" at end of entry */
      *((IGRchar *)strrchr(cs_names[i], '*')) = '\0';
      
      _pdm_debug("entry after stripping = <%s>", cs_names[i]);

      if (strcmp(csname, cs_names[i]) == 0)
         {
          _pdm_debug("a match was found", 0);
          
          *csid = cs_objects[i].objid;

          /* Free variables */
          if (cs_names)
             di$free(lines = cs_names, count = cs_count);

          if (cs_objects)
             free(cs_objects);

          _pdm_debug("extracted cs id = %d", *csid);

          return(PDM_S_SUCCESS); 
         }
     } 

 if (i == cs_count)
    {
     _pdm_debug("no match found", 0);

     /* Free variables */
     if (cs_names)
        di$free(lines = cs_names, count = cs_count);

     if (cs_objects)
        free(cs_objects);
    }

 return(0);
}

/*
 * This function loads part view information from object space into the view
 * buffer. 
 */

IGRint PDUload_view_info (
                          osid,                /* obj space id */
                          osnum,               /* osnum */
                          view_buffer          /* part view buffer */
                         ) 

 OM_S_OBJID       osid;                 /* INPUT */
 OMuword          osnum;		/* INPUT */
 MEMptr           *view_buffer;	        /* OUTPUT */
{
 IGRlong          status = PDM_S_SUCCESS;
 IGRint           i, j;
 IGRint           origin_count = 0;
 IGRchar          **origins;
 IGRchar          *tmp1_str = NULL;
 IGRchar          *tmp2_str = NULL;
 IGRchar          origin_dir[DI_PATH_MAX];
 IGRchar          *origin_name = NULL;
 IGRchar          *view_name = NULL;
 IGRchar          orientation[MAX_VALUE];
 IGRchar          *orient_origin = NULL;
 IGRchar          *orient_xpoint = NULL;
 IGRchar          *orient_ypoint = NULL;
 IGRchar          *row = NULL;
 struct  GRid     *origin_ids = NULL;


 _pdm_debug("In the function PDUload_view_info", 0);

 /* Check if need to get active design module info */
  if (osnum == 0)
    {
    /* Get active module info */
    status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
    _pdm_debug("osnum = %d", osnum);
    _pdm_rstatus ("ex$get_cur_mod", status);
    }

 /* Make sure view buffer is empty */
 if (*view_buffer)
    {
     _pdm_debug("view buffer is not empty", 0);
     MEMclose(view_buffer);
     *view_buffer = NULL;
    }

 /* Get the <:filename:usr:ORIGIN *> path */
 di$give_pathname(osnum = osnum, pathname = origin_dir);
 strcat(origin_dir, ":usr");
 _pdm_debug("full search path = <%s>", origin_dir);

 /* Extract list of origin objects from given origin path */
 status = di$find (
                   start_dir = origin_dir,
                   regexp = "ORIGIN *",
                   lines = &origins,
                   grids = (DIgrid **)&origin_ids,
                   max_level = 1,
                   ptr = &origin_count
                  );
 _pdm_debug("%d origins were found", origin_count);

 if (origin_count <= 0)
    {
     _pdm_debug("no origins were found", 0);
     return(PDM_I_ORIGIN_NOT_FOUND);
    }

 /* Create view info buffer */
 status = PDMopen_buffer(3, view_buffer);
 _pdm_status("PDMopen_buffer", status);

 /* Loop in extracting origin name, view name, and orientation. Write view
    info to view buffer */
 for (i = 0; i < origin_count; ++i)
     {
      /* Extract ith origin name */
      _pdm_debug("extracted origin path = <%s>", origins[i]);
      *((IGRchar *)strrchr(origins[i],'*')) = '\0';

      j = strlen(origins[i]) - 1;
      tmp1_str = origins[i]  + j;
      tmp2_str = origins[i];

      while (tmp2_str[j] != ':') 
            {
             --j;
             tmp1_str = tmp1_str - 1;
            } 

      PDUfill_in_string(&origin_name, tmp1_str + 1);
      _pdm_debug("origin name = <%s>", origin_name);

      /* Extract view name */
      PDUfill_in_string(&view_name, tmp1_str + 8);
      _pdm_debug("view_name = <%s>", view_name);

      /* Extract view orientation */
      PDUextract_coord_orientation(
                                   origin_ids[i],
                                   &orient_origin,
                                   &orient_xpoint,
                                   &orient_ypoint
                                  );

      _pdm_debug("orient_origin = <%s>", orient_origin);
      _pdm_debug("orient_xpoint = <%s>", orient_xpoint);
      _pdm_debug("orient_ypoint = <%s>", orient_ypoint);

      /* Construct orientation string */
      *((IGRchar *)strrchr(orient_origin,':')) = '\0';
      *((IGRchar *)strrchr(orient_xpoint,':')) = '\0';
      *((IGRchar *)strrchr(orient_ypoint,':')) = '\0';
      sprintf(
              orientation,
              "%s!%s!%s",
              orient_origin,
              orient_xpoint,
              orient_ypoint
             );

      _pdm_debug("orientation = <%s>", orientation);

      /* Writre view info to view buffer */
      if (row)
         free(row);

      /* Allocate space for row */
      row = (IGRchar *) malloc (sizeof(IGRchar) * (*view_buffer)->row_size);
      memset(row, NULL, (*view_buffer)->row_size);

      sprintf(
              row,
              "%s\1%s\1%s\1",
              origin_name,
              orientation,
              view_name
             );

      _pdm_debug("row = <%s>", row);
      status = MEMwrite(*view_buffer, row);

      if (status != MEM_S_SUCCESS)
         {
          _pdm_debug("SEVERE error: could not write to view buffer", 0);
          return(status);
         }

     } /* end for loop */

 /* Free variables */
 if (origin_name)
    free (origin_name);

 if (view_name)
    free (view_name);

 if (row)
    free (row);

 if (orient_origin)
    free (orient_origin);

 if (orient_xpoint)
    free (orient_xpoint);

 if (orient_ypoint)
    free (orient_ypoint);

 if (origins)
    di$free(lines = origins, count = origin_count);

 if (origin_ids)
    free(origin_ids);


 return(PDM_S_SUCCESS);
}

/* 
 * This function checks to see if the PDUview saved view exists in the
 * active design.
 */
IGRint  PDUcheck_default_view()
{
 OM_S_OBJID       osid;                
 OMuword          osnum;              
 IGRchar          origin_dir[DI_PATH_MAX];
 IGRint           origin_count = 0;
 IGRlong          status = PDM_S_SUCCESS;

 _pdm_debug("In the PDUcheck_default_view function", 0);

 /* Get active module info */
 status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
 _pdm_rstatus ("ex$get_cur_mod", status);
 
 di$give_pathname(osnum = osnum, pathname = origin_dir);
 strcat(origin_dir, ":views:savedviews:GRsavedviews");
 _pdm_debug("full search path = <%s>", origin_dir);

 /* Check to see if PDUview entry exists */
 status = di$find (
                   start_dir = origin_dir,
                   regexp = "PDUview",
                   max_level = 1,
                   ptr = &origin_count
                  );

 if ( (status == DIR_S_SUCCESS) && (origin_count > 0) )
    {
     _pdm_debug("PDUview saved view exists", 0);
     return(PDM_S_SUCCESS);
    }

 _pdm_debug("PDUview saved view does not exist", 0);

 return(0);
}

/*
 * This function checks to see if there are any origins defined in the
 * active obj space.
 */
IGRint  PDUdo_origins_exist(invis_flag, osnum)
 IGRshort         invis_flag;         /* INPUT */
 OMuword          osnum;              /* INPUT */
{
 IGRlong          status;
 IGRchar          origin_dir[DI_PATH_MAX];
 OM_S_OBJID       osid;
 IGRint           origin_count = 0;
 
 _pdm_debug("In the PDUdo_origins exist function", 0);

 if (!invis_flag)
    {
     /* Get active module info */
     status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
     _pdm_rstatus ("ex$get_cur_mod", status);
    }

 /* Get the <:filename:usr:ORIGIN *> path */
 di$give_pathname(osnum = osnum, pathname = origin_dir);
 strcat(origin_dir, ":usr");
 _pdm_debug("full search path = <%s>", origin_dir);

 /* Extract list of origin objects from given origin path */
 status = di$find (
                   start_dir = origin_dir,
                   regexp = "ORIGIN *",
                   max_level = 1,
                   ptr = &origin_count
                  );

 if ( (origin_count <= 0) || (status != DIR_S_SUCCESS) )
    {
     _pdm_debug("no origins were found", 0);
     return(0);
    }

 return(1);
}

/*
 * This function deletes all PDU origins in a given object space.
 */

IGRint PDUdelete_origins(
                          osid,               /* obj space id */
                          osnum               /* osnum */
                        ) 

 OM_S_OBJID       osid;                 /* INPUT */
 OMuword          osnum;		/* INPUT */
{
 IGRlong          status = PDM_S_SUCCESS;
 IGRlong          msg;
 IGRint           i, j;
 IGRint           origin_count = 0;
 IGRchar          **origins;
 IGRchar          *tmp1_str = NULL;
 IGRchar          *tmp2_str = NULL;
 IGRchar          origin_dir[DI_PATH_MAX];
 IGRchar          file_dir[DI_PATH_MAX];
 IGRchar          view_dir[DI_PATH_MAX];
 IGRchar          *origin_name = NULL;
 IGRchar          *view_name = NULL;
 struct  GRid     *origin_ids = NULL;
 struct GRmd_env  mod_env;
 IGRlong          NumberOfBytes, BytesReceived;


 _pdm_debug("In the function PDUdelete_origins", 0);

 /* Check if need to get active design module info */
  if (osnum == 0)
    {
    /* Get active module info */
    status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
    _pdm_debug("osnum = %d", osnum);
    _pdm_rstatus ("ex$get_cur_mod", status);
    }

 /* Get active module information */
 NumberOfBytes = sizeof(mod_env);
 status = gr$get_module_env(
                            msg = &msg,
                            sizbuf = &NumberOfBytes,
                            buffer = &mod_env,
                            nret = &BytesReceived
                           );

  mod_env.md_id.osnum = osnum;
  mod_env.md_id.objid = osid;

 /* Get the <:filename:usr:ORIGIN *> path */
 di$give_pathname(osnum = osnum, pathname = origin_dir);
 strcat(origin_dir, ":usr");
 _pdm_debug("full search path = <%s>", origin_dir);

 /* Extract list of origin objects from given origin path */
 status = di$find (
                   start_dir = origin_dir,
                   regexp = "ORIGIN *",
                   lines = &origins,
                   grids = (DIgrid **)&origin_ids,
                   max_level = 1,
                   ptr = &origin_count
                  );
 _pdm_debug("%d origins were found", origin_count);

 if (origin_count <= 0)
    {
     _pdm_debug("no origins were found", 0);
     return(PDM_S_SUCCESS);
    }

 /* Loop in extracting origin names and view names. */
 for (i = 0; i < origin_count; ++i)
     {
      /* Extract ith origin name */
      _pdm_debug("extracted origin path = <%s>", origins[i]);
      *((IGRchar *)strrchr(origins[i],'*')) = '\0';

      j = strlen(origins[i]) - 1;
      tmp1_str = origins[i]  + j;
      tmp2_str = origins[i];

      while (tmp2_str[j] != ':') 
            {
             --j;
             tmp1_str = tmp1_str - 1;
            } 

      PDUfill_in_string(&origin_name, tmp1_str + 1);
      _pdm_debug("origin name = <%s>", origin_name);

      /* Extract view name */
      PDUfill_in_string(&view_name, tmp1_str + 8);
      _pdm_debug("view_name = <%s>", view_name);

      /* Delete origin */
      om$send(
              msg = message GRgraphics.GRdelete
                                      (
                                       &msg,
                                       &mod_env
                                      ),
              senderid = osid,
              targetid = origin_ids[i].objid,
              targetos = origin_ids[i].osnum
             );

      /* Delete saved view */
      di$give_pathname(
                       osnum = mod_env.md_id.osnum,
                       pathname = file_dir
                      );

      /* Construct full path to view directory */
      sprintf(
              view_dir,
              "%s:views:savedviews:GRsavedviews:%s",
              file_dir,
              view_name
             );

      _pdm_debug("view full path name = <%s>", view_dir);

      /* Remove saved view name */
      status = di$rm_name ( regexp = view_dir );
      _pdm_status("di$rm_name status", status);

     } /* end for loop */

 /* Free variables */
 if (origin_name)
    free (origin_name);

 if (origin_ids)
    free(origin_ids);

 if (view_name)
    free (view_name);

 if (origins)
    di$free(lines = origins, count = origin_count);


 return(PDM_S_SUCCESS);
}

/*
 * This function creates a PDU origin.
 */

IGRint	PDUcreate_origin(
                         placement_matrix,  /* placement matrix */
                         mod_env,           /* module environment */
                         view_name,         /* view name */
                         cs_desc,           /* coor sys desc */
                         origin,            /* coor sys origin */
                         create_svview,     /* falg for saved view creation */ 
                         csobj              /* cs obj id */
                        )
  IGRmatrix       placement_matrix;	/* INPUT */
  struct GRmd_env mod_env;              /* INPUT */
  IGRchar         *view_name;           /* INPUT */
  IGRchar         *cs_desc;             /* INPUT */
  IGRdouble       origin[3];            /* INPUT */
  IGRshort        create_svview;        /* INPUT */
  struct GRid     *csobj;               /* OUTPUT */
  
 {
  IGRlong	  status = PDM_S_SUCCESS;
  IGRint          i;
  IGRshort        ActiveLevel;
  IGRchar         cs_name[DI_PATH_MAX];
  IGRchar         view_dir[DI_PATH_MAX];
  IGRchar         file_dir[DI_PATH_MAX];
  IGRlong         msg = PDM_S_SUCCESS;
  IGRlong         NumberOfBytes, BytesReceived;
  struct IGRlbsys	lbs_geom;
  struct IGRdisplay     ActiveDisplay;
  struct GRvg_construct p_arglist;
  struct GRcs_construct class_attr;
  

  _pdm_debug("In the PDUcreate_origin function", 0 );

  _pdm_debug("placement matrix:",0);
  PDUdump_matrix(placement_matrix);

  _pdm_debug("osnum at entry = %d", mod_env.md_id.osnum);
  _pdm_debug("osid at entry = %d", mod_env.md_id.objid);
  _pdm_debug("view name at entry = <%s>", view_name);

  /* Get the <:filename:usr:ORIGIN *> path */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = cs_name 
                  );

  /* Get active level */
  ActiveLevel = 1023;

  /* Get active display */
  NumberOfBytes = sizeof(struct IGRdisplay);
  status = gr$get_active_display (
                                  msg = &msg,
                                  sizbuf = &NumberOfBytes,
                                  buffer = &ActiveDisplay,
                                  nret = &BytesReceived
                                 );

  /* Change certain display attributes */
  ActiveDisplay.weight = 0;
  ActiveDisplay.style = 5;

  /* Prefix view name with the word ORIGIN */
  if (view_name)
     {
      strcat(cs_name, ":usr:ORIGIN "); 
      strcat(cs_name, view_name);
     }

  _pdm_debug("coor sys name = <%s>", cs_name);

  /* Initialize structures used to construct a coor sys object */
  p_arglist.msg        = &msg;
  p_arglist.env_info   = &mod_env;
  p_arglist.display    = &ActiveDisplay;
  p_arglist.level      = ActiveLevel;
  p_arglist.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE; 
  p_arglist.newflag    = FALSE;
  p_arglist.name       = cs_name;

  /* Copy placement matrix into lbs */
  for (i = 0; i < 16; ++i) 
      {
       lbs_geom.matrix[i] = placement_matrix[i];
      }

  /* A local bounded system is required for coor sys construction */
  p_arglist.geometry = (IGRchar *) &lbs_geom;

  /* lbs diagonals are design file limits */
  lbs_geom.diag_pt1[0] = 0;
  lbs_geom.diag_pt1[1] = 0;
  lbs_geom.diag_pt1[2] = 0;
  lbs_geom.diag_pt2[0] = 0; 
  lbs_geom.diag_pt2[1] = 0;
  lbs_geom.diag_pt2[2] = 0;

  /* Set up structures for coor sys object construction */
  class_attr.desc = cs_desc;
  class_attr.flag = CS_CONNECT_TO_MGR;
  class_attr.type = RECTANGULAR;

  p_arglist.class_attr = (IGRchar *) &class_attr;

  csobj->osnum = mod_env.md_id.osnum;

  /* Construct coor sys object */
  status = om$construct (
                         classname = "GRgencs", 
                         p_objid = &(csobj->objid),
			 msg = message GRgraphics.GRconstruct (&p_arglist),
			 osnum = mod_env.md_id.osnum 
                        );
  _pdm_rstatus2 ("om$construct (GRconstruct) of GRgencs",
	         status, *(p_arglist.msg) );

  if ( ( 1&status ) && ( *(p_arglist.msg) == MSSUCC ) )
     {
      _pdm_debug("coor sys was created successfully", 0);

      if (create_svview)
         {
          /* Create saved view */
          status = dp$savvw_cons(
                                 msg = &msg,
                                 osnum = &(mod_env.md_id.osnum),
                                 vw_name = view_name,
                                 gg_id = &PDU_window_id,
                                 descript = "ORIGIN",
                                 origin = origin
                                );

          if (msg != MSSUCC)
             {
              _pdm_debug("dp$savvw_cons failed", 0);

              /* Delete coordinate system */
              om$send(
                      msg = message GRgraphics.GRdelete(
                                                        &msg,
                                                        &mod_env
                                                       ),
                      senderid = mod_env.md_id.objid,
                      targetid = csobj->objid,
                      targetos = csobj->osnum
                     );

              /* Delete saved view, if any */
              di$give_pathname(
                               osnum = mod_env.md_id.osnum,
                               pathname = file_dir
                              );

              /* Construct full path to view directory */
              sprintf(
                      view_dir,
                      "%s:views:savedviews:GRsavedviews:%s",
                      file_dir,
                      view_name
                     );

              _pdm_debug("view full path name = %s", view_dir);

              /* Remove saved view name */
              status = di$rm_name ( regexp = view_dir );
              _pdm_status("di$rm_name status", status);

              status = 0;
             }

          else
              {
               _pdm_debug("saved view was created successfully", 0);
               status = PDM_S_SUCCESS;
              }
         }

       else
           status = PDM_S_SUCCESS;
     }

  else
      {
       _pdm_debug("failed to construct coord sys", 0);
       status = 0;
      }

  return (status);
 }

/*
 * This function creates a PDU part pointer.
 */

IGRint  PDUcreate_part_pointer(
                               placement_matrix,  /* placement matrix */
                               mod_env,           /* module environment */
                               usage_id,          /* usage id */
                               cs_desc,           /* coor sys desc */
                               csobj              /* cs obj id */
                              )
  IGRmatrix       placement_matrix;     /* INPUT */
  struct GRmd_env mod_env;              /* INPUT */
  IGRchar         *usage_id;            /* INPUT */
  IGRchar         *cs_desc;             /* INPUT */
  struct GRid     *csobj;               /* OUTPUT */

{
  IGRlong         status = PDM_S_SUCCESS;
  IGRint          i;
  IGRshort        ActiveLevel;
  IGRchar         cs_name[DI_PATH_MAX];
  IGRlong         msg = PDM_S_SUCCESS;
  IGRlong         NumberOfBytes, BytesReceived;
  struct IGRlbsys       lbs_geom;
  struct IGRdisplay     ActiveDisplay;
  struct GRvg_construct p_arglist;
  struct GRcs_construct class_attr;


  _pdm_debug("In the PDUcreate_part_pointer function", 0 );

  _pdm_debug("placement matrix:",0);
  PDUdump_matrix(placement_matrix);

  _pdm_debug("osnum at entry = %d", mod_env.md_id.osnum);
  _pdm_debug("osid at entry = %d", mod_env.md_id.objid);
  _pdm_debug("usage id at entry = <%s>", usage_id);

  /* Get the <:filename> path */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = cs_name
                  );

  /* Get active level */
  ActiveLevel = 1023;

  /* Get active display */
  NumberOfBytes = sizeof(struct IGRdisplay);
  status = gr$get_active_display (
                                  msg = &msg,
                                  sizbuf = &NumberOfBytes,
                                  buffer = &ActiveDisplay,
                                  nret = &BytesReceived
                                 );

  /* Change certain display attributes */
  ActiveDisplay.weight = 0;
  ActiveDisplay.style = 5;

 /* Add usage id to the full name */
  if (usage_id)
     {
      strcat(cs_name, ":usr:");
      strcat(cs_name, usage_id);
     }

  _pdm_debug("coor sys name = <%s>", cs_name);

  /* Initialize structures used to construct a coor sys object */
  p_arglist.msg        = &msg;
  p_arglist.env_info   = &mod_env;
  p_arglist.display    = &ActiveDisplay;
  p_arglist.level      = ActiveLevel;
  p_arglist.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  p_arglist.newflag    = FALSE;
  p_arglist.name       = cs_name;

  /* Copy placement matrix into lbs */
  for (i = 0; i < 16; ++i)
      {
       lbs_geom.matrix[i] = placement_matrix[i];
      }

  /* A local bounded system is required for coor sys construction */
  p_arglist.geometry = (IGRchar *) &lbs_geom;

  /* lbs diagonals are design file limits */
  lbs_geom.diag_pt1[0] = 0;
  lbs_geom.diag_pt1[1] = 0;
  lbs_geom.diag_pt1[2] = 0;
  lbs_geom.diag_pt2[0] = 0;
  lbs_geom.diag_pt2[1] = 0;
  lbs_geom.diag_pt2[2] = 0;

  /* Set up structures for coor sys object construction */
  class_attr.desc = cs_desc;
  class_attr.flag = CS_CONNECT_TO_MGR;
  class_attr.type = RECTANGULAR;

  p_arglist.class_attr = (IGRchar *) &class_attr;

  csobj->osnum = mod_env.md_id.osnum;

 /* Construct coor sys object */
  status = om$construct (
                         classname = "GRgencs",
                         p_objid = &(csobj->objid),
                         msg = message GRgraphics.GRconstruct (&p_arglist),
                         osnum = mod_env.md_id.osnum
                        );
  _pdm_rstatus2 ("om$construct (GRconstruct) of GRgencs",
                 status, *(p_arglist.msg) );

  if ( ( 1&status ) && ( *(p_arglist.msg) == MSSUCC ) )
     {
      _pdm_debug("<%s> coor sys was created successfully", cs_name);
      status = PDM_S_SUCCESS;
     }

  return (status);
 }

/*
 * This function puts define origin command on the queue.
 */
IGRint PDUdefine_origin(
                        msg,
                        view_name,
                        origin_point,
                        window_view
                       )
 IGRlong       *msg;
 IGRchar       *view_name;
 IGRdouble     origin_point[3];
 IGRchar       *window_view;

 {
  IGRlong          status;
  IGRint           num_win = 0;
  IGRchar          *cs_desc = NULL;
  IGRdouble        ActiveScale[3];
  IGRdouble        ActiveAngle;
  IGRlong          NumberOfBytes, BytesReceived;
  IGRmatrix        placement_matrix;
  IGRmatrix        rot_matrix;
  struct GRid      csobj;
  struct GRmd_env  mod_env;
  
  _pdm_debug("In the PDUdefine_origin function", 0);
  
  /* Get current module environment information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Get objid of window view name */
  status = dp$get_gragad_id (
                             msg = msg,
                             mod_GRid = &(mod_env.md_id),
                             name = window_view,
                             array_size = 1,
                             numberofids = &num_win,
                             found_GRids = &PDU_window_id
                            );
  _pdm_status2 ("dp$get_gragad_id", status, msg);
  _pdm_debug("num_win = <%d>", num_win);

  _pdm_debug("window.objid of active module = <%d>", PDU_window_id.objid);
  _pdm_debug("window.osnum of active module = <%d>", PDU_window_id.osnum);

  _pdm_debug("origin_point:", 0);
  PDUdump_point(origin_point);

  /* Get the view rotation of the selected view matrix */
  status = om$send (
                    msg = message IGEgragad.DPinrot (msg, rot_matrix),
                    senderid = mod_env.md_id.objid,
                    targetid = PDU_window_id.objid,
                    targetos = PDU_window_id.osnum 
                   );
  _pdm_status2 ("IGEgragad.DPinrot", status, *msg);

  _pdm_debug("view rotation matrix:", 0);
  PDUdump_matrix(rot_matrix);

  ActiveAngle = 0.0;

  ActiveScale[0] = 1.0;
  ActiveScale[1] = 1.0;
  ActiveScale[2] = 1.0;

  /* Construct origin placement matrix */
  GRsmplmat(
            msg,
            &ActiveAngle,
            ActiveScale,
            origin_point,
            rot_matrix,
            placement_matrix
           );

  _pdm_debug("origin placement matrix:", 0);
  PDUdump_matrix(placement_matrix);

  /* Create PDU 2.0 origin */
  status = PDUcreate_origin(
                            placement_matrix,
                            mod_env,
                            view_name,
                            cs_desc,
                            origin_point,
                            1,
                            &csobj
                           );
  _pdm_status("PDUcreate_origin", status);
 
  if (status == PDM_S_SUCCESS)
     {
      /* Display constructed coordinate sysytem */
      dp$display(
                 msg = msg,
                 oids = &csobj,
                 mode = GRbd
                );

      *msg = PDM_S_SUCCESS;
      status = 1;
     }

  else
      {
       _pdm_debug("PDUcreate_origin failed", 0);
       status = 0;
      }

  return(status);
 }

/*
 * This function deletes a given saved view.
 */
IGRint  PDUdelete_svview(
                         view_name,
                         mod_env
                        )
 IGRchar          *view_name;
 struct GRmd_env  *mod_env;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    file_dir[DI_PATH_MAX];
  IGRchar    view_dir[DI_PATH_MAX];

  _pdm_debug("In the PDUdelete_svview function", 0);

  /* Delete saved view */
  di$give_pathname(
                   osnum = (*mod_env).md_id.osnum,
                   pathname = file_dir
                  );

  /* Construct full path to view directory */
  sprintf(
          view_dir,
          "%s:views:savedviews:GRsavedviews:%s",
          file_dir,
          view_name
         );

  _pdm_debug("view full path name = <%s>", view_dir);

  /* Remove saved view name */
  status = di$rm_name ( regexp = view_dir );
  _pdm_status("di$rm_name status", status);

  return(status);
 }

/*
 * This function is temp.
 */
IGRint PDUrm_name(name)
 IGRchar *name;
 {
  IGRint status;
  status = di$rm_name ( regexp = name );
  return(status);
 }

IGRint PDUrmdir(name)
 IGRchar *name;
 {
  IGRint status;
  status = di$rmdir(dirname = name, path = NULL);
  return(status);
 }
 

end implementation COpdu; 
