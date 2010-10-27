/* $Id: VDpktInit.C,v 1.3 2001/08/30 19:31:28 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/func / VDpktInit.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDpktInit.C,v $
 *	Revision 1.3  2001/08/30 19:31:28  ramarao
 *	Added functionality to add command keys to the pocket menu.
 *	
 *	Revision 1.2  2001/01/19 22:37:55  jayadev
 *	*** empty log message ***
 *	
 * Revision 1.1  2000/06/29  20:49:30  pinnacle
 * Created: vds/vdpocket/func/VDpktInit.C by rchennup for Service Pack
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/12/30  17:17:08  pinnacle
 * Added symbol 32 for "Select Assembly Components" command (VDSlAsCp)
 *
 * Revision 1.2  1997/12/18  21:49:44  pinnacle
 * for testing Select Assembly Components command, added { FI_CMD_KEY,   "VDSlAsCp", "SMfrm.sym", 15 },
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.4  1995/06/27  18:35:44  pinnacle
 * Replaced: vdpocket/func/VDpktInit.C for:  by azuurhou for vds.240
 *
 * Revision 1.3  1995/05/01  16:28:28  pinnacle
 * Replace: vdpocket/func/VDpktInit.C by azuurhou for OPE
 *
 * Revision 1.2  1994/12/09  16:22:40  pinnacle
 * Replaced:  vdpocket/func/VDpktInit.C r#
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
 *	04/28//95	adz		Reorganize the icons.
 *	12/30/97 	ejm		Added symbol 32 for "Select Assembly
 *					Components" command (VDSlAsCp).
 * -------------------------------------------------------------------*/

#include "OMerrordef.h"
#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "msdef.h"
#include "exmacros.h"

#include "vdpktdef.h"
#include "vdpktmacros.h"

#ifndef _SYS_STAT_H
#       include <sys/stat.h>
#endif

static int VDpocketReadFile( IGRchar	*file_name, int  load )
{
int		comma_cnt;
char	   	str_buf[1024], command_type[256], command_string[256],
		symbol_file[256], symbol_no[256], *p=NULL;
FILE          	*pocket_file=NULL;
struct VDpktGadgets 	pkt_list[2];

   pocket_file = fopen( file_name, "r" );   
   if( pocket_file == NULL ) return 0;

   while( fgets( str_buf, sizeof(str_buf), pocket_file ) )
   {
       if( str_buf[0] == '#' )  continue;
       for( comma_cnt=0, p=str_buf; *p != '\0'; ++p )
	 if( *p == ',' )   comma_cnt++;

       if( comma_cnt != 3 ) continue;

       command_type[0] = command_string[0] = 
	       symbol_file[0] = symbol_no[0] = '\0' ;

       sscanf( str_buf, "%[^,],%[^,], %[^,], %s\n", 
		       	command_type, command_string,
			symbol_file, symbol_no );

       if( command_type[0] == '\0' || command_string[0] == '\0' ||
	   symbol_file[0] == '\0' || symbol_no[0] == '\0' )
       {
	  continue;
       }
       if( !strcmp( command_type, "KEY" ) )   
	    pkt_list[0].type_cmd = FI_CMD_KEY ;
       else if( !strcmp( command_type, "STRING" ) )
            pkt_list[0].type_cmd = FI_CMD_STRING ;	
       else continue;

       pkt_list[0].cmd = strdup( command_string );
       pkt_list[0].sym_file = strdup( symbol_file );
       pkt_list[0].sym_index = atoi( symbol_no );

       pkt_list[1].type_cmd = VDPKT_ENDLIST;

       if( load )
       {
	  vd$pkt_add_gadgets( gadgets = pkt_list );
       }
       else
       {
	  vd$pkt_del_gadgets( gadgets = pkt_list );
       }
   }

wrapup:
   fclose( pocket_file );
   return 1;
}

static int	VDloadPocketGadgets( int load )
{
int			i;
long			msg;
char			dir[1024], try[1024], fileToFind[1024];
struct stat 		fs ;

   strcpy( fileToFind, "pocketEntries" );

   sprintf( try, "./%s", fileToFind ) ;
   if( stat( try, &fs ) == 0 && S_ISREG( fs.st_mode ) )
       VDpocketReadFile( try, load );

   sprintf( try, "%s/%s",  "config/english/pocket", fileToFind ) ;

   for( i = 0 ; ; i++ ) 
   {
       if( !ex$get_path( index = i,
                         path  = dir,
                         len   = sizeof( dir ) )
           || !*dir ) 
       {
           break ;
       }
       strcat( dir, try ) ;
       if( stat( dir, &fs ) == 0 && S_ISREG( fs.st_mode ) ) 
       {
          /*
           * Found it !
           */
          VDpocketReadFile( dir, load );
       } 
   } 

   return 1;
}

/*----------------------------------------------------------------------------*/
int SMAddToPocketMenu()
/*.SMAddToPocketMenu*/
{
static struct VDpktGadgets SMlist[] = {
	{ FI_CMD_KEY,     "SMPsHl", "SMfrm.sym", 13 },
	{ FI_CMD_KEY,   "VDQrySel", "SMfrm.sym", 18 },
	{ FI_CMD_KEY,   "VDPushCs", "SMfrm.sym", 19 },
	{ FI_CMD_KEY, "VDElBndSol", "SMfrm.sym", 28 },
	{ FI_CMD_KEY,  "VDElBndMV", "SMfrm.sym", 29 },
	{ FI_CMD_KEY,  "VDPushDrw", "SMfrm.sym", 30 },
	{ FI_CMD_KEY,   "VDSlAsCp", "SMfrm.sym", 32 },
	{ FI_CMD_KEY,    "GRSlAlF", "SMfrm.sym", 34 },
	{ -1	    ,           0 ,          0 ,  0 } };

int	sts = MSSUCC;

  /*
   * Add gadgets to default pocket menu.
   */
  sts = vd$pkt_add_gadgets(	gadgets	= SMlist );

  sts = VDloadPocketGadgets(1);

  sts = vd$pkt_menu( );

  return OM_S_SUCCESS;
  
} /* end SMAddToPocketMenu */

/*----------------------------------------------------------------------------*/
int SMDelToPocketMenu()
/*.SMDelToPocketMenu*/
{
static struct VDpktGadgets SMlist[] = {
	{ FI_CMD_KEY,     "SMPsHl", "SMfrm.sym", 13 },
	{ FI_CMD_KEY,      "Query", "SMfrm.sym", 18 },
	{ FI_CMD_KEY,   "VDPushCs", "SMfrm.sym", 19 },
	{ FI_CMD_KEY, "VDElBndSol", "SMfrm.sym", 28 },
	{ FI_CMD_KEY,  "VDElBndMV", "SMfrm.sym", 29 },
	{ FI_CMD_KEY,  "VDPushDrw", "SMfrm.sym", 30 },
	{ FI_CMD_KEY,   "VDSlAsCp", "SMfrm.sym", 32 },
	{ FI_CMD_KEY,    "GRSlAlF", "SMfrm.sym", 34 },
	{ -1	    ,           0 ,          0 ,  0 } };

int	sts = MSSUCC;

  /*
   * Delete gadgets to default pocket menu.
   */
  sts = vd$pkt_del_gadgets(	gadgets	= SMlist );
  sts = VDloadPocketGadgets(0);
  sts = vd$pkt_menu( );

  return OM_S_SUCCESS;
  
} /* end SMDelToPocketMenu */

/*----------------------------------------------------------------------------*/
