/* $Id: VDdrwPplFk.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vddraw/drw/VDdrwPplFk.I
 *
 * Description: Implementation of 'exec-ppl-func' keyword functionality.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwPplFk.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1998/05/14  17:36:36  pinnacle
# TR179801094
#
# Revision 1.2  1998/05/11  19:12:10  pinnacle
# TR179801096
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.6  1998/04/02  12:12:32  pinnacle
# Replaced: vddraw/drw/VDdrwPplFk.I for:  by rchennup for vds
#
# Revision 1.5  1998/03/26  21:59:56  pinnacle
# Replaced: vddraw/drw/VDdrwPplFk.I for:  by azuurhou for vds
#
# Revision 1.4  1997/11/25  06:15:26  pinnacle
# Replaced: vddraw/drw/VDdrwPplFk.I for:  by rchennup for vds
#
# Revision 1.1  1997/11/19  08:57:34  pinnacle
# Created: vddraw/drw/VDdrwPplFk.I by rchennup for vds
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      11/19/97   Rama Rao     File Creation
 *	03/26/97   adz		Add call for SM_PLL attribute usage.
 *      05/11/98   ah           TR179801096 Debug statement casuing core dump
 *      05/14/98   ah           TR179601096 Delete the extern for globals
 *************************************************************************/

/*
 * 05/11/98 ah
 * These routines were written to support calling ppl's during extract drawing.
 * They allowed variable number of input/output arguments.
 * They never really got tested during cert.
 *
 * These routines wer called for getting endtreatment infor for beams.
 * 179801096 fixed one core dump but still having other problems.
 * test file proftest.m from 179603965 still core dumps sometimes when getting
 * endtreatinfo0.  Other times, the ppl is not getting called and get a message
 * VSstfEndInfo.main() cannot be found.
 *
 * I don't know if the problem lies in these routines or in the struct end treatment
 * code itself.  We have other problems in that code as well.
 *
 * However, I removed the call to these routines and used smart attributes instead.
 * This seems to have helped.
 */
class implementation VDSroot;

#include <stdio.h>
#include "parametric.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_pplslc.h"
#include "VDmem.h"

from  ci	import	set_value;

/*
 * Three global data structures to handle the interaction of data
 * between the system and PPL programs.
 */

VD_execRes	__INP_PPL, __OUT_PPL, __GLOB_PPL;

IGRlong  VD_pplLoadEntry( struct GRid	ppl_id,
			  IGRchar	*entry_name,
			  IGRchar	*entry_value,
			  IGRint	entry_val_size )
{
  IGRint  msg;
  IGRlong sts;

     sts = om$send( msg = message ci.set_value
                  	  ( &msg, entry_name, entry_value, entry_val_size ),
		      senderid = ppl_id.objid,
                      targetid = ppl_id.objid,
                      targetos = ppl_id.osnum  );
     if( sts&msg&1 ) return 1;
     else            return 0;
}

IGRlong  VDppl_GetSize(	IGRint          which_info,
                       	IGRint          *size           )
{

   if( which_info == INPUT_INFO )
   {
	*size = __INP_PPL.v.aval.size;
   }
   else if( which_info == OUTPUT_INFO ) 
   {
	*size = __OUT_PPL.v.aval.size;
   }
   else if( which_info == GLOBAL_INFO )
   {
        *size = __GLOB_PPL.v.aval.size;
   }
   else 
   {
	printf(" Invalid info-option %d\n", which_info );
	return 0;
   }

   return 1;
}


