/* $Id: VSvalidate.I,v 1.3 2001/10/21 19:05:43 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsmisc/VSvalidate.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSvalidate.I,v $
 *	Revision 1.3  2001/10/21 19:05:43  ramarao
 *	Fixed a small bug while working on CR# 4081.
 *	
 *	Revision 1.2  2001/02/20 01:19:04  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1  2001/01/16 23:32:02  ramarao
 *	*** empty log message ***
 *	
# Revision 1.11  2000/08/25  15:39:32  pinnacle
# Replaced: struct/vsmisc/VSvalidate.I for:  by jvhanson for Service Pack
#
# Revision 1.10  2000/08/17  21:09:46  pinnacle
# Replaced: struct/vsmisc/VSvalidate.I for:  by jvhanson for Service Pack
#
# Revision 1.9  2000/06/19  20:16:32  pinnacle
# Replaced: struct/vsmisc/VSvalidate.I for:  by jvhanson for Service Pack
#
# Revision 1.8  2000/06/15  23:48:16  pinnacle
# Replaced: struct/vsmisc/VSvalidate.I for:  by jvhanson for Service Pack
#
# Revision 1.7  2000/06/15  16:50:20  pinnacle
# Replaced: struct/vsmisc/VSvalidate.I for:  by jvhanson for Service Pack
#
# Revision 1.5  2000/05/11  12:52:28  pinnacle
# Replaced: struct/vsmisc/VSvalidate.I for:  by jvhanson for Service Pack
#
# Revision 1.4  2000/05/05  18:49:08  pinnacle
# Replaced: struct/vsmisc/VSvalidate.I for:  by jvhanson for Service Pack
#
# Revision 1.3  2000/05/05  00:38:02  pinnacle
# Replaced: struct/vsmisc/VSvalidate.I for:  by jvhanson for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *	04/11/00	jvh		verify support routines
 *	06/15/00	jvh		added check for identical parents
 *      08/23/00        jvh             Added duplicate exceptions. 
 *					duplicate file name 'dup_except.lis' and can
 *					in local directory of any of the SP or product
 *					config directories.
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include 	<errno.h>
#include	<memory.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"OMparameters.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"exdef.h"
#include	"ex.h"
#include	"exmacros.h"
#include	"igrdp.h"
#include	"gr.h"
#include	"growner.h"
#include	"go.h"
#include	"griodef.h"
#include	"grio.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"msdef.h"
#include	"msmacros.h"
#include	"grmacros.h"
#include	"AS_status.h"
#include	"OMindex.h"
#include	"refdef.h"
#include	"ref.h"
#include	"madef.h"
#include	"msdef.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"
/*
#define	vdsDEBUG	1
#define vdserrDEBUG	1

#define DEBUG	1
*/



#include	"v_miscmacros.h"
#include	"vsdbgmacros.h"
#include	"VDmem.h"
#include	"vdparmacros.h" 
#include	"vd_ve.h"
#include	"v_edgedef.h"
#include	"v_edgemacros.h"



#define STVAL	-1.23456

#define	tol	.0001

extern	GRclassid	OPP_ACcpx_class_id ; /* $GRNUC/OMclassinit.c */
extern	GRclassid	OPP_VDSroot_class_id ;
extern	GRclassid	OPP_GRclhdr_class_id ;
extern	GRclassid	OPP_GRsmhdr_class_id ;
extern	GRclassid	OPP_EMSsubbs_class_id ;

from	GRgraphics	import	GRgetrang ;
from	GRgencs		import	GRgetmatrix ;
from	GRvg		import	GRgetname ;
from	expression	import	NDgive_value ;
from    ACcpx           import  find_macro ;
from	ACcpx_defn	import	ACgive_name ;
from	GRcurve		import	GRendpts ;
from	ASnode		import	ASreturn_go ;
extern int errno;
extern double sqrt() ;

#define	TRUE            1
#define	FALSE           !TRUE

static IGRdouble	*ranges ;
static IGRchar		*chkname[4000] ;

/************************************************************************
   this function take a set of macros and check to see if they are the
   same. It returns true if all goes well, and iocount is how many matches
   it found. inmatch is allocated by me and needs to be freed by you.
   inmatch is the return set of match pairs of macros if any.
   
   struct GRid *id , I set of macro ids to check 
   IGRint *iocount, 	, I/O number of macros and outputs num of matches 
   IGRint ** inmatch 	, O set of matches. num is list to num in list 
 ***********************************************************************/

