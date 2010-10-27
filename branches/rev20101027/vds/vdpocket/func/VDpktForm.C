/* $Id: VDpktForm.C,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/func / VDpktForm.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDpktForm.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/31  19:23:56  pinnacle
 * UnInit warnings
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/09/25  23:10:00  pinnacle
 * Replaced: vdpocket/func/VDpktForm.C for:  by sundar for vds.240
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
 *	10/31/97	ah		UnUsed warnings
 * -------------------------------------------------------------------*/

/*
	I/VDS	Pocket Menu macro functions.

	The following functions are defined to manipulate the default I/EMS
	pcoket menu.

	- VDpkt_form		How to get the pocket menu pointer.

	- VDpkt_menu		Display the I/EMS pocket menu, plus add
				gadgets of higer defined product to the 
				pocket menu form.

	- VDpkt_add_gadgets	Add a list of one or more gadgets to the
				pocket menu list.

	- VDpkt_del_gadgets	Delete a list of one or more gadgets from
				the pocket menu list.

	The functions can give the following type of return values:

	VD_E_GRP_EXIST		pocket menu group exist
	VD_E_NO_POCKETMENU	no pocketmenu found
	VD_E_NO_DEF_POCKET	def pocket menu not found
	VD_E_ERROR		error in encountered

	Which data structure to add/delete a gadget :
	-------------------------------------------

	struct VDpktGadgets{
          long    type_cmd ;    command type : FI_CMD_KEY or FI_CMD_STRING.
          char    *cmd ;        command string or ASCII key.
          char    *sym_file ;   symbol file
          int     sym_index ;   symbol index in symbol file.
        } ;

*/

#include <stdio.h>
#include <FI.h>
#include <MI.h>
#include <FIdyn.h>

#include "exdef.h"
#include "exmacros.h"
#include "OMtypes.h"
#include "msdef.h"
#include "vdpktdef.h"

/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"

/*
 * the following static defined structure and constants are to control
 * the placement of the gadgets in the pocketmenu.
 *
 * Structure VDpkt_list is used to save the gadgets to add; which is
 * necessary in case pocket menu is replace by alternative pocket menus.
 */

static	int	VDpkt_frm_width  = 0;		/* default form width   */
static	int	VDpkt_frm_height = 0;		/* default form height  */

static	struct	VDpktGadgets	VDpktList [VDPKT_MAX_GADGETS] = {

         /*  structure:     type, cmd, file, index */

	/*  0 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  1 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  2 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  3 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  4 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  5 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  6 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  7 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  8 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/*  9 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 10 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 11 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 12 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 13 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 14 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 15 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 16 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 17 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 18 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 19 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 20 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 21 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 22 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 23 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 24 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 25 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 26 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 27 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 28 */ { VDPKT_ENDLIST,   0,    0,     0 },
	/* 29 */ { VDPKT_ENDLIST,   0,    0,     0 } };

extern char	*MS_pocket_menu ;

#define pktRC( value_to_return ) \
        if( rc != FI_SUCCESS ) { sts = (value_to_return) ; goto wrapup ; }