IGRlong  VDppl_SetSize(	IGRint          which_info,
                       	IGRint          size           )
{

     if( which_info == INPUT_INFO )
     {
        __INP_PPL.type = VD_array;

        __INP_PPL.v.aval.size = size;

        if( __INP_PPL.v.aval.element ) _FREE( __INP_PPL.v.aval.element );

        __INP_PPL.v.aval.element = NULL;

	if( !size ) return 1;

        if( !( __INP_PPL.v.aval.element  = _MALLOC( size, VD_execRes ) ) )
                return 0;
     }
     else if( which_info == OUTPUT_INFO )
     {
        __OUT_PPL.type = VD_array;

        __OUT_PPL.v.aval.size = size;

        if( __OUT_PPL.v.aval.element ) _FREE( __OUT_PPL.v.aval.element );

        __OUT_PPL.v.aval.element = NULL;

	if( !size ) return 1;

        if( !( __OUT_PPL.v.aval.element  = _MALLOC( size, VD_execRes ) ) )
                return 0;
     }
     else if( which_info == GLOBAL_INFO )
     {
        __GLOB_PPL.type = VD_array;

        __GLOB_PPL.v.aval.size = size;

        if( __GLOB_PPL.v.aval.element ) _FREE( __GLOB_PPL.v.aval.element );

        __GLOB_PPL.v.aval.element = NULL;

	if( !size ) return 1;

        if( !( __GLOB_PPL.v.aval.element  = _MALLOC( size, VD_execRes ) ) )
                return 0;
     }
     else 
     {
	printf(" Invalid info-option %d\n", which_info );
	return 0;
     }

     return 1;
}


IGRlong VDppl_FreeGlobal(  IGRint          which_info )
{

   if( which_info == INPUT_INFO )
   {	
	__INP_PPL.v.aval.size = 0;
	_FREE( __INP_PPL.v.aval.element );
   }
   else if( which_info == OUTPUT_INFO )
   {
	__OUT_PPL.v.aval.size = 0;
	_FREE( __OUT_PPL.v.aval.element );
   }
   else if( which_info == GLOBAL_INFO )
   {
	__GLOB_PPL.v.aval.size = 0;
	_FREE( __GLOB_PPL.v.aval.element );
   }
   else 
   {
	printf(" Invalid info-option %d\n", which_info );
	return 0;
   }

   return 1;
}

IGRlong VDppl_GetArg_AtIndex(	IGRint          which_info,
                                IGRint          index,
                                IGRint          *type,
                                void            *value )
{
   IGRint		loc_type, dummy_size, *loc_int;
   IGRdouble		*loc_dbl;
   IGRchar		*loc_str;
   struct GRobj_env    	*loc_obj;
   VD_execRes		*dummy_res;

   	if( !type && !value   )
     	{
 	    printf(" Invalid Arguments: Send the Value or Type Pointer\n" );
            return 0; 
        }

        if( which_info == INPUT_INFO )
	{
	    dummy_size = __INP_PPL.v.aval.size;
	    if( !dummy_size )  { printf(" Input is not set\n"); return 0; }
	    dummy_res  = &__INP_PPL.v.aval.element[index];
	}
	else if( which_info == OUTPUT_INFO )
	{
	    dummy_size = __OUT_PPL.v.aval.size;
	    if( !dummy_size )  { printf(" Output is not set\n"); return 0; }
	    dummy_res  = &__OUT_PPL.v.aval.element[index];
	}
	else if( which_info == GLOBAL_INFO )
	{
	    dummy_size = __GLOB_PPL.v.aval.size;
	    if( !dummy_size )  { printf(" Global is not set\n"); return 0; }
	    dummy_res  = &__GLOB_PPL.v.aval.element[index];
	}
   	else 
   	{
	    printf(" Invalid info-option %d\n", which_info );
	    return 0;
   	}

	if( index < 0 || index >= dummy_size ) 
	{
	   printf(" Invalid index: Index should be greater than zero and less than %d\n",
			dummy_size );
	   return 0;
        }

	loc_type = dummy_res->type;

	if( type )   *type = loc_type;

	if( value )
	{
	    switch( loc_type )
	    {
                case VD_int :
			loc_int = (IGRint *)value ;
		  	*loc_int = dummy_res->_ival;
			break;

                case VD_double :
			loc_dbl = (IGRdouble *)value ;
			*loc_dbl = dummy_res->_dval;
			break;

                case VD_string :
			loc_str = (IGRchar *)value ;
			strcpy(loc_str, dummy_res->_sval);
                        break;

                case VD_object :
			loc_obj = (struct GRobj_env *)value ;
                        *loc_obj = dummy_res->_oval;
                        break;

                default :       printf(" unknown case \n");
                                return  0;
	    }
	}

	return 1;
}

