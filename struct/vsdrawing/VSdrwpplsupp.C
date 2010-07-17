/* $Id: VSdrwpplsupp.C,v 1.1.1.1 2001/01/04 21:10:34 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vddraw/drw/VSdrwpplsupp.C
 *
 * Description: Implementation of 'exec-ppl-func' functionality.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdrwpplsupp.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:34  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/12/18  10:21:52  pinnacle
 * Replaced: vsdrawing/VSdrwpplsupp.C for:  by rchennup for struct
 *
 * Revision 1.1  1997/11/19  10:14:20  pinnacle
 * Created: vsdrawing/VSdrwpplsupp.C by rchennup for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/19/97	Rama Rao	File Creation
 *
 ***************************************************************************/

#include <string.h>
#include "vsdrwapi.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "v_slc.h"
#include "VDmem.h"
#include "vsdbgmacros.h"

extern VD_execRes  __INP_PPL, __OUT_PPL;

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, exec_ppl_func ) {
int			i;
long			msg=0;
VStktxt			file_name, func_name;
VSdrwArgLst		*p;
int			nb_args;
VD_execRes		*args_list=NULL;

	SetProc( VSdrwOUTPUTexec_ppl_func ); Begin

	VSdrwStrVal( &arglist->arg, file_name );

	p=arglist->next;

	VSdrwStrVal( &p->arg, func_name );
	if( func_name[0] == '\0'  ) strcpy( func_name, "main" );

	nb_args = argc-1;

	if( !(args_list = _MALLOC( nb_args, VD_execRes ) ) ) goto wrapup;

	args_list[0].type 	   = VD_object;
	args_list[0]._oval.obj_id  = *inp->elmId;
	args_list[0]._oval.mod_env = *inp->elmEnv;

	for( i=1, p=p->next; i<nb_args && p; i++, p=p->next ){

		switch( p->arg.type ){

		case VS_int :
			args_list[i].type = VD_int;
			args_list[i]._ival = VSdrwIntVal(&p->arg);
			break;

		case VS_double :
			args_list[i].type = VD_double;
			args_list[i]._dval = VSdrwDblVal(&p->arg);
			break;

		case VS_string :
			args_list[i].type = VD_string;
			VSdrwStrVal(&p->arg, args_list[i]._sval);
			break;

		case VS_object :
			args_list[i].type  = VD_object;
			args_list[i]._oval =  p->arg.v.oval;
			break;

		default :	printf(" unknown case \n");
				return	xfFAILURE;
		}
	}

	__INP_PPL.type 		 = VD_array;
	__INP_PPL.v.aval.size    = nb_args;
	__INP_PPL.v.aval.element = args_list;

	__OUT_PPL.type		 = VD_array;
	__OUT_PPL.v.aval.size    = 0;
	__OUT_PPL.v.aval.element = NULL;

	msg = VD_exec_pplFunk( file_name, func_name );

	if( (msg&1) && __OUT_PPL.v.aval.size && __OUT_PPL.v.aval.element )
	{
	   if( __OUT_PPL.v.aval.size > 1 )
	   {
	      res->type           = VS_array;
	      res->v.aval.size    = __OUT_PPL.v.aval.size;
	      if( !( res->v.aval.element = _MALLOC( res->v.aval.size, 
		     VSexecRes )) ) return xfFAILURE;

	      for( i=0; i<res->v.aval.size; ++i )
	      {
		switch( __OUT_PPL.v.aval.element[i].type ){

		case VD_int :
			res->v.aval.element[i].type = VS_int;
			res->v.aval.element[i]._ival = 	
				__OUT_PPL.v.aval.element[i]._ival;
			break;

		case VD_double :
			res->v.aval.element[i].type = VS_double;
			res->v.aval.element[i]._dval = 
				__OUT_PPL.v.aval.element[i]._dval;
			break;

		case VD_string :
			res->v.aval.element[i].type = VS_string;
			strcpy( res->v.aval.element[i]._sval, 
				__OUT_PPL.v.aval.element[i]._sval );
			break;

		case VD_object :
			res->v.aval.element[i].type  = VS_object;
			res->v.aval.element[i]._oval =  
				__OUT_PPL.v.aval.element[i]._oval;
			break;

		default :	printf(" unknown case \n");
				return	xfFAILURE;
		}

	      }
           }
	   else
	   {
		switch( __OUT_PPL.v.aval.element[0].type ){

		case VD_int :
			res->type = VS_int;
			res->_ival = __OUT_PPL.v.aval.element[0]._ival;
			break;

		case VD_double :
			res->type = VS_double;
			res->_dval = __OUT_PPL.v.aval.element[0]._dval;
			break;

		case VD_string :
			res->type = VS_string;
			strcpy( res->_sval, __OUT_PPL.v.aval.element[0]._sval );
			break;

		case VD_object :
			res->type  = VS_object;
			res->_oval = __OUT_PPL.v.aval.element[0]._oval;
			break;

		default :	printf(" unknown case \n");
				return	xfFAILURE;
		}	        
	   }
	}
	else
	{
	      res->type  = VS_int;
	      res->_ival = 0;
	}

wrapup :

        __INP_PPL.v.aval.size = 0;
        _FREE( __INP_PPL.v.aval.element );

        __OUT_PPL.v.aval.size = 0;
        _FREE( __OUT_PPL.v.aval.element );

	End
	return msg ? xfSUCCESS : xfFAILURE ;
}