IGRint VDcheckGroupOfMacros ( struct GRid * id , 
				struct GRmd_env mod_env ,
				IGRint *iocount , 
				IGRint ** inmatch ,
				IGRint	num_excepts ,
				IGRchar	**exceptions )	
{
IGRint		sts ;
IGRint		*mlist ;
IGRint		*match ;
IGRint		count ;
IGRint		maxmatch = 0 ;
IGRlong		i ;
IGRlong 	j ;
IGRlong 	k ;
IGRlong		msg ;
IGRlong		time_1 ;
IGRlong 	time_2 ;
IGRlong 	time_3 ;
IGRdouble	percent ;
IGRchar		msg_str[ 128] ;
struct GRid 	chk[2] ;

	#ifdef DEBUG
	printf("in VDcheckGroupOfMacros\n");
	#endif
	
	//printf(" VDcheckGroupOfMacros about to show the exception names number=%d\n", num_excepts );
	
	ranges = NULL;
	match = NULL;
	mlist = NULL;
	
  	time( &time_1 ) ;
  	time_3 = time_1;	

	k = 0;
	count = *iocount;
	
	/* set the output to 0 in case we fail allocating some memory */
	*iocount = 0;
	
	/* n factorial I think is too big */
	/* i = count * ((( count - 1 ) * 0.5) +1 ); */
	
	#ifdef DEBUG
	printf("number of input macros=%d, factorial allocated=%d\n", count , i);
	#endif
	
	//maxmatch = i * 2;
	maxmatch = count *2;
	if( maxmatch == 0 ){ maxmatch = 1; }

	match = _MALLOC ( maxmatch , IGRint );
	if( match == NULL ) {
		printf("could not allocate %d integers for match\n", i );
		msg =  FALSE;
		goto wrapup;
	}

	if( count < 1 ) { count = 1; }
	
	mlist = _MALLOC ( count , IGRint );
	if( mlist == NULL ) {
		printf("could not allocate %d integers for mlist\n", count );
		msg =  FALSE;
		goto wrapup;
	}
		
	ranges = _MALLOC ( count * 6 , IGRdouble );
	if( ranges == NULL ) {
		printf("could not allocate %d integers for ranges\n", count * 6 );
		msg =  FALSE;
		goto wrapup;
	}
	
	
	for( i=0;i<count;i++){
		ranges[(i*6)+0] = STVAL;
		ranges[(i*6)+1] = STVAL;
		ranges[(i*6)+2] = STVAL;
		mlist[i] = FALSE;
	}
	
		
	#ifdef DEBUG
	printf("got past the mallocs\n");
	#endif
	
	for( i=0;i<count-1;i++){

   		/*set up some process display */
  		time( &time_2); 
  		percent = (double)(time_2-time_3)/60.0;	
  		if( percent > 0.05 ){
 			time_3 = time_2;
  			percent = 100.0 * ( (IGRdouble) i / (IGRdouble) count );
  			sprintf( msg_str , "Checking for duplicate macros, %.1f %s [%d of %d]" , 
  					 percent, "%" , i+1 , count );
  			UI_status( msg_str );
  		} 
 		
		#ifdef DEBUG
		printf("in iloop i=%d\n", i );
		#endif
		
		if( i > 0 ){
			if( mlist[i-1] == TRUE ){
				#ifdef DEBUG
				printf("skipping i loop mlist[%d] = TRUE\n", i);	
				#endif
				continue;
			}
		}

		for( j=i+1; j<count;j++){
		
			#ifdef DEBUG
			printf("\tin jloop j=%d\n", j );
			#endif
			
			if( mlist[j-1] == TRUE) {
				#ifdef DEBUG
				printf("\tskipping j loop mlist[%d] = TRUE\n", j-1 );	
				#endif
				
				continue;
			}
			
			chk[0] = id[i];
			chk[1] = id[j];	
			
			if( chk[0].objid == chk[1].objid ){
				mlist[j-1] = FALSE;
				continue;
			}

			if( VDcheck2Macros ( chk , mod_env , exceptions , num_excepts ) == TRUE ){
			
				msg = VDcheckTwoRanges ( chk , mod_env , i , j );
			
				if( msg == TRUE){
					msg = VDcheckParents ( chk , mod_env );
					
					#ifdef DEBUG
					printf("check parents msg=%d\n", msg );
					#endif
					
					if( msg == TRUE){
						match[k] = i;
						match[k+1] = j;
						k=k+2;
						mlist[j-1] = TRUE;
					} else {
						mlist[j-1] = FALSE;
					}
					
				} else if( msg == -1){
				
					if( VDcheckGeom ( chk , mod_env ) == TRUE){
					
						match[k] = i;
						match[k+1] = j;
						k=k+2;
						mlist[j-1] = TRUE;
						
					} else {
					
						mlist[j-1] = FALSE;
						
					}
					
				} else {
				
					mlist[j-1] = FALSE;
					
				}
			}
		}
	}
	match[k] = -1;
	match[k+1] = -1;
	*iocount = k/2;
	
	#ifdef DEBUG
	printf("got past the sorting\n");
	for(i=0;i<count-1; i++){
		printf("mlist[%d]=%d\n", i , mlist[i] );
	}
	
	for(i=0;i<k; i=i+2){
		printf("match[%d]=%d, %d\n", i , match[i], match[i+1] );
	}
	#endif
	
	msg = TRUE;
	
wrapup:
	* inmatch = match;
	_FREE( mlist );
	_FREE( ranges );
	return msg;
	
}



/************************************************************************
   this function will check if the name is in the ignore list, if 
   it is in the list we return TRUE to signify don't process this macro 
   return TRUE else FALSE.
 ***********************************************************************/
IGRint checkIgnoreNames ( IGRchar *macname , IGRchar **exceptnames , IGRint numexcepts ){
IGRint	i, j, k, found, iswild, junk;
IGRchar	tmpStr[60];

	//printf("in checkIgnoreNames numexceptions count=%d\n", numexcepts );
	
	for( i=0;i<numexcepts; i=i+1){
		strcpy( tmpStr, exceptnames[i]);
		found = TRUE;	
		k=0;
		#ifdef DEBUG
		printf( "macname[%s], exception[%d]=%s\n", macname, i , tmpStr);
		#endif
		
		iswild = FALSE;
		for(j=0;j<strlen(macname);j=j+1){
			if( (macname[j] != tmpStr[k] && iswild == FALSE) || tmpStr[k] == '*'  ){
			
				found = FALSE;
				/* the characters don't match check if except[k]='*' */
				if( tmpStr[k] == '*' ){
					#ifdef DEBUG
					printf("found a wildcard at %d ", k );
					printf("next dec[%d] chr[%c]\n", tmpStr[k+1], tmpStr[k+1] );
					#endif
					
					iswild = TRUE;
					
					if( tmpStr[k+1] == 0 || tmpStr[k+1] == 10){
						#ifdef DEBUG
						printf("FOUND a MATCH[%s][%s]\n", macname, tmpStr );
						#endif
						
						found = TRUE;
						break;
					}else{
						j=j-1;
						k=k+1;
					}
				}else{
					#ifdef DEBUG
					printf("names don't match\n");
					#endif
					
					found = FALSE;
					break;
				}
				
			} else if( macname[j] != tmpStr[k] && iswild == TRUE ){ 
				#ifdef DEBUG
				printf("ne iswild is true char[%c] j[%d] and char[%c] k[%d]\n", 
					macname[j],  j , tmpStr[k],  k );
				#endif
				junk = 1;
			} else { 
				#ifdef DEBUG
				printf("char[%c] j[%d] and k[%d]\n", macname[j],  j , k );
				#endif
				
				found = TRUE;
				iswild = FALSE;
				k=k+1; 
			}
		}
		if( found == TRUE ){
			#ifdef DEBUG
			printf("FOUND a MATCH[%s][%s]\n", macname, tmpStr );
			#endif
			
			break;
		}
	}
	return found;
}



