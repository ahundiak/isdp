/* $Id: VDQYnptfrm.I,v 1.2 2002/01/18 15:24:10 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/cmd / VDQYnptfrm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDQYnptfrm.I,v $
 *	Revision 1.2  2002/01/18 15:24:10  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/12/17  15:34:42  pinnacle
# VDS 2.4.1: TR 179603860, CREATE QUERY CRITERIA, misspelling of "overwritten" corrected
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.35  1996/05/24  08:45:40  pinnacle
# Replaced: vdpocket/cmd/VDQYnptfrm.I for:  by apazhani for vds.240
#
# Revision 1.34  1996/04/29  22:37:20  pinnacle
# Replaced: vdpocket/cmd/VDQYnptfrm.I for:  by yzhu for vds.240
#
# Revision 1.33  1996/02/08  17:37:24  pinnacle
# Replaced: vdpocket/cmd/VDQYnptfrm.I for:  by yzhu for vds.240
#
# Revision 1.32  1996/01/11  20:39:52  pinnacle
# Replaced: vdpocket/cmd/VDQYnptfrm.I for:  by yzhu for vds.240
#
# Revision 1.30  1995/09/04  21:35:44  pinnacle
# Replaced: vdpocket/cmd/VDQYnptfrm.I for:  by yzhu for vds.240
#
# Revision 1.28  1995/08/10  13:13:00  pinnacle
# Replaced: vdpocket/cmd/VDQYnptfrm.I for:  by yzhu for vds.240
#
# Revision 1.27  1995/07/24  19:00:52  pinnacle
# Replaced: vdpocket/cmd/VDQYnptfrm.I for:  by hverstee for vds.240
#
# Revision 1.26  1995/05/09  19:17:44  pinnacle
# Replace: vdpocket/cmd/VDQYnptfrm.I by yzhu for OPE
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *      01/09/96        yzhu    TR17960019: 
 *                              include file name with query name
 *                              in select query and create query.
 *                              can't duplicate query name in design i
 *                              file. only can edit query in design 
 *                              file. edited query in ref file will
 *                              copy to design file if name not 
 *                              duplacated.
 *      02/02/96        yzhu    TR179600368 
 *      12/05/96	ejm	TR179603860: CREATE QUERY CRITERIA
 *				If user edits an existing query, the message
 *				is Query -name- is overwrited. Needs to say
 *				overwritten.
 *
 *				Corrected the misspelling of the word,
 *				"overwritten"; was "overwrited"
 *	01/18/02	ylong	CR5979
 * -------------------------------------------------------------------*/

class implementation VDCmdQYnpt;

#include <stdio.h>
#include <memory.h>
#include <malloc.h>
#include <string.h>
#ifndef NT
#include <sys/param.h>
#else
#include <stdlib.h>  
#define MAXPATHLEN _MAX_PATH
#endif
                       
#include <coimport.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "vdsmacros.h"
#include "parametric.h"
#include "VDQYdef.h"
#include "vdqrydef.h"
#include "AS_status.h" 
#include "DIomac.h"
#include "vdparmacros.h"
#include "dpmacros.h"
#include "vdcollmacros.h"
#include "vdcolldef.h"
#include "ACrg_collect.h"
#include "ACattrib.h"

#include "VDmsg.h"
#include "SMmsg.h"
#include "expriv.h"
#include "bsmalloc.h"
#include "VDmem.h"
#include "v_dbgmacros.h"

/* #define DEBUG	1  */ 

%safe
static int			nb_elt = 0;
static int			coll_nb = 0;
static int			def_state = 0;
static struct ElemType		*elements = NULL;
static char      		**AttrNameList = NULL;
static char      		**AttrTextList = NULL;
static IGRchar         		VDQYnpt_query_list[8*4096] = { 0 };
%endsafe

from	ACmacro_defn	import	ACgive_feet_desc;
from	NDmacro		import	ACgive_structure;
from    ACrg_collect    import  NDdelete;
from	GRgraphics	import	GRgetname;
from	VDquery		import	VDname_query, VDgive_query;

/*-----------------------------------------------------------------------*/
int my_strcmpQrylist( elm1,elm2) 
struct Qry_list *elm1, *elm2; 
{
     return( strcmp( elm1->name, elm2->name ));
}

int my_strcmp ( p_st1, p_st2 )
char **p_st1, **p_st2;
{
        return strcmp ( *p_st1, *p_st2 );
}


VDqry_set_text(	form_ptr, gadget, text )
Form			form_ptr;
IGRint			gadget;
IGRchar			*text;
{
IGRint			i, num ;
IGRchar			select[QUERY_LEN];
IGRchar			where[QUERY_LEN];

        SetProc( VDqry_set_text ); Begin
	/*
	 * split the buffer.
	 */
        if( VDqry_splt_string( text, select, where ) ){

                FIfld_get_num_rows(     form_ptr, gadget, &num );
                for( i=0 ; i<num ; i++ ){
                        FIfld_set_text( form_ptr, gadget, i, 0, "", FALSE );
                }

                /*
                 * fill in the new text.
                 */
		i=0;
                FIfld_set_text( form_ptr, gadget, i++, 0, select, FALSE);
                FIfld_set_text( form_ptr, gadget, i++, 0, where, FALSE );
        }

        End
	return	TRUE ;
}


VDqry_get_text(   form_ptr, gadget, text )
Form                    form_ptr;
IGRint                  gadget;
IGRchar                 *text;
{
IGRint                  i,
			sel,
			pos,
                        num = 0 ;
IGRchar                 buffer[QUERY_LEN];

        SetProc( VDqry_set_text ); Begin
        text[0] = '\0';
	buffer[0] = '\0';

        FIfld_get_num_rows(     form_ptr, gadget, &num );

        for( i=0 ; i<num ; i++ ){
                FIfld_get_text( form_ptr, gadget, i, 0,
                                QUERY_LEN, buffer, &sel, &pos);

                if( strlen( text ) + strlen( buffer ) > QUERY_LEN ){
                        /*
                         * query buffer is to small.
                         */
			text[0] = '\0';
                        return FALSE;
                }

                strcat( text, buffer );
                strcat( text, " " );
        }
        End
	return TRUE ;
}


VDQYclear_list (fp, label)
    Form fp;
    int  label;
{
    int num, i, sel, mode, attr;

    SetProc( VDQYclear_list ); Begin
    FIfld_get_attr (fp, label, 0, &attr);

    if (attr & FI_POPUP_ASSO_LIST)
    {
        FIfld_set_text (fp, label, 0, 0, "", FALSE);
    }
    else
    {
        FIfld_get_mode (fp, label, 0, &mode);
        FIfld_get_num_rows (fp, label, &num);
        for (i=0; i<num; ++i)
        {
            FIfld_get_select (fp, label, i, 0, &sel);
            if (sel)
            {
                FIfld_set_select (fp, label, i, 0, FALSE);
                if (mode == FI_SINGLE_SELECT) break;
            }
        }
    }
    End
    return TRUE;
}

int VDQYis_string_on_list (fp, label, s)
    Form   fp;
    int    label;
    char * s;
{
    int  i, num, sel, pos;
    char text[QUERY_LEN];

    SetProc( VDQYis_string_on_list ); Begin
    FIfld_get_num_rows (fp, label, &num);
    for (i=0; i<num; ++i)
    {
        FIfld_get_text (fp, label, i, 0, QUERY_LEN, text, &sel, &pos);

        if (!strcmp(text, s)) return(1);
    }

    End
    return (0);
}

/******************************************************************************

Method:
    
    switch_query_state

Description:

    This method switches the form between states (display prompts, update lists
    enable gadgets ...)

    History

    jay wallingford     04/16/91    creation date

******************************************************************************/

#define		QRY_GRP_MACRO		69
#define		QRY_GRP_WHERE		65
#define		QRY_GRP_ATTR		66
#define		QRY_GRP_COND		67
#define		QRY_GRP_VALUE		68
#define		QRY_GRP_CONJ		80


method switch_query_state (int state; int reset)
{
Form			fp;
IGRchar			prompt[MS_MAX_MSG_LENGTH];

        SetProc( VDCmdQYnpt.switch_query_state ); Begin
	/*
	 * initialization values.
	 */
	fp = me->forms[0].form_ptr ;

	/*
	 * test on the state to give messages.
	 */

	switch (state)
	{
	case MACRO:

		/*
		 * Select macro(s) to search
		 */
/*		FIg_enable( fp, QRY_GRP_MACRO ); */
		FIg_enable( fp, MACRO_LIST ); 
		FIg_enable( fp, MACRO_FIELD); 
		FIg_enable( fp, EDIT_QRY_TOGGLE); 
		FIg_disable(fp, QRY_GRP_WHERE );
		FIg_disable(fp, QRY_GRP_ATTR );
		FIg_disable(fp, ATTR_SYMB_TOGGLE);
		FIg_disable(fp, QRY_GRP_COND );
		FIg_disable(fp, QRY_GRP_VALUE );
		FIg_disable(fp, QRY_GRP_CONJ );
		FIg_disable(fp, FI_EXECUTE );
		FIg_disable(fp, FI_ACCEPT );
		FIg_enable( fp, LOCATE_OBJECT);

		ex$message(msgnumb = GR_P_SelMacSrch, buff = prompt);
		break;

	case WHEREG:
	
		/* 
		 * Execute query, select additional macro(s),
		 * or initiate condition clause
		 */
 
/*		FIg_enable( fp, QRY_GRP_MACRO ); */
                if (me->macro_list == FALSE) {
		    FIg_enable(fp, QRY_GRP_WHERE );
		    FIg_disable(fp, MACRO_LIST );
                }
                else if (def_state != 1) {
		    FIg_disable(fp, QRY_GRP_WHERE );
		    FIg_disable(fp, MACRO_FIELD );
		    FIg_disable(fp, MACRO_LIST );
                }
                else {
		    FIg_enable(fp, QRY_GRP_WHERE );
		    FIg_disable(fp, MACRO_LIST );
		    FIg_disable(fp, MACRO_FIELD );
                }
		FIg_disable(fp, QRY_GRP_ATTR );
 		FIg_disable(fp, ATTR_SYMB_TOGGLE);
		FIg_disable(fp, QRY_GRP_COND );
		FIg_disable(fp, QRY_GRP_VALUE );
		FIg_disable(fp, QRY_GRP_CONJ );
		FIg_enable(fp, FI_EXECUTE );
		FIg_enable(fp, FI_ACCEPT );
		FIg_disable(fp, LOCATE_OBJECT);
		FIg_disable( fp, EDIT_QRY_TOGGLE); 

		ex$message(msgnumb = GR_P_ExeQuery, buff = prompt);
		break;

	case ATTRIBUTE:

		/*
		 * Select attribute
		 */
		FIg_disable(fp, MACRO_LIST );
		FIg_disable(fp, MACRO_FIELD );
/*		FIg_disable( fp, QRY_GRP_MACRO );    */
		FIg_disable(fp, QRY_GRP_WHERE );
		FIg_enable(fp, QRY_GRP_ATTR );
 		FIg_enable(fp, ATTR_SYMB_TOGGLE);
		FIg_disable(fp, QRY_GRP_COND );
		FIg_disable(fp, QRY_GRP_VALUE );
		FIg_disable(fp, QRY_GRP_CONJ );
		FIg_disable(fp, FI_EXECUTE );
		FIg_disable(fp, FI_ACCEPT );
		FIg_disable( fp, EDIT_QRY_TOGGLE); 

		ex$message(msgnumb = GR_P_SelAttr, buff = prompt);
	/*	ex$message(msgnumb = VD_P_QrySelAttr, buff = prompt); */
		break;

	case CONDITION:

		/*
		 * Select conditional operator
		 */

		FIg_disable(fp, MACRO_LIST );
		FIg_disable(fp, MACRO_FIELD );
/*		FIg_disable( fp, QRY_GRP_MACRO );    */
		FIg_disable(fp, QRY_GRP_WHERE );
		FIg_disable(fp, QRY_GRP_WHERE );
 		FIg_disable(fp, ATTR_SYMB_TOGGLE);
		FIg_disable(fp, QRY_GRP_ATTR );
		FIg_enable(fp, QRY_GRP_COND );
		FIg_disable(fp, QRY_GRP_VALUE );
		FIg_disable(fp, QRY_GRP_CONJ );
		FIg_disable(fp, FI_EXECUTE );
		FIg_disable(fp, FI_ACCEPT );
		FIg_disable( fp, EDIT_QRY_TOGGLE); 

		ex$message(msgnumb = GR_P_SelCondOperator, buff = prompt);
	/*	ex$message(msgnumb = VD_P_QrySelCondOper, buff = prompt); */
		break;

	case VALUE1:

		/*
		 * Key-in comparision value
		 */
		FIg_disable(fp, MACRO_LIST );
		FIg_disable(fp, MACRO_FIELD );
/*		FIg_disable( fp, QRY_GRP_MACRO );    */
		FIg_disable(fp, QRY_GRP_WHERE );
 		FIg_disable(fp, ATTR_SYMB_TOGGLE);
		FIg_disable(fp, QRY_GRP_ATTR );
		FIg_disable(fp, QRY_GRP_COND );
		FIg_enable(fp, QRY_GRP_VALUE );
		FIg_disable(fp, QRY_GRP_CONJ );
		FIg_disable(fp, FI_EXECUTE );
		FIg_disable(fp, FI_ACCEPT );
		FIg_disable( fp, EDIT_QRY_TOGGLE); 

		ex$message(msgnumb = GR_P_KeyinCompVal, buff = prompt);
	/*	ex$message(msgnumb = VD_P_QryKeyinCompVal, buff = prompt); */
		break;

	case CONJUNCTION:

		/*
		 * Execute query or select conjunction operator
		 */
		FIg_disable(fp, MACRO_LIST );
		FIg_disable(fp, MACRO_FIELD );
/*		FIg_disable( fp, QRY_GRP_MACRO );    */
		FIg_disable(fp, QRY_GRP_WHERE );
		FIg_disable(fp, QRY_GRP_ATTR );
                FIg_disable(fp, ATTR_SYMB_TOGGLE);
		FIg_disable(fp, QRY_GRP_COND );
		FIg_disable(fp, QRY_GRP_VALUE );
		FIg_enable(fp, QRY_GRP_CONJ );
		FIg_enable(fp, FI_EXECUTE );
		FIg_enable(fp, FI_ACCEPT );
		FIg_disable( fp, EDIT_QRY_TOGGLE); 

		ex$message(msgnumb = GR_P_ExeOrSel, buff = prompt);
	/*	ex$message(msgnumb = VD_P_QryExeOrSel, buff = prompt); */
		break;
	}

	FIfld_set_text (fp, MESSAGE, 0, 0, prompt, FALSE);

        End
	return OM_S_SUCCESS;
}

/******************************************************************************

Method:
    
    add_to_query

Description:

    This method adds a string to the end of a query.

History:

    jay wallingford     04/16/91    creation date

******************************************************************************/

method add_to_query (int label)
{
Form    		fp;
int     		state;
int  			sel, pos;
char 			query[QUERY_LEN],
			text[QUERY_LEN],
			buffer[QUERY_LEN];
    SetProc( VDCmdQYnpt.add_to_query ); Begin
    /* Init some variables */
    fp = me->forms[0].form_ptr;
    state = me->query_state;
    text[0] = '\0';

    switch (state)
    {
    case WHEREG:

        strcat(text, (label == WHERE_CHECK) ? "where" : "where!");
	
        break;

    case ATTRIBUTE:

        strcat(text, "(");
        FIfld_get_text (fp, ATTRIBUTE_FIELD, 0, 0, QUERY_LEN, buffer,&sel,&pos);
        strcat(text, buffer);
/*        strcat(text, "");   */
        break;

    case CONDITION:

        strcat(text, (label == NE) ? "!=" :
                     (label == EQ) ? "="  :
                     (label == GE) ? ">=" :
                     (label == LE) ? "<=" :
                     (label == GT) ? ">"  :
                                     "<" );
        break;

    case VALUE1:

        FIfld_get_text (fp, VALUE_FIELD, 0, 0, QUERY_LEN, buffer, &sel, & pos);
        strcat (text, buffer);
        strcat (text, ")");
        break;

    case CONJUNCTION:

        strcat(text, (label == AND_CHECK)     ? "&"  :
                     (label == AND_NOT_CHECK) ? "&!" :
                     (label == OR_CHECK)      ? "|"  :
		     (label == XOR_CHECK)     ? "@"  :
						"|!");
        break;
    }

    VDqry_get_text( fp, QUERY, query );

    if (me->num_query_offsets > om$dimension_of(varray = me->query_offsets))
    {
        om$vla_set_dimension (varray = me->query_offsets,
                              size = me->num_query_offsets + 10);
    }

    me->query_offsets[me->num_query_offsets++] = strlen(query);

    strcat (query, text);

    VDqry_set_text ( fp, QUERY, query );    

    End
    return OM_S_SUCCESS;
}
    
/******************************************************************************

Method:
    
    back_up_query

Description:

    This method backs up a query to the previous state.

History:

    jay wallingford     04/16/91    creation date

******************************************************************************/

method back_up_query ()
{
IGRint			status = OM_S_SUCCESS ;
Form			fp;
IGRint			state,
			sel,
			num,
			pos,
			num_offsets,
			reset = TRUE;
IGRchar			query[QUERY_LEN],
			text[QUERY_LEN];

	SetProc( VDCmdQYnpt.back_up_query ); Begin
	/*
	 * Init some variables
	 */

	fp = me->forms[0].form_ptr;
	state = me->query_state;
	num_offsets = me->num_query_offsets;

	if( state != MACRO ){
		if( (state == ATTRIBUTE) && (num_offsets != 1) ){
			state = CONJUNCTION;
		}
		else	--state;

		if( state == WHEREG )	reset = FALSE;
	}

    
	if( num_offsets ){

		VDqry_get_text ( fp, QUERY, query );
		query[me->query_offsets[me->num_query_offsets = --num_offsets]] = '\0';
		VDqry_set_text ( fp, QUERY, query );
	}

	if( (state == WHEREG) || (state == MACRO) ){
		if( state == MACRO ){
			strcpy( query, "select " );
			VDqry_set_text ( fp, QUERY, query );
                FIfld_set_text (fp, MACRO_FIELD, 0, 0, "", FALSE);

                status =
                om$vla_set_dimension(  varray =  me->VDslist,
                                size   =  0);

		}

		FIg_reset (fp, ATTRIBUTE_LIST);
		FIg_reset (fp, ATTRIBUTE_FIELD);
/*		FIg_set_state( fp, ATTR_SYMB_TOGGLE, FALSE ); */
		FIg_set_state( fp, ATTR_SYMB_TOGGLE, TRUE ); 

		FIg_reset (fp, VALUE_FIELD);
		FIg_reset (fp, VALUE_LIST);

	}

	if( state == VALUE1 ){
		text[0] = '\0';
		FIfld_get_num_rows(	fp, VALUE_LIST, &num);
		if( num )
			FIfld_get_text(	fp, VALUE_LIST, 0, 0, QUERY_LEN, 
					text, &sel, &pos);

		if( text[0] == '\0' ){
			FIg_reset (fp, VALUE_FIELD);
        		FIfld_pos_cursor (fp, VALUE_FIELD, 0, 0, 0, 0, 0, 0);
		}

	}

	status =
	om$send(msg = message VDCmdQYnpt.switch_query_state 
                                (me->query_state = state, reset),
		targetid = my_id );

        End        
	return OM_S_SUCCESS ;
}


/* ------------------------------------------------------------------------ */
void PrintAtt(elem)
struct AttrDef	*elem;
{
int	i;

	printf("\n\t name   : %s\n",elem->name);
	printf("\t nb_value : %d\n",elem->nb_value);
	for(i=0;i<elem->nb_value;i++) 
		printf("\t\t val: %s\n",elem->value[i]);
}

/* ------------------------------------------------------------------------ */

void PrintElem(elem)
struct ElemType	*elem;
{
int	i;

	printf("\n\nElement ------------------- \n\n");
	printf("\t selected  : %d\n",elem->selected);
	printf("\t user_name : %s\n",elem->user_name);
	printf("\t real_name : %s\n",elem->real_name);
	printf("\t nb_att    : %d\n",elem->nb_att);
	for(i=0;i<elem->nb_att;i++) PrintAtt(&elem->att[i]);

