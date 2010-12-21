/* $Id: VDScheckin.I,v 1.4 2001/04/24 20:34:10 jdsauby Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/imp / VDScheckin.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDScheckin.I,v $
 *	Revision 1.4  2001/04/24 20:34:10  jdsauby
 *	Added for post tabel timestamp, CR 4474 and for Post Macros CR 5083
 *	
 *	Revision 1.3  2001/03/22 16:51:52  anand
 *	VDPmeCheckin reduced to a stub - changed per request by Tawana and Jeff.
 *	
 *	Revision 1.2  2001/03/20 18:59:58  jdsauby
 *	Re-imported from service pack into CVS
 *	
# Revision 1.4  2000/11/02  20:33:48  pinnacle
# Replaced: vds/vdcheckin/imp/VDScheckin.I for:  by impd252 for Service Pack
#
# Revision 1.3  2000/09/21  17:08:32  pinnacle
# Replaced: vds/vdcheckin/imp/VDScheckin.I for:  by azuurhou for Service Pack
#
# Revision 1.2  2000/07/10  19:44:28  pinnacle
# Replaced: vds/vdcheckin/imp/VDScheckin.I for:  by apazhani for Service Pack
#
# Revision 1.13  2000/03/07  20:04:56  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by impd252 for vds
#
# Revision 1.12  1999/08/27  06:53:46  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by ssranade for vds
#
# Revision 1.11  1999/02/08  19:09:14  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by lawaddel for vds
#
# Revision 1.10  1999/01/28  20:21:38  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by lawaddel for vds
#
# Revision 1.9  1998/11/25  05:13:30  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for: CR # 179801371 by ssranade for vds
#
# Revision 1.8  1998/09/30  06:53:50  pinnacle
# Display posting status on status bar
#
# Revision 1.7  1998/09/28  07:26:32  pinnacle
# (No comment)
#
# Revision 1.6  1998/09/04  19:38:46  pinnacle
# Added string.h for strtok
#
# Revision 1.5  1998/09/03  08:06:50  pinnacle
# TR # 179801453
#
# Revision 1.4  1998/08/31  07:45:12  pinnacle
# TR #:179801292  

# Changes in generation of SIR posting logfile
#
# Revision 1.3  1998/08/14  04:52:48  pinnacle
# For SIR LogFile Generation for Posting SIR parts.
#
# Revision 1.2  1998/08/07  03:59:20  pinnacle
# For SIR

# Modified VDPmeCheckin to accomodate SIR
#
# Revision 1.10  1998/04/17  19:44:52  pinnacle
# TR179800996
#
# Revision 1.9  1998/04/17  19:06:36  pinnacle
# TR179800996
#
# Revision 1.8  1998/04/17  18:04:16  pinnacle
# TR179800996
#
# Revision 1.7  1998/01/30  14:21:22  pinnacle
# AssyTree
#
# Revision 1.6  1998/01/06  20:02:58  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by v250_int for vds
#
# Revision 1.5  1997/12/03  22:04:48  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by yzhu for vds
#
# Revision 1.3  1997/10/27  09:13:14  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by apazhani for vds
#
# Revision 1.2  1997/10/15  10:47:12  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by apazhani for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.4  1997/03/13  10:26:58  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by rgade for vds.241
#
# Revision 1.3  1997/02/27  15:07:40  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by hverstee for vds.241
#
# Revision 1.2  1997/02/05  11:20:38  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.11  1996/05/30  20:43:10  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by tlbriggs for vds.240
#
# Revision 1.10  1996/05/16  19:54:08  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.9  1996/05/13  21:47:34  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.8  1996/05/09  13:27:00  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.7  1996/05/08  17:29:44  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.6  1996/05/06  16:24:50  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.5  1996/05/03  15:45:00  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.4  1995/10/31  20:17:08  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sundar for vds.240
#
# Revision 1.2  1995/10/25  14:20:52  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by hverstee for vds.240
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
 *  08/07/98    Shailesh    Modified VDPmeCheckin to accomodate SIR
 *	10/31/95	tlb		Remove corrections fix.
 *      04/30/96        slj 		Altered to remove schematic stuff.
 *	05/01/96	slj		Removed commented out stuff
 *	05/06/96	slj		Added FREE(p_obj_list) to VdsCheckIn
 *	05/09/96	slj		Removed call to VDPostConnection in
 *					VDScheckin, initialized logfile, p_file
 *	05/16/96	slj		Reset p_nbCatalogs, p_svdsCatalog if
 *				 	vdscatalogs is not found in database
 *	05/30/96	tlb		Replace VDS_CHECKIN_MODEL by REP_MODEL
 *	07/19/96	msm		Added Function VDPmeCheckin -
 *					Reconcile PME code changes.
 *	11/05/96        Ravi 		Added the boolean argument to the
 *					VDPmeCheckin function call to facilitai
 *					te the use of TranslistSav object..
 *	10/15/97        Alwin           Added case PID_EQUIP_OBJ, for pid equip
 *	10/26/97        Alwin           Added cases for the Backshell component.
 *                                      Added some Debug statements.
 *	01/30/98	ah		Post Assembly Tree
 *      04/17/98        ah              TR179800996 Core dump while posting some files
 *                                      and getting extraneous warning messages
 *  04/08/98        Shailesh            Logfile generation for posting Parts to AIM.
 *  08/31/98        Shailesh            Changes in logfile ( ISR posting ).
 *  09/04/98        ah                  Add string.h to make clix happy
 *  09/30/98        Shailesh           	Added VDaimGetpostyes()
 *                                      to show posting status on status bar.
 *  25Nov98		SSR		CR#179801371 Posting of parts or FSIs
 *  					Depending on File type.
 *  01/28/99            law             CR179802489 Posting cable leads
 *  02/04/99            law             CR179701619 Posting jumpers
 *  Aug27/99		SSR		Removed Parts posting to AIM
 *  May23/00		Alwin		Added case's for PID posting of PIPING
 *					and HVAC. CR179901521
 *  Jul/10/00		Alwin		Added case's for Rway Nozzle 
 *
 * -------------------------------------------------------------------*/

/*     

ABSTRACT : 

CHANGE HISTORY

CH  16-Jan-1991  : Design date
MF  04-Dec-1991  : RIS integration

modified for 'Fast-checkin' by J.o's & B.j
modified for 'RIS access' by Marc Fournier (20-Nov-1991)
modified for 'Drawing checkin' by Marc Fournier (23-Jan-1992)
modified for 'PDM checkin of design file' by Mallik (9-May-92)
modified for 'Composite beams' by Alain & Mallik(18-May-92)
modified for 'The order of PDM checkin of design file'
             'Read the checkin flag from the database' by Mallik(28-May-92)
modified for 'Modified for Yarrow' by Mallik 10-July-92
modified for 'PDM 2.0 checkin file to server' by Roger Malmgren (3-Sep-92)
modified for 'command object interface' by Rishad Ali (25-Aug-94)
*/

class implementation ACdb_info ;

#include	<stdio.h>
#include <time.h>
#include "string.h"

#include	"ex.h"
#include	"exdef.h"
#include	"exmacros.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"msdef.h"
#include	"msmacros.h"

#include	"ACdb_info.h"

#include	"AS_status.h"
#include	"parametric.h"
#include	"expression.h"
#include	"expmacros.h"

#include	"madef.h"

#include	"ACcheckin.h"
#include	"VDmem.h"
#include	"VDScheckdef.h"

#include	"PDUerror.h"
#include 	"PDMexec.h"
#include	"PDUuser.h"
#include	"PDUcommand.h"
#include	"PDMfile_mac.h"
#include	"PDUstr.h"

#include	"VDScheckin.h"
#include	"VDSris_def.h"
#include	"VDSris_siz.h"
#include	"VDDbtbldef.h"
#include	"vdbmacros.h"
#include	"v_risproto.h"
#include	"v_miscmacros.h"
/*
#define vdsDEBUG
#define vdserrDEBUG
  */
#include	"v_dbgmacros.h"
#include	"v_datamacros.h"

#include 	"VDPdef.h"
#include	"ACrg_collect.h"


#define FILE_PRINT      if (dm2_log) fprintf

#define TRACE
/******************************************************************************/

#define		AS_DEBUG	1
#define		NBSIZE		10

from OMObjSpace import pass;
from ACcpx      import find_macro, ACgive_structure;
from ACcpx_defn import ACgive_name;
/*from VDREquip 	import VDGetConnectivity;*/
from VDSroot	import VDPostYourselfToDb;
from VDPtrTbl	import	VDPpostPMEdata;
from VDPenabObj         import VDPIsObjEnabled;
from ACrg_collect import ACget_named_attribute;

/*  from VRCorrection  import  VRGetPipeCpts; */

/******************************************************************************/

extern  struct  PDUuser         *user;
extern  int     VD_PDU_present;
/******************************************************************************/

extern  GRclassid     OPP_ACdb_info_class_id;
extern  GRclassid     OPP_VDSroot_class_id;
extern  struct  PDUrefresh  *refresh;
extern int* VDaimGetpostyes();
extern int* VDaimGetpostno();

//extern int CumPartVar;

#ifdef COR_FIX
    extern  GRclassid     OPP_VRCorrection_class_id;
#endif

// needed for CR 4474
#include "VDChkTblLst.h"
//extern long VDpdmPostTableTimestamp();
//static VDTableList  tables;


int VDScheckin (key, to_sql,designRep)
        char                    *key;
        int                     to_sql;
	char			*designRep; /* (I) REP_MODEL or REP_SCHEM */
