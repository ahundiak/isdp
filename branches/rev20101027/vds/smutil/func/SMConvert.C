/* $Id: SMConvert.C,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMConvert.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMConvert.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
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
 *
 * -------------------------------------------------------------------*/

/*  
   File     SMConvert.C  
   Date     September 92          
   Auteur   Jean Jasinczuk

   Description : Some Functions to easy manipulate unit with SMAN 
     
 History:
*/


#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "godef.h"
#include "griodef.h" 
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h" 
#include "griomacros.h"
#include "UOMdef.h"
#include "UOMmacros.h"


#include "SMdef.h"


/* ----------------- int SMRetCurUnit() -------------------------- */
/* Retrieves the name of the external distance unit                */
/* This name is Meter, Millimeter, Inch, Feet                      */
/* Return 1 if OK and 0 if fail                                    */

int SMRetExtDistUnit(unit,osnum)
char *unit;             /* [O] Name of the distance unit */
OMuword osnum;          /* [I] Current osnum             */
{
  IGRlong status,msg;
  short flag = 1, num_defaults = 1;
  GRIOalias_name alias_name[UOM_K_MAX_DEFS];

  /* Search the current EMS Unit */
  status = uom$get_default_units(msg = &msg,
				 table_name = GRIO_DISTANCE,
				 flag = &flag,
				 num_defaults = &num_defaults,
				 default_units = alias_name,
				 osnum = osnum);
  if(!(status & 1)) return 0;
  
  if(strncmp(alias_name[0],"in",2) == 0)
    strcpy(unit,"Inch");
  else
    if(strcmp(alias_name[0],"ft") == 0 ||
       strcmp(alias_name[0],"foot") == 0||
       strcmp(alias_name[0],"feet") == 0)
    strcpy(unit,"Feet");
    else
      if(strcmp(alias_name[0],"m") == 0 ||
	 strncmp(alias_name[0],"me",2) == 0)
      strcpy(unit,"Meter");
      else
	if(strcmp(alias_name[0],"mm") == 0 ||
	   strncmp(alias_name[0],"milli",5) == 0)
	strcpy(unit,"Millimeter");
	else
	  strcpy(unit,"Meter"); /* Put a  default unit */ 
  
  return 1;
}

/* ------------------------ int SMDistUnitFlag ------------------------- */
/* Given one name  Meter, Millimeter, Inch, Feet it fill corresponding   */
/* flag for unit as define in SMdef.h.                                   */


int SMDistUnitFlag(unit_str,sm_unit)
char unit_str[];           /* [I] Name of the distance unit */
IGRshort *sm_unit;         /* [O] SMAN unit    */
{
  if (!strcmp(unit_str,"Meter")) 
    *sm_unit |= SM_UNIT_MTC | SM_UNIT_MTR;
  else
    if(!strcmp(unit_str,"Millimeter")) 
    *sm_unit |=  SM_UNIT_MTC | SM_UNIT_MMTR;
    else
      if (!strcmp(unit_str,"Feet"))
      *sm_unit |= SM_UNIT_IMP | SM_UNIT_FT;
      else
        if (!strcmp(unit_str,"Inch"))
	*sm_unit |= SM_UNIT_IMP | SM_UNIT_INC;
	else
	  return 0;

  return 1;
}

/* ------------------------- int SMRetAnglUnitFlag -------------------- */
/* Retrieves the flag of the external angle unit (see SMdef.h)          */
/* Return 1 if OK and 0 if fail                                         */

int SMRetAnglUnitFlag(sm_unit,osnum)
IGRshort *sm_unit;             /* [O] Flag of the angle unit */
OMuword osnum;                 /* [I] Current osnum             */
{  
  IGRlong status,msg;
  short flag = 1, num_defaults = 1;
  GRIOalias_name alias_name[UOM_K_MAX_DEFS];

  /* Search the current EMS Unit */
  status = uom$get_default_units(msg = &msg,
				 table_name = GRIO_ANGLE,
				 flag = &flag,
				 num_defaults = &num_defaults,
				 default_units = alias_name,
				 osnum = osnum);
  if(!(status & 1)) return 0;
  
  if(strncmp(alias_name[0],"r",1) == 0)
    *sm_unit |= SM_UNIT_DEG;
  else
    if(strncmp(alias_name[0],"d",1) == 0)
    *sm_unit |= SM_UNIT_RAD;
    else
      *sm_unit |= SM_UNIT_DEG;

  return 1;
}

