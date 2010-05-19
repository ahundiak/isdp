/* $Id: VDpostProd.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdcheckin/imp/VDpostProd.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpostProd.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/11  14:07:48  pinnacle
# Staging tree
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/03/02  18:40:06  pinnacle
# AssyTree
#
# Revision 1.7  1998/02/26  14:06:20  pinnacle
# AssyTree
#
# Revision 1.6  1998/01/07  18:43:24  pinnacle
# VDatGetSetMgr
#
# Revision 1.5  1998/01/07  15:50:58  pinnacle
# Replaced: vdcheckin/imp/VDpostProd.I for:  by yzhu for vds
#
# Revision 1.3  1997/12/30  21:25:38  pinnacle
# Replaced: vdcheckin/imp/VDpostProd.I for:  by yzhu for vds
#
# Revision 1.2  1997/12/29  18:38:36  pinnacle
# Replaced: vdcheckin/imp/VDpostProd.I for:  by yzhu for vds
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/24/97  yzhu    Creation Date.
 * 01/07/98  ah	     VDatGetSetMgr changed
 * 02/26/98  ah      Removed VDatMAC.h
 * 10/11/98  ah      Added VDatMaster.h, really need to delete all
 *                   Staging tree stuff from here
 * -------------------------------------------------------------------*/

class implementation ACdb_info ;

#include        <stdio.h>

#include        "ex.h"

#include        "exdef.h"
#include        "exmacros.h"

#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"

#include        "msdef.h"
#include        "msmacros.h"

#include        "ACdb_info.h"

#include        "AS_status.h"
#include        "parametric.h"
#include        "expression.h"
#include        "expmacros.h"

#include        "madef.h"

#include        "ACcheckin.h"
#include        "VDmem.h"
#include        "VDScheckdef.h"

#include        "PDUerror.h"
#include        "PDMexec.h"
#include        "PDUuser.h"
#include        "PDUcommand.h"
#include        "PDMfile_mac.h"

#include        "VDScheckin.h"
#include        "VDSris_def.h"
#include        "VDSris_siz.h"
#include        "VDDbtbldef.h"
#include        "vdbmacros.h"
#include        "v_risproto.h"
#include        "v_miscmacros.h"
#include        "v_dbgmacros.h"
#include        "v_datamacros.h"
#include        "coparamac.h"

#include "VDmaster.h"
#include "VDatMaster.h"

#include        "vdparmacros.h"
#include 	"v_slcdef.h"
// #include 	"v_pplslc.h"
#include 	"vdprocinfo.h"
#include 	"VDBload.h"

#include        "VDPdef.h"

from ACcpx      import find_macro, ACgive_structure;

/******************************************************************************/


extern  struct  PDUuser         *user;
extern  int     VD_PDU_present;
/******************************************************************************/

extern  GRclassid     OPP_ACdb_info_class_id;
extern  GRclassid     OPP_VDSroot_class_id;

IGRlong VdsTreeFillRow( row, flds, fldCnt, serial_no,
 	current_cat, current_nam, current_rev,tbl_type, p_file )