/************************************************************************
   this function will check if the macro names are the same and 
   return TRUE else FALSE.
 ***********************************************************************/
IGRint VDcheck2Macros ( struct GRid id[2], struct GRmd_env MOD_ENV, 
			IGRchar **exceptnames, IGRint numexcepts )
{
IGRint		sts ;
IGRint		i ;
IGRlong		msg ;
struct GRid	MACRO_ID ;
struct GRid	TGRID ;
IGRchar		* pname ;
IGRchar		macro_name[256] ;

	pname = NULL;
	
	#ifdef DEBUG
	printf("about to show the exception names number=%d\n", numexcepts );
	
	for( i=0;i<numexcepts; i=i+1){
		printf( "exception[%d]=%s\n", i , exceptnames[i]);
	}
	#endif
	
	
	for( i=0;i<2;i++){
		
		TGRID = id[i];
		
		#ifdef DEBUG
		printf("ACcpx.find_macro[%d, %d]\n", TGRID.objid, TGRID.osnum );
		#endif
		
		MACRO_ID.objid = NULL_OBJID;
        	sts = om$send ( msg = message ACcpx.find_macro( &MACRO_ID ),
                        senderid = NULL_OBJID,
                        targetid = TGRID.objid,
                        targetos = TGRID.osnum);
                        	        
		if ( !(sts & 1) ){ 
			#ifdef DEBUG
			printf("ACcpx.find_macro failed [%d, %d]\n", TGRID.objid, TGRID.osnum);
			#endif
			msg = FALSE; 
			goto wrapup; 
		}
		
		#ifdef DEBUG
		printf("ACcpx_defn.ACgive_name[%d, %d]\n", MACRO_ID.objid, MACRO_ID.osnum );
        	#endif
        	
        	sts = om$send ( msg = message ACcpx_defn.ACgive_name( & pname ),
                        senderid = NULL_OBJID,
                        targetid = MACRO_ID.objid,
                        targetos = MACRO_ID.osnum);

		if ( !(sts & 1) ){ 
			msg = FALSE; 
			#ifdef DEBUG
			printf("ACcpx_defn.ACgive_name failed\n");
			#endif
			goto wrapup; 
		}
		
		#printf("in VDcheck2Macros numexceptions count=%d\n", numexcepts );
		if( checkIgnoreNames ( pname , exceptnames, numexcepts ) == TRUE ) { msg = FALSE; goto wrapup; }

				
		if( i == 0 ){
			#ifdef DEBUG
			printf("i=0 sprintf pname\n");
			#endif
			
			sprintf( macro_name , "%s" , pname );
			
			#ifdef DEBUG
			printf("PAST sprintf pname\n");
			#endif
		
		} else if( strcmp( macro_name, pname ) == 0 ){
			msg = TRUE;
			goto wrapup; 
			
		} else { 
			#ifdef DEBUG
			printf("macro names are different[%s][%s]\n", pname , macro_name );	
			#endif	
			msg = FALSE; 
			goto wrapup;
		}
	} 
	return FALSE;
wrapup:
	
	return msg;
}



/************************************************************************
   this function will check the classname of an object and 
   return TRUE if it is a subclass of the input SupClassName
 ***********************************************************************/
int VDcheckClassname ( struct GRid id, IGRchar *SupClassName )
{
int	sts ;
IGRchar	classname[256];
	

        sts = om$get_classname( 
        	osnum = id.osnum,
        	objid = id.objid,
        	classname = classname);

       	if( !om$is_ancestry_valid(
       		superclassname = SupClassName,
       		subclassname = classname) == 1 ) return FALSE;
       	else return TRUE;
}

/************************************************************************
   this function will take 2 GRids and compare the names and
   return true if they are the same and the name of the first
   regardless of the return code
************************************************************************/

IGRint	VDcheckNames( struct GRid grids[2], IGRchar *name )
{
IGRint	sts;
IGRchar	name1[128];
IGRchar	name2[128];

	/* get the name of the incoming object */
	sts = VDgetName( grids[0], name1 );
	sts = VDgetName( grids[1], name2 );
        
	strcpy(name,name1);
	
        if( strcmp( name2, name1 ) == 0 ){ 
        	return TRUE; 
        } else {
        	return FALSE;
        }
}

/************************************************************************
   this function will check the values of expressions systems and 
   return TRUE if the same name and value.
 ***********************************************************************/
