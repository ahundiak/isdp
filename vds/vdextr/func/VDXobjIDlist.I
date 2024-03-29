/* $Id*/

/* I/VDS
 *
 * File:        vds/vdextr/func/VDXobjIDlist.I
 *
 * Description: Routines to create list of components for the input object.
 *
 * Dependencies: 
 *
 * Reference
 *      $Log: VDXobjIDlist.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/04/19  13:59:26  pinnacle
# for dynapipe
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/16/99        ylong           created
 *
 */

class implementation Root;

#include        <stdio.h>
#include        <string.h>
#include        <stdlib.h>
#include        <memory.h>
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "OMminimum.h"
#include        "OMerrordef.h"
#include        "OMparameters.h"
#include        "igrdef.h"
#include        "igr.h"
#include        "exdef.h"
#include        "ex.h"
#include        "igrdp.h"
#include        "gr.h"
#include        "growner.h"
#include        "go.h"
#include        "griodef.h"
#include        "grio.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "msdef.h"
#include        "msmacros.h"
#include        "exmacros.h"
#include        "grmacros.h"
#include        "AS_status.h"

#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"

#include        "v_miscmacros.h"
#include        "v_dbgmacros.h"

/* #include        "vdpktapis.h" */


/* External functions */

extern  int 	printf(const char *,...);
extern  char    *malloc();
extern  void    free();
extern  int     fflush();
extern  void    UI_message(char *symstr);
extern  IGRint  GRget_to_comp_info();

extern  char    *strchr();
extern  char    *strstr();
extern  char    *strcpy();
extern  int     strcmp();

        int     VDXcompare_int();

