
#ifndef vdsetmacro_include
#define vdsetmacro_include

/* I/VDS
 *
 * File:        ~VDS/include/vdsetmacros.h
 *
 * Description: This file defines macros for sets 
 *
 * History:
 *      18/11/94        Chaya V. Rao
 *      29/02/96        Ravi.         Modified the vd$give_setobjs macro.
 *
 */

/*============================================================================*/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDcreate_set __(( char               *set_name,
                             char               delete_existing,
                             struct GRobj_env   *comps,
                             int                numcomps,
                             struct GRmd_env    *set_env,
                             struct GRid        *set_grid
                            ));

extern int VDsetgrid_to_name __(( struct GRid       *set_grid,
                                  int               maxchar,
                                  char              *set_name
                               ));

extern int VDsetname_to_grid __(( char             *set_name,
                                  struct GRid      *set_grid
                               ));

extern int VDsetname_to_gridenv __(( char                    *set_name,
                                     struct GRobj_env        *VDset_grid
                                  ));

extern int VDGive_setobjs __((  struct GRid     *set_grid,
                                char            *set_name,
				struct GRmd_env *set_env,
                                int             *numcomps,
                                struct GRid     *set_objs,
				struct GRobj_env *setobj_envs
                            ));

extern int VDadd_to_set __(( struct GRid      *set_grid,
                             char             *set_name,
                             struct GRobj_env *comps,
                             int              numcomps
                          ));

extern int VDdelete_set __(( char    *set_name    
                          ));

extern int VDdel_setobjs __((  struct GRid       *set_grid,
                               char              *set_name,
                               int               numcomps,
                               struct GRobj_env  *comps
                           ));

extern	int VD_CheckObjInList __((
				struct GRid obj,
				struct GRobj_env *list1,
				int cnt1,
				struct GRobj_env *list2,
				int cnt2
				));

extern	int VD_CheckObjectFromListOrSet __((
				long		*msg,
				struct GRid	*setId,
				int		count,
				struct GRobj_env *list,
				int		*outCount,
				struct GRobj_env **outList,
				int		option ));


#if defined(__cplusplus)
}
#endif

/*
 * the following return codes are expected for the macros
 * as described below.
 */
#define         SUCCESS         1
#define         FAILURE         0
#define         SET_EXISTS      2     

/*============================================================================*/
/*
 * option masks defined.
 */

#define         VD_K_set_Chk_Owned      0x0001
#define         VD_K_set_Chk_Dangle     0x0002
#define         VD_K_set_Chk_Correct    0x0004
#define         VD_K_set_Chk_TblHdr     0x0008
#define         VD_K_set_Chk_TblRow     0x0010
#define         VD_K_set_Chk_drw3dVw    0x0020
#define         VD_K_set_Chk_drw2dVw    0x0040
#define         VD_K_set_Chk_drwGeom    0x0080          /* Drawing support  */
#define         VD_K_set_Chk_VShelper   0x0100          /* Struct support   */
#define         VD_K_set_Chk_RelHdr     0x0200          /* VDrelat_hdr      */

#define		VD_K_set_Chk_Cell	0x1000		/* GRclhdr class    */
#define		VD_K_set_Chk_Symbol	0x2000		/* GRsmhdr class    */	

#define		VD_K_set_Chk_Default	0x0FFF


/*============================================================================*/
/* ---------------------------------------------------------------------------

MARCO

    vd$create_set (  );

ABSTRACT
     
    This macro creates a set

ARGUMENTS

        data type         argument     I/O    description
         
        char             *set_name       i    - name of set to be constructed 
        char             delete_existing i    - if TRUE, delete any existing set
                                                by the same name 
        struct GRobj_env *comps;         i    - list of objects to connect to 
                                                the set 
        int              numcomps;       i    - number of objects to connect to
                                                the set
        struct GRmd_env  *set_env;       i    - module environment 
        struct GRid      *set_grid;      o    - objid/osnum of created set 

EXAMPLE

        vd$create_set( set_name        = set_name,
                       delete_existing = 0,
                       comps           = comps,
                       numcomps        = numcomps,
                       set_env         = &set_env,
                       set_grid        = &set_grid ); 
REMARKS

        make_source has to be done to the objects if from reference file
        before creating a set with those objects.

Return Status

        SUCCESS      if set created
        SET_EXISTS   if a set already exists
        FAILURE      if cannot create set

---------------------------------------------------------------------------- */

