/* #######################    APOGEE COMPILED   ######################## */
class implementation COdetail;

#include <coimport.h>
#include <stdio.h>
#include <FI.h>
#include <refdef.h>
#include <ref.h>
#include <grgsmacros.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <DImacros.h>
#include <OMlimits.h>
#include <FI.h>
#include <sys/types.h>
#include <sys/param.h>
#ifdef CLIX
#include <sys/dir.h>
#include <dirent.h>
#endif
#ifdef IRIX5
#include <dirent.h>
#define DIRSIZ MAXNAMLEN
#endif
#ifdef SUNOS5
#include <dirent.h>
#endif
#include <dpdef.h>
#include <dp.h>
#include <dpmacros.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <referr.h>
#include <grerr.h>
#include "detailco.h"
#include <alloca.h>
#include <sys/stat.h>
#include "exfi.h"

#ifdef SUNOS5
#define DIRSIZ 14
#endif

from GRgraphics   import GRdelete, GRdisplay, GRconstruct, GRgetrang, GRchgname;
from GRreffile    import GRgetenvironment;
from GRmodule     import GRmdremove;

#define EM_FORM_CANCELLED 0x099

method options_mode (int mode; char * info)
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
        FIg_reset (form, OPTIONS_FIELD);
        FIfld_set_mode (form, OPTIONS_FIELD, 0, FI_SINGLE_SELECT);
        FIg_erase (form, TITLE_FIELD);

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
#if defined SUNOS && defined XYXYX
	           strncpy(name, entry->d_name, DIRSIZ(entry));
        	            name[DIRSIZ(entry)] = '\0';
#else
	             strncpy(name, entry->d_name, DIRSIZ);
        	            name[DIRSIZ] = '\0';
#endif
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

	                FIg_erase (form, TITLE_FIELD);
        	        ex$message (msgnumb = GR_I_DgnFls, buff = msg_buff);

                	FIg_set_text (form, TITLE_FIELD, msg_buff);
	                FIg_display (form, TITLE_FIELD);

			for(Count=0;Count<row;Count++)
                	   FIfld_set_text ( form, OPTIONS_FIELD, Count, 0,
				    file_list[Count], 0 );

			free(file_list);

        	        closedir(dp);
	            }
        	    else FIfld_set_mode (form, OPTIONS_FIELD, 0, FI_REVIEW);
	            UI_status ("");
        	}

    	}
        break;
        case ORIENTATION_MODE:
        {
            static IGRlong default_views[7] = {GR_I_Top,    GR_I_Front,
                                               GR_I_Left,   GR_I_Right,
                                               GR_I_Bottom, GR_I_Back,
                                               GR_I_Iso};
            int row;

            ex$message (msgnumb = GR_I_Orients, buff = msg_buff);

            FIg_set_text (form, TITLE_FIELD, msg_buff);
            FIg_display (form, TITLE_FIELD);

            for (row=0; row<7; ++row)
            {
                ex$message (msgnumb = default_views[row], buff = msg_buff);

                FIfld_set_text ( form,
                                 OPTIONS_FIELD,
                                 row, 0,
                                 msg_buff, 0 );
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
            char name[1024];
            struct var_list list[2];

            ex$message (msgnumb = GR_I_WinVws, buff = msg_buff);

            FIg_set_text (form, TITLE_FIELD, msg_buff);
            FIg_display (form, TITLE_FIELD);

            /*
             * Get the module environment from the reference file id.
             */
            om$send ( msg = message GRreffile.GRgetenvironment (&ok,
                                                                &me->ModuleInfo,
                                                                &mod_env),
                      targetid = ((struct GRid *)info)->objid,
                      targetos = ((struct GRid *)info)->osnum );

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
                                         OPTIONS_FIELD,
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

                    if (ok & 1)
                    {
                        FIfld_set_text ( form,
                                         OPTIONS_FIELD,
                                         row++, 0,
                                         name, 0 );
                    }
                }
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

            ex$message (msgnumb = GR_I_Scales, buff = msg_buff);
            FIg_set_text (form, TITLE_FIELD, msg_buff);
	       FIg_display (form, TITLE_FIELD);

	       for (row =0; row<23; ++row)
	       {
		   FIfld_set_text ( form,
				    OPTIONS_FIELD,
				    row, 0,
				    iso_scales[row], 0 );
	       }
	   }
	       break;
	   }
       }
