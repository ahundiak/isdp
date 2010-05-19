/* $Id: VDrtupdcls.sl,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdconvert/cmd / VDrtupdcls.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrtupdcls.sl,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/03/24  15:48:32  pinnacle
# Replaced: vdconvert/cmd/VDrtupdcls.sl for:  by azuurhou for vds.240
#
# Revision 1.4  1996/03/23  23:19:50  pinnacle
# Replaced: vdconvert/cmd/VDrtupdcls.sl for:  by yzhu for vds.240
#
# Revision 1.3  1996/03/20  20:24:24  pinnacle
# Replaced: vdconvert/cmd/VDrtupdcls.sl for:  by yzhu for vds.240
#
# Revision 1.2  1995/07/29  15:59:38  pinnacle
# Replaced: vdconvert/cmd/VDrtupdcls.sl for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/24  16:44:06  pinnacle
# Created: vdconvert/cmd/VDrtupdcls.sl by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *       07/25/95         HV             Moved from vdroot
 *
 * -------------------------------------------------------------------*/

/****************************************************************************

        Filename:       VDrtupdcls.sl
        Author:         AD Zuurhout/Eric Faivre
        Type:           Slic File
        Process by:     $EXNUC/bin/slic VDrtupdcls.sl
        Output:         VDrtupdcls.S  and VDrtupdcls.I
        makemake file   VDSroot.m -> makefile -> ../lib/VDSroot.o

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



/****************************************************************************/
/*      CLASS SPECIFICATIONS                                            *****/
/****************************************************************************/

command_string       VDC_M_CvtRtCmp,0,VDChRtDsFs
class                VDrtupdcls
super_class          VDS_LOCATE
command_table        "vds.cmd"
product_name         "$VDS"

start_state          start

/****************************************************************************/
/*      SPECIFICATION AREA                                              *****/
/****************************************************************************/

specification

/****************************************************************************/
/*      IMPLEMENTATION AREA                                             *****/
/****************************************************************************/

implementation

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

state_table

state start

   on CMD_TYPE = 0 do update_design_file		state terminate

/************************************************************************/
/*      METHOD: update_text_leader                                      */
/************************************************************************/

action update_design_file
{
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
}  