#omdef vd$create_set ( set_name,
                       delete_existing = 0,
                       comps,
                       numcomps,
                       set_env,
                       set_grid )

       VDcreate_set( (set_name), (delete_existing), (comps), (numcomps),
                     (set_env), (set_grid) )

#endomdef

/*============================================================================*/

/* -----------------------------------------------------------------------------

  MARCO

     vd$setgrid_toname ( );
  
  ABSTRACT

     This macro gets the name of a set given the id of the set

  ARGUMENTS

        data type         argument    I/O     description

        struct GRid       *set_grid    i       - objid/osnum of created set 
        int               maxchar      i       - max length of set name 
        char              *set_name    o       - name of set to be constructed 

  EXAMPLE

       vd$setgrid_toname ( set_grid  = &set_grid,
                           maxchar   = maxlength,
                           set_name  = set_name,
                          );

  Return Status
    
       OM_S_SUCCESS  
                           
  --------------------------------------------------------------------------- */

#omdef vd$setgrid_toname( set_grid,
                          maxchar,
                          set_name
                         )

       VDsetgrid_to_name( (set_grid), (maxchar), (set_name) )

#endomdef

/*============================================================================*/

/* ---------------------------------------------------------------------------- 

MACRO

   vd$setname_togrid ( );

ABSTRACT

   This macro gets GRid of a set given the set name

ARGUMENTS

        data type         argument    I/O     description

        char              *set_name    i      - name of set to be constructed 
        struct GRid       *set_grid    o      - objid/osnum of created set 

EXAMPLE
  
        vd$setname_togrid( set_name  = set_name,
                           set_grid  = &set_grid,
                         );

Return Status

       OM_S_SUCCESS

---------------------------------------------------------------------------- */ 

#omdef vd$setname_togrid( set_name,      
                          set_grid
                         )

       VDsetname_to_grid( (set_name), (set_grid) )

#endomdef

/*============================================================================*/

/*-----------------------------------------------------------------------------

MACRO

  vd$setname_tobjenv ( );

ABSTRACT

  This macro gets GRobj_env of a set given the setname

ARGUMENTS
 
        data type         argument    I/O     description

        char              *set_name    i      - name of set 
        struct GRobj_env  *VDset_grid  o      - objid/osnum of created set 

EXAMPLE

    vd$setname_tobjenv( set_name   = set_name,
                        VDset_grid = &VDset_grid,
                       );

Return Status

    OM_S_SUCCESS

 ---------------------------------------------------------------------------- */

#omdef vd$setname_tobjenv( set_name,
                           VDset_grid
                          )

        
       VDsetname_to_gridenv( (set_name), (VDset_grid) )

#endomdef

/*============================================================================*/

/* ---------------------------------------------------------------------------

MACRO

   vd$give_setobjs ( );

ABSTRACT

   This macro gives the number of set objects and their grids given the set name

ARGUMENTS

   data type         argument    I/O     description
 
   struct GRid     *set_grid     i - objid/osnum of set 
   char            *set_name     i - name of set to be constructed 
   int             *numcomps     o - number of objects in set
   struct GRid     *set_objs     o - objects connected to the set

EXAMPLE

    vd$give_setobjs( set_grid = &set_grid,
                     set_name = set_name,
                     numcomps = &numcomps,
                     set_objs = set_objs
                   );

REMARKS

    user ALLOCATES memory for set_objs depending on numcomps

Return Status
    
    SUCCESS     if success 
    FAILURE     if failure 

----------------------------------------------------------------------------- */

#omdef vd$give_setobjs( set_grid = NULL, 
                        set_name,
			set_env  = NULL,
                        numcomps = NULL,
                        set_objs = NULL,
			setobj_envs = NULL
                      )
       VDGive_setobjs( (set_grid), (set_name), (set_env), (numcomps),	
			(set_objs), (setobj_envs) ) 

#endomdef