/*.VDScheckin */
{
        char                            current_cat[MAXWORD];
        char                            current_nam[MAXWORD];
        char                            current_rev[MAXWORD];
        int                             first_attr;

        char                            user[MAXWORD];
        char                            passwd[MAXWORD];
        char                            project[MAXWORD];
        char                            filename[MAXWORD];

        int                             nb_tables;
        char                            dynamic_table[MAXWORD];
	struct		table_attr	*dyntbl_attr = NULL;
	int				dyntbl_count=0;
	struct		vdscatalog	*VdsCatalogs = NULL;
	int				nbCatalogs;
        struct          GRmd_env        mod_env;

        struct          ACobj_info_1    *p_obj_info_1 = NULL ;

        struct          GRid            *p_obj_list = NULL;

        int                             i, j;
 	long				msg;
 	int				count;

 	int				ind;

 	char				row[MAX_ROW_CHAR];

	int				VDmodel_key = 0;
	char				*logfile = NULL;
	FILE				*p_file = NULL;
	int				sts;
	int				rev_flag;
	OM_S_OBJID			next_objid,
					prev_objid;
	int				nbDups=0;
	struct GRid			thisObject ;
	FILE				*sql_file = NULL;
	char				proj_num[30],proj_rev[20];
	int				prj_units;
	int				DelConnRecords;

        SetProc( VDScheckin ); Begin 

	sts = SUCCESS;
	sql_file = NULL;
	p_file = NULL;

  	if (VDSverify_login() != PDM_S_SUCCESS)
        {
           UI_status("User not logged in to Database");
           printf("User not logged in to Database\n");
           sts = DB_WARNING;
	   goto quit;
        }

  	if(VDSverify_project() != OM_S_SUCCESS)
   	{
     	     sts = FAILURE;
             goto quit;
        }

        if( VdsRisAttach() != SUCCESS)
           { printf(" Error in VdsRisAttach\n");
	     sts = DB_WARNING;
	     goto quit; }

	/*|Regular or drawing checkin ? */
	if( strcmp( key, REG_CHECKIN ) == 0 ) {
		first_attr	= REG_FIRST_ATTR;
		logfile		= "VDSreg_chk.log" ;
	} else if( strcmp( key, DWG_CHECKIN ) == 0 ) {
		first_attr	= DWG_FIRST_ATTR ;
		logfile		= "VDSdwg_chk.log" ;
	} else {
		printf( "Unknown key : <%s> for VDS checkin\n", key ) ;
		sts = FAILURE;
		goto quit;
	}

        /* 4/30/96 check validity of designRep */
        if (strcmp (designRep, REP_MODEL) != 0 )
	  {
		printf ("Unknown design representation: <%s> for VDS checkin\n",
			designRep);
		sts = DB_WARNING;
		goto quit;
          }
          
	/*|Initialization */
 	ind               = -1;
	DelConnRecords = DELETE_Y;

        __DBGpr_com("Getting the Dynamic Table Count" );
	sts = VDGetDynamicTblCount( key, designRep, &nb_tables );

	nb_tables = nb_tables+10; /* Kludge incase the family name is not there
				     in vdscatalogs */

	/*C   Allocate memory for dyntbl_attr's */
	dyntbl_attr = _CALLOC (nb_tables, struct table_attr );
	_CheckAlloc(dyntbl_attr, "calloc:dyntbl_attr", sts, FALSE, quit);
	
	for ( i = 0; i < nb_tables; i++ )
	{
		dyntbl_attr[i].table_name[0]	= '\0';
		dyntbl_attr[i].type		= 0; 
		dyntbl_attr[i].feet_list	= NULL; 
		dyntbl_attr[i].format_list	= NULL; 
		dyntbl_attr[i].delete		= DELETE_Y;
	}

	/*C   Memory is allocated here and needs to be freed later  */

	sts = VDReadVdsCatalogs( &nbCatalogs, &VdsCatalogs );

	p_file = (FILE *)fopen( logfile, "w" ) ;
	if( p_file == NULL ) {
		printf( "Cannot open file <%s>, logging to stdout.\n", logfile);
		p_file = (FILE *)stdout ;
	}

 	/*C   Get the refresh area info and open the RIS schema */
 	/*C   This should be done in three time :
 	/*C     - Verify that the active refresh area is filled
 	/*C 	- Open the RIS schema.
 	/*C 	- Get the other info. */

	/*|VdsDatabaseAccess */
	sts = VdsDatabaseAccess(	user,
					passwd,
					project,
					current_cat,
					current_nam,
					current_rev,
					filename,
					&rev_flag );

        if(sts != SUCCESS) 
        { 
           __DBGpr_com("VdsDatabaseAccess failed");
           goto quit; 
        }

	/* Delete From all Dynamic tables */
        __DBGpr_str(" current_cat ", current_cat);
        __DBGpr_str(" current_nam ", current_nam);
        __DBGpr_str(" current_rev ", current_rev);
        __DBGpr_com("Cleaning up all the Dynamic Tables before Posting" );
	sts = VDDeleteDynamicTbls( current_cat, current_nam, current_rev );

	/*|Set or get the model file key in (or from ) EMS directories */

	if( strcmp( key, REG_CHECKIN ) == 0 ) {

		fprintf( p_file, "\n\t\t\tVDS fast checkin on model\n\n");
		fflush( p_file ) ;
		VDmodel_key = VDSset_model_key(	current_cat,
						current_nam,
						current_rev ) ;
	} else {
		fprintf( p_file, "\n\t\t\tVDS fast checkin on drawing\n\n" ) ;
		fflush( p_file ) ;
	}

	if(!VDGetProjectNumRev( proj_num,proj_rev,&prj_units))
		printf("Unable to get Project Number\n");

	if(!VDValidateProject(proj_num,proj_rev,prj_units))
		fprintf( p_file,"\nInvalid Project and Project Units in DB\n");

	if(!VDAddPartToProject( proj_num,
                           	proj_rev,
                             	current_cat,
                             	current_nam,
                             	current_rev))
		fprintf( p_file,"\n\n Unable to add part to VDS_PROJECT_PARTS\n\n");

         /* Save OS to disc */
        sts = ex$save_module( ftype = EX_visible, filename = filename );
        if (sts != 1)
	{
          UI_status("WARNING!! Design file not saved on server");
          fprintf(p_file,"\n\n\t\t Unable to save %s to disc\n\n",
                         filename);
          fflush( p_file ) ;
          fprintf( p_file,"\t\t<%s> not saved on server\n\n", filename);
          fflush( p_file ) ;
	  sts = SUCCESS;
	  goto quit;
	}

/******* SEND THE DESIGN FLAG TO THE SERVER *************/

	sts = VdsCheckinDesign( current_cat, current_nam,
				current_rev, filename, p_file );
	if( sts != SUCCESS) goto quit;

	sql_file = (FILE *)fopen("post.sql","w");
	if( sql_file == NULL ) 
		printf( "Cannot open file <%s>.\n", "post.sql");

 	ex$get_cur_mod( id    = &mod_env.md_id.objid, 
                	osnum = &mod_env.md_id.osnum);

 	mod_env.md_env.matrix_type = MAIDMX; /* Used for the ACgive_structure */
 	MAidmx( &msg, mod_env.md_env.matrix) ;
  
 	/*|Get the list of objects to be checked in */

        __DBGpr_com("Calling the Function VDS_ACdb_info_get_objects" );
        count = 0; /* Initialize the count */
 	VDS_ACdb_info_get_objects(mod_env.md_id.osnum, &p_obj_list, &count);

        __DBGpr_int("No of Objects obtained ", count );

 	if( count == 0 ) {
		/*|Nothing to check-in */
		UI_status("No objects found to checkin");
		fprintf( p_file, "\t\t>>> No objects found to checkin\n" ) ;
		fflush( p_file ) ;
		sts = FAILURE;
		goto quit ;
	} else {
		fprintf( p_file, "\t\t%d components to check\n\n", count );
		fflush( p_file ) ;
	}

 	/*|Collecting the values of the objects to be checked in */

        p_obj_info_1 = _MALLOC ( count, struct ACobj_info_1 );
        _CheckAlloc (p_obj_info_1, "malloc:p_obj_info_1", sts, OM_E_ABORT, quit);

	sts = VdsGet_db_info( p_obj_list, p_obj_info_1, count);

	prev_objid = next_objid = NULL ;

	for( i = 0 ; i < count ; i++ ) {
		UI_status("Processing ...");

                /* CH 8 Jul 92 */
                if(p_obj_list[i].objid == NULL_OBJID) continue;
                /* End, CH 8 Jul 92 */

		thisObject = p_obj_info_1[i].obj ;
                __DBGpr_obj(" Processing the Object..", thisObject );

		/*
		 * Trap duplicate entries.
		 */
		if( i < count-1 ) {
			next_objid = p_obj_info_1[i+1].obj.objid ;
		} else /* i == count - 1 */ {

			/* Must catch the last one if any ...	*/
			/* Need only test if more than 1 obj	*/
	    		if( thisObject.objid == prev_objid ) {
				next_objid = thisObject.objid ;
	    		} else next_objid = NULL ;
		}

		if( next_objid == thisObject.objid ) {
			if( next_objid != prev_objid ) nbDups = 0 ;
			nbDups++;
		} else if( prev_objid == thisObject.objid ) {
			nbDups++ ; /* ALAIN 10 jun 92 */
		} else {
			nbDups = 0;
		}

		prev_objid = thisObject.objid ;

		fprintf( p_file, "PROCESSING %d (#%d)\n",
			 thisObject.objid, i ) ;
		fflush( p_file ) ;

                __DBGpr_com("Get the Dynamic Table Name" );
                dynamic_table[0] = '\0';
		sts = VDGetDynTableName( p_obj_info_1[i].quantity, 
					 thisObject, 
					 mod_env,
					 key, 
					 designRep,
					 nbCatalogs,
					 VdsCatalogs, 
					 dynamic_table );

                __DBGpr_str( "Dynamic Table Name ", dynamic_table );

		if(sts == VDS_E_DYNAMIC_TABLE_NOT_FOUND || (!strcmp(dynamic_table,""))) continue;

		sts = VDGetDynAttrIndex( dynamic_table,
					 &dyntbl_count,
					 &ind,
					 dyntbl_attr);
		/* should check value of sts here before filling rows */
		if (sts != 1) continue;

		sts = VdsFillRow( p_obj_info_1[i], row, thisObject, 
				  mod_env, dyntbl_attr[ind], nbDups,
				  current_cat, current_nam, current_rev,
				  key, p_file ); 
		if (sts != SUCCESS) continue;
           __DBGpr_str("row to db",row);
      	   /* Call directly the function instead of using a shell script */
      	   /* Instead of using the ascii file, the info should is passed
      	   /* directly. */

		if( dyntbl_attr[ind].table_name[0] != '\0' ) {

			sts = VdsPostDb(	key,
						current_cat,
						current_nam,
						current_rev,
						dyntbl_attr[ind].table_name,
						dyntbl_attr[ind].nb_feet,
						dyntbl_attr[ind].format_list,
						row,
						&dyntbl_attr[ind].delete,
						to_sql,
						sql_file ) ;
			if( sts != SUCCESS ) {
				fprintf( p_file,
				 	"Error, cannot fill the database table: %s%s\n",
					 dyntbl_attr[ind].table_name, key);
				fflush( p_file ) ;
			}
		}
	}   /* end for(i=0;i<count;i++)			*/

quit: 

	/* I'm free */
        if (count > 0)
	  	_FREE (p_obj_info_1);

	/* 5/3/96 added FREE for p_obj_list */
	_FREE (p_obj_list);

  	for ( i=0; i<nb_tables; i++) {
		if( dyntbl_attr[i].feet_list != NULL ) {

			for( j = 0 ; j < dyntbl_attr[i].nb_feet ; j++ ) {
				if( dyntbl_attr[i].feet_list[j] != NULL )
					_FREE (dyntbl_attr[i].feet_list[j] );
				if( dyntbl_attr[i].format_list[j] != NULL )
					_FREE( dyntbl_attr[i].format_list[j] ) ;
			}
			_FREE( dyntbl_attr[i].feet_list ) ;
			_FREE( dyntbl_attr[i].format_list ) ;
		}
	}
        _FREE(dyntbl_attr);

	/* Free VdsCatalogs	*/
	_FREE( VdsCatalogs );

	if (p_file != (FILE *)stdout ) fclose (p_file);
	if (sql_file != NULL ) fclose (sql_file);

        End
	return (sts);
}
/******************************************************************************/

