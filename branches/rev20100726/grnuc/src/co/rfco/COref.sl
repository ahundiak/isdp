/*
 *  Description
 *      This object contains the code needed to support the following 
 *      commands:
 *      
 *      ATTACH REFERENCE FILE
 *      DETACH REFERENCE FILE
 *      MODIFY CLIPPING POLYGON DEPTH
 *      DROP REFERENCE FILE SYMBOLOGY
 *
 *  History
 *
 *      jay wallingford 09/22/89   creation date
 *      mark ferguson   09/29/89   added modify clippoly
 *                      09/29/89   added drop reference symb.
 *      henry           11/04/91   add assign_filename action
 *      henry           01/13/91   add assign_filename action
 *      Gang            07/09/93   support for shrink/wrap, background and
 *                                 read/write.
 *      Mike            07/22/93   added is_associative action
 *      jhw             12/3/93    fixed problem with is_associative action
 */
class               COref
super_class         COtools
super_class         CEO_GSLOCATE
start_state         terminate
spec_path           "$grnuc/co/spec"
options             "SItc"

specification

#include <OMindex.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DImacros.h>
#include <DIprims.h>
#include <FI.h>
#include <grerr.h>
#include <refdef.h>
#include <ref.h>
#include <referr.h>
#include <dpmacros.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

instance
{
    /*
     * This is required for the following commands.
     *
     *      ATTACH REFERENCE FILE
     *      DETACH REFEFENCE FILE
     */
    char                 filename [DI_PATH_MAX];
    char                 name [DI_PATH_MAX];
    char                 view [DI_PATH_MAX];
    char                 scale [DI_PATH_MAX];
    char                 mode;
    struct GRevent          origin_event;
    int                  origin_flag;
    int                  ref_id_count,option;
    variable struct GRid    ref_id[1];
    char                 ref_dir[DI_PATH_MAX];

    /*
     * This data is required by the following commands.
     *
     * DROP REFERENCE FILE SYMBOLOGY
     * MODIFY CLIPPING POLYGON DEPTH
     */
    struct GRid      reffile;         /* Reference file */
    struct GRid      clippoly;        /* Clipping polygon to be modified */
    struct GRparms   clippoly_parms;  /* Geometric parms of clippoly */

    struct GRid      object;          /* Generic object */

    struct GRmd_env  mod_info;        /* Module information */

    long          from_window,     /* Window modify started in */
                     to_window;       /* Window modify completed in */
    IGRpoint         from_point,      /* From modify point */
                     to_point;        /* To modify point */
    char             ref_mode;
    IGRulong         ref_properties;  /* optional properties GRRF_BACKGROUND
                                         and GRRF_SHRINK_WRAP */
    int              token;
}

implementation

#include <coimport.h>
#include <OMerrordef.h>
#include <stdio.h>
#include <alloca.h>
#include "msmacros.h"
#include "exmacros.h"
#include "grmessage.h"
#include "growner.h"
#include "detailco.h"
#include "dpdef.h"
#include <sys/stat.h>
#include <sys/param.h>

#define DIRSIZ 50

#ifdef SUNOS5
//#define DIRSIZ 14 XXX - Use the macro for Solaris
#include <sys/fs/ufs_fsdir.h>
#define DIRSIZ  MAXNAMLEN
#endif

#define FILNAME_OPT  222
#define TITLE_FLD    333

from IGEgragad  import	DPinrot;
from GRgraphics import	GRdisplay, GRconstruct, GRdelete, GRisparent;
from GRreffile  import  GRchgfilename,GRgetenvironment,GRgetrang,GRchgname;
from GRreffile  import	GRchgrfprops;
from GRclippoly import  GRmodify_height;
from GRmodule   import  GRmdremove;

extern int GRformlbsys();
extern int DEref_view_recalled();

