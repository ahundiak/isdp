#include <stdio.h>
#include <sdl.h>
#include <tools.h>
#include <ctype.h>

#define  debug 1

main()
{
    int mask = 1;
    int em;
    int w_no,x2,y2,x1,y1,button,tran,time;
    int xx1,yy1,xx2,yy2;
    int rno;

    printf("\nTracking area should not overlap with any other type\n");
    printf("of digitize region. ( paper menu etc).\n");
    printf("If you overlap tracking area and other digitize region,\n");
    printf("you have to use command button in the overlapped area.\n");


    Enter_tools();
    Enable_events(BUTTON_EVENT );
    Set_message_mode(1);

    Inq_dig(&x1,&y1);
    Create_dig_region(0,0,0,x1,y1,&rno);   

        Set_dig_btn(rno,mask);

 
            Display_message(1,3,"Give first diagonal point of tracking area ( use command button only )");
            Wait_for_next(BUTTON_EVENT, &em);
            Get_button_data(&w_no,&x1,&y1,&button,&tran,&time);
            Keybdbell(0);
#if debug
            printf("w_no=%d x1=%d y1=%d button=%d tran=%d\n",w_no,x1,y1,button,tran);
#endif

            Display_message(1,3,"Give second diagonal point of tracking area ( use command button only )");
            Wait_for_next(BUTTON_EVENT, &em);
            Get_button_data(&w_no,&x2,&y2,&button,&tran,&time);
            Keybdbell(0);

#if debug
            printf("w_no=%d x2=%d y2=%d button=%d tran=%d\n",w_no,x2,y2,button,tran);
#endif


        Delete_dig_region(rno);
        xx1=xx2=yy1=yy2=0;
        xx1 = ( x1 < x2 ) ? x1 : x2;
	xx2 = ( x1 < x2 ) ? x2 : x1;
        yy1 = ( y1 < y2 ) ? y1 : y2;
	yy2 = ( y1 < y2 ) ? y2 : y1;

printf( "\nwindow tracking area set to  <%d><%d>   <%d><%d>\n",xx1,yy1, xx2,yy2);
       Set_trackarea(0,xx1,yy1,xx2,yy2);

        Exit_tools();
    exit(1);
}
















