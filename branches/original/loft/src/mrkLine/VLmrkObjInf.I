//
//	I/LOFT: return type name and information of this object.
//

class implementation VLmrkLine  ;

#include <stdio.h>
#include <string.h>
#include "exmacros.h"
#include "msmacros.h"
#include "vlmark.h"
#include "v_miscmacros.h"

/*********************************** DEBUG flags        ***********************

#define MARKERDEBUG     1
#define vsDEBUG         1
#define vserrDEBUG      1 

*********************************** end DEBUG flags    ***********************/

#include "vldbgmacros.h"

//----------------------------------------------------------------------------

method GRgetobjinfo(	long			*msg ;
			struct GRobj_info	*info ) {

	int		sts = OM_E_INVARG,
			status ;

        int             nchars = 0,             // Space to print type
			index  = 0,
			inAlen ;                // Length of "inA"
	char		inA[MS_MAX_MSG_LENGTH]; // In-macro message buf.
	struct	ret_struct RetStr ;		// return values for give struc
	struct  GRmd_env	MdEnv;		//current mod env

	SetProc( ObjInf ) ;	Begin

	if ( !msg || !info ) goto wrapup;

	inA[0] = 0 ;

	status = ex$get_cur_mod( osnum = &(MdEnv.md_id.osnum),
				    id = &(MdEnv.md_id.objid) );
	__CheckRC( status, 1 , "get cur mod", wrapup ) ;
	__DBGpr_obj( "module info", MdEnv.md_id ) ;

        RetStr.var.text_st.text_string[0] = 0 ;


		// get the name of the obj defining the mark
        status = om$send( msg = message NDmacro.ACgive_structure( &sts,
                                                                &index,
                                                        "contents:dataName",
                                                                &RetStr,
                                                                &MdEnv ),
                                targetid        = my_id ) ;
	CheckRC( status, sts ) ;

		// only get second name if first worked
	if ( RetStr.var.text_st.text_string[0] && (status&1) ) {

	   strcpy( inA, RetStr.var.text_st.text_string ) ;

	   strcat( inA, "/");

		// get the name of the obj being marked

	   RetStr.var.text_st.text_string[0] = 0 ;
	   status = om$send( msg = message NDmacro.ACgive_structure( &sts,
                                                                &index,
                                                        "contents:plate name",
                                                                &RetStr,
                                                                &MdEnv ),
                                targetid        = my_id ) ;
	   CheckRC( status, sts ) ;

	   if ( RetStr.var.text_st.text_string[0] && (status&1) )
                        	strcat( inA, RetStr.var.text_st.text_string );

	   __DBGpr_str( "inA", inA ) ;

	}	// if give foot works 


		// if in reference file
	if( OM_Gw_current_OS != MdEnv.md_id.osnum ) {
			inAlen = strlen( strcat( inA, " [R]" ) ) ;
	} else  inAlen = strlen( inA ) ;

		// standard name for marks
	nchars = strlen(  VLMarkName ) ;	// was + inAlen ;
	__DBGpr_int( "Nchars", nchars ) ;
	
        if( inAlen && (inAlen < MS_MAX_MSG_LENGTH) ) {
	   sprintf(info->type, "%.*s %.*s ", nchars,  VLMarkName, inAlen,inA ) ;
        } else {
		sprintf( info->type, "%.*s ", nchars,  VLMarkName ) ;
	}

	if ( (nchars+inAlen) < MS_MAX_MSG_LENGTH )
		info->type[nchars+inAlen+1]		= '\0';

	info->type[ MS_MAX_MSG_LENGTH - 1 ]	= '\0';  // safety valve


	__DBGpr_str( "Type", info->type ) ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

wrapup:
	End
	return sts;

} // end method GRgetobjinfo

//----------------------------------------------------------------------------

end implementation VLmrkLine  ;