	printf("\n ---------------------------- \n\n");
}


/******************************************************************************

Function:
    
    IsElemInMacroList

Description:

    This function look for the given text in the list of the element and
    returns its index if it found.


******************************************************************************/

int IsElemInMacroList(text, index)
IGRchar		*text;
IGRint		*index;
{
int	i;

	*index = -1;
	if( elements == NULL ) return 0;

	for( i=0 ; i<nb_elt ; i++ )
	  if(strcmp(text,elements[i].user_name) == 0){
		*index = i;
		return (1);
	  }

	return 0;
}
/* ------------------------------------------------------------------------ */
int IsElemInAttList(text, mac_index, att_index)
IGRchar		*text;
IGRint		mac_index;
IGRint		*att_index;
{
int	i;

	*att_index = -1;

	for( i=0 ; i<elements[mac_index].nb_att ; i++ )
	  if(strcmp(text,elements[mac_index].att[i].name) == 0) {
		*att_index = i; 
		return (1);
	  }

	return 0;
}



/******************************************************************************

Function:
    
    VDQYget_feet

Description:

    This function returns the feet of all the given macros.

    If the macro name is in the elements list, its feet are taken from that
    list.
    Otherwise, we search for the macro definition in the directory subsystem
    (di$dump in "file:construct_lib:*:constructs:macroname* restricted to the 
     ACcpx_defn elements) and send a ACgive_feet_desc to get the feetnames.

Notes: In the second case, the result is dependant of the way the macro
definition are stored in the directory subsytem. If ever the macrodef would
be stored in another location, this function would need to be revised 
according to it.


******************************************************************************/



VDQYget_feet ( feet_names, count, names, mac_count )
IGRchar		***feet_names;	/* The feet				OUT */
IGRint		*count;		/* The number of feet			OUT */
IGRchar		**names;	/* The macro names (or classname)       IN  */
IGRint		mac_count;	/* The number of macro names		IN  */
{
OM_S_CLASSLIST		class_list;
OMuword			macro_def_clid;
IGRint			i, j, k, l,
			macro_index,
			status,
			in_list = FALSE,
			nb_macros;
IGRchar			regexp[QUERY_LEN],
			reg_exp[QUERY_LEN];
DIgrid			*macros;
static char		**feet = NULL;
static int              nb_feet = 0;
struct GRmd_env		md_env;
IGRlong			msg,
			NumberOfBytes,
			BytesReceived;

        SetProc( VDCmdQYnpt.VDQYget_feet ); Begin

	/*
	 * free the previous list
	 */
	macros = NULL;

	if( nb_feet ){
		for( i=0 ; i<nb_feet ; i++) {
			_FREE( feet[i] ); 
                }
		_FREE(feet);
		nb_feet = 0;
	}


	/*
	 * restrict the search to the ACcpx_defn elements
	 */

	class_list.w_flags = OM_CLST_subclass;
	class_list.w_count = 1;
	status =
	om$get_classid(	classname = "ACcpx_defn", 
                        p_classid = &macro_def_clid );
	if (status != OM_S_SUCCESS) goto wrapup;
        class_list.p_classes = &macro_def_clid;

	NumberOfBytes = sizeof(md_env);
	gr$get_module_env(	msg    = &msg,
				sizbuf = &NumberOfBytes,
				buffer = &md_env,
				nret   = &BytesReceived);
	if(!(msg&1)) {status = OM_E_ABORT; goto wrapup;}

	status =
	di$give_pathname(	pathname = regexp,
				osnum = md_env.md_id.osnum);
	if (status != 1) goto wrapup;

	/*
	 * get the macro names in the directory subsystem
	 */

	strcat(regexp,":constructs_lib:*:constructs:");

	for( l=0; l<mac_count ; l++ ){
 
#ifdef DEBUG
	  printf("macro_name[%d]: %s\n",l, names[l]);
#endif

	  if( IsElemInMacroList( names[l], &macro_index )){

		int	count;

		count = elements[macro_index].nb_att;
		in_list = TRUE;

		if( ! count ) goto get_dump;

		if( nb_feet )
		  feet = _REALLOC ( feet, 
                         (1 + ((nb_feet + count) / 64)) * 64, char *  );
		else
		  feet = _MALLOC( 
                      (1 + ((nb_feet + count) / 64)) * 64,  char *  );

/*		if( nb_feet )
		  feet = (char **)BSrealloc ( (char *)feet, 
                    (1 + ((nb_feet + count) / 64)) * 64  * sizeof ( char * ) );
		else
		  feet = (char **)BSmalloc ( 
		    (1 + ((nb_feet + count) / 64)) * 64  * sizeof ( char * ) );
*/   
		if( ! feet ){
		  status = OM_E_NODYNMEM;
		  goto wrapup;
		}

		for( j=0 ; j<count ; j++ ){
		  feet [j + nb_feet] = _MALLOC( 
			(1 + ( strlen( elements[macro_index].att[j].name) / 32))			  * 32 , char);

		  if( ! feet[j + nb_feet] ){
		    status =  OM_E_NODYNMEM;
		    goto wrapup;
		  }

		  strcpy( feet[j+nb_feet],  elements[macro_index].att[j].name);
		}

#ifdef DEBUG
		printf("feet from the element list: %d\n", count);
		for(j=0;j<count;j++) printf("feetname: %s\n",feet[j+nb_feet]);
#endif

		nb_feet += count;

	  } /* IsElemInMacroList( names[l], &macro_index ) */

	  else{

get_dump:
	    strcpy(reg_exp, regexp);
	    if( in_list )
		strcat(reg_exp,elements[macro_index].real_name);
	    else
		strcat(reg_exp,names[l]);

	    strcat(reg_exp,"*");
            
            /* malloc macros in di$dump */
	    status =
	    di$dump(   regexp = reg_exp,
                       ptr = &nb_macros,
                       grids = &macros,
                       p_classes = &class_list,
                       options = 0 );
	    if (status != OM_S_SUCCESS) goto wrapup;

	    for( i=0 ; i<nb_macros ; i++ ){

		int		count;
		struct myfeet	*myfeet;

		status =	
		om$send(msg = message ACmacro_defn.ACgive_feet_desc ( &count, 
								&myfeet ),
                        senderid = NULL_OBJID,
 		        targetid = macros[i].objid,
                        targetos = macros[i].osnum );
		if (status != OM_S_SUCCESS) goto wrapup;

/*
		if (nb_feet)
		  feet = (char **)BSrealloc ( (char *)feet, 
                    (1 + ((nb_feet + count) / 64)) * 64  * sizeof ( char * ) );
		else
		  feet = (char **)BSmalloc ( 
	            (1 + ((nb_feet + count) / 64)) * 64  * sizeof ( char * ) );
 */   
		if (nb_feet)
		  feet = _REALLOC( feet, 
                    (1 + ((nb_feet + count) / 64)) * 64, char *  );
		else
		  feet = _MALLOC ( 
	            (1 + ((nb_feet + count) / 64)) * 64  , char * );
		if( !feet ){
		  status = OM_E_NODYNMEM;
		  goto wrapup;
		}

		k=0;
		for( j=0 ; j<count ; j++ ){
		  /*
		   * some feet can be expression but not defined like
		   * that in the macro definition
		   *
		   * if(!(myfeet[j].prop & parameter_generic)) continue; 
		   */
		  feet [k + nb_feet] = _MALLOC( 
			(1 + (strlen ( myfeet [j].name ) / 32)) * 32, char  );
		  if( ! feet [k + nb_feet] ){
			status = OM_E_NODYNMEM;
			goto wrapup;
		  }

		  strcpy( feet[k+nb_feet], myfeet[j].name );
		  k++;
		}

#ifdef DEBUG
		printf("feet from di$dump : %d\n", count);
		for(j=0;j<count;j++) printf("feetname: %s\n",feet[j+nb_feet]);
#endif

		nb_feet + = k;

	    } /* for( i=0 ; i<nb_macros ; i++ ) */

	    _FREE( macros );
                macros = NULL;
	  }
	} /* for( l=0; l<mac_count ; l++ ) */

	*feet_names = feet;
	*count = nb_feet;

	_FREE( macros );
                macros = NULL;
        End
	return OM_S_SUCCESS;
wrapup:  

	*count = 0;
	_FREE( macros );
        End
	return status;
}

/******************************************************************************

Method:
    init_query

Description:
    This method initialized the query form (VDquery1 / VDquery0).

Override:
    from CEO form_notification

History:

******************************************************************************/
method init_query ()
{
IGRint			status = OM_S_SUCCESS ;
Form			form_ptr;
int     		i, num , j;
GRname			buffer;
IGRlong                 sts,msg;                  
IGRchar                 text[QUERY_LEN];
IGRchar                 **tmpnamelist, **tmptextlist;

       SetProc( VDCmdQYnpt.init_query ); Begin

        if (!(me->forms[0].form_ptr)) {
             printf("No form pointer \n");
             return 0;
        }
	form_ptr = me->forms[0].form_ptr;

	/*
	 * Reset the form, this will turn on all gadgets
	 */

	FIf_reset (form_ptr);
        FIg_erase(form_ptr, EDIT_QUERY);
        FIg_erase(form_ptr, EDIT_QUERY_TITLE);
        FIg_erase(form_ptr, NEW_NAME);
        FIg_erase(form_ptr, NEW_NAME_TITLE);

        FIg_set_color(form_ptr,QUERY_TITLE, FI_BLACK);
        FIg_set_color(form_ptr,QUERY_NAME_TITLE,FI_BLACK);
        FIg_set_color(form_ptr,QUERY_DESCR_TITLE,FI_BLACK);

        FIg_display(form_ptr, QUERY_DESCR_TITLE);
        FIg_display(form_ptr, QUERY_NAME_TITLE);
        FIg_display(form_ptr, QUERY_TITLE);
        FIg_display(form_ptr, QUERY);



	/*
	 * Reset the query state
	 */
	status =
	om$send(msg = message VDCmdQYnpt.switch_query_state( 
					me->query_state = MACRO,
					TRUE ),
		targetid = my_id );

	/*
	 * Add the select keyword to the query field
	 */
	strcpy( buffer, "select " );
	VDqry_set_text (form_ptr, QUERY, buffer );

	/*
	 * Init the number of query offsets
	 */
	me->num_query_offsets = 0;

       /* read from collection table */

        /* when strings is malloc, first free it */
        VDfree_str_list ( AttrNameList, coll_nb );
        VDfree_str_list ( AttrTextList, coll_nb );

        sts = vd$get_list_from_coll(  msg       =  &msg,
                                coll_name =  VD_QRYDEF_DIR_NAME,
                                nb_rows   =  &coll_nb  );

        if ( !VDmalloc_str_list ( &AttrNameList, coll_nb, ATTR_NAME ) )
                {   
                        if ( coll_nb )
                            printf(" no memory allocated \n");
                }
        if (!VDmalloc_str_list ( &AttrTextList, coll_nb, VD_ATTR_LEN ) )
                {
                        if ( coll_nb )
                            printf(" no memory allocated \n");
                }
        sts = vd$get_list_from_coll(  msg             = &msg,
                                coll_name       = VD_QRYDEF_DIR_NAME,
                                nb_rows         = &coll_nb,
                                attr_name_list  = AttrNameList,
                                attr_text_list  = AttrTextList,
                                list_size       = coll_nb  );

	if( coll_nb ){

		FIfld_get_num_rows (form_ptr, MACRO_LIST, &num);
		FIfld_delete_rows (form_ptr, MACRO_LIST, 0, num);

        	/*
         	* put list into a tmp list in order to use qsort.
         	*/

        	tmpnamelist = NULL;
        	tmptextlist = NULL;
        	VDmalloc_str_list(&tmpnamelist, coll_nb, Qrylistlen);
        	VDmalloc_str_list(&tmptextlist, coll_nb, Qrylistlen);

        	for( i=0 ; i<coll_nb ; i++ ){
           	  tmpnamelist[i][0] = '\0';
           	  strcpy(tmpnamelist[i], AttrNameList[i]);
                }

        	/* sort */
        	qsort ( tmpnamelist, coll_nb, sizeof ( char *),
                	(int (*) ())my_strcmp);

        	for( i=0 ; i<coll_nb ; i++ ){
           	   for( j=0 ; j<coll_nb ; j++ ){
           		if(!strcmp(tmpnamelist[i], AttrNameList[j])) {
                  		tmptextlist[i][0] = '\0';
             	  		strcpy(tmptextlist[i], AttrTextList[j]);
                  		break; 
                        }
           	   } 
                }
     
        	/* rearrang AttrNameList and AttrTextList */
        	for( i=0 ; i<coll_nb ; i++ ){
                  AttrNameList[i][0] = '\0';
                  AttrTextList[i][0] = '\0';
                  strcpy(AttrTextList[i],tmptextlist[i]);
                  strcpy(AttrNameList[i],tmpnamelist[i]);
        	}

                /* free */
        	VDfree_str_list(tmpnamelist, coll_nb);
        	VDfree_str_list(tmptextlist, coll_nb);
        } /* if( coll_nb ) */
 
        /* check query definition format which is from collect table  
         */

        if (coll_nb) {
            status =
            om$send(msg = message VDCmdQYnpt.query_check(
                             AttrTextList,coll_nb),
                             targetid = my_id );
            if(status == 0) {
                goto wrapup;
            }
        }

        /* rearrange query definition */
        if (coll_nb) {
            status =
            om$send(msg = message VDCmdQYnpt.query_struct(
                             AttrNameList,AttrTextList,coll_nb),
                             targetid = my_id );
        }

	/* fill macro_list */
	for( i=0 ; i<coll_nb ; i++ ) {
                text[0] = '\0';
                strcat(text,AttrNameList[i]);
/*                strcat(text, "{");
                strcat(text,AttrTextList[i]);
                strcat(text, "}");
*/
		FIfld_set_text(	form_ptr, MACRO_LIST, i, 0, 
			        text, FALSE);
        }

	return OM_S_SUCCESS;
wrapup:
        FIfld_set_text( form_ptr, 10, 0, 0,
	"Syntax error in query definition, please check display query definition form", FALSE );

        End
	return OM_S_SUCCESS;
}

/******************************************************************************

Method:
    
    form_notification

Description:

    This method supports the query status display form.

Override:

    from CEO form_notification

History:

    jay wallingford     04/16/91    creation date

******************************************************************************/

method form_notification ( int    form_label; 
                           int    gadget_label; 
                           double value; 
                           Form   form_ptr )
{
IGRint		status = OM_S_SUCCESS;

        SetProc( VDCmdQYnpt.form_notification ); Begin

 if( me->mytype == QRY_COB_EXEC ){
	/*
	 * control form notification for form VDquery0
	 */
	status =
	om$send(msg = message VDCmdQYnpt.notify_query0(	form_label,
							gadget_label,
							value,
							form_ptr ),
		targetid = my_id );
	as$status( action= RET_STATUS );
 }
 else{
	/*
	 * control form notification for form VDquery1
	 */
	status =
	om$send(msg = message VDCmdQYnpt.notify_query1(	form_label,
							gadget_label,
							value,
							form_ptr ),
		targetid = my_id );
	as$status( action= RET_STATUS );
  }

  End
  return status;
}

/******************************************************************************
Method:
    notify_query0

Description:
    This method supports the select query form.

Override:
History:

    ad Zuurhout     09/12/94   creation date
    yzhu            10/12/94   modify
******************************************************************************/

