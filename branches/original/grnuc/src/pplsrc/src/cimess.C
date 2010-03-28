/*
 * cimess.C
 *
 * Etienne   BEEKER
 * Dominique GARDELLA
 * Alain     FALASSE
 * this file contains  the interface to send messages to the system
 * i.e the make_message construction and the sending
 *
 */


#include "ci.h"
#include <ctype.h>
#include "exmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include <limits.h>

extern struct instance_ci *ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;
extern struct GRvg_construct	Ci_cnst_list;
extern struct IGResintx		Ci_text_attr;

enum { SEND = 0, CLAS = 1, MESS = 2, ARGS = 3, SIZE = 4,
       TARG = 5, OBSP = 6, CNST = 7, MODE = 8, CHAN = 9,
       VERB =10, P_CHAN = 11
} ;

/*----------------------------------------------------------------------------*/
#argsused
int CIsend( instr, evdata, runenv, state )

struct ci_instruction	*instr	;
CIco_resp		*evdata	;
CIruntime		*runenv	;
short			*state	;
/*
 * Performs message sends. Note: AG's "place" messages are handled differently.
 */
{
	int stat ; long OMsts ;


	if( strcmp( cival(instr->paramlist[MESS]), "place" ) == 0 ) {
#if 1
	   OMsts = ciplace( cival( instr->paramlist[CLAS] ),	/* class */
			   cival( instr->paramlist[TARG] ),	/* target */
			   isstring( instr->paramlist[TARG] ),	/* flag */
			   cival( instr->paramlist[ARGS] ),	/* args. */
			   &Ci_cnst_list,
			   &Ci_text_attr ) ;
#else
		erreur("place: ci not attached with Associative Geometry");
		OMsts = OM_W_abort ;
#endif
	  stat = ISUCCESS ;
	} else {
		/* make_message performed */
		stat = cimkmess( instr, evdata, runenv, &OMsts ) ;
	}

	i_cival( instr->paramlist[SEND] ) = OMsts ;

	return stat ;
}
/*----------------------------------------------------------------------------*/
int cimkmess( mess, evdata, runenv, p_OMsts )

struct ci_instruction	*mess	;
CIco_resp		*evdata	;
CIruntime		*runenv	;
long			*p_OMsts;

/* -- Arg  1 : index of class name
      Arg  2 : index of message name
      Arg  3 : index of structure containing arguments
      Arg  4 : index size of above-mentioned structure
      Arg  5 : index of target id or target name
      Arg  6 : index of target object space ( -1 means take current )
      Arg  7 : index of construct flag
      Arg  8 : index of send mode
      Arg  9 : channel name
      Arg 10 : verbose flag
      Arg 11 : channel selector
      Arg 12 : line number in source file for this instruction
      AF modified for new structures and send mechanism. ( 11/23/87 )
      AF made to return correct OM error code. ( 10/12/88 )
   -- */