IGRint VDcheckTwoExpressions ( struct GRid id[2] )
{
IGRint		sts ;
IGRint		i ;
IGRlong		msg ;
IGRchar		funame[256];
IGRchar		dirname[256];
IGRchar		bname1[128];
IGRchar		bname2[128];
IGRdouble	exp_vals[2];
	
	for( i=0;i<2;i++){
		
		if( VDcheckClassname ( id[i], "expression" ) == FALSE ) return FALSE;
		
        	sts = om$send(msg = message GRvg.GRgetname(
                	&msg,
                	funame),
			senderid = NULL_OBJID,
			targetid = id[i].objid,
			targetos = id[i].osnum );
       		
                sts = om$send( msg = message expression.NDgive_value(
			&exp_vals[i]),
			senderid = NULL_OBJID,
			targetid = id[i].objid,
			targetos = id[i].osnum );
                                
		if ( !(sts & msg & 1) ) return FALSE;	
		if( i == 0 ){
       			di$split (pathname = funame, dirname = dirname, name = bname1);
       			#ifdef DEBUG
        		printf("Selected object name is %s, [%s]\n" , bname1 , funame );
        		#endif
        	} else {
       			di$split (pathname = funame, dirname = dirname, name = bname2);
        		#ifdef DEBUG
        		printf("Selected object name is %s, [%s]\n" , bname2 , funame );
        		#endif
        	}
        }
					
	if ( (sts & msg & 1) ){	
		if( strcmp( bname1, bname2 ) == 0 ) return TRUE;
	} else return FALSE;
	return TRUE;

}


/************************************************************************
   this function will check the values of 2 Coordinate systems and 
   return TRUE if within the tolerance value.
 ***********************************************************************/
IGRint VDcheckTwoCoordSys ( struct GRid id[2] )
{
IGRint		sts ;
IGRint		i ;
IGRlong		msg ;
IGRdouble	cs [32] ;

	for( i=0;i<2;i++){
		
		if( VDcheckClassname ( id[i], "GRgencs" ) == FALSE ) return FALSE;
		
  		sts = om$send( msg = message GRgencs.GRgetmatrix(&msg,&cs[i*16]),
			senderid = NULL_OBJID,
			targetid = id[i].objid,
			targetos = id[i].osnum );
			
		if ( !(sts & msg & 1) ) return FALSE;	
        }
					
	if ( (sts & msg & 1) ){	
		for( i=0;i<16;i=i+1 ){
			if( cs[i] < cs[i+16] - tol ||
		    	    cs[i] > cs[i+16] + tol )
		    	    return FALSE;
		}
	} else return FALSE;
	return TRUE;

}

/************************************************************************
   this function will check the ranges of 2 objects and return TRUE if 
   within the tolerance value.
 ***********************************************************************/
IGRint VDcheckTwoRanges ( struct GRid id[2], struct GRmd_env env, IGRlong st, IGRlong en )
{
IGRint		sts ;
IGRint		i ;
IGRlong		msg ;
IGRdouble	Range1 [6] ;
IGRdouble	Range2 [6] ;
IGRboolean	World = 0 ;

   if( 	(ranges[(st*6)+0] == STVAL) &&
  	(ranges[(st*6)+1] == STVAL) &&
  	(ranges[(st*6)+2] == STVAL) ){

	sts = om$send( msg=message GRgraphics.GRgetrang(
		&msg ,
		&env.md_env.matrix_type ,
		env.md_env.matrix ,
		&World ,
		Range1 ),
		senderid = NULL_OBJID,
		targetid=id[0].objid,
		targetos=id[0].osnum );
		
	if ( !(sts & msg & 1) ) return FALSE;	
   	for ( i=0; i< 6; i++ ) ranges[(st*6)+i] = Range1[i];
	
   } else {
   	for ( i=0; i< 6; i++ ) Range1[i] = ranges[(st*6)+i];
   }
		
		
   if(  (ranges[(en*6)+0] == STVAL) &&
  	(ranges[(en*6)+1] == STVAL) &&
  	(ranges[(en*6)+2] == STVAL) ){

	sts = om$send( msg=message GRgraphics.GRgetrang(
		&msg ,
		&env.md_env.matrix_type ,
		env.md_env.matrix ,
		&World ,
		Range2 ),
		senderid = NULL_OBJID,
		targetid=id[1].objid,
		targetos=id[1].osnum );
		
	if ( !(sts & msg & 1) ) return FALSE;	
   	for ( i=0; i< 6; i++ ) ranges[(en*6)+i] = Range2[i];
	
   } else {
   	for ( i=0; i< 6; i++ ) Range2[i] = ranges[(en*6)+i];
   }
   
   #ifdef DEBUG
   printf("checking the range now\n");
   #endif
		
   for( i=0;i<6;i=i+1){
	if( Range1[i] < Range2[i] - tol ||
	    Range1[i] > Range2[i] + tol ){
	    #ifdef DEBUG
	    printf("!!!!!!!!!!!!!range not the same\n");
	    #endif
	    return FALSE;
	}
   }
   
   if(  Range1[0] == Range1[1] &&
	Range1[0] == Range1[2] &&
  	Range1[3] == Range1[4] &&
	Range1[3] == Range1[5] ){ 
	#ifdef DEBUG
   	printf("Bad range [%.3f, %.3f, %.3f], [%.3f, %.3f, %.3f], len[%.3f]\n",
   		Range1[0], Range1[1] , Range1[2],
   		Range1[3], Range1[4] , Range1[5],
   		sqrt( ((Range1[3]-Range1[0])*(Range1[3]-Range1[0]))+ 
   		      ((Range1[4]-Range1[1])*(Range1[4]-Range1[1]))+ 
   		      ((Range1[5]-Range1[2])*(Range1[5]-Range1[2])) ) );
   	#endif
   	return -1;
   }
   return TRUE;
}


