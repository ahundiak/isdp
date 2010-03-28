#ifndef cctspec_include
#define cctspec_include 1

struct  vlt_slot
             {
              unsigned long pixel;
              unsigned short red,green,blue;
              char flags;
              char pad;
              };

struct rgb_color 
             {
             unsigned short red;
             unsigned short green;
             unsigned short blue;
             };

#endif /* cctspec_include */
