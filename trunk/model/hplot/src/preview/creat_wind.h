#ifndef CREAT_WIND_H
#define CREAT_WIND_H

/*--- create_window --------------------------------------------*/

extern 
WLuint32 create_window( WLuint16 screen_no,
                        WLuint32 context_no,
                        int x, 
                        int y,
                        int width,
                        int height,
                        WLuint32 *lwin_no,
                        struct WLraster_data *image,
                        char **image_buffer );

#endif