char                    *row;
int                     serial_no;
TVDatFld        	*flds;
IGRint          	fldCnt;
char                    *current_cat;
char                    *current_nam;
char                    *current_rev;
int                     tbl_type;
FILE                    *p_file;
{
        int             ind_row_table;
        char            modelSerialStr[MAXWORD];
        char            leafSerialStr[MAXWORD];
        char            foot_char[MAX_ROW_CHAR];
        int             j, sts;
	int		flag_type;
   	int             first_attr=0;
   	struct GRid     leaf, model;
   	struct GRobj_env     objenv;
        char            ref_cat[VDB_MAX_CATALOG_LEN];
        char            ref_nam[VDB_MAX_CATALOG_LEN];
        char            ref_rev[VDB_MAX_CATALOG_LEN];


        SetProc( VdsTreeFillRow ); Begin 
        ref_cat[0] = '\0';
        ref_nam[0] = '\0';
        ref_rev[0] = '\0';


        ind_row_table  = 0;

        if( tbl_type == VDATSTAGE ) 
        	first_attr      = VDDYSTART;
	else
        	first_attr      = VDATSTART;

        __DBGpr_int("first_attr", first_attr);
        __DBGpr_int("tbl_type", tbl_type);

        /*Fill the common values */
        sprintf( leafSerialStr, "%d", serial_no ) ;

        leaf.objid = serial_no;
        leaf.osnum = 2;

        __DBGpr_obj("leaf ", leaf);

        /* get model object of leaf */
        sts = VDatGetLeafObject(&leaf, &objenv);

        sprintf( leafSerialStr, "%d", serial_no ) ;
        sprintf( modelSerialStr, "%d", objenv.obj_id.objid ) ;

        model.objid = objenv.obj_id.objid;
        model.osnum = objenv.obj_id.osnum;
        __DBGpr_obj("model object", model);

        /* get Catalog, PartId, and revision from reference file */
        sts = VD_expOsnumPDMId(&model,ref_cat,ref_nam, ref_rev); 
        __DBGpr_str("ref_cat", ref_cat);
        __DBGpr_str("ref_nam", ref_nam);
        __DBGpr_str("ref_rev", ref_rev);

        /*Now amended to process */

        fill_row( row, &ind_row_table, modelSerialStr);
        fill_row( row, &ind_row_table, ref_cat);
        fill_row( row, &ind_row_table, ref_nam);
        fill_row( row, &ind_row_table, ref_rev);

        if( tbl_type == VDATPIECE ) {
        	fill_row( row, &ind_row_table, leafSerialStr);
        	fill_row( row, &ind_row_table, current_cat);
        	fill_row( row, &ind_row_table, current_nam);
        	fill_row( row, &ind_row_table, current_rev);
	}

        /*| Ask for the feet values */

        for( j = first_attr; j < fldCnt ; j++ ) {
           
           // __DBGpr_str( "attr_name", flds[j].name);
 
           flag_type = 1;

           switch( flds[j].type ) {
		case VDAT_FLD_TYPE_CHAR:
                        strcpy( foot_char, flds[j].valueTxt ) ;
                        break;
		case VDAT_FLD_TYPE_DOUBLE:
		case VDAT_FLD_TYPE_NUMERIC:
                        sprintf( foot_char, "%f", flds[j].valueDbl ) ;
                        break;
		case VDAT_FLD_TYPE_INT:
		case VDAT_FLD_TYPE_SMALLINT:
                        sprintf( foot_char, "%d", flds[j].valueInt ) ;
                        break;
                default:
                    fprintf( p_file, 
		    "Error, no type <%d> is defined\n", flds[j].type );
                    fflush( p_file ) ;

                    flag_type = 0;
                    break;
           } 

           __DBGpr_str( "foot_char", foot_char);
           if(  flag_type )
              fill_row( row, &ind_row_table, foot_char);

        } /* end for(j=first_attr;j<dyntbl_attr.nb_feet;j++)    */

        strcpy( &row[ind_row_table], SEP_STRING);
        ind_row_table++;

//wrapup:
        End
        return SUCCESS;

} /* VdsTreeFillRow */



/************************************************************/
#argsused
VDprd_postAssemblyTree(msg, key, to_sql, 
                       catalog, partid, revision, designRep, delete  )
