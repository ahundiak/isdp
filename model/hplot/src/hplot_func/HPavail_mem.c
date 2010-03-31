#include <stdio.h>

#if CLIX
#include <sys/types.h>  
#include <sys/sysclip.h>
#include <sys/immu.h>
#endif 

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

#define	MIN_BUF_SIZE		5600000
#define z50Mb			52428800
#define	z8_5Mb			8912896
#define z16Mb			16777216
#define	z1_85Mb			1939866

/*---HPinq_available_memory------------------------------------------------*/

/*
NAME
	HPinq_available_memory

KEYWORD
	HSplot
	memory management
		
DESCRIPTION
	Will get the amount of physical memory available on the machine and
	compute the amount of memory HSplot can have to allocate z/image
	buffers from
	
GLOBALS USED
	HPglobal: Structure local to HSplot that contains global information
		  In this is stored the total physical memory avail and
		  the amount of physical memory available to HSplot
		  
RETURN VALUES
	buf_mem: The amount fo physical memory available to HSplot (Why is
		 returned and pushed into the global???)

ALGORITHM
	The amount of physical memory available to HSplot is:
		if the total physical memory is more than 50Meg
			2/3 the total physical memory
			
		if the total physical memory is less than 50Meg
			8.5Meg - ((total physical memory, less 16Meg) / 16Meg) * 1.85Meg
			
	Also, the physical memory available must not be less than 5.6Meg, which is the
	amount needed, worse case, for one scanline.

FUNCTIONS CALLED
	getmemsize: Returns in bytes, the amount of physical memory available
		    on the workstation.

NOTES
	Because getmemsize() is not supported on the SUN, we, at this time, assume
	32Meg of main memory.
			    
HISTORY
	08/11/92	Mike Lanier
		Ansi function prototypes
		
	??/??/??	Mike Lanier
		Created.
		
*/

	
#if defined(__STDC__) || defined(__cplusplus)
	int	HPinq_available_memory( void )
#else
	int	HPinq_available_memory()
#endif

	{
	int	phys_mem;
	int	buf_mem;

#	if defined (CLIX)
		phys_mem = getmemsize();
#	else	 		
		phys_mem = 33554432;
#	endif
	
	if( phys_mem < z50Mb )
		buf_mem = phys_mem - (z8_5Mb + ((phys_mem - z16Mb) / z16Mb) * z1_85Mb);
	else
		buf_mem = (phys_mem * 3) >> 2;
		
	if( buf_mem < MIN_BUF_SIZE ) buf_mem = MIN_BUF_SIZE;
	
	HPglobal.tot_phys_mem = phys_mem;
	HPglobal.tot_buf_mem = buf_mem;
	
	return( buf_mem );
	}

