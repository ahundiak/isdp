/* $Id: VDutilqry.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/func/VDutilqry.I
 *
 * Description:
 *  The purpose of the function is to handle query on attributes
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDutilqry.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  19:23:56  pinnacle
# UnInit warnings
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/31/97	ah		UnInit warnings, header
 * -------------------------------------------------------------------*/

class implementation Root;

#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "wl.h"
#include "OMminimum.h"
#include "OMerrordef.h"			/* OM_E_ABORT */
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"

#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igrdef.h"
#include "dp.h"
#include "lcdef.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "igecolmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "growner.h"
#include "parametric.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "VDquery.h"
#include "vdpardef.h"
#include "VDQYdef.h"
#include "vdparmacros.h"
#include "vdqrydef.h"
#include "vdrefmacros.h"
#include "v_miscmacros.h"
#icnlude "v_datamacros.h"
#include "v_dbgmacros.h"
#include "refmacros.h"
#include "bsmalloc.h"
#include "VDmem.h"

from    ACcpx_defn      import  ACgive_name;
from    ACcpx           import  find_macro;
from 	ACmacro_defn 	import 	ACgive_feet_desc;
from	NDmacro		import	ACgive_structure;
from	ACncpx		import	ACreturn_foot,
				ACfind_temp_obj;
from	ACdb_info	import	ACgive_db_structure;
from	GRvg		import	GRgetsymb;
from	expression	import	NDgive_value;
from	VDquery		import	ACcreate,
				VDname_query,
				VDgive_query,
				VDcreate ;

/* #define DEBUG	1  */


/******************************************************************************

Function:
    
    VDquery_on_attr

Description:


    This function return the status of the test "att operator operant2".
    att is got by sending a ACgive_structure to the object with the name
    of the attribute (operant1) to test the attribute value or the GRgetsymb
    to test the symbology of the object.

Return Status

    status	= TRUE ;	 query is true 
    status	= FALSE;	 otherwise    
    
 */


