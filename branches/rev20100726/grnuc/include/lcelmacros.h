#ifndef  lcelmacros_include
#define  lcelmacros_include


/*\
Name
   lc$locate_eligible

Description
   This routine provides the ability to setup the locate eligibility
   criteria. It helps in bypassing the form interface for setting
   the criteria. It has been designed for the sake of ATP's.

Input
   The routine needs two inputs. 
   classname = The name of the class which is to be set/cleared. The
               name should be as is displayed in "Locate Eligibility
               Form". 
   setbit    = an int value to indicate the status to be set. It has
	       4 options.

               CLEARALL      -  To remove locate eligibility for all classes 
               SETALL        -  To set locate eligibility for all classes
               CLASSCLEAR    -  To remove locate eligibility for given class 
               CLASSSET      -  To set locate eligibility for given class 

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/

#define CLEARALL        0
#define SETALL          1
#define CLASSCLEAR      2
#define CLASSSET        3

#omdef lc$locate_eligible( classname = NULL,
                           setbit = CLEARALL)

   LClocate_eligible ((classname), (setbit) )
#endomdef

#endif