/******************************************************************************/
int format_foot ( foot_name, obj_str, foot_char)

	char 			*foot_name;	/* foot name (I)	*/
	struct	ret_struct 	*obj_str;	/* foot def (I)		*/
	char			*foot_char;	/* foot in char (O)	*/

/*.format_foot */
{
	int	trailing;
	int	i;
	int	j;
	int	l;
	int 	sts = SUCCESS ;

 	if (obj_str->type & parameter_generic)
  	  {
   	   /*|Parameter */
   	   if (obj_str->type == double_type)
    	     {
              /* modified for cr179701619 for negative integer problem */
              IGRdouble doubleval;

              __DBGpr_dbl("Double type", obj_str->var.root_pm_st.value );
              doubleval = obj_str->var.root_pm_st.value;
     	      l = sprintf(foot_char, "%lf", doubleval);
              __DBGpr_str("translated float ",foot_char);

              { char *p = NULL ;
                p = strchr(foot_char, 'N');
                if( p != NULL ){
                  printf(" Found a NaN value for attribute %s\n", foot_name );
                  l = sprintf(foot_char, "999999.0" );
		  sts = FAILURE ;
                }
              }

     	      /*|Suppress trailing zeros */
     	      /*^
              printf("number of written char %d=<%s>\n", l, foot_name);
	      */
     	      for (i=0; foot_char[i] != '.' || i>= l; i++) { ; }
     	      if (i < l)
       	        {
        	 /*^
printf ("decimal point encounterd at position %d \n", i);
		 */
        	 trailing = TRUE;
        	 for ( j=i+1; j<l; j++)
           	   if (foot_char[j] != '0') trailing = FALSE;
        	   if (trailing == TRUE) foot_char[i]= 0;
       	        }
    	     }
   	   else
    	     {
     	      /*"Text type: %s\n", obj_str->var.text_st.text_string */
     	      strcpy(foot_char, obj_str->var.text_st.text_string);
    	     }
  	  }
 	else if (obj_str->type & point_generic)
  	  {
   	   /*|Point */
   	   sprintf ( foot_char,
		     "%lf:%lf:%lf",
		     obj_str->var.point_st.pt[0],
		     obj_str->var.point_st.pt[1],
		     obj_str->var.point_st.pt[2] );
          }
 	else if (obj_str->type & ref_generic)
  	  {
    	   /*|Coordinate system */
   	   sprintf ( foot_char,
		     "%lf:%lf:%lf:%lf:%lf:%lf:%lf:%lf:%lf",
                     obj_str->var.ref_st.t[3],obj_str->var.ref_st.t[7],
                     obj_str->var.ref_st.t[11],obj_str->var.ref_st.t[0],
                     obj_str->var.ref_st.t[4],obj_str->var.ref_st.t[8],
                     obj_str->var.ref_st.t[1],obj_str->var.ref_st.t[5],
                     obj_str->var.ref_st.t[9]);
  	  }
 	else
  	  {
printf("format: %d   ---> Unknown for: %s\n",  obj_str->type, foot_name);
   	   /*"format: %d   ---> Unknown\n",  obj_str->type*/
   	   return FAILURE;
  	  }
/*
        printf(" foot name:<%s>, value: <%s>\n", foot_name, foot_char ); 
*/

 	return sts;
}
/******************************************************************************/

/******************************************************************************/
int fill_row ( table, ind, value)

	char 		table[];		/* Row name		*/
	int  		ind[];			/* available position 	*/
	char		value[];		/* Value to store	*/

/*.fill_row*/
{

 	if (*ind == 0)
  	  {
   	   /*| First call */
   	   strcpy(table,value);
   	   *ind = strlen(value);
  	  }
 	else
  	  {
   	   strcpy ( &table[*ind], SEP_STRING);
   	   strcpy ( &table[*ind+SEP_LENGTH], value);
   	   *ind = *ind + strlen(value) + SEP_LENGTH;
  	  }


 	return SUCCESS;
}
/******************************************************************************/

/* ALAIN 13 may 92 : modifications of functions found in ACdb_info.I */

IGRint VDS_ACdb_info_get_objects (os_osnum, p_obj_list, p_count)

GRspacenum   os_osnum;
struct  GRid **p_obj_list;
IGRint       *p_count;

/*.VDS_ACdb_info_get_objects*/
  {
   return (VDS_ACdb_info_get_specific_objects (os_osnum, p_obj_list, p_count,
	   VDS_FAST_CHECKIN));
  }


/* VDS_ACdb_info_get_specific_objects */  
IGRint VDS_ACdb_info_get_specific_objects (os_osnum, p_obj_list, p_count, chk_flag)

GRspacenum   os_osnum;
struct  GRid **p_obj_list;		/* O: object list */
IGRint       *p_count;			/* O: object count */
IGRint       chk_flag;

{
   struct ACobj_info_1		*p_obj_info = NULL; 
   int				status=0;
   int				count;
   int 				i;
   int    			compar ();
   void				qsort ();
   int 				max_obj, i_obj;
   GRclassid 			obj_class;
   IGRint			checkin_candidate;

   SetProc( VDS_ACdb_info_get_specific_objects ); Begin

   status = OM_S_SUCCESS;
   *p_obj_list	= NULL ;
   *p_count	= 0 ;

   max_obj = OM_GA_OSDs[os_osnum]->CurSpaceMapSize;
   count = max_obj;

   p_obj_info= _MALLOC (count, struct ACobj_info_1 );
   _CheckAlloc (p_obj_info, "malloc:p_obj_info", status, OM_E_ABORT, quit);

   for (i_obj= 0; i_obj< max_obj; i_obj= i_obj+ 1)
   {
      // __DBGpr_int( "Checking the Object Id ", i_obj );
      status = om$get_classid(objid = i_obj,
                              osnum = os_osnum,
                          p_classid = &obj_class);
    
      if (status&1)
        { 
         status = om$is_ancestry_valid (subclassid   = obj_class,
					superclassid = OPP_ACdb_info_class_id);

         if (status == OM_S_SUCCESS)
	   {
            __DBGpr_int("Checking for ancestry_valid for object", i_obj );
            /* Set the default/initial value to FALSE. Alwin */
            checkin_candidate = FALSE;

            status= om$send (msg = message ACdb_info.ACcheckin_candidate
				          (chk_flag, &checkin_candidate),
	                senderid = NULL_OBJID,
		        targetid = i_obj,
		        targetos = os_osnum);

            __DBGpr_int( "Check_in_candidate status ", checkin_candidate );

            if ((status&1) &&  (checkin_candidate == TRUE))
              {
                __DBGpr_int( "Object added to list for posting", i_obj );
		status = om$send(	msg = message ACdb_info.ACadd_to_list_1(
						p_obj_info, count, p_count ),
						senderid = NULL_OBJID,
		        		targetid = i_obj,
		        		targetos = os_osnum);
                __DBGpr_int( "Object Count after addition", *p_count );
              }
           }
        }
   }

   /* sorting the objects by serial_no */
   if( ! *p_count ) goto quit ;

   count = *p_count;
   qsort (p_obj_info, (unsigned)count, sizeof (struct ACobj_info_1), compar);

   __DBGpr_com( "Allocating memory for p_obj_list" );
   *p_obj_list= _MALLOC (count, struct GRid );
   _CheckAlloc (*p_obj_list, "malloc:p_obj_list", status, OM_E_ABORT, quit);

   for (i=0; i< count; i= i+1)
     (*p_obj_list)[i]= p_obj_info[i].obj;
 
quit:

   End
   __DBGpr_com( "Freeing the memory, p_obj_info" );
   _FREE(p_obj_info);

   return (status);
}

compar (p_obj_info1, p_obj_info2)

struct ACobj_info_1 *p_obj_info1;
struct ACobj_info_1 *p_obj_info2;

/*.compar */
  {

#  ifdef DEBUG
   printf ("enter compar \n");
   printf ("p_obj_info1->serial_no= %d \n", p_obj_info1->serial_no);
   printf ("p_obj_info2->serial_no= %d \n", p_obj_info2->serial_no);
#  endif

#  ifdef DEBUG
   printf ("exit  compar \n");
#  endif
   return (p_obj_info1->serial_no - p_obj_info2->serial_no);
  }

/* END 13 may 92 */
/*----------------------------------------------------------------------------*/


