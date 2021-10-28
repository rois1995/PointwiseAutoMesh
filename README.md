# PointwiseAutoMesh
Glyph scripts for automatic meshing of 2D profiles through Pointwise

## Main features
1. Automatically spline the input profile
2. Creation of both Euler and Navier-Stokes (with boundary layer) meshes
3. Create Unstructured and Structured meshes in .su2 and .cgns format
4. Outputs some important mesh quality metrics (number of cells, skewness etc..) as min and max values both to screen and to a file

## Pre-requisites
Pointwise software has to be installed on your machine. Version 18.4 is required. 

The input requested comprehends two files for the upper and lower surface of the airfoil, namely UpSurface.dat and LowSurface.dat . These files must be within the same folder from where the script is launched.

The settings file, namely settingsPointwise.cfg, must be in the same folder from where the script is launched. Most of the settings have been described within the file. If some description is missing or is not clear, please contact me.

## How to use
To launch the scripts on Ubuntu/MacOS:

1. Clone the repository on your computer 
```
git clone https://github.com/rois1995/PointwiseAutoMesh.git
```
2. Go to the 2D folder
```
cd PointwiseAutoMesh/2D
```
3. Modify the settings file to convenience
4. Copy the LowSurface.dat and UpSurface.dat in the same folder where you have the .glf scripts
5. Run pointwise (you have to have it inserted within the PATH to run it from command line)
```
pointwise -b CreateMesh.glf
```
6. Enjoy the mesh!

## To-do list
- Implement multi-line airfoil (airfoil divided into sections)
- Implement multi-element airfoil (slat, flap etc..)
- Include backward compatibility with older versions of Pointwise
- Extend list of mesh formats
- Extend import options

## Contact me 
For more informations contact me at rauxa1995@hotmail.it