method notify_query0 ( int    form_label; 
                       int    gadget_label; 
                       double value; 
                       Form   form_ptr )
{
IGRlong			msg = MSSUCC;
IGRint			sts,state;
IGRint			status = OM_S_SUCCESS;
IGRint			i,ii,
			pos, sel,
			row,num1,
			nbAct, nbRows;
IGRchar			*pSelect,
			*pWhere,
			*pComment,
			buffer[8*QUERY_LEN],
			text[80],
			name[QUERY_LEN],
			select[QUERY_LEN],
			where[QUERY_LEN];
struct	GRid		curId;
IGRchar			textline[QUERY_LEN], activeFile[QUERY_LEN];
IGRchar                 fullname[QUERY_LEN], filename[QUERY_LEN];
IGRchar                 queryname[QUERY_LEN], *ptr;
IGRlong                 sts1;
IGRint                  len =0;
IGRint			actSt = 0;
GRspacenum		cur_os;

        SetProc( VDCmdQYnpt.notify_query0); Begin

	ex$get_cur_mod( osnum   = &cur_os );
        VDget_filename_from_os( cur_os, activeFile );
	FIg_get_state( form_ptr, QRY_SEL_FILE_OPT_TOGGLE, &actSt );


	switch (gadget_label){

	case QRY_SEL_EXIST_TITLE  : 
	case QRY_SEL_DESC_TITLE   :
	case QRY_SEL_DEF_TITLE    :
	case QRY_SEL_ACTIVE_TITLE :

		/*
		 * do nothing.
		 */
		break;

	case QRY_SEL_EXIST        :
	case QRY_SEL_ACTIVE       :
	case QRY_SEL_DEF          :
	case QRY_SEL_DESC         :
		/*
		 * let select a active row to manippulate.
		 */
		break ;

        case QRY_SEL_SORT_LIST_TOGGLE  :
                FIg_get_state( form_ptr, QRY_SEL_SORT_LIST_TOGGLE, &state);
                __DBGpr_int( " state ", state);
                if(  state ){
                      FIg_enable(form_ptr, QRY_SEL_SORT_LIST);
                }
                else {

                      FIg_disable(form_ptr, QRY_SEL_SORT_LIST);
                      VDqry_clr_display(      form_ptr, QRY_SEL_EXIST );
                      VDqry_clr_display(      form_ptr, QRY_SEL_SORT_LIST );

                      num1 = om$dimension_of ( varray = me->qry_sortlist);

                      FIfld_set_num_rows( form_ptr, QRY_SEL_EXIST, num1 );

		      ii = 0;
                      for( i = 0; i < num1; i++) {

			 if( actSt && strcmp(activeFile, me->qry_sortlist[i].filename) ) continue;

                         fullname[0] = '\0';
                         sprintf( fullname, "%s[%s]",
                               me->qry_sortlist[i].name,
                               me->qry_sortlist[i].filename);

                         __DBGpr_str( "fullname", fullname);
                         FIfld_set_text(       form_ptr,
                                                QRY_SEL_EXIST,
                                                ii,
                                                0,
                                                fullname,
                                                FALSE );
			 ii++;
                     }

                }	 
		break ;

        case QRY_SEL_SORT_LIST    :
		/*
		 * sort list.
		 */
                FIfld_get_text( form_ptr, gadget_label, 0, 0,
                                QUERY_LEN, text, &sel, &pos);

                __DBGpr_str(" text ", text);

                /* skip blank */
                while(text[0] == ' ') strcpy(text, &text[1]);

                if( text[0] == '\0') { 
                  FIfld_set_text( form_ptr, gadget_label, 0, 0, "*", FALSE );
                  strcpy( text, "*");
                }
  
                /* clear list */
                VDqry_clr_display(      form_ptr, QRY_SEL_EXIST );

                num1 = om$dimension_of ( varray = me->qry_sortlist);
                FIfld_set_num_rows( form_ptr, QRY_SEL_EXIST, num1 );

                ii = 0;
                for( i = 0; i < num1; i++) {
		     if( actSt && strcmp(activeFile, me->qry_sortlist[i].filename) ) continue;
                     status =
                     VD_matchRE(text,me->qry_sortlist[i].name);
                     if(status) {
#ifdef DEBUG
                          printf(" me->qry_sortlist == %s\n", 
                                   me->qry_sortlist[i].name);
#endif


                        fullname[0] = '\0';
                        sprintf( fullname, "%s[%s]",
                                 me->qry_sortlist[i].name, 
                                 me->qry_sortlist[i].filename);

                        __DBGpr_str( "fullname", fullname);

                        FIfld_set_text( form_ptr,
                                        QRY_SEL_EXIST,
                                        ii,
                                        0,
                                        fullname,
                                        FALSE );
                        ii = ii + 1;
                     }
                }

		break ;
           
	case QRY_SEL_FILE_OPT_TOGGLE:
                /* clear list */
                VDqry_clr_display(  form_ptr, QRY_SEL_EXIST );
		FIg_get_state( form_ptr, QRY_SEL_FILE_OPT_TOGGLE, &actSt );
                num1 = om$dimension_of ( varray = me->qry_sortlist);
                FIfld_set_num_rows( form_ptr, QRY_SEL_EXIST, num1 );
		
		ii = 0;
                for( i = 0; i < num1; i++) {

		   if( actSt && strcmp(activeFile, me->qry_sortlist[i].filename) ) continue;

                   fullname[0] = '\0';
                   sprintf( fullname, "%s[%s]",
                            me->qry_sortlist[i].name,
                            me->qry_sortlist[i].filename);

                   FIfld_set_text(	form_ptr,
                                        QRY_SEL_EXIST,
                                        ii,
                                        0,
                                        fullname,
                                        FALSE );
		   ii++;
                }

		break;

	case QRY_SEL_REVIEW_BUTTON:
		/*
		 * get active row from list.
		 */
		nbRows = om$dimension_of( varray = me->queries );
		sel = FALSE;

		FIfld_get_active_row(	form_ptr, QRY_SEL_EXIST, &row, &pos );
		FIfld_get_select( form_ptr, QRY_SEL_EXIST, row, 0, &sel );
		if( ! sel || row < 0 || row > nbRows )	break;


                textline[0] = '\0';
                FIfld_get_text( form_ptr, QRY_SEL_EXIST, row, 0, 60, textline,
                                                      &sel, &pos);

                for ( i = 0; i < nbRows; i ++ ) {

                        IGRint  dirIndex = -1;
                        struct  GRmd_env        mdEnv;
                        struct  ret_struct      retStr;

                        status =
                        om$send(msg = message NDmacro.ACgive_structure(
                                                        &sts,
                                                        &dirIndex,
                                                        name,
                                                        &retStr,
                                                        &mdEnv ),
                                mode     = OM_e_wrt_message,
                                targetid = me->queries[i].objid,
                                targetos = me->queries[i].osnum,
                                senderid = NULL_OBJID );

                        fullname[0] = '\0';
                        filename[0] = '\0';

                        sts1 = VDget_filename_from_os(
                                me->queries[i].osnum, filename );
                        __DBGpr_str( "filename", filename);

                        if ( !(1&sts1) ) {
                         FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
                         FIfld_set_text( form_ptr,10,0,0,"Not found File Name",
                                         FALSE);
                        }

                        sprintf( fullname, "%s[%s]",
                               retStr.var.text_st.text_string, filename);
                        __DBGpr_str( "fullname", fullname);

                       if(!strcmp( textline, fullname)) {
                               curId = me->queries[i] ;
                               break;
                      }
                }

#ifdef	DEBUG
		printf(" id/os: %d,%d\n", curId.objid, curId.osnum );
#endif

		pComment = NULL;
		status =
		om$send(msg = message VDquery.VDgive_query(
							&msg,
							NULL,
							NULL,
							&pComment ),
			targetid = curId.objid,
			targetos = curId.osnum,
			senderid = NULL_OBJID );

		if( (status & msg & 1)  && pComment ){
			/*
			 * print message.
			 */
			IGRint	len = 0;
			
			VDqry_clr_display( form_ptr, QRY_SEL_DESC );
			len = strlen( pComment );
			if( len < 30 )
				FIfld_set_text(	form_ptr, QRY_SEL_DESC,
						0,0, pComment, FALSE );
			else{
			  i = ii = 0;
			  while( i<len ){
				strncpy( buffer, &(pComment[i]), 30 );
				FIfld_set_text( form_ptr, QRY_SEL_DESC,
						ii++, 0, buffer, FALSE );
				i+=30;
			  }
		}
		}

	        _FREE( pComment );
		pComment = NULL;

		break;

	case QRY_SEL_SET_ACTIVE   :

		nbAct   = om$dimension_of( varray = me->act_queries );
		nbRows  = om$dimension_of( varray = me->queries );
                __DBGpr_int( "nbAct", nbAct);
                __DBGpr_int( "nbRows", nbRows);
		sel     = FALSE;

		FIfld_get_active_row( form_ptr, QRY_SEL_EXIST, &row, &pos );
		FIfld_get_select( form_ptr, QRY_SEL_EXIST, row, 0, &sel );

		if( ! sel || row < 0 || row > nbRows )	break;

                textline[0] = '\0'; 
                FIfld_get_text( form_ptr, QRY_SEL_EXIST, row, 0, 60, textline,
                                                      &sel, &pos);
                __DBGpr_str( "textline", textline);
                strcpy( name, VD_qry_nmName ); 
                for ( i = 0; i < nbRows; i ++ ) {

                        IGRint  dirIndex = -1;
                        struct  GRmd_env        mdEnv;
                        struct  ret_struct      retStr;

                        status =
                        om$send(msg = message NDmacro.ACgive_structure(
                                                        &sts,
                                                        &dirIndex,
                                                        name,
                                                        &retStr,
                                                        &mdEnv ),
                                mode     = OM_e_wrt_message,
                                targetid = me->queries[i].objid,
                                targetos = me->queries[i].osnum,
                                senderid = NULL_OBJID );

          		fullname[0] = '\0';
          		filename[0] = '\0';

          		sts1 = VDget_filename_from_os( 
                                me->queries[i].osnum, filename );
                        __DBGpr_str( "filename", filename);

          		if ( !(1&sts1) ) {
                	 FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
                         FIfld_set_text( form_ptr,10,0,0,"Not found File Name",
                                         FALSE);
                        }

                        sprintf( fullname, "%s[%s]", 
                               retStr.var.text_st.text_string, filename);
                        __DBGpr_str( "fullname", fullname);

                        if(!strcmp( textline, fullname)) { 
		               curId = me->queries[i] ;
                               __DBGpr_obj( "curId", curId);
                               break;
                        }
                }
		if( nbAct == 0 ){
			status = 
			om$vla_set_dimension(   varray = me->act_queries,
						size   = 1 );
			me->act_queries[0] = curId ;
		}
		else{
		    for( i=0 ; i<nbAct ; i++ ){
			if( curId.objid == me->act_queries[i].objid &&
			    curId.osnum == me->act_queries[i].osnum )	break;
		    }

		    if( i<nbAct ) break ;	/* duplication */

		    status = 
		    om$vla_set_dimension(   varray = me->act_queries,
					    size   = nbAct+1 );
		    me->act_queries[nbAct] = curId ;
		}
#ifdef	DEBUG
		printf(" id/os: %d,%d\n", curId.objid, curId.osnum );
#endif

		/*
		 * get number of rows in the active query list.
		 */
		nbAct = om$dimension_of( varray = me->act_queries );
                __DBGpr_int( " nbAct ", nbAct);

		strcpy( name, VD_qry_nmName );
		VDqry_clr_display(	form_ptr, QRY_SEL_ACTIVE );

		ii=0;
		for( i=0 ; i<nbAct ; i++ ){

			IGRint	dirIndex = -1;
			struct	GRmd_env	mdEnv;
			struct	ret_struct	retStr;

			status = 
			om$send(msg = message NDmacro.ACgive_structure(
							&sts,
							&dirIndex,
							name,
							&retStr,
							&mdEnv ),
	                	mode     = OM_e_wrt_message,
				targetid = me->act_queries[i].objid,
				targetos = me->act_queries[i].osnum,
				senderid = NULL_OBJID );

			if( ! (status & sts & 1 )) continue;

                        fullname[0] = '\0';
                        filename[0] = '\0';

                        sts1 = VDget_filename_from_os(
                                me->act_queries[i].osnum, filename );
                        __DBGpr_str( "filename", filename);
                        if ( !(1&sts1) ) {
                         FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
                         FIfld_set_text( form_ptr,10,0,0,"Not found File Name",
                                         FALSE);
                        }

                        sprintf( fullname, "%s[%s]",
                               retStr.var.text_st.text_string, filename);
                        __DBGpr_str( "fullname", fullname);

                         
			FIfld_set_text( form_ptr, QRY_SEL_ACTIVE, ii++, 0,
				fullname, FALSE );
		}

		/*
		 * fill in definition field.
		 */

		VDqry_clr_display( form_ptr, QRY_SEL_DEF );
		ii=0;
		pSelect = NULL;
		pWhere = NULL;
		for( i=0 ; i<nbAct ; i++ ){

			status =
			om$send(msg = message VDquery.VDgive_query(
							&msg,
							&pSelect,
							&pWhere,
							NULL ),
				targetid = me->act_queries[i].objid,
				targetos = me->act_queries[i].osnum,
				senderid = NULL_OBJID );

			if( (status & msg & 1) && pSelect ){

				strcpy( buffer, pSelect );
				strcat( buffer, " " );
				if( pWhere ) strcat( buffer, pWhere );

				VDqry_splt_string( buffer, select, where );

				FIfld_set_text( form_ptr, QRY_SEL_DEF,
						ii++, 0, select, FALSE );
			
				FIfld_set_text( form_ptr, QRY_SEL_DEF,
						ii++, 0, where, FALSE );
			}

			_FREE( pSelect );
			_FREE(  pWhere  );

			pSelect = NULL;
			pWhere  = NULL;
		}

		break;

	case QRY_SEL_RESET_ACTIVE :

		nbAct = om$dimension_of( varray = me->act_queries );
		sel   = FALSE;

		FIfld_get_active_row( form_ptr, QRY_SEL_ACTIVE, &row, &pos );
		FIfld_get_select( form_ptr, QRY_SEL_ACTIVE, row, 0, &sel );

		if( ! sel || row < 0 || row > nbAct )	break;

		for( i=row ; i<(nbAct-1) ; i++ ){
			me->act_queries[i] = me->act_queries[i+1] ;
		}

		status = 
		om$vla_set_dimension(   varray = me->act_queries,
					size   = nbAct-1 );

		/*
		 * get number of rows in the active query list.
		 */
		nbAct = om$dimension_of( varray = me->act_queries );
		strcpy( name, VD_qry_nmName );
		VDqry_clr_display( form_ptr, QRY_SEL_ACTIVE );

		ii=0;
		for( i=0 ; i<nbAct ; i++ ){

			IGRint	dirIndex = -1;
			struct	GRmd_env	mdEnv;
			struct	ret_struct	retStr;

			status = 
			om$send(msg = message NDmacro.ACgive_structure(
							&sts,
							&dirIndex,
							name,
							&retStr,
							&mdEnv ),
	                	mode     = OM_e_wrt_message,
				targetid = me->act_queries[i].objid,
				targetos = me->act_queries[i].osnum,
				senderid = NULL_OBJID );

			if( ! (status & sts & 1 )) continue;

                        fullname[0] = '\0';
                        filename[0] = '\0';

                        sts1 = VDget_filename_from_os(
                                me->act_queries[i].osnum, filename );
                        __DBGpr_str( "filename", filename);

                        if ( !(1&sts1) ) {
                         FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
                         FIfld_set_text( form_ptr,10,0,0,"Not found File Name",
                                         FALSE);
                        }

                        sprintf( fullname, "%s[%s]",
                               retStr.var.text_st.text_string, filename);
                        __DBGpr_str( "fullname", fullname);


			FIfld_set_text( form_ptr, QRY_SEL_ACTIVE, ii++, 0,
				fullname, FALSE );
		}

		/*
		 * fill in definition field.
		 */

		VDqry_clr_display( form_ptr, QRY_SEL_DEF );

		ii=0;
		pSelect = NULL;
		pWhere  = NULL;

		for( i=0 ; i<nbAct ; i++ ){
			status =
			om$send(msg = message VDquery.VDgive_query(
							&msg,
							&pSelect,
							&pWhere,
							NULL ),
				targetid = me->act_queries[i].objid,
				targetos = me->act_queries[i].osnum,
				senderid = NULL_OBJID );

			if( (status & msg & 1) && pSelect ){

				strcpy( buffer, pSelect );
				strcat( buffer, " ");
				if( pWhere ) strcat( buffer, pWhere );

				VDqry_splt_string( buffer, select, where );

				FIfld_set_text( form_ptr, QRY_SEL_DEF,
						ii++, 0, select, FALSE );
			
				FIfld_set_text( form_ptr, QRY_SEL_DEF,
						ii++, 0, where, FALSE );
			}

			_FREE( pSelect );
			_FREE( pWhere  );
			pSelect = NULL;
			pWhere  = NULL;
		}

		break;


	case FI_CANCEL:
		/*
		 * Erase and reset the form, this will also reset query state
		 */
		status =
		om$send(msg = message CEO.erase_form_by_label(
							form_label, 0, &sts ),
		targetid = my_id );

		_put_response(  resp = EX_FORM_FINISHED );
		
		break;

	case FI_ACCEPT:
		{
		int	response;
		long	ok, buffersize;
	
		nbAct   = om$dimension_of( varray = me->act_queries );
                __DBGpr_int( " nbAct ", nbAct);
		pSelect = NULL;
		pWhere  = NULL;
		buffer[0] = '\0';
                VDQYnpt_query_list[0] = '\0';               
               
                ptr = NULL;
                /* save active query names */
                for( i=0 ; i<nbAct ; i++ ){
			FIfld_get_text(	form_ptr, QRY_SEL_ACTIVE, i, 0, 
					60, textline, &sel, &pos);
                        len = 0;
                        len = strlen( textline );
                        ptr = strchr( textline, '[');
                        queryname[0] ='\0';
                        if( ptr != NULL)
                              len = len - strlen(&ptr[0]);
                        strcpy( queryname, textline);
                        queryname[len] = '\0';
                        __DBGpr_str( " active queryname", queryname);
                        strcat( VDQYnpt_query_list,queryname);
                        strcat( VDQYnpt_query_list,";");
                }
		for( i=0 ; i<nbAct ; i++ ){

			status =
			om$send(msg = message VDquery.VDgive_query(
							&msg,
							&pSelect,
							&pWhere,
							NULL ),
				targetid = me->act_queries[i].objid,
				targetos = me->act_queries[i].osnum,
				senderid = NULL_OBJID );

			if( (status & msg & 1) && pSelect ){

				strcat( buffer, pSelect );
				strcat( buffer, " ");
				if( pWhere ) strcat( buffer, pWhere );

				strcat( buffer, ";" );
			}

			_FREE( pSelect );
			_FREE( pWhere  );

			pSelect = NULL;
			pWhere  = NULL;
		}

		/*
		 * Push the query on the queue.
		 */
		buffersize = strlen(buffer) + 1;
		response = EX_STRING;

		ex$putque(	msg		= &ok,
				response	= &response,
				byte		= &buffersize,
				buffer		= buffer );
        	}
                strcpy( me->buffercontent,buffer);
		break;
	default:

		break;
	}

quit:
        End
	return OM_S_SUCCESS ;
}

/******************************************************************************
Method:
    notify_query1

Description:
    This method supports the query status display form.

Override:
History:

    ad Zuurhout     09/12/94   creation date

******************************************************************************/

