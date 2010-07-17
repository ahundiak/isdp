/****************************************************************************

        Description:

 	Correction done by Eric Faivre do correct the design file
 	with objects created before using VDSroot class.

	Below you find the problem description of Eric.


I found that the problem comes from the class VDSroot !!!.

When you create a plate in a new design file, the system creates the plate
but also some other objects ( OM objects ), one of this object is the
OMOSCO.

The OMOSCO object is unique and represents a class definition ( OM class ).
It contains some informations about the class it represent and the number
of objects of this class.

This is the class hierarchy of a source plate.

		 Root
		 |
		 V
		 .
		 .
		 |
		 NDnode
		 |
		 V
		 .
		 .
		 |
		 VDSroot
		 |
		 V
		 |
		 VScpx
		 |
		 V
		 |
		 VSsrcPlate

When constructing a plate the system see if the OMOSCO of the class
VSsrcPlate exist, if no it creates it. Looks the parent class, here VScpx.
See if the OMOSCO of the class VScpx exist, if no it creates it ... until
Root class.

You can have several plates, but you have only ONE OMOSCO of class VSsrcPlate.
The OMOSCO knows the number of elements of that class.

When you delete the plate, it's that you did on the test case, the system
delete the plate, and delete also all the OMOSCO if its number of element is
zero.

For example, you have two plates. You delete the first one. The system
deletes only the plate ( graphic ), it doesn't delete the OMOSCO because
the second plate still exist.

when you delete the second plate, the system deletes the plate ( graphic ).
Delete also the OMOSCO of the class VSsrcPlate. Looks the parent class,
here VScpx. See if the number of element of class VScpx still exist ( No,
because its an abstract class ), so it delete the OMOSCO of the class
VScpx ... until Root.

This is the mechanisum of the delete.

In the test case, the plates were created before the implementation of the
class VDSroot. So, the OMOSCO object of the class VDSroot doesn't exist in
the test case !!!

When you delete the last plate with the product where VDSroot is implemented.
The system assumes that the OMOSCO of the class VDSroot exist do delete it,
but, it doesn't exist and we have a memory fault ( the OMOSCO of the class
VDSroot is a NULL pointer in the list of OMOSCO ).

The problem appears here with a plate, but we can have the same thing which
all objects sub-classed from VDSroot !!! ( PIPING, LOFT, VDS, ... )

That means also that the file created in 2.2 ( where VDSroot doesn't exist )
will fail with some commands in 2.3 !!!


        History:
        EF     11-23-1994      Creation date

 ****************************************************************************/
/*
 	I/STRUCT
*/
class implementation VSrtUpdCmd ;

#include <stdio.h>
#include <string.h>
#include "exdef.h"
#include "OMtypes.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMminimum.h"
#include "OMextern.h"
#include "OMprimitives.h"
#include "OMintprims.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exmacros.h" 
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "expression.h"
#include "expmacros.h"
#include "AS_status.h"

/*
#define VS_SESSION_STARTUP	0
#define VS_DGNFILE_STARTUP	1
*/

/**
#define	DEBUG
 **/

/************************************************************************/
/*      USED FUNCTIONS                                                  */
/************************************************************************/


/*----------------------------------------------------------------------------*/
/*	Structure coming from OMOSCOi.c ( compilation of file OMOSCOi.I ).    */
/*----------------------------------------------------------------------------*/

/** comment out ---
struct Root_instance
  {
   OM_S_OBJECTHDR OPPobjecthdr;
  };
 **/

struct OMOSCO_instance
  {
   OM_S_OSCO OSCO;
   OM_p_CHANNEL_HDR    to_OSO;
   struct OM_sd_varlenarr_descr component_list_descr;
   struct OM_sd_varlenarr_descr vla_list_descr;
   struct OM_sd_varlenarr_descr chan_info_descr;
   struct OM_sd_varlenarr_descr res_classname_descr;
   struct OM_sd_varlenarr_descr res_channum_descr;
   int component_size;
   OMuword num_parents;
  };

struct OMOSCO_total_instance
 {
  struct Root_instance Root;
  struct OMOSCO_instance OMOSCO;
 };

/*----------------------------------------------------------------------------*/
int VS_modifyVDSrootOMOSCO( os, oid, w_child_refcnt )

OMuword       os ;
OM_S_OBJID    oid ;
int	      w_child_refcnt ; {

	long			sts ;
	OM_S_RIP		rip ;
	struct OMOSCO_instance	*myme ;
	OM_S_OSCO		*myOSCO ;

	myme   = NULL ;
	myOSCO = NULL ;

	sts = om$get_any_instance( osnum = os,
				   objid = oid,
				   p_rip = &rip ) ;
	if( !( sts & 1 ) ) return 0 ;

	myme   = &(((struct OMOSCO_total_instance *) rip.p_object)->OMOSCO) ;
	myOSCO = &(myme->OSCO) ;

	/*
	 * Set number of class directly subclassed from VDSroot.
	 */
	myOSCO->w_child_refcnt = (OMuword) w_child_refcnt ;

	return 1 ;

} /* VS_modifyVDSrootOMOSCO */