action construct_reference_file
{
    long                    msg, msg1;
    OMuword                 classid;
    struct GRvg_construct   const_list;
    struct IGRlbsys         lbsys;
    struct GRrf_info        rf_info;
    IGRmatrix               window_rotation;
    struct GRid             ref_id;
    unsigned int         properties;

    /*  
     * Set up the construct arguments.
     */
    properties = 0;
    om$get_classid ( classname = "GRreffile", p_classid = &classid );

    const_list.msg = &msg1;
    const_list.env_info = &me->ModuleInfo;
    const_list.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    const_list.geometry = (IGRchar *) &lbsys;
    const_list.display = &me->ActiveDisplay;
    const_list.level = me->ActiveLevel;
    const_list.newflag = FALSE;
    if(me->name[0] != NULL)
      const_list.name = me->name;
    else
      const_list.name = NULL;
    const_list.class_attr = (char *)&rf_info;

    rf_info.filename = me->filename;
    rf_info.named_view = (me->view[0]) ? me->view : NULL;
    rf_info.clip_poly = NULL;
    rf_info.prism_classname = NULL;
    rf_info.description = NULL;
    properties = GRRF_IS_READ_ONLY;
    if(me->ref_properties & GRRF_BACKGROUND)
      {
         properties |= GRRF_BACKGROUND;
      }
    rf_info.ref_properties = &properties;
    rf_info.scale = (me->scale[0]) ? me->scale : NULL;

    if (me->origin_flag)
    {
        status = om$send ( msg = message IGEgragad.DPinrot ( &msg,
                                                             window_rotation ),
                           targetid = me->origin_event.event.button.objid,
                           targetos = me->origin_event.event.button.osnum );

        if (status & msg & 1)
        {
            GRformlbsys ( &msg,
                          window_rotation,
			  &me->origin_event.event.button.x,
			  &lbsys );
        }
    }
    else
    {
        /* 
         * Load identity matrix.
         */
        MAidmx(&msg,lbsys.matrix);

        /*
         * Design file limits.
         */
        lbsys.diag_pt1[0] = lbsys.diag_pt1[1] = lbsys.diag_pt1[2] = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt2[0] = lbsys.diag_pt2[1] = lbsys.diag_pt2[2] = (double)(GRDGNLIMITS_MAX_D - 1.0);
    }

    if ( 1 & status & msg)
    {
      /* if the mode is writable, add that file to the list */
      if (me->mode == 'W') GRmake_writable ( &msg, me->filename,NULL );
      status = om$construct( osnum = me->ModuleInfo.md_id.osnum,
                             obj_osnum = me->ModuleInfo.md_id.osnum,
                             classid = classid,
                             msg = message GRgraphics.GRconstruct ( &const_list ),
                             p_objid = &ref_id.objid );

        ref_id.osnum = me->ModuleInfo.md_id.osnum;

        if ( status & msg1 & 1 )
        {
            /*
             * Activate any symbology overrides.
             */
            if ( me->view[0] )
            {
                struct GRid win_id;

                win_id.objid = me->origin_event.event.button.objid;
                win_id.osnum = me->origin_event.event.button.osnum;
    
                /*
                 * Activate any symbology overrides attached to 
                 * the reference file's saved view.
                 */
                DEref_view_recalled ( &msg, 
                                      &ref_id, 
                                      &win_id );
            }   


            if(me->ref_properties & GRRF_SHRINK_WRAP)
             {
                /* Shrink/Wrap the clipping polygon */

                GRrfshwrclip(&msg, &ref_id);
             }

            /*
             * Display the constructed object.
             */
            me->DisplayMode = GRbd;
            
            om$send ( mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay
                                        ( &msg,
			                  &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                          &me->DisplayMode, 
                                          &me->ModuleInfo.md_id ),
                      senderid = my_id,
                      targetid = ref_id.objid,
                      targetos = ref_id.osnum );
        }
    }

    *sts = msg1;
    if ( !(status & msg1 & msg & 1) )
    {
        om$send ( msg = message GRgraphics.GRdelete ( &msg, &me->ModuleInfo ),
            targetos = ref_id.osnum, targetid = ref_id.objid, senderid = my_id );
        if ((msg1 != GRVIEWNOTFOUND)    &&
            (msg1 != GRNAMEDUPLICATED)  &&
            (msg1 != GRFILENOTFOUND)    &&
            (msg1 != GRSDGNEXCEED)      &&
            (msg1 != OM_E_NO_OS_AVAIL))
           *sts = MSFAIL;

        if (msg1 == GRNAMEDUPLICATED) me->name[0] = '\0';
            
    }
    else
    { 
        me->name[0] = '\0';
    }

    return OM_S_SUCCESS;
}


action options_mode (int mode; char * info)