/* ----------------- SMConvDistExtInt --------------------------  */
/* Convert an external distance (user) to internal one (system)  */
/* Return 1 if OK else return 0                                  */

int SMConvDistExtInt(input,output,osnum)
IGRdouble input;              /* [I] External unit to convert */
IGRdouble *output;            /* [O] Internal unit */
OMuword osnum;                /* [I] Work osnum     */
{
  IGRlong status,msg;
  
  status = uom$cvt_imp_to_wrk(msg =  &msg,
			      unit_type = GRIO_DISTANCE,
			      osnum = osnum,
			      primary = input,
			      result  = output);
  return (status & msg & 1); 
}


/* ----------------- SMConvDistIntExt ------------------------- */
/* Convert an internal distance to external one                */
/* Return 1 if OK else return 0                                */

int SMConvDistIntExt(input,output,osnum)
IGRdouble input;              /* [I] Internal unit to convert */
IGRdouble *output;            /* [O] External unit */
OMuword osnum;                /* [I] Work osnum     */
{
  IGRlong status,msg;
  IGRshort num_alias;
  IGRchar convert_array[150];
  
  num_alias = 1;
  status = uom$cvt_imp_to_alias(msg =  &msg,
				unit_type = GRIO_DISTANCE,
				working_units = &input,
				osnum = osnum,
				num_alias = &num_alias,
				cvt_list = convert_array);          

  if(!(status & msg & 1)) return 0;
  
  if(sscanf(convert_array,"%lf",output) != 1) return 0;
  
  return 1;
}


/* ----------------- SMConvDistIntUnit ------------------------- */
/* Convert an internal distance to a specified unit             */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

SMConvDistIntUnit(input,unit,output,osnum)
IGRdouble input;      /* [I] internal value      */
IGRshort  unit;       /* [I] SMAN type of unit */
IGRdouble *output;    /* [O] external value      */
OMuword osnum;        /* [I] Work osnum          */
{
  IGRlong status;
  char *alias;
  
  if(unit & SM_UNIT_MTR)
    alias = "meters";
  else
    if(unit & SM_UNIT_MMTR)
      alias = "millimeters";
    else
      if(unit & SM_UNIT_INC)
	alias = "inches";
      else
	if(unit &  SM_UNIT_FT)
	  alias = "feet";
	else return 0;

  status = uom$cvt_dbu_to_value(osnum = osnum,
				ivalue = input,
				oalias = alias,
				ovalue = output );
  return(status & 1);
}

/* ----------------- SMConvDistUnitInt ------------------------- */
/* Convert a specified unit to internal distance                 */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */


SMConvDistUnitInt(input,unit,output,osnum)
IGRdouble input;       /* [I] number of user unit to convert */
IGRshort  unit;       /* [I] SMAN type of unit */
IGRdouble *output;     /* [O] internal value */
OMuword osnum;         /* [I] Work osnum    */
{
  IGRlong status;
  char *alias;
  
  if(unit & SM_UNIT_MTR)
    alias = "meters";
  else
    if(unit & SM_UNIT_MMTR)
      alias = "millimeters";
    else
      if(unit & SM_UNIT_INC)
	alias = "inches";
      else
	if(unit &  SM_UNIT_FT)
	  alias = "feet";
	else return 0;

  status = uom$cvt_value_to_dbu(osnum = osnum,
				ivalue = input,
				ialias = alias,
				ovalue = output );
  return(status & 1);
}

/* ----------------- SMConvAnglExtInt --------------------------  */
/* Convert an external Angle (user) to internal one (system)  */
/* Return 1 if OK else return 0                                  */

