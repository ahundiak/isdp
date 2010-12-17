/***************************************************************************/
/*                                                                         */
/*   This file contains routines to fill in 'part_list' buffer of global   */
/*   structure PDUrefresh. Scans the directory :macro_parts                */
/*                                                                         */
/*           File Creation Date:     02-July-92   MMS (IGI)                */
/*           File Modified Date:     05-Jan-93    DKK (IGI)                */
/*                                                                         */
/***************************************************************************/

class implementation Root;

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <sys/param.h>
#include <MEMstruct.h>
#include <PDUstr.h>
#include <PDUmacros.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dp.h"
#include "gr.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "ci_mac_def.h"
#include "ci_macro.h"
#include "cisymb.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "MOmacros.h"
#include "MEMerrordef.h"
#include "PDUfile_def.h"
#include "nddef.h"
#include "macro.h"
#include "PDUerror.h"       
#include "PALglbs.h"       


#include "FI.h"
#include "MEMstruct.h"

/*#include "PDUproto.h"*/
#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"

from ACmacro_defn import ACgive_upscan;
from ACrg_collect import ACget_named_attribute;
from NDnode import NDget_objects, ASreturn_go;
from ACncpx import ACreturn_foot ;
from ACcpx import find_macro ;
from ACcpx_defn import ACgive_feet_desc ;
from expression import give_formula ;

extern int   PDMdebug_on ;
extern struct PDUrefresh *refresh ;
extern struct GRmd_env lmod_env ;
extern OMuword OPP_ACcpx_class_id ;
extern OMuword OPP_ACdyn_col_class_id ;
extern OMuword OPP_text_exp_class_id ;
extern OMuword OPP_Gexp_class_id ;
#define	AC_ATTRIB_MASK_TYPE	0x00ff

static char **dynattr, **dyntype, **dynvals;
static int  numdyn;

extern MEMptr PDU_child_buffer, PDU_param_buffer;

%safe
extern MEMptr PDUchild_dyn_buffer;
%endsafe

PALchekin(lenv)
struct GRmd_env *lenv ;

{
	struct GRid dir_grid, part_grid ;
	int    i,nb_lines, sts = 0 ;
        int    status;
	char   **lines;
	GRobjid macro ;
	OMuword classid ;
		
	if( PDU_param_buffer != NULL )
		MEMclose(&PDU_param_buffer);

	/* format grand child_buffer */
	if(  PDMcr_para_ass_bufr(&PDU_param_buffer) != PDM_S_SUCCESS )
		return(0);

	if(PDMdebug_on)
		MEMprint_buffers("PDU_param_buffer: ", PDU_param_buffer,PDU_DEBUG_FILE);
	
	lmod_env = *lenv ;

	/* Read the directory struture :PDU:macro_part: level to get list
	   of objects 
	*/

	if( !get_nblines_in_dir(&nb_lines,&lines,&dir_grid,lmod_env.md_id.osnum))
		return(0);
        
        /* Added by JAMAL */
        if (PDU_child_buffer == NULL)
          {
           status = PDUformat_buffer(PDU_CHILD_BUFR, &PDU_child_buffer);
           _pdm_status("PDUformat_buffer", status);
          }

	sts = 1 ;

	for(i = 0 ; i < nb_lines ; i = i + 1 ){

		remove_brackets(lines[i]);

		macro = NULL_OBJID ;

		sts = di$translate ( objname = lines[i],
                                     osnum   = dir_grid.osnum,
		             	     p_objid = &macro);

		_pdm_debug("macro: %s",lines[i]);

		/* get feet of ci_macro */
		if( macro != NULL_OBJID && macro != 0 ){

			sts = om$get_classid(   objid     = macro, 
			       			osnum     = lmod_env.md_id.osnum,
			       			p_classid = &classid);

			if( om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
				  subclassid  = classid ) == OM_S_SUCCESS ){

				part_grid.objid = macro ;
				part_grid.osnum = lmod_env.md_id.osnum ;

				sts = update_part_list_bufr(&part_grid,NULL);
				if(sts==-1){
					sts = 0;
					break;
				}
				else if ( !sts ) break;
			}
		}
	}

	if(lines != NULL && nb_lines != 0)
        	di$free(lines = lines,count = nb_lines);

	return(sts);
}