/*----------------------------------------------------------------------------*/
int VDpkt_menu( )
{
struct	standard_st	stand_st ;
struct	VDpktGadgets	*gad;

// No longer used
// struct	EX_cmd		t_cmd;


char	pck_name[200];
int	Sts, sts = MSSUCC,
	rc, prod, gi,
	ResizeForm,	/* if gadget is added */
	next_label, 	/* gadget label */
	w_fact,		/* width factor */
	sym_width, sym_height; 	/* creation sizes of symbol gadget */
FILE	*fp;

int	VDpkt_pos_width  = 0,		/* place position in form */
	VDpkt_pos_height = 0,		/* place position in form */
	VDpkt_limit      = 0;		/* limit of icons per line */

int	VDg_size[VDPKT_MAX_GADGETS];	/* width size factor of gadgets */


	/*
	 * find the default pocket menu; if any.
	 */
	pck_name[0] = '\0';

	Sts = TRUE ;
	for( prod = 0 ; Sts == TRUE ; prod++ ) {

		if( ( Sts = ex$get_path(index	= prod,
					path	= pck_name,
					len	= sizeof( pck_name ) ) ) ) {

		  strcat( pck_name, "config/english/menus/" ) ;
		  strcat( pck_name, VDPKT_POCKET_MENU ) ;

		  /*
		   * test if file exist
		   */
		  fp = ( FILE * ) fopen ( pck_name , "r" );

		  if( fp == NULL ) continue ;
		  else{
		    fclose( fp );
		    break;
		  }
		}
		else {
		  sts = VD_E_NO_POCKETMENU ;
		  goto wrapup ;
		}
	}

	/*
	 * set the default pocket menu
	 */
	MS_swap_menu( POCKET_MENU, pck_name );
	/*"POCKET_MENU : " , pck_name */

	/*
	 * If I/VDS - ROUTE - STRUCT runs in batch mode -> no pocket menu.
	 */
	if( ! MS_pocket_menu ) { sts = VD_E_NO_POCKETMENU ; goto wrapup ; }

	/*
	 * Look if the function is called for the first time to get the
	 * dimension values of the pocket menu form.
	 */
	if( ! VDpkt_frm_width || ! VDpkt_frm_height ){

		rc = FIf_get_size(	MS_pocket_menu,
					&VDpkt_frm_width, &VDpkt_frm_height ) ;
		pktRC( VD_E_NO_POCKETMENU ) ;
	}

	/*
	 * start position to add symbol gadget
	 */
	VDpkt_pos_width  = 0;
	VDpkt_pos_height = 0;

	/*
	 * get the limit of gadgets per line.
	 */
	VDpkt_limit = VDpkt_frm_width / VD_PKT_S_ICONSIZE ;

	/*
	 * initize the width size factor of all gadgets.
	 */
	for( gi = 0 ; gi < VDPKT_MAX_GADGETS ; gi ++ ) VDg_size[ gi ] = 0 ;

	/*
	 * calculate the width size factor of all gadgets.
	 */
	for(	gi = 0 , gad = VDpktList ;
		gi < VDPKT_MAX_GADGETS && gad->type_cmd != VDPKT_ENDLIST ;
		gi ++ , gad ++ ){

		/*
		 * test for correct command types
		 */
		if( !(  gad->type_cmd & FI_CMD_STRING ||
			gad->type_cmd & FI_CMD_KEY )   ){
			continue;
		}

		/*
		 * Test if the command is still active (switchprod )
		 *
		 *   Sts = TRUE;
		 *   Sts = ex$get_cmd_info(	string	= gad->cmd,
		 *			mode	= (int) gad->type_cmd,
		 *			cmdstr	= &t_cmd );
		 *
		 *   if (! Sts ) continue ;
		 */

		stand_st.xlo		= 0 ;
		stand_st.ylo		= 0 ;
		stand_st.attr_mask	= 0 ;
		stand_st.fontname	= gad->sym_file ;
		stand_st.symbol_index	= (char) gad->sym_index ;
		stand_st.xhi		= 100 ;
		stand_st.yhi		= 100 ;
		stand_st.off_color	= stand_st.off_color2
					= stand_st.on_color
					= stand_st.on_color2 = FI_BLACK ;
		stand_st.next_in_seq	= 0 ;
		stand_st.value	= 0.0 ;
		stand_st.bodysize	= 15.0 ;
		stand_st.text		= NULL ;
		stand_st.help_topic	= NULL ;
		stand_st.command	= NULL ;
		stand_st.user_pointer	= NULL ;
		stand_st.symbol_index2	= 0 ;

		/*
		 * create dymmy gadget to test sizes
		 */
		rc = FIg_new( MS_pocket_menu, FI_SYM, VD_PKT_SYMBOL ) ;
		pktRC( VD_E_ERROR ) ;

		rc = FIg_set_standard_variables(MS_pocket_menu,
					  	  VD_PKT_SYMBOL,
						  &stand_st ) ;
		pktRC( VD_E_ERROR ) ;

		rc = FIg_activate( MS_pocket_menu, VD_PKT_SYMBOL ) ;
		pktRC( VD_E_ERROR ) ;

		FIg_get_size( MS_pocket_menu, VD_PKT_SYMBOL,
				&sym_width, &sym_height );

		FIg_delete( MS_pocket_menu, VD_PKT_SYMBOL ) ;

		/*
		 * Set location and size for all gadgets.
		 */
		if( !sym_width || !sym_height ) {
			continue;
		}

		/*
		 * Get corresponding gadget size.
		 * In this version the gadgets size is limited to two
		 * times the standard size.
		 */
		if     ( sym_width < VD_PKT_S_ICONSIZE ) VDg_size[gi] = 1;
		else if( sym_width < VD_PKT_D_ICONSIZE ) VDg_size[gi] = 2;
		else                                     VDg_size[gi] = 2;
	}

	/*
	 * first add the gadgets of double size, before adding gadgets
	 * of default gadget size.
	 */
	ResizeForm = FALSE ;
	for( w_fact = 2 ; w_fact > 0 ; w_fact -- ) {

	    /*
	     * look for the gadgets of size w_fact
	     */

	    for(gi = 0 , gad = VDpktList ;
		gi < VDPKT_MAX_GADGETS && gad->type_cmd != VDPKT_ENDLIST ;
		gi ++ , gad ++ ){

		if( w_fact != VDg_size[gi] ) { continue ; }

		/*
		 * Look if we have to start on the next line.
		 */

		if ( w_fact + VDpkt_pos_width > VDpkt_limit ) {
			VDpkt_pos_height++ ; 
			VDpkt_pos_width = 0;
		}

		stand_st.attr_mask	= gad->type_cmd ;
		stand_st.fontname	= gad->sym_file ;
		stand_st.symbol_index	= (char) gad->sym_index ;
		stand_st.off_color	= FI_BLACK ;
		stand_st.on_color 	= FI_WHITE ;
		stand_st.value		= 0 ;
		stand_st.command	= gad->cmd ;

		stand_st.xlo	= VDpkt_pos_width  * VD_PKT_S_ICONSIZE +
				  VDpkt_pos_width  + 3 ;
		stand_st.ylo	= VDpkt_pos_height * VD_PKT_S_ICONSIZE +
				  VDpkt_pos_height + 1 +
				  VDpkt_frm_height - 3 ;

		stand_st.xhi	= stand_st.xlo + VD_PKT_S_ICONSIZE * w_fact +
				  ( w_fact - 1 ) ;
		stand_st.yhi	= stand_st.ylo + VD_PKT_S_ICONSIZE ;

		/*
		 * Add gadgets to default pocket menu.
		 * Find gadget label.
		 */
		rc = FIf_get_next_label( MS_pocket_menu, &next_label ) ;
		pktRC( VD_E_ERROR ) ;

		rc = FIg_new( MS_pocket_menu, FI_BUTTON, next_label ) ;
		pktRC( VD_E_ERROR ) ;

		rc = FIg_set_standard_variables( MS_pocket_menu, next_label,
						 &stand_st ) ;
		pktRC( VD_E_ERROR ) ;

		/*" command: %s\n", gad->cmd */

		rc = FIg_activate( MS_pocket_menu, next_label ) ;
		pktRC( VD_E_ERROR ) ;

		/*
		 * increment of the width position in the form
		 */
		VDpkt_pos_width += w_fact ;

		if( ! ResizeForm ) ResizeForm = TRUE ;
	    }
	}

	/*
	 * Set new size of pocket menu.
	 */
	FIf_set_scaling_off( MS_pocket_menu ) ;
	if( ResizeForm ) 
		FIf_set_size( MS_pocket_menu,
			VDpkt_frm_width,                         /* pr width */
			VDpkt_frm_height +			 /* pr hght  */	
			(VDpkt_pos_height+1)*VD_PKT_S_ICONSIZE + /* nb lines */	
			VDpkt_pos_height+1 );			 /* nb space */	

	wrapup :
		return sts ;

} /* VDpkt_menu */