int  VdsRetChkDgnFlag( checkinDgn, err_ptr )
int  *checkinDgn;
char *err_ptr;
{

        char    table[100];
        char    select[100];
        char    search[300];
        int     sts, project_num;
	int	nbocc;
	char	**buffer;
	char	value[MAXWORD];


	sts = 1;

        if (!VdsGetPrjNo(&project_num))
        {
          if(err_ptr != NULL)
             sprintf(err_ptr, "Failed to get current project number" );
          sts = FAILURE;
	  goto quit;
        }

        sprintf( table, "%s", "vds_project");
        sprintf( select, "%s", "checkin_dgn");
	sprintf( search, "prj_no = %d", project_num);

	sts = vdb$RisSelect (   select 		= select,
				table_name	= table,
				where		= search,
				numselect 	= 1,
				p_numrows 	= &nbocc,
				p_buffer 	= &buffer );
        if (sts == FAILURE) 
	{
          if(err_ptr != NULL)
             sprintf(err_ptr, "Failed accessing VDS_PROJECT." );
          goto quit;
	}

	        /*|Extract value from buffer */
        sts = vdb$RisExtractValue ( 	nbrows 		= nbocc, 
					nbcolumns 	= 1,  
				    	buffer 		= buffer, 
					row 		= 0, 
					column 		= 0, 
				    	value 		= value);
        if (sts == FAILURE)
	{
          if(err_ptr != NULL)
             sprintf(err_ptr, "Failed to fetch chkin_dgn flag" );
	  goto quit;
	}

        *checkinDgn = atoi (value);

quit:
        vdb$RisFreeBuffer (buffer =  buffer, size = nbocc);

        return (sts);
}
/* VdsGetTempFileName creates a unique filename in current working directory*/
int VdsGetTempFileName ( defstring, tempname )
char defstring[];       /* Default string               (I)*/
char tempname[];        /* Temporary filename           (O)*/

/*      Returns 1 if ok
                0 if failure */
{
        int     i;
        FILE    *file_ptr;
        char    number[4];
	int	status;

	status = 1;

        strcpy (tempname,defstring);
        tempname[14] = NULL;

        /* Check if file is possible to open for reading */
        file_ptr = (FILE *)fopen(tempname,"r");
        if( file_ptr == NULL )
        {  /* Non-existing file should be possible to open for write */
           file_ptr = (FILE *)fopen(tempname,"w");
           if( file_ptr != NULL )
           {
              return 1;
           }
        }
        else fclose(file_ptr);

        for (i=0;i<1000;i++)
        {
           tempname[11] = NULL;
           sprintf(number,"%d",i);
           strcat(tempname,number);
           file_ptr = (FILE *)fopen(tempname,"r");
           if( file_ptr == NULL )
           {  /* Non-existing file should be possible to open for write */
              file_ptr = (FILE *)fopen(tempname,"w");
              if( file_ptr != NULL )
              {
                 fclose(file_ptr);
                 return 1;
              }
           }
           else fclose(file_ptr);
        }


        return 0;
}


int  VdsCheckinDesign( current_cat, current_nam,
			current_rev, filename, p_file)
char	*current_cat;
char	*current_nam;
char	*current_rev;
char	*filename;
FILE	*p_file;
{

     int		PDUstatus, sts;
     static int		first=0;
     static int         designFlag;
     char		err_msg[100];
     char		io_status[3];
     char		checkin_user[15];
     char		checkout_user[15];
     char		checkout_node[31];
     char		checkout_dir[81];
     char		t_name[25], defstring[25];
     char		buffer[81];
     struct EX_var_list ex_var[2];
     int                var_size, bad_var;
     char               cur_filename[128];

     SetProc( VdsCheckinDesign ); Begin 
     sts = TRUE;
 
     if( !first )
     {
          sts = VdsRetChkDgnFlag( &designFlag, err_msg);
          if( sts != 1)
          {
            printf("<%s>\n",err_msg );
	    first = 0;
	    goto quit;
          }
          first = 1;
     }

     if(designFlag == 1 && VD_PDU_present)
     {
        /* Check in file to server */

        /* Check current filename against filename */
        var_size = sizeof( cur_filename );
        ex_var[0].var       = EX_CUR_FILENAME;
        ex_var[0].var_value = cur_filename;
        ex_var[0].num_bytes = &var_size;

        ex_var[1].var = NULL;
        if (!ex$global ( mode = EX_INQ,
                         var  = &ex_var[0],
                         which_error = &bad_var ))
        {
           UI_status("Failed to get current filename");
           fprintf(p_file,"\n\nFailed to get current filename\n");
           fflush( p_file ) ;
           sts = FAILURE;
           goto quit;
        }
        if (strcmp(cur_filename,filename))
        {
           UI_status("Part local filename not same as current filename");
           fprintf(p_file,"\n\nPart local filename <%s>, name of current file <%s>\n",
                          filename,cur_filename);
           fflush( p_file ) ;
	   sts = FAILURE;
           goto quit;
        }
  
	if ( VdsRetrievePartAttributes ( current_cat,
                                         current_nam,
                                         current_rev,
					 io_status,
                                	 checkin_user,
					 checkout_user,
					 checkout_node,
                                	 checkout_dir,
                                         err_msg) != SUCCESS )
          {
           UI_status(err_msg);
           fprintf(p_file,"\n\n%s\n",err_msg);
           fflush( p_file ) ;
	   sts = FAILURE;
           goto quit;
          }


       if ( io_status[0] != NULL )
         {
          if ( strcmp(io_status,"O") && strcmp(io_status,"S"))
            {
             sprintf(err_msg,"Part %s rev %s is not checked out",
                         current_nam, current_rev);
             UI_status(err_msg);
             fprintf(p_file,"\n\n\t\t %s\n\n");
             fflush( p_file ) ;
             fprintf( p_file,
             "\t\t<%s> not saved on server\n\n", filename);
             fflush( p_file ) ;
	     sts = FAILURE;
             goto quit;
            }
          else if ( strcmp(checkout_node,user->wrkst_node)
                   || strcmp(checkout_dir,user->wrkst_cwd)
		   || strcmp(checkout_user,user->username))
            {
             sprintf(err_msg,"Part %s rev %s is checked out by %s",
                         current_nam, current_rev, checkout_user);
	     UI_status(err_msg);
             fprintf(p_file,"\n\n\t\t Part %s rev %s is checked out by %s to %s on node %s\n\n",
                         current_nam, current_rev, checkout_user,checkout_dir,
                         checkout_node);
             fflush( p_file ) ;
	     sts = FAILURE;
             goto quit;
            }
          }
        else
	  {
	     UI_status("Checking the design file to the Server");
	     /* Save OS to disc */
/* Saving done earlier.
	     sts = ex$save_module( ftype = EX_visible, filename = filename );
*/
	     /* Create security copy of OS */
	     sprintf(defstring,"__%s",filename);
	     defstring[14] = NULL;
	     if (!VdsGetTempFileName ( defstring, t_name ))
	     {
	        UI_status("Unable to create temporary filename");
	        fprintf( p_file,
	             "\n\n\t\tUnable to create temporary filename out of %s\n");
	        fprintf( p_file,
	             "\t\t<%s> not sent to the PDMserver\n\n", filename);
	        fflush( p_file ) ;
	        sts = FAILURE;
		goto quit;
	     }
	     sprintf(buffer,"/bin/cp %s %s",filename, t_name);
	     sts = system(buffer);
	     if (sts != 0 )
	     {
	        UI_status("Unable to take sequrity copy of current file");
	        fprintf( p_file,
	             "\n\n\t\tUnable to sequrity copy %s to %s\n",filename, t_name);
	        fprintf( p_file,
	             "\t\t<%s> not sent to the PDMserver\n\n", filename);
	        fflush( p_file ) ;
	        sts = FAILURE;
		goto quit;
	     }
	     pdm$checkin_part ( status 	     = &PDUstatus,
				catalog_name = current_cat,
				partid	     = current_nam,
				revision     = current_rev );
	     if (PDUstatus != PDM_S_SUCCESS) {
		UI_status("PDM checkin file to server failed");
                fprintf( p_file,
                "\n\n\t\tError pdm$checkin_part  sts = %x\n",PDUstatus);
                fprintf( p_file,
                "\t\t<%s> not sent to the PDMserver\n\n", filename);
                fflush( p_file ) ;
                sts = FAILURE;
                goto restore_temp;
	     } else {
                fprintf ( p_file,
                "\n\n\t\t<%s> sent to the PDMserver\n\n", filename);
                fflush( p_file ) ;
	     }

	     pdm$checkout_part ( status        = &PDUstatus,
				 catalog_name  = current_cat,
				 partid        = current_nam,
				 revision      = current_rev,
				 activate_flag = 0 );
	     if (PDUstatus != PDM_S_SUCCESS) {
		UI_status("PDM checkout file from server failed");
                fprintf( p_file,
                "\n\n\t\tError pdm$checkout_part  sts = %x\n",PDUstatus);
                fprintf( p_file,
                "\t\t<%s> not retrieved from the PDMserver\n\n", filename);
                fflush( p_file ) ;
                sts = FAILURE;
                goto restore_temp;
	     } else {
                fprintf ( p_file,
                "\n\n\t\t<%s> retrieved from the PDMserver\n\n", filename);
                fflush( p_file ) ;
	     }
	     sts = SUCCESS;
restore_temp:
	     /* Restore OS from security copy */
	     sprintf(buffer,"/bin/mv %s %s",t_name, filename);
	     system(buffer);
	     goto quit;
	  }

         /* Save OS to disc */
/* Saving done earlier.
        sts = ex$save_module( ftype = EX_visible, filename = filename );
        if (sts != 1)
	{
          UI_status("WARNING!! Design file not saved on server");
          fprintf(p_file,"\n\n\t\t Unable to save %s to disc\n\n",
                         filename);
          fflush( p_file ) ;
          fprintf( p_file,"\t\t<%s> not saved on server\n\n", filename);
          fflush( p_file ) ;
          sts = SUCCESS;
	  goto quit;
	}
*/

	/* Fill PDMexec structure */
        PDUload_exec_structure("", current_cat, current_nam, current_rev,
			       "","","",0, 0);

	/* Check in file to server using "CheckIn In Place" */
	PDUstatus =  PDMpost_to_database(NULL,NULL,NULL,NULL,NULL);

        if (PDUstatus != PDM_S_SUCCESS) {
		UI_status("PDM post to database failed");
                fprintf( p_file,
                "\n\n\t\tError PDMpost_to_database  sts = %x\n",PDUstatus);
                fprintf( p_file,
                "\t\t<%s> not sent to the PDMserver\n\n", filename);
                fflush( p_file ) ;
                sts = FAILURE;
		goto quit;
	}
    }

quit:
    End
    return (sts);
}

