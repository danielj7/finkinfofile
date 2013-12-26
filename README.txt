FinkInfoFile metadata importer for Spotlight
Copyright (c) 2006-2013 Daniel Johnson. All rights reserved.
daniel@daniel-johnson.org

This file is part of FinkInfoFile.

FinkInfoFile is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

FinkInfoFile is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FinkInfoFile; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

Instructions for use:

Install FinkInfoFile.pkg

	Or if you want to install for just the current user:

1. Copy FinkInfoFile.mdimporter from the package_contents folder to ~/Library/Spotlight

2. From Terminal type: mdimport /sw/fink
   (or whereever you keep your fink tree)

Spotlight will now index all fink *.info files.

The following metadata are currently indexed (in addition to the plain text content, but searching metadata is faster than content):
Title = Package
Authors = Maintainer
Email addresses = Maintainer
Description = Description
Instructions = DescDetail
Version = Epoch:Version-Revision

Source code is included in the Source folder that should accompany the FinkInfoFile.pkg file.

The importer is now built as a Universal Binary.

The latest version of this importer can be found at http://homepage.mac.com/danielj7 or http://www.daniel-johnson.org.