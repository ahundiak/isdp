/* $Id: VDrtpostdb.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / VDrtpostdb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrtpostdb.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/02/08  19:09:34  pinnacle
# Replaced: vdroot/VDrtpostdb.I for:  by lawaddel for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/05/10  13:36:14  pinnacle
# Replaced: vdroot/VDrtpostdb.I for:  by sljenks for vds.240
#
# Revision 1.2  1996/05/08  18:02:22  pinnacle
# Replaced: vdroot/VDrtpostdb.I for:  by sljenks for vds.240
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
 *	05/07/96	slj		changed to VDS _FREE, added
 *					one exit point, and _FREE(VdsCatalogs)
 *					to free used memory.
 *	05/10/96	slj		moved p_file initialization, added
 *					debugging statements
 *      01/28/99        law             CR179802489-Added posting object
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "PDUerror.h"
#include "exmacros.h"
#include "VDSpdudef.h"
#include "vdbmacros.h"
#include "PDUuser.h"
#include "VDScheckin.h"
#include "VDSris_def.h"
#include "exdef.h"
#include "exmacros.h"
#include "madef.h"
#include "igetypedef.h"
#include "VDSris_siz.h"
#include "vdbmacros.h"
#include "v_dbgmacros.h"
#include "VDmem.h"
#include "VDScheckdef.h"
#include "v_dbgmacros.h"
/*  from   VRpost  import   VRGetCompSeqNo;  */
#define SUCCESS	1

extern int			VD_PDU_present;
extern struct PDUuser		*user;
extern struct PDUrefresh	*refresh;

