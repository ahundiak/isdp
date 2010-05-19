/* $Id: VDpdmReplPrt.I,v 1.6 2002/05/10 19:33:50 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdm.I
 *
 * Description:	Some pdm routines
 *
 * Dependencies:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/30/01  js      Creation
 * 05/09/02  ah      Tyecast to remove warning
 ***************************************************************************/
class implementation Root;


#include "VDtypedef.h"
#include "VDobj.h"
#include "VDexp.h"
#include "VDdir.h"
#include "VDos.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "PDUuser.h"
#include "VDdbgAssert.h"
#include "VDassert.h"

#include "part.h"          /* Needed to Update GRpart object */
#include "partdef.h"
#include "partmacros.h"

#include "DIdef.h"        /* Needed to get object of reference file CS */
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "grmacros.h"     /* Needed to rename CS */
#include "expmacros.h"

VDASSERT_FFN("vdpdm/func/VDpdmReplPrt.I");

from GRpart import GRchg_part,GRmod_attribute;

extern struct PDUuser   *user;

#if 0
struct PDUuser
	{
	char		*username;
        char            *environment;
        char            *server;
        char            *passwd;
        long		user_id;
        int             storage_no;
        char            *storage_name;
 
        char		*wrkst_username;
        char		*wrkst_passwd;
        char		*wrkst_cwd;
        char		*wrkst_node;

	};
#endif

/* ---------------------------------------------
 * check if one view is available in list of views
 * **/
static IGRstat isViewAvailable(IGRchar *view,
	                       TVDrisInfo *ris)
{
    VDASSERT_FN("isViewAvailable");
    IGRstat retFlag = 0;
    IGRint  i;

    VDASSERTW(*view != 0);
    VDASSERTW(ris->rows > 0);


    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);
    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,view);

    for (i = 0; i < ris->rows; i++) {

	if (traceFlag) printf("## compared view %s\n",ris->buf[i]);
	if (!strcmp(view,ris->buf[i])) {
	    retFlag = 1;
	    goto wrapup;
	}

    }

    // done, view is not available
wrapup:
    if (traceFlag) printf(">>> %s %s <%d>\n",ffn(),fn,retFlag);
    return retFlag;
}

/*-----------------------------------------------
 * Check to see if new revision has at least the same views
 * as the old revision
 * **/
IGRstat VDpdmIsViewsAvailable(IGRchar *catalog,
                              IGRint  *itno_old,
			      IGRint  *itno_new)
{
    VDASSERT_FN("VDpdmIsViewsAvailable");
    IGRstat retFlag = 0;
    IGRint  i;

    TVDrisInfo  ris_old,ris_new;

    // Init, arg check
    VDrisInitInfo( &ris_old );
    VDrisInitInfo( &ris_new );
    VDASSERTW(*catalog != 0);
    VDASSERTW(*itno_old > 0);
    VDASSERTW(*itno_new > 0);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the views for the old rev
    // build the sql
    sprintf(ris_old.sql,
	    "Select p_viewname from v_%s where %s=%d;",
	    catalog, "n_itemno", *itno_old);

    if (traceFlag) printf("### SQL_old: <%s>\n",ris_old.sql);

    // query it
    VDrisQuery( &ris_old, NULL );
    if (ris_old.rows < 1) goto wrapup;

    // get the views for the new rev
    // build the sql
    sprintf(ris_new.sql,
	    "Select p_viewname from v_%s where %s=%d;",
	    catalog, "n_itemno", *itno_new);

    if (traceFlag) printf("### SQL_new: <%s>\n",ris_new.sql);

    // query it
    VDrisQuery( &ris_new, NULL );
    if (ris_new.rows < 1) goto wrapup;

    // compare to assure that the new has at least the same
    for (i = 0; i < ris_old.rows; i++) {
	if (!isViewAvailable(ris_old.buf[i],&ris_new)) {
	    goto wrapup;
	}
    }
    
    // done, all views are available
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    VDrisFreeInfo( &ris_old );
    VDrisFreeInfo( &ris_new );
    return retFlag;
}

// get the part description
IGRstat VDpdmGetPartDescription(IGRchar *catalog,
                                IGRint   itemno,
				IGRchar *descr)
{
    VDASSERT_FN("VDpdmGetPartDescription");
    IGRstat retFlag = 0;

    TVDrisInfo  ris;

    // Arg check / init
    VDrisInitInfo( &ris );

    VDASSERTW(*catalog);
    VDASSERTW(itemno > 0);
    VDASSERTW(descr);

    // the sql
    sprintf(ris.sql,
	    "Select n_itemdesc from %s where n_itemno=%d;",
	    catalog,itemno);

    // the query
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // set it
    strcpy(descr,ris.buf[0]);

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}

