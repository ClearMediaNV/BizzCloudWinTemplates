@ECHO OFF
MD "%windir%\logs\StickyNotes"
MSIEXEC /I "%~dp0Sticky Notes Classic.msi" /qn /lv* "%windir%\logs\StickyNotes\StickyNotesClassicinstall.txt"  /norestart