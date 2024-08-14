Installation
=====

.. _installation:

Kairos requires nextflow and several bioinformatics packages. The dependencies can be installed through mamba (or conda), as in the following command: 

.. code-block:: bash

   
   git clone https://github.com/clb21565/kairos.git
   mamba install -n kairos -f environment.yml

After installing, download the target and mobile genetic element protein databases. Kairos includes default databases deepARG and mobileOG-db (v1.6 currently). 

.. code-block:: bash

   bash get_databases.sh
   ls ./databases/deepARG*
   ls ./databases/mobileOG-db*

Running the above chunk should put the databases in a new directory, databases, in pwd. 

Kairos has been developed using nextflow version 24.04.3.5916. Installation instructions for nextflow can be found `here`_. 

.. _here: https://www.nextflow.io/docs/latest/install.html
