//	include file :	mdu_data.h
//	Author       :  J.H.Kidd	13 Dec 1989
//
//
//	Description:	This include file contains structure definitions and
//			function declarations that are used in the ppl programs
//			that control the mdu/mdc interface

//	First some include file dependencies:

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exmacros.h"

extern  DIcd(),EX_get_global(),DIstart_find(),DIfetch_find();

//	Declaration of a structure type for the mdc header info

struct UDtype
{
	char	mdcflag[4];	// =ON or OFF - indicates recognition by BOM etc
	char	part[17];	// part number
	char	desc[41];	// description
	char	mat[26];	// material
	char	dim[26];	// dimension
	int	qty;		// quantity
};

//************************************************************************
// function to request a string from the user providing a default

// this is done with a getevent call, the response is returned to main program

mdu_string( str1, strp )
char	*str1;
char	*strp;
{
char	str2[80],str3[80];
struct	GRevent	event1;

mdustart:
	strcpy(str2,"default =");
	strcat(str2,str1);
	message( str2 );
	strcpy(str2,strp);
	strcat(str2," / MOVE_ON");
	ci$getevent( event = &event1, prompt = str2 );

	if ( event1.response == D_RESET )
	{
		message(" ");
		return D_RESET;
	}
	else if ( event1.response == RESET )
	{
		message(" ");
		return RESET;
	}
	else if ( event1.response == STRING || event1.response == VALUE )
	{
		message(" ");
		if( strcmp(event1.event.keyin,"") )
			strcpy(str1,event1.event.keyin);
		return STRING;
	}
	else
	{
		message("Invalid entry");
		goto mdustart;
	}


}

// **************************************************************************
// 	Function to place the mdu heqader info in the design file

//	Example function call:

//	sts = mdu_place( objid , struct_data );

//		where:	objid = object id of group/cell/ref file
//			struct_data is a structure of type UDtype

//			sts = 1		if successful
//			    = 0		if failed

mdu_place( mduobj , UDdata )
GRobj	mduobj;
struct	UDtype	UDdata;
{
GRobj		UDobj;			// User Data obj id
char		UDexp[10];		// User Data template expression
char		UDname[60];		// User Data name for creation
char		topdir[20];		// top dir pathname
GRobj           EXECUTOR;               /* object of class "ci_executor" */
int             sts, i, num, size;	/* mere status */
char		fname[80];

struct	UDtype	*UDp;
struct  EX_var_list	gv;
struct	GRmd_env mod_env1;

	// Obtain obj id from user data name
	// this is also tests if user data already exists for this object

	size = sizeof(fname);
	gv.var = EX_CUR_FILENAME;
	gv.var_value = fname;
	gv.num_bytes = &size;
	ex$global( mode = EX_INQ, var = &gv, which_error = &sts );

	strcpy(topdir,":");
	strcat(topdir,fname);
	strcat(topdir,":usr:mdc");

	strcpy( UDexp , "mdu" );
	strcat( UDexp , itoa( (int)mduobj ) );
	strcat( UDexp , "*" );

	// test if user data already exists for this object - use search

	sts = di$start_find( start_dir = topdir,
				ptr = &num,
				regexp = UDexp );

	if( sts == DIR_S_SUCCESS )
	{
		// data exists - tell user and exit program

		write( "Object already in mdc - use mdu_edit.u to edit data\n");
		return 0;
	}
	else
	{
		// create user data entry

		ci$send( msg = message user_data.set_data 
               		( sizeof(struct UDtype), &UDdata),
	 		targetid = UDobj,
	 		construct = 1 );

                strcpy( UDname , "mdu" );
                strcat( UDname , itoa( (int)mduobj ) );
//******
		num = 9 - strlen( UDname );
		for( i=0 ; i<num ; i=i+1 )
			strcat( UDname , "." );
	
		strcat( UDname , UDdata.part );

		num = 27 - strlen( UDname );
		for( i=0 ; i<num ; i=i+1 )
			strcat( UDname , "." );
	
		strcat( UDname , itoa( UDdata.qty ) );

		num = 32 - strlen( UDname );
		for( i=0 ; i<num ; i=i+1 )
			strcat( UDname , "." );
	
		strcat( UDname , UDdata.mdcflag );
//******

                sts = di$add_name( objname = UDname,
				path = topdir,
                                objid = UDobj );

		if( sts == DIR_S_SUCCESS )
		{
			write( "successful add " );
		}
		else
		{

			strcpy(topdir,":");
			strcat(topdir,fname);
			strcat(topdir,":usr");

			sts = di$cd( dirname = topdir );
			if( sts != DIR_S_SUCCESS )
			{
				write( "error changing to top directory\n\n");
				exit;
			}
			sts = di$mkdir( dirname = "mdc" );
			if( sts != DIR_S_SUCCESS )
			{
				write( "error in creating mdc directory\n\n");
				exit;
			}

			strcat(topdir,":mdc");

                	sts = di$add_name( objname = UDname,
					path = topdir,
                                	objid = UDobj );

			if( sts == DIR_S_SUCCESS )
				write( "successful add " );
			else
				write( "error in adding user data name");
		}

		write("user_data ", UDname," has been created\n");

       		// Create the "listening" object
		// attach it to the CI file
       		// & link it to the graphic object.

        	ci$get_module_info(md_env = &mod_env1);

		if ( ci$send(msg = message ci_executor.CI_ex_load
			( mod_env1.md_id.osnum, mduobj, 
				mod_env1.md_id.osnum, UDobj, 
				"mdu_ex", &sts ),
       			targetid = EXECUTOR,
       			targetos = 2,
       			construct = 1 ) && sts )
		{
  			status( "" );
			return 1;
		}
		else
		{
  			status( "Error - CI file not attached" );
  			write( "Error - CI file not attached\n" );
			return 0;
		}
	}
}

