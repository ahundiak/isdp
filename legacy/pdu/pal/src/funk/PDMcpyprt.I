/************************************************************************/
/*                                                                	*/
/* This is the command object for copying a part already placed 	*/
/* in the design file.							*/
/*	. Locate part to be copied.					*/
/*									*/
/*	. Get original part's template description.			*/
/*		. Get its number of locatable templates			*/
/*		. Get its number of static attribute collections	*/
/*		. Get its number of dynamic attribute collection	*/
/*									*/
/*	. Get new locatbles templates for the copy			*/
/*									*/
/*	. Get new dynamic attributes values				*/
/*		. Create new dynamic attribute collections		*/
/*									*/
/*	. Place copy with original part's static attribute collections	*/
/*	  and								*/
/*	  new locatable templates					*/
/*	  plus								*/
/*	  new dynamic attribute collections.				*/
/*									*/
/*									*/
/* History:                                                       	*/
/*          Creation date:      09-July-92  M. M. Sarma           	*/
/*									*/
/*	    Modified to handle Multiple colloections.			*/
/*	    			18th, Nov, 1992	- Raj Shekar .P		*/
/*	    Modified :          05/02/92    D. KrishnaKumar		*/
/*									*/
/************************************************************************/

class implementation Root;

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "gr.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "nddef.h"
#include "graph.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "ci_mac_def.h"
#include "ci_macro.h"
#include "OMprimitives.h"
#include "parametric.h"
#include "expmacros.h"
#include "graph.h"
#include "ndmacros.h"
#include "macro.h" ;
#include "asbox.h"
#include "ACattrib.h"
#include "msdef.h"
#include "msmacros.h"
#include <PDUstr.h>
#include <PDUcommand.h>
#include <PDUprompt.h>
#include "macro.h"
#include "FI.h"
/* PAL include files */
#include "MOmacros.h"
#include "PALmsg.h"
#include "PALglbs.h"

#include <stdio.h>
#include "exmacros.h"
#include <string.h>
#include "dpmacros.h"

#define MAX_ROWS      100
#define MAX_TEMP      100

from ACmacro_defn import ACgive_upscan;
from NDnode     import NDget_objects    ;
from NDnode     import ASreturn_go      ;
from GRgraphics import GRchgname        ;
from ACcpx      import find_macro       ;
from ACcpx_defn import ACgive_name      ;
from ACcpx_defn import ACgive_temp_desc ;
from GRgraphics import GRdelete         ;

/**********   Externs from PDMselprt.c ***********/

extern char PDU_placement_type ;
extern struct GRid  *grid_list		;
/* extern struct GRid  DYNA_GRID_LIST[]    ; */
extern struct PDUrefresh	*refresh ;
extern char *PDU_usage_id ;

extern char 	**StatAttribs, **DynAttribs, **DynAttribTypes,**DynAttribDesc,
		**StatUnits,  **StatTypes ,**StatDesc ;

extern int	 	MAC_num_temp  ;
extern struct stemp	*MAC_temp_desc;
extern  char    *PALchild_no ;
/*************************************************/

/* Global  Variables */
extern int Num_Stat, Num_Dyn;

/* Static variables */
static struct GRmd_env		my_env;

static int     sts;
static IGRlong msg;
static char  *macname ;
static struct GRid datum_grid ;
static int  ismacro;
static char placement_type[3];

extern OMuword OPP_nci_macro_class_id ;
extern OMuword OPP_ACconst_class_id ;
extern int	PDU_command             ;

static int	selci_macro;	    /* Flag for selection cimacro placement (if set) */

/* #define DEBUG 1 */

extern Form PDU_desrev_fp;

#define	STATIC	0
#define	DYNAMIC	1