/*----------------------------------------------------------------------------*/
int VDpkt_form( pkt_form )
char	*pkt_form; 	/* pocket menu pointer  */
{
int	sts = MSSUCC;

	/*
	 * If product runs in batch mode -> no pocket menu.
	 */
	if( !MS_pocket_menu ) { sts = VD_E_NO_POCKETMENU ; goto wrapup ; }

	* pkt_form = * MS_pocket_menu ;

	wrapup :
		return sts ;

} /* VDpkt_form */

/*----------------------------------------------------------------------------*/

int VDpkt_add_gadgets( gadgets )
struct	VDpktGadgets	*gadgets;  /* list of gadgets to be added in list */
{
struct	VDpktGadgets	*tgad, *gad;
int	sts = MSSUCC,	/* return value         */
	Duplicate,	/* test for existance   */
	gi; 		/* tabel index counters */

	/*
	 * If no list to add, returns true.
	 */
	if( ! gadgets ) { goto wrapup ; }

	/*
	 * look if gadget already exist in the pocket_menu,
	 * if the gadget is added, remove the gadget from the user list. 
	 */
	for( tgad = gadgets ; tgad->type_cmd != VDPKT_ENDLIST ; tgad ++ ){

	    /*
	     * test for valid command type.
	     */
	    /* VDpkt_print( tgad ); */

	    Duplicate = FALSE ;

	    if( tgad->type_cmd & FI_CMD_STRING ||
		tgad->type_cmd & FI_CMD_KEY     ){

		for(	gi = 0 , gad = VDpktList ;
			gi < VDPKT_MAX_GADGETS && gad->type_cmd != VDPKT_ENDLIST;
			gi ++ , gad ++ ){

		    if((strcmp( tgad->sym_file,    gad->sym_file  ) == 0 ) &&
			      ( tgad->sym_index == gad->sym_index ) ){

			/*
			 * gadget exist in list.
			 */
			/*" Duplicate : %s\n", tgad->cmd */
			Duplicate = TRUE ;
		    }
		}

		if( ! Duplicate ) {

		    /*
		     * test if the pocket list if full.
		     */
		    if( gi == VDPKT_MAX_GADGETS ) {
			/*
			 * warning: have reached the end of the static table.
			 */
			printf(" VDS pocket menu : max icons reached. \n");
			goto wrapup;
		    }
        
		    /*
		     * add at end of list.
		     */
		    VDpkt_copy( tgad, gad );
		    /*" Add : %s\n ", gad->cmd */
		}
	    }
	}