VDquery_on_attr( msg, object, operant1, operator, operant2 )
IGRlong			*msg;
struct	GRobj_env	*object;
IGRchar			*operant1;
IGRint			operator;
IGRchar			*operant2; 
{
IGRint			status = OM_S_SUCCESS ,
			sts,
			dir_index ;
IGRshort		sDummy;
struct	ret_struct	str;
struct	GRsymbology	symb;		/* object symbology. */
struct	GRid		module;
IGRchar			op2[50];	
IGRchar			vstring[50];	
IGRint                  mirr_flag = FALSE;
struct GRid             macroDef ;
IGRchar                 *macName ;

        SetProc( VDquery_on_attr ); Begin

	*msg = MSSUCC ;

	if(( ! operant1 ) || ( ! operant2 ))
		goto wrapup;

	if( operator == VD_cnt_qry_NONE )
		goto wrapup;

	dir_index= -1;
	str.type = NULL;

	if( ( strcmp( VD_str_symb_LEVEL,  operant1 ) == 0 ) ||
	    ( strcmp( VD_str_symb_COLOR,  operant1 ) == 0 ) ||
	    ( strcmp( VD_str_symb_WEIGHT, operant1 ) == 0 ) || 
            ( strcmp( VD_str_symb_STYLE,  operant1 ) == 0 )) {
 
		/*
		 * get the symbology and test on it.
		 */
		status =
		om$send(msg = message GRvg.GRgetsymb( msg, &symb ),
			senderid = object->obj_id.objid,
			targetos = object->obj_id.osnum ,
			targetid = object->obj_id.objid );
		if( ! ( status & *msg & 1 )){ goto wrapup; }

		/*
		 * check and set for level symbology.
		 */
		if( strcmp( VD_str_symb_LEVEL,  operant1 ) == 0 ){
		
			__DBGpr_int(" check in level ",  symb.level );
	
       			/*
			 * fill in the structure to the condition.
			 */

			str.type = double_type;
			str.var.root_pm_st.value = (double ) symb.level ;

			if( ! isdigit( *operant2 )){

			    /*
			     * find the layer number corresponding to the
			     * layer name
			     */

			    status =
			    ex$get_cur_mod(	id	= &module.objid,
						osnum	= &module.osnum );

			    status =
			    dp$levels_name_to_number(
						msg	= msg,
						name	= operant2,
						number	= &sDummy,
						mod_objid = module.objid,
						osnum	= module.osnum);

         		    __DBGpr_int(" layer <operant2> ",  operant2);
         		    __DBGpr_int(" layer <sDummy> ",  sDummy);

			    sprintf( operant2, "%d", sDummy );

			}
		}

		/*
		 * check and set for color symbology.
		 */
		else if( strcmp( VD_str_symb_COLOR,  operant1 ) == 0 ){

			__DBGpr_int("color",  symb.display_attr.color );
			
			/*
			 * fill in the structure to the condition.
			 */
			str.type = double_type;
			str.var.root_pm_st.value =
					(double ) symb.display_attr.color ;

			if( ! isdigit( *operant2 )){

			    status =
			    ige$get_color_from_name(
						color	= &sDummy,
						name	= operant2 );
			    if( !(status&1)){ goto wrapup ; }

			    __DBGpr_int("color<operant2>", operant2);
			    __DBGpr_int("color<sDummy>", sDummy);
			    
			    sprintf( operant2, "%d", sDummy );
			}
		}

		/*
		 * check and set for weight symbology.
		 */
		else if ( strcmp( VD_str_symb_WEIGHT, operant1 ) == 0 ){

			__DBGpr_int("weight",symb.display_attr.weight );
			/*
			 * fill in the structure to the condition.
			 */
			str.type = double_type;
			str.var.root_pm_st.value =
					(double) symb.display_attr.weight ;
		}

		/*
		 * check and set for style symbology.
		 */
		else if ( strcmp( VD_str_symb_STYLE,  operant1 ) == 0 ){

	        __DBGpr_int(" check in style ", symb.display_attr.style );
			/*
			 * fill in the structure to the condition.
			 */
			str.type = double_type;
			str.var.root_pm_st.value =
					(double) symb.display_attr.style ;
		}
		else goto wrapup;
	}

	/*
	 * check on attribute information.
	 */
	else{

           __DBGpr_com(" Checkin attributes ");
           __DBGpr_obj(" object->obj_id ", object->obj_id);

           mirr_flag = FALSE;
           /*
            * Get the macro definition name.
            */
        
 	   status =
           _VD_SEND_OBJN(  object->obj_id, ACcpx.find_macro( &macroDef ));
           __CheckRC( status, 1, "ACcpx.find_macro", none ) ;

           status =
           _VD_SEND_OBJN(  macroDef, ACcpx_defn.ACgive_name( &macName ));
           __CheckRC( status, 1, " ACcpx_defn.ACgive_name", none ) ;

           if ( strcmp ( macName, "cpymir" ) == 0 ) {
  
              IGRchar      tempoperant1[80]; 
              IGRint       len;

              __DBGpr_com(" Get owner object ");
              __DBGpr_str(" operant1 ", operant1);

              len = strlen(operant1);
              __DBGpr_int(" len ", len);

              if(len >= 9 && strncmp(operant1,"miror_obj",9)){ 
                  tempoperant1[0] = '\0';
                  strcat( tempoperant1, "miror_obj:"); 
                  strcat( tempoperant1, operant1); 
              }
              else {
                  tempoperant1[0] = '\0';
                  strcat( tempoperant1, operant1); 
              }
              __DBGpr_str(" tempoperant1 ", tempoperant1);

              status =
              om$send(msg = message NDmacro.ACgive_structure (
                                                &sts,
                                                &dir_index,
                                                tempoperant1,
                                                &str,
                                                &object->mod_env ),
                        senderid = object->obj_id.objid,
                        targetos = object->obj_id.osnum ,
                        targetid = object->obj_id.objid);
              __CheckRC( status, sts, "NDmacro.ACgive_structure", none ) ;

              mirr_flag = TRUE;
              __DBGpr_com(" Success to get owner of mirror object ");
           }

none:
           if( !mirr_flag ) {
                __DBGpr_com(" No mirror object ");
		status =
		om$send(msg = message NDmacro.ACgive_structure (
						&sts,
						&dir_index,
						operant1, 
						&str,
						&object->mod_env ),
			senderid = object->obj_id.objid, 
			targetos = object->obj_id.osnum ,
			targetid = object->obj_id.objid);
		if(!(status & sts & 1)) {
			/*
			 * try ACgive_db_structure to get the cache (ROUTE)
			 */
			status =
			om$send(msg = message ACdb_info.ACgive_db_structure ( 
							&sts, 
							&dir_index, 
							operant1,
							&str,
							&object->mod_env ),
				senderid = object->obj_id.objid,
				targetos = object->obj_id.osnum ,
				targetid = object->obj_id.objid);

		}

		if(!(status & sts & 1)) {

		  struct GRid	Temp;
		  double	value ;

		  status =
		  om$send(msg = message ACncpx.ACfind_temp_obj( &sts,
								operant1,
								&Temp ),
				senderid = object->obj_id.objid,
				targetos = object->obj_id.osnum ,
				targetid = object->obj_id.objid);
		  if( status & sts & 1 ){
		    status =
		    om$send(msg = message expression.NDgive_value( &value ),
			    senderid = NULL_OBJID,
			    targetos = Temp.osnum ,
			    targetid = Temp.objid );

		    str.type = double_type ;
		    str.var.root_pm_st.value = value ;
		  }
		}
          }
	} /* else */

	/*
	 * check the structure type to classify the condition.
	 */
        op2[0] = '\0';
        vstring[0] = '\0';

	if( str.type == double_type ){
		
	    __DBGpr_int(" double_type str.type ", str.type);
	    __DBGpr_dbl(" str.var.root_pm_st.value",
                              str.var.root_pm_st.value);
            
 	    /* convert  str.var.root_pm_st.value to string,
             * then check it VD_matchRE against operant2, if it is true
             * using the converted string as input value. 
             */
            sprintf(vstring, "%.16f", str.var.root_pm_st.value);           
            status =
            VD_matchRE(operant2,vstring);		
            if (status) 
                 strcpy(op2,vstring);
            else
                 strcpy(op2,operant2);

	    /*
	     * scanf will die if we cannot get a double
	     */
	    if (isdigit ( *op2 )){

		double val;

		sscanf ( op2, "%lf", &val );

		switch (operator)
		{
		case VD_cnt_qry_G_THAN :
			status = str.var.root_pm_st.value > val;
			break;
		case VD_cnt_qry_L_THAN :
			status = str.var.root_pm_st.value < val;
			break;
		case VD_cnt_qry_G_EQUAL:
			status = str.var.root_pm_st.value >= val;
			break;
		case VD_cnt_qry_L_EQUAL:
			status = str.var.root_pm_st.value <= val;
			break;
		case VD_cnt_qry_EQUAL  :
			status = str.var.root_pm_st.value == val;
			break;
		case VD_cnt_qry_N_EQUAL:
			status = str.var.root_pm_st.value != val;
			break;
		default: status = OM_E_ABORT;
		}
	    }
	    else
		/*
		 * we abort the checking.
		 */
		status = 0; 
	}

	else if (str.type == text_type ) {
		
		__DBGpr_int(" text_type str.type ", str.type);
		__DBGpr_str(" str.var.text_st.text_string ", 
                         str.var.text_st.text_string);
            
	    /* check  str.var.text_st.text_string using 
             * VD_matchRE against operant2, if it is true
             * using str.var.text_st.text_string as input value. 
             */
            strcpy(vstring, str.var.text_st.text_string);           
            status =
            VD_matchRE(operant2,vstring);		
            if (status) 
                 strcpy(op2,vstring);
            else
                 strcpy(op2,operant2);

		switch (operator)
		{
		case VD_cnt_qry_G_THAN : status =
			strcmp ( str.var.text_st.text_string, op2 ) > 0;
			break;
		case VD_cnt_qry_L_THAN : status =
			strcmp ( str.var.text_st.text_string, op2 ) < 0;
			break;
		case VD_cnt_qry_G_EQUAL: status =
			strcmp ( str.var.text_st.text_string, op2 ) >= 0;
			break;
		case VD_cnt_qry_L_EQUAL: status =
			strcmp ( str.var.text_st.text_string, op2 ) <= 0;
			break;
		case VD_cnt_qry_EQUAL  : status = 
			strcmp ( str.var.text_st.text_string, op2 ) == 0;
			break;
		case VD_cnt_qry_N_EQUAL: status = 
			strcmp ( str.var.text_st.text_string, op2 ) != 0;
			break;
#ifdef YYYYY
			if (di$is_regexp ( regexp = operant2 )){

			    char **reg_buffer;
			    int  i, reg_count;

			    /*
			     *  compile the regular expression 
			     */
			    DImulti_parse ( operant2, &reg_buffer, &reg_count );

			    /*
			     * check if we match it or not
			     */
			    if (operator == VD_cnt_qry_EQUAL  )
				status = DImulti_step(
						str.var.text_st.text_string, 
						reg_buffer,
						reg_count );
			    else
				status = !DImulti_step(
						str.var.text_st.text_string,
						reg_buffer,
						reg_count );

			    for (i = 0; i < reg_count; i++)
				_FREE ( reg_buffer [i] );
			    _FREE( reg_buffer ); 
			}
			else
			    if (operator == VD_cnt_qry_EQUAL  )
				status = strcmp(str.var.text_st.text_string,
						operant2 ) == 0;
			    else
				status = strcmp(str.var.text_st.text_string,
						operant2 ) != 0;

			break;
#endif

		default: status = 0; /*OM_E_ABORT;*/
		}
	}

	else if (str.type == macro_generic ) {
	
        	__DBGpr_int(" macro_generic str_type ", str.type);
		__DBGpr_str(" str.var.macro_st.name ", 
                         str.var.macro_st.name);
            
	    /* check  str.var.macro_st.name using 
             * VD_matchRE against operant2, if it is true
             * using str.var.macro_st.name as input value. 
             */
            strcpy(vstring, str.var.macro_st.name);           
            status =
            VD_matchRE(operant2,vstring);		
            if (status) 
                 strcpy(op2,vstring);
            else
                 strcpy(op2,operant2);

	    switch (operator)
	    {
            case VD_cnt_qry_G_THAN :
		status = strcmp ( str.var.macro_st.name, op2 ) > 0;
		break;
            case VD_cnt_qry_L_THAN :
		status = strcmp ( str.var.macro_st.name, op2 ) < 0;
                break;
	    case VD_cnt_qry_G_EQUAL:
		status = strcmp ( str.var.macro_st.name, op2 ) >= 0;
                break;
            case VD_cnt_qry_L_EQUAL:
		status = strcmp ( str.var.macro_st.name, op2 ) <= 0;
                break;
            case VD_cnt_qry_EQUAL  : 
		status = strcmp ( str.var.macro_st.name, op2 ) == 0;
                break;
            case VD_cnt_qry_N_EQUAL:
		status = strcmp ( str.var.macro_st.name, op2 ) != 0;
                break;

#ifdef YYYYY
		if (di$is_regexp ( regexp = operant2 )){

			char **reg_buffer;
			int  i, reg_count;

			/*
			 * compile the regular expression
			 */
			DImulti_parse ( operant2, &reg_buffer, &reg_count );

			/*
			 * check if we match it or not
			 */
			if (operator == VD_cnt_qry_EQUAL  )
				status = DImulti_step(
						str.var.macro_st.name, 
						reg_buffer,
						reg_count );
			else
				status = !DImulti_step(
						str.var.macro_st.name, 
						reg_buffer,
						reg_count );

			for (i = 0; i < reg_count; i++)
				_FREE ( reg_buffer [i] );
			_FREE ( reg_buffer );
                 }
                 else
                 	if (operator == VD_cnt_qry_EQUAL  )
                 		status = strcmp(str.var.macro_st.name,
						operant2 ) == 0;
			else
				status = strcmp(str.var.macro_st.name,
						operant2 ) != 0;

                 break;
#endif

	    default: status = 0; /*OM_E_ABORT;*/
	    }
	}
	else
		status = 0; /*OM_E_ABORT; */


	/*
	 * return the status of the attribute query.
	 */
        End       
	return status;

wrapup:
        End
	return 0;

}