/* This parameter added only for those places where only the child no. is required
   given the part id
*/
update_part_list_bufr( part_grid , attr_name)
struct GRid *part_grid;
char *attr_name;
{

	int 	alsize = 512 , tbl_no = -1;
	int	status, num_coll;
	char 	*str = NULL,  *catname = NULL, *partname = NULL,*partrev= NULL  ;
	struct 	GRid 		cat_attr_coll, dyn_attr_coll;
	struct  GRid            *coll;
	
	/* Part at main directory level goes into PDU_child_buffer */
	str = (char *) malloc(alsize);
	str[0] = '\0' ;

	if( !GetCollsList( part_grid, &coll, &num_coll ))
		return(0);

	cat_attr_coll = coll[0];
	dyn_attr_coll = coll[num_coll - 1];

	_pdm_debug("Dyncollection objid %d", dyn_attr_coll.objid);
	_pdm_debug("Dyncollection osnum %d", dyn_attr_coll.osnum);

	/* Get the catalog attributes from the FIRST collection */

	catname  = (char *)malloc(20); catname[0] = '\0' ;
	partname = (char *)malloc(80); partname[0] = '\0' ;
	partrev  = (char *)malloc(80); partrev[0] = '\0' ;

	if(! GetACrgAttribVal(&cat_attr_coll,"n_catalogname",&catname,&alsize))
		goto wrapup;
	catname[strlen(catname)-1] = '\0' ;

	if( !GetACrgAttribVal(&cat_attr_coll,"n_itemname",&partname,&alsize))
		goto wrapup;
	partname[strlen(partname)-1] = '\0' ;

	if( !GetACrgAttribVal(&cat_attr_coll,"n_itemrev",&partrev,&alsize))
		goto wrapup;
	partrev[strlen(partrev)-1] = '\0' ;
		
	alsize = 512 ;
	if( !GetACrgAttribVal(&dyn_attr_coll,"serial_no",&str,&alsize) )
		goto wrapup;

		
	strcat(str,catname);
	strcat(str,"\1");
	strcat(str,partname);
	strcat(str,"\1");
	strcat(str,partrev);
	strcat(str,"\1");

	tbl_no = -1 ;
	  

	strcat(str,"\1");    /* p_attached - not to be set for param parts */

	/* Get standard dynamic attributes	*/
		
	if( GetACrgAttribVal(&dyn_attr_coll,"p_quantity",&str,&alsize))
	  if( GetACrgAttribVal(&dyn_attr_coll,"p_usageid",&str,&alsize))
	   if( GetACrgAttribVal(&dyn_attr_coll,"p_tagno",&str,&alsize))
	    if( !GetACrgAttribVal(&dyn_attr_coll,"p_alttagno",&str,&alsize)) 
		strcat(str,"\1");

	/* Get p_incbom from the FIRST collection */
	if( GetACrgAttribVal(&dyn_attr_coll,"p_incbom",&str,&alsize))
			tbl_no = 1 ;

        _pdm_debug("tbl_no = <%d>", tbl_no);

	if( tbl_no == -1 )
		goto wrapup;

	str = (char *) realloc(str,strlen(str)+ 128 );

	strcat(str,"\1");    /* p_explode - not to be set for param parts */
	strcat(str,"\1");    /* n_cofilename - not to be set for param parts */
	strcat(str,"\1");    /* p_history    - not to be set for param parts */
	strcat(str,"\1");    /* n_cofilename */
	strcat(str,"\1");    /* n_catalogno  */
	strcat(str,"\1");    /* n_lelve      */

	tbl_no = 1;

	/* Write the data to part_list buffer of global structure */
	status = MEMwrite(PDU_child_buffer,str);
        _pdm_status("MEMwrite", status);

         if (status != MEM_S_SUCCESS)
           { 
		_pdm_debug("Error writing to PDU_child_buffer\n",0);
		MEMclose(&PDU_child_buffer);
		tbl_no = -1 ;
		goto wrapup;
	}

	if(PDMdebug_on)
		MEMprint_buffers("child: ", PDU_child_buffer,PDU_DEBUG_FILE);

	if( !Process_feet_of_assbly(part_grid,catname,partname,partrev))
		tbl_no = 0;


wrapup:
	MyFree( str ); 	
	MyFree( catname );
	MyFree( partname );
	MyFree( partrev );

	return(tbl_no);
}

