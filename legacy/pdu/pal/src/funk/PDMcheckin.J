/***************************************************************************/
/*                                                                         */
/*   This file contains routines to fill in 'part_list' buffer of global   */
/*   structure PDUrefresh. Scans the directory :macro_parts                */
/*                                                                         */
/*           File Creation Date:     02-July-92   MMS (IGI)                */
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

from ACmacro_defn import ACgive_upscan;
from ACrg_collect import ACget_named_attribute;
from NDnode import NDget_objects;
from ACncpx import ACreturn_foot ;
from ACcpx import find_macro ;
from ACcpx_defn import ACgive_feet_desc ;

extern int   PDMdebug_on ;
extern struct PDUrefresh *refresh ;
struct GRmd_env lmod_env ;
extern OMuword OPP_ACcpx_class_id ;
extern OMuword OPP_ACdyn_col_class_id ;
#define	AC_ATTRIB_MASK_TYPE	0x00ff

extern MEMptr PDU_child_buffer, PDU_param_buffer;

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

				if(update_part_list_bufr(&part_grid,NULL)==-1){
					sts = 0;
					break;
				}
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

	int 	alsize = 512 , tbl_no = -1,  sts;
	int	status, num_org, num_loc, num_coll, coll_ndx;
	char 	*str = NULL,  *catname, *partname,*partrev  ;
	long 	msg;


	struct 	GRid 		hdr, acdyn_col, cat_attr_coll, dyn_attr_coll;
	struct	ACrg_coll	attrib;
	struct	ACrg_coll	*list;
	struct  stemp		*temp_desc;

	/* Part at main directory level goes into PDU_child_buffer */
	str = (char *) malloc(alsize);
	str[0] = '\0' ;

	sts = om$send(  msg = message ACcpx.find_macro( &hdr),
                 	senderid = part_grid -> objid,
                 	targetid = part_grid -> objid,
                 	targetos = part_grid -> osnum);

	_MO_omerr_chk("updateprtlistbufr: find_macro : macro", sts, wrapup);

	GetOriginalMacroInfo (&hdr, &temp_desc, &num_org, &num_loc, &num_coll);

	if( !num_coll) 	/* No collections.			*/
			/* NOT a PDM parametric part. Don't add.*/
	{
		_pdm_debug("No collections to the part",0);
		return( 0 );
	}

	/* Get the FIRST acdyn collection, which holds the catalog attrs */
	if (!get_acdyncol_temp(part_grid, &cat_attr_coll, num_loc))
		return (0);
	
	/* Get the LAST acdyn collection, which holds the statndard dyn attrs */
	if (!get_acdyncol_temp(part_grid, &dyn_attr_coll, num_loc + num_coll - 1))
		return (0);

	_pdm_debug("Dyncollection objid %d", dyn_attr_coll.objid);
	_pdm_debug("Dyncollection osnum %d", dyn_attr_coll.osnum);

	if( attr_name != NULL ) {
		
		strcpy( attrib.name, attr_name );

		if (GetDyncolIndx( temp_desc, attr_name, num_org, num_loc, &coll_ndx) == -1)
		{
		    /* Not a template to the macro, might be in the */
		    /* FIRST or the LAST collection.		    */

		    sts = om$send(
			  msg = message ACrg_collect.ACget_named_attribute
					( &msg, &attrib ),
			  senderid = cat_attr_coll.objid,
			  targetid = cat_attr_coll.objid,
			  targetos = cat_attr_coll.osnum );


		    if(!(msg & 1))
		    {
		    _pdm_debug("%s Not in first collection ...trying last",attrib.name);

			/* If attribute is NOT found in the coll */
		        sts = om$send(
			      msg = message ACrg_collect.ACget_named_attribute
					( &msg, &attrib ),
			      senderid = dyn_attr_coll.objid,
			      targetid = dyn_attr_coll.objid,
			      targetos = dyn_attr_coll.osnum );

			/* Not in this collection, too. Return FAILURE*/
		        if (!(msg & 1))
			{
				_pdm_debug("First collection list is ....",0);
				GetACrgAttribList(&cat_attr_coll,&list,&num_org);
				for(sts = 0; sts < num_org; sts++ )
					_pdm_debug("%s",list[sts].name);
				_pdm_debug("Last collection list is ....",0);
				GetACrgAttribList(&dyn_attr_coll,&list,&num_org);
				for(sts = 0; sts < num_org; sts++ )
					_pdm_debug("%s",list[sts].name);
				return (0);
			}
		    }
		}

		else
		{
		    /* It IS a template to the macro.		*/
		    /* get the acdyn coll it's mapped onto.	*/
		    if (!get_acdyncol_temp(part_grid, &acdyn_col, num_loc + coll_ndx))
			return (0);

		    sts = om$send( msg = message ACrg_collect.ACget_named_attribute
					( &msg, &attrib ),
				senderid = acdyn_col.objid,
				targetid = acdyn_col.objid,
				targetos = acdyn_col.osnum );

		    if(!( msg & 1))
			/* Attribute is NOT found in the coll. Return FAILURE */
			return(0);

		}
		_pdm_debug(" attribute type = %d", attrib.desc.type);

		if( attrib.desc.type & AC_ATTRIB_MASK_TYPE & AC_ATTRIB_TEXT )
			strcpy(attr_name,attrib.desc.value.att_txt);	
		else
			if( attrib.desc.type & AC_ATTRIB_MASK_TYPE & AC_ATTRIB_DOUBLE )
				sprintf(attr_name,"%lf", attrib.desc.value.att_exp);
			else

				return(0);

		return(1);
	}

	
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
	if( !GetACrgAttribVal(&cat_attr_coll,"serial_no",&str,&alsize) )
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
	if( GetACrgAttribVal(&cat_attr_coll,"p_incbom",&str,&alsize))
			tbl_no = 1 ;
	if( GetACrgAttribVal(&cat_attr_coll,"p_incstr",&str,&alsize))
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

	Process_feet_of_assbly(part_grid,catname,partname,partrev); 


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
	IGRlong msg ;
	struct GRid glist;
	short mat_type ;
	IGRmatrix matrix ;
	int num_feet ;
	struct myfeet *feet_desc ;
	OMuword  classid ;

	/* Parts at foot level of macros instanced in design file go
	   into grand child buffer 
	*/	

	if( ! GetFeetDesc(part_grid,&num_feet,&feet_desc))
		return(0);

	for( i = 0 ; i < num_feet ; ++i ) {

	        sts = om$send( msg = message ACncpx.ACreturn_foot(&msg,
                                      feet_desc[i].name,
                                      &glist,
                                      &mat_type,matrix),
			senderid = part_grid -> objid,
			targetid = part_grid -> objid,
			targetos = part_grid -> osnum);

		_MO_emerr_chk("ACreturn_foot : symb", msg, wrapup);
		_MO_omerr_chk("ACreturn_foot : symb", sts, wrapup);
		
		sts = om$get_classid(   objid     = glist.objid, 
	       			osnum     = glist.osnum,
	       			p_classid = &classid);

		if( om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
				  subclassid  = classid ) == OM_S_SUCCESS ){

                        _pdm_debug("call updategrandchild", 0);
			UpdateGrandChild(&glist,catname,partname,partrev);

		}
	}

