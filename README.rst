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

Installing ``cetbuildtools2``
=============================
Prerequisites: `CMake`_ 3.0 or higher

Create build directory outside the ``cetbuildtools2`` source directory (i.e.
the directory holding this README file::

  $ ls
  cetbuildtools2.git
  $ mkdir cetbuildtools2.build
  $ cd cetbuildtools2.build

Run cmake in the build directory to configure the project, supplying a directory 
under which the programs and files should be installed plus the path to the
``cetbuildtools2`` source directory::

  $ cmake -DCMAKE_INSTALL_PREFIX=/some/install/dir ../cetbuildtools2.git

Run cmake again, passing the ``--build`` and ``--target`` arguments as
follows to install ``cetbuildtools2`` to the location chosen above::

  $ cmake --build . --target install

Before installing, unit tests may be run by building the ``test`` target::

  $ cmake --build . --target test

Using ``cetbuildtools2``
========================
TODO

Why reStructured Text for Documentation?
========================================

CMake modules can be documented using RST, and processed via CMake itself and/or
`Sphinx`_ to generate command-line, manual and webpage docs. Might as well
get this in place from the start!

.. _`Sphinx`: http://www.sphinx-doc.org/en/stable/

