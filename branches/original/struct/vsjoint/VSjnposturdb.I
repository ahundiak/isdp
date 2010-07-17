/* $Id: VSjnposturdb.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjnposturdb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnposturdb.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/03/25  15:30:16  pinnacle
# TR179800839
#
# Revision 1.3  1998/01/09  11:22:42  pinnacle
# Replaced: vsjoint/VSjnposturdb.I for:  by svkadamb for struct
#
# Revision 1.1  1997/11/21  04:40:10  pinnacle
# Created: VSjnposturdb.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 *			suresh		calling routines which will get the
 *					parents catalog/partid/revision.
 *      03/25/98        suresh          Columns mismatch,  if any, 
 *                                      between database and current 
 *                                      design was tested. TR179800839
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include <stdio.h>
#include <string.h>
#include "DIprims.h"                    /* di$give_pathname */
#include "nddef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "PDUerror.h"		/* used for PDM_S_SUCCESS */ 
#include "VDScheckin.h"
#include "VDScheckdef.h"
#include "VDSris_def.h"
#include "vdsmacros.h"
#include "vdbmacros.h" // To fix TR# 179800839
#include "v_slc.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

#define VS_DYN_NUM     25

extern 	get_catalog_candidates() ,
	get_first_part_candidate() ;

from ACpretend	import ACfind_parent ;

