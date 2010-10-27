/* $Id: VDPrjPart.C,v 1.2 2001/03/20 19:00:19 jdsauby Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/func / VDPrjPart.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDPrjPart.C,v $
 *	Revision 1.2  2001/03/20 19:00:19  jdsauby
 *	Re-imported from service pack into CVS
 *	
 * Revision 1.2  2000/07/10  19:46:38  pinnacle
 * Replaced: vds/vdcheckin/func/VDPrjPart.C for:  by apazhani for Service Pack
 *
 * Revision 1.4  1999/01/28  20:21:58  pinnacle
 * Replaced: vdcheckin/func/VDPrjPart.C for:  by lawaddel for vds
 *
 * Revision 1.3  1999/01/19  17:36:58  pinnacle
 * Replaced: vdcheckin/func/VDPrjPart.C for:  by apazhani for vds
 *
 * Revision 1.2  1998/10/08  16:50:46  pinnacle
 * Replaced: vdcheckin/func/VDPrjPart.C for:  by apazhani for vds
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.5  1998/04/17  18:04:50  pinnacle
 * TR179800996
 *
 * Revision 1.4  1997/11/21  11:49:04  pinnacle
 * Replaced: vdcheckin/func/VDPrjPart.C for:  by svkadamb for vds
 *
 * Revision 1.3  1997/10/27  09:29:34  pinnacle
 * Replaced: vdcheckin/func/VDPrjPart.C for:  by apazhani for vds
 *
 * Revision 1.2  1997/10/15  10:55:00  pinnacle
 * Replaced: vdcheckin/func/VDPrjPart.C for:  by apazhani for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/05/03  15:43:32  pinnacle
 * Replaced: vdcheckin/func/VDPrjPart.C for:  by sljenks for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/30/96        slj		Removed listings for tables that
 *					were removed in 2.4 schema.
 *					 - vds_connection, sch_pid_dynamic,
 *					 - schpidnoz_dynamic, sch_eqp_dyanamic,
 *					 - sch_eqp_dynamic, sch_hvac_dynamic,
 *					 - elec_dynamic, sch_elec_dynamic,
 *					 - foptic_dynamic, sch_foptic_dynamic,
 *					 - sch_hvnoz_dynamic, sch_elterm_dynamic
 *					 - elterm_dynamic
 *	05/01/96	slj		Removed date information from 
 *					VDS_PROJECT_PARTS insert function.
 *	10/15/97        Alwin           Added some tables for the cleanup in
 *                                      the function "VDDeleteDynamicTbls"
 *                                      which are related to CABLE product.
 *                                      ( for TR179701824 )
 *	10/26/97        Alwin           Added CABLE relates tables for the
 *                                      cleanup operation before posting.
 *      04/17/98        ah              TR179800996 Removed warning messages while
 *                                      deleting from ris tables
 *      10/08/98        Alwin           Added CABLE lead tables for the cleanup
 *                                      operation before posting. TR179801987
 *      01/19/99        Alwin           Added CABLE Jumper tables for the
 *                                      cleanup operation.
 *      01/28/99        law             CR179802489-add lead tables
 *      06/01/00        Alwin           Added PID PIPING/HVAC tables for the 
 *					cleanup operation. CR179901521
 *      07/10/00        Alwin           Added Rway Nozzle table in list of 
 *					tables to be cleaned up.
 * -------------------------------------------------------------------*/

/* VDPrjpart.C */
#include 	<stdio.h>

#include 	"OMtypes.h"
#include  	"OMerrordef.h"
#include  	"OMminimum.h"
#include  	"OMprimitives.h"
#include  	"igrtypedef.h"
#include  	"igetypedef.h"
#include  	"gr.h"
#include  	"godef.h"
#include  	"igr.h"
#include 	"VDSris_def.h"
#include 	"VDScheckdef.h"
#include 	"VDScheckin.h"
#include 	"ACcheckin.h"
#include 	"vdbmacros.h"
#include 	"v_dbgmacros.h"

#define	 boolean	short

/* The function VDAddPartToProject adds a part to a PROJECT specified */
/* Removed data information as it is no longer in the table. slj 5/1/96 */
int	VDAddPartToProject( proj_num, 
			    proj_rev, 
			    assembly_cat, 
			    assembly_nam, 
			    assembly_ver)