	wrapup :
		return sts ;

} /* VDpkt_add_gadgets */

/*----------------------------------------------------------------------------*/

int VDpkt_del_gadgets( gadgets )
struct	VDpktGadgets	*gadgets;  /* list of gadgets to be added in list */
{
struct	VDpktGadgets	*tgad, *gad, *ngad;
int	sts = MSSUCC,
	gi;	 	/* tabel index counters */

	/*
	 * If no list to add, returns true.
	 */
	if( ! gadgets ) { goto wrapup ; }

	/*
	 * look if gadget already exist in the list; if found remove it.
	 */
	for( gad = gadgets ; gad->type_cmd != VDPKT_ENDLIST ; gad ++ ){

	  /*
	   * test for valid command type.
	   */

	  /* VDpkt_print( gad ); */

	  if( gad->type_cmd & FI_CMD_STRING ||
	      gad->type_cmd & FI_CMD_KEY     ){

	    for(	gi = 0 , tgad = VDpktList ;
			gi < VDPKT_MAX_GADGETS && tgad->type_cmd != VDPKT_ENDLIST;
			gi ++ , tgad ++ ){

		if((strcmp( tgad->sym_file,    gad->sym_file  ) == 0 ) &&
			  ( tgad->sym_index == gad->sym_index ) ){

		    /*
		     * gadget exist in list.
		     */
		    /*" Remove : %s\n", gad->cmd */
		    VDpkt_init( tgad );
		    ngad = tgad ;
		    ngad ++ ;

		    /*
		     * move up the list
		     */
		    while( gi < VDPKT_MAX_GADGETS && 
			   ngad->type_cmd != VDPKT_ENDLIST ){

			/*
			 * copy the structure information.	
			 */
			VDpkt_copy( ngad, tgad );
			VDpkt_init( ngad );

			tgad = ngad ;
			ngad ++ ; gi ++ ;
		    }
		    break ;
		}
	    }
	  } /* if type_cmd */
	}

	wrapup :
		return sts ;

} /* VDpkt_del_gadgets */

/*----------------------------------------------------------------------------*/

int VDpkt_initlist( )
{
int	gi;
struct	VDpktGadgets	*gad;

	for(	gi = 0 , gad = VDpktList ;
		gi < VDPKT_MAX_GADGETS && gad->type_cmd != VDPKT_ENDLIST;
		gi ++ , gad ++ ){
	    /*
	     * initize structure information.
	     */
	    VDpkt_init( gad ) ;
	}
	return 1 ;

} /* VDpkt_initlist */

/*----------------------------------------------------------------------------*/

int VDpkt_init( gad )
struct	VDpktGadgets	*gad ;	/* gadget structure  */
{

	if( ! gad ) { return 0 ; }

	gad->type_cmd    = VDPKT_ENDLIST ;
	gad->cmd         = 0 ;
	gad->sym_file    = 0 ;
	gad->sym_index   = 0 ;

	return 1 ;

} /* VDpkt_init */

/*----------------------------------------------------------------------------*/

int VDpkt_copy( fr , to )
struct	VDpktGadgets	*fr, *to ;	/* gadget structures  */
{

	if( to == NULL || fr == NULL ) { return 0 ; }

	to->type_cmd  = fr->type_cmd  ;
	to->cmd       = fr->cmd ;
	to->sym_file  = fr->sym_file ;
	to->sym_index = fr->sym_index ;

	return 1 ;

} /* VDpkt_copy */

/*----------------------------------------------------------------------------*/

int VDpkt_prlist( )
{
int	gi;
struct	VDpktGadgets	*gad;

	for(	gi = 0 , gad = VDpktList ;
		gi < VDPKT_MAX_GADGETS && gad->type_cmd != VDPKT_ENDLIST;
		gi ++ , gad ++ ){
	    /*
	     * print structure information.
	     */
	    printf( " index : %d\n", gi ) ;
	    
	    VDpkt_print( gad ) ;
	}

	return 1 ;

} /* VDpkt_prlist */

/*----------------------------------------------------------------------------*/

int VDpkt_print( gad )
struct	VDpktGadgets	*gad;
{

	printf("\t -----------------------" ) ;
	printf("\t type : %d\n", gad->type_cmd   ) ;
	printf("\t file : %s\n", gad->sym_file   ) ;
	printf("\t index: %d\n", gad->sym_index  ) ;
	printf("\t cmd  : %s\n", gad->cmd        ) ;
	printf("\t -----------------------" ) ;

	return 1 ;

} /* VDpkt_print */

/*----------------------------------------------------------------------------*/