/******************************************************************************

Function:
    
    VDqry_create_object

Description:

    This function return the object identifier of a new created querie object.
    The information will be stored in the collector object.

Return Status

    status	= TRUE ;	 query is true 
    status	= FALSE;	 otherwise    
    
 */

VDqry_create_object( msg, object, name, query, comment )
IGRlong			*msg;		/* out */
struct	GRid		*object;	/* out */
IGRchar			*name; 		/* in:  query name. */
IGRchar			*query;		/* in  */
IGRchar			*comment;	/* in  */	
{
IGRint			status,
			index;
struct	GRid		obj;
GRspacenum		curOs;
GRname			qryName,
			objName,
			objPwd,
			curDir,
			pwdDir;
IGRchar			select[QUERY_LEN],
			where[QUERY_LEN];

        SetProc( VDqry_create_object ); Begin
#ifdef	DEBUG
	printf(" name   : %s\n", name );
	printf(" query  : %s\n", query );
	printf(" comment: %s\n", comment );
#endif

//	status = FALSE;  // In case of early failure

	/*
	 * create query directory if does not exist and go to it.
	 */
	ex$get_cur_mod(	osnum	= &curOs );

	obj.objid = NULL_OBJID;
	obj.osnum = curOs ;

	status =
	di$pwd(	dirname	= pwdDir );
	if( status != DIR_S_SUCCESS ){
		printf(" VDcreate_query: di$pwd failed \n");
		goto wrapup;
	}

	status = di$give_pathname( osnum = curOs, pathname = curDir );
	as$status( action = RET_STATUS );

	status = di$cd( dirname = curDir );
	if( status != DIR_S_SUCCESS ){
		printf(" Can't go to directory: %s \n", curDir );
		goto wrapup;
	}

	strcat( curDir, ":" );
	strcat(	curDir, QRY_str_DIR_NAME );

	/*
	 * test if directory exists
	 */
	status =
	di$translate(	objname = curDir,
                        p_objid = &obj.objid,
                        p_osnum = &obj.osnum );
	if( status != DIR_S_SUCCESS ){
		/*
		 * create directory
		 */
		obj.objid = NULL_OBJID;
		status =
		di$mkdir(	dirname = curDir,
				p_dirid = &obj.objid,
				p_osnum = &obj.osnum );
		if( status != DIR_S_SUCCESS ){
			/*
			 * mkdir fails
		 	 */
			printf(" VDcreate_query: di$mkdir failed \n");
			goto wrapup;
		}
	}

	status =
	di$cd(	dirname	= curDir );
	if( status != DIR_S_SUCCESS ){
		printf(" VDcreate_query: di$cd failed \n");
		goto wrapup;
	}


	/*
	 * get a new object name.
	 */
	index = 0;
	while( TRUE ){
		sprintf( objPwd, "%s:%s_%d", curDir, QRY_str_DIR_NAME, index );

#ifdef	DEBUG
	printf(" objPwd : %s\n", objPwd );
#endif

		obj.objid = NULL_OBJID;
		status =
		di$translate(	objname = objPwd,
				p_objid = &obj.objid,
                                p_osnum = &obj.osnum );
		if( status != DIR_S_SUCCESS ){
			/*
			 * found a new one
			 */
			break;
		}
		else index++;
	}

	/*
	 * get query name.
	 */
	sprintf( objName, "%s_%d", QRY_str_DIR_NAME, index );
	if( ! name )
		strcpy( qryName, objName );
	else{
		if( strlen( name ) > 60 ) name[60] = '\0';
		strcpy( qryName, name );
	}

	/*
	 * check the syntax of the query line.
	 *
	 * <select> <.....> <where> .....
	 *
	 */

	/*
	 * check if name is unique.
	 */
	obj.objid	= NULL_OBJID;
	status =
	om$construct(	msg = message VDquery.ACcreate(	msg,
							objName ),
			classid	= OPP_VDquery_class_id,
			p_objid = &obj.objid,
			osnum   = obj.osnum );
	as$status( action = GOTO_VALUE, value = wrapup );
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup );

	status = 
	om$send(msg = message VDquery.VDname_query(
					msg,
					qryName ), 
		senderid = NULL_OBJID,
		targetid = obj.objid,
		targetos = obj.osnum );
	as$status( action = GOTO_VALUE, value = wrapup );
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup );

        if( ! ( VDqry_splt_string( query, select, where ))){
                /*
                 * error in the querie setup.
		 */
		strcpy( select, query );
		where[0] = '\0';
	}

	status = 
	om$send(msg = message VDquery.VDcreate (
					msg,
					select,
					where,
					comment ),
		senderid = NULL_OBJID,
		targetid = obj.objid,
		targetos = obj.osnum );
	as$status( action = GOTO_VALUE, value = wrapup );
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup );

	if( object )	*object = obj ;
		
	status =
	di$cd(	dirname	= pwdDir );
	if( status != DIR_S_SUCCESS ){
		printf(" VDcreate_query: di$cd failed \n");
		goto wrapup;
	}

	*msg = MSSUCC ;
        End
	return	TRUE;