/*----------------------------------------------------------------------------*/
method VDPostYourselfToDb(long	*msg ;
			  char	*key ;
			  int	to_sql ;
			  char	*catalog ;
			  char	*partid ;
			  char	*revision ;
			  char	*designRep ;
			  int	*delete )  {

	long		sts;		/* return code			*/
	int		ACrc,		/* ACgive_struct retun code	*/
			index = -1,
			j, 		/* attribute name count		*/
			i ;		/* loop index			*/
	char		*tablename,	/* table of joint		*/
			logfile[50] ;	/* infor mation to log file	*/
	FILE		*p_file ;	/* file pointer for log file	*/
	IGRint   	nbRoots = 0,	/* parent count of joints	*/
			jj ,
			ModCol_Type[VS_DYN_NUM];
	char 		*ModCol_Value[VS_DYN_NUM];
	struct GRmd_env myEnv ;
	struct GRid	*buffer = NULL,	/* Used for root objects	*/
			myGrid ;	/* current object		*/
	GRname		object_id, 	/* object id as string		*/
			memb_name, 	/* name of my object		*/
			firstParent,	/* first root's id as string	*/
			secondParent,	/* second root's id as string	*/
			attrDesc ;	/* description of joint attrib  */
	GRname		firstCatalog,
			firstPartid,
			firstRevision ;
	GRname		secondCatalog,
			secondPartid,
			secondRevision ;
	char		*attrName[12] ; /* attribute names of joint	*/
	struct table_attr pdc_attr; // To fix TR# 179800839
	struct ret_struct 
			rs ;		

	SetProc( VSjoint_VDPostYourselfToDb ); Begin 

	*msg = MSSUCC; 

	//Start : To fix TR# 179800839
	pdc_attr.type                 = 0;
	pdc_attr.feet_list            = NULL;
	pdc_attr.format_list          = NULL;
	pdc_attr.table_name[0]        = '\0';
	 // End: To fix TR# 179800839

	myGrid.objid = my_id ;
	myGrid.osnum = OM_Gw_current_OS ;
		
	//Start : To fix TR# 179800839
	for( jj = 0; jj < VS_DYN_NUM ; jj++ ) {
		ModCol_Value[jj] = NULL ;
	}
	//End : To fix TR# 179800839

	if( strcmp( key, REG_CHECKIN ) == 0 ) {
		strcpy( logfile, "VDSreg_chk.log" );
	} else if( strcmp(key, DWG_CHECKIN) == 0 ) {
		strcpy( logfile, "VDSdwg_chk.log" );
	} else {
		printf( "Unknown key : <%s> for VDS checkin\n", key );
		return MSFAIL;
	}

	VSgetVirtualInfo( msg, &myGrid, &myEnv, NULL ) ;
 
	/*
	 * Replace by routines as defined in VD_expObjDynTable in
	 *	$VDS/vdtbl/parser/VDexpObj.I
	 */
	tablename = VD_CKTB_JOINT ;
 
	__DBGpr_str( "Tablename of Posting ", tablename );

	/* 	
	 * Initialization 
	 */
	p_file = NULL;
 
#ifndef MY_DEBUG
	p_file = (FILE *)fopen( logfile, "w+" );
#endif
	if( p_file == NULL ) {
		p_file = (FILE *)stdout;
	}
	/*
	 * Get the number columns and make sure it has the same number of 
	 * columns as in the new dynamic table for joint
	 */

	//Start : To fix TR# 179800839

	 strcpy( pdc_attr.table_name, tablename );

	 vdb$RetrieveAttributes(	table_name= tablename, 
					p_num	  = &pdc_attr.nb_feet ,
					p_attr	  = &pdc_attr.feet_list, 
					p_type	  = &pdc_attr.format_list );

	if(  pdc_attr.nb_feet != VS_DYN_NUM ) {
		UI_status (" Mismatch in columns for Joint Table" ) ;
		VS_Wait_timer( 60 ) ;
		printf(" Joint Object [%d %d] not posted \n", myGrid.objid, 
								myGrid.osnum );
		/*
		 * Free all the column information obtained 
		 */
		if( pdc_attr.feet_list != NULL )
		{
			for( jj = 0; jj < pdc_attr.nb_feet; ++jj )
			{
				if( pdc_attr.feet_list[jj] != NULL )
					_FREE( pdc_attr.feet_list[jj] );
	 
				if( pdc_attr.format_list[jj] != NULL )
					_FREE( pdc_attr.format_list[jj] ) ;
			}
	 
			_FREE( pdc_attr.feet_list );
			_FREE( pdc_attr.format_list );
		}
		return OM_S_SUCCESS ;
	}
	//End : To fix TR# 179800839
	/*
	 * Initialise all the attribute names of the joint object
	 */
	attrName[0]  = VS_D_jnWldCodAttr;
	attrName[1]  = VS_D_jnWldPrcAttr;
	attrName[2]  = VS_K_jnWldSizAttr;
	attrName[3]  = VS_K_jnWldLenAttr;
	attrName[4]  = VS_D_jnWldSidAttr;
	attrName[5]  = VS_D_jnWldInfAttr;
	attrName[6]  = VS_D_jnIncrLnAttr;
	attrName[7]  = VS_D_jnGrvAngAttr;
	attrName[8]  = VS_K_jnPitchAttr;
	attrName[9]  = VS_K_jnWldPosAttr;
	attrName[10]  = VS_K_jnShrnkAttr;
	attrName[11] = VS_K_jnFieldWeld;
	
	/*
	 * set the attribute type as stored in the database table
	 */
	ModCol_Type[0] = INT ;
	ModCol_Type[1] = CHAR ;
	ModCol_Type[2] = CHAR ;
	ModCol_Type[3] = CHAR ;
	ModCol_Type[4] = CHAR ;
	ModCol_Type[5] = INT ;
	ModCol_Type[6] = INT ;
	ModCol_Type[7] = DOUBLE ;
	ModCol_Type[8] = DOUBLE ;
	ModCol_Type[9] = INT ;
	ModCol_Type[10] = INT ;
	ModCol_Type[11] = DOUBLE ;
	ModCol_Type[12] = DOUBLE ;
	ModCol_Type[13] = DOUBLE ;
	ModCol_Type[14] = INT ;
	ModCol_Type[15] = DOUBLE ;
	ModCol_Type[16] = INT ;
	ModCol_Type[17] = INT ;
	ModCol_Type[18] = CHAR ;
	ModCol_Type[19] = CHAR ;
	ModCol_Type[20] = CHAR ;
	ModCol_Type[21] = INT ;
	ModCol_Type[22] = CHAR ;
	ModCol_Type[23] = CHAR ;
	ModCol_Type[24] = CHAR ;
	
	sprintf( object_id, "%d", my_id );
	/*
	 * get the name of the joint object
	 */
	vd$get_name(	obj	= &myGrid ,
			name	= memb_name );

	ModCol_Value[0] = VSstrdup( object_id );
	ModCol_Value[1] = VSstrdup( catalog ) ;
	ModCol_Value[2] = VSstrdup( partid ) ;
	ModCol_Value[3] = VSstrdup( revision ) ;
	ModCol_Value[4] = VSstrdup( memb_name ) ;


	for( i = 5 , j = 0 ; i < 17 && j<12 ; i++ ) {

		attrDesc[0] = '\0' ;
		/*
		 * get the attribute value corresponding to the attribute name
		 */
		sts = om$send(  msg     = message ACcpx.ACgive_structure(
							&ACrc, 
							&index, 
							attrName[j], 
							&rs, 
							&myEnv ),
				targetid= my_id ) ;
		if( !(ACrc & sts & 1 ) )  goto wrapup ;
		sprintf(attrDesc, "%g", rs.var.root_pm_st.value ) ;

		ModCol_Value[i] = VSstrdup( attrDesc ) ;
		j++ ;
	}

	sts = om$send( msg	= message NDnode.NDget_objects(
							ND_ROOT | ND_IN_BUF ,
							NULL,
							0,
							&buffer,
							0,
							OM_K_MAXINT,
							&nbRoots ),	
			targetid = my_id );
	__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup );

	__DBGpr_obj(" First  Obj ", buffer[0] );
	__DBGpr_obj(" Second Obj ", buffer[1] );

	sts = om$send( msg = message ACpretend.ACfind_parent( &buffer[0],
								NULL, NULL ),
			targetid = buffer[0].objid ,
			targetos = buffer[0].osnum );
	__DBGpr_obj(" First  Obj ", buffer[0] );

	sts = om$send( msg = message ACpretend.ACfind_parent( &buffer[1],
								NULL, NULL ),
			targetid = buffer[1].objid ,
			targetos = buffer[1].osnum );

	sprintf( firstParent, "%d", buffer[0].objid ) ;
	sprintf( secondParent,"%d", buffer[1].objid ) ;
	
	if( buffer[0].osnum != OM_Gw_current_OS ) {
		int 			ncat=0;
		char 			**catalogs=NULL,
					*fileName = NULL ;
		GRname			path_name ;

		sts = di$give_pathname( osnum	= buffer[0].osnum,
					pathname= path_name );
		if( sts != DIR_S_SUCCESS ) {
			di$report_error( sts     = sts,
					comment = "Error in di$give_pathname" );
                }

		fileName = strrchr( path_name, ':') ;
		
		sts = get_catalog_candidates( fileName+1, &catalogs, &ncat );

		__DBGpr_int( "No. of Catalogs ", ncat );
		__DBGpr_str( " Catalog Name ", catalogs[0] );

		strcpy( firstCatalog, catalogs[0] );

		if( ncat > 0 ) {
			if( !get_first_part_candidate(	fileName+1, 
							catalogs[0], 
							firstPartid,
							firstRevision, 
							fileName+1 ) )
			{
				UI_status( "Failed to get part name and revision" );
				sts = OM_E_ABORT;
				return OM_S_SUCCESS;
			}
		}

		__DBGpr_com(" First Parent Info " );
		__DBGpr_str(" Catalog ", firstCatalog );
		__DBGpr_str(" Part ID ", firstPartid );
		__DBGpr_str(" Revision", firstRevision );
	} else {
		strcpy( firstCatalog,  catalog);
		strcpy( firstPartid , partid );
		strcpy( firstRevision,  revision );
	}

	if( buffer[1].osnum != OM_Gw_current_OS ) {
		int 			ncat = 0;
		char 			**catalogs =NULL,
					*fileName = NULL ;
		GRname			path_name ;

		sts = di$give_pathname( osnum	= buffer[1].osnum,
					pathname= path_name );
		if( sts != DIR_S_SUCCESS ) {
			di$report_error( sts     = sts,
					comment = "Error in di$give_pathname" );
                }

		fileName = strrchr( path_name, ':') ;
		
		sts = get_catalog_candidates( fileName+1, &catalogs, &ncat );

		__DBGpr_int( "No. of Catalogs ", ncat );
		__DBGpr_str( " Catalog Name ", catalogs[0] );

		strcpy( secondCatalog, catalogs[0] );

		if( ncat > 0 ) {
			if( !get_first_part_candidate(	fileName+1, 
							catalogs[0], 
							secondPartid,
							secondRevision, 
							fileName+1 ) )
			{
				UI_status( "Failed to get part name and revision" );
				sts = OM_E_ABORT;
				return OM_S_SUCCESS;
			}
		}

		__DBGpr_com(" Second Parent Info " );
		__DBGpr_str(" Catalog ", secondCatalog );
		__DBGpr_str(" Part ID ", secondPartid );
		__DBGpr_str(" Revision", secondRevision );
	} else {
		strcpy( secondCatalog,  catalog);
		strcpy( secondPartid , partid );
		strcpy( secondRevision,  revision );
	}

	ModCol_Value[17]= VSstrdup( firstParent) ;
	ModCol_Value[18]= VSstrdup( firstCatalog ) ;
	ModCol_Value[19]= VSstrdup( firstPartid  );
	ModCol_Value[20]= VSstrdup( firstRevision ) ;
	ModCol_Value[21]= VSstrdup( secondParent ) ;
	ModCol_Value[22]= VSstrdup( secondCatalog  );
	ModCol_Value[23]= VSstrdup( secondPartid  );
	ModCol_Value[24]= VSstrdup( secondRevision  );

	sts = VdsSqlInsert (tablename, VS_DYN_NUM, ModCol_Type, ModCol_Value);

wrapup :
	/*
	 * Free the modified column values
	 * VSstrdup assigns the memory
	 */
	VSfreeList( VS_DYN_NUM, ModCol_Value );

	if( p_file != (FILE *)stdout )
		fclose( p_file );

	End
	return sts ;

} /* method VDPostYourselfToDb */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