IGRlong VDppl_SetArg_AtIndex(	IGRint          which_info,
                                IGRint          index,
                                IGRint          type,
                                void            *value )
{
   IGRint		dummy_size, *loc_int;
   IGRdouble		*loc_dbl;
   struct GRobj_env    	*loc_obj;
   VD_execRes		*dummy_res=NULL;

     	if( !value )
     	{
	   printf(" Invalid Arguments: Send the Value Pointer\n" );
           return 0; 
     	}

     	if( ( type != VD_int )    && ( type != VD_double ) && 
	    ( type != VD_object ) && ( type != VD_string )	)
     	{
	   printf(" Invalid Type: Valid Types are VD_int, VD_double, VD_object, VD_string, VD_array\n");
           return 0;
     	}


        if( which_info == INPUT_INFO )
	{
	    dummy_size = __INP_PPL.v.aval.size;
	    if( !dummy_size || index < 0 || index >= dummy_size ) 
            {
		if( !dummy_size ) printf(" Error: Input size is not set\n");
		else printf(" Error: Index should be between 0 and %d\n", dummy_size );
	  	return 0;
	    }
	    dummy_res  = &__INP_PPL.v.aval.element[index];
	}
	else if( which_info == OUTPUT_INFO )
	{
	    dummy_size = __OUT_PPL.v.aval.size;
	    if( !dummy_size || index < 0 || index >= dummy_size )
	    {
                if( !dummy_size ) printf(" Error: Output size is not set\n");
                else printf(" Error: Index should be between 0 and %d\n", dummy_size );
                return 0;
	    }
	    dummy_res  = &__OUT_PPL.v.aval.element[index];
	}
	else if( which_info == GLOBAL_INFO )
	{
	    dummy_size = __GLOB_PPL.v.aval.size;
	    if( !dummy_size || index < 0 || index >= dummy_size )
	    {
                if( !dummy_size ) printf(" Error: Output size is not set\n");
                else printf(" Error: Index should be between 0 and %d\n", dummy_size );
                return 0;
	    }
	    dummy_res  = &__GLOB_PPL.v.aval.element[index];
	}
   	else 
   	{
	    printf(" Invalid info-option %d\n", which_info );
	    return 0;
   	}

	if( dummy_res )
	{
	    switch( type )
	    {
                case VD_int :
			loc_int = ( IGRint * ) value;
		  	dummy_res->_ival = *loc_int;
			break;

                case VD_double :
			loc_dbl = ( IGRdouble * ) value;
			dummy_res->_dval = *loc_dbl;
			break;

                case VD_string :
			strcpy( dummy_res->_sval, value );
                        break;

                case VD_object :
			loc_obj = ( struct GRobj_env * ) value;
			dummy_res->_oval = *loc_obj;
                        break;

                default :       printf(" unknown case \n");
                                return  0;
	    }
	}
	dummy_res->type = type;

	return 1;
}

IGRlong	VD_exec_pplFunk( IGRchar	 *file_name,
			 IGRchar	 *func_name,
			 struct GRid	 *object,
			 struct GRmd_env *md_env      )
{
    struct GRid ppl_id;

        if (!VD_pplLoad (file_name, func_name, &ppl_id )) return 0;

	if ( object )  VD_pplLoadEntry( ppl_id, "OBJECT_ID", 
				(IGRchar *) object, sizeof(struct GRid) );
	if ( md_env )  VD_pplLoadEntry( ppl_id, "OBJECT_ENV", 
				(IGRchar *) md_env, sizeof(struct GRmd_env ));