char		*proj_num; 			/* I */
char		*proj_rev; 			/* I */
char		*assembly_cat; 			/* I */
char		*assembly_nam; 			/* I */
char		*assembly_ver; 			/* I */
{
	char		*table="VDS_PROJECT_PARTS";
	char		where[300];
	char		*select="assembly_ver";
	char		**buf;
	char		tmp_str[15];
	int		i, status, num, columns=5;
	int		col_typ[5];
	char		*col_value[5];
	char		TMPSTRING[6*30];
	boolean 	found=FALSE;

	/* Verify if the project revison is NULL or not */

	for(i=0; i<columns; i++ ) col_value[i] = &TMPSTRING[i*30];

	if( strcmp(proj_rev,"NULL"))
	{
	   strcpy(tmp_str,proj_rev);
	   if( strcmp( proj_rev, assembly_ver ))
	   {
	     /*------------------------------------------------------------------------
	      * TR179800996 Not sure about the reasoning behind this warning
	      * Part revs really should not be required to match project revs
	      * or maybe they should
	      *
	      * In any event, a mismatch does not seem to be a problem
	      * so suppress for now.
	      */
	     //UI_status("Warning: different project version and assembly version");
	     //printf("Warning: different project version and assembly version\n");
	   }
	   sprintf(where,
		   "prj_number='%s' and prj_version ='%s' and assembly_cat='%s' and assembly_nam='%s'", proj_num, proj_rev, assembly_cat, assembly_nam);
	}
	else
	{
	   strcpy(tmp_str,"");
	   sprintf(where,
		   "prj_number='%s' and assembly_cat='%s' and assembly_nam='%s'", proj_num, assembly_cat, assembly_nam);
	}

	status = vdb$RisSelect (select 		= select, 
				table_name 	= table, 
				where 		= where, 	
				numselect 	= 1,
				p_numrows 	= &num, 
				p_buffer 	= &buf); 
	if(status != 1 )
	   { vdb$RisFreeBuffer( buffer = buf, size = num ); return 0; }  /* Bad Query */

	if( num == 0)   	/* No previous occurences */
	   found = FALSE;
	else			/* found previous occurences  */
	{
	   for ( i = 0; i < num; i++ )
	     if(!strcmp(buf[i],assembly_ver))
	     {
	        found = TRUE;
	   	sprintf(where,
		   "prj_number='%s' and assembly_cat='%s' and assembly_nam='%s' and assembly_ver ='%s'", proj_num, assembly_cat, assembly_nam, assembly_ver);
	   	vdb$RisDelete ( table_name = "VDS_PROJECT_PARTS",
				where = where ); 
	     }
	}
	vdb$RisFreeBuffer( buffer = buf,size =  num );

	col_typ[0] = col_typ[1] = col_typ[2] = col_typ[3] = col_typ[4] = CHAR;

	strcpy( col_value[0], proj_num);
	strcpy( col_value[1], tmp_str);    /* tmp_str holds the proj_rev */
	strcpy( col_value[2], assembly_cat);
	strcpy( col_value[3], assembly_nam);
	strcpy( col_value[4], assembly_ver);

	if(!VdsSqlInsert( table, columns, col_typ, col_value))
	      return 0;

	return 1;
}


/* This function posts to the database the information contained in row. */
/* The table name to post is already concatenated with DYNAMIC.          */

int VdsPostDb (key, catalog, partnum, partrev, table,
	        number, datatype, row, p_delete, to_sql, sqlfile)
	char		*key;		/*	I	*/
	char		*catalog;	/*	I	*/
	char		*partnum;	/*	I	*/
	char		*partrev;	/*	I	*/
	char		*table;		/*	I	*/
	int		number;		/*	I	*/
	char		**datatype;	/*	I	*/
	char		*row;		/*	I	*/
	int		*p_delete;	/*	I/O	*/
        int             to_sql;         /* To post to DB or
                                           an SQL file I */
        FILE            *sqlfile;       /*      I       */


/*.VdsPostDb*/
{
 	int		status = SUCCESS;
	int		delete = DELETE_N;
	int		print = PRINT_N;

       if( to_sql != 1)
       {
	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) return FAILURE;
       }

       if( to_sql != 1)
       {
	if ((*p_delete) == DELETE_Y)
	  {
 	   /*|Delete existing rows */
 	   status = VdsDeleteRows ( key, table, catalog, partnum, partrev);
 	   if (status != SUCCESS)
  	     {
   	      printf ( "VdsDeleteRows returns %d\n", status);
   	      goto quit;
  	     }
	   *p_delete = DELETE_N;
  	  }
       }

 	/*|Insert rows */
 	status = VdsInsertRows ( table,
				 number,
				 datatype,
				 (int *) NULL,
				 row,
				 &delete,
				 &print,
				 to_sql,
				 sqlfile );
 	if (status != SUCCESS)
  	  {
   	   printf ( "VdsInsertRows returns %d\n", status);
   	   goto quit;
  	  }

quit:
	return status;
}

/* ----------------------------------------------------------------------
 * TR179800996 Getting warning messages when a table did not exist
 * Many new tables have not yet been added to existing databases
 * resulting in some confusion
 * So, just comment out the warning messages
 */
