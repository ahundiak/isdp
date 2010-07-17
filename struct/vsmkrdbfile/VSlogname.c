/*
  Function: vslogname().

  Returns : *char
	    (the login name of the user).

*/

#include <stdio.h>
#include <pwd.h>

struct passwd *VSpasswd_ptr;

char *vslogname()
  {
    extern struct passwd *VSpasswd_ptr;

    VSpasswd_ptr = getpwuid (getuid ());
    return (VSpasswd_ptr->pw_name);
  }
