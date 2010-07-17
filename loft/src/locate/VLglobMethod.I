/* ************************************************************************** */
/*      File :          <VLglobMethod.I>                                      */
/*                                                                            */
/*      Author :	Marc Fournier (COC shipbuilding)                      */
/*                                                                            */
/*      History :       12-Jan-1993     creation of <VLlocMethod.I>           */
/*                      05-Apr-1995     group methods in <VLpathMethod.I>     */
/*                                                                            */
/*      These <VLlocate> methods manage the Loft global variables.	      */
/* ************************************************************************** */

class implementation VLlocateCmd;

#include	"vlprototype.h"
#include	"AS_status.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"griomacros.h"

#include	"vlglobals.h"

from	ACrg_collect	import	ACcreate,
				AClist_attribute, ACset_list_attribute,
				ACget_named_attribute, ACmod_list_attribute;
from	NDnode		import	NDdelete;

extern	GRclassid	OPP_ACrg_collect_class_id;

#if ISDP_MAKE_SP
extern struct  GRid MANwk_hull;
#else
%safe
struct	GRid	MANwk_hull = { 0, (OM_S_OBJID)-1 };
%endsafe
#endif

/*	#define	TRACE	*/

/* ************************************************************************** */
method VLsetGlobals	(IGRlong		*msg;
			 IGRchar		*path )
{
		IGRlong		sts;
	struct	ACrg_coll	globals[GLOBAL_G_NUMBER];
		IGRint		db_type;

#ifdef TRACE
		IGRint		i;
#endif


	/* Construct ACrg_collect object */
	me->Globals.objid = NULL_OBJID;
	me->Globals.osnum = me->Current.md_id.osnum;
	om$construct ( classid = OPP_ACrg_collect_class_id,
                       osnum   = me->Globals.osnum,
                       p_objid = &me->Globals.objid );
#ifdef TRACE
printf( "om$construct(OPP_ACrg_collect_class_id) --> me->Globals : (%d|%d)\n",
	me->Globals.osnum, me->Globals.objid );
#endif

	/* Name ACrg_collect object */
	sts = om$send ( msg = message ACrg_collect.ACcreate (msg, path),
			targetid = me->Globals.objid,
			targetos = me->Globals.osnum );
	as$status ( sts    = sts,
	    	    msg    = "ACrg_collect.ACcreate",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );
#ifdef TRACE
printf( "ACrg_collect.ACcreate(%s) with me->Globals : (%d|%d)\n",
	path, me->Globals.osnum, me->Globals.objid );
#endif

	/* Fill ACrg_coll object */
	strcpy ( globals[IDX_G_MID].name, NAM_G_MID);
	strcpy ( globals[IDX_G_TGG].name, NAM_G_TGG);
	strcpy ( globals[IDX_G_JGG].name, NAM_G_JGG);
	strcpy ( globals[IDX_G_EXT].name, NAM_G_EXT);
	strcpy ( globals[IDX_G_PGH].name, NAM_G_PGH);
	strcpy ( globals[IDX_G_PGW].name, NAM_G_PGW);
	strcpy ( globals[IDX_G_PGS].name, NAM_G_PGS);
	strcpy ( globals[IDX_G_RAD].name, NAM_G_RAD);
	strcpy ( globals[IDX_G_OFF].name, NAM_G_OFF);
	strcpy ( globals[IDX_G_SPA].name, NAM_G_SPA);
	strcpy ( globals[IDX_G_XTS].name, NAM_G_XTS);
	strcpy ( globals[IDX_G_YTS].name, NAM_G_YTS);
	strcpy ( globals[IDX_G_XJS].name, NAM_G_XJS);
	strcpy ( globals[IDX_G_YJS].name, NAM_G_YJS);
	strcpy ( globals[IDX_G_XJF].name, NAM_G_XJF);
	strcpy ( globals[IDX_G_YJF].name, NAM_G_YJF);
	strcpy ( globals[IDX_G_SPI].name, NAM_G_SPI);
	strcpy ( globals[IDX_G_XPI].name, NAM_G_XPI);
	strcpy ( globals[IDX_G_YPI].name, NAM_G_YPI);
	strcpy ( globals[IDX_G_MRG].name, NAM_G_MRG);
	strcpy ( globals[IDX_G_SYO].name, NAM_G_SYO);
	strcpy ( globals[IDX_G_TJT].name, NAM_G_TJT);
	strcpy ( globals[IDX_G_PJT].name, NAM_G_PJT);
	strcpy ( globals[IDX_G_IPJ].name, NAM_G_IPJ);
	strcpy ( globals[IDX_G_PJI].name, NAM_G_PJI);
	strcpy ( globals[IDX_G_FUL].name, NAM_G_FUL);
	strcpy ( globals[IDX_G_HLE].name, NAM_G_HLE);
	strcpy ( globals[IDX_G_HRA].name, NAM_G_HRA);
	strcpy ( globals[IDX_G_HWI].name, NAM_G_HWI);
	strcpy ( globals[IDX_G_TSZ].name, NAM_G_TSZ);
	strcpy ( globals[IDX_G_JSZ].name, NAM_G_JSZ);
	strcpy ( globals[IDX_G_PJQ].name, NAM_G_PJQ);
	strcpy ( globals[IDX_G_STH].name, NAM_G_STH);
	strcpy ( globals[IDX_G_STT].name, NAM_G_STT);
	strcpy ( globals[IDX_G_STE].name, NAM_G_STE);
	strcpy ( globals[IDX_G_STW].name, NAM_G_STW);
	strcpy ( globals[IDX_G_STC].name, NAM_G_STC);
	strcpy ( globals[IDX_G_UPD].name, NAM_G_UPD);
	strcpy ( globals[IDX_G_UNW_CODE].name, NAM_G_UNW_CODE);
	strcpy ( globals[IDX_G_UNW_SURF].name, NAM_G_UNW_SURF);
	strcpy ( globals[IDX_G_WATONPLATE].name, NAM_G_WATONPLATE);
	strcpy ( globals[IDX_G_TESS].name, NAM_G_TESS);
	strcpy ( globals[IDX_G_OFFSET].name, NAM_G_OFFSET);
	strcpy ( globals[IDX_G_REL_ER].name, NAM_G_REL_ER);
	strcpy ( globals[IDX_G_FIB].name, NAM_G_FIB);
	strcpy ( globals[IDX_G_T_EXP].name, NAM_G_T_EXP);
	strcpy ( globals[IDX_G_SIDE].name, NAM_G_SIDE);
	strcpy ( globals[IDX_G_X_EXP].name, NAM_G_X_EXP);
	strcpy ( globals[IDX_G_Y_EXP].name, NAM_G_Y_EXP);
	strcpy ( globals[IDX_G_JGO].name, NAM_G_JGO);
	strcpy ( globals[IDX_G_JSO].name, NAM_G_JSO);
	strcpy ( globals[IDX_G_JSW].name, NAM_G_JSW);
	strcpy ( globals[IDX_G_BOO].name, NAM_G_BOO);
	strcpy ( globals[IDX_G_STATION].name, NAM_G_STATION);
	strcpy ( globals[IDX_G_PC_BDR_NAME].name, NAM_G_PC_BDR_NAME);
	strcpy ( globals[IDX_G_PC_GAP].name, NAM_G_PC_GAP);
	strcpy ( globals[IDX_G_PC_MAX_COL].name, NAM_G_PC_MAX_COL);
	strcpy ( globals[IDX_G_PC_VERBOSE].name, NAM_G_PC_VERBOSE);
	strcpy ( globals[IDX_G_PJM].name, NAM_G_PJM);
	strcpy ( globals[IDX_G_PTN].name, NAM_G_PTN);
	strcpy ( globals[IDX_G_PJN].name, NAM_G_PJN);
	strcpy ( globals[IDX_G_PJH].name, NAM_G_PJH);
	strcpy ( globals[IDX_G_BEND_STEP].name, NAM_G_BEND_STEP );
        strcpy ( globals[IDX_G_TEMP_STEP].name, NAM_G_TEMP_STEP );

	globals[IDX_G_MID].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_TGG].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_JGG].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_EXT].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PGH].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PGW].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PGS].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_RAD].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_OFF].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_SPA].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_XTS].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_YTS].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_XJS].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_YJS].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_XJF].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_YJF].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_SPI].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_XPI].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_YPI].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_MRG].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_SYO].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_TJT].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PJT].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_IPJ].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PJI].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_FUL].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_HLE].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_HRA].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_HWI].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_TSZ].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_JSZ].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PJQ].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_STH].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_STT].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_STE].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_STW].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_STC].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_UPD].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_UNW_CODE].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_UNW_SURF].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_WATONPLATE].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_TESS].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_OFFSET].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_REL_ER].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_FIB].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_T_EXP].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_SIDE].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_X_EXP].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_Y_EXP].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_JGO].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_JSO].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_JSW].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_BOO].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_STATION].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PC_BDR_NAME].desc.type = AC_ATTRIB_TEXT;
	globals[IDX_G_PC_GAP].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PC_MAX_COL].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PC_VERBOSE].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PJM].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PTN].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PJN].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_PJH].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_BEND_STEP].desc.type = AC_ATTRIB_DOUBLE;
	globals[IDX_G_TEMP_STEP].desc.type = AC_ATTRIB_DOUBLE;

	globals[IDX_G_MID].desc.value.att_exp = VAL_G_MID;
	globals[IDX_G_TGG].desc.value.att_exp = VAL_G_TGG;
	globals[IDX_G_JGG].desc.value.att_exp = VAL_G_JGG;
	globals[IDX_G_EXT].desc.value.att_exp = VAL_G_EXT;
	globals[IDX_G_PGH].desc.value.att_exp = VAL_G_PGH;
	globals[IDX_G_PGW].desc.value.att_exp = VAL_G_PGW;
	globals[IDX_G_PGS].desc.value.att_exp = VAL_G_PGS;
	globals[IDX_G_RAD].desc.value.att_exp = VAL_G_RAD;
	globals[IDX_G_OFF].desc.value.att_exp = VAL_G_OFF;
	globals[IDX_G_SPA].desc.value.att_exp = VAL_G_SPA;
	globals[IDX_G_XTS].desc.value.att_exp = VAL_G_XTS;
	globals[IDX_G_YTS].desc.value.att_exp = VAL_G_YTS;
	globals[IDX_G_XJS].desc.value.att_exp = VAL_G_XJS;
	globals[IDX_G_YJS].desc.value.att_exp = VAL_G_YJS;
	globals[IDX_G_XJF].desc.value.att_exp = VAL_G_XJF;
	globals[IDX_G_YJF].desc.value.att_exp = VAL_G_YJF;
	globals[IDX_G_SPI].desc.value.att_exp = VAL_G_SPI;
	globals[IDX_G_XPI].desc.value.att_exp = VAL_G_XPI;
	globals[IDX_G_YPI].desc.value.att_exp = VAL_G_YPI;
	globals[IDX_G_MRG].desc.value.att_exp = VAL_G_MRG;
	globals[IDX_G_SYO].desc.value.att_exp = VAL_G_SYO;
	globals[IDX_G_TJT].desc.value.att_exp = VAL_G_TJT;
	globals[IDX_G_PJT].desc.value.att_exp = VAL_G_PJT;
	globals[IDX_G_IPJ].desc.value.att_exp = VAL_G_IPJ;
	globals[IDX_G_PJI].desc.value.att_exp = VAL_G_PJI;
	globals[IDX_G_FUL].desc.value.att_exp = VAL_G_FUL;
	globals[IDX_G_HLE].desc.value.att_exp = VAL_G_HLE;
	globals[IDX_G_HRA].desc.value.att_exp = VAL_G_HRA;
	globals[IDX_G_HWI].desc.value.att_exp = VAL_G_HWI;
	globals[IDX_G_TSZ].desc.value.att_exp = VAL_G_TSZ;
	globals[IDX_G_JSZ].desc.value.att_exp = VAL_G_JSZ;
	globals[IDX_G_PJQ].desc.value.att_exp = VAL_G_PJQ;
	globals[IDX_G_STH].desc.value.att_exp = VAL_G_STH;
	globals[IDX_G_STT].desc.value.att_exp = VAL_G_STT;
	globals[IDX_G_STE].desc.value.att_exp = VAL_G_STE;
	globals[IDX_G_STW].desc.value.att_exp = VAL_G_STW;
	globals[IDX_G_STC].desc.value.att_exp = VAL_G_STC;
	globals[IDX_G_UPD].desc.value.att_exp = VAL_G_UPD;
	globals[IDX_G_UNW_CODE].desc.value.att_exp = VAL_G_UNW_CODE;
	globals[IDX_G_UNW_SURF].desc.value.att_exp = VAL_G_UNW_SURF;
	globals[IDX_G_WATONPLATE].desc.value.att_exp = VAL_G_WATONPLATE;
	globals[IDX_G_TESS].desc.value.att_exp = VAL_G_TESS;
	globals[IDX_G_OFFSET].desc.value.att_exp = VAL_G_OFFSET;
	globals[IDX_G_REL_ER].desc.value.att_exp = VAL_G_REL_ER;
	globals[IDX_G_FIB].desc.value.att_exp = VAL_G_FIB;
	globals[IDX_G_T_EXP].desc.value.att_exp = VAL_G_T_EXP;
	globals[IDX_G_SIDE].desc.value.att_exp = VAL_G_SIDE;
	globals[IDX_G_X_EXP].desc.value.att_exp = VAL_G_X_EXP;
	globals[IDX_G_Y_EXP].desc.value.att_exp = VAL_G_Y_EXP;
	globals[IDX_G_JGO].desc.value.att_exp = VAL_G_JGO;
	globals[IDX_G_JSO].desc.value.att_exp = VAL_G_JSO;
	globals[IDX_G_JSW].desc.value.att_exp = VAL_G_JSW;
	globals[IDX_G_BOO].desc.value.att_exp = VAL_G_BOO;
	globals[IDX_G_STATION].desc.value.att_exp = VAL_G_STATION;
	strcpy( globals[IDX_G_PC_BDR_NAME].desc.value.att_txt,
		VAL_G_PC_BDR_NAME);
	globals[IDX_G_PC_GAP].desc.value.att_exp = VAL_G_PC_GAP;
	globals[IDX_G_PC_MAX_COL].desc.value.att_exp = VAL_G_PC_MAX_COL;
	globals[IDX_G_PC_VERBOSE].desc.value.att_exp = VAL_G_PC_VERBOSE;
	globals[IDX_G_PJM].desc.value.att_exp = VAL_G_PJM;
	globals[IDX_G_PTN].desc.value.att_exp = VAL_G_PTN;
	globals[IDX_G_PJN].desc.value.att_exp = VAL_G_PJN;
	globals[IDX_G_PJH].desc.value.att_exp = VAL_G_PJH;
	globals[IDX_G_BEND_STEP].desc.value.att_exp = VAL_G_BEND_STEP;
	globals[IDX_G_TEMP_STEP].desc.value.att_exp = VAL_G_TEMP_STEP;

        sts = co$unit_database_type(    osnum   = me->Globals.osnum,
                                        db_type = &db_type );

	if ( ( sts & 1 ) && db_type == GRIO_UNITS_ARE_ENGLISH )
	{

 	  globals[IDX_G_TGG].desc.value.att_exp = VAL_ENG_TGG;
	  globals[IDX_G_JGG].desc.value.att_exp = VAL_ENG_JGG;
	  globals[IDX_G_EXT].desc.value.att_exp = VAL_ENG_EXT;
	  globals[IDX_G_PGH].desc.value.att_exp = VAL_ENG_PGH;
	  globals[IDX_G_PGW].desc.value.att_exp = VAL_ENG_PGW;
	  globals[IDX_G_RAD].desc.value.att_exp = VAL_ENG_RAD;
	  globals[IDX_G_OFF].desc.value.att_exp = VAL_ENG_OFF;
	  globals[IDX_G_SPA].desc.value.att_exp = VAL_ENG_SPA;
	  globals[IDX_G_XPI].desc.value.att_exp = VAL_ENG_XPI;
	  globals[IDX_G_YPI].desc.value.att_exp = VAL_ENG_YPI;
	  globals[IDX_G_MRG].desc.value.att_exp = VAL_ENG_MRG;
	  globals[IDX_G_PJI].desc.value.att_exp = VAL_ENG_PJI;
	  globals[IDX_G_STH].desc.value.att_exp = VAL_ENG_STH;
	  globals[IDX_G_STT].desc.value.att_exp = VAL_ENG_STT;
	  globals[IDX_G_STE].desc.value.att_exp = VAL_ENG_STE;
	  globals[IDX_G_REL_ER].desc.value.att_exp = VAL_ENG_REL_ER;
	  globals[IDX_G_JSW].desc.value.att_exp = VAL_ENG_JSW;
	  globals[IDX_G_PC_GAP].desc.value.att_exp = VAL_ENG_PC_GAP;
	  globals[IDX_G_PJH].desc.value.att_exp = VAL_ENG_PJH;

	}

	sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
					(msg, GLOBAL_G_NUMBER, globals),
			targetid = me->Globals.objid,
			targetos = me->Globals.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACset_list_attribute",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
