#ifndef refmacros_include
#define refmacros_include

/************************************************************************

    Description:

    This macro is used to change a reference file attachment type. The
    available types are normal and background.  Background attachments
    are only retrieved when attached to the master file. The user can
    specify the attachment to be changed by either attachment object
    id or by attachement name.

    gr$chg_ref_type(
		msg,
		ref_os = OM_Gw_current_OS,
		ref_id = NULL_OBJID ^
		attachment_name = NULL,
		background = TRUE)

    Arguments:

    IGRlong *msg		(O)	Completion code.
					MSSUCC - Completed successfully.
					MSFAIL - Failed.

    OMuword ref_os		(I)	Reference attachement object osnum.

    OM_S_OBJID ref_id		(I)	Reference attachement object id.

    IGRchar *attachment_name	(I)	Reference attachement name.

    IGRboolean background	(I)	If TRUE, the attachement is made
					a background one.
 ************************************************************************/

#omdef  gr$chg_ref_type(
		msg,
		ref_os = OM_Gw_current_OS,
		ref_id = NULL_OBJID ^
		attachment_name = NULL,
		background = TRUE)

	GRchgreftype(msg, ref_id, ref_os, attachment_name, background);		
	
#endomdef

/*************************************************************************

  Description :

    This macro is used to attach a reference file.

      gr$attach_reffile(
                msg,
                filename,
                mod_env = (struct GRmd_env *)NULL,
                attachment_name = NULL,
                ref_properties = GRRF_SHRINK_WRAP,
                updatable = TRUE,
                saved_view = NULL,
                window_grid = (struct GRid *)NULL,
                window_name = NULL,
                rot_matrix = NULL,
                origin = (IGRdouble *)NULL,
                scale = NULL,
                ref_grid = (struct GRid *)NULL,
                ref_osnum = (GRspacenum *)NULL)

  Arguments :

  IGRlong  *msg              (O)   Completion code.
                                   MSSUCC - Completed successfully.
                                   MSFAIL - Failed.
  IGRchar  *filename         (I)   Name of the file to be attached.
  struct GRmd_env *mod_env   (I)   Module environment.
  IGRchar  *attachment_name  (I)   Attachment name.
  IGRulong ref_properties    (I)   Reference file properties defined
                                   in refdef.h.
  IGRboolean updatable       (I)   Updatable flag, if TURE attachment
                                   will be updatable else read-only.
  IGRchar *saved_view        (I)   Saved view name.
  struct GRid *window_grid   (I)   GRid of the window.
  IGRchar *window_name       (I)   Window name.
  IGRmatrix rot_matrix       (I)   View rotation matrix.
  IGRdouble *origin          (I)   Reference file origin.
  IGRchar *scale             (I)   Scale
  struct GRid *ref_grid      (O)   GRid of the reference file.
  GRspacenum *ref_osnum      (O)   Reference file object space number.

  Notes:
         If the user specifies window_grid, window_name and rot_matrix,
    the order of presedence will be rot_matrix, window_grid and then
    window_name.

  Examples :

        gr$attach_reffile(msg = &msg,
                          filename = filename,
                          ref_properties = GRRF_SHRINK_WRAP|GRRF_BACKGROUND,
                          updatable = TRUE,
                          ref_grid = &ref_grid);

***************************************************************************/

#omdef  gr$attach_reffile(
                msg,
                filename,
                mod_env = (struct GRmd_env *)NULL,
                attachment_name = NULL,
                ref_properties = GRRF_SHRINK_WRAP,
                updatable = TRUE,
                saved_view = NULL,
                window_grid = (struct GRid *)NULL,
                window_name = NULL,
                rot_matrix = NULL,
                origin = (IGRdouble *)NULL,
                scale = NULL,
                ref_grid = (struct GRid *)NULL,
                ref_osnum = (GRspacenum *)NULL)
                
#if !om$specified(filename)
#omerror "Must specify the <filename>"
#else
#if !om$specified(saved_view) && om$specified(origin)
#omerror "Must specify <saved_view> with <origin>"
#else
#if om$specified(origin) && !om$specified(window_grid) && !om$specified(window_name) && !om$specified(rot_matrix)
#omerror "Must specify <window_grid> or <window_name> or <rot_matrix> with <origin>"
#else
        GRattach_reffile(msg,filename,mod_env,attachment_name,ref_properties,
                       updatable,saved_view,window_grid,window_name,
                       rot_matrix,origin,scale,ref_grid,ref_osnum);
#endif
#endif
#endif
#endomdef

/**************************************************************************

  Description :

     This macro is used to get the reference file parameters.

      gr$get_ref_parameters(
                msg,
                ref_grid = (struct GRid *)NULL^
                ref_name = NULL,
                mod_env = (struct GRmd_env *)NULL,
                ref_properties = NULL,
                updatable = (IGRboolean *)NULL,
                filename = NULL,
                scale = NULL,
                saved_view = NULL,
                ref_osnum = (GRspacenum *)NULL)
  Arguments :

     IGRlong  *msg            (O)   Completion code.
                                    MSSUCC - successfully completed.
                                    MSFAIL - failed.   
     struct GRid *ref_grid    (I)   GRid of the reference file.
     IGRchar  *ref_name       (I)   Name of the reference file.
     struct GRmd_env *mod_env (I)   Module environment.
     IGRulong *ref_properties (O)   Reference file properties defined
                                    in refdef.h
     IGRboolean *updatable    (O)   Updatable flag.
     IGRchar  *filename       (O)   Filename. The size should be of
                                    DI_PATH_MAX.
     IGRchar  *scale          (O)   Scale.
     IGRchar  *saved_view     (O)   Saved view name.
     GRspacenum   *ref_osnum  (O)   Reference file object space number 

  Examples :

        gr$get_ref_parameters(msg = &msg,
                              ref_name = "piston",
                              ref_properties = &ref_props,
                              filename = filename);

**************************************************************************/