{
    int msg;
    int    index;
    char * form;
    int file_compare_func();

    struct stat stat_buffer;
    IGRchar msg_buff[256];

/*
 *  Don't display if noboby has asked for status display form
 */
    if ( ! me->form_requested ) {
      return (OM_S_SUCCESS);
    }
/*
 *  Don't display the same thing
 */
    if ( mode == me->option ) {
      return (OM_S_SUCCESS);
    }

     me->option = mode;
    om$send( msg = message CEO.get_form_ptr( STATUS_FORM, &form, &index, &msg ),
             targetid = my_id );

    /*
     *  Fill in the status display form
     */
    {
        FIg_reset (form, FILNAME_OPT);
        FIfld_set_mode (form, FILNAME_OPT, 0, FI_SINGLE_SELECT);
        FIg_erase (form, TITLE_FLD);

        switch (me->option)
        {
        case FILENAME_MODE:
        {
             {
                struct  dirent *entry;
                char directory[1024], name[256], path[1024];
                int row;
                DIR  * dp;
                FILE * fp;
                extern char * getcwd();
                char **file_list;
                int Count, Size=64 ,n_Size=64;


                ex$message (msgnumb = GR_S_FndngDgnFls);

                if (!info)
                {
                  extern long EXgetcwd();

                  EXgetcwd(directory,1024);
                }

                else strcpy (directory, info);

                /*
                 * Open the current directory.
                 */
                if (dp=(DIR *)opendir(directory))
                {
                    row = 0;

                /*
                 * Read the "." and ".." and the first entry directory entries
                 */
                    if (entry = (struct dirent *)readdir(dp))
                        if (entry = (struct dirent *)readdir(dp))
                            entry = (struct dirent *)readdir(dp);
            /*
             * Allocate some memory for 64 directory entries
             */

            file_list = (char **)malloc( sizeof(char*) * Size);

            if (file_list==NULL) return (OM_S_SUCCESS);

            /*
             * While there are directory entries.
             */
              while (entry)
                    {
                    /*
                     * Copy the DIRSIZ char d_name into DIRSIZ + 1 char name
                     * up to DIRSIZ chars.
                     * NOTE: This is required size a d_name entry is only 14
                     *       chars. If a directory name is 14 chars there will
                     *       be NO NULL at the end.
                     */
                 strncpy(name, entry->d_name, DIRSIZ);
                        name[DIRSIZ] = '\0';
                        strcpy (path, directory);
                        strcat (path, "/");
                        strcat (path, name);

                /*
                 * check if the file is a regular file
                 */


                stat(path, &stat_buffer);

                if (S_ISREG(stat_buffer.st_mode))

                {
                   /*
                    * If the file can be opened for read.
                    */

                    if (fp = (FILE *)fopen(path, "r"))
                    {
                      /*
                       * If the file is an object space, put the filename
                       * on the form.
                       */

                       if (COis_om_file(fp))
                       {
                  if (row == Size) /* see if enough mem is allocated */
                  {
                   Size += n_Size;
                   file_list= (char **)realloc(file_list,Size * sizeof(char *));
                   if (file_list==NULL) return (OM_S_SUCCESS);
                  }

               file_list[row]= (char *) alloca(strlen(name)*sizeof(char)+1);
                if (file_list[row])
                  if ((strcpy(file_list[row],name))==NULL)
                          return(OM_S_SUCCESS);
                row++;
                }

                  fclose(fp);
                  }
                }

              entry = (struct dirent *)readdir(dp);

            } /* end while loop */

            qsort(file_list,row,sizeof(char *),file_compare_func);

                FIg_erase (form, TITLE_FLD);
                ex$message (msgnumb = GR_I_DgnFls, buff = msg_buff);

                FIg_set_text (form, TITLE_FLD, msg_buff);
                FIg_display (form, TITLE_FLD);

                for(Count=0;Count<row;Count++)
                FIfld_set_text ( form, FILNAME_OPT, Count, 0,
                file_list[Count], 0 );

                free(file_list);

                closedir(dp);
              }
                else FIfld_set_mode (form, FILNAME_OPT, 0, FI_REVIEW);
                UI_status ("");
           }

        }
        break;


      case SCALE_MODE:
        {
            int row;
            static char * iso_scales[23] = {"50:1","20:1","10:1","5:1","2:1",
                                            "1:1","1:2","1:5","1:10","1:20",
                                            "1:25","1:33.3","1:50","1:75",
                                            "1:80","1:100","1:150","1:200",
                                            "1:500","1:1000","1:2000","1:5000",
                                            "1:10000"};
            //strcpy ( me->scale,info);

            ex$message (msgnumb = GR_I_Scales, buff = msg_buff);
            FIg_set_text (form, TITLE_FLD, msg_buff);
            FIg_display (form, TITLE_FLD);

            for (row =0; row<23; ++row)
             {
                  FIfld_set_text ( form,
                    FILNAME_OPT,
                    row, 0,
                    iso_scales[row], 0 );
              }
          }
           break;


            case VIEW_MODE:
        {
            struct GRmd_env mod_env;
            IGRlong ok;
            int  count = 0, row = 0, i;
            long num;
            struct GRid grids[500];
            char name[1024], filename[1024];
            struct var_list list[2];
            struct  GRid partid;

            ex$message (msgnumb = GR_I_WinVws, buff = msg_buff);

            FIg_set_text (form, TITLE_FLD, msg_buff);
            FIg_display (form, TITLE_FLD);
            strcpy(filename, me->filename);

            if(filename)
            {
                long                    status, msg,msg1;
                int                     active;
       		OMuword                 classid;
                struct GRvg_construct   const_list;
                struct IGRlbsys         lbsys;
                struct GRrf_info        rf_info;
                IGRuint                 properties;
	        IGRchar           write [MAXPATHLEN];

	        om$get_classid ( classname = "GRreffile",
	           		    p_classid = &classid );

	   	const_list.msg = &msg1;
	   	const_list.newflag = FALSE;
	   	const_list.env_info = &me->ModuleInfo;
	   	const_list.properties = GRIS_NEW;
	   	const_list.geometry = (IGRchar *)&lbsys;
	   	const_list.display = &me->ActiveDisplay;
        	const_list.level = me->ActiveLevel;
        	const_list.class_attr = (IGRchar *)&rf_info;
        	const_list.name = NULL;

        	rf_info.filename = filename;
        	rf_info.named_view = NULL;
        	rf_info.clip_poly = NULL;
        	rf_info.prism_classname = NULL;
        	rf_info.description = NULL;
        	rf_info.ref_properties = &properties;
        	properties = GRIS_MODEL_ATTACHMENT;
        	rf_info.scale = "1:1";

        /* 
         * Load identity matrix.
         */
        MAidmx(&msg,lbsys.matrix);

        /*
         * Design file limits.
         */
        lbsys.diag_pt1[0] = lbsys.diag_pt1[1] = lbsys.diag_pt1[2] = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt2[0] = lbsys.diag_pt2[1] = lbsys.diag_pt2[2] = (double)(GRDGNLIMITS_MAX_D - 1.0);

        active = GRactive_owner_temp_clear (0);
        
        /*
         * Make the query file the same mode as the 
         * drawview that is being constructed.
         */
        ex$message ( msgnumb = GR_I_WRITE1, buff = &write [0] );
        ex$message ( msgnumb = GR_I_WRITE2, buff = &write [1] );

        if (me->mode==write[0] || me->mode==write[1])
            GRmake_writable (&msg, filename,NULL);
        else
            properties |= GRRF_IS_READ_ONLY;

        /* 
         * Construct the query file.
         */
        status = om$construct( osnum = me->ModuleInfo.md_id.osnum,
                               obj_osnum = me->ModuleInfo.md_id.osnum,
                               classid = classid,
                               msg = message GRgraphics.GRconstruct
                                                            (&const_list),
                               p_objid = &partid.objid );

        GRactive_owner_temp_clear (&active);

        partid.osnum = me->ModuleInfo.md_id.osnum;

        if ( !(status & msg1 & 1) )
        {
            if ((msg1 != GRVIEWNOTFOUND)    &&
                (msg1 != GRNAMEDUPLICATED)  &&
                (msg1 != GRFILENOTFOUND)    &&
                (msg1 != GRSDGNEXCEED)      &&
                (msg1 != OM_E_NO_OS_AVAIL))
            {   
                 msg1 = MSFAIL;
            }
        }
        else
        {
            GRrange     range;
            IGRint      index;
            GRobjid     ref_objid;
            IGRboolean  world;
            IGRchar     refname[DI_PATH_MAX];

            world = FALSE;

            /* must rename the reference file so that when the permanent
             * (model) reference file is attached, it will have the desired
             * name - find a unique name
             */

            for (index = 1;; index++)
            {
                sprintf(refname, "tmp_ref_name%d", index);

                if (di$translate(objname = refname,
                                 osnum = me->ModuleInfo.md_id.osnum,
                                 path = "ref:refnames",
                                 p_objid = &ref_objid) != DIR_S_SUCCESS)
                {
                    om$send(mode = OM_e_wrt_object,
                            msg = message GRgraphics.GRchgname(&msg,
                                                            &me->ModuleInfo,
                                                            refname),
                            targetid = partid.objid,
                            targetos = partid.osnum);
                    break;
                }
            }

            om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRgetrang ( &msg,
                                                         &me->ModuleInfo.md_env.matrix_type,
                                                         me->ModuleInfo.md_env.matrix,
                                                         &world,
                                                         range ),
                    targetid = partid.objid,
                    targetos = partid.osnum);

            if (msg & 1)
            {
		om$send ( msg = message GRmodule.GRmdremove ( &msg,
                                                              range,
                                                              &partid.objid),
                          targetid = me->ModuleInfo.md_id.objid,
                          targetos = me->ModuleInfo.md_id.osnum);
             }
            }
         }

            om$send ( msg = message GRreffile.GRgetenvironment (&ok,
                                                                &me->ModuleInfo,
                                                                &mod_env),
                      targetid = partid.objid,
                      targetos = partid.osnum );


            dp$get_gragad_id ( msg = &ok,
                               mod_GRid = &mod_env.md_id,
                               name = "*",
                               numberofids = &count,
                               array_size = 500,
                               found_GRids = grids );

            list[0].var = GRAGAD_NAME;
            list[0].var_ptr = name;
            list[0].num_bytes = 1024;
            list[0].bytes_returned = &num;
            list[1].var = END_PARAM;

            if ((ok & 1) && count)
            {
                for (i=0; i<count; ++i)
                {
                    dp$inq_set_gragad ( msg = &ok,
                                        osnum = mod_env.md_id.osnum,
                                        gragad_objid = grids[i].objid,
                                        which_error = &ok,
                                        var_list = list );

                    if (ok & 1)
                    {
                        FIfld_set_text ( form,
                                         FILNAME_OPT,
                                         row++, 0,
                                         name, 0 );
                    }
                }

                count = 0;
            }

            dp$get_saved_vw_id ( msg = &ok,
                                 osnum = mod_env.md_id.osnum,
                                 name = "*",
                                 numberofids = &count,
                                 array_size = 500,
                                 found_GRids = grids );

            list[0].var = SAV_VW_NAME;
            list[0].var_ptr = name;
            list[0].num_bytes = 1024;
            list[0].bytes_returned = &num;
            list[1].var = END_PARAM;

            if ((ok & 1) && count)
            {
                for (i=0; i<count; ++i)
                {
                    dp$inq_set_saved_view ( msg = &ok,
                                            osnum = mod_env.md_id.osnum,
                                            vw_objid = grids[i].objid,
                                            which_error = &ok,
                                            var_list = list );

                   if(ok & 1)
                    {
                        FIfld_set_text ( form,
                                         FILNAME_OPT,
                                         row++, 0,
                                         name, 0 );
                    }
                }
            }
       if (partid.objid != NULL_OBJID)
        {
	  om$send ( msg = message GRgraphics.GRdelete (&ok, &me->ModuleInfo),
	            targetid = partid.objid,
	            targetos = partid.osnum );

	   partid.objid = NULL_OBJID;
	   partid.osnum = 0;
        }
       }
            break;
       }
     }
         
        if( me->option != -1 )
        {
       om$send( msg = message CEO.display_form_by_label( STATUS_FORM, &msg ),
                targetid = my_id );
        }

       return (OM_S_SUCCESS);
  }