IGRint	VdsGet_db_info( p_obj_list, p_obj_info_1, count)
struct	GRid		*p_obj_list;
struct	ACobj_info_1	*p_obj_info_1;
IGRint			count;
{
	int 		i;
	int		sts;
	long		msg;
 	struct	ACdb_info	db_info;

        SetProc( VdsGet_db_info ); Begin 

	for( i = 0 ; i < count ; i++ ) {
   		
		sts = om$send(	msg = message ACdb_info.ACget_db_info(
						&msg, &db_info),
				senderid= NULL_OBJID,
				targetid= p_obj_list[i].objid,
				targetos= p_obj_list[i].osnum ) ;
                /* CH 8 Jul 92 */
                if(!(sts & msg &1))
		 {
		  printf("Error getting db_info for: %d, %d (skip it)\n",
		  	 p_obj_list[i].objid,  p_obj_list[i].osnum );
                  p_obj_list[i].objid = NULL_OBJID;
		  continue;
		 }

                /* End, CH 8 Jul 92 */
		p_obj_info_1[i].obj       = p_obj_list[i];
		p_obj_info_1[i].serial_no = db_info.serial_no;
		p_obj_info_1[i].quantity  = db_info.quantity;
	/*
printf(" ObjID = %d ## , Serial No = %d, Quantity = %d \n", p_obj_list[i].objid,
	 db_info.serial_no, db_info.quantity );
*/

	}

        End
	return SUCCESS;
}

IGRint	VdsFillRow( p_obj_info_1, row, thisObject, mod_env, dyntbl_attr, nbDups, current_cat, current_nam, current_rev,key, p_file )

struct	ACobj_info_1	p_obj_info_1;
char			*row;
struct GRid		thisObject ;
struct GRmd_env		mod_env;
struct table_attr	dyntbl_attr;
int			nbDups;
char			*current_cat;
char			*current_nam;
char			*current_rev;
char			*key;
FILE			*p_file;
{

 	int		ind_row_table;
	char		member_name[MAXWORD];
 	char 		SerialStr[MAXWORD];
 	char 		ItemStr[MAXWORD];
 	char 		QuantityStr[MAXWORD];
 	int 		QuantityInt;
 	char 		reference_cat[MAXWORD];
 	char 		reference_nam[MAXWORD];
 	char 		reference_rev[MAXWORD];
	char		*thisAttr;
	long		msg;
 	struct		ret_struct	tmp_rts;
	char		tmp_foot_char[MAX_ROW_CHAR];
 	char		foot_char[MAX_ROW_CHAR];
	char		footToGet[MAX_ROW_CHAR] ;
	int		j, k, l, sts;
	int		first_attr=0;


   	ind_row_table  = 0;
	member_name[0] = 0;

	if( strcmp( key, REG_CHECKIN ) == 0 ) {
		first_attr	= REG_FIRST_ATTR;
	} else if( strcmp( key, DWG_CHECKIN ) == 0 ) {
		first_attr	= DWG_FIRST_ATTR ;
	}

		/*|Fill the common values */
		sprintf( SerialStr, "%d", p_obj_info_1.serial_no ) ;

		/*|Now amended to process */

		if( strcmp( key, REG_CHECKIN ) == 0 )
			fill_row( row, &ind_row_table, SerialStr);

		fill_row( row, &ind_row_table, current_cat);
		fill_row( row, &ind_row_table, current_nam);
		fill_row( row, &ind_row_table, current_rev);

		if( strcmp( key, DWG_CHECKIN ) == 0 ) {
			ItemStr[0] = QuantityStr[0] = QuantityInt = '\0' ;

			sts = VDget_drawing_item_info(
						 &thisObject,
					         ItemStr,
					         &QuantityInt,
					         &mod_env );

			if( sts != TRUE ) {
				strcpy ( ItemStr, "666");
				strcpy ( QuantityStr, "0");
			} else {
				sprintf( QuantityStr, "%d", QuantityInt);
			}

			VDSget_model_key(	thisObject,
						reference_cat,
						reference_nam,
						reference_rev ) ;


			fill_row( row, &ind_row_table, reference_cat	);
			fill_row( row, &ind_row_table, reference_nam	);
			fill_row( row, &ind_row_table, reference_rev	);
			fill_row( row, &ind_row_table, SerialStr	);
			fill_row( row, &ind_row_table, ItemStr		);
			fill_row( row, &ind_row_table, QuantityStr	);
		}

		/*| Ask for the feet values */

		for( j = first_attr; j < dyntbl_attr.nb_feet ; j++ ) {
			int dir_ind = -1 ;

			thisAttr = dyntbl_attr.feet_list[j] ;

			__DBGpr_str( " Attribute", thisAttr );

			if( !strcmp( thisAttr, LOC_X ) )

/*    coordinates etc......              */
 {
	sts = om$send(
	msg = message ACdb_info.ACgive_db_structure(
		  			(int*) &msg,
		  			&dir_ind,
		  			COOR_SYS_NAME,
		  			&tmp_rts,
		  			&mod_env ),
  	  senderid = NULL_OBJID,
          targetid = thisObject.objid,
	  targetos = thisObject.osnum ) ;

	if( sts & msg & 1 )
            {
		int max ;
                GRclassid    thisclass;
#ifdef COR_FIX
                IGRdouble    ddCoord[6];
#endif COR_FIX

                sts = om$get_classid( osnum     = thisObject.osnum ,
                                      objid     = thisObject.objid,
                                      p_classid = &thisclass);

#ifdef COR_FIX
                if (om$is_ancestry_valid
                      (subclassid   = thisclass,
                       superclassid = OPP_VRCorrection_class_id )
                                    == OM_S_SUCCESS )
                {  /*   overrule location with COG....   */
                  sts = om$send
                       (msg = message VRCorrection.VRGetPipeCpts
                                         (&msg, &mod_env, ddCoord),
  	           senderid = NULL_OBJID,
                   targetid = thisObject.objid,
                   targetos = thisObject.osnum ) ;

                   tmp_rts.var.ref_st.t[3]  = (ddCoord[0] + ddCoord[3]) / 2.0;
                   tmp_rts.var.ref_st.t[7]  = (ddCoord[1] + ddCoord[4]) / 2.0;
                   tmp_rts.var.ref_st.t[11] = (ddCoord[2] + ddCoord[5]) / 2.0;
                 } /*   end override    */
#endif COR_FIX

		sts = format_foot(	COOR_SYS_NAME,
					&tmp_rts,
					foot_char ) ;
		if( sts != SUCCESS ){
		  printf("Posting[%d,%d] attribute %s INVALID\n",
				thisObject.osnum, thisObject.objid, 
				COOR_SYS_NAME );
		}

		l = 0 ;
                max = strlen( foot_char ) ;

		for ( k=0; k <= max ; k++ )
                {
			if ( (foot_char[k] == DOUBLE_COL)
			||   (foot_char[k] == 0) )
                    {
			strncpy( tmp_foot_char, &foot_char[l], k-l);
			tmp_foot_char[k-l] = 0;

			fill_row(row, &ind_row_table, tmp_foot_char);
			l= k+ 1;
			if (foot_char[k] == DOUBLE_COL) j++;
		     }
	         }
              }
              else
              {
		fprintf( p_file,
	 "Unable to retrieve referential for component.Component ignored");
		fprintf( p_file,
	 "Component type = %d \n",p_obj_info_1.quantity);
		fflush( p_file ) ;
		fill_row(row, &ind_row_table, "" ) ;
		}

 }
 else /* NOT LOC_X */ {

			char	*wantedFoot ;

			tmp_rts.type = text_type;
			tmp_rts.var.text_st.text_string[0] = '\0' ;

			/* KLUDGE WAITING FOR MODIF IN STRUCT, ROUTE & EQUIP */

			if( !strcmp( thisAttr, "f_part_name") ) {
				wantedFoot = "part_num" ;
			} else if( !strcmp( thisAttr, "f_part_rev" ) ) {
				wantedFoot = "material" ;
			} else {
				wantedFoot = thisAttr ;
			}
			if( nbDups > 0 ) {
				sprintf( footToGet, "%d:%s", nbDups-1,
					 wantedFoot ) ;
			} else {
		   		strcpy( footToGet, wantedFoot ) ;
			}
			
			dir_ind = -1 ;
			sts = om$send(
				msg	= message ACdb_info.ACgive_db_structure(
								(int*) &msg,
								&dir_ind,
					  			footToGet,
								&tmp_rts,
								&mod_env ),
		    		senderid= NULL_OBJID,
		    		targetid= thisObject.objid,
		    		targetos= thisObject.osnum ) ;

			if( sts & msg & 1 ) {

				sts = format_foot(	thisAttr,
							&tmp_rts,
							foot_char ) ;
				if( sts != SUCCESS ){
				  printf("Posting[%d,%d] attribute %s INVALID\n",
					thisObject.osnum, thisObject.objid, thisAttr );
				}

				fill_row( row, &ind_row_table, foot_char);

				if( !strncmp( dyntbl_attr.table_name, STRUCT_NAM, STRUCT_LEN)
				&&  !strcmp ( thisAttr, MEMBER_NAM ) ) {
					strcpy( member_name, foot_char ) ;
				}

			} else {

				fprintf(
					p_file,
					"\tAttribute <%s>\tnot defined for <%s> product\n",
     					footToGet,
	            			dyntbl_attr.table_name);
					fill_row( row, &ind_row_table, "" );
				fflush( p_file ) ;
			}
       
		}/* end NOT LOC_X */ 

		} /* end for(j=first_attr;j<dyntbl_attr.nb_feet;j++) 	*/

   	   strcpy( &row[ind_row_table], SEP_STRING);
   	   ind_row_table++;


	return SUCCESS;
}

IGRint	VDGetRefIdFlag( thisObject, mod_env, ref_flag )
struct GRid		thisObject ;
struct GRmd_env		mod_env;
int    *ref_flag;
{
	long		msg;
 	struct		ret_struct	tmp_rts;
	int		sts;
	int		dir_ind = -1 ;


	sts = om$send(
	msg	= message ACdb_info.ACgive_db_structure(
					(int*) &msg,
					&dir_ind,
		  			VD_N_ORIGINAL_AN,
					&tmp_rts,
					&mod_env ),
	  		senderid= NULL_OBJID,
	  		targetid= thisObject.objid,
	  		targetos= thisObject.osnum ) ;
	if(sts & msg & 1) {
 		if (tmp_rts.type & parameter_generic && tmp_rts.type == text_type )

	      		/* I am only looking for a 'Y' or a 'N' */
     	      		if( tmp_rts.var.text_st.text_string[0] == 'N' || tmp_rts.var.text_st.text_string[0] == 'n' )
				*ref_flag = TRUE;
	}


	return SUCCESS;
}

