Originator : Melania Stewart - July 24, 1996

    This directory contains dlls used by RIS:
        i9shamr1.dll
        i9ums1.dll
        msvcrt10.dll - Required by the ORACLE dataservers.
        template.pcd - TR#439601821 and TR#439601820 : This pcd file 
            will fix the problem where SMS installation will fail if the
            SMS.INI file is in another drive than C:. Since SETUPSDK
            may not release again, we are keeping this file in our source 
            tree. The original version is in <SETUPSDK>\msdsetup\template.pcd,
            in case it is decided that we have to build a new version of SETUPSDK.