long *msg;           /* O */
char *key;           /* I */
int  to_sql;         /* I */
char *catalog;       /* I */
char *partid;        /* I */
char *revision;      /* I */
char *designRep;     /* I */
int  *delete;        /* I/O */
{
long    	sts;
TVDvlaID  	setVLA;
TVDvlaID 	leafVLA;
TVDvlaID 	nodeVLA;

struct GRid 		mgrID;
struct GRid 		setID;
struct GRid 		leafID;
struct GRid 		nodeID;
struct GRid 		postID;

IGRint 		setI, nodeI, leafI;

IGRchar 	tableName[128];

TVDatFld 	flds[VDAT_FLD_MAX];
IGRint   	fldCnt = 0, nb_attr= 0;
IGRint   	serial_no = 0, attI, j, jj;
FILE 		*p_file = NULL, *sql_file = NULL;
IGRchar 	**dataType = NULL;
char 		row[MAX_ROW_CHAR];
char            logfile[50];
char            temp[20];

        SetProc( VDprd_postAssemblyTree ); Begin

        sts = MSSUCC;
        *msg = MSSUCC;

  	__DBGpr_com ("VDSverify_login");
  	if( VDSverify_login() != PDM_S_SUCCESS )
  	{
    	   UI_status( "User not logged in to Database" );
    	   sts = MSFAIL;
    	   goto wrapup;
        }
       
        /* get set manager */
        vdat$GetSetMgr(mgrID = &mgrID);
        if (mgrID.objid == NULL_OBJID) {
    	   UI_status( "Could not find manager" );
    	   __DBGpr_com("Could not find manager");
    	   sts = MSFAIL;
    	   goto wrapup;
        }
        __DBGpr_obj( "Mgr Id", mgrID);


  	p_file = (FILE *)fopen( logfile, "w+" );
  	if( p_file == NULL )
  	{
  	  p_file = (FILE *)stdout;
  	}

  	sql_file = (FILE *)fopen( "post.sql", "w" );

  	if( sql_file == NULL )
   	   printf( "Cannot open file <%s>.\n", "post.sql" );


        // Get list of sets
        VDatGetSetsVLA(&mgrID,&setVLA);
      
        // For each set
        for(setI = 0; VDvlaID_GetAt(&setVLA,&setID,setI); setI++) {
           __DBGpr_obj( "Set Id", setID);

           // Get list of leafs
           VDvlaID_Empty(&leafVLA);
           VDatGetLeafsVLA(&setID,&leafVLA);

           // For each leaf
           for(leafI = 0; VDvlaID_GetAt(&leafVLA,&leafID,leafI); leafI++) {
             __DBGpr_obj( "leaf object Id", leafID);

             // Get leaf post table for set
             VDatRDBGetPost(&leafID,&postID);
             __DBGpr_obj( "Leaf post table Id", postID);

             // Name of table
             VDatRDBGetTableName(&postID,tableName);
             __DBGpr_str( "leaf post table name", tableName);


             // Get All Attributes
             VDatFldGetAllAttrs(&leafID,flds,&fldCnt);
             __DBGpr_int ("fldCnt", fldCnt);

             for( j = 0; j< fldCnt; j++ ) {
                __DBGpr_str( "attr_name", flds[j].name);

                switch( flds[j].type ) {
                  case VDAT_FLD_TYPE_CHAR:
                        __DBGpr_str( "Text", flds[j].valueTxt ) ;
                        break;
                  case VDAT_FLD_TYPE_DOUBLE:
                  case VDAT_FLD_TYPE_NUMERIC:
                        __DBGpr_dbl( "Text",flds[j].valueDbl ) ;
                        break;
                  case VDAT_FLD_TYPE_INT:
                  case VDAT_FLD_TYPE_SMALLINT:
                        __DBGpr_dbl( "Text",flds[j].valueInt ) ;
                        break;
                }
 	     }
             // Get serial_no
             serial_no = leafID.objid;
             __DBGpr_int ("serial_no", serial_no);

             // make row
             __DBGpr_com("VdsTreeFillRow");
             sts = VdsTreeFillRow( row, flds, fldCnt, 
                   serial_no, catalog, partid, revision, VDATPIECE, p_file );
           
             __DBGpr_str("row", row);
  
             // Get nb_attr and dataType
             nb_attr = fldCnt; 
             dataType = NULL;
             dataType = _MALLOC ( nb_attr, char*);
             if ( dataType == NULL ){
    	   	UI_status( "Can not allocate memory for dataType" );
    	   	sts = MSFAIL;
    	   	goto wrapup;
             } 
             __DBGpr_com("before attI loop");
             for ( attI = 0; attI < nb_attr; attI++ ) {
                dataType[attI] = _MALLOC ( MAXWORD, char);
                if ( dataType[attI] == NULL ){
    	   	   UI_status( "Can not allocate memory for dataType[i]" );
    	   	   sts = MSFAIL;
    	   	   goto wrapup;
                }
 
                sprintf( temp, "%d", flds[attI].type ) ;
                strcpy( dataType[attI], temp ) ;

                __DBGpr_str( "dataType[attI]", dataType[attI]);
             
             }
             if( tableName[0] != '\0' ) {
                __DBGpr_com("VdsPostDb");
                __DBGpr_int("to_sql", to_sql);
                sts 
		= VdsPostDb( key, catalog, partid, revision, tableName,
                     nb_attr, dataType, row, delete, to_sql, sql_file );

                if( sts != SUCCESS ) {
                   fprintf( p_file, 
			"Error, cannot fill the database table: %s%s\n",
              		tableName, key );
                   fflush( p_file ) ;
                }
             }
        
             /* free */ 
             if( dataType != NULL ) {
          	for( jj = 0; jj < nb_attr; ++jj ) {
            		if( dataType[jj] != NULL )
                   	   _FREE( dataType[jj] );
                }

                _FREE( dataType);
             }

    	   } /* for leafI */

           // Get list of nodes

           VDvlaID_Empty(&nodeVLA);
           VDatGetNodesVLA(&setID,&nodeVLA);

           // For each node
           for(nodeI = 0; VDvlaID_GetAt(&nodeVLA,&nodeID,nodeI); nodeI++) {
             __DBGpr_obj( "Node  Id", nodeID);
             // Get leaf post table for set
             VDatRDBGetPost(&nodeID,&postID);
             __DBGpr_obj( "Node post table Id", postID);

             // Name of table
             VDatRDBGetTableName(&postID,tableName);
             __DBGpr_str( "Node post table name", tableName);

             // Get All Attributes
             VDatFldGetAllAttrs(&nodeID,flds,&fldCnt);
             __DBGpr_int ("fldCnt", fldCnt);

             // Get serial_no
             serial_no = nodeID.objid;
             __DBGpr_int ("serial_no", serial_no);

             // make row
             __DBGpr_com("VdsTreeFillRow");
             sts = VdsTreeFillRow( row, flds, fldCnt,
                   serial_no, catalog, partid, revision, VDATSTAGE, p_file );

             __DBGpr_str("row", row);
             // Get nb_attr and dataType
             nb_attr = fldCnt;
             dataType = NULL;
             dataType = _MALLOC ( nb_attr, char*);
             if ( dataType == NULL ){
                UI_status( "Can not allocate memory for dataType" );
                sts = MSFAIL;
                goto wrapup;
             }
             __DBGpr_com("before attI loop");
             for ( attI = 0; attI < nb_attr; attI++ ) {
                dataType[attI] = _MALLOC ( MAXWORD, char);
                if ( dataType[attI] == NULL ){
                   UI_status( "Can not allocate memory for dataType[i]" );
                   sts = MSFAIL;
                   goto wrapup;
                }

                sprintf( temp, "%d", flds[attI].type ) ;
                strcpy( dataType[attI], temp ) ;

                __DBGpr_str( "dataType[attI]", dataType[attI]);
             }
             if( tableName[0] != '\0' ) {
                __DBGpr_com("VdsPostDb");
                __DBGpr_int("to_sql", to_sql);
                sts
                = VdsPostDb( key, catalog, partid, revision, tableName,
                     nb_attr, dataType, row, delete, to_sql, sql_file );

                if( sts != SUCCESS ) {
                   fprintf( p_file,
                        "Error, cannot fill the database table: %s%s\n",
                        tableName, key );
                   fflush( p_file ) ;
                }
             }

             /* free */
             if( dataType != NULL ) {
                for( jj = 0; jj < nb_attr; ++jj ) {
                        if( dataType[jj] != NULL )
                           _FREE( dataType[jj] );
                }
                _FREE( dataType);
             }

           } /* for nodeI */

        } /* for SetI */

wrapup:
  	VDvlaID_Delete(&setVLA);
  	VDvlaID_Delete(&leafVLA);
  	VDvlaID_Delete(&nodeVLA);

        if( dataType != NULL ) {
          for( jj = 0; jj < nb_attr; ++jj ) {
            if( dataType[jj] != NULL )
                   _FREE( dataType[jj] );
          }
        	_FREE( dataType);
        }

        End
        return sts;
}

/************************************************************/

VDprd_postObjects(msg, key, to_sql, 
                  catalog, partid, revision, designRep, delete  )
long *msg;           /* O */
char *key;           /* I */
int  to_sql;         /* I */
char *catalog;       /* I */
char *partid;        /* I */
char *revision;      /* I */
char *designRep;     /* I */
int  *delete;        /* I/O */
{ 

long 	status;

        SetProc( VDprd_postObjects ); Begin

        status = SUCCESS; 

        __DBGpr_str ( "catalog",  catalog); 
        __DBGpr_str ( "partid",   partid); 
        __DBGpr_str ( "revision", revision); 

        /* this is used to post assembly tree */      
	status = 
        VDprd_postAssemblyTree(msg, key, to_sql,
                       catalog, partid, revision, designRep, delete  );


        /** In the future, we can changet to other function **/

        End
        return status;
}

end implementation ACdb_info ;