void PALcopy_part(frfp)
Form frfp;
{            
	selci_macro  = 0;
	PDU_desrev_fp = frfp ;
	get_mod_info(&my_env);

	{
		int             responses[1]	;
		char            *strings[1];		
                char *prompt_msg = NULL;

/**** CHANGE THE COMMAND NAME AND STRING LATER **************/
		PDU_command = PDC_M_COPY_PPART;
		responses[0] = EX_CMD_KEY;
		strings[0] = "PDCpPPr";

		PDUprepare_queue(responses,strings,1);
	}
/*
        for( ; ; ) 
	{

                ex$message( msgnumb = PDR_P_CpyPrt,
                              buff  = error_msg );

                prompt_msg = 
                   (char *)PDUtranslate_message(PDP_P_IDENTIFY_OR_MOVEON);
		response = PALloc_obj(prompt_msg,&my_env,&datum_grid,2);

		if( response < 0 )
			continue;

		if( !response )
			break;


		copy_prpart(&datum_grid);

        }  end of for loop */
}

/* This is a DUMMY FUNCTION TO AVOID UNRESOLVED PROBLEM until PDM changes in its
   code to use PPL command 
*/

copy_prpart( part )
struct GRid *part;
{
	_pdm_debug("coming into the dummy function copy_prpart %d",part->objid);
	return(1);
}

copy_attribute(attrib, type, fromrg_grid, torg_grid)
char *attrib;
char *type;
struct GRid *fromrg_grid, *torg_grid ;
{
	int alloc_size ;
	char *text_val ;

	_pdm_debug("enter copy_attribute: ", 0 );

	text_val = (char *)malloc(30);
	alloc_size = 30 ;
	text_val[0] = '\0' ;

	if(!GetACrgAttribVal(fromrg_grid, attrib, &text_val, &alloc_size))
		return(0);
	
	text_val[strlen(text_val)-1] = '\0' ;

	_pdm_debug("text_val: %s", text_val );
	_pdm_debug("temp type: %s", type);
		
	if( !strcmp(type,"Expression double"))
	        add_attribute(torg_grid,text_val,attrib,AC_ATTRIB_DOUBLE);
	else
	        add_attribute(torg_grid,text_val,attrib,AC_ATTRIB_TEXT);

	free( text_val);

	return(1);
}

GetNumCollections( partid, hdr, numcoll )
struct GRid *partid, *hdr;
int *numcoll;
{
int num_loc;

	if( !GetMacroHeaderGivenGrid( *partid, hdr ) )
		return( 0 );

	if (!GetOriginalMacroInfo (hdr, &MAC_temp_desc, &MAC_num_temp, &num_loc, numcoll))
		return (0);

	return(1);
}