/************************************************************************
   this function will get the curve geometry of the macros and check them
   
************************************************************************/
IGRint VDcheckGeom ( struct GRid grid[2], struct GRmd_env MOD_ENV )
{
IGRint			sts = 0;
IGRint			i = 0;
IGRint			checkedGeom = 0;
IGRlong 		msg = 0;
struct VDve_elem_buf    buf1;
struct VDve_elem_buf    buf2;
struct GRid		TMPGRIDS[2] ;
IGRchar			classname[128] ;
IGRchar			name[128] ;


	if( grid[0].objid == grid[1].objid ){
		msg = TRUE;
		goto wrapup;
	}

        buf1.count       = 0 ;
        buf1.buf_siz     = 0 ;
        buf1.obj_info_p  = NULL ;

        sts = vd_$select_obj_comps(   	msg     = &msg,
                                        option  = VD_K_gm_WIREFRAME,
                                        grIds   = &grid[0],
                                        theEnv  = &MOD_ENV,
                                        elmList = &buf1 );

        __CheckRC( sts, msg, "vd_$select_obj_comps", wrapup );


        #ifdef  DEBUG
        __DBGpr_com(" Component List : ");
        for( i=0; i<buf1.count; i=i+1 ) VD_ShowObj( & buf1.obj_info_p[i].obj_id );
        #endif
        
        buf2.count       = 0 ;
        buf2.buf_siz     = 0 ;
        buf2.obj_info_p  = NULL ;

        sts = vd_$select_obj_comps  (   msg     = &msg,
                                        option  = VD_K_gm_WIREFRAME,
                                        grIds   = &grid[1],
                                        theEnv  = &MOD_ENV,
                                        elmList = &buf2 );

        __CheckRC( sts, msg, "vd_$select_obj_comps", wrapup );


        #ifdef  DEBUG
        __DBGpr_com(" Component List : ");
        for( i=0; i<buf1.count; i=i+1 ) VD_ShowObj( & buf2.obj_info_p[i].obj_id );
        #endif

	if( buf2.count != buf1.count ){ 
		msg = FALSE;
		goto wrapup;
	}
        
        for( i=0;i<buf1.count;i=i+1){
        
        	TMPGRIDS[0] = buf1.obj_info_p[i].obj_id;
        	TMPGRIDS[1] = buf2.obj_info_p[i].obj_id;
        	
		if( VDcheckClassnames ( TMPGRIDS, classname ) == TRUE ){
		
			#ifdef DEBUG
			printf("classname=%s, ", classname );
			#endif
			msg = TRUE;
			
			if( om$is_ancestry_valid(
       				superclassname = "GRgencs",
       				subclassname = classname)  == OM_S_SUCCESS ){
       				
				#ifdef DEBUG
				printf("VDcheckGeom Gencs classname=%s\n", classname );
				#endif
				checkedGeom = checkedGeom + 1;
       				msg = VDcheckGencs ( TMPGRIDS );
       				if( msg == FALSE ){ 
       					
       					#ifdef DEBUG
       					printf("coord sys do not match[%d][%d]\n",
       						TMPGRIDS[0].objid, TMPGRIDS[1].objid);
       					#endif
       					
       					goto wrapup; 
       				}
       			} 
			
			
			if( om$is_ancestry_valid(
       				superclassname = "GRcurve",
       				subclassname = classname)  == OM_S_SUCCESS ){
       				
       				#ifdef DEBUG
				printf("VDcheckGeom Curve classname=%s id[%d, %d]\n", classname, 
					TMPGRIDS[0].objid,
					TMPGRIDS[1].objid );
				#endif
				
				checkedGeom = checkedGeom + 1;
       				msg = VDcheckCurves ( TMPGRIDS, MOD_ENV );
       				if( msg == FALSE ){ 
       					#ifdef DEBUG
       					printf("curves do not match[%d][%d]\n",
       						TMPGRIDS[0].objid, TMPGRIDS[1].objid);
       					#endif
       					
       					goto wrapup; 
       				}
       			} 
			
			if( VDcheckNames ( TMPGRIDS, name ) == TRUE ){
				#ifdef DEBUG
				printf("name=%s, should check that this is the same value\n", name );
				#endif
			} else { 
				msg = FALSE; 
				goto wrapup; 
			}
			
		}         
        }

wrapup:
        _FREE( buf1.obj_info_p );
        _FREE( buf2.obj_info_p );
	return msg;
}



/************************************************************************
   this function will get the name of the input GRid and return it in 
   name.
************************************************************************/
IGRint VDgetName ( struct GRid grid, IGRchar *name )
{
IGRint	sts;
IGRlong msg;
IGRchar funame[128];
IGRchar dirname[128];

        sts = om$send(msg = message GRvg.GRgetname(
                &msg,
                funame),
		senderid = NULL_OBJID,
		targetid = grid.objid,
		targetos = grid.osnum );
		
	if ( !(msg & sts & 1) ){
		#ifdef DEBUG
		printf("in VDgetName msg=%d, sts=%d\n",msg,sts );
		#endif
		strcpy( name, "");
		return FALSE;	
	}
	di$split (pathname = funame, dirname = dirname, name = name );
	#ifdef DEBUG
	printf("Selected object name is %s, [%s]\n" , name , funame );
	#endif
	return TRUE;
}

/************************************************************************
   this function will check the two coords and return TRUE if the same
   else FALSE
************************************************************************/
IGRint VDcheckGencs ( struct GRid grid[2] )
{
IGRint		sts;
IGRint		i;
IGRlong 	msg;
IGRdouble	cm[32];


	for( i=0;i<2;i++){
        	sts = om$send(msg = message GRgencs.GRgetmatrix(
			&msg,
			&cm[i*16] ),
			senderid = NULL_OBJID,
			targetid = grid[i].objid,
			targetos = grid[i].osnum );
			
		if ( !(msg & sts & 1) ){
			#ifdef DEBUG
			printf("in VDcheckGencs msg=%d, sts=%d, id[%d,%d]\n",msg,sts,
				grid[i].objid, grid[i].osnum );
			#endif
			return FALSE;	
		}
	}		
		
	/* check the values of the coordinate systems */
	for( i=0;i<16;i++){
		if( cm[i] < cm[i+16] - tol ||
		    cm[i] > cm[i+16] + tol ){
		    	
		    	#ifdef DEBUG
		    	printf("coords systems are different\n");
		    	#endif
		    	
		    	return FALSE;
		}
	}

	return TRUE;
}