/*  Get a list of all dynamic tables from the database.                      */
/*  Look at the table VDSCATALOGS to retrieve distinct dynamic tables	     */

int  VDGetDynamicTblCount( key, designRep, nb_tables )
char	*key;
char	*designRep; /* (I) */
int	*nb_tables;
{
	char	**tables; 
	char	select[200];
	char	where[200];


	if(!strcmp(key,DWG_CHECKIN ))
	{
		sprintf( select,"%s","distinct cit_table");
		sprintf( where, "%s","cit_table is not null and cit_table != \' \'" );
	}
	else
	{
		if(!strcmp(designRep, REP_MODEL))
		{
		   sprintf( select,"%s","distinct dynamic_table");
		   sprintf( where, "%s","dynamic_table is not null and dynamic_table != \' \' " );
		}
		else
		{
		   /* replaced sprintf's with error messages */
		   printf ("ERROR: invalid designRep <%s>, DynamicTableCnt \n",
			   designRep);
                   return(FALSE);
		}
	}

	vdb$RisSelect(  select 		= select,
			table_name 	= "VDSCATALOGS",
			where 		= where,
			numselect 	= 1,
			p_numrows 	= nb_tables,
			p_buffer 	= &tables );
	vdb$RisFreeBuffer ( buffer = tables, size = *nb_tables );


	/* 5/16/96 slj - added check for number of rows returned */
	if (nb_tables == NULL || *nb_tables == 0) return (FALSE);
	else return (TRUE);
}

/*C  Get a list of all catalogs and the dynamic tables from the database.    */
/*C  Look at the table VDSCATALOGS to retrieve all info of dynamic tables    */

int VDReadVdsCatalogs( p_nbCatalogs, p_sVdsCatalog )
int			*p_nbCatalogs;		/* O -- Number of catalogs */
struct	vdscatalog	**p_sVdsCatalog;	/* O -- VDS catalogs info  */
{
	char	**buf;
	char	*select="catalog_name, dynamic_table, sch_dyn_table, cit_table, product";
	int	nbselect, i,size;
	int	status;

	status = SUCCESS;

	nbselect = 5;
	status = vdb$RisSelect(	select 		= select,
			table_name 	= "VDSCATALOGS",
			numselect 	= nbselect,
			p_numrows 	= p_nbCatalogs,
			p_buffer 	= &buf );

	if (status != SUCCESS)
	  {
	     printf ("VDReadVdsCatalogs: Error returned from vdb$RisSelect\n");
	     /* 5/16/96 slj - reset these variables if vdscatalog fails */
	     *p_nbCatalogs = 0;
	     *p_sVdsCatalog = NULL;
	     goto quit;
	  }
        if( *p_nbCatalogs ) {
	*p_sVdsCatalog = _CALLOC (*p_nbCatalogs, struct vdscatalog );
	_CheckAlloc (*p_sVdsCatalog, "calloc:*p_sVdsCatalog", status, FALSE, quit);

	}
	/*C 	Fill the buffer with the information		*/

	for ( i =0; i < *p_nbCatalogs; i++ )
	{
		strcpy( (*p_sVdsCatalog)[i].catalog_name, buf[i*nbselect] );
		strcpy( (*p_sVdsCatalog)[i].dynamic_table, buf[i*nbselect+1] );
		strcpy( (*p_sVdsCatalog)[i].sch_dyn_table, buf[i*nbselect+2] );
		strcpy( (*p_sVdsCatalog)[i].cit_table, buf[i*nbselect+3] );
		strcpy( (*p_sVdsCatalog)[i].product, buf[i*nbselect+4] );
	}

quit:
	size = 5 * *p_nbCatalogs;
	vdb$RisFreeBuffer ( buffer = buf, size = size );

	return (status);
}

/*D  This function returns the dynamic_table given the Object and the 
     representation. If the object does not provide the family_name then 
     the dynamic_table is obtained by the quantity. This is just to support the
     old ones too. */

int VDGetDynTableName(  quantity,
			thisObject,
			mod_env,
			key,
			designRep, 
			nbCatalogs, 
			VdsCatalog, 
			dynamic_table )

int 		quantity;		/* I -  Quantity of the Object     */
struct GRid	thisObject ;		/* I -  ObjId of the Object	   */
struct GRmd_env		mod_env;
char		*key;			/* I -	Whether Regular or Drawing */
char		*designRep;		/* I -  Whether Schematic or Model */
int		nbCatalogs;		/* I -  Number of catalogs	   */
struct vdscatalog	*VdsCatalog;	/* I -- VDS catalogs info  	   */
char		*dynamic_table;		/* O -  Name of dynamic table      */
{
	long		msg;
 	struct		ret_struct	tmp_rts;
	int		i,sts;
	int		dir_ind = -1 ;
	char		family_name[20];

	// Added for JTS CR 4474
	if (dynamic_table) *dynamic_table = 0;
	// end of 4474

	family_name[0]='\0';
	sts = om$send(
	msg	= message ACdb_info.ACgive_db_structure(
					(int*) &msg,
					&dir_ind,
		  			VD_N_FAMILY_NAME_AN,
					&tmp_rts,
					&mod_env ),
	  		senderid= NULL_OBJID,
	  		targetid= thisObject.objid,
	  		targetos= thisObject.osnum ) ;
	if(sts & msg & 1) {
 		if (tmp_rts.type & parameter_generic && tmp_rts.type == text_type )
		strcpy( family_name, tmp_rts.var.text_st.text_string );
	}
	if(!strcmp(family_name,""))	
	{
	/*C   I have not got the family_name Get the dynamic_table name based */
	/*C   on quantity. This is to take care of previous mechanism, if     */
	/*C   there is no family name associated with the object.             */

		sts = VDGetDyntblNamebyQuantity( quantity, key, dynamic_table );
		if( sts == VDS_E_DYNAMIC_TABLE_NOT_FOUND ) goto quit;  // CR 4474
		//if( sts == VDS_E_DYNAMIC_TABLE_NOT_FOUND ) return sts;
	}
	else	/*C   Look up vdscatalog for the dynamic family name */
	{
	  /*C  If drawing Checkin get cit_table. If rep is schematic get    */
	  /*C  sch_dyn_table. If Model checkin get dynamic_table.	    */

		for( i =0; i < nbCatalogs; i++ )
		{
		    if(!strcmp(family_name, VdsCatalog[i].catalog_name ))
		    {
			if(!strcmp(key,DWG_CHECKIN)) 
			{
			   strcpy(dynamic_table, VdsCatalog[i].cit_table );
			}
			else if(!strcmp(designRep,"schematic"))
			{
			   strcpy(dynamic_table, VdsCatalog[i].sch_dyn_table );
			}
			else
			   strcpy(dynamic_table, VdsCatalog[i].dynamic_table );
			if(!strcmp(dynamic_table,"NULL"))
			   VDGetDyntblNamebyQuantity( quantity, key, dynamic_table );
			sts = 1;
			goto quit;
		    }
		}
	/*C  If I am here I have not yet found the dynamic table */
		VDGetDyntblNamebyQuantity( quantity, key, dynamic_table );
		if( sts == VDS_E_DYNAMIC_TABLE_NOT_FOUND ) goto quit;
	}

quit:
	// Added for JTS CR 4474
	if ( *dynamic_table != 0 ) 
	    VDChkAddTableToList(dynamic_table);

	return (sts);
}

/*C	VDGetDynAttrIndex() returns the dynamic_table attributes and the   */
/*C	index in the dyntbl_attr buffer.				   */

int VDGetDynAttrIndex( 	dynamic_table,
		 	dyntbl_count,
			index,
			dyntbl_attr)

char			*dynamic_table;		/* I --  Dynamic table name  */
int			*dyntbl_count;		/* I/O - count of dyn tables */
int			*index;			/* O --  Index to the buffer */
struct  table_attr	*dyntbl_attr;		/* I/O - Buffer itself	     */
{
	int	i,sts;


	for ( i = 0; i < *dyntbl_count; i++ )
	{
		if(!strcmp(dyntbl_attr[i].table_name,dynamic_table ))
		{
		/*C   Found the index   */
		    *index = i; return 1;
		}
	}

	/*C   Get from the database the attributes of the dynamic table */

	sts = vdb$RetrieveAttributes(
				table_name = dynamic_table,
				p_num = &dyntbl_attr[*dyntbl_count].nb_feet,
				p_attr = &dyntbl_attr[*dyntbl_count].feet_list,
				p_type = &dyntbl_attr[*dyntbl_count].format_list );
	if( sts != SUCCESS ) { /*
		fprintf( p_file,
		 "Unable to retrieve database schema for table <%s>\n", dynamic_table);
		fprintf( p_file,
		 "All objects checking in to this table will be ignored for check-in.\n");
		fflush( p_file ) ;
	        break; */
	}
	strcpy(dyntbl_attr[*dyntbl_count].table_name, dynamic_table );
	*index = *dyntbl_count;
	(*dyntbl_count)++;


	return 1;
}

