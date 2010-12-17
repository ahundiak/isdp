/****************************************************************************/
/*     Functions to see if the macro is edited, edit macro to accept graphic*/
/*     and ACrg_collect object as templates, add attributes to ACrg_collect,*/
/*     place macro, get macro header, place selection ci_macro , change     */
/*     symbology of feet of macro , get macro template description, find    */
/*     macro type (macro or ci_macro ), Get value of attribute in ACrg_coll-*/
/*     ect and deletion of macro and ACrg_collect when placement fails.     */
/*                                                                          */
/*     File Creation date 10/06/92            MMS (IGI)                     */
/*     File Modified date 05/01/93            DKK (IGI)                     */
/*                                                                          */
/****************************************************************************/

class implementation GRvg;

#include "OMprimitives.h"
#include <gr.h>
#include "MOmacros.h"
#include "parametric.h"
#include "macro.h"
#include "FI.h"
#include "macro.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "ACdyn_col.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "PALglbs.h"
#include "parametric.h"
#include "ex.h"
#include "exmacros.h"
#include "expression.h"
#include "OMprimitives.h" 
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "acdef.h"
#include "acmacros.h"
#include "macro.h"

#include "MEMstruct.h"

/*#include "PDUproto.h"*/
#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"


#define PAL_S_SUCCESS 1
#define PAL_E_ERROR   0

from  ci_macro     import init;
from  expression   import create           ;
from  text_exp 	   import create           ;
from  ACdyn_col    import ACcreate         ;
from  ACdiowner    import ACadd_attribute  ;
from  ACcpx_defn   import ACgive_temp_desc ;
from  ACcpx_defn   import ACgive_feet_desc ;
from  ACmacro_defn import ACgive_upscan    ;
from  ACmacro_defn import ACtake_template  ;
from  ACmacro_defn import ACtake_feet      ;
from  ACcpx        import ACattach         ;
from  ACcpx        import find_macro       ;
from  ACrg_collect import ACget_named_attribute ;
from  ACheader     import ACmplace_from_def; 
from  ACconst      import ACmplace         ;
from  ACpretdef    import ACsconnect       ;
from  NDnode       import NDdisplay        ;
from  NDnode       import NDplace          ;
from  NDnode       import NDchg_state      ;
from  ACncpx       import ACreturn_foot    ;
from  NDnode       import NDget_objects    ;
from  ACrg_collect import ACshow_data      ;

extern OMuword OPP_ACci_header_class_id;
extern OMuword OPP_nci_macro_class_id;
extern OMuword OPP_ACheader_class_id;
extern OMuword OPP_ACconst_class_id;
extern OMuword OPP_text_exp_class_id;
extern OMuword OPP_expression_class_id;
extern OMuword OPP_ACdyn_col_class_id;
extern OMuword OPP_ACcpx_class_id;

extern char PDU_placement_type ;
extern int PDU_default_color ;
extern int PDU_default_layer ;
extern int PDU_default_style ;
extern int PDU_default_weight ;
extern char *PDU_usage_id;

#define	AC_ATTRIB_MASK_TYPE	0x00ff
/*#define DEBUG 1 */

int PDUcreat_rgbox(pl_name, md_env, rg_collect_grid)

/****************************************************************************/
/*    This function creates an ACrg_collect class  object.                  */
/*    Names the object in the directory as 'attr_placement_                 */
/*    name'  and returns the object id in 'rg_collect_grid'                 */
/*                                                                          */
/*    	return value:      PAL_S_SUCCESS -- success                         */
/*                         PAL_E_ERROR   -- failure to create               */
/****************************************************************************/

char         *pl_name        ;              /*i.  placement name of macro */
struct GRmd_env  *md_env     ;              /*i.  Module environment      */
struct GRid  *rg_collect_grid;              /*o.  GRid of ACrg_collect object */
{

	int  sts;
	IGRlong msg;

	rg_collect_grid -> objid = NULL_OBJID;
	rg_collect_grid -> osnum = md_env -> md_id.osnum  ;
#ifdef DEBUG
	printf("osno. %d\n", md_env -> md_id.osnum );
#endif
	sts = om$construct ( classid   = OPP_ACdyn_col_class_id,
			     p_objid   = &rg_collect_grid -> objid,
			     osnum     = rg_collect_grid -> osnum );

        _MO_omerr_chk("construct  :ACdyn_col", sts, wrapup);

	sts = om$send(	msg	 = message ACdyn_col.ACcreate
					( &msg, pl_name),
			senderid = rg_collect_grid -> objid,
			targetid = rg_collect_grid -> objid,
			targetos = rg_collect_grid -> osnum );