wrapup:
		
	status =
	di$cd(	dirname	= pwdDir );
	if( status != DIR_S_SUCCESS ){
		printf(" VDcreate_query: di$cd failed \n");
		goto wrapup;
	}
	*msg = MSFAIL;
        End
	return	FALSE;
} /* VDqry_create_object */  

/***********************************************************************
Function:

    VDqry_check_macro

Description:

    This function return the macro feet namd number of feet based on 
    the macro name.

Return Status

    status      = TRUE ;         macro exists
    status      = FALSE;         otherwise

*/

VDqry_check_macro( msg, name )
IGRlong                 *msg;              	/* out */
IGRchar                 *name;			/* in  */
{
OM_S_CLASSLIST          class_list;
OMuword                 macro_def_clid;
IGRint                  status,i,
                        nb_macros;
IGRchar                 regexp[QUERY_LEN],
                        reg_exp[QUERY_LEN];
DIgrid                  *macros;
DIchar			**mac_name;
struct GRmd_env         md_env;
IGRlong			NumberOfBytes,
                        BytesReceived;

        SetProc( VDqry_check_macro ); Begin
#ifdef DEBUG
        printf("\nFunction VDqry_check_macro .......\n");
        printf(" macroname: = %s\n", name);
#endif
        *msg = MSSUCC ;

        macros = NULL;
        mac_name = NULL;

        /*
         * restrict the search to the ACcpx_defn elements
         */

        class_list.w_flags = OM_CLST_subclass;
        class_list.w_count = 1;
        status =
        om$get_classid( classname = "ACcpx_defn",
                        p_classid = &macro_def_clid );
        if (status != OM_S_SUCCESS) goto wrapup;

        class_list.p_classes = &macro_def_clid;

        NumberOfBytes = sizeof(md_env);
        gr$get_module_env(      msg    = msg,
                                sizbuf = &NumberOfBytes,
                                buffer = &md_env,
                                nret   = &BytesReceived);
        if(!(*msg&1)) {status = OM_E_ABORT; goto wrapup;}

        status =
        di$give_pathname(       pathname = regexp,
                                osnum = md_env.md_id.osnum);
        if (status != 1) goto wrapup;
        /*
         * get the macro names in the directory subsystem
         */

        strcat(regexp,":constructs_lib:*:constructs:");
#ifdef DEBUG
          printf("regexp: %s\n",regexp);
#endif


#ifdef DEBUG
          printf("macro_name: %s\n", name);
#endif

            strcpy(reg_exp, regexp);
            strcat(reg_exp,name);

            strcat(reg_exp,"*");

            nb_macros = 0;
            status =
            di$dump(   regexp = reg_exp,
                       ptr    = &nb_macros,
                       lines  = &mac_name,    /* mac_name is allocated in dump*/
                       grids  = &macros,      /* macro is allocated in dump*/
                       p_classes = &class_list,
                       options = 0 );
            if (status != OM_S_SUCCESS) goto wrapup;

            status = OM_S_SUCCESS;
           
wrapup:
#ifdef DEBUG
        if( mac_name ){
             for(i = 0; i < nb_macros; i++) {
              	printf("lib macro name [%d] = %s\n", i, mac_name[i]);
             }
        } 	
#endif
	
        if( mac_name ){
             for(i = 0; i < nb_macros; i++) {
              	_FREE(mac_name[i]);
             }
             _FREE( mac_name);
        } 		
             
        _FREE(macros);
   
        End
        return status;
} /* VDqry_check_macro */

