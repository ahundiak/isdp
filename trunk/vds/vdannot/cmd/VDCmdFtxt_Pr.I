/* $Id: VDCmdFtxt_Pr.I,v 1.1.1.1.2.1 2002/07/09 16:01:19 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdFtxt_Pr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdFtxt_Pr.I,v $
 *	Revision 1.1.1.1.2.1  2002/07/09 16:01:19  ylong
 *	CR6014
 *
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/05/05  21:54:26  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/05  09:06:14  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Pr.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/04/15  13:52:30  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Pr.I for:  by yzhu for vds.240
#
# Revision 1.4  1996/03/28  20:19:34  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Pr.I for:  by yzhu for vds.240
#
# Revision 1.3  1995/05/26  13:26:32  pinnacle
# Replace: by tlbriggs for OPE
#
# Revision 1.2  1995/03/18  22:47:56  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Pr.I by rmanem r#
#
# Revision 1.1  1994/11/21  20:12:08  pinnacle
# delete by mistake
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	01-03-1992	ADZ	Creation date
 *	10-06-1993	ADZ	Adding template information for macros.
 *	03/18/95	rmn	Clear parameter list in form before getting
 *				   parameters for the object.
 *	05/12/95	adz	Crash on referenc link beams when selected
 *				   from reference file.
 *	04/15/96	adz	Change vd$get_parameters to vd$get_params 
 *	11/05/97	Sundar	Added one function VDfill_in_exprs
 *	05/05/99	Ming    TR179900036
 *	06/14/02	ylong	CR6014
 * -------------------------------------------------------------------*/

class implementation VDCmdFtxt;

#include <stdio.h>
#include <string.h>

#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"
#include "nddef.h"
#include "asbox.h"
#include "FI.h"

#include "grerr.h"
#include "macro.h"

#include "exmacros.h"
#include "dpmacros.h"
#include "ndmacros.h"
#include "msmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDmsg.h"
#include "ASmessages.h"
#include "VDSannot.h"
#include "vdparmacros.h"      
/*
#define vdserrDEBUG 1
#define vdsDEBUG 1
*/
#include "v_miscmacros.h"      
#include "v_dbgmacros.h"      

#include "VDdrwlo.h"      
#include "vdtblmacros.h"      
#include "VDmem.h"      
#include "VDobj.h"

#include "AS_status.h"

/* foreign methods */
from NDmacro	     import ACreturn_foot;
from ACcpx           import ACfind_temp_obj;
from ACcpx           import find_macro ;
from ACcpx_defn	     import ACgive_name;
from NDnode	     import NDgive_structure, NDdelete, ASreturn_go;
from ACmacro_defn    import ACgive_feet_desc, ACgive_temp_desc;
from ACrg_collect    import AClist_attribute;
from ACsym           import ACgive_foot;
from IGRdir	     import dump;
from expression      import NDgive_value;

#define AS_DEBUG

/************************************************************************/
/*	METHOD:	fill_in_params						*/
/************************************************************************/

