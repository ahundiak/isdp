/*  math.h, /usr/include, 02/11/83
    standard c math functions

    Changes:
      83/02/10  cas  added log10, HUGE                           
*/   

extern double fabs(), floor(), ceil(), fmod(), ldexp();
extern double sqrt(), hypot(), atof();
extern double sin(), cos(), tan(), asin(), acos(), atan(), atan2();
extern double exp(), log(), log10(), pow();
extern double sinh(), cosh(), tanh();
extern double gamma();

/*  removed because of variable-name conflicts           */
/*  extern double j0(), j1(), jn(), y0(), y1(), yn();    */

#define HUGE   0.3595386269724631e+309