// get the catalog no
IGRstat VDpdmGetCatalogNo(IGRchar *catalog,
                          IGRint  *catno)
{
    VDASSERT_FN("VDpdmGetCatalogNo");
    IGRstat retFlag = 0;
    IGRstat sts;

    TVDrisInfo  ris;
    
    // Arg check / init
    VDrisInitInfo( &ris );
    VDASSERTW((catalog) && (*catalog));
    VDASSERTW(catno);

    // the sql
    sprintf(ris.sql,
	    "Select n_catalogno from nfmcatalogs where n_catalogname='%s';",
	    catalog);

    // query
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    *catno = atoi(ris.buf[0]);
    VDASSERTW(*catno > 0);

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}
    
// get the item no from the catalog
IGRstat VDpdmGetItemNo(TVDpdmInfo *info,
                       IGRint     *itemno)
{
    VDASSERT_FN("VDpdmGetItemNo");
    IGRstat retFlag = 0;

    TVDrisInfo  ris;
    
    // Arg check / init
    VDrisInitInfo( &ris );
    VDASSERTW(*info->catalog != 0);
    VDASSERTW(*info->part    != 0);
    VDASSERTW(itemno);

    // the sql
    sprintf(ris.sql,
	    "Select n_itemno from %s where %s='%s' and %s='%s';",
	    info->catalog, "n_itemname", info->part,
	    "n_itemrev", info->rev);

    // query
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    *itemno = atoi(ris.buf[0]);
    VDASSERTW(*itemno > 0);

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}

/* --------------------------------------------------------------
 * Check to see if the part is even checked out
 * **/
static IGRstat isPartCheckedOut(IGRchar *catalog,
                                IGRint  itemno)
{
    VDASSERT_FN("isPartCheckedOut");
    IGRstat retFlag = 0;

    TVDrisInfo  ris;

    // Arg Check / init
    VDrisInitInfo( &ris );

    VDASSERTW(*catalog != 0);
    VDASSERTW(itemno > 0);

    // the sql
    sprintf(ris.sql,
	    "Select n_status from %s where n_itemno=%d;",
	    catalog, itemno);

    // the query
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // if status = 'I' then this part is not checked out.
    if (!strcmp(ris.buf[0],"I")) goto wrapup;

    // done, part is checked out
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    return retFlag;
}

/* --------------------------------------------
 * Get the storagearea number for the checked out file
 * **/
static void getCOSANO(IGRint  catno,
                      IGRint  itemno,
		      IGRint *co_sano)
{
    VDASSERT_FN("getCOSANO");

    TVDrisInfo  ris;

    // Arg Check / init
    VDrisInitInfo( &ris );

    VDASSERTW(catno  > 0);
    VDASSERTW(itemno > 0);
    VDASSERTW(co_sano);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);
    if (traceFlag) printf(">>> %s %s <cat %d item %d>\n",ffn(),fn,catno,itemno);
    // the sql
    sprintf(ris.sql,
	    "Select n_sano from nfmsafiles where n_catalogno=%d and n_itemno=%d" 
	    " and n_co='Y';",
	    catno, itemno);

    if (traceFlag) printf("### SQL <<<%s>>>\n",ris.sql);
    // the query
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // set it
    *co_sano = atoi(ris.buf[0]);

    // done
wrapup:
    if (traceFlag) printf("<<< %s %s <%d>\n",ffn(),fn,*co_sano);
    VDrisFreeInfo( &ris );
    return;
}

/* ---------------------------------------------
 * Get a list of possible storage area numbers based
 * on this workstation user and path
 * **/
static void getSANOlist(TVDrisInfo *ris)
{
    VDASSERT_FN("getSANOlist");

    IGRchar sql[1024];
    
    VDASSERTW(ris);
    VDASSERTW(user);


    // the sql
    sprintf(sql,
	    "Select n_sano from nfmstoragearea where n_username='%s' "
	    "and n_pathname='%s';",
	    user->wrkst_username, user->wrkst_cwd);

    // the query
    VDrisQuery( ris, sql );

    // done
wrapup:
    return;
}
    
/* --------------------------------------------------------------
 * Check if current file is checked out.
 * **/
