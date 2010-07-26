class specification COcisetup (1:0) of super_cmd ;

#include "ci.h"

instance COcisetup {
	IGRint	action ;
} ;

override init, wakeup, super_cmd.sleep, execute, delete, form_input ;

end specification COcisetup ;