int VDGetDyntblNamebyQuantity( quantity, key, dynamic_table )
int     quantity;
char     *key;
char     *dynamic_table;
{

  SetProc ( VDGetDybTblNamebyQuantity ); Begin

  /* 4/30/96 slj - Removed cases for old 2.4 tables. */
  if(!strcmp(key,REG_CHECKIN))
  {
     switch (quantity) {

     /* PIPING Tables */
     case VD_CKIN_PID_PIPING_OBJ:   strcpy(dynamic_table,VD_CKTB_PID_PIPING);
        break;
     case VD_CKIN_PID_PIPENOZ_OBJ:  strcpy(dynamic_table,VD_CKTB_PIP_PID_NOZ);
        break;
     case VD_CKIN_PIPING_OBJ:       strcpy(dynamic_table,VD_CKTB_PIPING);
        break;
     case VD_CKIN_PIPE_NOZZ_OBJ:    strcpy(dynamic_table,VD_CKTB_PIP_NOZ);
        break;
     case VD_CKIN_PIPE_SUPP_OBJ:    strcpy(dynamic_table,VD_CKTB_PIP_SUP);
        break;

     /* HVAC Tables */
     case VD_CKIN_SCH_HVAC_OBJ:     strcpy(dynamic_table,VD_CKTB_PID_HVAC);
        break;
     case VD_CKIN_SCH_HVNOZ_OBJ:    strcpy(dynamic_table,VD_CKTB_HV_PID_NOZ);
        break;
     case VD_CKIN_HVAC_OBJ:         strcpy(dynamic_table,VD_CKTB_HVAC);
        break;
     case VD_CKIN_HVAC_NOZZ_OBJ:    strcpy(dynamic_table,VD_CKTB_HV_NOZ);
        break;

     /* RACEWAY Table */
     case VD_CKIN_RWAY_OBJ:         strcpy(dynamic_table,VD_CKTB_RWAY);
        break;
     case VD_CKIN_RWAY_NOZZ_OBJ:    strcpy(dynamic_table,VD_CKTB_RWAY_NOZ);
        break;

     case VD_CKIN_STRUCT_BEAM_OBJ:  strcpy(dynamic_table,VD_CKTB_SBEAM);
        break;
     case VD_CKIN_STRUCT_PLATE_OBJ: strcpy(dynamic_table,VD_CKTB_SPLATE);
        break;
     case VD_CKIN_STRUCT_JNT_OBJ:   strcpy(dynamic_table,VD_CKTB_JOINT);
        break;
     case VD_CKIN_EQUIPMENT_OBJ:    strcpy(dynamic_table,VD_CKTB_EQUIP);
        break;
     case VD_CKIN_COMPARTMENT_OBJ:  strcpy(dynamic_table,VD_CKTB_COMPART);
        break;
     case VD_CKIN_SURFACE_OBJ:      strcpy(dynamic_table,VD_CKTB_SURFACE);
        break;

     /*      cabling tables added        */

     case VD_CKIN_CABMOD_GUIDE:      strcpy(dynamic_table,VD_CKTB_M_CBGUIDE);
        break;
     case VD_CKIN_CABMOD_ELTERM:     strcpy(dynamic_table,VD_CKTB_M_CBETERM);
        break;
     case VD_CKIN_CABMOD_ELCAB:      strcpy(dynamic_table,VD_CKTB_M_CBECAB);
        break;
     case VD_CKIN_CABMOD_FOTERM:     strcpy(dynamic_table,VD_CKTB_M_CBFTERM);
        break;
     case VD_CKIN_CABMOD_FOCAB:      strcpy(dynamic_table,VD_CKTB_M_CBFCAB);
        break;

     case VD_CKIN_CABSCH_GUIDE:      strcpy(dynamic_table,VD_CKTB_S_CBGUIDE);
        break;
     case VD_CKIN_CABSCH_ELTERM:     strcpy(dynamic_table,VD_CKTB_S_CBETERM);
        break;
     case VD_CKIN_CABSCH_ELCAB:      strcpy(dynamic_table,VD_CKTB_S_CBECAB);
        break;
     case VD_CKIN_CABSCH_FOTERM:     strcpy(dynamic_table,VD_CKTB_S_CBFTERM);
        break;
     case VD_CKIN_CABSCH_FOCAB:      strcpy(dynamic_table,VD_CKTB_S_CBFCAB);
        break;

     case VD_CKIN_PID_EQUIP_OBJ:      strcpy(dynamic_table, VD_CKTB_PID_EQUIP);
        break;
 
     case VD_CKIN_CABSCH_EBKSHELL: strcpy(dynamic_table,VD_CKTB_S_CBEBKSH);
        break;
 
     case VD_CKIN_CABMOD_EBKSHELL: strcpy(dynamic_table,VD_CKTB_M_CBEBKSH);
        break;

     case VD_CKIN_VRPOST_ELEAD:      strcpy(dynamic_table,VD_CKTB_S_CBELEAD);
        break;
     case VD_CKIN_VRPOST_FLEAD:      strcpy(dynamic_table,VD_CKTB_S_CBFLEAD);
        break;
     case VD_CKIN_VRPOST_JUMP:       strcpy(dynamic_table,VD_CKTB_S_CBJUMP);
        break;
     case VD_CKIN_VRPOST_JMPLOC:     strcpy(dynamic_table,VD_CKTB_S_CBJMPLOC);
        break;
     default:
        printf("Unknown Object Type \n");
        return VDS_E_DYNAMIC_TABLE_NOT_FOUND;
     }
  }
  else if(!strcmp(key,DWG_CHECKIN))
  {
     switch (quantity) {
     case VD_CKIN_STRUCT_BEAM_OBJ:    strcpy(dynamic_table,VD_CKTB_BM_CIT);
        break;
     case VD_CKIN_STRUCT_PLATE_OBJ:   strcpy(dynamic_table,VD_CKTB_PL_CIT);
        break;
     case VD_CKIN_COMPARTMENT_OBJ:    strcpy(dynamic_table,VD_CKTB_CP_CIT);
        break;
     default:
        return VDS_E_DYNAMIC_TABLE_NOT_FOUND;
     }
  }

  __DBGpr_str( " Dynamic Table Name ", dynamic_table );

  End
  return 1;
}

/***************************************************************************/
/* int	VDPostConnectionInfo (	current_cat,	-- Assembly Catalog	(I)*/
/*				current_nam,    -- Assembly Part	(I)*/ 
/*				current_rev,	-- Assembly Revision	(I)*/
/*				quantity,   -- Type of OBJ in ACdbInfo  (I)*/
/*				EntityId  )	-- OBJID of the Object	(I)*/
/* Returns: 0 -- Failure						   */
/*	    1 -- Success						   */
/*									   */
/*  The Objective is to post the connectivity information to the database  */
/*  in the table VDS_CONNECTIONS. 					   */
/*									   */
/*  Algorithm:
/*  For the entity of EntityId, retrieve the neighbouring objects  in a    */
/*  particular order/direction ( flow direction being the criteria for     */
/*  PIPING OBJECTS. Make an entry in the table for each object and each    */
/*  Connect point. The design file is made unique based on Assembly Catalog*/
/*  Part and Revision. The information in the table VDS_CONNECTIONS should */
/*  consistent with the information in the DYNAMIC tables. There cannot be */
/*  duplicate entries in the database. So at the time of post to database  */
/*  All previous entries for a design file in the table are deleted.	   */ 
/*									   */
/*  The function VDGetRouteConnectivity should return only the Cpts which  */
/*  have a outward flow direction.					   */
/*									   */
/***************************************************************************/

int	VDPostConnectionInfo (	current_cat,
				current_nam,
				current_rev,
				quantity,
				mod_env,
				EntityId,
				delete  )
char		*current_cat;
char		*current_nam;
char		*current_rev;
int		quantity;
struct GRmd_env mod_env;
struct GRid	EntityId;
int		*delete;
{
	struct	VDConnEntity	Entities[NBSIZE];
	struct	VDConnEntity	*p_Entities;
	short			NbCpts=0;
	char			**Cpts;
	char			TMPSTRING[NBSIZE * 10];
	char			COLSTRING[ 7 * 30];
	char			where[100];
	int			columns=7;  /* No of cols in VDS_CONNECTIONS */
	int			col_typ[7];
	char			*col_value[7];
	char			*table="VDS_CONNECTIONS";
	int			i,sts;
	int			NbSize;
	
        SetProc( VDPostConnectionInfo ); Begin

	sts = 1;

	for ( i=0; i < columns; i++) 	
		col_value[i]=NULL;

	NbSize = NBSIZE;
	Cpts = _MALLOC (NbSize, char* );
	_CheckAlloc(Cpts, "malloc:Cpts", sts, FALSE, quit);

	for ( i=0; i<NbSize; i++ ) 
 	   { 
		Cpts[i]=&TMPSTRING[i*10];
		Cpts[i][0]=0;
	   }
	for ( i=0; i<columns; i++ ) 
	   { 
		col_value[i] = &COLSTRING[i*30];
		col_value[i][0] = 0;
 	   }

	p_Entities = Entities; 

	/* if they have to be deleted then delete */

	if( *delete == DELETE_Y )
	{
		sprintf( where,"assembly_cat = '%s' and assembly_nam = '%s' and assembly_ver = '%s' ", 
			 current_cat, current_nam, current_rev );
		sts = vdb$RisDelete (table_name = table, where = where );

		/* -----------------------------------------------------------------
		 * TR179800996 An error here probably means the table does not exist
                 * Not a problem is no elements are being posted to it
                 * So just suppress the warning message
                 *
                 * Actually the warnings were coming from func/VDPrjPart.C
                 * Not sure when this code gets called
                 * But suppress it anyways
		 */
		//if(sts != 1)	printf("Error Deleting from <%s>\n", table);


	    *delete = DELETE_N;
	}

	columns = 7;

	/* Prepare the SqlInsert Statement	*/
	col_typ[0] = col_typ[1] = col_typ[2] = col_typ[4] = col_typ[6] = CHAR;
	col_typ[3] = col_typ[5] = INT;

/*	sprintf(tmp_str,"%d\0",EntityId.objid ); */

	strcpy( col_value[0], current_cat );
	strcpy( col_value[1], current_nam );
	strcpy( col_value[2], current_rev );
	sprintf( col_value[3],"%8d\0",EntityId.objid );
	for ( i = 0; i < NbCpts; i++ )
	{
		Cpts[i][9] = '\0';
		strcpy ( col_value[4], Cpts[i] );
		sprintf( col_value[5], "%d", p_Entities[i].EntityNo.objid );
		p_Entities[i].Cpt[9] = '\0';
		strcpy ( col_value[6], p_Entities[i].Cpt );

	/* 	Post to the table */

		if(!VdsSqlInsert( table, columns, col_typ, col_value ))
		 {
			sts = 0;
			goto quit;
		 }
	}

quit:
	_FREE (Cpts);

        End
	return (sts);
}