IGRstat VDpdmIsPartCheckedOut(TVDpdmInfo  *info,
                              IGRint      catno,
			      IGRint      itemno)
{
    VDASSERT_FN("VDpdmIsPartCheckedOut");
    
    IGRstat retFlag = 0;
    IGRstat sts;
    
    TVDrisInfo  ris;
    IGRchar     sql[1024];
    IGRint      sano, co_sano, i;
    
    // Arg check
    VDrisInitInfo( &ris );
    sano                     = 0;
    co_sano                  = 0;

    VDASSERTW(*info->catalog != 0);
    VDASSERTW(catno           > 0);
    VDASSERTW(itemno          > 0);
    VDASSERTW(user);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // verify logged in
    sts = VDpdmVerifyLogin();
    if (!(sts & 1)) goto wrapup;

    /* ----------------------------------------
     * Since the PDUuser structure does not appear to be
     * populated correctly, we need to do this the hard way.
     * **/
    // Check to see if part has a checked out status
    if (traceFlag) printf("### Check for CO status\n");
    sts = isPartCheckedOut(info->catalog,itemno);
    if (!(sts & 1)) goto wrapup;

    // Part is checked out, is it checked out to this workstation and
    // user.
    // get a list of possible storage area numbers for this workstation user and
    // path.
    if (traceFlag) printf("### get list of possible storage areas\n");
    getSANOlist(&ris);
    if (ris.rows < 1) goto wrapup;

    // get the SANO that this part is checked out to
    if (traceFlag) printf("### get the CO storage area\n");
    getCOSANO(catno,itemno,&co_sano);
    if (co_sano < 1) goto wrapup;

    // compare the list of SANOs to the co_sano
    if (traceFlag) printf("### compare storage areas\n");
    for (i = 0; i < ris.rows; i++) {
	sano = atoi(ris.buf[i]);
	if (traceFlag) printf("### sano = %d, co_sano = %d\n",sano,co_sano);
	if ((sano - co_sano) == 0) {
	    retFlag = 1;
	    goto wrapup;
	}
    }


wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
#if 0
/* ----------------------------------------------
 * Check that all level 1 reference files are local
 * ***/
IGRstat VDpdmAreReferenceFileLocal()
{
    return 1;
}
#endif
/* ----------------------------------------------
 * Rename Coordinate system for reference file
 * **/
IGRstat VDpdmRenameRefFileCS(IGRchar  *old_name,
                             IGRchar  *new_name )
{
    VDASSERT_FN("VDpdmRenameRefFileCS");

    IGRstat retFlag = 0;
    IGRstat sts;

    VDASSERTW(*old_name);
    VDASSERTW(*new_name);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);
    if (traceFlag) printf(">>> %s %s <%s --> %s>\n",ffn(),fn,old_name,new_name);

    // rename it
    di$rename(oldname = old_name, newname = new_name);

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

	
/* ---------------------------------------------
 * Update GRpart REV
 * **/
IGRstat VDpdmUpdateGRpartRev(TGRid   *part_id,
			     IGRchar *new_rev)
{
    VDASSERT_FN("VDpdmUpdateGRpartRev");

    IGRstat retFlag = 0;
    IGRstat sts,msg,om_msg;

    IGRint type = GR_STATIC_ATTR;

    VDASSERTW(part_id->objid != NULL_OBJID);
    VDASSERTW(*new_rev);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);
    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,new_rev);

    // make sure it is a PDM part
    if (! PDMpart_check (part_id)) {
	printf("### Object is not a part Object\n");
	goto wrapup;
    }

    // change the revision
    if (traceFlag) printf("### change revision\n");
    sts = om$send ( msg = message GRpart.GRmod_attribute (
		&msg,
		REVISION_NAME,
		new_rev,
		&type ),
	    targetid = part_id->objid,
	    targetos = part_id->osnum,
	    senderid = NULL_OBJID );

    if (!(sts & msg & 1)) {
	printf("### Chg Part Revision not successful\n");
	goto wrapup;
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------------
 * Update GRpart Usage ID
 * **/
IGRstat VDpdmUpdateGRpartUID(TGRid   *part_id,
			     IGRchar *new_uid)
{
    VDASSERT_FN("VDpdmUpdateGRpartUID");

    IGRstat retFlag = 0;
    IGRstat sts,msg,om_msg;
    IGRchar usage_id[DI_PATH_MAX];

    IGRint type = GR_DYNAMIC_ATTR;

    VDASSERTW(part_id->objid != NULL_OBJID);
    VDASSERTW(*new_uid);

    // say hi
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);
    if (traceFlag) printf(">>> %s %s <%d:%s>\n",ffn(),fn,part_id->objid,new_uid);

    // make sure it is a PDM part
    if (! PDMpart_check (part_id)) {
	printf("### Object is not a part Object\n");
	goto wrapup;
    }

    // change the usage_id
    sprintf(usage_id,"\"%s\"",new_uid);
    sts = om$send ( msg = message GRpart.GRmod_attribute (
		&msg,
		"usage_id",
		usage_id,
		&type ),
	    targetid = part_id->objid,
	    targetos = part_id->osnum,
	    senderid = NULL_OBJID );

    if (!(sts & msg & 1)) {
	printf("### Chg Usage_id not successful\n");
	goto wrapup;
    }
    
    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ----------------------------------------------
 * Delete the PDM part out of the file
 * **/
IGRstat VDpdmDeletePdmPart(TGRid *part_id)
{
    VDASSERT_FN("VDpdmDeletePdmPart");

    IGRstat retFlag = 0;
    IGRlong msg, sts;

    VDASSERTW(part_id->objid != NULL_OBJID);

    sts = gr$delete_object(msg          = &msg,
		           object_id    = part_id,
			   display_flag = 0 );

    if (!(sts & msg & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

#if 0
/* -------------------------------------------
 * Update PDMCIT db table
 * **/
IGRstat VDpdmUpdatePDMCIT(IGRint  citno,
                          IGRchar *usageid,
			  IGRchar *itemrev)
{
    VDASSERT_FN("VDpdmUpdatePDMCIT");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[256];

    VDASSERTW(citno > 0);
    VDASSERTW(*usageid);
    VDASSERTW(*itemrev);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // build the sql
    sprintf(sql,
	    "Update PDMCIT set p_usageid='%s', n_itemrev='%s' where p_citno=%d;",
	    usageid, itemrev, citno);

    if (traceFlag) printf("### SQL <<<%s>>>\n",sql);

    sts = VDrisExecute( sql );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    

/* -------------------------------------------
 * Update NFMSETCIT db table
 * **/
IGRstat VDpdmUpdateNFMSETCIT(IGRint  citno,
                             IGRint  itemno)
{
    VDASSERT_FN("VDpdmUpdateNFMSETCIT");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[256];

    VDASSERTW(citno > 0);
    VDASSERTW(itemno > 0);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // build the sql
    sprintf(sql,
	    "Update NFMSETCIT set n_citemno=%d where n_citno=%d;",
	    itemno, citno);

    if (traceFlag) printf("### SQL <<<%s>>>\n",sql);
    
    sts = VDrisExecute( sql );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -------------------------------------------
 * Replace Part
 * **/
IGRstat VDpdmReplacePart(IGRint  *cur_key,
                         IGRint  *ref_key)
{
    return 1;
}

/* -------------------------------------------
 * Update NFMSAFILES to match new ref file configuration
 * **/
IGRstat VDpdmUpdateNFMSAFILES(IGRint sano,
                              IGRint catno,
			      IGRint itno_old,
			      IGRint itno_new)
{
    VDASSERT_FN("VDpdmUpdateNFMSAFILES");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[256];

    VDASSERTW(sano > 0);
    VDASSERTW(catno > 0);
    VDASSERTW(itno_old > 0);
    VDASSERTW(itno_new > 0);
    
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // build the sql
    sprintf(sql,
	    "Update NFMSAFILES set n_itemno=%d where "
	    "n_sano=%d and n_catalogno=%d and n_itemno=%d;",
	    itno_new, sano, catno, itno_old);
    
    if (traceFlag) printf("### SQL <<<%s>>>\n",sql);
    
    sts = VDrisExecute( sql );
    if (!(sts & 1)) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
#endif
/* -----------------------------------------------
 * get the check out filename
 * **/
static void getCOFileName(IGRchar *catalog,
                          IGRchar *part,
			  IGRchar *rev,
			  IGRchar *file)
{
    VDASSERT_FN("getCOFileName");

    IGRstat     sts;
    TVDrisInfo  ris;
    IGRchar     sql[1024];
    IGRint      itemno;
    TVDpdmInfo  info;

    // init
    VDrisInitInfo( &ris );

    // arg check
    VDASSERTW(*catalog != 0);
    VDASSERTW(*part    != 0);
    VDASSERTW(*rev     != 0);
    VDASSERTW(file); *file = 0;

    // build the query

    // To get itemno, only need catalog and part in info
    strcpy(info.catalog,catalog);
    strcpy(info.part,part);
    strcpy(info.rev,rev);
    sts = VDpdmGetItemNo(&info,&itemno);
    if (!(sts & 1)) goto wrapup;

    
    sprintf(sql,
	    "Select n_cofilename from f_%s where n_itemnum = %d and "
	    "n_fileversion = (Select max(n_fileversion) from f_%s where n_itemnum = %d);",
	    catalog, itemno, catalog, itemno );

    if (traceFlag) printf("### SQL: <<<%s>>>\n",sql);
    // query it
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    if (traceFlag) printf("### cofile <%s>\n",ris.buf[0]);

    // set it
    strcpy(file,ris.buf[0]);

    // done
wrapup:
    VDrisFreeInfo( &ris );
    return;
}

/*--------------------------------------------------
 * Verify that check file name of new rev equals the 
 * Check out filename of the old rev.
 * **/
IGRstat VDpdmIsCOFileNameEqual(IGRchar *catalog,
                               IGRchar *part,
			       IGRchar *rev_old,
			       IGRchar *rev_new)
{
    VDASSERT_FN("VDpdmIsCOFileNameEqual");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar cofile_old[80];
    IGRchar cofile_new[80];

    // init
    *cofile_old = 0;
    *cofile_new = 0;

    // Arg check
    VDASSERTW(*catalog != 0);
    VDASSERTW(*part    != 0);
    VDASSERTW(*rev_old != 0);
    VDASSERTW(*rev_new != 0);

    // say hi
    //traceFlag = 1;
    traceFlag = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the old cofile
    getCOFileName(catalog, part, rev_old, cofile_old);
    if (*cofile_old == 0) goto wrapup;
    if (traceFlag) printf("### old cofile <%s>\n",cofile_old);

    // get the new cofile
    getCOFileName(catalog, part, rev_new, cofile_new);
    if (*cofile_new == 0) goto wrapup;
    if (traceFlag) printf("### new cofile <%s>\n",cofile_new);

    // are they equal
    if (!strcmp(cofile_old,cofile_new)) retFlag = 1;

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ----------------------------------------------------------
 * Get a list of parts, and the object ids.
 * **/
IGRstat VDpdmGetPDMPartIDs(TGRid    *part_ids,
		           IGRint   *cnt)
{
    VDASSERT_FN("VDpdmGetPDMPartIDs");

    IGRstat retFlag = 0;
    IGRlong msg,status;
    IGRint  qty;
    IGRint  i,ptr;
    IGRchar pathname[DI_PATH_MAX];
    VDosnum cur_os = OM_K_NOT_AN_OS;
    TGRid   path_id;


    // arg check, init
    VDASSERTW(part_ids);
    VDASSERTW(cnt); *cnt = 0;
    *pathname = 0;

    // get the path to parts
    ex$get_cur_mod( osnum = &cur_os );
    if (cur_os == OM_K_NOT_AN_OS) goto wrapup;

    status = di$give_pathname(osnum    = cur_os,
	                      pathname = pathname);
    
    if ( status != DIR_S_SUCCESS )
    {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     goto wrapup;
    }

    strcat( pathname, ":parts:*:*:*" );

   
    // start the dump of this directory
    di$start_dump( regexp = pathname,
                   ptr    = &ptr );
    if (ptr < 1) goto wrapup;

    // fill the part_ids
    qty = 0;
    for ( i = 0; i < ptr; i++ ) {
	
	di$fetch_dump( p_grid = (struct digrid *)&path_id,
                       index  = i );

	// make sure it is a PDM part
	if ( PDMpart_check (&path_id) ) {
	    part_ids[qty] = path_id;
	    qty++;
	}
    }

    // done
    *cnt = qty;
    if (qty > 0) retFlag = 1;

wrapup:
    return retFlag;
}

    
/* ------------------------------------------------
 * Get attr value for part id
 * ***/
IGRstat VDpdmGetAttrForPartID(TGRid   *partID,
                              IGRchar *attr_name,
			      IGRchar *attr_value)
{
    VDASSERT_FN("VDpdmGetAttrForPartID");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRlong msg;

    // Arg Check / init
    VDASSERTW(partID->objid != NULL_OBJID);
    VDASSERTW(*attr_name != 0);
    VDASSERTW(attr_value); 
    *attr_value = 0;

    // get it
    sts = co$part_get_attr( msg   = &msg,
                            part  = partID,
	                    attr  = attr_name,
			    value = attr_value );
    if (!(sts & msg & 1)) goto wrapup;

    // done
    if (*attr_value != 0) retFlag = 1;

wrapup:
    return retFlag;
}

end implementation Root;






