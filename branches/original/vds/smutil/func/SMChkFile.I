/* $Id: SMChkFile.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smutil/func / SMChkFile.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMChkFile.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  17:54:32  pinnacle
# Fixed warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/17  14:53:36  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/30/97	ah		get rid of warninga
 * -------------------------------------------------------------------*/

class implementation Root;


/**
/* Functions to check the assoc connections through reference files 
/*
/*	- InitGoInfo
/*	- InitTagCon
/*	- FreeTagCon
/*	- InitConnInfo
/*	- PrtCon
/*	- GetConnections
/*	- sort_connections
/*	- GetGoInfo
/*	- isParentHere
/*	- findRefFileName
/*	- GetTagCon
/*	- TryReconnect
/*	- ReConnect
/*	
/**/


#include <stdio.h>

#include "OMerrordef.h" 
#include "OMindex.h"
#include "OMminimum.h"
#include "OMmacros.h"



#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "gr.h"
#include "igrdp.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "refdef.h"
#include "ref.h"
#include "msdef.h"
#include "gomacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "AS_status.h"
#include "SMcon.h"
#include "vdsmacros.h"
#include "VDmem.h"


from	NDnode		import	NDget_objects, ASreturn_go;
from	OMObjSpace	import	pass;
from	GRgraphics	import	GRfunction, GRdisplay;
from	GRreffile	import	GRgetosnum, GRinquireref;
from	GRnotify	import	GRntfyconn;


extern OM_S_CHANSELECT AS_listeners;

extern	GRclassid OPP_ASsource_class_id, OPP_ACpretend_class_id, 
		  OPP_ASsourcein_class_id, OPP_ACpretendin_class_id,
		  OPP_OMTagCon_class_id, OPP_GRcontext_class_id;




/* ---------------------------------------------------------------------- */
/*	Init the structure GoInfo
/**/

IGRint InitGoInfo(go)
struct GoInfo	*go; 	/* (I) struture to init */
{

	go->obj.objid = NULL_OBJID;
	go->obj_name[0] = '\0';
	go->class_name[0] = '\0';
	go->class_id = 0;
	go->tag = 0;

return 1;
}
/* ---------------------------------------------------------------------- */
/*	Init the structure TagConInfo
/**/

IGRint InitTagCon(tag)
struct TagConInfo	*tag; 	/* (I) struture to init */
{

	tag->obj.objid = NULL_OBJID;
	tag->intname[0] = '\0';
	tag->count = 0;
	tag->oidlist = NULL;
	tag->taglist = NULL;

return 1;
}
/* ---------------------------------------------------------------------- */
/*	Free the structure TagConInfo
/**/

IGRint FreeTagCon(tag)
struct TagConInfo	*tag; 	/* (I) struture to init */
{

	if(tag->oidlist){ free(tag->oidlist); tag->oidlist = NULL;}
	if(tag->taglist){ free(tag->taglist);  tag->taglist= NULL;}

return 1;
}

/* ---------------------------------------------------------------------- */
/*	Init the structure ConnInfo
/**/

IGRint InitConnInfo(con)
struct ConnInfo	*con;	/* (I) struture to init */
{

	con->source_id.objid = NULL_OBJID;
	con->class_name[0] = '\0';
	con->ref_name[0] = '\0';
	con->ref_id.objid = NULL_OBJID;
	con->ref_osnum = 0;
	con->context_id.objid = NULL_OBJID;
	InitGoInfo(&con->go_info);
	con->nb_child = 0;
	con->child = NULL;

return 1;
}

/* ---------------------------------------------------------------------- */
/*	Print the assoc connections in the report file (if report_file
/*      is NULL make a printf)
/**/

#argsused