method notify_query1 ( int    form_label; 
                       int    gadget_label; 
                       double value; 
                       Form   form_ptr )
{
IGRlong			msg,sts1;
IGRint			sts;
IGRint			status = OM_S_SUCCESS;
IGRint			sel, pos, num;
IGRint			state;		/* FIfld_get_state value */
IGRint			i,k,
			j,
			macro_index,
			att_index;
IGRchar			*ptr,
			buffer[4*QUERY_LEN],
			bufferi[4*QUERY_LEN],
			query[4*QUERY_LEN],
			name[QUERY_LEN],
/*			oldname[QUERY_LEN],    */
			comment[QUERY_LEN], 
			text[QUERY_LEN],
			tname[QUERY_LEN],
			class_name[QUERY_LEN],
			text1[QUERY_LEN],
			text2[QUERY_LEN],
			text3[QUERY_LEN];
IGRint			switch_state = TRUE,
			concatenate = TRUE,
			back_up = FALSE;
struct	GRid		qryId;
struct ACrg_coll        *list; 
IGRint                  count,count1,ii,len;
IGRdouble               value1;
IGRint                  a_flag = 1;
IGRint                  v_flag = 1;
IGRint                  c_flag = FALSE;
IGRint                  vd_flag = 1;
int     		ref_macrolist = FALSE;
int     		ref_locatelist = FALSE;
int                     no_dash = 0;
int 			nbRows = 0;
int 			sel_flag, qflag;
struct  GRid            curId;
IGRchar                 *pSelect,
                        *pWhere,
                        *pComment,
                        select[QUERY_LEN],
                        where[QUERY_LEN];
IGRchar 		prompt[MS_MAX_MSG_LENGTH];
GRname                  gvName;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;
IGRint                  rc,
                        directIndex = 0;
IGRchar                 **tmpquery;
IGRchar                 fullname[QUERY_LEN], filename[QUERY_LEN];
GRspacenum              cur_os;
IGRchar                 queryname[QUERY_LEN], filename1[QUERY_LEN];
IGRchar                 *ptr1;
IGRint                  dupflag = FALSE;

 SetProc( VDCmdQYnpt.notify_query1); Begin

 macro_index = att_index = -1;
 me->macro_list = FALSE;

 switch (gadget_label){

    case FORM_TITLE:
    case ELEM_TYPE_TITLE:
    case CONDITION_TITLE:
    case VALUE_TITLE:

    case QUERY_CMD_DELETE:
    case QUERY_CMD_LOAD:
    case QUERY_CMD_SAVE:

    case QUERY:
    case QUERY_DESCRIPTION:
    case QUERY_TITLE:
    case QUERY_NAME_TITLE:
    case QUERY_DESCR_TITLE:

	switch_state = FALSE;
	concatenate = FALSE;

	break;

    case EDIT_QRY_TOGGLE:
        FIg_get_state( form_ptr, EDIT_QRY_TOGGLE, &state);
        if(  state ){
	     VDqry_clr_display(form_ptr, QUERY );
	     VDqry_clr_display(form_ptr, EDIT_QUERY );
	     VDqry_clr_display(form_ptr, NEW_NAME);
	     VDqry_clr_display(form_ptr, QUERY_NAME);
	     VDqry_clr_display(form_ptr, QUERY_DESCRIPTION);
	     VDqry_clr_display(form_ptr, 10);

             FIg_erase(form_ptr, QUERY_TITLE);
             FIg_erase(form_ptr, QUERY);

             FIg_set_color(form_ptr,EDIT_QUERY_TITLE, FI_BLUE);
             FIg_set_color(form_ptr,QUERY_NAME_TITLE, FI_BLUE);
             FIg_set_color(form_ptr,QUERY_DESCR_TITLE, FI_BLUE);
             FIg_set_color(form_ptr,NEW_NAME_TITLE, FI_BLUE);

             FIg_display(form_ptr, EDIT_QUERY);
             FIg_display(form_ptr, EDIT_QUERY_TITLE);
             FIg_display(form_ptr, NEW_NAME);
             FIg_display(form_ptr, NEW_NAME_TITLE);
             FIg_display(form_ptr, QUERY_NAME_TITLE);
             FIg_display(form_ptr, QUERY_DESCR_TITLE);

                FIg_disable( form_ptr, MACRO_LIST );
                FIg_disable( form_ptr, MACRO_FIELD);
                FIg_disable(form_ptr, QRY_GRP_WHERE );
                FIg_disable(form_ptr, QRY_GRP_ATTR );
                FIg_disable(form_ptr, ATTR_SYMB_TOGGLE);
                FIg_disable(form_ptr, QRY_GRP_COND );
                FIg_disable(form_ptr, QRY_GRP_VALUE );
                FIg_disable(form_ptr, QRY_GRP_CONJ );
                FIg_disable( form_ptr, BACKUP_BUTTON );
                FIg_disable(form_ptr, FI_EXECUTE );
                FIg_disable(form_ptr, FI_ACCEPT );
                FIg_disable( form_ptr, LOCATE_OBJECT);
                FIg_enable(form_ptr, FI_CANCEL );
                FIg_enable(form_ptr, FI_RESET );


                FIg_disable(form_ptr, EDIT_QUERY);
                FIg_disable(form_ptr, QUERY_DESCRIPTION);
                FIg_disable(form_ptr, NEW_NAME);
        }
        else {

	     VDqry_clr_display(form_ptr, 10);
	     VDqry_clr_display(form_ptr, QUERY_NAME);
	     VDqry_clr_display(form_ptr, QUERY_DESCRIPTION);
             FIg_erase(form_ptr, EDIT_QUERY);
             FIg_erase(form_ptr, EDIT_QUERY_TITLE);
             FIg_erase(form_ptr, NEW_NAME);
             FIg_erase(form_ptr, NEW_NAME_TITLE);

             FIg_set_color(form_ptr,QUERY_TITLE, FI_BLACK);
             FIg_set_color(form_ptr,QUERY_NAME_TITLE,FI_BLACK);
             FIg_set_color(form_ptr,QUERY_DESCR_TITLE,FI_BLACK);

             FIg_display(form_ptr, QUERY_DESCR_TITLE);
             FIg_display(form_ptr, QUERY_NAME_TITLE);
             FIg_display(form_ptr, QUERY_TITLE);
             FIg_display(form_ptr, QUERY);


                /*
                 * Select macro(s) to search
                 */
/*              FIg_enable( form_ptr , QRY_GRP_MACRO ); */ 
                FIg_enable( form_ptr, MACRO_LIST );
                FIg_enable( form_ptr, MACRO_FIELD);
                FIg_enable( form_ptr, LOCATE_OBJECT);
                FIg_enable( form_ptr, BACKUP_BUTTON);
                FIg_disable(form_ptr, QRY_GRP_WHERE );
                FIg_disable(form_ptr, QRY_GRP_ATTR );
                FIg_disable(form_ptr, ATTR_SYMB_TOGGLE);
                FIg_disable(form_ptr, QRY_GRP_COND );
                FIg_disable(form_ptr, QRY_GRP_VALUE );
                FIg_disable(form_ptr, QRY_GRP_CONJ );
                FIg_disable(form_ptr, FI_EXECUTE );
                FIg_disable(form_ptr, FI_ACCEPT );

                ex$message(msgnumb = GR_P_SelMacSrch, buff = prompt);


        }           

	switch_state = FALSE;
	concatenate  = FALSE;

        break;

        
    case EDIT_QUERY:
	switch_state = FALSE;
	concatenate  = FALSE;
        break;

    case NEW_NAME:
	 switch_state = FALSE;
	 concatenate  = FALSE;
         break;

    case QUERY_NAME:

	FIfld_set_text( form_ptr, 10,0,0, "",FALSE);
        FIg_get_state( form_ptr, EDIT_QRY_TOGGLE, &state);

        if(  state ){
          __DBGpr_com(" state = 1");
          FIfld_get_list_num_rows( form_ptr, QUERY_NAME, 0, &num );

          sel_flag =NULL;
          name[0] = '\0';

          /* get name from QUERY_NAME */
	  FIfld_get_text(	form_ptr, QUERY_NAME, 0, 0, QUERY_LEN, name, 
			&sel, & pos);

          __DBGpr_str(" name ", name);

          /* get current space num */
          status =
          ex$get_cur_mod( osnum   = &cur_os );
          /* name = queryname[filename] */
          len = 0;
          len = strlen(name);
          queryname[0] = '\0';
          filename[0] = '\0';
          fullname[0] = '\0';
          filename1[0] = '\0';
          if( len != NULL){
             ptr = strchr(name,'[');
             if(ptr != NULL) {
                len = len - strlen(&ptr[0]);
                strncpy(queryname,name, len);
                queryname[len] = '\0';
                ptr = &ptr[1];
                len = strlen(ptr);
                ptr1 = strchr(ptr,']');
                len = len - strlen(&ptr1[0]);
                strncpy(filename,ptr, len);
                filename[len] = '\0';
	        FIfld_set_text( form_ptr, QUERY_NAME,0,0, queryname,FALSE);
                len = strlen(name);
                strcpy( fullname, name);
                fullname[len] = '\0';
             } 
             else { /* if name = query name */ 
                strncpy(queryname,name, len);
                queryname[len] = '\0';
          	/* 
                 * get current filename which is used for name check.
           	 * we want to keep name unique in the current file.
           	 * we can have same query name with diff file name
           	 */
                sts1 =
                VDget_filename_from_os( cur_os, filename );
                if ( !(1&sts1) ) {
                  FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
                  FIfld_set_text( form_ptr,10,0,0,"Not found File Name",FALSE);
                   sprintf(fullname, "%s", name);
                }
                else    
                   sprintf(fullname, "%s[%s]", name,filename);
              } 
                __DBGpr_str(" queryname ", queryname);
                __DBGpr_str(" filename ", filename);
                __DBGpr_str(" fullname ", fullname);
          }
          nbRows  = om$dimension_of( varray = me->queries );

          qflag = 0;
          /* comparing input name with list */
          for( i=0 ; i<num ; i++ ){
                buffer[0] = '\0';
                FIfld_get_list_text(    form_ptr,
                                        QUERY_NAME,
                                        i,
                                         0,
                                        QUERY_LEN,
                                        buffer,
                                        &sel );

                __DBGpr_str(" buffer ", buffer);
                if(!strcmp(buffer, fullname)) {
                        /* from name get id */
                        for( j=0 ; j<nbRows; j++ ){
                          IGRint  dirIndex = -1;
                          struct  GRmd_env        mdEnv;
                          struct  ret_struct      retStr;
                          GRname  name1;  
                          strcpy( name1, VD_qry_nmName );
                          
                          status =
                          om$send(msg = message NDmacro.ACgive_structure(
                                                        &sts,
                                                        &dirIndex,
                                                        name1,
                                                        &retStr,
                                                        &mdEnv ),
                                mode     = OM_e_wrt_message,
                                targetid = me->queries[j].objid,
                                targetos = me->queries[j].osnum,
                                senderid = NULL_OBJID );

                          if(!strcmp( queryname, 
                                      retStr.var.text_st.text_string)){
                	   sts1 =
                	   VDget_filename_from_os( me->queries[j].osnum, 
                                                            filename1 );
                	   if ( !(1&sts1) ) {
                            FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
                            FIfld_set_text( form_ptr,10,0,0,
                                           "Not found File Name",FALSE);
                           }
                           else if(!strcmp( filename1, filename)) {
                               curId = me->queries[j] ;
                               if( cur_os == me->queries[j].osnum ) 
                                            me->isdesignfile = TRUE;
                               else
                                            me->isdesignfile = FALSE;
                               break;
                           } 
                          }
                        } /* for */

                        /*
                         * fill in definition and commnet field.
                         */
                        pSelect  = NULL;
                        pWhere   = NULL;
                        pComment = NULL;

                        ii = 0;
                        status =
                        om$send(msg = message VDquery.VDgive_query(
                                                        &msg,
                                                        &pSelect,
                                                        &pWhere,
                                                        &pComment),
                                targetid = curId.objid,
                                targetos = curId.osnum,
                                senderid = NULL_OBJID );

                        buffer[0] = '\0';
                        if( (status & msg & 1) && pSelect ){
                                strcpy( buffer, pSelect );
                                strcat( buffer, " " );
                                if( pWhere ) strcat( buffer, pWhere );

                                VDqry_splt_string( buffer, select, where );
			
                                FIg_enable(      form_ptr, EDIT_QUERY );
                                FIg_enable(      form_ptr, NEW_NAME);
			        VDqry_clr_display(      form_ptr, EDIT_QUERY );
			        VDqry_clr_display(      form_ptr, NEW_NAME);

                                FIfld_set_text( form_ptr, EDIT_QUERY,
                                                ii++, 0, select, FALSE );

                                FIfld_set_text( form_ptr, EDIT_QUERY,
                                                ii++, 0, where, FALSE );

                                FIfld_set_text( form_ptr, NEW_NAME,
                                                0, 0, queryname, FALSE );
 
                                qflag = 1;
                        }
               
                        buffer[0] = '\0';
                        if( (status & msg & 1)  && pComment ){
                        /*
                         * print message.
                         */
                        IGRint  len = 0;

	        	 VDqry_clr_display( form_ptr,QUERY_DESCRIPTION);
                         len = strlen( pComment );
                         if( len < 30 )
                                FIfld_set_text( form_ptr, QUERY_DESCRIPTION,
                                                0,0, pComment, FALSE );
                       	 else{
                          i = ii = 0;
                          while( i<len ){
                                strncpy( buffer, &(pComment[i]), 30 );
                                FIfld_set_text( form_ptr, QUERY_DESCRIPTION,
                                                ii++, 0, buffer, FALSE );
                                i+=30;
                          }
                         }
                        }

                        _FREE( pComment ) ;
                        _FREE( pSelect );
                        _FREE(  pWhere  );

                        if ( qflag == 1) 
                                    break;   /* out of i loop */      
                 } /*if(!strcmp */
            } /* for (i */
            
            if(!qflag) { 
                VDqry_clr_display(form_ptr, EDIT_QUERY );
                VDqry_clr_display(form_ptr, NEW_NAME);
                VDqry_clr_display(form_ptr, QUERY_NAME);
                VDqry_clr_display(form_ptr, QUERY_DESCRIPTION);
                VDqry_clr_display(form_ptr, 10);

               	FIg_disable(form_ptr, EDIT_QUERY );
               	FIg_disable(form_ptr, QUERY_DESCRIPTION );
               	FIg_disable(form_ptr, NEW_NAME );
                FIg_disable(form_ptr, FI_EXECUTE );
                FIg_disable(form_ptr, FI_ACCEPT );
	          
		FIfld_set_text( form_ptr, 10,0,0, "No query found",FALSE);
            }
            else {
               	FIg_enable(form_ptr, EDIT_QUERY );
               	FIg_enable(form_ptr, QUERY_DESCRIPTION );
               	FIg_enable(form_ptr, NEW_NAME );
               	FIg_enable(form_ptr, FI_EXECUTE );
               	FIg_enable(form_ptr, FI_RESET );
               	FIg_enable(form_ptr, FI_ACCEPT );
            }
        } /* if(state) */
        else {
          me->isdesignfile = TRUE;
          __DBGpr_com(" state = 0");

	  /*
	   * check if name is unique
	   */
	  FIfld_get_text(	form_ptr, QUERY_NAME, 0, 0, QUERY_LEN, name, 
			&sel, & pos);
        
          __DBGpr_str( " name ", name);

          /* if name = queryname[filename] */
          len = 0;
          len = strlen(name);
                __DBGpr_int( " len0 ", len);
          queryname[0] = '\0';
          filename[0] = '\0';
          fullname[0] = '\0';
          filename1[0] = '\0';
          if( len != NULL){
             ptr = strchr(name,'[');
             if(ptr != NULL) {
                len = len - strlen(&ptr[0]);
                __DBGpr_int( " len1 ", len);
                strncpy(queryname,name, len);
                queryname[len]='\0'; 
                __DBGpr_str( " queryname ", queryname);
                ptr = &ptr[1];
                len = 0;
                len = strlen(ptr);
                __DBGpr_str( " ptr ", ptr);
                ptr1 = strchr(ptr,']');
                len = len - strlen(&ptr1[0]);
                __DBGpr_int( " len2 ", len);
                strncpy(filename, ptr, len);
                filename[len] = '\0';
                __DBGpr_str( " filename ", filename);
                FIfld_set_text( form_ptr, QUERY_NAME,0,0, queryname,FALSE);
             }
             else{  /* if name = query name */
                __DBGpr_int( " len2 ", len);
                strncpy(queryname,name, len);
                queryname[len]='\0'; 
                
             }
          }
     
          /* get current space num */
          status =
          ex$get_cur_mod( osnum   = &cur_os );
         
          /* get current filename which is used for name check.
           * we want to keep name unique in the current file.
           * we can have same query name with diff file name 
           */
          fullname[0] = '\0';
          filename[0] = '\0';
          sts1 =
          VDget_filename_from_os( cur_os, filename );
          if ( !(1&sts1) ) {
		FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
		FIfld_set_text( form_ptr,10,0,0,"Not found File Name",FALSE);
                break;
          }

          sprintf(fullname, "%s[%s]", queryname,filename);	
                __DBGpr_str( " fullname ", fullname);
	  FIfld_get_list_num_rows( form_ptr, QUERY_NAME, 0, &num );

	  for( i=0 ; i<num ; i++ ){

                FIfld_get_list_text(	form_ptr,
                                        QUERY_NAME,
                                        i,
                                        0,
					QUERY_LEN,
					buffer,
					&sel );

		if ( strcmp( buffer, fullname ) == 0 ){
			/*
			 * duplicate of name.
			 */
/*			UI_status(" Name not unique" ); */
		       FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
		       FIfld_set_text( form_ptr,10,0,0,"Name not unique",FALSE);
		       break;
		}
	  }
        } /* else */

	switch_state = FALSE;
	concatenate  = FALSE;

	break;
	
    case MACRO_LIST:

        text[0] = '\0';
        text1[0] = '\0';
        FIfld_get_num_rows (form_ptr, MACRO_LIST, &num);
        for (i=0; i<num; ++i)
        {
            FIfld_get_select (form_ptr, MACRO_LIST, i, 0, &sel);
            FIfld_get_text (form_ptr,MACRO_LIST, i, 0, QUERY_LEN, text1, &sel, 
								&pos);
            if (sel)
            {
                if(text1[0] != '\0') {
                     strcat(text, me->qry_list[i].iname);    
                      me->macro_list = TRUE;
                      me->macro_field = FALSE;
                      me->feet_flag = FALSE;
                      me->locate_flag = FALSE;
                      FIg_disable(form_ptr, LOCATE_OBJECT);
                      FIg_disable(form_ptr, MACRO_FIELD);
                }
            }
                      
        }
        FIfld_set_text (form_ptr, MACRO_FIELD, 0, 0, text, FALSE);

    case MACRO_FIELD:

        def_state = 0;
        if(gadget_label == MACRO_FIELD) {
              me->locate_flag = FALSE;
              me->macro_list = FALSE;
              me->feet_flag = TRUE;
              me->macro_field = TRUE;
        }

        FIfld_get_text (form_ptr, MACRO_FIELD, 0, 0, QUERY_LEN, text, &sel, 
								&pos);

	while(text[0] == ' ') strcpy(text, &text[1]);
	while(text[strlen(text)-1] == ' ') text[strlen(text)-1] = '\0';

	ptr = &text[0];
	buffer[0] = '\0';
	bufferi[0] = '\0';
	text1[0] = '\0';
        no_dash  = 0; 
	while(ptr != NULL ){
            strcpy(text, &ptr[0]);
            if( VDSGetNextWord(text, query, QUERY_LEN, '-', &ptr) == 0){
                        printf("ERROR VDSGetNextWord\n");
                        return 0;
            }
            if ( me->macro_list && !no_dash) {
                /* get definision from collection table */
               for (i = 0; i < coll_nb; i++) {
                 FIfld_get_select (form_ptr, MACRO_LIST, i, 0, &sel);
                  if (sel) {
                        if(buffer[0] == '\0') strcpy(buffer,"select ");
                        else strcat(buffer,"-");
                    strcpy ( bufferi , buffer ) ;
                    status =
                    om$send(msg = message VDCmdQYnpt.arrange_qrylist(
                                                   AttrTextList[i],
                                                   bufferi),
                             targetid = my_id );
                    if ( status ) {
                        c_flag = TRUE;
                        no_dash = 1;
                        break ;
                    }
                  } 
                } 
                if(c_flag) {
                  if ( def_state == 5) {
                	status =
                	om$send(msg = message VDCmdQYnpt.switch_query_state
                                   (me->query_state = CONJUNCTION, TRUE),
                		   targetid = my_id );
                        as$status();
                  }
                  else {
                	status =
                	om$send(msg = message VDCmdQYnpt.switch_query_state
                                   (me->query_state = WHEREG, TRUE),
                		   targetid = my_id );
                        as$status();
                  } 
                        strcpy ( buffer , bufferi ) ;
                        switch_state = FALSE;
                }
                else if( !c_flag) {
                        FIfld_set_text ( form_ptr , 10 , 0 , 0 ,
                                "Syntax error in query definition " , 0 ) ;

                        switch_state = FALSE ;
                        strcpy ( buffer , "select " ) ;
                }
            } /* if */
            if( me->macro_field) { /* direct input */
                        if(buffer[0] == '\0') strcpy(buffer,"select ");
                        else strcat(buffer,"-");
                        /* check if the input name is a external name in
                         * query definition list (macro_list). If it is
                         * find relative internal name
                         */ 
                        for (i = 0; i < coll_nb; i++) {
                           if(strcmp(query,AttrNameList[i]) == 0 ) {
                              strcpy(query,me->qry_list[i].iname);
                              break;
                           }
                        }
                        strcat(buffer,query );
             }
         } /* while */

         if( me->macro_field) {
                        strcat(buffer, "  ");
         }

	/*
	 * write the constructed query in the QUERY field and go to the
	 * next state
 	 */

	VDqry_set_text( form_ptr, QUERY, buffer );

        if( text[0] == '\0' ){ 
            back_up = TRUE; 
            switch_state = FALSE; 
        }
        else if( me->query_state == WHEREG ){
            switch_state = FALSE;
        }
        concatenate = FALSE;

        break;

    case ATTR_SYMB_TOGGLE:

	switch_state = FALSE;
	concatenate = FALSE;

        FIg_get_state( form_ptr, ATTR_SYMB_TOGGLE, &state);
	if(  state ){

#ifdef	DEBUG
	  printf(" switch to symbology \n");
#endif
          FIfld_get_num_rows (form_ptr, ATTRIBUTE_LIST, &num);
          FIfld_delete_rows (form_ptr, ATTRIBUTE_LIST, 0, num);

          FIfld_get_num_rows (form_ptr, VALUE_LIST, &num);
          FIfld_delete_rows (form_ptr, VALUE_LIST, 0, num);

	  /*
	   * fill the attributes list with the symbology options.
	   */
          FIfld_set_text(form_ptr, ATTRIBUTE_LIST, 0, 0, "level", FALSE );
          FIfld_set_text(form_ptr, ATTRIBUTE_LIST, 1, 0, "color", FALSE );
          FIfld_set_text(form_ptr, ATTRIBUTE_LIST, 2, 0, "style", FALSE );
          FIfld_set_text(form_ptr, ATTRIBUTE_LIST, 3, 0, "weight", FALSE );

          FIfld_set_text(form_ptr, ATTRIBUTE_FIELD, 0, 0, " ", FALSE );
          FIfld_set_text(form_ptr, VALUE_FIELD, 0, 0, " ", FALSE );
	
	  break;
	}

#ifdef	DEBUG
	  printf("switch to attributes \n");
#endif

    case WHERE_CHECK:
    case WHERE_NOT_CHECK:

        {
          char ** pp_feet;
          int     num_feet = 0;
          char *  pp_macros[QUERY_LEN];
          int     num_macros = 0;
          char *  sep = "-";
          int     count2,ii,k;
          int     d_flag = 1;

#ifdef	DEBUG
	  printf(" WHERE_NOT_CHECK .. \n");
#endif
          me->feet_flag = TRUE;

	  /* get all the element types from the MACRO_FIELD */

          FIfld_get_text (form_ptr, MACRO_FIELD, 0, 0, QUERY_LEN, text, 
							&sel, &pos);

          if (pp_macros[num_macros] = strtok(text, sep))
          {
             ++num_macros;
             while ((pp_macros[num_macros] = strtok(NULL, sep)) &&
                       (num_macros < QUERY_LEN))
                        		++num_macros;
          }

          FIfld_get_num_rows (form_ptr, ATTRIBUTE_LIST, &num);
		
          FIfld_delete_rows (form_ptr, ATTRIBUTE_LIST, 0, num);

          status =
          om$vla_set_dimension(  varray =  me->VDslist,
                                 size   =  0);
 
          /* check ATTR_SYMB_TOGGLE state, if it is on symb, just put
           * symb in attribute list, if is is on attr, put attribute
           * on list
           */

          FIg_get_state( form_ptr, ATTR_SYMB_TOGGLE, &state);
 
          /*
           * if input directly and ATTR_SYMB_TOGGLE state is on attribute
           * , check and fill the attributes list with 
           * the feet of the macro or query_definition 
           */
          if(me->locate_flag == FALSE && !state) { 
             if( ! (VDQYget_feet (&pp_feet, &num_feet, pp_macros,
                                num_macros) & 1 )) {
                FIfld_pos_cursor (form_ptr, ATTRIBUTE_FIELD, 0, 0, 0, 0, 0, 0);
                me->feet_flag = FALSE;
             }
            if( me->feet_flag == FALSE ) {
             /*
              * if input name is not found in macro feet,
              * check if external name(usr name) is in query definition list
              * if it is, set relative attr in attr list 
              */
             FIfld_get_text (form_ptr, MACRO_FIELD, 0, 0, QUERY_LEN, text1,
                                                  &sel, & pos);
             ii = 0;
             for (i = 0; i < coll_nb; i ++ ) {
                 if(strcmp(text1, AttrNameList[i]) == 0) {
                   for ( j = 0; j < me->qry_list[i].nb_att; j++ ) {
                       FIfld_set_text(form_ptr, ATTRIBUTE_LIST, ii, 0,
                                 me->qry_list[i].desc[j].att_name, FALSE);
                       ii = ii + 1;
                   }
                 }
             }
             if( ii > 0 ) ref_macrolist = TRUE;
             /* if ref_macrolist == FALSE, check if internal name 
              * is in query definiton list 
              */
             if( ref_macrolist == FALSE ) {
                ii = 0;
                for (i = 0; i < coll_nb; i ++ ) {
                 if(strcmp(text1, me->qry_list[i].iname) == 0) {
                   for ( j = 0; j < me->qry_list[i].nb_att; j++ ) {
                     FIfld_get_num_rows (form_ptr, ATTRIBUTE_LIST, &num);
                     for (k=0; k<num; k++) {
                      FIfld_get_text (form_ptr, ATTRIBUTE_LIST, k, 0, 
                                      QUERY_LEN, text2, &sel, & pos);
                      if(strcmp(me->qry_list[i].desc[j].att_name, text2)==NULL)                       {
                         d_flag   =  0;
                         break;                        
                      }
                     }
                     if( d_flag ) {
                       FIfld_set_text(form_ptr, ATTRIBUTE_LIST, ii, 0,
                                 me->qry_list[i].desc[j].att_name, FALSE);
                       ii = ii + 1;
                     }
                         d_flag = 1;
                   } /* for */
                 } /* if */
                } /* for (i */
              } /* if( ref_macrolist == FALSE ) */ 
             if( ii > 0 ) ref_macrolist = TRUE;
            } /* if( me->feet_flag == FALSE ) */
          } /* if((me->locate_flag == FALSE) */

          /* if locate, set EDIT_QRY_TOGGLE = atrr */
          if(me->locate_flag == TRUE) {
             FIg_set_state( form_ptr, ATTR_SYMB_TOGGLE, FALSE);
          }
          /* for direct input and on symb state of toggle */ 
          if(me->locate_flag == FALSE && state) {
              FIfld_get_num_rows (form_ptr, ATTRIBUTE_LIST, &num);
              FIfld_delete_rows (form_ptr, ATTRIBUTE_LIST, 0, num);

              FIfld_get_num_rows (form_ptr, VALUE_LIST, &num);
              FIfld_delete_rows (form_ptr, VALUE_LIST, 0, num);
        
              /*
               * fill the attributes list with the symbology options.
              */
             FIfld_set_text(form_ptr, ATTRIBUTE_LIST, 0, 0, "level", FALSE );
             FIfld_set_text(form_ptr, ATTRIBUTE_LIST, 1, 0, "color", FALSE );
             FIfld_set_text(form_ptr, ATTRIBUTE_LIST, 2, 0, "style", FALSE );
             FIfld_set_text(form_ptr, ATTRIBUTE_LIST, 3, 0, "weight", FALSE );

             FIfld_set_text(form_ptr, ATTRIBUTE_FIELD, 0, 0, " ", FALSE );
             FIfld_set_text(form_ptr, VALUE_FIELD, 0, 0, " ", FALSE );
          } 
 
          /*
           * if not found feet for direct input ( only for attr toggle)
           * or using locate function do following
           */  
       	  count1 = om$dimension_of( varray = me->VDlocObjs );
          if((me->locate_flag == TRUE) ||
             ((ref_macrolist == FALSE) && !state)) {
            
             /* if input name match some class name of located object
              * set object's attr into attr list
              */ 
             if (ref_macrolist == FALSE) {
                FIfld_get_text (form_ptr, MACRO_FIELD, 0, 0, QUERY_LEN, text1,
                                                   &sel, & pos);

        	for( i = 0; i < count1; i++) {
           	   status =
           	   om$get_classname(
                        classname = class_name,
                        objid = me->VDlocObjs[i].obj_id.objid,
                        osnum = me->VDlocObjs[i].obj_id.osnum  );
                   if(strcmp(text1, class_name) == 0)  {
                        ref_locatelist = TRUE;
                        break;
                   } 
                }
              } /* if (ref */

             if ( (ref_locatelist == TRUE) || (me->locate_flag == TRUE)) {
               for(i = 0; i < count1; i++) { 
		/*
		 * get the number of attributes and list of attributes.
		 */

                count = 0;
                vd$get_parameters( sts    = &msg,
                          	   object = &me->VDlocObjs[i].obj_id,
                          	   md_env = &me->VDlocObjs[i].mod_env,
                          	   count  = &count );

                if( !count ) continue;
                list = NULL;
                list=_MALLOC(count,struct ACrg_coll );
                
                status =  
       		vd$get_parameters( sts    = &msg,
                          	   object = &me->VDlocObjs[i].obj_id,
                          	   md_env = &me->VDlocObjs[i].mod_env,
                          	   plist  = list,
                          	   size   = count,
                          	   count  = &count );

                if(status == 1) {
                        
       	          count2 = om$dimension_of( varray = me->VDslist);
                  status =
                  om$vla_set_dimension(  varray =  me->VDslist,
                                         size   =  count2 + count);

 		  for( j = count2; j < count2 + count; j ++ ) {
                     strcpy(me->VDslist[j].name, list[j - count2].name);  
                     me->VDslist[j].desc.type =  list[j - count2].desc.type;
		     if( me->VDslist[j].desc.type == AC_ATTRIB_TEXT ){
                       strcpy(me->VDslist[j].desc.value.att_txt, 
                          	list[j - count2].desc.value.att_txt);
		     }
		     else{
                       me->VDslist[j].desc.value.att_exp = 
                          	list[j - count2].desc.value.att_exp;
		     }
                  }
                }
                _FREE(list) ; 
                    list = NULL;
	     } /* for .. count1 */

	     /*
	      * we have concatenated all the attributes of selected objects.
	      */

             ptr = NULL;
             len = 0;
             /*
	      * truncate the attribute collector names to show only the
	      * the resulting attribute name.
              * (in case attr name like star_atrr:pumb)
              * modify to accept case star_atrr:pumb 4/24/95
	      */
       	     count2 = om$dimension_of( varray = me->VDslist);
             ii = 0;
             for (i=0; i<count2; i++) {
               tname[0] = '\0';
               for(j=0; j<=i; j++) {   
                  FIfld_get_text (form_ptr, ATTRIBUTE_LIST, j, 0, QUERY_LEN,
                                                text, &sel, & pos);

                  len = strlen(me->VDslist[i].name);
                  strcpy(tname, me->VDslist[i].name);
                  tname[len] = '\0';

/*                  ptr = strchr(me->VDslist[i].name,':');
                  len = strlen(me->VDslist[i].name);
                  if( ptr == NULL) {
                       strcpy(tname, me->VDslist[i].name);
                       tname[len] = '\0';
                  }
                  else {
                       strcpy(tname, &ptr[1]);
                       len = strlen(ptr) - 1;
                       tname[len] = '\0';       
                  }
*/
                  if( strcmp(tname, text) == 0) {
                      a_flag = FALSE;
                      break;
                  }
                } /* for (j = 0 ) */
                if(a_flag == TRUE) {
                      FIfld_set_text(form_ptr, ATTRIBUTE_LIST, ii, 0,
                                     tname, FALSE);
                      ii = ii + 1;  
                }
                  a_flag = TRUE;
            } /* for( i = 0 ) */
           } /* if ( ref */
          } /* if((me->locate_flag == TRUE) */ 

          if((me->feet_flag == TRUE) &&((ref_locatelist == FALSE)&& !state)){   
                 for (i=0; i<num_feet; ++i)
                        FIfld_set_text(form_ptr, ATTRIBUTE_LIST, i, 0,
                                                pp_feet[i], FALSE);
          } 
    
        }

        break;

    case ATTRIBUTE_LIST:

        text[0] = '\0';
        FIfld_get_num_rows (form_ptr, ATTRIBUTE_LIST, &num);
        for (i=0; i<num; ++i)
        {
            FIfld_get_select (form_ptr, ATTRIBUTE_LIST, i, 0, &sel);
            if (sel)
            {
                FIfld_get_text (form_ptr, ATTRIBUTE_LIST, i, 0, QUERY_LEN, 
						text, &sel, & pos);
                break;
            }
        }
        FIfld_set_text (form_ptr, ATTRIBUTE_FIELD, 0, 0, text, FALSE);

    case ATTRIBUTE_FIELD:

        FIfld_get_text (form_ptr, ATTRIBUTE_FIELD, 0, 0, QUERY_LEN, text, 
							&sel, & pos);

	while(text[0] == ' ') strcpy(text, &text[1]);

	while(text[strlen(text)-1] == ' ') text[strlen(text)-1] = '\0';


        FIfld_set_text (form_ptr, VALUE_FIELD, 0, 0, "", FALSE);
        switch_state = concatenate = (text[0] != '\0');

        break;

    case NE:
    case EQ:
    case GE:
    case LE:
    case GT:
    case LT:
	text[0] = '\0';
	FIfld_get_num_rows (form_ptr, VALUE_LIST, &num);
	if(num) FIfld_get_text (form_ptr, VALUE_LIST, 0, 0, QUERY_LEN, 
							text, &sel, &pos);
	if(text[0] == '\0')
		FIfld_pos_cursor (form_ptr, VALUE_FIELD, 0, 0, 0, 0, 0, 0);
        
        /* 
         * set value list which from located objects. This list give users
         * a reference.
         */ 

        FIfld_get_text (form_ptr, ATTRIBUTE_FIELD, 0, 0, QUERY_LEN, text,
                                                        &sel, & pos);

        while(text[0] == ' ') strcpy(text, &text[1]);
        while(text[strlen(text)-1] == ' ') text[strlen(text)-1] = '\0';
        count1 = om$dimension_of( varray = me->VDslist);

        FIg_get_state( form_ptr, ATTR_SYMB_TOGGLE, &state);
        if (!state) {
           if(me->locate_flag == FALSE && me->feet_flag == FALSE ) {
               /* check if input name matches with external name 
                * in query definition, if it does, set relative values in 
                * query definition  into value list
                */  
              FIfld_get_text (form_ptr, MACRO_FIELD, 0, 0, QUERY_LEN, text1,
                                                  &sel, & pos);
              ii = 0;
              for (i = 0; i < coll_nb; i ++ ) {
                 if(strcmp(text1, AttrNameList[i]) == 0) {
                   for ( j = 0; j < me->qry_list[i].nb_att; j++ ) {
                      FIfld_get_select (form_ptr, ATTRIBUTE_LIST,j, 0, &sel);
                      if (sel) {
                        FIfld_set_text(form_ptr, VALUE_LIST, ii, 0,
                                 me->qry_list[i].desc[j].value.att_txt, FALSE);
                        ii = ii + 1;
                      }
                   }
                 }
              } /* for */
              if(ii > 0) ref_macrolist = TRUE;
              /* if ref_macrolist = FALSE, check if it match with internal
               * name of query definition
               */
              if( ref_macrolist == FALSE) {
                FIfld_get_text (form_ptr, ATTRIBUTE_FIELD, 0, 0, QUERY_LEN, 
                                     text2, &sel, & pos);
                ii = 0;
                for (i = 0; i < coll_nb; i ++ ) {
                 if(strcmp(text1, me->qry_list[i].iname) == 0) {
                   for ( j = 0; j < me->qry_list[i].nb_att; j++ ) {
                   if(strcmp(text2,me->qry_list[i].desc[j].att_name) == NULL){  
	             FIfld_get_num_rows (form_ptr, VALUE_LIST, &num);
                     for (k=0; k<num; k++) {
                      FIfld_get_text (form_ptr, VALUE_LIST, k, 0,
                                      QUERY_LEN, text3, &sel, & pos);
                      if(strcmp(me->qry_list[i].desc[j].value.att_txt, text3)
                                                                      == NULL)
                        {
                         vd_flag   =  0;
                         break;
                        }
                     } /* (k=0; k<num; k++) */ 

                    if( vd_flag ) {
                        FIfld_set_text(form_ptr, VALUE_LIST, ii, 0,
                                 me->qry_list[i].desc[j].value.att_txt, FALSE);
                        ii = ii + 1;
                    }
                        vd_flag   =  1;
                  } /* if(strcmp(text2 */
                 } /* for */
               } /* if */
              } /* for ( i = */
              if(ii > 0) ref_macrolist = TRUE;
             } /* if( ref_macrolist == FALSE)  */

              /* 
               * if ref_macrolist == FALSE, check if input name match some 
               * of that of located object
               */
       	      count1 = om$dimension_of( varray = me->VDslist );
              if (ref_macrolist == FALSE) {
                for( i = 0; i < count1; i++) {
                   status =
                   om$get_classname(
                        classname = class_name,
                        objid = me->VDlocObjs[i].obj_id.objid,
                        osnum = me->VDlocObjs[i].obj_id.osnum  );
                   if(strcmp(text1, class_name) == 0)  {
                        ref_locatelist = TRUE;
                        break;
                   }
                }
              }
          } /* if (me->locate_flag  == FALSE*/
          if((me->locate_flag == TRUE) || (ref_locatelist  == TRUE))  { 

              /* change  attribute's values with selected attribute,
              * if there are duplication of attribute name, also put
              * its value here
              */
            FIfld_get_num_rows (form_ptr, VALUE_LIST, &num);
            FIfld_delete_rows (form_ptr, VALUE_LIST, 0, num);
            ii = 0;
            for (i=0; i<count1; i++) {
                  tname[0] = '\0';
                  len = strlen(me->VDslist[i].name);
                  strcpy(tname, me->VDslist[i].name);
                  tname[len] = '\0';

/* modify to include the case stat_attr:quip 4/24/95 
                  ptr = strchr(me->VDslist[i].name,':');
                  len = strlen(me->VDslist[i].name);
                  if( ptr == NULL) {
                       strcpy(tname, me->VDslist[i].name);
                       tname[len] = '\0';
                  }
                  else {
                       strcpy(tname, &ptr[1]);
                       len = strlen(ptr) - 1;
                       tname[len] = '\0';
                  }
*/
                  if( strcmp(tname, text) == 0) {
                    FIfld_get_num_rows (form_ptr, VALUE_LIST, &num);
                    for(j=0; j<=num; j++) {
                      /* attribute is value */
                      if( me->VDslist[i].desc.type == AC_ATTRIB_DOUBLE) {
                           FIfld_get_value(form_ptr, VALUE_LIST, j, 0,
                                             &value1, &sel, &pos);
                           if( me->VDslist[i].desc.value.att_exp == value1) {
                             v_flag = FALSE;
                             break;
                           }
                      }
                      else {
                        FIfld_get_text (form_ptr, VALUE_LIST, j, 0, QUERY_LEN,
                                                text1, &sel, & pos);
                        if((strcmp(me->VDslist[i].desc.value.att_txt,text1)==0)
                           && (text1[0] != '\0'))
                        {
                                v_flag = FALSE;
                                break;
                        }
                      }
                   }
                   if(v_flag == TRUE) {
                         if( me->VDslist[i].desc.type == AC_ATTRIB_DOUBLE) {
                           FIfld_set_value(form_ptr, VALUE_LIST, ii, 0,
                                    me->VDslist[i].desc.value.att_exp, FALSE);
                         }
                         else {
                           FIfld_set_text (form_ptr, VALUE_LIST, ii, 0,
                                 me->VDslist[i].desc.value.att_txt, FALSE);
                         }
                         ii = ii + 1;
                   }
                   v_flag = TRUE;
                  } /* if */
             }/* for */
         FIfld_get_text (form_ptr, VALUE_LIST, 0, 0, QUERY_LEN,
                                                text1, &sel, & pos);
         } /* if(me-> */
        } /*if(!state */
        break;

    case VALUE_LIST:
        text[0] = '\0';
        FIfld_get_num_rows (form_ptr, VALUE_LIST, &num);
        for (i=0; i<num; ++i)
        {
            FIfld_get_select (form_ptr, VALUE_LIST, i, 0, &sel);
            if (sel)
            {
                FIfld_get_text (form_ptr, VALUE_LIST, i, 0, QUERY_LEN, text, 
							&sel, & pos);
                break;
            }
        }
        FIfld_set_text (form_ptr, VALUE_FIELD, 0, 0, text, FALSE);

    case VALUE_FIELD:
        FIfld_get_text (form_ptr, VALUE_FIELD, 0, 0, QUERY_LEN, text, 
							&sel, & pos);
        switch_state = concatenate = (text[0] != '\0');
        break;

    case AND_CHECK:
    case AND_NOT_CHECK:
    case OR_CHECK:
    case OR_NOT_CHECK:
    case XOR_CHECK:
            FIfld_get_text (form_ptr, MACRO_FIELD, 0, 0, QUERY_LEN, text1, 
          					  &sel, & pos);
            ii = 0;
            for (i = 0; i < coll_nb; i ++ ) {
                 if(strcmp(text1, AttrNameList[i]) == 0) {
                   for ( j = 0; j < me->qry_list[i].nb_att; j++ ) {
                       FIfld_set_text(form_ptr, ATTRIBUTE_LIST, ii, 0, 
                                 me->qry_list[i].desc[j].att_name, FALSE); 
                       ii = ii + 1;
                   }
                 } 
            }
                   
	FIfld_pos_cursor (form_ptr, ATTRIBUTE_FIELD, 0, 0, 0, 0, 0, 0);
        FIfld_set_text (form_ptr, VALUE_FIELD, 0, 0, "", FALSE);
        FIfld_set_text (form_ptr, ATTRIBUTE_FIELD, 0, 0, "", FALSE);
	break;


    case LOCATE_OBJECT:

	 concatenate = FALSE;
         switch_state = FALSE;

         dp$erase_hilite (msg = &sts);
         me->rep_label = VD_LOCATE_OBJECT;
         _put_response (resp = VD_LOCATE_STATUS);

         /* set size = 0 before locate */
         status =
         om$vla_set_dimension(  varray =  me->VDslist,
                                size   =  0);
         status =
         om$vla_set_dimension(  varray =  me->VDlocObjs,
                                size   =  0);
        
         me->locate_flag = TRUE;         
         me->macro_field = FALSE;         
         me->feet_flag = TRUE;         
         me->locate_wakeup = FALSE;         
	 FIg_disable(form_ptr, MACRO_LIST );
	 FIg_disable(form_ptr, MACRO_FIELD );

	 /* added by alwin, TR#: 179601572 Date : 5/24/96 */
	 SMVA_disable(form_ptr, 8, FI_RESET, FI_CANCEL, QUERY_CMD_SAVE,
			QUERY_CMD_LOAD, QUERY_CMD_DELETE, MACRO_FIELD,
			LOCATE_OBJECT, BACKUP_BUTTON );
	 /* added by alwin, TR#: 179601572 Date : 5/24/96 */

         break;

    case FI_RESET:
       	
                UI_status("");

		status =
        	om$send(msg = message VDCmdQYnpt.init_query(),
                	targetid = my_id );

		status =
		om$send(msg = message VDCmdQYnpt.wakeup_query( ),
			targetid = my_id );

       	  	count1 = om$dimension_of( varray = me->VDlocObjs );
         	
		status =
         	om$vla_set_dimension(  varray =  me->VDslist,
                                size   =  0);
         
		status =
         	om$vla_set_dimension(  varray =  me->VDlocObjs,
                                size   =  0);
        	me->locate_flag = FALSE;         
        	switch_state = FALSE;
        	concatenate = FALSE;

        break;

    case BACKUP_BUTTON:

	status =
        om$send ( msg = message VDCmdQYnpt.back_up_query(),
                  targetid = my_id );

        switch_state = FALSE;
        concatenate = FALSE;
        break;

    case FI_EXECUTE :
    case FI_ACCEPT : 
        
	switch_state = FALSE;
	concatenate = FALSE;

       	UI_status("");
        FIfld_set_text( form_ptr, 10, 0, 0, "", FALSE );

        FIg_get_state( form_ptr, EDIT_QRY_TOGGLE, &state);
        if(  state ){ /* for edit query case */

                /* get query from definition field  */
                if( ! VDqry_get_text( form_ptr, EDIT_QUERY, query ) ){
                        UI_status(" Query buffer too small " );
                        break;
                }

                tmpquery = NULL;
                VDmalloc_str_list(&tmpquery, 1, Qrylistlen);
                for( i=0 ; i<1 ; i++ ){
                  tmpquery[i][0] = '\0';
                  strcpy(tmpquery[i], query);
                }

                /* check syntax */
                status =
                om$send(msg = message VDCmdQYnpt.query_check(
                             tmpquery, 1),
                             targetid = my_id );
                CheckRC( status, 1 );

                /*      as$status(); */

 		VDfree_str_list(tmpquery, 1);

                if(status == 0) {
                       FIfld_set_text( form_ptr, 10, 0, 0, "Query Syntax Error", 				       FALSE );
                       UI_status(" Query Syntax Error" );
                       break;
                }

                /*
                * get the query name.
                */
                name[0] = '\0';
         	FIfld_get_text( form_ptr, NEW_NAME, 0, 0, QUERY_LEN, name,
                        					&sel, & pos);
         	while(name[0] == ' ') strcpy(name, &name[1]);

                /* if name = '   ' */
                if( num = strlen( name ) == 0 ){
                        UI_status(" Define query name ");
                        FIg_set_text( form_ptr, MESSAGE, "Define query name" );
                        break;
                }

                /* 
                 * comparing oldname and newname, if there are same and the 
                 * query is in design file, delete old one, the new one is 
                 * added late.
                 */
                if ( me->isdesignfile) {
                  /* get current space num */
                  status =
                  ex$get_cur_mod( osnum   = &cur_os );
 
		   nbRows  = om$dimension_of( varray = me->queries );

                   strcpy( gvName, VD_qry_nmName );

                   for ( j = 0; j < nbRows; j ++) {
                       status =
                       om$send(msg = message NDmacro.ACgive_structure(
                                                        &rc,          /* out */
                                                        &directIndex, /* int */
                                                        gvName,       /* in  */
                                                        &retStr,      /* out */
                                                        &mdEnv ),     /* out */
                                mode     = OM_e_wrt_message,
                                targetid = me->queries[j].objid,
                                targetos = me->queries[j].osnum );
                       as$status();

                       if(!strcmp( name, retStr.var.text_st.text_string)) {
                           if( cur_os == me->queries[j].osnum ){
                           status =
                           om$send(msg = message ACrg_collect.NDdelete(&mdEnv),
                                targetid = me->queries[j].objid,
                                targetos = me->queries[j].osnum,
                                senderid = NULL_OBJID );
                           as$status();
            		
                           sprintf(text," The query <%s> is overwritten", name);
            		   UI_status(text);
                           FIfld_set_text( form_ptr,10,0,0, text,FALSE);

                           break;
                           }
                        }
                   } /* for j */
         	} /* if */
                else { 
                   /* 
                    * query is in ref file,check if there are same name 
                    * in the design file 
                    */

          	  /* get current space num */
          	  status =
          	  ex$get_cur_mod( osnum   = &cur_os );

          	  /* get current filename which is used for name check.
           	   * we want to keep name unique in the current file.
                   * we can have same query name with diff file name
                  */
          	  fullname[0] = '\0';
          	  filename[0] = '\0';

                  sts1 = VDget_filename_from_os( cur_os, filename );
                  if ( !(1&sts1) ) {
                   FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
                   FIfld_set_text( form_ptr,10,0,0,"Not found File Name",FALSE);
                   break;
                  }

                  sprintf(fullname, "%s[%s]", name,filename);
                  __DBGpr_str( " fullname ", fullname);
                  FIfld_get_list_num_rows( form_ptr, QUERY_NAME, 0, &num );

                  for( i=0 ; i<num ; i++ ){

                    FIfld_get_list_text(    form_ptr,
                                        QUERY_NAME,
                                        i,
                                        0,
                                        QUERY_LEN,
                                        buffer,
                                        &sel );

                    if ( strcmp( buffer, fullname ) == 0 ){
                        /*
                         * duplicate of name.
                         */
                       UI_status(" The name exists in design file" ); 
                       FIfld_set_text( form_ptr,10,0,0,
                                       "The name exists in design file",FALSE);
                       dupflag = TRUE;
                       break;
                    }
                  }
                 
                  if ( dupflag ) break;           

	        } 
        }
        else {  /* not edit query */
                if( ! VDqry_get_text( form_ptr, QUERY, query ) ){
                        UI_status(" Query buffer too small " );
                        FIg_set_text( form_ptr, MESSAGE, 
                                    "Query buffer too small" );
                        break;
                }

                /*
                * get the query name.
                */
                name[0] = '\0';
                FIfld_get_text( form_ptr, QUERY_NAME, 0, 0, QUERY_LEN, name,
                        &sel, & pos);

                if( num = strlen( name ) == 0 ){
                        UI_status(" Define query name ");
                        FIg_set_text( form_ptr, MESSAGE, "Define query name" );
                        break;
                }

                  /* get current space num */
                  status =
                  ex$get_cur_mod( osnum   = &cur_os );

                  /* get current filename which is used for name check.
                   * we want to keep name unique in the current file.
                   * we can have same query name with diff file name
                  */
                  fullname[0] = '\0';
                  filename[0] = '\0';

                  sts1 = VDget_filename_from_os( cur_os, filename );
                  if ( !(1&sts1) ) {
                   FIfld_set_text( form_ptr, QUERY_NAME,0,0,"",FALSE);
                   FIfld_set_text( form_ptr,10,0,0,"Not found File Name",FALSE);
                   break;
                  }

                  sprintf(fullname, "%s[%s]", name,filename);
                  __DBGpr_str( " fullname ", fullname);
                  FIfld_get_list_num_rows( form_ptr, QUERY_NAME, 0, &num );

                  for( i=0 ; i<num ; i++ ){

                    FIfld_get_list_text(    form_ptr,
                                        QUERY_NAME,
                                        i,
                                        0,
                                        QUERY_LEN,
                                        buffer,
                                        &sel );

                    if ( strcmp( buffer, fullname ) == 0 ){
                        /*
                         * duplicate of name.
                         */
                       UI_status(" The name exists in design file" );
                       FIfld_set_text( form_ptr,10,0,0,
                                       "The name exists in design file",FALSE);
                       dupflag = TRUE;
                       break;
                    }
                  }
                  if (dupflag) break;
        }
        /*
         * get the comments field.
         */
        if(!( VDqry_get_text( form_ptr, QUERY_DESCRIPTION, comment ))){
                        /*
                        * comment buffer to small.
                        */
                        UI_status( " No comments please " );
        }

	/*
	 * create the query.
	 */
	qryId.objid = NULL_OBJID;
	qryId.osnum = me->ModuleInfo.md_id.osnum;

	VDqry_create_object( &msg, &qryId, name, query, comment );

	if( qryId.objid == NULL_OBJID && (! (msg&1)) ){
		/*
		 * error in construction.
		 */
		UI_status( " Error during construction query object" );
		break;
	}

	if( gadget_label == FI_ACCEPT ){
        	status = 
        	om$send(msg = message CEO.erase_form_by_label(
						form_label, 0, &sts ),
                	targetid = my_id );
                status =
                om$vla_set_dimension(  varray =  me->VDlocObjs,
                                size   =  0);
                status =
                om$vla_set_dimension(  varray =  me->VDslist,
                                size   =  0);
                _put_response(  resp = EX_FORM_FINISHED );
	}
	else  { 
          status =
          om$send(msg = message VDCmdQYnpt.init_query(),
                targetid = my_id );

          status =
          om$send(msg = message VDCmdQYnpt.wakeup_query( ),
                targetid = my_id );

          if(state) { /* for edit query on */
             VDqry_clr_display(form_ptr, QUERY );
             VDqry_clr_display(form_ptr, EDIT_QUERY );
             VDqry_clr_display(form_ptr, NEW_NAME);
             VDqry_clr_display(form_ptr, QUERY_NAME);
             VDqry_clr_display(form_ptr, QUERY_DESCRIPTION);
             VDqry_clr_display(form_ptr, 10);
            
             FIg_set_state( form_ptr, EDIT_QRY_TOGGLE, TRUE);
 
             FIg_erase(form_ptr, QUERY_TITLE);
             FIg_erase(form_ptr, QUERY);

             FIg_set_color(form_ptr,EDIT_QUERY_TITLE, FI_BLUE);
             FIg_set_color(form_ptr,QUERY_NAME_TITLE, FI_BLUE);
             FIg_set_color(form_ptr,QUERY_DESCR_TITLE, FI_BLUE);
             FIg_set_color(form_ptr,NEW_NAME_TITLE, FI_BLUE);

             FIg_display(form_ptr, EDIT_QUERY_TITLE);
             FIg_display(form_ptr, EDIT_QUERY);
             FIg_display(form_ptr, NEW_NAME_TITLE);
             FIg_display(form_ptr, NEW_NAME);
             FIg_display(form_ptr, QUERY_NAME_TITLE);
             FIg_display(form_ptr, QUERY_DESCR_TITLE);

             FIg_disable(form_ptr, EDIT_QUERY);
             FIg_disable(form_ptr, QUERY_DESCRIPTION);
             FIg_disable(form_ptr, NEW_NAME);

                FIg_disable( form_ptr, MACRO_LIST );
                FIg_disable( form_ptr, MACRO_FIELD);
                FIg_disable(form_ptr, QRY_GRP_WHERE );
                FIg_disable(form_ptr, QRY_GRP_ATTR );
                FIg_disable(form_ptr, ATTR_SYMB_TOGGLE);
                FIg_disable(form_ptr, QRY_GRP_COND );
                FIg_disable(form_ptr, QRY_GRP_VALUE );
                FIg_disable(form_ptr, QRY_GRP_CONJ );
                FIg_disable( form_ptr, BACKUP_BUTTON );
                FIg_disable(form_ptr, FI_EXECUTE );
                FIg_disable(form_ptr, FI_ACCEPT );
                FIg_disable( form_ptr, LOCATE_OBJECT);
                FIg_enable(form_ptr, FI_CANCEL );
                FIg_enable(form_ptr, FI_RESET );
 
 
	  }
        }
	break;
        
    case FI_CANCEL: 
	/*
	 * Erase and reset the form, this will also reset query state
	 */
        status = 
        om$send(msg = message CEO.erase_form_by_label(
					form_label, 0, &sts ),
                targetid = my_id );

        _put_response(  resp = EX_FORM_FINISHED );
         status =
         om$vla_set_dimension(  varray =  me->VDlocObjs,
                                size   =  0);

         status =
         om$vla_set_dimension(  varray =  me->VDslist,
                                size   =  0);
        break;

 } /* switch */

 /*
  * do end processsing before leaving the form.
  */
 if( concatenate ){

	status =
        om$send(msg = message VDCmdQYnpt.add_to_query (gadget_label),
                targetid = my_id );

 }
        
 if( switch_state ){
/* used for Querydef

        FIfld_get_text (form_ptr, VALUE_FIELD, 0, 0, QUERY_LEN, text, 
							&sel, & pos);

	if(	me->query_state == 1 &&
		text[0] != '\0' ) 		me->query_state = 5;

        else
*/
		me->query_state =
			(me->query_state == 5) ? 2 : me->query_state + 1;

	status =
        om$send(msg = message VDCmdQYnpt.switch_query_state 
                                            (me->query_state, TRUE),
                targetid = my_id );
 }
 else if( back_up ){

	status =
        om$send(msg = message VDCmdQYnpt.back_up_query (),
                targetid = my_id );
 }
        
 quit:

 End
 return (OM_S_SUCCESS);
}