int SMConvAnglExtInt(input,output,osnum)
IGRdouble input;              /* [I] External unit to convert */
IGRdouble *output;            /* [O] Internal unit */
OMuword osnum;               /* [I] Work osnum     */
{
  IGRlong status,msg;
  
  status = uom$cvt_imp_to_wrk(msg =  &msg,
                             unit_type = GRIO_ANGLE,
                             osnum = osnum,
                             primary = input,
                             result  = output);
  return (status & msg & 1); 
}


/* ----------------- SMConvAnglIntExt ------------------------- */
/* Convert an internal Angle to external one                    */
/* Return 1 if OK else return 0                                 */

int SMConvAnglIntExt(input,output,osnum)
IGRdouble input;              /* [I] Internal unit to convert */
IGRdouble *output;            /* [O] External unit */
OMuword osnum;                /* [I] Work osnum     */
{
  IGRlong status,msg;
  IGRshort num_alias;
  IGRchar convert_array[150];
  
  num_alias = 1;
  status = uom$cvt_imp_to_alias(msg =  &msg,
				unit_type = GRIO_ANGLE,
				working_units = &input,
				osnum = osnum,
				num_alias = &num_alias,
				cvt_list = convert_array);          

  if(!(status & msg & 1)) return 0;
  
  if(sscanf(convert_array,"%lf",output) != 1) return 0;
  
  return 1;
}


/* ----------------- SMConvAnglIntUnit ------------------------- */
/* Convert an internal Angle to a specified unit                */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

int SMConvAnglIntUnit(input,unit,output,osnum)
IGRdouble input;      /* [I] internal value      */
IGRshort  unit;       /* [I] SMAN type of unit */
IGRdouble *output;    /* [O] external value      */
OMuword osnum;        /* [I] Work osnum          */
{
  IGRlong status;
  char *alias;

  if(unit & SM_UNIT_RAD)
    alias = "radians";
  else
    if(unit & SM_UNIT_DEG)
      alias = "degrees";
    else
      return 0;

  status = uom$cvt_dbu_to_value(osnum= osnum,
				ivalue = input,
				oalias = alias,
				ovalue = output);
  return (status & 1);
}

/* ----------------- SMConvAnglUnitInt ------------------------- */
/* Convert a specified unit to internal Angle                    */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */


SMConvAnglUnitInt(input,unit,output,osnum)
IGRdouble input;       /* [I] number of user unit to convert */
IGRshort  unit;       /* [I] SMAN type of unit */
IGRdouble *output;     /* [O] internal value */
OMuword osnum;         /* [I] Work osnum    */
{
  IGRlong status;
  char *alias;

  if(unit & SM_UNIT_RAD)
    alias = "radians";
  else
    if(unit & SM_UNIT_DEG)
      alias = "degrees";
    else
      return 0;
  
  status = uom$cvt_value_to_dbu(osnum = osnum,
				ivalue = input,
				ialias = alias,
				ovalue = output );
  return(status & 1);
}



/* ----------------- SMConvSurfIntExt -------------------------  */
/* Convert an external Surface to a internal                     */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

int SMConvSurfIntExt(input,output,osnum)
IGRdouble input;              /* [I] Internal unit to convert */
IGRdouble *output;            /* [O] External unit */
OMuword osnum;                /* [I] Work osnum     */
{

  IGRlong status;
  IGRdouble coef;

#if 0
  IGRlong msg;
  char  return_array[1][40];
  char alias[50];
  short num_defaults = 1;
  short flag = 0;

  status = uom$get_default_units( msg = &msg,
				 table_name = GRIO_DISTANCE,
				 flag = &flag,
				 num_defaults = &num_defaults,
				 default_units = return_array,
				 osnum = osnum);
  sprintf(alias,"sq_%s",return_array[0]);
  
  status = uom$cvt_dbu_to_value(osnum = osnum,
				ivalue = input,
				oalias = alias,
				ovalue = output);
  return (status & 1);
#endif

  status = SMConvDistIntExt(1.0,&coef,osnum);
  if(!(status & 1)) return 0;
  
  *output = coef * coef * input;
  return 1;
}
 

/* ----------------- SMConvSurfExtInt -------------------------  */
/* Convert an external Surface to a internal                     */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

