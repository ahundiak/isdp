/* # $Id: VDCmdPlPtsi.I,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $ */
 
/* # -------------------------------------------------------------------
# I/VDS
#
# File: vds/vdpts/VDCmdPlPtsi.I
#
# Description:
#
# Dependencies:
#
# Revision History:
#       $Log: VDCmdPlPtsi.I,v $
#       Revision 1.1.1.1  2001/01/04 21:09:05  cvs
#       Initial import to CVS
#
# Revision 1.2  1998/10/23  18:44:02  pinnacle
# tr179802164
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/10/31  19:39:18  pinnacle
# UnInit warnings
#
# Revision 1.3  1997/06/05  17:45:04  pinnacle
# Replaced: vdpts/VDCmdPlPtsi.I for:  by impd for vds
#
# Revision 1.2  1997/06/05  13:51:36  pinnacle
# Replaced: vdpts/VDCmdPlPtsi.I for:  by impd for vds
#
# Revision 1.1  1997/05/30  09:09:46  pinnacle
# initial revision
#
# History:
#       MM/DD/YY        AUTHOR          DESCRIPTION
#       05/30/97        Sundar          Creation Date
#	10/31/97	ah		Warnings
#       10/23/98        ylong           tr179802164(crash on empty file)
#
# -------------------------------------------------------------------*/

class implementation VDCmdPlPts;

#include <stdio.h>
#include "msmacros.h"
#include "ASmessages.h"
/* Added */
#include "OMmacros.h"
#include "exmacros.h"
#include "asmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "macro.h"
#include "parametric.h" 
/* Added */
#include "asbox.h"
#include "AS_status.h"
#include "OMmacros.h"
#include "madef.h"
#include "expression.h"
#include "expmacros.h"

#include "nddef.h"
#include "dp.h"
#include "dpmacros.h"

#include "VDcmd.h"
#include "v_dbgmacros.h"
#include "v_miscmacros.h"
#include "VDmem.h"

#define PLACE 0
#define VD_K_FILE_ACCEPTED   260
#define VD_K_FILE_CANCELED   261

extern OMuword OPP_AScspoint_class_id;

struct GRas
{
	OMuint num_parents;    /*  number of parents  */
	struct GRid *parents;  /*  pointer to parents GRid  */
	struct GRid *context;  /*  pointer to parent context GRid if the */
			/* parent is in a reference file. NULL_GRid if not */ 
	IGRchar *as_attr;  /*  pointer to specific attributes for as object  */
	IGRchar *go_attr;  /*  pointer to specific attributes for go object  */
	struct GRid go_objid;     /*  graphic object objid  */
	struct GRid my_context;   /*  context of the graphic object */
};


from GRgraphics import GRconstruct, GRdisplay;
from AScspoint import NDplace;
from NDnode import NDget_objects;

extern GRclassid OPP_AScspoint_class_id;
#define VD_K_MAX_RGXP 30
#define MAXPATHLEN 1024

%safe
static char     curPATH[MAXPATHLEN      +1]     = ".",
                curNAME[FILENAME_MAX    +1]     = "",
                curRGXP[VD_K_MAX_RGXP]          = "*" ;
%endsafe

method wakeup ( int pos )
{
	if ( me->mytype == PLACE ){
		ex$message( msgnumb = VDC_M_VDPlPts);
	}
	else{
		ex$message( msgnumb = VDC_M_VDWrPts);
	}

	return( OM_S_SUCCESS);
}