IGRint	PrtCon(report_file, nb_con, con, nb_brk, brk)
IGRchar		*report_file;	/* (I) name of the report file */
IGRint		nb_con;		/* (I) nb of connections */
struct ConnInfo *con;		/* (I) connection info */
IGRint		nb_brk;		/* (I) nb of broken connections */
IGRint		*brk;		/* (I) index of the broken connection */
{
int	i,k, index;
FILE	*pf;
IGRchar filename[DI_PATH_MAX];

// if (nb_con); // Get rid of wwarning

pf = NULL;
if(report_file && report_file[0] != '\0')
		pf = (FILE *) fopen(report_file,"w");
else pf = stdout;

if(pf == NULL){
	printf("cannot open report file\n");
	return 0;
}
 
ex$filename( 	name = filename,
		len  =  DI_PATH_MAX) ;

 
fprintf(pf,"\n\nList of broken connections through reference file in : %s\n\n", filename ) ;

for(i=0;i<nb_brk;i++){
	index = brk[i];
	fprintf(pf,"\n\n----------------- Connection %s :[%d,%d] ------------------------\n\n",con[i].class_name, con[index].source_id.objid, con[index].source_id.osnum);
	fprintf(pf,"reference file:          %s (osnum %d)\n",con[index].ref_name, con[index].ref_osnum);
	fprintf(pf,"context:                 [%d,%d] \n",con[index].context_id.objid,con[index].context_id.osnum);

	fprintf(pf,"graphic object:          MISSING (broken connection) \n");
	fprintf(pf,"\tlost connection in the reference file: %s\n",con[index].ref_name);
	fprintf(pf,"\nchildrens:\n");

	for(k=0;k<con[index].nb_child;k++){
		fprintf(pf,"\t [%d,%d]	name: %s	(class %s (%d))\n",
			con[index].child[k].obj.objid,con[index].child[k].obj.osnum,
			con[index].child[k].obj_name,con[index].child[k].class_name,
			con[index].child[k].class_id);
	}
}

fprintf(pf,"\n\nThere are %d broken connections\n",nb_brk);

fprintf(pf,"--------------------------------------------------------------------------\n\n\n\n\n");
fprintf(pf,"End of the rapport ...\n");

fflush(pf);
fclose(pf);

return 1;
}


/* ---------------------------------------------------------------------- */
/*
/*	Get the assoc connections and the info about it
/****/

IGRint  GetConnections(nb_connections, connections, nb_broken, broken_index)
IGRint		*nb_connections;	/* (O) nb of connections */
struct ConnInfo **connections;		/* (O) connection info */
IGRint		*nb_broken;		/* (O) nb of broken connections */
IGRint		**broken_index;		/* (O) index of the broken connection */