int VDDeleteDynamicTbls(assembly_cat, assembly_nam, assembly_rev)
char	*assembly_cat;
char	*assembly_nam;
char	*assembly_rev;
{
	char	table[20];
	char	where[200];
	int	status;

        SetProc( VDDeleteDynamicTbls ); Begin

        __DBGpr_com(" Deleting all the Dynamic Tables" );

	sprintf( where,"assembly_cat = '%s' and assembly_nam = '%s' and assembly_ver = '%s' ",
		  assembly_cat, assembly_nam, assembly_rev);

        __DBGpr_com( "Deleting piping_pid_dyn...");
	strcpy(table,VD_CKTB_PID_PIPING);
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting piping_pid_noz_dyn...");
	strcpy(table,VD_CKTB_PIP_PID_NOZ);
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting hvac_pid_dyn...");
	strcpy(table,VD_CKTB_PID_HVAC);
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting hvac_pid_noz_dyn...");
	strcpy(table,VD_CKTB_HV_PID_NOZ);
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting piping_dynamic ...");
	strcpy(table,"piping_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting piping_noz_dynamic ...");
	strcpy(table,"piping_noz_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting piping_sup_dynamic ...");
	strcpy(table,"piping_sup_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting hvac_dynamic ...");
	strcpy(table,"hvac_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting hvac_noz_dynamic ...");
	strcpy(table,"hvac_noz_dynamic");
	status = vdb$RisDelete (table_name = table, where =where );

        __DBGpr_com( "Deleting rway_dynamic ...");
	strcpy(table,"rway_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting rway_noz_dynamic ...");
	strcpy( table, VD_CKTB_RWAY_NOZ );
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting struct_bm_dynamic ...");
	strcpy(table,"struct_bm_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting struct_pl_dynamic ...");
	strcpy(table,"struct_pl_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting struct_jn_dynamic ...");
	strcpy(table,"struct_jn_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting equip_dynamic ...");
	strcpy(table,"equip_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting compart_dynamic ...");
	strcpy(table,"compart_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting surf_dynamic ...");
	strcpy(table,"surf_dynamic");
	status = vdb$RisDelete (table_name = table, where = where );

        /********* SCHEMATIC REPRESENTATION *******************/

        __DBGpr_com( "Deleting vrsch_equip_dyn ...");
	strcpy(table,"vrsch_equip_dyn");
	status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting vcsch_eterm ...");
        strcpy(table,"vcsch_eterm");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcsch_fterm ...");
        strcpy(table,"vcsch_fterm");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcsch_ecable ...");
        strcpy(table,"vcsch_ecable");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcsch_fcable ...");
        strcpy(table,"vcsch_fcable");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcsch_guide ...");
        strcpy(table,"vcsch_guide");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcsch_ebkshell ...");
        strcpy(table,"vcsch_ebkshell");
        status = vdb$RisDelete (table_name = table, where = where );

        /********* MODEL REPRESENTATION *******************/

        __DBGpr_com( "Deleting vcdyn_eterm ...");
        strcpy(table,"vcdyn_eterm");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcdyn_fterm ...");
        strcpy(table,"vcdyn_fterm");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcdyn_fcable ...");
        strcpy(table,"vcdyn_fcable");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcdyn_ecable ...");
        strcpy(table,"vcdyn_ecable");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcdyn_guide ...");
        strcpy(table,"vcdyn_guide");
        status = vdb$RisDelete (table_name = table, where = where );
 
        __DBGpr_com( "Deleting vcdyn_ebkshell ...");
        strcpy(table,"vcdyn_ebkshell");
        status = vdb$RisDelete (table_name = table, where = where );

        /* The Cable Lead tables are also added for the intial deleting.
        Previously this was carried out in the VCCpost.I file of the Cable
        object. Alwin for TR179801987*/

	/* Table name changed from vcdyn_elead -> vcsch_elead. CR179802489 */
        __DBGpr_com( "Deleting vcsch_elead ...");
        strcpy(table,"vcsch_elead");
        status = vdb$RisDelete (table_name = table, where = where );

	/* Table name changed from vcdyn_flead -> vcsch_flead. CR179802489 */
        __DBGpr_com( "Deleting vcsch_flead ...");
        strcpy(table,"vcsch_flead");
        status = vdb$RisDelete (table_name = table, where = where );

        /* Cleaning up the Jumper Tables. Alwin */

        __DBGpr_com( "Deleting vcsch_jump ...");
        strcpy(table,"vcsch_jump");
        status = vdb$RisDelete (table_name = table, where = where );

        __DBGpr_com( "Deleting vcsch_jmploc ...");
        strcpy(table,"vcsch_jmploc");
        status = vdb$RisDelete (table_name = table, where = where );

        /* Cleaning up the Jumper Tables. Alwin */

        End
	return 1;

}
/******************************************************************************/








