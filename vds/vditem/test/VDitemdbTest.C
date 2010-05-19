 /* $Id: VDitemdbTest.C,v 1.1 2001/01/10 18:04:42 art Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1TestPlot.I
 *
 * Description: Unit Plot Tree Testing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDitemdbTest.C,v $
 *      Revision 1.1  2001/01/10 18:04:42  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  19:26:00  pinnacle
 * Created: vds/vditem/test/VDitemdbTest.C by jdsauby for Service Pack
 *
 * Revision 1.1  2000/08/15  18:27:10  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/24  21:12:30  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/
#include "VDItemDB.h" 
#include "VDobj.h"

#include "VDassert.h"

VDASSERT_FFN("vdutil/test/VDitemdbJeffTest.C");

extern IGRstat VDitemdbGetMatIDForObject();
extern IGRstat VDitemdbGetItemDBCollector();
extern IGRstat VDgetItemDbParameters();
extern IGRstat VDitemdbGetItemDBCollectorAttributes(); 


static IGRstat VDitemJeffTestGetAttributes()
{
    VDASSERT_FN("VDitemJeffTestGetAttributes");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;
    TVDitemdbCollAttrs   list;
    IGRchar              keyValue[128];
    TGRid                objid;

    // say hi
    printf(">>> VDitemJeffTestGetAttributes\n");

    objid.osnum = 2;
    for (i = 0; i < 100; i++) { 
	//object 1
	vd$item_init( list = &list );
	keyValue[0]  = '\0';
	objid.objid = 487;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );

	sts = VDitemdbGetItemDBCollectorAttributes( keyValue, &list ); 
	VDASSERTW( (sts & 1) && (list.cnt != 0) );
	vd$item_free( list = &list );
	//object 2

	vd$item_init( list = &list );
	keyValue[0]  = '\0';
	objid.objid = 1247;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );

	sts = VDitemdbGetItemDBCollectorAttributes( keyValue, &list ); 
	VDASSERTW( (sts & 1) && (list.cnt != 0) );
	vd$item_free( list = &list );

	//object 3
	vd$item_init( list = &list );
	keyValue[0]  = '\0';
	objid.objid = 387;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );

	sts = VDitemdbGetItemDBCollectorAttributes( keyValue, &list ); 
	VDASSERTW( (sts & 1) && (list.cnt != 0) );
	vd$item_free( list = &list );

	//object 4
	vd$item_init( list = &list );
	keyValue[0]  = '\0';
	objid.objid = 1004;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );

	sts = VDitemdbGetItemDBCollectorAttributes( keyValue, &list ); 
	VDASSERTW( (sts & 1) && (list.cnt != 0) );
	vd$item_free( list = &list );

    }

    // done
    retFlag = 1;
    
wrapup:
    vd$item_free( list = &list );

    // say bye
    printf("<<< VDitemJeffTestGetAttributes\n");
    return retFlag;
}
static IGRstat VDitemJeffTestGetParams()
{

    VDASSERT_FN("VDitemJeffTestGetParams");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRlong 		status;
    TGRid   		objid;
    struct GRmd_env 	md_env;
    IGRint  		i,count;
    struct ACrg_coll 	*plist;

    // say hi
    printf(">>> VDitemJeffTestGetParams\n");

    objid.osnum = 2;
    //md_env.id.objid = NULL_OBJID;
    
    for (i = 0; i < 100; i++) {

	// object 1
	objid.objid = 487;
	count       = 0;
	sts = VDgetItemDbParameters(&status,&objid,&md_env,&count,NULL);
	VDASSERTW( (sts & 1) && (count != 0) );
	plist = malloc( count * sizeof(struct ACrg_coll) );
	sts = VDgetItemDbParameters(&status,&objid,&md_env,&count,&plist);
        if (plist) free( plist );
	VDASSERTW( (sts & 1) && (count != 0) );

	// object 2
	objid.objid = 1247;
	count       = 0;
	sts = VDgetItemDbParameters(&status,&objid,&md_env,&count,NULL);
	VDASSERTW( (sts & 1) && (count != 0) );
	plist = malloc( count * sizeof(struct ACrg_coll) );
	sts = VDgetItemDbParameters(&status,&objid,&md_env,&count,&plist);
        if (plist) free( plist );
	VDASSERTW( (sts & 1) && (count != 0) );


	// object 3
	objid.objid = 387;
	count       = 0;
	sts = VDgetItemDbParameters(&status,&objid,&md_env,&count,NULL);
	VDASSERTW( (sts & 1) && (count != 0) );
	plist = malloc( count * sizeof(struct ACrg_coll) );
	sts = VDgetItemDbParameters(&status,&objid,&md_env,&count,&plist);
        if (plist) free( plist );
	VDASSERTW( (sts & 1) && (count != 0) );


	// object 4
	objid.objid = 1004;
	count       = 0;
	sts = VDgetItemDbParameters(&status,&objid,&md_env,&count,NULL);
	VDASSERTW( (sts & 1) && (count != 0) );
	plist = malloc( count * sizeof(struct ACrg_coll) );
	sts = VDgetItemDbParameters(&status,&objid,&md_env,&count,&plist);
        if (plist) free( plist );
	VDASSERTW( (sts & 1) && (count != 0) );



    }

    // done
    retFlag = 1;

wrapup:
    if (plist) free( plist );
    // say bye
    printf("<<< VDitemJeffTestGetParams\n");


    return retFlag;
}





/* ---------------------------------------------
* Test getting and filling collector
**/
static IGRstat VDitemJeffTestCollector()
{
    VDASSERT_FN("VDitemJeffTestCollector");

    IGRstat retFlag = 0;
    IGRstat sts;

    TGRid   objid, collID;
    IGRint  i;
    IGRchar keyValue[128], path[DI_PATH_MAX];

    // say hi
    printf(">>> VDitemJeffTestCollector\n");

    // Test the keyValue calculation
    objid.osnum = 2;
    for (i = 0; i < 100; i++) {

	// object 1
	collID.objid = NULL_OBJID;
	keyValue[0]  = '\0';
	objid.objid = 487;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );
	sts = VDitemdbGetItemDBCollector( keyValue, path, &collID );
	VDASSERTW( (sts & 1) && (collID.objid != NULL) );

	// object 2
	collID.objid = NULL_OBJID;
	keyValue[0]  = '\0';
	objid.objid = 1247;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );
	sts = VDitemdbGetItemDBCollector( keyValue, path, &collID );
	VDASSERTW( (sts & 1) && (collID.objid != NULL) );

	// object 3
	collID.objid = NULL_OBJID;
	keyValue[0]  = '\0';
	objid.objid = 387;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );
	sts = VDitemdbGetItemDBCollector( keyValue, path, &collID );
	VDASSERTW( (sts & 1) && (collID.objid != NULL) );

	// object 4
	collID.objid = NULL_OBJID;
	keyValue[0]  = '\0';
	objid.objid = 1004;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );
	sts = VDitemdbGetItemDBCollector( keyValue, path, &collID );
	VDASSERTW( (sts & 1) && (collID.objid != NULL) );


    }

    // done
    retFlag = 1;