/* ------------------------------------------------------------------------ */

int InitElemType(struct ElemType *str)
{
int	i;

	str->selected = 0;
	str->user_name[0] = '\0';
	str->real_name[0] = '\0';
	str->nb_att = 0;
	for(i=0;i<MAX_NB_ATT;i++) InitAttrDef(&str->att[i]);

	return 1;
}

/* ------------------------------------------------------------------------ */

int InitAttrDef(struct AttrDef	*str)
{
	str->name[0] = '\0';
	str->nb_value = 0;
	str->value = NULL;

	return 1;
}

/* ------------------------------------------------------------------------ */
int FreeAttrDef(struct AttrDef	*str)
{
int	i;

	if(! str->nb_value) return 1;

	if(str->value) {
		for(i=0;i<str->nb_value;i++) {
			_FREE(str->value[i]);
				str->value[i] = NULL;
                }
		_FREE(str->value);
		str->value = NULL;
	}

	return 1;
}

/* ------------------------------------------------------------------------ */
int FreeElemType(struct ElemType *str)
{
int	i;

if(! str->nb_att) return 1;

for(i=0;i<str->nb_att; i++)
	FreeAttrDef(&str->att[i]); 


return 1;
}

/******************************************************************************

Function:
    
	IsElemType

Description:

    This function reads from the input buffer the name and classname.
    It is called by the function VDqry_ReadFile to read the first line of 
    each written element (NAME: element_type (macro_name) )

******************************************************************************/


