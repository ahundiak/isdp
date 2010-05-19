/* $Id: SMLtdVolMac.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMLtdVolMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMLtdVolMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
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
 *
 * -------------------------------------------------------------------*/

/*
/*  ----------------------------------------------------------------------
/*  SMLtdVolMac.I
/*  Alain CLAUDE
/*  30 Oct 92
/*
/*  Abstract
/*	"Limited Volume" macro definition.
/*	The templates are :
/*	- an expression : 0 (do not consume the faces) ; 1 (consume)
/*	- the faces of a limited volume, which define
/*		  a solid as the macro foot (of class EMSgensolid)
/*
/*	Related files : SMLtdVol.S SMLtdVoli.I SMmakeLtdVol.I
/*
/*  History
/*
/* */


class implementation SMLtdVol ;

#define MAX_TEMP	50
#define MAX_FEET	1

extern SMCrtMacDef() ;

SMLtdVolMacDef() 
{
 int	nb_temp, i;
 char	*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR];	
 int	temp_type[MAX_TEMP];	
 int	nb_feet;	
 char	*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];
 struct GRid	 mac_id;
 
 /* 
	Template initialization 
  */

 nb_temp = 0 ;
 sprintf(&tmp_temp[nb_temp * macro_MAX_CHAR],"consume_parents") ;
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR] ;
 temp_type[nb_temp++] = parameter_generic | double_type ;

 i       = 1 ;
 while(nb_temp < MAX_TEMP)
  {
   sprintf(&tmp_temp[nb_temp * macro_MAX_CHAR],"surface%d",i++) ;
   temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR] ;
   temp_type[nb_temp++] = other_generic ;
  }

 /*
	Feet initialization 
  */

 strcpy(&tmp_feet[0 * macro_MAX_CHAR],"volume") ;
 feet_list[0] = &tmp_feet[0 * macro_MAX_CHAR] ;

 nb_feet = 1 ;

 return (SMCrtMacDef("SMLtdVol", "SMPrivMac", nb_temp, temp_list, temp_type, 
	   nb_feet, feet_list, 0, NULL, NULL, &mac_id)) ;
}

end implementation SMLtdVol ;