/************************************************************************
   this function will check the two liness and return TRUE if the same
   else FALSE
************************************************************************/
IGRint VDcheckCurves ( struct GRid grid[2], struct GRmd_env MOD_ENV )
{
IGRint		sts;
IGRint		i;
IGRlong 	msg;
IGRdouble	ep[6];


	for( i=0;i<2;i++){
        	sts = om$send(msg = message GRcurve.GRendpts(
                        &msg,
                        &MOD_ENV.md_env.matrix_type,
                        MOD_ENV.md_env.matrix,
                        &ep[0],
                        &ep[3]),
			senderid = NULL_OBJID,
			targetid = grid[i].objid,
			targetos = grid[i].osnum );
			
		if ( !(msg & sts & 1) ){
			#ifdef DEBUG
			printf("in VDcheckCurves msg=%d, sts=%d\n", 
					msg , sts , grid[i].objid, grid[i].osnum);
			#endif
			return FALSE;	
		}
	}		
		
	/* check the values of the coordinate systems */
	for( i=0;i<3;i++){
		
		#ifdef DEBUG
		printf("[%.3f, %.3f]\n", ep[i] , ep[i+3] );
		#endif
		
		if( ep[i] < ep[i+3] - tol ||
		    ep[i] > ep[i+3] + tol ){
		    	#ifdef DEBUG
		    	printf("Curves are different\n");
		    	#endif
		    	return FALSE;
		}
	}

	return TRUE;
}

/************************************************************************
   this function will check the components of 2 objects and return TRUE if 
   the components are the same in value. this function assumes that the 
   2 macros are the same kind. we are now checking the internals.
 ***********************************************************************/
IGRint VDcheckTwoComponents ( struct GRid id[2], struct GRmd_env MOD_ENV )
{
IGRint			sts ;
IGRint			i ;
IGRint			checkedGeom ;
IGRlong			msg ;
IGRuint			count1 ;
IGRuint			count2 ;
IGRuint			count3 ;
IGRuint			count4 ;
IGRchar			classname[128] ;
IGRchar			name[128] ;
struct GRid		TMPGRIDS[2] ;
OM_S_CHANSELECT         to_components ;
OM_S_OBJECT_LINKAGE     *objectlist1 ;
OM_S_OBJECT_LINKAGE     *objectlist2 ;
	
	objectlist1 = NULL;
	objectlist2 = NULL;

	/* check to see if there is a coord system to check its values  */
		
        sts = om$make_chanselect( channame = "GRcmpowner.to_components",
                                p_chanselect = &to_components );

	if ( !(sts & 1) ){
		#ifdef DEBUG
		printf("returning False from make_chanselect\n");
		#endif
		return FALSE;	
	}
	
	#ifdef DEBUG
	printf("going into om$get_channel_count\n");
	#endif
	
	sts = om$get_channel_count( objid = id[0].objid,
                                    osnum = id[0].osnum,
                                    p_chanselect = &to_components,
                                    count = &count1 );
	if ( !(sts & 1) ){
		msg = FALSE;	
		goto wrapup;
	}
	
	/* get the same data from the second macro */
	sts = om$get_channel_count( objid = id[1].objid,
                                    osnum = id[1].osnum,
                                    p_chanselect = &to_components,
                                    count = &count2 );
                                      	
	if ( !(sts & 1) ){
		msg = FALSE;	
		goto wrapup;
	}
	
	/* check the channel count of both macros first */
	if( count2 != count1){
		msg = FALSE;	
		goto wrapup;
	}
	
	/* allocate the memory for the list */
	objectlist1 = _MALLOC ( count1 , OM_S_OBJECT_LINKAGE );

	if( objectlist1 == NULL ) {
		printf("could not allocate %d integers for objectlist1 \n", count1 );
		msg = FALSE;
		goto wrapup;
	}
	
	/* allocate the memory for the list */
	objectlist2 = _MALLOC ( count1 , OM_S_OBJECT_LINKAGE );
	if( objectlist2 == NULL ) {		
		printf("could not allocate %d integers for objectlist2 \n", count1 );
		msg = FALSE;
		goto wrapup;
	}
	
	sts = om$get_channel_objects( objid = id[0].objid,
                                      osnum = id[0].osnum,
                                      p_chanselect = &to_components,
                                      list = objectlist1,
                                      size = count1,
                                      count=&count3 );
	if ( !(sts & 1) ){
		msg = FALSE;	
		goto wrapup;
	}
	
	sts = om$get_channel_objects( objid = id[1].objid,
                                      osnum = id[1].osnum,
                                      p_chanselect = &to_components,
                                      list = objectlist2,
                                      size = count1,
                                      count = &count4 );
	if ( !(sts & 1) ) { 
		msg = FALSE; 
		goto wrapup; 
	}


	/* check the channel count of both macros first */
	if( count3 != count4){
		msg = FALSE;	
		goto wrapup;
	}

	checkedGeom = 0;
	
	for( i=0;i<count3;i++){
	
		#ifdef DEBUG
		printf("i=[%d] of [%d]\n", i, count3 );
		#endif
	
		TMPGRIDS[0].objid = objectlist1[i].S_objid;
		TMPGRIDS[0].osnum = objectlist1[i].osnum;
		TMPGRIDS[1].objid = objectlist2[i].S_objid;
		TMPGRIDS[1].osnum = objectlist2[i].osnum;
		
		
		if( VDcheckClassnames ( TMPGRIDS, classname ) == TRUE ){
			#ifdef DEBUG
			printf("classname=%s, ", classname );
			#endif
			msg = TRUE;
			
			if( om$is_ancestry_valid(
       				superclassname = "GRgencs",
       				subclassname = classname)  == OM_S_SUCCESS ){
       				
				#ifdef DEBUG
				printf("Gencs classname=%s\n", classname );
				#endif
				checkedGeom = checkedGeom + 1;
       				msg = VDcheckGencs ( TMPGRIDS );
       				if( msg == FALSE ){ 
       					
       					#ifdef DEBUG
       					printf("coord sys do not match[%d][%d]\n",
       						TMPGRIDS[0].objid, TMPGRIDS[1].objid);
       					#endif
       					
       					goto wrapup; 
       				}
       			} 
			
			
			if( om$is_ancestry_valid(
       				superclassname = "GRcurve",
       				subclassname = classname)  == OM_S_SUCCESS ){
       				
       				#ifdef DEBUG
				printf("Curve classname=%s id[%d, %d]\n", classname, 
					TMPGRIDS[0].objid,
					TMPGRIDS[1].objid );
				#endif
				
				checkedGeom = checkedGeom + 1;
       				msg = VDcheckCurves ( TMPGRIDS, MOD_ENV );
       				if( msg == FALSE ){ 
       					#ifdef DEBUG
       					printf("curves do not match[%d][%d]\n",
       						TMPGRIDS[0].objid, TMPGRIDS[1].objid);
       					#endif
       					
       					goto wrapup; 
       				}
       			} 
			
			if( VDcheckNames ( TMPGRIDS, name ) == TRUE ){
				#ifdef DEBUG
				printf("name=%s, should check that this is the same value\n", name );
				#endif
			} else { 
				msg = FALSE; 
				goto wrapup; 
			}
			
		} else { 
			msg = FALSE; 
			goto wrapup; 
		}
	}
	if( checkedGeom == 0 ){ 
		printf("id[%d, %d] id[%d,%d] no curves or coords were checked, long process now\n",
			TMPGRIDS[0].objid, TMPGRIDS[0].osnum ,TMPGRIDS[1].objid, TMPGRIDS[1].osnum);
		msg = VDcheckGeom( TMPGRIDS, MOD_ENV );		
		goto wrapup;
	}

	msg = TRUE;
wrapup:
	_FREE( objectlist1 ); 
	_FREE( objectlist2 ); 
	return msg;
		
}

