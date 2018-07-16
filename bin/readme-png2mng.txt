NAME
       png2mng.pl - combine a set of PNG images into an animated MNG image

SYNOPSIS
       png2mng.pl basename width height

DESCRIPTION
       png2mng.pl  reads  a  sequence  of  PNG images and combines them into a
       single animated MNG image.

       The individual PNG images should be numbered  consecutively  from  zero
       up,  and  should  have names of the form basenameXXXX where XXXX is the
       four-digit sequence number (0000, 0001,  0002,  etc).   The  width  and
       height of the PNG images should also be included on the command line.

       The final animated MNG image will be written to standard output.

       This utility is part of the KDE Software Development Kit.

EXAMPLE
       The  following example will combine the files hi32-action-kde-0000.png,
       hi32-action-kde-0001.png, hi32-action-kde-0002.png, etc., and write the
       resulting animated image to hi32-action-kde.mng:

              png2mng.pl hi32-action-kde- 32 32 > hi32-action-kde.mng