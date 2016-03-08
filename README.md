# CRUK Reverse The Odds image transformation script

## Basic idea

This Ruby script is used to  transform tissue micro-array (TMA) images for use in
Cancer Research UK's Reverse The Odds game.  It takes images from a source folder, transforms them,
writes them out to a target folder and creates a file of image metadata to describe the transformed images.

## Prerequisites

imagemagick (6.9.3-0 or later) must be installed.  Can be downloaded from [http://www.imagemagick.org/script/binary-releases.php]

## Image transformation

The script does the following to each source image
- segments the source image into a 6x6 or 4x4 array of subimages
- invert the colours so background is black rather than white
- changes colours and increases saturation

All of the above is done by calling the imagemagick convert command.
See online imagemagick documentation for details of parameters [http://www.imagemagick.org]

## File processing

Given a source folder the script recursively converts all images in that folder and all enclosed folders.
The enclosed folder structure is preserved in the target folder.

Each source image produces multiple target images (one for each of the segments).
These are collected together in a folder that is named after the source image.
In order to anonymise images a guid is used in place of the source image name.
The mapping between source file name and guid is recorded in the metadata file.
Each target image is named \<guid>_\<segment number>.jpg

For 6x6 transformations the outer images are discarded resulting in only
the central 4x4 set of image segments being saved.
The reason for this is that the outer segments often contain very little tissue
and so add little value to the analysis

## Image metadata

Image names are changed to ensure anonymity.  As a consequence any information encoded in the name is lost.
To preserve this, and add extra metadata, a metadata file (manifest.json) is created as part of the transformation process.
Some metadata is image specific, other is common to the whole batch of images being transformed.
Common metadata values are set as constants within the script:
 - collection - the name of the collection from which these images was taken
 - stain_type - the type of stain used in the images

## Changing transformation behaviour

The script has been written so that it is easy to change its behaviour in certain areas:

- source folder
- target folder
- source image type (jpeg, tiff)
- transformation details

These are all set up as constants at the top of the script and can be changed as needed

Normally the script creates only one version of the transformed image.    However there is an option to create a range
of transformed images with different transformations.  This can be useful when experimenting with new image types to find an optimal transformation.
To switch this mode on set $create_colour_range to true

## Copyright / Licence

Copyright 2016 Cancer Research UK

Source Code License: The GNU Affero General Public License, either version 3 of the License or (at your option) any later version. (See agpl.txt file)

The GNU Affero General Public License is a free, copyleft license for software and other kinds of works, specifically designed to ensure
cooperation with the community in the case of network server software.

Documentation is under a Creative Commons Attribution Noncommercial License version 3.