/******************************************************************************/
int VdsCheckIn( key, to_sql, designRep )
char *key;
int  to_sql;
char *designRep;	/* (I) REP_MODEL or REP_SCHEM */
/*.VdsCheckIn */ 
{
 	char 				current_cat[MAXWORD];
 	char 				current_nam[MAXWORD];
 	char 				current_rev[MAXWORD];

 	char				user[MAXWORD];
	char				passwd[MAXWORD];
 	char				project[MAXWORD];
	char				filename[MAXWORD];

 	struct		GRmd_env	mod_env;

 	struct		ACobj_info_1	*p_obj_info_1 = NULL ;

 	struct		GRid		*p_obj_list = NULL;

 	int 				i;
 	long				msg;
 	int				count;

 	int				ind;

	int				VDmodel_key = 0;
	char				*logfile ;
	FILE				*p_file;
	int				sts;
	int				rev_flag;
	OM_S_OBJID			next_objid,
					prev_objid;
	int				nbDups=0;
	struct GRid			thisObject ;
	char				proj_num[30],proj_rev[20];
	int				prj_units;

	GRclassid      			ObjClass;
	int				status;
	int				delete;

	int                             tbl_cnt;
	char                          **tbl_list;

        SetProc( VdsCheckin ); Begin
	status = TRUE;

	logfile = NULL;
	p_file = NULL;

	delete = DELETE_Y;

	// added by JTS CR 4474
	VDChkInitTableList();

  	if (VDSverify_login() != PDM_S_SUCCESS)
        {
           UI_status("User not logged in to Database");
           printf("User not logged in to Database\n");
           status = DB_WARNING;
	   goto quit;
        }

  	if(VDSverify_project() != OM_S_SUCCESS)
   	{
     	     status = FAILURE;
             __DBGpr_com("Verify Project Failure");
             goto quit;
        }

        if( VdsRisAttach() != SUCCESS)
           { printf(" Error in VdsRisAttach\n");
	     status = DB_WARNING; 
   	     goto quit; }

	/*|Regular or drawing checkin ? */
	if( strcmp( key, REG_CHECKIN ) == 0 )
	 logfile = "VDSreg_chk.log";
	else if( strcmp( key, DWG_CHECKIN ) == 0 )
	 logfile = "VDSdwg_chk.log";
	else
	{
		printf( "Unknown key : <%s> for VDS checkin\n", key ) ;
		status = FAILURE;
		goto quit;
	}

	/*|Initialization */
 	ind		= -1;

	p_file = (FILE *)fopen( logfile, "w" ) ;
	if( p_file == NULL ) {
		printf( "Cannot open file <%s>, logging to stdout.\n", logfile);
		p_file = (FILE *)stdout ;
	}

 	/* Get the refresh area info and open the RIS schema */
 	/* This should be done in three time :
 	/*      - Verify that the active refresh area is filled
 	/*	- Open the RIS schema.
 	/*	- Get the other info. */

        __DBGpr_com("before VdsDatabaseAccess");
	/*|VdsDatabaseAccess */
	sts = VdsDatabaseAccess(	user,
					passwd,
					project,
					current_cat,
					current_nam,
					current_rev,
					filename,
					&rev_flag );

        if(sts != SUCCESS) { status = sts; goto quit; }

        __DBGpr_com(" Cleaning up the Dynamic Tables before posting" );
	sts = VDDeleteDynamicTbls( current_cat, current_nam, current_rev );

	/*|Set or get the model file key in (or from ) EMS directories */

        __DBGpr_com(" beroe VDSset_model_key" );
	if( strcmp( key, REG_CHECKIN ) == 0 ) {

		fprintf( p_file, "\n\t\t\tVDS fast checkin on model\n\n");
		fflush( p_file ) ;
		VDmodel_key = VDSset_model_key(	current_cat,
						current_nam,
						current_rev ) ;
	} else {
		fprintf( p_file, "\n\t\t\tVDS fast checkin on drawing\n\n" ) ;
		fflush( p_file ) ;
	}

        __DBGpr_com("before VDGetProjectNumRev");
	if(!VDGetProjectNumRev( proj_num,proj_rev,&prj_units))
		printf("Unable to get Project Number\n");
        __DBGpr_com("before VDValidateProject");
	if(!VDValidateProject(proj_num,proj_rev,prj_units))
		fprintf( p_file,"\nInvalid Project and Project Units in DB\n");

        __DBGpr_com("before VDAddPartToProject");
	if(!VDAddPartToProject( proj_num,
                           	proj_rev,
                             	current_cat,
                             	current_nam,
                             	current_rev))
		fprintf( p_file,"\n\n Unable to add part to VDS_PROJECT_PARTS\n\n");

         /* Save OS to disc */
        sts = ex$save_module( ftype = EX_visible, filename = filename );
        if (sts != 1)
	{
          UI_status("WARNING!! Design file not saved on server");
          fprintf(p_file,"\n\n\t\t Unable to save %s to disc\n\n",
                         filename);
          fflush( p_file ) ;
          fprintf( p_file,"\t\t<%s> not saved on server\n\n", filename);
          fflush( p_file ) ;
          status = SUCCESS;
	  goto quit;
	} 

/******* SEND THE DESIGN FLAG TO THE SERVER *************/

        __DBGpr_com("before VdsCheckinDesign");
	sts = VdsCheckinDesign( current_cat, current_nam,
				current_rev, filename, p_file );
	if( sts != SUCCESS)
	{ status = FAILURE;
	  goto quit;
	}

 	ex$get_cur_mod( id    = &mod_env.md_id.objid, 
                	osnum = &mod_env.md_id.osnum);

 	mod_env.md_env.matrix_type = MAIDMX; /* Used for ACgive_structure */
 	MAidmx( &msg, mod_env.md_env.matrix) ;
  
 	/*|Get the list of objects to be checked in */
        __DBGpr_com(" Calling the VDS_ACdb_info_get_objects " );
        count = 0;
 	VDS_ACdb_info_get_objects(mod_env.md_id.osnum, &p_obj_list, &count);
        __DBGpr_int(" No of Objects to be posted ", count );

 	if( count == 0 ) {
		/*|Nothing to check-in */
		UI_status("No objects found to checkin");
		fprintf( p_file, "\t\t>>> No objects found to checkin\n" ) ;
		fflush( p_file ) ;
		status = FAILURE;
		goto quit ;
  	} else {
		fprintf( p_file, "\t\t%d components to check\n\n", count );
		fflush( p_file ) ;
  	}

 	/*|Collecting the values of the objects to be checked in */

	p_obj_info_1 = _MALLOC (count, struct ACobj_info_1 );
	_CheckAlloc (p_obj_info_1, "malloc:p_obj_info_1", sts, OM_E_ABORT, quit);
        __DBGpr_com( "Calling the function VdsGet_db_info" );
	sts = VdsGet_db_info( p_obj_list, p_obj_info_1, count);

	prev_objid = next_objid = NULL ;

	delete = DELETE_Y;

	for( i = 0 ; i < count ; i++ ) {

		UI_status("Processing ...");

                /* CH 8 Jul 92 */
                if(p_obj_list[i].objid == NULL_OBJID) continue;
                /* End, CH 8 Jul 92 */

		thisObject = p_obj_info_1[i].obj ;
                __DBGpr_obj( "Processing the Object ", thisObject );

		/*
		 * Trap duplicate entries.
		 */
		if( i < count-1 ) {
			next_objid = p_obj_info_1[i+1].obj.objid ;
		} else /* i == count - 1 */ {

			/* Must catch the last one if any ...	*/
			/* Need only test if more than 1 obj	*/
	    		if( thisObject.objid == prev_objid ) {
				next_objid = thisObject.objid ;
	    		} else next_objid = NULL ;
		}

		if( next_objid == thisObject.objid ) {
			if( next_objid != prev_objid ) nbDups = 0 ;
			nbDups++;
		} else if( prev_objid == thisObject.objid ) {
			nbDups++ ; /* ALAIN 10 jun 92 */
		} else {
			nbDups = 0;
		}

		prev_objid = thisObject.objid ;

		fprintf( p_file, "PROCESSING %d (#%d)\n",
			 thisObject.objid, i ) ;
		fflush( p_file ) ;

		/* validate classid */
                __DBGpr_com(" Validating the Classid of the Object" );
		status = om$get_classid(
				osnum        = thisObject.osnum,
				objid        = thisObject.objid,
				p_classid    = &ObjClass );
		as$status();

		if( om$is_ancestry_valid(
				 subclassid   = ObjClass,
		 		 superclassid = OPP_VDSroot_class_id)
		    != OM_S_SUCCESS )
		{
		  fprintf( p_file,
			   "object %d,%d does not subclass from VDSroot\n",
			   thisObject.objid, thisObject.osnum );
		  status = MSFAIL;
		  goto quit;
		}

		/* send VDpostYourselfToDb */
                __DBGpr_obj( "Posting the Object... ", thisObject );
		status = om$send( msg = message VDSroot.VDPostYourselfToDb
                                                ( &msg, REG_CHECKIN, to_sql,
						  current_cat, current_nam,
						  current_rev, designRep,
						  &delete ),
				  senderid = NULL_OBJID,
				  targetid = thisObject.objid,
				  targetos = thisObject.osnum );
		as$status();

	}   /* end for(i=0;i<count;i++)			*/

quit: 
        /* Post assembly tree set
         * Uses a self contained posting system
         */
        VDatPOSTAll();


	/* Post vdpdm stuff, currently just macros
	 * Self contained posting system
	 * Added for JTS CR 5083*/
	VDpdmPostAll();

	// Add gettablelist here, then cycle through to timestamp them.  CR
	// 4474
	// get the table list
	
	tbl_cnt = 0;
	VDChkGetTableList(&tbl_cnt,&tbl_list);
	
	for (i = 0; i < tbl_cnt; i++) {
	    VDpdmPostTableTimestamp(tbl_list[i]);
	}

	// free up the Table List CR 4474
	VDChkFreeTableList();
/*
        status = VDprd_postObjects( &msg, REG_CHECKIN, to_sql,
				    current_cat, current_nam,
                                    current_rev, designRep,
                                    &delete );
        CheckRC( status, msg ); 
*/
        
//quit: 

        __DBGpr_com( "Freeing the memory" );
        if (count > 0)
		_FREE (p_obj_info_1);

	if (p_file != (FILE *)stdout ) fclose (p_file);

	_FREE(p_obj_list);
        End
	return (status);
}

end implementation ACdb_info ;