Process_feet_of_assbly(part_grid,catname, partname, partrev )
struct GRid *part_grid;
char *catname, *partname, *partrev ;
{
	int i, sts ;
	struct GRid *feetlist = NULL;
	int num_feet ;
	OMuword  classid ;
	char classname[156];

	/* Parts at foot level of macros instanced in design file go
	   into grand child buffer 
	*/	

        GetFeetObjects( part_grid, &num_feet, &feetlist );

	_pdm_debug("Total num of feet (incl. templ_feet) = %d", num_feet );

        for( i = 0; i < num_feet; i++ )
        {
           	/* Get the ACcpx objects on the footlist of the part, if any */
        	sts = om$get_classid(   objid     = feetlist[i].objid, 
	           			osnum     = feetlist[i].osnum,
	           			p_classid = &classid);

		_pdm_debug("foot %d is of", feetlist[i].objid);
        	sts = om$get_classname(   objid     = feetlist[i].objid, 
	           			osnum     = feetlist[i].osnum,
	           			classname = classname);

		_pdm_debug(" class:    %s", classname );

        	if( om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
                		subclassid  = classid ) == OM_S_SUCCESS )
	        {
		        dynattr = (char **)malloc(sizeof(char *));
        		dyntype = (char **)malloc(sizeof(char *));
        		dynvals = (char **)malloc(sizeof(char *));
	        	numdyn = 0;

			/* Open the global buffer, for the first time. It should be
                           closed by the function calling PALchekin().
			*/

			if( PDUchild_dyn_buffer == NULL )
			if( (sts = MEMopen(&PDUchild_dyn_buffer,512)) != MEM_S_SUCCESS ) 
			{
				_pdm_debug("MEMopen failure : status = <0x.%8x>", sts );
				goto wrapup;
			}

                        _pdm_debug("call updategrandchild", 0);
			if( !UpdateGrandChild(&feetlist[i],catname,partname,partrev))
				goto wrapup;
		}
	}

        if( feetlist )
            free( feetlist );
	return(1);
wrapup:
 	return(0);
}

GetFeetObjects( part_grid, num_feet, feet )
struct GRid *part_grid;
int *num_feet;
struct GRid **feet;
{
OM_S_CHANSELECT to_components;
OM_S_OBJECT_LINKAGE *list = NULL;
unsigned int total_count;
int i, j, sts, numcoll;
IGRshort mat_type ;
IGRmatrix tmat ; 
struct GRid *loc_feet = NULL, *coll;
GRclassid classid;

	sts = om$make_chanselect( channame = "GRcmpowner.to_components",
				p_chanselect = &to_components );

	sts = om$get_channel_count(objid = part_grid->objid,
				   osnum = part_grid->osnum,
				   p_chanselect = &to_components,
				   count = &total_count);

	_pdm_debug("feet count = %d", total_count );

	if (!total_count)
	    goto getcoll; /* No feet ??? */

        list = (OM_S_OBJECT_LINKAGE *)
        	malloc( (total_count) * sizeof(OM_S_OBJECT_LINKAGE) );

	sts = om$get_channel_objects( objid = part_grid->objid,
			         osnum = part_grid->osnum,
                                 p_chanselect = &to_components,
                                 list = list,
                                 size = total_count,
                                 count = &total_count);

	for( i =0; i < total_count; i++ )
	 _pdm_debug("foot.objid = %d", list[i].S_objid );

        loc_feet = (struct GRid *)malloc( total_count * sizeof( struct GRid ));
	for ( i = 0; i < total_count; i++ )
	{
		loc_feet[i].objid = list[i].S_objid;
		loc_feet[i].osnum = list[i].osnum;

        	sts = om$get_classid(   objid     = loc_feet[i].objid, 
	           			osnum     = loc_feet[i].osnum,
	           			p_classid = &classid);

        	if( om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
                		subclassid  = classid ) != OM_S_SUCCESS )
		{
  		  sts = om$send(msg = message NDnode.ASreturn_go( &loc_feet[i],
							&mat_type, 
							tmat),
					senderid = loc_feet[i].objid,
					targetid = loc_feet[i].objid,
					targetos = loc_feet[i].osnum);
		}
	     _pdm_debug("foot.objid = %d", loc_feet[i].objid );
	}

getcoll:
	/* Add the template collections to the feet list */
	GetCollsList( part_grid, &coll, &numcoll );

