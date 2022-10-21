# PointwiseAutoMesh
Glyph scripts for automatic meshing of 2D profiles through Pointwise

## Main features
1. Automatically spline the input profile
2. Creation of both Euler and Navier-Stokes (with boundary layer) meshes
3. Create Unstructured and Structured meshes in .su2 and .cgns format
4. Outputs some important mesh quality metrics (number of cells, skewness etc..) as min and max values both to screen and to a file
5. Possibility of including multi-line airfoils
6. Create mesh with wind Tunnel walls

Example of structured mesh:
![alt text](https://github.com/rois1995/PointwiseAutoMesh/blob/main/2D/StructuredMesh.png)

Example of multi-line airfoil unstructured mesh
![alt text](https://github.com/rois1995/PointwiseAutoMesh/blob/main/2D/MultiLineAirfoil.png)

Example of quad-dominant Euler mesh
![alt text](https://github.com/rois1995/PointwiseAutoMesh/blob/main/2D/EulerMesh.png)

Example of quad-dominant Euler mesh
![alt text](https://github.com/rois1995/PointwiseAutoMesh/blob/main/2D/WindTunnelModel.png)

## Pre-requisites
Pointwise software has to be installed on your machine. Version 18.4 is required. 

The input requested comprehends .dat files containing the coordinates of the each element of the airfoil (Ex: UpSurface.dat, LowSurface.dat, BluntTE.dat etc..). If the trailing edge is sharp, at least 2 lines are required, one for the upper and one for the lower surface of the airfoil. Otherwise, you must include also the line representing the railing edge. These files must be within the same folder from where the script is launched.

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
4. Copy the .dat files in the same folder where you have the CreateMesh.glf script
5. Run pointwise (you have to have it inserted within the PATH to run it from command line)
```
pointwise -b CreateMesh.glf
```
6. Enjoy the mesh!

## To-do list
- Implement multi airfoil (slat, flap etc..)
- Include backward compatibility with older versions of Pointwise
- Extend list of mesh formats
- Include checks on geometry

## Contact me 
For more informations contact me at rauxa1995@hotmail.it

