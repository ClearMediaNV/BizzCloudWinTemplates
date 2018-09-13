@ECHO OFF
MD C:\temp
MSIEXEC /I "%~dp0Sticky Notes Classic.msi" /qn /lv* "c:\temp\StickyNotesClassicinstall.txt"  /norestart