Make_copy(grid, hdr, coll_list, num_coll, flag)
struct GRid *grid ;
struct GRid *hdr, **coll_list;
int num_coll, flag;       /* flag = 1 - Associative copy; 0 - NonAssociative copy */
{
	int	alloc_size, i;
	char 	*cat_name, *ptr;
	char    *part_id = NULL, *revnum = NULL;
	int	 num_loc;
	struct	GRid	cat_attr_coll;

	datum_grid = *grid ;

	if( !GetNumLocatable(MAC_temp_desc, MAC_num_temp, &num_loc))
		return(0);

	/* The FIRST collection containing the catalog attributes	*/
	/* (that are not templates to the macro ) comes after the 	*/
	/* locatable templates and is at 'num_loc'eth position	*/

	if (!get_acdyncol_temp(&datum_grid, &cat_attr_coll, num_loc))
		return (0);

	_pdm_debug ("cat_attr_coll : %d\n", cat_attr_coll.objid );

	alloc_size=20;
	cat_name=malloc(alloc_size);
	cat_name[0] = '\0' ;

	if( !GetACrgAttribVal(&cat_attr_coll, "n_catalogname",&cat_name,
								&alloc_size))
		return(0);

	cat_name[strlen(cat_name)-1]= '\0';
	_pdm_debug("catalog name : %s", cat_name);

	alloc_size=20;
	part_id=malloc(alloc_size);
	part_id[0] = '\0' ;

	if(!GetACrgAttribVal(&cat_attr_coll, "n_itemname",&part_id,&alloc_size))
		return(0);

	part_id[strlen(part_id)-1]= '\0' ;  

	alloc_size=20;
	revnum=malloc(alloc_size);
	revnum[0] = '\0' ;

	if( !GetACrgAttribVal(&cat_attr_coll, "n_itemrev",&revnum,&alloc_size))
		return(0);

	revnum[strlen(revnum)-1]= '\0' ;

	if( !GetStatAndDynAttribs ( 
				cat_name,
				&Num_Stat,
				&StatAttribs, &StatTypes,&StatDesc,&StatUnits,
				&Num_Dyn,
				&DynAttribs, &DynAttribTypes, &DynAttribDesc
				))
		return(0);

	_pdm_debug("no. of stat temp = %d", Num_Stat );
	_pdm_debug("no. of dyn  temp = %d", Num_Dyn  );

	mystrcpy(&refresh -> rev_catalog,cat_name);
	mystrcpy(&refresh -> rev_partid,part_id);
	mystrcpy(&refresh -> rev_revision,revnum);
	mystrcpy(&refresh -> rev_parttype,"P");

	*coll_list = (struct GRid *) malloc (sizeof(struct GRid) * num_coll);
	MemCheck((*coll_list));

	for (i = 0; i < num_coll; i++) 
		(*coll_list)[i].objid = NULL_OBJID;

	if( Num_Stat == 0 )	
	{
		if( flag )   /* Assoc copy - Use old static collection */
			(*coll_list)[0] = cat_attr_coll;
		else
		{
			if(!PDUcreat_rgbox("", &my_env, *coll_list))
			{
				_pdm_debug("PDUcreat_rgbox1 failed",0);
				return(0);
			}
			if(!PDUcreat_rgbox("", &my_env, &(*coll_list)[num_coll-1]))
			{
				_pdm_debug("PDUcreat_rgbox1 failed",0);
				return(0);
			}
			/* add standard attributes */
			PALchild_no = NULL; /* This will generate a new child no. */
			AddStdAttribsToColl( *coll_list, num_coll, refresh->rev_catalog,
					 refresh->rev_partid, refresh->rev_revision,
								     &my_env) ;
		}
	}
	else
	if(!GetAttrCollAndFillCollList (STATIC, *coll_list, num_loc, num_coll, flag))
		goto wrapup;

	if(!GetAttrCollAndFillCollList (DYNAMIC, *coll_list, num_loc, num_coll, flag))
		goto wrapup;

	ptr = part_id;
	while( *ptr )
		if( *ptr++ == '$' )
			break;
	if( *ptr != '\0') /*  A formula */
		mystrcpy(&refresh -> rev_partid,"computable");

	MyFree ( part_id );
	MyFree ( revnum );
	MyFree( cat_name );

	if(!GetMacroNameFromInstance(hdr,&ismacro,placement_type))
		return(0);

	return( 1 );
wrapup:
	MyFree(*coll_list);
	return(0);
}

Copy_ppart( hdr, env, numgrids )
struct GRid *hdr;
struct GRmd_env *env;
int numgrids;
{
int sts;
char *partname = NULL;

	_pdm_debug("before place_macro()",0);

	sts = place_macro(env, numgrids, hdr, grid_list,
		ismacro, placement_type[0], macname, partname );

	if( sts )
		PDUincrement_child_no( env->md_id.osnum );

	return( sts );
}


GetMacroNameFromInstance(hdr,ismacro,placement_type)
struct GRid *hdr;
int *ismacro ;
char *placement_type;

{
char error_msg[100] ;
	

	sts = om$send( msg = message ACcpx.find_macro( hdr),
                      	         senderid = datum_grid.objid,
                      	         targetid = datum_grid.objid,
        	        	 targetos = datum_grid.osnum);

	_MO_omerr_chk("ACload_macro : macro", sts, wrapup);

	sts = om$get_classname(objid = hdr -> objid, 
			       osnum = hdr -> osnum,
			       classname = error_msg);

	_MO_omerr_chk("get_classname : macro", sts, wrapup);

#ifdef DEBUG
	printf("header class: %s\n", error_msg );
#endif

	if( !strcmp(error_msg,"ACheader") || !strcmp(error_msg,"ACci_header") )
	        strcpy(placement_type, "S");
	else 
	        strcpy(placement_type, "C");


	sts = om$send( msg = message ACcpx_defn.ACgive_name(&macname),
                                  senderid = hdr -> objid,
                                  targetid = hdr -> objid,
                                  targetos = hdr -> osnum );                   


	_pdm_debug("macro name: %s", macname );

	if( strcmp(error_msg,"ci_mac_def") == 0 ) 
        	*ismacro = 0 ;
	else     
	        *ismacro = 1 ;


	/* Get templates and types 
	sts = om$send( msg = message ACcpx_defn.ACgive_temp_desc(&mac_num_temp,&temp_desc),
        			senderid = hdr -> objid,
        			targetid = hdr -> objid,
			        targetos = hdr -> osnum );

	_MO_omerr_chk("ACgive_temp_desc : macro", sts, wrapup);
	*/

	return(1);
wrapup:
	return(0);
}