	_pdm_debug("Created ACdyn_col %s", pl_name);

        _MO_emerr_chk("PDUcreat_rgbox() :ACdyn_col.ACcreate", msg, wrapup);
        _MO_omerr_chk("PDUcreat_rgbox() :ACdyn_col.ACcreate", sts, wrapup);


	return( PAL_S_SUCCESS );	
wrapup:
	return( PAL_E_ERROR );
}


/* ---------   Add attribute to a given ACrg_collect  object -------- */

int add_static_attributes(rg_collect_grid,value,attr_name)
struct GRid *rg_collect_grid ;
char *value, *attr_name;
{

	int sts     ;
	IGRlong msg ;

	sts = om$send(	msg	 = message ACdiowner.ACadd_attribute(
					&msg,
					attr_name,
					value ),
			senderid = rg_collect_grid -> objid,
			targetid = rg_collect_grid -> objid,
			targetos = rg_collect_grid -> osnum );

        _MO_emerr_chk("PDUcreat_rgbox() :ACadd_attribute", msg, wrapup);
       	_MO_omerr_chk("PDUcreat_rgbox() :ACadd_attribute", sts, wrapup);

	return(1);
wrapup:
	return(0);
}

/* ------------------   PDUis_macro_edited()  -------------------------*/

int PDUis_macro_edited(hdr)
struct GRid *hdr ;

/***********************************************************************/
/*   This function finds out whether the macro definition is edited or */
/*   not.  Input - macro header object                                 */
/***********************************************************************/
{

	int num_org_temp, num_temp_for_placement , props, sts ;
	struct stemp *temp_desc ;
	struct sup   *sup ;

	/* Get original template description as exists at creation time */
	sts = om$send( msg = message ACcpx_defn.ACgive_temp_desc(
				&num_org_temp,&temp_desc),
                      senderid = hdr  -> objid,
                      targetid = hdr  -> objid,
                      targetos = hdr  -> osnum );

	_MO_omerr_chk("PDUis_macro_edited(): ACgive_temp_desc ", sts, wrapup);

	sts = om$send( msg = message ACmacro_defn.ACgive_upscan(
				&num_temp_for_placement,&props,&sup),
                      senderid = hdr  -> objid,
                      targetid = hdr  -> objid,
                      targetos = hdr  -> osnum );

	_MO_omerr_chk("PDUis_macro_edited(): ACgive_upscan : ", sts, wrapup);
	
	if( num_org_temp != num_temp_for_placement )  // macro is edited
		return( PAL_S_SUCCESS );

	if( !num_temp_for_placement )
		return(PAL_E_ERROR);

	/* If actual and mapped happen to be the same, it could still 
	   be that the last template is not ACdyn_col type
	*/

	if( sup[num_temp_for_placement-1].type == macro_generic )
		return(PAL_S_SUCCESS );

wrapup:
	return( PAL_E_ERROR);
}


