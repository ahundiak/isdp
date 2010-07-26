/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
/*----------------------------------------------------------------------------*/
int CMDbegin( cmd )

int cmd ;

{ int rc ; PCIlist args ;

  if( !isstring( cmd ) ) rc = ERRsyn( "docmd argument must be a string", NULL ) ;
  else {
  	args.free   		= FALSE     		;
  	args.num    		= 2     		;
  	args.elt.Stat[0] 	= mkSYS( "begincmd" )	;
  	args.elt.Stat[1] 	= cmd			;
  	rc = genins( FCALL, &args )			;
  }
  return rc ;

} /* CMDbegin */
/*----------------------------------------------------------------------------*/
int CMDend()

{ PCIlist args ;

  	args.free   		= FALSE     		;
  	args.num    		= 1     		;
  	args.elt.Stat[0] 	= mkSYS( "endcmd" )	;
  	return genins( FCALL, &args ) 			;

} /* CMDend */
/*----------------------------------------------------------------------------*/
int KEYbegin( cmd )

int cmd ;

{ int rc ; PCIlist args ;

  if( !isstring( cmd ) ) rc = ERRsyn( "dokey argument must be a string", NULL ) ;
  else {
  	args.free   		= FALSE     			;
  	args.num    		= 2     			;
  	args.elt.Stat[0] 	= mkSYS( "begincmd_key" )	;
  	args.elt.Stat[1] 	= cmd				;
  	rc = genins( FCALL, &args )				;
  }
  return rc ;

} /* KEYbegin */
/*----------------------------------------------------------------------------*/
