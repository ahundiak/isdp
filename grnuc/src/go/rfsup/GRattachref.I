/*

  Name

     GRattach_reffile

  Abstract

     This function is used to attach the reference file.

  Arguments

     IGRlong      *msg          (O) completion code
     IGRchar *filename          (I) filename
     struct GRmd_env *mod_env   (I) module environment
     IGRchar *attachment_name   (I) attachment name
     IGRulong ref_properties    (I) reference file properties defined
                                    in refdef.h
     IGRboolean updatable       (I) updatable flag, if TRUE attachment
                                    will be updatable else read-only
     IGRchar *saved_view        (I) saved view name
     struct GRid *window_grid   (I) GRid of the window
     IGRchar *window_name       (I) window name
     IGRmatrix rot_matrix       (I) view rotation matrix
     IGRdouble *origin          (I) origin for the attachment
     IGRchar *scale             (I) scale
     struct GRid *ref_grid      (O) GRid of the reference file
     GRspacenum *ref_osnum      (O) reference file object space number

  Return Values

    -MSSUCC if successful
    -MSFAIL if failure

  History

     Gang     07/19/93    Creation date.

*/

class implementation GRreffile;

#include "stdio.h"
#include "coimport.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "msmacros.h"
#include "exmacros.h"
#include "grmessage.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "grimport.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "refdef.h"
#include "refmacros.h"

from IGEgragad  import	DPinrot;

extern int GRformlbsys();
extern int DEref_view_recalled();


IGRint GRattach_reffile(msg,
                        filename,
                        mod_env,
                        attachment_name,
                        ref_properties,
                        updatable,
                        saved_view,
                        window_grid,
                        window_name,
                        rot_matrix,
                        origin,
                        scale,
                        ref_grid,
                        ref_osnum)
