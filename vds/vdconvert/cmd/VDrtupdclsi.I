class implementation VDrtupdcls;



#include <stdio.h>
#include <string.h>
#include <math.h>
#include <values.h>
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
#include "exmacros.h" 
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "expression.h"
#include "expmacros.h"
#include "AS_status.h"
#include "v_dbgmacros.h"
#include "parametric.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

/**
#define	DEBUG
 **/
from NDnode     import NDgive_structure;
from expression import NDgive_value, NDset_value;
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
int VD_modifyVDSrootOMOSCO( os, oid, w_child_refcnt )

OMuword       os ;
OM_S_OBJID    oid ;
int	      w_child_refcnt ; {

	long			sts ;
	OM_S_RIP		rip ;
	struct OMOSCO_instance	*myme ;
	OM_S_OSCO		*myOSCO ;

        SetProc( VD_modifyVDSrootOMOSCO ); Begin
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

        End
	return 1 ;

} /* VD_modifyVDSrootOMOSCO */

/*----------------------------------------------------------------------------*/

int VD_isAnOMOSCO( os, oid )

OMuword       os ;
OM_S_OBJID    oid ; {

	long		sts ;
	char		classname[OM_K_MAXCLASS_LEN] ;

        SetProc( VD_isAnOMOSCO ); Begin 

	sts = om$get_classname( osnum	  = os,
				objid	  = oid,
				classname = classname ) ;

	if( !( sts & 1 ) ) return FALSE ;

	if( !strcmp( classname, "OMOSCO" ) ) {
               End
               return TRUE ;
        }
	else return FALSE ;

} /* VD_isAnOMOSCO */

/*----------------------------------------------------------------------------*/

char *VD_classnameOfOMOSCO( os, oid )
OMuword       os ;
OM_S_OBJID    oid ; {

	long			sts ;
	OM_S_RIP		rip ;
	struct OMOSCO_instance	*myme ;
	OM_S_OSCO		*myOSCO ;

        SetProc( VD_classnameOfOMOSCO ); Begin
	myme   = NULL ;
	myOSCO = NULL ;

	sts = om$get_any_instance( osnum = os,
				   objid = oid,
				   p_rip = &rip ) ;
	if( !( sts & 1 ) ) return NULL ;

	myme   = &(((struct OMOSCO_total_instance *) rip.p_object)->OMOSCO) ;
	myOSCO = &(myme->OSCO) ;

        End
	return myOSCO->s_name ;

} /* VD_classnameOfOMOSCO */

/*----------------------------------------------------------------------------*/

int VD_isAVDSrootOMOSCO( os, oid )
OMuword       os ;
OM_S_OBJID    oid ; {

	int	rc ;
	char	*classname ;
	
        SetProc( VD_isAVDSrootOMOSCO ); Begin 

	rc = VD_isAnOMOSCO( os, oid ) ;

	if( !rc ) return FALSE ;

	classname = VD_classnameOfOMOSCO( os, oid ) ;

	if( classname == NULL ) return FALSE ;

	if( !strcmp( classname, "VDSroot" ) ) {
             End 
             return TRUE ;
        }
	else return FALSE ;

} /* VD_isAVDSrootOMOSCO */

/*----------------------------------------------------------------------------*/