int PDUedit_macro(hdr, dyn_list, num_dyn)
/***********************************************************************/
/*      Edit the macro definition such that, all exp ( text & double ) */
/*      attribs NOT falling into the input dyn_list, will go into the  */
/*      FIRST collection and the attribs IN the dyn_list would go into */
/*      the second collection, the rest locatable templates will be at */
/*      the begining of the template list to the macro                 */
/***********************************************************************/
struct GRid *hdr ;
char **dyn_list;
int num_dyn;
{
	int    i, j, org_num_temp, nb_sup, sts ,back ;
	IGRlong msg;
	struct stemp *temp_desc, *new_desc  ;
	struct sup   *supptr ;
	int    count;
	struct myfeet *feet_desc, *new_feet;
	int    nb_feet;
	OM_S_OBJID new_template;

	new_template = NULL_OBJID;

		
	msg = PAL_E_ERROR ;
	temp_desc = NULL;
	new_desc = NULL;
	feet_desc = NULL;
	new_feet = NULL;
	
	supptr = NULL;

	/* Get original template description  and types */
	sts = om$send( msg = message ACcpx_defn.ACgive_temp_desc(
				&org_num_temp,&temp_desc),
                      targetid = hdr -> objid,
                      senderid = hdr -> objid,
                      targetos = hdr -> osnum );

	_MO_omerr_chk("PDUedit_macro(): ACgive_temp_desc ", sts, wrapup);

	/* EDIT MACRO DEFINITION NOW */

	new_desc = (struct stemp *)malloc( (org_num_temp+2) 
						* sizeof(struct stemp ));
	if ( new_desc == NULL )
	{
		printf("PDUedit_macro(): Not enough dynamic memory\n");
		goto wrapup;
	}

	supptr  = (struct sup *)malloc(sizeof(struct sup));
	if ( supptr == NULL )
	{
		printf("PDUedit_macro():Not enough dynamic memory\n");
		goto wrapup;
	}

	/* For each template of the original macro, define down scan (attribute
           name of ACdyn_col and channel index - 'back' )
	*/

	/* set channel nos for non exp type templates first,ie., locatable */
	back = 0 ;
	for( i = 0 ; i < org_num_temp ; i = i + 1 ) 
	{
#ifdef DEBUG
printf(" template: %s, %d %d\n", temp_desc[i].name, i, temp_desc[i].type );
#endif
		if( !(temp_desc[i].type & parameter_generic)) 
		{
			strcpy(new_desc[i].name , temp_desc[i].name ) ;  
        		new_desc[i].type = temp_desc[i]. type ; 
#ifdef DEBUG
printf("graphic template: %s %d %d\n", temp_desc[i].name, i, temp_desc[i].type);
#endif
		        new_desc[i].back =  back ;
#ifdef DEBUG
printf("channel index: %d\n", back);
#endif
			back = back + 1;
        		strcpy(new_desc[i].down_scan,".");/* No Mapping */

		        /* descibe the object connected at each index--'back' */
			strcpy(supptr[back-1].prompt,temp_desc[i].name);
			strcpy(supptr[back-1].up_scan,".");
	
			if( temp_desc[i].type == 65792 ) /* Plane type */
				supptr[back-1].type = 64 ;
			else
				supptr[back-1].type = temp_desc[i].type ;

			supptr = (struct sup *)realloc( supptr, (back+1) *
							sizeof(struct sup));
			if( supptr == NULL ) 
			{
				printf("PDUedit_macro():No dynamic memory\n");
				goto wrapup;
			}
		}
	}

	supptr = (struct sup *)realloc( supptr, (back+2) *
					sizeof(struct sup));
	if( supptr == NULL ) 
	{
		printf("PDUedit_macro():No dynamic memory\n");
		goto wrapup;
	}

	/* set channel nos for  exp type templates now */
	for( i = 0 ; i < org_num_temp ; i = i + 1 ) 
	{
		strcpy(new_desc[i].name , temp_desc[i].name ) ;  
        	new_desc[i].type = temp_desc[i].type ; 

		if( (temp_desc[i].type == double_type) ||
		    (temp_desc[i].type == text_type)  ) 
		{
			for( j = 0; j < num_dyn; j = j +1 )
				if ( !strcmp(temp_desc[i].name, dyn_list[j])) 
		        	{
					new_desc[i].back =  back+1;
        				strcpy(new_desc[i].down_scan,
							 temp_desc[i].name);
					break;
				}
			if( j == num_dyn ) /* Not a dynamic attr */
			{
				new_desc[i].back =  back;
        			strcpy(new_desc[i].down_scan,temp_desc[i].name);
			}
		}
	}

	/* Construct two ACpretends and make them  template-feet of the macro */

    	strcpy(new_desc[org_num_temp].name, "static");
	strcpy(supptr[back].prompt, "static");
	strcpy(supptr[back].up_scan,"*");
	supptr[back].type = macro_generic ;

    	strcpy(new_desc[org_num_temp+1].name, "dynamic");
	strcpy(supptr[back+1].prompt, "dynamic");
	strcpy(supptr[back+1].up_scan,"*");
	supptr[back+1].type = macro_generic ;

	nb_sup	= back;
	count = org_num_temp;
	for( i = org_num_temp; i < (org_num_temp + 2) ; i= i+1 )
	{
		new_desc[i].type = macro_generic;
    		strcpy(new_desc[i].down_scan, ".");
		new_desc[i].back =  nb_sup ;
	
		nb_sup = nb_sup + 1;

		sts = om$construct( classid = OPP_ACpretdef_class_id,
			    p_objid = &new_template,
			    osnum = hdr -> osnum );

		_MO_omerr_chk("PDUedit_macro():construct ACpretdef",sts,wrapup);

		sts = om$send( msg = message ACpretdef.ACsconnect(new_desc,
								 &count ),
						targetid = new_template,
						senderid = new_template,
						targetos = hdr->osnum);

		_MO_omerr_chk("PDUeditmacro():ACpretdef.ASsconnect",sts,wrapup);
	}

	/* This message sets the 'templates to input' at placement time */

	sts = om$send ( msg = message ACmacro_defn.ACtake_template
				( nb_sup, supptr, count, new_desc ),
			targetid = hdr -> objid,
			senderid = hdr -> objid,
			targetos = hdr -> osnum );

	_MO_omerr_chk("PDUedit_macro() :ACtake_template", sts, wrapup);

	/* Now get the feet description of the original macro and add the dyn_
		collection */

	sts = om$send( msg = message ACmacro_defn.ACgive_feet_desc( &nb_feet,
								&feet_desc ),
					targetid = hdr->objid,
					senderid = hdr->objid,
					targetos = hdr->osnum);

	_MO_omerr_chk("PDUedit_macro() :ACgive_feet_desc", sts, wrapup);

	new_feet = (struct myfeet *) malloc((nb_feet+2)*sizeof(struct myfeet));

	if( new_feet == NULL )
	{
		printf(" Malloc problem\n" );
		goto wrapup;
	}

	for ( i = 0; i < nb_feet; i = i + 1 )
		new_feet[i] = feet_desc[i];

       /* changed by kumar for KK 061693 */

	strcpy( new_feet[i].name, "static" );
	strcpy( new_feet[i+1].name, "dynamic" );
	new_feet[i].pos = org_num_temp;
	new_feet[i+1].pos = org_num_temp+1;

	for( ; i < (nb_feet+2); i = i+1 )
	{
		new_feet[i].prop = macro_generic;
		new_feet[i].chan = feet_in_template;
	}

	sts = om$send( msg = message ACmacro_defn.ACtake_feet( nb_feet+2,
								 new_feet),
						targetid = hdr->objid,
						senderid = hdr->objid,
						targetos = hdr->osnum );


	_MO_omerr_chk("PDUedit_macro() :ACtake_feet", sts, wrapup);

	msg = PAL_S_SUCCESS ;
wrapup:
	if( supptr != NULL )
		free( (char *) supptr );

	if( new_desc != NULL )
		free( (char *) new_desc );

	if( new_feet != NULL )
		free( (char *) new_feet );

	return(msg);
}