{
 int 		i, id_con, id_brk, id_max, status;
 IGRchar	filename[DI_PATH_MAX];
 GRclassid	my_class;
 struct GRid	*child, mod_id, OBJ;
 IGRmatrix	matrix;
 IGRshort	mat_type;


 if(! nb_connections)	{
	printf("ERROR ,Invalid argument\n");
	goto wrapup;
 }
 else 			*nb_connections = 0;
 if(connections)	*connections = NULL;
 if(nb_broken)		*nb_broken = 0;
 if(broken_index)	*broken_index = NULL;

 ex$filename( 	name = filename,
		len  =  DI_PATH_MAX) ;
 ex$get_cur_mod( id = &mod_id.objid, osnum = &mod_id.osnum );
	
 id_max	= OM_GA_OSDs[mod_id.osnum]->CurSpaceMapSize;
 OBJ.osnum = mod_id.osnum;


 
 for ( OBJ.objid = 0; OBJ.objid < id_max; OBJ.objid += 1 ) {

	if ( om$is_objid_valid( osnum	= OBJ.osnum,
				objid	= OBJ.objid ) 
				!= OM_S_SUCCESS )  continue;

 
	om$get_classid(	osnum		= OBJ.osnum,
			objid		= OBJ.objid,
			p_classid 	= &my_class);


	if( om$is_ancestry_valid(
			subclassid     = my_class,
			superclassid =  OPP_ACpretendin_class_id) == OM_S_SUCCESS 
        ||  om$is_ancestry_valid(
			subclassid     = my_class,
			superclassid =  OPP_ASsourcein_class_id) == OM_S_SUCCESS)
		(*nb_connections) ++;
 }
 if((*nb_connections) ){
	(*connections) = 
		_MALLOC( *nb_connections,struct ConnInfo );
	if( (*connections) == NULL){
		printf("ERROR, bad allocation of connection\n");
		 goto wrapup; 
	}
	for(i=0;i< (*nb_connections);i++)
		InitConnInfo( &(*connections)[i] );

	if(broken_index){
		(*broken_index) = 
		     _MALLOC( (*nb_connections),IGRint );
		if( (*broken_index) == NULL){
			printf("ERROR, bad allocation broken_index\n");
			 goto wrapup; 
		}
	}
	id_brk = 0;
	id_con = 0;
 	for ( OBJ.objid = 0; OBJ.objid < id_max; OBJ.objid += 1 ) {

		if ( om$is_objid_valid( osnum	= OBJ.osnum,
					objid	= OBJ.objid ) 
						!= OM_S_SUCCESS )  continue;

 
		om$get_classid(	osnum		= OBJ.osnum,
				objid		= OBJ.objid,
				p_classid 	= &my_class);


		if( om$is_ancestry_valid(
			subclassid     = my_class,
			superclassid =  OPP_ACpretendin_class_id) == OM_S_SUCCESS ){
			
			(*connections)[id_con].source_id = OBJ;
			strcpy((*connections)[id_con].class_name, "ACpretendin");
		}
			
        	else if( om$is_ancestry_valid(
			subclassid     = my_class,
			superclassid =  OPP_ASsourcein_class_id) == OM_S_SUCCESS){

			(*connections)[id_con].source_id = OBJ;
			strcpy((*connections)[id_con].class_name, "ASsourcein");
		}
		else continue;
		isParentHere( OBJ.objid, OBJ.osnum, 
				(*connections)[id_con].ref_name ,
				&(*connections)[id_con].context_id,
				&(*connections)[id_con].ref_id,
				&(*connections)[id_con].ref_osnum);
		status = om$send( msg = message NDnode.ASreturn_go(
                                          &(*connections)[id_con].go_info.obj, 
					  &mat_type, matrix ),
			senderid = NULL_OBJID,
                        targetid = OBJ.objid,
                        targetos = OBJ.osnum );


		if(!(status & 1) ){
			/* broken connection */
			if(broken_index) (*broken_index)[id_brk] = id_con; 
			id_brk ++;
		}
		else{
			GetGoInfo(&(*connections)[id_con].go_info.obj, 
				(*connections)[id_con].go_info.obj_name, 
				&(*connections)[id_con].go_info.tag, 
				&(*connections)[id_con].go_info.class_id,
				(*connections)[id_con].go_info.class_name);

		}
		status = om$send( msg = message NDnode.NDget_objects(
                               		ND_CHILDREN|ND_IN_BUF,NULL,0,&child,
					0, OM_K_MAXINT, 
					&(*connections)[id_con].nb_child),
				senderid = NULL_OBJID,
                        	targetid = OBJ.objid,
                        	targetos = OBJ.osnum );
		as$status();
		if((*connections)[id_con].nb_child){
			(*connections)[id_con].child = 
		 	  _MALLOC ((*connections)[id_con].nb_child,struct GoInfo);
			if( (*connections)[id_con].child == NULL){
				printf("ERROR, bad allocation child\n");
				/* goto wrapup; */
			}
		}

		for(i=0;i<(*connections)[id_con].nb_child;i++){
			(*connections)[id_con].child[i].obj = child[i];

			vd$get_name( name =(*connections)[id_con].child[i].obj_name,
				     obj = &( (*connections)[id_con].child[i].obj) );
			status = om$get_classid(	
						osnum = (*connections)[id_con].child[i].obj.osnum,
						objid = (*connections)[id_con].child[i].obj.objid,
						p_classid = &(*connections)[id_con].child[i].class_id);
			as$status();
			om$get_classname(	
						osnum = (*connections)[id_con].child[i].obj.osnum,
						objid = (*connections)[id_con].child[i].obj.objid,
						classname = (*connections)[id_con].child[i].class_name);
			as$status();
		}
		id_con ++;
	}
	if(nb_broken) *nb_broken = id_brk;	
 }


return 1;
wrapup:
	return 0;

}


/* ---------------------------------------------------------------------- */
/*
/*	Get Info on a graphic object
/*	
/****/

IGRint	GetGoInfo(go, obj_name, Tag, Class_id, Class_name)
struct GRid	*go;		/* (I) graphic obj we want the info */
IGRchar		*obj_name;	/* (O) name of the graphic obj */
OMuint		*Tag;		/* (O) tag of the graphic obj */
OMuword		*Class_id;	/* (O) class id of the graphic obj */
IGRchar		*Class_name;	/* (O) class name of the graphic obj */
{
int		status;

 status = OM_S_SUCCESS;

 if(Tag){
	status = om$objid_to_tag(	osnum = go->osnum,
					objid = go->objid,
					p_tag = Tag);
	as$status();
 }
 if(obj_name){
	vd$get_name(name = obj_name, obj = go);
 }
 if(Class_id ){
	status = om$get_classid(	osnum = go->osnum,
					objid = go->objid,
					p_classid = Class_id);
	as$status();
						
 }
 if(Class_name){
	om$get_classname(	osnum = go->osnum,
				objid = go->objid,
				classname = Class_name);
	as$status();

 }
return 1;
}