        if (!VD_pplRun (file_name, func_name, ppl_id, NULL )) return 0;

//        VD_pplDelete (ppl_id);

	return 1;
}

IGRlong VDppl_exec( IGRchar	*file_name,
		    IGRchar	*func_name,
		    IGRint	nb_args,
		    VD_execRes  *args_list  )
{
   IGRint  	i;
   IGRlong 	sts;

	if( nb_args && args_list )
	{
	   sts = vd$ppl_set_size(  which_info = INPUT_INFO,
				   size       = nb_args	     );
	   if( !(sts&1) )  return sts;

	   for( i=0; i<nb_args; ++i )
	   {
	     switch( args_list[i].type )
	     {
                case VD_int :
		  sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
					        index      = i,
					  	type       = VD_int,
					  	value = &args_list[i]._ival );
		  if( !(sts&1) )  return sts;
		  break;

                case VD_double :
                  sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                          	index      = i,
                                          	type       = VD_double,
                                          	value = &args_list[i]._dval );
                  if( !(sts&1) )  return sts;
                  break;

                case VD_string :
                  sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                                index      = i,
                                                type       = VD_string,
                                                value = args_list[i]._sval );
                  if( !(sts&1) )  return sts;
                  break;

                case VD_object :
                  sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                                index      = i,
                                                type       = VD_object,
                                                value = &args_list[i]._oval );
                  if( !(sts&1) )  return sts;
                  break;

                default :       printf(" unknown case \n");
                                return  0;
	     }
	   }
	}
   	return ( VD_exec_pplFunk( file_name, func_name, NULL, NULL ) );
}

IGRlong VDobj_ppl_exec( IGRchar		*file_name,
		        IGRchar		*func_name,
             		struct GRid     *object,
             		struct GRmd_env *module_info,
             		IGRint          IN_count,
             		VD_execRes      *IN_args,
             		IGRint          *OUT_count,
             		VD_execRes      **OUT_args  )
{
   IGRint  	i, out_cnt;
   IGRlong 	sts;

	if( IN_count && IN_args )
	{
	   sts = vd$ppl_set_size(  which_info = INPUT_INFO,
				   size       = IN_count	     );
	   if( !(sts&1) )  return sts;

	   for( i=0; i<IN_count; ++i )
	   {
	     switch( IN_args[i].type )
	     {
                case VD_int :
		  sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
					        index      = i,
					  	type       = VD_int,
					  	value = &IN_args[i]._ival );
		  if( !(sts&1) )  return sts;
		  break;

                case VD_double :
                  sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                          	index      = i,
                                          	type       = VD_double,
                                          	value = &IN_args[i]._dval );
                  if( !(sts&1) )  return sts;
                  break;

                case VD_string :
                  sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                                index      = i,
                                                type       = VD_string,
                                                value = IN_args[i]._sval );
                  if( !(sts&1) )  return sts;
                  break;

                case VD_object :
                  sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                                index      = i,
                                                type       = VD_object,
                                                value = &IN_args[i]._oval );
                  if( !(sts&1) )  return sts;
                  break;

                default :       printf(" unknown case \n");
                                return  0;
	     }
	   }
	}

   	if ( !(VD_exec_pplFunk( file_name, func_name, object, module_info )) )
        return 0;

	if( OUT_count || OUT_args )
	{
	    vd$ppl_get_size(  	which_info = OUTPUT_INFO,
                         	size       = &out_cnt    );
	    if( OUT_count ) *OUT_count = out_cnt;

	    if( !OUT_args ) return 1;

	    if( !(*OUT_args = _MALLOC( out_cnt, VD_execRes )) ) return 0;
	    for( i=0; i<out_cnt; ++i )
	    {
	      vd$ppl_getarg_at_index(  which_info = OUTPUT_INFO,
                               	       index	  = i,
                                       type       = &(*OUT_args)[i].type );

	      switch( (*OUT_args)[i].type )
	      {
                case VD_int :
		  sts = vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
					        index      = i,
					  	value = &(*OUT_args)[i]._ival );
		  if( !(sts&1) )  return sts;
		  break;

                case VD_double :
                  sts = vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
                                          	index      = i,
                                          	value = &(*OUT_args)[i]._dval );
                  if( !(sts&1) )  return sts;
                  break;

                case VD_string :
                  sts = vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
                                                index      = i,
                                                value = (*OUT_args)[i]._sval );
                  if( !(sts&1) )  return sts;
                  break;

                case VD_object :
                  sts = vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
                                                index      = i,
                                                value = &(*OUT_args)[i]._oval );
                  if( !(sts&1) )  return sts;
                  break;

                default :       printf(" unknown case \n");
                                return  0;
	      }  
	    }
	}

	vd$ppl_free_args( which_info = INPUT_INFO );
	vd$ppl_free_args( which_info = OUTPUT_INFO );

	return 1;
}

