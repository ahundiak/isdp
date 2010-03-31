/* This file contains the options used by the initialization method of the
   loop. These options are defined to be 'negative' so that by default the
   caller (by using NULL) gets all the processing options. If any of these
   options is used it is callers responsibility to send in appropriate
   property mask.
*/

#define EMLpInit_NoClosureTest	0x0001 /* This option will prevent the method
					  from performing a closure test
					  (and setting the property 
					   appropriately).*/
					
#define EMLpInit_NoRange	0x0002 /* Loop range should not be set upon
					  initialization. If this option
					  is set the loop range should be
					  valid BEFORE calling lpinit.*/
					
#define EMLpInit_NoLoopType	0x0004 /* The P/C property should not be
					  determined even if the loop is
					  closed.*/
					
#define EMLpInit_IgnoreInProps	0x0008 /* Do not transfer the incoming props
					  into the loop instance data.*/
					