/*
 *  Now display the status display form.  We must let cob in on this so
 *  it will set the form_requested field.
 */
	if( me->option != -1 )
	{
       om$send( msg = message CEO.display_form_by_label( STATUS_FORM, &msg ),
                targetid = my_id );
	}

       return (OM_S_SUCCESS);
   }

   method options_notify ( int form_label;
			  int gadget_label;
			  double value;
			  char * form_ptr )
   {
       IGRchar buffer[1024];
       IGRchar text[EXFI_STRLEN];
       IGRint  r_pos;
       IGRint  sel_flag;
       IGRint  msg = MSSUCC;
       IGRlong buffersize;
       IGRint  response;

       switch ( gadget_label )
       {
       case FI_ACCEPT:
           me->option = -1;
	   /*
	    * Erase the options form.
	    */
	   om$send ( msg = message CEO.erase_form_by_label(form_label,0,&msg),
		     targetid = my_id );
	   break;
       case OPTIONS_FIELD:
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
	       if (strcmp(me->directory, ".") && (me->directory[0] != '\0'))
	       {
		   strcpy(buffer,me->directory);
		   strcat(buffer, "/");
	       }
	       else buffer[0] = '\0';

	       strcat(buffer, text);
	   }
	   else strcpy(buffer, text);

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

       return (OM_S_SUCCESS);
   }

   method query_file (long * msg; char * filename)
   {
       long                    status;
       int                     active;
       OMuword                 classid;
       struct GRvg_construct   const_list;
       struct IGRlbsys         lbsys;
       struct GRrf_info        rf_info;
       IGRuint                 properties;

       if (me->ref_id.objid != NULL_OBJID)
       {
	   om$send ( msg = message GRgraphics.GRdelete (msg, &me->ModuleInfo),
		     targetid = me->ref_id.objid,
		     targetos = me->ref_id.osnum );

	   me->ref_id.objid = NULL_OBJID;
	   me->ref_id.osnum = 0;
       }

       if (filename)
       {
	   IGRchar           write [MAXPATHLEN];

	   om$get_classid ( classname = "GRreffile",
			    p_classid = &classid );

	   const_list.msg = msg;
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
        MAidmx(msg,lbsys.matrix);

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
            GRmake_writable (msg, filename,NULL);
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
                               p_objid = &me->ref_id.objid );

        GRactive_owner_temp_clear (&active);

        me->ref_id.osnum = me->ModuleInfo.md_id.osnum;

        if ( !(status & *msg & 1) )
        {
            if ((*msg != GRVIEWNOTFOUND)    &&
                (*msg != GRNAMEDUPLICATED)  &&
                (*msg != GRFILENOTFOUND)    &&
                (*msg != GRSDGNEXCEED)      &&
                (*msg != OM_E_NO_OS_AVAIL))
            {
                 *msg = MSFAIL;
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
                            msg = message GRgraphics.GRchgname(msg,
                                                            &me->ModuleInfo,
                                                            refname),
                            targetid = me->ref_id.objid,
                            targetos = me->ref_id.osnum);
                    break;
                }
            }

            om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRgetrang ( msg,
                                                         &me->ModuleInfo.md_env.matrix_type,
                                                         me->ModuleInfo.md_env.matrix,
                                                         &world,
                                                         range ),
                    targetid = me->ref_id.objid,
                    targetos = me->ref_id.osnum);

            if (*msg & 1)
            {
		om$send ( msg = message GRmodule.GRmdremove ( msg,
                                                              range,
                                                              &me->ref_id.objid),
                          targetid = me->ModuleInfo.md_id.objid,
                          targetos = me->ModuleInfo.md_id.osnum);
            }
        }
    }

    return (OM_S_SUCCESS);
}

method set_option( int mode )
{
  me->option = mode;
  return (OM_S_SUCCESS);
}

int file_compare_func( file1, file2)
char **file1, **file2;
{
  return strcmp(*file1,*file2);
}

end implementation COdetail;