action change_reference_filename
{
    int  msg = MSSUCC;

    status = om$send ( msg = message GRreffile.GRchgfilename ( (IGRlong *) sts,
                                                               me->filename,
                                                               me->name ),
                       targetid = me->ref_id[0].objid,
                       targetos = me->ref_id[0].osnum );

    if ( !(status & msg & *sts & 1) )
    {
        if ( *sts != GRNAMEDUPLICATED )
        {
            *sts = MSFAIL;
        }
    }
    else *sts = MSSUCC;

    return (OM_S_SUCCESS);
}

/* 
Description
   This action saves the current clipping polygon and finds the associated
   reference file attachment's objid and osnum.
*/

action save_clippoly ()
{
  OM_S_CHANSELECT      chansel;            /* Channel reference file is on */
  OM_S_OBJECT_LINKAGE  linkage;            /* Channel information */
  IGRuint              count;
  long              OMmsg = OM_S_SUCCESS;

  me->clippoly       = me->event3.located_object[0].located_obj;
  me->clippoly_parms = me->event3.located_object[0].geom_parms;

  me->object         = me->clippoly;

  me->mod_info       = me->ModuleInfo;

  chansel.type       = OM_e_name;
  chansel.u_sel.name = "GRclippoly.to_attachment";

  /*
   * Get the reference file off the channel
   */
  OMmsg = om$get_channel_objects(osnum        = me->clippoly.osnum,
                                 objid        = me->clippoly.objid,
                                 p_chanselect = &chansel,
                                 list         = &linkage,
                                 size         = 1,
                                 count        = &count);

  me->reffile.osnum = linkage.osnum;
  me->reffile.objid = linkage.S_objid;
}

/*
Description
   This action saves the "from" information.
*/ 

action save_from_info ()
{
  me->from_window   = me->event1.event.button.window;
  me->from_point[0] = me->event3.located_object[0].proj_pnt[0];
  me->from_point[1] = me->event3.located_object[0].proj_pnt[1];
  me->from_point[2] = me->event3.located_object[0].proj_pnt[2];
}


/*
Description
   This action saves the "to" information and modifies the clipping polygon.
*/

action modify_clippoly
{
  long           msg;          /* Return code */
  IGRpoint          pts[2];       /* boreline points */
  struct IGRline    boreline;     /* Boreline "to" point */
  long           OMmsg = OM_S_SUCCESS;

  OMmsg = 1;

  me->to_window   = me->event1.event.button.window;
  me->to_point[0] = me->event1.event.button.x;
  me->to_point[1] = me->event1.event.button.y;
  me->to_point[2] = me->event1.event.button.z;

  /* 
    Construct the boreline 
  */
  boreline.point1 = pts[0];
  boreline.point2 = pts[1];

  GRbrlnconstr(&msg, &me->event1.event.button.x, me->ModuleInfo.md_env.matrix,
                     &boreline);
   
  /* 
   * Modify the clipping polygon
   */
  OMmsg = om$send(msg = message GRclippoly.GRmodify_height(&msg,
                     &me->ModuleInfo, 
                     &me->clippoly_parms,
                     me->from_point,
                     &boreline),
                     targetid = me->clippoly.objid,
                     targetos = me->clippoly.osnum);
}


