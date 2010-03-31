#ifndef OPTIONS_H
#define OPTIONS_H

#define OPTION_DISP_IMAGE       0
#define OPTION_CONV_BMP         1
 
struct option_node
   {
   int                  type;
   char                 *filename;
   struct option_node   *next;
   };
 
extern char	GetOptions( int, char **, struct option_node ** );

#endif