/***********************************************************************
Function:

    VDqry_give_list

Description:

    This function gives the count and list (optional) the existing 
	queries in the current object space. Whenever ref_file is 
	set to TRUE, the total list of queries is the number of 
	queries in active and reference files.

	Memory for the list of queries need to be allocated and Freed
	outside this function.

Return Status

    status = TRUE ; 

*/


VDqry_give_list( msg, list_size, list, md_env_list, count, ref_file)
IGRlong			*msg;                    /* out */
IGRint                  list_size;               /* in  */
struct GRid		*list;                   /* out */
struct GRmd_env         *md_env_list;            /* out */
IGRint                  *count;                  /* out */
IGRint                  ref_file;                /* in  */
{
IGRint                  i,j,
                        nb_queries,
			qryAlloc,
                        qryCount;
GRname                  classname,
                        curFile,
                        objname;
struct  GRid            *qryDump;
struct  GRid            *qryList;
struct GRmd_env         *qryenvList;           
GRspacenum              cur_os = 0;
IGRint			status;
IGRint			NbOs;
GRspacenum		*osList = NULL;
struct GRmd_env         *envList = NULL;
IGRchar                 refFile[DI_PATH_MAX];
IGRlong                 NumberOfBytes,
                        BytesReceived;
struct GRmd_env         mod_env;
IGRint                  NoOfUniq = 0,ii,jj,found = FALSE;
struct GRid             *qryListUnq = NULL;
struct GRmd_env         *qryenvListUnq = NULL;


        SetProc( VDqry_give_list ); Begin

        *msg = MSSUCC ;

	*count = 0;

        qryList = NULL;
        qryDump = NULL ;
        qryenvList = NULL;

	qryCount = 0;

        /*
         * find the existing query objects.
         */
        status =
        ex$get_cur_mod( osnum   = &cur_os );

        di$give_pathname( osnum = cur_os, pathname = curFile );

        __DBGpr_str(" pathname ", curFile );

        sprintf( objname, "%s:%s:*", curFile, QRY_str_DIR_NAME );

        /* allocat qryDump in di$dump */ 
	nb_queries = 0 ;

        status =
        di$dump(        regexp = objname,
                        grids  = (DIgrid **)&qryDump,
                        ptr    = &nb_queries );

        NumberOfBytes = sizeof(mod_env);
        BytesReceived = 0;
        gr$get_module_env(      msg    = msg,
                                sizbuf = &NumberOfBytes,
                                buffer = &mod_env,
                                nret   = &BytesReceived);

	if( nb_queries != 0 ){
	        qryList = _MALLOC( nb_queries,struct GRid);
	        qryenvList = _MALLOC( nb_queries,struct GRmd_env);
       		for(i = 0; i < nb_queries; i ++){
			qryList[i] = qryDump[i];
                        qryenvList[i] = mod_env;
        	}
		qryCount = nb_queries;

		_FREE( qryDump )  ;
	        qryDump = NULL ;
	}

        /* osList and envList are  allocated in vd$get_ref_os_list */
	if( ref_file ) {
		NbOs = 0 ;
    		status = vd$get_ref_os_list(
				msg		=  msg,
                                main_os		=  &cur_os,
                                num_ref_os	=  &NbOs,
                                ref_os_list	=  &osList,
                                ref_env_list    =  &envList);
            

		for( j = 0; j < NbOs; j++ ) {

			di$give_pathname( osnum = osList[j],
					pathname = refFile );

			sprintf( objname , "%s:%s:*",
						&(refFile[0]),
						QRY_str_DIR_NAME );

			nb_queries = 0 ;
			_FREE( qryDump );
			qryDump = NULL ;

        		status =
        		di$dump(regexp = objname,
                        	grids  = (DIgrid **)&qryDump,
                        	ptr    = &nb_queries );
			if( ! nb_queries || ! (status&1) ){
				_FREE( qryDump );
				qryDump = NULL ;
				continue;
			}

                        qryAlloc = qryCount + nb_queries;

			if( qryList ){
                          qryList = _REALLOC(qryList,qryAlloc, struct GRid);
			}
			else{
	        	  qryList = _MALLOC( qryAlloc, struct GRid);
			}
			if( qryenvList ){
                          qryenvList = _REALLOC(qryenvList,
                                           qryAlloc,struct GRmd_env);
			}
			else{
	        	  qryenvList = _MALLOC(qryAlloc ,struct GRmd_env);
                        }

                        for( i = qryCount; i < qryAlloc; i ++ ) {
            			qryList[i] = qryDump[i - qryCount];
            			qryenvList[i] = envList[j];
                        }

                        qryCount += nb_queries;

			_FREE( qryDump );
			qryDump = NULL ;

		} /* for(j < NbOs) */
	} /* if */
     
        /* make sure object list is unique */
        if ( qryCount ) { 

        	qryenvListUnq = _MALLOC(qryCount ,struct GRmd_env);
        	qryListUnq = _MALLOC( qryCount, struct GRid); 

                qryenvListUnq[0] = qryenvList[0];
                qryListUnq[0]    = qryList[0];
                NoOfUniq = 1;
                
                for( ii = 1; ii < qryCount; ii++) {

                   found = FALSE;

                   for ( jj = 0; jj< NoOfUniq; jj++) {
                        
                        if( qryList[ii].osnum == qryListUnq[jj].osnum &&
                            qryList[ii].objid == qryListUnq[jj].objid ) 
                        {
                           found = TRUE;
                           break;
                        } 
                   }      
                   if( !found) {
                       qryenvListUnq[NoOfUniq] = qryenvList[ii];
                       qryListUnq[NoOfUniq]    = qryList[ii];
                       NoOfUniq++;
                   } 
                }
           }
           qryCount = NoOfUniq;

         for( i=0 ; i<qryCount ; i++ ){
                /*
                 * test object class .
                 */
                om$get_classname(       osnum   = qryListUnq[i].osnum,
                                        objid   = qryListUnq[i].objid,
                                        classname = classname );
                if( om$is_ancestry_valid(
			subclassname   = classname,
			superclassname = VD_QRY_Classname ) != OM_S_SUCCESS ){
                        /*
                         * inproper class.
                         */
                        continue;
                }

		if( list ){
                	list[*count].objid = qryListUnq[i].objid ;
             		list[*count].osnum = qryListUnq[i].osnum ;
		}

		if( md_env_list ){
                	md_env_list[*count] = qryenvListUnq[i] ;
		}

		(*count) ++ ;

		if( list && ( *count >= list_size ))
			break;
        }

        /*
         * free allocated memory.
         */
        _FREE( qryList ); 
        _FREE( qryenvList ); 
        _FREE( qryDump );
        _FREE( osList );
        _FREE( envList );
        _FREE( qryListUnq ); 
        _FREE( qryenvListUnq ); 

        End
        return TRUE;

}/* VDqry_give_list */