IsElemType(buffer, name, class_name)
IGRchar 	*buffer;
IGRchar 	*name;
IGRchar 	*class_name;
{
IGRchar		*text, tmp[QUERY_LEN], *next;

name[0] = '\0';
class_name[0] = '\0';

if(strncmp(buffer,"NAME:", 5) == 0 ){

	text = &buffer[5];
	
	if( VDSGetNextWord(text, tmp, QUERY_LEN, '(', &next) == 0){
		printf("ERROR VDSGetNextWord\n");
		return 0;
	}
	if(tmp[0] == '\0' && next == NULL ) return (1);

	if(tmp[0] != '\0') strcpy(name, tmp);
	if(next == NULL){
		strcpy(class_name,tmp);
		return (1);
	}
	while(next[0] == ' ' || next[0] == '\t' ) strcpy(next, &next[1]);
	while(next[strlen(next) - 1] ==')' || next[strlen(next) - 1] == ' ' ||
			next[strlen(next) - 1] == '\t') 
		next[strlen(next) - 1] = '\0';


	strcpy(class_name, next);

}

else return(0);

return (1);

}
/******************************************************************************

Function:
    
	VDqry_ReadFile

Description:

	This function reads the file (VDS/config/QueryDef) and
	fills the name convention for the user defined name and the object
	name.


******************************************************************************/


int VDqry_ReadFile(file_name, nb_elt, element)
IGRchar			*file_name;
IGRint			*nb_elt;
struct ElemType		**element;
{
char			name[QUERY_LEN],
			class_name[QUERY_LEN], 
			buffer[QUERY_LEN];
FILE			*pf;
int			i, k, count, list, len1, NEWNAME;
struct ElemType		*myelem;


        SetProc( VDCmdQYnpt.VDqry_ReadFile ); Begin

	(*nb_elt) = -1;
	myelem = NULL;
	(*element) = NULL;
	NEWNAME = 0;

	pf = NULL;
	vd$openfile(	file_name 	= file_name,
			product_name 	= "Vds",
			sub_path 	= "config",
			cur_dir 	= TRUE,
			p_file 		= &pf);
	if(pf == NULL){
  		/* printf("file [%s] not found\n",file_name); */
 	 	return (1);
	}

	count = 5;
	myelem = _MALLOC(count,struct ElemType);
	if(!myelem){
		printf("Bad allocation\n");
		goto wrapup;
	}

	for(i=0;i<count;i++) InitElemType(&myelem[i]);

	list = 0;
	while (fgets(buffer,QUERY_LEN-1,pf) != NULL){

  		/* enleve les tabulations et les fins de lignes */

  		if (buffer[0] == '#') continue;

  		while(buffer[0] == '\t' || buffer[0] == ' ')
			strcpy(buffer, &buffer[1]);

  		len1 = strlen(buffer);
  		if(len1 < 1) continue;

  		while( buffer[len1-1] == '\t' || buffer[len1-1] == '\n' ){
    			buffer[len1-1] = '\0';
    			len1 = strlen(buffer);
   		}

  		if(len1 < 1) continue;

		/* take element name */

		if( IsElemType(buffer, name, class_name)){

			if(name[0] == '\0' || class_name[0] == '\0') {
				NEWNAME = 0;
				continue;
			}
			NEWNAME = 1;
			(*nb_elt) ++;
			if( (*nb_elt) >= count ){
				count = count+5;
				myelem = _REALLOC(myelem, 
					count,struct ElemType);
 				if(!myelem){
					printf("Bad allocation\n");
					goto wrapup;
 				}

 				for(i=(*nb_elt);i<count;i++)
					InitElemType(&myelem[i]);

			}

			/* fill name */

			strcpy(myelem[*nb_elt].user_name, name);
			strcpy(myelem[*nb_elt].real_name, class_name);
			myelem[*nb_elt].nb_att = 0;
			continue;			
		}

		if( NEWNAME == 0) continue;

  		/* get the attribute and its default values */

		if( GetAttAndValues(buffer, 
			&myelem[*nb_elt].att[myelem[*nb_elt].nb_att]) != 1){
			printf("ERROR GetAttAndValues\n");
			goto wrapup;
		}

 		myelem[*nb_elt].nb_att ++;
		continue;
	
  		

	}/* while EOF */

	if(pf) fflush(pf);
	if(pf)fclose(pf);

	(*nb_elt) ++;

	if( (*nb_elt) ){

	    (*element) = _MALLOC( (*nb_elt),struct ElemType);
 	    if(!(*element) ){
		printf("Bad allocation\n");
		goto wrapup;
 	    }

	    for(i=0;i<(*nb_elt);i++) InitElemType(&( (*element)[i] ));
	    for(i=0;i<(*nb_elt);i++){
		strcpy((*element)[i].user_name, myelem[i].user_name);
		strcpy((*element)[i].real_name, myelem[i].real_name);
		(*element)[i].nb_att = myelem[i].nb_att;
		for(k=0;k<myelem[i].nb_att;k++){
			strcpy( (*element)[i].att[k].name,  
					myelem[i].att[k].name);
			(*element)[i].att[k].nb_value = 
						myelem[i].att[k].nb_value;
			(*element)[i].att[k].value = 
						myelem[i].att[k].value;
		}

	    }
	}


	_FREE(myelem) ;
            myelem = NULL;
        End
	return (1);

wrapup:

	if(myelem){
		for(i=0;i<count;i++) 
                        FreeElemType( &myelem[i]);
		_FREE(myelem); 
                 myelem = NULL;
	}
	_FREE(*element) ; 
             (*element) = NULL;
	*nb_elt = 0;
	
	if(pf) fflush(pf);
	if(pf)fclose(pf);
        End
	return (0);
}

/******************************************************************************

Function:
    
    GetAttAndValues

Description:

    This function scans the input buffer and fills the structure att


******************************************************************************/


int GetAttAndValues(buffer, att)
IGRchar		*buffer;
struct AttrDef	*att;
{
IGRint			i,
			nb_part,
			count;
IGRchar			*text,
			tmp[QUERY_LEN],
			**word;
  SetProc( VDCmdQYnpt.GetAttAndValues ); Begin

  count = 0;
  nb_part = 0;
  word = NULL;

  InitAttrDef(att);

  if(buffer[0] == '\n' || buffer[0] == '\0') goto wrapup;

  /* get the attribute name */


  if( VDSGetNextWord(buffer, tmp, QUERY_LEN, '(', &text) == 0){
		printf("ERROR VDSGetNextWord\n");
		goto wrapup;
  }

  if(text == NULL){

	/* look also for a '=' */

	if( VDSGetNextWord(buffer, tmp, QUERY_LEN, '=', &text) == 0){
		printf("ERROR VDSGetNextWord\n");
		goto wrapup;
	}
	if(text != NULL){
		strcpy(att->name, tmp);
		att->nb_value = 1;
		att->value = NULL;
		att->value = _MALLOC(1 ,IGRchar *);
		if(!att->value){
			printf("Bad memory allocation \n");
			goto wrapup;
		}
		att->value[0] = NULL;
		att->value[0] = _MALLOC( 
				(1 + strlen(text)) ,IGRchar );
		if(!att->value[0]){
			printf("Bad memory allocation \n");
			goto wrapup;
		}
		strcpy(att->value[0], text);
		return(1);
	}

	strcpy(att->name, buffer);
	return (1);
  }
	