GetMacroHeaderGivenName (macroname, module_env, header)
char 		*macroname;
struct GRmd_env *module_env;
struct	GRid	*header;
{
	/*	This function returns the objid of the header of a 	*/
	/*	given macro.						*/
 
	int  		sts;
	int msg;
	struct GRid 	macro;
	IGRlong ret_msg ;
	
    	macro.objid = NULL_OBJID ;
	macro.osnum = module_env -> md_id.osnum ;

	sts = om$construct ( classid = OPP_ACcpx_class_id,
			     p_objid = &macro.objid,
			       osnum = macro.osnum );

	_MO_omerr_chk("GetMacroHeaderGivenName : om$construct", sts, wrapup);

	sts = om$send(msg = message ACcpx.ACattach(&msg,macroname),
                 	senderid = macro.objid,
			targetid = macro.objid, 
			targetos = macro.osnum );


	_pdm_debug("GetMacroHeaderGivenName (): macro.objid %d\n", macro.objid);

	_MO_omerr_chk("ACattach : macro by name", sts, wrapup);

	sts = om$send(  msg = message ACcpx.find_macro( header),
                 	senderid = macro.objid,
                 	targetid = macro.objid,
                 	targetos = macro.osnum);

	_MO_omerr_chk("find_macro : macro", sts, wrapup);

	return (PAL_S_SUCCESS);

wrapup	:
	/* Deleted unused ACcpx objects.	*/
	sts = om$send(msg = message GRgraphics.GRdelete(&ret_msg, module_env),
                 	senderid = macro.objid,
			targetid = macro.objid, 
			targetos = macro.osnum );

	return (PAL_E_ERROR);
}

change_symbology(hdr,dattr,active_level)
struct GRid *hdr ;
short active_level ;
struct IGRdisplay *dattr ;
{
	int sts ;
	IGRlong msg ;
	IGRuint rgbval;

	_pdm_debug("symb: %hd ",  active_level );