/***********************************************************************
Function:

    VDqry_name_to_objid

Description:

    This function return the object id and names of queries.

Return Status

    status      = TRUE ;         get object id
    status      = FALSE;         otherwise

*/

VDqry_name_to_objid( msg, name, object )
IGRlong                 *msg;                   /* out */
IGRchar                 *name;                  /* in */
struct  GRid            *object;                /* out */
{
IGRint                  count;
IGRint                  i, ii,
                        sts1,
                        directIndex = 0;
GRname                  gvName;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;
struct GRid             *list_objid;             /* out */
IGRint                  status;

        SetProc( VDqry_give_name_objid ); Begin

        *msg = MSSUCC ;
        list_objid      = NULL;

        /*
         * check the input
         */

        if( ! object ) goto wrapup; 

        if( ! name || strlen( name ) == 0 ) goto wrapup;

        object->objid = NULL_OBJID ;

        /*
         * find the existing query objects.
         */

        vd$qry_get_id_list(     msg     = msg,
                                count   = &count );

        list_objid = _MALLOC(count, struct GRid );
        status =
        vd$qry_get_id_list(     msg             = msg,
                                list_size       = count,
                                list            = list_objid,
                                count           = &count);

        ii=0;
        strcpy( gvName, VD_qry_nmName );

        for( i=0 ; i< count ; i++ ){

                status =
		om$send(msg = message ACncpx.ACgive_structure (
                                                &sts1,
                                                &directIndex,
                                                gvName,
                                                &retStr,
                                                &mdEnv ),
                        mode     = OM_e_wrt_message,
                        senderid = NULL_OBJID,
                        targetid = list_objid[i].objid,
                        targetos = list_objid[i].osnum );

                if(! ( status & sts1 & 1 ))     continue;

                /*
                 * compare the name within the list.
                 */

                if( strcmp( name, retStr.var.text_st.text_string ) == 0 ){
                        object->objid = list_objid[i].objid ;
                        object->osnum = list_objid[i].osnum ;
                        break;
                }

        } /* for */

        if( i >= count )        goto wrapup;

        _FREE( list_objid );

        *msg = MSSUCC;
        End
        return OM_S_SUCCESS ;

wrapup:

        _FREE( list_objid );
        *msg = MSFAIL;

        End
        return OM_S_SUCCESS ;

} /* VDqry_give_name_objid */

/***********************************************************************
Function:

    VDqry_process

Description:

    This function return list of objects which match with the query 
    and list number.

Return Status

    status      = TRUE ;         get object list

    status      = FALSE;         otherwise

*/

VDqry_process( sts, objects, nb_objects, queries, nb_queries, found, nb_found )
IGRlong		        *sts;			 /* O */	
struct  GRobj_env       *objects;                /* I */
IGRint		        nb_objects;              /* I */
struct  GRid            *queries;                /* I */
IGRint		        nb_queries;              /* I */
struct  GRobj_env       **found;                 /* O */
IGRint		        *nb_found;               /* O */
{
IGRchar                 *pSelect,
                        *pWhere,
                        buffer[8*QUERY_LEN];
IGRint			i,status,flag;
IGRlong			msg;	
IGRint			nbTemp; 
struct  GRobj_env       *Temp ;


	SetProc( VDqry_process ); Begin 

        msg  = OM_S_SUCCESS ;
        *sts = MSSUCC ;

	status = FALSE;  // In case of early failure

	/*
	 * Checking arguments.
	 */
	Temp = NULL ;
	nbTemp = 0 ;

	if( ! objects || nb_objects == 0 ){
		/*
		 * Nothing to check.
		 */
		goto wrapup ;
	}
		
        flag = 1;
        if( ! (Temp = _MALLOC( nb_objects, struct GRobj_env )) )
		goto wrapup;
	

	for( i=0 ; i<nb_queries ; i++ ){

            pSelect = NULL;
            pWhere  = NULL;
            buffer[0] = '\0';

            /* get query string from queru id */
            status =
            om$send(msg = message VDquery.VDgive_query( sts,
                                                        &pSelect,
                                                        &pWhere,
                                                        NULL ),
                                targetid = queries[i].objid,
                                targetos = queries[i].osnum,
                                senderid = NULL_OBJID );

            if( (status & *sts & 1) && pSelect ){

              strcat( buffer, pSelect );
              strcat( buffer, " ");
              if( pWhere ) strcat( buffer, pWhere );
              strcat( buffer, ";" );
            }

	    _FREE( pSelect );
	    _FREE( pWhere  );

      	    vd$qry_get_mul_objects(sts        = sts, 
			   	   objects    = objects, 
                                   nb_objects = nb_objects, 
                                   query      = buffer, 
                                   found      = Temp, 
                                   nb_found   = &nbTemp); 
	} /* for (i) */
	
        if( found )	*found = NULL ;

	if( nbTemp ){

		*nb_found = nbTemp;
		__DBGpr_int(" nbTemp ", nbTemp );
        
		/*
		 * Check if we need to give the objects back.
		 */
		if( found ){
			*found = Temp ;
			Temp   = NULL ;
		}
	}

	wrapup:

		_FREE( Temp );
		End
		return status;

} /* VDqry_process */