get_acdyncol_temp(part_grid, acdyn_coll, coll_ndx)
struct GRid *part_grid;
struct GRid *acdyn_coll;
int coll_ndx;
{
	int sts, cnt=1  ;
	IGRmatrix tmat;
	short mat_type;

	_pdm_debug("Getting acdyncol at index %d", coll_ndx);

     	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, acdyn_coll, 1,
						    NULL, coll_ndx, coll_ndx, &cnt),
                       	targetid = part_grid -> objid, 
                       	targetos = part_grid -> osnum,
			senderid = part_grid -> objid);

     	_MO_omerr_chk("GetCatalogTemplateValue () : NDnode.NDgetobjects ",  sts,  wrapup);

	if( !cnt )
	{
		_pdm_debug("Could not get the root at this index",0);
		return(0);
	}

	/* Might be a pretend, get the original.	*/
	sts = om$send(msg = message NDnode.ASreturn_go( acdyn_coll,
							&mat_type, 
							tmat),
					senderid = acdyn_coll->objid,
					targetid = acdyn_coll->objid,
					targetos = acdyn_coll->osnum);
	return(1);
wrapup:
	return(0);
}

void PALdel_part(frfp)
Form frfp ;
{            
	PDU_desrev_fp = frfp;

	{
		int             responses[1]	;
                char *prompt_msg = NULL;
		char            *strings[1];		

/**** CHANGE THE COMMAND NAME AND STRING LATER **************/
/*		PDU_command = PDC_M_DELETE_PPART; */
		responses[0] = EX_CMD_KEY;
		strings[0] = "PDDlPPr";

		PDUprepare_queue(responses,strings,1);
	}


	/* locate object
        prompt_msg = (char *)PDUtranslate_message(PDP_P_IDENTIFY_OR_MOVEON);    
        for( ; ; ) 
	{
		response = PALloc_obj(prompt_msg,&my_env,&datum_grid,3);

		if( response < 0 )
			continue;

		if( !response )
			break;

		delete_prpart(&datum_grid,&my_env);

        }  end of for loop */
}

delete_prpart_old(grid,lenv)
struct GRid *grid ;
struct GRmd_env *lenv;
{
	int sts, cnt = 0 ;
	struct GRid col_grid ;

	/* Get then collection templates obj id */
     	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, NULL, 0,
						    NULL, 0,OM_K_MAXINT , &cnt),
                       	targetid = grid->objid, 
                       	targetos = grid->osnum,
			senderid = grid->objid);

     	_MO_omerr_chk("delete_prprt() : NDnode.NDgetobjects ",  sts,  wrapup);

     	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, &col_grid, 1,
						    NULL, cnt-1, cnt-1, &cnt),
                       	targetid = grid->objid, 
                       	targetos = grid->osnum,
			senderid = grid->objid);

     	_MO_omerr_chk("delete_prprt() : NDnode.NDgetobjects ",  sts,  wrapup);


	if( cnt ) /* If the Part has some roots only see TR#92W2800 */ 
	{
		_pdm_debug("ACdyncolobj:%d",col_grid.objid);

		/* Delete collection object if there are no dependents */
     		/* get the dependent children list */
     		sts = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN,
								  NULL,
                                                       		  0,NULL,0,
								  OM_K_MAXINT,
								  &cnt),
                          senderid = col_grid.objid,
                          targetid = col_grid.objid,
			  targetos = col_grid.osnum );

     		_MO_omerr_chk("delpart:NDnode: NDgetobjects", sts, wrapup);

     		if(cnt == 1 ) {
		sts = om$send(msg = message GRgraphics.GRdelete(&msg,lenv), /* changed from &my_env */
			targetid = col_grid.objid,
			senderid = col_grid.objid,
			targetos = col_grid.osnum);
		}
	}

	dp$display(
                msg = &sts,
                oids = grid ,
                mode = GRbe
               );

	sts = om$send(msg = message GRgraphics.GRdelete(&msg,lenv), /* changed from &my_env */
			targetid = grid -> objid,
			senderid = grid -> objid,
			targetos = grid -> osnum);

	return(1);
