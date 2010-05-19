/* $Id: VDweldsym.I,v 1.1.1.1 2001/01/04 21:09:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdweld/func/VDweldsym.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDweldsym.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/09  16:12:12  pinnacle
# Created: vdweld/func/VDweldsym.I by impd for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/21/97	  HF		Cooperates with file $VDS/config/weld_symbols in order
 *					to make placement of Welding Symbols user customizable
 *					
 * -------------------------------------------------------------------*/

class implementation DMweld;

#define AS_DEBUG	1

#include "fielddef.h"
#include "dimweld.h"
#include "weldform.h"
#include "VDweldsym.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*      ********************	GLOBAL VARIABLES  *****************************	*/
/* 	Used also in :								*/
/*		vdweld/imp/weldtxt.I						*/
/*		vdweld/cmd/VDweldcmd.I						*/
/*		vdweld/cmd/weldform.I						*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int				VDS_is_active_environment;
int				weld_sym_initialized;

struct VDweld_gadget_sym	sym_char [MAX_WLD_SYM_SZ];

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDread_sym_codes( FILE *fptr, int *num_codes )
{
  char str [DESC_SIZE * 4];
  char desc[DESC_SIZE];

  int  i0 = 0, j0;
  int  index, bezel, symbol, blank, flush, convex, concave, snr[2];

  __enterFunction ( name = "VDread_sym_codes" );

  while ( fgets (str, DESC_SIZE * 4, fptr) && i0 < MAX_WLD_SYM_SZ )
  {
    if ( str[0] == '#' ) continue;
    
    j0 = sscanf ( str, "%d %d %d %d %d %d %d %d %d %[^\n]",
		  &index, &bezel, &symbol, &blank, &flush, &convex, &concave, &snr[0], &snr[1], desc );
    
    if ( j0 == 10 )
    {
      sym_char [i0].index   = (short)index;
      sym_char [i0].bezel   = (short)bezel;
      sym_char [i0].symbol  = (short)symbol;
      sym_char [i0].type[0] = (short)blank;
      sym_char [i0].type[1] = (short)flush;
      sym_char [i0].type[2] = (short)convex;
      sym_char [i0].type[3] = (short)concave;
      sym_char [i0].snr [0] = (short)snr[0];
      sym_char [i0].snr [1] = (short)snr[1];

      strcpy ( sym_char [i0].desc, desc );
      
      i0++;
    }
  }
  *num_codes = i0;
  sym_char[0].fill   = (short)i0;	// TOTAL NUMBER OF RECORDS / LINES

  if ( i0 >= MAX_WLD_SYM_SZ ) printf ("MAXIMUM NR. of Lines for Weld_Symbol is %d\n", MAX_WLD_SYM_SZ );

  if (VDcomment)
  {
    for (j0=0; j0 < i0; j0++)
    {
      __printf ( "sym_char[%2d] = %5d %5d %5d %5d %5d %5d %5d %5d %5d <%s>",
		 `j0, sym_char[j0].index,   sym_char[j0].bezel,   sym_char[j0].symbol,  sym_char[j0].type[0], sym_char[j0].type[1],
		      sym_char[j0].type[2], sym_char[j0].type[3], sym_char[j0].snr [0], sym_char[j0].snr [1], sym_char[j0].desc` );
    }
  }
  
  __exitFunction ( name = "VDread_sym_codes" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDread_weld_sym_char( int *num_codes )
{
  char  file_name[257];
  char  tmpfile  [257];
  char *slash;
  int   path_found;
  int   j;
  int   status;
  FILE *fptr;

  __enterFunction ( name = "VDread_weld_sym_char" );

  *num_codes = 0;
  
  fptr = fopen ( "weld_symbols", "r" );
  
  if ( fptr )
  {
    goto read_sym_fil;
  }

  status = ex$get_path ( index = 0, path = file_name, len = sizeof(file_name) );
  strcat (file_name, "config/" );

  slash = (char *)strrchr (file_name, '/' );
  *slash = '\0';
  strcat (file_name, "/weld_symbols" );

  fptr = fopen ( file_name, "r" );
  if ( fptr )
  {
    goto read_sym_fil;
  }
  __printf ( "file_name  = <%s>", file_name );
  
  path_found = TRUE;
  for (j=1; path_found; j++)
  {
    path_found = ex$get_path ( index = j, 
			       path  = tmpfile, 
			       len   = sizeof(tmpfile) );
    if (path_found)
    {
      strcat (tmpfile, "config/weld_symbols" );

      __printf ( "tmpfile[%d] = <%s>", `j, tmpfile` );

      fptr = fopen ( tmpfile, "r" );
      if ( fptr )
      {
	goto read_sym_fil;
      }
    }
  }

read_sym_fil:

  if ( fptr )
  {
    VDread_sym_codes( fptr, num_codes );
    fclose ( fptr );
    status = 1;
  }
  else
  {
    status = 0;
  }

  __exitFunction ( name = "VDread_weld_sym_char" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static short	VDget_wld_sym_char ( int idx, int typ )
{
  int	i0, sts, num_sym_chars = 0;
  
  if ( idx >= MAX_WLD_SYM_SZ ) return 0;

  if ( ! weld_sym_initialized )
  {
    sts = VDread_weld_sym_char( &num_sym_chars );
    if ( 1 & sts && num_sym_chars )
    {
      weld_sym_initialized = 1;
    }
    else return 0;
  }

  for ( i0=0; i0 < MAX_WLD_SYM_SZ; i0++ )
  {
    if ( sym_char [i0].bezel == idx )
    {
      return ( sym_char [i0].type [typ-11] );
    }
  }
  return 0;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDget_weld_symbol_char (symbol,weld_type,weld_char)
	 IGRint  symbol;
	 IGRint  weld_type;
	 IGRchar  *weld_char;
{
  short weld_chr = 0;
  
  __enterFunction ( name = "VDget_weld_symbol_char" );

  __printf ( "weld_symbol = %d, weld_type = %d", `symbol, weld_type` );
  
  weld_chr = VDget_wld_sym_char ( symbol, weld_type );

  if ( weld_chr )
  {
    *weld_char = weld_chr;
    goto quit;
  }

  switch(symbol)
  {
  case GAD_SYMBOL1_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 32;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 32;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 32;
      else	*weld_char = 32;
      break;
    }
  case GAD_SYMBOL2_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 113;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 68;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 81;
      else	*weld_char = 100;
      break;
    }
  case GAD_SYMBOL3_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 116;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 71;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 84;
      else	*weld_char = 103;
      break;
    }
  case GAD_SYMBOL4_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 117;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 72;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 85;
      else	*weld_char = 104;
      break;
    }
  case GAD_SYMBOL5_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 114;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 69;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 82;
      else	*weld_char = 101;
      break;
    }
  case GAD_SYMBOL6_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 115;
      else if (weld_type == WL_CONVEX)
		  *weld_char = 70;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 83;
      else	*weld_char = 102;
      break;
    }
  case GAD_SYMBOL7_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 111;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 66;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 79;
      else	*weld_char = 98;
      break;
    }
  case GAD_SYMBOL8_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 112;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 67;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 80;
      else	*weld_char = 99;
      break;
    }
  case GAD_SYMBOL9_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 119;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 74;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 87;
      else	*weld_char = 106;
      break;
    }
  case GAD_SYMBOL10_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 53;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 53;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 53;
      else	*weld_char = 53;
      break;
    }
  case GAD_SYMBOL11_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 54;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 54;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 54;
      else	*weld_char = 54;
      break;
    }
  case GAD_SYMBOL12_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 55;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 55;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 55;
      else	*weld_char = 55;
      break;
    }
  case GAD_SYMBOL13_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 119;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 74;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 87;
      else	*weld_char = 106;
      break;
    }
  case GAD_SYMBOL14_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 120;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 75;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 88;
      else	*weld_char = 107;
      break;
    }
  case GAD_SYMBOL15_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 110;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 65;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 78;
      else	*weld_char = 97;
      break;
    }
  case GAD_SYMBOL16_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 110;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 65;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 78;
      else	*weld_char = 97;
      break;
    }
  case GAD_SYMBOL17_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 121;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 76;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 89;
      else	*weld_char = 108;
      break;
    }
  case GAD_SYMBOL18_BZ:
    {
      if (	 weld_type == WL_FLUSH)
		*weld_char = 122;
      else if (  weld_type == WL_CONVEX)
		*weld_char = 77;
      else if (  weld_type == WL_CONCAVE)
		*weld_char = 90;
      else	*weld_char = 109;
      break;
    }
  default:

    break;
  }
quit:
  __printf ( "weld_char = %d, weld_char = <%c>", `*weld_char, *weld_char` );
    
  __exitFunction ( name = "VDget_weld_symbol_char" );

  return(TRUE);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation DMweld;