  strcpy(att->name, tmp);


	/* get the values of the attribute */

  count = 5;

  word = _MALLOC(count,IGRchar *);
  if(!word){
	printf("Bad memory allocation \n");
	goto wrapup;
  }
  for(i=0;i<count;i++) word[i] = NULL;
  for(i=0;i<count;i++) {
	word[i] = _MALLOC(QUERY_LEN ,IGRchar );
	if(!(word[i] )){
		printf("Bad memory allocation \n");
		goto wrapup;
	}
  }

  nb_part = 0;
  while(text != NULL ){

	if(nb_part >= count){
		count = count + 5;
		word = _REALLOC(word, count, IGRchar *);
		if(!word){
			printf("Bad memory allocation \n");
			goto wrapup;
		}
		for(i=nb_part;i<count;i++) word[i] = NULL;
		for(i=nb_part;i<count;i++) {
			word[i] = _MALLOC(
					QUERY_LEN, IGRchar );
			if(!(word[i] )){
				printf("Bad memory allocation \n");
				goto wrapup;
			}
		}
	}

	strcpy(tmp, text);
	if( VDSGetNextWord(tmp, word[nb_part], QUERY_LEN, ',', &text) == 0){
		printf("ERROR VDSGetNextWord\n");
		goto wrapup;
	}
	if(word[nb_part][0] == '\0') continue;
	nb_part++;
  }

  if( word[nb_part-1][strlen(word[nb_part-1]) - 1] == ')' ) 
	word[nb_part-1][strlen(word[nb_part-1]) - 1] = '\0';

  if(word[nb_part-1][0] == '\0') nb_part --;

  att->nb_value = nb_part;
  att->value = word;

#ifdef DEBUG
   PrintAtt(att);
#endif

  End
  return 1;

wrapup:

  if(word) {
	for(i=0;i<count;i++) {
		_FREE(word[i]); 
                 word[i] = NULL;
        }
	_FREE(word); 
         word = NULL;
  }
  InitAttrDef(att);

  End
  return 0;
}


/******************************************************************************

Method:
    wakeup_query

Description:
    This method initialized the query form (VDquery1).

verride:
    from CEO form_notification

History:
    10/6/94   	yzhu   		modified    

******************************************************************************/
method wakeup_query( )
{
IGRint			status = OM_S_SUCCESS ;
Form			form_ptr;
IGRlong			msg;
GRspacenum		cur_os;
IGRchar			*ptr;
IGRint     		i, ii,
			gadget,
			sts,
			directIndex = 0,
			num;
GRname			gvName,
                        objName;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;
struct	GRid		dirId;
int			nbAct;
IGRchar                 *pSelect,
                        *pWhere,
                        buffer[8*QUERY_LEN],
                        name[QUERY_LEN],
                        select[QUERY_LEN],
                        where[QUERY_LEN];
IGRchar                 *act_qry_name_list[QUERY_LEN];
IGRchar                 ttmp[QUERY_LEN], new_temp[QUERY_LEN] ;
IGRint                  act_qry_count;
IGRint			len; 
IGRint			k,j, nbRows,rtj;
IGRchar 		*ptr1;
IGRint			num1,sortnum; 
struct Qry_list         *tmpqrylist;
/*IGRchar                 **tmpqrylist;  change 1/5/96 */
IGRint  		d_flag = TRUE, sel, pos, state;
IGRchar                 fullname[QUERY_LEN], filename[QUERY_LEN];
IGRlong                 sts1; 
GRname                  fullqryname;
IGRint			actSt = 0;
IGRchar                 activeFile[QUERY_LEN];

        SetProc( VDCmdQYnpt.wakeup_query ); Begin
	msg = MSSUCC ;

       /*
        *  if stack is empty,  stop to do any thing
        */
	if( ex$is_cmd_stack_empty()  && me->mytype == 1 ){
          /* CO id and my id not the same */

	  UI_status (" NO command on stack ");

          me->qry_delete_flag = 1 ;
          me->state = _terminate;
          return( OM_I_STOP_SENDING );
        }
        new_temp[0] = '\0';

	form_ptr = me->forms[0].form_ptr;

	/*
	 * find the existing query objects.
	 */
        status =
        ex$get_cur_mod( osnum   = &cur_os );

        di$give_pathname( osnum = cur_os, pathname = me->qry_dir );

        __DBGpr_str( " pathname is %s\n", me->qry_dir );

        strcat( me->qry_dir, ":" );
        strcat( me->qry_dir, QRY_str_DIR_NAME );

	dirId.objid = NULL_OBJID;
        status = di$translate(  objname = me->qry_dir,
                                p_objid = &dirId.objid,
                                p_osnum = &dirId.osnum );
        if( !(status&1) || dirId.objid == NULL_OBJID ){
                dirId.objid = NULL_OBJID;

                status = di$mkdir(    dirname = me->qry_dir,   
                                      p_dirid = &dirId.objid,
                                      p_osnum = &dirId.osnum );
                if( !(status&1 ) )
                  status = di$translate(  objname = me->qry_dir,
                                          p_objid = &dirId.objid,
                                          p_osnum = &dirId.osnum );

                if( !(status&1 )||( dirId.objid == NULL_OBJID )){
                        ex$message(     msgnumb = VD_S_CanCrea,
                                        type = "%s",
                                        var = `me->qry_dir` );
                        return( OM_E_ABORT );
                }
        }

        /*
         * copy to instance.
         */
        me->qry_dirId = dirId ;


	/*
	 * create the list in the name list.
	 */
	status =
	om$send(msg = message VDCmdQYnpt.create_list( &msg ),
		targetid = my_id );
	as$status( );

	num = om$dimension_of(   varray  = me->queries );
	/*
	 * reset list to null
	 */
	gadget = ( me->mytype == QRY_COB_CRT ) ? QUERY_NAME : QRY_SEL_EXIST ;

	if( me->mytype == QRY_COB_CRT ){
	
        	/*  create state.  */
		FIfld_set_list_num_rows( form_ptr, gadget, 0, 0 );
	}
	else{
		/*  execute state.  */
		VDqry_clr_display(	form_ptr, QRY_SEL_EXIST );
		VDqry_clr_display(	form_ptr, QRY_SEL_ACTIVE );
		VDqry_clr_display(      form_ptr, QRY_SEL_DESC );
		VDqry_clr_display(      form_ptr, QRY_SEL_DEF );

		FIfld_set_num_rows( form_ptr, gadget, num );
	}

        sortnum = 0;

	ii=0;
	strcpy( gvName, VD_qry_nmName );

	for( i=0 ; i<num ; i++ ){

		status = 
		om$send(msg = message NDmacro.ACgive_structure(
						&sts,
                                                &directIndex,
                                                gvName,
                                                &retStr,
                                                &mdEnv ),
	                mode     = OM_e_wrt_message,
			targetid = me->queries[i].objid,
			targetos = me->queries[i].osnum );

	        if(! ( status & sts & 1 )){

			/*
			 * query does not have a name.
			 */

			objName[0] = '\0';
			status =
			om$send(msg = message GRgraphics.GRgetname(
						&msg,
						objName ),
				targetid = me->queries[i].objid,
				targetos = me->queries[i].osnum );
			if( !( status & msg & 1 )){
				/* do not treat object.  */
				continue;
			}

			ptr = strrchr( objName, ':' );
			ptr = ptr ? ptr+1 : objName ;

			status = 
			om$send(msg = message VDquery.VDname_query(
							&msg, ptr ),
				targetid = me->queries[i].objid,
				targetos = me->queries[i].osnum );
			if( !( status & msg & 1 )){
				/* do not treat object.  */
				continue;
			}

			/*
			 * recall the object to get the name.
			 */
			status = 
			om$send(msg = message NDmacro.ACgive_structure(
					                &sts,
                                                        &directIndex,
                                                        gvName,
                                                        &retStr,
                                                        &mdEnv ),
			        mode     = OM_e_wrt_message,
				targetid = me->queries[i].objid,
				targetos = me->queries[i].osnum );
			if( !( status & sts & 1 )){
				/*
				 * do not treat object.
				 */
				continue;
			}
		}

                /* set up qry_sortlist */
        	status =
        	om$vla_set_dimension(   varray = me->qry_sortlist,
                	                size   = sortnum + 1 );
		as$status( action= RET_STATUS );

                me->qry_sortlist[sortnum].name[0] = '\0'; 
                strcpy( me->qry_sortlist[sortnum].name, 
                        retStr.var.text_st.text_string); 
                
                /* 1/5/96 add for TR179600019 */
                me->qry_sortlist[sortnum].filename[0] = '\0';
                sts1 =
                VDget_filename_from_os( me->queries[i].osnum, filename );
                if ( !(1&sts1) ) { 
		         sortnum = sortnum + 1;
                         continue;
                }
                strcpy(me->qry_sortlist[sortnum].filename, filename);  
		sortnum = sortnum + 1;

	} /* for i */
        if( num == 0)  {
              om$vla_set_dimension(   varray = me->qry_sortlist,
               	                      size   = 0 );
        }

        /*
         * put list into a tmp list in order to use qsort.
         */

        num1 = 0;
	num1 = om$dimension_of(   varray  = me->qry_sortlist );
        if( num1 == 0) goto jump1; 
        
        tmpqrylist = NULL;
        tmpqrylist = _MALLOC(num1,struct Qry_list);

        for( i=0 ; i<num1 ; i++ ){
           tmpqrylist[i] = me->qry_sortlist[i];
        }

        qsort ( tmpqrylist, num1, sizeof (struct Qry_list ),
                (int (*) ()) my_strcmpQrylist);
        /* 
         * put shorted list into me->qry_sortlist
         */
        for( i=0 ; i<num1 ; i++ ){
           me->qry_sortlist[i] = tmpqrylist[i];

#ifdef DEBUG    
           printf(" me->qry_sortlist.name = %s\n",
                   me->qry_sortlist[sortnum].name);
#endif  
        }


        /*
	 * display the name in the form. 
         * modify for TR179600019: include the file name in query name
         */

        VDget_filename_from_os( cur_os, activeFile );
	FIg_get_state( form_ptr, QRY_SEL_FILE_OPT_TOGGLE, &actSt );

	ii = 0;
        for( i=0 ; i<num1 ; i++ ){
            sprintf(fullqryname, "%s[%s]", me->qry_sortlist[i].name,
                                          me->qry_sortlist[i].filename); 
            if( me->mytype == QRY_COB_CRT ){
                  FIfld_set_list_default_text(  form_ptr,
                              gadget, i, 0, fullqryname, FALSE);
             }
             else{
		  if(actSt && strcmp(activeFile, me->qry_sortlist[i].filename))
		  {
			continue;
		  }
                  FIfld_set_text( form_ptr, gadget, ii, 0, fullqryname, FALSE );
		  ii++;
             }
        }

        _FREE(tmpqrylist); 
        tmpqrylist = NULL;

jump1: 
        /* set sort toggle = off and sort list disable as default */
         FIg_set_state_off( form_ptr, QRY_SEL_SORT_LIST_TOGGLE) ;
         FIg_disable(form_ptr, QRY_SEL_SORT_LIST);
 
        /* test if there are previous defined query names 
         * if it does, find relative id of active queries
         */  
        
        new_temp[0] = '\0';
        act_qry_count = 0;

        __DBGpr_str( " VDQYnpt_query_list ", VDQYnpt_query_list);
        if ( VDQYnpt_query_list[0] != '\0') {
           ttmp[0] = '\0'; 
           ii = 0;
           strcpy( ttmp, VDQYnpt_query_list);
           len = strlen(ttmp);
           
           while( len != NULL){
             ptr1 = strchr(ttmp,';');
             if(ptr1 == NULL) break;
             else {
                len = len - strlen(&ptr1[0]);
                act_qry_name_list[ii] = NULL; 
                act_qry_name_list[ii] = 
                         _MALLOC((len+1) , char);
                act_qry_name_list[ii][0] = '\0';
                strncpy(new_temp, ttmp, len);
                new_temp[len] = '\0';
                strcpy( act_qry_name_list[ii], new_temp );
                new_temp[0] = '\0';
                ii = ii + 1;
                ttmp[0] = '\0';
                strcpy(ttmp, &ptr1[1]);
                len = strlen(ttmp);
            }
           } /* while */
           act_qry_count = ii;  
           __DBGpr_int( " act_qry_count ", act_qry_count);
           nbRows  = om$dimension_of( varray = me->queries );
           __DBGpr_int( " nbRows ", nbRows);
           nbAct   = 0;
           strcpy( name, VD_qry_nmName );
           VDqry_clr_display(      form_ptr, QRY_SEL_ACTIVE );

           __DBGpr_int( " nbAct ", nbAct);
           status =
           om$vla_set_dimension(   varray = me->act_queries,
                                   size   = nbAct + 1 );
           ii = 0;
           for( i = 0; i < act_qry_count; i ++ ) {
              for (j = 0; j < nbRows; j ++ ) {
                        IGRint  dirIndex = -1;
                        struct  GRmd_env        mdEnv;
                        struct  ret_struct      retStr;

                        status =
                        om$send(msg = message NDmacro.ACgive_structure(
                                                        &sts,
                                                        &dirIndex,
                                                        name,
                                                        &retStr,
                                                        &mdEnv ),
                                mode     = OM_e_wrt_message,
                                targetid = me->queries[j].objid,
                                targetos = me->queries[j].osnum,
                                senderid = NULL_OBJID );

                        if( ! (status & sts & 1 )) continue;
                       
                        /* compare query names: if = 0, this query is 
                           active query
                        */
                        rtj = 0; 
                        if(strcmp(retStr.var.text_st.text_string,
                                  act_qry_name_list[i]) == 0) 
                         {
                           /* test if it is in act_queries */
                           for( k = 0; k < ii; k ++ ) {
                              if ((me->queries[j].objid == 
                                   me->act_queries[k].objid) &&
                                  (me->queries[j].osnum == 
                                   me->act_queries[k].osnum)) 
                              {
                              		rtj = 1;
                              		continue;
                              }
                           } 
                           if(rtj) continue;   /* go to next j */ 
                           me->act_queries[ii].objid = me->queries[j].objid;
                           me->act_queries[ii].osnum = me->queries[j].osnum;
                           ii += 1;
           		   status =
                           om$vla_set_dimension(varray = me->act_queries,
                                                size   = ii + 1 );
                           break;  /* goto next i */
                         }
                } /* for j */
            } /* for i */
            status =
            om$vla_set_dimension(varray = me->act_queries,
                                                size   = ii );
  
        } /* if */
         
        /* if active query list is not NULL, display it on form 
         * just for select form case 
         */

        if(me->mytype != QRY_COB_CRT ) {
            nbAct = om$dimension_of( varray = me->act_queries );
            strcpy( name, VD_qry_nmName );

            ii=0;
            for( i=0 ; i<nbAct ; i++ ){

            	IGRint  dirIndex = -1;
            	struct  GRmd_env        mdEnv;
            	struct  ret_struct      retStr;

                        status =
                        om$send(msg = message NDmacro.ACgive_structure(
                                                        &sts,
                                                        &dirIndex,
                                                        name,
                                                        &retStr,
                                                        &mdEnv ),
                                mode     = OM_e_wrt_message,
                                targetid = me->act_queries[i].objid,
                                targetos = me->act_queries[i].osnum,
                                senderid = NULL_OBJID );

                        if( ! (status & sts & 1 )) continue;

                        fullname[0] = '\0';
                        filename[0] = '\0';

                        sts1 = VDget_filename_from_os(
                                me->act_queries[i].osnum, filename );
                        __DBGpr_str( "filename", filename);
                        if ( !(1&sts1) ) {
                         FIfld_set_text( form_ptr,10,0,0,"Not found File Name",
                                         FALSE);
                        }

                        sprintf( fullname, "%s[%s]",
                               retStr.var.text_st.text_string, filename);
                        __DBGpr_str( "fullname", fullname);

                        FIfld_set_text( form_ptr, QRY_SEL_ACTIVE, ii++, 0,
                                fullname, FALSE );
         } /* for i */

         /*
          * fill in definition field.
          */

          ii=0;
          pSelect = NULL;
          pWhere = NULL;
          for( i=0 ; i<nbAct ; i++ ){

                 status =
                 om$send(msg = message VDquery.VDgive_query(
                                                        &msg,
                                                        &pSelect,
                                                        &pWhere,
                                                        NULL ),
                                targetid = me->act_queries[i].objid,
                                targetos = me->act_queries[i].osnum,
                                senderid = NULL_OBJID );

                        if( (status & msg & 1) && pSelect ){

                                strcpy( buffer, pSelect );
                                strcat( buffer, " " );
                                if( pWhere ) strcat( buffer, pWhere );

                                VDqry_splt_string( buffer, select, where );

                                FIfld_set_text( form_ptr, QRY_SEL_DEF,
                                                ii++, 0, select, FALSE );

                                FIfld_set_text( form_ptr, QRY_SEL_DEF,
                                                ii++, 0, where, FALSE );
                        }

                        _FREE( pSelect );
                        _FREE( pWhere  );

                        pSelect = NULL;
                        pWhere  = NULL;
           } /* for */
	}/* if */ 
   
	/* clear field when query name is empty in create query form */

         FIg_get_state( form_ptr, EDIT_QRY_TOGGLE, &state);    
         __DBGpr_int(" state ", state);
      
         name[0] = '\0'; 
         FIfld_get_text(       form_ptr, QUERY_NAME, 0, 0, QUERY_LEN, name,
                        &sel, & pos);
         __DBGpr_str(" query name ", name);

         FIfld_get_list_num_rows( form_ptr, QUERY_NAME, 0, &num );
         __DBGpr_int(" query # ", num);

         if( me->mytype == QRY_COB_CRT && name[0] != '\0' &&  state == 1 ) {
           __DBGpr_com(" in ");

           for( i=0 ; i<num ; i++ ){

                buffer[0] = '\0';
                FIfld_get_list_text(    form_ptr,
                                        QUERY_NAME,
                                        i,
                                        0,
                                        QUERY_LEN,
                                        buffer,
                                        &sel );
                __DBGpr_str(" query name ", buffer);

                if ( strcmp( buffer, name ) == 0 ){
                       /*
                        * keep content in QUERY_NAME, DEFINITION
                        * COMMENT and NEW NAME
                        */
                       d_flag = FALSE;
         	       __DBGpr_int(" d_flag ", d_flag);
                       
                       break;
               }
          }

          if( d_flag ) {
             VDqry_clr_display(form_ptr, NEW_NAME);
             VDqry_clr_display(form_ptr, QUERY);
             VDqry_clr_display(form_ptr, EDIT_QUERY);
             FIfld_set_text( form_ptr, QUERY_NAME, 0, 0,"", FALSE );
             VDqry_clr_display(form_ptr, QUERY_DESCRIPTION);
          }
        }
      
        status =
        om$send(msg = message VDCmdQYnpt.checkEvent (&msg),
                			targetid = my_id );
        as$status();
        
	if( form_ptr && !me->form_display_flag && 
            me->locate_wakeup && (msg != VD_QRY_CHECK_EVN)){

		FIf_display( form_ptr );
	}

        me->form_display_flag = 0;   /* make form display available */ 
        
        for (i = 0; i < act_qry_count; i ++ ) {
          _FREE(act_qry_name_list[i]);
        }
   
        me->isdesignfile = TRUE; /* init assume work on design file */ 
        End 
	return	OM_S_SUCCESS ;
} /* wake_up */

/******************************************************************************

Method:

   arrange_qrylist

Description:

    This method rearrang the querylist which is from display query definition.
    It also set offsets.

******************************************************************************/