method store_cs ( long *msg ) {
 
        long    sts ;
        int     index = 0;
 
        sts = om$send(  msg     = message VDS_LOCATE.addLocatedObject(
                                msg,
                                &me->event1.located_object[0].located_obj,
                                &me->event1.located_object[0].module_info,
                                index ),
                        targetid= my_id ) ;
        return OM_S_SUCCESS ;
}
method store_active_cs ( long *msg ) {
 
        long    sts ;
        int     index = 0;
        struct GRobj_env csGrid;
 
 
        sts = VDget_active_cs(msg, &csGrid);
        sts = om$send(  msg     = message VDS_LOCATE.addLocatedObject(
                                msg,
                                &csGrid.obj_id,
                                &csGrid.mod_env,
                                index ),
                        targetid= my_id ) ;
        return OM_S_SUCCESS ;
}
method store_file_name( long *msg )
{
//      IGRlong sts;
 
        strcpy(me->fileName , me->event1.event.keyin );
        if( fopen(me->fileName, (me->mytype == PLACE) ? "r" : "w" ) == NULL){
                *msg = OM_E_ABORT ;
                me->ret = OM_E_ABORT ;
                UI_status(" cannot open file" );
		me->fileName[0]='\0';
        }
	
        return OM_S_SUCCESS ;
}
method createFileForm( long *msg ) {
 
        strcpy( me->fileInfo.openMode, (me->mytype == PLACE) ? "r" : "w" ) ;
        me->fileInfo.callBack= NULL ;
        me->fileInfo.curPATH = curPATH ;
        me->fileInfo.curNAME = curNAME ;
        me->fileInfo.curRGXP = curRGXP ;
        if( !me->fileForm ) {
                me->fileForm = (char *) VDcreateFileForm( 10,
                                                         100,
                                                         &me->fileInfo ) ;
        }
        *msg = me->fileForm ? MSSUCC : MSFAIL ;
        return OM_S_SUCCESS ;
 
} /* method createFileForm */
method fileFormDismissed( int dismissType ) {
 
        switch( dismissType ) {
                case VD_K_FILE_ACCEPTED : break ;
                case VD_K_FILE_CANCELED : me->fileInfo.pathName[0] = '\0' ;
                                          break ;
        }
        me->fileForm = NULL ;
        return OM_S_SUCCESS ;
 
} /* method fileFormDismissed */
method fileFormOnOffOut( int Switch /* 0=off, 1=on, 2=out */ ) {
 
        if( me->fileForm ) {
                switch( Switch ) {
                        case 0 : FIf_erase  ( me->fileForm ) ; break ;
                        case 1 : FIf_display( me->fileForm ) ; break ;
                        case 2 : FIf_delete ( me->fileForm ) ;
                                 me->fileForm = NULL ; break ;
                }
        }
 
        return OM_S_SUCCESS ;
 
} /* method fileFormOnOffOut */

