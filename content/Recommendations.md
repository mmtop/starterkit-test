# Recommendations
This thesis implemented two new algorithms and coherent backscattering functionality to abTEM. While develop-
ing these methods, the focus lay in the theoretical implementation of these algorithms. Therefore, performance and
efficiency were not a priority . Although the laplace finite difference was adapted to run on the GPU, performance
compared to the CMS using the FFT method is much slower. Even for relatively low orders of the PCMS and FCMS
they are slower than the realspace CMS. Of course this is to be expected because of the extra terms. Yet, optimization
of the codebase may drastically improve performance.

Beyond simulation, it is important to bridge the gap between theoretical and experimental. It would be highly valuable
to compare the results from this thesis against real low voltage S/TEM experiments.

Having implemented the coherent backscattered contributions, this paper only shows its possibility for STEM-in-
SEM applications. Testing the implementation against a broader range of materials and for various optical parameters
would be very useful.

Finally, when reconstructing the backscattered signal the current code assumes perfect coherence where the complex
backscattered signals are allowed to interfere. A great addition would be to also have fully incoherent backscattered
signals where instead of the complex wavefunction we sum the wave intensities.