/*	21/Dec/93 - raj.	TR# 13931 4526.			*/
/*	If it goes to wrapup the feet info. is not returned.	*/
/*	if( !numcoll )
		goto wrapup;					*/

	for( i = 0;i < numcoll; i++ )
	{
		for( j = 0;j < total_count; j++ )
		   if( (coll[i].objid == loc_feet[j].objid) &&
		       (coll[i].osnum == loc_feet[j].osnum) )
		      break;

		if( j == total_count ) /* not found */
		{
		  /* TR# 13941 8568. When no. of feet (total_count) == 0:
		  control jumps to label getcoll above and loc_feet is not
		  allocated for previously. So use malloc instead of realloc
		  for the first time. */
		  if (total_count == 0)
		  {
		    loc_feet = (struct GRid *) malloc(1 * sizeof(struct GRid));
		  }
		  else
		  {
		    loc_feet = (struct GRid *)realloc( loc_feet,
				(total_count+1) * sizeof( struct GRid ));
		  }
		  loc_feet[j] = coll[i];
		  total_count++;
		}
	}
        *num_feet = total_count; 
	*feet = ( struct GRid *)malloc( total_count * sizeof( struct GRid ));
	for( j = 0; j < total_count; j++ )
	{
		(*feet)[j] = loc_feet[j] ;
		_pdm_debug("foot = %d", (*feet)[j].objid );
	}

	free( loc_feet );
wrapup:

    return( 1 );
}

GetACrgAttribVal(rg_grid, attr_name, buff,alloc_size)
char *attr_name, **buff;
struct GRid *rg_grid ;
int *alloc_size ;
{
	int     sts ;
	long    msg ;
	char    val[15] ;

	struct	ACrg_coll	attrib;

	_pdm_debug ("Enter GetACrgAttribVal", 0);
	_pdm_debug ("Attribute %s ", attr_name);

	/* Get attributes from the ACrg_collect object */

	strcpy( attrib.name, attr_name );

	sts = om$send( msg = message ACrg_collect.ACget_named_attribute
					( &msg, &attrib ),
				senderid = rg_grid -> objid,
				targetid = rg_grid -> objid,
				targetos = rg_grid -> osnum );

        _MO_omerr_chk("GetACrgAttribVal () : ACrg_collect.ACget_named_attribute ", sts, wrapup);
        _MO_emerr_chk("GetACrgAttribVal () : ACrg_collect.ACget_named_attribute", msg, wrapup);

	if( attrib.desc.type & AC_ATTRIB_MASK_TYPE & AC_ATTRIB_DOUBLE ){

		sprintf(val,"%lf", attrib.desc.value.att_exp);
		
		if( (strlen(*buff) + strlen(val) + 3) > *alloc_size) {
			*alloc_size =  strlen(*buff) + strlen(val) + 128;
			*buff = (char *) realloc(*buff, *alloc_size );
			MemCheck( (*buff) );
		}

		strcat(*buff,val);
		strcat(*buff,"\1");
	}

	else {
		if( strlen(*buff) + strlen(attrib.desc.value.att_txt) + 3 > *alloc_size) {
			*alloc_size =  strlen(*buff) + strlen(attrib.desc.value.att_txt) + 128;
			*buff = (char *) realloc(*buff, *alloc_size );
			MemCheck((*buff));
		}

		strcat(*buff,attrib.desc.value.att_txt);	
		strcat(*buff,"\1");
	}
	_pdm_debug ("Value     : %s", *buff);

	return(1);

wrapup :
	return (0);
}

/* Parts at foot level of macros instanced in design file go
   into grand child buffer 
*/	

