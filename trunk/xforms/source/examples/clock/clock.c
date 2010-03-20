#include <stdio.h>
#include <X11/Xlib.h>
#include <sys/types.h>
#include <sys/lock.h>
#include "time.h"
#include "FI.h"

#include "XFIproto_pub.h"

#define READOUT     14
#define INTERVAL	5
char buffer[20];


time_t time();
time_t the_time;







struct tm *localtime();
struct tm *t;

char *time_string;


/*
struct tms *localtime();
struct tms *t;
*/




main (argc, argv)
int	argc;
char	*argv[];
{
	char *display_name = "";
    Display		*display;

    int hour;
	int min;
	Form form;
	XEvent event;




	char dummy1[20], dummy2[20], dummy3[20];


/*
    plock ( PROCLOCK );
*/
    if ( (display=XOpenDisplay(display_name)) == None )
    {
    	fprintf( stderr, "%s: cannot connect to X server %s\n",
    		XDisplayName(display_name) );
    	exit( -1 );
    }

    FSEnter ( display, 0 );

	FI_enter( display, (Colormap) NULL, (int) NULL );
/*
    FI_set_font_path ( ".:..:/usr/ip32/resrc/bsfont" );
*/
	the_time = time(0);
	printf("after getting the_time\n");

	if (the_time == -1)
	{
	  printf("the_time = -1\n");
	  exit(0);
	}
	t = localtime(&the_time);
	time_string = asctime(t);
	printf("after getting time_string\n");

	sscanf(time_string, "%s %s %s %d:%d", dummy1, dummy2, dummy3, 
		&hour, &min);

	if (hour > 12)
	  hour = hour - 12;
	printf("TIME:  %d:%d\n", hour, min);
	
	sleep(INTERVAL);

    FIf_new ( 100, "clock.form", NULL, &form );
    FIf_display ( form );


/*
    FIf_get_window ( form, &window );

    Set_win_auto_act ( window, 0 );
    Set_win_sys_icon ( window, DELETE_ICON_VALUE, 1 );

    Start_timer ( 60, 1, &timer_no );
*/

	  	
    while ( FI_forms_active() )
    {
		 XNextEvent (display, &event);

	sleep(INTERVAL);

	the_time = time(0);
	if (the_time == -1)
	  exit(0);
	t = localtime(&the_time);
	time_string = asctime(t);

	sscanf(time_string, "%s %s %s %d:%d", dummy1, dummy2, dummy3, 
		&hour, &min);

	if (hour > 12)
	  hour = hour - 12;
	printf("TIME:  %d:%d\n", hour, min);
	
				sprintf ( buffer, "%2d:%02d", hour,min );
	
				if ( buffer[0] == ' ' )
					strcpy ( buffer, &buffer[1] );
					
				FIg_erase    ( form, READOUT );
				FIg_set_text ( form, READOUT, buffer );
				FIg_display  ( form, READOUT );
				
    }

   XCloseDisplay (display);
}