/* ---------------------------------------------------------------------- */
/*
/*	verify if the object (ACpretendin or ASsourcein )has parents, 
/*	and return the reference file name and context.
/*	
/****/

int isParentHere( objid, osnum,ref_name,context, ref_id, ref_osnum ) 
OM_S_OBJID 	objid ; 	/* (I) assoc objid */
OMuword 	osnum ;		/* (I) assoc osnum */
char 		*ref_name;	/* (O) reference file name */
struct GRid	*context;	/* (O) context id */
struct GRid	*ref_id;	/* (O) ref file id */
OMuword 	*ref_osnum ;	/* (O) ref file osnum */
{
	
IGRint			i;
long			status, sts;
OM_S_OBJECT_LINKAGE	objOnChan[2] ;
OMuint			count ;
struct GRid		go;
IGRchar			osname[DI_PATH_MAX];
OM_S_CHANSELECT 	ASsource_listeners, GRcontext_to_reffile ;
GRclassid		my_class;
	
if(ref_name == NULL || context == NULL || ref_id == NULL || ref_osnum == NULL){
 	printf("ERROR isParentHere, Invalid argument\n");
	return 0;
}

go.objid = NULL_OBJID;
context->objid = NULL_OBJID;
ref_id->objid = NULL_OBJID;

sts = om$make_chanselect(
		channame	= "ASsource.listeners",
		p_chanselect	= &ASsource_listeners ) ;
sts = om$make_chanselect(
		channame	= "GRcontext.to_reffile",
		p_chanselect	= &GRcontext_to_reffile ) ;
/*
 *  Get the GRcontext.
 */
	
sts = om$get_channel_objects(
			objid		= objid,
			osnum		= osnum,
			p_chanselect	= &ASsource_listeners,
			size		= 2,
			list		= objOnChan,
			count		= &count ) ;


if (!count) {
	om$report_error( sts = sts ) ;
	return 0 ;
}
/*
 *   		The channel is not ordered. Thus we can find the context at 
 *		the first or at the second position 
 */

status=om$get_classid( 	osnum = objOnChan[0].osnum, 
				objid = objOnChan[0].S_objid,
        		 	p_classid = &my_class);
as$status(action = RET_STATUS);

if (count == 1 &&
      	om$is_ancestry_valid(	subclassid = my_class,
             		superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS){
  	 
    	context->objid = objOnChan[0].S_objid;
    	context->osnum = objOnChan[0].osnum;
}

else if(count == 2){
    	if((om$is_ancestry_valid(subclassid = my_class,
        superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
    		 {
			context->objid = objOnChan[0].S_objid;
      			context->osnum = objOnChan[0].osnum;
      			go.objid = objOnChan[1].S_objid;
      			go.osnum = objOnChan[1].osnum;
    		 }
    	else
    		 {
      			go.objid = objOnChan[0].S_objid;
      			go.osnum = objOnChan[0].osnum;
      			context->objid = objOnChan[1].S_objid;
      			context->osnum = objOnChan[1].osnum;
    		 }
}

/*
 * Get the GRreffile.
 */

sts = om$get_channel_objects(
			objid		= context->objid,
			osnum		= context->osnum,
			p_chanselect	= &GRcontext_to_reffile,
			size		= 1,
			list		= objOnChan,
			count		= &count ) ;
if( (sts&1) && count) {
		ref_id->objid = objOnChan[0].S_objid;
		ref_id->osnum = objOnChan[0].osnum;
			
		status = om$send( msg = message GRreffile.GRgetosnum(
						&sts, ref_osnum),
				senderid = NULL_OBJID,
                        	targetid = ref_id->objid,
                        	targetos = ref_id->osnum );

		findRefFileName(	objOnChan[0].S_objid,
						objOnChan[0].osnum,
						ref_name ) ;

}
else if(go.objid != NULL_OBJID){
	/* context is deconnected from the ref file */

	*ref_osnum = go.osnum;
	status = om$os_number_to_name(osnum = go.osnum,
				     osname = osname);
	as$status();
	if(status & 1){
		for(i = strlen(osname);i!=0; i--){
			if(osname[i] == '/'){
				strcpy(ref_name, &osname[i+1]);
				break;
			}
		}
	}
		
}
return 1;

}


/* ---------------------------------------------------------------------- */
/*	Given a context, return the reference file name.
/*	
/****/

int findRefFileName( objid, osnum, ref_name )
OM_S_OBJID objid ; 	/* (I) ref file objid */
OMuword osnum ; 	/* (I) ref file osnum */
char *ref_name; 	/* (O) reference file name */
{

long			sts, msg, sizbuf, nret;
struct GRinquire_list	inquire_requests[3] ;
int			which_error ;
IGRboolean		pass_to_other_spaces,
				reference_file_found ;
struct GRmd_env		md_env;

sizbuf = sizeof(struct GRmd_env	);
gr$get_module_env(	msg = &msg,
			sizbuf = &sizbuf,
			buffer = &md_env,
			nret = &nret);
	
pass_to_other_spaces = FALSE ;

inquire_requests[0].var 		= REFERENCE_FILE_NAME ;
inquire_requests[0].var_ptr		= ref_name ;
inquire_requests[0].num_requested	= 1023 ;
inquire_requests[1].var 		= REFERENCE_FILE_FOUND ;
inquire_requests[1].var_ptr		= (char *) &reference_file_found ;
inquire_requests[1].num_requested	= sizeof reference_file_found ;
inquire_requests[2].var 		= END_REPORT_REQUEST ;

sts = om$send(	msg	= message GRreffile.GRinquireref(
							&msg,
							&md_env,
							inquire_requests,
							&which_error,
							&pass_to_other_spaces,
							NULL ),
			senderid= NULL_OBJID,
			targetid= objid,
			targetos= osnum ) ;

return 1;
}


/* ---------------------------------------------------------------------- */
/* 	Get all the TagCon objects and the info on them
/*	TagCon object is allocated in the function and need to be
/*	deallocated by the user.
/*
/****/

IGRint GetTagCon(nb_TagCon, TagCon)
int			*nb_TagCon;	/* (O) nb TagCon object */
struct TagConInfo 	**TagCon;	/* (O) TagCon Info */
{
int		i, id_max, status;
struct GRid	mod_id, *tag, OBJ;
GRclassid	my_class;

tag = NULL;

if(nb_TagCon == NULL || TagCon == NULL){
	printf("invalid argument\n");
	goto wrapup;
}
if( (*nb_TagCon) && (*TagCon)){
	for(i=0;i< *nb_TagCon; i++) FreeTagCon( & ((*TagCon)[i]) );
	free(*TagCon); *TagCon = NULL;
}
*nb_TagCon = 0;
*TagCon = NULL;

 ex$get_cur_mod( id = &mod_id.objid, osnum = &mod_id.osnum );
 id_max	= OM_GA_OSDs[mod_id.osnum]->CurSpaceMapSize;
 OBJ.osnum = mod_id.osnum;
 
 tag = _MALLOC(id_max,struct GRid);
 if(tag == NULL){
	printf("Bad allocation \n");
	 goto wrapup; 
 }
 
 for ( OBJ.objid = 0; OBJ.objid < id_max; OBJ.objid += 1 ) {

	if ( om$is_objid_valid( osnum	= OBJ.osnum,
				objid	= OBJ.objid ) 
				!= OM_S_SUCCESS )  continue;

	om$get_classid(	osnum		= OBJ.osnum,
			objid		= OBJ.objid,
			p_classid 	= &my_class);

	status = OM_E_ABORT;	


	if( status = om$is_ancestry_valid(
			subclassid     = my_class,
			superclassid =  OPP_OMTagCon_class_id) == OM_S_SUCCESS ){
		tag[*nb_TagCon] = OBJ;
		(*nb_TagCon) ++;
	}

 }
 if(*nb_TagCon){
	*TagCon = 
	   _MALLOC((*nb_TagCon), struct TagConInfo);
	if( (*TagCon) == NULL){
		printf("Bad allocation \n");
		goto wrapup; 
	}
 }
 for(i=0;i<(*nb_TagCon);i++){
	InitTagCon( &((*TagCon)[i]) );
	(*TagCon)[i].obj = tag[i];
	status = vds_get_tagcon_info(	(*TagCon)[i].obj.osnum, 
					(*TagCon)[i].obj.objid,
					(*TagCon)[i].intname,
					& ( (*TagCon)[i].oidlist),
					& ( (*TagCon)[i].taglist),
					& ( (*TagCon)[i].count )  );
  	if(!(status & 1)){
		printf("ERROR vds_get_tagcon_info\n");
		goto wrapup;
	}

 }


_FREE(tag);

return 1;
wrapup:

_FREE(tag);
if(TagCon && (*TagCon) ){
	for(i=0;i< *nb_TagCon; i++) FreeTagCon( & ((*TagCon)[i]) );
	free(*TagCon); *TagCon = NULL;
}
if(nb_TagCon) *nb_TagCon = 0;

return 0;

}


/* ---------------------------------------------------------------------- */
/* 	Try to find the graphic object and reconnect it to
/*	its source.
/****/

IGRint	TryReconnect(nb_TagCon, TagCon, connection, suc)
int			nb_TagCon;	/* (I) nb tag connection in the file */
struct TagConInfo 	*TagCon;	/* (I) tag connection info */
struct ConnInfo 	*connection;	/* (I) connection to rebuild */
int			*suc;		/* (O) 0 = fail to reconnect, 1= success */
{
int			i, tag_index, status;
IGRboolean		found;

if(suc == NULL || connection == NULL){
	printf("invalid argument\n");
	return 0;
}
*suc = 0;

/* get the graphic object that was connected before */


found = FALSE;

for(i=0;i<nb_TagCon;i++){
	for(tag_index = 0; tag_index < TagCon[i].count; tag_index ++){
		if(connection->source_id.objid == TagCon[i].oidlist[tag_index]){
			found = TRUE;
			connection->go_info.tag = TagCon[i].taglist[tag_index];
			break;
		}

	}
	if(found) break;
}

if(found == FALSE){
	/* the connection is not tagged */
	*suc = 0;
	return 1;
}


connection->go_info.obj.osnum = connection->ref_osnum;

status = om$tag_to_objid(osnum = connection->ref_osnum,
			 p_objid = &connection->go_info.obj.objid,
			 tag = connection->go_info.tag);

if(!(status&1)) {
	*suc = 0;
	return 1;
 }



/* reconnect the ASlistener connection */

 status = ReConnect(&connection->source_id, &connection->go_info.obj, 
			&connection->context_id);

 if(!(status & 1)){
	*suc = 0;
	return 1;
 }

*suc = 1;


return 1;


}

/* ---------------------------------------------------------------------- */
/* 	Reconnect the source object to its graphic, and context
/****/

IGRint	ReConnect(source, go, context)
struct GRid	*source;
struct GRid	*go;
struct GRid	*context;

{
IGRint		list_index = 0;
IGRlong		msg, status;
OM_S_CHANSELECT misc_chan;
IGRboolean	prev_tag, tag_conn;
GRspacenum	prev_osnum, dummy, tag_osnum;



/* deconnect from the source the ASlistener connections 
	(GRcontext and Graphic obj )

*/


status = om$send(msg = message Root.wild_disconnect(AS_listeners),
		senderid = NULL_OBJID,
		targetid = source->objid,
		targetos = source->osnum);

as$status(action = RET_STATUS);


prev_tag = om$enable_tag_connects( flag = TRUE );

om$set_tag_os(	p_prev_osnum = &prev_osnum,
        	osnum        = go->osnum );


/* connect the graphic object */

tag_conn = FALSE;
status = om$send( msg = message GRnotify.GRntfyconn( &msg, source,
                   &AS_listeners, &list_index, &tag_conn, &tag_osnum ), 
		   	senderid = NULL_OBJID,
		   	targetid = go->objid,
                   	targetos = go->osnum );
as$status(action = RET_STATUS);
if (!(msg & 1) ) {
     	/*|  Connection impossible -> On tue l'object associatif */
	return 0;
}


if( prev_tag ){
      /*| prev_tag is true */

      om$set_tag_os( p_prev_osnum = &dummy, osnum = prev_osnum );
}


/* now connect to the context */

status = om$make_chanselect(channame = "GRcontext.to_misc",
          p_chanselect = &misc_chan);

as$status(action = RET_STATUS);

status = om$send(msg = message Root.connect(misc_chan,OM_K_MAXINT,source->objid,
          	source->osnum,AS_listeners,OM_K_MAXINT),
		senderid = NULL_OBJID,
          	targetid = context->objid,
          	targetos = context->osnum);

as$status(action = RET_STATUS);
    
return 1;
}


end implementation Root;