/*
	free( (char *) feet_desc );
*/
	return(1);
wrapup:
/*
	free( (char *) feet_desc );
*/
	return(0);
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
/*
			if (*buff == NULL ) {
				fprintf (stderr, "Unable To Allocate Memmory\n");
				return (0);
			}
*/
		}

		strcat(*buff,val);
		strcat(*buff,"\1");
	}

	else {
		if( strlen(*buff) + strlen(attrib.desc.value.att_txt) + 3 > *alloc_size) {
			*alloc_size =  strlen(*buff) + strlen(attrib.desc.value.att_txt) + 128;
			*buff = (char *) realloc(*buff, *alloc_size );
			MemCheck((*buff));
/*
			if (*buff == NULL ) {
				fprintf (stderr, "Unable To Allocate Memmory\n");
				return (0);
			}
*/
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
	IGRlong msg ;
	IGRshort mat_type ;
	IGRmatrix matrix  ;
	struct GRid childid[2], tempid; 
	struct myfeet *feet_desc  ;
	OMuword classid ;
	char *catname,*partname,*partrev;

	/* Get feet desciption of macro. If feet classid happens to be 
	   ACdyn_col, store level and ID
	*/

	_pdm_debug("Entered Update Grandchild..objid %d",glist->objid);

	if(!GetFeetDesc(glist,&num_feet,&feet_desc))
		return(0);

	_pdm_debug("After getfeetdesc ..",0);

	for( i = num_feet - 1; i >= 0; i-- )
	{
		/* See if the last foot is ACdyn_col type  */
        	sts = om$send( msg = message ACncpx.ACreturn_foot(&msg,
                                   feet_desc[i].name,
                                   &tempid,
                                   &mat_type,matrix),
			senderid = glist -> objid ,
			targetid = glist -> objid ,
			targetos = glist -> osnum);

		_MO_emerr_chk("ACreturn_foot : symb", msg, wrapup);
		_MO_omerr_chk("ACreturn_foot : symb", sts, wrapup);

		sts = om$get_classid(   objid     = tempid.objid, 
       				osnum     = tempid.osnum,
       				p_classid = &classid);
	
		if( om$is_ancestry_valid(superclassid = OPP_ACdyn_col_class_id,
			  	subclassid  = classid ) != OM_S_SUCCESS )
		{
			if( i == (num_feet - 1) ) /* last one NOT acdyncol */
				return(1);
			else
				break;/* first non-acdyncol foot encountered */
		}
		else
		{
			if( i == (num_feet-1) )/* (childid[1] -> Dyn attr box)*/
				childid[1] = tempid;
			else /* the childid[0] -> (stat attr box ) */
				childid[0] = tempid;
		}
	}

	add_data_togrand_child(childid,pn_catname,pn_partname,pn_partrev,
			&catname,&partname,&partrev );

	for( i = 0 ; i < num_feet - 1 ; ++i ) {

	        sts = om$send( msg = message ACncpx.ACreturn_foot(&msg,
                                      feet_desc[i].name,
                                      &tempid,
                                      &mat_type,matrix),
			senderid = glist -> objid ,
			targetid = glist -> objid ,
			targetos = glist -> osnum);

		_MO_emerr_chk("ACreturn_foot : symb", msg, wrapup);
		_MO_omerr_chk("ACreturn_foot : symb", sts, wrapup);
		
		sts = om$get_classid(   objid     = tempid.objid, 
	       			osnum     = tempid.osnum,
	       			p_classid = &classid);

		if( om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
				  subclassid  = classid ) == OM_S_SUCCESS ){

			UpdateGrandChild(&tempid,catname, partname,partrev);
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
        int status;
	char *str = NULL;

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

	if( GetACrgAttribVal(&acdyn_col[0],"serial_no",&str,&alsize) )
	 if( GetACrgAttribVal(&acdyn_col[1],"p_tagno",&str,&alsize))
	  if( GetACrgAttribVal(&acdyn_col[1],"p_usageid",&str,&alsize))
	   if( GetACrgAttribVal(&acdyn_col[1],"p_alttagno",&str,&alsize))
	    if( GetACrgAttribVal(&acdyn_col[0],"p_incbom",&str,&alsize))
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

	_pdm_debug("Final str ... %s",str);

	status =  MEMwrite(PDU_param_buffer,str);
        _pdm_status("MEMwrite", status);

         if (status != MEM_S_SUCCESS)
         {
		_pdm_debug("Error writing to PDU_param_buffer\n",0);
		MEMclose(&PDU_param_buffer);
		tbl_no = 0 ;
		goto wrapup;
	}

wrapup:
	free(str);
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

	_pdm_debug("directory containing macro is: ", dir_name );

  
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
end implementation Root;