#ifdef TRACE
printf( "ACrg_collect.ACset_list_attribute(%d) --> me->Globals = (%d|%d)\n",
	GLOBAL_G_NUMBER, me->Globals.osnum, me->Globals.objid );
for ( i=0; i<GLOBAL_G_NUMBER; i++)
	printf( "New attribute %2d is called <%s> = %lf\n", i, globals[i].name,
		globals[i].desc.value.att_exp );
#endif

wrapup :
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
method VLupdGlobals	(IGRlong		*msg)
{
		IGRlong		ret, sts;
		IGRchar		path[DI_PATH_MAX];
		IGRint		num=0;
	struct	ACrg_coll	globals[GLOBAL_G_NUMBER];
#ifdef TRACE
		IGRint		i;
#endif


	/* Retrieve current osnum absolute path */
	ret = di$give_pathname ( osnum	  = me->Current.md_id.osnum,
				 pathname = path );
	if (ret != DIR_S_SUCCESS) {
		di$report_error ( sts     = ret, 
				  comment = "\tdi$give_pathname()");
		sts = ret;
		goto wrapup;
	}

	/* Search named ACrg_coll under "IGENOD" directory */
	sprintf ( path, "%s:IGENOD:%s", path, GLOBAL_G_NAME);
	me->Globals.objid = NULL_OBJID;
	me->Globals.osnum = me->Current.md_id.osnum;
	ret = di$translate ( objname = path,
			     p_objid = &me->Globals.objid,
			     p_osnum = &me->Globals.osnum );
#ifdef TRACE
printf( "di$translate (path = <%s>) : (%d|%d), returns %d (check with %d)\n",
	path, me->Globals.osnum, me->Globals.objid, ret, DIR_W_NAME_NOT_FOUND );
#endif

	if (ret == DIR_S_SUCCESS) {

		/* Save current global structure */
		sts = om$send ( msg = message ACrg_collect.AClist_attribute
					( msg, GLOBAL_G_NUMBER, globals, &num),
				targetid = me->Globals.objid,
				targetos = me->Globals.osnum );
#ifdef TRACE
printf( "ACrg_collect.AClist_attribute() --> me->Globals : (%d|%d)\n",
	me->Globals.osnum, me->Globals.objid );
printf( "<%s> contains %d old attributes and %d new\n",
	path, num, GLOBAL_G_NUMBER);
for ( i=0; i<num; i++)
	printf( "Old attribute %2d is called <%s> = %lf\n", i, globals[i].name,
		globals[i].desc.value.att_exp );
#endif
		if (GLOBAL_G_NUMBER <= num)	goto wrapup;
		else {	sts = om$send ( msg = message NDnode.NDdelete 
							(&me->Current),
					targetid = me->Globals.objid,
					targetos = me->Globals.osnum );
			as$status ( sts    = sts,
		    		    msg    = "NDnode.NDdelete",
		    		    test   = (!(sts & 0x00000001)),
		    		    action = GOTO_VALUE,
		    		    value  = wrapup );
		}
	}

	/* Generate a brand new global structure */
	sts = om$send ( msg = message VLlocateCmd.VLsetGlobals ( msg, path),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "VLlocateCmd.VLsetGlobals",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	if (num > 0) {
		/* Modify new global structure with saved values */
		sts = om$send ( msg = message ACrg_collect.ACmod_list_attribute
						( msg, num, globals),
				targetid = me->Globals.objid,
				targetos = me->Globals.osnum );
		as$status ( sts    = sts,
		    	    msg    = "ACrg_collect.ACmod_list_attribute",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );
#ifdef TRACE
printf( "ACrg_collect.ACmod_list_attribute(%d) --> me->Globals : (%d|%d)\n",
	num, me->Globals.osnum, me->Globals.objid );
#endif
	}

wrapup :
        return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
method VLgetGlobals	( IGRlong		*msg;
			  IGRchar		*name;
			  IGRdouble		*value )
{
		IGRlong		sts=MSFAIL;
	struct	ACrg_coll	response;

	/* Retrieve value */
	strcpy ( response.name, name);
	*value = 0.0;
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, &response),
			targetid = me->Globals.objid,
			targetos = me->Globals.osnum );
	as$status ( sts    = sts,
	    	    msg    = "ACrg_collect.ACget_named_attribute",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );
	*value = response.desc.value.att_exp;
wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
method VLmodGlobals	( IGRlong		*msg;
			  IGRchar		*name;
			  IGRdouble		value )
{
		IGRlong		sts=MSFAIL;
	struct	ACrg_coll	response;


	/* Retrieve ACrg_coll size */
	strcpy ( response.name, name);
	response.desc.type = AC_ATTRIB_DOUBLE;
	response.desc.value.att_exp = value;
	sts = om$send ( msg = message ACrg_collect.ACmod_list_attribute
					( msg, 1, &response),
			targetid = me->Globals.objid,
			targetos = me->Globals.osnum );
	as$status ( sts    = sts,
	    	    msg    = "ACrg_collect.ACmod_list_attribute",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

wrapup:
	return (sts);
}
/* ************************************************************************** */

end implementation VLlocateCmd;