/***********************************************************************
Function:

    VDqry_get_mul_objects

Description:

    This function check list of objects with a query

Return Status

    status      = TRUE ;         get object list
    status      = FALSE;         otherwise

*************************************************************************/
VDqry_get_mul_objects( sts, objects, nb_objects, query, found, num )
IGRlong                 *sts;                    /* O */
struct  GRobj_env       *objects;                /* I */
IGRint                  nb_objects;              /* I */
IGRchar                 *query;                  /* I */
struct  GRobj_env       *found;                  /* O */
IGRint                  *num;                    /* I/O */
{
IGRint                  j,k,status,flag,i;
IGRint                  syntax1;

IGRchar                 **query_class_name = NULL;
IGRint                  cl_count;
OM_S_CHANSELECT         MyChannelStruct;
char                    class_name[80], mac_name[80];
char                    tmp_name [80];
struct GRid             tmp_grid;

        SetProc( VDqry_chk_mul_objects ); Begin
        
	*sts = MSSUCC;
        status = FALSE;

        syntax1 = 0;
        for ( j = 0; j < nb_objects; j++ ) {
            flag = 1;
            status =
            VDDIprocess_query (
                                query,
                                &objects[j].obj_id.osnum,
                                &objects[j].obj_id.objid,
                                &objects[j].mod_env,
                                syntax1);

            if(status) {
              
              /* get class name or macro name from query */

              cl_count = 0;
              query_class_name = NULL;

              VDmalloc_str_list(&query_class_name, Qrynamenum, Qrynamelen);

              VDQYget_query_names(&query_class_name, &cl_count);

              /*
               * get the class and macro of the object
              */
              class_name[0] = '\0';
              tmp_name[0]   = '\0';
              mac_name[0] = '\0';

              /* get the class of the object */
              status =
              om$get_classname( classname = class_name,
                                objid = objects[j].obj_id.objid,
                                osnum = objects[j].obj_id.osnum  );

              /*
               * if element's superclass_name
               * is ACcpx, go to find macro id and pathnames
               * then split it into macro names
               * if classname = "ACdiowner" , make channel and
               * get macro_names.
               */

              if( vd_$is_ancestry_valid(object  = &objects[j].obj_id,
                                        classid = OPP_ACcpx_class_id )){

                   __DBGpr_com(" object blong to ACcpx ");

                   VD_drwGetACcpxInfo(  &objects[j].obj_id,
                                        mac_name, TRUE );
                   __DBGpr_obj(" xxxxxxxxxxxx object ", objects[j].obj_id);
                   __DBGpr_str(" macro name", mac_name);

              } /* vd_$is_ancestry_valid */
              else{
                /*
                 * if object is ACdiowner, then get the GO (graphic object ?)
                 */
                if( !( strcmp( class_name, "ACdiowner" ) ) ){

                  /*
                   * make channel connection to GO
                   */
                  status =
                  om$make_chanselect( channame = "GRcmpowner.to_components",
                                      p_chanselect = &MyChannelStruct );

                  /*
                   * get the actual GO connected to the ACdiowner
                   */
                  status =
                  om$get_objid_at_index(
                                objid = objects[j].obj_id.objid,
                                osnum = objects[j].obj_id.osnum,
                                p_chanselect = &MyChannelStruct,
                                index = 0,
                                objidaddr = &tmp_grid.objid,
                                osnumaddr = &tmp_grid.osnum );

                  /*
                   * get the class of the GO
                   */
                  status =
                  om$get_classname(classname = mac_name,
                                   objid = tmp_grid.objid,
                                   osnum = tmp_grid.osnum  );
                }
              } /* else .. vd_$is_ancestry_valid */

              /*
               * Compare the Names ...
               */
              if( mac_name[0] != '\0' ) {
                status = 0;
                for( i=0; i<cl_count; i++ ){
                  if( VDQYis_subclas(mac_name, query_class_name[i]) ||
                     VDQYis_subclas(class_name, query_class_name[i])||
                      VD_matchRE(query_class_name[i],class_name) ||
                      VD_matchRE(query_class_name[i],mac_name) ) {

                    status = 1;
                    break;
                  }
                }
              }
              else if(    mac_name[0] == '\0'     ||
                        status != OM_S_SUCCESS ){

                 status = 0;
                 for ( i = 0; i < cl_count; i++) {
                   if( VDQYis_subclas(class_name, query_class_name[i])||
                       VD_matchRE(query_class_name[i],class_name) ) {

                     status = 1;
                     break;
                   }
                 }
               }
               if ( !status && query_class_name != NULL ) {   
                                    /* special case for piping */
              
                 class_name[0]  = '\0';

                 status = 0;

                 for ( i = 0; i < cl_count; i++) {
                    if( !(strcmp( class_name, "VRPCorentity")) &&
                        !(strcmp(query_class_name[i], "PPccdef"))) {
                        status = 1;
                        break;
                    }
                    else if (
                        !(strcmp( class_name, "VRHCorentity")) &&
                        !(strcmp(query_class_name[i], "HVccdef"))) {
                        status = 1;
                        break;
                    }
                    else if (
                        !(strcmp( class_name, "VRRCorentity")) &&
                        !(strcmp(query_class_name[i], "RWccdef"))) {
                        status = 1;
                        break;
                    }
                  }
                 } /* if (!satatus ) */
               } /* if (satatus ) */
               /*
                * free the memory.
                */

               VDfree_str_list(query_class_name, Qrynamenum);
               query_class_name = NULL;
 
               if (status) {
#ifdef DEBUG
            printf(" j = : %d\n", j);
            printf(" macr_name: %s\n", mac_name);
            printf(" class name: %s\n", class_name);
            printf(" objectid: %d\n", object_list[j].obj_id.objid);
            printf(" objectosnum: %d\n", object_list[j].obj_id.osnum);
#endif
                for( k = 0; k < *num; k++) {
                      if((objects[j].obj_id.osnum == found[k].obj_id.osnum)
                        && (objects[j].obj_id.objid == found[k].obj_id.objid)) 
                      {
                        flag = 0;
                        break;
                      }
                }
                if( flag ){
			found[*num] = objects[j];
                        (*num) ++;
                }
               }
	} /* for (j) */

        /*
         * free the memory.
         */

        VDfree_str_list(query_class_name, Qrynamenum);


        if( (*num) > 0 ) status = 1;

        End
    	return status;

} /* VDqry_get_mul_objects */
/***********************************************************************
Function:

    VDqry_chk_one_object

Description:

    This function try to find if there is any object matching with query

Return Status

    status      = TRUE ;         get object list
    status      = FALSE;         otherwise

*/
VDqry_chk_one_object( sts, objects, nb_objects, query, found)
IGRlong                 *sts;                    /* O */
struct  GRid            *objects;                /* I */
IGRint                  nb_objects;              /* I */
IGRchar                 *query;                  /* I */
struct  GRid            *found;                  /* O */
{
IGRint                  j,status;
IGRlong                 size;
struct GRmd_env         objectInfo;
IGRint                  syntax1;