wrapup:
    // say bye
    printf("<<< VDitemJeffTestCollector\n");


    return retFlag;
}



/* ----------------------------------------------
 * test matid generation
 */

static IGRstat VDitemJeffTestMatID()
{
    VDASSERT_FN("VDitemJeffTestMatID");

    IGRstat retFlag = 0;
    IGRstat sts;

    TGRid   objid;
    IGRint  i,cur;
    IGRchar keyValue[128];

    // say hi
    printf(">>> VDitemJeffTestMatID\n");

    // Test the keyValue calculation
    objid.osnum = 2;
    for (i = 0; i < 100; i++) {
cur = i;
	objid.objid = 487;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );

	if ( cur == cur%10 ) printf ("### KeyValue <%s>\n",keyValue);

	objid.objid = 1247;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );

	if ( cur == cur%10 ) printf ("### KeyValue <%s>\n",keyValue);

	objid.objid = 387;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );

	if ( cur == cur%10 ) printf ("[%d] ### KeyValue <%s>\n",cur,keyValue);

	objid.objid = 1004;
	sts = VDitemdbGetMatIDForObject( &objid, keyValue );
	VDASSERTW( (sts & 1) && (keyValue[0] != '\0') );

	if ( cur == cur%10 ) printf ("### KeyValue <%s>\n",keyValue);

    }

    // done
    retFlag = 1;

wrapup:
    // say bye
    printf("<<< VDitemJeffTestMatID\n");


    return retFlag;
}

/* -----------------------------------------------
 * Main Traffic director
 */
IGRstat VDitemdbTest()
{
    VDASSERT_FN("VDitemdbTest");

    IGRstat retFlag = 0;
    IGRstat sts;



    // Say Hi
    printf("-------------- Itemdb Testing Begins  ---------------\n");

    //sts = VDitemJeffTestMatID();
    //VDASSERTW(sts & 1);

    //sts = VDitemJeffTestCollector();
    //VDASSERTW(sts & 1);
    sts = VDitemJeffTestGetAttributes();
    VDASSERTW(sts & 1);
    
    //sts = VDitemJeffTestGetParams();
    //VDASSERTW(sts & 1);

    // Done
    retFlag = 1;

wrapup:
    printf("-------------- Itemdb Testing Ends  %d ---------------\n",retFlag);
    return retFlag;
}