/*============================================================================*/                           
/* ---------------------------------------------------------------------------

MACRO

  vd$add_to_set ( );

ABSTRACT
  
  adds given set components to set

ARGUMENTS

  data type         argument    I/O     description
  
  struct GRid       *set_grid    i - objid/osnum of set 
  char              *set_name    i - name of set to be constructed
  struct GRobj_env  *comps       i - list of objects to connect to the set 
  int               numcomps     i - number of objects to connect to the set

EXAMPLE

   vd$add_to_set ( set_grid = &set_grid,
                   set_name = set_name,
                   comps    = comps,
                   numcomps = numcomps
                 );

Return Status

       SUCCESS   if success
       FAILURE   if failure


 -----------------------------------------------------------------------------*/

#omdef

     vd$add_to_set( set_grid = NULL,
                    set_name,
                    comps,
                    numcomps 
                  )

     VDadd_to_set( (set_grid), (set_name), (comps), (numcomps) ) 

#endomdef

/*============================================================================*/

/*---------------------------------------------------------------------------

MACRO

  vd$delete_set ( );

ABSTRACT

  Given a set by its name, deletes it

ARGUMENTS

  data type         argument    I/O     description

  char             *set_name    i      -name of set to be deleted  

EXAMPLE

    vd$delete_set ( set_name );

Return Status

  OM_S_SUCCESS

--------------------------------------------------------------------------*/
#omdef

 vd$delete_set ( set_name )

 VDdelete_set( ( set_name) )

#endomdef

/*==========================================================================*/

/* ---------------------------------------------------------------------------

MACRO

   vd$delete_from_set ( );

ABSTRACT

   This macro deletes objects from set given the set name

ARGUMENTS

   data type         argument    I/O     description
 
   struct GRid     *set_grid     i - objid/osnum of set 
   char            *set_name     i - name of set to be constructed 
   int             *numcomps     i - number of objects 
   struct GRobj_env*comps        i - objects to be deleted

EXAMPLE

    vd$delete_from_set( set_grid = &set_grid,
                        set_name = set_name,
                        numcomps = &numcomps,
                        comps    = set_objs
                      );

Return Status
    
    SUCCESS     if success 
    FAILURE     if failure 

----------------------------------------------------------------------------- */

#omdef vd$delete_from_set( set_grid = NULL, 
                           set_name,
                           numcomps,
                           comps 
                         )

       VDdel_setobjs( (set_grid), (set_name), (numcomps), (comps) ) 

#endomdef

/*============================================================================*/                           
/* ---------------------------------------------------------------------------

MACRO

   vd$filter_objects( );

ABSTRACT

   This macro filter out objects from the input set, which can be a 
   list of GRobj_env or a 'setId'.

   When 'iList' & 'iCount' is given the returned list need to be freed by 
   the caller function.

ARGUMENTS

	data_type	argument	I/O	description
 
	long		msg		O	Return code.
	struct GRid	*setId		I	GRgrset id object.
	int		iCount		I	# objs in List.
	struct GRobj_env *iList		I	List of Objects.
	int		*oCount		O	# objs in filtered List
	struct GRobj_env **oList	O	List of filtered objects
	int		option		I	Filter Option.

EXAMPLE

	vd$filter_objects(	msg	= &msg,
				setId	= &setId );

	vd$filter_objects(	msg	= &msg,
				iCount	= inCount,
				iList	= inList,
				oCount	= &outCount,
				oList	= &outList );
				setId	= &setId );

Return Status
    
	SUCCESS     if success 
	FAILURE     if failure 

----------------------------------------------------------------------------- */

#omdef vd$filter_objects(	msg,
				setId	= NULL ^
				iList	= NULL,
				iCount	= 0,
				oCount	= NULL,
				oList	= NULL,
				option	= VD_K_set_Chk_Default )
#	if om$specified( setId )
		VD_CheckObjectFromListOrSet( (msg), (setId),
					0, NULL, NULL, NULL, (option) )
#	else om$specified( iList )
#	    if om$equal( iCount, 0 )
#		omerror "vd$filter_objects: `iCount' must be set."
#	    elif om$equal( oList, NULL ) || om$equal( oCount, 0 )
#		omerror "vd$filter_objects: `oList' or `oCount' must be set."
#	    else
		VD_CheckObjectFromListOrSet( (msg), NULL, 
				(iCount), (iList), (oCount), (oList), (option))
#	    endif
#	endif
#endomdef
	
/*============================================================================*/                           
#endif
 