int SMConvSurfExtInt(input,output,osnum)
IGRdouble input;              /* [I] Internal unit to convert */
IGRdouble *output;            /* [O] External unit */
OMuword osnum;                /* [I] Work osnum     */
{
  IGRlong status;
  IGRdouble coef;

#if 0
  IGRlong msg;
  char  return_array[1][40];
  char alias[50];
  short num_defaults = 1;
  short flag = 0;


  status = uom$get_default_units( msg = &msg,
				 table_name = GRIO_DISTANCE,
				 flag = &flag,
				 num_defaults = &num_defaults,
				 default_units = return_array,
				 osnum = osnum);
  sprintf(alias,"sq_%s",return_array[0]);
  
  status = uom$cvt_value_to_dbu(osnum = osnum,
				ivalue = input,
				ialias = alias,
				ovalue = output);
  return (status & 1);
#endif

  status = SMConvDistExtInt(1.0,&coef,osnum);
  if(!(status & 1)) return 0;
  
  *output = coef * coef * input;
  return 1;
}
 


/* ----------------- SMConvSurfIntUnit ------------------------- */
/* Convert an internal Surface to a specified unit             */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

SMConvSurfIntUnit(input,unit,output,osnum)
IGRdouble input;      /* [I] internal value      */
IGRshort  unit;       /* [I] SMAN type of unit */
IGRdouble *output;    /* [O] external value      */
OMuword osnum;        /* [I] Work osnum          */
{
  IGRlong status;
  IGRdouble coef;

#if 0
  char *alias;
  
  if(unit & SM_UNIT_MTR)
    alias = "sq_meters";
  else
    if(unit & SM_UNIT_MMTR)
      alias = "sq_millimeters";
    else
      if(unit & SM_UNIT_INC)
	alias = "sq_inches";
      else
	if(unit &  SM_UNIT_FT)
	  alias = "sq_feet";
	else return 0;

 
  status = uom$cvt_dbu_to_value(osnum= osnum,
				ivalue = input,
				oalias = alias,
				ovalue = output );
 
  return (status & 1);
#endif
  status = SMConvDistIntUnit(1.0,unit,&coef,osnum);
  if(!(status & 1)) return 0;

  *output = coef * coef * input;
  return 1;

}

/* ----------------- SMConvSurfUnitInt ------------------------- */
/* Convert a specified unit to internal Surface                  */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */


SMConvSurfUnitInt(input,unit,output,osnum)
IGRdouble input;       /* [I] number of user unit to convert */
IGRshort  unit;       /* [I] SMAN type of unit */
IGRdouble *output;     /* [O] internal value */
OMuword osnum;         /* [I] Work osnum    */
{
  IGRlong status;
  IGRdouble coef;

#if 0
  char *alias;
  
  if(unit & SM_UNIT_MTR)
    alias = "sq_meters";
  else
    if(unit & SM_UNIT_MMTR)
      alias = "sq_millimeters";
    else
      if(unit & SM_UNIT_INC)
	alias = "sq_inches";
      else
	if(unit &  SM_UNIT_FT)
	  alias = "sq_feet";
	else return 0;

  status = uom$cvt_value_to_dbu(osnum = osnum,
				ivalue = input,
				ialias = alias,
				ovalue = output );
  return(status & 1);
#endif

  status = SMConvDistUnitInt(1.0,unit,&coef,osnum);
  if(!(status & 1)) return 0;

  *output = coef * coef * input;
  return 1;
}

/* ----------------- SMConvVolIntExt -------------------------  */
/* Convert an external Surface to a internal                     */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

int SMConvVolIntExt(input,output,osnum)
IGRdouble input;              /* [I] Internal unit to convert */
IGRdouble *output;            /* [O] External unit */
OMuword osnum;                /* [I] Work osnum     */
{
  IGRlong status;
  IGRdouble coef;
#if 0
  IGRlong msg;
  char  return_array[1][40];
  char alias[50];
  short num_defaults = 1;
  short flag = 0;

  status = uom$get_default_units( msg = &msg,
				 table_name = GRIO_DISTANCE,
				 flag = &flag,
				 num_defaults = &num_defaults,
				 default_units = return_array,
				 osnum = osnum);
  sprintf(alias,"cu_%s",return_array[0]);
  
  status = uom$cvt_dbu_to_value(osnum = osnum,
				ivalue = input,
				oalias = alias,
				ovalue = output);
  return (status & 1);
#endif

  status = SMConvDistIntExt(1.0,&coef,osnum);
  if(!(status & 1)) return 0;
  
  *output = coef * coef *coef * input;
  return 1;
}
 