method	fill_in_params( long * sts )
{
int	status = OM_S_SUCCESS;
int	msg;
IGRint	i, num_row, eqp_flag = 0;
char	*c;

/*
 * variables for dump
 */
DIchar		**collns;
DIgrid		*colln_ids;		/* ids of these collections	*/
DIint		nb_colln;		/* number of format collections */
GRclassid	classid;

SetProc( MTD.fill_in_params); Begin 
/*
 * This method get the parameters ( feetnames and values )
 * of a selected macro and set them in the folowing instance:
 *	struct	myfeet	*lfeet,
 *	int		nb_feet,
 *	struct	GRid	Feet_List[],
 *	struct	ret_struct	Feet_Values[]
 *
 */

  collns    = NULL;
  colln_ids = NULL;
  nb_colln  = 0;

  if( me->macro_id.objid == NULL_OBJID ){
    /*| no macro active */
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }

  /* CR6014, get name from VDSget_discipline 
  status =
  om$send(msg = message ACcpx_defn.ACgive_name( &c ),
	  targetid = me->macro_id.objid,
	  targetos = me->macro_id.osnum );
  as$status();

  strcpy(me->macro_name,c);
  */

  VDSget_discipline( &me->hdr, 0, me->macro_name );
  if( !strncmp( me->macro_name, "equipment", 9 ) ) {
    FIg_display( me->forms[0].form_ptr, EQP_NAME_OPT );
    FIg_get_state( me->forms[0].form_ptr, EQP_NAME_OPT, &eqp_flag );
    if( eqp_flag ) VDSget_discipline( &me->hdr, eqp_flag, me->macro_name );
  }
  else {
    FIg_erase( me->forms[0].form_ptr, EQP_NAME_OPT );
  }

  /*" macro name is %s\n", me->macro_name */

  FIg_set_text( me->forms[0].form_ptr, EXIST_FORMAT, me->macro_name );

  num_row = 0;
  VDfill_in_params(	&me->hdr,		/* macro object */
			&num_row,		/* display row */
			"",
			me->forms[0].form_ptr,	/* form pointer */
			&me->mod_env );

  __DBGpr_int(" num_row ", num_row );

  VDfill_in_exprs( me->forms[0].form_ptr);


  /**********************************************************************/
  /*									*/
  /* get previous defined formatted text definitions and delete them	*/
  /*									*/
  /**********************************************************************/
  if( me->formats_dir.objid == NULL_OBJID ){
    /*| format directory not found */
    *sts = MSFAIL;
    return( OM_E_ABORT );
  }
    
  status = 
  om$send(msg = message IGRdir.dump(	&msg,
					"*",
					NULL,
					&collns,
					&colln_ids,
					&nb_colln,
					0 ),
	  targetid = me->formats_dir.objid,
	  targetos = me->formats_dir.osnum,
	  senderid = NULL_OBJID );
  as$status( action=GOTO_VALUE, value=wrapup );

  for( i=0; i<nb_colln; i++){
    /* delete previous syntax */
    om$get_classid(	osnum   = colln_ids[i].osnum,
			objid   = colln_ids[i].objid,
			p_classid = &classid );
    if( om$is_ancestry_valid(	superclassid = OPP_ACrg_collect_class_id,
				subclassid   = classid) == OM_S_SUCCESS){

	status =
	om$send(msg = message ACrg_collect.NDdelete(&me->ModuleInfo ),
		targetid = colln_ids[i].objid,
		targetos = colln_ids[i].osnum);
	as$status( action=GOTO_VALUE, value=wrapup );
    }
  }

wrapup:

  di$free( lines = collns, count = nb_colln );
  if( nb_colln ) DIfree( colln_ids );

  *sts = MSSUCC;
  End
  return( status );
}

/************************************************************************/
/*	FUNCTION: VDfill_in_params					*/
/************************************************************************/

VDfill_in_params(object_id,num_row,object_name,form_ptr,md_env)
struct GRid	*object_id;	/* maco object		*/
int		*num_row;	/* active display row	*/
char		*object_name;	/* macro object		*/
char		*form_ptr;	/* active form pointer	*/
struct GRmd_env	*md_env;	/* module environment	*/
{
int			status, count, i;
long			sts;
char			s_tmp[DI_PATH_MAX], feet_name[DI_PATH_MAX];
struct ACrg_coll  	*plist;
struct	GRid		go ;

        SetProc( VDfill_in_params ); Begin

	/* clear field, just in case get_parameters fails */
	FIfld_set_num_rows( form_ptr, PARAS_FIELD, *num_row );

	go = *object_id ;
	plist = NULL;

	status =
	om$send(msg = message NDmacro.ACreturn_foot( &sts, "", &go, NULL, NULL ),
		senderid = NULL_OBJID,
		targetid = go.objid,
		targetos = go.osnum );

	status =
	vd$get_params(	sts 		= &sts,
			object 		= object_id,
			md_env		= md_env,
			count		= &count,
			plist		= &plist );
	CheckRC( status, sts );

	if( count ){
		__DBGpr_int(" Count ", count );
		FIfld_set_num_rows( form_ptr, PARAS_FIELD, (*num_row + count ) );
	}

	for( i=0 ; i<count ; i++ ){
	  if(object_name[0] != '\0')
	    sprintf(feet_name,"%s:%s", object_name, plist[i].name );
	  else
	    strcpy(feet_name, plist[i].name );

	  if( plist[i].desc.type == AC_ATTRIB_DOUBLE ){

	    sprintf( s_tmp, "%.3f", plist[i].desc.value.att_exp ); 
	    FIfld_set_text( form_ptr, PARAS_FIELD, *num_row, 0, feet_name, FALSE );
	    FIfld_set_text( form_ptr,PARAS_FIELD, *num_row,1, s_tmp, FALSE );
            (*num_row)++;
          }

	  if( plist[i].desc.type == AC_ATTRIB_TEXT ){

	    FIfld_set_text( form_ptr,PARAS_FIELD,*num_row,0, feet_name,FALSE);
	    FIfld_set_text( form_ptr,PARAS_FIELD,*num_row, 1, 
		          plist[i].desc.value.att_txt, FALSE );
            (*num_row)++;
          }
	}

