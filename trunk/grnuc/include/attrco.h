#ifndef attrco_include
#define attrco_include

/*
 * Additional structure types.
 */
#define CO_wakeup_message   10  /* This is used to signal a status display that is */
                                /* happening at wakeup. */

/*
 * Additional attribute types.
 */
#define CO_epdel        4194304     /* 0x00400000 .... .... .1.. .... .... .... .... .... */
#define CO_apdel        8388608     /* 0x00800000 .... .... 1... .... .... .... .... .... */
#define CO_ang2pts      16777216    /* 0x01000000 .... ...1 .... .... .... .... .... .... */
#define CO_ang3pts      33554432    /* 0x02000000 .... ..1. .... .... .... .... .... .... */
#define CO_scale3pts    67108864    /* 0x04000000 .... .1.. .... .... .... .... .... .... */
#define CO_angunit      134217728   /* 0x08000000 .... 1... .... .... .... .... .... .... */
#define CO_disunit      268435456   /* 0x10000000 ...1 .... .... .... .... .... .... .... */
#define CO_areaunit     536870912   /* 0x20000000 ..1. .... .... .... .... .... .... .... */


/* 
 * Locks Command types
 */
#define ARCDIR          3
#define BORELINE        5
#define APPFLGON	7
#define APPFLGOFF	9
#define ABSFLGON	11
#define ABSFLGOFF	13
#define TXINDON         15
#define TXINDOFF        17
#define DYNON		19
#define DYNALL		21
#define RFLCON		23
#define RFLCOF		25
#define FILMOD          27
#define TXFILMOD        29

/*
 * PRIV: These are NOT attribute types!!!
 */
#define CO_pattern      (CO_epdel | CO_apdel)
#define CO_construct	(CO_ang2pts | CO_ang3pts | CO_scale3pts)
#define CO_units        (CO_angunit | CO_disunit | CO_areaunit)
#endif