/*----------------------------------------------------------------------------*/

int VS_isAnOMOSCO( os, oid )

OMuword       os ;
OM_S_OBJID    oid ; {

	long		sts ;
	char		classname[OM_K_MAXCLASS_LEN] ;

	sts = om$get_classname( osnum	  = os,
				objid	  = oid,
				classname = classname ) ;

	if( !( sts & 1 ) ) return FALSE ;

	if( !strcmp( classname, "OMOSCO" ) ) return TRUE ;
	else return FALSE ;

} /* VS_isAnOMOSCO */

/*----------------------------------------------------------------------------*/

char *VS_classnameOfOMOSCO( os, oid )
OMuword       os ;
OM_S_OBJID    oid ; {

	long			sts ;
	OM_S_RIP		rip ;
	struct OMOSCO_instance	*myme ;
	OM_S_OSCO		*myOSCO ;

	myme   = NULL ;
	myOSCO = NULL ;

	sts = om$get_any_instance( osnum = os,
				   objid = oid,
				   p_rip = &rip ) ;
	if( !( sts & 1 ) ) return NULL ;

	myme   = &(((struct OMOSCO_total_instance *) rip.p_object)->OMOSCO) ;
	myOSCO = &(myme->OSCO) ;

	return myOSCO->s_name ;

} /* VS_classnameOfOMOSCO */

/*----------------------------------------------------------------------------*/

int VS_isAVDSrootOMOSCO( os, oid )
OMuword       os ;
OM_S_OBJID    oid ; {

	int	rc ;
	char	*classname ;

	rc = VS_isAnOMOSCO( os, oid ) ;

	if( !rc ) return FALSE ;

	classname = VS_classnameOfOMOSCO( os, oid ) ;

	if( classname == NULL ) return FALSE ;

	if( !strcmp( classname, "VDSroot" ) ) return TRUE ;
	else return FALSE ;

} /* VS_isAVDSrootOMOSCO */

/*----------------------------------------------------------------------------*/

int VS_nbClassDirectlySubclassedFromVDSroot() {

	long		sts ;
	int		i, j, max,
			count;
	OMuint		nb_parents ;
	struct GRid	curMod ;
	char		*OMOSCO_classname,
			classname[OM_K_MAXCLASS_LEN] ;
	OMuword 	OMOSCO_classid_parents[10] ;

	count = 0 ;

	ex$get_cur_mod( osnum = &curMod.osnum,
			id    = &curMod.objid ) ;

	max = OM_GA_OSDs[curMod.osnum]->CurSpaceMapSize ;

	for( i=0; i<max; i=i+1 ) {

		if( !VS_isAnOMOSCO( curMod.osnum, (OM_S_OBJID) i ) ) continue ;

		OMOSCO_classname = VS_classnameOfOMOSCO( curMod.osnum, 
						  (OM_S_OBJID) i ) ;

		if( OMOSCO_classname == NULL ) continue ;

		sts = om$get_all_parents( classname  = OMOSCO_classname,
					  parentlist = OMOSCO_classid_parents,
					  size	     = 10,
					  count      = &nb_parents ) ;

		if( !( sts & 1 ) ) continue ;

		for( j=0; j<nb_parents; j=j+1 ) {
			sts = om$get_classname(
					  classid   = OMOSCO_classid_parents[j],
					  classname = classname ) ;

			if( !( sts & 1 ) ) continue ;

			if( !strcmp( classname, "VDSroot" ) )
				count = count + 1 ;
		}
	}

	return count ;

} /* VS_nbClassDirectlySubclassedFromVDSroot */

/*----------------------------------------------------------------------------*/