	if( !PDU_default_layer )
	{
		sts = om$send(msg = message GRvg.GRchglevel(&msg,&active_level),
		  		senderid = hdr -> objid,
		  		targetid = hdr -> objid,
		  		targetos = hdr -> osnum);
		_MO_omerr_chk("change_symb : chglevel", sts, wrapup);
	}
	if( !PDU_default_color )
	{
		sts = om$send(msg = message GRvg.GRchgcolor(&msg,&rgbval,
								&dattr->color),
                  		targetid = hdr -> objid,
                  		senderid = hdr -> objid,
                  		targetos = hdr -> osnum);
		_MO_omerr_chk("change_symb : chgcolor", sts, wrapup);
	}
	if( !PDU_default_style )
	{
		sts = om$send(msg = message GRvg.GRchgstyle(&msg,&dattr->style),
                  		targetid = hdr -> objid,
                  		senderid = hdr -> objid,
                  		targetos = hdr -> osnum);
		_MO_omerr_chk("change_symb : chgstyle", sts, wrapup);
	}
	if( !PDU_default_weight )
	{
		sts=om$send(msg=message GRvg.GRchgweight(&msg,&dattr->weight),
                  		targetid = hdr -> objid,
                  		senderid = hdr -> objid,
                  		targetos = hdr -> osnum);
		_MO_omerr_chk("change_symb : chgweight", sts, wrapup);
	}
	return(1);

wrapup:
	return(0);
}

void GetMacroType(header,mtype)
struct GRid *header ;
int *mtype ;
{
	int sts ;
	char buff[100];
	sts = om$get_classname(objid = header -> objid, 
			       osnum = header -> osnum,
			       classname = buff);

	_pdm_debug("buff 1 %s ", buff );

	if( strcmp(buff,"ci_mac_def") == 0 ) 
		*mtype = 0 ;
	else     
        	*mtype = 1 ;
}

void do_clean_up(obj,rggrid,env)

	/* When placement fails, deletes the macro instance and 
	   ACrg_collect object template
	*/

GRobjid obj ;
struct GRid *rggrid;
struct GRmd_env *env ;

{
	int  cnt, sts  ;
	IGRlong msg ;

	om$send(msg = message GRgraphics.GRdelete(&msg,env),
        		senderid = obj,
        		targetid = obj,
			targetos = env -> md_id.osnum );
     
        /* delete Acrg_collect object if there are no dependents */

     	/* get the dependent children list */
     	sts = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN,NULL,
                                                       0,NULL,0,OM_K_MAXINT,&cnt),
                          senderid = rggrid -> objid,
                          targetid = rggrid -> objid,
			  targetos = env -> md_id.osnum );


     	_MO_omerr_chk("NDnode: NDgetobjects", sts, wrapup);

     	if(cnt > 0 )
	 	return;

     	/* if there are no dependents delete it */

	om$send(msg = message GRgraphics.GRdelete(&msg,env),
        		senderid = rggrid -> objid,
        		targetid = rggrid -> objid,
			targetos = env -> md_id.osnum );

	return;
wrapup:
	return;

} 

place_macro( env,num_temp,hdr,grid_list1, is_macro,plcmnt_mode,macro_name,part_no)
 struct GRmd_env  *env;
 int  num_temp;
 struct GRid  *hdr;
 struct GRid  *grid_list1 ;
 int  is_macro;
 char  plcmnt_mode ;
 char  *macro_name;
 char  *part_no ;

/*
int    num_temp, ismacro;
struct GRmd_env	*env;
struct GRid *hdr, *grid_list ;
char *macro_name,*part_no;
char plcmnt_mode ;
*/