/* ----------------- SMConvVolExtInt -------------------------  */
/* Convert an external Volume to a internal                     */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

int SMConvVolExtInt(input,output,osnum)
IGRdouble input;              /* [I] Internal unit to convert */
IGRdouble *output;            /* [O] External unit */
OMuword osnum;                /* [I] Work osnum     */
{
  IGRlong status;
  IGRdouble coef;

#if 0
  IGRlong msg;
  char  return_array[1][40];
  char alias[50];
  short num_defaults = 1;
  short flag = 0;


  status = uom$get_default_units( msg = &msg,
				 table_name = GRIO_DISTANCE,
				 flag = &flag,
				 num_defaults = &num_defaults,
				 default_units = return_array,
				 osnum = osnum);
  sprintf(alias,"cu_%s",return_array[0]);
  
  status = uom$cvt_value_to_dbu(osnum = osnum,
				ivalue = input,
				ialias = alias,
				ovalue = output);
  return (status & 1);
#endif

  status = SMConvDistExtInt(1.0,&coef,osnum);
  if(!(status & 1)) return 0;
  
  *output = coef * coef *coef * input;
  return 1;
}
 


/* ----------------- SMConvVolIntUnit ------------------------- */
/* Convert an internal Volume to a specified unit             */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

SMConvVolIntUnit(input,unit,output,osnum)
IGRdouble input;      /* [I] internal value      */
IGRshort  unit;       /* [I] SMAN type of unit */
IGRdouble *output;    /* [O] external value      */
OMuword osnum;        /* [I] Work osnum          */
{
  IGRlong status;
  IGRdouble coef;

#if 0  
  char *alias;

  if(unit & SM_UNIT_MTR)
    alias = "cu_meters";
  else
    if(unit & SM_UNIT_MMTR)
      alias = "cu_millimeters";
    else
      if(unit & SM_UNIT_INC)
	alias = "cu_inches";
      else
	if(unit &  SM_UNIT_FT)
	  alias = "cu_feet";
	else return 0;

 
  status = uom$cvt_dbu_to_value(osnum= osnum,
				ivalue = input,
				oalias = alias,
				ovalue = output );
 
  return (status & 1);
#endif

  status = SMConvDistIntUnit(1.0,unit,&coef,osnum);
  if(!(status & 1)) return 0;

  *output = coef * coef * coef * input;
  return 1;

}

/* ----------------- SMConvVolUnitInt ------------------------- */
/* Convert a specified unit to internal Volume                  */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */


SMConvVolUnitInt(input,unit,output,osnum)                
IGRdouble input;       /* [I] number of user unit to convert */
IGRshort  unit;       /* [I] SMAN type of unit */
IGRdouble *output;     /* [O] internal value */
OMuword osnum;         /* [I] Work osnum    */
{
  IGRlong status;
  IGRdouble coef;
  
#if 0
  char *alias;
  if(unit & SM_UNIT_MTR)
    alias = "cu_meters";
  else
    if(unit & SM_UNIT_MMTR)
      alias = "cu_millimeters";
    else
      if(unit & SM_UNIT_INC)
	alias = "cu_inches";
      else
	if(unit &  SM_UNIT_FT)
	  alias = "cu_feet";
	else return 0;


  status = uom$cvt_value_to_dbu(osnum = osnum,
				ivalue = input,
				ialias = alias,
				ovalue = output );
  return (status & 1);
#endif

  status = SMConvDistUnitInt(1.0,unit,&coef,osnum);
  if(!(status & 1)) return 0;

  *output = coef * coef * coef * input;
  return 1;

}



/* ----------------- SMConvPtsExtInt --------------------------------  */
/* Convert array of external distance (user) to internal one (system)  */
/* Return 1 if OK else return 0                                        */

