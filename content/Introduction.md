---
abstract: |
    Accurate interpretation of data on the atomic scale obtained by S/TEM requires robust simulation methods. The most
    common method to achieve this is the multislice. The conventional multislice (CMS) algorithm relies on scattering
    physics assumptions which break down at lower accelerating voltages. This thesis presents an implementation of two
    improved versions of the multislice algorithm into the TEM simulation package abTEM written in Python. These are
    the Propagator Corrected Multislice (PCMS) and the Fully Corrected Multislice (FCMS). The former uses higher order
    terms to more accurately describe the spherical curvature of the Ewald Sphere, contrary to the parabolic approximation
    used in CMS. The Fully Corrected MS starts from the same Schrödinger equation as the other methods but makes fewer
    approximations concerning electron energy and simultaneously accounts for backscattering effects.
    All three methods are compared for a sample of SrTiO3 for various thicknesses and electron energies. The obtained
    results agree with previous literature, highlighting that the effects are negligible for high electron energies (∼200 keV)
    and start to appear around (∼50 keV). The Propagator corrected and Fully corrected MS agree until the energy drops
    approximately below 10 keV, where they begin to diverge. Additionally, the reconstructed backscattered signal follows
    the expected theoretical dependence on the square of the electron wavelength, showing significantly weaker signals at
    higher energies.
---

# Introduction

Transmission electron microscopy (TEM) is a powerful method for imaging the atomic scale @Williams_2009, leveraging the much
smaller wavelength of electrons compared to ordinary light, where diffraction causes a limit to resolution.

Computer simulation of the scattering process can be a powerful tool to interpret the complex scattering patterns
of the electron beam. To simulate the complex interactions of the electrons with the sample, various techniques exist.
This paper will focus on the multislice algorithm @Cowley_1957, which works by dividing potential of the sample into many
discrete slices and calculating the scattering for each slice, followed by a propagation through vacuum. The multislice
algorithm, in its conventional and most common form, works by assuming that the electrons move very fast. While
this is a valid assumption to make since commonly, high accelerating voltages are used for TEM, there are situations
where lower voltages are required. For example if the sample is radiation sensitive and higher energy beams would
damage the sample [@KAISER20111239; @EGERTON2004399]. Another reason for simulating with lower voltages is the use of STEM in SEM, where
a TEM measurement is performed inside a SEM which typically operates at a lower voltage @Sun2018. These situations
have sparked an increased interest in low voltage TEM. Therefore, being able to accurately model TEM even for these
lower voltages is of great importance.

In order to accurately simulate this, better models are required. Two recently-proposed extensions to the multislice
method will be implemented into python and added to the python package abTEM: the propagator corrected multislice
(PCMS) and the fully corrected multislice (FCMS) @Ming2013. abTEM is an open-source software written in Python which
makes performing multislice simulations very easy. The improved methods will be benchmarked compared to the
conventional multislice (CMS).

CMS, as it exists in abTEM, assumes that all electron scattering happens in the forward direction, meaning every
electron entering the sample will exit it on the other side. In reality however, there is a chance of the electrons scatter-
ing back to the electron source. This thesis adds this functionality to abTEM as well as the ability to reconstruct the
total backscattered wave which might be valuable to SEM simulation @SCHWEIZER2020112956.