/*
   This action is defined externally.
*/

action dynamics extern


/* 
Description
   This action drops the reference file symbology overrides.
*/

action drop_ref_symbology
{
  long            chng_msg;            
  short           action; 
  IGRulong        properties;
  long            OMmsg = OM_S_SUCCESS;

  action = 0;                             /* Set flag to clear input word */
  properties = GROVERRIDE_SYMBOLOGY; 

  /*
    Change the properties of the reffile.
  */      
  OMmsg = gr$gspass ( msg = sts,
                      pass_msg = message GRreffile.GRchgrfprops(
                                   &chng_msg,
                                   &action,
                                   &properties),
                      path = NULL,
                      p_chanselect = &me->located_chansel );
}



action echo_mode
/*
   This actions displays the current mode of the file (if any)
*/
{
  IGRboolean assoc_flag;
  char       tmp [DI_PATH_MAX];

  *sts = MSSUCC;
  gr$get_associative_flag ( sizbuf = sizeof ( IGRboolean ), buffer = &assoc_flag );

  /* Check if the file is in the list of writable files for the master os */
  GRis_writable ( sts, &me->filename[0], 0, (OMuword)0 );
  if (*sts == MSSUCC)
    /* The file is writable (flag is ON and it is in the list) */
    me->mode = 'W';
  else
    /* see if the file is open */
    if (ex$is_file_open ( name = &me->filename[0] ))
    {
      long    msg;
      OMuword osnum = 0;

      /* The file is writable if it is the module and read-only otherwise */
      om$os_name_to_number ( osname = &me->filename[0], p_osnum = &osnum );
      if (!osnum)
      {
        int  len = 1026;
        char buffer[1026];
        char *basename = NULL;

        /*
         * If this isn't a full pathname.
         */
        if (me->filename[0] != '/')
        {
            buffer[0] = '\0';

            /*
             * Get the current working directory.
             */
            ex$get_working_dir (name = buffer, len = &len);

            if (buffer[0] != '\0')
            {
                /* 
                 * Construct a full pathname.
                 */
                strcat (buffer, &me->filename[0]);
                basename = buffer;
            }
            else /* Use the filename as is. */
            {
                basename = &me->filename[0];
            }
        }
        else /* it's a full pathname */
        {
            basename = &(me->filename [strlen ( &me->filename[0] ) - 1]);

            /* let's try the base name */  
            for (; (*basename != '/') && (basename != &(me->filename [0])); 
                 basename--);
        }

        om$os_name_to_number ( osname = basename, p_osnum = &osnum );
      }

      if (osnum)
      {
        GRcheckref ( &msg, NULL, NULL, NULL, &osnum );

        if (msg != MSSUCC) 
        {
            me->mode = 'W';
        }
        else
        {
            IGRlong status, ok;

            status = GRis_nested_writable (&ok, me->filename); 

            me->mode =  (status & ok & 1) ? 'W' : 'R';
        }
      }
      else
        me->mode = 'W';
      *sts = MSSUCC;
    }
    else
      /* It's a new file, the assoc flag is used to determine the attachment mode */
      if (assoc_flag)
      {
        FILE *fet;
        
        /* in order for the file to be read/write, we must have the write permission */
        fet = fopen ( me->filename, "r+" );
        if (!fet)
        {
          me->mode = 'R';
          *sts = MSSUCC;
        }
        else
        {
          /* Associativity is ON, the file is not already open and we can write to it */
          if(me->ref_mode == 'R')
             me->mode = 'R';
          else
             me->mode = 'W';
          fclose ( fet );
        }
      }       
      else
      {
        if(me->ref_mode == 'W')
         {
           FILE *fet;

           fet = fopen(me->filename, "r+");
           if(!fet)
           {
              me->mode = 'R';
              *sts = MSSUCC;
           }
           else
           {
             me->mode = 'W';
             fclose(fet);
           }
         }
        else
           me->mode = 'R';
      }

  ex$message ( msgnumb = me->mode == 'W' ? GR_I_RWFILE : GR_I_ROFILE,
               type = "%s",  
               buff = tmp,
               var = `me->filename` );
  UI_status ( tmp );
}
action file_mode
/*
   This actions displays the current mode of the file (if any)
*/
{
  IGRboolean assoc_flag;
  char       tmp [DI_PATH_MAX];

  *sts = MSSUCC;
  gr$get_associative_flag ( sizbuf = sizeof ( IGRboolean ), buffer = &assoc_flag );

  /* Check if the file is in the list of writable files for the master os */
  GRis_writable ( sts, &me->filename[0], 0, (OMuword)0 );
  if (*sts == MSSUCC)
    /* The file is writable (flag is ON and it is in the list) */
    me->mode = 'W';
  else
    /* see if the file is open */
    if (ex$is_file_open ( name = &me->filename[0] ))
    {
      long    msg;
      OMuword osnum = 0;

      /* The file is writable if it is the module and read-only otherwise */
      om$os_name_to_number ( osname = &me->filename[0], p_osnum = &osnum );
      if (!osnum)
      {
        int  len = 1026;
        char buffer[1026];
        char *basename = NULL;

        /*
         * If this isn't a full pathname.
         */
        if (me->filename[0] != '/')
        {
            buffer[0] = '\0';

            /*
             * Get the current working directory.
             */
            ex$get_working_dir (name = buffer, len = &len);

            if (buffer[0] != '\0')
            {
                /* 
                 * Construct a full pathname.
                 */
                strcat (buffer, &me->filename[0]);
                basename = buffer;
            }
            else /* Use the filename as is. */
            {
                basename = &me->filename[0];
            }
        }
        else /* it's a full pathname */
        {
            basename = &(me->filename [strlen ( &me->filename[0] ) - 1]);

            /* let's try the base name */  
            for (; (*basename != '/') && (basename != &(me->filename [0])); 
                 basename--);
        }

        om$os_name_to_number ( osname = basename, p_osnum = &osnum );
      }

      if (osnum)
      {
        GRcheckref ( &msg, NULL, NULL, NULL, &osnum );

        if (msg != MSSUCC) 
        {
            me->mode = 'W';
        }
        else
        {
            IGRlong status, ok;

            status = GRis_nested_writable (&ok, me->filename); 

            me->mode =  (status & ok & 1) ? 'W' : 'R';
        }
      }
      else
        me->mode = 'W';
      *sts = MSSUCC;
    }
    else
      /* It's a new file, the assoc flag is used to determine the attachment mode */
      if (assoc_flag)
      {
        FILE *fet;
        
        /* in order for the file to be read/write, we must have the write permission */
        fet = fopen ( me->filename, "r+" );
        if (!fet)
        {
          me->mode = 'R';
          *sts = MSSUCC;
        }
        else
        {
          /* Associativity is ON, the file is not already open and we can write to it */
          if(me->ref_mode == 'R')
             me->mode = 'R';
          else
             me->mode = 'W';
          fclose ( fet );
        }
      }       
      else
      {
        if(me->ref_mode == 'W')
         {
           FILE *fet;

           fet = fopen(me->filename, "r+");
           if(!fet)
           {
              me->mode = 'R';
              *sts = MSSUCC;
           }
           else
           {
             me->mode = 'W';
             fclose(fet);
           }
         }
        else
           me->mode = 'R';
      }

}