	if( *num_row ){
		__DBGpr_int(" NumCount ", *num_row );
		FIfld_set_num_rows( form_ptr, PARAS_FIELD, *num_row );
	}

	goto wrapup ;

wrapup:

	_FREE( plist );

        End
	return OM_S_SUCCESS;
}

/************************************************************************/
/*      FUNCTION: VDfill_in_exprs                                       */
/************************************************************************/
 
VDfill_in_exprs(form_ptr)
char            *form_ptr;      /* active form pointer  */
{
	IGRlong 	msg,status;
	IGRshort 	count=0;
	IGRint 		i, row;
	GRspacenum 	cur_os;
	IGRchar 	*Tabtyp=NULL;

	SetProc ( VDfill_in_exprs ); Begin
	ex$get_cur_mod (osnum = &cur_os);
	vd$tblexp_idt ( msg = &msg,
			osnum = cur_os,
                        p_count = &count);
 
	if ( count == 0)
		goto wrapup;

	Tabtyp=_MALLOC(count*VD_CREXP_CHR_TYPE, char);

	vd$tblexp_idt ( msg = &msg,
                        osnum = cur_os,
                        p_count = &count,
			 p_typs = Tabtyp);

	FIfld_set_num_rows( form_ptr, EXP_TYP_FIELD, count );
	row = 0;
	for (i=0; i<count; i++){
		if( Tabtyp[i*VD_CREXP_CHR_TYPE] == '\0' ) continue;
		VDfld_set_list_text( form_ptr,EXP_TYP_FIELD,row++,0,
			&Tabtyp[i*VD_CREXP_CHR_TYPE],FALSE);
	}

   	wrapup :
		_FREE(Tabtyp);
	End
	return 1;
}

/************************************************************************/
/*	FUNCTION VDget_feet_values					*/
/************************************************************************/

int VDget_feet_values(	Macro,			/* In: Macro to find feet Info*/
			mod_env,		/* In: Current Module	      */
			macro_name,		/* Out: Macro Defn Name	      */
			nb_feet, 		/* Out: Number of Feet Found  */
			Feet_List_ptr,		/* Out: Ids of Feet	      */
			Feet_Values_ptr,	/* Out: Feet Values, if any   */
			l_feet )		/* Out: Names of Feet + junk  */
/* 
 * WARNING:
 *
 * The parameters Feet_List_ptr and Feet_Values_ptr are allocating memory 
 * locally which has to liberated after user -> om$dealloc
 */