/************************************************************************
   this function will take 2 GRids and compare the classnames and
   return true if they are the same and the classname of the first
   regardless of the return code
************************************************************************/
IGRint	VDcheckClassnames( struct GRid	grids[2], IGRchar *classname )
{
IGRint	sts;
IGRchar	classname1[128];

	/* get the classname of the incoming object */
        sts = om$get_classname( 
        	osnum = grids[0].osnum,
        	objid = grids[0].objid,
        	classname = classname);

        if( !(sts & 1)){
        	printf("get_classname failed id[%d , %d]\n", 
        		grids[0].objid , grids[0].osnum );
        	return FALSE;
        }

        sts = om$get_classname( 
        	osnum = grids[1].osnum,
        	objid = grids[1].objid,
        	classname = classname1);
        	
        if( !(sts & 1)){
        	printf("get_classname failed id[%d , %d]\n", 
        		grids[1].objid , grids[1].osnum );
        	return FALSE;
        }
        	
        if( strcmp( classname, classname1 ) == 0 ){ 
        	return TRUE; 
        } else {
        	return FALSE;
        }
}



/************************************************************************
   this function will check the parents of 2 objects and return TRUE if 
   the parents are the same. this function assumes that the 
   2 macros are the same kind. we are now checking the internals.
 ***********************************************************************/
