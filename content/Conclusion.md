# Conclusion
This thesis presented the open-source implementation of two more accurate multislice algorithms, namely the propagator corrected multislice (PCMS) and the fully corrected multislice (FCMS). Both methods were implemented into
the open-source Python package abTEM, and the contribution is now under review by the package maintainers. These
methods address the limitations of the conventional multislice (CMS) algorithm, specifically the parabolic approximation of the Ewald sphere and the lack of backscattering contributions, which degrades in accuracy at low electron
energies.

Comparative analysis of SrTiO3 simulations confirms that for high electron energies (200 keV), all three methods
yield nearly identical diffraction patterns. This validates the CMS for ordinary TEM simulations. However, significant
divergence is observed as the electron energy decreases. Consistent with theoretical predictions, deviations between
CMS and the corrected methods become noticeable below 50 keV.

The PCMS and FCMS methods remain in agreement down to approximately 10 keV. At extremely low energies
(5 keV), the methods diverge from one another, suggesting that the higher-order potential interactions and backscattering effects accounted for in the FCMS become non-negligible at these energies. Furthermore, the implementation
of the FCMS enabled the reconstruction of the backscattered exit wave. The results successfully demonstrate the expected theoretical dependence of the backscattered signal on electron wavelength, providing a new tool for simulating
coherent EBSD signals in the scanning electron microscope (SEM).

In summary, the addition of PCMS and FCMS extends the validity of abTEM simulations for low voltage simulations, offering the ability for modeling radiation-sensitive materials and interpreting low-energy electron diffraction
data.