UpdateGrandChild(glist,pn_catname,pn_partname,pn_partrev)
struct GRid *glist ;
char *pn_catname, *pn_partname, *pn_partrev ;
{
	int num_feet, lc_level = 0 , i ,sts ;	
	struct GRid childid[2], *feetlist = NULL; 
	OMuword classid ;
	char *catname,*partname,*partrev;

	char *ptr, tempstr[256];

	/* Get feet desciption of macro. If feet classid happens to be 
	   ACdyn_col, store level and ID
	*/

	_pdm_debug("Entered Update Grandchild..objid %d",glist->objid);

        GetFeetObjects( glist, &num_feet, &feetlist );

        for( i = num_feet - 1; i >= 0; i-- )
        {
		sts = om$get_classid( objid = feetlist[i].objid, 
       				      osnum = feetlist[i].osnum,
       				      p_classid = &classid);
	
		if( om$is_ancestry_valid(superclassid = OPP_ACdyn_col_class_id,
			  	subclassid  = classid ) != OM_S_SUCCESS )
		{
		int found = 0;
/* 21/Dec/93 - raj. Init tempstr to null.	*/
		tempstr[0] = '\0';

			if( i == (num_feet - 1) ) /* last one NOT acdyncol */
				return(1);
/** Added this for including expression feet type attrs in the list - 09/06/93 */
/* Check if it is an expression-foot and if so, add it to the respective "expfeet" and
   increment numexpfeet*/
			else 
			if(om$is_ancestry_valid(superclassid = OPP_text_exp_class_id,
			      subclassid = classid) == OM_S_SUCCESS)
			{
				dynattr = (char **)realloc(dynattr,sizeof(char *)*(numdyn+1));
				dynattr[numdyn] = (char *)malloc(128);
			        di$untranslate( objname = tempstr, 
                        		        objid = feetlist[i].objid, 
                              			osnum = feetlist[i].osnum );
				_pdm_debug("expname = %s", tempstr );
				strcpy( dynattr[numdyn], tempstr );
				ptr = strrchr( tempstr, ':');
				if( ptr )
					strcpy( dynattr[numdyn], ptr );
				dyntype = (char **)realloc(dyntype,sizeof(char *) * (numdyn+1));
				dyntype[numdyn] = (char *)malloc(strlen("char(80)")+1);
				strcpy(dyntype[numdyn],"char(80)");
				dynvals = (char **)realloc(dynvals,sizeof(char *) * (numdyn+1));
				found = 1;
			}
			else
			if(om$is_ancestry_valid(superclassid = OPP_Gexp_class_id,
			      subclassid = classid) == OM_S_SUCCESS)
			{
				dynattr = (char **)realloc(dynattr,sizeof(char *)*(numdyn+1));
				dynattr[numdyn] = (char *)malloc(128);
			        di$untranslate( objname = tempstr, 
                        		        objid = feetlist[i].objid, 
                              			osnum = feetlist[i].osnum );
				_pdm_debug("expname = %s", tempstr );
				strcpy( dynattr[numdyn], tempstr );
				ptr = strrchr( tempstr, ':');
				if( ptr )
					strcpy( dynattr[numdyn], ptr );
				dyntype = (char **)realloc(dyntype,sizeof(char *) * (numdyn+1));
				dyntype[numdyn] = (char *)malloc(strlen("double")+1);
				strcpy(dyntype[numdyn],"double");
				dynvals = (char **)realloc(dynvals,sizeof(char *) * (numdyn+1));
				found = 1;
			}
			else
				break;/* first non-acdyncol & non-exp type foot encountered */
			if( found )
			{
			char formula[256];

				sts = om$send ( msg = message expression.give_formula(formula),
					targetid = feetlist[i].objid,
					senderid = feetlist[i].objid,
					targetos = feetlist[i].osnum);

		     		_MO_omerr_chk("NDgive_structure:updategrandchild:", sts,  wrapup);

				remove_quotes(formula); 

				if(strcmp(dyntype[numdyn],"char")) /* double type */
				{
	   				dynvals[numdyn] = (char *)malloc(80*sizeof(char));
			   		MemCheck (dynvals[numdyn] );
					sscanf(formula,"%s",dynvals[numdyn]);
				}
				else
				{
	   				dynvals[numdyn] = (char *)malloc(strlen(formula) + 1);
			   		MemCheck (dynvals[numdyn]);
					strcpy(dynvals[numdyn],formula);
				}

                                _pdm_debug("dyn attr val: %s",
                                           dynvals[numdyn] );
				numdyn++;
			}
		}
		else
		{
			if( i == (num_feet-1) )/* (childid[1] -> Dyn attr box)*/
				childid[0] = childid[1] = feetlist[i]; /* TR#6544 */
			else /* the childid[0] -> (stat attr box ) */
				childid[0] = feetlist[i];
		}
	}

	if( !add_data_togrand_child(childid,pn_catname,pn_partname,pn_partrev,
			&catname,&partname,&partrev ))
		return(0);

	for( i = 0 ; i < num_feet - 1 ; ++i ) {

		sts = om$get_classid(   objid     = feetlist[i].objid, 
	       			osnum     = feetlist[i].osnum,
	       			p_classid = &classid);

		if( om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
				  subclassid  = classid ) == OM_S_SUCCESS ){

			UpdateGrandChild(&feetlist[i],catname, partname,partrev);
		}
	}
	lc_level = 1 ;
wrapup:
	MyFree( catname );
	MyFree(partname);
	MyFree(partrev );

	return(lc_level);
}

GetFeetDesc(grid,nofeet,feetdesc)
struct GRid *grid ;
int *nofeet ;
struct myfeet **feetdesc;
{
	int sts ;
	struct GRid hdr ;

	sts = om$send(  msg = message ACcpx.find_macro( &hdr),
                 	senderid = grid -> objid,
                 	targetid = grid -> objid,
                 	targetos = grid -> osnum);

	_MO_omerr_chk("find_macro : macro", sts, wrapup);