// Note, sts never gets set argsused does not work for methods
method VDSplace_points ( long *sts)
{
	struct GRmd_env md_env;
	struct GRvg_construct cnst_list;
	long status,msg;
	double point[3];
//	struct IGRpolyline geom_l;	// Not used
	long cnst_lis_msg;
	struct IGRdisplay      Active_display;
	IGRshort               Active_level;
	struct GRid dummy;
	struct GRid display_info;
	enum GRdpmode               DisplayMode;
	IGRint size, retsize;
	FILE *fp;
	IGRchar response_data[30] ;
	IGRchar dumdum[80] ;			// HF: 06/05/97

	/* For AScspoint */
	IGRint i;
	IGRdouble val_param;
	struct GRas         asso_lis;
//	struct ret_struct   cs_struct;     /* structure of the parent         */
//	int                 msg_numb[3];   /* prompts                         */
	struct GRid         list_id[4];
	struct GRid         parents[4];
	struct GRid         context[4];
	struct GRobj_env        csObj[1] ;	// HF: 06/05/97

	if (sts);	// Get rid of warning

	/* For AScspoint */

	size=sizeof(struct GRmd_env);
	gr$get_module_env(msg = &msg,
                        sizbuf = &size,
                        buffer = &md_env,
                        nret = &retsize);

	ASget_active_symb(&Active_level,&Active_display);
	Active_display.weight=4;

	cnst_list.msg = &cnst_lis_msg;
	cnst_list.env_info = &md_env;
	cnst_list.display = &Active_display;
	cnst_list.geometry = 0;
	cnst_list.newflag = FALSE;
	cnst_list.level = Active_level;
	cnst_list.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
	cnst_list.class_attr = (IGRchar *) &asso_lis;
	cnst_list.name = NULL;

	strcpy(dumdum,"");
	asso_lis.num_parents = 4;
	asso_lis.parents     = parents;
	asso_lis.go_attr     = dumdum;	//NULL;	// HF: 06/05/97
	asso_lis.as_attr     = dumdum;	//NULL;
//	strcpy(asso_lis.as_attr,"");
	asso_lis.context     = context;
	asso_lis.go_objid    = NULL_GRID ; 
	context[0] = NULL_GRID;
	context[1] = NULL_GRID;
	context[2] = NULL_GRID;

	DisplayMode = GRbd;	/* how to display element */ 
	GRfindmod(&display_info);
	dummy.osnum = md_env.md_id.osnum;

	/*
	list_id[3].objid = me->event1.located_object[0].located_obj.objid ;
	list_id[3].osnum = me->event1.located_object[0].located_obj.osnum ;
	*/
	status = om$send( msg     = message VDS_LOCATE.getLocatedObjects(
                                                                &msg,
                                                                1,
                                                                csObj ),
                        targetid=my_id );
        __CheckRC( status, msg, "VDS_LOCATE.getLocatedObject", wrapup );
 
        list_id[3].objid = csObj[0].obj_id.objid ;
        list_id[3].osnum = csObj[0].obj_id.osnum ;
 
        if(me->fileInfo.curNAME[0] == '\0' || me->fileInfo.pathName[0] == '\0')
		goto wrapup ;

	status = GRfindcontext( &msg, &md_env.md_env.matrix_type,
                    md_env.md_env.matrix, &list_id[3].osnum, &context[3] );

	fp=fopen(me->fileInfo.pathName, "r");
	while ( fscanf(fp,"%lf %lf %lf",&point[0],&point[1],&point[2]) != EOF ){
   		for (i=0; i<3; i++){
			sprintf(response_data,"%lf",point[i]);
			status = ASget_param_from_string (response_data,
							double_type, 
							&list_id[i],
							&val_param,
							&md_env);
		}
		for (i=0; i<4; i++){
			as$make_source(go_grid = list_id[i],
					as_os = list_id[i].osnum,
					as_grid = &parents[i]);
		}

		status = om$construct(classid = OPP_AScspoint_class_id,
      		        		osnum = dummy.osnum,
      		        		p_objid = &dummy.objid);
		as$status();
		/*
		printf ("Before NDplace\n");
		status = om$send(msg = message AScspoint.NDplace( &asso_lis,
				&md_env, (IGRchar *)&cnst_list ),
				targetos = dummy.osnum,
                       		targetid = dummy.objid);
		as$status();
		printf ("After NDplace\n");
		*/

	
		status=om$send(msg = message GRgraphics.GRconstruct(&cnst_list),
				targetos = dummy.osnum,
                       		targetid = dummy.objid);
		as$status();
	
		status = om$send(msg = message GRgraphics.GRdisplay( &msg,
      		                      	&md_env.md_env.matrix_type,
      		                       	md_env.md_env.matrix,
      		                       	&DisplayMode, 
					&display_info),
      		           	targetid = dummy.objid,
      		           	targetos = dummy.osnum);
		as$status();
	
	}
	fclose(fp);

wrapup :
	return status; 

} /* end VDSplace_points method */

method VDSwrite_points( long *status)
{
	IGRlong msg;
	struct GRid *list=NULL, param[4];
	IGRint	i, j, count=0, nb_roots;
	IGRdouble dbl[3];
	FILE *fp;
	
	*status=OM_S_SUCCESS;
	*status=VDobjInActiveSpace( &msg, &count, &list, 
					OPP_AScspoint_class_id);
	
	if ( count == 0 ) goto wrapup ;

	fp=fopen(me->fileInfo.pathName,"w");
	for(i=0; i<count; i++){
		*status=om$send(msg=message NDnode.NDget_objects
					(ND_ROOT,
                 			param,4,NULL,0,3, &nb_roots),
                    		targetid = list[i].objid,
                    		targetos = list[i].osnum);

		for (j=0; j<3; j++){
			*status=VD_expValue(param[j].objid,
						param[j].osnum,
						&dbl[j]);	
		}
		fprintf (fp, "%lf %lf %lf\n", dbl[0], dbl[1], dbl[2] );	
	}
	fclose(fp);

wrapup :
	if ( list )_FREE(list);
	return OM_S_SUCCESS ;    //tr179802164
}

method dehilite( long *sts )
{
	IGRlong msg;
 
  	dp$erase_hilite(msg = &msg);
        return OM_S_SUCCESS ;
}

end implementation VDCmdPlPts;
