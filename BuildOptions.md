### -Defines ###

#### Defined in MKDOPT, MKMKOPT, ####
```
MKDOPT
  -DX11
  -DRUN_X=1

  -DNOT_SHARABLE Does not seem to be used
  -DINTEL == Used in a few spots

  -DLITTLE_ENDIAN really should be __LITTLE_ENDIAN

  -Di386
  -D__i386
  -D__i386__

  -DINGR == used in a few spots
  -Dunix=1

  -D__Sol2__ == Used in one place, PDU emsfixes

  -DRISV5 == Part of RIS???

  -DSYSV == Used in /usr/include
  -DSYS5 == Not used at all

  -DSUNOS
  -DSUNOS5
    /usr/include NO
    isdp various

  -DISDP_MAKE_SP=1

MKMKOPT
  -i /opt/ingr/grnucdp/Isl.mkmk

```
#### Predefined macros ####
```
man -1 cc

unix (not in Xc)
sparc (SPARC)
sun  (not in Xc)

__BUILTIN_VA_ARG_INCR
__SUNPRO_C=0x510
__SVR4(SPARC)
__SunOS_OSversion _OSversion(SPARC)
__amd64(x86 with-m64)
__gnu__linux(linux)
__i386(x86)
__linux(linux)
__linux__(linux)
__sparc(SPARC)
__sparcv9(with-m64)
__sun(Solaris)
__unix
__`uname -s`_`uname -r | tr . _` __SunOS_5.10_

__x86_64(x86)

__RESTRICT -Xa and -Xt
__PRAGMA_REDEFINE_EXTNAME

Also have
__STDC__ 1 for -Xc, 0 for -Xa

```

### C Options ###
```
Solaris 08 = -Xc -xCC -xO1 -W0,-xd -K PIC
Solaris 10 = -Xa -xCC              -Kpic -m32 -w -features=no%conststrings
COMPOPT
```
#### -Xc or -Xa ####
```
-Xc Strict
-Xa K&R extensions

Want to stick with -Xc, know we had an earlier issue and went to Xa for awhile for Solaris 10
Need to revisit the problem and fix differently

Had used -D__EXTENSIONS__ but that causes issues with omcpp stdio.h
```
#### -W0,-xd ####
Passes -xd to 0  acomp component, c front end compiler

-# or -v for verbose

#### -w ####
Suppresses warnings, get a bunch of them

#### -features=no%conststrings ####
Overrides the default of making constant strings read only

#### -m32 ####
Forces memory model to 32 bit, probably not required but keep it anyways

#### -x01 ####
Optimization level 1

Leave off for now for Solaris 10, more concerned with debugging than speed


#### -m32 ####
32 bit model, probably not required

#### -Kpic ####
Dynamic loading

#### -xCC ####
Just to support CC style options

#### -g ####
debug information