int SMConvPtsExtInt(input,nb_input,output,osnum)
IGRdouble input[];            /* [I] Array of  units to convert */
IGRint nb_input;              /* [I] Number of element in input array */
IGRdouble output[];           /* [O] Array of Internals unit */
OMuword osnum;                /* [I] Work osnum  */
{
  IGRlong status,msg;
  IGRint i;

  for(i=0; i < nb_input; i++)
   {
     status = uom$cvt_imp_to_wrk(msg =  &msg,
				 unit_type = GRIO_DISTANCE,
				 osnum = osnum,
				 primary = input[i],
				 result  = &output[i]);
     if(!(status & 1)) return 0;
   }

  return 1;
}


/* ----------------- SMConvPtsIntExt ------------------------- */
/* Convert an internal distance to external one                */
/* Return 1 if OK else return 0                                */

int SMConvPtsIntExt(input,nb_input,output,osnum)
IGRdouble input[];            /* [I] Array of internal unit to convert */
IGRint nb_input;              /* [I] Number of element in input array */
IGRdouble output[];           /* [O] Array of External unit */
OMuword osnum;                /* [I] Work osnum     */
{
  IGRlong status,msg;
  IGRshort num_alias;
  IGRchar convert_array[150];
  int i;
 
  num_alias = 1;

  for(i=0; i < nb_input; i++)
   {
     status = uom$cvt_imp_to_alias(msg =  &msg,
				   unit_type = GRIO_DISTANCE,
				   working_units = &input[i],
				   osnum = osnum,
				   num_alias = &num_alias,
				   cvt_list = convert_array);          

     if(!(status & msg & 1)) return 0;
     if(sscanf(convert_array,"%lf",&output[i]) != 1) return 0;
   } 
  
  return 1;
}


/* ----------------- SMConvPtsIntUnit ------------------------- */
/* Convert an array of internal distance to a specified unit    */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */

SMConvPtsIntUnit(input,nb_input,unit,output,osnum)
IGRdouble input[];    /* [I] internal value      */
IGRint  nb_input;     /* [I] Number of element in input array */
IGRshort  unit;       /* [I] SMAN type of unit   */
IGRdouble output[];   /* [O] external value      */
OMuword osnum;        /* [I] Work osnum          */
{
  IGRlong status;
  char *alias;
  int i;
  
  if(unit & SM_UNIT_MTR)
    alias = "meters";
  else
    if(unit & SM_UNIT_MMTR)
      alias = "millimeters";
    else
      if(unit & SM_UNIT_INC)
	alias = "inches";
      else
	if(unit &  SM_UNIT_FT)
	  alias = "feet";
	else return 0;

  for(i=0; i < nb_input; i++)
   {
     status = uom$cvt_dbu_to_value(osnum = osnum,
				   ivalue = input[i],
				   oalias = alias,
				   ovalue = &output[i]);
     if(!(status & 1)) return 0;
   }

  return 1;
}

/* ----------------- SMConvPtsUnitInt ------------------------- */
/* Convert a specified unit to internal distance                 */
/* The unit is given with a flag  (see SMdef.h)                 */         
/* Return 1 if OK else return 0                                 */


SMConvPtsUnitInt(input,nb_input,unit,output,osnum)
IGRdouble input[];     /* [I] Array of  user unit to convert */
IGRint  nb_input;      /* [I] Number of element in input array */
IGRshort  unit;        /* [I] SMAN type of unit */
IGRdouble output[];     /* [O] internal value */
OMuword osnum;         /* [I] Work osnum    */
{
  IGRlong status;
  char *alias;
  int i;
  
  if(unit & SM_UNIT_MTR)
    alias = "meters";
  else
    if(unit & SM_UNIT_MMTR)
      alias = "millimeters";
    else
      if(unit & SM_UNIT_INC)
	alias = "inches";
      else
	if(unit &  SM_UNIT_FT)
	  alias = "feet";
	else return 0;

  for(i=0; i < nb_input; i++)
   {
     status = uom$cvt_value_to_dbu(osnum = osnum,
				   ivalue = input[i],
				   ialias = alias,
				   ovalue = &output[i] );
     if(!(status & 1)) return 0;
   }

 return 1;
}