/*******************************************************************
*
*       Function VDXobjectID_list()
*
*  Makes list of all "ACmodel_mgr" components that are found in the path
*  "directory:sub_dir".
*  You may use "osnum:sub_dir" or "osnum:objid" or "directory:objid" instead.
*
*  Interface macro vdx$objectID_list is defined in $VDS/include/vdxmacros.h
*
*  NOTE: Function VDXmodel_list could be used instead.
*---------------------------------------------------------------------
*
*               HISTORY
*
* 04/22/96      KDD
*---------------------------------------------------------------------
*
*              PARAMETERS
*
* (I)   osnum           = active object space number
*                         Valid ONLY IF directory = NULL.
*
* (I)   *directory      = pathname to the active object space.
*
* (I)   objid           = Root object ID in the object space osnum.
*                         Valid ONLY IF sub_dir = NULL.
*
* (I)   *sub_dir        = name of the subdirectory to extract objects from.
*			  Corresponds to root object. 
*
* (I/O) *list           = pointer to the list of object IDs.
*                         Caller must secure enough storage space.
*
* (O)   *count_out      = number of objects in the output list.
*
*---------------------------------------------------------------------
*
*               RETURN STATUS
*
* (long)   1    = Always. 
*---------------------------------------------------------------------
*
*               ALGORITHM
*
*  1.  Get the pathname (di$give_pathname) and osnum (di$translate), of the
*      current object space.
*
*  2.  Get the "sub_dir" (di$untranslate) and "objid" (di$untranslate) of the 
*      root object.
*
*  3.  Get the full sub-directory tree (di$find) for root object == "pathname".
*
*  4.  Get the list of all "ACmodel_mgr" components for each entry in step 3.
*
*  5.  Sort (qsort) the IDs in the output list in increasing order.
*
*---------------------------------------------------------------------
*
*               EXAMPLE
*
*   Macro interface with vdx$objectID_list in $VDS/include/vdxmacros.h
*
*   Here [2,226] == ":xxxx:models_lib"
*   Note: the extra word ":IGENOD" provides the correct osnum.
*   NOTE: The caller allocates and frees memory for the pointer list.
*
*        char            *xxxx          = ":xxxx";
*        char            *models_lib    = ":models_lib";
*        GRspacenum      osnum          = 2;
*        IGRint          i              = 226;
*        GRobjid         *list          = NULL;
*        int             count;
*        IGRint          maxObj         = 8912;
*
*        list = (GRobjid *) malloc (maxObj * sizeof (GRobjid ));
*        if (list) free(list);
*
*        status = vdx$objectID_list(   osnum   = osnum,
*                                     sub_dir = models_lib,
*                                     list    = list,
*                                     count   = &count);
*
*        status = vdx$objectID_list(   osnum   = osnum,
*                                     objid   = (GRobjid) i,
*                                     list    = list,
*                                     count   = &count);
*
*        xxxx = ":xxxx:IGENOD";
*        status = vdx$objectID_list( directory = xxxx,
*                                     sub_dir = models_lib,
*                                     list    = list,
*                                     count   = &count);
*
*        xxxx = ":xxxx:usr";
*        status = vdx$objectID_list( directory = xxxx,
*                                     objid   = (GRobjid) i,
*                                     list    = list,
*                                     count   = &count);
*
*---------------------------------------------------------------------
*
*               NOTES
*
*  di$find allocates memory, therefore we use di$free. ($EXNUC/include)
*  i.e. we must free "lines" space.
*
*********************************************************************/
int VDXobjectID_list ( osnum, directory, objid, sub_dir, list, count_out)
                GRspacenum      osnum;
                char            *directory;
                GRobjid         objid;
                char            *sub_dir;
                GRobjid         *list;
                int             *count_out;
{

  char                  loc_mes[40];
  int                   i, len;
  struct GRid           ObjID ;
  long                  status, status1 ;
  GRobjid               Xobjid;
  GRspacenum            Xosnum;

  struct digrid         *grids ;
  DIint                 number, count, comp_count;
  DIchar                **lines;
  DIchar                pathname [DI_PATH_MAX];
  char                  classname[OM_K_MAXCLASS_LEN],
                        *ACmodel_mgr    = "ACmodel_mgr";

  SetProc( VDXobjectID_list ); Begin

  lines = NULL;
  count = 0;
  number = 0;
  status = 1;
  grids = NULL;

/*
* Input check
*/
  if ( (count_out == NULL) || (list == NULL ) )  {
        __DBGpr_com("Failed in VDXobjectID_list (count or list)");
        status = 0;
        goto wrapup ;
  };

/*
*       get the pathname, the osnum, the objid, and sub_dir
*/
  if (directory == NULL) {
        status = di$give_pathname( osnum    = osnum,
                                   pathname = pathname ) ;
  }
  else {
        strcpy(pathname, directory);
        status = di$translate(  objname = pathname,
                                p_objid = &Xobjid,
                                p_osnum = &osnum);
  }

  Xosnum = osnum;

  if (sub_dir == NULL) {
        status1 = di$untranslate( objname = pathname,
                                  objid   = objid,
                                  osnum   = Xosnum);
  }
  else {
        strcat(pathname, sub_dir);
        status1 = di$translate( objname = pathname,
                                p_objid = &objid,
                                p_osnum = &Xosnum);
  }

  if ( !(status & status1 & 1) ) {status = 0 ; goto wrapup;};

  ObjID.objid = objid;
  ObjID.osnum = osnum;

  __DBGpr_obj("Object ",ObjID);
  __DBGpr_str("Directory path ",pathname);

  strcpy(loc_mes,"Checking ");
  strcpy(&loc_mes[9],pathname);
  len = strlen(loc_mes);
  strcpy(&loc_mes[len]," components.");
  UI_message(loc_mes);

  status = di$find(     start_dir = pathname,
                        lines     = &lines,
                        grids     = &grids,
                        ptr       = &number);
  if ( !(status & DIR_S_SUCCESS) ) { goto wrapup;};

  __DBGpr_int("Number of components",number);

  for (i=0; i < number ; i++ ) {

        status = di$translate(  objname = lines[i],
                                p_objid = &ObjID.objid,
                                p_osnum = &ObjID.osnum);
        if ( !(status&1) ) continue;

        status = om$get_classname(      objid = ObjID.objid,
                                        osnum = ObjID.osnum,
                                    classname = classname ) ;
        if ( !(status&1) ) continue;

        if ( !strcmp(classname, ACmodel_mgr) ) {
                list[count] = ObjID.objid;
                count++;

                comp_count = VDXget_components( &ObjID,
                                                &list[count]);
                count += comp_count;

                __DBGpr_int("ACmodel_mgr =", ObjID.objid);

                continue;
        }
  }

  qsort(list, count, sizeof (GRobjid), VDXcompare_int);

wrapup:

  status = 1;

  fflush(stdout);

  if (lines) di$free ( lines = lines, count = number );

  if (count_out) *count_out = count;

  __DBGpr_int("Number of entries in the list = ", count);

  End

  return ( (long) status);
}

/*******************************************************************
*
*       Function VDXget_components() 
*
*  Puts the components of the object "Obj" in the list "list"
*
*---------------------------------------------------------------------
*
*               HISTORY
*
*  04/19/96     KDD
*---------------------------------------------------------------------
*
*              PARAMETERS
*
* (I)   *Obj            = object id and osnum
* (I/O) *list           = pointer to the list of components
*---------------------------------------------------------------------
*
*               RETURN VALUE
*
*  count                = total number of new loaded components.
*
*---------------------------------------------------------------------
*
*               ALGORITHM
*
*  Recursive search.
*  The caller sends the first available slot in the list of object IDs.
*  This function loads THE SAME LIST with the new components it finds.
*
*---------------------------------------------------------------------
*
*               NOTES
*
* Uses GRowner functionality but not GRcompowner.
* macro interface from $GRnuc/src/go/ownergo/GRcmpownfunc.I + GRowngetcomp.I
*
********************************************************************/
int VDXget_components(   Obj, list)
        struct GRid             *Obj;
        GRobjid                 *list;
{

   struct GRid          components;
   int                  i,
                        status,
                        count,
                        chld_count;

   IGRint               number;
   OMuint               list_count;
   OM_p_OBJECT_LINKAGE  list_ids;
   OM_S_CHANSELECT      chansel;

   SetProc( VDXget_components ); Begin

   list_ids = NULL;
   count = 0;
   status = 1;

   status = GRget_to_comp_info( &chansel,
                                Obj->osnum,
                                Obj->objid,
                                &number);
   if ( !(status &1) ) { goto wrapup;} ;

   list_ids = (OM_p_OBJECT_LINKAGE) malloc
               ( (sizeof (OM_S_OBJECT_LINKAGE)) * number);

   status = om$get_channel_objects ( osnum = Obj->osnum,
                                     objid = Obj->objid,
                              p_chanselect = &chansel,
                                      list = list_ids,
                                      size = number,
                                     count = &list_count);
   if ( !(status & 1)) list_count = 0;

   if (number != (int) list_count) {
        __DBGpr_obj("Wrong component count for object",*Obj);
        __DBGpr_int("NumOfComp from GRget_to_comp_info    ",number);
        __DBGpr_int("NumOfComp from om$get_channel_objects",list_count);
        number = 0;
   }

   for (i=0; i < number ; i++  ) {
        list[count] = (GRobjid) list_ids[i].S_objid;
        count = count + 1;

        components.osnum = Obj->osnum;
        components.objid = list_ids[i].S_objid;

        chld_count =
        VDXget_components(  &components,
                            &list[count]);

        count = count + chld_count;
   }

wrapup:

   if (list_ids) free(list_ids);

   End

   return (count) ;
}

