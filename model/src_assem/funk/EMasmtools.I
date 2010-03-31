class implementation EMdescribe;

#include <stdio.h>
#include <string.h>
#include <grimport.h>
#include <OMindex.h>
#include <DIprims.h>
#include <grerr.h>
#include <msmacros.h>
#include <grmessage.h>
#include <alloca.h>
#include <OMmacros.h>
#include <exmacros.h>
#include <OMminimum.h>
#include <OMlimits.h>
#include <OMOSfilehdr.h>
#include <igrtypedef.h>
#include <igrdef.h>
#include <igr.h>
#include <igrdp.h>
#include <grownerdef.h>
#include <gocmacros.h>
#include <godef.h>
#include <go.h>
#include <griodef.h>
#include <grio.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <limits.h>
#include <dpdef.h>
#include <dp.h>
#include <dpmacros.h>
#include <refdef.h>
#include <ref.h>
#include <csdef.h>
#include <grcoordsys.h>

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

extern OMuword	OPP_EMinstance_class_id;

from GRgraphics import GRconstruct;

IGRlong EMconstruct_reffile (IGRlong         * msg,
                             struct GRmd_env * mod_env,
                             IGRchar         * filename,
                             IGRchar         * view,
                             IGRuint           props,
                             IGRuint           ref_props,
                             IGRchar         * name,
                             IGRdouble       * origin,
                             IGRdouble       * matrix,
                             struct GRid     * reffile_id)
{
    IGRlong                 om_msg = OM_S_SUCCESS;
    struct GRvg_construct   arglist;
    struct IGRlbsys         lbsys;
    struct IGRdisplay       display;
    IGRshort                level;
    struct GRrf_info        rf_info;
    IGRmatrix               loc_matrix;
    IGRlong                 size;
    IGRshort                i = 4;

    /*
     * Get active display.
     */
    size = sizeof(struct IGRdisplay);
    om_msg = gr$get_active_display (msg = msg,
                                    sizbuf = &size,
                                    buffer = &display,
                                    nret = &size);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Get active level.
     */
    size = sizeof(IGRshort);
    om_msg = gr$get_active_level (msg = msg,
                                  sizbuf = &size,
                                  buffer = &level,
                                  nret = &size);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Setup the construction list.
     */
    arglist.msg = msg;
    arglist.env_info = mod_env,
    arglist.properties = props,
    arglist.geometry = (IGRchar *) &lbsys;
    arglist.display = &display;
    arglist.level = level;
    arglist.newflag = FALSE;
    arglist.name = name;
    arglist.class_attr = (char *)&rf_info;

    /*
     * Setup the reference file class attributes list.
     */
    rf_info.filename = filename;
    rf_info.named_view = NULL;
    rf_info.clip_poly = NULL;
    rf_info.prism_classname = NULL;
    rf_info.description = NULL;
    rf_info.ref_properties = &ref_props;
    rf_info.scale = "1";

    /*
     * If there is specific placement information ...
     */
    if (origin && matrix)
    {
        rf_info.named_view = view;

        /*
         * Reconstruct the window matrix.
         */
        MAtrnmx (msg, &i, matrix, loc_matrix);
    
        if (!(*msg & 1))
        {
            goto quit;
        }
    
        /*
         * Form the local bounded system geometery.
         */
        GRformlbsys (msg, loc_matrix, origin, &lbsys);
        
        if (!(*msg & 1))
        {
            goto quit;
        }
    }    
    else /* 1:1 attachment */
    {
        /* 
         * Load identity matrix.
         */
        MAidmx(msg,lbsys.matrix);

        /*
         * Design file limits.
         */
        lbsys.diag_pt1[0] = lbsys.diag_pt1[1] = lbsys.diag_pt1[2] = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt2[0] = lbsys.diag_pt2[1] = lbsys.diag_pt2[2] = (double)(GRDGNLIMITS_MAX_D - 1.0);
    }
    
    reffile_id->osnum = mod_env->md_id.osnum;

    /*
     * If the file is meant to be writable. Set the writable flag
     * for the file. Why we have to set the read only bit it it
     * will eventually be writable is not known???
     */
    if (!(ref_props & GRRF_IS_READ_ONLY))
    {
        ref_props |= GRRF_IS_READ_ONLY;
        GRmake_writable (msg, filename, NULL);
    }
    
