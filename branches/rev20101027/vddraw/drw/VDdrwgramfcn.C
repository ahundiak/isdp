/* $Id: VDdrwgramfcn.C,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwgramfcn.C
 *
 * Description:
 *	Parser support functions 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwgramfcn.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.3  1998/11/30  17:16:18  pinnacle
 * tr802288
 *
 * Revision 1.2  1998/05/20  21:57:48  pinnacle
 * Replaced: vddraw/drw/VDdrwgramfcn.C for:  by mdong for vds
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.5  1998/04/18  19:04:44  pinnacle
 * Replaced: vddraw/drw/VDdrwgramfcn.C for:  by azuurhou for vds
 *
 * Revision 1.3  1997/10/30  21:24:46  pinnacle
 * Warnings
 *
 * Revision 1.2  1997/10/28  16:13:44  pinnacle
 * Replaced: vddraw/drw/VDdrwgramfcn.C for:  by rchennup for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.5  1995/08/17  22:51:52  pinnacle
 * Replaced: vddraw/drw/VDdrwgramfcn.C for:  by azuurhou for vds.240
 *
 * Revision 1.3  1995/05/11  19:12:30  pinnacle
 * Replace: by tlbriggs for OPE
 *
 * Revision 1.2  1995/05/05  08:05:08  pinnacle
 * Replace: by tlbriggs for OPE
 *
 * Revision 1.1  1995/03/31  10:35:52  pinnacle
 * Created: vddraw/drw/VDdrwgramfcn.C by tlbriggs r#
 *
 *
 * History:
 *	3/22/95	    tlb		Created
 *	5/2/95	    tlb		InitParser - close any open log file
 *	5/9/95	    tlb		Change InitParser, ParserLocFlags interfaces
 *				Fixup debug messages
 *	10/30/97    ah          Fix warnings
 *      05/20/98    Ming        TR179800594
 *      11/25/98    ylong       TR179802288
 *
 *************************************************************************/

#include <stdio.h>
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_globalmsg.h"

#include "v_dbgmacros.h"
#include "v_drwproto.h"

#define FILE_NAME 	inp->inputFiles.name[inp->inputFiles.iScanned]
#define DEF		inp->defaults

/*-----------------------------------------------------------------------*/
/* VD_drwInitParser 
 *	initialize major parser data structures
 */
void
VD_drwInitParser (
    	VD_drwExecData 		*xData ,	    	/* Execution data */
	VD_drwInputData		*inp, 
	VD_drwMacInfo		**macInfo ,	/* I/O */
    	int		   	*elmProcessed,	/* O */
	int			*X		/* O */
	)
{
	SetProc (VD_drwInitParser); Begin

	/* Set the execute flag
	 *	If we are only extracting the attributes to be
	 *	reported to the drawing then we are not
	 *	"executing".
	 */
	*elmProcessed = FALSE;
	if( macInfo )	{ *X = FALSE ; *macInfo = NULL ; }
	else		{ *X = TRUE  ; }


	/* override input defaults */
        if( inp->applicationFlag != VD_K_DRW_VOLUMECUT &&
	    inp->applicationFlag != VD_K_DRW_SYMBOLOGY )     /* TR179800594 */
	  DEF.elmLevel		= VD_K_LEVEL;
	DEF.hdnLevel		= VD_K_LEVEL + 1;
	DEF.hdnDisplay.style	= VD_K_HIDDEN_STYLE;

	/* initialize xData */ 
        xData->action		= (void (*)()) VD_drwUndefinedAction;
        xData->elmQuery		= (void (*)()) VD_drwUndefinedAction;
        xData->verbose		= FALSE;
	xData->selectMask	= 0 ;
        *xData->viewCriterion	= '\0';
        *xData->filter		= '\0';
        xData->txPosHelper	= VD_undefTxPosHelper;
        xData->lastGraphic	= NULL;

        /*
         * Do not forget to init garbage list to NULL !
         */
        xData->garbageList	= NULL;

        /*
         * Init local overrides to the input default values.
         */
        xData->overrides.viewConeAngle	= DEF.viewConeAngle;
	xData->processFlags		= inp->processFlags;

	/*
	 * Reset local overrides to the input defaults 
	 */
	VD_drwResetSymbology ( xData, &(inp->defaults));

	/* print input symbology */
#ifdef PARSER_SYMB
	if (X) 
		VD_drwPrintSymbology ("Input", *xData);
#endif

        /*
         * The log file for the verbose mode is stdout by
         * default unless it is redefined with a
         *	"set logfile <filename>"
         * statement.
         */
	VD_drwCloseLogFile();
        xData->logFile = stdout;

	/*
	 * Process the input element.
	 */
	if( *X ){
	  if( inp->constDefName[0] == '\0' ){
	    VD_drwGetMacroType( inp, xData );
            if (!xData->parsedElmType) VD_drwGetGRhdrType( inp, xData );
	  }
	  else xData->parsedElmType = VD_gI_InAsbly ;
	}
	
#ifdef PARSER_DEBUG
	if (xData->verbose) {
		printf ("%s\n", *X ? 
			"-----------------------------------------------\n" :
			"===============================================\n");
		VD_drwPrintParserFlags (xData, macInfo, *elmProcessed, *X);
		}
#endif  PARSER_DEBUG

	End
}