action assign_filename ( char *fname )
/*
   This action moves fname into me->filename.
*/
{
  strcpy ( me->filename, fname );
}


action assign_name ( char *fname )
/*
   This action moves fname into me->name.
*/
{
  strcpy ( me->name, fname );
}


action assign_scale ( char *scale )
/*
   This action moves fname into me->scale
*/
{ 
  IGRlong om_msg;
  int clip_state, back_state,sts,msg;
  int i,sel,update_state,pos;
  IGRboolean shwr_flag, backgr_flag;
  char attach_name[DI_PATH_MAX];
  char buffer[1024];

  clip_state = 0;
  back_state = 0;
  update_state = 0;
  sel = 0;
  i = 0;
  attach_name[0] = NULL;

  strcpy ( me->scale, scale );

  if(me->option == SCALE_MODE)
 {
  FIg_get_state(me->status_display_form_ptr, BACKGROUND, &back_state);
  FIg_get_state(me->status_display_form_ptr, CLIPPING, &clip_state);
  FIg_get_state(me->status_display_form_ptr, UPDATE, &update_state);

  FIfld_get_text (me->status_display_form_ptr,ATTACHNAME, 0, 0,
                  DI_PATH_MAX, (unsigned char *)attach_name, &sel, &i);

  if(back_state == 0)
  {
     me->ref_properties = me->ref_properties & ~GRRF_BACKGROUND;
     backgr_flag = FALSE;
     gr$put_reffile_background( sizbuf = sizeof ( IGRboolean ),
                                buffer = &backgr_flag);
  }
  else
  {
     me->ref_properties = me->ref_properties | GRRF_BACKGROUND;
     backgr_flag = TRUE;
     gr$put_reffile_background( sizbuf = sizeof ( IGRboolean ),
                                buffer = &backgr_flag);
  }
   if(clip_state == 1)
  {
     me->ref_properties = me->ref_properties & ~GRRF_SHRINK_WRAP;
     shwr_flag = FALSE;
     gr$put_reffile_shrink_wrap( sizbuf = sizeof ( IGRboolean ),
                                 buffer = &shwr_flag);
  }
  else
  {
     me->ref_properties = me->ref_properties | GRRF_SHRINK_WRAP;
     shwr_flag = TRUE;
     gr$put_reffile_shrink_wrap( sizbuf = sizeof ( IGRboolean ),
                                 buffer = &shwr_flag);
  }
  if(update_state == 0)
            {
              me->ref_mode = 'W';
            }
           else
            {
              me->ref_mode = 'R';
            }
        if(attach_name[0] != NULL)
            {
              strcpy(me->name,attach_name);
            }

           FIfld_set_text (me->status_display_form_ptr,
                           ATTACHNAME,
                           0, 0, "", FALSE);

            sts = om$send(msg = message CEO.erase_form_by_label
                                    (me->token, 0, &msg),
                         targetid = my_id);
           
           me->form_requested = FALSE;
  } 
}

action assign_view ( char *vname )
/*
   This action moves fname into me->view
*/
{
  strcpy ( me->view, vname );
}


action assign_origin_flag ( int flag )
/*
   This action moves flag into me->origin_flag
*/
{
  me->origin_flag = flag;
}


action assign_origin_event ()
/*
   This action moves me->event1 into me->origin_event
*/
{
  me->origin_event = me->event1;
}


action assign_grid ()
/*
   This action moves the channel to the grid.
*/
{
   status = om$send ( msg = message COtools.assign ( (IGRchar *) &me->located_chansel,
              (IGRchar *) me->ref_id, CO_gschan_to_grid ),
              targetid = my_id );
}

action assign_defaults ()
/*
  This action initializes the reference file properties.
*/
{
  IGRboolean shwr_flag;
  IGRboolean backgr_flag;

  me->ref_properties = 0;
  gr$get_reffile_shrink_wrap( sizbuf = sizeof ( IGRboolean ),
                              buffer = &shwr_flag);
  gr$get_reffile_background( sizbuf = sizeof ( IGRboolean ),
                             buffer = &backgr_flag);

  if(shwr_flag)
    me->ref_properties |= GRRF_SHRINK_WRAP;
  else
    me->ref_properties &= ~GRRF_SHRINK_WRAP;

  if(backgr_flag)
    me->ref_properties |= GRRF_BACKGROUND;
  else
    me->ref_properties &= ~GRRF_BACKGROUND;
  me->name[0] = NULL;
  me->filename[0] = NULL;
  me->ref_mode = NULL;
}