IGRlong VDppl_give_info(IGRchar		*file_name,
		        IGRchar		*func_name,
             		struct GRid     *object,
             		struct GRmd_env *module_info,
			IGRchar		*arg_0,
			IGRchar		*arg_1,
			struct ret_struct *retStr )
{
	/*
	 * Retrieve the information for PPL processing.
	 */
	IGRint		i, out_cnt;
	IGRlong 	sts;

	/*
	 * Initialization of output buffers.
	 */
	
	retStr->type = text_type ;
	strcpy( retStr->var.text_st.text_string, "");

	if( arg_0 )
	{
	   sts = vd$ppl_set_size(  which_info = INPUT_INFO,
				   size       = 1 );
	   if( !(sts&1) )  return sts;

           sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                   index	= 0,
                                   type		= VD_string,
                                   value	= arg_0 );
           if( !(sts&1) )  return sts;
	}

	if( arg_1 && arg_0 )
	{
	   sts = vd$ppl_set_size(  which_info = INPUT_INFO,
				   size       = 2	     );
	   if( !(sts&1) )  return sts;

           sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                   index	= 0,
                                   type		= VD_string,
                                   value	= arg_0 );
           if( !(sts&1) )  return sts;

           sts = vd$ppl_setarg_at_index( which_info = INPUT_INFO,
                                   index      	= 1,
                                   type       	= VD_string,
                                   value	= arg_1 );
           if( !(sts&1) )  return sts;
	}

   	if ( !(VD_exec_pplFunk( file_name, func_name, object, module_info )) )
        	return 0;

	if( retStr ){

	    out_cnt = 0 ;
	    vd$ppl_get_size(  	which_info = OUTPUT_INFO,
                         	size       = &out_cnt    );

	    // __DBGpr_int(" OUT_count ", out_cnt ); TR179801096

	    if( out_cnt > 1 ) out_cnt = 1 ;

	    /* Currently only one attribute */
	    for( i=0; i<out_cnt; ++i )
	    {
	      vd$ppl_getarg_at_index(  which_info = OUTPUT_INFO,
                               	       index	  = i,
                                       type       = &retStr->type );

	      switch( retStr->type )
	      {
                case VD_int :
                case VD_double :

		  retStr->type = double_type ;
                  sts = vd$ppl_getarg_at_index(
				which_info = OUTPUT_INFO,
                                index      = i,
                                value      = &retStr->var.root_pm_st.value );
                  if( !(sts&1) )  return sts;
                  break;

                case VD_string :

		  retStr->type = text_type ;
                  sts = vd$ppl_getarg_at_index(
				which_info = OUTPUT_INFO,
                                index      = i,
                                value	   = retStr->var.text_st.text_string );
                  if( !(sts&1) )  return sts;
                  break;

                default :       printf(" unknown case \n");
                                return  0;
	      }  
	    } /* for ... */
	} /* if OUT_... */

	vd$ppl_free_args( which_info = INPUT_INFO );
	vd$ppl_free_args( which_info = OUTPUT_INFO );

	return 1;
}

end implementation VDSroot;
