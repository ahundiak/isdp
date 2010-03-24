/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
		< 1986, 1987, 1988, 1989, 1990, 1991 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              Huntsville, Al 35894-0001
*/ 


/* ODE.h -- Internal/Extern COB ( formerly "ODE" ) things */
#ifndef ODEh
#define ODEh

#include "COBmacros.h"
#include "ode_export.h"
#include "COB_arg.h"

/*** The following definition needs to be here for when Object-Based **/
/***   forms are phased out.					     **/
#ifndef STATUS_FORM
#define STATUS_FORM	OM_K_MAXINT
#endif

/************************  stuff moved from  "CEO.S"  *****************/

struct CEO_form
{
  char	      * form_ptr;	/* I/Forms form ptr			*/
  int		label;		/* form label				*/
  int		x;		/* form x position			*/
  int		y;		/* form y position			*/
  char		display_type;	/* 0 = No automatic display/erase	*/
				/* 1 = Automatic display & erase	*/
				/* 2 = Automatic display but NO erase, until  */
				/* 	all cmd objs using form are deleted   */
				/*	(persistent form)		*/
  char		displayed;	/* 0 = Form NOT currently displayed	*/
  				/* 1 = Form currently displayed		*/
  char	      *	name;		/* file name containing form definition */
  OM_S_OBJID	prev_pf_cmd_oid;/* oid of the last COB command that	*/
				/*     controlled this persistent form	*/
};


/*************************  moved from tool.h *************************/
typedef union
  {
    int		  i;
    double	  d;
    char	* str;
  } data_val;


#endif	/*****   end of #ifndef ODEh  *****/