IGRlong *msg;
IGRchar *filename;
struct GRmd_env *mod_env;
IGRchar *attachment_name;
IGRulong ref_properties;
IGRboolean updatable;
IGRchar *saved_view;
struct GRid *window_grid;
IGRchar *window_name;
IGRmatrix rot_matrix;
IGRdouble *origin;
IGRchar *scale;
struct GRid *ref_grid;
GRspacenum *ref_osnum;
{
    int		            sts;
    long                    msg1;
    OMuword                 classid;
    struct GRvg_construct   const_list;
    struct IGRlbsys         lbsys;
    struct GRmd_env         cur_mod;
    struct IGRdisplay       display;
    IGRshort                level;
    IGRlong                 nbytes_in_buff,nbytes_trans;
    struct GRrf_info        rf_info;
    struct GRid             win_id;
    struct GRid             ref_id;
    struct GRid             mod_id;
    IGRint                  count,i;
    IGRmatrix               window_rotation;
    unsigned int            properties;
    IGRchar                 views[100];
    IGRchar                 ref_scale[DI_PATH_MAX];
    IGRchar                 ref_filename[DI_PATH_MAX];
    enum GRdpmode           DisplayMode;
    IGRchar                 ref_mode;
    IGRchar                 mode[2];

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    ref_filename[0]=NULL;

    /*  
     * Set up the construct arguments.
     */

    GRfindrefpath(filename,ref_filename);
    if(access(ref_filename,0) == -1)
     {
         *msg = MSFAIL;
          sts = OM_E_ABORT;
          goto quit;
     }

    if(mod_env == NULL)
     {
        /* get the current module environment */

        nbytes_in_buff = sizeof(struct GRmd_env);
        sts = gr$get_module_env(msg = msg,
                                sizbuf = &nbytes_in_buff,
                                buffer = &cur_mod,
                                nret = &nbytes_trans);
        if(!(*msg & sts & 1))
         {
           goto quit;
         }
     }
    else
     {
        cur_mod = *mod_env;
     }

    /* Get active display */

    nbytes_in_buff = sizeof(struct IGRdisplay);
    sts = gr$get_active_display (msg = msg,
                                 sizbuf = &nbytes_in_buff,
                                 buffer = &display,
                                 nret = &nbytes_trans);
    if(!(sts & *msg & 1))
     {
       goto quit;
     }

    /* Get active level */ 

    nbytes_in_buff = sizeof(IGRshort);
    sts = gr$get_active_level(msg = msg,
                              sizbuf = &nbytes_in_buff,
                              buffer = &level,
                              nret = &nbytes_trans);
    if(!(sts & *msg & 1))
     {
       goto quit;
     }

    properties = 0;
    om$get_classid ( classname = "GRreffile", p_classid = &classid );

    const_list.msg = &msg1;
    const_list.env_info = &cur_mod;
    const_list.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    const_list.geometry = (IGRchar *) &lbsys;
    const_list.display = &display;
    const_list.level = level;
    const_list.newflag = FALSE;

    if(attachment_name != NULL)
      const_list.name = attachment_name;
    else
      const_list.name = NULL;
    const_list.class_attr = (char *)&rf_info;

    rf_info.filename = ref_filename;
    rf_info.named_view = (saved_view) ? saved_view : NULL;
    rf_info.clip_poly = NULL;
    rf_info.prism_classname = NULL;
    rf_info.description = NULL;
    properties = GRRF_IS_READ_ONLY;
    if(ref_properties & GRRF_BACKGROUND)
      {
         properties |= GRRF_BACKGROUND;
      }
    rf_info.ref_properties = &properties;
    if(scale)
      rf_info.scale = scale;
    else
     {
       strcpy(ref_scale,"1");
       rf_info.scale = ref_scale;
     }

    if ((origin) && (saved_view))
    {
        if((window_grid == NULL) && (window_name == NULL) &&
           (rot_matrix == NULL))
         {
             /* Load identity matrix. */
             MAidmx(msg,window_rotation);
         }
        else
         {
           if(rot_matrix == NULL)
            {
             if(window_grid == NULL)
              {
                count = 0;

                mod_id.objid = cur_mod.md_id.objid;
                mod_id.osnum = cur_mod.md_id.osnum;

                strcpy(views,GRDP_SAVEDVIEWS);
                strcat(views," ");
                strcat(views,GRDP_REGVIEWS);

                dp$get_gragad_id(
                           msg = msg,
                           mod_GRid = &mod_id,
                           name = window_name,
                           array_size = 1,
                           total_num = &i,
                           numberofids = &count,
                           found_GRids = &win_id,
                           search_priority = views);

               if(!count)
                {
                   *msg = MSFAIL;
                   goto quit;
                }
             }
            else
             {
                 win_id.objid = window_grid->objid;
                 win_id.osnum = window_grid->osnum;
             }
            sts = om$send ( msg = message IGEgragad.DPinrot ( msg,
                                                            window_rotation ),
                            senderid = NULL_OBJID,
                            targetid = win_id.objid,
                            targetos = win_id.osnum );
           }
          else
           {
             for(i=0; i< 16; i++)
              {
                window_rotation[i] = rot_matrix[i];
              }
           }
         }

        if (sts & *msg & 1)
        {
            GRformlbsys ( msg,
                          window_rotation,
			  origin,
			  &lbsys );
        }
    }
    else
    {
        /* 
         * Load identity matrix.
         */
        MAidmx(msg,lbsys.matrix);

        /*
         * Design file limits.
         */
        lbsys.diag_pt1[0]  = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt1[1]  = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt1[2]  = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt2[0]  = (double)(GRDGNLIMITS_MAX_D - 1.0);
        lbsys.diag_pt2[1]  = (double)(GRDGNLIMITS_MAX_D - 1.0);
        lbsys.diag_pt2[2]  = (double)(GRDGNLIMITS_MAX_D - 1.0);
    }

    if ( 1 & sts & *msg)
    {
      if(updatable)
       {
         ref_mode = 'W';
       }
      else
       {
         ref_mode = 'R';
       }

      /* check the read/write mode */

      sts = check_mode(ref_mode,ref_filename,mode);
      /* if the mode is writable, add that file to the list */
      if (mode[0] == 'W') GRmake_writable ( msg, ref_filename,NULL );
      sts = om$construct( osnum = cur_mod.md_id.osnum,
                             obj_osnum = cur_mod.md_id.osnum,
                             classid = classid,
                             msg = message GRgraphics.GRconstruct ( &const_list ),
                             p_objid = &(ref_id.objid) );

        ref_id.osnum = cur_mod.md_id.osnum;

        if ( sts & msg1 & 1 )
        {
            /*
             * Activate any symbology overrides.
             */
            if ( saved_view)
            {
                /*
                 * Activate any symbology overrides attached to 
                 * the reference file's saved view.
                 */
                DEref_view_recalled ( msg, 
                                      &ref_id, 
                                      &win_id );
            }   


            if(ref_properties & GRRF_SHRINK_WRAP)
             {
                /* Shrink/Wrap the clipping polygon */

                GRrfshwrclip(&msg1, &ref_id);
             }

            /*
             * Display the constructed object.
             */

            DisplayMode = GRbd;
            
            om$send ( mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRdisplay
                                        ( msg,
			                  &cur_mod.md_env.matrix_type,
                                          cur_mod.md_env.matrix,
                                          &DisplayMode, 
                                          &cur_mod.md_id ),
                      senderid = NULL_OBJID,
                      targetid = ref_id.objid,
                      targetos = ref_id.osnum );
        }
    }

   if ( !(sts & msg1 & *msg & 1) )
    {
        om$send ( msg = message GRgraphics.GRdelete ( msg, &cur_mod ),
                  senderid =  NULL_OBJID,
                  targetid = ref_id.objid, 
                  targetos = ref_id.osnum);

           *msg = MSFAIL;
    }
   else
    {
       if(ref_grid)
        {
           ref_grid->objid = ref_id.objid;
           ref_grid->osnum = ref_id.osnum;
        }

       if(ref_osnum)
        {
          sts = om$send(msg = message GRreffile.GRgetosnum(msg,ref_osnum),
                        senderid = NULL_OBJID,
                        targetid = ref_id.objid,
                        targetos = ref_id.osnum);
        }
    }
    

quit:
  return sts;
}