    /*
     * Construct the reference file object.
     */ 
    om_msg = om$construct (classname = "GRreffile",
                           msg = message GRgraphics.GRconstruct(&arglist),
                           p_objid = &(reffile_id->objid),
                           osnum = reffile_id->osnum);
 quit:
    
    return (om_msg);
}

IGRlong EMconstruct_handle (IGRlong         * msg,
                            struct GRmd_env * mod_env,
                            IGRuint           props,
                            IGRchar         * name,
                            IGRdouble       * origin,
                            IGRdouble       * matrix,
                            struct GRid     * handle_id)
{
    IGRlong               om_msg = OM_S_SUCCESS;
    struct IGRlbsys       lbs_geom;
    struct GRvg_construct arglist;
    struct GRcs_construct cs_args;
    struct IGRdisplay     display;
    IGRshort              level;
    IGRlong               size;
    IGRint                i = 4;
    
    /*
     * Get active display.
     */
    size = sizeof(struct IGRdisplay);
    om_msg = gr$get_active_display (msg = msg,
                                    sizbuf = &size,
                                    buffer = &display,
                                    nret = &size);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Get active level.
     */
    size = sizeof(IGRshort);
    om_msg = gr$get_active_level (msg = msg,
                                  sizbuf = &size,
                                  buffer = &level,
                                  nret = &size);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Copy the orientation matrix.
     */
    for (i=0; i<16; ++i)
    {
        lbs_geom.matrix[i] = matrix[i];
    }

    /*
     * Add the origin.
     */
    for (i=0; i<3; ++i)
    {
        /*
         * If they didn't pass in an origin, assume it's
         * already in the placement matrix.
         */
        if (origin)
        {
            lbs_geom.matrix[3 + (4 * i)] = origin[i];
        }
        
        lbs_geom.diag_pt1[i] = 0;
        lbs_geom.diag_pt2[i] = 0;
    }
    
    /*
     * Setup argument list.
     */
    cs_args.desc = NULL;
    cs_args.flag = CS_CONNECT_TO_MGR;
    cs_args.type = RECTANGULAR;

    /*
     * Set construction list for coord. sys.
     */
    arglist.msg        = msg;
    arglist.env_info   = mod_env;
    arglist.display    = &display;
    arglist.level      = level;
    arglist.geometry   = (IGRchar *)&lbs_geom;
    arglist.properties = props;
    arglist.newflag    = FALSE;
    arglist.name       = name;
    arglist.class_attr = (IGRchar *)&cs_args;
    
    /*
     * Construct a graphic handle for the part instance.
     */
    handle_id->osnum = mod_env->md_id.osnum;
    
    om_msg = om$construct (classname = "GRgencs",
                           msg = message GRgraphics.GRconstruct(&arglist),
                           osnum = handle_id->osnum,
                           p_objid = &(handle_id->objid));

