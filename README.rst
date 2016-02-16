cetbuildtools2
**************

A rewrite of the `FNAL cetbuildtools`_ `CMake`_ modules to 

1. Decouple the functionality from the `FNAL UPS`_ configuration management system

2. Modernize CMake usage

The intent is to keep gross functionality (compiling/linking flags and policy)
the same, whilst lower level interfaces such as target creation will be factored
to keep as close as possible to CMake interfaces.

.. _`FNAL cetbuildtools`: https://cdcvs.fnal.gov/redmine/projects/cetbuildtools
.. _`CMake`: https://www.cmake.org
.. _`FNAL UPS`: https://cdcvs.fnal.gov/redmine/projects/ups

License
=======
``cetbuildtools2`` is distributed under the OSI-approved BSD 3-clause License.
See `LICENSE`_ for details.

.. _`LICENSE`: LICENSE


Why reStructured Text?
======================

CMake modules can be documented using RST, and processed via CMake itself and/or
`Sphinx`_ to generate command-line, manual and webpage docs. Might as well
get this in place from the start!

.. _`Sphinx`: http://www.sphinx-doc.org/en/stable/

