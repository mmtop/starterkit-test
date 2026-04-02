# Propagator Corrected MS
## Theoretical Framework
The CMS approximates the Ewald sphere as a parabola.
Therefore, it is only accurate for small scattering angles which is not a good approximation when the accelerating voltage is lower and the electrons scatter at higher angles.
An improved algorithm which accounts for this, a modification of Eq.[](#multislice-simplified-schrodinger), was recently proposed @Ming2013.

```{figure} ./images/Ewald_sphere_approximation.png
:label: Ewald_sphere_approximation
:width: 60%
:align: center

Approximation of the Ewald sphere by a parabola @Chen1997
```
$$
\varphi_j(\mathbf{R}) = \exp \left[ i\varepsilon \left( 2\pi K_0 \left[ \sqrt{1 + \frac{\Delta}{(2\pi K_0)^2}} - 1 \right] + \sigma U_j(\mathbf{R}) \right) \right] \varphi_{j-1}(\mathbf{R})
$$

We end up with the laplace operator inside a square root which is tricky to implement numerically.
Therefore, we again take the Taylor expanded form:

(propagator_corrected_multislice_taylor_series)=
$$
   \varphi_j(\mathbf{R}) = \exp \left[ i\varepsilon \left\{ \left[ \frac{\Delta}{4\pi K_0} + \sigma U_j(\mathbf{R}) \right] - \frac{1}{4\pi K_0} \left( \frac{\Delta}{4\pi K_0} \right)^2 + \frac{1}{8\pi^2 K_0^2} \left( \frac{\Delta}{4\pi K_0} \right)^3 - \dots \right\} \right] \varphi_{j-1}(\mathbf{R})
$$
Here we find the CMS operator inside the square brackets in addition to a series of higher order terms to correct for the Ewald sphere curvature.

## Python Implementation
Eq.[](#propagator_corrected_multislice_taylor_series) can be implemented numerically by utilizing the same method used for the exponent series where the higher powers of the propagator part can be calculated by applying the operator multiple times.
After adding the right prefactor and taking the exponent we end up with correct result [Code. 3](#propagator-taylor-series).

To calculate the exponent of this series we use the same exponential as in the previous chapter [Code. 2](#multislice_exponential-series).

## Results
In order to compare the propagator corrected multislice as fairly as possible to the conventional multislice, we will perform the conventional multislice calculations in realspace. 
Keeping the calculations in realspace creates some artifacts compared to the fourier version, especially at low voltages (see @FFTvsRS), due the approximation of the laplacian by a finite difference stencil.
However, since the fully corrected multislice can only be implemented in realspace, we decided to calculate the CMS in realspace as well.
For the simulation a sampling interval of 0.1 Å x 0.1 Å was used and a slice thickness of 0.05 Å.

The two methods (realspace MS and PCMS) are applied to a crystal of SrTiO3 @osti_1263154 with size of (1x1x24) unit cells and (1x1x48) unit cells for planewaves of different energies. 
The propagator corrected operator is chosen to include up to the third power correction term.
To speed up calculations, the existing laplace stencil provided by abTEM was adapted to be able to utilize the GPU.
All calculations were performed on a NVIDIA A40 GPU @imphys_hpc_hardware. 

After calculating the exitwave we apply a PixelatedDetector provided by abTEM which gives us the intensity of the diffraction patterns.
Because most electrons pass by the sample without scattering, the central pixel corresponding to the unscattered beam is very bright compared to the diffracted rays.
For that reason in the next plot the central pixel is set to 0.
To even further enhance visible detail the power of 0.25 is applied to the image.

::::{tab-set}
:::{tab-item} 24 unit cells z thickness
```{figure} ./plots/SrTiO3_PW_24_(PC)_blockdirect.png
:label: SrTiO3_PW_24_PC_blockdirect
:width: 100%
:align: center

Diffraction patterns for SrTiO$_3$ illuminated by planewave for different energies with 24 unitcells thickness in z axis and power=0.25
```

:::

:::{tab-item} 48 unit cells z thickness
```{figure} ./plots/SrTiO3_PW_48_(PC)_blockdirect.png
:label: SrTiO3_PW_48_PC_blockdirect
:width: 100%
:align: center

Diffraction patterns for SrTiO$_3$ illuminated by planewave for different energies with 48 unitcells thickness in z axis and power=0.25
```
:::
::::


In the next plots we are comparing the difference between the two methods.
Instead of blocking the direct beam and taking a power we calculate the lower and upper 3\% quantiles of the two upper rows combined as well as for the difference plot and clip the image using those values.
% You should probably use histogram clipping per energy, i.e. per column -- otherwise the higher energies appear saturated.
The result is the same dynamic range for all images allowing for a greater comparison.
In the lowest row, the two plots are subtracted and again clipped by the 3\% quantiles of all subtracted plots combined.

::::{tab-set}
:::{tab-item} 24 unit cells z thickness
```{figure} ./plots/SrTiO3_PW_24_(PC)_magma.png
:label: SrTiO3_PW_24_PC
:width: 100%
:align: center

Comparison of the conventional multislice (CMS) and the propagator corrected multislice (PCMS) for SrTiO$_3$ with 24 unitcells thickness in z axis
```

:::

:::{tab-item} 48 unit cells z thickness
```{figure} ./plots/SrTiO3_PW_48_(PC)_magma.png
:label: SrTiO3_PW_48_PC
:width: 100%
:align: center

Comparison of the conventional multislice (CMS) and the propagator corrected multislice (PCMS) for SrTiO$_3$ with 48 unitcells thickness in z axis
```
:::
::::