int VS_CorrectDesignFiles() {

	long		sts;
	int		rc,
			i,
			max ;
	OMuword 	VDSrootClassid ;
	struct GRid	curMod,
			VDSrootId,
			VDSrootOMOSCO ;
	int		nbSubclassed ;

	VDSrootId.objid = NULL_OBJID ;

	ex$get_cur_mod( osnum = &curMod.osnum,
			id    = &curMod.objid ) ;

	/*
	 * See if VDSroot class is defined in the product.
	 */
	sts = om$get_classid( classname = "VDSroot",
			      p_classid = &VDSrootClassid ) ;

	if( !( sts & 1 ) ) {
#ifdef	DEBUG
		printf( "Class VDSroot not defined in the product\n" ) ;
		printf( "-> Do nothing\n" ) ;
#endif
		goto wrapup ;
	}

	/*
	 * See if OMOSCO for VDSroot already exist.
	 */
	max = OM_GA_OSDs[curMod.osnum]->CurSpaceMapSize ;

	for( i=0; i<max; i=i+1 ) {
		rc = VS_isAVDSrootOMOSCO( curMod.osnum, (OM_S_OBJID) i ) ;
		if( rc ) break ;
	}

	if( i<max ) {
#ifdef	DEBUG
		printf( "The OMOSCO object for VDSroot exist [%d,%d]\n",
							     curMod.osnum, i ) ;
		printf( "-> Do nothing\n" ) ;
#endif
		goto wrapup ;
	}

	/*
	 * We don't have an OMOSCO for VDSroot, so construct a VDSroot object.
	 * This construction will construct the OMOSCO object for VDSroot.
	 */
	VDSrootId.osnum = curMod.osnum ;

	sts = om$construct( classname = "VDSroot",
			    p_objid   = &VDSrootId.objid,
			    osnum     = VDSrootId.osnum ) ;

	if( !( sts & 1 ) ) {
		printf( "ERROR in constructing object of class VDSroot\n" ) ;
		goto wrapup ;
	}

	/*
	 * Retrieve the OMOSCO for VDSroot.
	 */
	max = OM_GA_OSDs[curMod.osnum]->CurSpaceMapSize ;

	for( i=0; i<max; i=i+1 ) {
		rc = VS_isAVDSrootOMOSCO( curMod.osnum, (OM_S_OBJID) i ) ;
		if( rc ) break ;
	}

	if( i<max ) {
		VDSrootOMOSCO.osnum = curMod.osnum ;
		VDSrootOMOSCO.objid = i ;
	} else {
		printf( "ERROR : The OMOSCO doesn't exist after construction !!!\n" ) ;
		goto wrapup ;
	}

#ifdef	DEBUG
	printf( "OMOSCO object for VDSroot : [%d,%d]\n", VDSrootOMOSCO.osnum,
							 VDSrootOMOSCO.objid ) ;
#endif

	/*
	 * Find number of classes directly subclassed from VDSroot.
	 */
	nbSubclassed = VS_nbClassDirectlySubclassedFromVDSroot() ;

#ifdef	DEBUG
	printf( "Number of classes directly subclassed from VDSroot : %d\n",
							nbSubclassed ) ;
#endif

	/*
	 * Now, modify the OMOSCO for class VDSroot.
	 */
	sts = VS_modifyVDSrootOMOSCO( VDSrootOMOSCO.osnum, VDSrootOMOSCO.objid,
				   nbSubclassed ) ;

	if( !( sts & 1 ) )
		printf( "ERROR : Cannot modify OMOSCO for class VDSroot\n" ) ;

	wrapup :
		if( VDSrootId.objid != NULL_OBJID ) {
			sts = om$send( msg	= message Root.delete( 1 ),
				       senderid = NULL_OBJID,
				       targetid = VDSrootId.objid,
				       targetos = VDSrootId.osnum ) ;

			if( !( sts & 1 ) )
				printf( "ERROR in deleting object of class VDSroot\n" ) ;
		}

		return sts ;

} /* VS_CorrectDesignFiles */
/*----------------------------------------------------------------------------*/


/************************************************************************/
/*      METHOD: execute ( update_text_leader of VDS command )           */
/************************************************************************/
method execute(	int *response ; char *response_data ; int pos ) {

  long		status;
  OM_S_OBJID	mod_id;
  GRspacenum	cur_os;
  IGRchar	file_name[DI_PATH_MAX],
		exp_name[DI_PATH_MAX],
		cur_dir[DI_PATH_MAX];
  struct GRid	tmp_obj;
  IGRlong	error = MSSUCC;

  /*
   * Test if the expression is already defined : if so the file 
   * was already update
   */
  cur_dir[0] = '\0';
  status = di$pwd(dirname = cur_dir);
  if( status != DIR_S_SUCCESS ){
        error = MSFAIL;
        goto wrapup;
  }
  ex$get_cur_mod( id = &mod_id, osnum = &cur_os );
  status = di$give_pathname( osnum = cur_os, pathname = file_name );
  if( status != DIR_S_SUCCESS ){
        error = MSFAIL;
        goto wrapup;
  }

  strcat( file_name, ":IGENOD" );
  sprintf( exp_name, "%s:NewVDroot", file_name );

  status = di$cd(dirname = file_name);
  if( status != DIR_S_SUCCESS ){
        error = MSFAIL;
        goto wrapup;
  }

  status = di$translate(	objname = exp_name,
				osnum	= cur_os,
				p_objid = &tmp_obj.objid);
  if(status == DIR_S_SUCCESS){
#ifdef DEBUG
     printf("File already update\n");
#endif
    goto wrapup;
  }
  else{
    /* Create the expression of file already update */
    status =  exp$create(exp_name  = "NewVDroot",
			 osnum     = cur_os,
			 exp_value = 0.0,
			 p_exp_id  = &tmp_obj);
    if(!(status & 1))
       printf("Can't create expression NewVDroot\n");

    di$cd(dirname = cur_dir);
  }

  status = VS_CorrectDesignFiles();

wrapup:
  if ( !( status & 1 ) ){ 
	printf("Warning problem with updating of VDSroot class.\n");
	return OM_S_SUCCESS;
  }

  if( cur_dir[0] != '\0' ){
    di$cd(dirname = cur_dir);
  }

  UI_status(" Verified VDSroot class definition." );

  *response = TERMINATE ;
  return OM_S_SUCCESS;

}


end implementation VSrtUpdCmd ;