wrapup:
	return(0);
}

delete_prpart(grid,lenv)
struct GRid *grid ;
struct GRmd_env *lenv;
{
	int sts, cnt = 0 ;
	struct GRid *col_grid ;

	/* TR# 13941 6347.	*/
	extern short PDU_activate_delete;

	int	ii, dep_cnt;
	char	class_name[132];

	/* Get templates' obj ids */
     	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, NULL, 0,
						    NULL, 0,OM_K_MAXINT , &cnt),
                       	targetid = grid->objid, 
                       	targetos = grid->osnum,
			senderid = grid->objid);

     	_MO_omerr_chk("delete_prprt() : NDnode.NDgetobjects ",  sts,  wrapup);

	col_grid = (struct GRid *) malloc (cnt * sizeof (struct GRid));
	if (col_grid == NULL)
	{
		_pdm_debug ("Unable To Allocate Memory in  delete_prpart()\n", 0);
		return (0);
	}

     	sts = om$send( msg = message NDnode.NDget_objects(ND_ROOT, col_grid,
						cnt, NULL, 0, cnt-1, &cnt),
                       	targetid = grid->objid, 
                       	targetos = grid->osnum,
			senderid = grid->objid);

     	_MO_omerr_chk("delete_prprt() : NDnode.NDgetobjects ",  sts,  wrapup);


	for (ii = 0; ii < cnt; ii = ii + 1)
	{
	
		sts = om$get_classname(	objid = col_grid[ii].objid, 
					osnum = col_grid[ii].osnum,
					classname = class_name);
			
		_MO_omerr_chk("get_classname : macro", sts, wrapup);

		_pdm_debug ("Template id	 : %d", col_grid[ii].objid);
		_pdm_debug ("Template class name : %s", class_name);

		/* We will clean up only ACdyn_col template objects.	*/
		if (strcmp (class_name, "ACdyn_col"))
			continue;

		/* Delete collection object if there are no dependents */
     		/* get the dependent children list */
     		sts = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN,
						  NULL,
       		                       		  0,NULL,0,
						  OM_K_MAXINT,
						  &dep_cnt),
			senderid = col_grid[ii].objid,
			targetid = col_grid[ii].objid,
			targetos = col_grid[ii].osnum );

		_MO_omerr_chk("delpart:NDnode: NDgetobjects", sts, wrapup);

     		if(dep_cnt == 1 )
		{
			sts = om$send(msg = message GRgraphics.GRdelete(&msg,lenv), /* changed from &my_env */
				targetid = col_grid[ii].objid,
				senderid = col_grid[ii].objid,
				targetos = col_grid[ii].osnum);
			_pdm_debug ("\t The above template is DELETED", 0);
		}
	}

	dp$display(
                msg = &sts,
                oids = grid ,
                mode = GRbe
               );

	if (!PDU_activate_delete) /* TR# 13941 6347. To avoid endless loop
				  if delete is not invoked from GRdelete
				  method. This flag then is TRUE.	*/
	sts = om$send(msg = message GRgraphics.GRdelete(&msg,lenv), /* changed from &my_env */
			targetid = grid -> objid,
			senderid = grid -> objid,
			targetos = grid -> osnum);

	free ((char *) col_grid);

	return(1);

wrapup:
	free ((char *) col_grid);

	return(0);
}

GetAttrCollAndFillCollList (flag, coll_list, num_loc, numcoll, asflg)
int	flag, asflg;
int  num_loc, numcoll;
struct GRid *coll_list;
{
int	i, coll_index, num_attr, dynloc = 0;
char    **Attribs;
struct  GRid frcoll;