        SetProc( VDqry_chk_one_object ); Begin

        *sts = MSSUCC;
        status      = TRUE ;         

        /* get object env */
        size = sizeof( objectInfo );
        gr$get_module_env( msg = sts,
                     sizbuf = &size,
                     buffer = &objectInfo,
                     nret = &size );
        syntax1 = 0;
        for ( j = 0; j < nb_objects; j++ ) {

                status =
                VDDIprocess_query (
                                query,
                                &objects[j].osnum,
                                &objects[j].objid,
                                &objectInfo,
                                &syntax1);

                if(status) {
                        found[0].osnum = objects[j].osnum;
                        found[0].objid = objects[j].objid;
                        break;
                }
        } /* for (j) */
        
        End 
        return status;
} /* VDqry_chk_one_object */


/*--------------------------------------------------------------------------
Function:

                VDqry_get_macro_names

Description:
   This function returns the valid macros of the current design file.

Return Status

    status      = OM_S_SUCCESS ;         get macro name
    status      = OM_E_ABORT;            otherwise

HISTORY :
   -------
        02/07/95        yzhu            Create.

------------------------------------------------------------------------*/
int VDqry_get_macro_names ( sts, macronames, count )
long *sts                       /* out code                     out */;
char **macronames       	/* The macro names              out */;
int  *count         		/* The number of macros      in/out */;
{
  OM_S_CLASSLIST     class_list;
  int                i, status;
  OMuword            macro_def_clid;
  char               **macro_names = NULL;
  struct GRmd_env    md_env;
  IGRlong            msg, NumberOfBytes, BytesReceived;
  int         	     nb_macros = 0;
  IGRchar            regexp[DI_PATH_MAX];
  int                len;

        SetProc( VDqry_get_macro_names ); Begin
        *sts = MSSUCC;   

        /* get the list of valid macros */
        class_list.w_flags = OM_CLST_subclass;
        class_list.w_count = 1;
        status = om$get_classid ( classname = "ACcpx_defn",
                                  p_classid = &macro_def_clid );
	if (status != OM_S_SUCCESS)  return status;

        class_list.p_classes = &macro_def_clid;

        NumberOfBytes = sizeof(md_env);
        gr$get_module_env( msg    = &msg,
                           sizbuf = &NumberOfBytes,
                    	   buffer = &md_env,
                           nret   = &BytesReceived);
        if(!(msg&1)) return OM_E_ABORT;

        status = di$give_pathname(      pathname = regexp,
                                	osnum = md_env.md_id.osnum);
        if (status != 1) return status;

        strcat(regexp,":constructs_lib:*:constructs:*");

        if( !(*count) ) {
            	status =
        	di$dump ( regexp = regexp,
                  	  ptr = &nb_macros,
                  	  options = 0 );
                if (status != OM_S_SUCCESS) return status;
                *count = nb_macros;
        }
        else {
                status =
        	di$dump ( regexp = regexp,
                	  lines = &macro_names,
                    	  ptr = &nb_macros,
                          p_classes = &class_list,
                          options = 0 );
                if (status != OM_S_SUCCESS) return status;
       
                for (i = 0; i < nb_macros; i++)
                di$split ( pathname = macro_names [i],
                   	   name     = macro_names [i] );

                for (i = 0; i < nb_macros; i++) {
                     len =  strlen(macro_names[i]); 
                     strncpy(macronames[i],macro_names[i],len);
                }
               
                
  		/* free the macro_names which is allocate in di$dump*/
  		if (macro_names) {
      			for (i = 0; i < nb_macros; i++) {
                           _FREE( macro_names [i] );
                        }
    			_FREE ( macro_names );
  		}
 

        }  
        
        End
        return OM_S_SUCCESS;
} /* VDqry_get_macro_name */

end implementation Root;