method arrange_qrylist(IGRchar *in_query_list; 
                       IGRchar *buffer) 
{
IGRchar                 *ptr,
                        text[QUERY_LEN],
                        tmpquery[QUERY_LEN],
                        tmp[QUERY_LEN];
IGRint                  len,sw,j,sw1,
                        pre_query_offsets = 0 ,
                        end_query_flag = FALSE;

     SetProc( VDCmdQYnpt.arrange_qrylist ); Begin
     /*
      * rearrang input query following the format of create query form
      */

     def_state = 0;
     /* check if queru is empty */
     if(in_query_list == NULL) {
        printf("Query is empty\n");   
        goto wrapup;
     }

     /*
      * find classname or macro name
      * and where or where!
      */
     tmpquery[0] = '\0';
     strcpy(tmpquery, in_query_list);
     while(tmpquery[0] == ' ' && (&tmpquery[1] != NULL)) 
                           strcpy(tmpquery, &tmpquery[1]);
   
     if(strncmp("select", tmpquery, 6) != 0)  goto wrapup;
 
     strcpy(tmpquery, &tmpquery[6]);

     while(tmpquery[0] == ' ' && (&tmpquery[1] != NULL)) 
                           strcpy(tmpquery, &tmpquery[1]);

     len = strlen(tmpquery) ;
     ptr = strchr(tmpquery, ' ') ;
     if ( ptr != NULL ) {

          /* seperate class name or macro name */
          len = len - strlen(ptr);
          strncpy(text, tmpquery, len);
          text[len] = '\0';
          strcat(buffer,text);
          strcat(buffer, "  ");
          if ( me->num_query_offsets >
                   om$dimension_of(varray = me->query_offsets))
              {
                   om$vla_set_dimension (varray = me->query_offsets,
                      size = me->num_query_offsets + 10);
              }
          pre_query_offsets = strlen(buffer);
          me->query_offsets[me->num_query_offsets++] = pre_query_offsets;

          /* check where or where! */
          if(!(&ptr[1])) {
               def_state = 1;
               goto onlyname;
          }
          strcpy(text, &ptr[1]);
          while(text[0] == ' ' && (&text[1] != NULL)) strcpy(text, &text[1]);
          if( text[0] == ' ' && (&text[1] == NULL)) {
                def_state = 1;
                goto onlyname;
          } 
          if (strncmp("where!", text, 6)==0 ) {
              strcat(buffer, "where! ");
              strcpy(text, &text[6]);

              if ( me->num_query_offsets >
                   om$dimension_of(varray = me->query_offsets))
              {
                   om$vla_set_dimension (varray = me->query_offsets,
                      size = me->num_query_offsets + 10);
              }
              pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
              me->query_offsets[me->num_query_offsets++] =pre_query_offsets + 7;
          }
          else if (strncmp("where", text, 5)==0 ) {
              strcat(buffer, "where ");
              strcpy(text, &text[5]);
              if ( me->num_query_offsets >
                   om$dimension_of(varray = me->query_offsets))
              {
                   om$vla_set_dimension (varray = me->query_offsets,
                      size = me->num_query_offsets + 10);
              }
              pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
              me->query_offsets[me->num_query_offsets++] =pre_query_offsets + 6;
          }
          else  { 
              /* if user not use where or where!, it is considered as where */
              strcat(buffer, "where ");
              if ( me->num_query_offsets >
                   om$dimension_of(varray = me->query_offsets))
              {
                   om$vla_set_dimension (varray = me->query_offsets,
                      size = me->num_query_offsets + 10);
              }
              pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
              me->query_offsets[me->num_query_offsets++] =pre_query_offsets + 6;
          }
     }
     else if( len ) {
                /* only have class name or macro_name */
              	strncpy(text, tmpquery, len);
              	text[len] = '\0';
              	strcat(buffer,text);
              	strcat(buffer, "  ");
              	if ( me->num_query_offsets >
                   om$dimension_of(varray = me->query_offsets))
              	{
                   om$vla_set_dimension (varray = me->query_offsets,
                      size = me->num_query_offsets + 10);
               	}
                pre_query_offsets = strlen(buffer);
                me->query_offsets[me->num_query_offsets++] = pre_query_offsets;

                def_state = 1;
                goto onlyname;
     }
     else {
               printf("Query doesn't include calss or macro name\n");
               goto wrapup;
     }

     if(!strlen(text)) goto wrapup;

     /*
      * check entity (attr1 = val1), limited 100 offsets
      */
     om$vla_set_dimension (varray = me->query_offsets,
                      size = me->num_query_offsets + 100);
     while(end_query_flag == FALSE) {

              while(text[0] == ' ' &&(&text[1] != NULL)) strcpy(text, &text[1]);
              /* check ( */

              strcat(buffer, "(");

              if(  text[0] == '(')
                              strcpy(text, &text[1]);

              len = strlen(text);

              sw = 0;
              for(j = 0; j<len; j++) {
                  if(  text[j] == '!') {
                    ptr = strchr(text,'!');
                    sw = 1;
                  }
                  else if ( text[j] == '<') {
                    ptr = strchr(text,'<');
                    sw = 2;
                  }
                  else if(  text[j] == '>') {
                    ptr = strchr(text,'>');
                    sw = 3;
                  }
                  else if(  text[j] == '=') {
                    ptr = strchr(text,'=');
                    sw = 4;
                  }
                  if(sw) break;
              }


              switch(sw) 
              {
              case 1:    
                   if (ptr[1] != '=') goto wrapup;
                   len = strlen(text) - strlen(ptr);
                   if(!len) goto wrapup;
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                   tmp[len] = '\0';
                   strcat(buffer,tmp);
                   strcat(buffer," ");
                   pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                   me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + len + 1;

                   strcat(buffer, "!= ");
                   pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                   me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 3;
                   if (ptr[2] == NULL) goto wrapup;
                   strcpy(text, &ptr[2]);
                   break;

              case 2:
                   len = strlen(text);
                   len = len - strlen(ptr);
                   if(!len) goto wrapup;
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;

                   tmp[len] = '\0';
                   strcat(buffer,tmp);
                   strcat(buffer," ");
                   pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                   me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + len + 2;
                   if (ptr[1] == '=') {
                     strcat(buffer, ">= ");
                     pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                      me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 3;
                     if (ptr[2] == NULL) goto wrapup;
                     strcpy(text, &ptr[2]);
                   }
                   else {
                     strcat(buffer, "> ");
                     pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                      me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 2;
                     if (ptr[1] == NULL) goto wrapup;
                     strcpy(text, &ptr[1]);
                   }
                   break;

              case 3:
                   len = strlen(text);
                   len = len - strlen(ptr);
                   if(!len) goto wrapup;
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                   tmp[len] = '\0';
                   strcat(buffer,tmp);
                   strcat(buffer," ");
                   pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                   me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + len + 2;
                   if (ptr[1] == '=') {
                    strcat(buffer, "<= ");
                     pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                      me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 3;

                     if (ptr[2] == NULL) goto wrapup;
                     strcpy(text, &ptr[2]);
                   }
                   else  {
                     strcat(buffer, "< ");
                     pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                      me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 2;
                     if (ptr[1] == NULL) goto wrapup;
                     strcpy(text, &ptr[1]);
                   }
                   break;

              case 4:
                   len = strlen(text);
                   len = len - strlen(ptr);
                   if(!len) goto wrapup;
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;

                   tmp[len] = '\0';
                   strcat(buffer,tmp);
                   strcat(buffer," ");
                   pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                   me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + len + 2;
                   strcat(buffer,"= ");
                     pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                      me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 2;
                   if (ptr[1] == NULL) goto wrapup;
                   strcpy(text, &ptr[1]);
                   break;

              default: 
                   printf("Query doesn't include condition\n");
                   goto wrapup;
              } 

              while(text[0] == ' ' && (&text[1] != NULL)) 
                                                     strcpy(text, &text[1]);

              /* check ")" */

              len = strlen(text);

              sw1 = 0;
              for(j = 0; j<len; j++) {
                if(  text[j] == ')') {
                   ptr = strchr(text,')');
                   sw1 = 1;
                }
                else if( text[j] == '&') {
                   ptr = strchr(text,'&');
                   sw1 = 2;
                }
                else if( text[j] == '|') {
                   ptr = strchr(text,'|');
                   sw1 = 3;
                }
                else if( text[j] == '@') {
                   ptr = strchr(text,'@');
                   sw1 = 4;
                }
                if(sw1) break;
             }

/*             if (!(ptr = strchr(text,')'))) goto wrapup;     */
             if (sw1) {
                   len = strlen(text);
                   len = len - strlen(ptr);
                   if(!len) goto wrapup;
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                   tmp[len] = '\0';
                   strcat(buffer,tmp);
                   strcat(buffer, ") ");
                   pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                   me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + len + 2;
              }
             if (!sw1) {
                   len = strlen(text);
                   if(!len) goto wrapup;
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                   tmp[len] = '\0';
                   strcat(buffer,tmp);
                   strcat(buffer, ") ");
                   pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                   me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + len + 2;
                   /* stop here */
                   end_query_flag = TRUE;
                   continue;
              }
             /* include ) case */
             if(sw1 == 1) {
                  if (ptr[1] == NULL) {
                              end_query_flag = TRUE;
                              continue;
                   }
                   /* pass ) */
                   strcpy(text, &ptr[1]);
             }
             else { /* for > 1 cases */
                   strcpy(text, &ptr[0]);
              }
  
              while(text[0] == ' ' && (&text[1] != NULL)) 
                                            strcpy(text,&text[1]);
              /* check conjunction */
              if(text[0] == '&') {
                   if (text[1] == '!') {
                    strcat(buffer, "&! ");
                    pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                    me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 3;
                    if (text[2] == NULL) goto wrapup;
                    strcpy(text, &text[2]);
                   }
                   else {
                    strcat(buffer, "& ");
                    pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                    me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 2;
                    if (text[1] == NULL) goto wrapup;
                    strcpy(text, &text[1]);
                   }
              }
              else if(text[0] == '|') {
                   if (text[1] == '!') {
                    strcat(buffer, "|! ");
                    pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                    me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 3;
                    if (text[2] == NULL) goto wrapup;
                    strcpy(text, &text[2]);
                   }
                   else {
                    strcat(buffer, "| ");
                    pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                    me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 2;
                    if (text[1] == NULL) goto wrapup;
                    strcpy(text, &text[1]);
                   }
              }
              else if(text[0] == '@') {
                    strcat(buffer, "@ ");
                    pre_query_offsets =
                      me->query_offsets[me->num_query_offsets-1];
                    me->query_offsets[me->num_query_offsets++]
                             = pre_query_offsets + 2;
                    if (text[1] == NULL) goto wrapup;
                    strcpy(text, &text[1]);
             }
             else if(text[0] == '\0') {
                    end_query_flag = TRUE;
             }             
             else {
                    goto wrapup;
             }
    }  /* while */
   def_state = 5;

onlyname:
    me->num_query_offsets = me->num_query_offsets-1;
    End
    return 1;
wrapup:
    def_state = 0;
    me->num_query_offsets = 0;
    printf("Query format is wrong\n");
    End
    return 0;
}
/******************************************************************************

Method:

   query_struct

Description:

    This method makes query structure Qry_coll from query definition 
History:

    yuhang    12/28/94    creation date

******************************************************************************/

method query_struct(   IGRchar** name_list; 
                       IGRchar** text_list; 
                       IGRint nb_list)
{
IGRint     		status;
IGRchar                 *ptr,
                        text[QUERY_LEN],
                        tmpquery[QUERY_LEN],
                        tmp[QUERY_LEN];
IGRint                  len,i,sw,sw1,j,
			end_query_flag = FALSE;

     SetProc( VDCmdQYnpt.query_struct ); Begin
     status =
     om$vla_set_dimension(  varray =  me->qry_list,
                            size   =  nb_list );
    
     for( i = 0; i < nb_list; i++) {
         end_query_flag = FALSE;
         me->qry_list[i].nb_att = 0;
         if(name_list[i] == NULL) {
            strcpy(me->qry_list[i].ename, ""); 
         } 
         else {
           strcpy(me->qry_list[i].ename, name_list[i]); 
         }
     
	/*
      	* find classname or macro name
      	* and where or where!
      	*/
     	tmpquery[0] = '\0';
     	strcpy(tmpquery, text_list[i]);
     	while(tmpquery[0] == ' ' && (&tmpquery[1] != NULL))
                           strcpy(tmpquery, &tmpquery[1]);

        /* skip select */
     	strcpy(tmpquery, &tmpquery[6]);

     	while(tmpquery[0] == ' ' && (&tmpquery[1] != NULL))
                           strcpy(tmpquery, &tmpquery[1]);

     	len = strlen(tmpquery) ;
     	ptr = strchr(tmpquery, ' ') ;
     	if ( ptr != NULL ) {
          	/* seperate class name or macro name */
          	len = len - strlen(ptr);
          	strncpy(text, tmpquery, len);
          	text[len] = '\0';
          	strcpy(me->qry_list[i].iname, text); 

          	/* check where or where! */
          	if(!(&ptr[1])) {
         		me->qry_list[i].nb_att = 0;
                        continue;
                } 
                strcpy(text, &ptr[1]);
               	while(text[0] == ' ' && (&text[1] != NULL)) 
                                                    strcpy(text, &text[1]);
          
                if( text[0] == ' ' && (&text[1] == NULL)) {
                        /* for case : there are some space after classname */
         		me->qry_list[i].nb_att = 0;
                        continue;
                }
                if (strncmp("where!", text, 6)==0 ) {
                   strcpy(text, &text[6]);
                }
                else if (strncmp("where", text, 5)==0 ) {
                   strcpy(text, &text[5]);
                }       
          }
          else if( len ) {
                /* only have class name or macro_name */
                strncpy(text, tmpquery, len);
                text[len] = '\0';
          	strcpy(me->qry_list[i].iname, text); 
         	me->qry_list[i].nb_att = 0;
                        continue;
          }
          else {
                /* no intername */
                strcpy(me->qry_list[i].iname, "");
                me->qry_list[i].nb_att = 0;
                        continue;
          }

          
          if(!strlen(text)) { 
                me->qry_list[i].nb_att = 0;
                continue;
          }

     	/*
      	* check entity (attr1 = val1), 
      	*/
        while(end_query_flag == FALSE) {
              while(text[0] == ' ' &&(&text[1] != NULL)) 
                                             strcpy(text, &text[1]);
              /* check ( */

              if(  text[0] == '(') 
                              strcpy(text, &text[1]);

              len = strlen(text);

              sw = 0;
              for(j = 0; j<len; j++) {
                  if(  text[j] == '!') {
                    ptr = strchr(text,'!'); 
                    sw = 1;
                  }
                  else if ( text[j] == '<') {
                    ptr = strchr(text,'<'); 
                    sw = 2;
                  }
                  else if(  text[j] == '>') {
                    ptr = strchr(text,'>'); 
                    sw = 3;
                  }
                  else if(  text[j] == '=') {
                    ptr = strchr(text,'='); 
                    sw = 4;
                  }
                  if(sw) break;
              }

              switch(sw)
              {
              case 1:
                   len = strlen(text) - strlen(ptr);
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                   tmp[len] = '\0';
                   strcpy(me->qry_list[i].desc[me->qry_list[i].nb_att].att_name,                         tmp);
                   strcpy(text, &ptr[2]);
                   break;

              case 2:
                   len = strlen(text);
                   len = len - strlen(ptr);
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                   tmp[len] = '\0';
                   strcpy(me->qry_list[i].desc[me->qry_list[i].nb_att].att_name,                         tmp);
                   if (ptr[1] == '=') {
                     strcpy(text, &ptr[2]);
                   }
                   else {
                     strcpy(text, &ptr[1]);
                   }
                   break;

              case 3:
                   len = strlen(text);
                   len = len - strlen(ptr);
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   }
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                   tmp[len] = '\0';
                   strcpy(me->qry_list[i].desc[me->qry_list[i].nb_att].att_name,                         tmp);
                   if (ptr[1] == '=') {
                     strcpy(text, &ptr[2]);
                   }
                   else  {
                     strcpy(text, &ptr[1]);
                   }
                   break;

              case 4:
                   len = strlen(text);
                   len = len - strlen(ptr);
                   strncpy(tmp, text, len);
                   while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                   } 
                   while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;

                   tmp[len] = '\0';
                   strcpy(me->qry_list[i].desc[me->qry_list[i].nb_att].att_name,                         tmp);
                   strcpy(text, &ptr[1]);
                   break;

              }
              while(text[0] == ' ' && (&text[1] != NULL))
                                                     strcpy(text, &text[1]);
              /* check ")" */

              len = strlen(text);

              sw1 = 0;
              for(j = 0; j<len; j++) {
                if(  text[j] == ')') {
                   ptr = strchr(text,')');
                   sw1 = 1;
                }
                else if( text[j] == '&') {
                   ptr = strchr(text,'&');
                   sw1 = 2;
                }
                else if( text[j] == '|') {
                   ptr = strchr(text,'|');
                   sw1 = 3;
                }
                else if( text[j] == '@') {
                   ptr = strchr(text,'@');
                   sw1 = 4;
                }
                if(sw1) break;
             }

             if(sw1) {
                len = strlen(text);
                len = len - strlen(ptr);
                strncpy(tmp, text, len);
                while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                }
                while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                tmp[len] = '\0';
                me->qry_list[i].desc[me->qry_list[i].nb_att].type =
                                                           AC_ATTRIB_TEXT;
             strcpy(me->qry_list[i].desc[me->qry_list[i].nb_att].value.att_txt,
                         tmp);
                me->qry_list[i].nb_att = me->qry_list[i].nb_att + 1;
             }
             else if(!sw1) {
                len = strlen(text);
                strncpy(tmp, text, len);
                while(tmp[0] == ' ' &&(&tmp[1] != NULL)) {
                         strcpy(tmp, &tmp[1]);
                         len = len -  1;
                }
                while(tmp[len-1] == ' ' && ((len - 1) != NULL)) len = len-1;
                tmp[len] = '\0';
                me->qry_list[i].desc[me->qry_list[i].nb_att].type =
                                                           AC_ATTRIB_TEXT;
             strcpy(me->qry_list[i].desc[me->qry_list[i].nb_att].value.att_txt,
                         tmp);
                   me->qry_list[i].nb_att = me->qry_list[i].nb_att + 1;
             
                /* stop query again */
                end_query_flag = TRUE;
                continue;
             }
             /* include ) case */
             if(sw1 == 1) {
                   /* if no more query stop */
                   if (&ptr[1] == NULL) {
                              end_query_flag = TRUE;
                              continue;
                   }
                   /* pass ) */
                   strcpy(text, &ptr[1]);
              }
              else { /* for > 1 cases */
                   strcpy(text, &ptr[0]);
              }
              while(text[0] == ' ' && (&text[1] != NULL))
                                            strcpy(text,&text[1]);
              /* check conjunction */
              if(text[0] == '&') {
                   if (text[1] == '!') {
                    strcpy(text, &text[2]);
                   }
                   else {
                    strcpy(text, &text[1]);
                   }
              }
              else if(text[0] == '|') {
                   if (text[1] == '!') {
                    strcpy(text, &text[2]);
                   }
                   else {
                    strcpy(text, &text[1]);
                   }
              }
              else if(text[0] == '@') {
                    strcpy(text, &text[1]);
              }
              else if(text[0] == '\0') {
                    end_query_flag = TRUE;
              }
         }  /* while */
    } /* for */
         End
         return 1;
} 
/******************************************************************************

Method:

   query_check

Description:

    This method checks query definition
History:

    yuhang    1/21/94    creation date

******************************************************************************/

method query_check(IGRchar **text_list;
                   IGRint nb_list)
{
IGRint                  status;
IGRint                  i;
IGRint                  sts1;
OMuword                 my_os1;
OM_S_OBJID              my_id1;
struct GRmd_env         my_env1;
IGRint                  syntax1;
IGRlong                 msg;
IGRlong                 NumberOfBytes,
                        BytesReceived;

     SetProc( VDCmdQYnpt.query_check ); Begin
     my_os1 = 0;
     my_id1 = NULL_OBJID;
     syntax1 = 1;

     NumberOfBytes = sizeof(my_env1);
     BytesReceived = 0;
     gr$get_module_env(      msg    = &msg,
                                sizbuf = &NumberOfBytes,
                                buffer = &my_env1,
                                nret   = &BytesReceived);

     status = 1;
     for( i = 0; i < nb_list; i++) {
         sts1 =
         VDDIprocess_query(
                             text_list[i],
                             &my_os1,
                             &my_id1,
                             &my_env1,
                             syntax1 ) >= 0 ? 1 : 0;
         if( sts1 == 0 ){
                         status = 0;
                         break; 
         }                    
     }                         
     End
     return status;                   
 } 

end implementation VDCmdQYnpt;