{
int		sts, i ;
GRobjid		macro_obj;
struct  GRid    def_occ;
IGRlong         msg     ;
int		msg1;
char 		dir_name[DI_PATH_MAX];

        _pdm_debug("placing macro: %s", macro_name );
        _pdm_debug("numtemp: %d, ", num_temp);
	_pdm_debug("ismacro = %d",  is_macro);

        for( i = 0 ; i < num_temp ; i = i + 1 )
            _pdm_debug("grid: %d ", grid_list1[i].objid);

/*        sts = om$send(  msg      = message ACrg_collect.ACshow_data
                                        ( &msg ),
                        targetid = grid_list1[num_temp-1].objid,
                        senderid = grid_list1[num_temp-1].objid,
                        targetos = grid_list1[num_temp-1].osnum );

        as$status( sts = sts, msg = "Error in msg ACshow_data" ); */

        def_occ.objid	= NULL_OBJID;

        if(is_macro == 0 ){

		_pdm_debug("ismacro FALSE",0);
		macro_obj            = NULL_OBJID ;

		if( plcmnt_mode ==  'S' ) {
		_pdm_debug("placementmode = 'S'" ,0);

			om$construct( classid = OPP_ACci_header_class_id,
                		      osnum   = env -> md_id.osnum,
			              p_objid = &macro_obj );


	   		sts = om$send(	msg = message ACheader.ACmplace_from_def(
					&msg1,
					4,
					0,
					macro_name,
					num_temp,
					grid_list1,
					&def_occ,
					env ),

                	targetid = macro_obj,
			senderid = macro_obj );
		}
		else {
			_pdm_debug("placementmode != 'S'" ,0);
			om$construct( classid = OPP_nci_macro_class_id,
                		      osnum   = env -> md_id.osnum,
			              p_objid = &macro_obj );


	    		sts = om$send(msg = message ci_macro.init(&msg1, 4, macro_name,
					    num_temp, grid_list1,NULL,
					    env),
			targetid = macro_obj,
			targetos = env->md_id.osnum,
			senderid = macro_obj);
		}     

/* This check is commented since ci_macro.init returns wrong "msg"
		_MO_emerr_chk("nci_macro.init : MOplate", msg, wrapup);
*/
		_MO_omerr_chk("nci_macro.init : MOplate", sts, wrapup);
        }

        else{
		_pdm_debug("ismacro TRUE",0);
		macro_obj = NULL_OBJID ;
/*		if( plcmnt_mode == 'C'  ) { */
			_pdm_debug("placementmode = 'C'" ,0);
			om$construct( classid = OPP_ACconst_class_id,
                		      osnum   = env -> md_id.osnum,
			              p_objid = &macro_obj );

	            	sts = om$send(msg = message  ACconst.ACmplace(
        						    &msg1,4,0,
                                                            macro_name,
                                                            num_temp,
                                                            grid_list1,
							    env),
        	         			targetid = macro_obj,
        	         			senderid = macro_obj,
                	 			targetos = env -> md_id.osnum );

/*		}
		else {
			_pdm_debug("placementmode != 'C'" ,0);
			om$construct( classid = OPP_ACheader_class_id,
                		      osnum   = env -> md_id.osnum,
			              p_objid = &macro_obj );

	   		sts = om$send(msg = message ACheader.ACmplace_from_def(
					&msg1,
					4,
					0,
					macro_name,
					num_temp,
					grid_list1,
					&def_occ,
					env ),
				targetid = macro_obj,
				senderid = macro_obj,
				targetos = env -> md_id.osnum );
		} */
	}

	/*  To place a macro in drop mode    */
/*
struct NDcp_struct cp_info;

	cp_info.list = NULL;
	sts = om$send(msg = message ACexpand.ACmplace(&suc,0,
					  macro_name, num_temp,
                                          grid_list1, &cp_info, env),
	             targetid = macro_obj,
	             senderid = macro_obj,
 		     targetos = env -> md_id.osnum );
*/

        if( !( msg1 & 1) || !(sts & 1) ) {
          	_pdm_debug("Placement failed", 0);
                do_clean_up(macro_obj,&grid_list1[num_temp-1],env);
	       		free( (char *) grid_list1 ) ;
				grid_list1 = NULL ;

/* Do not go to wrapup and return(1). return(0) now.
		_MO_emerr_chk("place_macro : ACplace", msg1, wrapup);
		_MO_omerr_chk("place_macro : ACplace", sts, wrapup);
*/
                return(0);
        }

	free( (char *) grid_list1 );

	grid_list1 = NULL ;


        /* To add entry in directory */

        _pdm_debug("before naming in directory: %s", PDU_usage_id);

/* added */
        /* make absolute path from the main directory  */
       DIstmocpy(dir_name,"PDU","macro_parts",PDU_usage_id,0,env->md_id.osnum);

	_pdm_debug("absolute path : %s", dir_name);

       di$mkpath( pathname = dir_name );
/* end */

        sts = om$send(msg = message GRvg.GRchgname(&msg,env,dir_name),
                      targetid = macro_obj,
                      senderid = macro_obj,
                      targetos = env -> md_id.osnum );

        _MO_emerr_chk("GRchgname : name", msg, wrapup);
        _MO_omerr_chk("GRchgname : name", sts, wrapup);

	_pdm_debug("after naming object ", 0 );

        /* set symbology of object */
        set_feet_symbology(macro_obj,env);

        _pdm_debug("before setting feature symbology");

/*        push macro_obj, my_env ;

        ci$exec(file_name = "feature_symb.u" , entry = "hole_symb"); */

        sts = om$send( msg = message NDnode.NDdisplay(0, GRbd, env),
			  senderid = macro_obj,
			  targetid = macro_obj,
			  targetos = env ->md_id.osnum);

	_MO_omerr_chk("NDnode.NDdisplay : MOplate", sts, wrapup);

        /* create grpart 
        create_grpart(place_part_f,macro_obj);
	*/

wrapup:

	return(1);
}



