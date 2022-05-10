#!/bin/bash

# reference: https://hprc.tamu.edu/wiki/Grace:Batch, Example Job 2: A multi core, single node job
# how to submit *.slurm: [NetID@grace1 ~]$ sbatch MyJob.slurm

##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=saveRegionalStericHeightSunwayTH_2021Apr15       #Set the job name
#SBATCH --time=20:00:00               #Set the wall clock limit
#SBATCH --nodes=1                    #Request 1 node
#SBATCH --ntasks-per-node=8          #Request 8 tasks/cores per node
#SBATCH --mem=32G                    #Request 32GB per node 
#SBATCH --output=saveRegionalStericHeightSunwayTH_2021Apr15.%j      #Send stdout/err to "*.[jobID]" 

#Executable Lines
module purge
ml Anaconda3/5.3.0
source activate /scratch/group/ihesp/shared/conda/envs/envMar25/
python saveRegionalStericHeightSunwayTH_2021Apr15.py