action set_gadgets ()
{
  IGRboolean assoc_flag;
  FILE *fet;

  gr$get_associative_flag ( sizbuf = sizeof ( IGRboolean ),
                            buffer = &assoc_flag);

  if(assoc_flag)
   {
      if(me->filename[0] != NULL)
       {
         fet = fopen(me->filename,"r+");
         if(!fet)
          {
            assoc_flag = 0;
          }
         else
          {
            fclose(fet);
          }
       }
   }
  else
   {
     if(me->ref_mode == 'W')
       assoc_flag = 1; 
   }

  if(assoc_flag)
   {
     FIg_set_state_off(me->status_display_form_ptr, UPDATE);
   }
  else
   {
     FIg_set_state_on(me->status_display_form_ptr, UPDATE);
   }

  if(me->ref_properties & GRRF_SHRINK_WRAP)
   {
     FIg_set_state_off(me->status_display_form_ptr,CLIPPING);
   }
  else
   {
     FIg_set_state_on(me->status_display_form_ptr,CLIPPING);
   }

  if(me->ref_properties & GRRF_BACKGROUND)
   {
     FIg_set_state_on(me->status_display_form_ptr,BACKGROUND);
   }
  else
   {
     FIg_set_state_off(me->status_display_form_ptr,BACKGROUND);
   }

   FIfld_set_text (me->status_display_form_ptr, ATTACHNAME, 
                   0, 0, me->name, FALSE);
}


action status_disp ()
{
    om$send(msg = message COref.set_gadgets(),
            targetid = my_id);

    om$send(msg = message CEO.status_disp(),
            mode = OM_e_wrt_message,
            targetid = my_id);
}