// **************************************************************************

// function to edit the contents of user data structure

// argument to functio is a pointer to structure ot type UDtype

// return status = 1 for success , = 0 for failure / reject selected

mdu_edit( UDp )
struct	UDtype	*UDp;
{
int	resp;
char	str1[80];
int	i1;
struct	GRevent	event2;

mdus1:	strcpy(str1, UDp->mdcflag );
	resp =  mdu_string( str1 , "Enter mdc status (ON/OFF)" );

	if( resp == D_RESET ) return 0;
	if( strcmp(str1,"ON") && strcmp(str1,"OFF") ) goto mdus1;
	strcpy(UDp->mdcflag , str1 );


mdus2:	strcpy(str1, UDp->part );
	resp =  mdu_string( str1 , "Enter part number" );

	if( resp == D_RESET ) goto mdus1;
	if( strlen(str1)>16 )
	{
		status("string too long (max =16)");
		goto mdus2;
	}
	status("");
	strcpy(UDp->part , str1 );


mdus3:	strcpy(str1, UDp->desc );
	resp =  mdu_string( str1 , "Enter part description" );

	if( resp == D_RESET )
		goto mdus2;
	if( strlen(str1)>40 )
	{
		status("string too long (max = 40)");
		goto mdus3;
	}
	status("");
	strcpy(UDp->desc , str1 );


mdus4:	strcpy(str1, UDp->mat );
	resp =  mdu_string( str1 , "Enter part material" );

	if( resp == D_RESET )
		goto mdus3;
	if( strlen(str1)>25 )
	{
		status("string too long (max = 25)");
		goto mdus4;
	}
	status("");
	strcpy(UDp->mat , str1 );


mdus5:	strcpy(str1, UDp->dim );
	resp =  mdu_string( str1 , "Enter part dimension" );

	if( resp == D_RESET )
		goto mdus4;
	if( strlen(str1)>25 )
	{
		status("string too long (max = 25)");
		goto mdus5;
	}
	status("");
	strcpy(UDp->dim , str1 );


mdus6:	strcpy(str1, itoa(UDp->qty) );
	resp =  mdu_string( str1 , "Enter part quantity" );

	if( resp == D_RESET ) goto mdus5;
	if( atoi(str1)==0 )
		goto mdus6;
	else
		UDp->qty = atoi( str1 );

	return 1;

}


//***************************************************************************
// function to check if an object already has mdc user data attached
//
//	Argument = object id
//
//	Returns =	1 for data attached
//			0 for no data attached

mdu_check( mduobj )
GRobj	mduobj;
{
struct	GRid 	UDobj;			/* User Data obj data */
char		UDexp[20];		/* User Data name */
int             size,sts,num;		/* mere status */
char		topdir[20],fname[20];

struct 		EX_var_list	gv;


	size = sizeof(fname);
	gv.var = EX_CUR_FILENAME;
	gv.var_value = fname;
	gv.num_bytes = &size;
	ex$global( mode = EX_INQ, var = &gv, which_error = &sts );

	strcpy(topdir,":");
	strcat(topdir,fname);
	strcat(topdir,":usr:mdc");

	strcpy( UDexp , "mdu" );
	strcat( UDexp , itoa( (int)mduobj ) );
	strcat( UDexp , "*" );

	// test if user data already exists for this object - use search

	sts = di$start_find( start_dir = topdir,
				ptr = &num,
				regexp = UDexp );

	if( sts == DIR_S_SUCCESS )
	{
		write("num = ",num);
		sts = di$fetch_find( line = UDexp ,
					index = 0 ,
					p_grid = &UDobj );
		write("obj name = ",UDexp,"objid = ",UDobj.objid,"\n");
		return 1;
	}
	else
	{
		return 0;
	}

}