/************************************************************************
*
*       Function VDXmodel_list
*
*  Makes list of "ACmodel_mgr" and "ACmodel" components in the current osnum.
*
*  NOTE: The Caller allocates enought memory for the pointer list. 
*
*  Note: Function VDXobjectID_list could be used instead.
*        The later is faster, but will miss ACmodel_mgr objects that are
*        not in the "sub_dir" subdirectory.
*
*---------------------------------------------------------------------
*
*               HISTORY
*
*   04/22/96    KDD
*
*---------------------------------------------------------------------
*
*               PARAMETERS
*
* (I)   maxobj          = maxinum number of objects in the space "osnum".
*
* (I)   osnum           = the active object space
*
* (I/O) *list           = the address of the available space to store
*                         the object IDs.
*
* (O)   *count_out      = number of entries loaded in the list.
*
*---------------------------------------------------------------------
*
*               RETURN STATUS
*
* (long)   1    = Always. 
*
*---------------------------------------------------------------------
*
*               ALGORITHM
*
*  Scan all objects in the space osnum, and select those that are
*  "ACmodel_mgr" and "ACmodel". Include all components of "ACmodel" in
*  the list.
*
*  Sort the IDs in the output list in increasing order.
*
*---------------------------------------------------------------------
*
*               EXAMPLE
*
*        IGRint          maxobj          = 0;
*        GRspacenum      osnum;
*        GRobjid         *list           = NULL;
*        int             count;
*
*        list = (GRobjid *) malloc (maxobj * sizeof (GRobjid ));
*        if (list) free(list);
*
*        status = VDXmodel_list( maxobj,
*                                osnum,
*                                list,
*                                &count);
*
************************************************************************/
int VDXmodel_list( maxobj, osnum, list, count_out)
        IGRint          maxobj;
        GRspacenum      osnum;
        GRobjid         *list;
        int             *count_out;
{
  struct GRid   ObjID;
  int           i;
  char          classname[OM_K_MAXCLASS_LEN],
                *ACmodel        = "ACmodel",
                *ACmodel_mgr    = "ACmodel_mgr";
  int           status;
  int           chld_count, count;

  SetProc( VDXmodel_list ); Begin

  ObjID.osnum = osnum;
  count = 0;

  __DBGpr_int("Checking osnum",ObjID.osnum);

  if ( (count_out == NULL) || (list == NULL ) )   goto wrapup;

  for (i = 1; i < maxobj; i++) {
        ObjID.objid = i;
        status = om$get_classname(      objid = ObjID.objid,
                                        osnum = ObjID.osnum,
                                    classname = classname ) ;
        if ( !(status&1) ) continue;

        if ( !strcmp(classname, ACmodel_mgr) ) {
                list[count] = ObjID.objid;
                count++;

                __DBGpr_int("ACmodel_mgr =", ObjID.objid);

                continue;
        }

        if ( !strcmp(classname, ACmodel) ) {
                list[count] = ObjID.objid;
                count++;
                chld_count = VDXget_components( &ObjID,
                                                &list[count]);
                count += chld_count;

                __DBGpr_int("ACmodel     =", ObjID.objid);

                continue;
        }

  }

  qsort(list, count, sizeof (GRobjid), VDXcompare_int);

  *count_out = count;

wrapup:

  status = 1;

  __DBGpr_int("Number of entries in the list = ", count);

  End

  return ( (long) status);
}

/************************************************************************
*
*       function VDXcompare_int (int a, int b)
*
*  Compares two integer numbers.
*  Returns:	0 	a == b
*		1	a > b
*	       -1	a < b
*
************************************************************************/
int VDXcompare_int( a, b)
    int *a, *b;
{
         return((*a == *b) ? 0 : (*a < *b) ? -1 : 1);
}

end implementation Root;
