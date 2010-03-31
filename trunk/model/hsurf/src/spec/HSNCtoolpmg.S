
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

/*	CLASS NAME:	HSNCtoolpmg
	SUBCLASS OF:	global_class
	ABSTRACT:	a "super" object that manages objects of the
			  class HSNCtoolpath.
	CHANNELS DECLARED:	tp - a channel to objects of the class
				  HSNCtoolpath.
	MESSAGES DECLARED:	(none)
	CHANGE HISTORY:    DH    07/05/88    :    Design date
-------------------------------------------------------------------------
		C L A S S   D E S C R I P T I O N
-------------------------------------------------------------------------
*/
class specification HSNCtoolpmg (1:0) of global_class;

instance HSNCtoolpmg
  {
    channel {(one_to_many)} tp;
  };

end specification HSNCtoolpmg;