method VDPostYourselfToDb( long *msg;		/* O */
			   char *key;		/* I */
			   int  to_sql;		/* I */
			   char *catalog;	/* I */
			   char *partid;	/* I */
			   char *revision;	/* I */
			   char *designRep;	/* I */
			   int  *delete;	/* I/O */
			  )
{
  char logfile[50];
  char pdc_table[MAXWORD];
  char row[MAX_ROW_CHAR];
  char dynamic_table[MAXWORD];
  int  ind, jj;
  int  prepare;
  int  sts;
  int  DelConnRecords;
  int  nbCatalogs;
  long messg;
  struct table_attr pdc_attr;
  struct GRmd_env mod_env;
  struct ACobj_info_1 obj_info_1;
  struct GRid thisObject;
  struct vdscatalog *VdsCatalogs = NULL;
  FILE *p_file = NULL, *sql_file = NULL;

  SetProc (VDPostYourselfToDb); Begin


  *msg = MSSUCC;
  sts = MSSUCC;
  p_file   = NULL;
  sql_file = NULL;


  dynamic_table[0] = '\0';
  row[0] = '\0';

  __DBGpr_com ("VDSverify_login");
  if( VDSverify_login() != PDM_S_SUCCESS )
  {
    UI_status( "User not logged in to Database" );
    sts = MSFAIL;
    goto wrapup;
  }

  __DBGpr_com ("Determine post type");
  __DBGpr_str ("key = ", key);
  __DBGpr_str ("REG_CHECKIN = ", REG_CHECKIN);
  /* regular or drawing checkin? */
  if( strcmp( key, REG_CHECKIN ) == 0 )
  {
    strcpy( logfile, "VDSreg_chk.log" );
  }
  else if( strcmp(key, DWG_CHECKIN) == 0 )
  {
    strcpy( logfile, "VDSdwg_chk.log" );
  }
  else
  {
    printf( "Unknown key : <%s> for VDS checkin\n", key );
    sts = MSFAIL;
    goto wrapup;
  }

  __DBGpr_str(" LogFile ", logfile );

  /* Initialization */
  ind		 = -1;
  DelConnRecords = DELETE_N;

  pdc_attr.type			= 0;
  pdc_attr.feet_list		= NULL;
  pdc_attr.format_list		= NULL;
  pdc_attr.table_name[0]	= '\0';
  prepare			= PREPARE_Y;

  p_file = (FILE *)fopen( logfile, "w+" );
  if( p_file == NULL )
  {
    p_file = (FILE *)stdout;
  }

  sql_file = (FILE *)fopen( "post.sql", "w" );

  if( sql_file == NULL )
   printf( "Cannot open file <%s>.\n", "post.sql" );

  ex$get_cur_mod( id    = &mod_env.md_id.objid,
                  osnum = &mod_env.md_id.osnum );

  mod_env.md_env.matrix_type = MAIDMX; /* Used for ACgive_structure */
  MAidmx( &messg, mod_env.md_env.matrix );


  thisObject.objid = my_id;
  thisObject.osnum = OM_Gw_current_OS;

  __DBGpr_obj("getting db_info",thisObject);
  sts = VdsGet_db_info( &thisObject, &obj_info_1, 1 );

  __DBGpr_com("back from VdsGet_db_info");
  fprintf( p_file, "PROCESSING %d\n", thisObject.objid );
  fflush( p_file );

  /* This is no longer valid in 2.4 - slj 5/9/96 */
  /*
  sts = VDPostConnectionInfo( catalog, partid, revision,
			      obj_info_1.quantity, mod_env,
                              thisObject, &DelConnRecords );

  if( sts != SUCCESS )
  {
    fprintf( p_file,
    "Error, cannot post connectivity info for Object: %d, Quantity: %d \n",
    thisObject.objid, obj_info_1.quantity );
    fflush( p_file );
  }
  */

  __DBGpr_com("VDReadVdsCatalogs");
  sts = VDReadVdsCatalogs( &nbCatalogs, &VdsCatalogs );

  __DBGpr_com("VDGetDynTableName");
  sts = VDGetDynTableName( obj_info_1.quantity, thisObject, mod_env,
                           key, designRep, nbCatalogs, VdsCatalogs,
                           dynamic_table );

  if( sts == VDS_E_DYNAMIC_TABLE_NOT_FOUND ||
      (dynamic_table == NULL) )
   {
     sts = MSFAIL;
     goto wrapup;
   }

  strcpy( pdc_attr.table_name, dynamic_table );

  __DBGpr_com(" Call vdb$RetrieveAttributes ");
  sts = vdb$RetrieveAttributes( table_name = dynamic_table /*pdc_table*/,
                                p_num      = &pdc_attr.nb_feet,
                                p_attr     = &pdc_attr.feet_list,
                                p_type     = &pdc_attr.format_list );
  if( sts != SUCCESS )
  {
    fprintf( p_file,
             "Unable to retrieve database schema for table <%s>\n", pdc_table);
    fprintf( p_file,
       "All objects checking in to this table will be ignored for check-in.\n");
    fflush( p_file );
    sts = MSFAIL;
    goto wrapup;
  }

    {
  struct {
    IGRlong     *suc;
    struct GRid *mp;
  } msgArgs;

    struct GRid comp_id;
    IGRchar classname[256];
    IGRlong retmsg;
    OM_S_MESSAGE msgMass;

      om$get_classname( objid = my_id, classname = classname);
      __DBGpr_int("obj being processed",my_id);
      __DBGpr_str("class of object",classname);
      if ( 1 == om$is_ancestry_valid( subclassname   = classname,
                                     superclassname = "VRpost") )
      {
         msgArgs.suc = &retmsg;
         msgArgs.mp  = &comp_id;
         sts = om$make_message(
            classname  = "VRpost",
            methodname = "VRGetCompSeqNo",
            size       = sizeof(msgArgs),
            p_arglist  = &msgArgs,
            p_msg      = &msgMass);

         __DBGpr_com("VRpost object detected");
         sts= om$send( msg    = &msgMass,
                     targetid = my_id);
         __DBGpr_obj("cable object ",comp_id);
         obj_info_1.serial_no = comp_id.objid;
      }
    }
  pdc_attr.type = obj_info_1.quantity;
  sts = VdsFillRow( obj_info_1, row, thisObject, mod_env, pdc_attr,
		    0, catalog, partid, revision, key, p_file );
  if( pdc_attr.table_name[0] != '\0' )
  {
    __DBGpr_com("VdsPostDb");
  __DBGpr_com("VdsFillRow");
  __DBGpr_int("db table id",obj_info_1.quantity);
  __DBGpr_str("row sent to db",row);
    sts = VdsPostDb( key, catalog, partid, revision, pdc_attr.table_name,
                     pdc_attr.nb_feet, pdc_attr.format_list, row,
                     delete, to_sql, sql_file );

    if( sts != SUCCESS )
    {
     fprintf( p_file, "Error, cannot fill the database table: %s%s\n",
              pdc_attr.table_name, key );
     fflush( p_file ) ;
    }
  }

wrapup:

  __DBGpr_com("In VDPostYourselfToDb wrapup");

  if( pdc_attr.feet_list != NULL )
  {
    for( jj = 0; jj < pdc_attr.nb_feet; ++jj )
    {
      if( pdc_attr.feet_list[jj] != NULL )
       _FREE( pdc_attr.feet_list[jj] );

      if( pdc_attr.format_list[jj] != NULL )
       _FREE( pdc_attr.format_list[jj] ) ;
    }

    _FREE( pdc_attr.feet_list );
    _FREE( pdc_attr.format_list );
  }

  __DBGpr_com("After _FREE of pdc_attr");

  _FREE(VdsCatalogs);

  __DBGpr_com("After _FREE of VdsCatalogs");

  if( p_file != (FILE *)stdout )
   fclose( p_file );

  if( sql_file != NULL )
   fclose( sql_file );

  End

  return (sts);

}

end implementation VDSroot;