IGRint check_mode (ref_mode,
                   filename,
                   mode)
IGRchar ref_mode;
IGRchar *filename;
IGRchar *mode;
{
  IGRlong  sts;
  IGRboolean assoc_flag;

  sts = MSSUCC;
 gr$get_associative_flag (sizbuf = sizeof( IGRboolean ), buffer = &assoc_flag );

  /* Check if the file is in the list of writable files */
  GRis_writable ( &sts, filename, 0, (OMuword)0 );
  if (sts == MSSUCC)
    /* The file is writable (flag is ON and it is in the list) */
    mode[0] = 'W';
  else
    /* see if the file is open */
    if (ex$is_file_open ( name = filename))
    {
      long    msg;
      OMuword osnum = 0;

      /* The file is writable if it is the module and read-only otherwise */
      om$os_name_to_number ( osname = filename, p_osnum = &osnum );
      if (!osnum)
      {
        int  len = 1026;
        char buffer[1026];
        char *basename = NULL;

        /*
         * If this isn't a full pathname.
         */
        if (filename[0] != '/')
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
                strcat (buffer, filename);
                basename = buffer;
            }
            else /* Use the filename as is. */
            {
                basename = filename;
            }
        }
        else /* it's a full pathname */
        {
            basename = &(filename [strlen ( &filename[0] ) - 1]);

            /* let's try the base name */  
            for (; (*basename != '/') && (basename != &(filename [0])); 
                 basename--);
        }

        om$os_name_to_number ( osname = basename, p_osnum = &osnum );
      }

      if (osnum)
      {
        GRcheckref ( &msg, NULL, NULL, NULL, &osnum );
        mode[0] = msg == MSSUCC ? 'R' : 'W';
      }
      else
        mode[0] = 'W';
      sts = MSSUCC;
    }
    else
      /* It's a new file, the assoc flag is used to determine the attachment mode */
      if (assoc_flag)
      {
        FILE *fet;
        
        /* in order for the file to be read/write, we must have the write permission */
        fet = fopen ( filename, "r+" );
        if (!fet)
        {
          mode[0] = 'R';
          sts = MSSUCC;
        }
        else
        {
          /* Associativity is ON, the file is not already open and we can write to it */
          if(ref_mode == 'R')
             mode[0] = 'R';
          else
             mode[0] = 'W';
          fclose ( fet );
        }
      }       
      else
      {
        if(ref_mode == 'W')
         {
           FILE *fet;

           fet = fopen(filename, "r+");
           if(!fet)
           {
              mode[0] = 'R';
              sts = MSSUCC;
           }
           else
           {
             mode[0] = 'W';
             fclose(fet);
           }
         }
        else
           mode[0] = 'R';
      }

  return sts;
}

end implementation GRreffile;


