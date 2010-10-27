/* $Id: vdmiscmacros.h,v 1.2 2001/02/19 17:08:12 paul_noel Exp $  */

/************************************************************************* 
* I/VDS
*
* File:	$VDS/include/vdmiscmacros.h
*
* Description: Misc macro definitions. 
*
* Dependencies:
*
* Reference
*	$Log: vdmiscmacros.h,v $
*	Revision 1.2  2001/02/19 17:08:12  paul_noel
*	Add macro for Table operations
*	
*	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
*	Initial import to CVS
*	
 * Revision 1.2  1998/04/30  19:02:10  pinnacle
 * Missing c++ bracket
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1998/04/23  14:24:34  pinnacle
 * ah
 *
 * Revision 1.2  1998/04/21  21:16:54  pinnacle
 * Replaced: include/vdmiscmacros.h for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1997/01/08  21:17:58  pinnacle
 * Replaced: include/vdmiscmacros.h for:  by kddinov for vds.241
 *
* Revision 1.1  1996/07/19  20:33:52  pinnacle
* Create VDS 241 project
*
* Revision 1.1  1996/05/01  21:50:06  pinnacle
* Created: include/vdmiscmacros.h by kddinov for vds.240
*
* History:
*	MM/DD/YY	AUTHOR		DESCRIPTION
*
*	04/30/96	KDD		vd$objectID_list
*	10/28/96	KDD		vd$get_file
*       04/23/98        ah              vd$sym_cl_place
*                                       I also added VDtypedef.h to avoid multiple includes
*                                       I also uncommented the function prototypes.
*       04/30/98        ah              closing cplusplus brackets left out
*************************************************************************/

#ifndef vd_miscmacros
#define vd_miscmacros	1

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#if 0
#include        "OMminimum.h"
#include        "OMerrordef.h"
#include        "OMparameters.h"
#include	"igetypedef.h"
#include        "igrtypedef.h"
#include        "igrdp.h"
#include        "gr.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif



extern int VDobjectID_list __((	GRspacenum      osnum,
		                char            *directory,
		                GRobjid         objid,
		                char            *sub_dir,
		                GRobjid         *list,
		                int             *count_out ));

extern int VDGetFile __((	char    *form_title,
		                char    *d_name,
		                char    *f_name,
		                char    *out_file,
		                char    *f_filter,
		                char    *d_filter,
		                int     last_search,
		                int     (*d_test)(),
		                int     (*f_test)()  )); 

extern IGRint VDclplace __((    IGRlong    	  *msg,
                                IGRint     	  num_cells,
                                IGRpoint  	  origins[],
                                IGRdouble  	  *angle,
                                IGRdouble  	  scale[],
                                IGRdouble  	  rot_matrix[],
                                IGRchar    	  name[], 
                                unsigned short 	  properties,
                                struct IGRdisplay *display,
                                IGRchar           *class_attr, 
                                IGRshort          *level, 
                                struct GRmd_env   *symbol_env, 
                                struct GRmd_env   *target_env,
                                char              classname[],
                                struct GRid       *sdh_id, 
                                struct GRid       cl_id[]    ));

#if defined(__cplusplus)
}
#endif

/*
extern int VDobjectID_list ();
extern int VDGetFile ();
*/
/*************************************************************************
*
* Macro definition: vd$objectID_list ()
*
* This macro provides the interface to the VDobjectID_list function.
* The function VDobjectID_list returns the list of IDs for the components
* of the input object.
*
*---------------------------------------------------------------------
*
*       PARAMETERS
*
* (I)   osnum           = active object space number
*
* (I)   *directory      = pathname to the active object space.
*
* (I)   objid           = object ID in the object space osnum.
*                         Valid ONLY IF sub_dir = NULL.
*
* (I)   *sub_dir        = name of the subdirectory to extract objects from.
*
* (I/O) *list      !    = pointer to the list of object IDs.
*                         Caller must secure the storage space (array, malloc).
*
* (O)   *count     !    = number of objects in the output list.
*
*---------------------------------------------------------------------
*
*               RETURN STATUS
*
* (long)   1    = Always.
*---------------------------------------------------------------------
*
*               EXAMPLE
*
*   Here [2,226] == ":xxxx:models_lib"
*   Note: the extra word ":IGENOD" provides the correct osnum.
*   Note: The caller allocates and frees memory for the pointer list.
*
*        char            *xxxx          = ":xxxx";
*        char            *models_lib    = ":models_lib";
*        GRspacenum      osnum          = 2;
*        IGRint          i              = 226;
*        GRobjid         *list          = NULL;
*        int             count;
*
*        list = (GRobjid *) malloc (maxObj * sizeof (GRobjid ));
*        if (list) free(list);
*
*        status = vd$objectID_list(   osnum   = osnum,
*                                     sub_dir = models_lib,
*                                     list    = list,
*                                     count   = &count);
*
*        status = vd$objectID_list(   osnum   = osnum,
*                                     objid   = (GRobjid) i,
*                                     list    = list,
*                                     count   = &count);
*
*        xxxx = ":xxxx:IGENOD";
*        status = vd$objectID_list( directory = xxxx,
*                                     sub_dir = models_lib,
*                                     list    = list,
*                                     count   = &count);
*
*        xxxx = ":xxxx:usr";
*        status = vd$objectID_list( directory = xxxx,
*                                     objid   = (GRobjid) i,
*                                     list    = list,
*                                     count   = &count);
*
********************************************************************/
#omdef  vd$objectID_list( osnum        = (GRspacenum) 0 ,
                          directory    = NULL,
                          objid        = (GRobjid)    0 ,
                          sub_dir      = NULL,
                          list         = NULL,
                          count        = NULL)

    VDobjectID_list(     (osnum), (directory), (objid), (sub_dir),
                               (list), (count))