	sts = om$send( msg = message ACcpx_defn.ACgive_feet_desc(nofeet,
                                                             feetdesc),
                      senderid = hdr.objid,
                      targetid = hdr.objid,
                      targetos = hdr.osnum );

	_MO_omerr_chk("ACgive_feet_desc : macro", sts, wrapup);

	return(1);
wrapup:
	return(0);
}

add_data_togrand_child(acdyn_col,pn_catname,pn_partname,pn_partrev,
		catname,partname,partrev )
struct GRid *acdyn_col ;
char *pn_catname,*pn_partname,*pn_partrev ;
char **catname, **partname, **partrev ;
{

	int alsize = 1024 , tbl_no = 0 ;
        int i, status;
	char *str = NULL;

	char **attrs = NULL, **types = NULL, **vals = NULL;
	int num;
	MEMptr lclbuf = NULL;
        char *str1 = NULL;
        char tmpstr[10];
        extern int PDU_dyn_index;


	/* Part at main directory level goes into PDU_child_buffer */
	str = (char *) malloc(alsize);
	str[0] = '\0' ;

	_pdm_debug("Entered add_data_togrand_child",0);

	(*catname)  = (char *)malloc(20);
	(*catname)[0] = '\0' ;

	(*partname) = (char *)malloc(80);
	(*partname)[0] = '\0' ;

	(*partrev)  = (char *)malloc(80);
	(*partrev)[0] = '\0' ;

	
	if(! GetACrgAttribVal(&acdyn_col[0],"n_catalogname",catname,&alsize))
		goto wrapup;

	(*catname)[strlen(*catname)-1] = '\0' ;
	if( !GetACrgAttribVal(&acdyn_col[0],"n_itemname",partname,&alsize))
		goto wrapup;


	(*partname)[strlen(*partname)-1] = '\0' ;

	if( !GetACrgAttribVal(&acdyn_col[0],"n_itemrev",partrev,&alsize))
		goto wrapup;

	(*partrev)[strlen(*partrev)-1] = '\0' ;
		
	strcat(str,"\1\1");          /* structure no and p_level */
	strcat(str,pn_catname);
	strcat(str,"\1");
	strcat(str,pn_partname);
	strcat(str,"\1");
	strcat(str,pn_partrev);
	strcat(str,"\1\1\1"); /* n_pcatalogno, n_pitemno */

	strcat(str,*catname);
	strcat(str,"\1");
	strcat(str,*partname);
	strcat(str,"\1");
	strcat(str,*partrev);
	strcat(str,"\1\1\1"); /* n_ccatalogno, n_citemno */
	
	tbl_no = 0 ;

	_pdm_debug(" str is ... %s", str );
	  
	if( !GetACrgAttribVal(&acdyn_col[1],"p_quantity",&str,&alsize))
		goto wrapup;

	strcat(str,"\1"); /* p_history */

	if( GetACrgAttribVal(&acdyn_col[1],"serial_no",&str,&alsize) )
	 if( GetACrgAttribVal(&acdyn_col[1],"p_tagno",&str,&alsize))
	  if( GetACrgAttribVal(&acdyn_col[1],"p_usageid",&str,&alsize))
	   if( GetACrgAttribVal(&acdyn_col[1],"p_alttagno",&str,&alsize))
	    if( GetACrgAttribVal(&acdyn_col[1],"p_incbom",&str,&alsize))
		tbl_no = 1 ;

	if( !tbl_no )
		goto wrapup;

	strcat(str,"\1");    /* p_explode not to be set for param parts?? */
	strcat(str,"\1");    /* p_attached not to be set for param parts?? */
	strcat(str,"\1");    /* p_cofilename    - not to be set for param parts */

	tbl_no = 1;

	/* Write the data to part_list buffer of global structure */
	if( !PDU_param_buffer)
	{
		_pdm_debug("PDU_param_buffer not open",0);
		goto wrapup;
	}

/*** Added this for TR#139307199 **************************************************
   Get the list of attributes and their values from the dynamic collection and 
   format a MEM buffer with these attributes, excluding the standard dynamic
   attributes such as p_quantity, p_usageid, p_tagno, p_alttagno, p_incstr,
   p_incbom, serial_no etc., then insert a row of values.

   Add these attributes to the list that has expression-feet.

   MEMappend this local buffer to the global PDUchild_dyn_attr_bufr.
***********************************************************************************/

	ReadAtrsFromCols(&acdyn_col[1], &attrs, &types, &vals, &num );

	for( i = 0; i < num; i++ )
	{
		if( !strcmp( attrs[i],"p_quantity") ||
		    !strcmp( attrs[i],"p_usageid")  ||
		    !strcmp( attrs[i],"p_tagno")    ||
		    !strcmp( attrs[i],"p_alttagno") ||
		    !strcmp( attrs[i],"p_explode")  ||
		    !strcmp( attrs[i],"p_attach")   ||
		    !strcmp( attrs[i],"p_incstr")   ||
		    !strcmp( attrs[i],"n_catalogname")   ||
		    !strcmp( attrs[i],"p_incbom"))
			continue;

		dynattr = (char **)realloc(dynattr,sizeof(char *)*(numdyn+1));
		dynattr[numdyn] = (char *)malloc(strlen(attrs[i])+1);

                /* Want to include serial_no in the buffer - Jamal 6-21-93. */
                if (strcmp(attrs[i], "serial_no") == 0)
                   strcpy(dynattr[numdyn], "p_childno");

                else
		   strcpy(dynattr[numdyn], attrs[i]);

                /* Adjust size of attribute according to attribute value. Jamal
                   6-21-93. */ 
		dyntype = (char **)realloc(dyntype,sizeof(char *) * (numdyn+1));
		if( !strcmp( types[i], "Expression text") )
		{
			dyntype[numdyn] = (char *)malloc(strlen("char(20)")+5);
                        sprintf(dyntype[numdyn], "char(%d)", strlen(vals[i])+1);
		}
		else
		{
			dyntype[numdyn] = (char *)malloc(strlen("double")+1);
			strcpy(dyntype[numdyn],"double");
		}

		dynvals = (char **)realloc(dynvals,sizeof(char *)*(numdyn+1));
		dynvals[numdyn] = (char *)malloc(strlen(vals[i])+1);
		strcpy(dynvals[numdyn], vals[i]);

		numdyn++;
	}

	/* Free the complete list of dynattribs */
	for( i = 0; i < num; i++ )
	{
		MyFree( attrs[i]);
		MyFree( types[i]);
		MyFree( vals[i]);
	}
	MyFree( attrs );
	MyFree( types );
	MyFree( vals );
	
	_pdm_debug("numdyn=%d",numdyn);

	if( numdyn == 0 ) /* No dynamic attributes to be filled in the buffer */
	{
		tbl_no = 1;

                strcat(str, "-1"); /* p_dyndataindex */
                strcat(str, "\1");
 
                _pdm_debug("Final str ... %s", str);

                status =  MEMwrite(PDU_param_buffer, str);
                _pdm_status("MEMwrite", status);

                 if (status != MEM_S_SUCCESS)
                 {
                        _pdm_debug("Error writing to PDU_param_buffer\n",0);
                        MEMclose(&PDU_param_buffer);
                        tbl_no = 0 ;
                        goto wrapup;
                 }


		goto wrapup;
	}

        str1 = (char *) malloc(alsize);
        str1[0] = '\0' ;
        strcpy(str1, str);

	for( i = 0; i < numdyn; i++ )
	{
		_pdm_debug("dynattr=%s",dynattr[i]);
		_pdm_debug("dyntype=%s",dyntype[i]);
		_pdm_debug("dynvals=%s",dynvals[i]);
	}

        /* Now, using the attributes and types, format the local MEMbuffer */
	if( FormatAttrBuffer( &lclbuf, dynattr, dyntype, numdyn ) != MEM_S_SUCCESS )
	{
		tbl_no = 0;
		goto wrapup;
	}

	/* Write the row of attr values into the local buffer */
	str[0] = '\0';
	for( i = 0; i < numdyn; i++ )
	{
		if( i > 0 )
			strcat( str, "\1" );
		if( ( strlen( str ) + strlen( dynvals[i] ) + 1 ) > alsize )
		{
			str = (char *)realloc(str, (alsize+128));
			alsize += 128;
		}
		strcat( str, dynvals[i] );
		_pdm_debug("str: %s ",str);
	}

	strcat( str, "\1");
        strcat(str,*catname);
        strcat( str, "\1");

	status =  MEMwrite(lclbuf,str);
        _pdm_status("MEMwrite", status);

         if (status != MEM_S_SUCCESS)
         {
		_pdm_debug("Error writing to lclbuf",0);
		MEMclose(&lclbuf);
		tbl_no = 0 ;
		goto wrapup;
	}

	if( PDMdebug_on )
		MEMprint_buffer( "lclbuf: ", lclbuf, PDU_DEBUG_FILE );

	/* Append the local buffer to the global PDUchild_dyn_buffer */
	if( (status = MEMappend( lclbuf, PDUchild_dyn_buffer )) != MEM_S_SUCCESS ) 
	{
		_pdm_debug("Error appending lclbuf",0);
		MEMclose(&lclbuf);
		tbl_no = 0 ;
		goto wrapup;
	}

        if( PDMdebug_on )
		MEMprint_buffers( "PDUchild_dyn_buffer: ", PDUchild_dyn_buffer,
                                  PDU_DEBUG_FILE );

        /* Associate p_dyndataindex with lclbuf in PDU_param_buffer */
        sprintf(tmpstr, "%d\1", PDU_dyn_index);
        strcat(str1, tmpstr);
        _pdm_debug("Final str1 ... %s", str1);

        status =  MEMwrite(PDU_param_buffer, str1);
        _pdm_status("MEMwrite", status);

        if (status != MEM_S_SUCCESS)
           {
            _pdm_debug("Error writing to PDU_param_buffer\n",0);
            MEMclose(&PDU_param_buffer);
            tbl_no = 0 ;
            goto wrapup;
           }

        if( PDMdebug_on )
          MEMprint_buffer( "PDU_param_buffer: ", PDU_param_buffer,
                           PDU_DEBUG_FILE );

        /* Increment PDU_dyn_index */
        ++PDU_dyn_index;
       
 
wrapup:
        if (str)
	   free(str);

        if (str1)
           free(str1);

/* added */
	for( i = 0; i < numdyn; i ++ )
	{
		MyFree(dynattr[i]);
		MyFree(dyntype[i]);
		MyFree(dynvals[i]);
	}
	MyFree( dynattr );
	MyFree( dyntype );
	MyFree( dynvals );

	return(tbl_no);
}	