set_feet_symbology(macobj,env)
GRobjid macobj ;
struct GRmd_env *env ;

	/** Set symbology of graphic feet of macro to current symbology **/
{
struct GRid glist , hdr;
short  mat_type, level   ;
IGRmatrix matrix ;
int i, num_feet , bufsiz, nret , sts;
struct myfeet *feet_desc ;
struct IGRdisplay display_attr ;
IGRlong msg ;
OMuword  obj_class ;

	_pdm_debug("in setting feet symbology %d",macobj);


        /* get module, level & display information */
        bufsiz = sizeof(struct IGRdisplay);
        gr$get_active_display(msg = &msg, sizbuf = &bufsiz, 
                        buffer = &display_attr, nret = &nret);

        bufsiz = sizeof(IGRshort);
        gr$get_active_level(msg = &msg, sizbuf = &bufsiz, 
                        buffer = &level, nret = &nret);

	sts = om$send( msg = message ACcpx.find_macro( &hdr),
        	         targetid = macobj,
        	         senderid = macobj,
                	 targetos = env -> md_id.osnum);

	_MO_omerr_chk("find_macro : macro", sts, wrapup1);

	/* Get feet and types */
	sts = om$send( msg = message ACcpx_defn . ACgive_feet_desc(&num_feet,
                                                             &feet_desc),
                      senderid = hdr.objid,
                      targetid = hdr.objid,
                      targetos = hdr.osnum );

	_MO_omerr_chk("ACgive_feet_desc : macro", sts, wrapup1);

	
	for( i = 0 ; i < num_feet ; i = i + 1 ) {

        	_pdm_debug("setting symbology for %s ",feet_desc[i].name);

		if( PDU_placement_type== 'S' ){
        		glist.objid = macobj;
        		glist.osnum = env -> md_id.osnum ;
        		change_symbology(&glist,&display_attr,level );
	        	return(1);
        	}

	        sts = om$send( msg = message ACncpx.ACreturn_foot(&msg,
                                      feet_desc[i].name,
                                      &glist,
                                      &mat_type,matrix),
			senderid = macobj,
			targetid = macobj,
			targetos = env -> md_id.osnum);

/** Commented this out, since ACreturn_foot message is not understood by
    other class objects on the foot list
		_MO_emerr_chk("ACreturn_foot : symb", msg, wrapup);
		_MO_omerr_chk("ACreturn_foot : symb", sts, wrapup);
**/  
                if ( msg == 0 )
			continue;

		om$get_classid( osnum = glist.osnum,
				objid = glist.objid,
				p_classid= &obj_class );

		if(om$is_ancestry_valid(superclassid = OPP_expression_class_id,
			      subclassid = obj_class) == OM_S_SUCCESS)
			continue ;

		if(om$is_ancestry_valid(superclassid = OPP_ACdyn_col_class_id,
			      subclassid = obj_class) == OM_S_SUCCESS)
			continue ;

		if(om$is_ancestry_valid(superclassid = OPP_GRvg_class_id,
			      subclassid = obj_class) == OM_S_SUCCESS)
        		change_symbology(&glist,&display_attr,level );
	        wrapup: 
        	continue;
    	}

	return(1);
wrapup1:
	return(0);
}

void get_mod_info(gmd_env)
struct GRmd_env *gmd_env ;
{
	int bufsiz;

        bufsiz = sizeof(struct GRmd_env);

	gr$get_module_env(sizbuf = &bufsiz, buffer = gmd_env);
}

void FlashMessage (msgnum)
int msgnum;
{
	char buff[100];

       	ex$message( msgnumb = msgnum,
                       buff = buff) ;
        warn_box(buff); 
}

void PALstatus_msg (msgnum)
int msgnum;
{

       	ex$message( msgnumb = msgnum,
                      field = 2) ;
}


check_obj_class(grid)
struct GRid grid ;
{
OMuword obj_class ;

            om$get_classid(objid = grid.objid,
		     osnum = grid.osnum,
		     p_classid = &obj_class);

            /* if an exp obj */
            if(om$is_ancestry_valid(superclassid = OPP_expression_class_id,
			      subclassid = obj_class) == OM_S_SUCCESS)
                   return(1);

            if(om$is_ancestry_valid(superclassid = OPP_text_exp_class_id,
			      subclassid = obj_class) == OM_S_SUCCESS)
                   return(1);

            return(0);
}

define_temp_to_ACdyncol(no,templist,rggrid,md_env)
int no;
struct GRid *rggrid , *templist;
struct GRmd_env *md_env ;
{