IGRint VDcheckParents ( struct GRid id[2], struct GRmd_env MOD_ENV )
{
IGRint			sts ;
IGRint			i ;
IGRint			checkedGeom ;
IGRlong			msg ;
IGRuint			count1 ;
IGRuint			count2 ;
IGRuint			count3 ;
IGRuint			count4 ;
IGRchar			classname[128] ;
IGRchar			name[128] ;
struct GRid		TMPGRIDS[2] ;
OM_S_CHANSELECT         father ;
OM_S_OBJECT_LINKAGE     *objectlist1 ;
OM_S_OBJECT_LINKAGE     *objectlist2 ;
	
	objectlist1 = NULL;
	objectlist2 = NULL;
	msg = FALSE;

	/* check to see if there is a coord system to check its values  */
		
        sts = om$make_chanselect( channame = "NDfather.father",
                                p_chanselect = &father );

	if ( !(sts & 1) ){
		#ifdef DEBUG
		printf("returning False from make_chanselect\n");
		#endif
		return FALSE;	
	}
	
	#ifdef DEBUG
	printf("going into om$get_channel_count\n");
	#endif
	
	sts = om$get_channel_count( objid = id[0].objid,
                                    osnum = id[0].osnum,
                                    p_chanselect = &father,
                                    count = &count1 );
	if ( !(sts & 1) ){
		#ifdef DEBUG
		printf("returning False from om$get_channel_count\n");
		#endif
		msg = FALSE;	
		goto wrapup;
	}
	
	/* get the same data from the second macro */
	sts = om$get_channel_count( objid = id[1].objid,
                                    osnum = id[1].osnum,
                                    p_chanselect = &father,
                                    count = &count2 );
                                      	
	if ( !(sts & 1) ){
		#ifdef DEBUG
		printf("returning False from om$get_channel_count\n");
		#endif
		msg = FALSE;	
		goto wrapup;
	}
	
	/* check the channel count of both macros first */
	if( count2 != count1){
		#ifdef DEBUG
		printf("returning False inconsistant parent count\n");
		#endif
		msg = FALSE;	
		goto wrapup;
	}
	
	/* if both macros have 0 for count return TRUE */
	if( count1 == count2 && count1 == 0 ){
		msg = TRUE;	
		goto wrapup;
	}
	
	/* allocate the memory for the list */
	objectlist1 = _MALLOC ( count1 , OM_S_OBJECT_LINKAGE );

	if( objectlist1 == NULL ) {
		#ifdef DEBUG
		printf("could not allocate %d integers for objectlist1 \n", count1 );
		#endif
		msg = FALSE;
		goto wrapup;
	}
	
	/* allocate the memory for the list */
	objectlist2 = _MALLOC ( count1 , OM_S_OBJECT_LINKAGE );
	if( objectlist2 == NULL ) {		
		#ifdef DEBUG
		printf("could not allocate %d integers for objectlist2 \n", count1 );
		#endif
		msg = FALSE;
		goto wrapup;
	}
	
	sts = om$get_channel_objects( objid = id[0].objid,
                                      osnum = id[0].osnum,
                                      p_chanselect = &father,
                                      list = objectlist1,
                                      size = count1,
                                      count=&count3 );
	if ( !(sts & 1) ){
		#ifdef DEBUG
		printf("returning False from om$get_channel_objects\n");
		#endif
		msg = FALSE;	
		goto wrapup;
	}
	
	sts = om$get_channel_objects( objid = id[1].objid,
                                      osnum = id[1].osnum,
                                      p_chanselect = &father,
                                      list = objectlist2,
                                      size = count1,
                                      count = &count4 );
	if ( !(sts & 1) ) { 
		#ifdef DEBUG
		printf("returning False from om$get_channel_objects\n");
		#endif
		msg = FALSE; 
		goto wrapup; 
	}


	/* check the channel count of both macros first */
	if( count3 != count4){
		#ifdef DEBUG
		printf("returning False inconsistant number of parents\n");
		#endif
		msg = FALSE;	
		goto wrapup;
	}

	checkedGeom = 0;
	
	for( i=0;i<count3;i++){
	
		#ifdef DEBUG
		printf("i=[%d] of [%d]\n", i, count3 );
		#endif
	
		TMPGRIDS[0].objid = objectlist1[i].S_objid;
		TMPGRIDS[0].osnum = objectlist1[i].osnum;
		TMPGRIDS[1].objid = objectlist2[i].S_objid;
		TMPGRIDS[1].osnum = objectlist2[i].osnum;
		
		if( (TMPGRIDS[0].objid == TMPGRIDS[1].objid ) &&
		    (TMPGRIDS[0].osnum == TMPGRIDS[1].osnum ) ){
		    #ifdef DEBUG
		    printf("parents are the same msg=true[ %d, %d]\n", 
		    		TMPGRIDS[0].objid,
		    		TMPGRIDS[0].osnum);
		    #endif
		    msg = TRUE;
		    
		}else if( VDcheckClassnames ( TMPGRIDS, classname ) == TRUE ){
			#ifdef DEBUG
			printf("classname=%s, ", classname );
			#endif
			msg = TRUE;
			
			if( om$is_ancestry_valid(
       				superclassname = "ACpretend",
       				subclassname = classname)  == OM_S_SUCCESS ){
       				
				#ifdef DEBUG
				printf("pretend classname=%s\n", classname );
				#endif
								
				/* do a return go to get the parents */
    				om$send( msg = message ASnode.ASreturn_go( 
    					&TMPGRIDS[0], 
                        		&MOD_ENV.md_env.matrix_type,
                        		MOD_ENV.md_env.matrix),
                        		senderid = NULL_OBJID,
              				targetid = TMPGRIDS[0].objid,
              				targetos = TMPGRIDS[0].osnum );
              				
    				om$send( msg = message ASnode.ASreturn_go( 
    					&TMPGRIDS[1], 
                        		&MOD_ENV.md_env.matrix_type,
                        		MOD_ENV.md_env.matrix),
                        		senderid = NULL_OBJID,
              				targetid = TMPGRIDS[1].objid,
              				targetos = TMPGRIDS[1].osnum );

				if( (TMPGRIDS[0].objid == TMPGRIDS[1].objid ) &&
		    		    (TMPGRIDS[0].osnum == TMPGRIDS[1].osnum ) ){
		    		    	#ifdef DEBUG
		    			printf("ACpretend parents are the same msg=true[ %d, %d]\n", 
		    				TMPGRIDS[0].objid,
		    				TMPGRIDS[0].osnum);
		  			#endif
		    		    
		    			msg = TRUE;
		    		} else { 
		    			#ifdef DEBUG
		    			printf("FALSE check of ACpretend GO's\n");
		    			#endif
		    			
					msg = FALSE; 
					goto wrapup; 
				}
			}else { 
		    		#ifdef DEBUG
		    		printf("FALSE check of parent GO's\n");
		    		#endif
		    			
				msg = FALSE; 
				goto wrapup; 
			}
		} else { 
			#ifdef DEBUG
		    	printf("FALSE check of classnames\n");
		    	#endif
		    	
			msg = FALSE; 
			goto wrapup; 
		}
	}
	msg = TRUE;
wrapup:
	_FREE( objectlist1 ); 
	_FREE( objectlist2 ); 
	return msg;
		
}


end implementation Root;