int VD_nbClassDirectlySubclassedFromVDSroot() {

	long		sts ;
	int		i, j, max,
			count;
	OMuint		nb_parents ;
	struct GRid	curMod ;
	char		*OMOSCO_classname,
			classname[OM_K_MAXCLASS_LEN] ;
	OMuword 	OMOSCO_classid_parents[10] ;

        SetProc( VD_nbClassDirectlySubclassedFromVDSroot ); Begin

	count = 0 ;

	ex$get_cur_mod( osnum = &curMod.osnum,
			id    = &curMod.objid ) ;

	max = OM_GA_OSDs[curMod.osnum]->CurSpaceMapSize ;

	for( i=0; i<max; i=i+1 ) {

		if( !VD_isAnOMOSCO( curMod.osnum, (OM_S_OBJID) i ) ) continue ;

		OMOSCO_classname = VD_classnameOfOMOSCO( curMod.osnum, 
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

        End
	return count ;

} /* VD_nbClassDirectlySubclassedFromVDSroot */

/*----------------------------------------------------------------------------*/

int VD_CorrectDesignFiles() {

	long		sts;
	int		rc,
			i,
			max ;
	OMuword 	VDSrootClassid ;
	struct GRid	curMod,
			VDSrootId,
			VDSrootOMOSCO ;
	int		nbSubclassed ;

        SetProc( VD_CorrectDesignFiles ); Begin 
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
		rc = VD_isAVDSrootOMOSCO( curMod.osnum, (OM_S_OBJID) i ) ;
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
		rc = VD_isAVDSrootOMOSCO( curMod.osnum, (OM_S_OBJID) i ) ;
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
	nbSubclassed = VD_nbClassDirectlySubclassedFromVDSroot() ;

#ifdef	DEBUG
	printf( "Number of classes directly subclassed from VDSroot : %d\n",
							nbSubclassed ) ;
#endif

	/*
	 * Now, modify the OMOSCO for class VDSroot.
	 */
	sts = VD_modifyVDSrootOMOSCO( VDSrootOMOSCO.osnum, VDSrootOMOSCO.objid,
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

                End
		return sts ;

} /* VD_CorrectDesignFiles */
/*----------------------------------------------------------------------------*/


/************************************************************************/
/*      STATE TABLE                                                     */
/************************************************************************/


#define _start 0

method update_design_file ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	OM_S_OBJID		mod_id;
	GRspacenum		cur_os;
	IGRchar			file_name[DI_PATH_MAX],
				exp_name[DI_PATH_MAX],
				cur_dir[DI_PATH_MAX];
	struct GRid		tmp_obj;
	IGRlong			error = MSSUCC;
	struct	ret_struct	rst;
	IGRdouble		value;
	struct GRmd_env		md_env;
	IGRlong			msg, NumberOfBytes, BytesReceived;
	IGRchar			name[DI_PATH_MAX]; 
	IGRshort		rc;
 
  SetProc( VDrtupdcls.update_design_file ); Begin

  *sts = MSSUCC;

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

     /* tr 179601053: change NewVDroot to 1.
        in struct, it sets the NewVDroot = 0
     */
     value = 100.0;
     status =
     om$send(msg = message expression.NDgive_value( &value ),
                            senderid = NULL_OBJID,
                 	    targetid = tmp_obj.objid,
                            targetos = cur_os);
     
     if(!(status & 1))
         printf("Can't get expression value \n");
         __DBGpr_dbl( " value = ", value);
 
     if( fabs( value ) < 0.1 ) {	/* value = 0.0 */

    	__DBGpr_com( " change the old value of NewVDroot"); 

        NumberOfBytes = sizeof(md_env);
        gr$get_module_env( msg    = &msg,
                    sizbuf = &NumberOfBytes,
                    buffer = &md_env,
                    nret   = &BytesReceived);

        value = 1.0;
        strcpy( name, "");
        status =
        om$send(msg = message expression.NDset_value( 
                            "",  value, &md_env, &rc),
                            senderid = NULL_OBJID,
                 	    targetid = tmp_obj.objid,
                            targetos = cur_os);
        if(!(status & 1))
         printf("Can't set value NewVDroot\n");
     }
     else {
    	__DBGpr_com("File already update");
        goto wrapup;
     }
  }
  else{
    /* Create the expression of file already update */
    status =  exp$create(exp_name  = "NewVDroot",
			 osnum     = cur_os,
			 exp_value = 1.0,
			 p_exp_id  = &tmp_obj);
    if(!(status & 1))
       printf("Can't create expression NewVDroot\n");

    di$cd(dirname = cur_dir);
  }

  status = VD_CorrectDesignFiles();

wrapup:
  if ( !( status & 1 ) ){ 
	printf("Warning problem with updating of VDSroot class.\n");
	return OM_S_SUCCESS;
  }

  if( cur_dir[0] != '\0' ){
    di$cd(dirname = cur_dir);
  }

  UI_status(" Verified VDSroot class definition." );

  End
  goto quit;
quit:
  return OM_S_SUCCESS;
}

end implementation VDrtupdcls;