#omdef  gr$get_ref_parameters(
                msg,
                ref_grid = (struct GRid *)NULL^
                ref_name = NULL,
                mod_env = (struct GRmd_env *)NULL,
                ref_properties = NULL,
                updatable = (IGRboolean *)NULL,
                filename = NULL,
                scale = NULL,
                saved_view = NULL,
                ref_osnum = (GRspacenum *)NULL )

#if !om$specified (ref_grid) && !om$specified (ref_name)
# omerror "Must specify <ref_grid> or <ref_name>"
#else
        GRgetrefinfo(msg,ref_grid,ref_name,mod_env,ref_properties,updatable,
                     filename,scale,saved_view,ref_osnum);
#endif

#endomdef

/**************************************************************************

  Description :

     This macro is used to change the reference file attachment by
     putting the new reference file parameters.

      gr$put_ref_parameters(
                msg,
                ref_grid = (struct GRid *)NULL^
                ref_name = NULL,
                mod_env = (struct GRmd_env *)NULL,
                ref_properties = 0,
                filename = NULL,
                attachment_name = NULL,
                scale = NULL)
  Arguments :

     IGRlong  *msg            (O)   Completion code.
                                    MSSUCC - successfully completed.
                                    MSFAIL - failed.   
     struct GRid *ref_grid    (I)   GRid of the reference file.
     IGRchar  *ref_name       (I)   Name of the reference file.
     struct GRmd_env *mod_env (I)   Module environment.
     IGRulong ref_properties  (I)   Reference file properties defined
                                    in refdef.h.
     IGRchar  *filename       (I)   Filename.
     IGRchar *attachment_name (I)   Attachment name.
     IGRchar  *scale          (I)   Scale.

  Examples :

        gr$put_ref_parameters(msg = &msg,
                              ref_name = "piston",
                              ref_properties = GRRF_SHRINK_WRAP,
                              filename = filename);

************************************************************************/
                
#omdef  gr$put_ref_parameters(
                msg,
                ref_grid = (struct GRid *)NULL^
                ref_name = NULL,
                mod_env = (struct GRmd_env *)NULL,
                ref_properties = 0,
                filename = NULL,
                attachment_name = NULL,
                scale = NULL)

#if !om$specified (ref_grid) && !om$specified (ref_name)
# omerror "Must specify <ref_grid> or <ref_name>"
#else
        GRputrefinfo(msg,ref_grid,ref_name,mod_env,ref_properties,
                     filename,attachment_name,scale);
#endif

#endomdef

/**********************************************************************

   Description :

      This macro will review the reference files and sends the output
    to the output_file.This macro also returns all the first level
    reference files GRids and attachment names for a given object space.

       gr$review_ref_files(msg,
                          output_file = NULL^
                          ref_osnum = (GRspacenum *)NULL,
                          num_found = NULL,
                          ref_grids = NULL,
                          ref_names = NULL)

   Arguments :

      IGRlong      *msg         (O)  Completion code.
      IGRchar      *output_file (I)  Output file name.
      GRspacenum   *ref_osnum   (I)  Reference file osnum.
      IGRint       *num_found   (O)  Number of ref files found in first
                                     level.
      struct GRid  **ref_grids  (O)  List of GRids of the reference files.
                                     The required memory will be allocated
                                     by the macro, the user should free
                                     the pointer.
      IGRchar      ***ref_names (O)  List of attachment names of the
                                     reference files.
                                     The required memory will be allocated
                                     by the macro, the user should free 
                                     the pointer.
   Examples :

   #include "cieveryone.h"
   #include "cilocate.h"
   #include "cievent.h"
   #include "cisend.h"
   #include "cidef.h"
   #include "OMindex.h"
   #include "igetypedef.h"
   #include "griodef.h"
   #include "stdio.h"
   #include "refdef.h"
   #include "ref.h"
   #include "refmacros.h"


   main()
    {
       long int msg;
       struct GRid *ref_ids;
       int num_ref,i;
       IGRchar **ref_names;

       gr$review_ref_files(msg = &msg,
                          output_file = "/usr/tmp/revrep",
                          ref_grids = &ref_ids,
                          ref_names = &ref_names,
                          num_found = &num_ref);
                    
      for(i=0; i < num_ref; i = i +1)
       {
          printf("ref_objid: %d\n",ref_ids[i].objid);
          printf("ref_osnum: %d\n",ref_ids[i].osnum);
          printf("ref_name: %s\n",ref_names[i]);
       }

     free(ref_ids);

     for(i=0; i < num_ref; i = i + 1)
      {
         free(ref_names[i]);
      }

     free(ref_names);
   }

***********************************************************************/

#omdef gr$review_ref_files(msg,
                          output_file = NULL^
                          ref_osnum = (GRspacenum *)NULL,
                          num_found = NULL,
                          ref_grids = NULL,
                          ref_names = NULL)

#if !om$specified (output_file) && !om$specified (ref_osnum)
# omerror "Must specify <output_file> or <ref_osnum>"
#else
       GRrevreffiles(msg,output_file,ref_osnum,num_found,ref_grids,ref_names); 
#endif
#endomdef
					
#endif
