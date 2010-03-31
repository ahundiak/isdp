/*
  DESCRIPTION

    This file contains C macro developed for the interference analysis in
    EMS.
  Creation :
 
    Srividya P. - 31st Oct 95
 

*/

#ifndef EMSintfmacros_include_
#define EMSintfmacros_include_

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) ()
#else
#define __(args) ()
#endif
 
#if defined(__cplusplus)
extern "C" {
#endif
 

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exdef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

extern IGRlong EManalyzeInterference __((
IGRlong *EMmsg;
struct GRlc_info *SetInfo1, *Ele1;
IGRint NumEle1, setnum1;
struct GRlc_info *SetInfo2, *Ele2;
IGRint NumEle2, setnum2;
IGRushort options;
IGRchar *ReportFileName
));

#if defined(__cplusplus)
}
#endif
 
/* The macro analyses the interference between different sets of elements

   Arguments:
   SetInfo1	input	The set information
   Ele1         input   Set of elements to be checked for interference.
			There will be a structure per element.
   NumEle1	input   Number of Elements in the above array.
   setnum1      input   The index or number of the set
                        that should be included in the report
   SetInfo2     input   The set information
   Ele2         input   Set of elements against which each
                        element of the first set is to
                        be checked.
   NumEle2      input   Number of elements in above array
   setnum1      input   The index or number of the set
                        that should be included in the report
   options     input    
  options =value     output desired
            0        output of intersection curves is not desired, 
		     Intf volume elements should not be added 
		     No area elements and no display of curves/volumes.
            1        output of intersection curves is desired, 
                     Intf volume elements should  be added
                     area elements and  display of curves/volumes.
            2        only intersection curves and display of curves
            3        only intf volume curves and display of volume elems
	    4        only area elems and their display.
            5        only curves and volume elems and their display 

	        
   fileName  input           Filename in which the report is to
                             be written. If NULL is passed,stdout is used.
   
   
*/
#undef __

#omdef ems$analyze_intf(msg,
			Setinfo1,
			Ele1,
			NumEle1,
			setnum1,
			Setinfo2,
			Ele2,
			NumEle2,
			setnum2,
			options=0, 
			filename =NULL)

EManalyzeInterference((msg),(Setinfo1),(Ele1),(NumEle1),(setnum1),
                            (Setinfo2),(Ele2), (NumEle2),(setnum2),
                            (options),(filename))
#endomdef
#endif