/*-----------------------------------------------------------------------*/
/* VD_drwEndParser 
 *	cleanup, print closing messages
 */
void
VD_drwEndParser (
    	VD_drwExecData 		*xData ,	/* Execution data */
	VD_drwInputData		*inp ,
	VD_drwMacInfo		**macInfo ,	
    	int		   	elmProcessed    
	)
{
	SetProc (VD_drwEndParser); Begin

	/* Write finishup messages */
        if( xData->verbose ) {
        	if( macInfo ) 
          		VD_drwPrintf( ">> End file %s\n", FILE_NAME);
		else {
          		if( !elmProcessed ) 
            			VD_drwElmNotProcessed( xData->logFile, inp);
          		VD_drwPrintf ( ">> End object %d, %d\n\n",
                   		inp->elmId->osnum, inp->elmId->objid);
        		}
		}

        /*  Collect garbage  */
        VD_drwCollectGarbage( xData);

	End
}
/*-----------------------------------------------------------------------*/
/* VD_drwProcessType
 *	Setup prcessing for a specific element type
 *	Returns: 
 *		0,1 	execute flag
 *		-1	memory error	
 */
int
VD_drwProcessType (
    	VD_drwExecData 		*xData ,	/* I/O Execution data */
	VD_drwInputData		*inp ,		/* I */
	VD_drwMacInfo		**macInfo ,	/* I */
    	int		   	*elmProcessed,	/* O */
	int			X		/* I */
	)
{
	SetProc (VD_drwProcessType); Begin

	/* Get filter name and parsedElmType for this element */
	if( X || macInfo ) 
		(*(VD_drwElmQuery)xData->elmQuery)(VD_drwQueryFilter,inp,xData);
		
	if( macInfo ) {
 		if( !VD_drwAddMacInfo( macInfo, xData->filter )) {
			End
			return -1;
			}
	  	}
	else if( X ) {
		/*
		 * Is type of input element corresponding to
		 * that for which we are parsing code ?
		 */

		/* stop execution if element type not set 
		 *		ie if macinfo or no match
		 */
		X = 0 != xData->parsedElmType;

	    	/*
	     	 * If type is OK, are we processing a const (a macro
	     	 * occurrence) ? If so is the macro definition of the input
	     	 * const the same as that specified for the code
	     	 * we are parsing ?
	     	 */
                                           /* if_else block is for tr179802288*/
                if( ! strcmp( inp->constDefName, "unit-processing") &&  
		      strcmp( xData->filter, inp->constDefName ))
                {
		 	__DBGpr_com(" Checking Unit-Processing ");
			X = 0 ;
		}
		else
                {
	    	  if( X && VD_gI_InAsbly == xData->parsedElmType )
                  { 
	      		X = VD_matchRE( xData->filter, inp->constDefName);
                  }
		}

		/* Element will be processed */
		if (X) {
	    	    if( xData->verbose ) {
	        	if( VD_gI_InAsbly == xData->parsedElmType ) {
		  	    VD_drwParserTrace( 
				"Element type '%s'\tFilter: '%s'\tObject: '%s'\n",
		          		xData->parsedElmDesc, xData->filter,
					inp->constDefName);
		  		VD_drwParserTrace ("View criterion : '%s'\n", 
							xData->viewCriterion);
	        		} 
		     	else 
	          		VD_drwParserTrace( "Element type '%s'\n", 
							xData->parsedElmDesc);
	      		}

	      	   /*
	       	    * Element accepted : find its view.
	       	    */
	      	    *elmProcessed = TRUE;

		}

#ifdef PARSER_DEBUG

		/* Element was not processed */
		else if (xData->verbose) {
			if (!xData->parsedElmType)	
		    		VD_drwParserDebug (
				  "Skip element '%s': object not a '%s'\n", 
						xData->parsedElmDesc,
						xData->filter);
			else
		    		VD_drwParserDebug (
			  	  "Skip element '%s': object did not match filter '%s'\n", 
						xData->parsedElmDesc,
						xData->filter);
			}
#endif PARSER_DEBUG
		}


	End
	return X;
}