 quit:
    
    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_named_attribute                                             |
 |                                                                           |
 | This function checks for a particular named attribute in an attribute list|
 |                                                                           |
 | Input:   IGRchar     * name      Name of the attribute to be found.       |
 |          IGRint        num_attrs Number of attributes in list.            |
 |          EMattr      * attrs     Attribute list.                          |
 |                                                                           |
 | Return:  EMattr      *           Pointer to attribute or NULL if notfound |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
EMattr * EMget_named_attribute (IGRchar * name,
                                IGRint    num_attrs, 
                                EMattr  * attrs)
{
    IGRint i;
    
    if (name && attrs && (num_attrs > 0))
    {
        for (i=0; i<num_attrs; ++i)
        {
            if (!strcmp(name, attrs[i].info.name))
            {
                return &attrs[i];
            }
        }
    }
    
    return NULL;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMadd_obj_to_untree                                               |
 |                                                                           |
 | This function adds an object to the untranslate tree with a specified     |
 | name.                                                                     |
 |                                                                           |
 | Input:  struct GRid  * id        Object's id.                             |
 |         struct GRid  * dir_id    Directory id.                            |
 |         IGRchar      * name      Name to add.                             |
 |                                                                           |
 | Note:                                                                     |
 |                                                                           |
 | If the directory has more than one name in the directory system the obj   | 
 | will be added relative to each of those names.                            |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 | dkk              9/2/94      modified to fix problem in renaming localpart|
 +---------------------------------------------------------------------------*/
IGRlong EMadd_obj_to_untree (struct GRid * id,
                             struct GRid * dir_id,
                             IGRchar     * name)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    IGRchar     dirname[DI_PATH_MAX], loc_name[DI_PATH_MAX];
    DIint       num_names, i, status = DIR_S_SUCCESS;
    OMuword     classid;
    struct GRid loc_id;
    
    /* 
     * Start an untranslate on the dir_id. This is done since there might be
     * a number of names and I want to have this object named
     * relative to each of those directory names.
     */
    di$start_untrans (objid = dir_id->objid,
                      osnum = dir_id->osnum,
                      ptr   = &num_names);
    
    for (i=0; i<num_names; ++i)
    {
        di$fetch_untrans (index = i, objname = dirname);

        DIunall (id->osnum,
                 id->objid,
                 dirname,
                 name,
                 0, NULL, NULL);
    }
    
    /*
     * Set the flag that says this object is named.
     */
    OM_DI_SET (id->osnum, id->objid);

    /*
     * Get the object's class.
     */
    om$get_classid (objid = id->objid,
                    osnum = id->osnum,
                    p_classid = &classid);
    
    /*
     * If it's a directory ...
     */
    if (om$is_ancestry_valid (superclassid = OPP_IGRdir_class_id,
                              subclassid = classid) == OM_S_SUCCESS)
    {
        i=0;
        loc_id.osnum = id->osnum;

        /* Added this if condition - 09/02/94 */
	if((id->objid != dir_id->objid) && (id->osnum != dir_id->osnum))
	{
        /* 
         * Add all it's members to the untranslate tree.
         */
        while ((status == DIR_S_SUCCESS) && (om_msg & 1))
        {
            om_msg = om$send (msg = message IGRdir.translate (&status,
                                                              NULL,
                                                              i++,
                                                              loc_name,
                                                              &loc_id.objid),
                              senderid = NULL_OBJID,
                              targetid = id->objid,
                              targetos = id->osnum);
            
            if ((om_msg & 1) && (status == DIR_S_SUCCESS))
            {
                EMadd_obj_to_untree (&loc_id, id, loc_name);
            }
        }
        
        om_msg = OM_S_SUCCESS;
        status = DIR_S_SUCCESS;
	}
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMrem_obj_from_untree                                             |
 |                                                                           |
 | This function removes an object from the untranslate tree. If only the    |
 | object's id is specified then all names will be removed. If a directory   |
 | id is specified only the object's name relative to that directory will be |
 | removed from the untranslate tree.                                        |
 |                                                                           |
 | Input:  struct GRid  * id            Object's id.                         |
 |         struct GRid  * dir_id        Directory id.                        |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 | dkk              9/2/94      modified to fix problem in renaming localpart|
 +---------------------------------------------------------------------------*/
IGRlong EMrem_obj_from_untree (struct GRid * id,
                               struct GRid * dir_id)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    IGRint      i;
    IGRboolean  remove;
    IGRchar     name[DI_PATH_MAX], fullname[DI_PATH_MAX], dirname[DI_PATH_MAX];
    struct GRid loc_dir_id, loc_id;
    DIint       deleted = 0;
    DIint       num_names, status = DIR_S_SUCCESS;
    OMuword     classid;
    
    /*
     * Get the object's class.
     */
    om$get_classid (objid = id->objid,
                    osnum = id->osnum,
                    p_classid = &classid);
    
    /*
     * If it's a directory ...
     */
    if (om$is_ancestry_valid (superclassid = OPP_IGRdir_class_id,
                              subclassid = classid) == OM_S_SUCCESS)
    {
        /* Added this if condition - 09/02/94 */
	if((id->objid != dir_id->objid) && (id->osnum != dir_id->osnum))
	{
        i = 0;
        loc_id.osnum = id->osnum;
        
        /* 
         * Remove all it's members from the untranslate tree before
         * it is removed.
         */
        while ((status == DIR_S_SUCCESS) && (om_msg & 1))
        {
            om_msg = om$send (msg = message IGRdir.translate (&status,
                                                              NULL,
                                                              i++,
                                                              NULL,
                                                              &loc_id.objid),
                              senderid = NULL_OBJID,
                              targetid = id->objid,
                              targetos = id->osnum);
            
            if ((om_msg & 1) && (status == DIR_S_SUCCESS))
            {
                EMrem_obj_from_untree (&loc_id, id);
            }
        }
        
        om_msg = OM_S_SUCCESS;
        status = DIR_S_SUCCESS;
	}
    }
    
    /* 
     * Start an untranslate on the object.
     */
    di$start_untrans (objid = id->objid,
                      osnum = id->osnum,
                      ptr   = &num_names);
    
    for (i=num_names-1; i>=0; --i)
    {
        if (di$fetch_untrans (index = i, objname = fullname) != DIR_S_SUCCESS)
        {
            break;
        }

        di$split (pathname = fullname, dirname = dirname, name = name);

        remove = FALSE;
        
        if (dir_id)
        {
            loc_dir_id.objid = NULL_OBJID;
            
            if (di$translate (objname = dirname, 
                              p_objid = &(loc_dir_id.objid),
                              p_osnum = &(loc_dir_id.osnum)) == DIR_S_SUCCESS)
            {
                if ((loc_dir_id.objid == dir_id->objid) &&
                    (loc_dir_id.osnum == dir_id->osnum))
                {
                    remove = TRUE;
                }
            }
        }
        else
        {
            remove = TRUE;
        }

        if (remove)
        {
            DIunall (id->osnum, id->objid, dirname, name, 1, NULL, &deleted);
        }
    }

    /*
     * If all names have been removed.
     */
    if (deleted)
    {
        /*
         * Clear the named bit on the object.
         */
        OM_DI_RESET(id->osnum, id->objid);
    }
    
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMrename_directory                                                |
 |                                                                           |
 | This function renames a directory with respect to it's primary owner      |
 | directory.                                                                |
 |                                                                           |
 | Input:  struct GRid     * dir_id   Directory to update with respect to.   |
 |         IGRchar         * new_name New name for the directory.            |
 |                                                                           |
 | Output: IGRlong         * msg     Return.                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  12/4/93     creation                                     |
 | dkk              09/02/94    modified to fix problem in renaming instances|
 +---------------------------------------------------------------------------*/
IGRlong EMrename_directory (IGRlong     * msg,
                            struct GRid * dir_id,
                            IGRchar     * new_name)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    DIint       status = DIR_S_SUCCESS, i;
    IGRchar     old_name[DI_PATH_MAX], loc_dir_name[DI_PATH_MAX];
    IGRchar     path[DI_PATH_MAX], loc_name[DI_PATH_MAX];
    struct GRid loc_dir_id, loc_id;
    OM_S_OBJID  objid;
    OMuword     classid;

    /*
     * Get the fullname of the describe object.
     */
    if (di$untranslate (objid = dir_id->objid,
                        osnum = dir_id->osnum,
                        objname = path) != DIR_S_SUCCESS)
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Get the name of the describe object's primary directory.
     */
    if (di$split (pathname = path,
                  dirname  = loc_dir_name,
                  name     = old_name) != DIR_S_SUCCESS)
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Get the id of the describe objects primary directory.
     */
    if (di$translate (objname = loc_dir_name,
                      p_objid = &loc_dir_id.objid,
                      p_osnum = &loc_dir_id.osnum) != DIR_S_SUCCESS)
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
    
    /*
     * Make sure the new_name is legal.
     */
    om_msg = om$send (msg = message IGRdir.translate (&status, 
                                                      new_name,
                                                      -1,
                                                      NULL,
                                                      &objid),
                      senderid = NULL_OBJID,
                      targetid = loc_dir_id.objid,
                      targetos = loc_dir_id.osnum);
    
    if (om_msg & status & 1)
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
    else
    {
        om_msg = OM_S_SUCCESS;
        status = DIR_S_SUCCESS;
    }

    /*
     * Remove the describe object's members from the untranslate tree.
     */
    i = 0;
    loc_id.osnum = dir_id->osnum;
    
    while ((status == DIR_S_SUCCESS) && (om_msg & 1))
    {
        om_msg = om$send (msg = message IGRdir.translate (&status,
                                                          NULL,
                                                          i++,
                                                          NULL,
                                                          &loc_id.objid),
                          senderid = NULL_OBJID,
                          targetid = dir_id->objid,
                          targetos = dir_id->osnum);

        if ((om_msg & 1) && (status == DIR_S_SUCCESS))
        {
            EMrem_obj_from_untree (&loc_id, dir_id);
        }
    }
    
    om_msg = OM_S_SUCCESS;
    status = DIR_S_SUCCESS;

    /* 
     * Remove the directory object from it's primary directory, this
     * will also remove it from the untranslate tree.
     */
    /* Check if the directory being renamed is EMinstance, if so, 
       send the IGRdir.remove message OM_e_wrt_message so that
       the EMcachepart's override is not used. This is because,
       the EMcachepart_IGRdir_remove_method is removing the 
       cachepart itself if the instance being deleted is the last one,
       which definitely is not the behavior we want here - 09/02/94
    */

    om$get_classid (objid = dir_id->objid,
                    osnum = dir_id->osnum,
                    p_classid = &classid);
    
    /*
     * If it's a EMinstance directory ...
     */
    if (om$is_ancestry_valid (superclassid = OPP_EMinstance_class_id,
                              subclassid = classid) == OM_S_SUCCESS)
    {
        om_msg = om$send (msg = message IGRdir.remove (&status, 
                                                   old_name, 
                                                   -1),
                      senderid = NULL_OBJID,
                      mode = OM_e_wrt_message,
                      targetid = loc_dir_id.objid,
                      targetos = loc_dir_id.osnum);
    }
    else
    {
        om_msg = om$send (msg = message IGRdir.remove (&status, 
                                                   old_name, 
                                                   -1),
                      senderid = NULL_OBJID,
                      targetid = loc_dir_id.objid,
                      targetos = loc_dir_id.osnum);
    }

    if (!(om_msg & status & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /* 
     * Add it back with the new name, this will put the directory
     * back in the untranslate tree with the new name.
     */
    om_msg = om$send (msg = message IGRdir.add (&status, 
                                                new_name,
                                                dir_id->objid,
                                                NULL),
                      senderid = NULL_OBJID,
                      targetid = loc_dir_id.objid,
                      targetos = loc_dir_id.osnum);

    if (!(om_msg & status & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Update the directory object's members in the untranslate tree.
     */
    i = 0;
    loc_id.osnum = dir_id->osnum;
    
    while ((status == DIR_S_SUCCESS) && (om_msg & 1))
    {
        om_msg = om$send (msg = message IGRdir.translate (&status,
                                                          NULL,
                                                          i++,
                                                          loc_name,
                                                          &loc_id.objid),
                          senderid = NULL_OBJID,
                          targetid = dir_id->objid,
                          targetos = dir_id->osnum);

        if ((om_msg & 1) && (status == DIR_S_SUCCESS))
        {
            EMadd_obj_to_untree (&loc_id, dir_id, loc_name);
        }
    }
    
    om_msg = OM_S_SUCCESS;
    status = DIR_S_SUCCESS;

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMis_om_file                                                      |
 |                                                                           |
 | This function determines if the input filename is an OM filed object space|
 |                                                                           |
 | Input:  IGRchar      * filename  Filename                                 |
 |                                                                           |
 | Return: IGRboolean               TRUE is OM file, FALSE otherwise.        |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/1/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRboolean EMis_om_file (IGRchar * filename)
{
    struct OM_sd_OS_filehdr_OM      filehdr;
    FILE                          * fp;
    IGRboolean                      is_om_file = FALSE;
    
    if (fp = fopen (filename, "r"))
    {
        if (fread(&filehdr, sizeof (struct OM_sd_OS_filehdr_OM), 1, fp) &&
            strlen(filehdr.start_time) == 25  &&   
            isalpha(filehdr.start_time[0])    &&
            isalpha(filehdr.start_time[1])    && 
            isalpha(filehdr.start_time[2])    &&
            (filehdr.start_time[3] == ' ')    && 
            isalpha(filehdr.start_time[4])    &&
            isalpha(filehdr.start_time[5])    && 
            isalpha(filehdr.start_time[6])    &&
            (filehdr.start_time[7] == ' ')    && 
            (isdigit(filehdr.start_time[8])   ||
             (filehdr.start_time[8] == ' '))  && 
            isdigit(filehdr.start_time[9])    && 
            (filehdr.start_time[10] == ' ')   &&
            isdigit(filehdr.start_time[11])   && 
            isdigit(filehdr.start_time[12])   &&
            (filehdr.start_time[13] == ':')   && 
            isdigit(filehdr.start_time[14])   &&
            isdigit(filehdr.start_time[15])   && 
            (filehdr.start_time[16] == ':')   &&
            isdigit(filehdr.start_time[17])   && 
            isdigit(filehdr.start_time[18])   &&
            (filehdr.start_time[19] == ' ')   && 
            isdigit(filehdr.start_time[20])   &&
            isdigit(filehdr.start_time[21])   && 
            isdigit(filehdr.start_time[22])   &&
            isdigit(filehdr.start_time[23]))
        {
            is_om_file = TRUE;
        }
        
        fclose(fp);
    }

    return is_om_file;
}

end implementation EMdescribe;




