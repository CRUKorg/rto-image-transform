# CRUK Reverse The Odds image transformation code

## Basic idea

This Ruby script is used to process to transform tissue micro-array (TMA) images for use in
Cancer Research UK's Reverse The Odds game.  It takes issues from a source folder, transforms them,
writes them out to a target folder and creates a file of image metadata to describe the transformed images.

## Image transformation

The script does the following to each source image
- segments the source image into a 6x6 or 4x4 array of subimages
- invert the colours so background is black rather than white
- changes colours and increases saturation

All of the above is done by calling the imagemagick convert command.
See online imagemagick documentation for details of parameters [http://www.imagemagick.org]

## File processing

Given a source folder the script recursively converts all images in that folder and all enclosed folders.
The enclosed folder structure is preserved in the target folder
