class implementation Root;

#include	<stdio.h>
#include	<string.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"exdef.h"
#include	"ex.h"
#include	"igrdp.h"
#include	"gr.h"
#include	"growner.h"
#include	"go.h"
#include	"griodef.h"
#include	"grio.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "AS_status.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"

#include	"vlglobals.h"

from	ACrg_collect	import	GRchgname;

//	#define	TRACE

IGRint VLconvertMANtoLOFT ()

{

		IGRint		i, j, sts=OM_S_SUCCESS, chg[16], max;
		IGRlong		ret, size=sizeof(struct GRmd_env), nret;
		IGRchar		path[DI_PATH_MAX];
		IGRchar		oldname[DI_PATH_MAX], newname[DI_PATH_MAX];
	struct	GRid		globals;
	struct	GRmd_env	md_env;
		IGRchar		old[320], new[320], nam[80];

	/*c Retrieve current environment */
	gr$get_module_env ( msg    = &ret,
                            sizbuf = &size,
                            buffer = &md_env,
                            nret   = &nret );

	/*c Retrieve current osnum absolute path */
        ret = di$give_pathname ( osnum    = md_env.md_id.osnum,
                                 pathname = path );
        if (ret != DIR_S_SUCCESS) {
                di$report_error ( sts     = ret,
                                  comment = "\tdi$give_pathname()");
                sts = ret;
                goto wrapup;
        }

	/*c Search old ACrg_coll under "IGENOD" directory */
	sprintf ( oldname, "%s:IGENOD:MANglobals", path);
        globals.objid = NULL_OBJID;
        globals.osnum = md_env.md_id.osnum;
        ret = di$translate ( objname = oldname,
                             p_objid = &globals.objid,
                             p_osnum = &globals.osnum );
	if (ret == DIR_S_SUCCESS) {
		sprintf ( newname, "%s:IGENOD:%s", path, GLOBAL_G_NAME);
		sts = om$send ( msg = message ACrg_collect.GRchgname
					( &ret, &md_env, newname),
				senderid = NULL_OBJID,
				targetid = globals.objid,
				targetos = globals.osnum );
		as$status ( sts    = sts,
                    	    msg    = "ACrg_collect.GRchgname",
                    	    test   = (!(sts & 0x00000001 & ret)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

	/*c Fill MAN & LOFT class names */
	strcpy (&old[ 0*20],"MANtplMgr");   strcpy (&new[ 0*20],"VLtplMgr");
	strcpy (&old[ 1*20],"MANtplObj");   strcpy (&new[ 1*20],"VLtplObj");
	strcpy (&old[ 2*20],"MANbalance");  strcpy (&new[ 2*20],"VLbalance");
	strcpy (&old[ 3*20],"MANlayout");   strcpy (&new[ 3*20],"VLlayout");
	strcpy (&old[ 4*20],"MANpinjig");   strcpy (&new[ 4*20],"VLpinjig");
	strcpy (&old[ 5*20],"MANjigTbl");   strcpy (&new[ 5*20],"VLjigTbl");
	strcpy (&old[ 6*20],"MANpltJig");   strcpy (&new[ 6*20],"VLpltJig");
	strcpy (&old[ 7*20],"MANstfnrTpl"); strcpy (&new[ 7*20],"VLstfnrTpl");
	strcpy (&old[ 8*20],"MANgenLine");  strcpy (&new[ 8*20],"VLgenLine");
	strcpy (&old[ 9*20],"MANbutt");     strcpy (&new[ 9*20],"VLbutLine");
	strcpy (&old[10*20],"MANcntrL");    strcpy (&new[10*20],"VLctrLine");
	strcpy (&old[11*20],"MANseam");     strcpy (&new[11*20],"VLseaLine");
	strcpy (&old[12*20],"MANvirButt");  strcpy (&new[12*20],"VLvirButt");
	strcpy (&old[13*20],"MANwatLine");  strcpy (&new[13*20],"VLwatLine");
	strcpy (&old[14*20],"MANMark");     strcpy (&new[14*20],"VLmrkLine");
	strcpy (&old[15*20],"MANRolLn");    strcpy (&new[15*20],"VLrolLine");
	for ( i=0; i<16; i++)	chg[i] = 0;
#ifdef TRACE
printf( "\n\t\tList of classes \n");
for ( i=0; i<16; i++)
printf( "\tClass %2d : <%s>   \t-->\t<%s>\n", i, &old[i*20], &new[i*20]);
#endif

	/*c Loop on object space's objects */
	max = OM_GA_OSDs[md_env.md_id.osnum]->CurSpaceMapSize;
        for ( i=0; i<max; i++) {

                /* Get valid object only */
                sts = om$is_objid_valid (osnum = md_env.md_id.osnum,
                                         objid = i);
                if (!(sts & 1)) { sts = OM_S_SUCCESS;	continue; }

                /* Get valid object class ID */
                sts = om$get_classname (osnum     = md_env.md_id.osnum,
                                        objid     = i,
                                        classname = nam);
                if (!(sts & 1)) { sts = OM_S_SUCCESS;	continue; }

		/* Change MAN class into LOFT class */
		for ( j=0; j<16; j++) {
			if (!strcmp ( nam, &old[j*20])) {
				sts = om$change_class(osnum= md_env.md_id.osnum,
					       	      objid= i,
					       	      classname= &new[j*20]);
				if (sts & 1) {
					(chg[j])++;
#ifdef TRACE
printf( "Object (%d|%d)\tchange from class <%s>\tto class<%s>\n",
	md_env.md_id.osnum, i, &old[j*20], &new[j*20] );
#endif
				}
				j = 16;
			}
		}
        }

	/*c Result on conversion */
	printf( "\n");
	for ( i=0; i<16; i++) {
		if (chg[i])
printf( "I/LOFT : %5d objects of class <%s>  \tconvert to class <%s>\n", 
	chg[i], &old[20*i], &new[20*i] );
	}
	
wrapup:
	return (sts);
}

end implementation Root;