action form_notification(int form_label;
                         int gadget_label;
                         double value;
                         char * form_ptr )
{
  IGRlong om_msg;
  int clip_state, back_state,sts,msg;
  int i,sel,update_state,pos;
  IGRboolean shwr_flag, backgr_flag;
  char attach_name[DI_PATH_MAX];
  char buffer[1024];

  me->token=form_label;
  clip_state = 0;
  back_state = 0;
  update_state = 0;
  sel = 0;
  i = 0;
  attach_name[0] = NULL;

   /* clear the message field */
   FIfld_set_text(me->status_display_form_ptr,FI_MSG_FIELD,0,0,"",0);
   switch(gadget_label)
   {
      case ATTACHNAME:      
        FIfld_get_text (form_ptr, 
                        gadget_label, 
                        0, 0, 
                        DI_PATH_MAX, 
                        buffer, 
                        &sel, &pos);

        if (strchr(buffer, '*') || 
            strchr(buffer, '[') || 
            strchr(buffer, ']'))
        {
            ex$message (msgnumb = GR_E_InvNme, buff = buffer);
            FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0, buffer, FALSE);
            FIfld_set_text (form_ptr, ATTACHNAME, 0, 0, "", FALSE);
        }
        else
        {
            IGRchar         path[DI_PATH_MAX];
            OM_S_OBJID      objid;
            OMuword         osnum;
            struct GRmd_env mod_env;

            gr$get_module_env (buffer = &mod_env);
            DIstmocpy (path, "ref", "refnames", 0, mod_env.md_id.osnum);
            DIstrcat (path, buffer);
            om_msg = di$translate (objname = path, 
                                   p_objid = &objid,
                                   p_osnum = &osnum);

            if (om_msg == DIR_S_SUCCESS)
            {
                ex$message (msgnumb = GR_E_AttnameEx, buff = buffer);
                FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0, buffer, FALSE);
                FIfld_set_text (form_ptr, ATTACHNAME, 0, 0, "", FALSE);
            }
        }
        
        break;

      case UPDATE:

           FIg_get_state(me->status_display_form_ptr, UPDATE, &update_state);
           
           if(me->filename[0] != NULL)
            {
              if(update_state == 0)
               {
                 FILE *fet;
 
                 fet = fopen(me->filename,"r+");
                 if(!fet)
                  {
                    FIg_set_state_on(me->status_display_form_ptr,UPDATE);
                    ex$message ( msgnumb = GR_E_NotUpdate,
                                 buff = buffer);
                    FIfld_set_text(me->status_display_form_ptr,FI_MSG_FIELD,
                                   0,0,buffer,0);
                  }
                 else
                   fclose(fet);
               }
              else
               {

                 char       tmp [DI_PATH_MAX];

                 sts = MSSUCC;
                 /* Check if the file is in the list of writable files */
                 GRis_writable ( &sts, &me->filename[0], 0, (OMuword)0 );
                 if (sts == MSSUCC)
                  {
                    FIg_set_state_off(me->status_display_form_ptr,UPDATE);
                    ex$message ( msgnumb = GR_E_AttUpdate,
                                 buff = buffer);
                    FIfld_set_text(me->status_display_form_ptr,FI_MSG_FIELD,
                                   0,0,buffer,0);
                  }
                }
               }
           break;
      
       case FILNAME_OPT:
       {
       IGRchar buffer[1024];
       IGRchar text[EXFI_STRLEN];
       IGRint  r_pos;
       IGRint  sel_flag;
       IGRint  msg = MSSUCC;
       IGRlong buffersize;
       IGRint  response;

	   FIfld_get_text ( form_ptr, 
			    gadget_label,
			    (int)value, 
			    0, 
			    EXFI_STRLEN, 
			    text, 
			    &sel_flag, 
			    &r_pos );

	   if (me->option == FILENAME_MODE)
	   {
	       if (strcmp(me->ref_dir, ".") && (me->ref_dir[0] != '\0'))
	       {
		   strcpy(buffer,me->ref_dir);
		   strcat(buffer, "/");
	       }
	       else buffer[0] = '\0';

	       strcat(buffer, text);
	   }
	   else strcpy(buffer, text);

      
 if(me->option == SCALE_MODE)
 {
  FIg_get_state(me->status_display_form_ptr, BACKGROUND, &back_state);
  FIg_get_state(me->status_display_form_ptr, CLIPPING, &clip_state);
  FIg_get_state(me->status_display_form_ptr, UPDATE, &update_state);

  FIfld_get_text (me->status_display_form_ptr,ATTACHNAME, 0, 0,
                  DI_PATH_MAX, (unsigned char *)attach_name, &sel, &i);

  if(back_state == 0)
  {
     me->ref_properties = me->ref_properties & ~GRRF_BACKGROUND;
     backgr_flag = FALSE;
     gr$put_reffile_background( sizbuf = sizeof ( IGRboolean ),
                                buffer = &backgr_flag);
  }
  else
  {
     me->ref_properties = me->ref_properties | GRRF_BACKGROUND;
     backgr_flag = TRUE;
     gr$put_reffile_background( sizbuf = sizeof ( IGRboolean ),
                                buffer = &backgr_flag);
  }

  if(clip_state == 1)
  {
     me->ref_properties = me->ref_properties & ~GRRF_SHRINK_WRAP;
     shwr_flag = FALSE;
     gr$put_reffile_shrink_wrap( sizbuf = sizeof ( IGRboolean ),
                                 buffer = &shwr_flag);
  }
  else
  {
     me->ref_properties = me->ref_properties | GRRF_SHRINK_WRAP;
     shwr_flag = TRUE;
     gr$put_reffile_shrink_wrap( sizbuf = sizeof ( IGRboolean ),
                                 buffer = &shwr_flag);
  }

  if(update_state == 0)
            {
              me->ref_mode = 'W';
            }
           else
            {
              me->ref_mode = 'R';
            }

           if(attach_name[0] != NULL)
            {
              strcpy(me->name,attach_name);
            }

           FIfld_set_text (me->status_display_form_ptr,
                           ATTACHNAME,
                           0, 0, "", FALSE);

           sts = om$send(msg = message CEO.erase_form_by_label
                                    (form_label, 0, &msg),
                         targetid = my_id);

           me->form_requested = FALSE;
       }        
	   /*
	    * Set the text justification.
	    */
	   buffersize = strlen(buffer) + 1;
	   response = EX_STRING;

	   ex$putque ( msg = (IGRlong *)&msg,
		       response = &response,
		       byte = &buffersize,
		       buffer = buffer );

	   FIfld_set_select (form_ptr, gadget_label, (int)value, 0, FALSE);


	   me->option = -1;
	   break;
        }

      case FI_ACCEPT:

           FIg_get_state(me->status_display_form_ptr, BACKGROUND, &back_state);
           FIg_get_state(me->status_display_form_ptr, CLIPPING, &clip_state);
           FIg_get_state(me->status_display_form_ptr, UPDATE, &update_state);

           FIfld_get_text (me->status_display_form_ptr,ATTACHNAME, 0, 0, 
                           DI_PATH_MAX, (unsigned char *)attach_name, &sel, &i);
       
           if(back_state == 0)
            {
              me->ref_properties = me->ref_properties & ~GRRF_BACKGROUND;
              backgr_flag = FALSE;
              gr$put_reffile_background( sizbuf = sizeof ( IGRboolean ),
                                         buffer = &backgr_flag);
            }
           else
            {
              me->ref_properties = me->ref_properties | GRRF_BACKGROUND;
              backgr_flag = TRUE;
              gr$put_reffile_background( sizbuf = sizeof ( IGRboolean ),
                                         buffer = &backgr_flag);
            }

           if(clip_state == 1)
            {
              me->ref_properties = me->ref_properties & ~GRRF_SHRINK_WRAP;
              shwr_flag = FALSE;
              gr$put_reffile_shrink_wrap( sizbuf = sizeof ( IGRboolean ),
                                          buffer = &shwr_flag);
            }
           else
            {
              me->ref_properties = me->ref_properties | GRRF_SHRINK_WRAP;
              shwr_flag = TRUE;
              gr$put_reffile_shrink_wrap( sizbuf = sizeof ( IGRboolean ),
                                          buffer = &shwr_flag);
            }

           if(update_state == 0)
            {
              me->ref_mode = 'W';
            }
           else
            {
              me->ref_mode = 'R';
            }

           if(attach_name[0] != NULL)
            {
              strcpy(me->name,attach_name);
            }

           FIfld_set_text (me->status_display_form_ptr,
                           ATTACHNAME,
                           0, 0, "", FALSE);

           sts = om$send(msg = message CEO.erase_form_by_label
                                    (form_label, 0, &msg),
                         targetid = my_id);

           me->form_requested = FALSE;
        
           break;

     case FI_CANCEL:

           sts = om$send(msg = message CEO.erase_form_by_label
                                    (form_label, 0, &msg),
                         targetid = my_id);

           me->form_requested = FALSE;

           break;

           
   }


}

/*
Name
        is_associative

Description
        This function checks whether the located reference files object[s]
        contain associative relationships with the master file.
*/
action is_associative()
{
    int i, sts, msg, size, count;
    IGRlong rc;
    IGRboolean assoc;
    struct GRobj_env *list;

    /* use me->ret to get info back to the state table */
    me->ret = MSFAIL;

    /* grab a list of the located objects */
    sts = gr$gsinqcount(msg = &msg,
                        count = &count,
                        p_chanselect = &me->located_chansel);
    if (!(sts & msg & 1)) goto bail;
    size = sizeof(struct GRobj_env) * count;
    list = (struct GRobj_env *)alloca(size);
    sts = gr$gsget_objects(msg = &msg,
                           array = list,
                           size = size,
                           count = &count,
                           p_chanselect = &me->located_chansel);
    if (!(sts & msg & 1)) goto bail;

    /* check each object for associativity */
    for (i = 0, assoc = FALSE; i < count; i++)
    {
        sts = om$send(msg = message GRgraphics.GRisparent(&rc, &assoc),
                      targetid = list[i].obj_id.objid,
                      targetos = list[i].obj_id.osnum);
        
        if (!(sts & rc & 1))
        {
            continue;
        }
        
        if (assoc)
        {
            me->ret = MSSUCC;
            break;
        }
    }

  bail:

    return(OM_S_SUCCESS);
}