struct	GRid		*Macro;  
struct	GRmd_env	*mod_env;      
IGRchar			*macro_name;   
IGRint			*nb_feet;     
struct	GRid		**Feet_List_ptr;    
struct	ret_struct	**Feet_Values_ptr;  
struct	myfeet		*l_feet;	      
/*.VDget_feet_values*/
{
struct	GRid		*F_List;
struct	ret_struct	*F_Values;
struct	ACrg_coll	*list_att = NULL ;
struct	GRid		macro_id, go_prov;
IGRint			msg, ifeet;
IGRint			status = OM_S_SUCCESS;
IGRlong			sts;
IGRchar			*c;
GRclassid		obj_class;

extern GRclassid	OPP_NDnode_class_id 	;
extern GRclassid	OPP_ASsource_class_id 	;

  SetProc(VDCmdFtxt_Pr.VDget_feet_values); Begin

  __DBGpr_obj(" Macro ", *Macro );
  F_List = NULL ;
  F_Values = NULL ;

  *nb_feet = 0;
  *Feet_List_ptr = NULL ;
  *Feet_Values_ptr = NULL ;

  status =
  om$get_classid(	osnum = Macro->osnum,
			objid = Macro->objid,
			p_classid = &obj_class );

  if( om$is_ancestry_valid(
		subclassid = obj_class ,
		superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS ){

    /*| retreive the graphical object*/
    status =
    om$send(msg = message NDnode.ASreturn_go(&go_prov, NULL, NULL ),
	    targetid = Macro->objid,
	    targetos = Macro->osnum,
	    senderid = NULL_OBJID );
    if( status == OM_S_SUCCESS ) *Macro = go_prov;
  }

  status =
  om$send(msg = message ACcpx.find_macro(&macro_id),
	  targetid = Macro->objid,
	  targetos = Macro->osnum,
	  senderid = NULL_OBJID );
  as$status();

  __DBGpr_obj(" MacroId ", macro_id );

  status =
  om$send(msg = message ACcpx_defn.ACgive_name(&c),
	  targetid = macro_id.objid,
	  targetos = macro_id.osnum,
	  senderid = NULL_OBJID );
  as$status();

  strcpy( macro_name,c );

  status =
  om$send(msg = message ACmacro_defn.ACgive_feet_desc( nb_feet, &l_feet),
                    senderid = NULL_OBJID,
                    targetid = macro_id.objid,
                    targetos = macro_id.osnum);
  as$status();

  __DBGpr_int(" nb_feet ", *nb_feet );

  if( *nb_feet == 0 ) goto wrapup ;
  
  *Feet_Values_ptr = _MALLOC( *nb_feet, struct ret_struct ); 
  *Feet_List_ptr   = _MALLOC( *nb_feet, struct GRid ); 

  F_Values = *Feet_Values_ptr;
  F_List   = *Feet_List_ptr;

  for(ifeet=0; ifeet< *(nb_feet); ifeet++ ){

    /*" l_feet[%d]: %s\n", ifeet, l_feet[ifeet].name */
    status =
    om$send(msg = message ACsym.ACgive_foot(	&msg,
						l_feet[ifeet].name,
						&F_List[ifeet] ),
	    targetid = Macro->objid,
	    targetos = Macro->osnum,
	    senderid = NULL_OBJID );
    as$status();
    as$status( sts = msg );

    if( F_List[ifeet].objid != NULL_OBJID ){
      om$get_classid(	osnum = F_List[ifeet].osnum,
			objid = F_List[ifeet].objid,
			p_classid = &obj_class );
    }
    else{
      /*| Foot Not defined */
      obj_class = OPP_GRgraphics_class_id;
    }

    if( om$is_ancestry_valid(
			subclassid = obj_class,
			superclassid = OPP_NDnode_class_id ) == OM_S_SUCCESS ){
      status =
      om$send(msg = message NDnode.NDgive_structure(	&sts,
							&F_Values[ifeet],
							mod_env ),
	      targetid = F_List[ifeet].objid,
	      targetos = F_List[ifeet].osnum,
	      senderid = NULL_OBJID );
      as$status();

      if( F_Values[ifeet].type ==  gen_rg_collect ){

	IGRint           nb_att;         /* number of feet found in coll */
	IGRint           icol;           /* count feet in collection */
	IGRint           new_size;

	/*| found a collection */
        status =
	om$send(msg = message ACrg_collect.AClist_attribute(&sts, 0, NULL, &nb_att ),
		targetid = F_List[ifeet].objid,
		targetos = F_List[ifeet].osnum,
		senderid = NULL_OBJID );
	as$status();

	_FREE( list_att ); list_att = NULL ;
	list_att = _MALLOC( (nb_att+1), struct ACrg_coll ); 
	if( list_att == NULL ) return( OM_E_NODYNMEM );

	status =
	om$send(msg = message ACrg_collect.AClist_attribute(&sts,
                                       nb_att+1,  list_att, &nb_att ),
                     senderid = NULL_OBJID,
                     targetid = F_List[ifeet].objid,
                     targetos = F_List[ifeet].osnum);
	as$status();

	/*|increasing sizes */
	new_size = *nb_feet + nb_att;
	*Feet_List_ptr   = _REALLOC( *Feet_List_ptr,   new_size, struct GRid );
	*Feet_Values_ptr = _REALLOC( *Feet_Values_ptr, new_size, struct ret_struct );

	F_Values = *Feet_Values_ptr;
	F_List   = *Feet_List_ptr;

	if( ! F_Values || ! F_List ) return( OM_E_NODYNMEM );

	for( icol=0; icol<nb_att; ++icol ){

	  status =
	  om$send( msg = message ACrg_collect.ACgive_foot(
						&msg,
						list_att[icol].name,
						&F_List[(*nb_feet)+icol] ),
		  targetid = F_List[ifeet].objid,
		  targetos = F_List[ifeet].osnum,
		  senderid = NULL_OBJID );
	  as$status();

	  /* | make sure the foot's name reflects its nested state */
	  strcpy( l_feet[(*nb_feet)+icol].name, l_feet[ifeet].name );
	  strcat( l_feet[(*nb_feet)+icol].name, ":" );
	  strcat( l_feet[(*nb_feet)+icol].name, list_att[icol].name );

	  /*" Foot:%d  %s\n", F_List[(*nb_feet)+icol].objid, l_feet[(*nb_feet)+icol].name */
	}

	*nb_feet = (*nb_feet) + nb_att;

	/*| Free list_att */
	_FREE( list_att ); list_att = NULL ;
      }
    }
    else F_Values[ifeet].type = other_generic;

  } /*end for on number of feet */

wrapup:

	_FREE( list_att );

	End
	return( OM_S_SUCCESS );
}


end implementation VDCmdFtxt;