#endomdef

/*************************************************************************
*
* Macro definition: vd$get_file ()
*
* This macro provides the interface to the VDGetFile function.
* The function VDGetFile invokes GUI (form) interface to select file from the
* UNIX directory system. 
*
*-----------------------------------------------------------------------------
*   Parameters:
*
*  I  char *title	- optional title on the form.
*
* I/O char *directory 	- search directory. Disregard if dir_flag = 1.
*                 	  if "." or "" starts with $PWD environmental variable.
*                 	  if NULL starts with the last search directory.
*
* I/O char *filename  	- filename, from the current directory.
*
*  O  char *out_file  !	- selected file. Full pathname == "dirname/filename".
*
*  I  char *file_filter - file name selection filter.
*
*  I  char *dir_filter  - directory name selection filter.
*
*  I  int last_search  	- 1 search using the path from the last call.
*			  0 start a new search.
*
*  I  int (*file_test())- FUNCTION to filter out the files.
*                 	  Takes one argument (char *) full_file_name.
*                 	  Returns 1 if the file is to be displayed, 0 otherwise.
*
*  I  int (*dir_test()) - FUNCTION to filter out the directories.
*                 	  Takes one argument (char *) full_dir_name.
*                 	  Returns 1 to display the directory, 0 otherwise.
*
*-----------------------------------------------------------------------------
*   Return status:
*       1       - success
*       0       - otherwise
*
*-----------------------------------------------------------------------------
*	EXAMPLE
*
*  char         dirname[80] =".",
*               filename[80]="",
*               out_file[80];
*
*  int          status;
*
*
*  status = vd$get_file( out_file 	= out_file);
*
*  status = vd$get_file( directory	= dirname, 
*			 filename	= filename, 
*			 out_file	= out_file, 
*			 last_search	= 1);
*
*  This example will reserve space for dirname, to get back the pathname. 
*
*  int is_drawing_file( char *name) { return 1; }  
*  strcpy(dirname,"                                                   ");
*
*  status = vd$get_file( directory      = dirname,
*                        filename       = filename,
*                        out_file       = out_file,
*                        file_filter    = "*.dat",
*                        file_test      = is_drawing_file,
*                        last_search    = 0);
*
*****************************************************************************/
#omdef  vd$get_file( 	title     	= NULL,
                     	directory 	= NULL,
			filename	= NULL,
			out_file,
			file_filter	= NULL,
			dir_filter	= NULL,
			last_search	= 0,
			dir_test	= NULL,
			file_test	= NULL)

    VDGetFile(	(title), (directory), (filename), (out_file), 
		(file_filter), (dir_filter), (last_search), 
		(dir_test), (file_test) )
#endomdef

/*--------------------------------------------------------------------------
Name
        vd$sym_cl_place

Description
        This macro is used to place a cell.

Synopsis
        IGRlong *msg                    return code
        IGRint num_cells                the number of cells to be constructed
        IGRpoint origin[]               the origins of the cells
        IGRdouble *angle                the angle (in radians)
        IGRdouble scale[]               an array of x,y,z scales
        IGRmatrix rot_matrix            matrix defining the way the cell
                                        is viewed. (View rotation)
        IGRchar name[]                  the name of the cell
        unsigned short properties       the properties of the cell
        struct IGRdisplay *display      ptr to display attributes
        IGRchar *class_attr             class specifiec attributes
        IGRshort *level                 the level of the cell
        struct GRmd_env *symbol_env     original symbol environment
        struct GRmd_env *target_env     environment to construct objects in
        IGRchar *classname              the class name of the cell
        struct GRid *sdh_id             the cell definition header
        struct GRid cl_id[]             the new cell id's

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
-----------------------------------------------------------------------------*/

#omdef vd$sym_cl_place (msg,
                        num_cells = 1,
                        origin,
                        angle,
                        scale,
                        rot_matrix,
                        name = NULL,
                        properties = GRIS_NEW | GRIS_DISPLAYABLE |
                                     GRIS_LOCATABLE,
                        display = NULL,
                        class_attr = NULL,
                        level = NULL,
                        symbol_env,
                        target_env,
                        classname = "GRclhdr",
                        sdh_id,
                        cl_id)

    VDclplace ((msg), (num_cells), (origin), (angle), (scale),
               (rot_matrix), (name), (properties), (display),
               (class_attr), (level), (symbol_env), (target_env),
               (classname), (sdh_id), (cl_id))
#endomdef

/* -------------------------------------------------------------------------
 *
 * Function to get nodelists based on selection rgColl 
 * and provide those lists for further processing 
 * I = rg_list (required to know list selection criterion)
 * I = rootNode (required for list selection give treeID if nodeName/nodeType selection used)
 * I = nodeName (check functionality) Not needed if sent rootNode
 * I = nodeType (check functionality) Not needed if sent rootNode
 * O = nodeList ( Memory allocated required)
 * O = nodeCnt  ( count of nodes in nodeList required)
 *
 * ------------------------------------------------------------------------- 
*/

extern IGRstat VDdrw_getSelectList __((struct ACrg_coll *rg_list,
                                       TGRid            *rootNode,
                                       IGRchar          *nodeName,
                                       IGRchar          *nodeType,
                                       TGRid           **nodeList,
                                       IGRint           *nodeCnt));
#omdef vddrw$GetSelectList(rg_list,
                          rootNode,
                          nodeName = NULL,
                          nodeType = NULL,
                          nodeList,
                          nodeCnt)

VDdrw_getSelectList((rg_list),
                    (rootNode),
                    (nodeName),
                    (nodeType),
                    (nodeList),
                    (nodeCnt))
#endomdef


#endif	/* vd_miscmacros */