#argsused // Get rid of warnings

/*-----------------------------------------------------------------------*/
/* VD_drwProcessGraType
 *	Setup prcessing for a specific graphics name 
 *	Returns: 
 *		0,1 	execute flag
 *		-1	memory error	
 */
int
VD_drwProcessGraType (
    	VD_drwExecData 		*xData ,	/* I/O Execution data */
	VD_drwInputData		*inp ,		/* I */
	VD_drwMacInfo		**macInfo ,	/* I */
    	int		   	*elmProcessed,	/* O */
	int			X		/* I */
	)
{
	SetProc (VD_drwProcessGraType); Begin

		/* Get graphics name in constDefName and parsedElmType */
		(*(VD_drwElmQuery)xData->elmQuery)(
					VD_drwQueryGraType, inp, xData);

		/* return if element type does not support graphics name
		 */
		if (! xData->parsedElmType) {
			VD_drwParserWarn (xData->verbose,
			"Element type %s does not support graphics names - string ignored: %s\n",
				xData->parsedElmDesc, xData->filter);
			
			End
			return X;
			}

		/* compare user defined name with graphics name */
	    	if( X && VD_gI_InAsbly == xData->parsedElmType )  
	      		X = VD_matchRE( xData->filter, inp->constDefName);

	    	if( xData->verbose ) 
			VD_drwParserTrace (
					"Element name '%s'\t\tObject name '%s'\n",
		          		xData->filter, inp->constDefName);
		/*
	       	 * Reset processed flag 
		 *	Was set in previous step
 		 */
	      	*elmProcessed = X ;

			
#ifdef PARSER_DEBUG
		if (!X && xData->verbose) {
		    VD_drwParserDebug ("Skip element '%s': name did not match\n", 
							xData->parsedElmDesc);
		     }
#endif PARSER_DEBUG

	End
	return X;
}
/*-----------------------------------------------------------------------*/
/* VD_drwPrintParserFlags
 *	print parser flags and data structures 
 */
void
VD_drwPrintParserFlags (
    	VD_drwExecData 		*xData ,	/* Execution data */
	VD_drwMacInfo		**macInfo ,	
    	int		   	elmProcessed,
	int			X
	)
{
	if (!xData->verbose) return;
	VD_drwParserDebug (
      "Flags: verbose = %d\tmacInfo = %d\tX = %d\telmProcessed = %d\n"
				,xData->verbose, macInfo, X, elmProcessed);
}
/*-----------------------------------------------------------------------*/
/* VD_drwPrintParserLocFlags
 *	print parser locate flags and data structures 
 */
void
VD_drwPrintParserLocFlags (
    	VD_drwExecData 		*xData ,	/* Execution data */
	VD_drwInputData		*inp 
	)
{
	if (!xData->verbose) return;
	VD_drwPrintMsg ("###",
			"Input: \tconstDefName = '%s'\n", inp->constDefName);
	VD_drwPrintMsg("###","xData: \tfilter = '%s'\t\tviewCriterion = '%s'\n",
				xData->filter, xData->viewCriterion);
	VD_drwPrintMsg ("###",
			"\t\tparsedElmType = %d\tparsedElmDesc = '%s'\n\n",
				xData->parsedElmType, xData->parsedElmDesc);
}