get_nblines_in_dir(nb_lines,lines,dir_grid,osnum)
int *nb_lines ;
char ***lines ;
struct GRid *dir_grid ;
int osnum ;
{
	int sts ;
	char   dir_name[MAXPATHLEN] ;
	
	DIstmocpy(dir_name,"PDU","macro_parts",0,osnum);  

	sts = di$translate(p_objid   = &dir_grid -> objid,
			     osnum   = dir_grid -> osnum,
			   objname   = dir_name);

	_pdm_debug("directory containing macro is: %s", dir_name );

  
	/*   Get and print the contents of this directory */

	strcat(dir_name,":*");

	sts = di$ls(	  regexp = dir_name ,
        	          lines  = lines ,
                	  ptr    = nb_lines);

/*	if(!(sts&1))di$report_error(sts = sts); */

	if(*nb_lines == 0)
        	return(0) ;

	return(1);

}

FormatAttrBuffer (attr, colname, colfrmt, numcols )
 MEMptr *attr;
 char   **colname;
 char   **colfrmt;
 int    numcols;

/* this function formats a buffer for a set of attributes. */
{
    long	status;
    char 	s[1024];
    int		i;
    short       catfound = FALSE;

	_pdm_debug ("Entered FormatAttrBuffer ()", 0);

	status = MEMopen( attr, 512);
    	if( status != MEM_S_SUCCESS) 
	{
        	MEMclose( attr );
        	sprintf (s, "%s %d", "MEMopen failed status : ", status);
	        _pdm_debug ("%s", s);
        	return( status );
    	}

/*      MEMprint_buffer ("Empty attr buffer", *attr, NULL);*/

	for ( i = 0 ; i < numcols ; i++ )
	{
            if (strcmp(colname[i], "n_catalogname") == 0)
                continue;
  
	    status = MEMwrite_format( *attr, colname[i], colfrmt[i] );
            /* WriteError(status, attr); */
    	    if( status != MEM_S_SUCCESS) 
  	      {
      		MEMclose( attr );
       		sprintf (s, "%s %d %d",
                        "MEMwrite_format failed status,i= ", status, i);
	        _pdm_debug ("%s", s);

       		return(status);
	      }
	}

        /* Need to add n_catalogname. */
        status = MEMwrite_format( *attr, "n_catalogname", "char(20)");
        if( status != MEM_S_SUCCESS)
          {
           MEMclose( attr );
           _pdm_debug("MEMwrite_format failed on n_catalogname", 0);

           return(status);
          }

/*      MEMprint_buffer ("Formatted attr buffer", *attr, NULL);*/
	
	_pdm_debug ("Exiting FormatAttrBuffer ()", 0);

    return (MEM_S_SUCCESS);    	
}


end implementation Root;


