echo rebuilding Fontware
make pc_make
echo testing 'makebmap.exe'
makebmap ..\font\font0003.bco -l 10