{ long		 		iobj		;
  struct GRid			target		;
  char				*Class	, *Msg	;
  OM_S_MESSAGE			OMmsg		;
  register short 		*args		;
  static enum OM_e_wrt_flag	mode[] = { OM_e_wrt_object	,
				  	   OM_e_wrt_message	,
				  	   OM_e_wrt_ancestor	,
				  	   OM_e_wrt_parent	} ;
  OM_S_CHANSELECT		chanselect 	;
  OM_p_CHANSELECT		p_chanselect 	;
  int				verbose		;

#define TELL( m )							\
	sprintf( errmess, "CIsend(%s) %s.%s error:", (m), Class, Msg ) ;\
	linerreur( errmess, args[mess->nbparam] ) ;			\
	return IFAILED ;

  args = mess->paramlist	;
  iobj = args[TARG]		;

  verbose = i_cival( args[VERB] );
#ifdef DEBUG
  printf( "cimkmess: verbose = %d\n", verbose ) ; fflush( stdout ) ;
#endif

/* Object space number */
  if( isintvalue( args[OBSP] ) ) {
	  int nos = ci_give_intvalue( args[OBSP] ) ;
	  if( nos == -1 )
		ex$get_cur_mod( osnum = &target.osnum ) ;
	  else
		target.osnum = nos ;
  } else {
	*p_OMsts = om$os_name_to_number( osname  = st_cival( args[OBSP] ),
				   	 p_osnum = &target.osnum 	 ) ;

	if( !( *p_OMsts & SUCC ) ) {
		if( verbose ) {
			CIomerr(	evdata			,
					runenv			,
					ci_data->ficcmd		,
					args[mess->nbparam]	,
					*p_OMsts		,
					NULL			,
					NULL			,
					INT_MAX			,
					NULL			,
					-1			,
					st_cival( args[OBSP] )	) ;
		}
		return ISUCCESS ;		
 	}
  }


/* Object id. */
  if( isGRobj( iobj ) )
	target.objid = o_cival( iobj )	;
  else if( isstring( iobj ) ) {  
	long DIstat ;

	DIstat = di$translate(	objname = st_cival( iobj ),
		     		p_objid = &target.objid  ) ;

	if( !( DIstat & SUCC ) ) {
		char tmp[200] ;
		sprintf( tmp, "CIsend: message %s.%s -> `%s'\n",
					cival( args[CLAS] )	,
					cival( args[MESS] )	,
					st_cival( iobj )	) ;
		di$report_error( sts = DIstat, comment = tmp ) ;
		*p_OMsts = OM_W_ABORT ;
		return ISUCCESS ;
	}
  }


/* -- class & message names are char arrays -- */
   Class	= cival( args[CLAS] ) ;
   Msg		= cival( args[MESS] ) ;


/* -- construct the message -- */
  *p_OMsts = om$make_message(	classname	= Class	,
				methodname	= Msg	,
				p_arglist	= cival( args[ARGS] ),
				size		= i_cival( args[SIZE] ),
				p_msg		= &OMmsg
		       	    ) ;

  if( !( *p_OMsts & SUCC ) ) {
  	if( verbose ) {
		CIomerr(	evdata			,
				runenv			,
				ci_data->ficcmd		,
				args[mess->nbparam]	,
				*p_OMsts		,
				Class			,
				Msg			,
				INT_MAX			,
				NULL			,
				-1			,
				NULL			) ;
	}
	return ISUCCESS ;
  }

/* send the message now if "channame" or "p_chanselect" specified */
  if( ( p_chanselect = (OM_p_CHANSELECT)p_cival( args[P_CHAN] ) ) == NULL ) {
    if( ispointer( args[CHAN] ) ) {
	if( ( chanselect.u_sel.name = p_cival( args[CHAN] ) ) == NULL )
	    goto CHANNAME_NOT_SPECIFIED ;
    } else
	chanselect.u_sel.name	= cival( args[CHAN] ) ;
	chanselect.type		= OM_e_name ;
	p_chanselect		= &chanselect ;
    }

    *p_OMsts = om$send(	msg	 	= &OMmsg,
   			mode	 	= mode[i_cival( args[MODE] )],
                	senderid 	= target.objid,
			targetos 	= target.osnum,
			p_chanselect 	= p_chanselect ) ;
    if( !( *p_OMsts & OM_S_SUCCESS ) ) {
	if( verbose ) {
	   	CIomerr( evdata			,
			 runenv			,
			 ci_data->ficcmd	,
   			 args[mess->nbparam]	,
   			 *p_OMsts		,
   			 Class			,
   		         Msg			,
   		         INT_MAX		,
   		         chanselect.u_sel.name	,
   		         target.osnum		,
   		         NULL 			) ;
   	}
   }
   return ISUCCESS ;

CHANNAME_NOT_SPECIFIED:

/* -- construct the object if need be -- */
  if(    IF_EQ_OBJID( target.objid, NULL_OBJID ) 
      || i_cival( args[CNST] ) ) {

	*p_OMsts = om$construct( osnum 		= target.osnum	,
				 classname 	= Class		,
				 p_objid 	= &target.objid	,
				 neighbor	= OM_GS_NULL_NEIGHBOR ) ;
	if( !( *p_OMsts & SUCC ) ) {
		if( verbose ) {
			CIomerr(	evdata			,
					runenv			,
					ci_data->ficcmd		,
   					args[mess->nbparam]	,
   					*p_OMsts		,
   					Class			,
   		        		NULL			,
   		        		INT_MAX			,
   		        		NULL			,
   		        		target.osnum		,
   		        		NULL 			) ;
   		}
   		return ISUCCESS ;
	}
    	o_cival( iobj ) = target.objid ;
  }

  *p_OMsts = om$send(	msg	 = &OMmsg			,
			mode	 = mode[i_cival( args[MODE] )]	,
                	senderid = evdata->ci_id		,
			targetid = target.objid			,
			targetos = target.osnum			) ;

  if( !( *p_OMsts & OM_S_SUCCESS ) ) {
  	if( verbose ) {
		CIomerr(	evdata			,
				runenv			,
				ci_data->ficcmd		,
   				args[mess->nbparam]	,
   				*p_OMsts		,
   				Class			,
   		        	Msg			,
   		        	target.objid		,
   		        	NULL			,
   		        	target.osnum		,
   		        	NULL 			) ;
	}
  }

  return ISUCCESS ;

} /* cimkmess */
/*----------------------------------------------------------------------------*/