	int sts ;
	struct GRas as_list ;
	struct  ACcol_info      my_col_info;


_pdm_debug("Adding templates to ACdyncol",0);
_pdm_debug("num templates:%d",no);

        as_list.num_parents     = no;
	as_list.parents         = templist;
	as_list.as_attr         = (IGRchar *) &my_col_info;

	strcpy( my_col_info.pl_fct_name, "" );
	strcpy( my_col_info.cp_fct_name, "normal_cmpt" );


	sts = om$send(  msg      = message NDnode.NDplace(
                                        &as_list,
                                        md_env,
                                        NULL ),
                        targetid = rggrid -> objid,
                        senderid = rggrid -> objid,
                        targetos = md_env -> md_id.osnum );

	_MO_omerr_chk("NDnode.NDplace ", sts, wrapup);

_pdm_debug("Adding templates to ACdyncol SUCCESSFUL",0);
	return(1);

wrapup:
	return(0);


}

selection_temp_to_ACdyncol(no,templist,rggrid,md_env, numcoll)
int no , numcoll;
struct GRid *rggrid , *templist;
struct GRmd_env  *md_env ;
{

	int sts ;
	struct GRas as_list ;
	struct  ACcol_info      my_col_info;

/* for( sts = 0 ; sts < no ; ++sts )
	printf("templist: %d %d\n", templist[sts].objid, templist[sts].osnum );


printf("mod_id and osnum : %d %d\n", md_env->md_id.objid,md_env->md_id.osnum);
*/
 
        as_list.num_parents     = no;
	as_list.parents         = templist;
	as_list.as_attr         = (IGRchar *) &my_col_info;

/* Need to call dummy_place, even though the collection with selection criteria nolonger
   contains dynamic attributes. otherwise if no "place" function "compute" function is
   getting invoked at placement time. ---- checked on 07/04/93
*/
	if( numcoll == 1 )
		strcpy( my_col_info.pl_fct_name, "selection_place" );
	else
		strcpy( my_col_info.pl_fct_name, "dummy_place" );
	strcpy( my_col_info.cp_fct_name, "selection_compute" );


	sts = om$send(  msg      = message NDnode.NDplace(
                                        &as_list,
                                        md_env,
                                        NULL ),
                        targetid = rggrid -> objid,
                        senderid = rggrid -> objid,
                        targetos = rggrid -> osnum );

	_MO_omerr_chk("NDnode.NDplace ", sts, wrapup);

	return(1);

wrapup:
	return(0);


}


create_expression(expname,expval,expgrid,exptype)
char *expname, *expval ;
struct GRid *expgrid ;
int exptype ;
{
	int sts ;
	char a,b;
	short msg ;

        if( exptype  == 1 || exptype == EXP_DOUBLE  ){

	      sts = om$construct ( classid = OPP_expression_class_id,
				p_objid   = &expgrid -> objid ,
				osnum     = expgrid -> osnum );

	      _MO_omerr_chk("crete expression ", sts, wrapup);	     

 	      sts = om$send( msg = message  expression.create(expname, expval,&msg),
				   targetid = expgrid -> objid,
				   senderid = expgrid -> objid,
                                   targetos = expgrid -> osnum );
        }
        else{

	      sts = om$construct ( classid = OPP_text_exp_class_id,
				p_objid   = &expgrid -> objid ,
				osnum     = expgrid -> osnum );

	      _MO_omerr_chk("crete text expression ", sts, wrapup);	     

	      sts = om$send( msg = message  text_exp.create(expname, expval, &msg),
				   targetid = expgrid -> objid,
			           senderid = expgrid -> objid,
                                   targetos = expgrid -> osnum );
        }

	_MO_emerr_chk("crete expression ", msg, wrapup);
	_MO_omerr_chk("crete expression ", sts, wrapup);


	a = ~0 ;  b = ND_DEL_NO_CH|ND_WAIT_DEL ;
       	sts = om$send( msg = message NDnode.NDchg_state(a, b), 
               	             targetid = expgrid -> objid , 
                       	     targetos = expgrid -> osnum ,
			     senderid = expgrid -> objid );

   	_MO_omerr_chk("NDnode.NDchg_state : pal_chg_state () : ", sts, wrapup);


#ifdef DEBUG
	printf("exp objid: %d\n", expgrid -> objid );
#endif

	return(1);
wrapup:
	return(0);
}

attach_macro_lib( maclib)
char *maclib;
{
int sts;

        sts = ac$construct_path(mode= AC_ADD_PATH,
                                 name = maclib );
	if (sts != OM_S_SUCCESS)
		return(0);
	return(1);
}

end implementation GRvg;
