/*

 Class specification for super_ci
 Subclass of global_class

 Abstract:
   super_ci is a super_object keeping track of all PPL objects it has been
   requested to load. Therefore, given a file name, it can decide to load a
   new PPL object, or to clone an appropriate object, if it is aware of one.
   This feature minimize memory space, taking advantage of CI reentrance.

 Message overridden, motivation:
   super_construct
	Initialization of some globals.
   wake_up
	If not "desactivated", initialization of some globals.
   sleep(int pos)
	If pos == 1: The design file is going to be saved and closed.
	  The super object deallocates the memory. If ever the loaded CI 
	  objects are to receive the "sleep" message, it can be sent from here.
	If pos == 0: The design file is going to be saved only, and the super
	  object will soon receive a "wake_up" message which is  "desactivated"
	  from here.
 History:
    GARDELLA D.	08/03/88 :  creation.

*/

class specification super_ci (0:1) of global_class;

override	wake_up,
		global_class.sleep,
		super_construct;

end specification super_ci;