	if( flag == STATIC )
	{
		num_attr = Num_Stat;
		Attribs = StatAttribs;
	}
	else
	{
		num_attr = Num_Dyn;
		Attribs = DynAttribs;
	}

	for (i = 0; i < num_attr; i++) 
	{
		if (GetDyncolIndx(MAC_temp_desc, Attribs[i], MAC_num_temp, num_loc,
							 &coll_index) == -1)
		{
			if ( flag == DYNAMIC ) 
			{
				dynloc++;
				continue;    /* Dynamic Locatable types are not mapped */
			}
			else
			/* CHANGED behaviour for the sake of PDMNORM, Vdaps 
                           CIMacro, which has unmapped attributes - 23/06/93 */
				coll_index = 0;				
/*				return (0);*/
		}
		if( coll_list[coll_index].objid == NULL_OBJID )
		{
	    		if (flag == STATIC) 
			{
				if( asflg == 1 ) /* Use old static collection itself */
				{
					if (!get_acdyncol_temp(&datum_grid, 
							&coll_list[coll_index], 
							num_loc + coll_index))
						return (0);
				}
				else /* Create new collection, add stdattrs and this */
				{
					if(!PDUcreat_rgbox("", &my_env, &coll_list[coll_index]))
					{
						_pdm_debug("PDUcreat_rgbox1 failed",0);
						return(0);
					}
					if( coll_index == 0 )
					{
						/* Create the last dynamic collection also */
						if(!PDUcreat_rgbox("", &my_env, &coll_list[numcoll-1]))
						{
							_pdm_debug("PDUcreat_rgbox1 failed",0);
							return(0);
						}
						/* add standard attributes */
						PALchild_no = NULL; /* This will generate a new child no. */
						AddStdAttribsToColl( coll_list, numcoll, 
								     refresh->rev_catalog,
								     refresh->rev_partid,
								     refresh->rev_revision,
								     &my_env) ;
					}
					if (!get_acdyncol_temp(&datum_grid, &frcoll, 
									num_loc+coll_index))
						return (0);

					if(!copy_attribute(StatAttribs[i], StatTypes[i],
							 &frcoll, &coll_list[coll_index]))
						return(0);
				}
			}
			else if (flag == DYNAMIC) 
			{
				if( coll_index == (numcoll - 1) ) /* last collection */
				{
					_pdm_debug("creating new std dyn collection",0);
					if( !create_newdyncol(coll_list,coll_index,num_loc,1))
						return(0);
				}
				else
					if(!create_newdyncol(coll_list,coll_index,num_loc,0))
						return(0);
			}
		}
		else if( (flag == STATIC) && !asflg ) /* Add static attr to new coll */
		{
			if (!get_acdyncol_temp(&datum_grid, &frcoll, num_loc+coll_index))
				return (0);

			if(!copy_attribute(StatAttribs[i], StatTypes[i], &frcoll, 
								&coll_list[coll_index]))
				return(0);
		}
	}

	if ( (flag == DYNAMIC) && (num_attr == dynloc) )
		if( !create_newdyncol(coll_list,numcoll-1,num_loc,1))
			return(0);

	return (1);
}

create_newdyncol( list, indx, numloc, flg )
struct GRid *list;
int indx, numloc, flg;
{
struct GRid frcoll;
char *childno = NULL;

	if(!PDUcreat_rgbox("", &my_env, &list[indx]))
	{
		_pdm_debug("PDUcreat_rgbox failed",0);
		return(0);
	}
	if( flg )		/* Add standard dyn attrs */
	{
		if (!get_acdyncol_temp(&datum_grid, &frcoll, numloc+indx))
			return (0);
			
		PDUgenerate_child_no (&childno, my_env.md_id.osnum);

		_pdm_debug("index = %d", indx);
	        add_attribute( &list[indx],childno,"serial_no",AC_ATTRIB_TEXT);

		if(!copy_attribute("p_incbom","Expression text", &frcoll, &list[indx]))
			return(0);

		if(!copy_attribute("p_incstr","Expression text", &frcoll, &list[indx]))
			return(0);

		if(!copy_attribute("p_attach","Expression text", &frcoll, &list[indx]))
			return(0);
	}

	return(1);
}

end implementation Root ;
